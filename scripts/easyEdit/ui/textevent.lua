
-- add default textinput to the base ui element
function Ui:textinput(textinput)
	if not self.visible then return false end

	if self.parent then
		return self.parent:textinput(textinput)
	end

	return false
end

-- add textinput event to the main event loop
modApi.events.onUiRootCreated:subscribe(function(screen, root)
	local oldUiRootEventLoop = root.event
	function root:event(eventloop)
		local result = oldUiRootEventLoop(self, eventloop)

		if eventloop:type() == sdl.events.textinput then
			if self.focuschild then
				return self.focuschild:textinput(eventloop:textinput())
			else
				return false
			end
		end

		return result
	end
end)
