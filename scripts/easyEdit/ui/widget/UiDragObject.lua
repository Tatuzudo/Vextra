
local UiDragObject = Class.inherit(Ui)

function UiDragObject:new(dragObjectType)
	Ui.new(self)

	self._debugName = "UiDragObject"
	self.draggable = true
	self.dragObjectType = dragObjectType or "UNDEFINED_TYPE"
	self.wPercent = nil
	self.hPercent = nil
	self:hide()

	Assert.Equals('string', type(self.dragObjectType), "Argument #1")
end

function UiDragObject:getDragType()
	return self.dragObjectType
end

function UiDragObject:onDragSourceGrabbed(dragSource)
	-- overridable method
end

function UiDragObject:onDropTargetDropped(dropTarget)
	-- overridable method
end

function UiDragObject:onDropTargetExited(dropTarget)
	-- overridable method
end

function UiDragObject:onDropTargetEntered(dropTarget)
	-- overridable method
end

function UiDragObject:processDropTargets()
	local dropped = false
		or self.root == nil
		or self.visible == false
		or self.dragged == false

	if dropped then
		local dropTarget = self.dropTarget

		if dropTarget then
			if dropTarget.onDragObjectDropped then
				dropTarget:onDragObjectDropped(self)
			end

			if self.onDropTargetDropped then
				self:onDropTargetDropped(dropTarget)
			end

			self.dropTarget = nil
		end

		return
	end

	local root = self.root
	local hoveredChild = root.draghoveredchild
	local old_dropTarget = self.dropTarget
	local new_dropTarget

	-- Only consider targets with dropTargetType
	-- equal to this element's dragObjectType.
	if hoveredChild then
		local target = hoveredChild:getGroupOwner()
		if target.dropTargetType == self.dragObjectType then
			new_dropTarget = target
		end
	end

	if new_dropTarget == old_dropTarget then
		if new_dropTarget then
			if new_dropTarget.onDragObjectMoved then
				new_dropTarget:onDragObjectMoved(self)
			end

			if self.onDropTargetTraversed then
				self:onDropTargetTraversed(new_dropTarget)
			end
		end
	else
		if old_dropTarget then

			self.dropTarget = new_dropTarget

			if old_dropTarget.onDragObjectExited then
				old_dropTarget:onDragObjectExited(self)
			end

			if self.onDropTargetExited then
				self:onDropTargetExited(old_dropTarget)
			end
		end

		if new_dropTarget then

			self.dropTarget = new_dropTarget

			if new_dropTarget.onDragObjectEntered then
				new_dropTarget:onDragObjectEntered(self)
			end

			if self.onDropTargetEntered then
				self:onDropTargetEntered(new_dropTarget)
			end
		end
	end
end

function UiDragObject:startDrag(mx, my)
	self.dragX = mx
	self.dragY = my

	self:addTo(sdlext.getUiRoot().draggableUi)
	self:show()
	self:setfocus()

	self:onDragSourceGrabbed(self.dragSource)
	self:processDropTargets()
end

function UiDragObject:stopDrag(mx, my)
	self:detach()
	self:hide()
	self:processDropTargets()
end

function UiDragObject:dragWheel()
	self:processDropTargets()
	return false
end

function UiDragObject:wheel()
	return false
end

function UiDragObject:dragMove(mx, my)
	local diffx = mx - self.dragX
	local diffy = my - self.dragY

	self.x = self.x + diffx
	self.y = self.y + diffy
	self.screenx = self.screenx + diffx
	self.screeny = self.screeny + diffy
	self.dragX = mx
	self.dragY = my

	self:processDropTargets()
end

function UiDragObject:keydown(keycode)
	if keycode == SDLKeycodes.ESCAPE then
		self.root:setPressedChild(nil)
		self.root:setDraggedChild(nil)
		self:processDropTargets()
	end

	return true
end

function UiDragObject.registerAsDragObject(ui, dragObjectType)
	ui.dragObjectType = dragObjectType

	for i, fn in pairs(UiDragObject) do
		ui[i] = fn
	end
end

return UiDragObject
