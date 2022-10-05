
local Mission = Class.inherit(IndexedEntry)
Mission._debugName = "Mission"
Mission._entryType = "missions"
Mission._iconDef = {
	width = 90,
	height = 60,
	scale = 2,
	pathformat = "img/strategy/mission/small/%s.png",
}
Mission._tooltipDef = {
	width = 120,
	height = 120,
	scale = 2,
	clip = true,
	outlinesize = 0,
	pathformat = "img/strategy/mission/%s.png",
}

function Mission:getName()
	return self.Name or self._id
end

function Mission:getCategory()
	return nil
end

function Mission:getDragType()
	return "MISSION"
end

function Mission:getImagePath()
	if self.BossPawn then
		local unit = modApi.units:get(self.BossPawn)
		if unit then
			return unit:getImagePath()
		end
	end

	return string.format(self._iconDef.pathformat, self._id)
end

function Mission:getTooltipImagePath()
	if self.BossPawn then
		local unit = modApi.units:get(self.BossPawn)
		if unit then
			return unit:getTooltipImagePath()
		end
	end

	return string.format(self._tooltipDef.pathformat, self._id)
end

function Mission:getImageRows(anim)
	if self.BossPawn then
		local unit = modApi.units:get(self.BossPawn)
		if unit then
			return unit:getImageRows()
		end
	end

	return 1
end

function Mission:getImageColumns(anim)
	if self.BossPawn then
		local unit = modApi.units:get(self.BossPawn)
		if unit then
			return unit:getImageColumns()
		end
	end

	return 1
end

function Mission:getImageOffset()
	if self.BossPawn then
		local unit = modApi.units:get(self.BossPawn)
		if unit then
			return unit:getImageOffset()
		end
	end

	return 0
end

modApi.missions = IndexedList(Mission)
