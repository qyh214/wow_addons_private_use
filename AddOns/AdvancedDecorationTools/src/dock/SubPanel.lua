-- 子面板（DockUI 下方面板）
-- 目标：将 DockUI.lua 中的下方面板实现解耦为独立脚本，保持交互与视觉一致。

local ADDON_NAME, ADT = ...
if not ADT or not ADT.IsToCVersionEqualOrNewerThan(110000) then return end

local API = ADT.API
local UI  = ADT.DockUI or {}
local Def = assert(UI.Def, "DockUI.Def 不存在：请确认 DockUI.lua 已加载")

local GetRightPadding            = assert(UI.GetRightPadding, "DockUI.GetRightPadding 不存在")
local ComputeSideSectionWidth    = assert(UI.ComputeSideSectionWidth, "DockUI.ComputeSideSectionWidth 不存在")
local CreateSettingsHeader       = assert(UI.CreateSettingsHeader, "DockUI.CreateSettingsHeader 不存在")

local function AttachTo(main)
    if not main or main.__SubPanelAttached then return end

    function main:EnsureSubPanel()
        if self.SubPanel then return self.SubPanel end

        local sub = CreateFrame("Frame", nil, self)
        self.SubPanel = sub

        -- 与主面板下边无缝拼接；宽度与“中央区域”一致。
        -- 关键改动：左侧锚点不再使用“创建时的固定像素偏移”（sideSectionWidth），
        -- 改为直接锚到 CentralSection 的 BOTTOMLEFT，从而在语言切换/字体变化
        -- 导致左侧分类栏宽度变动时，子面板能即时跟随，无需额外刷新。
        if self.CentralSection then
            sub:SetPoint("TOPLEFT", self.CentralSection, "BOTTOMLEFT", 0, 0)
        else
            -- 兜底（极早期调用）：仍按当前估算宽度贴紧右侧区域。
            local leftOffset = tonumber(self.sideSectionWidth) or ComputeSideSectionWidth() or 180
            sub:SetPoint("TOPLEFT", self, "BOTTOMLEFT", leftOffset, 0)
        end
        sub:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0)
        sub:SetHeight(192)
        sub:SetFrameStrata(self:GetFrameStrata())
        sub:SetFrameLevel(self:GetFrameLevel())

        -- 边框与背景：保持与主面板一致
        local borderFrame = CreateFrame("Frame", nil, sub)
        borderFrame:SetAllPoints(sub)
        borderFrame:SetFrameLevel(sub:GetFrameLevel() + 100)
        sub.BorderFrame = borderFrame

        -- 与 DockUI 主框体保持一致：边框严格贴合容器，不做 ±4 像素外扩，
        -- 以免视觉上比右侧面板“略宽”。
        local border = borderFrame:CreateTexture(nil, "OVERLAY")
        border:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", 0, 0)
        border:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", 0, 0)
        border:SetAtlas("housing-wood-frame")
        border:SetTextureSliceMargins(16, 16, 16, 16)
        border:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
        borderFrame.WoodFrame = border

        local bg = sub:CreateTexture(nil, "BACKGROUND")
        bg:SetAtlas("housing-basic-panel-background")
        -- 背景也与 DockUI 右侧区域的 inset 规则保持一致（参考 DockUI.Def）。
        local rightInset = (Def.RightBGInsetRight ~= nil) and Def.RightBGInsetRight or -2
        local bottomInset = (Def.CenterBGInsetBottom ~= nil) and Def.CenterBGInsetBottom or 2
        bg:SetPoint("TOPLEFT", sub, "TOPLEFT", 0, 0)
        bg:SetPoint("BOTTOMRIGHT", sub, "BOTTOMRIGHT", rightInset, bottomInset)
        sub.Background = bg

        -- 统一内容容器
        local content = CreateFrame("Frame", nil, sub)
        content:SetPoint("TOPLEFT", sub, "TOPLEFT", 10, -14)
        content:SetPoint("BOTTOMRIGHT", sub, "BOTTOMRIGHT", -10, 10)
        sub.Content = content

        -- 标题 Header（占位文案）
        local header = CreateSettingsHeader(content)
        header:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -10)
        header:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -10)
        header:SetHeight((Def.ButtonSize or 28) + 2)
        -- 默认不显示任何占位文本，便于“无正文时自动隐藏”
        header:SetText("")

        -- 分隔条：下移并左右对称以居中
        if header.Divider then
            header.Divider:ClearAllPoints()
            local pad = GetRightPadding()
            header.Divider:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", pad, -2)
            header.Divider:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -pad, -2)
        end

        -- 标题样式：居中、小号 Fancy + 淡金色 + 阴影
        if header.Label then
            header.Label:ClearAllPoints()
            header.Label:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 6)
            header.Label:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 6)
            header.Label:SetJustifyH("CENTER")
            if _G.Fancy24Font then
                header.Label:SetFontObject("Fancy24Font")
            elseif _G.Fancy22Font then
                header.Label:SetFontObject("Fancy22Font")
            else
                header.Label:SetFontObject("GameFontNormalLarge")
            end
            header.Label:SetTextColor(Def.TitleColorPaleGold[1], Def.TitleColorPaleGold[2], Def.TitleColorPaleGold[3])
            if header.Label.SetShadowColor then header.Label:SetShadowColor(0, 0, 0, 1) end
            if header.Label.SetShadowOffset then header.Label:SetShadowOffset(1, -1) end
        end

        sub.Header = header

        -- 自适应高度：根据 Content 子节点的“实际可见范围”动态调节 SubPanel 高度
        -- 说明：
        -- - 不依赖业务侧（Housing）的行数/字体/布局细节，完全依据可见像素范围计算；
        -- - 避免双实现（DRY）：高度唯一权威改为由 SubPanel 自身测量；业务侧只需触发一次“请求自适应”。
        do
            -- 改为使用 Housing_Config.lua 的“单一权威”配置，避免硬编码
            local CFG = ADT.GetHousingCFG and ADT.GetHousingCFG() or nil
            local L   = CFG and CFG.Layout or {}
            local AUTO_MIN     = tonumber(L.subPanelMinHeight)   or 160
            local AUTO_MAX     = tonumber(L.subPanelMaxHeight)   or 1024
            local INSET_TOP    = tonumber(L.contentTopPadding)   or 14   -- content 与 sub 顶边的内边距
            local INSET_BOTTOM = tonumber(L.contentBottomPadding) or 10   -- content 与 sub 底边的内边距
            local HEADER_NUDGE = tonumber(L.headerTopNudge)      or 10   -- Header 相对 Content 的下移
            local HEADER_GAP   = tonumber(L.headerToInstrGap)    or 8    -- Header 与说明列表的间距
            local pendingTicker
            local lastApplied
            
            -- 判空：除 Header 外是否存在“可见且占据面积”的子节点
            local function AnyNonHeaderVisible(frame, header)
                if not frame then return false end
                for _, ch in ipairs({frame:GetChildren()}) do
                    if ch and ch ~= header and (not ch.IsShown or ch:IsShown()) then
                        -- 若存在可见后代，则认为“正文存在”
                        if AnyNonHeaderVisible(ch, header) then return true end
                        -- 无后代或后代不可见时，仅在自己具备有效绘制面积且非透明时才算可见
                        local alphaOK = (not ch.GetAlpha) or ((ch:GetAlpha() or 0) > 0.01)
                        local visibleOK = (not ch.IsVisible) or ch:IsVisible()
                        local w = (ch.GetWidth and ch:GetWidth()) or 0
                        local h = (ch.GetHeight and ch:GetHeight()) or 0
                        local hasArea = (w or 0) > 2 and (h or 0) > 2
                        if alphaOK and visibleOK and hasArea and (not ch.GetChildren or select('#', ch:GetChildren()) == 0) then
                            return true
                        end
                    end
                end
                return false
            end

            local function HeaderHasMeaningfulText(header)
                if not (header and header.Label) then return false end
                if not (header.Label.IsShown and header.Label:IsShown()) then return false end
                local a = header.Label.GetAlpha and header.Label:GetAlpha() or 1
                if a <= 0.01 then return false end
                local t = header.Label.GetText and header.Label:GetText() or nil
                return type(t) == 'string' and t:match('%S') ~= nil
            end

            local function DeepestBottom(frame)
                if not (frame and frame.GetBottom) then return nil end
                -- 透明/不可见的容器不参与高度计算，避免把 HoverHUD 等透明容器的“更低 bottom”算进去
                if (frame.GetAlpha and (frame:GetAlpha() or 0) <= 0.01) then return nil end
                if (frame.IsVisible and not frame:IsVisible()) then return nil end
                local minB = frame:GetBottom()
                if frame.GetChildren then
                    for _, ch in ipairs({frame:GetChildren()}) do
                        if ch and (not ch.IsShown or ch:IsShown()) then
                            -- 同样忽略透明/不可见子节点
                            if (not ch.GetAlpha or (ch:GetAlpha() or 0) > 0.01) and (not ch.IsVisible or ch:IsVisible()) then
                                local b = DeepestBottom(ch)
                                if b then minB = (minB and math.min(minB, b)) or b end
                            end
                        end
                    end
                end
                return minB
            end

            -- 计算目标高度。
            -- 修正点：
            -- - 顶锚从“弹窗顶部/Header 顶部”改为“Header 下方分隔线 + headerToInstrGap”，
            --   以避免额外把 Header 顶部空间计入“正文高度”造成底部多余留白。
            -- - 同时保持 Header 自身始终包含在 SubPanel 高度内（即：Header 可见区域 + GAP + 正文 + 下内边距）。
            local function ComputeRequiredHeight()
                if not (sub and sub.Content) then return end
                local cont   = sub.Content
                local header = sub.Header
                if not header then return end

                -- 1) 计算“正文”的下边界（排除 header 自身）；上边界固定取“Header 分隔线下方 GAP 处”
                local bottomMost
                for _, ch in ipairs({cont:GetChildren()}) do
                    if ch and ch ~= header and (not ch.IsShown or ch:IsShown()) then
                        -- 过滤透明/不可见容器，避免误把 HoverHUD 等透明容器计入高度
                        if (not ch.GetAlpha or (ch:GetAlpha() or 0) > 0.01) and (not ch.IsVisible or ch:IsVisible()) then
                            local cb = DeepestBottom(ch) or (ch.GetBottom and ch:GetBottom())
                            if cb then bottomMost = bottomMost and math.min(bottomMost, cb) or cb end
                        end
                    end
                end

                -- 2) 以 Header 分隔线为顶部参考，动态测算高度
                local headerHeight = (header.GetHeight and header:GetHeight()) or ((Def.ButtonSize or 28) + 2)
                local headerBottom = header.GetBottom and header:GetBottom() or nil
                -- 纵向布局稳定前可能尚未获得 Bottom；此时回退到“Header 顶部法”，避免返回 nil
                local headerTop    = header.GetTop and header:GetTop() or nil

                -- 顶端基准：Header 下边（或以顶-高估算）减去 GAP
                local headerRefBottom = headerBottom or (headerTop and (headerTop - headerHeight)) or 0
                local topRef = headerRefBottom - HEADER_GAP

                local contentPixels = 0
                if bottomMost then
                    contentPixels = math.max(0, topRef - bottomMost)
                end

                -- 顶端：内容区到 SubPanel 顶部的固定内边距（含 header 高度/位置/GAP）
                local topPadding = INSET_TOP + HEADER_NUDGE + headerHeight + HEADER_GAP

                -- 目标高度 = 顶部(内容→Header 分隔线/GAP/内边距) + 正文高度 + 底部内边距
                local target = math.floor(topPadding + contentPixels + INSET_BOTTOM + 0.5)
                target = math.max(AUTO_MIN, math.min(AUTO_MAX, target))
                return target
            end

            local function ApplyAutoHeightOnce()
                local h = ComputeRequiredHeight()
                if not h then return false end
                if lastApplied and math.abs((lastApplied or 0) - h) <= 1 then
                    -- 变化很小则认为已稳定
                    return true
                end
                sub:SetHeight(h)
                lastApplied = h
                return false
            end

            local function EvaluateAutoHide()
                -- KISS：显示/隐藏的唯一权威在这里裁决。
                -- 规则：只在“正文为空 且 标题无意义”时隐藏；否则必须显示。
                local noBody = not AnyNonHeaderVisible(sub.Content, sub.Header)
                local noHeader = not HeaderHasMeaningfulText(sub.Header)
                if noBody and noHeader then
                    sub:SetHeight(0)
                    sub:Hide()
                else
                    if not sub:IsShown() then
                        sub:Show()
                        -- 显示后交由 OnShow 钩子触发一次自适应与再次判空
                    end
                end
            end

            local function RequestAutoResize()
                if pendingTicker then return end
                -- 短期采样多次以等待暴雪 VerticalLayout 完成排版（字体缩放/行隐藏等）
                local count, maxSample = 0, 12
                pendingTicker = C_Timer.NewTicker(0.02, function(t)
                    count = count + 1
                    local stable = ApplyAutoHeightOnce()
                    if stable or count >= maxSample then
                        t:Cancel(); pendingTicker = nil
                        -- 排版稳定后判空一次
                        EvaluateAutoHide()
                        -- 宽度为 DockUI 的唯一权威，这里只“请求父容器重算”。
                        if ADT and ADT.CommandDock and ADT.CommandDock.SettingsPanel then
                            local main = ADT.CommandDock.SettingsPanel
                            if main.UpdateAutoWidth then main:UpdateAutoWidth() end
                        end
                    end
                end)
            end

            -- 提供给外部的统一触发入口：以方法形式挂到 sub 本体，避免全局重复实现。
            sub._ADT_RequestAutoResize = function()
                -- 移除“必须已可见才能自适应”的限制，
                -- 以便在被误隐藏后也能通过内容变化自动恢复显示。
                RequestAutoResize()
            end

            -- 宽度需求上报：返回“在不换行前提下正文所需的中心区域宽度”。
            -- 注意：不直接设宽；DockUI.UpdateAutoWidth 作为唯一裁决者。
            do
                local meter
                local function ensureMeter()
                    if not meter then
                        meter = sub:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        meter:Hide()
                    end
                    return meter
                end

                local function measureFS(fs)
                    if not (fs and fs.GetText) then return 0 end
                    local text = fs:GetText() or ""
                    if text == "" then return 0 end
                    local m = ensureMeter()
                    -- 尝试复制字体
                    if fs.GetFont then
                        local file, h, flags = fs:GetFont()
                        if file and h then m:SetFont(file, h, flags) end
                    elseif fs.GetFontObject and fs:GetFontObject() then
                        m:SetFontObject(fs:GetFontObject())
                    end
                    m:SetText(text)
                    local w = m:GetStringWidth() or 0
                    return math.ceil(w)
                end

                local function isRightAnchored(region)
                    if not (region and region.GetNumPoints) then return false end
                    local n = region:GetNumPoints() or 0
                    for i=1,n do
                        local p = region:GetPoint(i)
                        if type(p) == 'string' and p:find("RIGHT") then return true end
                    end
                    return false
                end

                function sub:GetDesiredCenterWidth()
                    if not (self and self.Content) then return 0 end
                    local content = self.Content
                    local maxRow, headerW = 0, 0

                    -- Header 文本（若存在且可见）
                    if self.Header and self.Header.Label and (self.Header.Label:IsShown() or true) then
                        headerW = measureFS(self.Header.Label) or 0
                    end

                    local GAP = 10
                    for _, row in ipairs({content:GetChildren()}) do
                        if row and row ~= self.Header then
                            local leftMax, rightSum, anyFS = 0, 0, false
                            -- 仅测 FontString，其他控件（如 Key 按钮）通常自带文本区域，以其 FontString 为准
                            if row.GetRegions then
                                for _, r in ipairs({row:GetRegions()}) do
                                    if r and r.GetObjectType and r:GetObjectType() == "FontString" then
                                        anyFS = true
                                        local w = measureFS(r)
                                        if isRightAnchored(r) then
                                            rightSum = rightSum + w
                                        else
                                            if w > leftMax then leftMax = w end
                                        end
                                    end
                                end
                            end

                            local rowW
                            if anyFS and rightSum > 0 and leftMax > 0 then
                                rowW = leftMax + GAP + rightSum
                            elseif anyFS then
                                rowW = math.max(leftMax, rightSum)
                            else
                                -- 兜底：没有可测文本时，不以“容器当前宽度”反推，避免与父容器形成正反馈导致无限增宽。
                                -- 此类行（纯分隔/纯图形）对“无换行宽度”的决策应为 0。
                                rowW = 0
                            end
                            if type(rowW) == 'number' and rowW > maxRow then maxRow = rowW end
                        end
                    end

                    local pad = (GetRightPadding and GetRightPadding()) or 0
                    local safe = 16 -- 轻微安全边
                    local want = math.max(headerW, maxRow) + pad + safe
                    -- 保护：避免把不合理的大值（例如异常字体测量）一路放大到接近屏幕宽
                    local parent = (self:GetParent() or UIParent)
                    local viewport = (parent and parent.GetWidth and parent:GetWidth()) or 1600
                    local capRatio = 0.8
                    if ADT and ADT.GetHousingCFG then
                        local C = ADT.GetHousingCFG()
                        if C and C.Layout and type(C.Layout.subPanelMaxViewportRatio) == 'number' then
                            capRatio = C.Layout.subPanelMaxViewportRatio
                        end
                    end
                    if type(capRatio) ~= 'number' or capRatio <= 0 or capRatio > 1 then capRatio = 0.8 end
                    local hardCap = math.floor(viewport * capRatio)
                    if want > hardCap then want = hardCap end
                    want = math.max(0, math.floor(want + 0.5))
                    return want
                end
            end

            -- 尺寸/可见性变动时触发一次
            sub:HookScript("OnShow", function()
                RequestAutoResize()
                -- 次帧再判一次，覆盖“先显示后刷新”的时序
                C_Timer.After(0.05, EvaluateAutoHide)
            end)
            if sub.Content.HookScript then
                sub.Content:HookScript("OnSizeChanged", function() RequestAutoResize() end)
            end
            
            -- 对外暴露：允许业务侧在特殊时点主动触发判空
            ADT.DockUI.EvaluateSubPanelAutoHide = EvaluateAutoHide
        end
        sub:Hide()
        return sub
    end

    function main:SetSubPanelShown(shown)
        if not self.SubPanel then return end
        self.SubPanel:SetShown(shown)
    end

    function main:SetSubPanelHeight(height)
        if not self.SubPanel then return end
        self.SubPanel:SetHeight(tonumber(height) or 192)
    end

    main.__SubPanelAttached = true
