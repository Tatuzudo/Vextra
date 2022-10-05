
-- header
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local UiBoxLayout = require(path.."widget/UiBoxLayout")
local UiEditBox = require(path.."widget/UiEditBox")
local UiEditorButton = require(path.."widget/UiEditorButton")
local UiMultiClickButton = require(path.."widget/UiMultiClickButton")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollAreaH = UiScrollAreaExt.horizontal
local UiScrollArea = UiScrollAreaExt.vertical
local UiPopup = require(path.."widget/UiPopup")
local DecoObj = require(path.."deco/DecoObj")
local DecoEditorButton = require(path.."deco/DecoEditorButton")
local DecoImmutable = require(path.."deco/DecoImmutable")


local addStaticContentList2x = helpers.addStaticContentList2x
local createStaticContentList2x = helpers.createStaticContentList2x
local createPopupEntryFunc_icon1x = helpers.createPopupEntryFunc_icon1x
local createPopupEntryFunc_icon2x = helpers.createPopupEntryFunc_icon2x
local createPopupEntryFunc_text = helpers.createPopupEntryFunc_text
local createUiEditBox = helpers.createUiEditBox
local setIconDef = helpers.setIconDef
local resetButton_entry = helpers.resetButton_entry
local deleteButton_entry = helpers.deleteButton_entry

-- defs
local EDITOR_TITLE = "Island Editor"
local TITLE_CREATE_NEW_ISLAND = "New island"
local ENTRY_HEIGHT = helpers.ENTRY_HEIGHT
local BORDER_SIZE = 2
local SCROLL_BAR_WIDTH = 16
local PADDING = 8
local LABEL_HEIGHT = 20
local ORIENTATION_HORIZONTAL = helpers.ORIENTATION_HORIZONTAL
local ORIENTATION_VERTICAL = helpers.ORIENTATION_VERTICAL
local FONT_TITLE = helpers.FONT_TITLE
local TEXT_SETTINGS_TITLE = helpers.TEXT_SETTINGS_TITLE
local COLOR_RED = helpers.COLOR_RED
local ISLAND_ICON_DEF = modApi.island:getIconDef()
local ISLAND_ICON_DEF_SMALL = copy_table(ISLAND_ICON_DEF)
ISLAND_ICON_DEF_SMALL.width = 61
local CEO_ICON_DEF = modApi.ceo:getIconDef()
local TILESET_ICON_DEF = modApi.tileset:getIconDef()
local CORPORATION_ICON_DEF = modApi.corporation:getIconDef()
local ENEMY_LIST_EXCLUSION = { "finale" }
local BOSS_LIST_EXCLUSION = { "finale1", "finale2" }

-- ui
local currentContent
local islandList
local uiEditBox
local islandEditor = {}
local sortLessThan = get_sort_less_than("_id")

local function format_popupWindow(self)
	self.popupWindow
		:width(0.6)
		:height(0.6)

	self.popupWindow.flowlayout
		:setVar("padl", 50)
		:setVar("padr", 50)
		:setVar("padt", 60)
		:setVar("padb", 70)
		:vgap(60)
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

local function onSend_island(sender, reciever)
	reciever.data.island = sender.data._id
	reciever.decorations[3]:updateSurfacesForce(reciever)
end

local function mkSend_popup(objName)
	return function(sender, reciever)
		reciever.data[objName] = sender.data._id
	end
end

local function mkRecieve_popup(objName)
	return function(reciever, sender)
		local obj = modApi[objName]:get(sender.data[objName])
		reciever.data = obj
	end
end

local function mkSend_list(objName)
	return function(sender, reciever)
		local objList = modApi[objName]:get(sender.data)
		reciever.data[objName] = sender.data._id
		sender.staticContentList.data = sender.data
		sender.staticContentListLabel.data = sender.data
	end
end

local function mkRecieve_list(objName)
	return function(reciever, sender)
		local objList = modApi[objName]:get(sender.data[objName])
		reciever.staticContentList.data = objList
		reciever.staticContentListLabel.data = objList
	end
end

local function onRecieve_id(reciever, sender)
	local text = sender.data:getName()
	if text ~= nil then
		text = "Island: "..text
	end
	reciever.text_title_bounce_centerv_clip = text
