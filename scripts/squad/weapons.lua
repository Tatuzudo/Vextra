local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
local writepath = "img/weapons/"
local readpath = resourcePath .. writepath

local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end

local function DNT_hash(point) return point.x + point.y*10 end

----------------
--- Upgrades ---
----------------

local wt2 = {
	DNT_SS_SparkHurl_Upgrade1 = "+1 Damage",
	DNT_SS_SparkHurl_Upgrade2 = "+1 Damage",

	DNT_SS_SappingProboscis_Upgrade1 = "Acidic Spit",
	DNT_SS_SappingProboscis_Upgrade2 = "+1 Life Steal" ,

	DNT_SS_AcridSpray_Upgrade1 = "Extra Stink",
	DNT_SS_AcridSpray_Upgrade2 = "+2 Damage",
}
for k,v in pairs(wt2) do Weapon_Texts[k] = v end



-----------
--- Art ---
-----------
modApi:appendAsset(writepath.."DNT_SS_AcridSpray.png", readpath.."DNT_SS_AcridSpray.png")
modApi:appendAsset(writepath.."DNT_SS_SappingProboscis.png", readpath.."DNT_SS_SappingProboscis.png")
modApi:appendAsset(writepath.."DNT_SS_SparkHurl.png", readpath.."DNT_SS_SparkHurl.png")

--Layering it right on top of the previous smoke icon. If it becomes an issue, I can hide that icon with damage.bHide or whatever
--Opacity Layering might be an issue, so I'm using the non glowing one /shrug
modApi:appendAsset("img/combat/icons/DNT_icon_stink.png",resourcePath.."img/combat/icons/DNT_icon_stink.png")
	Location["combat/icons/DNT_icon_stink.png"] = Point(-8,11)
modApi:appendAsset("img/combat/icons/DNT_icon_stink_glow.png",resourcePath.."img/combat/icons/DNT_icon_stink_glow.png")
	Location["combat/icons/DNT_icon_stink_glow.png"] = Point(-10,9)
----------------
--- Stinkbug ---
----------------
-- weapon DNT_SS_AcridSpray
DNT_SS_AcridSpray = Skill:new {
  Name = "Acrid Spray",
  -- Description = "Strike a tile while placing short-lived stink clouds to both sides.",
  Description = "Strike a tile and place short-lived stink clouds to both sides.", -- tatu change
  Damage = 1,
  Class = "TechnoVek",
  SoundBase = "/enemy/mosquito_1",
  Icon = "weapons/DNT_SS_AcridSpray.png",
  --LaunchSound = "/weapons/titan_fist",
  PathSize = 1,
  FartRange = 1,
  PowerCost = 0,
  Upgrades = 2,
  --UpgradeList = {Extra Stink, +2 Damage},
  UpgradeCost = {2,3},
  CustomTipImage = "DNT_SS_AcridSpray_Tip",
  TipImage = {
    Unit = Point(2,2),
		Target = Point(2,1),
		Mountain = Point(1,2),
		Enemy = Point(3,2),
		Enemy2 = Point(2,1),
		CustomPawn = "DNT_StinkbugMech",
  },
}

