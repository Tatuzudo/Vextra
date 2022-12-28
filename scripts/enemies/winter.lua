local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
--local previewer = require(scriptPath.."weaponPreview/api")
local trait = require(scriptPath..'libs/trait')

local writepath = "img/units/aliens/"
local readpath = resourcePath .. writepath
local imagepath = writepath:sub(5,-1)
local a = ANIMS

local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end


-------------
--  Icons  --
-------------

-- modApi:appendAsset("img/effects/DNT_snowflake.png",resourcePath.."img/effects/DNT_snowflake.png")
	-- -- Location["effects/DNT_snowflake.png"] = Point(0,0)

-------------
--   Art   --
-------------

-- same sprite for all psions
local name = "jelly"

modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
modApi:appendAsset(writepath.."DNT_"..name.."_ns.png", readpath.."DNT_"..name.."_ns.png")
modApi:appendAsset(writepath.."DNT_"..name.."_icon.png", readpath.."DNT_"..name.."_icon.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -16, PosY = -14, Height = 10 }
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -23, PosY = -21, Height = 10 }

a.DNT_jelly = base
a.DNT_jellye = baseEmerge
a.DNT_jellya = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
a.DNT_jellyd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", PosX = -18, PosY = -14, NumFrames = 8, Time = 0.14, Loop = false }
a.DNT_jelly_ns = a.MechIcon:new{ Image = imagepath.."DNT_"..name.."_ns.png", Height = 10 }

a.DNT_jelly_icon = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name.."_icon.png", PosX = -16, PosY = -14, Height = 10 }
a.DNT_jelly_icone = baseEmerge
a.DNT_jelly_icona = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
a.DNT_jelly_icond = base:new{ Image = imagepath.."DNT_"..name.."_death.png", PosX = -18, PosY = -14, NumFrames = 8, Time = 0.14, Loop = false }
a.DNT_jelly_icon_ns = a.MechIcon:new{ Image = imagepath.."DNT_"..name.."_ns.png", Height = 10 }

-----------------
--  Portraits  --
-----------------

local ptname = "Winter"
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."1.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."1.png")

--------------
-- Emitters --
--------------

local BURST_UP = "DNT_Winter_Up"
DNT_Winter_Up = Emitter:new{
	image = "combat/icons/icon_ice.png",
	x = -11,
	y = 6,
	max_alpha = 1.0,
	min_alpha = 1.0,
	angle = -90,
	rot_speed = 0,
	angle_variance = 0,
	random_rot = false,
	lifespan = 0.75,
	burst_count = 1,
	speed = 0.75,
	birth_rate = 0,
	gravity = false,
	layer = LAYER_FRONT
}

local BURST_DOWN = "DNT_Winter_Down"
DNT_Winter_Down = Emitter:new{
	image = "combat/icons/icon_ice.png",
	x = -11,
	y = 6,
	max_alpha = 0.5,
	min_alpha = 0.5,
	angle = 90,
	rot_speed = 0,
	angle_variance = 0,
	random_rot = false,
	lifespan = 0.75,
	burst_count = 1,
	speed = 0.75,
	birth_rate = 0,
	gravity = false,
	layer = LAYER_FRONT
}

DNT_Blizzard = Emitter:new{
	image = "combat/tiles_grass/particle.png",
	x = 0,
	y = -30,
	variance = 20,
	max_alpha = 1,
	min_alpha = 1,
	angle = 110,
	angle_variance = 40,
	rot_speed = 5,
	random_rot = true,
	lifespan = 0.5,
	burst_count = 0,
	speed = 5,
	birth_rate = 0.2,
	gravity = false,
	layer = LAYER_FRONT,
	timer = 2,
	max_particles = 64
}

-------------
-- Weapons --
-------------

DNT_Winter_Passive = PassiveSkill:new{
	Name = "Psionic Blizzard",
	Description = "Freeze the starting tile of all mechs at the end of each turn.",
	Class = "Enemy",
	Icon = "weapons/prime_lightning.png",
	Passive = "DNT_Winter_Passive",
	CustomTipImage = "DNT_Winter_Passive_Tip",
	TipImage = {
		Unit = Point(2,3),
		CustomPawn = "DNT_Winter1",
		Target = Point(2,2),
		Enemy = Point(2,1),
	}
}

