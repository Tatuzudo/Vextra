local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
--local previewer = require(scriptPath.."weaponPreview/api")

local writepath = "img/units/aliens/"
local readpath = resourcePath .. writepath
local imagepath = writepath:sub(5,-1)
local a = ANIMS

local customAnim = require(scriptPath .."libs/customAnim")

local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end


-------------
--  Icons  --
-------------

-------------
--   Art   --
-------------

local name = "stinkbug" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -26, PosY = -3}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -26, PosY = -3, NumFrames = 10}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_stinkbug = base
a.DNT_stinkbuge = baseEmerge
a.DNT_stinkbuga = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
a.DNT_stinkbugd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 9, Time = .14 } --Numbers copied for now
a.DNT_stinkbugw = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png", PosY = 2} --Only if there's a boss


local effectsPath = resourcePath .."img/effects/"

local files = {
	"fart_appear.png",
	"fart_front.png",
	"fart_back.png",
	"fart_appear_dark.png",
	"fart_front_dark.png",
	"fart_back_dark.png",
}

-- iterate our files and add the assets so the game can find them.
for _, file in ipairs(files) do
	modApi:appendAsset("img/effects/" .. file, effectsPath .. file)
end

a.DNT_FartAppear = Animation:new{
	Image = "effects/fart_appear.png",
	NumFrames = 6,
	Loop = false,
	Time = 0.04,
	PosX = -23,
	PosY = 0,
}

a.DNT_FartAppearDark = a.DNT_FartAppear:new{
	Image = "effects/fart_appear_dark.png",
}

a.DNT_FartFront = Animation:new{
	Image = "effects/fart_front.png",
	NumFrames = 6,
	Loop = false,
	PosX = -23,
	PosY = 0,
	Time = 0.4
}

a.DNT_FartFrontDark = a.DNT_FartFront:new{
	Image = "effects/fart_front_dark.png",
}

a.DNT_FartBack = a.DNT_FartFront:new{
	Image = "effects/fart_back.png",
	Layer = ANIMS.LAYER_LESS_BACK
}

a.DNT_FartBackDark = a.DNT_FartBack:new{
	Image = "effects/fart_back_dark.png",
}

-----------------
--  Portraits  --
-----------------

local ptname = "Stinkbug"
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."1.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."1.png")
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."2.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."2.png")
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."Boss.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."Boss.png")

-------------
-- Weapons --
-------------

DNT_StinkbugAtk1 = Skill:new {
	Name = "Acrid Spray",
	Description = "Prepares to attack while surrounding itself with short-lived stink clouds.",
	Damage = 1,
	Class = "Enemy",
	LaunchSound = "",
	PathSize = 1,
	FartRange = 1,
	Icon = "weapons/enemy_leaper1.png",
	SoundBase = "/enemy/mosquito_1",
	CustomTipImage = "DNT_StinkbugAtk_Tip",
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy = Point(1,2),
		Building = Point(2,1),
		CustomPawn = "DNT_Stinkbug1",
	}
}

DNT_StinkbugAtk2 = DNT_StinkbugAtk1:new {
	Name = "Noxious Spray",
	Damage = 3,
	CustomTipImage = "DNT_StinkbugAtk2_Tip",
}

DNT_StinkbugAtkBoss = DNT_StinkbugAtk1:new {
	Name = "Abhorrent Spray",
	Description = "Prepares to attack while surrounding itself with lines of short-lived stink clouds.",
	Damage = 3,
	FartRange = 8,
	CustomTipImage = "DNT_StinkbugAtkBoss_Tip",
}

function DNT_StinkbugAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local mission = GetCurrentMission()
    if not mission.DNT_FartList then mission.DNT_FartList = {} end
	
	local L = true
	local R = true
	local FartAppear = IsPassiveSkill("Electric_Smoke") and "DNT_FartAppearDark" or "DNT_FartAppear"
	for i = 1, self.FartRange do
		if L then
			local dir2 = dir+1 > 3 and 0 or dir+1
			local p3 = p1 + DIR_VECTORS[dir2]*i
			ret:AddScript(string.format("table.insert(GetCurrentMission().DNT_FartList,%s)",p3:GetString())) -- insert point in fart list
			local damage = SpaceDamage(p3,0) -- smoke
			damage.sAnimation = FartAppear
			damage.iSmoke = EFFECT_CREATE
			ret:AddDamage(damage)
			if Board:IsBlocked(p3,PATH_PROJECTILE) and not Board:IsPawnSpace(p3) then L = false end
		end
		if R then
			local dir3 = dir-1 < 0 and 3 or dir-1
			local p4 = p1 + DIR_VECTORS[dir3]*i
			ret:AddScript(string.format("table.insert(GetCurrentMission().DNT_FartList,%s)",p4:GetString())) -- insert other fart point
			local damage = SpaceDamage(p4,0) -- smoke
			damage.sAnimation = FartAppear
			damage.iSmoke = EFFECT_CREATE
			ret:AddDamage(damage)
			if Board:IsBlocked(p4,PATH_PROJECTILE) and not Board:IsPawnSpace(p4) then R = false end
		end
		ret:AddDelay(0.1)
	end
	
	local damage = SpaceDamage(p2,self.Damage) -- attack
	damage.sAnimation = "explomosquito_"..dir
	damage.sSound = self.SoundBase.."/attack"
	ret:AddQueuedMelee(p1,damage)
	
	ret:AddDelay(0.24) -- delay for adding smoke anim (hook)

	return ret
