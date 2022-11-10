local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
--local previewer = require(scriptPath.."weaponPreview/api")

local writepath = "img/units/aliens/"
local readpath = resourcePath .. writepath
local imagepath = writepath:sub(5,-1)
local a = ANIMS

local this = {}

local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end

-------------
--  Icons  --
-------------

-------------
--   Art   --
-------------

local name = "dragonfly" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
--modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

-- local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -23, PosY = -10} -- old 50x50
local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -28, PosY = -15} --60x60
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -28, PosY = -15, NumFrames = 14} --60x60

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_dragonfly = base
a.DNT_dragonflye = baseEmerge
a.DNT_dragonflya = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 8 }
a.DNT_dragonflyd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 10, Time = .12 } --Numbers copied for now
--a.DNT_namew = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png"} --Only if there's a boss



-------------
-- Weapons --
-------------

DNT_DragonflyAtk1 = Skill:new {
	Name = "Spark Burst", --Make this better
	Description = "Smoke the target, preparing to explode the smoke. If there's smoke, it explodes in a T shape. Otherwise, it just hits the target with fire.",
	Damage = 1,
	Class = "Enemy",
	PathSize = 1,
	LaunchSound = "",
	Fire = 1,
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,3),
		Target = Point(2,2),
		--Smoke = Point(2,2),
		Enemy = Point(2,2),
		Building = Point(3,1),
		Enemy2 = Point(1,1),
		Second_Origin = Point(2,3),
		Second_Target = Point(3,3),
		Enemy3 = Point(3,3),
		CustomPawn = "DNT_Dragonfly1",
	}
}


--[[
function DNT_DragonflyAtk1:GetTargetArea(p1)
	local ret = PointList()
	ret:push_back(p1)
	return ret
end
--]]
function DNT_DragonflyAtk1:GetTargetScore(p1,p2)
	this.isTargetScore = true
	local ret = Skill.GetTargetScore(self, p1, p2)
	this.isTargetScore = nil

	local pawn = Board:GetPawn(p2)
	if pawn and pawn:GetTeam() == TEAM_ENEMY then
		ret = 0
	elseif pawn and pawn:GetTeam() == TEAM_PLAYER then
		ret = ret + 1
	end

	return ret
end


function DNT_DragonflyAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2-p1)
	local backdir = GetDirection(p1-p2)
	local damage = nil

	--Only create smoke if it's the enemies turn (displacement replays the GetSkillEffect(), this makes it not create smoke again)
	--and it's not getting target score. Although it is fun that way
	--LOG(Game:GetTeamTurn() == TEAM_ENEMY)
	--If this gets pushed during the enemy turn, we're going to have problems

	if not IsTipImage() then -- I want to only put down smoke for the first example attack
		damage = SpaceDamage(p2,0)
		damage.iSmoke = 1 --Create
		ret:AddDamage(damage)
	else --Tip Image Magic
		if p2 == Point(2,2) then
			damage = SpaceDamage(p2,0)
			damage.iSmoke = 1 --Create
			ret:AddDamage(damage)
		end
	end

	--[[
	if not this.isTargetScore and Game:GetTeamTurn() == TEAM_ENEMY then
		--I believe the false here makes it play the animation. I'm surprised that's not default
		Board:SetSmoke(p2,true,false) --This might create unwanted smoke at unwanted times but we'll see YES
	end
	--]]

	if Board:IsSmoke(p2) or this.isTargetScore or (IsTipImage() and  p2 == Point(2,2)) then -- or Game:GetTeamTurn() == TEAM_ENEMY then
		damage = SpaceDamage(p2,self.Damage)
		damage.iSmoke = 2 --Disperse
		damage.iFire = self.Fire
		damage.sSound = "/weapons/flamespreader"
		damage.sAnimation = "explopush2_"..dir
		ret:AddQueuedDamage(damage)
		for i= -1, 1 do
			local target = p2 + DIR_VECTORS[dir] + DIR_VECTORS[(dir+1)%4]*i
			if Board:IsValid(target) then
				damage = SpaceDamage(target,self.Damage)
				damage.iFire = self.Fire
				damage.sAnimation = "ExploAir1"
				ret:AddQueuedDamage(damage)
			end
		end
	else
		damage = SpaceDamage(p2,self.Damage)
		damage.iFire = self.Fire
		damage.sSound = "/weapons/flamespreader"
		damage.sAnimation = "ExploRaining1"
		ret:AddQueuedDamage(damage)
	end
	return ret
end

DNT_DragonflyAtk2 = DNT_DragonflyAtk1:new {
	Name = "Spark Explosion",
	Damage = 3, --I think this upgrade could use a little omph
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,3),
		Target = Point(2,2),
		--Smoke = Point(2,2),
		Enemy = Point(2,2),
		Building = Point(3,1),
		Enemy2 = Point(1,1),
		Second_Origin = Point(2,3),
		Second_Target = Point(3,3),
		Enemy3 = Point(3,3),
		CustomPawn = "DNT_Dragonfly2",
	}
}

