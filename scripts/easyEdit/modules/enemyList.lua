
function shuffle_list(list)
	for i = #list, 2, -1 do
		local j = math.random(1, i)

		-- swap entries
		list[i], list[j] = list[j], list[i]
	end
end

local EnemyList = Class.inherit(IndexedEntry)
EnemyList._debugName = "EnemyList"
EnemyList._entryType = "enemyList"

function EnemyList:new(id, base)
	IndexedEntry.new(self, id, base)
	self.enemies = {
		Core = {},
		Unique = {},
		Leaders = {},
		Bots = {}
	}
	self.categories = { "Core", "Core", "Core", "Leaders", "Unique", "Unique" }
end

function EnemyList:copy(base)
	if type(base) ~= 'table' then return end

	self.enemies = copy_table(base.enemies)
	self.categories = copy_table(base.categories)
end

function EnemyList:addEnemy(enemy, category)
	Assert.Equals('string', type(enemy), "Argument #1")
	Assert.Equals('string', type(category), "Argument #2")

	self.enemies[category] = self.enemies[category] or {}
	table.insert(self.enemies[category], enemy)
end

function EnemyList:getCategories()
	return self.enemies
end

function EnemyList:getObject(unitId, suffix)
	suffix = suffix or "1"
	return modApi.units:get(unitId..suffix)
end

function EnemyList:getContentType()
	return modApi.units
end

function EnemyList:isInvalid()
	for categoryId, category in pairs(self:getCategories()) do
		for _, enemyId in ipairs(category) do
			if _G[enemyId.."1"] == nil then
				return true
			end
		end
	end

	return false
end


modApi.enemyList = IndexedList(EnemyList)
