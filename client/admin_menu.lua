-- ========================================
-- XP SYSTEM - ADMIN MENU (ox_lib)
-- ========================================

local QBCore = exports['qb-core']:GetCoreObject()

-- ========================================
-- FORWARD DECLARATIONS
-- ========================================

local OpenAdminMenu
local OpenPlayerActions
local ShowPlayerStats
local GiveXPDialog
local SetLevelDialog
local ResetXPConfirm

-- ========================================
-- MAIN ADMIN MENU
-- ========================================

OpenAdminMenu = function()
    -- Get online players from server
    lib.callback('qb-xpsystem:server:getOnlinePlayers', false, function(players)
        if not players or #players == 0 then
            lib.notify({
                title = 'XP System',
                description = 'Keine Spieler online',
                type = 'error'
            })
            return
        end
        
        -- Create player options for context menu
        local playerOptions = {}
        for _, player in ipairs(players) do
            table.insert(playerOptions, {
                title = player.label,
                description = 'Level ' .. player.level .. ' | ' .. player.xp .. ' XP',
                icon = 'user',
                iconColor = player.level >= 50 and '#FFD700' or '#FFFFFF',
                onSelect = function()
                    OpenPlayerActions(player.value, player.label, player.level, player.xp)
                end
            })
        end
        
        -- Register and show context menu
        lib.registerContext({
            id = 'xp_admin_main',
            title = '🎮 XP System - Admin Panel',
            options = playerOptions
        })
        
        lib.showContext('xp_admin_main')
    end)
end

-- ========================================
-- PLAYER ACTIONS MENU
-- ========================================

OpenPlayerActions = function(playerId, playerName, currentLevel, currentXP)
    lib.registerContext({
        id = 'xp_admin_actions',
        title = '👤 ' .. playerName,
        menu = 'xp_admin_main', -- Back button
        options = {
            {
                title = '📊 Stats anzeigen',
                description = 'Zeige detaillierte Stats',
                icon = 'chart-line',
                iconColor = '#3B82F6',
                onSelect = function()
                    ShowPlayerStats(playerId, playerName)
                end
            },
            {
                title = '📈 XP geben',
                description = 'Gib dem Spieler XP',
                icon = 'arrow-up',
                iconColor = '#10B981',
                onSelect = function()
                    GiveXPDialog(playerId, playerName, currentLevel, currentXP)
                end
            },
            {
                title = '🎯 Level setzen',
                description = 'Setze ein bestimmtes Level',
                icon = 'bullseye',
                iconColor = '#F59E0B',
                onSelect = function()
                    SetLevelDialog(playerId, playerName)
                end
            },
            {
                title = '🔄 XP zurücksetzen',
                description = 'Reset auf Level 1',
                icon = 'undo',
                iconColor = '#EF4444',
                onSelect = function()
                    ResetXPConfirm(playerId, playerName)
                end
            }
        }
    })
    
    lib.showContext('xp_admin_actions')
end

-- ========================================
-- SHOW PLAYER STATS
-- ========================================

ShowPlayerStats = function(playerId, playerName)
    lib.callback('qb-xpsystem:server:getPlayerStats', false, function(stats)
        if not stats then
            lib.notify({
                title = 'XP System',
                description = 'Fehler beim Laden der Stats',
                type = 'error'
            })
            return
        end
        
        lib.registerContext({
            id = 'xp_player_stats',
            title = '📊 Stats - ' .. playerName,
            menu = 'xp_admin_actions',
            options = {
                {
                    title = 'Level Informationen',
                    icon = 'chart-bar',
                    readOnly = true,
                    metadata = {
                        {label = 'Aktuelles Level', value = stats.level},
                        {label = 'Max Level', value = stats.maxLevel > 0 and stats.maxLevel or 'Unbegrenzt'},
                        {label = 'Fortschritt', value = stats.progress .. '%'}
                    }
                },
                {
                    title = 'XP Informationen',
                    icon = 'star',
                    readOnly = true,
                    metadata = {
                        {label = 'Aktuell', value = string.format('%s / %s XP', stats.currentXP, stats.requiredXP)},
                        {label = 'Gesamt', value = stats.totalXP .. ' XP'},
                        {label = 'Bis Level-Up', value = stats.xpToNext .. ' XP'}
                    }
                },
                {
                    title = 'Account Details',
                    icon = 'user',
                    readOnly = true,
                    metadata = {
                        {label = 'CitizenID', value = stats.citizenid},
                        {label = 'Spieler ID', value = playerId}
                    }
                }
            }
        })
        
        lib.showContext('xp_player_stats')
    end, playerId)
