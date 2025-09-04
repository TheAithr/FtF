local Entity = {}
Entity.__index = Entity

function Entity.new(x, y, width, height, team, entityType)
    local self = setmetatable({}, Entity)
    
    self.x = x or 0
    self.y = y or 0
    self.width = width or 50
    self.height = height or 50
    
    self.team = team or "neutral"
    self.entityType = entityType or "basic"
    
    self.id = love.math.random() * 1000000
    
    self.stats = {
        movespeed = {200, "Movespeed", 20, 0},
        maxHealth = {100, "Max Health", 10, 0},
        damage = {10, "Base Damage", 1, 0},
        critRate = {0, "Crit Chance", 1, 0},
        critDamage = {2, "Crit Damage", 0.1, 0},
        armor = {0, "Armor", 0.5, 0},
        lifesteal = {0, "Lifesteal", 0.5, 0}, 
        dodge = {0, "Dodge Chance", 0.25, 0},
        attackRate = {1, "Attack Rate", 0.05, 0}
    }
    
    self.hp = self.stats.maxHealth[1]
    self.immunity = 0
    
    self.projectiles = {}
    self.attackCooldown = 0
    
    return self
end

function Entity:update(dt)
    self.immunity = math.max(0, self.immunity - dt)
    
    self.attackCooldown = math.max(0, self.attackCooldown - dt)
    
    for i = #self.projectiles, 1, -1 do
        local projectile = self.projectiles[i]
        local state = projectile:update(dt)
        if state == "dead" then
            table.remove(self.projectiles, i)
        end
    end
    
    self:updateStats()
    
    return self:checkDeath() and "dead" or "alive"
end

function Entity:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    
    for _, projectile in ipairs(self.projectiles) do
        projectile:draw()
    end
end

function Entity:updateStats()
    for stat, base in pairs(self.stats) do
        self.stats[stat][1] = base[1] + (base[3] * base[4])
    end
end

function Entity:shoot(targetX, targetY)
    if self.attackCooldown <= 0 then
        if Game.states.explore and Game.states.explore.projectileManager then
            Game.states.explore.projectileManager:addProjectile(
                self.x, self.y, 500, 5, targetX, targetY, self.team,
                self.stats.damage[1], self.stats.critRate[1], self.stats.critDamage[1]
            )
        else
            table.insert(self.projectiles, Projectile.new(
                self.x, self.y, 500, 5, targetX, targetY, self.team,
                self.stats.damage[1], self.stats.critRate[1], self.stats.critDamage[1]
            ))
        end
        self.attackCooldown = 1 / self.stats.attackRate[1]
    end
end

function Entity:checkCollidingProjectile()
    if self.immunity <= 0 then
        if self.team == "player" then
            for i, enemy in ipairs(Game.states.explore.enemies or {}) do
                for j, projectile in ipairs(enemy.projectiles) do
                    if projectile:collision(self.x, self.y, self.width, self.height) then
                        enemy:damageCalc(self)
                        table.remove(enemy.projectiles, j)
                        self.immunity = 1
                        return self:checkDeath() and "dead" or "hit"
                    end
                end
            end
        elseif self.team == "enemy" then
            local player = Game.states.explore.player
            if player and player.projectiles then
                for i, projectile in ipairs(player.projectiles) do
                    if projectile:collision(self.x, self.y, self.width, self.height) then
                        player:damageCalc(self)
                        table.remove(player.projectiles, i)
                        return self:checkDeath() and "dead" or "hit"
                    end
                end
            end
        end
    end
    return "none"
end

function Entity:damageCalc(target)
    local critRoll = love.math.random(100)
    local dodgeRoll = love.math.random(100)
    
    if dodgeRoll > target.stats.dodge[1] then
        local baseDamage = math.max(
            self.stats.damage[1] / ((target.stats.armor[1] / 50) + 1), 
            1
        )
        
        local finalDamage
        if critRoll <= self.stats.critRate[1] then
            finalDamage = math.floor(self.stats.critDamage[1] * baseDamage * 10 + 0.5) / 10
            if self.stats.lifesteal[1] > 0 then
                self.hp = math.min(
                    self.hp + self.stats.critDamage[1] * self.stats.lifesteal[1], 
                    self.stats.maxHealth[1]
                )
            end
        else
            finalDamage = math.floor(baseDamage * 10 + 0.5) / 10
            if self.stats.lifesteal[1] > 0 then
                self.hp = math.min(
                    self.hp + self.stats.lifesteal[1], 
                    self.stats.maxHealth[1]
                )
            end
        end
        
        target.hp = target.hp - finalDamage
        return finalDamage
    end
    
    return 0 
end

function Entity:checkDeath()
    return self.hp <= 0
end

function Entity:heal(amount)
    if self.hp < self.stats.maxHealth[1] then
        self.hp = math.min(self.hp + amount, self.stats.maxHealth[1])
        return true
    end
    return false
end

function Entity:getSpeedWithBiome()
    local tileX = math.floor(self.x / tileSize)
    local tileY = math.floor(self.y / tileSize)
    local tile = Game:getTile(tileX, tileY)
    local speedMult = 1
    
    for _, b in pairs(biomeList or {}) do
        if b.name == tile.biome then
            speedMult = b.speedMult
            break
        end
    end
    
    return self.stats.movespeed[1] * speedMult
end

return Entity
