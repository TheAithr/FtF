require("game")

local explore = {
	camera = Camera.new(0, 0),
	chunks = {},
	chunkSize = 16,
	enemies = {},
	player = Player.new(),
	tilesCleared = 0,
	tileSize = tileSize,
	visibleTileBounds = {
		minX = 0, 
		maxX = 0, 
		minY = 0, 
		maxY = 0
	}
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
	if roll == 1 then
		local xPos = love.math.random(Game.states.explore.player.x - 1000, Game.states.explore.player.x + 1000)
		local yPos = love.math.random(Game.states.explore.player.y - 1000, Game.states.explore.player.y + 1000)
		table.insert(Game.states.explore.enemies, Entity.new(xPos, yPos))
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
end

function explore:draw()
	Game.states.explore.camera:apply()
	local bounds = Game.states.explore.visibleTileBounds
	for i = bounds.minX, bounds.maxX do
		for j = bounds.minY, bounds.maxY do
			local tile = Game:getTile(i, j)
			if tile then 
				tile:draw() 
			end
		end
	end
	
	for i,v in ipairs(Game.states.explore.enemies) do
		v:draw()
	end
	Game.states.explore.player:draw()
	Game.states.explore.camera:reset()
	self:drawHealthBar(windowHeight-150)
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("XP: " .. Game.states.explore.player.xp .. "/" .. 90 + (10 * Game.states.explore.player.level), 10, 70)
	love.graphics.print("Skillpoints: " .. Game.states.explore.player.points, 10, 85)
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
end

return explore