local sniper = {}
sniper.__index = sniper

function sniper.new()
    local self = setmetatable({}, sniper)

    self.damageMult = 1.25
    self.firerate = 2
    self.lifespan = 2
    self.speed = 1000
    self.properties = {pierce=true}

    return self
end

return sniper