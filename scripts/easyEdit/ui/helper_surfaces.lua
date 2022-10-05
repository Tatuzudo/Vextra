
-- header
local path = GetParentPath(...)
local defs = require(path.."helper_defs")


-- defs
local COLOR_RED = defs.COLOR_RED
local TRANSFORM_RED = { { multiply = COLOR_RED } }
local TRANSFORM_HL = { { multiply = deco.colors.buttonborderhl } }


local helpers = {
	surfaceReward = {}
}

modApi.events.onFtldatFinalized:subscribe(function()
	local surfaceDef = { transformations = TRANSFORM_RED }
	local surfaceDefHl = { transformations = TRANSFORM_HL }

	surfaceDef.path = "img/ui/easyEdit/delete.png"
	surfaceDefHl.path = "img/ui/easyEdit/delete.png"
	helpers.surfaceDelete = sdlext.getSurface(surfaceDef)
	helpers.surfaceDeleteHl = sdlext.getSurface(surfaceDefHl)

	surfaceDef.path = "img/ui/easyEdit/reset.png"
	surfaceDefHl.path = "img/ui/easyEdit/reset.png"
	helpers.surfaceReset = sdlext.getSurface(surfaceDef)
	helpers.surfaceResetHl = sdlext.getSurface(surfaceDefHl)

	surfaceDef.path = "img/ui/warning_symbol.png"
	surfaceDefHl.path = "img/ui/warning_symbol.png"
	helpers.surfaceWarning = sdlext.getSurface(surfaceDef)
	helpers.surfaceWarningHl = sdlext.getSurface(surfaceDefHl)

	surfaceDef.path = "img/ui/easyEdit/delete_small.png"
	surfaceDefHl.path = "img/ui/easyEdit/delete_small.png"
	helpers.surfaceDeleteSmall = sdlext.getSurface(surfaceDef)
	helpers.surfaceDeleteSmallHl = sdlext.getSurface(surfaceDefHl)

	surfaceDef.path = "img/ui/easyEdit/reset_small.png"
	surfaceDefHl.path = "img/ui/easyEdit/reset_small.png"
	helpers.surfaceResetSmall = sdlext.getSurface(surfaceDef)
	helpers.surfaceResetSmallHl = sdlext.getSurface(surfaceDefHl)

	surfaceDef.path = "img/ui/easyEdit/warning_small.png"
	surfaceDefHl.path = "img/ui/easyEdit/warning_small.png"
	helpers.surfaceWarningSmall = sdlext.getSurface(surfaceDef)
	helpers.surfaceWarningSmallHl = sdlext.getSurface(surfaceDefHl)

	helpers.surfaceReward[REWARD_REP] = sdlext.getSurface{
		path = "img/ui/star.png"
	}
	helpers.surfaceReward[REWARD_POWER] = sdlext.getSurface{
		path = "img/ui/power.png"
	}
	helpers.surfaceReward[REWARD_TECH] = sdlext.getSurface{
		path = "img/ui/core.png"
	}
	helpers.surfaceReward[REWARD_POD] = sdlext.getSurface{
		path = "img/ui/pod.png"
	}
end)


return helpers
