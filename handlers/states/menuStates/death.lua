local Scaling = require("lib.scaling")

local death = {}

function death:draw()
    local w, h = love.graphics.getDimensions()
    
    local fontSize = Scaling.getScaledFontSize(32)
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)
    
    local text = "You died"
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.print(text, (w - textWidth) / 2, (h - textHeight) / 2)
    love.graphics.setColor(1, 1, 1, 1)
end

return death
