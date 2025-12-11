local ADDON_NAME, ns = ...

ns.locale = GetLocale()

local npcNameCache = ns.npcNameCache or {}
ns.npcNameCache = npcNameCache

local retryQueue = {}
local retryTimer
local maxRetries = 15
local retryInterval = 0.2
local maxPerTickBase = 50
local timeBudgetMs = 10

local function getSVBucket()
  local locNow = ns and ns.locale or GetLocale() or "enUS"
  local db = HandyNotes_MapNotesRetailNpcCacheDB
  return (db and db.names and db.names[locNow]) or {}
end

local function normalizeID(id)
  if id == nil then return nil end
  local n = tonumber(id)
  return n or id
end

function ns.SilenceHN(enable)
  if not HandyNotes or not HandyNotes.SendMessage then return end
  if enable and not ns.hnSilenced then
    ns.hnSilenced = true
    ns.hnSendMessageOrig = HandyNotes.SendMessage
    function HandyNotes:SendMessage(event, ...)
      if event == "HandyNotes_NotifyUpdate" then return end
      return ns.hnSendMessageOrig(self, event, ...)
    end
  elseif not enable and ns.hnSilenced then
    HandyNotes.SendMessage = ns.hnSendMessageOrig
    ns.hnSendMessageOrig = nil
    ns.hnSilenced = false
  end
end

setmetatable(npcNameCache, {
  __index = function(t, id)
    local num = tonumber(id)
    local bucket = getSVBucket()
    local packed = (num and bucket[num]) or bucket[id]
    if type(packed) == "string" then
      local name, title = packed:match("([^\031]*)\031(.*)")
      if name and name ~= "" then
        if title == "" then title = nil end
        local tuple = { name, title }
        rawset(t, id, tuple)
        return tuple
      end
    end
    return nil
  end
})

function ns.GetNPCName(id)
  id = normalizeID(id)
  if not id or id == 0 then return nil end

  local tuple = npcNameCache[id]
  if tuple then
    return tuple[1]
  end

  local db = HandyNotes_MapNotesRetailNpcCacheDB
  local loc = ns.locale or GetLocale() or "enUS"
  local packed = db and db.names and db.names[loc] and db.names[loc][id]
  if type(packed) == "string" then
    local name, title = packed:match("([^\031]*)\031(.*)")
    if name and name ~= "" then
      if title == "" then title = nil end
      npcNameCache[id] = { name, title }
      return name
    end
  end

  return nil
end

local function PersistNpcName(charDB, locale, npcID, name, title)
  if not (charDB and locale and npcID and name) then return end
  charDB.names = charDB.names or {}
  charDB.names[locale] = charDB.names[locale] or {}
  local packed = name .. "\031" .. (title or "")
  charDB.names[locale][npcID] = packed
end

ns.npcCacheSuccess = 0
ns.npcCacheFail = 0

