local Players = {}

-- Request characters list
RegisterNetEvent('srp-characters:requestCharacters')
AddEventHandler('srp-characters:requestCharacters', function()
    local source = source
    local license = GetPlayerIdentifierByType(source, 'license')
    
    if not license then return end
    
    MySQL.query('SELECT * FROM players WHERE license = ? AND firstname IS NOT NULL', {license}, 
    function(characters)
        print('^3[DEBUG] Found ' .. #characters .. ' characters for license: ' .. license .. '^7')
        TriggerClientEvent('srp-characters:showCharacterList', source, characters or {})
    end)
end)

-- Save new character
RegisterNetEvent('srp-characters:saveNewCharacter')
AddEventHandler('srp-characters:saveNewCharacter', function(data)
    local source = source
    local license = GetPlayerIdentifierByType(source, 'license')
    
    if not license then return end
    
    MySQL.insert('INSERT INTO players (license, char_slot, firstname, lastname, dateofbirth, gender) VALUES (?, ?, ?, ?, ?, ?)', {
        license,
        data.char_slot,
        data.firstname,
        data.lastname,
        data.dateofbirth,
        data.gender
    }, function(id)
        if id then
            print('^2[SUCCESS] Created new character for ' .. GetPlayerName(source) .. '^7')
            
            -- Set the default model based on gender before starting customization
            local defaultModel = data.gender == 'male' and 'mp_m_freemode_01' or 'mp_f_freemode_01'
            TriggerClientEvent('srp-characters:startPedCustomization', source, data.char_slot, defaultModel)
        else
            print('^1[ERROR] Failed to create character for ' .. GetPlayerName(source) .. '^7')
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Error',
                description = 'Failed to create character',
                type = 'error'
            })
            -- Return to character list
            TriggerEvent('srp-characters:requestCharacters', source)
        end
    end)
end)

-- Select character
RegisterNetEvent('srp-characters:selectCharacter')
AddEventHandler('srp-characters:selectCharacter', function(charSlot)
    local source = source
    local license = GetPlayerIdentifierByType(source, 'license')
    
    if not license then return end
    
    MySQL.single('SELECT * FROM players WHERE license = ? AND char_slot = ?', {
        license,
        charSlot
    }, function(character)
        if character then
            -- Initialize player data
            Players[source] = {
                id = character.id,
                license = license,
                char_slot = charSlot,
                firstname = character.firstname,
                lastname = character.lastname,
                dateofbirth = character.dateofbirth,
                gender = character.gender,
                cash = character.cash,
                bank = character.bank,
                position = json.decode(character.position),
                appearance = character.appearance and json.decode(character.appearance) or nil
            }
            
            print('^2[SUCCESS] Character loaded for ' .. GetPlayerName(source) .. '^7')
            
            -- Send player data to client
            TriggerClientEvent('srp-characters:characterLoaded', source, Players[source])
        else
            print('^1[ERROR] Character not found for ' .. GetPlayerName(source) .. '^7')
            TriggerEvent('srp-characters:requestCharacters', source)
        end
    end)
end)

-- Delete character
RegisterNetEvent('srp-characters:deleteCharacter')
AddEventHandler('srp-characters:deleteCharacter', function(charSlot)
    local source = source
    local license = GetPlayerIdentifierByType(source, 'license')
    
    if not license then return end
    
    print('^3[DEBUG] Attempting to delete character in slot ' .. tostring(charSlot) .. ' for license: ' .. license .. '^7')
    
    MySQL.execute('DELETE FROM players WHERE license = ? AND char_slot = ?', {
        license, 
        charSlot
    }, function(result)
        print('^3[DEBUG] Delete result:', json.encode(result))
        
        -- Fetch updated character list regardless of delete result
        MySQL.query('SELECT * FROM players WHERE license = ? AND firstname IS NOT NULL', {license}, 
        function(characters)
            if result and result.affectedRows > 0 then
                print('^2[SUCCESS] Character deleted from slot ' .. tostring(charSlot) .. '^7')
                
                -- Notify success
                TriggerClientEvent('ox_lib:notify', source, {
                    title = 'Success',
                    description = 'Character has been deleted',
                    type = 'success'
                })
            else
                print('^1[ERROR] Failed to delete character from slot ' .. tostring(charSlot) .. '^7')
                
                -- Notify error
                TriggerClientEvent('ox_lib:notify', source, {
                    title = 'Error',
                    description = 'Failed to delete character',
                    type = 'error'
                })
            end
            
            -- Always show updated character list
            TriggerClientEvent('srp-characters:showCharacterList', source, characters or {})
        end)
    end)
end)

-- Save appearance
RegisterNetEvent('srp-characters:saveAppearance')
AddEventHandler('srp-characters:saveAppearance', function(appearance, charSlot)
    local source = source
    local license = GetPlayerIdentifierByType(source, 'license')
    
    if not license then return end
    
    MySQL.update('UPDATE players SET appearance = ? WHERE license = ? AND char_slot = ?', {
        json.encode(appearance),
        license,
        charSlot
    }, function(affectedRows)
        if affectedRows > 0 then
            -- Update the player's appearance in memory if they exist
            if Players[source] then
                Players[source].appearance = appearance
            end
            
            print('^2[SUCCESS] Appearance saved for character slot ' .. charSlot .. '^7')
        else
            print('^1[ERROR] Failed to save appearance for character slot ' .. charSlot .. '^7')
        end
    end)
end)

-- Cleanup on player drop
AddEventHandler('playerDropped', function()
    local source = source
    Players[source] = nil
end)

-- Export the Players table
exports('GetPlayers', function()
    return Players
end) 