local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
--local previewer = require(scriptPath.."weaponPreview/api")
local trait = require(scriptPath..'libs/trait')

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

modApi:appendAsset("img/icons/fail.png",resourcePath.."img/icons/fail.png") --TEMPORARY
	Location["icons/fail.png"] = Point(-5,-5)
modApi:appendAsset("img/icons/DNT_ladybug_icon.png",resourcePath.."img/icons/DNT_ladybug_icon.png") --TEMPORARY
	Location["icons/DNT_ladybug_icon.png"] = Point(-10,2)
--modApi:appendAsset("img/combat/traits/DNT_ladybug_trait.png",resourcePath.."img/combat/traits/DNT_ladybug_trait.png")

------------
-- Traits --
------------

trait:add{
	pawnType = "DNT_LadybugBoss",
	icon = resourcePath.."img/combat/traits/DNT_ladybug_trait.png",
	desc_title = "Mesmerizing Shell",
	desc_text = "If this unit can be targeted by a mech it must be targeted by that mech.",
}


-------------
--   Art   --
-------------

local name = "ladybug"

modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")


local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -23, PosY = -5}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -23, PosY = -5}

a.DNT_ladybug = base
a.DNT_ladybuge = baseEmerge
a.DNT_ladybuga = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 8 }
a.DNT_ladybugd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 8, Time = 0.16} --Numbers copied for now
a.DNT_ladybugw = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png", PosY = 0} --Only if there's a boss

-----------------
--  Portraits  --
-----------------

local ptname = "Ladybug"
--modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."1.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."1.png")
--modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."2.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."2.png")
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."Boss.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."Boss.png")

-----------------
--  Animation  --
-----------------

modApi:appendAsset("img/effects/DNT_explo_heart.png", resourcePath.."img/effects/DNT_explo_heart.png")
a.DNT_explo_heart = a.ExploArt3:new {
	Image = "effects/DNT_explo_heart.png",
	Time = 0.1,
}

modApi:appendAsset("img/icons/DNT_ladybug_spiral.png",resourcePath.."img/icons/DNT_ladybug_spiral.png")
a.DNT_LadybugHypnosis = Animation:new {
	Image = "icons/DNT_ladybug_spiral.png", --"combat/icons/icon_mind_glow.png",
	NumFrames = 1,
	PosX = -15,
	PosY = -12, --4,
	Time = 1/60,
}

-------------
-- Weapons --
-------------

DNT_LadybugAtkBoss = LineArtillery:new {
	Name = "Focused Heal Bomb", --This needs to be better
	Description = "Tries to heal the Junebug in anyway it can, shooting a healing artillery with splash healing.",
	Damage = -2,
	SplashDamage = -1,
	Class = "Enemy",
	PathSize = 1,
	ArtillerySize = 5,
	Explosion = "",
	Junebug = "DNT_JunebugBoss",
	UpShot = "effects/shotup_ant2.png",
	LaunchSound = "/enemy/scarab_1/attack",
	ImpactSound = "/impact/generic/explosion",
	CustomTipImage = "DNT_LadybugAtkBoss_Tip",
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy = Point(2,2),
		CustomPawn = "DNT_LadybugBoss",
		Length = 5,
	}
}

function DNT_LadybugAtkBoss:GetTargetScore(p1,p2)
	local mission = GetCurrentMission()
	local ret = 0
	if mission.BossID then
		ret = 0-p1:Manhattan(Board:GetPawnSpace(mission.BossID)) --More negative the farther away
	else
		ret = 1 --If we're not in the mission, which this shouldn't happen but just in case, everything is 1
	end
	local pawn = Board:GetPawn(p2)
	if pawn and pawn:GetType() == self.Junebug then
		ret = ret + 100
	end
	return ret
end

function DNT_LadybugAtkBoss:AddHealing(ret,point,healing,arty) --This will check for the junebug which needs its health set
	arty = arty or false
	local damage = SpaceDamage(point,healing)
	if arty then
		damage.sAnimation = "DNT_explo_heart"
		damage.sSound = "/ui/map/repair_mech"
		ret:AddQueuedArtillery(damage, self.UpShot)
	else
		ret:AddQueuedDamage(damage)
	end

	local pawn = Board:GetPawn(point)
	if pawn and pawn:GetType() == self.Junebug and pawn:IsDead() then --Set Health of Junebug
		ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetHealth(%s)",point:GetString(),healing*-1))
	end

	ret:AddQueuedBounce(point,healing)

	return ret
end

function DNT_LadybugAtkBoss:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2-p1)
	ret = self:AddHealing(ret,p2,self.Damage,true)

	for i=DIR_START,DIR_END do
		local curr = p2+DIR_VECTORS[i]
		if Board:IsValid(curr) then
			ret = self:AddHealing(ret,p2+DIR_VECTORS[i],self.SplashDamage)
		end
	end
	return ret
end

-------------
-- Tooltip --
-------------

DNT_LadybugAtkBoss_Tip = DNT_LadybugAtkBoss:new {}

