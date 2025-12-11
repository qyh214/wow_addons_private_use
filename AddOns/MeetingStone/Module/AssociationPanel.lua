BuildEnv(...)

-- 添加分页相关变量
local PAGE_SIZE = 100  -- 每页显示的数量
local currentPage = 1  -- 当前页码

AssociationPanel = Addon:NewModule(CreateFrame('Frame', nil, MainPanel), 'AssociationPanel', 'AceEvent-3.0', 'AceTimer-3.0', 'AceSerializer-3.0',
  'AceBucket-3.0')

local Base64 = LibStub('NetEaseBase64-1.0')
local AceSerializer = LibStub('AceSerializer-3.0')
local LibDeflate = LibStub:GetLibrary("LibDeflate")

local socialOptions = {
    {text = "团队副本", value = "RAID"},
    {text = "地下城", value = "DUNGEON"},
    {text = "社交和升级", value = "SOCIAL"},
    {text = "PVP", value = "PVP"},
    {text = "角色扮演", value = "RP"}
}

local SimpleApplicantNotifier = {
    hasApplicants = false,
    checkInterval = 10 -- 检查间隔(秒)
}

-- 难度映射表
local DIFFICULTY_MAP = {
    [14] = {text = "普通", value = 14},
    [15] = {text = "英雄", value = 15},
    [16] = {text = "史诗", value = 16}
}

-- 设置默认值为最高numEncounters，如果没有数据则默认8 本赛季
local MaxEncounters = 8
local SeasonalSelection = "欧米伽"

