
-- header
local path = GetParentPath(...)
local defs = require(path.."helper_defs")
local format = require(path.."helper_format")
local tooltip = require(path.."helper_tooltip")
local UiEditBox = require(path.."widget/UiEditBox")
local UiDragSource = require(path.."widget/UiDragSource")
local DecoImmutable = require(path.."deco/DecoImmutable")

local setIconDef = format.setIconDef


-- defs
local ENTRY_HEIGHT = defs.ENTRY_HEIGHT
local FONT_TITLE = defs.FONT_TITLE
local TEXT_SETTINGS_TITLE = defs.TEXT_SETTINGS_TITLE


local helpers = {}

function helpers.createUiTitle(text)
	return Ui()
		:heightpx(ENTRY_HEIGHT)
		:decorate{
			DecoImmutable.Frame,
			DecoText(text, FONT_TITLE, TEXT_SETTINGS_TITLE),
		}
end

function helpers.createUiEditBox(class, ...)
	class = class or Ui
	local ui = class(...)
	UiEditBox.registerAsEditBox(ui)

	return ui
end

function helpers.onGroupClicked(self)
	local groupOwner = self:getGroupOwner()

	if groupOwner.onclicked then
		return groupOwner:onclicked()
	end

	return false
end

function helpers.findUiInListAt(list, x)
	local key, value = next(list)
	local smallestDist = INT_MAX
	for k, ui in pairs(list) do
		local dist
		if x < ui.screenx then
			dist = ui.screenx - x
		elseif x > ui.screenx + ui.w then
			dist = x - ui.screenx - ui.w
		else
			-- x is inside ui extents
			key, value = k, ui
			break
		end

		if dist < smallestDist then
			key, value = k, ui
			smallestDist = dist
		end
	end

	return key, value
end

local function onPopupEntryClicked(self)
	local popupButton = self.popupOwner

	popupButton.id = self.id
	popupButton.data = self.data

	if easyEdit.displayedEditorButton then
		popupButton:send()
	end

	popupButton.popupWindow:quit()

	return true
end

function helpers.createPopupEntryFunc_text(iconDef)
	return function(id, data)
		local popupEntry = Ui()
			:format(setIconDef, iconDef)

		popupEntry.id = id
		popupEntry.data = data
		popupEntry.onclicked = onPopupEntryClicked
		popupEntry.padl = 8
		popupEntry.padr = 8
		popupEntry
			:decorate{
				DecoImmutable.Button,
				DecoImmutable.ObjectNameTitleBounceCenterVClip,
			}

		return popupEntry
	end
end

function helpers.createPopupEntryFunc_icon2x(iconDef)
	return function(id, data)
		local popupEntry = Ui()
			:format(setIconDef, iconDef)

		popupEntry.id = id
		popupEntry.data = data
		popupEntry.onclicked = onPopupEntryClicked
		popupEntry:decorate{
			DecoImmutable.Button,
			DecoImmutable.Anchor,
			DecoImmutable.ObjectSurface2xCenterClip,
			DecoImmutable.TransHeader,
			DecoImmutable.ObjectNameLabelBounceCenterHClip,
		}

		return popupEntry
	end
end

function helpers.createPopupEntryFunc_icon1x(iconDef)
	return function(id, data)
		local popupEntry = Ui()
			:format(setIconDef, iconDef)

		popupEntry.id = id
		popupEntry.data = data
		popupEntry.onclicked = onPopupEntryClicked
		popupEntry:decorate{
			DecoImmutable.Button,
			DecoImmutable.Anchor,
			DecoImmutable.ObjectSurface1xCenterClip,
			DecoImmutable.TransHeader,
			DecoImmutable.ObjectNameLabelBounceCenterHClip,
		}

		return popupEntry
	end
end

local function getCreateDragSourceFunc(iconDef, dragObject, tooltip)
	return function(self, objectId)
		local objectList = self.data
		local object = objectList:getObject(objectId)
		local entry = UiDragSource(dragObject)
			:format(setIconDef, iconDef)
			:decorate{ DecoImmutable.ObjectSurface2xOutlineCenter }
			:setCustomTooltip(tooltip)

		entry.data = object
		entry.saveId = objectId
		entry.createObject = dragObject.createObject

		if object and object.getCategory then
			entry.categoryId = object:getCategory()
		end

		return entry
	end
end

function helpers.getCreateUnitDragSourceFunc(iconDef, dragObject)
	return getCreateDragSourceFunc(iconDef, dragObject, tooltip.unitTooltip)
end
function helpers.getCreateMissionDragSourceFunc(iconDef, dragObject)
	return getCreateDragSourceFunc(iconDef, dragObject, tooltip.missionTooltip)
end
function helpers.getCreateStructureDragSourceFunc(iconDef, dragObject)
	return getCreateDragSourceFunc(iconDef, dragObject, tooltip.structureTooltip)
end


local function getCreateDragSourceCopyFunc(iconDef, tooltip)
	return function(self, dragObject)
		local entry = UiDragSource(dragObject)
			:format(setIconDef, iconDef)
			:decorate{ DecoImmutable.ObjectSurface2xOutlineCenter }
			:setCustomTooltip(tooltip)

		entry.data = dragObject.data
		entry.saveId = dragObject.saveId
		entry.categoryId = dragObject.categoryId
		entry.createObject = dragObject.createObject

		return entry
	end
end

function helpers.getCreateUnitDragSourceCopyFunc(iconDef)
	return getCreateDragSourceCopyFunc(iconDef, tooltip.unitTooltip)
end
function helpers.getCreateMissionDragSourceCopyFunc(iconDef)
	return getCreateDragSourceCopyFunc(iconDef, tooltip.missionTooltip)
end
function helpers.getCreateStructureDragSourceCopyFunc(iconDef)
	return getCreateDragSourceCopyFunc(iconDef, tooltip.structureTooltip)
end

return helpers
