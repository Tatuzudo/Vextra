
-- defs
local FONT = sdlext.font("fonts/JustinFont12Bold.ttf", 12)
local TEXT_SETTINGS = deco.uifont.default.set

local DecoBounceLabel = Class.inherit(DecoText)
local clipRect = sdl.rect(0,0,0,0)

function DecoBounceLabel:new(text, font, textset, align)
	self.text = text
	self.font = font or FONT
	self.textset = textset or TEXT_SETTINGS
	self.align = align or "top"

	DecoText.new(self, self.text, self.font, self.textset)
end

function DecoBounceLabel:draw(screen, widget)
	if self.surface == nil then return end

	local r = widget.rect
	local surface = self.surface
	local decorationx = widget.decorationx
	local decorationy = widget.decorationy
	local align = self.align
	local padl = widget.padl
	local padr = widget.padr
	local padt = widget.padt
	local padb = widget.padb
	local x = r.x + padl
	local y = r.y + padt + decorationy
	local w = r.w - padl - padr
	local h = r.h - padt - padb
	local surf_w = surface:w()
	local surf_h = surface:h()

	clipRect.x = x
	clipRect.y = y
	clipRect.w = w
	clipRect.h = h

	if align == "bottom" then
		y = y + h - self.surface:h()
	elseif align == "center" then
		y = y + decorationy + math.floor((h - surf_h) / 2)
	end

	if surf_w > w then
		x = x - (surf_w - w) * (math.sin(os.clock())+1) / 2
	else
		x = x + math.floor((w - surf_w) / 2)
	end

	local currentClipRect = screen:getClipRect()
	if currentClipRect then
		clipRect = clipRect:getIntersect(currentClipRect)
	end

	screen:clip(clipRect)
	screen:blit(surface, nil, x, y)
	screen:unclip()
end

return DecoBounceLabel
