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
--   Art   --
-------------

local name = "mantis" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
--modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -23, PosY = -5}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -23, PosY = -5, NumFrames = 10}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_mantis = base
a.DNT_mantise = baseEmerge
a.DNT_mantisa = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
a.DNT_mantisd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 8, Time = .15 } --Numbers copied for now
--a.DNT_namew = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png"} --Only if there's a boss




-------------
-- Weapons --
-------------

DNT_MantisSlash1 = Skill:new{
	Name = "Sharp Claws",
	Description = "Slash two diagonal tiles.",
	Class = "Enemy",
	SoundBase = "/enemy/leaper_1",
	Icon = "weapons/enemy_leaper1.png",
	PathSize = 1,
	Damage = 1,
	Range = 1,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(1,2),
		Enemy2 = Point(3,2),
		CustomPawn = "DNT_Mantis1",
	}
}

DNT_MantisSlash2 = DNT_MantisSlash1:new{
	Name = "Razor Claws",
	Damage = 2,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(1,2),
		Enemy2 = Point(3,2),
		CustomPawn = "DNT_Mantis2",
	}
}

DNT_MantisSlash3 = DNT_MantisSlash1:new{
	Name = "Vorpal Claws",
	Description = "Slash two diagonal tiles and the tiles in front of them.",
	Damage = 2,
	Range = 2,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(1,2),
		Enemy2 = Point(3,2),
		Building = Point(3,1),
		CustomPawn = "DNT_Mantis3",
	}
}

function DNT_MantisSlash1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local dirA = dir+1 > 3 and 0 or dir+1
	local dirB = dir-1 < 0 and 3 or dir-1

	ret:AddQueuedMelee(p1,SpaceDamage(p2 + DIR_VECTORS[dir]*10))

	for i = 1, self.Range do
		local pA = p1 + DIR_VECTORS[dirA] + DIR_VECTORS[dir]*i
		local pB = p1 + DIR_VECTORS[dirB] + DIR_VECTORS[dir]*i
		local damage = SpaceDamage(pA,self.Damage)
		damage.sAnimation = "SwipeClaw2"
		ret:AddQueuedDamage(damage)
		damage.loc = pB
		damage.sSound = self.SoundBase.."/attack"
		ret:AddQueuedDamage(damage)
	end

	return ret
end

-----------
-- Pawns --
-----------

DNT_Mantis1 = Pawn:new{
	Name = "Mantis",
	Health = 2,
	MoveSpeed = 3,
	Image = "DNT_mantis",
	Jumper = true,
	SkillList = { "DNT_MantisSlash1" },
	SoundLocation = "/enemy/leaper_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
}
AddPawn("DNT_Mantis1")

DNT_Mantis2 = Pawn:new{
	Name = "Alpha Mantis",
	Health = 4,
	MoveSpeed = 3,
	Image = "DNT_mantis",
	ImageOffset = 1,
	Jumper = true,
	SkillList = { "DNT_MantisSlash2" },
	SoundLocation = "/enemy/leaper_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
	Tier = TIER_ALPHA,
}
AddPawn("DNT_Mantis2")

DNT_Mantis3 = Pawn:new{
	Name = "Mantis Leader",
	Health = 6,
	MoveSpeed = 3,
	Image = "DNT_mantis",
	ImageOffset = 2,
	Jumper = true,
	SkillList = { "DNT_MantisSlash3" },
	SoundLocation = "/enemy/leaper_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
	Tier = TIER_BOSS,
	Massive = true
}
AddPawn("DNT_Mantis3")
