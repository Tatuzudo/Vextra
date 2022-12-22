local mod = modApi:getCurrentMod()
local global = "Vextra"

-- Add Achievements
local achievements = {
	-- DNT_Something = modApi.achievements:add{
		-- id = "DNT_Something",
		-- name = "Name",
		-- tooltip = "Description.",
		-- image = mod.resourcePath.."img/achievements/placeholder.png",
		-- objective = 1, -- this could be true, false or a number
		-- global = global,
		-- addReward = addSquad1, -- to unlock secret squad
		-- remReward = remSquad1 -- to lock secret squad (for testing)
	-- },
	DNT_SelfSmush = modApi.achievements:add{
		id = "DNT_SelfSmush",
		name = "Pest Control",
		tooltip = "Finish off a Cockroach by smushing it with a another Vek.",
		image = mod.resourcePath.."img/achievements/placeholder.png",
		objective = 1,
		global = global,
	},
}

local modid = "Djinn_NAH_Tatu_Vextra"
function DNT_VextraChevio(id)
	if modApi.achievements:getProgress(modid,id) then return end
	modApi.achievements:trigger(modid,id)
end


-- Helper Functions
local function isGame()
	return true
		and Game ~= nil
		and GAME ~= nil
end

local function isMission()
	local mission = GetCurrentMission()

	return true
		and isGame()
		and mission ~= nil
		and mission ~= Mission_Test
end

local function isMissionBoard()
	return true
		and isMission()
		and Board ~= nil
		and Board:IsTipImage() == false
end

-- Secret Functions
local function addSquad1()

end

local function remSquad1()

end

-- Hook Functions

local function HOOK_PawnTracked(mission, pawn) --My attempt to get the pawn working, it's commented out (below) for now
	if isMissionBoard() then
		if not achievements.DNT_SelfSmush:isComplete() and pawn:GetType() == "DNT_StupidDummyPawn" then
			LOG(2)
			local space = pawn:GetSpace()
			Board:RemovePawn(pawn:GetId())
			local pawn = Board:GetPawn(space)
			if pawn and pawn:GetTeam() == TEAM_ENEMY then
				DNT_VextraChevio(DNT_SelfSmush)
			end
		end
	end
end


-- AddHooks
local function EVENT_onModsLoaded()
	--DNT_Vextra_ModApiExt:addPawnTrackedHook(HOOK_PawnTracked)
	-- modApi:addNextTurnHook(HOOK_nextTurn)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