end

function DNT_StinkbugAtk1:GetTargetScore(p1,p2)
	local ret = Skill.GetTargetScore(self, p1, p2)
	local dir = GetDirection(p2 - p1)

	local dir2 = dir+1 > 3 and 0 or dir+1
	local p3 = p1 + DIR_VECTORS[dir2]
	if self.FartRange > 1 then p3 = GetProjectileEnd(p1,p3) end
	local pawn3 = Board:GetPawn(p3)

	local dir3 = dir-1 < 0 and 3 or dir-1
	local p4 = p1 + DIR_VECTORS[dir3]
	if self.FartRange > 1 then p4 = GetProjectileEnd(p1,p4) end
	local pawn4 = Board:GetPawn(p4)

	local order = extract_table(Board:GetPawns(TEAM_ENEMY))
	local selfOrder = 0
	local pawn3Order = 0
	local pawn4Order = 0

	for i = 1, #order do -- get attack order
		if Board:GetPawn(p1) and order[i] == Board:GetPawn(p1):GetId() then
			selfOrder = i
		elseif pawn3 and order[i] == pawn3:GetId() then
			pawn3Order = i
		elseif pawn4 and order[i] == pawn4:GetId() then
			pawn4Order = i
		end
	end

	if pawn3 then
		if pawn3:GetTeam() == TEAM_ENEMY and pawn3Order < selfOrder then -- avoid smoke friends that already attacked.
			ret = ret - 4
		-- elseif pawn3:GetTeam() == TEAM_PLAYER then -- try to fart on mechs if possible
			-- ret = ret + 2
		end
	end

	if pawn4 then
		if pawn4:GetTeam() == TEAM_ENEMY and pawn4Order < selfOrder then  -- avoid smoke friends that already attacked.
			ret = ret - 4
		-- elseif pawn4:GetTeam() == TEAM_PLAYER then  -- try to fart on mechs if possible
			-- ret = ret + 2
		end
	end

    return ret
end

--CustomTip

DNT_StinkbugAtk_Tip = DNT_StinkbugAtk1:new{}
DNT_StinkbugAtk2_Tip = DNT_StinkbugAtk_Tip:new {
	Damage = DNT_StinkbugAtk2.Damage,
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy = Point(1,2),
		Building = Point(2,1),
		CustomPawn = "DNT_Stinkbug2",
	}
}
DNT_StinkbugAtkBoss_Tip = DNT_StinkbugAtk_Tip:new {
	Damage = DNT_StinkbugAtkBoss.Damage,
	FartRange = 8,
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy = Point(1,2),
		Building = Point(2,1),
		CustomPawn = "DNT_StinkbugBoss",
	}
}

function DNT_StinkbugAtk_Tip:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	
	local dir2 = dir+1 > 3 and 0 or dir+1
	local p3 = p1 + DIR_VECTORS[dir2]

	local dir3 = dir-1 < 0 and 3 or dir-1
	local p4 = p1 + DIR_VECTORS[dir3]
	
	local anim1 = IsPassiveSkill("Electric_Smoke") and "DNT_FartFrontDark" or "DNT_FartFront"
	-- local anim2 = IsPassiveSkill("Electric_Smoke") and "DNT_FartBackDark" or "DNT_FartBack"
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
	damage.loc = p4
	ret:AddDamage(damage)
	
	if self.FartRange > 1 then -- for the boss
		for i = 1, 2 do
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
			damage.sAnimation = anim1
			ret:AddDamage(damage)
			damage.loc = p4 + DIR_VECTORS[dir3]*i
			ret:AddDamage(damage)
		end
	end
	
	return ret
end

-----------
-- Pawns --
-----------

DNT_Stinkbug1 = Pawn:new
	{
		Name = "Stinkbug",
		Description = "Description",
		Health = 2,
		MoveSpeed = 3,
		Image = "DNT_stinkbug", --Image = "DNT_stinkbug" --lowercase
		SkillList = {"DNT_StinkbugAtk1"},
		SoundLocation = "/enemy/scarab_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
	}
AddPawn("DNT_Stinkbug1")

