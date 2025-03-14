---@class BFC
local BFC = select(2, ...)

local PAD = 2
local SPACING = 2
local ATTIC_HEIGHT = 90
local URL = "https://wow.miaoyanai.com/?ref=bigfoot"
local DAY = 24 * 60 * 60
local EXPIRED_THRESHOLD = 3 * 24 * 60 * 60
local MAX_ENTRIES = 99
local DATA_EXPIRED = "|cffff0000工匠数据已过期%d天|r\n\n你可以通过以下几种方式更新数据：\n"
    .. "1. |cffffff00大脚客户端（每次启动会自动更新）|r\n    插件库 - 大脚发布 - 大脚公益助手 - 更新数据 - 重载界面\n"
    .. "2. |cffffff00魔兽工坊网站|r\n    复制工匠数据字符串 - 插件内导入\n"
    .. "3. 其他玩家分享的字符串"

---------------------------------------------------------------------
-- craftsman frame
---------------------------------------------------------------------
local isSearch = false
local listUpdateRequired = true
local listEntries, searchEntries = 0, 0
local listSelected, searchSelected
local categoryFilter, matchedResult

local craftsmanFrame
local categoryDropdown, searchBox, topInfoText, updateTimeText, maskFrame, tipsFrame
local normalList, searchList

local LoadData

---------------------------------------------------------------------
-- comparator
---------------------------------------------------------------------
local function SortComparator(a, b)
    if a.isFavorite and not b.isFavorite then
        return true
    elseif not a.isFavorite and b.isFavorite then
        return false
    else
        return a.index < b.index
    end
end

---------------------------------------------------------------------
-- factory
---------------------------------------------------------------------

local function SetSelected(index, selected)
    if not index then return end
    local old, found
    if isSearch then
        found = searchList.view:FindFrame(index)
    else
        found = normalList.view:FindFrame(index)
    end
    if found then
        found.SelectedHighlight:SetShown(selected)
    end
end

local function ElementFactory(factory, elementData)
    factory("CraftsmanButtonTemplate", function(button, elementData)
        --! NOTE: only invoked on shown buttons
        -- elementData.playerFull = elementData.player .. "-" .. elementData.server
        -- if BFCCraftsman.favorites[elementData.playerFull] then
        --     elementData.isFavorite = true
        -- else
        --     elementData.isFavorite = false
        -- end
        button:UpdateText(elementData)
        button:UpdateFavoriteButton()

        if isSearch then
            SetSelected(elementData, searchSelected == elementData)
        else
            SetSelected(elementData, listSelected == elementData)
        end

        button:SetScript("OnClick", function(button, buttonName, down)
            if buttonName == "LeftButton" then
                if isSearch then
                    SetSelected(searchSelected, false)
                    searchSelected = elementData
                else
                    SetSelected(listSelected, false)
                    listSelected = elementData
                end
                SetSelected(elementData, true)
                BFC.ShowMessageFrame(elementData.player, elementData.playerFull)
            end
        end)
    end)
end

---------------------------------------------------------------------
-- list
---------------------------------------------------------------------
local function CreateList(parent, name)
    local list = CreateFrame("ScrollFrame", name, parent, "WowScrollBoxList")
    list:SetPoint("TOPLEFT")
    list:SetPoint("BOTTOMRIGHT", -20, 2)

    list.scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
    list.scrollBar:SetPoint("TOPLEFT", list, "TOPRIGHT", 5, 0)
    list.scrollBar:SetPoint("BOTTOMLEFT", list, "BOTTOMRIGHT", 5, 0)

    list.dataProvider = CreateDataProvider()
    -- list.dataProvider:SetSortComparator(SortComparator)

    list.view = CreateScrollBoxListLinearView()
    list.view:SetElementFactory(ElementFactory)
    list.view:SetPadding(PAD, PAD, PAD, PAD, SPACING)

    ScrollUtil.InitScrollBoxListWithScrollBar(list, list.scrollBar, list.view)
    list:SetDataProvider(list.dataProvider)

    return list
