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
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffff0000", L["All MapNotes icons have been hidden"])
        else
            ns.Addon.db.profile.activate.HideMapNote = false
            print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cff00ff00", L["All set icons have been restored"])
        end

    end

    if button == "RightButton" then 

        if GetCurrentMapID == 946 then -- World Map
        
            if not ns.Addon.db.profile.activate.CosmosMap then
                ns.Addon.db.profile.activate.CosmosMap = true
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", WORLDMAP_BUTTON, "|cff00ff00" .. L["is activated"])
            else
                ns.Addon.db.profile.activate.CosmosMap = false
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", WORLDMAP_BUTTON, "|cffff0000" .. L["is deactivated"])
            end

        end

        if GetCurrentMapID == 947 then-- Azeroth World Map

            if not ns.Addon.db.profile.activate.Azeroth then
                ns.Addon.db.profile.activate.Azeroth = true
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. WORLD_MAP, "|cff00ff00" .. L["is activated"])
            else
                ns.Addon.db.profile.activate.Azeroth = false
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. WORLD_MAP, "|cffff0000" .. L["is deactivated"])
            end

        end

        -- Continent Maps
        if info.mapType == 2 then 

            if GetCurrentMapID == 1414 then
                if ns.Addon.db.profile.showContinentKalimdor then
                    ns.Addon.db.profile.showContinentKalimdor = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Kalimdor"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentKalimdor = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Kalimdor"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            elseif GetCurrentMapID == 1415 then
                if ns.Addon.db.profile.showContinentEasternKingdom then
                    ns.Addon.db.profile.showContinentEasternKingdom = false
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Eastern Kingdom"], L["icons"], "|cffff0000" .. L["are hidden"])
                else
                    ns.Addon.db.profile.showContinentEasternKingdom = true
                    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Eastern Kingdom"], L["icons"], "|cff00ff00" .. L["are shown"])
                end
            end

        end

        -- Dungeon Maps
        if info.mapType == 4 and not 
            (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 or GetCurrentMapID == 1458 or GetCurrentMapID == 1954
            or GetCurrentMapID == 1947 or GetCurrentMapID == 1457 or GetCurrentMapID == 1453 or GetCurrentMapID == 1455
            or GetCurrentMapID == 1955 or GetCurrentMapID == 86 or GetCurrentMapID == 125 or GetCurrentMapID == 126 )
        then
        
            if not ns.Addon.db.profile.activate.DungeonMap then
                ns.Addon.db.profile.activate.DungeonMap = true
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dungeon map"], "|cff00ff00" .. L["is activated"])
            else
                ns.Addon.db.profile.activate.DungeonMap = false
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dungeon map"], "|cffff0000" .. L["is deactivated"])
            end

        end

        --Zones without Sync function
        if not ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6) and not 
            (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 or GetCurrentMapID == 1458 or GetCurrentMapID == 1954
            or GetCurrentMapID == 1947 or GetCurrentMapID == 1457 or GetCurrentMapID == 1453 or GetCurrentMapID == 1455
            or GetCurrentMapID == 1955 or GetCurrentMapID == 86 or GetCurrentMapID == 125 or GetCurrentMapID == 126)  then
        
            if not ns.Addon.db.profile.activate.ZoneMap then
                ns.Addon.db.profile.activate.ZoneMap = true
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zone map"], L["icons"], "|cff00ff00" .. L["are shown"])
            else
                ns.Addon.db.profile.activate.ZoneMap = false
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zone map"], L["icons"], "|cffff0000" .. L["are hidden"])
            end

        end

        --Zones Sync function
        if ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6 ) and not 
            (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 or GetCurrentMapID == 1458 or GetCurrentMapID == 1954
            or GetCurrentMapID == 1947 or GetCurrentMapID == 1457 or GetCurrentMapID == 1453 or GetCurrentMapID == 1455
            or GetCurrentMapID == 1955 or GetCurrentMapID == 86 or GetCurrentMapID == 125 or GetCurrentMapID == 126) then
        
            if not ns.Addon.db.profile.activate.ZoneMap then
                ns.Addon.db.profile.activate.ZoneMap = true
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["are shown"])
            else
                ns.Addon.db.profile.activate.ZoneMap = false
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["synchronizes"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"])
            end

        end

        --Capitals without Sync function
        if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and 
        (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 or GetCurrentMapID == 1458 or GetCurrentMapID == 1954
        or GetCurrentMapID == 1947 or GetCurrentMapID == 1457 or GetCurrentMapID == 1453 or GetCurrentMapID == 1455
        or GetCurrentMapID == 1955 or GetCurrentMapID == 86 or GetCurrentMapID == 125 or GetCurrentMapID == 126) then
        
            if not ns.Addon.db.profile.activate.Capitals then
                ns.Addon.db.profile.activate.Capitals = true
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], L["icons"], "|cff00ff00" .. L["are shown"])
            else
                ns.Addon.db.profile.activate.Capitals = false
                print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], L["icons"], "|cffff0000" .. L["are hidden"])
            end

        end

        --Capitals Sync function
        if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and 
            (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 or GetCurrentMapID == 1458 or GetCurrentMapID == 1954
            or GetCurrentMapID == 1947 or GetCurrentMapID == 1457 or GetCurrentMapID == 1453 or GetCurrentMapID == 1455
            or GetCurrentMapID == 1955 or GetCurrentMapID == 86 or GetCurrentMapID == 125 or GetCurrentMapID == 126)  then
        
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


