local myname, ns = ...
local _, myfullname = C_AddOns.GetAddOnInfo(myname)

ns.suppressoverlay = {}

local function isChecked(key) return ns.db[key] end
local function toggleChecked(key)
    ns.db[key] = not ns.db[key]
    ns.HL:Refresh()
end

local function hideTextureWithAtlas(atlas, ...)
    for i=1, select("#", ...) do
        local region = select(i, ...)
        if region:IsObjectType("Texture") and region:GetAtlas() == atlas then
            region:Hide()
        end
    end
end
local defaultSort = function(a, b) return a < b end
local function iterKeysByValue(tbl, sortFunction)
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys, function(a, b)
        return (sortFunction or defaultSort)(tbl[a], tbl[b])
    end)
    return ipairs(keys)
end
local OptionsDropdown = {}
do
    local inherited = {"set", "get", "func", "confirm", "validate", "disabled", "hidden"}
    local function inherit(t1, t2)
        for _,k in ipairs(inherited) do
            if t2[k] ~= nil then
                t1[k] = t2[k]
            end
        end
    end
    local nodet = {}
    function OptionsDropdown.node(options, ...)
        wipe(nodet)
        local node = options
        inherit(nodet, node)
        for i=1, select('#', ...) do
            node = node.args[select(i, ...)]
            if not node then return end
            inherit(nodet, node)
        end
        return ns.merge(nodet, node)
    end
    local info = {}
    function OptionsDropdown.makeInfo(options, ...)
        local node = OptionsDropdown.node(options, ...)
        wipe(info)
        info.options = options
        info.option = node
        info.arg = node.arg
        info.type = node.type
        info.handler = node.handler
        info.uiType = "dropdown"
        info.uiName = "HandyNotesTreasures-Dropdown"
        info[0] = "" -- not a slashcommand
        for i=1, select('#', ...) do
            info[i] = select(i, ...)
        end
        return info
    end
    local function nodeValueOrFunc(key, options, ...)
        local node = OptionsDropdown.node(options, ...)
        if not node then return end
        if type(node[key]) == "function" then
            return node[key](OptionsDropdown.makeInfo(options, ...))
        end
        return node[key]
    end
    function OptionsDropdown.isHidden(options, ...)
        return nodeValueOrFunc('hidden', options, ...)
    end
    function OptionsDropdown.values(options, ...)
        return nodeValueOrFunc('values', options, ...)
    end

    local function executeHandler(func)
        func()
        ns.HL:Refresh()
    end
    function OptionsDropdown.FillFromArgs(args, description)
        local sorted = {}
        for key in pairs(args) do
            table.insert(sorted, key)
        end
        table.sort(sorted, function(a, b)
            return (args[a].order or 0) < (args[b].order or 0)
        end)
        for _, key in ipairs(sorted) do
            local option = args[key]
            if not option.dropdownHidden and (option.type == "toggle" or option.type == "execute") then
                local item
                if option.type == "toggle" then
                    item = description:CreateCheckbox(option.name, isChecked, toggleChecked, key)
                elseif option.type == "execute" then
                    item = description:CreateButton(option.name, executeHandler, option.func)
                end
                if option.disabled then
                    item:SetEnabled(not option.disabled())
                end
                if option.desc then
                    item:SetTitleAndTextTooltip(nil, option.desc)
                end
            end
        end
    end
end
local zoneGroups, zoneHasGroups, zoneAchievements, zoneHasAchievements, allGroups, hasGroups
do
    local gcache
    function allGroups()
        if not gcache then
            gcache = {}
            for _, points in pairs(ns.points) do
                for _, point in pairs(points) do
                    if point.group then
                        gcache[point.group] = point.group
                    end
                end
            end
        end
        return gcache
    end
    function hasGroups()
        local groups = allGroups()
        for _ in pairs(groups) do
            return true
        end
    end
    local zcache = {}
    function zoneGroups(uiMapID)
        if not zcache[uiMapID] then
            local relevant = {}
            for _, point in pairs(ns.points[uiMapID] or {}) do
                if point.group then
                    relevant[point.group] = point.group
                end
            end
            zcache[uiMapID] = relevant
        end
        return zcache[uiMapID]
    end
    function zoneHasGroups(uiMapID)
        for _, _ in pairs(zoneGroups(uiMapID)) do
            return true
        end
    end
    local acache = {}
    function zoneAchievements(uiMapID)
        if not acache[uiMapID] then
            local relevant = {}
            for _, point in pairs(ns.points[uiMapID] or {}) do
                if point.achievement then
                    relevant[point.achievement] = true
                end
            end
            acache[uiMapID] = relevant
        end
        return acache[uiMapID]
    end
    function zoneHasAchievements(uiMapID)
        for _, _ in pairs(zoneAchievements(uiMapID)) do
            return true
        end
    end
