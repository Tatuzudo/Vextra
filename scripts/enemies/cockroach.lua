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

------------
-- Traits --
------------

trait:add{
	pawnType = "DNT_Cockroach1",
	icon = resourcePath.."img/combat/traits/DNT_cockroach_trait.png",
	--icon_offset = Point(0,-15),
	desc_title = "Undying",
	desc_text = "If killed, resurrect with full hp after the Vek attack, unless damaged again or stepped on.",
}
trait:add{
	pawnType = "DNT_Cockroach2",
	icon = resourcePath.."img/combat/traits/DNT_cockroach_trait.png",
	--icon_offset = Point(0,-15),
	desc_title = "Undying",
	desc_text = "If killed, resurrect with full hp after the Vek attack, unless damaged again or stepped on.",
}


-------------
--   Art   --
-------------

local name = "cockroach" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."e.png", readpath.."DNT_"..name.."e.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
--modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -23, PosY = -5}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."e.png", PosX = -23, PosY = -5, NumFrames = 11}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_cockroach = base
a.DNT_cockroache = baseEmerge
a.DNT_cockroacha = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
a.DNT_cockroachd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 4, Time = .15 } --Numbers copied for now
--a.DNT_namew = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png"} --Only if there's a boss

--MINE
local corpseNames = {
	"beta",
	"alpha",
	"leader",
}
for _, suffix in pairs(corpseNames) do
	modApi:appendAsset(writepath.."DNT_cockroach_corpse_"..suffix..".png", readpath.."DNT_cockroach_corpse_"..suffix..".png")
		Location[imagepath.."DNT_cockroach_corpse_"..suffix..".png"] = Point(-23,-5)

	modApi:appendAsset(writepath.."DNT_cockroach_explosion_"..suffix..".png", readpath.."DNT_cockroach_explosion_"..suffix..".png")
	modApi:appendAsset(writepath.."DNT_cockroach_death_reverse_"..suffix..".png", readpath.."DNT_cockroach_death_reverse_"..suffix..".png")
end


--[[
DNT_cockroach_filler = Animation:new{
	Image = imagepath.."DNT_cockroach_corpse.png",
	NumFrames = 1,
	Loop = false,
	Time = 1,
	PosX = 0,
	PosY = 0,
}
--]]
a.DNT_cockroach_explosion_beta = Animation:new{
	Image = imagepath.."DNT_cockroach_explosion_beta.png",
	NumFrames = 8,
	Time = .14,
	Loop = false,
	PosX = -23,
	PosY = -5,
}
a.DNT_cockroach_explosion_alpha = a.DNT_cockroach_explosion_beta:new{
	Image = imagepath.."DNT_cockroach_explosion_alpha.png",
}
a.DNT_cockroach_explosion_leader = a.DNT_cockroach_explosion_beta:new{
	Image = imagepath.."DNT_cockroach_explosion_leader.png",
}

--These aren't actually the revere direction from the death, but they are used to play the reverse animation because they need to be seperate
a.DNT_cockroachd_reverse_beta = a.DNT_cockroachd:new{
	Image = imagepath.."DNT_cockroach_death_reverse_beta.png",
	NumFrames = 4,
	Height = 1,
}
a.DNT_cockroachd_reverse_alpha = a.DNT_cockroachd_reverse_beta:new{
	Image = imagepath.."DNT_cockroach_death_reverse_alpha.png",
}

a.DNT_cockroachd_reverse_leader = a.DNT_cockroachd_reverse_beta:new{
	Image = imagepath.."DNT_cockroach_death_reverse_leader.png",
}



-------------
-- Weapons --
-------------

DNT_CockroachAtk1 = LineArtillery:new {
	Name = "Organ Donor",
	Description = "Launch artillery attack on two tiles, one tile apart.",
	Damage = 1,
	ArtillerySize = 4,
	SelfDamage = 1,
	Class = "Enemy",
	PathSize = 1,
	Projectile = "effects/shotup_ant1.png",
	--Explosion = "ExploArt1",
	ImpactSound = "/impact/generic/explosion",
	LaunchSound = "",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Building = Point(2,0),
		Target = Point(2,2),
		CustomPawn = "DNT_Cockroach1",
	}
}
DNT_CockroachAtk2 = DNT_CockroachAtk1:new { --Just an example
	Damage = 3,
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Building = Point(2,0),
		Target = Point(2,2),
		CustomPawn = "DNT_Cockroach2",
	}
}



