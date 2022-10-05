
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local DecoEditorButton = require(path.."deco/DecoEditorButton")
local DecoButtonExt = require(path.."deco/DecoButtonExt")
local DecoMultiClickButton = require(path.."deco/DecoMultiClickButton")
local DecoHealth = require(path.."deco/DecoHealth")
local DecoMove = require(path.."deco/DecoMove")
local DecoCheckbox = require(path.."deco/DecoCheckbox")
local DecoLabel = require(path.."deco/DecoLabel")
local DecoImmutable = require(path.."deco/DecoImmutable")
local DecoTextBox = require(path.."deco/DecoTextBox")
local UiTextBox = require(path.."widget/UiTextBox")
local UiBoxLayout = require(path.."widget/UiBoxLayout")
local UiMultiClickButton = require(path.."widget/UiMultiClickButton")
local UiEditorButton = require(path.."widget/UiEditorButton")
local UiEditBox = require(path.."widget/UiEditBox")
local UiNumberBox = require(path.."widget/UiNumberBox")
local UiWeightLayout = require(path.."widget/UiWeightLayoutExt")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollArea = UiScrollAreaExt.vertical
local UiScrollAreaH = UiScrollAreaExt.horizontal
local UiPopup = require(path.."widget/UiPopup")

local createPopupEntryFunc_icon1x = helpers.createPopupEntryFunc_icon1x
local createPopupEntryFunc_icon2x = helpers.createPopupEntryFunc_icon2x
local setIconDef = helpers.setIconDef
local createUiEditBox = helpers.createUiEditBox
local createUiTitle = helpers.createUiTitle
local decoUnitWithLabel = helpers.decoUnitWithLabel
local decoIconWithLabel = helpers.decoIconWithLabel
local resetButton_entry = helpers.resetButton_entry
local deleteButton_entry = helpers.deleteButton_entry


-- defs
local EDITOR_TITLE = "Mech Editor"
local TITLE_CREATE_NEW_UNIT = "New unit"
local SCROLL_BAR_WIDTH = helpers.SCROLL_BAR_WIDTH
local ENTRY_HEIGHT = helpers.ENTRY_HEIGHT
local PADDING = 8
local ORIENTATION_VERTICAL = helpers.ORIENTATION_VERTICAL
local ORIENTATION_HORIZONTAL = helpers.ORIENTATION_HORIZONTAL
local FONT_TITLE = helpers.FONT_TITLE
local TEXT_SETTINGS_TITLE = helpers.TEXT_SETTINGS_TITLE
local FONT_LABEL = helpers.FONT_LABEL
local TEXT_SETTINGS_LABEL = helpers.TEXT_SETTINGS_LABEL
local TEXT_SETTINGS_NUMBER = deco.textset(deco.colors.white, deco.colors.black, 2, false)
local CHECKBOX_WIDTH = 25
local CHECKBOX_HEIGHT = 25
local CHECKBOX_CONTAINER_WIDTH = 120
local CHECKBOX_CONTAINER_HEIGHT = 50
local COLOR_RED = helpers.COLOR_RED
local UNIT_ICON_DEF = modApi.units:getIconDef()
local WEAPON_ICON_DEF = modApi.weapons:getIconDef()

local CLASSES = { "Prime", "Brute", "Ranged", "Science", "TechnoVek" }

local TEAMS = {
	[TEAM_PLAYER] = "Player",
	[TEAM_ENEMY] = "Enemy",
	[TEAM_NONE] = "None",
}
local IMPACT_MATERIALS = {
	[IMPACT_METAL] = "Metal",
	[IMPACT_INSECT] = "Insect",
	[IMPACT_ROCK] = "Rock",
	[IMPACT_BLOB] = "Blob",
	[IMPACT_FLESH] = "Flesh",
}
local TIERS = {
	[TIER_NORMAL] = "Normal",
	[TIER_ALPHA] = "Alpha",
	[TIER_BOSS] = "Boss",
}
local LEADER = {
	[LEADER_NONE] = "None",
	[LEADER_HEALTH] = "Health",
	[LEADER_VINES] = "Vines",
	[LEADER_ARMOR] = "Armor",
	[LEADER_REGEN] = "Regen",
	[LEADER_EXPLODE] = "Explode",
	[LEADER_TENTACLE] = "Tentacle",
}

