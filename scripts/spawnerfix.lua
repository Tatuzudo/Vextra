--Override the spawner code to fix a vanilla bug that is too minor to worth the risk

function Spawner:SelectPawn(choices, weak)
  --LOG("Taking over spawns.")
  local available = {}
	local backup = {}
	local super_backup = {}
	for i,v in pairs(choices) do
		local max_count = self.max_pawns[v] or 3

		local start_spawns = 4

		if GetDifficulty() == DIFF_HARD then
			start_spawns = 5
		elseif GetDifficulty() == DIFF_UNFAIR then
			start_spawns = 6
		end

		if self.num_spawns < start_spawns and v == "Jelly_Lava" then
			max_count = 0--never spawn Jelly_Lava in the start
		end

		local current_count = self.pawn_counts[v] or 0
		local under_max = current_count < max_count
		local is_match = weak == (WeakPawns[v] == true)
		--if it's a match and under the max then add it to the list
		if is_match and under_max then
			available[#available+1] = v
		  --backup anything that's weak and not limited to 1 as a replacement backup
    elseif WeakPawns[v] and max_count ~= 1 then --only add to back up if under max
      super_backup[#super_backup+1] = v
      if under_max then
        backup[#backup+1] = v
      end
		end
	end
	---every pawn is already maxed out. so ignore the maxes.
	if #available == 0 then
		--try backup list first
		if #backup ~= 0 then
			available = backup
    elseif #super_backup ~= 0 then
      available = super_backup
		else --then just give up
		    LOG("Spawner GAVE UP and gave a COMPLETELY RANDOM pawn. This SHOULD NOT HAPPEN. Please tell Matthew")
			available = choices
		end
	end

	return random_element(available)
end


--[[ OLDER VERSION THAT MIGHT WORK BETTER CAUSE IT IS LESS FANCY.

--Override the spawner code to fix a vanilla bug that is too minor to worth the risk

function Spawner:SelectPawn(choices, weak)
  LOG("Taking over spawns.")
  local available = {}
	local backup = {}
	local super_backup = {}
	for i,v in pairs(choices) do
		local max_count = self.max_pawns[v] or 3

		local start_spawns = 4

		if GetDifficulty() == DIFF_HARD then
			start_spawns = 5
		elseif GetDifficulty() == DIFF_UNFAIR then
			start_spawns = 6
		end

		if self.num_spawns < start_spawns and v == "Jelly_Lava" then
			max_count = 0--never spawn Jelly_Lava in the start
		end

		local current_count = self.pawn_counts[v] or 0
		local under_max = current_count < max_count
		local is_match = weak == (WeakPawns[v] == true)
		--if it's a match and under the max then add it to the list
		if is_match and under_max then
			available[#available+1] = v
		  --backup anything that's weak and not limited to 1 as a replacement backup
    elseif WeakPawns[v] and max_count ~= 1 and under_max then --only add to back up if under max
			backup[#backup+1] = v
		end
	end

	---every pawn is already maxed out. so ignore the maxes.
	if #available == 0 then
		--try backup list first
		if #backup ~= 0 then
			available = backup
		else --then just give up
		    LOG("Spawner GAVE UP and gave a COMPLETELY RANDOM pawn. This SHOULD NOT HAPPEN. Please tell Matthew")
			available = choices
		end
	end

	return random_element(available)
end
]]
