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

modApi:appendAsset("img/icons/DNT_acid_icon.png",resourcePath.."img/icons/DNT_acid_icon.png") --TEMPORARY
	Location["icons/DNT_acid_icon.png"] = Point(0,0)
modApi:appendAsset("img/icons/DNT_acid_icon_glow.png",resourcePath.."img/icons/DNT_acid_icon_glow.png") --TEMPORARY
	Location["icons/DNT_acid_icon_glow.png"] = Point(0,0)

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

local ptname = "Acid"
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."1.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."1.png")

--------------
-- Emitters --
--------------

local BURST_UP = "DNT_Acid_Up"
DNT_Acid_Up = Emitter:new{
	image = "icons/DNT_acid_icon.png",
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

local BURST_DOWN = "DNT_Acid_Down"
DNT_Acid_Down = Emitter:new{
	image = "icons/DNT_acid_icon.png",
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

DNT_Acid_Passive = PassiveSkill:new{
	Name = "Caustic Glands",
	Description = "All other Vek leave A.C.I.D. on death and apply it to adjacent enemies at the start of the player's turn.",
	Class = "Enemy",
	Icon = "weapons/prime_lightning.png",
	Passive = "DNT_Acid_Passive",
	CustomTipImage = "DNT_Acid_Passive_Tip",
	TipImage = {
		Unit = Point(2,3),
		CustomPawn = "DNT_Acid1",
		Target = Point(2,2),
		Friend = Point(2,1),
		Enemy = Point(3,1),
	}
}

function DNT_Acid_Passive:GetSkillEffect(p1,p2) -- for passive preview
	return SkillEffect()
end

DNT_Acid_Passive_Tip = DNT_Acid_Passive:new{}

function DNT_Acid_Passive_Tip:GetSkillEffect(p1,p2) -- for passive preview
	local p1 = Point(2,1)
	local p2 = Point(3,1)
	
	local ret = SkillEffect()
	Board:Ping(p1,GL_Color(0,255,0))
	Board:AddBurst(p1,BURST_UP,DIR_NONE)
	
	effect = SkillEffect()
	local damage = SpaceDamage(p2)
	damage.sAnimation = "ExploFirefly2"
	damage.iAcid = EFFECT_CREATE
	effect:AddProjectile(p1,damage,"effects/shot_firefly2",NO_DELAY)
	
	if IsPassiveSkill("Psion_Leech") then -- psionic receiver
		Board:Ping(p2,GL_Color(0,255,0))
		Board:AddBurst(p2,BURST_UP,DIR_NONE)
		
		damage.loc = p1
		damage.sAnimation = "ExploFirefly2"
		effect:AddProjectile(p2,damage,"effects/shot_firefly2",NO_DELAY)
	end
	
	Board:AddEffect(effect)
	
	damage = SpaceDamage(p1,0) -- acid on death effect
	damage.iAcid = EFFECT_CREATE
	ret:AddDamage(damage)
	
	damage = SpaceDamage(p1,3,3)
	ret:AddMelee(p2,damage)
	ret:AddDelay(1)
	
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

----------------------
-- Helper Functions --
----------------------

local DNT_PSION = "DNT_Acid1"

local function DNT_PsionTarget(pawn)
	if GetCurrentMission() and pawn then
		if GetCurrentMission()[DNT_PSION] and pawn:GetType() ~= DNT_PSION then
			if pawn:GetTeam() == TEAM_ENEMY or (IsPassiveSkill("Psion_Leech") and pawn:IsMech()) then
				if _G[pawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[pawn:GetType()].Minor then
					return true
				end
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
	func = DNT_psionTrait,
	icon = "img/icons/DNT_acid_icon.png",
	icon_glow = "img/icons/DNT_acid_icon_glow.png",
	icon_offset = Point(0,9),
	desc_title = "Caustic Glands",
	desc_text = "The Corrosive Psion causes Vek to leave A.C.I.D. on death and apply it to adjacent enemies at the start of the player's turn.",
}

trait:add{
	func = DNT_psionTraitB,
	icon = "img/icons/DNT_acid_icon.png",
	icon_glow = "img/icons/DNT_acid_icon_glow.png",
	icon_offset = Point(8,17),
	desc_title = "Caustic Glands",
	desc_text = "The Corrosive Psion causes Vek to leave A.C.I.D. on death and apply it to adjacent enemies at the start of the player's turn.",
}

------------------------
-- Hooks and Function --
------------------------

-- some interesting sounds
--/weapons/phase_shot /weapons/refrigerate "/weapons/acid_shot" "/impact/generic/acid_canister"
local function DNT_Sound_Buff()
	Game:TriggerSound("/ui/battle/buff_explode")
	Game:TriggerSound("/props/acid_splash")
end

-- psion spawn
local HOOK_pawnTracked = function(mission, pawn)
	if isMissionBoard() then
		modApi:scheduleHook(1500, function()
			if pawn:GetType() == DNT_PSION and not pawn:IsMinor() then
				DNT_Sound_Buff()
				mission[DNT_PSION] = true
				local pawnList = extract_table(Board:GetPawns(TEAM_ANY))
				for i = 1, #pawnList do
					local currPawn = Board:GetPawn(pawnList[i])
					if DNT_PsionTarget(currPawn) then
						trait:update(currPawn:GetSpace())
						Board:Ping(currPawn:GetSpace(),GL_Color(0,255,0))
						Board:AddBurst(currPawn:GetSpace(),BURST_UP,DIR_NONE)
						-- currPawn:SetAcid(false)
					end
				end
			elseif DNT_PsionTarget(pawn) then
				trait:update(pawn:GetSpace())
				Board:Ping(pawn:GetSpace(),GL_Color(0,255,0))
				-- pawn:SetAcid(false)
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
		if pawn:GetType() == DNT_PSION and not pawn:IsMinor() then
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
	if mission[DNT_PSION] and Game:GetTeamTurn() == TEAM_PLAYER then
		local pawnList = extract_table(Board:GetPawns(TEAM_ANY))
		local pNumber = false
		for i = 1, #pawnList do
			local currPawn = Board:GetPawn(pawnList[i])
			if DNT_PsionTarget(currPawn) then
				local effect = SkillEffect()
				local p1 = currPawn:GetSpace()
				for i = DIR_START, DIR_END do
					local p2 = p1 + DIR_VECTORS[i]
					local adjPawn = Board:GetPawn(p2)
					if adjPawn and adjPawn:GetTeam() ~= currPawn:GetTeam() and adjPawn:GetTeam() ~= TEAM_NONE then
						pNumber = true
						adjPawn:SetAcid(true) -- instead of adding on damage for reset turn to work
						local damage = SpaceDamage(p2)
						damage.sSound = "/props/acid_splash"
						-- damage.sAnimation = "ExploFirefly2" -- has too much delay
						damage.sScript = string.format("Board:AddAnimation(%s,'ExploFirefly2',ANIM_NO_DELAY)",p2:GetString())
						effect:AddProjectile(p1,damage,"effects/shot_firefly2",NO_DELAY)
					end
				end
				Board:AddEffect(effect)
				-- if pNumber then
					-- Board:Ping(currPawn:GetSpace(), GL_Color(0,255,0))
					-- Board:AddBurst(currPawn:GetSpace(),BURST_UP,DIR_NONE)
				-- end
			end
		end
		if pNumber then
			-- DNT_Sound_Buff()
			-- Game:TriggerSound("/props/acid_splash")
		end
	end
end

local HOOK_pawnKilled = function(mission, pawn)
	if isMissionBoard() then
		if DNT_PsionTarget(pawn) then
			pawn:SetAcid(true)
		end
	end
end

-- add hooks
local function EVENT_onModsLoaded()
	------------------------ add your hooks here------------------------
	DNT_Vextra_ModApiExt:addPawnTrackedHook(HOOK_pawnTracked)
	DNT_Vextra_ModApiExt:addPawnUntrackedHook(HOOK_pawnUntracked)
	DNT_Vextra_ModApiExt:addPawnKilledHook(HOOK_pawnKilled)
	-- DNT_Vextra_ModApiExt:addSkillBuildHook(HOOK_onSkillBuild)
	-- DNT_Vextra_ModApiExt:addFinalEffectBuildHook(HOOK_onFinalEffectBuild)
	-- DNT_Vextra_ModApiExt:addPawnIsAcidHook(HOOK_PawnIsAcid)

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
