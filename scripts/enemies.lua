
local enemies = {
	DNT_Fly = {
		weakpawn = true,
		--ExclusiveElement = "Scarab",
		max_pawns = 3,
	},
	DNT_Mantis = {
		weakpawn = true,
		ExclusiveElement = "Starfish",
		max_pawns = 3,
	},
	DNT_Pillbug = {
		weakpawn = false,
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
		weakpawn = false,--true,
		ExclusiveElement = "Jelly_Explode",
		max_pawns = 3,
	},
	DNT_Stinkbug = {
		weakpawn = true,
		ExclusiveElement = "Mosquito",
		max_pawns = 2,
	},
	DNT_Cockroach = {
		weakpawn = false,
		max_pawns = 3,
		IslandLocks = 2,
	},
	DNT_Termites = {
		weakpawn = true,--false,
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
	DNT_Haste = {
		weakpawn = false,
		max_pawns = 1,
		IslandLocks = 2,
		max_level = 1,
	},
	DNT_Acid = {
		weakpawn = false,
		max_pawns = 1,
		IslandLocks = 2,
		max_level = 1,
	},
	DNT_Reactive = {
		weakpawn = false,
		max_pawns = 1,
		IslandLocks = 2,
		max_level = 1,
	},
	DNT_Nurse = {
		weakpawn = false,
		max_pawns = 1,
		IslandLocks = 2,
		max_level = 1,
	},
	DNT_Winter = {
		weakpawn = false,
		max_pawns = 1,
		IslandLocks = 2,
		max_level = 1,
	},
}

-- config enemies
for id, v in pairs(enemies) do
	WeakPawns[id] = v.weakpawn
	Spawner.max_pawns[id] = v.max_pawns -- defaults to 3
	Spawner.max_level[id] = v.max_level -- defaults to 2 (no alpha is 1)
	if v.ExclusiveElement then
		if ExclusiveElements then
			ExclusiveElements[id] = v.exclusive_element
		elseif exclusiveElements then
			table.insert(exclusiveElements, {string.format("%q",id), v.ExclusiveElement})
		end
	end
end

--Anthill has many (spawner), Cockroach has many (arty), Pillbug has many (arty)
--This is following vanilla's standards of only one arty and one spawner per island
if ExclusiveElements then --1.2.76b  I also do not know if this actually works.
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
		--DNT_Cockroach = "Jelly_Explode",
		--DNT_Cockroach = "Jelly_Spider",
		--DNT_Cockroach = "Jelly_Fire",
		DNT_Fly = "Moth",
		DNT_Fly = "Scarab",
	}
elseif exclusiveElements then --1.2.79+
	for _, list in pairs(exclusiveElements) do
		if list[1] == "Moth" then
			table.insert(list, "DNT_Cockroach")
			table.insert(list, "DNT_Pillbug")
		elseif list[1] == "Spider" then
			table.insert(list, "DNT_Anthill")
		elseif list[1] == "Leaper" then
			table.insert(list, "DNT_Silkworm")
		end
	end
	table.insert(exclusiveElements, {"DNT_IceCrawler", "Burrower", "DNT_Antlion", "DNT_Anthill"}) --Ice Crawers and Burrowers act weird because of the damage + freeze
	--table.insert(exclusiveElements, {"DNT_Cockroach", "Jelly_Explode", "Jelly_Spider", "Jelly_Fire"}) --FIXED Cockroaches don't currently work with death effect psions
end

if FlyingEnemies then --Flying table, seperate from Exlcuisve Elements
	local new_flying = {DNT_Dragonfly = true}
	FlyingEnemies = add_tables(FlyingEnemies, new_flying)
end

--Console testing
-- for i, j in pairs(exclusiveElements) do LOG(i); for k, l in pairs(j) do LOG(l) end end
-- checkExclusiveList


-- Exclude Psions from boss Psion mission
-- function Mission_JellyBoss:StartMission()
	-- self:StartBoss()
	-- self:GetSpawner():BlockPawns({
		-- "Jelly_Health",
		-- "Jelly_Explode",
		-- "Jelly_Regen",
		-- "Jelly_Armor",
		-- "Jelly_Fire",
		-- "Jelly_Spider",
		-- "Jelly_Boost",
		-- -- our psions
		-- "DNT_Haste",
		-- "DNT_Acid",
		-- "DNT_Reactive",
	-- })
-- end


local myPsions = {
	"DNT_Haste",
	"DNT_Acid",
	"DNT_Reactive",
	"DNT_Nurse",
	"DNT_Winter",
}

modApi.events.onPreMissionAvailable:subscribe(function(mission)
    if true
        and mission.BossPawn ~= nil
        and _G[mission.BossPawn] ~= nil
        and _G[mission.BossPawn].Leader ~= LEADER_NONE
    then
        -- for _, myPsion in ipairs(myPsions) do
            -- mission:GetSpawner():BlockPawns(myPsion)
        -- end
		mission:GetSpawner():BlockPawns(myPsions)
    end
end)
