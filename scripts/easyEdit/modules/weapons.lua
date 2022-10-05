
local Weapon = Class.inherit(IndexedEntry)
Weapon._entryType = "weapon"
Weapon._iconDef = {
	width = 60,
	height = 40,
	scale = 2,
	clip = true,
	outlinesize = 0,
	pathformat = "img/%s",
	pathtoken = "Icon",
	pathmissing = "img/weapons/skill_default.png",
}

function Weapon:isMechWeapon()
	local class = self.Class
	return class ~= "" and class ~= "" and class ~= "Enemy"
end

function Weapon:isEnemyWeapon()
	return self.Class == "Enemy"
end

function Weapon:getImagePath()
	if self.Icon == nil then
		return "img/weapons/skill_default.png"
	end

	return "img/"..self.Icon
end

modApi.weapons = IndexedList(Weapon)
