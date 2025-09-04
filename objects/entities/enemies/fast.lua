local EnemyBase = require("objects.entities.enemies.enemyBase")

local Fast = {}
Fast.__index = Fast
setmetatable(Fast, EnemyBase)

function Fast.new(x, y)
    local self = EnemyBase.new(x, y, 40, 40, "fast")
    setmetatable(self, Fast)
    
    self.stats.movespeed = {200, "Movespeed", 20, 0}
    self.stats.maxHealth = {10, "Max Health", 1, 0}
    self.stats.damage = {10, "Base Damage", 1, 0}
    self.stats.critRate = {0, "Crit Chance", 1, 0}
    self.stats.critDamage = {2, "Crit Damage", 0.1, 0}
    self.stats.armor = {0, "Armor", 0.5, 0}
    self.stats.lifesteal = {0, "Lifesteal", 0.5, 0}
    self.stats.dodge = {0, "Dodge Chance", 0.25, 0}
    self.stats.attackRate = {0.5, "Attack Rate", 0.05, 0}
    
    self:scaleToPlayerLevel()
    
    return self
end

function Fast:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    love.graphics.setColor(0.8, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", self.x + 2 - self.width/2, self.y + 2 - self.height/2, self.width - 4, self.height - 4)
    love.graphics.setColor(1, 1, 1, 1)
    
    for _, projectile in ipairs(self.projectiles) do
        projectile:draw()
    end
end

return Fast
