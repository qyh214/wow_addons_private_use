local ADDON_NAME, ns = ...

local function MN_GetNodeDataFromPin(pin)
  if not pin then return nil end
  local uiMapId = pin.uiMapId or pin.uiMapID or pin.mapID
  local coord = pin.coord
  if uiMapId == nil or coord == nil then return nil end
  if not (ns.nodes and ns.nodes[uiMapId]) then return nil end
  return ns.nodes[uiMapId][coord], uiMapId, coord
end

local function MN_SetPinOverlayState(pin, makeHigh)
  if not pin then return end
  local wantStrata = makeHigh and "HIGH" or "MEDIUM"
  local wantLevel = makeHigh and 9999 or 1

  if pin.SetFrameStrata then
    if not pin.GetFrameStrata or pin:GetFrameStrata() ~= wantStrata then
      pin:SetFrameStrata(wantStrata)
    end
  end

  if pin.SetFrameLevel then
    if not pin.GetFrameLevel or pin:GetFrameLevel() ~= wantLevel then
      pin:SetFrameLevel(wantLevel)
    end
  end
end

local function MN_ApplyOverlay()
  if not (WorldMapFrame and WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child) then return end

  local child = WorldMapFrame.ScrollContainer.Child
  local children = { child:GetChildren() }

  for _, pin in ipairs(children) do
    if pin and pin.GetObjectType and (pin:GetObjectType() == "Button" or pin:GetObjectType() == "Frame") then
      local onEnter = pin.GetScript and pin:GetScript("OnEnter")

      local isMapNotes = (pin.pluginName == "MapNotes")
        or (ns.pluginHandler and (pin.handler == ns.pluginHandler or pin.pluginHandler == ns.pluginHandler or onEnter == ns.pluginHandler.OnEnter))

      if isMapNotes then
        local nodeData = MN_GetNodeDataFromPin(pin)
        if nodeData and nodeData.HigherStrataLevel then
          MN_SetPinOverlayState(pin, true)
        end
      end
    end
  end
end

local function MN_ScheduleOverlay()
  C_Timer.After(0, MN_ApplyOverlay)
  C_Timer.After(0.05, MN_ApplyOverlay)
end

ns.MN_ScheduleOverlay = MN_ScheduleOverlay

C_Timer.After(0, function()
  if not WorldMapFrame then return end

  WorldMapFrame:HookScript("OnShow", MN_ScheduleOverlay)

  if type(WorldMapFrame.OnMapChanged) == "function" then
    hooksecurefunc(WorldMapFrame, "OnMapChanged", MN_ScheduleOverlay)
  else
    hooksecurefunc(WorldMapFrame, "SetMapID", MN_ScheduleOverlay)
  end

  if ns.Addon and ns.Addon.RegisterMessage then
    ns.Addon:RegisterMessage("HandyNotes_NotifyUpdate", function(_, plugin)
      if plugin == "MapNotes" then
        MN_ScheduleOverlay()
      end
    end)
  end
end)