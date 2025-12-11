local env = select(2, ...)
local GenericEnum = env.WPM:New("wpm_modules/generic-enum")

do -- Color
    GenericEnum.ColorRGB = {
        White               = { r = 255 / 255, g = 255 / 255, b = 255 / 255 },
        Black               = { r = 25 / 255, g = 25 / 255, b = 25 / 255 },
        Orange              = { r = 255 / 255, g = 166 / 255, b = 0 / 255 },
        Yellow              = { r = 255 / 255, g = 204 / 255, b = 26 / 255 },
        Green               = { r = 82 / 255, g = 204 / 255, b = 51 / 255 },
        Green02             = { r = 82 / 255, g = 175 / 255, b = 51 / 255 },
        Red                 = { r = 208 / 255, g = 85 / 255, b = 85 / 255 },
        Gray                = { r = 157 / 255, g = 157 / 255, b = 157 / 255 },
        LightGray           = { r = 205 / 255, g = 205 / 255, b = 205 / 255 },
        ProgressGreen       = { r = 78 / 255, g = 144 / 255, b = 80 / 255 },
        ProgressOrange      = { r = 215 / 255, g = 154 / 255, b = 91 / 255 },
        ProgressBronze      = { r = 172 / 255, g = 150 / 255, b = 122 / 255 },

        StatInt             = { r = 84 / 255, g = 54 / 255, b = 87 / 255 },
        StatStr             = { r = 108 / 255, g = 56 / 255, b = 60 / 255 },
        StatAgl             = { r = 100 / 255, g = 88 / 255, b = 75 / 255 },
        StatCrit            = { r = 87 / 255, g = 54 / 255, b = 54 / 255 },
        StatHaste           = { r = 75 / 255, g = 100 / 255, b = 85 / 255 },
        StatMastery         = { r = 74 / 255, g = 55 / 255, b = 85 / 255 },
        StatVers            = { r = 75 / 255, g = 75 / 255, b = 75 / 255 },
    }

    GenericEnum.ColorHEX = {
        White               = "|cffFFFFFF",
        Black               = "|cff000000",
        Orange              = "|cffFFA500",
        Yellow              = "|cffFFCC1A",
        Green               = "|cff54CB34",
        Green02             = "|cff52AF33",
        Red                 = "|cffD05555",
        Gray                = "|cff9D9D9D",
        LightGray           = "|cffCDCDCD",
        ProgressGreen       = "|cff4E9050",
        ProgressOrange      = "|cffD79A5B",
        ProgressBronze      = "|cffAC967A",
        StatInt             = "|cff543657",
        StatStr             = "|cff6C383C",
        StatAgl             = "|cff64584B",
        StatCrit            = "|cff573636",
        StatHaste           = "|cff4B6455",
        StatMastery         = "|cff4A3755",
        StatVers            = "|cff4B4B4B",
    }
end
