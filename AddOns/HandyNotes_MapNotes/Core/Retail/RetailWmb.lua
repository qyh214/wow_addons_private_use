local ADDON_NAME, ns = ...

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local WorldMapOptionsButtonMixin = {}
_G[ADDON_NAME .. 'WorldMapOptionsButtonMixin'] = WorldMapOptionsButtonMixin

function WorldMapOptionsButtonMixin:OnLoad()

end


function WorldMapOptionsButtonMixin:OnClick(button)
local info = C_Map.GetMapInfo(WorldMapFrame:GetMapID())
local GetCurrentMapID = WorldMapFrame:GetMapID()

    if button == "LeftButton" then

        if not LibStub("AceConfigDialog-3.0"):Close("MapNotes") then
            LibStub("AceConfigDialog-3.0"):Open("MapNotes")
        end 

    end

    if button == "MiddleButton" then

        if not ns.Addon.db.profile.activate.HideMapNote then
            ns.Addon.db.profile.activate.HideMapNote = true
            if ns.Addon.db.profile.MmbWmbChatMessage then
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffff0000", L["All MapNotes icons have been hidden"])
            end
        else
            ns.Addon.db.profile.activate.HideMapNote = false
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

            if GetCurrentMapID == 12 or GetCurrentMapID == 948 then
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
            elseif GetCurrentMapID == 13 then
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
            elseif GetCurrentMapID == 101 then
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
            elseif GetCurrentMapID == 113 then
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
            elseif GetCurrentMapID == 424 then
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
            elseif GetCurrentMapID == 572 then
                if ns.Addon.db.profile.showContinentDraenor then
                    ns.Addon.db.profile.showContinentDraenor = false
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Draenor"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentDraenor = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Draenor"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif GetCurrentMapID == 619 or GetCurrentMapID == 905 then
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
            elseif GetCurrentMapID == 875 then
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
            elseif GetCurrentMapID == 876 then
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
            elseif GetCurrentMapID == 1550 then
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
            elseif GetCurrentMapID == 1978 then
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
            elseif GetCurrentMapID == 2274 then
                if ns.Addon.db.profile.showContinentKhazAlgar then
                    ns.Addon.db.profile.showContinentKhazAlgar = false
                        WorldMapFrame:Hide()
                        OpenWorldMap(uiMapID)
                        WorldMapFrame:SetMapID(2274)
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Khaz Algar"], L["icons"], "|cffff0000" .. L["are hidden"])
                    end
                else
                    ns.Addon.db.profile.showContinentKhazAlgar = true
                    WorldMapFrame:Hide()
                    OpenWorldMap(uiMapID)
                    WorldMapFrame:SetMapID(2274)
                    if ns.Addon.db.profile.MmbWmbChatMessage then
                        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Khaz Algar"], L["icons"], "|cff00ff00" .. L["are shown"])
                    end
                end
            end

        end

        -- Dungeon Maps
        if info.mapType == 4 and not 
            (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 --Cata nodes
            or GetCurrentMapID == 2266 -- Milleania's Threshold
            or GetCurrentMapID == 84 or GetCurrentMapID == 87 or GetCurrentMapID == 89 or GetCurrentMapID == 103 or GetCurrentMapID == 85
            or GetCurrentMapID == 90 or GetCurrentMapID == 86 or GetCurrentMapID == 88 or GetCurrentMapID == 110 or GetCurrentMapID == 111
            or GetCurrentMapID == 125 or GetCurrentMapID == 126 or GetCurrentMapID == 391 or GetCurrentMapID == 392 or GetCurrentMapID == 393 
            or GetCurrentMapID == 394 or GetCurrentMapID == 582 or GetCurrentMapID == 590 or GetCurrentMapID == 622 or GetCurrentMapID == 624 
            or GetCurrentMapID == 626 or GetCurrentMapID == 627 or GetCurrentMapID == 628 or GetCurrentMapID == 629 or GetCurrentMapID == 831 or GetCurrentMapID == 832 
            or GetCurrentMapID == 1161 or GetCurrentMapID == 1163 or GetCurrentMapID == 1164 or GetCurrentMapID == 1165 or GetCurrentMapID == 1670 
            or GetCurrentMapID == 1671 or GetCurrentMapID == 1672 or GetCurrentMapID == 1673 or GetCurrentMapID == 2112 or GetCurrentMapID == 407 
            or GetCurrentMapID == 2339 or GetCurrentMapID == 503 or GetCurrentMapID == 499 or GetCurrentMapID == 500 or GetCurrentMapID == 2322 
            or GetCurrentMapID == 2346)
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
            if (GetCurrentMapID == 1 or GetCurrentMapID == 7 or GetCurrentMapID == 10 or GetCurrentMapID == 11 or GetCurrentMapID == 57 or GetCurrentMapID == 62 
                or GetCurrentMapID == 63 or GetCurrentMapID == 64 or GetCurrentMapID == 65 or GetCurrentMapID == 66 or GetCurrentMapID == 67 or GetCurrentMapID == 68 
                or GetCurrentMapID == 69 or GetCurrentMapID == 70 or GetCurrentMapID == 71 or GetCurrentMapID == 74 or GetCurrentMapID == 75 or GetCurrentMapID == 76 
                or GetCurrentMapID == 77 or GetCurrentMapID == 78 or GetCurrentMapID == 80 or GetCurrentMapID == 81 or GetCurrentMapID == 83 or GetCurrentMapID == 97 
                or GetCurrentMapID == 106 or GetCurrentMapID == 199 or GetCurrentMapID == 327 or GetCurrentMapID == 460 or GetCurrentMapID == 461 or GetCurrentMapID == 462 
                or GetCurrentMapID == 468 or GetCurrentMapID == 1527 or GetCurrentMapID == 198 or GetCurrentMapID == 249)
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
            elseif (GetCurrentMapID == 13 or GetCurrentMapID == 14 or GetCurrentMapID == 15 or GetCurrentMapID == 16 or GetCurrentMapID == 17 or GetCurrentMapID == 18 
                or GetCurrentMapID == 19 or GetCurrentMapID == 21 or GetCurrentMapID == 22 or GetCurrentMapID == 23 or GetCurrentMapID == 25 or GetCurrentMapID == 26 
                or GetCurrentMapID == 27 or GetCurrentMapID == 28 or GetCurrentMapID == 30 or GetCurrentMapID == 32 or GetCurrentMapID == 33 or GetCurrentMapID == 34 
                or GetCurrentMapID == 35 or GetCurrentMapID == 36 or GetCurrentMapID == 37 or GetCurrentMapID == 42 or GetCurrentMapID == 47 or GetCurrentMapID == 48 
                or GetCurrentMapID == 49 or GetCurrentMapID == 50 or GetCurrentMapID == 51 or GetCurrentMapID == 52 or GetCurrentMapID == 55 or GetCurrentMapID == 56 
                or GetCurrentMapID == 94 or GetCurrentMapID == 210 or GetCurrentMapID == 224 or GetCurrentMapID == 245 or GetCurrentMapID == 425 or GetCurrentMapID == 427 
                or GetCurrentMapID == 465 or GetCurrentMapID == 467 or GetCurrentMapID == 469 or GetCurrentMapID == 2070 
                or GetCurrentMapID == 241 or GetCurrentMapID == 203 or GetCurrentMapID == 204 or GetCurrentMapID == 205 or GetCurrentMapID == 241 or GetCurrentMapID == 244 
                or GetCurrentMapID == 245 or GetCurrentMapID == 201 or GetCurrentMapID == 95 or GetCurrentMapID == 122 or GetCurrentMapID == 217  or GetCurrentMapID == 226)
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
            elseif (GetCurrentMapID == 100 or GetCurrentMapID == 102 or GetCurrentMapID == 104 or GetCurrentMapID == 105 or GetCurrentMapID == 107 or GetCurrentMapID == 108
                or GetCurrentMapID == 109)
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
            elseif (GetCurrentMapID == 114 or GetCurrentMapID == 115 or GetCurrentMapID == 116 or GetCurrentMapID == 117 or GetCurrentMapID == 118 or GetCurrentMapID == 119
                or GetCurrentMapID == 120 or GetCurrentMapID == 121 or GetCurrentMapID == 123 or GetCurrentMapID == 127 or GetCurrentMapID == 170)
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
            elseif (GetCurrentMapID == 371 or GetCurrentMapID == 376 or GetCurrentMapID == 379 or GetCurrentMapID == 388 or GetCurrentMapID == 390 or GetCurrentMapID == 418
                or GetCurrentMapID == 422 or GetCurrentMapID == 433 or GetCurrentMapID == 434 or GetCurrentMapID == 504 or GetCurrentMapID == 554  or GetCurrentMapID == 1530
                or GetCurrentMapID == 507)
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
            elseif (GetCurrentMapID == 525 or GetCurrentMapID == 534 or GetCurrentMapID == 535 or GetCurrentMapID == 539 or GetCurrentMapID == 542 or GetCurrentMapID == 543
                or GetCurrentMapID == 550 or GetCurrentMapID == 588)
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
            elseif (GetCurrentMapID == 630 or GetCurrentMapID == 634 or GetCurrentMapID == 641 or GetCurrentMapID == 646 or GetCurrentMapID == 650 or GetCurrentMapID == 652
                or GetCurrentMapID == 750 or GetCurrentMapID == 680 or GetCurrentMapID == 830 or GetCurrentMapID == 882 or GetCurrentMapID == 885 or GetCurrentMapID == 941 
                or GetCurrentMapID == 790 or GetCurrentMapID == 971)
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
            elseif (GetCurrentMapID == 862 or GetCurrentMapID == 863 or GetCurrentMapID == 864 or GetCurrentMapID == 1355 or GetCurrentMapID == 1528)
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
            elseif (GetCurrentMapID == 895 or GetCurrentMapID == 896 or GetCurrentMapID == 942 or GetCurrentMapID == 1462 or GetCurrentMapID == 1169)
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
            elseif (GetCurrentMapID == 1525 or GetCurrentMapID == 1533 or GetCurrentMapID == 1536 or GetCurrentMapID == 1543 or GetCurrentMapID == 1565 or GetCurrentMapID == 1961
                or GetCurrentMapID == 1970 or GetCurrentMapID == 2016)
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
            elseif (GetCurrentMapID == 2022 or GetCurrentMapID == 2023 or GetCurrentMapID == 2024 or GetCurrentMapID == 2025 or GetCurrentMapID == 2026 or GetCurrentMapID == 2133
                or GetCurrentMapID == 2151 or GetCurrentMapID == 2200 or GetCurrentMapID == 2239)
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
            elseif (GetCurrentMapID == 2248 or GetCurrentMapID == 2214 or GetCurrentMapID == 2215 or GetCurrentMapID == 2255 or GetCurrentMapID == 2256 or GetCurrentMapID == 2213 
                or GetCurrentMapID == 2216 or GetCurrentMapID == 2369 or GetCurrentMapID == 2322 or GetCurrentMapID == 2346 or GetCurrentMapID == 2371 or GetCurrentMapID == 2472)
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
            if (GetCurrentMapID == 1 or GetCurrentMapID == 7 or GetCurrentMapID == 10 or GetCurrentMapID == 11 or GetCurrentMapID == 57 or GetCurrentMapID == 62 
                or GetCurrentMapID == 63 or GetCurrentMapID == 64 or GetCurrentMapID == 65 or GetCurrentMapID == 66 or GetCurrentMapID == 67 or GetCurrentMapID == 68 
                or GetCurrentMapID == 69 or GetCurrentMapID == 70 or GetCurrentMapID == 71 or GetCurrentMapID == 74 or GetCurrentMapID == 75 or GetCurrentMapID == 76 
                or GetCurrentMapID == 77 or GetCurrentMapID == 78 or GetCurrentMapID == 80 or GetCurrentMapID == 81 or GetCurrentMapID == 83 or GetCurrentMapID == 97 
                or GetCurrentMapID == 106 or GetCurrentMapID == 199 or GetCurrentMapID == 327 or GetCurrentMapID == 460 or GetCurrentMapID == 461 or GetCurrentMapID == 462 
                or GetCurrentMapID == 468 or GetCurrentMapID == 1527 or GetCurrentMapID == 198 or GetCurrentMapID == 249)
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
            elseif (GetCurrentMapID == 13 or GetCurrentMapID == 14 or GetCurrentMapID == 15 or GetCurrentMapID == 16 or GetCurrentMapID == 17 or GetCurrentMapID == 18 
                or GetCurrentMapID == 19 or GetCurrentMapID == 21 or GetCurrentMapID == 22 or GetCurrentMapID == 23 or GetCurrentMapID == 25 or GetCurrentMapID == 26 
                or GetCurrentMapID == 27 or GetCurrentMapID == 28 or GetCurrentMapID == 30 or GetCurrentMapID == 32 or GetCurrentMapID == 33 or GetCurrentMapID == 34 
                or GetCurrentMapID == 35 or GetCurrentMapID == 36 or GetCurrentMapID == 37 or GetCurrentMapID == 42 or GetCurrentMapID == 47 or GetCurrentMapID == 48 
                or GetCurrentMapID == 49 or GetCurrentMapID == 50 or GetCurrentMapID == 51 or GetCurrentMapID == 52 or GetCurrentMapID == 55 or GetCurrentMapID == 56 
                or GetCurrentMapID == 94 or GetCurrentMapID == 210 or GetCurrentMapID == 224 or GetCurrentMapID == 245 or GetCurrentMapID == 425 or GetCurrentMapID == 427 
                or GetCurrentMapID == 465 or GetCurrentMapID == 467 or GetCurrentMapID == 469 or GetCurrentMapID == 2070 
                or GetCurrentMapID == 241 or GetCurrentMapID == 203 or GetCurrentMapID == 204 or GetCurrentMapID == 205 or GetCurrentMapID == 241 or GetCurrentMapID == 244 
                or GetCurrentMapID == 245 or GetCurrentMapID == 201 or GetCurrentMapID == 95 or GetCurrentMapID == 122 or GetCurrentMapID == 217  or GetCurrentMapID == 226) 
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
            elseif (GetCurrentMapID == 100 or GetCurrentMapID == 102 or GetCurrentMapID == 104 or GetCurrentMapID == 105 or GetCurrentMapID == 107 or GetCurrentMapID == 108
                or GetCurrentMapID == 109) 
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
            elseif (GetCurrentMapID == 114 or GetCurrentMapID == 115 or GetCurrentMapID == 116 or GetCurrentMapID == 117 or GetCurrentMapID == 118 or GetCurrentMapID == 119
                or GetCurrentMapID == 120 or GetCurrentMapID == 121 or GetCurrentMapID == 123 or GetCurrentMapID == 127 or GetCurrentMapID == 170) 
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
            elseif (GetCurrentMapID == 371 or GetCurrentMapID == 376 or GetCurrentMapID == 379 or GetCurrentMapID == 388 or GetCurrentMapID == 390 or GetCurrentMapID == 418
                or GetCurrentMapID == 422 or GetCurrentMapID == 433 or GetCurrentMapID == 434 or GetCurrentMapID == 504 or GetCurrentMapID == 554  or GetCurrentMapID == 1530
                or GetCurrentMapID == 507) 
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
            elseif (GetCurrentMapID == 525 or GetCurrentMapID == 534 or GetCurrentMapID == 535 or GetCurrentMapID == 539 or GetCurrentMapID == 542 or GetCurrentMapID == 543
                or GetCurrentMapID == 550 or GetCurrentMapID == 588) 
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
            elseif (GetCurrentMapID == 630 or GetCurrentMapID == 634 or GetCurrentMapID == 641 or GetCurrentMapID == 646 or GetCurrentMapID == 650 or GetCurrentMapID == 652
                or GetCurrentMapID == 750 or GetCurrentMapID == 680 or GetCurrentMapID == 830 or GetCurrentMapID == 882 or GetCurrentMapID == 885 or GetCurrentMapID == 941 
                or GetCurrentMapID == 790 or GetCurrentMapID == 971) 
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
            elseif (GetCurrentMapID == 862 or GetCurrentMapID == 863 or GetCurrentMapID == 864 or GetCurrentMapID == 1355 or GetCurrentMapID == 1528) 
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
            elseif (GetCurrentMapID == 895 or GetCurrentMapID == 896 or GetCurrentMapID == 942 or GetCurrentMapID == 1462 or GetCurrentMapID == 1169) 
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
            elseif (GetCurrentMapID == 1525 or GetCurrentMapID == 1533 or GetCurrentMapID == 1536 or GetCurrentMapID == 1543 or GetCurrentMapID == 1565 or GetCurrentMapID == 1961
                or GetCurrentMapID == 1970 or GetCurrentMapID == 2016) 
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
            elseif (GetCurrentMapID == 2022 or GetCurrentMapID == 2023 or GetCurrentMapID == 2024 or GetCurrentMapID == 2025 or GetCurrentMapID == 2026 or GetCurrentMapID == 2133
                or GetCurrentMapID == 2151 or GetCurrentMapID == 2200 or GetCurrentMapID == 2239) 
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
            elseif (GetCurrentMapID == 2248 or GetCurrentMapID == 2214 or GetCurrentMapID == 2215 or GetCurrentMapID == 2255 or GetCurrentMapID == 2256 or GetCurrentMapID == 2213
                or GetCurrentMapID == 2216 or GetCurrentMapID == 2369 or GetCurrentMapID == 2322 or GetCurrentMapID == 2346 or GetCurrentMapID == 2371 or GetCurrentMapID == 2472) 
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
        if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 -- Cata nodes
            or GetCurrentMapID == 2266 -- Millenia's Threshold
            or GetCurrentMapID == 84 or GetCurrentMapID == 87 or GetCurrentMapID == 89 or GetCurrentMapID == 103 or GetCurrentMapID == 85
            or GetCurrentMapID == 90 or GetCurrentMapID == 86 or GetCurrentMapID == 88 or GetCurrentMapID == 110 or GetCurrentMapID == 111
            or GetCurrentMapID == 125 or GetCurrentMapID == 126 or GetCurrentMapID == 391 or GetCurrentMapID == 392 or GetCurrentMapID == 393 
            or GetCurrentMapID == 394 or GetCurrentMapID == 582 or GetCurrentMapID == 590 or GetCurrentMapID == 622 or GetCurrentMapID == 624 
            or GetCurrentMapID == 626 or GetCurrentMapID == 627 or GetCurrentMapID == 628 or GetCurrentMapID == 629 or GetCurrentMapID == 831 or GetCurrentMapID == 832 
            or GetCurrentMapID == 1161 or GetCurrentMapID == 1163 or GetCurrentMapID == 1164 or GetCurrentMapID == 1165 or GetCurrentMapID == 1670 
            or GetCurrentMapID == 1671 or GetCurrentMapID == 1672 or GetCurrentMapID == 1673 or GetCurrentMapID == 2112 or GetCurrentMapID == 407 
            or GetCurrentMapID == 2339 or GetCurrentMapID == 503 or GetCurrentMapID == 499 or GetCurrentMapID == 500 or GetCurrentMapID == 2322 
            or GetCurrentMapID == 2346)
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
        if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 -- Cata nodes
            or GetCurrentMapID == 2266 -- Millenia's Threshold
            or GetCurrentMapID == 84 or GetCurrentMapID == 87 or GetCurrentMapID == 89 or GetCurrentMapID == 103 or GetCurrentMapID == 85
            or GetCurrentMapID == 90 or GetCurrentMapID == 86 or GetCurrentMapID == 88 or GetCurrentMapID == 110 or GetCurrentMapID == 111
            or GetCurrentMapID == 125 or GetCurrentMapID == 126 or GetCurrentMapID == 391 or GetCurrentMapID == 392 or GetCurrentMapID == 393 
            or GetCurrentMapID == 394 or GetCurrentMapID == 582 or GetCurrentMapID == 590 or GetCurrentMapID == 622 or GetCurrentMapID == 624 
            or GetCurrentMapID == 626 or GetCurrentMapID == 627 or GetCurrentMapID == 628 or GetCurrentMapID == 629 or GetCurrentMapID == 831 or GetCurrentMapID == 832 
            or GetCurrentMapID == 1161 or GetCurrentMapID == 1163 or GetCurrentMapID == 1164 or GetCurrentMapID == 1165 or GetCurrentMapID == 1670 
            or GetCurrentMapID == 1671 or GetCurrentMapID == 1672 or GetCurrentMapID == 1673 or GetCurrentMapID == 2112 or GetCurrentMapID == 407 
            or GetCurrentMapID == 2339 or GetCurrentMapID == 503 or GetCurrentMapID == 499 or GetCurrentMapID == 500 or GetCurrentMapID == 2322 
            or GetCurrentMapID == 2346) 
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
local GetCurrentMapID = WorldMapFrame:GetMapID()

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

        if GetCurrentMapID == 12 or GetCurrentMapID == 948 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Kalimdor"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif GetCurrentMapID == 13 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Eastern Kingdom"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif GetCurrentMapID == 101 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Outland"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif GetCurrentMapID == 113 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Northrend"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif GetCurrentMapID == 424 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Pandaria"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif GetCurrentMapID == 572 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Draenor"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif GetCurrentMapID == 619 or GetCurrentMapID == 905 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Broken Isles"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif GetCurrentMapID == 875 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Zandalar"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif GetCurrentMapID == 876 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Kul Tiras"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif GetCurrentMapID == 1550 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Shadowlands"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif GetCurrentMapID == 1978 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Dragon Isles"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif GetCurrentMapID == 2274 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Khaz Algar"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        end

    end
       
    -- Zones without Sync function
    if not ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 4 or info.mapType == 5 or info.mapType == 6) then
        --Kalimdor
        if (GetCurrentMapID == 1 or GetCurrentMapID == 7 or GetCurrentMapID == 10 or GetCurrentMapID == 11 or GetCurrentMapID == 57 or GetCurrentMapID == 62 
            or GetCurrentMapID == 63 or GetCurrentMapID == 64 or GetCurrentMapID == 65 or GetCurrentMapID == 66 or GetCurrentMapID == 67 or GetCurrentMapID == 68 
            or GetCurrentMapID == 69 or GetCurrentMapID == 70 or GetCurrentMapID == 71 or GetCurrentMapID == 74 or GetCurrentMapID == 75 or GetCurrentMapID == 76 
            or GetCurrentMapID == 77 or GetCurrentMapID == 78 or GetCurrentMapID == 80 or GetCurrentMapID == 81 or GetCurrentMapID == 83 or GetCurrentMapID == 97 
            or GetCurrentMapID == 106 or GetCurrentMapID == 199 or GetCurrentMapID == 327 or GetCurrentMapID == 460 or GetCurrentMapID == 461 or GetCurrentMapID == 462 
            or GetCurrentMapID == 468 or GetCurrentMapID == 1527 or GetCurrentMapID == 198 or GetCurrentMapID == 249)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kalimdor"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Eastern Kingdom
        elseif (GetCurrentMapID == 13 or GetCurrentMapID == 14 or GetCurrentMapID == 15 or GetCurrentMapID == 16 or GetCurrentMapID == 17 or GetCurrentMapID == 18 
            or GetCurrentMapID == 19 or GetCurrentMapID == 21 or GetCurrentMapID == 22 or GetCurrentMapID == 23 or GetCurrentMapID == 25 or GetCurrentMapID == 26 
            or GetCurrentMapID == 27 or GetCurrentMapID == 28 or GetCurrentMapID == 30 or GetCurrentMapID == 32 or GetCurrentMapID == 33 or GetCurrentMapID == 34 
            or GetCurrentMapID == 35 or GetCurrentMapID == 36 or GetCurrentMapID == 37 or GetCurrentMapID == 42 or GetCurrentMapID == 47 or GetCurrentMapID == 48 
            or GetCurrentMapID == 49 or GetCurrentMapID == 50 or GetCurrentMapID == 51 or GetCurrentMapID == 52 or GetCurrentMapID == 55 or GetCurrentMapID == 56 
            or GetCurrentMapID == 94 or GetCurrentMapID == 210 or GetCurrentMapID == 224 or GetCurrentMapID == 245 or GetCurrentMapID == 425 or GetCurrentMapID == 427 
            or GetCurrentMapID == 465 or GetCurrentMapID == 467 or GetCurrentMapID == 469 or GetCurrentMapID == 2070 
            or GetCurrentMapID == 241 or GetCurrentMapID == 203 or GetCurrentMapID == 204 or GetCurrentMapID == 205 or GetCurrentMapID == 241 or GetCurrentMapID == 244 
            or GetCurrentMapID == 245 or GetCurrentMapID == 201 or GetCurrentMapID == 95 or GetCurrentMapID == 122 or GetCurrentMapID == 217  or GetCurrentMapID == 226)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Eastern Kingdom"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()            
        --Outland
        elseif (GetCurrentMapID == 100 or GetCurrentMapID == 102 or GetCurrentMapID == 104 or GetCurrentMapID == 105 or GetCurrentMapID == 107 or GetCurrentMapID == 108
            or GetCurrentMapID == 109)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Outland"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()  
        --Northrend
        elseif (GetCurrentMapID == 114 or GetCurrentMapID == 115 or GetCurrentMapID == 116 or GetCurrentMapID == 117 or GetCurrentMapID == 118 or GetCurrentMapID == 119
            or GetCurrentMapID == 120 or GetCurrentMapID == 121 or GetCurrentMapID == 123 or GetCurrentMapID == 127 or GetCurrentMapID == 170)
        then 
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Northrend"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Pandaria
        elseif (GetCurrentMapID == 371 or GetCurrentMapID == 376 or GetCurrentMapID == 379 or GetCurrentMapID == 388 or GetCurrentMapID == 390 or GetCurrentMapID == 418
            or GetCurrentMapID == 422 or GetCurrentMapID == 433 or GetCurrentMapID == 434 or GetCurrentMapID == 504 or GetCurrentMapID == 554  or GetCurrentMapID == 1530
            or GetCurrentMapID == 507)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Pandaria"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Draenor
        elseif (GetCurrentMapID == 525 or GetCurrentMapID == 534 or GetCurrentMapID == 535 or GetCurrentMapID == 539 or GetCurrentMapID == 542 or GetCurrentMapID == 543
            or GetCurrentMapID == 550 or GetCurrentMapID == 588)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Draenor"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Broken Isles
        elseif (GetCurrentMapID == 630 or GetCurrentMapID == 634 or GetCurrentMapID == 641 or GetCurrentMapID == 646 or GetCurrentMapID == 650 or GetCurrentMapID == 652
            or GetCurrentMapID == 750 or GetCurrentMapID == 680 or GetCurrentMapID == 830 or GetCurrentMapID == 882 or GetCurrentMapID == 885 or GetCurrentMapID == 941 
            or GetCurrentMapID == 790 or GetCurrentMapID == 971)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Broken Isles"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Zandalar
        elseif (GetCurrentMapID == 862 or GetCurrentMapID == 863 or GetCurrentMapID == 864 or GetCurrentMapID == 1355 or GetCurrentMapID == 1528)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Zandalar"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --KulTiras
        elseif (GetCurrentMapID == 895 or GetCurrentMapID == 896 or GetCurrentMapID == 942 or GetCurrentMapID == 1462 or GetCurrentMapID == 1169)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kul Tiras"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Shadowlands
        elseif(GetCurrentMapID == 1525 or GetCurrentMapID == 1533 or GetCurrentMapID == 1536 or GetCurrentMapID == 1543 or GetCurrentMapID == 1565 or GetCurrentMapID == 1961
            or GetCurrentMapID == 1970 or GetCurrentMapID == 2016)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Shadowlands"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Dragon Isle
        elseif (GetCurrentMapID == 2022 or GetCurrentMapID == 2023 or GetCurrentMapID == 2024 or GetCurrentMapID == 2025 or GetCurrentMapID == 2026 or GetCurrentMapID == 2133
            or GetCurrentMapID == 2151 or GetCurrentMapID == 2200 or GetCurrentMapID == 2239)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Dragon Isles"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Khaz Algar
        elseif (GetCurrentMapID == 2248 or GetCurrentMapID == 2214 or GetCurrentMapID == 2215 or GetCurrentMapID == 2255 or GetCurrentMapID == 2256 or GetCurrentMapID == 2213 
            or GetCurrentMapID == 2216 or GetCurrentMapID == 2369 or GetCurrentMapID == 2322 or GetCurrentMapID == 2346 or GetCurrentMapID == 2371 or GetCurrentMapID == 2472)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Khaz Algar"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        end
    end

    -- Zones Sync function
    if ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 4 or info.mapType == 5 or info.mapType == 6) then
        --Kalimdor
        if (GetCurrentMapID == 1 or GetCurrentMapID == 7 or GetCurrentMapID == 10 or GetCurrentMapID == 11 or GetCurrentMapID == 57 or GetCurrentMapID == 62 
            or GetCurrentMapID == 63 or GetCurrentMapID == 64 or GetCurrentMapID == 65 or GetCurrentMapID == 66 or GetCurrentMapID == 67 or GetCurrentMapID == 68 
            or GetCurrentMapID == 69 or GetCurrentMapID == 70 or GetCurrentMapID == 71 or GetCurrentMapID == 74 or GetCurrentMapID == 75 or GetCurrentMapID == 76 
            or GetCurrentMapID == 77 or GetCurrentMapID == 78 or GetCurrentMapID == 80 or GetCurrentMapID == 81 or GetCurrentMapID == 83 or GetCurrentMapID == 97 
            or GetCurrentMapID == 106 or GetCurrentMapID == 199 or GetCurrentMapID == 327 or GetCurrentMapID == 460 or GetCurrentMapID == 461 or GetCurrentMapID == 462 
            or GetCurrentMapID == 468 or GetCurrentMapID == 1527 or GetCurrentMapID == 198 or GetCurrentMapID == 249)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Eastern Kingdom
        elseif (GetCurrentMapID == 13 or GetCurrentMapID == 14 or GetCurrentMapID == 15 or GetCurrentMapID == 16 or GetCurrentMapID == 17 or GetCurrentMapID == 18 
            or GetCurrentMapID == 19 or GetCurrentMapID == 21 or GetCurrentMapID == 22 or GetCurrentMapID == 23 or GetCurrentMapID == 25 or GetCurrentMapID == 26 
            or GetCurrentMapID == 27 or GetCurrentMapID == 28 or GetCurrentMapID == 30 or GetCurrentMapID == 32 or GetCurrentMapID == 33 or GetCurrentMapID == 34 
            or GetCurrentMapID == 35 or GetCurrentMapID == 36 or GetCurrentMapID == 37 or GetCurrentMapID == 42 or GetCurrentMapID == 47 or GetCurrentMapID == 48 
            or GetCurrentMapID == 49 or GetCurrentMapID == 50 or GetCurrentMapID == 51 or GetCurrentMapID == 52 or GetCurrentMapID == 55 or GetCurrentMapID == 56 
            or GetCurrentMapID == 94 or GetCurrentMapID == 210 or GetCurrentMapID == 224 or GetCurrentMapID == 245 or GetCurrentMapID == 425 or GetCurrentMapID == 427 
            or GetCurrentMapID == 465 or GetCurrentMapID == 467 or GetCurrentMapID == 469 or GetCurrentMapID == 2070 
            or GetCurrentMapID == 241 or GetCurrentMapID == 203 or GetCurrentMapID == 204 or GetCurrentMapID == 205 or GetCurrentMapID == 241 or GetCurrentMapID == 244 
            or GetCurrentMapID == 245 or GetCurrentMapID == 201 or GetCurrentMapID == 95 or GetCurrentMapID == 122 or GetCurrentMapID == 217  or GetCurrentMapID == 226)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()        
        --Outland
        elseif (GetCurrentMapID == 100 or GetCurrentMapID == 102 or GetCurrentMapID == 104 or GetCurrentMapID == 105 or GetCurrentMapID == 107 or GetCurrentMapID == 108
            or GetCurrentMapID == 109)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Northrend
        elseif (GetCurrentMapID == 114 or GetCurrentMapID == 115 or GetCurrentMapID == 116 or GetCurrentMapID == 117 or GetCurrentMapID == 118 or GetCurrentMapID == 119
            or GetCurrentMapID == 120 or GetCurrentMapID == 121 or GetCurrentMapID == 123 or GetCurrentMapID == 127 or GetCurrentMapID == 170)
        then 
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Pandaria
        elseif (GetCurrentMapID == 371 or GetCurrentMapID == 376 or GetCurrentMapID == 379 or GetCurrentMapID == 388 or GetCurrentMapID == 390 or GetCurrentMapID == 418
            or GetCurrentMapID == 422 or GetCurrentMapID == 433 or GetCurrentMapID == 434 or GetCurrentMapID == 504 or GetCurrentMapID == 554  or GetCurrentMapID == 1530
            or GetCurrentMapID == 507)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Draenor
        elseif (GetCurrentMapID == 525 or GetCurrentMapID == 534 or GetCurrentMapID == 535 or GetCurrentMapID == 539 or GetCurrentMapID == 542 or GetCurrentMapID == 543
            or GetCurrentMapID == 550 or GetCurrentMapID == 588)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Broken Isles
        elseif (GetCurrentMapID == 630 or GetCurrentMapID == 634 or GetCurrentMapID == 641 or GetCurrentMapID == 646 or GetCurrentMapID == 650 or GetCurrentMapID == 652
            or GetCurrentMapID == 750 or GetCurrentMapID == 680 or GetCurrentMapID == 830 or GetCurrentMapID == 882 or GetCurrentMapID == 885 or GetCurrentMapID == 941 
            or GetCurrentMapID == 790 or GetCurrentMapID == 971)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Zandalar
        elseif (GetCurrentMapID == 862 or GetCurrentMapID == 863 or GetCurrentMapID == 864 or GetCurrentMapID == 1355 or GetCurrentMapID == 1528)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --KulTiras
        elseif (GetCurrentMapID == 895 or GetCurrentMapID == 896 or GetCurrentMapID == 942 or GetCurrentMapID == 1462 or GetCurrentMapID == 1169)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Shadowlands
        elseif(GetCurrentMapID == 1525 or GetCurrentMapID == 1533 or GetCurrentMapID == 1536 or GetCurrentMapID == 1543 or GetCurrentMapID == 1565 or GetCurrentMapID == 1961
            or GetCurrentMapID == 1970 or GetCurrentMapID == 2016)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Dragon Isle
        elseif (GetCurrentMapID == 2022 or GetCurrentMapID == 2023 or GetCurrentMapID == 2024 or GetCurrentMapID == 2025 or GetCurrentMapID == 2026 or GetCurrentMapID == 2133
            or GetCurrentMapID == 2151 or GetCurrentMapID == 2200 or GetCurrentMapID == 2239)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Dragon Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Khaz Algar
        elseif (GetCurrentMapID == 2248 or GetCurrentMapID == 2214 or GetCurrentMapID == 2215 or GetCurrentMapID == 2255 or GetCurrentMapID == 2256 or GetCurrentMapID == 2213 
            or GetCurrentMapID == 2216 or GetCurrentMapID == 2369 or GetCurrentMapID == 2322 or GetCurrentMapID == 2346 or GetCurrentMapID == 2371 or GetCurrentMapID == 2472)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Khaz Algar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        end
    end

    -- Dungeon Maps
    if info.mapType == 4 and not 
            (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 -- Cata nodes
            or GetCurrentMapID == 2266 -- Millenias's Threshold
            or GetCurrentMapID == 84 or GetCurrentMapID == 87 or GetCurrentMapID == 89 or GetCurrentMapID == 103 or GetCurrentMapID == 85
            or GetCurrentMapID == 90 or GetCurrentMapID == 86 or GetCurrentMapID == 88 or GetCurrentMapID == 110 or GetCurrentMapID == 111
            or GetCurrentMapID == 125 or GetCurrentMapID == 126 or GetCurrentMapID == 391 or GetCurrentMapID == 392 or GetCurrentMapID == 393 
            or GetCurrentMapID == 394 or GetCurrentMapID == 582 or GetCurrentMapID == 590 or GetCurrentMapID == 622 or GetCurrentMapID == 624 
            or GetCurrentMapID == 626 or GetCurrentMapID == 627 or GetCurrentMapID == 628 or GetCurrentMapID == 629 or GetCurrentMapID == 831 or GetCurrentMapID == 832 
            or GetCurrentMapID == 1161 or GetCurrentMapID == 1163 or GetCurrentMapID == 1164 or GetCurrentMapID == 1165 or GetCurrentMapID == 1670 
            or GetCurrentMapID == 1671 or GetCurrentMapID == 1672 or GetCurrentMapID == 1673 or GetCurrentMapID == 2112 or GetCurrentMapID == 407 
            or GetCurrentMapID == 2339 or GetCurrentMapID == 503 or GetCurrentMapID == 499 or GetCurrentMapID == 500 or GetCurrentMapID == 2322 
            or GetCurrentMapID == 2346)
    then
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. DUNGEONS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end

    -- Capitals without Sync function
    if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and 
            (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 -- Cata nodes
            or GetCurrentMapID == 2266 -- Millenia's Threshold
            or GetCurrentMapID == 84 or GetCurrentMapID == 87 or GetCurrentMapID == 89 or GetCurrentMapID == 103 or GetCurrentMapID == 85
            or GetCurrentMapID == 90 or GetCurrentMapID == 86 or GetCurrentMapID == 88 or GetCurrentMapID == 110 or GetCurrentMapID == 111
            or GetCurrentMapID == 125 or GetCurrentMapID == 126 or GetCurrentMapID == 391 or GetCurrentMapID == 392 or GetCurrentMapID == 393 
            or GetCurrentMapID == 394 or GetCurrentMapID == 582 or GetCurrentMapID == 590 or GetCurrentMapID == 622 or GetCurrentMapID == 624 
            or GetCurrentMapID == 626 or GetCurrentMapID == 627 or GetCurrentMapID == 628 or GetCurrentMapID == 629 or GetCurrentMapID == 831 or GetCurrentMapID == 832 
            or GetCurrentMapID == 1161 or GetCurrentMapID == 1163 or GetCurrentMapID == 1164 or GetCurrentMapID == 1165 or GetCurrentMapID == 1670 
            or GetCurrentMapID == 1671 or GetCurrentMapID == 1672 or GetCurrentMapID == 1673 or GetCurrentMapID == 2112 or GetCurrentMapID == 407 
            or GetCurrentMapID == 2339 or GetCurrentMapID == 503 or GetCurrentMapID == 499 or GetCurrentMapID == 500 or GetCurrentMapID == 2322 
            or GetCurrentMapID == 2346)
    then
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Capitals"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end

    -- Capitals Sync function
    if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and 
            (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 -- Cata nodes
            or GetCurrentMapID == 2266 -- Millenia's Threshold
            or GetCurrentMapID == 84 or GetCurrentMapID == 87 or GetCurrentMapID == 89 or GetCurrentMapID == 103 or GetCurrentMapID == 85
            or GetCurrentMapID == 90 or GetCurrentMapID == 86 or GetCurrentMapID == 88 or GetCurrentMapID == 110 or GetCurrentMapID == 111
            or GetCurrentMapID == 125 or GetCurrentMapID == 126 or GetCurrentMapID == 391 or GetCurrentMapID == 392 or GetCurrentMapID == 393 
            or GetCurrentMapID == 394 or GetCurrentMapID == 582 or GetCurrentMapID == 590 or GetCurrentMapID == 622 or GetCurrentMapID == 624 
            or GetCurrentMapID == 626 or GetCurrentMapID == 627 or GetCurrentMapID == 628 or GetCurrentMapID == 629 or GetCurrentMapID == 831 or GetCurrentMapID == 832 
            or GetCurrentMapID == 1161 or GetCurrentMapID == 1163 or GetCurrentMapID == 1164 or GetCurrentMapID == 1165 or GetCurrentMapID == 1670 
            or GetCurrentMapID == 1671 or GetCurrentMapID == 1672 or GetCurrentMapID == 1673 or GetCurrentMapID == 2112 or GetCurrentMapID == 407 
            or GetCurrentMapID == 2339 or GetCurrentMapID == 503 or GetCurrentMapID == 499 or GetCurrentMapID == 500 or GetCurrentMapID == 2322 
            or GetCurrentMapID == 2346)
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