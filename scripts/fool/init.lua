local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

require(scriptPath.."fool/units")
require(scriptPath.."fool/portraits")
require(scriptPath.."fool/confetti")

require(scriptPath.."fool/new_vek_spawns")
require(scriptPath.."fool/clown")
require(scriptPath.."fool/gift")



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
