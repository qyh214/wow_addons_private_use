-- BannerPlugin.lua
-- @Date   : 07/01/2024, 10:01:07 AM
--
BuildEnv(...)

BannerPlugin = Addon:NewModule('BannerPlugin', 'AceEvent-3.0', 'AceComm-3.0')

function BannerPlugin:OnEnable()
    self:Init()
    if self.db.global.BannerShData then
        self:MEETINGHORN_SH(_, self.db.global.BannerShData)
    end
end

function BannerPlugin:Init()
    self.db = Profile.gdb

    self:RegisterMessage('MEETINGSTONE_OPEN')
    self:RegisterMessage('MEETINGSTONE_CLOSE')
    self:RegisterMessage('MEETINGHORN_SH')
    self:RegisterMessage('MEETINGHORN_STB')

    self.infoPages = {
        {id = 3, texture = "Interface\\AddOns\\MeetingStone\\Media\\BannerPlugin\\StbTextureBg3"},
        {id = 4, texture = "Interface\\AddOns\\MeetingStone\\Media\\BannerPlugin\\StbTextureBg4"},
    }

    self.currentPage = 1
    self.timer = nil  -- 初始化定时器成员变量

    self.frame = CreateFrame("Frame", "BannerFrame", UIParent, "BackdropTemplate")
    self.frame:SetSize(256, MainPanel:GetHeight())
    self.frame:SetPoint("LEFT", MainPanel, "RIGHT", 0, 0)
    self.frame:EnableMouse(true)
    self.frame:SetMovable(true)
    self.frame:SetClampedToScreen(true)
    self.frame:SetScript("OnMouseDown", function()
        self:PrintCurrentID()
    end)

    -- 创建关闭按钮
    self.CloseButton = CreateFrame("Button", nil, self.frame, "UIPanelCloseButton")
    self.CloseButton:SetSize(32, 32)  -- 设置按钮大小
    self.CloseButton:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -5, -5)  -- 设置按钮位置

    -- 设置点击事件
    self.CloseButton:SetScript("OnClick", function()
        self.db.global.BannerTime = time()
        self.frame:Hide()  -- 隐藏 self.frame
       LogStatistics:InsertLog({ time(), 10, 1 })
    end)

    -- 创建背景纹理
    self.BannerBackground = self.frame:CreateTexture(nil, "BACKGROUND")
    self.BannerBackground:SetAllPoints(self.frame)

    self:CreateButtons()
    self.frame:Hide()
end

function BannerPlugin:CreateButtons()
    self.PreviousButton = CreateFrame("Button", nil, self.frame)
    self.PreviousButton:SetSize(48, 48)
    self.PreviousButton:SetPoint("LEFT", 10, 0)
    self.PreviousButton:SetNormalTexture('Interface\\AddOns\\MeetingStone\\Media\\banner_btn_left')
    self.PreviousButton:SetHighlightTexture("Interface\\AddOns\\MeetingStone\\Media\\banner_btn_left", "ADD")
    local  PreviousNormalTexture = self.PreviousButton:GetNormalTexture()
    PreviousNormalTexture:SetTexCoord(0, 1, 0, 1)
    local PreviousHighlightTexture = self.PreviousButton:GetHighlightTexture()
    PreviousHighlightTexture:SetTexCoord(0, 1, 0, 1)
    self.PreviousButton:SetScript("OnClick", function()
        self:OnPreviousClick()
    end)

    self.NextButton = CreateFrame("Button", nil, self.frame)
    self.NextButton:SetSize(48, 48)
    self.NextButton:SetPoint("RIGHT", -10, 0)
    self.NextButton:SetNormalTexture('Interface\\AddOns\\MeetingStone\\Media\\banner_btn_right')
    self.NextButton:SetHighlightTexture("Interface\\AddOns\\MeetingStone\\Media\\banner_btn_right", "ADD")
    local nextNormalTexture = self.NextButton:GetNormalTexture()
    nextNormalTexture:SetTexCoord(0, 1, 0, 1)
    local nextHighlightTexture = self.NextButton:GetHighlightTexture()
    nextHighlightTexture:SetTexCoord(0, 1, 0, 1)

    self.NextButton:SetScript("OnClick", function()
        self:OnNextClick()
    end)

end

function BannerPlugin:UpdateBanner()
    if not self.db.global.BannerData or #self.db.global.BannerData == 0 then
        return
    end
    if #self.db.global.BannerData == 1 then
        self.PreviousButton:Hide()
        self.NextButton:Hide()
    else
        self.PreviousButton:Show()
        self.NextButton:Show()
    end
    self.BannerBackground:SetTexture(self.db.global.BannerData[self.currentPage].texture)
    self.BannerBackground:SetTexCoord(0, 1, 0, 424 / 512)
end

function BannerPlugin:OnPreviousClick()
    self.currentPage = self.currentPage - 1
    if self.currentPage < 1 then
        self.currentPage = #self.db.global.BannerData
    end
    self:UpdateBanner()
end

function BannerPlugin:OnNextClick()
    self.currentPage = self.currentPage + 1
    if self.currentPage > #self.db.global.BannerData then
        self.currentPage = 1
    end
    self:UpdateBanner()
end

function BannerPlugin:PrintCurrentID()
    local stbUrl = self.db.global.BannerData[self.currentPage]['u']
    if stbUrl == '' or stbUrl == nil then
        return
    end

    GUI:CallUrlDialog(stbUrl)
   LogStatistics:InsertLog({time(), 5, stbUrl})
end

function BannerPlugin:AutoRotateBanner()
    self:OnNextClick()
    self.timer = C_Timer.NewTimer(15, function() self:AutoRotateBanner() end)
end

function BannerPlugin:MEETINGHORN_SH(_, data)
    if not data then
        return
    end
    self.db.global.BannerShData = data
end

function BannerPlugin:MEETINGHORN_STB(_, data, BannerIntervalTime)
    self.db.global.BannerData = {}
    self.db.global.BannerIntervalTime = BannerIntervalTime
    for _, val in pairs(data) do
        for _, page in pairs(self.infoPages) do
            if val.id == page.id then
                page['u'] = val['u']
                page['a'] = val['a']
                table.insert(self.db.global.BannerData, page)
            end
        end
    end
    if not self.db.global.BannerData or #self.db.global.BannerData == 0 then
        self.frame:Hide()
        return
    end
    self:MEETINGSTONE_OPEN()
end

function BannerPlugin:MEETINGSTONE_OPEN()
    if not self.db.global.BannerData or #self.db.global.BannerData == 0
    or  not MainPanel:IsVisible() then
        return
    end
    if self.db.global.BannerIntervalTime and self.db.global.BannerTime
    and  (self.db.global.BannerTime + self.db.global.BannerIntervalTime) > time() then
        return
    end
    self.frame:Show()
    if not self.timer then
        self:AutoRotateBanner()
    end
end

function BannerPlugin:MEETINGSTONE_CLOSE()
    self.frame:Hide()
    if self.timer then
        self.timer:Cancel()
        self.timer = nil
    end
end
