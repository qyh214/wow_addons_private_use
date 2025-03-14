--[[
    BtWQuestsCharacters handles storing information about the users characters like completed quests and reputation
    The data is saved as a list in BtWQuests_Characters
]]

local function ArrayContains(a, item)
    for i=1,#a do
        if a[i] == item then
            return true
        end
    end
    
    return false
end

local GetLogIndexForQuestID = C_QuestLog and C_QuestLog.GetLogIndexForQuestID or GetQuestLogIndexByID
local IsQuestFlaggedCompleted = C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted or IsQuestFlaggedCompleted

local GetQuestsActive
if select(4, GetBuildInfo()) < 90000 then
    function GetQuestsActive(tbl)
        local tbl = tbl or {};
    
        local numEntries = GetNumQuestLogEntries()
        for i=1,numEntries do
            local questID = select(8, GetQuestLogTitle(i));
            if questID ~= nil and questID ~= 0 then
                tbl[questID] = {};
    
                for objective=1,GetNumQuestLeaderBoards(i) do
                    tbl[questID][objective] = {GetQuestLogLeaderBoard(objective, i)};
                end
            end
        end
        
        return tbl;
    end
else
    function GetQuestsActive(tbl)
        local tbl = tbl or {};
    
        local numEntries = C_QuestLog.GetNumQuestLogEntries()
        for i=1,numEntries do
            local info = C_QuestLog.GetInfo(i);
            if info.questID ~= nil and info.questID ~= 0 then
                tbl[info.questID] = {};
    
                for objective=1,GetNumQuestLeaderBoards(i) do
                    tbl[info.questID][objective] = {GetQuestLogLeaderBoard(objective, i)};
                end
            end
        end
        
        return tbl;
    end
end
local GetQuestsCompleted = GetQuestsCompleted or function (tbl)
    local tbl = tbl or {};

    for _,questID in ipairs(C_QuestLog.GetAllCompletedQuestIDs()) do
        tbl[questID] = true
    end
    
    return tbl;
end
local GetNumFactions = C_Reputation and C_Reputation.GetNumFactions or GetNumFactions;
local GetFactionDataByID = C_Reputation and C_Reputation.GetFactionDataByID or function (id)
    local name, _, standing, barMin, barMax, barValue, _, _, _, _, _, _, _, factionID = GetFactionInfoByID(id);
    return name and {
        name = name,
        factionID = factionID,
        reaction = standing,
        currentReactionThreshold = barMin,
        currentStanding = barValue,
        nextReactionThreshold = barMax
    };
end;
local GetFactionDataByIndex = C_Reputation and C_Reputation.GetFactionDataByIndex or function (i)
    local name, _, standing, barMin, barMax, barValue, _, _, _, _, _, _, _, factionID = GetFactionInfo(i);
    return name and {
        name = name,
        factionID = factionID,
        reaction = standing,
        currentReactionThreshold = barMin,
        currentStanding = barValue,
        nextReactionThreshold = barMax
    };
end;

local BtWQuestsCharactersMap = {} -- Map from name-realm to Character Mixin

local ClassMap = {}
for classID=1,GetNumClasses() do
    local info = C_CreatureInfo.GetClassInfo(classID)
    if info then
        ClassMap[info.classFile] = info
        ClassMap[info.classID] = info
    end
end

local accountPlayerLevel = 0
local function GetAccountPlayerLevel()
    if accountPlayerLevel == 0 then
        for _,v in pairs(BtWQuests_Characters or {}) do
            accountPlayerLevel = math.max(accountPlayerLevel, v.level or 0)
        end
    end
    return math.max(accountPlayerLevel, UnitLevel("player") or 0)
end

BtWQuestsCharactersCharacterMixin = {}
function BtWQuestsCharactersCharacterMixin:IsPartySync()
    return false
end
function BtWQuestsCharactersCharacterMixin:IsWarband()
    return false
end
function BtWQuestsCharactersCharacterMixin:IsPlayer()
    return false
end
function BtWQuestsCharactersCharacterMixin:GetFullName()
    return self.t.name, self.t.realm
end
function BtWQuestsCharactersCharacterMixin:GetName()
    return self.t.name
end
function BtWQuestsCharactersCharacterMixin:GetDisplayName()
    local name, realm = self:GetFullName();
    return string.format("%s-%s", name, realm);
end
function BtWQuestsCharactersCharacterMixin:GetRealm()
    return self.t.realm
end
function BtWQuestsCharactersCharacterMixin:GetFaction()
    return self.t.faction
end
function BtWQuestsCharactersCharacterMixin:GetRace()
    return self.t.race
end
function BtWQuestsCharactersCharacterMixin:GetClass()
    return self.t.class
end
function BtWQuestsCharactersCharacterMixin:GetClassString()
    return ClassMap[self.t.class].classFile
end
function BtWQuestsCharactersCharacterMixin:GetLevel()
    return self.t.level or 0
end
function BtWQuestsCharactersCharacterMixin:GetSex()
    return self.t.sex
end


function BtWQuestsCharactersCharacterMixin:IsFaction(faction)
    return self:GetFaction() == faction
end

function BtWQuestsCharactersCharacterMixin:IsRace(race)
    return self:GetRace() == race
