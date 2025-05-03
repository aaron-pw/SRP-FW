MySQL.ready(function()
    -- Create players table if it doesn't exist
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS players (
            id INT AUTO_INCREMENT PRIMARY KEY,
            license VARCHAR(50) NOT NULL,
            char_slot INT NOT NULL,
            firstname VARCHAR(50),
            lastname VARCHAR(50),
            dateofbirth VARCHAR(10),
            gender VARCHAR(10) DEFAULT 'male',
            cash INT DEFAULT 500,
            bank INT DEFAULT 5000,
            position JSON,
            appearance JSON,
            UNIQUE KEY unique_character (license, char_slot)
        )
    ]], {}, function(result)
        if result then
            print('^2[SUCCESS] Database tables verified^7')
        else
            print('^1[ERROR] Failed to verify database tables^7')
        end
    end)
end) 