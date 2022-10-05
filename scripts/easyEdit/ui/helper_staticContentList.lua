
-- header
local path = GetParentPath(...)
local DecoImmutable = require(path.."deco/DecoImmutable")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollAreaH = UiScrollAreaExt.horizontal

local function addStaticContentList1x(self, data)
	self.staticContentList = Ui()
	self.staticContentListLabel = Ui()
	self
		:beginUi(UiWeightLayout)
			:width(1)
			:height(1)
			:beginUi(UiScrollAreaH)
				:height(.5)
				:setVar("scrollheight", 0)
				:setVar("padb", 0)
				:beginUi(self.staticContentList)
					:decorate{ DecoImmutable.ContentList1x }
					:setVar("groupOwner", self)
					:setVar("data", data)
				:endUi()
			:endUi()
			:beginUi(self.staticContentListLabel)
				:widthpx(100)
				:setVar("data", data)
				:decorate{ DecoImmutable.ObjectNameLabelBounceCenterClip }
			:endUi()
			:setTranslucent(true, true)
		:endUi()
end

local function addStaticContentList2x(self, data)
	self.staticContentList = Ui()
	self.staticContentListLabel = Ui()
	self
		:beginUi(UiWeightLayout)
			:width(1)
			:height(1)
			:beginUi(UiScrollAreaH)
				:setVar("scrollheight", 0)
				:setVar("padb", 0)
				:beginUi(self.staticContentList)
					:decorate{ DecoImmutable.ContentList2x }
					:setVar("groupOwner", self)
					:setVar("data", data)
				:endUi()
			:endUi()
			:beginUi(self.staticContentListLabel)
				:widthpx(200)
				:setVar("data", data)
				:decorate{ DecoImmutable.ObjectNameTitleBounceCenterClip }
			:endUi()
			:setTranslucent(true, true)
		:endUi()
end

local function createStaticContentList1x(id, data)
	return Ui()
		:format(addStaticContentList1x, data)
		:heightpx(20)
		:decorate{ DecoImmutable.GroupButton }
		:padding(-5)
end

local function createStaticContentList2x(id, data)
	return Ui()
		:format(addStaticContentList2x, data)
		:heightpx(40)
		:decorate{ DecoImmutable.GroupButton }
		:padding(-5)
end

return {
	addStaticContentList = addStaticContentList1x,
	addStaticContentList2x = addStaticContentList2x,
	createStaticContentList = createStaticContentList1x,
	createStaticContentList2x = createStaticContentList2x,
}
