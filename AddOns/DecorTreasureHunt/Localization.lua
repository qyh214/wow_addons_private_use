local ADDON_NAME, DTH = ...;

local L = {
    enUS = {
        -- Options
        AUTO_ACCEPT = "Auto-Accept Quest",
        AUTO_TURNIN = "Auto Turn-In Quest",
        TOOLTIP_TEXT = "Click to configure auto-accept and auto turn-in settings",
        AUTO_ACCEPT_ENABLED = "Auto-Accept has been |cnGREEN_FONT_COLOR:enabled|r.",
        AUTO_ACCEPT_DISABLED = "Auto-Accept has been |cnRED_FONT_COLOR:disabled|r.",
        AUTO_TURNIN_ENABLED = "Auto Turn-In has been |cnGREEN_FONT_COLOR:enabled|r.",
        AUTO_TURNIN_DISABLED = "Auto Turn-In has been |cnRED_FONT_COLOR:disabled|r.",

        -- Main Addon
        QUEST_ACCEPTED = "Quest automatically accepted.",
        QUEST_TURNIN = "Quest automatically turned in.",
        WAYPOINT_SET = "Waypoint set to treasure location.",
    },

    deDE = {
        -- Options
        AUTO_ACCEPT = "Quest automatisch annehmen",
        AUTO_TURNIN = "Quest automatisch abgeben",
        TOOLTIP_TEXT = "Klicken um automatisches Annehmen und Abgeben zu konfigurieren",
        AUTO_ACCEPT_ENABLED = "Automatisches Annehmen wurde |cnGREEN_FONT_COLOR:aktiviert|r.",
        AUTO_ACCEPT_DISABLED = "Automatisches Annehmen wurde |cnRED_FONT_COLOR:deaktiviert|r.",
        AUTO_TURNIN_ENABLED = "Automatisches Abgeben wurde |cnGREEN_FONT_COLOR:aktiviert|r.",
        AUTO_TURNIN_DISABLED = "Automatisches Abgeben wurde |cnRED_FONT_COLOR:deaktiviert|r.",

        -- Main Addon
        QUEST_ACCEPTED = "Quest automatisch angenommen.",
        QUEST_TURNIN = "Quest automatisch abgegeben.",
        WAYPOINT_SET = "Wegpunkt zum Schatzfundort gesetzt.",
    }
};

DTH.L = L[GetLocale()] or L["enUS"];
