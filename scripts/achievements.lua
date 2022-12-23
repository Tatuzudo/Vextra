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
	DNT_Suicidal = modApi.achievements:add{
		id = "DNT_Suicidal",
		name = "No Diving",
		tooltip = "Have an Isopod leap to its doom.",
		image = mod.resourcePath.."img/achievements/placeholder.png",
		objective = 1,
		global = global,
	},
	DNT_DragonSlayer = modApi.achievements:add{
		id = "DNT_DragonSlayer",
		name = "Dragon Slayer",
		tooltip = "Have a Fly kill a Dragonfly.",
		image = mod.resourcePath.."img/achievements/placeholder.png",
		objective = 1,
		global = global,
	},
	DNT_Fartality = modApi.achievements:add{
		id = "DNT_Fartality",
		name = "Fartality!",
		tooltip = "Move stinkbugs to fart tiles 3 times in a single battle.",
		image = mod.resourcePath.."img/achievements/placeholder.png",
		objective = 1,
		global = global,
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

-- Variables
local flyAttack = false -- Dragon Slayer
local inStink = 0 -- Fartality

-- Hook Functions
local function HOOK_PawnKilled(mission, pawn)
	if isMissionBoard() then
		-- Dragon Slayer (Dragonfly kill)
		if not achievements.DNT_DragonSlayer:isComplete() and pawn:GetType():find("^DNT_Dragonfly") then
			if flyAttack then
				achievements.DNT_DragonSlayer:addProgress(1)
			end
		end
	end
end

local function HOOK_QueuedSkillStart(mission, pawn, weaponId, p1, p2)
	if isMissionBoard() then
		-- Dragon Slayer (Start Fly attack)
		if not achievements.DNT_DragonSlayer:isComplete() and pawn:GetType():find("^DNT_Fly") and not pawn:IsMech() then
			flyAttack = true
		end
		-- Fartality start count
		if not achievements.DNT_Fartality:isComplete() then
			if mission and mission.DNT_FartList then
				inStink = 0
				for i = 1, #mission.DNT_FartList do
					local stinker = Board:GetPawn(mission.DNT_FartList[i])
					if stinker and stinker:GetType():find("^DNT_Stinkbug") and not stinker:IsMech() then
						inStink = inStink + 1
					end
				end
			end
		end
		LOG(inStink)
	end
end

local function HOOK_QueuedSkillEnd(mission, pawn, weaponId, p1, p2)
	if isMissionBoard() then
		-- Suicidal
		if not achievements.DNT_Suicidal:isComplete() and pawn:GetType():find("^DNT_Pillbug") then
			local terrain = Board:GetTerrain(p2)
			local terrainDeadly = (terrain == TERRAIN_WATER and _G[pawn:GetType()].Massive == false) or terrain == TERRAIN_HOLE
			if terrainDeadly and not Board:GetPawn(p2) then
				achievements.DNT_Suicidal:addProgress(1)
			end
		end
		-- Dragon Slayer (End Fly attack)
		if pawn:GetType():find("^DNT_Fly") and not pawn:IsMech() then
			flyAttack = false
		end
		-- Fartality end count
		if not achievements.DNT_Fartality:isComplete() then
			modApi:scheduleHook(1000, function()
				if mission and mission.DNT_FartList then
					for i = 1, #mission.DNT_FartList do
						local stinker = Board:GetPawn(mission.DNT_FartList[i])
						if stinker and stinker:GetType():find("^DNT_Stinkbug") and not stinker:IsMech() then
							inStink = inStink - 1
						end
					end
				end
				LOG(inStink)
				mission.DNT_FartProgress = mission.DNT_FartProgress or 0
				mission.DNT_FartProgress = mission.DNT_FartProgress - math.min(inStink,0)
				if mission.DNT_FartProgress >= 3 then
					achievements.DNT_Fartality:addProgress(1)
				end
			end)
		end
	end
end

local function HOOK_SkillStart(mission, pawn, weaponId, p1, p2)
	if isMissionBoard() then
		-- Fartality start count
		if not achievements.DNT_Fartality:isComplete() then
			if mission and mission.DNT_FartList then
				inStink = 0
				for i = 1, #mission.DNT_FartList do
					local stinker = Board:GetPawn(mission.DNT_FartList[i])
					if stinker and stinker:GetType():find("^DNT_Stinkbug") and not stinker:IsMech() then
						inStink = inStink + 1
					end
				end
			end
		end
		LOG(inStink)
	end
end

local function HOOK_SkillEnd(mission, pawn, weaponId, p1, p2)
	if isMissionBoard() then
		-- Fartality end count
		if not achievements.DNT_Fartality:isComplete() then
			modApi:scheduleHook(1000, function()
				if mission and mission.DNT_FartList then
					for i = 1, #mission.DNT_FartList do
						local stinker = Board:GetPawn(mission.DNT_FartList[i])
						if stinker and stinker:GetType():find("^DNT_Stinkbug") and not stinker:IsMech() then
							inStink = inStink - 1
						end
					end
				end
				LOG(inStink)
				mission.DNT_FartProgress = mission.DNT_FartProgress or 0
				mission.DNT_FartProgress = mission.DNT_FartProgress - math.min(inStink,0)
				if mission.DNT_FartProgress >= 3 then
					achievements.DNT_Fartality:addProgress(1)
				end
			end)
		end
	end
end

-- AddHooks
local function EVENT_onModsLoaded()
	DNT_Vextra_ModApiExt:addSkillEndHook(HOOK_SkillEnd)
	DNT_Vextra_ModApiExt:addSkillStartHook(HOOK_SkillStart)
	DNT_Vextra_ModApiExt:addPawnKilledHook(HOOK_PawnKilled)
	DNT_Vextra_ModApiExt:addQueuedSkillEndHook(HOOK_QueuedSkillEnd)
	DNT_Vextra_ModApiExt:addQueuedSkillStartHook(HOOK_QueuedSkillStart)
	
	-- modApi:addNextTurnHook(HOOK_nextTurn)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)


