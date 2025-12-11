local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local function DecodeCoord(coord)
    local x = math.floor(coord / 10000) / 100
    local y = (coord % 10000) / 100
    return x / 100, y / 100
end

local Icon_Size = 20 -- pin size
local function CreateMNFlightPin(parent)
    local FlightmasterMapIcons = CreateFrame("Frame", nil, parent)
    FlightmasterMapIcons:SetSize(Icon_Size, Icon_Size)
    FlightmasterMapIcons:SetFrameStrata("HIGH")
    FlightmasterMapIcons:SetFrameLevel(parent:GetFrameLevel() + 500)
    FlightmasterMapIcons:EnableMouse(true) -- do not let clicks through = true , let clicks through = false
    FlightmasterMapIcons:SetHitRectInsets(0,0,0,0)
    FlightmasterMapIcons.tex = FlightmasterMapIcons:CreateTexture(nil, "OVERLAY")
    FlightmasterMapIcons.tex:SetAllPoints()
    FlightmasterMapIcons.tex:SetTexelSnappingBias(0)
    FlightmasterMapIcons.tex:SetSnapToPixelGrid(false)
    FlightmasterMapIcons:Hide()
    return FlightmasterMapIcons
end

local function ApplyIcon(pin, node)
    if not (pin and node and node.type and ns.icons) then return end

    local icon = ns.icons[node.type]
    if not icon then return end

    if type(icon) == "string" then
        pin.tex:SetTexture(icon)
    elseif icon.atlas then
        pin.tex:SetAtlas(icon.atlas, true)
    elseif icon.texture then
        pin.tex:SetTexture(icon.texture)
    end
end

local function ShowTaxiDungeonTooltip(pin, node)
    if not node then return end
    GameTooltip:SetOwner(pin, "ANCHOR_CURSOR")

    local title
    if node.id and type(node.id) ~= "table" then
        if not EJ_GetInstanceInfo then LoadAddOn("Blizzard_EncounterJournal") end
        local ok, name = pcall(EJ_GetInstanceInfo, node.id)
        if ok and name then title = name end
    end
    title = title or node.name or (node.type and (node.type .. (node.id and (" ("..node.id..")") or ""))) or "MapNotes"
    GameTooltip:AddLine("|cffffd200" .. title, 1, 1, 1)

    if node.dnID then
        GameTooltip:AddLine(" ")
        if type(node.dnID) == "table" then
            for _, line in ipairs(node.dnID) do
                GameTooltip:AddLine(line, 1, 1, 1, true)
            end
        else
            GameTooltip:AddLine(node.dnID, 1, 1, 1, true)
        end
    end

    if ns.Addon and ns.Addon.db and ns.Addon.db.profile.BossNames then
        if node.id and type(node.id) ~= "table" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L["Bosses in this instance"])
            if not EJ_GetEncounterInfoByIndex then LoadAddOn("Blizzard_EncounterJournal") end
            pcall(EJ_SelectInstance, node.id)
            local i = 1
            while true do
                local bossName = EJ_GetEncounterInfoByIndex(i)
                if not bossName then break end
                GameTooltip:AddLine("• " .. bossName, 1, 1, 1)
                i = i + 1
            end
        end
    end

    GameTooltip:Show()
end

local provider = { pins = {}, forMapID = nil, canvas = nil, child = nil }
local hooked = false
local function RemoveAllPins()
    for pin in pairs(provider.pins) do
        pin:Hide()
        pin:SetParent(nil)
    end
    wipe(provider.pins)
end

local function PositionAllPins()
    if not provider.child then return end

    local w, h = provider.child:GetSize()
    if not (w and h) or w == 0 or h == 0 then return end

    local scale = provider.canvas and provider.canvas:GetCanvasScale() or 1
    local adjustedSize = Icon_Size / scale

    for pin, pos in pairs(provider.pins) do
        pin:ClearAllPoints()
        pin:SetPoint("CENTER", provider.child, "TOPLEFT", pos.x * w, -pos.y * h)
        pin:SetSize(adjustedSize, adjustedSize)
        pin:Show()
    end
end

