
-- header
local path = GetParentPath(...)
local DecoButtonExt = require(path.."DecoButtonExt")

local DecoEditorObject = Class.inherit(DecoButtonExt)

function DecoEditorObject:draw(screen, widget)
	if easyEdit.selectedEditorButton == widget then
		local color = self.color
		local bordercolor = self.bordercolor
		self.color = self.hlcolor
		self.bordercolor = self.borderhlcolor

		DecoButtonExt.draw(self, screen, widget)

		self.color = color
		self.bordercolor = bordercolor
	else
		DecoButtonExt.draw(self, screen, widget)
	end
end

return DecoEditorObject
