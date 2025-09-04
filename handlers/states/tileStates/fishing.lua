require("game")
local Scaling = require("lib.scaling")

local fishing = {
    start = nil,
    exit = nil,

    fish = {
        speed = 300,
        cap = 5,
        table = {}
    },
    bar = {
        top = 20,
        bottom = 70,
        speed =  200
    },
    isFishing = false,
    queueResetTimer = false,
    fishDelay = 1,
    timer = 0
}

function fishing:updateLayout()
    local w, h = love.graphics.getDimensions()
    
    local exitSize = Scaling.scale(50)
    self.exit = Button.new(w - exitSize - Scaling.scale(10), Scaling.scale(10), exitSize, exitSize * 0.5, "EXIT", false)
end

function fishing:draw()
    self:updateLayout()
    
    local fishing = Game.states.fishing
    local w, h = love.graphics.getDimensions()
    
    local fontSize = Scaling.getScaledFontSize(12)
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)
    
    local barWidth = Scaling.scale(40)
    local barMargin = Scaling.scale(10)
    love.graphics.rectangle("line", barMargin, barMargin, barWidth, h - barMargin * 2)
    love.graphics.rectangle("fill", barMargin, fishing.bar.top, barWidth, fishing.bar.bottom - fishing.bar.top)

    for i,v in ipairs(fishing.fish.table) do
        if v ~= nil then
            local fishSize = Scaling.scale(20)
            love.graphics.rectangle("fill", v.x - fishSize/2, v.y - fishSize/2, fishSize, fishSize)
        end
    end

    if self.exit then
        self.exit:update()
        self.exit:draw()
    end
end

function fishing:enter()
    local fishing = Game.states.fishing
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
        local w, h = love.graphics.getDimensions()
        fishing.bar.top = math.min(fishing.bar.top + (fishing.bar.speed * dt), h - Scaling.scale(70))
        fishing.bar.bottom = math.min(fishing.bar.bottom + (fishing.bar.speed * dt), h - Scaling.scale(20))
    end
end

function fishing:mousepressed(x, y, button)
    if self.exit and self.exit:mousepressed(x, y, button) then
		Game.stateManager:switch("explore")
	end
end

function fishing:mousereleased(x, y, button)
    if self.exit then self.exit:mousereleased(x, y, button) end
    if self.start then self.start:mousereleased(x, y, button) end
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
        local w, h = love.graphics.getDimensions()
        local yPos = love.math.random(Scaling.scale(20), h - Scaling.scale(20))
        local xPos = w - Scaling.scale(30)
        table.insert(fishing.fish.table, {x=xPos, y=yPos, speed=fishing.fish.speed})
    end
end
	
return fishing