--Boss Weapon is complicated/different enough to have its own code
DNT_DragonflyAtkB = LineArtillery:new {
	Name = "Launch Sparks",
	Description = "Smoke a line to the target, preparing to launch an explosive artillery. If there's smoke, it explodes in a T shape. Otherwise, it just hits the target with fire.",
	Damage = 2,
	Class = "Enemy",
	Explosion = "",
	ArtillerySize = 3,
	PathSize = 1,
	LaunchSound = "",
	Fire = 1,
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,4),
		Target = Point(2,2),
		Enemy = Point(2,2),
		Building = Point(3,1),
		Enemy2 = Point(1,1),
		Second_Origin = Point(2,4),
		Second_Target = Point(2,1),
		CustomPawn = "DNT_DragonflyBoss",
	}
}

function DNT_DragonflyAtkB:GetTargetScore(p1,p2)
	this.isTargetScore = true
	local ret = Skill.GetTargetScore(self, p1, p2)
	this.isTargetScore = nil

	local dir = GetDirection(p2-p1)
	local target = p1
	--All Smokes
	while (target ~= p2 and Board:IsValid(target)) do --Board:IsValid just in case
		target = target + DIR_VECTORS[dir]
		local pawn = Board:GetPawn(target)
		if pawn and pawn:GetTeam() == TEAM_ENEMY then
			ret = ret - 12 --Highly discourage smoking teammates
		elseif pawn and pawn:GetTeam() == TEAM_PLAYER then
			ret = ret + 1
		end
	end

	return ret
end

function DNT_DragonflyAtkB:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2-p1)
	local damage = nil
	--local backdir = GetDirection(p1-p2)

	if IsTipImage() and p2 == Point(2,2) then --Tip Image Stuff
		damage = SpaceDamage(p2,0)
		damage.iSmoke = 1 --Create
		ret:AddDamage(damage)
		damage.loc = Point(2,3)
		ret:AddDamage(damage)
	elseif not IsTipImage() then
		local target = p1
		damage = SpaceDamage(target,0)
		damage.iSmoke = 1 --Create
		while (target ~= p2 and Board:IsValid(target)) do --Board:IsValid just in case
			target = target + DIR_VECTORS[dir]
			damage.loc = target
			ret:AddDamage(damage)
		end
	end
	
	--Sound
	ret:AddQueuedScript("Game:TriggerSound('/weapons/fireball')")
	if Board:IsSmoke(p2) or this.isTargetScore or (IsTipImage() and  p2 == Point(2,2)) then -- or Game:GetTeamTurn() == TEAM_ENEMY then
		damage = SpaceDamage(p2,self.Damage)
		damage.iSmoke = 2 --Disperse
		damage.iFire = self.Fire
		damage.sSound = "/weapons/flamespreader"
		damage.sAnimation = "explopush2_"..dir
		ret:AddQueuedArtillery(damage, "effects/shotup_ignite_fireball.png", NO_DELAY)
		ret:AddQueuedDelay(0.8)
		for i= -1, 1 do
			local target = p2 + DIR_VECTORS[dir] + DIR_VECTORS[(dir+1)%4]*i
			if Board:IsValid(target) then
				damage = SpaceDamage(target,self.Damage)
				damage.iFire = self.Fire
				damage.sAnimation = "ExploAir1"
				ret:AddQueuedDamage(damage)
			end
		end
	else
		damage = SpaceDamage(p2,self.Damage)
		damage.iFire = self.Fire
		damage.sSound = "/weapons/flamespreader"
		damage.sAnimation = "ExploRaining1"
		ret:AddQueuedArtillery(damage, "effects/shotup_ignite_fireball.png", FULL_DELAY)
	end
	return ret
end




-----------
-- Pawns --
-----------

DNT_Dragonfly1 = Pawn:new
	{
		Name = "Dragonfly",
		Health = 2,
		MoveSpeed = 4,
		Flying = true,
		Image = "DNT_dragonfly", --change
		SkillList = {"DNT_DragonflyAtk1"},
		SoundLocation = "/enemy/hornet_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
	}
AddPawn("DNT_Dragonfly1")

DNT_Dragonfly2 = Pawn:new
	{
		Name = "Alpha Dragonfly",
		Health = 4,
		MoveSpeed = 4,
		Flying = true,
		SkillList = {"DNT_DragonflyAtk2"},
		Image = "DNT_dragonfly", --change
		SoundLocation = "/enemy/hornet_1/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_Dragonfly2")

DNT_DragonflyBoss = Pawn:new
	{
		Name = "Dragonfly Leader",
		Health = 6,
		MoveSpeed = 3,
		Flying = true,
		Ranged = 1,
		SkillList = {"DNT_DragonflyAtkB"},
		Image = "DNT_dragonfly", --change
		SoundLocation = "/enemy/hornet_1/",
		ImageOffset = 2,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_BOSS,
		Massive = true,
	}
AddPawn("DNT_DragonflyBoss")


-----------
-- Hooks --
-----------
--UNCOMMENT if you need it
--[[


function this:load(NAH_MechTaunt_ModApiExt)
	local options = mod_loader.currentModContent[mod.id].options
	NAH_MechTaunt_ModApiExt:addSkillBuildHook(SkillBuild) --EXAMPLE

end

return this
--]]
