local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")

local Type = "ATTimingsEditorContainer"
local Version = 1
local variables = {
    BackdropBorderColor = { 0.25, 0.25, 0.25, 0.9 },
    BackdropColor = { 0, 0, 0, 0.9 },
    FrameHeight = 600,
    FrameWidth = 800,
    BarHeight = 10,
    Backdrop = {
        bgFile = nil,
        edgeFile = nil,
        tile = true,
        tileSize = 16,
        edgeSize = 1,
    },
    ContentFramePadding = { x = 15, y = 15 },
    Padding = { x = 2, y = 2 },
}

---@param self ATTimingsEditorContainer
local function OnAcquire(self)
    self.frame:Show()
    self.frame:SetPoint("CENTER", UIParent, "CENTER")
end

---@param self ATTimingsEditorContainer
local function OnRelease(self)
    self.frame:Hide()
end


local function SetTitle(self, title)
    self.frame:SetTitle(title)
end

local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)

    local frame = CreateFrame("Frame", Type .. count, UIParent, "PortraitFrameTemplateNoCloseButton")
    frame:SetPortraitTextureRaw("Interface\\AddOns\\AbilityTimeline\\Media\\Textures\\portrait.tga")
    frame:SetSize(variables.FrameWidth, variables.FrameHeight)
    private.Debug(frame, "AT_TIMINGS_EDITOR_FRAME_BASE")
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
    closeButton:SetScript("OnClick", function()
        private.closeTimingsEditor()
    end)

    local contentFrameName = Type .. "ContentFrame" .. count
    local contentFrame = CreateFrame("Frame", contentFrameName, frame)

    contentFrame:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        variables.Padding.x,
        -variables.ContentFramePadding.y - frame.TitleContainer:GetHeight()
    )
    contentFrame:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT", 0, 30
    )

    frame.Footer = CreateFrame("Frame", nil, frame)
    frame.Footer:SetHeight(30)
    frame.Footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
    frame.Footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    frame.Footer.Background = frame.Footer:CreateTexture(nil, "BACKGROUND")
    frame.Footer.Background:SetAllPoints(frame.Footer)
    frame.Footer.Background:SetColorTexture(0, 0, 0, 0.5)
    frame.Footer.AddonName = frame.Footer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.Footer.AddonName:SetPoint("LEFT", frame.Footer, "LEFT", 10, 0)
    frame.Footer.AddonName:SetFormattedText("Better Timeline %s", C_AddOns.GetAddOnMetadata(appName, "Version"))
    frame.Footer.Urls = AceGUI:Create("SimpleGroup")
    frame.Footer:SetScript("OnHide", function(self, button) --TODO FIX THIS WORKAROUND
        frame.Footer.Urls.frame:Hide()
    end)
    frame.Footer:SetScript("OnShow", function(self, button)
        frame.Footer.Urls.frame:Show()
    end)
    frame.Footer.Urls:SetLayout("Flow")
    frame.Footer.Urls:SetPoint("BOTTOMRIGHT", frame.Footer, "BOTTOMRIGHT", -10, 3)
    frame.Footer.Urls:SetPoint("TOPRIGHT", frame.Footer, "TOPRIGHT", -10, 3)
    frame.Footer.Urls:SetWidth(70)

    frame.Footer.PatreonLink = AceGUI:Create("Icon")
    frame.Footer.PatreonLink:SetImageSize(16, 16)
    frame.Footer.PatreonLink:SetWidth(30)
    frame.Footer.PatreonLink:SetHeight(16)
    frame.Footer.PatreonLink:SetImage("Interface\\AddOns\\AbilityTimeline\\Media\\Textures\\Brands\\Patreon_logo.tga")
    frame.Footer.PatreonLink:SetCallback("OnClick", function()
        if not private.TextCopyFrame then
            private.TextCopyFrame = AceGUI:Create('AtTextCopyFrame')
        end
        private.TextCopyFrame.frame.CloseButton:SetScript("OnClick",
            function() if private.TextCopyFrame and not private.TextCopyFrame:IsReleasing() then
                    private.TextCopyFrame:Release()
                    private.TextCopyFrame = nil
                end end)
        private.TextCopyFrame.frame:SetPoint("TOP", UIParent, "TOP", 0, -50)
        private.TextCopyFrame.frame:Show()
        private.TextCopyFrame:SetValues('https://www.patreon.com/c/Jodsderechte')
    end)
    private.AddFrameTooltip(frame.Footer.PatreonLink.frame, "PatreonDescription")
    frame.Footer.Urls:AddChild(frame.Footer.PatreonLink)

    frame.Footer.DiscordLink = AceGUI:Create("Icon")
    frame.Footer.DiscordLink:SetImageSize(21, 16)
    frame.Footer.DiscordLink:SetWidth(30)
    frame.Footer.DiscordLink:SetHeight(16)
    frame.Footer.DiscordLink:SetImage("Interface\\AddOns\\AbilityTimeline\\Media\\Textures\\Brands\\Discord_logo.tga")
    frame.Footer.DiscordLink:SetCallback("OnClick", function()
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
        private.TextCopyFrame:SetValues('https://discord.com/invite/v3gYmYamGJ')
    end)

    private.AddFrameTooltip(frame.Footer.DiscordLink.frame, "DiscordDescription")
    frame.Footer.Urls:AddChild(frame.Footer.DiscordLink)

    ---@class ATTimingsEditorContainer : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        SetTitle = SetTitle,
        content = contentFrame,
        frame = frame,
        type = Type,
        count = count,
    }

    return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