local hoveredPin
local function UpdateHoverTooltip()
    if not (provider.canvas and provider.child and next(provider.pins)) then
        if hoveredPin then GameTooltip:Hide(); hoveredPin = nil end
        return
    end

    local mx, my = GetCursorPosition()
    local scale = provider.child:GetEffectiveScale()
    mx, my = mx / scale, my / scale

    local left = provider.child:GetLeft()
    local top = provider.child:GetTop()
    local w, h = provider.child:GetSize()
    if not (left and top and w and h and w > 0 and h > 0) then return end

    local lx = mx - left
    local ly = top - my

    local canvasScale = provider.canvas:GetCanvasScale() or 1
    local adjustedSize = Icon_Size / canvasScale
    local r = adjustedSize * 0.6

    local bestPin, bestDist2
    for pin, pos in pairs(provider.pins) do
        local px = pos.x * w
        local py = pos.y * h
        local dx = lx - px
        local dy = ly - py
        local d2 = dx*dx + dy*dy
        if d2 <= (r*r) and (not bestDist2 or d2 < bestDist2) then
            bestPin, bestDist2 = pin, d2
        end
    end

    if bestPin then
        if hoveredPin ~= bestPin then
            hoveredPin = bestPin
            GameTooltip:Hide()
        end
        ShowTaxiDungeonTooltip(bestPin, provider.pins[bestPin] and provider.pins[bestPin].node)
    else
        if hoveredPin then GameTooltip:Hide(); hoveredPin = nil end
    end

end


local function RefreshAllData()
    if not (FlightMapFrame and FlightMapFrame:IsShown()) then return end

    local map = FlightMapFrame
    local canvas = map and map.ScrollContainer
    local child = canvas and canvas.Child
    if not (canvas and child) then return end

    local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
    if db and db.activate and db.activate.HideMapNote then
        RemoveAllPins(); return
    end
    if db and db.showTaxiMapNodes == false then
        RemoveAllPins(); return
    end

    provider.canvas, provider.child, provider.forMapID = canvas, child, map:GetMapID()

    RemoveAllPins()

    local t = ns.nodes and ns.nodes[provider.forMapID]
    if t then
        for coord, node in pairs(t) do
            local x, y = DecodeCoord(coord)
            if x and y and x > 0 and x < 1 and y > 0 and y < 1 then
                local pin = CreateMNFlightPin(child)
                ApplyIcon(pin, node)

                provider.pins[pin] = { x = x, y = y, node = node }
            end
        end
    end

    if not child._mnSizeHooked then
        child:HookScript("OnSizeChanged", PositionAllPins)
        child._mnSizeHooked = true
    end

    PositionAllPins()
    UpdateHoverTooltip()
end

function ns.RefreshTaxiMapIfOpen()
    if FlightMapFrame and FlightMapFrame:IsShown() then
        if EnsureHooks then EnsureHooks() end
        C_Timer.After(0, function()
            if RefreshAllData then RefreshAllData() end
            if ns.TaxiToggleButton and ns.TaxiToggleButton.UpdateTooltip and GameTooltip:IsOwned(ns.TaxiToggleButton) then
                ns.TaxiToggleButton:UpdateTooltip()
            end
        end)
    end
end

local function EnsureHooks()
    if hooked then return end

    local map = FlightMapFrame
    if not (map and map.RegisterCallback) then return end

    map:RegisterCallback("OnMapChanged", function()
        provider.forMapID = map:GetMapID()
        RefreshAllData()
    end, provider)

    hooksecurefunc(FlightMapFrame, "SetMapID", function(_, mapID)
        if provider and provider.forMapID ~= mapID then
            provider.forMapID = mapID
            RefreshAllData()
        end
    end)

    map:RegisterCallback("OnCanvasScaleChanged", function()
        PositionAllPins()
        UpdateHoverTooltip()
    end, provider)

    map:RegisterCallback("OnCanvasPanChanged", function()
        PositionAllPins()
        UpdateHoverTooltip()
    end, provider)

    hooked = true
end

