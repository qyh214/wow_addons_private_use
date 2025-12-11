local ADDON_NAME, ns = ...
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
local loc = GetLocale()

function ns.MapNotesOpenMap(mapID, duration)
  if not mapID then return end
  local act = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not act then return end

  if act.UseInBattle and ns.UnsafeSetMapID then
    return ns.UnsafeSetMapID(mapID, duration)
  elseif act.ToggleMap and ns.SafeOpenWorldMap then
    return ns.SafeOpenWorldMap(mapID, duration)
  else
    return
  end
end


-- disable safe setting
function ns.ForceUseInBattle(enable, silent)
  local act = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not act then return end

  act._UseInBattleBackup = act._UseInBattleBackup or {}
  if enable then
    if not next(act._UseInBattleBackup) then
      act._UseInBattleBackup.ToggleMap = act.ToggleMap
      act._UseInBattleBackup.ToggleMapInfo = act.ToggleMapInfo
      act._UseInBattleBackup.ToggleMapAfterCombat = act.ToggleMapAfterCombat
      act._UseInBattleBackup.InfoBlockedInCombat = act.InfoBlockedInCombat
    end
    act.UseInBattle = true
    act.ToggleMap = false
    act.ToggleMapInfo = false
    act.ToggleMapAfterCombat= false
    act.InfoBlockedInCombat = false
  else
    act.UseInBattle = false
    if next(act._UseInBattleBackup) then
      act.ToggleMap = act._UseInBattleBackup.ToggleMap
      act.ToggleMapInfo = act._UseInBattleBackup.ToggleMapInfo
      act.ToggleMapAfterCombat = act._UseInBattleBackup.ToggleMapAfterCombat
      act.InfoBlockedInCombat = act._UseInBattleBackup.InfoBlockedInCombat
    end
    act._UseInBattleBackup = {}
  end

  if ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.MapChanging then
    ns.MapChangeLastSet = nil
    if ns.ChangingMapToPlayerZone then ns.ChangingMapToPlayerZone() end
  end

  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end

function ns.SyncUseInBattleFromDB()
  local act = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not act then return end
  ns.ForceUseInBattle(act.UseInBattle, true)
end


-- safe mapchange
ns.CombatLocked = (ns.LOCALE_COMBAT_LOCKED and (ns.LOCALE_COMBAT_LOCKED[ns.locale] or ns.LOCALE_COMBAT_LOCKED.enUS)) or "Map switching is blocked during combat"
ns.AfterCombatAllowed = (ns.LOCALE_AFTER_COMBAT_ALLOWED and (ns.LOCALE_AFTER_COMBAT_ALLOWED[ns.locale] or ns.LOCALE_AFTER_COMBAT_ALLOWED.enUS)) or "Map switching blocked in combat – will be executed after combat"
ns.OpenAfterCombat = (ns.LOCALE_OPEN_AFTER_COMBAT and (ns.LOCALE_OPEN_AFTER_COMBAT[ns.locale] or ns.LOCALE_OPEN_AFTER_COMBAT.enUS)) or "> Map switching executed after combat <"

local pendingMapOpen
function ns.SafeOpenWorldMap(mapID)
  if not mapID then return end
  local act = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not act or not act.ToggleMap then return end

  ns._lastCombatInfo = ns._lastCombatInfo or 0
  local now = GetTime()

  if InCombatLockdown() then

    if act.InfoBlockedInCombat and (now - ns._lastCombatInfo) < 0.2 then return end
    ns._lastCombatInfo = now

    if act.ToggleMapAfterCombat then
      pendingMapOpen = mapID
      if act.InfoBlockedInCombat then
        if UIErrorsFrame then
          UIErrorsFrame:AddMessage(ns.COLORED_ADDON_NAME .. "\n" .. ns.AfterCombatAllowed, 1, 0.82, 0)
        else
          print(ns.COLORED_ADDON_NAME .. "\n" .. ns.AfterCombatAllowed)
        end
      end
    else
      if act.InfoBlockedInCombat then
        if UIErrorsFrame then
          UIErrorsFrame:AddMessage(ns.COLORED_ADDON_NAME .. "\n" .. ns.CombatLocked, 1, 0.82, 0)
        else
          print(ns.COLORED_ADDON_NAME .. "\n" .. ns.CombatLocked)
        end
      end
    end
    return
  end

  C_Map.OpenWorldMap(mapID)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function()
  if pendingMapOpen then
    C_Map.OpenWorldMap(pendingMapOpen)
    pendingMapOpen = nil
    local act = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
    if act and act.InfoBlockedInCombat then
      if UIErrorsFrame then
        UIErrorsFrame:AddMessage(ns.COLORED_ADDON_NAME .. "\n" .. ns.OpenAfterCombat, 1, 0.82, 0)
      else
        print(ns.COLORED_ADDON_NAME .. "\n" .. ns.OpenAfterCombat)
      end
    end
  end
