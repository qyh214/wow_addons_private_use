
BuildEnv(...)

BaseActivity = Addon:NewClass('BaseActivity', Object)

BaseActivity:InitAttr{
    'ActivityID',
    'GroupID',
    'CustomID',
    'VoiceChat',
    'ItemLevel',
    'HonorLevel',
    'Name',

    'Summary',
    'Comment',
    'MinLevel',
    'MaxLevel',
    'PvPRating',
    'Source',

    'Mode',
    'Loot',
    'Version',
    'IsMeetingStone',

    'Leader',
    'LeaderClass',
    'LeaderItemLevel',
    'LeaderHonorLevel',
    'LeaderProgression',
    'LeaderPvPRating',

    'SavedInstance',
}

function BaseActivity:GetModeText()
    return GetModeName(self:GetMode())
end

function BaseActivity:GetLootShortText()
    return GetLootShortName(self:GetLoot())
end

function BaseActivity:GetLootText()
    return GetLootName(self:GetLoot())
end

function BaseActivity:GetLeaderText()
    return GetClassColoredText(self:GetLeaderClass(), self:GetLeader())
end

function BaseActivity:GetLeaderShortText()
    return GetClassColoredText(self:GetLeaderClass(), self:GetLeaderShort())
end

function BaseActivity:GetCode()
    return GetActivityCode(self:GetActivityID(), self:GetCustomID())
end

function BaseActivity:UpdateCustomData(comment, title)
    local summary, isMeetingStone, customId, version, mode, loot,
            class, itemLevel, progression, leaderPvPRating, minLevel, maxLevel, pvpRating, source, creator, savedInstance, _, honorLevel = DecodeCommetData(comment)

    if isMeetingStone then
        if customId == 0 then
            customId = nil
        end
        local changeTo = ACTIVITY_CUSTOM_CHANGETO[customId]
        if changeTo then
            customId = nil
            self:SetActivityID(changeTo)
        end
        self:SetVersion(version)
        self:SetMode(mode)
        self:SetLoot(loot)
        self:SetSummary(summary)
        self:SetComment(nil)
        self:SetCustomID(customId)
        self:SetMinLevel(minLevel or 1)
        self:SetMaxLevel(maxLevel or MAX_PLAYER_LEVEL)
        self:SetPvPRating(pvpRating or 0)
        self:SetSource(source)
        self:SetSavedInstance(savedInstance)

        creator = creator and Ambiguate(creator, 'none')
        if creator and creator ~= self:GetLeader() then
            self:SetLeaderClass(nil)
            self:SetLeaderItemLevel(nil)
            self:SetLeaderPvPRating(nil)
            self:SetLeaderProgression(nil)
            self:SetLeaderHonorLevel(nil)
        else
            self:SetLeaderClass(class)
            self:SetLeaderItemLevel(itemLevel)
            self:SetLeaderPvPRating(leaderPvPRating)
            self:SetLeaderProgression(progression)
            self:SetLeaderHonorLevel(honorLevel)
        end
    else
        self:SetVersion(nil)
        self:SetMode(0xFF)
        self:SetLoot(0xFF)
        self:SetLeaderClass(nil)
        self:SetLeaderItemLevel(nil)
        self:SetLeaderProgression(nil)
        self:SetSummary(title)
        self:SetComment(summary)
        self:SetCustomID(nil)
        self:SetMinLevel(1)
        self:SetMaxLevel(MAX_PLAYER_LEVEL)
        self:SetPvPRating(0)
        self:SetSource(nil)
        self:SetSavedInstance(nil)
    end
    self:SetIsMeetingStone(isMeetingStone)
end

function BaseActivity:HasInvalidContent()
    return CheckContent(self:GetSummary()) or CheckContent(self:GetComment()) or CheckContent(self:GetVoiceChat())
end

function BaseActivity:CheckSpamWord()
    return CheckSpamWord(self:GetSummary()) or CheckSpamWord(self:GetComment()) or CheckSpamWord(self:GetVoiceChat())
end

function BaseActivity:GetName()
    return GetActivityName(self:GetActivityID(), self:GetCustomID())
end

function BaseActivity:GetShortName()
    return GetActivityShortName(self:GetActivityID(), self:GetCustomID())
end

function BaseActivity:IsUseHonorLevel()
    return IsUseHonorLevel(self:GetActivityID())
end

function BaseActivity:IsSoloActivity()
    return IsSoloCustomID(self:GetCustomID())
end
