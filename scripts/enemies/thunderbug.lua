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

local name = "thunderbug" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."e.png", readpath.."DNT_"..name.."e.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
--modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -24, PosY = -10}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."e.png", PosX = -24, PosY = -8, NumFrames = 10}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_thunderbug = base
a.DNT_thunderbuge = baseEmerge
a.DNT_thunderbuga = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
a.DNT_thunderbugd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 8, Time = .15 } --Numbers copied for now
--a.DNT_namew = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png"} --Only if there's a boss


-------------
-- Weapons --
-------------

DNT_VekLightning1 = Skill:new{
	Name = "Lightning Bolt",
	Description = "Damage the target and adjacent units and buildings.",
	Class = "Enemy",
	Icon = "weapons/prime_lightning.png",
	PathSize = 1,
	Damage = 1,
	MaxSpread = 2,
	DistRed = 0,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(2,2),
		Building = Point(2,1),
		Enemy2 = Point(3,1),
		Building2 = Point(1,2),
		CustomPawn = "DNT_Thunderbug1",
	}
}

DNT_VekLightning2 = DNT_VekLightning1:new{
	Damage = 2,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(2,2),
		Building = Point(2,1),
		Enemy2 = Point(3,1),
		Building2 = Point(1,2),
		CustomPawn = "DNT_Thunderbug2",
	}
}

DNT_VekLightning3 = DNT_VekLightning1:new{
	Damage = 3,
	MaxSpread = 3,
	DistRed = 1,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(2,2),
		Building = Point(2,1),
		Enemy2 = Point(3,1),
		Building2 = Point(1,2),
		CustomPawn = "DNT_Thunderbug2",
	}
}

function DNT_VekLightning1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local hash = function(point) return point.x + point.y*10 end
	local explored = {[hash(p1)] = true}
	local spread = self.MaxSpread
	local todo = {{p2,spread}}
	local origin = { [hash(p2)] = p1 }

	while #todo ~= 0 do
		local current = todo[1][1]
		spread = todo[1][2]
		table.remove(todo, 1)

		if not explored[hash(current)] then
			explored[hash(current)] = true

			local direction = GetDirection(current - origin[hash(current)])
			local damage = SpaceDamage(current,self.Damage - (self.MaxSpread + spread) * self.DistRed)
			damage.sAnimation = "Lightning_Attack_"..direction
			ret:AddQueuedDamage(damage)
			ret:AddQueuedAnimation(current,"Lightning_Hit")
			ret:AddQueuedSound("/weapons/electric_whip")

			if Board:IsPawnSpace(current) or Board:IsBuilding(current) then
				for i = DIR_START, DIR_END do
					local neighbor = current + DIR_VECTORS[i]
					if not explored[hash(neighbor)] and spread > 1 then
						if Board:IsPawnSpace(neighbor) or Board:IsBuilding(neighbor) then
							todo[#todo + 1] = {neighbor,spread-1}
							origin[hash(neighbor)] = current
						end
					end
				end
			end
		end
	end

	return ret
end


function DNT_VekLightning1:GetTargetScore(p1,p2)
	local ret = Skill.GetTargetScore(self, p1, p2)

	-- don't zap your friends.
	local zapPawn = Board:GetPawn(p2)
	if zapPawn then
		if zapPawn:GetTeam() == TEAM_ENEMY then
			ret = 0
		end
	end

    return ret
end

-----------
-- Pawns --
-----------

DNT_Thunderbug1 = Pawn:new{
	Name = "Thunderbug",
	Health = 2,
	MoveSpeed = 3,
	Image = "DNT_thunderbug",
	SkillList = { "DNT_VekLightning1" },
	SoundLocation = "/enemy/beetle_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_INSECT,
}
AddPawn("DNT_Thunderbug1")

DNT_Thunderbug2 = Pawn:new{
	Name = "Alpha Thunderbug",
	Health = 4,
	MoveSpeed = 3,
	Image = "DNT_thunderbug",
	ImageOffset = 1,
	SkillList = { "DNT_VekLightning2" },
	SoundLocation = "/enemy/beetle_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_INSECT,
	Tier = TIER_ALPHA,
}
AddPawn("DNT_Thunderbug2")

DNT_Thunderbug3 = Pawn:new{
	Name = "Thunderbug Leader",
	Health = 6,
	MoveSpeed = 3,
	Image = "DNT_thunderbug",
	ImageOffset = 2,
	SkillList = { "DNT_VekLightning3" },
	SoundLocation = "/enemy/beetle_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_INSECT,
	Tier = TIER_BOSS,
}
AddPawn("DNT_Thunderbug3")