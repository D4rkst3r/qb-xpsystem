local QBCore = exports['qb-core']:GetCoreObject()

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

--- Check if player has admin permission using ACE system
---@param source number
---@return boolean
local function HasAdminPermission(source)
    -- Console always has permission
    if source == 0 then
        return true
    end
    return IsPlayerAceAllowed(source, Config.AdminPermission)
end

--- Get player by ID with error handling
---@param source number
---@param targetId number
---@return table|nil Player, number targetSource
local function GetTargetPlayer(source, targetId)
    local targetSource = tonumber(targetId)
    if not targetSource then
        TriggerClientEvent('QBCore:Notify', source, 'Ungültige Spieler ID', 'error')
        return nil, nil
    end
    
    local Player = QBCore.Functions.GetPlayer(targetSource)
    if not Player then
        TriggerClientEvent('QBCore:Notify', source, 'Spieler nicht gefunden', 'error')
        return nil, nil
    end
    
    return Player, targetSource
end

-- ========================================
-- ADMIN COMMANDS
-- ========================================

--- Command: /givexp [id] [amount]
--- Give XP to a player
QBCore.Commands.Add(Config.Commands.giveXP.name, Config.Commands.giveXP.help, Config.Commands.giveXP.params, false, function(source, args)
    -- Check ACE permission
    if not HasAdminPermission(source) then
        if source == 0 then
            print('^1[XP System]^7 Cannot send notification to console')
        else
            TriggerClientEvent('QBCore:Notify', source, 'Keine Berechtigung für diesen Befehl', 'error')
        end
        return
    end
    
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    
    if not targetId or not amount then
        if source == 0 then
            print('^3[XP System]^7 Verwendung: givexp [id] [amount]')
        else
            TriggerClientEvent('QBCore:Notify', source, 'Verwendung: /givexp [id] [amount]', 'error')
        end
        return
    end
    
    local Player, targetSource = GetTargetPlayer(source, targetId)
    if not Player then return end
    
    -- Validate amount
    if amount <= 0 or amount > 100000 then
        if source == 0 then
            print('^3[XP System]^7 XP Menge muss zwischen 1 und 100,000 liegen')
        else
            TriggerClientEvent('QBCore:Notify', source, 'XP Menge muss zwischen 1 und 100,000 liegen', 'error')
        end
        return
    end
    
    -- Give XP
    local success = exports['qb-xpsystem']:GiveXP(targetSource, amount, 'Admin Command')
    
    if success then
        local adminName = "Console"
        if source ~= 0 then
            local adminPlayer = QBCore.Functions.GetPlayer(source)
            adminName = adminPlayer.PlayerData.name
            TriggerClientEvent('QBCore:Notify', source, string.format('Du hast %s %d XP gegeben', Player.PlayerData.name, amount), 'success')
        else
            print(string.format('^2[XP System]^7 Gave %d XP to %s', amount, Player.PlayerData.name))
        end
        
        TriggerClientEvent('QBCore:Notify', targetSource, string.format('Du hast %d XP von einem Admin erhalten', amount), 'success')
        
        -- Log to Discord
        TriggerEvent('qb-xpsystem:server:logAdminAction', source, targetSource, 'GIVE_XP', {
            amount = amount,
            adminName = adminName,
            targetName = Player.PlayerData.name
        })
        
        print(string.format('^3[XP Admin]^7 %s gave %d XP to %s', adminName, amount, Player.PlayerData.name))
    else
        if source == 0 then
            print('^1[XP System]^7 Fehler beim Geben von XP')
        else
            TriggerClientEvent('QBCore:Notify', source, 'Fehler beim Geben von XP', 'error')
        end
    end
end)

--- Command: /setlevel [id] [level]
--- Set player level
QBCore.Commands.Add(Config.Commands.setLevel.name, Config.Commands.setLevel.help, Config.Commands.setLevel.params, false, function(source, args)
    -- Check ACE permission
    if not HasAdminPermission(source) then
        TriggerClientEvent('QBCore:Notify', source, 'Keine Berechtigung für diesen Befehl', 'error')
        return
    end
    
    local targetId = tonumber(args[1])
    local level = tonumber(args[2])
    
    if not targetId or not level then
        TriggerClientEvent('QBCore:Notify', source, 'Verwendung: /setlevel [id] [level]', 'error')
        return
    end
    
    local Player, targetSource = GetTargetPlayer(source, targetId)
    if not Player then return end
    
    -- Validate level
    if level < 1 or (Config.MaxLevel > 0 and level > Config.MaxLevel) then
        TriggerClientEvent('QBCore:Notify', source, string.format('Level muss zwischen 1 und %d liegen', Config.MaxLevel > 0 and Config.MaxLevel or 'unbegrenzt'), 'error')
        return
    end
    
    -- Get old level for logging
    local oldData = exports['qb-xpsystem']:GetPlayerXP(targetSource)
    local oldLevel = oldData and oldData.level or 0
    
    -- Set level
    local success = exports['qb-xpsystem']:SetLevel(targetSource, level)
    
    if success then
        local adminPlayer = QBCore.Functions.GetPlayer(source)
        TriggerClientEvent('QBCore:Notify', source, string.format('Du hast das Level von %s auf %d gesetzt', Player.PlayerData.name, level), 'success')
        TriggerClientEvent('QBCore:Notify', targetSource, string.format('Dein Level wurde von einem Admin auf %d gesetzt', level), 'info')
        
        -- Log to Discord
        TriggerEvent('qb-xpsystem:server:logAdminAction', source, targetSource, 'SET_LEVEL', {
            oldLevel = oldLevel,
            newLevel = level,
            adminName = adminPlayer.PlayerData.name,
            targetName = Player.PlayerData.name
        })
        
        print(string.format('^3[XP Admin]^7 %s set %s level to %d (was %d)', adminPlayer.PlayerData.name, Player.PlayerData.name, level, oldLevel))
    else
        TriggerClientEvent('QBCore:Notify', source, 'Fehler beim Setzen des Levels', 'error')
    end
end)

