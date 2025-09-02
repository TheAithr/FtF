return {
    beam = {
        damageMult = 0.025,
        firerate = 60,
        lifespan = 1,
        speed = 200,
        properties = {}
    },
    
    burst = {
        damageMult = 1.1,
        firerate = 0.75,
        lifespan = 2,
        speed = 300,
        properties = {burstCount = 3, burstSpread = 3}
    },
    
    pistol = {
        damageMult = 1.25,
        firerate = 2,
        lifespan = 2,
        speed = 300,
        properties = {}
    },
    
    rifle = {
        damageMult = 1,
        firerate = 4,
        lifespan = 4,
        speed = 350,
        properties = {}
    },
    
    shotgun = {
        damageMult = 0.9,
        firerate = 0.25,
        lifespan = 2,
        speed = 250,
        properties = {volley = 8, spread = 15}
    },
    
    smg = {
        damageMult = 0.5,
        firerate = 8,
        lifespan = 2,
        speed = 400,
        properties = {}
    },
    
    sniper = {
        damageMult = 1.25,
        firerate = 0.25,
        lifespan = 2,
        speed = 1000,
        properties = {pierce = true}
    },
    
    sword = {
        damageMult = 1.25,
        firerate = 2,
        lifespan = 2,
        speed = 2,
        properties = {melee = true}
    },
    
    grimoire = {
        damageMult = 1,
        firerate = 1,
        lifespan = 1,
        speed = 1,
        properties = {grimoire = true}
    }
}
