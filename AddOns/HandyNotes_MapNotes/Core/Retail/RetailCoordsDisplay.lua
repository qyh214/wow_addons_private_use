local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local function MN_IsMapMaximized()
  return WorldMapFrame and WorldMapFrame.IsMaximized and WorldMapFrame:IsMaximized() or false
end

local function MN_GetUnifiedMouseScale()
  local dc = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.displayCoords
  if not dc then return 1 end
  return dc.MouseCoordsSize or (dc.mouse and dc.mouse.scale) or (dc.mouseMax and dc.mouseMax.scale) or 1
end

local function MN_CurrentMousePos()
  local dc = ns.Addon.db.profile.displayCoords
  if MN_IsMapMaximized() then return dc.mouseMax or dc.mouse end
  return dc.mouse or dc.mouseMax
end

local function MN_ReanchorMouseFrame()
  if not MouseCoordsFrame then return end
  local pos = MN_CurrentMousePos(); if not pos then return end
  local anchor = _G[pos.relativeTo]; if not anchor or not anchor:IsVisible() then anchor = UIParent end
  MouseCoordsFrame:ClearAllPoints()
  MouseCoordsFrame:SetPoint(pos.point, anchor, pos.relativePoint, pos.x, pos.y)
  MouseCoordsFrame:SetScale(MN_GetUnifiedMouseScale())
end

function ns.CreatePlayerCoordsFrame()
  local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
  if not (db and db.displayCoords and db.displayCoords.showPlayerCoords) then return end

  local pos = ns.Addon.db.profile.displayCoords.player or { point = "TOPRIGHT", relativeTo = "UIParent", relativePoint = "TOPRIGHT", x = -52.68329620361328, y = -250.0940246582031, scale = 1.0 }
  local dc = ns.Addon.db.profile.displayCoords
  local pScale = (pos and pos.scale) or (dc and dc.PlayerCoordsSize) or 1.0
  if PlayerCoordsFrame then
    PlayerCoordsFrame:SetScale(pScale)
    PlayerCoordsFrame:Show()
    return
  end

  local anchor = _G[pos.relativeTo] or UIParent
  local playerFrame = CreateFrame("Frame", "PlayerCoordsFrame", UIParent)
  playerFrame:SetSize(120, 30)
  playerFrame:SetPoint(pos.point, anchor, pos.relativePoint, pos.x, pos.y)
  playerFrame:SetScale(pScale)
  playerFrame:SetFrameStrata("MEDIUM")
  playerFrame:SetFrameLevel(5)
  playerFrame:SetMovable(true)
  playerFrame:EnableMouse(true)
  playerFrame:RegisterForDrag("LeftButton")

  playerFrame:SetScript("OnDragStart", function(self, button)
    if button == "LeftButton" and IsShiftKeyDown() then
      self:StartMoving()
    end
  end)

  playerFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, x, y = self:GetPoint()
    ns.Addon.db.profile.displayCoords.player = {
      point = point,
      relativeTo = relativeTo and relativeTo:GetName() or "UIParent",
      relativePoint = relativePoint,
      x = x, y = y,
      scale = self:GetScale()
    }
    ns.Addon.db.profile.displayCoords.PlayerCoordsSize = self:GetScale()
  end)

  playerFrame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    if not ns.Addon.db.profile.activate.HideMapNote then
      if ns.Addon.db.profile.displayCoords.showCoordTooltip then
        GameTooltip:AddLine(ns.COLORED_ADDON_NAME .. " " .. L["Player coordinates"], 1, 1, 1, true)
        GameTooltip:AddLine(TextIconInfo:GetIconString() .. "|cff00ff00< " .. L["Hold down Shift + Left mouse button to move"] .. " >", 1, 1, 1)
      end
    end
    GameTooltip:Show()
  end)

  playerFrame:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  local alpha = ns.Addon.db.profile.displayCoords.PlayerCoordsAlpha or 1
  playerFrame.background = playerFrame:CreateTexture(nil, "BACKGROUND")
  playerFrame.background:SetAllPoints()
  playerFrame.background:SetColorTexture(0, 0, 0, alpha)

  playerFrame.border = CreateFrame("Frame", nil, playerFrame, "BackdropTemplate")
  playerFrame.border:SetAllPoints()
  playerFrame.border:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
  playerFrame.border:SetBackdropBorderColor(1, 0.8, 0)
  playerFrame.border:SetAlpha(alpha)

  playerFrame.text = playerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  playerFrame.text:SetPoint("CENTER")
  playerFrame.text:SetText(ns.COLORED_ADDON_NAME)

  local lastX, lastY = 0, 0
  local function UpdateCoords()
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID then
      local pos = C_Map.GetPlayerMapPosition(mapID, "player")
      if pos then
        local x, y = pos:GetXY()
        if x and y and x > 0 and y > 0 then
          x = math.floor(x * 10000 + 0.5) / 100
          y = math.floor(y * 10000 + 0.5) / 100
          if x ~= lastX or y ~= lastY then
            playerFrame.text:SetFormattedText("|cffff0000%.2f|r |cff00ccff%.2f|r", x, y)
            lastX, lastY = x, y
          end
        else
          playerFrame.text:SetText("")
        end
      end
    end
  end

  playerFrame:SetScript("OnUpdate", function(self, elapsed)
    if not self:IsVisible() then return end
    self.timer = (self.timer or 0) + elapsed
    if self.timer >= 0.2 then
      UpdateCoords()
      self.timer = 0
    end
  end)