end

-- 将方法挂载到 Dock 主面板
AttachTo(ADT.CommandDock and ADT.CommandDock.SettingsPanel)

-- 对外：提供统一的 Header 文本设置入口，避免分散直接访问
ADT.DockUI = ADT.DockUI or {}
-- 注意：为规避某些运行环境对 "function A.B.C(...)" 语法的解析异常，这里采用赋值式匿名函数。
ADT.DockUI.SetSubPanelHeaderText = function(text)
    local main = ADT.CommandDock and ADT.CommandDock.SettingsPanel
    if not (main and main.EnsureSubPanel) then return end
    local sub = main:EnsureSubPanel()
    if not (sub and sub.Header and sub.Header.Label) then return end
    sub.Header:SetText(text or "")
    if text and text ~= "" then sub.Header.Label:Show() end
end

ADT.DockUI.SetSubPanelHeaderAlpha = function(alpha)
    local main = ADT.CommandDock and ADT.CommandDock.SettingsPanel
    if not (main and main.SubPanel and main.SubPanel.Header and main.SubPanel.Header.Label) then return end
    local label = main.SubPanel.Header.Label
    local a = tonumber(alpha) or 0
    a = math.max(0, math.min(1, a))
    label:SetAlpha(a)
    if a <= 0.001 then label:Hide() else label:Show() end