end)

-- blizzard error frame
local information = (ns.LOCALE_BLOCKPANEL_MSG and (ns.LOCALE_BLOCKPANEL_MSG[loc] or ns.LOCALE_BLOCKPANEL_MSG.enUS)) or "Please reload the UI to return this function to the Blizzard UI."
local function CreateBlockPanel()
    if MN_BlockPanel then return end

    local f = CreateFrame("Frame", "MN_BlockPanel", UIParent, "DialogBorderOpaqueTemplate")
    f:SetSize(360, 90)
    f:SetFrameStrata("DIALOG")
    f:Hide()

    if f.SetBackdrop then
        f:SetBackdrop({
            bgFile  = "Interface\\Buttons\\WHITE8x8",
            edgeFile= "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = false, edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 },
        })
        f:SetBackdropColor(0, 0, 0, 0.90)
    end

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", f, "TOP", 0, -12)
    f.title:SetText("|cffff0000Map|r|cff00ccffNotes|r")

    f.msg = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.msg:SetPoint("TOP", f.title, "BOTTOM", 0, 0)
    f.msg:SetWidth(f:GetWidth() - 32)
    f.msg:SetJustifyH("CENTER")
    f.msg:SetText(information)

    local BTN_W, BTN_H = 100, 22
    f.btns = CreateFrame("Frame", nil, f)
    f.btns:SetPoint("TOP", f.msg, "BOTTOM", 0, -10)
    f.btns:SetSize(BTN_W, BTN_H)

    f.buttonReload = CreateFrame("Button", nil, f.btns, "StaticPopupButtonTemplate")
    f.buttonReload:SetSize(BTN_W, BTN_H)
    f.buttonReload:SetPoint("CENTER", f.btns, "CENTER", -69, -3)
    f.buttonReload:SetText(RELOADUI)
    f.buttonReload:SetNormalFontObject("GameFontNormal")
    f.buttonReload:SetHighlightFontObject("GameFontHighlight")
    f.buttonReload:SetScript("OnClick", ReloadUI)

    f.buttonIgnore = CreateFrame("Button", nil, f.btns, "StaticPopupButtonTemplate")
    f.buttonIgnore:SetSize(BTN_W, BTN_H)
    f.buttonIgnore:SetPoint("CENTER", f.btns, "CENTER", 69, -3)
    f.buttonIgnore:SetText(IGNORE)
    f.buttonIgnore:SetNormalFontObject("GameFontNormal")
    f.buttonIgnore:SetHighlightFontObject("GameFontHighlight")
    f.buttonIgnore:SetScript("OnClick", function() f:Hide() end)

    MN_BlockPanel = f

    if f:GetName() then
        table.insert(UISpecialFrames, f:GetName())
    end

    f:SetScript("OnSizeChanged", function(self)
        if self.msg then self.msg:SetWidth(self:GetWidth() - 32) end
        if self.btns then self.btns:SetPoint("TOP", self.msg, "BOTTOM", 0, 0) end
    end)
end
CreateBlockPanel()

