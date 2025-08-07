local Item = {}

local items = {}

local function loadItemsFromFolder(path)
	local fullPath = "objects.items." .. path
	local files = love.filesystem.getDirectoryItems("objects/items/" .. path)

	for _, file in ipairs(files) do
		if file:match("%.lua$") then
			local itemName = file:sub(1, -5)
			local modulePath = fullPath .. "." .. itemName
			local ok, module = pcall(require, modulePath)
			if ok and module then
				table.insert(items, module.new())
			else
				print("Failed to load item:", modulePath, module)
			end
		end
	end
end

function Item:init()
	items = {}
	loadItemsFromFolder("t1")
	loadItemsFromFolder("t2")
end

function Item:createItems(inventory)
	for i, item in ipairs(items) do
		inventory[i] = item
	end
end

function Item:generateItem(inventory)
	local source = inventory or items
	local roll = love.math.random(#source)
	local item = source[roll]
	if item ~= nil then
		item:addStack()
	end
	return item
end

function Item:addStack(item, inventory)
	for i, invItem in ipairs(inventory) do
		if invItem.name == item.name then
			invItem:addStack()
			break
		end
	end
end

function Item:cheat(inventory)
	for i, item in ipairs(inventory) do
		for j=1, 10 do
			item:addStack()
		end
	end
end

return Item