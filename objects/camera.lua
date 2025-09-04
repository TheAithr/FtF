local Camera = {}
Camera.__index = Camera

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
	local windowWidth, windowHeight = love.graphics.getDimensions()
	self.x = x - windowWidth / 2
	self.y = y - windowHeight / 2
end

function Camera:apply()
	love.graphics.push()
	love.graphics.scale(self.scale)
	love.graphics.translate(-math.floor(self.x), -math.floor(self.y))
end

function Camera:setScale(scale)
	self.scale = scale or 1
end

function Camera:getWorldCoordinates(screenX, screenY)
	return (screenX / self.scale) + self.x, (screenY / self.scale) + self.y
end

function Camera:getScreenCoordinates(worldX, worldY)
	return (worldX - self.x) * self.scale, (worldY - self.y) * self.scale
end

function Camera:reset()
	love.graphics.pop()
end

return Camera
