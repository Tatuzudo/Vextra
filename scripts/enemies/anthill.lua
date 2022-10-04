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
--WOOO lots of animations and we can't automate cause of variable names, let's go copy pasta
local name, base = nil

name = "anthill" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -26, PosY = -5}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -26, PosY = -5, NumFrames = 10}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_anthill = base
a.DNT_anthille = baseEmerge
a.DNT_anthilla = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
a.DNT_anthilld = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 12, Time = .14 } --Numbers copied for now
a.DNT_anthillw = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png", PosY = 0} --Only if there's a boss



name = "workerant"

modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -26, PosY = -6, Height = 1}

a.DNT_workerant = base
a.DNT_workeranta = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
a.DNT_workerantd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 6, Time = .15 } --Numbers copied for now



name = "flyingant"

modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -26, PosY = -6, Height = 1}

a.DNT_flyingant = base
a.DNT_flyinganta = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
a.DNT_flyingantd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 6, Time = .15 } --Numbers copied for now



name = "soldierant"

modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -26, PosY = -6, Height = 1}

a.DNT_soldierant = base
a.DNT_soldieranta = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
a.DNT_soldierantd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 6, Time = .15 } --Numbers copied for now

--projectiles
modApi:appendAsset("img/effects/DNT_WorkerAnt1_upshot.png", resourcePath .. "img/effects/DNT_WorkerAnt1_upshot.png")
modApi:appendAsset("img/effects/DNT_FlyingAnt1_upshot.png", resourcePath .. "img/effects/DNT_FlyingAnt1_upshot.png")
modApi:appendAsset("img/effects/DNT_SoldierAnt1_upshot.png", resourcePath .. "img/effects/DNT_SoldierAnt1_upshot.png")

-------------
-- Weapons --
-------------

-- Anthill
DNT_AnthillAtk1 = Skill:new {
	Name = "Breeding Ground",
	Description = "Spawn soldier, flying or worker ants. Spawn stronger ants at higher health.",
	Damage = 0,
	Class = "Enemy",
	LaunchSound = "",
	ImpactSound = "/enemy/spider_boss_1/attack_egg_land",
	Spawns = {"DNT_WorkerAnt1","DNT_FlyingAnt1","DNT_SoldierAnt1","DNT_SoldierAnt1","DNT_SoldierAnt1"},
	TipImage = {
		Unit = Point(2,2),
		Building = Point(2,1),
		Target = Point(3,1),
		Second_Origin = Point(3,1),
		Second_Target = Point(2,1),
		CustomPawn = "DNT_Anthill1",
	}
}

DNT_AnthillAtk2 = DNT_AnthillAtk1:new {
	Spawns = {"DNT_WorkerAnt1","DNT_WorkerAnt1","DNT_FlyingAnt1","DNT_FlyingAnt1","DNT_SoldierAnt1"},
	TipImage = {
		Unit = Point(2,2),
		Building = Point(2,1),
		Target = Point(3,1),
		Second_Origin = Point(3,1),
		Second_Target = Point(2,1),
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

	local spawn = math.min(Pawn:GetHealth(), 5)

	local damage = SpaceDamage(p2)
	damage.sPawn = self.Spawns[spawn]

	ret:AddArtillery(damage,"effects/"..self.Spawns[spawn].."_upshot.png",NO_DELAY)

	if IsTipImage() then
		ret:AddDelay(4)
	end

	return ret
end

function DNT_AnthillAtk1:GetTargetScore(p1, p2)
    local ret = 1
	if Board:IsBlocked(p2,PATH_GROUND) or Board:IsPod(p2) then
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

-- Ants
DNT_WorkerAntAtk = Skill:new {
	Name = "Cutting Bite",
	Description = "Prepares to bite an adjacent tile",
	Damage = 1,
	Class = "Enemy",
	LaunchSound = "",
	PathSize = 1,
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy = Point(2,1),
		CustomPawn = "DNT_WorkerAnt1",
	}
}

DNT_FlyingAntAtk = DNT_WorkerAntAtk:new {
	Name = "Sharp Sting",
	Damage = 1,
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy = Point(2,1),
		CustomPawn = "DNT_FlyingAnt1",
	}
}

