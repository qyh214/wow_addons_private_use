local ADDON_NAME, ns = ...

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local WorldMapOptionsButtonMixin = {}
_G[ADDON_NAME .. 'WorldMapOptionsButtonMixin'] = WorldMapOptionsButtonMixin

function WorldMapOptionsButtonMixin:OnLoad()

end


function WorldMapOptionsButtonMixin:OnClick(button)
local info = C_Map.GetMapInfo(WorldMapFrame:GetMapID())

    if button == "LeftButton" then

        if not LibStub("AceConfigDialog-3.0"):Close("MapNotes") then
            LibStub("AceConfigDialog-3.0"):Open("MapNotes")
        end 

    end

    if button == "MiddleButton" then

        if not ns.Addon.db.profile.activate.HideMapNote then
            ns.Addon.db.profile.activate.HideMapNote = true
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffff0000", L["All MapNotes icons have been hidden"])
        else
            ns.Addon.db.profile.activate.HideMapNote = false
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cff00ff00", L["All set icons have been restored"])
        end

    end

    if button == "RightButton" then 

        -- Cosmos
        if info.mapType == 0 then 
        
            if not ns.Addon.db.profile.activate.CosmosMap then
                ns.Addon.db.profile.activate.CosmosMap = true
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", WORLDMAP_BUTTON, L["icons"], "|cff00ff00" .. L["are shown"])
            else
                ns.Addon.db.profile.activate.CosmosMap = false
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", WORLDMAP_BUTTON, L["icons"], "|cffff0000" .. L["are hidden"])
            end

        end

        -- Azeroth World Map
        if info.mapType == 1 then

            if not ns.Addon.db.profile.activate.Azeroth then
                ns.Addon.db.profile.activate.Azeroth = true
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. AZEROTH, L["icons"], "|cff00ff00" .. L["are shown"])
            else
                ns.Addon.db.profile.activate.Azeroth = false
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. AZEROTH, L["icons"], "|cffff0000" .. L["are hidden"])
            end

        end
        
        -- Continent Maps
        if info.mapType == 2 then 

            if WorldMapFrame:GetMapID() == 12 or WorldMapFrame:GetMapID() == 948 then
                if ns.Addon.db.profile.showContinentKalimdor then
                    ns.Addon.db.profile.showContinentKalimdor = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Kalimdor"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentKalimdor = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Kalimdor"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif WorldMapFrame:GetMapID() == 13 then
                if ns.Addon.db.profile.showContinentEasternKingdom then
                    ns.Addon.db.profile.showContinentEasternKingdom = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Eastern Kingdom"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentEasternKingdom = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Eastern Kingdom"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif WorldMapFrame:GetMapID() == 101 then
                if ns.Addon.db.profile.showContinentOutland then
                    ns.Addon.db.profile.showContinentOutland = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Outland"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentOutland = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Outland"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif WorldMapFrame:GetMapID() == 113 then
                if ns.Addon.db.profile.showContinentNorthrend then
                    ns.Addon.db.profile.showContinentNorthrend = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Northrend"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentNorthrend = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Northrend"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif WorldMapFrame:GetMapID() == 424 then
                if ns.Addon.db.profile.showContinentPandaria then
                    ns.Addon.db.profile.showContinentPandaria = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Pandaria"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentPandaria = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Pandaria"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif WorldMapFrame:GetMapID() == 572 then
                if ns.Addon.db.profile.showContinentDraenor then
                    ns.Addon.db.profile.showContinentDraenor = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Draenor"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentDraenor = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Draenor"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif WorldMapFrame:GetMapID() == 619 then
                if ns.Addon.db.profile.showContinentBrokenIsles then
                    ns.Addon.db.profile.showContinentBrokenIsles = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Broken Isles"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentBrokenIsles = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Broken Isles"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif WorldMapFrame:GetMapID() == 875 then
                if ns.Addon.db.profile.showContinentZandalar then
                    ns.Addon.db.profile.showContinentZandalar = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Zandalar"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentZandalar = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Zandalar"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif WorldMapFrame:GetMapID() == 876 then
                if ns.Addon.db.profile.showContinentKulTiras then
                    ns.Addon.db.profile.showContinentKulTiras = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Kul Tiras"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentKulTiras = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Kul Tiras"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif WorldMapFrame:GetMapID() == 1550 then
                if ns.Addon.db.profile.showContinentShadowlands then
                    ns.Addon.db.profile.showContinentShadowlands = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Shadowlands"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentShadowlands = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Shadowlands"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif WorldMapFrame:GetMapID() == 1978 then
                if ns.Addon.db.profile.showContinentDragonIsles then
                    ns.Addon.db.profile.showContinentDragonIsles = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Dragon Isles"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentDragonIsles = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Dragon Isles"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif WorldMapFrame:GetMapID() == 2274 then
                if ns.Addon.db.profile.showContinentKhazAlgar then
                    ns.Addon.db.profile.showContinentKhazAlgar = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Khaz Algar"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentKhazAlgar = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Khaz Algar"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            end

        end

        -- Dungeon Maps
        if info.mapType == 4 and not 
            (WorldMapFrame:GetMapID() == 1454 or WorldMapFrame:GetMapID() == 1456 --Cata nodes
            or WorldMapFrame:GetMapID() == 2266 -- Milleania's Threshold
            or WorldMapFrame:GetMapID() == 84 or WorldMapFrame:GetMapID() == 87 or WorldMapFrame:GetMapID() == 89 or WorldMapFrame:GetMapID() == 103 or WorldMapFrame:GetMapID() == 85
            or WorldMapFrame:GetMapID() == 90 or WorldMapFrame:GetMapID() == 86 or WorldMapFrame:GetMapID() == 88 or WorldMapFrame:GetMapID() == 110 or WorldMapFrame:GetMapID() == 111
            or WorldMapFrame:GetMapID() == 125 or WorldMapFrame:GetMapID() == 126 or WorldMapFrame:GetMapID() == 391 or WorldMapFrame:GetMapID() == 392 or WorldMapFrame:GetMapID() == 393 
            or WorldMapFrame:GetMapID() == 394 or WorldMapFrame:GetMapID() == 582 or WorldMapFrame:GetMapID() == 590 or WorldMapFrame:GetMapID() == 622 or WorldMapFrame:GetMapID() == 624 
            or WorldMapFrame:GetMapID() == 626 or WorldMapFrame:GetMapID() == 627 or WorldMapFrame:GetMapID() == 628 or WorldMapFrame:GetMapID() == 629 or WorldMapFrame:GetMapID() == 1161
            or WorldMapFrame:GetMapID() == 1163 or WorldMapFrame:GetMapID() == 1164 or WorldMapFrame:GetMapID() == 1165 or WorldMapFrame:GetMapID() == 1670 or WorldMapFrame:GetMapID() == 1671 
            or WorldMapFrame:GetMapID() == 1672 or WorldMapFrame:GetMapID() == 1673 or WorldMapFrame:GetMapID() == 2112 or WorldMapFrame:GetMapID() == 407 or WorldMapFrame:GetMapID() == 2339 
            or WorldMapFrame:GetMapID() == 503 or WorldMapFrame:GetMapID() == 499 or WorldMapFrame:GetMapID() == 500)
        then
        
            if not ns.Addon.db.profile.activate.DungeonMap then
                ns.Addon.db.profile.activate.DungeonMap = true
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dungeon map"], L["icons"], "|cff00ff00" .. L["are shown"])
            else
                ns.Addon.db.profile.activate.DungeonMap = false
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dungeon map"], L["icons"], "|cffff0000" .. L["are hidden"])
            end

        end

        -- Zones without Sync function
        if not ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6) then
            --Kalimdor
            if (WorldMapFrame:GetMapID() == 1 or WorldMapFrame:GetMapID() == 7 or WorldMapFrame:GetMapID() == 10 or WorldMapFrame:GetMapID() == 11 or WorldMapFrame:GetMapID() == 57 or WorldMapFrame:GetMapID() == 62 
                or WorldMapFrame:GetMapID() == 63 or WorldMapFrame:GetMapID() == 64 or WorldMapFrame:GetMapID() == 65 or WorldMapFrame:GetMapID() == 66 or WorldMapFrame:GetMapID() == 67 or WorldMapFrame:GetMapID() == 68 
                or WorldMapFrame:GetMapID() == 69 or WorldMapFrame:GetMapID() == 70 or WorldMapFrame:GetMapID() == 71 or WorldMapFrame:GetMapID() == 74 or WorldMapFrame:GetMapID() == 75 or WorldMapFrame:GetMapID() == 76 
                or WorldMapFrame:GetMapID() == 77 or WorldMapFrame:GetMapID() == 78 or WorldMapFrame:GetMapID() == 80 or WorldMapFrame:GetMapID() == 81 or WorldMapFrame:GetMapID() == 83 or WorldMapFrame:GetMapID() == 97 
                or WorldMapFrame:GetMapID() == 106 or WorldMapFrame:GetMapID() == 199 or WorldMapFrame:GetMapID() == 327 or WorldMapFrame:GetMapID() == 460 or WorldMapFrame:GetMapID() == 461 or WorldMapFrame:GetMapID() == 462 
                or WorldMapFrame:GetMapID() == 468 or WorldMapFrame:GetMapID() == 1527 or WorldMapFrame:GetMapID() == 198 or WorldMapFrame:GetMapID() == 249)
            then
                if not ns.Addon.db.profile.showZoneKalimdor then
                    ns.Addon.db.profile.showZoneKalimdor = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kalimdor"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneKalimdor = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kalimdor"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            --Eastern Kingdom
            elseif (WorldMapFrame:GetMapID() == 13 or WorldMapFrame:GetMapID() == 14 or WorldMapFrame:GetMapID() == 15 or WorldMapFrame:GetMapID() == 16 or WorldMapFrame:GetMapID() == 17 or WorldMapFrame:GetMapID() == 18 
                or WorldMapFrame:GetMapID() == 19 or WorldMapFrame:GetMapID() == 21 or WorldMapFrame:GetMapID() == 22 or WorldMapFrame:GetMapID() == 23 or WorldMapFrame:GetMapID() == 25 or WorldMapFrame:GetMapID() == 26 
                or WorldMapFrame:GetMapID() == 27 or WorldMapFrame:GetMapID() == 28 or WorldMapFrame:GetMapID() == 30 or WorldMapFrame:GetMapID() == 32 or WorldMapFrame:GetMapID() == 33 or WorldMapFrame:GetMapID() == 34 
                or WorldMapFrame:GetMapID() == 35 or WorldMapFrame:GetMapID() == 36 or WorldMapFrame:GetMapID() == 37 or WorldMapFrame:GetMapID() == 42 or WorldMapFrame:GetMapID() == 47 or WorldMapFrame:GetMapID() == 48 
                or WorldMapFrame:GetMapID() == 49 or WorldMapFrame:GetMapID() == 50 or WorldMapFrame:GetMapID() == 51 or WorldMapFrame:GetMapID() == 52 or WorldMapFrame:GetMapID() == 55 or WorldMapFrame:GetMapID() == 56 
                or WorldMapFrame:GetMapID() == 94 or WorldMapFrame:GetMapID() == 210 or WorldMapFrame:GetMapID() == 224 or WorldMapFrame:GetMapID() == 245 or WorldMapFrame:GetMapID() == 425 or WorldMapFrame:GetMapID() == 427 
                or WorldMapFrame:GetMapID() == 465 or WorldMapFrame:GetMapID() == 467 or WorldMapFrame:GetMapID() == 469 or WorldMapFrame:GetMapID() == 499 or WorldMapFrame:GetMapID() == 500 or WorldMapFrame:GetMapID() == 2070 
                or WorldMapFrame:GetMapID() == 241 or WorldMapFrame:GetMapID() == 203 or WorldMapFrame:GetMapID() == 204 or WorldMapFrame:GetMapID() == 205 or WorldMapFrame:GetMapID() == 241 or WorldMapFrame:GetMapID() == 244 
                or WorldMapFrame:GetMapID() == 245 or WorldMapFrame:GetMapID() == 201 or WorldMapFrame:GetMapID() == 95 or WorldMapFrame:GetMapID() == 122 or WorldMapFrame:GetMapID() == 217  or WorldMapFrame:GetMapID() == 226)
            then
                if not ns.Addon.db.profile.showZoneEasternKingdom then
                    ns.Addon.db.profile.showZoneEasternKingdom = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Eastern Kingdom"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneEasternKingdom = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            --Outland
            elseif (WorldMapFrame:GetMapID() == 100 or WorldMapFrame:GetMapID() == 102 or WorldMapFrame:GetMapID() == 104 or WorldMapFrame:GetMapID() == 105 or WorldMapFrame:GetMapID() == 107 or WorldMapFrame:GetMapID() == 108
                or WorldMapFrame:GetMapID() == 109)
            then
                if not ns.Addon.db.profile.showZoneOutland then
                    ns.Addon.db.profile.showZoneOutland = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Outland"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneOutland = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Outland"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            --Northrend
            elseif (WorldMapFrame:GetMapID() == 114 or WorldMapFrame:GetMapID() == 115 or WorldMapFrame:GetMapID() == 116 or WorldMapFrame:GetMapID() == 117 or WorldMapFrame:GetMapID() == 118 or WorldMapFrame:GetMapID() == 119
                or WorldMapFrame:GetMapID() == 120 or WorldMapFrame:GetMapID() == 121 or WorldMapFrame:GetMapID() == 123 or WorldMapFrame:GetMapID() == 127 or WorldMapFrame:GetMapID() == 170)
            then
                if not ns.Addon.db.profile.showZoneNorthrend then
                    ns.Addon.db.profile.showZoneNorthrend = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Northrend"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneNorthrend = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Northrend"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            --Pandaria
            elseif (WorldMapFrame:GetMapID() == 371 or WorldMapFrame:GetMapID() == 376 or WorldMapFrame:GetMapID() == 379 or WorldMapFrame:GetMapID() == 388 or WorldMapFrame:GetMapID() == 390 or WorldMapFrame:GetMapID() == 418
                or WorldMapFrame:GetMapID() == 422 or WorldMapFrame:GetMapID() == 433 or WorldMapFrame:GetMapID() == 434 or WorldMapFrame:GetMapID() == 504 or WorldMapFrame:GetMapID() == 554  or WorldMapFrame:GetMapID() == 1530
                or WorldMapFrame:GetMapID() == 507)
            then
                if not ns.Addon.db.profile.showZonePandaria then
                    ns.Addon.db.profile.showZonePandaria = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Pandaria"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZonePandaria = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Pandaria"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            --Draenor
            elseif (WorldMapFrame:GetMapID() == 525 or WorldMapFrame:GetMapID() == 534 or WorldMapFrame:GetMapID() == 535 or WorldMapFrame:GetMapID() == 539 or WorldMapFrame:GetMapID() == 542 or WorldMapFrame:GetMapID() == 543
                or WorldMapFrame:GetMapID() == 550 or WorldMapFrame:GetMapID() == 588)
            then
                if not ns.Addon.db.profile.showZoneDraenor then
                    ns.Addon.db.profile.showZoneDraenor = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Draenor"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneDraenor = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Draenor"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            --Broken Isles
            elseif (WorldMapFrame:GetMapID() == 630 or WorldMapFrame:GetMapID() == 634 or WorldMapFrame:GetMapID() == 641 or WorldMapFrame:GetMapID() == 646 or WorldMapFrame:GetMapID() == 650 or WorldMapFrame:GetMapID() == 652
                or WorldMapFrame:GetMapID() == 750 or WorldMapFrame:GetMapID() == 680 or WorldMapFrame:GetMapID() == 830 or WorldMapFrame:GetMapID() == 882 or WorldMapFrame:GetMapID() == 885 or WorldMapFrame:GetMapID() == 905
                or WorldMapFrame:GetMapID() == 941 or WorldMapFrame:GetMapID() == 790 or WorldMapFrame:GetMapID() == 971)
            then
                if not ns.Addon.db.profile.showZoneBrokenIsles then
                    ns.Addon.db.profile.showZoneBrokenIsles = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Broken Isles"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneBrokenIsles = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Broken Isles"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            --Zandalar
            elseif (WorldMapFrame:GetMapID() == 862 or WorldMapFrame:GetMapID() == 863 or WorldMapFrame:GetMapID() == 864 or WorldMapFrame:GetMapID() == 1355 or WorldMapFrame:GetMapID() == 1528)
            then
                if not ns.Addon.db.profile.showZoneZandalar then
                    ns.Addon.db.profile.showZoneZandalar = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zandalar"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneZandalar = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zandalar"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            --KulTiras
            elseif (WorldMapFrame:GetMapID() == 895 or WorldMapFrame:GetMapID() == 896 or WorldMapFrame:GetMapID() == 942 or WorldMapFrame:GetMapID() == 1462 or WorldMapFrame:GetMapID() == 1169)
            then
                if not ns.Addon.db.profile.showZoneKulTiras then
                    ns.Addon.db.profile.showZoneKulTiras = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kul Tiras"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneKulTiras = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Kul Tiras"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            --Shadowlands
            elseif (WorldMapFrame:GetMapID() == 1525 or WorldMapFrame:GetMapID() == 1533 or WorldMapFrame:GetMapID() == 1536 or WorldMapFrame:GetMapID() == 1543 or WorldMapFrame:GetMapID() == 1565 or WorldMapFrame:GetMapID() == 1961
                or WorldMapFrame:GetMapID() == 1970 or WorldMapFrame:GetMapID() == 2016)
            then
                if not ns.Addon.db.profile.showZoneShadowlands then
                    ns.Addon.db.profile.showZoneShadowlands = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Shadowlands"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneShadowlands = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Shadowlands"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            --Dragon Isle
            elseif (WorldMapFrame:GetMapID() == 2022 or WorldMapFrame:GetMapID() == 2023 or WorldMapFrame:GetMapID() == 2024 or WorldMapFrame:GetMapID() == 2025 or WorldMapFrame:GetMapID() == 2026 or WorldMapFrame:GetMapID() == 2133
                or WorldMapFrame:GetMapID() == 2151 or WorldMapFrame:GetMapID() == 2200 or WorldMapFrame:GetMapID() == 2239)
            then
                if not ns.Addon.db.profile.showZoneDragonIsles then
                    ns.Addon.db.profile.showZoneDragonIsles = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dragon Isles"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneDragonIsles = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dragon Isles"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            --Khaz Algar
            elseif (WorldMapFrame:GetMapID() == 2248 or WorldMapFrame:GetMapID() == 2214 or WorldMapFrame:GetMapID() == 2215 or WorldMapFrame:GetMapID() == 2255 or WorldMapFrame:GetMapID() == 2256 or WorldMapFrame:GetMapID() == 2213 or WorldMapFrame:GetMapID() == 2216)
            then
                if not ns.Addon.db.profile.showZoneKhazAlgar then
                    ns.Addon.db.profile.showZoneKhazAlgar = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Khaz Algar"] ..  " " .. L["Zones"] .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneKhazAlgar = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Khaz Algar"] .. " " .. L["Zones"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            end
        end

        -- Zones Sync function
        if ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6) then
            --Kalimdor
            if (WorldMapFrame:GetMapID() == 1 or WorldMapFrame:GetMapID() == 7 or WorldMapFrame:GetMapID() == 10 or WorldMapFrame:GetMapID() == 11 or WorldMapFrame:GetMapID() == 57 or WorldMapFrame:GetMapID() == 62 
                or WorldMapFrame:GetMapID() == 63 or WorldMapFrame:GetMapID() == 64 or WorldMapFrame:GetMapID() == 65 or WorldMapFrame:GetMapID() == 66 or WorldMapFrame:GetMapID() == 67 or WorldMapFrame:GetMapID() == 68 
                or WorldMapFrame:GetMapID() == 69 or WorldMapFrame:GetMapID() == 70 or WorldMapFrame:GetMapID() == 71 or WorldMapFrame:GetMapID() == 74 or WorldMapFrame:GetMapID() == 75 or WorldMapFrame:GetMapID() == 76 
                or WorldMapFrame:GetMapID() == 77 or WorldMapFrame:GetMapID() == 78 or WorldMapFrame:GetMapID() == 80 or WorldMapFrame:GetMapID() == 81 or WorldMapFrame:GetMapID() == 83 or WorldMapFrame:GetMapID() == 97 
                or WorldMapFrame:GetMapID() == 106 or WorldMapFrame:GetMapID() == 199 or WorldMapFrame:GetMapID() == 327 or WorldMapFrame:GetMapID() == 460 or WorldMapFrame:GetMapID() == 461 or WorldMapFrame:GetMapID() == 462 
                or WorldMapFrame:GetMapID() == 468 or WorldMapFrame:GetMapID() == 1527 or WorldMapFrame:GetMapID() == 198 or WorldMapFrame:GetMapID() == 249)
            then
                if not ns.Addon.db.profile.showZoneKalimdor then
                    ns.Addon.db.profile.showZoneKalimdor = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneKalimdor = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            -- Eastern Kingdom
            elseif (WorldMapFrame:GetMapID() == 13 or WorldMapFrame:GetMapID() == 14 or WorldMapFrame:GetMapID() == 15 or WorldMapFrame:GetMapID() == 16 or WorldMapFrame:GetMapID() == 17 or WorldMapFrame:GetMapID() == 18 
                or WorldMapFrame:GetMapID() == 19 or WorldMapFrame:GetMapID() == 21 or WorldMapFrame:GetMapID() == 22 or WorldMapFrame:GetMapID() == 23 or WorldMapFrame:GetMapID() == 25 or WorldMapFrame:GetMapID() == 26 
                or WorldMapFrame:GetMapID() == 27 or WorldMapFrame:GetMapID() == 28 or WorldMapFrame:GetMapID() == 30 or WorldMapFrame:GetMapID() == 32 or WorldMapFrame:GetMapID() == 33 or WorldMapFrame:GetMapID() == 34 
                or WorldMapFrame:GetMapID() == 35 or WorldMapFrame:GetMapID() == 36 or WorldMapFrame:GetMapID() == 37 or WorldMapFrame:GetMapID() == 42 or WorldMapFrame:GetMapID() == 47 or WorldMapFrame:GetMapID() == 48 
                or WorldMapFrame:GetMapID() == 49 or WorldMapFrame:GetMapID() == 50 or WorldMapFrame:GetMapID() == 51 or WorldMapFrame:GetMapID() == 52 or WorldMapFrame:GetMapID() == 55 or WorldMapFrame:GetMapID() == 56 
                or WorldMapFrame:GetMapID() == 94 or WorldMapFrame:GetMapID() == 210 or WorldMapFrame:GetMapID() == 224 or WorldMapFrame:GetMapID() == 245 or WorldMapFrame:GetMapID() == 425 or WorldMapFrame:GetMapID() == 427 
                or WorldMapFrame:GetMapID() == 465 or WorldMapFrame:GetMapID() == 467 or WorldMapFrame:GetMapID() == 469 or WorldMapFrame:GetMapID() == 499 or WorldMapFrame:GetMapID() == 500 or WorldMapFrame:GetMapID() == 2070 
                or WorldMapFrame:GetMapID() == 241 or WorldMapFrame:GetMapID() == 203 or WorldMapFrame:GetMapID() == 204 or WorldMapFrame:GetMapID() == 205 or WorldMapFrame:GetMapID() == 241 or WorldMapFrame:GetMapID() == 244 
                or WorldMapFrame:GetMapID() == 245 or WorldMapFrame:GetMapID() == 201 or WorldMapFrame:GetMapID() == 95 or WorldMapFrame:GetMapID() == 122 or WorldMapFrame:GetMapID() == 217  or WorldMapFrame:GetMapID() == 226) 
            then
                if not ns.Addon.db.profile.showZoneEasternKingdom then
                    ns.Addon.db.profile.showZoneEasternKingdom = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneEasternKingdom = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            -- Outland    
            elseif (WorldMapFrame:GetMapID() == 100 or WorldMapFrame:GetMapID() == 102 or WorldMapFrame:GetMapID() == 104 or WorldMapFrame:GetMapID() == 105 or WorldMapFrame:GetMapID() == 107 or WorldMapFrame:GetMapID() == 108
                or WorldMapFrame:GetMapID() == 109) 
            then
                if not ns.Addon.db.profile.showZoneOutland then
                    ns.Addon.db.profile.showZoneOutland = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneOutland = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            -- Northrend    
            elseif (WorldMapFrame:GetMapID() == 114 or WorldMapFrame:GetMapID() == 115 or WorldMapFrame:GetMapID() == 116 or WorldMapFrame:GetMapID() == 117 or WorldMapFrame:GetMapID() == 118 or WorldMapFrame:GetMapID() == 119
                or WorldMapFrame:GetMapID() == 120 or WorldMapFrame:GetMapID() == 121 or WorldMapFrame:GetMapID() == 123 or WorldMapFrame:GetMapID() == 127 or WorldMapFrame:GetMapID() == 170) 
            then
                if not ns.Addon.db.profile.showZoneNorthrend then
                    ns.Addon.db.profile.showZoneNorthrend = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneNorthrend = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            -- Pandaria    
            elseif (WorldMapFrame:GetMapID() == 371 or WorldMapFrame:GetMapID() == 376 or WorldMapFrame:GetMapID() == 379 or WorldMapFrame:GetMapID() == 388 or WorldMapFrame:GetMapID() == 390 or WorldMapFrame:GetMapID() == 418
                or WorldMapFrame:GetMapID() == 422 or WorldMapFrame:GetMapID() == 433 or WorldMapFrame:GetMapID() == 434 or WorldMapFrame:GetMapID() == 504 or WorldMapFrame:GetMapID() == 554  or WorldMapFrame:GetMapID() == 1530
                or WorldMapFrame:GetMapID() == 507) 
            then
                if not ns.Addon.db.profile.showZonePandaria then
                    ns.Addon.db.profile.showZonePandaria = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZonePandaria = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            -- Draenor    
            elseif (WorldMapFrame:GetMapID() == 525 or WorldMapFrame:GetMapID() == 534 or WorldMapFrame:GetMapID() == 535 or WorldMapFrame:GetMapID() == 539 or WorldMapFrame:GetMapID() == 542 or WorldMapFrame:GetMapID() == 543
                or WorldMapFrame:GetMapID() == 550 or WorldMapFrame:GetMapID() == 588) 
            then
                if not ns.Addon.db.profile.showZoneDraenor then
                    ns.Addon.db.profile.showZoneDraenor = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneDraenor = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            -- Broken Isles    
            elseif (WorldMapFrame:GetMapID() == 630 or WorldMapFrame:GetMapID() == 634 or WorldMapFrame:GetMapID() == 641 or WorldMapFrame:GetMapID() == 646 or WorldMapFrame:GetMapID() == 650 or WorldMapFrame:GetMapID() == 652
                or WorldMapFrame:GetMapID() == 750 or WorldMapFrame:GetMapID() == 680 or WorldMapFrame:GetMapID() == 830 or WorldMapFrame:GetMapID() == 882 or WorldMapFrame:GetMapID() == 885 or WorldMapFrame:GetMapID() == 905
                or WorldMapFrame:GetMapID() == 941 or WorldMapFrame:GetMapID() == 790 or WorldMapFrame:GetMapID() == 971) 
            then
                if not ns.Addon.db.profile.showZoneBrokenIsles then
                    ns.Addon.db.profile.showZoneBrokenIsles = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneBrokenIsles = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            -- Zandalar    
            elseif (WorldMapFrame:GetMapID() == 862 or WorldMapFrame:GetMapID() == 863 or WorldMapFrame:GetMapID() == 864 or WorldMapFrame:GetMapID() == 1355 or WorldMapFrame:GetMapID() == 1528) 
            then
                if not ns.Addon.db.profile.showZoneZandalar then
                    ns.Addon.db.profile.showZoneZandalar = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneZandalar = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            -- Kul Tiras    
            elseif (WorldMapFrame:GetMapID() == 895 or WorldMapFrame:GetMapID() == 896 or WorldMapFrame:GetMapID() == 942 or WorldMapFrame:GetMapID() == 1462 or WorldMapFrame:GetMapID() == 1169) 
            then
                if not ns.Addon.db.profile.showZoneKulTiras then
                    ns.Addon.db.profile.showZoneKulTiras = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneKulTiras = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            -- Shadowlands    
            elseif (WorldMapFrame:GetMapID() == 1525 or WorldMapFrame:GetMapID() == 1533 or WorldMapFrame:GetMapID() == 1536 or WorldMapFrame:GetMapID() == 1543 or WorldMapFrame:GetMapID() == 1565 or WorldMapFrame:GetMapID() == 1961
                or WorldMapFrame:GetMapID() == 1970 or WorldMapFrame:GetMapID() == 2016) 
            then
                if not ns.Addon.db.profile.showZoneShadowlands then
                    ns.Addon.db.profile.showZoneShadowlands = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneShadowlands = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            -- Dragon Isles    
            elseif (WorldMapFrame:GetMapID() == 2022 or WorldMapFrame:GetMapID() == 2023 or WorldMapFrame:GetMapID() == 2024 or WorldMapFrame:GetMapID() == 2025 or WorldMapFrame:GetMapID() == 2026 or WorldMapFrame:GetMapID() == 2133
                or WorldMapFrame:GetMapID() == 2151 or WorldMapFrame:GetMapID() == 2200 or WorldMapFrame:GetMapID() == 2239) 
            then
                if not ns.Addon.db.profile.showZoneDragonIsles then
                    ns.Addon.db.profile.showZoneDragonIsles = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Dragon Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneDragonIsles = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Dragon Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            -- Khaz Algar    
            elseif (WorldMapFrame:GetMapID() == 2248 or WorldMapFrame:GetMapID() == 2214 or WorldMapFrame:GetMapID() == 2215 or WorldMapFrame:GetMapID() == 2255 or WorldMapFrame:GetMapID() == 2256 or WorldMapFrame:GetMapID() == 2213 or WorldMapFrame:GetMapID() == 2216) 
            then
                if not ns.Addon.db.profile.showZoneKhazAlgar then
                    ns.Addon.db.profile.showZoneKhazAlgar = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Khaz Algar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
                else
                    ns.Addon.db.profile.showZoneKhazAlgar = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Khaz Algar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
                end
            end
        end

        -- Capitals without Sync function
        if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and (WorldMapFrame:GetMapID() == 1454 or WorldMapFrame:GetMapID() == 1456 -- Cata nodes
            or WorldMapFrame:GetMapID() == 2266 -- Millenia's Threshold
            or WorldMapFrame:GetMapID() == 84 or WorldMapFrame:GetMapID() == 87 or WorldMapFrame:GetMapID() == 89 or WorldMapFrame:GetMapID() == 103 or WorldMapFrame:GetMapID() == 85
            or WorldMapFrame:GetMapID() == 90 or WorldMapFrame:GetMapID() == 86 or WorldMapFrame:GetMapID() == 88 or WorldMapFrame:GetMapID() == 110 or WorldMapFrame:GetMapID() == 111
            or WorldMapFrame:GetMapID() == 125 or WorldMapFrame:GetMapID() == 126 or WorldMapFrame:GetMapID() == 391 or WorldMapFrame:GetMapID() == 392 or WorldMapFrame:GetMapID() == 393 
            or WorldMapFrame:GetMapID() == 394 or WorldMapFrame:GetMapID() == 582 or WorldMapFrame:GetMapID() == 590 or WorldMapFrame:GetMapID() == 622 or WorldMapFrame:GetMapID() == 624 
            or WorldMapFrame:GetMapID() == 626 or WorldMapFrame:GetMapID() == 627 or WorldMapFrame:GetMapID() == 628 or WorldMapFrame:GetMapID() == 629 or WorldMapFrame:GetMapID() == 1161
            or WorldMapFrame:GetMapID() == 1163 or WorldMapFrame:GetMapID() == 1164 or WorldMapFrame:GetMapID() == 1165 or WorldMapFrame:GetMapID() == 1670 or WorldMapFrame:GetMapID() == 1671 
            or WorldMapFrame:GetMapID() == 1672 or WorldMapFrame:GetMapID() == 1673 or WorldMapFrame:GetMapID() == 2112 or WorldMapFrame:GetMapID() == 407 or WorldMapFrame:GetMapID() == 2339 
            or WorldMapFrame:GetMapID() == 503 or WorldMapFrame:GetMapID() == 499 or WorldMapFrame:GetMapID() == 500) 
        then
        
            if not ns.Addon.db.profile.activate.Capitals then
                ns.Addon.db.profile.activate.Capitals = true
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], L["icons"], "|cff00ff00" .. L["are shown"])
            else
                ns.Addon.db.profile.activate.Capitals = false
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], L["icons"], "|cffff0000" .. L["are hidden"])
            end

        end

        -- Capitals Sync function
        if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and (WorldMapFrame:GetMapID() == 1454 or WorldMapFrame:GetMapID() == 1456 -- Cata nodes
            or WorldMapFrame:GetMapID() == 2266 -- Millenia's Threshold
            or WorldMapFrame:GetMapID() == 84 or WorldMapFrame:GetMapID() == 87 or WorldMapFrame:GetMapID() == 89 or WorldMapFrame:GetMapID() == 103 or WorldMapFrame:GetMapID() == 85
            or WorldMapFrame:GetMapID() == 90 or WorldMapFrame:GetMapID() == 86 or WorldMapFrame:GetMapID() == 88 or WorldMapFrame:GetMapID() == 110 or WorldMapFrame:GetMapID() == 111
            or WorldMapFrame:GetMapID() == 125 or WorldMapFrame:GetMapID() == 126 or WorldMapFrame:GetMapID() == 391 or WorldMapFrame:GetMapID() == 392 or WorldMapFrame:GetMapID() == 393 
            or WorldMapFrame:GetMapID() == 394 or WorldMapFrame:GetMapID() == 582 or WorldMapFrame:GetMapID() == 590 or WorldMapFrame:GetMapID() == 622 or WorldMapFrame:GetMapID() == 624 
            or WorldMapFrame:GetMapID() == 626 or WorldMapFrame:GetMapID() == 627 or WorldMapFrame:GetMapID() == 628 or WorldMapFrame:GetMapID() == 629 or WorldMapFrame:GetMapID() == 1161
            or WorldMapFrame:GetMapID() == 1163 or WorldMapFrame:GetMapID() == 1164 or WorldMapFrame:GetMapID() == 1165 or WorldMapFrame:GetMapID() == 1670 or WorldMapFrame:GetMapID() == 1671 
            or WorldMapFrame:GetMapID() == 1672 or WorldMapFrame:GetMapID() == 1673 or WorldMapFrame:GetMapID() == 2112 or WorldMapFrame:GetMapID() == 407 or WorldMapFrame:GetMapID() == 2339 
            or WorldMapFrame:GetMapID() == 503 or WorldMapFrame:GetMapID() == 499 or WorldMapFrame:GetMapID() == 500) then
        
            if not ns.Addon.db.profile.activate.Capitals then
                ns.Addon.db.profile.activate.Capitals = true
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
            else
                ns.Addon.db.profile.activate.Capitals = false
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
            end
            
        end

    end
    ns.Addon:FullUpdate()
    HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end