function DNT_SS_AcridSpray:GetSkillEffect(p1,p2)
  local ret = SkillEffect()
  local dir = GetDirection(p2 - p1)
  local mission = GetCurrentMission()
  if not mission then LOG("@NamesAreHard on Discord if you see this thank you") end
  if not mission.DNT_FartList then mission.DNT_FartList = {} end

	local damage = SpaceDamage(p2,self.Damage,dir) -- attack
  damage.sAnimation = "explomosquito_"..dir
  damage.sSound = self.SoundBase.."/attack"
  ret:AddMelee(p1,damage,NO_DELAY)

  local L = true
  local R = true
  local FartAppear = IsPassiveSkill("Electric_Smoke") and "DNT_FartAppearDark" or "DNT_FartAppear"
  for i = 1, self.FartRange do
    if L then
      local dir2 = dir+1 > 3 and 0 or dir+1
      local p3 = p1 + DIR_VECTORS[dir2]*i
      -- ret:AddScript(string.format("table.insert(GetCurrentMission().DNT_FartList,%s)",p3:GetString())) -- insert point in fart list
	  ret:AddScript("GetCurrentMission().DNT_FartList["..DNT_hash(p3).."] = "..p3:GetString()) -- insert point in fart list
      local damage = SpaceDamage(p3,0) -- smoke
      damage.sAnimation = FartAppear
      damage.iSmoke = EFFECT_CREATE
			damage.sImageMark = "combat/icons/DNT_icon_stink.png"
      ret:AddDamage(damage)
      -- if Board:IsBlocked(p3,PATH_PROJECTILE) and not Board:IsPawnSpace(p3) then L = false end
    end
    if R then
      local dir3 = dir-1 < 0 and 3 or dir-1
      local p4 = p1 + DIR_VECTORS[dir3]*i
      -- ret:AddScript(string.format("table.insert(GetCurrentMission().DNT_FartList,%s)",p4:GetString())) -- insert other fart point
	  ret:AddScript("GetCurrentMission().DNT_FartList["..DNT_hash(p4).."] = "..p4:GetString()) -- insert point in fart list
      local damage = SpaceDamage(p4,0) -- smoke
      damage.sAnimation = FartAppear
      damage.iSmoke = EFFECT_CREATE
			damage.sImageMark = "combat/icons/DNT_icon_stink.png"
      ret:AddDamage(damage)
      -- if Board:IsBlocked(p4,PATH_PROJECTILE) and not Board:IsPawnSpace(p4) then R = false end
    end
    ret:AddDelay(0.1)
  end

  ret:AddDelay(0.24) -- delay for adding smoke anim (hook)

  return ret
end

DNT_SS_AcridSpray_A = DNT_SS_AcridSpray:new{
	CustomTipImage = "DNT_SS_AcridSpray_A_Tip",
	-- UpgradeDescription = "Stink clouds extend to both sides infinitely until hitting an object.",
	UpgradeDescription = "Places another stink cloud to both sides.",
	FartRange = 2,
}

DNT_SS_AcridSpray_B = DNT_SS_AcridSpray:new{
	CustomTipImage = "DNT_SS_AcridSpray_B_Tip",
	UpgradeDescription = "Increases damage by 2.",
	Damage = 3,
}

DNT_SS_AcridSpray_AB = DNT_SS_AcridSpray:new{
	CustomTipImage = "DNT_SS_AcridSpray_AB_Tip",
	FartRange = 2,
	Damage = 3,
}


DNT_SS_AcridSpray_Tip = DNT_SS_AcridSpray:new{}
DNT_SS_AcridSpray_A_Tip = DNT_SS_AcridSpray_Tip:new{
	FartRange = 2,
}
DNT_SS_AcridSpray_B_Tip = DNT_SS_AcridSpray_Tip:new{
	Damage = 3,
}
DNT_SS_AcridSpray_AB_Tip = DNT_SS_AcridSpray_Tip:new{
	FartRange = 2,
	Damage = 3,
}

