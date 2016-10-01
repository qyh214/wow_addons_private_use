
BuildEnv(...)

CurrentActivity = Addon:NewClass('CurrentActivity', BaseActivity)

CurrentActivity:InitAttr{
    'Title',
}

function CurrentActivity:FromAddon(data)
    local obj = CurrentActivity:New()
    obj:_FromAddon(data)
    return obj
end

function CurrentActivity:FromSystem(...)
    local obj = CurrentActivity:New()
    obj:_FromSystem(...)
    return obj
end

function CurrentActivity:_FromAddon(data)
    for k, v in pairs(data) do
        local func = self['Set' .. k]
        if type(func) == 'function' then
            func(self, v)
        end
    end
end

function CurrentActivity:_FromSystem(activityId, ilvl, honorLevel, title, comment, voiceChat)
    self:SetActivityID(activityId)
    self:SetItemLevel(ilvl)
    self:SetHonorLevel(honorLevel)
    self:SetVoiceChat(voiceChat)
    self:UpdateCustomData(comment, title)
end

function CurrentActivity:GetTitle()
    return format('%s-%s-%s-%s', L['集合石'], self:GetLootText(), self:GetModeText(), self:GetName())
end

function CurrentActivity:GetCreateArguments(autoAccept)
    local comment = CodeCommentData(self)
    return  self:GetActivityID(),
            self:GetTitle(),
            self:GetItemLevel(),
            self:GetHonorLevel(),
            self:GetVoiceChat(),
            self:GetSummary() .. comment,
            autoAccept
end