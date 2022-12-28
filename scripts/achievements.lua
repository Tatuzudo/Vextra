local mod = modApi:getCurrentMod()
local global = "Vextra"

local customAnim = require(mod.scriptPath .."libs/customAnim")

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
		image = mod.resourcePath.."img/achievements/nodiving.png",
		objective = 1,
		global = global,
	},
	DNT_DragonSlayer = modApi.achievements:add{
		id = "DNT_DragonSlayer",
		name = "Dragon Slayer",
		tooltip = "Have a Fly kill a Dragonfly.",
		image = mod.resourcePath.."img/achievements/dragonslayer.png",
		objective = 1,
		global = global,
		addReward = DNT_checkSquadProgress,
		remReward = DNT_checkSquadProgress,
	},
	DNT_Fartality = modApi.achievements:add{
		id = "DNT_Fartality",
		name = "Fartality!",
		tooltip = "Move Stinkbugs to stink tiles 3 times in a single battle.",
		image = mod.resourcePath.."img/achievements/placeholder.png",
		objective = 1,
		global = global,
		addReward = DNT_checkSquadProgress,
		remReward = DNT_checkSquadProgress,
	},
	DNT_Picnic = modApi.achievements:add{
		id = "DNT_Picnic",
		name = "Safe for a Picnic",
		tooltip = "Kill the Anthill Leader and finish the battle with no Ants left on the board.",
		image = mod.resourcePath.."img/achievements/safe4picnic.png",
		objective = 1,
		global = global,
	},
	DNT_UnstableGround = modApi.achievements:add{
		id = "DNT_UnstableGround",
		name = "Unstable Ground",
		tooltip = "Drop the Antlion Leader into a chasm by breaking the ground beneath it.",
		image = mod.resourcePath.."img/achievements/placeholder.png",
		objective = 1,
		global = global,
		secret = true,
	},
	DNT_LightningRod = modApi.achievements:add{
		id = "DNT_LightningRod",
		name = "Lightning Rod",
		tooltip = "Have a Thunderbug be struck by a lightning tile.",
		image = mod.resourcePath.."img/achievements/lightningrod.png",
		objective = 1,
		global = global,
		secret = true,
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

-- Hook Functions
local function HOOK_PawnKilled(mission, pawn)
	if isMissionBoard() then
		-- Dragon Slayer (Dragonfly kill)
		if not achievements.DNT_DragonSlayer:isComplete() and pawn:GetType():find("^DNT_Dragonfly") then
			if flyAttack then
				achievements.DNT_DragonSlayer:addProgress(1)
			end
		end
		-- Unstable Ground
		if not achievements.DNT_UnstableGround:isComplete() then
			if pawn:GetType():find("^DNT_AntlionBoss") and Board:GetTerrain(pawn:GetSpace()) == TERRAIN_HOLE then
				achievements.DNT_UnstableGround:addProgress(1)
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
		modApi:scheduleHook(500, function()
			if pawn:GetType():find("^DNT_Fly") and not pawn:IsMech() then
				flyAttack = false
			end
		end)
	end
end

-- local function HOOK_SkillStart(mission, pawn, weaponId, p1, p2)
	-- if isMissionBoard() then

	-- end
-- end

-- local function HOOK_SkillEnd(mission, pawn, weaponId, p1, p2)
	-- if isMissionBoard() then

	-- end
-- end

local function HOOK_PawnPositionChanged(mission, pawn, oldPosition)
	if isMissionBoard() then
		-- Fartality
		if not achievements.DNT_Fartality:isComplete() then
			local currPos = pawn:GetSpace()
			local anim = IsPassiveSkill("Electric_Smoke") and "DNT_FartFrontDark" or "DNT_FartFront"
			modApi:scheduleHook(500, function()
				if customAnim:Is(mission,pawn:GetSpace(),anim) and currPos == pawn:GetSpace() then
					mission.DNT_FartProgress = mission.DNT_FartProgress or 0
					mission.DNT_FartProgress = mission.DNT_FartProgress + 1
					if mission.DNT_FartProgress >= 3 then
						achievements.DNT_Fartality:addProgress(1)
					end
				end
			end)
		end
	end
end

-- Lightning Rog (not a hook)

-- local Old_Env_Lightning = Env_Lightning.GetAttackEffect

-- function Env_Lightning:GetAttackEffect(location)
	-- local effect = Old_Env_Lightning(location)
	
	-- modApi:scheduleHook(1000, function()
		-- if not achievements.DNT_LightningRod:isComplete() then
			-- if Board:GetPawn(location) and Board:GetPawn(location):GetType():find("^DNT_Thunderbug") then
				-- achievements.DNT_LightningRod:addProgress(1)
			-- end
		-- end
	-- end)
	
	-- return effect
-- end

function Env_Lightning:GetAttackEffect(location) -- maybe change this later
	
	local effect = SkillEffect()
	
	local damage = SpaceDamage(location, DAMAGE_DEATH)
	damage.sAnimation = "LightningBolt"..random_int(2)
	
	local rain = location - Point(1,1)
	local script = "Board:SetWeather(3,"..RAIN_NORMAL..","..rain:GetString()..",Point(2,2),2)"
	effect:AddScript(script)
	effect:AddSound("/props/lightning_strike")
	
	effect:AddDelay(1)
	
	effect:AddDamage(damage)
	
	modApi:scheduleHook(1000, function()
		if not achievements.DNT_LightningRod:isComplete() then
			if Board:GetPawn(location) and Board:GetPawn(location):GetType():find("^DNT_Thunderbug") then
				achievements.DNT_LightningRod:addProgress(1)
			end
		end
	end)
	
	return effect
end

local function Hook_MissionEnd(mission)
	-- Picnic
	if not achievements.DNT_Picnic:isComplete() and mission.Name == "Anthill Leader" then
		local pawnList = extract_table(Board:GetPawns(TEAM_ENEMY))
		if pawnList and #pawnList > 0 then
			for i = 1, #pawnList do
				local pawnName = Board:GetPawn(pawnList[i]):GetType()
				local antNames = {"DNT_WorkerAnt", "DNT_FlyingAnt", "DNT_SoldierAnt", "DNT_Anthill"}
				for i = 1, #antNames do
					if pawnName:find(antNames[i]) then
						return
					end
				end
			end
		end
		achievements.DNT_Picnic:addProgress(1)
	end
end

-- AddHooks
local function EVENT_onModsLoaded()
	-- modApiExt
	DNT_Vextra_ModApiExt:addPawnKilledHook(HOOK_PawnKilled)
	-- DNT_Vextra_ModApiExt:addSkillEndHook(HOOK_SkillEnd)
	-- DNT_Vextra_ModApiExt:addSkillStartHook(HOOK_SkillStart)
	DNT_Vextra_ModApiExt:addQueuedSkillEndHook(HOOK_QueuedSkillEnd)
	DNT_Vextra_ModApiExt:addQueuedSkillStartHook(HOOK_QueuedSkillStart)
	DNT_Vextra_ModApiExt:addPawnPositionChangedHook(HOOK_PawnPositionChanged)
	-- modApi
	modApi:addMissionEndHook(Hook_MissionEnd)
	-- modApi:addNextTurnHook(HOOK_nextTurn)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
