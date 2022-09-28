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

modApi:appendAsset("img/effects/DNT_upshot_pillbug1.png", resourcePath.."img/effects/DNT_upshot_pillbug1.png")
modApi:appendAsset("img/effects/DNT_effect1_pillbug1.png", resourcePath.."img/effects/DNT_effect1_pillbug1.png")
modApi:appendAsset("img/effects/DNT_effect2_pillbug1.png", resourcePath.."img/effects/DNT_effect2_pillbug1.png")

modApi:appendAsset("img/effects/DNT_upshot_pillbug2.png", resourcePath.."img/effects/DNT_upshot_pillbug2.png")
modApi:appendAsset("img/effects/DNT_effect1_pillbug2.png", resourcePath.."img/effects/DNT_effect1_pillbug2.png")
modApi:appendAsset("img/effects/DNT_effect2_pillbug2.png", resourcePath.."img/effects/DNT_effect2_pillbug2.png")

modApi:appendAsset("img/effects/DNT_upshot_pillbug3.png", resourcePath.."img/effects/DNT_upshot_pillbug3.png")
modApi:appendAsset("img/effects/DNT_effect1_pillbug3.png", resourcePath.."img/effects/DNT_effect1_pillbug3.png")
modApi:appendAsset("img/effects/DNT_effect2_pillbug3.png", resourcePath.."img/effects/DNT_effect2_pillbug3.png")

-------------
--   Art   --
-------------

local name = "pillbug" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
--modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -23, PosY = -5}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -26, PosY = -10, NumFrames = 12}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_pillbug = base
a.DNT_pillbuge = baseEmerge
a.DNT_pillbuga = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 8, Time = .15}
a.DNT_pillbugd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 8, Time = .14 } --Numbers copied for now
--a.DNT_pillbugw = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png"} --Only if there's a boss


-------------
-- Weapons --
-------------

DNT_PillbugLeap1 = Skill:new{
	Name = "Bouncing Leap",
	Description = "Leap to a tile, landing on it or bouncing back on occupied tiles before it.", -- Too confusing?
	Class = "Enemy",
	Icon = "weapons/enemy_scarab1.png",
	Projectile = "effects/DNT_upshot_pillbug1.png",
	Effect1 = "effects/DNT_effect1_pillbug1.png",
	Effect2 = "effects/DNT_effect2_pillbug1.png",
	Range = 5,
	Damage = 1,
	TipImage = {
		Unit = Point(2,4),
		Target = Point(2,0),
		Enemy1 = Point(2,0),
		Mountain = Point(2,1),
		Building = Point(2,2),
		CustomPawn = "DNT_Pillbug1",
	}
}

DNT_PillbugLeap2 = DNT_PillbugLeap1:new{
	Name = "Carapace Leap",
	Damage = 2,
	Projectile = "effects/DNT_upshot_pillbug2.png",
	Effect1 = "effects/DNT_effect1_pillbug2.png",
	Effect2 = "effects/DNT_effect2_pillbug2.png",
	TipImage = {
		Unit = Point(2,4),
		Target = Point(2,0),
		Enemy1 = Point(2,0),
		Mountain = Point(2,1),
		Building = Point(2,2),
		CustomPawn = "DNT_Pillbug2",
	}
}

DNT_PillbugLeap3 = DNT_PillbugLeap1:new{
	Name = "Crushing Leap",
	Damage = 3,
	Projectile = "effects/DNT_upshot_pillbug3.png",
	Effect1 = "effects/DNT_effect1_pillbug3.png",
	Effect2 = "effects/DNT_effect2_pillbug3.png",
	TipImage = {
		Unit = Point(2,4),
		Target = Point(2,0),
		Enemy1 = Point(2,0),
		Mountain = Point(2,1),
		Building = Point(2,2),
		CustomPawn = "DNT_Pillbug3",
	}
}

function DNT_PillbugLeap1:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		for k = 2, self.Range do
			local curr = DIR_VECTORS[i]*k + point
			if Board:IsValid(curr) then
				ret:push_back(curr)
			end
		end
	end
	return ret
end

