local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")

local Type = "AtTimelineTicks"
local Version = 1
local variables = {
    color = {
        r = 1,
        g = 1,
        b = 1,
        a = 1,
    },
    height = 1,
    width = 10,
    textOffset = {
        x = 5,
        y = 0,
    }
}

---@param self AtTimelineTicks
local function OnAcquire(self)
end

---@param self AtTimelineTicks
local function OnRelease(self)
    self.frame.tickText:SetText("")
    self.frame:ClearAllPoints()
end

local function SetTick(self, relativeTo, tick, totalSize, threshhold, isHorizontal)
    self.frame.tickText:SetText(tick .. "s")
    local tickPosition = (tick / threshhold) * totalSize
    self.frame:ClearAllPoints()
    self.frame.tickLine:ClearAllPoints()
    self.frame.tickText:ClearAllPoints()
    self.tick = tick
    if isHorizontal then
        self.frame:SetPoint("TOPLEFT", relativeTo, "TOPLEFT", tickPosition, 0)
        self.frame:SetPoint("BOTTOMLEFT", relativeTo, "BOTTOMLEFT", tickPosition, 0)
        self.frame.tickLine:SetPoint("TOP", self.frame, "TOP", 0, 0)
        self.frame.tickLine:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 0)
        self.frame.tickText:SetPoint("BOTTOM", self.frame.tickLine, "TOP", variables.textOffset.y, variables.textOffset
            .x)
    else
        self.frame:SetPoint("LEFT", relativeTo, "BOTTOMLEFT", 0, tickPosition)
        self.frame:SetPoint("RIGHT", relativeTo, "BOTTOMRIGHT", 0, tickPosition)
        self.frame.tickLine:SetPoint("LEFT", self.frame, "LEFT", 0, 0)
        self.frame.tickLine:SetPoint("RIGHT", self.frame, "RIGHT", 0, 0)
        self.frame.tickText:SetPoint("LEFT", self.frame.tickLine, "RIGHT", variables.textOffset.x, variables.textOffset
            .y)
    end
    self.frame:SetParent(relativeTo)
end


local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)

    local frame = CreateFrame("Frame", Type .. count, UIParent)

    frame:SetHeight(variables.height)
    frame:SetWidth(variables.width)
    frame.tickLine = frame:CreateTexture(nil, "ARTWORK")
    frame.tickLine:SetColorTexture(variables.color.r, variables.color.g, variables.color.b, variables.color.a)
    frame.tickLine:SetPoint("LEFT", frame, "LEFT", 0, 0)
    frame.tickLine:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    frame.tickText = frame:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med3")
    frame.tickText:SetPoint("LEFT", frame.tickLine, "RIGHT", variables.textOffset.x, variables.textOffset.y)
    frame.tickText:SetJustifyH("CENTER")
    frame:Hide()

    ---@class AtTimelineTicks : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        frame = frame,
        type = Type,
        count = count,
        SetTick = SetTick,
        tick = 0,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
