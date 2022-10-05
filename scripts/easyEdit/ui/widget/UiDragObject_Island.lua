
-- header
local path = GetParentPath(...)
local path_prev = GetParentPath(path)
local UiDragObject = require(path.."UiDragObject")
local DecoImmutable = require(path_prev.."deco/DecoImmutable")


local UiDragObject_Island = Class.inherit(UiDragObject)

function UiDragObject_Island:new(...)
	UiDragObject.new(self, ...)
	self.decoIsland = DecoImmutable.ObjectSurface2x
	self
		:size(nil, nil)
		:decorate{ self.decoIsland }
end

function UiDragObject_Island:onDropTargetDropped(dropTarget)
	self.data_prev = nil
end

function UiDragObject_Island:onDropTargetExited(dropTarget)
	dropTarget.data = self.data_prev
end

function UiDragObject_Island:onDropTargetEntered(dropTarget)
	self.data_prev = dropTarget.data
	dropTarget.data = self.data
end

function UiDragObject_Island:onDragSourceGrabbed(dragSource)
	self.data = dragSource.data
	self.decoIsland:updateSurfacesForce(self)

	local decoId = self.decoIsland.id
	local decoDef = self[decoId]
	local surface = decoDef.surface

	self:sizepx(surface:w(), surface:h())

	self.x = dragSource.screenx + math.floor((dragSource.w - self.w) / 2)
	self.y = dragSource.screeny + math.floor((dragSource.h - self.h) / 2)
end

return UiDragObject_Island
