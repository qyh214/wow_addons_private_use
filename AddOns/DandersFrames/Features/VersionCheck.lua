local addonName, DF = ...

-- ============================================================
-- VERSION CHECK & /df users
-- Broadcasts and receives DF version info over addon comms.
-- Nags the user once per session if a newer stable release is
-- seen. Powers /df users listing for group/raid.
-- ============================================================

local pairs, ipairs, type = pairs, ipairs, type
local tonumber, tostring = tonumber, tostring
local format, match, find, gsub = string.format, string.match, string.find, string.gsub
local GetTime = GetTime

DF.VersionCheck = DF.VersionCheck or {}
local VC = DF.VersionCheck

-- In-memory state (reset each session)
VC.seenUsers = {}       -- [playerFullName] = { version = "vX.Y.Z", lastSeen = GetTime() }
VC.hasNagged = false
VC.initialized = false

-- Constants
VC.PREFIX = "DF_VerCheck"
VC.STALE_SECONDS = 600

-- ============================================================
-- VERSION PARSING & COMPARISON
-- Handles strings like "v4.3.2", "4.3.2", "v4.3.2-alpha.3",
-- "4.3.3-beta.1". Leading "v" is optional.
-- ============================================================

-- Returns: major, minor, patch, prerelease (string or nil), prereleaseNum (number or nil)
-- Returns nil on parse failure.
function VC:ParseVersion(str)
    if type(str) ~= "string" then return nil end
    local s = str:gsub("^v", "")
    local major, minor, patch, suffix = match(s, "^(%d+)%.(%d+)%.(%d+)(.*)$")
    if not major then return nil end
    major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)

    local pre, preNum
    if suffix and suffix ~= "" then
        local tag, num = match(suffix, "^%-(%a+)%.(%d+)$")
        if not tag then
            tag = match(suffix, "^%-(%a+)$")
            num = 0
        end
        if tag then
            pre = tag:lower()
            preNum = tonumber(num) or 0
        end
    end
    return major, minor, patch, pre, preNum
end

-- Returns true if version string has a pre-release suffix (alpha/beta)
function VC:IsPreRelease(str)
    local _, _, _, pre = self:ParseVersion(str)
    return pre == "alpha" or pre == "beta"
end

-- Compare a vs b. Returns -1 if a<b, 0 if a==b, 1 if a>b. Returns nil on parse error.
-- Semver rule: higher base triple wins; if equal, no-suffix > has-suffix; if both have
-- suffixes, compare (pre, preNum) lex/numerically.
function VC:CompareVersions(a, b)
    local aM, am, ap, aPre, aPreN = self:ParseVersion(a)
    local bM, bm, bp, bPre, bPreN = self:ParseVersion(b)
    if not aM or not bM then return nil end

    if aM ~= bM then return aM < bM and -1 or 1 end
    if am ~= bm then return am < bm and -1 or 1 end
    if ap ~= bp then return ap < bp and -1 or 1 end

    -- Base equal. Suffix rules:
    if not aPre and not bPre then return 0 end
    if not aPre and bPre then return 1 end   -- stable > pre
    if aPre and not bPre then return -1 end  -- pre < stable
    -- Both pre: alpha < beta, else by number
    if aPre ~= bPre then return aPre < bPre and -1 or 1 end
    if aPreN ~= bPreN then return aPreN < bPreN and -1 or 1 end
    return 0
end

