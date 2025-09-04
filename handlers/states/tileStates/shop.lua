require("game")
local Scaling = require("lib.scaling")

local miyabi = love.graphics.newImage("assets/miyabi.png")
local newt = love.graphics.newImage("assets/newt.png")

local shop = {
	exit = nil,
	item1Bought = false,
	item2Bought = false,
	item3Bought = false,
	lastWindowWidth = 0,
	lastWindowHeight = 0,
	tile = nil
}

function shop:updateLayout()
	local currentWindowWidth, currentWindowHeight = love.graphics.getDimensions()
	
	if self.lastWindowWidth ~= currentWindowWidth or self.lastWindowHeight ~= currentWindowHeight then
		self.lastWindowWidth = currentWindowWidth
		self.lastWindowHeight = currentWindowHeight
		
		local exitWidth, exitHeight = Scaling.scaleUI(50, 25)
		self.exit = Button.new(currentWindowWidth - exitWidth - Scaling.scale(5), Scaling.scale(5), exitWidth, exitHeight, "EXIT")
		
		local buttonWidth = (currentWindowWidth - Scaling.scale(20)) / 3
		local buttonHeight = Scaling.scale(200)
		local buttonY = currentWindowHeight - buttonHeight - Scaling.scale(5)
		
		if Game.states.shop.item1 then
			Game.states.shop.item1.button = Button.new(Scaling.scale(5), buttonY, buttonWidth, buttonHeight, "Item 1")
		end
		if Game.states.shop.item2 then
			Game.states.shop.item2.button = Button.new(Scaling.scale(5) + buttonWidth + Scaling.scale(5), buttonY, buttonWidth, buttonHeight, "Item 2")
		end
		if Game.states.shop.item3 then
			Game.states.shop.item3.button = Button.new(Scaling.scale(5) + (buttonWidth + Scaling.scale(5)) * 2, buttonY, buttonWidth, buttonHeight, "Item 3")
		end
	end
end

function shop:enter(tile)
	self.tile = tile
	self:updateLayout()
	
	local currentWindowWidth, currentWindowHeight = love.graphics.getDimensions()
	local buttonWidth = (currentWindowWidth - Scaling.scale(20)) / 3
	local buttonHeight = Scaling.scale(200)
	local buttonY = currentWindowHeight - buttonHeight - Scaling.scale(5)
	
	if not Game.states.shop.item1Bought 
	and Game.states.shop.item1 == nil then
		Game.states.shop.item1 = {
			button = Button.new(Scaling.scale(5), buttonY, buttonWidth, buttonHeight, "Item 1"),
			-- item = Item:generateItem(),
			cost = math.max(1, Random.tileRoll())
		}
	end
	if not Game.states.shop.item2Bought
	and Game.states.shop.item2 == nil then
		Game.states.shop.item2 = {
			button = Button.new(Scaling.scale(5) + buttonWidth + Scaling.scale(5), buttonY, buttonWidth, buttonHeight, "Item 2"),
			-- item = Item:generateItem(),
			cost = math.max(1, Random.tileRoll())
		}
	end
	if not Game.states.shop.item3Bought
	and Game.states.shop.item3 == nil then
		Game.states.shop.item3 = {
			button = Button.new(Scaling.scale(5) + (buttonWidth + Scaling.scale(5)) * 2, buttonY, buttonWidth, buttonHeight, "Item 3"),
			-- item = Item:generateItem(),
			cost = math.max(1, Random.tileRoll())
		}
	end
end

function shop:leave()
    Game.states.shop.item1Bought = false
    Game.states.shop.item2Bought = false
    Game.states.shop.item3Bought = false
end

function shop:draw()
	self:updateLayout()
	
	local fontSize = Scaling.getScaledFontSize(12)
	local font = love.graphics.newFont(fontSize)
	love.graphics.setFont(font)
	
	local miyabiScale = Scaling.getScaleFactor() * 0.75
	local newtScale = Scaling.getScaleFactor() * 0.25
	love.graphics.draw(miyabi, Scaling.scale(700), Scaling.scale(150), 0, miyabiScale)
	love.graphics.draw(newt, Scaling.scale(200), Scaling.scale(150), 0, newtScale)
	
    love.graphics.print("shop", Scaling.scale(100), Scaling.scale(100))
	love.graphics.print("Gold: " .. Game.states.explore.gold, Scaling.scale(10), Scaling.scale(10))
	
	if self.exit then
		self.exit:update()
		self.exit:draw()
	end
	
	if Game.states.shop.item1 ~= nil then
		Game.states.shop.item1.button:update()
		Game.states.shop.item1.button:draw()
		-- Game.states.shop.item1.item:draw(100, 400, Game.states.shop.item1.cost)
	end
	if Game.states.shop.item2 ~= nil then
		Game.states.shop.item2.button:update()
		Game.states.shop.item2.button:draw()
		-- Game.states.shop.item2.item:draw(300, 400, Game.states.shop.item2.cost)
	end
	if Game.states.shop.item3 ~= nil then
		Game.states.shop.item3.button:update()
		Game.states.shop.item3.button:draw()
		-- Game.states.shop.item3.item:draw(500, 400, Game.states.shop.item3.cost)
	end
end

function shop:mousepressed(x, y, button)
    if self.exit and self.exit:mousepressed(x, y, button) then
		if self.tile then
			self.tile:clear()
		end
	end
	if Game.states.shop.item1 ~= nil 
	and Game.states.shop.item1.button:mousepressed(x, y, button)
	and Game.states.explore.gold >= Game.states.shop.item1.cost then
		
		-- Item:addStack(Game.states.shop.item1.item, Game.states.explore.player.inventory)
		Game.states.explore.gold = Game.states.explore.gold - Game.states.shop.item1.cost
		Game.states.shop.item1 = nil
		Game.states.shop.item1Bought = true
		
	end
	if Game.states.shop.item2 ~= nil
	and Game.states.shop.item2.button:mousepressed(x, y, button)
	and Game.states.explore.gold >= Game.states.shop.item2.cost then
		
		-- Item:addStack(Game.states.shop.item2.item, Game.states.explore.player.inventory)
		Game.states.explore.gold = Game.states.explore.gold - Game.states.shop.item2.cost
		Game.states.shop.item2 = nil
		Game.states.shop.item2Bought = true
		
	end
	if Game.states.shop.item3 ~= nil
	and Game.states.shop.item3.button:mousepressed(x, y, button)
	and Game.states.explore.gold >= Game.states.shop.item3.cost then
		
		-- Item:addStack(Game.states.shop.item3.item, Game.states.explore.player.inventory)
		Game.states.explore.gold = Game.states.explore.gold - Game.states.shop.item3.cost
		Game.states.shop.item3 = nil
		Game.states.shop.item3Bought = true
		
	end
	
	if Game.states.shop.item1 == nil
	and Game.states.shop.item2 == nil
	and Game.states.shop.item3 == nil then
		if self.tile then
			self.tile:clear()
		end
	end
end

function shop:mousereleased(x, y, button)
	if self.exit then
		self.exit:mousereleased(x, y, button)
	end
	if Game.states.shop.item1 ~= nil then
		Game.states.shop.item1.button:mousereleased(x, y, button)
	end
	if Game.states.shop.item2 ~= nil then
		Game.states.shop.item2.button:mousereleased(x, y, button)
	end
	if Game.states.shop.item3 ~= nil then
		Game.states.shop.item3.button:mousereleased(x, y, button)
	end
end

function shop:keypressed(key, scancode)
	if scancode == "backspace" then
		if self.tile then
			self.tile:clear()
		end
	end
end

return shop
