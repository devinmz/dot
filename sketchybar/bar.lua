local colors = require("colors")

local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null || echo 'Light'")
local output = handle and handle:read("*a"):match("^%s*(.-)%s*$"):lower() or "light"
if handle then handle:close() end
local appearance = output

-- Equivalent to the --bar domain
sbar.bar({
    height = 39,
    color = colors[appearance].bar.bg,
    margin = 8,
    corner_radius = 12,
    padding_right = 12,
    padding_left = 12,
    y_offset = 4,
    blur_radius = 10,
    shadow = true,
    notch_width = 220,
    notch_offset = 0
})
