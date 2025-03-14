local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local LibCustomGlow = LibStub("LibCustomGlow-1.0")

local Conditions = {
    -- 名字-服务器
    {
        Title = L["addon_set_settings_condition_name_and_realm"],
        Event = { "PLAYER_LOGIN" },
        Dynamic = false,
        Current = function(self)
            return UnitFullName("player")
        end,
        Sence = function(self)
            return GetUnitName("player", true)
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetPlayerNameConditions(addonSet, self:Current())
        end
    },
    -- 战争模式
    {
        Title = PVP_LABEL_WAR_MODE,
        Event = { "PLAYER_FLAGS_CHANGED" },
        Dynamic = true,
        Current = function(self)
            return C_PvP.IsWarModeDesired()
        end,
        Sence = function(self)
            local _, instanceType = GetInstanceInfo()
            if instanceType ~= "none" then
                return "Disabled"
            end
            
            return C_PvP.IsWarModeDesired() and "Enabled" or "Disabled"
        end,
        MetCondition = function(self, addonSet)
            local _, instanceType = GetInstanceInfo()
            if instanceType ~= "none" then
                -- 非野外，不检查战争模式，视为命中条件
                return true, true
            end

            return Addon:IsAddonSetMetWarModeCondition(addonSet, self:Current())
        end
    },
    -- 阵营
    {
        Title = FACTION,
        Event = { "PLAYER_LOGIN" },
        Dynamic = false,
        Current = function(self)
            return UnitFactionGroup("player")
        end,
        Sence = function(self)
            local faction = UnitFactionGroup("player")
            return faction
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetFactionCondition(addonSet, self:Current())
        end
    },
    -- 满级
    {
        Title = L["addon_set_settings_condition_max_level"],
        Event = { "PLAYER_LOGIN", "PLAYER_LEVEL_UP" },
        Dynamic = true,
        Current = function(self)
            local maxLevel = UnitLevel("player") == GetMaxPlayerLevel()
            self.Dynamic = not maxLevel
            return maxLevel
        end,
        Sence = function(self)
            return self:Current() and "MaxLevel" or "Leveling"
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetMaxLevelCondition(addonSet, self:Current())
        end
    },
    -- 职业和专精
    {
        Title = L["addon_set_settings_condition_specialization"],
        Event = { "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" },
        Dynamic = true,
        Current = function(self)
            local currentSpecIndex = GetSpecialization()
            return currentSpecIndex and GetSpecializationInfo(currentSpecIndex)
        end,
        Sence = function(self)
            local _, specName = self:Current()
            return specName or "Unknown"
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetSpecializationCondition(addonSet, self:Current())
        end
    },
    -- 专精职责
    {
        Title = L["addon_set_settings_condition_specialization_role"],
        Event = { "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" },
        Dynamic = true,
        Current = function(self)
            local currentSpecIndex = GetSpecialization()
            if currentSpecIndex then
                local _, _, _, _, role = GetSpecializationInfo(currentSpecIndex)
                return role
            end
        end,
        Sence = function(self)
            return self:Current() or "Unknown"
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetSpecializationRoleCondition(addonSet, self:Current())
        end
    },
    -- 玩家种族
    {
        Title = L["addon_set_settings_condition_race"],
        Event = { "PLAYER_LOGIN" },
        Dynamic = false,
        Current = function(self)
            local _, _, raceId = UnitRace("player")
            if raceId then
                local raceInfo = C_CreatureInfo.GetRaceInfo(raceId)
                if raceInfo then
                    return raceInfo.clientFileString
                end
            end
        end,
        Sence = function(self)
            return self:Current() or "Unknown"
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetRaceCondition(addonSet, self:Current())
        end
    },
    -- 副本类型
    {
        Title = L["addon_set_settings_condition_instance_type"],
        Event = { "ZONE_CHANGED_NEW_AREA" },
        Dynamic = true,
        Current = function(self)
            local _, instanceType = GetInstanceInfo()
            return instanceType
        end,
        Sence = function(self)
            return self:Current() or "Unknown"
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetInstanceTypeCondition(addonSet, self:Current())
        end
    },
    -- 副本难度
    {
        Title = L["addon_set_settings_condition_instance_difficulty"],
        Event = { "PLAYER_DIFFICULTY_CHANGED", "ZONE_CHANGED_NEW_AREA" },
        Dynamic = true,
        Current = function(self)
            local _, _, difficultyId = GetInstanceInfo()
            if difficultyId then
                return Addon.InstanceDifficultyInfo[difficultyId]
            end
        end,
        Sence = function(self)
            return self:Current() or "Unknown"
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetInstanceDifficultyCondition(addonSet, self:Current())
        end
    },
    -- 副本难度类型
    {
        Title = L["addon_set_settings_condition_instance_difficulty_type"],
        Event = { "PLAYER_DIFFICULTY_CHANGED", "ZONE_CHANGED_NEW_AREA" },
        Dynamic = true,
        Current = function(self)
            local _, _, difficultyId = GetInstanceInfo()
            return difficultyId
        end,
        Sence = function(self)
            return self:Current() or "Unknown"
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetInstanceDifficultyTypeCondition(addonSet, self:Current())
        end
    },
    -- 史诗钥石词缀
    {
        Title = L["addon_set_settings_condition_mythic_plus_affix"],
        Event = { "CHALLENGE_MODE_START", "CHALLENGE_MODE_COMPLETED" },
        Dynamic = true,
        Current = function(self)
            local _, affixIDs = C_ChallengeMode.GetActiveKeystoneInfo()
            return affixIDs
        end,
        Sence = function(self)
            local affixIds = C_ChallengeMode.GetActiveKeystoneInfo()
            return affixIDs and table.concat(affixIds) or "Unknown"
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetMythicPlusAffixCondition(addonSet, self:Current())
        end
    }
}

