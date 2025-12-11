local ADDON_NAME, ns = ...

local iconLink = "Interface\\Addons\\" .. ADDON_NAME .. "\\images\\"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MNMMBIcon = LibStub("LibDBIcon-1.0", true)

ns.miniButton = {
text = ns.COLORED_ADDON_NAME,
type = "data source",
icon = iconLink .. "MNL4",
OnTooltipShow = function(tooltip)
  if not (ns.Addon and ns.Addon.db and ns.Addon.db.profile) then
    if tooltip and tooltip.AddLine then
      tooltip:AddLine(ns.COLORED_ADDON_NAME)
      tooltip:Show()
    end
    return
  end
  local mapID = (WorldMapFrame and WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()) or C_Map.GetBestMapForUnit("player")
  local info = mapID and C_Map.GetMapInfo(mapID) or {}
  local PlayerMapID = C_Map.GetBestMapForUnit("player")

  if not tooltip or not tooltip.AddLine then return end
    tooltip:AddLine(ns.COLORED_ADDON_NAME)
    tooltip:AddLine(" ")
    tooltip:AddLine(L["Left-click => Open/Close"] .. " " .. ns.COLORED_ADDON_NAME,1,1,1)
    tooltip:AddLine(L["Shift + Right-click => hide"] .. " " .. "|cffffff00" .. L["-> MiniMapButton <-"],1,1,1)
    if ns.Addon.db.profile.activate.ToggleMap then
      tooltip:AddLine(L["Middle-Mouse-Button => Open/Close"] .. " " .. "|cff00ccff" .. "-> " .. WORLDMAP_BUTTON .." <-",1,1,1)
    end
    tooltip:AddLine(SHIFT_KEY .. " + " .. KEY_BUTTON3 .. "|cff00ccff" .. " -> " .. UIOPTIONS_MENU .. " " .. RELOADUI .. " (" .. SLASH_RELOAD1 .. ")" .." <-",1,1,1)


  -- Zone without Sync function
  if not ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 4 or info.mapType == 5 or info.mapType == 6)
    and not (PlayerMapID == 1454 or PlayerMapID == 1456 --Cata nodes
    or PlayerMapID == 2266 -- Millenia's Threshold
    or PlayerMapID == 2351 or PlayerMapID == 2352 -- Housing
    or PlayerMapID == 24 or PlayerMapID == 626 or PlayerMapID == 747 or PlayerMapID == 720 or PlayerMapID == 721 or PlayerMapID == 726 or PlayerMapID == 739 -- Legion Class Halls
    or PlayerMapID == 734 or PlayerMapID == 735 or PlayerMapID == 695 or PlayerMapID == 702 or PlayerMapID == 647 or PlayerMapID == 648 or PlayerMapID == 709 or PlayerMapID == 717 -- Legion Class Halls
    or PlayerMapID == 84 or PlayerMapID == 87 or PlayerMapID == 89 or PlayerMapID == 103 or PlayerMapID == 85
    or PlayerMapID == 90 or PlayerMapID == 86 or PlayerMapID == 88 or PlayerMapID == 110 or PlayerMapID == 111
    or PlayerMapID == 125 or PlayerMapID == 126 or PlayerMapID == 391 or PlayerMapID == 392 or PlayerMapID == 393 
    or PlayerMapID == 394 or PlayerMapID == 582 or PlayerMapID == 590 or PlayerMapID == 622 or PlayerMapID == 624 
    or PlayerMapID == 627 or PlayerMapID == 628 or PlayerMapID == 629 or PlayerMapID == 831 or PlayerMapID == 832
    or PlayerMapID == 1161 or PlayerMapID == 1163 or PlayerMapID == 1164 or PlayerMapID == 1165 or PlayerMapID == 1670 
    or PlayerMapID == 1671 or PlayerMapID == 1672 or PlayerMapID == 1673 or PlayerMapID == 2112 or PlayerMapID == 407 
    or PlayerMapID == 2339 or PlayerMapID == 499 or PlayerMapID == 500)
  then
    --Kalimdor
    if (PlayerMapID == 1 or PlayerMapID == 7 or PlayerMapID == 10 or PlayerMapID == 11 or PlayerMapID == 57 or PlayerMapID == 62 
      or PlayerMapID == 63 or PlayerMapID == 64 or PlayerMapID == 65 or PlayerMapID == 66 or PlayerMapID == 67 or PlayerMapID == 68 
      or PlayerMapID == 69 or PlayerMapID == 70 or PlayerMapID == 71 or PlayerMapID == 74 or PlayerMapID == 75 or PlayerMapID == 76 
      or PlayerMapID == 77 or PlayerMapID == 78 or PlayerMapID == 80 or PlayerMapID == 81 or PlayerMapID == 83 or PlayerMapID == 97 
      or PlayerMapID == 106 or PlayerMapID == 199 or PlayerMapID == 327 or PlayerMapID == 460 or PlayerMapID == 461 or PlayerMapID == 462 
      or PlayerMapID == 468 or PlayerMapID == 1527 or PlayerMapID == 198 or PlayerMapID == 249)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kalimdor"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Eastern Kingdom
    elseif (PlayerMapID == 13 or PlayerMapID == 14 or PlayerMapID == 15 or PlayerMapID == 16 or PlayerMapID == 17 or PlayerMapID == 18 
      or PlayerMapID == 19 or PlayerMapID == 21 or PlayerMapID == 22 or PlayerMapID == 23 or PlayerMapID == 25 or PlayerMapID == 26 
      or PlayerMapID == 27 or PlayerMapID == 28 or PlayerMapID == 30 or PlayerMapID == 32 or PlayerMapID == 33 or PlayerMapID == 34 
      or PlayerMapID == 35 or PlayerMapID == 36 or PlayerMapID == 37 or PlayerMapID == 42 or PlayerMapID == 47 or PlayerMapID == 48 
      or PlayerMapID == 49 or PlayerMapID == 50 or PlayerMapID == 51 or PlayerMapID == 52 or PlayerMapID == 55 or PlayerMapID == 56 
      or PlayerMapID == 94 or PlayerMapID == 210 or PlayerMapID == 224 or PlayerMapID == 245 or PlayerMapID == 425 or PlayerMapID == 427 
      or PlayerMapID == 465 or PlayerMapID == 467 or PlayerMapID == 469 or PlayerMapID == 2070 
      or PlayerMapID == 241 or PlayerMapID == 203 or PlayerMapID == 204 or PlayerMapID == 205 or PlayerMapID == 241 or PlayerMapID == 244 
      or PlayerMapID == 245 or PlayerMapID == 201 or PlayerMapID == 95 or PlayerMapID == 122 or PlayerMapID == 217  or PlayerMapID == 226)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Eastern Kingdom"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Outland
    elseif (PlayerMapID == 100 or PlayerMapID == 102 or PlayerMapID == 104 or PlayerMapID == 105 or PlayerMapID == 107 or PlayerMapID == 108
      or PlayerMapID == 109)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Outland"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Northrend
    elseif (PlayerMapID == 114 or PlayerMapID == 115 or PlayerMapID == 116 or PlayerMapID == 117 or PlayerMapID == 118 or PlayerMapID == 119
      or PlayerMapID == 120 or PlayerMapID == 121 or PlayerMapID == 123 or PlayerMapID == 127 or PlayerMapID == 170)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Northrend"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Pandaria
    elseif (PlayerMapID == 371 or PlayerMapID == 376 or PlayerMapID == 379 or PlayerMapID == 388 or PlayerMapID == 390 or PlayerMapID == 418
      or PlayerMapID == 422 or PlayerMapID == 433 or PlayerMapID == 434 or PlayerMapID == 504 or PlayerMapID == 554  or PlayerMapID == 1530
      or PlayerMapID == 507)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Pandaria"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Draenor
    elseif (PlayerMapID == 525 or PlayerMapID == 534 or PlayerMapID == 535 or PlayerMapID == 539 or PlayerMapID == 542 or PlayerMapID == 543
      or PlayerMapID == 550 or PlayerMapID == 588)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Draenor"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Broken Isles
    elseif (PlayerMapID == 630 or PlayerMapID == 634 or PlayerMapID == 641 or PlayerMapID == 646 or PlayerMapID == 650 or PlayerMapID == 652 or PlayerMapID == 659
      or PlayerMapID == 750 or PlayerMapID == 680 or PlayerMapID == 830 or PlayerMapID == 882 or PlayerMapID == 885 or PlayerMapID == 905
      or PlayerMapID == 941 or PlayerMapID == 790 or PlayerMapID == 971 or PlayerMapID == 715)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Broken Isles"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Zandalar
    elseif (PlayerMapID == 862 or PlayerMapID == 863 or PlayerMapID == 864 or PlayerMapID == 1355 or PlayerMapID == 1528)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Zandalar"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Kul Tiras
    elseif (PlayerMapID == 895 or PlayerMapID == 896 or PlayerMapID == 942 or PlayerMapID == 1462 or PlayerMapID == 1169)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kul Tiras"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Shadowlands
    elseif (PlayerMapID == 1525 or PlayerMapID == 1533 or PlayerMapID == 1536 or PlayerMapID == 1543 or PlayerMapID == 1565 or PlayerMapID == 1816 or PlayerMapID == 1961
      or PlayerMapID == 1970 or PlayerMapID == 2016)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Shadowlands"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Dragon Isles
    elseif (PlayerMapID == 2022 or PlayerMapID == 2023 or PlayerMapID == 2024 or PlayerMapID == 2025 or PlayerMapID == 2026 or PlayerMapID == 2133
      or PlayerMapID == 2151 or PlayerMapID == 2200 or PlayerMapID == 2239)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Dragon Isles"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Khaz Algar
    elseif (PlayerMapID == 2248 or PlayerMapID == 2214 or PlayerMapID == 2215 or PlayerMapID == 2255 or PlayerMapID == 2256 or PlayerMapID == 2213 
      or PlayerMapID == 2216 or PlayerMapID == 2369 or PlayerMapID == 2322 or PlayerMapID == 2346 or PlayerMapID == 2371 or PlayerMapID == 2472)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Khaz Algar"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    end
  end

  -- Zone Sync function
  if ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6)
    and not (PlayerMapID == 1454 or PlayerMapID == 1456 --Cata nodes
    or PlayerMapID == 2266 -- Millenia's Threshold
    or PlayerMapID == 2351 or PlayerMapID == 2352 -- Housing
    or PlayerMapID == 24 or PlayerMapID == 626 or PlayerMapID == 747 or PlayerMapID == 720 or PlayerMapID == 721 or PlayerMapID == 726 or PlayerMapID == 739 -- Legion Class Halls
    or PlayerMapID == 734 or PlayerMapID == 735 or PlayerMapID == 695 or PlayerMapID == 702 or PlayerMapID == 647 or PlayerMapID == 648 or PlayerMapID == 709 or PlayerMapID == 717 -- Legion Class Halls
    or PlayerMapID == 84 or PlayerMapID == 87 or PlayerMapID == 89 or PlayerMapID == 103 or PlayerMapID == 85
    or PlayerMapID == 90 or PlayerMapID == 86 or PlayerMapID == 88 or PlayerMapID == 110 or PlayerMapID == 111
    or PlayerMapID == 125 or PlayerMapID == 126 or PlayerMapID == 391 or PlayerMapID == 392 or PlayerMapID == 393 
    or PlayerMapID == 394 or PlayerMapID == 582 or PlayerMapID == 590 or PlayerMapID == 622 or PlayerMapID == 624 
    or PlayerMapID == 627 or PlayerMapID == 628 or PlayerMapID == 629 or PlayerMapID == 831 or PlayerMapID == 832
    or PlayerMapID == 1161 or PlayerMapID == 1163 or PlayerMapID == 1164 or PlayerMapID == 1165 or PlayerMapID == 1670 
    or PlayerMapID == 1671 or PlayerMapID == 1672 or PlayerMapID == 1673 or PlayerMapID == 2112 or PlayerMapID == 407 
    or PlayerMapID == 2339 or PlayerMapID == 499 or PlayerMapID == 500)
  then
    --Kalimdor
    if (PlayerMapID == 1 or PlayerMapID == 7 or PlayerMapID == 10 or PlayerMapID == 11 or PlayerMapID == 57 or PlayerMapID == 62 
      or PlayerMapID == 63 or PlayerMapID == 64 or PlayerMapID == 65 or PlayerMapID == 66 or PlayerMapID == 67 or PlayerMapID == 68 
      or PlayerMapID == 69 or PlayerMapID == 70 or PlayerMapID == 71 or PlayerMapID == 74 or PlayerMapID == 75 or PlayerMapID == 76 
      or PlayerMapID == 77 or PlayerMapID == 78 or PlayerMapID == 80 or PlayerMapID == 81 or PlayerMapID == 83 or PlayerMapID == 97 
      or PlayerMapID == 106 or PlayerMapID == 199 or PlayerMapID == 327 or PlayerMapID == 460 or PlayerMapID == 461 or PlayerMapID == 462 
      or PlayerMapID == 468 or PlayerMapID == 1527 or PlayerMapID == 198 or PlayerMapID == 249)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Eastern Kingdom
    elseif (PlayerMapID == 13 or PlayerMapID == 14 or PlayerMapID == 15 or PlayerMapID == 16 or PlayerMapID == 17 or PlayerMapID == 18 
      or PlayerMapID == 19 or PlayerMapID == 21 or PlayerMapID == 22 or PlayerMapID == 23 or PlayerMapID == 25 or PlayerMapID == 26 
      or PlayerMapID == 27 or PlayerMapID == 28 or PlayerMapID == 30 or PlayerMapID == 32 or PlayerMapID == 33 or PlayerMapID == 34 
      or PlayerMapID == 35 or PlayerMapID == 36 or PlayerMapID == 37 or PlayerMapID == 42 or PlayerMapID == 47 or PlayerMapID == 48 
      or PlayerMapID == 49 or PlayerMapID == 50 or PlayerMapID == 51 or PlayerMapID == 52 or PlayerMapID == 55 or PlayerMapID == 56 
      or PlayerMapID == 94 or PlayerMapID == 210 or PlayerMapID == 224 or PlayerMapID == 245 or PlayerMapID == 425 or PlayerMapID == 427 
      or PlayerMapID == 465 or PlayerMapID == 467 or PlayerMapID == 469 or PlayerMapID == 2070 
      or PlayerMapID == 241 or PlayerMapID == 203 or PlayerMapID == 204 or PlayerMapID == 205 or PlayerMapID == 241 or PlayerMapID == 244 
      or PlayerMapID == 245 or PlayerMapID == 201 or PlayerMapID == 95 or PlayerMapID == 122 or PlayerMapID == 217  or PlayerMapID == 226)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Outland
    elseif (PlayerMapID == 100 or PlayerMapID == 102 or PlayerMapID == 104 or PlayerMapID == 105 or PlayerMapID == 107 or PlayerMapID == 108
      or PlayerMapID == 109)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Northrend
    elseif (PlayerMapID == 114 or PlayerMapID == 115 or PlayerMapID == 116 or PlayerMapID == 117 or PlayerMapID == 118 or PlayerMapID == 119
      or PlayerMapID == 120 or PlayerMapID == 121 or PlayerMapID == 123 or PlayerMapID == 127 or PlayerMapID == 170)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Pandaria
    elseif (PlayerMapID == 371 or PlayerMapID == 376 or PlayerMapID == 379 or PlayerMapID == 388 or PlayerMapID == 390 or PlayerMapID == 418
      or PlayerMapID == 422 or PlayerMapID == 433 or PlayerMapID == 434 or PlayerMapID == 504 or PlayerMapID == 554  or PlayerMapID == 1530
      or PlayerMapID == 507)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Draenor
    elseif (PlayerMapID == 525 or PlayerMapID == 534 or PlayerMapID == 535 or PlayerMapID == 539 or PlayerMapID == 542 or PlayerMapID == 543
      or PlayerMapID == 550 or PlayerMapID == 588)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Broken Isles
    elseif (PlayerMapID == 630 or PlayerMapID == 634 or PlayerMapID == 641 or PlayerMapID == 646 or PlayerMapID == 650 or PlayerMapID == 652 or PlayerMapID == 659
      or PlayerMapID == 750 or PlayerMapID == 680 or PlayerMapID == 830 or PlayerMapID == 882 or PlayerMapID == 885 or PlayerMapID == 905
      or PlayerMapID == 941 or PlayerMapID == 790 or PlayerMapID == 971 or PlayerMapID == 715 )
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Zandalar
    elseif (PlayerMapID == 862 or PlayerMapID == 863 or PlayerMapID == 864 or PlayerMapID == 1355 or PlayerMapID == 1528)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Kul Tiras
    elseif (PlayerMapID == 895 or PlayerMapID == 896 or PlayerMapID == 942 or PlayerMapID == 1462 or PlayerMapID == 1169)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Shadowlands
    elseif (PlayerMapID == 1525 or PlayerMapID == 1533 or PlayerMapID == 1536 or PlayerMapID == 1543 or PlayerMapID == 1565 or PlayerMapID == 1816 or PlayerMapID == 1961
      or PlayerMapID == 1970 or PlayerMapID == 2016)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Dragon Isles
    elseif (PlayerMapID == 2022 or PlayerMapID == 2023 or PlayerMapID == 2024 or PlayerMapID == 2025 or PlayerMapID == 2026 or PlayerMapID == 2133
      or PlayerMapID == 2151 or PlayerMapID == 2200 or PlayerMapID == 2239)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Dragon Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    --Khaz Algar
    elseif (PlayerMapID == 2248 or PlayerMapID == 2214 or PlayerMapID == 2215 or PlayerMapID == 2213 or PlayerMapID == 2216
      or PlayerMapID == 2369 or PlayerMapID == 2322 or PlayerMapID == 2346)
    then
      tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Khaz Algar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
      tooltip:Show()
    end
  end

  -- Capital without Synch function
  if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap 
    and (PlayerMapID == 1454 or PlayerMapID == 1456 --Cata nodes
    or PlayerMapID == 2266 -- Millenia's Threshold
    or PlayerMapID == 2351 or PlayerMapID == 2352 -- Housing
    or PlayerMapID == 24 or PlayerMapID == 626 or PlayerMapID == 747 or PlayerMapID == 720 or PlayerMapID == 721 or PlayerMapID == 726 or PlayerMapID == 739 -- Legion Class Halls
    or PlayerMapID == 734 or PlayerMapID == 735 or PlayerMapID == 695 or PlayerMapID == 702 or PlayerMapID == 647 or PlayerMapID == 648 or PlayerMapID == 709 or PlayerMapID == 717 -- Legion Class Halls
    or PlayerMapID == 84 or PlayerMapID == 87 or PlayerMapID == 89 or PlayerMapID == 103 or PlayerMapID == 85
    or PlayerMapID == 90 or PlayerMapID == 86 or PlayerMapID == 88 or PlayerMapID == 110 or PlayerMapID == 111
    or PlayerMapID == 125 or PlayerMapID == 126 or PlayerMapID == 391 or PlayerMapID == 392 or PlayerMapID == 393 
    or PlayerMapID == 394 or PlayerMapID == 582 or PlayerMapID == 590 or PlayerMapID == 622 or PlayerMapID == 624 
    or PlayerMapID == 627 or PlayerMapID == 628 or PlayerMapID == 629 or PlayerMapID == 831 or PlayerMapID == 832
    or PlayerMapID == 1161 or PlayerMapID == 1163 or PlayerMapID == 1164 or PlayerMapID == 1165 or PlayerMapID == 1670 
    or PlayerMapID == 1671 or PlayerMapID == 1672 or PlayerMapID == 1673 or PlayerMapID == 2112 or PlayerMapID == 407 
    or PlayerMapID == 2339 or PlayerMapID == 499 or PlayerMapID == 500)
  then
    tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Capitals"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
    tooltip:Show()
  end

  -- Capital Synch function
  if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap 
    and (PlayerMapID == 1454 or PlayerMapID == 1456 --Cata nodes
    or PlayerMapID == 2266 -- Millenia's Threshold
    or PlayerMapID == 2351 or PlayerMapID == 2352 -- Housing
    or PlayerMapID == 24 or PlayerMapID == 626 or PlayerMapID == 747 or PlayerMapID == 720 or PlayerMapID == 721 or PlayerMapID == 726 or PlayerMapID == 739 -- Legion Class Halls
    or PlayerMapID == 734 or PlayerMapID == 735 or PlayerMapID == 695 or PlayerMapID == 702 or PlayerMapID == 647 or PlayerMapID == 648 or PlayerMapID == 709 or PlayerMapID == 717 -- Legion Class Halls
    or PlayerMapID == 84 or PlayerMapID == 87 or PlayerMapID == 89 or PlayerMapID == 103 or PlayerMapID == 85
    or PlayerMapID == 90 or PlayerMapID == 86 or PlayerMapID == 88 or PlayerMapID == 110 or PlayerMapID == 111
    or PlayerMapID == 125 or PlayerMapID == 126 or PlayerMapID == 391 or PlayerMapID == 392 or PlayerMapID == 393 
    or PlayerMapID == 394 or PlayerMapID == 582 or PlayerMapID == 590 or PlayerMapID == 622 or PlayerMapID == 624 
    or PlayerMapID == 627 or PlayerMapID == 628 or PlayerMapID == 629 or PlayerMapID == 831 or PlayerMapID == 832
    or PlayerMapID == 1161 or PlayerMapID == 1163 or PlayerMapID == 1164 or PlayerMapID == 1165 or PlayerMapID == 1670 
    or PlayerMapID == 1671 or PlayerMapID == 1672 or PlayerMapID == 1673 or PlayerMapID == 2112 or PlayerMapID == 407 
    or PlayerMapID == 2339 or PlayerMapID == 499 or PlayerMapID == 500)
  then
    tooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Capitals"] .. " & " .. L["Capitals"] .. " " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
    tooltip:Show()
  end

  ns.suppressAreaMapMirror = true
  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
  C_Timer.After(0, function() ns.suppressAreaMapMirror = nil end)
