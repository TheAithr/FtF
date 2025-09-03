local beam = {}
beam.__index = beam

function beam.new()
    local self = setmetatable({}, beam)

    self.damageMult = 0.025
    self.firerate = 60
    self.lifespan = 1
    self.speed = 200
    self.properties = {}
    self.projectiles = {}
    self.cooldown = 0

    return self
end

function beam:attacK()
    if self.cooldown <= 0 then
        local player = Game.states.explore.player
        local mx, my = love.mouse.getPosition()
        table.insert(self.projectiles, Projectile.new(player.x, player.y, self.speed, self.lifespan, mx, my, player.team))
	    self.cooldown = 1/(self.firerate * player.attackRate[1])
    end
end

function beam:update(dt)
    self.cooldown = self.cooldown - dt
end

function beam:update(dt)
    self.cooldown = self.cooldown - dt
    for i,v in ipairs(self.projectiles) do
        if v:update() == "dead" then
            table.remove(self.projectiles, v)
        end
    end
end

return beam