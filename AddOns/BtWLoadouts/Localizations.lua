-- Define Localization table

local _, Internal = ...

local L = {}
setmetatable(L, {
    __index = function (self, key)
        return key
    end,
})
Internal.L = L

local ACTION_BAR = HUD_EDIT_MODE_ACTION_BAR_LABEL or "Action Bar %d"
local STANCE_BAR = HUD_EDIT_MODE_STANCE_BAR_LABEL or "Stance Bar %d"

-- Fallbacks for items missing translations
L["Talents"] = TALENTS
L["PvP Talents"] = PVP_TALENTS
L["Equipment"] = BAG_FILTER_EQUIPMENT
L["Set: %s"] = ITEM_SET_BONUS
L["New Set"] = PAPERDOLL_NEWEQUIPMENTSET
L["Activate"] = TALENT_SPEC_ACTIVATE
L["Update"] = UPDATE
L["Delete"] = DELETE
L["Name"] = NAME
L["Specialization"] = SPECIALIZATION
L["None"] = NONE
L["New"] = NEW
L["World"] = WORLD
L["Dungeons"] = DUNGEONS
L["Raids"] = RAIDS
L["Arena"] = ARENA
L["Battlegrounds"] = BATTLEGROUNDS
L["Other"] = OTHER
L["Scenarios"] = SCENARIOS
L["Enabled"] = VIDEO_OPTIONS_ENABLED
L["Soulbinds"] = COVENANT_PREVIEW_SOULBINDS

L["Action Bar 2"] = format(ACTION_BAR, 2)
L["Action Bar 3"] = format(ACTION_BAR, 3)
L["Action Bar 4"] = format(ACTION_BAR, 4)
L["Action Bar 5"] = format(ACTION_BAR, 5)
L["Action Bar 6"] = format(ACTION_BAR, 6)
L["Action Bar 7"] = format(ACTION_BAR, 7)
L["Action Bar 8"] = format(ACTION_BAR, 8)
L["Stance Bar 1"] = format("%s %d", STANCE_BAR, 1)
L["Stance Bar 2"] = format("%s %d", STANCE_BAR, 2)
L["Stance Bar 3"] = format("%s %d", STANCE_BAR, 3)
L["Stance Bar 4"] = format("%s %d", STANCE_BAR, 4)