end

-- 统一：是否让 Header Alpha 跟随 HoverHUD 的 DisplayFrame OnUpdate
local _follow = true
function ADT.DockUI.SetHeaderAlphaFollow(state)
    _follow = not not state
    if _follow then
        -- 取消任何正在运行的 Header 专用淡入/淡出，以避免与“悬停跟随”双源竞争
        local main = ADT.CommandDock and ADT.CommandDock.SettingsPanel
        if main and main.SubPanel and main.SubPanel.Header then
            local f = main.SubPanel.Header._ADT_HeaderFader
            if f and f.SetScript then f:SetScript("OnUpdate", nil) end
        end
    end
end
function ADT.DockUI.IsHeaderAlphaFollowEnabled() return _follow end

-- 供“选中场景”使用的 Header 专用 fader（仍然使用 HoverHUD 的 FadeMixin，以保持节奏一致）
local function EnsureHeaderFader()
    local main = ADT.CommandDock and ADT.CommandDock.SettingsPanel
    if not (main and main.SubPanel and main.SubPanel.Header and main.SubPanel.Header.Label) then return nil end
    local header = main.SubPanel.Header
    if not header._ADT_HeaderFader then
        local f = CreateFrame("Frame", nil, header)
        f.target = header.Label
        function f:SetAlpha(a)
            self.alpha = a or 0
            if self.target and self.target.SetAlpha then self.target:SetAlpha(self.alpha) end
        end
        function f:GetAlpha()
            if self.target and self.target.GetAlpha then return self.target:GetAlpha() end
            return self.alpha or 0
        end
        if ADT.Housing and ADT.Housing.FadeMixin then
            Mixin(f, ADT.Housing.FadeMixin)
        end
        header._ADT_HeaderFader = f
    end
    return header._ADT_HeaderFader