end
function BtWQuestsCharactersCharacterMixin:InRaces(races)
    return ArrayContains(races, self:GetRace())
end

function BtWQuestsCharactersCharacterMixin:IsClass(class)
    return self:GetClass() == class
end
function BtWQuestsCharactersCharacterMixin:InClasses(classes)
    return ArrayContains(classes, self:GetClass())
end

function BtWQuestsCharactersCharacterMixin:AtleastLevel(level)
    return self:GetLevel() >= level
end
function BtWQuestsCharactersCharacterMixin:AtmostLevel(level)
    return self:GetLevel() <= level
end

-- @TODO Should probably just get character related info
function BtWQuestsCharactersCharacterMixin:GetFactionInfoByID(factionID)
    local name
    local tbl = GetFactionDataByID(factionID) or {}
    local factionName, standing, barMin, barMax, value = tbl.name, tbl.reaction, tbl.currentReactionThreshold, tbl.nextReactionThreshold, tbl.currentStanding

    if self.t.reputations then
        local data = self.t.reputations[factionID];
        if data ~= nil then
            if data[1] ~= nil then
                standing, barMin, barMax, value, name = unpack(data);
            else
                standing, barMin, barMax, value, name = data.standing, data.barMin, data.barMax, data.value, data.name;
            end
        else
            standing, barMin, barMax, value = 0, 0, 1, 0
        end
    end

    if factionName == nil and name ~= nil then
        factionName = name
    end

    return factionName, standing, barMin, barMax, value
end

function BtWQuestsCharactersCharacterMixin:HasProfession(profession)
    return self.t.professions[profession] and true or false
end

function BtWQuestsCharactersCharacterMixin:GetSkillInfo(skillID)
    local level, maxLevel = 0, 0;

    if self.t.skills then
        local data = self.t.skills[skillID];
        if data ~= nil then
            if data[1] ~= nil then
                level, maxLevel = unpack(data);
            else
                level, maxLevel = data.level, data.maxLevel;
            end
        end
    end

    return level, maxLevel;
end

function BtWQuestsCharactersCharacterMixin:IsQuestActive(id)
    return self.t.questsActive[id] and true or false
end
function BtWQuestsCharactersCharacterMixin:IsQuestCompleted(id)
    return self.t.questsCompleted[id] and true or false
end

function BtWQuestsCharactersCharacterMixin:IsChainActive(id)
    return BtWQuestsDatabase:IsChainActive(id, self)
end
function BtWQuestsCharactersCharacterMixin:IsChainCompleted(id)
    return BtWQuestsDatabase:IsChainCompleted(id, self)
end

function BtWQuestsCharactersCharacterMixin:IsCategoryActive(id)
    return BtWQuestsDatabase:IsCategoryActive(id, self)
end
function BtWQuestsCharactersCharacterMixin:IsCategoryCompleted(id)
    return BtWQuestsDatabase:IsCategoryCompleted(id, self)
end

function BtWQuestsCharactersCharacterMixin:ToggleCategoryIgnored(id)
    if self.t.ignoredCategories == nil then
        self.t.ignoredCategories = {}
    end

    if self.t.ignoredCategories[id] then
        self.t.ignoredCategories[id] = nil
    else
        self.t.ignoredCategories[id] = true
    end
end
function BtWQuestsCharactersCharacterMixin:SetCategoryIgnored(id, ignore)
    if ignore == false then
        ignore = nil
    end

    if self.t.ignoredCategories == nil then
        self.t.ignoredCategories = {}
    end

    self.t.ignoredCategories[id] = ignore
end
function BtWQuestsCharactersCharacterMixin:IsCategoryIgnored(id)
    return self.t.ignoredCategories and self.t.ignoredCategories[id]
end

function BtWQuestsCharactersCharacterMixin:ToggleChainIgnored(id)
    if self.t.ignoredChains == nil then
        self.t.ignoredChains = {}
    end

    if self.t.ignoredChains[id] then
        self.t.ignoredChains[id] = nil
    else
        self.t.ignoredChains[id] = true
    end
end
function BtWQuestsCharactersCharacterMixin:SetChainIgnored(id, ignore)
    if ignore == false then
        ignore = nil
    end

    if self.t.ignoredChains == nil then
        self.t.ignoredChains = {}
    end

    self.t.ignoredChains[id] = ignore
end
function BtWQuestsCharactersCharacterMixin:IsChainIgnored(id)
    return self.t.ignoredChains and self.t.ignoredChains[id]
end
function BtWQuestsCharactersCharacterMixin:IsChainActive(id)
    return BtWQuestsDatabase:IsChainActive(id, self)
end
function BtWQuestsCharactersCharacterMixin:IsChainCompleted(id)
    return BtWQuestsDatabase:IsChainCompleted(id, self)
end

function BtWQuestsCharactersCharacterMixin:IsCategoryActive(id)
    return BtWQuestsDatabase:IsCategoryActive(id, self)
end
function BtWQuestsCharactersCharacterMixin:IsCategoryCompleted(id)
    return BtWQuestsDatabase:IsCategoryCompleted(id, self)
end

function BtWQuestsCharactersCharacterMixin:ToggleCategoryIgnored(id)
    if self.t.ignoredCategories == nil then
        self.t.ignoredCategories = {}
    end

    if self.t.ignoredCategories[id] then
        self.t.ignoredCategories[id] = nil
    else
        self.t.ignoredCategories[id] = true
    end
