DNT_GLOBAL_CLOWN_ACTIVE = true --DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
DNT_GLOBAL_GIFT_ACTIVE = true --DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING

local function isAnt(type)
  return type == "DNT_FAnt1" or type == "DNT_SoldierAnt1" or type == "DNT_WorkerAnt1"
end

local function isCockroach(type)
  return type == "DNT_Cockroach1" or type == "DNT_Cockroach2" or type == "DNT_CockroachBoss "
end

local clown_bug_emerge_odds = .02
local gift_emerge_odds = .08

local HOOK_pawnTracked = function(mission, pawn)
  local type = pawn:GetType()
	if type:find("^DNT") --Is a Vextra Vek
  and type ~= "DNT_Clown1" --No infinite loops
	and type ~= "DNT_Gift1" --No infinite loops
  and _G[type].Image ~= "DNT_jelly" --No Psions (they break)
  and _G[type].Tier ~= TIER_BOSS --Don't replace the boss
  and type ~= "DNT_LadybugBoss" --Ladybug is a boss too despite not being marked as so
  and not isCockroach(type) --Cockroaches respawn and can get overridden when they do so
  and not isAnt(type) --Don't replace ants
  and not pawn:IsMech() then --Let's not replace our mechs
    local random = math.random()
    if random > 1-clown_bug_emerge_odds and DNT_GLOBAL_CLOWN_ACTIVE then
      Game:TriggerSound("ui/battle/psion_attack")
      local space = pawn:GetSpace()
      Board:RemovePawn(pawn)

      local newPawn = PAWN_FACTORY:CreatePawn("DNT_Clown1")
      Board:AddPawn(newPawn, space)
      newPawn:SpawnAnimation()
    elseif random > 1-clown_bug_emerge_odds-gift_emerge_odds and DNT_GLOBAL_GIFT_ACTIVE and not mission.gift_spawn then
      Game:TriggerSound("/ui/map/flyin_rewards")
      local space = pawn:GetSpace()
      Board:RemovePawn(pawn)

      local newPawn = PAWN_FACTORY:CreatePawn("DNT_Gift1")
      Board:AddPawn(newPawn, space)
      newPawn:SpawnAnimation()

      mission.gift_spawn = true
    end
	end
end

local HOOK_postGameStart = function()
  GAME.clown_bug_start_spawn_odds = 1-.30
end

local HOOK_preMissionAvaliable = function(mission)
  if math.random() > GAME.clown_bug_start_spawn_odds then
    GAME.clown_bug_start_spawn_odds = 1-.04
    local pawn = PAWN_FACTORY:CreatePawn("DNT_Clown1")
    Board:AddPawn(pawn)
    mission.Clown_Spawn = pawn:GetSpace()
  end
end

local HOOK_nextTurn = function(mission)
	if Board:GetTurn() == 0 and mission.Clown_Spawn then
    local effect = SkillEffect()
    effect:AddSound("/props/ground_break_tile")
		local damage = SpaceDamage(mission.Clown_Spawn, DAMAGE_DEATH)
		damage.sAnimation = "tentacles"
		damage.iTerrain = TERRAIN_LAVA
		damage.sSound = "/props/tentacle"
		effect:AddDamage(damage)
    Board:AddEffect(effect)
  end
end




local function EVENT_onModsLoaded()
	DNT_Vextra_ModApiExt:addPawnTrackedHook(HOOK_pawnTracked)
  modApi:addPreMissionAvailableHook(HOOK_preMissionAvaliable)
  modApi:addNextTurnHook(HOOK_nextTurn)
  modApi:addPostStartGameHook(HOOK_postGameStart)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
