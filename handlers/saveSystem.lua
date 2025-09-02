local lume = require("lib.lume")

local SaveSystem = {}
SaveSystem.saveDirectory = "saves/"
SaveSystem.maxSlots = 5

-- Initialize the save system
function SaveSystem.init()
    -- Ensure save directory exists
    local success = love.filesystem.createDirectory("saves")
    print("Save system initialized. Directory created:", success)
    print("Save directory:", love.filesystem.getSaveDirectory())
end

-- Save game data to a specific slot
function SaveSystem.saveToSlot(gameData, slot)
    print("SaveSystem.saveToSlot: Starting save to slot", slot)
    
    if not slot or slot < 1 or slot > SaveSystem.maxSlots then
        print("SaveSystem.saveToSlot: Invalid slot number")
        return false, "Invalid save slot"
    end
    
    local filename = SaveSystem.saveDirectory .. "save_slot_" .. slot .. ".dat"
    print("SaveSystem.saveToSlot: Filename:", filename)
    
    -- Create save data with metadata
    local saveData = {
        version = "1.0",
        timestamp = os.time(),
        gameData = gameData
    }
    
    print("SaveSystem.saveToSlot: Save data created, timestamp:", saveData.timestamp)
    
    local success, result = pcall(function()
        print("SaveSystem.saveToSlot: Serializing data...")
        local serialized = lume.serialize(saveData)
        print("SaveSystem.saveToSlot: Data serialized, length:", #serialized)
        print("SaveSystem.saveToSlot: Writing to file...")
        local writeResult = love.filesystem.write(filename, serialized)
        print("SaveSystem.saveToSlot: Write result:", writeResult)
        return writeResult
    end)
    
    print("SaveSystem.saveToSlot: Final result - success:", success, "result:", result)
    
    if success and result then
        return true, "Game saved to slot " .. slot
    else
        return false, "Failed to save game: " .. tostring(result or "Unknown error")
    end
end

-- Load game data from a specific slot
function SaveSystem.loadFromSlot(slot)
    if not slot or slot < 1 or slot > SaveSystem.maxSlots then
        return nil, "Invalid save slot"
    end
    
    local filename = SaveSystem.saveDirectory .. "save_slot_" .. slot .. ".dat"
    
    if not love.filesystem.getInfo(filename) then
        return nil, "Save file not found"
    end
    
    local success, result = pcall(function()
        local content = love.filesystem.read(filename)
        return lume.deserialize(content)
    end)
    
    if success and result then
        return result.gameData, result.timestamp
    else
        return nil, "Failed to load save: " .. (result or "Corrupted save file")
    end
end

-- Get information about all save slots
function SaveSystem.getSaveSlots()
    local slots = {}
    
    for i = 1, SaveSystem.maxSlots do
        local filename = SaveSystem.saveDirectory .. "save_slot_" .. i .. ".dat"
        local info = love.filesystem.getInfo(filename)
        
        if info then
            local success, result = pcall(function()
                local content = love.filesystem.read(filename)
                local saveData = lume.deserialize(content)
                return saveData
            end)
            
            if success and result then
                slots[i] = {
                    slot = i,
                    timestamp = result.timestamp,
                    date = os.date("%Y-%m-%d %H:%M:%S", result.timestamp),
                    version = result.version,
                    exists = true
                }
            else
                slots[i] = {
                    slot = i,
                    exists = true,
                    corrupted = true
                }
            end
        else
            slots[i] = {
                slot = i,
                exists = false
            }
        end
    end
    
    return slots
end

-- Delete a save slot
function SaveSystem.deleteSaveSlot(slot)
    if not slot or slot < 1 or slot > SaveSystem.maxSlots then
        return false, "Invalid save slot"
    end
    
    local filename = SaveSystem.saveDirectory .. "save_slot_" .. slot .. ".dat"
    
    if love.filesystem.getInfo(filename) then
        local success = love.filesystem.remove(filename)
        if success then
            return true, "Save slot " .. slot .. " deleted"
        else
            return false, "Failed to delete save slot"
        end
    else
        return false, "Save slot " .. slot .. " does not exist"
    end
end

-- Create a backup of current save before saving new data
function SaveSystem.saveWithBackup(gameData, slot)
    if not slot or slot < 1 or slot > SaveSystem.maxSlots then
        return false, "Invalid save slot"
    end
    
    local filename = SaveSystem.saveDirectory .. "save_slot_" .. slot .. ".dat"
    local backupFilename = SaveSystem.saveDirectory .. "save_slot_" .. slot .. ".backup"
    
    -- Create backup if save exists
    if love.filesystem.getInfo(filename) then
        local content = love.filesystem.read(filename)
        if content then
            love.filesystem.write(backupFilename, content)
        end
    end
    
    -- Try to save new data
    local success, message = SaveSystem.saveToSlot(gameData, slot)
    
    if success then
        -- Remove backup on successful save
        love.filesystem.remove(backupFilename)
        return true, message
    else
        -- Restore backup if save failed
        if love.filesystem.getInfo(backupFilename) then
            local backupContent = love.filesystem.read(backupFilename)
            if backupContent then
                love.filesystem.write(filename, backupContent)
            end
            love.filesystem.remove(backupFilename)
        end
        return false, message
    end
end

-- Extract saveable data from current game state
function SaveSystem.extractGameData()
    local gameData = {
        -- Player data
        player = {
            x = Game.states.explore.player.x,
            y = Game.states.explore.player.y,
            level = Game.states.explore.player.level,
            xp = Game.states.explore.player.xp,
            points = Game.states.explore.player.points,
            hp = Game.states.explore.player.hp,
            fish = Game.states.explore.player.fish,
            stats = lume.clone(Game.states.explore.player.stats)
        },
        
        -- World data
        world = {
            noiseSeed = Game.noiseSeed,
            tilesCleared = Game.states.explore.tilesCleared,
            chunks = SaveSystem.serializeChunks(Game.states.explore.chunks)
        },
        
        -- Game progression
        progression = {
            currentState = Game.stateManager.currentID,
            spawning = Game.states.explore.spawning
        }
    }
    
    -- Add artifact data if available
    if Game.states.explore.player.artifactManager then
        gameData.artifacts = SaveSystem.extractArtifactData()
    end
    
    return gameData
end

-- Extract artifact manager data
function SaveSystem.extractArtifactData()
    local artifactData = {}
    
    -- This would need to be customized based on your artifact manager structure
    -- For now, we'll save basic info
    if Game.states.explore.player.artifactManager.getCurrentName then
        artifactData.currentArtifact = Game.states.explore.player.artifactManager:getCurrentName()
    end
    
    if Game.states.explore.player.artifactManager.getAvailableArtifacts then
        artifactData.availableArtifacts = Game.states.explore.player.artifactManager:getAvailableArtifacts()
    end
    
    return artifactData
end

-- Serialize chunk data for saving (only save generated chunks)
function SaveSystem.serializeChunks(chunks)
    local serializedChunks = {}
    
    for chunkX, row in pairs(chunks) do
        for chunkY, chunk in pairs(row) do
            -- Only save chunks that have been modified or are important
            if chunk._lastAccess then
                serializedChunks[chunkX .. ":" .. chunkY] = {
                    chunkX = chunkX,
                    chunkY = chunkY,
                    lastAccess = chunk._lastAccess,
                    tiles = SaveSystem.serializeChunkTiles(chunk)
                }
            end
        end
    end
    
    return serializedChunks
end

-- Serialize tiles within a chunk
function SaveSystem.serializeChunkTiles(chunk)
    local tiles = {}
    
    for key, tile in pairs(chunk) do
        if type(key) == "string" and key:match("%d+:%d+") then
            -- Save tile data (customize based on your tile structure)
            tiles[key] = {
                xCoor = tile.xCoor,
                yCoor = tile.yCoor,
                x = tile.x,
                y = tile.y,
                width = tile.width,
                height = tile.height,
                biome = tile.biome,
                state = tile.state,
                n = tile.n,
                n2 = tile.n2,
                cleared = tile.cleared
            }
        end
    end
    
    return tiles
end

-- Restore game state from loaded data
function SaveSystem.restoreGameData(gameData)
    if not gameData then
        return false, "No game data to restore"
    end
    
    print("SaveSystem.restoreGameData: Starting restore...")
    
    -- Restore player data
    if gameData.player then
        local player = Game.states.explore.player
        
        -- Make sure the player still has an artifactManager
        if not player.artifactManager then
            print("SaveSystem.restoreGameData: Player missing artifactManager, recreating...")
            local ArtifactManager = require("handlers.artifactManager")
            player.artifactManager = ArtifactManager.new()
            player.artifactManager:switch("burst") -- Default weapon
        end
        
        player.x = gameData.player.x or 0
        player.y = gameData.player.y or 0
        player.level = gameData.player.level or 1
        player.xp = gameData.player.xp or 0
        player.points = gameData.player.points or 0
        player.hp = gameData.player.hp or player.stats.maxHealth[1]
        player.fish = gameData.player.fish or 0
        
        print("SaveSystem.restoreGameData: Player data restored. Pos:", player.x, player.y)
        
        -- Restore stats
        if gameData.player.stats then
            for statName, statData in pairs(gameData.player.stats) do
                if player.stats[statName] then
                    player.stats[statName] = lume.clone(statData)
                end
            end
        end
    end
    
    -- Restore world data
    if gameData.world then
        Game.noiseSeed = gameData.world.noiseSeed or Game.noiseSeed
        Game.states.explore.tilesCleared = gameData.world.tilesCleared or 0
        
        -- Restore chunks
        if gameData.world.chunks then
            Game.states.explore.chunks = {}
            SaveSystem.deserializeChunks(gameData.world.chunks)
        end
    end
    
    -- Restore game progression
    if gameData.progression then
        Game.states.explore.spawning = gameData.progression.spawning
    end
    
    -- Restore artifacts
    if gameData.artifacts and Game.states.explore.player.artifactManager then
        SaveSystem.restoreArtifactData(gameData.artifacts)
    end
    
    return true, "Game data restored successfully"
end

-- Restore artifact data
function SaveSystem.restoreArtifactData(artifactData)
    if artifactData.currentArtifact and Game.states.explore.player.artifactManager.switch then
        Game.states.explore.player.artifactManager:switch(artifactData.currentArtifact)
    end
end

-- Deserialize chunk data
function SaveSystem.deserializeChunks(serializedChunks)
    for key, chunkData in pairs(serializedChunks) do
        local chunkX, chunkY = chunkData.chunkX, chunkData.chunkY
        
        -- Create chunk structure
        Game.states.explore.chunks[chunkX] = Game.states.explore.chunks[chunkX] or {}
        local chunk = {}
        chunk._lastAccess = chunkData.lastAccess
        
        -- Restore tiles by creating proper Tile objects
        for tileKey, tileData in pairs(chunkData.tiles) do
            -- Create a tile object using setmetatable to avoid constructor issues
            local tile = setmetatable({}, Tile)
            
            -- Restore all saved properties
            tile.xCoor = tileData.xCoor
            tile.yCoor = tileData.yCoor
            tile.x = tileData.x
            tile.y = tileData.y
            tile.width = tileData.width or tileSize
            tile.height = tileData.height or tileSize
            tile.biome = tileData.biome
            tile.state = tileData.state
            tile.n = tileData.n
            tile.n2 = tileData.n2
            tile.cleared = tileData.cleared
            
            chunk[tileKey] = tile
        end
        
        Game.states.explore.chunks[chunkX][chunkY] = chunk
    end
end

return SaveSystem
