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

local name = "junebug" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")
modApi:appendAsset(writepath.."DNT_"..name.."_Bw_broken.png", readpath.."DNT_"..name.."_Bw_broken.png")


local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -27, PosY = -3, Height = 1}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -27, PosY = -3, Height = 1, NumFrames = 9}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_junebug = base
a.DNT_junebuge = baseEmerge
a.DNT_junebuga = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 12 } --BELOW: Frames 7, Time .14
a.DNT_junebugd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 1, Time = 0, PosY = -2 } --Numbers copied for now
a.DNT_junebugw = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png", PosY = 3} --Only if there's a boss
a.DNT_junebugw_broken = base:new{Image = imagepath.."DNT_"..name.."_Bw_broken.png", PosY = 5}

name = "angryjunebug" --Angry boi

modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")

a.DNT_angryjunebug = a.DNT_junebug:new{}
a.DNT_angryjunebuge = a.DNT_junebuge:new{}
a.DNT_angryjunebuga = a.DNT_junebuga:new{ Image = imagepath.."DNT_"..name.."a.png", Time = a.DNT_junebuga.Time / 2}
a.DNT_angryjunebugd = a.DNT_junebugd:new{}
a.DNT_angryjunebugw = a.DNT_junebugw:new{}
a.DNT_angryjunebugw_broken = a.DNT_junebugw_broken:new{}


-----------------
--  Portraits  --
-----------------

local ptname = "Junebug"
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."Boss.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."Boss.png")

-----------------
--  Animation  --
-----------------

modApi:copyAsset("img/effects/laserbend_U.png", "img/effects/DNT_laser_junebug_U.png")
modApi:copyAsset("img/effects/laserbend_U1.png", "img/effects/DNT_laser_junebug_U1.png")
modApi:copyAsset("img/effects/laserbend_U2.png", "img/effects/DNT_laser_junebug_U2.png")
modApi:copyAsset("img/effects/laserbend_R.png", "img/effects/DNT_laser_junebug_R.png")
modApi:copyAsset("img/effects/laserbend_R1.png", "img/effects/DNT_laser_junebug_R1.png")
modApi:copyAsset("img/effects/laserbend_R2.png", "img/effects/DNT_laser_junebug_R2.png")
modApi:copyAsset("img/effects/laserbend_start.png", "img/effects/DNT_laser_junebug_start.png")
modApi:appendAsset("img/effects/DNT_laser_junebug_hit.png", resourcePath.."img/effects/DNT_laser_junebug_hit.png")
local v = "DNT_laser_junebug"
Location["effects/"..v.."_U.png"] = Point(-12,3)
Location["effects/"..v.."_U1.png"] = Point(-12,3)
Location["effects/"..v.."_U2.png"] = Point(-12,3)
Location["effects/"..v.."_R.png"] = Point(-12,3)
Location["effects/"..v.."_R1.png"] = Point(-12,3)
Location["effects/"..v.."_R2.png"] = Point(-12,3)
Location["effects/"..v.."_hit.png"] = Point(-12,3)
Location["effects/"..v.."_start.png"] = Point(-12,3)

modApi:appendAsset("img/effects/DNT_junebug_shimmer.png", resourcePath.."img/effects/DNT_junebug_shimmer.png")
a.DNT_JunebugShimmer = Animation:new {
	Image = "effects/DNT_junebug_shimmer.png",
	NumFrames = 6,
	PosX = -15,
	PosY = 4,
	Loop = false,
	Time = 0.09,
}

--[[
a.DNT_JunebugPlusU = Animation:new {
	Image = "effects/laser_push_U.png",
	NumFrames = 1,
	PosX = -12,
	PosY = 0,
	Loop = false,
	Time = 0.3,
}

a.DNT_JunebugPlusR = Animation:new {
	Image = "effects/laser_push_R.png",
	NumFrames = 1,
	PosX = -12,
	PosY = 0,
	Loop = false,
	Time = 0.3,
}

a.DNT_JunebugPlusSpiral = Animation:new {
	Image = "effects/laser_push_hit.png",
	NumFrames = 1,
	PosX = -12,
	PosY = 0,
	Loop = false,
	Time = 0.3,
}
]]

-------------
-- Weapons --
-------------

DNT_JunebugAtkBoss = Skill:new {
	Name = "Light Bender",
	Description = "Hit two opposite tiles with a powerful light attack. If the ladybug dies, launch two high powered pushing lasers in opposite directions.",
	Damage = 3,
	MinDamage = 1,
	Class = "Enemy",
	LaunchSound = "",
  PathSize = 1,
  LaserArt = "effects/DNT_laser_junebug",
	CustomTipImage = "DNT_JunebugAtkBoss_Tip",
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,2),
		Target = Point(2,1),
		Building = Point(2,0),
		Enemy = Point(2,1),
		Enemy2 = Point(2,4),
		Second_Origin = Point(2,2),
		Second_Target = Point(2,1),
		CustomPawn = "DNT_JunebugBoss",
		Length = 4,
	}
}

