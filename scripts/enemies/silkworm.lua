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

local name = "silkworm" --lowercase, I could also use this else where, but let's make it more readable elsewhere

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

DNT_SilkwormAtk1 = Skill:new {
	Name = "Webbing Spit", --This needs to be better
	Description = "Send a projectile attack forward while webbing behind.",
	Damage = 1,
	PathSize = 1,
	Class = "Enemy",
	--LaunchSound = "",
	Icon = "weapons/enemy_firefly1.png",
	ImpactSound = "/impact/dynamic/enemy_projectile",
	Projectile = "effects/shot_firefly",
	SoundBase = "/enemy/scorpion_soldier_1",
	TipImage = { --This is all tempalate and probably needs to change
		Building = Point(2,3),
		Enemy = Point(2,0),
		Target = Point(2,2),
		Unit = Point(2,1),
		CustomPawn = "DNT_Silkworm1",
	}
}

-- Web Something and attack > Web Mech > Shoot Something > Web Buidling, shoot void (shoot should always happen first) > nothing
function DNT_SilkwormAtk1:GetTargetScore(p1, p2)
	local ret = Skill.GetTargetScore(self, p1, p2)

	local backdir = GetDirection(p1 - p2)
	local target = p1 + DIR_VECTORS[backdir]
	local pawn = Board:GetPawn(target)
	if ret > 5 then
		if (pawn and pawn:GetTeam() == TEAM_PLAYER and not pawn:IsTempUnit()) and pawn:IsMech() or Board:IsBuilding(target) then
			ret = ret + 4 --The score for hitting something, -1. We want to web, but we'd rather attack
		end
	else
		if (pawn and pawn:GetTeam() == TEAM_PLAYER and not pawn:IsTempUnit() and pawn:IsMech()) then
			ret = ret + 6
		elseif Board:IsBuilding(target) then
			ret = ret + 2
		end
	end
	return ret
end


function DNT_SilkwormAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2-p1)
	local backdir = GetDirection(p1 - p2)

	--Firefly Attack
	local target = GetProjectileEnd(p1,p2)
	local damage = SpaceDamage(target, self.Damage)
	damage.sAnimation = "ExploFirefly1"
	ret:AddQueuedProjectile(damage,self.Projectile)

	--Web
	target = p1 + DIR_VECTORS[backdir]
	--LOG(target)
	local pawn = Board:GetPawn(target)
	if pawn or Board:IsBuilding(target) then --only play the sound if there's a pawn to web, or a building
		local sound = SpaceDamage(target)
		sound.sAnimation = ""
		ret:AddDamage(SoundEffect(target,self.SoundBase.."/attack_web"))
		ret:AddGrapple(p1,target,"hold")
	end

	return ret
end

DNT_SilkwormAtk2 = DNT_SilkwormAtk1:new { --Just an example
	Damage = 3,
	TipImage = { --This is all tempalate and probably needs to change
		Building = Point(2,3),
		Enemy = Point(2,0),
		Target = Point(2,2),
		Unit = Point(2,1),
		CustomPawn = "DNT_Silkworm2",
	}
}

-----------
-- Pawns --
-----------

DNT_Silkworm1 = Pawn:new
	{
		Name = "Silkworm",
		Health = 2,
		MoveSpeed = 3,
		Image = "scorpion", --change
		SkillList = {"DNT_SilkwormAtk1"},
		SoundLocation = "/enemy/scorpion_soldier_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
	}
AddPawn("DNT_Silkworm1")

DNT_Silkworm2 = Pawn:new
	{
		Name = "Alpha Silkworm",
		Health = 4,
		MoveSpeed = 3,
		SkillList = {"DNT_SilkwormAtk2"},
		Image = "scorpion", --change
		SoundLocation = "/enemy/scorpion_soldier_2/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_Silkworm2")



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
