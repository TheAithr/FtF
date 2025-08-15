local Player = {}
Player.__index = Player

function Player.new()
	local self = setmetatable({}, Player)
	
	self.x = love.math.random(-100, 100) * tileSize
	self.y = love.math.random(-100, 100) * tileSize
	self.width = 50
	self.height = 50

	self.level = 1
	self.xp = 0
	self.points = 1
	
	self.stats = {
		movespeed = 200,
		maxHealth = 100,
		damage = 10,
		critRate = 0,
		critDamage = 2,
		armor = 0,
		lifesteal = 0, 
		dodge = 0
	}

	self.hp = self.stats.maxHealth or 100

	self.statNames = {
		movespeed = "Movespeed",
		maxHealth = "Max Health",
		damage = "Base Damage",
		critRate = "Crit Chance",
		critDamage = "Crit Damage",
		armor = "Defence",
		lifesteal = "Lifesteal",
		dodge = "Dodge Chance"
	}

	self.perLevel = {
		movespeed = 20,
		maxHealth = 10,
		damage = 1,
		critRate = 1,
		critDamage = 0.1,
		armor = 0.5,
		lifesteal = 0.5,
		dodge = 0.25
	}

	self.skillPoints = {
		movespeed = 0,
		maxHealth = 0,
		damage = 0,
		critRate = 0,
		critDamage = 0,
		armor = 0,
		lifesteal = 0,
		dodge = 0
	}

	return self
end

function Player:update(dt)
	print("current state: ", Game.stateManager.currentID)
	if Game.stateManager.currentID == "explore" then
		local speed
		for _,b in pairs(biomeList) do
			if b.name == tile.biome then
				speedMult = b.speedMult
			end
		end
		speed = self.stats.movespeed * speedMult
		
		if love.keyboard.isDown("a") then
			self.x = self.x - speed * dt
			print("moveLeft")
		end
		if love.keyboard.isDown("d") then
			self.x = self.x + speed * dt
			print("moveRight")
		end
		if love.keyboard.isDown("w") then
			self.y = self.y - speed * dt
			print("moveUp")
		end
		if love.keyboard.isDown("s") then
			self.y = self.y + speed * dt
			print("moveDown")
		end
	end
end

function Player:draw()
	love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("fill", self.x + 2 - self.width/2, self.y + 2 - self.height/2, self.width - 4, self.height - 4)
	love.graphics.setColor(1, 1, 1, 1)
end

function Player:updateStats()
	self.stats.movespeed = 200
	self.stats.maxHealth = 100
	self.stats.damage = 10
	self.stats.critRate = 0
	self.stats.critDamage = 2
	self.stats.armor = 0
	self.stats.lifesteal = 0
	self.stats.dodge = 0

	while self.xp >= 100 do
		self.xp = self.xp - 100
		self.level = self.level + 1
		if self.level % 5 == 0 then
			self.points = self.points + 3
		else
			self.points = self.points + 1
		end
	end

	for stat, base in pairs(self.stats) do
        self.stats[stat] = base + (self.perLevel[stat] * self.skillPoints[stat])
    end
end

return Player
