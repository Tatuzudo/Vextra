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

modApi:appendAsset("img/icons/DNT_nurse_icon.png",resourcePath.."img/icons/DNT_nurse_icon.png")
	Location["icons/DNT_nurse_icon.png"] = Point(0,0)
modApi:appendAsset("img/icons/DNT_nurse_icon_glow.png",resourcePath.."img/icons/DNT_nurse_icon_glow.png")
	Location["icons/DNT_nurse_icon_glow.png"] = Point(0,0)

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

local ptname = "Nurse"
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."1.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."1.png")

--------------
-- Emitters --
--------------

local BURST_UP = "DNT_Nurse_Up"
DNT_Nurse_Up = Emitter:new{
	image = "icons/DNT_nurse_icon.png",
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

local BURST_DOWN = "DNT_Nurse_Down"
DNT_Nurse_Down = Emitter:new{
	image = "icons/DNT_nurse_icon.png",
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

-------------
-- Weapons --
-------------

DNT_Nurse_Passive = PassiveSkill:new{
	Name = "Healing Burst",
	Description = "All other Vek heal with friendly damage.",--"All other Vek heal instead of damaging allies.",
	Class = "Enemy",
	Icon = "weapons/prime_lightning.png",
	Passive = "DNT_Nurse_Passive",
	CustomTipImage = "DNT_Nurse_Passive_Tip",
	TipImage = {
		Unit = Point(2,3),
		CustomPawn = "DNT_Nurse1",
		Target = Point(2,2),
		Friend = Point(1,1),
		Friend2 = Point(2,1),
	}
}

function DNT_Nurse_Passive:GetSkillEffect(p1,p2) -- for passive preview
	return SkillEffect()
end

DNT_Nurse_Passive_Tip = DNT_Nurse_Passive:new{}

function DNT_Nurse_Passive_Tip:GetSkillEffect(p1,p2) -- for passive preview
	local ret = SkillEffect()
	local damage = 1
	if IsPassiveSkill("Passive_FriendlyFire") then damage = damage + 1 end
	if IsPassiveSkill("Passive_FriendlyFire_A") or IsPassiveSkill("Passive_FriendlyFire_B") then damage = damage + 1 end
	if IsPassiveSkill("Passive_FriendlyFire_AB") then damage = damage + 1 end

	Board:Ping(Point(1,1),GL_Color(0,255,0))
	Board:AddBurst(Point(1,1),BURST_UP,DIR_NONE)
	Board:Ping(Point(2,1),GL_Color(0,255,0))
	Board:AddBurst(Point(2,1),BURST_UP,DIR_NONE)

	local dam = SpaceDamage(Point(2,1),-damage)
	ret:AddMelee(Point(1,1),dam)
	ret:AddDelay(2)

	return ret
end

-----------
-- Pawns --
-----------

DNT_Nurse1 = Pawn:new{
	Name = "Nurse Psion",
	Health = 2,
	MoveSpeed = 2,
	Image = "DNT_jelly", -- do not change
	LargeShield = true,
	VoidShockImmune = true,
	ImageOffset = 3, -- change this to the right sprite
	SkillList = { "DNT_Nurse_Passive" },
	SoundLocation = "/enemy/jelly/",
	Flying = true,
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	-- Leader = LEADER_VINES,--LEADER_HEALTH,
	-- Tooltip = "Jelly_Health_Tooltip"
}
AddPawn("DNT_Nurse1")

----------------------
-- Helper Functions --
----------------------

local DNT_PSION = "DNT_Nurse1"

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

local DNT_psionTrait = function(trait,pawn)
	if _G[pawn:GetType()].Tier ~= TIER_BOSS then
		if pawn:GetSpace() == mouseTile() or pawn:IsSelected() then
			return DNT_PsionTarget(pawn)
		end
	end
end

local DNT_psionTraitB = function(trait,pawn)
	if _G[pawn:GetType()].Tier == TIER_BOSS then
		if pawn:GetSpace() == mouseTile() or pawn:IsSelected() then
			return DNT_PsionTarget(pawn)
		end
	end
end

trait:add{
	func = DNT_psionTrait, -- maybe change this name?
	icon = "img/icons/DNT_nurse_icon.png",
	icon_glow = "img/icons/DNT_nurse_icon_glow.png",
	icon_offset = Point(2,10),
	desc_title = "Healing Burst",--"Healing Strikes",
	desc_text = "The Nurse Psion causes other Vek to heal with friendly damage.",--"The Nurse Psion causes Vek to heal instead of damaging allies.",
}

trait:add{
	func = DNT_psionTraitB, -- maybe change this name?
	icon = "img/icons/DNT_nurse_icon.png",
	icon_glow = "img/icons/DNT_nurse_icon_glow.png",
	icon_offset = Point(6,16),
	desc_title = "Healing Burst",
	desc_text = "The Nurse Psion causes other Vek to heal with friendly damage.",
}

------------------------
-- Hooks and Function --
------------------------

-- some interesting sounds
--/weapons/phase_shot /weapons/refrigerate "/weapons/acid_shot" "/impact/generic/acid_canister"
local function DNT_Sound_Buff()
	Game:TriggerSound("/ui/battle/buff_regen")
	Game:TriggerSound("/impact/generic/tractor_beam")
end

-- psion spawn
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

-- psion acid attack / no friendly fire
local DNT_NurseAttack = function(mission, p1, skillEffect)
	local pawn = Board:GetPawn(p1)
	-- if mission and mission[DNT_PSION] and pawn and DNT_PsionTarget(pawn) then
	local validPawn
	if pawn then validPawn = (_G[pawn:GetType()].Minor or pawn:GetTeam() == TEAM_PLAYER) end
	if mission and mission[DNT_PSION] and pawn and (DNT_PsionTarget(pawn) or validPawn) then
		if skillEffect.q_effect ~= nil then -- and pawn:GetTeam() == TEAM_ENEMY then
			for i = 1, skillEffect.q_effect:size() do
				local spaceDamage = skillEffect.q_effect:index(i)
				local damage = spaceDamage.iDamage
				local dpawn = Board:GetPawn(spaceDamage.loc)
				-- if dpawn and dpawn:GetTeam() == pawn:GetTeam() and _G[dpawn:GetType()].DefaultFaction ~= FACTION_BOTS then
				if dpawn and pawn:GetTeam() == dpawn:GetTeam() and DNT_PsionTarget(dpawn) then
					if damage > 0 and damage ~= DAMAGE_DEATH then -- and dpawn then
						if pawn:GetTeam() == TEAM_ENEMY and not IsTipImage() then
							if IsPassiveSkill("Passive_FriendlyFire") then damage = damage + 1 end
							if IsPassiveSkill("Passive_FriendlyFire_A") or IsPassiveSkill("Passive_FriendlyFire_B") then damage = damage + 1 end
							if IsPassiveSkill("Passive_FriendlyFire_AB") then damage = damage + 1 end
						end
						spaceDamage.iDamage = -damage
					end
				end
			end
		end

		if skillEffect.effect ~= nil then -- and pawn:GetTeam() == TEAM_ENEMY then
			for i = 1, skillEffect.effect:size() do
				local spaceDamage = skillEffect.effect:index(i)
				local damage = spaceDamage.iDamage
				local dpawn = Board:GetPawn(spaceDamage.loc)
				-- if dpawn and dpawn:GetTeam() == pawn:GetTeam() and _G[dpawn:GetType()].DefaultFaction ~= FACTION_BOTS then
				if dpawn and pawn:GetTeam() == dpawn:GetTeam() and DNT_PsionTarget(dpawn) then
					if damage > 0 and damage ~= DAMAGE_DEATH then -- and dpawn then
						if pawn:GetTeam() == TEAM_ENEMY and not IsTipImage() then
							if IsPassiveSkill("Passive_FriendlyFire") then damage = damage + 1 end
							if IsPassiveSkill("Passive_FriendlyFire_A") or IsPassiveSkill("Passive_FriendlyFire_B") then damage = damage + 1 end
							if IsPassiveSkill("Passive_FriendlyFire_AB") then damage = damage + 1 end
						end
						spaceDamage.iDamage = -damage
					end
				end
			end
		end
	end
end

local HOOK_onSkillBuild = function(mission, pawn, weaponId, p1, p2, skillEffect)
	DNT_NurseAttack(mission, p1, skillEffect)
end


local HOOK_onFinalEffectBuild = function(mission, pawn, weaponId, p1, p2, p3, skillEffect)
	DNT_NurseAttack(mission, p1, skillEffect)
end

-- -- psion acid immune / acid heal
-- local function HOOK_PawnIsAcid(mission, pawn, isAcid)
	-- if mission[DNT_PSION] and isAcid and pawn:GetType() ~= DNT_PSION then
		-- if _G[pawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[pawn:GetType()].Minor then
			-- if pawn:GetTeam() == TEAM_ENEMY or (pawn:IsMech() and IsPassiveSkill("Psion_Leech")) then
				-- pawn:SetAcid(false)
				-- -- Board:DamageSpace(pawn:GetSpace(), -1)
			-- end
		-- end
	-- end
-- end


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
		DNT_Nurse1['Image'] = "DNT_jelly_icon"
	else
		DNT_Nurse1['Image'] = "DNT_jelly"
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

-- add hooks
local function EVENT_onModsLoaded()
	------------------------ add your hooks here------------------------
	DNT_Vextra_ModApiExt:addPawnTrackedHook(HOOK_pawnTracked)
	DNT_Vextra_ModApiExt:addPawnUntrackedHook(HOOK_pawnUntracked)
	DNT_Vextra_ModApiExt:addSkillBuildHook(HOOK_onSkillBuild)
	DNT_Vextra_ModApiExt:addFinalEffectBuildHook(HOOK_onFinalEffectBuild)

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