end
function BtWQuestsCharactersCharacterMixin:SetCategoryIgnored(id, ignore)
    if ignore == false then
        ignore = nil
    end

    if self.t.ignoredCategories == nil then
        self.t.ignoredCategories = {}
    end

    self.t.ignoredCategories[id] = ignore and true or nil
end
function BtWQuestsCharactersCharacterMixin:IsCategoryIgnored(id)
    return self.t.ignoredCategories and self.t.ignoredCategories[id]
end

function BtWQuestsCharactersCharacterMixin:ToggleChainIgnored(id)
    if self.t.ignoredChains == nil then
        self.t.ignoredChains = {}
    end

    if self.t.ignoredChains[id] then
        self.t.ignoredChains[id] = nil
    else
        self.t.ignoredChains[id] = true
    end
end
function BtWQuestsCharactersCharacterMixin:SetChainIgnored(id, ignore)
    if ignore == false then
        ignore = nil
    end

    if self.t.ignoredChains == nil then
        self.t.ignoredChains = {}
    end

    self.t.ignoredChains[id] = ignore and true or nil
end
function BtWQuestsCharactersCharacterMixin:IsChainIgnored(id)
    return self.t.ignoredChains and self.t.ignoredChains[id]
end

function BtWQuestsCharactersCharacterMixin:GetHeartOfAzerothLevel()
    return self.t.heartOfAzerothLevel or 0
end
function BtWQuestsCharactersCharacterMixin:HeartOfAzerothAtleastLevel(level)
    return self:GetHeartOfAzerothLevel() >= level
end
function BtWQuestsCharactersCharacterMixin:HeartOfAzerothAtmostLevel(level)
    return self:GetHeartOfAzerothLevel() <= level
end

function BtWQuestsCharactersCharacterMixin:GetRenownLevel()
    return self.t.renownLevel or 0
end
function BtWQuestsCharactersCharacterMixin:RenownAtleastLevel(level)
    return self:GetRenownLevel() >= level
end
function BtWQuestsCharactersCharacterMixin:RenownAtmostLevel(level)
    return self:GetRenownLevel() <= level
end
function BtWQuestsCharactersCharacterMixin:GetCovenant()
    return self.t.covenantID or 0
end
function BtWQuestsCharactersCharacterMixin:IsCovenant(id)
    return self:GetCovenant() == id
end
function BtWQuestsCharactersCharacterMixin:InCovenants(ids)
    return ArrayContains(ids, self:GetCovenant())
end
function BtWQuestsCharactersCharacterMixin:GetChromieTimeID()
    return self.t.chromieTimeID or 0
end

function BtWQuestsCharactersCharacterMixin:GetCurrencyQuantity(id)
    return self.t.currencies and self.t.currencies[id] and self.t.currencies[id].quantity or 0;
end
function BtWQuestsCharactersCharacterMixin:GetFriendshipReputation(factionID)
    local id, rep, maxRep, name, text, texture, reaction, threshold, nextThreshold;

    if self.t.friendships then
        local data = self.t.friendships[factionID];
        if type(data) == "table" and data.friendshipFactionID then
            return data;
        elseif data ~= nil then
            if data[1] ~= nil then
                id, rep, maxRep, name, text, texture, reaction, threshold, nextThreshold = unpack(data);
            else
                id, rep, maxRep, name, text, texture, reaction, threshold, nextThreshold = data.id, data.rep, data.maxRep, data.name, data.text, data.texture, data.reaction, data.threshold, data.nextThreshold;
            end
        end
    end

    return {
        friendshipFactionID = id,
        standing = rep,
        maxRep = maxRep,
        name = name,
        text = text,
        texture = texture,
        reaction = reaction,
        reactionThreshold = threshold,
        nextThreshold = nextThreshold,
    };
end
function BtWQuestsCharactersCharacterMixin:GetAchievementInfo(achievementID)
    local id, name, points, completed, month, day, year, description,
    flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID);
    
    if self.t.achievements then
        local data = self.t.achievements[achievementID];
        if data ~= nil then
            id = id or achievementID;

            if data[1] ~= nil then
                id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = unpack(data);
            else
                name, points, completed, rewardText, wasEarnedByMe = data.name, data.points, data.completed, data.rewardText, data.wasEarnedByMe;
            end
        end
    end

    return id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy;

    -- local achievement = (self.t.achievements or {})[achievementID]
    -- if achievement then
    --     return unpack(achievement)
    -- end

    -- return GetAchievementInfo(achievementId)
end
function BtWQuestsCharactersCharacterMixin:GetAchievementCriteriaInfo(achievementID, criteriaIndex)
    local criteriaString, criteriaType, completed, quantity, reqQuantity,
    charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(achievementID, criteriaIndex);
    
    if self.t.achievements then
        local data = self.t.achievements[achievementID];
        if data ~= nil then
            if data[1] ~= nil then
                data = data[15];
            else
                data = data.criterias;
            end

            data = data[criteriaIndex];
            if data then
                if data[1] ~= nil then
                    criteriaString, criteriaType, completed, quantity, reqQuantity,
                    charName, flags, assetID, quantityString, criteriaID, eligible = unpack(data);
                else
                    criteriaString, completed, criteriaID = data.criteriaString, data.completed, data.criteriaID;
                end
            end
        end
    end

    return criteriaString, criteriaType, completed, quantity, reqQuantity,
    charName, flags, assetID, quantityString, criteriaID, eligible;

    -- local achievement = (self.t.achievements or {})[achievementId];
    -- if achievement then
    --     local criteria = achievement.criterias[criteriaIndex]
    --     return unpack(criteria or {})
    -- end

    -- return GetAchievementCriteriaInfo(achievementId, criteriaIndex)
