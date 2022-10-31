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

-- modApi:copyAsset("img/combat/icons/icon_acid_immune_glow.png", "img/combat/icons/DNT_acid_immune.png")
	-- Location["combat/icons/DNT_acid_immune.png"] = Point(0,4)--Point(-17,4)

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

-------------
-- Weapons --
-------------

DNT_Acid_Passive = PassiveSkill:new{
	Name = "Caustic Glands",
	Description = "Remove A.C.I.D. from other vek and make their attacks apply A.C.I.D.",
	Class = "Enemy",
	Icon = "weapons/prime_lightning.png",
	Passive = "DNT_Acid_Passive",
	CustomTipImage = "DNT_Acid_Passive_Tip",
	TipImage = {
		Unit = Point(2,3),
		CustomPawn = "DNT_Acid1",
		Target = Point(2,2),
		Friend = Point(2,2),
		Enemy = Point(2,1),
	}
}

function DNT_Acid_Passive:GetSkillEffect(p1,p2) -- for passive preview
	return SkillEffect()
end

DNT_Acid_Passive_Tip = DNT_Acid_Passive:new{}

function DNT_Acid_Passive_Tip:GetSkillEffect(p1,p2) -- for passive preview
	local ret = SkillEffect()
	local damage = SpaceDamage(Point(2,1),1)
	damage.iAcid = EFFECT_CREATE
	ret:AddMelee(p2,damage)
	return ret
end

-----------
-- Pawns --
-----------

DNT_Acid1 = Pawn:new{
	Name = "Corrosive Psion",
	Health = 2,
	MoveSpeed = 2,
	Image = "DNT_jelly", -- do not change
	LargeShield = true,
	VoidShockImmune = true,
	ImageOffset = 1, -- change this to the right sprite
	SkillList = { "DNT_Acid_Passive" },
	SoundLocation = "/enemy/jelly/",
	Flying = true,
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	-- Leader = LEADER_VINES,--LEADER_HEALTH,
	-- Tooltip = "Jelly_Health_Tooltip"
}
AddPawn("DNT_Acid1")

------------
-- Traits --
------------

