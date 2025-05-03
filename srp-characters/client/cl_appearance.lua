RegisterNetEvent('srp-characters:startPedCustomization')
AddEventHandler('srp-characters:startPedCustomization', function(charSlot, defaultModel)
    -- Clear any existing menus and cameras
    lib.hideContext()
    if DoesCamExist(previewCam) then
        DestroyCam(previewCam, true)
        RenderScriptCams(false, false, 0, true, true)
    end
    
    -- Clear blur effect
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
    
    Wait(500) -- Give time for cleanup
    
    -- Request and load the interior
    local interiorID = GetInteriorAtCoords(402.85, -996.45, -99.0)
    LoadInterior(interiorID)
    while not IsInteriorReady(interiorID) do
        Wait(100)
    end
    
    -- Reset the ped to default freemode model and clear appearance
    defaultModel = defaultModel or 'mp_m_freemode_01'
    exports['fivem-appearance']:setPlayerModel(defaultModel)
    
    -- Get the new ped reference after model change
    local ped = PlayerPedId()
    
    -- Reset appearance to default using setPedComponents and setPedProps
    local defaultComponents = {
        [0] = {drawable = 0, texture = 0},  -- Face
        [1] = {drawable = 0, texture = 0},  -- Mask
        [2] = {drawable = 0, texture = 0},  -- Hair
        [3] = {drawable = 0, texture = 0},  -- Torso
        [4] = {drawable = 0, texture = 0},  -- Legs
        [5] = {drawable = 0, texture = 0},  -- Bags
        [6] = {drawable = 0, texture = 0},  -- Shoes
        [7] = {drawable = 0, texture = 0},  -- Accessories
        [8] = {drawable = 0, texture = 0},  -- Undershirt
        [9] = {drawable = 0, texture = 0},  -- Body Armor
        [10] = {drawable = 0, texture = 0}, -- Decals
        [11] = {drawable = 0, texture = 0}  -- Tops
    }
    
    local defaultProps = {
        [0] = {drawable = -1, texture = -1}, -- Hats
        [1] = {drawable = -1, texture = -1}, -- Glasses
        [2] = {drawable = -1, texture = -1}, -- Ears
        [3] = {drawable = -1, texture = -1}, -- Watches
        [4] = {drawable = -1, texture = -1}  -- Bracelets
    }
    
    -- Apply default components and props
    for componentId, component in pairs(defaultComponents) do
        SetPedComponentVariation(ped, componentId, component.drawable, component.texture, 0)
    end
    
    for propId, prop in pairs(defaultProps) do
        if prop.drawable == -1 then
            ClearPedProp(ped, propId)
        else
            SetPedPropIndex(ped, propId, prop.drawable, prop.texture, true)
        end
    end
    
    -- Teleport player to customization location
    SetEntityCoords(ped, Config.CustomizationRoom.coords.x, Config.CustomizationRoom.coords.y, Config.CustomizationRoom.coords.z, false, false, false, false)
    SetEntityHeading(ped, Config.CustomizationRoom.coords.w)
    
    -- Ensure ped is on ground
    PlaceObjectOnGroundProperly(ped)
    
    -- Make ped visible locally but invisible to others
    SetEntityVisible(ped, true, false)
    SetEntityLocallyVisible(ped)
    SetEntityLocallyInvisible(ped)
    NetworkSetEntityInvisibleToNetwork(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    
    local config = {
        ped = true,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        tattoos = true,
        -- Restrict ped models to only freemode
        pedModels = {
            [`mp_m_freemode_01`] = 'Male',
            [`mp_f_freemode_01`] = 'Female'
        },
        defaultModel = defaultModel
    }
    
    exports['fivem-appearance']:startPlayerCustomization(function(appearance)
        if appearance then
            -- Save appearance and character slot
            TriggerServerEvent('srp-characters:saveAppearance', appearance, charSlot)
            
            -- Reset ped visibility
            NetworkSetEntityInvisibleToNetwork(ped, false)
            SetEntityInvincible(ped, false)
            FreezeEntityPosition(ped, false)
            
            -- Show spawn selector
            TriggerEvent('srp-spawn:showSpawnSelector', Config.DefaultSpawn)
        else
            -- If cancelled, return to character list
            -- Reset ped visibility first
            NetworkSetEntityInvisibleToNetwork(ped, false)
            SetEntityInvincible(ped, false)
            FreezeEntityPosition(ped, false)
            
            TriggerServerEvent('srp-characters:requestCharacters')
        end
    end, config)
end)

-- Cleanup function
function CleanupCustomization()
    local ped = PlayerPedId()
    
    -- Reset ped state
    NetworkSetEntityInvisibleToNetwork(ped, false)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    
    -- Clear interior
    local interiorID = GetInteriorAtCoords(402.85, -996.45, -99.0)
    if interiorID ~= 0 then
        DeactivateInteriorEntitySet(interiorID, "shell")
        RefreshInterior(interiorID)
    end
end

-- Add cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    CleanupCustomization()
end) 