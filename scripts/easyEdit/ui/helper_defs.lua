
local helpers = {}

helpers.FONT_TITLE = sdlext.font("fonts/JustinFont12Bold.ttf", 16)
helpers.TEXT_SETTINGS_TITLE = deco.uifont.default.set
helpers.FONT_LABEL = sdlext.font("fonts/JustinFont12Bold.ttf", 12)
helpers.TEXT_SETTINGS_LABEL = deco.uifont.default.set
helpers.ENTRY_HEIGHT = 60
helpers.LABEL_HEIGHT = 19
helpers.OBJECT_LIST_HEIGHT = 40
helpers.OBJECT_LIST_PADDING = 23
helpers.OBJECT_LIST_GAP = 53
helpers.SCROLL_BAR_WIDTH = 16
helpers.COLOR_GREEN = sdl.rgb(64, 196, 64)
helpers.COLOR_YELLOW = sdl.rgb(192, 192, 64)
helpers.COLOR_RED = sdl.rgb(192, 32, 32)
helpers.ORIENTATION_VERTICAL = false
helpers.ORIENTATION_HORIZONTAL = true

return helpers