local acidTrait = function(trait,pawn)
	if pawn:GetSpace() == mouseTile() or pawn:IsSelected() then
		if GetCurrentMission().DNT_Acid_Psion and pawn:GetType() ~= "DNT_Acid1" then -- change the psion and variable name here
			if pawn:GetTeam() == TEAM_ENEMY or (IsPassiveSkill("Psion_Leech") and pawn:IsMech()) then
				if _G[pawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[pawn:GetType()].Minor then
					return true
				end
			end
		end
	end
end 

trait:add{
	func = acidTrait, -- maybe change this name?
	icon = "img/combat/icons/icon_acid_immune.png", --"img/combat/icons/icon_acid_immune.png",
	icon_glow = "img/combat/icons/icon_acid_immune_glow.png", --"img/combat/icons/icon_acid_glow_immune.png",
	icon_offset = Point(0,9),
	desc_title = "Caustic Glands",
	desc_text = "The Corrosive Psion remove A.C.I.D. from other vek and make their attacks apply A.C.I.D.",
}

-----------
-- Hooks --
-----------

-- some interesting sounds
--/weapons/phase_shot --/weapons/refrigerate --"/weapons/acid_shot"

-- psion spawn
local HOOK_pawnTracked = function(mission, pawn)
	modApi:scheduleHook(1500, function()
		if pawn:GetType() == "DNT_Acid1" then
			mission.DNT_Acid_Psion = true
			if IsPassiveSkill("Psion_Leech") then
				local playerList = extract_table(Board:GetPawns(TEAM_PLAYER))
				for i = 1, #playerList do
					currPawn = Board:GetPawn(playerList[i])
					if currPawn:IsMech() then
						trait:update(currPawn:GetSpace())
						Board:Ping(currPawn:GetSpace(),GL_Color(0,255,0))
						-- Board:AddAnimation(currPawn:GetSpace(),"Acid")
					end
				end
			end
			local enemyList = extract_table(Board:GetPawns(TEAM_ENEMY))
			for i = 1, #enemyList do
				local currPawn = Board:GetPawn(enemyList[i])
				if currPawn:GetType() ~= "DNT_Acid1" then
					if _G[currPawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[currPawn:GetType()].Minor then
						trait:update(currPawn:GetSpace())
						Board:Ping(currPawn:GetSpace(),GL_Color(0,255,0))
						-- Board:AddAnimation(currPawn:GetSpace(),"Acid")
					end
				end
			end
		elseif mission.DNT_Acid_Psion and pawn:GetType() ~= "DNT_Acid1" then
			if pawn:GetTeam() == TEAM_ENEMY or (IsPassiveSkill("Psion_Leech") and pawn:IsMech()) then
				if _G[pawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[pawn:GetType()].Minor then
					trait:update(pawn:GetSpace())
					Board:Ping(pawn:GetSpace(),GL_Color(0,255,0))
					Game:TriggerSound("/props/acid_splash")
					-- Board:AddAnimation(pawn:GetSpace(),"Acid")
				end
			end
		end
	end)
end

local HOOK_pawnUntracked = function(mission, pawn)
	if pawn:GetType() == "DNT_Acid1" then
		Game:TriggerSound("/weapons/phase_shot")
		mission.DNT_Acid_Psion = nil
		if IsPassiveSkill("Psion_Leech") then
			local playerList = extract_table(Board:GetPawns(TEAM_PLAYER))
			for i = 1, #playerList do
				currPawn = Board:GetPawn(playerList[i])
				if currPawn:IsMech() then
					Board:Ping(currPawn:GetSpace(),GL_Color(255,0,0))
					trait:update(currPawn:GetSpace())
				end
			end
		end
		local enemyList = extract_table(Board:GetPawns(TEAM_ENEMY))
		for i = 1, #enemyList do
			local currPawn = Board:GetPawn(enemyList[i])
			if currPawn:GetType() ~= "DNT_Acid1" then
				if _G[currPawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[currPawn:GetType()].Minor then
					Board:Ping(currPawn:GetSpace(),GL_Color(255,0,0))
					trait:update(currPawn:GetSpace())
				end
			end
		end
	end
end

-- psion acid attack / no friendly fire
local DNT_AcidAttack = function(mission, pawn, skillEffect)
	local condVek = (_G[pawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[pawn:GetType()].Minor)
	if mission and mission.DNT_Acid_Psion then
		if skillEffect.q_effect ~= nil and condVek then -- and pawn:GetTeam() == TEAM_ENEMY then
			for i = 1, skillEffect.q_effect:size() do
				local spaceDamage = skillEffect.q_effect:index(i)
				local damage = spaceDamage.iDamage
				local dpawn = Board:GetPawn(spaceDamage.loc)
				if damage > 0 then -- and dpawn then
					spaceDamage.iAcid = EFFECT_CREATE
					if dpawn and dpawn:GetType() ~= "DNT_Acid1" then
						local condTarget = (_G[dpawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[dpawn:GetType()].Minor)
						if condTarget and (dpawn:GetTeam() == TEAM_ENEMY or (dpawn:IsMech() and IsPassiveSkill("Psion_Leech"))) then
							spaceDamage.iAcid = EFFECT_NONE
							-- spaceDamage.iDamage = 0
						end
					end
				end
			end
		end
		
		if skillEffect.effect ~= nil and IsPassiveSkill("Psion_Leech") then -- and pawn:GetTeam() == TEAM_ENEMY then
			for i = 1, skillEffect.effect:size() do
				local spaceDamage = skillEffect.effect:index(i)
				local damage = spaceDamage.iDamage
				local dpawn = Board:GetPawn(spaceDamage.loc)
				if damage > 0 then -- and dpawn then
					spaceDamage.iAcid = EFFECT_CREATE
					if dpawn and dpawn:GetType() ~= "DNT_Acid1" then
						local condTarget = (_G[dpawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[dpawn:GetType()].Minor)
						if condTarget and (dpawn:GetTeam() == TEAM_ENEMY or (dpawn:IsMech() and IsPassiveSkill("Psion_Leech"))) then
							spaceDamage.iAcid = EFFECT_NONE
							-- spaceDamage.iDamage = 0
						end
					end
				end
			end
		end
	end
end

local HOOK_onSkillBuild = function(mission, pawn, weaponId, p1, p2, skillEffect)
	DNT_AcidAttack(mission, pawn, skillEffect)
end


local HOOK_onFinalEffectBuild = function(mission, pawn, weaponId, p1, p2, p3, skillEffect)
	DNT_AcidAttack(mission, pawn, skillEffect)
end

-- psion acid immune / acid heal
local function HOOK_PawnIsAcid(mission, pawn, isAcid)
	if mission.DNT_Acid_Psion and isAcid and pawn:GetType() ~= "DNT_Acid1" then
		if _G[pawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[pawn:GetType()].Minor then
			if pawn:GetTeam() == TEAM_ENEMY or (pawn:IsMech() and IsPassiveSkill("Psion_Leech")) then
				pawn:SetAcid(false)
				-- Board:DamageSpace(pawn:GetSpace(), -1)
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
		DNT_Acid1['Image'] = "DNT_jelly_icon"
	else
		DNT_Acid1['Image'] = "DNT_jelly"
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
				if currPawn:GetType() == "DNT_Acid1" then
					GetCurrentMission().DNT_Acid_Psion = true
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
			if currPawn:GetType() == "DNT_Acid1" then
				mission.DNT_Acid_Psion = true
			end
		end
	end
end

-- add hooks
local function EVENT_onModsLoaded()
	------------------------ add your hooks here------------------------
	DNT_Vextra_ModApiExt:addPawnTrackedHook(HOOK_pawnTracked)
	DNT_Vextra_ModApiExt:addPawnUntrackedHook(HOOK_pawnUntracked)
	DNT_Vextra_ModApiExt:addSkillBuildHook(HOOK_onSkillBuild)
	DNT_Vextra_ModApiExt:addFinalEffectBuildHook(HOOK_onFinalEffectBuild)
	DNT_Vextra_ModApiExt:addPawnIsAcidHook(HOOK_PawnIsAcid)
	
	------------------------ do not change this -------------------------
	-- add / remove trait when selected / highlighted
	DNT_Vextra_ModApiExt:addTileHighlightedHook(HOOK_tileHighlighted)
	DNT_Vextra_ModApiExt:addTileUnhighlightedHook(HOOK_tileHighlighted)
	DNT_Vextra_ModApiExt:addPawnSelectedHook(HOOK_pawnSelected)
	DNT_Vextra_ModApiExt:addPawnDeselectedHook(HOOK_pawnSelected)
	-- for when quitting and loading first turn
	DNT_Vextra_ModApiExt:addGameLoadedHook(HOOK_gameLoaded)
	modApi:addNextTurnHook(HOOK_nextTurn)
end


--------------------------- do not change this --------------------------
modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
-- add / remove icon sprite
modApi.events.onGameStateChanged:subscribe(EVENT_onGameStateChanged)
-------------------------------------------------------------------------