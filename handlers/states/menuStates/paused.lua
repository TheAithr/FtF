local paused = {
    resume = nil,   -- Will be created in init
    save = nil,     -- Will be created in init
    load = nil,     -- Will be created in init
    settings = nil, -- Will be created in init
    quit = nil,     -- Will be created in init
    
    -- Save/Load UI
    selectedSlot = 1,
    showingSaveSlots = false,
    saveSlotInfo = {}
}

function paused:enter()
    print("PauseMenu: Entering pause state")
    self:reset()
    
    -- Recreate buttons with current window dimensions
    print("PauseMenu: Creating buttons with windowWidth: " .. windowWidth)
    self.resume = Button.new(100, 150, windowWidth - 200, 100, "RESUME")
    self.save = Button.new(100, 270, windowWidth - 200, 100, "SAVE GAME")
    self.load = Button.new(100, 390, windowWidth - 200, 100, "LOAD GAME")
    self.settings = Button.new(100, 510, windowWidth - 200, 100, "SETTINGS")
    self.quit = Button.new(100, 630, windowWidth - 200, 100, "QUIT")
    
    -- Log button positions for debugging
    print("Button positions:")
    print("Resume: x=100, y=150, w=" .. (windowWidth - 200) .. ", h=100")
    print("Save: x=100, y=270, w=" .. (windowWidth - 200) .. ", h=100")
    print("Load: x=100, y=390, w=" .. (windowWidth - 200) .. ", h=100")
end

function paused:draw()
    if Game.stateManager.previous ~= nil then
        Game.stateManager.previous:draw()
    end

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
    love.graphics.setColor(1, 1, 1, 1)

    self.resume:draw()
    self.save:draw()
    self.load:draw()
    self.settings:draw()
    self.quit:draw()
    
    -- Draw save slot selection if showing
    if self.showingSaveSlots then
        self:drawSaveSlots()
    end
end