-- blizzard popup 
local function MN_ShowBlockPanelForPopup(which, addonName)
    if not MN_BlockPanel then return end
    if which ~= "ADDON_ACTION_FORBIDDEN" and which ~= "ADDON_ACTION_BLOCKED" then
        MN_BlockPanel:Hide()
        return
    end

    local offender = tostring(addonName or "")
    local isMapNotes = (offender == "HandyNotes_MapNotes")

    C_Timer.After(0.05, function()
        local target
        for i = 1, (STATICPOPUP_NUMDIALOGS or 4) do
            local f = _G["StaticPopup"..i]
            if f and f:IsShown() and f.which == which then
                if isMapNotes then
                    target = f; break
                end
                if offender == "" then
                    local txt = (f.text and f.text.GetText and f.text:GetText()) or ""
                    if txt:find("HandyNotes_MapNotes", 1, true) then
                        isMapNotes = true
                        target = f; break
                    end
                end
            end
        end

        if target then
            MN_BlockPanel:ClearAllPoints()
            MN_BlockPanel:SetPoint("TOPLEFT", target, "BOTTOMLEFT", 0, -2)
            MN_BlockPanel:SetPoint("TOPRIGHT", target, "BOTTOMRIGHT", 0, -2)
            MN_BlockPanel:SetScale(target:GetScale() or 1)
            MN_BlockPanel:Show()

            if not target.MN_BlockPanelHooked then
                target:HookScript("OnHide", function()
                    if MN_BlockPanel then MN_BlockPanel:Hide() end
                end)
                target.MN_BlockPanelHooked = true
            end
        else
            MN_BlockPanel:Hide()
        end
    end)
end

hooksecurefunc("StaticPopup_Show", function(which, text1)
    MN_ShowBlockPanelForPopup(which, text1)
end)

hooksecurefunc("StaticPopup_Hide", function(which)
    if which == "ADDON_ACTION_FORBIDDEN" or which == "ADDON_ACTION_BLOCKED" then
        if MN_BlockPanel then MN_BlockPanel:Hide() end
    end
end)

-- unsafe function to change map
local function UseInBattleActive()
  return ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate and ns.Addon.db.profile.activate.UseInBattle
end

ns.suppressBlockedUntil = ns.suppressBlockedUntil or 0
function ns.SuppressInterfaceBlockedFor(seconds)
  if not UseInBattleActive() then return end
  local dur = seconds or 0.8
  ns.suppressBlockedUntil = GetTime() + dur
  BS_ApplySilence()
  ArmWindowRestore(dur)
  ns.PurgeOurTaintsNow()
  C_Timer.After(0.05, ns.PurgeOurTaintsNow)
  C_Timer.After(dur + 0.02, ns.PurgeOurTaintsNow)
end

ns.wmIBShieldArmedUntil = ns.wmIBShieldArmedUntil or 0

function ns.ArmWorldMapIBShield(maxSeconds)
  if not UseInBattleActive() then return end
  local dur = maxSeconds or 10
  ns.wmIBShieldArmedUntil = GetTime() + dur
end

local function MN_WorldMap_OnShow_Arm()
  if not UseInBattleActive() then return end
  if InCombatLockdown() and GetTime() <= (ns.wmIBShieldArmedUntil or 0) then
    ns.SuppressInterfaceBlockedFor(2.0)
    ns.wmIBShieldArmedUntil = 0
  end
end

ns.mnIBShieldEv = ns.mnIBShieldEv or CreateFrame("Frame")
ns.mnIBShieldEv:UnregisterAllEvents()
ns.mnIBShieldEv:RegisterEvent("PLAYER_REGEN_DISABLED")
ns.mnIBShieldEv:SetScript("OnEvent", function()
  if not UseInBattleActive() then return end
  if GetTime() <= (ns.wmIBShieldArmedUntil or 0) then
    ns.SuppressInterfaceBlockedFor(2.0)
    ns.wmIBShieldArmedUntil = 0
  end
end)

local function MarkMapOpening()
  ns.mapOpening = true
  C_Timer.After(0, function() ns.mapOpening = false end)
end

local function TryHookWorldMap()
  if InCombatLockdown() then return end
  if not ns.mnWMHooked and WorldMapFrame then
    ns.mnWMHooked = true
    WorldMapFrame:HookScript("OnShow", MN_WorldMap_OnShow_Arm)
    WorldMapFrame:HookScript("OnShow", MarkMapOpening)
  end
