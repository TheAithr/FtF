local EnemyBase = require("objects.entities.enemies.enemyBase")

local Boss = {}
Boss.__index = Boss
setmetatable(Boss, EnemyBase)

function Boss.new(x, y)
    local self = EnemyBase.new(x, y, 100, 100, "boss")
    setmetatable(self, Boss)
    
    self.stats.movespeed = {25, "Movespeed", 10, 0}
    self.stats.maxHealth = {100, "Max Health", 1, 0}
    self.stats.damage = {50, "Base Damage", 1, 0}
    self.stats.critRate = {0, "Crit Chance", 1, 0}
    self.stats.critDamage = {2, "Crit Damage", 0.1, 0}
    self.stats.armor = {10, "Armor", 0.5, 0}
    self.stats.lifesteal = {0, "Lifesteal", 0.5, 0}
    self.stats.dodge = {0, "Dodge Chance", 0.25, 0}
    self.stats.attackRate = {0.1, "Attack Rate", 0.01, 0}
    
    self:scaleToPlayerLevel()
    
    return self
end

function Boss:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    love.graphics.setColor(0.8, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", self.x + 2 - self.width/2, self.y + 2 - self.height/2, self.width - 4, self.height - 4)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("boss", self.x - self.width/2 + 5, self.y - self.height/2 + 5)
    
    for _, projectile in ipairs(self.projectiles) do
        projectile:draw()
    end
end

return Boss
