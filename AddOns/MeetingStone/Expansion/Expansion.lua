BuildEnv(...)

Expansion = Addon:NewModule('Expansion', 'AceEvent-3.0')

local function CreateMemberFilter(self, point, MainPanel, x, text, DB_Name, tooltip)
  if Profile.gdb.global.UIMemory[DB_Name] == nil then
    Profile.gdb.global.UIMemory[DB_Name] = false
  end

  local TCount = GUI:GetClass('CheckBox'):New(self)
  do
    TCount:SetSize(24, 24)
    TCount:SetPoint(point, MainPanel, x, 3)
    TCount:SetText(text)
    TCount:SetChecked(Profile.gdb.global.UIMemory[DB_Name])
    TCount:SetScript('OnClick', function()
      Profile.gdb.global.UIMemory[DB_Name] = not Profile.gdb.global.UIMemory[DB_Name]
      self.ActivityList:Refresh()
    end)
  end
  if tooltip then
    GUI:Embed(TCount, 'Tooltip')
    TCount:SetTooltip("说明", tooltip)
    TCount:SetTooltipAnchor("ANCHOR_BOTTOMRIGHT")
  end
end

local function CreateScoreFilter(self, text, score)
  local DB_Name = 'SCORE'
  if Profile.gdb.global.UIMemory[DB_Name] == nil then
    Profile.gdb.global.UIMemory[DB_Name] = false
  end

  local filterScoreCheckBox = GUI:GetClass('CheckBox'):New(self)
  do
    filterScoreCheckBox:SetSize(24, 24)
    filterScoreCheckBox:SetPoint('TOPLEFT', self.SearchBox, 'TOPLEFT', 0, 26)
    filterScoreCheckBox:SetText(text)
    filterScoreCheckBox:SetChecked(Profile.gdb.global.UIMemory[DB_Name])
    filterScoreCheckBox:SetScript("OnClick", function()
      if Profile.gdb.global.UIMemory[DB_Name] then
        Profile.gdb.global.UIMemory[DB_Name] = nil
      else
        Profile.gdb.global.UIMemory[DB_Name] = score
      end
      self.ActivityList:Refresh()
    end)
    GUI:Embed(filterScoreCheckBox, 'Tooltip')
    filterScoreCheckBox:SetTooltip("说明", "过滤队长是0分的队伍, 可能有助于减少广告")
    filterScoreCheckBox:SetTooltipAnchor("ANCHOR_TOPLEFT")
  end
end

function Expansion:OnInitialize()
  -- Initialize Profile.gdb.global.UIMemory if not present
  if not Profile.gdb.global.UIMemory or not Profile.gdb.global.UIMemory.IGNORE_LIST then
    Profile.gdb.global.UIMemory = {}
    Profile.gdb.global.UIMemory.IGNORE_LIST = {}
  end

  -- Transfer old filters to the new ignore list
  if Profile.gdb.global.UIMemory.filters then
    for k, v in pairs(Profile.gdb.global.UIMemory.filters) do
      table.insert(Profile.gdb.global.UIMemory.IGNORE_LIST, {
        leader = k,
        time = v,
        dep = '旧数据结构转化',
      })
    end
    Profile.gdb.global.UIMemory.filters = nil
  end

  -- Clean the ignore list
  for i, v in ipairs(Profile.gdb.global.UIMemory.IGNORE_LIST) do
    if v.leader == nil then
      table.remove(Profile.gdb.global.UIMemory.IGNORE_LIST, i)
    end
    v.titles = nil
    if v.time == true then
      v.time = ''
    end
  end

  -- Sort the ignore list
  table.sort(Profile.gdb.global.UIMemory.IGNORE_LIST, function(a, b)
    if a.time == b.time then
      return a.leader < b.leader
    end
    if type(a.time) == type(b.time) and type(a.time) == 'string' then
      return a.time > b.time
    end
    return type(a.time) == 'string'
  end)

  -- Define additional defaults if necessary
  if Profile.gdb.global.UIMemory.IGNORE_TIPS_LOG == nil then
    Profile.gdb.global.UIMemory.IGNORE_TIPS_LOG = true
  end

  if Profile.gdb.global.UIMemory.FILTER_MULTY == nil then
    Profile.gdb.global.UIMemory.FILTER_MULTY = true
  end

  -- Additional initialization logic here

  -- Initialize the BrowsePanel
  BrowsePanel:EX_INIT()
