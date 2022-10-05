
local path = GetParentPath(...)
local UiBoxLayout = require(path.."widget/UiBoxLayout")

local function loadConfig()
	local currentProfilePath = modApi:getCurrentProfilePath()
	if currentProfilePath == nil then
		return
	end

	sdlext.config(
		currentProfilePath.."modcontent.lua",
		function(obj)
			local config = obj.easyEditConfig

			if config == nil then
				config = {}
				obj.easyEditConfig = config
			end

			easyEdit.enabled = config.enabled or false
			easyEdit.debugLogging = config.debugLogging or false
			easyEdit.debugUi = config.debugUi or false
		end
	)
end

local function saveConfig()
	sdlext.config(
		modApi:getCurrentProfilePath().."modcontent.lua",
		function(readObj)
			local config = {}
			config.enabled = easyEdit.enabled
			config.debugLogging = easyEdit.debugLogging
			config.debugUi = easyEdit.debugUi

			readObj.easyEditConfig = config
		end
	)
end

local createCheckboxOption = function(text, tooltipOn, tooltipOff)
	local cbox = UiCheckbox()
		:width(1):heightpx(41)
		:decorate{
			DecoButton(),
			DecoAlign(0, 2),
			DecoText(text),
			DecoAlign(0, -2),
			DecoRAlign(33),
			DecoCheckbox()
		}

	function cbox:updateTooltipState()
		if self.checked then
			self.tooltip = tooltipOn
		else
			self.tooltip = tooltipOff
		end
		Ui.updateTooltipState(self)
	end

	return cbox
end

local function buildFrameContent(parentUi)
	local content = UiBoxLayout()
		:vgap(5)
		:width(1)
		:addTo(parentUi)

	local checkboxes = {}

	checkboxes.enabled = createCheckboxOption(
			"Enabled",
			"Disable EasyEdit\n\nRequires a restart to take effect",
			"Enable EasyEdit\n\nRequires a restart to take effect"
		)
		:addTo(content)

	checkboxes.debugLogging = createCheckboxOption(
			"Debug logging",
			"Disable EasyEdit specific debug logging",
			"Enable EasyEdit specific debug logging"
		)
		:addTo(content)

	checkboxes.debugUi = createCheckboxOption(
			"Debug Ui",
			"Disable debug ui",
			"Enable debug ui"
		)
		:addTo(content)

	function checkboxes.enabled:onclicked()
		easyEdit.enabled = self.checked
		return true
	end

	function checkboxes.debugLogging:onclicked()
		easyEdit.debugLogging = self.checked
		return true
	end

	function checkboxes.debugUi:onclicked()
		easyEdit.debugUi = self.checked
		return true
	end

	checkboxes.enabled.checked = easyEdit.enabled
	checkboxes.debugLogging.checked = easyEdit.debugLogging
	checkboxes.debugUi.checked = easyEdit.debugUi
end

local function buildFrameButtons(buttonLayout)
end

local function onExit()
	saveConfig()
end

-- main button
local function mainButton()
	sdlext.showDialog(function(ui, quit)
		ui.onDialogExit = onExit

		local frame = sdlext.buildButtonDialog(
			"EasyEdit Configuration",
			buildFrameContent,
			buildFrameButtons
		)

		local function onGameWindowResized(self, screen, oldSize)
			local minW = 400
			local minH = 300
			local maxW = 600
			local maxH = 400
			local width = math.min(maxW, math.max(minW, ScreenSizeX() - 200))
			local height = math.min(maxH, math.max(minH, ScreenSizeY() - 100))

			self
				:widthpx(width)
				:heightpx(height)
		end

		frame
			:addTo(ui)
			:anchor("center", "center")

		onGameWindowResized(frame)

		modApi.events.onGameWindowResized:subscribe(function(screen, oldSize)
			onGameWindowResized(frame, screen, oldSize)
		end)
	end)
end

loadConfig()
modApi.events.onProfileChanged:subscribe(loadConfig)

sdlext.addModContent("Configure EasyEdit", mainButton, "Configure some features of EasyEdit")