-- Developer-only: run the expected comparator test matrix. Returns pass/fail counts.
function VC:RunComparatorTests()
    local cases = {
        -- { a, b, expected }
        { "v4.3.2", "v4.3.3", -1 },
        { "v4.3.3", "v4.3.2",  1 },
        { "v4.3.2", "v4.3.2",  0 },
        { "4.3.2",  "v4.3.2",  0 },
        { "v4.3.2-alpha.3", "v4.3.2",       -1 },  -- pre < stable (same base)
        { "v4.3.2",         "v4.3.2-alpha.3", 1 },
        { "v4.3.2-alpha.3", "v4.3.3",       -1 },  -- lower base beats suffix
        { "v4.3.3-alpha.1", "v4.3.2",        1 },  -- pre of higher base > stable of lower
        { "v4.3.2-alpha.1", "v4.3.2-alpha.2",-1 },
        { "v4.3.2-alpha.5", "v4.3.2-beta.1",-1 },
        { "v4.3.2-beta.1",  "v4.3.2-alpha.9", 1 },
    }
    local pass, fail = 0, 0
    for _, c in ipairs(cases) do
        local got = self:CompareVersions(c[1], c[2])
        if got == c[3] then
            pass = pass + 1
        else
            fail = fail + 1
            print(format("|cffff4040FAIL|r cmp(%s, %s) = %s, expected %s",
                c[1], c[2], tostring(got), tostring(c[3])))
        end
    end
    print(format("|cffeda55fDandersFrames:|r comparator tests: %d pass, %d fail", pass, fail))
    return pass, fail
end

-- ============================================================
-- ADDON COMM DISPATCH
-- ============================================================

-- Cached on Init
VC.playerFullName = nil

local function getPlayerFullName()
    local name = UnitName("player")
    local realm = GetRealmName():gsub("%s", "")
    return name .. "-" .. realm
end

-- Handler table: messageType -> function(sender, payload, channel)
VC.handlers = {}

function VC:Dispatch(messageType, sender, payload, channel)
    if sender == self.playerFullName then return end  -- ignore self
    local handler = self.handlers[messageType]
    if handler then
        handler(self, sender, payload, channel)
    end
end

-- Parse incoming tab-separated message: "TYPE\tPAYLOAD..."
function VC:OnAddonMessage(prefix, message, channel, sender)
    if prefix ~= self.PREFIX then return end
    local msgType, payload = match(message, "^([^\t]+)\t?(.*)$")
    if not msgType then return end
    self:Dispatch(msgType, sender, payload, channel)
end

-- Public entry point, called from Core.lua after PLAYER_LOGIN.
function VC:Init()
    if self.initialized then return end
    self.initialized = true
    self.playerFullName = getPlayerFullName()

    C_ChatInfo.RegisterAddonMessagePrefix(self.PREFIX)

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHAT_MSG_ADDON")
    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:RegisterEvent("GUILD_ROSTER_UPDATE")
    frame:SetScript("OnEvent", function(_, event, prefix, message, channel, sender)
        if event == "CHAT_MSG_ADDON" then
            VC:OnAddonMessage(prefix, message, channel, sender)
        elseif event == "GROUP_ROSTER_UPDATE" then
            local key = VC:GroupCompositionKey()
            if key ~= VC.lastGroupKey then
                VC.lastGroupKey = key
                VC:ScheduleRebroadcast(3)
            end
        elseif event == "GUILD_ROSTER_UPDATE" then
            VC:ScheduleRebroadcast(5)
        end
    end)
    self.eventFrame = frame

    self.lastGroupKey = self:GroupCompositionKey()

    C_Timer.After(3, function()
        VC:BroadcastHello()
    end)
end

-- ============================================================
-- BROADCAST HELPERS
-- ============================================================

-- Returns true if the player's HOME party/raid contains at least one real
-- player other than the player themselves. Follower dungeons and NPC-companion
-- delves report IsInGroup()=true with only NPCs; sending to PARTY in that
-- state produces a repeating "You aren't in a party." chat error.
-- Only meaningful for home PARTY/RAID validation -- INSTANCE_CHAT doesn't
-- need this check because instance groups can't contain NPC followers.
function VC:HasPlayerGroupMembers()
    if not IsInGroup(LE_PARTY_CATEGORY_HOME) then return false end
    if IsInRaid(LE_PARTY_CATEGORY_HOME) then
        local n = GetNumGroupMembers()
        for i = 1, n do
            local token = "raid" .. i
            if UnitExists(token) and UnitIsPlayer(token) and not UnitIsUnit(token, "player") then
                return true
            end
        end
        return false
    end
    for i = 1, 4 do
        local token = "party" .. i
        if UnitExists(token) and UnitIsPlayer(token) then
            return true
        end
    end
    return false
