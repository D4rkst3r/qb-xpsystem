-- ========================================
-- XP SYSTEM - STYLE PREFERENCES SERVER
-- ========================================

local QBCore = exports['qb-core']:GetCoreObject()

-- ========================================
-- DATABASE INITIALIZATION
-- ========================================

CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `player_xp_preferences` (
            `citizenid` VARCHAR(50) NOT NULL,
            `style` INT(11) NOT NULL DEFAULT 1,
            `size` VARCHAR(20) NOT NULL DEFAULT 'medium',
            `position` VARCHAR(20) NOT NULL DEFAULT 'bottom-right',
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    print('^2[XP System]^7 Style preferences table checked/created')
end)

-- ========================================
-- LOAD PREFERENCES
-- ========================================

lib.callback.register('qb-xpsystem:server:getStylePreferences', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end
    
    local citizenid = Player.PlayerData.citizenid
    
    local result = MySQL.query.await('SELECT * FROM player_xp_preferences WHERE citizenid = ?', {citizenid})
    
    if result and result[1] then
        return {
            style = result[1].style,
            size = result[1].size,
            position = result[1].position
        }
    else
        -- Create default entry
        MySQL.insert('INSERT INTO player_xp_preferences (citizenid, style, size, position) VALUES (?, ?, ?, ?)',
            {citizenid, 1, 'medium', 'bottom-right'})
        
        return {
            style = 1,
            size = 'medium',
            position = 'bottom-right'
        }
    end
end)

-- ========================================
-- SAVE PREFERENCES
-- ========================================

RegisterNetEvent('qb-xpsystem:server:saveStylePreferences', function(prefs)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    
    MySQL.update('UPDATE player_xp_preferences SET style = ?, size = ?, position = ? WHERE citizenid = ?',
        {prefs.style, prefs.size, prefs.position, citizenid})
    
    print(string.format('^2[XP System]^7 Saved style preferences for %s (Style: %d, Size: %s, Position: %s)',
        Player.PlayerData.name, prefs.style, prefs.size, prefs.position))
end)

print('^2[XP System]^7 Style preferences server initialized')
