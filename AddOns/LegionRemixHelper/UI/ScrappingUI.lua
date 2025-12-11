---@class AddonPrivate
local Private = select(2, ...)

---@class ScrappingUI
---@field utils ScrappingUtils
---@field frame Frame
---@field scrappingMachine Frame
---@field scrollFrame ScrollFrameComponentObject
local scrappingUI = {
    utils = Private.ScrappingUtils,
    frame = nil,
    scrappingMachine = nil,
    scrollFrame = nil,
    iconFrames = {},
    ---@type table<any, string>
    L = nil,
    ---@type Frame[]
    tabs = {},
    ---@type Frame|table
    tabSystem = nil,
}
Private.ScrappingUI = scrappingUI

local const = Private.constants
local components = Private.Components

---@param name string
---@return Frame tabContent
---@return number tabID
function scrappingUI:AddTab(name)
    local tabSystem = self.tabSystem

    local tabID = tabSystem:AddTab(name)
    local tabButton = tabSystem:GetTabButton(tabID)
    tabButton:Init(tabID, name)

    local tabContent = CreateFrame("Frame", nil, self.frame)
    tabContent:SetAllPoints()
    tabContent:Hide()

    self.tabs[tabID] = tabContent

    return tabContent, tabID
end

function scrappingUI:Init()
    self.scrappingMachine = ScrappingMachineFrame
    self.L = Private.L
    local addon = Private.Addon

    local resetButton = CreateFrame("Frame", nil, self.scrappingMachine)
    resetButton:SetSize(24, 24)
    resetButton:SetPoint("TOPRIGHT", self.scrappingMachine, "TOPRIGHT", -10, -25)
    resetButton.texture = resetButton:CreateTexture(nil, "BACKGROUND")
    resetButton.texture:SetAllPoints()
    resetButton.texture:SetAtlas("GM-raidMarker-reset")
    resetButton:SetScript("OnMouseDown", function()
        C_ScrappingMachineUI.RemoveAllScrapItems()
    end)

    local frame = CreateFrame("Frame", nil, self.scrappingMachine, "PortraitFrameFlatBaseTemplate")
    frame:SetSize(275, self.scrappingMachine:GetHeight())
    frame:SetPoint("TOPLEFT", self.scrappingMachine, "TOPRIGHT", 5, 0)
    ButtonFrameTemplate_HidePortrait(frame)
    self.frame = frame

    local tabSys = CreateFrame("Frame", nil, frame, "TabSystemTemplate")
    self.tabSystem = tabSys
    tabSys:SetPoint("BOTTOMLEFT", 5, -30)

    tabSys:SetTabSelectedCallback(function(tabID)
        for id, tabContent in pairs(self.tabs) do
            tabContent:SetShown(id == tabID)
        end
        return false
    end)
    local scraperList, scrapperTabID = self:AddTab(self.L["ScrappingUI.ScraperListTabTitle"])
    tabSys:SetTab(scrapperTabID)

    local qualityLabel = components.Label:CreateFrame(scraperList, {
        anchors = {
            { "TOPLEFT",  15,  -30 },
            { "TOPRIGHT", -15, -30 }
        },
        text = self.L["ScrappingUI.MaxScrappingQuality"],
        font = "GameFontNormalSmall",
    })

    local qualities = {}
    for qualityString, qualityIndex in pairs(Enum.ItemQuality) do
        if qualityIndex <= 4 and qualityIndex >= 1 then
            -- Use WoW's localized quality name instead of the enum key
            local localizedQualityName = _G["ITEM_QUALITY" .. qualityIndex .. "_DESC"] or qualityString
            local qualityColor = CreateColor(C_Item.GetItemQualityColor(qualityIndex))
            if qualityColor then
                localizedQualityName = qualityColor:WrapTextInColorCode(localizedQualityName)
            end
            tinsert(qualities, { localizedQualityName, qualityIndex })
        end
    end
    sort(qualities, function(a, b) return a[2] < b[2] end)
    local qualityDropdown = components.Dropdown:CreateFrame(scraperList, {
        anchors = {
            { "TOPLEFT",  qualityLabel.frame, "BOTTOMLEFT",  0, -2 },
            { "TOPRIGHT", qualityLabel.frame, "BOTTOMRIGHT", 0, -2 },
        },
        dropdownType = "RADIO",
        radioOptions = qualities,
        onSelect = function(value)
            self.utils:SetMaxScrappingQuality(value)
            self:Refresh()
        end,
        isSelected = function(value)
            return value == self.utils:GetMaxScrappingQuality()
        end,
        defaultSelection = self.utils:GetMaxScrappingQuality(),
    })

    local minItemLevelLabel = components.Label:CreateFrame(scraperList, {
        anchors = {
            { "TOPLEFT",  qualityDropdown.dropdown, "BOTTOMLEFT",  0, -5 },
            { "TOPRIGHT", qualityDropdown.dropdown, "BOTTOMRIGHT", 0, -5 }
        },
        text = self.L["ScrappingUI.MinItemLevelDifference"],
        font = "GameFontNormalSmall",
    })
    local minItemLevelTextBox = components.TextBox:CreateFrame(scraperList, {
        anchors = {
            { "TOPLEFT",  minItemLevelLabel.frame, "BOTTOMLEFT",  5, -2 },
            { "TOPRIGHT", minItemLevelLabel.frame, "BOTTOMRIGHT", 0, -2 },
        },
        font = "GameFontHighlight",
        instructions = self.L["ScrappingUI.MinItemLevelDifferenceInstructions"],
        text = tostring(self.utils:GetMinimumLevelDifference() or 0),
        maxLetters = 3,
        onTextChanged = function(text, userInput)
            if userInput then
                local num = tonumber(text)
                if num then
                    self.utils:SetMinimumLevelDifference(num)
                    self:Refresh()
                end
            end
        end,
    })

    local autoScrapCheckBox = components.CheckBox:CreateFrame(scraperList, {
        anchors = {
            { "TOPLEFT", minItemLevelTextBox.editBox, "BOTTOMLEFT", -5, -5 },
        },
        width = 20,
        height = 20,
        text = self.L["ScrappingUI.AutoScrap"],
        font = "GameFontNormalSmall",
        checked = self.utils:GetAutoScrap(),
        onClick = function(checked)
            self.utils:SetAutoScrap(checked)
            if checked then
                self.utils:AutoScrapBatch()
            end
        end,
    })

    local scrollFrame = components.ScrollFrame:CreateFrame(scraperList, {
        frame_strata = frame:GetFrameStrata(),
        initializer = self:GetScrollframeInitializer(),
        type = "GRID",
        element_height = 35,
        element_width = 35,
        elements_per_row = 6,
        anchors = {
            with_scroll_bar = {
                { "TOPLEFT",     15,  -150 },
                { "BOTTOMRIGHT", -25, 15 }
            },
            without_scroll_bar = {
                { "TOPLEFT",     15, -150 },
                { "BOTTOMRIGHT", -5, 15 }
            },
        },
    })
    self.scrollFrame = scrollFrame

    local advancedSettings = self:AddTab(self.L["ScrappingUI.AdvancedSettingsTabTitle"])

    local ignoreHighestEquip = components.CheckBox:CreateFrame(advancedSettings, {
        anchors = {
            { "TOPLEFT", advancedSettings, 15, -30 },
        },
        width = 20,
        height = 20,
        text = self.L["ScrappingUI.AdvancedJewelryFilter"],
        font = "GameFontNormalSmall",
        checked = self.utils:GetAdvancedJeweleryFilter(),
        onClick = function(checked)
            self.utils:SetAdvancedJeweleryFilter(checked)
            self:Refresh()
        end,
    })

    local onlyJeweleryTraitsToKeep = components.Dropdown:CreateFrame(advancedSettings, {
        anchors = {
            { "TOPLEFT", ignoreHighestEquip.checkButton, "BOTTOMLEFT", 0, -15 },
        },
        width = 200,
        height = 20,
        template = "WowStyle1FilterDropdownTemplate",
        setupMenu = function(_, rootDescription)
            rootDescription:CreateButton(self.L["ScrappingUI.FilterCheckAll"], function()
                self.utils:SetTraitToKeepForAll(true)
                self:Refresh()
                return MenuResponse.Refresh
            end)
            rootDescription:CreateButton(self.L["ScrappingUI.FilterUncheckAll"], function()
                self.utils:SetTraitToKeepForAll(false)
                self:Refresh()
                return MenuResponse.Refresh
            end)
            for _, slot in ipairs(self.utils:GetTraitSlots()) do
                ---@diagnostic disable-next-line: missing-parameter
                local submenu = rootDescription:CreateButton(self.L["ScrappingUI." .. slot])
                local traits = self.utils:GetSortedTraitsToKeepForSlot(slot)
                local spellTraits = {}
                local loadedSpells = 0
                local allLoaded = false
                for _, itemID in ipairs(traits) do
                    local spellID = Private.ArtifactTraitUtils:GetJewelrySpellID(tonumber(itemID))
                    local spell = Spell:CreateFromSpellID(spellID)
                    spell:ContinueOnSpellLoad(function()
                        if allLoaded then return end
                        if spellTraits[itemID] then return end
                        loadedSpells = loadedSpells + 1
                        spellTraits[itemID] = {
                            name = spell:GetSpellName(),
                            icon = C_Spell.GetSpellTexture(spellID),
                        }
                        if loadedSpells ~= #traits then return end
                        allLoaded = true
                        for _, loadedItemID in ipairs(traits) do
                            local trait = spellTraits[loadedItemID]
                            ---@cast trait {name: string, icon: string}
                            if trait then
                                submenu:CreateCheckbox(("|T%s:16|t %s"):format(trait.icon, trait.name), function()
                                    return self.utils:GetTraitToKeepForSlot(slot, loadedItemID)
                                end, function()
                                    self.utils:ToggleTraitToKeepForSlot(slot, loadedItemID)
                                    self:Refresh()
                                    return MenuResponse.Refresh
                                end)
                            end
                        end
                    end)
                end
            end
        end
    })
    onlyJeweleryTraitsToKeep:GetDropdown():SetText(self.L["ScrappingUI.JewelryTraitsToKeep"])

    local ignoreFromSets = components.CheckBox:CreateFrame(advancedSettings, {
        anchors = {
            { "TOPLEFT", onlyJeweleryTraitsToKeep.dropdown, 0, -30 },
        },
        width = 20,
        height = 20,
        text = self.L["ScrappingUI.IgnoreFromEquipmentSets"],
        font = "GameFontNormalSmall",
        checked = self.utils:GetIgnoreFromEquipmentSets(),
        onClick = function(checked)
            self.utils:SetIgnoreFromEquipmentSets(checked)
            self:Refresh()
        end,
    })

    self.scrappingMachine:HookScript("OnShow", function()
        self:Refresh()
        RunNextFrame(function()
            self:RefreshPending()
        end)
        self.utils:AutoScrap()
    end)

    addon:RegisterEvent("BAG_UPDATE_DELAYED", "scrappingUI_BagUpdateDelayed", function()
        if self.scrappingMachine:IsShown() then
            self:Refresh()
        end
    end)
    addon:RegisterEvent("SCRAPPING_MACHINE_PENDING_ITEM_CHANGED", "scrappingUI_ScrappingMachinePendingItemChanged",
        function()
            RunNextFrame(function()
                self:RefreshPending()
            end)
        end)
