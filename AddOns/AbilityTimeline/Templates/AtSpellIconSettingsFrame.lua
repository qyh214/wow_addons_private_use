local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")
local Type = "AtSpellIconSettingsFrame"
local Version = 1
local variables = {
    width = 800,
    height = 500,
    ContentFramePadding = { x = 15, y = 15 },
    Padding = { x = 2, y = 2 },
    Footer = {
        height = 30,
    }
}

---@param self AtSpellIconSettingsFrame
local function OnAcquire(self)
end

---@param self AtSpellIconSettingsFrame
local function OnRelease(self)
    self.frame.Footer.Urls:Release()
end

local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", "AtSpellIconSettingsFrame", UIParent, "PortraitFrameTemplateNoCloseButton")
    frame:SetPortraitTextureRaw("Interface\\AddOns\\AbilityTimeline\\Media\\Textures\\portrait.tga")
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetWidth(variables.width)
    frame:SetHeight(variables.height)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    frame:SetTitle(private.getLocalisation("SpellIconSettings"))

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


    frame.CloseButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.CloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    frame.CloseButton:SetScript("OnClick", function() private.closeSpellIconSettings() end)
    frame:Show()

    local contentFrameName = Type .. "ContentFrame" .. count
    local contentFrame = CreateFrame("Frame", contentFrameName, frame)
    contentFrame:ClearAllPoints()
    contentFrame:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        variables.Padding.x + variables.ContentFramePadding.x,
        -variables.ContentFramePadding.y - frame.TitleContainer:GetHeight()
    )
    contentFrame:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOM",
        0,
        variables.Footer.height
    )
    local rightContentFrameName = Type .. "RightContentFrame" .. count
    local rightContentFrame = CreateFrame("Frame", rightContentFrameName, frame, "BackdropTemplate")
    rightContentFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 32, right = 32, top = 48, bottom = 32 }
    })
    rightContentFrame:ClearAllPoints()
    rightContentFrame:SetPoint(
        "TOPLEFT",
        frame,
        "TOP",
        variables.Padding.x,
        -variables.ContentFramePadding.y - frame.TitleContainer:GetHeight()
    )
    rightContentFrame:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT"
    )

    local IconPreviewTitle = rightContentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    IconPreviewTitle:SetFontHeight(32)
    IconPreviewTitle:SetPoint("CENTER", rightContentFrame, "TOP", 0, -32)
    IconPreviewTitle:SetText(private.getLocalisation("IconPreview"))


    ---@class AtSpellIconSettingsFrame : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
        content = contentFrame,
        rightContent = rightContentFrame,
    }

    return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
