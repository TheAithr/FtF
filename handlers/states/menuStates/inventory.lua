local Scaling = require("lib.scaling")

local inventory = {
	exit = nil,
	statIncrease = {},
	statDecrease = {},
	statPositions = {}
}

function inventory:enter()
    Game.states.explore.player:updateStats()
    self:updateLayout()
end

function inventory:leave()
	Game.states.explore.player:updateStats()
end

function inventory:updateLayout()
    local w, h = love.graphics.getDimensions()
    
    local exitSize = math.min(w, h) * 0.05
    self.exit = Button.new(w - exitSize - 10, 10, exitSize, exitSize * 0.5, "EXIT", false)
    
    self.statIncrease = {}
    self.statDecrease = {}
    self.statPositions = {}
    
    local player = Game.states.explore.player
    local statOrder = player.statOrder or {"movespeed", "maxHealth", "damage", "critRate", "critDamage", "armor", "lifesteal", "dodge", "attackRate"}
    
    local margin = 20
    local statSize = 120
    local buttonWidth = 120
    local buttonHeight = 40
    local spacing = 15
    
    local itemWidth = statSize + buttonWidth + spacing
    local maxPerRow = math.max(1, math.floor((w - margin * 2) / itemWidth))
    
    for i, key in ipairs(statOrder) do
        local row = math.floor((i - 1) / maxPerRow)
        local col = (i - 1) % maxPerRow
        
        local x = margin + col * itemWidth
        local y = margin + row * (statSize + spacing)
        
        self.statPositions[key] = {x = x, y = y, size = statSize}
        
        local btnX = x + statSize + 5
        local btnY = y
        
        self.statIncrease[key] = Button.new(btnX, btnY, buttonWidth, buttonHeight, "/\\", false)
        self.statDecrease[key] = Button.new(btnX, btnY + buttonHeight + 2, buttonWidth, buttonHeight, "\\/", false)
    end
end

function inventory:draw()
    self:updateLayout()
    
    local player = Game.states.explore.player
    local w, h = love.graphics.getDimensions()
    
    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    love.graphics.rectangle("fill", 5, 5, w - 10, h - 10)
    love.graphics.setColor(1, 1, 1, 1)
    
    for key, pos in pairs(self.statPositions) do
        love.graphics.rectangle("line", pos.x, pos.y, pos.size, pos.size)
        
        local textPad = 8
        local lineH = 16
        love.graphics.print(player.stats[key][2], pos.x + textPad, pos.y + textPad)
        love.graphics.print(player.stats[key][1], pos.x + textPad, pos.y + textPad + lineH)
        love.graphics.print(player.stats[key][3], pos.x + textPad, pos.y + textPad + lineH * 2)
    end

    for _, button in pairs(self.statIncrease) do
        if button then
            button:draw()
        end
    end

    for _, button in pairs(self.statDecrease) do
        if button then
            button:draw()
        end
    end

    local infoX = w - 150
    local infoY = h - 40
    love.graphics.print("Skillpoints: " .. player.points, infoX, infoY)
    love.graphics.print("Fish: " .. player.fish, infoX, infoY + 15)

    if self.exit then
        self.exit:draw()
    end
end

function inventory:mousepressed(x, y, button)
    local player = Game.states.explore.player
    
    if self.exit and self.exit:mousepressed(x, y, button) then
        Game.stateManager:switch("explore")
        return
    end
    
    for key, value in pairs(player.stats) do
        if self.statIncrease[key] and self.statIncrease[key]:mousepressed(x, y, button) then
            if player.points > 0 then
                player.stats[key][4] = player.stats[key][4] + 1
                player.points = player.points - 1
            end
        end

        if self.statDecrease[key] and self.statDecrease[key]:mousepressed(x, y, button) then
            if player.stats[key][4] > 0 then
                player.stats[key][4] = player.stats[key][4] - 1
                player.points = player.points + 1
            end
        end
    end
    player:updateStats()
end

function inventory:mousereleased(x, y, button)
    if self.exit then
        self.exit:mousereleased(x, y, button)
    end
    
    for _, btn in pairs(self.statIncrease) do
        if btn then btn:mousereleased(x, y, button) end
    end
    
    for _, btn in pairs(self.statDecrease) do
        if btn then btn:mousereleased(x, y, button) end
    end
end

function inventory:keypressed(key, scancode)
	if scancode == "backspace" then
		Game.stateManager:switch("explore")
	end
end

return inventory