end
function BtWQuestsCharactersCharacterMixin:GetAchievementCriteriaInfoByID(achievementID, criteriaID)
    local criteriaString, criteriaType, completed, quantity, reqQuantity,
    charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfoByID(achievementID, criteriaID);
    
    if self.t.achievements then
        local data = self.t.achievements[achievementID];
        if data ~= nil then
            if data[1] ~= nil then
                data = data[15];
            else
                data = data.criteria;
            end

            for _,data in pairs(data) do
                if data and data.criteriaID == criteriaID then
                    if data[1] ~= nil then
                        criteriaString, criteriaType, completed, quantity, reqQuantity,
                        charName, flags, assetID, quantityString, criteriaID, eligible = unpack(data);
                    else
                        criteriaString, completed, criteriaID = data.criteriaString, data.completed, data.criteriaID;
                    end

                    break;
                end
            end
        end
    end

    return criteriaString, criteriaType, completed, quantity, reqQuantity,
    charName, flags, assetID, quantityString, criteriaID, eligible;
end
function BtWQuestsCharactersCharacterMixin:GetXPModifier()
    return self.t.xpModifier or 0;
end
function BtWQuestsCharactersCharacterMixin:IsWarModeDesired()
    return self.t.warMode or false;
end
function BtWQuestsCharactersCharacterMixin:GetWarModeRewardBonus()
    -- Only one faction can get an increase war mode bonus, if we arent the players faction
    -- and the player has over the default warmode bonus then we have the default
    if self:IsFaction(select(2, UnitFactionGroup("player"))) then
        return C_PvP.GetWarModeRewardBonus()
    else
        if C_PvP.GetWarModeRewardBonus() ~= C_PvP.GetWarModeRewardBonusDefault() then
            return C_PvP.GetWarModeRewardBonusDefault();
        else
            return self.t.warModeBonus or C_PvP.GetWarModeRewardBonusDefault();
        end
    end
end
function BtWQuestsCharactersCharacterMixin:GetNumQuestLeaderBoards(questID)
    local questID = tonumber(questID);
    local quest = self.t.questsActive[questID];
    if type(quest) == "table" then
        return #quest;
    else
        return GetNumQuestLeaderBoards(questID);
    end
end
function BtWQuestsCharactersCharacterMixin:GetQuestLogLeaderBoard(index, questID)
    local questID = tonumber(questID);
    local quest = self.t.questsActive[questID];
    if type(quest) == "table" and quest[index] then
        return unpack(quest[index]);
    else
        local name, type = GetQuestLogLeaderBoard(index, questID);
        return name, type, false;
    end
end


BtWQuestsCharactersPlayerMixin = Mixin({}, BtWQuestsCharactersCharacterMixin)
function BtWQuestsCharactersPlayerMixin:IsPlayer()
    return true
end
function BtWQuestsCharactersPlayerMixin:GetFullName()
    return UnitName("player"), GetRealmName()
end
function BtWQuestsCharactersPlayerMixin:GetName()
    return UnitName("player")
end
function BtWQuestsCharactersPlayerMixin:GetRealm()
    return GetRealmName()
end
function BtWQuestsCharactersPlayerMixin:GetFaction()
    return UnitFactionGroup("player")
end
function BtWQuestsCharactersPlayerMixin:GetRace()
    return select(2, UnitRace("player"))
end
function BtWQuestsCharactersPlayerMixin:GetClass()
    return select(3, UnitClass("player"))
end
function BtWQuestsCharactersPlayerMixin:GetClassString()
    return select(2, UnitClass("player"))
end
function BtWQuestsCharactersPlayerMixin:GetLevel()
    return UnitLevel("player")
end
function BtWQuestsCharactersPlayerMixin:GetSex()
    return UnitSex("player")
end
if C_TradeSkillUI then
    function BtWQuestsCharactersPlayerMixin:GetSkillInfo(skillID)
        if C_TradeSkillUI.GetProfessionInfoBySkillLineID then
            local result = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillID)
            return result and result.skillLevel or 0, result and result.maxSkillLevel or 0
        else
            local _, level, maxLevel = C_TradeSkillUI.GetTradeSkillLineInfoByID(skillID)
            return level, maxLevel
        end
    end
end
function BtWQuestsCharactersPlayerMixin:GetFactionInfoByID(factionID)
    local tbl = GetFactionDataByID(factionID) or {}
    local factionName, standing, barMin, barMax, value = tbl.name, tbl.reaction, tbl.currentReactionThreshold, tbl.nextReactionThreshold, tbl.currentStanding

    return factionName, standing, barMin, barMax, value
