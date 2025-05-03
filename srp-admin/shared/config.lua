Config = {}

Config.AdminMenu = {
    -- Menu categories and their required permissions
    categories = {
        ['Player Management'] = {
            permission = 'admin.players',
            options = {
                {label = 'Teleport to Player', permission = 'admin.teleport'},
                {label = 'Bring Player', permission = 'admin.bring'},
                {label = 'Heal Player', permission = 'admin.heal'},
                {label = 'Revive Player', permission = 'admin.revive'},
                {label = 'Kick Player', permission = 'admin.kick'},
                {label = 'Ban Player', permission = 'admin.ban'}
            }
        },
        ['Server Management'] = {
            permission = 'admin.server',
            options = {
                {label = 'Announce Message', permission = 'admin.announce'},
                {label = 'Clear Area', permission = 'admin.cleararea'},
                {label = 'Weather Control', permission = 'admin.weather'}
            }
        },
        ['Developer Tools'] = {
            permission = 'admin.dev',
            options = {
                {label = 'Toggle NoClip', permission = 'admin.noclip'},
                {label = 'Toggle Debug', permission = 'admin.debug'},
                {label = 'Vehicle Dev Tools', permission = 'admin.devtools'}
            }
        }
    }
}