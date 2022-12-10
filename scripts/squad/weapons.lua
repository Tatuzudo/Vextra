local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
local writepath = "img/weapons/"
local readpath = resourcePath .. writepath

local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end
-------------
--- Icons ---
-------------
modApi:appendAsset(writepath.."DNT_SS_AcridSpray.png", readpath.."DNT_SS_AcridSpray.png")
modApi:appendAsset(writepath.."DNT_SS_SappingProboscis.png", readpath.."DNT_SS_SappingProboscis.png")
modApi:appendAsset(writepath.."DNT_SS_SparkHurl.png", readpath.."DNT_SS_SparkHurl.png")

----------------
--- Stinkbug ---
----------------
-- weapon DNT_SS_AcridSpray
DNT_SS_AcridSpray = Skill:new {
  Name = "Acrid Spray",
  Description = "Strike a tile while placing short-lived stink clouds to both sides.",
  Damage = 1,
  Class = "TechnoVek",
  SoundBase = "/enemy/mosquito_1",
  Icon = "weapons/DNT_SS_AcridSpray.png",
  --LaunchSound = "/weapons/titan_fist",
  PathSize = 1,
  FartRange = 1,
  PowerCost = 0,
  Upgrades = 0,
  --UpgradeList = {},
  --UpgradeCost = {},
  CustomTipImage = "DNT_SS_AcridSpray_Tip",
  TipImage = {
    Unit = Point(2,2),
		Target = Point(2,1),
		Enemy = Point(1,2),
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

  local L = true
  local R = true
  for i = 1, self.FartRange do
    if L then
      local dir2 = dir+1 > 3 and 0 or dir+1
      local p3 = p1 + DIR_VECTORS[dir2]*i
      ret:AddScript(string.format("table.insert(GetCurrentMission().DNT_FartList,%s)",p3:GetString())) -- insert point in fart list
      local damage = SpaceDamage(p3,0) -- smoke
      damage.sAnimation = "DNT_FartAppear"
      damage.iSmoke = EFFECT_CREATE
      ret:AddDamage(damage)
      if Board:IsBlocked(p3,PATH_PROJECTILE) and not Board:IsPawnSpace(p3) then L = false end
    end
    if R then
      local dir3 = dir-1 < 0 and 3 or dir-1
      local p4 = p1 + DIR_VECTORS[dir3]*i
      ret:AddScript(string.format("table.insert(GetCurrentMission().DNT_FartList,%s)",p4:GetString())) -- insert other fart point
      local damage = SpaceDamage(p4,0) -- smoke
      damage.sAnimation = "DNT_FartAppear"
      damage.iSmoke = EFFECT_CREATE
      ret:AddDamage(damage)
      if Board:IsBlocked(p4,PATH_PROJECTILE) and not Board:IsPawnSpace(p4) then R = false end
    end
    ret:AddDelay(0.1)
  end

  local damage = SpaceDamage(p2,self.Damage,dir) -- attack
  damage.sAnimation = "explomosquito_"..dir
  damage.sSound = self.SoundBase.."/attack"
  ret:AddMelee(p1,damage)

  ret:AddDelay(0.24) -- delay for adding smoke anim (hook)

  return ret
end

DNT_SS_AcridSpray_Tip = DNT_SS_AcridSpray:new{}

function DNT_SS_AcridSpray_Tip:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)

	local dir2 = dir+1 > 3 and 0 or dir+1
	local p3 = p1 + DIR_VECTORS[dir2]

	local dir3 = dir-1 < 0 and 3 or dir-1
	local p4 = p1 + DIR_VECTORS[dir3]

	local damage = SpaceDamage(p2,self.Damage,dir) -- attack
  damage.sAnimation = "explomosquito_"..dir
  damage.sSound = self.SoundBase.."/attack"
	ret:AddMelee(p1,damage)

	damage = SpaceDamage(p3,0) -- smoke
	damage.sAnimation = "DNT_FartAppear"
	damage.iSmoke = EFFECT_CREATE
	ret:AddDamage(damage)
	damage.loc = p4
	ret:AddDamage(damage)

	ret:AddDelay(0.24) -- delay for adding smoke anim
	damage = SpaceDamage(p3,0) -- smoke
	damage.sAnimation = "DNT_FartFront"
	ret:AddDamage(damage)
	damage.loc = p4
	ret:AddDamage(damage)

	if self.FartRange > 1 then -- for the boss
		for i = 1, 2 do
			damage = SpaceDamage(p3 + DIR_VECTORS[dir2]*i,0) -- smoke
			damage.sAnimation = "DNT_FartAppear"
			damage.iSmoke = EFFECT_CREATE
			ret:AddDamage(damage)
			damage.loc = p4 + DIR_VECTORS[dir3]*i,0
			ret:AddDamage(damage)
			ret:AddDelay(0.24) -- delay for adding smoke anim
			damage.loc = p3 + DIR_VECTORS[dir2]*i,0
			damage.sAnimation = "DNT_FartFront"
			ret:AddDamage(damage)
			damage.loc = p4 + DIR_VECTORS[dir3]*i,0
			ret:AddDamage(damage)
		end
	end

	ret:AddDelay(0.4) -- prolong the animation for Tip
	damage.loc = p4
	ret:AddDamage(damage)
	damage.loc = p3
	ret:AddDamage(damage)

	if self.FartRange > 1 then -- for the boss
		for i = 1, 2 do
			damage.loc = p3 + DIR_VECTORS[dir2]*i
			damage.sAnimation = "DNT_FartFront"
			ret:AddDamage(damage)
			damage.loc = p4 + DIR_VECTORS[dir3]*i
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
  Class = "TechnoVek",
  Icon = "weapons/DNT_SS_SappingProboscis.png",
  ImpactSound = "/enemy/moth_1/attack_impact",
	LaunchSound = "/enemy/moth_1/attack_launch",
  Projectile = "effects/shotup_crab2.png",
  PathSize = 8,
  PowerCost = 0,
  Upgrades = 0,
  --UpgradeList = {},
  --UpgradeCost = {},
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

-----------------
--- Dragonfly ---
-----------------
-- weapon DNT_SS_SparkHurl
DNT_SS_SparkHurl = LineArtillery:new {
  Name = "Spark Hurl",
  Description = "Hurl sparks at a target with limited range. If there's smoke, it explodes in a T shape outwards, igniting and damaging targets. Otherwise, it only affects the target.",
  Damage = 1,
  Fire = 1,
  Class = "TechnoVek",
  Icon = "weapons/DNT_SS_SparkHurl.png",
  ArtillerySize = 3,
  PowerCost = 0,
  Upgrades = 0,
  Explosion = "",
  UpShot = "effects/shotup_ignite_fireball.png",
  --UpgradeList = {},
  --UpgradeCost = {},
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
		damage = SpaceDamage(p2,self.Damage)
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
		damage = SpaceDamage(p2,self.Damage)
		damage.iFire = self.Fire
		damage.sSound = "/weapons/flamespreader"
		damage.sAnimation = "ExploRaining1"
		ret:AddArtillery(damage, self.UpShot, FULL_DELAY)
	end
	return ret
end
