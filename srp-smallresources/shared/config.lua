Config = {}

Config.Scenarios = {
    -- Areas to disable scenarios (police, ambulance, etc)
    DisabledZones = {
        -- Mission Row Police Department
        {
            coords = vector3(441.2, -982.5, 30.69),
            radius = 50.0,
            types = {'WORLD_VEHICLE_POLICE_NEXT_TO_CAR', 'WORLD_VEHICLE_AMBULANCE', 'WORLD_VEHICLE_POLICE_CAR'}
        },
        -- Pillbox Hospital
        {
            coords = vector3(304.27, -600.33, 43.28),
            radius = 50.0,
            types = {'WORLD_VEHICLE_AMBULANCE', 'WORLD_VEHICLE_POLICE_CAR'}
        }
    },

    -- Global scenario types to disable everywhere
    GloballyDisabled = {
        'WORLD_VEHICLE_POLICE_BIKE',
        'WORLD_VEHICLE_POLICE_CAR',
        'WORLD_VEHICLE_POLICE_NEXT_TO_CAR',
        'WORLD_VEHICLE_AMBULANCE',
        'WORLD_VEHICLE_FIRE_TRUCK',
        'WORLD_VEHICLE_MILITARY_PLANES_BIG',
        'WORLD_VEHICLE_MILITARY_PLANES_SMALL',
    }
}

Config.Density = {
    -- Vehicle density settings (0.0 to 1.0)
    vehicles = {
        parked = 0.7,    -- Parked vehicle density
        driving = 0.5,    -- Driving vehicle density
        ambient = 0.5     -- Random ambient vehicle spawns
    },

    -- Pedestrian density settings (0.0 to 1.0)
    peds = {
        scenario = 0.3,    -- Scenario ped density
        ambient = 0.4      -- Random ambient ped spawns
    },

    -- Extra world settings
    extras = {
        garbageTrucks = false,      -- Disable garbage trucks
        randomTrains = false,       -- Disable random trains
        randomBoats = false,        -- Disable random boats
        randomPlanes = false,       -- Disable random planes
        
        -- Traffic behavior
        ignoreLights = false,       -- NPCs ignore traffic lights
        ignorePlayers = true,       -- NPCs ignore players
        aggressive = false          -- Aggressive drivers
    }
}