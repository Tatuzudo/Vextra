
-- header
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local DecoIcon = require(path.."deco/DecoIcon")
local DecoLabel = require(path.."deco/DecoLabel")
local DecoImmutable = require(path.."deco/DecoImmutable")
local UiBoxLayout = require(path.."widget/UiBoxLayout")

local addStaticContentList1x = helpers.addStaticContentList
local createStaticContentList1x = helpers.createStaticContentList

-- defs
local LIST_HEIGHT = 20
local LIST_GAP = 30
local HEADER_HEIGHT = 180
local ORIENTATION_HORIZONTAL = helpers.ORIENTATION_HORIZONTAL
local ORIENTATION_VERTICAL = helpers.ORIENTATION_VERTICAL
local CEO_ICON_DEF = modApi.ceo:getIconDef()
local TILESET_ICON_DEF = modApi.tileset:getIconDef()
local PAD_L = 40
local PAD_R = 40
local PAD_T = 20
local PAD_B = 40

-- ui
UiTooltipIslandComposite = Class.inherit(UiWeightLayout)
function UiTooltipIslandComposite:new()
	UiWeightLayout.new(self)
	self._debugName = "UiTooltipIslandComposite"

	self.staticTooltip = true
	self.uiCeo_icon = Ui()
	self.uiCeo_label = Ui()
	self.uiTileset_icon = Ui()
	self.uiTileset_label = Ui()
	self.uiEnemyList = createStaticContentList1x()
	self.uiBossList = createStaticContentList1x()
	self.uiMissionList = createStaticContentList1x()
	self.uiStructureList = createStaticContentList1x()

	self
		:vgap(0)
		:widthpx(400)
		:setVar("padt", PAD_T)
		:setVar("padb", PAD_B)
		:orientation(ORIENTATION_VERTICAL)
		:heightpx(0
			+ PAD_T + PAD_B
			+ HEADER_HEIGHT
			+ LIST_HEIGHT * 4
			+ LIST_GAP * 5
		)
		:decorate{ DecoImmutable.Frame }
		:beginUi()
			:heightpx(HEADER_HEIGHT)
			:beginUi(UiWeightLayout)
				:size(1,1)
				:hgap(0)
				:orientation(ORIENTATION_HORIZONTAL)
				:beginUi(self.uiCeo_label)
					:width(0.5)
					:decorate{
						DecoLabel("CEO", "center", "top"),
						DecoImmutable.Anchor,
						DecoImmutable.ObjectNameLabelBounceCenterBottomClip,
					}
					:beginUi(self.uiCeo_icon)
						:anchor("center", "center")
						:widthpx(CEO_ICON_DEF.width * CEO_ICON_DEF.scale)
						:heightpx(CEO_ICON_DEF.height * CEO_ICON_DEF.scale)
						:decorate{
							DecoImmutable.Frame,
							DecoImmutable.ObjectSurface2xCenterClip,
						}
					:endUi()
				:endUi()
				:beginUi()
					:widthpx(2)
					:decorate{ DecoSolid(deco.colors.buttonborder) }
				:endUi()
				:beginUi(self.uiTileset_label)
					:width(0.5)
					:decorate{
						DecoLabel("TILESET", "center", "top"),
						DecoImmutable.Anchor,
						DecoImmutable.ObjectNameLabelBounceCenterBottomClip,
					}
					:beginUi(self.uiTileset_icon)
						:anchor("center", "center")
						:widthpx(TILESET_ICON_DEF.width * TILESET_ICON_DEF.scale)
						:heightpx(TILESET_ICON_DEF.height * TILESET_ICON_DEF.scale)
						:decorate{
							DecoImmutable.Frame,
							DecoImmutable.ObjectSurface1xCenterClip,
						}
					:endUi()
				:endUi()
			:endUi()
		:endUi()
		:beginUi()
			:heightpx(LIST_GAP * 2)
			:setVar("padl", PAD_L)
			:setVar("padr", PAD_R)
			:beginUi()
				:anchorV("center")
				:heightpx(2)
				:decorate{ DecoSolid(deco.colors.buttonborder) }
			:endUi()
		:endUi()
		:beginUi(UiBoxLayout)
			:setVar("padl", PAD_L)
			:setVar("padr", PAD_R)
			:vgap(LIST_GAP)
			:add(self.uiEnemyList)
			:add(self.uiBossList)
			:add(self.uiMissionList)
			:add(self.uiStructureList)
		:endUi()
end

function UiTooltipIslandComposite:onCustomTooltipShown(hoveredUi)
	local islandComposite = hoveredUi.data

	if islandComposite == nil then
		self.uiCeo_icon.data = nil
		self.uiCeo_label.data = nil
		self.uiTileset_icon.data = nil
		self.uiTileset_label.data = nil
		self.uiEnemyList.staticContentList.data = nil
		self.uiBossList.staticContentList.data = nil
		self.uiMissionList.staticContentList.data = nil
		self.uiStructureList.staticContentList.data = nil
		return
	end

	local island = modApi.island:get(islandComposite.island)
	local ceo = modApi.ceo:get(islandComposite.ceo)
	local tileset = modApi.tileset:get(islandComposite.tileset)
	local enemyList = modApi.enemyList:get(islandComposite.enemyList)
	local bossList = modApi.bossList:get(islandComposite.bossList)
	local missionList = modApi.missionList:get(islandComposite.missionList)
	local structureList = modApi.structureList:get(islandComposite.structureList)

	self.uiCeo_icon.data = ceo
	self.uiCeo_label.data = ceo
	self.uiTileset_icon.data = tileset
	self.uiTileset_label.data = tileset
	self.uiEnemyList.staticContentList.data = enemyList
	self.uiBossList.staticContentList.data = bossList
	self.uiMissionList.staticContentList.data = missionList
	self.uiStructureList.staticContentList.data = structureList
	self.uiEnemyList.staticContentListLabel.data = enemyList
	self.uiBossList.staticContentListLabel.data = bossList
	self.uiMissionList.staticContentListLabel.data = missionList
	self.uiStructureList.staticContentListLabel.data = structureList
end

return UiTooltipIslandComposite()
