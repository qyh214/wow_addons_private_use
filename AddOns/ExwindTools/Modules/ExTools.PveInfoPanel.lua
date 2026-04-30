-- =============================================================
-- [[ PVE 信息扩展面板 ]]
-- { Key = "ExTools.PveInfoPanel", Name = "PVE 扩展面板", Desc = "在副本查找器 (PVEFrame) 侧边显示额外信息挂架。", Category = 4 },
-- =============================================================

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExTools.PveInfoPanel"

-- =============================================================
-- 第一部分：Grid 布局定义
-- =============================================================
local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 1, y = 1, w = 47, h = 2, label = L["本周大秘境信息"] },
        { key = "desc", type = "description", x = 1, y = 3, w = 47, h = 1, label = L["自动依附在 PVE 面板侧边的信息架。"] },
        { key = "enabled", type = "checkbox", x = 1, y = 5, w = 12, h = 2, label = L["启用模块"] },
        { key = "side", type = "select", x = 15, y = 5, w = 12, h = 2, label = L["依附侧"], options = { ["LEFT"] = L["左侧"], ["RIGHT"] = L["右侧"] } },
        { key = "offsetX", type = "slider", x = 1, y = 10, w = 15, h = 2, label = L["水平偏移 (X)"], min = -100, max = 100, step = 1 },
        { key = "offsetY", type = "slider", x = 18, y = 10, w = 15, h = 2, label = L["垂直偏移 (Y)"], min = -500, max = 500, step = 5 },
    }
    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, { enabled = true, side = "RIGHT", offsetX = 2, offsetY = 0 })
local mainFrame
local FIXED_WIDTH = 260
local raiderIOHooked

-- =============================================================
-- 第二部分：辅助组件 (勋章化 UI 部件)
-- =============================================================

local function CreateSectionTitle(parent, text, yOfs)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(FIXED_WIDTH - 15, 14)
    container:SetPoint("TOP", parent, "TOP", 0, yOfs)
    local label = container:CreateFontString(nil, "OVERLAY")
    label:SetFont(ExwindTools.MAIN_FONT, 15, "OUTLINE")
    label:SetText(text)
    label:SetTextColor(1, 0.8, 0, 0.95)
    label:SetPoint("CENTER", 0, 0)
    local leftLine = container:CreateTexture(nil, "ARTWORK")
    leftLine:SetHeight(1)
    leftLine:SetPoint("LEFT", 0, 0)
    leftLine:SetPoint("RIGHT", label, "LEFT", -8, 0)
    leftLine:SetColorTexture(1, 0.8, 0, 0.2)
    local rightLine = container:CreateTexture(nil, "ARTWORK")
    rightLine:SetHeight(1)
    rightLine:SetPoint("RIGHT", 0, 0)
    rightLine:SetPoint("LEFT", label, "RIGHT", 8, 0)
    rightLine:SetColorTexture(1, 0.8, 0, 0.2)
    return container
end

local function CreateHeaderIcon(parent, texture, xOfs, labelText, clickFunc)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(50, 50)
    btn:SetPoint("CENTER", parent, "TOP", xOfs, -47)

    -- 阻止 ElvUI 全局扫描给此按钮套皮肤
    btn.IsSkinned = true
    btn.noBackdrop = true

    local icon = btn:CreateTexture(nil, "OVERLAY")
    icon:SetAllPoints()
    icon:SetTexture("Interface\\AddOns\\ExwindCore\\Textures\\" .. texture)
    icon:SetVertexColor(0.85, 0.85, 0.85)
    btn.icon = icon
    local label = btn:CreateFontString(nil, "OVERLAY")
    label:SetFont(ExwindTools.MAIN_FONT, 15, "OUTLINE")
    label:SetPoint("BOTTOM", icon, "BOTTOM", 0, 1)
    label:SetText(labelText)
    label:SetTextColor(1, 0.8, 0)
    btn:SetScript("OnEnter", function(self)
        self.icon:SetVertexColor(1, 1, 1)
        self:SetScale(1.05)
    end)
    btn:SetScript("OnLeave", function(self)
        self.icon:SetVertexColor(0.85, 0.85, 0.85)
        self:SetScale(1.0)
    end)
    btn:SetScript("OnClick", clickFunc)
    return btn