function AssociationPanel:OnInitialize()
    GUI:Embed(self, 'Tab')
    MainPanel:RegisterPanel(L['公会招募'], self, {
      after = L['管理活动'],
      padding = 5,
      topHeight = 100
    })

    self.DifficultyMap = {
        ['普通'] = 1,
        ['英雄'] = 2,
        ['史诗'] = 3
    }

    self:RegisterMessage('MEETINGHORN_SQGDL')
    self:RegisterMessage('MEETINGHORN_SQGDW')
    self:RegisterMessage('MEETINGSTONE_SERVER_STATUS_UPDATED', 'UpdateStatus')

    if Profile.cdb.profile.Association == nil or Profile.cdb.profile.Association.IgnoreList == nil then
      Profile.cdb.profile.Association = {}
      Profile.cdb.profile.Association.IgnoreList = {}
    end

    self.hasPermission = false
    self.isWhiteRole = false

    self.ActivityTendencyType = "RAID"

    local ActivityTendency = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
    ActivityTendency:SetPoint('TOPLEFT', MainPanel, 'TOPLEFT', 70, -30)
    ActivityTendency:SetText(L['活动倾向 (筛选公会类型)'])

    local ActivityDropdown = GUI:GetClass('Dropdown'):New(self)
    ActivityDropdown:SetPoint('TOPLEFT', ActivityTendency, 'BOTTOMLEFT', 0, -5)
    ActivityDropdown:SetSize(170, 26)
    ActivityDropdown:SetMaxItem(20)
    ActivityDropdown:SetDefaultValue(0)
    ActivityDropdown:SetDefaultText(L['请选择活动倾向'])
    ActivityDropdown:SetCallback('OnSelectChanged', function(_, data, ...)
      if self.IgnoreList then
        self.IgnoreList:SetColumnVisible("ActivityTime", data.value == "RAID")
      end
      self.ActivityTendencyType = data.value
      if self.filtrateCount then
        if data.value == "RAID" or data.value == "DUNGEON" then
          self.filtrateCount:Show()
          if data.value == "RAID" then
            self.filtrateCount:SetText('仅看史诗')
          elseif data.value == "DUNGEON" then
            self.filtrateCount:SetText('仅看2600分以上')
          end
        else
          self.filtrateCount:Hide()
        end

      end
      self:SendAssociationSQGDL()
    end)
    ActivityDropdown:SetMenuTable(socialOptions)
    ActivityDropdown:SetValue('RAID')
    self.ActivityDropdown = ActivityDropdown

    -- 新增排序方式下拉框
    local ServerType = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
    ServerType:SetPoint('TOPLEFT', ActivityTendency, 'TOPLEFT', 200, 0)
    ServerType:SetText(L['服务器'])

    self.ServerNameType = Profile.cdb.profile.Association.ServerNameType or GetGuildMasterRealm()

    -- 创建编辑框
    local ServerEditBox = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
    ServerEditBox:SetSize(100, 20)
    ServerEditBox:SetPoint("TOPLEFT", ServerType, "BOTTOMLEFT", 0, -10)
    ServerEditBox:SetAutoFocus(false)
    ServerEditBox:SetMaxLetters(20)
    ServerEditBox:SetText(self.ServerNameType or '')
    self.ServerEditBox = ServerEditBox

    -- 创建自动完成的下拉框
    local suggestionDropdown = CreateFrame("Frame", nil, UIParent, "TooltipBorderedFrameTemplate")
    suggestionDropdown:SetClampedToScreen(true)
    suggestionDropdown:SetFrameStrata("DIALOG")
    suggestionDropdown:SetSize(180, 150)
    suggestionDropdown:Hide()
    self.suggestionDropdown = suggestionDropdown

    -- 创建滚动框架
    local scrollFrame = CreateFrame("ScrollFrame", nil, suggestionDropdown, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)

    -- 创建内容框架
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(150, 0)
    scrollFrame:SetScrollChild(content)

    -- 存储建议按钮
    local suggestionButtons = {}

    -- 正式服服务器列表（中国大陆地区）
    local serverList = {
        "阿尔萨斯", "阿比迪斯", "阿扎达斯", "阿曼尼", "埃德萨拉", "埃雷达尔", "艾维娜", "艾莫莉丝", "安东尼达斯",
        "安戈洛", "安格博达", "安加萨", "安苏", "奥达曼", "奥杜尔", "奥妮克希亚", "奥蕾莉亚", "奥特兰克",
        "奥斯里安", "巴尔古恩", "白银之手", "暴风祭坛", "壁炉谷", "冰风岗", "藏宝海湾", "达尔坎", "达克萨隆",
        "丹莫德", "迪瑟洛克", "冬拥湖", "杜隆坦", "朵丹尼尔", "恶魔之魂", "菲米丝", "盖斯", "古达克",
        "古尔丹", "古加尔", "格雷迈恩", "国王之谷", "嚎风峡湾", "寒冰皇冠", "黑锋哨站", "黑铁", "红龙军团",
        "火羽山", "霍格", "基尔加丹", "加尔", "加基森", "迦拉克隆", "金度", "金色平原", "荆棘谷",
        "凯恩血蹄", "凯尔萨斯", "卡珊德拉", "卡扎克", "库德兰", "狂热之刃", "兰娜瑟尔", "雷斧堡垒", "雷克萨",
        "丽丽（四川）", "烈焰峰", "灵风", "洛肯", "洛萨", "罗宁", "玛诺洛斯", "麦迪文", "米奈希尔",
        "密林游侠", "末日行者", "耐奥祖", "诺莫瑞根", "诺森德", "诺兹多姆", "贫瘠之地", "晴日峰（江苏）",
        "燃烧平原", "燃烧之刃", "萨尔", "塞拉摩", "塞拉赞恩", "沙怒", "圣火神殿", "生态船", "时光之穴",
        "斯克提斯", "斯坦索姆", "死亡之翼", "索瑞森", "提尔之手", "提瑞斯法", "通灵学院", "铜龙军团",
        "图拉扬", "托塞德林", "瓦拉纳", "瓦里安", "亡语者", "威拉扎德", "永夜港", "勇士岛", "巫妖之王",
        "无底海渊", "西瘟疫之地", "血色十字军", "迅捷微风", "亚雷戈斯", "伊萨里奥斯", "伊森德雷", "伊森利恩",
        "伊瑟拉", "银月", "影牙要塞", "影之哀伤", "远古海滩", "月光林地", "扎拉赞恩", "斩魔者", "蜘蛛王国",
        "金色平原", "祖尔金", "血吼", "血环", "血牙魔王", "熊猫酒仙", "辛达苟萨", "符文图腾", "鬼雾峰",
        "恐怖图腾", "霜狼", "霜之哀伤", "风暴之眼", "风暴之鳞", "风暴峭壁", "白骨荒野", "阿格拉玛",
        "艾苏恩", "安威玛尔", "尘风峡谷", "达纳斯", "迪托马斯", "黑石尖塔", "回音山", "基尔罗格", "卡德罗斯",
        "蓝龙军团", "雷霆之王", "玛多兰", "玛瑟里顿", "奈萨里奥", "普瑞斯托", "萨格拉斯", "山丘之王", "索拉丁",
        "阿迦玛甘", "阿克蒙德", "埃加洛尔", "埃苏雷格", "艾萨拉", "艾森娜", "爱斯特纳", "暗影之月", "奥拉基尔",
        "冰霜之刃", "达斯雷玛", "地狱咆哮", "地狱之石", "风暴之怒", "风行者", "弗塞雷迦", "戈古纳斯", "海加尔",
        "毁灭之锤", "火焰之树", "卡德加", "拉文凯斯", "玛法里奥", "玛维·影歌", "梅尔加尼", "梦境之树", "耐普图隆",
        "轻风之语", "夏维安", "塞纳留斯", "闪电之刃", "石爪峰", "泰兰德", "屠魔山谷", "伊利丹", "月神殿",
        "战歌", "主宰之剑", "布莱克摩", "黑暗之矛", "红龙女王", "红云台地", "黄金之路", "迦罗娜", "狂风峭壁",
        "雷霆号角", "玛里苟斯", "纳沙塔尔", "普罗德摩", "千针石林", "甜水绿洲", "沃金", "羽月", "自由之风",
        "艾欧娜尔", "暗影议会", "达隆米尔", "耳语海岸", "激流堡", "巨龙之吼", "暗影裂口", "克尔苏加德", "拉格纳罗斯",
        "埃霍恩", "利刃之拳", "瑞文戴尔", "塔伦米尔", "希尔瓦娜斯", "遗忘海岸", "银松森林", "鹰巢山", "世界之树",
        "恶魔之翼", "万色星辰", "激流之傲", "加兹鲁维", "大地之怒", "雏龙之翼", "黑暗魅影", "踏梦者", "神圣之歌",
        "暮色森林", "元素之力", "日落沼泽", "芬里斯", "法拉希姆", "安其拉", "安纳塞隆", "阿努巴拉克", "阿拉希",
        "瓦里玛萨斯", "巴纳扎尔", "黑手军团", "血羽", "燃烧军团", "克洛玛古斯", "破碎岭", "克苏恩", "阿纳克洛斯",
        "雷霆之怒", "桑德兰", "黑翼之巢", "德拉诺", "龙骨平原", "卡拉赞", "熔火之心", "格瑞姆巴托", "古拉巴什",
        "哈卡", "海克泰尔", "库尔提拉斯", "洛丹伦", "奈法利安", "奎尔萨拉斯", "拉贾克斯", "拉文霍德", "森金",
        "范达尔鹿盔", "泰拉尔", "瓦拉斯塔兹", "永恒之井", "海达希亚", "萨菲隆", "纳克萨玛斯", "无尽之海", "莱索恩",
        "阿卡玛", "灰谷", "巴瑟拉斯", "血顶", "达文格尔", "埃克索图斯", "菲拉斯", "加里索斯", "布莱恩", "伊莫塔尔",
        "大漩涡", "外域", "天空之墙", "逐日者", "塔纳利斯", "瑟莱德丝", "黑暗虚空", "双子峰", "天谴之门", "冰川之拳",
        "刺骨利刃", "深渊之巢", "埃基尔松", "火烟之谷", "伊兰尼库斯", "火喉", "冬寒", "迦玛兰", "幽暗沼泽", "烈焰荆棘",
        "夺灵者", "石锤", "厄祖玛特", "冬泉谷", "深渊之喉", "凤凰之神", "阿古斯", "奥金顿", "刀塔", "鲜血熔炉",
        "黑暗之门", "死亡熔炉", "格鲁尔", "哈兰", "军团要塞", "麦姆", "艾露恩", "穆戈尔", "摩摩尔", "试炼之环",
        "罗曼斯", "希雷诺斯", "塞泰克", "暗影迷宫", "托尔巴拉德", "太阳之井", "末日祷告祭坛", "范克里夫", "瓦丝琪",
        "祖阿曼", "祖达克", "翡翠梦境", "阿斯塔洛", "布鲁塔卢斯", "达基萨斯", "熵魔", "能源舰", "迦顿", "戈提克",
        "奎尔丹纳斯", "萨洛拉丝", "奥尔加隆", "织亡者", "玛洛加尔","丽丽（四川）", "晴日峰（江苏）"
    }
    -- 更新建议列表
    local function UpdateSuggestions(text)
        -- 清空现有按钮
        for _, btn in ipairs(suggestionButtons) do
            btn:Hide()
        end

        if text == "" then
            suggestionDropdown:Hide()
            return
        end

        -- 收集匹配的建议
        local matches = {}
        text = text:lower()

        for _, server in ipairs(serverList) do
            if server:lower():find(text, 1, true) then
                table.insert(matches, server)
            end
        end

        -- 按匹配度排序
        table.sort(matches, function(a, b)
            return a:lower():find(text) < b:lower():find(text)
        end)

        -- 限制显示数量
        local maxSuggestions = math.min(#matches, 8)

        if maxSuggestions == 0 then
            suggestionDropdown:Hide()
            return
        end

        -- 创建或更新建议按钮
        for i = 1, maxSuggestions do
            if not suggestionButtons[i] then
                local btn = CreateFrame("Button", nil, content)
                btn:SetSize(150, 20)
                btn:SetNormalFontObject("GameFontNormalSmall")
                btn:SetHighlightFontObject("GameFontHighlightSmall")

                btn:SetScript("OnClick", function(tempSelf)
                    ServerEditBox:SetText(tempSelf.serverName)
                    ServerEditBox:ClearFocus()
                    suggestionDropdown:Hide()
                    self.ServerNameType = tempSelf.serverName
                    Profile.cdb.profile.Association.ServerNameType = self.ServerNameType
                end)

                suggestionButtons[i] = btn
            end

            local btn = suggestionButtons[i]
            btn:SetPoint("TOPLEFT", 0, -(i-1)*20)
            btn:SetText(matches[i])
            btn.serverName = matches[i]
            btn:Show()
        end

        -- 调整内容框架大小
        content:SetHeight(maxSuggestions * 20)

        -- 显示建议框并定位到编辑框下方
        suggestionDropdown:SetHeight(math.min(maxSuggestions * 20 + 10, 150))
        suggestionDropdown:SetPoint("TOP", ServerEditBox, "BOTTOM", 0, -5)
        suggestionDropdown:Show()
    end

    -- 设置编辑框事件处理
    ServerEditBox:SetScript("OnTextChanged", function(tempSelf, isUserInput)
        if isUserInput then
            self.ServerNameType = tempSelf:GetText()
            Profile.cdb.profile.Association.ServerNameType = self.ServerNameType
            UpdateSuggestions(tempSelf:GetText())
        end
    end)

    ServerEditBox:SetScript("OnEditFocusLost", function()
        C_Timer.After(0.1, function()
            if not suggestionDropdown:IsMouseOver() then
                suggestionDropdown:Hide()
            end
        end)
    end)

    ServerEditBox:SetScript("OnEditFocusGained", function(self)
        UpdateSuggestions(self:GetText())
    end)

    -- 添加键盘导航支持
    ServerEditBox:SetScript("OnKeyDown", function(self, key)
        if key == "DOWN" and suggestionDropdown:IsShown() then
            for i, btn in ipairs(suggestionButtons) do
                if btn:IsShown() then
                    btn:SetFocus()
                    break
                end
            end
        end
    end)

    local filtrateCount = GUI:GetClass('CheckBox'):New(self)
    filtrateCount:SetSize(24, 24)
    filtrateCount:SetPoint('LEFT', ServerEditBox, 'RIGHT', 10, 0)
    filtrateCount:SetText('仅看史诗')
    filtrateCount:SetChecked(false)
    filtrateCount:SetScript('OnClick', function()
      if not self.IgnoreList then
        return
      end
      if self.filtrateCount and self.filtrateCount:GetChecked() and (self.ActivityTendencyType == "RAID" or self.ActivityTendencyType == "DUNGEON") then
        self.IgnoreList:SetFilterText('AssociationPanel')
      else
        self.IgnoreList:SetFilterText('')
      end
      self.IgnoreList:Refresh()
    end)
    self.filtrateCount = filtrateCount

    local RefreshButton = CreateFrame("Button", nil, self, "UIMenuButtonStretchTemplate")
    RefreshButton:SetSize(60, 30)
    RefreshButton:SetPoint("TOPRIGHT", MainPanel, "TOPRIGHT", -30, -50)
    RefreshButton:SetText("搜索")
    RefreshButton:SetNormalFontObject('GameFontNormal')
    RefreshButton:SetHighlightFontObject('GameFontHighlight')
    RefreshButton:SetDisabledFontObject('GameFontDisable')

    self.cooldownActive = false
    self.cooldownRemaining = 0

    local function UpdateButtonState(_, elapsed)
        if not self.cooldownActive then return end

        self.cooldownRemaining = self.cooldownRemaining - elapsed

        if self.cooldownRemaining <= 0 then
            -- 冷却结束
            self.cooldownActive = false
            RefreshButton:SetText("搜索")
            RefreshButton:SetEnabled(Logic.IsConnectServer)
            RefreshButton:SetScript("OnUpdate", nil)
            self.ActivityDropdown:SetEnabled(true)
            if self.firstPageButton then
                self.firstPageButton:Enable()
            end
            if self.nextPageButton then
                self.nextPageButton:Enable()
            end
            self.SearchingAssociationBlocker:Hide()
        else
            -- 更新倒计时文本
            local remaining = math.ceil(self.cooldownRemaining)
            RefreshButton:SetText(tostring(remaining)..'秒')
        end
    end

    RefreshButton:SetScript("OnClick", function(_)
        self:SendAssociationSQGDL()
    end)
    self.RefreshButton = RefreshButton

    self:SetScript("OnUpdate", UpdateButtonState)

    self.SearchBoxText = ""
    -- 创建搜索框框架
    local SearchBox = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
    SearchBox:SetSize(150, 20)
    SearchBox:SetPoint("RIGHT", RefreshButton, "LEFT", -10, 0)
    SearchBox:SetAutoFocus(false)
    SearchBox:SetTextInsets(20, 20, 0, 0) -- 为图标留出空间

    -- 设置默认提示文本
    SearchBox.placeholder = SearchBox:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    SearchBox.placeholder:SetPoint("LEFT", 20, 0)
    SearchBox.placeholder:SetText("搜索...")
    SearchBox.placeholder:SetTextColor(0.5, 0.5, 0.5)

    -- 创建放大镜图标
    local searchIcon = SearchBox:CreateTexture(nil, "OVERLAY")
    searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon") -- 使用游戏内置的搜索图标
    searchIcon:SetSize(14, 14)
    searchIcon:SetPoint("LEFT", 5, 0)

    -- 文本变化时处理
    SearchBox:SetScript("OnTextChanged", function(tempSelf)
        local searchText = tempSelf:GetText()
        if searchText == "" then
            tempSelf.placeholder:Show()
        else
            tempSelf.placeholder:Hide()
        end
        self.SearchBoxText = searchText
    end)

    -- 获取焦点时处理
    SearchBox:SetScript("OnEditFocusGained", function(self)
        self.placeholder:Hide()
    end)

    -- 失去焦点时处理
    SearchBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self.placeholder:Show()
        end
    end)

    -- 回车键处理
    SearchBox:SetScript("OnEnterPressed", function(tempSelf)
        local searchText = tempSelf:GetText()
        self.SearchBoxText = searchText
        self:SendAssociationSQGDL()
    end)

    self.clubFinderGUID = nil
    self.associationID = nil

    local IgnoreList = GUI:GetClass('DataGridView'):New(self)

    IgnoreList:SetAllPoints(self)
    IgnoreList:SetItemHighlightWithoutChecked(true)
    IgnoreList:SetItemHeight(32)
    IgnoreList:SetItemSpacing(1)
    IgnoreList:SetItemClass(Addon:GetClass('BrowseItem'))
    IgnoreList:SetSelectMode('RADIO')
    IgnoreList:SetScrollStep(9)
    IgnoreList:SetItemList(Profile.cdb.profile.Association.IgnoreList)
    --IgnoreList:SetSortHandler(function(activity)
    --  return self:SortHandler(activity)
    --end, true)

    IgnoreList:RegisterFilter(function(activity, ...)
      if self.filtrateCount and self.filtrateCount:GetChecked() and (self.ActivityTendencyType == "RAID" or self.ActivityTendencyType == "DUNGEON") then
        if self.ActivityTendencyType == "RAID" and activity.DifficultyName ~= "史诗" then
          return false
        elseif self.ActivityTendencyType == "DUNGEON" and activity.MythicPlusScore < 2600 then
          return false
        end
      end
      return true
    end)

    self.checkBoxs = {}
    IgnoreList:InitHeader({
      --{
      --  key = 'Recruit',
      --  text = '新人推荐度',
      --  width = 100,
      --  showHandler = function(activity)
      --    if activity.NewcomerRecommendation > 0 then
      --      return format([[|TInterface\AddOns\MeetingStone\Media\GlodLeaderIcon:20:20:0:0:128:128:0:128:0:128|t X%d]], activity.NewcomerRecommendation),NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b
      --    else
      --      return NONE, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b
      --    end
      --  end,
      --  sortHandler = function(activity)
      --    return activity.NewcomerRecommendation
      --  end
      --},
      {
        key = 'EnvironmentalRebirthCheck',
        text = '参与幻境新生',
        width = 100,
        showHandler = function(activity)
          if activity.EnvironmentalRebirthCheck then
            return [[|TInterface\AddOns\MeetingStone\Media\huanjing:30:69:0:0:128:32:0:69:0:30|t]]
          end
        end,
      },
      {
        key = 'AssociationName',
        text = '公会名',
        width = 150,
        showHandler = function(activity)
          return activity.AssociationName, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b
        end,
      },
      {
        key = 'ServerName',
        text = '服务器',
        width = 100,
        showHandler = function(activity)
          return activity.serverName, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b
        end,
      },
      {
        key = 'Schedule',
        text = '特殊数据',
        width = 120,
        showHandler = function(activity)
          if self.ActivityTendencyType == "RAID" then
            if activity.DifficultyName  then
              local difficultyColors = {
                ["普通"] = "|cffffffff",  -- 白色
                ["英雄"] = "|cff0070dd",  -- 蓝色
                ["史诗"] = "|cffff8000",  -- 橙色
              }

              local colorCode = difficultyColors[activity.DifficultyName] or "|cffffffff"
              return format("%s%s %d/%d|r",
                colorCode,
                activity.DifficultyName,
                activity.EncounterProgress,
                MaxEncounters)
            else
              return NONE, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b
            end
          elseif self.ActivityTendencyType == "PVP" then
            local maxNum = 0
            for _, num in ipairs(activity.PersonalRated) do
              if num > maxNum then
                maxNum = num
              end
            end
            if maxNum > 0 then
              return "PVP 点数"..maxNum
            else
              return NONE, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b
            end
          elseif self.ActivityTendencyType == "DUNGEON" then
            if not activity.MythicPlusScore or activity.MythicPlusScore == 0 then
              return NONE, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b
            end
            local color = "|cFFBF80FF"
            if activity.MythicPlusScore > 3000 then
                color = "|cffff8000"
            end
            return '钥石分: '..format("%s%d|r",
              color, activity.MythicPlusScore)
          elseif self.ActivityTendencyType == "SOCIAL" or self.ActivityTendencyType == "RP" then
            return '成就点: '..format("|cFFBF80FF%d|r",
              activity.HighestPlayerPoints)
          end
        end,
        sortHandler = function(activity)
          return self:SortHandler(activity)
        end,
      },
      {
        key = 'ActiveNumber',
        text = '活跃人数',
        width = 80,
        showHandler = function(activity)
            local num = activity.AssociationNum or 0
            local r, g, b
            if num >= 800 then
                r, g, b = 1.0, 0.5, 0.5
            elseif num >= 500 then
                r, g, b = 1.0, 0.75, 0.5
            elseif num >= 300 then
                r, g, b = 1.0, 1.0, 0.6
            elseif num <= 100 then
            r, g, b = 0.6, 1.0, 0.6
                r, g, b = GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b
            end

            return num, r, g, b
        end,
      },
      {
        key = 'Require',
        text = '装等要求',
        width = 80,
        showHandler = function(activity)
            local mounting = activity.mounting or 0
            return mounting
        end,
      },
      {
        key = 'ActivityTime',
        text = '活动时间',
        width = 100,
        showHandler = function(activity)
          if not activity.StartTime then
            return NONE, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b
          end
          return format("%s-%s", activity.StartTime, activity.EndTime), 1.0, 0.75, 0.5
        end,
      },
      {
        key = 'Explain',
        text = '说明',
        style = 'LEFT',
        width = 260,
        showHandler = function(activity)
          return activity.explain
        end,
      },
    })
    IgnoreList:SetHeaderPoint('BOTTOMLEFT', IgnoreList, 'TOPLEFT', -2, 2)

    IgnoreList:SetCallback('OnSelectChanged', function(_, _, activity)
      self:UpdateAddAssociationButton(activity)
    end)

    IgnoreList:SetCallback('OnItemEnter', function(_, _, applicant)
        MainPanel:OpenAssociationTooltip(applicant)
    end)
    IgnoreList:SetCallback('OnItemLeave', function()
        MainPanel:CloseTooltip()
    end)
    IgnoreList:SetCallback('OnItemMenu', function(_, itemButton, activity)
      self:ToggleActivityMenu(itemButton, activity)
    end)

    self.IgnoreList = IgnoreList

    local SearchingAssociationBlocker = CreateFrame('Frame', nil, self)
    do
      SearchingAssociationBlocker:Hide()
      SearchingAssociationBlocker:SetAllPoints(self)
      SearchingAssociationBlocker:SetScript('OnShow', function()
        IgnoreList:GetScrollChild():Hide()
      end)
      SearchingAssociationBlocker:SetScript('OnHide', function(SearchingBlocker)
        IgnoreList:GetScrollChild():Show()
        SearchingBlocker:Hide()
      end)

      local Spinner = CreateFrame('Frame', nil, SearchingAssociationBlocker, 'LoadingSpinnerTemplate')
      do
        Spinner:SetPoint('CENTER')
        Spinner.Anim:Play()
      end

      local Label = SearchingAssociationBlocker:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
      do
        Label:SetPoint('BOTTOM', Spinner, 'TOP')
        Label:SetText(SEARCHING)
      end
    end
    self.SearchingAssociationBlocker = SearchingAssociationBlocker

    local NoResultAssociationBlocker = CreateFrame('Frame', nil, self)
    do
      NoResultAssociationBlocker:SetPoint('BOTTOMLEFT')
      NoResultAssociationBlocker:SetPoint('BOTTOMRIGHT')
      NoResultAssociationBlocker:SetPoint('TOP')
      NoResultAssociationBlocker:Hide()

      local Label = NoResultAssociationBlocker:CreateFontString(nil, 'ARTWORK', 'GameFontDisable')
      do
        Label:SetPoint('CENTER', 0, 20)
      end
        Label:SetText([[|TInterface\DialogFrame\UI-Dialog-Icon-AlertNew:30|t  ]] .. "暂无公会")

      NoResultAssociationBlocker.Label = Label
    end
    self.NoResultAssociationBlocker = NoResultAssociationBlocker

    local RecruitIgnore = CreateFrame('Button', nil, self, 'UIPanelButtonTemplate')
    do
      GUI:Embed(RecruitIgnore, 'Tooltip')
      RecruitIgnore:SetTooltipAnchor('ANCHOR_TOP')
      RecruitIgnore:SetSize(120, 22)
      RecruitIgnore:SetPoint('BOTTOM', MainPanel, 'BOTTOM', -64, 4)
      RecruitIgnore:SetText('发布招募')
      RecruitIgnore:SetMotionScriptsWhileDisabled(true)
      RecruitIgnore:SetScript('OnClick', function()
        self:CreateRecruitmentWindow()
        self.recruitmentFrame:Show()
      end)
    end
    self.RecruitIgnore = RecruitIgnore

    local AddAssociationIgnore = CreateFrame('Button', nil, self, 'UIPanelButtonTemplate')
    do
      GUI:Embed(AddAssociationIgnore, 'Tooltip')
      AddAssociationIgnore:SetTooltipAnchor('ANCHOR_TOP')
      AddAssociationIgnore:SetTooltip(L['请选择一个搜索结果'])
      AddAssociationIgnore:SetSize(120, 22)
      AddAssociationIgnore:SetPoint('BOTTOM', MainPanel, 'BOTTOM', 64, 4)
      AddAssociationIgnore:SetText('申请加入')
      AddAssociationIgnore:Disable()
      AddAssociationIgnore:SetMotionScriptsWhileDisabled(true)
      AddAssociationIgnore:SetScript('OnClick', function()
        self:ShowApplicationDialog()
      end)
    end
    self.AddAssociationIgnore = AddAssociationIgnore

    -- 添加分页控制按钮
    local pageControlFrame = CreateFrame("Frame", nil, self)
    pageControlFrame:SetSize(200, 30)
    pageControlFrame:SetPoint("BOTTOMRIGHT", MainPanel, "BOTTOMRIGHT", 10, 4)

    -- 下一页按钮
    local nextPageButton = CreateFrame("Button", nil, pageControlFrame, "UIPanelButtonTemplate")
    nextPageButton:SetSize(80, 22)
    nextPageButton:SetPoint("BOTTOMRIGHT", MainPanel, "BOTTOMRIGHT", -10, 4)
    nextPageButton:SetText("下一页")
    nextPageButton:SetScript("OnClick", function()
        if self.cooldownActive then return end
        currentPage = currentPage + 1
        self:SendAssociationSQGDL(currentPage)
    end)
    nextPageButton:Hide()
    self.nextPageButton = nextPageButton

    -- 返回首页按钮
    local firstPageButton = CreateFrame("Button", nil, pageControlFrame, "UIPanelButtonTemplate")
    firstPageButton:SetSize(80, 22)
    firstPageButton:SetPoint("RIGHT", nextPageButton, "LEFT",10, 0)
    firstPageButton:SetText("首页")
    firstPageButton:SetScript("OnClick", function()
        if self.cooldownActive then return end
        if currentPage ~= 1 then
            currentPage = 1
            self:SendAssociationSQGDL(currentPage)
        end
    end)
    firstPageButton:Hide()
    self.firstPageButton = firstPageButton

    local AddAssociationProposer = CreateFrame('Button', nil, self, 'UIPanelButtonTemplate')
    GUI:Embed(AddAssociationProposer, 'Tooltip')
    AddAssociationProposer:SetTooltipAnchor('ANCHOR_TOP')
    AddAssociationProposer:SetSize(120, 22)
    AddAssociationProposer:SetPoint('BOTTOMLEFT', MainPanel, 'BOTTOMLEFT', 10, 4)
    AddAssociationProposer:SetText("查看申请人")
    AddAssociationProposer:Disable()
    AddAssociationProposer:SetMotionScriptsWhileDisabled(true)
    self.AddAssociationProposer = AddAssociationProposer

    self.originalText = AddAssociationProposer:GetText()

    -- 开始检查定时器
    self.checkTimer = C_Timer.NewTimer(SimpleApplicantNotifier.checkInterval, function()
        self:CheckApplicants()
    end)

    AddAssociationProposer:SetScript("OnClick", function()
        if not CommunitiesFrame then
            LoadAddOn("Blizzard_Communities")
        end

        -- 检查界面是否已经显示
        if CommunitiesFrame and CommunitiesFrame:IsShown() then
            -- 如果已显示，则关闭界面
            HideUIPanel(CommunitiesFrame)
        else
            -- 如果未显示，则打开界面并执行原有逻辑
            if CommunitiesFrame then
                ShowUIPanel(CommunitiesFrame) -- 打开主界面

                local guildClubId = C_Club.GetGuildClubId()
                if not self.hasPermission or not guildClubId then
                    return
                end

                if CommunitiesFrame.RosterTab then
                    CommunitiesFrame.RosterTab:Click() -- 点击"名单"标签
                end

                C_ClubFinder.RequestApplicantList(Enum.ClubFinderRequestType.Guild)

                -- 直接显示申请人列表，隐藏成员列表
                CommunitiesFrame.GuildMemberListDropdown:SetText("申请人")
                CommunitiesFrame.MemberList:Hide()
                CommunitiesFrame.ApplicantList:Show()
                self:HideReminder()
            end
        end
    end)

    self:SetScript("OnShow", self.OnShow)
		self:SetScript("OnHide", self.OnHide)

    self:UpdateStatus()
