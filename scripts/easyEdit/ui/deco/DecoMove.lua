
-- header
local path = GetParentPath(...)
local DecoIcon = require(path.."DecoIcon")


local DecoMove = Class.inherit(DecoIcon)

function DecoMove:new(_, scale, alignH, alignV)
	DecoIcon.new(self)

	self.path = self.path or "img/combat/icons/icon_move.png"
	self.alignH = alignH or "center"
	self.alignV = alignV or "bottom"
	self.scale = scale or 1
	self.outlineSize = scale or 1
	self.outlineSizeHl = scale or 1
	self.outlineColor = deco.colors.buttonborder
	self.outlineColorHl = deco.colors.focus

	self:updateSurfaces()
end

return DecoMove
