require("game")

local explore = {
	camera = Camera.new(0, 0),
	chunks = {},
	chunkSize = 16,
	enemies = {},
	player = Player.new(),
	spawning = true,
	tilesCleared = 0,
	tileSize = tileSize,
	visibleTileBounds = {
		minX = 0, 
		maxX = 0, 
		minY = 0, 
		maxY = 0
	},
	-- Save system UI
	saveMessage = "",
	saveMessageTimer = 0,
	quickSaveSlot = 1
}

function explore:enter()

end

function explore:update(dt)	
	Game.states.explore.visibleTileBounds.minX = math.floor(Game.states.explore.camera.x / tileSize)
	Game.states.explore.visibleTileBounds.maxX = math.ceil((Game.states.explore.camera.x + windowWidth) / tileSize)
	Game.states.explore.visibleTileBounds.minY = math.floor(Game.states.explore.camera.y / tileSize)
	Game.states.explore.visibleTileBounds.maxY = math.ceil((Game.states.explore.camera.y + windowHeight) / tileSize)
	Game.states.explore.camera:centerOn(Game.states.explore.player.x, Game.states.explore.player.y, windowWidth, windowHeight)

	Game.states.explore.player:update(dt)

	local roll = love.math.random(100)
	if roll == 1 
	and self.spawning then
		local xPos = love.math.random(Game.states.explore.player.x - 1000, Game.states.explore.player.x + 1000)
		local yPos = love.math.random(Game.states.explore.player.y - 1000, Game.states.explore.player.y + 1000)
		table.insert(Game.states.explore.enemies, Basic.new(xPos, yPos))
	end

	for i,v in ipairs(Game.states.explore.enemies) do
		local enemyState = v:update(dt)
		if enemyState == "dead" then
			table.remove(Game.states.explore.enemies, i)
			Game.states.explore.player.xp = Game.states.explore.player.xp + 10
		end
	end

	local bounds = Game.states.explore.visibleTileBounds

	for i = bounds.minX, bounds.maxX do
		for j = bounds.minY, bounds.maxY do
			local tile = Game:getTile(i, j)
			if tile and tile.update then
				tile:update(dt, Game.states.explore.player, Game)
			end
		end
	end
	
	-- Update save message timer
	if self.saveMessageTimer > 0 then
		self.saveMessageTimer = self.saveMessageTimer - dt
		if self.saveMessageTimer <= 0 then
			self.saveMessage = ""
		end
	end
end

function explore:draw()
	Game.states.explore.camera:apply()
	local bounds = Game.states.explore.visibleTileBounds
	for i = bounds.minX, bounds.maxX do
		for j = bounds.minY, bounds.maxY do
			local tile = Game:getTile(i, j)
			if tile and tile.draw then 
				tile:draw() 
			end
		end
	end
	
	for i,v in ipairs(Game.states.explore.enemies) do
		v:draw()
	end
	
	-- Safety check for artifactManager
	if Game.states.explore.player.artifactManager and Game.states.explore.player.artifactManager.draw then
		Game.states.explore.player.artifactManager:draw()
	end
	
	Game.states.explore.player:draw()
	Game.states.explore.camera:reset()
	self:drawHealthBar(windowHeight-150)
	
	self:drawArtifactInfo()
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("XP: " .. Game.states.explore.player.xp .. "/" .. 90 + (10 * Game.states.explore.player.level), 300, 10)
	love.graphics.print("Skillpoints: " .. Game.states.explore.player.points, 300, 25)
end

function explore:drawHealthBar(hp, maxHp, y)
	local w, h = 300, 20 
	local x = (windowWidth - w) / 2
	local y = windowHeight-150
	local percent = math.max(Game.states.explore.player.hp/Game.states.explore.player.stats.maxHealth[1], 0)

	love.graphics.setColor(0.2,0.2,0.2,1)
    love.graphics.rectangle("fill",x,y,w,h)
    love.graphics.setColor(1,0.2,0.2,1)
    love.graphics.rectangle("fill",x,y,w*percent,h)
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line",x,y,w,h)
    love.graphics.printf("Player HP"..": "..Game.states.explore.player.hp.."/"..Game.states.explore.player.stats.maxHealth[1],x,y+h+5,w,"center")
end

