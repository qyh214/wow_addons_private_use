local ADDON_NAME, mppe = ...
local translate = mppe.Translate

-- 用于存储周报框架的引用，供外部函数访问
mppe.WeeklyReportFrame = nil

-- ==================================================================
-- 定义函数（这些函数将在外部可用，内部通过 mppe.WeeklyReportFrame 访问框架）
-- ==================================================================

-- 根据周数据表格生成窗体内文字（后期考虑调整格式）
function mppe.WeeklyReport_TextMode(test)
    local frame = mppe.WeeklyReportFrame
    if not frame then return end
    local mainText = frame.mainText
    if not mainText then return end

    mainText:SetFont(mainText:GetFont(), MythicPlusPageExtensionDB.WeeklyReport_FontSize)
    mainText:SetJustifyH("LEFT")
    mainText:SetJustifyV("TOP")
    local dunRuns = frame:GetWeeklyData(test)
    
    -- 提前检查数据，避免后续不必要的计算
    if not dunRuns.TOTAL or #dunRuns.TOTAL == 0 then return end
    
    -- 颜色格式化函数
    local function colorByOvertime(level, overtime)
        return string.format("%s%d|r", overtime and "|cffff0000" or "|cff00ff00", level)
    end
    
    -- 初始化缓存
    local textParts = {}
    local translate = mppe.Translate
    local dungeons = mppe.Dungeons
    
    -- 宝库奖励等级映射
    local vaultRewards = {
        "",
        translate['Champion'].."4",
        translate['Hero'].."1",
        translate['Hero'].."1",
        translate['Hero'].."2",
        translate['Hero'].."2",
        translate['Hero'].."3",
        translate['Hero'].."4",
        translate['Hero'].."4", 
        translate['Myth'].."1", 
    }
    if MythicPlusPageExtensionDB.WeeklyReport_ShowWeeklyTOP8 then
        -- 添加标题
        table.insert(textParts, "|c00FFBA1A" .. translate['Top 8 Weekly Mythic+ Runs:'] .. "|r")
        table.insert(textParts, "\n") -- 添加一个空行
        -- 处理前8条记录
        for ti, d in ipairs(dunRuns.TOP8) do
            local dungeonInfo = dungeons[d.dunID]
            local dunShortname = dungeonInfo and translate[dungeonInfo.Name] or "Unknown"
            
            local line = "\n  " .. colorByOvertime(d.level, d.overtime) .. "  " .. dunShortname
            
            if ti == 1 or ti == 4 or ti == 8 then
                local vaultLevel = math.min(d.level, 10)
                line = line .. string.format(" |cffa335ee %s%s|r", 
                    translate['iLvl:'], vaultRewards[vaultLevel])
            end
            
            table.insert(textParts, line) 
        end
        table.insert(textParts, "\n\n") 
    end
    -- 处理总记录
    local totalCount = 0
    local dungeonDetails = {}
    
    for _, d in ipairs(dunRuns.TOTAL) do
        local dungeonInfo = dungeons[d.dunID]
        local dunShortname = dungeonInfo and translate[dungeonInfo.Name] or "Unknown"
        
        local runsText = {}
        for ri, r in ipairs(d.runs) do
            table.insert(runsText, colorByOvertime(r.level, r.overtime))
            totalCount = totalCount + 1
        end
        
        table.insert(dungeonDetails, string.format("\n  %s(|T:1:1|t|c00ffff63%d|T:1:1|t|r): %s",
            dunShortname, #d.runs, table.concat(runsText, ", ")))
    end
    
    -- 添加总计标题
    table.insert(textParts, "|c00FFBA1A" .. translate['Weekly Mythic+ Total Runs:'] .. "|r|c00ffff63 " .. totalCount .. " |r")
    table.insert(textParts, "\n") -- 添加一个空行
    -- 合并所有部分
    for _, detail in ipairs(dungeonDetails) do
        table.insert(textParts, detail)
    end
    
    -- 设置最终文本
    mainText:SetText(table.concat(textParts, ""))
end

-- 获取周数据表格（将在框架创建后作为方法附加到框架上，此处不直接定义）

function mppe.WeeklyFrameShowOrHide(show)
    local frame = mppe.WeeklyReportFrame
    if not frame then return end
    if MythicPlusPageExtensionDB.WeeklyReport_Enable and show then
        frame:Show()
        mppe.RefreshWeeklyReport()
    else
        frame:Hide()
    end
end

local function Accordion_Show(isTestMode)
    local frame = mppe.WeeklyReportFrame
    if not frame then return end
    local mainText = frame.mainText
    if not mainText then return end

    mainText:SetText("")
    local dunRuns = frame:GetWeeklyData(isTestMode)
     -- 颜色格式化函数
    local function colorByOvertime(level, overtime)
        return string.format("%s%d|r", overtime and "|cffff0000" or "|cff00ff00", level)
    end
        -- 宝库奖励等级映射
    local vaultRewards = {
        "",
        translate['Champion'].."4",
        translate['Hero'].."1",
        translate['Hero'].."1",
        translate['Hero'].."2",
        translate['Hero'].."2",
        translate['Hero'].."3",
        translate['Hero'].."4",
        translate['Hero'].."4", 
        translate['Myth'].."1", 
    }
    -- 复用或创建框架
    local Frame_Top8 = _G["mppe_WeeklyReportAccordion_Top8"] or 
                       CreateFrame("Frame", "mppe_WeeklyReportAccordion_Top8", frame)
    Frame_Top8:SetWidth(frame:GetWidth() - 10)
    Frame_Top8:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -25)
    Frame_Top8:Show()
    
    -- 标题（不变部分）
    local Header_Top8 = _G["mppe_WeeklyReportAccordion_Top8_Header"] or 
                        CreateFrame("Button", "mppe_WeeklyReportAccordion_Top8_Header", Frame_Top8)
    if not Header_Top8.initialized then
        Header_Top8:SetHeight(25)
        Header_Top8:SetPoint("TOP")
        
        Header_Top8.bg = Header_Top8:CreateTexture(nil, "BACKGROUND")
        Header_Top8.bg:SetAllPoints()
        Header_Top8.bg:SetColorTexture(0.25, 0.25, 0.25, 0.5)
        
        Header_Top8.title = Header_Top8:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        Header_Top8.title:SetPoint("LEFT", 10, 0)
        Header_Top8.title:SetText(mppe.Translate['Top 8 Weekly Mythic+ Runs:'])
        
        Header_Top8.expandIcon = Header_Top8:CreateTexture(nil, "OVERLAY")
        Header_Top8.expandIcon:SetSize(12, 12)
        Header_Top8.expandIcon:SetPoint("RIGHT", -10, 0)
        
        Header_Top8.initialized = true
    end
    
    -- 更新标题宽度
    Header_Top8:SetWidth(Frame_Top8:GetWidth())
    
    -- 内容区域
    local Content_Top8 = _G["mppe_WeeklyReportAccordion_Top8_Content"] or 
                         CreateFrame("Frame", "mppe_WeeklyReportAccordion_Top8_Content", Frame_Top8)
    Content_Top8:SetPoint("TOP", Header_Top8, "BOTTOM")
    Content_Top8:SetWidth(Frame_Top8:GetWidth())
    
    if not Content_Top8.initialized then
        Content_Top8.bg = Content_Top8:CreateTexture(nil, "BACKGROUND")
        Content_Top8.bg:SetAllPoints()
        Content_Top8.bg:SetColorTexture(0.25, 0.25, 0.25, 0.25)
        Content_Top8.initialized = true
    end
    
    -- 清空旧内容
    Content_Top8:Hide()
    
    -- 移除旧内容
    for i = Content_Top8:GetNumChildren(), 1, -1 do
        local child = select(i, Content_Top8:GetChildren())
        child:Hide()
        child:SetParent(nil)
    end
    
    local regions = {Content_Top8:GetRegions()}
    for _, region in ipairs(regions) do
        if region ~= Content_Top8.bg then
            region:Hide()
            region:SetParent(nil)
        end
    end
    
    -- 创建新内容
    if dunRuns and dunRuns.TOP8 and #dunRuns.TOP8 > 0 then
        local contentHeight = 0
        local itemHeight = 20
        local padding = 0
        
        for i, d in ipairs(dunRuns.TOP8) do
            local dungeonInfo = mppe.Dungeons[d.dunID]
            local dunShortname = dungeonInfo and mppe.Translate[dungeonInfo.Name] or "Unknown"
            local _lv = Content_Top8:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            _lv:SetPoint("TOPLEFT", 5, -((i-1) * (itemHeight + padding))-2)
            _lv:SetText(colorByOvertime(d.level, d.overtime))
            _lv:SetWidth(20)

            local _v = Content_Top8:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            if i == 1 or i == 4 or i == 8 then
                local vaultLevel = math.min(d.level, 10)
                _v:SetPoint("TOPRIGHT", -5, -((i-1) * (itemHeight + padding))-2)      
                _v:SetText(string.format("|cffa335ee %s%s|r", mppe.Translate['iLvl:'], vaultRewards[vaultLevel]))
                _v:SetWidth(_v:GetStringWidth())
            end
            
            local _dun = Content_Top8:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            _dun:SetPoint("LEFT",_lv,"RIGHT",3,0)
            _dun:SetWidth(Content_Top8:GetWidth()-_lv:GetWidth()-(_v:GetWidth() or 0) - 10)
            _dun:SetText(dunShortname)
            _dun:SetJustifyH("LEFT")

            -- 创建每行内容
            -- local line = Content_Top8:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            -- line:SetPoint("TOP", 0, -((i-1) * (itemHeight + padding))-2)
            -- line:SetText(colorByOvertime(d.level, d.overtime) .. "  " .. dunShortname)
            -- line:SetJustifyH("LEFT")
            -- line:SetWidth(Content_Top8:GetWidth() - 20)
            
            contentHeight = contentHeight + itemHeight + padding
        end
        
        -- 设置内容高度
        Content_Top8:SetHeight(contentHeight + padding)
        
        -- 更新折叠状态
        Header_Top8.expandIcon:SetAtlas("common-icon-plus")
        Frame_Top8:SetHeight(Header_Top8:GetHeight())
        
        -- 点击事件
        Header_Top8:SetScript("OnClick", function()
            if Content_Top8:IsShown() then
                Content_Top8:Hide()
                Frame_Top8:SetHeight(Header_Top8:GetHeight())
                Header_Top8.expandIcon:SetAtlas("common-icon-plus")
            else
                Content_Top8:Show()
                Frame_Top8:SetHeight(Header_Top8:GetHeight() + Content_Top8:GetHeight())
                Header_Top8.expandIcon:SetAtlas("common-icon-minus")
            end
        end)
        
        Header_Top8:Enable()
    else
        -- 没有数据时禁用点击
        Header_Top8:Disable()
        --Header_Top8.title:SetText("TOP8 (无数据)")
        --Header_Top8.expandIcon:Hide()
        Frame_Top8:SetHeight(Header_Top8:GetHeight())
    end

    local Frame_Total = _G["mppe_WeeklyReportAccordion_Total"] or 
                       CreateFrame("Frame", "mppe_WeeklyReportAccordion_Total", frame)
    Frame_Total:SetWidth(frame:GetWidth() - 10)
    Frame_Total:SetPoint("TOP", Frame_Top8, "BOTTOM", 0, 0)
    Frame_Total:Show()

    -- 标题（不变部分）
    local Header_Total = _G["mppe_WeeklyReportAccordion_Total_Header"] or 
                        CreateFrame("Button", "mppe_WeeklyReportAccordion_Total_Header", Frame_Total)
    if not Header_Total.initialized then
        Header_Total:SetHeight(25)
        Header_Total:SetPoint("TOP")
        
        Header_Total.bg = Header_Total:CreateTexture(nil, "BACKGROUND")
        Header_Total.bg:SetAllPoints()
        Header_Total.bg:SetColorTexture(0.25, 0.25, 0.25, 0.5)
        
        Header_Total.title = Header_Total:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        Header_Total.title:SetPoint("LEFT", 10, 0)
        Header_Total.title:SetText(mppe.Translate['Weekly Mythic+ Total Runs:'])
        
        Header_Total.expandIcon = Header_Total:CreateTexture(nil, "OVERLAY")
        Header_Total.expandIcon:SetSize(12, 12)
        Header_Total.expandIcon:SetPoint("RIGHT", -10, 0)
        
        Header_Total.initialized = true
    end
    
    -- 更新标题宽度
    Header_Total:SetWidth(Frame_Total:GetWidth())

        -- 内容区域
    local Content_Total = _G["mppe_WeeklyReportAccordion_Total_Content"] or 
                         CreateFrame("Frame", "mppe_WeeklyReportAccordion_Total_Content", Frame_Total)
    Content_Total:SetPoint("TOP", Header_Total, "BOTTOM")
    Content_Total:SetWidth(Frame_Total:GetWidth())
    
    if not Content_Total.initialized then
        Content_Total.bg = Content_Total:CreateTexture(nil, "BACKGROUND")
        Content_Total.bg:SetAllPoints()
        Content_Total.bg:SetColorTexture(0.25, 0.25, 0.25, 0.25)
        Content_Total.initialized = true
    end

        -- 清空旧内容
    Content_Total:Hide()
    
    -- 移除旧内容
    for i = Content_Total:GetNumChildren(), 1, -1 do
        local child = select(i, Content_Total:GetChildren())
        child:Hide()
        child:SetParent(nil)
    end
    
    local regions = {Content_Total:GetRegions()}
    for _, region in ipairs(regions) do
        if region ~= Content_Total.bg then
            region:Hide()
            region:SetParent(nil)
        end
    end
    
    -- 创建新内容
    if dunRuns and dunRuns.TOTAL and #dunRuns.TOTAL > 0 then
        local contentHeight = 0
        local itemHeight = 20
        local padding = 0
        local lastItem = Content_Total
        for i, d in ipairs(dunRuns.TOTAL) do
            local dungeonInfo = mppe.Dungeons[d.dunID]
            local dunShortname = dungeonInfo and mppe.Translate[dungeonInfo.Name] or "Unknown"
            
            local totalItem = CreateFrame("Frame", "mppe_WeeklyReportAccordion_Total_Content_i"..i, Content_Total)
            totalItem:SetWidth(Content_Total:GetWidth())
            if i == 1 then
                totalItem:SetPoint("TOP", lastItem, "TOP", 0, 0)
            else
                totalItem:SetPoint("TOP", lastItem, "BOTTOM", 0, 0)
            end
            totalItem:Show()

            local runsText = {}
            local totalCount = 0
            for ri, r in ipairs(d.runs) do
                table.insert(runsText, colorByOvertime(r.level, r.overtime))
                totalCount = totalCount + 1
            end

            local headerItem = CreateFrame("Button", "mppe_WeeklyReportAccordion_Total_Header_Item"..i, totalItem)
            headerItem:SetHeight(25)
            headerItem:SetPoint("TOP")
            
            headerItem.bg = headerItem:CreateTexture(nil, "BACKGROUND")
            headerItem.bg:SetAllPoints()
            headerItem.bg:SetColorTexture(0.25, 0.25, 0.25, 0.5)
            
            headerItem.title = headerItem:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            headerItem.title:SetPoint("LEFT", 10, 0)
            headerItem.title:SetText(string.format("|c00ffffff%s|r (|T:1:1|t|c00ffff63%d|r|T:1:1|t)",dunShortname,totalCount))
            
            headerItem.expandIcon = headerItem:CreateTexture(nil, "OVERLAY")
            headerItem.expandIcon:SetSize(12, 12)
            headerItem.expandIcon:SetPoint("RIGHT", -10, 0)
            headerItem:SetWidth(totalItem:GetWidth())
            local contentItem = CreateFrame("Frame", "mppe_WeeklyReportAccordion_Total_Content", Frame_Total)
            contentItem:SetPoint("TOP", Header_Total, "BOTTOM")
            contentItem:SetWidth(Frame_Total:GetWidth())

            contentItem.bg = contentItem:CreateTexture(nil, "BACKGROUND")
            contentItem.bg:SetAllPoints()
            contentItem.bg:SetColorTexture(0.25, 0.25, 0.25, 0.25)
            contentItem:Hide()
            local detailItem =  contentItem:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            detailItem:SetPoint("TOPLEFT",headerItem,"BOTTOMLEFT", 15, -2)
            detailItem:SetPoint("TOPRIGHT",headerItem,"BOTTOMRIGHT", -15, -2)
            detailItem:SetText(table.concat(runsText, ", "))
            --detailItem:SetWidth(contentItem:GetWidth())
            detailItem:SetJustifyH("LEFT")
            if detailItem:GetStringWidth()>contentItem:GetWidth()-30 then
                detailItem:SetHeight(detailItem:GetStringHeight()*(1+math.floor(detailItem:GetStringWidth()/(contentItem:GetWidth()-30))))
            else
                detailItem:SetHeight(detailItem:GetStringHeight())
            end
            -- 设置内容高度
            contentItem:SetHeight(detailItem:GetHeight()+4+6)
            
            -- 更新折叠状态
            headerItem.expandIcon:SetAtlas("common-icon-plus")
            totalItem:SetHeight(headerItem:GetHeight())
            
            headerItem.contentItem = contentItem
            totalItem.headerItem = headerItem

            -- 点击事件
            headerItem:SetScript("OnClick", function()
                if contentItem:IsShown() then
                    detailItem:Hide()
                    contentItem:Hide()
                    totalItem:SetHeight(headerItem:GetHeight())
                    headerItem.expandIcon:SetAtlas("common-icon-plus")
                else
                    contentItem:Show()
                    detailItem:Show()
                    totalItem:SetHeight(headerItem:GetHeight() + contentItem:GetHeight())
                    headerItem.expandIcon:SetAtlas("common-icon-minus")
                end
            end)
            lastItem = totalItem
            contentHeight = contentHeight + itemHeight + padding
        end
        
        -- 设置内容高度
        Content_Total:SetHeight(contentHeight + padding)
        
        -- 更新折叠状态
        Header_Total.expandIcon:SetAtlas("common-icon-plus")
        Frame_Total:SetHeight(Header_Total:GetHeight())
        
        -- 点击事件
        Header_Total:SetScript("OnClick", function()
            if Content_Total:IsShown() then
                -- 折叠主面板前，先关闭所有已展开的地牢子面板
                for _, child in ipairs({Content_Total:GetChildren()}) do
                    if child.headerItem and child.headerItem.contentItem then
                        local header = child.headerItem
                        if header.contentItem:IsShown() then
                            local onClick = header:GetScript("OnClick")
                            if onClick then
                                onClick(header)
                            end
                        end
                    end
                end
                Content_Total:Hide()
                Frame_Total:SetHeight(Header_Total:GetHeight())
                Header_Total.expandIcon:SetAtlas("common-icon-plus")
            else
                Content_Total:Show()
                Frame_Total:SetHeight(Header_Total:GetHeight() + Content_Total:GetHeight())
                Header_Total.expandIcon:SetAtlas("common-icon-minus")
            end
        end)
        
        Header_Total:Enable()
    else
        -- 没有数据时禁用点击
        Header_Total:Disable()
        --Header_Top8.title:SetText("TOP8 (无数据)")
        --Header_Top8.expandIcon:Hide()
        Frame_Total:SetHeight(Header_Total:GetHeight())
    end

    --Frame_Total:SetHeight(20)
end

local function Accordion_AutoSize()
    
end

function mppe.RefreshWeeklyReport(isTestMode)
    local frame = mppe.WeeklyReportFrame
    if not frame then return end
    if (MythicPlusPageExtensionDB.WeeklyReport_FrameStyle and MythicPlusPageExtensionDB.WeeklyReport_FrameStyle) == "accordion" then
        -- if WeeklyReport_Inited then
            Accordion_Show(isTestMode)
        -- end
    else
        mppe.WeeklyReport_TextMode(isTestMode)
    end 
end

-- ==================================================================
-- 监听 PLAYER_LOGIN 事件创建周报主窗体
-- ==================================================================
local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function()
    -- 在 PLAYER_LOGIN 时重新检查 UI 插件
    local UiE = ElvUI and ElvUI[1]
    local UiN = NDui and NDui[1]

    -- print("PLAYER_LOGIN: " .. (UiE and "ElvUI Found" or (UiN and "NDui Found" or "No UI")))

    -- ==================================================================
    -- 周报主窗体创建
    local mppeFrame 

    -- 根据 UI 插件应用样式
    if UiE then
        mppeFrame = CreateFrame("Frame", "MythicPlusPageExtensionFrame", UIParent)
        mppeFrame:CreateBackdrop("Transparent")
        local closeButton = CreateFrame("Button", "MythicPagePlus_UiECloseBtn", mppeFrame)
        closeButton:SetSize(20, 20)
        closeButton:SetPoint("TOPRIGHT", mppeFrame, "TOPRIGHT", 0, 0)
        closeButton:SetScript("OnClick", function() mppeFrame:Hide() end)
        local skins = UiE:GetModule('Skins')
        skins:HandleCloseButton(closeButton)
    elseif UiN then
        mppeFrame = CreateFrame("Frame", "MythicPlusPageExtensionFrame", UIParent, "SettingsFrameTemplate")
        local skins = UiN:GetModule("Skins")
        UiN.StripTextures(mppeFrame)
        UiN.SetBD(mppeFrame)
        
        UiN.ReskinClose(mppeFrame.ClosePanelButton)
    else
        mppeFrame = CreateFrame("Frame", "MythicPlusPageExtensionFrame", UIParent, "SettingsFrameTemplate")
    end

    -- 公共属性
    mppeFrame:SetSize(300, 300)
    mppeFrame:SetPoint("CENTER")
    mppeFrame:SetMovable(false)
    mppeFrame:EnableMouse(true)
    mppeFrame:SetScript("OnDragStart", mppeFrame.StartMoving)
    mppeFrame:SetScript("OnDragStop", mppeFrame.StopMovingOrSizing)
    mppeFrame:SetScript("OnShow", function()
        if not MythicPlusPageExtensionDB.WeeklyReport_Enable then
            mppeFrame:Hide()
        else
            mppeFrame:UpdateFollowFramePosition()
        end
        if MythicPlusPageExtensionDB.WeeklyReport_HideRaiderIOFrame and RaiderIO_ProfileTooltip then
            RaiderIO_ProfileTooltip:Hide()
        end
    end)
    mppeFrame:Hide()

    -- 标题
    mppeFrame.title = mppeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mppeFrame.title:SetPoint("TOP", mppeFrame, 0, -5)
    mppeFrame.title:SetText("MPPE")

    -- 存储要跟随的窗口
    local targetFrame = PVEFrame

    -- 文本显示区域
    local mainText = mppeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    mainText:SetPoint("TOPLEFT", mppeFrame, "TOPLEFT", 15, -30)
    mainText:SetPoint("BOTTOMRIGHT", mppeFrame, "BOTTOMRIGHT", -15, 15)
    mainText:SetText("|c00FFBA1A"..mppe.Translate['There are no records for this week yet!'] .. "|r")
    mainText:SetJustifyH("CENTER")
    mainText:SetJustifyV("MIDDLE")
    mppeFrame.mainText = mainText  -- 存储到框架上供函数使用

    -- 更新跟随框体位置的函数
    function mppeFrame:UpdateFollowFramePosition()
        if not targetFrame or not targetFrame:IsShown() then
            mppeFrame:Hide()
            return
        end
        if UiE or UiN then
            mppeFrame:SetSize(MythicPlusPageExtensionDB.WeeklyReport_FrameWidth, targetFrame:GetHeight()+MythicPlusPageExtensionDB.WeeklyReport_FrameHeightCorrection)
            mppeFrame:ClearAllPoints()
            mppeFrame:SetPoint("TOPLEFT", targetFrame, "TOPRIGHT", 0, MythicPlusPageExtensionDB.WeeklyReport_FrameHeightCorrection/2)
        else
            mppeFrame:SetSize(MythicPlusPageExtensionDB.WeeklyReport_FrameWidth, targetFrame:GetHeight())
            mppeFrame:ClearAllPoints()
            mppeFrame:SetPoint("TOPLEFT", targetFrame, "TOPRIGHT", -7, 0)
        end
        -- 确保跟随窗口不会超出屏幕
        if mppeFrame:GetLeft() < 0 then
            mppeFrame:SetPoint("LEFT", UIParent, "LEFT", 5, 0)
        end

        mppeFrame:Show()
    end

    -- 处理目标窗口移动
    if targetFrame.SetScript then
        local originalOnDragStop = targetFrame:GetScript("OnDragStop")
        if originalOnDragStop then
            targetFrame:SetScript("OnDragStop", function(self, ...)
                originalOnDragStop(self, ...)
                mppeFrame:UpdateFollowFramePosition()
            end)
        end

        local originalOnSizeChanged = targetFrame:GetScript("OnSizeChanged")
        if originalOnSizeChanged then
            targetFrame:SetScript("OnSizeChanged", function(self, ...)
                if originalOnSizeChanged then
                    originalOnSizeChanged(self, ...)
                end
                mppeFrame:UpdateFollowFramePosition()
            end)
        end
    end

    -- 初始检查（如果目标窗口已经打开）
    if targetFrame:IsShown() then
        mppeFrame:UpdateFollowFramePosition()
    end

    -- ==================================================================
    -- 设置按钮
    mppeFrame.SettingBtn = CreateFrame("Button", "MythicPagePlus_SettingBtn", mppeFrame, "UIPanelIconDropdownButtonTemplate")
    mppeFrame.SettingBtn:SetPoint("TOPRIGHT", -27, -4)

    if UiE then
        -- ElvUI 下按钮可能已有样式，无需额外纹理
    elseif UiN then
        UiN.Reskin(mppeFrame.SettingBtn)
        mppeFrame.SettingBtn:ClearAllPoints()
        mppeFrame.SettingBtn:SetPoint("TOPRIGHT", -27, -6)
    else
        local settingsBtn_texture = mppeFrame.SettingBtn:CreateTexture(nil, "OVERLAY")
        settingsBtn_texture:SetSize(mppeFrame.SettingBtn:GetWidth()+16,mppeFrame.SettingBtn:GetWidth()+16)
        settingsBtn_texture:SetPoint("CENTER", 0, -3)
        settingsBtn_texture:SetAtlas("common-dropdown-a-button-settings-shadowless")
    end

    local originalOnMouseDown = mppeFrame.SettingBtn:GetScript("OnMouseDown")
    local originalOnMouseUp = mppeFrame.SettingBtn:GetScript("OnMouseUp")
    mppeFrame.SettingBtn:SetScript("OnMouseDown", function(self, button, ...)    
        self.downButton = button
        if originalOnMouseDown then return originalOnMouseDown(self, button, ...) end
    end)

    mppeFrame.SettingBtn:SetScript("OnMouseUp", function(self, button, ...)
        if self.downButton == button then
            if button == "LeftButton" and IsShiftKeyDown() then
                --mppe.PartyEvent:RequestKeystone()
                --mppe.DebugPrint(mppe.PartyMember)
                --mainText:SetText("")
                -- if UiN then
                --     print("NDUI")
                -- else
                --     print("No")
                -- end
                mppe.RefreshWeeklyReport(true)
            elseif button == "LeftButton" then
                mppe.SettingsShow()
            elseif button == "RightButton" and IsShiftKeyDown() then
                mppe.RefreshWeeklyReport(true) 
            elseif button == "RightButton" then  
                mppe.RequestPartyInfo()        
                mppe.RefreshScoreNTeleport()
                mppe.RefreshWeeklyReport()
                mppe.RefreshPartyInfo()
                mppe.RefreshPartyInspector()
            end
        end
        self.downButton = nil
        if originalOnMouseUp then return originalOnMouseUp(self, button, ...) end
    end)

    mppeFrame.SettingBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("MPPE By CN2714"..(mppe.Translator and " ("..mppe.Translator..")" or ""))
        GameTooltip:AddLine(mppe.Translate['Left-Click:Settings(/mppe)'], 1, 1, 1)
        GameTooltip:AddLine(mppe.Translate['Right-Click:Refresh(Score&Teleport/PartyInfo/WeeklyReport)'], 1, 1, 1)
        GameTooltip:Show()
    end)
    mppeFrame.SettingBtn:SetScript("OnLeave", function(self)
        self.downButton = nil
        GameTooltip:Hide()
    end)

    -- ==================================================================
    -- 将 GetWeeklyData 方法附加到框架上
    function mppeFrame:GetWeeklyData(isTestMode)
        local dunRuns = {
            TOP8 = {},
            TOTAL = {}
        }
        
        local runHistory
        
        -- 测试模式：生成随机数据
        if isTestMode then
            local testData = {
                dungeons = {499, 505, 503, 525, 542, 391, 392, 378},
                levels = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11,},-- 12, 13, 14, 15, 16, 17, 18, 19, 20},
                completed = {true, false}
            }
            
            local function randomFromArray(array)
                return array[math.random(1, #array)]
            end
            
            local totalRuns = math.random(100, 200)
            runHistory = {}
            
            for i = 1, totalRuns do
                runHistory[i] = {
                    mapChallengeModeID = randomFromArray(testData.dungeons),
                    level = randomFromArray(testData.levels),
                    completed = randomFromArray(testData.completed)
                }
            end
        else
            -- 真实数据
            runHistory = C_MythicPlus.GetRunHistory(false, true)
        end
        
        if #runHistory == 0 then
            return dunRuns
        end
        
        -- 对 runHistory 按 level,completed(false=0,true=1) 降序排序
        table.sort(runHistory, function(a, b)
            if a.level ~= b.level then
                return a.level > b.level
            end
            if a.completed ~= b.completed then
                return a.completed  
            end
            return a.mapChallengeModeID < b.mapChallengeModeID
        end)
        
        -- 处理TOP8
        for i = 1, math.min(8, #runHistory) do
            local run = runHistory[i]
            dunRuns.TOP8[i] = {
                dunID = run.mapChallengeModeID,
                level = run.level,
                overtime = not run.completed
            }
        end
        
        -- 按副本分组统计所有记录
        local dungeonGroups = {}
        
        for _, run in ipairs(runHistory) do
            local dungeonId = run.mapChallengeModeID
            local dungeonGroup = dungeonGroups[dungeonId]
            
            if not dungeonGroup then
                dungeonGroup = {dunID = dungeonId, runs = {}}
                dungeonGroups[dungeonId] = dungeonGroup
                table.insert(dunRuns.TOTAL, dungeonGroup)
            end
            
            table.insert(dungeonGroup.runs, {
                level = run.level,
                overtime = not run.completed
            })
        end

        -- 对 dunRuns.TOTAL 按 dunID 升序排序
        table.sort(dunRuns.TOTAL, function(a, b)
            return a.dunID < b.dunID  -- 升序排序
        end)
        return dunRuns
    end

    -- 将框架赋值给 mppe.WeeklyReportFrame 以供外部函数使用
    mppe.WeeklyReportFrame = mppeFrame

    -- 可以在这里触发一次初始刷新（如果需要）
    -- mppe.RefreshWeeklyReport()
end)