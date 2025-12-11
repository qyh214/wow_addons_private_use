---@class AddonPrivate
local Private = select(2, ...)

local const = Private.constants
local components = Private.Components

local collEnums = const.COLLECTIONS.ENUM

---@class CollectionTabUI
---@field contentFrame Frame
---@field isUICreated boolean
---@field scrollFrame ScrollFrameComponentObject
---@field progress ProgressBarComponentObject
---@field data CollectionRewardObject[]|nil
local collectionTabUI = {
    contentFrame = nil,
    isUICreated = false,
    scrollFrame = nil,
    progress = nil,
    data = nil,
    filter = {
        collected = true,
        uncollected = true,
        raidVariants = false,
        onlyUnique = false,
        types = {},
        sources = {},
        search = "",
    },
    ---@type table<any, string>
    L = nil
}
Private.CollectionTabUI = collectionTabUI

--- MOVE TO EXTRA COMPONENT!!!!
local function createCollectionItemFrame()
    local f = CreateFrame("Button", nil, UIParent)
    f:SetSize(50, 50)

    local iconTexture = f:CreateTexture()

    local borderCollected = f:CreateTexture()

    local name = f:CreateFontString(nil, nil, "GameFontNormal")
    name:SetPoint("LEFT", f, "RIGHT", 9, 3)
    name:SetWidth(135)
    name:SetJustifyH("LEFT")

    local pushed = f:CreateTexture()
    pushed:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    pushed:SetSize(42, 42)
    pushed:SetPoint("CENTER", 0, 1)
    f:SetPushedTexture(pushed)

    local highlight = f:CreateTexture()
    highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    highlight:SetSize(48, 48)
    highlight:SetPoint("CENTER", 0, 2)
    highlight:SetBlendMode("ADD")
    f:SetHighlightTexture(highlight)

    function f:SetCollected(isCollected)
        if isCollected then
            iconTexture:SetPoint("CENTER", 0, 1)
            iconTexture:SetSize(42, 42)
            iconTexture:SetTexCoord(.04347826, .95652173, .04347826, .95652173)
            iconTexture:SetDesaturated(false)
            iconTexture:SetAlpha(1)
            borderCollected:SetPoint("CENTER")
            borderCollected:SetSize(56, 56)
            borderCollected:SetAtlas("collections-itemborder-collected")
            name:SetTextColor(const.COLORS.YELLOW:GetRGBA())
            name:SetShadowColor(0, 0, 0, 1)
        else
            iconTexture:SetPoint("CENTER", 0, 2)
            iconTexture:SetSize(42, 41)
            iconTexture:SetTexCoord(.063, .938, .063, .917)
            iconTexture:SetDesaturated(true)
            iconTexture:SetAlpha(.18)
            borderCollected:SetPoint("CENTER", 0, 2)
            borderCollected:SetSize(50, 50)
            borderCollected:SetAtlas("collections-itemborder-uncollected")
            name:SetTextColor(const.COLORS.GREY:GetRGBA())
            name:SetShadowColor(0, 0, 0, 0.33)
        end
    end

    function f:SetItem(itemID, customName)
        self.itemID = itemID
        if self.itemID then
            local item = Item:CreateFromItemID(self.itemID)
            item:ContinueOnItemLoad(function()
                name:SetText(item:GetItemName())
                iconTexture:SetTexture(item:GetItemIcon())
            end)
        else
            self.name = customName
            name:SetText(self.name or "")
            iconTexture:SetTexture(134939)
        end
    end

    function f:SetDataInstanceID(dataInstanceID)
        self.dataInstanceID = dataInstanceID
    end

    function f:RefreshTooltip()
        if not GameTooltip:GetOwner() == self then return end
        ---@diagnostic disable-next-line: undefined-field
        local data = self:GetParent().data
        local r, g, b = const.COLORS.LIGHT_GREY:GetRGB()
        if self.itemID then
            local itemTooltip = C_TooltipInfo.GetItemByID(self.itemID)
            self:SetDataInstanceID(itemTooltip.dataInstanceID)
            GameTooltip:ClearLines()
            for _, line in ipairs(itemTooltip.lines) do
                if line.leftText then
                    local lr, lg, lb = line.leftColor:GetRGB()
                    GameTooltip:AddLine(line.leftText, lr, lg, lb, line.wrapText)
                end
                if line.rightText then
                    local rr, rg, rb = line.rightColor:GetRGB()
                    GameTooltip:AddLine(line.rightText, rr, rg, rb, line.wrapText)
                end
            end

            ---@cast data CollectionRewardObject?
            if data and not data:IsCollected() then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(data:GetSourceTooltip(), 1, 1, 1, true)
            end
            GameTooltip:AddLine(" ")
            if data and data:GetRewardType() ~= collEnums.REWARD_TYPE.TOY then
                GameTooltip:AddLine(collectionTabUI.L["Tabs.CollectionTabUI.CtrlClickPreview"], r, g, b, true)
            end
            GameTooltip:AddLine(collectionTabUI.L["Tabs.CollectionTabUI.ShiftClickToLink"], r, g, b, true)
        else
            GameTooltip:SetText(self.name or collectionTabUI.L["Tabs.CollectionTabUI.NoName"])
        end

        if data then
            if data:HasSourceType(collEnums.SOURCE_TYPE.VENDOR) then
                GameTooltip:AddLine(collectionTabUI.L["Tabs.CollectionTabUI.AltClickVendor"], r, g, b, true)
            elseif data:HasSourceType(collEnums.SOURCE_TYPE.ACHIEVEMENT) then
                GameTooltip:AddLine(collectionTabUI.L["Tabs.CollectionTabUI.AltClickAchievement"], r, g, b, true)
            end
        end
        GameTooltip:Show()
    end

    Private.Addon:RegisterEvent("TOOLTIP_DATA_UPDATE", tostring(f), function(_, _, dataInstanceID)
        if f.dataInstanceID and dataInstanceID == f.dataInstanceID then
            f:RefreshTooltip()
        end
    end)

    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

        f:RefreshTooltip()

        f:SetScript("OnUpdate", function()
            if IsModifiedClick("DRESSUP") then
                ShowInspectCursor()
            else
                ResetCursor()
            end
        end)
    end)

    f:SetScript("OnLeave", function()
        GameTooltip:Hide()
        ResetCursor()
        f:SetDataInstanceID(nil)
        f:SetScript("OnUpdate", nil)
    end)

    f:SetScript("OnClick", function(self)
        ---@type CollectionRewardObject?
        local data = self:GetParent().data
        if not data then return end
        if IsModifiedClick("DRESSUP") then
            data:Preview()
        elseif IsModifiedClick("CHATLINK") then
            data:Link()
        elseif IsAltKeyDown() then
            if data:HasSourceType(collEnums.SOURCE_TYPE.VENDOR) then
                data:SetVendorWaypoint()
            elseif data:HasSourceType(collEnums.SOURCE_TYPE.ACHIEVEMENT) then
                data:ShowAchievement()
            end
        end
    end)

    return f
