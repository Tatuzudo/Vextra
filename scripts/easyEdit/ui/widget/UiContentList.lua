
-- header
local path = GetParentPath(...)
local parentPath = GetParentPath(path)
local helpers = require(parentPath.."helpers")
local UiBoxLayoutLite = require(path.."UiBoxLayoutLite")
local UiDropTarget = require(path.."UiDropTarget")
local UiDragObject = require(path.."UiDragObject")
local UiScrollAreaExt = require(path.."UiScrollAreaExt")
local UiScrollAreaH = UiScrollAreaExt.horizontal
local findUiInListAt = helpers.findUiInListAt
local DecoImmutable = require(parentPath.."deco/DecoImmutable")
local getTextSurface = sdl.text
local totalWidth = sdlext.totalWidth


-- defs
local CASCADE = true
local FONT_LABEL = helpers.FONT_LABEL
local TEXT_SETTINGS_LABEL = helpers.TEXT_SETTINGS_LABEL


local UiCategoryEntries = Class.inherit(Ui)
function UiCategoryEntries:new()
	Ui.new(self)
	self._debugName = "UiCategoryEntries"
	self.step = 0
end

function UiCategoryEntries:relayout()
	local children = self.children
	local w = self.w
	local h = self.h
	local padl = self.padl
	local padr = self.padr
	local padt = self.padt
	local padb = self.padb
	local step = self.step
	local nextX = 0

	for i = 1, #children do
		local child = children[i]
		if child.wPercent ~= nil then
			child.w = (w - padl - padr) * child.wPercent
		end
		if child.hPercent ~= nil then
			child.h = (h - padt - padb) * child.hPercent
		end
	end

	if #children > 0 then
		local child = children[1]
		local deco = child.decorations[1]

		for i = 1, 2 do
			local surface = true
				and deco.id
				and child[deco.id]
				and child[deco.id].surface

			if surface then
				local deco_w = surface:w()
				nextX = deco_w / 2 - step / 2
				break
			end

			deco:updateSurfacesForce(child)
		end
	end

	for i = 1, #children do
		local child = children[i]

		child.screenx = self.screenx + nextX
		child.screeny = self.screeny + h/2 - child.h/2 + child.y

		child:relayout()

		child.rect.x = child.screenx
		child.rect.y = child.screeny
		child.rect.w = child.w
		child.rect.h = child.h

		nextX = nextX + step
	end

	if #children > 0 then
		local child = children[#children]
		local deco = child.decorations[1]

		for i = 1, 2 do
			local surface = true
				and deco.id
				and child[deco.id]
				and child[deco.id].surface

			if surface then
				local deco_w = surface:w()
				nextX = nextX + deco_w / 2 - step / 2
				break
			end

			deco:updateSurfacesForce(child)
		end
	end

	self.w = math.max(step, nextX)
end


local function createContentEntryDefault(self, data)
	return Ui()
		:sizepx(50, 50)
		:decorate{ DecoImmutable.Frame }
end

local function createContentCategoryDefault()
	return Ui()
end

local UiContentList = Class.inherit(UiDropTarget)
function UiContentList:new(opt)
	local dropTargetType
	local dragObject = opt.dragObject

	if dragObject then
		dropTargetType = dragObject:getDragType()
	end

	UiDropTarget.new(self, dropTargetType)
	self._debugName = "UiContentList"

	local scrollarea = UiScrollAreaH()
	local content = UiBoxLayoutLite()
	scrollarea.scrollheight = 0
	scrollarea.padb = 0

	self.createEntry = opt.createEntry or createContentEntryDefault
	self.dragObject = opt.dragObject or UiDragObject()
	self.data = opt.data or {}
	self.step = opt.step or 50
	self.scrollarea = scrollarea
	self.content = content
	self.categories = {}

	self
		:beginUi(UiWeightLayout)
			:decorate{ DecoImmutable.GroupButtonDropTarget }
			:setVar("padt", 0)
			:setVar("padb", 0)
			:setVar("padr", 0)
			:width(1)
			:heightpx(40)
			:setGroupOwner(self)
			:beginUi(scrollarea)
				:beginUi(content)
					:beginUi()
						:widthpx(20)
					:endUi()
				:endUi()
			:endUi()
			:setTranslucent(true, CASCADE)
			:beginUi()
				:widthpx(200)
				:setVar("text_title_bounce_center_clip", tostring(self.data:getName()))
				:setGroupOwner(self)
				:settooltip("Name of content list", nil, true)
				:decorate{ DecoImmutable.TextTitleBounceCenterClip }
			:endUi()
		:endUi()
end

function UiContentList:reset()
	for categoryId, category in pairs(self.categories) do
		for i = #category.children, 1, -1 do
			category.children[i]:detach()
		end
	end
end

function UiContentList:populate()
	local objectList = self.data
	local categories = objectList:getCategories()
	for categoryId, category in pairs(categories) do
		self:addCategory(categoryId)

		for _, id in ipairs(category) do
			self:addEntry(categoryId, id)
		end
	end
end

function UiContentList:getObject(id)
	Assert.Error("Undefined method")
end

function UiContentList:getContainer(categoryId)
	if categoryId then
		return self.categories[categoryId]
	end

	local x = sdl.mouse.x()

	local name, category = findUiInListAt(self.categories, x)
	return category
end

function UiContentList:scrollToContain(x, w)
	self.scrollarea:scrollToContain(x, w)
end

function UiContentList:addCategory(name)
	if self.categories[name] then
		return self
	end

	local labelSurface = sdl.text(FONT_LABEL, TEXT_SETTINGS_LABEL, name)
	local labelWidth = totalWidth(labelSurface)
	local category = UiCategoryEntries()
	category.step = self.step
	category.groupOwner = self
	category.id = name

	self.categories[name] = category
	self.content
		:beginUi()
			:setVar("text_label_center_clip", labelSurface)
			:widthpx(labelWidth)
			:decorate{ DecoImmutable.TextLabelCenterClip }
			:setTranslucent(true)
		:endUi()
		:beginUi(category)
			:setTranslucent(true)
		:endUi()

	return self
end

function UiContentList:addEntry(categoryId, data)
	local category = self.categories[categoryId]

	if category == nil then
		self:addCategory(categoryId)
		category = self.categories[categoryId]
	end

	local entry = self:createEntry(data)
	entry.groupOwner = self
	entry.detachable = true
	entry:addTo(category)

	return self
end

return UiContentList
