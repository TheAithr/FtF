local smg = {}
smg.__index = smg

function smg.new()
    local self = setmetatable({}, smg)

    self.damageMult = 0.5
    self.firerate = 8
    self.lifespan = 2
    self.speed = 400
    self.properties = {}

    return self
end

return smg