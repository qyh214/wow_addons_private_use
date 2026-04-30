-- =============================================================
-- ExwindTools NDui 皮肤集成
-- 当检测到 NDui 时，自动为所有框架应用 NDui 样式
--
-- 核心原理：
--   NDui 通过 _G["NDui"] = ns 暴露命名空间，其中 ns[1] = B 对象
--   B 对象上挂载了所有 UI 皮肤函数（B:CreateBD, B:Reskin, B:SetBD 等）
--   与 ElvUI 不同，NDui 的皮肤函数不是帧方法，而是静态函数调用。
--   NDui 的 ns[4] = DB 对象包含媒体资源（纹理、字体、颜色等）。
--
-- 审计依据：
--   NDui/Init.lua (全局导出 _G["NDui"] = ns)
--   NDui/Core/Functions.lua (B:CreateBD, B:SetBD, B:Reskin 等皮肤函数)
--   NDui/Core/Database.lua (DB.bdTex, DB.normTex, DB.closeTex 等媒体路径)
--
-- [v1.0.0] 2026-02-27 基于 NDui 源码审计编写
-- =============================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end

-- ⚠️ 互斥：如果 ElvUI 皮肤已加载，则不启用 NDui 皮肤
-- ElvUI 和 NDui 不会同时安装，但做防御处理
if ExwindTools.ElvUISkin and ExwindTools.ElvUISkin:IsElvUILoaded() then return end

local NDuiSkin = {}
ExwindTools.NDuiSkin = NDuiSkin

-- =============================================
-- NDui 引擎引用（延迟初始化）
-- =============================================
local B              -- NDui 基础模块（B = ns[1]，挂载所有 UI 函数）
local C              -- NDui 配置表（C = ns[2]）
local DB             -- NDui 数据库（DB = ns[4]，包含媒体资源路径）
local nduiReady = false  -- NDui 是否完全初始化

--- 初始化 NDui 引用
-- NDui 在 PLAYER_LOGIN 事件中完成初始化（Init.lua 中 B:RegisterEvent("PLAYER_LOGIN", ...)）
-- 因此必须在 PLAYER_LOGIN 之后调用此函数
local function InitNDui()
    if nduiReady then return true end

    local ndui = _G.NDui
    if not ndui then return false end

    B = ndui[1]
    if not B then return false end

    C = ndui[2]
    DB = ndui[4]

    if not DB then return false end

    -- 验证 B 对象上存在核心皮肤函数
    if not B.CreateBD then return false end

    -- 验证 B.Modules 是否已填充（Init.lua 中 PLAYER_LOGIN 回调内设置）
    -- 如果还没有 Modules，说明 NDui 尚未完成初始化
    if not B.Modules then return false end

    nduiReady = true
    return true
end

-- =============================================
-- 核心皮肤方法
-- =============================================

--- 为框架应用 NDui 风格的 Backdrop（背景 + 边框）
-- 对应 ElvUISkin:ApplyBackdrop → NDui B:CreateBD
-- NDui B:CreateBD 签名: B:CreateBD(alpha)
--   - 设置 Backdrop 背景为黑色半透明
--   - 边框由 C.db["Skins"]["GreyBD"] 控制颜色
--   - alpha 不传时使用 C.db["Skins"]["SkinAlpha"]
-- @param frame Frame 目标框架
-- @param alpha number|nil 背景透明度(0-1)，不传使用 NDui 默认值
function NDuiSkin:ApplyBackdrop(frame, alpha)
    if not frame then return false end
    if not InitNDui() then return false end

    -- NDui 的 CreateBD 是通过 B 对象静态调用
    -- 内部会执行 frame:SetBackdrop + SetBackdropColor + SetBackdropBorderColor
    pcall(B.CreateBD, frame, alpha)
    return true
end

--- 为框架创建带阴影的 Backdrop（SetBD = CreateBDFrame + CreateSD + CreateTex）
-- 对应 ElvUISkin:CreateBackdrop → NDui B:SetBD
-- B:SetBD 是 NDui 最完整的框架美化方法：
--   1. CreateBDFrame: 创建背景帧
--   2. CreateSD: 创建阴影
--   3. CreateTex: 创建背景纹理
-- @param frame Frame 目标框架
-- @param alpha number|nil 背景透明度
function NDuiSkin:CreateBackdrop(frame, alpha)
    if not frame then return false end
    if not InitNDui() then return false end

    local bg = nil
    pcall(function()
        bg = B.SetBD(frame, alpha)
    end)
    return bg ~= nil, bg
end

