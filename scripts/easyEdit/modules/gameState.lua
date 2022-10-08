
-- Check current sector each frame. If an increment is detected,
-- it means we have left an island. When leaving the 4th island,
-- sector does not increase, so no event is dispatched.
-- Event onGameStateChanged can be used to detect when the island
-- has been fully left, when it is reflected in the save data.
modApi.events.onFrameDrawStart:subscribe(function()
	if not Game or not GAME then
		return
	end

	local sector = Game:GetSector()

	if GAME.currentSector == nil then
		GAME.currentSector = sector
	elseif GAME.currentSector < sector then
		GAME.currentSector = sector

		easyEdit.events.onIslandLeft:dispatch(GAME.Island)
	end
end)

local GAME_STATE_MAIN_MENU = 0
local GAME_STATE_MAP = 1
local GAME_STATE_ISLAND = 2
local GAME_STATE_MISSION = 3
local GAME_STATE_MISSION_TEST = 4

local currentState = GAME_STATE_MAIN_MENU

function modApi:getGameState()
	return currentState
end

local function setGameState(state)
	local oldState = currentState

	if currentState ~= state then
		currentState = state
		easyEdit.events.onGameStateChanged:dispatch(currentState, oldState)
	end

	if Game then
		GAME.currentState = currentState
	end
end

modApi.events.onGameExited:subscribe(function()
	setGameState(GAME_STATE_MAIN_MENU)
end)

local function updateGameState()
	local mission = GetCurrentMission()

	if not Game then
		setGameState(GAME_STATE_MAIN_MENU)
	elseif mission == Mission_Test then
		setGameState(GAME_STATE_MISSION_TEST)
	elseif mission then
		setGameState(GAME_STATE_MISSION)
	elseif RegionData.podRewards then
		setGameState(GAME_STATE_ISLAND)
	else
		setGameState(GAME_STATE_MAP)
	end
end

modApi.events.onPreIslandSelection:subscribe(function()
	setGameState(GAME_STATE_ISLAND)
end)

easyEdit.events.onIslandLeft:subscribe(function()
	setGameState(GAME_STATE_MAP)
end)

modApi.events.onSaveDataUpdated:subscribe(updateGameState)
modApi.events.onMissionChanged:subscribe(updateGameState)

return {
	MAIN_MENU = GAME_STATE_MAIN_MENU,
	MAP = GAME_STATE_MAP,
	ISLAND = GAME_STATE_ISLAND,
	MISSION = GAME_STATE_MISSION,
	MISSION_TEST = GAME_STATE_MISSION_TEST,
}
