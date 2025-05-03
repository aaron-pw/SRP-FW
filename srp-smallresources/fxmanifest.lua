fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'srp-smallresources'
description 'Small utilities and features for SRP Framework'
author 'aaron-pw'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}