end

function ns.CreateMouseCoordsFrame()
  local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
  if not (db and db.displayCoords and db.displayCoords.showMouseCoords) then return end
  if not ns.Addon or not ns.Addon.db or not ns.Addon.db.profile.displayCoords.showMouseCoords then return end
  if not WorldMapFrame:IsShown() then return end

  local dc = ns.Addon.db.profile.displayCoords
  dc.mouse = dc.mouse or { point="TOPLEFT",  relativeTo="UIParent", relativePoint="TOPLEFT", x=19.4, y=-207, scale=dc.MouseCoordsSize or 1.0 }
  dc.mouseMax = dc.mouseMax or { point="TOPRIGHT", relativeTo="UIParent", relativePoint="TOPRIGHT", x=-370.415771484375, y=-1.976189851760864, scale=dc.MouseCoordsSize or 0.7 }

  if MouseCoordsFrame then
    MN_ReanchorMouseFrame()
    return
  end

  local mouseFrame = CreateFrame("Frame", "MouseCoordsFrame", UIParent)
  mouseFrame:SetSize(190, 30)
  mouseFrame:SetFrameStrata("HIGH")
  mouseFrame:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 5)
  mouseFrame:SetMovable(true)
  mouseFrame:EnableMouse(true)
  mouseFrame:RegisterForDrag("LeftButton")
  MN_ReanchorMouseFrame()

  mouseFrame:SetScript("OnDragStart", function(self, button)
    if button == "LeftButton" and IsShiftKeyDown() then
      self:StartMoving()
    end
  end)

  mouseFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, x, y = self:GetPoint()
    local dc = ns.Addon.db.profile.displayCoords
    local slot = MN_IsMapMaximized() and "mouseMax" or "mouse"
    dc[slot] = dc[slot] or {}
    dc[slot].point, dc[slot].relativePoint, dc[slot].x, dc[slot].y = point, relativePoint, x, y
    dc[slot].relativeTo = (relativeTo and relativeTo.GetName and relativeTo:GetName()) or "UIParent"
    local s = self:GetScale()
    dc.MouseCoordsSize = s
    dc.mouse = dc.mouse or {}
    dc.mouseMax = dc.mouseMax or {}
    dc.mouse.scale = s
    dc.mouseMax.scale = s
  end)

  mouseFrame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    if not ns.Addon.db.profile.activate.HideMapNote then
      if ns.Addon.db.profile.displayCoords.showCoordTooltip then
        GameTooltip:AddLine(ns.COLORED_ADDON_NAME .. " " .. L["Mouse coordinates"], 1, 1, 1, true)        
        GameTooltip:AddLine(TextIconInfo:GetIconString() .. "|cff00ff00< " .. L["Hold down Shift + Left mouse button to move"] .. " >", 1, 1, 1)
      end
    end
    GameTooltip:Show()
  end)

  mouseFrame:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  local alpha = ns.Addon.db.profile.displayCoords.MouseCoordsAlpha or 1
  mouseFrame.background = mouseFrame:CreateTexture(nil, "BACKGROUND")
  mouseFrame.background:SetAllPoints()
  mouseFrame.background:SetColorTexture(0, 0, 0, alpha)
  mouseFrame.background:SetDrawLayer("BACKGROUND", 0)

  mouseFrame.border = CreateFrame("Frame", nil, mouseFrame, "BackdropTemplate")
  mouseFrame.border:SetAllPoints()
  mouseFrame.border:SetBackdrop({edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 4, right = 4, top = 4, bottom = 4 },})
  mouseFrame.border:SetBackdropBorderColor(1, 0.8, 0)
  mouseFrame.border:SetAlpha(alpha)

  mouseFrame.text = mouseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  mouseFrame.text:SetPoint("CENTER")
  mouseFrame.text:SetText(ns.COLORED_ADDON_NAME)
  mouseFrame.text:SetDrawLayer("OVERLAY", 7)

  local function UpdateMouseCoords()
    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end
    local sc = WorldMapFrame and WorldMapFrame.ScrollContainer
    if not (sc and sc:IsMouseOver()) then
      if MouseCoordsFrame.lastX ~= 0 or MouseCoordsFrame.lastY ~= 0 then
        MouseCoordsFrame.text:SetText(MOUSE_LABEL .. ": |cffff000000.00|r |cff00ccff00.00|r")
        MouseCoordsFrame.lastX, MouseCoordsFrame.lastY = 0, 0
      end
      return
    end
    local x, y
    if WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.GetNormalizedCursorPosition then
      x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
    else
      local cursorX, cursorY = GetCursorPosition()
      local scale = WorldMapFrame:GetEffectiveScale()
      cursorX = cursorX / scale
      cursorY = cursorY / scale
      if WorldMapDetailFrame and WorldMapDetailFrame:IsVisible() then
        local left = WorldMapDetailFrame:GetLeft()
        local top = WorldMapDetailFrame:GetTop()
        local width = WorldMapDetailFrame:GetWidth()
        local height = WorldMapDetailFrame:GetHeight()
        if left and top and width and height then
          x = (cursorX - left) / width
          y = (top - cursorY) / height
        end
      end
      if (not x or not y) and WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.NormalizeUIPosition then
        x, y = WorldMapFrame.ScrollContainer:NormalizeUIPosition(cursorX, cursorY)
      end
    end

    if x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
      local x2 = math.floor(x * 10000 + 0.5) / 100
      local y2 = math.floor(y * 10000 + 0.5) / 100
      if x2 ~= MouseCoordsFrame.lastX or y2 ~= MouseCoordsFrame.lastY then
        MouseCoordsFrame.text:SetFormattedText(MOUSE_LABEL .. ": |cffff0000%.2f|r |cff00ccff%.2f|r", x2, y2)
        MouseCoordsFrame.lastX, MouseCoordsFrame.lastY = x2, y2
      end
    else
      if MouseCoordsFrame.lastX ~= 0 or MouseCoordsFrame.lastY ~= 0 then
        MouseCoordsFrame.text:SetText(MOUSE_LABEL .. ": |cffff000000.00|r |cff00ccff00.00|r")
        MouseCoordsFrame.lastX, MouseCoordsFrame.lastY = 0, 0
      end
    end
  end

  mouseFrame:SetScript("OnUpdate", function(self, elapsed)
    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end
    self.timer = (self.timer or 0) + elapsed
    if self.timer >= 0.1 then
      UpdateMouseCoords()
      self.timer = 0
    end
  end)

  MouseCoordsFrame = mouseFrame
  mouseFrame.lastX, mouseFrame.lastY = 0, 0