end

-- =============================================================
-- 第三部分：核心功能 (数据处理)
-- =============================================================

local function GetBaseAnchorFrame()
    local anchorFrame = _G.PVEFrame

    -- 探测 ElvUI_WindTools
    local wt = _G.WindTools and _G.WindTools[1]
    if wt and wt.GetModule then
        local ll = wt:GetModule("LFGList", true)
        if ll and ll.RightPanel and ll.RightPanel:IsShown() then
            return ll.RightPanel
        end
    end

    -- 兜底兼容逻辑 (如果用户使用了其他名为 WindUI 的插件)
    if _G.WindUI_PveFrame and _G.WindUI_PveFrame:IsShown() then
        return _G.WindUI_PveFrame
    end
    if _G.WindUI_MainFrame and _G.WindUI_MainFrame:IsShown() then
        return _G.WindUI_MainFrame
    end

    return anchorFrame
end

local function GetRaiderIOAnchorFrame()
    local profileTooltip = _G.RaiderIO_ProfileTooltip
    if profileTooltip and profileTooltip:IsShown() then
        return profileTooltip
    end

    local profileAnchor = _G.RaiderIO_ProfileTooltipAnchor
    if profileAnchor and profileAnchor:IsShown() and profileAnchor:GetParent() and profileAnchor:GetParent():IsShown() then
        return profileAnchor
    end
end

local function UpdatePosition()
    if not mainFrame or not mainFrame:IsShown() then return end

    local offX = EX_DB.offsetX or 2
    local offY = EX_DB.offsetY or 0
    local anchorFrame = GetBaseAnchorFrame()
    local raiderIOAnchor = GetRaiderIOAnchorFrame()

    if raiderIOAnchor then
        local anchorRight = anchorFrame and anchorFrame.GetRight and anchorFrame:GetRight()
        local raiderIORight = raiderIOAnchor.GetRight and raiderIOAnchor:GetRight()
        if anchorRight and raiderIORight and raiderIORight > anchorRight then
            offX = offX + (raiderIORight - anchorRight)
        end
    end

    mainFrame:ClearAllPoints()
    mainFrame:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", offX, offY)
    mainFrame:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT", offX, offY)
    mainFrame:SetWidth(FIXED_WIDTH)
end

-- [联动 Hook] 确保当 Wind工具箱刷新它的面板时，我们也同步刷新位置
local function HookWindUI()
    local wt = _G.WindTools and _G.WindTools[1]
    if wt and wt.GetModule then
        local ll = wt:GetModule("LFGList", true)
        if ll and ll.UpdateRightPanel then
            _G.hooksecurefunc(ll, "UpdateRightPanel", function()
                _G.C_Timer.After(0.05, UpdatePosition)
            end)
        end
    end
end

local function HookRaiderIO()
    if raiderIOHooked then return end

    local hookedAny = false
    local function HookFrame(frame)
        if not frame or frame.EX_PveInfoPanelHooked then
            return
        end
        frame.EX_PveInfoPanelHooked = true
        frame:HookScript("OnShow", function()
            _G.C_Timer.After(0.02, UpdatePosition)
        end)
        frame:HookScript("OnHide", function()
            _G.C_Timer.After(0.02, UpdatePosition)
        end)
        hookedAny = true
    end

    HookFrame(_G.RaiderIO_ProfileTooltip)
    HookFrame(_G.RaiderIO_ProfileTooltipAnchor)

    if hookedAny then
        raiderIOHooked = true
    end
end

