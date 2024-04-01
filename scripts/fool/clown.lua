local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
--local previewer = require(scriptPath.."weaponPreview/api")

local writepath = "img/units/aliens/"
local readpath = resourcePath .. "img/units/aliens/fool/"
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

local name = "clownbug" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
--modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -25, PosY = -4, Height = 1}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -25, PosY = -4, NumFrames = 9, Height = 1}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_clownbug = base
a.DNT_clownbuge = baseEmerge
a.DNT_clownbuga = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 12, Time = .15}
a.DNT_clownbugd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 7, Time = .14 } --Numbers copied for now
--a.DNT_namew = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png"} --Only if there's a boss


modApi:appendAsset("img/effects/DNT_anvil.png",resourcePath.."img/effects/fool/DNT_anvil.png")
	Location["effects/DNT_anvil.png"] = Point(-27,2)

--modApi:appendAsset("img/icons/icon_clowned.png",resourcePath.."img/icons/fool/icon_clowned.png")
--	Location["effects/icon_clowned.png"] = Point(-27,2)

-------------
-- Weapons --
-------------

DNT_ClownAtk1 = Laser_Base:new {
	Name = "Devastation",
	Description = "Be Scared",
	Damage = DAMAGE_DEATH,
  MinDamage = DAMAGE_DEATH,
	Class = "Enemy",
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,2),
		Target = Point(2,2),
		Enemy = Point(2,3),
		Enemy2 = Point(2,1),
		Enemy3 = Point(3,2),
		Enemy4 = Point(1,2),
		Building = Point(2,4),
		Building2 = Point(2,0),
		Building3 = Point(0,2),
		Building4 = Point(4,2),
		CustomPawn = "DNT_Clown1",
		Length = 6,
	},
}


function DNT_ClownAtk1:GetTargetArea(p1)
	local ret = PointList()
	ret:push_back(p1)
	return ret
end

function DNT_ClownAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
  for dir=DIR_START, DIR_END do
    local target = p1 + DIR_VECTORS[dir]
    self:AddQueuedLaser(ret, target, dir)
  end
	return ret
end

-----------
-- Pawns --
-----------

DNT_Clown1 = Pawn:new
	{
		Name = "Clown Beetle",
		Health = 10,
		MoveSpeed = 6,
		Image = "DNT_clownbug", --lowercase
		SkillList = {"DNT_ClownAtk1"},
		SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Minor = true,
	}
AddPawn("DNT_Clown1")

--Spawn code in new_vek_spawns.lua (replacement of Vextra Vek and spawns at start of mission)

local HOOK_skillBuild = function(mission, pawn, weaponId, p1, p2, skillEffect)
  local targetPawn = Board:GetPawn(p2)
  if targetPawn and targetPawn:GetType() == "DNT_Clown1" and pawn:GetTeam() == TEAM_PLAYER and weaponId ~= "DNT_ClownAtk1" then
		local effect = SkillEffect()
		local damage = SpaceDamage(p2)
		effect:AddDropper(damage, "effects/DNT_anvil.png")
		effect:AddDelay(.8)
	  effect:AddSound("/impact/dynamic/rock")
		effect:AddScript(string.format("Board:GetPawn(%s):Kill(false)",targetPawn:GetId()))
		Board:AddEffect(effect)
  end
end




local function EVENT_onModsLoaded()
  DNT_Vextra_ModApiExt:addSkillBuildHook(HOOK_skillBuild)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
