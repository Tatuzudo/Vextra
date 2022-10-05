
local NULLTABLE = {}
local requestScrolling
local UiScrollAreaExt = Class.inherit(UiScrollArea)

function UiScrollAreaExt:new(...)
	UiScrollArea.new(self, ...)
	self._debugName = "UiScrollAreaExt"
end

function UiScrollAreaExt:hasScrollbar()
	return true
		and self.scrollbuttonrect.w > 0
		and self.scrollbuttonrect.h > 0
end

function UiScrollAreaExt:scrollToContain(targetTop, targetHeight)
	local scrollTop = self.screeny
	local scrollBottom = scrollTop + self.h
	local targetBottom = targetTop + targetHeight

	if targetTop < scrollTop then
		local dyLowest = -self.scrollOvershoot
		local dyTarget = self.dy - (scrollTop - targetTop)

		self.dyTarget = math.max(dyLowest, dyTarget)

	elseif targetBottom > scrollBottom then
		local dyHighest = math.max(0, self.innerHeight - self.h + self.scrollOvershoot)
		local dyTarget = self.dy + (targetBottom - scrollBottom)

		self.dyTarget = math.min(dyHighest, dyTarget)
	end
end

function UiScrollAreaExt:scrollTo(targetY)
	return self:scrollToContain(targetY, 0)
end

function UiScrollAreaExt:relayout()
	local crop = self.cropped
	self.cropped = false

	UiScrollArea.relayout(self)

	self.clipRect.x = 0
	self.clipRect.w = sdl.screen():w()

	if crop then
		self.cropped = true
		self.w = math.min(self.w, self.innerWidth)
		self.h = math.min(self.h, self.innerHeight)
	end
end

function UiScrollAreaExt:draw(screen)
	local clipRect = self.clipRect

	local currentClipRect = screen:getClipRect()
	if currentClipRect then
		clipRect = clipRect:getIntersect(currentClipRect)
	end

	screen:clip(clipRect)
	Ui.draw(self, screen)

	if self:hasScrollbar() and self.innerHeight > self.h then
		screen:drawrect(deco.colors.black, self.scrollrect)
		drawborder(screen, deco.colors.white, self.scrollrect, 2)

		if self.scrollPressed then
			screen:drawrect(deco.colors.focus, self.scrollbuttonrect)
		elseif self.scrollHovered then
			screen:drawrect(deco.colors.buttonborderhl, self.scrollbuttonrect)
		else
			screen:drawrect(deco.colors.white, self.scrollbuttonrect)
		end
	end

	screen:unclip()
end

function UiScrollAreaExt:wheel(mx, my, y)
	requestScrolling = self
	local result = Ui.wheel(self, mx, my, y)

	if not self.scrollPressed and requestScrolling == self then
		local upperlimit = math.max(0, self.innerHeight - self.h)
		self.dyTarget = math.max(-self.scrollOvershoot, math.min(upperlimit + self.scrollOvershoot, self.dyTarget - y * self.scrollDistance))
	end

	requestScrolling = nil

	return result
end

function UiScrollAreaExt:mousedown(x, y, button)
	if self:hasScrollbar() == false then
		return false
	end

	return UiScrollArea.mousedown(self, x, y, button)
end


local UiScrollAreaExtH = Class.inherit(UiScrollAreaH)

function UiScrollAreaExtH:new(...)
	UiScrollAreaH.new(self, ...)
	UiScrollAreaH.hasScrollbar = UiScrollAreaExt.hasScrollbar
	self._debugName = "UiScrollAreaExtH"
end

function UiScrollAreaExtH:scrollToContain(targetLeft, targetWidth)
	local scrollLeft = self.screenx
	local scrollRight = scrollLeft + self.w
	local targetRight = targetLeft + targetWidth

	if targetLeft < scrollLeft then
		local dxLowest = -self.scrollOvershoot
		local dxTarget = self.dx - (scrollLeft - targetLeft)

		self.dxTarget = math.max(dxLowest, dxTarget)

	elseif targetRight > scrollRight then
		local dxHighest = math.max(0, self.innerWidth - self.w + self.scrollOvershoot)
		local dxTarget = self.dx + (targetRight - scrollRight)

		self.dxTarget = math.min(dxHighest, dxTarget)
	end
end

function UiScrollAreaExtH:scrollTo(targetX)
	return self:scrollToContain(targetX, 0)
end

function UiScrollAreaExtH:relayout()
	local crop = self.cropped
	self.cropped = false

	UiScrollAreaH.relayout(self)

	self.clipRect.y = 0
	self.clipRect.h = sdl.screen():h()

	if crop then
		self.cropped = true
		self.w = math.min(self.w, self.innerWidth)
		self.h = math.min(self.h, self.innerHeight)
	end
end

function UiScrollAreaExtH:draw(screen)
	local clipRect = self.clipRect

	local currentClipRect = screen:getClipRect()
	if currentClipRect then
		clipRect = clipRect:getIntersect(currentClipRect)
	end
	
	screen:clip(clipRect)
	Ui.draw(self, screen)

	if self:hasScrollbar() and self.innerWidth > self.w then
		screen:drawrect(deco.colors.black, self.scrollrect)
		drawborder(screen, deco.colors.white, self.scrollrect, 2)

		if self.scrollPressed then
			screen:drawrect(deco.colors.focus, self.scrollbuttonrect)
		elseif self.scrollHovered then
			screen:drawrect(deco.colors.buttonborderhl, self.scrollbuttonrect)
		else
			screen:drawrect(deco.colors.white, self.scrollbuttonrect)
		end
	end

	screen:unclip()
end

function UiScrollAreaExtH:wheel(mx, my, y)
	requestScrolling = self
	local result = Ui.wheel(self, mx, my, y)

	if not self.scrollPressed and requestScrolling == self then
		local upperlimit = math.max(0, self.innerWidth - self.w)
		self.dxTarget = math.max(-self.scrollOvershoot, math.min(upperlimit + self.scrollOvershoot, self.dxTarget - y * self.scrollDistance))
	end

	requestScrolling = nil

	return result
end

function UiScrollAreaExt:mousedown(x, y, button)
	if self:hasScrollbar() == false then
		return false
	end

	return UiScrollArea.mousedown(self, x, y, button)
end

return {
	vertical = UiScrollAreaExt,
	horizontal = UiScrollAreaExtH
}
