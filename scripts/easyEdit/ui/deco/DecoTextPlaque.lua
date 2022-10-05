
local rect = sdl.rect(0,0,0,0)

local DecoTextPlaque = Class.inherit(DecoAlignedText)
function DecoTextPlaque:new(opt)
	DecoAlignedText.new(self, opt.text, opt.font, opt.textset, opt.alignH, opt.alignV)

	local padding = opt.padding or 0
	local padl = opt.padl or 0
	local padr = opt.padr or 0
	local padt = opt.padt or 0
	local padb = opt.padb or 0

	self.padl = padding + padl
	self.padr = padding + padr
	self.padt = padding + padt
	self.padb = padding + padb

	self.bgcolor = opt.bgcolor or deco.colors.halfblack
end

function DecoTextPlaque:draw(screen, widget)
	local surface = self.surface

	if surface == nil then return end
	local r = widget.rect
	local x, y
	local align_h = self.alignH
	local align_v = self.alignV
	local padl = self.padl
	local padr = self.padr
	local padt = self.padt
	local padb = self.padb
	local widget_x = r.x
	local widget_y = r.y
	local widget_w = r.w
	local widget_h = r.h
	local surf_w = surface:w() + padl + padr
	local surf_h = surface:h() + padt + padb

	if align_h == "center" then
		x = widget_x + math.floor(widget_w / 2 - surf_w / 2)
	elseif align_h == "right" then
		x = widget_x + widget_w - surf_w
	elseif align_h == "right_outside" then
		x = widget_x + widget_w
	elseif align_h == "left_outside" then
		x = widget_x - surf_w
	else
		x = widget_x
	end

	if align_v == "center" then
		y = widget_y + math.floor(widget_h / 2 - surf_h / 2)
	elseif align_v == "bottom" then
		y = widget_y + widget_h - surf_h
	elseif align_v == "bottom_outside" then
		y = widget_y + widget_h
	elseif align_v == "top_outside" then
		y = widget_y - surf_h
	else
		y = widget_y
	end

	x = x + widget.decorationx
	y = y + widget.decorationy

	rect.x = x
	rect.y = y
	rect.w = surf_w
	rect.h = surf_h

	screen:drawrect(self.bgcolor, rect)
	screen:blit(self.surface, nil, x + padl, y + padt)
end

return DecoTextPlaque