function DNT_CockroachAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	--local backdir = GetDirection(p1 - p2)

	local target = p2
	local damage = SpaceDamage(target, self.Damage)
	damage.sAnimation = "ExploArt1",

	ret:AddQueuedArtillery(damage,self.Projectile, NO_DELAY)

	target = p2 + DIR_VECTORS[direction]*2
	damage.loc = target

	ret:AddQueuedArtillery(damage,self.Projectile, NO_DELAY)

	damage = SpaceDamage(p1,self.SelfDamage)
	--Hide the self damage, we don't want people to misunderstand the red ground on it (doesn't work how I want)
	--damage.bHide = true
	--damage.bHideIcon = true This hides damage numbers on hover (I assume)
	--damage.bHidePath = true
	ret:AddQueuedDamage(damage)

--TO DO REMOVE I JUST HAD TO GO
--1. Check the hide it was hiding too much 2. Check the death flip back it's showing the wrong thing
--Finish the change list by going through the code from where it is currently scrolled to


	--[[ OLD TARGETTING SYSTEM
	local target = p2 + DIR_VECTORS[direction]
	local damage = SpaceDamage(target, self.Damage)
	damage.sAnimation = "ExploArt1",

	ret:AddQueuedArtillery(damage,self.Projectile, NO_DELAY)

	target = p2 + DIR_VECTORS[backdir]
	damage.loc = target

	ret:AddQueuedArtillery(damage,self.Projectile, NO_DELAY)
	]]

	return ret
end

-----------
-- Pawns --
-----------

DNT_Cockroach1 = Pawn:new
	{
		Name = "Cockroach",
		Health = 1,
		MoveSpeed = 3,
		Ranged = 1,
		Image = "DNT_cockroach", --lowercase
		SkillList = {"DNT_CockroachAtk1"},
		SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		DroppedCorpse = "DNT_Corpse_Mine",
		Corpse = true,
	}
AddPawn("DNT_Cockroach1")


DNT_Cockroach2 = DNT_Cockroach1:new
	{
		Name = "Alpha Cockroach",
		Health = 3,
		MoveSpeed = 3,
		Ranged = 1,
		SkillList = {"DNT_CockroachAtk2"},
		Image = "DNT_cockroach",
		SoundLocation = "/enemy/beetle_1/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
		DroppedCorpse = "DNT_Corpse2_Mine",
		Corpse = true,
	}
AddPawn("DNT_Cockroach2")

------------------
-- Death Effect --
------------------

local function DNT_Cockroach_Effect(p1, corpse)
	local ret = SkillEffect()
	ret:AddDelay(3*.15)
	ret:AddScript(string.format("Board:GetPawn(%s):SetSpace(Point(-1,-1))",p1:GetString()))
	local terrain = Board:GetTerrain(p1)
	if terrain ~= TERRAIN_WATER and terrain ~= TERRAIN_LAVA then
		local damage = SpaceDamage(p1,0)
		damage.sItem = corpse
		--ret:AddDelay(0.016)
		ret:AddDamage(damage)--Wait a frame?
		--ret:AddScript(string.format("table.insert(GetCurrentMission().CockroachCorpses,%s)",p1:GetString())) --BAD
		--ret:AddDelay(9*.15) --1.35
	end
	return ret
end

function DNT_Cockroach1:GetDeathEffect(p1) --Death Effects aren't inheritable apparently
	local corpse = self.DroppedCorpse
	return DNT_Cockroach_Effect(p1, corpse)
end

function DNT_Cockroach2:GetDeathEffect(p1) --Death Effects aren't inheritable apparently
	local corpse = self.DroppedCorpse
	return DNT_Cockroach_Effect(p1, corpse)
end


-----------
-- Mines --
-----------

TILE_TOOLTIPS = {
	DNT_Corpse_Text = {"Cockroach Corpse", "Comes back to life at the beginning of the Vek turn as a Cockroach unless stepped on or damaged."},
	DNT_Corpse_Text2 = {"Alpha Cockroach Corpse", "Comes back to life at the beginning of the Vek turn as an Alpha Cockroach unless stepped on or damaged."}
}

local mine_damage_beta = SpaceDamage(0)
--mine_damage_beta.sAnimation = "DNT_cockroach_explosion_beta"
--ANIMATIONS ARE HIDDEN FOR NOW, AT LEAST UNTIL WE FIND A WAY TO NOT MAKE THEM PLAY WITH A PAWN
--mine_damage_beta.sScript = "LOG(mine_damage_beta.loc)"
--mine_damage_beta.sScript = string.format("Board:AddAnimation(%s,%q,ANIM_NO_DELAY)",self.loc,"DNT_cockroach_explosion_beta")

local mine_damage_alpha = SpaceDamage(0)
--ANIMATIONS ARE HIDDEN FOR NOW, AT LEAST UNTIL WE FIND A WAY TO NOT MAKE THEM PLAY WITH A PAWN
--mine_damage_alpha.sAnimation = "DNT_cockroach_explosion_alpha"

