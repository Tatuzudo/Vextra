
local UiBoxLayoutExt = Class.inherit(UiBoxLayout)
function UiBoxLayoutExt:new()
	UiBoxLayout.new(self)
	self.wPercent = 1
	self.hPercent = 1
end

return UiBoxLayoutExt
