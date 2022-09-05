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
--a.DNT_namea = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 8 }
--a.DNT_named = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 8, Time = .04 } --Numbers copied for now
--a.DNT_namew = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png"} --Only if there's a boss



-------------
-- Weapons --
-------------

DNT_NameAtk1 = Skill:new {
	Name = "Name",
	Description = "Description",
	Damage = 0,
	Class = "Enemy",
	LaunchSound = "",
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,4),
		Target = Point(2,3),
		Enemy = Point(2,3),
		CustomPawn = "DNT_Name1",
	}
}
DNT_NameAtk2 = DNT_NameAtk1:new { --Just an example
	Damage = 1,
}

function DNT_NameAtk1:GetTargetArea(p1)
	local ret = PointList()
	ret:push_back(p1)
	return ret
end

function DNT_NameAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()

	return ret
end

-----------
-- Pawns --
-----------

DNT_Name1 = Pawn:new
	{
		Name = "Name",
		Health = 2,
		MoveSpeed = 3,
		Image = "DNT_name" --lowercase
		SkillList = {"DNT_NameAtk1"},
		SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
	}
AddPawn("DNT_Name1")

DNT_Name2 = Pawn:new
	{
		Name = "Alpha Name",
		Health = 4,
		MoveSpeed = 3,
		SkillList = {"DNT_NameAtk2"},
		Image = "DNT_name",
		SoundLocation = "/enemy/beetle_1/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_Name2")



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
