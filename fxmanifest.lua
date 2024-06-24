fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

author 'Phil'
description 'Player Blips'
version '1.0'

shared_scripts {
    'shared/config.lua', -- Make sure this path is correct relative to your fxmanifest.lua
    '@rsg-core/shared/jobs.lua', -- Adjust according to your resource naming and structure
    '@rsg-core/shared/gangs.lua' -- Adjust according to your resource naming and structure
}

client_scripts {
    'client/utils.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- Adjust this path if necessary, ensure it's correctly included
    'server/main.lua'
}