end

---------------------------------------------------------------------
-- create craftsman frame
---------------------------------------------------------------------
local function CreateCraftsmanFrame()
    craftsmanFrame = CreateFrame("Frame", "BFC_CraftsmanFrame", BFC_MainFrame)
    craftsmanFrame:SetAllPoints()

    ---------------------------------------------------------------------
    -- top info
    ---------------------------------------------------------------------
    topInfoText = craftsmanFrame:CreateFontString(nil, "OVERLAY", "BFC_FONT_WHITE")
    topInfoText:SetPoint("TOPLEFT", 15, -70)

    function topInfoText.Update()
        topInfoText:SetFormattedText("总计：%d    本服：%d    列出的条目：%d", BFC.loadedCraftsman.count_total, BFC.loadedCraftsman.count_server, isSearch and searchEntries or listEntries)
    end

    ---------------------------------------------------------------------
    -- bottom info
    ---------------------------------------------------------------------
    local bottomInfoText = craftsmanFrame:CreateFontString(nil, "OVERLAY", "BFC_FONT_WHITE")
    bottomInfoText:SetPoint("BOTTOMLEFT", 15, 7)
    bottomInfoText:SetText("本插件数据由 |cffffff00魔兽工坊|r 提供")

    ---------------------------------------------------------------------
    -- update time
    ---------------------------------------------------------------------
    updateTimeText = craftsmanFrame:CreateFontString(nil, "OVERLAY", "BFC_FONT_WHITE")
    updateTimeText:SetPoint("BOTTOMRIGHT", -15, 7)

    ---------------------------------------------------------------------
    -- link
    ---------------------------------------------------------------------
    local linkEditbox = CreateFrame("EditBox", nil, craftsmanFrame)
    linkEditbox:SetFontObject("BFC_FONT_WHITE")
    linkEditbox:SetPoint("LEFT", bottomInfoText, "RIGHT", 10, 0)
    linkEditbox:SetPoint("RIGHT", updateTimeText, "LEFT", -10, 0)
    linkEditbox:SetHeight(20)
    linkEditbox:SetTextColor(0.6, 0.6, 0.6, 1)
    linkEditbox:SetText(URL)
    linkEditbox:SetCursorPosition(0)
    linkEditbox:SetAutoFocus(false)
    linkEditbox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    linkEditbox:SetScript("OnMouseUp", function(self) self:HighlightText() end)
    linkEditbox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    linkEditbox:SetScript("OnEditFocusLost", function(self) self:HighlightText(0, 0) end)
    linkEditbox:SetScript("OnTextChanged", function(self, userChanged)
        if userChanged then
            self:SetText(URL)
            self:HighlightText()
            self:SetCursorPosition(0)
        end
    end)

    ---------------------------------------------------------------------
    -- frame container
    ---------------------------------------------------------------------
    local scrollContainer = CreateFrame("Frame", "BFC_MainFrameContainer", craftsmanFrame)
    scrollContainer:SetPoint("TOPLEFT", 15, -ATTIC_HEIGHT-5)
    scrollContainer:SetPoint("BOTTOMRIGHT", -11, 32)

    -- scrollContainer.bg = scrollContainer:CreateTexture(nil, "ARTWORK")
    -- scrollContainer.bg:SetAllPoints(scrollContainer)
    -- scrollContainer.bg:SetColorTexture(0.03, 0.03, 0.03, 1)

    ---------------------------------------------------------------------
    -- mask
    ---------------------------------------------------------------------
    maskFrame = CreateFrame("Frame", nil, craftsmanFrame)
    maskFrame:EnableMouse(true)
    maskFrame:SetFrameLevel(craftsmanFrame:GetFrameLevel() + 100)
    maskFrame:SetAllPoints(scrollContainer)
    maskFrame:Hide()

    maskFrame.texture = maskFrame:CreateTexture(nil, "ARTWORK")
    maskFrame.texture:SetAllPoints()
    maskFrame.texture:SetColorTexture(0.15, 0.15, 0.15, 0.9)

    maskFrame.text = maskFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    maskFrame.text:SetPoint("LEFT", 10, 0)
    maskFrame.text:SetPoint("RIGHT", -10, 0)
    maskFrame.text:SetJustifyH("CENTER")
    maskFrame.text:SetJustifyV("MIDDLE")
    maskFrame.text:SetSpacing(7)

    function maskFrame.FadeOut()
        UIFrameFadeOut(maskFrame, 0.25, 1, 0)
        C_Timer.After(0.25, function()
            maskFrame:Hide()
        end)
    end

    ---------------------------------------------------------------------
    -- list
    ---------------------------------------------------------------------
    normalList = CreateList(scrollContainer, "BFC_CraftsmanNormalList")
    searchList = CreateList(scrollContainer, "BFC_CraftsmanSearchList")

        ---------------------------------------------------------------------
    -- category
    ---------------------------------------------------------------------
    local ALL = _G.ALL

    categoryDropdown = CreateFrame("DropdownButton", "BFC_CategoryDropdown", craftsmanFrame, "WowStyle1DropdownTemplate")
    categoryDropdown:SetWidth(150)
    categoryDropdown:SetHeight(25)
    categoryDropdown:SetPoint("TOPLEFT", 15, -35)
    categoryDropdown:SetDefaultText(ALL)

    -- local selectedValue = nil

    -- local function IsSelected(value)
    --     return value == selectedValue
    -- end

    -- local function SetSelected(value)
    --     selectedValue = value
    -- end

    -- MenuUtil.CreateRadioMenu(categoryDropdown,
    --     IsSelected,
    --     SetSelected,
    --     {"Radio 1", 1},
    --     {"Radio 2", 2},
    --     {"Radio 3", 3},
    -- )

    local function DropdownOnClick(category)
        if category then
            local c1, c2, c3 = strsplit("|", category)
            categoryDropdown:OverrideText(c3 or c2 or c1)
            categoryFilter = BFC.GetRelatedCategories(category)
        else -- all
            categoryDropdown:OverrideText(ALL)
            categoryFilter = nil
        end
        listUpdateRequired = isSearch
        LoadData(isSearch and searchBox:GetText())
    end

    categoryDropdown:SetupMenu(function(dropdown, rootDescription)
        -- rootDescription:SetGridMode(MenuConstants.VerticalGridDirection, 3)
        rootDescription:CreateButton(ALL, DropdownOnClick)
        rootDescription:CreateDivider()

        for _, t1 in pairs(BFC.category) do
            local b1 = rootDescription:CreateButton(t1.category)
            -- all
            b1:CreateButton(ALL, DropdownOnClick, t1.category)
            -- divider
            b1:CreateDivider()

            for _, t2 in pairs(t1.subs) do
                local b2 = b1:CreateButton(t2.category, DropdownOnClick, (not t2.subs) and (t1.category .. "|" .. t2.category))

                if t2.subs then
                    -- all
                    b2:CreateButton(ALL, DropdownOnClick, t1.category .. "|" .. t2.category)
                    -- divider
                    b2:CreateDivider()

                    for _, t3 in pairs(t2.subs) do
                        local b3 = b2:CreateButton(t3, DropdownOnClick, t1.category .. "|" .. t2.category .. "|" .. t3)
                    end
                end
            end
        end

        -- rootDescription:CreateTitle()
        -- rootDescription:CreateTitle(_G.ARMOR)
        -- rootDescription:CreateTitle(_G.INVTYPE_PROFESSION_GEAR)
    end)

    ---------------------------------------------------------------------
    -- search
    ---------------------------------------------------------------------
    searchBox = CreateFrame("EditBox", "BFC_SearchBox", craftsmanFrame, "SearchBoxTemplate")
    searchBox:SetScript("OnTextChanged", function(self, userChanged)
        SearchBoxTemplate_OnTextChanged(self)

        BFC.HideMessageFrame()

        local text = searchBox:GetText()
        if string.len(text) == 0 then
            isSearch = false
            normalList:Show()
            normalList.scrollBar:Show()
            searchList:Hide()
            searchList.scrollBar:Hide()
            if listUpdateRequired then
                listUpdateRequired = false
                LoadData()
            else
                topInfoText.Update()
            end
        else
            isSearch = true
            dropdownChangedBySearch = false
            searchList:Show()
            searchList.scrollBar:Show()
            normalList:Hide()
            normalList.scrollBar:Hide()
            if userChanged then
                LoadData(strtrim(text))
            end
        end
    end)

    searchBox:SetPoint("TOPRIGHT", -10, -35)
    searchBox:SetPoint("LEFT", categoryDropdown, "RIGHT", 20, 0)
    searchBox:SetHeight(25)

    ---------------------------------------------------------------------
    -- export
    ---------------------------------------------------------------------
    local exportButton = CreateFrame("Button", nil, craftsmanFrame, "UIPanelButtonTemplate")
    exportButton:SetPoint("TOPRIGHT", -15, -65)
    exportButton:SetTextToFit("导出")
    exportButton:SetScript("OnClick", function()
        BFC.ShowExportFrame()
    end)

    ---------------------------------------------------------------------
    -- import
    ---------------------------------------------------------------------
    local importButton = CreateFrame("Button", nil, craftsmanFrame, "UIPanelButtonTemplate")
    importButton:SetPoint("BOTTOMRIGHT", exportButton, "BOTTOMLEFT", -3, 0)
    importButton:SetTextToFit("导入")
    importButton:SetScript("OnClick", function()
        BFC.ShowImportFrame()
    end)

    ---------------------------------------------------------------------
    -- data timeliness
    ---------------------------------------------------------------------
    tipsFrame = CreateFrame("Frame", nil, craftsmanFrame, "TooltipBackdropTemplate")
    tipsFrame:SetPoint("BOTTOMRIGHT", craftsmanFrame, "BOTTOMRIGHT", -15, 30)
    tipsFrame:SetSize(450, 10)
    tipsFrame:SetFrameLevel(craftsmanFrame:GetFrameLevel() + 150)
    tipsFrame:EnableMouse(true)
    tipsFrame.NineSlice.Center:SetTexture("interface/buttons/white8x8")
    tipsFrame:SetBackdropColor(0.125, 0.1, 0.1, 0.95)
    tipsFrame:Hide()

    tipsFrame.closeBtn = CreateFrame("Button", nil, tipsFrame, "UIPanelButtonTemplate") -- UIPanelCloseButton
    tipsFrame.closeBtn:SetPoint("BOTTOMLEFT", 10, 10)
    tipsFrame.closeBtn:SetPoint("BOTTOMRIGHT", -10, 10)
    tipsFrame.closeBtn:SetText("好的")
    tipsFrame.closeBtn:SetScript("OnClick", function()
        tipsFrame:Hide()
    end)

    tipsFrame.text = tipsFrame:CreateFontString(nil, "OVERLAY", "BFC_FONT_WHITE")
    tipsFrame.text:SetPoint("TOPLEFT", 10, -10)
    -- tipsFrame.text:SetPoint("TOPRIGHT", -10, -10)
    tipsFrame.text:SetJustifyH("LEFT")
    tipsFrame.text:SetSpacing(5)

    tipsFrame:SetScript("OnShow", function()
        tipsFrame:SetHeight(tipsFrame.text:GetHeight() + 50)
        tipsFrame:SetWidth(tipsFrame.text:GetWidth() + 20)
    end)
