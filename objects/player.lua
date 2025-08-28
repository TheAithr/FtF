local Player = {}
Player.__index = Player

function Player.new()
	local self = setmetatable({}, Player)
	
	self.x = 0
	self.y = 0
	self.width = 50
	self.height = 50

	self.level = 1
	self.xp = 0
	self.points = 1
	
	self.stats = {
		movespeed = {200, "Movespeed", 20, 0},
		maxHealth = {100, "Max Health", 10, 0},
		damage = {10, "Base Damage", 1, 0},
		critRate = {0, "Crit Chance", 1, 0},
		critDamage = {2, "Crit Damage", 0.1, 0},
		armor = {0, "Armor", 0.5, 0},
		lifesteal = {0, "Lifesteal", 0.5, 0}, 
		dodge = {0, "Dodge Chance", 0.25, 0},
		attackRate = {3, "Attack Rate", 0.05, 0}
	}

	self.immunity = 0
	self.attackCooldown = 0

	self.projectiles = {}
	self.team = "player"

	self.hp = self.stats.maxHealth[1] or 100
	self.fish = 0

	return self
end

function Player:update(dt)
	local tileX = math.floor(self.x / tileSize)
	local tileY = math.floor(self.y / tileSize)
	local tile = Game:getTile(tileX, tileY)

	if Game.stateManager.currentID == "explore" then
		local speed
		for _,b in pairs(biomeList) do
			if b.name == tile.biome then
				speedMult = b.speedMult
			end
		end
		speed = self.stats.movespeed[1] * speedMult

		for i,v in ipairs(self.projectiles) do
			local pState = v:update(dt)
			if pState == "dead" then
				table.remove(self.projectiles, i)
			end
		end

		self.attackCooldown = self.attackCooldown - dt

		self:checkCollidingProjectile()
		self.immunity = self.immunity - dt
		
		if love.keyboard.isDown("a") then
			self.x = self.x - speed * dt
		end
		if love.keyboard.isDown("d") then
			self.x = self.x + speed * dt
		end
		if love.keyboard.isDown("w") then
			self.y = self.y - speed * dt
		end
		if love.keyboard.isDown("s") then
			self.y = self.y + speed * dt
		end
		self:updateStats()
	end
end

function Player:draw()
	for i,v in ipairs(self.projectiles) do
		v:draw()
	end
	love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
	love.graphics.setColor(0, 0, 1, 1)
	love.graphics.rectangle("fill", self.x + 2 - self.width/2, self.y + 2 - self.height/2, self.width - 4, self.height - 4)
	love.graphics.setColor(1, 1, 1, 1)
end

function Player:updateStats()
	self.stats.movespeed[1] = 200
	self.stats.maxHealth[1] = 100
	self.stats.damage[1] = 10
	self.stats.critRate[1] = 0
	self.stats.critDamage[1] = 2
	self.stats.armor[1] = 0
	self.stats.lifesteal[1] = 0
	self.stats.dodge[1] = 0
	self.stats.attackRate[1] = 3

	local levelCost = 90 + (10 * self.level)

	while self.xp >= levelCost do
		self.xp = self.xp - levelCost
		self.level = self.level + 1
		if self.level % 10 == 0 then
			self.points = self.points + 3
		else
			self.points = self.points + 1
		end
	end

	for stat, base in pairs(self.stats) do
        self.stats[stat][1] = self.stats[stat][1] + (self.stats[stat][3] * self.stats[stat][4])
    end
end

function Player:checkCollidingProjectile()
	if self.immunity <= 0 then
		local hit = false
		for i,enemy in ipairs(Game.states.explore.enemies) do
			for j,projectile in ipairs(enemy.projectiles) do
				if projectile:collision(self.x, self.y, self.width, self.height) then
					enemy:damageCalc(self)
					table.remove(enemy.projectiles, j)
					self.immunity = 1
					if self:checkDeath() then
						Game.stateManager:switch("death")
					end
					return
				end
			end
		end
	end
end

function Player:shoot(targetX, targetY)
	if self.attackCooldown <= 0 then
					table.insert(self.projectiles, Projectile.new(self.x, self.y, 750, 5, targetX, targetY, self.team))
					self.attackCooldown = 1/self.stats.attackRate[1]
				end
end

function Player:checkDeath()
	return self.hp <= 0
end

function Player:damageCalc(target)
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

function Player:healCalc()
	if self.hp < self.stats.maxHealth[1] then
		self.hp = math.floor(math.min(self.hp + self.stats.maxHealth[1] / 2, self.stats.maxHealth[1])* 10 + 0.5) / 10
		self.fish = self.fish - 1
	end
end

return Player