end

function collectionTabUI:CreateTabUI()
    local itemsFrame = CreateFrame("Frame", nil, self.contentFrame)
    itemsFrame:SetPoint("TOPLEFT")
    itemsFrame:SetPoint("BOTTOMRIGHT", 0, 50)

    local bottomBar = self.contentFrame:CreateTexture()
    bottomBar:SetPoint("BOTTOMLEFT", 0, 0)
    bottomBar:SetPoint("TOPRIGHT", itemsFrame, "BOTTOMRIGHT", 0, 0)
    bottomBar:SetAtlas("talents-background-bottombar", true)

    local scrollFrame = components.ScrollFrame:CreateFrame(itemsFrame, {
        anchors = {
            with_scroll_bar = {
                { "TOPLEFT",     itemsFrame, "TOPLEFT",     25,  -25 },
                { "BOTTOMRIGHT", itemsFrame, "BOTTOMRIGHT", -25, 25 },
            },
            without_scroll_bar = {
                { "TOPLEFT",     itemsFrame, "TOPLEFT",     25,  -25 },
                { "BOTTOMRIGHT", itemsFrame, "BOTTOMRIGHT", -25, 25 },
            },
        },
        element_height = 55,
        element_width = 200,
        elements_per_row = math.floor((itemsFrame:GetWidth() - 50) / 205),
        type = "GRID",
        element_padding = 5,
        initializer = function(frame, data)
            ---@cast data CollectionRewardObject
            if not frame.initialized then
                local icon = createCollectionItemFrame()
                icon:SetParent(frame)
                icon:SetPoint("LEFT", frame, "LEFT", 0, 0)

                frame.icon = icon
                frame.initialized = true
            end

            frame.data = data
            frame.icon:SetItem(data:GetItemID(), data:GetName())
            frame.icon:SetCollected(data:IsCollected())
        end
    })

    local filterDropdown = components.Dropdown:CreateFrame(itemsFrame, {
        anchors = {
            { "RIGHT", bottomBar, "RIGHT", -15, 0 },
        },
        width = 80,
        height = 20,
        template = "WowStyle1FilterDropdownTemplate",
        setupMenu = function(dropdown, rootDescription)
            rootDescription:CreateCheckbox(self.L["Tabs.CollectionTabUI.FilterRaidVariants"], function(data)
                    return self.filter.raidVariants
                end,
                function()
                    self.filter.raidVariants = not self.filter.raidVariants
                    self:UpdateFilteredData()
                end)
            rootDescription:CreateCheckbox(self.L["Tabs.CollectionTabUI.FilterUnique"], function(data)
                    return self.filter.onlyUnique
                end,
                function()
                    self.filter.onlyUnique = not self.filter.onlyUnique
                    self:UpdateFilteredData()
                end)
            rootDescription:CreateCheckbox(self.L["Tabs.CollectionTabUI.FilterCollected"], function(data)
                    return self.filter.collected
                end,
                function()
                    self.filter.collected = not self.filter.collected
                    self:UpdateFilteredData()
                end)
            rootDescription:CreateCheckbox(self.L["Tabs.CollectionTabUI.FilterNotCollected"], function(data)
                    return self.filter.uncollected
                end,
                function()
                    self.filter.uncollected = not self.filter.uncollected
                    self:UpdateFilteredData()
                end)
            ---@diagnostic disable-next-line: missing-parameter
            local sourceSubMenu = rootDescription:CreateButton(self.L["Tabs.CollectionTabUI.FilterSources"])
            sourceSubMenu:CreateButton(self.L["Tabs.CollectionTabUI.FilterCheckAll"], function()
                for sourceEnum in pairs(self.filter.sources) do
                    self.filter.sources[sourceEnum] = true
                end
                self:UpdateFilteredData()
                return MenuResponse.Refresh
            end)
            sourceSubMenu:CreateButton(self.L["Tabs.CollectionTabUI.FilterUncheckAll"], function()
                for sourceEnum in pairs(self.filter.sources) do
                    self.filter.sources[sourceEnum] = false
                end
                self:UpdateFilteredData()
                return MenuResponse.Refresh
            end)
            for sourceEnum in pairs(self.filter.sources) do
                sourceSubMenu:CreateCheckbox(const.COLLECTIONS.SOURCE_NAMES[sourceEnum], function()
                        return self.filter.sources[sourceEnum]
                    end,
                    function()
                        self.filter.sources[sourceEnum] = not self.filter.sources[sourceEnum]
                        self:UpdateFilteredData()
                    end)
            end
            ---@diagnostic disable-next-line: missing-parameter
            local typesSubMenu = rootDescription:CreateButton(self.L["Tabs.CollectionTabUI.Type"])
            typesSubMenu:CreateButton(self.L["Tabs.CollectionTabUI.FilterCheckAll"], function()
                for typeEnum in pairs(self.filter.types) do
                    self.filter.types[typeEnum] = true
                end
                self:UpdateFilteredData()
                return MenuResponse.Refresh
            end)
            typesSubMenu:CreateButton(self.L["Tabs.CollectionTabUI.FilterUncheckAll"], function()
                for typeEnum in pairs(self.filter.types) do
                    self.filter.types[typeEnum] = false
                end
                self:UpdateFilteredData()
                return MenuResponse.Refresh
            end)
            for typeEnum in pairs(self.filter.types) do
                typesSubMenu:CreateCheckbox(const.COLLECTIONS.REWARD_TYPE_NAMES[typeEnum], function()
                        return self.filter.types[typeEnum]
                    end,
                    function()
                        self.filter.types[typeEnum] = not self.filter.types[typeEnum]
                        self:UpdateFilteredData()
                    end)
            end
        end
    })

    local searchBar = components.TextBox:CreateFrame(itemsFrame, {
        anchors = {
            { "RIGHT", filterDropdown.dropdown, "LEFT", -5, 0 },
        },
        onTextChanged = function(text)
            self.filter.search = text
            self:UpdateFilteredData()
        end,
        instructions = self.L["Tabs.CollectionTabUI.SearchInstructions"],
    })

    local progress = components.ProgressBar:CreateFrame(itemsFrame, {
        anchors = {
            { "RIGHT", searchBar.editBox, "LEFT", -45, 0 },
        },
        width = 200,
        height = 12,
        barColor = CreateColor(0.2, 0.6, 0.2, 1),
    })

    self.scrollFrame = scrollFrame
    self.progress = progress
