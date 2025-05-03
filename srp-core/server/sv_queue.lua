-- ==================
-- Local Variables
-- ==================
local Queue = {}
local QueuedPlayers = {}
local ConnectingPlayers = {}
local PlayerCount = 0
local MaxPlayers = GetConvarInt('sv_maxclients', 32)
local QueueUpdateInterval = 5000

-- Session handling
local PendingSession = {}
local HandshakeTimeout = 15000 -- 15 seconds for handshake

-- ==================
-- Helper Functions
-- ==================
local function RemoveFromQueue(source)
    if not QueuedPlayers[source] then return end
    
    for i = 1, #Queue do
        if Queue[i].source == source then
            table.remove(Queue, i)
            break
        end
    end
    
    QueuedPlayers[source] = nil
end

local function AddToQueue(source, name, deferrals)
    local ids = GetPlayerIdentifiers(source)
    local priority = 0
    
    -- Check if player has priority from permissions
    if ids.license then
        local group = exports['srp-core']:GetPlayerGroup(ids.license)
        if Config.Queue.PriorityGroups[group] then
            priority = Config.Queue.PriorityGroups[group]
        end
    end
    
    local player = {
        source = source,
        name = name,
        priority = priority,
        timeout = os.time() + Config.Queue.Timeout,
        deferrals = deferrals
    }
    
    -- Insert player into queue based on priority
    local inserted = false
    for i = 1, #Queue do
        if Queue[i].priority < priority then
            table.insert(Queue, i, player)
            inserted = true
            break
        end
    end
    
    if not inserted then
        table.insert(Queue, player)
    end
    
    QueuedPlayers[source] = true
    return #Queue
end

local function GetPlayerInfo(source)
    local identifiers = GetPlayerIdentifiers(source)
    local steamid = "No Steam"
    local name = GetPlayerName(source) or "Unknown"
    
    -- Get Steam ID if available
    for _, identifier in ipairs(identifiers) do
        if identifier:match("steam:") then
            steamid = identifier
            break
        end
    end
    
    return name, steamid
end

-- ==================
-- Event Handlers
-- ==================
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local playerName, steamId = GetPlayerInfo(source)
    
    print(string.format("^2[CONNECTING] ^7%s ^3(Steam: %s)^7", playerName, steamId))
    
    deferrals.defer()

    -- Allow time for session handshake
    deferrals.update("Initializing connection...")
    
    -- Add to pending session
    PendingSession[source] = {
        name = name,
        deferrals = deferrals,
        timestamp = GetGameTimer(),
        handled = false
    }
    
    -- Wait for session to initialize
    CreateThread(function()
        local timeout = GetGameTimer() + HandshakeTimeout
        
        while GetGameTimer() < timeout do
            if GetPlayerPing(source) > 0 then
                -- Session established, process queue
                if PlayerCount < MaxPlayers then
                    deferrals.done()
                    ConnectingPlayers[source] = true
                else
                    local position = AddToQueue(source, name, deferrals)
                end
                PendingSession[source].handled = true
                return
            end
            Wait(100)
        end
        
        -- Handshake timeout
        if not PendingSession[source].handled then
            deferrals.done("Connection timed out - please try again")
            PendingSession[source] = nil
        end
    end)
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    local playerName, steamId = GetPlayerInfo(source)
    
    print(string.format("^1[DISCONNECTED] ^7%s ^3(Steam: %s)^7 - Reason: %s", playerName, steamId, reason))
    
    if PendingSession[source] then
        PendingSession[source] = nil
    end
    RemoveFromQueue(source)
    if ConnectingPlayers[source] then
        PlayerCount = PlayerCount - 1
        ConnectingPlayers[source] = nil
    end
end) 