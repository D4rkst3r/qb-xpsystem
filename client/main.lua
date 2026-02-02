local QBCore = exports['qb-core']:GetCoreObject()

-- ========================================
-- LOCAL VARIABLES
-- ========================================

local currentXPData = {
    level = 1,
    xp = 0,
    totalXP = 0
}

local isUIVisible = false

-- ========================================
-- UI MANAGEMENT
-- ========================================

--- Update UI with current XP data
local function UpdateUI()
    if not isUIVisible then return end
    
    local requiredXP = 0
    QBCore.Functions.TriggerCallback('qb-xpsystem:server:getRequiredXP', function(xp)
        requiredXP = xp
        
        local progress = (currentXPData.xp / requiredXP) * 100
        
        SendNUIMessage({
            action = 'updateXP',
            data = {
                level = currentXPData.level,
                currentXP = currentXPData.xp,
                requiredXP = requiredXP,
                progress = progress,
                totalXP = currentXPData.totalXP
            }
        })
    end, currentXPData.level)
end

--- Show XP UI
local function ShowUI()
    if isUIVisible then return end
    
    isUIVisible = true
    SendNUIMessage({
        action = 'show',
        mode = Config.UIMode,
        position = Config.UIPosition
    })
    
    UpdateUI()
end

--- Hide XP UI
local function HideUI()
    if not isUIVisible then return end
    
    isUIVisible = false
    SendNUIMessage({
        action = 'hide'
    })
end

-- ========================================
-- EVENT HANDLERS
-- ========================================

--- Update XP data from server
RegisterNetEvent('qb-xpsystem:client:updateXP', function(data)
    currentXPData = data
    UpdateUI()
end)

--- Handle level up
RegisterNetEvent('qb-xpsystem:client:levelUp', function(newLevel, levelsGained)
    -- Show notification
    if Config.ShowNotifications then
        local message = levelsGained > 1 and
            string.format('Glückwunsch! Du hast %d Level erreicht! Neues Level: %d', levelsGained, newLevel) or
            string.format('Level Up! Neues Level: %d', newLevel)
        
        QBCore.Functions.Notify(message, 'success', 5000)
    end
    
    -- Show level up animation
    SendNUIMessage({
        action = 'levelUp',
        data = {
            level = newLevel,
            levelsGained = levelsGained
        }
    })
    
    -- Play sound (optional)
    PlaySoundFrontend(-1, "RANK_UP", "HUD_AWARDS", true)
end)

--- Show stats popup
RegisterNetEvent('qb-xpsystem:client:showStats', function(message)
    SendNUIMessage({
        action = 'showStats',
        data = {
            message = message
        }
    })
end)

-- ========================================
-- KEYBIND (Optional)
-- ========================================

-- Toggle XP UI with a key (F6 by default)
RegisterCommand('+toggleXPUI', function()
    if isUIVisible then
        HideUI()
    else
        ShowUI()
    end
end, false)

RegisterCommand('-toggleXPUI', function() end, false)

RegisterKeyMapping('+toggleXPUI', 'Toggle XP UI', 'keyboard', 'F6')

-- ========================================
-- PLAYER SPAWN
-- ========================================

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000) -- Wait for everything to load
    ShowUI()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    HideUI()
end)

-- ========================================
-- RESOURCE START/STOP
-- ========================================

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    Wait(1000)
    if QBCore.Functions.GetPlayerData() and QBCore.Functions.GetPlayerData().citizenid then
        ShowUI()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    HideUI()
end)

-- ========================================
-- NUI CALLBACKS
-- ========================================

RegisterNUICallback('closeStats', function(data, cb)
    SendNUIMessage({
        action = 'closeStats'
    })
    cb('ok')
end)

-- ========================================
-- EXPORTS
-- ========================================

--- Get current XP data
---@return table
exports('GetXPData', function()
    return currentXPData
end)

--- Show UI programmatically
exports('ShowUI', function()
    ShowUI()
end)

--- Hide UI programmatically
exports('HideUI', function()
    HideUI()
end)

-- ========================================
-- CALLBACK REGISTRATION
-- ========================================

-- Register callback for getting required XP
QBCore.Functions.CreateCallback = QBCore.Functions.CreateCallback or function() end

CreateThread(function()
    Wait(1000)
    -- Callback is handled server-side
end)

print('^2[XP System]^7 Client initialized successfully')
