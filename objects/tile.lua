local Tile = {}
Tile.__index = Tile

biomeList = {
	oceanBiome = {
		name = "ocean",
		color = {0.2, 0.5, 1, 1},
		speedMult = 0.75,
		states = {
			{name="empty", weight=1000},
			{name="combat", weight=200},
			{name="shop", weight=0},
			{name="treasure", weight=25}
		}
	},

	deepOceanBiome = {
		name = "deepOcean",
		color = {0, 0, 1, 1},
		speedMult = 0.75,
		states = {
			{name="empty", weight=1000},
			{name="combat", weight=400},
			{name="shop", weight=0},
			{name="treasure", weight=50}
		}
	},

	beachBiome = {
		name = "beach",
		color = {1, 1, 0, 1},
		speedMult = 1,
		states = {
			{name="empty", weight=1000},
			{name="combat", weight=0},
			{name="shop", weight=0},
			{name="treasure", weight=30}
		}
	},

	grasslandBiome = {
		name = "grassland",
		color = {0, 1, 0, 1},
		speedMult = 1,
		states = {
			{name="empty", weight=1000},
			{name="combat", weight=100},
			{name="shop", weight=10},
			{name="treasure", weight=10}
		}
	},

	forestBiome = {
		name = "forest",
		color = {0.1, 0.8, 0.1, 1},
		speedMult = 1,
		states = {
			{name="empty", weight=1000},
			{name="combat", weight=150},
			{name="shop", weight=20},
			{name="treasure", weight=0}
		}
	},

	tundraBiome = {
		name = "tundra",
		color = {1, 1, 1, 1},
		speedMult = 1,
		states = {
			{name="empty", weight=1500},
			{name="combat", weight=75},
			{name="shop", weight=20},
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

local function getNoiseBiome(x, y)
    -- Lower scale = larger islands
    local scale = 0.03
	local scaleGrassland = 0.05
	local scaleOcean = 0.05
    local n = love.math.noise(x * scale + Game.noiseSeed, y * scale + Game.noiseSeed)
	local nGrassland = love.math.noise(x * scaleGrassland + Game.noiseSeed, y * scaleGrassland + Game.noiseSeed)
	local nOcean = love.math.noise(x * scaleOcean + Game.noiseSeed, y * scaleOcean + Game.noiseSeed)
    if n < 0.2 then
        if nOcean < 0.3 then
			return "deepOcean"
		elseif nOcean < 1 then
			return "ocean"
		end
    elseif n < 0.4 then
        return "beach"
	elseif n < 0.875 then
		if nGrassland < 0.5 then
			return "grassland"
		elseif nGrassland < 1 then
			return "forest"
		end
	elseif n < 1 then
		return "tundra"
    end
end

function Tile:rollBiome()
	return getNoiseBiome(self.xCoor, self.yCoor)
end

return Tile
