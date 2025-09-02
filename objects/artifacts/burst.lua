local burst = {}
burst.__index = burst

function burst.new()
    local self = setmetatable({}, burst)

    self.damageMult = 1.1
    self.firerate = 0.75
    self.lifespan = 2
    self.speed = 300
    self.properties = {burstCount=3, currentBurst=0}
    self.projectiles = {}
    self.cooldown = 0

    return self
end

function burst:attacK()
    if self.cooldown <= 0 then
        local player = Game.states.explore.player
        local mx, my = love.mouse.getPosition()
        table.insert(self.projectiles, Projectile.new(player.x, player.y, self.speed, self.lifespan, mx, my, player.team))
        if currentBurst < burstCount then
            self.cooldown = 1/(self.firerate * player.attackRate[1] * 3)
            burstCount = burstCount + 1
        else
            burstCount = 0
	        self.cooldown = 1/(self.firerate * player.attackRate[1])
        end
    end
end

function burst:update(dt)
    self.cooldown = self.cooldown - dt
    for i,v in ipairs(self.projectiles) do
        if v:update() == "dead" then
            table.remove(self.projectiles, v)
        end
    end
end

return burst