do
  local f = CreateFrame("Frame")
  f:RegisterEvent("TAXIMAP_OPENED")
  f:RegisterEvent("TAXIMAP_CLOSED")
  f:RegisterEvent("ADDON_LOADED")
  f:SetScript("OnEvent", function(_, ev, addon)
    if ev == "ADDON_LOADED" and addon == "Blizzard_FlightMap" then
      if FlightMapFrame and FlightMapFrame.BorderFrame then
        ns.CreateTaxiMapToggleButton()
      end
      return
    end

    if ev == "TAXIMAP_OPENED" and FlightMapFrame and FlightMapFrame:IsShown() then
        ns.UpdateTaxiMapToggleButtonVisibility()
        EnsureHooks()
        RefreshAllData()
        if not hoverTicker then
            hoverTicker = C_Timer.NewTicker(0.05, function()
                if provider.child and next(provider.pins) then
                    UpdateHoverTooltip()
                end
            end)
        end
    elseif ev == "TAXIMAP_CLOSED" then
        RemoveAllPins()
        if hoveredPin then GameTooltip:Hide(); hoveredPin = nil end
        if hoverTicker then hoverTicker:Cancel(); hoverTicker = nil end
        provider.canvas, provider.child, provider.forMapID = nil, nil, nil
    end
  end)
end

function ns.CreateTaxiMapToggleButton()

    local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
    if not (db and db.activate.FlightmapButton) then
        if ns.TaxiToggleButton then ns.TaxiToggleButton:Hide() end
        return
    end

    if ns.TaxiToggleButton and ns.TaxiToggleButton:IsShown() then return end

    local tries = 0
    local function tryCreate()

        tries = tries + 1
        if not FlightMapFrame or not FlightMapFrame:IsShown() then
            if tries < 10 then C_Timer.After(0.05, tryCreate) end
            return
        end

        local parent = FlightMapFrame.BorderFrame or FlightMapFrame
        if not parent then
            if tries < 10 then C_Timer.After(0.05, tryCreate) end
            return
        end

        if not ns.TaxiToggleButton then
            local btn = CreateFrame("Button", "MapNotesTaxiToggleButton", parent)
            btn:SetSize(30, 30)
            btn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -30, -6)
            btn:SetFrameStrata("DIALOG")
            btn:SetFrameLevel(parent:GetFrameLevel() + 20)
            btn:EnableMouse(true)
            
            local tex = btn:CreateTexture(nil, "ARTWORK")
            tex:SetAllPoints()
            if ns.icons and ns.icons.MNL then
              tex:SetTexture(ns.icons.MNL)
            else
              tex:SetAtlas("Waypoint-MapPin-Minor")
            end
            btn.icon = tex

            btn.UpdateTooltip = function(self)
                GameTooltip:SetOwner(self, "MIDDLE")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(ns.COLORED_ADDON_NAME)
                GameTooltip:AddLine(" ")
                local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
                local active = db and db.showTaxiMapNodes
                GameTooltip:AddLine(active and (KEY_BUTTON1 .. " => " .. "|cffff0000" .. L["Hide Instances"]) or (KEY_BUTTON1 .. " => " .. "|cff00ff00" .. L["Show Instances"]), 1, 1, 1)
                GameTooltip:Show()
            end

            btn:SetScript("OnEnter", function(self) self:UpdateTooltip() end)

            btn:SetScript("OnLeave", GameTooltip_Hide)

            btn:SetScript("OnClick", function()
                if not (ns.Addon and ns.Addon.db and ns.Addon.db.profile) then return end
                
                local db = ns.Addon.db.profile
                db.showTaxiMapNodes = not db.showTaxiMapNodes
                if db.showTaxiMapNodes then
                    if FlightMapFrame and FlightMapFrame:IsShown() and RefreshAllData then
                        RefreshAllData()
                    end
                else
                    if RemoveAllPins then
                        RemoveAllPins()
                    end
                end
            end)
            ns.TaxiToggleButton = btn
        else
            ns.TaxiToggleButton:SetParent(parent)
            ns.TaxiToggleButton:ClearAllPoints()
            ns.TaxiToggleButton:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, -30)
            ns.TaxiToggleButton:SetFrameStrata("DIALOG")
            ns.TaxiToggleButton:SetFrameLevel(parent:GetFrameLevel() + 20)
            ns.TaxiToggleButton:Show()
        end
    end

    tryCreate()
end

function ns.UpdateTaxiMapToggleButtonVisibility()
    local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
    if not db then return end

    if db.activate.HideMapNote then
        if ns.TaxiToggleButton then ns.TaxiToggleButton:Hide() end
        if RemoveAllPins then RemoveAllPins() end
        return
    end

    if db.activate.FlightmapButton then
        ns.CreateTaxiMapToggleButton()
        if ns.TaxiToggleButton then ns.TaxiToggleButton:Show() end
    else
        if ns.TaxiToggleButton then ns.TaxiToggleButton:Hide() end
    end
end