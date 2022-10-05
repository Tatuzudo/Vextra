
local function getModPath()
	local mod = modApi:getCurrentMod()
	return mod.resourcePath
end

local Island = Class.inherit(IndexedEntry)
Island._entryType = "island"
Island._iconDef = {
	width = 80,
	height = 60,
	scale = 2,
	clip = true,
	outlinesize = 0,
	pathformat = "img/strategy/island1x_%s.png",
}

function Island:new(id, base)
	IndexedEntry.new(self, id, base)
	self:copyAssets({_id = "0"})
	self:copyAssets(base)

	self.paths = {
		["island"] = string.format("island%s", id),
		["island1x"] = string.format("island1x_%s", id),
		["island1x_out"] = string.format("island1x_%s_out", id),
		["islands/island_0"] = string.format("islands/island_%s_0", id),
		["islands/island_1"] = string.format("islands/island_%s_1", id),
		["islands/island_2"] = string.format("islands/island_%s_2", id),
		["islands/island_3"] = string.format("islands/island_%s_3", id),
		["islands/island_4"] = string.format("islands/island_%s_4", id),
		["islands/island_5"] = string.format("islands/island_%s_5", id),
		["islands/island_6"] = string.format("islands/island_%s_6", id),
		["islands/island_7"] = string.format("islands/island_%s_7", id),
		["islands/island_0_OL"] = string.format("islands/island_%s_0_OL", id),
		["islands/island_1_OL"] = string.format("islands/island_%s_1_OL", id),
		["islands/island_2_OL"] = string.format("islands/island_%s_2_OL", id),
		["islands/island_3_OL"] = string.format("islands/island_%s_3_OL", id),
		["islands/island_4_OL"] = string.format("islands/island_%s_4_OL", id),
		["islands/island_5_OL"] = string.format("islands/island_%s_5_OL", id),
		["islands/island_6_OL"] = string.format("islands/island_%s_6_OL", id),
		["islands/island_7_OL"] = string.format("islands/island_%s_7_OL", id)
	}
end

function Island:copy(base)
	if type(base) ~= 'table' then return end

	self.shift = base.shift
	self.magic = base.magic
	self.regionData = copy_table(base.regionData)
	self.network = copy_table(base.network)
end

function Island:copyAssets(base)
	if type(base) ~= 'table' then return end

	Assert.ResourceDatIsOpen()

	local root = "img/strategy/"
	local from = base._id
	local to = self._id
	local files = {
		string.format("%sisland%s.png", root, from), string.format("%sisland%s.png", root, to),
		string.format("%sisland1x_%s.png", root, from), string.format("%sisland1x_%s.png", root, to),
		string.format("%sisland1x_%s_out.png", root, from), string.format("%sisland1x_%s_out.png", root, to)
	}

	for k = 0, 7 do
		table.insert(files, string.format("%sislands/island_%s_%s.png", root, from, k))
		table.insert(files, string.format("%sislands/island_%s_%s.png", root, to, k))
		table.insert(files, string.format("%sislands/island_%s_%s_OL.png", root, from, k))
		table.insert(files, string.format("%sislands/island_%s_%s_OL.png", root, to, k))
	end

	for i = 1, #files, 2 do
		local src = files[i]
		local dst = files[i+1]
		if modApi:assetExists(src) then
			modApi:copyAsset(src, dst)
		end
	end
end

function Island:appendAssets(islandPath)
	Assert.ResourceDatIsOpen()
	Assert.Equals('string', type(islandPath), "Argument #1")

	islandPath = islandPath:gsub("[^/]$","%1/")
	local modPath = getModPath()

	for from, to in pairs(self.paths) do
		from = string.format("%s%s%s.png", modPath, islandPath, from)
		to = string.format("img/strategy/%s.png", to)

		if modApi:fileExists(from) then
			modApi:appendAsset(to, from)
		end
	end
end

function Island:getImagePath()
	return string.format(self._iconDef.pathformat, self._id)
end


modApi.island = IndexedList(Island)
