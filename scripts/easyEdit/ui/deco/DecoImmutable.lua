
-- A list of immutable surface decorations,
-- that draws surfaces by referencing variables
-- in the parent widget.

-- header
local path = GetParentPath(...)
local parentPath = GetParentPath(path)
local DecoButtonExt = require(path.."DecoButtonExt")
local colorMap = require(path.."colorMap")
local transforms = require(parentPath.."helper_transforms")
local defs = require(parentPath.."helper_defs")
local surfaces = require(parentPath.."helper_surfaces")
local getColorMap = colorMap.get


-- defs
local NULLTABLE = {}
local FONT_TITLE = defs.FONT_TITLE
local TEXT_SETTINGS_TITLE = defs.TEXT_SETTINGS_TITLE
local FONT_LABEL = defs.FONT_LABEL
local TEXT_SETTINGS_LABEL = defs.TEXT_SETTINGS_LABEL
local NULLOBJECT = {
	getImagePath = function() return "img/nullResource.png" end,
	getTooltipImagePath = function() return "img/nullResource.png" end,
	getImageOffset = function() return 0 end,
	getImageColumns = function() return 1 end,
	getImageRows = function() return 1 end,
}


local DecoImmutable = {}
local rect = sdl.rect(0,0,0,0)
local clipRect = sdl.rect(0,0,0,0)
local surfaceDef = {}
local colorMapDef = transforms.colorMapDef


local ObjectDictionary = {}
local Object = Class.inherit(UiDeco)
function Object:new(opt)
	Assert.Equals(type(opt), 'table', "Argument #1")
	Assert.Equals(type(opt.id), 'string', "Invalid id")
	Assert.Equals(ObjectDictionary[opt.id], nil, "Duplicate id")

	UiDeco.new(self)

	for i, v in pairs(opt) do
		self[i] = v
	end

	ObjectDictionary[opt.id] = self
end

function Object:updateSurfacesForce(widget)
	widget[self.id] = nil
	self:updateSurfaces(widget)
end

function Object:updateSurfaces(widget)
	object = widget.data

	local decoDef = widget[self.id]
	if decoDef == nil then
		decoDef = {}
		widget[self.id] = decoDef
	end

	if object == nil then
		object = NULLOBJECT
	end

	if object ~= decoDef.object then
		local getSurface = sdlext.getSurface
		local imagePath = object:getImagePath()
		local isMech = imagePath:find("^img/units/player")

		decoDef.object = object
		decoDef.imageColumns = object:getImageColumns()

		if isMech then
			decoDef.imageOffset = 0
			decoDef.imageRows = 1
			colorMapDef.colormap = getColorMap(object:getImageOffset())
		else
			decoDef.imageOffset = object:getImageOffset()
			decoDef.imageRows = object:getImageRows()
		end

		surfaceDef.path = imagePath
		surfaceDef.transformations = self.transform
		decoDef.surface = getSurface(surfaceDef)
		surfaceDef.transformations = self.transformhl
		decoDef.surfacehl = getSurface(surfaceDef)

		if isMech then
			colorMapDef.colormap = nil
		end
	end
end

function Object:draw(screen, widget)
	self:updateSurfaces(widget)

	local decoDef = widget[self.id]
	local surface = decoDef.surface

	if widget.hovered or widget.forcehl then
		surface = decoDef.surfacehl or decoDef.surface
	-- elseif widget.dragHovered then
		-- surface = decoDef.surfacedraghl or decoDef.surface
	end

	if surface == nil then return end
	local r = widget.rect

	local imageColumns = decoDef.imageColumns or 1
	local imageRows = decoDef.imageRows or 1
	local imageOffset = decoDef.imageOffset or 0
	local align_h = self.align_h
	local align_v = self.align_v
	local padl = widget.padl
	local padr = widget.padr
	local padt = widget.padt
	local padb = widget.padb
	local widget_x = r.x + padl
	local widget_y = r.y + padt
	local widget_w = r.w - padl - padr
	local widget_h = r.h - padt - padb

	local surf_w = math.floor(surface:w() / imageColumns)
	local surf_h = math.floor(surface:h() / imageRows)
	local surf_x
	local surf_y

	imageOffset = math.min(imageOffset, imageRows - 1)

	if self.bounce and surf_w > widget_w then
		surf_x = widget_x - math.floor((surf_w - widget_w) * (math.sin(os.clock())+1) / 2) + widget.decorationx
	elseif align_h == "center" then
		surf_x = widget_x + math.floor(widget_w / 2 - surf_w / 2) + widget.decorationx
	elseif align_h == "right" then
		surf_x = widget_x + widget_w - surf_w + widget.decorationx
	else
		surf_x = widget_x
	end

	if align_v == "center" then
		surf_y = math.floor(widget_y + widget_h / 2 - surf_h / 2) + widget.decorationy
	elseif align_v == "bottom" then
		surf_y = widget_y + widget_h - surf_h + widget.decorationy
	else
		surf_y = widget_y
	end

	clipRect.x = surf_x
	clipRect.y = surf_y
	clipRect.w = surf_w
	clipRect.h = surf_h

	local currentClipRect = screen:getClipRect()
	if currentClipRect then
		clipRect = clipRect:getIntersect(currentClipRect)
	end

	if self.clip then
		rect.x = widget_x
		rect.y = widget_y
		rect.w = widget_w
		rect.h = widget_h
		clipRect = clipRect:getIntersect(rect)
	end

	screen:clip(clipRect)
	screen:blit(surface, nil, surf_x, surf_y - imageOffset * surf_h)
	screen:unclip()