--- 创建 NDui 风格的背景帧（不含阴影）
-- B:CreateBDFrame 签名: B:CreateBDFrame(alpha, gradient)
-- @param frame Frame 目标框架
-- @param alpha number|nil 背景透明度
-- @param gradient boolean|nil 是否添加渐变
function NDuiSkin:CreateBDFrame(frame, alpha, gradient)
    if not frame then return nil end
    if not InitNDui() then return nil end

    local bg = nil
    pcall(function()
        bg = B.CreateBDFrame(frame, alpha, gradient)
    end)
    return bg
end

--- 应用 NDui 边框颜色
-- NDui 的边框颜色由 C.db["Skins"]["GreyBD"] 控制：
--   true: 白色半透明 (1,1,1,0.2)
--   false: 纯黑 (0,0,0,1)
-- @param frame Frame 目标框架
-- @param r number|nil 红色分量(自定义时)
-- @param g number|nil 绿色分量
-- @param b number|nil 蓝色分量
-- @param a number|nil 透明度
function NDuiSkin:ApplyBorder(frame, r, g, b, a)
    if not frame then return false end
    if not InitNDui() then return false end

    if frame.SetBackdropBorderColor then
        if r then
            frame:SetBackdropBorderColor(r, g or 0, b or 0, a or 1)
        else
            -- 使用 NDui 默认边框颜色逻辑
            B.SetBorderColor(frame)
        end
        return true
    end

    return false
end

--- 创建带 NDui 样式的框架（封装 CreateFrame + SetBD）
-- 对应 ElvUISkin:CreateFrame
-- @param frameType string 框架类型（"Frame", "Button" 等）
-- @param name string|nil 框架名称
-- @param parent Frame|nil 父框架
-- @param inherits string|nil 继承模板
function NDuiSkin:CreateFrame(frameType, name, parent, inherits)
    local frame = CreateFrame(frameType, name, parent or UIParent, inherits)

    if InitNDui() then
        pcall(function()
            B.SetBD(frame)
        end)
    else
        -- 降级：NDui 未加载时使用原生背景
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

--- 为已存在的框架应用 NDui 皮肤
-- 对应 ElvUISkin:SkinFrame
-- @param frame Frame 已存在的框架
function NDuiSkin:SkinFrame(frame)
    if not frame then return false end
    if not InitNDui() then return false end

    pcall(function()
        B.SetBD(frame)
    end)
    return true
end

-- =============================================
-- NDui 组件皮肤封装
-- =============================================

--- 应用 NDui 按钮样式
-- 源码: Functions.lua:939 - B:Reskin(noHighlight, override)
-- 功能: 清除原生纹理 → 创建 BDFrame → 添加 Hover 效果
-- @param button Button 目标按钮
-- @param noHighlight boolean|nil 是否禁用高亮效果
function NDuiSkin:SkinButton(button, noHighlight)
    if not button then return false end
    if not InitNDui() then return false end

    pcall(B.Reskin, button, noHighlight)
    return true
end

--- 应用 NDui 滑块样式
-- 源码: Functions.lua:1355 - B:ReskinSlider(vertical)
-- 功能: 清除纹理 → 创建 BDFrame → 美化滑块 thumb → 添加进度条
-- @param slider Slider 目标滑块
-- @param vertical boolean|nil 是否垂直方向
function NDuiSkin:SkinSlider(slider, vertical)
    if not slider then return false end
    if not InitNDui() then return false end

    pcall(B.ReskinSlider, slider, vertical)
    return true
end

--- 应用 NDui 编辑框样式
-- 源码: Functions.lua:1192 - B:ReskinEditBox(height, width)
-- 功能: 隐藏原生边框 → 创建 BDFrame → 可选调整尺寸
-- @param editbox EditBox 目标编辑框
-- @param height number|nil 指定高度
-- @param width number|nil 指定宽度
function NDuiSkin:SkinEditBox(editbox, height, width)
    if not editbox then return false end
    if not InitNDui() then return false end

    pcall(B.ReskinEditBox, editbox, height, width)
    return true
end

--- 应用 NDui 复选框样式
-- 源码: Functions.lua:1316 - B:ReskinCheck(forceSaturation)
-- 功能: 清除原生纹理 → 创建 BDFrame → 自定义选中标记 → 职业色高亮
-- @param checkbox CheckButton 目标复选框
-- @param forceSaturation boolean|nil 是否强制饱和度
function NDuiSkin:SkinCheckBox(checkbox, forceSaturation)
    if not checkbox then return false end
    if not InitNDui() then return false end

    pcall(B.ReskinCheck, checkbox, forceSaturation)
    return true