end

function ns.UnsafeSetMapID(mapID, duration)
  if not UseInBattleActive() then return end
  if not mapID then return end

  ns.SuppressInterfaceBlockedFor(duration or 0.8)
  ns.ArmWorldMapIBShield(43200) --12 hours

  if ns.mapOpening then
    local id = mapID
    C_Timer.After(0, function()
      if WorldMapFrame and id then
        WorldMapFrame:SetMapID(id)
      end
    end)
  else
    if WorldMapFrame and WorldMapFrame.SetMapID then
      WorldMapFrame:SetMapID(mapID)
    end
  end
end

if UseInBattleActive() then TryHookWorldMap() end

local function EarlySuppressIfArmed()
  if not UseInBattleActive() then return end
  if InCombatLockdown() and GetTime() <= (ns.wmIBShieldArmedUntil or 0) then
    ns.SuppressInterfaceBlockedFor(2.5)
  end
end

local function TryHookWorldMapEarly()
  if InCombatLockdown() then return end
  if WorldMapFrame and not ns.mnWMEarlyHooked then
    ns.mnWMEarlyHooked = true
    if type(WorldMapFrame.HandleUserActionToggleSelf) == "function" then
      hooksecurefunc(WorldMapFrame, "HandleUserActionToggleSelf", EarlySuppressIfArmed)
    end
  end
end

if UseInBattleActive() then TryHookWorldMapEarly() end

local _f = ns.mnEarlyEv or CreateFrame("Frame")
ns.mnEarlyEv = _f
_f:UnregisterAllEvents()
_f:RegisterEvent("PLAYER_LOGIN")
_f:RegisterEvent("ADDON_LOADED")
_f:SetScript("OnEvent", function(_, event, arg1)
  if not UseInBattleActive() then return end
  if event == "PLAYER_LOGIN" then
    TryHookWorldMapEarly()
  elseif event == "ADDON_LOADED" and arg1 == "Blizzard_WorldMap" then
    TryHookWorldMapEarly()
  end
end)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, arg1)
  if not UseInBattleActive() then return end
  if event == "PLAYER_LOGIN" then
    TryHookWorldMap()
  elseif event == "ADDON_LOADED" and arg1 == "Blizzard_WorldMap" then
    TryHookWorldMap()
  end
end)

function ns.TrySetPropagate(btn, value)
  if not UseInBattleActive() then return end
  if InCombatLockdown() then return end
  if not (btn and btn.SetPropagateMouseClicks) then return end
  if btn.IsForbidden and btn:IsForbidden() then return end
  ns.SuppressInterfaceBlockedFor(0.8)
  local ok, err = pcall(btn.SetPropagateMouseClicks, btn, value)
  return ok, err
end

local function StripWoWCodes(s)
  if type(s) ~= "string" then return "" end
  s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
       :gsub("|H.-|h", ""):gsub("|h", "")
       :gsub("%s+", " ")
  return s
end

local function IsMapNotesSetPropagateTaintMsg(msg)
  if type(msg) ~= "string" then return false end
  local m = msg:lower()
  return m:find("addon_action_blocked", 1, true) and m:find("handynotes_mapnotes", 1, true) and (m:find("setpropagatemouseclicks", 1, true) 
      or m:find(":setpropagatemouseclicks", 1, true) or m:find("setpassthroughbuttons", 1, true) or m:find(":setpassthroughbuttons", 1, true))
end

