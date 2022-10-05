
-- A lightweight variant of UiBoxLayout
-- No padding, gap or alignment.

local UiBoxLayoutLite = Class.inherit(Ui)
function UiBoxLayoutLite:new()
	Ui.new(self)
	self._debugName = "UiBoxLayoutLite"
end

function UiBoxLayoutLite:relayout()
	local nextX = 0

	for i = 1, #self.children do
		local child = self.children[i]
		if child.wPercent ~= nil then
			child.w = (self.w - self.padl - self.padr) * child.wPercent
		end
		if child.hPercent ~= nil then
			child.h = (self.h - self.padt - self.padb) * child.hPercent
		end
	end

	for i = 1, #self.children do
		local child = self.children[i]

		child.screenx = self.screenx + nextX
		child.screeny = self.screeny + self.h/2 - child.h/2 + child.y

		child:relayout()

		child.rect.x = child.screenx
		child.rect.y = child.screeny
		child.rect.w = child.w
		child.rect.h = child.h

		nextX = nextX + child.w
	end

	self.w = nextX
end

return UiBoxLayoutLite
