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



name = "fant"

modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -26, PosY = -6, Height = 1}

a.DNT_fant = base
a.DNT_fanta = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
a.DNT_fantd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 6, Time = .15 } --Numbers copied for now



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
modApi:appendAsset("img/effects/DNT_FAnt1_upshot.png", resourcePath .. "img/effects/DNT_FAnt1_upshot.png")
modApi:appendAsset("img/effects/DNT_SoldierAnt1_upshot.png", resourcePath .. "img/effects/DNT_SoldierAnt1_upshot.png")

-----------------
--  Portraits  --
-----------------

-- Anthill
local ptname = "Anthill"
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."1.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."1.png")
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."2.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."2.png")
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."Boss.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."Boss.png")

-- Ants
modApi:appendAsset("img/portraits/enemy/DNT_WorkerAnt1.png",resourcePath.."img/portraits/enemy/DNT_WorkerAnt1.png")
modApi:appendAsset("img/portraits/enemy/DNT_FAnt1.png",resourcePath.."img/portraits/enemy/DNT_FAnt1.png")
modApi:appendAsset("img/portraits/enemy/DNT_SoldierAnt1.png",resourcePath.."img/portraits/enemy/DNT_SoldierAnt1.png")

-------------
-- Weapons --
-------------

-- Anthill
DNT_AnthillAtk1 = Skill:new {
	Name = "Breeding Ground",
	Description = "Spawn soldier, flying or worker ants. Spawn stronger ants at higher health.",
	Damage = 0,
	Class = "Enemy",
	LaunchSound = "/enemy/shaman_1/attack_launch",
	ImpactSound = "/enemy/spider_boss_1/attack_egg_land",
	Spawns = {"DNT_WorkerAnt1","DNT_FAnt1","DNT_SoldierAnt1"},
	DoubleSpawn = false,
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
	Spawns = {"DNT_WorkerAnt1","DNT_WorkerAnt1","DNT_FAnt1","DNT_FAnt1","DNT_SoldierAnt1"},
	TipImage = {
		Unit = Point(2,2),
		Building = Point(2,1),
		Target = Point(3,1),
		Second_Origin = Point(3,1),
		Second_Target = Point(2,1),
		CustomPawn = "DNT_Anthill2",
	}
}

DNT_AnthillAtkBoss = DNT_AnthillAtk1:new {
	Name = "Ant Rain",
	Description = "Spawn two soldier, flying or worker ants. Spawn stronger ants at higher health.",
	Spawns = {"DNT_WorkerAnt1","DNT_FAnt1","DNT_FAnt1","DNT_SoldierAnt1"},
	DoubleSpawn = true,
	TipImage = {
		Unit = Point(2,2),
		Building = Point(2,1),
		Target = Point(3,1),
		Second_Origin = Point(3,1),
		Second_Target = Point(2,1),
		CustomPawn = "DNT_AnthillBoss",
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
	local mission = GetCurrentMission()

	local spawn = math.min(Pawn:GetHealth(), #self.Spawns)

	local damage = SpaceDamage(p2)
	damage.sPawn = self.Spawns[spawn]

	ret:AddArtillery(damage,"effects/"..self.Spawns[spawn].."_upshot.png")

	if self.DoubleSpawn then
		ret:AddDelay(0.1)
		local spawn2 = math.max(spawn-1,1)
		ret:AddScript(string.format(
			"GetCurrentMission():FlyingSpawns(%s,1,%q,{ image = %q, launch = %q, impact = %q})",--launch = \"\", impact = \"\"})",
			p1:GetString(),
			self.Spawns[spawn2],
			"effects/"..self.Spawns[spawn2].."_upshot.png",
			self.LaunchSound,
			self.ImpactSound
		))
	end


	if IsTipImage() then
		ret:AddDelay(3)
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
	StrikeAnim = "SwipeClaw1",
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

DNT_SoldierAntAtk = DNT_WorkerAntAtk:new {
	Name = "Slashing Bite",
	Damage = 2,
	StrikeAnim = "SwipeClaw2",
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
	damage.sSound = "/enemy/leaper_1/attack"
	damage.sAnimation = self.StrikeAnim
	ret:AddQueuedDamage(damage)
	return ret
end

DNT_FAntAtk = DNT_WorkerAntAtk:new {
	Name = "Sharp Sting",
	Description = "Prepares to sting an adjacent tile",
	Damage = 1,
	StrikeAnim = "explomosquito_",
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy = Point(2,1),
		CustomPawn = "DNT_FAnt1",
	}
}

function DNT_FAntAtk:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local damage = SpaceDamage(p2,self.Damage)
	damage.sSound = "/enemy/hornet_1/attack"
	damage.sAnimation = self.StrikeAnim ..dir
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
		Icon = "portraits/enemy/DNT_Anthill1",
		Health = 3,
		MoveSpeed = 2,
		Burrows = true,
		Pushable = false,
		VoidShockImmune = true,
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
		Icon = "portraits/enemy/DNT_Anthill2",
		Health = 5,
		MoveSpeed = 2,
		Burrows = true,
		Pushable = false,
		VoidShockImmune = true,
		SkillList = {"DNT_AnthillAtk2"},
		Image = "DNT_anthill",
		SoundLocation = "/enemy/beetle_1/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_Anthill2")

DNT_AnthillBoss = Pawn:new
	{
		Name = "Anthill Leader",
		Icon = "portraits/enemy/DNT_AnthillBoss",
		Health = 4,
		MoveSpeed = 2,
		Burrows = true,
		Pushable = false,
		VoidShockImmune = true,
		SkillList = {"DNT_AnthillAtkBoss"},
		Image = "DNT_anthill",
		SoundLocation = "/enemy/beetle_1/",
		ImageOffset = 2,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_Boss,
		Massive = true
	}
AddPawn("DNT_AnthillBoss")

-- WorkerAnt
DNT_WorkerAnt1 = Pawn:new
	{
		Name = "Worker Ant",
		Health = 1,
		MoveSpeed = 3,
		SpawnLimit = false,
		Image = "DNT_workerant", --lowercase
		SkillList = {"DNT_WorkerAntAtk"},
		SoundLocation = "/enemy/spiderling_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Minor = true,
	}
AddPawn("DNT_WorkerAnt1")

-- FAnt
DNT_FAnt1 = Pawn:new
	{
		Name = "Flying Ant",
		Health = 1,
		MoveSpeed = 3,
		Flying = true,
		SpawnLimit = false,
		Image = "DNT_fant", --lowercase
		SkillList = {"DNT_FAntAtk"},
		SoundLocation = "/enemy/hornet_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Minor = true,
	}
AddPawn("DNT_FAnt1")

-- SoldierAnt
DNT_SoldierAnt1 = Pawn:new
	{
		Name = "Soldier Ant",
		Health = 2,
		MoveSpeed = 3,
		SpawnLimit = false,
		Image = "DNT_soldierant",
		SkillList = {"DNT_SoldierAntAtk"},
		SoundLocation = "/enemy/spiderling_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Minor = true,
	}
AddPawn("DNT_SoldierAnt1")

-----------
-- Hooks --
-----------
--UNCOMMENT fi you need it
--[[
local this = {}

function this:load(DNT_Vextra_ModApiExt)
	local options = mod_loader.currentModContent[mod.id].options
	DNT_Vextra_ModApiExt:addSkillBuildHook(SkillBuild) --EXAMPLE

end

return this
--]]
