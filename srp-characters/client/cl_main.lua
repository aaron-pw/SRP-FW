local PlayerData = {}
local previewCam = nil

-- Helper function for date formatting
local function FormatDate(dateString)
    if not dateString then return "Unknown" end
    
    -- If it's already in DD/MM/YYYY format
    if string.match(dateString, "%d%d/%d%d/%d%d%d%d") then
        return dateString
    end
    
    -- Try to match different date formats
    local day, month, year = dateString:match("(%d+)/(%d+)/(%d+)")
    if not day then
        -- Try YYYY-MM-DD format
        year, month, day = dateString:match("(%d+)-(%d+)-(%d+)")
    end
    
    if day and month and year then
        -- Convert to numbers
        day = tonumber(day)
        month = tonumber(month)
        year = tonumber(year)
        
        -- Format with leading zeros
        return string.format("%02d/%02d/%04d", day, month, year)
    end
    
    return dateString
end

-- Character actions menu (Play/Delete)
local function ShowCharacterActions(char)
    lib.registerContext({
        id = 'character_actions_menu',
        title = string.format('%s %s', char.firstname, char.lastname),
        menu = 'character_list_menu',
        options = {
            {
                title = '🎮 Play Character',
                description = 'Start playing with this character',
                onSelect = function()
                    print('^3[DEBUG] Character selected: ' .. char.firstname .. ' ' .. char.lastname .. '^7')
                    
                    -- Start screen fade
                    DoScreenFadeOut(500)
                    while not IsScreenFadedOut() do
                        Wait(0)
                    end
                    
                    -- Request the character data from server
                    TriggerServerEvent('srp-characters:selectCharacter', char.char_slot or 1)
                end
            },
            {
                title = '❌ Delete Character',
                description = 'Permanently delete this character',
                onSelect = function()
                    local confirm = lib.alertDialog({
                        header = 'Delete Character',
                        content = string.format('Are you sure you want to delete %s %s?\nThis action cannot be undone!', 
                            char.firstname, 
                            char.lastname
                        ),
                        centered = true,
                        cancel = true,
                        labels = {
                            confirm = 'DELETE',
                            cancel = 'CANCEL'
                        }
                    })
                    
                    if confirm == 'confirm' then
                        TriggerServerEvent('srp-characters:deleteCharacter', char.char_slot)
                    else
                        lib.showContext('character_list_menu')
                    end
                end
            }
        }
    })
    
    lib.showContext('character_actions_menu')
end

-- Camera settings
local charCam = nil
local defaultCamCoords = vector3(-1355.93, -1487.78, 520.75)
local defaultCamRot = vector3(0.0, 0.0, 40.0)
local defaultCharacterSpawn = vector4(-1042.28, -2745.42, 21.36, 327.7) -- This is where the invisible ped will be

-- Function to setup character selection camera
local function SetupCharacterCamera()
    -- Create camera
    charCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    
    -- Set camera position and rotation
    SetCamCoord(charCam, defaultCamCoords.x, defaultCamCoords.y, defaultCamCoords.z)
    SetCamRot(charCam, defaultCamRot.x, defaultCamRot.y, defaultCamRot.z, 2)
    SetCamFov(charCam, 50.0)
    
    -- Render camera
    RenderScriptCams(true, true, 1000, true, true)
    
    -- Set timecycle modifier for better atmosphere
    SetTimecycleModifier('MP_intro_logo')
    SetTimecycleModifierStrength(1.0)
end

-- Function to cleanup character camera
local function CleanupCharacterCamera()
    if DoesCamExist(charCam) then
        DestroyCam(charCam, true)
        RenderScriptCams(false, true, 1000, true, true)
        charCam = nil
    end
    
    -- Clear timecycle modifier
    ClearTimecycleModifier()
end

-- Character list display
local function ShowCharacterList(characters)
    print('^3[DEBUG] Building character list menu^7')
    
    -- Ensure camera is set up
    if not DoesCamExist(charCam) then
        SetupCharacterCamera()
    end
    
    local options = {}
    
    -- Add existing characters to the list
    for _, char in ipairs(characters) do
        local formattedDate = FormatDate(char.dateofbirth)
        print('^3[DEBUG] Original DOB:', char.dateofbirth, 'Formatted:', formattedDate)
        
        table.insert(options, {
            title = string.format('%s %s', char.firstname, char.lastname),
            description = string.format('Date of Birth: %s | Slot: %d', 
                formattedDate,
                char.char_slot or 1
            ),
            onSelect = function()
                ShowCharacterActions(char)
            end
        })
    end
    
    -- Add "Create New Character" option if less than max characters
    if #characters < Config.MaxCharacters then
        local nextSlot = #characters + 1
        table.insert(options, {
            title = '➕ Create New Character',
            description = string.format('Slot %d', nextSlot),
            onSelect = function()
                print('^3[DEBUG] Create new character selected for slot ' .. nextSlot .. '^7')
                OpenCharacterCreator(nextSlot)
            end
        })
    end
    
    lib.registerContext({
        id = 'character_list_menu',
        title = 'Character Selection',
        options = options,
        canClose = false
    })
    
    print('^3[DEBUG] Showing character list menu^7')
    lib.showContext('character_list_menu')
