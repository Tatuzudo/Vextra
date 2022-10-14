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
--   Art   --
-------------

local name = "fly" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- -- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
-- modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
-- modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
-- modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
-- modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
-- modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

-- local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -23, PosY = -5}
-- local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -23, PosY = -5, NumFrames = 10}

-- -- REPLACE "name" with the name
-- -- UNCOMENT WHEN YOU HAVE SPRITES
-- a.DNT_mantis = base
-- a.DNT_mantise = baseEmerge
-- a.DNT_mantisa = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
-- a.DNT_mantisd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 8, Time = .15 } --Numbers copied for now
-- a.DNT_mantisw = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png", PosY = 3} --Only if there's a boss

-------------
-- Weapons --
-------------

DNT_FlyAtk1 = Skill:new{
	-- Name = "Gastric Eviction",
	Name = "Sapping Proboscis",
	Description = "Short-range artillery attack that applies A.C.I.D.",
	Class = "Enemy",
	Icon = "weapons/enemy_leaper1.png",
	ImpactSound = "/enemy/moth_1/attack_impact",
	LaunchSound = "/enemy/moth_1/attack_launch",
	Projectile = "effects/shotup_crab2.png",
	LaserArt = "effects/laser2",
	PathSize = 1,
	Damage = 1,
	Heal = 1,
	Range = 2,
	-- Acid = EFFECT_CREATE,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy1 = Point(2,1),
		CustomPawn = "DNT_Fly1",
	}
}

DNT_FlyAtk2 = DNT_FlyAtk1:new{
	-- Name = "Caustic Eviction",
	Name = "Syphon Proboscis",
	ImpactSound = "/enemy/moth_2/attack_impact",
	LaunchSound = "/enemy/moth_2/attack_launch",
	Projectile = "effects/shotup_crab2.png",
	Damage = 2,
	Heal = 2,
}

DNT_FlyAtk3 = DNT_FlyAtk1:new{
	-- Name = "Corrosive Eviction",
	Name = "Leech Proboscis",
	ImpactSound = "/enemy/moth_2/attack_impact",
	LaunchSound = "/enemy/moth_2/attack_launch",
	Projectile = "effects/shotup_crab2.png",
	Damage = 3,
	Heal = 4,
	Acid = EFFECT_CREATE,
}

-- function DNT_FlyAtk1:GetTargetArea(point)
	-- local ret = PointList()
	-- for i = DIR_START, DIR_END do
		-- local curr = DIR_VECTORS[i]*self.Range + point
		-- if Board:IsValid(curr) then
			-- ret:push_back(curr)
		-- end
	-- end
	-- return ret
-- end


-- function DNT_FlyAtk1:GetSkillEffect(p1, p2)
	-- local ret = SkillEffect()
	
	-- local damage = SpaceDamage(p2,self.Damage)
	-- damage.iAcid = self.Acid
	-- ret:AddQueuedArtillery(damage,self.Projectile,FULL_DELAY)
	
	-- return ret
-- end

SkillEffect["DNT_AddQueuedProjectile"] = function(self, ...) -- add our own queued projectile
	local fx = SkillEffect()
	fx["AddProjectile"](fx, ...)
	self.q_effect:AppendAll(fx.effect)
end

function DNT_FlyAtk1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local p3 = GetProjectileEnd(p1,p2)
	local dir = GetDirection(p1 - p2)
	
	local damage = SpaceDamage(p3,self.Damage,dir)
	damage.iAcid = self.Acid
	ret:AddQueuedDamage(damage)
	local heal = SpaceDamage(p1,-self.Heal)
	-- ret:AddQueuedProjectile(SpaceDamage(p3),self.LaserArt)
	ret:DNT_AddQueuedProjectile(p3,SpaceDamage(p1),"effects/shot_firefly2",NO_DELAY)
	ret:AddQueuedDelay(p1:Manhattan(p3)*0.1)
	if Board:IsBlocked(p3, PATH_PROJECTILE) and Board:GetTerrain(p3) ~= TERRAIN_MOUNTAIN then
		ret:AddQueuedDamage(heal)
	end
	
	return ret
end

function DNT_FlyAtk1:GetTargetScore(p1,p2)
	local ret = Skill.GetTargetScore(self, p1, p2)
	if Board:IsBlocked(p2, PATH_PROJECTILE) then
		ret = ret -2
	end
	return ret
end

-----------
-- Pawns --
-----------

DNT_Fly1 = Pawn:new{
	Name = "Fly",
	-- Health = 1,
	-- MoveSpeed = 5,
	Health = 3,
	StartingHealth = 1,
	MoveSpeed = 4,
	Image = "hornet",--"DNT_mantis",
	Flying = true,
	SkillList = { "DNT_FlyAtk1" },
	SoundLocation = "/enemy/leaper_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
}
AddPawn("DNT_Fly1")

DNT_Fly2 = Pawn:new{
	Name = "Alpha Fly",
	-- Health = 3,
	-- MoveSpeed = 5,
	Health = 5,
	StartingHealth = 3,
	MoveSpeed = 4,
	Image = "hornet",--"DNT_mantis",
	ImageOffset = 1,
	Flying = true,
	SkillList = { "DNT_FlyAtk2" },
	SoundLocation = "/enemy/leaper_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
	Tier = TIER_ALPHA,
}
AddPawn("DNT_Fly2")

DNT_Fly3 = Pawn:new{
	Name = "Fly Leader",
	-- Health = 5,
	-- MoveSpeed = 5,
	Health = 7,
	StartingHealth = 4,
	MoveSpeed = 4,
	Image = "hornet",--"DNT_mantis",
	ImageOffset = 2,
	Flying = true,
	SkillList = { "DNT_FlyAtk3" },
	SoundLocation = "/enemy/leaper_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
	Tier = TIER_BOSS,
	Massive = true,
}
AddPawn("DNT_Fly3")

-----------
-- Hooks --
-----------

local HOOK_pawnTracked = function(mission, pawn)
	if pawn:GetType():find("^DNT_Fly") then
		-- pawn:SetHealth(math.floor(pawn:GetHealth()/2))
		pawn:SetHealth(_G[pawn:GetType()].StartingHealth)
	end
end

local function EVENT_onModsLoaded()
	DNT_Vextra_ModApiExt:addPawnTrackedHook(HOOK_pawnTracked)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
