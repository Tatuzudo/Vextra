local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath


function Prime_WayTooBig:GetSkillEffect(p1,p2)
	LOG("I'M TAKING OVER!!")
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local target = GetProjectileEnd(p1,p2)

	local self_damage = SpaceDamage(p1,self.SelfDamage,(dir+2)%4)
	self_damage.sAnimation = "explopush2_"..(dir+2)%4
	ret:AddDamage(self_damage)

	local damage = SpaceDamage(target, self.Damage)
	damage.sAnimation = "explopush2_"..dir
	ret:AddProjectile(damage,"advanced/effects/shot_bigone")
	local newtarget = nil

	for i = -1, 1 do
		newtarget = target + DIR_VECTORS[dir] + (DIR_VECTORS[(dir-1)%4]) * i
		if Board:IsValid(newtarget) then
			damage = SpaceDamage(newtarget, 2)
			damage.sAnimation = "ExploAir2"
			ret:AddDamage(damage)
		end
	end

	for i = -2, 2 do
		newtarget = target + (DIR_VECTORS[dir]*2) + (DIR_VECTORS[(dir-1)%4]) * i
		if Board:IsValid(newtarget) then
			damage = SpaceDamage(newtarget, 1)
			damage.sAnimation = "ExploAir1"
			ret:AddDamage(damage)
		end
	end


	return ret
end
