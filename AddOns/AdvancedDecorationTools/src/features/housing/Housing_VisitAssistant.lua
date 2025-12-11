-- Housing_VisitAssistant.lua：访屋助手（曲线通过好友拿 GUID → 查看/访问住宅）
-- 设计原则：
-- - 单一权威：配置项统一落在 ADT_DB（VisitAutoRemoveFriend / VisitFriendWaitSec）。
-- - 不做“兜底/兼容映射”：必须提供全名（玩家-服务器）。
-- - 事件优先：通过 FRIENDLIST_UPDATE 驱动；同时容忍网络/延迟，用 Ticker 轮询到上限秒数。

local ADDON_NAME, ADT = ...
ADT = ADT or {}

local VA = CreateFrame("Frame")
ADT.VisitAssistant = VA

local function notify(msg, kind)
    if ADT and ADT.Notify then ADT.Notify(msg, kind) else print("ADT:", msg) end
end

local function dprint(msg)
    if ADT and ADT.DebugPrint then ADT.DebugPrint("[Visit] " .. tostring(msg)) end
end

local function getCfg()
    return {
        autoRemove = ADT.GetDBBool and ADT.GetDBBool("VisitAutoRemoveFriend") or true,
        waitSec    = (ADT.GetDBValue and (ADT.GetDBValue("VisitFriendWaitSec") or 8)) or 8,
    }
end

local function sanitizeName(s)
    if type(s) ~= "string" then return s end
    -- 去首尾空白，并将常见横线统一为 '-'
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    s = s:gsub("—", "-"):gsub("–", "-"):gsub("－", "-")
    return s
end

local function isFullName(name)
    name = sanitizeName(name)
    return type(name) == "string" and name:find("-") ~= nil
end

local function loadHouseListUI()
    local loaded = true
    if C_AddOns and C_AddOns.LoadAddOn then
        local ok, ret = pcall(C_AddOns.LoadAddOn, "Blizzard_HouseList")
        loaded = ok and (ret ~= nil)
    elseif UIParentLoadAddOn then
        loaded = UIParentLoadAddOn("Blizzard_HouseList") and true or false
    end
    if not HouseListFrame then
        loaded = false
    end
    return loaded
end

-- 内部状态
VA.pending = nil -- { name=fullname, started=GetTime(), ticker=..., triedAdd=true }
VA._check = nil   -- 延迟绑定的检查函数
VA._mode = nil    -- 'friend' | 'handshake'

-- 停止当前流程
function VA:Stop(reason)
    local p = self.pending
    if p and p.ticker then p.ticker:Cancel() end
    self.pending = nil
    self._check = nil
    self:UnregisterEvent("FRIENDLIST_UPDATE")
    self:UnregisterEvent("RECENT_ALLIES_CACHE_UPDATE")
    self:UnregisterEvent("RECENT_ALLIES_DATA_READY")
    self:UnregisterEvent("CHAT_MSG_WHISPER")
    if reason and ADT.IsDebugEnabled and ADT.IsDebugEnabled() then dprint("Stop: "..tostring(reason)) end
end

-- 尝试从好友列表读取 guid
local function tryGetGuidByFriend(name)
    name = sanitizeName(name)
    local char = name:match("^([^%-]+)") or name
    local info = C_FriendList and C_FriendList.GetFriendInfo and C_FriendList.GetFriendInfo(name)
    if info and info.guid and info.connected then
        return info.guid
    end
    -- 退化为按“纯角色名”查询
    info = C_FriendList and C_FriendList.GetFriendInfo and C_FriendList.GetFriendInfo(char)
    if info and info.guid and info.connected then
        return info.guid
    end
    -- 再退化为遍历好友表（保险）
    if C_FriendList and C_FriendList.GetNumFriends and C_FriendList.GetFriendInfoByIndex then
        local n = C_FriendList.GetNumFriends() or 0
        for i=1,n do
            local fi = C_FriendList.GetFriendInfoByIndex(i)
            if fi and fi.connected and fi.guid then
                local fname = tostring(fi.name or "")
                local amb = Ambiguate and Ambiguate(fname, "none") or fname
                if fname == char or fname == name or amb == char then
                    dprint("Matched friend entry: "..fname)
                    return fi.guid
                end
            end
        end
    end
    return nil
