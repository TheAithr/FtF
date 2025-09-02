local rifle = {}
rifle.__index = rifle

function rifle.new()
    local self = setmetatable({}, rifle)

    self.damageMult = 1
    self.firerate = 4
    self.lifespan = 4
    self.speed = 350
    self.properties = {}

    return self
end

return rifle