function DNT_LadybugAtkBoss_Tip:GetSkillEffect(p1,p2)
	local pawn = Board:GetPawn(Point(2,1))
	if not pawn then
		Board:AddPawn("DNT_JunebugBoss",Point(2,1))
		local damage = SpaceDamage(Point(2,1),DAMAGE_DEATH)
		Board:DamageSpace(damage)
		local damage = SpaceDamage(Point(2,2),2)
		Board:DamageSpace(damage)
	end
	local ret = DNT_LadybugAtkBoss:GetSkillEffect(p1,p2)
	--ret:AddQueuedDelay(1)
	return ret
end

-----------
-- Pawns --
-----------

DNT_LadybugBoss = Pawn:new
	{
		Name = "Ladybug",
		Health = 3,
		MoveSpeed = 4,
		Image = "DNT_ladybug",
		VoidShockImmune = true,
		SkillList = {"DNT_LadybugAtkBoss"},
		SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		PunishmentDamage = 2,
		Tier = TIER_ALPHA,
		Ranged = 1,
	}
AddPawn("DNT_LadybugBoss")


-----------
-- Hooks --
-----------

--Ladybug Check
local function isLadybug(pawn)
	if pawn then
		local type = pawn:GetType()
		return type == "DNT_LadybugBoss"
	end
	return false
end

local function AdjustTargetArea(mission, pawn, weaponId, p1, targetArea)
	--Only when there's a ladybug
	if not mission then return end
	if mission.DNT_LadybugID and Board:IsPawnAlive(mission.DNT_LadybugID) and pawn:GetTeam() == TEAM_PLAYER then
		local targets = extract_table(targetArea)
		for _, point in pairs(targets) do
			if isLadybug(Board:GetPawn(point)) then
				while not targetArea:empty() do
					targetArea:erase(0)
				end
				targetArea:push_back(point)
				Board:AddAnimation(point,"DNT_LadybugHypnosis",ANIM_NO_DELAY)
				--Board:Ping(point, GL_Color(28, 255, 62))
				--Board:AddAlert(point, "HYPNOSIS")
				return
			end
		end
	end
end

local function AdjustSecondTargetArea(mission, pawn, weaponId, p1, p2, targetArea)
	AdjustTargetArea(mission, pawn, weaponId, p1, targetArea)
end

--Load hooks
local this = {}

function this:load(DNT_Vextra_ModApiExt)
	local options = mod_loader.currentModContent[mod.id].options
	DNT_Vextra_ModApiExt:addTargetAreaBuildHook(AdjustTargetArea)
	DNT_Vextra_ModApiExt:addSecondTargetAreaBuildHook(AdjustSecondTargetArea)
	--DNT_Vextra_ModApiExt:addSkillBuildHook(SkillBuild)
	--DNT_Vextra_ModApiExt:addPawnHealedHook(PawnHealedHook) Only mechs revive

end

return this




--[[Hook that baits mechs
local function SkillBuild(mission, pawn, weaponId, p1, p2, skillEffect)
	if pawn:GetTeam() == TEAM_PLAYER and pawn:IsMech() and not IsTipImage() then --?
		local pawn = Board:GetPawn(p2)
		if isLadybug(pawn) then --Don't go on, we're targetting a ladybug
			return
		end
		local weapon = _G[weaponId]
		local areaPoints = weapon:GetTargetArea(p1)
		for _,v in pairs(extract_table(areaPoints)) do
			pawn = Board:GetPawn(v)
			if isLadybug(pawn) then --There is a ladybug and we aren't targetting it
				--Ping the ladybug(s) and add damage
				local point = pawn:GetSpace()
				skillEffect:AddScript("
					local v = Point("..v:GetString()..")
					Board:Ping(v, GL_Color(255, 0, 0))
					Board:AddAlert(v, 'DIDN\'T TARGET')
				")
				local punishmentDmg = _G[pawn:GetType()].PunishmentDamage

				local icon = SpaceDamage(point, 0)
				icon.sImageMark = "icons/DNT_ladybug_icon.png"
				skillEffect:AddDamage(icon)

				--Save old effect
				local oldEffect = skillEffect.effect
				local oldEffectCopy = DamageList()
				--Make a copy
				for i = 1, oldEffect:size() do
					local oldDamage = oldEffect:index(i);
					oldEffectCopy:push_back(oldDamage)
				end

				--ADD SELF DAMAGE TO SKILL EFFECT
				skillEffect.effect = DamageList()
				local damage = SpaceDamage(p1, punishmentDmg) --Add up? Biggest One? This is temporary
				--damage.sImageMark = "icons/fail.png"
				--damage.sImageMark = "icons/DNT_ladybug_icon.png"
				skillEffect.effect:push_back(damage)

				--Add old effect back in
				for i = 1, oldEffectCopy:size() do
					oldDamage = oldEffectCopy:index(i);
					skillEffect.effect:push_back(oldDamage)
				end
			end
		end
	end
end
--]]
--[[
local function PawnHealedHook(mission, pawn, healingTaken)
	LOG(pawn:GetType() .. " was healed for " .. healingTaken .. " damage!")
end
]]--
