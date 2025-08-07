local CheckBox = {}
CheckBox.__index = CheckBox

function CheckBox.new(x, y, text, size)
	local self = setmetatable({}, CheckBox)

    local font = love.graphics.newFont()
    font.size = size

	self.x = x
	self.y = y
    self.text = text
    self.textWidth = font:getWidth(self.text)
    self.textHeight = font:getHeight(self.text)
	self.width = self.x + self.textWidth + 5 + self.textHeight
	self.height = self.textHeight
	self.active = false
	self.hovered = false

	return self
end

function CheckBox:update()
	local mx, my = love.mouse.getPosition()
	self.hovered = self:contains(mx, my)
end

function CheckBox:contains(x, y)
	return x > self.x and x < self.x + self.textHeight and y > self.y and y < self.y + self.textHeight
end

function CheckBox:mousepressed(x, y, CheckBox)
	if self:contains(x, y) and CheckBox == 1 and not self.activated then
		self.active = not self.active
	end
	return self.active
end

function CheckBox:mousereleased(x, y, CheckBox)
	
end

function CheckBox:draw()
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
	if self.active then
        love.graphics.rectangle("fill", self.x, self.y, self.textHeight, self.textHeight)
    else
        love.graphics.rectangle("line", self.x, self.y, self.textHeight, self.textHeight)
    end
    love.graphics.print(self.text, self.x + self.textHeight + 5, self.y)
end

return CheckBox
