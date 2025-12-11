local ADDON_NAME, ns = ...

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local WorldMapOptionsButtonMixin = {}
_G[ADDON_NAME .. 'WorldMapOptionsButtonMixin'] = WorldMapOptionsButtonMixin

function WorldMapOptionsButtonMixin:OnLoad()

end


function WorldMapOptionsButtonMixin:OnClick(button)
local info = C_Map.GetMapInfo(WorldMapFrame:GetMapID())
local CurrentMapID = WorldMapFrame:GetMapID()

    if button == "LeftButton" then

        if not LibStub("AceConfigDialog-3.0"):Close("MapNotes") then
            LibStub("AceConfigDialog-3.0"):Open("MapNotes")
        end

        ns.suppressAreaMapMirror = true
        C_Timer.After(0, function() ns.suppressAreaMapMirror = nil end)
    end

    if button == "MiddleButton" then

        if not ns.Addon.db.profile.activate.HideMapNote then
            ns.Addon.db.profile.activate.HideMapNote = true
            if ns.ApplyWorldMapArrowSize then ns.ApplyWorldMapArrowSize() end -- deactivation of the worldmap player arrow changes
            if ns.RefreshContinentDelvesPins then ns.RefreshContinentDelvesPins({ remove = true }) end -- hide delves
            if ns.Addon.db.profile.MmbWmbChatMessage then
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffff0000", L["All MapNotes icons have been hidden"])
            end
        else
            ns.Addon.db.profile.activate.HideMapNote = false
            if ns.ApplyWorldMapArrowSize then ns.ApplyWorldMapArrowSize() end -- deactivation of the worldmap player arrow changes
            if ns.RefreshContinentDelvesPins then ns.RefreshContinentDelvesPins() end -- rebuild delves if activated
            if ns.Addon.db.profile.MmbWmbChatMessage then
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cff00ff00", L["All set icons have been restored"])
            end
        end

    end

    if button == "RightButton" then 

        -- Cosmos
        if info.mapType == 0 then 
        
            if not ns.Addon.db.profile.activate.CosmosMap then
                ns.Addon.db.profile.activate.CosmosMap = true
                if ns.Addon.db.profile.MmbWmbChatMessage then
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", WORLDMAP_BUTTON, L["icons"], "|cff00ff00" .. L["are shown"])
                end
            else
                ns.Addon.db.profile.activate.CosmosMap = false
                if ns.Addon.db.profile.MmbWmbChatMessage then
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", WORLDMAP_BUTTON, L["icons"], "|cffff0000" .. L["are hidden"])
                end
            end

        end

        -- Azeroth World Map
        if info.mapType == 1 then

            if not ns.Addon.db.profile.activate.Azeroth then
                ns.Addon.db.profile.activate.Azeroth = true
                if ns.Addon.db.profile.MmbWmbChatMessage then
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. AZEROTH, L["icons"], "|cff00ff00" .. L["are shown"])
                end
            else
                ns.Addon.db.profile.activate.Azeroth = false
                if ns.Addon.db.profile.MmbWmbChatMessage then
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. AZEROTH, L["icons"], "|cffff0000" .. L["are hidden"])
                end
            end

        end
        
        -- Continent Maps
        if info.mapType == 2 then 

            if CurrentMapID == 12 or CurrentMapID == 948 then
                if ns.Addon.db.profile.showContinentKalimdor then
                    ns.Addon.db.profile.showContinentKalimdor = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Kalimdor"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentKalimdor = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Kalimdor"], L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                end
            elseif CurrentMapID == 13 then
                if ns.Addon.db.profile.showContinentEasternKingdom then
                    ns.Addon.db.profile.showContinentEasternKingdom = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Eastern Kingdom"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentEasternKingdom = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Eastern Kingdom"], L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                end
            elseif CurrentMapID == 101 then
                if ns.Addon.db.profile.showContinentOutland then
                    ns.Addon.db.profile.showContinentOutland = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Outland"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentOutland = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Outland"], L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                end
            elseif CurrentMapID == 113 then
                if ns.Addon.db.profile.showContinentNorthrend then
                    ns.Addon.db.profile.showContinentNorthrend = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Northrend"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentNorthrend = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Northrend"], L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                end
            elseif CurrentMapID == 424 then
                if ns.Addon.db.profile.showContinentPandaria then
                    ns.Addon.db.profile.showContinentPandaria = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Pandaria"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentPandaria = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Pandaria"], L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                end
            elseif CurrentMapID == 572 then
                if ns.Addon.db.profile.showContinentDraenor then
                    ns.Addon.db.profile.showContinentDraenor = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Draenor"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentDraenor = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Draenor"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif CurrentMapID == 619 or CurrentMapID == 905 then
                if ns.Addon.db.profile.showContinentBrokenIsles then
                    ns.Addon.db.profile.showContinentBrokenIsles = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Broken Isles"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentBrokenIsles = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Broken Isles"], L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                end
            elseif CurrentMapID == 875 then
                if ns.Addon.db.profile.showContinentZandalar then
                    ns.Addon.db.profile.showContinentZandalar = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Zandalar"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentZandalar = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Zandalar"], L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                end
            elseif CurrentMapID == 876 then
                if ns.Addon.db.profile.showContinentKulTiras then
                    ns.Addon.db.profile.showContinentKulTiras = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Kul Tiras"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentKulTiras = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Kul Tiras"], L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                end
            elseif CurrentMapID == 1550 then
                if ns.Addon.db.profile.showContinentShadowlands then
                    ns.Addon.db.profile.showContinentShadowlands = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Shadowlands"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentShadowlands = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Shadowlands"], L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                end
            elseif CurrentMapID == 1978 then
                if ns.Addon.db.profile.showContinentDragonIsles then
                    ns.Addon.db.profile.showContinentDragonIsles = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Dragon Isles"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentDragonIsles = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Dragon Isles"], L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                end
            elseif CurrentMapID == 2274 then
                if ns.Addon.db.profile.showContinentKhazAlgar then
                    ns.Addon.db.profile.showContinentKhazAlgar = false
                    if ns.Addon.db.profile.showContinentDelves then ns.RefreshContinentDelvesPins() end
                    if not ns.Addon.db.profile.showContinentDelves then ns.RefreshContinentDelvesPins({ remove = true }) end
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Khaz Algar"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentKhazAlgar = true
                    if ns.Addon.db.profile.showContinentDelves then ns.RefreshContinentDelvesPins() end
                    if not ns.Addon.db.profile.showContinentDelves then ns.RefreshContinentDelvesPins({ remove = true }) end
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Khaz Algar"], L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                end
            end

        end

        -- Dungeon Maps
        if info.mapType == 4 and not 
            (CurrentMapID == 1454 or CurrentMapID == 1456 --Cata nodes
            or CurrentMapID == 719  -- Mardum
            or CurrentMapID == 2266 -- Milleania's Threshold
            or CurrentMapID == 24 or CurrentMapID == 626 or CurrentMapID == 747 or CurrentMapID == 720 or CurrentMapID == 721 or CurrentMapID == 726 or CurrentMapID == 739 -- Legion Class Halls
            or CurrentMapID == 734 or CurrentMapID == 735 or CurrentMapID == 695 or CurrentMapID == 702 or CurrentMapID == 647 or CurrentMapID == 648 or CurrentMapID == 709 or CurrentMapID == 717 -- Legion Class Halls
            or CurrentMapID == 84 or CurrentMapID == 87 or CurrentMapID == 89 or CurrentMapID == 103 or CurrentMapID == 85
            or CurrentMapID == 90 or CurrentMapID == 86 or CurrentMapID == 88 or CurrentMapID == 110 or CurrentMapID == 111
            or CurrentMapID == 125 or CurrentMapID == 126 or CurrentMapID == 391 or CurrentMapID == 392 or CurrentMapID == 393 
            or CurrentMapID == 394 or CurrentMapID == 582 or CurrentMapID == 590 or CurrentMapID == 622 or CurrentMapID == 624 
            or CurrentMapID == 627 or CurrentMapID == 628 or CurrentMapID == 629 or CurrentMapID == 831 or CurrentMapID == 832 
            or CurrentMapID == 1161 or CurrentMapID == 1163 or CurrentMapID == 1164 or CurrentMapID == 1165 or CurrentMapID == 1670 
            or CurrentMapID == 1671 or CurrentMapID == 1672 or CurrentMapID == 1673 or CurrentMapID == 2112 or CurrentMapID == 407 
            or CurrentMapID == 2339 or CurrentMapID == 503 or CurrentMapID == 499 or CurrentMapID == 500 or CurrentMapID == 2322)
        then
        
            if not ns.Addon.db.profile.activate.DungeonMap then
                ns.Addon.db.profile.activate.DungeonMap = true
                if ns.Addon.db.profile.MmbWmbChatMessage then
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dungeon map"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            else
                ns.Addon.db.profile.activate.DungeonMap = false
                if ns.Addon.db.profile.MmbWmbChatMessage then
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dungeon map"], L["icons"], "|cffff0000" .. L["are hidden"])
                end
            end

        end

        -- Zones without Sync function
        if not ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 4 or info.mapType == 5 or info.mapType == 6) then
            --Kalimdor
            if (CurrentMapID == 1 or CurrentMapID == 7 or CurrentMapID == 10 or CurrentMapID == 11 or CurrentMapID == 57 or CurrentMapID == 62 
                or CurrentMapID == 63 or CurrentMapID == 64 or CurrentMapID == 65 or CurrentMapID == 66 or CurrentMapID == 67 or CurrentMapID == 68 
                or CurrentMapID == 69 or CurrentMapID == 70 or CurrentMapID == 71 or CurrentMapID == 74 or CurrentMapID == 75 or CurrentMapID == 76 
                or CurrentMapID == 77 or CurrentMapID == 78 or CurrentMapID == 80 or CurrentMapID == 81 or CurrentMapID == 83 or CurrentMapID == 97 
                or CurrentMapID == 106 or CurrentMapID == 199 or CurrentMapID == 327 or CurrentMapID == 460 or CurrentMapID == 461 or CurrentMapID == 462 
                or CurrentMapID == 468 or CurrentMapID == 1527 or CurrentMapID == 198 or CurrentMapID == 249)
            then
                if not ns.Addon.db.profile.showZoneKalimdor then
                    ns.Addon.db.profile.showZoneKalimdor = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kalimdor"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneKalimdor = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kalimdor"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            --Eastern Kingdom
            elseif (CurrentMapID == 13 or CurrentMapID == 14 or CurrentMapID == 15 or CurrentMapID == 16 or CurrentMapID == 17 or CurrentMapID == 18 
                or CurrentMapID == 19 or CurrentMapID == 21 or CurrentMapID == 22 or CurrentMapID == 23 or CurrentMapID == 25 or CurrentMapID == 26 
                or CurrentMapID == 27 or CurrentMapID == 28 or CurrentMapID == 30 or CurrentMapID == 32 or CurrentMapID == 33 or CurrentMapID == 34 
                or CurrentMapID == 35 or CurrentMapID == 36 or CurrentMapID == 37 or CurrentMapID == 42 or CurrentMapID == 47 or CurrentMapID == 48 
                or CurrentMapID == 49 or CurrentMapID == 50 or CurrentMapID == 51 or CurrentMapID == 52 or CurrentMapID == 55 or CurrentMapID == 56 
                or CurrentMapID == 94 or CurrentMapID == 210 or CurrentMapID == 224 or CurrentMapID == 245 or CurrentMapID == 425 or CurrentMapID == 427 
                or CurrentMapID == 465 or CurrentMapID == 467 or CurrentMapID == 469 or CurrentMapID == 2070 
                or CurrentMapID == 241 or CurrentMapID == 203 or CurrentMapID == 204 or CurrentMapID == 205 or CurrentMapID == 241 or CurrentMapID == 244 
                or CurrentMapID == 245 or CurrentMapID == 201 or CurrentMapID == 95 or CurrentMapID == 122 or CurrentMapID == 217  or CurrentMapID == 226)
            then
                if not ns.Addon.db.profile.showZoneEasternKingdom then
                    ns.Addon.db.profile.showZoneEasternKingdom = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Eastern Kingdom"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneEasternKingdom = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            --Outland
            elseif (CurrentMapID == 100 or CurrentMapID == 102 or CurrentMapID == 104 or CurrentMapID == 105 or CurrentMapID == 107 or CurrentMapID == 108
                or CurrentMapID == 109)
            then
                if not ns.Addon.db.profile.showZoneOutland then
                    ns.Addon.db.profile.showZoneOutland = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Outland"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneOutland = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Outland"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            --Northrend
            elseif (CurrentMapID == 114 or CurrentMapID == 115 or CurrentMapID == 116 or CurrentMapID == 117 or CurrentMapID == 118 or CurrentMapID == 119
                or CurrentMapID == 120 or CurrentMapID == 121 or CurrentMapID == 123 or CurrentMapID == 127 or CurrentMapID == 170)
            then
                if not ns.Addon.db.profile.showZoneNorthrend then
                    ns.Addon.db.profile.showZoneNorthrend = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Northrend"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneNorthrend = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Northrend"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            --Pandaria
            elseif (CurrentMapID == 371 or CurrentMapID == 376 or CurrentMapID == 379 or CurrentMapID == 388 or CurrentMapID == 390 or CurrentMapID == 418
                or CurrentMapID == 422 or CurrentMapID == 433 or CurrentMapID == 434 or CurrentMapID == 504 or CurrentMapID == 554  or CurrentMapID == 1530
                or CurrentMapID == 507)
            then
                if not ns.Addon.db.profile.showZonePandaria then
                    ns.Addon.db.profile.showZonePandaria = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Pandaria"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZonePandaria = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Pandaria"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            --Draenor
            elseif (CurrentMapID == 525 or CurrentMapID == 534 or CurrentMapID == 535 or CurrentMapID == 539 or CurrentMapID == 542 or CurrentMapID == 543
                or CurrentMapID == 550 or CurrentMapID == 588)
            then
                if not ns.Addon.db.profile.showZoneDraenor then
                    ns.Addon.db.profile.showZoneDraenor = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Draenor"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneDraenor = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Draenor"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            --Broken Isles
            elseif (CurrentMapID == 630 or CurrentMapID == 634 or CurrentMapID == 641 or CurrentMapID == 646 or CurrentMapID == 650 or CurrentMapID == 652 or CurrentMapID == 659
                or CurrentMapID == 750 or CurrentMapID == 680 or CurrentMapID == 830 or CurrentMapID == 882 or CurrentMapID == 885 or CurrentMapID == 941 
                or CurrentMapID == 790 or CurrentMapID == 971 or CurrentMapID == 715 or CurrentMapID == 719)
            then
                if not ns.Addon.db.profile.showZoneBrokenIsles then
                    ns.Addon.db.profile.showZoneBrokenIsles = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Broken Isles"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneBrokenIsles = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Broken Isles"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            --Zandalar
            elseif (CurrentMapID == 862 or CurrentMapID == 863 or CurrentMapID == 864 or CurrentMapID == 1355 or CurrentMapID == 1528)
            then
                if not ns.Addon.db.profile.showZoneZandalar then
                    ns.Addon.db.profile.showZoneZandalar = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zandalar"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneZandalar = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zandalar"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            --KulTiras
            elseif (CurrentMapID == 895 or CurrentMapID == 896 or CurrentMapID == 942 or CurrentMapID == 1462 or CurrentMapID == 1169)
            then
                if not ns.Addon.db.profile.showZoneKulTiras then
                    ns.Addon.db.profile.showZoneKulTiras = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kul Tiras"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneKulTiras = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kul Tiras"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            --Shadowlands
            elseif (CurrentMapID == 1525 or CurrentMapID == 1533 or CurrentMapID == 1536 or CurrentMapID == 1543 or CurrentMapID == 1565 or CurrentMapID == 1816 or CurrentMapID == 1961
                or CurrentMapID == 1970 or CurrentMapID == 2016)
            then
                if not ns.Addon.db.profile.showZoneShadowlands then
                    ns.Addon.db.profile.showZoneShadowlands = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Shadowlands"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneShadowlands = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Shadowlands"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            --Dragon Isle
            elseif (CurrentMapID == 2022 or CurrentMapID == 2023 or CurrentMapID == 2024 or CurrentMapID == 2025 or CurrentMapID == 2026 or CurrentMapID == 2133
                or CurrentMapID == 2151 or CurrentMapID == 2200 or CurrentMapID == 2239)
            then
                if not ns.Addon.db.profile.showZoneDragonIsles then
                    ns.Addon.db.profile.showZoneDragonIsles = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dragon Isles"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneDragonIsles = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dragon Isles"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            --Khaz Algar
            elseif (CurrentMapID == 2248 or CurrentMapID == 2214 or CurrentMapID == 2215 or CurrentMapID == 2255 or CurrentMapID == 2256 or CurrentMapID == 2213 
                or CurrentMapID == 2216 or CurrentMapID == 2369 or CurrentMapID == 2322 or CurrentMapID == 2346 or CurrentMapID == 2371 or CurrentMapID == 2472)
            then
                if not ns.Addon.db.profile.showZoneKhazAlgar then
                    ns.Addon.db.profile.showZoneKhazAlgar = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Khaz Algar"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneKhazAlgar = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Khaz Algar"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            end
        end

        -- Zones Sync function
        if ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3  or info.mapType == 4 or info.mapType == 5 or info.mapType == 6) then
            --Kalimdor
            if (CurrentMapID == 1 or CurrentMapID == 7 or CurrentMapID == 10 or CurrentMapID == 11 or CurrentMapID == 57 or CurrentMapID == 62 
                or CurrentMapID == 63 or CurrentMapID == 64 or CurrentMapID == 65 or CurrentMapID == 66 or CurrentMapID == 67 or CurrentMapID == 68 
                or CurrentMapID == 69 or CurrentMapID == 70 or CurrentMapID == 71 or CurrentMapID == 74 or CurrentMapID == 75 or CurrentMapID == 76 
                or CurrentMapID == 77 or CurrentMapID == 78 or CurrentMapID == 80 or CurrentMapID == 81 or CurrentMapID == 83 or CurrentMapID == 97 
                or CurrentMapID == 106 or CurrentMapID == 199 or CurrentMapID == 327 or CurrentMapID == 460 or CurrentMapID == 461 or CurrentMapID == 462 
                or CurrentMapID == 468 or CurrentMapID == 1527 or CurrentMapID == 198 or CurrentMapID == 249)
            then
                if not ns.Addon.db.profile.showZoneKalimdor then
                    ns.Addon.db.profile.showZoneKalimdor = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneKalimdor = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            -- Eastern Kingdom
            elseif (CurrentMapID == 13 or CurrentMapID == 14 or CurrentMapID == 15 or CurrentMapID == 16 or CurrentMapID == 17 or CurrentMapID == 18 
                or CurrentMapID == 19 or CurrentMapID == 21 or CurrentMapID == 22 or CurrentMapID == 23 or CurrentMapID == 25 or CurrentMapID == 26 
                or CurrentMapID == 27 or CurrentMapID == 28 or CurrentMapID == 30 or CurrentMapID == 32 or CurrentMapID == 33 or CurrentMapID == 34 
                or CurrentMapID == 35 or CurrentMapID == 36 or CurrentMapID == 37 or CurrentMapID == 42 or CurrentMapID == 47 or CurrentMapID == 48 
                or CurrentMapID == 49 or CurrentMapID == 50 or CurrentMapID == 51 or CurrentMapID == 52 or CurrentMapID == 55 or CurrentMapID == 56 
                or CurrentMapID == 94 or CurrentMapID == 210 or CurrentMapID == 224 or CurrentMapID == 245 or CurrentMapID == 425 or CurrentMapID == 427 
                or CurrentMapID == 465 or CurrentMapID == 467 or CurrentMapID == 469 or CurrentMapID == 2070 
                or CurrentMapID == 241 or CurrentMapID == 203 or CurrentMapID == 204 or CurrentMapID == 205 or CurrentMapID == 241 or CurrentMapID == 244 
                or CurrentMapID == 245 or CurrentMapID == 201 or CurrentMapID == 95 or CurrentMapID == 122 or CurrentMapID == 217  or CurrentMapID == 226) 
            then
                if not ns.Addon.db.profile.showZoneEasternKingdom then
                    ns.Addon.db.profile.showZoneEasternKingdom = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneEasternKingdom = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            -- Outland    
            elseif (CurrentMapID == 100 or CurrentMapID == 102 or CurrentMapID == 104 or CurrentMapID == 105 or CurrentMapID == 107 or CurrentMapID == 108
                or CurrentMapID == 109) 
            then
                if not ns.Addon.db.profile.showZoneOutland then
                    ns.Addon.db.profile.showZoneOutland = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneOutland = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            -- Northrend    
            elseif (CurrentMapID == 114 or CurrentMapID == 115 or CurrentMapID == 116 or CurrentMapID == 117 or CurrentMapID == 118 or CurrentMapID == 119
                or CurrentMapID == 120 or CurrentMapID == 121 or CurrentMapID == 123 or CurrentMapID == 127 or CurrentMapID == 170) 
            then
                if not ns.Addon.db.profile.showZoneNorthrend then
                    ns.Addon.db.profile.showZoneNorthrend = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneNorthrend = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            -- Pandaria    
            elseif (CurrentMapID == 371 or CurrentMapID == 376 or CurrentMapID == 379 or CurrentMapID == 388 or CurrentMapID == 390 or CurrentMapID == 418
                or CurrentMapID == 422 or CurrentMapID == 433 or CurrentMapID == 434 or CurrentMapID == 504 or CurrentMapID == 554  or CurrentMapID == 1530
                or CurrentMapID == 507) 
            then
                if not ns.Addon.db.profile.showZonePandaria then
                    ns.Addon.db.profile.showZonePandaria = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZonePandaria = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            -- Draenor    
            elseif (CurrentMapID == 525 or CurrentMapID == 534 or CurrentMapID == 535 or CurrentMapID == 539 or CurrentMapID == 542 or CurrentMapID == 543
                or CurrentMapID == 550 or CurrentMapID == 588) 
            then
                if not ns.Addon.db.profile.showZoneDraenor then
                    ns.Addon.db.profile.showZoneDraenor = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneDraenor = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            -- Broken Isles    
            elseif (CurrentMapID == 630 or CurrentMapID == 634 or CurrentMapID == 641 or CurrentMapID == 646 or CurrentMapID == 650 or CurrentMapID == 652 or CurrentMapID == 659
                or CurrentMapID == 750 or CurrentMapID == 680 or CurrentMapID == 830 or CurrentMapID == 882 or CurrentMapID == 885 or CurrentMapID == 941 
                or CurrentMapID == 790 or CurrentMapID == 971 or CurrentMapID == 715 or CurrentMapID == 719)
            then
                if not ns.Addon.db.profile.showZoneBrokenIsles then
                    ns.Addon.db.profile.showZoneBrokenIsles = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneBrokenIsles = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            -- Zandalar    
            elseif (CurrentMapID == 862 or CurrentMapID == 863 or CurrentMapID == 864 or CurrentMapID == 1355 or CurrentMapID == 1528) 
            then
                if not ns.Addon.db.profile.showZoneZandalar then
                    ns.Addon.db.profile.showZoneZandalar = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneZandalar = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            -- Kul Tiras    
            elseif (CurrentMapID == 895 or CurrentMapID == 896 or CurrentMapID == 942 or CurrentMapID == 1462 or CurrentMapID == 1169) 
            then
                if not ns.Addon.db.profile.showZoneKulTiras then
                    ns.Addon.db.profile.showZoneKulTiras = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneKulTiras = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            -- Shadowlands    
            elseif (CurrentMapID == 1525 or CurrentMapID == 1533 or CurrentMapID == 1536 or CurrentMapID == 1543 or CurrentMapID == 1565 or CurrentMapID == 1816 or CurrentMapID == 1961
                or CurrentMapID == 1970 or CurrentMapID == 2016) 
            then
                if not ns.Addon.db.profile.showZoneShadowlands then
                    ns.Addon.db.profile.showZoneShadowlands = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneShadowlands = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            -- Dragon Isles    
            elseif (CurrentMapID == 2022 or CurrentMapID == 2023 or CurrentMapID == 2024 or CurrentMapID == 2025 or CurrentMapID == 2026 or CurrentMapID == 2133
                or CurrentMapID == 2151 or CurrentMapID == 2200 or CurrentMapID == 2239) 
            then
                if not ns.Addon.db.profile.showZoneDragonIsles then
                    ns.Addon.db.profile.showZoneDragonIsles = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Dragon Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneDragonIsles = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Dragon Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            -- Khaz Algar    
            elseif (CurrentMapID == 2248 or CurrentMapID == 2214 or CurrentMapID == 2215 or CurrentMapID == 2255 or CurrentMapID == 2256 or CurrentMapID == 2213
                or CurrentMapID == 2216 or CurrentMapID == 2369 or CurrentMapID == 2322 or CurrentMapID == 2346 or CurrentMapID == 2371 or CurrentMapID == 2472) 
            then
                if not ns.Addon.db.profile.showZoneKhazAlgar then
                    ns.Addon.db.profile.showZoneKhazAlgar = true
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Khaz Algar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                else
                    ns.Addon.db.profile.showZoneKhazAlgar = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Khaz Algar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                end
            end
        end

        -- Capitals without Sync function
        if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and (CurrentMapID == 1454 or CurrentMapID == 1456 -- Cata nodes
            or CurrentMapID == 2266 -- Millenia's Threshold
            or CurrentMapID == 2351 or CurrentMapID == 2352 -- Housing
            or CurrentMapID == 24 or CurrentMapID == 626 or CurrentMapID == 747 or CurrentMapID == 720 or CurrentMapID == 721 or CurrentMapID == 726 or CurrentMapID == 739 -- Legion Class Halls
            or CurrentMapID == 734 or CurrentMapID == 735 or CurrentMapID == 695 or CurrentMapID == 702 or CurrentMapID == 647 or CurrentMapID == 648 or CurrentMapID == 709 or CurrentMapID == 717 -- Legion Class Halls
            or CurrentMapID == 84 or CurrentMapID == 87 or CurrentMapID == 89 or CurrentMapID == 103 or CurrentMapID == 85
            or CurrentMapID == 90 or CurrentMapID == 86 or CurrentMapID == 88 or CurrentMapID == 110 or CurrentMapID == 111
            or CurrentMapID == 125 or CurrentMapID == 126 or CurrentMapID == 391 or CurrentMapID == 392 or CurrentMapID == 393 
            or CurrentMapID == 394 or CurrentMapID == 582 or CurrentMapID == 590 or CurrentMapID == 622 or CurrentMapID == 624 
            or CurrentMapID == 627 or CurrentMapID == 628 or CurrentMapID == 629 or CurrentMapID == 831 or CurrentMapID == 832 
            or CurrentMapID == 1161 or CurrentMapID == 1163 or CurrentMapID == 1164 or CurrentMapID == 1165 or CurrentMapID == 1670 
            or CurrentMapID == 1671 or CurrentMapID == 1672 or CurrentMapID == 1673 or CurrentMapID == 2112 or CurrentMapID == 407 
            or CurrentMapID == 2339 or CurrentMapID == 503 or CurrentMapID == 499 or CurrentMapID == 500 or CurrentMapID == 2322)
        then
        
            if not ns.Addon.db.profile.activate.Capitals then
                ns.Addon.db.profile.activate.Capitals = true
                if ns.Addon.db.profile.MmbWmbChatMessage then
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            else
                ns.Addon.db.profile.activate.Capitals = false
                if ns.Addon.db.profile.MmbWmbChatMessage then
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], L["icons"], "|cffff0000" .. L["are hidden"])
                end
            end
        end

        -- Capitals Sync function
        if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and (CurrentMapID == 1454 or CurrentMapID == 1456 -- Cata nodes
            or CurrentMapID == 2266 -- Millenia's Threshold
            or CurrentMapID == 2351 or CurrentMapID == 2352 -- Housing
            or CurrentMapID == 24 or CurrentMapID == 626 or CurrentMapID == 747 or CurrentMapID == 720 or CurrentMapID == 721 or CurrentMapID == 726 or CurrentMapID == 739 -- Legion Class Halls
            or CurrentMapID == 734 or CurrentMapID == 735 or CurrentMapID == 695 or CurrentMapID == 702 or CurrentMapID == 647 or CurrentMapID == 648 or CurrentMapID == 709 or CurrentMapID == 717 -- Legion Class Halls
            or CurrentMapID == 84 or CurrentMapID == 87 or CurrentMapID == 89 or CurrentMapID == 103 or CurrentMapID == 85
            or CurrentMapID == 90 or CurrentMapID == 86 or CurrentMapID == 88 or CurrentMapID == 110 or CurrentMapID == 111
            or CurrentMapID == 125 or CurrentMapID == 126 or CurrentMapID == 391 or CurrentMapID == 392 or CurrentMapID == 393 
            or CurrentMapID == 394 or CurrentMapID == 582 or CurrentMapID == 590 or CurrentMapID == 622 or CurrentMapID == 624 
            or CurrentMapID == 627 or CurrentMapID == 628 or CurrentMapID == 629 or CurrentMapID == 831 or CurrentMapID == 832 
            or CurrentMapID == 1161 or CurrentMapID == 1163 or CurrentMapID == 1164 or CurrentMapID == 1165 or CurrentMapID == 1670 
            or CurrentMapID == 1671 or CurrentMapID == 1672 or CurrentMapID == 1673 or CurrentMapID == 2112 or CurrentMapID == 407 
            or CurrentMapID == 2339 or CurrentMapID == 503 or CurrentMapID == 499 or CurrentMapID == 500 or CurrentMapID == 2322)
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
    ns.Addon:FullUpdate()
    HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end

