-- ==================
-- Local Variables
-- ==================
local core = exports['srp-core']

-- ==================
-- Helper Functions
-- ==================
local function hasPermission(source, permission)
    return core:HasPermission(source, permission)
end

-- ==================
-- Admin Commands
-- ==================
lib.addCommand('admin', {
    help = 'Open admin menu',
    restricted = false -- Core handles permissions
}, function(source, args, raw)
    local hasAnyPermission = false
    
    -- Check if player has access to any category
    for category, data in pairs(Config.AdminMenu.categories) do
        if hasPermission(source, data.permission) then
            hasAnyPermission = true
            break
        end
    end
    
    if hasAnyPermission then
        TriggerClientEvent('srp-admin:openMenu', source)
    else
        lib.notify(source, {
            title = 'Access Denied',
            description = 'You do not have permission to use the admin menu',
            type = 'error'
        })
    end
end)

-- ==================
-- Admin Functions
-- ==================
lib.callback.register('srp-admin:checkPermission', function(source, permission)
    return hasPermission(source, permission)
end)

lib.callback.register('srp-admin:getMenuData', function(source)
    local menuData = {categories = {}}
    
    -- Only return categories/options the player has access to
    for category, data in pairs(Config.AdminMenu.categories) do
        if hasPermission(source, data.permission) then
            local accessibleOptions = {}
            
            for _, option in ipairs(data.options) do
                if hasPermission(source, option.permission) then
                    table.insert(accessibleOptions, option)
                end
            end
            
            if #accessibleOptions > 0 then
                menuData.categories[category] = {
                    permission = data.permission,
                    options = accessibleOptions
                }
            end
        end
    end
    
    return menuData
end)

RegisterNetEvent('srp-admin:toggleNoclip', function()
    local source = source
    if not hasPermission(source, 'admin.noclip') then 
        lib.notify(source, {
            title = 'Access Denied',
            description = 'You do not have permission to use noclip',
            type = 'error'
        })
        return 
    end
    
    TriggerClientEvent('srp-admin:noclip', source)
end)