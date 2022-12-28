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
	end
end

-- AddHooks
local function EVENT_onModsLoaded()
	modApi:addMissionUpdateHook(HOOK_MissionUpdate)

	DNT_Vextra_ModApiExt:addQueuedSkillEndHook(HOOK_QueuedSkillEnd)
	DNT_Vextra_ModApiExt:addQueuedSkillStartHook(HOOK_QueuedSkillStart)
	DNT_Vextra_ModApiExt:addPawnIsFireHook(HOOK_PawnIsFire)

	modApi:addMissionStartHook(Hook_MissionStart)
	-- modApi:addNextTurnHook(HOOK_nextTurn)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
