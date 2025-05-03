Config = {}

Config.DefaultSpawns = {
    {
        name = "Legion Square",
        coords = vector4(195.17, -933.77, 29.7, 144.5),
        icon = "🌆",
        description = "The heart of Los Santos"
    },
    {
        name = "Sandy Shores",
        coords = vector4(1851.41, 3683.45, 33.27, 212.31),
        icon = "🏜️",
        description = "A desert community"
    },
    {
        name = "Paleto Bay",
        coords = vector4(-125.47, 6204.05, 31.18, 315.00),
        icon = "🏖️",
        description = "A coastal town up north"
    },
    {
        name = "Grapeseed",
        coords = vector4(1662.19, 4776.16, 41.07, 93.26),
        icon = "🌾",
        description = "A farming community"
    }
}

-- Distance threshold for "Last Location" spawn option (in meters)
Config.LastLocationThreshold = 100.0

-- Camera settings for spawn selection
Config.SpawnCam = {
    defaultFov = 50.0,
    defaultHeight = 200.0,
    transitionTime = 1000
} 