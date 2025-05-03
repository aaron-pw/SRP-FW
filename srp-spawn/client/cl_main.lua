-- Import camera config from srp-characters
local CameraConfig = exports['srp-characters']:GetCameraConfig()
local spawnCam = nil

-- Function to cleanup spawn camera
local function CleanupSpawnCamera()
    if DoesCamExist(spawnCam) then
        DestroyCam(spawnCam, true)
        RenderScriptCams(false, true, 1000, true, true)
        spawnCam = nil
    end
    
    -- Clear timecycle modifier
    ClearTimecycleModifier()
end

-- Handle spawn selection
local function HandleSpawn(coords)
    if not coords then return end
    
    -- Start screen fade out
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    
    -- Clean up camera
    CleanupSpawnCamera()
    
    -- Teleport player
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, coords.w)
    
    -- Wait for collision to load
    while not HasCollisionLoadedAroundEntity(ped) do
        Wait(0)
    end
    
    -- Ensure player is visible
    SetEntityVisible(ped, true, false)
    NetworkSetEntityInvisibleToNetwork(ped, false)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    
    -- Re-enable HUD elements
    DisplayRadar(true)
    DisplayHud(true)
    SetRadarBigmapEnabled(false, false) -- Ensure minimap is in normal mode
    
    -- Save spawn location
    TriggerServerEvent('srp-spawn:saveLastLocation', {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        w = coords.w
    })
    
    -- Update player state
    TriggerEvent('srp-characters:playerSpawned', true)
    
    -- Fade screen back in
    DoScreenFadeIn(500)
    while not IsScreenFadedIn() do
        Wait(0)
    end
end

-- Function to setup spawn camera
local function SetupSpawnCamera()
    -- Create camera
    if DoesCamExist(spawnCam) then
        DestroyCam(spawnCam, true)
    end
    
    spawnCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    
    -- Set camera position and rotation
    SetCamCoord(spawnCam, CameraConfig.defaultCamCoords.x, CameraConfig.defaultCamCoords.y, CameraConfig.defaultCamCoords.z)
    SetCamRot(spawnCam, CameraConfig.defaultCamRot.x, CameraConfig.defaultCamRot.y, CameraConfig.defaultCamRot.z, 2)
    SetCamFov(spawnCam, CameraConfig.defaultFov)
    
    -- Render camera
    RenderScriptCams(true, true, CameraConfig.transitionTime, true, true)
    
    -- Set timecycle modifier for better atmosphere
    SetTimecycleModifier('MP_intro_logo')
    SetTimecycleModifierStrength(1.0)
end

-- Show spawn selector menu
RegisterNetEvent('srp-spawn:showSpawnSelector')
AddEventHandler('srp-spawn:showSpawnSelector', function(lastPosition)
    -- Ensure screen is faded out
    DoScreenFadeOut(0)
    
    -- Setup camera
    SetupSpawnCamera()
    
    -- Short wait to ensure camera is set up
    Wait(500)
    
    local options = {}
    
    -- Add "Last Location" option if valid
    if lastPosition then
        table.insert(options, {
            title = "↩️ Last Location",
            description = "Spawn at your last known location",
            onSelect = function()
                HandleSpawn(vector4(
                    lastPosition.x,
                    lastPosition.y,
                    lastPosition.z,
                    lastPosition.w or 0.0
                ))
            end
        })
    end
    
    -- Add default spawn points
    for _, spawn in ipairs(Config.DefaultSpawns) do
        table.insert(options, {
            title = "📌 " .. spawn.name,
            description = spawn.description,
            onSelect = function()
                HandleSpawn(spawn.coords)
            end
        })
    end
    
    -- Register spawn selector menu
    lib.registerContext({
        id = 'spawn_selector_menu',
        title = 'Select Spawn Location',
        options = options,
        onExit = function()
            -- Don't cleanup camera on exit as we want it to persist until spawn
        end
    })
    
    -- Fade screen in before showing menu
    DoScreenFadeIn(500)
    while not IsScreenFadedIn() do
        Wait(0)
    end
    
    -- Show the menu
    lib.showContext('spawn_selector_menu')
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    CleanupSpawnCamera()
end) 