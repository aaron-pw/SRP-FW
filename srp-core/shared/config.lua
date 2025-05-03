Config = {}

-- Permissions Configuration
Config.Permissions = {
    Groups = {
        ['admin'] = {
            label = 'Administrator',
            inherits = 'moderator',
            permissions = {
                'admin.teleport',
                'admin.noclip',
                'admin.heal',
                'admin.revive',
                'admin.kick',
                'admin.ban',
                'admin.bring',
                'admin.goto',
                'admin.players',
                'admin.server',
                'admin.dev',
                'admin.announce',
                'admin.cleararea',
                'admin.weather',
                'admin.devtools',
                'admin.debug',
                'admin.spawnvehicle'
            }
        },
        ['moderator'] = {
            label = 'Moderator',
            inherits = 'user',
            permissions = {
                'mod.teleport',
                'mod.noclip',
                'mod.heal',
                'mod.revive'
            }
        },
        ['user'] = {
            label = 'User',
            permissions = {}
        }
    },
    
    -- User assignments (by license)
    Users = {
        ["license:31765fd3d6bc9de5bf1c4fbd507c0dfedd24de4c"] = "admin",     -- Aaron admin
        ["license:0987654321"] = "moderator", -- Example moderator
    },
    
    -- Default group for new players
    DefaultGroup = 'user'
}

-- Debug Mode
Config.Debug = true

-- Other core-specific configurations can go here
Config.SaveInterval = 5 * 60 * 1000 -- Save player data every 5 minutes

-- Queue Configuration
Config.Queue = {
    -- Priority levels for different groups
    PriorityGroups = {
        ['admin'] = 100,
        ['moderator'] = 50,
        ['premium'] = 25,
        ['user'] = 0
    },
    
    -- Time in seconds before queue timeout
    Timeout = 300, -- 5 minutes
    
    -- Queue update interval in ms
    UpdateInterval = 5000
}