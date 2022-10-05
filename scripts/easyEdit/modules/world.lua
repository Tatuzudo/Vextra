
-- defs
local DEFAULT_FINAL_MISSION = Mission_Final
local DEFAULT_ISLAND_SLOTS = { "archive", "rst", "pinnacle", "detritus" }
local LOGDF = easyEdit.LOGF


local vanillaCorporations = { "Corp_Grass", "Corp_Desert", "Corp_Snow", "Corp_Factory" }

modApi.world = {
	{
		bossList = "archive",
		ceo = "dewey",
		corporation = "archive",
		enemyList = "vanilla",
		island = "archive",
		missionList = "archive",
		structureList = "vanilla",
		tileset = "grass",
	},
	{
		bossList = "rst",
		ceo = "jessica",
		corporation = "rst",
		enemyList = "vanilla",
		island = "rst",
		missionList = "rst",
		structureList = "vanilla",
		tileset = "sand",
	},
	{
		bossList = "pinnacle",
		ceo = "zenith",
		corporation = "pinnacle",
		enemyList = "vanilla",
		island = "pinnacle",
		missionList = "pinnacle",
		structureList = "vanilla",
		tileset = "snow",
	},
	{
		bossList = "detritus",
		ceo = "vikram",
		corporation = "detritus",
		enemyList = "vanilla",
		island = "detritus",
		missionList = "detritus",
		structureList = "vanilla",
		tileset = "acid",
	},
}

function modApi.world:update()
	local world = easyEdit.savedata.cache.world or DEFAULT_ISLAND_SLOTS

	for islandSlot, islandCompositeId in ipairs(world) do
		local islandComposite = modApi.islandComposite:get(islandCompositeId)

		if islandComposite == nil then
			LOGDF("EasyEdit - IslandSlot[%s] - Block missing island composite %q", islandSlot, islandCompositeId)
		elseif islandComposite:isInvalid() then
			LOGDF("EasyEdit - IslandSlot[%s] - Block malformed island composite %q", islandSlot, islandCompositeId)
		else
			LOGDF("EasyEdit - IslandSlot[%s] - Set island composite %q", islandSlot, islandCompositeId)

			if modApi.resource then
				self:setIsland(islandSlot, islandComposite.island)
			end

			self:setCorporation(islandSlot, islandComposite.corporation)
			self:setCeo(islandSlot, islandComposite.ceo)
			self:setTileset(islandSlot, islandComposite.tileset)
			self:setEnemyList(islandSlot, islandComposite.enemyList)
			self:setBossList(islandSlot, islandComposite.bossList)
			self:setMissionList(islandSlot, islandComposite.missionList)
			self:setStructureList(islandSlot, islandComposite.structureList)
		end
	end
end

function modApi.world:reset()
	easyEdit.savedata.cache.world = nil
	self:update()
end

function modApi.world:setIsland(islandSlot, islandId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(islandId), "Argument #2")
	Assert.ResourceDatIsOpen()

	local island = modApi.island:get(islandId)
	if island == nil then
		LOGDF("EasyEdit - IslandSlot[%s] - Block missing island %q", islandSlot, islandId)
		return
	elseif island:isInvalid() then
		LOGDF("EasyEdit - IslandSlot[%s] - Block malformed island %q", islandSlot, islandId)
		return
	else
		LOGDF("EasyEdit - IslandSlot[%s] - Set island %q", islandSlot, islandId)
		self[islandSlot].island = islandId
	end

	local n = islandSlot - 1

	Location[string.format("strategy/island%s.png", n)] = Island_Locations[islandSlot]
	Location[string.format("strategy/island1x_%s.png", n)] = Island_Locations[islandSlot] - island.shift
	Location[string.format("strategy/island1x_%s_out.png", n)] = Island_Locations[islandSlot] - island.shift

	Island_Magic[islandSlot] = island.magic

	for k = 0, 7 do
		Region_Data[string.format("island_%s_%s", n, k)] = island.regionData[k+1]
	end

	for k = 0, 7 do
		_G["Network_Island_".. n][tostring(k)] = island.network[k+1]
	end

	island.copyAssets({_id = n}, island)
end

function modApi.world:setCorporation(islandSlot, corpId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(corpId), "Argument #2")

	local corp = modApi.corporation:get(corpId)
	if corp == nil then
		LOGDF("EasyEdit - IslandSlot[%s] - Block missing corporation %q", islandSlot, corpId)
		return
	elseif corp:isInvalid() then
		LOGDF("EasyEdit - IslandSlot[%s] - Block malformed corporation %q", islandSlot, corpId)
		return
	else
		LOGDF("EasyEdit - IslandSlot[%s] - Set corporation %q", islandSlot, corpId)
		self[islandSlot].corporation = corpId
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	corp.copy(base, corp)
	modApi.modLoaderDictionary[baseCorpId .."_Name"] = corp.Name
	modApi.modLoaderDictionary[baseCorpId .."_Description"] = corp.Description
