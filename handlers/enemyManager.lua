local EnemyManager = {}
Enemymanager.__index = Enemymanager

function Enemymanager.new()
    local self = setmetatable({}, Enemymanager)
    
    self.enemies = {}
    
    return self
end

return EnemyManager