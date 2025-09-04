local EnemyManager = {}
EnemyManager.__index = EnemyManager

local Basic = require("objects.entities.enemies.basic")
local Light = require("objects.entities.enemies.light")
local Heavy = require("objects.entities.enemies.heavy")
local Boss = require("objects.entities.enemies.boss")

function EnemyManager.new()
    local self = setmetatable({}, EnemyManager)

    self.directorSpawns = {
        {name="basic", weight=30, cost=0.8, minLevel=1},
        {name="light", weight=20, cost=0.75, minLevel=2},
        {name="heavy", weight=10, cost=2, minLevel=3},
        {name="boss", weight=3, cost=10, minLevel=5}
    }
    
    self.queue = {}
    self.enemies = {}
    self.credits = 0
    self.cps = Game.states.explore.player.level / 5
    
    return self
end

function EnemyManager:update(dt)
    self:queueEnemy()
    self.cps = Game.states.explore.player.level / 5
    self.credits = self.credits + (self.cps * dt)
    if #self.queue > 0 and self.credits > self.queue[1].cost then
        self.credits = self.credits - self.queue[1].cost
        table.insert(self.enemies, self:queuedEnemytoRealEnemy(self.queue[1]))
        table.remove(self.queue, 1)
        self:queueEnemy()
    end

    for i = #self.enemies, 1, -1 do
        local v = self.enemies[i]
        local enemyState = v:update(dt)
		if enemyState == "dead" then
			table.remove(self.enemies, i)
			Game.states.explore.player.xp = Game.states.explore.player.xp + 10
		end
    end
end

function EnemyManager:draw()
    for i,v in ipairs(self.enemies) do
        v:draw()
    end
end

function EnemyManager:queueEnemy()
    if #self.queue <= 10 then
        local playerLevel = Game.states.explore.player.level or 1
        local availableEnemies = {}
        
        for _, enemyData in ipairs(self.directorSpawns) do
            if playerLevel >= enemyData.minLevel then
                table.insert(availableEnemies, enemyData)
            end
        end
        
        if #availableEnemies > 0 then
            local enemyName = Random.weightedRoll(availableEnemies)
            local queuedEnemy = nil
            for _, enemyData in ipairs(availableEnemies) do
                if enemyData.name == enemyName then
                    queuedEnemy = enemyData
                    break
                end
            end
            if queuedEnemy then
                table.insert(self.queue, queuedEnemy)
            end
        end
    end
end

function EnemyManager:checkEntityCollision(x, y, width, height, excludeEntity)
    for _, enemy in ipairs(self.enemies) do
        if enemy ~= excludeEntity then
            local dx = math.abs(x - enemy.x)
            local dy = math.abs(y - enemy.y)
            local minDistX = (width + enemy.width) / 2
            local minDistY = (height + enemy.height) / 2
            
            if dx < minDistX and dy < minDistY then
                return true
            end
        end
    end
    
    local player = Game.states.explore.player
    if player and player ~= excludeEntity then
        local dx = math.abs(x - player.x)
        local dy = math.abs(y - player.y)
        local minDistX = (width + player.width) / 2
        local minDistY = (height + player.height) / 2
        
        if dx < minDistX and dy < minDistY then
            return true
        end
    end
    
    return false
end

function EnemyManager:findSafeSpawnPosition(queuedEnemy)
    local attempts = 0
    local maxAttempts = 50
    local width, height = 50, 50
    
    if queuedEnemy.name == "light" then
        width, height = 40, 40
    elseif queuedEnemy.name == "heavy" then
        width, height = 60, 60
    elseif queuedEnemy.name == "boss" then
        width, height = 100, 100
    end
    
    while attempts < maxAttempts do
        local xPos = love.math.random(Game.states.explore.player.x - 1000, Game.states.explore.player.x + 1000)
        local yPos = love.math.random(Game.states.explore.player.y - 1000, Game.states.explore.player.y + 1000)
        
        if not self:checkEntityCollision(xPos, yPos, width, height, nil) then
            return xPos, yPos
        end
        
        attempts = attempts + 1
    end
    
    local angle = love.math.random() * 2 * math.pi
    local distance = 1200
    return Game.states.explore.player.x + math.cos(angle) * distance,
           Game.states.explore.player.y + math.sin(angle) * distance
end

function EnemyManager:queuedEnemytoRealEnemy(queuedEnemy)
    local xPos, yPos = self:findSafeSpawnPosition(queuedEnemy)
    if queuedEnemy.name == "basic" then
        return Basic.new(xPos, yPos)
    elseif queuedEnemy.name == "light" then
        return Light.new(xPos, yPos)
    elseif queuedEnemy.name == "heavy" then
        return Heavy.new(xPos, yPos)
    elseif queuedEnemy.name == "boss" then
        return Boss.new(xPos, yPos)
    end
end

function EnemyManager:removeEnemy(enemy)
    for i, e in ipairs(self.enemies) do
        if e == enemy then
            table.remove(self.enemies, i)
            return true
        end
    end
    return false
end

function EnemyManager:getEnemies()
    return self.enemies
end

-- Get available enemy types for current player level
function EnemyManager:getAvailableEnemyTypes()
    local playerLevel = Game.states.explore.player.level or 1
    local availableEnemies = {}
    
    for _, enemyData in ipairs(self.directorSpawns) do
        if playerLevel >= enemyData.minLevel then
            table.insert(availableEnemies, {
                name = enemyData.name,
                minLevel = enemyData.minLevel,
                weight = enemyData.weight,
                cost = enemyData.cost
            })
        end
    end
    
    return availableEnemies
end

-- Update minimum level for a specific enemy type
function EnemyManager:setEnemyMinLevel(enemyName, minLevel)
    for _, enemyData in ipairs(self.directorSpawns) do
        if enemyData.name == enemyName then
            enemyData.minLevel = minLevel
            return true
        end
    end
    return false
end

return EnemyManager
