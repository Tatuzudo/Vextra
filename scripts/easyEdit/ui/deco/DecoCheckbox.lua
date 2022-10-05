
local DecoCheckbox = Class.inherit(UiDeco)
local rect = sdl.rect(0,0,0,0)

function DecoCheckbox:new(width, height, alignH, alignV)
	UiDeco.new(self)

	self.width = width
	self.height = height
	self.alignH = alignH
	self.alignV = alignV
	self.borderOuter = 2
	self.borderInner = 2
	self.color = deco.colors.white
	self.colorhl = deco.colors.buttonborderhl
	self.colorbg = deco.colors.framebg
	self.colordisabled = deco.colors.buttonborderdisabled
end

function DecoCheckbox:isDisabled(widget)
	return widget.disabled
end

function DecoCheckbox:isHighlighted(widget)
	return widget.hovered
end

function DecoCheckbox:draw(screen, widget)
	local color = self.color

	if self:isDisabled(widget) then
		color = self.colordisabled
	elseif self:isHighlighted(widget) then
		color = self.colorhl
	end

	local r = widget.rect
	local colorbg = self.colorbg
	local alignH = self.alignH
	local alignV = self.alignV
	local borderInner = self.borderInner
	local borderOuter = self.borderOuter
	local padl = widget.padl
	local padr = widget.padr
	local padt = widget.padt
	local padb = widget.padb
	local widget_x = r.x + padl
	local widget_y = r.y + padt
	local widget_w = r.w - padl - padr
	local widget_h = r.h - padt - padb
	local check_w = self.width or widget_w
	local check_h = self.height or widget_h
	local check_x
	local check_y

	if alignH == "center" then
		check_x = math.floor(widget_x + widget_w / 2 - check_w / 2)
	elseif alignH == "right" then
		check_x = widget_x + widget_w - check_w
	else
		check_x = widget_x
	end

	if alignV == "center" then
		check_y = math.floor(widget_y + widget_h / 2 - check_h / 2)
	elseif alignV == "bottom" then
		check_y = widget_y + widget_h - check_h
	else
		check_y = widget_y
	end

	rect.x = check_x
	rect.y = check_y
	rect.w = check_w
	rect.h = check_h

	screen:drawrect(color, rect)

	rect.x = check_x + borderOuter
	rect.y = check_y + borderOuter
	rect.w = check_w - borderOuter * 2
	rect.h = check_h - borderOuter * 2

	screen:drawrect(colorbg, rect)

	if widget.checked then
		rect.x = check_x + borderOuter + borderInner
		rect.y = check_y + borderOuter + borderInner
		rect.w = check_w - (borderOuter + borderInner) * 2
		rect.h = check_h - (borderOuter + borderInner) * 2

		screen:drawrect(color, rect)
	end
end

return DecoCheckbox