end
function ns.SetupMapOverlay()
    local frame
    local Krowi = LibStub("Krowi_WorldMapButtons-1.4", true)
    if Krowi then
        frame = Krowi:Add(nil, "DropdownButton")
    else
        -- (this is a close translation of WorldMapTrackingOptionsButtonTemplate)
        frame = CreateFrame("DropdownButton", WorldMapFrame, WorldMapFrame:GetCanvasContainer())
        frame:SetPoint("TOPRIGHT", -68, -2)
        hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
            frame:Refresh()
        end)
    end
    frame:SetFrameStrata(ns.CLASSIC and "TOOLTIP" or "HIGH")
    frame:SetSize(32, 32)
    frame.Background = frame:CreateTexture(nil, "BACKGROUND")
    frame.Background:SetPoint("TOPLEFT", 2, -4)
    frame.Background:SetSize(25, 25)
    frame.Background:SetTexture([[Interface\Minimap\UI-Minimap-Background]])
    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:SetTexture([[Interface\Minimap\Tracking\None]])
    frame.Icon:SetSize(20, 20)
    frame.Icon:SetPoint("TOPLEFT", 6, -6)
    frame.Border = frame:CreateTexture(nil, "OVERLAY", nil, -1)
    frame.Border:SetTexture([[Interface\Minimap\MiniMap-TrackingBorder]])
    frame.Border:SetSize(54, 54)
    frame.Border:SetPoint("TOPLEFT")
    frame:SetHighlightTexture([[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]], "ADD")

    frame.Icon:SetAtlas("VignetteLootElite")
    frame.Icon:SetPoint("TOPLEFT", 6, -5)
    hideTextureWithAtlas("MapCornerShadow-Right", frame:GetRegions())
    frame.Refresh = function(self)
        local uiMapID = WorldMapFrame.mapID
        local info = C_Map.GetMapInfo(uiMapID)
        local parentMapID = info and info.parentMapID or 0
        if ns.db.worldmapoverlay and (
            (ns.points[uiMapID] and not ns.suppressoverlay[uiMapID]) or
            (ns.points[parentMapID] and not ns.suppressoverlay[parentMapID])
        ) then
            self:Show()
        else
            self:Hide()
        end
    end
    frame.OnMouseDown = function(self, button)
        if IsAltKeyDown() then
            -- undiscoverable debug helper:
            ns.db.found = not ns.db.found
            return ns.HL:Refresh()
        end
        self.Icon:SetPoint("TOPLEFT", 8, -8);
        self.Icon:SetAlpha(0.5)
    end
    frame.OnMouseUp = function(self)
        self.Icon:SetPoint("TOPLEFT", 6, -5)
        self.Icon:SetAlpha(1)
    end
    frame.OnMouseEnter = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip, myfullname)
        GameTooltip_AddNormalLine(GameTooltip, "Adjust display settings")
        GameTooltip:Show()
    end
    frame:SetScript("OnMouseUp", frame.OnMouseUp)
    frame:SetScript("OnMouseDown", frame.OnMouseDown)
    frame:SetScript("OnEnter", frame.OnMouseEnter)
    frame:SetScript("OnLeave", GameTooltip_Hide)

    local function createVisibility(description)
        local key = description:GetData() .. "_filter"
        local function isVisible(val)
            return ns.db[key] == val
        end
        local function setVisible(val)
            ns.db[key] = val
            ns.HL:Refresh()
            return MenuResponse.Close
        end
        description:CreateRadio(ALL, isVisible, setVisible, "all")
        description:CreateRadio("Will drop loot", isVisible, setVisible, "lootable")
        description:CreateRadio("Will drop notable loot", isVisible, setVisible, "notable")

        return description
    end

    local function achievementIsChecked(achievementid)
        return not ns.db.achievementsHidden[achievementid]
    end
    local function achievementToggleChecked(achievementid)
        ns.db.achievementsHidden[achievementid] = not ns.db.achievementsHidden[achievementid]
        ns.HL:Refresh()
    end

    frame:SetupMenu(function(dropdown, rootDescription)
        local uiMapID = WorldMapFrame.mapID -- self:GetParent():GetMapID()
        if not uiMapID then return false end
        rootDescription:SetTag("MENU_WORLD_MAP_"..myname)
        -- rootDescription:CreateTitle(myfullname)
        rootDescription:CreateTitle(SHOW)
        local npcs = createVisibility(rootDescription:CreateCheckbox("NPCs", isChecked, toggleChecked, "show_npcs"))
        npcs:CreateDivider()
        OptionsDropdown.FillFromArgs(ns.options.args.common.args.display.args.npcs.args, npcs)

        local treasure = createVisibility(rootDescription:CreateCheckbox("Treasure", isChecked, toggleChecked, "show_treasure"))

        OptionsDropdown.FillFromArgs(ns.options.args.common.args.display.args, rootDescription)

        rootDescription:QueueDivider()
        rootDescription:QueueTitle("Nearby types")

        local showZoneGroups = not (ns.hiddenConfig.groupsHiddenByZone and OptionsDropdown.isHidden(ns.options.args.data, "groupsHidden")) and zoneHasGroups(uiMapID)
        local showZoneAchievements = not OptionsDropdown.isHidden(ns.options.args.data, "achievementsHidden") and zoneHasAchievements(uiMapID)

        if showZoneGroups then
            local global = not ns.hiddenConfig.groupsHidden
            local function groupIsChecked(group)
                if global then
                    return not ns.db.groupsHidden[group]
                end
                return not ns.db.groupsHiddenByZone[uiMapID][group]
            end
            local function groupToggleChecked(group)
                if global then
                    ns.db.groupsHidden[group] = not ns.db.groupsHidden[group]
                else
                    ns.db.groupsHiddenByZone[uiMapID][group] = not ns.db.groupsHiddenByZone[uiMapID][group]
                end
                ns.HL:Refresh()
            end
            local function groupTooltip(tooltip)
                GameTooltip_AddNormalLine(tooltip, global and "Show this type of point everywhere" or "Show this type of point on this map")
            end
            for _, group in iterKeysByValue(zoneGroups(uiMapID)) do
                rootDescription:CreateCheckbox(ns.render_string(ns.groups[group] or group), groupIsChecked, groupToggleChecked, group):SetTooltip(groupTooltip)
            end
        end
        if showZoneAchievements then
            local function achievementTooltip(tooltip)
                GameTooltip_AddNormalLine(tooltip, "Show this type of point")
            end
            for achievementid in pairs(zoneAchievements(uiMapID)) do
                rootDescription:CreateCheckbox(ns.render_string(("{achievement:%d}"):format(achievementid)), achievementIsChecked, achievementToggleChecked, achievementid):SetTooltip(achievementTooltip)
            end
        end

        rootDescription:ClearQueuedDescriptions()

        rootDescription:QueueDivider()
        rootDescription:QueueTitle("All types")

        local showAchievements = not OptionsDropdown.isHidden(ns.options.args.data, "achievementsHidden")
        if showAchievements then
            local achievementSubmenu = rootDescription:CreateButton(ACHIEVEMENTS)
            local relevant = zoneAchievements(uiMapID)
            local values = OptionsDropdown.values(ns.options.args.data, "achievementsHidden")
            for _, achievementid in iterKeysByValue(values) do
                local label = values[achievementid]
                if relevant[achievementid] then
                    label = BRIGHTBLUE_FONT_COLOR:WrapTextInColorCode(label) .. " " .. CreateAtlasMarkup("VignetteKill", 0)
                end
                achievementSubmenu:CreateCheckbox(label, achievementIsChecked, achievementToggleChecked, achievementid)
            end
        end
        local showZones = not OptionsDropdown.isHidden(ns.options.args.data, "zonesHidden")
        if showZones then
            local zonesSubmenu = rootDescription:CreateButton(ZONE)
            local function isZoneChecked(zoneUiMapID) return not ns.db.zonesHidden[zoneUiMapID] end
            local function toggleZoneChecked(zoneUiMapID)
                ns.db.zonesHidden[zoneUiMapID] = not ns.db.zonesHidden[zoneUiMapID]
                ns.HL:Refresh()
            end
            local values = OptionsDropdown.values(ns.options.args.data, "zonesHidden")
            for _, zoneUiMapID in iterKeysByValue(values) do
                local label = values[zoneUiMapID]
                if uiMapID == zoneUiMapID then
                    label = BRIGHTBLUE_FONT_COLOR:WrapTextInColorCode(label) .. " " .. CreateAtlasMarkup("VignetteKill", 0)
                end
                local zoneSubmenu = zonesSubmenu:CreateCheckbox(label, isZoneChecked, toggleZoneChecked, zoneUiMapID)

                if not ns.hiddenConfig.groupsHiddenByZone and zoneHasGroups(zoneUiMapID) then
                    local function isGroupChecked(group) return not ns.db.groupsHiddenByZone[zoneUiMapID][group] end
                    local function toggleGroupChecked(group)
                        ns.db.groupsHiddenByZone[zoneUiMapID][group] = not ns.db.groupsHiddenByZone[zoneUiMapID][group]
                        ns.HL:Refresh()
                    end
                    local function groupTooltip(tooltip)
                        GameTooltip_AddNormalLine(tooltip, "Hide this type of point on this map")
                    end
                    local groups = zoneGroups(zoneUiMapID)
                    for _, group in iterKeysByValue(groups) do
                        local item = zoneSubmenu:CreateCheckbox(ns.render_string(ns.groups[group] or group), isGroupChecked, toggleGroupChecked, group)
                        item:SetEnabled(not ns.db.groupsHidden[group])
                        item:SetTooltip(groupTooltip)
                    end
                end
            end
        end
        local showGroups = not OptionsDropdown.isHidden(ns.options.args.data, "groupsHidden") and hasGroups()
        if showGroups then
            local groupSubmenu = rootDescription:CreateButton(GROUP)
            local function isGroupChecked(group) return not ns.db.groupsHidden[group] end
            local function toggleGroupChecked(group)
                ns.db.groupsHidden[group] = not ns.db.groupsHidden[group]
                ns.HL:Refresh()
            end
            local function groupTooltip(tooltip)
                GameTooltip_AddNormalLine(tooltip, "Hide this type of point everywhere")
            end
            local groups = allGroups()
            for _, group in iterKeysByValue(groups) do
                groupSubmenu:CreateCheckbox(ns.render_string(ns.groups[group] or group), isGroupChecked, toggleGroupChecked, group)
            end
        end

        rootDescription:ClearQueuedDescriptions()
        rootDescription:CreateDivider()

        local notabilitySubmenu = rootDescription:CreateButton("What's notable?")
        OptionsDropdown.FillFromArgs(ns.options.args.common.args.notable.args, notabilitySubmenu)

        local settingsSubmenu = rootDescription:CreateButton("More settings")
        settingsSubmenu:CreateTitle(ns.options.args.common.args.found.name)
        OptionsDropdown.FillFromArgs(ns.options.args.common.args.found.args, settingsSubmenu)
        settingsSubmenu:CreateTitle(ns.options.args.common.args.tooltips.name)
        OptionsDropdown.FillFromArgs(ns.options.args.common.args.tooltips.args, settingsSubmenu)
        settingsSubmenu:CreateTitle(ns.options.args.common.args.fiddly.name)
        OptionsDropdown.FillFromArgs(ns.options.args.common.args.fiddly.args, settingsSubmenu)

        rootDescription:CreateButton("Open HandyNotes options", function()
            if InterfaceOptionsFrame_Show then
                InterfaceOptionsFrame_Show()
                InterfaceOptionsFrame_OpenToCategory('HandyNotes')
            else
                Settings.OpenToCategory('HandyNotes')
            end
            LibStub('AceConfigDialog-3.0'):SelectGroup('HandyNotes', 'plugins', (myname:gsub("HandyNotes_", "")))
        end)
    end)
end