DNT_Corpse_Mine = {
	Image = imagepath.."DNT_cockroach_corpse_beta.png",
	Damage = mine_damage_beta,
	Tooltip = "DNT_Corpse_Text",
	Icon = imagepath.."combat/icons/icon_frozenmine_glow.png",
	UsedImage = "",
}

DNT_Corpse2_Mine = {
	Image = imagepath.."DNT_cockroach_corpse_alpha.png",
	Damage = mine_damage_alpha,
	Tooltip = "DNT_Corpse_Text2",
	Icon = imagepath.."combat/icons/icon_frozenmine_glow.png",
	UsedImage = "",
}

-----------
-- Hooks --
-----------
local function IsVek(pawn, vek)
	return pawn and (pawn:GetType() == vek.."1" or pawn:GetType() == vek.."2" or pawn:GetType() == vek.."Boss")
end
--[[
local function PawnKilled(mission, pawn)
	if IsVek(pawn, "DNT_Cockroach") then
		LOG("DEATH HOOK")

	end
end
]]

--[[
local function resetVars(mission)
	mission.CockroachCorpses = {}
	mission.AlphaCockroachCorpses = {}
end
--]]

local function NextTurn(mission)
	if Game:GetTeamTurn() == TEAM_ENEMY then
		local point = nil
		local effect = SkillEffect()
		effect:AddDelay(4*.15) --1.35
		local board_size = Board:GetSize()
		for i = 1, board_size.x - 1 do
			for j = 1, board_size.y - 1 do
				local point = Point(i,j)
				if Board:GetItem(point) == DNT_Cockroach1.DroppedCorpse then
					--local damage = SpaceDamage(point,0)
					--damage.sPawn = "DNT_Cockroach1"
					--effect:AddDamage(damage)
					effect:AddScript(string.format("Board:AddPawn(%q,%s)","DNT_Cockroach1",point:GetString()))
					Board:AddAnimation(point,"DNT_cockroachd_reverse_beta",ANIM_REVERSE)
				elseif Board:GetItem(point) == DNT_Cockroach2.DroppedCorpse then
					--local damage = SpaceDamage(point,0)
					--damage.sPawn = "DNT_Cockroach2"
					--effect:AddDamage(damage)
					effect:AddScript(string.format("Board:AddPawn(%q,%s)","DNT_Cockroach2",point:GetString()))
					Board:AddAnimation(point,"DNT_cockroachd_reverse_alpha",ANIM_REVERSE)
				end
			end
		end
		Board:AddEffect(effect)
		resetVars(mission)
	end
end

--[[
local board_size = Board:GetSize()
for i = 0, board_size.x - 1 do
	for j = 0, board_size.y - 1 do
		local point = Point(i,j)
		--local pawn = Board:GetPawn(point)
		if IsVek(pawn, "DNT_CockroachCorpse") then
			local being = _G[pawn:GetType()].Being
			local damage = SpaceDamage(pawn:GetSpace(),1)
			damage.sPawn = being
			Board:DamageSpace(damage)
		end
	end
	--]]

--[[
local function MissionStart(mission)
	resetVars(mission)
end
local function PhaseStart(_, mission)
	resetVars(mission)
end
--]]

local this = {}

function this:load(NAH_Vextra_ModApiExt)
	local options = mod_loader.currentModContent[mod.id].options
	--NAH_Vextra_ModApiExt:addPawnKilledHook(PawnKilled) --EXAMPLE
	modApi:addNextTurnHook(NextTurn)
	--modApi:addMissionStartHook(MissionStart)
	--modApi:addMissionNextPhaseCreatedHook(PhaseStart)
end

return this




--[[
DNT_CockroachCorpse1 = Pawn:new
	{
		Name = "Cockroach Corpse",
		Health = 1,
		MoveSpeed = 0,
		Image = "totem", --lowercase
		--SkillList = {"DNT_CockroachAtk1"},
		--SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Minor = true,
		Being = "DNT_Cockroach1",
	}
AddPawn("DNT_CockroachCorpse1")


DNT_CockroachCorpse2 = Pawn:new
	{
		Name = "Alpha Cockroach Corpse",
		Health = 1,
		MoveSpeed = 0,
		--SkillList = {"DNT_CockroachAtk2"},
		Image = "totem",
		--SoundLocation = "/enemy/beetle_1/",
		ImageOffset = 1,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_ALPHA,
		Minor = true,
		Being = "DNT_Cockroach2",
	}
AddPawn("DNT_CockroachCorpse2")
--]]
