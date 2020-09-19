fx_version 'adamant'

game 'gta5'

description 'Fakeplates for ESX'

version '0.0.1'

client_scripts {
  '@es_extended/locale.lua',
  'locales/en.lua',
  'config.lua',
  'client/main.lua'
}

server_scripts {
  '@es_extended/locale.lua',
  'locales/en.lua',
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'server/main.lua'
}

dependencies {
  'es_extended',
  'mythic_progbar',
	'mythic_notify'
}