end
function BtWQuestsCharactersPlayerMixin:IsQuestActive(questID)
    local index = GetLogIndexForQuestID(questID)
    return index and index > 0
end
function BtWQuestsCharactersPlayerMixin:IsQuestCompleted(questID)
    if C_QuestSession.HasJoined() then
        return BtWQuestsCharactersCharacterMixin.IsQuestCompleted(self, questID)
    else
        return IsQuestFlaggedCompleted(questID)
    end
end
function BtWQuestsCharactersPlayerMixin:GetHeartOfAzerothLevel()
    if C_AzeriteItem.HasActiveAzeriteItem() then
        local itemLocation = C_AzeriteItem.FindActiveAzeriteItem();
        if itemLocation and itemLocation:IsValid() then
            return C_AzeriteItem.GetPowerLevel(itemLocation)
        end
    end

    return BtWQuestsCharactersCharacterMixin.GetHeartOfAzerothLevel(self)
end
function BtWQuestsCharactersPlayerMixin:GetCurrencyQuantity(id)
    local info = C_CurrencyInfo.GetCurrencyInfo(id);
    return info and info.quantity or 0
end
function BtWQuestsCharactersPlayerMixin:GetFriendshipReputation(factionId)
    return C_GossipInfo.GetFriendshipReputation(factionId)
end
function BtWQuestsCharactersPlayerMixin:GetAchievementInfo(achievementId)
    return GetAchievementInfo(achievementId)
end
function BtWQuestsCharactersPlayerMixin:GetAchievementCriteriaInfo(achievementId, criteriaIndex)
    return GetAchievementCriteriaInfo(achievementId, criteriaIndex)
end
function BtWQuestsCharactersPlayerMixin:GetAchievementCriteriaInfoByID(achievementId, criteriaId)
    return GetAchievementCriteriaInfoByID(achievementId, criteriaId)
end
function BtWQuestsCharactersPlayerMixin:GetRenownLevel()
    return C_CovenantSanctumUI.GetRenownLevel()
end
function BtWQuestsCharactersPlayerMixin:GetCovenant()
    return C_Covenants.GetActiveCovenantID()
end
function BtWQuestsCharactersPlayerMixin:GetChromieTimeID()
    return UnitChromieTimeID("player")
end

local xpTooltip = CreateFrame("GameTooltip", "BtWQuestsCharactersXPTooltip", UIParent, "GameTooltipTemplate");
local itemXPBySlot = {
    [INVSLOT_HEAD]     = 0.1,
    [INVSLOT_SHOULDER] = 0.1,
    [INVSLOT_CHEST]    = 0.1,
    [INVSLOT_LEGS]     = 0.1,
    [INVSLOT_FINGER1]  = 0.05,
    [INVSLOT_FINGER2]  = 0.05,
    [INVSLOT_BACK]     = 0.05,
};
local itemXpCache = {};
local gemXpByID = {
    [153714] = 0.05,
};
if not TooltipDataProcessor or not TooltipDataProcessor.AddTooltipPostCall then
    xpTooltip:SetScript("OnTooltipSetItem", function (self)
        local itemName, itemLink = self:GetItem();
    
        for i=1,15 do
            local text = _G[self:GetName().."TextLeft"..i];
            if text and text:IsShown() then
                local text = text:GetText();
                local percent = string.match(text, "^Equip: Experience gained is increased by ([%d]+)%%.$");
                if not percent then
                    percent = string.match(text, "^Equip: Experience gained from killing monsters and completing quests increased by ([%d]+)%%.$");
                end
    
                if percent then
                    itemXpCache[itemLink] = tonumber(percent) * 0.01;
                    break
                end
            end
        end
    end)
end
local function PlayerXPModifier()
    local modifier = 0;
    if GetItemGem then
        for inventorySlotId=INVSLOT_HEAD,INVSLOT_TABARD do
            local itemLink = GetInventoryItemLink("player", inventorySlotId);
            if itemLink then
                for index=1,3 do
                    local _, gemLink = GetItemGem(itemLink, index);
                    if gemLink then
                        local itemID = GetItemInfoInstant(gemLink);
                        if gemXpByID[itemID] then
                            modifier = modifier + gemXpByID[itemID];
                        end
                    end
                end
            end
        end
    end
    return modifier;
end
function BtWQuestsCharactersPlayerMixin:GetXPModifier()
    return PlayerXPModifier();
end
function BtWQuestsCharactersPlayerMixin:IsWarModeDesired()
    return C_PvP and C_PvP.IsWarModeDesired and C_PvP.IsWarModeDesired() or false;
end
function BtWQuestsCharactersPlayerMixin:GetWarModeRewardBonus()
    return C_PvP and C_PvP.GetWarModeRewardBonus and C_PvP.GetWarModeRewardBonus() or 0;
end

function BtWQuestsCharactersPlayerMixin:GetNumQuestLeaderBoards(questID)
    local index = GetLogIndexForQuestID(questID);
    return index and GetNumQuestLeaderBoards(index);
end
function BtWQuestsCharactersPlayerMixin:GetQuestLogLeaderBoard(objective, questID)
    local index = GetLogIndexForQuestID(questID);
    return index and GetQuestLogLeaderBoard(objective, index);
end

