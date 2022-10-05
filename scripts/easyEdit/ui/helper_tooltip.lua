
-- header
local path = GetParentPath(...)
local DecoImmutable = require(path.."deco/DecoImmutable")
local switch = require(path.."switch")


-- Default Object
local UiTooltipObject = Class.inherit(Ui)
function UiTooltipObject:new()
	Ui.new(self)

	self._debugName = "UiTooltipObject"
	self.staticTooltip = true

	self
		:sizepx(180, 120)
		:decorate{
			DecoImmutable.Frame,
			DecoImmutable.TooltipObject,
			DecoImmutable.TransHeader,
			DecoImmutable.ObjectNameLabelBounceCenterHClip,
		}
end

function UiTooltipObject:onCustomTooltipShown(hoveredUi)
	self.data = hoveredUi.data
end


-- Mission
UiTooltipMission = Class.inherit(UiTooltipObject)
function UiTooltipMission:new()
	UiTooltipObject.new(self)
	self._debugName = "UiTooltipMission"

	self
		:sizepx(240, 240)
		:decorate{
			DecoImmutable.Frame,
			DecoImmutable.TooltipMission,
			DecoImmutable.TransHeader,
			DecoImmutable.ObjectNameLabelBounceCenterHClip,
		}
end


-- structure
UiTooltipStructure = Class.inherit(UiTooltipObject)
function UiTooltipStructure:new()
	UiTooltipObject.new(self)
	self._debugName = "UiTooltipStructure"

	self
		:sizepx(180, 120)
		:decorate{
			DecoImmutable.Frame,
			DecoImmutable.TooltipObject,
			DecoImmutable.StructureReward,
			DecoImmutable.TransHeader,
			DecoImmutable.ObjectNameLabelBounceCenterHClip,
		}
end


local tooltips = {
	mission = UiTooltipMission(),
	boss = UiTooltipObject(),
	unit = UiTooltipObject(),
	structure = UiTooltipStructure(),
	island = UiTooltipObject(),
	ceo = UiTooltipObject(),
	tileset = UiTooltipObject(),
	object = UiTooltipObject(),
}

return {
	missionTooltip = tooltips.mission,
	bossTooltip = tooltips.bossMission,
	unitTooltip = tooltips.unit,
	structureTooltip = tooltips.structure,
	islandTooltip = tooltips.island,
	ceoTooltip = tooltips.ceo,
	tilesetTooltip = tooltips.tileset,
	objectTooltip = tooltips.object,
}
