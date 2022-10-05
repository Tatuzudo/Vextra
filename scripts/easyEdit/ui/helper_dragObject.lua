
-- A ui class for moving UiDragSource children of UiBoxLayout parents.

-- header
local path = GetParentPath(...)
local UiDragObject = require(path.."widget/UiDragObject")


local function addSaveEntry(ui)

	local obj = ui.data
	local categoryId = ui.parent.id
	local groupOwner = ui:getGroupOwner()
	local objList = groupOwner.data
	local saveId = ui.saveId
	local saveCategories = objList:getCategories()

	table.insert(saveCategories[categoryId], saveId)
end

local function remSaveEntry(ui)

	local obj = ui.data
	local categoryId = ui.parent.id
	local groupOwner = ui:getGroupOwner()
	local objList = groupOwner.data
	local saveId = ui.saveId
	local saveCategories = objList:getCategories()

	remove_element(saveId, saveCategories[categoryId])
end


local helpers = {}

helpers.contentListDragObject = Class.inherit(UiDragObject)
function helpers.contentListDragObject:new(dragObjectType)
	UiDragObject.new(self, dragObjectType)

	self._debugName = "UiDragObject - contentListDragObject"
end

function helpers.contentListDragObject.onDragSourceGrabbed(dragObject, dragSource)
	dragObject.data = dragSource.data
	dragObject.saveId = dragSource.saveId
	dragObject.categoryId = dragSource.categoryId
	dragObject.x = 0
	dragObject.y = 0
	dragObject.dragX = -10
	dragObject.dragY = -20

	if dragSource.detachable and sdlext.isCtrlDown() == false then
		remSaveEntry(dragSource)
		dragObject.heldObject = dragSource
		dragObject.heldObject.forcehl = true
		dragSource:detach()

	elseif dragSource.createObject then
		dragObject.heldObject = dragSource:createObject(dragObject)
		dragObject.heldObject.detachable = true
		dragObject.heldObject.forcehl = true
	end
end

function helpers.contentListDragObject.onDropTargetDropped(dragObject, dropTarget)
	local droppedObject = dragObject.droppedObject

	if droppedObject then
		droppedObject.forcehl = false
	end

	dragObject.droppedObject = nil
	dragObject.heldObject = nil
end

function helpers.contentListDragObject.onDropTargetEntered(dragObject, dropTarget)
	local heldObject = dragObject.heldObject
	if heldObject == nil then
		return
	end

	local container = dropTarget:getContainer(heldObject.categoryId)

	if container == nil then
		return
	end

	local containerOwner = container:getGroupOwner()
	local mouse_x = sdl.mouse.x()
	local children = container.children
	local desiredIndex
	local lastChild = children[#children]
	local screenx

	if #children == 0 then
		desiredIndex = 1
		screenx = container.screenx
	elseif mouse_x > lastChild.screenx + lastChild.w then
		desiredIndex = #children + 1
		screenx = lastChild.screenx + lastChild.w
	else
		desiredIndex = BinarySearchMin(1, #children, mouse_x, function(i)
			return children[i].screenx + children[i].w
		end)
		screenx = children[desiredIndex].screenx
	end

	container:add(heldObject, desiredIndex)

	dragObject.droppedObject = heldObject
	dragObject.droppedObject.groupOwner = dropTarget:getGroupOwner()
	dragObject.heldObject = nil

	addSaveEntry(heldObject)

	if containerOwner.scrollToContain then
		containerOwner:scrollToContain(screenx, heldObject.w)
	end
end

function helpers.contentListDragObject.onDropTargetExited(dragObject, dropTarget)
	local droppedObject = dragObject.droppedObject
	if droppedObject == nil then
		return
	end

	remSaveEntry(droppedObject)
	droppedObject:detach()
	dragObject.heldObject = droppedObject
	dragObject.droppedObject = nil
end

function helpers.contentListDragObject.onDropTargetTraversed(dragObject, dropTarget)
	local droppedObject = dragObject.droppedObject
	if droppedObject == nil then
		return
	end

	local container = dropTarget:getContainer(droppedObject.categoryId)

	if container == nil then
		return
	end

	local containerOwner = container:getGroupOwner()
	local children = container.children
	local mouse_x = sdl.mouse.x()
	local currentIndex = list_indexof(children, droppedObject)
	local desiredIndex
	local screenx

	if currentIndex == -1 then
		local lastChild = children[#children]

		if #children == 0 then
			desiredIndex = 1
			screenx = container.screenx
		elseif mouse_x > lastChild.screenx + lastChild.w then
			desiredIndex = #children + 1
			screenx = lastChild.screenx + lastChild.w
		else
			desiredIndex = BinarySearchMin(1, #children, mouse_x, function(i)
				return children[i].screenx + children[i].w
			end)
			screenx = children[desiredIndex].screenx
		end

		remSaveEntry(droppedObject)

		droppedObject
			:detach()
			:addTo(container, desiredIndex)

		addSaveEntry(droppedObject)
	else
		desiredIndex = BinarySearchMax(1, #children, mouse_x, function(i)
			return children[i].screenx
		end)
		screenx = children[desiredIndex].screenx

		if currentIndex ~= desiredIndex then
			local dist = desiredIndex - currentIndex
			local sign = dist / math.abs(dist)

			for i = currentIndex + sign, desiredIndex, sign do
				children[i].screenx, children[i-sign].screenx = children[i-sign].screenx, children[i].screenx
				children[i], children[i-sign] = children[i-sign], children[i]
			end
		end
	end

	if containerOwner.scrollToContain then
		containerOwner:scrollToContain(screenx, droppedObject.w)
	end
end

return helpers
