-- =============================================================
-- ExwindTools ElvUI 皮肤集成
-- 当检测到 ElvUI 时，自动为所有框架应用 ElvUI 样式
--
-- 核心原理：
--   ElvUI 通过 Toolkit.lua 将 SetTemplate/CreateBackdrop 等方法
--   注入到所有 Frame 类型的 metatable.__index 中，因此任何 frame
--   对象都可以直接调用 frame:SetTemplate("Transparent") 等方法。
--   Skins Handle 函数（HandleButton等）则挂在 E.Skins 模块上。
--
-- [v5.1.0] 2026-02-17 基于 ElvUI 源码审计重写
--   审计依据: ElvUI/Game/Shared/General/Toolkit.lua (SetTemplate 定义)
--             ElvUI/Game/Shared/Modules/Skins/Skins.lua (Handle* 定义)
-- =============================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end

local ElvUISkin = {}
ExwindTools.ElvUISkin = ElvUISkin

-- =============================================
-- ElvUI 引擎引用（延迟初始化）
-- =============================================
local E                  -- ElvUI 引擎对象
local S                  -- ElvUI Skins 模块
local elvuiReady = false -- ElvUI 是否完全初始化

-- 初始化 ElvUI 引用
-- ⚠️ 必须在 ElvUI 完成初始化后再调用
local function InitElvUI()
    if elvuiReady then return true end

    local elvui = _G.ElvUI
    if not elvui then return false end

    E = elvui[1]
    if not E then return false end

    -- 检查 ElvUI 是否已完成初始化（E.initialized 在 Core.lua 中设置）
    if not E.initialized then return false end

    -- 获取 Skins 模块引用
    S = E:GetModule("Skins", true) -- true = 静默模式，不报错

    elvuiReady = true
    return true
end

-- =============================================
-- 核心皮肤方法
-- =============================================

--- 为框架应用 ElvUI SetTemplate 样式
-- ElvUI 的 SetTemplate 是帧方法（注入到 metatable），不是 E 的方法
-- 签名：frame:SetTemplate(template, glossTex, ignoreUpdates, forcePixelMode, ...)
-- @param frame Frame 目标框架
-- @param template string|nil 模板类型："Default"/"Transparent"/"ClassColor"/"NoBackdrop"(默认"Transparent")
-- @param glossTex boolean|nil 是否使用光泽纹理
function ElvUISkin:ApplyBackdrop(frame, template, glossTex)
    if not frame then return false end
    if not InitElvUI() then return false end

    template = template or "Transparent"

    -- ✅ 正确调用：frame:SetTemplate() 是帧方法
    if frame.SetTemplate then
        frame:SetTemplate(template, glossTex)
        return true
    end

    return false
end

--- 为框架创建 ElvUI 风格的 Backdrop（边框+阴影）
-- 比 SetTemplate 更进一步，创建内嵌的背景层
-- @param frame Frame 目标框架
-- @param template string|nil 模板类型
-- @param glossTex boolean|nil 是否使用光泽纹理
function ElvUISkin:CreateBackdrop(frame, template, glossTex)
    if not frame then return false end
    if not InitElvUI() then return false end

    template = template or "Transparent"

    if frame.CreateBackdrop then
        frame:CreateBackdrop(template, glossTex)
        return true
    end

    return false
end

--- 应用 ElvUI 边框颜色
-- @param frame Frame 目标框架
-- @param r number|nil 红色分量(0-1)，不填则使用 ElvUI 默认边框色
-- @param g number|nil 绿色分量
-- @param b number|nil 蓝色分量
-- @param a number|nil 透明度
function ElvUISkin:ApplyBorder(frame, r, g, b, a)
    if not frame then return false end
    if not InitElvUI() then return false end

    if frame.SetBackdropBorderColor then
        local bc = E.media.bordercolor
        frame:SetBackdropBorderColor(
            r or (bc and bc[1]) or 0.1,
            g or (bc and bc[2]) or 0.1,
            b or (bc and bc[3]) or 0.1,
            a or 1
        )
        return true
    end

    return false
end

