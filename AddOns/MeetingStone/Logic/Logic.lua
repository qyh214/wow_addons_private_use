
BuildEnv(...)

Logic = Addon:NewModule('Logic', 'AceEvent-3.0', 'NetEaseSocket-2.0')

function Logic:OnInitialize()
    if not ADDON_REGIONSUPPORT then
        return
    end

    self:ListenSocket('NERB', 'S1' .. UnitFactionGroup('player'))

    self:RegisterServer('SDV', 'SOCKET_DATA_VALUE')
    self:RegisterServer('SSM', 'SOCKET_SYSTEM_MESSAGE')
    self:RegisterServer('SVERSION', 'SOCKET_VERSION')

    self:RegisterServer('SERVER_CONNECTED')
    self:RegisterServer('SERVER_DISCONNECTED', 'ServerConnect')
    self:RegisterServer('CHANNEL_DISCONNECTED', 'ConnectChannel')

    self:RegisterServerEvent('EXCHANGE_RESULT', 'MEETINGSTONE_REWARD_RESULT')
    self:RegisterServerEvent('MALLPURCHASE_RESULT', 'MEETINGSTONE_MALLPURCHASE_RESULT')
    self:RegisterServerEvent('MALLQUERY_RESULT', 'MEETINGSTONE_MALLQUERY_RESULT')

    self:ServerConnect()
end

function Logic:RegisterServerEvent(cmd, event)
    self:RegisterServer(cmd, function(_, ...)
        self:SendMessage(event, ...)
    end)
end

function Logic:ServerConnect()
    if self:IsCanConnect() then
        self:ConnectServer()
    end
    self:SendMessage('MEETINGSTONE_SERVER_STATUS_UPDATED', false)
end

function Logic:IsCanConnect()
    return not IsTrialAccount() and not self.notSupport
end

function Logic:IsSupport()
    return not self.notSupport
end

function Logic:SOCKET_DATA_VALUE(_, key, data)
    DataCache:SaveCache(key, data)
end

function Logic:SOCKET_SYSTEM_MESSAGE(_, msg)
    SendSystemMessage(msg)
end

function Logic:SOCKET_VERSION(_, ...)
    self.notSupport = not select(3, ...)
    self:SendMessage('MEETINGSTONE_NEW_VERSION', ...)
end

function Logic:SERVER_CONNECTED()
    self:SendServer('SLOGIN', ADDON_VERSION, UnitGUID('player'), GetAddonSource(), select(2, BNGetInfo()))
    self:SendMessage('MEETINGSTONE_SERVER_STATUS_UPDATED', true)
end

---- Mall API

function Logic:MallQueryPoint()
    self:SendServer('MALLQUERY', UnitGUID('player'), ADDON_VERSION_SHORT)
end

function Logic:MallPurchase(id, price, confirm)
    if not id then
        debug('MallPurchase args #1 is null', 2)
        return
    end

    self:SendServer('MALLPURCHASE', id, UnitGUID('player'), ADDON_VERSION_SHORT, confirm, price)
    debug(format('MALLPURCHASE: %s %s', id, price))
end

function Logic:Exchange(text)
    if not text or text == '' then
        debug('code is null', 2)
        return
    end

    self:SendServer('EXCHANGE', text, UnitGUID('player'), ADDON_VERSION_SHORT)
    debug('EXCHANGE: ' .. text)
end

function Logic:SEI(activity)
    if not activity then
        return
    end

    self:SendServer('SEI',
        UnitGUID('player'),
        GetPlayerBattleTag(),
        ADDON_VERSION,
        activity:GetActivityID(),
        activity:GetActivityType(),
        activity:GetActivityMode(),
        activity:GetActivityLoot(),
        activity:GetActivitySummary())
end

function Logic:SEJ(activity, comment, tank, healer, damager)
    if not activity then
        return
    end

    self:SendServer('SEJ',
        UnitGUID('player'),
        GetPlayerBattleTag(),
        ADDON_VERSION,
        activity:GetLeader(),
        activity:IsMeetingStone(),
        activity:GetActivityID(),
        activity:GetCustomID(),
        comment,
        tank,
        healer,
        dammager)
end

function Logic:AddIgnore(name, msg)
    if not name or UnitIsUnit('player', Ambiguate(name, 'none')) then
        return
    end

    self:SendServer('IGNORE',
        name,
        msg,
        UnitGUID('player'),
        GetPlayerBattleTag(),
        ADDON_VERSION)
end
