
-- create boss list
local bossList = modApi.bossList:add("Vextra Only")
local bossListCombined =  modApi.bossList:add("Vanilla + Vextra")
local bossListVanilla = modApi.bossList:get("archive")
bossListCombined:copy(bossListVanilla)

local DNT_bosses = {
  "Mission_MantisBoss",
  "Mission_PillbugBoss",
  "Mission_ThunderbugBoss",
  "Mission_SilkwormBoss",
  "Mission_AntlionBoss",
  "Mission_FlyBoss",
  "Mission_TermitesBoss",
  "Mission_CockroachBoss",
  "Mission_DragonflyBoss",
  "Mission_IceCrawlerBoss",
}


for _, boss in pairs(DNT_bosses) do
  bossList:addBoss(boss)
  bossListCombined:addBoss(boss)
end