end


local ObjectTooltip = Class.inherit(Object)
function ObjectTooltip:updateSurfaces(widget)
	object = widget.data

	local decoDef = widget[self.id]
	if decoDef == nil then
		decoDef = {}
		widget[self.id] = decoDef
	end

	if object == nil then
		object = NULLOBJECT
	end

	if object ~= decoDef.object then
		local getSurface = sdlext.getSurface
		local imagePath = object:getTooltipImagePath()
		local isMech = imagePath:find("^img/units/player")

		decoDef.object = object
		decoDef.imageColumns = object:getImageColumns()

		if isMech then
			decoDef.imageOffset = 0
			decoDef.imageRows = 1
			colorMapDef.colormap = getColorMap(object:getImageOffset())
		else
			decoDef.imageOffset = object:getImageOffset()
			decoDef.imageRows = object:getImageRows()
		end

		surfaceDef.path = imagePath
		surfaceDef.transformations = self.transform
		decoDef.surface = getSurface(surfaceDef)
		surfaceDef.transformations = self.transformhl
		decoDef.surfacehl = getSurface(surfaceDef)

		if isMech then
			colorMapDef.colormap = nil
		end
	end
end


local ObjectString = Class.inherit(Object)
ObjectString.field = "getName"
function ObjectString:updateSurfaces(widget)
	object = widget.data

	local decoDef = widget[self.id]
	if decoDef == nil then
		decoDef = {}
		widget[self.id] = decoDef
	end

	if object == nil then
		clear_table(decoDef)
		return
	end

	local text
	local fieldValue = object[self.field]
	if type(fieldValue) == 'function' then
		text = fieldValue(object)
	else
		text = fieldValue
	end

	if text ~= decoDef.text then
		decoDef.text = text
		decoDef.imageOffset = 0
		decoDef.imageColumns = 1
		decoDef.imageRows = 1
		decoDef.surface = sdl.text(self.font, self.textset, text)
	end
end


local Text = Class.inherit(Object)
function Text:draw(screen, widget)
	local text = widget[self.id]
	if type(text) == 'string' then
		widget[self.id] = sdl.text(self.font, self.textset, text)
	end

	local surface = widget[self.id]

	if surface == nil then return end
	local r = widget.rect
	local align_h = self.align_h
	local align_v = self.align_v
	local padl = widget.padl
	local padr = widget.padr
	local padt = widget.padt
	local padb = widget.padb
	local widget_x = r.x + padl
	local widget_y = r.y + padt
	local widget_w = r.w - padl - padr
	local widget_h = r.h - padt - padb

	local surf_w = math.floor(surface:w())
	local surf_h = math.floor(surface:h())
	local surf_x
	local surf_y

	if align_h == "center" then
		if self.bounce and surf_w > widget_w then
			surf_x = widget_x - math.floor((surf_w - widget_w) * (math.sin(os.clock())+1) / 2) + widget.decorationx
		else
			surf_x = widget_x + math.floor(widget_w / 2 - surf_w / 2) + widget.decorationx
		end
	elseif align_h == "right" then
		surf_x = widget_x + widget_w - surf_w + widget.decorationx
	else
		surf_x = widget_x
	end

	if align_v == "center" then
		surf_y = math.floor(widget_y + widget_h / 2 - surf_h / 2) + widget.decorationy
	elseif align_v == "bottom" then
		surf_y = widget_y + widget_h - surf_h + widget.decorationy
	else
		surf_y = widget_y
	end

	clipRect.x = surf_x
	clipRect.y = surf_y
	clipRect.w = surf_w
	clipRect.h = surf_h

	local currentClipRect = screen:getClipRect()
	if currentClipRect then
		clipRect = clipRect:getIntersect(currentClipRect)
	end

	if self.clip then
		rect.x = widget_x
		rect.y = widget_y
		rect.w = widget_w
		rect.h = widget_h
		clipRect = clipRect:getIntersect(rect)
	end

	screen:clip(clipRect)
	screen:blit(surface, nil, surf_x, surf_y)
	screen:unclip()
