-- Utility script for easily adding new artifacts
-- Usage example:
--   local addArtifact = require("utils.addArtifact")
--   addArtifact("new_weapon", {
--       damageMult = 1.5,
--       firerate = 3,
--       lifespan = 2.5,
--       speed = 400,
--       properties = {pierce = true}
--   })

local function addArtifact(name, config)
    -- Validate required fields
    local required = {"damageMult", "firerate", "lifespan", "speed"}
    for _, field in ipairs(required) do
        if config[field] == nil then
            error("Missing required field '" .. field .. "' for artifact '" .. name .. "'")
        end
    end
    
    -- Ensure properties table exists
    config.properties = config.properties or {}
    
    print("To add the artifact '" .. name .. "', add this to data/artifacts.lua:")
    print("")
    print("    " .. name .. " = {")
    print("        damageMult = " .. config.damageMult .. ",")
    print("        firerate = " .. config.firerate .. ",")
    print("        lifespan = " .. config.lifespan .. ",")
    print("        speed = " .. config.speed .. ",")
    
    if next(config.properties) then
        print("        properties = {")
        for key, value in pairs(config.properties) do
            if type(value) == "string" then
                print("            " .. key .. " = \"" .. value .. "\",")
            elseif type(value) == "boolean" then
                print("            " .. key .. " = " .. tostring(value) .. ",")
            else
                print("            " .. key .. " = " .. value .. ",")
            end
        end
        print("        }")
    else
        print("        properties = {}")
    end
    
    print("    },")
    print("")
    print("The artifact will be automatically available in-game after restarting.")
end

return addArtifact
