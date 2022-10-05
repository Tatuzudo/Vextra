
local UiEditBox = Class.inherit(Ui)
function UiEditBox:new()
	Ui.new(self)
	self._debugName = "UiEditBox"
end

function UiEditBox:updateText(text)
	-- overridable method
	if self.__index:isSubclassOf(UiTextBox) then
		self.textfield = text
	else
		for _, deco in ipairs(self.decorations) do
			if deco.__index:isSubclassOf(DecoText) then
				deco:setsurface(text)
				break
			end
		end
	end
end

function UiEditBox:updateSurface(path)
	if type(path) ~= 'string' then return end

	for _, deco in ipairs(self.decorations) do
		if deco.__index:isSubclassOf(DecoSurface) then
			deco.surface = sdlext.getSurface{ path = path }
			break
		end
	end
end

function UiEditBox:onRecieve(sender)
	-- overridable method
end

function UiEditBox:onSend(reciever)
	-- overridable method
end

function UiEditBox:recieve(sender)
	sender = sender or easyEdit.displayedEditorButton
	if not sender then return end

	self:onRecieve(sender)
end

function UiEditBox:send(reciever)
	reciever = reciever or easyEdit.displayedEditorButton
	if not reciever then return end

	self:onSend(reciever)
end

function UiEditBox:registerAsEditBox()
	self.onRecieve = UiEditBox.onRecieve
	self.onSend = UiEditBox.onSend
	self.recieve = UiEditBox.recieve
	self.send = UiEditBox.send
	self.updateText = UiEditBox.updateText
	self.updateSurface = UiEditBox.updateSurface

	return self
end

return UiEditBox
