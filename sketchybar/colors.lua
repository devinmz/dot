return {
    light = {
        black = 0xff0A0E14,
        white = 0xffE6E1CF,
        red = 0xffF07178,
        red_bg = 0xff3D1F2A,
        green = 0xffAAD94C,
        green_bg = 0xff2C3A1F,
        blue = 0xff59C2FF,
        blue_bg = 0xff123247,
        yellow = 0xffFFD580,
        magenta = 0xffD2A6FF,
        magenta_bg = 0xff3A2A4D,
        grey = 0xffB3B1AD,
        grey_bg = 0xff1F2430,
        orange = 0xffFFB454,
        orange_bg = 0xff4A3320,
        yellow_bg = 0xff4D3D1A,
        fg = 0xffE6E1CF,
        fg_bg = 0xff1F2430,

        spaces = {
            bg = 0xee0A0E14,
            fg = 0xffE6E1CF,
        },

        bar = {
            bg = 0xee0A0E14,
            border = 0xff1F2430,
        },
        popup = {
            bg = 0xee0A0E14,
            border = 0xff3B4354
        },
        bg1 = 0xff0F1419,
        bg2 = 0xff1F2430,

    },
    dark = {
        black = 0xff0A0E14,
        white = 0xffE6E1CF,
        red = 0xffF07178,
        red_bg = 0xff3D1F2A,
        green = 0xffAAD94C,
        green_bg = 0xff2C3A1F,
        blue = 0xff59C2FF,
        blue_bg = 0xff123247,
        yellow = 0xffFFD580,
        magenta = 0xffD2A6FF,
        magenta_bg = 0xff3A2A4D,
        grey = 0xffB3B1AD,
        grey_bg = 0xff1F2430,
        orange = 0xFFFFB454,
        orange_bg = 0xff4A3320,
        yellow_bg = 0xff4D3D1A,
        fg = 0xffE6E1CF,
        fg_bg = 0xff1F2430,

        spaces = {
            bg = 0xee0A0E14,
            fg = 0xffE6E1CF,
        },

        bar = {
            bg = 0xee0A0E14,
            border = 0xff1F2430,
        },
        popup = {
            bg = 0xee0A0E14,
            border = 0xff3B4354
        },
        bg1 = 0xff0F1419,
        bg2 = 0xff1F2430,
    },

    transparent = 0x00000000,
    with_alpha = function(color, alpha)
        if alpha > 1.0 or alpha < 0.0 then return color end
        return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
    end,
}
