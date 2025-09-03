local Projectile = {}
Projectile.__index = Projectile

function Projectile.new(x, y, speed, lifespan, targetX, targetY, team)
    local self = setmetatable({}, Projectile)
    
    self.x = x
    self.y = y
    self.width = 20
    self.height = 20
    
    self.speed = speed
    self.lifespan = lifespan
	self.life = 0

    self.AI = "straight"
	self.team = team

	self.targetX = targetX
	self.targetY = targetY
    
    local deltaX = self.targetX - self.x
    local deltaY = self.targetY - self.y
    local length = math.sqrt(deltaX^2 + deltaY^2)

	if length > 0 then
        self.directionX = deltaX / length
        self.directionY = deltaY / length
    else
        self.directionX = 0
        self.directionY = 0
    end

    return self
end

function Projectile:update(dt)
    if Game.stateManager.currentID == "explore" then
		self.life = self.life + dt
		if self.life > self.lifespan then
			return "dead"
		end

        if self.AI == "straight" then
            self.x = self.x + self.directionX * self.speed * dt
            self.y = self.y + self.directionY * self.speed * dt
        end
    end
end

function Projectile:draw()
	love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
	love.graphics.setColor(1, 1, 1, 1)
end

function Projectile:collision(x, y, w, h)
	return self.x > x - w/2
	and self.x < x + w/2
	and self.y > y - h/2
	and self.y < y + h/2
end

return Projectile