
local mod = mod_loader.mods[modApi.currentMod]
modApi:appendAsset("img/icons/fail.png",mod.resourcePath.."img/icons/fail.png") -- Landing tile blocked icon?
	Location["icons/fail.png"] = Point(-5,12)

-------------
-- Weapons --
-------------

DNT_PillbugLeap1 = Skill:new{
	Name = "Bouncing Leap",
	Description = "Leap to a tile, landing on it or bouncing on units or buildings to land on the tile before it.", -- Too confusing?
	Class = "Enemy",
	Icon = "weapons/enemy_scarab1.png",
	Projectile = "effects/shotup_crab1.png",
	Range = 8,
	Damage = 1,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,0),
		Mountain = Point(2,2),
		Enemy1 = Point(2,0),
		CustomPawn = "DNT_Pillbug1",
	}
}

DNT_PillbugLeap2 = DNT_PillbugLeap1:new{
	Damage = 3
}

function DNT_PillbugLeap1:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		for k = 1, self.Range do
			local curr = DIR_VECTORS[i]*k + point
			if Board:IsValid(curr) then
				ret:push_back(curr)
			end
		end
	end
	return ret
end

function DNT_PillbugLeap1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local p3 = p2 - DIR_VECTORS[dir]
	
	if Board:IsBlocked(p2,PATH_PROJECTILE) then
		if Board:IsBlocked(p3,PATH_PROJECTILE) then
			ret:AddQueuedScript("Board:AddAlert(".. p1:GetString() ..", 'ATTACK BLOCKED')")
			local noDmg = SpaceDamage(p2, 0)
			noDmg.sImageMark = "icons/fail.png"
			ret:AddQueuedArtillery(noDmg,"",NO_DELAY) -- artillery dots
			-- ret:AddQueuedDamage(noDmg) -- no artillery dots, just area
		else
			ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetInvisible(true)", Pawn:GetId()))
			ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetSpace(Point(-1,-1))", Pawn:GetId())) -- move pawn to hide charge effect
			ret:AddQueuedArtillery(SpaceDamage(p2, self.Damage),self.Projectile,NO_DELAY) -- 1st artillery effect
			
			local move = PointList()
			move:push_back(p1)
			move:push_back(p3)
			ret:AddQueuedCharge(move, NO_DELAY) -- charge move pawn preview, with arrows :/   Use pillbug sprite as sImageMark instead of charge?
			ret.q_effect:back().bHide = true -- hide charge arrow path (this is behaving in a weird way)
			-- ret.q_effect:back().bHidePath = true -- hide charge arrow path
			
			ret:AddQueuedDelay(0.5)
			ret:AddQueuedScript(string.format([[
				local fx = SkillEffect()
				fx:AddArtillery(%s,SpaceDamage(%s, 0),%q,NO_DELAY)
				Board:AddEffect(fx)
			]],p2:GetString(),p3:GetString(),self.Projectile)) -- 2nd artillery effect
			
			ret:AddQueuedDelay(1.1)
			ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetSpace(%s)", Pawn:GetId(), p3:GetString())) -- move pawn to landing point
			ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetInvisible(false)", Pawn:GetId()))
			ret:AddQueuedDelay(0.5)
		end
	else
		ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetInvisible(true)", Pawn:GetId()))
		ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetSpace(Point(-1,-1))", Pawn:GetId())) -- move pawn to hide charge effect
		ret:AddQueuedArtillery(SpaceDamage(p2, 0),self.Projectile,NO_DELAY) -- artillery effect
		
		ret:AddQueuedDelay(0.8)
		local move = PointList()
		move:push_back(p1)
		move:push_back(p2)
		ret:AddQueuedCharge(move, NO_DELAY) -- charge arrows
		ret.q_effect:back().bHide = true -- hide charge arrow path
		
		ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetSpace(%s)", Pawn:GetId(), p2:GetString())) -- move pawn to landing point
		ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetInvisible(false)", Pawn:GetId()))
	end
	
	return ret
end

function DNT_PillbugLeap1:GetTargetScore(p1, p2)
    local ret = Skill.GetTargetScore(self, p1, p2)
    local dir = GetDirection(p1 - p2)
    local p3 = p2 + DIR_VECTORS[dir]
	
	if Board:IsBlocked(p2, PATH_PROJECTILE) then
		if Board:IsBlocked(p3, PATH_PROJECTILE) then -- do not attack if the target is blocked
			ret = ret - 5
		elseif Board:GetTerrain(p3) == TERRAIN_WATER or Board:GetTerrain(p3) == TERRAIN_HOLE then -- less priority to suicide attacks
			ret = ret - 4
		end
	end
	
    return ret
end

-----------
-- Pawns --
-----------

DNT_Pillbug1 = Pawn:new{
	Name = "Pillbug",
	Health = 1,
	MoveSpeed = 2,
	Ranged = 1,
	Image = "digger",
	Armor = true,
	SkillList = { "DNT_PillbugLeap1" },
	SoundLocation = "/enemy/digger_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
	-- -- Mech test
	-- Class = "Prime",
	-- DefaultTeam = TEAM_PLAYER,
}

DNT_Pillbug2 = Pawn:new{
	Name = "Alpha Pillbug",
	Health = 3,
	MoveSpeed = 2,
	Ranged = 1,
	Image = "digger",
	ImageOffset = 1,
	Armor = true,
	SkillList = { "DNT_PillbugLeap2" },
	SoundLocation = "/enemy/digger_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
	-- -- Mech test
	-- Class = "Prime",
	-- DefaultTeam = TEAM_PLAYER,
}