end,

OnClick = function(self, button)
  if not (ns.Addon and ns.Addon.db and ns.Addon.db.profile) then return end
  local mapID = (WorldMapFrame and WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()) or C_Map.GetBestMapForUnit("player")
  local info = mapID and C_Map.GetMapInfo(mapID) or {}
  local PlayerMapID = C_Map.GetBestMapForUnit("player")

  if button == "RightButton" and not IsShiftKeyDown() then

    -- Zone without Sync function
    if not ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 4 or info.mapType == 5 or info.mapType == 6) 
      and not (PlayerMapID == 1454 or PlayerMapID == 1456 --Cata nodes
      or PlayerMapID == 24 or PlayerMapID == 626 or PlayerMapID == 747 or PlayerMapID == 720 or PlayerMapID == 721 or PlayerMapID == 726 or PlayerMapID == 739 -- Legion Class Halls
      or PlayerMapID == 734 or PlayerMapID == 735 or PlayerMapID == 695 or PlayerMapID == 702 or PlayerMapID == 647 or PlayerMapID == 648 or PlayerMapID == 709 or PlayerMapID == 717 -- Legion Class Halls
      or PlayerMapID == 84 or PlayerMapID == 87 or PlayerMapID == 89 or PlayerMapID == 103 or PlayerMapID == 85
      or PlayerMapID == 90 or PlayerMapID == 86 or PlayerMapID == 88 or PlayerMapID == 110 or PlayerMapID == 111
      or PlayerMapID == 125 or PlayerMapID == 126 or PlayerMapID == 391 or PlayerMapID == 392 or PlayerMapID == 393 
      or PlayerMapID == 394 or PlayerMapID == 582 or PlayerMapID == 590 or PlayerMapID == 622 or PlayerMapID == 624 
      or PlayerMapID == 627 or PlayerMapID == 628 or PlayerMapID == 629 or PlayerMapID == 831 or PlayerMapID == 832
      or PlayerMapID == 1161 or PlayerMapID == 1163 or PlayerMapID == 1164 or PlayerMapID == 1165 or PlayerMapID == 1670 
      or PlayerMapID == 1671 or PlayerMapID == 1672 or PlayerMapID == 1673 or PlayerMapID == 2112 or PlayerMapID == 407 
      or PlayerMapID == 2339 or PlayerMapID == 499 or PlayerMapID == 500)
    then
      --Kalimdor
      if (PlayerMapID == 1 or PlayerMapID == 7 or PlayerMapID == 10 or PlayerMapID == 11 or PlayerMapID == 57 or PlayerMapID == 62 
        or PlayerMapID == 63 or PlayerMapID == 64 or PlayerMapID == 65 or PlayerMapID == 66 or PlayerMapID == 67 or PlayerMapID == 68 
        or PlayerMapID == 69 or PlayerMapID == 70 or PlayerMapID == 71 or PlayerMapID == 74 or PlayerMapID == 75 or PlayerMapID == 76 
        or PlayerMapID == 77 or PlayerMapID == 78 or PlayerMapID == 80 or PlayerMapID == 81 or PlayerMapID == 83 or PlayerMapID == 97 
        or PlayerMapID == 106 or PlayerMapID == 199 or PlayerMapID == 327 or PlayerMapID == 460 or PlayerMapID == 461 or PlayerMapID == 462 
        or PlayerMapID == 468 or PlayerMapID == 1527 or PlayerMapID == 198 or PlayerMapID == 249)
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
      elseif (PlayerMapID == 13 or PlayerMapID == 14 or PlayerMapID == 15 or PlayerMapID == 16 or PlayerMapID == 17 or PlayerMapID == 18 
        or PlayerMapID == 19 or PlayerMapID == 21 or PlayerMapID == 22 or PlayerMapID == 23 or PlayerMapID == 25 or PlayerMapID == 26 
        or PlayerMapID == 27 or PlayerMapID == 28 or PlayerMapID == 30 or PlayerMapID == 32 or PlayerMapID == 33 or PlayerMapID == 34 
        or PlayerMapID == 35 or PlayerMapID == 36 or PlayerMapID == 37 or PlayerMapID == 42 or PlayerMapID == 47 or PlayerMapID == 48 
        or PlayerMapID == 49 or PlayerMapID == 50 or PlayerMapID == 51 or PlayerMapID == 52 or PlayerMapID == 55 or PlayerMapID == 56 
        or PlayerMapID == 94 or PlayerMapID == 210 or PlayerMapID == 224 or PlayerMapID == 245 or PlayerMapID == 425 or PlayerMapID == 427 
        or PlayerMapID == 465 or PlayerMapID == 467 or PlayerMapID == 469 or PlayerMapID == 2070 
        or PlayerMapID == 241 or PlayerMapID == 203 or PlayerMapID == 204 or PlayerMapID == 205 or PlayerMapID == 241 or PlayerMapID == 244 
        or PlayerMapID == 245 or PlayerMapID == 201 or PlayerMapID == 95 or PlayerMapID == 122 or PlayerMapID == 217  or PlayerMapID == 226)
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
      elseif (PlayerMapID == 100 or PlayerMapID == 102 or PlayerMapID == 104 or PlayerMapID == 105 or PlayerMapID == 107 or PlayerMapID == 108
        or PlayerMapID == 109)
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
      elseif (PlayerMapID == 114 or PlayerMapID == 115 or PlayerMapID == 116 or PlayerMapID == 117 or PlayerMapID == 118 or PlayerMapID == 119
        or PlayerMapID == 120 or PlayerMapID == 121 or PlayerMapID == 123 or PlayerMapID == 127 or PlayerMapID == 170)
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
      elseif (PlayerMapID == 371 or PlayerMapID == 376 or PlayerMapID == 379 or PlayerMapID == 388 or PlayerMapID == 390 or PlayerMapID == 418
        or PlayerMapID == 422 or PlayerMapID == 433 or PlayerMapID == 434 or PlayerMapID == 504 or PlayerMapID == 554  or PlayerMapID == 1530
        or PlayerMapID == 507)
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
      elseif (PlayerMapID == 525 or PlayerMapID == 534 or PlayerMapID == 535 or PlayerMapID == 539 or PlayerMapID == 542 or PlayerMapID == 543
        or PlayerMapID == 550 or PlayerMapID == 588)
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
      elseif (PlayerMapID == 630 or PlayerMapID == 634 or PlayerMapID == 641 or PlayerMapID == 646 or PlayerMapID == 650 or PlayerMapID == 652 or PlayerMapID == 659
        or PlayerMapID == 750 or PlayerMapID == 680 or PlayerMapID == 830 or PlayerMapID == 882 or PlayerMapID == 885 or PlayerMapID == 905
        or PlayerMapID == 941 or PlayerMapID == 790 or PlayerMapID == 971 or PlayerMapID == 715)
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
      elseif (PlayerMapID == 862 or PlayerMapID == 863 or PlayerMapID == 864 or PlayerMapID == 1355 or PlayerMapID == 1528)
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
      elseif (PlayerMapID == 895 or PlayerMapID == 896 or PlayerMapID == 942 or PlayerMapID == 1462 or PlayerMapID == 1169)
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
      elseif (PlayerMapID == 1525 or PlayerMapID == 1533 or PlayerMapID == 1536 or PlayerMapID == 1543 or PlayerMapID == 1565 or PlayerMapID == 1816 or PlayerMapID == 1961
        or PlayerMapID == 1970 or PlayerMapID == 2016)
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
      elseif (PlayerMapID == 2022 or PlayerMapID == 2023 or PlayerMapID == 2024 or PlayerMapID == 2025 or PlayerMapID == 2026 or PlayerMapID == 2133
        or PlayerMapID == 2151 or PlayerMapID == 2200 or PlayerMapID == 2239)
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
      elseif (PlayerMapID == 2248 or PlayerMapID == 2214 or PlayerMapID == 2215 or PlayerMapID == 2255 or PlayerMapID == 2256 or PlayerMapID == 2213 
        or PlayerMapID == 2216 or PlayerMapID == 2369 or PlayerMapID == 2322 or PlayerMapID == 2346 or PlayerMapID == 2371 or PlayerMapID == 2472)
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
      and not (PlayerMapID == 1454 or PlayerMapID == 1456 --Cata nodes
      or PlayerMapID == 2266 -- Millenia's Threshold
      or PlayerMapID == 2351 or PlayerMapID == 2352 -- Housing
      or PlayerMapID == 24 or PlayerMapID == 626 or PlayerMapID == 747 or PlayerMapID == 720 or PlayerMapID == 721 or PlayerMapID == 726 or PlayerMapID == 739 -- Legion Class Halls
      or PlayerMapID == 734 or PlayerMapID == 735 or PlayerMapID == 695 or PlayerMapID == 702 or PlayerMapID == 647 or PlayerMapID == 648 or PlayerMapID == 709 or PlayerMapID == 717 -- Legion Class Halls
      or PlayerMapID == 84 or PlayerMapID == 87 or PlayerMapID == 89 or PlayerMapID == 103 or PlayerMapID == 85
      or PlayerMapID == 90 or PlayerMapID == 86 or PlayerMapID == 88 or PlayerMapID == 110 or PlayerMapID == 111
      or PlayerMapID == 125 or PlayerMapID == 126 or PlayerMapID == 391 or PlayerMapID == 392 or PlayerMapID == 393 
      or PlayerMapID == 394 or PlayerMapID == 582 or PlayerMapID == 590 or PlayerMapID == 622 or PlayerMapID == 624 
      or PlayerMapID == 627 or PlayerMapID == 628 or PlayerMapID == 629 or PlayerMapID == 831 or PlayerMapID == 832
      or PlayerMapID == 1161 or PlayerMapID == 1163 or PlayerMapID == 1164 or PlayerMapID == 1165 or PlayerMapID == 1670 
      or PlayerMapID == 1671 or PlayerMapID == 1672 or PlayerMapID == 1673 or PlayerMapID == 2112 or PlayerMapID == 407 
      or PlayerMapID == 2339 or PlayerMapID == 499 or PlayerMapID == 500)
    then
      --Kalimdor
      if (PlayerMapID == 1 or PlayerMapID == 7 or PlayerMapID == 10 or PlayerMapID == 11 or PlayerMapID == 57 or PlayerMapID == 62 
        or PlayerMapID == 63 or PlayerMapID == 64 or PlayerMapID == 65 or PlayerMapID == 66 or PlayerMapID == 67 or PlayerMapID == 68 
        or PlayerMapID == 69 or PlayerMapID == 70 or PlayerMapID == 71 or PlayerMapID == 74 or PlayerMapID == 75 or PlayerMapID == 76 
        or PlayerMapID == 77 or PlayerMapID == 78 or PlayerMapID == 80 or PlayerMapID == 81 or PlayerMapID == 83 or PlayerMapID == 97 
        or PlayerMapID == 106 or PlayerMapID == 199 or PlayerMapID == 327 or PlayerMapID == 460 or PlayerMapID == 461 or PlayerMapID == 462 
        or PlayerMapID == 468 or PlayerMapID == 1527 or PlayerMapID == 198 or PlayerMapID == 249)
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
      elseif (PlayerMapID == 13 or PlayerMapID == 14 or PlayerMapID == 15 or PlayerMapID == 16 or PlayerMapID == 17 or PlayerMapID == 18 
        or PlayerMapID == 19 or PlayerMapID == 21 or PlayerMapID == 22 or PlayerMapID == 23 or PlayerMapID == 25 or PlayerMapID == 26 
        or PlayerMapID == 27 or PlayerMapID == 28 or PlayerMapID == 30 or PlayerMapID == 32 or PlayerMapID == 33 or PlayerMapID == 34 
        or PlayerMapID == 35 or PlayerMapID == 36 or PlayerMapID == 37 or PlayerMapID == 42 or PlayerMapID == 47 or PlayerMapID == 48 
        or PlayerMapID == 49 or PlayerMapID == 50 or PlayerMapID == 51 or PlayerMapID == 52 or PlayerMapID == 55 or PlayerMapID == 56 
        or PlayerMapID == 94 or PlayerMapID == 210 or PlayerMapID == 224 or PlayerMapID == 245 or PlayerMapID == 425 or PlayerMapID == 427 
        or PlayerMapID == 465 or PlayerMapID == 467 or PlayerMapID == 469 or PlayerMapID == 2070 
        or PlayerMapID == 241 or PlayerMapID == 203 or PlayerMapID == 204 or PlayerMapID == 205 or PlayerMapID == 241 or PlayerMapID == 244 
        or PlayerMapID == 245 or PlayerMapID == 201 or PlayerMapID == 95 or PlayerMapID == 122 or PlayerMapID == 217  or PlayerMapID == 226)
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
      elseif (PlayerMapID == 100 or PlayerMapID == 102 or PlayerMapID == 104 or PlayerMapID == 105 or PlayerMapID == 107 or PlayerMapID == 108
        or PlayerMapID == 109)
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
      elseif (PlayerMapID == 114 or PlayerMapID == 115 or PlayerMapID == 116 or PlayerMapID == 117 or PlayerMapID == 118 or PlayerMapID == 119
        or PlayerMapID == 120 or PlayerMapID == 121 or PlayerMapID == 123 or PlayerMapID == 127 or PlayerMapID == 170)
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
      elseif (PlayerMapID == 371 or PlayerMapID == 376 or PlayerMapID == 379 or PlayerMapID == 388 or PlayerMapID == 390 or PlayerMapID == 418
        or PlayerMapID == 422 or PlayerMapID == 433 or PlayerMapID == 434 or PlayerMapID == 504 or PlayerMapID == 554  or PlayerMapID == 1530
        or PlayerMapID == 507)
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
      elseif (PlayerMapID == 525 or PlayerMapID == 534 or PlayerMapID == 535 or PlayerMapID == 539 or PlayerMapID == 542 or PlayerMapID == 543
        or PlayerMapID == 550 or PlayerMapID == 588)
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
      elseif (PlayerMapID == 630 or PlayerMapID == 634 or PlayerMapID == 641 or PlayerMapID == 646 or PlayerMapID == 650 or PlayerMapID == 652 or PlayerMapID == 659
        or PlayerMapID == 750 or PlayerMapID == 680 or PlayerMapID == 830 or PlayerMapID == 882 or PlayerMapID == 885 or PlayerMapID == 905
        or PlayerMapID == 941 or PlayerMapID == 790 or PlayerMapID == 971 or PlayerMapID == 715)
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
      elseif (PlayerMapID == 862 or PlayerMapID == 863 or PlayerMapID == 864 or PlayerMapID == 1355 or PlayerMapID == 1528)
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
      elseif (PlayerMapID == 895 or PlayerMapID == 896 or PlayerMapID == 942 or PlayerMapID == 1462 or PlayerMapID == 1169)
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
      elseif (PlayerMapID == 1525 or PlayerMapID == 1533 or PlayerMapID == 1536 or PlayerMapID == 1543 or PlayerMapID == 1565 or PlayerMapID == 1816 or PlayerMapID == 1961
        or PlayerMapID == 1970 or PlayerMapID == 2016)
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
      elseif (PlayerMapID == 2022 or PlayerMapID == 2023 or PlayerMapID == 2024 or PlayerMapID == 2025 or PlayerMapID == 2026 or PlayerMapID == 2133
        or PlayerMapID == 2151 or PlayerMapID == 2200 or PlayerMapID == 2239)
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
      elseif (PlayerMapID == 2248 or PlayerMapID == 2214 or PlayerMapID == 2215 or PlayerMapID == 2255 or PlayerMapID == 2256 or PlayerMapID == 2213 
        or PlayerMapID == 2216 or PlayerMapID == 2369 or PlayerMapID == 2322 or PlayerMapID == 2346 or PlayerMapID == 2371 or PlayerMapID == 2472)
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
      and (PlayerMapID == 1454 or PlayerMapID == 1456 --Cata nodes
      or PlayerMapID == 2266 -- Millenia's Threshold
      or PlayerMapID == 2351 or PlayerMapID == 2352 -- Housing
      or PlayerMapID == 24 or PlayerMapID == 626 or PlayerMapID == 747 or PlayerMapID == 720 or PlayerMapID == 721 or PlayerMapID == 726 or PlayerMapID == 739 -- Legion Class Halls
      or PlayerMapID == 734 or PlayerMapID == 735 or PlayerMapID == 695 or PlayerMapID == 702 or PlayerMapID == 647 or PlayerMapID == 648 or PlayerMapID == 709 or PlayerMapID == 717 -- Legion Class Halls
      or PlayerMapID == 84 or PlayerMapID == 87 or PlayerMapID == 89 or PlayerMapID == 103 or PlayerMapID == 85
      or PlayerMapID == 90 or PlayerMapID == 86 or PlayerMapID == 88 or PlayerMapID == 110 or PlayerMapID == 111
      or PlayerMapID == 125 or PlayerMapID == 126 or PlayerMapID == 391 or PlayerMapID == 392 or PlayerMapID == 393 
      or PlayerMapID == 394 or PlayerMapID == 582 or PlayerMapID == 590 or PlayerMapID == 622 or PlayerMapID == 624 
      or PlayerMapID == 627 or PlayerMapID == 628 or PlayerMapID == 629 or PlayerMapID == 831 or PlayerMapID == 832
      or PlayerMapID == 1161 or PlayerMapID == 1163 or PlayerMapID == 1164 or PlayerMapID == 1165 or PlayerMapID == 1670 
      or PlayerMapID == 1671 or PlayerMapID == 1672 or PlayerMapID == 1673 or PlayerMapID == 2112 or PlayerMapID == 407 
      or PlayerMapID == 2339 or PlayerMapID == 499 or PlayerMapID == 500)
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
      and (PlayerMapID == 1454 or PlayerMapID == 1456 --Cata nodes
      or PlayerMapID == 2266 -- Millenia's Threshold
      or PlayerMapID == 2351 or PlayerMapID == 2352 -- Housing
      or PlayerMapID == 24 or PlayerMapID == 626 or PlayerMapID == 747 or PlayerMapID == 720 or PlayerMapID == 721 or PlayerMapID == 726 or PlayerMapID == 739 -- Legion Class Halls
      or PlayerMapID == 734 or PlayerMapID == 735 or PlayerMapID == 695 or PlayerMapID == 702 or PlayerMapID == 647 or PlayerMapID == 648 or PlayerMapID == 709 or PlayerMapID == 717 -- Legion Class Halls
      or PlayerMapID == 84 or PlayerMapID == 87 or PlayerMapID == 89 or PlayerMapID == 103 or PlayerMapID == 85
      or PlayerMapID == 90 or PlayerMapID == 86 or PlayerMapID == 88 or PlayerMapID == 110 or PlayerMapID == 111
      or PlayerMapID == 125 or PlayerMapID == 126 or PlayerMapID == 391 or PlayerMapID == 392 or PlayerMapID == 393 
      or PlayerMapID == 394 or PlayerMapID == 582 or PlayerMapID == 590 or PlayerMapID == 622 or PlayerMapID == 624 
      or PlayerMapID == 627 or PlayerMapID == 628 or PlayerMapID == 629 or PlayerMapID == 831 or PlayerMapID == 832
      or PlayerMapID == 1161 or PlayerMapID == 1163 or PlayerMapID == 1164 or PlayerMapID == 1165 or PlayerMapID == 1670 
      or PlayerMapID == 1671 or PlayerMapID == 1672 or PlayerMapID == 1673 or PlayerMapID == 2112 or PlayerMapID == 407 
      or PlayerMapID == 2339 or PlayerMapID == 499 or PlayerMapID == 500)
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

  -- reload ui
  if button == "MiddleButton" and IsShiftKeyDown() then
    ReloadUI()
  end

  -- open/close Worldmap
  if button == "MiddleButton" and not IsShiftKeyDown() then
    if ns.Addon.db.profile.activate.ToggleMap then
      if not InCombatLockdown() then
        if WorldMapFrame:IsShown() then
          WorldMapFrame:Hide()
        else
          C_Map.OpenWorldMap()
        end
      else
        if ns.Addon.db.profile.activate.InfoBlockedInCombat then
          UIErrorsFrame:AddMessage(ns.COLORED_ADDON_NAME .. "\n" .. ns.CombatLocked, 1, 0.82, 0)
        end
      end
    end
  end

  ns.suppressAreaMapMirror = true
  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
  C_Timer.After(0, function() ns.suppressAreaMapMirror = nil end)
end 
}