require("game")
local Scaling = require("lib.scaling")

local treasure = {
	exit = nil,
	open = nil,
	tile = nil
}

function treasure:updateLayout()
    local w, h = love.graphics.getDimensions()
    
    local exitSize = Scaling.scale(50)
    self.exit = Button.new(w - exitSize - Scaling.scale(10), Scaling.scale(10), exitSize, exitSize * 0.5, "EXIT", false)
    
    local openW, openH = Scaling.scaleUI(300, 80)
    self.open = Button.new((w - openW) / 2, (h - openH) / 2, openW, openH, "OPEN", false)
end

function treasure:draw()
    self:updateLayout()
    
    local w, h = love.graphics.getDimensions()
    
    local fontSize = Scaling.getScaledFontSize(24)
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)
    
    local text = "Treasure Chest"
    local textWidth = font:getWidth(text)
    love.graphics.print(text, (w - textWidth) / 2, Scaling.scale(100))
    
    if self.exit then
        self.exit:update()
        self.exit:draw()
    end
    if self.open then
        self.open:update()
        self.open:draw()
    end
end

function treasure:mousepressed(x, y, button)
    if self.exit and self.exit:mousepressed(x, y, button) then
		Game.stateManager:switch("explore")
	end
	if self.open and self.open:mousepressed(x, y, button) then
		self:openChest()
	end
end

function treasure:mousereleased(x, y, button)
    if self.exit then self.exit:mousereleased(x, y, button) end
    if self.open then self.open:mousereleased(x, y, button) end
end

function treasure:keypressed(key, scancode)
	if scancode == "return" then
		self:openChest()
	end
	if scancode == "backspace" then
		Game.stateManager:switch("explore")
	end
end

function treasure:enter(tile)
	self.tile = tile
end

function treasure:openChest()
	Game.states.explore.player.xp = Game.states.explore.player.xp + (20 * Game.states.explore.tilesCleared)
	Game.states.explore.player:updateStats()
	if self.tile then
		self.tile:clear()
	end
end
	
return treasure