--- Command: /resetxp [id]
--- Reset player XP and level
QBCore.Commands.Add(Config.Commands.resetXP.name, Config.Commands.resetXP.help, Config.Commands.resetXP.params, false, function(source, args)
    -- Check ACE permission
    if not HasAdminPermission(source) then
        TriggerClientEvent('QBCore:Notify', source, 'Keine Berechtigung für diesen Befehl', 'error')
        return
    end
    
    local targetId = tonumber(args[1])
    
    if not targetId then
        TriggerClientEvent('QBCore:Notify', source, 'Verwendung: /resetxp [id]', 'error')
        return
    end
    
    local Player, targetSource = GetTargetPlayer(source, targetId)
    if not Player then return end
    
    -- Get old data for logging
    local oldData = exports['qb-xpsystem']:GetPlayerXP(targetSource)
    
    -- Reset to starting level
    local success = exports['qb-xpsystem']:SetLevel(targetSource, Config.StartingLevel)
    
    if success then
        local adminPlayer = QBCore.Functions.GetPlayer(source)
        TriggerClientEvent('QBCore:Notify', source, string.format('Du hast die XP von %s zurückgesetzt', Player.PlayerData.name), 'success')
        TriggerClientEvent('QBCore:Notify', targetSource, 'Deine XP und dein Level wurden von einem Admin zurückgesetzt', 'error')
        
        -- Log to Discord
        TriggerEvent('qb-xpsystem:server:logAdminAction', source, targetSource, 'RESET_XP', {
            oldLevel = oldData and oldData.level or 0,
            oldXP = oldData and oldData.totalXP or 0,
            adminName = adminPlayer.PlayerData.name,
            targetName = Player.PlayerData.name
        })
        
        print(string.format('^3[XP Admin]^7 %s reset XP for %s (was Level %d)', adminPlayer.PlayerData.name, Player.PlayerData.name, oldData and oldData.level or 0))
    else
        TriggerClientEvent('QBCore:Notify', source, 'Fehler beim Zurücksetzen der XP', 'error')
    end
end)

--- Command: /checkstats [id]
--- Check player stats (or self if no ID provided)
QBCore.Commands.Add(Config.Commands.checkStats.name, Config.Commands.checkStats.help, Config.Commands.checkStats.params, false, function(source, args)
    -- Check ACE permission for checking others
    local targetId = args[1] and tonumber(args[1])
    local checkingOther = targetId and targetId ~= source
    
    if checkingOther and not HasAdminPermission(source) then
        TriggerClientEvent('QBCore:Notify', source, 'Keine Berechtigung zum Überprüfen anderer Spieler', 'error')
        return
    end
    
    -- Determine target
    local targetSource = targetId or source
    local Player = QBCore.Functions.GetPlayer(targetSource)
    
    if not Player then
        TriggerClientEvent('QBCore:Notify', source, 'Spieler nicht gefunden', 'error')
        return
    end
    
    -- Get XP data
    local xpData = exports['qb-xpsystem']:GetPlayerXP(targetSource)
    
    if not xpData then
        TriggerClientEvent('QBCore:Notify', source, 'Keine XP Daten gefunden', 'error')
        return
    end
    
    -- Calculate required XP for next level
    local requiredXP = exports['qb-xpsystem']:CalculateXPForLevel(xpData.level)
    local progress = (xpData.xp / requiredXP) * 100
    
    -- Build stats message
    local statsMessage = string.format(
        [[
<strong>XP Stats für %s</strong><br>
━━━━━━━━━━━━━━━━━━━━<br>
<strong>Level:</strong> %d%s<br>
<strong>Aktueller XP:</strong> %d / %d<br>
<strong>Fortschritt:</strong> %.1f%%<br>
<strong>Gesamt XP:</strong> %s<br>
<strong>CitizenID:</strong> %s
        ]],
        Player.PlayerData.name,
        xpData.level,
        (Config.MaxLevel > 0 and ' / ' .. Config.MaxLevel or ''),
        xpData.xp,
        requiredXP,
        progress,
        formatNumber(xpData.totalXP),
        xpData.citizenid
    )
    
    TriggerClientEvent('qb-xpsystem:client:showStats', source, statsMessage)
    
    -- Log if admin is checking another player
    if checkingOther then
        local adminPlayer = QBCore.Functions.GetPlayer(source)
        print(string.format('^3[XP Admin]^7 %s checked stats for %s (Level %d)', adminPlayer.PlayerData.name, Player.PlayerData.name, xpData.level))
    end
end)

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

--- Format number with commas
---@param number number
---@return string
function formatNumber(number)
    local formatted = tostring(number)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- ========================================
-- CONSOLE COMMANDS (for RCON)
-- ========================================

RegisterCommand('xp_save_all', function()
    local count = 0
    for source, _ in pairs(GetPlayers()) do
        exports['qb-xpsystem']:GetPlayerXP(tonumber(source))
        count = count + 1
    end
    print(string.format('^2[XP System]^7 Manually saved %d player(s) XP data', count))
end, true)

RegisterCommand('xp_reload', function()
    print('^3[XP System]^7 Reloading configuration...')
    -- Reload config (resource restart required for full reload)
    print('^2[XP System]^7 Please restart the resource for full configuration reload')
end, true)

print('^2[XP System]^7 Commands initialized successfully')