local function UpdateStats()
    if not mainFrame or not mainFrame:IsShown() then return end
    local ID_TO_NAME = {
        --12.0 S1
        [239] = L["执政"],
        [556] = L["萨隆"],
        [161] = L["通天"],
        [402] = L["学院"],
        [557] = L["风行"],
        [558] = L["魔导"],
        [560] = L["洞窟"],
        [559] = L["节点"],
        --11.2 S3
        [525] = L["水闸"],
        [499] = L["隐修"],
        [505] = L["破晨"],
        [503] = L["回响"],
        [542] = L["生态"],
        [378] = L["赎罪"],
        [392] = L["宏图"],
        [391] = L["天街"]
    }

    -- 获取本周战绩
    local wRuns = _G.C_MythicPlus.GetRunHistory(false, true, true) or {}
    table.sort(wRuns, function(a, b) return a.level > b.level end)

    local mapTable = _G.C_ChallengeMode.GetMapTable() or {}
    local aggregatedData = {}
    for _, id in ipairs(mapTable) do aggregatedData[id] = { highest = 0, runs = {} } end

    for _, run in ipairs(wRuns) do
        local id = run.mapChallengeModeID
        if aggregatedData[id] then
            if run.level > aggregatedData[id].highest then aggregatedData[id].highest = run.level end
            table.insert(aggregatedData[id].runs, { level = run.level, timed = run.completed })
        end
    end



    -- 2. 上半部
    local upper = ""
    for i = 1, 8 do
        local run = wRuns[i]
        if run then
            local name, _, _, icon = _G.C_ChallengeMode.GetMapUIInfo(run.mapChallengeModeID)
            local hex = "ffffffff"
            local mix = _G.C_ChallengeMode.GetKeystoneLevelRarityColor(run.level)
            if mix then hex = mix:GenerateHexColor() or "ffffffff" end

            upper = upper .. string.format("%s |cffffffff+%d|r |c%s%s|r\n",
                _G.CreateSimpleTextureMarkup(icon or 136116, 14, 14), run.level, hex, name or "??")
        else
            upper = upper .. "|cff444444-|r\n"
        end
    end
    mainFrame.upperDisplay:SetText(upper:gsub("\n$", ""))

    -- 2. 下半部
    local lower = ""
    for _, id in ipairs(mapTable) do
        local _, _, _, icon = _G.C_ChallengeMode.GetMapUIInfo(id)
        local data = aggregatedData[id]
        local runsStr = ""
        if data and #data.runs > 0 then
            table.sort(data.runs, function(a, b) return b.level < a.level end)
            for _, r in ipairs(data.runs) do
                runsStr = runsStr .. (r.timed and "|cff00ff00" or "|cffff0000") .. r.level .. "|r "
            end
        else
            runsStr = "|cff888888-|r"
        end
        local iconMarkup = _G.CreateSimpleTextureMarkup(icon or 136116, 14, 14)
        local nameOverlay = string.format("|cffffd100%s|r", ID_TO_NAME[id] or "?")
        lower = lower .. string.format("%s %s (%s)\n", iconMarkup, nameOverlay, runsStr)
    end
    mainFrame.lowerDisplay:SetText(lower:gsub("\n$", ""))
end

-- 集中处理皮肤应用逻辑
local function ApplyElvUISkin(frame)
    if not frame then return false end
    local Skin = ExwindTools.ElvUISkin
    if not Skin or not Skin:IsElvUILoaded() then return false end

    Skin:SkinFrame(frame, "Transparent")
    local E = _G.ElvUI and _G.ElvUI[1]
    local S = E and E:GetModule("Skins", true)
    if S and S.CreateShadowModule then
        _G.pcall(S.CreateShadowModule, S, frame)
    end
    if frame.CloseButton then Skin:SkinCloseButton(frame.CloseButton) end
    return true
end