function WorldMapOptionsButtonMixin:OnEnter()
local info = C_Map.GetMapInfo(WorldMapFrame:GetMapID())
local CurrentMapID = WorldMapFrame:GetMapID()

    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip_SetTitle(GameTooltip, ns.COLORED_ADDON_NAME)
    GameTooltip:AddLine(L["Left-click => Open/Close"] .. "|cffffcc00" .. " " .. ns.COLORED_ADDON_NAME,1,1,1)
    GameTooltip:AddLine(" ",1,1,1)
    GameTooltip:AddLine(KEY_BUTTON3 .. " => " .. "|cffffcc00" .. L["Disable MapNotes, all icons will be hidden on each map and all categories will be disabled"] .. " " .. SHOW .. " / " .. HIDE,1,1,1,1)
    GameTooltip:AddLine(" ",1,1,1)
    
    -- Cosmos Map
    if info.mapType == 0 then 
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. WORLDMAP_BUTTON .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end

    -- Azeroth World Map
    if info.mapType == 1 then
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. AZEROTH .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end    

    -- Continent Maps
    if info.mapType == 2 then 

        if CurrentMapID == 12 or CurrentMapID == 948 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Kalimdor"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif CurrentMapID == 13 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Eastern Kingdom"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif CurrentMapID == 101 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Outland"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif CurrentMapID == 113 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Northrend"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif CurrentMapID == 424 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Pandaria"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif CurrentMapID == 572 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Draenor"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif CurrentMapID == 619 or CurrentMapID == 905 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Broken Isles"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif CurrentMapID == 875 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Zandalar"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif CurrentMapID == 876 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Kul Tiras"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif CurrentMapID == 1550 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Shadowlands"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif CurrentMapID == 1978 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Dragon Isles"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif CurrentMapID == 2274 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Khaz Algar"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        end

    end
       
    -- Zones without Sync function
    if not ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 4 or info.mapType == 5 or info.mapType == 6) then
        --Kalimdor
        if (CurrentMapID == 1 or CurrentMapID == 7 or CurrentMapID == 10 or CurrentMapID == 11 or CurrentMapID == 57 or CurrentMapID == 62 
            or CurrentMapID == 63 or CurrentMapID == 64 or CurrentMapID == 65 or CurrentMapID == 66 or CurrentMapID == 67 or CurrentMapID == 68 
            or CurrentMapID == 69 or CurrentMapID == 70 or CurrentMapID == 71 or CurrentMapID == 74 or CurrentMapID == 75 or CurrentMapID == 76 
            or CurrentMapID == 77 or CurrentMapID == 78 or CurrentMapID == 80 or CurrentMapID == 81 or CurrentMapID == 83 or CurrentMapID == 97 
            or CurrentMapID == 106 or CurrentMapID == 199 or CurrentMapID == 327 or CurrentMapID == 460 or CurrentMapID == 461 or CurrentMapID == 462 
            or CurrentMapID == 468 or CurrentMapID == 1527 or CurrentMapID == 198 or CurrentMapID == 249)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kalimdor"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Eastern Kingdom
        elseif (CurrentMapID == 13 or CurrentMapID == 14 or CurrentMapID == 15 or CurrentMapID == 16 or CurrentMapID == 17 or CurrentMapID == 18 
            or CurrentMapID == 19 or CurrentMapID == 21 or CurrentMapID == 22 or CurrentMapID == 23 or CurrentMapID == 25 or CurrentMapID == 26 
            or CurrentMapID == 27 or CurrentMapID == 28 or CurrentMapID == 30 or CurrentMapID == 32 or CurrentMapID == 33 or CurrentMapID == 34 
            or CurrentMapID == 35 or CurrentMapID == 36 or CurrentMapID == 37 or CurrentMapID == 42 or CurrentMapID == 47 or CurrentMapID == 48 
            or CurrentMapID == 49 or CurrentMapID == 50 or CurrentMapID == 51 or CurrentMapID == 52 or CurrentMapID == 55 or CurrentMapID == 56 
            or CurrentMapID == 94 or CurrentMapID == 210 or CurrentMapID == 224 or CurrentMapID == 245 or CurrentMapID == 425 or CurrentMapID == 427 
            or CurrentMapID == 465 or CurrentMapID == 467 or CurrentMapID == 469 or CurrentMapID == 2070 
            or CurrentMapID == 241 or CurrentMapID == 203 or CurrentMapID == 204 or CurrentMapID == 205 or CurrentMapID == 241 or CurrentMapID == 244 
            or CurrentMapID == 245 or CurrentMapID == 201 or CurrentMapID == 95 or CurrentMapID == 122 or CurrentMapID == 217  or CurrentMapID == 226)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Eastern Kingdom"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()            
        --Outland
        elseif (CurrentMapID == 100 or CurrentMapID == 102 or CurrentMapID == 104 or CurrentMapID == 105 or CurrentMapID == 107 or CurrentMapID == 108
            or CurrentMapID == 109)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Outland"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()  
        --Northrend
        elseif (CurrentMapID == 114 or CurrentMapID == 115 or CurrentMapID == 116 or CurrentMapID == 117 or CurrentMapID == 118 or CurrentMapID == 119
            or CurrentMapID == 120 or CurrentMapID == 121 or CurrentMapID == 123 or CurrentMapID == 127 or CurrentMapID == 170)
        then 
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Northrend"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Pandaria
        elseif (CurrentMapID == 371 or CurrentMapID == 376 or CurrentMapID == 379 or CurrentMapID == 388 or CurrentMapID == 390 or CurrentMapID == 418
            or CurrentMapID == 422 or CurrentMapID == 433 or CurrentMapID == 434 or CurrentMapID == 504 or CurrentMapID == 554  or CurrentMapID == 1530
            or CurrentMapID == 507)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Pandaria"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Draenor
        elseif (CurrentMapID == 525 or CurrentMapID == 534 or CurrentMapID == 535 or CurrentMapID == 539 or CurrentMapID == 542 or CurrentMapID == 543
            or CurrentMapID == 550 or CurrentMapID == 588)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Draenor"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Broken Isles
        elseif (CurrentMapID == 630 or CurrentMapID == 634 or CurrentMapID == 641 or CurrentMapID == 646 or CurrentMapID == 650 or CurrentMapID == 652 or CurrentMapID == 659
            or CurrentMapID == 750 or CurrentMapID == 680 or CurrentMapID == 830 or CurrentMapID == 882 or CurrentMapID == 885 or CurrentMapID == 941 
            or CurrentMapID == 790 or CurrentMapID == 971 or CurrentMapID == 715 or CurrentMapID == 719)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Broken Isles"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Zandalar
        elseif (CurrentMapID == 862 or CurrentMapID == 863 or CurrentMapID == 864 or CurrentMapID == 1355 or CurrentMapID == 1528)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Zandalar"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --KulTiras
        elseif (CurrentMapID == 895 or CurrentMapID == 896 or CurrentMapID == 942 or CurrentMapID == 1462 or CurrentMapID == 1169)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kul Tiras"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Shadowlands
        elseif (CurrentMapID == 1525 or CurrentMapID == 1533 or CurrentMapID == 1536 or CurrentMapID == 1543 or CurrentMapID == 1565 or CurrentMapID == 1816 or CurrentMapID == 1961
            or CurrentMapID == 1970 or CurrentMapID == 2016)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Shadowlands"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Dragon Isle
        elseif (CurrentMapID == 2022 or CurrentMapID == 2023 or CurrentMapID == 2024 or CurrentMapID == 2025 or CurrentMapID == 2026 or CurrentMapID == 2133
            or CurrentMapID == 2151 or CurrentMapID == 2200 or CurrentMapID == 2239)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Dragon Isles"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Khaz Algar
        elseif (CurrentMapID == 2248 or CurrentMapID == 2214 or CurrentMapID == 2215 or CurrentMapID == 2255 or CurrentMapID == 2256 or CurrentMapID == 2213 
            or CurrentMapID == 2216 or CurrentMapID == 2369 or CurrentMapID == 2322 or CurrentMapID == 2346 or CurrentMapID == 2371 or CurrentMapID == 2472)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Khaz Algar"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        end
    end

    -- Zones Sync function
    if ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 4 or info.mapType == 5 or info.mapType == 6) then
        --Kalimdor
        if (CurrentMapID == 1 or CurrentMapID == 7 or CurrentMapID == 10 or CurrentMapID == 11 or CurrentMapID == 57 or CurrentMapID == 62 
            or CurrentMapID == 63 or CurrentMapID == 64 or CurrentMapID == 65 or CurrentMapID == 66 or CurrentMapID == 67 or CurrentMapID == 68 
            or CurrentMapID == 69 or CurrentMapID == 70 or CurrentMapID == 71 or CurrentMapID == 74 or CurrentMapID == 75 or CurrentMapID == 76 
            or CurrentMapID == 77 or CurrentMapID == 78 or CurrentMapID == 80 or CurrentMapID == 81 or CurrentMapID == 83 or CurrentMapID == 97 
            or CurrentMapID == 106 or CurrentMapID == 199 or CurrentMapID == 327 or CurrentMapID == 460 or CurrentMapID == 461 or CurrentMapID == 462 
            or CurrentMapID == 468 or CurrentMapID == 1527 or CurrentMapID == 198 or CurrentMapID == 249)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Eastern Kingdom
        elseif (CurrentMapID == 13 or CurrentMapID == 14 or CurrentMapID == 15 or CurrentMapID == 16 or CurrentMapID == 17 or CurrentMapID == 18 
            or CurrentMapID == 19 or CurrentMapID == 21 or CurrentMapID == 22 or CurrentMapID == 23 or CurrentMapID == 25 or CurrentMapID == 26 
            or CurrentMapID == 27 or CurrentMapID == 28 or CurrentMapID == 30 or CurrentMapID == 32 or CurrentMapID == 33 or CurrentMapID == 34 
            or CurrentMapID == 35 or CurrentMapID == 36 or CurrentMapID == 37 or CurrentMapID == 42 or CurrentMapID == 47 or CurrentMapID == 48 
            or CurrentMapID == 49 or CurrentMapID == 50 or CurrentMapID == 51 or CurrentMapID == 52 or CurrentMapID == 55 or CurrentMapID == 56 
            or CurrentMapID == 94 or CurrentMapID == 210 or CurrentMapID == 224 or CurrentMapID == 245 or CurrentMapID == 425 or CurrentMapID == 427 
            or CurrentMapID == 465 or CurrentMapID == 467 or CurrentMapID == 469 or CurrentMapID == 2070 
            or CurrentMapID == 241 or CurrentMapID == 203 or CurrentMapID == 204 or CurrentMapID == 205 or CurrentMapID == 241 or CurrentMapID == 244 
            or CurrentMapID == 245 or CurrentMapID == 201 or CurrentMapID == 95 or CurrentMapID == 122 or CurrentMapID == 217  or CurrentMapID == 226)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()        
        --Outland
        elseif (CurrentMapID == 100 or CurrentMapID == 102 or CurrentMapID == 104 or CurrentMapID == 105 or CurrentMapID == 107 or CurrentMapID == 108
            or CurrentMapID == 109)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Northrend
        elseif (CurrentMapID == 114 or CurrentMapID == 115 or CurrentMapID == 116 or CurrentMapID == 117 or CurrentMapID == 118 or CurrentMapID == 119
            or CurrentMapID == 120 or CurrentMapID == 121 or CurrentMapID == 123 or CurrentMapID == 127 or CurrentMapID == 170)
        then 
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Pandaria
        elseif (CurrentMapID == 371 or CurrentMapID == 376 or CurrentMapID == 379 or CurrentMapID == 388 or CurrentMapID == 390 or CurrentMapID == 418
            or CurrentMapID == 422 or CurrentMapID == 433 or CurrentMapID == 434 or CurrentMapID == 504 or CurrentMapID == 554  or CurrentMapID == 1530
            or CurrentMapID == 507)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Draenor
        elseif (CurrentMapID == 525 or CurrentMapID == 534 or CurrentMapID == 535 or CurrentMapID == 539 or CurrentMapID == 542 or CurrentMapID == 543
            or CurrentMapID == 550 or CurrentMapID == 588)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Broken Isles
        elseif (CurrentMapID == 630 or CurrentMapID == 634 or CurrentMapID == 641 or CurrentMapID == 646 or CurrentMapID == 650 or CurrentMapID == 652 or CurrentMapID == 659
            or CurrentMapID == 750 or CurrentMapID == 680 or CurrentMapID == 830 or CurrentMapID == 882 or CurrentMapID == 885 or CurrentMapID == 941 
            or CurrentMapID == 790 or CurrentMapID == 971 or CurrentMapID == 715 or CurrentMapID == 719)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Zandalar
        elseif (CurrentMapID == 862 or CurrentMapID == 863 or CurrentMapID == 864 or CurrentMapID == 1355 or CurrentMapID == 1528)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --KulTiras
        elseif (CurrentMapID == 895 or CurrentMapID == 896 or CurrentMapID == 942 or CurrentMapID == 1462 or CurrentMapID == 1169)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Shadowlands
        elseif (CurrentMapID == 1525 or CurrentMapID == 1533 or CurrentMapID == 1536 or CurrentMapID == 1543 or CurrentMapID == 1565 or CurrentMapID == 1816 or CurrentMapID == 1961
            or CurrentMapID == 1970 or CurrentMapID == 2016)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Dragon Isle
        elseif (CurrentMapID == 2022 or CurrentMapID == 2023 or CurrentMapID == 2024 or CurrentMapID == 2025 or CurrentMapID == 2026 or CurrentMapID == 2133
            or CurrentMapID == 2151 or CurrentMapID == 2200 or CurrentMapID == 2239)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Dragon Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Khaz Algar
        elseif (CurrentMapID == 2248 or CurrentMapID == 2214 or CurrentMapID == 2215 or CurrentMapID == 2255 or CurrentMapID == 2256 or CurrentMapID == 2213 
            or CurrentMapID == 2216 or CurrentMapID == 2369 or CurrentMapID == 2322 or CurrentMapID == 2346 or CurrentMapID == 2371 or CurrentMapID == 2472)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Khaz Algar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        end
    end

    -- Dungeon Maps
    if info.mapType == 4 and not 
            (CurrentMapID == 1454 or CurrentMapID == 1456 -- Cata nodes
            or CurrentMapID == 719  -- Mardum
            or CurrentMapID == 2266 -- Millenias's Threshold
            or CurrentMapID == 24 or CurrentMapID == 626 or CurrentMapID == 747 or CurrentMapID == 720 or CurrentMapID == 721 or CurrentMapID == 726 or CurrentMapID == 739 -- Legion Class Halls
            or CurrentMapID == 734 or CurrentMapID == 735 or CurrentMapID == 695 or CurrentMapID == 702 or CurrentMapID == 647 or CurrentMapID == 648 or CurrentMapID == 709 or CurrentMapID == 717 -- Legion Class Halls
            or CurrentMapID == 84 or CurrentMapID == 87 or CurrentMapID == 89 or CurrentMapID == 103 or CurrentMapID == 85
            or CurrentMapID == 90 or CurrentMapID == 86 or CurrentMapID == 88 or CurrentMapID == 110 or CurrentMapID == 111
            or CurrentMapID == 125 or CurrentMapID == 126 or CurrentMapID == 391 or CurrentMapID == 392 or CurrentMapID == 393 
            or CurrentMapID == 394 or CurrentMapID == 582 or CurrentMapID == 590 or CurrentMapID == 622 or CurrentMapID == 624 
            or CurrentMapID == 627 or CurrentMapID == 628 or CurrentMapID == 629 or CurrentMapID == 831 or CurrentMapID == 832 
            or CurrentMapID == 1161 or CurrentMapID == 1163 or CurrentMapID == 1164 or CurrentMapID == 1165 or CurrentMapID == 1670 
            or CurrentMapID == 1671 or CurrentMapID == 1672 or CurrentMapID == 1673 or CurrentMapID == 2112 or CurrentMapID == 407 
            or CurrentMapID == 2339 or CurrentMapID == 503 or CurrentMapID == 499 or CurrentMapID == 500 or CurrentMapID == 2322)
    then
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. DUNGEONS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end

    -- Capitals without Sync function
    if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and 
            (CurrentMapID == 1454 or CurrentMapID == 1456 -- Cata nodes
            or CurrentMapID == 2266 -- Millenia's Threshold
            or CurrentMapID == 2351 or CurrentMapID == 2352 -- Housing
            or CurrentMapID == 24 or CurrentMapID == 626 or CurrentMapID == 747 or CurrentMapID == 720 or CurrentMapID == 721 or CurrentMapID == 726 or CurrentMapID == 739 -- Legion Class Halls
            or CurrentMapID == 734 or CurrentMapID == 735 or CurrentMapID == 695 or CurrentMapID == 702 or CurrentMapID == 647 or CurrentMapID == 648 or CurrentMapID == 709 or CurrentMapID == 717 -- Legion Class Halls
            or CurrentMapID == 84 or CurrentMapID == 87 or CurrentMapID == 89 or CurrentMapID == 103 or CurrentMapID == 85
            or CurrentMapID == 90 or CurrentMapID == 86 or CurrentMapID == 88 or CurrentMapID == 110 or CurrentMapID == 111
            or CurrentMapID == 125 or CurrentMapID == 126 or CurrentMapID == 391 or CurrentMapID == 392 or CurrentMapID == 393 
            or CurrentMapID == 394 or CurrentMapID == 582 or CurrentMapID == 590 or CurrentMapID == 622 or CurrentMapID == 624 
            or CurrentMapID == 627 or CurrentMapID == 628 or CurrentMapID == 629 or CurrentMapID == 831 or CurrentMapID == 832 
            or CurrentMapID == 1161 or CurrentMapID == 1163 or CurrentMapID == 1164 or CurrentMapID == 1165 or CurrentMapID == 1670 
            or CurrentMapID == 1671 or CurrentMapID == 1672 or CurrentMapID == 1673 or CurrentMapID == 2112 or CurrentMapID == 407 
            or CurrentMapID == 2339 or CurrentMapID == 503 or CurrentMapID == 499 or CurrentMapID == 500 or CurrentMapID == 2322)
    then
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Capitals"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end

    -- Capitals Sync function
    if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and 
            (CurrentMapID == 1454 or CurrentMapID == 1456 -- Cata nodes
            or CurrentMapID == 2266 -- Millenia's Threshold
            or CurrentMapID == 2351 or CurrentMapID == 2352 -- Housing
            or CurrentMapID == 24 or CurrentMapID == 626 or CurrentMapID == 747 or CurrentMapID == 720 or CurrentMapID == 721 or CurrentMapID == 726 or CurrentMapID == 739 -- Legion Class Halls
            or CurrentMapID == 734 or CurrentMapID == 735 or CurrentMapID == 695 or CurrentMapID == 702 or CurrentMapID == 647 or CurrentMapID == 648 or CurrentMapID == 709 or CurrentMapID == 717 -- Legion Class Halls
            or CurrentMapID == 84 or CurrentMapID == 87 or CurrentMapID == 89 or CurrentMapID == 103 or CurrentMapID == 85
            or CurrentMapID == 90 or CurrentMapID == 86 or CurrentMapID == 88 or CurrentMapID == 110 or CurrentMapID == 111
            or CurrentMapID == 125 or CurrentMapID == 126 or CurrentMapID == 391 or CurrentMapID == 392 or CurrentMapID == 393 
            or CurrentMapID == 394 or CurrentMapID == 582 or CurrentMapID == 590 or CurrentMapID == 622 or CurrentMapID == 624 
            or CurrentMapID == 627 or CurrentMapID == 628 or CurrentMapID == 629 or CurrentMapID == 831 or CurrentMapID == 832 
            or CurrentMapID == 1161 or CurrentMapID == 1163 or CurrentMapID == 1164 or CurrentMapID == 1165 or CurrentMapID == 1670 
            or CurrentMapID == 1671 or CurrentMapID == 1672 or CurrentMapID == 1673 or CurrentMapID == 2112 or CurrentMapID == 407 
            or CurrentMapID == 2339 or CurrentMapID == 503 or CurrentMapID == 499 or CurrentMapID == 500 or CurrentMapID == 2322)
    then
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end
end

function WorldMapOptionsButtonMixin:OnMouseDown(button)
    self.Icon:SetPoint('TOPLEFT', 8, -8)
end


function WorldMapOptionsButtonMixin:OnMouseUp()
    self.Icon:SetPoint('TOPLEFT', self, 'TOPLEFT', 6, -6)
end

function WorldMapOptionsButtonMixin:Refresh()

end