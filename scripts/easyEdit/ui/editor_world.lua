
-- header
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local tooltip_islandComposite = require(path.."helper_tooltip_islandComposite")
local DecoIcon = require(path.."deco/DecoIcon")
local DecoImmutable = require(path.."deco/DecoImmutable")
local DecoImmutableIsland = DecoImmutable.ObjectSurface2xCenterClip
local DecoImmutableIslandOutline = DecoImmutable.IslandCompositeIsland
local DecoImmutableIslandCompositeTitle = DecoImmutable.ObjectNameLabelBounceCenterHClip
local UiBoxLayout = require(path.."widget/UiBoxLayout")
local UiDragSource = require(path.."widget/UiDragSource")
local UiDragObject_Island = require(path.."widget/UiDragObject_Island")
local UiDropTarget = require(path.."widget/UiDropTarget")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollArea = UiScrollAreaExt.vertical
local UiScrollAreaH = UiScrollAreaExt.horizontal

-- defs
local EDITOR_TITLE = "World Editor"
local ENTRY_HEIGHT = helpers.ENTRY_HEIGHT
local PADDING = 8
local SCROLLBAR_WIDTH = 16
local ORIENTATION_VERTICAL = helpers.ORIENTATION_VERTICAL
local ORIENTATION_HORIZONTAL = helpers.ORIENTATION_HORIZONTAL
local DRAG_TARGET_TYPE = modApi.islandComposite:getDragType()
local TOOLTIP_ISLAND_COMPOSITE = tooltip_islandComposite
local DEFAULT_ISLAND_SLOTS = { "archive", "rst", "pinnacle", "detritus" }
local ISLAND_ICON_DEF = modApi.island:getIconDef()
local ISLAND_COMPOSTE_COMPONENTS = {
	"island",
	"corporation",
	"ceo",
	"tileset",
	"enemyList",
	"bossList",
	"missionList",
	"structureList",
}

-- ui
local islandSlots
local worldEditor = {}
local dragObject = UiDragObject_Island(DRAG_TARGET_TYPE)

local function resetAll()
	for i = 1, 4 do
		local islandComposite = modApi.islandComposite:get(DEFAULT_ISLAND_SLOTS[i])
		local island = modApi.island:get(islandComposite.island)
		local islandInSlot = islandSlots[i]

		islandInSlot.data = islandComposite
	end
end

local function getEditedIslandCompositeId(islandSlot)
	local islandComposite = islandSlots[islandSlot].data

	if islandComposite == nil then
		return modApi.world[islandSlot].island
	end

	return islandComposite._id
end

local function setParentAsGroupOwner(self)
	self.groupOwner = self.parent
end

