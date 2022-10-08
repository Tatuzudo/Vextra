
-- header
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local DecoImmutable = require(path.."deco/DecoImmutable")
local DecoTextBox = require(path.."deco/DecoTextBox")
local UiTextBox = require(path.."widget/UiTextBox")
local UiBoxLayout = require(path.."widget/UiBoxLayout")
local UiDragSource = require(path.."widget/UiDragSource")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollArea = UiScrollAreaExt.vertical
local UiScrollAreaH = UiScrollAreaExt.horizontal
local UiContentList = require(path.."widget/UiContentList")

local missionTooltip = helpers.missionTooltip
local getCreateMissionDragSourceFunc = helpers.getCreateMissionDragSourceFunc
local getCreateMissionDragSourceCopyFunc = helpers.getCreateMissionDragSourceCopyFunc
local contentListDragObject = helpers.contentListDragObject
local resetButton_contentList = helpers.resetButton_contentList
local deleteButton_contentList = helpers.deleteButton_contentList
local getSurface = sdlext.getSurface
local getTextSurface = sdl.text

-- defs
local DRAG_TYPE_MISSION = modApi.missions:getDragType()
local TITLE_EDITOR = "Mission List Editor"
local TITLE_CREATE_NEW_LIST = "Create new list"
local FONT_TITLE = helpers.FONT_TITLE
local TEXT_SETTINGS_TITLE = helpers.TEXT_SETTINGS_TITLE
local FONT_LABEL = helpers.FONT_LABEL
local TEXT_SETTINGS_LABEL = helpers.TEXT_SETTINGS_LABEL
local ORIENTATION_VERTICAL = helpers.ORIENTATION_VERTICAL
local ORIENTATION_HORIZONTAL = helpers.ORIENTATION_HORIZONTAL
local ENTRY_HEIGHT = helpers.ENTRY_HEIGHT
local PADDING = 8
local SCROLLBAR_WIDTH = 16
local OBJECT_LIST_HEIGHT = helpers.OBJECT_LIST_HEIGHT
local OBJECT_LIST_PADDING = helpers.OBJECT_LIST_PADDING
local OBJECT_LIST_GAP = helpers.OBJECT_LIST_GAP
local MISSION_ICON_DEF = modApi.missions:getIconDef()
local MISSION_TOOLTIP_DEF = modApi.missions:getTooltipDef()
local TRANSFORM_MISSION = helpers.transform_2x_outline
local TRANSFORM_MISSION_HL = helpers.transform_2x_outline_hl
local TRANSFORM_MISSION_TOOLTIP = helpers.transform_2x
local CONTENT_ENTRY_DEF = copy_table(MISSION_ICON_DEF)
CONTENT_ENTRY_DEF.width = 25
CONTENT_ENTRY_DEF.height = 25
CONTENT_ENTRY_DEF.clip = false

-- ui
local contentListContainers
local missionListEditor = {}
local dragObject = contentListDragObject(modApi.missions:getDragType())
	:setVar("createObject", getCreateMissionDragSourceCopyFunc(CONTENT_ENTRY_DEF))
	:decorate{ DecoImmutable.ObjectSurface2xOutline }

local function resetAll()
	for i = #contentListContainers.children, 1, -1 do
		local contentListContainer = contentListContainers.children[i]
		local contentList = contentListContainer.contentList
		local objectList = contentList.data

		if objectList:isCustom() then
			if objectList:delete() then
				contentListContainer:detach()
			end
		else
			objectList:reset()
			contentList:reset()
			contentList:populate()
		end
	end
end