end

-- 启动访屋：通过全名
function VA:VisitByFullName(fullName)
    if self.pending then
        notify("已有一次访屋流程在进行中，请稍后再试。", 'info')
        return
    end
    if not isFullName(fullName) then
        notify("请输入完整角色全名：角色-服务器（例如 圣糖刺客-凤凰之神）", 'error')
        return
    end

    fullName = sanitizeName(fullName)
    local cfg = getCfg()
    self.pending = { name = fullName, started = GetTime() or 0, triedAdd = false }
    self._mode = 'friend'

    -- 1) 尝试临时加好友
    if C_FriendList and C_FriendList.AddFriend then
        dprint("AddFriend "..fullName)
        pcall(C_FriendList.AddFriend, fullName)
    end
    if C_FriendList and C_FriendList.ShowFriends then C_FriendList.ShowFriends() end

    -- 2) 监听 FRIENDLIST_UPDATE，并并行开启轮询，直到拿到 guid 或超时
    local deadline = (GetTime and GetTime() or 0) + math.max(2, tonumber(cfg.waitSec) or 8)
    local function check()
        if C_FriendList and C_FriendList.ShowFriends then C_FriendList.ShowFriends() end
        local guid = tryGetGuidByFriend(fullName)
        if guid then
            dprint("Got GUID: "..tostring(guid))
            VA:Stop("got-guid")

            -- 鉴于 12.0 对 C_Housing.* 加了“仅暴雪UI可用”的限制（AllowedWhenUntainted），
            -- 这里不再由插件代为打开“查看住宅”面板，改为提示用户手动触发暴雪入口。
            notify("已获得对方标识，但因暴雪限制需手动打开‘查看住宅’：在好友/队伍/聊天右键该名字。", 'info')

            -- 可选：移除临时好友
            if cfg.autoRemove and C_FriendList and C_FriendList.RemoveFriend then
                C_Timer.After(0.2, function()
                    dprint("Auto-RemoveFriend "..fullName)
                    pcall(C_FriendList.RemoveFriend, fullName)
                end)
            end
            return
        end

        if (GetTime and GetTime() or 0) >= deadline then
            VA:Stop("timeout")
            notify("未能在限定时间内获取对方在线信息/标识（请确认其当前在线且名字正确）。", 'error')
        end
    end

    -- 注册事件（加速响应）
    VA._check = check
    VA:RegisterEvent("FRIENDLIST_UPDATE")

    -- 定时轮询
    self.pending.ticker = C_Timer.NewTicker(0.5, check, math.ceil(cfg.waitSec / 0.5) + 2)

    notify("正在查询对方在线信息…", 'info')
end

