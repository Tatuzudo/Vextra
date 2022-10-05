local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
local previewer = require(scriptPath.."weaponPreview/api")

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

a.DNT_FartFront = Animation:new{
	Image = "effects/fart_front.png",
	NumFrames = 6,
	Loop = false,
	PosX = -23,
	PosY = 0,
	Time = 0.4
}

a.DNT_FartBack = a.DNT_FartFront:new{
	Image = "effects/fart_back.png",
}

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
	Icon = "weapons/enemy_leaper1.png",
	SoundBase = "/enemy/leaper_1",
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

function DNT_StinkbugAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local mission = GetCurrentMission()
    if not mission.DNT_FartList then mission.DNT_FartList = {} end

	local dir2 = dir+1 > 3 and 0 or dir+1
	local p3 = p1 + DIR_VECTORS[dir2]
	ret:AddScript(string.format("table.insert(GetCurrentMission().DNT_FartList,%s)",p3:GetString())) -- insert point in fart list

	local dir3 = dir-1 < 0 and 3 or dir-1
	local p4 = p1 + DIR_VECTORS[dir3]
	ret:AddScript(string.format("table.insert(GetCurrentMission().DNT_FartList,%s)",p4:GetString())) -- insert other fart point

	-- ret:AddScript(string.format("Board:AddAnimation(p3,'DNT_FartFront')",p4:GetString())) -- add fart animation

	local damage = SpaceDamage(p2,self.Damage) -- attack
	damage.sAnimation = "SwipeClaw2"
	damage.sSound = self.SoundBase.."/attack"
	ret:AddQueuedMelee(p1,damage)

	damage = SpaceDamage(p3,0) -- smoke
	-- damage.sAnimation = "airpush_"..dir2
	damage.sAnimation = "DNT_FartAppear"
	damage.iSmoke = EFFECT_CREATE
	ret:AddDamage(damage)
	damage.loc = p4
	-- damage.sAnimation = "airpush_"..dir3
	ret:AddDamage(damage)

	ret:AddDelay(0.24) -- delay for adding smoke anim (hook)

	return ret
end

function DNT_StinkbugAtk1:GetTargetScore(p1,p2)
  local ret = Skill.GetTargetScore(self, p1, p2)
	local dir = GetDirection(p2 - p1)

	local dir2 = dir+1 > 3 and 0 or dir+1
	local p3 = p1 + DIR_VECTORS[dir2]
	local pawn3 = Board:GetPawn(p3)

	local dir3 = dir-1 < 0 and 3 or dir-1
	local p4 = p1 + DIR_VECTORS[dir3]
	local pawn4 = Board:GetPawn(p4)

	if pawn3 then -- smoke enemies, avoid friends.
		if pawn3:GetTeam() == TEAM_ENEMY then
			ret = ret - 2
		elseif pawn3:GetTeam() == TEAM_PLAYER then
			ret = ret + 1
		end
	end

	if pawn4 then -- smoke enemies, avoid friends (other side)
		if pawn4:GetTeam() == TEAM_ENEMY then
			ret = ret - 2
		elseif pawn4:GetTeam() == TEAM_PLAYER then
			ret = ret + 1
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

function DNT_StinkbugAtk_Tip:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	--local mission = GetCurrentMission()
	--if not mission.DNT_FartList then mission.DNT_FartList = {} end

	local dir2 = dir+1 > 3 and 0 or dir+1
	local p3 = p1 + DIR_VECTORS[dir2]
	--ret:AddScript(string.format("table.insert(GetCurrentMission().DNT_FartList,%s)",p3:GetString())) -- insert point in fart list

	local dir3 = dir-1 < 0 and 3 or dir-1
	local p4 = p1 + DIR_VECTORS[dir3]
	--ret:AddScript(string.format("table.insert(GetCurrentMission().DNT_FartList,%s)",p4:GetString())) -- insert other fart point

	-- ret:AddScript(string.format("Board:AddAnimation(p3,'DNT_FartFront')",p4:GetString())) -- add fart animation

	local damage = SpaceDamage(p2,self.Damage) -- attack
	damage.sAnimation = "SwipeClaw2"
	damage.sSound = self.SoundBase.."/attack"
	ret:AddQueuedMelee(p1,damage)

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

	ret:AddDelay(0.4) -- prolong the animation for Tip
	ret:AddDamage(damage)
	damage.loc = p3
	ret:AddDamage(damage)

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
		SoundLocation = "/enemy/beetle_1/",
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
		SoundLocation = "/enemy/beetle_2/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
	}
AddPawn("DNT_Stinkbug2")


-----------
-- Hooks --
-----------

