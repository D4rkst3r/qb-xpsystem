-- ========================================
-- QB-XPSYSTEM INTEGRATION EXAMPLES
-- ========================================
-- 
-- Diese Datei enthält Beispiele, wie du das XP-System
-- in deine eigenen Scripts integrieren kannst.
-- 
-- WICHTIG: Dies ist KEINE funktionierende Ressource!
-- Kopiere die Beispiele in deine eigenen Scripts.
-- ========================================

-- ========================================
-- BEISPIEL 1: XP FÜR POLIZEI-JOBS
-- ========================================

-- In qb-policejob/server/main.lua

-- XP für Arrests geben
RegisterNetEvent('police:server:JailPlayer', function(playerId, time)
    local src = source
    -- Dein bestehender Code...
    
    -- XP geben basierend auf Gefängniszeit
    local xpAmount = math.floor(time / 5) -- 1 XP pro 5 Sekunden
    exports['qb-xpsystem']:GiveXP(src, xpAmount, "Verdächtigen eingesperrt")
end)

-- XP für Tickets geben
RegisterNetEvent('police:server:billPlayer', function(playerId, price)
    local src = source
    -- Dein bestehender Code...
    
    -- XP basierend auf Ticket-Höhe
    local xpAmount = math.floor(price / 100) -- 1 XP pro $100
    exports['qb-xpsystem']:GiveXP(src, xpAmount, "Strafzettel ausgestellt")
end)

-- XP für Beweise sichern
RegisterNetEvent('police:server:SetEvidence', function()
    local src = source
    -- Dein bestehender Code...
    
    exports['qb-xpsystem']:GiveXP(src, 30, "Beweise gesichert")
end)

-- ========================================
-- BEISPIEL 2: XP FÜR AMBULANCE/EMS
-- ========================================

-- In qb-ambulancejob/server/main.lua

-- XP für Wiederbeleben
RegisterNetEvent('hospital:server:RevivePlayer', function(playerId)
    local src = source
    -- Dein bestehender Code...
    
    exports['qb-xpsystem']:GiveXP(src, 40, "Spieler wiederbelebt")
end)

-- XP für Heilen
RegisterNetEvent('hospital:server:TreatWounds', function()
    local src = source
    -- Dein bestehender Code...
    
    exports['qb-xpsystem']:GiveXP(src, 20, "Wunden behandelt")
end)

-- ========================================
-- BEISPIEL 3: XP FÜR MECHANIKER
-- ========================================

-- In qb-mechanicjob/server/main.lua

-- XP für Reparaturen
RegisterNetEvent('mechanic:server:RepairVehicle', function()
    local src = source
    -- Dein bestehender Code...
    
    exports['qb-xpsystem']:GiveXP(src, 35, "Fahrzeug repariert")
end)

-- XP für Upgrades
RegisterNetEvent('mechanic:server:UpgradeVehicle', function(upgradeName)
    local src = source
    -- Dein bestehender Code...
    
    local xpRewards = {
        engine = 50,
        transmission = 45,
        turbo = 60,
        brakes = 40
    }
    
    local xpAmount = xpRewards[upgradeName] or 35
    exports['qb-xpsystem']:GiveXP(src, xpAmount, "Fahrzeug aufgewertet: " .. upgradeName)
end)

-- ========================================
-- BEISPIEL 4: XP FÜR AKTIVITÄTEN
-- ========================================

-- Für ein Fishing-Script
RegisterNetEvent('fishing:server:CatchFish', function(fishType)
    local src = source
    
    -- XP basierend auf Fischart
    local fishXP = {
        ['fish'] = 10,
        ['shark'] = 50,
        ['dolphin'] = 30,
        ['whale'] = 100
    }
    
    local xpAmount = fishXP[fishType] or 10
    exports['qb-xpsystem']:GiveXP(src, xpAmount, "Fisch gefangen: " .. fishType)
end)

-- Für ein Mining-Script
RegisterNetEvent('mining:server:MinedOre', function(oreType)
    local src = source
    
    local oreXP = {
        ['iron'] = 15,
        ['gold'] = 25,
        ['diamond'] = 50
    }
    
    local xpAmount = oreXP[oreType] or 10
    exports['qb-xpsystem']:GiveXP(src, xpAmount, "Erz abgebaut: " .. oreType)
end)

-- ========================================
-- BEISPIEL 5: LEVEL-BASIERTE FREISCHALTUNGEN
-- ========================================