end

function modApi.world:setCeo(islandSlot, ceoId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(ceoId), "Argument #2")

	local ceo = modApi.ceo:get(ceoId)
	if ceo == nil then
		LOGDF("EasyEdit - IslandSlot[%s] - Block missing ceo %q", islandSlot, ceoId)
		return
	elseif ceo:isInvalid() then
		LOGDF("EasyEdit - IslandSlot[%s] - Block malformed ceo %q", islandSlot, ceoId)
		return
	else
		LOGDF("EasyEdit - IslandSlot[%s] - Set ceo %q", islandSlot, ceoId)
		self[islandSlot].ceo = ceoId
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	ceo.copy(base, ceo)
	modApi.modLoaderDictionary[baseCorpId .."_CEO_Name"] = ceo.CEO_Name

	if islandSlot == 2 then
		local finalMissionId = ceo.finalMission
		local finalMission

		if finalMissionId then
			finalMission = _G[finalMissionId]
		end

		if finalMission then
			Mission_Final = finalMission
		else
			Mission_Final = DEFAULT_FINAL_MISSION
		end
	end
end

function modApi.world:setTileset(islandSlot, tilesetId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(tilesetId), "Argument #2")

	local tileset = modApi.tileset:get(tilesetId)
	if tileset == nil then
		LOGDF("EasyEdit - IslandSlot[%s] - Block missing tileset %q", islandSlot, tilesetId)
		return
	elseif tileset:isInvalid() then
		LOGDF("EasyEdit - IslandSlot[%s] - Block malformed tileset %q", islandSlot, tilesetId)
		return
	else
		LOGDF("EasyEdit - IslandSlot[%s] - Set tileset %q", islandSlot, tilesetId)
		self[islandSlot].tileset = tilesetId
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	base.Tileset = tileset._id
	modApi.modLoaderDictionary[baseCorpId .."_Environment"] = tileset.climate
end

function modApi.world:setEnemyList(islandSlot, enemyListId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(enemyListId), "Argument #2")

	local enemyList = modApi.enemyList:get(enemyListId)
	if enemyList == nil then
		LOGDF("EasyEdit - IslandSlot[%s] - Block missing enemy list %q", islandSlot, enemyListId)
		return
	elseif enemyList:isInvalid() then
		LOGDF("EasyEdit - IslandSlot[%s] - Block malformed enemy list %q", islandSlot, enemyListId)
		return
	else
		LOGDF("EasyEdit - IslandSlot[%s] - Set enemy list %q", islandSlot, enemyListId)
		self[islandSlot].enemyList = enemyListId
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	base.Enemies = copy_table(enemyList.enemies)
	base.EnemyCategories = copy_table(enemyList.categories)
end

function modApi.world:setBossList(islandSlot, bossListId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(bossListId), "Argument #2")

	local bossList = modApi.bossList:get(bossListId)
	if not bossList then
		LOGDF("EasyEdit - IslandSlot[%s] - Block missing boss list %q", islandSlot, bossListId)
		return
	elseif bossList:isInvalid() then
		LOGDF("EasyEdit - IslandSlot[%s] - Block malformed boss list %q", islandSlot, bossListId)
		return
	else
		LOGDF("EasyEdit - IslandSlot[%s] - Set boss list %q", islandSlot, bossListId)
		self[islandSlot].bossList = bossListId
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	bossList.copy(base, bossList)
end

function modApi.world:setMissionList(islandSlot, missionListId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(missionListId), "Argument #2")

	local missionList = modApi.missionList:get(missionListId)
	if not missionList then
		LOGDF("EasyEdit - IslandSlot[%s] - Block missing mission list %q", islandSlot, missionListId)
		return
	elseif missionList:isInvalid() then
		LOGDF("EasyEdit - IslandSlot[%s] - Block malformed mission list %q", islandSlot, missionListId)
		return
	else
		LOGDF("EasyEdit - IslandSlot[%s] - Set mission list %q", islandSlot, missionListId)
		self[islandSlot].missionList = missionListId
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	missionList.copy(base, missionList)
end

function modApi.world:setStructureList(islandSlot, structureListId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(structureListId), "Argument #2")

	local structureList = modApi.structureList:get(structureListId)
	if not structureList then
		LOGDF("EasyEdit - IslandSlot[%s] - Block missing structure list %q", islandSlot, structureListId)
		return
	elseif structureList:isInvalid() then
		LOGDF("EasyEdit - IslandSlot[%s] - Block malformed structure list %q", islandSlot, structureListId)
		return
	else
		LOGDF("EasyEdit - IslandSlot[%s] - Set structure list %q", islandSlot, structureListId)
		self[islandSlot].structureList = structureListId
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	structureList.copy(base, structureList)
end
