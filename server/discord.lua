-- ========================================
-- DISCORD WEBHOOK LOGGING
-- ========================================

local QBCore = exports['qb-core']:GetCoreObject()

-- Queue system to prevent blocking
local logQueue = {}
local isProcessing = false

--- Format number with commas
---@param number number
---@return string
local function formatNumber(number)
    local formatted = tostring(number)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

--- Get player identifiers for logging (formatted)
---@param source number
---@return table
local function GetFormattedIdentifiers(source)
    local identifiers = {
        steam = 'N/A',
        license = 'N/A',
        discord = 'N/A',
        ip = 'N/A'
    }

    -- Use native FiveM function explicitly
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if string.find(identifier, "steam:") then
            identifiers.steam = identifier
        elseif string.find(identifier, "license:") then
            identifiers.license = identifier
        elseif string.find(identifier, "discord:") then
            identifiers.discord = "<@" .. string.gsub(identifier, "discord:", "") .. ">"
        elseif string.find(identifier, "ip:") then
            identifiers.ip = identifier
        end
    end

    return identifiers
end

--- Send Discord webhook (queued and async)
---@param embed table
local function SendToDiscord(embed)
    if not Config.DiscordLogs.enabled or not Config.DiscordWebhook or Config.DiscordWebhook == '' then
        return
    end

    -- Add to queue
    table.insert(logQueue, embed)

    -- Process queue if not already processing
    if not isProcessing then
        isProcessing = true

        CreateThread(function()
            while #logQueue > 0 do
                local currentEmbed = table.remove(logQueue, 1)

                PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers)
                    -- Silent processing
                end, 'POST', json.encode({
                    username = Config.DiscordLogs.botName or 'XP System',
                    avatar_url = Config.DiscordLogs.botAvatar or '',
                    embeds = { currentEmbed }
                }), { ['Content-Type'] = 'application/json' })

                -- Small delay between requests
                Wait(100)
            end

            isProcessing = false
        end)
    end
end

--- Create embed object
---@param title string
---@param description string
---@param color number
---@param fields table
---@return table
local function CreateEmbed(title, description, color, fields)
    return {
        ["title"] = title,
        ["description"] = description,
        ["color"] = color,
        ["fields"] = fields or {},
        ["footer"] = {
            ["text"] = "XP System • " .. os.date("%d.%m.%Y %H:%M:%S"),
        },
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
    }
end

-- ========================================
-- LOG LEVEL UP
-- ========================================
AddEventHandler('qb-xpsystem:server:logLevelUp', function(source, oldLevel, newLevel)
    local ids = GetFormattedIdentifiers(source)
    local playerName = GetPlayerName(source)

    local description = string.format("Der Spieler **%s** ist im Level aufgestiegen!", playerName)
    local fields = {
        { name = "Altes Level", value = tostring(oldLevel), inline = true },
        { name = "Neues Level", value = tostring(newLevel), inline = true },
        { name = "Discord",     value = ids.discord,        inline = false }
    }

    local embed = CreateEmbed("🆙 Level Up", description, 3066993, fields) -- Grün
    SendToDiscord(embed)

    print(string.format('^2[XP System]^7 %s leveled up from %d to %d', playerName, oldLevel, newLevel))
end)

-- ========================================
-- LOG ADMIN ACTIONS
-- ========================================
AddEventHandler('qb-xpsystem:server:logAdminAction', function(adminSource, targetSource, action, data)
    local adminName = GetPlayerName(adminSource)
    local targetName = GetPlayerName(targetSource)

    local description = string.format("Ein Admin hat das Level/XP eines Spielers geändert.")
    local fields = {
        { name = "Admin",      value = adminName,      inline = true },
        { name = "Zielperson", value = targetName,     inline = true },
        { name = "Aktion",     value = action,         inline = false },
        { name = "Details",    value = tostring(data), inline = false }
    }

    local embed = CreateEmbed("🛠️ Admin Aktion", description, 15105570, fields) -- Orange
    SendToDiscord(embed)

    print(string.format('^3[XP System Admin]^7 %s performed %s on %s', adminName, action, targetName))
end)

-- ========================================
-- LOG SUSPICIOUS ACTIVITY
-- ========================================
AddEventHandler('qb-xpsystem:server:logSuspicious', function(source, amount, reason)
    local ids = GetFormattedIdentifiers(source)

    local description = "⚠️ **Verdächtige XP-Aktivität erkannt!**"
    local fields = {
        { name = "Spieler",    value = GetPlayerName(source),      inline = true },
        { name = "Grund",      value = reason,                     inline = true },
        { name = "Menge",      value = formatNumber(amount),       inline = false },
        { name = "Identifier", value = "License: " .. ids.license, inline = false }
    }

    local embed = CreateEmbed("🚨 Warnung", description, 15158332, fields) -- Rot
    SendToDiscord(embed)

    print(string.format('^1[XP System SUSPICIOUS]^7 %s - %s - Amount: %d', GetPlayerName(source), reason, amount))
end)
