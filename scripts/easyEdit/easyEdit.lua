
local skipInit = true
	and easyEdit ~= nil
	and easyEdit.initialized == true

if skipInit then
	return easyEdit
end

local VERSION = "1.5.5"
local MOD_LOADER_TARGET = "2.7.2"
local path = GetParentPath(...)

local function finalizeInit(self)
	LOGDF("Easy Edit %s initializing", self.version)
	Assert.Traceback = true

	require(path.."ui/editor_easyEdit")

	if not self.enabled then
		LOGDF("Easy Edit %s did not initialize because it is disabled", self.version)
		return
	end

	if self.modLoaderTarget ~= modApi.version then
		LOGF(""
			.."WARNING: This version of Easy Edit is specifically made for mod loader"
			.."version %s, and may not work with properly with the current mod loader"
			.."version %s",
			tostring(self.modLoaderTarget),
			tostring(modApi.version)
		)
	end

	require(path.."debug")
	require(path.."global")
	require(path.."ml_fixes")
	require(path.."datastructures/binarySearch")
	require(path.."datastructures/sort")
	require(path.."modules/events")
	require(path.."modules/gameState")
	require(path.."modules/indexedList")
	require(path.."modules/units")
	require(path.."modules/unitImage")
	require(path.."modules/weapons")
	require(path.."modules/missions")
	require(path.."modules/structures")
	require(path.."modules/corporation")
	require(path.."modules/tileset")
	require(path.."modules/structure")
	require(path.."modules/structureList")
	require(path.."modules/enemyList")
	require(path.."modules/bossList")
	require(path.."modules/missionList")
	require(path.."modules/island")
	require(path.."modules/islandComposite")
	require(path.."modules/world")
	require(path.."modules/currentTileset")
	require(path.."modules/saveData")
	require(path.."alter")
	require(path.."ui/widget/Ui")
	require(path.."ui/widget/UiDebug")
	require(path.."ui/widget/UiCustomTooltip")
	require(path.."ui/widget/UiGroupTooltip")
	require(path.."ui/menues")
	require(path.."ui/editor_cleanProfile")

	LOGDF("Easy Edit %s initialized", self.version)
end

local function onModsMetadataDone()
	local isHighestVersion = true
		and easyEdit.initialized ~= true
		and easyEdit.version == VERSION

	if isHighestVersion then
		easyEdit:finalizeInit()
		easyEdit.initialized = true
	end
end


local isNewerVersion = false
	or easyEdit == nil
	or VERSION > easyEdit.version

if isNewerVersion then
	easyEdit = easyEdit or {}
	easyEdit.version = VERSION
	easyEdit.modLoaderTarget = MOD_LOADER_TARGET
	easyEdit.path = path
	easyEdit.finalizeInit = finalizeInit

	-- easyEdit needs to be initialized after all mods have been enumerated,
	-- but before any mod begins initializing. onModsMetadataDone will suffice.
	modApi.events.onModsMetadataDone:subscribe(onModsMetadataDone)
end

return easyEdit
