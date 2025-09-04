local EnemyBase = require("objects.entities.enemies.enemyBase")

local Light = {}
Light.__index = Light
setmetatable(Light, EnemyBase)

function Light.new(x, y)
    local self = EnemyBase.new(x, y, 40, 40, "light")
    setmetatable(self, Light)
    
    self.stats.movespeed = {200, "Movespeed", 20, 0}
    self.stats.maxHealth = {10, "Max Health", 1, 0}
    self.stats.damage = {5, "Base Damage", 0.5, 0}
    self.stats.critRate = {0, "Crit Chance", 1, 0}
    self.stats.critDamage = {2, "Crit Damage", 0.1, 0}
    self.stats.armor = {0, "Armor", 0.5, 0}
    self.stats.lifesteal = {0, "Lifesteal", 0.5, 0}
    self.stats.dodge = {0, "Dodge Chance", 0.25, 0}
    self.stats.attackRate = {0.6, "Attack Rate", 0.05, 0}
    
    self:scaleToPlayerLevel()
    
    return self
end

function Light:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    love.graphics.setColor(0.8, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", self.x + 2 - self.width/2, self.y + 2 - self.height/2, self.width - 4, self.height - 4)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("light", self.x - self.width/2 + 5, self.y - self.height/2 + 5)
    
    for _, projectile in ipairs(self.projectiles) do
        projectile:draw()
    end
end

return Light
