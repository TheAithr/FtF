local Scaling = require("lib.scaling")

local paused = {
    resume = nil,
    settings = nil,
    quit = nil
}

function paused:updateLayout()
    local w, h = love.graphics.getDimensions()
    
    local buttonWidth, buttonHeight = Scaling.scaleUI(300, 50)
    local spacing = Scaling.scale(15)
    
    local totalHeight = (buttonHeight * 3) + (spacing * 2)
    
    local buttonX = (w - buttonWidth) / 2
    local startY = (h - totalHeight) / 2
    
    self.resume = Button.new(buttonX, startY, buttonWidth, buttonHeight, "RESUME", false)
    self.settings = Button.new(buttonX, startY + buttonHeight + spacing, buttonWidth, buttonHeight, "SETTINGS", false)
    self.quit = Button.new(buttonX, startY + (buttonHeight + spacing) * 2, buttonWidth, buttonHeight, "QUIT", false)
end

function paused:draw()
    if Game.stateManager.previous ~= nil then
        Game.stateManager.previous:draw()
    end
    
    local previousFont = love.graphics.getFont()
    
    self:updateLayout()
    
    local w, h = love.graphics.getDimensions()

    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(1, 1, 1, 1)
    
    local fontSize = Scaling.getScaledFontSize(32)
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)
    
    local title = "PAUSED"
    local titleWidth = font:getWidth(title)
    love.graphics.print(title, (w - titleWidth) / 2, Scaling.scale(100))
    
    love.graphics.setFont(previousFont)

    if self.resume then
        self.resume:draw()
    end
    if self.settings then
        self.settings:draw()
    end
    if self.quit then
        self.quit:draw()
    end
end

function paused:mousepressed(x, y, button)
    if self.resume and self.resume:mousepressed(x, y, button) then
        self:resumeFunc()
    end
    if self.settings and self.settings:mousepressed(x, y, button) then
        self:settingsFunc()
    end
    if self.quit and self.quit:mousepressed(x, y, button) then
        self:quitFunc()
    end
end

function paused:mousereleased(x, y, button)
    if self.resume then self.resume:mousereleased(x, y, button) end
    if self.settings then self.settings:mousereleased(x, y, button) end
    if self.quit then self.quit:mousereleased(x, y, button) end
end

function paused:keypressed(key, scancode)
    if scancode == "escape" then
        self:resumeFunc()
    end
end

function paused:resumeFunc()
    Game.stateManager:switch(Game.stateManager.previousID or "explore")
end
function paused:settingsFunc()
    Game.stateManager:switch("settings")
end
function paused:quitFunc()
    love.event.quit()
end

return paused