function DNT_Winter_Passive:GetSkillEffect(p1,p2) -- for passive preview
	return SkillEffect()
end

DNT_Winter_Passive_Tip = DNT_Winter_Passive:new{}

function DNT_Winter_Passive_Tip:GetSkillEffect(p1,p2) -- for passive preview
	local ret = SkillEffect()
	
	ret:AddScript([[
		Board:Ping(Point(2,1),GL_Color(0,255,0))
		Board:AddBurst(Point(2,1),"DNT_Winter_Up",DIR_NONE)
	]])
	
	local dam = SpaceDamage(Point(2,1))
	dam.iFrozen = EFFECT_CREATE
	
	ret:AddQueuedDamage(dam)
	ret:AddDelay(2)
	
	return ret
end

-----------
-- Pawns --
-----------

DNT_Winter1 = Pawn:new{
	Name = "Winter Psion",
	Health = 2,
	MoveSpeed = 2,
	Image = "DNT_jelly", -- do not change
	LargeShield = true,
	VoidShockImmune = true,
	ImageOffset = 4, -- change this to the right sprite
	SkillList = { "DNT_Winter_Passive" },
	SoundLocation = "/enemy/jelly/",
	Flying = true,
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	-- Leader = LEADER_VINES,--LEADER_HEALTH,
	-- Tooltip = "Jelly_Health_Tooltip"
}
AddPawn("DNT_Winter1")

----------------------
-- Helper Functions --
----------------------

local DNT_PSION = "DNT_Winter1"

