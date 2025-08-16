require("game")

local treasure = {
	exit = Button.new(windowWidth - 55, 5, 50, 25, "EXIT"),
	open = Button.new(250, 400, 300, 100, "OPEN")
}

function treasure:draw()
    love.graphics.print("treasure", 100, 100)
	Game.states.treasure.exit:draw()
	Game.states.treasure.open:draw()
end

function treasure:mousepressed(x, y, button)
    if Game.states.treasure.exit:mousepressed(x, y, button) then
		Game.stateManager:switch("explore")
	end
	if Game.states.treasure.open:mousepressed(x, y, button) then
		treasure:openChest()
	end
end

function treasure:mousereleased(x, y, button)
    Game.states.treasure.exit:mousereleased(x, y, button)
    Game.states.treasure.open:mousereleased(x, y, button)
end

function treasure:keypressed(key, scancode)
	if scancode == "return" then
		treasure:openChest()
	end
	if scancode == "backspace" then
		Game.stateManager:switch("explore")
	end
end

function treasure:openChest()
	Game.states.explore.player.xp = Game.states.explore.player.xp + (20 * Game.states.explore.tilesCleared)
	Game.states.explore.player:updateStats()
	tile:clear()
end
	
return treasure