end

-- ========================================
-- GIVE XP DIALOG
-- ========================================

GiveXPDialog = function(playerId, playerName, currentLevel, currentXP)
    local input = lib.inputDialog('📈 XP geben - ' .. playerName, {
        {
            type = 'number',
            label = 'XP Menge',
            description = 'Wie viel XP möchtest du geben?',
            icon = 'arrow-up',
            required = true,
            min = 1,
            max = 100000,
            default = 500
        },
        {
            type = 'input',
            label = 'Grund (Optional)',
            description = 'Warum gibst du XP?',
            icon = 'message',
            placeholder = 'z.B. Event-Gewinn'
        }
    })
    
    if not input then 
        OpenPlayerActions(playerId, playerName, currentLevel, currentXP)
        return 
    end
    
    local amount = tonumber(input[1])
    local reason = input[2] or 'Admin Panel'
    
    -- Send to server
    TriggerServerEvent('qb-xpsystem:server:adminGiveXP', playerId, amount, reason)
    
    lib.notify({
        title = 'XP System',
        description = 'Du hast ' .. playerName .. ' ' .. amount .. ' XP gegeben',
        type = 'success'
    })
    
    -- Go back to actions menu
    Wait(1000)
    OpenPlayerActions(playerId, playerName, currentLevel, currentXP)
end

-- ========================================
-- SET LEVEL DIALOG
-- ========================================

SetLevelDialog = function(playerId, playerName)
    lib.callback('qb-xpsystem:server:getMaxLevel', false, function(maxLevel)
        local input = lib.inputDialog('🎯 Level setzen - ' .. playerName, {
            {
                type = 'number',
                label = 'Neues Level',
                description = maxLevel > 0 and ('Level 1-' .. maxLevel) or 'Beliebiges Level',
                icon = 'bullseye',
                required = true,
                min = 1,
                max = maxLevel > 0 and maxLevel or 999,
                default = 10
            }
        })
        
        if not input then 
            OpenAdminMenu()
            return 
        end
        
        local level = tonumber(input[1])
        
        -- Send to server
        TriggerServerEvent('qb-xpsystem:server:adminSetLevel', playerId, level)
        
        lib.notify({
            title = 'XP System',
            description = 'Du hast ' .. playerName .. ' auf Level ' .. level .. ' gesetzt',
            type = 'success'
        })
        
        -- Go back to main menu
        Wait(1000)
        OpenAdminMenu()
    end)
end

-- ========================================
-- RESET XP CONFIRMATION
-- ========================================

ResetXPConfirm = function(playerId, playerName)
    local alert = lib.alertDialog({
        header = '⚠️ XP zurücksetzen',
        content = 'Möchtest du wirklich die XP von **' .. playerName .. '** zurücksetzen?\n\nDies kann **nicht** rückgängig gemacht werden!',
        centered = true,
        cancel = true,
        labels = {
            confirm = 'Ja, zurücksetzen',
            cancel = 'Abbrechen'
        }
    })
    
    if alert == 'confirm' then
        -- Send to server
        TriggerServerEvent('qb-xpsystem:server:adminResetXP', playerId)
        
        lib.notify({
            title = 'XP System',
            description = playerName .. ' wurde auf Level 1 zurückgesetzt',
            type = 'info'
        })
        
        -- Go back to main menu
        Wait(1000)
        OpenAdminMenu()
    else
        OpenAdminMenu()
    end
end

-- ========================================
-- COMMANDS
-- ========================================

-- Admin Command
RegisterCommand('xpadmin', function()
    OpenAdminMenu()
end, false)

-- Register Key Mapping
RegisterKeyMapping('xpadmin', 'XP Admin Menu öffnen', 'keyboard', '')

print('^2[XP System]^7 Admin menu initialized')