-- 最近弹窗时的场景
local latestSences = {}
-- 是否为第一次条件检查
local firstCheckCondition = true

local function CheckAddonSetCondition()
    if not Addon:IsLoadConditionDetectEnabled() then
        return
    end

    local sences = {}
    for _, condition in ipairs(Conditions) do
        local sence = condition:Sence()
        tinsert(sences, condition.Title .. ":" .. sence)
    end
    local lastSences = latestSences
    latestSences = sences

    -- print("--------------------")
    -- DevTools_Dump(sences)

    local firstCheck = firstCheckCondition
    firstCheckCondition = false

    local addonSets = Addon:GetAddonSets()
    local activeAddonSetName = Addon:GetActiveAddonSetName()
    local metConditionAddonSets = {}
    local activeAddonSetMetConditionNum = 0
    local activeAddonSetMetCondition = false
    local maxMetConditionNum = 0

    for addonSetName, addonSet in pairs(addonSets) do
        -- DevTools_Dump(addonSet.Conditions)
        if addonSet.Enabled then
            local metConditions = {}
            local metCondition = true

            for _, condition in ipairs(Conditions) do
                -- 仅当第一次检查条件时，才检查静态条件，这样会显著降低静态条件的提示频率
                if firstCheck or condition.Dynamic then
                    -- conditionEmpty true:条件为空 false:条件不为空
                    local met, conditionEmpty = condition:MetCondition(addonSet)
                    -- print(addonSetName, condition.Title, met, conditionEmpty)

                    if not met then
                        metCondition = false
                        break
                    end

                    if not conditionEmpty then
                        tinsert(metConditions, condition.Title)
                    end
                end
            end

            local metConditionSize = #metConditions
            maxMetConditionNum = math.max(maxMetConditionNum, metConditionSize)
            
            if metCondition and metConditionSize > 0 then
                if addonSetName == activeAddonSetName then
                    activeAddonSetMetCondition = true
                    activeAddonSetMetConditionNum = metConditionSize
                end
                
                tinsert(metConditionAddonSets, { AddonSet = addonSet, MetConditions = metConditions, MetConditionSize = metConditionSize })
            end
        end
    end
    
    -- for _, item in ipairs(metConditionAddonSets) do
    --     print("满足加载条件的插件集：", item.AddonSet.Name, table.concat(item.MetConditions, "，"))
    -- end

    if #metConditionAddonSets <= 0 then
        Addon:HideAddonSetConditionDialog()
        return
    end

    -- 当前插件集就满足条件，并且条件数量与满足最多条件数量的插件集一致，则无需弹出提示
    if activeAddonSetMetCondition and activeAddonSetMetConditionNum >= maxMetConditionNum then
        Addon:HideAddonSetConditionDialog()

        -- 检查是否完全匹配
        if firstCheck and not Addon:IsAddonSetPerfectMacth(activeAddonSetName) then
            local alertInfo = {
                Extra = activeAddonSetName,
                Label = L["addon_set_not_perfect_match_alert"]:format(WrapTextInColor(activeAddonSetName, NORMAL_FONT_COLOR)),
                ConfirmText = L["addon_set_not_perfect_match_confirm"],
                CancelText = L["ignore"],
                OnConfirm = function(extra)
                    Addon:ApplyAddonSetAddons(extra)
                    ReloadUI()
                end
            }
            Addon:ShowAlertDialog(alertInfo)
        end
        return
    end

    -- 如果场景不一致，才触发选择弹窗
    if not tCompare(lastSences, sences) then
        table.sort(metConditionAddonSets, function(a, b) return a.MetConditionSize > b.MetConditionSize end)
        
        Addon:ShowAddonSetConditionDialog(metConditionAddonSets)
    end
end

