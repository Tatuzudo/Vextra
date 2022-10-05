
local UiGroupTooltip = Class.inherit(UiTooltip)

function UiGroupTooltip:new()
	UiTooltip.new(self)

	self:size(nil, nil)
	self._debugName = "UiGroupTooltip"
end

function UiGroupTooltip:relayout()
	local root = self.root
	local hoveredchild = root.hoveredchild
	local groupOwner = hoveredchild and hoveredchild:getGroupOwner()

	local isChildOfGroupTooltip = true
		and root.tooltip == nil
		and groupOwner ~= nil
		and groupOwner ~= hoveredchild
		and groupOwner.isGroupTooltip == true
		and groupOwner.tooltip ~= nil

	if not isChildOfGroupTooltip then
		self.visible = false
		return
	end

	local tooltip = root.tooltip
	local tooltip_title = root.tooltip_title
	local tooltip_static = root.tooltip_static

	-- temporary redirect tooltip to groupOwner
	root:setHoveredChild(groupOwner)
	root.tooltip = groupOwner.tooltip
	root.tooltip_title = groupOwner.tooltip_title
	root.tooltip_static = groupOwner.tooltip_static

	UiTooltip.relayout(self)

	-- revert
	root:setHoveredChild(hoveredchild)
	root.tooltip = tooltip
	root.tooltip_title = tooltip_title
	root.tooltip_static = tooltip_static
end

modApi.events.onUiRootCreated:subscribe(function(screen, uiRoot)
	uiRoot.priorityUi:add(UiGroupTooltip())
end)