-- In irgendeinem Script - Level prüfen vor Zugriff
RegisterNetEvent('yourscript:server:DoAction', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    -- Level des Spielers abrufen
    local playerLevel = exports['qb-xpsystem']:GetLevel(src)
    
    -- Mindest-Level 10 erforderlich
    if playerLevel < 10 then
        TriggerClientEvent('QBCore:Notify', src, 'Du benötigst Level 10 für diese Aktion!', 'error')
        return
    end
    
    -- Aktion erlauben
    -- ... dein Code hier ...
    TriggerClientEvent('QBCore:Notify', src, 'Aktion erfolgreich!', 'success')
end)

-- Level-basierte Shops
RegisterNetEvent('shop:server:BuyItem', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playerLevel = exports['qb-xpsystem']:GetLevel(src)
    
    -- Items mit Level-Anforderungen
    local levelRequirements = {
        ['weapon_pistol'] = 5,
        ['weapon_smg'] = 10,
        ['weapon_rifle'] = 25,
        ['weapon_sniper'] = 50
    }
    
    local requiredLevel = levelRequirements[itemName] or 1
    
    if playerLevel < requiredLevel then
        TriggerClientEvent('QBCore:Notify', src, 
            string.format('Du benötigst Level %d für dieses Item!', requiredLevel), 'error')
        return
    end
    
    -- Item kaufen...
    -- ... dein Code hier ...
end)

-- ========================================
-- BEISPIEL 6: ACHIEVEMENTS & MILESTONES
-- ========================================

-- Erste Job-Aktion
RegisterNetEvent('yourjob:server:FirstJobAction', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    -- Prüfe ob Spieler das schon gemacht hat (via Metadata)
    local firstJobDone = Player.PlayerData.metadata['first_job_done'] or false
    
    if not firstJobDone then
        -- Bonus XP für ersten Job
        exports['qb-xpsystem']:GiveXP(src, 100, "Erster Job abgeschlossen!")
        
        -- Metadata speichern
        Player.Functions.SetMetaData('first_job_done', true)
        TriggerClientEvent('QBCore:Notify', src, 'Achievement freigeschaltet: Erster Job! +100 XP', 'success')
    end
end)

-- Erstes Auto gekauft
RegisterNetEvent('qb-vehicleshop:server:buyVehicle', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    local firstCarBought = Player.PlayerData.metadata['first_car_bought'] or false
    
    if not firstCarBought then
        exports['qb-xpsystem']:GiveXP(src, 150, "Erstes Auto gekauft!")
        Player.Functions.SetMetaData('first_car_bought', true)
    end
    
    -- Normales XP fürs Auto kaufen
    exports['qb-xpsystem']:GiveXP(src, 25, "Auto gekauft")
end)

-- ========================================
-- BEISPIEL 7: EVENT-BASIERTE XP
-- ========================================

-- Bonus XP bei Events
RegisterNetEvent('event:server:JoinEvent', function()
    local src = source
    
    exports['qb-xpsystem']:GiveXP(src, 200, "Event beigetreten")
end)

-- XP für Event-Sieg
RegisterNetEvent('event:server:WinEvent', function()
    local src = source
    
    exports['qb-xpsystem']:GiveXP(src, 500, "Event gewonnen!")
    TriggerClientEvent('QBCore:Notify', src, 'Du hast das Event gewonnen! +500 XP', 'success')
end)

-- ========================================
-- BEISPIEL 8: ZEITBASIERTE XP (SPIELZEIT)
-- ========================================

-- In einem Timer-Thread (könnte in qb-core sein)
CreateThread(function()
    while true do
        Wait(300000) -- 5 Minuten
        
        -- Allen Online-Spielern XP geben
        local Players = QBCore.Functions.GetPlayers()
        for _, playerId in pairs(Players) do
            exports['qb-xpsystem']:GiveXP(playerId, 10, "5 Minuten Spielzeit")
        end
    end
end)

-- ========================================
-- BEISPIEL 9: LEVEL-UP EVENT NUTZEN
-- ========================================

-- In server/main.lua eines beliebigen Scripts
AddEventHandler('qb-xpsystem:server:playerLevelUp', function(source, oldLevel, newLevel)
    local Player = QBCore.Functions.GetPlayer(source)
    
    -- Glückwunsch-Nachricht
    TriggerClientEvent('QBCore:Notify', source, 
        string.format('Herzlichen Glückwunsch zu Level %d, %s!', newLevel, Player.PlayerData.charinfo.firstname),
        'success', 5000)
    
    -- Spezielle Belohnungen bei bestimmten Levels
    if newLevel == 50 then
        -- VIP-Status geben bei Level 50
        -- Player.Functions.AddMoney('bank', 50000)
        TriggerClientEvent('QBCore:Notify', source, 'Level 50 Bonus: $50,000 auf deinem Bankkonto!', 'success')
    end
    
    -- Discord-Ankündigung (zusätzlich zum eingebauten Log)
    -- TriggerEvent('custom:discord:announce', Player.PlayerData.name, newLevel)
end)