DNT_SoldierAntAtk = DNT_WorkerAntAtk:new {
	Name = "Slashing Bite",
	Damage = 2,
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy = Point(2,1),
		CustomPawn = "DNT_SoldierAnt1",
	}
}

function DNT_WorkerAntAtk:GetSkillEffect(p1,p2)
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
		Health = 3,
		MoveSpeed = 2,
		Burrows = true,
		Pushable = false,
		Image = "DNT_anthill", --lowercase
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
		Image = "DNT_anthill",
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
		Health = 1,
		MoveSpeed = 3,
		SpawnLimit = false,
		Image = "DNT_workerant", --lowercase
		SkillList = {"DNT_WorkerAntAtk"},
		SoundLocation = "/enemy/spiderling_1//",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Minor = true,
	}
AddPawn("DNT_WorkerAnt1")

-- DNT_WorkerAnt2 = Pawn:new
	-- {
		-- Name = "Alpha Worker Ant",
		-- Health = 1,
		-- MoveSpeed = 3,
		-- SkillList = {"DNT_AntAtk1"},
		-- Image = "spiderling",
		-- SoundLocation = "/enemy/spiderling_2/",
		-- ImageOffset = 1,
		-- DefaultTeam = TEAM_ENEMY,
		-- ImpactMaterial = IMPACT_INSECT,
		-- Tier = TIER_ALPHA,
	-- }
-- AddPawn("DNT_WorkerAnt2")

-- FlyingAnt
DNT_FlyingAnt1 = Pawn:new
	{
		Name = "Flying Ant",
		Health = 1,
		MoveSpeed = 3,
		Flying = true,
		SpawnLimit = false,
		Image = "DNT_flyingant", --lowercase
		SkillList = {"DNT_FlyingAntAtk"},
		SoundLocation = "/enemy/spiderling_1//",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Minor = true,
	}
AddPawn("DNT_FlyingAnt1")

-- DNT_FlyingAnt2 = Pawn:new
	-- {
		-- Name = "Alpha Flying Ant",
		-- Health = 1,
		-- MoveSpeed = 3,
		-- Flying = true,
		-- SkillList = {"DNT_AntAtk1"},
		-- Image = "hornet",
		-- SoundLocation = "/enemy/spiderling_2/",
		-- ImageOffset = 1,
		-- DefaultTeam = TEAM_ENEMY,
		-- ImpactMaterial = IMPACT_INSECT,
		-- Tier = TIER_ALPHA,
	-- }
-- AddPawn("DNT_FlyingAnt2")

-- SoldierAnt
DNT_SoldierAnt1 = Pawn:new
	{
		Name = "Soldier Ant",
		Health = 2,
		MoveSpeed = 3,
		SpawnLimit = false,
		Image = "DNT_soldierant",
		SkillList = {"DNT_SoldierAntAtk"},
		SoundLocation = "/enemy/spiderling_1//",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Minor = true,
	}
AddPawn("DNT_SoldierAnt1")

-- DNT_SoldierAnt2 = Pawn:new
	-- {
		-- Name = "Alpha Soldier Ant",
		-- Health = 2,
		-- MoveSpeed = 3,
		-- SkillList = {"DNT_AntAtk2"},
		-- Image = "leaper",
		-- SoundLocation = "/enemy/spiderling_2/",
		-- ImageOffset = 1,
		-- DefaultTeam = TEAM_ENEMY,
		-- ImpactMaterial = IMPACT_INSECT,
		-- Tier = TIER_ALPHA,
	-- }
-- AddPawn("DNT_SoldierAnt2")

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