end

--- 应用 NDui 关闭按钮样式
-- 源码: Functions.lua:1161 - B:ReskinClose(parent, xOffset, yOffset, override)
-- 功能: 清除纹理 → 创建 BDFrame → 绘制 X 图标 → Hover 效果
-- @param button Button 目标关闭按钮
-- @param parent Frame|nil 父框架（用于定位）
function NDuiSkin:SkinCloseButton(button, parent)
    if not button then return false end
    if not InitNDui() then return false end

    pcall(B.ReskinClose, button, parent)
    return true
end

--- 应用 NDui 状态栏样式
-- 源码: Functions.lua:836 - B:CreateSB(spark, r, g, b)
-- 功能: 设置 StatusBar 纹理 + 颜色 → SetBD → 可选 Spark 光效
-- @param statusbar StatusBar 目标状态栏
-- @param spark boolean|nil 是否添加 Spark 光效
-- @param r number|nil 红色分量（不传使用职业色）
-- @param g number|nil 绿色分量
-- @param b number|nil 蓝色分量
function NDuiSkin:SkinStatusBar(statusbar, spark, r, g, b)
    if not statusbar then return false end
    if not InitNDui() then return false end

    pcall(B.CreateSB, statusbar, spark, r, g, b)
    return true
end

--- 应用 NDui Tab 标签样式
-- 源码: Functions.lua:969 - B:ReskinTab()
-- 功能: 隐藏背景层 → 创建 BDFrame → 添加高亮效果
-- @param tab Button 目标 Tab 按钮
function NDuiSkin:SkinTab(tab)
    if not tab then return false end
    if not InitNDui() then return false end

    pcall(B.ReskinTab, tab)
    return true
end

--- 应用 NDui 滚动条样式
-- 源码: Functions.lua:1072 - B:ReskinScroll()
-- 功能: 清除纹理 → 美化 Thumb → 箭头按钮
-- @param scrollbar ScrollBar 目标滚动条
function NDuiSkin:SkinScrollBar(scrollbar)
    if not scrollbar then return false end
    if not InitNDui() then return false end

    pcall(B.ReskinScroll, scrollbar)
    return true
end

--- 应用 NDui WowTrimScrollBar 样式
-- 源码: Functions.lua:1092 - B:ReskinTrimScroll(noTaint)
-- 功能: 精简版滚动条皮肤（适用于新版 TrimScrollBar）
-- @param scrollbar Frame 目标 TrimScrollBar
-- @param noTaint boolean|nil 是否避免污染
function NDuiSkin:SkinTrimScrollBar(scrollbar, noTaint)
    if not scrollbar then return false end
    if not InitNDui() then return false end

    pcall(B.ReskinTrimScroll, scrollbar, noTaint)
    return true
end

--- 应用 NDui 下拉菜单样式
-- 源码: Functions.lua:1110 - B:ReskinDropDown()
-- 功能: 清除纹理 → 创建 BDFrame → 添加向下箭头
-- @param dropdown Frame 目标下拉菜单
function NDuiSkin:SkinDropDown(dropdown)
    if not dropdown then return false end
    if not InitNDui() then return false end

    pcall(B.ReskinDropDown, dropdown)
    return true
end

--- 应用 NDui 箭头按钮样式
-- 源码: Functions.lua:1228 - B:ReskinArrow(direction)
-- @param button Button 目标箭头按钮
-- @param direction string 方向："up"/"down"/"left"/"right"
function NDuiSkin:SkinArrow(button, direction)
    if not button then return false end
    if not InitNDui() then return false end

    pcall(B.ReskinArrow, button, direction)
    return true
end

--- 应用 NDui 颜色选择器样式
-- 源码: Functions.lua:1301 - B:ReskinColorSwatch()
function NDuiSkin:SkinColorSwatch(swatch)
    if not swatch then return false end
    if not InitNDui() then return false end

    pcall(B.ReskinColorSwatch, swatch)
    return true
end

--- 应用 NDui StepperSlider 样式
-- 源码: Functions.lua:1396 - B:ReskinStepperSlider(minimal)
-- 注意: 这是带左右箭头步进的滑块（MinimalSliderWithSteppersTemplate）
-- @param slider Frame 目标 StepperSlider
-- @param minimal boolean|nil 是否使用精简模式
function NDuiSkin:SkinStepperSlider(slider, minimal)
    if not slider then return false end
    if not InitNDui() then return false end

    pcall(B.ReskinStepperSlider, slider, minimal)
    return true
end

