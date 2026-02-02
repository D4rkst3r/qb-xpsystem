-- ========================================
-- WICHTIG: DISCORD WEBHOOK TEST
-- ========================================
-- 
-- Ersetze in deiner config.lua Zeile 52 mit:

Config.DiscordWebhook = 'https://discord.com/api/webhooks/1467991292087894149/ApYeQh2-ivn4BcILGI-CxKEKX3H-gmxNmrM2Q-FhVTYfJp615iEB2OTYULMOZuQVybgn'

-- Stelle sicher, dass diese Einstellungen aktiv sind:
Config.DiscordLogs = {
    enabled = true,  -- MUSS TRUE SEIN!
    
    colors = {
        levelUp = 3066993,
        adminAction = 15158332,
        suspicious = 16776960
    },
    
    botName = 'XP System',
    botAvatar = 'https://i.imgur.com/4M34hi2.png'
}

-- ========================================
-- WEBHOOK TESTEN
-- ========================================
-- 
-- Nach dem Restart:
-- 1. /givexp [deine_id] 5000  → Sollte Level-Up Discord-Log senden
-- 2. /setlevel [andere_id] 10 → Sollte Admin-Action Discord-Log senden
-- 
-- ========================================
