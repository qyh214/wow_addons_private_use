local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")

local Type = "AtImportDialog"
local Version = 1

local variables = {
    x = 600,
    y = 380,
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
            y = 5,
        }
    },
}

---@param self AtImportDialog
local function OnAcquire(self)
    self.frame:SetPoint("CENTER", UIParent, "CENTER")
    self.frame:SetFrameStrata("DIALOG")
    self:SetLayout("List")
    self.frame:Show()
end

---@param self AtImportDialog
local function OnRelease(self)
    self:ReleaseChildren()
    self.frame:Hide()
end

local function SetTitle(self, title)
    self.frame.titleBar:SetText(title)
end

local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", Type .. count, UIParent, "BackdropTemplate")
    frame:SetFrameStrata("DIALOG")
    frame:SetSize(variables.x, variables.y)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame:SetBackdropColor(1, 1, 1, 1)

    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)


    frame.titleBar = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", variables.titleBar.padding.x, variables.titleBar.padding.y)
    frame.titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", variables.titleBar.padding.x, variables.titleBar.padding.y)
    frame.titleBar:SetText(private.getLocalisation("ImportDialogTitle"))
    frame.titleBar:SetHeight(variables.titleBar.height)

    frame.subtitleBar = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.subtitleBar:SetPoint("TOPLEFT", frame.titleBar, "BOTTOMLEFT", 0, -5)
    frame.subtitleBar:SetPoint("TOPRIGHT", frame.titleBar, "BOTTOMRIGHT", 0, -5)
    frame.subtitleBar:SetText(private.getLocalisation("ImportDialogFreeOfCharge"))
    frame.subtitleBar:SetHeight(variables.titleBar.height)
    frame.subtitleBar:SetWordWrap(true)
    frame.subtitleBar:SetTextColor(1, 0.64, 0) -- orange

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    local contentFrameName = Type .. "ContentFrame" .. count
    local contentFrame = CreateFrame("Frame", contentFrameName, frame)

    contentFrame:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        variables.contentFrame.padding.x,
        -(variables.contentFrame.padding.y * 2 + frame.titleBar:GetHeight() + frame.subtitleBar:GetHeight())
    )
    contentFrame:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT",
        -variables.contentFrame.padding.x,
        variables.contentFrame.padding.y
    )

    ---@class AtImportDialog : AceGUIWidget
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
