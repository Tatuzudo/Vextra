
-- create boss list
local bossList = modApi.bossList:add("Vextra")
local bossListCombined =  modApi.bossList:add("Vanilla + Vextra")
local bossListVanilla = modApi.bossList:get("archive")
bossListCombined:copy(bossListVanilla)

local DNT_bosses = {
  "Mission_MantisBoss",
  "Mission_PillbugBoss",
  "Mission_ThunderbugBoss",
  "Mission_SilkwormBoss",
}

for _, boss in pairs(DNT_bosses) do
  bossList:addBoss(boss)
  bossListCombined:addBoss(boss)
end
