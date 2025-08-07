local Player = {}
Player.__index = Player

function Player.new()
	local self = setmetatable({}, Player)
	
	self.x = love.math.random(-100, 100) * tileSize
	self.y = love.math.random(-100, 100) * tileSize
	self.width = 50
	self.height = 50
	
	self.stats = {
		movespeed = 200,
		maxHealth = 100,
		health = 100,
		damage = 10,
		critRate = 0,
		critDamage = 2,
		armor = 0,
		lifesteal = 0
	}
	
	self.inventory = {}
	Item:createItems(self.inventory)

	return self
end

function Player:update(dt)
	print("current state: ", Game.stateManager.currentID)
	if Game.stateManager.currentID == "explore" then
		local biome = "grassland"
		if tile and tile.biome then
			biome = tile.biome
		end
		local speed
		if biome == "ocean" then
			speed = self.stats.movespeed * 0.75
		else
			speed = self.stats.movespeed
		end
		
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
end

return Player
