local artifactRegister = {}
artifactRegister.__index = artifactRegister

function artifactRegister.new()
    return setmetatable({
        artifacts = {},
        current = nil
    }, artifactRegister)
end

function artifactRegister:update(dt)
    for key,artifact in pairs(artifacts) do
        artifact:update(dt)
    end
end

function artifactRegister:add(name, artifact)
    self.artifacts[name] = artifact
end

function artifactRegister:switch(name)
    self.current = self.artifacts[name]
end

function artifactRegister:attack()
    if self.current.attack then
        self.current:attack()
    end
end

return artifactRegister