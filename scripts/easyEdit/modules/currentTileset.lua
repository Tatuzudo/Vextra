
local path = GetParentPath(...)
local GAME_STATE = require(path.."gameState")

-- The game automatically changes the tileset used in tipimages,
-- missions and test mech scenario at various points.
-- When launching Into the Breach, it starts as "grass".
-- Exiting a run to start a new one without closing the application,
-- will _not_ reset the current tileset.

-- easyEdit:getCurrentTileset returns the current tileset.

-- easyEdit.event.onTilesetChanged can be subscribed to, to get notified
-- when the tileset changes.

local currentTileset = "grass"
local testMechTileset = "grass"

function easyEdit:getCurrentTileset()
	return currentTileset
end

local function isFinalIsland()
	return RegionData.iBattleRegion == 20
end

local function isFinalIslandAvailable()
	return Game and Game:GetSector() > 2
end

local function getCurrentCorpTileset()
	-- If a mission on the final island does not have
	-- a custom tileset, the game will set it to volcano.
	if isFinalIsland() then
		return "volcano"
	end

	local corp_id = Game:GetCorp().name:sub(1, -6)

	if corp_id == "" then
		local island = RegionData.island

		if island == -1 then
			return "grass"
		end

		local islandData = RegionData["island"..island]
		corp_id = islandData.corporation
	end

	return _G[corp_id].Tileset
end

local function setCurrentTileset(tileset, testTileset)
	local oldTileset = currentTileset

	if currentTileset ~= tileset then
		currentTileset = tileset

		testTileset = testTileset or tileset
		testMechTileset = testTileset

		easyEdit.events.onTilesetChanged:dispatch(tileset, oldTileset)
	end
end

-- When entering a mission;
-- the enabled tileset changes to that mission's tileset;
-- which is either a custom tileset, or that corporation's tileset.
modApi.events.onMissionChanged:subscribe(function(mission)
	if mission then
		local saveData = mission:GetSaveData()
		local missionTileset = ""
		local corpTileset = getCurrentCorpTileset()

		-- If a mission has already been flagged as won,
		-- the game will not check its CustomTile variable.
		if not saveData or saveData.victory ~= 1 then
			missionTileset = mission.CustomTile:sub(7, -1)
		end

		if missionTileset == "" then
			missionTileset = corpTileset
		end

		setCurrentTileset(missionTileset, corpTileset)
	end
end)

-- When entering an island from the map view;
-- the enabled tileset changes to the corporation's tileset.
easyEdit.events.onGameStateChanged:subscribe(function(newState, oldState)
	if
		oldState == GAME_STATE.MAP     and
		newState == GAME_STATE.ISLAND
	then
		setCurrentTileset(getCurrentCorpTileset())
	end
end)

-- When entering an island from the main menu;
-- the enabled tileset changes to the corporation's tileset.
easyEdit.events.onGameStateChanged:subscribe(function(newState, oldState)
	if
		oldState == GAME_STATE.MAIN_MENU and
		newState == GAME_STATE.ISLAND
	then
		setCurrentTileset(getCurrentCorpTileset())
	end
end)

-- When entering map view from island view
-- when the final island is available;
-- the enabled tileset always changes to "volcano",
-- and the test mech scenario tileset changes to "grass".
easyEdit.events.onGameStateChanged:subscribe(function(newState, oldState)
	if
		isFinalIslandAvailable()      and
		oldState == GAME_STATE.ISLAND and
		newState == GAME_STATE.MAP
	then
		setCurrentTileset("volcano", "grass")
	end
end)

-- When entering map view from main menu
-- when the final island is available;
-- the enabled tileset always changes to "volcano",
-- and the test mech scenario tileset changes to "grass".
easyEdit.events.onGameStateChanged:subscribe(function(newState, oldState)
	if
		isFinalIslandAvailable()         and
		oldState == GAME_STATE.MAIN_MENU and
		newState == GAME_STATE.MAP
	then
		setCurrentTileset("volcano", "grass")
	end
end)

-- When entering test mech scenario,
-- the tileset is either changed to the corporation's tileset,
-- or "grass" if the tileset was "volcano".
easyEdit.events.onGameStateChanged:subscribe(function(newState, oldState)
	if
		newState == GAME_STATE.MISSION_TEST and
		currentTileset ~= testMechTileset
	then
		setCurrentTileset(testMechTileset)
	end
end)
