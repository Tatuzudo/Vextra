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

local name = "silkworm" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -25, PosY = -5}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -25, PosY = -6, NumFrames = 9}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_silkworm = base
a.DNT_silkworme = baseEmerge
a.DNT_silkworma = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 6 }
a.DNT_silkwormd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 10, Time = .15 } --Numbers copied for now
a.DNT_silkwormw = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png", PosY = 1} --Only if there's a boss



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
	ExtraWebs = false,
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
	local oldret = ret

	local backdir = GetDirection(p1 - p2)
	local targets = {p1 + DIR_VECTORS[backdir]}
	if self.ExtraWebs then
		for i=-1, 1, 2 do
			table.insert(targets, p1 + DIR_VECTORS[(backdir+i)%4])
		end
	end

	for _, target in pairs(targets) do
		local pawn = Board:GetPawn(target)
		if (pawn and pawn:GetTeam() == TEAM_PLAYER and not pawn:IsTempUnit() and pawn:IsMech()) then
			ret = ret + 5 --The score for hitting something, it is equal between webbing and shooting now
		elseif Board:IsBuilding(target) then
			ret = ret + 2 --Just because we like to see webs, and keep it away from what it's attacking
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
	if self.ExtraWebs then
		for i=-1, 1, 2 do
			target = p1 + DIR_VECTORS[(backdir+i)%4]
			local pawn = Board:GetPawn(target)
			if pawn or Board:IsBuilding(target) then --only play the sound if there's a pawn to web, or a building
				local sound = SpaceDamage(target)
				sound.sAnimation = ""
				ret:AddDamage(SoundEffect(target,self.SoundBase.."/attack_web"))
				ret:AddGrapple(p1,target,"hold")
			end
		end
	end

	return ret
end

DNT_SilkwormAtk2 = DNT_SilkwormAtk1:new {
	Damage = 3,
	TipImage = {
		Building = Point(2,3),
		Enemy = Point(2,0),
		Target = Point(2,2),
		Unit = Point(2,1),
		CustomPawn = "DNT_Silkworm2",
	}
}

DNT_SilkwormAtkB = DNT_SilkwormAtk1:new {
	Description = "Send a projectile attack forward while webbing the other three directions.",
	Damage = 4,
	ExtraWebs = true,
	TipImage = {
		Building = Point(2,3),
		Enemy = Point(2,0),
		Enemy2 = Point(1,1),
		Target = Point(2,2),
		Unit = Point(2,1),
		CustomPawn = "DNT_SilkwormBoss",
	}
}

-----------
-- Pawns --
-----------

DNT_Silkworm1 = Pawn:new
	{
		Name = "Silkworm",
		Health = 2,
		MoveSpeed = 4,
		Image = "DNT_silkworm", --change
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
		MoveSpeed = 4,
		SkillList = {"DNT_SilkwormAtk2"},
		Image = "DNT_silkworm", --change
		SoundLocation = "/enemy/scorpion_soldier_2/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_Silkworm2")

DNT_SilkwormBoss = Pawn:new
	{
		Name = "Silkworm Leader",
		Health = 6,
		MoveSpeed = 4,
		SkillList = {"DNT_SilkwormAtkB"},
		Image = "DNT_silkworm", --change
		SoundLocation = "/enemy/scorpion_soldier_2/",
		ImageOffset = 2,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_BOSS,
		Massive = true,
	}
AddPawn("DNT_SilkwormBoss")


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
