
local addonId, addonTable = ...
local AceLocale = LibStub("AceLocale-3.0")
local Loc = AceLocale:GetLocale("Details_ChartViewer")
local Details = Details

---@type detailsframework
local detailsFramework = DetailsFramework
local ChartViewer = addonTable.ChartViewer
local ChartViewerWindowFrame = ChartViewerWindowFrame
local CreateFrame = CreateFrame
local GetTime = GetTime
local GameTooltip = GameTooltip

local CONST_TABBUTTON_WIDTH = 140
local CONST_TABBUTTON_HEIGHT = 20

local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

local toTitleCase = function(first, rest)
    return first:upper() .. rest:lower()
end

function ChartViewer:TabOnEnter(tab) --called from xml, xml is obsolete
    GameTooltip:SetOwner(tab, "ANCHOR_TOPLEFT")
    local tabObject = ChartViewer:GetTab(tab.index)
    GameTooltip:AddLine(tabObject.name)
    GameTooltip:AddLine(tabObject.segment_type == 1 and "Current Segment" or "Last 5 Segments")
    GameTooltip:AddLine(" ")

    local chartData = tabObject.data
    if (chartData:find("MULTICHARTS~")) then --multichart
        chartData = chartData:gsub("MULTICHARTS~", "")
        chartData = chartData:gsub("~", ", ")

    elseif (chartData:find("_")) then --preset
        chartData = chartData:gsub("_", " ")
        chartData = chartData:gsub("(%a)([%w_']*)", toTitleCase)
        chartData = chartData:gsub("Preset", "Preset:")
    end

    GameTooltip:AddDoubleLine("Chart:", chartData)
    GameTooltip:Show()
    tab.CloseButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
end

--new tab
ChartViewer.tab_prototype = {
    name = Loc ["STRING_NEWTAB"],
    segment_type = 1,
    data = "",
    texture = "line",
    version = "v2.0"
}

function ChartViewer:GetAllTabs()
    return ipairs(self.tabs)
end

function ChartViewer:GetTab(tabindex)
    return self.tabs[tabindex]
end

