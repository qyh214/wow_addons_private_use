local myname, ns = ...
local _, myfullname = C_AddOns.GetAddOnInfo(myname)

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

ns.suppressoverlay = {}

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

    function OptionsDropdown.FillFromArgs(args, info, level)
        wipe(info)
        info.isNotRadio = true
        info.keepShownOnClick = true
        info.tooltipOnButton = true
        info.func = function(button)
            local checked = button.checked
            local value = button.value
            if (checked) then
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            else
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
            end
            local option = args[value]
            if option.type == "execute" then
                option.func()
            else
                ns.db[value] = checked
            end
            ns.HL:Refresh()
        end

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
                info.text = option.name
                info.tooltipTitle = option.desc
                info.value = key
                if option.type == "toggle" then
                    info.notCheckable = nil
                    info.checked = ns.db[key]
                elseif option.type == "execute" then
                    info.notCheckable = true
                    info.checked = nil
                end
                if option.disabled then
                    info.disabled = option.disabled()
                else
                    info.disabled = nil
                end
                LibDD:UIDropDownMenu_AddButton(info, level)
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
    local Krowi = LibStub("Krowi_WorldMapButtons-1.4", true) or LibStub("Krowi_WorldMapButtons-1.3", true)
    if Krowi then
        frame = Krowi:Add(nil, "DropDownToggleButton")
    --elseif false and WorldMapFrame.AddOverlayFrame then
        -- retail
        -- This is super-tainted on retail, so is currently disabled
        -- frame = WorldMapFrame:AddOverlayFrame("WorldMapTrackingOptionsButtonTemplate", "DROPDOWNTOGGLEBUTTON", "TOPRIGHT", WorldMapFrame:GetCanvasContainer(), "TOPRIGHT", -68, -2)
    else
        -- (this is a close translation of WorldMapTrackingOptionsButtonTemplate)
        frame = CreateFrame("DropDownToggleButton", WorldMapFrame, WorldMapFrame:GetCanvasContainer())
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
    frame.IconOverlay = frame:CreateTexture(nil, "OVERLAY")
    frame.IconOverlay:Hide()
    frame.IconOverlay:SetPoint("TOPLEFT", frame.Icon)
    frame.IconOverlay:SetPoint("BOTTOMRIGHT", frame.Icon)
    frame.IconOverlay:SetColorTexture(0, 0, 0, 0.5)
    frame.Border = frame:CreateTexture(nil, "OVERLAY", nil, -1)
    frame.Border:SetTexture([[Interface\Minimap\MiniMap-TrackingBorder]])
    frame.Border:SetSize(54, 54)
    frame.Border:SetPoint("TOPLEFT")
    frame:SetHighlightTexture([[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]], "ADD")

    -- replace the default dropdown:
    frame.DropDown = LibDD:Create_UIDropDownMenu(myname .. "OptionsDropdown", frame) -- replace the template
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
        self.IconOverlay:Show()

        local uiMapID = WorldMapFrame.mapID
        if not uiMapID then
            return
        end
        LibDD:ToggleDropDownMenu(1, nil, self.DropDown, self, 0, -5)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
    frame.OnMouseUp = function(self)
        self.Icon:SetPoint("TOPLEFT", 6, -5)
        self.IconOverlay:Hide()
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
    frame.InitializeDropDown = function(self, level, menuList)
        local uiMapID = WorldMapFrame.mapID
        local info = LibDD:UIDropDownMenu_CreateInfo()
        level = level or 1
        if level == 1 then
            info.isTitle = true
            info.notCheckable = true
            info.text = SHOW
            LibDD:UIDropDownMenu_AddButton(info, level)

            wipe(info)
            info.hasArrow = true
            info.isNotRadio = true
            info.notCheckable = nil
            info.keepShownOnClick = true
            info.func = function(button)
                local checked = button.checked
                local value = button.value
                if (checked) then
                    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                else
                    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
                end
                ns.db[value] = checked
                ns.HL:Refresh()
            end

            info.text = "NPCs"
            info.checked = ns.db.show_npcs
            info.value = "show_npcs"
            LibDD:UIDropDownMenu_AddButton(info, level)

            info.text = "Treasure"
            info.checked = ns.db.show_treasure
            info.value = "show_treasure"
            LibDD:UIDropDownMenu_AddButton(info, level)

            -- OptionsDropdown.FillFromArgs(ns.options.args.common.args.display.args.npcs.args, info, level)
            OptionsDropdown.FillFromArgs(ns.options.args.common.args.display.args, info, level)
            LibDD:UIDropDownMenu_AddSeparator(level)

            local showZoneGroups = not (ns.hiddenConfig.groupsHiddenByZone and OptionsDropdown.isHidden(ns.options.args.data, "groupsHidden")) and zoneHasGroups(uiMapID)
            local showZoneAchievements = not OptionsDropdown.isHidden(ns.options.args.data, "achievementsHidden") and zoneHasAchievements(uiMapID)

            if showZoneGroups or showZoneAchievements then
                wipe(info)
                info.isTitle = true
                info.notCheckable = true
                info.text = "Nearby types"
                LibDD:UIDropDownMenu_AddButton(info, level)
            end

            if showZoneGroups then
                local global = not ns.hiddenConfig.groupsHidden
                wipe(info)
                info.isNotRadio = true
                info.keepShownOnClick = true
                info.tooltipOnButton = true
                info.func = function(button, group)
                    if global then
                        ns.db.groupsHidden[group] = not button.checked
                    else
                        ns.db.groupsHiddenByZone[uiMapID][group] = not button.checked
                    end
                    ns.HL:Refresh()
                end
                info.tooltipTitle = global and "Show this type of point everywhere" or "Show this type of point on this map"
                for _, group in iterKeysByValue(zoneGroups(uiMapID)) do
                    info.tooltipText = nil
                    info.text = ns.render_string(ns.groups[group] or group)
                    info.arg1 = group
                    if global then
                        info.checked = not ns.db.groupsHidden[group]
                        if ns.db.groupsHiddenByZone[uiMapID][group] then
                            info.tooltipText = "Currently hidden in this zone"
                        end
                    else
                        info.checked = not ns.db.groupsHiddenByZone[uiMapID][group]
                    end
                    LibDD:UIDropDownMenu_AddButton(info, level)
                end
            end
            if showZoneAchievements then
                wipe(info)
                info.isNotRadio = true
                info.keepShownOnClick = true
                info.tooltipOnButton = true
                info.func = function(button, achievementid)
                    ns.db.achievementsHidden[achievementid] = not button.checked
                    ns.HL:Refresh()
                end
                info.tooltipTitle = "Show this type of point"
                for achievementid in pairs(zoneAchievements(uiMapID)) do
                    info.text = ns.render_string(("{achievement:%d}"):format(achievementid))
                    info.arg1 = achievementid
                    info.checked = not ns.db.achievementsHidden[achievementid]
                    LibDD:UIDropDownMenu_AddButton(info, level)
                end
            end

            if showZoneGroups or showZoneAchievements then
                LibDD:UIDropDownMenu_AddSeparator(level)
            end

            local showAchievements = not OptionsDropdown.isHidden(ns.options.args.data, "achievementsHidden")
            local showZones = not OptionsDropdown.isHidden(ns.options.args.data, "zonesHidden")
            local showGroups = not OptionsDropdown.isHidden(ns.options.args.data, "groupsHidden") and hasGroups()

            if showAchievements or showZones or showGroups then
                wipe(info)
                info.isTitle = true
                info.notCheckable = true
                info.text = "All types"
                LibDD:UIDropDownMenu_AddButton(info, level)
            end

            wipe(info)
            info.hasArrow = true
            info.keepShownOnClick = true
            info.notCheckable = true

            if showAchievements then
                info.text = ACHIEVEMENTS
                info.value = "achievementsHidden"
                LibDD:UIDropDownMenu_AddButton(info, level)
            end
            if showZones then
                info.text = ZONE
                info.value = "zonesHidden"
                LibDD:UIDropDownMenu_AddButton(info, level)
            end
            if showGroups then
                info.text = GROUP
                info.value = "groupsHidden"
                LibDD:UIDropDownMenu_AddButton(info, level)
            end

            if showAchievements or showZones or showGroups then
                LibDD:UIDropDownMenu_AddSeparator(level)
            end

            wipe(info)
            info.notCheckable = true

            info.text = "What's notable?"
            info.value = "notability"
            info.hasArrow = true
            LibDD:UIDropDownMenu_AddButton(info, level)

            info.text = "More settings"
            info.value = "settings"
            info.hasArrow = true
            LibDD:UIDropDownMenu_AddButton(info, level)

            info.text = "Open HandyNotes options"
            info.hasArrow = nil
            info.keepShownOnClick = nil
            info.func = function(button)
                if InterfaceOptionsFrame_Show then
                    InterfaceOptionsFrame_Show()
                    InterfaceOptionsFrame_OpenToCategory('HandyNotes')
                else
                    Settings.OpenToCategory('HandyNotes')
                end
                LibStub('AceConfigDialog-3.0'):SelectGroup('HandyNotes', 'plugins', (myname:gsub("HandyNotes_", "")))
            end
            LibDD:UIDropDownMenu_AddButton(info, level)

        elseif level == 2 and (L_UIDROPDOWNMENU_MENU_VALUE == "show_npcs" or L_UIDROPDOWNMENU_MENU_VALUE == "show_treasure") then
            wipe(info)
            info.func = function(button, arg1)
                local checked = button.checked
                local value = button.value
                if (checked) then
                    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                else
                    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
                end
                ns.db[value] = arg1
                ns.HL:Refresh()
            end
            info.value = L_UIDROPDOWNMENU_MENU_VALUE .. "_filter"
            info.keepShownOnClick = false

            info.text = ALL
            info.arg1 = "all"
            info.checked = ns.db[info.value] == "all"
            LibDD:UIDropDownMenu_AddButton(info, level)
            info.text = "Will drop loot"
            info.arg1 = "lootable"
            info.checked = ns.db[info.value] == "lootable"
            LibDD:UIDropDownMenu_AddButton(info, level)
            info.text = "Will drop notable loot"
            info.arg1 = "notable"
            info.checked = ns.db[info.value] == "notable"
            LibDD:UIDropDownMenu_AddButton(info, level)

            if L_UIDROPDOWNMENU_MENU_VALUE == "show_npcs" then
                LibDD:UIDropDownMenu_AddSeparator(level)
                OptionsDropdown.FillFromArgs(ns.options.args.common.args.display.args.npcs.args, info, level)
            end
        elseif level == 2 and L_UIDROPDOWNMENU_MENU_VALUE == "notability" then
            wipe(info)
            OptionsDropdown.FillFromArgs(ns.options.args.common.args.notable.args, info, level)
        elseif level == 2 and L_UIDROPDOWNMENU_MENU_VALUE == "settings" then
            wipe(info)
            info.isTitle = true
            info.notCheckable = true
            info.text = ns.options.args.common.args.found.name
            LibDD:UIDropDownMenu_AddButton(info, level)
            OptionsDropdown.FillFromArgs(ns.options.args.common.args.found.args, info, level)
            wipe(info)
            info.isTitle = true
            info.notCheckable = true
            info.text = ns.options.args.common.args.tooltips.name
            LibDD:UIDropDownMenu_AddButton(info, level)
            OptionsDropdown.FillFromArgs(ns.options.args.common.args.tooltips.args, info, level)
            wipe(info)
            info.isTitle = true
            info.notCheckable = true
            info.text = ns.options.args.common.args.fiddly.name
            LibDD:UIDropDownMenu_AddButton(info, level)
            OptionsDropdown.FillFromArgs(ns.options.args.common.args.fiddly.args, info, level)
        elseif level == 2 or level == 3 then
            local parent = L_UIDROPDOWNMENU_MENU_VALUE
            local currentZone = WorldMapFrame.mapID
            info.arg1 = parent
            info.isTitle = nil
            info.disabled = nil
            info.notCheckable = nil
            info.isNotRadio = true
            info.keepShownOnClick = true
            info.tooltipOnButton = true
            info.func = function(button, section, subsection, checked)
                local value = button.value
                if (checked) then
                    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                else
                    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
                end
                if subsection then
                    ns.db[section][subsection][value] = not checked
                else
                    ns.db[section][value] = not checked
                end
                ns.HL:Refresh()
            end
            local values = OptionsDropdown.values(ns.options.args.data, parent)
            if parent == "achievementsHidden" then
                local relevant = zoneAchievements(currentZone)
                for _, achievementid in iterKeysByValue(values) do
                    info.text = values[achievementid]
                    info.value = achievementid
                    info.checked = not ns.db.achievementsHidden[achievementid]
                    if relevant[achievementid] then
                        info.text = BRIGHTBLUE_FONT_COLOR:WrapTextInColorCode(info.text) .. " " .. CreateAtlasMarkup("VignetteKill", 0)
                    end
                    LibDD:UIDropDownMenu_AddButton(info, level)
                end
            elseif parent == "zonesHidden" then
                for _, uiMapID in iterKeysByValue(values) do
                    info.text = values[uiMapID]
                    info.value = uiMapID
                    info.checked = not ns.db.zonesHidden[uiMapID]
                    if uiMapID == currentZone then
                        info.text = BRIGHTBLUE_FONT_COLOR:WrapTextInColorCode(info.text) .. " " .. CreateAtlasMarkup("VignetteKill", 0)
                    end
                    if not ns.hiddenConfig.groupsHiddenByZone and zoneHasGroups(uiMapID) then
                        info.hasArrow = true
                        info.menuList = "groupsHiddenByZone"
                    else
                        info.hasArrow = nil
                        info.menuList = nil
                    end
                    LibDD:UIDropDownMenu_AddButton(info, level)
                end
            elseif parent == "groupsHidden" then
                info.arg1 = "groupsHidden"
                info.tooltipTitle = "Hide this type of point everywhere"
                local groups = allGroups()
                for _, group in iterKeysByValue(groups) do
                    info.text = ns.render_string(ns.groups[group] or group)
                    info.value = group
                    info.checked = not ns.db.groupsHidden[group]
                    LibDD:UIDropDownMenu_AddButton(info, level)
                end
            elseif menuList == "groupsHiddenByZone" then
                local uiMapID = parent
                info.arg1 = "groupsHiddenByZone"
                info.arg2 = uiMapID
                info.tooltipTitle = "Hide this type of point on this map"
                local groups = zoneGroups(uiMapID)
                for _, group in iterKeysByValue(groups) do
                    info.text = ns.render_string(ns.groups[group] or group)
                    info.value = group
                    info.checked = not ns.db.groupsHiddenByZone[uiMapID][group]
                    info.disabled = ns.db.groupsHidden[group] -- if it's global-disabled
                    LibDD:UIDropDownMenu_AddButton(info, level)
                end
            end
        end
    end
    frame.OnSelection = function(self, value, checked, arg1, arg2) end
    LibDD:UIDropDownMenu_SetInitializeFunction(frame.DropDown, function(self, ...) frame:InitializeDropDown(...) end)
    LibDD:UIDropDownMenu_SetDisplayMode(frame.DropDown, "MENU")
end
