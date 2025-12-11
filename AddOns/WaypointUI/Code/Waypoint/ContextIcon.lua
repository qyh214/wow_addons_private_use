local env                    = select(2, ...)

local IsOnQuest              = C_QuestLog.IsOnQuest
local IsReadyForTurnIn       = C_QuestLog.ReadyForTurnIn
local IsQuestRepeatable      = C_QuestLog.IsRepeatableQuest
local GetQuestClassification = C_QuestInfoSystem.GetQuestClassification
local GetQuestType           = C_QuestLog.GetQuestType

local Path                   = env.WPM:Import("wpm_modules/path")
local Waypoint_ContextIcon   = env.WPM:New("@/Waypoint/ContextIcon")


-- Shared
--------------------------------

local PATH = Path.Root .. "/Art/Icon/"


-- Helper
--------------------------------

local ICON_TYPE_NAMES = {
    Default    = nil,
    Important  = "Important",
    Campaign   = "Campaign",
    Legendary  = "Legendary",
    Artifact   = "Artifact",
    Calling    = "CampaignRecurring",
    Meta       = "Meta",
    Recurring  = "Recurring",
    Repeatable = "Repeatable"
}

local function getQuestIconName(questID)
    local classification = GetQuestClassification(questID)
    local questType      = GetQuestType(questID)

    local isCompleted    = IsReadyForTurnIn(questID)
    local isActive       = IsOnQuest(questID)
    local suffix         = isCompleted and "Complete" or (isActive and "Incomplete" or "Available")

    local typeKey
    if classification == Enum.QuestClassification.Normal then
        typeKey = "Default"
    elseif classification == Enum.QuestClassification.Important then
        typeKey = "Important"
    elseif classification == Enum.QuestClassification.Campaign then
        typeKey = "Campaign"
    elseif classification == Enum.QuestClassification.Legendary or questType == Enum.QuestTag.Legendary then
        typeKey = "Legendary"
    elseif questType == 107 then
        typeKey = "Artifact"
    elseif classification == Enum.QuestClassification.Calling then
        typeKey = "Calling"
    elseif classification == Enum.QuestClassification.Meta then
        typeKey = "Meta"
    elseif classification == Enum.QuestClassification.Recurring then
        typeKey = "Recurring"
    elseif IsQuestRepeatable(questID) then
        typeKey = "Repeatable"
    end

    if not typeKey then return nil end

    local typeName = ICON_TYPE_NAMES[typeKey]
    return typeName and ("Quest%s%s"):format(typeName, suffix) or ("Quest%s"):format(suffix)
end


-- API
--------------------------------

---@param questID number
---@return string? inlineIcon
---@return string? texturePath
function Waypoint_ContextIcon:GetContextIcon(questID)
    assert(questID, "Invalid variable `questID`")

    local iconName = getQuestIconName(questID)
    if not iconName then return nil, nil end

    return PATH .. iconName .. ".png"
end
