local stateManager = {}
stateManager.__index = stateManager

function stateManager.new()
	return setmetatable({
		states = {},
		current = nil,
		previous = nil
	}, stateManager)
end

function stateManager:add(name, state)
	self.states[name] = state
end

function stateManager:switch(name, ...)
	if self.states[name] then
		if self.current ~= nil then
			self.previous = self.current
		end
		if self.currentID ~= nil then
			self.previousID = self.currentID
		end
		if self.current and self.current.leave then
			self.current:leave()
		end
		self.current = self.states[name]
		if self.current.enter then
			self.current:enter(...)
			self.currentID = name
		end
	end
end

function stateManager:update(dt)
	if self.current and self.current.update then
		self.current:update(dt)
	end
end

function stateManager:draw()
	if self.current and self.current.draw then
		self.current:draw()
	end
end

function stateManager:mousepressed(x, y, b, istouch, presses)
	if self.current and self.current.mousepressed then
		self.current:mousepressed(x, y, b, istouch, presses)
	end
end

function stateManager:mousereleased(x, y, b, istouch, presses)
	if self.current and self.current.mousereleased then
		self.current:mousereleased(x, y, b, istouch, presses)
	end
end

function stateManager:keypressed(key, scancode, isrepeat)
	if self.current and self.current.keypressed then
		self.current:keypressed(key, scancode, isrepeat)
	end
end

function stateManager:keyreleased(key, scancode)
	if self.current and self.current.keyreleased then
		self.current:keyreleased(key, scancode)
	end
end

return stateManager