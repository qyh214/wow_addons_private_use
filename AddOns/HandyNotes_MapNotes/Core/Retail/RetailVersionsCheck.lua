local ADDON_NAME, ns = ...
local TOC_VERSION = tostring(ns and ns.CurrentAddonVersion or "0.0.0"):gsub("%s+", "")
local VERSION_FALLBACK = (TOC_VERSION == "0.0.0")

local PREFIX = "HN_MapNotes_Ver"
local f = CreateFrame("Frame")

local function NormName(s)
  return (tostring(s or "")):gsub("%s+", "")
end

local PLAYER = NormName((UnitName("player") or "player") .. "-" .. (GetRealmName() or ""))

local function split3(v)
  v = tostring(v or "")
  local clean = v:match("(%d+%.%d+%.%d+)") or v:match("(%d+%.%d+)") or v:match("(%d+)")
  if not clean then return 0,0,0 end
  local a,b,c = clean:match("^(%d+)%.(%d+)%.(%d+)$")
  if a then return tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0 end
  local x,y = clean:match("^(%d+)%.(%d+)$")
  if x then return tonumber(x) or 0, tonumber(y) or 0, 0 end
  return tonumber(clean) or 0, 0, 0
end

local function IsNewer(remote, localv)
  local r1,r2,r3 = split3(remote); local l1,l2,l3 = split3(localv)
  if r1 ~= l1 then return r1 > l1 end
  if r2 ~= l2 then return r2 > l2 end
  return r3 > l3
end

local function PickPrimaryChannel()
  if IsInRaid() then
    return (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID"
  elseif IsInGroup() then
    return (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY"
  elseif IsInGuild() then
    return "GUILD"
  end
end

local maxSeen
local printedOnce

local function Broadcast(ver)
  if VERSION_FALLBACK then return end
  local sent = false
  local ch = PickPrimaryChannel()
  if ch and ver then
    C_ChatInfo.SendAddonMessage(PREFIX, ver, ch)
    sent = true
  end
  if IsInGuild() and ch ~= "GUILD" and ver then
    C_ChatInfo.SendAddonMessage(PREFIX, ver, "GUILD")
    sent = true
  end
  return sent
end

local function SendOnce()
  return Broadcast(maxSeen or TOC_VERSION)
end

local function SendWithRetry()
  if VERSION_FALLBACK then return end
  if not SendOnce() then
    C_Timer.After(3, SendOnce)
  end
end

local function WhisperBackVersion(targetRaw)
  if not targetRaw or targetRaw == "" then return end
  C_ChatInfo.SendAddonMessage(PREFIX, TOC_VERSION, "WHISPER", targetRaw)
end

local function EnableReceiving()
  if not f:IsEventRegistered("CHAT_MSG_ADDON") then
    f:RegisterEvent("CHAT_MSG_ADDON")
  end
end

local function DisableReceiving()
  if f:IsEventRegistered("CHAT_MSG_ADDON") then
    f:UnregisterEvent("CHAT_MSG_ADDON")
  end
end

C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")

f:SetScript("OnEvent", function(_, evt, ...)
  if evt == "PLAYER_ENTERING_WORLD" then
    if InCombatLockdown() then DisableReceiving() else EnableReceiving() end
    C_Timer.After(5, SendWithRetry)
    f:UnregisterEvent("PLAYER_ENTERING_WORLD")

  elseif evt == "GROUP_ROSTER_UPDATE" then
    C_Timer.After(3, SendWithRetry)
  elseif evt == "PLAYER_REGEN_ENABLED" then
    EnableReceiving()
  elseif evt == "PLAYER_REGEN_DISABLED" then
    DisableReceiving()
  elseif evt == "CHAT_MSG_ADDON" then
    if VERSION_FALLBACK then return end
    local prefix, msg, channel, senderRaw = ...
    if prefix ~= PREFIX or not msg then return end
    if NormName(senderRaw) == PLAYER then return end

    if IsNewer(msg, TOC_VERSION) then
      maxSeen = msg
      if not printedOnce then
        printedOnce = true
        local VersionsCheckText = ns and ns.CHANGE_VERSIONS_CHECK and (ns.CHANGE_VERSIONS_CHECK[ns.locale] or ns.CHANGE_VERSIONS_CHECK.enUS)
        if VersionsCheckText and ns and ns.COLORED_ADDON_NAME then
          print(ns.COLORED_ADDON_NAME .. " " .. string.format(VersionsCheckText, tostring(maxSeen), tostring(TOC_VERSION)))
        else
          print(string.format("New version |cff00ff00%s|r available, your version |cffffff00%s|r is outdated!", tostring(maxSeen), tostring(TOC_VERSION)))
        end
      end
      C_Timer.After(1, function() Broadcast(maxSeen) end)
      return
    end

    if IsNewer(TOC_VERSION, msg) then
      C_Timer.After(0.5, function() WhisperBackVersion(senderRaw) end)
      return
    end
  end
end)