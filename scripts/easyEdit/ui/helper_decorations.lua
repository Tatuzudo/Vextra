
-- header
local path = GetParentPath(...)
local defs = require(path.."helper_defs")
local DecoUnit = require(path.."deco/DecoUnit")
local DecoIcon = require(path.."deco/DecoIcon")
local DecoBounceLabel = require(path.."deco/DecoBounceLabel")
local DecoImmutable = require(path.."deco/DecoImmutable")
local DecoImmutableAlignReward = DecoAlign(0, -4)

-- defs
local FONT_LABEL = defs.FONT_LABEL
local TEXT_SETTINGS_LABEL = defs.TEXT_SETTINGS_LABEL
local REWARD_DEF = { outlinesize = 0, alignV = "bottom", alignH = "right" }

local helpers = {}

function helpers.decoIconWithLabel(obj, iconDef)
	local name
	if type(obj) == 'table' then
		name = obj:getName()
		iconDef = iconDef or obj:getIconDef()
	end
	return
		DecoImmutable.Button,
		DecoImmutable.Anchor,
		DecoIcon(obj, iconDef),
		DecoImmutable.TransHeader,
		DecoBounceLabel(name, FONT_LABEL, TEXT_SETTINGS_LABEL, "top")
end

function helpers.decoUnitWithLabel(unit, iconDef)
	local name
	if type(unit) == 'table' then
		name = unit:getName()
		iconDef = iconDef or unit:getIconDef()
	end
	return
		DecoImmutable.Button,
		DecoImmutable.Anchor,
		DecoUnit(unit, iconDef),
		DecoImmutable.TransHeader,
		DecoBounceLabel(name, FONT_LABEL, TEXT_SETTINGS_LABEL, "top")
end

function helpers.decoStructureWithLabel(structure, iconDef)
	local name, reward
	if type(structure) == 'table' then
		reward = structure:getRewardIcon()
		name = structure:getName()
		iconDef = iconDef or unit:getIconDef()
	end
	return
		DecoImmutable.Button,
		DecoImmutable.Anchor,
		DecoIcon(structure, iconDef),
		DecoImmutableAlignReward,
		DecoIcon(reward, REWARD_DEF),
		DecoImmutable.Anchor,
		DecoImmutable.TransHeader,
		DecoBounceLabel(name, FONT_LABEL, TEXT_SETTINGS_LABEL, "top")
end

return helpers
