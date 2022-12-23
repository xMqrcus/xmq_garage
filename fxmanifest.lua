fx_version 'cerulean'
game 'gta5'

dependency "vrp"

ui_page "html/index.html"

files {
  "html/index.html",
  "html/css/style.css",
  "html/js/javascript.js"
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  "@vrp/lib/utils.lua",
  "server.lua"
}

client_scripts { 
  "lib/Proxy.lua",
  "lib/Tunnel.lua",
  "garages.lua",
  "client.lua"
}