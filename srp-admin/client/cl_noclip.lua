local noclipEnabled = false
local ent
local invisible = nil
local noclipCam = nil
local speed = 1.0
local maxSpeed = 32.0
local minY, maxY = -150.0, 160.0
local disableControls = { 30, 31, 32, 33, 34, 35, 44, 46 }

local cache = {
    ped = PlayerPedId(),
    vehicle = nil,
    playerId = PlayerId()
}

CreateThread(function()
    while true do
        cache.ped = PlayerPedId()
        cache.vehicle = GetVehiclePedIsIn(cache.ped, false)
        cache.playerId = PlayerId()
        Wait(1000)
    end
end)

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    
    CreateThread(function()
        local inVehicle = false

        if cache.vehicle then
            inVehicle = true
            ent = cache.vehicle
        else
            ent = cache.ped
        end

        local pos = GetEntityCoords(ent)
        local rot = GetEntityRotation(ent)
        
        if noclipEnabled then
            noclipCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, rot.z, 75.0, true, 2)
            AttachCamToEntity(noclipCam, ent, 0.0, 0.0, 0.0, true)
            RenderScriptCams(true, false, 3000, true, false)
            FreezeEntityPosition(ent, true)
            SetEntityCollision(ent, false, false)
            SetEntityAlpha(ent, 0, false)
            SetPedCanRagdoll(cache.ped, false)
            SetEntityVisible(ent, false, false)

            if not inVehicle then
                ClearPedTasksImmediately(cache.ped)
            end

            if inVehicle then
                FreezeEntityPosition(cache.ped, true)
                SetEntityCollision(cache.ped, false, false)
                SetEntityAlpha(cache.ped, 0, false)
                SetEntityVisible(cache.ped, false, false)
            end

            lib.notify({
                title = 'NoClip Enabled',
                description = 'Use WASD to move, Q/E for Up/Down, Mouse Wheel for speed',
                type = 'info',
                duration = 5000
            })
        end

        while noclipEnabled do
            Wait(0)
            if IsDisabledControlPressed(0, 14) then -- Scroll Up
                speed = math.min(speed + 0.1, maxSpeed)
            elseif IsDisabledControlPressed(0, 15) then -- Scroll Down
                speed = math.max(0.1, speed - 0.1)
            end

            local multiplier = 1.0
            if IsDisabledControlPressed(0, 21) then -- Left Shift
                multiplier = 2.0
            elseif IsDisabledControlPressed(0, 19) then -- Left Alt
                multiplier = 4.0
            elseif IsDisabledControlPressed(0, 36) then -- Left CTRL
                multiplier = 0.25
            end

            local rightVector, forwardVector, upVector = GetCamMatrix(noclipCam)
            local pos = GetEntityCoords(ent)

            if IsDisabledControlPressed(0, 32) then -- W
                pos = pos + forwardVector * (speed * multiplier)
            elseif IsDisabledControlPressed(0, 33) then -- S
                pos = pos - forwardVector * (speed * multiplier)
            end

            if IsDisabledControlPressed(0, 34) then -- A
                pos = pos - rightVector * (speed * multiplier)
            elseif IsDisabledControlPressed(0, 35) then -- D
                pos = pos + rightVector * (speed * multiplier)
            end

            if IsDisabledControlPressed(0, 44) then -- Q
                pos = pos + upVector * (speed * multiplier)
            elseif IsDisabledControlPressed(0, 46) then -- E
                pos = pos - upVector * (speed * multiplier)
            end

            SetEntityCoordsNoOffset(ent, pos.x, pos.y, pos.z, true, true, true)
            if not inVehicle then
                SetEntityCoordsNoOffset(cache.ped, pos.x, pos.y, pos.z, true, true, true)
            end

            local camRot = GetCamRot(noclipCam, 2)
            SetEntityHeading(ent, (360 + camRot.z) % 360)
            SetEntityVisible(ent, false, false)

            if inVehicle then
                SetEntityVisible(cache.ped, false, false)
            end

            for _, control in ipairs(disableControls) do
                DisableControlAction(0, control, true)
            end

            DisablePlayerFiring(cache.playerId, true)
        end

        DestroyCam(noclipCam, false)
        noclipCam = nil
        RenderScriptCams(false, false, 3000, true, false)
        FreezeEntityPosition(ent, false)
        SetEntityCollision(ent, true, true)
        ResetEntityAlpha(ent)
        SetPedCanRagdoll(cache.ped, true)
        SetEntityVisible(ent, not invisible, false)
        ClearPedTasksImmediately(cache.ped)
        
        if inVehicle then
            FreezeEntityPosition(cache.ped, false)
            SetEntityCollision(cache.ped, true, true)
            ResetEntityAlpha(cache.ped)
            SetEntityVisible(cache.ped, true, false)
            SetPedIntoVehicle(cache.ped, ent, -1)
        end

        lib.notify({
            title = 'NoClip Disabled',
            description = 'NoClip mode has been disabled',
            type = 'info'
        })
    end)
end

RegisterNetEvent('srp-admin:noclip', function()
    toggleNoclip()
end)

RegisterCommand('noclip', function()
    TriggerServerEvent('srp-admin:toggleNoclip')
end)

lib.addKeybind({
    name = 'toggleNoclip',
    description = 'Toggle NoClip Mode',
    defaultKey = 'HOME',
    onPressed = function()
        TriggerServerEvent('srp-admin:toggleNoclip')
    end
})