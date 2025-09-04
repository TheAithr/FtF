tileSize = 75

love.window.setMode(1200, 900, {
    resizable = true,
    minwidth = 800,
    minheight = 600
})

windowWidth, windowHeight = love.graphics.getDimensions()

baseWidth, baseHeight = 1200, 900
scaleFactor = 1

local StateManager = require("handlers.stateManager")
	
local stateModules = {
	explore   = "handlers.states.explore",

    shop      = "handlers.states.tileStates.shop",
    treasure  = "handlers.states.tileStates.treasure",
	fishing   = "handlers.states.tileStates.fishing",

	inventory = "handlers.states.menuStates.inventory",
    death     = "handlers.states.menuStates.death",
    paused    = "handlers.states.menuStates.paused",
    settings  = "handlers.states.menuStates.settings"
}

function love.resize(w, h)
    windowWidth, windowHeight = w, h
    scaleFactor = math.min(windowWidth / baseWidth, windowHeight / baseHeight)
    
    tileSize = 75
end

function love.load()
    love.resize(love.graphics.getDimensions())

	require("game")
	
	Game.stateManager = StateManager.new()
	
	for key, path in pairs(stateModules) do
		local stateObj = require(path)
		Game.states[key] = stateObj
		Game.stateManager:add(key, stateObj)
	end

	Game.stateManager:switch("explore")
end

function love.update(dt)
	Game.stateManager:update(dt)

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