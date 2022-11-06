local enemyListSolo = modApi.enemyList:add("Vextra Only")
local enemyListCombined =  modApi.enemyList:add("Vanilla + Vextra")
local enemyListVanilla = modApi.enemyList:get("vanilla")
--local enemyListFinale = modApi.enemyList:get("finale")

enemyListSolo.categories = {"Core", "Core", "Core", "Leaders", "Unique", "Unique"}
enemyListCombined.categories = {"Core", "Core", "Core", "Leaders", "Unique", "Unique"}

enemyListCombined:copy(enemyListVanilla)

for _, table in ipairs(DNT_Vextra_VekList) do
	local name = "DNT_"..table[1]
	local category = table[3]
	--LOG(name)
	--LOG(category)
	enemyListSolo:addEnemy(name,category)
	enemyListCombined:addEnemy(name,category)
	--enemyListFinale:addEnemy(name, "Enemies")
end

--Add bots and psions, we only have new vek

enemyListSolo:addEnemy("Snowtank", "Bots")
enemyListSolo:addEnemy("Snowart", "Bots")
enemyListSolo:addEnemy("Snowlaser", "Bots")

-- enemyListSolo:addEnemy("Jelly_Health", "Leaders")
-- enemyListSolo:addEnemy("Jelly_Regen", "Leaders")
-- enemyListSolo:addEnemy("Jelly_Armor", "Leaders")
-- enemyListSolo:addEnemy("Jelly_Explode", "Leaders")
-- enemyListSolo:addEnemy("Jelly_Spider", "Leaders")
-- enemyListSolo:addEnemy("Jelly_Fire", "Leaders")
-- enemyListSolo:addEnemy("Jelly_Boost", "Leaders")