function DNT_SS_AcridSpray_Tip:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	
	local dir2 = dir+1 > 3 and 0 or dir+1
	local p3 = p1 + DIR_VECTORS[dir2]

	local dir3 = dir-1 < 0 and 3 or dir-1
	local p4 = p1 + DIR_VECTORS[dir3]
	
	local anim1 = IsPassiveSkill("Electric_Smoke") and "DNT_FartFrontDark" or "DNT_FartFront"
	local anim2 = IsPassiveSkill("Electric_Smoke") and "DNT_FartBackDark" or "DNT_FartBack"
	local anim3 = IsPassiveSkill("Electric_Smoke") and "DNT_FartAppearDark" or "DNT_FartAppear"
	
	local damage = SpaceDamage(p2,self.Damage) -- attack
	damage.sAnimation = "explomosquito_"..dir
	damage.sSound = self.SoundBase.."/attack"
	ret:AddQueuedMelee(p1,damage)

	damage = SpaceDamage(p3,0) -- smoke
	damage.sAnimation = anim3
	damage.iSmoke = EFFECT_CREATE
	ret:AddDamage(damage)
	damage.loc = p4
	ret:AddDamage(damage)

	ret:AddDelay(0.24) -- delay for adding smoke anim
	damage = SpaceDamage(p3,0) -- smoke
	damage.sAnimation = anim1
	ret:AddDamage(damage)
	damage.sAnimation = anim2
	ret:AddDamage(damage)
	damage.loc = p4
	damage.sAnimation = anim1
	ret:AddDamage(damage)
	damage.sAnimation = anim2
	ret:AddDamage(damage)
	
	if self.FartRange > 1 then -- for the boss
		for i = 1, 1 do
			damage = SpaceDamage(p3 + DIR_VECTORS[dir2]*i,0) -- smoke
			damage.sAnimation = anim3
			damage.iSmoke = EFFECT_CREATE
			ret:AddDamage(damage)
			damage.loc = p4 + DIR_VECTORS[dir3]*i,0
			ret:AddDamage(damage)
			ret:AddDelay(0.24) -- delay for adding smoke anim
			damage.loc = p3 + DIR_VECTORS[dir2]*i,0
			damage.sAnimation = anim1
			ret:AddDamage(damage)
			damage.sAnimation = anim2
			ret:AddDamage(damage)
			damage.loc = p4 + DIR_VECTORS[dir3]*i,0
			damage.sAnimation = anim1
			ret:AddDamage(damage)
			damage.sAnimation = anim2
			ret:AddDamage(damage)
		end
	end
	
	ret:AddDelay(0.4) -- prolong the animation for Tip
	damage.loc = p4
	damage.sAnimation = anim1
	ret:AddDamage(damage)
	damage.sAnimation = anim2
	ret:AddDamage(damage)
	damage.loc = p3
	damage.sAnimation = anim1
	ret:AddDamage(damage)
	damage.sAnimation = anim2
	ret:AddDamage(damage)
	
	if self.FartRange > 1 then -- for the boss
		for i = 1, 1 do
			damage.loc = p3 + DIR_VECTORS[dir2]*i
			damage.sAnimation = anim1
			ret:AddDamage(damage)
			damage.sAnimation = anim2
			ret:AddDamage(damage)
			damage.loc = p4 + DIR_VECTORS[dir3]*i
			damage.sAnimation = anim1
			ret:AddDamage(damage)
			damage.sAnimation = anim2
			ret:AddDamage(damage)
		end
	end
	
	return ret
end

-----------
--- Fly ---
-----------
-- weapon DNT_SS_SappingProboscis
DNT_SS_SappingProboscis = Skill:new {
  Name = "Sapping Proboscis",
  Description = "Shoots a projectile that steals health from the target and pulls.",
  Damage = 1,
  Heal = 1,
	Acid = 0,
  Class = "TechnoVek",
  Icon = "weapons/DNT_SS_SappingProboscis.png",
  ImpactSound = "/enemy/moth_1/attack_impact",
	LaunchSound = "/enemy/moth_1/attack_launch",
  Projectile = "effects/shotup_crab2.png",
  PathSize = 8,
  PowerCost = 0,
  Upgrades = 2,
  --UpgradeList = {Acid, +1 Life Steal},
  UpgradeCost = {1,2},
  TipImage = {
		Unit_Damaged = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(2,1),
		CustomPawn = "DNT_FlyMech",
	},
}

function DNT_SS_SappingProboscis:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local p3 = GetProjectileEnd(p1,p2)
	local dir = GetDirection(p1 - p2)

	local damage = SpaceDamage(p3,self.Damage,dir)
	damage.iAcid = self.Acid
	ret:AddDamage(damage)

	-- ret:AddQueuedProjectile(SpaceDamage(p3),self.LaserArt)
	ret:AddProjectile(p3,SpaceDamage(p1),"effects/shot_firefly2",NO_DELAY)
	ret:AddDelay(p1:Manhattan(p3)*0.1)
	if Board:IsPawnSpace(p3) or Board:IsPowered(p3) then
    local heal = SpaceDamage(p1,-self.Heal)
    ret:AddDamage(heal)
	end

	return ret
