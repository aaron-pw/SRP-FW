local density = Config.Density

-- Main density control thread
CreateThread(function()
    while true do
        -- Vehicle density
        SetVehicleDensityMultiplierThisFrame(density.vehicles.driving)
        SetRandomVehicleDensityMultiplierThisFrame(density.vehicles.ambient)
        
        -- Ped density
        SetPedDensityMultiplierThisFrame(density.peds.ambient)
        SetScenarioPedDensityMultiplierThisFrame(density.peds.scenario, density.peds.scenario)
        
        Wait(0)
    end
end)

-- Parked vehicle control thread
CreateThread(function()
    while true do
        -- Enable parked vehicle generation
        SetParkedVehicleDensityMultiplierThisFrame(density.vehicles.parked)
        
        -- Force game to create parked cars
        SetVehicleModelIsSuppressed(GetHashKey("rubble"), true)
        SetGarbageTrucks(false)
        SetCreateRandomCops(false)
        SetCreateRandomCopsNotOnScenarios(false)
        SetCreateRandomCopsOnScenarios(false)
        
        -- Enable all vehicle generators
        SetAllVehicleGeneratorsActive()
        SetAllLowPriorityVehicleGeneratorsActive(true)
        
        -- Extra parked vehicle settings
        SetFarDrawVehicles(true)
        
        Wait(0)
    end
end)

-- Extra world settings thread
CreateThread(function()
    -- Disable specific vehicle spawns
    SetRandomBoats(not density.extras.randomBoats)
    SetRandomTrains(not density.extras.randomTrains)
    
    while true do
        -- Traffic behavior settings
        SetPedAllowedToDuck(true, density.extras.ignorePlayers)
        SetPedPathsInArea(-9999.0, -9999.0, -9999.0, 9999.0, 9999.0, 9999.0, density.extras.ignorePlayers, 0)
        
        -- Vehicle behavior settings
        local vehicles = GetGamePool('CVehicle')
        for i = 1, #vehicles do
            local vehicle = vehicles[i]
            if DoesEntityExist(vehicle) then
                -- Set traffic behavior
                SetDriverAggressiveness(vehicle, density.extras.aggressive and 1.0 or 0.0)
                SetDriverAbility(vehicle, 1.0)
                
                -- Traffic light behavior
                if density.extras.ignoreLights then
                    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront", 0.9)
                end
            end
        end
        
        Wait(1000)
    end
end)

-- Random events control
CreateThread(function()
    for i = 1, 15 do
        EnableDispatchService(i, false)
    end
    
    while true do
        -- Disable random events
        CancelCurrentPoliceReport()
        DisablePlayerVehicleRewards(PlayerId())
        
        Wait(1000)
    end
end)

-- Cleanup when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    
    -- Reset density settings
    SetParkedVehicleDensityMultiplierThisFrame(1.0)
    SetVehicleDensityMultiplierThisFrame(1.0)
    SetRandomVehicleDensityMultiplierThisFrame(1.0)
    SetPedDensityMultiplierThisFrame(1.0)
    SetScenarioPedDensityMultiplierThisFrame(1.0, 1.0)
    
    -- Reset extra settings
    SetRandomBoats(true)
    SetRandomTrains(true)
    SetAllVehicleGeneratorsActive()
    SetAllLowPriorityVehicleGeneratorsActive(true)
    SetGarbageTrucks(true)
end)
