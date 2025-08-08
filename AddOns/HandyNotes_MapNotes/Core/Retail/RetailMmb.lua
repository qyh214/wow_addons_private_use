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
local GetBestMapForUnit = C_Map.GetBestMapForUnit("player")

  if not tooltip or not tooltip.AddLine then return end
    tooltip:AddLine(ns.COLORED_ADDON_NAME)
    tooltip:AddLine(" ")
    tooltip:AddLine(L["Left-click => Open/Close"] .. " " .. ns.COLORED_ADDON_NAME,1,1,1)
    tooltip:AddLine(L["Shift + Right-click => hide"] .. " " .. "|cffffff00" .. L["-> MiniMapButton <-"],1,1,1)
    tooltip:AddLine(L["Middle-Mouse-Button => Open/Close"] .. " " .. "|cff00ccff" .. "-> " .. WORLDMAP_BUTTON .." <-",1,1,1)



  -- Zone without Sync function
  if not ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 4 or info.mapType == 5 or info.mapType == 6)
    and not (GetBestMapForUnit == 1454 or GetBestMapForUnit == 1456 --Cata nodes
    or GetBestMapForUnit == 2266 -- Millenia's Threshold
    or GetBestMapForUnit == 84 or GetBestMapForUnit == 87 or GetBestMapForUnit == 89 or GetBestMapForUnit == 103 or GetBestMapForUnit == 85
    or GetBestMapForUnit == 90 or GetBestMapForUnit == 86 or GetBestMapForUnit == 88 or GetBestMapForUnit == 110 or GetBestMapForUnit == 111
    or GetBestMapForUnit == 125 or GetBestMapForUnit == 126 or GetBestMapForUnit == 391 or GetBestMapForUnit == 392 or GetBestMapForUnit == 393 
    or GetBestMapForUnit == 394 or GetBestMapForUnit == 582 or GetBestMapForUnit == 590 or GetBestMapForUnit == 622 or GetBestMapForUnit == 624 
    or GetBestMapForUnit == 626 or GetBestMapForUnit == 627 or GetBestMapForUnit == 628 or GetBestMapForUnit == 629 or GetBestMapForUnit == 831 or GetBestMapForUnit == 832
    or GetBestMapForUnit == 1161 or GetBestMapForUnit == 1163 or GetBestMapForUnit == 1164 or GetBestMapForUnit == 1165 or GetBestMapForUnit == 1670 
    or GetBestMapForUnit == 1671 or GetBestMapForUnit == 1672 or GetBestMapForUnit == 1673 or GetBestMapForUnit == 2112 or GetBestMapForUnit == 407 
    or GetBestMapForUnit == 2339 or GetBestMapForUnit == 499 or GetBestMapForUnit == 500)
  then
    --Kalimdor
    if (GetBestMapForUnit == 1 or GetBestMapForUnit == 7 or GetBestMapForUnit == 10 or GetBestMapForUnit == 11 or GetBestMapForUnit == 57 or GetBestMapForUnit == 62 
      or GetBestMapForUnit == 63 or GetBestMapForUnit == 64 or GetBestMapForUnit == 65 or GetBestMapForUnit == 66 or GetBestMapForUnit == 67 or GetBestMapForUnit == 68 
      or GetBestMapForUnit == 69 or GetBestMapForUnit == 70 or GetBestMapForUnit == 71 or GetBestMapForUnit == 74 or GetBestMapForUnit == 75 or GetBestMapForUnit == 76 
      or GetBestMapForUnit == 77 or GetBestMapForUnit == 78 or GetBestMapForUnit == 80 or GetBestMapForUnit == 81 or GetBestMapForUnit == 83 or GetBestMapForUnit == 97 
      or GetBestMapForUnit == 106 or GetBestMapForUnit == 199 or GetBestMapForUnit == 327 or GetBestMapForUnit == 460 or GetBestMapForUnit == 461 or GetBestMapForUnit == 462 
      or GetBestMapForUnit == 468 or GetBestMapForUnit == 1527 or GetBestMapForUnit == 198 or GetBestMapForUnit == 249)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kalimdor"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Eastern Kingdom
    elseif (GetBestMapForUnit == 13 or GetBestMapForUnit == 14 or GetBestMapForUnit == 15 or GetBestMapForUnit == 16 or GetBestMapForUnit == 17 or GetBestMapForUnit == 18 
      or GetBestMapForUnit == 19 or GetBestMapForUnit == 21 or GetBestMapForUnit == 22 or GetBestMapForUnit == 23 or GetBestMapForUnit == 25 or GetBestMapForUnit == 26 
      or GetBestMapForUnit == 27 or GetBestMapForUnit == 28 or GetBestMapForUnit == 30 or GetBestMapForUnit == 32 or GetBestMapForUnit == 33 or GetBestMapForUnit == 34 
      or GetBestMapForUnit == 35 or GetBestMapForUnit == 36 or GetBestMapForUnit == 37 or GetBestMapForUnit == 42 or GetBestMapForUnit == 47 or GetBestMapForUnit == 48 
      or GetBestMapForUnit == 49 or GetBestMapForUnit == 50 or GetBestMapForUnit == 51 or GetBestMapForUnit == 52 or GetBestMapForUnit == 55 or GetBestMapForUnit == 56 
      or GetBestMapForUnit == 94 or GetBestMapForUnit == 210 or GetBestMapForUnit == 224 or GetBestMapForUnit == 245 or GetBestMapForUnit == 425 or GetBestMapForUnit == 427 
      or GetBestMapForUnit == 465 or GetBestMapForUnit == 467 or GetBestMapForUnit == 469 or GetBestMapForUnit == 2070 
      or GetBestMapForUnit == 241 or GetBestMapForUnit == 203 or GetBestMapForUnit == 204 or GetBestMapForUnit == 205 or GetBestMapForUnit == 241 or GetBestMapForUnit == 244 
      or GetBestMapForUnit == 245 or GetBestMapForUnit == 201 or GetBestMapForUnit == 95 or GetBestMapForUnit == 122 or GetBestMapForUnit == 217  or GetBestMapForUnit == 226)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Eastern Kingdom"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Outland
    elseif (GetBestMapForUnit == 100 or GetBestMapForUnit == 102 or GetBestMapForUnit == 104 or GetBestMapForUnit == 105 or GetBestMapForUnit == 107 or GetBestMapForUnit == 108
      or GetBestMapForUnit == 109)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Outland"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Northrend
    elseif (GetBestMapForUnit == 114 or GetBestMapForUnit == 115 or GetBestMapForUnit == 116 or GetBestMapForUnit == 117 or GetBestMapForUnit == 118 or GetBestMapForUnit == 119
      or GetBestMapForUnit == 120 or GetBestMapForUnit == 121 or GetBestMapForUnit == 123 or GetBestMapForUnit == 127 or GetBestMapForUnit == 170)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Northrend"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Pandaria
    elseif (GetBestMapForUnit == 371 or GetBestMapForUnit == 376 or GetBestMapForUnit == 379 or GetBestMapForUnit == 388 or GetBestMapForUnit == 390 or GetBestMapForUnit == 418
      or GetBestMapForUnit == 422 or GetBestMapForUnit == 433 or GetBestMapForUnit == 434 or GetBestMapForUnit == 504 or GetBestMapForUnit == 554  or GetBestMapForUnit == 1530
      or GetBestMapForUnit == 507)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Pandaria"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Draenor
    elseif (GetBestMapForUnit == 525 or GetBestMapForUnit == 534 or GetBestMapForUnit == 535 or GetBestMapForUnit == 539 or GetBestMapForUnit == 542 or GetBestMapForUnit == 543
      or GetBestMapForUnit == 550 or GetBestMapForUnit == 588)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Draenor"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Broken Isles
    elseif (GetBestMapForUnit == 630 or GetBestMapForUnit == 634 or GetBestMapForUnit == 641 or GetBestMapForUnit == 646 or GetBestMapForUnit == 650 or GetBestMapForUnit == 652
      or GetBestMapForUnit == 750 or GetBestMapForUnit == 680 or GetBestMapForUnit == 830 or GetBestMapForUnit == 882 or GetBestMapForUnit == 885 or GetBestMapForUnit == 905
      or GetBestMapForUnit == 941 or GetBestMapForUnit == 790 or GetBestMapForUnit == 971)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Broken Isles"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Zandalar
    elseif (GetBestMapForUnit == 862 or GetBestMapForUnit == 863 or GetBestMapForUnit == 864 or GetBestMapForUnit == 1355 or GetBestMapForUnit == 1528)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Zandalar"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Kul Tiras
    elseif (GetBestMapForUnit == 895 or GetBestMapForUnit == 896 or GetBestMapForUnit == 942 or GetBestMapForUnit == 1462 or GetBestMapForUnit == 1169)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kul Tiras"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Shadowlands
    elseif (GetBestMapForUnit == 1525 or GetBestMapForUnit == 1533 or GetBestMapForUnit == 1536 or GetBestMapForUnit == 1543 or GetBestMapForUnit == 1565 or GetBestMapForUnit == 1961
      or GetBestMapForUnit == 1970 or GetBestMapForUnit == 2016)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Shadowlands"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Dragon Isles
    elseif (GetBestMapForUnit == 2022 or GetBestMapForUnit == 2023 or GetBestMapForUnit == 2024 or GetBestMapForUnit == 2025 or GetBestMapForUnit == 2026 or GetBestMapForUnit == 2133
      or GetBestMapForUnit == 2151 or GetBestMapForUnit == 2200 or GetBestMapForUnit == 2239)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Dragon Isles"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Khaz Algar
    elseif (GetBestMapForUnit == 2248 or GetBestMapForUnit == 2214 or GetBestMapForUnit == 2215 or GetBestMapForUnit == 2255 or GetBestMapForUnit == 2256 or GetBestMapForUnit == 2213 
      or GetBestMapForUnit == 2216 or GetBestMapForUnit == 2369 or GetBestMapForUnit == 2322 or GetBestMapForUnit == 2346 or GetBestMapForUnit == 2371 or GetBestMapForUnit == 2472)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Khaz Algar"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    end
  end

  -- Zone Sync function
  if ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6)
    and not (GetBestMapForUnit == 1454 or GetBestMapForUnit == 1456 --Cata nodes
    or GetBestMapForUnit == 2266 -- Millenia's Threshold
    or GetBestMapForUnit == 84 or GetBestMapForUnit == 87 or GetBestMapForUnit == 89 or GetBestMapForUnit == 103 or GetBestMapForUnit == 85
    or GetBestMapForUnit == 90 or GetBestMapForUnit == 86 or GetBestMapForUnit == 88 or GetBestMapForUnit == 110 or GetBestMapForUnit == 111
    or GetBestMapForUnit == 125 or GetBestMapForUnit == 126 or GetBestMapForUnit == 391 or GetBestMapForUnit == 392 or GetBestMapForUnit == 393 
    or GetBestMapForUnit == 394 or GetBestMapForUnit == 582 or GetBestMapForUnit == 590 or GetBestMapForUnit == 622 or GetBestMapForUnit == 624 
    or GetBestMapForUnit == 626 or GetBestMapForUnit == 627 or GetBestMapForUnit == 628 or GetBestMapForUnit == 629 or GetBestMapForUnit == 831 or GetBestMapForUnit == 832
    or GetBestMapForUnit == 1161 or GetBestMapForUnit == 1163 or GetBestMapForUnit == 1164 or GetBestMapForUnit == 1165 or GetBestMapForUnit == 1670 
    or GetBestMapForUnit == 1671 or GetBestMapForUnit == 1672 or GetBestMapForUnit == 1673 or GetBestMapForUnit == 2112 or GetBestMapForUnit == 407 
    or GetBestMapForUnit == 2339 or GetBestMapForUnit == 499 or GetBestMapForUnit == 500)
  then
    --Kalimdor
    if (GetBestMapForUnit == 1 or GetBestMapForUnit == 7 or GetBestMapForUnit == 10 or GetBestMapForUnit == 11 or GetBestMapForUnit == 57 or GetBestMapForUnit == 62 
      or GetBestMapForUnit == 63 or GetBestMapForUnit == 64 or GetBestMapForUnit == 65 or GetBestMapForUnit == 66 or GetBestMapForUnit == 67 or GetBestMapForUnit == 68 
      or GetBestMapForUnit == 69 or GetBestMapForUnit == 70 or GetBestMapForUnit == 71 or GetBestMapForUnit == 74 or GetBestMapForUnit == 75 or GetBestMapForUnit == 76 
      or GetBestMapForUnit == 77 or GetBestMapForUnit == 78 or GetBestMapForUnit == 80 or GetBestMapForUnit == 81 or GetBestMapForUnit == 83 or GetBestMapForUnit == 97 
      or GetBestMapForUnit == 106 or GetBestMapForUnit == 199 or GetBestMapForUnit == 327 or GetBestMapForUnit == 460 or GetBestMapForUnit == 461 or GetBestMapForUnit == 462 
      or GetBestMapForUnit == 468 or GetBestMapForUnit == 1527 or GetBestMapForUnit == 198 or GetBestMapForUnit == 249)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Eastern Kingdom
    elseif (GetBestMapForUnit == 13 or GetBestMapForUnit == 14 or GetBestMapForUnit == 15 or GetBestMapForUnit == 16 or GetBestMapForUnit == 17 or GetBestMapForUnit == 18 
      or GetBestMapForUnit == 19 or GetBestMapForUnit == 21 or GetBestMapForUnit == 22 or GetBestMapForUnit == 23 or GetBestMapForUnit == 25 or GetBestMapForUnit == 26 
      or GetBestMapForUnit == 27 or GetBestMapForUnit == 28 or GetBestMapForUnit == 30 or GetBestMapForUnit == 32 or GetBestMapForUnit == 33 or GetBestMapForUnit == 34 
      or GetBestMapForUnit == 35 or GetBestMapForUnit == 36 or GetBestMapForUnit == 37 or GetBestMapForUnit == 42 or GetBestMapForUnit == 47 or GetBestMapForUnit == 48 
      or GetBestMapForUnit == 49 or GetBestMapForUnit == 50 or GetBestMapForUnit == 51 or GetBestMapForUnit == 52 or GetBestMapForUnit == 55 or GetBestMapForUnit == 56 
      or GetBestMapForUnit == 94 or GetBestMapForUnit == 210 or GetBestMapForUnit == 224 or GetBestMapForUnit == 245 or GetBestMapForUnit == 425 or GetBestMapForUnit == 427 
      or GetBestMapForUnit == 465 or GetBestMapForUnit == 467 or GetBestMapForUnit == 469 or GetBestMapForUnit == 2070 
      or GetBestMapForUnit == 241 or GetBestMapForUnit == 203 or GetBestMapForUnit == 204 or GetBestMapForUnit == 205 or GetBestMapForUnit == 241 or GetBestMapForUnit == 244 
      or GetBestMapForUnit == 245 or GetBestMapForUnit == 201 or GetBestMapForUnit == 95 or GetBestMapForUnit == 122 or GetBestMapForUnit == 217  or GetBestMapForUnit == 226)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Outland
    elseif (GetBestMapForUnit == 100 or GetBestMapForUnit == 102 or GetBestMapForUnit == 104 or GetBestMapForUnit == 105 or GetBestMapForUnit == 107 or GetBestMapForUnit == 108
      or GetBestMapForUnit == 109)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Northrend
    elseif (GetBestMapForUnit == 114 or GetBestMapForUnit == 115 or GetBestMapForUnit == 116 or GetBestMapForUnit == 117 or GetBestMapForUnit == 118 or GetBestMapForUnit == 119
      or GetBestMapForUnit == 120 or GetBestMapForUnit == 121 or GetBestMapForUnit == 123 or GetBestMapForUnit == 127 or GetBestMapForUnit == 170)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Pandaria
    elseif (GetBestMapForUnit == 371 or GetBestMapForUnit == 376 or GetBestMapForUnit == 379 or GetBestMapForUnit == 388 or GetBestMapForUnit == 390 or GetBestMapForUnit == 418
      or GetBestMapForUnit == 422 or GetBestMapForUnit == 433 or GetBestMapForUnit == 434 or GetBestMapForUnit == 504 or GetBestMapForUnit == 554  or GetBestMapForUnit == 1530
      or GetBestMapForUnit == 507)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Draenor
    elseif (GetBestMapForUnit == 525 or GetBestMapForUnit == 534 or GetBestMapForUnit == 535 or GetBestMapForUnit == 539 or GetBestMapForUnit == 542 or GetBestMapForUnit == 543
      or GetBestMapForUnit == 550 or GetBestMapForUnit == 588)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Broken Isles
    elseif (GetBestMapForUnit == 630 or GetBestMapForUnit == 634 or GetBestMapForUnit == 641 or GetBestMapForUnit == 646 or GetBestMapForUnit == 650 or GetBestMapForUnit == 652
      or GetBestMapForUnit == 750 or GetBestMapForUnit == 680 or GetBestMapForUnit == 830 or GetBestMapForUnit == 882 or GetBestMapForUnit == 885 or GetBestMapForUnit == 905
      or GetBestMapForUnit == 941 or GetBestMapForUnit == 790 or GetBestMapForUnit == 971)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Zandalar
    elseif (GetBestMapForUnit == 862 or GetBestMapForUnit == 863 or GetBestMapForUnit == 864 or GetBestMapForUnit == 1355 or GetBestMapForUnit == 1528)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Kul Tiras
    elseif (GetBestMapForUnit == 895 or GetBestMapForUnit == 896 or GetBestMapForUnit == 942 or GetBestMapForUnit == 1462 or GetBestMapForUnit == 1169)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Shadowlands
    elseif (GetBestMapForUnit == 1525 or GetBestMapForUnit == 1533 or GetBestMapForUnit == 1536 or GetBestMapForUnit == 1543 or GetBestMapForUnit == 1565 or GetBestMapForUnit == 1961
      or GetBestMapForUnit == 1970 or GetBestMapForUnit == 2016)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Dragon Isles
    elseif (GetBestMapForUnit == 2022 or GetBestMapForUnit == 2023 or GetBestMapForUnit == 2024 or GetBestMapForUnit == 2025 or GetBestMapForUnit == 2026 or GetBestMapForUnit == 2133
      or GetBestMapForUnit == 2151 or GetBestMapForUnit == 2200 or GetBestMapForUnit == 2239)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Dragon Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Khaz Algar
    elseif (GetBestMapForUnit == 2248 or GetBestMapForUnit == 2214 or GetBestMapForUnit == 2215 or C_Map.GetBestMapForUnit("player") or GetBestMapForUnit == 2213 or GetBestMapForUnit == 2216
      or GetBestMapForUnit == 2369 or GetBestMapForUnit == 2322 or GetBestMapForUnit == 2346)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Khaz Algar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    end
  end

  -- Capital without Synch function
  if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap 
    and (GetBestMapForUnit == 1454 or GetBestMapForUnit == 1456 --Cata nodes
    or GetBestMapForUnit == 2266 -- Millenia's Threshold
    or GetBestMapForUnit == 84 or GetBestMapForUnit == 87 or GetBestMapForUnit == 89 or GetBestMapForUnit == 103 or GetBestMapForUnit == 85
    or GetBestMapForUnit == 90 or GetBestMapForUnit == 86 or GetBestMapForUnit == 88 or GetBestMapForUnit == 110 or GetBestMapForUnit == 111
    or GetBestMapForUnit == 125 or GetBestMapForUnit == 126 or GetBestMapForUnit == 391 or GetBestMapForUnit == 392 or GetBestMapForUnit == 393 
    or GetBestMapForUnit == 394 or GetBestMapForUnit == 582 or GetBestMapForUnit == 590 or GetBestMapForUnit == 622 or GetBestMapForUnit == 624 
    or GetBestMapForUnit == 626 or GetBestMapForUnit == 627 or GetBestMapForUnit == 628 or GetBestMapForUnit == 629 or GetBestMapForUnit == 831 or GetBestMapForUnit == 832
    or GetBestMapForUnit == 1161 or GetBestMapForUnit == 1163 or GetBestMapForUnit == 1164 or GetBestMapForUnit == 1165 or GetBestMapForUnit == 1670 
    or GetBestMapForUnit == 1671 or GetBestMapForUnit == 1672 or GetBestMapForUnit == 1673 or GetBestMapForUnit == 2112 or GetBestMapForUnit == 407 
    or GetBestMapForUnit == 2339 or GetBestMapForUnit == 499 or GetBestMapForUnit == 500)
  then
    tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Capitals"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
    tooltip:Show()
  end

  -- Capital Synch function
  if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap 
    and (GetBestMapForUnit == 1454 or GetBestMapForUnit == 1456 --Cata nodes
    or GetBestMapForUnit == 2266 -- Millenia's Threshold
    or GetBestMapForUnit == 84 or GetBestMapForUnit == 87 or GetBestMapForUnit == 89 or GetBestMapForUnit == 103 or GetBestMapForUnit == 85
    or GetBestMapForUnit == 90 or GetBestMapForUnit == 86 or GetBestMapForUnit == 88 or GetBestMapForUnit == 110 or GetBestMapForUnit == 111
    or GetBestMapForUnit == 125 or GetBestMapForUnit == 126 or GetBestMapForUnit == 391 or GetBestMapForUnit == 392 or GetBestMapForUnit == 393 
    or GetBestMapForUnit == 394 or GetBestMapForUnit == 582 or GetBestMapForUnit == 590 or GetBestMapForUnit == 622 or GetBestMapForUnit == 624 
    or GetBestMapForUnit == 626 or GetBestMapForUnit == 627 or GetBestMapForUnit == 628 or GetBestMapForUnit == 629 or GetBestMapForUnit == 831 or GetBestMapForUnit == 832
    or GetBestMapForUnit == 1161 or GetBestMapForUnit == 1163 or GetBestMapForUnit == 1164 or GetBestMapForUnit == 1165 or GetBestMapForUnit == 1670 
    or GetBestMapForUnit == 1671 or GetBestMapForUnit == 1672 or GetBestMapForUnit == 1673 or GetBestMapForUnit == 2112 or GetBestMapForUnit == 407 
    or GetBestMapForUnit == 2339 or GetBestMapForUnit == 499 or GetBestMapForUnit == 500)
  then
    tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Capitals"] .. " & " .. L["Capitals"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
    tooltip:Show()
  end

  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end,

