local shotgun = {}
shotgun.__index = shotgun

function shotgun.new()
    local self = setmetatable({}, shotgun)

    self.damageMult = 0.9
    self.firerate = 0.75
    self.lifespan = 2
    self.speed = 250
    self.properties = {volley=8, spread=15}

    return self
end

return shotgun