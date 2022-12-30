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
--  Anims  --
-------------
local directions = {"U","R","D","L"}
for i=1,3 do --4
	for _, v in pairs(directions) do
		modApi:appendAsset("img/effects/DNT_chillthrower"..i.."_"..v..".png", resourcePath.."img/effects/chillthrower"..i.."_"..v..".png")
	end
end
a.chillthrower1_0 = a.flamethrower1_0:new{ Image = "effects/DNT_chillthrower1_U.png"}
a.chillthrower2_0 = a.flamethrower2_0:new{ Image = "effects/DNT_chillthrower2_U.png"}
a.chillthrower3_0 = a.flamethrower3_0:new{ Image = "effects/DNT_chillthrower3_U.png"}
--a.chillthrower4_0 = a.flamethrower4_0:new{ Image = "effects/DNT_chillthrower4_U.png"}

a.chillthrower1_1 = a.flamethrower1_1:new{ Image = "effects/DNT_chillthrower1_R.png"}
a.chillthrower2_1 = a.flamethrower2_1:new{ Image = "effects/DNT_chillthrower2_R.png"}
a.chillthrower3_1 = a.flamethrower3_1:new{ Image = "effects/DNT_chillthrower3_R.png"}
--a.chillthrower4_1 = a.flamethrower4_1:new{ Image = "effects/DNT_chillthrower4_R.png"}

a.chillthrower1_2 = a.flamethrower1_2:new{ Image = "effects/DNT_chillthrower1_D.png"}
a.chillthrower2_2 = a.flamethrower2_2:new{ Image = "effects/DNT_chillthrower2_D.png"}
a.chillthrower3_2 = a.flamethrower3_2:new{ Image = "effects/DNT_chillthrower3_D.png"}
--a.chillthrower4_2 = a.flamethrower4_2:new{ Image = "effects/DNT_chillthrower4_D.png"}

a.chillthrower1_3 = a.flamethrower1_3:new{ Image = "effects/DNT_chillthrower1_L.png"}
a.chillthrower2_3 = a.flamethrower2_3:new{ Image = "effects/DNT_chillthrower2_L.png"}
a.chillthrower3_3 = a.flamethrower3_3:new{ Image = "effects/DNT_chillthrower3_L.png"}
--a.chillthrower1_0 = a.flamethrower4_3:new{ Image = "effects/DNT_chillthrower4_L.png"}
 --Board:AddAnimation(Point(6,6),"chillthrower1_3",ANIM_NO_DELAY)
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

-----------------
--  Portraits  --
-----------------

local ptname = "IceCrawler"
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."1.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."1.png")
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."2.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."2.png")
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."Boss.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."Boss.png")

-------------
-- Weapons --
-------------

DNT_IceCrawlerAtk1 = Skill:new {
	Name = "Cryo Chillthrower",
	Description = "Release an icy gas with 3 range that deals more damage the farther it travels and freezes. Stops at buildings and mountains.",
	Damage = 2,
	MinDamage = 0, --Starting Damage
	Range = 3,
	Class = "Enemy",
	FreezeSelf = false, -- set true and uncomment the hooks to test with self freeze
	ExplodeIce = false,
	ExtraTiles = false,
	DamageIncrease = 1,
	LaunchSound = "/weapons/flamespreader",
	ImpactSound = "/impact/generic/explosion",
	Projectile = "effects/shot_tankice",
	PathSize = 1,
	Icon = "weapons/enemy_leaper1.png",
	SoundBase = "/enemy/leaper_1",
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy = Point(2,2),
		Building = Point(2,1),
		CustomPawn = "DNT_IceCrawler1",
	}
}

DNT_IceCrawlerAtk2 = DNT_IceCrawlerAtk1:new {
	Damage = 3,
	MinDamage = 1, --Starting Damage
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy = Point(2,2),
		Building = Point(2,1),
		CustomPawn = "DNT_IceCrawler2",
	}
}
DNT_IceCrawlerAtkB = DNT_IceCrawlerAtk1:new {
	Description = "Release an icy gas in two directions with 3 range that deals more damage the farther it travels and freezes. Explodes existing ice out sideways. Stops at buildings and mountains.",
	Damage = 3,
	MinDamage = 1, --Starting Damage
	ExplodeIce = true,
	ExtraTiles = true,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy = Point(2,2),
		Building = Point(2,1),
		Enemy2 = Point(1,2),
		Building2 = Point(3,1),
		Mountain = Point(2,4),
		Second_Origin = Point(2,3),
		Second_Target = Point(2,2),
		CustomPawn = "DNT_IceCrawlerBoss",
	}
}

