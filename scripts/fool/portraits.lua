local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

local writepath = "img/portraits/enemy/"
local readpath = resourcePath .. "img/portraits/enemy/fool/"
local imagepath = writepath:sub(5,-1)

local names = {"Anthill","Antlion","Cockroach","Dragonfly","Fly","IceCrawler","Ladybug","Mantis","Pillbug","Silkworm","Stinkbug","Termites","Thunderbug"}
for _, name in pairs(names) do
  LOG(name)
  modApi:appendAsset(writepath.."DNT_"..name.."1.png",readpath.."DNT_"..name.."1.png")
  modApi:appendAsset(writepath.."DNT_"..name.."2.png",readpath.."DNT_"..name.."2.png")
  modApi:appendAsset(writepath.."DNT_"..name.."Boss.png",readpath.."DNT_"..name.."Boss.png")
end

local oneportrait = {"Acid", "Haste", "Nurse", "Reactive", "Winter", "FAnt", "SoldierAnt", "WorkerAnt"}
for _, name in pairs(oneportrait) do
  modApi:appendAsset(writepath.."DNT_"..name.."1.png",readpath.."DNT_"..name.."1.png")
end

local name = "Junebug"
modApi:appendAsset(writepath.."DNT_"..name.."Boss.png",readpath.."DNT_"..name.."Boss.png")

names = {
	"StinkbugMech",
	"DragonflyMech",
	"FlyMech",
}
for _, ptname in pairs(names) do
	modApi:appendAsset("img/portraits/pilots/Pilot_DNT_"..ptname..".png",resourcePath.."img/portraits/pilots/fool/Pilot_DNT_"..ptname..".png")
end
