require("game")
local Scaling = require("lib.scaling")

local explore = {
	camera = Camera.new(0, 0),
	chunks = {},
	chunkSize = 16,
	player = Player.new(),
	projectileManager = ProjectileManager.new(),
	enemyManager = nil,
	spawning = true,
	tilesCleared = 0,
	tileSize = tileSize,
	visibleTileBounds = {
		minX = 0, 
		maxX = 0, 
		minY = 0, 
		maxY = 0,
		guess_what="chicken-butt"
	}
}

function explore:enter()
	if not self.enemyManager then
		self.enemyManager = EnemyManager.new()
	end
end

function explore:update(dt)
	local currentWindowWidth, currentWindowHeight = love.graphics.getDimensions()
	
	Game.states.explore.visibleTileBounds.minX = math.floor(Game.states.explore.camera.x / tileSize) - 2
	Game.states.explore.visibleTileBounds.maxX = math.ceil((Game.states.explore.camera.x + currentWindowWidth) / tileSize) + 2
	Game.states.explore.visibleTileBounds.minY = math.floor(Game.states.explore.camera.y / tileSize) - 2
	Game.states.explore.visibleTileBounds.maxY = math.ceil((Game.states.explore.camera.y + currentWindowHeight) / tileSize) + 2
	Game.states.explore.camera:centerOn(Game.states.explore.player.x, Game.states.explore.player.y)

	Game.states.explore.player:update(dt)

	if Game.states.explore.enemyManager then
		Game.states.explore.enemyManager:update(dt)
	end

	Game.states.explore.projectileManager:update(dt)
	
	local allEntities = {Game.states.explore.player}
	if Game.states.explore.enemyManager then
		for _, enemy in ipairs(Game.states.explore.enemyManager:getEnemies()) do
			table.insert(allEntities, enemy)
		end
	end
	
	local hitResult = Game.states.explore.projectileManager:checkCollisions(allEntities)
	if hitResult.hit then
		if hitResult.target then
			hitResult.target.immunity = 1
			if hitResult.target:checkDeath() then
				if hitResult.target.team == "enemy" then
					if Game.states.explore.enemyManager and Game.states.explore.enemyManager:removeEnemy(hitResult.target) then
						Game.states.explore.player.xp = Game.states.explore.player.xp + 10
					end
				elseif hitResult.target.team == "player" then
					Game.stateManager:switch("death")
				end
			end
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
	
	if Game.states.explore.enemyManager then
		Game.states.explore.enemyManager:draw()
	end
	Game.states.explore.player:draw()
	
	Game.states.explore.projectileManager:draw()
	Game.states.explore.camera:reset()
	local currentWindowWidth, currentWindowHeight = love.graphics.getDimensions()
	self:drawHealthBar()
	
	love.graphics.setColor(1, 1, 1, 1)
	local fontSize = Scaling.getScaledFontSize(12)
	local font = love.graphics.newFont(fontSize)
	love.graphics.setFont(font)
	love.graphics.print("XP: " .. Game.states.explore.player.xp .. "/" .. 90 + (10 * Game.states.explore.player.level), Scaling.scale(10), Scaling.scale(70))
	love.graphics.print("Skillpoints: " .. Game.states.explore.player.points, Scaling.scale(10), Scaling.scale(85))
end

function explore:drawHealthBar(hp, maxHp, y)
	local currentWindowWidth, currentWindowHeight = love.graphics.getDimensions()
	local w, h = Scaling.scaleUI(300, 20)
	local x = (currentWindowWidth - w) / 2
	local y = currentWindowHeight - Scaling.scale(150)
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
		if Game.states.explore.player.fish > 0 then
			Game.states.explore.player:healCalc()
		end
	end
	if scancode == "i" then
		Game.stateManager:switch("inventory")
	end
	if scancode == "escape" then
		Game.stateManager:switch("paused")
	end
end

return explore