local function buildFrameContent(parentUi)
	contentListContainers = UiBoxLayout()
	local missions = UiBoxLayout()
	local createNewList = UiTextBox()
	local dropTargets = {}

	local content = UiWeightLayout()
		:hgap(0)
		:beginUi(Ui)
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				:beginUi()
					:heightpx(ENTRY_HEIGHT)
					:decorate{
						DecoImmutable.Frame,
						DecoText("Mission Lists", FONT_TITLE, TEXT_SETTINGS_TITLE),
					}
				:endUi()
				:beginUi(UiScrollArea)
					:decorate{ DecoImmutable.Frame }
					:beginUi(UiBoxLayout)
						:height(nil)
						:vgap(OBJECT_LIST_GAP)
						:padding(PADDING)
						:setVar("padt", OBJECT_LIST_PADDING)
						:setVar("padb", OBJECT_LIST_PADDING)
						:anchorH("center")
						:beginUi(contentListContainers)
							:height(nil)
							:vgap(OBJECT_LIST_GAP)
						:endUi()
						:beginUi()
							:heightpx(OBJECT_LIST_HEIGHT)
							:padding(-5) -- unpad button
							:decorate{ DecoImmutable.GroupButton }
							:beginUi(createNewList)
								:format(function(self) self:setGroupOwner(self.parent) end)
								:setVar("textfield", TITLE_CREATE_NEW_LIST)
								:settooltip("Create a new mission list", nil, true)
								:decorate{
									DecoTextBox{
										font = FONT_TITLE,
										textset = TEXT_SETTINGS_TITLE,
										alignH = "center",
										alignV = "center",
									}
								}
							:endUi()
						:endUi()
					:endUi()
				:endUi()
			:endUi()
		:endUi()
		:beginUi(Ui)
			:widthpx(0
				+ MISSION_ICON_DEF.width * MISSION_ICON_DEF.scale
				+ 4 * PADDING + SCROLLBAR_WIDTH
			)
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				:beginUi()
					:heightpx(ENTRY_HEIGHT)
					:decorate{
						DecoImmutable.Frame,
						DecoText("Missions", FONT_TITLE, TEXT_SETTINGS_TITLE),
					}
				:endUi()
				:beginUi(UiScrollArea)
					:decorate{ DecoImmutable.Frame }
					:beginUi(missions)
						:padding(PADDING)
						:vgap(7)
					:endUi()
				:endUi()
			:endUi()
		:endUi()

	local function addObjectList(objectList)
		local resetButton
		local contentList = UiContentList{
			data = objectList,
			dragObject = dragObject,
			createEntry = getCreateMissionDragSourceFunc(CONTENT_ENTRY_DEF, dragObject),
		}

		if objectList:isCustom() then
			resetButton = deleteButton_contentList()
		else
			resetButton = resetButton_contentList()
		end

		contentList:populate()

		contentListContainers
			:beginUi(UiWeightLayout)
				:makeCullable()
				:heightpx(40)
				:orientation(ORIENTATION_HORIZONTAL)
				:setVar("contentList", contentList)
				:add(resetButton)
				:beginUi(contentList)
					:setVar("isGroupTooltip", true)
					:settooltip("Drag-and-drop missions to edit the mission list"
						.."\n\nMouse-wheel to scroll the list", nil, true)
				:endUi()
			:endUi()
	end

	local missionLists_sorted = to_array(modApi.missionList._children)

	stablesort(missionLists_sorted, function(a, b)
		return alphanum(a:getName():lower(), b:getName():lower())
	end)

	for _, objectList in ipairs(missionLists_sorted) do
		addObjectList(objectList)
	end

	local missions_sorted = to_array(filter_table(modApi.missions._children, function(k, v)
		return v.BossPawn == nil
	end))

	stablesort(missions_sorted, function(a, b)
		return alphanum(a:getName():lower(), b:getName():lower())
	end)

	for _, mission in ipairs(missions_sorted) do
		local missionId = mission._id
		local entry = UiDragSource(dragObject)

		entry.data = mission
		entry.saveId = missionId
		entry.createObject = getCreateMissionDragSourceCopyFunc(CONTENT_ENTRY_DEF)

		entry
			:widthpx(MISSION_ICON_DEF.width * MISSION_ICON_DEF.scale)
			:heightpx(MISSION_ICON_DEF.height * MISSION_ICON_DEF.scale)
			:setCustomTooltip(missionTooltip)
			:decorate{
				DecoImmutable.Button,
				DecoImmutable.Anchor,
				DecoImmutable.ObjectSurface2xOutlineCenterClip,
				DecoImmutable.TransHeader,
				DecoImmutable.ObjectNameLabelBounceCenterHClip,
			}
			:makeCullable()
			:addTo(missions)
	end

	function createNewList:onEnter()
		local name = self.textfield
		if name:len() > 0 and modApi.missionList:get(name) == nil then
			local objectList = modApi.missionList:add(name)
			objectList:lock()
			addObjectList(objectList)
		end

		self.root:setfocus(content)
	end

	createNewList.onFocusChangedEvent:subscribe(function(uiTextBox, focused, focused_prev)
		if focused then
			uiTextBox.textfield = ""
			uiTextBox:setCaret(0)
			uiTextBox.selection = nil
		else
			uiTextBox.textfield = TITLE_CREATE_NEW_LIST
		end
	end)

	function content:keydown(keycode)
		if SDLKeycodes.isEnter(keycode) then
			createNewList:show()
			createNewList:setfocus()

			return true
		end
	end

	return content
end

local function buildFrameButtons(buttonLayout)
	sdlext.buildButton(
		"Default",
		"Reset everything to default\n\nWARNING: This will delete all custom mission lists",
		resetAll
 	):addTo(buttonLayout)
end

local function onExit()
	modApi.missionList:save()
end

-- main button
function missionListEditor.mainButton()

	sdlext.showDialog(function(ui, quit)
		ui.onDialogExit = onExit

		local frame = sdlext.buildButtonDialog(
			TITLE_EDITOR,
			buildFrameContent,
			buildFrameButtons
		)

		function frame:onGameWindowResized(screen, oldSize)
			local minW = 800
			local minH = 600
			local maxW = 1400
			local maxH = 800
			local width = math.min(maxW, math.max(minW, ScreenSizeX() - 200))
			local height = math.min(maxH, math.max(minH, ScreenSizeY() - 100))

			self
				:widthpx(width)
				:heightpx(height)
		end

		frame
			:addTo(ui)
			:anchor("center", "center")
			:onGameWindowResized()
	end)
end

return missionListEditor
