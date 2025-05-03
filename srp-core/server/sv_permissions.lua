-- ==================
-- Local Variables
-- ==================
local PlayerGroups = {}

-- ==================
-- Helper Functions
-- ==================
local function endsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

local function startsWith(str, start)
    return str:sub(1, #start) == start
end

-- ==================
-- Core Group Functions
-- ==================
local function GetPlayerGroup(source)
    if not PlayerGroups[source] then
        local license = GetPlayerIdentifierByType(source, 'license')
        if not license then return Config.Permissions.DefaultGroup end
        
        -- Check if user has assigned group
        PlayerGroups[source] = Config.Permissions.Users[license] or Config.Permissions.DefaultGroup
    end
    
    return PlayerGroups[source]
end

-- ==================
-- Permission Functions
-- ==================
function HasPermission(source, permission)
    local playerGroup = GetPlayerGroup(source)
    local currentGroup = Config.Permissions.Groups[playerGroup]
    
    -- Check group permissions
    while currentGroup do
        for _, perm in ipairs(currentGroup.permissions) do
            -- Check for exact match, wildcard, or pattern match
            if perm == permission or perm == '*' or 
               (endsWith(perm, '.*') and startsWith(permission, perm:sub(1, -3))) then
                return true
            end
        end
        
        -- Check inherited permissions
        if currentGroup.inherits then
            currentGroup = Config.Permissions.Groups[currentGroup.inherits]
        else
            break
        end
    end
    
    return false
end

function GetPlayerPermissions(source)
    local permissions = {}
    local playerGroup = GetPlayerGroup(source)
    local currentGroup = Config.Permissions.Groups[playerGroup]
    
    -- Collect all permissions including inherited ones
    while currentGroup do
        for _, perm in ipairs(currentGroup.permissions) do
            table.insert(permissions, perm)
        end
        
        if currentGroup.inherits then
            currentGroup = Config.Permissions.Groups[currentGroup.inherits]
        else
            break
        end
    end
    
    return permissions
end

-- ==================
-- Event Handlers
-- ==================
AddEventHandler('playerDropped', function()
    PlayerGroups[source] = nil
end)

-- Debug event for checking permissions
RegisterNetEvent('srp-core:checkPermission', function(permission)
    local src = source
    local hasPermission = HasPermission(src, permission)
    local group = GetPlayerGroup(src)
    
    if Config.Debug then
        print(string.format('^3[DEBUG] Player %s (Group: %s) %s permission: %s^7', 
            GetPlayerName(src), 
            group, 
            hasPermission and "has" or "doesn't have",
            permission
        ))
    end
end)

-- ==================
-- Exports
-- ==================
exports('HasPermission', HasPermission)
exports('GetPlayerPermissions', GetPlayerPermissions)
exports('GetPlayerGroup', GetPlayerGroup)

-- ==================
-- Debug Functions
-- ==================
if Config.Debug then
    RegisterCommand('checkperms', function(source, args)
        if source == 0 then return end -- Console can't check permissions
        
        local permission = args[1]
        if not permission then
            print('^1Error: Please specify a permission to check^7')
            return
        end
        
        TriggerEvent('srp-core:checkPermission', permission)
    end)
end