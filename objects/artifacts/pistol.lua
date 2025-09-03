local pistol = {}
pistol.__index = pistol

function pistol.new()
    local self = setmetatable({}, pistol)

    self.damageMult = 1.25
    self.firerate = 2
    self.lifespan = 2
    self.speed = 300
    self.properties = {}

    return self
end

return pistol