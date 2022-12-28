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
trait:add{
	pawnType = "DNT_CockroachBoss",
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
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -23, PosY = -5}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -23, PosY = -5, NumFrames = 11}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_cockroach = base
a.DNT_cockroache = baseEmerge
a.DNT_cockroacha = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 4 }
a.DNT_cockroachd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", NumFrames = 5, Lengths = {.15,.15,.15,.15,.8}, Loop = false }
a.DNT_cockroachw = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png", PosY = 0} --Only if there's a boss

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
a.DNT_cockroach_explo_beta = Animation:new{
	Image = imagepath.."DNT_cockroach_explosion_beta.png",
	NumFrames = 8,
	Time = .14,
	Loop = false,
	PosX = -23,
	PosY = -5,
	Layer = ANIMS.LAYER_FLOOR,
}
a.DNT_cockroach_explo_alpha = a.DNT_cockroach_explo_beta:new{
	Image = imagepath.."DNT_cockroach_explosion_alpha.png",
}
a.DNT_cockroach_explo_leader = a.DNT_cockroach_explo_beta:new{
	Image = imagepath.."DNT_cockroach_explosion_leader.png",
}

--Death animation is seperate from the actual thing
a.DNT_cockroachd_beta = base:new{
  Image = imagepath.."DNT_cockroach_death_reverse_beta.png",
	Loop = false,
	NumFrames = 5,
  --Time = .15,
	Height = 1,
	Lengths = {.15, .15, .15, .15, 1.5}
}
a.DNT_cockroachd_alpha = a.DNT_cockroachd_beta:new{
	Image = imagepath.."DNT_cockroach_death_reverse_alpha.png",
}

a.DNT_cockroachd_leader = a.DNT_cockroachd_beta:new{
	Image = imagepath.."DNT_cockroach_death_reverse_leader.png",
}

a.DNT_cockroach_revive_beta = a.DNT_cockroachd_beta:new{
	Frames = {5,4,3,2,1},
	Lengths = {.15, .15, .15, .15, .15},
}
a.DNT_cockroach_revive_alpha = a.DNT_cockroachd_alpha:new{
	Lengths = {.15, .15, .15, .15, .15},
}
a.DNT_cockroach_revive_leader = a.DNT_cockroachd_leader:new{
	Lengths = {.15, .15, .15, .15, .15},
}

-----------------
--  Portraits  --
-----------------

local ptname = "Cockroach"
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."1.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."1.png")
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."2.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."2.png")
modApi:appendAsset("img/portraits/enemy/DNT_"..ptname.."Boss.png",resourcePath.."img/portraits/enemy/DNT_"..ptname.."Boss.png")

-------------
-- Weapons --
-------------

DNT_CockroachAtk1 = LineArtillery:new {
	Name = "Organ Donor",
	Description = "Damage itself to launch an artillery "
				.."attack on two tiles, one tile apart.",
	Damage = 1,
	ArtillerySize = 4,
	SelfDamage = 1,
	Class = "Enemy",
	PathSize = 1,
	Projectile = "effects/shotup_ant1.png",
	ImpactSound = "/impact/generic/explosion",
	LaunchSound = "",
	ExtraTiles = false,
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Building = Point(2,0),
		Target = Point(2,2),
		CustomPawn = "DNT_Cockroach1",
	}
}

DNT_CockroachAtk2 = DNT_CockroachAtk1:new {
	Name = "Organ Deliverer",
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

DNT_CockroachAtkB = DNT_CockroachAtk1:new {
	Name = "Organ Provider",
	Description = "Damage itself to launch an artillery "
				.."attack on four tiles, centered around one tile.",
	Damage = 2,
	ExtraTiles = true,
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Building = Point(2,0),
		Target = Point(2,2),
		CustomPawn = "DNT_CockroachBoss",
	}
}


function DNT_CockroachAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)

	local targets = {p2, p2 + DIR_VECTORS[direction]*2}
	if self.ExtraTiles then
		table.insert(targets, p2+DIR_VECTORS[direction]+DIR_VECTORS[(direction+1)%4])
		table.insert(targets, p2+DIR_VECTORS[direction]+DIR_VECTORS[(direction-1)%4])
	end

	for _, target in pairs(targets) do
		local damage = SpaceDamage(target, self.Damage)
		damage.sAnimation = "ExploArt1"
		if Board:IsValid(target) then
			ret:AddQueuedArtillery(damage,self.Projectile, NO_DELAY)
		end
	end

	damage = SpaceDamage(p1,self.SelfDamage)
	ret:AddQueuedDamage(damage)

	return ret
end

----------------------------- UNITS -----------------------------

DNT_Cockroach1 = Pawn:new
	{
		Name = "Cockroach",
		Health = 1,
		MoveSpeed = 3,
		Ranged = 1,
		Image = "DNT_cockroach",
		SkillList = {"DNT_CockroachAtk1"},
		SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		CorpseItem = "DNT_Corpse_Mine",
		ReviveAnim = "DNT_cockroach_revive_beta",
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
		CorpseItem = "DNT_Corpse2_Mine",
		ReviveAnim = "DNT_cockroach_revive_alpha",
		Corpse = true,
	}
AddPawn("DNT_Cockroach2")

DNT_CockroachBoss = DNT_Cockroach1:new
	{
		Name = "Cockroach Leader",
		Health = 6,
		MoveSpeed = 3,
		Ranged = 1,
		SkillList = {"DNT_CockroachAtkB"},
		Image = "DNT_cockroach",
		SoundLocation = "/enemy/beetle_1/",
		ImageOffset = 2,
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_INSECT,
		Tier = TIER_BOSS,
		Massive = true,
		CorpseItem = "DNT_Corpse3_Mine",
		ReviveAnim = "DNT_cockroach_revive_leader",
		Corpse = true,
	}
