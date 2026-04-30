local appName, app = ...
---@class AbilityTimeline
local private = app
local AceLocale = LibStub ('AceLocale-3.0')
local currentLocale = LibStub ('AceLocale-3.0'):GetLocale (appName, true)---@type AbilityTimelineLocale
private.getLocalisation = function(Object)
      return currentLocale[Object]
end
