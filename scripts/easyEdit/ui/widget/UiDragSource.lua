
local UiDragSource = Class.inherit(Ui)

function UiDragSource:new(dragObject)
	Ui.new(self)

	self._debugName = "UiDragSource"
	self.draggable = true
	self.dragObject = dragObject
	self.dragSourceType = dragObject.dragObjectType

	Assert.Equals('string', type(self.dragSourceType), "Argument #1")
end

function UiDragSource:getDragType()
	return self.dragSourceType
end

function UiDragSource:startDrag(mx, my, button)
	self.dragObject.x = self.screenx + math.floor((self.w - self.dragObject.w) / 2)
	self.dragObject.y = self.screeny + math.floor((self.h - self.dragObject.h) / 2)
	self.dragObject.dragSource = self

	-- pass pressed and dragged state to dragObject
	self.root:setPressedChild(self.dragObject)
	self.root:setDraggedChild(self.dragObject)
end

function UiDragSource.registerAsDragSource(ui, dragSourceType)
	ui.dragSourceType = dragSourceType

	for i, fn in pairs(UiDragSource) do
		ui[i] = fn
	end
end

return UiDragSource
