
-------------
-- Weapons --
-------------

DNT_VekLightning1 = Skill:new{
	Name = "Lightning Bolt",
	Description = "Electrocute chained units and buildings, dealing less damage with distance.",
	Class = "Enemy",
	Icon = "weapons/prime_lightning.png",
	Queued = true, -- set false to test as mech weapon (instant effect)
	PathSize = 1,
	Damage = 2,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(2,2),
		Building = Point(2,1),
		Enemy2 = Point(3,1),
		Building2 = Point(1,2),
		CustomPawn = "DNT_Thunderbug1",
	}
}

DNT_VekLightning2 = DNT_VekLightning1:new{
	Damage = 3,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(2,2),
		Building = Point(2,1),
		Enemy2 = Point(3,1),
		Building2 = Point(1,2),
		CustomPawn = "DNT_Thunderbug2",
	}
}


function DNT_VekLightning1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local hash = function(point) return point.x + point.y*10 end
	local explored = {[hash(p1)] = true}
	local damvalue = self.Damage
	local todo = {{p2,damvalue}}
	local origin = { [hash(p2)] = p1 }

	while #todo ~= 0 do
		local current = todo[1][1]
		damvalue = todo[1][2]
		table.remove(todo, 1)

		if not explored[hash(current)] then
			explored[hash(current)] = true

			local direction = GetDirection(current - origin[hash(current)])
			local damage = SpaceDamage(current,damvalue)
			damage.sAnimation = "Lightning_Attack_"..direction

			if self.Queued then -- queued
				ret:AddQueuedDamage(damage)
				ret:AddQueuedAnimation(current,"Lightning_Hit")
				ret:AddQueuedSound("/weapons/electric_whip")
			else -- instant
				ret:AddDamage(damage)
				ret:AddAnimation(current,"Lightning_Hit")
				ret:AddSound("/weapons/electric_whip")
			end

			if Board:IsPawnSpace(current) or Board:IsBuilding(current) then
				for i = DIR_START, DIR_END do
					local neighbor = current + DIR_VECTORS[i]
					if not explored[hash(neighbor)] and damvalue > 1 then
						if Board:IsPawnSpace(neighbor) or Board:IsBuilding(neighbor) then
							todo[#todo + 1] = {neighbor,damvalue-1}
							origin[hash(neighbor)] = current
						end
					end
				end
			end
		end
	end

	return ret
end

-----------
-- Pawns --
-----------

DNT_Thunderbug1 = Pawn:new{
	Name = "Thunderbug",
	Health = 2,
	MoveSpeed = 3,
	Image = "beetle",
	SkillList = { "DNT_VekLightning1" },
	SoundLocation = "/enemy/beetle_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_INSECT,
	-- -- Mech test
	-- Class = "Prime",
	-- DefaultTeam = TEAM_PLAYER,
}
AddPawn("DNT_Thunderbug1")

DNT_Thunderbug2 = Pawn:new{
	Name = "Alpha Thunderbug",
	Health = 4,
	MoveSpeed = 3,
	Image = "beetle",
	ImageOffset = 1,
	SkillList = { "DNT_VekLightning2" },
	SoundLocation = "/enemy/beetle_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_INSECT,
	-- -- Mech test
	-- Class = "Prime",
	-- DefaultTeam = TEAM_PLAYER,
}

AddPawn("DNT_Thunderbug2")
