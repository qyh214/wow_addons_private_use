local appName, app = ...
---@class AbilityTimeline
local private = app

-- easy lookup table
local dispellTypeColors = {}
for _, dispellTypeInfo in pairs(private.dispellTypeList) do
   dispellTypeColors[dispellTypeInfo.mask] = CreateColor(
      dispellTypeInfo.color.r,
      dispellTypeInfo.color.g,
      dispellTypeInfo.color.b,
      dispellTypeInfo.color.a
   )
end

private.spellIDColors = {}

local EventColors = {}
local SetupEventColorisation = function()
    if EventColors and next(EventColors) then return end -- already setup
    for eventID in pairs(C_EncounterEvents.GetEventList()) do
        local eventInfo = C_EncounterEvents.GetEventInfo(eventID)
        local icons = eventInfo and eventInfo.icons
        if icons then
            for mask, color in pairs(dispellTypeColors) do
                if bit.band(icons, mask) ~= 0 then
                    EventColors[eventID] = eventInfo.color
                    private.spellIDColors[eventInfo.spellID] = eventInfo.color
                    C_EncounterEvents.SetEventColor(eventID, color)
                    break -- Only set the first matching color
                end
            end
        end
    end
end

local RemoveEventColorisation = function()
    for eventID, color in pairs(EventColors) do
        if color then
            C_EncounterEvents.SetEventColor(eventID, color)
        else
            local color = CreateColor(private.db.profile.text_settings.defaultColor.r, private.db.profile.text_settings.defaultColor.g, private.db.profile.text_settings.defaultColor.b)
            C_EncounterEvents.SetEventColor(eventID, color)
        end
    end
    wipe(EventColors)
end

private.ToggleEventColorisation = function(enable)
    if enable then
        SetupEventColorisation()
    else
        RemoveEventColorisation()
    end
end