local function ShouldBlockChat(raw)
  if not UseInBattleActive() then
    return false
  end

  local s = StripWoWCodes(raw):lower()
  local inWindow = GetTime() <= (ns.suppressBlockedUntil or 0)

  local iab  = (INTERFACE_ACTION_BLOCKED and INTERFACE_ACTION_BLOCKED:lower()) or "interface action failed because of an addon"
  local iabm = (INTERFACE_ACTION_BLOCKED_MODULAR and INTERFACE_ACTION_BLOCKED_MODULAR:lower()) or ""
  local isInterfaceBlocked = (iab ~= "" and s:find(iab,1,true)) or (iabm ~= "" and s:find(iabm,1,true))

  if isInterfaceBlocked then
    local mentions = s:find("setpropagatemouseclicks", 1, true) or s:find("setpassthroughbuttons", 1, true)
    return mentions or inWindow
  end

  if inWindow then
    local trigger = ns.bugSackTriggers[GetLocale()]
    if trigger and s:find(trigger:lower(), 1, true) then
      return true
    end
  end
  return false
end

local function InstallChatHooks()
  for i = 1, (NUM_CHAT_WINDOWS or 10) do
    local f = _G["ChatFrame"..i]
    if f and f.AddMessage and not f.__MN_OrigAddMessage then
      f.__MN_OrigAddMessage = f.AddMessage
      f.AddMessage = function(self, msg, ...)
        if ShouldBlockChat(msg) then return end
        return self:__MN_OrigAddMessage(msg, ...)
      end
    end
  end

  if type(ChatFrame_DisplaySystemMessageInPrimary) == "function" and not _G.__MN_PrimaryHook then
    _G.__MN_PrimaryHook = true
    local orig = ChatFrame_DisplaySystemMessageInPrimary
    ChatFrame_DisplaySystemMessageInPrimary = function(msg, ...)
      if ShouldBlockChat(msg) then return end
      return orig(msg, ...)
    end
  end
end

local function PatchBugGrabber()
  if not UseInBattleActive() then return end
  if not BugGrabber then return end
  local target = BugGrabber
  local mt = getmetatable(BugGrabber)
  if mt and type(mt.__index)=="table" and type(mt.__index.StoreBug)=="function" then
    target = mt.__index
  end
  if target.__MN_StorePatched or type(target.StoreBug) ~= "function" then return end

  target.__MN_StorePatched = true
  local orig = target.StoreBug
  function target:StoreBug(bug, ...)
    local msg = (type(bug)=="table" and (bug.message or bug.error or bug.msg or bug.text)) or tostring(bug or "")
    if GetTime() <= (ns.suppressBlockedUntil or 0) and IsMapNotesSetPropagateTaintMsg(msg or "") then
      return
    end
    return orig(self, bug, ...)
  end
end

local function PatchBugSack()
  if not UseInBattleActive() then return end
  if not BugSack then return end
  local remain = (ns.suppressBlockedUntil or 0) - GetTime()
  if remain > 0 then
    BS_ApplySilence()
    ArmWindowRestore(remain)
  end
end

ns.BS = ns.BS or { active=false, guard_id=0, origMute=nil, origAuto=nil, origChat=nil, origOpenSack=nil }
local function _ShouldBlockAutoOpenNow()
  if GetTime() > (ns.suppressBlockedUntil or 0) then return false end
  if type(debugstack) ~= "function" then return true end
  local st = (debugstack(3, 10, 10) or ""):lower()
  return st:find("buggrabber", 1, true) or st:find("callbackhandler", 1, true)
end

function BS_ApplySilence()
  if not UseInBattleActive() then return false end
  if not BugSack or not BugSack.db then return false end

  if not ns.BS.active then
    ns.BS.origMute = BugSack.db.mute
    ns.BS.origAuto = BugSack.db.auto
    ns.BS.origChat = BugSack.db.chatframe
    ns.BS.origOpenSack = BugSack.OpenSack
  end

  BugSack.db.chatframe = false
  BugSack.db.auto = false
  BugSack.db.mute = true

  if type(BugSack.OpenSack) == "function" then
    BugSack.OpenSack = function(self, ...)
      if _ShouldBlockAutoOpenNow() then
        return
      end
      return ns.BS.origOpenSack and ns.BS.origOpenSack(self, ...)
    end
  end

  ns.BS.active = true
  return true
end

