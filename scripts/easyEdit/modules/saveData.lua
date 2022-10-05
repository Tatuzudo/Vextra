
-- header
local path = GetParentPath(...)
local serializer = require(path.."serializer")
local explorer = require(path.."explorer")
local direxists = explorer.direxists
local fileexists = explorer.fileexists
local listdirs = explorer.listdirs
local listfiles = explorer.listfiles
local listobjects = explorer.listobjects
local pruneExtension = explorer.pruneExtension
local remdir = explorer.remdir
local isdir = explorer.isdir
local isfile = explorer.isfile

local modules = {
	-- modApi.units,
	modApi.enemyList,
	modApi.missionList,
	modApi.bossList,
	modApi.structureList,
	modApi.islandComposite,
	modApi.world,
}

-- defs
local LOGD = easyEdit.LOG
local LOGDF = easyEdit.LOGF
local DIRS = {
	-- "units",
	"enemyList",
	"bossList",
	"missionList",
	"structureList",
	"islandComposite",
}

local savedata = {}
local saveRoot = GetSavedataLocation()
local saveLoc
local fullSaveLoc
local modConfig

local function getModConfig()
	if modConfig == nil then
		modConfig = mod_loader:getModConfig()
	end

	return modConfig
end

local function isFromUninstalledMod(result)
	local modId = result and result.mod or nil
	if modId then
		local modConfig = getModConfig()
		local mod = modConfig[modId]

		if mod == nil or not mod.enabled then
			return true
		end
	end

	return false
end


local function loadFromFile(path)
	LOGD("EasyEdit - Load from file ../"..path)
	local result

	if path:sub(-4, -1) == ".lua" then
		result = serializer.deserialize(saveRoot..path)
	end

	if isFromUninstalledMod(result) then
		return nil
	end

	return result
end

local function loadFromDir(path, depth)
	LOGD("EasyEdit - Load from dir ../"..path)
	local result = {}

	if not depth or depth > 0 then
		for _, dir in ipairs(listdirs(saveRoot..path)) do
			result[dir] = loadFromDir(path..dir.."/", depth - 1)
		end
	end

	for _, file in ipairs(listfiles(saveRoot..path)) do
		local id = pruneExtension(file)
		result[id] = loadFromFile(path..file)
	end

	if not next(result) then
		LOGD("EasyEdit - Nothing to load from ../"..path)
		return nil
	end

	LOGD("EasyEdit - Loading from ../"..path)

	return result
end

local function saveToFile(cache, path)
	LOGD("EasyEdit - Save to file ../"..path)

	serializer.configureFile(
		path,
		function(obj)
			clear_table(obj)
			clone_table(obj, cache)
		end
	)
end

local function saveToDir(cache, path)
	LOGD("EasyEdit - Save to dir ../"..path)

	for key, value in pairs(cache) do
		saveToFile(value, path..key..".lua")
	end
end

-- Force load savedata from disc.
function savedata:load()
	if self.currentProfile == nil then
		Assert.Error("No current profile")
	end

	LOGF("EasyEdit - Load savedata for profile [%s]", self.currentProfile)
	self.cache = loadFromDir(saveLoc, 2) or {}
	self:updateLiveData()
end

function savedata:saveAsFile(id, data)
	if self.currentProfile == nil then
		Assert.Error("No current profile")
	end

	data = copy_table(data)
	self.cache[id] = data
	saveToFile(data, saveLoc..id..".lua")
end

function savedata:saveAsDir(id, data)
	if self.currentProfile == nil then
		Assert.Error("No current profile")
	end

	data = copy_table(data)
	self.cache[id] = data

	if pruneExtension(id) ~= id then
		LOGF("EasyEdit - %q is not a directory", id)
		return
	end

	-- delete lua file with same name as dir
	if isfile(fullSaveLoc..id..".lua") then
		LOGD("EasyEdit - delete "..fullSaveLoc..id..".lua")
		os.remove(fullSaveLoc..id..".lua")
	end

	local dir = id.."/"
	saveToDir(data, saveLoc..dir)

	-- delete lua files of removed objects
	for _, file in ipairs(listfiles(fullSaveLoc..dir)) do
		local id = pruneExtension(file)
		if data[id] == nil then
			if isfile(fullSaveLoc..dir..file) then
				LOGD("EasyEdit - delete "..fullSaveLoc..dir..file)
				os.remove(fullSaveLoc..dir..file)
			end
		end
	end

	self:updateLiveData()
end

function savedata:mkdirs()
	if self.currentProfile == nil then
		Assert.Error("No current profile")
	end

	os.mkdir(fullSaveLoc)

	for _, dir in pairs(DIRS) do
		os.mkdir(fullSaveLoc..dir)
	end
end

-- Apply cached savedata to lists and update game objects.
function savedata:updateLiveData()
	LOG("EasyEdit - Update livedata")
	for _, module in ipairs(modules) do
		module:update()
	end
end

local function changeEasyEditProfile(_, newProfile)
	local oldProfile = easyEdit.savedata.currentProfile
	if oldProfile ~= nil then
		LOGF("EasyEdit - Unset profile [%s]", oldProfile)
		LOGF("EasyEdit - Unload savedata for profile [%s]", oldProfile)
		LOG("EasyEdit - Update livedata")
		for _, module in ipairs(modules) do
			module:reset()
		end
	end

	if newProfile == "" then
		newProfile = nil
	end

	easyEdit.savedata.currentProfile = newProfile
	if newProfile == nil then
		return
	end

	LOGF("EasyEdit - Set profile [%s]", newProfile)
	modConfig = mod_loader:getModConfig()
	saveLoc = "easyEdit_"..newProfile.."/"
	fullSaveLoc = saveRoot..saveLoc
	easyEdit.savedata:mkdirs()
	easyEdit.savedata:load()
end

function savedata:init()
	if savedata.initialized then
		return
	end

	savedata.initialized = true
	changeEasyEditProfile(nil, Settings.last_profile)
end

easyEdit.savedata = savedata

modApi.events.onProfileChanged:subscribe(changeEasyEditProfile)