end

---------------------------------------------------------------------
-- CraftsmanButtonMixin
---------------------------------------------------------------------
CraftsmanButtonMixin = {}

function CraftsmanButtonMixin:OnLoad()
    self.FavoriteButton:SetScript("OnEnter", function()
        self:OnEnter()
    end)

    self.FavoriteButton:SetScript("OnLeave", function()
        self:OnLeave()
    end)

    self.FavoriteButton:SetScript("OnClick", function()
        self:GetData().isFavorite = not self:GetData().isFavorite
        -- update BFCCraftsman.favorites
        if self:GetData().isFavorite then
            BFCCraftsman.favorites[self:GetData().playerFull] = true
        else
            BFCCraftsman.favorites[self:GetData().playerFull] = nil
        end

        -- update list
        for index, elementData in normalList.dataProvider:Enumerate() do
            elementData.isFavorite = BFCCraftsman.favorites[elementData.playerFull]
            local button = normalList.view:FindFrame(elementData)
            if button then
                button:UpdateFavoriteButton()
            end
        end
        for index, elementData in searchList.dataProvider:Enumerate() do
            elementData.isFavorite = BFCCraftsman.favorites[elementData.playerFull]
            local button = searchList.view:FindFrame(elementData)
            if button then
                button:UpdateFavoriteButton()
            end
        end
    end)
