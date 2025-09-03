local sword = {}
sword.__index = sword

function sword.new()
    local self = setmetatable({}, sword)

    self.damageMult = 1.25
    self.firerate = 2
    self.lifespan = 2
    self.speed = 2
    self.properties = {}

    return self
end

return sword