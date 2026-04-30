local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")

local Type = "AtImportPopup"
local Version = 1

local variables = {
    x = 500,
    y = 350,
    titleBar = {
        height = 30,
        padding = {
            x = 0,
            y = -10,
        },
    },
    logo = {
        width = 128,
        height = 128,
    },
    progressBar = {
        width = 400,
        height = 30,
    },
}

---@param self AtImportPopup
local function OnAcquire(self)
    self.frame:SetPoint("CENTER", UIParent, "CENTER")
    self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
    self.frame:Show()
end

---@param self AtImportPopup
local function OnRelease(self)
    if self.timer then
        self.timer:Cancel()
        self.timer = nil
    end
    self.frame:Hide()
end

local function StartImport(self, duration, onComplete, onCancel)
    self.importDuration = duration
    self.importStartTime = GetTime()
    self.onComplete = onComplete
    self.onCancel = onCancel
    self.isCancelled = false

    self.frame.buttonHolder.cancelButton:SetScript("OnClick", function()
        self:CancelImport()
    end)

    if not self.timer then
        self.timer = C_Timer.NewTicker(0.05, function()
            if not self.frame or not self.frame:IsShown() then
                if self.timer then
                    self.timer:Cancel()
                    self.timer = nil
                end
                return
            end

            local elapsed = GetTime() - self.importStartTime
            local progress = math.min(elapsed / self.importDuration, 1.0)
            local remainingTime = math.max(0, self.importDuration - elapsed)

            self.frame.progressBar:SetValue(progress * 100)

            if progress >= 1.0 then
                if self.timer then
                    self.timer:Cancel()
                    self.timer = nil
                end
                if self.onComplete and not self.isCancelled then
                    self.onComplete()
                end
                self:Release()
            end
        end)
    end
end

local function CancelImport(self)
    self.isCancelled = true
    if self.timer then
        self.timer:Cancel()
        self.timer = nil
    end
    if self.onCancel then
        self.onCancel()
    end
    self:Release()
end

local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", Type .. count, UIParent, "BackdropTemplate")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetSize(variables.x, variables.y)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)

    frame:EnableMouse(true)
    frame:SetMovable(false)

    frame.titleBar = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.titleBar:SetPoint("TOP", frame, "TOP", 0, -20)
    frame.titleBar:SetText(private.getLocalisation("ImportPopupTitle"))

    frame.logo = frame:CreateTexture(nil, "ARTWORK")
    frame.logo:SetSize(variables.logo.width, variables.logo.height)
    frame.logo:SetPoint("TOP", frame.titleBar, "BOTTOM", 0, -10)
    frame.logo:SetTexture("Interface\\AddOns\\AbilityTimeline\\Media\\Textures\\logo_transparent.tga")

    frame.messageText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.messageText:SetPoint("TOP", frame.logo, "BOTTOM", 0, -10)
    frame.messageText:SetWidth(variables.x - 40)
    frame.messageText:SetWordWrap(true)
    frame.messageText:SetJustifyH("CENTER")
    frame.messageText:SetText(private.getLocalisation("ImportDialogFreeOfCharge"))
    frame.messageText:SetTextColor(1, 0.82, 0)

    frame.buttonHolder = CreateFrame("Frame", nil, frame)
    frame.buttonHolder:SetHeight(60)
    frame.buttonHolder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    frame.buttonHolder:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)

    frame.buttonHolder.supportButton = CreateFrame("Button", nil, frame.buttonHolder, "UIPanelButtonTemplate")
    frame.buttonHolder.supportButton:SetSize(120, 30)
    frame.buttonHolder.supportButton:SetPoint("CENTER", frame.buttonHolder, "CENTER", -65, 0)
    frame.buttonHolder.supportButton:SetText(private.getLocalisation("SupportButton"))

    frame.buttonHolder.supportButton:SetScript("OnClick", function()
        if not private.TextCopyFrame then
            private.TextCopyFrame = AceGUI:Create('AtTextCopyFrame')
        end
        private.TextCopyFrame.frame.CloseButton:SetScript("OnClick",
            function() if private.TextCopyFrame then
                    private.TextCopyFrame:Release()
                    private.TextCopyFrame = nil
                end end)
        private.TextCopyFrame.frame:SetPoint("TOP", UIParent, "TOP", 0, -50)
        private.TextCopyFrame.frame:Show()
        private.TextCopyFrame:SetValues('https://www.patreon.com/c/Jodsderechte')
    end)

    frame.buttonHolder.cancelButton = CreateFrame("Button", nil, frame.buttonHolder, "UIPanelButtonTemplate")
    frame.buttonHolder.cancelButton:SetSize(120, 30)
    frame.buttonHolder.cancelButton:SetPoint("CENTER", frame.buttonHolder, "CENTER", 65, 0)
    frame.buttonHolder.cancelButton:SetText(private.getLocalisation("ReminderCancelButton"))

    frame.progressBarBg = frame:CreateTexture(nil, "BACKGROUND")
    frame.progressBarBg:SetSize(variables.progressBar.width, variables.progressBar.height)
    frame.progressBarBg:SetPoint("BOTTOM", frame.buttonHolder, "TOP", 0, 10)
    frame.progressBarBg:SetColorTexture(0.2, 0.2, 0.2, 1)

    frame.progressBar = CreateFrame("StatusBar", nil, frame)
    frame.progressBar:SetSize(variables.progressBar.width, variables.progressBar.height)
    frame.progressBar:SetPoint("CENTER", frame.progressBarBg, "CENTER", 0, 0)
    frame.progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    frame.progressBar:GetStatusBarTexture():SetHorizTile(false)
    frame.progressBar:GetStatusBarTexture():SetVertTile(false)
    frame.progressBar:SetMinMaxValues(0, 100)
    frame.progressBar:SetValue(0)
    frame.progressBar:SetStatusBarColor(0, 0.7, 1, 1)

    frame.progressBarBorder = frame:CreateTexture(nil, "BORDER")
    frame.progressBarBorder:SetSize(variables.progressBar.width + 4, variables.progressBar.height + 4)
    frame.progressBarBorder:SetPoint("CENTER", frame.progressBar, "CENTER")
    frame.progressBarBorder:SetColorTexture(0.8, 0.8, 0.8, 1)
    frame.progressBarBorder:SetDrawLayer("OVERLAY", 1)

    frame.progressText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.progressText:SetPoint("BOTTOM", frame.progressBar, "TOP", 0, 5)
    frame.progressText:SetText("0%")

    frame.progressBar:SetScript("OnValueChanged", function(self, value)
        frame.progressText:SetText(string.format("%d%%", math.floor(value)))
    end)

    ---@class AtImportPopup : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        StartImport = StartImport,
        CancelImport = CancelImport,
        type = Type,
        count = count,
        frame = frame,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