AddPawn("DNT_CockroachBoss")

function DNT_Cockroach1:GetDeathEffect(p)
	local ret = SkillEffect()
	local pawn = Board:GetPawn(p)
	local item = self.CorpseItem

	if pawn then
		local pawnId = pawn:GetId()
		local terrain = Board:GetTerrain(p)

		if terrain == TERRAIN_HOLE then
			-- Do nothing

		elseif terrain == TERRAIN_WATER then
			-- If the unit dies and is pushed into water,
			-- unset corpse so it causes a splash.

			ret:AddScript(string.format("Board:GetPawn(%s):SetCorpse(false)", pawnId))
		else
			-- Wait until xp text is gone
			-- before we swap out the unit
			-- with an item.

			ret:AddDelay(0.5)
			ret:AddScript(string.format([[
				local pawnId, item = %s, %q
				local pawn = Board:GetPawn(pawnId)
				if pawn then
					local p = pawn:GetSpace()

					pawn:SetCorpse(false)
					pawn:SetCustomAnim("")
					Board:SetItem(p, item)
				end
			]], pawnId, item))
		end
	end

	return ret
end

DNT_Cockroach2.GetDeathEffect = DNT_Cockroach1.GetDeathEffect
DNT_CockroachBoss.GetDeathEffect = DNT_Cockroach1.GetDeathEffect

----------------------------- MINES -----------------------------

TILE_TOOLTIPS = {
	DNT_Corpse_Text = {
		"Cockroach Corpse",
		"Comes back to life at the beginning of the Vek turn "..
		"as a Cockroach unless stepped on or damaged."
	},
	DNT_Corpse_Text2 = {
		"Alpha Cockroach Corpse",
		"Comes back to life at the beginning of the Vek turn "..
		"as an Alpha Cockroach unless stepped on or damaged."
	},
	DNT_Corpse_Text3 = {
		"Cockroach Leader Corpse",
		"Comes back to life at the beginning of the Vek turn "..
		"as a Cockroach Leader unless stepped on or damaged."
	},
}

mine_damage_beta = SpaceDamage(0)
local mine_damage_alpha = SpaceDamage(0)
local mine_damage_leader = SpaceDamage(0)
mine_damage_beta.sAnimation = "DNT_cockroach_explo_beta"
mine_damage_alpha.sAnimation = "DNT_cockroach_explo_alpha"
mine_damage_leader.sAnimation = "DNT_cockroach_explo_leader"


DNT_Item_Blank = {
	Image = "",
	Damage = SpaceDamage(),
	Tooltip = "",
	Icon = "",
	UsedImage = "",
}

DNT_Corpse_Mine = {
	Image = "units/aliens/DNT_cockroach_corpse_beta.png",
	Damage = mine_damage_beta,
	Tooltip = "DNT_Corpse_Text",
	Icon = "combat/icons/icon_frozenmine_glow.png",
	UsedImage = "",
}

DNT_Corpse2_Mine = {
	Image = "units/aliens/DNT_cockroach_corpse_alpha.png",
	Damage = mine_damage_alpha,
	Tooltip = "DNT_Corpse_Text2",
	Icon = "combat/icons/icon_frozenmine_glow.png",
	UsedImage = "",
}

DNT_Corpse3_Mine = {
	Image = "units/aliens/DNT_cockroach_corpse_leader.png",
	Damage = mine_damage_leader,
	Tooltip = "DNT_Corpse_Text3",
	Icon = "combat/icons/icon_frozenmine_glow.png",
	UsedImage = "",
}

---------------------------- RESPAWN -----------------------------

local item2Cockroach = {
	DNT_Corpse_Mine = "DNT_Cockroach1",
	DNT_Corpse2_Mine = "DNT_Cockroach2",
	DNT_Corpse3_Mine = "DNT_CockroachBoss",
}

modApi.events.onNextTurn:subscribe(function(mission)
	if Game:GetTeamTurn() ~= TEAM_ENEMY then
		return
	end

	local effect = SkillEffect()

	for i, p in ipairs(Board) do
		local item = Board:GetItem(p)
		local cockroachType = item2Cockroach[item]

		if cockroachType then
			local pawnTable = _G[cockroachType]
			local reviveAnim = pawnTable.ReviveAnim

			-- Create a blank item to remove the cockroach
			-- corpse while the revive animation plays
			effect:AddScript(string.format("Board:SetItem(%s,'DNT_Item_Blank')", p:GetString()))
			effect:AddAnimation(p, reviveAnim, ANIM_DELAY)
			effect:AddDelay(0.75)
			effect:AddScript(string.format("Board:AddPawn(%q,%s)", cockroachType, p:GetString()))
		end
	end

	Board:AddEffect(effect)
end)

--Hook to fix a bug where the cockroach corpse would show up when retreating/evacuating
local function HOOK_MissionEnd(mission,effect)
	local enemies = extract_table(Board:GetPawns(TEAM_ENEMY))
	for _, id in pairs(enemies) do
		local pawn = Board:GetPawn(id)
		if pawn:GetType():find("^DNT_Cockroach") then
			pawn:SetCorpse(false)
		end
	end
end

local function EVENT_onModsLoaded()
	modApi:addMissionEndHook(HOOK_MissionEnd)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