function DNT_JunebugAtkBoss:GetTargetArea(p1)
	local ret = PointList()
	for dir = DIR_START, DIR_END do
		ret:push_back(p1 + DIR_VECTORS[dir])
	end
	return ret
end

function DNT_JunebugAtkBoss:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local mission = GetCurrentMission()
	local direction = GetDirection(p2-p1)
	local backdir = (direction+2)%4
	local damage = nil
	if (mission.DNT_LadybugID and Board:IsPawnAlive(mission.DNT_LadybugID)) or (IsTipImage() and self.Tooltip <= 1) then --Tooltip Stuff
		--Animation First Since the Queued Melee has Delay
		ret:AddQueuedBounce(p1,2)
		targets = {p1+DIR_VECTORS[direction],p1+DIR_VECTORS[backdir]}
		for _, target in pairs(targets) do
			damage = SpaceDamage(target,self.Damage,GetDirection(target-p1))
			damage.sAnimation = "DNT_JunebugShimmer"
			ret:AddQueuedMelee(p1, damage)
		end
	else --Stolen and Edited from Push Beam
		local dirs = {direction,backdir}
		for _, dir in pairs(dirs) do
			local targets = {}
			local curr = p1 + DIR_VECTORS[dir]
			while Board:GetTerrain(curr) ~= TERRAIN_MOUNTAIN and not Board:IsBuilding(curr) and Board:IsValid(curr) do
				targets[#targets+1] = curr
				curr = curr + DIR_VECTORS[dir]
			end
			if Board:IsValid(curr) then
				targets[#targets+1] = curr
			end
			local dam = SpaceDamage(curr, 0)
			ret:AddQueuedProjectile(dam,self.LaserArt,NO_DELAY)

			for i = 1, #targets do
				local curr = targets[#targets - i + 1]
				if Board:IsPawnSpace(curr) then
					ret:AddQueuedDelay(0.1)
				end

				local damage = SpaceDamage(curr, math.max(1,self.Damage-p1:Manhattan(curr)+1), dir)
				ret:AddQueuedDamage(damage)
			end
		end

	end
	return ret
end

-------------
-- Tooltip --
-------------

DNT_JunebugAtkBoss_Tip = DNT_JunebugAtkBoss:new{
	Tooltip = 0, --0 1 equals Ladybug, 2 3 equals no ladybug
	--This is because the skill effect runs twice. I'll use these numbers change the board state and determine which weapon to use
}

function DNT_JunebugAtkBoss_Tip:GetSkillEffect(p1,p2)
	if self.Tooltip == 0 then --Add Ladybug
		Board:AddPawn("DNT_LadybugBoss", Point(2,3))
	end
	local ret = DNT_JunebugAtkBoss.GetSkillEffect(self,p1,p2) --Pass in self by using the . instead of :
	self.Tooltip = (self.Tooltip + 1) % 4
	return ret
end

-----------
-- Pawns --
-----------
--[[
DNT_Name1 = Pawn:new
	{
		Name = "Name",
		Health = 2,
		MoveSpeed = 3,
		Image = "DNT_name" --lowercase
		SkillList = {"DNT_NameAtk1"},
		SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
	}
AddPawn("DNT_Name1")

DNT_Name2 = Pawn:new
	{
		Name = "Alpha Name",
		Health = 4,
		MoveSpeed = 3,
		SkillList = {"DNT_NameAtk2"},
		Image = "DNT_name",
		SoundLocation = "/enemy/beetle_1/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_Name2")
]]--

DNT_JunebugBoss = Pawn:new
	{
		Name = "Junebug Leader",
		Health = 5,
		MoveSpeed = 4,
		SkillList = {"DNT_JunebugAtkBoss"},
		Image = "DNT_junebug",
		SoundLocation = "/enemy/beetle_1/",
		ImageOffset = 0,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_BOSS,
    Massive = true,
    Corpse = true,
	}
AddPawn("DNT_JunebugBoss")

function DNT_JunebugBoss:GetDeathEffect(p1)
	local ret = SkillEffect()
	if Board:GetTerrain(p1) == TERRAIN_WATER then
		Board:AddAnimation(p1,"Splash",ANIM_NO_DELAY)
	end
	return ret
end



-----------
-- Hooks --
-----------



local this = {}

local function PawnKilled(mission,pawn)
	if mission.DNT_LadybugID == pawn:GetId() and Board:IsPawnAlive(mission.BossID) then
		local space = Board:GetPawn(mission.BossID):GetSpace()
		Board:GetPawn(mission.BossID):SetCustomAnim("DNT_angryjunebug")
		Board:Ping(space, GL_Color(255,0,0))
		Board:AddAlert(space,"COMPANION KILLED")
	end
end

function this:load(DNT_Vextra_ModApiExt)
	local options = mod_loader.currentModContent[mod.id].options
	DNT_Vextra_ModApiExt:addPawnKilledHook(PawnKilled)

end

return this
