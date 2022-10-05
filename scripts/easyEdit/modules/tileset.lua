
local defaultLoc = Point(-28,1)
-- extract tile image offsets
local tileLoc = {}
for key, point in pairs(Location) do
	local pattern = "^.-(tiles_.+)/([^.]+).png"
	local tileset = key:gsub(pattern, "%1")
	local tile = key:gsub(pattern, "%2")

	if tileset == "tiles_grass" then
		tileLoc[tile] = point
	end
end

local function getModPath()
	local mod = modApi:getCurrentMod()
	return mod.resourcePath
end

local Tileset = Class.inherit(IndexedEntry)
Tileset._entryType = "tileset"
Tileset._iconDef = {
	width = 120,
	height = 120,
	scale = 1,
	clip = true,
	outlinesize = 0,
	pathformat = "img/strategy/corp/%s_env.png",
}

function Tileset:new(id, base)
	self._id = id
	IndexedEntry.new(self, id, base)
	self.tileLoc = {}
	self.tileTooltip = {}
	self:setEmitters()
	self:copyAssets(base)
end

function Tileset:copy(base)
	if type(base) ~= 'table' then return end

	self.tileLoc = base.tileLoc
	self.tileTooltip = base.tileTooltip
	self.climate = base.climate
	self.rainChance = base.rainChance
	self.environmentChance = copy_table(base.environmentChance)
	self.crackChance = copy_table(base.crackChance)
	self:setEmitters(
		_G["Emitter_tiles_".. base._id],
		_G["Emitter_Burst_tiles_".. base._id]
	)
end

function Tileset:copyAssets(base, overwrite)
	if type(base) ~= 'table' then return end
	Assert.ResourceDatIsOpen()

	if overwrite == nil then
		overwrite = true
	end

	local resourceDat = modApi.resource:inner_paths()
	local files = {}
	local from = string.format("img/combat/tiles_%s/", base._id)
	local to = string.format("img/combat/tiles_%s/", self._id)

	for _, filepath in ipairs(resourceDat) do
		if modApi:stringStartsWith(filepath, from) then
			files[#files+1] = filepath
		end
	end

	for _, filepath in ipairs(files) do
		local destination = filepath:gsub(from, to)
		if overwrite or not modApi:assetExists(destination) then
			modApi:copyAsset(filepath, destination)
			local filename = filepath:gsub("(.*/)(.*)(.png)","%2")
			local loc = self.tileLoc[filename] or tileLoc[filename] or defaultLoc
			local combatPath = destination:sub(5, -1)
			Location[combatPath] = loc
		end
	end
end

function Tileset:addTile(id, loc)
	Assert.ResourceDatIsOpen()
	Assert.Equals('string', type(id), "Argument #1")

	loc = loc or self.tileLoc[id] or tileLoc[id] or defaultLoc

	Assert.TypePoint(loc, "Argument #2")
	Assert.NotEquals('nil', type(self.tilePath), "self.tilePath")

	local modPath = getModPath()
	local filePath = string.format("%s%s%s.png", modPath, self.tilePath, id)

	Assert.FileExists(filePath)

	local resourcePath = string.format("combat/tiles_%s/%s.png", self._id, id)
	Location[resourcePath] = loc

	modApi:appendAsset("img/".. resourcePath, filePath)
end

function Tileset:addTiles(tiles)
	for id, loc in pairs(tiles) do

		if type(id) == 'number' then
			id = loc
			loc = nil
		end

		self:addTile(id, loc)
	end
end

function Tileset:appendAssets(tilePath)
	Assert.ResourceDatIsOpen()
	Assert.Equals({'nil', 'string'}, type(tilePath), "Argument #1")

	if tilePath then
		self.tilePath = tilePath
							:gsub("\\", "/")
							:gsub("([^/]+)$","%1/")
	end

	Assert.NotEquals('nil', type(self.tilePath), "self.tilePath")

	local modPath = getModPath()
	local files = mod_loader:enumerateFilesIn(modPath .. self.tilePath)
	local images = {}

	for _, file in ipairs(files) do
		if modApi:stringEndsWith(file, ".png") then
			if file == "env.png" then
				self:setTilesetIcon(self.tilePath .. file)
			else
				table.insert(images, file:sub(1, -5))
			end
		end
	end

	self:addTiles(images)
end

function Tileset:setTilesetIcon(filePath)
	Assert.ResourceDatIsOpen()
	Assert.Equals('string', type(filePath), "Argument #1")
	Assert.FileRelativeToCurrentModExists(filePath)

	local modPath = getModPath()
	modApi:appendAsset(string.format("img/strategy/corp/%s_env.png", self._id), modPath .. filePath)
end

function Tileset:setClimate(climate)
	Assert.Equals('string', type(climate), "Argument #1")

	self.climate = climate
end

function Tileset:setRainChance(rainChance)
	Assert.Equals('number', type(rainChance), "Argument #1")

	self.rainChance = rainChance
end

function Tileset:setCrackChance(crackChance)
	Assert.Equals('number', type(crackChance), "Argument #1")

	self.crackChance = crackChance
end

function Tileset:setEnvironmentChance(environmentChance)
	Assert.Equals({'number', 'table'}, type(environmentChance), "Argument #1")

	self.environmentChance = environmentChance
end

function Tileset:setEmitters(emitter_dust, emitter_burst)
	Assert.Equals({'nil', 'table'}, type(emitter_dust), "Argument #1")
	Assert.Equals({'nil', 'table'}, type(emitter_burst), "Argument #2")

	emitter_dust = emitter_dust or {}
	emitter_burst = emitter_burst or {}

	_G["Emitter_tiles_".. self._id] = Emitter_Dust:new(emitter_dust)
	_G["Emitter_tiles_".. self._id].image = "combat/tiles_".. self._id .."/dust.png"
	_G["Emitter_Burst_tiles_".. self._id] = Emitter_Burst:new(emitter_burst)
	_G["Emitter_Burst_tiles_".. self._id].image = "combat/tiles_".. self._id .."/dust.png"
end

function Tileset:setTileTooltip(tooltip)
	Assert.Equals('table', type(tooltip), "Argument #1")
	Assert.Equals('string', type(tooltip.tile), "tile")
	Assert.Equals('string', type(tooltip.title), "title")
	Assert.Equals('string', type(tooltip.text), "text")

	self.tileTooltip[tooltip.tile] = {
		title = tooltip.title,
		text = tooltip.text
	}
end

function Tileset:onDisabled()
	for tile, tooltip in pairs(self.tileTooltip) do
		modApi.modLoaderDictionary["Tile_"..tile.."_Title"] = nil
		modApi.modLoaderDictionary["Tile_"..tile.."_Text"] = nil
	end
end

function Tileset:onEnabled()
	for tile, tooltip in pairs(self.tileTooltip) do
		modApi.modLoaderDictionary["Tile_"..tile.."_Title"] = tooltip.title
		modApi.modLoaderDictionary["Tile_"..tile.."_Text"] = tooltip.text
	end
end

function Tileset:getRainChance()
	return self.rainChance
end

function Tileset:getCrackChance(tileType)
	return self.crackChance
end

function Tileset:getEnvironmentChance(tileType, difficulty)
	local chance = self.environmentChance

	if type(chance) == 'table' then
		if type(chance[difficulty]) == 'table' then
			chance = chance[difficulty][tileType]
		else
			chance = chance[tileType]
		end
	end

	return type(chance) == 'number' and chance or 0
end

function Tileset:getImagePath()
	return string.format(self._iconDef.pathformat, self._id)
end


modApi.tileset = IndexedList(Tileset)
