local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
--local previewer = require(scriptPath.."weaponPreview/api")

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

local name = "antlion" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -23, PosY = -5}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -23, PosY = -5, NumFrames = 9}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_antlion = base
a.DNT_antlione = baseEmerge
a.DNT_antliona = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 8 }
a.DNT_antliond = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 8, Time = .14 } --Numbers copied for now
a.DNT_antlionw = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png", PosY = 0} --Only if there's a boss

-----------------
--  Portraits  --
-----------------

local ptname = "Antlion"
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."1.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."1.png")
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."2.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."2.png")
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."Boss.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."Boss.png")

-------------
-- Weapons --
-------------

DNT_AntlionAtk1 = Skill:new {
	-- Name = "Shattering Mandibles", --This needs to be better
	Name = "Seismic Pincers",
	Description = "Crack the target's tile, preparing to strike it.",
	Damage = 1,
	PathSize = 1,
	Class = "Enemy",
	LaunchSound = "",
	Crack = 1,
	ExtraTiles = false,
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy = Point(2,1),
		CustomPawn = "DNT_Antlion1",
		CustomEnemy = "BottlecapMech", --Not working, but not super important
	}
}

--[[
function DNT_AntlionAtk1:GetTargetArea(p1)
	local ret = PointList()
	ret:push_back(p1)
	return ret
end
--]]

function DNT_AntlionAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	if IsTipImage() then
		ret:AddDelay(0.3) --I want to see the crack happen
	end

	local targets = {}
	if not self.ExtraTiles then
		table.insert(targets, p2)
	else
		for i=DIR_START, DIR_END do
			table.insert(targets, p1 + DIR_VECTORS[i])
		end
	end

	for _, target in pairs(targets) do

		local damage = nil
		--crack + bounce
		if not Board:IsBuilding(target) and (Board:GetTerrain(target) ~= TERRAIN_ICE or (Board:GetTerrain(target) == TERRAIN_ICE and Board:GetHealth(target) >= 2)) then
			damage = SpaceDamage(target,0)
			damage.iCrack = self.Crack
			ret:AddDamage(damage)
			ret:AddBurst(target,"Emitter_Crack_Start2",DIR_NONE)
			ret:AddBounce(target,2)
		end
		ret:AddDelay(0.2)

		--HOOK_pawnDamaged
		damage = SpaceDamage(target,self.Damage)
		damage.sSound = "/enemy/burrower_1/attack"
		damage.sAnimation = "SwipeClaw2"
		ret:AddQueuedMelee(p1, damage, NO_DELAY)
		ret:AddQueuedDelay(0.2)
	end

	return ret
end

DNT_AntlionAtk2 = DNT_AntlionAtk1:new { --Just an example
	Damage = 3,
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy = Point(2,1),
		CustomPawn = "DNT_Antlion2",
	}
}

DNT_AntlionAtkB = DNT_AntlionAtk1:new { --Just an example
	Description = "Crack all adjacent tiles, preparing to strike them.",
	ExtraTiles = true,
	Damage = 2,
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy = Point(2,1),
		Enemy2 = Point(1,2),
		Building = Point(2,3),
		CustomPawn = "DNT_AntlionBoss",
	}
}

-----------
-- Pawns --
-----------

DNT_Antlion1 = Pawn:new
	{
		Name = "Antlion",
		Health = 3,
		MoveSpeed = 3,
		Image = "DNT_antlion", --lowercase
		SkillList = {"DNT_AntlionAtk1"},
		SoundLocation = "/enemy/burrower_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Burrows = true,
		Pushable = false
	}
AddPawn("DNT_Antlion1")

DNT_Antlion2 = Pawn:new
	{
		Name = "Alpha Antlion",
		Health = 5,
		MoveSpeed = 3,
		SkillList = {"DNT_AntlionAtk2"},
		Image = "DNT_antlion",
		SoundLocation = "/enemy/burrower_1/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
		Burrows = true,
		Pushable = false
	}
AddPawn("DNT_Antlion2")

DNT_AntlionBoss = Pawn:new
	{
		Name = "Antlion Leader",
		Health = 5,
		MoveSpeed = 3,
		SkillList = {"DNT_AntlionAtkB"},
		Image = "DNT_antlion",
		SoundLocation = "/enemy/burrower_1/",
		ImageOffset = 2,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_BOSS,
		Burrows = true,
		Pushable = false,
		Massive = true
	}
AddPawn("DNT_AntlionBoss")

