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
		-- golbal = global,
		-- addReward = addSquad1, -- to unlock secret squad
		-- remReward = remSquad1 -- to lock secret squad (for testing)
	-- },
	DNT_Suicidal = modApi.achievements:add{
		id = "DNT_Suicidal",
		name = "Yeet",
		tooltip = "Have an Isopod leap to its doom.",
		image = mod.resourcePath.."img/achievements/placeholder.png",
		objective = 1,
		golbal = global,
	},
}

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
local function HOOK_QueuedSkillEnd(mission, pawn, weaponId, p1, p2)
	if isMissionBoard() then
		-- Suicidal
		if not achievements.DNT_Suicidal:isComplete() and pawn:GetType():find("^DNT_Pillbug") then
			LOG(2)
			local terrain = Board:GetTerrain(p2)
			local terrainDeadly = (terrain == TERRAIN_WATER and _G[pawn:GetType()].Massive == false) or terrain == TERRAIN_HOLE
			if terrainDeadly and not Board:GetPawn(p2) then
				LOG(3)
				achievements.DNT_Suicidal:addProgress(1)
			end
		end
	end
end


-- AddHooks
local function EVENT_onModsLoaded()
	DNT_Vextra_ModApiExt:addQueuedSkillEndHook(HOOK_QueuedSkillEnd)
	-- modApi:addNextTurnHook(HOOK_nextTurn)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)