BtWQuestsCharactersPartySyncMixin = Mixin({}, BtWQuestsCharactersPlayerMixin)
function BtWQuestsCharactersPartySyncMixin:IsPartySync()
    return true
end
function BtWQuestsCharactersPartySyncMixin:GetName()
    return BtWQuests.L["Party Sync"];
end
function BtWQuestsCharactersPartySyncMixin:GetFullName()
    return "", "partysync"
end
function BtWQuestsCharactersPartySyncMixin:GetDisplayName()
    return self:GetName();
end
function BtWQuestsCharactersPartySyncMixin:GetLevel()
    return UnitEffectiveLevel("player");
end
function BtWQuestsCharactersPartySyncMixin:IsQuestActive(questID)
    if C_QuestLog.IsQuestDisabledForSession(questID) then
        return true
    end
    local index = GetLogIndexForQuestID(questID)
    return index and index > 0
end
function BtWQuestsCharactersPartySyncMixin:IsQuestCompleted(questID)
    return IsQuestFlaggedCompleted(questID)
end

BtWQuestsCharactersWarbandMixin = Mixin({}, BtWQuestsCharactersPlayerMixin)
function BtWQuestsCharactersWarbandMixin:IsWarband()
    return true
end
function BtWQuestsCharactersWarbandMixin:GetName()
    return BtWQuests.L["Warband"];
end
function BtWQuestsCharactersWarbandMixin:GetFullName()
    return "", "warband"
end
function BtWQuestsCharactersWarbandMixin:GetDisplayName()
    return self:GetName();
end
function BtWQuestsCharactersWarbandMixin:GetLevel()
    return GetAccountPlayerLevel();
end
function BtWQuestsCharactersWarbandMixin:IsQuestCompleted(questID)
    return C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID)
end

BtWQuestsCharacters = {}
local BtWQuests_CharactersMap = nil
local function BtWQuestsCharactersUpdateMap()
    if BtWQuests_Characters == nil then
        BtWQuests_Characters = {}
    end

    BtWQuests_CharactersMap = {}
    for i=#BtWQuests_Characters,1,-1 do
        local character = BtWQuests_Characters[i]
        -- Remove any character missing a name or realm, this is to fix an issue caused by setting these values only on logout
        if not character.name or not character.realm then
            BtWQuests_Characters[i] = nil
        else
            local key = character.name .. "-" .. character.realm
            BtWQuests_CharactersMap[key] = character
        end
    end

    table.sort(BtWQuests_Characters, function(a, b)
        return (a.name .. "-" .. a.realm) < (b.name .. "-" .. b.realm)
    end)
end

local function BtWQuestsCharactersNextPairs(self, prev)
    local key = next(BtWQuests_CharactersMap, prev)
    return key, self:GetCharacter(key)
end
function BtWQuestsCharacters:pairs()
    if BtWQuests_CharactersMap == nil then
        BtWQuestsCharactersUpdateMap()
    end

    return BtWQuestsCharactersNextPairs, self, nil
end

local function BtWQuestsCharactersNextIPairs(self, prev)
    local index, value = next(BtWQuests_Characters, prev)
    if index == nil or value == nil then
        return nil
    end
    local key = value.name .. "-" .. value.realm
    return index, key, self:GetCharacter(key)
end
function BtWQuestsCharacters:ipairs()
    return BtWQuestsCharactersNextIPairs, self, nil
end

function BtWQuestsCharacters:HasCharacter(name, realm)
    local key
    if realm == nil then
        key = name
    else
        key = name .. "-" .. realm
    end

    if BtWQuests_CharactersMap == nil then
        BtWQuestsCharactersUpdateMap()
    end

    return BtWQuests_CharactersMap[key] ~= nil
end
function BtWQuestsCharacters:GetCharacter(name, realm)
    local key
    if realm == nil then
        key = name
    else
        key = name .. "-" .. realm
    end

    if BtWQuests_CharactersMap == nil then
        BtWQuestsCharactersUpdateMap()
    end

    if BtWQuestsCharactersMap[key] == nil then
        local playerName = UnitName("player")
        local playerRealm = GetRealmName()
        local playerKey = playerName .. "-" .. playerRealm

        if key == "-partysync" then
            BtWQuestsCharactersMap[key] = BtWQuests_CreatePartySync(BtWQuests_CharactersMap[playerKey])
        elseif key == "-warband" then
            BtWQuestsCharactersMap[key] = BtWQuests_CreateWarband(BtWQuests_CharactersMap[playerKey])
        elseif playerKey == key then
            -- Insert player in to data if they are missing. This generally happens before OnEvent is called which will fill any missing details
            if not BtWQuests_CharactersMap[key] then
                BtWQuests_CharactersMap[key] = {}
                table.insert(BtWQuests_Characters, BtWQuests_CharactersMap[key])
            end

            BtWQuestsCharactersMap[key] = BtWQuests_CreatePlayer(BtWQuests_CharactersMap[key])
        elseif BtWQuests_CharactersMap[key] ~= nil then
            BtWQuestsCharactersMap[key] = BtWQuests_CreateCharacter(BtWQuests_CharactersMap[key])
        end
    end

    return BtWQuestsCharactersMap[key]
