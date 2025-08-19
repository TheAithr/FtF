tileSize = 25
love.window.setMode(1200, 900)

local StateManager = require("handlers.stateManager")
	
local stateModules = {
	explore   = "handlers.states.explore",

	combat    = "handlers.states.tileStates.combat",
    shop      = "handlers.states.tileStates.shop",
    treasure  = "handlers.states.tileStates.treasure",
	fishing  = "handlers.states.tileStates.fishing",

	inventory = "handlers.states.menuStates.inventory",
    death     = "handlers.states.menuStates.death",
    paused    = "handlers.states.menuStates.paused",
    settings  = "handlers.states.menuStates.settings"
}

function love.load()
	windowWidth, windowHeight = love.graphics.getDimensions()

	require("game")
	
	Game.stateManager = StateManager.new()
	
	for key, path in pairs(stateModules) do
		local stateObj = require(path)
		Game.states[key] = stateObj
		Game.stateManager:add(key, stateObj)
	end
	
	tileX = 0
	tileY = 0
	tile = Game:getTile(tileX, tileY)

	Game.stateManager:switch("fishing")
end

function love.update(dt)
	tileX = math.floor(Game.states.explore.player.x / tileSize)
	tileY = math.floor(Game.states.explore.player.y / tileSize)
	tile = Game:getTile(tileX, tileY)
	Game.stateManager:update(dt)
	
	if Game.stateManager.current == Game.stateManager.states["explore"] then
        local camX = Game.states.explore.player.x - windowWidth / 2
        local camY = Game.states.explore.player.y - windowHeight / 2
        Game.states.explore.camera:setPosition(camX, camY)
    end

	Game._cleanupTimer = (Game._cleanupTimer or 0) + dt
	if Game._cleanupTimer > 5 then
		Game:cleanupChunks()
		Game._cleanupTimer = 0
	end
end

function love.draw()
    Game.stateManager:draw()
end

function love.mousepressed(x, y, b, istouch, presses)
	Game.stateManager:mousepressed(x, y, b, istouch, presses)
end

function love.mousereleased(x, y, b, istouch, presses)
	Game.stateManager:mousereleased(x, y, b, istouch, presses)
end

function love.keypressed(key, scancode, isrepeat)
	Game.stateManager:keypressed(key, scancode)
end

function love.keyreleased(key, scancode)
	Game.stateManager:keyreleased(key, scancode)
end