end

function AssociationPanel:CheckApplicants()
    local guildClubId = C_Club.GetGuildClubId()
    if not self.hasPermission or not guildClubId then
      return
    end
    if not CommunitiesFrame then
      LoadAddOn("Blizzard_Communities")
    end
    C_ClubFinder.RequestApplicantList(Enum.ClubFinderRequestType.Guild)

    C_Timer.After(0.5, function()
      local invitations = false
      if CommunitiesFrame.RosterTab.shadow then
        invitations = CommunitiesFrame.RosterTab.shadow:IsShown()
      end

      if invitations then
        self:ShowReminder()
      else
        self:HideReminder()
      end
    end)
end

function AssociationPanel:ShowReminder()
    self.AddAssociationProposer:SetText(string.format("有待处理申请"))
    self.AddAssociationProposer:SetNormalFontObject("GameFontGreen")
    SimpleApplicantNotifier.hasApplicants = true
end

-- 隐藏提醒
function AssociationPanel:HideReminder()
    self.AddAssociationProposer:SetText(self.originalText)
    self.AddAssociationProposer:SetNormalFontObject("GameFontNormal")
    SimpleApplicantNotifier.hasApplicants = false
end

function AssociationPanel:SortHandler(activity)
    if self.ActivityTendencyType == "RAID" then
        if activity.DifficultyName then
          local difficultyPart = tostring(self.DifficultyMap[activity.DifficultyName])  -- 1位 (1-3)
          local progressPart = string.format("%01d", activity.EncounterProgress or 0)  -- 1位 (0-8)
          local numPart = string.format("%04d", activity.AssociationNum or 0)  -- 4位 (最多1000)
          local idPart = string.format("%03d", activity.AssociationNumID or 0)
          return difficultyPart .. progressPart .. numPart .. idPart
        end
    elseif self.ActivityTendencyType == "PVP" then
        local maxNum = 0
        for _, num in ipairs(activity.PersonalRated) do
            if num > maxNum then
              maxNum = num
            end
        end
        return maxNum
    elseif self.ActivityTendencyType == "DUNGEON" then
        if not activity.MythicPlusScore or activity.MythicPlusScore == 0 then
          return 0
        end
        return activity.MythicPlusScore
    elseif self.ActivityTendencyType == "SOCIAL" or self.ActivityTendencyType == "RP" then
        return activity.HighestPlayerPoints
    end
end

-- 点击编辑框外部时隐藏建议框的处理函数
function AssociationPanel:HideSuggestionsOnClick(_, button)
    if not self.suggestionDropdown:IsMouseOver() and not self.ServerEditBox:IsMouseOver() then
        self.suggestionDropdown:Hide()
    end
end

function AssociationPanel:OnShow()
    self:SendAssociationSQGDL()
    Logic:SendServer('CQGDW')
    LogStatistics:InsertLog({ time(), "wow_recruit_tab", {action=1} })
    self:CheckApplicants()
end

-- 隐藏面板时的处理
function AssociationPanel:OnHide()
    -- 隐藏建议框
    if self.suggestionDropdown then
        self.suggestionDropdown:Hide()
    end
end

function AssociationPanel:HideSuggestionsOnClick(_, button)
    if self.suggestionDropdown:IsShown() and
       not self.suggestionDropdown:IsMouseOver() and
       not self.ServerEditBox:IsMouseOver() then
        self.suggestionDropdown:Hide()
    end
end

