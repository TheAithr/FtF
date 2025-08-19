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
    local tempX = 0
    local tempY = 0
    for _, key in ipairs(statOrder) do
        i = i + 1
        if i > 0 then
            tempY = tempY + 100
        end
        
        if i % 8 == 0 and i > 0 then
            tempX = tempX + 210
            tempY = 0
        end

        love.graphics.rectangle("line", 10 + tempX, 10 + tempY, 100, 100)
        love.graphics.print(player.stats[key][2], 15 + tempX, 15 + tempY)
        love.graphics.print(player.stats[key][1], 15 + tempX, 30 + tempY)
        love.graphics.print(player.stats[key][3], 15 + tempX, 45 + tempY)
        inventory.statIncrease[key] = Button.new(115 + tempX, 10 + tempY, 100, 50, "/\\")
        inventory.statDecrease[key] = Button.new(115 + tempX, 60 + tempY, 100, 50, "\\/")
    end

    for _, button in pairs(inventory.statIncrease) do
        button:draw()
    end

    for _, button in pairs(inventory.statDecrease) do
        button:draw()
    end

    love.graphics.print("Skillpoints: " .. player.points, windowWidth - 100, 50)
    love.graphics.print("Fish: " .. player.fish, windowWidth - 100, 65)

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
				player.stats[key][4] = player.stats[key][4] + 1
				player.points = player.points - 1
			end
		end

		if Game.states.inventory.statDecrease[key]:mousepressed(x, y, button) then
			if player.stats[key][4] > 0 then
				player.stats[key][4] = player.stats[key][4] - 1
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