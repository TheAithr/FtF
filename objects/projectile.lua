local Projectile = {}
Projectile.__index = Projectile

function Projectile.new(x, y, speed, lifespan, targetX, targetY, team, playerVx, playerVy)
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
    
    -- Calculate base direction vector
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
    
    -- Approach: Compensate starting position for player movement instead of full velocity inheritance
    playerVx = playerVx or 0
    playerVy = playerVy or 0
    
    -- Option 1: Partial velocity inheritance (current approach)
    -- Use a smaller inheritance factor for more predictable behavior
    local inheritanceFactor = 0.3  -- Adjust this value (0.0 to 1.0) to control inheritance strength
    local baseVx = self.directionX * self.speed
    local baseVy = self.directionY * self.speed
    self.velocityX = baseVx + (playerVx * inheritanceFactor)
    self.velocityY = baseVy + (playerVy * inheritanceFactor)
    
    -- Option 2: Position compensation (uncomment to use instead)
    -- This adjusts the starting position to account for player movement
    -- local compensationTime = 0.1  -- How far ahead to compensate (in seconds)
    -- self.x = self.x + playerVx * compensationTime
    -- self.y = self.y + playerVy * compensationTime
    -- self.velocityX = self.directionX * self.speed
    -- self.velocityY = self.directionY * self.speed

    return self
end

function Projectile:update(dt)
    if Game.stateManager.currentID == "explore" then
		self.life = self.life + dt
		if self.life > self.lifespan then
			return "dead"
		end

        if self.AI == "straight" then
            -- Use the combined velocity (projectile + inherited player velocity)
            self.x = self.x + self.velocityX * dt
            self.y = self.y + self.velocityY * dt
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