function WorldMapOptionsButtonMixin:OnEnter()
local info = C_Map.GetMapInfo(WorldMapFrame:GetMapID())

    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip_SetTitle(GameTooltip, ns.COLORED_ADDON_NAME)
    GameTooltip:AddLine(L["Left-click => Open/Close"] .. "|cffffcc00" .. " " .. ns.COLORED_ADDON_NAME,1,1,1)
    GameTooltip:AddLine(" ",1,1,1)
    GameTooltip:AddLine(L["Middle-Mouse-Button => Open/Close"] .. " => " .. "|cffffcc00" .. L["Disable MapNotes, all icons will be hidden on each map and all categories will be disabled"] .. " " .. SHOW .. " / " .. HIDE,1,1,1,1)
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

        if WorldMapFrame:GetMapID() == 12 or WorldMapFrame:GetMapID() == 948 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Kalimdor"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif WorldMapFrame:GetMapID() == 13 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Eastern Kingdom"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif WorldMapFrame:GetMapID() == 101 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Outland"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif WorldMapFrame:GetMapID() == 113 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Northrend"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif WorldMapFrame:GetMapID() == 424 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Pandaria"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif WorldMapFrame:GetMapID() == 572 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Draenor"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif WorldMapFrame:GetMapID() == 619 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Broken Isles"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif WorldMapFrame:GetMapID() == 875 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Zandalar"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif WorldMapFrame:GetMapID() == 876 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Kul Tiras"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif WorldMapFrame:GetMapID() == 1550 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Shadowlands"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif WorldMapFrame:GetMapID() == 1978 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Dragon Isles"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif WorldMapFrame:GetMapID() == 2274 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Khaz Algar"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        end

    end
       
    -- Zones without Sync function
    if not ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6) then
        --Kalimdor
        if (WorldMapFrame:GetMapID() == 1 or WorldMapFrame:GetMapID() == 7 or WorldMapFrame:GetMapID() == 10 or WorldMapFrame:GetMapID() == 11 or WorldMapFrame:GetMapID() == 57 or WorldMapFrame:GetMapID() == 62 
            or WorldMapFrame:GetMapID() == 63 or WorldMapFrame:GetMapID() == 64 or WorldMapFrame:GetMapID() == 65 or WorldMapFrame:GetMapID() == 66 or WorldMapFrame:GetMapID() == 67 or WorldMapFrame:GetMapID() == 68 
            or WorldMapFrame:GetMapID() == 69 or WorldMapFrame:GetMapID() == 70 or WorldMapFrame:GetMapID() == 71 or WorldMapFrame:GetMapID() == 74 or WorldMapFrame:GetMapID() == 75 or WorldMapFrame:GetMapID() == 76 
            or WorldMapFrame:GetMapID() == 77 or WorldMapFrame:GetMapID() == 78 or WorldMapFrame:GetMapID() == 80 or WorldMapFrame:GetMapID() == 81 or WorldMapFrame:GetMapID() == 83 or WorldMapFrame:GetMapID() == 97 
            or WorldMapFrame:GetMapID() == 106 or WorldMapFrame:GetMapID() == 199 or WorldMapFrame:GetMapID() == 327 or WorldMapFrame:GetMapID() == 460 or WorldMapFrame:GetMapID() == 461 or WorldMapFrame:GetMapID() == 462 
            or WorldMapFrame:GetMapID() == 468 or WorldMapFrame:GetMapID() == 1527 or WorldMapFrame:GetMapID() == 198 or WorldMapFrame:GetMapID() == 249)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kalimdor"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Eastern Kingdom
        elseif (WorldMapFrame:GetMapID() == 13 or WorldMapFrame:GetMapID() == 14 or WorldMapFrame:GetMapID() == 15 or WorldMapFrame:GetMapID() == 16 or WorldMapFrame:GetMapID() == 17 or WorldMapFrame:GetMapID() == 18 
            or WorldMapFrame:GetMapID() == 19 or WorldMapFrame:GetMapID() == 21 or WorldMapFrame:GetMapID() == 22 or WorldMapFrame:GetMapID() == 23 or WorldMapFrame:GetMapID() == 25 or WorldMapFrame:GetMapID() == 26 
            or WorldMapFrame:GetMapID() == 27 or WorldMapFrame:GetMapID() == 28 or WorldMapFrame:GetMapID() == 30 or WorldMapFrame:GetMapID() == 32 or WorldMapFrame:GetMapID() == 33 or WorldMapFrame:GetMapID() == 34 
            or WorldMapFrame:GetMapID() == 35 or WorldMapFrame:GetMapID() == 36 or WorldMapFrame:GetMapID() == 37 or WorldMapFrame:GetMapID() == 42 or WorldMapFrame:GetMapID() == 47 or WorldMapFrame:GetMapID() == 48 
            or WorldMapFrame:GetMapID() == 49 or WorldMapFrame:GetMapID() == 50 or WorldMapFrame:GetMapID() == 51 or WorldMapFrame:GetMapID() == 52 or WorldMapFrame:GetMapID() == 55 or WorldMapFrame:GetMapID() == 56 
            or WorldMapFrame:GetMapID() == 94 or WorldMapFrame:GetMapID() == 210 or WorldMapFrame:GetMapID() == 224 or WorldMapFrame:GetMapID() == 245 or WorldMapFrame:GetMapID() == 425 or WorldMapFrame:GetMapID() == 427 
            or WorldMapFrame:GetMapID() == 465 or WorldMapFrame:GetMapID() == 467 or WorldMapFrame:GetMapID() == 469 or WorldMapFrame:GetMapID() == 499 or WorldMapFrame:GetMapID() == 500 or WorldMapFrame:GetMapID() == 2070 
            or WorldMapFrame:GetMapID() == 241 or WorldMapFrame:GetMapID() == 203 or WorldMapFrame:GetMapID() == 204 or WorldMapFrame:GetMapID() == 205 or WorldMapFrame:GetMapID() == 241 or WorldMapFrame:GetMapID() == 244 
            or WorldMapFrame:GetMapID() == 245 or WorldMapFrame:GetMapID() == 201 or WorldMapFrame:GetMapID() == 95 or WorldMapFrame:GetMapID() == 122 or WorldMapFrame:GetMapID() == 217  or WorldMapFrame:GetMapID() == 226)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Eastern Kingdom"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()            
        --Outland
        elseif (WorldMapFrame:GetMapID() == 100 or WorldMapFrame:GetMapID() == 102 or WorldMapFrame:GetMapID() == 104 or WorldMapFrame:GetMapID() == 105 or WorldMapFrame:GetMapID() == 107 or WorldMapFrame:GetMapID() == 108
            or WorldMapFrame:GetMapID() == 109)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Outland"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()  
        --Northrend
        elseif (WorldMapFrame:GetMapID() == 114 or WorldMapFrame:GetMapID() == 115 or WorldMapFrame:GetMapID() == 116 or WorldMapFrame:GetMapID() == 117 or WorldMapFrame:GetMapID() == 118 or WorldMapFrame:GetMapID() == 119
            or WorldMapFrame:GetMapID() == 120 or WorldMapFrame:GetMapID() == 121 or WorldMapFrame:GetMapID() == 123 or WorldMapFrame:GetMapID() == 127 or WorldMapFrame:GetMapID() == 170)
        then 
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Northrend"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Pandaria
        elseif (WorldMapFrame:GetMapID() == 371 or WorldMapFrame:GetMapID() == 376 or WorldMapFrame:GetMapID() == 379 or WorldMapFrame:GetMapID() == 388 or WorldMapFrame:GetMapID() == 390 or WorldMapFrame:GetMapID() == 418
            or WorldMapFrame:GetMapID() == 422 or WorldMapFrame:GetMapID() == 433 or WorldMapFrame:GetMapID() == 434 or WorldMapFrame:GetMapID() == 504 or WorldMapFrame:GetMapID() == 554  or WorldMapFrame:GetMapID() == 1530
            or WorldMapFrame:GetMapID() == 507)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Pandaria"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Draenor
        elseif (WorldMapFrame:GetMapID() == 525 or WorldMapFrame:GetMapID() == 534 or WorldMapFrame:GetMapID() == 535 or WorldMapFrame:GetMapID() == 539 or WorldMapFrame:GetMapID() == 542 or WorldMapFrame:GetMapID() == 543
            or WorldMapFrame:GetMapID() == 550 or WorldMapFrame:GetMapID() == 588)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Draenor"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Broken Isles
        elseif (WorldMapFrame:GetMapID() == 630 or WorldMapFrame:GetMapID() == 634 or WorldMapFrame:GetMapID() == 641 or WorldMapFrame:GetMapID() == 646 or WorldMapFrame:GetMapID() == 650 or WorldMapFrame:GetMapID() == 652
            or WorldMapFrame:GetMapID() == 750 or WorldMapFrame:GetMapID() == 680 or WorldMapFrame:GetMapID() == 830 or WorldMapFrame:GetMapID() == 882 or WorldMapFrame:GetMapID() == 885 or WorldMapFrame:GetMapID() == 905
            or WorldMapFrame:GetMapID() == 941 or WorldMapFrame:GetMapID() == 790 or WorldMapFrame:GetMapID() == 971)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Broken Isles"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Zandalar
        elseif (WorldMapFrame:GetMapID() == 862 or WorldMapFrame:GetMapID() == 863 or WorldMapFrame:GetMapID() == 864 or WorldMapFrame:GetMapID() == 1355 or WorldMapFrame:GetMapID() == 1528)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Zandalar"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --KulTiras
        elseif (WorldMapFrame:GetMapID() == 895 or WorldMapFrame:GetMapID() == 896 or WorldMapFrame:GetMapID() == 942 or WorldMapFrame:GetMapID() == 1462 or WorldMapFrame:GetMapID() == 1169)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Kul Tiras"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Shadowlands
        elseif(WorldMapFrame:GetMapID() == 1525 or WorldMapFrame:GetMapID() == 1533 or WorldMapFrame:GetMapID() == 1536 or WorldMapFrame:GetMapID() == 1543 or WorldMapFrame:GetMapID() == 1565 or WorldMapFrame:GetMapID() == 1961
            or WorldMapFrame:GetMapID() == 1970 or WorldMapFrame:GetMapID() == 2016)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Shadowlands"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Dragon Isle
        elseif (WorldMapFrame:GetMapID() == 2022 or WorldMapFrame:GetMapID() == 2023 or WorldMapFrame:GetMapID() == 2024 or WorldMapFrame:GetMapID() == 2025 or WorldMapFrame:GetMapID() == 2026 or WorldMapFrame:GetMapID() == 2133
            or WorldMapFrame:GetMapID() == 2151 or WorldMapFrame:GetMapID() == 2200 or WorldMapFrame:GetMapID() == 2239)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Dragon Isles"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Khaz Algar
        elseif (WorldMapFrame:GetMapID() == 2248 or WorldMapFrame:GetMapID() == 2214 or WorldMapFrame:GetMapID() == 2215 or WorldMapFrame:GetMapID() == 2255 or WorldMapFrame:GetMapID() == 2256 or WorldMapFrame:GetMapID() == 2213 or WorldMapFrame:GetMapID() == 2216)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Khaz Algar"] .. " " .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        end
    end

    -- Zones Sync function
    if ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6) then
        --Kalimdor
        if (WorldMapFrame:GetMapID() == 1 or WorldMapFrame:GetMapID() == 7 or WorldMapFrame:GetMapID() == 10 or WorldMapFrame:GetMapID() == 11 or WorldMapFrame:GetMapID() == 57 or WorldMapFrame:GetMapID() == 62 
            or WorldMapFrame:GetMapID() == 63 or WorldMapFrame:GetMapID() == 64 or WorldMapFrame:GetMapID() == 65 or WorldMapFrame:GetMapID() == 66 or WorldMapFrame:GetMapID() == 67 or WorldMapFrame:GetMapID() == 68 
            or WorldMapFrame:GetMapID() == 69 or WorldMapFrame:GetMapID() == 70 or WorldMapFrame:GetMapID() == 71 or WorldMapFrame:GetMapID() == 74 or WorldMapFrame:GetMapID() == 75 or WorldMapFrame:GetMapID() == 76 
            or WorldMapFrame:GetMapID() == 77 or WorldMapFrame:GetMapID() == 78 or WorldMapFrame:GetMapID() == 80 or WorldMapFrame:GetMapID() == 81 or WorldMapFrame:GetMapID() == 83 or WorldMapFrame:GetMapID() == 97 
            or WorldMapFrame:GetMapID() == 106 or WorldMapFrame:GetMapID() == 199 or WorldMapFrame:GetMapID() == 327 or WorldMapFrame:GetMapID() == 460 or WorldMapFrame:GetMapID() == 461 or WorldMapFrame:GetMapID() == 462 
            or WorldMapFrame:GetMapID() == 468 or WorldMapFrame:GetMapID() == 1527 or WorldMapFrame:GetMapID() == 198 or WorldMapFrame:GetMapID() == 249)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Kalimdor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Eastern Kingdom
        elseif (WorldMapFrame:GetMapID() == 13 or WorldMapFrame:GetMapID() == 14 or WorldMapFrame:GetMapID() == 15 or WorldMapFrame:GetMapID() == 16 or WorldMapFrame:GetMapID() == 17 or WorldMapFrame:GetMapID() == 18 
            or WorldMapFrame:GetMapID() == 19 or WorldMapFrame:GetMapID() == 21 or WorldMapFrame:GetMapID() == 22 or WorldMapFrame:GetMapID() == 23 or WorldMapFrame:GetMapID() == 25 or WorldMapFrame:GetMapID() == 26 
            or WorldMapFrame:GetMapID() == 27 or WorldMapFrame:GetMapID() == 28 or WorldMapFrame:GetMapID() == 30 or WorldMapFrame:GetMapID() == 32 or WorldMapFrame:GetMapID() == 33 or WorldMapFrame:GetMapID() == 34 
            or WorldMapFrame:GetMapID() == 35 or WorldMapFrame:GetMapID() == 36 or WorldMapFrame:GetMapID() == 37 or WorldMapFrame:GetMapID() == 42 or WorldMapFrame:GetMapID() == 47 or WorldMapFrame:GetMapID() == 48 
            or WorldMapFrame:GetMapID() == 49 or WorldMapFrame:GetMapID() == 50 or WorldMapFrame:GetMapID() == 51 or WorldMapFrame:GetMapID() == 52 or WorldMapFrame:GetMapID() == 55 or WorldMapFrame:GetMapID() == 56 
            or WorldMapFrame:GetMapID() == 94 or WorldMapFrame:GetMapID() == 210 or WorldMapFrame:GetMapID() == 224 or WorldMapFrame:GetMapID() == 245 or WorldMapFrame:GetMapID() == 425 or WorldMapFrame:GetMapID() == 427 
            or WorldMapFrame:GetMapID() == 465 or WorldMapFrame:GetMapID() == 467 or WorldMapFrame:GetMapID() == 469 or WorldMapFrame:GetMapID() == 499 or WorldMapFrame:GetMapID() == 500 or WorldMapFrame:GetMapID() == 2070 
            or WorldMapFrame:GetMapID() == 241 or WorldMapFrame:GetMapID() == 203 or WorldMapFrame:GetMapID() == 204 or WorldMapFrame:GetMapID() == 205 or WorldMapFrame:GetMapID() == 241 or WorldMapFrame:GetMapID() == 244 
            or WorldMapFrame:GetMapID() == 245 or WorldMapFrame:GetMapID() == 201 or WorldMapFrame:GetMapID() == 95 or WorldMapFrame:GetMapID() == 122 or WorldMapFrame:GetMapID() == 217  or WorldMapFrame:GetMapID() == 226)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Eastern Kingdom"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()        
        --Outland
        elseif (WorldMapFrame:GetMapID() == 100 or WorldMapFrame:GetMapID() == 102 or WorldMapFrame:GetMapID() == 104 or WorldMapFrame:GetMapID() == 105 or WorldMapFrame:GetMapID() == 107 or WorldMapFrame:GetMapID() == 108
            or WorldMapFrame:GetMapID() == 109)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Outland"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Northrend
        elseif (WorldMapFrame:GetMapID() == 114 or WorldMapFrame:GetMapID() == 115 or WorldMapFrame:GetMapID() == 116 or WorldMapFrame:GetMapID() == 117 or WorldMapFrame:GetMapID() == 118 or WorldMapFrame:GetMapID() == 119
            or WorldMapFrame:GetMapID() == 120 or WorldMapFrame:GetMapID() == 121 or WorldMapFrame:GetMapID() == 123 or WorldMapFrame:GetMapID() == 127 or WorldMapFrame:GetMapID() == 170)
        then 
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Northrend"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Pandaria
        elseif (WorldMapFrame:GetMapID() == 371 or WorldMapFrame:GetMapID() == 376 or WorldMapFrame:GetMapID() == 379 or WorldMapFrame:GetMapID() == 388 or WorldMapFrame:GetMapID() == 390 or WorldMapFrame:GetMapID() == 418
            or WorldMapFrame:GetMapID() == 422 or WorldMapFrame:GetMapID() == 433 or WorldMapFrame:GetMapID() == 434 or WorldMapFrame:GetMapID() == 504 or WorldMapFrame:GetMapID() == 554  or WorldMapFrame:GetMapID() == 1530
            or WorldMapFrame:GetMapID() == 507)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Pandaria"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Draenor
        elseif (WorldMapFrame:GetMapID() == 525 or WorldMapFrame:GetMapID() == 534 or WorldMapFrame:GetMapID() == 535 or WorldMapFrame:GetMapID() == 539 or WorldMapFrame:GetMapID() == 542 or WorldMapFrame:GetMapID() == 543
            or WorldMapFrame:GetMapID() == 550 or WorldMapFrame:GetMapID() == 588)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Draenor"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Broken Isles
        elseif (WorldMapFrame:GetMapID() == 630 or WorldMapFrame:GetMapID() == 634 or WorldMapFrame:GetMapID() == 641 or WorldMapFrame:GetMapID() == 646 or WorldMapFrame:GetMapID() == 650 or WorldMapFrame:GetMapID() == 652
            or WorldMapFrame:GetMapID() == 750 or WorldMapFrame:GetMapID() == 680 or WorldMapFrame:GetMapID() == 830 or WorldMapFrame:GetMapID() == 882 or WorldMapFrame:GetMapID() == 885 or WorldMapFrame:GetMapID() == 905
            or WorldMapFrame:GetMapID() == 941 or WorldMapFrame:GetMapID() == 790 or WorldMapFrame:GetMapID() == 971)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Broken Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Zandalar
        elseif (WorldMapFrame:GetMapID() == 862 or WorldMapFrame:GetMapID() == 863 or WorldMapFrame:GetMapID() == 864 or WorldMapFrame:GetMapID() == 1355 or WorldMapFrame:GetMapID() == 1528)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Zandalar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --KulTiras
        elseif (WorldMapFrame:GetMapID() == 895 or WorldMapFrame:GetMapID() == 896 or WorldMapFrame:GetMapID() == 942 or WorldMapFrame:GetMapID() == 1462 or WorldMapFrame:GetMapID() == 1169)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Kul Tiras"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Shadowlands
        elseif(WorldMapFrame:GetMapID() == 1525 or WorldMapFrame:GetMapID() == 1533 or WorldMapFrame:GetMapID() == 1536 or WorldMapFrame:GetMapID() == 1543 or WorldMapFrame:GetMapID() == 1565 or WorldMapFrame:GetMapID() == 1961
            or WorldMapFrame:GetMapID() == 1970 or WorldMapFrame:GetMapID() == 2016)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Shadowlands"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Dragon Isle
        elseif (WorldMapFrame:GetMapID() == 2022 or WorldMapFrame:GetMapID() == 2023 or WorldMapFrame:GetMapID() == 2024 or WorldMapFrame:GetMapID() == 2025 or WorldMapFrame:GetMapID() == 2026 or WorldMapFrame:GetMapID() == 2133
            or WorldMapFrame:GetMapID() == 2151 or WorldMapFrame:GetMapID() == 2200 or WorldMapFrame:GetMapID() == 2239)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Dragon Isles"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        --Khaz Algar
        elseif (WorldMapFrame:GetMapID() == 2248 or WorldMapFrame:GetMapID() == 2214 or WorldMapFrame:GetMapID() == 2215 or WorldMapFrame:GetMapID() == 2255 or WorldMapFrame:GetMapID() == 2256 or WorldMapFrame:GetMapID() == 2213 or WorldMapFrame:GetMapID() == 2216)
        then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["synchronizes"] .. " " .. L["Khaz Algar"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        end
    end

    -- Dungeon Maps
    if info.mapType == 4 and not 
        (WorldMapFrame:GetMapID() == 1454 or WorldMapFrame:GetMapID() == 1456 -- Cata nodes
        or WorldMapFrame:GetMapID() == 2266 -- Millenias's Threshold
        or WorldMapFrame:GetMapID() == 84 or WorldMapFrame:GetMapID() == 87 or WorldMapFrame:GetMapID() == 89 or WorldMapFrame:GetMapID() == 103 or WorldMapFrame:GetMapID() == 85
        or WorldMapFrame:GetMapID() == 90 or WorldMapFrame:GetMapID() == 86 or WorldMapFrame:GetMapID() == 88 or WorldMapFrame:GetMapID() == 110 or WorldMapFrame:GetMapID() == 111
        or WorldMapFrame:GetMapID() == 125 or WorldMapFrame:GetMapID() == 126 or WorldMapFrame:GetMapID() == 391 or WorldMapFrame:GetMapID() == 392 or WorldMapFrame:GetMapID() == 393 
        or WorldMapFrame:GetMapID() == 394 or WorldMapFrame:GetMapID() == 582 or WorldMapFrame:GetMapID() == 590 or WorldMapFrame:GetMapID() == 622 or WorldMapFrame:GetMapID() == 624 
        or WorldMapFrame:GetMapID() == 626 or WorldMapFrame:GetMapID() == 627 or WorldMapFrame:GetMapID() == 628 or WorldMapFrame:GetMapID() == 629 or WorldMapFrame:GetMapID() == 1161
        or WorldMapFrame:GetMapID() == 1163 or WorldMapFrame:GetMapID() == 1164 or WorldMapFrame:GetMapID() == 1165 or WorldMapFrame:GetMapID() == 1670 or WorldMapFrame:GetMapID() == 1671 
        or WorldMapFrame:GetMapID() == 1672 or WorldMapFrame:GetMapID() == 1673 or WorldMapFrame:GetMapID() == 2112 or WorldMapFrame:GetMapID() == 407 or WorldMapFrame:GetMapID() == 2339 
        or WorldMapFrame:GetMapID() == 503 or WorldMapFrame:GetMapID() == 499 or WorldMapFrame:GetMapID() == 500) 
    then
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. DUNGEONS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end

    -- Capitals without Sync function
    if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and (WorldMapFrame:GetMapID() == 1454 or WorldMapFrame:GetMapID() == 1456 -- Cata nodes
        or WorldMapFrame:GetMapID() == 2266 -- Millenia's Threshold
        or WorldMapFrame:GetMapID() == 84 or WorldMapFrame:GetMapID() == 87 or WorldMapFrame:GetMapID() == 89 or WorldMapFrame:GetMapID() == 103 or WorldMapFrame:GetMapID() == 85
        or WorldMapFrame:GetMapID() == 90 or WorldMapFrame:GetMapID() == 86 or WorldMapFrame:GetMapID() == 88 or WorldMapFrame:GetMapID() == 110 or WorldMapFrame:GetMapID() == 111
        or WorldMapFrame:GetMapID() == 125 or WorldMapFrame:GetMapID() == 126 or WorldMapFrame:GetMapID() == 391 or WorldMapFrame:GetMapID() == 392 or WorldMapFrame:GetMapID() == 393 
        or WorldMapFrame:GetMapID() == 394 or WorldMapFrame:GetMapID() == 582 or WorldMapFrame:GetMapID() == 590 or WorldMapFrame:GetMapID() == 622 or WorldMapFrame:GetMapID() == 624 
        or WorldMapFrame:GetMapID() == 626 or WorldMapFrame:GetMapID() == 627 or WorldMapFrame:GetMapID() == 628 or WorldMapFrame:GetMapID() == 629 or WorldMapFrame:GetMapID() == 1161
        or WorldMapFrame:GetMapID() == 1163 or WorldMapFrame:GetMapID() == 1164 or WorldMapFrame:GetMapID() == 1165 or WorldMapFrame:GetMapID() == 1670 or WorldMapFrame:GetMapID() == 1671 
        or WorldMapFrame:GetMapID() == 1672 or WorldMapFrame:GetMapID() == 1673 or WorldMapFrame:GetMapID() == 2112 or WorldMapFrame:GetMapID() == 407 or WorldMapFrame:GetMapID() == 2339 
        or WorldMapFrame:GetMapID() == 503 or WorldMapFrame:GetMapID() == 499 or WorldMapFrame:GetMapID() == 500) 
    then
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Capitals"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end

    -- Capitals Sync function
    if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and (WorldMapFrame:GetMapID() == 1454 or WorldMapFrame:GetMapID() == 1456 -- Cata nodes
        or WorldMapFrame:GetMapID() == 2266 -- Millenia's Threshold
        or WorldMapFrame:GetMapID() == 84 or WorldMapFrame:GetMapID() == 87 or WorldMapFrame:GetMapID() == 89 or WorldMapFrame:GetMapID() == 103 or WorldMapFrame:GetMapID() == 85
        or WorldMapFrame:GetMapID() == 90 or WorldMapFrame:GetMapID() == 86 or WorldMapFrame:GetMapID() == 88 or WorldMapFrame:GetMapID() == 110 or WorldMapFrame:GetMapID() == 111
        or WorldMapFrame:GetMapID() == 125 or WorldMapFrame:GetMapID() == 126 or WorldMapFrame:GetMapID() == 391 or WorldMapFrame:GetMapID() == 392 or WorldMapFrame:GetMapID() == 393 
        or WorldMapFrame:GetMapID() == 394 or WorldMapFrame:GetMapID() == 582 or WorldMapFrame:GetMapID() == 590 or WorldMapFrame:GetMapID() == 622 or WorldMapFrame:GetMapID() == 624 
        or WorldMapFrame:GetMapID() == 626 or WorldMapFrame:GetMapID() == 627 or WorldMapFrame:GetMapID() == 628 or WorldMapFrame:GetMapID() == 629 or WorldMapFrame:GetMapID() == 1161
        or WorldMapFrame:GetMapID() == 1163 or WorldMapFrame:GetMapID() == 1164 or WorldMapFrame:GetMapID() == 1165 or WorldMapFrame:GetMapID() == 1670 or WorldMapFrame:GetMapID() == 1671 
        or WorldMapFrame:GetMapID() == 1672 or WorldMapFrame:GetMapID() == 1673 or WorldMapFrame:GetMapID() == 2112 or WorldMapFrame:GetMapID() == 407 or WorldMapFrame:GetMapID() == 2339 
        or WorldMapFrame:GetMapID() == 503 or WorldMapFrame:GetMapID() == 499 or WorldMapFrame:GetMapID() == 500) 
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