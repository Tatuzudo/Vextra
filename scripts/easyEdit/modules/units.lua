
modApi:appendAsset("img/units/nullUnit.png", "resources/mods/game/img/placeholders/mech.png")

local function getTableKeys(tbl)
	local keys = {}
	local index = tbl

	while type(index) == 'table' do
		for i, v in pairs(index) do
			if tostring(i):sub(1,1) ~= "_" then
				if keys[i] == nil then
					keys[i] = true
				end
			end
		end

		local prev_index = index
		index = index.__index

		if index == prev_index then
			index = nil
		end
	end

	return keys
end

local function getTableContent(tbl)
	local keys = getTableKeys(tbl)
	local content = {}

	for key, _ in pairs(keys) do
		content[key] = tbl[key]
	end

	return content
end

local Unit = Class.inherit(IndexedEntry)
Unit._debugName = "Unit"
Unit._entryType = "units"
Unit._iconDef = {
	width = 90,
	height = 60,
	scale = 2,
}
Unit._tooltipDef = {
	width = 90,
	height = 60,
	scale = 2,
	clip = true,
}

function Unit:new(id, base)
	IndexedEntry.new(self, id, base)
end

function Unit:getAnim()
	local image = self.Image

	if image == nil then
		return nil
	end

	return ANIMS[image] or nil
end

function Unit:getImagePath(anim)
	local anim = anim or Unit.getAnim(self)

	if anim == nil then
		return "img/units/nullUnit.png"
	end

	return anim.Image and ("img/"..anim.Image) or "img/units/nullUnit.png"
end

function Unit:getImageRows(anim)
	local anim = anim or Unit.getAnim(self)

	if anim == nil then
		return 1
	end

	return anim.Height or 1
end

function Unit:getImageColumns(anim)
	local anim = anim or Unit.getAnim(self)

	if anim == nil then
		return 1
	end

	return anim.Frames and #anim.Frames or anim.NumFrames or 1
end

function Unit:getImageOffset()
	return self.ImageOffset or 0
end

function Unit:getName()
	return self.Name
end

function Unit:isValid()
	return false
		or Unit.getImagePath(self):sub(1,10) == "img/units/"
		or Unit.getImagePath(self):sub(1,19) == "img/advanced/units/"
end

function Unit:isMech()
	return false
		or Unit.getImagePath(self):sub(1,17) == "img/units/player/"
		or Unit.getImagePath(self):sub(1,26) == "img/advanced/units/player/"
end

function Unit:isEnemy()
	return false
		or Unit.getImagePath(self):sub(1,17) == "img/units/aliens/"
		or Unit.getImagePath(self):sub(1,26) == "img/advanced/units/aliens/"
end

function Unit:isBot()
	return false
		or Unit.getImagePath(self):sub(1,19) == "img/units/snowbots/"
		or Unit.getImagePath(self):sub(1,28) == "img/advanced/units/snowbots/"
end

function Unit:isMission()
	return false
		or Unit.getImagePath(self):sub(1,18) == "img/units/mission/"
		or Unit.getImagePath(self):sub(1,27) == "img/advanced/units/mission/"
end

function Unit:isBaseEnemy()
	local isBaseEnemy = true
		and (self:isEnemy() or self:isBot())
		and tonumber(self._id:sub(-1,-1)) == 1

	return isBaseEnemy
end

local excludeFields = {
	-- ImageOffset = true,
}

function Unit:copy(base)
	if type(base) ~= 'table' then return end

	local keys = getTableKeys(base)
	for key, _ in pairs(keys) do
		local value = copy_table(base[key])
		local copyValue = true
			and type(value) ~= 'function'
			and self[key] ~= value
			and excludeFields[key] ~= true

		if copyValue then
			self[key] = value
		end
	end
end

function Unit:getCategory()
	return nil
end

function Unit:getDragType()
	return "UNIT"
end

local Units = IndexedList(Unit)
Units._soundBases = {}
Units._basePawn = TankMech.__index
Units._baseMech = PunchMech:new()

function Units:addSoundBase(unit)
	local soundBase = unit.SoundLocation
	local addSound = true
		and type(soundBase) == 'string'
		and soundBase ~= ""
		and not list_contains(self._soundBases, soundBase)

	if addSound then
		table.insert(self._soundBases, soundBase)
	end
end

function Units:update()
	local cache_units = easyEdit.savedata.cache.units or {}

	for unit_id, unit_data in pairs(cache_units) do
		local livedata = modApi.units:get(unit_id)
		local unit = _G[unit_id]

		-- if unit_data.ImageOffset then
			-- unit_data.ImageOffset = nil
		-- end

		if unit == nil then
			unit = self._baseMech:new(unit_data)
			_G[unit_id] = unit
		end

		if livedata == nil then
			livedata = modApi.units:add(unit_id, self._baseMech)
			livedata:lock()
		end

		if livedata then
			clear_table(livedata)
			clone_table(livedata, unit_data)
			livedata.copy(unit, livedata)
		end
	end
end

modApi.units = Units
