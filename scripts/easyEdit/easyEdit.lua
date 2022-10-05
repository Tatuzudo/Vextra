
local skipInit = true
	and easyEdit ~= nil
	and easyEdit.initialized == true

if skipInit then
	return easyEdit
end

local VERSION = "1.5.3"
local path = GetParentPath(...)

local function finalizeInit(self)
	LOGDF("Easy Edit %s initializing", self.version)
	Assert.Traceback = true

	require(path.."ui/editor_easyEdit")
	require(path.."modules/assets")
	require(path.."modules/animations")

	if not self.enabled then
		LOGDF("Easy Edit %s did not initialize because it is disabled", self.version)
		return
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
	require(path.."ui/textevent")
	require(path.."ui/widget/UiTextBox")
	require(path.."ui/deco/DecoTextBox")
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
	easyEdit.path = path
	easyEdit.finalizeInit = finalizeInit

	-- easyEdit needs to be initialized after all mods have been enumerated,
	-- but before any mod begins initializing. onModsMetadataDone will suffice.
	modApi.events.onModsMetadataDone:subscribe(onModsMetadataDone)
end

return easyEdit
