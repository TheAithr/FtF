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
		movespeed = {200, "Movespeed", 20, 0},
		maxHealth = {100, "Max Health", 10, 0},
		damage = {10, "Base Damage", 1, 0},
		critRate = {0, "Crit Chance", 1, 0},
		critDamage = {2, "Crit Damage", 0.1, 0},
		armor = {0, "Armor", 0.5, 0},
		lifesteal = {0, "Lifesteal", 0.5, 0}, 
		dodge = {0, "Dodge Chance", 0.25, 0}
	}

	self.hp = self.stats.maxHealth or 100
	self.fish = 0

	return self
end

function Player:update(dt)
	if Game.stateManager.currentID == "explore" then
		local speed
		for _,b in pairs(biomeList) do
			if b.name == tile.biome then
				speedMult = b.speedMult
			end
		end
		speed = self.stats.movespeed[1] * speedMult
		
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
	self.stats.movespeed[1] = 200
	self.stats.maxHealth[1] = 100
	self.stats.damage[1] = 10
	self.stats.critRate[1] = 0
	self.stats.critDamage[1] = 2
	self.stats.armor[1] = 0
	self.stats.lifesteal[1] = 0
	self.stats.dodge[1] = 0

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

return Player
