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

modApi:appendAsset("img/icons/DNT_reactive_icon.png",resourcePath.."img/icons/DNT_reactive_icon.png") --TEMPORARY
	Location["icons/DNT_reactive_icon.png"] = Point(0,0)
modApi:appendAsset("img/icons/DNT_reactive_icon_glow.png",resourcePath.."img/icons/DNT_reactive_icon_glow.png") --TEMPORARY
	Location["icons/DNT_reactive_icon_glow.png"] = Point(0,0)

-------------
--   Art   --
-------------

local name = "jelly" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
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

local ptname = "Reactive"
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."1.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."1.png")

--------------
-- Emitters --
--------------

local BURST_UP = "DNT_Reactive_Up"
DNT_Reactive_Up = Emitter:new{
	image = "icons/DNT_reactive_icon.png",
	x = -12,
	y = 5,
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

local BURST_DOWN = "DNT_Reactive_Down"
DNT_Reactive_Down = Emitter:new{
	image = "icons/DNT_reactive_icon.png",
	x = -12,
	y = -5,
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

-------------
-- Weapons --
-------------

DNT_Reactive_Passive = PassiveSkill:new{
	Name = "Repulsive Decay",
	Description = "All other Vek push adjacent tiles on death.",
	Class = "Enemy",
	Icon = "weapons/prime_lightning.png",
	Passive = "DNT_Reactive_Passive",
	CustomTipImage = "DNT_Reactive_Passive_Tip",
	TipImage = {
		Unit = Point(2,3),
		CustomPawn = "DNT_Reactive1",
		Target = Point(1,1),
		Friend = Point(1,1),
		Enemy = Point(2,1),
		Building = Point(3,1),
	}
}

function DNT_Reactive_Passive:GetSkillEffect(p1,p2) -- for passive tip image
	return SkillEffect()
end

DNT_Reactive_Passive_Tip = DNT_Reactive_Passive:new{}

function DNT_Reactive_Passive_Tip:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local pos = Point(1,1)

	Board:Ping(pos,GL_Color(0,255,0))
	Board:AddBurst(pos,BURST_UP,DIR_NONE)
	if IsPassiveSkill("Psion_Leech") then
		Board:Ping(Point(2,1),GL_Color(0,255,0))
		Board:AddBurst(Point(2,1),BURST_UP,DIR_NONE)
	end

	ret:AddMelee(Point(2,1),SpaceDamage(pos,DAMAGE_DEATH))
	ret.effect:back().bHide = true
	ret:AddDelay(1)
	ret:AddAnimation(pos,"ExploRepulse3")
	for i = DIR_START, DIR_END do
		damage = SpaceDamage(pos + DIR_VECTORS[i], 0)
		damage.iPush = i
		damage.sAnimation = "airpush_"..i
		ret:AddDamage(damage)
		ret.effect:back().bHide = true
	end
	ret:AddDelay(1.5)

	return ret
end

-----------
-- Pawns --
-----------

DNT_Reactive1 = Pawn:new{
	Name = "Reactive Psion",
	Health = 2,
	MoveSpeed = 2,
	Image = "DNT_jelly",--"DNT_jelly_icon",
	LargeShield = true,
	VoidShockImmune = true,
	ImageOffset = 2,
	SkillList = { "DNT_Reactive_Passive" },
	SoundLocation = "/enemy/jelly/",
	Flying = true,
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	-- Leader = LEADER_VINES,--LEADER_HEALTH,
	-- Tooltip = "Jelly_Health_Tooltip"
}
AddPawn("DNT_Reactive1")

----------------------
-- Helper Functions --
----------------------

local DNT_PSION = "DNT_Reactive1"

local function DNT_PsionTarget(pawn)
	if GetCurrentMission()[DNT_PSION] and pawn:GetType() ~= DNT_PSION then
		if pawn:GetTeam() == TEAM_ENEMY or (IsPassiveSkill("Psion_Leech") and pawn:IsMech()) then
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

------------
-- Traits --
------------

local ReactiveTrait = function(trait,pawn)
	if pawn:GetSpace() == mouseTile() or pawn:IsSelected() then
		return DNT_PsionTarget(pawn)
	end
end

trait:add{
	func = ReactiveTrait,
	icon = "img/icons/DNT_reactive_icon.png",
	icon_glow = "img/icons/DNT_reactive_icon_glow.png",
	icon_offset = Point(0,9),
	desc_title = "Repulsive Decay",
	desc_text = "The Reactive Psion causes other Vek to push adjacent tiles on death.",
}

------------------------
-- Hooks and Function --
------------------------

-- some interesting sounds
--"/impact/generic/tractor_beam" "/impact/generic/control" "/weapons/bomb_strafe"
local function DNT_Sound_Buff()
	Game:TriggerSound("/ui/battle/buff_armor")
	Game:TriggerSound("/impact/generic/control")
end

-- psion spawning / dying effects and vars
local HOOK_pawnTracked = function(mission, pawn)
	if isMissionBoard() then
		modApi:scheduleHook(1500, function()
			if pawn:GetType() == DNT_PSION then
				DNT_Sound_Buff()
				mission[DNT_PSION] = true
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
				end
			end
		end)
	end
end

local HOOK_pawnUntracked = function(mission, pawn)
	if isMissionBoard() then
		if pawn:GetType() == DNT_PSION then
			mission[DNT_PSION] = nil
			Game:TriggerSound("/ui/battle/buff_removed")
			local pawnList = extract_table(Board:GetPawns(TEAM_ANY))
			for i = 1, #pawnList do
				local currPawn = Board:GetPawn(pawnList[i])
				if currPawn:GetTeam() == TEAM_ENEMY or (IsPassiveSkill("Psion_Leech") and currPawn:IsMech()) then
					if _G[currPawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[currPawn:GetType()].Minor then
						Board:Ping(currPawn:GetSpace(),GL_Color(255,50,50))
						trait:update(currPawn:GetSpace())
						Board:AddBurst(currPawn:GetSpace(),BURST_DOWN,DIR_NONE)
					end
				end
			end
		end
	end
end

local HOOK_pawnKilled = function(mission, pawn)
	if isMissionBoard() then
		if DNT_PsionTarget(pawn) then
			local effect = SkillEffect()
			local pos = pawn:GetSpace()
			effect:AddDelay(1)
			effect:AddAnimation(pos,"ExploRepulse3")
			effect:AddSound("/weapons/science_repulse")
			for i = DIR_START, DIR_END do
				damage = SpaceDamage(pos + DIR_VECTORS[i], 0)
				damage.iPush = i
				damage.sAnimation = "airpush_"..i
				effect:AddDamage(damage)
			end
			Board:AddEffect(effect)
		end
	end
end

local function HOOK_nextTurn(mission)
	if Board:GetTurn() == 0 then
		local enemyList = extract_table(Board:GetPawns(TEAM_ENEMY))
		for i = 1, #enemyList do
			local currPawn = Board:GetPawn(enemyList[i])
			if currPawn:GetType() == DNT_PSION then
				mission[DNT_PSION] = true
			end
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
		DNT_Reactive1['Image'] = "DNT_jelly_icon"
	else
		DNT_Reactive1['Image'] = "DNT_jelly"
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
					GetCurrentMission()[DNT_PSION] = true
					break
				end
			end
		end
	)
end

-- add hooks
local function EVENT_onModsLoaded()
	-- psion effects
	DNT_Vextra_ModApiExt:addPawnTrackedHook(HOOK_pawnTracked)
	DNT_Vextra_ModApiExt:addPawnUntrackedHook(HOOK_pawnUntracked)
	modApi:addNextTurnHook(HOOK_nextTurn)
	DNT_Vextra_ModApiExt:addPawnKilledHook(HOOK_pawnKilled)
	-- add / remove trait when selected / highlighted
	DNT_Vextra_ModApiExt:addTileHighlightedHook(HOOK_tileHighlighted)
	DNT_Vextra_ModApiExt:addTileUnhighlightedHook(HOOK_tileHighlighted)
	DNT_Vextra_ModApiExt:addPawnSelectedHook(HOOK_pawnSelected)
	DNT_Vextra_ModApiExt:addPawnDeselectedHook(HOOK_pawnSelected)
	-- for when quitting and loading first turn
	DNT_Vextra_ModApiExt:addGameLoadedHook(HOOK_gameLoaded)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

-- add / remove icon sprite
modApi.events.onGameStateChanged:subscribe(EVENT_onGameStateChanged)
