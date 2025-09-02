# 🔫 Artifact Switching & Shooting System

## 🎮 **Controls**

### **Shooting**
- **Hold Left Mouse Button** - Continuous fire with current weapon
- **Space Bar** - Single shot (legacy control, also works)

### **Weapon Switching**
- **Number Keys (1-9)** - Switch directly to specific weapons:
  - `1` - Pistol
  - `2` - Rifle  
  - `3` - Shotgun
  - `4` - Sniper
  - `5` - SMG
  - `6` - Burst
  - `7` - Beam
  - `8` - Minigun
  - `9` - Laser Cannon

- **Q/R Keys** - Cycle through available weapons:
  - `Q` - Previous weapon
  - `R` - Next weapon

### **Movement**
- **WASD** - Move player
- **Mouse** - Aim direction (projectiles fire toward mouse cursor)

## 📊 **On-Screen Information**

The game displays:
- **Current weapon name** (top-left)
- **Weapon stats**: damage, fire rate, active projectiles
- **Special properties** (if any): pierce, volley, burst, etc.
- **Controls help** (bottom of screen)

## 🔧 **How It Works**

### **Automatic System**
1. All weapons are **automatically loaded** from `data/artifacts.lua`
2. **No manual registration** needed - just add to config file
3. **Consistent behavior** across all weapons

### **Smart Aiming**
- Projectiles automatically aim toward mouse cursor
- Camera position is factored in for accurate shooting
- Different weapons have different projectile behaviors

### **Weapon Properties**
- **Volley** - Fires multiple projectiles (e.g., Shotgun: 8 pellets)
- **Burst** - Fires in quick bursts (e.g., Burst: 3 shots)
- **Pierce** - Projectiles go through enemies (e.g., Sniper)
- **High fire rate** - Rapid continuous fire (e.g., Minigun, Beam)

## 🎯 **Available Weapons**

| Weapon | Key | Damage | Fire Rate | Special |
|--------|-----|--------|-----------|---------|
| Pistol | 1 | 1.25× | 2/sec | Balanced |
| Rifle | 2 | 1.0× | 4/sec | Accurate |
| Shotgun | 3 | 0.9× | 0.75/sec | 8 pellets, spread |
| Sniper | 4 | 1.25× | 2/sec | Pierce, high speed |
| SMG | 5 | 0.5× | 8/sec | Fast fire |
| Burst | 6 | 1.1× | 0.75/sec | 3-shot burst |
| Beam | 7 | 0.025× | 60/sec | Laser beam |
| Minigun | 8 | 0.2× | 15/sec | Extreme fire rate |
| Laser Cannon | 9 | 2.0× | 1/sec | High damage, pierce |

## 🛠 **Technical Features**

### **Performance Optimized**
- Projectiles are automatically cleaned up when they expire
- Efficient collision detection
- Smooth camera tracking

### **Modular Design**
- Easy to add new weapons in `data/artifacts.lua`
- Consistent behavior via base artifact class
- Hot-reload support for development

### **Error Handling**
- Graceful fallback if weapon not found
- Nil-safe projectile handling
- Input validation for weapon switching

## 🎨 **Visual Feedback**

### **Real-time Stats**
- See damage multiplier and fire rate for current weapon
- Live projectile count shows active shots
- Special properties listed when applicable

### **Projectile Visualization**
- Different projectiles have consistent appearance
- Proper layering (projectiles draw behind player, above enemies)
- Smooth animation and movement

## 🔄 **Cycling Logic**

The weapon cycling system:
1. Gets all available weapons from configuration
2. Finds current weapon position in list
3. Moves to next/previous weapon in sequence
4. Wraps around (last weapon → first weapon)

## 🎮 **Usage Examples**

**Quick Combat:**
```
1. Hold LMB to start shooting
2. Press 3 for shotgun when enemies are close
3. Press 4 for sniper when enemies are far
4. Press Q/R to cycle if you forget the numbers
```

**Weapon Testing:**
```
1. Press 8 for minigun - watch the projectile count!
2. Press 9 for laser cannon - see the pierce effect
3. Press 3 for shotgun - notice the spread pattern
4. Press 6 for burst - observe the 3-shot pattern
```

The system is designed to be intuitive and responsive, giving you immediate access to any weapon while providing clear feedback about what you're using!
