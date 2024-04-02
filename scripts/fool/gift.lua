local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
--local previewer = require(scriptPath.."weaponPreview/api")

local writepath = "img/units/aliens/"
local readpath = resourcePath .. "img/units/aliens/fool/"
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

local name = "gift" --lowercase, I could also use this else where, but let's make it more readable elsewhere

-- UNCOMMENT WHEN YOU HAVE SPRITES; you can do partial
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
--modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")

local base = a.EnemyUnit:new{Image = imagepath .. "DNT_"..name..".png", PosX = -23, PosY = -5, Height = 1}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "DNT_"..name.."_emerge.png", PosX = -23, PosY = -5, Height = 1, NumFrames = 12, Time = .1}

-- REPLACE "name" with the name
-- UNCOMENT WHEN YOU HAVE SPRITES
a.DNT_gift = base
a.DNT_gifte = baseEmerge
a.DNT_gifta = base:new{ Image = imagepath.."DNT_"..name.."a.png", NumFrames = 8, Time = .1}
a.DNT_giftd = base:new{ Image = imagepath.."DNT_"..name.."_death.png", Loop = false, NumFrames = 22, Time = .08 } --Numbers copied for now
--a.DNT_namew = base:new{ Image = imagepath.."DNT_"..name.."_Bw.png"} --Only if there's a boss



-------------
-- Weapons --
-------------

DNT_GiftAtk1 = Skill:new {
	Name = "What's Inside?",
	Description = "Break it open and find out! Maybe you'll get a weapon (if you're lucky).",
	Class = "Enemy",
	TipImage = { --This is all tempalate and probably needs to change
		Unit = Point(2,2),
		CustomPawn = "DNT_Gift1",
	},
}


function DNT_GiftAtk1:GetTargetArea(p1)
	local ret = PointList()
	ret:push_back(p1)
	return ret
end

function DNT_GiftAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()

  ret:AddScript(string.format([[
    Game:TriggerSound("/ui/map/flyin_rewards")
    Board:Ping(%s, GL_Color(161, 0, 11))]],
  p1:GetString()))
	return ret
end

-----------
-- Pawns --
-----------

DNT_Gift1 = Pawn:new
	{
		Name = "Gift",
		Health = 1,
		MoveSpeed = 0,
		Image = "DNT_gift", --lowercase
		SkillList = {"DNT_GiftAtk1"},
		--SoundLocation = "/enemy/beetle_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_BLOB,
    IsPortrait = false,
		Minor = true,
	}
AddPawn("DNT_Gift1")

local weapon_odds = .3
local boss_odds = .01

function DNT_Gift1:GetDeathEffect(p)
  local ret = SkillEffect()
	local pawn = Board:GetPawn(p)
	if pawn then
		return ret
	end
  local mission = GetCurrentMission()

	ret:AddSound("ui/battle/emerge_resisted")
  ret:AddDelay(.6) --Just guessed
	ret:AddSound("ui/battle/pod_open")

  local get_weapon = math.random() > 1-weapon_odds and not mission.get_weapon;
  if get_weapon then
    mission.get_weapon = true
    ret:AddScript(string.format([[Board:AddAlert(%s, "WEAPON GET!")]],p:GetString()))
  else
    local vek_gift_list = {"Mantis","Pillbug","Thunderbug","Silkworm","Dragonfly",
    "Antlion","Termites","Stinkbug","Cockroach","Anthill","IceCrawler","Fly"}
    local vek_name = "DNT_"..random_removal(vek_gift_list)
    local vek_type
    if math.random() > 1-boss_odds then
      vek_type = vek_name.."Boss"
    else
      vek_type = vek_name..tostring(math.random(1,2))
    end

    ret:AddScript(string.format([[
      local point = %s
      local pawn = PAWN_FACTORY:CreatePawn(%q)
      Board:AddPawn(pawn, point)
      pawn:SpawnAnimation()
    ]],p:GetString(), vek_type))
  end

  return ret
end

--Spawn Code in new_vek_spawns.lua

local HOOK_missionEnd = function(mission)
  if mission.get_weapon then
    Game:AddWeapon("")
  end
end

local function EVENT_onModsLoaded()
  modApi:addMissionEndHook(HOOK_missionEnd)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
