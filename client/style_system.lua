-- ========================================
-- XP SYSTEM - STYLE SYSTEM
-- ========================================

local QBCore = exports['qb-core']:GetCoreObject()

-- Current style (saved per player)
local currentStyle = 1
local currentSize = 'medium'
local currentPosition = 'bottom-right'

-- ========================================
-- STYLE DEFINITIONS
-- ========================================

local Styles = {
    {
        id = 1,
        name = 'Modern',
        description = 'Gradient Circle Design',
        icon = '🌟',
        class = 'style-modern'
    },
    {
        id = 2,
        name = 'Minimal',
        description = 'Clean & Small',
        icon = '⚪',
        class = 'style-minimal'
    },
    {
        id = 3,
        name = 'Gamer',
        description = 'Gaming Aesthetic',
        icon = '🎮',
        class = 'style-gamer'
    },
    {
        id = 4,
        name = 'Glass',
        description = 'Glassmorphism',
        icon = '💎',
        class = 'style-glass'
    },
    {
        id = 5,
        name = 'Neon',
        description = 'Cyberpunk Neon',
        icon = '⚡',
        class = 'style-neon'
    },
    {
        id = 6,
        name = 'Retro',
        description = '8-Bit Pixel',
        icon = '👾',
        class = 'style-retro'
    },
    {
        id = 7,
        name = 'Elegant',
        description = 'Luxury Gold',
        icon = '👑',
        class = 'style-elegant'
    },
    {
        id = 8,
        name = 'Compact',
        description = 'Ultra Small',
        icon = '📦',
        class = 'style-compact'
    },
    {
        id = 9,
        name = 'Animated',
        description = 'Pulsing Effects',
        icon = '✨',
        class = 'style-animated'
    },
    {
        id = 10,
        name = 'RGB',
        description = 'Rainbow Colors',
        icon = '🌈',
        class = 'style-rgb'
    }
}

-- ========================================
-- LOAD/SAVE PREFERENCES
-- ========================================

local function LoadStylePreferences()
    lib.callback('qb-xpsystem:server:getStylePreferences', false, function(prefs)
        if prefs then
            currentStyle = prefs.style or 1
            currentSize = prefs.size or 'medium'
            currentPosition = prefs.position or 'bottom-right'
            
            -- Apply style
            ApplyStyle(currentStyle, currentSize, currentPosition)
        end
    end)
end

local function SaveStylePreferences()
    TriggerServerEvent('qb-xpsystem:server:saveStylePreferences', {
        style = currentStyle,
        size = currentSize,
        position = currentPosition
    })
end

-- ========================================
-- APPLY STYLE
-- ========================================

function ApplyStyle(styleId, size, position)
    currentStyle = styleId
    currentSize = size or currentSize
    currentPosition = position or currentPosition
    
    local style = Styles[styleId]
    if not style then return end
    
    SendNUIMessage({
        action = 'changeStyle',
        style = style.class,
        size = currentSize,
        position = currentPosition
    })
    
    lib.notify({
        title = 'XP UI Style',
        description = style.icon .. ' ' .. style.name .. ' aktiviert!',
        type = 'success',
        duration = 2000
    })
    
    SaveStylePreferences()
end

-- ========================================
-- CYCLE THROUGH STYLES
-- ========================================

local function CycleStyle()
    currentStyle = currentStyle + 1
    if currentStyle > #Styles then
        currentStyle = 1
    end
    
    ApplyStyle(currentStyle)
end

-- ========================================
-- STYLE MENU
-- ========================================

local function OpenStyleMenu()
    local options = {}
    
    for _, style in ipairs(Styles) do
        local isActive = style.id == currentStyle
        
        table.insert(options, {
            title = style.icon .. ' ' .. style.name,
            description = style.description .. (isActive and ' ✓' or ''),
            icon = isActive and 'check-circle' or 'circle',
            iconColor = isActive and '#10B981' or '#6B7280',
            onSelect = function()
                ApplyStyle(style.id)
                Wait(500)
                OpenStyleMenu() -- Reopen to show checkmark
            end
        })
    end
    
    lib.registerContext({
        id = 'xp_style_menu',
        title = '🎨 XP UI Styles',
        menu = 'xp_settings_menu',
        options = options
    })
    
    lib.showContext('xp_style_menu')
end

-- ========================================
-- SIZE MENU
-- ========================================