function AssociationPanel:UpdateStatus(event, isConnected)
  if IsInGuild() then
      local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")
      if guildRankIndex then
          self.hasPermission = (guildRankIndex <= 2) -- 根据公会设置调整这个值
      end
  end

  if Logic.IsConnectServer then
    if self.hasPermission and C_Club.GetGuildClubId() then
      self.RecruitIgnore:Enable()
      self.AddAssociationProposer:Enable()
      self.RecruitIgnore:SetTooltip(nil)
      self.AddAssociationProposer:SetTooltip(nil)
    else
      if not self.hasPermission then
        self.RecruitIgnore:SetTooltip(L['会长or官员才可发布'])
      elseif not C_Club.GetGuildClubId() then
        self.RecruitIgnore:SetTooltip(L['暴雪游戏服务目前不可用'])
        self.AddAssociationProposer:SetTooltip(L['暴雪游戏服务目前不可用'])
      end
    end
    if self.AddAssociationProposer then
      if self.hasPermission then
        self.AddAssociationProposer:SetText("查看申请人")
      else
        self.AddAssociationProposer:SetText("公会与社区")
      end
    end
    self.RefreshButton:Enable()
  else
    if self.RecruitIgnore then
      self.RecruitIgnore:SetEnabled(false)
      self.RecruitIgnore:SetTooltip(L['服务连接中...'])
      self.AddAssociationProposer:SetTooltip(L['服务连接中...'])
    end
    if self.RefreshButton then
      self.RecruitIgnore:SetEnabled(false)
    end
  end
end

local specAbbreviations = {
    ["战士"] = {
        ["武器"] = "武器战",
        ["防护"] = "防战",
        ["狂怒"] = "狂暴战"
    },
    ["萨满祭司"] = {
        ["恢复"] = "奶萨",
        ["增强"] = "增强萨",
        ["元素"] = "元素萨"
    },
    ["潜行者"] = {
        ["敏锐"] = "敏锐贼",
        ["狂徒"] = "狂徒贼",
        ["奇袭"] = "奇袭贼"
    },
    ["牧师"] = {
        ["暗影"] = "暗牧",
        ["神圣"] = "神牧",
        ["戒律"] = "戒律牧"
    },
    ["圣骑士"] = {
        ["防护"] = "防骑",
        ["神圣"] = "奶骑",
        ["惩戒"] = "惩戒骑"
    },
    ["武僧"] = {
        ["酒仙"] = "酒仙",
        ["踏风"] = "踏风",
        ["织雾"] = "织雾"
    },
    ["法师"] = {
        ["火焰"] = "火法",
        ["冰霜"] = "冰法",
        ["奥术"] = "奥法"
    },
    ["猎人"] = {
        ["生存"] = "生存猎",
        ["射击"] = "射击猎",
        ["野兽控制"] = "兽王猎"
    },
    ["唤魔师"] = {
        ["恩护"] = "恩护",
        ["湮灭"] = "湮灭",
        ["增辉"] = "增辉"
    },
    ["德鲁伊"] = {
        ["平衡"] = "鸟德",
        ["野性"] = "猫德",
        ["守护"] = "熊德",
        ["恢复"] = "奶德"
    },
    ["死亡骑士"] = {
        ["邪恶"] = "邪DK",
        ["冰霜"] = "冰DK",
        ["鲜血"] = "血DK"
    },
    ["术士"] = {
        ["恶魔"] = "恶魔术",
        ["毁灭"] = "毁灭术",
        ["痛苦"] = "痛苦术"
    },
    ["恶魔猎手"] = {
        ["复仇"] = "复仇DH",
        ["浩劫"] = "浩劫DH"
    }
}

local  function GetSpecAbbreviation(specText)
    local spec, class = specText:match("(.+)%((.+)%)")
    if not spec or not class then
        return specText
    end

    -- 查找缩写
    if specAbbreviations[class] and specAbbreviations[class][spec] then
        return specAbbreviations[class][spec]
    end

    return specText
end

