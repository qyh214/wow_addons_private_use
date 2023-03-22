local W, F, E, L = unpack((select(2, ...)))
local S = W.Modules.Skins
local ES = E.Skins

local _G = _G
local hooksecurefunc = hooksecurefunc
local pairs = pairs

local CreateFrame = CreateFrame

local UIDROPDOWNMENU_MAXLEVELS = UIDROPDOWNMENU_MAXLEVELS

function S:Blizzard_DeathRecap()
    self:CreateBackdropShadow(_G.DeathRecapFrame)
end

function S:SkinSkipButton(frame)
    if frame and frame.CloseDialog then
        self:CreateShadow(frame.CloseDialog)
    end
end

function S:BlizzardMiscFrames()
    if not self:CheckDB("misc") then
        return
    end

    self:CreateShadow(_G.GameMenuFrame)
    self:CreateShadow(_G.AutoCompleteBox)

    -- 跳过剧情
    self:SecureHook("CinematicFrame_OnDisplaySizeChanged", "SkinSkipButton")
    self:SecureHook("MovieFrame_PlayMovie", "SkinSkipButton")

    -- 聊天菜单
    local chatMenus = {"ChatMenu", "EmoteMenu", "LanguageMenu", "VoiceMacroMenu"}

    for _, menu in pairs(chatMenus) do
        self:SecureHookScript(_G[menu], "OnShow", "CreateShadow")
    end

    -- 下拉菜单
    for i = 1, UIDROPDOWNMENU_MAXLEVELS, 1 do
        local f = _G["DropDownList" .. i .. "Backdrop"]
        self:CreateShadow(f)

        f = _G["DropDownList" .. i .. "MenuBackdrop"]
        self:CreateShadow(f)
    end

    -- 错误提示
    if _G.UIErrorsFrame then
        F.SetFontWithDB(_G.UIErrorsFrame, E.private.WT.skins.errorMessage)
    end

    if _G.ActionStatus.Text then
        F.SetFontWithDB(_G.ActionStatus.Text, E.private.WT.skins.errorMessage)
    end

    -- 灵魂医者传送按钮
    self:CreateShadow(_G.GhostFrameContentsFrame)

    -- 跳过剧情
    self:CreateShadow(_G.CinematicFrameCloseDialog)

    -- 举报玩家
    local reportFrameShadowContainer = CreateFrame("Frame", nil, _G.ReportFrame)
    reportFrameShadowContainer:SetAllPoints(_G.ReportFrame)
    self:CreateShadow(reportFrameShadowContainer)

    -- 分离物品
    self:CreateShadow(_G.StackSplitFrame)

    -- 聊天设定
    self:CreateShadow(_G.ChatConfigFrame)

    -- 颜色选择器
    self:CreateShadow(_G.ColorPickerFrame)

    -- UIWidget
    self:SecureHook(
        ES,
        "SkinStatusBarWidget",
        function(_, widgetFrame)
            if widgetFrame.Label then
                F.SetFontOutline(widgetFrame.Label)
            end
            if widgetFrame.Bar then
                self:CreateBackdropShadow(widgetFrame.Bar)
                if widgetFrame.Bar.Label then
                    F.SetFontOutline(widgetFrame.Bar.Label)
                end
            end
        end
    )

    self:SecureHook(
        _G.UIWidgetTemplateStatusBarMixin,
        "Setup",
        function(widget)
            local forbidden = widget:IsForbidden()
            local bar = widget.Bar
            local id = widget.widgetSetID

            if forbidden or id == 283 or not bar or not bar.backdrop then
                return
            end

            self:CreateBackdropShadow(bar)

            if widget.Label then
                F.SetFontOutline(widget.Label)
            end

            if bar.Label then
                F.SetFontOutline(bar.Label)
            end

            if widget.isJailersTowerBar and self:CheckDB(nil, "scenario") then
                bar:SetWidth(234)
            end
        end
    )

    self:SecureHook(
        _G.UIWidgetTemplateCaptureBarMixin,
        "Setup",
        function(widget)
            local bar = widget.Bar
            if bar then
                self:CreateBackdropShadow(bar)
            end
        end
    )

    self:RawHook(
        ES,
        "SkinTextWithStateWidget",
        function(_, widgetFrame)
            local text = widgetFrame.Text
            if not text then
                return
            end
            F.SetFontOutline(text)
        end,
        true
    )

    if _G.UIWidgetTemplateTextWithState then
        hooksecurefunc(
            _G.UIWidgetTemplateTextWithState,
            "Setup",
            function(widget)
                ES:SkinTextWithStateWidget(widget)
            end
        )
    end

    -- Icon Selection Frames (After ElvUI Skin)
    self:SecureHook(
        ES,
        "HandleIconSelectionFrame",
        function(_, frame)
            self:CreateShadow(frame)
        end
    )

    -- Battle.net
    self:CreateShadow(_G.BattleTagInviteFrame)
end

S:AddCallback("BlizzardMiscFrames")
S:AddCallbackForAddon("Blizzard_DeathRecap")