OnClick = function(self, button)
local info = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"))
local GetBestMapForUnit = C_Map.GetBestMapForUnit("player")

  if button == "RightButton" and not IsShiftKeyDown() then

    -- Zone without Sync function
    if not ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 4 or info.mapType == 5 or info.mapType == 6) 
      and not (GetBestMapForUnit == 1454 or GetBestMapForUnit == 1456 --Cata nodes
      or GetBestMapForUnit == 84 or GetBestMapForUnit == 87 or GetBestMapForUnit == 89 or GetBestMapForUnit == 103 or GetBestMapForUnit == 85
      or GetBestMapForUnit == 90 or GetBestMapForUnit == 86 or GetBestMapForUnit == 88 or GetBestMapForUnit == 110 or GetBestMapForUnit == 111
      or GetBestMapForUnit == 125 or GetBestMapForUnit == 126 or GetBestMapForUnit == 391 or GetBestMapForUnit == 392 or GetBestMapForUnit == 393 
      or GetBestMapForUnit == 394 or GetBestMapForUnit == 582 or GetBestMapForUnit == 590 or GetBestMapForUnit == 622 or GetBestMapForUnit == 624 
      or GetBestMapForUnit == 626 or GetBestMapForUnit == 627 or GetBestMapForUnit == 628 or GetBestMapForUnit == 629 or GetBestMapForUnit == 831 or GetBestMapForUnit == 832
      or GetBestMapForUnit == 1161 or GetBestMapForUnit == 1163 or GetBestMapForUnit == 1164 or GetBestMapForUnit == 1165 or GetBestMapForUnit == 1670 
      or GetBestMapForUnit == 1671 or GetBestMapForUnit == 1672 or GetBestMapForUnit == 1673 or GetBestMapForUnit == 2112 or GetBestMapForUnit == 407 
      or GetBestMapForUnit == 2339 or GetBestMapForUnit == 499 or GetBestMapForUnit == 500)
    then
      --Kalimdor
      if (GetBestMapForUnit == 1 or GetBestMapForUnit == 7 or GetBestMapForUnit == 10 or GetBestMapForUnit == 11 or GetBestMapForUnit == 57 or GetBestMapForUnit == 62 
        or GetBestMapForUnit == 63 or GetBestMapForUnit == 64 or GetBestMapForUnit == 65 or GetBestMapForUnit == 66 or GetBestMapForUnit == 67 or GetBestMapForUnit == 68 
        or GetBestMapForUnit == 69 or GetBestMapForUnit == 70 or GetBestMapForUnit == 71 or GetBestMapForUnit == 74 or GetBestMapForUnit == 75 or GetBestMapForUnit == 76 
        or GetBestMapForUnit == 77 or GetBestMapForUnit == 78 or GetBestMapForUnit == 80 or GetBestMapForUnit == 81 or GetBestMapForUnit == 83 or GetBestMapForUnit == 97 
        or GetBestMapForUnit == 106 or GetBestMapForUnit == 199 or GetBestMapForUnit == 327 or GetBestMapForUnit == 460 or GetBestMapForUnit == 461 or GetBestMapForUnit == 462 
        or GetBestMapForUnit == 468 or GetBestMapForUnit == 1527 or GetBestMapForUnit == 198 or GetBestMapForUnit == 249)
      then
        if not ns.Addon.db.profile.showMiniMapKalimdor then
          ns.Addon.db.profile.showMiniMapKalimdor = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kalimdor"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showMiniMapKalimdor = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kalimdor"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Eastern Kingdom
      elseif (GetBestMapForUnit == 13 or GetBestMapForUnit == 14 or GetBestMapForUnit == 15 or GetBestMapForUnit == 16 or GetBestMapForUnit == 17 or GetBestMapForUnit == 18 
        or GetBestMapForUnit == 19 or GetBestMapForUnit == 21 or GetBestMapForUnit == 22 or GetBestMapForUnit == 23 or GetBestMapForUnit == 25 or GetBestMapForUnit == 26 
        or GetBestMapForUnit == 27 or GetBestMapForUnit == 28 or GetBestMapForUnit == 30 or GetBestMapForUnit == 32 or GetBestMapForUnit == 33 or GetBestMapForUnit == 34 
        or GetBestMapForUnit == 35 or GetBestMapForUnit == 36 or GetBestMapForUnit == 37 or GetBestMapForUnit == 42 or GetBestMapForUnit == 47 or GetBestMapForUnit == 48 
        or GetBestMapForUnit == 49 or GetBestMapForUnit == 50 or GetBestMapForUnit == 51 or GetBestMapForUnit == 52 or GetBestMapForUnit == 55 or GetBestMapForUnit == 56 
        or GetBestMapForUnit == 94 or GetBestMapForUnit == 210 or GetBestMapForUnit == 224 or GetBestMapForUnit == 245 or GetBestMapForUnit == 425 or GetBestMapForUnit == 427 
        or GetBestMapForUnit == 465 or GetBestMapForUnit == 467 or GetBestMapForUnit == 469 or GetBestMapForUnit == 2070 
        or GetBestMapForUnit == 241 or GetBestMapForUnit == 203 or GetBestMapForUnit == 204 or GetBestMapForUnit == 205 or GetBestMapForUnit == 241 or GetBestMapForUnit == 244 
        or GetBestMapForUnit == 245 or GetBestMapForUnit == 201 or GetBestMapForUnit == 95 or GetBestMapForUnit == 122 or GetBestMapForUnit == 217  or GetBestMapForUnit == 226)
      then
        if not ns.Addon.db.profile.showMiniMapEasternKingdom then
          ns.Addon.db.profile.showMiniMapEasternKingdom = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Eastern Kingdom"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showMiniMapEasternKingdom = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Eastern Kingdom"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Outland
      elseif (GetBestMapForUnit == 100 or GetBestMapForUnit == 102 or GetBestMapForUnit == 104 or GetBestMapForUnit == 105 or GetBestMapForUnit == 107 or GetBestMapForUnit == 108
        or GetBestMapForUnit == 109)
      then
        if not ns.Addon.db.profile.showMiniMapOutland then
          ns.Addon.db.profile.showMiniMapOutland = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Outland"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showMiniMapOutland = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Outland"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Northrend
      elseif (GetBestMapForUnit == 114 or GetBestMapForUnit == 115 or GetBestMapForUnit == 116 or GetBestMapForUnit == 117 or GetBestMapForUnit == 118 or GetBestMapForUnit == 119
        or GetBestMapForUnit == 120 or GetBestMapForUnit == 121 or GetBestMapForUnit == 123 or GetBestMapForUnit == 127 or GetBestMapForUnit == 170)
      then
        if not ns.Addon.db.profile.showMiniMapNorthrend then
          ns.Addon.db.profile.showMiniMapNorthrend = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Northrend"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showMiniMapNorthrend = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Northrend"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Pandaria
      elseif (GetBestMapForUnit == 371 or GetBestMapForUnit == 376 or GetBestMapForUnit == 379 or GetBestMapForUnit == 388 or GetBestMapForUnit == 390 or GetBestMapForUnit == 418
        or GetBestMapForUnit == 422 or GetBestMapForUnit == 433 or GetBestMapForUnit == 434 or GetBestMapForUnit == 504 or GetBestMapForUnit == 554  or GetBestMapForUnit == 1530
        or GetBestMapForUnit == 507)
      then
        if not ns.Addon.db.profile.showMiniMapPandaria then
          ns.Addon.db.profile.showMiniMapPandaria = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Pandaria"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showMiniMapPandaria = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Pandaria"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Draenor
      elseif (GetBestMapForUnit == 525 or GetBestMapForUnit == 534 or GetBestMapForUnit == 535 or GetBestMapForUnit == 539 or GetBestMapForUnit == 542 or GetBestMapForUnit == 543
        or GetBestMapForUnit == 550 or GetBestMapForUnit == 588)
      then
        if not ns.Addon.db.profile.showMiniMapDraenor then
          ns.Addon.db.profile.showMiniMapDraenor = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Draenor"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showMiniMapDraenor = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Draenor"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Broken Isles
      elseif (GetBestMapForUnit == 630 or GetBestMapForUnit == 634 or GetBestMapForUnit == 641 or GetBestMapForUnit == 646 or GetBestMapForUnit == 650 or GetBestMapForUnit == 652
        or GetBestMapForUnit == 750 or GetBestMapForUnit == 680 or GetBestMapForUnit == 830 or GetBestMapForUnit == 882 or GetBestMapForUnit == 885 or GetBestMapForUnit == 905
        or GetBestMapForUnit == 941 or GetBestMapForUnit == 790 or GetBestMapForUnit == 971)
      then
        if not ns.Addon.db.profile.showMiniMapBrokenIsles then
          ns.Addon.db.profile.showMiniMapBrokenIsles = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Broken Isles"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showMiniMapBrokenIsles = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Broken Isles"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Zandalar
      elseif (GetBestMapForUnit == 862 or GetBestMapForUnit == 863 or GetBestMapForUnit == 864 or GetBestMapForUnit == 1355 or GetBestMapForUnit == 1528)
      then
        if not ns.Addon.db.profile.showMiniMapZandalar then
          ns.Addon.db.profile.showMiniMapZandalar = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zandalar"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showMiniMapZandalar = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zandalar"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Kul Tiras
      elseif (GetBestMapForUnit == 895 or GetBestMapForUnit == 896 or GetBestMapForUnit == 942 or GetBestMapForUnit == 1462 or GetBestMapForUnit == 1169)
      then
        if not ns.Addon.db.profile.showMiniMapKulTiras then
          ns.Addon.db.profile.showMiniMapKulTiras = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kul Tiras"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showMiniMapKulTiras = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kul Tiras"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Shadowlands
      elseif (GetBestMapForUnit == 1525 or GetBestMapForUnit == 1533 or GetBestMapForUnit == 1536 or GetBestMapForUnit == 1543 or GetBestMapForUnit == 1565 or GetBestMapForUnit == 1961
        or GetBestMapForUnit == 1970 or GetBestMapForUnit == 2016)
      then
        if not ns.Addon.db.profile.showMiniMapShadowlands then
          ns.Addon.db.profile.showMiniMapShadowlands = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Shadowlands"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showMiniMapShadowlands = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Shadowlands"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Dragon Isles
      elseif (GetBestMapForUnit == 2022 or GetBestMapForUnit == 2023 or GetBestMapForUnit == 2024 or GetBestMapForUnit == 2025 or GetBestMapForUnit == 2026 or GetBestMapForUnit == 2133
        or GetBestMapForUnit == 2151 or GetBestMapForUnit == 2200 or GetBestMapForUnit == 2239)
      then
        if not ns.Addon.db.profile.showMiniMapDragonIsles then
          ns.Addon.db.profile.showMiniMapDragonIsles = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dragon Isles"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showMiniMapDragonIsles = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dragon Isles"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Khaz Algar
      elseif (GetBestMapForUnit == 2248 or GetBestMapForUnit == 2214 or GetBestMapForUnit == 2215 or GetBestMapForUnit == 2255 or GetBestMapForUnit == 2256 or GetBestMapForUnit == 2213 
        or GetBestMapForUnit == 2216 or GetBestMapForUnit == 2369 or GetBestMapForUnit == 2322 or GetBestMapForUnit == 2346 or GetBestMapForUnit == 2371 or GetBestMapForUnit == 2472)
      then
        if not ns.Addon.db.profile.showMiniMapKhazAlgar then
          ns.Addon.db.profile.showMiniMapKhazAlgar = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Khaz Algar"] .. " " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showMiniMapKhazAlgar = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Khaz Algar"] .. " " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      end
    end

    -- Zone Sync function
    if ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6) 
      and not (GetBestMapForUnit == 1454 or GetBestMapForUnit == 1456 --Cata nodes
      or GetBestMapForUnit == 2266 -- Millenia's Threshold
      or GetBestMapForUnit == 84 or GetBestMapForUnit == 87 or GetBestMapForUnit == 89 or GetBestMapForUnit == 103 or GetBestMapForUnit == 85
      or GetBestMapForUnit == 90 or GetBestMapForUnit == 86 or GetBestMapForUnit == 88 or GetBestMapForUnit == 110 or GetBestMapForUnit == 111
      or GetBestMapForUnit == 125 or GetBestMapForUnit == 126 or GetBestMapForUnit == 391 or GetBestMapForUnit == 392 or GetBestMapForUnit == 393 
      or GetBestMapForUnit == 394 or GetBestMapForUnit == 582 or GetBestMapForUnit == 590 or GetBestMapForUnit == 622 or GetBestMapForUnit == 624 
      or GetBestMapForUnit == 626 or GetBestMapForUnit == 627 or GetBestMapForUnit == 628 or GetBestMapForUnit == 629 or GetBestMapForUnit == 831 or GetBestMapForUnit == 832
      or GetBestMapForUnit == 1161 or GetBestMapForUnit == 1163 or GetBestMapForUnit == 1164 or GetBestMapForUnit == 1165 or GetBestMapForUnit == 1670 
      or GetBestMapForUnit == 1671 or GetBestMapForUnit == 1672 or GetBestMapForUnit == 1673 or GetBestMapForUnit == 2112 or GetBestMapForUnit == 407 
      or GetBestMapForUnit == 2339 or GetBestMapForUnit == 499 or GetBestMapForUnit == 500)
    then
      --Kalimdor
      if (GetBestMapForUnit == 1 or GetBestMapForUnit == 7 or GetBestMapForUnit == 10 or GetBestMapForUnit == 11 or GetBestMapForUnit == 57 or GetBestMapForUnit == 62 
        or GetBestMapForUnit == 63 or GetBestMapForUnit == 64 or GetBestMapForUnit == 65 or GetBestMapForUnit == 66 or GetBestMapForUnit == 67 or GetBestMapForUnit == 68 
        or GetBestMapForUnit == 69 or GetBestMapForUnit == 70 or GetBestMapForUnit == 71 or GetBestMapForUnit == 74 or GetBestMapForUnit == 75 or GetBestMapForUnit == 76 
        or GetBestMapForUnit == 77 or GetBestMapForUnit == 78 or GetBestMapForUnit == 80 or GetBestMapForUnit == 81 or GetBestMapForUnit == 83 or GetBestMapForUnit == 97 
        or GetBestMapForUnit == 106 or GetBestMapForUnit == 199 or GetBestMapForUnit == 327 or GetBestMapForUnit == 460 or GetBestMapForUnit == 461 or GetBestMapForUnit == 462 
        or GetBestMapForUnit == 468 or GetBestMapForUnit == 1527 or GetBestMapForUnit == 198 or GetBestMapForUnit == 249)
      then
        if not ns.Addon.db.profile.showZoneKalimdor then
          ns.Addon.db.profile.showZoneKalimdor = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showZoneKalimdor = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Eastern Kingdom
      elseif (GetBestMapForUnit == 13 or GetBestMapForUnit == 14 or GetBestMapForUnit == 15 or GetBestMapForUnit == 16 or GetBestMapForUnit == 17 or GetBestMapForUnit == 18 
        or GetBestMapForUnit == 19 or GetBestMapForUnit == 21 or GetBestMapForUnit == 22 or GetBestMapForUnit == 23 or GetBestMapForUnit == 25 or GetBestMapForUnit == 26 
        or GetBestMapForUnit == 27 or GetBestMapForUnit == 28 or GetBestMapForUnit == 30 or GetBestMapForUnit == 32 or GetBestMapForUnit == 33 or GetBestMapForUnit == 34 
        or GetBestMapForUnit == 35 or GetBestMapForUnit == 36 or GetBestMapForUnit == 37 or GetBestMapForUnit == 42 or GetBestMapForUnit == 47 or GetBestMapForUnit == 48 
        or GetBestMapForUnit == 49 or GetBestMapForUnit == 50 or GetBestMapForUnit == 51 or GetBestMapForUnit == 52 or GetBestMapForUnit == 55 or GetBestMapForUnit == 56 
        or GetBestMapForUnit == 94 or GetBestMapForUnit == 210 or GetBestMapForUnit == 224 or GetBestMapForUnit == 245 or GetBestMapForUnit == 425 or GetBestMapForUnit == 427 
        or GetBestMapForUnit == 465 or GetBestMapForUnit == 467 or GetBestMapForUnit == 469 or GetBestMapForUnit == 2070 
        or GetBestMapForUnit == 241 or GetBestMapForUnit == 203 or GetBestMapForUnit == 204 or GetBestMapForUnit == 205 or GetBestMapForUnit == 241 or GetBestMapForUnit == 244 
        or GetBestMapForUnit == 245 or GetBestMapForUnit == 201 or GetBestMapForUnit == 95 or GetBestMapForUnit == 122 or GetBestMapForUnit == 217  or GetBestMapForUnit == 226)
      then
        if not ns.Addon.db.profile.showZoneEasternKingdom then
          ns.Addon.db.profile.showZoneEasternKingdom = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showZoneEasternKingdom = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Outland
      elseif (GetBestMapForUnit == 100 or GetBestMapForUnit == 102 or GetBestMapForUnit == 104 or GetBestMapForUnit == 105 or GetBestMapForUnit == 107 or GetBestMapForUnit == 108
        or GetBestMapForUnit == 109)
      then
        if not ns.Addon.db.profile.showZoneOutland then
          ns.Addon.db.profile.showZoneOutland = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showZoneOutland = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Northrend
      elseif (GetBestMapForUnit == 114 or GetBestMapForUnit == 115 or GetBestMapForUnit == 116 or GetBestMapForUnit == 117 or GetBestMapForUnit == 118 or GetBestMapForUnit == 119
        or GetBestMapForUnit == 120 or GetBestMapForUnit == 121 or GetBestMapForUnit == 123 or GetBestMapForUnit == 127 or GetBestMapForUnit == 170)
      then
        if not ns.Addon.db.profile.showZoneNorthrend then
          ns.Addon.db.profile.showZoneNorthrend = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showZoneNorthrend = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Pandaria
      elseif (GetBestMapForUnit == 371 or GetBestMapForUnit == 376 or GetBestMapForUnit == 379 or GetBestMapForUnit == 388 or GetBestMapForUnit == 390 or GetBestMapForUnit == 418
        or GetBestMapForUnit == 422 or GetBestMapForUnit == 433 or GetBestMapForUnit == 434 or GetBestMapForUnit == 504 or GetBestMapForUnit == 554  or GetBestMapForUnit == 1530
        or GetBestMapForUnit == 507)
      then
        if not ns.Addon.db.profile.showZonePandaria then
          ns.Addon.db.profile.showZonePandaria = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showZonePandaria = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Draenor
      elseif (GetBestMapForUnit == 525 or GetBestMapForUnit == 534 or GetBestMapForUnit == 535 or GetBestMapForUnit == 539 or GetBestMapForUnit == 542 or GetBestMapForUnit == 543
        or GetBestMapForUnit == 550 or GetBestMapForUnit == 588)
      then
        if not ns.Addon.db.profile.showZoneDraenor then
          ns.Addon.db.profile.showZoneDraenor = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showZoneDraenor = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Broken Isles
      elseif (GetBestMapForUnit == 630 or GetBestMapForUnit == 634 or GetBestMapForUnit == 641 or GetBestMapForUnit == 646 or GetBestMapForUnit == 650 or GetBestMapForUnit == 652
        or GetBestMapForUnit == 750 or GetBestMapForUnit == 680 or GetBestMapForUnit == 830 or GetBestMapForUnit == 882 or GetBestMapForUnit == 885 or GetBestMapForUnit == 905
        or GetBestMapForUnit == 941 or GetBestMapForUnit == 790 or GetBestMapForUnit == 971)
      then
        if not ns.Addon.db.profile.showZoneBrokenIsles then
          ns.Addon.db.profile.showZoneBrokenIsles = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showZoneBrokenIsles = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Zandalar
      elseif (GetBestMapForUnit == 862 or GetBestMapForUnit == 863 or GetBestMapForUnit == 864 or GetBestMapForUnit == 1355 or GetBestMapForUnit == 1528)
      then
        if not ns.Addon.db.profile.showZoneZandalar then
          ns.Addon.db.profile.showZoneZandalar = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showZoneZandalar = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Kul Tiras
      elseif (GetBestMapForUnit == 895 or GetBestMapForUnit == 896 or GetBestMapForUnit == 942 or GetBestMapForUnit == 1462 or GetBestMapForUnit == 1169)
      then
        if not ns.Addon.db.profile.showZoneKulTiras then
          ns.Addon.db.profile.showZoneKulTiras = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showZoneKulTiras = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Shadowlands
      elseif (GetBestMapForUnit == 1525 or GetBestMapForUnit == 1533 or GetBestMapForUnit == 1536 or GetBestMapForUnit == 1543 or GetBestMapForUnit == 1565 or GetBestMapForUnit == 1961
        or GetBestMapForUnit == 1970 or GetBestMapForUnit == 2016)
      then
        if not ns.Addon.db.profile.showZoneShadowlands then
          ns.Addon.db.profile.showZoneShadowlands = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showZoneShadowlands = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      --Dragon Isles
      elseif (GetBestMapForUnit == 2022 or GetBestMapForUnit == 2023 or GetBestMapForUnit == 2024 or GetBestMapForUnit == 2025 or GetBestMapForUnit == 2026 or GetBestMapForUnit == 2133
        or GetBestMapForUnit == 2151 or GetBestMapForUnit == 2200 or GetBestMapForUnit == 2239)
      then
        if not ns.Addon.db.profile.showZoneDragonIsles then
          ns.Addon.db.profile.showZoneDragonIsles = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Dragon Isles"]  .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showZoneDragonIsles = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Dragon Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
       --Khaz Algar
      elseif (GetBestMapForUnit == 2248 or GetBestMapForUnit == 2214 or GetBestMapForUnit == 2215 or GetBestMapForUnit == 2255 or GetBestMapForUnit == 2256 or GetBestMapForUnit == 2213 
        or GetBestMapForUnit == 2216 or GetBestMapForUnit == 2369 or GetBestMapForUnit == 2322 or GetBestMapForUnit == 2346 or GetBestMapForUnit == 2371 or GetBestMapForUnit == 2472)
      then
        if not ns.Addon.db.profile.showZoneKhazAlgar then
          ns.Addon.db.profile.showZoneKhazAlgar = true
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Khaz Algar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["are shown"])
          end
        else
          ns.Addon.db.profile.showZoneKhazAlgar = false
          if ns.Addon.db.profile.MmbWmbChatMessage then
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Khaz Algar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"])
          end
        end
      end
    end

    -- CapitalsMinimap without Sync function
    if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap
      and (GetBestMapForUnit == 1454 or GetBestMapForUnit == 1456 --Cata nodes
      or GetBestMapForUnit == 2266 -- Millenia's Threshold
      or GetBestMapForUnit == 84 or GetBestMapForUnit == 87 or GetBestMapForUnit == 89 or GetBestMapForUnit == 103 or GetBestMapForUnit == 85
      or GetBestMapForUnit == 90 or GetBestMapForUnit == 86 or GetBestMapForUnit == 88 or GetBestMapForUnit == 110 or GetBestMapForUnit == 111
      or GetBestMapForUnit == 125 or GetBestMapForUnit == 126 or GetBestMapForUnit == 391 or GetBestMapForUnit == 392 or GetBestMapForUnit == 393 
      or GetBestMapForUnit == 394 or GetBestMapForUnit == 582 or GetBestMapForUnit == 590 or GetBestMapForUnit == 622 or GetBestMapForUnit == 624 
      or GetBestMapForUnit == 626 or GetBestMapForUnit == 627 or GetBestMapForUnit == 628 or GetBestMapForUnit == 629 or GetBestMapForUnit == 831 or GetBestMapForUnit == 832
      or GetBestMapForUnit == 1161 or GetBestMapForUnit == 1163 or GetBestMapForUnit == 1164 or GetBestMapForUnit == 1165 or GetBestMapForUnit == 1670 
      or GetBestMapForUnit == 1671 or GetBestMapForUnit == 1672 or GetBestMapForUnit == 1673 or GetBestMapForUnit == 2112 or GetBestMapForUnit == 407 
      or GetBestMapForUnit == 2339 or GetBestMapForUnit == 499 or GetBestMapForUnit == 500)
    then
      if not ns.Addon.db.profile.activate.MinimapCapitals then
        ns.Addon.db.profile.activate.MinimapCapitals = true
        if ns.Addon.db.profile.MmbWmbChatMessage then
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, L["Capitals"], L["icons"], "|cff00ff00" .. L["are shown"])
        end
      else
        ns.Addon.db.profile.activate.MinimapCapitals = false
        if ns.Addon.db.profile.MmbWmbChatMessage then
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, L["Capitals"], L["icons"], "|cffff0000" .. L["are hidden"])
        end
      end
    end

    -- Capital Synch function
    if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap
      and (GetBestMapForUnit == 1454 or GetBestMapForUnit == 1456 --Cata nodes
      or GetBestMapForUnit == 2266 -- Millenia's Threshold
      or GetBestMapForUnit == 84 or GetBestMapForUnit == 87 or GetBestMapForUnit == 89 or GetBestMapForUnit == 103 or GetBestMapForUnit == 85
      or GetBestMapForUnit == 90 or GetBestMapForUnit == 86 or GetBestMapForUnit == 88 or GetBestMapForUnit == 110 or GetBestMapForUnit == 111
      or GetBestMapForUnit == 125 or GetBestMapForUnit == 126 or GetBestMapForUnit == 391 or GetBestMapForUnit == 392 or GetBestMapForUnit == 393 
      or GetBestMapForUnit == 394 or GetBestMapForUnit == 582 or GetBestMapForUnit == 590 or GetBestMapForUnit == 622 or GetBestMapForUnit == 624 
      or GetBestMapForUnit == 626 or GetBestMapForUnit == 627 or GetBestMapForUnit == 628 or GetBestMapForUnit == 629 or GetBestMapForUnit == 831 or GetBestMapForUnit == 832
      or GetBestMapForUnit == 1161 or GetBestMapForUnit == 1163 or GetBestMapForUnit == 1164 or GetBestMapForUnit == 1165 or GetBestMapForUnit == 1670 
      or GetBestMapForUnit == 1671 or GetBestMapForUnit == 1672 or GetBestMapForUnit == 1673 or GetBestMapForUnit == 2112 or GetBestMapForUnit == 407 
      or GetBestMapForUnit == 2339 or GetBestMapForUnit == 499 or GetBestMapForUnit == 500)
    then
      if not ns.Addon.db.profile.activate.Capitals then
        ns.Addon.db.profile.activate.Capitals = true
        if ns.Addon.db.profile.MmbWmbChatMessage then
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
        end
      else
        ns.Addon.db.profile.activate.Capitals = false
        if ns.Addon.db.profile.MmbWmbChatMessage then
          print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
        end
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