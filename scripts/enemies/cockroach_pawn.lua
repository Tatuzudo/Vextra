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

local name = "cockroach" --lowercase, I could also use this else where, but let's make it more readable elsewhere

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

DNT_CockroachAtk1 = Skill:new {
	Name = "Cockroach Atk",
	Description = "Description",
	Damage = 1,
	Class = "Enemy",
	PathSize = 1,
	Projectile = "effects/shot_firefly",
	LaunchSound = "",
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy = Point(2,1),
		CustomPawn = "DNT_Cockroach1",
	}
}
DNT_CockroachAtk2 = DNT_CockroachAtk1:new { --Just an example
	Damage = 3,
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy = Point(2,1),
		CustomPawn = "DNT_Cockroach1",
	}
}



function DNT_CockroachAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local target = GetProjectileEnd(p1,p2)
	local damage = SpaceDamage(target, self.Damage)
	ret:AddQueuedProjectile(damage,self.Projectile)

	return ret
end

-----------
-- Pawns --
-----------

DNT_Cockroach1 = Pawn:new
	{
		Name = "Cockroach",
		Health = 1,
		MoveSpeed = 3,
		Ranged = 1,
		Image = "shaman", --lowercase
		SkillList = {"DNT_CockroachAtk1"},
		SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		DroppedCorpse = "DNT_CockroachCorpse1",
	}
AddPawn("DNT_Cockroach1")

DNT_Cockroach2 = Pawn:new
	{
		Name = "Alpha Cockroach",
		Health = 3,
		MoveSpeed = 3,
		Ranged = 1,
		SkillList = {"DNT_CockroachAtk2"},
		Image = "shaman",
		SoundLocation = "/enemy/beetle_1/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
		DroppedCorpse = "DNT_CockroachCorpse2",
	}
AddPawn("DNT_Cockroach2")

DNT_CockroachCorpse1 = Pawn:new
	{
		Name = "Cockroach Corpse",
		Health = 1,
		MoveSpeed = 0,
		Image = "totem", --lowercase
		--SkillList = {"DNT_CockroachAtk1"},
		--SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Minor = true,
		Being = "DNT_Cockroach1",
	}
AddPawn("DNT_CockroachCorpse1")


DNT_CockroachCorpse2 = Pawn:new
	{
		Name = "Alpha Cockroach Corpse",
		Health = 1,
		MoveSpeed = 0,
		--SkillList = {"DNT_CockroachAtk2"},
		Image = "totem",
		--SoundLocation = "/enemy/beetle_1/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
		Minor = true,
		Being = "DNT_Cockroach2",
	}
AddPawn("DNT_CockroachCorpse2")

function DNT_Cockroach1:GetDeathEffect(p1)
	local ret = SkillEffect()
	local corpse = self.DroppedCorpse
	local damage = SpaceDamage(p1,0)
	damage.sPawn = corpse
	ret:AddDamage(damage)
	ret:AddDelay(9*.15) --1.35
	return ret
end

function DNT_Cockroach2:GetDeathEffect(p1)
	local ret = SkillEffect()
	local corpse = self.DroppedCorpse
	local damage = SpaceDamage(p1,0)
	damage.sPawn = corpse
	ret:AddDamage(damage)
	ret:AddDelay(9*.15) --1.35
	return ret
end
-----------
-- Hooks --
-----------
local function IsVek(pawn, vek)
	return pawn and (pawn:GetType() == vek.."1" or pawn:GetType() == vek.."2" or pawn:GetType() == vek.."Boss")
end

local function PawnKilled(mission, pawn)
	if IsVek(pawn, "DNT_Cockroach") then
		LOG("DEATH HOOK")

	end
end

local function NextTurn(mission)
	if Game:GetTeamTurn() == TEAM_ENEMY then
		local board_size = Board:GetSize()
		for i = 0, board_size.x - 1 do
			for j = 0, board_size.y - 1 do
				local point = Point(i,j)
				local pawn = Board:GetPawn(point)
				if IsVek(pawn, "DNT_CockroachCorpse") then
					local being = _G[pawn:GetType()].Being
					local damage = SpaceDamage(pawn:GetSpace(),1)
					damage.sPawn = being
					Board:DamageSpace(damage)
				end
			end
		end
	end
end

local this = {}

function this:load(NAH_Vextra_ModApiExt)
	local options = mod_loader.currentModContent[mod.id].options
	--NAH_Vextra_ModApiExt:addPawnKilledHook(PawnKilled) --EXAMPLE
	modApi:addNextTurnHook(NextTurn)
end

return this
