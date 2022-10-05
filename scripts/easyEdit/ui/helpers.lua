
-- header
local path = GetParentPath(...)
local defs = require(path.."helper_defs")
local format = require(path.."helper_format")
local prefabs = require(path.."helper_prefabs")
local surfaces = require(path.."helper_surfaces")
local tooltips = require(path.."helper_tooltip")
local decorations = require(path.."helper_decorations")
local dragObject = require(path.."helper_dragObject")
local resetButton = require(path.."helper_resetButton")
local transforms = require(path.."helper_transforms")
local staticContentList = require(path.."helper_staticContentList")


local function combineTables(...)
	local collection = {}

	for argIndex = 1, select("#", ...) do
		for key, value in pairs(select(argIndex, ...)) do
			collection[key] = value
		end
	end

	return collection
end


return combineTables(
	defs,
	format,
	prefabs,
	surfaces,
	tooltips,
	decorations,
	dragObject,
	resetButton,
	transforms,
	staticContentList
)
