-- TODO: remove characters not in 'alphabet', also when pasting text

--[[
	A UI element with a simple purpose. Whenever this element is focused
	(and the console is closed), all keyboard input is overridden and fed
	into its 'textfield' object. The entered text can for example be displayed
	by decorating it with DecoTextBox.
	An alternate way of using the class is to register any arbitrary Ui object,
	populating it with all relevant functions.

	UiTextBox.registerAsTextBox(arbitraryUiObject)
--]]

local newtext = {}
UiTextBox = Class.inherit(Ui)
UiTextBox._ALPHABET_UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
UiTextBox._ALPHABET_LOWER = "abcdefghjiklmnopqrstuvwxyz"
UiTextBox._ALPHABET_NUMBERS = "1234567890"
UiTextBox._ALPHABET_SYMBOLS = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~ "
UiTextBox._ALPHABET_CHARS = UiTextBox._ALPHABET_UPPER..UiTextBox._ALPHABET_LOWER

function UiTextBox:new()
	Ui.new(self)
	self:init()
end

function UiTextBox:init()
	self._debugName = "UiTextBox"
	self.textfield = ""
	self.editable = true
	self.selection = nil
	self.caret = 0
	self.focused_prev = false

	self.onMousePressEvent = Event()
	self.onMouseMoveEvent = Event()
	self.onTextAddedEvent = Event()
	self.onTextRemovedEvent = Event()
	self.onCaretMovedEvent = Event()
	self.onFocusChangedEvent = Event()
end

function UiTextBox:setText(text)
	self.textfield = text
	self.selection = nil
	self:setCaret(self.caret)
	return self
end

function UiTextBox:setMaxLength(maxLength)
	self.maxLength = maxLength
	return self
end

function UiTextBox:setAlphabet(alphabet)
	self.alphabet = alphabet
	return self
end

function UiTextBox:setCaret(newcaret)
	local oldcaret = self.caret
	local size = self.textfield:len()
	local selection = self.selection

	if newcaret < 0 then
		newcaret = 0
	elseif newcaret > size then
		newcaret = size
	end

	self.caret = newcaret
	self.onCaretMovedEvent:dispatch(newcaret, oldcaret)
end

function UiTextBox:moveCaret(delta)
	self:setCaret(self.caret + delta)
end

function UiTextBox:getCaret()
	return self.caret
end

function UiTextBox:tryStartSelection()
	if sdlext.isShiftDown() then
		if self.selection == nil then
			self.selection = self.caret
		end
	else
		self.selection = nil
	end
end

function UiTextBox:deleteSelection()
	if not self.editable or self.selection == nil then return end
	local from, to = self:getSelection()

	self:setCaret(from)
	self:delete(to - from)
	self.selection = nil
end

function UiTextBox:getSelection()
	if self.selection == nil then return 0,0 end
	local from = self.selection
	local to = self.caret

	if from < to then
		return from, to
	else
		return to, from
	end
end

function UiTextBox:copy()
	local from, to = self:getSelection()
	local text = self.textfield:sub(from + 1, to)
	if type(text) == 'string' then
		sdl.clipboard.set(text)
	end
end

function UiTextBox:paste()
	if not self.editable then return end
	local text = sdl.clipboard.get()
	if type(text) == 'string' then
		self:addText(text)
	end
end

function UiTextBox:addText(input)
	if not self.editable then return end

	local textfield = self.textfield
	local textlength = textfield:len()
	local inputlength = input:len()
	local caret = self.caret
	local maxlength = self.maxLength

	if maxlength then
		local remainingLength = maxlength - textlength
		if inputlength > remainingLength then
			input = input:sub(0, remainingLength)
			inputlength = input:len()
		end
	end

	newtext[1] = textfield:sub(0, caret)
	newtext[2] = input
	newtext[3] = textfield:sub(caret + 1, textlength)

	self.textfield = table.concat(newtext)
	self.caret = caret + inputlength
	self.onTextAddedEvent:dispatch(caret, input)
end

