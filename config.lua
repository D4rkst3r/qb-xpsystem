Config = {}

-- ========================================
-- XP SYSTEM CONFIGURATION
-- ========================================

-- Base XP required for level 1
Config.BaseXP = 100

-- Multiplier for XP curve (Level * Multiplier)
Config.LevelMultiplier = 1.5

-- Maximum level (0 = unlimited)
Config.MaxLevel = 100

-- Starting level for new players
Config.StartingLevel = 1

-- ========================================
-- UI CONFIGURATION
-- ========================================

-- UI Mode: 'circular' or 'rectangular'
Config.UIMode = 'circular'

-- UI Position (for circular mode)
Config.UIPosition = {
    x = 95, -- Percentage from left
    y = 85  -- Percentage from top
}

-- Show XP notifications
Config.ShowNotifications = true

-- ========================================
-- ANTI-EXPLOIT CONFIGURATION
-- ========================================

-- Cooldown between XP events per player (in milliseconds)
Config.XPCooldown = 1000 -- 1 second

-- Maximum XP that can be given at once (anti-cheat)
Config.MaxXPPerEvent = 1000

-- Log suspicious XP activity
Config.LogSuspiciousActivity = true

-- ========================================
-- DISCORD WEBHOOK LOGGING
-- ========================================

Config.DiscordWebhook =
'https://discord.com/api/webhooks/1467991292087894149/ApYeQh2-ivn4BcILGI-CxKEKX3H-gmxNmrM2Q-FhVTYfJp615iEB2OTYULMOZuQVybgn'                         -- Add your webhook URL here

Config.DiscordLogs = {
    enabled = true,

    -- Log colors
    colors = {
        levelUp = 3066993,      -- Green
        adminAction = 15158332, -- Red
        suspicious = 16776960   -- Yellow
    },

    -- Bot name and avatar
    botName = 'XP System',
    botAvatar = 'https://i.imgur.com/4M34hi2.png'
}

-- ========================================
-- LEVEL REWARDS SYSTEM
-- ========================================

Config.LevelRewards = {
    enabled = true,

    rewards = {
        -- Level 5 Reward
        [5] = {
            money = 5000,
            items = {
                { name = 'phone', amount = 1 }
            },
            message = 'Glückwunsch zu Level 5! Du hast €5,000 und ein Telefon erhalten!'
        },

        -- Level 10 Reward
        [10] = {
            money = 10000,
            items = {
                { name = 'weapon_pistol', amount = 1 },
                { name = 'pistol_ammo',   amount = 50 }
            },
            message = 'Level 10 erreicht! Du hast €10,000 und eine Pistole erhalten!'
        },

        -- Level 25 Reward
        [25] = {
            money = 25000,
            items = {
                { name = 'advancedlockpick', amount = 5 }
            },
            message = 'Wow, Level 25! €25,000 und erweiterte Werkzeuge für dich!'
        },

        -- Level 50 Reward
        [50] = {
            money = 50000,
            items = {
                { name = 'weapon_assaultrifle', amount = 1 },
                { name = 'rifle_ammo',          amount = 100 }
            },
            message = 'LEVEL 50! Du bist ein Veteran! €50,000 und ein Sturmgewehr!'
        },

        -- Level 100 Reward
        [100] = {
            money = 100000,
            items = {
                { name = 'weapon_rpg', amount = 1 },
                { name = 'rpg_ammo',   amount = 10 }
            },
            message = '🎉 MAXIMALES LEVEL! €100,000 und eine spezielle Überraschung!'
        }
    }
}

-- ========================================
-- DATABASE CONFIGURATION
-- ========================================

Config.Database = {
    tableName = 'player_xp',
    autoCreate = true -- Automatically create table if it doesn't exist
}

-- ========================================
-- COMMAND PERMISSIONS
-- ========================================

-- ACE Permission required for admin commands
Config.AdminPermission = 'command.xpadmin'

-- Commands configuration
Config.Commands = {
    giveXP = {
        name = 'givexp',
        help = 'Gibt einem Spieler XP',
        params = {
            { name = 'id',     help = 'Spieler ID' },
            { name = 'amount', help = 'XP Menge' }
        }
    },

    setLevel = {
        name = 'setlevel',
        help = 'Setzt das Level eines Spielers',
        params = {
            { name = 'id',    help = 'Spieler ID' },
            { name = 'level', help = 'Neues Level' }
        }
    },

    resetXP = {
        name = 'resetxp',
        help = 'Setzt XP und Level eines Spielers zurück',
        params = {
            { name = 'id', help = 'Spieler ID' }
        }
    },

    checkStats = {
        name = 'checkstats',
        help = 'Zeigt die Stats eines Spielers an',
        params = {
            { name = 'id', help = 'Spieler ID (optional)' }
        }
    }
}

-- ========================================
-- XP SOURCES (Examples for integration)
-- ========================================

Config.XPSources = {
    -- Job XP
    jobs = {
        ['police'] = {
            arrest = 50,
            ticket = 25,
            evidence = 30
        },
        ['ambulance'] = {
            revive = 40,
            heal = 20
        },
        ['mechanic'] = {
            repair = 35,
            upgrade = 45
        }
    },

    -- Activity XP
    activities = {
        fishing = 15,
        mining = 20,
        hunting = 25,
        crafting = 30
    },

    -- Achievement XP
    achievements = {
        firstJob = 100,
        firstCar = 150,
        firstHouse = 200
    }
}
