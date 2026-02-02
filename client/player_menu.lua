-- ========================================
-- XP SYSTEM - PLAYER MENU (ox_lib)
-- ========================================

local QBCore = exports['qb-core']:GetCoreObject()

-- ========================================
-- FORWARD DECLARATIONS
-- ========================================

local OpenPlayerMenu
local ShowMyStats
local ShowLeaderboard
local ShowRewards
local ShowInfo

-- ========================================
-- MAIN PLAYER MENU
-- ========================================

OpenPlayerMenu = function()
    lib.registerContext({
        id = 'xp_player_main',
        title = '🎮 XP System - Menü',
        options = {
            {
                title = '📊 Meine Stats',
                description = 'Zeige deine XP-Statistiken',
                icon = 'chart-line',
                iconColor = '#3B82F6',
                onSelect = function()
                    ShowMyStats()
                end
            },
            {
                title = '🏆 Leaderboard',
                description = 'Top 10 Spieler',
                icon = 'trophy',
                iconColor = '#FFD700',
                onSelect = function()
                    ShowLeaderboard()
                end
            },
            {
                title = '🎁 Level Belohnungen',
                description = 'Zeige alle Level-Rewards',
                icon = 'gift',
                iconColor = '#10B981',
                onSelect = function()
                    ShowRewards()
                end
            },
            {
                title = 'ℹ️ XP System Info',
                description = 'Wie funktioniert das XP-System?',
                icon = 'info-circle',
                iconColor = '#8B5CF6',
                onSelect = function()
                    ShowInfo()
                end
            }
        }
    })
    
    lib.showContext('xp_player_main')
end

-- ========================================
-- MY STATS
-- ========================================

ShowMyStats = function()
    lib.callback('qb-xpsystem:server:getMyStats', false, function(stats)
        if not stats then
            lib.notify({
                title = 'XP System',
                description = 'Fehler beim Laden der Stats',
                type = 'error'
            })
            return
        end
        
        lib.registerContext({
            id = 'xp_my_stats',
            title = '📊 Meine Stats',
            menu = 'xp_player_main',
            options = {
                {
                    title = 'Level Informationen',
                    icon = 'chart-bar',
                    iconColor = '#3B82F6',
                    readOnly = true,
                    metadata = {
                        {label = 'Aktuelles Level', value = stats.level},
                        {label = 'Max Level', value = stats.maxLevel > 0 and stats.maxLevel or '∞'},
                        {label = 'Fortschritt', value = stats.progress .. '%'},
                        {label = 'Rang', value = '#' .. stats.rank}
                    }
                },
                {
                    title = 'XP Informationen',
                    icon = 'star',
                    iconColor = '#F59E0B',
                    readOnly = true,
                    metadata = {
                        {label = 'Aktuell', value = string.format('%s / %s XP', stats.currentXP, stats.requiredXP)},
                        {label = 'Gesamt verdient', value = string.format('%s XP', stats.totalXP)},
                        {label = 'Noch benötigt', value = stats.xpToNext .. ' XP'}
                    }
                },
                {
                    title = 'Nächste Belohnung',
                    icon = 'gift',
                    iconColor = '#10B981',
                    readOnly = true,
                    metadata = stats.nextReward and {
                        {label = 'Bei Level', value = stats.nextRewardLevel},
                        {label = 'Belohnung', value = stats.nextReward}
                    } or {
                        {label = 'Info', value = 'Keine weiteren Rewards'}
                    }
                }
            }
        })
        
        lib.showContext('xp_my_stats')
    end)
end

-- ========================================
-- LEADERBOARD
-- ========================================

