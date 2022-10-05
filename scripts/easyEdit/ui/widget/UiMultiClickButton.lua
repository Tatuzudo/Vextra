
local UiMultiClickButton = Class.inherit(Ui)

function UiMultiClickButton:new(clickTarget)
	Ui.new(self)

	self.tooltips = {}
	self.clickCount = 0
	self.clickTarget = clickTarget or 2
end

function UiMultiClickButton:updateTooltip()
	self.tooltip = self.tooltips[self.clickCount + 1]
end

function UiMultiClickButton:setTooltips(tooltips)
	self.tooltips = tooltips
	self:updateTooltip()
	return self
end

function UiMultiClickButton:clicked(button)
	if button == 1 then
		self.clickCount = self.clickCount + 1
		if self.clickCount == self.clickTarget then
			Ui.clicked(self, button)
			self.clickCount = 0
		end
	end

	return true
end

function UiMultiClickButton:relayout()
	if self.focused ~= true then
		self.clickCount = 0
	end

	self:updateTooltip()

	Ui.relayout(self)
end

return UiMultiClickButton