local function BS_RestoreSilence()
  if not BugSack or not BugSack.db or not ns.BS.active then return end
  if ns.BS.origChat ~= nil then BugSack.db.chatframe = ns.BS.origChat end
  if ns.BS.origAuto ~= nil then BugSack.db.auto = ns.BS.origAuto end
  if ns.BS.origMute ~= nil then BugSack.db.mute = ns.BS.origMute end
  if ns.BS.origOpenSack then BugSack.OpenSack = ns.BS.origOpenSack end
  ns.BS.active = false
  ns.BS.origMute, ns.BS.origAuto, ns.BS.origChat, ns.BS.origOpenSack = nil, nil, nil, nil
end

ns.SND = ns.SND or { active=false, guard_id=0, origPS=nil, origPSF=nil }
function SoundGate_Apply()
  if not UseInBattleActive() then return end
  if ns.SND.active then return end
  ns.SND.origPS  = ns.SND.origPS  or _G.PlaySound
  ns.SND.origPSF = ns.SND.origPSF or _G.PlaySoundFile

  local function shouldSuppressNow() -- mute bugsack for mapnotes setpropagatemouseclicks error
    if GetTime() > (ns.suppressBlockedUntil or 0) then return false end
    if type(debugstack) ~= "function" then return false end
    local st = debugstack(2, 8, 8)
    st = st and st:lower() or ""
    return st:find("bugsack", 1, true)
  end

  if type(_G.PlaySound) == "function" then
    _G.PlaySound = function(...)
      if shouldSuppressNow() then return end
      return ns.SND.origPS(...)
    end
  end
  if type(_G.PlaySoundFile) == "function" then
    _G.PlaySoundFile = function(...)
      if shouldSuppressNow() then return end
      return ns.SND.origPSF(...)
    end
  end

  ns.SND.active = true
end

function ArmWindowRestore(duration)
  if not UseInBattleActive() then return end
  local dur = duration or (ns.suppressBlockedUntil - GetTime())
  local delay = math.max(0.05, (dur or 0) + 0.01)

  ns.BS.guard_id  = (ns.BS.guard_id or 0) + 1
  local my_bs  = ns.BS.guard_id

  C_Timer.After(delay, function()
    if my_bs == ns.BS.guard_id and GetTime() >= (ns.suppressBlockedUntil or 0) then
      BS_RestoreSilence()
    end
  end)
end

local function _msgOf(e)
  return type(e)=="table" and (e.message or e.error or e.msg or e.text or "") or tostring(e or "")
end

local function _purgeList(list)
  if type(list) ~= "table" then return 0 end
  local removed = 0
  for i = #list, 1, -1 do
    if IsMapNotesSetPropagateTaintMsg(_msgOf(list[i])) then
      table.remove(list, i)
      removed = removed + 1
    end
  end
  return removed
end

function ns.PurgeOurTaintsNow()
  if not UseInBattleActive() then return 0 end
  local removed = 0

  if BugGrabber then
    if type(BugGrabber.GetSessionErrors)=="function" then
      local sess = BugGrabber:GetSessionErrors()
      removed = removed + _purgeList(sess)
    end
    removed = removed + _purgeList(BugGrabber.errors)
    if BugGrabber.db then removed = removed + _purgeList(BugGrabber.db.errors) end
  end

  removed = removed + _purgeList(_G.BugGrabberDB and _G.BugGrabberDB.errors)

  if BugSack then
    if type(BugSack.UpdateDisplay)=="function" then pcall(BugSack.UpdateDisplay, BugSack) end
    local any = false
    if BugGrabber and type(BugGrabber.GetSessionErrors)=="function" then
      local sess = BugGrabber:GetSessionErrors()
      any = type(sess)=="table" and #sess > 0
    end
    if not any and _G.BugGrabberDB and type(_G.BugGrabberDB.errors)=="table" then
      any = #_G.BugGrabberDB.errors > 0
    end
    local frame = _G.BugSackFrame or BugSack.frame
    if frame and frame:IsShown() and not any then
      if type(BugSack.CloseSack)=="function" then
        pcall(BugSack.CloseSack, BugSack)
      else
        frame:Hide()
      end
    end
  end
  return removed
end

