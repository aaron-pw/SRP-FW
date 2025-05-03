OpenCharacterCreator = function(slot)
    if not slot then return end
    
    -- Hide any existing menus
    lib.hideContext()
    Wait(200)
    
    -- Gender Selection Menu
    local genderOptions = {
        {
            title = 'Male',
            icon = '👨',
            onSelect = function()
                CreateCharacter(slot, 'male')
            end
        },
        {
            title = 'Female',
            icon = '👩',
            onSelect = function()
                CreateCharacter(slot, 'female')
            end
        }
    }
    
    lib.registerContext({
        id = 'gender_selection_menu',
        title = 'Select Gender',
        options = genderOptions,
        canClose = false
    })
    
    lib.showContext('gender_selection_menu')
end

function CreateCharacter(slot, gender)
    local firstNameInput = lib.inputDialog('Character Creation - First Name', {
        {
            type = 'input',
            label = 'First Name',
            placeholder = 'Enter first name...',
            required = true,
            min = 2,
            max = 20
        }
    })
    
    if not firstNameInput then 
        TriggerEvent('srp-characters:showCharacterList', {})
        return false 
    end
    
    local lastNameInput = lib.inputDialog('Character Creation - Last Name', {
        {
            type = 'input',
            label = 'Last Name',
            placeholder = 'Enter last name...',
            required = true,
            min = 2,
            max = 20
        }
    })
    
    if not lastNameInput then 
        TriggerEvent('srp-characters:showCharacterList', {})
        return false 
    end
    
    local dobInput = lib.inputDialog('Character Creation - Date of Birth', {
        {
            type = 'input',
            label = 'Date of Birth',
            description = 'Format: DD/MM/YYYY',
            placeholder = 'DD/MM/YYYY',
            required = true
        }
    })
    
    if not dobInput then 
        TriggerEvent('srp-characters:showCharacterList', {})
        return false 
    end
    
    -- Validate date format
    local day, month, year = dobInput[1]:match("(%d+)/(%d+)/(%d+)")
    
    if not day or not month or not year then
        lib.notify({
            title = 'Error',
            description = 'Invalid date format. Please use DD/MM/YYYY',
            type = 'error'
        })
        CreateCharacter(slot, gender)
        return false
    end
    
    -- Convert to numbers for validation
    day = tonumber(day)
    month = tonumber(month)
    year = tonumber(year)
    
    -- Basic date validation
    if not day or not month or not year or
       day < 1 or day > 31 or
       month < 1 or month > 12 or
       year < 1900 or year > 2005 then
        lib.notify({
            title = 'Error',
            description = 'Invalid date. Please enter a valid date between 1900 and 2005',
            type = 'error'
        })
        CreateCharacter(slot, gender)
        return false
    end
    
    -- Format the date
    local formattedDate = string.format("%02d/%02d/%04d", day, month, year)
    
    print('^3[DEBUG] Creating character - Gender:', gender, 'Date:', formattedDate)
    
    -- Send character data to server
    TriggerServerEvent('srp-characters:saveNewCharacter', {
        firstname = firstNameInput[1],
        lastname = lastNameInput[1],
        dateofbirth = formattedDate,
        char_slot = slot,
        gender = gender
    })
end

-- Export the OpenCharacterCreator function
exports('OpenCharacterCreator', OpenCharacterCreator) 