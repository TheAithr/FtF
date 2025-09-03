local grimoire = {}
grimoire.__index = grimoire

function grimoire.new()
    local self = setmetatable({}, grimoire)

    self.damageMult = 1
    self.firerate = 1
    self.lifespan = 1
    self.speed = 1
    self.properties = {grimoire=true}

    return self
end

return grimoire