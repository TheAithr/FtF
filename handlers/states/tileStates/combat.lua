require("game")

local windowWidth, windowHeight = love.graphics.getDimensions()

local combat = {
	buttons = {
		attack = Button.new(5, windowHeight - 105, windowWidth/3 - 10, 100, "Attack"),
		ability = Button.new(5 + windowWidth/3, windowHeight - 105, windowWidth/3 - 10, 100, "Ability"),
		heal = Button.new(5 + 2 * (windowWidth/3), windowHeight - 105, windowWidth/3 - 10, 100, "Heal"),
		run = Button.new(windowWidth - 105, windowHeight - 140, 100, 25, "Run Away")
	},

	enemy = {
		stats = {
		maxHealth = {50, "Max Health", 4, 50},
		damage = {10, "Base Damage", 0.25, 10},
		critRate = {0, "Crit Chance", 0.5, 0},
		critDamage = {2, "Crit Damage", 0.025, 2},
		armor = {0, "Armor", 0.25, 0},
		lifesteal = {0, "Lifesteal", 0.1, 0}
		},
		hp = 50
	}
}

function combat:enter()
	local player = Game.states.explore.player

	Game.states.combat.enemy = Game.states.combat.enemy or {}
	local enemy = Game.states.combat.enemy

	for stat, base in pairs(enemy.stats) do
        enemy.stats[stat][1] = enemy.stats[stat][4] + (enemy.stats[stat][3] * Game.states.explore.tilesCleared)
    end

	if enemy.stats.critRate[1] >= 100 then
		enemy.stats.critRate[1] = 100
	end
	
	enemy.stats.maxHealth[1] = math.floor(enemy.stats.maxHealth[1])
	
    enemy.hp = enemy.stats.maxHealth[1] or 100
	player.hp = player.stats.maxHealth[1] or 100
end

function combat:leave()   
	Game.states.combat.enemy.hp = Game.states.combat.enemy.stats.maxHealth[1] or 100
	Game.states.explore.player.hp = Game.states.explore.player.stats.maxHealth[1] or 100
end

function combat:cleared()
	tile:clear()
	local random = require("lib.random")
	Game.states.explore.gold = Game.states.explore.gold + random.tileRoll()
	Game.states.explore.player.xp = Game.states.explore.player.xp + 10 * Game.states.explore.tilesCleared
	Game.states.explore.player:updateStats()
end

function combat:update(dt)
	if Game.states.combat.enemy.hp <= 0 then
        local tileX = math.floor(Game.states.explore.player.x / Game.states.explore.tileSize)
        local tileY = math.floor(Game.states.explore.player.y / Game.states.explore.tileSize)
        local tile = Game:getTile(tileX, tileY)

        if tile and not tile.cleared then self:cleared() end
    end
end

function combat:draw()
	self:drawEnemyStats()
	
	self:drawHealthBar("Enemy HP", self.enemy.hp, self.enemy.stats.maxHealth[1], 30)
    self:drawHealthBar("Player HP", Game.states.explore.player.hp, Game.states.explore.player.stats.maxHealth[1], windowHeight-150)
   for _,b in pairs(combat.buttons) do b:draw() end
end	

function combat:mousepressed(x, y, button)
	local buttons = Game.states.combat.buttons
	if buttons.attack:mousepressed(x, y, button) then self:turnHandler(1) end
	if buttons.ability:mousepressed(x, y, button) then self:turnHandler(2) end
	if buttons.heal:mousepressed(x, y, button) then self:turnHandler(3) end
	if buttons.run:mousepressed(x, y, button) then self:turnHandler(4) end
end

function combat:mousereleased(x, y, button)
    local buttons = Game.states.combat.buttons
	if buttons.attack:mousereleased(x, y, button) then self:turnHandler(1) end
	if buttons.ability:mousereleased(x, y, button) then self:turnHandler(2) end
	if buttons.heal:mousereleased(x, y, button) then self:turnHandler(3) end
	if buttons.run:mousereleased(x, y, button) then self:turnHandler(4) end
end

function combat:keypressed(_, sc)
	for i=1,4 do if sc==tostring(i) then self:turnHandler(i) end end
end

function combat:drawHealthBar(label, hp, maxHp, y)
	local w, h = 300, 20 
	local x = (windowWidth - w) / 2
	local percent = math.max(hp/maxHp, 0)

	love.graphics.setColor(0.2,0.2,0.2,1)
    love.graphics.rectangle("fill",x,y,w,h)
    love.graphics.setColor(1,0.2,0.2,1)
    love.graphics.rectangle("fill",x,y,w*percent,h)
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line",x,y,w,h)
    love.graphics.printf(label..": "..hp.."/"..maxHp,x,y+h+5,w,"center")
end

function combat:drawEnemyStats()
	love.graphics.print("Enemy Stats", 5, 85)
	love.graphics.print("Damage: " .. Game.states.combat.enemy.stats.damage[1], 5, 100)
	love.graphics.print("Crit Rate: " .. Game.states.combat.enemy.stats.critRate[1], 5, 115)
	love.graphics.print("Armor: " .. Game.states.combat.enemy.stats.armor[1], 5, 130)
	love.graphics.print("LifeSteal: " .. Game.states.combat.enemy.stats.lifesteal[1], 5, 145)
	
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
	if critRoll <= user.stats.critRate[1] then
		target.hp = target.hp - math.floor(user.stats.critDamage[1] * (math.max(user.stats.damage[1] / ((target.stats.armor[1] / 50) + 1), 1)) * 10 + 0.5) / 10
		if user.stats.lifesteal[1] > 0 then
			user.hp = math.min(user.hp + user.stats.critDamage[1] * user.stats.lifesteal[1], user.stats.maxHealth[1])
		end
	else
		target.hp = target.hp - math.floor(math.max(user.stats.damage[1] / ((target.stats.armor[1] / 50) + 1), 1)* 10 + 0.5) / 10
		if user.stats.lifesteal[1] > 0 then
			user.hp = math.min(user.hp + user.stats.lifesteal[1], user.stats.maxHealth[1])
		end
	end
end

function combat.healCalc(user)
	user.hp = math.floor(math.min(user.hp + user.stats.maxHealth[1] / 10, user.stats.maxHealth[1])* 10 + 0.5) / 10
end

function combat:checkPlayerDeath()
	if Game.states.explore.player.hp <= 0 then
		Game.stateManager:switch("death")
	end
end

function combat:checkEnemyDeath()
	if Game.states.combat.enemy.hp <= 0 then
		self:cleared()
	end
end
	
return combat
