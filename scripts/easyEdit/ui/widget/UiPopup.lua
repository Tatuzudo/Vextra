
local path = GetParentPath(...)
local parentPath = GetParentPath(path)
local UiScrollAreaExt = require(path.."UiScrollAreaExt")
local UiScrollArea = UiScrollAreaExt.vertical
local UiScrollAreaH = UiScrollAreaExt.horizontal
local DecoImmutable = require(parentPath.."deco/DecoImmutable")
local DecoImmutableFrame = DecoImmutable.Frame
local DecoImmutableFrameHeader = DecoImmutable.FrameHeader
local DecoImmutableButton = DecoImmutable.Button

-- defs
local SCROLL_BAR_WIDTH = 16


local UiPopupWindow = Class.inherit(Ui)

function UiPopupWindow:new(popupOwner, title)
	local scroll = UiScrollArea()
	local flow = UiFlowLayout()

	Ui.new(self)

	self._debugName = "UiPopupWindow"
	self.scrollarea = scroll
	self.flowlayout = flow
	self.popupOwner = popupOwner

	self
		:caption(title)
		:compact()
		:decorate{
			DecoImmutableFrameHeader,
			DecoImmutableFrame
		}
		:beginUi(scroll)
			:compact()
			:beginUi(flow)
				:padding(40)
				:hgap(10)
				:vgap(10)
			:endUi()
		:endUi()
end

function UiPopupWindow:onGameWindowResized(screen)
	local scrollarea = self.scrollarea
	local flowlayout = self.flowlayout
	local count = #flowlayout.children
	local screen_w = screen:w()
	local screen_h = screen:h()

	if count > 0 then
		local entry_w = 0
		local entry_h = 0

		for _, child in ipairs(flowlayout.children) do
			if child.wPercent == nil and child.w > entry_w then
				entry_w = child.w
			end
			if child.hPercent == nil and child.h > entry_h then
				entry_h = child.h
			end
		end

		if entry_w > 0 and entry_h > 0 then
			local padl = flowlayout.padl
			local padr = flowlayout.padr
			local padt = flowlayout.padt
			local padb = flowlayout.padb
			local gapx = flowlayout.gapHorizontal
			local gapy = flowlayout.gapVertical

			local max_precent_w = 0.8
			local max_percent_h = 0.8
			local max_w = screen_w * max_precent_w - padl - padr
			local max_h = screen_h * max_percent_h - padt - padb

			local approxEntry_w = entry_w + gapx
			local approxEntry_h = entry_h + gapy

			local screenAspect = screen_w / screen_h
			local entryAspect = approxEntry_w / approxEntry_h
			local aspectRatio = screenAspect / entryAspect

			local approxCount_x = math.sqrt(count * aspectRatio)
			local approxCount_y = math.sqrt(count / aspectRatio)

			local approxEntries_w = approxCount_x * approxEntry_w
			local approxEntries_h = approxCount_y * approxEntry_h

			approxEntries_w = math.min(approxEntries_w, max_w)
			approxEntries_h = math.min(approxEntries_h, max_h)

			approxCount_x = approxEntries_w / approxEntry_w
			approxCount_y = approxEntries_h / approxEntry_h

			local count_x = math.max(1, math.ceil(approxCount_x))
			local count_y = math.max(1, math.ceil(approxCount_y))

			local width = 0
				+ count_x * entry_w
				+ count_x * gapx - gapx
				+ padl + padr
				+ SCROLL_BAR_WIDTH

			local height = 0
				+ count_y * entry_h
				+ count_y * gapy - gapy
				+ padt + padb

			self:sizepx(width, height)
		end
	end

	local parent = self.parent
	local dummy = Ui()
		:sizepx(screen_w, screen_h)

	if parent then
		self:detach()
	end

	dummy
		:add(self)
		:relayout()

	self
		:detach()

	if parent then
		self:addTo(parent)
	end

	self.x = (screen_w - self.w) / 2
	self.y = (screen_h - self.h) / 2
end

local UiPopupButton = Class.inherit(Ui)

function UiPopupButton:new(title)
	Ui.new(self)

	self._debugName = "UiPopupButton"
	self.popupWindow = UiPopupWindow(self, title)
end

local function onEntryClickedDefault(self)
	-- self in this method is the element that was clicked.
	-- self.owner is the UiPopupWindow element.
	-- defaults to apply the entry's id and data to the
	-- owning UiPopupWindow element, and closing the dialog.

	local popupOwner = self.popupOwner
	popupOwner.data = self.data
	popupOwner.popupWindow:quit()

	return true
end

local function createPopupEntryDefault(id, data)
	local popupEntry = Ui()
		:sizepx(100, 100)
		:padding(-1) -- combines to 4px with DecoButton's 5px padding
		:decorate{ DecoImmutableButton }

	return popupEntry
end

function UiPopupButton:addList(entryList, createEntry, onEntryClicked)
	createEntry = createEntry or createPopupEntryDefault
	onEntryClicked = onEntryClicked or onEntryClickedDefault

	for id, data in pairs(entryList) do
		local popupEntry = createEntry(id, data)

		popupEntry.id = id
		popupEntry.data = data
		popupEntry.onclicked = popupEntry.onclicked or onEntryClicked
		popupEntry.popupOwner = self
		popupEntry:addTo(self.popupWindow.flowlayout)
	end

	return self
end

function UiPopupButton:addArray(entryArray, createEntry, onEntryClicked)
	createEntry = createEntry or createPopupEntryDefault
	onEntryClicked = onEntryClicked or onEntryClickedDefault

	for id, data in ipairs(entryArray) do
		local popupEntry = createEntry(_, data)

		popupEntry.data = data
		popupEntry.onclicked = popupEntry.onclicked or onEntryClicked
		popupEntry.popupOwner = self
		popupEntry:addTo(self.popupWindow.flowlayout)
	end

	return self
end

function UiPopupButton:enumeratePopupEntries(func, ...)
	for _, child in ipairs(self.popupWindow.flowlayout.children) do
		local args = {...}
		for i, v in ipairs(args) do
			args[i] = child[v]
		end
		func(child, unpack(args))
	end

	return self
end

function UiPopupButton:onPopupExit()
	-- overridable method
end

function UiPopupButton:onPopupEnter()
	-- overridable method
end

function UiPopupButton:popupEnter()
	self:onPopupEnter()
end

function UiPopupButton:popupExit()
	self.popupWindow:detach()
	self.popupWindow.quit = nil
	self:onPopupExit()
end	

function UiPopupButton:onclicked()
	if self.disabled then
		return false
	end

	sdlext.showDialog(function(ui, quit)
		ui.onDialogExit = self:popupExit()
		self.popupWindow:addTo(ui)
		self.popupWindow:onGameWindowResized(screen)
		self.popupWindow.quit = quit
		self:popupEnter()
	end)

	return true
end

return UiPopupButton