function UiTextBox:delete(length)
	if not self.editable then return end
	local textfield = self.textfield
	local textlength = textfield:len()
	local caret = self.caret
	local selection = self.selection

	if length > textlength - caret then
		length = textlength - caret
	end

	if selection and selection > caret then
		if selection - length < caret then
			self.selection = nil
		else
			self.selection = selection - length
		end
	end

	newtext[1] = textfield:sub(0, caret)
	newtext[2] = ""
	newtext[3] = textfield:sub(caret + length + 1, -1)

	self.textfield = table.concat(newtext)
	self.onTextRemovedEvent:dispatch(caret, length)
end

function UiTextBox:backspace(length)
	if not self.editable then return end
	local textfield = self.textfield
	local textlength = textfield:len()
	local caret = self.caret
	local selection = self.selection

	if length > caret then
		length = caret
	end

	if selection then
		if selection > caret then
			self.selection = selection - length
		elseif selection < caret then
			if selection + length > caret then
				self.selection = nil
			end
		end
	end

	newtext[1] = textfield:sub(0, caret - length)
	newtext[2] = ""
	newtext[3] = textfield:sub(caret + 1, -1)

	self.textfield = table.concat(newtext)
	self.caret = caret - length

	self.onTextRemovedEvent:dispatch(caret - length, length)
end

function UiTextBox:newline()
	if not self.editable then return end
	local textfield = self.textfield
	local caret = self.caret

	self:addText("\n")
end

regex_list = {
	"%p+%s*",      -- punctuation + spaces
	"[^%p%s]*%s*", -- non-punctuation + spaces
}

function getFirstWordIndices(text)
	local out1, out2

	for _, regex in ipairs(regex_list) do
		out1, out2 = text:find("^"..regex)

		if out1 and out2 then
			return out1 - 1, out2
		end
	end

	return 0, text:len()
end

function getLastWordIndices(text)
	local out1, out2

	for _, regex in ipairs(regex_list) do
		out1, out2 = text:find(regex.."$")

		if out1 and out2 then
			return out1 - 1, out2
		end
	end

	return 0, text:len()
end

function UiTextBox:onSelectAll()
	self:setCaret(0)
	self.selection = self.textfield:len()
end

function UiTextBox:onCopy()
	self:copy()
end

function UiTextBox:onCut()
	self:copy()
	self:deleteSelection()
end

function UiTextBox:onPaste()
	self:deleteSelection()
	self:paste()
end

function UiTextBox:onInput(text)
	self:deleteSelection()
	self:addText(text)
end

function UiTextBox:onEnter()
	self.root:setfocus(nil)
end

function UiTextBox:onDelete()
	if sdlext.isCtrlDown() then
		local trail = self.textfield:sub(self.caret + 1, -1)
		local from, to = getFirstWordIndices(trail)
		self:delete(to - from)
	elseif self.selection ~= nil and self.selection ~= self.caret then
		self:deleteSelection()
	else
		self:delete(1)
	end
end

function UiTextBox:onBackspace()
	if sdlext.isCtrlDown() then
		local lead = self.textfield:sub(0, self.caret)
		local from, to = getLastWordIndices(lead)
		self:backspace(to - from)
	elseif self.selection ~= nil and self.selection ~= self.caret then
		self:deleteSelection()
	else
		self:backspace(1)
	end
end

function UiTextBox:onArrowRight()
	self:tryStartSelection()

	if sdlext.isCtrlDown() then
		local trail = self.textfield:sub(self.caret + 1, -1)
		local from, to = getFirstWordIndices(trail)
		self:moveCaret(to - from)
	else
		self:moveCaret(1)
	end
end

function UiTextBox:onArrowLeft()
	self:tryStartSelection()

	if sdlext.isCtrlDown() then
		local lead = self.textfield:sub(0, self.caret)
		local from, to = getLastWordIndices(lead)
		self:moveCaret(from - to)
	else
		self:moveCaret(-1)
	end
end

function UiTextBox:onArrowUp()
	self:onArrowLeft()
end

function UiTextBox:onArrowDown()
	self:onArrowRight()
end

function UiTextBox:onHome()
	self:tryStartSelection()
	self:setCaret(0)
end

function UiTextBox:onEnd()
	self:tryStartSelection()
	self:setCaret(self.textfield:len())
end

