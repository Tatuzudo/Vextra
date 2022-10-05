
-- header
local path = GetParentPath(...)
local defs = require(path.."helper_defs")
local surfaces = require(path.."helper_surfaces")
local UiMultiClickButton = require(path.."widget/UiMultiClickButton")
local DecoButtonExt = require(path.."deco/DecoButtonExt")
local DecoMultiClickButton = require(path.."deco/DecoMultiClickButton")
local DecoImmutable = require(path.."deco/DecoImmutable")


-- defs
local OBJECT_LIST_HEIGHT = defs.OBJECT_LIST_HEIGHT
local ORIENTATION_HORIZONTAL = defs.ORIENTATION_HORIZONTAL
local COLOR_RED = defs.COLOR_RED


local DecoImmutableButtonRed = DecoButtonExt(nil, COLOR_RED)


-- forward declare
local DecoImmutableMultiClickReset
local DecoImmutableMultiClickDelete
local DecoImmutableMultiClickResetSmall
local DecoImmutableMultiClickDeleteSmall


modApi.events.onFtldatFinalized:subscribe(function()
	DecoImmutableMultiClickReset = DecoMultiClickButton(
		{
			surfaces.surfaceReset,
			surfaces.surfaceWarning
		},
		{
			surfaces.surfaceResetHl,
			surfaces.surfaceWarningHl
		},
		"center",
		"center"
	)
	DecoImmutableMultiClickDelete = DecoMultiClickButton(
		{
			surfaces.surfaceDelete,
			surfaces.surfaceWarning
		},
		{
			surfaces.surfaceDeleteHl,
			surfaces.surfaceWarningHl
		},
		"center",
		"center"
	)
	DecoImmutableMultiClickResetSmall = DecoMultiClickButton(
		{
			surfaces.surfaceResetSmall,
			surfaces.surfaceWarningSmall
		},
		{
			surfaces.surfaceResetSmallHl,
			surfaces.surfaceWarningSmallHl
		},
		"center",
		"center"
	)
	DecoImmutableMultiClickDeleteSmall = DecoMultiClickButton(
		{
			surfaces.surfaceDeleteSmall,
			surfaces.surfaceWarningSmall
		},
		{
			surfaces.surfaceDeleteSmallHl,
			surfaces.surfaceWarningSmallHl
		},
		"center",
		"center"
	)
end)

local helpers = {}

local resetButton_contentList = Class.inherit(UiMultiClickButton)
function resetButton_contentList:new()
	UiMultiClickButton.new(self, 2)
	self
		:sizepx(OBJECT_LIST_HEIGHT, OBJECT_LIST_HEIGHT)
		:setTooltips{
			"Reset content list",
			"WARNING: clicking once more will reset this content list to its default"
		}
		:decorate{
			DecoImmutableButtonRed,
			DecoImmutable.Anchor,
			DecoImmutableMultiClickReset,
		}
end

function resetButton_contentList:onclicked()
	local contentListContainer = self.parent
	local contentList = contentListContainer.contentList
	local objectList = contentList.data

	objectList:reset()
	contentList:reset()
	contentList:populate()

	return true
end


local deleteButton_contentList = Class.inherit(UiMultiClickButton)
function deleteButton_contentList:new()
	UiMultiClickButton.new(self, 2)
	self
		:sizepx(OBJECT_LIST_HEIGHT, OBJECT_LIST_HEIGHT)
		:setTooltips{
			"Delete content list",
			"WARNING: clicking once more will delete this content list"
		}
		:decorate{
			DecoImmutableButtonRed,
			DecoImmutable.Anchor,
			DecoImmutableMultiClickDelete,
		}
end

function deleteButton_contentList:onclicked()
	local contentListContainer = self.parent
	local contentList = contentListContainer.contentList
	local objectList = contentList.data

	if objectList:delete() then
		contentListContainer:detach()
	end

	return true
end

local resetButton_entry = Class.inherit(UiMultiClickButton)
function resetButton_entry:new()
	UiMultiClickButton.new(self, 2)
	self
		:sizepx(20, 20)
		:setTooltips{
			"Reset this entry",
			"WARNING: clicking once more will reset this entry to its default"
		}
		:decorate{
			DecoImmutable.SolidHalfBlack,
			DecoImmutableMultiClickResetSmall,
		}
end

local deleteButton_entry = Class.inherit(UiMultiClickButton)
function deleteButton_entry:new()
	UiMultiClickButton.new(self, 2)
	self
		:sizepx(20, 20)
		:setTooltips{
			"Delete this entry",
			"WARNING: clicking once more will delete this entry"
		}
		:decorate{
			DecoImmutable.SolidHalfBlack,
			DecoImmutableMultiClickDeleteSmall,
		}
end

return {
	resetButton_contentList = resetButton_contentList,
	deleteButton_contentList = deleteButton_contentList,
	resetButton_entry = resetButton_entry,
	deleteButton_entry = deleteButton_entry,
}
