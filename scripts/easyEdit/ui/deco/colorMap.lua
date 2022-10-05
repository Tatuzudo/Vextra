
local PALETTE_INDEX_BASE = 1
local colorMapBase = {}
local colorMaps = {}
local basePalette = GetColorMap(PALETTE_INDEX_BASE)
for i, gl_color in ipairs(basePalette) do
	local rgb = sdl.rgb(gl_color.r, gl_color.g, gl_color.b)
	colorMapBase[i*2-1] = rgb
	colorMapBase[i*2] = rgb
end

local function buildSdlColorMap(palette)
	local colorMap = shallow_copy(colorMapBase)

	for i = 1, 8 do
		local gl_color = palette[i]
		if gl_color ~= nil then
			colorMap[i*2] = sdl.rgb(gl_color.r, gl_color.g, gl_color.b)
		end
	end

	return colorMap
end

local function getColorMap(imageOffset)
	local palette = modApi:getPalette(imageOffset + 1)
	local colorMap

	if palette then
		colorMap = colorMaps[imageOffset]
		if colorMap == nil then
			colorMap = buildSdlColorMap(palette.colorMap)
			colorMaps[imageOffset] = colorMap
		end
	end

	return colorMap
end

local function clearColorMapCache()
	clear_table(colorMaps)
end

return {
	get = getColorMap,
	clearCache = clearColorMapCache,
}