end

---@param reward CollectionRewardObject
---@param filter {collected:boolean, uncollected:boolean, types:boolean[], sources:boolean[], search:string, raidVariants:boolean, onlyUnique:boolean}
function collectionTabUI:MatchFilter(reward, filter)
    local isCollected = reward:IsCollected()
    if isCollected and not filter.collected then return false end
    if not isCollected and not filter.uncollected then return false end
    if not filter.raidVariants and reward:IsRaidVariant() then return false end
    if filter.onlyUnique and not reward:IsUniqueToRemix() then return false end
    if not filter.types[reward:GetRewardType()] then return false end
    local sources = reward:GetSourceTypes()
    local sourceMatch = false
    for _, source in ipairs(sources) do
        if filter.sources[source] then
            sourceMatch = true
            break
        end
    end
    if not sourceMatch then return false end
    if filter.search and filter.search ~= "" then
        local name = reward:GetName()
        if not name or not name:lower():find(filter.search:lower()) then
            return false
        end
    end
    return true
end

function collectionTabUI:UpdateFilteredData()
    local filtered = {}
    if not self.data then return end
    local collected = 0
    local filter = self.filter

    for _, reward in ipairs(self.data) do
        if self:MatchFilter(reward, filter) then
            tinsert(filtered, reward)
            if reward:IsCollected() then
                collected = collected + 1
            end
        end
    end

    local total = #filtered
    local collectedPercent = total > 0 and (collected / total) * 100 or 0
    local spentBronze, totalBronze = Private.CollectionUtils:GetCollectionBronzeCost(filtered)
    local spentStr = AbbreviateNumbers(spentBronze)
    local totalStr = AbbreviateNumbers(totalBronze)
    local leftToCollectStr = AbbreviateNumbers(totalBronze - spentBronze)
    local tooltipText = self.L["Tabs.CollectionTabUI.ProgressTooltip"]:format(spentStr, totalStr, leftToCollectStr)
    tooltipText = const.COLORS.WHITE:WrapTextInColorCode(tooltipText)

    self.scrollFrame:UpdateContent(filtered)
    self.progress:SetValue(collected)
    self.progress:SetMinMaxValues(0, total)
    self.progress:SetLabelText(self.L["Tabs.CollectionTabUI.Progress"]:format(collected, total, collectedPercent))
    self.progress:SetTooltipText(tooltipText)
end

---@param contentFrame Frame
function collectionTabUI:Init(contentFrame)
    self.L = Private.L
    self.contentFrame = contentFrame

    for _, source in pairs(collEnums.SOURCE_TYPE) do
        self.filter.sources[source] = true
    end
    for _, rType in pairs(collEnums.REWARD_TYPE) do
        self.filter.types[rType] = true
    end

    contentFrame:HookScript("OnShow", function()
        if not self.isUICreated then
            self.isUICreated = true
            self:CreateTabUI()
        end


        local data = Private.CollectionUtils:GetCollectionData()
        if data then
            self.data = data
            self:UpdateFilteredData()
        end
    end)
end

Comps = components
