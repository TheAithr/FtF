local Projectile = require("objects.projectile")

local BaseArtifact = {}
BaseArtifact.__index = BaseArtifact

function BaseArtifact.new(config)
    local self = setmetatable({}, BaseArtifact)
    
    -- Default values
    self.damageMult = config.damageMult or 1
    self.firerate = config.firerate or 1
    self.lifespan = config.lifespan or 2
    self.speed = config.speed or 300
    self.properties = config.properties or {}
    self.projectiles = {}
    self.cooldown = 0
    
    -- Copy any additional config properties
    for key, value in pairs(config) do
        if not self[key] then
            self[key] = value
        end
    end
    
    return self
end

function BaseArtifact:attack()
    if self.cooldown <= 0 then
        local player = Game.states.explore.player
        local mx, my = love.mouse.getPosition()
        
        -- Convert screen coordinates to world coordinates
        local camera = Game.states.explore.camera
        local worldX = mx + camera.x
        local worldY = my + camera.y
        
        -- Handle special properties
        if self.properties.volley then
            self:_createVolley(player, worldX, worldY)
        elseif self.properties.burstCount then
            self:_createBurst(player, worldX, worldY)
        else
            self:_createProjectile(player, worldX, worldY)
        end
        
        self.cooldown = 1 / (self.firerate * player.stats.attackRate[1])
    end
end

function BaseArtifact:_createProjectile(player, targetX, targetY)
    table.insert(self.projectiles, Projectile.new(
        player.x, player.y, self.speed, self.lifespan, targetX, targetY, player.team, player.vx, player.vy
    ))
end

function BaseArtifact:_createVolley(player, targetX, targetY)
    local volley = self.properties.volley or 1
    local spread = self.properties.spread or 0
    
    for i = 1, volley do
        local angle = math.atan2(targetY - player.y, targetX - player.x)
        local spreadAngle = (i - (volley + 1) / 2) * math.rad(spread) / volley
        local finalAngle = angle + spreadAngle
        
        local adjustedTargetX = player.x + math.cos(finalAngle) * 1000
        local adjustedTargetY = player.y + math.sin(finalAngle) * 1000
        
        table.insert(self.projectiles, Projectile.new(
            player.x, player.y, self.speed, self.lifespan, adjustedTargetX, adjustedTargetY, player.team, player.vx, player.vy
        ))
    end
end

function BaseArtifact:_createBurst(player, targetX, targetY)
    local burstCount = self.properties.burstCount or 3
    local burstSpread = self.properties.burstSpread or 5  -- Small random spread for burst shots
    
    -- Fire all burst shots at once with slight spread
    for i = 1, burstCount do
        -- Add small random spread to each shot in the burst
        local angle = math.atan2(targetY - player.y, targetX - player.x)
        local spreadAngle = (math.random() - 0.5) * math.rad(burstSpread)
        local finalAngle = angle + spreadAngle
        
        local adjustedTargetX = player.x + math.cos(finalAngle) * 1000
        local adjustedTargetY = player.y + math.sin(finalAngle) * 1000
        
        table.insert(self.projectiles, Projectile.new(
            player.x, player.y, self.speed, self.lifespan, adjustedTargetX, adjustedTargetY, player.team, player.vx, player.vy
        ))
    end
end

function BaseArtifact:update(dt)
    self.cooldown = math.max(0, self.cooldown - dt)
    
    for i = #self.projectiles, 1, -1 do
        local projectile = self.projectiles[i]
        if projectile:update(dt) == "dead" then
            table.remove(self.projectiles, i)
        end
    end
end

return BaseArtifact
