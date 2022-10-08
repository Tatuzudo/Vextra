
local path = GetParentPath(...)
local path_datastructures = GetParentPath(GetParentPath(path)).."datastructures/"
local binarySearch = require(path_datastructures.."binarySearch")
local binarySearchMin = binarySearch.min

--[[
	A decoration designed to be paired with the UiTextBox Class,
	or another Ui object that has been registered as a UiTextBox

	UiTextBox.registerAsTextBox(arbitraryUiObject)
--]]
local nullsurface = sdl.surface("")
local surfaceFonts = {}
local SurfaceFont = {
	_surfaces = {},
	font,
	textset,
	get = function(self, s)
		-- omit for speed
		--Assert.Equals('string', type(s))
		--Assert.Equals(1, s:len())

		local surfaces = self._surfaces
		if not surfaces[s] then
			local surface
			if s == "\n" then
				surface = nullsurface
			else
				surface = sdl.text(self.font, self.textset, s)
			end
			surfaces[s] = surface
		end


		return surfaces[s]
	end,
	__eq = function(a, b)
		if not a.font ~= not b.font then
			return false
		end

		if not a.textset ~= not b.textset then
			return false
		end

		if a.font then
			if
				a.font.name ~= b.font.name or
				a.font.size ~= b.font.size
			then
				return false
			end
		end

		if a.textset then
			if 
				a.textset.outlineColor ~= b.textset.outlineColor or
				a.textset.outlineWidth ~= b.textset.outlineWidth or
				a.textset.antialias ~= b.textset.antialias
			then
				return false
			end
		end

		return true
	end
}

SurfaceFont.__index = SurfaceFont

function SurfaceFont:getOrCreate(font, textset)
	for i, surfaceFont in ipairs(surfaceFonts) do
		if surfaceFont:__eq{font = font, set = textset} then
			return surfaceFont
		end
	end

	local surfaceFont = {font = font, textset = textset}
	setmetatable(surfaceFont, SurfaceFont)

	return surfaceFont
end

local DecoTextBox = Class.inherit(UiDeco)
function DecoTextBox:new(opt)
	UiDeco.new(self)
	opt = opt or {}

	self.font = opt.font or deco.uifont.default.font
	self.textset = opt.textset or deco.uifont.default.set
	self.alignH = opt.alignH or "left"
	self.alignV = opt.alignV or "top"
	self.offsetX = opt.offsetX or 0
	self.offsetY = opt.offsetY or 0
	self.charSpacing = opt.charSpacing or 1
	self.caretBlinkMs = opt.caretBlinkMs or 600
	self.selectionColor = opt.selectionColor or deco.colors.buttonborder
	self.selectHeightOvershoot = 2

	self.rect = sdl.rect(0,0,0,0)
	self.drawbuffer = {}

	self:updateFont()
end

local function subscribe(event, subscription)
	local addSubscription = true
		and type(event) == 'table'
		and type(subscription) == 'function'
		and Event.instanceOf(event, Event) == true
		and event:isSubscribed(subscription) == false

	if addSubscription then
		event:subscribe(subscription)
	end
end

local function unsubscribe(event, subscription)
	local remSubscription = true
		and type(event) == 'table'
		and type(subscription) == 'function'
		and Event.instanceOf(event, Event) == true
		and event:isSubscribed(subscription) == true

	if remSubscription then
		event:unsubscribe(subscription)
	end
end

function DecoTextBox:createMouseEventWrappers()
	if self.mousedown_wrapper == nil then
		self.mousedown_wrapper = function(widget, mx, my, button)
			self:mousedown(widget, mx, my, button)
		end
	end

	if self.mousemove_wrapper == nil then
		self.mousemove_wrapper = function(widget, mx, my)
			self:mousemove(widget, mx, my)
		end
	end
end

function DecoTextBox:apply(widget)
	self.widget = widget
	self:createMouseEventWrappers()
	subscribe(widget.onMousePressEvent, self.mousedown_wrapper)
	subscribe(widget.onMouseMoveEvent, self.mousemove_wrapper)
end

function DecoTextBox:unapply(widget)
	self.widget = nil
	self:createMouseEventWrappers()
	unsubscribe(widget.onMousePressEvent, self.mousedown_wrapper)
	unsubscribe(widget.onMouseMoveEvent, self.mousemove_wrapper)
end

function DecoTextBox:updateFont()
	self.surfaceFont = SurfaceFont:getOrCreate(self.font, self.textset)
	self.surfaceHeight = self.surfaceFont:get("|"):h()
end

function DecoTextBox:mousedown(widget, mx, my, button)
	local caret = self:screenToIndex(mx, my)
	widget:setCaret(caret)
	widget.selection = caret
end

function DecoTextBox:mousemove(widget, mx, my)
	if widget.pressed then
		local caret = self:screenToIndex(mx, my)
		widget:setCaret(caret)
	end
end

function DecoTextBox:setFont(font)
	font = font or deco.uifont.default.font

	if font ~= self.font then
		self.font = font
		updateFont(self)
	end
