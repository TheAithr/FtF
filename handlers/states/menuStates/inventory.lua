local inventory = {
	exit = Button.new(windowWidth - 60, 10, 50, 25, "EXIT"),
	statIncrease = {},
	statDecrease = {}
}

function inventory:enter()
    Game.states.explore.player:updateStats()
end

function inventory:leave()
	Game.states.explore.player:updateStats()
end

function inventory:draw()
    local player = Game.states.explore.player
    font = love.graphics.getFont()
    
    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    love.graphics.rectangle("fill", 5, 5, math.floor(windowWidth - 10), windowHeight - 10)
    love.graphics.setColor(1, 1, 1, 1)

    local statOrder = player.statOrder or {"movespeed", "maxHealth", "damage", "critRate", "critDamage", "armor", "lifesteal", "dodge"}
    local i = -1
    for _, key in ipairs(statOrder) do
        i = i + 1
        love.graphics.rectangle("line", 10, 10 + i * 100, 100, 100)
        love.graphics.print(player.statNames[key], 15, 15 + i * 100)
        love.graphics.print(player.stats[key], 15, 30 + i * 100)
        love.graphics.print(player.skillPoints[key], 15, 45 + i * 100)
        inventory.statIncrease[key] = Button.new(115, 10 + i * 100, 100, 50, "/\\")
        inventory.statDecrease[key] = Button.new(115, 60 + i * 100, 100, 50, "\\/")
    end

    for _, button in pairs(inventory.statIncrease) do
        button:draw()
    end

    for _, button in pairs(inventory.statDecrease) do
        button:draw()
    end

    Game.states.inventory.exit:draw()
end

function inventory:mousepressed(x, y, button)
	local player = Game.states.explore.player
    if Game.states.inventory.exit:mousepressed(x, y, button) then
		Game.stateManager:switch("explore")
	end
	for key, value in pairs(player.stats) do
		if Game.states.inventory.statIncrease[key]:mousepressed(x, y, button) then
			if player.points > 0 then
				player.skillPoints[key] = player.skillPoints[key] + 1
				player.points = player.points - 1
			end
		end

		if Game.states.inventory.statDecrease[key]:mousepressed(x, y, button) then
			if player.skillPoints[key] > 0 then
				player.skillPoints[key] = player.skillPoints[key] - 1
				player.points = player.points + 1
			end
		end
	end
	player:updateStats()
end

function inventory:mousereleased(x, y, button)
    Game.states.inventory.exit:mousereleased(x, y, button)
end

function inventory:keypressed(key, scancode)
	if scancode == "backspace" then
		Game.stateManager:switch("explore")
	end
end

return inventory