do
    local function OnEventTrigger(self, event, arg1, arg2)
        if event == "PLAYER_FLAGS_CHANGED" and arg1 ~= "player" then
            return
        end

        if self.debounceJob then
            self.debounceJob:Cancel()
        end
        self.debounceJob = C_Timer.After(1, CheckAddonSetCondition)
    end
    
    local conditionFrame = CreateFrame("Frame")
    conditionFrame:SetScript("OnEvent", OnEventTrigger)

    for _, item in ipairs(Conditions) do
        for _, event in ipairs(item.Event) do
            conditionFrame:RegisterEvent(event)
        end
    end
end

ImprovedAddonListConditionAddonSetItemMixin = {}

function ImprovedAddonListConditionAddonSetItemMixin:Update(data)
    local activeAddonSetName = Addon:GetActiveAddonSetName()
    local name = data.AddonSet.Name
    if activeAddonSetName == name then
        name = CreateSimpleTextureMarkup("Interface\\AddOns\\ImprovedAddonList\\Media\\location.png", 14, 14) .. " " .. name
    end

    self.Label:SetText(name)
    self.MetCount:SetText(L["addon_set_condition_met_count"]:format(data.MetConditionSize))
end

function ImprovedAddonListConditionAddonSetItemMixin:OnEnter()
    local item = self:GetElementData()
    local addonSet = item.AddonSet
    if not addonSet or not addonSet.Addons then
        return
    end

    local addons = {}
    local addonInfos = Addon:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        local addonName = addonInfo.Name
        if not Addon:IsAddonManager(addonName) and addonSet.Addons[addonName] then
            tinsert(addons, { Name = addonName })
        end
    end

    local conditions = item.MetConditions and table.concat(item.MetConditions, "\n")
    if conditions == nil or conditions == "" then
        conditions = L["addon_set_condition_met_none"]
    end
    conditions = WrapTextInColor(conditions, NORMAL_FONT_COLOR)

    local addonListTooltipInfo = {
        Addons = addons,
        Label = L["addon_set_condition_tooltip_label"]:format(WrapTextInColor(addonSet.Name, NORMAL_FONT_COLOR), conditions)
    }
    Addon:ShowAddonListTooltips(self:GetParent():GetParent(), addonListTooltipInfo)
end

function ImprovedAddonListConditionAddonSetItemMixin:OnLeave()
    Addon:HideAddonListTooltips()
end

function ImprovedAddonListConditionAddonSetItemMixin:OnClick()
    local item = self:GetElementData()
    local addonSet = item.AddonSet
    if not addonSet then
        return
    end
    Addon:SetActiveAddonSetName(addonSet.Name)
    Addon:ApplyAddonSetAddons(addonSet.Name)
    ReloadUI()
end

local AddonSetConditionDialogMixin = {}

function AddonSetConditionDialogMixin:Init()
    self:SetScript("OnUpdate", self.OnUpdate)
    self:SetScript("OnDragStart", self.OnDragStart)
    self:SetScript("OnDragStop", self.OnDragStop)

    self:SetScript("OnEvent", self.OnEvent)
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")

    self:SetWidth(300)
    self:SetFrameStrata("DIALOG")

    self:SetMovable(true)
    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
    self:SetClampedToScreen(true)

    CreateFrame("Frame", nil, self, "DialogBorderDarkTemplate")

    local Timer = self:CreateFontString(nil, nil, "GameFontWhiteTiny")
    self.Timer = Timer
    Timer:SetPoint("TOPLEFT", 12, -12)

    local Close = CreateFrame("Button", nil, self, "UIPanelCloseButton")
    self.Close = Close
    Close:SetSize(16, 16)
    Close:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, -2)

    local Label = self:CreateFontString(nil, nil, "GameFontNormalSmall")
    self.Label = Label
    Label:SetWidth(260)
    Label:SetPoint("TOP", 0, -25)
    Label:SetPoint("LEFT", 20, 0)
    Label:SetPoint("RIGHT", -20, 0)
    Label:SetText(L["addon_set_switch_tips_dialog_label"])

    local ScrollBox = CreateFrame("Frame", nil, self, "WowScrollBoxList")
    self.ScrollBox = ScrollBox

    local ScrollBar = CreateFrame("EventFrame", nil, self, "MinimalScrollBar")
    ScrollBar:SetPoint("TOP", Label, "BOTTOM", 0, -10)
    ScrollBar:SetPoint("RIGHT", self, "RIGHT", -25, 0)
    ScrollBar:SetPoint("BOTTOM", 0, 15)

    local anchorsWithScrollBar = {
        CreateAnchor("TOP", ScrollBar, "TOP"),
        CreateAnchor("LEFT", 15, 0),
        CreateAnchor("BOTTOMRIGHT", ScrollBar, "BOTTOMLEFT", -5, 0),
    }
    
    local anchorsWithoutScrollBar = {
        CreateAnchor("TOP", ScrollBar, "TOP"),
        CreateAnchor("LEFT", 25, 0),
        CreateAnchor("BOTTOMRIGHT", -25, 10);
    }

    local ScrollView = CreateScrollBoxListLinearView(1, 1, 1, 1, 1)
    ScrollView:SetElementInitializer("ImprovedAddonListConditionAddonSetItemTemplate", function(button, node) button:Update(node) end)
    ScrollView:SetElementExtentCalculator(function() return 25 end)
    
    ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, ScrollView)
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(ScrollBox, ScrollBar, anchorsWithScrollBar, anchorsWithoutScrollBar)

    
    Addon:RegisterCallback("AddonSettings.UIScale", self.OnUIScaleChanged, self)
