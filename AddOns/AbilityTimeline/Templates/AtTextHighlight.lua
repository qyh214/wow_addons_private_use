local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local Type = "AtTextHighlight"
local Version = 1
local variables = {
    text_height = 20,
    text_width = 300,
}


local function ApplySettings(self)
    -- Apply settings to the icon
    if private.db.profile.highlight_text_settings and private.db.profile.highlight_text_settings.font and private.db.profile.highlight_text_settings.fontSize then
        self.frame.SpellName:SetFont(SharedMedia:Fetch("font", private.db.profile.highlight_text_settings.font),
            private.db.profile.highlight_text_settings.fontSize, "OUTLINE")
    elseif private.db.profile.highlight_text_settings and private.db.profile.highlight_text_settings.fontSize then
        self.frame.SpellName:SetFontHeight(private.db.profile.highlight_text_settings.fontSize)
    end

    if private.db.profile.highlight_text_settings and private.db.profile.highlight_text_settings.defaultColor then
        self.frame.SpellName:SetTextColor(
            private.db.profile.highlight_text_settings.defaultColor.r,
            private.db.profile.highlight_text_settings.defaultColor.g,
            private.db.profile.highlight_text_settings.defaultColor.b
        )
    end

    if private.db.profile.highlight_text_settings and private.db.profile.highlight_text_settings.enableShadow then
        self.frame.SpellName:SetShadowColor(0, 0, 0, 1)
    else
        self.frame.SpellName:SetShadowColor(0, 0, 0, 0)
    end

    if private.db.profile.highlight_text_settings and private.db.profile.highlight_text_settings.strata then
		self.frame:SetFrameStrata(private.db.profile.highlight_text_settings.strata)
	end

    if private.db.profile.highlight_text_settings.useBackground then
        local texture = SharedMedia:Fetch("background", private.db.profile.highlight_text_settings.backgroundTexture)
        self.frame.SpellNameBackground:SetPoint("LEFT", self.frame.SpellName, "LEFT",
            -private.db.profile.highlight_text_settings.backgroundTextureOffset.x, 0)
        self.frame.SpellNameBackground:SetPoint("RIGHT", self.frame.SpellName, "RIGHT",
            private.db.profile.highlight_text_settings.backgroundTextureOffset.x, 0)
        self.frame.SpellNameBackground:SetPoint("TOP", self.frame.SpellName, "TOP", 0,
            private.db.profile.highlight_text_settings.backgroundTextureOffset.y)
        self.frame.SpellNameBackground:SetPoint("BOTTOM", self.frame.SpellName, "BOTTOM", 0,
            -private.db.profile.highlight_text_settings.backgroundTextureOffset.y)
        self.frame.SpellNameBackground:SetTexture(texture)
        self.frame.SpellNameBackground:Show()
    else
        self.frame.SpellNameBackground:Hide()
    end
end

---@param self AtTextHighlight
local function OnAcquire(self)
    ApplySettings(self)
end

---@param self AtTextHighlight
local function OnRelease(self)
    self.frame:SetScript("OnUpdate", nil)
    private.HIGHLIGHT_EVENTS.HighlightTexts[self.eventInfo.id] = nil
    for i, f in ipairs(private.HIGHLIGHT_TEXTS) do
        if f == self then
            table.remove(private.HIGHLIGHT_TEXTS, i)
            break
        end
    end
    private.evaluateTextPositions()
end


---comment
---@param self any
---@param remainingTime any
---@return unknown
local GetTextColor = function(self, remainingTime)
    if private.db.profile.cooldown_settings.cooldown_highlight and private.db.profile.cooldown_settings.cooldown_highlight.enabled then
        for _, value in pairs(private.db.profile.cooldown_settings.cooldown_highlight.highlights) do
            local time, color = value.time, value.color
            if (remainingTime <= time) then
                local createdColor = CreateColor(color.r, color.g, color.b)
                return createdColor:GenerateHexColor()
            end
        end
    end
    if private.db.profile.cooldown_settings.cooldown_color then
        local color = private.db.profile.cooldown_settings.cooldown_color
        local createdColor = CreateColor(color.r, color.g, color.b)
        return createdColor:GenerateHexColor()
    end
    return "ffffff"
