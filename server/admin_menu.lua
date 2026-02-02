-- ========================================
-- XP SYSTEM - ADMIN MENU SERVER
-- ========================================

local QBCore = exports['qb-core']:GetCoreObject()

-- ========================================
-- HELPER FUNCTION
-- ========================================

--- Check if player has admin permission
---@param source number
---@return boolean
local function HasAdminPermission(source)
    return IsPlayerAceAllowed(source, Config.AdminPermission)
end

-- ========================================
-- CALLBACKS
-- ========================================

--- Get all online players with XP data
lib.callback.register('qb-xpsystem:server:getOnlinePlayers', function(source)
    -- Check permission
    if not HasAdminPermission(source) then
        return {}
    end
    
    local players = {}
    local QBPlayers = QBCore.Functions.GetQBPlayers()
    
    for _, Player in pairs(QBPlayers) do
        local xpData = exports['qb-xpsystem']:GetPlayerXP(Player.PlayerData.source)
        
        if xpData then
            table.insert(players, {
                value = Player.PlayerData.source,
                label = Player.PlayerData.name .. ' [ID: ' .. Player.PlayerData.source .. ']',
                level = xpData.level,
                xp = xpData.xp
            })
        end
    end
    
    -- Sort by level (highest first)
    table.sort(players, function(a, b)
        return a.level > b.level
    end)
    
    return players
end)

--- Get detailed stats for a player
lib.callback.register('qb-xpsystem:server:getPlayerStats', function(source, targetId)
    -- Check permission
    if not HasAdminPermission(source) then
        return nil
    end
    
    local xpData = exports['qb-xpsystem']:GetPlayerXP(targetId)
    if not xpData then return nil end
    
    local requiredXP = exports['qb-xpsystem']:CalculateXPForLevel(xpData.level)
    local progress = (xpData.xp / requiredXP) * 100
    local xpToNext = requiredXP - xpData.xp
    
    return {
        level = xpData.level,
        maxLevel = Config.MaxLevel,
        currentXP = xpData.xp,
        requiredXP = requiredXP,
        totalXP = xpData.totalXP,
        progress = string.format('%.1f', progress),
        xpToNext = xpToNext,
        citizenid = xpData.citizenid
    }
end)

--- Get max level from config
lib.callback.register('qb-xpsystem:server:getMaxLevel', function(source)
    return Config.MaxLevel
end)

-- ========================================
-- ADMIN EVENTS
-- ========================================

--- Give XP to player
RegisterNetEvent('qb-xpsystem:server:adminGiveXP', function(targetId, amount, reason)
    local src = source
    
    -- Check permission
    if not HasAdminPermission(src) then
        TriggerClientEvent('QBCore:Notify', src, 'Keine Berechtigung', 'error')
        return
    end
    
    -- Validate
    if not targetId or not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Ungültige Eingabe', 'error')
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Spieler nicht gefunden', 'error')
        return
    end
    
    -- Give XP
    local success = exports['qb-xpsystem']:GiveXP(targetId, amount, reason or 'Admin Panel')
    
    if success then
        local adminPlayer = QBCore.Functions.GetPlayer(src)
        
        -- Notify target
        TriggerClientEvent('QBCore:Notify', targetId, 
            string.format('Ein Admin hat dir %d XP gegeben!', amount), 'success')
        
        -- Log to Discord
        TriggerEvent('qb-xpsystem:server:logAdminAction', src, targetId, 'GIVE_XP', {
            amount = amount,
            reason = reason,
            adminName = adminPlayer.PlayerData.name,
            targetName = targetPlayer.PlayerData.name
        })
        
        print(string.format('^3[XP Admin]^7 %s gave %d XP to %s (Reason: %s)', 
            adminPlayer.PlayerData.name, amount, targetPlayer.PlayerData.name, reason or 'None'))
    else
        TriggerClientEvent('QBCore:Notify', src, 'Fehler beim Geben von XP', 'error')
    end
end)

--- Set player level
RegisterNetEvent('qb-xpsystem:server:adminSetLevel', function(targetId, level)
    local src = source
    
    -- Check permission
    if not HasAdminPermission(src) then
        TriggerClientEvent('QBCore:Notify', src, 'Keine Berechtigung', 'error')
        return
    end
    
    -- Validate
    if not targetId or not level or level < 1 then
        TriggerClientEvent('QBCore:Notify', src, 'Ungültige Eingabe', 'error')
        return
    end
    
    if Config.MaxLevel > 0 and level > Config.MaxLevel then
        TriggerClientEvent('QBCore:Notify', src, 'Level zu hoch (Max: ' .. Config.MaxLevel .. ')', 'error')
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Spieler nicht gefunden', 'error')
        return
    end
    
    -- Get old level for logging
    local oldData = exports['qb-xpsystem']:GetPlayerXP(targetId)
    local oldLevel = oldData and oldData.level or 0
    
    -- Set level
    local success = exports['qb-xpsystem']:SetLevel(targetId, level)
    
    if success then
        local adminPlayer = QBCore.Functions.GetPlayer(src)
        
        -- Notify target
        TriggerClientEvent('QBCore:Notify', targetId, 
            string.format('Ein Admin hat dein Level auf %d gesetzt!', level), 'info')
        
        -- Log to Discord
        TriggerEvent('qb-xpsystem:server:logAdminAction', src, targetId, 'SET_LEVEL', {
            oldLevel = oldLevel,
            newLevel = level,
            adminName = adminPlayer.PlayerData.name,
            targetName = targetPlayer.PlayerData.name
        })
        
        print(string.format('^3[XP Admin]^7 %s set %s level to %d (was %d)', 
            adminPlayer.PlayerData.name, targetPlayer.PlayerData.name, level, oldLevel))
    else
        TriggerClientEvent('QBCore:Notify', src, 'Fehler beim Setzen des Levels', 'error')
    end
end)

--- Reset player XP
RegisterNetEvent('qb-xpsystem:server:adminResetXP', function(targetId)
    local src = source
    
    -- Check permission
    if not HasAdminPermission(src) then
        TriggerClientEvent('QBCore:Notify', src, 'Keine Berechtigung', 'error')
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Spieler nicht gefunden', 'error')
        return
    end
    
    -- Get old data for logging
    local oldData = exports['qb-xpsystem']:GetPlayerXP(targetId)
    
    -- Reset to starting level
    local success = exports['qb-xpsystem']:SetLevel(targetId, Config.StartingLevel)
    
    if success then
        local adminPlayer = QBCore.Functions.GetPlayer(src)
        
        -- Notify target
        TriggerClientEvent('QBCore:Notify', targetId, 
            'Ein Admin hat deine XP zurückgesetzt!', 'error')
        
        -- Log to Discord
        TriggerEvent('qb-xpsystem:server:logAdminAction', src, targetId, 'RESET_XP', {
            oldLevel = oldData and oldData.level or 0,
            oldXP = oldData and oldData.totalXP or 0,
            adminName = adminPlayer.PlayerData.name,
            targetName = targetPlayer.PlayerData.name
        })
        
        print(string.format('^3[XP Admin]^7 %s reset XP for %s (was Level %d)', 
            adminPlayer.PlayerData.name, targetPlayer.PlayerData.name, oldData and oldData.level or 0))
    else
        TriggerClientEvent('QBCore:Notify', src, 'Fehler beim Zurücksetzen', 'error')
    end
end)

print('^2[XP System]^7 Admin menu server initialized')
