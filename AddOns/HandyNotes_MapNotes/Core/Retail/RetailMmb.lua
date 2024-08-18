local ADDON_NAME, ns = ...

local iconLink = "Interface\\Addons\\" .. ADDON_NAME .. "\\images\\"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MNMMBIcon = LibStub("LibDBIcon-1.0", true)

ns.miniButton = {
text = ns.COLORED_ADDON_NAME,
type = "data source",
icon = iconLink .. "MNL4",
OnTooltipShow = function(tooltip)
local info = C_Map.GetMapInfo(WorldMapFrame:GetMapID())

  if not tooltip or not tooltip.AddLine then return end
    tooltip:AddLine(ns.COLORED_ADDON_NAME)
    tooltip:AddLine(" ")
    tooltip:AddLine(L["Left-click => Open/Close"] .. " " .. ns.COLORED_ADDON_NAME,1,1,1)
    tooltip:AddLine(L["Shift + Right-click => hide"] .. " " .. "|cffffff00" .. L["-> MiniMapButton <-"],1,1,1)
    tooltip:AddLine(L["Middle-Mouse-Button => Open/Close"] .. " " .. "|cff00ccff" .. "-> " .. WORLDMAP_BUTTON .." <-",1,1,1)

  -- Zone without Sync function
  if not ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6)
    and not (C_Map.GetBestMapForUnit("player") == 1454 or C_Map.GetBestMapForUnit("player") == 1456 --Cata nodes
    or C_Map.GetBestMapForUnit("player") == 2266 -- Millenia's Threshold
    or C_Map.GetBestMapForUnit("player") == 84 or C_Map.GetBestMapForUnit("player") == 87 or C_Map.GetBestMapForUnit("player") == 89 or C_Map.GetBestMapForUnit("player") == 103 or C_Map.GetBestMapForUnit("player") == 85
    or C_Map.GetBestMapForUnit("player") == 90 or C_Map.GetBestMapForUnit("player") == 86 or C_Map.GetBestMapForUnit("player") == 88 or C_Map.GetBestMapForUnit("player") == 110 or C_Map.GetBestMapForUnit("player") == 111
    or C_Map.GetBestMapForUnit("player") == 125 or C_Map.GetBestMapForUnit("player") == 126 or C_Map.GetBestMapForUnit("player") == 391 or C_Map.GetBestMapForUnit("player") == 392 or C_Map.GetBestMapForUnit("player") == 393 
    or C_Map.GetBestMapForUnit("player") == 394 or C_Map.GetBestMapForUnit("player") == 582 or C_Map.GetBestMapForUnit("player") == 590 or C_Map.GetBestMapForUnit("player") == 622 or C_Map.GetBestMapForUnit("player") == 624 
    or C_Map.GetBestMapForUnit("player") == 626 or C_Map.GetBestMapForUnit("player") == 627 or C_Map.GetBestMapForUnit("player") == 628 or C_Map.GetBestMapForUnit("player") == 629 or C_Map.GetBestMapForUnit("player") == 1161
    or C_Map.GetBestMapForUnit("player") == 1163 or C_Map.GetBestMapForUnit("player") == 1164 or C_Map.GetBestMapForUnit("player") == 1165 or C_Map.GetBestMapForUnit("player") == 1670 or C_Map.GetBestMapForUnit("player") == 1671 
    or C_Map.GetBestMapForUnit("player") == 1672 or C_Map.GetBestMapForUnit("player") == 1673 or C_Map.GetBestMapForUnit("player") == 2112 or C_Map.GetBestMapForUnit("player") == 407 or C_Map.GetBestMapForUnit("player") == 2339
    or C_Map.GetBestMapForUnit("player") == 499 or C_Map.GetBestMapForUnit("player") == 500)
  then
    --Kalimdor
    if (C_Map.GetBestMapForUnit("player") == 1 or C_Map.GetBestMapForUnit("player") == 7 or C_Map.GetBestMapForUnit("player") == 10 or C_Map.GetBestMapForUnit("player") == 11 or C_Map.GetBestMapForUnit("player") == 57 or C_Map.GetBestMapForUnit("player") == 62 
      or C_Map.GetBestMapForUnit("player") == 63 or C_Map.GetBestMapForUnit("player") == 64 or C_Map.GetBestMapForUnit("player") == 65 or C_Map.GetBestMapForUnit("player") == 66 or C_Map.GetBestMapForUnit("player") == 67 or C_Map.GetBestMapForUnit("player") == 68 
      or C_Map.GetBestMapForUnit("player") == 69 or C_Map.GetBestMapForUnit("player") == 70 or C_Map.GetBestMapForUnit("player") == 71 or C_Map.GetBestMapForUnit("player") == 74 or C_Map.GetBestMapForUnit("player") == 75 or C_Map.GetBestMapForUnit("player") == 76 
      or C_Map.GetBestMapForUnit("player") == 77 or C_Map.GetBestMapForUnit("player") == 78 or C_Map.GetBestMapForUnit("player") == 80 or C_Map.GetBestMapForUnit("player") == 81 or C_Map.GetBestMapForUnit("player") == 83 or C_Map.GetBestMapForUnit("player") == 97 
      or C_Map.GetBestMapForUnit("player") == 106 or C_Map.GetBestMapForUnit("player") == 199 or C_Map.GetBestMapForUnit("player") == 327 or C_Map.GetBestMapForUnit("player") == 460 or C_Map.GetBestMapForUnit("player") == 461 or C_Map.GetBestMapForUnit("player") == 462 
      or C_Map.GetBestMapForUnit("player") == 468 or C_Map.GetBestMapForUnit("player") == 1527 or C_Map.GetBestMapForUnit("player") == 198 or C_Map.GetBestMapForUnit("player") == 249)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kalimdor"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Eastern Kingdom
    elseif (C_Map.GetBestMapForUnit("player") == 13 or C_Map.GetBestMapForUnit("player") == 14 or C_Map.GetBestMapForUnit("player") == 15 or C_Map.GetBestMapForUnit("player") == 16 or C_Map.GetBestMapForUnit("player") == 17 or C_Map.GetBestMapForUnit("player") == 18 
      or C_Map.GetBestMapForUnit("player") == 19 or C_Map.GetBestMapForUnit("player") == 21 or C_Map.GetBestMapForUnit("player") == 22 or C_Map.GetBestMapForUnit("player") == 23 or C_Map.GetBestMapForUnit("player") == 25 or C_Map.GetBestMapForUnit("player") == 26 
      or C_Map.GetBestMapForUnit("player") == 27 or C_Map.GetBestMapForUnit("player") == 28 or C_Map.GetBestMapForUnit("player") == 30 or C_Map.GetBestMapForUnit("player") == 32 or C_Map.GetBestMapForUnit("player") == 33 or C_Map.GetBestMapForUnit("player") == 34 
      or C_Map.GetBestMapForUnit("player") == 35 or C_Map.GetBestMapForUnit("player") == 36 or C_Map.GetBestMapForUnit("player") == 37 or C_Map.GetBestMapForUnit("player") == 42 or C_Map.GetBestMapForUnit("player") == 47 or C_Map.GetBestMapForUnit("player") == 48 
      or C_Map.GetBestMapForUnit("player") == 49 or C_Map.GetBestMapForUnit("player") == 50 or C_Map.GetBestMapForUnit("player") == 51 or C_Map.GetBestMapForUnit("player") == 52 or C_Map.GetBestMapForUnit("player") == 55 or C_Map.GetBestMapForUnit("player") == 56 
      or C_Map.GetBestMapForUnit("player") == 94 or C_Map.GetBestMapForUnit("player") == 210 or C_Map.GetBestMapForUnit("player") == 224 or C_Map.GetBestMapForUnit("player") == 245 or C_Map.GetBestMapForUnit("player") == 425 or C_Map.GetBestMapForUnit("player") == 427 
      or C_Map.GetBestMapForUnit("player") == 465 or C_Map.GetBestMapForUnit("player") == 467 or C_Map.GetBestMapForUnit("player") == 469 or C_Map.GetBestMapForUnit("player") == 499 or C_Map.GetBestMapForUnit("player") == 500 or C_Map.GetBestMapForUnit("player") == 2070 
      or C_Map.GetBestMapForUnit("player") == 241 or C_Map.GetBestMapForUnit("player") == 203 or C_Map.GetBestMapForUnit("player") == 204 or C_Map.GetBestMapForUnit("player") == 205 or C_Map.GetBestMapForUnit("player") == 241 or C_Map.GetBestMapForUnit("player") == 244 
      or C_Map.GetBestMapForUnit("player") == 245 or C_Map.GetBestMapForUnit("player") == 201 or C_Map.GetBestMapForUnit("player") == 95 or C_Map.GetBestMapForUnit("player") == 122 or C_Map.GetBestMapForUnit("player") == 217  or C_Map.GetBestMapForUnit("player") == 226)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Eastern Kingdom"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Outland
    elseif (C_Map.GetBestMapForUnit("player") == 100 or C_Map.GetBestMapForUnit("player") == 102 or C_Map.GetBestMapForUnit("player") == 104 or C_Map.GetBestMapForUnit("player") == 105 or C_Map.GetBestMapForUnit("player") == 107 or C_Map.GetBestMapForUnit("player") == 108
      or C_Map.GetBestMapForUnit("player") == 109)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Outland"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Northrend
    elseif (C_Map.GetBestMapForUnit("player") == 114 or C_Map.GetBestMapForUnit("player") == 115 or C_Map.GetBestMapForUnit("player") == 116 or C_Map.GetBestMapForUnit("player") == 117 or C_Map.GetBestMapForUnit("player") == 118 or C_Map.GetBestMapForUnit("player") == 119
      or C_Map.GetBestMapForUnit("player") == 120 or C_Map.GetBestMapForUnit("player") == 121 or C_Map.GetBestMapForUnit("player") == 123 or C_Map.GetBestMapForUnit("player") == 127 or C_Map.GetBestMapForUnit("player") == 170)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Northrend"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Pandaria
    elseif (C_Map.GetBestMapForUnit("player") == 371 or C_Map.GetBestMapForUnit("player") == 376 or C_Map.GetBestMapForUnit("player") == 379 or C_Map.GetBestMapForUnit("player") == 388 or C_Map.GetBestMapForUnit("player") == 390 or C_Map.GetBestMapForUnit("player") == 418
      or C_Map.GetBestMapForUnit("player") == 422 or C_Map.GetBestMapForUnit("player") == 433 or C_Map.GetBestMapForUnit("player") == 434 or C_Map.GetBestMapForUnit("player") == 504 or C_Map.GetBestMapForUnit("player") == 554  or C_Map.GetBestMapForUnit("player") == 1530
      or C_Map.GetBestMapForUnit("player") == 507)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Pandaria"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Draenor
    elseif (C_Map.GetBestMapForUnit("player") == 525 or C_Map.GetBestMapForUnit("player") == 534 or C_Map.GetBestMapForUnit("player") == 535 or C_Map.GetBestMapForUnit("player") == 539 or C_Map.GetBestMapForUnit("player") == 542 or C_Map.GetBestMapForUnit("player") == 543
      or C_Map.GetBestMapForUnit("player") == 550 or C_Map.GetBestMapForUnit("player") == 588)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Draenor"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Broken Isles
    elseif (C_Map.GetBestMapForUnit("player") == 630 or C_Map.GetBestMapForUnit("player") == 634 or C_Map.GetBestMapForUnit("player") == 641 or C_Map.GetBestMapForUnit("player") == 646 or C_Map.GetBestMapForUnit("player") == 650 or C_Map.GetBestMapForUnit("player") == 652
      or C_Map.GetBestMapForUnit("player") == 750 or C_Map.GetBestMapForUnit("player") == 680 or C_Map.GetBestMapForUnit("player") == 830 or C_Map.GetBestMapForUnit("player") == 882 or C_Map.GetBestMapForUnit("player") == 885 or C_Map.GetBestMapForUnit("player") == 905
      or C_Map.GetBestMapForUnit("player") == 941 or C_Map.GetBestMapForUnit("player") == 790 or C_Map.GetBestMapForUnit("player") == 971)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Broken Isles"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Zandalar
    elseif (C_Map.GetBestMapForUnit("player") == 862 or C_Map.GetBestMapForUnit("player") == 863 or C_Map.GetBestMapForUnit("player") == 864 or C_Map.GetBestMapForUnit("player") == 1355 or C_Map.GetBestMapForUnit("player") == 1528)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Zandalar"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Kul Tiras
    elseif (C_Map.GetBestMapForUnit("player") == 895 or C_Map.GetBestMapForUnit("player") == 896 or C_Map.GetBestMapForUnit("player") == 942 or C_Map.GetBestMapForUnit("player") == 1462 or C_Map.GetBestMapForUnit("player") == 1169)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kul Tiras"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Shadowlands
    elseif (C_Map.GetBestMapForUnit("player") == 1525 or C_Map.GetBestMapForUnit("player") == 1533 or C_Map.GetBestMapForUnit("player") == 1536 or C_Map.GetBestMapForUnit("player") == 1543 or C_Map.GetBestMapForUnit("player") == 1565 or C_Map.GetBestMapForUnit("player") == 1961
      or C_Map.GetBestMapForUnit("player") == 1970 or C_Map.GetBestMapForUnit("player") == 2016)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Shadowlands"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Dragon Isles
    elseif (C_Map.GetBestMapForUnit("player") == 2022 or C_Map.GetBestMapForUnit("player") == 2023 or C_Map.GetBestMapForUnit("player") == 2024 or C_Map.GetBestMapForUnit("player") == 2025 or C_Map.GetBestMapForUnit("player") == 2026 or C_Map.GetBestMapForUnit("player") == 2133
      or C_Map.GetBestMapForUnit("player") == 2151 or C_Map.GetBestMapForUnit("player") == 2200 or C_Map.GetBestMapForUnit("player") == 2239)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Dragon Isles"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Khaz Algar
    elseif (C_Map.GetBestMapForUnit("player") == 2248 or C_Map.GetBestMapForUnit("player") == 2214 or C_Map.GetBestMapForUnit("player") == 2215 or C_Map.GetBestMapForUnit("player") == 2255 or C_Map.GetBestMapForUnit("player") == 2256 or C_Map.GetBestMapForUnit("player") == 2213 or C_Map.GetBestMapForUnit("player") == 2216)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Khaz Algar"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    end
  end

  -- Zone Sync function
  if ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6)
    and not (C_Map.GetBestMapForUnit("player") == 1454 or C_Map.GetBestMapForUnit("player") == 1456 --Cata nodes
    or C_Map.GetBestMapForUnit("player") == 2266 -- Millenia's Threshold
    or C_Map.GetBestMapForUnit("player") == 84 or C_Map.GetBestMapForUnit("player") == 87 or C_Map.GetBestMapForUnit("player") == 89 or C_Map.GetBestMapForUnit("player") == 103 or C_Map.GetBestMapForUnit("player") == 85
    or C_Map.GetBestMapForUnit("player") == 90 or C_Map.GetBestMapForUnit("player") == 86 or C_Map.GetBestMapForUnit("player") == 88 or C_Map.GetBestMapForUnit("player") == 110 or C_Map.GetBestMapForUnit("player") == 111
    or C_Map.GetBestMapForUnit("player") == 125 or C_Map.GetBestMapForUnit("player") == 126 or C_Map.GetBestMapForUnit("player") == 391 or C_Map.GetBestMapForUnit("player") == 392 or C_Map.GetBestMapForUnit("player") == 393 
    or C_Map.GetBestMapForUnit("player") == 394 or C_Map.GetBestMapForUnit("player") == 582 or C_Map.GetBestMapForUnit("player") == 590 or C_Map.GetBestMapForUnit("player") == 622 or C_Map.GetBestMapForUnit("player") == 624 
    or C_Map.GetBestMapForUnit("player") == 626 or C_Map.GetBestMapForUnit("player") == 627 or C_Map.GetBestMapForUnit("player") == 628 or C_Map.GetBestMapForUnit("player") == 629 or C_Map.GetBestMapForUnit("player") == 1161
    or C_Map.GetBestMapForUnit("player") == 1163 or C_Map.GetBestMapForUnit("player") == 1164 or C_Map.GetBestMapForUnit("player") == 1165 or C_Map.GetBestMapForUnit("player") == 1670 or C_Map.GetBestMapForUnit("player") == 1671 
    or C_Map.GetBestMapForUnit("player") == 1672 or C_Map.GetBestMapForUnit("player") == 1673 or C_Map.GetBestMapForUnit("player") == 2112 or C_Map.GetBestMapForUnit("player") == 407 or C_Map.GetBestMapForUnit("player") == 2339
    or C_Map.GetBestMapForUnit("player") == 499 or C_Map.GetBestMapForUnit("player") == 500)
  then
    --Kalimdor
    if (C_Map.GetBestMapForUnit("player") == 1 or C_Map.GetBestMapForUnit("player") == 7 or C_Map.GetBestMapForUnit("player") == 10 or C_Map.GetBestMapForUnit("player") == 11 or C_Map.GetBestMapForUnit("player") == 57 or C_Map.GetBestMapForUnit("player") == 62 
      or C_Map.GetBestMapForUnit("player") == 63 or C_Map.GetBestMapForUnit("player") == 64 or C_Map.GetBestMapForUnit("player") == 65 or C_Map.GetBestMapForUnit("player") == 66 or C_Map.GetBestMapForUnit("player") == 67 or C_Map.GetBestMapForUnit("player") == 68 
      or C_Map.GetBestMapForUnit("player") == 69 or C_Map.GetBestMapForUnit("player") == 70 or C_Map.GetBestMapForUnit("player") == 71 or C_Map.GetBestMapForUnit("player") == 74 or C_Map.GetBestMapForUnit("player") == 75 or C_Map.GetBestMapForUnit("player") == 76 
      or C_Map.GetBestMapForUnit("player") == 77 or C_Map.GetBestMapForUnit("player") == 78 or C_Map.GetBestMapForUnit("player") == 80 or C_Map.GetBestMapForUnit("player") == 81 or C_Map.GetBestMapForUnit("player") == 83 or C_Map.GetBestMapForUnit("player") == 97 
      or C_Map.GetBestMapForUnit("player") == 106 or C_Map.GetBestMapForUnit("player") == 199 or C_Map.GetBestMapForUnit("player") == 327 or C_Map.GetBestMapForUnit("player") == 460 or C_Map.GetBestMapForUnit("player") == 461 or C_Map.GetBestMapForUnit("player") == 462 
      or C_Map.GetBestMapForUnit("player") == 468 or C_Map.GetBestMapForUnit("player") == 1527 or C_Map.GetBestMapForUnit("player") == 198 or C_Map.GetBestMapForUnit("player") == 249)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Eastern Kingdom
    elseif (C_Map.GetBestMapForUnit("player") == 13 or C_Map.GetBestMapForUnit("player") == 14 or C_Map.GetBestMapForUnit("player") == 15 or C_Map.GetBestMapForUnit("player") == 16 or C_Map.GetBestMapForUnit("player") == 17 or C_Map.GetBestMapForUnit("player") == 18 
      or C_Map.GetBestMapForUnit("player") == 19 or C_Map.GetBestMapForUnit("player") == 21 or C_Map.GetBestMapForUnit("player") == 22 or C_Map.GetBestMapForUnit("player") == 23 or C_Map.GetBestMapForUnit("player") == 25 or C_Map.GetBestMapForUnit("player") == 26 
      or C_Map.GetBestMapForUnit("player") == 27 or C_Map.GetBestMapForUnit("player") == 28 or C_Map.GetBestMapForUnit("player") == 30 or C_Map.GetBestMapForUnit("player") == 32 or C_Map.GetBestMapForUnit("player") == 33 or C_Map.GetBestMapForUnit("player") == 34 
      or C_Map.GetBestMapForUnit("player") == 35 or C_Map.GetBestMapForUnit("player") == 36 or C_Map.GetBestMapForUnit("player") == 37 or C_Map.GetBestMapForUnit("player") == 42 or C_Map.GetBestMapForUnit("player") == 47 or C_Map.GetBestMapForUnit("player") == 48 
      or C_Map.GetBestMapForUnit("player") == 49 or C_Map.GetBestMapForUnit("player") == 50 or C_Map.GetBestMapForUnit("player") == 51 or C_Map.GetBestMapForUnit("player") == 52 or C_Map.GetBestMapForUnit("player") == 55 or C_Map.GetBestMapForUnit("player") == 56 
      or C_Map.GetBestMapForUnit("player") == 94 or C_Map.GetBestMapForUnit("player") == 210 or C_Map.GetBestMapForUnit("player") == 224 or C_Map.GetBestMapForUnit("player") == 245 or C_Map.GetBestMapForUnit("player") == 425 or C_Map.GetBestMapForUnit("player") == 427 
      or C_Map.GetBestMapForUnit("player") == 465 or C_Map.GetBestMapForUnit("player") == 467 or C_Map.GetBestMapForUnit("player") == 469 or C_Map.GetBestMapForUnit("player") == 499 or C_Map.GetBestMapForUnit("player") == 500 or C_Map.GetBestMapForUnit("player") == 2070 
      or C_Map.GetBestMapForUnit("player") == 241 or C_Map.GetBestMapForUnit("player") == 203 or C_Map.GetBestMapForUnit("player") == 204 or C_Map.GetBestMapForUnit("player") == 205 or C_Map.GetBestMapForUnit("player") == 241 or C_Map.GetBestMapForUnit("player") == 244 
      or C_Map.GetBestMapForUnit("player") == 245 or C_Map.GetBestMapForUnit("player") == 201 or C_Map.GetBestMapForUnit("player") == 95 or C_Map.GetBestMapForUnit("player") == 122 or C_Map.GetBestMapForUnit("player") == 217  or C_Map.GetBestMapForUnit("player") == 226)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Outland
    elseif (C_Map.GetBestMapForUnit("player") == 100 or C_Map.GetBestMapForUnit("player") == 102 or C_Map.GetBestMapForUnit("player") == 104 or C_Map.GetBestMapForUnit("player") == 105 or C_Map.GetBestMapForUnit("player") == 107 or C_Map.GetBestMapForUnit("player") == 108
      or C_Map.GetBestMapForUnit("player") == 109)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Northrend
    elseif (C_Map.GetBestMapForUnit("player") == 114 or C_Map.GetBestMapForUnit("player") == 115 or C_Map.GetBestMapForUnit("player") == 116 or C_Map.GetBestMapForUnit("player") == 117 or C_Map.GetBestMapForUnit("player") == 118 or C_Map.GetBestMapForUnit("player") == 119
      or C_Map.GetBestMapForUnit("player") == 120 or C_Map.GetBestMapForUnit("player") == 121 or C_Map.GetBestMapForUnit("player") == 123 or C_Map.GetBestMapForUnit("player") == 127 or C_Map.GetBestMapForUnit("player") == 170)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Pandaria
    elseif (C_Map.GetBestMapForUnit("player") == 371 or C_Map.GetBestMapForUnit("player") == 376 or C_Map.GetBestMapForUnit("player") == 379 or C_Map.GetBestMapForUnit("player") == 388 or C_Map.GetBestMapForUnit("player") == 390 or C_Map.GetBestMapForUnit("player") == 418
      or C_Map.GetBestMapForUnit("player") == 422 or C_Map.GetBestMapForUnit("player") == 433 or C_Map.GetBestMapForUnit("player") == 434 or C_Map.GetBestMapForUnit("player") == 504 or C_Map.GetBestMapForUnit("player") == 554  or C_Map.GetBestMapForUnit("player") == 1530
      or C_Map.GetBestMapForUnit("player") == 507)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Draenor
    elseif (C_Map.GetBestMapForUnit("player") == 525 or C_Map.GetBestMapForUnit("player") == 534 or C_Map.GetBestMapForUnit("player") == 535 or C_Map.GetBestMapForUnit("player") == 539 or C_Map.GetBestMapForUnit("player") == 542 or C_Map.GetBestMapForUnit("player") == 543
      or C_Map.GetBestMapForUnit("player") == 550 or C_Map.GetBestMapForUnit("player") == 588)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Broken Isles
    elseif (C_Map.GetBestMapForUnit("player") == 630 or C_Map.GetBestMapForUnit("player") == 634 or C_Map.GetBestMapForUnit("player") == 641 or C_Map.GetBestMapForUnit("player") == 646 or C_Map.GetBestMapForUnit("player") == 650 or C_Map.GetBestMapForUnit("player") == 652
      or C_Map.GetBestMapForUnit("player") == 750 or C_Map.GetBestMapForUnit("player") == 680 or C_Map.GetBestMapForUnit("player") == 830 or C_Map.GetBestMapForUnit("player") == 882 or C_Map.GetBestMapForUnit("player") == 885 or C_Map.GetBestMapForUnit("player") == 905
      or C_Map.GetBestMapForUnit("player") == 941 or C_Map.GetBestMapForUnit("player") == 790 or C_Map.GetBestMapForUnit("player") == 971)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Zandalar
    elseif (C_Map.GetBestMapForUnit("player") == 862 or C_Map.GetBestMapForUnit("player") == 863 or C_Map.GetBestMapForUnit("player") == 864 or C_Map.GetBestMapForUnit("player") == 1355 or C_Map.GetBestMapForUnit("player") == 1528)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Kul Tiras
    elseif (C_Map.GetBestMapForUnit("player") == 895 or C_Map.GetBestMapForUnit("player") == 896 or C_Map.GetBestMapForUnit("player") == 942 or C_Map.GetBestMapForUnit("player") == 1462 or C_Map.GetBestMapForUnit("player") == 1169)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Shadowlands
    elseif (C_Map.GetBestMapForUnit("player") == 1525 or C_Map.GetBestMapForUnit("player") == 1533 or C_Map.GetBestMapForUnit("player") == 1536 or C_Map.GetBestMapForUnit("player") == 1543 or C_Map.GetBestMapForUnit("player") == 1565 or C_Map.GetBestMapForUnit("player") == 1961
      or C_Map.GetBestMapForUnit("player") == 1970 or C_Map.GetBestMapForUnit("player") == 2016)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Dragon Isles
    elseif (C_Map.GetBestMapForUnit("player") == 2022 or C_Map.GetBestMapForUnit("player") == 2023 or C_Map.GetBestMapForUnit("player") == 2024 or C_Map.GetBestMapForUnit("player") == 2025 or C_Map.GetBestMapForUnit("player") == 2026 or C_Map.GetBestMapForUnit("player") == 2133
      or C_Map.GetBestMapForUnit("player") == 2151 or C_Map.GetBestMapForUnit("player") == 2200 or C_Map.GetBestMapForUnit("player") == 2239)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Dragon Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Khaz Algar
    elseif (C_Map.GetBestMapForUnit("player") == 2248 or C_Map.GetBestMapForUnit("player") == 2214 or C_Map.GetBestMapForUnit("player") == 2215 or C_Map.GetBestMapForUnit("player") or C_Map.GetBestMapForUnit("player") == 2213 or C_Map.GetBestMapForUnit("player") == 2216)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Khaz Algar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    end
  end

  -- Capital without Synch function
  if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap 
    and (C_Map.GetBestMapForUnit("player") == 1454 or C_Map.GetBestMapForUnit("player") == 1456 --Cata nodes
    or C_Map.GetBestMapForUnit("player") == 2266 -- Millenia's Threshold
    or C_Map.GetBestMapForUnit("player") == 84 or C_Map.GetBestMapForUnit("player") == 87 or C_Map.GetBestMapForUnit("player") == 89 or C_Map.GetBestMapForUnit("player") == 103 or C_Map.GetBestMapForUnit("player") == 85
    or C_Map.GetBestMapForUnit("player") == 90 or C_Map.GetBestMapForUnit("player") == 86 or C_Map.GetBestMapForUnit("player") == 88 or C_Map.GetBestMapForUnit("player") == 110 or C_Map.GetBestMapForUnit("player") == 111
    or C_Map.GetBestMapForUnit("player") == 125 or C_Map.GetBestMapForUnit("player") == 126 or C_Map.GetBestMapForUnit("player") == 391 or C_Map.GetBestMapForUnit("player") == 392 or C_Map.GetBestMapForUnit("player") == 393 
    or C_Map.GetBestMapForUnit("player") == 394 or C_Map.GetBestMapForUnit("player") == 582 or C_Map.GetBestMapForUnit("player") == 590 or C_Map.GetBestMapForUnit("player") == 622 or C_Map.GetBestMapForUnit("player") == 624 
    or C_Map.GetBestMapForUnit("player") == 626 or C_Map.GetBestMapForUnit("player") == 627 or C_Map.GetBestMapForUnit("player") == 628 or C_Map.GetBestMapForUnit("player") == 629 or C_Map.GetBestMapForUnit("player") == 1161
    or C_Map.GetBestMapForUnit("player") == 1163 or C_Map.GetBestMapForUnit("player") == 1164 or C_Map.GetBestMapForUnit("player") == 1165 or C_Map.GetBestMapForUnit("player") == 1670 or C_Map.GetBestMapForUnit("player") == 1671 
    or C_Map.GetBestMapForUnit("player") == 1672 or C_Map.GetBestMapForUnit("player") == 1673 or C_Map.GetBestMapForUnit("player") == 2112 or C_Map.GetBestMapForUnit("player") == 407 or C_Map.GetBestMapForUnit("player") == 2339
    or C_Map.GetBestMapForUnit("player") == 499 or C_Map.GetBestMapForUnit("player") == 500) 
  then
    tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Capitals"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
    tooltip:Show()
  end

  -- Capital Synch function
  if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap 
    and (C_Map.GetBestMapForUnit("player") == 1454 or C_Map.GetBestMapForUnit("player") == 1456 --Cata nodes
    or C_Map.GetBestMapForUnit("player") == 2266 -- Millenia's Threshold
    or C_Map.GetBestMapForUnit("player") == 84 or C_Map.GetBestMapForUnit("player") == 87 or C_Map.GetBestMapForUnit("player") == 89 or C_Map.GetBestMapForUnit("player") == 103 or C_Map.GetBestMapForUnit("player") == 85
    or C_Map.GetBestMapForUnit("player") == 90 or C_Map.GetBestMapForUnit("player") == 86 or C_Map.GetBestMapForUnit("player") == 88 or C_Map.GetBestMapForUnit("player") == 110 or C_Map.GetBestMapForUnit("player") == 111
    or C_Map.GetBestMapForUnit("player") == 125 or C_Map.GetBestMapForUnit("player") == 126 or C_Map.GetBestMapForUnit("player") == 391 or C_Map.GetBestMapForUnit("player") == 392 or C_Map.GetBestMapForUnit("player") == 393 
    or C_Map.GetBestMapForUnit("player") == 394 or C_Map.GetBestMapForUnit("player") == 582 or C_Map.GetBestMapForUnit("player") == 590 or C_Map.GetBestMapForUnit("player") == 622 or C_Map.GetBestMapForUnit("player") == 624 
    or C_Map.GetBestMapForUnit("player") == 626 or C_Map.GetBestMapForUnit("player") == 627 or C_Map.GetBestMapForUnit("player") == 628 or C_Map.GetBestMapForUnit("player") == 629 or C_Map.GetBestMapForUnit("player") == 1161
    or C_Map.GetBestMapForUnit("player") == 1163 or C_Map.GetBestMapForUnit("player") == 1164 or C_Map.GetBestMapForUnit("player") == 1165 or C_Map.GetBestMapForUnit("player") == 1670 or C_Map.GetBestMapForUnit("player") == 1671 
    or C_Map.GetBestMapForUnit("player") == 1672 or C_Map.GetBestMapForUnit("player") == 1673 or C_Map.GetBestMapForUnit("player") == 2112 or C_Map.GetBestMapForUnit("player") == 407 or C_Map.GetBestMapForUnit("player") == 2339
    or C_Map.GetBestMapForUnit("player") == 499 or C_Map.GetBestMapForUnit("player") == 500) 
  then
    tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Capitals"] .. " & " .. L["Capitals"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
    tooltip:Show()
  end

  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end,

