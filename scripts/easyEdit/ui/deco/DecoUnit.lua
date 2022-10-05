
ANIMS.nullUnit = ANIMS.Animation:new{
	Image = "units/nullUnit.png"
}

local NULLTABLE = {}
local PALETTE_INDEX_BASE = 1
local clipRectUnit = sdl.rect(0,0,0,0)
local clipRectWidget = sdl.rect(0,0,0,0)
local colorMapBase = {}
local basePalette = GetColorMap(PALETTE_INDEX_BASE)
for i, gl_color in ipairs(basePalette) do
	local rgb = sdl.rgb(gl_color.r, gl_color.g, gl_color.b)
	colorMapBase[i*2-1] = rgb
	colorMapBase[i*2] = rgb
end

local function buildSdlColorMap(palette)
	local res = shallow_copy(colorMapBase)

	for i = 1, 8 do
		local gl_color = palette[i]
		if gl_color ~= nil then
			res[i*2] = sdl.rgb(gl_color.r, gl_color.g, gl_color.b)
		end
	end

	return res
end

local DecoUnit = Class.inherit(UiDeco)
function DecoUnit:new(unit, opt)
	UiDeco.new(self)
	self:setObject(unit, opt or NULLTABLE)
end

function DecoUnit:updateDefs(opt)
	if opt == nil then return end

	self.clip = opt.clip
	self.scale = opt.scale or 1
	self.alignH = opt.alignH or "center"
	self.alignV = opt.alignV or "center"
	self.outlinesize = opt.outlinesize or opt.scale or 1
	self.outlinesizehl = opt.outlinesize or self.outlinesize
	self.outlinecolor = self.outlinesize and (opt.outlinecolor or deco.colors.buttonborder)
	self.outlinecolorhl = self.outlinesizehl and (opt.outlinecolorhl or deco.colors.buttonborderhl)
	self.pathmissing = opt.pathmissing or "img/nullResource.png"
end

function DecoUnit:setObject(unit, opt)
	self:updateDefs(opt)

	local image
	local imageOffset

	if type(unit) == 'string' then
		image = unit
	elseif type(unit) == 'userdata' then
		image = unit.Image
		imageOffset = unit.ImageOffset
	elseif type(unit) == 'table' then
		image = unit.Image
		imageOffset = unit.ImageOffset
	end

	if image == nil then
		self.isMech = false
		self.path = ""
		self.imageOffset = nil
		self.colorMap = nil
		return
	end

	local anim = ANIMS[image]
	local path

	if anim == nil then
		anim = ANIMS.nullUnit
		imageOffset = 0
	end

	if anim.Image then
		path = "img/"..anim.Image
	else
		path = self.pathmissing
	end

	if path == nil then
		Assert.Error("Path missing")
	end

	self.anim = anim
	self.isMech = false
		or path:sub(1,17) == "img/units/player/"
		or path:sub(1,26) == "img/advanced/units/player/"
	self.path = path
	self:setImageOffset(imageOffset)
end

function DecoUnit:setImageOffset(imageOffset)
	self.imageOffset = imageOffset
	self.colorMap = nil

	if imageOffset and self.isMech then
		local palette = modApi:getPalette(imageOffset + 1)

		if palette then
			self.colorMap = buildSdlColorMap(palette.colorMap)
		end
	end

	self:updateSurfaces()
end

function DecoUnit:updateSurfaces()
	self.surface = sdlext.getSurface{
		path = self.path,
		transformations = {
			{ scale = self.scale },
			{ colormap = self.colorMap },
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
			{ colormap = self.colorMap },
			{
				outline = {
					border = self.outlinesizehl,
					color = self.outlinecolorhl
				}
			}
		}
	}
end

function DecoUnit:isHighlighted(widget)
	-- overridable method
	return widget.hovered
end

function DecoUnit:draw(screen, widget)
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
	local anim = self.anim
	local columns = anim.Frames and #anim.Frames or anim.NumFrames
	local rows = self.isMech and 1 or anim.Height or 1
	local imageOffset = self.isMech and 0 or self.imageOffset or 0
	local w = math.floor(surface:w() / columns)
	local h = math.floor(surface:h() / rows)
	local x
	local y

	if alignH == "selfcenter" then
		x = math.floor(r.x + widget.decorationx - w / 2)
	elseif alignH == "center" then
		x = math.floor(r.x + widget.decorationx + r.w / 2 - w / 2)
	elseif alignH == "right" then
		x = r.x + widget.decorationx + r.w - w
	else
		x = r.x + widget.decorationx
	end

	if alignV == "selfcenter" then
		y = math.floor(r.y + widget.decorationy - h / 2)
	elseif alignV == "center" then
		y = math.floor(r.y + widget.decorationy + r.h / 2 - h / 2)
	elseif alignV == "bottom" then
		y = r.y + widget.decorationy + r.h - h
	else
		y = r.y + widget.decorationy
	end

	clipRectUnit.x = x
	clipRectUnit.y = y
	clipRectUnit.w = w
	clipRectUnit.h = h

	local currentClipRect = screen:getClipRect()
	if currentClipRect then
		clipRectUnit = clipRectUnit:getIntersect(currentClipRect)
	end

	if self.clip then
		clipRectWidget.x = widget_x
		clipRectWidget.y = widget_y
		clipRectWidget.w = widget_w
		clipRectWidget.h = widget_h
		clipRectUnit = clipRectUnit:getIntersect(clipRectWidget)
	end

	screen:clip(clipRectUnit)
	screen:blit(surface, nil, x, y - imageOffset * h)
	screen:unclip()
end

return DecoUnit