--- 应用 NDui 菜单按钮样式
-- 源码: Functions.lua:955 - B:ReskinMenuButton()
-- 功能: 清除纹理 → SetBD → 自定义 Hover/Click 效果（职业色高亮）
-- @param button Button 目标菜单按钮
function NDuiSkin:SkinMenuButton(button)
    if not button then return false end
    if not InitNDui() then return false end

    pcall(B.ReskinMenuButton, button)
    return true
end

--- 应用 NDui 肖像框样式
-- 源码: Functions.lua:1538 - B:ReskinPortraitFrame()
-- 功能: 清除纹理 → SetBD → 隐藏肖像 → 美化关闭按钮
-- @param frame Frame 目标肖像框架
function NDuiSkin:SkinPortraitFrame(frame)
    if not frame then return false end
    if not InitNDui() then return false end

    local bg = nil
    pcall(function()
        bg = B.ReskinPortraitFrame(frame)
    end)
    return bg ~= nil, bg
end

--- 清除框架上的暴雪原生纹理
-- 源码: Functions.lua:414 - B:StripTextures(kill)
-- @param frame Frame 目标框架
-- @param kill boolean|number|nil 清除方式（true=HideObject, 0=SetAlpha(0), nil=清空纹理）
function NDuiSkin:StripTextures(frame, kill)
    if not frame then return false end
    if not InitNDui() then return false end

    pcall(B.StripTextures, frame, kill)
    return true
end

--- 创建阴影效果
-- 源码: Functions.lua:590 - B:CreateSD(size, override)
-- @param frame Frame 目标框架
-- @param size number|nil 阴影大小（默认 5）
-- @param override boolean|nil 是否忽略全局阴影开关
function NDuiSkin:CreateShadow(frame, size, override)
    if not frame then return nil end
    if not InitNDui() then return nil end

    local shadow = nil
    pcall(function()
        shadow = B.CreateSD(frame, size, override)
    end)
    return shadow
end

-- =============================================
-- 媒体资源获取
-- =============================================

--- 获取 NDui 媒体资源，降级时返回默认值
-- NDui 媒体路径存放在 DB (ns[4]) 对象上
function NDuiSkin:GetMedia()
    if not InitNDui() then
        return {
            normFont = STANDARD_TEXT_FONT,
            blankTex = [[Interface\ChatFrame\ChatFrameBackground]],
            normTex = [[Interface\ChatFrame\ChatFrameBackground]],
            bordercolor = { 0, 0, 0 },
            backdropcolor = { 0, 0, 0, 0.5 },
        }
    end

    return {
        normFont = DB.Font and DB.Font[1] or STANDARD_TEXT_FONT,
        fontSize = DB.Font and DB.Font[2] or 12,
        fontFlags = DB.Font and DB.Font[3] or "OUTLINE",
        blankTex = DB.bdTex or [[Interface\ChatFrame\ChatFrameBackground]],
        normTex = DB.normTex,
        flatTex = DB.flatTex,
        gradTex = DB.gradTex,
        bgTex = DB.bgTex,
        glowTex = DB.glowTex,
        sparkTex = DB.sparkTex,
        closeTex = DB.closeTex,
        arrowTex = DB.ArrowUp,
    }
end

--- 检查 NDui 是否已加载并完成初始化
function NDuiSkin:IsNDuiLoaded()
    return InitNDui()
end

--- 获取 NDui 配色方案
-- NDui 使用职业颜色作为主题色（DB.r, DB.g, DB.b）
function NDuiSkin:GetColors()
    if not InitNDui() then
        return {
            class = { r = 0.3, g = 0.3, b = 0.3 },
            border = { r = 0, g = 0, b = 0 },
            backdrop = { r = 0, g = 0, b = 0 },
        }
    end

    return {
        class = { r = DB.r or 0.3, g = DB.g or 0.3, b = DB.b or 0.3 },
        border = { r = 0, g = 0, b = 0 },
        backdrop = { r = 0, g = 0, b = 0, a = C and C.db and C.db["Skins"] and C.db["Skins"]["SkinAlpha"] or 0.5 },
    }
end

--- 获取 NDui 的 mult 值（像素缩放乘数）
-- NDui 使用 C.mult 控制像素精确度
function NDuiSkin:GetMult()
    if not InitNDui() then return 1 end
    return C and C.mult or 1
end

-- =============================================
-- [核心] 主动 Hook ExwindTools 设置面板
-- =============================================

local skinApplied = false -- 防止重复 skin 主面板