end


-- 19 height half black transparent header
local TransHeader = Class.inherit(UiDeco)
function TransHeader:draw(screen, widget)
	local r = widget.rect
	local padr = widget.padr
	local padl = widget.padl
	local padt = widget.padt
	local padb = widget.padb

	clipRect.x = r.x + padr
	clipRect.y = r.y + padt
	clipRect.w = r.w - padr - padl
	clipRect.h = math.min(r.h - padt - padb, 19)

	screen:drawrect(deco.colors.halfblack, clipRect)
end


-- left/top aligned
local SurfaceReward = Class.inherit(UiDeco)
function SurfaceReward:draw(screen, widget)
	local decoDef = widget.decoDef or widget
	local surface = decoDef.surface_reward

	if widget.hovered or widget.forcehl then
		surface = decoDef.surfacehl_reward or decoDef.surface_reward
	elseif widget.dragHovered then
		surface = decoDef.surfacedraghl_reward or decoDef.surface_reward
	end

	if surface == nil then return end
	local r = widget.rect
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

	local x = widget_x + widget_w - surf_w + widget.decorationx - 6
	local y = widget_y + widget_h - surf_h + widget.decorationy - 10

	screen:blit(surface, nil, x, y)
end


-- static content list
local ContentList = Class.inherit(UiDeco)
function ContentList:draw(screen, widget)
	local decoDef = widget.decoDef or widget

	if decoDef == nil or decoDef.data == nil then
		return
	end

	local data = decoDef.data

	if data ~= decoDef.data_prev then
		decoDef.data_prev = data

		local categories = data:getCategories()
		local surfaces = {}
		local surfaceshl = {}
		local imageOffsets = {}
		local animHeights = {}
		local objects = data:getContentType()
		local getObject = data.getObject
		local getSurface = sdlext.getSurface
		local transform = decoDef.transform or self.transform
		local transformHl = decoDef.transformHl or self.transformHl
		local surfaceDef = surfaceDef

		decoDef.surfaces = surfaces
		decoDef.surfaceshl = surfaceshl
		decoDef.imageOffsets = imageOffsets
		decoDef.animHeights = animHeights

		for _, category in pairs(categories) do
			for _, objectId in ipairs(category) do
				local object = getObject(data, objectId) or NULLOBJECT
				surfaceDef.path = object:getImagePath()
				surfaceDef.transformations = transform
				table.insert(surfaces, getSurface(surfaceDef))
				surfaceDef.transformations = transformHl
				table.insert(surfaceshl, getSurface(surfaceDef))
				table.insert(imageOffsets, object:getImageOffset())
				table.insert(animHeights, object:getImageRows())
			end
		end
	end

	local r = widget.rect
	local padl = widget.padl
	local padr = widget.padr
	local padt = widget.padt
	local padb = widget.padb
	local widget_x = r.x + padl
	local widget_y = r.y + padt
	local widget_w = r.w - padl - padr
	local widget_h = r.h - padt - padb
	local min_x = 0
	local min_y = 0
	local max_x = INT_MAX
	local max_y = INT_MAX
	local surfaces = decoDef.surfaces
	local imageOffsets = decoDef.imageOffsets
	local animHeights = decoDef.animHeights
	local step = decoDef.step or self.step

	if widget:isGroupHovered() then
		surfaces = decoDef.surfaceshl
	end

	local currentClipRect = screen:getClipRect()
	if currentClipRect then
		min_x = currentClipRect.x
		min_y = currentClipRect.y
		max_x = min_x + currentClipRect.w
		max_y = min_y + currentClipRect.h
	end

	for i, surface in ipairs(surfaces) do
		local animHeight = animHeights[i]
		local imageOffset = math.min(imageOffsets[i], animHeight - 1)
		local w = surface:w()
		local h = surface:h() / animHeight
		local x = widget_x + i * step - step
		local y = math.floor(widget_y + widget_h / 2 - h / 2)
		local draw_x = x
		local draw_y = y - imageOffset * h

		if y < min_y then
			h = math.max(0, y + h - min_y)
			y = min_y
		elseif y + h > max_y then
			h = math.max(0, max_y - y)
		end

		if x < min_x then
			w = math.max(0, x + w - min_x)
			x = min_x
		elseif x + w > max_x then
			w = math.max(0, max_x - x)
		end

		clipRect.x = x
		clipRect.y = y
		clipRect.w = w
		clipRect.h = h

		screen:clip(clipRect)
		screen:blit(surface, nil, draw_x, draw_y)
		screen:unclip()
	end

	widget:widthpx(#surfaces * step)
end

local GroupButton = DecoButtonExt()
function GroupButton:isHighlighted(widget)
	return widget:isGroupHovered()
end


local color = deco.colors.buttonborder
local colorhl = deco.colors.buttonborderhl
local GroupButtonDropTarget = DecoButtonExt()
GroupButtonDropTarget.droptargetcolor = deco.colors.buttonhl
GroupButtonDropTarget.borderdroptargetcolor = sdl.rgb(
	color.r * 3/4 + colorhl.r * 1/4,
	color.g * 3/4 + colorhl.g * 1/4,
	color.b * 3/4 + colorhl.b * 1/4
)

function GroupButtonDropTarget:isHighlighted(widget)
	return widget:isGroupHovered() or widget:isGroupDragHovered()
end

function GroupButtonDropTarget:isDropTarget(widget, draggedElement)
	return draggedElement ~= nil
end

-- object surface 1x
local ObjectSurface1x = Object{
	id = "surface_1x",
}
local ObjectSurface1xClip = Object{
	id = "surface_1x_clip",
	clip = true,
}
local ObjectSurface1xCenter = Object{
	id = "surface_1x_center",
	align_h = "center",
	align_v = "center",
}
local ObjectSurface1xCenterClip = Object{
	id = "surface_1x_center_clip",
	align_h = "center",
	align_v = "center",
	clip = true,
}
local ObjectSurface1xOutline = Object{
	id = "surface_1x_outline",
	transform = transforms.transform_1x_outline,
	transformhl = transforms.transform_1x_outline_hl,
}
local ObjectSurface1xOutlineClip = Object{
	id = "surface_1x_outline_clip",
	transform = transforms.transform_1x_outline,
	transformhl = transforms.transform_1x_outline_hl,
	clip = true,
}
local ObjectSurface1xOutlineCenter = Object{
	id = "surface_1x_outline_center",
	transform = transforms.transform_1x_outline,
	transformhl = transforms.transform_1x_outline_hl,
	align_h = "center",
	align_v = "center",
}
local ObjectSurface1xOutlineCenterClip = Object{
	id = "surface_1x_outline_center_clip",
	transform = transforms.transform_1x_outline,
	transformhl = transforms.transform_1x_outline_hl,
	align_h = "center",
	align_v = "center",
	clip = true,
}
-- object surface 2x
local ObjectSurface2x = Object{
	id = "surface_2x",
	transform = transforms.transform_2x,
	transformhl = transforms.transform_2x,
}
local ObjectSurface2xClip = Object{
	id = "surface_2x_clip",
	transform = transforms.transform_2x,
	transformhl = transforms.transform_2x,
	clip = true,
}
local ObjectSurface2xCenter = Object{
	id = "surface_2x_center",
	transform = transforms.transform_2x,
	transformhl = transforms.transform_2x,
	align_h = "center",
	align_v = "center",
}
local ObjectSurface2xCenterClip = Object{
	id = "surface_2x_center_clip",
	transform = transforms.transform_2x,
	transformhl = transforms.transform_2x,
	align_h = "center",
	align_v = "center",
	clip = true,
}
local ObjectSurface2xOutline = Object{
	id = "surface_2x_outline",
	transform = transforms.transform_2x_outline,
	transformhl = transforms.transform_2x_outline_hl,
}
local ObjectSurface2xOutlineClip = Object{
	id = "surface_2x_outline_clip",
	transform = transforms.transform_2x_outline,
	transformhl = transforms.transform_2x_outline_hl,
	clip = true,
}
local ObjectSurface2xOutlineCenter = Object{
	id = "surface_2x_outline_center",
	transform = transforms.transform_2x_outline,
	transformhl = transforms.transform_2x_outline_hl,
	align_h = "center",
	align_v = "center",
}
local ObjectSurface2xOutlineCenterClip = Object{
	id = "surface_2x_outline_center_clip",
	transform = transforms.transform_2x_outline,
	transformhl = transforms.transform_2x_outline_hl,
	align_h = "center",
	align_v = "center",
	clip = true,
}
-- object name label
local ObjectNameLabel = ObjectString{
	id = "name_label",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
}
local ObjectNameLabelClip = ObjectString{
	id = "name_label_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	clip = true,
}
local ObjectNameLabelCenter = ObjectString{
	id = "name_label_center",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	align_v = "center",
}
local ObjectNameLabelCenterClip = ObjectString{
	id = "name_label_center_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	align_v = "center",
	clip = true,
}
local ObjectNameLabelCenterH = ObjectString{
	id = "name_label_centerh",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
}
local ObjectNameLabelCenterHClip = ObjectString{
	id = "name_label_centerh_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	clip = true,
}
local ObjectNameLabelCenterV = ObjectString{
	id = "name_label_centerv",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_v = "center",
}
local ObjectNameLabelCenterVClip = ObjectString{
	id = "name_label_centerv_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_v = "center",
	clip = true,
}
-- object name label bounce
local ObjectNameLabelBounce = ObjectString{
	id = "name_label_bounce",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	bounce = true,
}
local ObjectNameLabelBounceClip = ObjectString{
	id = "name_label_bounce_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	bounce = true,
	clip = true,
}
local ObjectNameLabelBounceCenter = ObjectString{
	id = "name_label_bounce_center",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	align_v = "center",
	bounce = true,
}
local ObjectNameLabelBounceCenterClip = ObjectString{
	id = "name_label_bounce_center_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	align_v = "center",
	bounce = true,
	clip = true,
}
local ObjectNameLabelBounceCenterH = ObjectString{
	id = "name_label_bounce_centerh",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	bounce = true,
}
local ObjectNameLabelBounceCenterHClip = ObjectString{
	id = "name_label_bounce_centerh_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	bounce = true,
	clip = true,
}
local ObjectNameLabelBounceCenterV = ObjectString{
	id = "name_label_bounce_centerv",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_v = "center",
	bounce = true,
}
local ObjectNameLabelBounceCenterVClip = ObjectString{
	id = "name_label_bounce_centerv_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_v = "center",
	bounce = true,
	clip = true,
}
local ObjectNameLabelBounceCenterBottomClip = ObjectString{
	id = "name_label_bounce_center_bottom_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	align_v = "bottom",
	bounce = true,
	clip = true,
}
-- object name title
local ObjectNameTitle = ObjectString{
	id = "name_title",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
}
local ObjectNameTitleClip = ObjectString{
	id = "name_title_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	clip = true,
}
local ObjectNameTitleCenter = ObjectString{
	id = "name_title_center",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	align_v = "center",
}
local ObjectNameTitleCenterClip = ObjectString{
	id = "name_title_center_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	align_v = "center",
	clip = true,
}
local ObjectNameTitleCenterH = ObjectString{
	id = "name_title_centerh",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
}
local ObjectNameTitleCenterHClip = ObjectString{
	id = "name_title_centerh_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	clip = true,
}
local ObjectNameTitleCenterV = ObjectString{
	id = "name_title_centerv",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_v = "center",
}
local ObjectNameTitleCenterVClip = ObjectString{
	id = "name_title_centerv_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_v = "center",
	clip = true,
}
-- object name title bounce
local ObjectNameTitleBounce = ObjectString{
	id = "name_title_bounce",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	bounce = true,
}
local ObjectNameTitleBounceClip = ObjectString{
	id = "name_title_bounce_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	bounce = true,
	clip = true,
}
local ObjectNameTitleBounceCenter = ObjectString{
	id = "name_title_bounce_center",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	align_v = "center",
	bounce = true,
}
local ObjectNameTitleBounceCenterClip = ObjectString{
	id = "name_title_bounce_center_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	align_v = "center",
	bounce = true,
	clip = true,
}
local ObjectNameTitleBounceCenterH = ObjectString{
	id = "name_title_bounce_centerh",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	bounce = true,
}
local ObjectNameTitleBounceCenterHClip = ObjectString{
	id = "name_title_bounce_centerh_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	bounce = true,
	clip = true,
}
local ObjectNameTitleBounceCenterV = ObjectString{
	id = "name_title_bounce_centerv",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_v = "center",
	bounce = true,
}
local ObjectNameTitleBounceCenterVClip = ObjectString{
	id = "name_title_bounce_centerv_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_v = "center",
	bounce = true,
	clip = true,
}
-- text label
local TextLabel = Text{
	id = "text_label",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
}
local TextLabelClip = Text{
	id = "text_label_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	clip = true,
}
local TextLabelCenter = Text{
	id = "text_label_center",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	align_v = "center",
}
local TextLabelCenterClip = Text{
	id = "text_label_center_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	align_v = "center",
	clip = true,
}
local TextLabelCenterH = Text{
	id = "text_label_centerh",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
}
local TextLabelCenterHClip = Text{
	id = "text_label_centerh_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	clip = true,
}
local TextLabelCenterV = Text{
	id = "text_label_centerv",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_v = "center",
}
local TextLabelCenterVClip = Text{
	id = "text_label_centerv_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_v = "center",
	clip = true,
}
-- text label bounce
local TextLabelBounce = Text{
	id = "text_label_bounce",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	bounce = true,
}
local TextLabelBounceClip = Text{
	id = "text_label_bounce_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	bounce = true,
	clip = true,
}
local TextLabelBounceCenter = Text{
	id = "text_label_bounce_center",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	align_v = "center",
	bounce = true,
}
local TextLabelBounceCenterClip = Text{
	id = "text_label_bounce_center_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	align_v = "center",
	bounce = true,
	clip = true,
}
local TextLabelBounceCenterH = Text{
	id = "text_label_bounce_centerh",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	bounce = true,
}
local TextLabelBounceCenterHClip = Text{
	id = "text_label_bounce_centerh_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	bounce = true,
	clip = true,
}
local TextLabelBounceCenterV = Text{
	id = "text_label_bounce_centerv",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_v = "center",
	bounce = true,
}
local TextLabelBounceCenterVClip = Text{
	id = "text_label_bounce_centerv_clip",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_v = "center",
	bounce = true,
	clip = true,
}
-- text title
local TextTitle = Text{
	id = "text_title",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
}
local TextTitleClip = Text{
	id = "text_title_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	clip = true,
}
local TextTitleCenter = Text{
	id = "text_title_center",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	align_v = "center",
}
local TextTitleCenterClip = Text{
	id = "text_title_center_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	align_v = "center",
	clip = true,
}
local TextTitleCenterH = Text{
	id = "text_title_centerh",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
}
local TextTitleCenterHClip = Text{
	id = "text_title_centerh_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	clip = true,
}
local TextTitleCenterV = Text{
	id = "text_title_centerv",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_v = "center",
}
local TextTitleCenterVClip = Text{
	id = "text_title_centerv_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_v = "center",
	clip = true,
}
-- text title bounce
local TextTitleBounce = Text{
	id = "text_title_bounce",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	bounce = true,
}
local TextTitleBounceClip = Text{
	id = "text_title_bounce_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	bounce = true,
	clip = true,
}
local TextTitleBounceCenter = Text{
	id = "text_title_bounce_center",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	align_v = "center",
	bounce = true,
}
local TextTitleBounceCenterClip = Text{
	id = "text_title_bounce_center_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	align_v = "center",
	bounce = true,
	clip = true,
}
local TextTitleBounceCenterH = Text{
	id = "text_title_bounce_centerh",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	bounce = true,
}
local TextTitleBounceCenterHClip = Text{
	id = "text_title_bounce_centerh_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_h = "center",
	bounce = true,
	clip = true,
}
local TextTitleBounceCenterV = Text{
	id = "text_title_bounce_centerv",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_v = "center",
	bounce = true,
}
local TextTitleBounceCenterVClip = Text{
	id = "text_title_bounce_centerv_clip",
	font = FONT_TITLE,
	textset = TEXT_SETTINGS_TITLE,
	align_v = "center",
	bounce = true,
	clip = true,
}
-- other
local TooltipObject = ObjectTooltip{
	id = "tooltip_object",
	transform = transforms.transform_2x_outline,
	transformhl = transforms.transform_2x_outline_hl,
	align_h = "center",
	align_v = "center",
	clip = true,
}
local TooltipMission = ObjectTooltip{
	id = "tooltip_mission",
	transform = transforms.transform_2x,
	transformhl = transforms.transform_2x,
	align_h = "center",
	align_v = "center",
	clip = true,
}
local IslandCompositeIsland = Object{
	id = "island_composite_island",
	transform = transforms.transform_2x,
	transformhl = transforms.transform_2x_outline_hl,
	align_h = "center",
	align_v = "center",
	clip = true,
}
local UnitImage = ObjectString{
	id = "unit_image",
	field = "Image",
	font = FONT_LABEL,
	textset = TEXT_SETTINGS_LABEL,
	align_h = "center",
	bounce = true,
	clip = true,
}

local Delete = DecoSurfaceAligned(nil, "center", "center")
function Delete:draw(screen, widget)
	if widget.hovered then
		self.surface = surfaces.surfaceDeleteSmallHl
	else
		self.surface = surfaces.surfaceDeleteSmall
	end

	DecoSurfaceAligned.draw(self, screen, widget)
end

local WarningLarge = DecoSurfaceAligned(nil, "center", "center")
function WarningLarge:draw(screen, widget)
	if widget.hovered then
		self.surface = surfaces.surfaceWarningHl
	else
		self.surface = surfaces.surfaceWarning
	end

	DecoSurfaceAligned.draw(self, screen, widget)
end

local ContentList1x = ContentList()
ContentList1x.transform = transforms.transform_1x_outline
ContentList1x.transformHl = transforms.transform_1x_outline_hl
ContentList1x.step = 25

local ContentList2x = ContentList()
ContentList2x.transform = transforms.transform_2x_outline
ContentList2x.transformHl = transforms.transform_2x_outline_hl
ContentList2x.step = 50

return {
	Object = Object,
	ObjectString = ObjectString,
	Text = Text,
	ContentList = ContentList,
	ObjectSurface1x = ObjectSurface1x,
	ObjectSurface1xClip = ObjectSurface1xClip,
	ObjectSurface1xCenter = ObjectSurface1xCenter,
	ObjectSurface1xCenterClip = ObjectSurface1xCenterClip,
	ObjectSurface1xOutline = ObjectSurface1xOutline,
	ObjectSurface1xOutlineClip = ObjectSurface1xOutlineClip,
	ObjectSurface1xOutlineCenter = ObjectSurface1xOutlineCenter,
	ObjectSurface1xOutlineCenterClip = ObjectSurface1xOutlineCenterClip,
	ObjectSurface2x = ObjectSurface2x,
	ObjectSurface2xClip = ObjectSurface2xClip,
	ObjectSurface2xCenter = ObjectSurface2xCenter,
	ObjectSurface2xCenterClip = ObjectSurface2xCenterClip,
	ObjectSurface2xOutline = ObjectSurface2xOutline,
	ObjectSurface2xOutlineClip = ObjectSurface2xOutlineClip,
	ObjectSurface2xOutlineCenter = ObjectSurface2xOutlineCenter,
	ObjectSurface2xOutlineCenterClip = ObjectSurface2xOutlineCenterClip,
	ObjectNameLabel = ObjectNameLabel,
	ObjectNameLabelClip = ObjectNameLabelClip,
	ObjectNameLabelCenter = ObjectNameLabelCenter,
	ObjectNameLabelCenterClip = ObjectNameLabelCenterClip,
	ObjectNameLabelCenterH = ObjectNameLabelCenterH,
	ObjectNameLabelCenterHClip = ObjectNameLabelCenterHClip,
	ObjectNameLabelCenterV = ObjectNameLabelCenterV,
	ObjectNameLabelCenterVClip = ObjectNameLabelCenterVClip,
	ObjectNameLabelBounce = ObjectNameLabelBounce,
	ObjectNameLabelBounceClip = ObjectNameLabelBounceClip,
	ObjectNameLabelBounceCenter = ObjectNameLabelBounceCenter,
	ObjectNameLabelBounceCenterClip = ObjectNameLabelBounceCenterClip,
	ObjectNameLabelBounceCenterH = ObjectNameLabelBounceCenterH,
	ObjectNameLabelBounceCenterHClip = ObjectNameLabelBounceCenterHClip,
	ObjectNameLabelBounceCenterV = ObjectNameLabelBounceCenterV,
	ObjectNameLabelBounceCenterVClip = ObjectNameLabelBounceCenterVClip,
	ObjectNameLabelBounceCenterBottomClip = ObjectNameLabelBounceCenterBottomClip,
	ObjectNameTitle = ObjectNameTitle,
	ObjectNameTitleClip = ObjectNameTitleClip,
	ObjectNameTitleCenter = ObjectNameTitleCenter,
	ObjectNameTitleCenterClip = ObjectNameTitleCenterClip,
	ObjectNameTitleCenterH = ObjectNameTitleCenterH,
	ObjectNameTitleCenterHClip = ObjectNameTitleCenterHClip,
	ObjectNameTitleCenterV = ObjectNameTitleCenterV,
	ObjectNameTitleCenterVClip = ObjectNameTitleCenterVClip,
	ObjectNameTitleBounce = ObjectNameTitleBounce,
	ObjectNameTitleBounceClip = ObjectNameTitleBounceClip,
	ObjectNameTitleBounceCenter = ObjectNameTitleBounceCenter,
	ObjectNameTitleBounceCenterClip = ObjectNameTitleBounceCenterClip,
	ObjectNameTitleBounceCenterH = ObjectNameTitleBounceCenterH,
	ObjectNameTitleBounceCenterHClip = ObjectNameTitleBounceCenterHClip,
	ObjectNameTitleBounceCenterV = ObjectNameTitleBounceCenterV,
	ObjectNameTitleBounceCenterVClip = ObjectNameTitleBounceCenterVClip,
	TextLabel = TextLabel,
	TextLabelClip = TextLabelClip,
	TextLabelCenter = TextLabelCenter,
	TextLabelCenterClip = TextLabelCenterClip,
	TextLabelCenterH = TextLabelCenterH,
	TextLabelCenterHClip = TextLabelCenterHClip,
	TextLabelCenterV = TextLabelCenterV,
	TextLabelCenterVClip = TextLabelCenterVClip,
	TextLabelBounce = TextLabelBounce,
	TextLabelBounceClip = TextLabelBounceClip,
	TextLabelBounceCenter = TextLabelBounceCenter,
	TextLabelBounceCenterClip = TextLabelBounceCenterClip,
	TextLabelBounceCenterH = TextLabelBounceCenterH,
	TextLabelBounceCenterHClip = TextLabelBounceCenterHClip,
	TextLabelBounceCenterV = TextLabelBounceCenterV,
	TextLabelBounceCenterVClip = TextLabelBounceCenterVClip,
	TextTitle = TextTitle,
	TextTitleClip = TextTitleClip,
	TextTitleCenter = TextTitleCenter,
	TextTitleCenterClip = TextTitleCenterClip,
	TextTitleCenterH = TextTitleCenterH,
	TextTitleCenterHClip = TextTitleCenterHClip,
	TextTitleCenterV = TextTitleCenterV,
	TextTitleCenterVClip = TextTitleCenterVClip,
	TextTitleBounce = TextTitleBounce,
	TextTitleBounceClip = TextTitleBounceClip,
	TextTitleBounceCenter = TextTitleBounceCenter,
	TextTitleBounceCenterClip = TextTitleBounceCenterClip,
	TextTitleBounceCenterH = TextTitleBounceCenterH,
	TextTitleBounceCenterHClip = TextTitleBounceCenterHClip,
	TextTitleBounceCenterV = TextTitleBounceCenterV,
	TextTitleBounceCenterVClip = TextTitleBounceCenterVClip,
	TooltipObject = TooltipObject,
	TooltipMission = TooltipMission,
	IslandCompositeIsland = IslandCompositeIsland,
	ContentList1x = ContentList1x,
	ContentList2x = ContentList2x,
	UnitImage = UnitImage,
	GroupButton = GroupButton,
	GroupButtonDropTarget = GroupButtonDropTarget,
	Delete = Delete,
	WarningLarge = WarningLarge,
	StructureReward = SurfaceReward(),
	TransHeader = TransHeader(),
	Button = DecoButton(),
	Frame = DecoFrame(),
	FrameHeader = DecoFrameHeader(),
	Border = DecoBorder(),
	Anchor = DecoAnchor(),
	SolidHalfBlack = DecoSolid(deco.colors.halfblack),
}
