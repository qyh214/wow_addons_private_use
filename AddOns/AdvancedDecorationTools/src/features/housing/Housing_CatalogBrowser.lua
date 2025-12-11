-- CatalogBrowser：装饰清单浏览（ADT 独立实现）
-- 功能：显示所有已放置装饰物的列表，支持搜索、高亮定位
local ADDON_NAME, ADT = ...
local L = ADT and ADT.L or {}

-- 本地化 API
local C_HousingDecor = C_HousingDecor
local GetAllPlacedDecor = C_HousingDecor.GetAllPlacedDecor
local GetDecorInstanceInfoForGUID = C_HousingDecor.GetDecorInstanceInfoForGUID
-- 12.0：以下 API 属于受保护动作，第三方插件调用会触发“被禁止的UI动作”。
-- 这里不再直接引用，改为在 UI 内部做被动展示（仅提示，不驱动游戏态）。
-- local SetPlacedDecorEntryHovered = C_HousingDecor.SetPlacedDecorEntryHovered
local IsHouseEditorActive = C_HouseEditor.IsHouseEditorActive
local GetActiveHouseEditorMode = C_HouseEditor.GetActiveHouseEditorMode
local GetCatalogEntryInfoByRecordID = C_HousingCatalog.GetCatalogEntryInfoByRecordID

-- 模块表
local DecorBrowser = {}
ADT.DecorBrowser = DecorBrowser

-- 缓存
local decorCache = {}
local lastHoveredGUID = nil


-- 获取目录信息（与 DecorHover 共用逻辑）
local function GetCatalogDecorInfo(decorID)
    return GetCatalogEntryInfoByRecordID(1, decorID, true)
end

-- 刷新装饰物缓存
function DecorBrowser:RefreshCache()
    wipe(decorCache)
    
    if not IsHouseEditorActive() then return decorCache end
    
    local placedDecor = GetAllPlacedDecor()
    if not placedDecor then return decorCache end
    
    for i, entry in ipairs(placedDecor) do
        local guid = entry.decorGUID
        local info = GetDecorInstanceInfoForGUID(guid)
        if info then
            local catalogInfo = GetCatalogDecorInfo(info.decorID)
            table.insert(decorCache, {
                guid = guid,
                name = info.name or "未知装饰",
                decorID = info.decorID,
                -- 库存数量
                stored = catalogInfo and (catalogInfo.quantity or 0) + (catalogInfo.remainingRedeemable or 0) or 0,
                -- 原始数据
                instanceInfo = info,
                catalogInfo = catalogInfo,
            })
        end
    end
    
    -- 按名称排序
    table.sort(decorCache, function(a, b)
        return a.name < b.name
    end)
    
    return decorCache
end

-- 获取缓存数据
function DecorBrowser:GetDecorList()
    return decorCache
end

-- 依据 recordID 查找任意一个已放置实例的 GUID（优先使用已缓存数据；必要时刷新一次缓存）
-- 高亮指定装饰物
function DecorBrowser:HighlightDecor(guid)
    -- KISS + 遵循API限制：不再尝试调用受保护的高亮API。
    -- 仅记录“当前意向高亮”的 guid，以便后续在我们自己的 UI 上做提示。
    -- 这样不会影响暴雪原生的“已放置清单/世界高亮”交互，也不会触发受保护动作。
    if guid and type(guid) == "string" then
        lastHoveredGUID = guid
    else
        lastHoveredGUID = nil
    end
end

-- 清除高亮
function DecorBrowser:ClearHighlight()
    -- 清空我们内部的“意向高亮”状态即可。
    lastHoveredGUID = nil
end

-- 搜索过滤
function DecorBrowser:FilterByName(keyword)
    if not keyword or keyword == "" then
        return decorCache
    end
    
    keyword = string.lower(keyword)
    local results = {}
    
    for _, item in ipairs(decorCache) do
        if string.find(string.lower(item.name), keyword, 1, true) then
            table.insert(results, item)
        end
    end
    
    return results
end

-- 获取统计信息
function DecorBrowser:GetStats()
    local total = #decorCache
    local budget = C_HousingDecor.GetSpentPlacementBudget() or 0
    local maxBudget = C_HousingDecor.GetMaxPlacementBudget() or 500
    
    return {
        count = total,
        budget = budget,
        maxBudget = maxBudget,
    }
end

------------------------------------------------------------
-- UI 弹窗
------------------------------------------------------------
local BrowserFrame = nil
local scrollChild = nil
local searchBox = nil
local itemButtons = {}

-- 创建按钮池
local function GetItemButton(index)
    if itemButtons[index] then
        return itemButtons[index]
    end
    
    local btn = CreateFrame("Button", nil, scrollChild)
    btn:SetSize(280, 28)
    btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    
    -- 名称
    btn.Name = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.Name:SetPoint("LEFT", 8, 0)
    btn.Name:SetWidth(200)
    btn.Name:SetJustifyH("LEFT")
    btn.Name:SetWordWrap(false)
    
    -- 库存数量
    btn.Count = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.Count:SetPoint("RIGHT", -8, 0)
    btn.Count:SetTextColor(0.7, 0.7, 0.7)
    
    -- 交互
    btn:SetScript("OnEnter", function(self)
        if self.guid then
            DecorBrowser:HighlightDecor(self.guid)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.decorName or "装饰物", 1, 1, 1)
            if self.stored and self.stored > 0 then
                GameTooltip:AddLine("库存: " .. self.stored, 0.7, 0.7, 0.7)
            end
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("点击复制名称到聊天框", 0, 1, 0)
            GameTooltip:Show()
        end
    end)
    
    btn:SetScript("OnLeave", function(self)
        DecorBrowser:ClearHighlight()
        GameTooltip:Hide()
    end)
    
    btn:SetScript("OnClick", function(self)
        if self.decorName then
            -- 复制名称到聊天框
            if ChatEdit_InsertLink then
                ChatEdit_InsertLink(self.decorName)
            end
        end
    end)
    
    itemButtons[index] = btn
    return btn
