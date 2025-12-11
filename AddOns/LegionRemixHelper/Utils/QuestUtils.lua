---@class AddonPrivate
local Private = select(2, ...)

---@class QuestUtils
---@field addon LegionRH
local questUtils = {
    addon = nil,
    ---@type table<any, string>
    L = nil,
}
Private.QuestUtils = questUtils

local const = Private.constants

function questUtils:Init()
    self.L = Private.L
    local addon = Private.Addon
    self.addon = addon

    addon:RegisterEvent("GOSSIP_SHOW", "QuestUtils_GossipShow", function()
        self:OnGossipShow()
    end)

    addon:RegisterEvent("QUEST_GREETING", "QuestUtils_QuestGreeting", function()
        self:OnQuestGreeting()
    end)

    addon:RegisterEvent("QUEST_COMPLETE", "QuestUtils_QuestComplete", function()
        self:OnQuestComplete()
    end)

    addon:RegisterEvent("QUEST_DETAIL", "QuestUtils_QuestDetail", function()
        self:OnQuestDetail()
    end)

    addon:RegisterEvent("QUEST_PROGRESS", "QuestUtils_QuestProgress", function()
        self:OnQuestProgress()
    end)

    addon:RegisterEvent("UPDATE_UI_WIDGET", "QuestUtils_HeroicWorldTier", function(_, _, widgetInfo)
        if widgetInfo then
            self:OnWorldTierIcon()
        end
    end)
end

function questUtils:CreateSettings()
    local settingsUtils = Private.SettingsUtils
    local settingsCategory = settingsUtils:GetCategory()
    local settingsPrefix = self.L["QuestUtils.SettingsCategoryPrefix"]

    settingsUtils:CreateHeader(settingsCategory, settingsPrefix, self.L["QuestUtils.SettingsCategoryTooltip"],
        { settingsPrefix })
    settingsUtils:CreateCheckbox(settingsCategory, "AUTO_QUEST_TURN_IN", "BOOLEAN", self.L["QuestUtils.AutoTurnIn"],
        self.L["QuestUtils.AutoTurnInTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "quest.autoTurnIn"))
    settingsUtils:CreateCheckbox(settingsCategory, "AUTO_QUEST_ACCEPT", "BOOLEAN", self.L["QuestUtils.AutoAccept"],
        self.L["QuestUtils.AutoAcceptTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "quest.autoAccept"))
    settingsUtils:CreateCheckbox(settingsCategory, "AUTO_QUEST_IGNORE_ETERNUS", "BOOLEAN", self.L["QuestUtils.IgnoreEternus"],
        self.L["QuestUtils.IgnoreEternusTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "quest.ignoreEternus"))
    settingsUtils:CreateCheckbox(settingsCategory, "AUTO_QUEST_SURPRESS_SHIFT", "BOOLEAN", self.L["QuestUtils.SuppressShift"],
        self.L["QuestUtils.SuppressShiftTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "quest.suppressShift"))
    settingsUtils:CreateCheckbox(settingsCategory, "AUTO_QUEST_HIDE_WORLD_TIER_ICON", "BOOLEAN", self.L["QuestUtils.SuppressWorldTierIcon"],
        self.L["QuestUtils.SuppressWorldTierIconTooltip"], false,
        settingsUtils:GetDBFunc("GETTERSETTER", "quest.suppressWorldTierIcon"))
end

---@param functionType "autoAccept" | "autoTurnIn" | "ignoreEternus" | "suppressShift" | "suppressWorldTierIcon"
---@return boolean isActive
function questUtils:IsActive(functionType)
    return self.addon:GetDatabaseValue("quest." .. functionType)
end

---@return boolean isEternusNPC
function questUtils:IsEternusNPC()
    local guid = UnitGUID("npc")
    if not guid then return false end
    local npcID = select(6, strsplit("-", guid))
    return npcID and tonumber(npcID) == const.QUESTS.ETERNUS_NPC_ID
end

---@return boolean shouldSurpress
function questUtils:ShouldSuppressAutoQuest()
    local suppressShift = self:IsActive("suppressShift")
    if suppressShift and IsShiftKeyDown() then
        return true
    end
    if self:IsActive("ignoreEternus") and self:IsEternusNPC() then
        return true
    end
    return false
end

function questUtils:OnGossipShow()
    if self:ShouldSuppressAutoQuest() then
        return
    end
    if self:IsActive("autoTurnIn") then
        local activeQuests = C_GossipInfo.GetActiveQuests()
        if activeQuests then
            for _, questInfo in ipairs(activeQuests) do
                if questInfo.isComplete then
                    C_GossipInfo.SelectActiveQuest(questInfo.questID)
                    break
                end
            end
        end
    end
    if self:IsActive("autoAccept") then
        local availableQuests = C_GossipInfo.GetAvailableQuests()
        if availableQuests then
            for _, questInfo in ipairs(availableQuests) do
                C_GossipInfo.SelectAvailableQuest(questInfo.questID)
                break
            end
        end
    end
end

function questUtils:OnQuestGreeting()
    if self:ShouldSuppressAutoQuest() then
        return
    end
    if self:IsActive("autoTurnIn") then
        local numActive = GetNumActiveQuests()
        for i = 1, numActive do
            local activeID = GetActiveQuestID(i)
            if activeID then
                local isComplete = C_QuestLog.IsComplete(activeID)
                if isComplete then
                    ---@diagnostic disable-next-line: redundant-parameter
                    SelectActiveQuest(i)
                end
            end
        end
    end
    if self:IsActive("autoAccept") and GetNumAvailableQuests() > 0 then
        ---@diagnostic disable-next-line: redundant-parameter
        SelectAvailableQuest(1)
    end
end

function questUtils:OnQuestComplete()
    if self:ShouldSuppressAutoQuest() then
        return
    end
    if self:IsActive("autoTurnIn") then
        pcall(function()  -- Only complete with no selection
            ---@diagnostic disable-next-line: param-type-mismatch
            GetQuestReward(nil)
        end)
    end
end

function questUtils:OnQuestDetail()
    if self:ShouldSuppressAutoQuest() then
        return
    end
    if self:IsActive("autoAccept") then
        AcceptQuest()
    end
end

function questUtils:OnQuestProgress()
    if self:ShouldSuppressAutoQuest() then
        return
    end
    if self:IsActive("autoTurnIn") and IsQuestCompletable() then
        CompleteQuest()
    end
end

function questUtils:ShouldSuppressWorldTierIcon()
    local suppressWorldTierIcon = self:IsActive("suppressWorldTierIcon")
    if suppressWorldTierIcon then
        return true
    end

    return false
end

function questUtils:UpdateWorldTierIcon()

    local container = UIWidgetBelowMinimapContainerFrame
    if not container or not container.GetLayoutChildren then return end

    local shouldSupress = self:ShouldSuppressWorldTierIcon()
    local widgetFrames = container.widgetFrames
    local widgetId = const.HEROIC_WORLD_TIER.WIDGET_ID

    if not widgetFrames or type(widgetFrames) ~= "table" or not widgetFrames[widgetId] then return end

    local worldTierWidget = widgetFrames[widgetId]
    if worldTierWidget.widgetID and worldTierWidget.widgetID == widgetId then
        if shouldSupress ~= not worldTierWidget:IsShown() then
            worldTierWidget:SetShown(not shouldSupress)
            if container.UpdateWidgetLayout then
                container:UpdateWidgetLayout()
            end
        end

        return
    end
end

function questUtils:OnWorldTierIcon()
    self:UpdateWorldTierIcon()
end
