-- Save last location
RegisterNetEvent('srp-spawn:saveLastLocation')
AddEventHandler('srp-spawn:saveLastLocation', function(position)
    local source = source
    local license = GetPlayerIdentifierByType(source, 'license')
    
    if not license then return end
    
    -- Get current character slot from srp-characters
    local Players = exports['srp-characters']:GetPlayers()
    local charSlot = Players[source] and Players[source].char_slot
    
    if not charSlot then return end
    
    MySQL.update('UPDATE players SET position = ? WHERE license = ? AND char_slot = ?', {
        json.encode(position),
        license,
        charSlot
    }, function(affectedRows)
        if affectedRows > 0 then
            print('^2[SUCCESS] Saved last location for ' .. GetPlayerName(source) .. '^7')
        else
            print('^1[ERROR] Failed to save last location for ' .. GetPlayerName(source) .. '^7')
        end
    end)
end) 