function ns.WipeStoredMapNotesTaints()
  if not UseInBattleActive() then return 0 end
  local db = _G.BugGrabberDB
  if not db or type(db.errors) ~= "table" then return 0 end

  local t = db.errors
  local removed = 0
  for i = #t, 1, -1 do
    local e = t[i]
    local msg = (type(e)=="table" and (e.message or e.error or e.msg or e.text)) or tostring(e or "")
    if IsMapNotesSetPropagateTaintMsg((msg or "")) then
      local cnt = tonumber(type(e)=="table" and e.counter) or 1
      table.remove(t, i)
      removed = removed + cnt
    end
  end

  if BugSack and type(BugSack.UpdateDisplay)=="function" then
    pcall(BugSack.UpdateDisplay, BugSack)
  end
  return removed
end

function _ScheduleMapNotesTaintWipes(duration)
  if not UseInBattleActive() then return end
  local d = duration or 0.8
  local deadline = GetTime() + d + 0.05
  ns.WipeStoredMapNotesTaints()
  C_Timer.After(0.05, ns.WipeStoredMapNotesTaints)
  C_Timer.After(d + 0.02, ns.WipeStoredMapNotesTaints)

  if not _G.BugGrabberDB then
    if ns.MN_WipeOnceFrame then
      ns.MN_WipeOnceFrame:UnregisterAllEvents()
      ns.MN_WipeOnceFrame:SetScript("OnEvent", nil)
      ns.MN_WipeOnceFrame = nil
    end
    ns.MN_WipeOnceFrame = CreateFrame("Frame")
    ns.MN_WipeOnceFrame:RegisterEvent("ADDON_LOADED")
    ns.MN_WipeOnceFrame:SetScript("OnEvent", function(self, _, name)
      if name == "!BugGrabber" and GetTime() <= deadline then
        ns.WipeStoredMapNotesTaints()
      end
      self:UnregisterAllEvents()
      self:SetScript("OnEvent", nil)
      ns.MN_WipeOnceFrame = nil
    end)
  end
end

local function EnsurePatches()
  InstallChatHooks()
  PatchBugGrabber()
  PatchBugSack()
end

function ns.ErrorMessages()
  if ns.ErrorMessagesInstalled then return end
  ns.ErrorMessagesInstalled = true

  EnsurePatches()

  if not ns.ErrorMessagesEventFrame then
    local f = CreateFrame("Frame")
    ns.ErrorMessagesEventFrame = f
    f:RegisterEvent("PLAYER_LOGIN")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(_, event, arg1)
      if event == "PLAYER_LOGIN" then
        EnsurePatches()
        if (ns.suppressBlockedUntil or 0) > GetTime() then
          BS_ApplySilence(); ArmWindowRestore(ns.suppressBlockedUntil - GetTime())
        end
      elseif event == "ADDON_LOADED" then
        if arg1 == "!BugGrabber" or arg1 == "BugSack" then
          EnsurePatches()
          if arg1 == "BugSack" and (ns.suppressBlockedUntil or 0) > GetTime() then
            BS_ApplySilence(); ArmWindowRestore(ns.suppressBlockedUntil - GetTime())
          end
        end
      end
    end)
  end
end

SLASH_MNSUPTEST1 = "/mnsuptrig"
SlashCmdList["MNSUPTEST"] = function()
  ns.SuppressInterfaceBlockedFor(0.8)
  local f = DEFAULT_CHAT_FRAME
  f:AddMessage("|cffffff00Interface-Aktion auf Grund eines Addons fehlgeschlagen|r")
  f:AddMessage("|cff00ff00BugSack: Du hast einen Fehler entdeckt!|r")
  f:AddMessage("|cffffffff[neutral sofort] Diese Zeile sollte sichtbar sein.|r")
  C_Timer.After(1.0, function()
    f:AddMessage("|cffffff00Interface-Aktion auf Grund eines Addons fehlgeschlagen (nach 1s)|r")
    f:AddMessage("|cff00ff00BugSack: Du hast einen Fehler entdeckt! (nach 1s)|r")
    f:AddMessage("|cffffffff[neutral 1s] Diese Zeile sollte sichtbar sein.|r")
  end)
end