end

-- UIPanelCloseButton_OnClick 会调用此函数
function AddonSetConditionDialogMixin.onCloseCallback(closeButton)
    local parent = closeButton:GetParent()
    parent:Dismiss()
end

function AddonSetConditionDialogMixin:OnUIScaleChanged()
    self:SetScale(Addon:GetUIScale())

    local x, y = Addon:GetLoadConditionPromptPosition()
    if x and y then
        local scale = self:GetEffectiveScale()
        self:SetPoint("BOTTOMLEFT", x / scale, y / scale)
    else
        self:SetPoint("TOP", 0, -135)
    end
end

function AddonSetConditionDialogMixin:OnEvent(event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
        self:Refresh(true)
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:Refresh(false)
    end
end

function AddonSetConditionDialogMixin:OnUpdate(elapsed)
    if not self.HideTime then
        self.Timer:Hide()
        return
    else
        self.Timer:Show()
    end

    local now = GetTime()
    local dismissTime = Addon:GetLoadConditionPromptAutoDismissTime() 
    if self:IsMouseOver() then
        self.HideTime = now + dismissTime
    end

    local remainTime = self.HideTime - now
    if remainTime <= 0 then
        self:Dismiss()
    else
        local percent = remainTime / dismissTime
        local alpha = 1 - math.pow(1 - percent, 2)
        self:SetAlpha(alpha)
    end

    self.timeElapsed = (self.timeElapsed or 0) + elapsed
    if self.timeElapsed > 0.1 then
        self.timeElapsed = 0

        self.Timer:SetText(string.format("%ds", remainTime))
    end
end

function AddonSetConditionDialogMixin:OnDragStart()
    self:StartMoving()
    self:SetUserPlaced(false)
end

function AddonSetConditionDialogMixin:OnDragStop()
    self:StopMovingOrSizing()
    local left, bottom = self:GetScaledRect()
    Addon:SaveLoadConditionPromptPosition(left, bottom)
end

function AddonSetConditionDialogMixin:GetDataProvider()
    self.DataProvider = self.DataProvider or CreateDataProvider()
    return self.DataProvider
end

function AddonSetConditionDialogMixin:RefreshAddonSets(addonSets)
    local dataProvider = self:GetDataProvider()
    dataProvider:Flush()

    if addonSets then
        dataProvider:InsertTable(addonSets)
    end

    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition)
end

function AddonSetConditionDialogMixin:Refresh(inCombat)
    if not self.Info then
        return
    end

    if inCombat then
        self:Hide()
        return    
    end

    local autoDismissTime = Addon:GetLoadConditionPromptAutoDismissTime()
    if autoDismissTime <= 0 then
        self.HideTime = nil
    else
        self.HideTime = GetTime() + autoDismissTime
    end

    self:OnUIScaleChanged()

    local addonSetSize = #self.Info
    local scrollBoxHeight = math.min(10, addonSetSize) * 25
    local height = self.Label:GetStringHeight() + scrollBoxHeight + 60
    self:SetHeight(height)

    self:RefreshAddonSets(self.Info)
    self:Show()
end

function AddonSetConditionDialogMixin:Dismiss()
    self.Info = nil
    self:Hide()
end

function AddonSetConditionDialogMixin:Setup(info)
    self.Info = info
    self:Refresh(InCombatLockdown())
end

function Addon:ShowAddonSetConditionDialog(info)
    local addonSetConditionDialog = self.AddonSetConditionDialog
    if not addonSetConditionDialog then
        addonSetConditionDialog = Mixin(CreateFrame("Frame", nil, UIParent), AddonSetConditionDialogMixin)
        self.AddonSetConditionDialog = addonSetConditionDialog
        addonSetConditionDialog:Init()
    end

    addonSetConditionDialog:Setup(info)
end

function Addon:HideAddonSetConditionDialog()
    if self.AddonSetConditionDialog then
        self.AddonSetConditionDialog:Dismiss()
    end
end