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

local name = "antlion" --lowercase, I could also use this else where, but let's make it more readable elsewhere

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

DNT_AntlionAtk1 = Skill:new {
	Name = "Shattering Mandibles", --This needs to be better
	Description = "Crack the targets tile, preparing to strike it.",
	Damage = 1,
	PathSize = 1,
	Class = "Enemy",
	LaunchSound = "",
	Crack = 1,
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
	local damage = SpaceDamage(p2,0)
	damage.iCrack = self.Crack
	ret:AddDamage(damage)
	ret:AddBurst(p2,"Emitter_Crack_Start2",DIR_NONE)
	ret:AddBounce(p2,2)


	damage = SpaceDamage(p2,self.Damage)
	damage.sSound = "/enemy/burrower_1/attack"
	damage.sAnimation = "SwipeClaw2"
	ret:AddQueuedDamage(damage)

	return ret
end

DNT_AntlionAtk2 = DNT_AntlionAtk1:new { --Just an example
	Damage = 3,
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy = Point(2,2),
		CustomPawn = "DNT_Antlion2",
	}
}


-----------
-- Pawns --
-----------

DNT_Antlion1 = Pawn:new
	{
		Name = "Antlion",
		Health = 2,
		MoveSpeed = 4,
		Image = "burrower", --lowercase
		SkillList = {"DNT_AntlionAtk1"},
		SoundLocation = "/enemy/burrower_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Burrows = true,
	}
AddPawn("DNT_Antlion1")

DNT_Antlion2 = Pawn:new
	{
		Name = "Alpha Antlion",
		Health = 4,
		MoveSpeed = 4,
		SkillList = {"DNT_AntlionAtk2"},
		Image = "burrower",
		SoundLocation = "/enemy/burrower_1/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
		Burrows = true,
	}
AddPawn("DNT_Antlion2")



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
