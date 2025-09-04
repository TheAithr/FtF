local EnemyManager = {}
EnemyManager.__index = EnemyManager

local Basic = require("objects.entities.enemies.basic")
local Fast = require("objects.entities.enemies.fast")

function EnemyManager.new()
    local self = setmetatable({}, EnemyManager)

    self.directorSpawns = {
        {name="basic", weight=3, cost=0.8},
        {name="fast", weight=2, cost=0.75}
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
        local enemyName = Random.weightedRoll(self.directorSpawns)
        local queuedEnemy = nil
        for _, enemyData in ipairs(self.directorSpawns) do
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

function EnemyManager:queuedEnemytoRealEnemy(queuedEnemy)
    local xPos = love.math.random(Game.states.explore.player.x - 1000, Game.states.explore.player.x + 1000)
	local yPos = love.math.random(Game.states.explore.player.y - 1000, Game.states.explore.player.y + 1000)
    if queuedEnemy.name == "basic" then
        return Basic.new(xPos, yPos)
    elseif queuedEnemy.name == "fast" then
        return Fast.new(xPos, yPos)
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

return EnemyManager
