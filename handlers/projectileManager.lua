local ProjectileManager = {}
ProjectileManager.__index = ProjectileManager

function ProjectileManager.new()
    local self = setmetatable({}, ProjectileManager)
    
    self.projectiles = {}
    
    return self
end

function ProjectileManager:addProjectile(x, y, speed, lifespan, targetX, targetY, team, damage, critRate, critDamage, creatorId)
    local projectile = Projectile.new(x, y, speed, lifespan, targetX, targetY, team, damage, critRate, critDamage)
    
    projectile.creatorId = creatorId or nil
    
    table.insert(self.projectiles, projectile)
    return projectile
end

function ProjectileManager:update(dt)
    for i = #self.projectiles, 1, -1 do
        local projectile = self.projectiles[i]
        local state = projectile:update(dt)
        
        if state == "dead" then
            table.remove(self.projectiles, i)
        end
    end
end

function ProjectileManager:draw()
    for _, projectile in ipairs(self.projectiles) do
        projectile:draw()
    end
end

function ProjectileManager:checkCollisions(entities)
    for i = #self.projectiles, 1, -1 do
        local projectile = self.projectiles[i]
        
        for j, entity in ipairs(entities) do
            if projectile.team ~= entity.team then
                if projectile:collision(entity.x, entity.y, entity.width, entity.height) then
                    local creator = self:findCreator(projectile.creatorId, entities)
                    if creator then
                        creator:damageCalc(entity)
                    else
                        self:applyDefaultDamage(projectile, entity)
                    end
                    
                    table.remove(self.projectiles, i)
                    
                    return {
                        hit = true,
                        target = entity,
                        projectile = projectile
                    }
                end
            end
        end
    end
    
    return { hit = false }
end

function ProjectileManager:findCreator(creatorId, entities)
    if not creatorId then return nil end
    
    for _, entity in ipairs(entities) do
        if entity.id == creatorId then
            return entity
        end
    end
    
    return nil
end

function ProjectileManager:applyDefaultDamage(projectile, target)
    if projectile.damage then
        local baseDamage = math.max(
            projectile.damage / ((target.stats.armor[1] / 50) + 1),
            1
        )
        
        local finalDamage = math.floor(baseDamage * 10 + 0.5) / 10
        target.hp = target.hp - finalDamage
    end
end

function ProjectileManager:getProjectilesByTeam(team)
    local teamProjectiles = {}
    for _, projectile in ipairs(self.projectiles) do
        if projectile.team == team then
            table.insert(teamProjectiles, projectile)
        end
    end
    return teamProjectiles
end

function ProjectileManager:clear()
    self.projectiles = {}
end

function ProjectileManager:getProjectileCount()
    return #self.projectiles
end

return ProjectileManager
