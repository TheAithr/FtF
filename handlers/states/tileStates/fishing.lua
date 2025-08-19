require("game")

local fishing = {
    start = Button.new(250, 400, 300, 100, "FISH"),
    exit = Button.new(windowWidth - 55, 5, 50, 25, "EXIT"),

    fish = {
        speed = 300,
        cap = 5,
        table = {}
    },
    bar = {
        top = 20,
        bottom = 70,
        speed =  100
    },
    isFishing = false,
    queueResetTimer = false,
    fishDelay = 1,
    timer = 0
}

function fishing:draw()
    local fishing = Game.states.fishing
    love.graphics.rectangle("line", 10, 10, 40, windowHeight - 20)
    love.graphics.rectangle("fill", 10, fishing.bar.top, 40, fishing.bar.bottom - fishing.bar.top)

    for i,v in ipairs(fishing.fish.table) do
        if v ~= nil then
            love.graphics.rectangle("fill", v.x - 10, v.y - 10, 20, 20)
        end
    end

    fishing.exit:draw()
end

function fishing:enter()
    local fishing = Game.states.fishing
    fishing.bar.speed = Game.states.explore.player.stats.movespeed[1] / 2
end

function fishing:update(dt)
    local fishing = Game.states.fishing

    fishing.timer = fishing.timer + dt
    if fishing.timer > fishing.fishDelay then
         if fishing.queueResetTimer then
            fishing.timer = 0
            fishing.queueResetTimer = false
            self:newFish()
         else
            fishing.queueResetTimer = true
         end
    end

    for i = #fishing.fish.table, 1, -1 do
        local v = fishing.fish.table[i]
        if v ~= nil then
            v.x = v.x - v.speed * dt
            if v.x < 0 then
                table.remove(fishing.fish.table, i)
            elseif v.y >= fishing.bar.top and v.y <= fishing.bar.bottom 
            and v.x < 50 and v.x > 10 then
                table.remove(fishing.fish.table, i)
                Game.states.explore.player.fish = Game.states.explore.player.fish + 1
            end
        end
    end

    if love.keyboard.isDown("w") then
        fishing.bar.top = math.max(fishing.bar.top - (fishing.bar.speed * dt), 20)
        fishing.bar.bottom = math.max(fishing.bar.bottom - (fishing.bar.speed * dt), 70)
    end
    if love.keyboard.isDown("s") then
        fishing.bar.top = math.min(fishing.bar.top + (fishing.bar.speed * dt), windowHeight - 70)
        fishing.bar.bottom = math.min(fishing.bar.bottom + (fishing.bar.speed * dt), windowHeight - 20)
    end
end

function fishing:mousepressed(x, y, button)
    if Game.states.fishing.exit:mousepressed(x, y, button) then
		Game.stateManager:switch("explore")
	end
    if Game.states.fishing.start:mousepressed(x, y, button) then
        
    end
end

function fishing:mousereleased(x, y, button)
    
end

function fishing:keypressed(key, scancode)
    if scancode == "backspace" then
        Game.stateManager:switch("explore")
    end
end

function fishing:keyreleased(key, scancode)

end

function fishing:newFish()
    local fishing = Game.states.fishing
    if #fishing.fish.table < fishing.fish.cap then
        local yPos = love.math.random(20, windowHeight - 20)
        local xPos = windowWidth - 30
        table.insert(fishing.fish.table, {x=xPos, y=yPos, speed=fishing.fish.speed})
    end
end
	
return fishing