-- ========================================
-- BEISPIEL 10: XP-BOOSTER ITEMS
-- ========================================

-- Nutze ein Item als XP-Booster
QBCore.Functions.CreateUseableItem('xp_booster', function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    -- Gebe dem Spieler einen XP-Boost Buff (du müsstest das selbst implementieren)
    Player.Functions.SetMetaData('xp_boost', os.time() + 3600) -- 1 Stunde
    Player.Functions.RemoveItem('xp_booster', 1)
    
    TriggerClientEvent('QBCore:Notify', src, 'XP-Booster aktiviert! +50% XP für 1 Stunde', 'success')
end)

-- Dann beim XP geben:
local function GiveXPWithBoost(source, amount, reason)
    local Player = QBCore.Functions.GetPlayer(source)
    local xpBoostEnd = Player.PlayerData.metadata['xp_boost'] or 0
    
    -- Prüfe ob Boost aktiv
    if os.time() < xpBoostEnd then
        amount = math.floor(amount * 1.5) -- 50% Bonus
    end
    
    exports['qb-xpsystem']:GiveXP(source, amount, reason)
end

-- ========================================
-- BEISPIEL 11: XP LEADERBOARD
-- ========================================

-- Command für Top XP-Spieler
QBCore.Commands.Add('xptop', 'Zeige die Top 10 XP-Spieler', {}, false, function(source)
    local src = source
    
    -- MySQL Query für Top-Spieler
    MySQL.Async.fetchAll('SELECT citizenid, level, total_xp FROM player_xp ORDER BY total_xp DESC LIMIT 10', {}, function(result)
        if result then
            local message = '<strong>🏆 XP Leaderboard - Top 10</strong><br>━━━━━━━━━━━━━━━━<br>'
            
            for i, data in ipairs(result) do
                local Player = QBCore.Functions.GetPlayerByCitizenId(data.citizenid)
                local name = Player and Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname or 'Unbekannt'
                
                message = message .. string.format(
                    '%d. <strong>%s</strong> - Level %d (%s XP)<br>',
                    i, name, data.level, formatNumber(data.total_xp)
                )
            end
            
            -- Zeige in Chat oder als Notification
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 255, 0},
                multiline = true,
                args = {"XP System", message}
            })
        end
    end)
end)

-- ========================================
-- BEISPIEL 12: XP TRANSFERIEREN
-- ========================================

-- Erlaube Spielern XP zu verschenken (nur wenn beide online)
QBCore.Commands.Add('givexpplayer', 'Gebe einem Spieler XP', {
    {name = 'id', help = 'Spieler ID'},
    {name = 'amount', help = 'XP Menge'}
}, false, function(source, args)
    local src = source
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    
    if not targetId or not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Ungültige Eingabe', 'error')
        return
    end
    
    -- Hole XP Daten des Gebers
    local giverData = exports['qb-xpsystem']:GetPlayerXP(src)
    
    -- Prüfe ob Geber genug XP hat
    if giverData.xp < amount then
        TriggerClientEvent('QBCore:Notify', src, 'Du hast nicht genug XP!', 'error')
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Spieler nicht gefunden', 'error')
        return
    end
    
    -- Entferne XP vom Geber
    exports['qb-xpsystem']:RemoveXP(src, amount)
    
    -- Gebe XP an Empfänger
    exports['qb-xpsystem']:GiveXP(targetId, amount, "Von Spieler geschenkt")
    
    local Player = QBCore.Functions.GetPlayer(src)
    TriggerClientEvent('QBCore:Notify', src, string.format('Du hast %d XP an %s gegeben', amount, targetPlayer.PlayerData.name), 'success')
    TriggerClientEvent('QBCore:Notify', targetId, string.format('Du hast %d XP von %s erhalten!', amount, Player.PlayerData.name), 'success')
end)

-- ========================================
-- HINWEIS: FORMATIERUNG
-- ========================================

-- Hilfsfunktion zum Formatieren von Zahlen
function formatNumber(num)
    local formatted = tostring(num)
    local k
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- ========================================
-- ENDE DER BEISPIELE
-- ========================================
-- 
-- Weitere Ideen für Integration:
-- - XP für Crafting
-- - XP für Drug-Runs
-- - XP für Store-Überfälle
-- - XP für Racing
-- - XP für Trucking/Delivery
-- - XP für Gang-Aktivitäten
-- - Level-basierte Gehälter
-- - Level-Boni bei Jobs
-- - Prestige-System (Reset auf Level 1 mit Bonus)
-- 
-- Viel Erfolg bei der Integration! 🚀
-- ========================================
