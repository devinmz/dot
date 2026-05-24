local colors = require("colors")
local settings = require("settings")

local yabai_path = "/opt/homebrew/bin/yabai"

local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null || echo 'Light'")
local output = handle and handle:read("*a"):match("^%s*(.-)%s*$"):lower() or "light"
if handle then handle:close() end
local appearance = output

local group_defs = {
    work = {
        icon = "",
        color = "green",
        space = 1,
    },
    browser = {
        icon = "",
        color = "blue",
        space = 2,
    },
    cursor = {
        icon = "",
        color = "orange",
        space = 3,
    },
    other = {
        icon = "",
        color = "magenta",
        space = 4,
    },
}

local extra_space_start = 5
local extra_space_max = 16
local item_gap = 10
local compact_width = 30
local compact_icon_width = compact_width
local expanded_icon_width = 22
local item_height = 30
local item_radius = 8
local label_gap = 8
local icon_label_gap = 14

for index = extra_space_start, extra_space_max do
    group_defs["space" .. index] = {
        icon = tostring(index),
        color = "yellow",
        space = index,
        extra = true,
    }
end

local function color_for(group, alpha)
    local value = colors[appearance][group_defs[group].color]
    if alpha then return colors.with_alpha(value, alpha) end
    return value
end

local function bg_for(group)
    return colors[appearance][group_defs[group].color .. "_bg"]
end

local function unique_insert(list, seen, value)
    if value and value ~= "" and not seen[value] then
        seen[value] = true
        table.insert(list, value)
    end
end

local function each_line(output, callback)
    if type(output) ~= "string" then return end
    for line in output:gmatch("[^\r\n]+") do
        callback(line)
    end
end

local function read_command(command)
    local handle = io.popen(command)
    if not handle then return "" end

    local output = handle:read("*a") or ""
    handle:close()
    return output
end

local function make_group(name)
    local def = group_defs[name]
    local has_label = name == "other" or def.extra

    return sbar.add("item", "left." .. name, {
        position = "left",
        drawing = not def.extra,
        width = has_label and "dynamic" or compact_width,
        padding_left = 0,
        padding_right = 0,
        icon = {
            string = def.icon,
            color = color_for(name, 0.55),
            highlight_color = color_for(name),
            align = has_label and "left" or "center",
            width = has_label and 0 or compact_icon_width,
            font = {
                family = settings.font.text,
                style = settings.font.style_map["Bold"],
                size = 18.0,
            },
            padding_left = has_label and label_gap or 0,
            padding_right = 0,
        },
        label = {
            drawing = has_label and "on" or "off",
            string = "",
            color = color_for(name, 0.85),
            font = {
                family = settings.font.text,
                style = settings.font.style_map["Semibold"],
                size = 12.0,
            },
            padding_left = has_label and label_gap or 0,
            padding_right = has_label and label_gap or 0,
        },
        background = {
            color = colors.transparent,
            border_width = 0,
            height = item_height,
            corner_radius = item_radius,
            padding_left = 0,
            padding_right = 0,
        },
        updates = true,
    })
end

local display_order = { "work", "browser", "cursor", "other" }
for index = extra_space_start, extra_space_max do
    table.insert(display_order, "space" .. index)
end

local groups = {}
local gaps = {}
local bracket_members = {}

for index, name in ipairs(display_order) do
    groups[name] = make_group(name)
    table.insert(bracket_members, groups[name].name)

    if index < #display_order then
        local gap = sbar.add("item", "left.gap.after." .. name, {
            position = "left",
            width = item_gap,
            padding_left = 0,
            padding_right = 0,
            icon = { drawing = false },
            label = { drawing = false },
            background = {
                color = colors.transparent,
                border_width = 0,
            },
            drawing = true,
        })

        gaps[name] = gap
        table.insert(bracket_members, gap.name)
    end
end