end
function BtWQuestsCharacters:RemoveCharacter(name, realm)
    local key
    if realm == nil then
        key = name
    else
        key = name .. "-" .. realm
    end

    for i=1,#BtWQuests_Characters do
        if BtWQuests_CharactersMap[key] == BtWQuests_Characters[i] then
            table.remove(BtWQuests_Characters, i)
            BtWQuests_CharactersMap[key] = nil
            BtWQuestsCharactersMap[key] = nil
        end
    end
end
function BtWQuestsCharacters:GetPlayer()
    if C_QuestSession and C_QuestSession.HasJoined() then
        return self:GetCharacter("-partysync")
    else
        return self:GetCharacter(UnitName("player"), GetRealmName())
    end
end

local temp = {};
local function GetFactions(tbl)
    local tbl = tbl or {};

    for id,data in pairs(tbl) do
        temp[id] = data;
    end

    wipe(tbl);
    local numEntries = GetNumFactions();
    for i=1,numEntries do
        -- local name, _, standing, barMin, barMax, barValue, _, _, _, _, _, _, _, factionID = GetFactionInfo(i);
        local factionData = GetFactionDataByIndex(i);
        if factionData and factionData.factionID ~= nil then
            local data = temp[factionData.factionID] or {};
            if data[1] ~= nil then
                wipe(data);
            end

            data.name = name;

            data.standing = factionData.reaction;

            data.barMin = factionData.currentReactionThreshold;
            data.barMax = factionData.nextReactionThreshold;
            data.barValue = factionData.currentStanding;
            
            tbl[factionData.factionID] = data;
        end
    end

    wipe(temp);
    return tbl;
end
local function GetKnownProfessions(tbl, ...)
    local tbl = tbl or {};

    wipe(tbl);
    for i=1,select('#', ...) do
        local index = select(i,...);
        if index ~= nil then
            local id = select(7, GetProfessionInfo(index));
            tbl[id] = true;
        end
    end

    return tbl;
end
local function GetAchievementCriterias(tbl, achievementID)
    local tbl = tbl or {};

    wipe(tbl);
    local numEntries = GetAchievementNumCriteria(achievementID);
    for i=1,numEntries do
        local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(achievementID, i);
        if criteriaString ~= nil then
            local data = tbl[i] or {};

            data.criteriaString = criteriaString;
            data.completed = completed;
            data.criteriaID = criteriaID;
            
            tbl[i] = data;
        end
    end

    return tbl;
end
local function GetAchievements(tbl, achievements)
    local tbl = tbl or {};

    for id,data in pairs(tbl) do
        temp[id] = data;
    end

    wipe(tbl);
    for achievementID in pairs(achievements) do
        local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID);
        if id ~= nil then
            local data = temp[achievementID] or {};
            if data[1] ~= nil then
                wipe(data);
            end

            data.name = name;
            data.points = points;
            data.completed = completed;
            data.rewardText = rewardText;
            data.wasEarnedByMe = wasEarnedByMe;
            
            data.criterias = GetAchievementCriterias(data.criterias, achievementID);
            
            tbl[achievementID] = data;
        end
    end

    wipe(temp);
    return tbl;
end
local function GetFriendships(tbl, friendships)
    local tbl = tbl or {};

    wipe(tbl);
    for factionID in pairs(friendships) do
        tbl[factionID] = C_GossipInfo.GetFriendshipReputation(factionID);
    end

    return tbl;
end
local function GetCurrencies(tbl, currencies)
    local tbl = tbl or {};

    wipe(tbl);
    for id in pairs(currencies) do
        tbl[id] = C_CurrencyInfo.GetCurrencyInfo(id);
    end

    return tbl;
end
local function GetSkills(tbl)
    local tbl = tbl or {};

    for id,data in pairs(tbl) do
        temp[id] = data;
    end

    wipe(tbl);
    local skillIDs = C_TradeSkillUI.GetAllProfessionTradeSkillLines()
    for _,skillID in ipairs(skillIDs) do
        local _, level, maxLevel
        if C_TradeSkillUI.GetProfessionInfoBySkillLineID then
            local result = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillID)
            level, maxLevel = result and result.skillLevel or 0, result and result.maxSkillLevel or 0
        else
            _, level, maxLevel = C_TradeSkillUI.GetTradeSkillLineInfoByID(skillID)
        end
        if level ~= 0 then
            local data = temp[skillID] or {};
            if data[1] ~= nil then
                wipe(data);
            end

            data.level = level;
            data.maxLevel = maxLevel;
            
            tbl[skillID] = data;
        end
    end

    wipe(temp);
    return tbl;
