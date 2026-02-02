local QBCore = exports['qb-core']:GetCoreObject()

-- ========================================
-- PLAYER DATA STORAGE
-- ========================================

local PlayerXPData = {}
local XPCooldowns = {}

-- ========================================
-- DATABASE INITIALIZATION
-- ========================================

CreateThread(function()
    if Config.Database.autoCreate then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `player_xp` (
                `citizenid` VARCHAR(50) NOT NULL,
                `level` INT(11) NOT NULL DEFAULT 1,
                `xp` INT(11) NOT NULL DEFAULT 0,
                `total_xp` INT(11) NOT NULL DEFAULT 0,
                PRIMARY KEY (`citizenid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])
        print('^2[XP System]^7 Database table checked/created successfully')
    end
end)

-- ========================================
-- XP CALCULATION FUNCTIONS
-- ========================================

--- Calculate XP required for a specific level
---@param level number
---@return number
local function CalculateXPForLevel(level)
    return math.floor(Config.BaseXP * (level * Config.LevelMultiplier))
end

--- Get total XP required to reach a level
---@param targetLevel number
---@return number
local function GetTotalXPForLevel(targetLevel)
    local totalXP = 0
    for i = 1, targetLevel - 1 do
        totalXP = totalXP + CalculateXPForLevel(i)
    end
    return totalXP
end

--- Calculate level from total XP
---@param totalXP number
---@return number level, number currentXP, number requiredXP
local function CalculateLevelFromXP(totalXP)
    local level = 1
    local xpForNextLevel = CalculateXPForLevel(level)
    local remainingXP = totalXP
    
    while remainingXP >= xpForNextLevel do
        remainingXP = remainingXP - xpForNextLevel
        level = level + 1
        if Config.MaxLevel > 0 and level >= Config.MaxLevel then
            return Config.MaxLevel, 0, 0
        end
        xpForNextLevel = CalculateXPForLevel(level)
    end
    
    return level, remainingXP, xpForNextLevel
end

-- ========================================
-- PLAYER DATA MANAGEMENT
-- ========================================

--- Load player XP data from database
---@param source number
local function LoadPlayerData(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    
    MySQL.query('SELECT * FROM player_xp WHERE citizenid = ?', {citizenid}, function(result)
        if result[1] then
            PlayerXPData[source] = {
                citizenid = citizenid,
                level = result[1].level,
                xp = result[1].xp,
                totalXP = result[1].total_xp
            }
        else
            -- Create new entry
            MySQL.insert('INSERT INTO player_xp (citizenid, level, xp, total_xp) VALUES (?, ?, ?, ?)',
                {citizenid, Config.StartingLevel, 0, 0})
            
            PlayerXPData[source] = {
                citizenid = citizenid,
                level = Config.StartingLevel,
                xp = 0,
                totalXP = 0
            }
        end
        
        -- Send data to client
        TriggerClientEvent('qb-xpsystem:client:updateXP', source, PlayerXPData[source])
        print(string.format('^2[XP System]^7 Loaded data for %s (Level %d)', Player.PlayerData.name, PlayerXPData[source].level))
    end)
end

--- Save player XP data to database
---@param source number
local function SavePlayerData(source)
    if not PlayerXPData[source] then return end
    
    local data = PlayerXPData[source]
    MySQL.update('UPDATE player_xp SET level = ?, xp = ?, total_xp = ? WHERE citizenid = ?',
        {data.level, data.xp, data.totalXP, data.citizenid})
end

--- Save all player data
local function SaveAllPlayerData()
    for source, _ in pairs(PlayerXPData) do
        SavePlayerData(source)
    end
    print('^2[XP System]^7 Saved all player data')
end

-- ========================================
-- REWARD SYSTEM
-- ========================================

--- Give reward to player for reaching a level
---@param source number
---@param level number
local function GiveReward(source, level)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    local reward = Config.LevelRewards.rewards[level]
    if not reward then return end
    
    -- Give money
    if reward.money then
        Player.Functions.AddMoney('cash', reward.money, 'Level ' .. level .. ' Reward')
    end
    
    -- Give items
    if reward.items then
        for _, item in ipairs(reward.items) do
            Player.Functions.AddItem(item.name, item.amount)
        end
    end
    
    -- Send notification
    if reward.message then
        TriggerClientEvent('QBCore:Notify', source, reward.message, 'success', 5000)
    end
    
    print(string.format('^2[XP System]^7 Gave level %d reward to %s', level, Player.PlayerData.name))
end

-- ========================================
-- XP GAIN & LEVEL UP LOGIC
-- ========================================

--- Give XP to a player with anti-exploit checks
---@param source number
---@param amount number
---@param reason string|nil
---@return boolean success
local function GivePlayerXP(source, amount, reason)
    -- Check if player data exists
    if not PlayerXPData[source] then
        print(string.format('^3[XP System]^7 Warning: Player %d data not loaded yet, attempting to load...', source))
        
        -- Try to load player data first
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            LoadPlayerData(source)
            Wait(500) -- Give it time to load
        end
        
        -- Check again
        if not PlayerXPData[source] then
            print(string.format('^1[XP System]^7 Error: Could not load player %d data', source))
            return false
        end
    end
    
    -- Anti-exploit: Check cooldown
    local currentTime = GetGameTimer()
    if XPCooldowns[source] and (currentTime - XPCooldowns[source]) < Config.XPCooldown then
        if Config.LogSuspiciousActivity then
            TriggerEvent('qb-xpsystem:server:logSuspicious', source, amount, 'Cooldown violation')
        end
        return false
    end
    
    -- Anti-exploit: Check max XP per event
    if amount > Config.MaxXPPerEvent then
        if Config.LogSuspiciousActivity then
            TriggerEvent('qb-xpsystem:server:logSuspicious', source, amount, 'Excessive XP amount')
        end
        amount = Config.MaxXPPerEvent
    end
    
    XPCooldowns[source] = currentTime
    
    local data = PlayerXPData[source]
    local oldLevel = data.level
    
    -- Add XP
    data.xp = data.xp + amount
    data.totalXP = data.totalXP + amount
    
    -- Check for level up(s)
    local leveledUp = false
    local newLevels = 0
    
    while data.xp >= CalculateXPForLevel(data.level) do
        if Config.MaxLevel > 0 and data.level >= Config.MaxLevel then
            data.xp = 0
            break
        end
        
        local xpRequired = CalculateXPForLevel(data.level)
        data.xp = data.xp - xpRequired
        data.level = data.level + 1
        leveledUp = true
        newLevels = newLevels + 1
        
        -- Check for level rewards
        if Config.LevelRewards.enabled and Config.LevelRewards.rewards[data.level] then
            GiveReward(source, data.level)
        end
    end
    
    -- Update client
    TriggerClientEvent('qb-xpsystem:client:updateXP', source, data)
    
    -- Handle level up
    if leveledUp then
        TriggerClientEvent('qb-xpsystem:client:levelUp', source, data.level, newLevels)
        TriggerEvent('qb-xpsystem:server:logLevelUp', source, oldLevel, data.level)
        
        -- Trigger event for other resources
        TriggerEvent('qb-xpsystem:server:playerLevelUp', source, oldLevel, data.level)
    end
    
    -- Save to database
    SavePlayerData(source)
    
    return true
end

-- ========================================
-- CALLBACKS
-- ========================================

QBCore.Functions.CreateCallback('qb-xpsystem:server:getRequiredXP', function(source, cb, level)
    cb(CalculateXPForLevel(level))
end)

-- ========================================
-- EXPORTS
-- ========================================

--- Get player XP data
---@param source number
---@return table|nil
exports('GetPlayerXP', function(source)
    return PlayerXPData[source]
end)

--- Give XP to player
---@param source number
---@param amount number
---@param reason string|nil
---@return boolean
exports('GiveXP', function(source, amount, reason)
    return GivePlayerXP(source, amount, reason)
end)

--- Remove XP from player
---@param source number
---@param amount number
---@return boolean
exports('RemoveXP', function(source, amount)
    if not PlayerXPData[source] then return false end
    
    local data = PlayerXPData[source]
    data.xp = math.max(0, data.xp - amount)
    data.totalXP = math.max(0, data.totalXP - amount)
    
    -- Recalculate level
    local newLevel, newXP, requiredXP = CalculateLevelFromXP(data.totalXP)
    data.level = newLevel
    data.xp = newXP
    
    TriggerClientEvent('qb-xpsystem:client:updateXP', source, data)
    SavePlayerData(source)
    
    return true
end)

--- Set player level
---@param source number
---@param level number
---@return boolean
exports('SetLevel', function(source, level)
    if not PlayerXPData[source] then return false end
    
    if Config.MaxLevel > 0 then
        level = math.min(level, Config.MaxLevel)
    end
    level = math.max(1, level)
    
    local data = PlayerXPData[source]
    data.level = level
    data.xp = 0
    data.totalXP = GetTotalXPForLevel(level)
    
    TriggerClientEvent('qb-xpsystem:client:updateXP', source, data)
    SavePlayerData(source)
    
    return true
end)

--- Get player level
---@param source number
---@return number|nil
exports('GetLevel', function(source)
    if not PlayerXPData[source] then return nil end
    return PlayerXPData[source].level
end)

--- Calculate XP required for level
---@param level number
---@return number
exports('CalculateXPForLevel', function(level)
    return CalculateXPForLevel(level)
end)

-- ========================================
-- EVENT HANDLERS
-- ========================================

RegisterNetEvent('QBCore:Server:PlayerLoaded', function(Player)
    local source = Player.PlayerData.source
    Wait(1000) -- Small delay to ensure everything is loaded
    LoadPlayerData(source)
end)

-- Also load on resource start for already connected players
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    Wait(2000) -- Wait for QBCore to be ready
    
    local Players = QBCore.Functions.GetQBPlayers()
    for _, Player in pairs(Players) do
        if Player then
            LoadPlayerData(Player.PlayerData.source)
        end
    end
    
    print(string.format('^2[XP System]^7 Loaded data for %d online players', #Players))
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(source)
    SavePlayerData(source)
    PlayerXPData[source] = nil
    XPCooldowns[source] = nil
end)

AddEventHandler('playerDropped', function()
    local source = source
    SavePlayerData(source)
    PlayerXPData[source] = nil
    XPCooldowns[source] = nil
end)

-- Save all data every 5 minutes
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutes
        SaveAllPlayerData()
    end
end)

-- Save all data on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SaveAllPlayerData()
    end
end)

print('^2[XP System]^7 Server initialized successfully')
