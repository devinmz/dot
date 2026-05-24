local colors = require("colors")
local settings = require("settings")

local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null || echo 'Light'")
local output = handle and handle:read("*a"):match("^%s*(.-)%s*$"):lower() or "light"
if handle then handle:close() end
local appearance = output

local current_app = sbar.add("item", "widgets.current_app", {
    position = "right",
    display = "active",
    icon = { drawing = false },
    label = {
        string = "App",
        color = colors[appearance].blue,
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Bold"],
        },
        padding_left = 13,
        padding_right = 13,
    },
    background = {
        color = colors[appearance].blue_bg,
        border_width = 0,
    },
    updates = true,
})

local wecom = sbar.add("item", "widgets.wecom", {
    position = "right",
    icon = { drawing = false },
    label = {
        string = "企微 --",
        color = colors[appearance].green,
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Bold"],
        },
        padding_left = 13,
        padding_right = 13,
    },
    background = {
        color = colors[appearance].green_bg,
        border_width = 0,
    },
    update_freq = 15,
    updates = true,
})

local note = sbar.add("item", "widgets.note", {
    position = "right",
    icon = { drawing = false },
    label = {
        string = "奔波儿霸 霸波儿奔",
        color = colors[appearance].orange,
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Bold"],
        },
        padding_left = 13,
        padding_right = 13,
    },
    background = {
        color = colors[appearance].orange_bg,
        border_width = 0,
    },
})

local function update_wecom()
    local script = [[osascript -e 'tell application "System Events" to tell process "Dock" to get value of attribute "AXStatusLabel" of UI element "企业微信" of list 1' 2>/dev/null]]

    sbar.exec(script, function(result)
        local count = tostring(result or ""):match("(%d+)")
        wecom:set({ label = { string = "企微 " .. (count or "0") } })
    end)
end

current_app:subscribe("front_app_switched", function(env)
    current_app:set({ label = { string = env.INFO } })
end)

wecom:subscribe({ "forced", "routine", "system_woke" }, update_wecom)

current_app:subscribe("apperace_change", function()
    sbar.exec("defaults read -g AppleInterfaceStyle 2>/dev/null || echo 'Light'", function(theme)
        appearance = theme:match("^%s*(.-)%s*$"):lower()
        sbar.animate("tanh", 10, function()
            current_app:set({
                label = { color = colors[appearance].blue },
                background = { color = colors[appearance].blue_bg },
            })
            note:set({
                label = { color = colors[appearance].orange },
                background = { color = colors[appearance].orange_bg },
            })
            wecom:set({
                label = { color = colors[appearance].green },
                background = { color = colors[appearance].green_bg },
            })
        end)
    end)
end)

sbar.add("bracket", "items.right.panel", {
    current_app.name,
    wecom.name,
    note.name,
}, {
    background = {
        color = colors.dark.bar.transparent,
        border_width = 0,
        height = 28,
        padding_left = 0,
        padding_right = 0,
        corner_radius = 5,
    },
})

update_wecom()