end
function BtWQuestsCharacters:OnEvent(event, ...)
    local name = UnitName("player");
    local realm = GetRealmName();
    if not name or not realm then
        return;
    end

    if BtWQuests_CharactersMap == nil then
        BtWQuestsCharactersUpdateMap()
    end

    local key = name .. "-" .. realm
    if BtWQuests_CharactersMap[key] == nil then
        BtWQuests_CharactersMap[key] = {}
        table.insert(BtWQuests_Characters, BtWQuests_CharactersMap[key])
    end

    local character = BtWQuests_CharactersMap[key]
    character.name = name;
    character.realm = realm;

    -- Some of these dont work during logout or even leaving world so they update with different events
    if event == "ACHIEVEMENT_EARNED" or event == "PLAYER_ENTERING_WORLD" then
        character.achievements = GetAchievements(character.achievements, self.achievements or {});
    end
    if event == "TRADE_SKILL_LIST_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        if C_TradeSkillUI and C_TradeSkillUI.GetAllProfessionTradeSkillLines then
            character.skills = GetSkills(character.skills);
        end
        if GetProfessions then
            character.professions = GetKnownProfessions(character.professions, GetProfessions());
        end
    end
    if event == "QUEST_ACCEPTED" or event == "QUEST_COMPLETE" or event == "QUEST_REMOVED" or event == "QUEST_TURNED_IN" or event == "PLAYER_ENTERING_WORLD" then
        character.questsActive = character.questsActive or {}
        character.questsCompleted = character.questsCompleted or {}

        wipe(character.questsActive)
        wipe(character.questsCompleted)
        
        character.questsActive = GetQuestsActive(character.questsActive);
        character.questsCompleted = GetQuestsCompleted(character.questsCompleted);
    end
    if C_PvP.IsWarModeDesired then
        if event == "WAR_MODE_STATUS_UPDATE" or event == "PLAYER_FLAGS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
            character.warMode = C_PvP.IsWarModeDesired();
            character.warModeBonus = C_PvP.GetWarModeRewardBonus();
        end
    end
    if event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        character.xpModifier = PlayerXPModifier();
    end
    if event == "COVENANT_CHOSEN" or event == "PLAYER_LOGIN" then
        character.covenantID = C_Covenants and C_Covenants.GetActiveCovenantID() or nil
        character.friendships = GetFriendships(character.friendships, self.friendships or {});
    end
    if event == "PLAYER_LOGOUT" then
        character.faction = UnitFactionGroup("player");
        character.sex = UnitSex("player");
        character.class = select(3, UnitClass("player"));
        character.race = select(2, UnitRace("player"));
        character.level = UnitLevel("player") or character.level;
        
        character.reputations = GetFactions(character.reputations);
        character.friendships = GetFriendships(character.friendships, self.friendships or {});
        character.currencies = GetCurrencies(character.currencies, self.currencies or {});

        if C_AzeriteItem and C_AzeriteItem.HasActiveAzeriteItem() then
            local itemLocation = C_AzeriteItem.FindActiveAzeriteItem();
            if itemLocation and itemLocation:IsValid() then
                character.heartOfAzerothLevel = C_AzeriteItem.GetPowerLevel(itemLocation)
            end
        end

        character.renownLevel = C_CovenantSanctumUI and C_CovenantSanctumUI.GetRenownLevel() or 0
        character.chromieTimeID = UnitChromieTimeID and UnitChromieTimeID("player") or 0

        character.ignoredChains = character.ignoredChains or (BtWQuests_Settings and BtWQuests_Settings.ignoredChains or {});
        character.ignoredCategories = character.ignoredCategories or (BtWQuests_Settings and BtWQuests_Settings.ignoredCategories or {});
    end
end

function BtWQuestsCharacters:AddFriendshipReputation(factionId)
    if self.friendships == nil then
        self.friendships = {}
    end
    self.friendships[factionId] = true;
end
function BtWQuestsCharacters:AddCurrency(id)
    if self.currencies == nil then
        self.currencies = {}
    end
    self.currencies[id] = true;
end
function BtWQuestsCharacters:AddAchievement(achievementId)
    if self.achievements == nil then
        self.achievements = {}
    end
    self.achievements[achievementId] = true;
end

function BtWQuests_CreatePlayer(data)
    return Mixin({t = data}, BtWQuestsCharactersPlayerMixin)
end

function BtWQuests_CreatePartySync(data)
    return Mixin({t = data}, BtWQuestsCharactersPartySyncMixin)
end

function BtWQuests_CreateWarband(data)
    return Mixin({t = data}, BtWQuestsCharactersWarbandMixin)
end

function BtWQuests_CreateCharacter(data)
    return Mixin({t = data}, BtWQuestsCharactersCharacterMixin)
end

local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD");
eventHandler:RegisterEvent("TRADE_SKILL_LIST_UPDATE");
eventHandler:RegisterEvent("QUEST_ACCEPTED");
eventHandler:RegisterEvent("QUEST_COMPLETE");
eventHandler:RegisterEvent("QUEST_REMOVED");
eventHandler:RegisterEvent("QUEST_TURNED_IN");
eventHandler:RegisterEvent("PLAYER_LOGIN");
eventHandler:RegisterEvent("PLAYER_FLAGS_CHANGED");
eventHandler:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
eventHandler:RegisterEvent("PLAYER_LEAVING_WORLD");
eventHandler:RegisterEvent("PLAYER_LOGOUT");
if GetAchievementInfo then
    eventHandler:RegisterEvent("ACHIEVEMENT_EARNED");
end
if C_PvP and C_PvP.IsWarModeDesired then
    eventHandler:RegisterEvent("WAR_MODE_STATUS_UPDATE");
end
if C_Covenants and C_PvP.IsWarModeDesired then
    eventHandler:RegisterEvent("COVENANT_CHOSEN");
end

eventHandler:SetScript("OnEvent", function (self, event, ...)
    BtWQuestsCharacters:OnEvent(event, ...)
end)

BtWQuests.Characters = BtWQuestsCharacters;
