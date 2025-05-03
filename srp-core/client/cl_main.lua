-- ==================
-- Local Variables
-- ==================
local PlayerData = {}
local isSpawned = false
local firstSpawn = true
local isLoaded = false
local previewCam = nil

-- ==================
-- Initialization Threads
-- ==================
-- Initial spawn handler
CreateThread(function()
    -- Disable auto-spawn from spawnmanager
    exports.spawnmanager:setAutoSpawn(false)
    
    -- Wait for game to load
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(0)
    end
    
    -- Set initial spawn point (prevents black screen)
    exports.spawnmanager:spawnPlayer({
        x = -1037.66,
        y = -2737.62,
        z = 20.17,
        heading = 0.0,
        model = 'mp_m_freemode_01',
        skipFade = true
    }, function()
        -- After initial spawn, trigger character selection
        TriggerServerEvent('srp-characters:requestCharacters')
    end)
end)

-- Debug thread
CreateThread(function()
    print('^2SRP-Core: Client-side initialized successfully^7')
end)

-- ==================
-- Core Event Handlers
-- ==================
AddEventHandler('playerSpawned', function()
    print('^3[DEBUG] playerSpawned event triggered^7')
    if firstSpawn then
        firstSpawn = false
        isLoaded = false
        
        -- Hide player and UI
        local ped = PlayerPedId()
        SetEntityVisible(ped, false, false)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        DisplayRadar(false)
        DisplayHud(false)
        
        -- Small delay to ensure everything is loaded
        Wait(1000)
        TriggerServerEvent('srp-core:playerFirstSpawn')
    end
end)

RegisterNetEvent('srp-core:playerSpawned')
AddEventHandler('srp-core:playerSpawned', function()
    if not isSpawned then
        isSpawned = true
        TriggerServerEvent('srp-core:playerSpawned')
    end
end)

RegisterNetEvent('srp-core:playerLoaded')
AddEventHandler('srp-core:playerLoaded', function(data)
    PlayerData = data
    TriggerEvent('srp-core:updateMoney', PlayerData.cash, PlayerData.bank)
end)

-- ==================
-- Player State Events
-- ==================
RegisterNetEvent('srp-core:updateMoney')
AddEventHandler('srp-core:updateMoney', function(cash, bank)
    PlayerData.cash = cash
    PlayerData.bank = bank
    
    lib.notify({
        title = 'Balance Update',
        description = string.format('Cash: $%d | Bank: $%d', cash, bank),
        type = 'inform'
    })
end)

RegisterNetEvent('srp-core:initializePlayer')
AddEventHandler('srp-core:initializePlayer', function()
    local ped = PlayerPedId()
    SetEntityVisible(ped, false, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetPedAoBlobRendering(ped, false)
    NetworkSetEntityInvisibleToNetwork(ped, true)
end)

-- ==================
-- Resource Handlers
-- ==================
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    
    Wait(1000)
    if NetworkIsPlayerActive(PlayerId()) then
        local ped = PlayerPedId()
        SetEntityVisible(ped, false, false)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        DisplayRadar(false)
        DisplayHud(false)
        
        TriggerServerEvent('srp-characters:requestCharacters')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    
    if DoesCamExist(previewCam) then
        DestroyCam(previewCam, true)
        RenderScriptCams(false, false, 0, true, true)
    end
    
    local ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    
    DisplayHud(true)
    DisplayRadar(true)
end)

-- ==================
-- Exports
-- ==================
exports('GetPlayerData', function()
    return PlayerData
end)

-- ==================
-- Resource Events
-- ==================
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print('^2SRP-Core: Client-side initialized^7')
end)

-- ==================
-- Player State Events
-- ==================
RegisterNetEvent('srp-core:setPlayerData')
AddEventHandler('srp-core:setPlayerData', function(key, value)
    if not PlayerData then return end
    PlayerData[key] = value
end)

RegisterNetEvent('srp-core:updatePlayerData')
AddEventHandler('srp-core:updatePlayerData', function(data)
    for k, v in pairs(data) do
        PlayerData[k] = v
    end
end)

-- ==================
-- Character Events
-- ==================
RegisterNetEvent('srp-core:characterSelected')
AddEventHandler('srp-core:characterSelected', function(data)
    PlayerData = data
    isLoaded = true
    
    -- Enable player and UI
    local ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    DisplayRadar(true)
    DisplayHud(true)
    
    TriggerEvent('srp-core:playerLoaded', PlayerData)
end)

RegisterNetEvent('srp-core:characterLogout')
AddEventHandler('srp-core:characterLogout', function()
    isLoaded = false
    PlayerData = {}
    
    -- Hide player and UI
    local ped = PlayerPedId()
    SetEntityVisible(ped, false, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    DisplayRadar(false)
    DisplayHud(false)
    
    -- Trigger character selection
    TriggerEvent('srp-characters:showCharacterList')
end)
