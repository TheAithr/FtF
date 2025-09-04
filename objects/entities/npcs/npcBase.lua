local Npcbase = {}
Npcbase.__index = Npcbase
setmetatable(Npcbase, Entity)

function Npcbase.new(x, y, width, height, enemyType)
    local self = Entity.new(x or 0, y or 0, width or 50, height or 50, "enemy", enemyType or "basic")
    setmetatable(self, Npcbase)
    
    self.AI = "wander"
    self.wanderPos = {0, 0}
    
    self:scaleToPlayerLevel()
    
    return self
end

function Npcbase:update(dt)
    if Game.stateManager.currentID ~= "explore" then
        return "alive"
    end
    
    local state = Entity.update(self, dt)
    if state == "dead" then
        return state
    end

    self:updateAI(dt)
    
    return state
end

function Npcbase:updateAI(dt)
    local speed = self:getSpeedWithBiome()
    local player = Game.states.explore.player
    
    if not player then return end
    
    local dx = player.x - self.x
    local dy = player.y - self.y
    local distToPlayer = math.sqrt(dx * dx + dy * dy)
    
    if distToPlayer <= 1000 then
        self.AI = "hunt"
    else
        self.AI = "wander"
    end
    
    if self.AI == "wander" then
        self:wanderBehavior(dt, speed)
    elseif self.AI == "hunt" then
        self:huntBehavior(dt, speed, player)
    end
end

function Npcbase:wanderBehavior(dt, speed)
    local minDist = 60
    
    if not self.wanderPos or (self.wanderPos[1] == 0 and self.wanderPos[2] == 0) then
        local found = false
        while not found do
            local wx = love.math.random(self.x - 250, self.x + 250)
            local wy = love.math.random(self.y - 250, self.y + 250)
            local dx = wx - self.x
            local dy = wy - self.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist >= minDist then
                self.wanderPos = {wx, wy}
                found = true
            end
        end
    end
    
    local diffX = self.wanderPos[1] - self.x
    local diffY = self.wanderPos[2] - self.y
    local dist = math.sqrt(diffX * diffX + diffY * diffY)
    
    if dist > 2 then
        local dirX = diffX / dist
        local dirY = diffY / dist
        local newX = self.x + dirX * speed * dt
        local newY = self.y + dirY * speed * dt
        
        if not self:checkCollisionAtPosition(newX, newY) then
            self.x = newX
            self.y = newY
        else
            self.wanderPos = {0, 0}
        end
    else
        self.wanderPos = {0, 0}
    end
end

function Npcbase:huntBehavior(dt, speed, player)
    local diffX = player.x - self.x
    local diffY = player.y - self.y
    local dist = math.sqrt(diffX * diffX + diffY * diffY)
    
    if dist > 0 then
        local dirX = diffX / dist
        local dirY = diffY / dist
        local newX = self.x + dirX * speed * dt
        local newY = self.y + dirY * speed * dt
        
        if not self:checkCollisionAtPosition(newX, newY) then
            self.x = newX
            self.y = newY
        else
            local altAngle = math.atan2(dirY, dirX) + (love.math.random() > 0.5 and math.pi/4 or -math.pi/4)
            local altDirX = math.cos(altAngle)
            local altDirY = math.sin(altAngle)
            local altX = self.x + altDirX * speed * dt * 0.5
            local altY = self.y + altDirY * speed * dt * 0.5
            
            if not self:checkCollisionAtPosition(altX, altY) then
                self.x = altX
                self.y = altY
            end
        end
    end
    
    if dist <= 1000 and self.attackCooldown <= 0 then
        self:shoot(player.x, player.y)
    end
end

function Npcbase:checkCollisionAtPosition(newX, newY)
    -- Check collision with all entities through the enemy manager
    if Game.states.explore and Game.states.explore.enemyManager then
        return Game.states.explore.enemyManager:checkEntityCollision(newX, newY, self.width, self.height, self)
    end
    return false
end

function Npcbase:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", self.x + 2 - self.width/2, self.y + 2 - self.height/2, self.width - 4, self.height - 4)
    love.graphics.setColor(1, 1, 1, 1)
    
    for _, projectile in ipairs(self.projectiles) do
        projectile:draw()
    end
end

function Npcbase:scaleToPlayerLevel()
    local player = Game.states.explore.player
    if not player then return end
    
    for i = 1, player.level do
        local roll = love.math.random(9)
        if roll == 1 then
            self.stats.movespeed[1] = self.stats.movespeed[1] + self.stats.movespeed[3]
        elseif roll == 2 then
            self.stats.maxHealth[1] = self.stats.maxHealth[1] + self.stats.maxHealth[3]
        elseif roll == 3 then
            self.stats.damage[1] = self.stats.damage[1] + self.stats.damage[3]
        elseif roll == 4 then
            self.stats.critRate[1] = self.stats.critRate[1] + self.stats.critRate[3]
        elseif roll == 5 then
            self.stats.critDamage[1] = self.stats.critDamage[1] + self.stats.critDamage[3]
        elseif roll == 6 then
            self.stats.armor[1] = self.stats.armor[1] + self.stats.armor[3]
        elseif roll == 7 then
            self.stats.lifesteal[1] = self.stats.lifesteal[1] + self.stats.lifesteal[3]
        elseif roll == 8 then
            self.stats.dodge[1] = self.stats.dodge[1] + self.stats.dodge[3]
        elseif roll == 9 then
            self.stats.attackRate[1] = self.stats.attackRate[1] + self.stats.attackRate[3]
        end
    end
    
    self.hp = self.stats.maxHealth[1]
end

return Npcbase