end

-- Header 淡入：若 fromCurrent 为 true，则从当前 Alpha 继续补完，不重置到 0。
function ADT.DockUI.FadeInHeader(fromCurrent)
    local f = EnsureHeaderFader(); if not f then return end
    _follow = false
    if not fromCurrent and f.SetAlpha then f:SetAlpha(0) end
    if f.FadeIn then f:FadeIn() end
end

-- 语义化别名：用于“同名切换时补完淡入”，避免重复播放动画
function ADT.DockUI.FinishHeaderFadeIn()
    return ADT.DockUI.FadeInHeader(true)
end

function ADT.DockUI.FadeOutHeader(delay)
    local f = EnsureHeaderFader(); if not f then return end
    _follow = false
    if f.FadeOut then f:FadeOut(tonumber(delay) or 0.5) end
end

-- 只读：获取当前 Header 文本与 Alpha，供上层判重/智能节流
function ADT.DockUI.GetSubPanelHeaderText()
    local main = ADT.CommandDock and ADT.CommandDock.SettingsPanel
    if not (main and main.SubPanel and main.SubPanel.Header and main.SubPanel.Header.Label) then return nil end
    return main.SubPanel.Header.Label:GetText()
end

function ADT.DockUI.GetSubPanelHeaderAlpha()
    local main = ADT.CommandDock and ADT.CommandDock.SettingsPanel
    if not (main and main.SubPanel and main.SubPanel.Header and main.SubPanel.Header.Label) then return 0 end
    local a = main.SubPanel.Header.Label:GetAlpha()
    if type(a) ~= 'number' then return 0 end
    return a
end
