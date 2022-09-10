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

local name = "icecrawler" --lowercase, I could also use this else where, but let's make it more readable elsewhere

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

DNT_IceCrawlerAtk1 = Skill:new {
	Name = "Cryo Spit",
	Description = "Damage and freeze the target or explode ice to damage adjacent tiles.",
	Damage = 1,
	Class = "Enemy",
	FreezeSelf = false, -- set true and uncomment the hooks to test with self freeze
	ExplodeIce = true,
	LaunchSound = "/enemy/snowtank_1/attack",
	ImpactSound = "/impact/generic/explosion",
	Projectile = "effects/shot_tankice",
	PathSize = 1,
	Icon = "weapons/enemy_leaper1.png",
	SoundBase = "/enemy/leaper_1",
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Second_Origin = Point(2,3),
		Second_Target = Point(2,2),
		Enemy = Point(1,1),
		Building = Point(2,1),
		CustomPawn = "DNT_IceCrawler1",
	}
}

DNT_IceCrawlerAtk2 = DNT_IceCrawlerAtk1:new {
	Damage = 3,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Second_Origin = Point(2,3),
		Second_Target = Point(2,2),
		Enemy = Point(1,1),
		Building = Point(2,1),
		CustomPawn = "DNT_IceCrawler2",
	}
}

function DNT_IceCrawlerAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local target = GetProjectileEnd(p1,p2)
	local damage = SpaceDamage(target,self.Damage) 
	
	if not Board:IsFrozen(target) then -- do not freeze frozen things again
		damage.iFrozen = EFFECT_CREATE
	end
	
	if self.FreezeSelf then
		selfdamage = SpaceDamage(p1)
		selfdamage.iFrozen = EFFECT_CREATE
		ret:AddQueuedDamage(selfdamage)
	end
	
	ret:AddQueuedProjectile(damage,self.Projectile,FULL_DELAY)
	
	if Board:IsFrozen(target) and self.ExplodeIce then
		for i = DIR_START, DIR_END do
			local curr = DIR_VECTORS[i] + target
			damage = SpaceDamage(curr,1)
			-- damage.sAnimation = "IceShards"
			-- damage.sSound = self.SoundBase.."/attack"
			ret:AddQueuedDamage(damage)
		end
	end
	
	-- Unfreeze mech corpse because it's weird (invisible ice). Also unfreeze shielded targets.
	local defrost = Board:GetPawn(target)
	if defrost then
		defrost = Board:IsDeadly(SpaceDamage(target,self.Damage),defrost) or defrost:IsDead() or defrost:IsShield()
	end
	if defrost then
		damage = SpaceDamage(target)
		damage.iFrozen = EFFECT_REMOVE
		ret:AddQueuedDamage(damage)
	end
	
	return ret
end

function DNT_IceCrawlerAtk1:GetTargetScore(p1,p2)
	local ret = Skill.GetTargetScore(self, p1, p2)
	
	local target = GetProjectileEnd(p1,p2)
	
	local pawn = Board:GetPawn(target)
	if pawn then -- make it more difficult to unfreeze mechs.
		if pawn:GetTeam() == TEAM_PLAYER and pawn:IsFrozen() then
			ret = ret - 4
		end
	end

	-- if Board:IsFrozen(p2) then -- ignore frozen things
		-- ret = 0
	-- end

    return ret
end

-----------
-- Pawns --
-----------

DNT_IceCrawler1 = Pawn:new
	{
		Name = "Ice Crawler",
		Health = 3,
		MoveSpeed = 4,
		Ranged = 1,
		Image = "bouncer", --Image = "DNT_IceCrawler"
		SkillList = {"DNT_IceCrawlerAtk1"},
		SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
	}
AddPawn("DNT_IceCrawler1")

DNT_IceCrawler2 = Pawn:new
	{
		Name = "Alpha Ice Crawler",
		Health = 5,
		MoveSpeed = 4,
		Ranged = 1,
		SkillList = {"DNT_IceCrawlerAtk2"},
		Image = "bouncer", --Image = "DNT_IceCrawler",
		SoundLocation = "/enemy/beetle_2/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_IceCrawler2")


-----------
-- Hooks --
-----------

-- local function HOOK_nextTurn(mission)
	-- if Game:GetTeamTurn() == TEAM_ENEMY then
		-- local enemyList = extract_table(Board:GetPawns(TEAM_ENEMY))
		-- for i = 1, #enemyList do
			-- if Board:GetPawn(enemyList[i]):GetType():find("^DNT_IceCrawler") ~= nil then
				-- Board:GetPawn(enemyList[i]):SetFrozen(false)
			-- end
		-- end
	-- elseif Game:GetTeamTurn() == TEAM_PLAYER then
		-- local enemyList = extract_table(Board:GetPawns(TEAM_PLAYER))
		-- for i = 1, #enemyList do
			-- if Board:GetPawn(enemyList[i]):GetType():find("^DNT_IceCrawler") ~= nil then
				-- Board:GetPawn(enemyList[i]):SetFrozen(false)
			-- end
		-- end
	-- end
-- end

-- local function EVENT_onModsLoaded()
	-- modApi:addNextTurnHook(HOOK_nextTurn)
-- end

-- modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
