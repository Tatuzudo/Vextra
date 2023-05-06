local mod = mod_loader.mods[modApi.currentMod]
local options = mod_loader.currentModContent[mod.id].options

local enemyListSolo = easyEdit.enemyList:add("Vextra Only")
local enemyListCombined =  easyEdit.enemyList:add("Vanilla + Vextra")
local enemyListVanilla = nil

if easyEdit.enemyList:get("vanilla") then
	enemyListVanilla = easyEdit.enemyList:get("vanilla")
elseif easyEdit.enemyList:get("archive") then
	enemyListVanilla = easyEdit.enemyList:get("archive")
else
	LOG("ERROR - Vextra - Enemy Lists not found, creating blank list to copy from")
	enemyListVanilla = easyEdit.enemyList:add("Blank List")
end

--local enemyListFinale = easyEdit.enemyList:get("finale")

enemyListSolo.categories = {"Core", "Core", "Core", "Leaders", "Unique", "Unique"}
enemyListCombined.categories = {"Core", "Core", "Core", "Leaders", "Unique", "Unique"}

enemyListCombined:copy(enemyListVanilla)

for _, table in ipairs(DNT_Vextra_VekList) do
	local name = "DNT_"..table[1]
	local category = table[3]
	if category ~= "None" then
		enemyListSolo:addEnemy(name,category)
		enemyListCombined:addEnemy(name,category)
	end
	--enemyListFinale:addEnemy(name, "Enemies")
end

--Add bots and ~~psions~~, we only have new vek

enemyListSolo:addEnemy("Snowtank", "Bots")
enemyListSolo:addEnemy("Snowart", "Bots")
enemyListSolo:addEnemy("Snowlaser", "Bots")

--Finale
if options.DNT_VextraFinale and options.DNT_VextraFinale.enabled then
  local enemyListFinale = easyEdit.enemyList:get("finale")

  --My (NAH) best judgement of who should go where. Not a huge deal anyway
  local DNT_finaleEnemies = {
		"DNT_Mantis",
		"DNT_Pillbug",
		"DNT_Silkworm",
		"DNT_Antlion",
		"DNT_Termites",
		"DNT_Stinkbug",
		"DNT_Fly",
  }

  for _, enemy in pairs(DNT_finaleEnemies) do
    enemyListFinale:addEnemy(enemy,"Enemies")
  end
end



--We have custom psions now!
-- enemyListSolo:addEnemy("Jelly_Health", "Leaders")
-- enemyListSolo:addEnemy("Jelly_Regen", "Leaders")
-- enemyListSolo:addEnemy("Jelly_Armor", "Leaders")
-- enemyListSolo:addEnemy("Jelly_Explode", "Leaders")
-- enemyListSolo:addEnemy("Jelly_Spider", "Leaders")
-- enemyListSolo:addEnemy("Jelly_Fire", "Leaders")
-- enemyListSolo:addEnemy("Jelly_Boost", "Leaders")
