
local colorMapDef = {}

local transform_2x = {
	{ scale = 2 },
	colorMapDef,
}
local transform_2x_outline = {
	{ scale = 2 },
	{ outline = { border = 2, color = deco.colors.buttonborder } },
	colorMapDef,
}
local transform_2x_outline_hl = {
	{ scale = 2 },
	{ outline = { border = 2, color = deco.colors.buttonborderhl } },
	colorMapDef,
}
local transform_1x_outline = {
	{ scale = 1 },
	{ outline = { border = 1, color = deco.colors.buttonborder } },
	colorMapDef,
}
local transform_1x_outline_hl = {
	{ scale = 1 },
	{ outline = { border = 1, color = deco.colors.buttonborderhl } },
	colorMapDef,
}

return {
	colorMapDef = colorMapDef,
	transform_1x = nil,
	transform_1x_hl = nil,
	transform_1x_outline = transform_1x_outline,
	transform_1x_outline_hl = transform_1x_outline_hl,
	transform_2x = transform_2x,
	transform_2x_hl = transform_2x,
	transform_2x_outline = transform_2x_outline,
	transform_2x_outline_hl = transform_2x_outline_hl,
}