local function OpenSizeMenu()
    local sizes = {
        {value = 'small', label = 'Klein', icon = '📦'},
        {value = 'medium', label = 'Mittel', icon = '📊'},
        {value = 'large', label = 'Groß', icon = '📈'}
    }
    
    local options = {}
    
    for _, size in ipairs(sizes) do
        local isActive = size.value == currentSize
        
        table.insert(options, {
            title = size.icon .. ' ' .. size.label,
            icon = isActive and 'check-circle' or 'circle',
            iconColor = isActive and '#10B981' or '#6B7280',
            onSelect = function()
                ApplyStyle(currentStyle, size.value)
                Wait(500)
                OpenSizeMenu()
            end
        })
    end
    
    lib.registerContext({
        id = 'xp_size_menu',
        title = '📏 UI Größe',
        menu = 'xp_settings_menu',
        options = options
    })
    
    lib.showContext('xp_size_menu')
end

-- ========================================
-- POSITION MENU
-- ========================================

local function OpenPositionMenu()
    local positions = {
        {value = 'top-left', label = 'Oben Links', icon = '↖️'},
        {value = 'top-right', label = 'Oben Rechts', icon = '↗️'},
        {value = 'bottom-left', label = 'Unten Links', icon = '↙️'},
        {value = 'bottom-right', label = 'Unten Rechts', icon = '↘️'},
        {value = 'center', label = 'Mitte', icon = '⊙'}
    }
    
    local options = {}
    
    for _, pos in ipairs(positions) do
        local isActive = pos.value == currentPosition
        
        table.insert(options, {
            title = pos.icon .. ' ' .. pos.label,
            icon = isActive and 'check-circle' or 'circle',
            iconColor = isActive and '#10B981' or '#6B7280',
            onSelect = function()
                ApplyStyle(currentStyle, currentSize, pos.value)
                Wait(500)
                OpenPositionMenu()
            end
        })
    end
    
    lib.registerContext({
        id = 'xp_position_menu',
        title = '📍 UI Position',
        menu = 'xp_settings_menu',
        options = options
    })
    
    lib.showContext('xp_position_menu')
end

-- ========================================
-- MAIN SETTINGS MENU
-- ========================================

local function OpenSettingsMenu()
    local currentStyleData = Styles[currentStyle]
    
    lib.registerContext({
        id = 'xp_settings_menu',
        title = '⚙️ XP UI Einstellungen',
        menu = 'xp_player_main',
        options = {
            {
                title = '🎨 UI Style',
                description = 'Aktuell: ' .. currentStyleData.icon .. ' ' .. currentStyleData.name,
                icon = 'palette',
                iconColor = '#8B5CF6',
                onSelect = function()
                    OpenStyleMenu()
                end
            },
            {
                title = '📏 Größe',
                description = 'Aktuell: ' .. string.upper(string.sub(currentSize, 1, 1)) .. string.sub(currentSize, 2),
                icon = 'expand',
                iconColor = '#3B82F6',
                onSelect = function()
                    OpenSizeMenu()
                end
            },
            {
                title = '📍 Position',
                description = 'Aktuell: ' .. currentPosition,
                icon = 'map-pin',
                iconColor = '#F59E0B',
                onSelect = function()
                    OpenPositionMenu()
                end
            },
            {
                title = '🔄 Stil durchschalten',
                description = 'Keybind: ALT + X',
                icon = 'sync',
                iconColor = '#10B981',
                onSelect = function()
                    CycleStyle()
                end
            },
            {
                title = '👁️ UI Anzeigen/Verstecken',
                description = 'Keybind: F6',
                icon = 'eye',
                iconColor = '#6B7280',
                readOnly = true
            }
        }
    })
    
    lib.showContext('xp_settings_menu')
end

-- ========================================
-- COMMANDS & KEYBINDS
-- ========================================

-- Cycle through styles
RegisterCommand('+cycleXPStyle', function()
    CycleStyle()
end, false)

RegisterCommand('-cycleXPStyle', function() end, false)

RegisterKeyMapping('+cycleXPStyle', 'XP UI Style wechseln', 'keyboard', 'LMENU-X') -- ALT + X

-- Open settings
RegisterCommand('xpstyle', function()
    OpenSettingsMenu()
end, false)

-- ========================================
-- EXPORTS
-- ========================================

exports('GetCurrentStyle', function()
    return currentStyle
end)

exports('SetStyle', function(styleId)
    ApplyStyle(styleId)
end)

exports('OpenStyleSettings', function()
    OpenSettingsMenu()
end)

-- Export for player menu
OpenXPSettings = OpenSettingsMenu

-- ========================================
-- INITIALIZE
-- ========================================

CreateThread(function()
    Wait(2000)
    LoadStylePreferences()
end)

print('^2[XP System]^7 Style system initialized with ' .. #Styles .. ' styles')
