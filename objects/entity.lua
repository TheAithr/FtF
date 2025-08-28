local Entity = {}
Entity.__index = Entity

function Entity.new(x, y)
	local self = setmetatable({}, Entity)
	
	self.x = x
	self.y = y
	self.width = 50
	self.height = 50
	
	self.stats = {
		movespeed =  {100, "Movespeed", 10, 0},
		maxHealth =  {10, "Max Health", 1, 0},
		damage =     {10, "Base Damage", 1, 0},
		critRate =   {0, "Crit Chance", 1, 0},
		critDamage = {2, "Crit Damage", 0.1, 0},
		armor =      {0, "Armor", 0.5, 0},
		lifesteal =  {0, "Lifesteal", 0.5, 0}, 
		dodge =      {0, "Dodge Chance", 0.25, 0},
		attackRate = {0.5, "Attack Rate", 0.05, 0}
	}

	for i=1, Game.states.explore.player.level do
		local roll = love.math.random(9)
		if roll == 1 then
			self.stats.movespeed[1] = self.stats.movespeed[1] + self.stats.movespeed[3]
		elseif roll == 2 then
			self.stats.maxHealth[1] = self.stats.maxHealth[1] + self.stats.maxHealth[3]
		elseif roll == 3 then
			self.stats.damage[1] = self.stats.damage[1] + self.stats.damage[3]
		elseif roll == 4 then
			self.stats.critRate[1] = self.stats.critRate[1] + self.stats.critRate[3]
		elseif roll == 5 then
			self.stats.critDamage[1] = self.stats.critDamage[1] + self.stats.critDamage[3]
		elseif roll == 6 then
			self.stats.armor[1] = self.stats.armor[1] + self.stats.armor[3]
		elseif roll == 7 then
			self.stats.lifesteal[1] = self.stats.lifesteal[1] + self.stats.lifesteal[3]
		elseif roll == 8 then
			self.stats.dodge[1] = self.stats.dodge[1] + self.stats.dodge[3]
		elseif roll == 9 then
			self.stats.attackRate[1] = self.stats.attackRate[1] + self.stats.attackRate[3]
		end
	end

    self.AI = "wander"
	self.wanderPos = {0, 0}

	self.hp = self.stats.maxHealth[1] or 100

	self.projectiles = {}
	self.team = "enemy"

	self.attackCooldown = 0

	return self
end

function Entity:update(dt)
    if Game.stateManager.currentID == "explore" then

		if self:checkDeath() then return "dead" end
		
		for i,v in ipairs(self.projectiles) do
			local pState = v:update(dt)
			if pState == "dead" then
				table.remove(self.projectiles, i)
			end
		end

		if self:checkCollidingProjectile() == "dead" then
			return "dead"
		end

		local tileX = math.floor(self.x / tileSize)
		local tileY = math.floor(self.y / tileSize)
		local tile = Game:getTile(tileX, tileY)
		local speedMult = 1
		for _,b in pairs(biomeList) do
			if b.name == tile.biome then
				speedMult = b.speedMult
			end
		end
		local speed = self.stats.movespeed[1] * speedMult

		local wx = love.math.random(self.x - 250, self.x + 250)
		local wy = love.math.random(self.y - 250, self.y + 250)
		local dx = wx - self.x
		local dy = wy - self.y
		local dist = math.sqrt(dx * dx + dy * dy)
		if dist <= 1000 then
		    self.AI = "hunt"
		    found = true
		else
			self.AI = "wander"
		end
		
        if self.AI == "wander" then
            local minDist = 60
            if not self.wanderPos or (self.wanderPos[1] == 0 and self.wanderPos[2] == 0) then
			    local found = false
			    while not found do
			        local wx = love.math.random(self.x - 250, self.x + 250)
			        local wy = love.math.random(self.y - 250, self.y + 250)
			        local dx = wx - self.x
			        local dy = wy - self.y
			        local dist = math.sqrt(dx * dx + dy * dy)
			        if dist >= minDist then
			            self.wanderPos = {wx, wy}
			            found = true
			        end
			    end
			end

            local diffX = self.wanderPos[1] - self.x
            local diffY = self.wanderPos[2] - self.y
            local dist = math.sqrt(diffX * diffX + diffY * diffY)

            if dist > 2 then
                local dirX = diffX / dist
                local dirY = diffY / dist
                self.x = self.x + dirX * speed * dt
                self.y = self.y + dirY * speed * dt
            end
		elseif self.AI == "hunt" then
			local diffX = Game.states.explore.player.x - self.x
            local diffY = Game.states.explore.player.y - self.y
            local dist = math.sqrt(diffX * diffX + diffY * diffY)

			local dirX = diffX / dist
            local dirY = diffY / dist
            self.x = self.x + dirX * speed * dt
            self.y = self.y + dirY * speed * dt
			
			local deltaX = Game.states.explore.player.x - self.x
    		local deltaY = Game.states.explore.player.y - self.y
    		local length = math.sqrt(deltaX^2 + deltaY^2)
			if length <= 1000 then
				if self.attackCooldown <= 0 then
					self:shoot(Game.states.explore.player.x, Game.states.explore.player.y)
					self.attackCooldown = 1/self.stats.attackRate[1]
				else
					self.attackCooldown = self.attackCooldown - dt
				end
			end
        end
    end
end

function Entity:draw()
	love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("fill", self.x + 2 - self.width/2, self.y + 2 - self.height/2, self.width - 4, self.height - 4)
	love.graphics.setColor(1, 1, 1, 1)

	for i,v in ipairs(self.projectiles) do
		v:draw()
	end
end

function Entity:shoot(targetX, targetY)
	table.insert(self.projectiles, Projectile.new(self.x, self.y, 500, 5, targetX, targetY, self.team))
end

function Entity:checkCollidingProjectile()
	for i,projectile in ipairs(Game.states.explore.player.projectiles) do
		if projectile:collision(self.x, self.y, self.width, self.height) then
			Game.states.explore.player:damageCalc(self)
			table.remove(Game.states.explore.player.projectiles, i)
			return "dead"
		end
	end
end

function Entity:damageCalc(target)
	local critRoll = love.math.random(100)
	local dodgeRoll = love.math.random(100)

	if dodgeRoll > target.stats.dodge[1] then
		if critRoll <= self.stats.critRate[1] then
			target.hp = target.hp - math.floor(self.stats.critDamage[1] * (math.max(self.stats.damage[1] / ((target.stats.armor[1] / 50) + 1), 1)) * 10 + 0.5) / 10
			if self.stats.lifesteal[1] > 0 then
				self.hp = math.min(self.hp + self.stats.critDamage[1] * self.stats.lifesteal[1], self.stats.maxHealth[1])
			end
		else
			target.hp = target.hp - math.floor(math.max(self.stats.damage[1] / ((target.stats.armor[1] / 50) + 1), 1)* 10 + 0.5) / 10
			if self.stats.lifesteal[1] > 0 then
				self.hp = math.min(self.hp + self.stats.lifesteal[1], self.stats.maxHealth[1])
			end
		end
	end
end

function Entity:checkDeath()
	return self.hp <= 0
end

return Entity
