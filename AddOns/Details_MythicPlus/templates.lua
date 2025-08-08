
--this file contains defaults for the layout of the addon frames, like colors, sizes, etc.

local addonName, private = ...
---@type detailsmythicplus
local addon = private.addon

addon.templates = {}

---@class detailsmythicplus : table
---@field templates templateclass templates for the scoreboard and other frames

---@class templateclass : table
---@field activityTimeline activitytimeline_template template for the activity timeline in the scoreboard
---@field dropdownRunSelector dropdownrunselector_template template for the run selector dropdown in the scoreboard

---@class activitytimeline_template : table
---@field deathMarker_Size number size of the death marker
---@field deathMarker_RoleIconScale number scale of the role icon in the death marker
---@field deathMarker_PortraitDesaturation number desaturation of the portrait in the death marker
---@field deathMarker_RoleIconDesaturation number desaturation of the role icon in the death marker
---@field deathMarker_DefaultClassTexture string path to the default class texture
---@field deathMarker_TooltipWidth number width of the tooltip for the death marker

--activity timeline in the scoreboard
local activityTimelineTemplate = {
    deathMarker_Size = 24,
    deathMarker_RoleIconScale = 0.75, --scale from the deathMarkerSize
    deathMarker_PortraitDesaturation = 1, --full black and white
    deathMarker_RoleIconDesaturation = 0.6,
    deathMarker_DefaultClassTexture = "Interface\\TargetingFrame\\UI-Classes-Circles",
    deathMarker_TooltipWidth = 250,
}

addon.templates.activityTimeline = activityTimelineTemplate

--dropdown selector is positioned at the top right corner of the scoreboard
---@class dropdownrunselector_template : table
---@field width number width of the dropdown
---@field height number height of the dropdown
---@field dropdownHeight number height of the dropdown when opened

local dropdownRunSelector = {
    width = 250,
    height = 20,
    dropdownHeight = 400,
}

addon.templates.dropdownRunSelector = dropdownRunSelector
