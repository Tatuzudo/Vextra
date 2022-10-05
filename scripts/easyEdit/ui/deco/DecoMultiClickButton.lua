
local DecoMultiClickButton = Class.inherit(DecoSurfaceAligned)

function DecoMultiClickButton:new(surfaces, surfaceshl, alignH, alignV)
	DecoSurfaceAligned.new(self, surfaces[1], alignH, alignV)

	self.surfaces = shallow_copy(surfaces)
	self.surfaceshl = shallow_copy(surfaceshl) or self.surfaces
end

function DecoMultiClickButton:draw(screen, widget)
	local index = (widget.clickCount or 0) + 1

	if widget.hovered then
		self.surface = self.surfaceshl[index]
	else
		self.surface = self.surfaces[index]
	end

	DecoSurfaceAligned.draw(self, screen, widget)
end

return DecoMultiClickButton
