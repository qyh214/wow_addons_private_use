local appName, app = ...
---@class AbilityTimeline
local private = app

---Adds a tooltip to a frame for a given localisation key
---@param frame frame
---@param localisationKey any
private.AddFrameTooltip = function(frame, localisationKey)
    frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(frame, "ANCHOR_TOPRIGHT")
        GameTooltip:AddLine(private.getLocalisation(localisationKey))
        GameTooltip:Show()
    end)

    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-- the following is prretty much just taken from https://github.com/Gethe/wow-ui-source/blob/3fefc3a27250137e2554384b413b9060a4fefcfd/Interface/AddOns/Blizzard_EncounterTimeline/EncounterTimelineEventFrame.lua#L159
local function GetTooltipFrame()
	return GameTooltip;
end

local function HideTooltip()
	local tooltipFrame = GetTooltipFrame();

	if tooltipFrame ~= nil then
		tooltipFrame:Hide();
	end
end

local function PopulateTooltip(tooltipFrame, eventInfo)
	tooltipFrame:SetSpellByID(eventInfo.spellID);
end

---Adds an EncounterTimelineEventInfo tooltip to a frame
---@param frame frame
---@param eventInfo EncounterTimelineEventInfo
---@param tooltipAnchor Enum.EncounterEventsTooltipAnchor
private.AddEventTooltip = function(frame, eventInfo, tooltipAnchor)
    frame:SetScript("OnEnter", function(self)
        local tooltipFrame = GetTooltipFrame();

        if tooltipFrame == nil then
            return;
        end

        HideTooltip();

        if tooltipAnchor == Enum.EncounterEventsTooltipAnchor.Default then
            GameTooltip_SetDefaultAnchor(tooltipFrame, self);
        elseif tooltipAnchor == Enum.EncounterEventsTooltipAnchor.Cursor then
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
        else
            assert(false, "Unsupported tooltip anchor mode (%s)", tooltipAnchor);
        end

        PopulateTooltip(tooltipFrame, eventInfo);
        tooltipFrame:Show();
    end)

    frame:SetScript("OnLeave", function(self)
        local tooltipFrame = GetTooltipFrame();

        if tooltipFrame ~= nil and tooltipFrame:IsOwned(self) then
            tooltipFrame:Hide();
        end
    end)
end
---clears an event frame tooltip
---@param frame frame
private.ClearEventTooltip = function(frame)
    frame:SetScript("OnEnter", nil)
    frame:SetScript("OnLeave", nil)
end 
