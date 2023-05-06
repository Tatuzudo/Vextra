local mod = mod_loader.mods[modApi.currentMod]
local options = mod_loader.currentModContent[mod.id].options

-- create boss list
local bossList = easyEdit.bossList:add("Vextra Only")
local bossListCombined =  easyEdit.bossList:add("Vanilla + Vextra")
local bossListVanilla = easyEdit.bossList:get("archive")
bossListCombined:copy(bossListVanilla)

local DNT_bosses = {
  "Mission_JunebugBoss", --At the top like Goos, makes it fit a bit more
  "Mission_MantisBoss",
  "Mission_PillbugBoss",
  "Mission_ThunderbugBoss",
  "Mission_SilkwormBoss",
  "Mission_AntlionBoss",
  "Mission_FlyBoss",
  "Mission_TermitesBoss",
  "Mission_StinkbugBoss",
  "Mission_CockroachBoss",
  "Mission_DragonflyBoss",
  "Mission_IceCrawlerBoss",
  "Mission_AnthillBoss",
}

for _, boss in pairs(DNT_bosses) do
  bossList:addBoss(boss)
  bossListCombined:addBoss(boss)
end

-- for spawning bosses in 4th island unfair
for i = 1, #DNT_bosses do
	local name = string.gsub(DNT_bosses[i], "Mission", "DNT")
	if name ~= "DNT_AnthillBoss" and name ~= "DNT_JunebugBoss" then
		BossesList[name] = true
	end
end

--Finale
if options.DNT_VextraFinale and options.DNT_VextraFinale.enabled then
  local bossListFinale1 = easyEdit.bossList:get("finale1")
  local bossListFinale2 = easyEdit.bossList:get("finale2")

  --My (NAH) best judgement of who should go where. Not a huge deal anyway
  local DNT_finaleBosses1 = {
    "Mission_MantisBoss",
    "Mission_PillbugBoss",
    "Mission_FlyBoss",
  }

  local DNT_finaleBosses2 = {
    "Mission_StinkbugBoss",
    "Mission_PillbugBoss",
    "Mission_FlyBoss",
  }

  for _, boss in pairs(DNT_finaleBosses1) do
    bossListFinale1:addBoss(boss)
  end

  for _, boss in pairs(DNT_finaleBosses2) do
    bossListFinale2:addBoss(boss)
  end
end