OnClick = function(self, button)
local info = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"))

  if button == "RightButton" and not IsShiftKeyDown() then
    -- Zone without Sync function
    if not ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6) 
      and not (C_Map.GetBestMapForUnit("player") == 1454 or C_Map.GetBestMapForUnit("player") == 1456 --Cata nodes
      or C_Map.GetBestMapForUnit("player") == 84 or C_Map.GetBestMapForUnit("player") == 87 or C_Map.GetBestMapForUnit("player") == 89 or C_Map.GetBestMapForUnit("player") == 103 or C_Map.GetBestMapForUnit("player") == 85
      or C_Map.GetBestMapForUnit("player") == 90 or C_Map.GetBestMapForUnit("player") == 86 or C_Map.GetBestMapForUnit("player") == 88 or C_Map.GetBestMapForUnit("player") == 110 or C_Map.GetBestMapForUnit("player") == 111
      or C_Map.GetBestMapForUnit("player") == 125 or C_Map.GetBestMapForUnit("player") == 126 or C_Map.GetBestMapForUnit("player") == 391 or C_Map.GetBestMapForUnit("player") == 392 or C_Map.GetBestMapForUnit("player") == 393 
      or C_Map.GetBestMapForUnit("player") == 394 or C_Map.GetBestMapForUnit("player") == 582 or C_Map.GetBestMapForUnit("player") == 590 or C_Map.GetBestMapForUnit("player") == 622 or C_Map.GetBestMapForUnit("player") == 624 
      or C_Map.GetBestMapForUnit("player") == 626 or C_Map.GetBestMapForUnit("player") == 627 or C_Map.GetBestMapForUnit("player") == 628 or C_Map.GetBestMapForUnit("player") == 629 or C_Map.GetBestMapForUnit("player") == 1161
      or C_Map.GetBestMapForUnit("player") == 1163 or C_Map.GetBestMapForUnit("player") == 1164 or C_Map.GetBestMapForUnit("player") == 1165 or C_Map.GetBestMapForUnit("player") == 1670 or C_Map.GetBestMapForUnit("player") == 1671 
      or C_Map.GetBestMapForUnit("player") == 1672 or C_Map.GetBestMapForUnit("player") == 1673 or C_Map.GetBestMapForUnit("player") == 2112 or C_Map.GetBestMapForUnit("player") == 407 or C_Map.GetBestMapForUnit("player") == 2339
      or C_Map.GetBestMapForUnit("player") == 499 or C_Map.GetBestMapForUnit("player") == 500)
    then
      --Kalimdor
      if (C_Map.GetBestMapForUnit("player") == 1 or C_Map.GetBestMapForUnit("player") == 7 or C_Map.GetBestMapForUnit("player") == 10 or C_Map.GetBestMapForUnit("player") == 11 or C_Map.GetBestMapForUnit("player") == 57 or C_Map.GetBestMapForUnit("player") == 62 
        or C_Map.GetBestMapForUnit("player") == 63 or C_Map.GetBestMapForUnit("player") == 64 or C_Map.GetBestMapForUnit("player") == 65 or C_Map.GetBestMapForUnit("player") == 66 or C_Map.GetBestMapForUnit("player") == 67 or C_Map.GetBestMapForUnit("player") == 68 
        or C_Map.GetBestMapForUnit("player") == 69 or C_Map.GetBestMapForUnit("player") == 70 or C_Map.GetBestMapForUnit("player") == 71 or C_Map.GetBestMapForUnit("player") == 74 or C_Map.GetBestMapForUnit("player") == 75 or C_Map.GetBestMapForUnit("player") == 76 
        or C_Map.GetBestMapForUnit("player") == 77 or C_Map.GetBestMapForUnit("player") == 78 or C_Map.GetBestMapForUnit("player") == 80 or C_Map.GetBestMapForUnit("player") == 81 or C_Map.GetBestMapForUnit("player") == 83 or C_Map.GetBestMapForUnit("player") == 97 
        or C_Map.GetBestMapForUnit("player") == 106 or C_Map.GetBestMapForUnit("player") == 199 or C_Map.GetBestMapForUnit("player") == 327 or C_Map.GetBestMapForUnit("player") == 460 or C_Map.GetBestMapForUnit("player") == 461 or C_Map.GetBestMapForUnit("player") == 462 
        or C_Map.GetBestMapForUnit("player") == 468 or C_Map.GetBestMapForUnit("player") == 1527 or C_Map.GetBestMapForUnit("player") == 198 or C_Map.GetBestMapForUnit("player") == 249)
      then
        if not ns.Addon.db.profile.showMiniMapKalimdor then
          ns.Addon.db.profile.showMiniMapKalimdor = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kalimdor"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showMiniMapKalimdor = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kalimdor"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Eastern Kingdom
      elseif (C_Map.GetBestMapForUnit("player") == 13 or C_Map.GetBestMapForUnit("player") == 14 or C_Map.GetBestMapForUnit("player") == 15 or C_Map.GetBestMapForUnit("player") == 16 or C_Map.GetBestMapForUnit("player") == 17 or C_Map.GetBestMapForUnit("player") == 18 
        or C_Map.GetBestMapForUnit("player") == 19 or C_Map.GetBestMapForUnit("player") == 21 or C_Map.GetBestMapForUnit("player") == 22 or C_Map.GetBestMapForUnit("player") == 23 or C_Map.GetBestMapForUnit("player") == 25 or C_Map.GetBestMapForUnit("player") == 26 
        or C_Map.GetBestMapForUnit("player") == 27 or C_Map.GetBestMapForUnit("player") == 28 or C_Map.GetBestMapForUnit("player") == 30 or C_Map.GetBestMapForUnit("player") == 32 or C_Map.GetBestMapForUnit("player") == 33 or C_Map.GetBestMapForUnit("player") == 34 
        or C_Map.GetBestMapForUnit("player") == 35 or C_Map.GetBestMapForUnit("player") == 36 or C_Map.GetBestMapForUnit("player") == 37 or C_Map.GetBestMapForUnit("player") == 42 or C_Map.GetBestMapForUnit("player") == 47 or C_Map.GetBestMapForUnit("player") == 48 
        or C_Map.GetBestMapForUnit("player") == 49 or C_Map.GetBestMapForUnit("player") == 50 or C_Map.GetBestMapForUnit("player") == 51 or C_Map.GetBestMapForUnit("player") == 52 or C_Map.GetBestMapForUnit("player") == 55 or C_Map.GetBestMapForUnit("player") == 56 
        or C_Map.GetBestMapForUnit("player") == 94 or C_Map.GetBestMapForUnit("player") == 210 or C_Map.GetBestMapForUnit("player") == 224 or C_Map.GetBestMapForUnit("player") == 245 or C_Map.GetBestMapForUnit("player") == 425 or C_Map.GetBestMapForUnit("player") == 427 
        or C_Map.GetBestMapForUnit("player") == 465 or C_Map.GetBestMapForUnit("player") == 467 or C_Map.GetBestMapForUnit("player") == 469 or C_Map.GetBestMapForUnit("player") == 499 or C_Map.GetBestMapForUnit("player") == 500 or C_Map.GetBestMapForUnit("player") == 2070 
        or C_Map.GetBestMapForUnit("player") == 241 or C_Map.GetBestMapForUnit("player") == 203 or C_Map.GetBestMapForUnit("player") == 204 or C_Map.GetBestMapForUnit("player") == 205 or C_Map.GetBestMapForUnit("player") == 241 or C_Map.GetBestMapForUnit("player") == 244 
        or C_Map.GetBestMapForUnit("player") == 245 or C_Map.GetBestMapForUnit("player") == 201 or C_Map.GetBestMapForUnit("player") == 95 or C_Map.GetBestMapForUnit("player") == 122 or C_Map.GetBestMapForUnit("player") == 217  or C_Map.GetBestMapForUnit("player") == 226)
      then
        if not ns.Addon.db.profile.showMiniMapEasternKingdom then
          ns.Addon.db.profile.showMiniMapEasternKingdom = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Eastern Kingdom"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showMiniMapEasternKingdom = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Eastern Kingdom"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Outland
      elseif (C_Map.GetBestMapForUnit("player") == 100 or C_Map.GetBestMapForUnit("player") == 102 or C_Map.GetBestMapForUnit("player") == 104 or C_Map.GetBestMapForUnit("player") == 105 or C_Map.GetBestMapForUnit("player") == 107 or C_Map.GetBestMapForUnit("player") == 108
        or C_Map.GetBestMapForUnit("player") == 109)
      then
        if not ns.Addon.db.profile.showMiniMapOutland then
          ns.Addon.db.profile.showMiniMapOutland = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Outland"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showMiniMapOutland = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Outland"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Northrend
      elseif (C_Map.GetBestMapForUnit("player") == 114 or C_Map.GetBestMapForUnit("player") == 115 or C_Map.GetBestMapForUnit("player") == 116 or C_Map.GetBestMapForUnit("player") == 117 or C_Map.GetBestMapForUnit("player") == 118 or C_Map.GetBestMapForUnit("player") == 119
        or C_Map.GetBestMapForUnit("player") == 120 or C_Map.GetBestMapForUnit("player") == 121 or C_Map.GetBestMapForUnit("player") == 123 or C_Map.GetBestMapForUnit("player") == 127 or C_Map.GetBestMapForUnit("player") == 170)
      then
        if not ns.Addon.db.profile.showMiniMapNorthrend then
          ns.Addon.db.profile.showMiniMapNorthrend = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Northrend"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showMiniMapNorthrend = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Northrend"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Pandaria
      elseif (C_Map.GetBestMapForUnit("player") == 371 or C_Map.GetBestMapForUnit("player") == 376 or C_Map.GetBestMapForUnit("player") == 379 or C_Map.GetBestMapForUnit("player") == 388 or C_Map.GetBestMapForUnit("player") == 390 or C_Map.GetBestMapForUnit("player") == 418
        or C_Map.GetBestMapForUnit("player") == 422 or C_Map.GetBestMapForUnit("player") == 433 or C_Map.GetBestMapForUnit("player") == 434 or C_Map.GetBestMapForUnit("player") == 504 or C_Map.GetBestMapForUnit("player") == 554  or C_Map.GetBestMapForUnit("player") == 1530
        or C_Map.GetBestMapForUnit("player") == 507)
      then
        if not ns.Addon.db.profile.showMiniMapPandaria then
          ns.Addon.db.profile.showMiniMapPandaria = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Pandaria"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showMiniMapPandaria = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Pandaria"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Draenor
      elseif (C_Map.GetBestMapForUnit("player") == 525 or C_Map.GetBestMapForUnit("player") == 534 or C_Map.GetBestMapForUnit("player") == 535 or C_Map.GetBestMapForUnit("player") == 539 or C_Map.GetBestMapForUnit("player") == 542 or C_Map.GetBestMapForUnit("player") == 543
        or C_Map.GetBestMapForUnit("player") == 550 or C_Map.GetBestMapForUnit("player") == 588)
      then
        if not ns.Addon.db.profile.showMiniMapDraenor then
          ns.Addon.db.profile.showMiniMapDraenor = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Draenor"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showMiniMapDraenor = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Draenor"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Broken Isles
      elseif (C_Map.GetBestMapForUnit("player") == 630 or C_Map.GetBestMapForUnit("player") == 634 or C_Map.GetBestMapForUnit("player") == 641 or C_Map.GetBestMapForUnit("player") == 646 or C_Map.GetBestMapForUnit("player") == 650 or C_Map.GetBestMapForUnit("player") == 652
        or C_Map.GetBestMapForUnit("player") == 750 or C_Map.GetBestMapForUnit("player") == 680 or C_Map.GetBestMapForUnit("player") == 830 or C_Map.GetBestMapForUnit("player") == 882 or C_Map.GetBestMapForUnit("player") == 885 or C_Map.GetBestMapForUnit("player") == 905
        or C_Map.GetBestMapForUnit("player") == 941 or C_Map.GetBestMapForUnit("player") == 790 or C_Map.GetBestMapForUnit("player") == 971)
      then
        if not ns.Addon.db.profile.showMiniMapBrokenIsles then
          ns.Addon.db.profile.showMiniMapBrokenIsles = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Broken Isles"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showMiniMapBrokenIsles = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Broken Isles"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Zandalar
      elseif (C_Map.GetBestMapForUnit("player") == 862 or C_Map.GetBestMapForUnit("player") == 863 or C_Map.GetBestMapForUnit("player") == 864 or C_Map.GetBestMapForUnit("player") == 1355 or C_Map.GetBestMapForUnit("player") == 1528)
      then
        if not ns.Addon.db.profile.showMiniMapZandalar then
          ns.Addon.db.profile.showMiniMapZandalar = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zandalar"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showMiniMapZandalar = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zandalar"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Kul Tiras
      elseif (C_Map.GetBestMapForUnit("player") == 895 or C_Map.GetBestMapForUnit("player") == 896 or C_Map.GetBestMapForUnit("player") == 942 or C_Map.GetBestMapForUnit("player") == 1462 or C_Map.GetBestMapForUnit("player") == 1169)
      then
        if not ns.Addon.db.profile.showMiniMapKulTiras then
          ns.Addon.db.profile.showMiniMapKulTiras = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kul Tiras"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showMiniMapKulTiras = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kul Tiras"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Shadowlands
      elseif (C_Map.GetBestMapForUnit("player") == 1525 or C_Map.GetBestMapForUnit("player") == 1533 or C_Map.GetBestMapForUnit("player") == 1536 or C_Map.GetBestMapForUnit("player") == 1543 or C_Map.GetBestMapForUnit("player") == 1565 or C_Map.GetBestMapForUnit("player") == 1961
        or C_Map.GetBestMapForUnit("player") == 1970 or C_Map.GetBestMapForUnit("player") == 2016)
      then
        if not ns.Addon.db.profile.showMiniMapShadowlands then
          ns.Addon.db.profile.showMiniMapShadowlands = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Shadowlands"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showMiniMapShadowlands = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Shadowlands"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Dragon Isles
      elseif (C_Map.GetBestMapForUnit("player") == 2022 or C_Map.GetBestMapForUnit("player") == 2023 or C_Map.GetBestMapForUnit("player") == 2024 or C_Map.GetBestMapForUnit("player") == 2025 or C_Map.GetBestMapForUnit("player") == 2026 or C_Map.GetBestMapForUnit("player") == 2133
        or C_Map.GetBestMapForUnit("player") == 2151 or C_Map.GetBestMapForUnit("player") == 2200 or C_Map.GetBestMapForUnit("player") == 2239)
      then
        if not ns.Addon.db.profile.showMiniMapDragonIsles then
          ns.Addon.db.profile.showMiniMapDragonIsles = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dragon Isles"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showMiniMapDragonIsles = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dragon Isles"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Khaz Algar
      elseif (C_Map.GetBestMapForUnit("player") == 2248 or C_Map.GetBestMapForUnit("player") == 2214 or C_Map.GetBestMapForUnit("player") == 2215 or C_Map.GetBestMapForUnit("player") == 2255 or C_Map.GetBestMapForUnit("player") == 2256 or C_Map.GetBestMapForUnit("player") == 2213 or C_Map.GetBestMapForUnit("player") == 2216)
      then
        if not ns.Addon.db.profile.showMiniMapKhazAlgar then
          ns.Addon.db.profile.showMiniMapKhazAlgar = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dragon Isles"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showMiniMapKhazAlgar = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dragon Isles"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      end
    end

    -- Zone Sync function
    if ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6) 
      and not (C_Map.GetBestMapForUnit("player") == 1454 or C_Map.GetBestMapForUnit("player") == 1456 --Cata nodes
      or C_Map.GetBestMapForUnit("player") == 2266 -- Millenia's Threshold
      or C_Map.GetBestMapForUnit("player") == 84 or C_Map.GetBestMapForUnit("player") == 87 or C_Map.GetBestMapForUnit("player") == 89 or C_Map.GetBestMapForUnit("player") == 103 or C_Map.GetBestMapForUnit("player") == 85
      or C_Map.GetBestMapForUnit("player") == 90 or C_Map.GetBestMapForUnit("player") == 86 or C_Map.GetBestMapForUnit("player") == 88 or C_Map.GetBestMapForUnit("player") == 110 or C_Map.GetBestMapForUnit("player") == 111
      or C_Map.GetBestMapForUnit("player") == 125 or C_Map.GetBestMapForUnit("player") == 126 or C_Map.GetBestMapForUnit("player") == 391 or C_Map.GetBestMapForUnit("player") == 392 or C_Map.GetBestMapForUnit("player") == 393 
      or C_Map.GetBestMapForUnit("player") == 394 or C_Map.GetBestMapForUnit("player") == 582 or C_Map.GetBestMapForUnit("player") == 590 or C_Map.GetBestMapForUnit("player") == 622 or C_Map.GetBestMapForUnit("player") == 624 
      or C_Map.GetBestMapForUnit("player") == 626 or C_Map.GetBestMapForUnit("player") == 627 or C_Map.GetBestMapForUnit("player") == 628 or C_Map.GetBestMapForUnit("player") == 629 or C_Map.GetBestMapForUnit("player") == 1161
      or C_Map.GetBestMapForUnit("player") == 1163 or C_Map.GetBestMapForUnit("player") == 1164 or C_Map.GetBestMapForUnit("player") == 1165 or C_Map.GetBestMapForUnit("player") == 1670 or C_Map.GetBestMapForUnit("player") == 1671 
      or C_Map.GetBestMapForUnit("player") == 1672 or C_Map.GetBestMapForUnit("player") == 1673 or C_Map.GetBestMapForUnit("player") == 2112 or C_Map.GetBestMapForUnit("player") == 407 or C_Map.GetBestMapForUnit("player") == 2339
      or C_Map.GetBestMapForUnit("player") == 499 or C_Map.GetBestMapForUnit("player") == 500)
    then
      --Kalimdor
      if (C_Map.GetBestMapForUnit("player") == 1 or C_Map.GetBestMapForUnit("player") == 7 or C_Map.GetBestMapForUnit("player") == 10 or C_Map.GetBestMapForUnit("player") == 11 or C_Map.GetBestMapForUnit("player") == 57 or C_Map.GetBestMapForUnit("player") == 62 
        or C_Map.GetBestMapForUnit("player") == 63 or C_Map.GetBestMapForUnit("player") == 64 or C_Map.GetBestMapForUnit("player") == 65 or C_Map.GetBestMapForUnit("player") == 66 or C_Map.GetBestMapForUnit("player") == 67 or C_Map.GetBestMapForUnit("player") == 68 
        or C_Map.GetBestMapForUnit("player") == 69 or C_Map.GetBestMapForUnit("player") == 70 or C_Map.GetBestMapForUnit("player") == 71 or C_Map.GetBestMapForUnit("player") == 74 or C_Map.GetBestMapForUnit("player") == 75 or C_Map.GetBestMapForUnit("player") == 76 
        or C_Map.GetBestMapForUnit("player") == 77 or C_Map.GetBestMapForUnit("player") == 78 or C_Map.GetBestMapForUnit("player") == 80 or C_Map.GetBestMapForUnit("player") == 81 or C_Map.GetBestMapForUnit("player") == 83 or C_Map.GetBestMapForUnit("player") == 97 
        or C_Map.GetBestMapForUnit("player") == 106 or C_Map.GetBestMapForUnit("player") == 199 or C_Map.GetBestMapForUnit("player") == 327 or C_Map.GetBestMapForUnit("player") == 460 or C_Map.GetBestMapForUnit("player") == 461 or C_Map.GetBestMapForUnit("player") == 462 
        or C_Map.GetBestMapForUnit("player") == 468 or C_Map.GetBestMapForUnit("player") == 1527 or C_Map.GetBestMapForUnit("player") == 198 or C_Map.GetBestMapForUnit("player") == 249)
      then
        if not ns.Addon.db.profile.showZoneKalimdor then
          ns.Addon.db.profile.showZoneKalimdor = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showZoneKalimdor = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Eastern Kingdom
      elseif (C_Map.GetBestMapForUnit("player") == 13 or C_Map.GetBestMapForUnit("player") == 14 or C_Map.GetBestMapForUnit("player") == 15 or C_Map.GetBestMapForUnit("player") == 16 or C_Map.GetBestMapForUnit("player") == 17 or C_Map.GetBestMapForUnit("player") == 18 
        or C_Map.GetBestMapForUnit("player") == 19 or C_Map.GetBestMapForUnit("player") == 21 or C_Map.GetBestMapForUnit("player") == 22 or C_Map.GetBestMapForUnit("player") == 23 or C_Map.GetBestMapForUnit("player") == 25 or C_Map.GetBestMapForUnit("player") == 26 
        or C_Map.GetBestMapForUnit("player") == 27 or C_Map.GetBestMapForUnit("player") == 28 or C_Map.GetBestMapForUnit("player") == 30 or C_Map.GetBestMapForUnit("player") == 32 or C_Map.GetBestMapForUnit("player") == 33 or C_Map.GetBestMapForUnit("player") == 34 
        or C_Map.GetBestMapForUnit("player") == 35 or C_Map.GetBestMapForUnit("player") == 36 or C_Map.GetBestMapForUnit("player") == 37 or C_Map.GetBestMapForUnit("player") == 42 or C_Map.GetBestMapForUnit("player") == 47 or C_Map.GetBestMapForUnit("player") == 48 
        or C_Map.GetBestMapForUnit("player") == 49 or C_Map.GetBestMapForUnit("player") == 50 or C_Map.GetBestMapForUnit("player") == 51 or C_Map.GetBestMapForUnit("player") == 52 or C_Map.GetBestMapForUnit("player") == 55 or C_Map.GetBestMapForUnit("player") == 56 
        or C_Map.GetBestMapForUnit("player") == 94 or C_Map.GetBestMapForUnit("player") == 210 or C_Map.GetBestMapForUnit("player") == 224 or C_Map.GetBestMapForUnit("player") == 245 or C_Map.GetBestMapForUnit("player") == 425 or C_Map.GetBestMapForUnit("player") == 427 
        or C_Map.GetBestMapForUnit("player") == 465 or C_Map.GetBestMapForUnit("player") == 467 or C_Map.GetBestMapForUnit("player") == 469 or C_Map.GetBestMapForUnit("player") == 499 or C_Map.GetBestMapForUnit("player") == 500 or C_Map.GetBestMapForUnit("player") == 2070 
        or C_Map.GetBestMapForUnit("player") == 241 or C_Map.GetBestMapForUnit("player") == 203 or C_Map.GetBestMapForUnit("player") == 204 or C_Map.GetBestMapForUnit("player") == 205 or C_Map.GetBestMapForUnit("player") == 241 or C_Map.GetBestMapForUnit("player") == 244 
        or C_Map.GetBestMapForUnit("player") == 245 or C_Map.GetBestMapForUnit("player") == 201 or C_Map.GetBestMapForUnit("player") == 95 or C_Map.GetBestMapForUnit("player") == 122 or C_Map.GetBestMapForUnit("player") == 217  or C_Map.GetBestMapForUnit("player") == 226)
      then
        if not ns.Addon.db.profile.showZoneEasternKingdom then
          ns.Addon.db.profile.showZoneEasternKingdom = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showZoneEasternKingdom = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Outland
      elseif (C_Map.GetBestMapForUnit("player") == 100 or C_Map.GetBestMapForUnit("player") == 102 or C_Map.GetBestMapForUnit("player") == 104 or C_Map.GetBestMapForUnit("player") == 105 or C_Map.GetBestMapForUnit("player") == 107 or C_Map.GetBestMapForUnit("player") == 108
        or C_Map.GetBestMapForUnit("player") == 109)
      then
        if not ns.Addon.db.profile.showZoneOutland then
          ns.Addon.db.profile.showZoneOutland = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showZoneOutland = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Northrend
      elseif (C_Map.GetBestMapForUnit("player") == 114 or C_Map.GetBestMapForUnit("player") == 115 or C_Map.GetBestMapForUnit("player") == 116 or C_Map.GetBestMapForUnit("player") == 117 or C_Map.GetBestMapForUnit("player") == 118 or C_Map.GetBestMapForUnit("player") == 119
        or C_Map.GetBestMapForUnit("player") == 120 or C_Map.GetBestMapForUnit("player") == 121 or C_Map.GetBestMapForUnit("player") == 123 or C_Map.GetBestMapForUnit("player") == 127 or C_Map.GetBestMapForUnit("player") == 170)
      then
        if not ns.Addon.db.profile.showZoneNorthrend then
          ns.Addon.db.profile.showZoneNorthrend = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showZoneNorthrend = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Pandaria
      elseif (C_Map.GetBestMapForUnit("player") == 371 or C_Map.GetBestMapForUnit("player") == 376 or C_Map.GetBestMapForUnit("player") == 379 or C_Map.GetBestMapForUnit("player") == 388 or C_Map.GetBestMapForUnit("player") == 390 or C_Map.GetBestMapForUnit("player") == 418
        or C_Map.GetBestMapForUnit("player") == 422 or C_Map.GetBestMapForUnit("player") == 433 or C_Map.GetBestMapForUnit("player") == 434 or C_Map.GetBestMapForUnit("player") == 504 or C_Map.GetBestMapForUnit("player") == 554  or C_Map.GetBestMapForUnit("player") == 1530
        or C_Map.GetBestMapForUnit("player") == 507)
      then
        if not ns.Addon.db.profile.showZonePandaria then
          ns.Addon.db.profile.showZonePandaria = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showZonePandaria = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Draenor
      elseif (C_Map.GetBestMapForUnit("player") == 525 or C_Map.GetBestMapForUnit("player") == 534 or C_Map.GetBestMapForUnit("player") == 535 or C_Map.GetBestMapForUnit("player") == 539 or C_Map.GetBestMapForUnit("player") == 542 or C_Map.GetBestMapForUnit("player") == 543
        or C_Map.GetBestMapForUnit("player") == 550 or C_Map.GetBestMapForUnit("player") == 588)
      then
        if not ns.Addon.db.profile.showZoneDraenor then
          ns.Addon.db.profile.showZoneDraenor = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showZoneDraenor = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Broken Isles
      elseif (C_Map.GetBestMapForUnit("player") == 630 or C_Map.GetBestMapForUnit("player") == 634 or C_Map.GetBestMapForUnit("player") == 641 or C_Map.GetBestMapForUnit("player") == 646 or C_Map.GetBestMapForUnit("player") == 650 or C_Map.GetBestMapForUnit("player") == 652
        or C_Map.GetBestMapForUnit("player") == 750 or C_Map.GetBestMapForUnit("player") == 680 or C_Map.GetBestMapForUnit("player") == 830 or C_Map.GetBestMapForUnit("player") == 882 or C_Map.GetBestMapForUnit("player") == 885 or C_Map.GetBestMapForUnit("player") == 905
        or C_Map.GetBestMapForUnit("player") == 941 or C_Map.GetBestMapForUnit("player") == 790 or C_Map.GetBestMapForUnit("player") == 971)
      then
        if not ns.Addon.db.profile.showZoneBrokenIsles then
          ns.Addon.db.profile.showZoneBrokenIsles = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showZoneBrokenIsles = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Zandalar
      elseif (C_Map.GetBestMapForUnit("player") == 862 or C_Map.GetBestMapForUnit("player") == 863 or C_Map.GetBestMapForUnit("player") == 864 or C_Map.GetBestMapForUnit("player") == 1355 or C_Map.GetBestMapForUnit("player") == 1528)
      then
        if not ns.Addon.db.profile.showZoneZandalar then
          ns.Addon.db.profile.showZoneZandalar = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showZoneZandalar = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Kul Tiras
      elseif (C_Map.GetBestMapForUnit("player") == 895 or C_Map.GetBestMapForUnit("player") == 896 or C_Map.GetBestMapForUnit("player") == 942 or C_Map.GetBestMapForUnit("player") == 1462 or C_Map.GetBestMapForUnit("player") == 1169)
      then
        if not ns.Addon.db.profile.showZoneKulTiras then
          ns.Addon.db.profile.showZoneKulTiras = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showZoneKulTiras = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Shadowlands
      elseif (C_Map.GetBestMapForUnit("player") == 1525 or C_Map.GetBestMapForUnit("player") == 1533 or C_Map.GetBestMapForUnit("player") == 1536 or C_Map.GetBestMapForUnit("player") == 1543 or C_Map.GetBestMapForUnit("player") == 1565 or C_Map.GetBestMapForUnit("player") == 1961
        or C_Map.GetBestMapForUnit("player") == 1970 or C_Map.GetBestMapForUnit("player") == 2016)
      then
        if not ns.Addon.db.profile.showZoneShadowlands then
          ns.Addon.db.profile.showZoneShadowlands = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showZoneShadowlands = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      --Dragon Isles
      elseif (C_Map.GetBestMapForUnit("player") == 2022 or C_Map.GetBestMapForUnit("player") == 2023 or C_Map.GetBestMapForUnit("player") == 2024 or C_Map.GetBestMapForUnit("player") == 2025 or C_Map.GetBestMapForUnit("player") == 2026 or C_Map.GetBestMapForUnit("player") == 2133
        or C_Map.GetBestMapForUnit("player") == 2151 or C_Map.GetBestMapForUnit("player") == 2200 or C_Map.GetBestMapForUnit("player") == 2239)
      then
        if not ns.Addon.db.profile.showZoneDragonIsles then
          ns.Addon.db.profile.showZoneDragonIsles = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Dragon Isles"]  .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showZoneDragonIsles = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Dragon Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
       --Khaz Algar
      elseif (C_Map.GetBestMapForUnit("player") == 2248 or C_Map.GetBestMapForUnit("player") == 2214 or C_Map.GetBestMapForUnit("player") == 2215 or C_Map.GetBestMapForUnit("player") == 2255 or C_Map.GetBestMapForUnit("player") == 2256 or C_Map.GetBestMapForUnit("player") == 2213 or C_Map.GetBestMapForUnit("player") == 2216)
      then
        if not ns.Addon.db.profile.showZoneKhazAlgar then
          ns.Addon.db.profile.showZoneKhazAlgar = true
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Khaz Algar"]  .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
        else
          ns.Addon.db.profile.showZoneKhazAlgar = false
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Khaz Algar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
        end
      end
    end

    -- CapitalsMinimap without Sync function
    if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap
      and (C_Map.GetBestMapForUnit("player") == 1454 or C_Map.GetBestMapForUnit("player") == 1456 --Cata nodes
      or C_Map.GetBestMapForUnit("player") == 2266 -- Millenia's Threshold
      or C_Map.GetBestMapForUnit("player") == 84 or C_Map.GetBestMapForUnit("player") == 87 or C_Map.GetBestMapForUnit("player") == 89 or C_Map.GetBestMapForUnit("player") == 103 or C_Map.GetBestMapForUnit("player") == 85
      or C_Map.GetBestMapForUnit("player") == 90 or C_Map.GetBestMapForUnit("player") == 86 or C_Map.GetBestMapForUnit("player") == 88 or C_Map.GetBestMapForUnit("player") == 110 or C_Map.GetBestMapForUnit("player") == 111
      or C_Map.GetBestMapForUnit("player") == 125 or C_Map.GetBestMapForUnit("player") == 126 or C_Map.GetBestMapForUnit("player") == 391 or C_Map.GetBestMapForUnit("player") == 392 or C_Map.GetBestMapForUnit("player") == 393 
      or C_Map.GetBestMapForUnit("player") == 394 or C_Map.GetBestMapForUnit("player") == 582 or C_Map.GetBestMapForUnit("player") == 590 or C_Map.GetBestMapForUnit("player") == 622 or C_Map.GetBestMapForUnit("player") == 624 
      or C_Map.GetBestMapForUnit("player") == 626 or C_Map.GetBestMapForUnit("player") == 627 or C_Map.GetBestMapForUnit("player") == 628 or C_Map.GetBestMapForUnit("player") == 629 or C_Map.GetBestMapForUnit("player") == 1161
      or C_Map.GetBestMapForUnit("player") == 1163 or C_Map.GetBestMapForUnit("player") == 1164 or C_Map.GetBestMapForUnit("player") == 1165 or C_Map.GetBestMapForUnit("player") == 1670 or C_Map.GetBestMapForUnit("player") == 1671 
      or C_Map.GetBestMapForUnit("player") == 1672 or C_Map.GetBestMapForUnit("player") == 1673 or C_Map.GetBestMapForUnit("player") == 2112 or C_Map.GetBestMapForUnit("player") == 407 or C_Map.GetBestMapForUnit("player") == 2339
      or C_Map.GetBestMapForUnit("player") == 499 or C_Map.GetBestMapForUnit("player") == 500) 
    then
      if not ns.Addon.db.profile.activate.MinimapCapitals then
        ns.Addon.db.profile.activate.MinimapCapitals = true
        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, L["Capitals"], L["icons"], "|cff00ff00" .. L["are shown"])
      else
        ns.Addon.db.profile.activate.MinimapCapitals = false
        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, L["Capitals"], L["icons"], "|cffff0000" .. L["are hidden"])
      end
    end

    -- Capital Synch function
    if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap
      and (C_Map.GetBestMapForUnit("player") == 1454 or C_Map.GetBestMapForUnit("player") == 1456 --Cata nodes
      or C_Map.GetBestMapForUnit("player") == 2266 -- Millenia's Threshold
      or C_Map.GetBestMapForUnit("player") == 84 or C_Map.GetBestMapForUnit("player") == 87 or C_Map.GetBestMapForUnit("player") == 89 or C_Map.GetBestMapForUnit("player") == 103 or C_Map.GetBestMapForUnit("player") == 85
      or C_Map.GetBestMapForUnit("player") == 90 or C_Map.GetBestMapForUnit("player") == 86 or C_Map.GetBestMapForUnit("player") == 88 or C_Map.GetBestMapForUnit("player") == 110 or C_Map.GetBestMapForUnit("player") == 111
      or C_Map.GetBestMapForUnit("player") == 125 or C_Map.GetBestMapForUnit("player") == 126 or C_Map.GetBestMapForUnit("player") == 391 or C_Map.GetBestMapForUnit("player") == 392 or C_Map.GetBestMapForUnit("player") == 393 
      or C_Map.GetBestMapForUnit("player") == 394 or C_Map.GetBestMapForUnit("player") == 582 or C_Map.GetBestMapForUnit("player") == 590 or C_Map.GetBestMapForUnit("player") == 622 or C_Map.GetBestMapForUnit("player") == 624 
      or C_Map.GetBestMapForUnit("player") == 626 or C_Map.GetBestMapForUnit("player") == 627 or C_Map.GetBestMapForUnit("player") == 628 or C_Map.GetBestMapForUnit("player") == 629 or C_Map.GetBestMapForUnit("player") == 1161
      or C_Map.GetBestMapForUnit("player") == 1163 or C_Map.GetBestMapForUnit("player") == 1164 or C_Map.GetBestMapForUnit("player") == 1165 or C_Map.GetBestMapForUnit("player") == 1670 or C_Map.GetBestMapForUnit("player") == 1671 
      or C_Map.GetBestMapForUnit("player") == 1672 or C_Map.GetBestMapForUnit("player") == 1673 or C_Map.GetBestMapForUnit("player") == 2112 or C_Map.GetBestMapForUnit("player") == 407 or C_Map.GetBestMapForUnit("player") == 2339
      or C_Map.GetBestMapForUnit("player") == 499 or C_Map.GetBestMapForUnit("player") == 500) 
    then
      if not ns.Addon.db.profile.activate.Capitals then
        ns.Addon.db.profile.activate.Capitals = true
        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
      else
        ns.Addon.db.profile.activate.Capitals = false
        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
      end
    end

  end

  -- hide MiniMapButton
  if IsShiftKeyDown() and button == "RightButton" then
    MNMMBIcon:Hide("MNMiniMapButton")
    ns.Addon.db.profile.activate.HideMMB = true
    LibStub("AceConfigDialog-3.0"):Close("HandyNotes") 
    print(ns.COLORED_ADDON_NAME .. "|cffffff00 " .. L["-> MiniMapButton <-"], "|cffff0000" .. L["are hidden"]) 
    print(ns.COLORED_ADDON_NAME .. "|cffffff00 " .. L["to show minimap button: /mnb or /MNB"])
    print(ns.COLORED_ADDON_NAME .. "|cffffff00 ".. L["to open MapNotes menu: /mno, /MNO"])
  end

  -- open/close MapNotes menu
  if button == "LeftButton" then
    if not LibStub("AceConfigDialog-3.0"):Close("MapNotes") then
      LibStub("AceConfigDialog-3.0"):Open("MapNotes")
      LibStub("AceConfigDialog-3.0"):Close("HandyNotes")
    end
  end

  -- open/close Worldmap
  if button == "MiddleButton" then
    if WorldMapFrame:IsShown() then
      ToggleWorldMap()
      WorldMapFrame:Hide()
    else 
      ToggleWorldMap()
      WorldMapFrame:Show()
    end
  end

  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end }