local function set_group_state(name, exists, is_active, apps_label)
    local def = group_defs[name]
    local can_show_apps = name == "other" or def.extra
    local has_apps = can_show_apps and apps_label and apps_label ~= ""
    local bg = colors.transparent
    local icon_alpha = 0.25
    local label_alpha = 0.25

    if is_active then
        bg = bg_for(name)
        icon_alpha = 1.0
        label_alpha = 1.0
    elseif exists then
        bg = colors.with_alpha(bg_for(name), 0.70)
        icon_alpha = 0.95
        label_alpha = 0.90
    else
        icon_alpha = 0.45
        label_alpha = 0.45
    end

    groups[name]:set({
        width = has_apps and "dynamic" or compact_width,
        padding_left = 0,
        padding_right = 0,
        icon = {
            highlight = is_active,
            color = color_for(name, icon_alpha),
            align = has_apps and "left" or "center",
            width = has_apps and expanded_icon_width or compact_icon_width,
            padding_left = has_apps and label_gap or 0,
            padding_right = 0,
        },
        label = {
            drawing = has_apps and "on" or "off",
            string = has_apps and apps_label or "",
            color = color_for(name, label_alpha),
            padding_left = has_apps and icon_label_gap or 0,
            padding_right = has_apps and label_gap or 0,
        },
        background = {
            color = bg,
            height = item_height,
            corner_radius = item_radius,
            padding_left = 0,
            padding_right = 0,
            border_width = is_active and 1 or 0,
            border_color = color_for(name, 0.95),
        },
        drawing = (not def.extra) or exists,
        click_script = exists and (yabai_path .. " -m space --focus " .. def.space) or "",
    })
end

local function set_gap_state(name, drawing)
    if gaps[name] then
        gaps[name]:set({ drawing = drawing })
    end
end

local function update_groups()
    local spaces_cmd = yabai_path .. " -m query --spaces | /opt/homebrew/bin/jq -r '.[] | [.index, .[\"has-focus\"]] | @tsv'"

    local state = {
        work = { exists = false, active = false },
        browser = { exists = false, active = false },
        cursor = { exists = false, active = false },
        other = { exists = false, active = false, apps = {}, seen = {} },
    }

    for index = extra_space_start, extra_space_max do
        state["space" .. index] = { exists = false, active = false, apps = {}, seen = {} }
    end

    each_line(read_command(spaces_cmd), function(line)
        local index, has_focus = line:match("^(%d+)%s+(%S+)$")
        index = tonumber(index)

        for name, def in pairs(group_defs) do
            if index == def.space then
                state[name].exists = true
                state[name].active = has_focus == "true"
            end
        end
    end)

    local windows_cmd = yabai_path .. " -m query --windows | /opt/homebrew/bin/jq -r '.[] | [.space, .app] | @tsv'"

    each_line(read_command(windows_cmd), function(line)
        local space, app = line:match("^(%d+)%s+(.+)$")
        space = tonumber(space)

        if space == group_defs.other.space then
            unique_insert(state.other.apps, state.other.seen, app)
        elseif space and space >= extra_space_start and space <= extra_space_max then
            local name = "space" .. space
            unique_insert(state[name].apps, state[name].seen, app)
        end
    end)

    table.sort(state.other.apps)
    local other_label = table.concat(state.other.apps, " ")

    set_group_state("work", state.work.exists, state.work.active)
    set_group_state("browser", state.browser.exists, state.browser.active)
    set_group_state("cursor", state.cursor.exists, state.cursor.active)
    set_group_state("other", state.other.exists, state.other.active, other_label)

    set_gap_state("work", true)
    set_gap_state("browser", true)
    set_gap_state("cursor", true)
    set_gap_state("other", state.space5.exists)

    for index = extra_space_start, extra_space_max do
        local name = "space" .. index
        table.sort(state[name].apps)
        set_group_state(name, state[name].exists, state[name].active, table.concat(state[name].apps, " "))
        set_gap_state(name, index < extra_space_max and state["space" .. (index + 1)].exists)
    end
end

local observer = sbar.add("item", "left.groups.observer", {
    drawing = false,
    update_freq = 2,
    updates = true,
})

observer:subscribe({ "forced", "routine", "front_app_switched", "space_change", "space_windows_change", "system_woke" }, update_groups)

local bracket = sbar.add("bracket", "items.groups.bracket", bracket_members, {
    background = {
        color = colors[appearance].spaces.bg,
        border_width = 0,
    },
    shadow = true,
})

bracket:subscribe("apperace_change", function()
    sbar.exec("defaults read -g AppleInterfaceStyle 2>/dev/null || echo 'Light'", function(theme)
        appearance = theme:match("^%s*(.-)%s*$"):lower()
        bracket:set({
            background = {
                color = colors[appearance].spaces.bg,
            },
        })
        update_groups()
    end)
end)

local spacer = sbar.add("item", "spacer.left.panel.inner", {
    icon = {
        drawing = false,
    },
    label = {
        drawing = false,
    },
    background = {
        color = colors.transparent,
        border_width = 0,
        padding_left = 0,
        padding_right = 0,
    },
    drawing = true,
    updates = true,
    width = 15,
})

sbar.add("bracket", "items.left.panel", {
    bracket.name,
    spacer.name,
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

update_groups()
