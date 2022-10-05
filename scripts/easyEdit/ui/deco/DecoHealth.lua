
-- header
local rect = sdl.rect(0,0,0,0)

-- defs
local WIDTHS = { 12, 7, 5, 4, 3, 2, 2 }
local HEIGHT = 9

local DecoHealth = Class.inherit(UiDeco)

function DecoHealth:new(health, alignH, alignV)
	UiDeco.new(self)
	self.health = health
	self.healthMax = health
	self.alignH = alignH or "center"
	self.alignV = alignV or "bottom"
end

function DecoHealth:isHighlighted(widget)
	return widget.hovered
end

function DecoHealth:draw(screen, widget)
	local r = widget.rect

	local health = self.health or 1
	local healthMax = self.healthMax or 1
	local widthHealth = WIDTHS[healthMax] or 1
	local widthBorder = healthMax * widthHealth + (healthMax - 1) + 4
	local heightBorder = HEIGHT
	local colorBorder = deco.colors.buttonborder
	local colorBg = deco.colors.framebg
	local colorHealth = deco.colors.healthgreen
	local alignH = self.alignH
	local alignV = self.alignV
	local padl = widget.padl
	local padr = widget.padr
	local padt = widget.padt
	local padb = widget.padb
	local widget_x = r.x + padl
	local widget_y = r.y + padt
	local widget_w = r.w - padl - padr
	local widget_h = r.h - padt - padb
	local x
	local y

	if self:isHighlighted(widget) then
		colorBorder = deco.colors.focus
	end

	if alignH == "center" then
		x = math.floor(widget_x + widget_w / 2 - widthBorder / 2)
	elseif alignH == "right" then
		x = widget_x + widget_w - widthBorder
	else
		x = widget_x
	end

	if alignV == "center" then
		y = math.floor(widget_y + widget_h / 2 - heightBorder / 2)
	elseif alignV == "bottom" then
		y = widget_y + widget_h - heightBorder
	else
		y = widget_y
	end

	rect.x = x + widget.decorationx
	rect.y = y + widget.decorationy
	rect.w = widthBorder
	rect.h = heightBorder

	screen:drawrect(colorBorder, rect)

	rect.x = rect.x + 1
	rect.y = rect.y + 1
	rect.w = rect.w - 2
	rect.h = rect.h - 2

	screen:drawrect(colorBg, rect)

	rect.x = rect.x + 1
	rect.y = rect.y + 1
	rect.w = widthHealth
	rect.h = rect.h - 2

	for i = 1, health do
		screen:drawrect(colorHealth, rect)
		rect.x = rect.x + widthHealth + 1
	end
end

return DecoHealth