end

function DecoTextBox:setTextSettings(textset)
	textset = textset or deco.uifont.default.set

	if textset ~= self.textset then
		self.textset = textset
		updateFont(self)
	end
end

function DecoTextBox:setSelectionColor(color)
	self.selectionColor = color or deco.colors.transparent
end

function DecoTextBox:screenToIndex(screenx, screeny)
	local widget = self.widget
	local textfield = widget.textfield
	local textLength = textfield:len()
	local drawbuffer = self.drawbuffer
	local surfaceHeight = self.surfaceHeight
	local charSpacing = self.charSpacing
	local overshoot = self.selectHeightOvershoot
	local x = self.x or 0
	local y = self.y or 0
	local character

	if screeny + overshoot < y then
		character =  0
	elseif screeny - overshoot > y + surfaceHeight then
		character = textLength
	else
		character = binarySearchMin(0, textLength, screenx, function(i)
			return x + drawbuffer[i * 2 + 1] + (drawbuffer[i * 2]:w() + charSpacing) / 2 
		end)
	end

	return character
end

function DecoTextBox:indexToScreen(index)
	local drawbuffer = self.drawbuffer
	local bufferindex = index * 2
	return
		self.x, drawbuffer[bufferindex + 1],
		self.y
end

function DecoTextBox:draw(screen, widget)
	local drawbuffer = self.drawbuffer

	local widgetWidth = widget.w
	local widgetHeight = widget.h
	local widgetLeft = widget.screenx
	local widgetTop = widget.screeny
	local widgetRight = widgetLeft + widgetWidth
	local widgetBottom = widgetTop + widgetHeight

	local alignV = self.alignV
	local alignH = self.alignH

	local selectFrom, selectTo = widget:getSelection()
	local selectionColor = self.selectionColor
	local textfield = widget.textfield
	local surfaceFont = self.surfaceFont
	local charSpacing = self.charSpacing
	local surfaceHeight = self.surfaceHeight
	local caretBlinkMs = self.caretBlinkMs
	local textLength = textfield:len()
	local bufferEnd = textLength * 2 - 2
	local focused = widget.focused
	local isCaret = false
	local caret = widget.caret
	local rect = self.rect
	rect.h = surfaceHeight

	-- localize common functions
	local getSurfaceWidth = nullsurface.w
	local getSurface = surfaceFont.get
	local drawrect = screen.drawrect
	local blit = screen.blit
	local textWidth = 0
	local textHeight = surfaceHeight

	if widget.focused then
		local focusChanged = focused ~= self.focused_prev
		local caretChanged = caret ~= self.caret_prev
		local time = os.clock() * 1000 % caretBlinkMs

		if not self.focustime or focusChanged or caretChanged then
			self.focustime = time
		end

		if (time - self.focustime) % caretBlinkMs * 2 < caretBlinkMs then
			isCaret = true
		end
	end

	self.focused_prev = widget.focused
	self.caret_prev = caret

	-- fill drawbuffer
	for i = 1, textLength do
		local char = textfield:sub(i, i)
		local bufferindex = i * 2 - 2
		local surface = getSurface(surfaceFont, char)
		local surfaceWidth = getSurfaceWidth(surface) + charSpacing

		drawbuffer[bufferindex] = surface
		drawbuffer[bufferindex+1] = textWidth
		textWidth = textWidth + surfaceWidth
	end

	local x = self.offsetX
	local y = self.offsetY

	if alignH == "center" then
		x = x + widgetLeft + math.floor((widgetWidth - textWidth) / 2)
	elseif alignH == "right" then
		x = x + widgetRight - textWidth
	else
		x = x + widgetLeft
	end

	if alignV == "center" then
		y = y + widgetTop + math.floor((widgetHeight - textHeight) / 2)
	elseif alignV == "bottom" then
		y = y + widgetBottom - textHeight
	else
		y = y + widgetTop
	end

	-- add final entry to simplify
	-- caret placement and lookup
	drawbuffer[bufferEnd+2] = nullsurface
	drawbuffer[bufferEnd+3] = textWidth

	-- draw selection
	if selectTo > selectFrom then
		local selectWidth = 0

		rect.x = x + drawbuffer[selectFrom * 2 + 1]
		rect.y = y

		for i = selectFrom * 2, selectTo * 2 - 2, 2 do
			local surface = drawbuffer[i]
			selectWidth = selectWidth + getSurfaceWidth(surface) + charSpacing
		end

		rect.w = selectWidth

		drawrect(screen, selectionColor, rect)
	end

	-- draw text
	for i = 0, bufferEnd, 2 do
		blit(screen, drawbuffer[i], nil, x + drawbuffer[i+1], y)
	end

	-- draw caret
	if isCaret then
		local i = caret * 2
		rect.x = x + drawbuffer[i+1]
		rect.y = y
		rect.w = 1
		drawrect(screen, self.textset.color, rect)
	end

	self.x = x
	self.y = y
	self.drawbuffer = drawbuffer
end

return DecoTextBox, SurfaceFont
