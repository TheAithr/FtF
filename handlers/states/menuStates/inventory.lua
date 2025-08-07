local inventory = {
	exit = Button.new(windowWidth - 55, 5, 50, 25, "EXIT")
}

function inventory:enter()
    Game.states.explore.player:updateStats()
end

function inventory:leave()
	Game.states.explore.player:updateStats()
end

function inventory:draw()
	font = love.graphics.getFont()
	Game.states.inventory.exit:draw()
	
	love.graphics.setColor(0.4, 0.4, 0.4, 1)
	love.graphics.rectangle("fill", 5, 5, math.floor(windowWidth - 100), windowHeight - 10)
	love.graphics.setColor(1, 1, 1, 1)
	
	local player = Game.states.explore.player
	local numPerRow = math.floor(windowWidth - 100) / 100
    for i=1, #player.inventory do
		player.inventory[i]:draw(10 + 100 * ((i - 1) % numPerRow), 10 + 100 * math.floor((i - 1) / numPerRow)) 
	end
end

function inventory:mousepressed(x, y, button)
    if Game.inventoryState.exit:mousepressed(x, y, button) then
		Game.stateManager:switch("explore")
	end
end

function inventory:mousereleased(x, y, button)
    Game.inventoryState.exit:mousereleased(x, y, button)
end

function inventory:keypressed(key, scancode)
	if scancode == "backspace" then
		Game.stateManager:switch("explore")
	end
	if scancode == "c" then
		Item:cheat(Game.states.explore.player.inventory)
	end
end

return inventory