function ns.GetNpcInfo(npcID)
  npcID = normalizeID(npcID)
  if not npcID then return end

  local entry = npcNameCache[npcID]
  if entry then
    return entry[1], entry[2]
  end

  local tooltipData = C_TooltipInfo.GetHyperlink("unit:Creature-0-0-0-0-" .. npcID .. "-0000000000")
  if not tooltipData then
    return nil, nil
  end

  if TooltipUtil and TooltipUtil.SurfaceArgs then
    TooltipUtil.SurfaceArgs(tooltipData)
    if tooltipData.lines then
      for i = 1, math.min(2, #tooltipData.lines) do
        TooltipUtil.SurfaceArgs(tooltipData.lines[i])
      end
    end
  end

  if not tooltipData.lines or not tooltipData.lines[1] then
    return nil, nil
  end

  local npcName  = tooltipData.lines[1] and tooltipData.lines[1].leftText or nil
  local npcTitle = tooltipData.lines[2] and tooltipData.lines[2].leftText or nil
  if not npcName or npcName == "" or npcName == _G.RETRIEVING_DATA or npcName == _G.UNKNOWNOBJECT then
    return nil, nil
  end

  npcNameCache[npcID] = { npcName, npcTitle }

  local db = HandyNotes_MapNotesRetailNpcCacheDB
  if type(db) == "table" then
    local loc = ns.locale or GetLocale() or "enUS"
    PersistNpcName(db, loc, npcID, npcName, npcTitle)
  end

  return npcName, npcTitle
end

function ns.PrimeNpcNameCache()
  local seen = {}
  local successCount = 0
  local failCount = 0

  local function scanContainer(container)
    for mapID, nodes in pairs(container or {}) do
      for coord, node in pairs(nodes) do
        local ids = {}
        if node.npcID then table.insert(ids, node.npcID) end
        for i = 1, 10 do
          local id = node["npcIDs" .. i]
          if id then table.insert(ids, id) end
        end

        for _, npcID in ipairs(ids) do
          if not seen[npcID] then
            seen[npcID] = true
            local name = ns.GetNpcInfo(npcID)
            if name then
              successCount = successCount + 1
            else
              failCount = failCount + 1
              retryQueue[npcID] = {
                attempts = 0,
                mapID = mapID,
                coord = coord,
                sourceFile = node.sourceFile or ns.currentSourceFile or "?"
              }
              if ns.DevMode() then
                print(("%s Missing NPC: %d (mapID: %d, coord: %.2f, file: %s) test 1"):format(ns.COLORED_ADDON_NAME, npcID, mapID, coord, retryQueue[npcID].sourceFile, "test1"))
              end
            end
          end
        end
      end
    end
  end

  scanContainer(ns.nodes)
  scanContainer(ns.minimap)

  ns.npcCacheSuccess = successCount
  ns.npcCacheFail = failCount

  local cachingTextDone = ns.LOCALE_CACHING_DONE[ns.locale] or ns.LOCALE_CACHING_DONE["enUS"] or "update database"
  local FoundMIssing = ns.LOCALE_FOUND_MISSING[ns.locale] or ns.LOCALE_FOUND_MISSING["enUS"] or "%s %s - %d found, %d missing"
  if ns.DevMode() or ns.manualScanActive then
    print((FoundMIssing):format(ns.COLORED_ADDON_NAME, cachingTextDone, ns.npcCacheSuccess, ns.npcCacheFail))
  end

  if failCount > 0 then
    local cachingText = ns.LOCALE_RETRY[ns.locale] or ns.LOCALE_RETRY["enUS"]
    print(ns.COLORED_ADDON_NAME .. " " .. cachingText .. " ...")
    ns.StartRetryQueue()
  end
end

local function withAllCategoriesEnabled(fn)
  local profile = ns.Addon and ns.Addon.db and ns.Addon.db.profile
  if type(profile) ~= "table" then
    local ok = pcall(fn); return
  end

  local NEGATE = {
    showZoneMapNotesIcons = true,

    -- Capitals
    showCapitalsMapNotes = true,
    showCapitalsProfessionsMixed = true,
    showCapitalsCooking = true,
    showCapitalsEnchanting = true,
    showCapitalsEngineer = true,
    showCapitalsFishing = true,
    showCapitalsHerbalism = true,
    showCapitalsInscription = true,
    showCapitalsJewelcrafting = true,
    showCapitalsLeatherworking = true,
    showCapitalsMining = true,
    showCapitalsSkinning = true,

    -- Capitals Minimap
    showMinimapCapitalsProfessionsMixed = true,
    showMinimapCapitalsCooking = true,
    showMinimapCapitalsEnchanting = true,
    showMinimapCapitalsEngineer = true,
    showMinimapCapitalsFishing = true,
    showMinimapCapitalsHerbalism = true,
    showMinimapCapitalsInscription = true,
    showMinimapCapitalsJewelcrafting = true,
    showMinimapCapitalsLeatherworking = true,
    showMinimapCapitalsMining = true,
    showMinimapCapitalsSkinning = true,
  }

  local snapshot = {}
  local EXCLUDE_TRUE = {
    ["DeveloperMode"] = true,
    ["activate.HideMapNote"] = true,
    ["activate.HideMMB"] = true,
    ["activate.HideWMB"] = true,
  }

  local function override_bools(tbl, path)
    for k, v in pairs(tbl) do
      local keypath = (path and path ~= "") and (path .. "." .. k) or k
      if type(v) == "boolean" then
        snapshot[keypath] = v
        if not EXCLUDE_TRUE[keypath] then
          tbl[k] = true
        end
      elseif type(v) == "table" then
        override_bools(v, keypath)
      end
    end
  end

  local function restore_bools(tbl, path)
    for k, v in pairs(tbl) do
      local keypath = (path and path ~= "") and (path .. "." .. k) or k
      if snapshot[keypath] ~= nil then
        tbl[k] = snapshot[keypath]
      elseif type(v) == "table" then
        restore_bools(v, keypath)
      end
    end
  end

  local function set_by_key(root, key, newval)
    if root[key] ~= nil then
      if snapshot[key] == nil then snapshot[key] = root[key] end
      root[key] = newval
    end
  end

  override_bools(profile, "")

  if profile.activate and type(profile.activate.HideMapNote) == "boolean" then
    if snapshot["activate.HideMapNote"] == nil then
      snapshot["activate.HideMapNote"] = profile.activate.HideMapNote
    end
    profile.activate.HideMapNote = false
  end

  for key in pairs(NEGATE) do
    set_by_key(profile, key, false)
  end

  local ok, err = pcall(fn)

  restore_bools(profile, "")

  if not ok and ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.DevMode() then
    print(ns.COLORED_ADDON_NAME .. " Rebuild error: " .. tostring(err))
  end
end

function ns.RebuildNpcNameCache(opts)
  opts = opts or {}

  local db = HandyNotes_MapNotesRetailNpcCacheDB or {}
  HandyNotes_MapNotesRetailNpcCacheDB = db

  local loc = ns.locale or GetLocale() or "enUS"
  db.names = db.names or {}
  db.names[loc] = db.names[loc] or {}

  ns.SilenceHN(true)

  withAllCategoriesEnabled(function()
    if ns.Addon and ns.Addon.FullUpdate then
      ns.Addon:FullUpdate()
    end
    ns.manualScanActive = true
    if ns.PrimeNpcNameCache then ns.PrimeNpcNameCache() end
    ns.manualScanActive = false
  end)

  if ns.Addon and ns.Addon.FullUpdate then
    ns.Addon:FullUpdate()
  end

  ns.SilenceHN(false)
  if HandyNotes and HandyNotes.SendMessage then
    HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
  end
end


function ns.GetNpcCacheStats()
  local loc = ns.locale or GetLocale() or "enUS"
  local saved = 0
  local bucket = (HandyNotes_MapNotesRetailNpcCacheDB and HandyNotes_MapNotesRetailNpcCacheDB.names and HandyNotes_MapNotesRetailNpcCacheDB.names[loc]) or {}
  for _ in pairs(bucket) do saved = saved + 1 end

  local ram = 0
  for _ in pairs(npcNameCache) do ram = ram + 1 end

  return ram, saved, loc
end

function ns.StartRetryQueue()
  if retryTimer then return end

  retryTimer = C_Timer.NewTicker(retryInterval, function()
    local processed = 0
    local fps = GetFramerate() or 60
    local scale
    if fps >= 120 then scale = 1.00
    elseif fps >= 90 then scale = 0.85
    elseif fps >= 60 then scale = 0.70
    elseif fps >= 45 then scale = 0.55
    elseif fps >= 30 then scale = 0.40
    else scale = 0.25 
    end
    local maxPerTick = math.max(3, math.floor(maxPerTickBase * scale))
    local startMs = debugprofilestop()

    for npcID, data in pairs(retryQueue) do
      local name = ns.GetNpcInfo(npcID)
      if name then
        retryQueue[npcID] = nil

        ns.npcCacheSuccess = (ns.npcCacheSuccess or 0) + 1
        if (ns.npcCacheFail or 0) > 0 then
          ns.npcCacheFail = ns.npcCacheFail - 1
        end

        if ns.DevMode() then
          print(("%s Cached after retry: %d (mapID: %d, file: %s)"):format(ns.COLORED_ADDON_NAME, npcID, data.mapID or 0, data.sourceFile or "?"))
        end

      else
        data.attempts = (data.attempts or 0) + 1
        if data.attempts >= maxRetries then
          retryQueue[npcID] = nil

          if ns.DevMode() then
            print(("%s Failed to cache: %d after %d tries (mapID: %d, coord: %.2f, file: %s)"):format(ns.COLORED_ADDON_NAME, npcID, maxRetries, data.mapID or 0, data.coord or 0, data.sourceFile or "?"))
          end

        end
      end

      processed = processed + 1
      if processed >= maxPerTick or (debugprofilestop() - startMs) >= timeBudgetMs then
        break
      end
    end

    local FoundMIssing = ns.LOCALE_FOUND_MISSING[ns.locale] or ns.LOCALE_FOUND_MISSING["enUS"] or "%s %s - %d found, %d missing"
    if next(retryQueue) == nil then
      retryTimer:Cancel()
      retryTimer = nil
      local cachingText = ns.LOCALE_RETRY_DONE[ns.locale] or ns.LOCALE_RETRY_DONE["enUS"]
      print((FoundMIssing):format(ns.COLORED_ADDON_NAME, cachingText, ns.npcCacheSuccess, ns.npcCacheFail))
    end

  end)
end

function ns.NpcTooltips(tooltip, nodeData )
  if not nodeData then return end

  if nodeData.type ~= "LFR" and nodeData.npcID then
    local npcName = ns.GetNPCName(nodeData.npcID)
    local npcTitle
    if not npcName then
      npcName, npcTitle = ns.GetNpcInfo(nodeData.npcID)
    else
      local tuple = ns.npcNameCache[nodeData.npcID]; npcTitle = tuple and tuple[2]
    end
    if npcName then
      tooltip:AddLine("|cffffffff" .. npcName)
    end
    if npcTitle and not npcTitle:match("%?%?+") then
      tooltip:AddLine(npcTitle)
    end
  end

  for i = 1, 10 do
    local id = nodeData["npcIDs" .. i]
    local icon = nodeData["icon" .. i]
    if id then
      local npcName = ns.GetNPCName(id)
      local npcTitle
      if not npcName then
        npcName, npcTitle = ns.GetNpcInfo(id) 
      else
        local tuple = ns.npcNameCache[id]; npcTitle = tuple and tuple[2]
      end

      if icon then
        if npcName then tooltip:AddLine(npcName) end
        if npcTitle and not npcTitle:match("%?%?+") then
          tooltip:AddLine(icon .. " " .. npcTitle)
        end
      else
        if npcName then tooltip:AddLine("|cffffffff" .. npcName) end
        if npcTitle and not npcTitle:match("%?%?+") then
          tooltip:AddLine(npcTitle)
        end
      end

      if i < 10 and (nodeData["npcIDs"..(i+1)] or nodeData.dnID) then
        tooltip:AddLine(" ")
      end
    end
  end

  -- old example npcIDs1-9
  --if nodeData.npcIDs1 then -- additional npcIDs
  --  local npcName, npcTitle = ns.GetNpcInfo(nodeData.npcIDs1)
  --  if nodeData.icon1 then
  --    if npcName then 
  --    tooltip:AddLine( (npcName or "???"))
  --    end
  --    if npcTitle and not npcTitle:match("%?%?+") then 
  --      tooltip:AddLine(nodeData.icon1 .. " " .. npcTitle)
  --    end
  --  else
  --    if npcName then 
  --      tooltip:AddLine("|cffffffff" .. npcName)
  --    end
  --    if npcTitle and not npcTitle:match("%?%?+") then 
  --      tooltip:AddLine(npcTitle) 
  --    end
  --  end
  --  if nodeData.npcIDs2 or nodeData.dnID then
  --    tooltip:AddLine(" ")
  --  end
  --end

end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, addonName)
  if addonName ~= "HandyNotes_MapNotes" then return end

  if type(HandyNotes_MapNotesRetailNpcCacheDB) ~= "table" then
    HandyNotes_MapNotesRetailNpcCacheDB = {}
  end

  local db = HandyNotes_MapNotesRetailNpcCacheDB
  db.names = db.names or {}
  db.cacheVersion = db.cacheVersion or ""

  -- delete savedvariables npc names if a new version is live
  --if db.cacheVersion ~= ns.CurrentAddonVersion then 
  --  db.names = {}
  --  db.cacheVersion = ns.CurrentAddonVersion
  --end

  local loc = ns.locale or GetLocale() or "enUS"
  db.names[loc] = db.names[loc] or {}

  db.lastLocale = db.lastLocale or (ns.locale or GetLocale() or "enUS")
  local current = ns.locale or GetLocale() or "enUS"
  if db.lastLocale ~= current then
    db.lastLocale = current
    for k in pairs(npcNameCache) do npcNameCache[k] = nil end

    C_Timer.After(2, function()
      if ns.Addon and ns.Addon.db and ns.DevMode() then
        local txt = (ns.LOCALE_CACHING and (ns.LOCALE_CACHING[current] or ns.LOCALE_CACHING.enUS)) or "update npc name database"
        print(ns.COLORED_ADDON_NAME .. " " .. txt .. " ...")
      end
      ns.RebuildNpcNameCache()
    end)
  end

  do
    local bucket = db.names[loc]
    for id, packed in pairs(bucket) do
      local name, title = string.match(packed, "^(.-)\031(.*)$")
      if name and name ~= "" then
        local idNum = tonumber(id) or id
        npcNameCache[idNum] = { name, title ~= "" and title or nil }
      end
    end
  end

  if db.lastNpcCacheVersion ~= ns.CurrentAddonVersion then
    db.lastNpcCacheVersion = ns.CurrentAddonVersion

    if ns.PrimeNpcNameCache then
      local cachingText = ns.LOCALE_CACHING[ns.locale] or ns.LOCALE_CACHING["enUS"]
      C_Timer.After(2, function()
        if ns.DevMode() then
          print(ns.COLORED_ADDON_NAME .. " " .. cachingText .. " ...")
        end
        ns.RebuildNpcNameCache()
      end)
    end
  end

