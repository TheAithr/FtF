local Camera = {}
Camera.__index = Camera

local windowWidth, windowHeight = love.graphics.getDimensions()

function Camera.new(x, y)
	return setmetatable({
		x = x or 0,
		y = y or 0,
		scale = 1,
	}, Camera)
end

function Camera:setPosition(x, y)
	self.x = x
	self.y = y
end

function Camera:centerOn(x, y)
	self.x = x - windowWidth / 2
	self.y = y - windowHeight / 2
end

function Camera:apply()
	love.graphics.push()
	love.graphics.scale(self.scale)
	love.graphics.translate(-math.floor(self.x), -math.floor(self.y))
end

function Camera:reset()
	love.graphics.pop()
end

return Camera
