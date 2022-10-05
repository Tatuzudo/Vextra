
local rect =  sdl.rect(0, 0, 0, 0)


local DecoOutline = Class.inherit(UiDeco)
function DecoOutline:new(bordercolor, bordersize, borderhlcolor, borderhlsize)
    self.bordercolor = bordercolor or deco.colors.buttonborder
    self.borderhlcolor = borderhlcolor or self.bordercolor
    self.bordersize = bordersize or 2
    self.borderhlsize = borderhlsize or self.bordersize
end

function DecoOutline:draw(screen, widget)
    local r = widget.rect
    local color = self.bordercolor
	local bordersize = self.bordersize

    if widget.hovered then
        color = self.borderhlcolor
        bordersize = self.borderhlsize
    end

    rect.x = r.x - bordersize
    rect.y = r.y - bordersize
    rect.w = r.w + bordersize * 2
    rect.h = r.h + bordersize * 2

    drawborder(screen, color, rect, bordersize)
end

return DecoOutline
