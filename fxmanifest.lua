fx_version "adamant"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

client_scripts {
	"@uiprompt/uiprompt.lua",
	"client/client.lua",
	"client/utils.lua",
    'client/balloonanimations.lua',
}

shared_scripts {
	'translation/translation.lua',
	'config.lua'
}

server_scripts {
	'server/server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css'
}

dependencies {
	'vorp_core',
	'vorp_utils'
}

lua54 'yes'

author 'alicain'
version '1.0.0'
