--[[
@Date    : 2016-06-15 12:09:45
@Author  : DengSir (ldz5@qq.com)
@Link    : https://dengsir.github.io
@Version : $Id$
]]

BuildEnv(...)

FollowQuery = Addon:NewClass('FollowQuery', Object)

FollowQuery:InitAttr{
    'Name',
    'Guid',
    'Class',
    'Level',
    'ItemLevel',
    'Sex',
    'TimeStamp',
}

FollowQuery._Objects = setmetatable({}, {__mode = 'v'})

function FollowQuery:Constructor(name)
    self:SetName(name)
    self._Objects[name] = self
end

function FollowQuery:Get(name)
    return self._Objects[name] or self:New(name)
end

function FollowQuery:GetNameText()
    local color = RAID_CLASS_COLORS[self:GetClass()]
    local name, realm = strsplit('-', self:GetName())
    return format('|c%s%s|r-%s', color.colorStr, name, realm)
end

function FollowQuery:GetSexTexture()
    if self:GetSex() == 2 then
        return [[Interface\AddOns\MeetingStone\Media\Female]]
    elseif self:GetSex() == 3 then
        return [[Interface\AddOns\MeetingStone\Media\Male]]
    else
        return 0, 0, 0, 0
    end
end