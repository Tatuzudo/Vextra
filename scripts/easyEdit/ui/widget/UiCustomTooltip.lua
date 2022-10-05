
local UiCustomTooltip = Class.inherit(Ui)

function UiCustomTooltip:new()
	Ui.new(self)

	self._debugName = "UiCustomTooltip"
	self.translucent = true
	self.tooltipOffset = 10
end

function UiCustomTooltip:isTooltipUi()
	return true
end

function UiCustomTooltip:relayout()
	local isHidden = false
		or self.visible ~= true
		or self.parent.visible ~= true

	if isHidden then
		return
	end

	if #self.children > 1 then
		Assert.Error("More than one custom tooltip attached")
	end

	local root = self.root
	local hoveredChild = root.hoveredchild

	if hoveredChild == nil then
		return
	end

	local old_customTooltip = self.customTooltip
	local new_customTooltip = hoveredChild.customTooltip

	if new_customTooltip == nil then
		self.customTooltip = nil

		if old_customTooltip then
			old_customTooltip:detach()
		end

		return
	end

	if old_customTooltip ~= new_customTooltip then
		if old_customTooltip then
			old_customTooltip:detach()
		end

		self.customTooltip = new_customTooltip
		self:add(new_customTooltip)
	end

	local tooltip = new_customTooltip
	tooltip.x = 0
	tooltip.y = 0
	tooltip.screenx = 0
	tooltip.screeny = 0

	-- Give both the hovered widget
	-- and the tooltip an opportunity
	-- to redress the tooltip.
	if tooltip.onCustomTooltipShown then
		tooltip:onCustomTooltipShown(hoveredChild)
	end

	if hoveredChild.onCustomTooltipShown then
		hoveredChild:onCustomTooltipShown(tooltip)
	end

	-- Relayout once to give the tooltip
	-- a chance to resize before we align it.
	Ui.relayout(self)

	local screenX = self.w
	local screenY = self.h
	local tooltipWidth = tooltip.w
	local tooltipHeight = tooltip.h
	local offset = self.tooltipOffset
	local x, y
	tooltip.ignoreMouse = true
	tooltip.translucent = true

	if tooltip.staticTooltip then
		-- Align tooltip beside the hovered widget.
		local widgetWidth = hoveredChild.w
		local widgetHeight = hoveredChild.h
		local widgetLeft = hoveredChild.screenx
		local widgetRight = widgetLeft + widgetWidth
		local widgetTop = hoveredChild.screeny
		local widgetBottom = widgetTop + widgetHeight

		if widgetRight + offset + tooltipWidth <= screenX then
			x = widgetRight + offset
			if widgetTop + tooltipHeight <= screenY then
				y = widgetTop
			else
				y = widgetBottom - tooltipHeight
			end
		elseif widgetLeft - offset - tooltipWidth >= 0 then
			x = widgetLeft - offset - tooltipWidth
			if widgetTop + tooltipHeight <= screenY then
				y = widgetTop
			else
				y = widgetBottom - tooltipHeight
			end
		else
			-- Tooltip is very wide
			-- Try align it vertically
			-- Finally adjust x
			if widgetBottom + offset + tooltipHeight <= screenY then
				y = widgetBottom + offset
			else
				y = widgetTop - offset - tooltipHeight
			end

			x = math.max(0, math.min(widgetLeft, screenX - tooltipWidth))
		end
	else
		-- Attach the tooltip to the mouse cursor.
		x = sdl.mouse.x()
		y = sdl.mouse.y()

		if x + tooltipWidth + offset <= screenX then
			x = x + offset
		else
			x = x - tooltipWidth - offset
		end

		if y + tooltipHeight <= screenY then
			y = y
		else
			y = y - tooltipHeight
		end
	end

	-- Set final tooltip position
	-- before relaying out again.
	tooltip.x = x
	tooltip.y = y
	tooltip.screenx = x
	tooltip.screeny = y

	Ui.relayout(self)
end

modApi.events.onUiRootCreated:subscribe(function(screen, uiRoot)
	uiRoot.priorityUi:add(UiCustomTooltip())
end)