--- 对主设置面板框架应用 NDui 皮肤
local function SkinMainPanel()
    if skinApplied then return end

    local EXUI = ExwindTools.UI
    if not EXUI or not EXUI.MainFrame then return end
    if not InitNDui() then return end

    local f = EXUI.MainFrame
    skinApplied = true

    -- 1. 主窗口：使用 NDui CreateBD 直接在 f 上设置 Backdrop
    -- ⚠️ 不能使用 B.SetBD(f)！SetBD 创建的是子级背景帧，f 自身的 BackdropTemplate
    --    仍然保留原来的不透明黑色背景，导致双层叠加看起来不透明。
    -- 正确做法：直接用 B.CreateBD(f) 替换 f 自身的 Backdrop，
    --    alpha 不传，使用 NDui 全局的 SkinAlpha 值，与 NDui 自身面板一致。
    pcall(function()
        B.CreateBD(f)        -- 直接在 f 上应用 NDui Backdrop（使用 SkinAlpha 透明度）
        B.CreateSD(f, nil, true)  -- 添加阴影（override=true 忽略全局阴影开关）
        B.CreateTex(f)       -- 添加背景纹理（如果用户启用了 BgTex）
    end)

    -- 2. 关闭按钮
    pcall(function()
        if f.CloseButton then
            -- [Fix] 直接使用存储的引用，避免在 WoW 12.x 中
            -- UIPanelCloseButton atlas 纹理导致纹理名匹配失败
            B.ReskinClose(f.CloseButton)
        else
            -- 兜底：遍历子帧查找（兼容旧版本）
            for _, child in ipairs({ f:GetChildren() }) do
                if child:GetObjectType() == "Button" and child:IsObjectType("Button") then
                    local regions = { child:GetRegions() }
                    for _, region in ipairs(regions) do
                        if region:GetObjectType() == "Texture" then
                            local tex = region:GetTexture()
                            if tex and type(tex) == "string" and tex:find("CloseButton") then
                                B.ReskinClose(child)
                                break
                            end
                        end
                    end
                    if not child._nduiSkinned and child:GetWidth() == 32 and child:GetHeight() == 32 then
                        pcall(function()
                            B.ReskinClose(child)
                            child._nduiSkinned = true
                        end)
                    end
                end
            end
        end
    end)

    -- 3. 滚动条皮肤
    pcall(function()
        local scrollbars = {
            _G["ExwindSidebarScrollScrollBar"],
            _G["ExwindCommonScrollScrollBar"],
            _G["ExwindModuleGridScrollScrollBar"],
        }
        for _, sb in ipairs(scrollbars) do
            if sb and not sb._nduiSkinned then
                sb._nduiSkinned = true
                pcall(B.ReskinScroll, sb)
            end
        end
    end)

    -- 4. 右侧面板框架
    if EXUI.RightPanel and not EXUI.RightPanel._nduiSkinned then
        pcall(function()
            -- 使用低透明度，与主面板透明风格一致
            B.CreateBD(EXUI.RightPanel, 0.15)
            EXUI.RightPanel._nduiSkinned = true
        end)
    end
end

--- 延迟 Skin 滚动条（模块设置页的滚动条可能晚于主面板创建）
local function SkinScrollBarsDeferred()
    if not InitNDui() then return end

    pcall(function()
        local scrollbars = {
            _G["ExwindSidebarScrollScrollBar"],
            _G["ExwindCommonScrollScrollBar"],
            _G["ExwindModuleGridScrollScrollBar"],
        }
        for _, sb in ipairs(scrollbars) do
            if sb and not sb._nduiSkinned then
                sb._nduiSkinned = true
                pcall(B.ReskinScroll, sb)
            end
        end
    end)
end

