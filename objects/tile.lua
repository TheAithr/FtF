local Tile = {}
Tile.__index = Tile

biomeList = {
	shallowOceanBiome = {
		name = "shallowOcean",
		color = {0.2, 0.5, 1, 1},
		speedMult = 0.85,
		threshold = 0.2,
		threshold2 = 0.3,
		states = {
			{name="empty", weight=1000},
			{name="combat", weight=200},
			-- {name="shop", weight=10},
			{name="treasure", weight=25}
		}
	},

	deepOceanBiome = {
		name = "deepOcean",
		color = {0, 0, 1, 1},
		speedMult = 0.75,
		threshold = 0.2,
		threshold2 = 1,
		states = {
			{name="empty", weight=1000},
			{name="combat", weight=400},
			-- {name="shop", weight=10},
			{name="treasure", weight=50}
		}
	},

	beachBiome = {
		name = "beach",
		color = {1, 1, 0, 1},
		speedMult = 1,
		threshold = 0.4,
		threshold2 = 1,
		states = {
			{name="empty", weight=1000},
			{name="combat", weight=0},
			-- {name="shop", weight=10},
			{name="treasure", weight=30}
		}
	},

	grasslandBiome = {
		name = "grassland",
		color = {0, 1, 0, 1},
		speedMult = 1,
		threshold = 0.875,
		threshold2 = 0.5,
		states = {
			{name="empty", weight=1000},
			{name="combat", weight=100},
			-- {name="shop", weight=10},
			{name="treasure", weight=10}
		}
	},

	forestBiome = {
		name = "forest",
		color = {0.1, 0.8, 0.1, 1},
		speedMult = 1,
		threshold = 0.875,
		threshold2 = 1,
		states = {
			{name="empty", weight=1000},
			{name="combat", weight=150},
			-- {name="shop", weight=10},
			{name="treasure", weight=0}
		}
	},

	mountainBiome = {
		name = "mountain",
		color = {1, 1, 1, 1},
		speedMult = 1,
		threshold = 1,
		threshold2 = 1,
		states = {
			{name="empty", weight=1500},
			{name="combat", weight=75},
			-- {name="shop", weight=10},
			{name="treasure", weight=20}
		}
	}
}

function Tile.new(x, y, baseBiome)
    local self = setmetatable({}, Tile)

    self.xCoor = x
    self.yCoor = y
    self.width = Game.states.explore.tileSize
    self.height = Game.states.explore.tileSize
    self.x = self.xCoor * self.width
    self.y = self.yCoor * self.height

	self.n = 0
	self.n2 = 0
	
	self.biome = self:rollBiome() or "grassland"

	for _,b in pairs(biomeList) do
		if self.biome == b.name then
			self.state = Random.weightedRoll(b.states)
		end
	end
	
    return self
end

function Tile:draw()
	for _,b in pairs(biomeList) do
		if self.biome == b.name then
			love.graphics.setColor(b.color)
		end
	end
	love.graphics.rectangle("fill", self.x, self.y, self.width - 0.5, self.height - 0.5)

	love.graphics.setColor(0, 0, 0, 1)
	if self.state ~= "empty" then
		love.graphics.print(self.state, self.x + 5, self.y + 5)
	end
	love.graphics.setColor(1, 1, 1, 1)
end

function Tile:behaviour()
    if self.state == "empty" then
		-- Do nothing
	else
		Game.stateManager:switch(self.state)
	end
	if self.state == "combat" then
		Game.states.combat.enemy.health = Game.states.combat.enemy.maxHealth
		Game.states.explore.player.health = Game.states.explore.player.maxHealth
	end
end

function Tile:clear()
	self.state = "empty"
	Game.states.explore.tilesCleared = Game.states.explore.tilesCleared + 1
	Game.stateManager:switch("explore")
end

function Tile:getNoiseBiome(x, y)
    local scale = 0.02
	local scale2 = 0.02

    self.n = love.math.noise(x * scale + Game.noiseSeed, y * scale + Game.noiseSeed)
	self.n2 = love.math.noise(x * scale2 + 2 * Game.noiseSeed, y * scale2 + 2 * Game.noiseSeed)

	local biomes = {}
    for _, b in pairs(biomeList) do
        table.insert(biomes, b)
    end

	table.sort(biomes, function(a, b)
        if a.threshold == b.threshold then
            return a.threshold2 < b.threshold2
        else
            return a.threshold < b.threshold
        end
    end)

	for _,b in pairs(biomes) do
		if self.n < b.threshold then
			if self.n2 < b.threshold2 then
				return b.name
			end
		end
	end

return biomes[#biomes].name
end

function Tile:rollBiome()
	return self:getNoiseBiome(self.xCoor, self.yCoor)
end

return Tile