function ChartViewer:CreateTab(tabName, segmentType, tabData, tabTexture, extraOptions, dataPresetName)
    if (not tabName) then
        return false

    elseif (string.len(tabName) < 2) then
        ChartViewer:Msg(Loc ["STRING_TOOSHORTNAME"])
        return false
    end

    if (not segmentType) then
        segmentType = 1
    end

    if (tabName == Loc["STRING_NEWTAB"] and dataPresetName and dataPresetName ~= "") then
        tabName = dataPresetName
    end

    local newTab = Details.CopyTable(ChartViewer.tab_prototype)
    newTab.name = tabName
    newTab.segment_type = segmentType
    newTab.data = tabData
    newTab.texture = tabTexture
    newTab.options = extraOptions

    if (extraOptions) then
        newTab.iType = extraOptions.iType
    end

    newTab.iType = newTab.iType or "NONE"

    table.insert(ChartViewer.tabs, newTab)

    ChartViewer:TabRefresh(#ChartViewer.tabs)
    return newTab
end

--refresh tabs
function ChartViewer:TabRefresh(tabSelected)
    --put in order
    for index, tab in ipairs(ChartViewer.tabs) do
        local tabButton = ChartViewer:TabGetButton(index)
        tabButton:Show()
        tabButton:SetText(tab.name)
        tabButton.index = index
        tabButton:SetPoint("topleft", tabButton:GetParent(), "topleft", 3 + ((index-1) * CONST_TABBUTTON_WIDTH), -26)
    end

    --hide not used tabs
    ChartViewer:TabHideNotUsedFrames()

    --check which tab is selected
    if (not tabSelected) then
        tabSelected = ChartViewer.tabs.last_selected
    end
    if (tabSelected > #ChartViewer.tabs) then
        tabSelected = #ChartViewer.tabs
    end

    --click on the selected tab
    ChartViewer:TabClick(ChartViewer.tab_container[tabSelected])
end

--click on a tab
function ChartViewer:TabDoubleClick(self)
    --edit
    local tab = ChartViewer.tabs[self.index]

    ChartViewer.type_dropdown:Select(tab.segment_type, true)
    ChartViewer.data_dropdown:Select(tab.data)

    ChartViewer.type_dropdown:Disable()
    ChartViewer.data_dropdown:Disable()

    ChartViewer.create_button.text = Loc ["STRING_CONFIRM"]

    ChartViewer.name_textentry.text = tab.name
    ChartViewer.texture_dropdown:Select(tab.texture)

    ChartViewer.NewTabPanel.editing = tab
    ChartViewer.NewTabPanel:Show()
end

function ChartViewer:TabClick(self)
    ChartViewer.tabs.last_selected = self.index
    ChartViewer:TabHighlight(self.index)
    ChartViewer:RefreshGraphic()
end

--get the selected tab object
function ChartViewer:TabGetCurrent()
    return ChartViewer.tabs[ChartViewer.tabs.last_selected]
end

--delete a tab
function ChartViewer:TabErase(index, goForIt)
    if (not goForIt) then
        local trueCallback = function()
            ChartViewer:TabErase(index, true)
        end

        local dontOverride = true --won't show another prompt if there's already one showing
        local promptWidth = 300
        local promptName = "REMOVE_CHART_PROMPT"
        detailsFramework:ShowPromptPanel("Remove Chart?", trueCallback, function()end, dontOverride, promptWidth, promptName)
        return
    end

    --get the new index
    local newSelectedTab = 1
    if (#ChartViewer.tabs > 1) then
        if (index == ChartViewer.tabs.last_selected) then
            if (index > 1 and #ChartViewer.tabs > index) then
                newSelectedTab = index

            elseif (index == #ChartViewer.tabs) then
                ChartViewer:TabRefresh(index-1)

            else
                ChartViewer:TabRefresh(1)
            end

        elseif (index < ChartViewer.tabs.last_selected) then
            newSelectedTab = ChartViewer.tabs.last_selected - 1
        else
            newSelectedTab = ChartViewer.tabs.last_selected
        end
    end

    --do the erase thing
    table.remove(ChartViewer.tabs, index)

    --check if there is at least 1 tab
    if (#ChartViewer.tabs == 0) then
        ChartViewer.tabs[1] = {name = Loc ["STRING_NEWTAB"], captures = {}, segment_type = 1, data = "", texture = "line"}
        newSelectedTab = 1
    end

    --refresh
    ChartViewer:TabRefresh(newSelectedTab)
end

--tab frames
function ChartViewer:TabGetButton(index)
    local tabButton = ChartViewer.tab_container[index]

    if (not tabButton) then
        tabButton = ChartViewer:CreateButtonForTab(index)
        tabButton.widget.index = index
        tabButton.index = index
        table.insert(ChartViewer.tab_container, tabButton)
    end

    return tabButton
end

function ChartViewer:CreateButtonForTab(index)
    local onClick = function(self, button)
        if (self.lastclick and self.lastclick + 0.2 > GetTime()) then
            ChartViewer:TabDoubleClick(self)
            self.lastclick = nil
            return
        end

        self.lastclick = GetTime()
        if (button == "LeftButton") then
            ChartViewer:TabClick(self)
        end
    end

    local newTabButton = detailsFramework:CreateButton(ChartViewerWindowFrame, onClick, CONST_TABBUTTON_WIDTH, CONST_TABBUTTON_HEIGHT)
    newTabButton:SetTemplate("DETAILS_TAB_BUTTONSELECTED_TEMPLATE")
    newTabButton:SetTemplate(options_button_template)
    newTabButton:SetWidth(CONST_TABBUTTON_WIDTH)
    newTabButton:SetAlpha(0.8)

    newTabButton.CloseButton = detailsFramework:CreateCloseButton(newTabButton.widget, "$parentCloseButton")
    newTabButton.CloseButton:SetSize(8, 8)
    newTabButton.CloseButton:SetAlpha(0.3)
    newTabButton.CloseButton:ClearAllPoints()
    newTabButton.CloseButton:SetPoint("topright", newTabButton.widget, "topright", -1, -1)

    newTabButton.CloseButton:SetScript("OnClick", function(self)
        ChartViewer:TabErase(newTabButton.index)
    end)

    return newTabButton
end

function ChartViewer:TabHideNotUsedFrames()
    for i = #ChartViewer.tabs+1, #ChartViewer.tab_container do
        ChartViewer.tab_container[i]:Hide()
    end
end

function ChartViewer:TabHighlight(index)
    for i = 1, #ChartViewer.tab_container do
        local tabButton = ChartViewer:TabGetButton(i)
        if (i == index) then
            --the tab is selected
            tabButton:SetTemplate("DETAILS_TAB_BUTTONSELECTED_TEMPLATE")
        else
            tabButton:SetTemplate(options_button_template)
        end

        tabButton:SetWidth(CONST_TABBUTTON_WIDTH)

        local texture = [[Interface\AddOns\Details_ChartViewer\charticon]]
        local textDistance = 1
        local leftPadding = 0
        local textHeight = 0
        local shortMethod = false
        tabButton:SetIcon(texture, 16, 16, "overlay", {0, 1, 0, 1}, {.5, .5, .5, 0.8}, textDistance, leftPadding, textHeight, shortMethod)
    end
end

function ChartViewer.CreateAddTabButton()
	local createNewTabButton = detailsFramework:CreateButton(ChartViewerWindowFrame, ChartViewer.OpenAddTabPanel, CONST_TABBUTTON_WIDTH, CONST_TABBUTTON_HEIGHT, "Add Chart")
	createNewTabButton:SetTextColor(1, 0.93, 0.74)
	createNewTabButton:SetIcon([[Interface\PaperDollInfoFrame\Character-Plus]], 14, 14, nil, {0, 1, 0, 1}, nil, 3)
	createNewTabButton:SetTemplate(options_button_template)
    createNewTabButton:SetAlpha(0.8)
	createNewTabButton:SetFrameLevel(10)

    createNewTabButton:SetPoint("topleft", ChartViewerWindowFrame, "topleft", 2, -49)
	ChartViewer.NewTabButton = createNewTabButton
end

function ChartViewer.CreateAddTabPanel()
	local addNewTabPanel = detailsFramework:CreatePanel(ChartViewerWindowFrame, 360, 280)
	ChartViewer.NewTabPanel = addNewTabPanel

	addNewTabPanel:SetPoint("center", ChartViewerWindowFrame, "center", 0, 0)
	addNewTabPanel:SetFrameLevel(ChartViewerWindowFrame:GetFrameLevel() + 10)

	Details:FormatBackground(addNewTabPanel)

	local titleBar = CreateFrame("frame", nil, addNewTabPanel.widget, "BackdropTemplate")
	titleBar:SetPoint("topleft", addNewTabPanel.widget, "topleft", 2, -3)
	titleBar:SetPoint("topright", addNewTabPanel.widget, "topright", -2, -3)
	titleBar:SetHeight(20)
	titleBar:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
	titleBar:SetBackdropColor(.5, .5, .5, 1)
	titleBar:SetBackdropBorderColor(0, 0, 0, 1)

	--title text
	local titleLabel = detailsFramework:NewLabel(titleBar, titleBar, nil, "titulo", "Add Chart", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
	titleLabel:SetPoint("center", titleBar , "center")
	titleLabel:SetPoint("top", titleBar , "top", 0, -5)

	local xStart = 10

    --texentry
    local nameLabel = detailsFramework:CreateLabel(addNewTabPanel, "Name:") --, size, color, font, member, name, layer)
    local nameTextEntry = detailsFramework:CreateTextEntry(addNewTabPanel, func, 150, 20) --, member, name)
    nameTextEntry:SetPoint("left", nameLabel, "right", 2, 0)
    ChartViewer.name_textentry = nameTextEntry
    nameTextEntry:SetTemplate(ChartViewer:GetFramework():GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

	--type
	local typeLabel = detailsFramework:CreateLabel(addNewTabPanel, "Type:")

    --dropdown
    local typeOptions_OnsSlect = function()
        if (ChartViewer.data_dropdown) then
            ChartViewer.data_dropdown:Refresh()
            ChartViewer.data_dropdown:Select(1, true)
        end
    end

    local typeOptions = {
        {onclick = typeOptions_OnsSlect, value = 1, icon = [[Interface\AddOns\Details\images\toolbar_icons]], iconcolor = {1, 1, 1}, iconsize = {14, 14}, texcoord = {32/256, 64/256, 0, 1}, label = "Current Segment", desc = "Show data only for the current segment, but can show more than one player."},
        {onclick = typeOptions_OnsSlect, value = 2, icon = [[Interface\AddOns\Details\images\toolbar_icons]], iconcolor = {1, 1, 1}, iconsize = {14, 14}, texcoord = {32/256, 64/256, 0, 1}, label = "Last 5 Segments", desc = "Show only one player, but shows it for the last 5 segments."},
    }

    local typeOptions_Func = function()
        return typeOptions
    end

    local typeDropdown = detailsFramework:CreateDropDown(addNewTabPanel, typeOptions_Func, 1, 150, 20) --, member, name
    typeDropdown:SetPoint("left", typeLabel, "right", 2, 0)
    ChartViewer.type_dropdown = typeDropdown
    typeDropdown:SetTemplate(ChartViewer:GetFramework():GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

	--data
    local dataOptions_Func = function()
        if (typeDropdown.value == 1) then --current
            local resultTable = {}

            --raid healing done
            table.insert(resultTable, {value = "PRESET_PLAYER_HEAL", label = "Player Healing Done", icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Disabled]], iconsize = {14, 14}})
            --player healing done
            table.insert(resultTable, {value = "PRESET_RAID_HEAL", label = "Raid Healing Done", icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Disabled]], iconsize = {14, 14}})

            --same class
            table.insert(resultTable, {value = "PRESET_DAMAGE_SAME_CLASS", label = "Damage(Same Class)", icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Disabled]], iconsize = {14, 14}})
            table.insert(resultTable, {value = "PRESET_HEAL_SAME_CLASS", label = "Healing(Same Class)", icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Disabled]], iconsize = {14, 14}})

            --all damagers
            table.insert(resultTable, {value = "PRESET_ALL_DAMAGERS", label = "All Damagers", icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Disabled]], iconsize = {14, 14}})

            --all healers
            table.insert(resultTable, {value = "PRESET_ALL_HEALERS", label = "All Healers", icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Disabled]], iconsize = {14, 14}})

            --tank damage taken
            table.insert(resultTable, {value = "PRESET_TANK_TAKEN", label = "Tanks Damage Taken", icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Disabled]], iconsize = {14, 14}})

            --already created data charts
            for index, capture in ipairs(Details.savedTimeCaptures) do
                table.insert(resultTable, {value = capture[1], icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Disabled]], iconsize = {14, 14}, label = capture[1], onclick = nil})
            end

            --arena ally team damage
            table.insert(resultTable, {value = "MULTICHARTS~Your Team Damage~Enemy Team Damage", label = "Arena Damage", icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Disabled]], iconsize = {14, 14}})
            table.insert(resultTable, {value = "MULTICHARTS~Your Team Healing~Enemy Team Healing", label = "Arena Heal", icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Disabled]], iconsize = {14, 14}})

            return resultTable

        elseif (typeDropdown.value == 2) then --last 5
            local resultTable = {}

            --raid healing done
            table.insert(resultTable, {value = "PRESET_PLAYER_HEAL", label = "Player Healing Done", icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Disabled]], iconsize = {14, 14}})
            table.insert(resultTable, {value = "PRESET_RAID_HEAL", label = "Raid Healing Done", icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Disabled]], iconsize = {14, 14}})

            --already created data charts
            for index, capture in ipairs(Details.savedTimeCaptures) do
                table.insert(resultTable, {value = capture[1], icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Disabled]], iconsize = {14, 14}, label = capture[1], onclick = nil})
            end

            return resultTable
        end
    end

    local dataLabel = detailsFramework:CreateLabel(addNewTabPanel, "Data:")
    local dataDropdown = detailsFramework:CreateDropDown(addNewTabPanel, dataOptions_Func, 1, 150, 20)
    dataDropdown:SetPoint("left", dataLabel, "right", 2, 0)
    ChartViewer.data_dropdown = dataDropdown
    dataDropdown:SetTemplate(ChartViewer:GetFramework():GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

	--line texture
    --dropdown
    local texture_options = {
        {value = "thinline", label = "Thin Line", icon = [[Interface\AddOns\Details\Libs\LibGraph-2.0\thinline]], iconcolor = {1, 1, 1}, iconsize = {30, 14}, texcoord = {0, 1, 0.3, 0.7}, onclick = nil},
        {value = "line", label = "Normal Line", icon = [[Interface\AddOns\Details\Libs\LibGraph-2.0\line]], iconcolor = {1, 1, 1}, iconsize = {30, 14}, texcoord = {0, 1, 0.3, 0.7}, onclick = nil},
        --{value = "sline", label = "Sline", desc = "", icon = [[Interface\AddOns\Details\Libs\LibGraph-2.0\sline]], iconcolor = {1, 1, 1}, iconsize = {130, 14}, texcoord = {0, 1, 0.3, 0.7}, onclick = nil},
        --{value = "smallline", label = "Small Line", desc = "", icon = [[Interface\AddOns\Details\Libs\LibGraph-2.0\smallline]], iconcolor = {1, 1, 1}, iconsize = {130, 14}, texcoord = {0, 1, 0.3, 0.7}, onclick = nil},
    }

    local textureOptions_Func = function()
        return texture_options
    end

    local textureLabel = detailsFramework:CreateLabel(addNewTabPanel, "Texture:")
    local textureDropdown = detailsFramework:CreateDropDown(addNewTabPanel, textureOptions_Func, 1, 150, 20)
    textureDropdown:SetPoint("left", textureLabel, "right", 2, 0)
    ChartViewer.texture_dropdown = textureDropdown
    textureDropdown:SetTemplate(ChartViewer:GetFramework():GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

    local internalOptions = {
        ["MULTICHARTS~Your Team Damage~Enemy Team Damage"] = {colors = {["Your Team Damage"] = {1, 1, 1}, ["Enemy Team Damage"] = {1, 0.6, 0.2}}, iType = "arena-DAMAGER", name = "Arena Damage"},
        ["MULTICHARTS~Your Team Healing~Enemy Team Healing"] = {colors = {["Your Team Healing"] = {1, 1, 1}, ["Enemy Team Healing"] = {1, 0.6, 0.2}}, iType = "arena-HEALER", name = "Arena Heal"},
        ["PRESET_PLAYER_HEAL"] = {iType = "solo-HEALER", name = "Player Healing Done"},
        ["PRESET_RAID_HEAL"] = {iType = "raid-HEALER", name = "Raid Healing Done"},
        ["PRESET_TANK_TAKEN"] = {iType = "raid-TANK", name = "Tanks Damage Taken"},
        ["PRESET_ALL_HEALERS"] = {iType = "raid-HEALER", name = "All Healers"},
        ["PRESET_ALL_DAMAGERS"] = {iType = "raid-DAMAGER-all", name = "All Damagers"},
        ["PRESET_HEAL_SAME_CLASS"] = {iType = "raid-HEALER", name = "Healing(Same Class)"},
        ["PRESET_DAMAGE_SAME_CLASS"] = {iType = "raid-DAMAGER", name = "Damager(Same Class)"},
    }

    function ChartViewer:GetInternalOptionsForChart(presetName)
        return internalOptions[presetName]
    end

    function ChartViewer:GetChartsForIType(iType, isKeyword)
        local resultTable = {}

        if (isKeyword) then
            for presetName, thisInternalOption in pairs(internalOptions) do
                if (thisInternalOption.iType:find(iType)) then
                    table.insert(resultTable, presetName)
                end
            end
        else
            for presetName, thisInternalOption in pairs(internalOptions) do
                if (thisInternalOption.iType == iType) then
                    table.insert(resultTable, presetName)
                end
            end
        end

        return resultTable
    end

	--todo: smoothness process selection

	--create button
    local create_func = function()
        local tab_name = nameTextEntry.text
        local tab_type = typeDropdown.value
        local tab_data = dataDropdown.value
        local tab_texture = textureDropdown.value

        if (ChartViewer.NewTabPanel.editing) then
            ChartViewer.NewTabPanel.editing.texture = tab_texture
            ChartViewer.NewTabPanel.editing.name = tab_name
            ChartViewer:RefreshGraphic()
        else
            local extra_options = internalOptions [tab_data]
            ChartViewer:CreateTab(tab_name, tab_type, tab_data, tab_texture, extra_options, dataDropdown.label:GetText())
        end

        addNewTabPanel:Hide()
    end

    --create button inside the create new chart panel, opened by the new chart button
    local createButton = detailsFramework:CreateButton(addNewTabPanel, create_func, 120, 20, "Create")
    ChartViewer.create_button = createButton
    createButton:SetTemplate(options_button_template)
    createButton:SetAlpha(0.8)

    local cancelButton = detailsFramework:CreateButton(addNewTabPanel, function() nameTextEntry:ClearFocus(); addNewTabPanel:Hide(); ChartViewer.NewTabPanel.editing = nil end, 120, 20, "Cancel")
    cancelButton:SetTemplate(options_button_template)
    cancelButton:SetAlpha(0.8)

    createButton:SetIcon([[Interface\Buttons\UI-CheckBox-Check]], nil, nil, nil, {0.125, 0.875, 0.125, 0.875}, nil, 4, 2)
    cancelButton:SetIcon([[Interface\Buttons\UI-GroupLoot-Pass-Down]], nil, nil, nil, {0.125, 0.875, 0.125, 0.875}, nil, 4, 2)

	--align
    local y = -26
    nameLabel:SetPoint("topleft", addNewTabPanel, "topleft", xStart, y * 2)
    typeLabel:SetPoint("topleft", addNewTabPanel, "topleft", xStart, y * 3)
    dataLabel:SetPoint("topleft", addNewTabPanel, "topleft", xStart, y * 4)
    textureLabel:SetPoint("topleft", addNewTabPanel, "topleft", xStart, y * 5)

    createButton:SetPoint("topleft", addNewTabPanel, "topleft", 10, y*7)
    cancelButton:SetPoint("left", createButton, "right", 20, 0)

	ChartViewer.OpenAddTabPanel = function()
		ChartViewer.type_dropdown:Enable()
		ChartViewer.data_dropdown:Enable()
		ChartViewer.create_button.text = "Create"
		ChartViewer.name_textentry.text = "New Tab"
		ChartViewer.NewTabPanel.editing = nil
		addNewTabPanel:Show()
	end
end