end

function CraftsmanButtonMixin:OnEnter()
    self.MouseoverOverlay:Show()
    if not self:GetData().isFavorite then
        self.FavoriteButton.NormalTexture:Show()
    end
end

function CraftsmanButtonMixin:OnLeave()
    self.MouseoverOverlay:Hide()
    if not self:GetData().isFavorite then
        self.FavoriteButton.NormalTexture:Hide()
    end
end

function CraftsmanButtonMixin:UpdateFavoriteButton()
    local isFavorite = self:GetData().isFavorite
    local currAtlas = isFavorite and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off"
    self.FavoriteButton.NormalTexture:SetAtlas(currAtlas)
    self.FavoriteButton.NormalTexture:SetShown(isFavorite)
    self.FavoriteButton.HighlightTexture:SetAtlas(currAtlas)
    self.FavoriteButton.HighlightTexture:SetAlpha(isFavorite and 0.2 or 0.4)
end

function CraftsmanButtonMixin:UpdateText(elementData)
    self.TitleLabel:SetText(elementData.title)
    self.PriceLabel:SetText(elementData.price .. "|A:Coin-Gold:0:0|a")
    self.PlayerLabel:SetText(elementData.player)
    self:UpdateFavoriteButton()
end

---------------------------------------------------------------------
-- load data
---------------------------------------------------------------------
local ticker, timer
local loaded = 0
local entries

