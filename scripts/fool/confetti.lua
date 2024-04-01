-- confetti spawn
local mod = mod_loader.mods[modApi.currentMod]

modApi:appendAsset("img/combat/tiles_grass/particleRed.png", mod.resourcePath.."img/effects/fool/particleRed.png")
modApi:appendAsset("img/combat/tiles_grass/particleGreen.png", mod.resourcePath.."img/effects/fool/particleGreen.png")
modApi:appendAsset("img/combat/tiles_grass/particleBlue.png", mod.resourcePath.."img/effects/fool/particleBlue.png")
modApi:appendAsset("img/combat/tiles_grass/particleYellow.png", mod.resourcePath.."img/effects/fool/particleYellow.png")

modApi:appendAsset("img/effects/explo_cheer_1.png", mod.resourcePath.."img/effects/fool/explo_cheer_1.png")
modApi:appendAsset("img/effects/explo_cheer_2.png", mod.resourcePath.."img/effects/fool/explo_cheer_2.png")
modApi:appendAsset("img/effects/explo_cheer_3.png", mod.resourcePath.."img/effects/fool/explo_cheer_3.png")
modApi:appendAsset("img/effects/explo_cheer_4.png", mod.resourcePath.."img/effects/fool/explo_cheer_4.png")
modApi:appendAsset("img/effects/explo_cheer_5.png", mod.resourcePath.."img/effects/fool/explo_cheer_5.png")
modApi:appendAsset("img/effects/explo_cheer_6.png", mod.resourcePath.."img/effects/fool/explo_cheer_6.png")
modApi:appendAsset("img/effects/explo_cheer_7.png", mod.resourcePath.."img/effects/fool/explo_cheer_7.png")

DNT_ConfettiW = Emitter:new{
	-- image = "combat/tiles_grass/particle.png",
	image = "combat/tiles_grass/particleYellow.png",
	x = -3,
	y = 25,
	variance = 10,
	max_alpha = 1.0,
	min_alpha = 0.5,
	angle = -40,
	angle_variance = 30,
	rot_speed = 0,
	random_rot = false,
	lifespan = 2,
	burst_count = 5,
	speed = 2,
	birth_rate = 0,
	gravity = true,
	layer = LAYER_FRONT,
	timer = 2,
	max_particles = 64,
}

DNT_ConfettiR = DNT_ConfettiW:new{
	image = "combat/tiles_grass/particleRed.png",
	angle = -60,
	angle_variance = 30,
	speed = 1.5,
}

DNT_ConfettiG = DNT_ConfettiW:new{
	image = "combat/tiles_grass/particleGreen.png",
	angle = -80,
	angle_variance = 30,
	speed = 3.0,
}

DNT_ConfettiB = DNT_ConfettiW:new{
	image = "combat/tiles_grass/particleBlue.png",
	angle = -100,
	angle_variance = 30,
	speed = 2.5,
}


ANIMS.DNT_ExploCheer1 = Animation:new{
	Image = "effects/explo_cheer_1.png",
	NumFrames = 8,
	Time = 0.1,
	PosX = -33,
	PosY = -14
}

ANIMS.DNT_ExploCheer2 = ANIMS.DNT_ExploCheer1:new{
	Image = "effects/explo_cheer_2.png",
	NumFrames = 9,
}

ANIMS.DNT_ExploCheer3 = ANIMS.DNT_ExploCheer1:new{
	Image = "effects/explo_cheer_3.png",
	NumFrames = 9,
}

ANIMS.DNT_ExploCheer4 = ANIMS.DNT_ExploCheer1:new{
	Image = "effects/explo_cheer_4.png",
	NumFrames = 9,
}

ANIMS.DNT_ExploCheer5 = ANIMS.DNT_ExploCheer1:new{
	Image = "effects/explo_cheer_5.png",
	NumFrames = 9,
}

ANIMS.DNT_ExploCheer6 = ANIMS.DNT_ExploCheer1:new{
	Image = "effects/explo_cheer_6.png",
	NumFrames = 9,
}

ANIMS.DNT_ExploCheer7 = ANIMS.DNT_ExploCheer1:new{
	Image = "effects/explo_cheer_7.png",
	NumFrames = 9,
}


local function spawnConfetti(point)
	Board:AddBurst(point,"DNT_ConfettiW",DIR_NONE)
	Board:AddBurst(point,"DNT_ConfettiR",DIR_NONE)
	Board:AddBurst(point,"DNT_ConfettiG",DIR_NONE)
	Board:AddBurst(point,"DNT_ConfettiB",DIR_NONE)
end


local HOOK_pawnTracked = function(mission, pawn)
	modApi:scheduleHook(100, function()
		if pawn:GetType():find("^DNT_") then
			spawnConfetti(pawn:GetSpace())
			Game:TriggerSound("/props/smoke_cloud")
		end
	end)
end

local EVENT_pawnLanded = function(pawnId)
	local pawn = Board:GetPawn(pawnId);
	if pawn:GetType():find("^DNT_") then
		spawnConfetti(pawn:GetSpace())
		--Game:TriggerSound("/props/smoke_cloud")
	end
end

local HOOK_pawnKilled = function(mission, pawn)
	modApi:scheduleHook(800, function()
		local type = pawn:GetType()
		if type:find("^DNT_") and type ~= "DNT_Gift1" and (math.random() > 0.66 or _G[pawn:GetType()].Tier == TIER_BOSS or pawn:IsMech()) then
			Board:AddAnimation(pawn:GetSpace(),"DNT_ExploCheer"..math.random(1,7),ANIM_NO_DELAY)
			Game:TriggerSound("/ui/general/level_up")
		end
	end)
end

local function EVENT_onModsLoaded()
	DNT_Vextra_ModApiExt:addPawnTrackedHook(HOOK_pawnTracked)
	DNT_Vextra_ModApiExt:addPawnKilledHook(HOOK_pawnKilled)
end

modApi.events.onPawnLanded:subscribe(EVENT_pawnLanded)
modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
