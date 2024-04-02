local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

local options = mod_loader.currentModContent[mod.id].options
local date = os.date("*t")
local is_april_first = (date["month"] == 4 and date["day"] == 1)

--Only gets here if it is april first or it isn't off
require(scriptPath.."fool/units")
require(scriptPath.."fool/portraits")
require(scriptPath.."fool/confetti")

--gameplay changes (april first or value is set to On)
if (is_april_first or (options.DNT_FoolEnabled and options.DNT_FoolEnabled.value == "On")) then
  require(scriptPath.."fool/new_vek_spawns")
  require(scriptPath.."fool/clown")
  require(scriptPath.."fool/gift")
end



--[[ Testing scripts for lua console

for i=0, 7 do
  for j=0, 7 do
    local pawn = Board:GetPawn(Point(i,j));
    if pawn then
      pawn:SpawnAnimation();
    end;
  end;
end;

for i=0, 7 do
  for j=0, 7 do
    local pawn = Board:GetPawn(Point(i,j));
    if pawn then
      pawn:SetFrozen(true);
    end;
  end;
end;

for i=0, 7 do
  for j=0, 7 do
    local pawn = Board:GetPawn(Point(i,j));
    if pawn then
      pawn:Kill(false);
    end;
  end;
end;
]]
