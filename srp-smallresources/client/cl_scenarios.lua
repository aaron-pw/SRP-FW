-- Local Variables
local DisabledZones = Config.Scenarios.DisabledZones
local GloballyDisabled = Config.Scenarios.GloballyDisabled

-- Function to disable scenarios in a specific area
local function DisableScenariosInArea(coords, radius, types)
    local position = coords
    for _, scenarioType in ipairs(types) do
        SetScenarioTypeEnabled(scenarioType, false)
        RemoveScenarioBlockingArea(GetScenarioBlockingAreaFromCoords(position, radius), true)
    end
end

-- Function to disable scenarios globally
local function DisableGlobalScenarios()
    for _, scenarioType in ipairs(GloballyDisabled) do
        SetScenarioTypeEnabled(scenarioType, false)
    end
end

-- Initialize scenario blocking
CreateThread(function()
    -- First disable global scenarios
    DisableGlobalScenarios()
    
    -- Then handle specific zones
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for _, zone in ipairs(DisabledZones) do
            local distance = #(playerCoords - zone.coords)
            
            if distance < zone.radius then
                DisableScenariosInArea(zone.coords, zone.radius, zone.types)
            end
        end
        
        -- Only check every second since this doesn't need to be checked every frame
        Wait(1000)
    end
end)

-- Disable emergency service dispatch and wanted levels
CreateThread(function()
    while true do
        -- Disable emergency service dispatching
        for i = 1, 15 do
            EnableDispatchService(i, false)
        end
        
        -- Disable police vehicle spawns
        SetCreateRandomCops(false)
        SetCreateRandomCopsNotOnScenarios(false)
        SetCreateRandomCopsOnScenarios(false)
        
        -- Disable wanted levels
        if GetPlayerWantedLevel(PlayerId()) > 0 then
            SetPlayerWantedLevel(PlayerId(), 0, false)
            SetPlayerWantedLevelNow(PlayerId(), false)
            SetDispatchCopsForPlayer(PlayerId(), false)
        end
        
        -- Only needs to be checked occasionally
        Wait(500)
    end
end)

-- Additional police response disabling
CreateThread(function()
    while true do
        -- Disable police response
        SetPoliceIgnorePlayer(PlayerId(), true)
        SetDispatchCopsForPlayer(PlayerId(), false)
        SetMaxWantedLevel(0)
        
        -- Disable law enforcement vehicles in the area
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        ClearAreaOfCops(playerCoords.x, playerCoords.y, playerCoords.z, 400.0)
        
        Wait(1000)
    end
end)

-- Cleanup when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    
    -- Re-enable scenarios when resource stops
    for _, scenarioType in ipairs(GloballyDisabled) do
        SetScenarioTypeEnabled(scenarioType, true)
    end
    
    for _, zone in ipairs(DisabledZones) do
        for _, scenarioType in ipairs(zone.types) do
            SetScenarioTypeEnabled(scenarioType, true)
        end
    end
    
    -- Reset police response settings
    SetPoliceIgnorePlayer(PlayerId(), false)
    SetDispatchCopsForPlayer(PlayerId(), true)
    SetMaxWantedLevel(5)
end)