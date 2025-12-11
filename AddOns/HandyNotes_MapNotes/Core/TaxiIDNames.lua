local ADDON_NAME, ns = ...

local function SplitTaxiName(rawName)
    if not rawName then return nil, nil end

    local base, zone = rawName:match("^(.-),%s*(.+)$")
    if base then
        return base, zone
    else
        return rawName, nil
    end
end

local function GetTaxiNameOnActiveMap(taxiID)
    if not taxiID or not C_TaxiMap or not C_TaxiMap.GetTaxiNodesForMap then return nil end

    local mapID = (WorldMapFrame and WorldMapFrame:IsShown() and WorldMapFrame:GetMapID()) or C_Map.GetBestMapForUnit("player")
    if not mapID then return nil end

    local nodes = C_TaxiMap.GetTaxiNodesForMap(mapID) or {}
    if #nodes == 0 then
        local info = C_Map.GetMapInfo(mapID)
        if info and info.parentMapID then
            nodes = C_TaxiMap.GetTaxiNodesForMap(info.parentMapID) or nodes
        end
    end

    for _, n in ipairs(nodes) do
        if n.nodeID == taxiID then
            local raw = n.name or (C_TaxiMap.GetTaxiNodeName and C_TaxiMap.GetTaxiNodeName(n.nodeID)) or "?"
            return SplitTaxiName(raw)
        end
    end
end

function ns.AddTaxiStatusToTooltip(tooltip, taxiID)
    if not taxiID then return end

    local base, zone = GetTaxiNameOnActiveMap(taxiID)
    if not base then return end

    tooltip:AddLine(base) -- only name without zone name

    --  if zone then -- name and zone name
    --      tooltip:AddLine(base .. ", " .. zone)
    --  end
end