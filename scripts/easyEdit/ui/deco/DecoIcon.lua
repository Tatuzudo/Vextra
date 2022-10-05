
local DecoIcon = Class.inherit(UiDeco)
local clipRect = sdl.rect(0,0,0,0)

function DecoIcon:new(obj, opt)
	UiDeco.new(self)
	self:setObject(obj, opt or {})
end

function DecoIcon:updateDefs(opt)
	if opt == nil then return end

	self.clip = opt.clip
	self.scale = opt.scale or 1
	self.alignH = opt.alignH or "center"
	self.alignV = opt.alignV or "center"
	self.outlinesize = opt.outlinesize or self.scale or 0
	self.outlinesizehl = opt.outlinesizehl or self.outlinesize
	self.outlinecolor = self.outlinesize and (opt.outlinecolor or deco.colors.buttonborder)
	self.outlinecolorhl = self.outlinesizehl and (opt.outlinecolorhl or deco.colors.buttonborderhl)
	self.pathformat = opt.pathformat or "%s"
	self.pathtoken = opt.pathtoken or "_id"
	self.pathmissing = opt.pathmissing or "img/nullResource.png"
end

function DecoIcon:setObject(obj, opt)
	self:updateDefs(opt)

	if obj == nil then
		self.path = nil
	elseif type(obj) == 'string' then
		self.path = obj
	elseif obj:instanceOf(IndexedEntry) then
		local path
		local token = obj[self.pathtoken]

		if token then
			path = string.format(self.pathformat, obj[self.pathtoken])
		else
			path = self.pathmissing
		end

		if path == nil then
			Assert.Error("Path missing")
		end

		self.path = path
	end

	self:updateSurfaces()
end

function DecoIcon:updateSurfaces()
	if self.path == nil then
		self.surface = nil
		self.surfacehl = nil
		return
	end

	self.surface = sdlext.getSurface{
		path = self.path,
		transformations = {
			{ scale = self.scale },
			{
				outline = {
					border = self.outlinesize,
					color = self.outlinecolor
				}
			}
		}
	}

	self.surfacehl = sdlext.getSurface{
		path = self.path,
		transformations = {
			{ scale = self.scale },
			{
				outline = {
					border = self.outlinesizehl,
					color = self.outlinecolorhl
				}
			}
		}
	}
end

function DecoIcon:isHighlighted(widget)
	-- overridable method
	return widget.hovered
end

function DecoIcon:draw(screen, widget)
	local surface = self.surface

	if self:isHighlighted(widget) then
		surface = self.surfacehl
	end

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

	if alignH == "selfcenter" then
		surf_x = math.floor(widget_x - surf_w / 2)
	elseif alignH == "center" then
		surf_x = math.floor(widget_x + widget_w / 2 - surf_w / 2)
	elseif alignH == "right" then
		surf_x = widget_x + widget_w - surf_w
	else
		surf_x = widget_x
	end

	if alignV == "selfcenter" then
		surf_y = math.floor(widget_y - surf_h / 2)
	elseif alignV == "center" then
		surf_y = math.floor(widget_y + widget_h / 2 - surf_h / 2)
	elseif alignV == "bottom" then
		surf_y = widget_y + widget_h - surf_h
	else
		surf_y = widget_y
	end

	surf_x = surf_x + widget.decorationx
	surf_y = surf_y + widget.decorationy

	if self.clip then
		clipRect.x = widget_x
		clipRect.y = widget_y
		clipRect.w = widget_w
		clipRect.h = widget_h

		local currentClipRect = screen:getClipRect()
		if currentClipRect then
			clipRect = clipRect:getIntersect(currentClipRect)
		end

		screen:clip(clipRect)
		screen:blit(surface, nil, surf_x, surf_y)
		screen:unclip()
	else
		screen:blit(surface, nil, surf_x, surf_y)
	end
end

return DecoIcon