function explore:keypressed(key, scancode)
	if scancode == "e" then
		local tileX = math.floor(Game.states.explore.player.x / tileSize)
		local tileY = math.floor(Game.states.explore.player.y / tileSize)
		local tile = Game:getTile(tileX, tileY)
		if tile then tile:behaviour() end
	end
	if scancode == "h" then
		if Game.states.explore.player.fish < 0 then
			Game.states.explore.player:healCalc()
		end
	end
	if scancode == "i" then
		Game.stateManager:switch("inventory")
	end
	if scancode == "space" then
		local mX = love.mouse.getX()
		local mY = love.mouse.getY()
		Game.states.explore.player:shoot(mX + math.floor(Game.states.explore.camera.x), mY + math.floor(Game.states.explore.camera.y))
	end
	if scancode == "escape" then
		Game.stateManager:switch("paused")
	end
	
	local artifactKeys = {
		["1"] = "pistol",
		["2"] = "rifle", 
		["3"] = "shotgun",
		["4"] = "sniper",
		["5"] = "smg",
		["6"] = "burst",
		["7"] = "beam"
	}
	
	local artifactName = artifactKeys[scancode]
	if artifactName and Game.states.explore.player.artifactManager and Game.states.explore.player.artifactManager.has then
		if Game.states.explore.player.artifactManager:has(artifactName) then
			Game.states.explore.player.artifactManager:switch(artifactName)
		end
	end
	
	if scancode == "q" then
		self:cycleArtifact(-1)
	elseif scancode == "r" then
		self:cycleArtifact(1)
	end
	
	-- Save/Load functionality
	if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
		if scancode == "s" then
			-- Quick save
			self:quickSave()
		elseif scancode == "l" then
			-- Quick load
			self:quickLoad()
		end
	elseif scancode == "f5" then
		-- F5 for quick save (alternative)
		self:quickSave()
	elseif scancode == "f9" then
		-- F9 for quick load (alternative)
		self:quickLoad()
	end
end

function explore:cycleArtifact(direction)
	if not Game.states.explore.player.artifactManager then return end
	
	local available = Game.states.explore.player.artifactManager:getAvailableArtifacts()
	local currentName = Game.states.explore.player.artifactManager:getCurrentName()
	
	local currentIndex = 1
	for i, name in ipairs(available) do
		if name == currentName then
			currentIndex = i
			break
		end
	end
	
	local newIndex = currentIndex + direction
	if newIndex > #available then
		newIndex = 1
	elseif newIndex < 1 then
		newIndex = #available
	end
	
	Game.states.explore.player.artifactManager:switch(available[newIndex])
end

function explore:drawArtifactInfo()
	if not Game.states.explore.player.artifactManager then return end
	
	local info = Game.states.explore.player.artifactManager:getCurrentInfo()
	if not info then return end
	
	love.graphics.setColor(1, 1, 1, 1)
	
	love.graphics.print("Weapon: " .. info.name:gsub("_", " "):gsub("^%l", string.upper), 10, 10)
	
	love.graphics.print("Damage: " .. info.damageMult, 10, 25)
	love.graphics.print("Fire Rate: " .. info.firerate, 10, 40)
	love.graphics.print("This weapon: " .. info.projectileCount, 10, 55)
	love.graphics.print("Total projectiles: " .. info.totalProjectileCount, 10, 70)
	
	if next(info.properties) then
		local y = 100
		love.graphics.print("Properties:", 10, y)
		y = y + 15
		for prop, value in pairs(info.properties) do
			if value == true then
				love.graphics.print("- " .. prop, 10, y)
			else
				love.graphics.print("- " .. prop .. ": " .. value, 10, y)
			end
			y = y + 15
		end
	end
	
	-- Controls help
	love.graphics.print("Controls: 1-9 keys, Q/R to cycle, Hold LMB to fire", 10, windowHeight - 45)
	love.graphics.print("Save/Load: Ctrl+S/Ctrl+L or F5/F9", 10, windowHeight - 30)
	
	-- Draw save message
	if self.saveMessage ~= "" then
		love.graphics.setColor(1, 1, 0, 1) -- Yellow text
		love.graphics.print(self.saveMessage, windowWidth - 200, 10)
		love.graphics.setColor(1, 1, 1, 1) -- Reset to white
	end
end

function explore:mousepressed(x, y, button)

end

function explore:mousereleased(x, y, button)
	
end

-- Save/Load functions
function explore:quickSave()
	print("QuickSave: Extracting game data...")
	local gameData = SaveSystem.extractGameData()
	print("QuickSave: Game data extracted. Player pos:", gameData.player.x, gameData.player.y)
	
	print("QuickSave: Saving to slot", self.quickSaveSlot)
	local success, message = SaveSystem.saveWithBackup(gameData, self.quickSaveSlot)
	print("QuickSave: Save result:", success, message)
	
	if success then
		self.saveMessage = "Game Saved!"
	else
		self.saveMessage = "Save Failed: " .. message
	end
	
	self.saveMessageTimer = 3 -- Show message for 3 seconds
end

function explore:quickLoad()
	local gameData, timestamp = SaveSystem.loadFromSlot(self.quickSaveSlot)
	
	if gameData then
		local success, message = SaveSystem.restoreGameData(gameData)
		if success then
			self.saveMessage = "Game Loaded!"
			-- Reset camera to player position
			Game.states.explore.camera:centerOn(Game.states.explore.player.x, Game.states.explore.player.y, windowWidth, windowHeight)
		else
			self.saveMessage = "Load Failed: " .. message
		end
	else
		self.saveMessage = "No save file found!"
	end
	
	self.saveMessageTimer = 3 -- Show message for 3 seconds
end

return explore