local eventkeyHandler = {
	[SDLKeycodes.BACKSPACE] = "onBackspace",
	[SDLKeycodes.DELETE] = "onDelete",
	[SDLKeycodes.ARROW_RIGHT] = "onArrowRight",
	[SDLKeycodes.ARROW_LEFT] = "onArrowLeft",
	[SDLKeycodes.ARROW_UP] = "onArrowUp",
	[SDLKeycodes.ARROW_DOWN] = "onArrowDown",
	[SDLKeycodes.RETURN] = "onEnter",
	[SDLKeycodes.RETURN2] = "onEnter",
	[SDLKeycodes.KP_ENTER] = "onEnter",
	[SDLKeycodes.HOME] = "onHome",
	[SDLKeycodes.END] = "onEnd",
}

local eventkeyHandler_ctrl = {
	[SDLKeycodes.a] = "onSelectAll",
	[SDLKeycodes.x] = "onCut",
	[SDLKeycodes.c] = "onCopy",
	[SDLKeycodes.v] = "onPaste"
}

function UiTextBox:relayout()
	local focused = self.focused
	local focused_prev = self.focused_prev

	if focused ~= focused_prev then

		if not focused then
			self.selection = nil
		end

		self.focused_prev = focused
		self.onFocusChangedEvent:dispatch(self, focused, focused_prev)
	end
end

function UiTextBox:mousedown(mx, my, button)
	if button == 1 then
		self.onMousePressEvent:dispatch(self, mx, my, button)
	end
end

function UiTextBox:mousemove(mx, my)
	if self.pressed then
		self.onMouseMoveEvent:dispatch(self, mx, my)
	end
end

function UiTextBox:keydown(keycode)
	if sdlext.isConsoleOpen() then return false end
	local eventKeyHandler

	eventKeyHandler = eventkeyHandler[keycode]

	if not eventKeyHandler and sdlext.isCtrlDown() then
		eventKeyHandler = eventkeyHandler_ctrl[keycode]
	end

	if eventKeyHandler then
		self[eventKeyHandler](self)
	end

	-- disable keyboard while the input field is active
	return true
end

function UiTextBox:textinput(textinput)
	if sdlext.isConsoleOpen() then return false end

	if not self.alphabet or self.alphabet:find(textinput) then
		self:onInput(textinput)
	end

	return true
end

function UiTextBox:registerAsTextBox()
	UiTextBox.init(self)
	self.setMaxLength      = UiTextBox.setMaxLength
	self.setAlphabet       = UiTextBox.setAlphabet
	self.setCaret          = UiTextBox.setCaret
	self.moveCaret         = UiTextBox.moveCaret
	self.tryStartSelection = UiTextBox.tryStartSelection
	self.deleteSelection   = UiTextBox.deleteSelection
	self.getSelection      = UiTextBox.getSelection
	self.copy              = UiTextBox.copy
	self.paste             = UiTextBox.paste
	self.addText           = UiTextBox.addText
	self.delete            = UiTextBox.delete
	self.backspace         = UiTextBox.backspace
	self.newline           = UiTextBox.newline
	self.mousedown         = UiTextBox.mousedown
	self.mousemove         = UiTextBox.mousemove
	self.keydown           = UiTextBox.keydown
	self.textinput         = UiTextBox.textinput
	self.onInput           = self.onInput or UiTextBox.onInput
	self.onEnter           = self.onEnter or UiTextBox.onEnter
	self.onDelete          = self.onDelete or UiTextBox.onDelete
	self.onBackspace       = self.onBackspace or UiTextBox.onBackspace
	self.onArrowLeft       = self.onArrowLeft or UiTextBox.onArrowLeft
	self.onArrowRight      = self.onArrowRight or UiTextBox.onArrowRight
	self.onArrowDown       = self.onArrowDown or UiTextBox.onArrowDown
	self.onArrowUp         = self.onArrowUp or UiTextBox.onArrowUp
	self.onHome            = self.onHome or UiTextBox.onHome
	self.onEnd             = self.onEnd or UiTextBox.onEnd
	self.onCut             = self.onCut or UiTextBox.onCut
	self.onCopy            = self.onCopy or UiTextBox.onCopy
	self.onPaste           = self.onPaste or UiTextBox.onPaste
	self.onSelectAll       = self.onSelectAll or UiTextBox.onSelectAll
end
