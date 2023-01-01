local mod = modApi:getCurrentMod()
local global = "Vextra"
local modid = "Djinn_NAH_Tatu_Vextra"

local customAnim = require(mod.scriptPath .."libs/customAnim")

local function DNT_checkSquadProgress() --This can be made local once combined
	local id = "DNT_SecretSquad"
	local complete = modApi.achievements:isComplete(modid,id)
	if complete then return end --Already Unlocked

	local count = 0
	local ids = {"DNT_PsychoDragonfly","DNT_DragonSlayer","DNT_Fartality"}
	for _, i in pairs(ids) do
		local complete = modApi.achievements:isComplete(modid,i)
		if complete then count = count + 1 end
	end
	if count >= 3 then
		modApi.achievements:trigger(modid,id)
	else
		modApi.achievements:addProgress(modid,id,count-modApi.achievements:getProgress(modid,id))
	end
end

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
	DNT_SelfSmush = modApi.achievements:add{
		id = "DNT_SelfSmush",
		name = "Pest Control",
		tooltip = "Finish off a Cockroach by smushing it with a another Vek",
		image = mod.resourcePath.."img/achievements/selfsmush.png",
		objective = 1,
		global = global,
	},
	DNT_PsychoDragonfly = modApi.achievements:add{
		id = "DNT_PsychoDragonfly",
		name = "We Didn't Start the Fire",
		tooltip = "Ignite two Vek with an attack from a dragonfly",
		image = mod.resourcePath.."img/achievements/placeholder.png",
		objective = 1,
		global = global,
		addReward = DNT_checkSquadProgress,
		remReward = DNT_checkSquadProgress,
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
	DNT_ShockAbsorber = modApi.achievements:add{
		id = "DNT_ShockAbsorber",
		name = "Shock Absorber",
		tooltip = "Leave Reactive Psion alive from the beginning to the end of a mission without losing grid power.",
		image = mod.resourcePath.."img/achievements/placeholder.png",
		objective = 1,
		global = global,
	},
	DNT_RedWedding = modApi.achievements:add{
		id = "DNT_RedWedding",
		name = "Red Wedding",
		tooltip = "Kill the Junebug Boss and Ladybug Boss in the same turn.",
		image = mod.resourcePath.."img/achievements/redwedding.png",
		objective = 1,
		global = global,
	},
	DNT_Picnic = modApi.achievements:add{
		id = "DNT_Picnic",
		name = "Safe for a Picnic",
		tooltip = "Kill the Anthill Leader and finish the battle with no Ants left on the board.",
		image = mod.resourcePath.."img/achievements/safe4picnic.png",
		objective = 1,
		global = global,
	},
	DNT_DoubleEdgedSword = modApi.achievements:add{ --Check In Weapon
		id = "DNT_DoubleEdgedSword",
		name = "Double Edged Sword",
		tooltip = "Have the Ice Crawler Leader hit 3 enemies in a single attack",
		image = mod.resourcePath.."img/achievements/doubleedgedsword.png",
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
	},
	DNT_LightningRod = modApi.achievements:add{
		id = "DNT_LightningRod",
		name = "Lightning Rod",
		tooltip = "Have a Thunderbug be struck by a lightning tile.",
		image = mod.resourcePath.."img/achievements/lightningrod.png",
		objective = 1,
		global = global,
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
	DNT_SubZero = modApi.achievements:add{
		id = "DNT_SubZero",
		name = "Sub-Zero",
		tooltip = "Freeze 7 enemies using the Winter Psion in a single island.\n\nEnemies frozen: $",
		image = mod.resourcePath.."img/achievements/subzero.png",
		objective = 7,
		global = global,
	},
	DNT_Zoologist = modApi.achievements:add{
		id = "DNT_Zoologist",
		name = "Zoologist",
		tooltip = "Encounter all Vextra Bosses in their mission. \nEncountered: $count",
		image = mod.resourcePath.."img/achievements/zoologist.png",
		objective = {
			Mission_ThunderbugBoss = true,
			Mission_PillbugBoss = true,
			Mission_MantisBoss = true,
			Mission_SilkwormBoss = true,
			Mission_AntlionBoss = true,
			Mission_FlyBoss = true,
			Mission_DragonflyBoss = true,
			Mission_TermitesBoss = true,
			Mission_StinkbugBoss = true,
			Mission_AnthillBoss = true,
			Mission_CockroachBoss = true,
			Mission_IceCrawlerBoss = true,
			Mission_JunebugBoss = true,
			count = 13,
		},
		global = global,
	},
	DNT_MissionImpossible = modApi.achievements:add{
		id = "DNT_MissionImpossible",
		name = "Mission Impossible",
		tooltip = "Finish 4 Islands with the original \"Vextra Only\" enemy and boss list",
		image = mod.resourcePath.."img/achievements/missionimpossible.png",
		objective = 1,
		global = global,
	},
	DNT_SecretSquad = modApi.achievements:add{
		id = "DNT_SecretSquad",
		name = "Secret Squad",
		tooltip = "Unlocks Secret Squad! Restart if just unlocked.\n$ neccesary achievements complete",
		image = mod.resourcePath.."img/achievements/placeholder.png",
		secret = true,
		objective = 3,
		global = global,
	},
}

-- Helper Functions
function DNT_VextraChevio(id)
	local complete = modApi.achievements:isComplete(modid,id)
	if complete then return end
	modApi.achievements:trigger(modid,id)
end

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

--Mission Impossible Helper Function
local function groupIsValid(given,expected)
	for k, v in pairs(given) do
		if not expected[v] then return false end --Unexpected enemy
		expected[v] = false
	end
	for k, v in pairs(expected) do
		if v then return false end --Enemy Not Found
	end
	return true
end

-- Variables
local flyAttack = false -- Dragon Slayer
local fireCount = 0 -- We Didn't Start the Fire
local dragonflyAttack = false -- We Didn't Start the Fire

-- Hook Functions
--Mission Hooks
local function HOOK_MissionStart(mission)
	if isMissionBoard() then
		--Zoologist Boss Encounter
		local missionId = mission.ID
		if not achievements.DNT_Zoologist:isComplete() then
			local progress = achievements.DNT_Zoologist:getProgress()
			if not progress[missionId] and type(progress[missionId]) ~= "nil" then --Check if progress hasn't been made and it's a mission I'm checking for
				--Long ass series of if statments cause I couldn't figure out how to do it easily )':
				if missionId == "Mission_ThunderbugBoss" then
					achievements.DNT_Zoologist:addProgress({Mission_ThunderbugBoss = true})
				elseif missionId == "Mission_PillbugBoss" then
					achievements.DNT_Zoologist:addProgress({Mission_PillbugBoss = true})
				elseif missionId == "Mission_MantisBoss" then
					achievements.DNT_Zoologist:addProgress({Mission_MantisBoss = true})
				elseif missionId == "Mission_SilkwormBoss" then
					achievements.DNT_Zoologist:addProgress({Mission_SilkwormBoss = true})
				elseif missionId == "Mission_AntlionBoss" then
					achievements.DNT_Zoologist:addProgress({Mission_AntlionBoss = true})
				elseif missionId == "Mission_FlyBoss" then
					achievements.DNT_Zoologist:addProgress({Mission_FlyBoss = true})
				elseif missionId == "Mission_DragonflyBoss" then
					achievements.DNT_Zoologist:addProgress({Mission_DragonflyBoss = true})
				elseif missionId == "Mission_TermitesBoss" then
					achievements.DNT_Zoologist:addProgress({Mission_TermitesBoss = true})
				elseif missionId == "Mission_StinkbugBoss" then
					achievements.DNT_Zoologist:addProgress({Mission_StinkbugBoss = true})
				elseif missionId == "Mission_AnthillBoss" then
					achievements.DNT_Zoologist:addProgress({Mission_AnthillBoss = true})
				elseif missionId == "Mission_CockroachBoss" then
					achievements.DNT_Zoologist:addProgress({Mission_CockroachBoss = true})
				elseif missionId == "Mission_IceCrawlerBoss" then
					achievements.DNT_Zoologist:addProgress({Mission_IceCrawlerBoss = true})
				elseif missionId == "Mission_JunebugBoss" then
					achievements.DNT_Zoologist:addProgress({Mission_JunebugBoss = true})
				end
				--achievements.DNT_Zoologist:addProgress({missionId = true})
				achievements.DNT_Zoologist:addProgress({count = 1}) --Adds automatically even though I use an equal sign
			end
		end

		--Shock Absorber
		if not achievements.DNT_ShockAbsorber:isComplete() then
			mission.DNT_SA_ReactivePsion = mission.DNT_SA_ReactivePsion or false
			mission.DNT_SA_GridPower = mission.DNT_SA_GridPower or Game:GetPower():GetValue()
		end
	end
end

local function HOOK_MissionUpdate(mission, pawn)
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

	-- Sub Zero
	if mission["DNT_Winter1"] and #mission["DNT_Winter1"] > 0 then
		for i = 1, #mission["DNT_Winter1"] do
			local p = mission["DNT_Winter1"][i]
			local pawn = Board:GetPawn(p)
			if pawn and pawn:GetTeam() == TEAM_ENEMY and not pawn:IsFrozen() then
				modApi:scheduleHook(900, function()
					if not achievements.DNT_SubZero:isComplete() then
						achievements.DNT_SubZero:addProgress(1)
					end
				end)
			end
		end
	end

	--Shock Absorber
	if not achievements.DNT_ShockAbsorber:isComplete() then
		mission.DNT_SA_GridPower = mission.DNT_SA_GridPower or 0
		if mission.DNT_SA_ReactivePsion and mission.DNT_Reactive1 and mission.DNT_SA_GridPower <= Game:GetPower():GetValue() then
			DNT_VextraChevio("DNT_ShockAbsorber")
		end
	end

	--Mission Impossible
	--THIS HAS TO BE AT THE BOTTOM IT HAS RETURN STATEMENTS!!!!!!!!!!!
	--I could change it if neccesary though.
	if not achievements.DNT_MissionImpossible:isComplete() then
		if GAME.DNT_MI_Count < 3 or not mission.BossMission then return end --Trigger at end of last boss mission on final island
		local islands = {"archive","rst","pinnacle","detritus"} --Doesn't work with Merida ):
		for _, island in pairs(islands) do --All Islands Have "Vextra Only"
			local islandComposite = easyEdit.islandComposite:get(island)
			local enemyList = easyEdit.enemyList:get(islandComposite.enemyList)
			local bossList = easyEdit.enemyList:get(islandComposite.bossList)
			if enemyList._id ~= "Vextra Only" or bossList._id ~= "Vextra Only" then return end --Only checks the name, testing
		end
		--Vextra Only is Unedited
		local coreEnemies = {DNT_Mantis=true,DNT_Antlion=true,DNT_Silkworm=true,DNT_Stinkbug=true,DNT_Fly=true}
		local uniqueEnemies = {DNT_IceCrawler=true,DNT_Thunderbug=true,DNT_Dragonfly=true,DNT_Pillbug=true,DNT_Termites=true,DNT_Anthill=true,DNT_Cockroach=true}
		--Don't care about bots
		local leaderEnemies = {DNT_Acid=true,DNT_Reactive=true,DNT_Haste=true,DNT_Nurse=true,DNT_Winter=true}
		local bossEnemies = {Mission_AnthillBoss=true,Mission_FlyBoss=true,Mission_JunebugBoss=true,Mission_MantisBoss=true,Mission_ThunderbugBoss=true,
												Mission_TermitesBoss=true,Mission_StinkbugBoss=true,Mission_SilkwormBoss=true,Mission_CockroachBoss=true,
												Mission_PillbugBoss=true,Mission_AntlionBoss=true,Mission_IceCrawlerBoss=true,Mission_DragonflyBoss=true}

		local enemies = easyEdit.enemyList:get("Vextra Only").enemies
		local bosses = easyEdit.bossList:get("Vextra Only").Bosses

		if not groupIsValid(enemies.Core,coreEnemies) then return end
		if not groupIsValid(enemies.Unique,uniqueEnemies) then return end
		if not groupIsValid(enemies.Leaders,leaderEnemies) then return end
		if not groupIsValid(bosses,bossEnemies) then return end

		DNT_VextraChevio("DNT_MissionImpossible")
	end
end


--Pawn Hooks
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

		--Red Wedding Pawn Killed
		if not achievements.DNT_RedWedding:isComplete() then
			if pawn:GetType() == "DNT_JunebugBoss" then
				mission.RW_Junebug = true
				if mission.RW_Junebug and mission.RW_Ladybug and mission.RW_SameTurn then
					DNT_VextraChevio("DNT_RedWedding")
				end
				mission.RW_SameTurn = true
			elseif pawn:GetType() == "DNT_LadybugBoss" then
				mission.RW_Ladybug = true
				if mission.RW_Junebug and mission.RW_Ladybug and mission.RW_SameTurn then
					DNT_VextraChevio("DNT_RedWedding")
				end
				mission.RW_SameTurn = true
			end
		end
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

local function HOOK_PawnPositionChanged(mission, pawn, oldPosition)
	if isMissionBoard() then
		-- Fartality
		if not achievements.DNT_Fartality:isComplete() and pawn:GetType():find("^DNT_Stinkbug") then
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


--Skill Hooks
local function HOOK_QueuedSkillStart(mission, pawn, weaponId, p1, p2)
	if isMissionBoard() then
		-- Dragon Slayer (Start Fly attack)
		if not achievements.DNT_DragonSlayer:isComplete() and pawn:GetType():find("^DNT_Fly") and not pawn:IsMech() then
			flyAttack = true
		end
		-- Psycho Dragonfly (Start Dragonfly attack)
		if not achievements.DNT_PsychoDragonfly:isComplete() and pawn:GetType():find("^DNT_Dragonfly") and not pawn:IsMech() then
			dragonflyAttack = true
			fireCount = 0
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
		-- Psycho Dragonfly (End Dragonfly attack)
		modApi:scheduleHook(1000, function()
			if not achievements.DNT_PsychoDragonfly:isComplete() and pawn:GetType():find("^DNT_Dragonfly") and not pawn:IsMech() then
				dragonflyAttack = false
			end
		end)
	end
end


--Misc.
local function HOOK_nextTurn(mission)
	if isMissionBoard() then
		-- Sub Zero
		if Game:GetTeamTurn() == TEAM_ENEMY then
			if mission["DNT_Winter1"] and #mission["DNT_Winter1"] > 0 then
				for i = 1, #mission["DNT_Winter1"] do
					local p = mission["DNT_Winter1"][i]
					local pawn = Board:GetPawn(p)
					if pawn and pawn:GetTeam() == TEAM_ENEMY and not pawn:IsFrozen() then
						modApi:scheduleHook(900, function()
							if not achievements.DNT_SubZero:isComplete() then
								achievements.DNT_SubZero:addProgress(1)
							end
						end)
					end
				end
			end
		end

		--Red Wedding New Turn
		if not achievements.DNT_RedWedding:isComplete() then
			mission.RW_SameTurn = false
		end

		--Shock Absorber
		if not achievements.DNT_ShockAbsorber:isComplete() then
			if Board:GetTurn() == 1 and Game:GetTeamTurn() == TEAM_PLAYER and mission.DNT_Reactive1 then
				mission.DNT_SA_ReactivePsion = true
			end
		end

	end
end


--Events
local function DNT_onIslandLeft(island)
	-- Reset Sub Zero with Island
	if not achievements.DNT_SubZero:isComplete() then
		achievements.DNT_SubZero:addProgress(-achievements.DNT_SubZero:getProgress())
	end
	--Mission Impossible One More Mission Completed
	if not achievements.DNT_MissionImpossible:isComplete() then
		GAME.DNT_MI_Count = GAME.DNT_MI_Count + 1
	end
end

local function DNT_GameStart()
	-- Reset Sub Zero with Game
	if not achievements.DNT_SubZero:isComplete() then
		achievements.DNT_SubZero:addProgress(-achievements.DNT_SubZero:getProgress())
	end
	--Mission Impossible 0 islands completed
	if not achievements.DNT_MissionImpossible:isComplete() then
		GAME.DNT_MI_Count = 0
	end
end

-- AddHooks
local function EVENT_onModsLoaded()
	--Mission Hooks
	modApi:addMissionStartHook(HOOK_MissionStart)
	modApi:addMissionUpdateHook(HOOK_MissionUpdate)
	modApi:addMissionEndHook(Hook_MissionEnd)

	--Pawn Hooks
	DNT_Vextra_ModApiExt:addPawnKilledHook(HOOK_PawnKilled)
	DNT_Vextra_ModApiExt:addPawnIsFireHook(HOOK_PawnIsFire)
	DNT_Vextra_ModApiExt:addPawnPositionChangedHook(HOOK_PawnPositionChanged)

	--SkillHooks
	-- DNT_Vextra_ModApiExt:addSkillEndHook(HOOK_SkillEnd)
	-- DNT_Vextra_ModApiExt:addSkillStartHook(HOOK_SkillStart)
	DNT_Vextra_ModApiExt:addQueuedSkillEndHook(HOOK_QueuedSkillEnd)
	DNT_Vextra_ModApiExt:addQueuedSkillStartHook(HOOK_QueuedSkillStart)

	-- Misc.
	modApi:addNextTurnHook(HOOK_nextTurn)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

modApi.events.onIslandLeft:subscribe(DNT_onIslandLeft)
modApi.events.onPostStartGame:subscribe(DNT_GameStart)

-- Lightning Rod (not a hook)
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
