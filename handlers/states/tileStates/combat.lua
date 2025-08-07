require("game")

local windowWidth, windowHeight = love.graphics.getDimensions()

local combat = {
	attack = Button.new(5, windowHeight - 105, windowWidth/3 - 10, 100, "Attack"),
	ability = Button.new(5 + windowWidth/3, windowHeight - 105, windowWidth/3 - 10, 100, "Ability"),
	heal = Button.new(5 + 2 * (windowWidth/3), windowHeight - 105, windowWidth/3 - 10, 100, "Heal"),
	run = Button.new(windowWidth - 105, windowHeight - 140, 100, 25, "Run Away"),

	enemy = {
		stats = {
		maxHealth = 50,
		health = 50,
		damage = 10,
		critRate = 0,
		critDamage = 2,
		armor = 0,
		lifesteal = 0
		}
	}
}

baseStats = {
	maxHealth = 50,
	damage = 10,
	critRate = 0,
	critDamage = 2,
	armor = 0,
	lifesteal = 0
}

scaling = {
	maxHealth = 8,
	damage = 0.5,
	critRate = 1,
	critDamage = 0.05,
	armor = 0.5,
	lifesteal = 0.2
}


function combat:enter()
	local player = Game.states.explore.player

	Game.states.combat.enemy = Game.states.combat.enemy or {}
	local enemy = Game.states.combat.enemy

	for stat, base in pairs(baseStats) do
        enemy[stat] = base + (scaling[stat] * Game.states.explore.tilesCleared)
    end

	if enemy.critRate >= 100 then
		enemy.critRate = 100
	end
	
	enemy.maxHealth = math.floor(enemy.maxHealth)
	
    enemy.health = enemy.maxHealth or 100
	player.health = player.maxHealth or 100
end

function combat:leave()   
	Game.states.combat.enemy.stats.health = Game.states.combat.enemy.stats.maxHealth or 100
	Game.states.explore.player.stats.health = Game.states.explore.player.stats.maxHealth or 100
end

function combat:update(dt)
	if Game.states.combat.enemy.health <= 0 then
        local tileX = math.floor(Game.states.explore.player.x / Game.states.explore.tileSize)
        local tileY = math.floor(Game.states.explore.player.y / Game.states.explore.tileSize)
        local tile = Game:getTile(tileX, tileY)

        if tile 
		and not tile.cleared then
            tile:clear()
			Game.states.explore.gold = Game.states.explore.gold + love.math.random(math.min(math.abs(tileX), math.abs(tileY)), math.max(math.abs(tileX), math.abs(tileY)))
        end
    end
end

function combat:draw()
	self:drawEnemyHealth()
	self:drawEnemyStats()
	self:drawPlayerHealth()
	
	Game.states.combat.attack:draw()
    Game.states.combat.ability:draw()
    Game.states.combat.heal:draw()
    Game.states.combat.run:draw()
end	

function combat:mousepressed(x, y, button)
    if Game.states.combat.attack:mousepressed(x, y, button) then
        self:turnHandler(1)
    end
    if Game.states.combat.ability:mousepressed(x, y, button) then
        self:turnHandler(2)
    end
    if Game.states.combat.heal:mousepressed(x, y, button) then
        self:turnHandler(3)
    end
    if Game.states.combat.run:mousepressed(x, y, button) then
        self:turnHandler(4)
    end
end

function combat:mousereleased(x, y, button)
    Game.states.combat.attack:mousereleased(x, y, button)
    Game.states.combat.ability:mousereleased(x, y, button)
    Game.states.combat.heal:mousereleased(x, y, button)
    Game.states.combat.run:mousereleased(x, y, button)
end

function combat:keypressed(key, scancode)
	if scancode == "1" then
		self:turnHandler(1)
	end
	if scancode == "2" then
		self:turnHandler(2)
	end
	if scancode == "3" then
		self:turnHandler(3)
	end
	if scancode == "4" then
		self:turnHandler(4)
	end
end

