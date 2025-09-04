local Player = {}
Player.__index = Player
setmetatable(Player, Entity)

function Player.new()
    local self = Entity.new(0, 0, 50, 50, "player", "player")
    setmetatable(self, Player)
    
    self.level = 1
    self.xp = 0
    self.points = self.level
    self.fish = 0
    
    self.stats.movespeed = {200, "Movespeed", 20, 0}
    self.stats.maxHealth = {100, "Max Health", 10, 0}
    self.stats.damage = {10, "Base Damage", 1, 0}
    self.stats.critRate = {0, "Crit Chance", 1, 0}
    self.stats.critDamage = {2, "Crit Damage", 0.1, 0}
    self.stats.armor = {0, "Armor", 0.5, 0}
    self.stats.lifesteal = {0, "Lifesteal", 0.5, 0}
    self.stats.dodge = {0, "Dodge Chance", 0.25, 0}
    self.stats.attackRate = {1, "Attack Rate", 0.05, 0}
    
    self.hp = self.stats.maxHealth[1]
    
    return self
end

function Player:update(dt)
    local state = Entity.update(self, dt)
    
    if Game.stateManager.currentID == "explore" then
        local speed = self:getSpeedWithBiome()
        
        if love.keyboard.isDown("a") then
            self.x = self.x - speed * dt
        end
        if love.keyboard.isDown("d") then
            self.x = self.x + speed * dt
        end
        if love.keyboard.isDown("w") then
            self.y = self.y - speed * dt
        end
        if love.keyboard.isDown("s") then
            self.y = self.y + speed * dt
        end
        
        if love.mouse.isDown(1) then
            local mX = love.mouse.getX()
            local mY = love.mouse.getY()
            local worldX = mX + Game.states.explore.camera.x
            local worldY = mY + Game.states.explore.camera.y
            self:shoot(worldX, worldY)
        end
        
        if state == "dead" then
            Game.stateManager:switch("death")
            return state
        end
    end
    
    return state
end

function Player:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    love.graphics.setColor(0, 0, 1, 1)
    love.graphics.rectangle("fill", self.x + 2 - self.width/2, self.y + 2 - self.height/2, self.width - 4, self.height - 4)
    love.graphics.setColor(1, 1, 1, 1)
    
    for _, projectile in ipairs(self.projectiles) do
        projectile:draw()
    end
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
    self.stats.attackRate[1] = 3
    
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

function Player:healCalc()
    if self.hp < self.stats.maxHealth[1] then
        self.hp = math.floor(math.min(self.hp + self.stats.maxHealth[1] / 2, self.stats.maxHealth[1]) * 10 + 0.5) / 10
        self.fish = self.fish - 1
    end
end

function Player:checkCollidingProjectile()
    if self.immunity <= 0 then
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
    end
    return "none"
end

return Player
