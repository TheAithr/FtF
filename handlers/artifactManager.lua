local BaseArtifact = require("objects.artifacts.base")
local artifactConfigs = require("data.artifacts")

local ArtifactManager = {}
ArtifactManager.__index = ArtifactManager

-- Validate artifact configuration
local function validateConfig(name, config)
    local required = {"damageMult", "firerate", "lifespan", "speed"}
    for _, field in ipairs(required) do
        if config[field] == nil then
            error("Artifact '" .. name .. "' missing required field: " .. field)
        end
    end
    return true
end

-- Auto-validate all configurations on load
for name, config in pairs(artifactConfigs) do
    validateConfig(name, config)
end

-- Create a new artifact manager instance
function ArtifactManager.new()
    local self = setmetatable({
        artifacts = {},
        current = nil
    }, ArtifactManager)
    
    -- Auto-load all configured artifacts
    self:loadAllArtifacts()
    
    return self
end

-- Factory Methods --

-- Create a single artifact from configuration
function ArtifactManager:createArtifact(name)
    local config = artifactConfigs[name]
    if not config then
        error("Unknown artifact: " .. tostring(name))
    end
    
    return BaseArtifact.new(config)
end

-- Load all configured artifacts
function ArtifactManager:loadAllArtifacts()
    for name, config in pairs(artifactConfigs) do
        self.artifacts[name] = BaseArtifact.new(config)
    end
end

-- Get all available artifact names
function ArtifactManager:getAvailableArtifacts()
    local names = {}
    for name, _ in pairs(artifactConfigs) do
        table.insert(names, name)
    end
    return names
end

-- Registry Methods --

-- Add an artifact (can be used for custom artifacts not in config)
function ArtifactManager:add(name, artifact)
    self.artifacts[name] = artifact
end

-- Remove an artifact
function ArtifactManager:remove(name)
    if self.current == self.artifacts[name] then
        self.current = nil
    end
    self.artifacts[name] = nil
end

-- Switch to a different artifact
function ArtifactManager:switch(name)
    if not self.artifacts[name] then
        error("Artifact '" .. tostring(name) .. "' not found. Available: " .. table.concat(self:getAvailableArtifacts(), ", "))
    end
    self.current = self.artifacts[name]
end

-- Get the current artifact
function ArtifactManager:getCurrent()
    return self.current
end

-- Get a specific artifact by name
function ArtifactManager:get(name)
    return self.artifacts[name]
end

-- Check if an artifact exists
function ArtifactManager:has(name)
    return self.artifacts[name] ~= nil
end

-- Management Methods --

-- Update all artifacts (called every frame)
function ArtifactManager:update(dt)
    for name, artifact in pairs(self.artifacts) do
        if artifact.update then
            artifact:update(dt)
        end
    end
end

-- Attack with current artifact
function ArtifactManager:attack()
    if self.current and self.current.attack then
        self.current:attack()
    end
end

-- Draw projectiles from current artifact
function ArtifactManager:draw()
    -- Draw projectiles from ALL artifacts, not just the current one
    -- This ensures projectiles don't disappear when switching weapons
    for name, artifact in pairs(self.artifacts) do
        if artifact.projectiles then
            for i, projectile in ipairs(artifact.projectiles) do
                if projectile.draw then
                    projectile:draw()
                end
            end
        end
    end
end

-- Get current artifact info for UI
function ArtifactManager:getCurrentInfo()
    if not self.current then return nil end
    
    -- Count total projectiles from all weapons
    local totalProjectiles = 0
    for name, artifact in pairs(self.artifacts) do
        if artifact.projectiles then
            totalProjectiles = totalProjectiles + #artifact.projectiles
        end
    end
    
    return {
        name = self:getCurrentName(),
        damageMult = self.current.damageMult,
        firerate = self.current.firerate,
        lifespan = self.current.lifespan,
        speed = self.current.speed,
        properties = self.current.properties,
        cooldown = self.current.cooldown,
        projectileCount = #self.current.projectiles,
        totalProjectileCount = totalProjectiles
    }
end

-- Get current artifact name
function ArtifactManager:getCurrentName()
    if not self.current then return nil end
    
    for name, artifact in pairs(self.artifacts) do
        if artifact == self.current then
            return name
        end
    end
    return nil
end

-- Reload artifacts from config (useful for development/modding)
function ArtifactManager:reload()
    local currentName = self:getCurrentName()
    
    -- Clear existing artifacts
    self.artifacts = {}
    self.current = nil
    
    -- Reload config
    package.loaded["data.artifacts"] = nil
    artifactConfigs = require("data.artifacts")
    
    -- Validate and load all artifacts
    for name, config in pairs(artifactConfigs) do
        validateConfig(name, config)
        self.artifacts[name] = BaseArtifact.new(config)
    end
    
    -- Restore current artifact if it still exists
    if currentName and self.artifacts[currentName] then
        self:switch(currentName)
    end
end

return ArtifactManager
