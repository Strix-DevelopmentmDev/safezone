fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Strix'
description 'Safezone Creator'
version '1.0.0'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js',
    'zones.json'
}

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'