-- ==================
-- Local Variables
-- ==================
local menuOpen = false

-- ==================
-- Menu Functions
-- ==================
local function openAdminMenu()
    -- Get menu data from server (includes permission checks)
    local menuData = lib.callback.await('srp-admin:getMenuData', false)
    
    -- Create menu options
    local options = {}
    for category, data in pairs(menuData.categories) do
        -- Add category header
        table.insert(options, {
            title = category,
            icon = 'bars',
            disabled = true
        })
        
        -- Add category options
        for _, option in ipairs(data.options) do
            table.insert(options, {
                title = option.label,
                description = 'Execute ' .. option.label,
                icon = 'circle',
                onSelect = function()
                    -- Directly handle the action here instead of using another event
                    if option.label == 'Toggle NoClip' then
                        TriggerServerEvent('srp-admin:toggleNoclip')
                    elseif option.label == 'Teleport to Player' then
                        local input = lib.inputDialog('Teleport to Player', {
                            {type = 'number', label = 'Player ID', description = 'Enter the server ID of the player', required = true}
                        })
                        if input then
                            TriggerServerEvent('srp-admin:teleportToPlayer', input[1])
                        end
                    elseif option.label == 'Bring Player' then
                        local input = lib.inputDialog('Bring Player', {
                            {type = 'number', label = 'Player ID', description = 'Enter the server ID of the player', required = true}
                        })
                        if input then
                            TriggerServerEvent('srp-admin:bringPlayer', input[1])
                        end
                    elseif option.label == 'Heal Player' then
                        local input = lib.inputDialog('Heal Player', {
                            {type = 'number', label = 'Player ID', description = 'Enter the server ID of the player (leave empty for self)', required = false}
                        })
                        TriggerServerEvent('srp-admin:healPlayer', input and input[1] or source)
                    end
                end
            })
        end
        
        -- Add separator between categories
        table.insert(options, {
            icon = 'chevron-down',
            disabled = true
        })
    end
    
    -- Remove last separator
    table.remove(options)
    
    lib.registerContext({
        id = 'admin_menu',
        title = 'Admin Menu',
        options = options,
        onExit = function()
            menuOpen = false
        end
    })
    
    lib.showContext('admin_menu')
    menuOpen = true
end

-- ==================
-- Event Handlers
-- ==================
RegisterNetEvent('srp-admin:openMenu', function()
    openAdminMenu()
end)

-- ==================
-- Keybinds
-- ==================
lib.addKeybind({
    name = 'openAdminMenu',
    description = 'Open Admin Menu',
    defaultKey = 'F5',
    onPressed = function()
        TriggerEvent('srp-admin:openMenu')
    end
})