DNT_Stinkbug2 = Pawn:new
	{
		Name = "Alpha Stinkbug",
		Health = 4,
		MoveSpeed = 3,
		SkillList = {"DNT_StinkbugAtk2"},
		Image = "DNT_stinkbug", --Image = "DNT_stinkbug",
		SoundLocation = "/enemy/scarab_2/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_Stinkbug2")

DNT_StinkbugBoss = Pawn:new
	{
		Name = "Stinkbug Leader",
		Health = 5,
		MoveSpeed = 3,
		SkillList = {"DNT_StinkbugAtkBoss"},
		Image = "DNT_stinkbug", --Image = "DNT_stinkbug",
		SoundLocation = "/enemy/scarab_2/",
		ImageOffset = 2,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
		Massive = true
	}
AddPawn("DNT_StinkbugBoss")

-----------
-- Hooks --
-----------

local reFart = 20 --timer

local HOOK_MissionUpdate = function(mission)
	if mission and mission.DNT_FartList then
		local farts = mission.DNT_FartList
		if farts then
			local anim1 = IsPassiveSkill("Electric_Smoke") and "DNT_FartFrontDark" or "DNT_FartFront"
			local anim2 = IsPassiveSkill("Electric_Smoke") and "DNT_FartBackDark" or "DNT_FartBack"
			local anim3 = IsPassiveSkill("Electric_Smoke") and "DNT_FartAppearDark" or "DNT_FartAppear"
			for i = 1, #farts do
				if Board:IsSmoke(farts[i]) then -- add effects on tiles with smoke
					if reFart == 1 then -- remove first when loading game
						customAnim:Rem(mission,farts[i],anim1)
						customAnim:Rem(mission,farts[i],anim2)
					end
					if not customAnim:Is(mission,farts[i],anim1) then
						customAnim:Add(mission,farts[i],anim1)
						customAnim:Add(mission,farts[i],anim2)
					end
				elseif customAnim:Is(mission,farts[i],anim1) then  -- remove effects on tiles without smoke
					customAnim:Rem(mission,farts[i],anim1)
					customAnim:Rem(mission,farts[i],anim2)
					Board:AddAnimation(farts[i],anim3,ANIM_REVERSE)
				end
			end
			if reFart > 0 then
				reFart = reFart - 1
			end
		end
	end
end

local HOOK_resetTurn = function(mission) -- reset reFart
	reFart = 20
end

local HOOK_nextTurn = function(mission) -- delete farts after all the vek attack
	local farts = mission.DNT_FartList
	if not IsTipImage() then
		if Game:GetTeamTurn() == TEAM_ENEMY and farts then
			local anim1 = IsPassiveSkill("Electric_Smoke") and "DNT_FartFrontDark" or "DNT_FartFront"
			local anim2 = IsPassiveSkill("Electric_Smoke") and "DNT_FartBackDark" or "DNT_FartBack"
			local anim3 = IsPassiveSkill("Electric_Smoke") and "DNT_FartAppearDark" or "DNT_FartAppear"
			for i = 1, #farts do
				if Board:IsSmoke(farts[i]) and customAnim:Is(mission,farts[i],anim1) then -- only delete farts, not normal smoke
					Board:SetSmoke(farts[i],false,false)
					customAnim:Rem(mission,farts[i],anim1)
					customAnim:Rem(mission,farts[i],anim2)
					Board:AddAnimation(farts[i],anim3,ANIM_REVERSE)
				end
			end
			mission.DNT_FartList = {}
		end
	end
end

local HOOK_MissionEnd = function(mission) -- delete farts on mission end
	local farts = mission.DNT_FartList
	if farts then
		local anim1 = IsPassiveSkill("Electric_Smoke") and "DNT_FartFrontDark" or "DNT_FartFront"
		local anim2 = IsPassiveSkill("Electric_Smoke") and "DNT_FartBackDark" or "DNT_FartBack"
		local anim3 = IsPassiveSkill("Electric_Smoke") and "DNT_FartAppearDark" or "DNT_FartAppear"
		for i = 1, #farts do
			if Board:IsSmoke(farts[i]) then
				if customAnim:Is(mission,farts[i],anim1) then -- only delete farts, not normal smoke
					Board:SetSmoke(farts[i],false,false)
					customAnim:Rem(mission,farts[i],anim1)
					customAnim:Rem(mission,farts[i],anim2)
					Board:AddAnimation(farts[i],anim3,ANIM_REVERSE)
				end
			end
		end
	end
end

local function EVENT_onModsLoaded()
	DNT_Vextra_ModApiExt:addResetTurnHook(HOOK_resetTurn)
	modApi:addNextTurnHook(HOOK_nextTurn)
	modApi:addMissionUpdateHook(HOOK_MissionUpdate)
	modApi:addMissionEndHook(HOOK_MissionEnd)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
