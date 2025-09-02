# Optimized Artifact System

The artifact system has been completely rewritten to make adding and modifying artifacts much easier. Here's what changed and how to use it.

## What's New

### ✅ Fixed Issues:
1. **Fixed the original bug**: Added nil checks in `basic.lua` to prevent the `ipairs` error
2. **Centralized configuration**: All artifact stats are now in `data/artifacts.lua`
3. **Automatic discovery**: No more manual registration - artifacts are loaded automatically
4. **Consistent structure**: All artifacts inherit from a base class
5. **Easy modification**: Change stats without touching code

### 🏗️ New Architecture:

1. **Base Artifact Class** (`objects/artifacts/base.lua`)
   - Provides common functionality for all artifacts
   - Handles projectile creation, cooldowns, and special properties
   - Supports volley, burst, pierce, and other effects

2. **Artifact Manager** (`handlers/artifactManager.lua`)
   - Combines factory and registry functionality
   - Automatically creates and manages artifacts from configuration data
   - Validates configuration on load
   - Provides complete artifact lifecycle management

3. **Configuration File** (`data/artifacts.lua`)
   - Contains all artifact statistics
   - Easy to modify without code changes
   - Self-documenting format

## How to Use

### Adding a New Artifact

1. **Simple way**: Edit `data/artifacts.lua` and add your artifact:

```lua
your_new_weapon = {
    damageMult = 1.5,      -- Damage multiplier
    firerate = 4,          -- Attacks per second
    lifespan = 3,          -- Projectile lifetime in seconds
    speed = 400,           -- Projectile speed
    properties = {         -- Special properties
        pierce = true,     -- Projectiles go through enemies
        volley = 5,        -- Fire multiple projectiles
        spread = 10,       -- Spread angle for volley
        burstCount = 3     -- Burst fire count
    }
}
```

2. **Helper utility**: Use the `utils/addArtifact.lua` helper:

```lua
local addArtifact = require("utils.addArtifact")
addArtifact("laser_cannon", {
    damageMult = 2.0,
    firerate = 1,
    lifespan = 5,
    speed = 800,
    properties = {pierce = true}
})
```

### Modifying Existing Artifacts

Simply edit the values in `data/artifacts.lua`. Changes take effect on restart.

### Special Properties

The system supports these special properties:

- `volley = N` - Fire N projectiles
- `spread = degrees` - Spread angle for volley shots
- `burstCount = N` - Fire N shots in quick succession
- `pierce = true` - Projectiles pass through enemies
- `melee = true` - Close-range weapon
- `grimoire = true` - Magic-based weapon

### Available Artifacts

All these artifacts are automatically loaded:
- `beam` - High rate of fire, low damage
- `burst` - 3-shot burst fire
- `pistol` - Balanced sidearm
- `rifle` - Accurate, long-range
- `shotgun` - Spread shot with 8 pellets
- `smg` - Fast firing, low damage
- `sniper` - High damage, piercing
- `sword` - Melee weapon
- `grimoire` - Magic weapon

### Switching Artifacts

In your player code, you can switch between artifacts:

```lua
-- Switch to a different artifact
player.artifactManager:switch("sniper")

-- Attack with current artifact
player.artifactManager:attack()

-- Get current artifact info
local info = player.artifactManager:getCurrentInfo()
print("Current weapon:", info.name, "DPS:", info.damageMult * info.firerate)
```

## Migration from Old System

The old individual artifact files are no longer needed. Everything is now handled through:
1. `data/artifacts.lua` - Configuration
2. `objects/artifacts/base.lua` - Common functionality
3. `handlers/artifactManager.lua` - Unified management system

## Benefits

1. **Easier balancing**: Modify stats in one place
2. **Faster development**: Add new weapons in seconds
3. **More consistent**: All weapons behave similarly
4. **Less code duplication**: Common functionality is shared
5. **Better maintainability**: Clear separation of data and logic

## Example: Adding a New Weapon Type

To add a "minigun" that fires rapidly with low damage:

```lua
-- Add to data/artifacts.lua
minigun = {
    damageMult = 0.2,
    firerate = 15,
    lifespan = 1.5,
    speed = 600,
    properties = {}
}
```

That's it! The minigun is now available in-game.
