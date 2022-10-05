
local StructureList = Class.inherit(IndexedEntry)
StructureList._debugName = "StructureList"
StructureList._entryType = "structureList"

function StructureList:new(id, base)
	IndexedEntry.new(self, id, base)
	self.PowAssets = {}
	self.TechAssets = {}
	self.RepAssets = {}
end

function StructureList:copy(base)
	if type(base) ~= 'table' then return end

	self.RepAssets = copy_table(base.RepAssets)
	self.PowAssets = copy_table(base.PowAssets)
	self.TechAssets = copy_table(base.TechAssets)
end

function StructureList:addAssets(...)
	local args = select("#", ...)
	for i = 1, args do
		local structure = select(i, ...)
		Assert.Equals('string', type(structure), "Argument #".. i)
		Assert.Equals('table', type(_G[structure]), "Invalid entry")

		local str = _G[structure]
		if str.Reward == REWARD_REP then
			table.insert(self.RepAssets, structure)
		elseif str.Reward == REWARD_POWER then
			table.insert(self.PowAssets, structure)
		elseif str.Reward == REWARD_TECH then
			table.insert(self.TechAssets, structure)
		else
			error("Unexpected structure reward: Expected number in range [0,2], but was "..tostring(str.Reward))
		end
	end
end

function StructureList:addPowAssets(...)
	local args = select("#", ...)
	for i = 1, args do
		local structure = select(i, ...)
		Assert.Equals('string', type(structure), "Argument #".. i)

		table.insert(self.PowAssets, structure)
	end
end

function StructureList:addTechAssets(...)
	local args = select("#", ...)
	for i = 1, args do
		local structure = select(i, ...)
		Assert.Equals('string', type(structure), "Argument #".. i)

		table.insert(self.TechAssets, structure)
	end
end

function StructureList:addRepAssets(...)
	local args = select("#", ...)
	for i = 1, args do
		local structure = select(i, ...)
		Assert.Equals('string', type(structure), "Argument #".. i)

		table.insert(self.RepAssets, structure)
	end
end

function StructureList:getCategories()
	return {
		Rep = self.RepAssets,
		Power = self.PowAssets,
		Core = self.TechAssets,
	}
end

function StructureList:getObject(structureId)
	return modApi.structures:get(structureId)
end

function StructureList:isContentList()
	return true
end

function StructureList:getContentType()
	return modApi.structures
end

function StructureList:isInvalid()
	for categoryId, category in pairs(self:getCategories()) do
		for _, structureId in ipairs(category) do
			if _G[structureId] == nil then
				return true
			end
		end
	end

	return false
end


modApi.structureList = IndexedList(StructureList)
