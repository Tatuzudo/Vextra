
-- defs
local FONT_LABEL = sdlext.font("fonts/JustinFont12Bold.ttf", 12)
local TEXT_SETTINGS_LABEL = deco.uifont.default.set

local DecoLabel = Class.inherit(DecoAlignedText)

function DecoLabel:new(text, alignH, alignV)
	DecoAlignedText.new(self, text, FONT_LABEL, TEXT_SETTINGS_LABEL, alignH, alignV)
end

function DecoLabel:draw(screen, widget)
	local surface = self.surface

	if surface == nil then return end
	local r = widget.rect
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

	local surf_w = surface:w()
	local surf_h = surface:h()
	local surf_x
	local surf_y

	if alignH == "center" then
		surf_x = widget.decorationx + math.floor(widget_x + widget_w / 2 - surf_w / 2)
	elseif alignH == "right" then
		surf_x = widget.decorationx + widget_x + widget_w - surf_w
	else
		surf_x = widget.decorationx + widget_x
	end

	if alignV == "center" then
		surf_y = widget.decorationy + math.floor(widget_y + widget_h / 2 - surf_h / 2)
	elseif alignV == "bottom" then
		surf_y = widget.decorationy + widget_y + widget_h - surf_h
	else
		surf_y = widget.decorationy + widget_y
	end

	screen:blit(surface, nil, surf_x, surf_y)
end

return DecoLabel
