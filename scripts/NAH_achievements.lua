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
		image = mod.resourcePath.."img/achievements/selfsmush.png",
		objective = 1,
		global = global,
	},
	DNT_PsychoDragonfly = modApi.achievements:add{
		id = "DNT_PsychoDragonfly",
		name = "We Didn't Start the Fire",
		tooltip = "Ignite two Vek with an attack from a dragonfly.",
		image = mod.resourcePath.."img/achievements/placeholder.png",
		objective = 1,
		global = global,
	},
}

local modid = "Djinn_NAH_Tatu_Vextra"
function DNT_VextraChevio(id)
	progress = modApi.achievements:getProgress(modid,id)
	if progress ~= 0 then return end
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

local fireCount = 0
local dragonflyAttack = false

local function HOOK_MissionUpdateHook(mission, pawn) --My attempt to get the pawn working, it's commented out (below) for now
	if isMissionBoard() then
		--SelfSmush/PestControl Cockroach Achievement
		if not achievements.DNT_SelfSmush:isComplete() then
			mission.DNT_CockroachMines = mission.DNT_CockroachMines or {}
			for _, point in pairs(mission.DNT_CockroachMines) do
				local pawn = Board:GetPawn(point)
				if pawn and pawn:GetTeam() == TEAM_ENEMY then
					DNT_VextraChevio("DNT_SelfSmush")
				end
			end
			mission.DNT_CockroachMines = {}
			for i, point in ipairs(Board) do
				local item = Board:GetItem(point)
				if item and item:find("^DNT_Corpse") ~= nil then
					table.insert(mission.DNT_CockroachMines,point)
				end
			end
		end
	end
end

local function HOOK_QueuedSkillStart(mission, pawn, weaponId, p1, p2)
	if isMissionBoard() then
		-- Psycho Dragonfly (Start Dragonfly attack)
		if not achievements.DNT_PsychoDragonfly:isComplete() and pawn:GetType():find("^DNT_Dragonfly") and not pawn:IsMech() then
			dragonflyAttack = true
			fireCount = 0
		end
	end
end

local function HOOK_QueuedSkillEnd(mission, pawn, weaponId, p1, p2)
	if isMissionBoard() then
		-- Psycho Dragonfly (End Dragonfly attack)
		modApi:scheduleHook(1000, function()
			dragonflyAttack = false
		end)
	end
end

local function HOOK_PawnIsFire(mission,pawn,isFire)
	if isMissionBoard() then
		-- Psycho Dragonfly (Count Fire)
		if not achievements.DNT_PsychoDragonfly:isComplete() and dragonflyAttack and isFire and pawn:GetTeam() == TEAM_ENEMY then
			fireCount = fireCount + 1
			if fireCount >= 2 then
				DNT_VextraChevio("DNT_PsychoDragonfly")
			end
		end
	end
end


-- AddHooks
local function EVENT_onModsLoaded()
	modApi:addMissionUpdateHook(HOOK_MissionUpdateHook)

	DNT_Vextra_ModApiExt:addQueuedSkillEndHook(HOOK_QueuedSkillEnd)
	DNT_Vextra_ModApiExt:addQueuedSkillStartHook(HOOK_QueuedSkillStart)
	DNT_Vextra_ModApiExt:addPawnIsFireHook(HOOK_PawnIsFire)
	-- modApi:addNextTurnHook(HOOK_nextTurn)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