-- NDui 皮肤应用逻辑
local function ApplyNDuiSkin(frame)
    if not frame then return false end
    local NDuiSkin = ExwindTools.NDuiSkin
    if not NDuiSkin or not NDuiSkin:IsNDuiLoaded() then return false end

    local NDui = _G.NDui
    if not NDui then return false end
    local B = NDui[1] -- NDui 核心函数库
    if not B then return false end

    local ok = pcall(function()
        -- 直接在 frame 上应用 NDui Backdrop（使用 SkinAlpha 透明度）
        B.CreateBD(frame)
        -- 添加阴影
        B.CreateSD(frame, nil, true)
        -- 添加背景纹理
        B.CreateTex(frame)
        -- 美化关闭按钮（必须用 ReskinClose 而非 Reskin，否则 × 图标会丢失）
        if frame.CloseButton then
            B.ReskinClose(frame.CloseButton)
        end
    end)
    return ok
end

local function CreateMainFrame()
    if mainFrame then return end

    local Skin = ExwindTools.ElvUISkin
    local isElv = Skin and Skin:IsElvUILoaded()
    local NDuiSkin = ExwindTools.NDuiSkin
    local isNDui = NDuiSkin and NDuiSkin:IsNDuiLoaded()

    if isElv then
        -- [ElvUI 模式]：创建纯净窗口，完全手动构建组件
        mainFrame = CreateFrame("Frame", "ExPveInfoPanel_Final", UIParent)
        mainFrame:SetSize(FIXED_WIDTH, 540)

        local title = mainFrame:CreateFontString(nil, "OVERLAY")
        title:SetFont(ExwindTools.MAIN_FONT, 16, "OUTLINE")
        title:SetPoint("TOP", 0, -8)
        title:SetTextColor(1, 0.82, 0)
        mainFrame.TitleText = title

        local close = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -2, -2)
        mainFrame.CloseButton = close

        ApplyElvUISkin(mainFrame)
    elseif isNDui then
        -- [NDui 模式]：创建纯净窗口，使用 NDui 风格美化
        mainFrame = CreateFrame("Frame", "ExPveInfoPanel_Final", UIParent, "BackdropTemplate")
        mainFrame:SetSize(FIXED_WIDTH, 540)

        local title = mainFrame:CreateFontString(nil, "OVERLAY")
        title:SetFont(ExwindTools.MAIN_FONT, 16, "OUTLINE")
        title:SetPoint("TOP", 0, -8)
        title:SetTextColor(1, 0.82, 0)
        mainFrame.TitleText = title

        local close = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -2, -2)
        mainFrame.CloseButton = close

        ApplyNDuiSkin(mainFrame)
    else
        -- [暴雪模式]：直接使用原生模板，不进行任何皮肤篡改
        mainFrame = CreateFrame("Frame", "ExPveInfoPanel_Final", UIParent, "DefaultPanelTemplate")
        mainFrame:SetSize(FIXED_WIDTH, 540)
    end

    mainFrame:SetFrameStrata("MEDIUM")
    mainFrame:SetToplevel(true)

    -- 保障标题文字
    if mainFrame.TitleText then mainFrame.TitleText:SetText(L["本周大秘境信息"]) end

    -- 顶部按钮：位置固化，仅对调“统计”与“赛季”
    mainFrame.infoBtn = CreateHeaderIcon(mainFrame, "ExInfo.png", -75, L["法术"],
        function() if SlashCmdList["EXSP"] then SlashCmdList["EXSP"]() end end)
    mainFrame.vaultBtn = CreateHeaderIcon(mainFrame, "ExVault.png", 0, L["大米"],
        function() if SlashCmdList["EXMPLUS"] then SlashCmdList["EXMPLUS"]() end end)
    mainFrame.statBtn = CreateHeaderIcon(mainFrame, "ExTotal.png", 75, L["记录"],
        function() if _G.EXMYRUN then _G.EXMYRUN:ToggleWindow() end end)

    -- 分割线 1 (低保记录)：下移以避开图标
    CreateSectionTitle(mainFrame, L["本周低保记录"], -75)
    local d1 = mainFrame:CreateFontString(nil, "OVERLAY")
    d1:SetFont(ExwindTools.MAIN_FONT, 15, "OUTLINE")
    d1:SetPoint("TOPLEFT", 15, -92)
    d1:SetJustifyH("LEFT")
    d1:SetSpacing(2)
    mainFrame.upperDisplay = d1

    -- 分割线 2 (大米详情)：下浮对应高度
    CreateSectionTitle(mainFrame, L["本周大米详情"], -251)
    local d2 = mainFrame:CreateFontString(nil, "OVERLAY")
    d2:SetFont(ExwindTools.MAIN_FONT, 15, "OUTLINE")
    d2:SetPoint("TOPLEFT", 15, -267)
    d2:SetJustifyH("LEFT")
    d2:SetSpacing(1)
    mainFrame.lowerDisplay = d2

    mainFrame:Hide()
    -- 判断面板是否应该显示
    local function ShouldShow()
        if not EX_DB.enabled then return false end
        if not _G.PVEFrame or not _G.PVEFrame:IsShown() then return false end

        -- 1: GroupFinder (LFG), 2: PVP, 3: Challenges (PVE/Mythic+)
        -- 根据用户要求，仅在切到 PVE (大秘境/挑战) 分页时显示
        local activeTab = _G.PanelTemplates_GetSelectedTab(_G.PVEFrame)
        if activeTab == 3 then
            return true
        end
        return false
    end

    local function UpdateVisibility()
        if not mainFrame then return end
        if ShouldShow() then
            mainFrame:Show()
            UpdatePosition()
            UpdateStats()
        else
            mainFrame:Hide()
        end
    end

    local function HookPVE()
        if not _G.PVEFrame then return end
        if _G.EXMRH_LaunchButton then _G.EXMRH_LaunchButton:Hide() end
        if _G.EXMRH_SpellInfoButton then _G.EXMRH_SpellInfoButton:Hide() end

        -- 挂钩显示与隐藏脚本
        _G.PVEFrame:HookScript("OnShow", function()
            _G.C_Timer.After(0.1, UpdateVisibility)
        end)
        _G.PVEFrame:HookScript("OnHide", function()
            if mainFrame then mainFrame:Hide() end
        end)

        -- 关键：挂钩暴雪分页切换函数
        if _G.PVEFrame_ShowFrame then
            _G.hooksecurefunc("PVEFrame_ShowFrame", UpdateVisibility)
        end

        -- 初始检测
        UpdateVisibility()
    end
    if _G.PVEFrame then
        HookPVE()
        HookWindUI()
        HookRaiderIO()
        ExwindTools:RegisterEvent("ADDON_LOADED", EXWIND_MODULE_KEY .. ".RaiderIO",
            function(_, n)
                if n == "RaiderIO" then
                    _G.C_Timer.After(0.2, function()
                        HookRaiderIO()
                        UpdatePosition()
                    end)
                end
            end)
    else
        ExwindTools:RegisterEvent("ADDON_LOADED", EXWIND_MODULE_KEY,
            function(_, n)
                if n == "Blizzard_GroupFinder" then
                    HookPVE()
                    HookWindUI()
                    HookRaiderIO()
                elseif n == "RaiderIO" then
                    _G.C_Timer.After(0.2, function()
                        HookRaiderIO()
                        UpdatePosition()
                    end)
                end
            end)
    end
end

local function RefreshPanelDisplay()
    if mainFrame and mainFrame:IsShown() then
        UpdateStats()
    end
end

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function()
    if not EX_DB.enabled then
        if mainFrame then mainFrame:Hide() end
        return
    end
    if not mainFrame then CreateMainFrame() end
    RefreshPanelDisplay()
end)

ExwindTools:RegisterEvent("ITEM_CHANGED", EXWIND_MODULE_KEY, RefreshPanelDisplay)
ExwindTools:RegisterEvent("BAG_UPDATE_DELAYED", EXWIND_MODULE_KEY, RefreshPanelDisplay)
ExwindTools:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE", EXWIND_MODULE_KEY, RefreshPanelDisplay)
ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY, function()
    _G.C_Timer.After(0.3, function()
        if mainFrame then
            RefreshPanelDisplay()
        end
    end)
end)

C_Timer.After(1, function() if EX_DB.enabled then CreateMainFrame() end end)
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
