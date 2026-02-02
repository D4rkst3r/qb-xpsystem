fx_version 'cerulean'
game 'gta5'

author 'XP System Team'
description 'Modern QBCore XP System with ACE Permissions'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/admin_menu.lua',
    'client/player_menu.lua',
    'client/style_system.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/commands.lua',
    'server/discord.lua',
    'server/admin_menu.lua',
    'server/player_menu.lua',
    'server/style_system.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/styles_multi.css',
    'html/app.js'
}

lua54 'yes'
