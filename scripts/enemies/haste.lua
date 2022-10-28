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

-- modApi:copyAsset("img/combat/icons/icon_kickoff.png", "img/combat/icons/DNT_icon_haste.png")
	-- -- Location["combat/icons/DNT_icon_haste.png"] = Point(-17,4)
-- modApi:copyAsset("img/combat/icons/icon_kickoff_glow.png", "img/combat/icons/DNT_icon_haste_glow.png")
	-- -- Location["combat/icons/DNT_icon_haste_glow.png"] = Point(-17,4)

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

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES

-- jelly = 	EnemyUnit:new{ Image = "units/aliens/jelly.png", PosX = -16, PosY = -14, Height = 10 }
-- jellya = 	jelly:new{ Image = "units/aliens/jellya.png", PosX = -17, PosY = -14, NumFrames = 4 }
-- jellye = 	BaseEmerge:new{ Image = "units/aliens/jelly_emerge.png", PosX = -23, PosY = -21, Height = 10 }
-- jellyd = 	jelly:new{ Image = "units/aliens/jelly_death.png", PosX = -18, PosY = -14, NumFrames = 8, Time = 0.14, Loop = false }
-- jelly_ns = 		MechIcon:new{ Image = "units/aliens/jelly_ns.png", Height = 10 }

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


-------------
-- Weapons --
-------------

DNT_Haste_Passive = PassiveSkill:new{
	Name = "Gotta Go Fast",--"Haste Hormones",
	Description = "All other Vek receive +2 bonus movement at the start of every turn.",
	Class = "Enemy",
	Icon = "weapons/prime_lightning.png",
	Passive = "DNT_Haste_Passive",
	TipImage = {
		Unit = Point(2,3),
		CustomPawn = "DNT_Haste1",
		Target = Point(2,2),
		Friend = Point(1,0),
		CustomFriend = "Firefly1",
	}
}

function DNT_Haste_Passive:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	ret:AddMove(Board:GetPath(Point(1,0), Point(3,3), PATH_GROUND), FULL_DELAY)
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
AddPawn("DNT_HastePsion1")

------------
-- Traits --
------------

local hasteTrait = function(trait,pawn)
	if pawn:GetSpace() == mouseTile() or pawn:IsSelected() then
		if GetCurrentMission().DNT_Haste_Psion and pawn:GetType() ~= "DNT_Haste1" then
			if pawn:GetTeam() == TEAM_ENEMY or (IsPassiveSkill("Psion_Leech") and pawn:IsMech()) then
				if _G[pawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[pawn:GetType()].Minor then
					return true
				end
			end
		end
	end
end 

trait:add{
	func = hasteTrait,
	icon = "img/combat/icons/icon_kickoff.png",
	icon_glow = "img/combat/icons/icon_kickoff_glow.png",
	icon_offset = Point(0,9),
	desc_title = "Gotta Go Fast",
	desc_text = "The Sonic Psion will add 2 bonus movement to all Vek at the start of every turn.",
}

-----------
-- Hooks --
-----------

local SPEED = 2

local HOOK_pawnTracked = function(mission, pawn)
	modApi:scheduleHook(1500, function()
		if pawn:GetType() == "DNT_Haste1" then
			mission.DNT_Haste_Psion = true
			if IsPassiveSkill("Psion_Leech") then
				local playerList = extract_table(Board:GetPawns(TEAM_PLAYER))
				for i = 1, #playerList do
					currPawn = Board:GetPawn(playerList[i])
					if currPawn:GetMoveSpeed() > 0 and currPawn:IsMech() then
						currPawn:AddMoveBonus(SPEED)
						trait:update(currPawn:GetSpace())
					end
				end
			end
			local enemyList = extract_table(Board:GetPawns(TEAM_ENEMY))
			for i = 1, #enemyList do
				local currPawn = Board:GetPawn(enemyList[i])
				if currPawn:GetMoveSpeed() > 0 and currPawn:GetType() ~= "DNT_Haste1" then
					if _G[currPawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[currPawn:GetType()].Minor then
						currPawn:AddMoveBonus(SPEED)
						trait:update(currPawn:GetSpace())
					end
				end
			end
		elseif mission.DNT_Haste_Psion and pawn:GetMoveSpeed() > 0 and pawn:GetType() ~= "DNT_Haste1" then
			if pawn:GetTeam() == TEAM_ENEMY or (IsPassiveSkill("Psion_Leech") and pawn:IsMech()) then
				if _G[pawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[pawn:GetType()].Minor then
					pawn:AddMoveBonus(SPEED)
					trait:update(pawn:GetSpace())
				end
			end
		end
	end)
end

local HOOK_pawnUntracked = function(mission, pawn)
	if pawn:GetType() == "DNT_Haste1" then
		mission.DNT_Haste_Psion = nil
		if IsPassiveSkill("Psion_Leech") then
			local playerList = extract_table(Board:GetPawns(TEAM_PLAYER))
			for i = 1, #playerList do
				currPawn = Board:GetPawn(playerList[i])
				if currPawn:GetMoveSpeed() > 0 and currPawn:IsMech() then
					Board:Ping(currPawn:GetSpace(),GL_Color(255,0,0))
					trait:update(currPawn:GetSpace())
				end
			end
		end
		local enemyList = extract_table(Board:GetPawns(TEAM_ENEMY))
		for i = 1, #enemyList do
			local currPawn = Board:GetPawn(enemyList[i])
			if currPawn:GetMoveSpeed() > 0 and currPawn:GetType() ~= "DNT_Haste1" then
				if _G[currPawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[currPawn:GetType()].Minor then
					Board:Ping(currPawn:GetSpace(),GL_Color(255,0,0))
					trait:update(currPawn:GetSpace())
				end
			end
		end
	end
end

local function HOOK_nextTurn(mission)
	if Board:GetTurn() ~= 0 then
		if mission.DNT_Haste_Psion and Game:GetTeamTurn() == TEAM_ENEMY then
			if IsPassiveSkill("Psion_Leech") then
				local playerList = extract_table(Board:GetPawns(TEAM_PLAYER))
				for i = 1, #playerList do
					currPawn = Board:GetPawn(playerList[i])
					if currPawn:GetMoveSpeed() > 0 and currPawn:IsMech() then
						currPawn:AddMoveBonus(SPEED)
						trait:update(currPawn:GetSpace())
					end
				end
			end
			local enemyList = extract_table(Board:GetPawns(TEAM_ENEMY))
			for i = 1, #enemyList do
				local currPawn = Board:GetPawn(enemyList[i])
				if currPawn:GetMoveSpeed() > 0 and currPawn:GetType() ~= "DNT_Haste1" then
					if _G[currPawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[currPawn:GetType()].Minor then
						currPawn:AddMoveBonus(SPEED)
						trait:update(currPawn:GetSpace())
					end
				end
			end
		end
	end
end

-- add / remove trait when selected / highlighted
local HOOK_tileHighlighted = function(mission, point)
	trait:update(point)
end

local HOOK_pawnSelected = function(mission, pawn)
	trait:update(pawn:GetSpace())
end

-- add / remove icon sprite
local EVENT_onGameStateChanged = function(newGameState, oldGameState)
	if newGameState == "Map" then
		DNT_Haste1['Image'] = "DNT_jelly_icon"
	else
		DNT_Haste1['Image'] = "DNT_jelly"
	end
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
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

-- add / remove icon sprite
modApi.events.onGameStateChanged:subscribe(EVENT_onGameStateChanged)