end

function ns.HidePlayerCoordsFrame()
  if PlayerCoordsFrame then
    PlayerCoordsFrame:Hide()
    PlayerCoordsFrame:SetScript("OnUpdate", nil)
    PlayerCoordsFrame:SetParent(nil)
    _G["PlayerCoordsFrame"] = nil
  end
end

function ns.HideMouseCoordsFrame()
  if MouseCoordsFrame then
    MouseCoordsFrame:Hide()
    MouseCoordsFrame:SetScript("OnUpdate", nil)
    MouseCoordsFrame:SetParent(nil)
    _G["MouseCoordsFrame"] = nil
  end
end

C_Timer.After(1, function()
  if ns.Addon and ns.Addon.db then
    ns.CreatePlayerCoordsFrame()

    if WorldMapFrame:IsShown() and ns.Addon.db.profile.displayCoords.showMouseCoords then
      ns.CreateMouseCoordsFrame()
    end
  end
end)

if not ns.MN_MouseSizeHooks then
  ns.MN_MouseSizeHooks = true

  WorldMapFrame:HookScript("OnSizeChanged", function()
    C_Timer.After(0, MN_ReanchorMouseFrame)
  end)

  if WorldMapFrame.Maximize then
    hooksecurefunc(WorldMapFrame, "Maximize", function()
      C_Timer.After(0, MN_ReanchorMouseFrame)
    end)
  end

  if WorldMapFrame.Minimize then
    hooksecurefunc(WorldMapFrame, "Minimize", function()
      C_Timer.After(0, MN_ReanchorMouseFrame)
    end)
  end
