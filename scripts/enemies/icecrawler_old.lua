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

local name = "icecrawler" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -26, PosY = -5}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -26, PosY = -5, NumFrames = 9}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_icecrawler = base
a.DNT_icecrawlere = baseEmerge
a.DNT_icecrawlera = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 9 }
a.DNT_icecrawlerd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 12, Time = .14 } --Numbers copied for now
a.DNT_icecrawlerw = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png", PosY = 0} --Only if there's a boss


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
	local tpawn = Board:GetPawn(target)
	local burrower = false
	if tpawn and _G[tpawn:GetType()].Burrows then burrower = true end

	if Board:IsBlocked(target,PATH_PROJECTILE) and not Board:IsFrozen(target) and not burrower then -- do not freeze frozen things again or burrowers (they burrow anyway with damage)
		damage.iFrozen = EFFECT_CREATE
	elseif not Board:IsBlocked(target,PATH_PROJECTILE) and Board:GetTerrain(target) ~= TERRAIN_ICE then
		damage.iFrozen = EFFECT_CREATE
	end

	if self.FreezeSelf then
		selfdamage = SpaceDamage(p1)
		selfdamage.iFrozen = EFFECT_CREATE
		ret:AddQueuedDamage(selfdamage)
	end

	ret:AddQueuedProjectile(damage,self.Projectile,FULL_DELAY)

	if self.ExplodeIce then
		if Board:IsFrozen(target) or (not Board:IsBlocked(target,PATH_PROJECTILE) and Board:GetTerrain(target) == TERRAIN_ICE) then
			for i = DIR_START, DIR_END do
				local curr = DIR_VECTORS[i] + target
				if i ~= GetDirection(p1 - p2) then
					damage = SpaceDamage(curr,self.Damage)
					-- damage.sAnimation = "IceShards"
					-- damage.sSound = self.SoundBase.."/attack"
					ret:AddQueuedDamage(damage)
				end
			end
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

-- function DNT_IceCrawlerAtk1:GetTargetScore(p1,p2)
	-- local ret = Skill.GetTargetScore(self, p1, p2)
	-- local dir = GetDirection(p2 - p1)
	-- local target = GetProjectileEnd(p1,p2)

	-- local pawn = Board:GetPawn(target)
	-- if pawn then
		-- if pawn:IsFrozen() then
			-- local p3 = p2 - DIR_VECTORS[dir]
			-- if p3 == p1 then
				-- ret = ret - 5
			-- end
			-- -- if pawn:GetTeam() == TEAM_PLAYER then -- make it more difficult to unfreeze mechs (it explodes now, not a big problem anymore).
				-- -- ret = ret - 5
			-- -- end
		-- end
	-- end

    -- return ret
-- end

-----------
-- Pawns --
-----------

DNT_IceCrawler1 = Pawn:new
	{
		Name = "Ice Crawler",
		Health = 3,
		MoveSpeed = 2,
		Ranged = 1,
		Image = "DNT_icecrawler", --Image = "DNT_IceCrawler"
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
		MoveSpeed = 2,
		Ranged = 1,
		SkillList = {"DNT_IceCrawlerAtk2"},
		Image = "DNT_icecrawler", --Image = "DNT_IceCrawler",
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