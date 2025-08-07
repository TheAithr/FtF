local Tile = {}
Tile.__index = Tile

local tundraStates = {
	{name="empty", weight=750},
	{name="combat", weight=75},
	{name="shop", weight=20},
	{name="treasure", weight=20}
}

local grasslandStates = {
	{name="empty", weight=1000},
	{name="combat", weight=100},
	{name="shop", weight=10},
	{name="treasure", weight=10}
}

local beachStates = {
	{name="empty", weight=700},
	{name="combat", weight=70},
	{name="shop", weight=0},
	{name="treasure", weight=30}
}

local oceanStates = {
	{name="empty", weight=1000},
	{name="combat", weight=200},
	{name="shop", weight=0},
	{name="treasure", weight=25}
}

function Tile.new(x, y, baseBiome)
    local self = setmetatable({}, Tile)

    self.xCoor = x
    self.yCoor = y
    self.width = Game.states.explore.tileSize
    self.height = Game.states.explore.tileSize
    self.x = self.xCoor * self.width
    self.y = self.yCoor * self.height
	
	self.baseBiome = baseBiome
	self.biome = self:rollBiome() or "grassland"

	if self.biome == "tundra" then
		self.state = Random.weightedRoll(tundraStates)
	elseif self.biome == "grassland" then
		self.state = Random.weightedRoll(grasslandStates)
	elseif self.biome == "beach" then
		self.state = Random.weightedRoll(beachStates)
	elseif self.biome == "ocean" then
		self.state = Random.weightedRoll(oceanStates)
	end
	
    return self
end

function Tile:draw()
	if self.biome == "tundra" then
		love.graphics.setColor(1, 1, 1, 1)
	elseif self.biome == "grassland" then
		love.graphics.setColor(0, 1, 0, 1)
	elseif self.biome == "beach" then
		love.graphics.setColor(1, 1, 0, 1)
	elseif self.biome == "ocean" then
		love.graphics.setColor(0, 0, 1, 1)
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
    local n = love.math.noise(x * scale + Game.noiseSeed, y * scale + Game.noiseSeed)
    if n < 0.25 then
        return "ocean"
    elseif n < 0.375 then
        return "beach"
	elseif n < 0.875 then
        return "grassland"
	elseif n < 1 then
		return "tundra"
    end
end

function Tile:rollBiome()
	return getNoiseBiome(self.xCoor, self.yCoor)
end

return Tile