end

WorldMapFrame:HookScript("OnHide", function()
  if MouseCoordsFrame then
    MouseCoordsFrame:Hide()
  end
end)

function ns.DefaultPlayerCoords()
  local data = {
    point = "TOPRIGHT",
    relativeTo = "UIParent",
    relativePoint = "TOPRIGHT",
    x = -77.298583984375,
    y = -326.6753234863281,
    scale = 0.8
  }

  ns.Addon.db.profile.displayCoords.player = CopyTable(data)
  ns.Addon.db.profile.displayCoords.PlayerCoordsSize = data.scale

  if PlayerCoordsFrame then
    PlayerCoordsFrame:SetScale(data.scale)
    PlayerCoordsFrame:ClearAllPoints()
    PlayerCoordsFrame:SetPoint(data.point, UIParent, data.relativePoint, data.x, data.y)
  end
end

function ns.DefaultMouseCoords()
  local dc = ns.Addon.db.profile.displayCoords

  local dataMin = {
    point = "TOP",
    relativeTo = "UIParent",
    relativePoint = "TOP",
    x = -637.3314819335938,
    y = -167.6416625976563,
    scale = 0.7,
  }

  local dataMax = {
    point = "TOPRIGHT",
    relativeTo = "UIParent",
    relativePoint = "TOPRIGHT",
    x = -370.415771484375,
    y = -1.976189851760864,
    scale = dataMin.scale,
  }

  dc.mouse = CopyTable(dataMin)
  dc.mouseMax = CopyTable(dataMax)
  dc.MouseCoordsSize = dataMin.scale
  dc.mouse.scale = dataMin.scale
  dc.mouseMax.scale = dataMin.scale

  if MouseCoordsFrame then
    MN_ReanchorMouseFrame()
  end
end