-- 备用方案：发送一次握手私聊，等待对方回任意消息，从 CHAT_MSG_WHISPER 取 guid
function VA:VisitByHandshake(fullName)
    if self.pending then
        notify("已有一次访屋流程在进行中，请稍后再试。", 'info')
        return
    end
    if not isFullName(fullName) then
        notify("请输入完整角色全名：角色-服务器（例如 圣糖刺客-凤凰之神）", 'error')
        return
    end
    fullName = sanitizeName(fullName)
    self.pending = { name = fullName, started = GetTime() or 0, triedAdd = false }
    self._mode = 'handshake'

    -- 发送一次礼貌握手
    local text = "[ADT访屋助手] 想访问你的住宅，随便回个字就能让我访问你的住宅，求求你啦求求你啦！"
    if C_ChatInfo and C_ChatInfo.SendChatMessage then
        C_ChatInfo.SendChatMessage(text, "WHISPER", nil, fullName)
    else
        SendChatMessage(text, "WHISPER", nil, fullName)
    end
    notify("已向对方发送验证私聊，请对方回复任意内容…", 'info')

    local deadline = (GetTime and GetTime() or 0) + 30
    VA:RegisterEvent("CHAT_MSG_WHISPER")
    -- 同时尝试 RecentAllies（暴雪“最近盟友”会记录密语对象）
    if C_RecentAllies and C_RecentAllies.IsSystemEnabled and C_RecentAllies.IsSystemEnabled() then
        pcall(C_RecentAllies.TryRequestRecentAlliesData)
        VA:RegisterEvent("RECENT_ALLIES_CACHE_UPDATE")
        VA:RegisterEvent("RECENT_ALLIES_DATA_READY")
    end
    VA._check = function()
        if (GetTime and GetTime() or 0) >= deadline then
            VA:Stop("handshake-timeout")
            notify("等待对方回复超时。可重试或改用战网好友/同队伍方式打开。", 'error')
        end
    end
    self.pending.ticker = C_Timer.NewTicker(1.0, VA._check, 35)
end

-- Slash 入口：/adt visit <角色-服务器>
function VA:HandleSlash(args)
    local sub, rest = (args or ""):match("^(%S+)%s*(.*)$")
    sub = (sub or ""):lower()
    if sub == "visit" then
        local name = rest:match("^%s*(.-)%s*$")
        if name == "" then
            notify("用法：/adt visit 角色-服务器（需对方在线）", 'info')
            return
        end
        self:VisitByFullName(name)
        return true
    elseif sub == "visitx" or sub == "visit!" then
        local name = rest:match("^%s*(.-)%s*$")
        if name == "" then
            notify("用法：/adt visitx 角色-服务器 —— 将发送1条私聊并等待对方回复以获取标识", 'info')
            return
        end
        self:VisitByHandshake(name)
        return true
    end
end

-- 防泄漏：切换世界或重载时停止流程
VA:RegisterEvent("PLAYER_LEAVING_WORLD")
VA:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LEAVING_WORLD" then
        self:Stop("leaving-world")
    elseif event == "FRIENDLIST_UPDATE" then
        if self._check then self._check() end
    elseif event == "CHAT_MSG_WHISPER" and self.pending and self._mode == 'handshake' then
        local _text, playerName, _lang, _chanName, playerName2, _sf, _zcid, _cidx, _cbase, _langID, _lineID, guid = ...
        local expected = sanitizeName(self.pending.name)
        local char = expected:match("^([^%-]+)") or expected
        local pn = tostring(playerName or "")
        local pn2 = tostring(playerName2 or "")
        local ambShort = Ambiguate and Ambiguate(pn, "short") or pn
        local ambNone  = Ambiguate and Ambiguate(pn, "none") or pn
        if guid and (
            pn == char or pn2 == char or ambShort == char or ambNone == expected
        ) then
            dprint("Handshake got whisper from target, guid="..tostring(guid))
            self:Stop("handshake-got-guid")
            notify("已获得对方标识，但需你手动右键该名字→‘查看住宅’（暴雪限制）。", 'info')
        end
    elseif (event == "RECENT_ALLIES_CACHE_UPDATE" or event == "RECENT_ALLIES_DATA_READY") and self.pending and self._mode == 'handshake' then
        local full = sanitizeName(self.pending.name)
        local ok, data = pcall(C_RecentAllies.GetRecentAllyByFullName, full)
        if ok and data and data.characterData and data.characterData.guid then
            local guid = data.characterData.guid
            dprint("RecentAllies got guid="..tostring(guid))
            self:Stop("recentallies-got-guid")
            notify("已获得对方标识，但需你手动右键该名字→‘查看住宅’（暴雪限制）。", 'info')
        end
    end
end)
