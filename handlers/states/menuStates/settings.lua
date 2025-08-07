-- handlers/states/settings.lua
local settings = {}

function settings:enter()
    -- Anything that should happen when changing to this state
end

function settings:leave()
    -- Anything that should happen when changing from this state
end

function settings:update(dt)
	-- Anything that should happen in each frame
end

function settings:draw()
    -- Anything that should be drawn
end

function settings:mousepressed(x, y, button)
    -- Anything that should occur on mouse click (usually buttons)
end

function settings:mousereleased(x, y, button)
    -- Same as above, but upon mouse release
end

function settings:keypressed(key, scancode)
	-- Keybinds that only apply during this state
end

function settings:keyreleased(key, scancode)
	-- Keybinds during this state, usually for identifying when held buttons are released
end

return settings
