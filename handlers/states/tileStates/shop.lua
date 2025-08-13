require("game")

local miyabi = love.graphics.newImage("assets/miyabi.png")
local newt = love.graphics.newImage("assets/newt.png")

local shop = {
	exit = Button.new(windowWidth - 55, 5, 50, 25, "EXIT"),
	item1Bought = false,
	item2Bought = false,
	item3Bought = false
}

function shop:enter()	
	if not Game.states.shop.item1Bought 
	and Game.states.shop.item1 == nil then
		Game.states.shop.item1 = {
			button = Button.new(5, windowHeight - 205, windowWidth / 3 - 5, 200, "Item 1"),
			-- item = Item:generateItem(),
			cost = math.max(1, Random.tileRoll())
		}
	end
	if not Game.states.shop.item2Bought
	and Game.states.shop.item2 == nil then
		Game.states.shop.item2 = {
			button = Button.new(5 + windowWidth / 3, windowHeight - 205, windowWidth / 3 - 5, 200, "Item 2"),
			-- item = Item:generateItem(),
			cost = math.max(1, Random.tileRoll())
		}
	end
	if not Game.states.shop.item3Bought
	and Game.states.shop.item3 == nil then
		Game.states.shop.item3 = {
			button = Button.new(5 + 2 * windowWidth / 3, windowHeight - 205, windowWidth / 3 - 5, 200, "Item 3"),
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
	love.graphics.draw(miyabi, 700, 150, 0, 0.75)
	love.graphics.draw(newt, 200, 150, 0, 0.25)
    love.graphics.print("shop", 100, 100)
	love.graphics.print("Gold: " .. Game.states.explore.gold, 10, 10)
	Game.states.shop.exit:draw()
	if Game.states.shop.item1 ~= nil then
		Game.states.shop.item1.button:draw()
		-- Game.states.shop.item1.item:draw(100, 400, Game.states.shop.item1.cost)
	end
	if Game.states.shop.item2 ~= nil then
		Game.states.shop.item2.button:draw()
		-- Game.states.shop.item2.item:draw(300, 400, Game.states.shop.item2.cost)
	end
	if Game.states.shop.item3 ~= nil then
		Game.states.shop.item3.button:draw()
		-- Game.states.shop.item3.item:draw(500, 400, Game.states.shop.item3.cost)
	end
end

function shop:mousepressed(x, y, button)
    if Game.states.shop.exit:mousepressed(x, y, button) then
		tile:clear()
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
		tile:clear()
	end
end

function shop:mousereleased(x, y, button)
	Game.states.shop.exit:mousereleased(x, y, button)
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
		tile:clear()
	end
end

return shop