end

local onSend = {
	island = onSend_island,
	corporation = mkSend_popup("corporation"),
	ceo = mkSend_popup("ceo"),
	tileset = mkSend_popup("tileset"),
	enemyList = mkSend_list("enemyList"),
	missionList = mkSend_list("missionList"),
	bossList = mkSend_list("bossList"),
	structureList = mkSend_list("structureList"),
}

local onRecieve = {
	id = onRecieve_id,
	island = mkRecieve_popup("island"),
	corporation = mkRecieve_popup("corporation"),
	ceo = mkRecieve_popup("ceo"),
	tileset = mkRecieve_popup("tileset"),
	enemyList = mkRecieve_list("enemyList"),
	missionList = mkRecieve_list("missionList"),
	bossList = mkRecieve_list("bossList"),
	structureList = mkRecieve_list("structureList"),
}

local function reset(reciever)
	reciever = reciever or easyEdit.displayedEditorButton
	if reciever == nil then return end

	local objectList = reciever.data

	if objectList:isCustom() then
		local isCurrentContentRemoved = false
			or reciever == easyEdit.selectedEditorButton
			or reciever == easyEdit.displayedEditorButton

		if isCurrentContentRemoved then
			easyEdit.selectedEditorButton = nil
			easyEdit.displayedEditorButton = nil
			currentContent:hide()
		end
		if objectList:delete() then
			reciever:detach()
		end
	else
		objectList:reset()
		reciever.decorations[3]:updateSurfacesForce(reciever)
	end

	for _, ui in pairs(uiEditBox) do
		ui:recieve()
	end
end

local function resetAll()
	for i = #islandList.children, 1, -1 do
		reset(islandList.children[i])
	end
end

local function onclicked_resetButton(self)
	reset(self.parent)
	return true
end

local function draw_resetButton(self, screen)
	if self.parent:isGroupHovered() then
		UiMultiClickButton.draw(self, screen)
	end
end

local function isHighlighted_decoEditorButton(self, widget)
	return widget:isGroupHovered()
end

