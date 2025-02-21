fx_version "cerulean"
game "gta5"
author "Pickle Mods"
version "v1.1.1"

ui_page "nui/index.html"

data_file 'DLC_ITYP_REQUEST' 'stream/mrc_human_torso.ytyp'

files {
	"nui/index.html",
	"nui/assets/**/*.*",
}

shared_scripts {
	"@ox_lib/init.lua",
	"config.lua",
	"locales/locale.lua",
    "locales/translations/*.lua",
	"modules/**/shared.lua",
    "core/shared.lua"
}

client_scripts {
	"bridge/**/**/client.lua",
	"modules/**/client.lua",
	"surgeries/**/client.lua",
    "core/client.lua"
}

server_scripts {
	"bridge/**/**/server.lua",
	"modules/**/server.lua",
}

lua54 'yes'

escrow_ignore {
	"config.lua",
	"_INSTALL/**/*.*",
	"bridge/**/**/*.*",
	"bridge/**/*.*",
    "locales/locale.lua",
    "locales/translations/*.lua",
	"surgeries/**/*.*",
}