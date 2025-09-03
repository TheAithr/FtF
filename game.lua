Button = require("objects.UI.button")
Player = require("objects.player")
Tile = require("objects.tile")
Camera = require("objects.camera")
Basic = require("objects.enemies.basic")
Projectile = require("objects.projectile")
artifactRegister = require("handlers.artifactRegister")
Random = require("lib.random")

Game = {}
Game.states = {}
Game.noiseSeed = love.math.random() * 1000000

function Game:getChunkCoords(tileX, tileY)
    return math.floor(tileX / self.states.explore.chunkSize), math.floor(tileY / self.states.explore.chunkSize)
end

function Game:getLocalCoords(tileX, tileY)
    local lx = tileX % self.states.explore.chunkSize
	local ly = tileY % self.states.explore.chunkSize
    if lx < 0 then lx = lx + self.states.explore.chunkSize end
    if ly < 0 then ly = ly + self.states.explore.chunkSize end
    return lx, ly
end

function Game:getOrCreateChunk(chunkX, chunkY)
    self.states.explore.chunks[chunkX] = self.states.explore.chunks[chunkX] or {}
    local chunkRow = self.states.explore.chunks[chunkX]
    if not chunkRow[chunkY] then
        local chunk = {}
        for i = 0, self.states.explore.chunkSize - 1 do
            for j = 0, self.states.explore.chunkSize - 1 do
                local tileX = chunkX * self.states.explore.chunkSize + i
                local tileY = chunkY * self.states.explore.chunkSize + j
                chunk[i .. ":" .. j] = Tile.new(tileX, tileY, chunk._baseBiome)
            end
        end
        chunkRow[chunkY] = chunk
    end
    chunkRow[chunkY]._lastAccess = love.timer.getTime()
    return chunkRow[chunkY]
end

function Game:getTile(tileX, tileY)
    local chunkX, chunkY = self:getChunkCoords(tileX, tileY)
    local chunk = self:getOrCreateChunk(chunkX, chunkY)
    local lx, ly = self:getLocalCoords(tileX, tileY)
    return chunk[lx .. ":" .. ly]
end

function Game:getTileIfExists(tileX, tileY)
    local chunkX, chunkY = self:getChunkCoords(tileX, tileY)
    local chunkRow = self.states.explore.chunks[chunkX]
    if not chunkRow then return nil end
    local chunk = chunkRow[chunkY]
    if not chunk then return nil end
    local lx, ly = self:getLocalCoords(tileX, tileY)
    return chunk[lx .. ":" .. ly]
end

function Game:cleanupChunks()
    local now = love.timer.getTime()
    local px, py = self.states.explore.player.x, self.states.explore.player.y
    local playerChunkX, playerChunkY = self:getChunkCoords(
        math.floor(px / tileSize), math.floor(py / tileSize)
    )

    local chunkRadius = 5
    local maxAge = 30

    for cx, row in pairs(self.states.explore.chunks) do
        for cy, chunk in pairs(row) do
            local dist = math.max(math.abs(cx - playerChunkX), math.abs(cy - playerChunkY))
            local lastUsed = chunk._lastAccess or 0

            if dist > chunkRadius and (now - lastUsed > maxAge) then
                row[cy] = nil
            end
        end
        if next(row) == nil then
            self.states.explore.chunks[cx] = nil
        end
    end
end