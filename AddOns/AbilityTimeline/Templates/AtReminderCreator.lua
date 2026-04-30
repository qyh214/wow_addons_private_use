local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")
local Type = "AtReminderCreator"
local Version = 1
local variables = {
    x = 420,
    y = 280,
    titleBar = {
        height = 30,
        padding = {
            x = 0,
            y = -10,
        },
    },
    contentFrame = {
        padding = {
            x = 10,
            y = -40,
        }
    },

}


---@param self AtReminderCreator
local function OnAcquire(self)
    self.frame:SetPoint("CENTER", private.TIMINGS_EDITOR_WINDOW.frame, "CENTER")
    self.frame:SetFrameStrata("DIALOG")
    self:SetLayout("List")
end

---@param self AtReminderCreator
local function OnRelease(self)
    self:ReleaseChildren()
    self.frame:Hide()
end


local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", Type .. count, private.TIMINGS_EDITOR_WINDOW.frame, "BackdropTemplate")
    frame:SetFrameStrata("DIALOG")
    frame:SetSize(variables.x, variables.y)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.95)
    frame:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
    frame:SetAlpha(1)

    -- Add an explicit dark overlay to guarantee opacity
    local overlay = frame:CreateTexture(nil, "BACKGROUND")
    overlay:SetAllPoints()
    overlay:SetColorTexture(0, 0, 0, 0.95)
    frame:SetPoint("CENTER", private.TIMINGS_EDITOR_WINDOW.frame, "CENTER")
    local titleBar = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleBar:SetPoint("TOP", frame, "TOP", variables.titleBar.padding.x, variables.titleBar.padding.y)
    titleBar:SetText(private.getLocalisation("ReminderAddTitle"))
    titleBar:SetHeight(variables.titleBar.height)

    local function SetTitle(self, title)
        titleBar:SetText(title)
    end

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

    local contentFrameName = Type .. "ContentFrame" .. count
    local contentFrame = CreateFrame("Frame", contentFrameName, frame)

    contentFrame:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        variables.contentFrame.padding.x,
        variables.contentFrame.padding.y - titleBar:GetHeight()
    )
    contentFrame:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT"
    )


    ---@class AtReminderCreator : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
        closeButton = closeButton,
        content = contentFrame,
        SetTitle = SetTitle,
    }

    return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
