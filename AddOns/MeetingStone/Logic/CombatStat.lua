-- CombatStat.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io/
-- @Date   : 2017-9-8 10:35:51

BuildEnv(...)

CombatStat = Addon:NewModule('CombatStat', 'AceEvent-3.0', 'AceTimer-3.0')
CombatStat:Disable()

function CombatStat:OnInitialize()
    self.units = {}
    self.groupUnits = {}
    self.data = Profile:GetCombatData()

    -- self:Debug()
end

function CombatStat:OnEnable()
    self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    self:RegisterEvent('UNIT_PET')
    self:RegisterEvent('GROUP_ROSTER_UPDATE', 'UpdateGroupUnits')

    self:UpdateUnits()
    self:UpdateGroupUnits()
    self:OnCombatTimer()
    self.combatTimer = self:ScheduleRepeatingTimer('OnCombatTimer', 3)
    
end

function CombatStat:Reset()
    self.units = {}
    self.data = Profile:ResetCombatData()
    self:CancelTimer(self.combatTimer)
    
end
CombatStat.OnDisable = Reset

function CombatStat:UpdateGroupUnits()
    wipe(self.groupUnits)

    for _, unit in IterateGroupUnits() do
        local guid = UnitGUID(unit)
        if guid then
            self.groupUnits[guid] = true
        end
    end
end

function CombatStat:OnCombatTimer()
    if not self:IsGroupInCombat() then
        self:LeaveCombat()
    end
end

function CombatStat:EnterCombat(timestamp)
    if self.combatTick then
        self:Touch('time', timestamp - self.combatTick)
    end
    self.combatTick = timestamp
end

function CombatStat:LeaveCombat()
    self.combatTick = nil
end

function CombatStat:IsGroupInCombat()
    for _, unit in IterateGroupUnits() do
        if UnitAffectingCombat(unit) then
            return true
        end
    end
    return UnitAffectingCombat('player')
end

function CombatStat:Touch(key, amount)
    self.data[key] = (self.data[key] or 0) + amount
end

function CombatStat:UNIT_PET(_, unit)
    if unit ~= 'player' then
        return
    end
    self:UpdateUnits()
end

function CombatStat:UpdateUnits()
    self.units[UnitGUID('player')] = 'player'

    local petGuid = UnitGUID('pet')
    if petGuid then
        self.units[petGuid] = 'pet'
    end
end

function CombatStat:COMBAT_LOG_EVENT_UNFILTERED(_, timestamp, event, _, srcGuid, srcName, srcFlags, _, destGuid, _, dstFlags, _, ...)
    if not self[event] then
        return
    end
    -- if not (self:IsUnitSelf(srcGuid) or self:IsUnitSelf(destGuid)) then
    --     return
    -- end
    self[event](self, timestamp, srcGuid, destGuid, ...)
end

function CombatStat:SWING_DAMAGE(timestamp, srcGuid, destGuid, amount)
    if self:IsUnitFriend(srcGuid) then
        self:EnterCombat(timestamp)
    end
    if not (self:IsUnitSelf(srcGuid) or self:IsUnitSelf(destGuid)) then
        return
    end

    if self:IsUnitSelf(srcGuid) then
        return self:Touch('dd', amount)
    elseif not self:IsUnitPet(srcGuid) then
        return self:Touch('dt', amount)
    end
end

function CombatStat:SPELL_DAMAGE(timestamp, srcGuid, destGuid, _, _, _, amount)
    return self:SWING_DAMAGE(timestamp, srcGuid, destGuid, amount)
end

function CombatStat:SPELL_HEAL(timestamp, srcGuid, destGuid, _, _, _, amount, overhealing)
    if self:IsUnitSelf(srcGuid) then
        local amount = amount - overhealing
        if amount > 0 then
            return self:Touch('hd', amount)
        end
    end
end

function CombatStat:UNIT_DIED(_, srcGuid, destGuid)
    if self:IsUnitSelf(destGuid) then
        return self:Touch('dead',1)
    end
end

function CombatStat:SPELL_SUMMON(timestamp, srcGuid, destGuid)
    if self:IsUnitSelf(srcGuid) then
        self.units[destGuid] = 'pet'
    end
end

CombatStat.SPELL_PERIODIC_DAMAGE = CombatStat.SPELL_DAMAGE
CombatStat.SPELL_BUILDING_DAMAGE = CombatStat.SPELL_DAMAGE
CombatStat.RANGE_DAMAGE = CombatStat.SPELL_DAMAGE
CombatStat.DAMAGE_SPLIT = CombatStat.SPELL_DAMAGE
CombatStat.DAMAGE_SHIELD = CombatStat.SPELL_DAMAGE
CombatStat.SPELL_PERIODIC_HEAL = CombatStat.SPELL_HEAL

function CombatStat:IsUnitSelf(guid)
    return self.units[guid]
end

function CombatStat:IsUnitPet(guid)
    return self.units[guid] == 'pet'
end

function CombatStat:IsUnitFriend(guid)
    return self.groupUnits[guid] or self.units[guid]
end

function CombatStat:GetCombatData()
    local time = self.data.time == 0 and 0xFFFFFFFF or self.data.time
    return {
        dd = self.data.dd,
        dt = self.data.dt,
        hd = self.data.hd,
        dps = floor(self.data.dd / time),
        hps = floor(self.data.hd / time),
        dead = self.data.dead,
    }
end

local templates = [[
dt: %d
dd: %d
dps: %d
hd: %d
hps: %d
dead: %d
%s
]]

function CombatStat:Debug()
    local f = CreateFrame('Frame', nil, UIParent) do
        f:SetPoint('LEFT')
        f:SetSize(200, 200)

        local bg = f:CreateTexture(nil, 'BACKGROUND') do
            bg:SetColorTexture(0,0,0,0.3)
            bg:SetAllPoints(true)
        end

        local text = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLeft') do
            text:SetPoint('TOPLEFT')
        end

        f:SetScript('OnUpdate', function(f)
            local data = self:GetCombatData()
            text:SetText(format(templates,
                data.dt,
                data.dd,
                data.dps,
                data.hd,
                data.hps,
                data.dead,
                self:IsEnabled() and '已开启' or '已关闭'
            ))
        end)
    end

    local StartButton = CreateFrame('Button', nil, f, 'UIPanelButtonTemplate') do
        StartButton:SetPoint('BOTTOMLEFT')
        StartButton:SetSize(80, 22)
        StartButton:SetText('开启')
        StartButton:SetScript('OnClick', function()
            GUI:CallMessageDialog('你应该只在打木桩测试时点击这个按钮！！！\n准备进秘境之前点关闭按钮！！！', function(result)
                if result then
                    self:Enable()
                end
            end)
        end)
    end

    local ClearButton = CreateFrame('Button', nil, f, 'UIPanelButtonTemplate') do
        ClearButton:SetPoint('LEFT', StartButton, 'RIGHT')
        ClearButton:SetSize(80,22)
        ClearButton:SetText('关闭')
        ClearButton:SetScript('OnClick', function()
            GUI:CallMessageDialog('点这个按钮会清除数据，你应该只在打完木桩后验证完数据后点击', function(result)
                if result then
                    self:Disable()
                end
            end)
        end)
    end
end
