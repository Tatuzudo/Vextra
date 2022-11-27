
Mission_ThunderbugBoss = Mission_Boss:new{
	Name = "Thunderbug Leader",
	-- islandLock = 3,
	BossPawn = "DNT_ThunderbugBoss",
	SpawnStartMod = -1,
	BossText = "Destroy the Thunderbug Leader",
}

Mission_PillbugBoss = Mission_Boss:new{
	Name = "Pillbug Leader",
	BossPawn = "DNT_PillbugBoss",
	SpawnStartMod = -1,
	BossText = "Destroy the Pillbug Leader",
}

Mission_MantisBoss = Mission_Boss:new{
	Name = "Mantis Leader",
	BossPawn = "DNT_MantisBoss",
	SpawnStartMod = -1,
	BossText = "Destroy the Mantis Leader",
}

Mission_SilkwormBoss = Mission_Boss:new{
	Name = "Silkworm Leader",
	BossPawn = "DNT_SilkwormBoss",
	SpawnStartMod = -1,
	BossText = "Destroy the Silkworm Leader",
}

Mission_AntlionBoss = Mission_Boss:new{
	Name = "Antlion Leader",
	BossPawn = "DNT_AntlionBoss",
	SpawnStartMod = -1,
	BossText = "Destroy the Antlion Leader",
}

Mission_FlyBoss = Mission_Boss:new{
	Name = "Fly Leader",
	BossPawn = "DNT_FlyBoss",
	SpawnStartMod = -1,
	BossText = "Destroy the Fly Leader",
}

Mission_DragonflyBoss = Mission_Boss:new{
	Name = "Dragonfly Leader",
	BossPawn = "DNT_DragonflyBoss",
	SpawnStartMod = -1,
	BossText = "Destroy the Dragonfly Leader",
}

Mission_TermitesBoss = Mission_Boss:new{
	Name = "Termite Leaders",
	BossPawn = "DNT_TermitesBoss",
	SpawnStartMod = -1,
	BossText = "Destroy the Termite Leaders",
}

Mission_StinkbugBoss = Mission_Boss:new{
	Name = "Stinkbug Leader",
	BossPawn = "DNT_StinkbugBoss",
	SpawnStartMod = -1,
	BossText = "Destroy the Stinkbug Leader",
}

Mission_AnthillBoss = Mission_Boss:new{
	Name = "Anthill Leader",
	BossPawn = "DNT_AnthillBoss",
	SpawnStartMod = -2, --There's gonna be a lot
	BossText = "Destroy the Anthill Leader",
}

function Mission_AnthillBoss:StartMission()
	self:StartBoss()
	self:GetSpawner():BlockPawns({
		"DNT_Anthill", --Let's not get a bunch of anthills with the anthill boss
		"Spider", --Or other spawners
		"Shaman",
		"Blobber",
	})
end


Mission_CockroachBoss = Mission_Boss:new{
	Name = "Cockroach Leader",
	BossPawn = "DNT_CockroachBoss",
	SpawnStartMod = -1,
	BossText = "Destroy and Stomp the Cockroach Leader",
}
--Custom is Dead since it's based off of BossID and the boss ID changes
--Updating BossID would be better but I can't because I also have to check for the mine.
function Mission_CockroachBoss:IsBossDead()
	local board_size = Board:GetSize()
	for i = 0, board_size.x - 1 do
		for j = 0, board_size.y - 1 do
			local point = Point(i,j)
			if Board:GetItem(point) == DNT_CockroachBoss.CorpseItem then return false end
			local pawn = Board:GetPawn(point)
			if pawn then
				if pawn:GetType() == "DNT_CockroachBoss" then return false end
			end
		end
	end
	return true
end

Mission_IceCrawlerBoss = Mission_Boss:new{
	Name = "Ice Crawler Leader",
	BossPawn = "DNT_IceCrawlerBoss",
	SpawnStartMod = -2, --One extra for the frozen Vek spawned
	BossText = "Destroy the Ice Crawler Leader",
}
--Add Ice
function Mission_IceCrawlerBoss:StartMission()
	self:StartBoss()
	math.randomseed(os.time())
	local tile = Board:GetPawn(self.BossID):GetSpace()
	local board_size = Board:GetSize()

	--Frozen Vek
	local choices = {}
	self.Enemies = {}


	for i = 0, board_size.x - 1 do
		for j = 0, board_size.y - 1 do
			local point = Point(i,j)
			local distance = point:Manhattan(tile)
			local odds = 30
			if Board:IsBuilding(point) then odds = 50 end
			if distance <= 2 and point ~= tile then
				Board:SetFrozen(point, true)
			elseif point == tile then
				Board:SetCustomTile(point, "snow.png")
			elseif (Board:IsBuilding(point) or Board:IsTerrain(point,TERRAIN_MOUNTAIN)) and not Board:IsUniqueBuilding(point) and math.random(1,100) <= odds then
				Board:SetFrozen(point, true)
			end
			--Frozen Vek
			if i >= 1 and i <= 5 and j >= 2 and j <= 6 then
				if 	not Board:IsBlocked(point,PATH_GROUND) then
					choices[#choices+1] = point
				end
			end
		end
	end

	--Frozen Vek
	if #choices > 0 then
		pawn = self:NextPawn()
		local choice = random_removal(choices)
		self.Enemies[#self.Enemies+1] = pawn:GetId()
		Board:AddPawn(pawn,choice)
		pawn:SetFrozen(true)
	else
		self.SpawnStartMod = -1 --In case this works, but this should never happen
	end
end

Mission_JunebugBoss = Mission_Boss:new{
	Name = "Junebug and Ladybug Leader",
	BossPawn = "DNT_JunebugBoss",
	SpawnStartMod = -1, --One extra for the ladybug?? It just heals so I'm not sure
	BossText = "Destroy the Junebug and Ladybug Companion",
	Ladybug = "DNT_LadybugBoss"
}

function Mission_JunebugBoss:StartMission()
	self:StartBoss()
	local tile = Board:GetPawn(self.BossID):GetSpace()
	for i=DIR_START,DIR_END do
		local curr = tile+DIR_VECTORS[i]
		--LOG(curr)
		if not Board:IsBlocked(curr,PATH_GROUND) then
			Board:AddPawn(self.Ladybug,curr)
			self.DNT_LadybugID = Board:GetPawn(curr):GetId()
			break
		end
	end
	if not self.DNT_LadybugID then
		LOG("THIS SHOULD NEVER HAPPEN BUT IF YOU SEE THIS @NamesAreHard ON DISCORD THANK YOU")
	end
end

function Mission_JunebugBoss:IsBossDead()
	return not Board:IsPawnAlive(self.BossID) and not Board:IsPawnAlive(self.DNT_LadybugID)
end
