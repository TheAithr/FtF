Random = {}

function Random.weightedRoll(outcomes)
	local totalWeight = 0
	for i,v in ipairs(outcomes) do
		totalWeight = totalWeight + v.weight
	end
	
	local randomNumber = love.math.random(1, totalWeight)
	local cumulativeWeight = 0
	local outcome = nil
	
	for i,v in ipairs(outcomes) do
		cumulativeWeight = cumulativeWeight + v.weight
		if randomNumber <= cumulativeWeight then
			outcome = v.name
			break
		end
	end
	
	return outcome
end

function Random.tileRoll()
	return love.math.random(math.floor(Game.states.explore.tilesCleared/2), Game.states.explore.tilesCleared)
end

return Random