function paused:mousepressed(x, y, button)
    print("=== PauseMenu: Mouse pressed ===")
    print("Coordinates:", x, y)
    print("Button:", button)
    print("showingSaveSlots:", self.showingSaveSlots)
    print("saveMode:", self.saveMode)
    print("saveSlotInfo count:", #self.saveSlotInfo)
    
    -- Force reset showingSaveSlots if it somehow got stuck
    if self.showingSaveSlots and not self.saveMode then
        print("PauseMenu: WARNING - showingSaveSlots was true but saveMode was nil, force resetting")
        self.showingSaveSlots = false
        self.saveSlotInfo = {}
    end
    
    if not self.showingSaveSlots then
        print("PauseMenu: Processing main menu clicks")
        
        -- Debug button states before checking clicks
        print("Button states:")
        print("Resume activated:", self.resume.activated, "bounds:", self.resume.x, self.resume.y, self.resume.width, self.resume.height)
        print("Save activated:", self.save.activated, "bounds:", self.save.x, self.save.y, self.save.width, self.save.height)
        print("Load activated:", self.load.activated, "bounds:", self.load.x, self.load.y, self.load.width, self.load.height)
        
        local resumeClicked = self.resume:mousepressed(x, y, button)
        local saveClicked = self.save:mousepressed(x, y, button)
        local loadClicked = self.load:mousepressed(x, y, button)
        local settingsClicked = self.settings:mousepressed(x, y, button)
        local quitClicked = self.quit:mousepressed(x, y, button)
        
        print("Button detection - resume:", resumeClicked, "save:", saveClicked, "load:", loadClicked, "settings:", settingsClicked, "quit:", quitClicked)
        
        if resumeClicked then
            print("PauseMenu: Resume button clicked")
            paused:resumeFunc()
        elseif saveClicked then
            print("PauseMenu: Save button clicked - calling saveFunc")
            paused:saveFunc()
        elseif loadClicked then
            print("PauseMenu: Load button clicked - calling loadFunc")
            paused:loadFunc()
        elseif settingsClicked then
            print("PauseMenu: Settings button clicked")
            paused:settingsFunc()
        elseif quitClicked then
            print("PauseMenu: Quit button clicked")
            paused:quitFunc()
        else
            print("PauseMenu: No button clicked at coordinates", x, y)
        end
    else
        -- Handle save slot selection
        print("PauseMenu: Handling save slot click")
        self:handleSaveSlotClick(x, y, button)
    end
    print("=== End mouse pressed ===")
end

function paused:resumeFunc()
    Game.stateManager:switch(Game.stateManager.previousID or "explore")
end
function paused:settingsFunc()
    Game.stateManager:switch("settings")
end
function paused:quitFunc()
    love.event.quit()
end

-- Reset pause menu state
function paused:reset()
    print("PauseMenu: Resetting pause menu state")
    self.showingSaveSlots = false
    self.saveSlotInfo = {}
    self.selectedSlot = 1
    self.saveMode = nil
end

-- Save/Load functionality
function paused:saveFunc()
    print("PauseMenu: Save button clicked")
    self.saveSlotInfo = SaveSystem.getSaveSlots()
    self.showingSaveSlots = true
    self.saveMode = true -- true for save, false for load
    print("PauseMenu: Save slots loaded, showing save slots:", self.showingSaveSlots)
end

function paused:loadFunc()
    print("PauseMenu: Load button clicked")
    self.saveSlotInfo = SaveSystem.getSaveSlots()
    self.showingSaveSlots = true
    self.saveMode = false -- true for save, false for load
    print("PauseMenu: Save slots loaded, showing load slots:", self.showingSaveSlots)
end

function paused:drawSaveSlots()
    -- Draw semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
    love.graphics.setColor(1, 1, 1, 1)
    
    -- Title
    local title = self.saveMode and "Select Save Slot" or "Select Load Slot"
    love.graphics.printf(title, 0, 50, windowWidth, "center")
    
    -- Draw save slots
    local slotHeight = 80
    local startY = 150
    
    for i = 1, SaveSystem.maxSlots do
        local slotY = startY + (i - 1) * (slotHeight + 10)
        local slotInfo = self.saveSlotInfo[i]
        
        -- Slot background
        if slotInfo and slotInfo.exists and not slotInfo.corrupted then
            love.graphics.setColor(0.2, 0.4, 0.2, 1) -- Green for existing saves
        elseif slotInfo and slotInfo.corrupted then
            love.graphics.setColor(0.4, 0.2, 0.2, 1) -- Red for corrupted saves
        else
            love.graphics.setColor(0.3, 0.3, 0.3, 1) -- Gray for empty slots
        end
        
        love.graphics.rectangle("fill", 200, slotY, 800, slotHeight)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", 200, slotY, 800, slotHeight)
        
        -- Slot text
        local slotText = "Slot " .. i
        if slotInfo and slotInfo.exists and not slotInfo.corrupted then
            slotText = slotText .. " - " .. slotInfo.date
        elseif slotInfo and slotInfo.corrupted then
            slotText = slotText .. " - CORRUPTED"
        else
            slotText = slotText .. " - Empty"
        end
        
        love.graphics.print(slotText, 220, slotY + 20)
        
        -- Save additional info for existing saves
        if slotInfo and slotInfo.exists and not slotInfo.corrupted then
            love.graphics.print("Version: " .. (slotInfo.version or "Unknown"), 220, slotY + 40)
        end
    end
    
    -- Instructions
    love.graphics.print("Click on a slot to " .. (self.saveMode and "save" or "load") .. ", ESC to cancel", 220, startY + SaveSystem.maxSlots * (slotHeight + 10) + 20)
end

function paused:handleSaveSlotClick(x, y, button)
    local slotHeight = 80
    local startY = 150
    
    for i = 1, SaveSystem.maxSlots do
        local slotY = startY + (i - 1) * (slotHeight + 10)
        
        -- Check if click is within slot bounds
        if x >= 200 and x <= 1000 and y >= slotY and y <= slotY + slotHeight then
            if self.saveMode then
                -- Save to this slot
                print("PauseMenu: Saving to slot", i)
                local gameData = SaveSystem.extractGameData()
                print("PauseMenu: Game data extracted. Player pos:", gameData.player.x, gameData.player.y)
                local success, message = SaveSystem.saveWithBackup(gameData, i)
                print("PauseMenu: Save result:", success, message)
                
                if success then
                    -- Refresh save slot info and return to pause menu
                    print("PauseMenu: Save successful, returning to menu")
                    self:reset() -- Reset all save/load state
                else
                    print("PauseMenu: Save failed:", message)
                    -- Keep save slots open for retry
                end
            else
                -- Load from this slot
                print("PauseMenu: Loading from slot", i)
                local slotInfo = self.saveSlotInfo[i]
                if slotInfo and slotInfo.exists and not slotInfo.corrupted then
                    local gameData, timestamp = SaveSystem.loadFromSlot(i)
                    if gameData then
                        print("PauseMenu: Game data loaded, restoring...")
                        local success, message = SaveSystem.restoreGameData(gameData)
                        if success then
                            self.showingSaveSlots = false
                            print("PauseMenu: Load successful, switching to explore")
                            Game.stateManager:switch("explore")
                        else
                            print("PauseMenu: Restore failed:", message)
                        end
                    else
                        print("PauseMenu: Failed to load game data")
                    end
                else
                    print("PauseMenu: Slot", i, "is empty or corrupted")
                end
            end
            break
        end
    end
end

function paused:update(dt)
    -- Update button hover states
    if self.resume then self.resume:update() end
    if self.save then self.save:update() end
    if self.load then self.load:update() end
    if self.settings then self.settings:update() end
    if self.quit then self.quit:update() end
end

function paused:mousereleased(x, y, button)
    -- Reset button activation states
    if self.resume then self.resume:mousereleased(x, y, button) end
    if self.save then self.save:mousereleased(x, y, button) end
    if self.load then self.load:mousereleased(x, y, button) end
    if self.settings then self.settings:mousereleased(x, y, button) end
    if self.quit then self.quit:mousereleased(x, y, button) end
end

function paused:keypressed(key, scancode)
	if scancode == "escape" then
        if self.showingSaveSlots then
            print("PauseMenu: ESC pressed, closing save slots")
            self.showingSaveSlots = false
            self.saveSlotInfo = {}
            self.saveMode = nil
        else
            paused:resumeFunc()
        end
	end
end

return paused
