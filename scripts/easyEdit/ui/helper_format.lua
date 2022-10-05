
local helpers = {}

function helpers.setIconDef(self, iconDef)
	if iconDef == nil then
		return
	end

	local scale = iconDef.scale or 1
	local width = iconDef.width
	local height = iconDef.height

	if width then
		self:widthpx(width * scale)
	end

	if height then
		self:heightpx(height * scale)
	end
end

return helpers