function combat:drawEnemyHealth()
	local barWidth = 300
	local barHeight = 20
	local x = (windowWidth - barWidth) / 2
	local y = 30
	local healthPercent = math.max(Game.states.combat.enemy.stats.health / Game.states.combat.enemy.stats.maxHealth, 0)

	love.graphics.setColor(0.2, 0.2, 0.2, 1)
	love.graphics.rectangle("fill", x, y, barWidth, barHeight)

	love.graphics.setColor(1, 0.2, 0.2, 1)
	love.graphics.rectangle("fill", x, y, barWidth * healthPercent, barHeight)
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", x, y, barWidth, barHeight)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf("Enemy HP: " .. Game.states.combat.enemy.stats.health .. "/" .. Game.states.combat.enemy.stats.maxHealth, x, y + barHeight + 5, barWidth, "center")
end

function combat:drawEnemyStats()
	love.graphics.print("Enemy Stats", 5, 85)
	love.graphics.print("Damage: " .. Game.states.combat.enemy.stats.damage, 5, 100)
	love.graphics.print("Crit Rate: " .. Game.states.combat.enemy.stats.critRate, 5, 115)
	love.graphics.print("Armor: " .. Game.states.combat.enemy.stats.armor, 5, 130)
	love.graphics.print("LifeSteal: " .. Game.states.combat.enemy.stats.lifesteal, 5, 145)
	
end

function combat:drawPlayerHealth()
	local barWidth = 300
	local barHeight = 20
	local x = (windowWidth - barWidth) / 2
	local y = windowHeight - 150
	local healthPercent = math.max(Game.states.explore.player.stats.health / Game.states.explore.player.stats.maxHealth, 0)
	
	love.graphics.setColor(0.2, 0.2, 0.2, 1)
	love.graphics.rectangle("fill", x, y, barWidth, barHeight)
	
	love.graphics.setColor(1, 0.2, 0.2, 1)
	love.graphics.rectangle("fill", x, y, barWidth * healthPercent, barHeight)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", x, y, barWidth, barHeight)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf("Player HP: " .. Game.states.explore.player.stats.health .. "/" .. Game.states.explore.player.stats.maxHealth, x, y + barHeight + 5, barWidth, "center")
end

function combat:turnHandler(action)
	local escaped = false
	if action == 1 then
		self.damageCalc(Game.states.explore.player, Game.states.combat.enemy)
		self:checkEnemyDeath()
	elseif action == 2 then
		print("Ability Stuff")
	elseif action == 3 then
		self.healCalc(Game.states.explore.player)
	else
		Game.stateManager:switch("explore")
		escaped = true
	end
	
	if not escaped then
		roll = love.math.random(1, 2)
		if roll == 1 then
			self.damageCalc(Game.states.combat.enemy, Game.states.explore.player)
			self:checkPlayerDeath()
		elseif roll == 2 then
			self.healCalc(Game.states.combat.enemy)
		end
	end
end

function combat.damageCalc(user, target)
	local critRoll = love.math.random(100)
	if critRoll <= user.stats.critRate then
		target.stats.health = target.stats.health - user.stats.critDamage * (math.max(user.stats.damage - target.stats.armor, 1))
		if user.stats.lifesteal > 0 then
			user.stats.health = math.min(user.stats.health + user.stats.critDamage * user.stats.lifesteal, user.stats.maxHealth)
		end
	else
		target.stats.health = target.stats.health - math.max(user.stats.damage - target.stats.armor, 1)
		if user.stats.lifesteal > 0 then
			user.stats.health = math.min(user.stats.health + user.stats.lifesteal, user.stats.maxHealth)
		end
	end
end

function combat.healCalc(user)
	user.stats.health = math.min(user.stats.health + user.stats.maxHealth / 10, user.stats.maxHealth)
end

function combat:checkPlayerDeath()
	if Game.states.explore.player.stats.health <= 0 then
		Game.stateManager:switch("death")
	end
end

function combat:checkEnemyDeath()
	if Game.states.combat.enemy.stats.health <= 0 then
		tile:clear()
	end
end
	
return combat
