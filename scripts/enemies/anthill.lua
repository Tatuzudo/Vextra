local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
local previewer = require(scriptPath.."weaponPreview/api")

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

local name = "name" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
--modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
--modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
--modApi:appendAsset(writepath.."DNT_"..name.."e.png", readpath.."DNT_"..name.."e.png")
--modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
--modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

--local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -23, PosY = -5}
--local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."e.png", PosX = 0, PosY = 0}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
--a.DNT_name = base
--a.DNT_namee = baseEmerge
--a.DNT_ladybuga = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 8 }
--a.DNT_named = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 8, Time = .04 } --Numbers copied for now
--a.DNT_namew = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png"} --Only if there's a boss



-------------
-- Weapons --
-------------

-- Anthill
DNT_AnthillAtk1 = Skill:new {
	Name = "Ant Spawn",
	Damage = 0,
	Class = "Enemy",
	LaunchSound = "",
	Projectile = "effects/shotup_crab1.png",
	Spawns = {"DNT_WorkerAnt1","DNT_FlyingAnt1","DNT_SoldierAnt1"},
	-- PathSize = 1,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,3),
		CustomPawn = "DNT_Anthill1",
	}
}

DNT_AnthillAtk2 = DNT_AnthillAtk1:new {
	-- Spawns = {"DNT_SoldierAnt2","DNT_FlyingAnt2","DNT_WorkerAnt2"},
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		CustomPawn = "DNT_Anthill2",
	}
}

function DNT_AnthillAtk1:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		local curr = DIR_VECTORS[i] + point
		if Board:IsValid(curr) then
			ret:push_back(curr)
		end

		local dir = GetDirection(curr - point)
		local dir2 = dir+1 > 3 and 0 or dir+1
		local curr2 = curr + DIR_VECTORS[dir2]
		if Board:IsValid(curr2) then
			ret:push_back(curr2)
		end
	end

	return ret
	-- return general_SquareTarget(point, 0)
end

function DNT_AnthillAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local spawn = math.min(Pawn:GetHealth(), 3)

	local damage = SpaceDamage(p2)
	damage.sPawn = self.Spawns[spawn]

	ret:AddArtillery(damage,self.Projectile,NO_DELAY)

	return ret
end

function DNT_AnthillAtk1:GetTargetScore(p1, p2)
    local ret = 1
	if Board:IsBlocked(p2,PATH_GROUND) or Board:IsPod(p2) then -- Board:GetTerrain(p2) == TERRAIN_WATER or Board:GetTerrain(p2) == TERRAIN_HOLE or
		ret = 0
	else
		local bonus = 0
		for i = DIR_START, DIR_END do
			local point = DIR_VECTORS[i] + p2
			local enemy = Board:GetPawn(point)
			if enemy then enemy = enemy:GetTeam() == TEAM_PLAYER end
			if Board:IsBuilding(point) or enemy then
				bonus = 1
			end
		end
		ret = ret + bonus
	end
	return ret
end

-- Soldier Ant
DNT_AntAtk1 = Skill:new {
	Name = "Ant Spawn",
	Damage = 1,
	Class = "Enemy",
	LaunchSound = "",
	PathSize = 1,
	Spawns = {},
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy = Point(2,2),
		-- CustomPawn = "DNT_SoldierAnt1",
	}
}

DNT_AntAtk2 = DNT_AntAtk1:new {
	Damage = 2,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy = Point(2,2),
		-- CustomPawn = "DNT_SoldierAnt2",
	}
}

function DNT_AntAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local damage = SpaceDamage(p2,self.Damage)
	damage.sAnimation = "explomosquito_"..dir
	ret:AddQueuedDamage(damage)
	return ret
end

-----------
-- Pawns --
-----------

-- Anthill
DNT_Anthill1 = Pawn:new
	{
		Name = "Anthill",
		Description = "Creates ants to attack nearby tiles. Stronger ants are created when the anthill is hurt.",
		Health = 3,
		MoveSpeed = 2,
		Burrows = true,
		Pushable = false,
		Image = "shaman", --lowercase
		SkillList = {"DNT_AnthillAtk1"},
		SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
	}
AddPawn("DNT_Anthill1")

DNT_Anthill2 = Pawn:new
	{
		Name = "Alpha Anthill",
		Health = 5,
		MoveSpeed = 2,
		Burrows = true,
		Pushable = false,
		SkillList = {"DNT_AnthillAtk2"},
		Image = "shaman",
		SoundLocation = "/enemy/beetle_1/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_Anthill2")

-- WorkerAnt
DNT_WorkerAnt1 = Pawn:new
	{
		Name = "Worker Ant",
		Description = "Weak ant",
		Health = 1,
		MoveSpeed = 3,
		SpawnLimit = false,
		Image = "spiderling", --lowercase
		SkillList = {"DNT_AntAtk1"},
		SoundLocation = "/enemy/spiderling_1//",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
	}
AddPawn("DNT_WorkerAnt1")

DNT_WorkerAnt2 = Pawn:new
	{
		Name = "Alpha Worker Ant",
		Health = 1,
		MoveSpeed = 3,
		SkillList = {"DNT_AntAtk1"},
		Image = "spiderling",
		SoundLocation = "/enemy/spiderling_2/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_WorkerAnt2")

-- FlyingAnt
DNT_FlyingAnt1 = Pawn:new
	{
		Name = "Flying Ant",
		Description = "Weak ant that can fly",
		Health = 1,
		MoveSpeed = 3,
		Flying = true,
		SpawnLimit = false,
		Image = "hornet", --lowercase
		SkillList = {"DNT_AntAtk1"},
		SoundLocation = "/enemy/spiderling_1//",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
	}
AddPawn("DNT_FlyingAnt1")

DNT_FlyingAnt2 = Pawn:new
	{
		Name = "Alpha Flying Ant",
		Health = 1,
		MoveSpeed = 3,
		Flying = true,
		SkillList = {"DNT_AntAtk1"},
		Image = "hornet",
		SoundLocation = "/enemy/spiderling_2/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_FlyingAnt2")

-- SoldierAnt
DNT_SoldierAnt1 = Pawn:new
	{
		Name = "Soldier Ant",
		Description = "Strong ant",
		Health = 2,
		MoveSpeed = 3,
		SpawnLimit = false,
		Image = "leaper",
		SkillList = {"DNT_AntAtk2"},
		SoundLocation = "/enemy/spiderling_1//",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
	}
AddPawn("DNT_SoldierAnt1")

DNT_SoldierAnt2 = Pawn:new
	{
		Name = "Alpha Soldier Ant",
		Health = 2,
		MoveSpeed = 3,
		SkillList = {"DNT_AntAtk2"},
		Image = "leaper",
		SoundLocation = "/enemy/spiderling_2/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_SoldierAnt2")

-----------
-- Hooks --
-----------
--UNCOMMENT fi you need it
--[[
local this = {}

function this:load(NAH_MechTaunt_ModApiExt)
	local options = mod_loader.currentModContent[mod.id].options
	NAH_MechTaunt_ModApiExt:addSkillBuildHook(SkillBuild) --EXAMPLE

end

return this
--]]