end

-- 更新列表显示
local function UpdateListDisplay(filteredList)
    filteredList = filteredList or decorCache
    
    -- 隐藏所有按钮
    for _, btn in ipairs(itemButtons) do
        btn:Hide()
    end
    
    -- 显示过滤后的列表
    for i, item in ipairs(filteredList) do
        local btn = GetItemButton(i)
        btn.guid = item.guid
        btn.decorName = item.name
        btn.stored = item.stored
        
        btn.Name:SetText(item.name)
        if item.stored > 0 then
            btn.Count:SetText("x" .. item.stored)
        else
            btn.Count:SetText("")
        end
        
        btn:SetPoint("TOPLEFT", 0, -(i - 1) * 30)
        btn:Show()
    end
    
    -- 更新滚动区域高度
    if scrollChild then
        scrollChild:SetHeight(math.max(#filteredList * 30, 100))
    end
    
    -- 更新标题统计
    if BrowserFrame and BrowserFrame.Title then
        local stats = DecorBrowser:GetStats()
        BrowserFrame.Title:SetText(string.format("装饰物浏览器 (%d/%d)", stats.budget, stats.maxBudget))
    end
end

-- 创建浏览器弹窗
local function CreateBrowserFrame()
    if BrowserFrame then
        return BrowserFrame
    end
    
    -- 主框架
    local frame = CreateFrame("Frame", "ADT_DecorBrowserFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(320, 420)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    
    -- 标题
    frame.Title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.Title:SetPoint("TOP", 0, -5)
    frame.Title:SetText("装饰物浏览器")
    
    -- 搜索框
    searchBox = CreateFrame("EditBox", nil, frame, "SearchBoxTemplate")
    searchBox:SetSize(280, 22)
    searchBox:SetPoint("TOP", frame.Inset, "TOP", 0, -8)
    searchBox:SetAutoFocus(false)
    searchBox:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        local filtered = DecorBrowser:FilterByName(text)
        UpdateListDisplay(filtered)
    end)
    
    -- 刷新按钮
    local refreshBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    refreshBtn:SetSize(60, 22)
    refreshBtn:SetPoint("TOPRIGHT", frame.Inset, "TOPRIGHT", -4, -8)
    refreshBtn:SetText("刷新")
    refreshBtn:SetScript("OnClick", function()
        DecorBrowser:RefreshCache()
        if searchBox then
            searchBox:SetText("")
        end
        UpdateListDisplay()
    end)
    
    -- 滚动框架
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame.Inset, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 8, -38)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)
    
    scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(280, 1)
    scrollFrame:SetScrollChild(scrollChild)
    if ADT and ADT.Scroll and ADT.Scroll.AttachScrollFrame then
        ADT.Scroll.AttachScrollFrame(scrollFrame)
    end
    
    -- 空状态提示
    frame.EmptyText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    frame.EmptyText:SetPoint("CENTER", 0, 50)
    frame.EmptyText:SetText("暂无放置的装饰物\n\n请在编辑模式下打开此面板")
    frame.EmptyText:Hide()
    
    -- ESC 关闭
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
            self:SetPropagateKeyboardInput(false)
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)
    
    -- 显示时刷新
    frame:SetScript("OnShow", function(self)
        DecorBrowser:RefreshCache()
        UpdateListDisplay()
        
        -- 显示空状态
        if #decorCache == 0 then
            self.EmptyText:Show()
        else
            self.EmptyText:Hide()
        end
    end)
    
    -- 隐藏时清除高亮
    frame:SetScript("OnHide", function(self)
        DecorBrowser:ClearHighlight()
    end)
    
    -- 注册到特殊框架列表（ESC 关闭）
    table.insert(UISpecialFrames, "ADT_DecorBrowserFrame")
    
    frame:Hide()
    BrowserFrame = frame
    return frame
end

-- 切换显示/隐藏
function DecorBrowser:Toggle()
    local frame = CreateBrowserFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- 显示
function DecorBrowser:Show()
    local frame = CreateBrowserFrame()
    frame:Show()
end

-- 隐藏
function DecorBrowser:Hide()
    if BrowserFrame then
        BrowserFrame:Hide()
    end
end

------------------------------------------------------------
-- 斜杠命令
------------------------------------------------------------
SLASH_ADTBROWSER1 = "/adtbrowser"
SLASH_ADTBROWSER2 = "/装饰浏览"
SlashCmdList["ADTBROWSER"] = function(msg)
    DecorBrowser:Toggle()
end

------------------------------------------------------------
-- 编辑模式监听（自动关闭）
------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "HOUSE_EDITOR_MODE_CHANGED" then
        -- 退出编辑模式时关闭浏览器
        if not IsHouseEditorActive() and BrowserFrame and BrowserFrame:IsShown() then
            BrowserFrame:Hide()
        end
    end
end)
