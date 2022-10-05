
local UiDropTarget = Class.inherit(Ui)

function UiDropTarget:new(dropTargetType)
	Ui.new(self)

	self._debugName = "UiDropTarget"
	self.dropTargetType = dropTargetType

	Assert.Equals('string', type(self.dropTargetType), "Argument #1")
end

function UiDropTarget:getDragType()
	return self.dropTargetType
end

function UiDropTarget:onDragObjectDropped(dragObject)
	-- overridable method
end

function UiDropTarget:onDragObjectEntered(dragObject)
	-- overridable method
end

function UiDropTarget:onDragObjectExited(dragObject)
	-- overridable method
end

function UiDropTarget.registerAsDropTarget(ui, dropTargetType)
	ui.dropTargetType = dropTargetType

	for i, fn in pairs(UiDropTarget) do
		ui[i] = fn
	end
end

return UiDropTarget
