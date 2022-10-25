local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
local previewer = require(scriptPath.."weaponPreview/api")

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

-- local name = "thunderbug" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- -- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
-- modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
-- modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
-- modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
-- modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
-- modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

-- local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -24, PosY = -10}
-- local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -24, PosY = -8, NumFrames = 10}

-- -- REPLACE "name" with the name
-- -- UNCOMENT WHEN YOU HAVE SPRITES
-- a.DNT_thunderbug = base
-- a.DNT_thunderbuge = baseEmerge
-- a.DNT_thunderbuga = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
-- a.DNT_thunderbugd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 8, Time = .15 } --Numbers copied for now
-- a.DNT_thunderbugw = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png", PosY = -3} --Only if there's a boss


-------------
-- Weapons --
-------------

DNT_Haste_Passive = PassiveSkill:new{
	Name = "Haste",
	Description = "All other vek receive +2 bonus movement.",
	Class = "Enemy",
	Icon = "weapons/prime_lightning.png",
	Passive = "DNT_Haste_Passive",
	TipImage = {
		Unit = Point(2,3),
		-- CustomPawn = "DNT_Thunderbug1",
		-- Target = Point(2,2),
		Enemy = Point(2,2),
	}
}

function DNT_Haste_Passive:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	-- local dir = GetDirection(p2 - p1)
	-- dano = SpaceDamage(Point(2,2),2)
	-- dano.iPush = dir
	-- dano.iAcid = EFFECT_CREATE
	-- ret:AddMelee(Point(2,3),dano)
	return ret
end

-----------
-- Pawns --
-----------

DNT_HastePsion1 = Pawn:new{
	Name = "Haste Psion",
	Health = 2,
	MoveSpeed = 2,
	Image = "jelly",
	LargeShield = true,
	VoidShockImmune = true,
	ImageOffset = 4,
	SkillList = { "DNT_Haste_Passive" },
	SoundLocation = "/enemy/jelly/",
	Flying = true,
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB
	-- Tooltip = "Jelly_Health_Tooltip"
}
AddPawn("DNT_HastePsion1")

-----------
-- Hooks --
-----------

local SPEED = 2

local HOOK_pawnTracked = function(mission, pawn)
	modApi:scheduleHook(1500, function()
		if pawn:GetType() == "DNT_HastePsion1" then
			mission.DNT_Haste_Psion = true
			if IsPassiveSkill("Psion_Leech") then
				local playerList = extract_table(Board:GetPawns(TEAM_PLAYER))
				for i = 1, #playerList do
					playerUnit = Board:GetPawn(playerList[i])
					if playerUnit:GetMoveSpeed() > 0 and playerUnit:IsMech() then
						playerUnit:AddMoveBonus(SPEED)
					end
				end
			end
			local enemyList = extract_table(Board:GetPawns(TEAM_ENEMY))
			for i = 1, #enemyList do
				local enemyUnit = Board:GetPawn(enemyList[i])
				if enemyUnit:GetMoveSpeed() > 0 and enemyUnit:GetType() ~= "DNT_HastePsion1" then
					if _G[enemyUnit:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[enemyUnit:GetType()].Minor then
						enemyUnit:AddMoveBonus(SPEED)
					end
				end
			end
		elseif mission.DNT_Haste_Psion and pawn:GetMoveSpeed() > 0 and pawn:GetType() ~= "DNT_HastePsion1" then
			if pawn:GetTeam() == TEAM_ENEMY or (IsPassiveSkill("Psion_Leech") and pawn:IsMech()) then
				if _G[pawn:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[pawn:GetType()].Minor then
					pawn:AddMoveBonus(SPEED)
				end
			end
		end
	end)
end

local HOOK_pawnUntracked = function(mission, pawn)
	if pawn:GetType() == "DNT_HastePsion1" then
		mission.DNT_Haste_Psion = nil
	end
end

local function HOOK_nextTurn(mission)
	if Board:GetTurn() ~= 0 then
		if mission.DNT_Haste_Psion and Game:GetTeamTurn() == TEAM_ENEMY then
			if IsPassiveSkill("Psion_Leech") then
				local playerList = extract_table(Board:GetPawns(TEAM_PLAYER))
				for i = 1, #playerList do
					playerUnit = Board:GetPawn(playerList[i])
					if playerUnit:GetMoveSpeed() > 0 and playerUnit:IsMech() then
						playerUnit:AddMoveBonus(SPEED)
					end
				end
			end
			local enemyList = extract_table(Board:GetPawns(TEAM_ENEMY))
			for i = 1, #enemyList do
				local enemyUnit = Board:GetPawn(enemyList[i])
				if enemyUnit:GetMoveSpeed() > 0 and enemyUnit:GetType() ~= "DNT_HastePsion1" then
					if _G[enemyUnit:GetType()].DefaultFaction ~= FACTION_BOTS and not _G[enemyUnit:GetType()].Minor then
						enemyUnit:AddMoveBonus(SPEED)
					end
				end
			end
		end
	end
end

local function EVENT_onModsLoaded()
	DNT_Vextra_ModApiExt:addPawnTrackedHook(HOOK_pawnTracked)
	DNT_Vextra_ModApiExt:addPawnUntrackedHook(HOOK_pawnUntracked)
	modApi:addNextTurnHook(HOOK_nextTurn)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)