-- ui
local currentContent
local unitList
local uiEditBox
local unitEditor = {}

local function onCheckboxClicked(self)
	if easyEdit.displayedEditorButton then
		self:send()
	end

	return true
end

local function onTextBoxEnter(self)
	if easyEdit.displayedEditorButton then
		self:send()
	end
end

local function resetParentData(self)
	self.parent.data = nil
	self.parent:send()
	return true
end

local function onRecieve_id(reciever, sender)
	local text = sender.data._id
	if text ~= nil then
		text = "Mech id: "..text
	end
	reciever.text_title_bounce_centerv_clip = text
end

local function onSend_name(sender, reciever)
	local unit = reciever.data
	local unitId = unit._id
	local name = sender.textfield

	modApi.modLoaderDictionary[unit._id] = name
	unit.Name = name

	sender:updateText(name)
end

local function onRecieve_name(reciever, sender)
	reciever:updateText(sender.data.Name)
end

local function onSend_class(sender, reciever)
	-- unimplemented
end

local function onRecieve_class(reciever, sender)
	reciever:updateText(sender.data.Class)
end

local function onSend_image(sender, reciever)
	reciever.data.Image = sender.data.Image
	reciever.decorations[3]:updateSurfacesForce(reciever)
end

local function onRecieve_image(reciever, sender)
	local unitImage = modApi.unitImage:get(sender.data.Image)
	reciever.data = unitImage
end

local function onSend_weapon(sender, reciever, weaponSlot)
	local weapon = sender.data
	local id = weapon and weapon._id or nil
	reciever.data.SkillList[weaponSlot] = id
end

local function onRecieve_weapon(reciever, sender, weaponSlot)
	local weapon = modApi.weapons:get(sender.data.SkillList[weaponSlot])
	reciever.data = weapon
end

local function onSend_weaponPrimary(sender, reciever)
	onSend_weapon(sender, reciever, 1)
end

local function onSend_weaponSecondary(sender, reciever)
	onSend_weapon(sender, reciever, 2)
end

local function onRecieve_weaponPrimary(reciever, sender)
	onRecieve_weapon(reciever, sender, 1)
end

local function onRecieve_weaponSecondary(reciever, sender)
	onRecieve_weapon(reciever, sender, 2)
end

local function onSend_health(sender, reciever)
	local unit = reciever.data
	local decoHealth = sender.decorations[1]
	local health = tonumber(sender.textfield)
	unit.Health = health
	decoHealth.healthMax = health
	decoHealth.health = health
end

local function onRecieve_health(reciever, sender)
	local unit = sender.data
	local decoHealth = reciever.decorations[1]
	local health = unit.Health
	decoHealth.healthMax = health
	decoHealth.health = health
	reciever.textfield = tostring(health)
end

local function onSend_moveSpeed(sender, reciever)
	local unit = reciever.data
	local moveSpeed = tonumber(sender.textfield)
	unit.MoveSpeed = moveSpeed
end

local function onRecieve_moveSpeed(reciever, sender)
	local unit = sender.data
	reciever.textfield = tostring(unit.MoveSpeed)
end

local function onSend_massive(sender, reciever)
	local unit = reciever.data
	unit.Massive = sender.checked == true
end

local function onSend_pushable(sender, reciever)
	local unit = reciever.data
	unit.Pushable = sender.checked == true
end

local function onSend_armor(sender, reciever)
	local unit = reciever.data
	unit.Armor = sender.checked == true
end

local function onSend_flying(sender, reciever)
	local unit = reciever.data
	unit.Flying = sender.checked == true
end

local function onSend_teleporter(sender, reciever)
	local unit = reciever.data
	unit.Teleporter = sender.checked == true
end

local function onSend_jumper(sender, reciever)
	local unit = reciever.data
	unit.Jumper = sender.checked == true
end

local function onSend_burrows(sender, reciever)
	local unit = reciever.data
	unit.Burrows = sender.checked == true
end

local function onSend_explodes(sender, reciever)
	local unit = reciever.data
	unit.Explodes = sender.checked == true
end

local function onSend_ignoreFire(sender, reciever)
	local unit = reciever.data
	unit.IgnoreFire = sender.checked == true
end

local function onSend_ignoreSmoke(sender, reciever)
	local unit = reciever.data
	unit.IgnoreSmoke = sender.checked == true