end

function BrowsePanel:EX_INIT()
  self:CreateExSearchPanel()
  self:CreateExSearchButton()
end

function BrowsePanel:CreateExSearchPanel()
  -- body
  local ExSearchPanel = CreateFrame('Frame', nil, MainPanel, 'SimplePanelTemplate')
  do
    GUI:Embed(ExSearchPanel, 'Refresh')
    ExSearchPanel:SetSize(322, MainPanel:GetHeight())
    ExSearchPanel:SetPoint('TOPLEFT', MainPanel, 'TOPRIGHT', 0, 0)
    ExSearchPanel:SetFrameLevel(self.ActivityList:GetFrameLevel() + 5)
    ExSearchPanel:EnableMouse(true)

    local Label = ExSearchPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    do
      Label:SetPoint('TOP', 0, -10)
      Label:SetText('赛季大秘境')
    end
    local CloseButton = CreateFrame('Button', nil, ExSearchPanel, 'UIPanelCloseButton')
    do
      CloseButton:SetSize(25, 25) -- 设置按钮大小
      CloseButton:SetPoint('TOPRIGHT', ExSearchPanel, 'TOPRIGHT', -5, -5) -- 放置在右上角
      CloseButton:SetScript('OnClick', function()
        ExSearchPanel:Hide() -- 点击后隐藏面板
      end)
    end
  end
  self.ExSearchPanel = ExSearchPanel
  ExSearchPanel:SetShown(false)

  self.MD = {}

  function containsValue(array, value)
    for i, v in ipairs(array) do
      if v == value then
        return true, i
      end
    end
    return false, i
  end

  function createCheckBox(index, text, checked, value, cbEvent, cbFunc, isNoPosition)
    local Box = Addon:GetClass('CheckBox'):New(ExSearchPanel.Inset)
    Box.Check:SetText(text)
    Box.Check:SetChecked(checked)
    Box.dataValue = value
    Box:SetCallback(cbEvent, function(box, ...)
      if cbFunc then
        cbFunc(box, ...)
      end
    end)
    if index == 1 then
      Box:SetPoint('TOPLEFT', 10, -10)
      Box:SetPoint('TOPRIGHT', -10, -10)
    else
      if isNoPosition then
        Box:ClearAllPoints()
      elseif index == #OTHER_DUNGEONS + 1 then
        Box:SetPoint('TOPLEFT', self.MD[index - 1], 'BOTTOMLEFT', 0, -10)
        Box:SetPoint('TOPRIGHT', self.MD[index - 1], 'BOTTOMRIGHT', 0, -10)
      else
        Box:SetPoint('TOPLEFT', self.MD[index - 1], 'BOTTOMLEFT')
        Box:SetPoint('TOPRIGHT', self.MD[index - 1], 'BOTTOMRIGHT')
      end
    end
    table.insert(self.MD, Box)

    return Box
  end

  function createFilterBox(index, text, min, max, minVue, MaxVue, cbEvent, cbFunc, checked, isMultipleChoice)
    local Box = Addon:GetClass('FilterBox'):New(ExSearchPanel.Inset)
    Box.Check:SetText(text)
    Box.MinBox:SetMinMaxValues(min, max)
    Box.MaxBox:SetMinMaxValues(min, max)
    Box.MinBox:SetText(minVue)
    Box.MaxBox:SetText(MaxVue)

    if isMultipleChoice then
      Box.Text:Hide()
      Box.MaxBox:Hide()
    end
    Box.Check:SetChecked(checked)
    Box:SetCallback(cbEvent, cbFunc)
    Box:SetPoint('TOPLEFT', self.MD[index - 1], 'BOTTOMLEFT', 0, -5)
    Box:SetPoint('TOPRIGHT', self.MD[index - 1], 'BOTTOMRIGHT', 0, -5)
    table.insert(self.MD, Box)
    return Box
  end

  for i, id in ipairs(OTHER_DUNGEONS) do
    if OTHER_ACTIVITYS[i] then
      local actInfo = C_LFGList.GetActivityInfoTable(OTHER_ACTIVITYS[i])
      if actInfo then
        local name = actInfo.fullName
        --local checkBoxName = actInfo.fullName:gsub("%s*%（史诗钥石%）%s*", "")
        local savedState = Profile.cdb.profile.dungeonFilters ~= nil and Profile.cdb.profile.dungeonFilters[name] ~= nil and Profile.cdb.profile.dungeonFilters[name] or false

        createCheckBox(i, name, savedState, id, 'OnChanged', function(box)
          if not Profile.cdb.profile.dungeonFilters then
            Profile.cdb.profile.dungeonFilters = {}
          end
          Profile.cdb.profile.dungeonFilters[name] = box.Check:GetChecked()
          if not box.Check:GetChecked() then
            local clear = true
            for k, v2 in pairs(Profile.cdb.profile.dungeonFilters) do
              if v2 then
                clear = false
                break
              end
            end
            if clear then
              Profile.cdb.profile.dungeonFilters = nil
            end
          end
          self.ActivityList:Refresh()
        end)
      end
    end
  end

  function roleFunc(box)
    local value = box.Check:GetChecked()
    local key = box.dataValue
    -- 保存状态到数据库
    if not Profile.cdb.profile.roleFilters then
      Profile.cdb.profile.roleFilters = {}
    end
    Profile.cdb.profile.roleFilters[key] = value
    self.ActivityList:Refresh()
  end

  local haveHealer = Profile.cdb.profile.roleFilters ~= nil and Profile.cdb.profile.roleFilters.haveHealer ~= nil and Profile.cdb.profile.roleFilters.haveHealer or false
  self.haveHealerBox = createCheckBox(#self.MD + 1, '有治疗', haveHealer, "haveHealer", 'OnChanged', function(box)
    if box.Check:GetChecked() and self.noHealerBox.Check:GetChecked() then
      Profile.cdb.profile.roleFilters.noHealer = false
      self.noHealerBox.Check:SetChecked(false)
    end
    roleFunc(box)
  end, true)
  self.haveHealerBox:SetSize(70, 20)
  self.haveHealerBox:SetPoint('TOPLEFT', self.MD[#self.MD - 1], 'BOTTOMLEFT', 0, -10)

  local noHealer = Profile.cdb.profile.roleFilters ~= nil and Profile.cdb.profile.roleFilters.noHealer ~= nil and Profile.cdb.profile.roleFilters.noHealer or false
  self.noHealerBox = createCheckBox(#self.MD + 1, '缺治疗', noHealer, "noHealer", 'OnChanged', function(box)
    if box.Check:GetChecked() and self.haveHealerBox.Check:GetChecked() then
      Profile.cdb.profile.roleFilters.haveHealer = false
      self.haveHealerBox.Check:SetChecked(false)
    end
    roleFunc(box)
  end, true)
  self.noHealerBox:SetSize(70, 20)
  self.noHealerBox:SetPoint('LEFT', self.haveHealerBox, 'RIGHT', 10, 0)

  local haveTank = Profile.cdb.profile.roleFilters ~= nil and Profile.cdb.profile.roleFilters.haveTank ~= nil and Profile.cdb.profile.roleFilters.haveTank or false
  self.haveTankBox = createCheckBox(#self.MD + 1, '有坦克', haveTank, "haveTank", 'OnChanged', function(box)
    if box.Check:GetChecked() and self.haveTankBox.Check:GetChecked() then
      Profile.cdb.profile.roleFilters.noTank = false
      self.noTankBox.Check:SetChecked(false)
    end
    roleFunc(box)
  end, true)
  self.haveTankBox:SetSize(70, 20)
  self.haveTankBox:SetPoint('TOPLEFT', self.haveHealerBox, 'BOTTOMLEFT', 0, -5)

  local noTank = Profile.cdb.profile.roleFilters ~= nil and Profile.cdb.profile.roleFilters.noTank ~= nil and Profile.cdb.profile.roleFilters.noTank or false
  self.noTankBox = createCheckBox(#self.MD + 1, '缺坦克', noTank, "noTank", 'OnChanged', function(box)
    if box.Check:GetChecked() and self.noTankBox.Check:GetChecked() then
      Profile.cdb.profile.roleFilters.haveTank = false
      self.haveTankBox.Check:SetChecked(false)
    end
    roleFunc(box)
  end, true)
  self.noTankBox:SetSize(70, 20)
  self.noTankBox:SetPoint('LEFT', self.haveTankBox, 'RIGHT', 10, 0)

  local noDps = Profile.cdb.profile.roleFilters ~= nil and Profile.cdb.profile.roleFilters.noDps ~= nil and Profile.cdb.profile.roleFilters.noDps or false
  local noDpsBox = createCheckBox(#self.MD + 1, '缺输出', noDps, "noDps", 'OnChanged', roleFunc, true)
  noDpsBox:SetSize(70, 20)
  noDpsBox:SetPoint('TOPLEFT', self.haveTankBox, 'BOTTOMLEFT', 0, -5)

  local vacancyChecked = Profile.cdb.profile.roleFilters ~= nil and Profile.cdb.profile.roleFilters.vacancyChecked ~= nil and Profile.cdb.profile.roleFilters.vacancyChecked or false
  local vacancyMinimumRating = vacancyChecked and Profile.cdb.profile.roleFilters ~= nil and Profile.cdb.profile.roleFilters.vacancyMinimumRating ~= nil and Profile.cdb.profile.roleFilters.vacancyMinimumRating or 0
  self.vacancyBox = createFilterBox(#self.MD + 1, '集合石空缺人数：', 0, 4, vacancyMinimumRating, 0, 'OnChanged', function(box)
    if not Profile.cdb.profile.roleFilters then
      Profile.cdb.profile.roleFilters = {}
    end
    Profile.cdb.profile.roleFilters.vacancyChecked = box.Check:GetChecked()
    Profile.cdb.profile.roleFilters.vacancyMinimumRating = box.MinBox:GetNumber()
    self.ActivityList:Refresh()
  end, vacancyChecked, true)

  local secretNumberChecked = Profile.cdb.profile.roleFilters ~= nil and Profile.cdb.profile.roleFilters.secretNumberChecked ~= nil and Profile.cdb.profile.roleFilters.secretNumberChecked or false
  local secretNumberMinimumRating = secretNumberChecked and Profile.cdb.profile.roleFilters ~= nil and Profile.cdb.profile.roleFilters.secretNumberMinimumRating ~= nil and Profile.cdb.profile.roleFilters.secretNumberMinimumRating or 0
  self.secretNumber =   createFilterBox(#self.MD + 1, LFG_LIST_MINIMUM_RATING, 0,9999, secretNumberMinimumRating, 0, 'OnChanged', function(box)
    if not Profile.cdb.profile.roleFilters then
      Profile.cdb.profile.roleFilters = {}
    end
    Profile.cdb.profile.roleFilters.secretNumberChecked = box.Check:GetChecked()
    Profile.cdb.profile.roleFilters.secretNumberMinimumRating = box.MinBox:GetNumber()
    self.ActivityList:Refresh()
  end, secretNumberChecked, true)

  local SearchFilterButton = CreateFrame('Button', nil, ExSearchPanel, 'UIPanelButtonTemplate')
  do
    SearchFilterButton:SetSize(80, 22)
    SearchFilterButton:SetPoint('BOTTOMLEFT', ExSearchPanel, 'BOTTOMLEFT', 81, 5)
    SearchFilterButton:SetText('搜索')
    SearchFilterButton:SetScript('OnClick', function()
      self:ResetFilter()
    end)
  end
  self.SearchFilterButton = SearchFilterButton

  local ResetFilterButton = CreateFrame('Button', nil, ExSearchPanel, 'UIPanelButtonTemplate')
  do
    ResetFilterButton:SetSize(80, 22)
    ResetFilterButton:SetPoint('LEFT', self.SearchFilterButton, 'RIGHT', 5, 0)
    ResetFilterButton:SetText('重置')
    ResetFilterButton:SetScript('OnClick', function()
      for i, box in ipairs(self.MD) do
        box:Clear()
      end

      -- 清除角色过滤状态
      wipe(Profile.cdb.profile.roleFilters)

      if Profile:GetEnableClassFilter() then
        for classID = 1, GetNumClasses() do
          local className, classFile, classID = GetClassInfo(classID)
          Profile.gdb.global.UIMemory[classFile] = false
          Profile.gdb.global.UIMemory.ClassNeed = true
        end
      end

      self.vacancyBox.Check:SetChecked(false)
      self.secretNumber.Check:SetChecked(false)

      Profile.cdb.profile.dungeonFilters = nil
      Profile.cdb.profile.roleFilters = nil
      self.ActivityList:Refresh()
      C_LFGList.ClearSearchTextFields()
      self.ActivityDropdown:SetValue('2-0-0-0')
      self:DoSearch()
    end)
  end
  self.ResetFilterButton = ResetFilterButton
end

function BrowsePanel:ResetFilter()
  for i, v in ipairs(OTHER_DUNGEONS) do
    local stats, index = containsValue(OTHER_DUNGEONS, v)
    if not stats then
      table.remove(OTHER_DUNGEONS, index)
    end
  end
  self:DoSearch()
end

function BrowsePanel:CreateExSearchButton()
  self.RefreshButton:SetPoint('TOPRIGHT', MainPanel, 'TOPRIGHT', -180, -38)
  local ExSearchButton = CreateFrame('Button', nil, self, 'UIMenuButtonStretchTemplate')
  do
    GUI:Embed(ExSearchButton, 'Tooltip')
    ExSearchButton:SetTooltipAnchor('ANCHOR_RIGHT')
    ExSearchButton:SetTooltip(L['大秘境'])
    ExSearchButton:SetSize(83, 31)
    ExSearchButton:SetPoint('LEFT', self.RefreshButton, 'RIGHT', 0, 0)
    ExSearchButton:SetText(L['大秘境'])
    ExSearchButton:SetNormalFontObject('GameFontNormal')
    ExSearchButton:SetHighlightFontObject('GameFontHighlight')
    ExSearchButton:SetDisabledFontObject('GameFontDisable')

    ExSearchButton:SetScript('OnClick', function()
      self:SwitchPanel(self.ExSearchPanel)
      BannerPlugin.CloseButton:Click()
    end)
  end
  self.ExSearchButton = ExSearchButton
  self.AdvButton:SetPoint('LEFT', ExSearchButton, 'RIGHT', 0, 0)
  self.AdvButton:SetScript('OnClick', function()
    self:SwitchPanel(self.AdvFilterPanel)
  end)

  CreateMemberFilter(self, 'BOTTOMLEFT', MainPanel, 70, '坦克', 'FILTER_TANK', "隐藏已有坦克职业的队伍，允许多选")
  CreateMemberFilter(self, 'BOTTOMLEFT', MainPanel, 130, '治疗', 'FILTER_HEALTH', "隐藏已有治疗职业的队伍，允许多选")
  CreateMemberFilter(self, 'BOTTOMLEFT', MainPanel, 190, '输出', 'FILTER_DAMAGE', "隐藏输出职业满的队伍，允许多选")
  CreateMemberFilter(self, 'BOTTOMLEFT', MainPanel, 250, '多选-"或"条件', 'FILTER_MULTY',
    '左侧几项多选时，将过滤出同时满足所有条件的队伍\n而多选的同时再勾选本项后，将过滤出满足勾选的任意一项条件的队伍\n一般而言，用于玩家想同时以多个职责加入队伍的时候\n例如战士想查找缺T或DPS的队伍')

  CreateMemberFilter(self, 'BOTTOM', MainPanel, 80, '同职过滤', 'FILTER_JOB',
    "五人副本时，隐藏已有同职责" .. UnitClass("player") .. "的队伍")
  CreateScoreFilter(self, '过滤队长0分队伍', 1)

  CreateMemberFilter(self, 'BOTTOM', MainPanel, 200, '显示屏蔽提示', 'IGNORE_TIPS_LOG',
    "屏蔽了队长或同标题玩家时，聊天框里显示一次提示信息")
end

function BrowsePanel:ToggleActivityMenu(anchor, activity)
  local usable, reason = self:CheckSignUpStatus(activity)

  GUI:ToggleMenu(anchor, {
    {
      text = activity:GetName(), isTitle = true, notCheckable = true
    },
    {
      text = '申请加入',
      func = function()
        self:SignUp(activity)
      end,
      disabled = not usable or activity:IsDelisted() or activity:IsApplication(),
      tooltipTitle = not (activity:IsDelisted() or activity:IsApplication()) and '申请加入',
      tooltipText = reason,
      tooltipWhileDisabled = true,
      tooltipOnButton = true,
    },
    {
      text = WHISPER_LEADER,
      func = function()
        ChatFrame_SendTell(activity:GetLeader())
      end,
      disabled = not activity:GetLeader(), -- or not activity:IsApplication(),
      tooltipTitle = not activity:IsApplication() and WHISPER,
      tooltipText = not activity:IsApplication() and LFG_LIST_MUST_SIGN_UP_TO_WHISPER,
      tooltipOnButton = true,
      tooltipWhileDisabled = true,
    },
    {
      --20220603 易安玥 修改到新的举报菜单
      text = LFG_LIST_REPORT_GROUP_FOR,
      func = function()
        LFGList_ReportListing(activity:GetID(), activity:GetLeader());
        LFGListSearchPanel_UpdateResultList(LFGListFrame.SearchPanel);
      end,
    },
    {
      text = '屏蔽队长',
      func = function()
        local name = activity:GetLeader()
        BrowsePanel.IgnoreLeaderOnly[name] = true
        if Profile.gdb.global.UIMemory.IGNORE_TIPS_LOG then
          print(name .. " 已加入黑名单")
        end
        BrowsePanel.ActivityList:Refresh()
      end,
    },
    {
      text = '屏蔽同标题玩家',
      hidden = function()
        return not Profile:GetEnableIgnoreTitle()
      end,
      func = function()
        local title = activity:GetSummary()         -- or activity:GetComment()
        if Profile.gdb.global.UIMemory.IGNORE_TIPS_LOG then
          print('添加过滤：', title)
        end
        BrowsePanel.IgnoreWithTitle[title] = true
        BrowsePanel.ActivityList:Refresh()
      end,
    },
    {
      text = '复制队长名字',
      func = function()
        local name = activity:GetLeader()
        print(name)
        GUI:CallUrlDialog(name)
      end,
    },
    { text = CANCEL },
  }, 'cursor')
end

function BrowsePanel:GetExSearchs()
  local filters = {}
  for _, box in ipairs(self.MD) do
    filters[box.dungeonName] = {
      enable = not not box.Check:GetChecked(),
    }
  end
  return filters
end

function BrowsePanel:SwitchPanel(panel)
  local list = {
    self.ExSearchPanel,
    self.AdvFilterPanel,
  }
  for i, v in ipairs(list) do
    if v == panel then
      v:SetShown(not v:IsShown())
    else
      v:SetShown(false)
    end
  end
end
