fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'srp-admin'
description 'Admin system for SRP Framework'
author 'aaronpw'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

dependencies {
    'ox_lib',
    'srp-core'
}