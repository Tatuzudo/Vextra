local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

local writepath = "img/units/aliens/"
local readpath = resourcePath .. "img/units/aliens/fool/"
local imagepath = writepath:sub(5,-1)

local names = {"anthill", "termites", "stinkbug", "thunderbug", "antlion", "silkworm", "cockroach", "junebug", "mantis", "pillbug", "icecrawler", "ladybug"}
for _, name in pairs(names) do
  modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
  modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
  modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
  modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
  modApi:appendAsset(writepath.."DNT_"..name.."_Bw.png", readpath.."DNT_"..name.."_Bw.png")
end

--ants are special (and flying things)
local ants = {"workerant", "fant", "soldierant", "fly", "dragonfly"}
for _, name in pairs(ants) do
  modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
  modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
  modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
end


local name = "fly"
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
name = "dragonfly"
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")

--Jelly's are special
name = "jelly"
modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")
modApi:appendAsset(writepath.."DNT_"..name.."_emerge.png", readpath.."DNT_"..name.."_emerge.png")
modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
modApi:appendAsset(writepath.."DNT_"..name.."_ns.png", readpath.."DNT_"..name.."_ns.png")
modApi:appendAsset(writepath.."DNT_"..name.."_icon.png", readpath.."DNT_"..name.."_icon.png")

--Cockroach has some special
local corpseNames = {
	"beta",
	"alpha",
	"leader",
}
for _, suffix in pairs(corpseNames) do
	modApi:appendAsset(writepath.."DNT_cockroach_corpse_"..suffix..".png", readpath.."DNT_cockroach_corpse_"..suffix..".png")
		Location[imagepath.."DNT_cockroach_corpse_"..suffix..".png"] = Point(-23,-5)

	modApi:appendAsset(writepath.."DNT_cockroach_explosion_"..suffix..".png", readpath.."DNT_cockroach_explosion_"..suffix..".png")
	modApi:appendAsset(writepath.."DNT_cockroach_death_reverse_"..suffix..".png", readpath.."DNT_cockroach_death_reverse_"..suffix..".png")
end

--Junebug has some special
name = "junebug"
modApi:appendAsset(writepath.."DNT_"..name.."_Bw_broken.png", readpath.."DNT_"..name.."_Bw_broken.png")

name = "angryjunebug" --Angry boi
modApi:appendAsset(writepath.."DNT_"..name.."a.png", readpath.."DNT_"..name.."a.png")


--Secret Squad

writepath = "img/units/player/"
readpath = resourcePath .. "img/units/player/fool/"

names = {
  "stinkbug_mech",
	"dragonfly_mech",
	"fly_mech",
}


for _, name in pairs(names) do
  modApi:appendAsset(writepath.."DNT_"..name..".png", readpath.."DNT_"..name..".png")
  modApi:appendAsset(writepath.."DNT_"..name.."_a.png", readpath.."DNT_"..name.."_a.png")
  modApi:appendAsset(writepath.."DNT_"..name.."_death.png", readpath.."DNT_"..name.."_death.png")
  modApi:appendAsset(writepath.."DNT_"..name.."_broken.png", readpath.."DNT_"..name.."_broken.png")
  modApi:appendAsset(writepath.."DNT_"..name.."_h.png", readpath.."DNT_"..name.."_h.png")
  modApi:appendAsset(writepath.."DNT_"..name.."_w_broken.png", readpath.."DNT_"..name.."_w_broken.png")
  modApi:appendAsset(writepath.."DNT_"..name.."_ns.png", readpath.."DNT_"..name.."_ns.png")
end

name = "stinkbug_mech"
modApi:appendAsset(writepath.."DNT_"..name.."_w.png", readpath.."DNT_"..name.."_w.png")