function AssociationPanel:CreateRecruitmentWindow()
    -- 如果窗口已存在，则显示并置顶
    if self.recruitmentFrame then
        self.recruitmentFrame:Raise()
        return
    end

    -- 创建招募窗口
    self.recruitmentFrame = CreateFrame("Frame", "RecruitmentFrame", UIParent, "BasicFrameTemplateWithInset")
    local frame = self.recruitmentFrame
    frame:SetSize(450, 500)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- 标题
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 0)
    frame.title:SetText("公会招募信息")

    -- 第一行：显示公会名称
    local guildNameLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    guildNameLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -40)
    guildNameLabel:SetText("公会名称:")

    local guildNameText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    guildNameText:SetPoint("LEFT", guildNameLabel, "RIGHT", 10, 0)
    guildNameText:SetText(GetGuildInfo("player") or "无公会")

    -- 第二行：显示公会活跃人数
    local activeMembersLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    activeMembersLabel:SetPoint("TOPLEFT", guildNameLabel, "BOTTOMLEFT", 0, -20)
    activeMembersLabel:SetText("活跃人数:")

    local activeMembersText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    activeMembersText:SetPoint("LEFT", activeMembersLabel, "RIGHT", 10, 0)
    activeMembersText:SetText(GetNumGuildMembers() or "0")

    -- 第三行：社交倾向下拉框
    local socialLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    socialLabel:SetPoint("TOPLEFT", activeMembersLabel, "BOTTOMLEFT", 0, -20)
    socialLabel:SetText("社交倾向:")

    local socialDropdown = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate")
    socialDropdown:SetPoint("LEFT", socialLabel, "RIGHT", 10, 0)
    socialDropdown:SetWidth(150)
    UIDropDownMenu_SetWidth(socialDropdown, 100)
    frame.socialDropdown = socialDropdown

    local SavedInstanceList = {}

    for i = 1, GetNumSavedInstances() do
      local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
      if isRaid and string.find(name, SeasonalSelection) then
        table.insert(SavedInstanceList, {name = name, difficulty = difficulty, encounterProgress=numEncounters, maxPlayers=maxPlayers, difficultyName=difficultyName, numEncounters=encounterProgress})
      end
    end

    -- 创建父框架
    local settingsFrame = CreateFrame("Frame", nil, frame)
    settingsFrame:SetPoint("TOPLEFT", socialLabel, "BOTTOMLEFT", 0, -20)
    settingsFrame:SetSize(frame:GetWidth(), 110) -- 根据需要调整大小
    frame.settingsFrame = settingsFrame

    -- 副本进度行
    local raidProgressLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    raidProgressLabel:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 0, 0)
    raidProgressLabel:SetText("副本进度:")

    -- 副本难度下拉框
    local raidDifficultyDropdown = CreateFrame("Frame", nil, settingsFrame, "UIDropDownMenuTemplate")
    raidDifficultyDropdown:SetPoint("LEFT", raidProgressLabel, "RIGHT", 10, 0)
    raidDifficultyDropdown:SetWidth(80)
    UIDropDownMenu_SetWidth(raidDifficultyDropdown, 80)
    frame.raidDifficultyDropdown = raidDifficultyDropdown

    -- 存储当前选择的难度文本
    frame.selectedDifficultyText = "普通"

    -- 初始化副本难度下拉框
    UIDropDownMenu_Initialize(raidDifficultyDropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(button, arg1, arg2, checked)
            frame.selectedDifficultyText = arg1
            UIDropDownMenu_SetText(self, arg1)
        end

        -- 确保不显示多选框
        info.checked = false
        info.isNotRadio = true
        info.notCheckable = true

        -- 添加所有难度选项
        for _, diff in pairs(DIFFICULTY_MAP) do
            info.text = diff.text
            info.value = diff.value
            info.arg1 = diff.text
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- 设置默认值为最高难度，如果没有数据则默认普通
    local maxDifficulty = 14 -- 默认普通
    frame.encountersNum = 1
    for _, raid in ipairs(SavedInstanceList) do
        if raid.difficulty > maxDifficulty and DIFFICULTY_MAP[raid.difficulty] then
            maxDifficulty = raid.difficulty
            frame.encountersNum = raid.numEncounters
        end
    end

    -- 设置下拉框默认值
    UIDropDownMenu_SetSelectedValue(raidDifficultyDropdown, maxDifficulty)
    UIDropDownMenu_SetText(raidDifficultyDropdown, DIFFICULTY_MAP[maxDifficulty] and DIFFICULTY_MAP[maxDifficulty].text or "普通")
    frame.selectedDifficultyText = DIFFICULTY_MAP[maxDifficulty] and DIFFICULTY_MAP[maxDifficulty].text or "普通"

    -- 副本进度输入框
    local raidProgressInput = CreateFrame("EditBox", nil, settingsFrame, "InputBoxTemplate")
    raidProgressInput:SetPoint("LEFT", raidDifficultyDropdown, "RIGHT", 8, 2)
    raidProgressInput:SetSize(50, 20)
    raidProgressInput:SetAutoFocus(false)
    raidProgressInput:SetNumeric(true)

    local raidProgressTimeSeparator = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    raidProgressTimeSeparator:SetPoint("RIGHT", raidProgressInput, "LEFT", -8, 0)
    raidProgressTimeSeparator:SetText("-")

    for _, raid in ipairs(SavedInstanceList) do
        if raid.encounterProgress and raid.encounterProgress > MaxEncounters then
            MaxEncounters = raid.encounterProgress
        end
    end
    raidProgressInput:SetText(frame.encountersNum)
    frame.raidProgressInput = raidProgressInput

    -- 输入验证函数
    local function ValidateEncounterInput(self)
        local input = tonumber(self:GetText()) or 1
        local max = MaxEncounters

        -- 确保输入在1到MaxEncounters之间
        if input < 1 then
            input = 1
        elseif input > max then
            input = max
        end
        frame.encountersNum = input
        self:SetText(input)
    end

    raidProgressInput:SetScript("OnEditFocusLost", ValidateEncounterInput)
    raidProgressInput:SetScript("OnEnterPressed", ValidateEncounterInput)

    -- 招募类型
    local recruitmentType = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    recruitmentType:SetPoint("TOPLEFT", raidProgressLabel, "BOTTOMLEFT", 0, -15)
    recruitmentType:SetText("招募类型:")

    -- 副本难度下拉框
    local recruitmentTypeDropdown = CreateFrame("Frame", nil, settingsFrame, "UIDropDownMenuTemplate")
    recruitmentTypeDropdown:SetPoint("LEFT", recruitmentType, "RIGHT", 10, 0)
    recruitmentTypeDropdown:SetWidth(80)
    UIDropDownMenu_SetWidth(recruitmentTypeDropdown, 80)
    frame.recruitmentTypeDropdown = recruitmentTypeDropdown

    -- 难度映射表
    local RECRUITMENT_MAP = {
        [1] = {text = "开荒", value = 1},
        [2] = {text = "带新", value = 2},
        [3] = {text = "速推", value = 3}
    }

    -- 存储当前选择的难度文本
    local recruitmentTypeText = "开荒"

    -- 初始化副本难度下拉框
    UIDropDownMenu_Initialize(recruitmentTypeDropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(button, arg1, arg2, checked)
            recruitmentTypeText = arg1
            UIDropDownMenu_SetText(self, arg1)
        end

        -- 确保不显示多选框
        info.checked = false
        info.isNotRadio = true
        info.notCheckable = true

        -- 添加所有难度选项
        for _, diff in pairs(RECRUITMENT_MAP) do
            info.text = diff.text
            info.value = diff.value
            info.arg1 = diff.text
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- 设置下拉框默认值
    UIDropDownMenu_SetSelectedValue(recruitmentTypeDropdown, 1)
    UIDropDownMenu_SetText(recruitmentTypeDropdown, RECRUITMENT_MAP[1] and RECRUITMENT_MAP[1].text or "开荒")
    recruitmentTypeText = RECRUITMENT_MAP[1] and RECRUITMENT_MAP[1].text or "开荒"

    -- 活动时间行
    local activityTimeLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    activityTimeLabel:SetPoint("TOPLEFT", recruitmentType, "BOTTOMLEFT", 0, -15)
    activityTimeLabel:SetText("活动时间:")
    -- 创建开始时间输入框
    local startTimeInput = CreateFrame("EditBox", nil, settingsFrame, "InputBoxTemplate")
    startTimeInput:SetPoint("LEFT", activityTimeLabel, "RIGHT", 10, 0)
    startTimeInput:SetSize(50, 20)
    startTimeInput:SetAutoFocus(false)
    startTimeInput:SetText("00:00")
    frame.startTimeInput = startTimeInput

    -- 存储原始值，用于回退
    local originalText = "00:00"

    -- 验证时间格式
    local function ValidateTimeFormat(text)
        if not string.match(text, "^%d%d:%d%d$") then
            return false
        end

        local hour, minute = text:match("^(%d%d):(%d%d)$")
        hour = tonumber(hour)
        minute = tonumber(minute)

        return hour ~= nil and minute ~= nil and hour >= 0 and hour < 24 and minute >= 0 and minute < 60
    end

    -- 格式化时间
    local function FormatTime(text)
        -- 移除非数字字符
        local digits = text:gsub("[^0-9]", "")

        -- 如果为空，返回默认值
        if #digits == 0 then
            return "00:00"
        end

        -- 限制最多4位数字
        if #digits > 4 then
            digits = digits:sub(1, 4)
        end

        -- 自动插入冒号
        if #digits > 2 then
            return digits:sub(1, 2) .. ":" .. digits:sub(3)
        elseif #digits == 2 then
            return digits .. ":"
        else
            return digits
        end
    end

    -- 智能输入处理
    startTimeInput:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end

        -- 保存当前光标位置
        local cursorPos = self:GetCursorPosition()
        local text = self:GetText()

        -- 格式化文本
        local formatted = FormatTime(text)

        -- 只有在格式化后的文本不同时才更新
        if formatted ~= text then
            self:SetText(formatted)
            -- 调整光标位置
            if cursorPos == #text then
                self:SetCursorPosition(#formatted)
            else
                self:SetCursorPosition(cursorPos)
            end
        end
    end)

    startTimeInput:SetScript("OnEditFocusGained", function(self)
        originalText = self:GetText()
        self:HighlightText()
    end)

    startTimeInput:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()

        -- 验证时间格式
        if not ValidateTimeFormat(text) then
            self:SetText(originalText)
            print("请输入有效的时间格式 (HH:MM)")
        else
            originalText = text
        end

        self:ClearFocus()
        self:HighlightText(0, 0) -- 取消高亮
    end)

    startTimeInput:SetScript("OnEscapePressed", function(self)
        self:SetText(originalText)
        self:ClearFocus()
        self:HighlightText(0, 0) -- 取消高亮
    end)

    startTimeInput:SetScript("OnEditFocusLost", function(self)
        local text = self:GetText()

        -- 验证时间格式
        if not ValidateTimeFormat(text) then
            self:SetText(originalText)
        else
            originalText = text
        end

        self:HighlightText(0, 0) -- 取消高亮
    end)

    -- 分隔符和结束时间输入框（类似处理）
    local timeSeparator = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    timeSeparator:SetPoint("LEFT", startTimeInput, "RIGHT", 1, 0)
    timeSeparator:SetText("-")

    local endTimeInput = CreateFrame("EditBox", nil, settingsFrame, "InputBoxTemplate")
    endTimeInput:SetPoint("LEFT", timeSeparator, "RIGHT", 5, 0)
    endTimeInput:SetSize(50, 20)
    endTimeInput:SetAutoFocus(false)
    endTimeInput:SetText("00:00")
    frame.endTimeInput = endTimeInput

    -- 为结束时间输入框添加相同的脚本
    endTimeInput:SetScript("OnEditFocusGained", startTimeInput:GetScript("OnEditFocusGained"))
    endTimeInput:SetScript("OnTextChanged", startTimeInput:GetScript("OnTextChanged"))
    endTimeInput:SetScript("OnEnterPressed", startTimeInput:GetScript("OnEnterPressed"))
    endTimeInput:SetScript("OnEscapePressed", startTimeInput:GetScript("OnEscapePressed"))
    endTimeInput:SetScript("OnEditFocusLost", startTimeInput:GetScript("OnEditFocusLost"))

    local socialTooltip = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    socialTooltip:SetPoint("TOPLEFT", socialLabel, "BOTTOMLEFT", 0, -30)
    socialTooltip:SetWidth(300)  -- 设置宽度以容纳多行文本
    socialTooltip:SetJustifyH("LEFT")  -- 左对齐
    socialTooltip:SetJustifyV("TOP")   -- 顶部对齐
    socialTooltip:Hide()
    frame.socialTooltip = socialTooltip

    -- 星期名称
    self.dayNames = {"周一", "周二", "周三", "周四", "周五", "周六", "周日"}
    self.dayCheckButtons = {}

    -- 创建7个复选框，每个代表一周中的一天
    for i = 1, 7 do
        local checkButton = CreateFrame("CheckButton", nil, settingsFrame, "UICheckButtonTemplate")

        -- 设置位置
        if i == 1 then
            checkButton:SetPoint("TOPLEFT", activityTimeLabel, "BOTTOMLEFT", 0, -10)
        else
            checkButton:SetPoint("LEFT", self.dayCheckButtons[i-1], "RIGHT", 40, 0)
        end

        -- 设置大小
        checkButton:SetSize(20, 20)

        -- 添加文字标签
        local label = checkButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", checkButton, "RIGHT", 2, 0)
        label:SetText(self.dayNames[i])

        -- 存储复选框引用
        self.dayCheckButtons[i] = checkButton

        if i == 6 or i == 7 then
            checkButton:SetChecked(true)
        end

        checkButton:SetScript("OnClick", function(mySelf)
            -- 计算当前选中的复选框数量
            local checkedCount = 0
            for j = 1, 7 do
                if self.dayCheckButtons[j]:GetChecked() then
                    checkedCount = checkedCount + 1
                end
            end

            -- 如果当前是取消选中操作且只有一个选中的复选框
            if not mySelf:GetChecked() and checkedCount == 0 then
                -- 阻止取消选中，保持选中状态
                mySelf:SetChecked(true)
                return
            end

            if self.recruitmentFrame then
                self.recruitmentFrame:UpdateDescriptionText()
            end
        end)
    end

    UIDropDownMenu_Initialize(socialDropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for _, option in ipairs(socialOptions) do
            info.text = option.text
            info.value = option.value
            info.func = function(tempSelf)
                UIDropDownMenu_SetSelectedValue(socialDropdown, tempSelf.value)
                if option.value == "RAID" then
                    socialTooltip:Hide()
                    settingsFrame:Show()
                else
                    socialTooltip:Show()
                    settingsFrame:Hide()
                end
                if option.value == "DUNGEON" then
                    socialTooltip:SetText("公会偏好将会按照发布者当前的史诗钥石地下城分数进行排序，若有变动可手动更新")
                elseif option.value == "PVP" then
                    socialTooltip:SetText("公会偏好将会按照发布者当前的评级最高分数进行排序，若有变动可手动更新")
                else -- SOCIAL 和 RP 及其他选项
                    socialTooltip:SetText("公会偏好将会按照公会人员最高的成就点数进行排序，若有变动可手动更新")
                end
                frame.selectedSocial = tempSelf.value
                frame:UpdateDescriptionText()
            end
            info.checked = (frame.selectedSocial == option.value)
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- 设置默认值
    UIDropDownMenu_SetSelectedValue(socialDropdown, "RAID")
    frame.selectedSocial = "RAID"

    -- 第四行：专精选择（多选下拉框）
    local roleLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    roleLabel:SetPoint("TOPLEFT", settingsFrame, "BOTTOMLEFT", 0, 0)
    roleLabel:SetText("寻找专精:")

    -- 使用正确的下拉框模板
    local specDropdown = CreateFrame("Button", "SpecDropdownButton", frame, "UIDropDownMenuTemplate")
    specDropdown:SetPoint("LEFT", roleLabel, "RIGHT", 10, 0)
    specDropdown:SetSize(115, 32)
    UIDropDownMenu_SetWidth(specDropdown, 100)

    -- 存储选中的专精
    frame.selectedSpecs = {}
    frame.specs = {}
    frame.specsByID = {}

    -- 收集所有专精数据
    local classIDs = {}
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
                table.insert(frame.specs, specData)
                frame.specsByID[specID] = specData
            end
        end
    end

    -- 按角色类型、职业名称和专精名称排序
    table.sort(frame.specs, function(a, b)
        if a.role ~= b.role then
            local roleOrder = {TANK = 1, HEALER = 2, DAMAGER = 3}
            return roleOrder[a.role] < roleOrder[b.role]
        end
        if a.className ~= b.className then
            return a.className < b.className
        end
        return a.name < b.name
    end)

    UIDropDownMenu_Initialize(specDropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()

        if level == 1 then
            -- 任意专精（清空所有选择）
            info.text = "任意专精"
            info.func = function()
                wipe(frame.selectedSpecs)
                frame:UpdateSpecDropdownText()
                frame:UpdateDescriptionText()
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

            -- 坦克专精（全选坦克）
            info.text = "坦克"
            info.func = function()
                wipe(frame.selectedSpecs)
                for _, spec in ipairs(frame.specs) do
                    if spec.role == "TANK" then
                        frame.selectedSpecs[spec.id] = true
                    end
                end
                frame.lastSelectedRole = "TANK"  -- 记录当前选择的角色类型
                frame:UpdateSpecDropdownText()
                frame:UpdateDescriptionText()
            end
            info.notCheckable = true
            info.hasArrow = true
            info.menuList = "TANK"
            UIDropDownMenu_AddButton(info, level)

            -- 治疗专精（全选治疗）
            info.text = "治疗"
            info.func = function()
                wipe(frame.selectedSpecs)
                for _, spec in ipairs(frame.specs) do
                    if spec.role == "HEALER" then
                        frame.selectedSpecs[spec.id] = true
                    end
                end
                frame.lastSelectedRole = "HEALER"  -- 记录当前选择的角色类型
                frame:UpdateSpecDropdownText()
                frame:UpdateDescriptionText()
            end
            info.notCheckable = true
            info.hasArrow = true
            info.menuList = "HEALER"
            UIDropDownMenu_AddButton(info, level)

            -- 伤害输出专精（全选伤害）
            info.text = "伤害输出"
            info.func = function()
                wipe(frame.selectedSpecs)
                for _, spec in ipairs(frame.specs) do
                    if spec.role == "DAMAGER" then
                        frame.selectedSpecs[spec.id] = true
                    end
                end
                frame.lastSelectedRole = "DAMAGER"  -- 记录当前选择的角色类型
                frame:UpdateSpecDropdownText()
                frame:UpdateDescriptionText()
            end
            info.notCheckable = true
            info.hasArrow = true
            info.menuList = "DAMAGER"
            UIDropDownMenu_AddButton(info, level)
        elseif level == 2 then
            local roleID = menuList

            -- 二级菜单（具体专精）
            for _, spec in ipairs(frame.specs) do
                if spec.role == roleID then
                    info.text = format("|cff%.2x%.2x%.2x%s|r (|cff%.2x%.2x%.2x%s|r)",
                        spec.classColor.r*255, spec.classColor.g*255, spec.classColor.b*255, spec.name,
                        spec.classColor.r*255, spec.classColor.g*255, spec.classColor.b*255, spec.className
                    )
                    info.checked = frame.selectedSpecs[spec.id]
                    info.func = function(self)
                        -- 如果当前选择的角色类型和之前不同，则清空之前的选择
                        --if frame.lastSelectedRole ~= roleID then
                        --    wipe(frame.selectedSpecs)
                        --    frame.lastSelectedRole = roleID
                        --end
                        -- 切换当前专精的选中状态
                        frame.selectedSpecs[spec.id] = not frame.selectedSpecs[spec.id] or nil
                        frame:UpdateSpecDropdownText()
                        frame:UpdateDescriptionText()
                    end
                    info.isNotRadio = true  -- 允许多选
                    info.keepShownOnClick = true
                    info.hasCheck = true
                    info.icon = spec.icon
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end
    end)

    -- 更新下拉框显示文本
    function frame:UpdateSpecDropdownText()
        local count = 0
        local roleCounts = {TANK = 0, HEALER = 0, DAMAGER = 0}

        -- 统计选中的专精数量及角色分布
        for specID in pairs(self.selectedSpecs) do
            local spec = self.specsByID[specID]
            if spec then
                count = count + 1
                roleCounts[spec.role] = (roleCounts[spec.role] or 0) + 1
            end
        end

        -- 检查是否全选了某个角色类型且没有选择其他角色类型的专精
        local isFullRoleSelected = false
        local fullSelectedRole = nil

        for role, selectedCount in pairs(roleCounts) do
            -- 计算该角色类型的专精总数
            local totalForRole = 0
            for _, spec in ipairs(self.specs) do
                if spec.role == role then
                    totalForRole = totalForRole + 1
                end
            end

            -- 如果当前角色类型的选中数量等于总数且大于0
            if selectedCount == totalForRole and selectedCount > 0 then
                -- 检查是否有其他角色类型的专精被选中
                local hasOtherRoles = false
                for otherRole, otherCount in pairs(roleCounts) do
                    if otherRole ~= role and otherCount > 0 then
                        hasOtherRoles = true
                        break
                    end
                end

                -- 如果没有其他角色类型的专精被选中，则标记为全选
                if not hasOtherRoles then
                    isFullRoleSelected = true
                    fullSelectedRole = role
                    break
                end
            end
        end

        if count == 0 then
            UIDropDownMenu_SetText(specDropdown, "任意专精")
        elseif isFullRoleSelected then
            if fullSelectedRole == "TANK" then
                UIDropDownMenu_SetText(specDropdown, "坦克专精")
            elseif fullSelectedRole == "HEALER" then
                UIDropDownMenu_SetText(specDropdown, "治疗专精")
            elseif fullSelectedRole == "DAMAGER" then
                UIDropDownMenu_SetText(specDropdown, "伤害输出专精")
            end
        else
            UIDropDownMenu_SetText(specDropdown, format("已选%d个专精", count))
        end
    end

    local recruitmentDialog = CommunitiesFrame.RecruitmentDialog

    -- 设置下拉框文本
    frame.specDropdown = specDropdown
    frame:UpdateSpecDropdownText()

    -- 第五行：装等要求输入框
    local ilvlLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ilvlLabel:SetPoint("TOPLEFT", roleLabel, "BOTTOMLEFT", 0, -20)
    ilvlLabel:SetText("装等要求:")

    local ilvlEditBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    ilvlEditBox:SetSize(60, 20)
    ilvlEditBox:SetPoint("LEFT", ilvlLabel, "RIGHT", 10, 0)
    ilvlEditBox:SetAutoFocus(false)
    ilvlEditBox:SetNumeric(true)
    ilvlEditBox:SetMaxLetters(3)
    local playerIlvl = string.format("%.1f", GetAverageItemLevel())  -- 获取玩家平均装等
    local ilvlNum = recruitmentDialog.MinIlvlOnly.EditBox and recruitmentDialog.MinIlvlOnly.EditBox:GetText() or "0"
    ilvlEditBox:SetText(ilvlNum)
    ilvlEditBox:SetScript("OnTextChanged", function(_)
        local text = ilvlEditBox:GetText()
        if text ~= "" then
            local num = tonumber(text)
            local playerIlvlNum = tonumber(playerIlvl)
            if num and num > playerIlvlNum then
                ilvlEditBox:SetText(tostring(playerIlvl))
            end
        end
        frame:UpdateDescriptionText()
    end)

    -- 设置悬浮提示
    ilvlEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")  -- 设置提示框位置
        GameTooltip:AddLine("输入物品等级", 1, 1, 1)  -- 标题（白色）
        GameTooltip:AddLine("不得超过你的当前装备等级: " .. playerIlvl, 1, 0.82, 0)  -- 提示（金色）
        GameTooltip:Show()  -- 显示提示
    end)

    ilvlEditBox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()  -- 隐藏提示
    end)

    -- 第六行：两个复选框
    local maxLevelCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    maxLevelCheck:SetPoint("TOPLEFT", ilvlLabel, "BOTTOMLEFT", 0, -10)
    maxLevelCheck:SetSize(24, 24)
    maxLevelCheck.text = maxLevelCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    maxLevelCheck.text:SetPoint("LEFT", maxLevelCheck, "RIGHT", 5, 0)
    maxLevelCheck.text:SetText("只限满级")
    if recruitmentDialog.MaxLevelOnly.Button then
      maxLevelCheck:SetChecked(recruitmentDialog.MaxLevelOnly.Button:GetChecked())
    end

    maxLevelCheck:SetScript("OnClick", function(self)
        frame:UpdateDescriptionText()
    end)
    frame.maxLevelCheck = maxLevelCheck

    local autoUpdateCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    autoUpdateCheck:SetPoint("LEFT", maxLevelCheck, "RIGHT", 80, 0)
    autoUpdateCheck:SetSize(24, 24)
    autoUpdateCheck.text = autoUpdateCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    autoUpdateCheck.text:SetPoint("LEFT", autoUpdateCheck, "RIGHT", 5, 0)
    autoUpdateCheck.text:SetText("登录自动更新")
    autoUpdateCheck:SetChecked(true)
    frame.autoUpdateCheck = autoUpdateCheck

    autoUpdateCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")  -- 提示框显示在右侧
        GameTooltip:AddLine("自动更新选项")        -- 标题（可选）
        GameTooltip:AddLine(" ")                   -- 空行分隔
        GameTooltip:AddLine("|cffffffff 勾选|r：招募展示30天", 1, 1, 1)  -- 白色文字
        GameTooltip:AddLine("|cffffffff 不勾选|r：招募信息仅展示72小时", 1, 1, 1)     -- 白色文字
        GameTooltip:Show()
    end)

    autoUpdateCheck:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    local environmentalRebirthCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    environmentalRebirthCheck:SetPoint("LEFT", autoUpdateCheck, "RIGHT", 100, 0)
    environmentalRebirthCheck:SetSize(24, 24)
    environmentalRebirthCheck.text = environmentalRebirthCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    environmentalRebirthCheck.text:SetPoint("LEFT", environmentalRebirthCheck, "RIGHT", 5, 0)
    environmentalRebirthCheck.text:SetText("参与军团再临：幻境新生")
    frame.environmentalRebirthCheck = environmentalRebirthCheck

    -- 第七行：招募说明标签
    local descriptionLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    descriptionLabel:SetPoint("TOPLEFT", maxLevelCheck, "BOTTOMLEFT", 0, -10)
    descriptionLabel:SetText("招募说明:")

    -- 创建多行文本输入框（只读）
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", descriptionLabel, "BOTTOMLEFT", 0, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 40)
    scrollFrame:SetHeight(200)

    local descriptionEditBox = CreateFrame("EditBox", nil, scrollFrame)
    descriptionEditBox:SetMultiLine(true)
    descriptionEditBox:SetAutoFocus(false)
    descriptionEditBox:SetFontObject("GameFontNormal")
    descriptionEditBox:SetTextColor(1, 1, 1, 1)
    descriptionEditBox:SetTextInsets(8, 8, 8, 8)
    descriptionEditBox:SetWidth(scrollFrame:GetWidth())
    descriptionEditBox:EnableMouse(false)
    descriptionEditBox:SetEnabled(false)

    scrollFrame:SetScrollChild(descriptionEditBox)
    frame.descriptionEditBox = descriptionEditBox

    -- 修改更新描述文本函数
    function frame:UpdateDescriptionText()
        local socialText = ""
        for _, option in ipairs(socialOptions) do
            if option.value == self.selectedSocial then
                socialText = option.text
                break
            end
        end

        -- 获取选中的专精名称
        local specText = "任意专精"
        local selectedSpecs = {}
        local roleCounts = {TANK = 0, HEALER = 0, DAMAGER = 0}
        local isFullRoleSelected = false
        local fullSelectedRole = nil
        local hasOtherRoles = false

        -- 检查选择的专精和角色类型
        for specID in pairs(self.selectedSpecs) do
            local spec = self.specsByID[specID]
            if spec then
                table.insert(selectedSpecs, format("%s(%s)", spec.name, spec.className))
                roleCounts[spec.role] = (roleCounts[spec.role] or 0) + 1
            end
        end

        -- 判断是否只全选了某个角色类型
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

        if isFullRoleSelected then
            -- 如果全选了某个角色类型，直接显示角色类型名称
            if fullSelectedRole == "TANK" then
                specText = "坦克专精"
            elseif fullSelectedRole == "HEALER" then
                specText = "治疗专精"
            elseif fullSelectedRole == "DAMAGER" then
                specText = "伤害输出专精"
            end
        elseif #selectedSpecs > 0 then
            -- 否则显示具体选中的专精
            specText = table.concat(selectedSpecs, "、")
            if #selectedSpecs > 3 then
                -- 对前3个专精进行缩写转换
                local abbreviatedSpecs = {}
                for i = 1, math.min(3, #selectedSpecs) do
                    table.insert(abbreviatedSpecs, GetSpecAbbreviation(selectedSpecs[i]))
                end
                specText = format("%d个专精: %s", #selectedSpecs, table.concat(abbreviatedSpecs, "、").."等")
            else
                local abbreviatedSpecs = {}
                for _, spec in ipairs(selectedSpecs) do
                    table.insert(abbreviatedSpecs, GetSpecAbbreviation(spec))
                end
                specText = table.concat(abbreviatedSpecs, "、")
            end
        end

        local maxLevelOnly = maxLevelCheck:GetChecked()

        local selectedDaysDescription, checkedIndices  = AssociationPanel:GetSelectedDaysDescription()

        local indicesText = ""
        if checkedIndices and #checkedIndices > 0 then
          indicesText = "活动日:周"..table.concat(checkedIndices, ", ")
        else
          indicesText = "活动日:"..selectedDaysDescription
        end
          -- 构建招募说明文本
        local description = string.format(
            "%s 招募:%s。 "..
            "%s",
            indicesText,
            specText,
            maxLevelOnly and "只限满级玩家" or "欢迎所有等级玩家"
        )

        self.descriptionEditBox:SetText(description)
    end

    -- 初始更新招募说明
    frame:UpdateDescriptionText()

    -- 发布按钮
    local postButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    postButton:SetSize(120, 22)
    postButton:SetPoint("BOTTOM", frame, "BOTTOM", -70, 15)
    postButton:SetText("发布")
    local checkTimer
    postButton:SetScript("OnClick", function()
        local ilvlRequirement = tonumber(ilvlEditBox:GetText()) or 0
        local description = descriptionEditBox:GetText()
        local socialType = frame.selectedSocial or "RAID"
        local maxLevelOnly = maxLevelCheck:GetChecked()
        local autoUpdate = autoUpdateCheck:GetChecked()
        local environmentalCheck = environmentalRebirthCheck:GetChecked()
        local guildName = GetGuildInfo("player") or "未知公会"
        local selectedDaysDescription = self:GetSelectedDaysDescription()
        local _, faction = UnitFactionGroup("player")

        local clubId = C_Club.GetGuildClubId()
        -- 获取选择的专精
        local selectedSpecs = {}
        local specIDs = {}
        for specID in pairs(frame.selectedSpecs) do
            local spec = frame.specsByID[specID]
            table.insert(specIDs, tonumber(specID))
            if spec then
                table.insert(selectedSpecs, format("%s(%s)", spec.name, spec.className))
            end
        end

        local PersonalRated = {}

        for pvpRank = 1, 4 do
            local rating, _, _, _, _, _, _ = GetPersonalRatedInfo(pvpRank)
            table.insert(PersonalRated, rating)
        end

        local numMembers = GetNumGuildMembers()
        local membersAchievements = {}

        local NewcomerRecommendation = 0
        -- 遍历所有公会成员
        for i = 1, numMembers do
            local name, _, _, _, _, _, _, _, _, _, _, achievementPoints = GetGuildRosterInfo(i)
            if name and achievementPoints then
                local cleanName = name:match("^([^-]+%-[^-]+)") or name
                local regimentData = Profile.gdb.global.LocomotiveData[cleanName]
                if regimentData and regimentData.level > 0 then
                  NewcomerRecommendation = NewcomerRecommendation + 1
                end
                table.insert(membersAchievements, {
                    name = cleanName,
                    points = achievementPoints
                })
            end
        end

        -- 按成就点数降序排序
        table.sort(membersAchievements, function(a, b)
            return a.points > b.points
        end)

        -- 提取最高成就玩家
        local highestPlayer = membersAchievements[1] or {name = "无", points = 0}

        -- 提取前三名玩家
        local topThreePlayers = {}
        for i = 1, math.min(3, #membersAchievements) do
            table.insert(topThreePlayers, membersAchievements[i])
        end

        C_ClubFinder.SetRecruitmentSettings(12, true)
        C_ClubFinder.SetRecruitmentSettings(13, maxLevelOnly)

        C_ClubFinder.PostClub(
          clubId, ilvlRequirement, guildName, description,
          0, specIDs, Enum.ClubFinderRequestType.Guild, false
      )

      local attempts = 0
      local maxAttempts = 10

      if checkTimer then
          checkTimer:Cancel()
      end

      checkTimer = C_Timer.NewTicker(1, function()
          attempts = attempts + 1

          -- 尝试获取招募信息
          local clubInfo = C_ClubFinder.GetRecruitingClubInfoFromClubID(clubId)
          if clubInfo and clubInfo.clubFinderGUID then
              local clubFinderGUID = clubInfo.clubFinderGUID
              checkTimer:Cancel()

              -- 显示成功消息
              UIErrorsFrame:AddMessage("招募信息已成功处理", 0.0, 1.0, 0.0)
              local data = {
                show_days = autoUpdate and 30 or 3,
                guild_id = clubId,
                guild_type = socialType,
                realm_name = GetGuildMasterRealm(),
                guild_name = GetGuildInfo("player"),
                note = description,
                other_info = {
                  mounting = ilvlRequirement,
                  AssociationNum = GetNumGuildMembers(),
                  LeaderName = UnitName("player"),
                  Faction = faction,
                  PersonalRated = PersonalRated,
                  AverageItemLevel = GetAverageItemLevel(),
                  DifficultyName = frame.selectedDifficultyText,
                  RecruitmentTypeText = recruitmentTypeText,
                  EncounterProgress = frame.encountersNum,
                  HighestPlayerPoints = highestPlayer.points,
                  TopThreePlayers = topThreePlayers,
                  NewcomerRecommendation = NewcomerRecommendation,
                  ClubFinderGUID = clubFinderGUID,
                  SelectedSpecs = selectedSpecs,
                  MythicPlusScore = GetMythicPlusScore(),
                  StartTime = startTimeInput:GetText(),
                  EndTime = endTimeInput:GetText(),
                  SelectedDaysDescription = selectedDaysDescription,
                  EnvironmentalRebirthCheck = environmentalCheck
                }
              }
              Logic:SendServer("CRGD", data)
        elseif attempts >= maxAttempts then
          print("超时：无法获取招募信息")
          checkTimer:Cancel()
          UIErrorsFrame:AddMessage("获取招募信息超时", 1.0, 0.0, 0.0)
        end
      end)

        -- 发布后隐藏窗口
        frame:Hide()
    end)

    -- 关闭按钮
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeButton:SetSize(120, 22)
    closeButton:SetPoint("BOTTOM", frame, "BOTTOM", 70, 15)
    closeButton:SetText("关闭")
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- 确保窗口显示时置顶
    frame:SetScript("OnShow", function()
        frame:Raise()
    end)

    -- 添加ESC键关闭支持
    tinsert(UISpecialFrames, frame:GetName())

    -- 显示窗口
    frame:Hide()
end

function AssociationPanel:GetSelectedDays()
    if not self.dayCheckButtons or #self.dayCheckButtons == 0 then
      return
    end
    local selectedDays = {}
    for i = 1, 7 do
        if self.dayCheckButtons[i]:GetChecked() then
            table.insert(selectedDays, i)
        end
    end
    return selectedDays
end

function AssociationPanel:SetSelectedDays(days)
    for i = 1, 7 do
        self.dayCheckButtons[i]:SetChecked(false) -- 先全部取消选中
    end

    for _, day in ipairs(days) do
        if day >= 1 and day <= 7 then
            self.dayCheckButtons[day]:SetChecked(true)
        end
    end
end

function AssociationPanel:GetSelectedDaysDescription()
    local selected = self:GetSelectedDays()
    local count = #selected

    if count == 7 then
        return "全周"
    end

    if count == 5 then
        local isAllWeekdays = true
        for i = 6, 7 do -- 检查是否包含周末
            if self.dayCheckButtons[i]:GetChecked() then
                isAllWeekdays = false
                break
            end
        end
        if isAllWeekdays then
            return "仅工作日"
        end
    end

    -- 仅周末（周六和周日）
    if count == 2 then
        if self.dayCheckButtons[6]:GetChecked() and self.dayCheckButtons[7]:GetChecked() then
            return "仅周末"
        end
    end

    local displayText = ""
    local checkedIndices = {}
    for i = 1, 7 do
        if self.dayCheckButtons[i]:GetChecked() then
            if displayText ~= "" then
                displayText = displayText .. ","
            end
            displayText = displayText .. self.dayNames[i]
            table.insert(checkedIndices, i)
        end
    end

    return displayText, checkedIndices
end

-- 显示申请对话框
function AssociationPanel:ShowApplicationDialog()
    if not self.applicationDialog then
        self:CreateApplicationWindow()
    end

    -- 重置对话框状态
    self.applicationDialog.editBox:SetText("")
    self.applicationDialog.selectedSpecID = nil

    -- 显示对话框
    self.applicationDialog:Show()
end

function AssociationPanel:CreateApplicationWindow()
    -- 创建主窗口框架
    self.applicationDialog = CreateFrame("Frame", "GuildApplicationFrame", UIParent, "BasicFrameTemplateWithInset")
    local frame = self.applicationDialog
    frame:SetSize(350, 350)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- 设置标题
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 0)
    frame.title:SetText("申请加入公会")

    -- 申请说明文字
    frame.instructions = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.instructions:SetPoint("TOP", 0, -30)
    frame.instructions:SetText("请填写申请信息并选择你的专精")

    -- 创建输入框背景
    frame.editBoxBackground = CreateFrame("Frame", nil, frame)
    frame.editBoxBackground:SetSize(300, 100)
    frame.editBoxBackground:SetPoint("TOP", 0, -60)

    -- 使用纹理创建背景
    frame.editBoxBackground.bg = frame.editBoxBackground:CreateTexture(nil, "BACKGROUND")
    frame.editBoxBackground.bg:SetAllPoints()
    frame.editBoxBackground.bg:SetColorTexture(0.1, 0.1, 0.1, 1)  -- 半透明黑色背景

    -- 使用纹理创建边框
    frame.editBoxBackground.border = frame.editBoxBackground:CreateTexture(nil, "BORDER")
    frame.editBoxBackground.border:SetAllPoints()
    frame.editBoxBackground.border:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
    frame.editBoxBackground.border:SetVertexColor(0.4, 0.4, 1)  -- 灰色边框

    -- 创建多行滚动输入框
    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame.editBoxBackground, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetSize(280, 90)
    frame.scrollFrame:SetPoint("TOP", 0, -5)

    frame.editBox = CreateFrame("EditBox", nil, frame.scrollFrame)
    frame.editBox:SetSize(280, 1000)
    frame.editBox:SetMultiLine(true)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:SetFontObject("GameFontHighlight")
    frame.editBox:SetTextInsets(8, 8, 8, 8)
    frame.editBox:SetText("")
    frame.scrollFrame:SetScrollChild(frame.editBox)

    frame.clickArea = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.clickArea:SetAllPoints(frame.scrollFrame)
    frame.clickArea:SetScript("OnMouseDown", function()
        frame.editBox:SetFocus()
    end)

    -- 专精选择多选框
    frame.specCheckBoxes = {}
    frame.selectedSpecs = {}

    local specCheckBoxContainer = CreateFrame("Frame", nil, frame)
    specCheckBoxContainer:SetSize(280, 120)
    specCheckBoxContainer:SetPoint("TOP", frame.editBoxBackground, "BOTTOM", 0, -10)

    local scrollFrame = CreateFrame("ScrollFrame", nil, specCheckBoxContainer, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(280, 120)
    scrollFrame:SetPoint("TOPLEFT")

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(280, 120)
    scrollFrame:SetScrollChild(scrollChild)

    -- 添加专精复选框
    local yOffset = 0
    for i = 1, GetNumSpecializations() do
        local specID, specName = GetSpecializationInfo(i)

        local checkBox = CreateFrame("CheckButton", nil, scrollChild, "UICheckButtonTemplate")
        checkBox:SetPoint("TOPLEFT", 10, -yOffset)
        checkBox:SetSize(25, 25)
        checkBox.specID = specID

        local label = checkBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", checkBox, "RIGHT", 5, 0)
        label:SetText(specName)

        checkBox:SetScript("OnClick", function(self)
            if self:GetChecked() then
                frame.selectedSpecs[specID] = true
            else
                frame.selectedSpecs[specID] = nil
            end
        end)

        frame.specCheckBoxes[i] = checkBox
        yOffset = yOffset + 30
    end

    scrollChild:SetHeight(yOffset)

    -- 申请按钮
    frame.applyButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.applyButton:SetSize(100, 25)
    frame.applyButton:SetPoint("BOTTOMLEFT", 40, 20)
    frame.applyButton:SetText("申请")
    frame.applyButton:SetScript("OnClick", function()
        self:SendGuildApplication()
    end)

    -- 取消按钮
    frame.cancelButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.cancelButton:SetSize(100, 25)
    frame.cancelButton:SetPoint("BOTTOMRIGHT", -40, 20)
    frame.cancelButton:SetText("取消")
    frame.cancelButton:SetScript("OnClick", function() frame:Hide() end)

    frame:Hide()
end

function AssociationPanel:ShowApplicationWindow()
    if not self.applicationFrame then
        self:CreateApplicationWindow()
    end

    -- 重置状态
    self.applicationFrame.editBox:SetText("")
    self.applicationFrame.selectedSpecID = nil
    UIDropDownMenu_SetText(self.applicationFrame.specDropdown, "选择你的专精")

    -- 显示窗口
    self.applicationFrame:Show()
end

function AssociationPanel:SendGuildApplication()
    local clubFinderGUID = self.clubFinderGUID

    if not clubFinderGUID then
        print("错误：未选择公会")
        return
    end

    local applicationText = self.applicationDialog.editBox:GetText()
    local selectedSpecs = self.applicationDialog.selectedSpecs or {}

    -- 检查是否至少选择了一个专精
    local specIDs = {}
    local hasSelectedSpec = false
    for specID, selected in pairs(selectedSpecs) do
        if selected then
            hasSelectedSpec = true
            table.insert(specIDs, tonumber(specID))
        end
    end

    if not hasSelectedSpec then
        print("请选择你的专精")
        return
    end

    -- 清理文本中的换行符
    local cleanText = applicationText:gsub("\n", " ")

    -- 发送申请
    if C_ClubFinder and C_ClubFinder.RequestMembershipToClub then
        C_ClubFinder.RequestMembershipToClub(clubFinderGUID, cleanText or "", specIDs)
        LogStatistics:InsertLog({ time(), "wow_recruit_tab", {action=3,guild_id=self.associationID or '', prefer=self.ActivityTendencyType} })
        print("申请已发送")
        self.applicationDialog:Hide()
    else
        print("当前魔兽世界版本不支持此功能")
    end
end

function AssociationPanel:UpdateAddAssociationButton(activity)
    if not activity then return end
    self.clubFinderGUID = activity.ClubFinderGUID
    self.associationID = activity.AssociationID
    local hasSelection = self.IgnoreList:GetSelected()
    self.AddAssociationIgnore:SetEnabled(hasSelection and self.clubFinderGUID and not IsInGuild())
    if hasSelection and self.clubFinderGUID and not IsInGuild() then
        self.AddAssociationIgnore:SetTooltip(nil) -- 清除提示
    else
      if IsInGuild() then
          self.AddAssociationIgnore:SetTooltip('已有公会的玩家无法申请加入')
      else
          self.AddAssociationIgnore:SetTooltip('请选择一个搜索结果')
      end
    end
end

function AssociationPanel:SendAssociationSQGDL(pageNum)
    if self.SearchingAssociationBlocker then
      self.SearchingAssociationBlocker:Show()
    end
    if self.NoResultAssociationBlocker then
      self.NoResultAssociationBlocker:Hide()
    end
    if self.ActivityDropdown then
      self.ActivityDropdown:SetEnabled(false)
    end
    if self.cooldownActive then return end
    local data = {
        guild_type = self.ActivityTendencyType,
        realm_name = self.ServerNameType,
        fuzzy = self.SearchBoxText or "",
        page = pageNum or 1,
        size = PAGE_SIZE
    }
    Logic:SendServer("CQGDL", data)
    self:SendAssociationCQGD()
    -- 开始冷却
    self.cooldownActive = true
    self.cooldownRemaining = 3
    if self.RefreshButton then
        self.RefreshButton:Disable()
    end
    if self.firstPageButton then
        self.firstPageButton:Disable()
    end
    if self.nextPageButton then
        self.nextPageButton:Disable()
    end
end

function AssociationPanel:SendAssociationCQGD()
    local guildID = C_Club.GetGuildClubId()
    if guildID == nil then
        return
    end
    local data = { guild_id = guildID }
    Logic:SendServer("CQGD", data)
end

function AssociationPanel:ToggleActivityMenu(anchor, activity)
  if not self.isWhiteRole then
    GUI:ToggleMenu(anchor, {
      {
        text = activity.AssociationName, isTitle = true, notCheckable = true
      },
      {
        text = "与公会发布者私聊",
        func = function()
          ChatFrame_SendTell((format("%s-%s", activity.LeaderName, activity.serverName)))
        end,
        tooltipTitle = WHISPER,
        tooltipText = "与公会发布者进行悄悄话",
        tooltipOnButton = true,
        tooltipWhileDisabled = true,
      },
      {
        text = '复制发布者名字',
        func = function()
          local name = format("%s-%s", activity.LeaderName, activity.serverName)
          print(name)
          GUI:CallUrlDialog(name)
        end,
      },
      { text = CANCEL },
    }, 'cursor')
    return
  end

  GUI:ToggleMenu(anchor, {
    {
      text = activity.AssociationName, isTitle = true, notCheckable = true
    },
    {
      text = "与公会发布者私聊",
      func = function()
        ChatFrame_SendTell((format("%s-%s", activity.LeaderName, activity.serverName)))
      end,
      tooltipTitle = WHISPER,
      tooltipText = "与公会发布者进行悄悄话",
      tooltipOnButton = true,
      tooltipWhileDisabled = true,
    },
    {
      text = '复制发布者名字',
      func = function()
        local name = format("%s-%s", activity.LeaderName, activity.serverName)
        print(name)
        GUI:CallUrlDialog(name)
      end,
    },
    {
      text = "删除公会",
      func = function()
        Logic:SendServer("CDGD", {guild_id = activity.AssociationID})
      end,
    },
    {
      text = "禁言公会1天",
      func = function()
        Logic:SendServer("CQBGD", {guild_id = activity.AssociationID, days = 1})
      end,
    },
    {
      text = "禁言公会3天",
      func = function()
        Logic:SendServer("CQBGD", {guild_id = activity.AssociationID, days = 3})
      end,
    },
    {
      text = "禁言公会7天",
      func = function()
        Logic:SendServer("CQBGD", {guild_id = activity.AssociationID, days = 7})
      end,
    },
    {
      text = "禁言公会30天",
      func = function()
        Logic:SendServer("CQBGD", {guild_id = activity.AssociationID, days = 30})
      end,
    },
    { text = CANCEL },
  }, 'cursor')
end

function AssociationPanel:MEETINGHORN_SQGD(_, item)
    self:CreateRecruitmentWindow()
    local other_info = item.other_info

    -- 设置社交倾向
    if item.guild_type and self.recruitmentFrame.socialDropdown then
        -- 找到对应的文本
        local socialText = ""
        for _, option in ipairs(socialOptions) do
            if option.value == item.guild_type then
                socialText = option.text
                break
            end
        end

        UIDropDownMenu_SetSelectedValue(self.recruitmentFrame.socialDropdown, item.guild_type)
        UIDropDownMenu_SetText(self.recruitmentFrame.socialDropdown, socialText)
        self.recruitmentFrame.selectedSocial = item.guild_type

        -- 根据社交倾向显示或隐藏相关设置
        if item.guild_type == "RAID" then
            if self.recruitmentFrame.settingsFrame then
                self.recruitmentFrame.settingsFrame:Show()
            end
            if self.recruitmentFrame.socialTooltip then
                self.recruitmentFrame.socialTooltip:Hide()
            end
        else
            if self.recruitmentFrame.settingsFrame then
                self.recruitmentFrame.settingsFrame:Hide()
            end
            if self.recruitmentFrame.socialTooltip then
                self.recruitmentFrame.socialTooltip:Show()
                if item.guild_type == "DUNGEON" then
                    self.recruitmentFrame.socialTooltip:SetText("公会偏好将会按照发布者当前的史诗钥石地下城分数进行排序，若有变动可手动更新")
                elseif item.guild_type == "PVP" then
                    self.recruitmentFrame.socialTooltip:SetText("公会偏好将会按照发布者当前的评级最高分数进行排序，若有变动可手动更新")
                else -- SOCIAL 和 RP 及其他选项
                    self.recruitmentFrame.socialTooltip:SetText("公会偏好将会按照公会人员最高的成就点数进行排序，若有变动可手动更新")
                end
            end
        end

      -- 根据社交倾向显示或隐藏相关设置
      if item.guild_type == "RAID" then
        if self.recruitmentFrame.settingsFrame then
          self.recruitmentFrame.settingsFrame:Show()
        end
        if self.recruitmentFrame.socialTooltip then
          self.recruitmentFrame.socialTooltip:Hide()
        end
      else
        if self.recruitmentFrame.settingsFrame then
          self.recruitmentFrame.settingsFrame:Hide()
        end
        if self.recruitmentFrame.socialTooltip then
          self.recruitmentFrame.socialTooltip:Show()
          -- 设置不同社交倾向的提示文本
          if item.guild_type == "DUNGEON" then
            self.recruitmentFrame.socialTooltip:SetText("公会偏好将会按照发布者当前的史诗钥石地下城分数进行排序，若有变动可手动更新")
          elseif item.guild_type == "PVP" then
            self.recruitmentFrame.socialTooltip:SetText("公会偏好将会按照发布者当前的评级最高分数进行排序，若有变动可手动更新")
          else -- SOCIAL 和 RP 及其他选项
            self.recruitmentFrame.socialTooltip:SetText("公会偏好将会按照公会人员最高的成就点数进行排序，若有变动可手动更新")
          end
        end
      end
    end

    -- 设置专精选择
    if self.recruitmentFrame.selectedSpecs then
      wipe(self.recruitmentFrame.selectedSpecs)
      if other_info.SelectedSpecs then
        for _, specName in ipairs(other_info.SelectedSpecs) do
          for _, spec in ipairs(self.recruitmentFrame.specs) do
            if format("%s(%s)", spec.name, spec.className) == specName then
              self.recruitmentFrame.selectedSpecs[spec.id] = true
              break
            end
          end
        end
      end
      self.recruitmentFrame:UpdateSpecDropdownText()
    end

    -- 设置装等要求
    if self.recruitmentFrame.ilvlEditBox then
      self.recruitmentFrame.ilvlEditBox:SetText(tostring(other_info.mounting or 0))
    end

    -- 设置满级限制
    if self.recruitmentFrame.maxLevelCheck then
      local isMaxLevelOnly = item.note and item.note:find("只限满级玩家")
      self.recruitmentFrame.maxLevelCheck:SetChecked(isMaxLevelOnly)
    end

    if self.recruitmentFrame.environmentalRebirthCheck then
      local isEnvironmentalRebirthCheck = item.EnvironmentalRebirthCheck
      self.recruitmentFrame.environmentalRebirthCheck:SetChecked(isEnvironmentalRebirthCheck)
    end

    -- 设置活动时间
    if other_info.StartTime and self.recruitmentFrame.startTimeInput then
      self.recruitmentFrame.startTimeInput:SetText(other_info.StartTime)
    end
    if other_info.EndTime and self.recruitmentFrame.endTimeInput then
      self.recruitmentFrame.endTimeInput:SetText(other_info.EndTime)
    end

    -- 设置副本难度和进度
    if other_info.DifficultyName and self.recruitmentFrame.raidDifficultyDropdown then
      UIDropDownMenu_SetText(self.recruitmentFrame.raidDifficultyDropdown, other_info.DifficultyName)
      self.recruitmentFrame.selectedDifficultyText = other_info.DifficultyName
    end

    if other_info.EncounterProgress and self.recruitmentFrame.raidProgressInput and self.recruitmentFrame.encountersNum then
       self.recruitmentFrame.encountersNum = other_info.EncounterProgress
       self.recruitmentFrame.raidProgressInput:SetText(tostring(other_info.EncounterProgress))
    end

    -- 设置招募类型
    if other_info.RecruitmentTypeText and self.recruitmentFrame.recruitmentTypeDropdown then
      UIDropDownMenu_SetText(self.recruitmentFrame.recruitmentTypeDropdown, other_info.RecruitmentTypeText)
      self.recruitmentFrame.recruitmentTypeText = other_info.RecruitmentTypeText
    end

    -- 设置活动日期
    if other_info.SelectedDaysDescription then
      local days = {}
      -- 解析描述中的星期几
      local dayMap = {
        ["一"] = 1, ["二"] = 2, ["三"] = 3, ["四"] = 4,
        ["五"] = 5, ["六"] = 6, ["日"] = 7, ["天"] = 7
      }

      for day, num in pairs(dayMap) do
        if other_info.SelectedDaysDescription:find("周"..day) then
          table.insert(days, num)
        end
      end

      -- 特殊情况处理
      if other_info.SelectedDaysDescription == "全周" then
        days = {1, 2, 3, 4, 5, 6, 7}
      elseif other_info.SelectedDaysDescription == "仅工作日" then
        days = {1, 2, 3, 4, 5}
      elseif other_info.SelectedDaysDescription == "仅周末" then
        days = {6, 7}
      end

      if #days > 0 then
        self:SetSelectedDays(days)
      end
    end

    -- 更新描述文本
    self.recruitmentFrame:UpdateDescriptionText()
end

function AssociationPanel:MEETINGHORN_SQGDW(_, data)
    self.isWhiteRole = data.is_white
end

function AssociationPanel:MEETINGHORN_SQGDL(_, data, len)
  if len > 0 then
      data = Base64:DeCode(data)
      data = LibDeflate:DecompressDeflate(data)
      local isDeserialize
      isDeserialize, data = AceSerializer:Deserialize(data)
      if not isDeserialize then
          print('公会数据更新失败。')
          return
      end
  end
  if Profile.cdb.profile.Association and #Profile.cdb.profile.Association.IgnoreList > 0 then
    wipe(Profile.cdb.profile.Association.IgnoreList)
  end

  for i, item in ipairs(data.records) do
      local other_info = item.other_info
      table.insert(Profile.cdb.profile.Association.IgnoreList, {
          AssociationNumID = i,
          AssociationName = item.guild_name,
          AssociationNum = other_info.AssociationNum,
          AssociationType = item.realm_name,
          mounting = other_info.mounting,
          AssociationID = item.guild_id,
          ActivityTendencyType = item.guild_type,
          explain = item.note,
          serverName = item.realm_name,
          LeaderName = other_info.LeaderName,
          Faction = other_info.Faction,
          PersonalRated = other_info.PersonalRated,
          AverageItemLevel = other_info.AverageItemLevel,
          DifficultyName = other_info.DifficultyName,
          EncounterProgress = other_info.EncounterProgress,
          MaxEncounters = MaxEncounters,
          HighestPlayerPoints = other_info.HighestPlayerPoints,
          TopThreePlayers = other_info.TopThreePlayers,
          NewcomerRecommendation = other_info.NewcomerRecommendation,
          ClubFinderGUID = other_info.ClubFinderGUID,
          SelectedSpecs = other_info.SelectedSpecs,
          MythicPlusScore = other_info.MythicPlusScore,
          StartTime = other_info.StartTime,
          EndTime = other_info.EndTime,
          SelectedDaysDescription = other_info.SelectedDaysDescription,
          RecruitmentTypeText = other_info.RecruitmentTypeText,
          EnvironmentalRebirthCheck = other_info.EnvironmentalRebirthCheck,
      })
  end

    -- 更新分页按钮显示状态
    if #Profile.cdb.profile.Association.IgnoreList == PAGE_SIZE then
        self.nextPageButton:Show()
    else
        self.nextPageButton:Hide()
    end

    if currentPage > 1 then
        self.firstPageButton:Show()
    else
        self.firstPageButton:Hide()
    end

    self:UpdateAddAssociationButton({})
    self.IgnoreList:Refresh()
    self.SearchingAssociationBlocker:Hide()
    self.NoResultAssociationBlocker:SetShown(#Profile.cdb.profile.Association.IgnoreList == 0)
end