end

-- Register network events
RegisterNetEvent('srp-characters:showCharacterList')
AddEventHandler('srp-characters:showCharacterList', ShowCharacterList)

RegisterNetEvent('srp-characters:characterLoaded')
AddEventHandler('srp-characters:characterLoaded', function(data)
    PlayerData = data
    PlayerData.spawned = false -- Initialize as false
    
    -- Clear any existing timecycle modifier
    ClearTimecycleModifier()
    SetTimecycleModifierStrength(0.0)
    
    -- Set the player model based on gender
    local model = data.gender == 'female' and 'mp_f_freemode_01' or 'mp_m_freemode_01'
    exports['fivem-appearance']:setPlayerModel(model)
    
    -- Wait for model to load
    Wait(500)
    
    -- Apply saved appearance if it exists
    if data.appearance then
        exports['fivem-appearance']:setPlayerAppearance(data.appearance)
    end
    
    -- Wait for appearance to apply
    Wait(500)
    
    -- Make player visible
    local ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    NetworkSetEntityInvisibleToNetwork(ped, false)
    SetEntityInvincible(ped, false)
    
    -- Trigger spawn selection
    TriggerEvent('srp-spawn:showSpawnSelector', data.position or Config.DefaultSpawn)
end)

-- Logout command
RegisterCommand('logout', function()
    -- Fade screen out
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    
    -- Save last position before logout
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    TriggerServerEvent('srp-spawn:saveLastLocation', {
        x = pos.x,
        y = pos.y,
        z = pos.z,
        w = heading
    })
    
    -- Hide HUD elements
    DisplayRadar(false)
    DisplayHud(false)
    
    -- Hide all HUD components
    local hudComponents = {
        1,  -- WANTED_STARS
        2,  -- WEAPON_ICON
        3,  -- CASH
        4,  -- MP_CASH
        6,  -- VEHICLE_NAME
        7,  -- AREA_NAME
        8,  -- VEHICLE_CLASS
        9,  -- STREET_NAME
        13, -- CASH_CHANGE
        17, -- SAVE_GAME
        19, -- WEAPON_WHEEL
        20, -- WEAPON_WHEEL_STATS
        21, -- HUD_COMPONENTS
        22, -- HUD_WEAPONS
    }
    
    for _, component in ipairs(hudComponents) do
        HideHudComponentThisFrame(component)
    end
    
    -- Disable controls
    DisableControlAction(0, 1, true) -- LookLeftRight
    DisableControlAction(0, 2, true) -- LookUpDown
    DisableControlAction(0, 142, true) -- MeleeAttackAlternate
    DisableControlAction(0, 18, true) -- Enter
    DisableControlAction(0, 322, true) -- ESC
    DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
    
    -- Clear focus
    SetNuiFocus(false, false)
    
    -- Teleport to character selection position
    SetEntityCoords(ped, defaultCharacterSpawn.x, defaultCharacterSpawn.y, defaultCharacterSpawn.z, false, false, false, false)
    SetEntityHeading(ped, defaultCharacterSpawn.w)
    FreezeEntityPosition(ped, true)
    
    -- Make ped invisible
    SetEntityVisible(ped, false, false)
    NetworkSetEntityInvisibleToNetwork(ped, true)
    SetEntityInvincible(ped, true)
    
    -- Setup camera
    SetupCharacterCamera()
    
    -- Request characters list
    Wait(500) -- Short wait to ensure everything is set up
    TriggerServerEvent('srp-characters:requestCharacters')
    
    -- Fade screen back in
    DoScreenFadeIn(500)
end, false)

-- Create a thread to continuously hide HUD during character selection
CreateThread(function()
    while true do
        if not PlayerData.spawned then -- Add this state variable when player spawns/logs out
            -- Hide HUD components every frame
            DisplayRadar(false)
            DisplayHud(false)
            
            local hudComponents = {
                1,  -- WANTED_STARS
                2,  -- WEAPON_ICON
                3,  -- CASH
                4,  -- MP_CASH
                6,  -- VEHICLE_NAME
                7,  -- AREA_NAME
                8,  -- VEHICLE_CLASS
                9,  -- STREET_NAME
                13, -- CASH_CHANGE
                17, -- SAVE_GAME
                19, -- WEAPON_WHEEL
                20, -- WEAPON_WHEEL_STATS
                21, -- HUD_COMPONENTS
                22, -- HUD_WEAPONS
            }
            
            for _, component in ipairs(hudComponents) do
                HideHudComponentThisFrame(component)
            end
        end
        Wait(0)
    end
end)

-- Add chat suggestion
CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/logout', 'Return to character selection')
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    CleanupCharacterCamera()
end)

-- Export the ShowCharacterList function
exports('ShowCharacterList', ShowCharacterList)

exports('GetCameraConfig', function()
    return CameraConfig
end)

-- Track player spawn state
RegisterNetEvent('srp-characters:playerSpawned')
AddEventHandler('srp-characters:playerSpawned', function(state)
    if PlayerData then
        PlayerData.spawned = state
    end
end) 