function ns.DefaultPlayerAlpha()
  ns.Addon.db.profile.displayCoords.PlayerCoordsAlpha = 1
  if PlayerCoordsFrame then
    if PlayerCoordsFrame.background then
      PlayerCoordsFrame.background:SetColorTexture(0, 0, 0, 1)
    end
    if PlayerCoordsFrame.border then
      PlayerCoordsFrame.border:SetAlpha(1)
    end
  end
end

function ns.DefaultMouseAlpha()
  ns.Addon.db.profile.displayCoords.MouseCoordsAlpha = 0
  if MouseCoordsFrame then
    if MouseCoordsFrame.background then
      MouseCoordsFrame.background:SetColorTexture(0, 0, 0, 0)
    end
    if MouseCoordsFrame.border then
      MouseCoordsFrame.border:SetAlpha(0)
    end
  end
end

function ns.showPlayerCoordsFrame()
  ns.Addon.db.profile.displayCoords.showPlayerCoords = true
  ns.CreatePlayerCoordsFrame()
end

function ns.showMouseCoordsFrame()
  ns.Addon.db.profile.displayCoords.showMouseCoords = true
  ns.CreateMouseCoordsFrame()
end

function ns.ApplySavedCoords()
  local db = ns.Addon.db.profile
  db.displayCoords = db.displayCoords or CopyTable(ns.defaults.profile.displayCoords or {})
  local player = db.displayCoords.player
  local mouse = db.displayCoords.mouse
  local dc = db.displayCoords

  if db.displayCoords.showPlayerCoords and player then
    if PlayerCoordsFrame then PlayerCoordsFrame:Hide() end
    ns.CreatePlayerCoordsFrame()
    local anchor = _G[player.relativeTo] or UIParent
    local pScale = (player and player.scale) or (dc and dc.PlayerCoordsSize) or 1.0
    PlayerCoordsFrame:SetScale(pScale)
    PlayerCoordsFrame:ClearAllPoints()
    PlayerCoordsFrame:SetPoint(player.point, anchor, player.relativePoint, player.x, player.y)
    PlayerCoordsFrame:Show()
  else
    ns.HidePlayerCoordsFrame()
  end

  if db.displayCoords.showMouseCoords and mouse then
    ns.HideMouseCoordsFrame()
    ns.CreateMouseCoordsFrame()
    if MouseCoordsFrame then
      MN_ReanchorMouseFrame()
      MouseCoordsFrame:Show()
    end
  else
    ns.HideMouseCoordsFrame()
  end

  ns.ApplySavedAlpha()
end

function ns.ApplySavedAlpha()
  local pAlpha = ns.Addon.db.profile.displayCoords.PlayerCoordsAlpha or 1
  local mAlpha = ns.Addon.db.profile.displayCoords.MouseCoordsAlpha or 1

  if PlayerCoordsFrame then
    if PlayerCoordsFrame.background then
      PlayerCoordsFrame.background:SetColorTexture(0, 0, 0, pAlpha)
    end
    if PlayerCoordsFrame.border then
      PlayerCoordsFrame.border:SetAlpha(pAlpha)
    end
  end

  if MouseCoordsFrame then
    if MouseCoordsFrame.background then
      MouseCoordsFrame.background:SetColorTexture(0, 0, 0, mAlpha)
    end
    if MouseCoordsFrame.border then
      MouseCoordsFrame.border:SetAlpha(mAlpha)
    end
  end
end

if not ns.MN_MouseOnShowHook then
  ns.MN_MouseOnShowHook = true
  WorldMapFrame:HookScript("OnShow", function()
    if ns.Addon and ns.Addon.db and ns.Addon.db.profile.displayCoords.showMouseCoords then
      C_Timer.After(0.05, function()
        if not MouseCoordsFrame then ns.CreateMouseCoordsFrame() end
        if MouseCoordsFrame then
          MN_ReanchorMouseFrame()
          MouseCoordsFrame:Show()
        end
      end)
    end
  end)
end
