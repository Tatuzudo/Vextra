local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local tips = require(path .."libs/tutorialTips")

--I have tips for all of the vek, and then you can turn them on or off in the init.lua
tips:Add{
	id = "Tip_DNT_Silkworm",
	title = "Silkworms",
	text = "The Silkworm sends a projectile forward, while webbing behind its attack!"
}

tips:Add{
	id = "Tip_DNT_Thunderbug",
	title = "Thunderbugs",
	text = "The Thunderbug has a lightning whip like attack that can chain through multiple enemies!"
}

tips:Add{
	id = "Tip_DNT_Mantis",
	title = "Mantises",
	text = "The Mantis shoots two diagonal attacks forward."
}

tips:Add{
	id = "Tip_DNT_Pillbug",
	title = "Pillbugs",
	text = "The Pillbug launches itself in the air, bouncing on units and structures backwards, doing damage on each bounce and landing in the first empty space."
}

tips:Add{
	id = "Tip_DNT_Ladybug",
	title = "Ladybugs",
	text = "The Ladybug has a simple weapon, but has a hypnotic effect on the mechs. If your weapon's target area is within the range of a ladybug, you must target your attack at a ladybug, or you hurt yourself in your confusion."
}

tips:Add{
	id = "Tip_DNT_Dragonfly",
	title = "Dragonflies",
	text = "The Dragonfly puts down a smoke immediately, and prepares to explode it. If there's smoke on the tile it attacks, it explodes in a T shape, dealing damage and creating fire. Otherwise, it only hits the tile in front of it."
}

tips:Add{
	id = "Tip_DNT_Antlion",
	title = "Antlions",
	text = "The Antlion immediately cracks its target tile, and then prepares to strike it with a melee attack."
}

tips:Add{
	id = "Tip_DNT_Termites",
	title = "Termites",
	text = "The Termites dash through all units and structures (if possible) till they reach an empty space, dealing damage along the way. If they can't, they do a basic melee strike."
}

tips:Add{
	id = "Tip_DNT_Stinkbug",
	title = "Stinkbugs",
	text = "The Stinkbug releases a fart cloud on both sides of them that acts like smoke, but disapates after the Vek turn."
}

tips:Add{
	id = "Tip_DNT_Cockroach",
	title = "Cockroachs",
	text = "COCKROACH TIP!"
}

tips:Add{
	id = "Tip_DNT_Anthill",
	title = "Anthills",
	text = "ANTHILL TIP!"
}

tips:Add{
	id = "Tip_DNT_IceCrawler",
	title = "Ice Crawlers",
	text = "ICE CRAWLER TIP!"
}

--Put the hooks in here for pawn creation
local this = {}

--@param vek	string	the name of the vek, capitalized
local function IsVek(pawn, vek)
	return pawn and (pawn:GetType() == vek.."1" or pawn:GetType() == vek.."2" or pawn:GetType() == vek.."Boss")
end

local function PawnCreated(mission, pawn)
	for _, table in ipairs(DNT_Vextra_VekList) do
		local name = "DNT_"..table[1]
		local tip = table[4]
		if tip and IsVek(pawn, name) then
			tips:Trigger("Tip_"..name, pawn:GetSpace())
		end
	end
end

function this:load(NAH_MechTaunt_ModApiExt)
	NAH_MechTaunt_ModApiExt:addPawnTrackedHook(PawnCreated)
end

return this
