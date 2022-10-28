
Mission_ThunderbugBoss = Mission_Boss:new{
	Name = "Thunderbug Leader",
	-- islandLock = 3,
	BossPawn = "DNT_Thunderbug3",
	SpawnStartMod = -1,
	BossText = "Destroy the Thunderbug Leader",
}

Mission_PillbugBoss = Mission_Boss:new{
	Name = "Pillbug Leader",
	BossPawn = "DNT_Pillbug3",
	SpawnStartMod = -1,
	BossText = "Destroy the Pillbug Leader",
}

Mission_MantisBoss = Mission_Boss:new{
	Name = "Mantis Leader",
	BossPawn = "DNT_Mantis3",
	SpawnStartMod = -1,
	BossText = "Destroy the Mantis Leader",
}

Mission_SilkwormBoss = Mission_Boss:new{
	Name = "Silkworm Leader",
	BossPawn = "DNT_Silkworm3",
	SpawnStartMod = -1,
	BossText = "Destroy the Silkworm Leader",
}

Mission_AntlionBoss = Mission_Boss:new{
	Name = "Antlion Leader",
	BossPawn = "DNT_Antlion3",
	SpawnStartMod = -1,
	BossText = "Destroy the Antlion Leader",
}

Mission_FlyBoss = Mission_Boss:new{
	Name = "Fly Leader",
	BossPawn = "DNT_Fly3",
	SpawnStartMod = -1,
	BossText = "Destroy the Fly Leader",
}

Mission_TermitesBoss = Mission_Boss:new{
	Name = "Termite Leaders",
	BossPawn = "DNT_Termites3",
	SpawnStartMod = -1,
	BossText = "Destroy the Termite Leaders",
}

Mission_CockroachBoss = Mission_Boss:new{
	Name = "Cockroach Leader",
	BossPawn = "DNT_Cockroach3",
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
			if Board:GetItem(point) == DNT_Cockroach3.DroppedCorpse then return false end
			local pawn = Board:GetPawn(point)
			if pawn then
				if pawn:GetType() == "DNT_Cockroach3" then return false end
			end
		end
	end
	return true
end
-- IslandLocks.Mission_ThunderbugBoss = 3
