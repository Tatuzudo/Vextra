
-- Changes to Ui Class
-- Targets mod loader v2.6.4

-- The mod loader's Ui Class defaults to
-- being of size 0,0.
-- Rarely is this desired, and a lot of
-- Ui object start by inheriting the size
-- of the parent ui element.

-- This file changes the default behavior
-- of the Ui Class to inherit the size of
-- its parent by default, by setting both
-- wPercent and hPercent to 1.

-- In order to leave the option to set
-- fixed values with widthpx and
-- heightpx, these functions will now
-- clear wPercent and hPercent,
-- respectively.

-- Ui
-- changed widthpx
-- changed heightpx
-- added sizepx
-- extended setfocus
-- added beginUi
-- added endUi
-- added setVar
-- added format
-- added updateDragHoverState
-- added updateGroupHoverState
-- added onGameWindowResized
-- added gameWindowResized
-- added isTooltipUi
-- extended updateTooltipState
-- added setGroupOwner
-- added getGroupOwner
-- added isGroupHovered
-- added isGroupDragHovered
-- added setCustomTooltip
-- added addDeco
-- added replaceDeco
-- added insertDeco
-- added removeDeco
-- added compact
-- added makeCullable

-- UiRoot
-- added setDragHoveredChild
-- extended updateStates
-- changed relayoutDragDropPriorityUi
-- changed relayoutTooltipUi

-- UiTooltip
-- added isTooltipui

local old_ui_new = Ui.new
function Ui:new(...)
	old_ui_new(self, ...)
	self.wPercent = 1
	self.hPercent = 1
end

function Ui:widthpx(w)
	self.w = w
	self.wPercent = nil
	return self
end

function Ui:heightpx(h)
	self.h = h
	self.hPercent = nil
	return self
end

function Ui:sizepx(w, h)
	self.w = w
	self.h = h
	self.wPercent = nil
	self.hPercent = nil
	return self
end

local old_Ui_setfocus = Ui.setfocus
function Ui:setfocus()
	if self.root == nil then
		return false
	end

	return old_Ui_setfocus(self)
end

-- Adds a ui instance of class 'class' (or Ui if nil)
-- to itself, and returns the new ui instance.
-- Intended to be used in function chaining when
-- setting up the Ui hierarchy.
function Ui:beginUi(class, ...)
	if class == nil then
		class = Ui
	end

	if Class.instanceOf(class, class.__index) then
		-- if 'class' is a ui instance
		return class:addTo(self)
	elseif Class.isSubclassOf(class, Ui) then
		-- if 'class' is a ui class
		return class(...):addTo(self)
	end

	Assert.True(false, "Invalid Argument #1")
end

-- Ends the current Ui instance when function chaining;
-- returning its parent.
function Ui:endUi()
	return self.parent
end

-- Sets a variable in the table to the given value
function Ui:setVar(var, value)
	self[var] = value
	return self
end

function Ui:format(fn, ...)
	fn(self, ...)
	return self
end

function UiRoot:setDragHoveredChild(child)
	if self.draghoveredchild then
		self.draghoveredchild.dragHovered = false
	end

	self.draghoveredchild = child

	if child then
		child.dragHovered = true
	end
end


-- New terms:
-- UiRoot.draghoveredchild
-- Ui.dragHovered
--
-- While dragging a ui element, UiRoot.hoveredchild
-- will be fixed to this element, and no other
-- elements can be hovered.
-- This update step enumerates every ui element,
-- so that any ui elements other than the one being
-- dragged can be identified as the
-- 'UiRoot.draghoveredchild'. This element will also
-- be flagged as 'dragHovered'
-- 'dragHovered' will be kept up to date regardless
-- if any element is dragged or not.
function Ui:updateDragHoverState()
	local root = self.root
	if root == self then
		root:setDragHoveredChild(nil)
	end

	local exit = false
		or root == nil
		or self.visible ~= true
		or self.ignoreMouse == true
		or self.containsMouse ~= true

	if exit then
		return false
	end

	if root.draggedchild ~= self then
		if self.translucent ~= true then
			root:setDragHoveredChild(self)
		end

		for _, child in ipairs(self.children) do
			if child:updateDragHoverState() then
				return true
			end
		end
	end

	return self.dragHovered
end

function Ui:updateGroupHoverState()
	self.groupHovered = false
	self.groupDragHovered = false

	if self.hovered then
		self:getGroupOwner().groupHovered = true
	end

	if self.dragHovered then
		self:getGroupOwner().groupDragHovered = true
	end

	for _, child in ipairs(self.children) do
		child:updateGroupHoverState()
	end
end

-- Adds more steps to the update phase of uiRoot.
old_UiRoot_updateStates = UiRoot.updateStates
function UiRoot:updateStates()
	old_UiRoot_updateStates(self)

	self:updateDragHoverState()
	self:updateGroupHoverState()
