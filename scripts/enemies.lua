
local enemies = {
	DNT_Mantis = {
		weakpawn = true,
		ExclusiveElements = "Starfish",
		max_pawns = 3,
	},
	DNT_Pillbug = {
		weakpawn = true,
		max_pawns = 2,
	},
	DNT_Silkworm = {
		weakpawn = true,
		max_pawns = 3,
	},
	DNT_Thunderbug = {
		weakpawn = false,
		max_pawns = 2,
	},
	DNT_Ladybug = {
		weakpawn = false,
		max_pawns = 2,
		IslandLocks = 2,
	},
	DNT_Dragonfly = {
		weakpawn = false,
		max_pawns = 2,
	},
	DNT_Antlion = {
		weakpawn = true,
		ExclusiveElements = "Jelly_Explode",
		max_pawns = 2,
	},
	DNT_Antlion = {
		weakpawn = true,
		max_pawns = 3,
	},
	DNT_Cockroach = {
		weakpawn = false,
		max_pawns = 2,
		IslandLocks = 2,
		ExclusiveElements = "Jelly_Explode", --Doens't work with them, so just exclude them
	},
	DNT_Termites = {
		weakpawn = false,
		max_pawns = 2,
		IslandLocks = 2,
	},
	DNT_Anthill = {
		weakpawn = false,
		max_pawns = 1,
		IslandLocks = 2,
	},
	DNT_IceCrawler = {
		weakpawn = false,
		max_pawns = 3,
		IslandLocks = 2,
	},
}

-- config enemies
for id, v in pairs(enemies) do
	WeakPawns[id] = v.weakpawn
	Spawner.max_pawns[id] = v.max_pawns -- defaults to 3
	Spawner.max_level[id] = v.max_level -- defaults to 2 (no alpha is 1)
	ExclusiveElements[id] = v.exclusive_element
end

--Anthill has many (spawner), Cockroach has many (arty), Pillbug has many (arty)
--This is following vanilla's standards of only one arty and one spawner per island
ExclusiveElements = {
	DNT_Anthill = "Blobber",
	DNT_Anthill = "Spider",
	DNT_Anthill = "Shaman",
	DNT_Cockroach = "Moth",
	DNT_Cockroach = "DNT_Pillbug",
	DNT_Cockroach = "Shaman",
	DNT_Cockroach = "Scarab",
	DNT_Pillbug = "Moth",
	DNT_Pillbug = "Scarab",
	DNT_Pillbug = "Shaman",
}
