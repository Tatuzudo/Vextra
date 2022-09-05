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

local name = "termites" --lowercase, I could also use this else where, but let's make it more readable elsewhere

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

DNT_TermitesAtk1 = Skill:new {
	Name = "Termite Rush",
	Description = "Rush forward through all units and structures till an empty space, dealing damage, and leaving a rock on the starting space. If it can't dash, do a basic melee strike instead.",
	PathSize = 1,
	Damage = 1,
	Class = "Enemy",
	LaunchSound = "",
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,4),
		Target = Point(2,3),
		Enemy = Point(2,3),
		CustomPawn = "DNT_Termites1",
	}
}
DNT_TermitesAtk2 = DNT_TermitesAtk1:new { --Just an example
	Damage = 3,
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,4),
		Target = Point(2,3),
		Enemy = Point(2,3),
		Building = Point(2,2),
		CustomPawn = "DNT_Termites1",
	}
}

--[[
function DNT_TermitesAtk1:GetTargetArea(p1)
	local ret = PointList()
	ret:push_back(p1)
	return ret
end
--]]
function DNT_TermitesAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2-p1)
	local target = p2
	local fullyBlocked = true

	for i=1,8 do
		target = target + DIR_VECTORS[dir]
		if not Board:IsValid(target) then
			break
		elseif not Board:IsBlocked(target, PATH_PROJECTILE) then
			fullyBlocked = false
			break --target is now stored as the first unblocked tile
		end
	end

	local damage = nil
	if not Board:IsBlocked(p2, PATH_PROJECTILE) or fullyBlocked then
		damage = SpaceDamage(p2,self.Damage)
		damage.sAnimation = "explomosquito_"..dir
		damage.sSound = "/enemy/mosquito_1/attack"
		ret:AddQueuedMelee(p1, damage)
	else
		local move = PointList()
		move:push_back(p1)
		move:push_back(target)
		ret:AddQueuedCharge(move,NO_DELAY)

		damage = SpaceDamage(p1)
		damage.sPawn = "Wall"
		damage.sSound = "/enemy/digger_1/attack_queued"
		ret:AddQueuedDamage(damage)

		local curr = p2
		for i=1, 8 do
			if curr ~= target then
				ret:AddQueuedDelay(.1)
				damage = SpaceDamage(curr,self.Damage)
				damage.sAnimation = "explomosquito_"..dir
				damage.sSound = "/enemy/mosquito_1/attack"
				ret:AddQueuedDamage(damage)
			else break end
			curr = curr + DIR_VECTORS[dir]
		end
		ret:AddQueuedDelay(.1)
		damage = SpaceDamage(target)
		damage.sSound = "/enemy/beetle_1/attack_impact"
		ret:AddDamage(damage)
	end
	return ret
end

-----------
-- Pawns --
-----------

DNT_Termites1 = Pawn:new
	{
		Name = "Termites",
		Health = 3,
		MoveSpeed = 3,
		Image = "spiderling", --lowercase
		SkillList = {"DNT_TermitesAtk1"},
		SoundLocation = "/enemy/centipede_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
	}
AddPawn("DNT_Termites1")

DNT_Termites2 = Pawn:new
	{
		Name = "Alpha Termites",
		Health = 5,
		MoveSpeed = 3,
		SkillList = {"DNT_TermitesAtk2"},
		Image = "spiderling",
		SoundLocation = "/enemy/centipede_1/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_Termites2")



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