local function DoLoad_Progressive()
    loaded = loaded + 1

    if isSearch then
        searchList.dataProvider:Insert(matchedResult[loaded])
    else
        normalList.dataProvider:Insert(matchedResult[loaded])
    end

    -- update loding
    maskFrame.text:SetFormattedText("正在加载工匠数据……\n%d%%", loaded / entries * 100)

    -- finished
    if loaded == entries then
        timer = C_Timer.After(0.25, maskFrame.FadeOut)
    end
end

local function DoLoad_Instant()
    for i = 1, MAX_ENTRIES do
        t = matchedResult[i]
        if not t then break end

        if isSearch then
            searchList.dataProvider:Insert(t)
            -- searchList.dataProvider:Sort()
        else
            normalList.dataProvider:Insert(t)
            -- normalList.dataProvider:Sort()
        end
    end

    timer = C_Timer.After(0.25, maskFrame.FadeOut)
end

local function PrepareData(text)
    local result = {}

    -- category
    if not categoryFilter then
        result = BFC.Copy(BFC.loadedCraftsman.data)
    else
        for _, t in pairs(BFC.loadedCraftsman.data) do
            if categoryFilter[t.categoryName] then
                tinsert(result, BFC.Copy(t))
            end
        end
    end

    -- search
    if text then
        local matched = {}
        for _, data in pairs(result) do
            -- title
            if (data.title and strfind(data.title, text)) or
                (data.categoryName and strfind(data.categoryName, text)) or
                (data.itemName and strfind(data.itemName, text)) or
                (data.itemLevel and strfind(data.itemLevel, text)) or
                (data.gameCharacterName and strfind(data.gameCharacterName, text)) then
                tinsert(matched, data)
            end
        end
        result = matched
    end

    -- complete data
    for i, t in pairs(result) do
        t.index = i

        t.title = t.title:gsub("%[", "|cffffff00[")
        t.title = t.title:gsub("%]", "]|r")

        if strfind(t.gameCharacterName, "-") then
            t.playerFull = t.gameCharacterName
            t.player = strsplit("-", t.gameCharacterName)
        else
            t.playerFull = t.gameCharacterName .. "-" .. t.serverName
            t.player = t.gameCharacterName
        end

        t.isFavorite = BFCCraftsman.favorites[t.playerFull]

        t.gameCharacterName = nil
        t.serverName = nil
    end

    -- sort
    sort(result, SortComparator)

    return result
