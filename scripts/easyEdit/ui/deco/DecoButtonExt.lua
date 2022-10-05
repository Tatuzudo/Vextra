
local DecoButtonExt = Class.inherit(DecoButton)
function DecoButtonExt:new(...)
	DecoButton.new(self, ...)

	self.targetcolor = nil
		or self.hlcolor
		or deco.colors.buttonhl

	self.bordertargetcolor = nil
		or self.borderhlcolor
		or deco.colors.buttonborderhl
end

function DecoButtonExt:isHighlighted(widget)
	-- overridable method
	return widget.hovered or widget.dragMoving
end

function DecoButtonExt:isDropTarget(widget, draggedElement)
	-- overridable method
	return false
end

function DecoButtonExt:draw(screen, widget)
	local root = widget.root
	local r = widget.rect

	local basecolor = self.color
	local bordercolor = self.bordercolor

	if widget.disabled then
		basecolor = self.disabledcolor
		bordercolor = self.disabledcolor

	elseif self:isHighlighted(widget) then
		basecolor = self.hlcolor
		bordercolor = self.borderhlcolor

	elseif root and root.draggedchild and self:isDropTarget(widget, root.draggedchild) then
		basecolor = self.droptargetcolor
		bordercolor = self.borderdroptargetcolor
	end

	self.rect.x = r.x
	self.rect.y = r.y
	self.rect.w = r.w
	self.rect.h = r.h
	screen:drawrect(bordercolor, self.rect)

	self.rect.x = r.x + 1
	self.rect.y = r.y + 1
	self.rect.w = r.w - 2
	self.rect.h = r.h - 2
	screen:drawrect(basecolor, self.rect)

	if not widget.disabled then
		self.rect.x = r.x + 2
		self.rect.y = r.y + 2
		self.rect.w = r.w - 4
		self.rect.h = r.h - 4
		screen:drawrect(bordercolor, self.rect)

		self.rect.x = r.x + 4
		self.rect.y = r.y + 4
		self.rect.w = r.w - 8
		self.rect.h = r.h - 8
		screen:drawrect(basecolor, self.rect)
	end

	widget.decorationx = widget.decorationx + 8
end

return DecoButtonExt