end

function scrappingUI:Refresh()
    local scrappableItems = self.utils:GetFilteredScrappableItems()
    self.scrollFrame:UpdateContent(scrappableItems)
    self.utils:AutoScrap()
end

function scrappingUI:RefreshPending()
    for _, f in ipairs(self.iconFrames) do
        if f.data then
            f.Icon.icon:SetDesaturated(self.utils:IsItemLocationPendingScrap(f.data.location))
        end
    end
end

---@return fun(elementFrame:table|Frame, data:ScrappableItem)
function scrappingUI:GetScrollframeInitializer()
    ---@param elementFrame table|Frame
    ---@param data ScrappableItem
    return function(elementFrame, data)
        if not elementFrame.initialized then
            elementFrame.initialized = true
            local f = components.ItemIcon:CreateFrame(elementFrame, {
                anchors = {
                    { "TOPLEFT" },
                    { "BOTTOMRIGHT" }
                },
                onClick = function()
                    self.utils:ScrapItemFromBag(elementFrame.data.bagID, elementFrame.data.slotID)
                end,
            })
            elementFrame.Icon = f

            tinsert(self.iconFrames, elementFrame)
        end
        elementFrame.data = data
        elementFrame.Icon:SetItem(data.link)
        elementFrame.Icon.icon:SetDesaturated(self.utils:IsItemLocationPendingScrap(data.location))
    end
end
