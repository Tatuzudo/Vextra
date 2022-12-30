local mod = modApi:getCurrentMod()
local global = "Vextra"
local modid = "Djinn_NAH_Tatu_Vextra"

--Needs to actually Unlock It
--Could use some more testing
function DNT_checkSquadProgress() --This can be made local once combined
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
	DNT_RedWedding = modApi.achievements:add{
		id = "DNT_RedWedding",
		name = "Red Wedding",
		tooltip = "Kill the Junebug Boss and Ladybug Boss in the same turn.",
		image = mod.resourcePath.."img/achievements/redwedding.png",
		objective = 1,
		global = global,
	},
	DNT_DoubleEdgedSword = modApi.achievements:add{ --Check In Weapon
		id = "DNT_DoubleEdgedSword",
		name = "Double Edged Sword",
		tooltip = "Have the Ice Crawler Leader hit 3 enemies in a single attack",
		image = mod.resourcePath.."img/achievements/doubleedgedsword.png",
		secret = true,
		objective = 1,
		global = global,
	},
	DNT_ShockAbsorber = modApi.achievements:add{
		id = "DNT_ShockAbsorber",
		name = "Shock Absorber",
		tooltip = "Leave Reactive Psion alive from the beginning to the end of a mission without losing grid power.",
		image = mod.resourcePath.."img/achievements/placeholder.png",
		objective = 1,
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
	--modApi.achievements:reset("Djinn_NAH_Tatu_Vextra", "DNT_Zoologist")
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
	DNT_SecretSquad = modApi.achievements:add{
		id = "DNT_SecretSquad",
		name = "Secret Squad",
		tooltip = "Secret Squad is now unlocked! Restart if just unlocked.",
		image = mod.resourcePath.."img/achievements/placeholder.png",
		secret = true,
		objective = 3,
		global = global,
	},
}

function DNT_VextraChevio(id)
	local complete = modApi.achievements:isComplete(modid,id)
	if complete then return end
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

-- Hook Functions

local fireCount = 0
local dragonflyAttack = false

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

local function HOOK_PawnKilled(mission,pawn)
	if isMissionBoard() then
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

--LOG(GetCurrentMission().DNT_Reactive1)
--LOG(GetCurrentMission().DNT_SA_ReactivePsion)
--LOG(GetCurrentMission().DNT_SA_GridPower)
local function HOOK_NextTurn(mission)
	if isMissionBoard() then
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

--for k, v in pairs(modApi.achievements:get("Djinn_NAH_Tatu_Vextra", "DNT_Zoologist"):getProgress()) do LOG(k);LOG(v) end

local function Hook_MissionStart(mission)
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

local function HOOK_PostStartGame()
	if not achievements.DNT_MissionImpossible:isComplete() then
		GAME.DNT_MI_Count = 0
	end
end

local function EVENT_OnIslandLeft(island) --This event doesn't trigger after island 4
	if not achievements.DNT_MissionImpossible:isComplete() then
		GAME.DNT_MI_Count = GAME.DNT_MI_Count + 1
	end
end

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


local function HOOK_MissionEnd(mission,ret)
	if not achievements.DNT_ShockAbsorber:isComplete() then
		mission.DNT_SA_GridPower = mission.DNT_SA_GridPower or 0
		if mission.DNT_SA_ReactivePsion and mission.DNT_Reactive1 and mission.DNT_SA_GridPower <= Game:GetPower():GetValue() then
			DNT_VextraChevio("DNT_ShockAbsorber")
		end
	end

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

-- AddHooks
local function EVENT_onModsLoaded()
	modApi:addMissionUpdateHook(HOOK_MissionUpdate)

	DNT_Vextra_ModApiExt:addQueuedSkillEndHook(HOOK_QueuedSkillEnd)
	DNT_Vextra_ModApiExt:addQueuedSkillStartHook(HOOK_QueuedSkillStart)
	DNT_Vextra_ModApiExt:addPawnIsFireHook(HOOK_PawnIsFire)

	modApi:addMissionStartHook(Hook_MissionStart)

	modApi:addNextTurnHook(HOOK_NextTurn)
	DNT_Vextra_ModApiExt:addPawnKilledHook(HOOK_PawnKilled)

	modApi:addPostStartGameHook(HOOK_PostStartGame)
	modApi:addMissionEndHook(HOOK_MissionEnd)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
modApi.events.onIslandLeft:subscribe(EVENT_OnIslandLeft)

--Mission Impossible Testing:
-- for k,v in pairs(easyEdit.islandComposite:get("archive")) do LOG(k) end
--LOG(easyEdit.islandComposite:get("archive")["enemyList"]) --> "Vextra Only"
--for k,v in pairs(easyEdit.enemyList:get(easyEdit.islandComposite:get("archive")["enemyList"])) do LOG(k); LOG(v) end
--LOG(easyEdit.enemyList:get(easyEdit.islandComposite:get("archive")["enemyList"]))