local function DNT_PsionTarget(pawn)
	if GetCurrentMission()[DNT_PSION] and pawn:GetType() ~= DNT_PSION then
		if (pawn:GetTeam() == TEAM_PLAYER and pawn:IsMech()) or (IsPassiveSkill("Psion_Leech") and pawn:GetTeam() == TEAM_ENEMY) then
			if _G[pawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[pawn:GetType()].Minor then
				return true
			end
		end
	end
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

local function DNT_Contains(tab, element)
	for _, value in pairs(tab) do
		if value == element then
			return true
		end
	end
	return false
end

------------
-- Traits --
------------

local winterTrait = function(trait,pawn)
	if pawn:GetSpace() == mouseTile() or pawn:IsSelected() then
		return DNT_PsionTarget(pawn)
	end
end

trait:add{
	func = winterTrait,
	icon = "img/combat/icons/icon_ice.png",
	icon_glow = "img/combat/icons/icon_ice_glow.png",
	icon_offset = Point(2,10),
	desc_title = "Psionic Blizzard",
	desc_text = "The Winter Psion will freeze the starting tile of all mechs at the end of each turn.",
}

------------------------
-- Hooks and Function --
------------------------

-- some interesting sounds
-- "/props/freezing" "/weapons/refrigerate" "/ui/map/map_open" /props/freezing_mine
local function DNT_Sound_Buff()
	Game:TriggerSound("/ui/battle/buff_regen")
	Game:TriggerSound("/ui/map/map_open")
end

-- psion spawn
local HOOK_pawnTracked = function(mission, pawn)
	if isMissionBoard() then
		modApi:scheduleHook(1500, function()
			if pawn:GetType() == DNT_PSION then
				DNT_Sound_Buff()
				mission[DNT_PSION] = {}
				local pawnList = extract_table(Board:GetPawns(TEAM_ANY))
				for i = 1, #pawnList do
					local currPawn = Board:GetPawn(pawnList[i])
					if DNT_PsionTarget(currPawn) then
						trait:update(currPawn:GetSpace())
						Board:Ping(currPawn:GetSpace(),GL_Color(0,255,0))
						Board:AddBurst(currPawn:GetSpace(),BURST_UP,DIR_NONE)
					end
				end
			elseif DNT_PsionTarget(pawn) then
				trait:update(pawn:GetSpace())
				Board:Ping(pawn:GetSpace(),GL_Color(0,255,0))
				if Board:GetTurn() ~= 0 then
					DNT_Sound_Buff()
					Board:AddBurst(pawn:GetSpace(),BURST_UP,DIR_NONE)
					mission[DNT_PSION][#mission[DNT_PSION]+1] = pawn:GetSpace()
				end
			end
		end)
	end
end

local HOOK_pawnUntracked = function(mission, pawn)
	if isMissionBoard() then
		if pawn:GetType() == DNT_PSION then
			Game:TriggerSound("/ui/battle/buff_removed")
			local pawnList = extract_table(Board:GetPawns(TEAM_ANY))
			for i = 1, #pawnList do
				local currPawn = Board:GetPawn(pawnList[i])
				if DNT_PsionTarget(currPawn) then
					Board:Ping(currPawn:GetSpace(),GL_Color(255,50,50))
					trait:update(currPawn:GetSpace())
					Board:AddBurst(currPawn:GetSpace(),BURST_DOWN,DIR_NONE)
				end
			end
			mission[DNT_PSION] = nil
		end
	end
end

-- add / remove trait when selected / highlighted
local HOOK_tileHighlighted = function(mission, point)
	if isMissionBoard() then
		trait:update(point)
	end
end

local HOOK_pawnSelected = function(mission, pawn)
	if isMissionBoard() then
		trait:update(pawn:GetSpace())
	end
end

-- add / remove icon sprite
local EVENT_onGameStateChanged = function(newGameState, oldGameState)
	if newGameState == "Map" then
		DNT_Winter1['Image'] = "DNT_jelly_icon"
	else
		DNT_Winter1['Image'] = "DNT_jelly"
	end
end

-- quiting / loading first turn fix
local HOOK_gameLoaded = function(mission)
	modApi:conditionalHook(
		function()
			return GetCurrentMission()
		end,
		function()
			local enemyList = extract_table(Board:GetPawns(TEAM_ENEMY))
			for i = 1, #enemyList do
				local currPawn = Board:GetPawn(enemyList[i])
				if currPawn:GetType() == DNT_PSION then
					if not GetCurrentMission()[DNT_PSION] then
						GetCurrentMission()[DNT_PSION] = {}
					end
					break
				end
			end
		end
	)
end

local function HOOK_nextTurn(mission)
	if Board:GetTurn() == 0 then
		local enemyList = extract_table(Board:GetPawns(TEAM_ENEMY))
		for i = 1, #enemyList do
			local currPawn = Board:GetPawn(enemyList[i])
			if currPawn:GetType() == DNT_PSION then
				mission[DNT_PSION] = {}
			end
		end
	end
	modApi:conditionalHook(
		function()
			return GetCurrentMission()
		end,
		function()
			mission = GetCurrentMission()
			if mission[DNT_PSION] then
				if Game:GetTeamTurn() == TEAM_ENEMY then
					-- freeze everything
					if #mission[DNT_PSION] > 0 then
						Game:TriggerSound("/props/snow_storm")
						local effect = SkillEffect()
						for i = 1, #mission[DNT_PSION] do
							local p = mission[DNT_PSION][i]
							effect:AddEmitter(p,"DNT_Blizzard")
						end
						effect:AddDelay(1)
						for i = 1, #mission[DNT_PSION] do
							local p = mission[DNT_PSION][i]
							local damage = SpaceDamage(p, 0)
							damage.iFrozen = EFFECT_CREATE
							effect:AddDamage(damage)
						end
						effect.iOwner = ENV_EFFECT
						effect:AddDelay(2)
						Board:AddEffect(effect)
						mission[DNT_PSION] = {}
					end
					-- mark spaces
					local delayTime = math.min(Board:GetTurn()*3000,3000)
					modApi:scheduleHook(delayTime, function()
						DNT_Sound_Buff()
						local pawnList = extract_table(Board:GetPawns(TEAM_ANY))
						for i = 1, #pawnList do
							local currPawn = Board:GetPawn(pawnList[i])
							if DNT_PsionTarget(currPawn) then
								local p = currPawn:GetSpace()
								local isbelt = false
								if mission.LiveEnvironment and mission.LiveEnvironment.Belts then
									isbelt = DNT_Contains(mission.LiveEnvironment.Belts, p)
								end
								if Board:IsValid(p) and not Board:IsEnvironmentDanger(p) and not isbelt then-- and not Board:IsTerrain(p,0) then
									local p = currPawn:GetSpace()
									mission[DNT_PSION][#mission[DNT_PSION]+1] = p
									Board:Ping(p,GL_Color(0,255,0))
									Board:AddBurst(p,BURST_UP,DIR_NONE)
									trait:update(p)
								end
							end
						end
					end)
				end
			end
		end
	)
end

local HOOK_MissionEnd = function(mission) -- delete farts on mission end
	if mission[DNT_PSION] and #mission[DNT_PSION] > 0 then
		Game:TriggerSound("/props/snow_storm")
		local effect = SkillEffect()
		for i = 1, #mission[DNT_PSION] do
			local p = mission[DNT_PSION][i]
			effect:AddEmitter(p,"DNT_Blizzard")
		end
		effect:AddDelay(1)
		for i = 1, #mission[DNT_PSION] do
			local p = mission[DNT_PSION][i]
			if Board:GetPawn(p) and Board:GetPawn(p):GetTeam() == TEAM_ENEMY then
				effect:AddAnimation(p,"IceBlock_Death")
				effect:AddSound("/props/ice_break")
			else
				local damage = SpaceDamage(p, 0)
				damage.iFrozen = EFFECT_CREATE
				effect:AddDamage(damage)
			end
		end
		effect.iOwner = ENV_EFFECT
		Board:AddEffect(effect)
		mission[DNT_PSION] = {}
	end
end

-- update marks
TILE_TOOLTIPS.DNT_psionic_blizzard = {"Psionic Blizzard", "The Winter Psion will freeze this tile at the end of the turn."}
local HOOK_MissionUpdate = function(mission)
	if mission and mission[DNT_PSION] and #mission[DNT_PSION] > 0 then
		for i = 1, #mission[DNT_PSION] do
			local p = mission[DNT_PSION][i]
			Board:MarkSpaceImage(p,"combat/tile_icon/tile_snowstorm.png",GL_Color(0, 180, 255 ,0.75))
			-- Board:MarkSpaceDesc(p,"ice_storm")
			Board:MarkSpaceDesc(p,"DNT_psionic_blizzard")
		end
	end
end

-- add hooks
local function EVENT_onModsLoaded()
	------------------------ add your hooks here------------------------
	DNT_Vextra_ModApiExt:addPawnTrackedHook(HOOK_pawnTracked)
	DNT_Vextra_ModApiExt:addPawnUntrackedHook(HOOK_pawnUntracked)
	modApi:addMissionUpdateHook(HOOK_MissionUpdate)
	modApi:addMissionEndHook(HOOK_MissionEnd)
	
	------------------------ do not change this -------------------------
	-- add / remove trait when selected / highlighted
	DNT_Vextra_ModApiExt:addTileHighlightedHook(HOOK_tileHighlighted)
	DNT_Vextra_ModApiExt:addTileUnhighlightedHook(HOOK_tileHighlighted)
	DNT_Vextra_ModApiExt:addPawnSelectedHook(HOOK_pawnSelected)
	DNT_Vextra_ModApiExt:addPawnDeselectedHook(HOOK_pawnSelected)
	-- for when quitting and loading first turn
	DNT_Vextra_ModApiExt:addGameLoadedHook(HOOK_gameLoaded)
	modApi:addNextTurnHook(HOOK_nextTurn) -- also for skill
end


--------------------------- do not change this --------------------------
modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
-- add / remove icon sprite
modApi.events.onGameStateChanged:subscribe(EVENT_onGameStateChanged)
-------------------------------------------------------------------------