end

function LoadData(text)
    BFC.HideMessageFrame()

    if ticker then
        ticker:Cancel()
        ticker = nil
    end

    if timer then
        timer:Cancel()
        timer = nil
    end

    maskFrame:Show()
    maskFrame:SetAlpha(1)
    maskFrame.text:SetText("正在加载工匠数据……")

    if isSearch then
        searchList.dataProvider:Flush()
    else
        normalList.dataProvider:Flush()
        listUpdateRequired = false
    end

    if #BFC.loadedCraftsman.data == 0 then
        searchEntries = 0
        listEntries = 0
        maskFrame.text:SetText("没有工匠数据……") -- TODO:
        topInfoText.Update()
        return
    end

    -- update time
    updateTimeText:SetText("数据更新时间：" .. date("%Y/%m/%d %H:%M", BFC.loadedCraftsman.updateTime))

    -- filter
    matchedResult = PrepareData(text)
    if isSearch then
        searchEntries = min(#matchedResult, MAX_ENTRIES)
        entries = searchEntries
    else
        listEntries = min(#matchedResult, MAX_ENTRIES)
        entries = listEntries
    end
    topInfoText.Update()

    if entries == 0 then
        maskFrame.text:SetText("没有匹配条件的工匠数据……") -- TODO:
        maskFrame.FadeOut()
        return
    end

    loaded = 0
    -- ticker = C_Timer.NewTicker(0, DoLoad_Progressive, entries)
    DoLoad_Instant()

    -- local start = GetTimePreciseSec()
    -- for i = 1, n do
    --     DoLoad_Instant()
    -- end
    -- print("time cost:", GetTimePreciseSec() - start)
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
function BFC.ShowCraftsmanFrame(item)
    if not craftsmanFrame then
        CreateCraftsmanFrame()
    end

    BFC_MainFrame.Inset:SetPoint("TOPLEFT", 11, -ATTIC_HEIGHT)

    craftsmanFrame:Show()

    if not craftsmanFrame.loaded then
        craftsmanFrame.loaded = true
        if not item then
            listUpdateRequired = true
            LoadData()
        end

        if time() - BFC.loadedCraftsman.updateTime >= EXPIRED_THRESHOLD then
            tipsFrame.text:SetFormattedText(DATA_EXPIRED, (time() - BFC.loadedCraftsman.updateTime) / DAY)
            tipsFrame:Show()
        else
            tipsFrame:Hide()
        end
    end

    if item then
        isSearch = true
        searchBox:SetText(item)
        LoadData(item)
    end
end

---------------------------------------------------------------------
-- reload
---------------------------------------------------------------------
function BFC.ReloadCraftsmanData()
    isSearch = false
    searchEntries = 0
    listEntries = 0
    searchBox:SetText("")
    categoryFilter = nil
    categoryDropdown:OverrideText(ALL)
    LoadData()
end