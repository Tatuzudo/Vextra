
local UiEditorButton = Class.inherit(Ui)
function UiEditorButton:new()
	Ui.new(self)
	self._debugName = "UiEditorButton"
end

function UiEditorButton:resetGlobalVariables()
	easyEdit.events.onEditorButtonSet:unsubscribeAll()
	easyEdit.selectedEditorButton = nil
	easyEdit.displayedEditorButton = nil
end

function UiEditorButton:clicked(button)
	easyEdit.selectedEditorButton = self
	Ui.clicked(self, button)

	return true
end

function UiEditorButton:updateState()
	local hovered_prev = self.hovered_prev
	local hovered = self:isGroupHovered()
	self.hovered_prev = hovered

	local displayedEditorButton = easyEdit.displayedEditorButton
	local selectedEditorButton = easyEdit.selectedEditorButton
	local isDisplayedEditorButtonHovered = true
		and easyEdit.displayedEditorButton
		and easyEdit.displayedEditorButton:isGroupHovered()

	if hovered ~= hovered_prev then
		if hovered then
			if displayedEditorButton ~= self then
				easyEdit.displayedEditorButton = self
				easyEdit.events.onEditorButtonSet:dispatch(self)
			end
		else
			if not isDisplayedEditorButtonHovered then
				if displayedEditorButton ~= selectedEditorButton then
					easyEdit.displayedEditorButton = selectedEditorButton
					easyEdit.events.onEditorButtonSet:dispatch(selectedEditorButton)
				end
			end
		end
	end

	Ui.updateState(self)
end

return UiEditorButton