--- Hook EXUI 的工厂方法，在创建组件后自动套 NDui 皮肤
local function HookEXUI()
    local EXUI = ExwindTools.UI
    if not EXUI then return end

    -- -------------------------------------------------------
    -- Hook CreateActionButton：紫色大按钮 → NDui Reskin + 职业色调
    -- -------------------------------------------------------
    if EXUI.CreateActionButton then
        local origCreateActionButton = EXUI.CreateActionButton
        EXUI.CreateActionButton = function(self, parent, text, onClick)
            local btn = origCreateActionButton(self, parent, text, onClick)
            if btn and InitNDui() and not btn._nduiSkinned then
                btn._nduiSkinned = true
                pcall(function()
                    B.Reskin(btn)
                    -- 保留原有的紫色主题，覆盖 NDui 默认效果
                    if btn.__bg and btn.__bg.SetBackdropColor then
                        btn.__bg:SetBackdropColor(0.64, 0.19, 0.79, 0.3)
                    end
                end)
            end
            return btn
        end
    end

    -- -------------------------------------------------------
    -- Hook CreateSmallButton：底部小按钮 → NDui Reskin
    -- -------------------------------------------------------
    if EXUI.CreateSmallButton then
        local origCreateSmallButton = EXUI.CreateSmallButton
        EXUI.CreateSmallButton = function(self, parent, text, onClick)
            local btn = origCreateSmallButton(self, parent, text, onClick)
            if btn and InitNDui() and not btn._nduiSkinned then
                btn._nduiSkinned = true
                pcall(B.Reskin, btn)
            end
            return btn
        end
    end

    -- -------------------------------------------------------
    -- Hook CreateSlider：滑动条 → NDui ReskinStepperSlider
    -- NDui 对 MinimalSliderWithSteppersTemplate 有专门的 ReskinStepperSlider
    --
    -- [v1.0.2 Fix] 与 ElvUI 皮肤同步修复策略（ExwindElvUISkin.lua v5.1.3）：
    --   ReskinStepperSlider 设计基于暴雪原生 250x40 尺寸，ExwindTools 的
    --   GridSlider 高度仅 20px，导致以下问题：
    --   1) bg (TOPLEFT(10,-offset)/BOTTOMRIGHT(-10,offset), offset=10) 高度 =
    --      20-10-10 = 0px → 滑槽不可见
    --   2) Thumb SetSize(20,30) 超出 20px 框架 → 视觉比例严重失调
    --   修复：调用 ReskinStepperSlider 后，找到 bg 并强制高度为 10px 居中，
    --   同时缩小 Thumb 为 12x18（bar 的 TOPLEFT/BOTTOMLEFT/RIGHT 锚点自动跟随）。
    -- -------------------------------------------------------
    if EXUI.CreateSlider then
        local origCreateSlider = EXUI.CreateSlider
        EXUI.CreateSlider = function(self, parent, width, label, minVal, maxVal, curVal, step, formatter, onValueChanged)
            local slider = origCreateSlider(self, parent, width, label, minVal, maxVal, curVal, step, formatter, onValueChanged)
            if slider and InitNDui() and not slider._nduiSkinned then
                slider._nduiSkinned = true
                pcall(function()
                    if slider.Back and slider.Forward and slider.Slider then
                        B.ReskinStepperSlider(slider, true)

                        local innerSlider = slider.Slider

                        -- Fix 1: 修正滑槽 bg 高度为 10px，居中对齐
                        -- ReskinStepperSlider 在 slider.Slider 上创建了 BDFrame 子帧作为滑槽
                        -- 需要找到这个 bg 并修正其锚点
                        local trackBg = nil
                        for _, child in ipairs({ innerSlider:GetChildren() }) do
                            if child.SetBackdrop and child.GetBackdrop and child:GetBackdrop() then
                                trackBg = child
                            end
                        end
                        if trackBg then
                            trackBg:ClearAllPoints()
                            trackBg:SetHeight(10)
                            trackBg:SetPoint("LEFT", innerSlider, "LEFT", 10, 0)
                            trackBg:SetPoint("RIGHT", innerSlider, "RIGHT", -10, 0)
                        end

                        -- Fix 2: 缩小 Thumb 尺寸，匹配 20px 高度的滑块
                        -- NDui 设置 Thumb = 20x30 适配 40px 框架，按比例缩小为 12x18
                        -- trackBg 内的 bar (TOPLEFT/BOTTOMLEFT/RIGHT → thumb:CENTER) 自动跟随
                        local thumb = innerSlider.Thumb
                        if thumb then
                            thumb:SetSize(12, 18)
                        end
                    elseif slider.Slider then
                        B.ReskinSlider(slider.Slider)
                    else
                        B.ReskinSlider(slider)
                    end
                end)
            end
            return slider
        end
    end

    -- -------------------------------------------------------
    -- Hook 所有下拉菜单工厂
    -- NDui 对 WowStyle1DropdownTemplate 使用 B:ReskinDropDown
    -- 但 ExwindTools 的下拉菜单可能是自定义的，使用 SetBD + 箭头
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
                if dropdown and InitNDui() and not dropdown._nduiSkinned then
                    dropdown._nduiSkinned = true
                    pcall(function()
                        -- 1. 清除暴雪原生背景纹理
                        if dropdown.NormalTexture then dropdown.NormalTexture:SetAlpha(0) end
                        if dropdown.HighlightTexture then dropdown.HighlightTexture:SetAlpha(0) end
                        if dropdown.PushedTexture then dropdown.PushedTexture:SetAlpha(0) end
                        for _, region in ipairs({ dropdown:GetRegions() }) do
                            if region:IsObjectType("Texture") then
                                local name = region:GetDebugName() or ""
                                if region ~= dropdown.Arrow and not name:find("Arrow") then
                                    local drawLayer = region:GetDrawLayer()
                                    if drawLayer == "BACKGROUND" or drawLayer == "BORDER" then
                                        region:SetAlpha(0)
                                    end
                                end
                            end
                        end

                        -- 2. 应用 NDui 背景（CreateBDFrame 而非 SetBD，避免阴影溢出）
                        local bg = B.CreateBDFrame(dropdown, 0, true)
                        bg:SetAllPoints()
                        dropdown.__bg = bg

                        -- 3. 替换箭头为 NDui 风格
                        if dropdown.Arrow then
                            dropdown.Arrow:SetAlpha(0)
                        end
                        local arrow = dropdown:CreateTexture(nil, "ARTWORK")
                        arrow:SetSize(18, 18)
                        arrow:SetPoint("RIGHT", dropdown, "RIGHT", -3, 0)
                        B.SetupArrow(arrow, "down")
                        dropdown.__texture = arrow

                        -- 4. Hover 效果（职业色）
                        dropdown:HookScript("OnEnter", B.Texture_OnEnter)
                        dropdown:HookScript("OnLeave", B.Texture_OnLeave)
                    end)
                end
                return dropdown
            end
        end
    end

    -- -------------------------------------------------------
    -- Hook CreateButton：内容区通用按钮 → NDui Reskin
    -- -------------------------------------------------------
    if EXUI.CreateButton then
        local origCreateButton = EXUI.CreateButton
        EXUI.CreateButton = function(self, parent, width, height, text, onClick)
            local btn = origCreateButton(self, parent, width, height, text, onClick)
            if btn and InitNDui() and not btn._nduiSkinned then
                btn._nduiSkinned = true
                pcall(B.Reskin, btn)
            end
            return btn
        end
    end

    -- -------------------------------------------------------
    -- Hook CreateCheckbox：勾选框 → NDui ReskinCheck
    -- -------------------------------------------------------
    if EXUI.CreateCheckbox then
        local origCreateCheckbox = EXUI.CreateCheckbox
        EXUI.CreateCheckbox = function(self, parent, text, initialValue, onClick)
            local container = origCreateCheckbox(self, parent, text, initialValue, onClick)
            if container and container.checkbox and InitNDui() and not container.checkbox._nduiSkinned then
                container.checkbox._nduiSkinned = true
                pcall(B.ReskinCheck, container.checkbox)
            end
            return container
        end
    end

    -- -------------------------------------------------------
    -- Hook CreateEditBox：输入框 → NDui 风格美化
    -- 使用 B.CreateBDFrame(editbox, 0, true) 匹配 NDui 原生 ReskinEditBox 行为：
    --   1. 创建子级 BDFrame 作为背景（alpha=0 黑色底 + 渐变纹理 → 可见的深色背景）
    --   2. 聚焦时职业色边框高亮，失焦恢复默认
    -- [Fix] 旧版使用 B.CreateBD(editbox, 0) 直接在 editbox 上设置 alpha=0 的 Backdrop，
    --   导致背景完全透明 + 边框为黑色/灰色（取决于 GreyBD），输入框几乎不可见。
    -- -------------------------------------------------------
    if EXUI.CreateEditBox then
        local origCreateEditBox = EXUI.CreateEditBox
        EXUI.CreateEditBox = function(self, parent, text, w, h, labelText, options)
            local container = origCreateEditBox(self, parent, text, w, h, labelText, options)
            if container and InitNDui() then
                local editbox = container.editBox or container
                if editbox and not editbox._nduiSkinned then
                    editbox._nduiSkinned = true
                    pcall(function()
                        -- 隐藏 editbox 自身的 BackdropTemplate 背景（避免双层叠加）
                        if editbox.SetBackdrop then
                            editbox:SetBackdrop(nil)
                        end

                        -- 使用 CreateBDFrame 创建带渐变的背景帧（与 NDui ReskinEditBox 一致）
                        local bg = B.CreateBDFrame(editbox, 0, true)
                        bg:SetPoint("TOPLEFT", editbox, "TOPLEFT", -2, 0)
                        bg:SetPoint("BOTTOMRIGHT", editbox, "BOTTOMRIGHT", 0, 0)
                        editbox.__bg = bg

                        -- 添加聚焦高亮效果（职业色边框）
                        local cr, cg, cb = DB.r, DB.g, DB.b
                        editbox:HookScript("OnEditFocusGained", function(self)
                            if self.__bg then
                                self.__bg:SetBackdropBorderColor(cr, cg, cb, 1)
                            end
                        end)
                        editbox:HookScript("OnEditFocusLost", function(self)
                            if self.__bg then
                                B.SetBorderColor(self.__bg)
                            end
                        end)
                    end)
                end
            end
            return container
        end
    end

    -- -------------------------------------------------------
    -- Hook CreateColorButton：颜色选择按钮 → NDui CreateBD
    -- -------------------------------------------------------
    if EXUI.CreateColorButton then
        local origCreateColorButton = EXUI.CreateColorButton
        EXUI.CreateColorButton = function(self, parent, label, db, key, hasAlpha, onUpdate)
            local btn = origCreateColorButton(self, parent, label, db, key, hasAlpha, onUpdate)
            if btn and InitNDui() and not btn._nduiSkinned then
                btn._nduiSkinned = true
                pcall(function()
                    B.CreateBD(btn, 1)
                end)
            end
            return btn
        end
    end

    -- -------------------------------------------------------
    -- Hook CreateSegmentedControl：分段控件 → NDui CreateBDFrame
    -- -------------------------------------------------------
    if EXUI.CreateSegmentedControl then
        local origCreateSegmentedControl = EXUI.CreateSegmentedControl
        EXUI.CreateSegmentedControl = function(self, parent, width, items, currentValue, onChange)
            local container = origCreateSegmentedControl(self, parent, width, items, currentValue, onChange)
            if container and InitNDui() and not container._nduiSkinned then
                container._nduiSkinned = true
                pcall(function()
                    B.CreateBD(container, 0)
                end)
            end
            return container
        end
    end

    -- -------------------------------------------------------
    -- Hook CreateSidebarItemBase：侧边栏导航项 → 轻量 NDui 皮肤
    -- 保留原有视觉设计，仅添加 NDui 风格的细微边框
    -- -------------------------------------------------------
    if EXUI.CreateSidebarItemBase then
        local origCreateSidebarItemBase = EXUI.CreateSidebarItemBase
        EXUI.CreateSidebarItemBase = function(self, parent)
            local btn = origCreateSidebarItemBase(self, parent)
            if btn and InitNDui() and not btn._nduiSkinned then
                btn._nduiSkinned = true
                -- 轻量皮肤：仅添加 NDui 背景帧，保留原有渐变/冰川蓝效果
                pcall(function()
                    local bg = B.CreateBDFrame(btn, 0)
                    bg:SetAllPoints()
                    -- 默认隐藏边框，保持原有外观
                    bg:SetBackdropBorderColor(0, 0, 0, 0)
                    btn.__nduiBg = bg
                end)
            end
            return btn
        end
    end

    -- -------------------------------------------------------
    -- Hook CreateCategoryHeaderBase：侧边栏分类头 → 轻量 NDui 皮肤
    -- -------------------------------------------------------
    if EXUI.CreateCategoryHeaderBase then
        local origCreateCategoryHeaderBase = EXUI.CreateCategoryHeaderBase
        EXUI.CreateCategoryHeaderBase = function(self, parent)
            local btn = origCreateCategoryHeaderBase(self, parent)
            if btn and InitNDui() and not btn._nduiSkinned then
                btn._nduiSkinned = true
                pcall(function()
                    local bg = B.CreateBDFrame(btn, 0)
                    bg:SetAllPoints()
                    bg:SetBackdropColor(0.1, 0.1, 0.12, 0.3)
                    bg:SetBackdropBorderColor(0, 0, 0, 0)
                    btn.__nduiBg = bg
                end)
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
            C_Timer.After(0.05, SkinScrollBarsDeferred)
        end)
    end
end

-- =============================================
-- 初始化入口
-- =============================================
-- NDui 在 PLAYER_LOGIN 中执行 OnLogin 完成初始化
-- 使用 PLAYER_ENTERING_WORLD 确保在 NDui 之后运行

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")

        -- 再次检查互斥：如果 ElvUI 已就绪，放弃 NDui 皮肤
        if ExwindTools.ElvUISkin and ExwindTools.ElvUISkin:IsElvUILoaded() then
            ExwindTools.NDuiSkin = nil
            return
        end

        if InitNDui() then
            -- print("|cff00ff00[ExwindTools]|r 检测到 NDui，已启用 NDui 皮肤集成")
            HookEXUI()
            -- 如果面板已经创建（极少见情况），直接 skin
            if ExwindTools.UI and ExwindTools.UI.MainFrame then
                SkinMainPanel()
            end
        end
    end
end)