end)

function ns.CreateTargetButton(npcName, title)
  if not npcName then return end
  if InCombatLockdown() then return end

  local x, y = GetCursorPosition()
  local scale = UIParent:GetEffectiveScale() or 1
  x, y = x/scale, y/scale

  if not ns.TargetButton then
    local btn = CreateFrame("Button", "MapNotesTargetButton", UIParent, "SecureActionButtonTemplate,UIPanelButtonTemplate")
    btn:SetSize(80, 30)
    btn:SetFrameStrata("FULLSCREEN_DIALOG")
    btn:SetToplevel(true)

    btn:RegisterForClicks("AnyDown", "AnyUp")

    btn:SetScript("OnMouseUp", function(self, button)
      if button == "RightButton" then
        self:Hide()
      end
    end)

    btn:SetScript("PreClick", function(self, button)
      if button ~= "LeftButton" then return end
      local npcName = self.npcName
      if not npcName or npcName == "" then return end

      local macro = string.format("/target %s\n/run if UnitExists('target') and (GetRaidTargetIndex('target') or 0) ~= 7 then SetRaidTarget('target', 7) end", npcName)
      self:SetAttribute("type", "macro")
      self:SetAttribute("type1", "macro")
      self:SetAttribute("macrotext", macro)
      self:SetAttribute("macrotext1", macro)
    end)

    btn:SetScript("PostClick", function(self)
      local expectName = self.npcName
      local expectTitle = self.npcTitle
      C_Timer.After(0.2, function()
        if not UnitExists("target") or UnitName("target") ~= expectName then
          local fullName = expectTitle and (expectName .. " – " .. expectTitle) or expectName
          local colored = "|cffffd700" .. fullName .. "|r"
          local CurrentMapID = WorldMapFrame and WorldMapFrame:GetMapID()
          if ns.Addon.db.profile.NpcNameTargetingChatText and (CurrentMapID ~= 626 and CurrentMapID ~= 747) then
            print(("%s %s (%s)"):format(ns.COLORED_ADDON_NAME, SPELL_FAILED_CUSTOM_ERROR_216, colored))
          end
        end
      end)
      C_Timer.After(0.05, function() self:Hide() end)
    end)

    btn:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_TOP")
      GameTooltip:SetText(ns.COLORED_ADDON_NAME, 1, 1, 1)
      local actionText = ns.LOCALE_TARGETING[ns.locale] or ns.LOCALE_TARGETING["enUS"]
      GameTooltip:AddLine(KEY_BUTTON1 .. " => " .. actionText, 1, 1, 1)
      GameTooltip:AddLine(KEY_BUTTON2 .. " => " .. CANCEL, 1, 1, 1)
      GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)

    btn:SetScript("OnHide", function(self)
      self:ClearAllPoints()
      self:SetAttribute("macrotext", nil)
      self:SetAttribute("macrotext1", nil)
      self:SetAttribute("type", nil)
      self:SetAttribute("type1", nil)
      self.npcName, self.npcTitle = nil, nil
    end)

    ns.TargetButton = btn
  end

  local btn = ns.TargetButton
  btn:ClearAllPoints()
  btn:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)

  btn.npcName  = npcName
  btn.npcTitle = title

  btn:SetText(npcName)
  local w = btn:GetFontString():GetStringWidth() + 20
  btn:SetWidth(math.max(80, w))

  btn:SetAttribute("type", "macro")
  btn:SetAttribute("type1", "macro")

  btn:Show()
