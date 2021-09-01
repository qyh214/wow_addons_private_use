-- Define Localization table

local _, Internal = ...

local L = {}
setmetatable(L, {
    __index = function (self, key)
        return key
    end,
})
Internal.L = L

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
