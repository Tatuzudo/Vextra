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

local name = "thunderbug" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -24, PosY = -10}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -24, PosY = -8, NumFrames = 10}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_thunderbug = base
a.DNT_thunderbuge = baseEmerge
a.DNT_thunderbuga = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
a.DNT_thunderbugd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 8, Time = .15 } --Numbers copied for now
a.DNT_thunderbugw = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png", PosY = -3} --Only if there's a boss

-----------------
--  Portraits  --
-----------------

local ptname = "Thunderbug"
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."1.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."1.png")
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."2.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."2.png")
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."Boss.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."Boss.png")

-------------
-- Weapons --
-------------

DNT_ThunderbugAtk1 = Skill:new{
	Name = "Static Prongs",
	Description = "Damage the target and adjacent units and buildings.",
	Class = "Enemy",
	Icon = "weapons/prime_lightning.png",
	StrikeAnim = "Lightning_Attack_",
	PathSize = 1,
	Damage = 1,
	MaxSpread = 2,
	DistRed = 0, -- increase to reduce damage with distance
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

DNT_ThunderbugAtk2 = DNT_ThunderbugAtk1:new{
	Name = "Galvanic Prongs",
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

DNT_ThunderbugAtkB = DNT_ThunderbugAtk1:new{
	Name = "Lightning Prongs",
	Description = "Damage the target and chained units and buildings. Deals less damage with distance.",
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

function DNT_ThunderbugAtk1:GetSkillEffect(p1, p2)
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
			local damage = SpaceDamage(current,self.Damage - (self.MaxSpread - spread) * self.DistRed)
			damage.sAnimation = self.StrikeAnim..direction
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


function DNT_ThunderbugAtk1:GetTargetScore(p1,p2)
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
	Health = 3,
	MoveSpeed = 4,
	Image = "DNT_thunderbug",
	SkillList = { "DNT_ThunderbugAtk1" },
	SoundLocation = "/enemy/beetle_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_INSECT,
}
AddPawn("DNT_Thunderbug1")

DNT_Thunderbug2 = Pawn:new{
	Name = "Alpha Thunderbug",
	Health = 5,
	MoveSpeed = 4,
	Image = "DNT_thunderbug",
	ImageOffset = 1,
	SkillList = { "DNT_ThunderbugAtk2" },
	SoundLocation = "/enemy/beetle_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_INSECT,
	Tier = TIER_ALPHA,
}
AddPawn("DNT_Thunderbug2")

DNT_ThunderbugBoss = Pawn:new{
	Name = "Thunderbug Leader",
	Health = 6,
	MoveSpeed = 4,
	Image = "DNT_thunderbug",
	ImageOffset = 2,
	SkillList = { "DNT_ThunderbugAtkB" },
	SoundLocation = "/enemy/beetle_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_INSECT,
	Tier = TIER_BOSS,
	Massive = true,
}
AddPawn("DNT_ThunderbugBoss")