local reFart = true
local HOOK_MissionUpdate = function(mission) -- local HOOK_gameLoaded
	if mission and not IsTipImage() then -- avoid a mission var not available error
		if reFart then -- redo animations when game is loaded
			local farts = mission.DNT_FartList
			if farts then
				for i = 1, #farts do
					if customAnim:Is(mission,farts[i],"DNT_FartFront") then
						customAnim:Rem(mission,farts[i],"DNT_FartFront")
					end
					customAnim:Add(mission,farts[i],"DNT_FartFront")
				end
			end
		end
		reFart = false
	end

	local farts = mission.DNT_FartList -- remove effects on tiles without smoke
	if farts then
		for i = 1, #farts do
			if not Board:IsSmoke(farts[i]) then
				if customAnim:Is(mission,farts[i],"DNT_FartFront") then
					customAnim:Rem(mission,farts[i],"DNT_FartFront")
					Board:AddAnimation(farts[i],"DNT_FartAppear",ANIM_REVERSE)
				end
			end
		end
	end
end

local HOOK_ResetTurn = function(mission) -- redo animations when turn reset after game is loaded
	reFart = true
end

local HOOK_skillEnd = function(mission, pawn, weaponId, p1, p2) -- add smoke animation on attack
	if weaponId:find("^DNT_StinkbugAtk") ~= nil and not IsTipImage() then
		local dir = GetDirection(p2 - p1)
		local dir2 = dir+1 > 3 and 0 or dir+1
		local dir3 = dir-1 < 0 and 3 or dir-1
		local p3 = p1 + DIR_VECTORS[dir2]
		local p4 = p1 + DIR_VECTORS[dir3]
		if not customAnim:Is(mission,p3,"DNT_FartFront") then
			customAnim:Add(mission,p3,"DNT_FartFront")
		end
		if not customAnim:Is(mission,p4,"DNT_FartFront") then
			customAnim:Add(mission,p4,"DNT_FartFront")
		end
	end
	if pawn:GetTeam() == TEAM_PLAYER then
		mission.DNT_TurnFartList = mission.DNT_FartList
	end
end

local HOOK_nextTurn = function(mission) -- delete farts after all the vek attack
	local farts = mission.DNT_FartList
	if not IsTipImage() then
		if Game:GetTeamTurn() == TEAM_ENEMY and farts then
			for i = 1, #farts do
				if Board:IsSmoke(farts[i]) then
					if customAnim:Is(mission,farts[i],"DNT_FartFront") then -- only delete farts, not normal smoke
						Board:SetSmoke(farts[i],false,false)
						customAnim:Rem(mission,farts[i],"DNT_FartFront")
						Board:AddAnimation(farts[i],"DNT_FartAppear",ANIM_REVERSE)
					end
				end
			end
			mission.DNT_FartList = {}
		elseif Game:GetTeamTurn() == TEAM_PLAYER then -- fart record for undo move
			if farts then
				mission.DNT_TurnFartList = farts
			else
				mission.DNT_TurnFartList = {}
			end
		end
	end
end

local HOOK_PawnUndoMove = function(mission, pawn, undonePosition) -- recreate farts after undo move (mist eaters passive)
	local farts = mission.DNT_TurnFartList
	if farts then
		for i = 1, #farts do
			if Board:IsSmoke(farts[i]) then
				if not customAnim:Is(mission,farts[i],"DNT_FartFront") then
					customAnim:Add(mission,farts[i],"DNT_FartFront")
					Board:AddAnimation(farts[i],"DNT_FartAppear")--,ANIM_REVERSE)
				end
			end
		end
	end
end

local HOOK_MissionEnd = function(mission) -- delete farts on mission end
	local farts = mission.DNT_FartList
	if farts then
		for i = 1, #farts do
			if Board:IsSmoke(farts[i]) then
				if customAnim:Is(mission,farts[i],"DNT_FartFront") then -- only delete farts, not normal smoke
					Board:SetSmoke(farts[i],false,false)
					customAnim:Rem(mission,farts[i],"DNT_FartFront")
					Board:AddAnimation(farts[i],"DNT_FartAppear",ANIM_REVERSE)
				end
			end
		end
	end
end

local function EVENT_onModsLoaded()
	-- DNT_Vextra_ModApiExt:addGameLoadedHook(HOOK_gameLoaded) -- mission var and GetCurMission not working with this :/
	DNT_Vextra_ModApiExt:addSkillEndHook(HOOK_skillEnd)
	DNT_Vextra_ModApiExt:addPawnUndoMoveHook(HOOK_PawnUndoMove)
	DNT_Vextra_ModApiExt:addResetTurnHook(HOOK_ResetTurn)
	modApi:addNextTurnHook(HOOK_nextTurn)
	modApi:addMissionUpdateHook(HOOK_MissionUpdate)
	modApi:addMissionEndHook(HOOK_MissionEnd)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

