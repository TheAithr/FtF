local paused = {
    resume = Button.new(100, 100, windowWidth - 200, windowHeight - 705, "RESUME"),
    settings = Button.new(100, 300, windowWidth - 200, windowHeight - 705, "SETTINGS"),
    quit = Button.new(100, 500, windowWidth - 200, windowHeight - 705, "QUIT")
}

function paused:draw()
    if Game.stateManager.previous ~= nil then
        Game.stateManager.previous:draw()
    end

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
    love.graphics.setColor(1, 1, 1, 1)

    Game.states.paused.resume:draw()
    Game.states.paused.settings:draw()
    Game.states.paused.quit:draw()
end

function paused:mousepressed(x, y, button)
    if Game.states.paused.resume:mousepressed(x, y, button) then
        paused:resumeFunc()
    end
    if Game.states.paused.settings:mousepressed(x, y, button) then
        paused:settingsFunc()
    end
    if Game.states.paused.quit:mousepressed(x, y, button) then
        paused:quitFunc()
    end
end

function paused:keypressed(key, scancode)
	if scancode == "escape" then
        paused:resumeFunc()
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
