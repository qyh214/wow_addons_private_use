MEETINGSTONE_UI_E_POINTS = {}
BuildEnv(...)
local CreateColor = CreateColor

--- ColorMixin is a mixin that provides functionality for working with colors.
---@class ColorMixin : table
ColorMixin = {}

---@class colorRGB : table, ColorMixin
---@field r number
---@field g number
---@field b number

---Sets the RGBA values of the color.
---@param r number The red component of the color (0-1).
---@param g number The green component of the color (0-1).
---@param b number The blue component of the color (0-1).
---@param a? number The alpha component of the color (0-1).
function ColorMixin:SetRGBA(r, g, b, a) end

---Sets the RGB values of the color.
---@param r number The red component of the color (0-1).
---@param g number The green component of the color (0-1).
---@param b number The blue component of the color (0-1).
function ColorMixin:SetRGB(r, g, b) end

---Returns the RGB values of the color.
---@return number r
---@return number g
---@return number b
function ColorMixin:GetRGB() return 0, 0, 0 end

---Returns the RGB values of the color as bytes (0-255).
---@return number red
---@return number green
---@return number blue
function ColorMixin:GetRGBAsBytes() return 0, 0, 0 end

---Returns the RGBA values of the color.
---@return number red
---@return number green
---@return number blue
---@return number alpha
function ColorMixin:GetRGBA() return 0, 0, 0, 0 end

---Returns the RGBA values of the color as bytes (0-255).
---@return number red
---@return number green
---@return number blue
---@return number alpha
function ColorMixin:GetRGBAAsBytes() return 0, 0, 0, 0 end

---Checks if the RGB values of this color are equal to another color.
---@param otherColor table The other color to compare with.
---@return boolean bIsEqual if the RGB values are equal, false otherwise.
function ColorMixin:IsRGBEqualTo(otherColor) return true end

---Checks if this color is equal to another color.
---@param otherColor table The other color to compare with.
---@return boolean True if the RGB and alpha values are equal, false otherwise.
function ColorMixin:IsEqualTo(otherColor) return true end

---Generates a hexadecimal color string with alpha.
---@return string hexadecimal color string with alpha.
function ColorMixin:GenerateHexColor() return "" end

---Generates a hexadecimal color string without alpha.
---@return string hexadecimal color string without alpha.
function ColorMixin:GenerateHexColorNoAlpha() return "" end

---Generates a hexadecimal color markup string.
---@return string hexadecimal color markup string.
function ColorMixin:GenerateHexColorMarkup() return "" end
-- Function to convert RGB values to hexadecimal string
function ColorMixin:RGBToHex(r, g, b)
    -- Convert normalized RGB values to 0-255 range
    local red = math.floor(r * 255 + 5)
    local green = math.floor(g * 255 + 5)
    local blue = math.floor(b * 255 + 5)

    -- Ensure values are within range
    red = math.max(0, math.min(255, red))
    green = math.max(0, math.min(255, green))
    blue = math.max(0, math.min(255, blue))

    -- Convert to hexadecimal format
    return string.format("%02X%02X%02X", red, green, blue)
end

---Wraps the given text in a color code using this color.
---@param text string The text to wrap.
---@return string The wrapped text with the color code.
function ColorMixin:WrapTextInColorCode(text)
    local color = CreateColor(self.r,self.g,self.b, 1)
    local hex = color:GenerateHexColor()
    return "|c" .. hex .. text .. "|r"
end

local medalTextures = {
    [80] = [[|TInterface\AddOns\MeetingStone\Media\StbTexture\StbTextureBgBig80:16:52:0:0:256:64:0:146:0:46|t]],
    [100] = [[|TInterface\AddOns\MeetingStone\Media\StbTexture\StbTextureBgBig100:16:46:0:0:128:64:0:128:0:46|t]],
}

MainPanel = Addon:NewModule(GUI:GetClass('Panel'):New(UIParent), 'MainPanel', 'AceEvent-3.0', 'AceBucket-3.0')

