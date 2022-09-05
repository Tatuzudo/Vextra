
-------------
-- Weapons --
-------------

DNT_MantisSlash1 = Skill:new{
	Name = "Sharp Claws",
	Description = "Slash two diagonal tiles.",
	Class = "Enemy",
	SoundBase = "/enemy/leaper_1",
	Icon = "weapons/enemy_leaper1.png",
	Queued = true, -- set false to test as mech weapon (instant effect)
	PathSize = 1,
	Damage = 1,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(1,2),
		Enemy2 = Point(3,2),
		CustomPawn = "DNT_Mantis1",
	}
}

DNT_MantisSlash2 = DNT_MantisSlash1:new{
	Damage = 3,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(1,2),
		Enemy2 = Point(3,2),
		CustomPawn = "DNT_Mantis2",
	}
}


function DNT_MantisSlash1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)

	local dir2 = dir+1 > 3 and 0 or dir+1
	local p3 = p2 + DIR_VECTORS[dir2]

	local dir3 = dir-1 < 0 and 3 or dir-1
	local p4 = p2 + DIR_VECTORS[dir3]

	if self.Queued then -- queued
		ret:AddQueuedMelee(p1,SpaceDamage(p2 + DIR_VECTORS[dir]*10)) -- queued
		local damage = SpaceDamage(p3,self.Damage)
		damage.sAnimation = "SwipeClaw2"
		ret:AddQueuedDamage(damage)
		damage.loc = p4
		damage.sSound = self.SoundBase.."/attack"
		ret:AddQueuedDamage(damage)
	else -- instant
		ret:AddMelee(p1,SpaceDamage(p2 + DIR_VECTORS[dir]*10)) -- instant
		local damage = SpaceDamage(p3,self.Damage)
		damage.sAnimation = "SwipeClaw2"
		ret:AddDamage(damage)
		damage.loc = p4
		damage.sSound = self.SoundBase.."/attack"
		ret:AddDamage(damage)
	end

	return ret
end

-----------
-- Pawns --
-----------

DNT_Mantis1 = Pawn:new{
	Name = "Mantis",
	Health = 2,
	MoveSpeed = 3,
	Image = "leaper",
	Jumper = true,
	SkillList = { "DNT_MantisSlash1" },
	SoundLocation = "/enemy/leaper_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
	-- -- Mech test
	-- Class = "Prime",
	-- DefaultTeam = TEAM_PLAYER,
}
AddPawn("DNT_Mantis1")

DNT_Mantis2 = Pawn:new{
	Name = "Alpha Mantis",
	Health = 4,
	MoveSpeed = 3,
	Image = "leaper",
	ImageOffset = 1,
	Jumper = true,
	SkillList = { "DNT_MantisSlash2" },
	SoundLocation = "/enemy/leaper_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
	-- -- Mech test
	-- Class = "Prime",
	-- DefaultTeam = TEAM_PLAYER,
}
AddPawn("DNT_Mantis2")