-- -- Death effect on water/chasms
-- DNT_FallAntlion1 = Pawn:new
	-- {
		-- Health = 1,
		-- Neutral = true,
		-- MoveSpeed = 0,
		-- IsPortrait = false,
		-- Image = "DNT_antlion",
		-- SoundLocation = "/enemy/burrower_1/",
		-- DefaultTeam = TEAM_NONE,
		-- ImpactMaterial = IMPACT_INSECT
	-- }
-- AddPawn("DNT_FallAntlion1")

-- DNT_FallAntlion2 = Pawn:new
	-- {
		-- Health = 1,
		-- Neutral = true,
		-- MoveSpeed = 0,
		-- IsPortrait = false,
		-- Image = "DNT_antlion",
		-- ImageOffset = 1,
		-- SoundLocation = "/enemy/burrower_1/",
		-- DefaultTeam = TEAM_NONE,
		-- ImpactMaterial = IMPACT_INSECT
	-- }
-- AddPawn("DNT_FallAntlion2")

-- DNT_FallAntlion3 = Pawn:new
	-- {
		-- Health = 1,
		-- Neutral = true,
		-- MoveSpeed = 0,
		-- IsPortrait = false,
		-- Image = "DNT_antlion",
		-- ImageOffset = 2,
		-- SoundLocation = "/enemy/burrower_1/",
		-- DefaultTeam = TEAM_NONE,
		-- ImpactMaterial = IMPACT_INSECT
	-- }
-- AddPawn("DNT_FallAntlion3")

-- -----------
-- -- Hooks --
-- -----------

-- local function HOOK_pawnPositionChanged(mission, pawn, oldpos) -- death fix for push to water/chasm/mine
	-- if pawn:GetType():find("^DNT_Antlion") ~= nil and not pawn:IsDead() then
		-- local pos = pawn:GetSpace()
		-- local n = (pawn:GetType()):sub(-1)
		-- if Board:GetTerrain(pos) == TERRAIN_HOLE then -- chasm
			-- pawn:Kill(true)
			-- Board:AddPawn("DNT_FallAntlion"..n,pos)
		-- elseif Board:GetTerrain(pos) == TERRAIN_WATER and _G[pawn:GetType()].Tier ~= TIER_BOSS then -- water
			-- pawn:Kill(true)
			-- Board:AddPawn("DNT_FallAntlion"..n,pos)
		-- elseif _G[Board:GetItem(pos)] ~= nil then -- mines
			-- local dam = _G[Board:GetItem(pos)].Damage
			-- dam.loc = pos
			-- dam.iFire = EFFECT_NONE
			-- Board:DamageSpace(dam)
			-- if dam.iFrozen == EFFECT_CREATE then
				-- pawn:SetSpace(pos)
			-- end

			-- -- local mineDamage = _G[Board:GetItem(pos)].Damage.iDamage
			-- -- dam = SpaceDamage(pos,mineDamage)
			-- -- Board:DamageSpace(dam)

			-- -- if Board:IsDeadly(dam,pawn) then
				-- -- pawn:Kill(true)
				-- -- Board:AddPawn("DNT_FallAntlion"..n,pos)
			-- -- end
		-- end
	-- end
-- end

-- local function HOOK_pawnDamaged(mission, pawn, damageTaken) -- death fix for cracked tiles
	-- if pawn:GetType():find("^DNT_Antlion") ~= nil and not pawn:IsDead() then
		-- local pos = pawn:GetSpace()
		-- local n = (pawn:GetType()):sub(-1)
		-- if Board:GetTerrain(pos) == TERRAIN_HOLE then
			-- Board:SetTerrain(pos,0)
			-- Board:SetTerrain(pos,TERRAIN_HOLE)
			-- pawn:Kill(true)
			-- Board:AddPawn("DNT_FallAntlion"..n,pos)
		-- elseif Board:GetTerrain(pos) == TERRAIN_WATER and _G[pawn:GetType()].Tier ~= TIER_BOSS then
			-- pawn:Kill(true)
			-- Board:AddPawn("DNT_FallAntlion"..n,pos)
		-- end
	-- end
-- end

-- local function EVENT_onModsLoaded()
	-- DNT_Vextra_ModApiExt:addPawnPositionChangedHook(HOOK_pawnPositionChanged)
	-- DNT_Vextra_ModApiExt:addPawnDamagedHook(HOOK_pawnDamaged)
-- end

-- modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
