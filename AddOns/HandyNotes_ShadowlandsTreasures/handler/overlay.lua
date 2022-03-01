local myname, ns = ...

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
end
local zoneGroups, zoneHasGroups
do
    local cache = {}
    function zoneGroups(uiMapID)
        if not cache[uiMapID] then
            local relevant = {}
            for _, point in pairs(ns.points[uiMapID] or {}) do
                if point.group then
                    relevant[point.group] = point.group
                end
            end
            cache[uiMapID] = relevant
        end
        return cache[uiMapID]
    end
    function zoneHasGroups(uiMapID)
        for _, _ in pairs(zoneGroups(uiMapID)) do
            return true
        end
    end
end
function ns.SetupMapOverlay()
    local frame = WorldMapFrame:AddOverlayFrame("WorldMapTrackingOptionsButtonTemplate", "DROPDOWNTOGGLEBUTTON", "TOPRIGHT", WorldMapFrame:GetCanvasContainer(), "TOPRIGHT", -68, -2);
    frame.Icon:SetAtlas("VignetteLootElite")
    frame.Icon:SetPoint("TOPLEFT", 6, -5)
    hideTextureWithAtlas("MapCornerShadow-Right", frame:GetRegions())
    frame.Refresh = function(self)
        local uiMapID = self:GetParent():GetMapID()
        local info = C_Map.GetMapInfo(uiMapID)
        local parentMapID = info and info.parentMapID or 0
        if ns.db.worldmapoverlay and (ns.points[uiMapID] or ns.points[parentMapID]) then
            self:Show()
        else
            self:Hide()
        end
    end
    frame.OnMouseUp = function(self)
        self.Icon:SetPoint("TOPLEFT", 6, -5)
        self.IconOverlay:Hide()
    end
    frame.InitializeDropDown = function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        level = level or 1
        if level == 1 then
            info.isTitle = true
            info.notCheckable = true
            info.text = "HandyNotes - " .. myname:gsub("HandyNotes_", "")
            UIDropDownMenu_AddButton(info, level)

            info.isTitle = nil
            info.disabled = nil
            info.notCheckable = nil
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
                local option = ns.options.args.display.args[value]
                local db = ns.db
                if option.type == "execute" then
                    option.func()
                else
                    db[value] = checked
                end
                ns.HL:Refresh()
            end

            local sorted = {}
            for key in pairs(ns.options.args.display.args) do
                table.insert(sorted, key)
            end
            table.sort(sorted, function(a, b)
                return (ns.options.args.display.args[a].order or 0) < (ns.options.args.display.args[b].order or 0)
            end)
            for _, key in ipairs(sorted) do
                local option = ns.options.args.display.args[key]
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
                UIDropDownMenu_AddButton(info, level)
            end

            UIDropDownMenu_AddSeparator(level)

            wipe(info)
            info.hasArrow = true
            info.keepShownOnClick = true
            info.notCheckable = true

            local displayed = false
            if not OptionsDropdown.isHidden(ns.options, "achievementsHidden") then
                info.text = ACHIEVEMENTS
                info.value = "achievementsHidden"
                UIDropDownMenu_AddButton(info, level)
                displayed = true
            end

            if not OptionsDropdown.isHidden(ns.options, "zonesHidden") then
                info.text = ZONE
                info.value = "zonesHidden"
                UIDropDownMenu_AddButton(info, level)
                displayed = true
            end

            if displayed then
                UIDropDownMenu_AddSeparator(level)
            end

            info.text = "Open HandyNotes options"
            info.hasArrow = nil
            info.keepShownOnClick = nil
            info.func = function(button)
                InterfaceOptionsFrame_Show()
                InterfaceOptionsFrame_OpenToCategory('HandyNotes')
                LibStub('AceConfigDialog-3.0'):SelectGroup('HandyNotes', 'plugins', myname:gsub("HandyNotes_", ""))
            end
            UIDropDownMenu_AddButton(info, level)

        elseif level == 2 or level == 3 then
            local parent = UIDROPDOWNMENU_MENU_VALUE
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
            local values = OptionsDropdown.values(ns.options, parent)
            if parent == "achievementsHidden" then
                local relevant = {}
                for _, point in pairs(ns.points[currentZone] or {}) do
                    if point.achievement then
                        relevant[point.achievement] = true
                    end
                end
                for _, achievementid in iterKeysByValue(values) do
                    info.text = values[achievementid]
                    info.value = achievementid
                    info.checked = not ns.db.achievementsHidden[achievementid]
                    if relevant[achievementid] then
                        info.text = BRIGHTBLUE_FONT_COLOR:WrapTextInColorCode(info.text) .. " " .. CreateAtlasMarkup("VignetteKill", 0)
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            elseif parent == "zonesHidden" then
                for _, uiMapID in iterKeysByValue(values) do
                    info.text = values[uiMapID]
                    info.value = uiMapID
                    info.checked = not ns.db.zonesHidden[uiMapID]
                    if uiMapID == currentZone then
                        info.text = BRIGHTBLUE_FONT_COLOR:WrapTextInColorCode(info.text) .. " " .. CreateAtlasMarkup("VignetteKill", 0)
                    end
                    if zoneHasGroups(uiMapID) then
                        info.hasArrow = true
                        info.menuList = "groupsHiddenByZone"
                    else
                        info.hasArrow = nil
                        info.menuList = nil
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            elseif menuList == "groupsHiddenByZone" then
                local uiMapID = parent
                info.arg1 = "groupsHiddenByZone"
                info.arg2 = uiMapID
                info.tooltipTitle = "Hide this type of point"
                local groups = zoneGroups(uiMapID)
                for _, group in iterKeysByValue(groups) do
                    info.text = ns.render_string(ns.groups[group] or group)
                    info.value = group
                    info.checked = not ns.db.groupsHiddenByZone[uiMapID][group]
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end
    end
    frame.OnSelection = function(self, value, checked, arg1, arg2) end
    UIDropDownMenu_SetInitializeFunction(frame.DropDown, function(self, ...) frame:InitializeDropDown(...) end)
end
