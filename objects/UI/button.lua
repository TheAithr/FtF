local Button = {}
Button.__index = Button

local fontCache = {}
local function getFont(size)
	if not fontCache[size] then
		fontCache[size] = love.graphics.newFont(size)
	end
	return fontCache[size]
end

function Button.new(x, y, width, height, text)
	local self = setmetatable({}, Button)

	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.text = text
	self.activated = false
	self.hovered = false

	return self
end

function Button:update()
	local mx, my = love.mouse.getPosition()
	self.hovered = self:contains(mx, my)
end

function Button:contains(x, y)
	return x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height
end

function Button:mousepressed(x, y, button)
	if self:contains(x, y) and button == 1 and not self.activated then
		self.activated = true
		return true
	end
	return false
end

function Button:mousereleased(x, y, button)
	if button == 1 then
		self.activated = false
	end
end

function Button:draw()
	if self.hovered then
		love.graphics.setColor(0.8, 0.8, 0.9, 1)
	else
		love.graphics.setColor(0.3, 0.3, 0.3, 1)
	end
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

	local oldFont = love.graphics.getFont()

	local paddingX = math.min(math.max(self.width * 0.1, 4), 20)
	local paddingY = math.min(math.max(self.height * 0.1, 4), 20)
	local maxWidth = self.width - paddingX * 2
	local maxHeight = self.height - paddingY * 2

	local minFontSize = 6
	local fontSize = 32
	local font, wrappedText, wrappedLines, totalTextHeight

	while fontSize >= minFontSize do
		font = getFont(fontSize)
		wrappedText, wrappedLines = font:getWrap(self.text, maxWidth)
		totalTextHeight = #wrappedLines * font:getHeight()
		if totalTextHeight <= maxHeight then
			break
		end
		fontSize = fontSize - 1
	end

	love.graphics.setFont(font)

	wrappedText, wrappedLines = font:getWrap(self.text, maxWidth)
	totalTextHeight = #wrappedLines * font:getHeight()

	local textX = self.x + paddingX
	local textY = self.y + (self.height - totalTextHeight) / 2

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(self.text, textX, textY, maxWidth, "center")
	
	love.graphics.setFont(oldFont)
	love.graphics.setColor(1, 1, 1, 1)
end

return Button