end

DNT_SS_SappingProboscis_A = DNT_SS_SappingProboscis:new{
	UpgradeDescription = "Adds A.C.I.D. to the attack.",
	Acid = 1,
}

DNT_SS_SappingProboscis_B = DNT_SS_SappingProboscis:new{
	UpgradeDescription = "Increases damage and healing by 1.",
	Damage = 2,
	Heal = 2,
}

DNT_SS_SappingProboscis_AB = DNT_SS_SappingProboscis:new{
	Acid = 1,
	Damage = 2,
	Heal = 2,
}


-----------------
--- Dragonfly ---
-----------------
-- weapon DNT_SS_SparkHurl
DNT_SS_SparkHurl = LineArtillery:new {
  Name = "Spark Hurl",
  --Description = "Hurl sparks that pushes the target. If there's smoke, it explodes in a T shape outwards, igniting and damaging targets. Otherwise, it only ignites the target doing one less damage.",
  Description = "Artillery that push, damage and ignite the target. Explode smoke tiles in a T shape.", -- tatu change
  Damage = 1,
  Fire = 1,
  Class = "TechnoVek",
  Icon = "weapons/DNT_SS_SparkHurl.png",
  ArtillerySize = 8,
  PowerCost = 0,
  Upgrades = 2,
  Explosion = "",
  UpShot = "effects/shotup_ignite_fireball.png",
  --UpgradeList = {+1 Damage, +1 Damage},
  -- UpgradeCost = {1,3}
  UpgradeCost = {2,3}, -- tatu change
  TipImage = {
		Unit = Point(2,4),
		Target = Point(2,2),
		Enemy = Point(2,2),
		Building = Point(3,1),
		Enemy2 = Point(1,1),
		Second_Origin = Point(2,4),
		Second_Target = Point(2,1),
		CustomPawn = "DNT_DragonflyMech",
	}
}

function DNT_SS_SparkHurl:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2-p1)
	local damage = nil

	if IsTipImage() and p2 == Point(2,2) then --Tip Image Stuff
		damage = SpaceDamage(p2,0)
		damage.iSmoke = 1 --Create
		Board:DamageSpace(damage)
	end

	--Sound
	ret:AddScript("Game:TriggerSound('/weapons/fireball')")
	if Board:IsSmoke(p2) or (IsTipImage() and p2 == Point(2,2)) then -- or Game:GetTeamTurn() == TEAM_ENEMY then
		damage = SpaceDamage(p2,self.Damage,dir)
		damage.iSmoke = 2 --Disperse
		damage.iFire = self.Fire
		damage.sSound = "/weapons/flamespreader"
		damage.sAnimation = "explopush2_"..dir
		ret:AddArtillery(damage, self.UpShot, NO_DELAY)
		ret:AddDelay(0.8)
		for i= -1, 1 do
			local target = p2 + DIR_VECTORS[dir] + DIR_VECTORS[(dir+1)%4]*i
			if Board:IsValid(target) then
				damage = SpaceDamage(target,self.Damage)
				damage.iFire = self.Fire
				damage.sAnimation = "ExploAir1"
				ret:AddDamage(damage)
			end
		end
	else
		-- damage = SpaceDamage(p2,self.Damage-1,dir)
		damage = SpaceDamage(p2,self.Damage,dir)  -- tatu change
		damage.iFire = self.Fire
		damage.sSound = "/weapons/flamespreader"
		damage.sAnimation = "ExploRaining1"
		ret:AddArtillery(damage, self.UpShot, FULL_DELAY)
	end
	return ret
end

DNT_SS_SparkHurl_A = DNT_SS_SparkHurl:new{
	UpgradeDescription = "Increases damage by 1.",
	Damage = 2,
}

DNT_SS_SparkHurl_B = DNT_SS_SparkHurl:new{
	UpgradeDescription = "Increases damage by 1.",
	Damage = 2,
}

DNT_SS_SparkHurl_AB = DNT_SS_SparkHurl:new{
	Damage = 3,
}