local function buildFrameContent(parentUi)
	local root = sdlext:getUiRoot()
	local islandComposites = UiBoxLayout()

	islandSlots = {
		UiDropTarget(DRAG_TARGET_TYPE),
		UiDropTarget(DRAG_TARGET_TYPE),
		UiDropTarget(DRAG_TARGET_TYPE),
		UiDropTarget(DRAG_TARGET_TYPE),
	}

	for islandSlot, islandUi in ipairs(islandSlots) do
		local currentIslandComposite = modApi.world[islandSlot]
		local currentIsland = modApi.island:get(currentIslandComposite.island)

		local function updateTooltipState(self)
			local missing = false
			local malformed = false

			local editedIslandComposite = self.parent.data
			if editedIslandComposite == nil then
				local missingIslandCompositeId = easyEdit.savedata.cache.world[islandSlot]
				self.tooltip = "Missing island composite: "..missingIslandCompositeId
			else
				local tooltip = {}
				for _, name in ipairs(ISLAND_COMPOSTE_COMPONENTS) do

					local componentId = editedIslandComposite[name]
					local component = modApi[name]:get(componentId)
					if componentId == nil then
						missing = true
						tooltip[#tooltip+1] = "Missing "..name.."\n"
					elseif component == nil then
						missing = true
						tooltip[#tooltip+1] = "Missing "..name..": "..componentId.."\n"
					elseif component:isInvalid() then
						malformed = true
						tooltip[#tooltip+1] = "Malformed "..name..": "..componentId.."\n"
					end
				end

				if missing or malformed then
					self.tooltip_title = "Update blocked"
					self.tooltip = table.concat(tooltip):sub(1,-2)
				else
					local editedIsland = modApi.island:get(editedIslandComposite.island)
					self.tooltip_title = "Restart required"
					self.tooltip = string.format("Restart required for island graphics to change from %s to %s", currentIsland:getName(), editedIsland:getName())
				end
			end

			Ui.updateTooltipState(self)
		end

		local function draw_ifIssue(self, screen)
			local issue = false
			local editedIslandComposite = self.parent.data

			if editedIslandComposite == nil or editedIslandComposite:isInvalid() then
				issue = true
			end

			if not issue then
				issue = currentIslandComposite.island ~= editedIslandComposite.island
			end

			if issue then
				self.__index.draw(self, screen)
			end
		end

		islandUi
			:beginUi()
				:format(setParentAsGroupOwner)
				:anchor("right", "top")
				:sizepx(40, 40)
				:pospx(20, 20)
				:setVar("draw", draw_ifIssue)
				:setVar("updateTooltipState", updateTooltipState)
				:decorate{
					DecoImmutable.SolidHalfBlack,
					DecoImmutable.WarningLarge,
				}
			:endUi()
	end

	local content = UiWeightLayout()
		:hgap(0)
		:beginUi()
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				:beginUi()
					:heightpx(ENTRY_HEIGHT)
					:setVar("padl", 8)
					:setVar("padr", 8)
					:setVar("text_title_centerv", "World")
					:decorate{
						DecoImmutable.Frame,
						DecoImmutable.TextTitleCenterV,
					}
				:endUi()
				:beginUi()
					:decorate{
						DecoImmutable.Frame,
						DecoIcon("img/strategy/waterbg.png", { clip = true }),
					}
					:beginUi(islandSlots[1])
						:size(.5, .5)
						:anchor("left", "top")
					:endUi()
					:beginUi(islandSlots[2])
						:size(.5, .5)
						:anchor("left", "bottom")
					:endUi()
					:beginUi(islandSlots[3])
						:size(.5, .5)
						:anchor("right", "top")
					:endUi()
					:beginUi(islandSlots[4])
						:size(.5, .5)
						:anchor("right", "bottom")
					:endUi()
				:endUi()
			:endUi()
		:endUi()
		:beginUi()
			:widthpx(0
				+ ISLAND_ICON_DEF.width * ISLAND_ICON_DEF.scale
				+ 4 * PADDING + SCROLLBAR_WIDTH
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
				:beginUi(UiScrollArea)
					:decorate{ DecoImmutable.Frame }
					:beginUi(islandComposites)
						:padding(PADDING)
						:vgap(7)
					:endUi()
				:endUi()
			:endUi()
		:endUi()

	local cache_world = easyEdit.savedata.cache.world or DEFAULT_ISLAND_SLOTS

	for islandSlot, cache_data in ipairs(cache_world) do
		local islandComposite = modApi.islandComposite:get(cache_data)
		local islandInSlot = islandSlots[islandSlot]

		islandInSlot
			:setVar("data", islandComposite)
			:setCustomTooltip(TOOLTIP_ISLAND_COMPOSITE)
			:decorate{ DecoImmutableIslandOutline }
	end

	for _, islandComposite in pairs(modApi.islandComposite._children) do
		local entry = UiDragSource(dragObject)

		entry
			:widthpx(ISLAND_ICON_DEF.width * ISLAND_ICON_DEF.scale)
			:heightpx(ISLAND_ICON_DEF.height * ISLAND_ICON_DEF.scale)
			:setVar("data", islandComposite)
			:setCustomTooltip(TOOLTIP_ISLAND_COMPOSITE)
			:decorate{
				DecoImmutable.Button,
				DecoImmutable.Anchor,
				DecoImmutableIsland,
				DecoImmutable.TransHeader,
				DecoImmutableIslandCompositeTitle,
			}
			:addTo(islandComposites)
	end

	return content
end

local function buildFrameButtons(buttonLayout)
	sdlext.buildButton(
		"Default",
		"Reset everything to default.",
		resetAll
 	):addTo(buttonLayout)
end

local function onExit()
	easyEdit.savedata.cache.world = {
		getEditedIslandCompositeId(1),
		getEditedIslandCompositeId(2),
		getEditedIslandCompositeId(3),
		getEditedIslandCompositeId(4),
	}

	easyEdit.savedata:saveAsFile("world", easyEdit.savedata.cache.world)
	easyEdit.savedata:updateLiveData()
end

function worldEditor.mainButton()
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

return worldEditor
