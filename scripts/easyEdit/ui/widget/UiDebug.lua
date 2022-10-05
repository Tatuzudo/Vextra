
-- header
local path = GetParentPath(...)
local parentPath = GetParentPath(path)
local DecoOutline = require(parentPath.."deco/DecoOutline")
local DecoTextPlaque = require(parentPath.."deco/DecoTextPlaque")

-- defs
local FONT = sdlext.font("fonts/NunitoSans_Bold.ttf", 18)


local UiDebug = Class.inherit(Ui)
function UiDebug:new(watchedElement, color)
	Ui.new(self)

	self._debugName = "UiDebug"
	self.translucent = true
	self.watchedElement = watchedElement
	self.decoText = DecoTextPlaque{
		font = FONT,
		textset = deco.textset(color, nil, nil, true),
		alignH = "left",
		alignV = "top_outside",
		padding = 8,
	}

	self:decorate{
		DecoOutline(color, 4),
		DecoAlign(-4,-4),
		self.decoText,
	}
end

function UiDebug:relayout()
	if not easyEdit.debugUi then
		return
	end

	local root = self.root
	local watchedElement = root[self.watchedElement]

	self.visible = watchedElement ~= nil

	if not self.visible then
		return
	end

	local debugName = watchedElement._debugName or "Missing debugName"

	if type(debugName) ~= 'string' then
		debugName = "Malformed debugName"
	end

	debugName = debugName.." - "..tostring(watchedElement)

	self.decoText:setsurface(debugName)

	self.screenx = watchedElement.screenx
	self.screeny = watchedElement.screeny
	self.w = watchedElement.w
	self.h = watchedElement.h

	Ui.relayout(self)
end

modApi.events.onUiRootCreated:subscribe(function(screen, uiRoot)
	uiRoot.priorityUi:add(UiDebug("hoveredchild", sdl.rgb(255, 100, 100)))
end)

modApi.events.onUiRootCreated:subscribe(function(screen, uiRoot)
	uiRoot.priorityUi:add(UiDebug("draghoveredchild", sdl.rgb(100, 255, 100)))
end)


-- Add debug names for all derivatives of class Ui
for name, class in pairs(_G) do
	if type(class) == 'table' then
		if Class.isSubclassOf(class, Ui) then
			if class.__index._debugName == nil then
				class.__index._debugName = name
			end
		end
	end
end