end

-- Single source of truth for "is this addon-message channel usable right now?"
-- Used by both GetAvailableChannels (broadcast targeting) and SendMessage
-- (send-time re-validation). Because every send funnels through SendMessage,
-- a false return here means C_ChatInfo.SendAddonMessage is never called for
-- that channel and ERR_NOT_IN_GROUP cannot fire from this addon.
--
-- LFG / LFR / scenarios / battlegrounds put the player in an INSTANCE group
-- (LE_PARTY_CATEGORY_INSTANCE) with no HOME group. PARTY/RAID addon messages
-- only target the HOME group, so sending PARTY/RAID in that state produces
-- "You aren't in a party./raid." chat spam. INSTANCE_CHAT is the correct
-- channel for instance-group comms.
function VC:IsChannelValid(channel)
    if channel == "INSTANCE_CHAT" then
        return IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInInstance()
    elseif channel == "RAID" then
        return IsInRaid(LE_PARTY_CATEGORY_HOME) and self:HasPlayerGroupMembers()
    elseif channel == "PARTY" then
        return IsInGroup(LE_PARTY_CATEGORY_HOME)
            and not IsInRaid(LE_PARTY_CATEGORY_HOME)
            and self:HasPlayerGroupMembers()
    elseif channel == "GUILD" then
        return IsInGuild()
    end
    return false
end