--TO DO: Animation
function DNT_IceCrawlerAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	--local target = GetProjectileEnd(p1,p2)
	local dir = GetDirection(p2-p1)
	local backdir = GetDirection(p1-p2)
	local damage = nil
	local DNT_DES_Count = 0 --achievement

	local targets = {}
	local curr = nil
	for i=1,self.Range do
		curr = p1+DIR_VECTORS[dir]*i
		table.insert(targets, curr)
		if Board:IsBuilding(curr) or Board:IsTerrain(curr, TERRAIN_MOUNTAIN) or not Board:IsValid(curr+DIR_VECTORS[dir]) then --Board isn't valid one space ahead
			break
		end
	end
	local distance = p1:Manhattan(curr)
	local animation = SpaceDamage(curr,0)
	animation.sAnimation = "chillthrower"..distance.."_"..dir

	local animation2 = nil --I need this later

	if self.ExtraTiles then
		for i=1,self.Range do
			curr = p1+DIR_VECTORS[backdir]*i
			table.insert(targets, curr)
			if Board:IsBuilding(curr) or Board:IsTerrain(curr, TERRAIN_MOUNTAIN) or not Board:IsValid(curr+DIR_VECTORS[backdir]) then
				break
			end
		end

		local distance2 = p1:Manhattan(curr)
		animation2 = SpaceDamage(curr,0)
		animation2.sAnimation = "chillthrower"..distance2.."_"..backdir
		animation2.sSound = "/weapons/flamespreader"
	end

	--LOG(animation.sAnimation)

	for _, target in pairs(targets) do
		local currentDistance = p1:Manhattan(target)
		--LOG("currentDistance", currentDistance)
		--LOG("backdir", backdir)
		--LOG("GetDirection", GetDirection(target-p1))
		if currentDistance == 1 and dir == GetDirection(target-p1) then
			ret:AddQueuedDamage(animation)
		elseif currentDistance == 1 and backdir == GetDirection(target-p1) then
			ret:AddQueuedDamage(animation2)
		end

		local currentDamage = (currentDistance+self.MinDamage-1)*self.DamageIncrease
		local tpawn = Board:GetPawn(target)
		local burrower = false
		if tpawn and _G[tpawn:GetType()].Burrows then burrower = true end
		if tpawn and tpawn:GetTeam() == TEAM_ENEMY then DNT_DES_Count = DNT_DES_Count + 1 end

		damage = SpaceDamage(target,currentDamage)
		if Board:IsBlocked(target,PATH_PROJECTILE) and not Board:IsFrozen(target) and not burrower then -- do not freeze frozen things again or burrowers (they burrow anyway with damage)
			damage.iFrozen = EFFECT_CREATE
		elseif not Board:IsBlocked(target,PATH_PROJECTILE) and Board:GetTerrain(target) ~= TERRAIN_ICE then
			damage.iFrozen = EFFECT_CREATE
		end

		ret:AddQueuedDamage(damage)

		if self.ExplodeIce then --Explode Ice
			if Board:IsFrozen(target) or (not Board:IsBlocked(target,PATH_PROJECTILE) and Board:GetTerrain(target) == TERRAIN_ICE) then
				for i = -1, 2, 2 do
					local currdir = (dir+i)%4
					local curr = DIR_VECTORS[currdir] + target
					local tpawn = Board:GetPawn(curr)
					if tpawn and tpawn:GetTeam() == TEAM_ENEMY then DNT_DES_Count = DNT_DES_Count + 1 end
					damage = SpaceDamage(curr,currentDamage)
					damage.sAnimation = "chillthrower1_"..currdir
					-- damage.sSound = self.SoundBase.."/attack"
					ret:AddQueuedDamage(damage)
				end
			end
		end

		-- Unfreeze mech corpse because it's weird (invisible ice). Also unfreeze shielded targets.
		local defrost = Board:GetPawn(target)
		if defrost then
			defrost = Board:IsDeadly(SpaceDamage(target,currentDamage),defrost) or defrost:IsDead() or defrost:IsShield()
		end
		if defrost then
			damage = SpaceDamage(target)
			damage.iFrozen = EFFECT_REMOVE
			ret:AddQueuedDamage(damage)
		end
		ret:AddQueuedDelay(.2)
	end

	if self.FreezeSelf then
		selfdamage = SpaceDamage(p1)
		selfdamage.iFrozen = EFFECT_CREATE
		ret:AddQueuedDamage(selfdamage)
	end

	--Achievement Check
	if DNT_DES_Count >= 3 and Board:GetPawn(p1):GetType() == "DNT_IceCrawlerBoss" then
		ret:AddQueuedScript('DNT_VextraChevio("DNT_DoubleEdgedSword")')
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
		Health = 2,
		MoveSpeed = 3,
		Ranged = 1,
		Image = "DNT_icecrawler", --Image = "DNT_IceCrawler"
		SkillList = {"DNT_IceCrawlerAtk1"},
		MoveSkill = "DNT_IceCrawlerMove",
		SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
	}
AddPawn("DNT_IceCrawler1")

DNT_IceCrawler2 = Pawn:new
	{
		Name = "Alpha Ice Crawler",
		Health = 4,
		MoveSpeed = 3,
		Ranged = 1,
		SkillList = {"DNT_IceCrawlerAtk2"},
		MoveSkill = "DNT_IceCrawlerMove",
		Image = "DNT_icecrawler", --Image = "DNT_IceCrawler",
		SoundLocation = "/enemy/beetle_2/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_IceCrawler2")

DNT_IceCrawlerBoss = Pawn:new
	{
		Name = "Ice Crawler Leader",
		Health = 6,
		MoveSpeed = 3,
		Ranged = 1,
		SkillList = {"DNT_IceCrawlerAtkB"},
		MoveSkill = "DNT_IceCrawlerMove",
		Image = "DNT_icecrawler", --Image = "DNT_IceCrawler",
		SoundLocation = "/enemy/beetle_2/",
		ImageOffset = 2,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_BOSS,
		Massive = true,
	}
AddPawn("DNT_IceCrawlerBoss")

----------------
-- Move Skill --
----------------

DNT_IceCrawlerMove = Move:new
{

}

function DNT_IceCrawlerMove:GetTargetArea(point)
	return Board:GetReachable(point, Pawn:GetMoveSpeed(), Pawn:GetPathProf())
end

function DNT_IceCrawlerMove:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	--local mission = GetCurrentMission()
	ret:AddMove(Board:GetPath(p1, p2, Pawn:GetPathProf()), FULL_DELAY)
	ret:AddScript(string.format("Board:SetCustomTile(%s, %q)",p2:GetString(),"snow.png"))
	return ret
end


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