end

function ns.TryCreateTarget(uiMapId, coord, button)
  if InCombatLockdown() then return false end
  if ns.Addon.db.profile.NpcNameTargeting then
    if button ~= "MiddleButton" or not IsShiftKeyDown() then return false end

    local cd = ns.nodes[uiMapId] and ns.nodes[uiMapId][coord]
    local npcID = cd and (cd.npcID or cd.npcIDs1)
    if not npcID then return false end

    local npcName, npcTitle = ns.GetNpcInfo(npcID)
    if not npcName then return false end

    local nx, ny = HandyNotes:getXY(coord)
    if not (nx and ny) then return false end

    -- distanz from GetWorldPosFromMapPos
    local fullName = npcTitle and (npcName.." – "..npcTitle) or npcName
    local colored = "|cffffd700"..fullName.."|r"
    local pX, pY, pZ = UnitPosition("player")
    local _, wp = C_Map.GetWorldPosFromMapPos(uiMapId, { x = nx, y = ny })
    if wp then
      local wX, wY, wZ = wp.x, wp.y, wp.z or 0
      local dx, dy = pX - wX, pY - wY
      local distYards = math.sqrt(dx*dx + dy*dy)

      --local distMeters = distYards * 0.9144
      --print( ("%s Entfernung: %.1f Y / %.1f m"):format( ns.COLORED_ADDON_NAME, distYards, distMeters ))
      local desiredYards = 102
      if distYards <= desiredYards then
        ns.CreateTargetButton(npcName, npcTitle)
      else
        if ns.Addon.db.profile.NpcNameTargetingChatText then
          print( ("%s %s (%s)"):format(ns.COLORED_ADDON_NAME, SPELL_FAILED_CUSTOM_ERROR_216, colored))
        end
      end
    end

    return true
  end
end

hooksecurefunc(WorldMapFrame, "Hide", function()
  if ns.TargetButton and ns.TargetButton:IsShown() then
    ns.TargetButton:Hide()
  end
end)

ns.pluginHandler = ns.pluginHandler or {}
ns.pluginHandler.OnEnter = function(self, uiMapId, coord)
  local nodeData = (ns.minimap[uiMapId] and ns.minimap[uiMapId][coord]) or (ns.nodes[uiMapId] and ns.nodes[uiMapId][coord])
  if not nodeData then return end

  local tooltip = (self:GetParent()==WorldMapButton and WorldMapTooltip) or GameTooltip
  if self:GetCenter() > UIParent:GetCenter() then
    tooltip:SetOwner(self, "ANCHOR_LEFT")
  else
    tooltip:SetOwner(self, "ANCHOR_RIGHT")
  end

  ns.NpcTooltips(tooltip, nodeData)
  tooltip:Show()
end