function MainPanel:OnInitialize()
    GUI:Embed(self, 'Refresh', 'Help', 'Blocker')

    self:SetSize(1000, 447)
    self:SetText(L['集合石'] .. ' Beta ' .. ADDON_VERSION)
    self:EnableUIPanel(true)
    self:SetTabStyle('BOTTOM')
    self:SetTopHeight(80)
    self:RegisterForDrag('LeftButton')
    self:SetMovable(true)
    self:SetScript('OnDragStart', self.StartMoving)
    self:SetScript('OnDragStop', self.StopMovingOrSizing)
    self:SetClampedToScreen(true)
    GUI:RegisterUIPanel(self)

    local icon = self:CreateTexture(nil, 'OVERLAY')  -- 使用比OVERLAY更基础的层
    icon:SetTexture(ADDON_LOGO)
    icon:SetSize(40, 40)
    icon:SetPoint('TOPLEFT', self, 'TOPLEFT', 3, -3)
    icon:SetDrawLayer('OVERLAY', 7)  -- 设置较高的子层级

    self:HookScript('OnShow', function()

        C_LFGList.RequestAvailableActivities()
        self:UpdateBlockers()
        self:SendMessage('MEETINGSTONE_OPEN')
        LogStatistics:SendServerExposure()
    end)

    self:HookScript('OnHide', function()
        self:SendMessage('MEETINGSTONE_CLOSE')
    end)

    self:RegisterMessage('MEETINGSTONE_NEW_VERSION')
    self:RegisterEvent('AJ_PVE_LFG_ACTION')
    self:RegisterEvent('AJ_PVP_LFG_ACTION', 'AJ_PVE_LFG_ACTION')

    PVEFrame:UnregisterEvent('AJ_PVE_LFG_ACTION')
    PVEFrame:UnregisterEvent('AJ_PVP_LFG_ACTION')

    local classIDs = {}
    self.specsByID = {}
    self.specs = {}
    for classID = 1, GetNumClasses() do
        local _, className, tempClassID = GetClassInfo(classID)
        table.insert(classIDs, tempClassID)
    end

    -- 在收集专精数据部分修改为获取中文职业名
    for _, classID in ipairs(classIDs) do
        local className, classFile = GetClassInfo(classID)  -- 获取职业名称和标识符
        local classColor = RAID_CLASS_COLORS[classFile]     -- 获取职业颜色
        for i = 1, GetNumSpecializationsForClassID(classID) do
            local specID, name, description, icon, role = GetSpecializationInfoForClassID(classID, i)
            if specID then
                local specData = {
                    id = specID,
                    name = name,
                    icon = icon,
                    role = role,
                    className = className,
                    classColor = classColor
                }
                table.insert(self.specs, specData)
                self.specsByID[specID] = specData
            end
        end
    end

    local AnnBlocker = self:NewBlocker('AnnBlocker', 1)
    do
        self.AnnBlocker = AnnBlocker
        AnnBlocker:SetCallback('OnCheck', function()
            return DataCache:GetObject('AnnList'):IsNew()
        end)
        AnnBlocker:SetCallback('OnInit', function(AnnBlocker)
            local width, height = AnnBlocker:GetSize()
            local topWidth, topHeight = width / 3, width / 3;
            local botWidth, botHeight = topWidth, height - topHeight;

            local BTLT = AnnBlocker:CreateTexture(nil, 'BORDER', nil, 1)
            do
                BTLT:SetSize(topWidth, topHeight)
                BTLT:SetPoint('TOPLEFT')
                BTLT:SetTexture([[Interface\GLUES\CREDITS\gatetga1]])
                BTLT:SetAlpha(0.4)
            end

            local BTT = AnnBlocker:CreateTexture(nil, 'BORDER', nil, 1)
            do
                BTT:SetSize(topWidth, topHeight)
                BTT:SetPoint('LEFT', BTLT, 'RIGHT')
                BTT:SetTexture([[Interface\GLUES\CREDITS\gatetga2]])
                BTT:SetAlpha(0.4)
            end

            local BTRT = AnnBlocker:CreateTexture(nil, 'BORDER', nil, 1)
            do
                BTRT:SetSize(topWidth, topHeight)
                BTRT:SetPoint('LEFT', BTT, 'RIGHT')
                BTRT:SetTexture([[Interface\GLUES\CREDITS\gatetga3]])
                BTRT:SetAlpha(0.4)
            end

            local BBLT = AnnBlocker:CreateTexture(nil, 'BORDER', nil, 1)
            do
                BBLT:SetSize(botWidth, botHeight)
                BBLT:SetPoint('TOP', BTLT, 'BOTTOM')
                BBLT:SetTexture([[Interface\GLUES\CREDITS\gatetga5]])
                BBLT:SetTexCoord(0, 1, 0, botHeight / topHeight)
                BBLT:SetAlpha(0.4)
            end

            local BBT = AnnBlocker:CreateTexture(nil, 'BORDER', nil, 1)
            do
                BBT:SetSize(botWidth, botHeight)
                BBT:SetPoint('LEFT', BBLT, 'RIGHT')
                BBT:SetTexture([[Interface\GLUES\CREDITS\gatetga6]])
                BBT:SetTexCoord(0, 1, 0, botHeight / topHeight)
                BBT:SetAlpha(0.4)
            end

            local BBRT = AnnBlocker:CreateTexture(nil, 'BORDER', nil, 1)
            do
                BBRT:SetSize(botWidth, botHeight)
                BBRT:SetPoint('LEFT', BBT, 'RIGHT')
                BBRT:SetTexture([[Interface\GLUES\CREDITS\gatetga7]])
                BBRT:SetTexCoord(0, 1, 0, botHeight / topHeight)
                BBRT:SetAlpha(0.4)
            end

            local NoticeFrame = CreateFrame('Frame', nil, AnnBlocker, 'MeetingStoneNoticeTemplate')
            NoticeFrame.btnKnow:SetScript('OnClick', function()
                DataCache:GetObject('AnnList'):SetIsNew(false)
                AnnBlocker:Hide()
            end)
            AnnBlocker.NoticeContainer = NoticeFrame.NoticeContainer

            self:RegisterMessage('MEETINGSTONE_ANNOUNCEMENT_UPDATED', function(_, isNew)
                if isNew then
                    AnnBlocker:Fire('OnFormat')
                end
            end)
        end)

        AnnBlocker:SetCallback('OnFormat', function(AnnBlocker)
            local annData = DataCache:GetObject('AnnList'):GetData() or {}
            local NoticeContainer = AnnBlocker.NoticeContainer

            local width = NoticeContainer.notices[1]:GetWidth()
            NoticeContainer:SetWidth((width + 10) * #annData - 10)

            for i, notice in ipairs(NoticeContainer.notices) do
                local v = annData[i]
                if v then
                    notice.Text:SetText(v.t or '')
                    notice.Text:SetTextColor(0.4, 0.7, 0)
                    notice.LookDetail:SetShown(v.u)
                    ApplyUrlButton(notice.LookDetail, v.u)
                else
                    notice:Hide()
                end
            end
        end)
    end

    local HelpBlocker = self:NewBlocker('HelpBlocker', 2)
    do
        HelpBlocker:SetCallback('OnCheck', function()
            return Profile:IsNewVersion() or (self.newVersion and not self.newVersionReaded)
        end)
        HelpBlocker:SetCallback('OnFormat', function(HelpBlocker)
            if self.newVersion then
                HelpBlocker.NewVersion:SetFormattedText('%s|cff00ffff%s|r', L['最新版本：'], self.newVersion)
                HelpBlocker.NewVersion:Show()
                HelpBlocker.NewVersionFlash:Show()
            else
                HelpBlocker.NewVersion:Hide()
                HelpBlocker.NewVersionFlash:Hide()
            end
        end)
        HelpBlocker:SetCallback('OnInit', function(HelpBlocker)
            local Icon = HelpBlocker:CreateTexture(nil, 'ARTWORK')
            do
                Icon:SetPoint('TOPLEFT', 50, -50)
                Icon:SetSize(64, 64)
                Icon:SetTexture([[Interface\AddOns\MeetingStone\Media\Mark\0]])
            end

            local Label = HelpBlocker:CreateFontString(nil, 'ARTWORK')
            do
                Label:SetFont(STANDARD_TEXT_FONT, 32, 'OUTLINE')
                Label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
                Label:SetPoint('LEFT', Icon, 'RIGHT', 0, 0)
                Label:SetText(L['集合石'])
            end

            local Content = HelpBlocker:CreateFontString(nil, 'ARTWORK', 'GameFontDisableLarge')
            do
                Content:SetPoint('TOPLEFT', Icon, 'BOTTOMLEFT', 10, -20)
                Content:SetJustifyH('LEFT')
                Content:SetJustifyV('TOP')
                Content:SetText(L['当前版本：'] .. ADDON_VERSION)
            end

            local NewVersion = HelpBlocker:CreateFontString(nil, 'ARTWORK', 'GameFontDisableLarge')
            do
                NewVersion:SetPoint('TOPLEFT', Content, 'BOTTOMLEFT', 0, -10)
                NewVersion:SetJustifyH('LEFT')
                NewVersion:SetJustifyV('TOP')
                NewVersion:SetText('N/A')
                NewVersion:Hide()
            end

            local NewVersionFlash = GUI:GetClass('AlphaFlash'):New(HelpBlocker)
            do
                NewVersionFlash:Hide()
                NewVersionFlash:SetPoint('BOTTOM', NewVersion, 'BOTTOM', 0, -5)
                NewVersionFlash:SetPoint('LEFT', NewVersion)
                NewVersionFlash:SetPoint('RIGHT', NewVersion)
                NewVersionFlash:SetHeight(20)
                NewVersionFlash:SetTexture([[INTERFACE\CHATFRAME\ChatFrameTab-NewMessage]])
                NewVersionFlash:SetVertexColor(1.00, 0.89, 0.18, 0.5)
                NewVersionFlash:SetBlendMode('ADD')
            end

            local SummaryHtml = GUI:GetClass('ScrollSummaryHtml'):New(HelpBlocker)
            do
                SummaryHtml:SetPoint('TOPLEFT', 360, -15)
                SummaryHtml:SetPoint('BOTTOMRIGHT', -20, 20)
                SummaryHtml:SetSpacing('h2', 20)
                SummaryHtml:SetSpacing('h1', 10)
                SummaryHtml:SetText(ADDON_SUMMARY)
            end

            local EnterButton = CreateFrame('Button', nil, HelpBlocker, 'UIPanelButtonTemplate')
            do
                EnterButton:SetPoint('BOTTOMLEFT', 50, 30)
                EnterButton:SetSize(120, 26)
                EnterButton:SetText(L['开始体验'])
                EnterButton:SetScript('OnClick', function()
                    self.newVersionReaded = true
                    Profile:SaveVersion()
                    HelpBlocker:Hide()
                end)
            end

            local ChangeLogButton = CreateFrame('Button', nil, HelpBlocker, 'UIPanelButtonTemplate')
            do
                ChangeLogButton:SetPoint('BOTTOMLEFT', EnterButton, 'TOPLEFT', 0, 10)
                ChangeLogButton:SetSize(120, 26)
                ChangeLogButton:SetText(L['更新日志'])
                ChangeLogButton:SetScript('OnClick', function()
                    SummaryHtml:SetText(ADDON_CHANGELOG)
                end)
            end

            local SummaryButton = CreateFrame('Button', nil, HelpBlocker, 'UIPanelButtonTemplate')
            do
                SummaryButton:SetPoint('BOTTOMLEFT', ChangeLogButton, 'TOPLEFT', 0, 10)
                SummaryButton:SetSize(120, 26)
                SummaryButton:SetText(L['插件简介'])
                SummaryButton:SetScript('OnClick', function()
                    SummaryHtml:SetText(ADDON_SUMMARY)
                end)
            end

            HelpBlocker.NewVersion = NewVersion
            HelpBlocker.NewVersionFlash = NewVersionFlash
        end)
    end

    if ADDON_REGIONSUPPORT then
        --self:CreateTitleButton{
        --    title = L['意见建议'],
        --    texture = [[Interface\AddOns\MeetingStone\Media\RaidbuilderIcons]],
        --    coords = {0, 32 / 256, 0, 0.5},
        --    callback = function()
        --        GUI:CallFeedbackDialog(ADDON_NAME, function(result, text)
        --            Logic:SendServer('SFEEDBACK', ADDON_NAME, ADDON_VERSION, text)
        --        end)
        --    end,
        --}

        self:CreateTitleButton{
            title = L['公告'],
            texture = [[Interface\AddOns\MeetingStone\Media\RaidbuilderIcons]],
            coords = {96 / 256, 128 / 256, 0, 0.5},
            callback = function()
                self:ToggleBlocker('AnnBlocker')
                LogStatistics:InsertLog({time(), 2})
            end,
        }
    end

    self:CreateTitleButton{
        title = L['插件简介'],
        texture = [[Interface\AddOns\MeetingStone\Media\RaidbuilderIcons]],
        coords = {224 / 256, 1, 0.5, 1},
        callback = function()
            self:ToggleBlocker('HelpBlocker')
            LogStatistics:InsertLog({time(), 3})
        end,
    }

    self.GameTooltip = GUI:GetClass('Tooltip'):New(self)

  if Profile.cdb.profile.settings.uiscale and Profile.cdb.profile.settings.uiscale ~= nil then
    self:SetScale(Profile.cdb.profile.settings.uiscale)
  end
end

function MainPanel:OnEnable()
    C_LFGList.RequestAvailableActivities()
end

function MainPanel:AJ_PVE_LFG_ACTION()
    Addon:ShowModule('MainPanel')
    MainPanel:SelectPanel(BrowsePanel)
end

function MainPanel:MEETINGSTONE_NEW_VERSION(_, version)
    self.newVersion = version
    self.newVersionReaded = nil
    self:UpdateBlockers()
end

function MainPanel:OpenActivityTooltip(activity, tooltip)
    -- local tooltip = self.tooltip
    if not tooltip then
        tooltip = self.GameTooltip
        tooltip:SetOwner(self, 'ANCHOR_NONE')
        tooltip:SetPoint('TOPLEFT', self, 'TOPRIGHT', 1, -10)
    end
    -- tooltip:SetOwner(self, 'ANCHOR_NONE')
    -- tooltip:SetPoint('TOPLEFT', self, 'TOPRIGHT', 1, -10)
    tooltip:AddHeader(activity:GetName(), 1, 1, 1)
    tooltip:AddLine(activity:GetSummary(), GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, true)

    if activity:GetComment() then
        tooltip:AddLine(activity:GetComment(), GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
    end

    tooltip:AddSepatator()

    if activity:GetLeader() then
        tooltip:AddLine(format(LFG_LIST_TOOLTIP_LEADER, activity:GetLeaderText()))

        if activity:GetLeaderItemLevel() then
            tooltip:AddLine(format(L['队长物品等级：|cffffffff%s|r'], activity:GetLeaderItemLevel()))
        end
        if activity:GetLeaderHonorLevel() then
            tooltip:AddLine(format(L['队长荣誉等级：|cffffffff%s|r'], activity:GetLeaderHonorLevel()))
        end

        local pvpRating = activity:GetLeaderPvpRating() or 0
        if pvpRating > 0 then
            tooltip:AddLine(format(L['队长PvP 等级：|cffffffff%s|r'], pvpRating))
        end

        local medalList = Logic:GetMedalList(activity:GetLeader())
        local medalText = ""
        if medalList then
            for _, medal in ipairs(medalList) do
                local texture = medalTextures[medal]
                if texture then
                  medalText = medalText.. texture
                end
            end
        end
        if medalList ~= nil then
          tooltip:AddLine(medalText)
        end


        local score = activity:GetLeaderScore() or 0
        if activity:IsMythicPlusActivity() or score > 0 then
            local color = C_ChallengeMode.GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR
            tooltip:AddLine(format(L['队长大秘评分：%s'], color:WrapTextInColorCode(score)))
            local info = activity:GetLeaderScoreInfo()
            if info and info.mapScore and info.mapScore > 0 then
                local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(info.mapScore) or HIGHLIGHT_FONT_COLOR
                local levelText = format(info.finishedSuccess and "|cff00ff00%d层|r" or "|cff7f7f7f%d层|r",
                    info.bestRunLevel or 0)
                tooltip:AddLine(format("队长当前副本: %s / %s", color:WrapTextInColorCode(info.mapScore), levelText))
            else
                tooltip:AddLine(format("队长当前副本: |cff7f7f7f 无信息|r"))
            end
        end
        tooltip:AddSepatator()
    end

    -- if activity:GetCrossFactionListing() then
    -- tooltip:AddLine(L["|cff00ff00跨阵营队伍|r"])
    -- end
    if activity:GetItemLevel() > 0 then
        tooltip:AddLine(format(LFG_LIST_TOOLTIP_ILVL, activity:GetItemLevel()))
    end
    if activity:IsUseHonorLevel() and activity:GetHonorLevel() > 0 then
        tooltip:AddLine(format(LFG_LIST_TOOLTIP_HONOR_LEVEL, activity:GetHonorLevel()))
    end
    if activity:GetVoiceChat() then
        tooltip:AddLine(format(L['语音聊天：|cffffffff%s|r'], activity:GetVoiceChat()), nil, nil, nil, true)
    end
    if activity:GetAge() > 0 then
        tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_AGE, SecondsToTime(activity:GetAge(), false, false, 1, false)))
    end
    --2022-11-17
    if activity:GetDisplayType() == Enum.LFGListDisplayType.ClassEnumerate then
        tooltip:AddSepatator()
        tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_MEMBERS_SIMPLE, activity:GetNumMembers()))
        for i = 1, activity:GetNumMembers() do
            local role, class, classLocalized, specLocalized = LfgService:GetSearchResultMemberInfo(activity:GetID(), i)
            local classColor                                 = RAID_CLASS_COLORS[class] or NORMAL_FONT_COLOR
            tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_CLASS_ROLE, classLocalized, specLocalized or _G[role]),
                classColor.r,
                classColor.g, classColor.b)
        end
    else
        -- Modification begin
        -- Display Raid/Party Roles,code from PGF addon
        local roles = {}
        local classInfo = {}
        for i = 1, activity:GetNumMembers() do
            local role, class, classLocalized, specLocalized = LfgService:GetSearchResultMemberInfo(activity:GetID(), i)
            if (class) then
                classInfo[class .. specLocalized] = {
                    name = classLocalized,
                    color = RAID_CLASS_COLORS[class] or NORMAL_FONT_COLOR,
                    spec = specLocalized
                }
                if not roles[role] then roles[role] = {} end
                if not roles[role][class .. specLocalized] then roles[role][class .. specLocalized] = 0 end
                roles[role][class .. specLocalized] = roles[role][class .. specLocalized] + 1
            end
        end

        for role, classes in pairs(roles) do
            tooltip:AddLine(_G[role] .. ": ")
            for classAndspec, count in pairs(classes) do
                local text = "   "
                if count > 1 then text = text .. count .. " " else text = text .. "   " end
                text = text ..
                    "|c" ..
                    classInfo[classAndspec].color.colorStr ..
                    classInfo[classAndspec].name .. " - " .. classInfo[classAndspec].spec .. "|r "
                tooltip:AddLine(text)
            end
        end
        -- Modification end
        local memberCounts = C_LFGList.GetSearchResultMemberCounts(activity:GetID())
        if memberCounts then
            tooltip:AddSepatator()
            tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_MEMBERS, activity:GetNumMembers(), memberCounts.TANK,
                memberCounts.HEALER, memberCounts.DAMAGER))
        end
    end

    for i = 1, activity:GetNumMembers() do
        local role, class, classLocalized, specLocalized, isLeader, isLeaver = LfgService:GetSearchResultMemberInfo(activity:GetID(), i)
        if isLeaver then
            tooltip:AddSepatator()
            local classColor = RAID_CLASS_COLORS[class] or NORMAL_FONT_COLOR
            tooltip:AddLine([[|TInterface/AddOns/MeetingStone/Media/LFG-ICON-REDWARNING:16:18:0:0:32:16:0:18:0:16|t]]..format(" %s %s |cffff0000是钥石逃亡者|r",
                classLocalized, specLocalized or _G[role]),
                classColor.r, classColor.g, classColor.b)
        end
    end

    if activity:IsAnyFriend() and activity:GetNumMembers() ~= 0 then
        tooltip:AddSepatator()
        tooltip:AddLine(LFG_LIST_TOOLTIP_FRIENDS_IN_GROUP)
        tooltip:AddLine(LFGListSearchEntryUtil_GetFriendList(activity:GetID()), 1, 1, 1, true)
    end

    local progressions = GetRaidProgressionData(activity:GetActivityID(), activity:GetCustomID())
    local progressionValue = activity:GetLeaderProgression()
    local completedEncounters = C_LFGList.GetSearchResultEncounterInfo(activity:GetID())
    if progressions and progressionValue then
        tooltip:AddSepatator()
        tooltip:AddDoubleLine(L['副本进度/经验：'], activity:GetShortName())
        for i, v in ipairs(progressions) do
            local color = activity:IsBossKilled(v.name) and RED_FONT_COLOR or GREEN_FONT_COLOR
            tooltip:AddDoubleLine(v.name, GetProgressionTex(progressionValue, i), color.r, color.g, color.b)
        end
    elseif completedEncounters and #completedEncounters > 0 then
        tooltip:AddSepatator()
        tooltip:AddLine(LFG_LIST_BOSSES_DEFEATED)
        for i = 1, #completedEncounters do
            tooltip:AddLine(completedEncounters[i], RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
        end
    end

    if activity:IsDelisted() then
        tooltip:AddSepatator()
        tooltip:AddLine(LFG_LIST_ENTRY_DELISTED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
    end

    local version = activity:GetVersion()
    if version then
        tooltip:AddDoubleLine(' ', GetFullVersion(version), 1, 1, 1, 0.5, 0.5, 0.5)
    end

    --[=[@debug@
    if activity:IsMeetingStone() then
        local source = activity:GetSource() or 1
        tooltip:AddLine(
            source == 0 and '单体' or source == 1 and '大脚' or source == 2 and '有爱' or source == 4 and '多玩' or
                source == 8 and 'EUI')
    end

    tooltip:AddLine('ID: ' .. activity:GetID())
    tooltip:AddLine('Loot: ' .. tostring(activity:GetLoot()))
    tooltip:AddLine('Mode: ' .. tostring(activity:GetMode()))
    --@end-debug@]=]

    tooltip:Show()
end

local FACTION_STRINGS = { [0] = '|cff00ff00' .. FACTION_HORDE .. '|r', [1] = '|cff00ff00' .. FACTION_ALLIANCE .. '|r' };

function GetSpecNameBySpecID(specID, playerSex)
	playerSex = playerSex or UnitSex("player");
	if playerSex then
		return select(2, GetSpecializationInfoByID(specID, playerSex));
	end
	return "";
end

function MainPanel:OpenApplicantTooltip(applicant)
    local GameTooltip = self.GameTooltip
    local name = applicant:GetName()
    local class = applicant:GetClass()
    local level = applicant:GetLevel()
    local localizedClass = applicant:GetLocalizedClass()
    local itemLevel = applicant:GetItemLevel()
    local comment = applicant:GetMsg()
    local useHonorLevel = applicant:IsUseHonorLevel()
    local specId = applicant:GetSpecID()

    GameTooltip:SetOwner(self, 'ANCHOR_NONE')
    GameTooltip:SetPoint('TOPLEFT', self, 'TOPRIGHT', 0, 0)

    if name then
        local classTextColor = RAID_CLASS_COLORS[class]
        GameTooltip:AddHeader(name, classTextColor.r, classTextColor.g, classTextColor.b)
        local classSpecializationName = localizedClass
        if specId then
            local specName = GetSpecNameBySpecID(specId)
            if specName then
                classSpecializationName = CLUB_FINDER_LOOKING_FOR_CLASS_SPEC:format(specName, classSpecializationName)
            end
        end
        GameTooltip:AddLine(string.format(UNIT_TYPE_LEVEL_TEMPLATE, level, classSpecializationName), 1, 1, 1)
    else
        GameTooltip:AddHeader(UnitName('none'), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    end
    GameTooltip:AddLine(string.format(LFG_LIST_ITEM_LEVEL_CURRENT, itemLevel), 1, 1, 1)
    if useHonorLevel then
        GameTooltip:AddLine(string.format(LFG_LIST_HONOR_LEVEL_CURRENT_PVP, applicant:GetHonorLevel()), 1, 1, 1)
    end

    if U1AddDonatorTitle then
        U1AddDonatorTitle(GameTooltip, name)
    end

    local score = applicant:GetDungeonScore() or 0
    if applicant:IsMythicPlusActivity() or score > 0 then
        local color = C_ChallengeMode.GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR
        GameTooltip:AddLine(format(L['大秘评分：%s'], color:WrapTextInColorCode(score)))
        local info = applicant:GetBestDungeonScore()
        if info and info.mapScore and info.mapScore > 0 then
            local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(info.mapScore) or HIGHLIGHT_FONT_COLOR
            local levelText = format(info.finishedSuccess and "|cff00ff00%d层|r" or "|cff7f7f7f%d层|r",
                info.bestRunLevel or 0)
            GameTooltip:AddLine(format("当前副本: %s / %s", color:WrapTextInColorCode(info.mapScore), levelText))
        else
            GameTooltip:AddLine(format("当前副本: |cff7f7f7f 无信息|r"))
        end
    end

    if comment and comment ~= '' then
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(comment, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, true)
    end

    -- Add statistics
    local stats = C_LFGList.GetApplicantMemberStats(applicant:GetID(), applicant:GetIndex()) or {}
    do
        for k, v in pairs(stats) do
            if v == 0 then
                stats[k] = nil
            end
        end
    end

    if next(stats) then
        GameTooltip:AddSepatator()
        GameTooltip:AddLine(LFG_LIST_PROVING_GROUND_TITLE)

        for _, _v in ipairs(PROVING_GROUND_DATA) do
            for i, v in ipairs(_v) do
                if stats[v.id] then
                    GameTooltip:AddLine(v.text)
                    break
                end
            end
        end
    end

    -- Add Progression
    local activityID = applicant:GetActivityID()
    local progressions = RAID_PROGRESSION_LIST[activityID]
    local progressionValue = applicant:GetProgression()
    local activity = CreatePanel:GetCurrentActivity()
    if progressions and progressionValue then
        GameTooltip:AddSepatator()
        GameTooltip:AddDoubleLine(L['副本经验：'], activity:GetName())
        for i, v in ipairs(progressions) do
            GameTooltip:AddDoubleLine(v.name, GetProgressionTex(progressionValue, i), 1, 1, 1)
        end
    end
    GameTooltip:Show()
end

function MainPanel:CloseTooltip()
    self.GameTooltip:Hide()
end

function MainPanel:OpenRecentPlayerTooltip(player)
    local manager = player:GetManager()
    local tooltip = self.GameTooltip
    tooltip:SetOwner(self, 'ANCHOR_NONE')
    tooltip:SetPoint('TOPLEFT', self, 'TOPRIGHT', 1, -10)

    tooltip:SetText(manager:GetName())
    tooltip:AddLine(player:GetNameText())
    tooltip:AddLine(player:GetNotes(), 1, 1, 1, true)
    tooltip:Show()
end

function MainPanel:OpenAssociationTooltip(association, tooltip)
    -- 初始化tooltip
    if not tooltip then
        tooltip = self.GameTooltip
        tooltip:SetOwner(self, 'ANCHOR_NONE')
        tooltip:SetPoint('TOPLEFT', self, 'TOPRIGHT', 1, -10)
    end

    -- 添加公会基本信息
    tooltip:AddHeader(association.AssociationName, 1, 1, 1)
    tooltip:AddLine(format("服务器: |cffffffff%s|r", association.serverName or association.AssociationType))
    tooltip:AddLine(format("成员数量: |cffffffff%d|r", tonumber(association.AssociationNum) or 0))

    -- 添加公会说明
    if association.explain and association.explain ~= "" then
        tooltip:AddSepatator()
        tooltip:AddLine("公会说明:", 1, 1, 1)
        tooltip:AddLine(association.explain, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
    end

    if association.SelectedSpecs then
        tooltip:AddSepatator()

        -- 判断选择的专精情况
        local specText = "任意专精"
        local roleCounts = {TANK = 0, HEALER = 0, DAMAGER = 0}
        local isFullRoleSelected = false
        local fullSelectedRole = nil
        local hasOtherRoles = false

        -- 首先创建一个从专精名称到specData的映射
        local specNameToData = {}
        for specID, specData in pairs(self.specsByID) do
            local formattedName = format("%s(%s)", specData.name, specData.className)
            specNameToData[formattedName] = specData
        end

        -- 统计各角色类型的数量
        for _, specString in ipairs(association.SelectedSpecs) do
            local specData = specNameToData[specString]
            if specData then
                roleCounts[specData.role] = (roleCounts[specData.role] or 0) + 1
            end
        end

        -- 判断是否全选了某个角色类型
        for role, count in pairs(roleCounts) do
            local total = 0
            -- 计算该角色类型的专精总数
            for _, spec in ipairs(self.specs) do
                if spec.role == role then
                    total = total + 1
                end
            end

            -- 如果当前角色类型的选中数量等于总数且大于0
            if count == total and count > 0 then
                -- 检查是否有其他角色类型的专精被选中
                hasOtherRoles = false
                for otherRole, otherCount in pairs(roleCounts) do
                    if otherRole ~= role and otherCount > 0 then
                        hasOtherRoles = true
                        break
                    end
                end

                -- 如果没有其他角色类型的专精被选中
                if not hasOtherRoles then
                    isFullRoleSelected = true
                    fullSelectedRole = role
                    break
                end
            end
        end

        -- 设置显示的文本
        if #association.SelectedSpecs == 0 then
            -- 任意专精使用默认颜色
            specText = "|cffffffff任意专精|r"
        elseif isFullRoleSelected then
            -- 根据角色类型设置不同颜色
            local roleColors = {
                TANK = {r = 0.67, g = 0.83, b = 0.45},    -- 坦克颜色
                HEALER = {r = 0.33, g = 0.83, b = 0.45},  -- 治疗颜色
                DAMAGER = {r = 0.83, g = 0.33, b = 0.33}   -- 输出颜色
            }

            local color = roleColors[fullSelectedRole]
            if fullSelectedRole == "TANK" then
                specText = format("|cff%.2x%.2x%.2x%s|r",
                    color.r*255, color.g*255, color.b*255, "坦克专精")
            elseif fullSelectedRole == "HEALER" then
                specText = format("|cff%.2x%.2x%.2x%s|r",
                    color.r*255, color.g*255, color.b*255, "治疗专精")
            elseif fullSelectedRole == "DAMAGER" then
                specText = format("|cff%.2x%.2x%.2x%s|r",
                    color.r*255, color.g*255, color.b*255, "伤害输出专精")
            end
        else
            -- 自定义专精选择使用默认颜色
            specText = "|cffffffff自定义专精选择|r"
        end

        tooltip:AddLine("需要的专精: "..specText)

        -- 如果不是全选某个角色类型，显示具体选择的专精
        if not isFullRoleSelected and #association.SelectedSpecs > 0 then
            -- 按角色类型分组显示专精
            local roleGroups = {
                {role = "TANK", title = "坦克专精:", color = {r = 0.67, g = 0.83, b = 0.45}},  -- 坦克颜色
                {role = "HEALER", title = "治疗专精:", color = {r = 0.33, g = 0.83, b = 0.45}},  -- 治疗颜色
                {role = "DAMAGER", title = "伤害输出专精:", color = {r = 0.83, g = 0.33, b = 0.33}}  -- 输出颜色
            }

            for _, group in ipairs(roleGroups) do
                local specsInRole = {}
                -- 遍历SelectedSpecs中的每个专精字符串
                for _, specString in ipairs(association.SelectedSpecs) do
                    local specData = specNameToData[specString]
                    if specData and specData.role == group.role then
                        table.insert(specsInRole, specData)
                    end
                end

                if #specsInRole > 0 then
                    -- 添加角色类型标题
                    tooltip:AddLine(format("|cff%.2x%.2x%.2x%s|r",
                        group.color.r*255, group.color.g*255, group.color.b*255,
                        group.title))

                    -- 添加该角色类型下的专精
                    for _, spec in ipairs(specsInRole) do
                        tooltip:AddDoubleLine(
                            format("   |T%s:16|t |cff%.2x%.2x%.2x%s|r",
                                spec.icon,
                                spec.classColor.r*255, spec.classColor.g*255, spec.classColor.b*255,
                                spec.name),
                            format("|cff%.2x%.2x%.2x%s|r",
                                spec.classColor.r*255, spec.classColor.g*255, spec.classColor.b*255,
                                spec.className)
                        )
                    end
                end
            end
        end
    end

    -- 添加装备等级要求
    local mounting = tonumber(association.mounting)
    if mounting and mounting > 0 then
        tooltip:AddSepatator()
        tooltip:AddLine(format("装备等级要求: |cffffffff%d|r", mounting))
    end

    if association.DifficultyName and association.ActivityTendencyType == "RAID" then
        local difficultyColors = {
                ["普通"] = "|cffffffff",  -- 白色
                ["英雄"] = "|cff0070dd",  -- 蓝色
                ["史诗"] = "|cffff8000",  -- 橙色
                -- 如果有其他难度可以继续添加
            }
        local colorCode = difficultyColors[association.DifficultyName] or "|cffffffff"
        tooltip:AddLine("自填公会进度: "..format("%s%s|r |cffffffff%d/%d|r",
                    colorCode,
                    association.DifficultyName,
                    association.EncounterProgress,
                    association.MaxEncounters))
        if association.RecruitmentTypeText then
          tooltip:AddLine("招募类型: "..format("|cffffffff%s|r",association.RecruitmentTypeText))
        end
    end

    if association.StartTime and association.ActivityTendencyType == "RAID" then
        tooltip:AddLine("活动时间:"..format(" |cFFBF80FF%s - %s|r",
                    association.StartTime,
                    association.EndTime))
    end

    if association.SelectedDaysDescription and association.ActivityTendencyType == "RAID" then
        tooltip:AddLine("活动日:"..format(" |cFFBF80FF%s|r",
            association.SelectedDaysDescription))
    end

    --if association.NewcomerRecommendation > 0 then
    --  tooltip:AddSepatator()
    --  tooltip:AddLine(format(
    --    [[|TInterface\AddOns\MeetingStone\Media\GlodLeaderIcon:20:20:0:0:128:128:0:128:0:128|t %s  %d]],
    --    L['新人推荐度'], association.NewcomerRecommendation))
    --end

    -- 获取会长信息
    local guildLeaderName = association.LeaderName
    if guildLeaderName then
        tooltip:AddSepatator()
        if association.Faction then
          local factionColor = "ffff0000"
          if association.Faction == "联盟" then
              factionColor = "ff0070dd"
          end
          tooltip:AddLine(format("发布者: |cffffffff%s|r |c%s(%s)|r", guildLeaderName, factionColor, association.Faction))
        else
          tooltip:AddLine(format("发布者: |cffffffff%s|r", guildLeaderName))
        end

        -- PVP类型与索引的对应关系
        local pvpTypes = {
            [1] = "2v2 竞技场",
            [2] = "3v3 竞技场",
            [3] = "5v5 竞技场",
            [4] = "评级战场"
        }

        -- 循环检查1-4的PVP等级
        for pvpRank = 1, #association.PersonalRated do
            local rating = association.PersonalRated[pvpRank]
            if rating and rating > 0 then
                tooltip:AddLine(format("%s 等级: |cffffffff%d|r", pvpTypes[pvpRank], rating))
            end
        end

        local averageItemLevel = association.AverageItemLevel
        if averageItemLevel and averageItemLevel > 0 then
            tooltip:AddLine(format("发布者物品等级: |cffffffff%.1f|r", averageItemLevel))
        end
        if association.MythicPlusScore and association.MythicPlusScore > 0 and association.ActivityTendencyType == "DUNGEON" then
          local color = "|cFFBF80FF"
          if association.MythicPlusScore > 3000 then
              color = "|cffff8000"
          end
          tooltip:AddLine("史诗钥石分数: "..format(" %s%d|r",
                      color, association.MythicPlusScore))
        end

    end

    if #association.TopThreePlayers > 1 and (association.ActivityTendencyType == "SOCIAL" or association.ActivityTendencyType == "RP") then
      tooltip:AddSepatator()
      tooltip:AddLine("公会前三名成就玩家:")
      for i, player in ipairs(association.TopThreePlayers) do
        tooltip:AddDoubleLine(player.name, format("成就点: |cffffffff  %d |r", player.points))
      end
    end

    -- 显示tooltip
    tooltip:Show()
end