function DNT_PillbugLeap1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local p3 = p2

	ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetInvisible(true)", p1:GetString())) -- hide pawn
	if Board:IsBlocked(p2,PATH_PROJECTILE) then
		ret:AddQueuedArtillery(SpaceDamage(p2, self.Damage),self.Projectile,NO_DELAY) -- jump effect
		ret:AddQueuedDelay(0.01)
		ret:AddQueuedArtillery(SpaceDamage(p2),self.Effect1,NO_DELAY) -- after effect 1
		ret:AddQueuedDelay(0.01)
		ret:AddQueuedArtillery(SpaceDamage(p2),self.Effect2,NO_DELAY) -- after effect 2
		ret:AddQueuedDelay(0.78)
		for i = 1, 8 do
			local nextpoint = p3 - DIR_VECTORS[dir]

			ret:AddQueuedScript(string.format([[
				local fx = SkillEffect()
				local p1 = %s
				local p2 = %s
				local proj = %q
				local effect1 = %q
				local effect2 = %q

				fx:AddArtillery(p1,SpaceDamage(p2),proj,NO_DELAY)
				fx:AddDelay(0.02)
				fx:AddArtillery(p1,SpaceDamage(p2),effect1,NO_DELAY)
				fx:AddDelay(0.02)
				fx:AddArtillery(p1,SpaceDamage(p2),effect2,NO_DELAY)

				Board:AddEffect(fx)
			]],p3:GetString(),nextpoint:GetString(),self.Projectile,self.Effect1,self.Effect2)) -- bounce effect

			p3 = p3 - DIR_VECTORS[dir]
			if not Board:IsBlocked(nextpoint,PATH_PROJECTILE) or nextpoint == p1 then
				break
			end
			ret:AddQueuedDelay(0.8)
			ret:AddQueuedDamage(SpaceDamage(p3,self.Damage))
		end
		ret:AddQueuedDelay(0.02)
	else
		ret:AddQueuedArtillery(SpaceDamage(p2),self.Projectile,NO_DELAY) -- jump effect
		ret:AddQueuedDelay(0.01)
		ret:AddQueuedArtillery(SpaceDamage(p2),self.Effect1,NO_DELAY) -- after effect 1
		ret:AddQueuedDelay(0.01)
		ret:AddQueuedArtillery(SpaceDamage(p2),self.Effect2,NO_DELAY) -- after effect 2
	end
	ret:AddQueuedDelay(0.78)
	ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetSpace(%s)", p1:GetString(), p3:GetString())) --move pawn
	ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetInvisible(false)", p3:GetString())) -- show pawn

	-- Preview
	local move = PointList()
	move:push_back(p1)
	move:push_back(p3)
	ret:AddQueuedMove(move, NO_DELAY) -- charge preview
	ret.q_effect:back().bHide = true -- hide charge arrow path
	ret:AddQueuedDelay(0.5)

	return ret
end

function DNT_PillbugLeap1:GetTargetScore(p1, p2)
  local ret = Skill.GetTargetScore(self, p1, p2)
  local dir = GetDirection(p2 - p1)

	if ret > 5 then
	  ret = 5
	end

	local p3 = p2
	while Board:IsBlocked(p3,PATH_PROJECTILE) do
		if p3 == p1 then
			break
		end
		p3 = p3 - DIR_VECTORS[dir]
	end

	if Board:GetTerrain(p3) == TERRAIN_HOLE then -- less priority to suicide attacks
		ret = ret - 4
	elseif Board:GetTerrain(p3) == TERRAIN_WATER and not _G[Board:GetPawn(p1):GetType()].Massive then
		ret = ret - 4
	end

	-- don't target your friends.
	local targetPawn = Board:GetPawn(p2)
	if targetPawn then
		if targetPawn:GetTeam() == TEAM_ENEMY then
			ret = 0
		end
	end

    return ret
end

-----------
-- Pawns --
-----------

DNT_Pillbug1 = Pawn:new{
	Name = "Isopod",
	Health = 1,
	MoveSpeed = 2,
	Ranged = 1,
	Image = "DNT_pillbug",
	Armor = true,
	SkillList = { "DNT_PillbugLeap1" },
	SoundLocation = "/enemy/digger_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
}
AddPawn("DNT_Pillbug1")

DNT_Pillbug2 = Pawn:new{
	Name = "Alpha Isopod",
	Health = 3,
	MoveSpeed = 2,
	Ranged = 1,
	Image = "DNT_pillbug",
	ImageOffset = 1,
	Armor = true,
	SkillList = { "DNT_PillbugLeap2" },
	SoundLocation = "/enemy/digger_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
	Tier = TIER_ALPHA,
}
AddPawn("DNT_Pillbug2")

DNT_Pillbug3 = Pawn:new{
	Name = "Isopod Leader",
	Health = 4,
	MoveSpeed = 2,
	Ranged = 1,
	Image = "DNT_pillbug",
	ImageOffset = 2,
	Armor = true,
	SkillList = { "DNT_PillbugLeap3" },
	SoundLocation = "/enemy/digger_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
	Tier = TIER_BOSS,
	Massive = true
}
AddPawn("DNT_Pillbug3")