end
---hides and shows texts to create colored texts (illegal btw)
---@param widget any
---@param eventInfo any
---@param remainingDuration any
local HandleTexts = function(widget, eventInfo, remainingDuration)
    local textColor = GetTextColor(widget, remainingDuration)
    local EventIconTextureID = eventInfo.id
    if eventInfo.source == Enum.EncounterTimelineEventSource.Script and private.BossModsSpellIndicators and private.BossModsSpellIndicators[eventID] then
        EventIconTextureID = private.BossModsSpellIndicators[eventID]	
    end
    C_EncounterTimeline.SetEventIconTextures(EventIconTextureID, 126, widget.frame.dispellTypeIcons)
    local atlas = widget.frame.dispellTypeIcons[1]:GetAtlas()
    local formatedText = string.format("%s in |c%s%i|r", eventInfo.spellName, textColor,
        math.ceil(remainingDuration))
    if private.db.profile.highlight_text_settings.dispellIcons then
        formatedText = string.format("|A:%s:20:20|a %s in |c%s%i|r", atlas, eventInfo.spellName, textColor,
            math.ceil(remainingDuration))
    end
    widget.frame.SpellName:SetText(formatedText)
    if private.db.profile.text_settings.useEventColor then
        if issecretvalue(eventInfo.icons) then
            widget.frame.SpellName:SetTextColor(eventInfo.color.r, eventInfo.color.g, eventInfo.color.b)
        elseif private.db.profile.dispellTextColor and eventInfo.icons and eventInfo.icons ~= 0 then
            for _, value in pairs(private.dispellTypeList) do
                if bit.band(eventInfo.icons, value.mask) ~= 0 then
                    widget.frame.SpellName:SetTextColor(value.color.r, value.color.g, value.color.b)
                    break -- Only set the first matching color
                end
            end
        end
    end
end

local SetEventInfo = function(widget, eventInfo, disableOnUpdate)
    widget.eventInfo = eventInfo
    local yOffset = (variables.text_height + private.db.global.text_highlight[private.ACTIVE_EDITMODE_LAYOUT].margin) *
        (#private.HIGHLIGHT_TEXTS)
    widget.yOffset = yOffset
    if not disableOnUpdate then
        HandleTexts(widget, eventInfo, eventInfo.duration)
        widget.frame:SetScript("OnUpdate", function(self)
            local remainingDuration = C_EncounterTimeline.GetEventTimeRemaining(widget.eventInfo.id)
            local state = C_EncounterTimeline.GetEventState(widget.eventInfo.id)
            if not remainingDuration or remainingDuration <= 0 or state ~= private.ENCOUNTER_STATES.Active then
                widget:Release()
            else
                HandleTexts(widget, eventInfo, remainingDuration)
            end
        end)
    end
    widget.frame:SetPoint("BOTTOM", private.TEXT_HIGHLIGHT_FRAME.frame, "BOTTOM", 0, yOffset)
    widget.frame:Show()
end

local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", "HIGHLIGHT_TEXT_" .. count, private.TEXT_HIGHLIGHT_FRAME.frame)
    local yOffset = (variables.text_height + private.db.global.text_highlight[private.ACTIVE_EDITMODE_LAYOUT].margin) *
        (#private.HIGHLIGHT_TEXTS)
    frame.yOffset = yOffset
    frame.SpellName = frame:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med3")
    frame.SpellName:SetWordWrap(false)
    frame.SpellName:SetPoint("CENTER", frame, "CENTER")
    frame:SetFrameStrata(private.FrameStrata.FULLSCREEN)

    frame.SpellNameBackground = frame:CreateTexture(nil, "BACKGROUND")
    frame.SpellNameBackground:SetPoint("LEFT", frame.SpellName, "LEFT",
        -private.db.profile.highlight_text_settings.backgroundTextureOffset.x, 0)
    frame.SpellNameBackground:SetPoint("RIGHT", frame.SpellName, "RIGHT",
        private.db.profile.highlight_text_settings.backgroundTextureOffset.x, 0)
    frame.SpellNameBackground:SetPoint("TOP", frame.SpellName, "TOP", 0,
        private.db.profile.highlight_text_settings.backgroundTextureOffset.y)
    frame.SpellNameBackground:SetPoint("BOTTOM", frame.SpellName, "BOTTOM", 0,
        -private.db.profile.highlight_text_settings.backgroundTextureOffset.y)
    frame.SpellNameBackground:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
    frame.SpellNameBackground:Hide()
    frame:SetWidth(variables.text_width)
    frame:SetHeight(variables.text_height)
    frame:SetPoint("BOTTOM", private.TEXT_HIGHLIGHT_FRAME.frame, "BOTTOM", 0, yOffset)

    frame.dispellTypeTexture = frame:CreateTexture(nil, "OVERLAY")
    frame.dispellTypeIcons = {}
    table.insert(frame.dispellTypeIcons, frame.dispellTypeTexture)

    ---@class AtTextHighlight : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
        SetEventInfo = SetEventInfo,
        eventInfo = {},
        yOffset = 0,
        GetTextColor = GetTextColor,
        ApplySettings = ApplySettings,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
