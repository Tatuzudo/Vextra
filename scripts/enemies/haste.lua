local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
local previewer = require(scriptPath.."weaponPreview/api")
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

--------------
-- Emitters --
--------------

local BURST_DOWN = "DNT_Haste_Down" 
DNT_Haste_Down = Emitter:new{
	image = "combat/icons/icon_kickoff.png",
	x = -14,
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

DNT_Haste_Passive = PassiveSkill:new{
	Name = "Gotta Go Fast",--"Haste Hormones",
	Description = "All other Vek receive +2 bonus movement at the start of every turn.",
	Class = "Enemy",
	Icon = "weapons/prime_lightning.png",
	Passive = "DNT_Haste_Passive",
	CustomTipImage = "DNT_Haste_Passive_Tip",
	TipImage = {
		Unit = Point(2,3),
		CustomPawn = "DNT_Haste1",
		Target = Point(2,2),
		Friend = Point(1,0),
	}
}

function DNT_Haste_Passive:GetSkillEffect(p1,p2) -- for passive preview
	return SkillEffect()
end

DNT_Haste_Passive_Tip = DNT_Haste_Passive:new{}

function DNT_Haste_Passive_Tip:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	
	Board:Ping(Point(1,0),GL_Color(0,255,0))
	Board:GetPawn(Point(1,0)):AddMoveBonus(2)
	
	ret:AddMove(Board:GetPath(Point(1,0), Point(3,3), PATH_GROUND), FULL_DELAY)
	ret:AddDelay(1)
	
	return ret
end

-----------
-- Pawns --
-----------

DNT_Haste1 = Pawn:new{
	Name = "Sonic Psion",--"Haste Psion",
	Health = 2,
	MoveSpeed = 2,
	Image = "DNT_jelly",--"DNT_jelly_icon",
	LargeShield = true,
	VoidShockImmune = true,
	ImageOffset = 0,
	SkillList = { "DNT_Haste_Passive" },
	SoundLocation = "/enemy/jelly/",
	Flying = true,
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	-- Leader = LEADER_VINES,--LEADER_HEALTH,
	-- Tooltip = "Jelly_Health_Tooltip"
}
AddPawn("DNT_Haste1")

----------------------
-- Helper Functions --
----------------------

local DNT_PSION = "DNT_Haste1"

local function DNT_PsionTarget(pawn)
	if GetCurrentMission()[DNT_PSION] and pawn:GetMoveSpeed() > 0 and pawn:GetType() ~= DNT_PSION then
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

local hasteTrait = function(trait,pawn)
	if pawn:GetSpace() == mouseTile() or pawn:IsSelected() then
		return DNT_PsionTarget(pawn)
	end
end 

trait:add{
	func = hasteTrait,
	icon = "img/combat/icons/icon_kickoff.png",
	icon_glow = "img/combat/icons/icon_kickoff_glow.png",
	icon_offset = Point(0,9),
	desc_title = "Gotta Go Fast",
	desc_text = "The Sonic Psion will add +2 bonus movement to all Vek at the turn start.",
}

------------------------
-- Hooks and Function --
------------------------

local DNT_SPEED = 2

local HOOK_pawnTracked = function(mission, pawn)
	if isMissionBoard() then
		modApi:scheduleHook(1500, function()
			if pawn:GetType() == DNT_PSION then
				mission[DNT_PSION] = true
				local pawnList = extract_table(Board:GetPawns(TEAM_ANY))
				for i = 1, #pawnList do
					local currPawn = Board:GetPawn(pawnList[i])
					if DNT_PsionTarget(currPawn) then
						currPawn:AddMoveBonus(DNT_SPEED)
						trait:update(currPawn:GetSpace())
					end
				end
			elseif DNT_PsionTarget(pawn) then
				pawn:AddMoveBonus(DNT_SPEED)
				trait:update(pawn:GetSpace())
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

local function HOOK_nextTurn(mission)
	if Board:GetTurn() ~= 0 then
		if mission[DNT_PSION] and Game:GetTeamTurn() == TEAM_ENEMY then
			local pawnList = extract_table(Board:GetPawns(TEAM_ANY))
			for i = 1, #pawnList do
				local currPawn = Board:GetPawn(pawnList[i])
				if DNT_PsionTarget(currPawn) then
					currPawn:AddMoveBonus(DNT_SPEED)
					trait:update(currPawn:GetSpace())
				end
			end
		end
	end
	-- quiting / loading first turn fix
	if mission[DNT_PSION] == nil then
		local enemyList = extract_table(Board:GetPawns(TEAM_ENEMY))
		for i = 1, #enemyList do
			local currPawn = Board:GetPawn(enemyList[i])
			if currPawn:GetType() == DNT_PSION then
				mission[DNT_PSION] = true
				break
			end
		end
		if mission[DNT_PSION] then
			local pawnList = extract_table(Board:GetPawns(TEAM_ANY))
			for i = 1, #pawnList do
				local currPawn = Board:GetPawn(pawnList[i])
				if DNT_PsionTarget(currPawn) then
					currPawn:AddMoveBonus(DNT_SPEED)
					trait:update(currPawn:GetSpace())
				end
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
		DNT_Haste1['Image'] = "DNT_jelly_icon"
	else
		DNT_Haste1['Image'] = "DNT_jelly"
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
			
			if GetCurrentMission()[DNT_PSION] then
				local pawnList = extract_table(Board:GetPawns(TEAM_ANY))
				for i = 1, #pawnList do
					local currPawn = Board:GetPawn(pawnList[i])
					if DNT_PsionTarget(currPawn) then
						currPawn:AddMoveBonus(DNT_SPEED)
						trait:update(currPawn:GetSpace())
					end
				end
			end
		end
	)
end

-- add hooks
local function EVENT_onModsLoaded()
	DNT_Vextra_ModApiExt:addPawnTrackedHook(HOOK_pawnTracked)
	DNT_Vextra_ModApiExt:addPawnUntrackedHook(HOOK_pawnUntracked)
	modApi:addNextTurnHook(HOOK_nextTurn)
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