end

function Ui:onGameWindowResized(screen, oldSize)
	-- overridable method
end

function Ui:gameWindowResized(screen, oldSize)
	self:onGameWindowResized(screen, oldSize)

	for _, child in ipairs(self.children) do
		child:gameWindowResized(screen, oldSize)
	end
end

-- The UiTooltip object in the UiRoot object
-- changes its size without the use of widthpx
-- and heightpx, altering w and h directly.
-- wPercent and hPercent must be nil for this
-- to work.
modApi.events.onUiRootCreated:subscribe(function(screen, root)
	root.tooltipUi.wPercent = nil
	root.tooltipUi.hPercent = nil
end)

-- Some of the ui in the mod loader relies on
-- wPercent and hPercent to be nil, so we have
-- to revert the changes done to the base Ui
-- class.
local old_UiBoxLayout_new = UiBoxLayout.new
function UiBoxLayout:new(...)
	old_UiBoxLayout_new(self, ...)
	self.wPercent = nil
	self.hPercent = nil
end

modApi.events.onGameWindowResized:subscribe(function(screen, oldSize)
	sdlext:getUiRoot():gameWindowResized(screen, oldSize)
end)

-- Make it possible to identify tooltip ui
-- unambiguously.
function Ui:isTooltipUi()
	return false
end
function UiTooltip:isTooltipUi()
	return true
end

-- Adjust Ui.updateTooltipState to take into account
-- tooltips which explicitly set tooltip_static
local old_Ui_updateTooltipState = Ui.updateTooltipState
function Ui:updateTooltipState()
	if old_Ui_updateTooltipState(self) then return end

	if self.tooltip_static then
		self.root.tooltip_static = self.tooltip_static
	else
		self.root.tooltip_static = self.draggable and self.dragged
	end
end

function Ui:setGroupOwner(groupOwner)
	self.groupOwner = groupOwner
	return self
end

function Ui:getGroupOwner()
	return self.groupOwner or self
end

function Ui:isGroupHovered()
	return self:getGroupOwner().groupHovered
end

function Ui:isGroupDragHovered()
	return self:getGroupOwner().groupDragHovered
end

function Ui:setCustomTooltip(ui)
	Assert.True(Ui.instanceOf(ui, Ui), "Argument #1")
	self.customTooltip = ui
	return self
end

function Ui:addDeco(decoration)
	self:insertDeco(#self.decorations + 1)

	return self
end

function Ui:replaceDeco(index, decoration)
	self:removeDeco(index)
	self:insertDeco(index, decoration)

	return self
end

function Ui:insertDeco(index, decoration)
	local decorations = self.decorations
	if index < 1 or index > #decorations + 1 then
		index = #decorations + 1
	end

	if decoration then
		table.insert(decorations, decoration)
		decoration:apply(self)
	end

	return self
end

function Ui:removeDeco(index)
	local decorations = self.decorations
	local decoration = decorations[index]

	if decoration then
		table.remove(decorations, index)
		decoration:unapply(self)
	end

	return self
end

-- Adjust UiRoot. Make it so anything added to
-- priorityUi only relays out once per update.
local tooltipUis = {}
local otherUis = {}
function UiRoot:relayoutDragDropPriorityUi()
	clear_table(tooltipUis)
	clear_table(otherUis)

	for _, child in ipairs(self.priorityUi.children) do
		if child:isTooltipUi() then
			tooltipUis[#tooltipUis+1] = child
			child.visible = false
		else
			otherUis[#otherUis+1] = child
			child.visible = true
		end
	end

	self.priorityUi:relayout()

	for _, child in ipairs(tooltipUis) do
		child.visible = true
	end
end

function UiRoot:relayoutTooltipUi()
	for _, child in ipairs(otherUis) do
		child.visible = false
	end

	self.priorityUi:relayout()

	for _, child in ipairs(otherUis) do
		child.visible = true
	end
end

-- Ui.crop does much the same as UiWeightLayout.compact
-- Syncronize names.
function Ui:crop(flag)
	if flag == nil then flag = true end

	self.isCompact = flag
	self.cropped = flag

	return self
end

Ui.compact = Ui.crop

local function relayoutCullable(self)
	self._nocull = self.parent.rect:intersects(self.rect)

	if self._nocull then
		self:_relayout()
	end
end

local function drawCullable(self, screen)
	if self._nocull then
		self:_draw(screen)
	end
end

-- Make ui element cullable by wrapping its
-- relayout and draw functions in a function
-- which checks whether the element intersects
-- its parent. This can be reversed by setting
-- self.relayout = self._relayout
-- self.draw = self._draw
function Ui:makeCullable()
	self._relayout = self.relayout
	self._draw = self.draw
	self.relayout = relayoutCullable
	self.draw = drawCullable

	return self
end