--- 创建带 ElvUI 样式的框架（封装 CreateFrame + SetTemplate）
-- @param frameType string 框架类型（"Frame", "Button" 等）
-- @param name string|nil 框架名称
-- @param parent Frame|nil 父框架
-- @param inherits string|nil 继承模板
-- @param elvuiTemplate string|nil ElvUI 模板类型
function ElvUISkin:CreateFrame(frameType, name, parent, inherits, elvuiTemplate)
    local frame = CreateFrame(frameType, name, parent or UIParent, inherits)

    if InitElvUI() then
        -- ✅ 正确调用：frame:SetTemplate() 是帧方法
        if frame.SetTemplate then
            frame:SetTemplate(elvuiTemplate or "Transparent")
        end
    else
        -- 降级：ElvUI 未加载时使用原生背景
        if not frame.SetBackdrop then
            _G.Mixin(frame, _G.BackdropTemplateMixin)
        end
        frame:SetBackdrop({
            bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
            edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
            tile = true,
            tileSize = 16,
            edgeSize = 12,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        frame:SetBackdropColor(0, 0, 0, 0.8)
        frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    end

    return frame
end

--- 为已存在的框架应用 ElvUI 皮肤
-- @param frame Frame 已存在的框架
-- @param elvuiTemplate string|nil ElvUI 模板类型
function ElvUISkin:SkinFrame(frame, elvuiTemplate)
    if not frame then return false end
    if not InitElvUI() then return false end

    if frame.SetTemplate then
        frame:SetTemplate(elvuiTemplate or "Transparent")
        return true
    end

    return false
end

-- =============================================
-- ElvUI Skins Handle 封装
-- =============================================

--- 应用 ElvUI 按钮样式
-- 源码: Skins.lua:996 - S:HandleButton(button, strip, isDecline, noStyle, ...)
function ElvUISkin:SkinButton(button)
    if not button then return false end
    if not InitElvUI() then return false end

    if S and S.HandleButton then
        S:HandleButton(button)
        return true
    end

    return false
end

--- 应用 ElvUI 滑块样式
-- 源码: Skins.lua:1806 - S:HandleSliderFrame(frame, template, frameLevel)
function ElvUISkin:SkinSlider(slider)
    if not slider then return false end
    if not InitElvUI() then return false end

    if S and S.HandleSliderFrame then
        S:HandleSliderFrame(slider)
        return true
    end

    return false
end

--- 应用 ElvUI 编辑框样式
-- 源码: Skins.lua:1405 - S:HandleEditBox(frame, template)
function ElvUISkin:SkinEditBox(editbox)
    if not editbox then return false end
    if not InitElvUI() then return false end

    if S and S.HandleEditBox then
        S:HandleEditBox(editbox)
        return true
    end

    return false
end

--- 应用 ElvUI 复选框样式
-- 源码: Skins.lua:1533 - S:HandleCheckBox(frame, noBackdrop, noReplaceTextures, ...)
function ElvUISkin:SkinCheckBox(checkbox)
    if not checkbox then return false end
    if not InitElvUI() then return false end

    if S and S.HandleCheckBox then
        S:HandleCheckBox(checkbox)
        return true
    end

    return false
end

--- 应用 ElvUI 关闭按钮样式
-- 源码: Skins.lua:1705 - S:HandleCloseButton(f, point, x, y)
function ElvUISkin:SkinCloseButton(button)
    if not button then return false end
    if not InitElvUI() then return false end

    if S and S.HandleCloseButton then
        S:HandleCloseButton(button)
        return true
    end

    return false
end

--- 应用 ElvUI 状态栏样式
-- 源码: Skins.lua:1496 - S:HandleStatusBar(frame, color, template)
function ElvUISkin:SkinStatusBar(statusbar, color)
    if not statusbar then return false end
    if not InitElvUI() then return false end

    if S and S.HandleStatusBar then
        S:HandleStatusBar(statusbar, color)
        return true
    end

    return false
end

--- 应用 ElvUI Tab 标签样式
-- 源码: Skins.lua:1259 - S:HandleTab(tab, noBackdrop, template)
function ElvUISkin:SkinTab(tab)
    if not tab then return false end
    if not InitElvUI() then return false end

    if S and S.HandleTab then
        S:HandleTab(tab)
        return true
    end

    return false
end

--- 应用 ElvUI 滚动条样式
-- 源码: Skins.lua:1102 - S:HandleScrollBar(frame, thumbY, thumbX, template)
function ElvUISkin:SkinScrollBar(scrollbar)
    if not scrollbar then return false end
    if not InitElvUI() then return false end

    if S and S.HandleScrollBar then
        S:HandleScrollBar(scrollbar)
        return true
    end

    return false
end

--- 应用 ElvUI 精简滚动条样式
-- 源码: Skins.lua:1212 - S:HandleTrimScrollBar(frame, ignoreUpdates)
-- 适用于 MinimalScrollBar / WowTrimScrollBar 等现代滚动条
function ElvUISkin:SkinTrimScrollBar(scrollbar, ignoreUpdates)
    if not scrollbar then return false end
    if not InitElvUI() then return false end

    if S and S.HandleTrimScrollBar then
        S:HandleTrimScrollBar(scrollbar, ignoreUpdates)
        return true
    end

    return false
end

-- =============================================
-- 媒体资源获取
-- =============================================

--- 获取 ElvUI 媒体资源，降级时返回默认值
-- ⚠️ E.media (小写) = 运行时动态值
--    E.Media (大写) = 静态资源路径表
function ElvUISkin:GetMedia()
    if not InitElvUI() then
        return {
            normFont = "Fonts\\FRIZQT__.TTF",
            blankTex = [[Interface\Buttons\WHITE8X8]],
            bordercolor = { 0.1, 0.1, 0.1 },
            backdropcolor = { 0.05, 0.05, 0.05 },
        }
    end

    return {
        normFont = E.media.normFont or "Fonts\\FRIZQT__.TTF",
        blankTex = E.media.blankTex or [[Interface\Buttons\WHITE8X8]],
        bordercolor = E.media.bordercolor or { 0.1, 0.1, 0.1 },
        backdropcolor = E.media.backdropcolor or { 0.05, 0.05, 0.05 },
        backdropfadecolor = E.media.backdropfadecolor or { 0.05, 0.05, 0.05, 0.85 },
        normTex = E.media.normTex,
        glossTex = E.media.glossTex,
        borderwidth = E.Border or 1,
        spacing = E.Spacing or 1,
    }
end

--- 检查 ElvUI 是否已加载并完成初始化
function ElvUISkin:IsElvUILoaded()
    return InitElvUI()
end

--- 获取 ElvUI 配色方案
function ElvUISkin:GetColors()
    if not InitElvUI() then
        return {
            class = { r = 0.3, g = 0.3, b = 0.3 },
            border = { r = 0.1, g = 0.1, b = 0.1 },
            backdrop = { r = 0.05, g = 0.05, b = 0.05 },
        }
    end

    local classColor = E:ClassColor(E.myclass, true)

    return {
        class = classColor or { r = 0.3, g = 0.3, b = 0.3 },
        border = E.media.bordercolor or { r = 0.1, g = 0.1, b = 0.1 },
        backdrop = E.media.backdropcolor or { r = 0.05, g = 0.05, b = 0.05 },
    }
end

-- =============================================
-- 初始化：等待 ElvUI 完全就绪后 Hook 面板
-- =============================================
-- 使用 PLAYER_ENTERING_WORLD 而非 PLAYER_LOGIN
-- 因为 ElvUI 在 PLAYER_LOGIN 期间才执行 Initialize()
-- PLAYER_ENTERING_WORLD 触发更晚，此时 ElvUI 必定已完成初始化

-- =============================================
-- [核心] 主动 Hook ExwindTools 设置面板
-- =============================================
-- 仅定义工具函数是不够的，必须主动 Hook 面板创建流程，
-- 在 UI 组件创建后自动调用 SetTemplate / Handle* 方法。

local skinApplied = false -- 防止重复 skin 主面板
local exBossModernScrollHooked = false

local function HideExBossModernScrollFallback(scrollbar)
    if not scrollbar then return end

    local track = scrollbar.Track or (scrollbar.GetTrack and scrollbar:GetTrack()) or nil
    if track then
        if track._exFallbackLine then track._exFallbackLine:Hide() end
        if track._exFallbackGlow then track._exFallbackGlow:Hide() end
    end

    local thumb = (track and track.Thumb) or (scrollbar.GetThumb and scrollbar:GetThumb()) or nil
    if thumb and thumb._exFallbackBody then
        thumb._exFallbackBody:Hide()
    end
end

local function SkinModernTrimScrollBar(scrollbar)
    if not scrollbar or not InitElvUI() or not S or not S.HandleTrimScrollBar then
        return false
    end

    local hasTrimParts = (scrollbar.Back or scrollbar.Forward or scrollbar.Track)
        and (scrollbar.GetThumb or (scrollbar.Track and scrollbar.Track.Thumb))
    if not hasTrimParts then
        return false
    end

    pcall(function()
        S:HandleTrimScrollBar(scrollbar)
        HideExBossModernScrollFallback(scrollbar)
        scrollbar._elvuiTrimSkinned = true
    end)
    return true
end

local function ScanAndSkinModernScrollBars(frame, visited)
    if not frame then return end
    visited = visited or {}
    if visited[frame] then return end
    visited[frame] = true

    if frame._exModernScrollBar then
        SkinModernTrimScrollBar(frame._exModernScrollBar)
    end

    if frame.Track and (frame.GetThumb or frame.Track.Thumb) and (frame.Back or frame.Forward) then
        SkinModernTrimScrollBar(frame)
    end

    for _, child in ipairs({ frame:GetChildren() }) do
        ScanAndSkinModernScrollBars(child, visited)
    end
end

local function HookExBossModernScrollBars()
    if exBossModernScrollHooked or not InitElvUI() then
        return
    end

    local exBoss = _G.ExBoss
    local ui = exBoss and exBoss.UI
    local panel = ui and ui.Panel
    if not ui or type(ui.ApplyModernScrollBarSkin) ~= "function" then
        return
    end

    hooksecurefunc(ui, "ApplyModernScrollBarSkin", function(scrollFrame)
        if scrollFrame and scrollFrame._exModernScrollBar then
            SkinModernTrimScrollBar(scrollFrame._exModernScrollBar)
        end
    end)

    if panel then
        if type(panel.Toggle) == "function" then
            hooksecurefunc(panel, "Toggle", function()
                C_Timer.After(0.05, function()
                    if panel._frame and panel._frame:IsShown() then
                        ScanAndSkinModernScrollBars(panel._frame)
                    end
                end)
            end)
        end

        if type(panel.Show) == "function" then
            hooksecurefunc(panel, "Show", function()
                C_Timer.After(0.05, function()
                    if panel._frame and panel._frame:IsShown() then
                        ScanAndSkinModernScrollBars(panel._frame)
                    end
                end)
            end)
        end

        if type(panel.SetTab) == "function" then
            hooksecurefunc(panel, "SetTab", function()
                C_Timer.After(0.05, function()
                    if panel._frame and panel._frame:IsShown() then
                        ScanAndSkinModernScrollBars(panel._frame)
                    end
                end)
            end)
        end
    end

    exBossModernScrollHooked = true

    if panel and panel._frame and panel._frame:IsShown() then
        ScanAndSkinModernScrollBars(panel._frame)
    end
end

--- 对主设置面板框架应用 ElvUI 皮肤
local function SkinMainPanel()
    if skinApplied then return end

    local EXUI = ExwindTools.UI
    if not EXUI or not EXUI.MainFrame then return end
    if not InitElvUI() then return end

    local f = EXUI.MainFrame
    skinApplied = true

    -- 1. 主窗口：使用 ElvUI 透明模板替换手动 Backdrop
    if f.SetTemplate then
        f:SetTemplate("Transparent")
        f:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    end

    -- 2. 关闭按钮（UIPanelCloseButton 子帧）
    if S and S.HandleCloseButton then
        if f.CloseButton then
            -- [Fix] 直接使用存储的引用，避免在 WoW 12.x 中
            -- UIPanelCloseButton atlas 纹理导致纹理名匹配失败
            pcall(function() S:HandleCloseButton(f.CloseButton) end)
        else
            -- 兜底：遍历子帧查找（兼容旧版本）
            for _, child in ipairs({ f:GetChildren() }) do
                if child:GetObjectType() == "Button" and child:IsObjectType("Button") then
                    local regions = { child:GetRegions() }
                    for _, region in ipairs(regions) do
                        if region:GetObjectType() == "Texture" then
                            local tex = region:GetTexture()
                            if tex and type(tex) == "string" and tex:find("CloseButton") then
                                S:HandleCloseButton(child)
                                break
                            end
                        end
                    end
                    if not child.IsSkinned and child:GetWidth() == 32 and child:GetHeight() == 32 then
                        pcall(function() S:HandleCloseButton(child) end)
                    end
                end
            end
        end
    end

    -- 3. 滚动条皮肤
    if S and S.HandleScrollBar then
        local scrollbars = {
            _G["ExwindSidebarScrollScrollBar"],
            _G["ExwindCommonScrollScrollBar"],
            _G["ExwindModuleGridScrollScrollBar"],
        }
        for _, sb in ipairs(scrollbars) do
            if sb and not sb.backdrop then
                pcall(function() S:HandleScrollBar(sb) end)
            end
        end
    end

    -- 4. 侧边栏面板 & 右侧面板框架
    if EXUI.SidebarFrame then
        local sidebar = EXUI.SidebarFrame:GetParent()
        if sidebar and sidebar.SetTemplate and not sidebar._elvuiSkinned then
            sidebar._elvuiSkinned = true
        end
    end
    if EXUI.RightPanel and EXUI.RightPanel.SetTemplate and not EXUI.RightPanel._elvuiSkinned then
        EXUI.RightPanel:SetTemplate("Transparent")
        EXUI.RightPanel:SetBackdropColor(0.05, 0.05, 0.05, 0.5)
        EXUI.RightPanel._elvuiSkinned = true
    end
end

--- 延迟 Skin 滚动条（模块设置页的滚动条可能晚于主面板创建）
local function SkinScrollBarsDeferred()
    if not InitElvUI() or not S or not S.HandleScrollBar then return end
    local scrollbars = {
        _G["ExwindSidebarScrollScrollBar"],
        _G["ExwindCommonScrollScrollBar"],
        _G["ExwindModuleGridScrollScrollBar"],
    }
    for _, sb in ipairs(scrollbars) do
        if sb and not sb.backdrop then
            pcall(function() S:HandleScrollBar(sb) end)
        end
    end
end

--- Hook EXUI 的工厂方法，在创建组件后自动套皮肤。
-- 对自有函数使用 Wrapper 模式（非 hooksecurefunc），因为需要获取返回值。
local function HookEXUI()
    local EXUI = ExwindTools.UI
    if not EXUI then return end

    -- -------------------------------------------------------
    -- Hook CreateActionButton：紫色大按钮 → ElvUI Default 模板
    -- -------------------------------------------------------
    if EXUI.CreateActionButton then
        local origCreateActionButton = EXUI.CreateActionButton
        EXUI.CreateActionButton = function(self, parent, text, onClick)
            local btn = origCreateActionButton(self, parent, text, onClick)
            if btn and InitElvUI() and btn.SetTemplate then
                btn:SetTemplate("Default", true)
                btn:SetBackdropColor(0.64, 0.19, 0.79, 0.6)
                btn:HookScript("OnEnter", function(b)
                    b:SetBackdropColor(0.74, 0.29, 0.89, 0.8)
                end)
                btn:HookScript("OnLeave", function(b)
                    b:SetBackdropColor(0.64, 0.19, 0.79, 0.6)
                end)
            end
            return btn
        end
    end

    -- -------------------------------------------------------
    -- Hook CreateSmallButton：底部小按钮 → ElvUI Default 模板
    -- -------------------------------------------------------
    if EXUI.CreateSmallButton then
        local origCreateSmallButton = EXUI.CreateSmallButton
        EXUI.CreateSmallButton = function(self, parent, text, onClick)
            local btn = origCreateSmallButton(self, parent, text, onClick)
            if btn and InitElvUI() and btn.SetTemplate then
                btn:SetTemplate("Default")
            end
            return btn
        end
    end

    -- -------------------------------------------------------
    -- [NEW] Hook CreateSlider：内容区滑动条 → ElvUI StepSlider 皮肤
    -- MinimalSliderWithSteppersTemplate 使用 S:HandleStepSlider()
    -- 审计依据: Skins.lua:1843 HandleStepSlider / SettingsPanel.lua
    --
    -- [v5.1.3 Fix] HandleStepSlider 的设计基于暴雪原生 250x40 尺寸，
    --   但 ExwindTools 的 GridSlider 池高度仅 20px，导致：
    --   1) backdrop (TOPLEFT(10,-10)/BOTTOMRIGHT(-10,10)) 高度 = 0px → 轨道不可见
    --   2) Thumb (20x30) 超出 20px 框架 → 视觉比例严重失调
    --   修复：调用 HandleStepSlider 后，强制修正 backdrop 为 10px 居中，
    --   并缩小 Thumb 尺寸使其匹配较小的滑块高度。
    -- -------------------------------------------------------
    if EXUI.CreateSlider then
        local origCreateSlider = EXUI.CreateSlider
        EXUI.CreateSlider = function(self, parent, width, label, minVal, maxVal, curVal, step, formatter, onValueChanged)
            local slider = origCreateSlider(self, parent, width, label, minVal, maxVal, curVal, step, formatter, onValueChanged)
            if slider and InitElvUI() and not slider._elvuiSkinned then
                slider._elvuiSkinned = true
                pcall(function()
                    if S and S.HandleStepSlider then
                        S:HandleStepSlider(slider, true)

                        local innerSlider = slider.Slider
                        if innerSlider then
                            -- Fix 1: 强制滑槽 backdrop 高度为 10px，居中对齐
                            -- 暴雪原生 40px 框架 → backdrop 20px，ExwindTools 20px → 0px
                            if innerSlider.backdrop then
                                innerSlider.backdrop:ClearAllPoints()
                                innerSlider.backdrop:SetHeight(10)
                                innerSlider.backdrop:SetPoint("LEFT", innerSlider, "LEFT", 10, 0)
                                innerSlider.backdrop:SetPoint("RIGHT", innerSlider, "RIGHT", -10, 0)
                            end

                            -- Fix 2: 缩小 Thumb 尺寸，匹配 20px 高度的滑块
                            -- 暴雪原生 Thumb = 20x30 适配 40px 框架
                            -- ExwindTools 按比例缩小为 12x18 适配 20px 框架
                            local thumb = innerSlider.Thumb
                            if thumb then
                                thumb:SetSize(12, 18)
                            end

                            -- Fix 3: barStep 进度条也需要匹配新的 backdrop 尺寸
                            if innerSlider.barStep and innerSlider.backdrop then
                                innerSlider.barStep:ClearAllPoints()
                                innerSlider.barStep:SetPoint("TOPLEFT", innerSlider.backdrop, E.mult, -E.mult)
                                innerSlider.barStep:SetPoint("BOTTOMLEFT", innerSlider.backdrop, E.mult, E.mult)
                                if thumb then
                                    innerSlider.barStep:SetPoint("RIGHT", thumb, "CENTER")
                                end
                            end
                        end
                    elseif S and S.HandleSliderFrame and slider.Slider then
                        S:HandleSliderFrame(slider.Slider)
                    end
                end)
            end
            return slider
        end
    end

    -- -------------------------------------------------------
    -- [NEW] Hook 所有下拉菜单工厂：WowStyle1DropdownTemplate → ElvUI 皮肤
    -- 不使用 HandleButton(strip=true)，因为 StripTextures 会销毁 Arrow 纹理
    -- 改为手动 SetTemplate + 创建 ElvUI 风格箭头
    -- 审计依据: Skins.lua:1438 HandleDropDownBox / SettingsPanel.lua:35
    -- -------------------------------------------------------
    local dropdownFactories = {
        "CreateDropdown",
        "CreateLSMDropdown",
        "CreateLSMTextureDropdown",
        "CreateLSMSoundDropdown",
        "CreateMultiSelectDropdown",
    }
    for _, funcName in ipairs(dropdownFactories) do
        if EXUI[funcName] then
            local origFunc = EXUI[funcName]
            EXUI[funcName] = function(self, ...)
                local dropdown = origFunc(self, ...)
                if dropdown and InitElvUI() and not dropdown._elvuiSkinned then
                    dropdown._elvuiSkinned = true
                    pcall(function()
                        -- 1. 隐藏暴雪原生背景纹理（但保留 Arrow 和 Text）
                        if dropdown.NormalTexture then dropdown.NormalTexture:SetAlpha(0) end
                        if dropdown.HighlightTexture then dropdown.HighlightTexture:SetAlpha(0) end
                        if dropdown.PushedTexture then dropdown.PushedTexture:SetAlpha(0) end
                        -- StripTextures 的精简版：只隐藏背景类纹理
                        for _, region in ipairs({ dropdown:GetRegions() }) do
                            if region:IsObjectType("Texture") then
                                local name = region:GetDebugName() or ""
                                -- 保留 Arrow + Text 相关纹理
                                if region ~= dropdown.Arrow and not name:find("Arrow") then
                                    local drawLayer = region:GetDrawLayer()
                                    if drawLayer == "BACKGROUND" or drawLayer == "BORDER" then
                                        region:SetAlpha(0)
                                    end
                                end
                            end
                        end

                        -- 2. 应用 ElvUI 模板背景
                        dropdown:SetTemplate("Default")

                        -- 3. 隐藏原始箭头，创建 ElvUI 风格箭头（朝下三角）
                        if dropdown.Arrow then
                            dropdown.Arrow:SetAlpha(0)
                        end

                        if not dropdown._elvuiArrow then
                            local arrow = dropdown:CreateTexture(nil, "ARTWORK")
                            arrow:SetTexture(E.Media.Textures.ArrowUp)
                            arrow:SetRotation(3.14159)  -- 180° = 朝下
                            arrow:SetSize(14, 14)
                            arrow:SetPoint("RIGHT", dropdown, "RIGHT", -3, 0)
                            arrow:SetVertexColor(1, 0.82, 0, 0.8)  -- ElvUI 金色
                            dropdown._elvuiArrow = arrow
                        end

                        -- 4. 悬停/离开效果
                        dropdown:HookScript("OnEnter", function(self)
                            if self._elvuiArrow then
                                self._elvuiArrow:SetVertexColor(1, 1, 1, 1)
                            end
                        end)
                        dropdown:HookScript("OnLeave", function(self)
                            if self._elvuiArrow then
                                self._elvuiArrow:SetVertexColor(1, 0.82, 0, 0.8)
                            end
                        end)
                    end)
                end
                return dropdown
            end
        end
    end

    -- -------------------------------------------------------
    -- [NEW] Hook CreateButton：内容区通用按钮 → ElvUI 按钮皮肤
    -- SharedButtonLargeTemplate 使用 S:HandleButton(btn, strip)
    -- 审计依据: Skins.lua:996 HandleButton
    -- -------------------------------------------------------
    if EXUI.CreateButton then
        local origCreateButton = EXUI.CreateButton
        EXUI.CreateButton = function(self, parent, width, height, text, onClick)
            local btn = origCreateButton(self, parent, width, height, text, onClick)
            if btn and InitElvUI() and not btn.IsSkinned then
                if S and S.HandleButton then
                    pcall(function() S:HandleButton(btn, true) end)
                end
            end
            return btn
        end
    end

    -- -------------------------------------------------------
    -- [NEW] Hook CreateCheckbox：勾选框 → ElvUI Checkbox 皮肤
    -- MinimalCheckboxTemplate 使用 S:HandleCheckBox(checkbox)
    -- 审计依据: Skins.lua:1533 HandleCheckBox
    -- -------------------------------------------------------
    if EXUI.CreateCheckbox then
        local origCreateCheckbox = EXUI.CreateCheckbox
        EXUI.CreateCheckbox = function(self, parent, text, initialValue, onClick)
            local container = origCreateCheckbox(self, parent, text, initialValue, onClick)
            if container and container.checkbox and InitElvUI() then
                if not container.checkbox.IsSkinned and S and S.HandleCheckBox then
                    pcall(function() S:HandleCheckBox(container.checkbox) end)
                end
            end
            return container
        end
    end

    -- -------------------------------------------------------
    -- [NEW] Hook CreateEditBox：输入框 → ElvUI 输入框皮肤
    -- 池化路径返回 EditBox 本身，Legacy 路径返回 Frame 容器
    -- 审计依据: Skins.lua:1405 HandleEditBox
    -- -------------------------------------------------------
    if EXUI.CreateEditBox then
        local origCreateEditBox = EXUI.CreateEditBox
        EXUI.CreateEditBox = function(self, parent, text, w, h, labelText, options)
            local container = origCreateEditBox(self, parent, text, w, h, labelText, options)
            if container and InitElvUI() then
                -- 池化路径: container.editBox == container (EditBox 本身)
                -- Legacy 路径: container.editBox 是 ScrollFrame 内的 EditBox
                local editbox = container.editBox or container
                if editbox and not editbox._elvuiSkinned then
                    editbox._elvuiSkinned = true
                    if editbox.SetTemplate then
                        editbox:SetTemplate("Default")
                        editbox:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
                    end
                end
            end
            return container
        end
    end

    -- -------------------------------------------------------
    -- [NEW] Hook CreateColorButton：颜色选择按钮 → ElvUI 模板
    -- 使用 BackdropTemplate，直接 SetTemplate
    -- -------------------------------------------------------
    if EXUI.CreateColorButton then
        local origCreateColorButton = EXUI.CreateColorButton
        EXUI.CreateColorButton = function(self, parent, label, db, key, hasAlpha, onUpdate)
            local btn = origCreateColorButton(self, parent, label, db, key, hasAlpha, onUpdate)
            if btn and InitElvUI() and not btn._elvuiSkinned then
                btn._elvuiSkinned = true
                if btn.SetTemplate then
                    btn:SetTemplate("Transparent")
                end
            end
            return btn
        end
    end

    -- -------------------------------------------------------
    -- [NEW] Hook CreateSegmentedControl：分段控件 → ElvUI 模板
    -- -------------------------------------------------------
    if EXUI.CreateSegmentedControl then
        local origCreateSegmentedControl = EXUI.CreateSegmentedControl
        EXUI.CreateSegmentedControl = function(self, parent, width, items, currentValue, onChange)
            local container = origCreateSegmentedControl(self, parent, width, items, currentValue, onChange)
            if container and InitElvUI() and not container._elvuiSkinned then
                container._elvuiSkinned = true
                if container.SetTemplate then
                    container:SetTemplate("Default")
                end
            end
            return container
        end
    end

    -- -------------------------------------------------------
    -- [NEW] Hook CreateSidebarItemBase：侧边栏导航项 → 轻量皮肤
    -- 不使用 HandleButton 以保留自定义渐变/冰川蓝效果
    -- -------------------------------------------------------
    if EXUI.CreateSidebarItemBase then
        local origCreateSidebarItemBase = EXUI.CreateSidebarItemBase
        EXUI.CreateSidebarItemBase = function(self, parent)
            local btn = origCreateSidebarItemBase(self, parent)
            if btn and InitElvUI() and not btn._elvuiSkinned then
                btn._elvuiSkinned = true
                -- 轻量皮肤：仅应用 ElvUI 边框，保留原有视觉设计
                if btn.SetTemplate then
                    btn:SetTemplate("Transparent")
                    btn:SetBackdropColor(0, 0, 0, 0)
                    btn:SetBackdropBorderColor(0, 0, 0, 0)
                end
            end
            return btn
        end
    end

    -- -------------------------------------------------------
    -- [NEW] Hook CreateCategoryHeaderBase：侧边栏分类头 → 轻量皮肤
    -- -------------------------------------------------------
    if EXUI.CreateCategoryHeaderBase then
        local origCreateCategoryHeaderBase = EXUI.CreateCategoryHeaderBase
        EXUI.CreateCategoryHeaderBase = function(self, parent)
            local btn = origCreateCategoryHeaderBase(self, parent)
            if btn and InitElvUI() and not btn._elvuiSkinned then
                btn._elvuiSkinned = true
                if btn.SetTemplate then
                    btn:SetTemplate("Transparent")
                    btn:SetBackdropColor(0.1, 0.1, 0.12, 0.4)
                    btn:SetBackdropBorderColor(0, 0, 0, 0)
                end
            end
            return btn
        end
    end

    -- -------------------------------------------------------
    -- Hook CreateMainFrame：面板创建后立即 skin
    -- -------------------------------------------------------
    if EXUI.CreateMainFrame then
        hooksecurefunc(EXUI, "CreateMainFrame", function()
            SkinMainPanel()
        end)
    end

    -- -------------------------------------------------------
    -- Hook Toggle：兜底，确保面板首次显示时已 skin
    -- -------------------------------------------------------
    if EXUI.Toggle then
        hooksecurefunc(EXUI, "Toggle", function()
            if EXUI.MainFrame and not skinApplied then
                SkinMainPanel()
            end
            -- 延迟 skin 可能后创建的滚动条
            SkinScrollBarsDeferred()
        end)
    end

    -- -------------------------------------------------------
    -- Hook ShowModuleSettingsPage：模块设置页创建后 skin 滚动条
    -- -------------------------------------------------------
    if EXUI.ShowModuleSettingsPage then
        hooksecurefunc(EXUI, "ShowModuleSettingsPage", function()
            -- 延迟一帧，等待 ScrollFrame 完全创建
            C_Timer.After(0.05, SkinScrollBarsDeferred)
        end)
    end
end

--- 初始化入口
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        if InitElvUI() then
            -- print("|cff00ff00[ExwindTools]|r 检测到 ElvUI，已启用 ElvUI 皮肤集成")
            HookEXUI()
            HookExBossModernScrollBars()
            -- 如果面板已经创建（极少见情况），直接 skin
            if ExwindTools.UI and ExwindTools.UI.MainFrame then
                SkinMainPanel()
            end
        end
    elseif event == "ADDON_LOADED" then
        if InitElvUI() then
            HookExBossModernScrollBars()
            if exBossModernScrollHooked then
                self:UnregisterEvent("ADDON_LOADED")
            end
        end
    end
end)
