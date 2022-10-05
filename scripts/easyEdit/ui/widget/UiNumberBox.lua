
local path = GetParentPath(...)
local UiTextBox = require(path.."UiTextBox")

local UiNumberBox = Class.inherit(UiTextBox)

function UiNumberBox:new(minValue, maxValue)
	UiTextBox.new(self)

	self.minValue = minValue
	self.maxValue = maxValue
end

function UiNumberBox:init()
	UiTextBox.init(self)
	self.alphabet = self._ALPHABET_NUMBERS
end

function UiNumberBox:setText(text)
	local value = tonumber(text)

	if value < self.minValue then
		self:setText(tostring(self.minValue))
	elseif value > self.maxValue then
		self:setText(tostring(self.maxValue))
	else
		UiTextBox.setText(self, text)
	end
end

function UiNumberBox:addText(input)
	UiTextBox.addText(self, input)

	local value = tonumber(self.textfield)
	if value < self.minValue then
		self:setText(tostring(self.minValue))
	elseif value > self.maxValue then
		self:setText(tostring(self.maxValue))
	end
end

return UiNumberBox