local function buildFrameContent(parentUi)
	islandList = UiBoxLayout()
	currentContent = UiScrollArea()

	local icon_island_width = ISLAND_ICON_DEF.width * ISLAND_ICON_DEF.scale
	local icon_island_height = ISLAND_ICON_DEF.height * ISLAND_ICON_DEF.scale
	local createNewIsland = UiTextBox()

	local enemyLists_sorted = to_array(filter_table(modApi.enemyList._children, function(k, v)
		return not list_contains(ENEMY_LIST_EXCLUSION, k)
	end))

	stablesort(enemyLists_sorted, function(a, b)
		return alphanum(a:getName():lower(), b:getName():lower())
	end)

	local bossLists_sorted = to_array(filter_table(modApi.bossList._children, function(k, v)
		return not list_contains(BOSS_LIST_EXCLUSION, k)
	end))

	stablesort(bossLists_sorted, function(a, b)
		return alphanum(a:getName():lower(), b:getName():lower())
	end)

	local missionLists_sorted = to_array(modApi.missionList._children)

	stablesort(missionLists_sorted, function(a, b)
		return alphanum(a:getName():lower(), b:getName():lower())
	end)

	local structureLists_sorted = to_array(modApi.structureList._children)

	stablesort(structureLists_sorted, function(a, b)
		return alphanum(a:getName():lower(), b:getName():lower())
	end)


	uiEditBox = {
		id = createUiEditBox(),
		corporation = createUiEditBox(UiPopup, "Corporations"),
		island = createUiEditBox(UiPopup, "Islands"),
		ceo = createUiEditBox(UiPopup, "Ceos"),
		tileset = createUiEditBox(UiPopup, "Tilesets"),
		enemyList = createUiEditBox(UiPopup, "Enemy Lists"),
		missionList = createUiEditBox(UiPopup, "Mission Lists"),
		bossList = createUiEditBox(UiPopup, "Boss Lists"),
		structureList = createUiEditBox(UiPopup, "Structure Lists"),
	}

	local content = UiWeightLayout()
		:hgap(0)
		-- left (list of islands)
		:beginUi(Ui)
			:widthpx(0
				+ icon_island_width
				+ SCROLL_BAR_WIDTH
				+ BORDER_SIZE
				+ 4 * PADDING
			)
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				:beginUi()
					:heightpx(ENTRY_HEIGHT)
					:setVar("padl", 8)
					:setVar("padr", 8)
					:setVar("text_title_centerv", "Islands")
					:decorate{
						DecoImmutable.Frame,
						DecoImmutable.TextTitleCenterV,
					}
				:endUi()
				:beginUi()
					:heightpx(40)
					:padding(-5) -- unpad button
					:decorate{ DecoImmutable.GroupButton }
					:beginUi(createNewIsland)
						:format(function(self) self.groupOwner = self.parent end)
						:setVar("textfield", TITLE_CREATE_NEW_ISLAND)
						:setAlphabet(UiTextBox._ALPHABET_CHARS.."_")
						:settooltip("Create a new island", nil, true)
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
				:beginUi(UiScrollArea)
					:decorate{ DecoImmutable.Frame }
					:beginUi(islandList)
						:padding(PADDING)
						:vgap(7)
						:anchorH("left")
					:endUi()
				:endUi()
			:endUi()
		:endUi()
		:beginUi()
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				:beginUi(uiEditBox.id)
					:heightpx(ENTRY_HEIGHT)
					:setVar("padl", 8)
					:setVar("padr", 8)
					:setVar("onRecieve", onRecieve.id)
					:setVar("text_title_bounce_centerv_clip", "Selected Island")
					:decorate{
						DecoImmutable.Frame,
						DecoImmutable.TextTitleBounceCenterVClip,
					}
				:endUi()
				:beginUi(currentContent)
					:hide()
					:beginUi(UiBoxLayout)
						:padding(PADDING)
						:vgap(0)
						:beginUi()
							:heightpx(2)
							:decorate{ DecoSolid(deco.colors.buttonborder) }
						:endUi()
						:beginUi(UiWeightLayout)
							:heightpx(200)
							:beginUi(UiBoxLayout)
								:width(.24)
								:vgap(7)
								:setVar("padt", 8)
								:beginUi()
									:heightpx(LABEL_HEIGHT)
									:setVar("text_label_center", "ISLAND")
									:decorate{ DecoImmutable.TextLabelCenter }
								:endUi()
								:beginUi(uiEditBox.island)
									:anchorH("center")
									:format(setIconDef, ISLAND_ICON_DEF_SMALL)
									:setVar("onRecieve", onRecieve.island)
									:setVar("onSend", onSend.island)
									:decorate{
										DecoImmutable.Button,
										DecoImmutable.Anchor,
										DecoImmutable.ObjectSurface1xCenterClip,
										DecoImmutable.TransHeader,
										DecoImmutable.ObjectNameLabelBounceCenterHClip,
									}
									:settooltip("Change island graphics", nil, true)
									:addList(
										modApi.island._children,
										createPopupEntryFunc_icon1x(ISLAND_ICON_DEF),
										onPopupEntryClicked
									)
								:endUi()
							:endUi()
							:beginUi()
								:widthpx(2)
								:decorate{ DecoSolid(deco.colors.buttonborder) }
							:endUi()
							:beginUi(UiBoxLayout)
								:width(.24)
								:vgap(7)
								:setVar("padt", 8)
								:beginUi()
									:heightpx(LABEL_HEIGHT)
									:setVar("text_label_center", "CORPORATION")
									:decorate{ DecoImmutable.TextLabelCenter }
								:endUi()
								:beginUi(uiEditBox.corporation)
									:anchorH("center")
									:format(setIconDef, CORPORATION_ICON_DEF)
									:setVar("onRecieve", onRecieve.corporation)
									:setVar("onSend", onSend.corporation)
									:decorate{
										DecoImmutable.Button,
										DecoImmutable.Anchor,
										DecoImmutable.ObjectSurface2xCenterClip,
										DecoImmutable.TransHeader,
										DecoImmutable.ObjectNameLabelBounceCenterHClip,
									}
									:settooltip("Change island corporation", nil, true)
									:addList(
										modApi.corporation._children,
										createPopupEntryFunc_icon2x(CORPORATION_ICON_DEF),
										onPopupEntryClicked
									)
								:endUi()
							:endUi()
							:beginUi()
								:widthpx(2)
								:decorate{ DecoSolid(deco.colors.buttonborder) }
							:endUi()
							:beginUi(UiBoxLayout)
								:width(.24)
								:vgap(7)
								:setVar("padt", 8)
								:beginUi()
									:heightpx(LABEL_HEIGHT)
									:setVar("text_label_center", "CEO")
									:decorate{ DecoImmutable.TextLabelCenter }
								:endUi()
								:beginUi(uiEditBox.ceo)
									:anchorH("center")
									:format(setIconDef, CEO_ICON_DEF)
									:setVar("onRecieve", onRecieve.ceo)
									:setVar("onSend", onSend.ceo)
									:decorate{
										DecoImmutable.Button,
										DecoImmutable.Anchor,
										DecoImmutable.ObjectSurface2xCenterClip,
										DecoImmutable.TransHeader,
										DecoImmutable.ObjectNameLabelBounceCenterHClip,
									}
									:settooltip("Change island ceo", nil, true)
									:addList(
										modApi.ceo._children,
										createPopupEntryFunc_icon2x(CEO_ICON_DEF),
										onPopupEntryClicked
									)
								:endUi()
							:endUi()
							:beginUi()
								:widthpx(2)
								:decorate{ DecoSolid(deco.colors.buttonborder) }
							:endUi()
							:beginUi(UiBoxLayout)
								:width(.24)
								:vgap(7)
								:setVar("padt", 8)
								:beginUi()
									:heightpx(LABEL_HEIGHT)
									:setVar("text_label_center", "TILESET")
									:decorate{ DecoImmutable.TextLabelCenter }
								:endUi()
								:beginUi(uiEditBox.tileset)
									:anchorH("center")
									:format(setIconDef, TILESET_ICON_DEF)
									:setVar("onRecieve", onRecieve.tileset)
									:setVar("onSend", onSend.tileset)
									:decorate{
										DecoImmutable.Button,
										DecoImmutable.Anchor,
										DecoImmutable.ObjectSurface1xCenterClip,
										DecoImmutable.TransHeader,
										DecoImmutable.ObjectNameLabelBounceCenterHClip,
									}
									:settooltip("Change island tileset", nil, true)
									:addList(
										modApi.tileset._children,
										createPopupEntryFunc_icon1x(TILESET_ICON_DEF),
										onPopupEntryClicked
									)
								:endUi()
							:endUi()
						:endUi()
						:beginUi(UiBoxLayout)
							:heightpx(400)
							:padding(20)
							:vgap(40)
							:beginUi(uiEditBox.enemyList)
								:heightpx(40)
								:padding(-5)
								:decorate{ DecoImmutable.GroupButton }
								:format(addStaticContentList2x)
								:format(format_popupWindow)
								:setVar("onRecieve", onRecieve.enemyList)
								:setVar("onSend", onSend.enemyList)
								:settooltip("Change the list of enemies available on the island", nil, true)
								:addArray(
									enemyLists_sorted,
									createStaticContentList2x,
									onPopupEntryClicked
								)
							:endUi()
							:beginUi(uiEditBox.bossList)
								:heightpx(40)
								:padding(-5)
								:decorate{ DecoImmutable.GroupButton }
								:format(addStaticContentList2x)
								:format(format_popupWindow)
								:setVar("onRecieve", onRecieve.bossList)
								:setVar("onSend", onSend.bossList)
								:settooltip("Change the list of bosses available on the island", nil, true)
								:addArray(
									bossLists_sorted,
									createStaticContentList2x,
									onPopupEntryClicked
								)
							:endUi()
							:beginUi(uiEditBox.missionList)
								:heightpx(40)
								:padding(-5)
								:decorate{ DecoImmutable.GroupButton }
								:format(addStaticContentList2x)
								:format(format_popupWindow)
								:setVar("onRecieve", onRecieve.missionList)
								:setVar("onSend", onSend.missionList)
								:settooltip("Change the list of missions available on the island", nil, true)
								:addArray(
									missionLists_sorted,
									createStaticContentList2x,
									onPopupEntryClicked
								)
							:endUi()
							:beginUi(uiEditBox.structureList)
								:heightpx(40)
								:padding(-5)
								:decorate{ DecoImmutable.GroupButton }
								:format(addStaticContentList2x)
								:format(format_popupWindow)
								:setVar("onRecieve", onRecieve.structureList)
								:setVar("onSend", onSend.structureList)
								:settooltip("Change the list of structures available on the island", nil, true)
								:addArray(
									structureLists_sorted,
									createStaticContentList2x,
									onPopupEntryClicked
								)
							:endUi()
						:endUi()
					:endUi()
				:endUi()
			:endUi()
		:endUi()

	local function addIslandCompositeObject(islandComposite)
		local entry = UiEditorButton()
		local decoEditorButton = DecoEditorButton()
		local resetButton

		if islandComposite:isCustom() then
			resetButton = deleteButton_entry()
		else
			resetButton = resetButton_entry()
		end

		resetButton.onclicked = onclicked_resetButton
		resetButton.draw = draw_resetButton
		resetButton.tooltip_static = true
		resetButton.groupOwner = entry
		decoEditorButton.isHighlighted = isHighlighted_decoEditorButton

		entry
			:widthpx(icon_island_width)
			:heightpx(icon_island_height)
			:setVar("data", islandComposite)
			:settooltip("Select which island to edit", nil, true)
			:decorate{
				decoEditorButton,
				DecoImmutable.Anchor,
				DecoImmutable.ObjectSurface1xCenterClip,
				DecoImmutable.TransHeader,
				DecoImmutable.ObjectNameLabelBounceCenterHClip,
			}
			:beginUi(resetButton)
				:pospx(2, 2)
				:anchor("left", "bottom")
			:endUi()
			:makeCullable()
			:addTo(islandList)

		return entry
	end

	local islands_sorted = to_sorted_array(modApi.islandComposite._children, sortLessThan)

	-- populate island list
	for _, islandComposite in ipairs(islands_sorted) do
		addIslandCompositeObject(islandComposite)
	end

	function createNewIsland:onEnter()
		local name = self.textfield
		if name:len() > 0 and modApi.islandComposite:get(name) == nil then
			local islandComposite = modApi.islandComposite:add(name)
			local scrollarea = islandList.parent
			islandComposite:lock()
			addIslandCompositeObject(islandComposite)
			scrollarea:scrollTo(scrollarea.innerHeight)
		end

		self.root:setfocus(content)
	end

	createNewIsland.onFocusChangedEvent:subscribe(function(uiTextBox, focused, focused_prev)
		if focused then
			uiTextBox.textfield = ""
			uiTextBox:setCaret(0)
			uiTextBox.selection = nil
		else
			uiTextBox.textfield = TITLE_CREATE_NEW_ISLAND
		end
	end)

	local function onEditorButtonSet(widget)
		if widget then
			currentContent:show()
			for _, ui in pairs(uiEditBox) do
				ui:recieve()
			end
		else
			currentContent:hide()
			uiEditBox.id.text_title_bounce_centerv_clip = "Selected Island"
		end
	end

	easyEdit.events.onEditorButtonSet:unsubscribeAll()
	easyEdit.events.onEditorButtonSet:subscribe(onEditorButtonSet)

	return content
end

local function buildFrameButtons(buttonLayout)

	sdlext.buildButton(
		"Default",
		"Reset everything to default\n\nWARNING: This will delete all custom islands",
		resetAll
 	):addTo(buttonLayout)
end

local function onExit()
	UiEditorButton:resetGlobalVariables()

	modApi.islandComposite:save()
end

function islandEditor.mainButton()
	UiEditorButton:resetGlobalVariables()

	sdlext.showDialog(function(ui, quit)
		ui.onDialogExit = onExit

		local frame = sdlext.buildButtonDialog(
			EDITOR_TITLE,
			buildFrameContent,
			buildFrameButtons
		)

		function frame:onGameWindowResized(screen, oldSize)
			local minW = 800
			local minH = 600
			local maxW = 1000
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

return islandEditor
