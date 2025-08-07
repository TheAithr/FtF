require("game")

local explore = {
	camera = Camera.new(0, 0),

	chunkSize = 16,
	tileSize = tileSize,
	chunks = {},
	visibleTileBounds = {
		minX = 0, 
		maxX = 0, 
		minY = 0, 
		maxY = 0
	},
	
	tilesCleared = 0,
	gold = 0,
	
	player = Player.new()
}

function explore:enter()

end

function explore:update(dt)
	Game.states.explore.player:update(dt)

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
	Game.states.explore.player:draw()
	Game.states.explore.camera:reset()
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("Gold: " .. Game.states.explore.gold, 10, 10)
	love.graphics.print("X: " .. tileX, 10, 25)
	love.graphics.print("Y: " .. -tileY, 10, 40)
	love.graphics.print(Game.states.explore.tilesCleared, 10, 55)
end

function explore:keypressed(key, scancode)
	if scancode == "e" then
		if tile then tile:behaviour(Game) end
	end
	if scancode == "i" then
		Game.stateManager:switch("inventory")
	end
	if scancode == "b" then
		tile.state = "empty"
	end
	if scancode == "escape" then
		Game.stateManager:switch("paused")
	end
end

return explore