-- Returns a list of channel strings ({"GUILD", "INSTANCE_CHAT"}, etc.)
-- currently available to the player. Empty when solo + no guild.
-- Prefers INSTANCE_CHAT over home RAID/PARTY when both apply -- instance
-- group members are reachable via INSTANCE_CHAT, no need to double-send.
function VC:GetAvailableChannels()
    local out = {}
    if self:IsChannelValid("GUILD") then out[#out+1] = "GUILD" end
    if self:IsChannelValid("INSTANCE_CHAT") then
        out[#out+1] = "INSTANCE_CHAT"
    elseif self:IsChannelValid("RAID") then
        out[#out+1] = "RAID"
    elseif self:IsChannelValid("PARTY") then
        out[#out+1] = "PARTY"
    end
    return out
end

function VC:SendMessage(msgType, payload, channel)
    -- Final chokepoint. Timer-deferred replies (H handler's 1-3s jitter)
    -- and any future caller can race a state change such as zoning into
    -- an instance, leaving the group, or transitioning between home and
    -- instance group categories. If the channel isn't valid right now,
    -- return without ever calling SendAddonMessage so ERR_NOT_IN_GROUP
    -- cannot fire.
    if not self:IsChannelValid(channel) then return end
    local body = payload and (msgType .. "\t" .. payload) or msgType
    C_ChatInfo.SendAddonMessage(self.PREFIX, body, channel)
end

-- Broadcasts H on every available channel.
function VC:BroadcastHello()
    for _, ch in ipairs(self:GetAvailableChannels()) do
        self:SendMessage("H", nil, ch)
    end
end

-- Sends V (our version) on one specific channel, unless we're on pre-release.
function VC:SendVersion(channel)
    if self:IsPreRelease(DF.VERSION) then return end  -- pre-release clients don't advertise
    self:SendMessage("V", tostring(DF.VERSION), channel)
end

-- ============================================================
-- NAG LOGIC
-- ============================================================

function VC:ShouldNag(incomingVersion)
    -- Incoming pre-release never triggers nag.
    if self:IsPreRelease(incomingVersion) then return false end
    local cmp = self:CompareVersions(incomingVersion, DF.VERSION)
    return cmp == 1
end

function VC:ShowNag(newVersion)
    local db = DF:GetGlobalDB()
    if not db.notifyOutdated then return end
    if self.hasNagged then return end
    self.hasNagged = true
    local L = DF.L
    print("|cffeda55fDandersFrames:|r " ..
        format(L["A newer version is available (%s). Get it on CurseForge."], tostring(newVersion)))
end

-- Receive H: respond with our version on the same channel type, with small jitter.
VC.handlers["H"] = function(self, sender, _, channel)
    local delay = 1 + math.random() * 2  -- 1-3s jitter to avoid response storms
    C_Timer.After(delay, function()
        self:SendVersion(channel)
    end)
end

-- Real V handler: record + nag
VC.handlers["V"] = function(self, sender, payload, channel)
    if not payload or payload == "" then return end
    self.seenUsers[sender] = { version = payload, lastSeen = GetTime() }
    if self:ShouldNag(payload) then
        self:ShowNag(payload)
    end
end

-- Developer-only: simulate receiving a V from a fake sender.
function VC:TestNag(version)
    self.hasNagged = false  -- allow re-test in same session
    VC.handlers["V"](self, "TestDummy-TestRealm", version or "999.0.0", "PARTY")
end

-- ============================================================
-- ROSTER CHANGE TRIGGERS (debounced)
-- ============================================================

VC.pendingRebroadcast = false
VC.lastGroupKey = nil

-- Returns a compact string describing current group composition. Used to
-- skip GROUP_ROSTER_UPDATE when only unit data changed (not membership).
function VC:GroupCompositionKey()
    if not IsInGroup() then return "solo" end
    local parts = {}
    local n = GetNumGroupMembers()
    local unit = IsInRaid() and "raid" or "party"
    for i = 1, n do
        local token = (unit == "party" and i == n) and "player" or (unit .. i)
        local fullName = GetUnitName(token, true)
        if fullName then parts[#parts+1] = fullName end
    end
    table.sort(parts)
    return table.concat(parts, ",")
end

function VC:ScheduleRebroadcast(delay)
    if self.pendingRebroadcast then return end
    self.pendingRebroadcast = true
    C_Timer.After(delay, function()
        self.pendingRebroadcast = false
        self:BroadcastHello()
    end)
end

-- ============================================================
-- /df users OUTPUT
-- ============================================================

-- Returns { name, realm, fullName, version (or nil), detected (bool) } for each group member.
function VC:CollectGroupMembers()
    local out = {}
    if not IsInGroup() then return out end
    local n = GetNumGroupMembers()
    local inRaid = IsInRaid()
    local now = GetTime()
    for i = 1, n do
        local token
        if inRaid then
            token = "raid" .. i
        else
            token = (i == n) and "player" or ("party" .. i)
        end
        local name, realm = UnitName(token)
        if name then
            if not realm or realm == "" then realm = GetRealmName():gsub("%s", "") end
            local fullName = name .. "-" .. realm
            local entry = { name = name, realm = realm, fullName = fullName }
            -- Self: always considered "detected" with local version
            if fullName == self.playerFullName then
                entry.version = DF.VERSION
                entry.detected = true
            else
                local seen = self.seenUsers[fullName]
                if seen and (now - seen.lastSeen) <= self.STALE_SECONDS then
                    entry.version = seen.version
                    entry.detected = true
                else
                    entry.detected = false
                end
            end
            out[#out+1] = entry
        end
    end
    return out
end

function VC:PrintUsers()
    if not IsInGroup() then
        print("|cffeda55fDandersFrames:|r Not in a group.")
        return
    end
    local members = self:CollectGroupMembers()
    local detected = 0
    for _, m in ipairs(members) do
        if m.detected then
            detected = detected + 1
            print(format("|cff00ff00v|r %s - %s", m.name, tostring(m.version)))
        else
            print(format("|cff888888x|r %s - not detected", m.name))
        end
    end
    print(format("|cffeda55fDandersFrames:|r %d / %d members running DandersFrames.",
        detected, #members))
end