ShowLeaderboard = function()
    lib.callback('qb-xpsystem:server:getLeaderboard', false, function(leaderboard)
        if not leaderboard or #leaderboard == 0 then
            lib.notify({
                title = 'XP System',
                description = 'Keine Daten verfügbar',
                type = 'error'
            })
            return
        end
        
        local options = {}
        
        for i, entry in ipairs(leaderboard) do
            local medal = ''
            local color = '#FFFFFF'
            
            if i == 1 then
                medal = '🥇 '
                color = '#FFD700'
            elseif i == 2 then
                medal = '🥈 '
                color = '#C0C0C0'
            elseif i == 3 then
                medal = '🥉 '
                color = '#CD7F32'
            else
                medal = '#' .. i .. ' '
            end
            
            table.insert(options, {
                title = medal .. entry.name,
                description = entry.online and '🟢 Online' or '⚫ Offline',
                icon = 'user',
                iconColor = color,
                readOnly = true,
                metadata = {
                    {label = 'Level', value = entry.level},
                    {label = 'Gesamt XP', value = string.format('%s XP', entry.totalXP)}
                }
            })
        end
        
        lib.registerContext({
            id = 'xp_leaderboard',
            title = '🏆 XP Leaderboard - Top 10',
            menu = 'xp_player_main',
            options = options
        })
        
        lib.showContext('xp_leaderboard')
    end)
end

-- ========================================
-- REWARDS
-- ========================================

ShowRewards = function()
    lib.callback('qb-xpsystem:server:getRewardsList', false, function(rewards)
        if not rewards or #rewards == 0 then
            lib.notify({
                title = 'XP System',
                description = 'Keine Belohnungen konfiguriert',
                type = 'info'
            })
            return
        end
        
        local options = {}
        
        for _, reward in ipairs(rewards) do
            local status = reward.unlocked and '✅ Freigeschaltet' or '🔒 Gesperrt'
            local color = reward.unlocked and '#10B981' or '#6B7280'
            
            table.insert(options, {
                title = 'Level ' .. reward.level,
                description = status,
                icon = reward.unlocked and 'check-circle' or 'lock',
                iconColor = color,
                readOnly = true,
                metadata = {
                    {label = 'Geld', value = reward.money and ('$' .. reward.money) or '-'},
                    {label = 'Items', value = reward.items or '-'},
                    {label = 'Nachricht', value = reward.message or '-'}
                }
            })
        end
        
        lib.registerContext({
            id = 'xp_rewards',
            title = '🎁 Level Belohnungen',
            menu = 'xp_player_main',
            options = options
        })
        
        lib.showContext('xp_rewards')
    end)
end

-- ========================================
-- INFO
-- ========================================

ShowInfo = function()
    lib.registerContext({
        id = 'xp_info',
        title = 'ℹ️ XP System Info',
        menu = 'xp_player_main',
        options = {
            {
                title = 'Wie funktioniert es?',
                icon = 'question-circle',
                readOnly = true,
                metadata = {
                    {label = '1.', value = 'Verdiene XP durch Aktivitäten'},
                    {label = '2.', value = 'Erreiche neue Level'},
                    {label = '3.', value = 'Erhalte Belohnungen'},
                    {label = '4.', value = 'Steige im Rang auf!'}
                }
            },
            {
                title = 'XP Quellen',
                icon = 'star',
                readOnly = true,
                metadata = {
                    {label = 'Jobs', value = 'Polizei, EMS, Mechaniker, etc.'},
                    {label = 'Aktivitäten', value = 'Fischen, Mining, Crafting'},
                    {label = 'Events', value = 'Server-Events & Specials'},
                    {label = 'Spielzeit', value = 'Passives XP beim Spielen'}
                }
            },
            {
                title = 'Commands',
                icon = 'terminal',
                readOnly = true,
                metadata = {
                    {label = '/xpmenu', value = 'Öffnet dieses Menü'},
                    {label = '/checkstats', value = 'Schnelle Stats-Anzeige'},
                    {label = 'F6', value = 'Toggle XP-Anzeige'}
                }
            }
        }
    })
    
    lib.showContext('xp_info')
end

-- ========================================
-- COMMANDS
-- ========================================

-- Player Command
RegisterCommand('xpmenu', function()
    OpenPlayerMenu()
end, false)

-- Register Key Mapping
RegisterKeyMapping('xpmenu', 'XP Menü öffnen', 'keyboard', '')

print('^2[XP System]^7 Player menu initialized')