end

local function onRecieve_massive(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Massive == true
end

local function onRecieve_pushable(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Pushable == true
end

local function onRecieve_armor(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Armor == true
end

local function onRecieve_flying(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Flying == true
end

local function onRecieve_teleporter(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Teleporter == true
end

local function onRecieve_jumper(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Jumper == true
end

local function onRecieve_burrows(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Burrows == true
end

local function onRecieve_explodes(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Explodes == true
end

local function onRecieve_ignoreFire(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.IgnoreFire == true
end

local function onRecieve_ignoreSmoke(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.IgnoreSmoke == true
end

local onSend = {
	name = onSend_name,
	class = onSend_class,
	image = onSend_image,
	weaponPrimary = onSend_weaponPrimary,
	weaponSecondary = onSend_weaponSecondary,
	health = onSend_health,
	moveSpeed = onSend_moveSpeed,
	massive = onSend_massive,
	pushable = onSend_pushable,
	armor = onSend_armor,
	flying = onSend_flying,
	teleporter = onSend_teleporter,
	jumper = onSend_jumper,
	burrows = onSend_burrows,
	explodes = onSend_explodes,
	ignoreFire = onSend_ignoreFire,
	ignoreSmoke = onSend_ignoreSmoke,
}

local onRecieve = {
	id = onRecieve_id,
	name = onRecieve_name,
	class = onRecieve_class,
	image = onRecieve_image,
	weaponPrimary = onRecieve_weaponPrimary,
	weaponSecondary = onRecieve_weaponSecondary,
	health = onRecieve_health,
	moveSpeed = onRecieve_moveSpeed,
	massive = onRecieve_massive,
	pushable = onRecieve_pushable,
	armor = onRecieve_armor,
	flying = onRecieve_flying,
	teleporter = onRecieve_teleporter,
	jumper = onRecieve_jumper,
	burrows = onRecieve_burrows,
	explodes = onRecieve_explodes,
	ignoreFire = onRecieve_ignoreFire,
	ignoreSmoke = onRecieve_ignoreSmoke,
}

local function reset(reciever)
	reciever = reciever or easyEdit.displayedEditorButton
	if reciever == nil then return end

	local unit = reciever.data

	if unit:isCustom() then
		if reciever == easyEdit.displayedEditorButton then
			easyEdit.displayedEditorButton = nil
		end
		if unit:delete() then
			reciever:detach()
		end
	else
		unit:reset()
		reciever.decorations[3]:updateSurfacesForce(reciever)

		modApi.modLoaderDictionary[unit._id] = nil
	end

	for _, ui in pairs(uiEditBox) do
		ui:recieve()
	end
end

local function resetAll()
	for i = #unitList.children, 1, -1 do
		reset(unitList.children[i])
	end
end

local function onclicked_resetButton(self)
	reset(self.parent)
	return true
end

local function draw_ifParentIsGroupHovered(self, screen)
	if self.parent:isGroupHovered() then
		self.__index.draw(self, screen)
	end
end

local function isHighlighted_ifGroupHovered(self, widget)
	return widget:isGroupHovered()
end

local function setParentAsGroupOwner(self)
	self.groupOwner = self.parent
end

local function buildFrameContent(parentUi)
	unitList = UiBoxLayout()
	currentContent = UiScrollArea()

	uiEditBox = {
		id = createUiEditBox(),
		name = createUiEditBox(UiTextBox),
		class = createUiEditBox(Ui),
		health = createUiEditBox(UiNumberBox, 1, 12),
		moveSpeed = createUiEditBox(UiNumberBox, 0, 14),
		image = createUiEditBox(UiPopup, "Mech Images"),
		weaponPrimary = createUiEditBox(UiPopup, "Weapons"),
		weaponSecondary = createUiEditBox(UiPopup, "Weapons"),
		massive = createUiEditBox(UiCheckbox),
		pushable = createUiEditBox(UiCheckbox),
		armor = createUiEditBox(UiCheckbox),
		flying = createUiEditBox(UiCheckbox),
		teleporter = createUiEditBox(UiCheckbox),
		jumper = createUiEditBox(UiCheckbox),
		burrows = createUiEditBox(UiCheckbox),
		explodes = createUiEditBox(UiCheckbox),
		ignoreFire = createUiEditBox(UiCheckbox),
		ignoreSmoke = createUiEditBox(UiCheckbox),
	}

	local images_filtered = filter_table(modApi.unitImage._children, function(k, unitImage)
		return unitImage:isMech()
	end)

	local images_sorted = to_sorted_array(images_filtered, function(a, b)
		local imageOffset_a = a.ImageOffset or INT_MAX
		local imageOffset_b = b.ImageOffset or INT_MAX

		return imageOffset_a < imageOffset_b
	end)

	local weapons_filtered = filter_table(modApi.weapons._children, function(k, weapon)
		return weapon:isMechWeapon()
	end)

	local weapons_sorted = to_sorted_array(weapons_filtered, function(a, b)
		local class_a = a.Class or ""
		local class_b = b.Class or ""

		return class_a < class_b
	end)

	local iconDef_unit = modApi.units:getIconDef()
	local icon_unit_width = iconDef_unit.width * iconDef_unit.scale
	local icon_unit_height = iconDef_unit.height * iconDef_unit.scale

	local iconDef_weapon = modApi.weapons:getIconDef()
	local icon_weapon_width = iconDef_weapon.width * iconDef_weapon.scale
	local icon_weapon_height = iconDef_weapon.height * iconDef_weapon.scale

	local unitBox = UiBoxLayout()
	local createNewUnit = UiTextBox()

	unitBox
		:widthpx(500)
		:heightpx(120)
		:dynamicResize(false)
		:anchor("center", "center")
		:hgap(5)
		:beginUi()
			:width(.3)
			:beginUi(uiEditBox.image)
				:sizepx(120, 120)
				:anchor("center", "center")
				:setVar("onRecieve", onRecieve.image)
				:setVar("onSend", onSend.image)
				:decorate{
					DecoImmutable.Button,
					DecoImmutable.Anchor,
					DecoImmutable.ObjectSurface2xOutlineCenterClip,
					DecoImmutable.TransHeader,
					DecoImmutable.UnitImage,
				}
				:addList(
					images_sorted,
					createPopupEntryFunc_icon2x(UNIT_ICON_DEF)
				)
			:endUi()
		:endUi()
		:beginUi()
			:width(.7)
			:beginUi(UiBoxLayout)
				:vgap(5)
				:beginUi(uiEditBox.name)
					:heightpx(28)
					:setVar("onEnter", onTextBoxEnter)
					:setVar("onRecieve", onRecieve.name)
					:setVar("onSend", onSend.name)
					:decorate{
						DecoTextBox{
							font = FONT_TITLE,
							textset = TEXT_SETTINGS_TITLE,
							alignV = "bottom",
						}
					}
				:endUi()
				:beginUi()
					:heightpx(2)
					:decorate{ DecoSolid(deco.colors.buttonborder) }
				:endUi()
				:beginUi(UiWeightLayout)
					:heightpx(icon_weapon_height)
					:hgap(5)
					:orientation(ORIENTATION_HORIZONTAL)
					:beginUi(uiEditBox.weaponPrimary)
						:format(setIconDef, WEAPON_ICON_DEF)
						:setVar("onRecieve", onRecieve.weaponPrimary)
						:setVar("onSend", onSend.weaponPrimary)
						:decorate{
							DecoImmutable.GroupButton,
							DecoImmutable.Anchor,
							DecoImmutable.ObjectSurface2xCenterClip,
							DecoImmutable.TransHeader,
							DecoImmutable.ObjectNameLabelBounceCenterHClip,
						}
						:addList(
							weapons_sorted,
							createPopupEntryFunc_icon2x(WEAPON_ICON_DEF)
						)
						:beginUi()
							:format(setParentAsGroupOwner)
							:anchor("left", "bottom")
							:sizepx(20, 20)
							:pospx(2, 2)
							:setVar("draw", draw_ifParentIsGroupHovered)
							:settooltip("Remove weapon", nil, true)
							:setVar("onclicked", resetParentData)
							:decorate{
								DecoImmutable.SolidHalfBlack,
								DecoImmutable.Delete,
							}
						:endUi()
					:endUi()
					:beginUi(uiEditBox.weaponSecondary)
						:format(setIconDef, WEAPON_ICON_DEF)
						:setVar("onRecieve", onRecieve.weaponSecondary)
						:setVar("onSend", onSend.weaponSecondary)
						:decorate{
							DecoImmutable.GroupButton,
							DecoImmutable.Anchor,
							DecoImmutable.ObjectSurface2xCenterClip,
							DecoImmutable.TransHeader,
							DecoImmutable.ObjectNameLabelBounceCenterHClip,
						}
						:addList(
							weapons_sorted,
							createPopupEntryFunc_icon2x(WEAPON_ICON_DEF)
						)
						:beginUi()
							:format(setParentAsGroupOwner)
							:anchor("left", "bottom")
							:sizepx(20, 20)
							:pospx(2, 2)
							:setVar("draw", draw_ifParentIsGroupHovered)
							:settooltip("Remove weapon", nil, true)
							:setVar("onclicked", resetParentData)
							:decorate{
								DecoImmutable.SolidHalfBlack,
								DecoImmutable.Delete,
							}
						:endUi()
					:endUi()
					:beginUi(UiWeightLayout)
						:width(1)
						:vgap(0)
						:orientation(ORIENTATION_VERTICAL)
						:beginUi(UiBoxLayout)
							:height(0.5)
							:hgap(3)
							:beginUi(uiEditBox.health)
								:sizepx(30,21)
								:setVar("onEnter", onTextBoxEnter)
								:setVar("onRecieve", onRecieve.health)
								:setVar("onSend", onSend.health)
								:decorate{
									DecoHealth(),
									DecoTextBox{
										textset = TEXT_SETTINGS_NUMBER,
										alignH = "center",
									}
								}
							:endUi()
							:beginUi(uiEditBox.moveSpeed)
								:sizepx(30,21)
								:setVar("onEnter", onTextBoxEnter)
								:setVar("onRecieve", onRecieve.moveSpeed)
								:setVar("onSend", onSend.moveSpeed)
								:decorate{
									DecoMove(),
									DecoTextBox{
										textset = TEXT_SETTINGS_NUMBER,
										alignH = "center",
									}
								}
							:endUi()
						:endUi()
						:beginUi(uiEditBox.class)
							:height(0.5)
							:setVar("onRecieve", onRecieve.class)
							:decorate{
								DecoText("Class"),
							}
						:endUi()
					:endUi()
				:endUi()
			:endUi()
		:endUi()
		
	local content = UiWeightLayout()
		:hgap(0)
		-- left area - scrollbar with all mechs
		:beginUi()
			:widthpx(0
				+ icon_unit_width
				+ SCROLL_BAR_WIDTH
				+ PADDING * 4
			)
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				-- title on top
				:add(createUiTitle("Mechs"))
				:beginUi()
					:heightpx(40)
					:padding(-5) -- unpad button
					:decorate{ DecoImmutable.GroupButton }
					:beginUi(createNewUnit)
						:setVar("textfield", TITLE_CREATE_NEW_UNIT)
						:setAlphabet(UiTextBox._ALPHABET_CHARS.."_")
						:settooltip("Create a new unit", nil, true)
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
				-- mech list
				:beginUi(UiScrollArea)
					:decorate{ DecoImmutable.Frame }
					:beginUi(unitList)
						:padding(PADDING)
						:vgap(7)
					:endUi()
				:endUi()
			:endUi()
		:endUi()
		-- right area - selected mech details
		:beginUi()
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				-- id on top
				:beginUi(uiEditBox.id)
					:heightpx(ENTRY_HEIGHT)
					:setVar("padl", 8)
					:setVar("padr", 8)
					:setVar("onRecieve", onRecieve.id)
					:setVar("text_title_bounce_centerv_clip", "Selected Mech")
					:decorate{
						DecoImmutable.Frame,
						DecoImmutable.TextTitleBounceCenterVClip,
					}
				:endUi()
				-- mech details
				:beginUi(currentContent)
					:hide()
					:padding(60)
					:decorate{ DecoImmutable.Frame }
					:beginUi(UiBoxLayout)
						:padding(PADDING)
						:vgap(40)
						:add(unitBox)
						:beginUi()
							:heightpx(2)
							:decorate{ DecoSolid(deco.colors.buttonborder) }
						:endUi()
						:beginUi(UiFlowLayout)
							:hgap(7)
							:vgap(25)
							:beginUi(uiEditBox.massive)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.massive)
								:setVar("onSend", onSend.massive)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("MASSIVE", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.pushable)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.pushable)
								:setVar("onSend", onSend.pushable)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("PUSHABLE", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.armor)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.armor)
								:setVar("onSend", onSend.armor)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("ARMOR", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.flying)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.flying)
								:setVar("onSend", onSend.flying)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("FLYING", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.teleporter)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.teleporter)
								:setVar("onSend", onSend.teleporter)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("TELEPORTER", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.jumper)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.jumper)
								:setVar("onSend", onSend.jumper)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("JUMPER", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.burrows)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.burrows)
								:setVar("onSend", onSend.burrows)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("BURROWS", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.explodes)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.explodes)
								:setVar("onSend", onSend.explodes)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("EXPLODES", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.ignoreFire)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.ignoreFire)
								:setVar("onSend", onSend.ignoreFire)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("FIRE IMMUNE", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.ignoreSmoke)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.ignoreSmoke)
								:setVar("onSend", onSend.ignoreSmoke)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("SMOKE IMMUNE", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
						:endUi()
					:endUi()
				:endUi()
			:endUi()
		:endUi()

	local function addUnitObject(unit)
		local entry = UiEditorButton()
		local decoEditorButton = DecoEditorButton()
		local resetButton

		if unit:isCustom() then
			resetButton = deleteButton_entry()
		else
			resetButton = resetButton_entry()
		end

		resetButton.onclicked = onclicked_resetButton
		resetButton.draw = draw_ifParentIsGroupHovered
		resetButton.tooltip_static = true
		resetButton.groupOwner = entry
		decoEditorButton.isHighlighted = isHighlighted_ifGroupHovered

		entry
			:format(setIconDef, UNIT_ICON_DEF)
			:setVar("data", unit)
			:settooltip("Select which mech to edit", nil, true)
			:decorate{
				decoEditorButton,
				DecoImmutable.Anchor,
				DecoImmutable.ObjectSurface2xCenterClip,
				DecoImmutable.TransHeader,
				DecoImmutable.ObjectNameLabelBounceCenterHClip,
			}
			:beginUi(resetButton)
				:pospx(2, 2)
				:anchor("left", "bottom")
			:endUi()
			:makeCullable()
			:addTo(unitList)

		return entry
	end

	function createNewUnit:onEnter()
		local name = self.textfield
		if name:len() > 0 and modApi.units:get(name) == nil then
			if _G[name] == nil then
				_G[name] = modApi.units._baseMech:new()
				local unit = modApi.units:add(name, modApi.units._baseMech)
				unit.Name = name
				unit:lock()
				addUnitObject(unit)
					:bringToTop()
			end
		end

		self.root:setfocus(content)
	end

	createNewUnit.onFocusChangedEvent:subscribe(function(uiTextBox, focused, focused_prev)
		if focused then
			uiTextBox.textfield = ""
			uiTextBox:setCaret(0)
			uiTextBox.selection = nil
		else
			uiTextBox.textfield = TITLE_CREATE_NEW_UNIT
		end
	end)

	local units_filtered = filter_table(modApi.units._children, function(k, unit)
		return unit._default:isMech()
	end)

	local mechs_sorted = to_sorted_array(units_filtered, function(a, b)
		local imageOffset_a = a.ImageOffset or INT_MAX
		local imageOffset_b = b.ImageOffset or INT_MAX

		return imageOffset_a < imageOffset_b
	end)

	-- populate unit list
	for _, unit in ipairs(mechs_sorted) do
		addUnitObject(unit)
	end

	local function onEditorButtonSet(widget)
		if widget then
			currentContent:show()
			for _, ui in pairs(uiEditBox) do
				ui:recieve()
			end
		else
			currentContent:hide()
			uiEditBox.id.text_title_bounce_centerv_clip = "Selected Mech"
		end
	end

	easyEdit.events.onEditorButtonSet:unsubscribeAll()
	easyEdit.events.onEditorButtonSet:subscribe(onEditorButtonSet)

	return content
end

local function buildFrameButtons(buttonLayout)

	sdlext.buildButton(
		"Default",
		"Reset everything to default\n\nWARNING: This will delete all custom mechs",
		resetAll
 	):addTo(buttonLayout)
end

local function onExit()
	UiEditorButton:resetGlobalVariables()

	modApi.units:save()
end

function unitEditor.mainButton()
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

return unitEditor
