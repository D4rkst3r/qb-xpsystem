-- ========================================
-- XP SYSTEM - PLAYER MENU SERVER
-- ========================================

local QBCore = exports['qb-core']:GetCoreObject()

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

--- Format number with commas
---@param number number
---@return string
local function FormatNumber(number)
    local formatted = tostring(number)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

--- Get next reward level
---@param currentLevel number
---@return number|nil, string|nil
local function GetNextReward(currentLevel)
    if not Config.LevelRewards.enabled then return nil, nil end
    
    local nextLevel = nil
    for level, reward in pairs(Config.LevelRewards.rewards) do
        if level > currentLevel then
            if not nextLevel or level < nextLevel then
                nextLevel = level
            end
        end
    end
    
    if nextLevel and Config.LevelRewards.rewards[nextLevel] then
        local reward = Config.LevelRewards.rewards[nextLevel]
        local rewardText = ''
        
        if reward.money then
            rewardText = '$' .. FormatNumber(reward.money)
        end
        
        if reward.items and #reward.items > 0 then
            if rewardText ~= '' then rewardText = rewardText .. ' + ' end
            rewardText = rewardText .. #reward.items .. ' Items'
        end
        
        return nextLevel, rewardText
    end
    
    return nil, nil
end

-- ========================================
-- CALLBACKS
-- ========================================

--- Get player's own stats
lib.callback.register('qb-xpsystem:server:getMyStats', function(source)
    local xpData = exports['qb-xpsystem']:GetPlayerXP(source)
    if not xpData then return nil end
    
    local requiredXP = exports['qb-xpsystem']:CalculateXPForLevel(xpData.level)
    local progress = (xpData.xp / requiredXP) * 100
    local xpToNext = requiredXP - xpData.xp
    
    -- Get rank
    local rank = 1
    MySQL.query('SELECT COUNT(*) as count FROM player_xp WHERE total_xp > ?', {xpData.totalXP}, function(result)
        if result and result[1] then
            rank = result[1].count + 1
        end
    end)
    
    Wait(100) -- Small wait for rank calculation
    
    -- Get next reward
    local nextRewardLevel, nextReward = GetNextReward(xpData.level)
    
    return {
        level = xpData.level,
        maxLevel = Config.MaxLevel,
        currentXP = FormatNumber(xpData.xp),
        requiredXP = FormatNumber(requiredXP),
        totalXP = FormatNumber(xpData.totalXP),
        progress = string.format('%.1f', progress),
        xpToNext = FormatNumber(xpToNext),
        rank = rank,
        nextRewardLevel = nextRewardLevel,
        nextReward = nextReward
    }
end)

--- Get leaderboard
lib.callback.register('qb-xpsystem:server:getLeaderboard', function(source)
    local leaderboard = {}
    
    MySQL.query('SELECT citizenid, level, total_xp FROM player_xp ORDER BY total_xp DESC LIMIT 10', {}, function(result)
        if result then
            for i, data in ipairs(result) do
                local Player = QBCore.Functions.GetPlayerByCitizenId(data.citizenid)
                local name = 'Unbekannt'
                local online = false
                
                if Player then
                    name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
                    online = true
                else
                    -- Get name from database
                    MySQL.query('SELECT JSON_EXTRACT(charinfo, "$.firstname") as firstname, JSON_EXTRACT(charinfo, "$.lastname") as lastname FROM players WHERE citizenid = ?', 
                        {data.citizenid}, function(charResult)
                        if charResult and charResult[1] then
                            local firstname = charResult[1].firstname or 'Unknown'
                            local lastname = charResult[1].lastname or 'Player'
                            -- Remove quotes from JSON_EXTRACT
                            firstname = string.gsub(firstname, '"', '')
                            lastname = string.gsub(lastname, '"', '')
                            name = firstname .. ' ' .. lastname
                        end
                    end)
                    Wait(50)
                end
                
                table.insert(leaderboard, {
                    rank = i,
                    name = name,
                    level = data.level,
                    totalXP = FormatNumber(data.total_xp),
                    online = online
                })
            end
        end
    end)
    
    Wait(200) -- Wait for database queries
    
    return leaderboard
end)

--- Get rewards list
lib.callback.register('qb-xpsystem:server:getRewardsList', function(source)
    if not Config.LevelRewards.enabled then return {} end
    
    local xpData = exports['qb-xpsystem']:GetPlayerXP(source)
    if not xpData then return {} end
    
    local rewards = {}
    
    -- Get all reward levels and sort them
    local levels = {}
    for level, _ in pairs(Config.LevelRewards.rewards) do
        table.insert(levels, level)
    end
    table.sort(levels)
    
    -- Build rewards list
    for _, level in ipairs(levels) do
        local reward = Config.LevelRewards.rewards[level]
        local unlocked = xpData.level >= level
        
        -- Format money
        local moneyText = reward.money and ('$' .. FormatNumber(reward.money)) or nil
        
        -- Format items
        local itemsText = nil
        if reward.items and #reward.items > 0 then
            local itemNames = {}
            for _, item in ipairs(reward.items) do
                table.insert(itemNames, item.amount .. 'x ' .. item.name)
            end
            itemsText = table.concat(itemNames, ', ')
        end
        
        table.insert(rewards, {
            level = level,
            unlocked = unlocked,
            money = moneyText,
            items = itemsText,
            message = reward.message
        })
    end
    
    return rewards
end)

print('^2[XP System]^7 Player menu server initialized')
