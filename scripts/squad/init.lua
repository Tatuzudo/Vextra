--I think this works
local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
local readPath = scriptPath.."squad/"

require(readPath.."weapons")
require(readPath.."pawns")
