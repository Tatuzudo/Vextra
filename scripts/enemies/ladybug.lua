local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
local previewer = require(scriptPath.."weaponPreview/api")
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
		pawnType = "DNT_Ladybug1",
		icon = resourcePath.."img/combat/traits/DNT_ladybug_trait.png",
		desc_title = "Hypnotic Shell",
		desc_text = "If this unit can be targeted by a mech and isn't, that mech takes 1 self damage (cumulative).",
	}
	trait:add{
		pawnType = "DNT_Ladybug2",
		icon = resourcePath.."img/combat/traits/DNT_ladybug_trait.png",
		desc_title = "Mesmerizing Shell",
		desc_text = "If this unit can be targeted by a mech and isn't, that mech takes 2 self damage (cumulative).",
	}


-------------
--   Art   --
-------------

local name = "ladybug"

modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
--modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -23, PosY = -5}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -23, PosY = -5}

a.DNT_ladybug = base
a.DNT_ladybuge = baseEmerge
a.DNT_ladybuga = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 8 }
a.DNT_ladybugd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 8, Time = 0.16} --Numbers copied for now
--a.DNT_ladybugw = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png"} --Only if there's a boss
-------------
-- Weapons --
-------------

DNT_LadybugAtk1 = Skill:new {
	Name = "Shell Bump", --This needs to be better
	Description = "Push all adjacent tiles.",
	Damage = 0,
	Class = "Enemy",
	LaunchSound = "/weapons/science_repulse",
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,2),
		Enemy = Point(2,1),
		Enemy2 = Point(1,2),
		Building = Point(3,2),
		CustomPawn = "DNT_Ladybug1",
	}
}

DNT_LadybugAtk2 = DNT_LadybugAtk1:new{
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,2),
		Enemy = Point(2,1),
		Enemy2 = Point(1,2),
		Building = Point(3,2),
		CustomPawn = "DNT_Ladybug2",
	}
}

function DNT_LadybugAtk1:GetTargetArea(p1)
	local ret = PointList()
	ret:push_back(p1)
	return ret
end

function DNT_LadybugAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	ret:AddQueuedBounce(p1,-2)
	for i = DIR_START,DIR_END do
		local curr = p1 + DIR_VECTORS[i]
		local spaceDamage = SpaceDamage(curr, 0, i)

		--In case we have a shield friendly upgrade (alpha/boss)
		if self.ShieldFriendly and (Board:GetPawnTeam(curr) == TEAM_ENEMY) then
			spaceDamage.iShield = 1
		end

		spaceDamage.sAnimation = "airpush_"..i
		ret:AddQueuedDamage(spaceDamage)

		ret:AddQueuedBounce(curr,-1)
	end

	local selfDamage = SpaceDamage(p1,0)

	--In case we have a shield self upgrade (alpha/boss)
	if self.ShieldSelf then
		selfDamage.iShield = 1
	end

	selfDamage.sAnimation = "ExploRepulse2"
	ret:AddQueuedDamage(selfDamage)
	return ret
end


-----------
-- Pawns --
-----------

DNT_Ladybug1 = Pawn:new
	{
		Name = "Ladybug",
		Health = 3,
		MoveSpeed = 4,
		Image = "DNT_ladybug",
		SkillList = {"DNT_LadybugAtk1"},
		SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		PunishmentDamage = 1,
	}
AddPawn("DNT_Ladybug1")

DNT_Ladybug2 = Pawn:new
	{
		Name = "Alpha Ladybug",
		Health = 5,
		MoveSpeed = 4,
		SkillList = {"DNT_LadybugAtk2"},
		Image = "DNT_ladybug",
		SoundLocation = "/enemy/beetle_1/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
		PunishmentDamage = 2,
	}
AddPawn("DNT_Ladybug2")

-----------
-- Hooks --
-----------

--Ladybug Check
local function isLadybug(pawn)
	if pawn then
		local type = pawn:GetType()
		return type == "DNT_Ladybug1" or type == "DNT_Ladybug2"
	end
	return false
end

--Hook that baits mechs
local function SkillBuild(mission, pawn, weaponId, p1, p2, skillEffect)
	if pawn:GetTeam() == TEAM_PLAYER and pawn:IsMech() and weaponId ~= "DNT_LadybugBait" and not IsTipImage() then --?
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
				local punishmentDmg = 0
				for _,point in pairs(extract_table(areaPoints)) do
					if isLadybug(Board:GetPawn(point)) then
						skillEffect:AddScript([[
							local v = Point(]]..v:GetString()..[[)
							Board:Ping(v, GL_Color(255, 0, 0))
							Board:AddAlert(v, "DIDN'T TARGET")
						]])
						punishmentDmg = punishmentDmg + _G[Board:GetPawn(point):GetType()].PunishmentDamage

						local icon = SpaceDamage(point, 0)
						icon.sImageMark = "icons/DNT_ladybug_icon.png"
						skillEffect:AddDamage(icon)

					end
				end


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


--Load hooks
local this = {}

function this:load(DNT_Vextra_ModApiExt)
	local options = mod_loader.currentModContent[mod.id].options
	DNT_Vextra_ModApiExt:addSkillBuildHook(SkillBuild)

end

return this
