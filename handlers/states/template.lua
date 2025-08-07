local template = {}

function template:enter()
    -- Anything that should happen when changing to this state
end

function template:leave()
    -- Anything that should happen when changing from this state
end

function template:update(dt)
	-- Anything that should happen in each frame
end

function template:draw()
    -- Anything that should be drawn
end

function template:mousepressed(x, y, button)
    -- Anything that should occur on mouse click (usually buttons)
end

function template:mousereleased(x, y, button)
    -- Same as above, but upon mouse release
end

function template:keypressed(key, scancode)
	-- Keybinds that only apply during this state
end

function template:keyreleased(key, scancode)
	-- Keybinds during this state, usually for identifying when held buttons are released
end

return template
