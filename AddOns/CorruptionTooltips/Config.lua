local L = LibStub("AceLocale-3.0"):GetLocale("CorruptionTooltips")

local myOptions =
{
    name = "Corruption Tooltips",
    type = "group",
    args =
    {
        toggle =
        {
            type = "toggle",
            name = L["Append to corruption stat"],
            desc = L["Use the new style tooltip."],
            set = function(info, val)
                CorruptionTooltips.db.profile.append = val
            end,
            get = function() return CorruptionTooltips.db.profile.append end,
            width = "full",
            order = 10,
        },
        icon =
        {
            type = "toggle",
            name = L["Show icon"],
            desc = L["Show the spell icon along with the name."],
            set = function(info, val)
                CorruptionTooltips.db.profile.icon = val
            end,
            get = function() return CorruptionTooltips.db.profile.icon end,
            width = "full",
            order = 20,
        },
        summary =
        {
            type = "toggle",
            name = L["Show summary on the corruption tooltip"],
            desc = L["List your corruptions in the eye tooltip in the character screen."],
            set = function(info, val)
                CorruptionTooltips.db.profile.summary = val
            end,
            get = function() return CorruptionTooltips.db.profile.summary end,
            width = "full",
            order = 30,
        },
        itemlevel =
        {
            type = "toggle",
            name = L["Show corruption amount in the character screen"],
            desc = L["Show corruption stat on items in the character screen when displaying the corruption tooltip."],
            set = function(info, val)
                CorruptionTooltips.db.profile.showlevel = val
            end,
            get = function() return CorruptionTooltips.db.profile.showlevel end,
            width = "full",
            order = 40,
        },
        english =
        {
            type = "toggle",
            name = L["Display in English"],
            desc = L["Don't translate the corruption effect names."],
            set = function(info, val)
                CorruptionTooltips.db.profile.english = val
            end,
            get = function() return CorruptionTooltips.db.profile.english end,
            width = "full",
            order = 50,
        }
    },
}

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
AceConfig:RegisterOptionsTable("CorruptionTooltips", myOptions, {"ct"})
AceConfigDialog:AddToBlizOptions("CorruptionTooltips", "Corruption Tooltips", nil)