function WorldMapOptionsButtonMixin:OnMouseDown(button)
    self.Icon:SetPoint('TOPLEFT', 8, -8)

end


function WorldMapOptionsButtonMixin:OnMouseUp()
    self.Icon:SetPoint('TOPLEFT', self, 'TOPLEFT', 6, -6)
end


function WorldMapOptionsButtonMixin:OnEnter()
local info = C_Map.GetMapInfo(WorldMapFrame:GetMapID())
local GetCurrentMapID = WorldMapFrame:GetMapID()

    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip_SetTitle(GameTooltip, ns.COLORED_ADDON_NAME)
    GameTooltip:AddLine(L["Left-click => Open/Close"] .. "|cffffcc00" .. " " .. ns.COLORED_ADDON_NAME,1,1,1)
    GameTooltip:AddLine(" ",1,1,1)
    GameTooltip:AddLine(L["Middle-Mouse-Button => Open/Close"] .. " => " .. "|cffffcc00" .. L["Disable MapNotes, all icons will be hidden on each map and all categories will be disabled"] .. " " .. SHOW .. " / " .. HIDE,1,1,1,1)
    GameTooltip:AddLine(" ",1,1,1)

    if GetCurrentMapID == 946 then -- World Map
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. WORLDMAP_BUTTON .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end

    if GetCurrentMapID == 947 then-- Azeroth World Map
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. WORLD_MAP .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end    

    -- Continent Maps
    if info.mapType == 2 then 

        if GetCurrentMapID == 1414 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Kalimdor"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        elseif GetCurrentMapID == 1415 then
            GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000" .. L["Continent map"] .. " " .. L["Eastern Kingdom"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
            GameTooltip:Show()
        end

    end

    --Zones without Sync function
    if not ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6 or GetCurrentMapID == 327 or GetCurrentMapID == 2266) and not 
        (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 or GetCurrentMapID == 1458 or GetCurrentMapID == 1954
        or GetCurrentMapID == 1947 or GetCurrentMapID == 1457 or GetCurrentMapID == 1453 or GetCurrentMapID == 1455
        or GetCurrentMapID == 1955 or GetCurrentMapID == 86 or GetCurrentMapID == 125 or GetCurrentMapID == 126) then
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Zone map"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end

    --Zones Sync function
    if ns.Addon.db.profile.activate.SyncZoneAndMinimap and (info.mapType == 3 or info.mapType == 5 or info.mapType == 6 or GetCurrentMapID == 327) and not 
        (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 or GetCurrentMapID == 1458 or GetCurrentMapID == 1954
        or GetCurrentMapID == 1947 or GetCurrentMapID == 1457 or GetCurrentMapID == 1453 or GetCurrentMapID == 1455
        or GetCurrentMapID == 1955 or GetCurrentMapID == 86 or GetCurrentMapID == 125 or GetCurrentMapID == 126) then
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Zones"] .. " & " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end

    --Dungeon Maps
    if info.mapType == 4 and not 
        (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 or GetCurrentMapID == 1458 or GetCurrentMapID == 1954
        or GetCurrentMapID == 1947 or GetCurrentMapID == 1457 or GetCurrentMapID == 1453 or GetCurrentMapID == 1455
        or GetCurrentMapID == 1955 or GetCurrentMapID == 86 or GetCurrentMapID == 125 or GetCurrentMapID == 126 )
    then
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. DUNGEONS .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end

    -- Capitals without Sync function
    if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and 
        (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 or GetCurrentMapID == 1458 or GetCurrentMapID == 1954
        or GetCurrentMapID == 1947 or GetCurrentMapID == 1457 or GetCurrentMapID == 1453 or GetCurrentMapID == 1455
        or GetCurrentMapID == 1955 or GetCurrentMapID == 86 or GetCurrentMapID == 125 or GetCurrentMapID == 126) then
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Capitals"] .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end

    -- Capitals Sync function
    if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap and 
        (GetCurrentMapID == 1454 or GetCurrentMapID == 1456 or GetCurrentMapID == 1458 or GetCurrentMapID == 1954
        or GetCurrentMapID == 1947 or GetCurrentMapID == 1457 or GetCurrentMapID == 1453 or GetCurrentMapID == 1455
        or GetCurrentMapID == 1955 or GetCurrentMapID == 86 or GetCurrentMapID == 125 or GetCurrentMapID == 126) then
        GameTooltip:AddLine(HELPFRAME_REPORT_PLAYER_RIGHT_CLICK .. " => " .. "|cffff0000".. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. "|cffffcc00" .. " " .. L["icons"] .. " " .. SHOW .. " / " .. HIDE,1,1,1)
        GameTooltip:Show()
    end
end



function WorldMapOptionsButtonMixin:Refresh()

end