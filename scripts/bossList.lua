
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