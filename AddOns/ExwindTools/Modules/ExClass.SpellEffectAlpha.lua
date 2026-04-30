-- =============================================================
-- [[ 法术触发透明度 ]]
-- { Key = "ExClass.SpellEffectAlpha", Name = "法术触发透明度", Desc = "根据当前专精自动调整法术触发（法术激活叠加）的透明度。", Category = 5 },
-- =============================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })
local EXState = ExwindTools.State

-- =============================================================
-- 第一部分：模块标识与载入检查
-- =============================================================
local EXWIND_MODULE_KEY = "ExClass.SpellEffectAlpha"

if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

-- =============================================================
-- 第二部分：依赖与数据初始化
-- =============================================================
local EXDB = _G.EXDB
if not EXDB then return end

local EXWIND_DEFAULTS = {
    enabled = true,
    globalDefault = 100,
    specs = {
        [250] = 100,
        [251] = 100,
        [252] = 100, -- 死亡骑士
        [71] = 100,
        [72] = 100,
        [73] = 100, -- 战士
        [65] = 100,
        [66] = 100,
        [70] = 100, -- 圣骑士
        [253] = 100,
        [254] = 100,
        [255] = 100, -- 猎人
        [262] = 100,
        [263] = 100,
        [264] = 100, -- 萨满
        [1467] = 100,
        [1468] = 100,
        [1473] = 100, -- 龙人
        [577] = 100,
        [581] = 100,
        [1480] = 100, -- 恶魔猎手
        [259] = 100,
        [260] = 100,
        [261] = 100, -- 潜行者
        [268] = 100,
        [269] = 100,
        [270] = 100, -- 武僧
        [102] = 100,
        [103] = 100,
        [104] = 100,
        [105] = 100, -- 德鲁伊
        [62] = 100,
        [63] = 100,
        [64] = 100, -- 法师
        [265] = 100,
        [266] = 100,
        [267] = 100, -- 术士
        [256] = 100,
        [257] = 100,
        [258] = 100, -- 牧师
    },

    globalScale = 1.0,
    offsetX = 0,
    sideSpacing = 0,
    vertSpacing = 0,
    offsetY = 0,
    pulseMagnitude = 100,
    pulseSpeed = 100,
    overlayScale = 1.0,
    fadeSpeed = 100,
    fadeOutSpeed = 100,
    testTextureFileID = 1027133,
    testTopTextureFileID = 656728,
    advancedEnabled = false,
}
local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EXWIND_DEFAULTS)
local ADVANCED_RUNTIME_ENABLED = EX_DB.advancedEnabled ~= false

-- =============================================================
-- 第三部分：业务逻辑
-- =============================================================
local function ApplyEffectAlpha()
    if not EX_DB.enabled then return end

    local state = EXState
    local specID = state.SpecID
    if not specID or specID == 0 then return end

    local val = EX_DB.specs[specID] or EX_DB.globalDefault or 30
    local finalVal = math.max(0, math.min(100, val)) / 100
    SetCVar("spellActivationOverlayOpacity", finalVal)
    SetCVar("displaySpellActivationOverlays", finalVal > 0 and 1 or 0)
end

-- ===================== 物理布局逻辑 =====================
local SL = Enum and Enum.ScreenLocationType or {}
local POS = {
    Center = SL.Center or 0,
    Left = SL.Left or 1,
    Right = SL.Right or 2,
    Top = SL.Top or 3,
    Bottom = SL.Bottom or 4,
    TopLeft = SL.TopLeft or 5,
    TopRight = SL.TopRight or 6,
    LeftOutside = SL.LeftOutside or 7,
    RightOutside = SL.RightOutside or 8,
}

local function ToNumber(v, fallback)
    local n = tonumber(v)
    if n == nil then
        return fallback
    end
    return n
end

local function ParseFileID(v, fallback)
    local n = tonumber(v)
    if not n or n <= 0 then
        return fallback
    end
    return math.floor(n)
end


local OVERLAY_IDS_TOP = {
    449487, 450916, 450923, 450926, 450927, 450930, 457658, 459314, 463452, 467696, 469752,
    510822, 627609, 801266, 1028136, 1028137, 1028138, 1028139, 2851788, 4699057, 6160020, 7549806,
}

local OVERLAY_IDS_LEFT_RIGHT = {
    449486, 449487, 449490, 449491, 449492, 449493, 450913, 450917, 450919, 450920, 450925, 450929, 450932,
    510823, 511104, 592058, 656728, 774420, 801267, 962497, 1027131, 1027132, 1027133, 1028091, 1028092,
    1029138, 1029139, 1030393, 2888300, 7549744,
}

local function RegisterEscCloseFrame(name)
    _G.UISpecialFrames = _G.UISpecialFrames or {}
    for i = 1, #_G.UISpecialFrames do
        if _G.UISpecialFrames[i] == name then
            return
        end
    end
    table.insert(_G.UISpecialFrames, name)
end

local OverlayPickerFrame
local function EnsureOverlayPickerFrame()
    if OverlayPickerFrame then
        return OverlayPickerFrame
    end

    local frame = CreateFrame("Frame", "ExwindToolsSpellOverlayPickerFrame", UIParent, "BackdropTemplate")
    frame:SetSize(760, 560)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetToplevel(true)
    frame:SetFrameLevel(200)
    frame:SetClampedToScreen(false)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0, 0, 0, 1)
    frame:Hide()

    RegisterEscCloseFrame("ExwindToolsSpellOverlayPickerFrame")

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -14)
    title:SetText(L["法术触发贴图选择器"])
    frame.title = title

    local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    subtitle:SetText(L["点击任意图块即可写入配置并立即触发测试。"])
    frame.subtitle = subtitle

    local searchLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    searchLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -52)
    searchLabel:SetText(L["过滤ID"])

    local searchBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    searchBox:SetSize(220, 24)
    searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 8, 0)
    searchBox:SetAutoFocus(false)
    searchBox:SetNumeric(false)
    searchBox:SetMaxLetters(20)
    searchBox:SetFrameStrata("FULLSCREEN_DIALOG")
    searchBox:SetFrameLevel(frame:GetFrameLevel() + 20)
    frame.searchBox = searchBox

    local infoText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    infoText:SetPoint("LEFT", searchBox, "RIGHT", 12, 0)
    infoText:SetText("")
    frame.infoText = infoText

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -78)
    scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -34, 46)
    frame.scroll = scroll

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)
    frame.content = content
    frame.buttons = {}

    local closeBottom = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBottom:SetSize(120, 24)
    closeBottom:SetPoint("BOTTOM", frame, "BOTTOM", 0, 12)
    closeBottom:SetText(L["关闭"])
    closeBottom:SetScript("OnClick", function()
        frame:Hide()
    end)
    frame.closeBottom = closeBottom

    OverlayPickerFrame = frame
    return frame
end

local function RenderOverlayPicker()
    local frame = OverlayPickerFrame
    if not frame or not frame.ids then return end

    local query = ""
    if frame.searchBox and frame.searchBox.GetText then
        query = (frame.searchBox:GetText() or ""):gsub("%s+", "")
    end

    local filtered = {}
    for i = 1, #frame.ids do
        local id = frame.ids[i]
        if query == "" or tostring(id):find(query, 1, true) then
            filtered[#filtered + 1] = id
        end
    end

    local cols = 6
    local cellW = 116
    local cellH = 94
    local iconSize = 58

    for i = 1, #filtered do
        local id = filtered[i]
        local btn = frame.buttons[i]
        if not btn then
            btn = CreateFrame("Button", nil, frame.content, "BackdropTemplate")
            btn:SetSize(cellW - 8, cellH - 8)
            btn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                tile = false,
                edgeSize = 1,
            })
            btn.icon = btn:CreateTexture(nil, "ARTWORK")
            btn.icon:SetSize(iconSize, iconSize)
            btn.icon:SetPoint("TOP", 0, -6)
            btn.icon:SetTexCoord(0, 1, 0, 1)
            btn.idText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            btn.idText:SetPoint("BOTTOM", 0, 6)
            btn.idText:SetJustifyH("CENTER")
            frame.buttons[i] = btn
        end

        btn.textureID = id
        btn.icon:SetTexture(id)
        btn.idText:SetText(tostring(id))
        btn:Show()

        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", frame.content, "TOPLEFT", col * cellW, -row * cellH)

        if ParseFileID(EX_DB[frame.targetKey], 0) == id then
            btn:SetBackdropColor(0.12, 0.25, 0.12, 0.95)
            btn:SetBackdropBorderColor(0.15, 0.95, 0.2, 1)
        else
            btn:SetBackdropColor(0.08, 0.08, 0.1, 0.88)
            btn:SetBackdropBorderColor(0.32, 0.32, 0.36, 1)
        end

        btn:SetScript("OnClick", function(self)
            EX_DB[frame.targetKey] = self.textureID
            ExwindTools:UpdateState(EXWIND_MODULE_KEY .. ".DatabaseChanged",
                { key = frame.targetKey, value = self.textureID, ts = GetTime() })
            ExwindTools:UpdateState(EXWIND_MODULE_KEY .. ".ButtonClicked", { key = "btn_test", ts = GetTime() })
            RenderOverlayPicker()
        end)

        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["OverlayFileDataID: "] .. tostring(self.textureID), 1, 0.82, 0)
            GameTooltip:AddLine(L["点击后立即写入并触发测试"], 0.7, 0.9, 1)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    for i = #filtered + 1, #frame.buttons do
        frame.buttons[i]:Hide()
    end

    local rows = math.max(1, math.ceil(#filtered / cols))
    frame.content:SetSize(cols * cellW, rows * cellH + 8)
    frame.infoText:SetText(string.format(L["候选: %d / %d"], #filtered, #frame.ids))
end

local function OpenOverlayPicker(targetKey, titleText, ids)
    local frame = EnsureOverlayPickerFrame()
    frame.targetKey = targetKey
    frame.ids = ids
    frame.title:SetText(titleText or L["法术触发贴图选择器"])
    frame.searchBox:SetText("")
    frame.searchBox:SetScript("OnTextChanged", function()
        RenderOverlayPicker()
    end)
    frame.searchBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    frame.searchBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    frame:Show()
    RenderOverlayPicker()
end

local TEST_BASE_SIZE_SCALE = 0.8
local TEST_LONG_SIDE = 256 * TEST_BASE_SIZE_SCALE
local TEST_SHORT_SIDE = 128 * TEST_BASE_SIZE_SCALE

local TEST_SLOT_DEFS = {
    { key = "Left",  position = POS.Left,  point = "RIGHT",  relPoint = "LEFT",  x = 0, y = 0, w = TEST_SHORT_SIDE, h = TEST_LONG_SIDE },
    { key = "Right", position = POS.Right, point = "LEFT",   relPoint = "RIGHT", x = 0, y = 0, w = TEST_SHORT_SIDE, h = TEST_LONG_SIDE,  hFlip = true },
    { key = "Top",   position = POS.Top,   point = "BOTTOM", relPoint = "TOP",   x = 0, y = 0, w = TEST_LONG_SIDE,  h = TEST_SHORT_SIDE, useTopTexture = true },
}

local TEST_STATE = {
    running = false,
    root = nil,
    anchor = nil,
    slots = {},
}

local GetLayoutCfg
local ApplyOffsetByPosition
local UpdateOverlayTestVisual

local function TryHideOverlayTestRoot()
    if TEST_STATE.running or not TEST_STATE.root then
        return
    end

    for _, slot in pairs(TEST_STATE.slots) do
        if slot:IsShown() or (slot.animOut and slot.animOut:IsPlaying()) then
            return
        end
    end

    TEST_STATE.root:Hide()
end

local function GetOrCreateOverlayTestRoot()
    if TEST_STATE.root then
        return TEST_STATE.root
    end

    local root = CreateFrame("Frame", "ExwindToolsOverlayTestFrame", UIParent)
    root:SetAllPoints(UIParent)
    root:SetFrameStrata("FULLSCREEN_DIALOG")
    root:SetFrameLevel(20)
    root:Hide()

    local anchor = CreateFrame("Frame", nil, root)
    anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    anchor:SetSize(TEST_LONG_SIDE, TEST_LONG_SIDE)

    TEST_STATE.root = root
    TEST_STATE.anchor = anchor
    TEST_STATE.slots = {}
    return root
end

local function BuildOverlayTestSlot(def)
    local slot = CreateFrame("Frame", nil, TEST_STATE.anchor)
    slot:SetSize(def.w, def.h)
    slot:Hide()

    local tex = slot:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(slot)
    slot.texture = tex

    slot.animIn = slot:CreateAnimationGroup()
    local animInAlpha = slot.animIn:CreateAnimation("Alpha")
    animInAlpha:SetFromAlpha(0)
    animInAlpha:SetToAlpha(1)
    animInAlpha:SetDuration(0.2)
    slot.animInAlpha = animInAlpha

    slot.animIn:SetScript("OnPlay", function(self)
        self:GetParent():SetAlpha(0)
    end)
    slot.animIn:SetScript("OnFinished", function(self)
        local overlay = self:GetParent()
        overlay:SetAlpha(1)
        if TEST_STATE.running and overlay._pulseEnabled then
            overlay.pulse:Play()
        end
    end)

    slot.animOut = slot:CreateAnimationGroup()
    local animOutAlpha = slot.animOut:CreateAnimation("Alpha")
    animOutAlpha:SetFromAlpha(1)
    animOutAlpha:SetToAlpha(0)
    animOutAlpha:SetDuration(0.1)
    slot.animOutAlpha = animOutAlpha

    slot.animOut:SetScript("OnFinished", function(self)
        local overlay = self:GetParent()
        overlay.pulse:Stop()
        overlay:SetAlpha(0)
        overlay:Hide()
        TryHideOverlayTestRoot()
    end)

    slot.pulse = slot:CreateAnimationGroup()
    slot.pulse:SetLooping("REPEAT")
    local pulseA = slot.pulse:CreateAnimation("Scale")
    pulseA:SetScale(1.08, 1.08)
    pulseA:SetDuration(0.5)
    pulseA:SetSmoothing("IN_OUT")
    pulseA:SetOrder(1)
    slot.pulseA = pulseA

    local pulseB = slot.pulse:CreateAnimation("Scale")
    pulseB:SetScale(0.9259, 0.9259)
    pulseB:SetDuration(0.5)
    pulseB:SetSmoothing("IN_OUT")
    pulseB:SetOrder(2)
    slot.pulseB = pulseB

    slot:SetScript("OnHide", function(self)
        self.animIn:Stop()
        self.animOut:Stop()
        self.pulse:Stop()
    end)

    TEST_STATE.slots[def.key] = slot
    return slot
end

local function ResolveOverlayTestSlot(def)
    local slot = TEST_STATE.slots[def.key]
    if slot then
        return slot
    end
    return BuildOverlayTestSlot(def)
end

local function SetSlotTexCoord(texture, hFlip, vFlip)
    local left, right, top, bottom = 0, 1, 0, 1
    if vFlip then
        top, bottom = 1, 0
    end
    if hFlip then
        left, right = 1, 0
    end
    texture:SetTexCoord(left, right, top, bottom)
end

local function ApplyOverlayTestSlotAnim(slot, cfg)
    if slot.animInAlpha then
        slot.animInAlpha:SetDuration(0.2 / (cfg.fadeSpeed / 100))
    end
    if slot.animOutAlpha then
        slot.animOutAlpha:SetDuration(0.1 / (cfg.fadeOutSpeed / 100))
    end

    if not (slot.pulseA and slot.pulseB) then
        return
    end

    local pulseDur = 0.5 / (cfg.pulseSpeed / 100)
    slot.pulseA:SetDuration(pulseDur)
    slot.pulseB:SetDuration(pulseDur)

    if cfg.pulseMagnitude <= 0 then
        slot._pulseEnabled = false
        slot.pulseA:SetScale(1.0, 1.0)
        slot.pulseB:SetScale(1.0, 1.0)
        slot.pulse:Stop()
        return
    end

    local amp = cfg.pulseMagnitude / 100
    slot.pulseA:SetScale(1.0 + (0.08 * amp), 1.0 + (0.08 * amp))
    slot.pulseB:SetScale(1.0 - (0.0741 * amp), 1.0 - (0.0741 * amp))
    slot._pulseEnabled = true

    if TEST_STATE.running and slot:IsShown() and not slot.animIn:IsPlaying() and not slot.pulse:IsPlaying() then
        slot.pulse:Play()
    end
end

local function ApplyOverlayTestSlotLayout(slot, def, cfg)
    slot:SetSize(def.w * cfg.overlayScale, def.h * cfg.overlayScale)
    local x, y = ApplyOffsetByPosition(def.position, def.x, def.y, cfg.sideSpacing, cfg.vertSpacing)
    slot:ClearAllPoints()
    slot:SetPoint(def.point, TEST_STATE.anchor, def.relPoint, x, y)
end

UpdateOverlayTestVisual = function()
    if not ADVANCED_RUNTIME_ENABLED then
        return
    end

    local root = TEST_STATE.root
    if not root then
        return
    end

    local cfg = GetLayoutCfg()
    TEST_STATE.anchor:ClearAllPoints()
    TEST_STATE.anchor:SetPoint("CENTER", UIParent, "CENTER", cfg.offsetX, cfg.offsetY)
    TEST_STATE.anchor:SetSize(TEST_LONG_SIDE, TEST_LONG_SIDE)
    TEST_STATE.anchor:SetScale(cfg.globalScale)

    local lrTex = ParseFileID(EX_DB.testTextureFileID, 1027133)
    local tbTex = ParseFileID(EX_DB.testTopTextureFileID, lrTex)

    for i = 1, #TEST_SLOT_DEFS do
        local def = TEST_SLOT_DEFS[i]
        local slot = ResolveOverlayTestSlot(def)
        local texID = def.useTopTexture and tbTex or lrTex
        slot.texture:SetTexture(texID)
        SetSlotTexCoord(slot.texture, def.hFlip, def.vFlip)
        ApplyOverlayTestSlotLayout(slot, def, cfg)
        ApplyOverlayTestSlotAnim(slot, cfg)
    end

    if TEST_STATE.running then
        root:Show()
    end
end

local function StartOverlayTest()
    if not ADVANCED_RUNTIME_ENABLED then
        return
    end

    GetOrCreateOverlayTestRoot()
    UpdateOverlayTestVisual()

    if TEST_STATE.running then
        return
    end

    TEST_STATE.running = true
    TEST_STATE.root:Show()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

    for i = 1, #TEST_SLOT_DEFS do
        local def = TEST_SLOT_DEFS[i]
        local slot = ResolveOverlayTestSlot(def)
        slot.animOut:Stop()
        slot.pulse:Stop()
        slot.animIn:Stop()
        slot:SetAlpha(0)
        slot:Show()
        slot.animIn:Play()
    end
end

local function StopOverlayTest(silent)
    TEST_STATE.running = false

    if TEST_STATE.root then
        UpdateOverlayTestVisual()
        for _, slot in pairs(TEST_STATE.slots) do
            if slot:IsShown() then
                slot.animIn:Stop()
                slot.pulse:Stop()
                slot.animOut:Stop()
                slot.animOut:Play()
            end
        end
        TryHideOverlayTestRoot()
    end
end

GetLayoutCfg = function()
    return {
        globalScale = math.max(0.1, ToNumber(EX_DB.globalScale, 1.0)),
        offsetX = ToNumber(EX_DB.offsetX, 0),
        offsetY = ToNumber(EX_DB.offsetY, 0),
        sideSpacing = ToNumber(EX_DB.sideSpacing, 0),
        vertSpacing = ToNumber(EX_DB.vertSpacing, 0),
        overlayScale = math.max(0.1, ToNumber(EX_DB.overlayScale, 1.0)),
        pulseMagnitude = math.max(0, ToNumber(EX_DB.pulseMagnitude, 100)),
        pulseSpeed = math.max(10, ToNumber(EX_DB.pulseSpeed, 100)),
        fadeSpeed = math.max(10, ToNumber(EX_DB.fadeSpeed, 100)),
        fadeOutSpeed = math.max(10, ToNumber(EX_DB.fadeOutSpeed, 100)),
    }
end

ApplyOffsetByPosition = function(position, x, y, sideSpacing, vertSpacing)
    if position == POS.Left or position == POS.LeftOutside then
        x = x - sideSpacing
    elseif position == POS.Right or position == POS.RightOutside then
        x = x + sideSpacing
    end

    if position == POS.Top then
        y = y + vertSpacing
    elseif position == POS.Bottom then
        y = y - vertSpacing
    elseif position == POS.TopLeft then
        x = x - sideSpacing
        y = y + vertSpacing
    elseif position == POS.TopRight then
        x = x + sideSpacing
        y = y + vertSpacing
    end

    return x, y
end

local function CaptureOverlayBase(overlay)
    local w, h = overlay:GetSize()
    overlay._baseW = w
    overlay._baseH = h

    local point, relativeTo, relativePoint, x, y = overlay:GetPoint()
    if point then
        overlay._basePoint = point
        overlay._baseRelTo = relativeTo
        overlay._baseRelPoint = relativePoint
        overlay._baseX = x or 0
        overlay._baseY = y or 0
    end
end

local function ApplyOverlayAnimTuning(overlay, cfg)
    if overlay.pulse then
        local pulseA, pulseB = overlay.pulse:GetAnimations()
        if pulseA and pulseB then
            local pulseDur = 0.5 / (cfg.pulseSpeed / 100)
            pulseA:SetDuration(pulseDur)
            pulseB:SetDuration(pulseDur)

            if cfg.pulseMagnitude <= 0 then
                pulseA:SetScale(1.0, 1.0)
                pulseB:SetScale(1.0, 1.0)
                overlay.pulse:Stop()
            else
                local amp = cfg.pulseMagnitude / 100
                local expand = 1.0 + (0.08 * amp)
                local shrink = 1.0 - (0.0741 * amp)
                pulseA:SetScale(expand, expand)
                pulseB:SetScale(shrink, shrink)
            end
        end
    end

    if overlay.animIn then
        local fadeIn = overlay.animIn:GetAnimations()
        if fadeIn then
            fadeIn:SetDuration(0.2 / (cfg.fadeSpeed / 100))
        end
    end

    if overlay.animOut then
        local fadeOut = overlay.animOut:GetAnimations()
        if fadeOut then
            fadeOut:SetDuration(0.1 / (cfg.fadeOutSpeed / 100))
        end
    end
end

local function ApplyOverlayLayout(overlay, position, cfg)
    if overlay._baseW and overlay._baseH then
        overlay:SetSize(overlay._baseW * cfg.overlayScale, overlay._baseH * cfg.overlayScale)
    end

    if overlay._basePoint then
        local x, y = ApplyOffsetByPosition(position, overlay._baseX or 0, overlay._baseY or 0, cfg.sideSpacing,
            cfg.vertSpacing)
        overlay:ClearAllPoints()
        overlay:SetPoint(overlay._basePoint, overlay._baseRelTo, overlay._baseRelPoint, x, y)
    end

    ApplyOverlayAnimTuning(overlay, cfg)
end

local function UpdatePhysicalLayout()
    if not ADVANCED_RUNTIME_ENABLED then
        return
    end

    local frame = _G.SpellActivationOverlayFrame
    if not frame then return end
    local cfg = GetLayoutCfg()

    -- 应用缩放
    frame:SetScale(cfg.globalScale)

    -- 应用整体位置 (水平+垂直偏移)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", cfg.offsetX, cfg.offsetY)

    -- 实时刷新所有当前可见的独立法术特效图案 (让用户拖动滑块时能立即看到效果)
    if frame.overlaysInUse then
        for _, overlayList in pairs(frame.overlaysInUse) do
            for position, overlay in pairs(overlayList) do
                if overlay:IsShown() then
                    ApplyOverlayLayout(overlay, position, cfg)
                end
            end
        end
    end
end

local overlayHookInstalled = false
local function TryInstallOverlayHook()
    if not ADVANCED_RUNTIME_ENABLED then return end
    if overlayHookInstalled then return end

    local frame = _G.SpellActivationOverlayFrame
    if not frame or type(frame.ShowOverlay) ~= "function" then return end

    -- 关键：挂在实例方法，确保命中真实调用点
    hooksecurefunc(frame, "ShowOverlay", function(self, spellID, texturePath, position, scale, r, g, b)
        local overlay = self:GetOverlay(spellID, position)
        if not overlay then return end

        CaptureOverlayBase(overlay)
        ApplyOverlayLayout(overlay, position, GetLayoutCfg())
    end)

    overlayHookInstalled = true
    UpdatePhysicalLayout()
end

TryInstallOverlayHook()
C_Timer.NewTicker(1, function(ticker)
    TryInstallOverlayHook()
    if overlayHookInstalled then
        ticker:Cancel()
    end
end, 20)


-- =============================================================
-- 第四部分：事件与状态订阅
-- =============================================================

-- 提取状态文本生成逻辑
local function GetStatusText()
    local state = EXState
    local classID = state.ClassID
    local specID = state.SpecID

    local classHex = "ffffff"
    local specIcon = 0
    if classID and EXDB.Classes[classID] then
        classHex = EXDB.Classes[classID].colorHex
    end
    if specID and EXDB.SpecByID[specID] then
        specIcon = EXDB.SpecByID[specID].icon
    end

    local iconStr = specIcon > 0 and string.format("|T%d:16:16:0:0|t ", specIcon) or ""
    local curAlpha = GetCVar("spellActivationOverlayOpacity")
    return string.format(L["当前: %s|cff%s%s - %s|r | 系统值: |cffffd100%d%%|r"],
        iconStr, classHex, state.ClassName or L["未知"], state.SpecName or L["未知"], (tonumber(curAlpha) or 0) * 100)
end

-- 监听数据库变动 (用户在 UI 中修改设置)
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(info)
    TryInstallOverlayHook()
    ApplyEffectAlpha()
    UpdatePhysicalLayout()
    UpdateOverlayTestVisual()
    -- [优化] 定向更新 UI 元素，避免全量刷新导致滚动条重置
    if ExwindTools.Grid and ExwindTools.Grid.Widgets then
        local w = ExwindTools.Grid.Widgets["live_status"]
        if w and w.text then -- GridDescription 组件包含 .text
            w.text:SetText(GetStatusText())
        end
    end
end)

-- 监听天赋/职业变动 (核心框架广播)
local function OnIdentityChanged()
    TryInstallOverlayHook()
    EX_RegisterLayout() -- 重新生成布局以更新当前状态文字
    ApplyEffectAlpha()
    UpdateOverlayTestVisual()

    -- 如果主 UI 正在显示当前模块，则强制刷新以更新界面文字 (切换专精时需要全刷新)
    if ExwindTools.UI and ExwindTools.UI.MainFrame and ExwindTools.UI.MainFrame:IsShown() and ExwindTools.UI.CurrentModule == EXWIND_MODULE_KEY then
        ExwindTools.UI:RefreshContent()
    end
end

ExwindTools:WatchState("SpecID", EXWIND_MODULE_KEY, OnIdentityChanged)
ExwindTools:WatchState("ClassName", EXWIND_MODULE_KEY, OnIdentityChanged)
ExwindTools:WatchState("SpecName", EXWIND_MODULE_KEY, OnIdentityChanged)

-- =============================================================
-- 第五部分：测试模式HOOK与按钮事件
-- =============================================================
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end

    if info.key == "btn_pick_lr_tex" then
        OpenOverlayPicker("testTextureFileID", L["选择左右触发贴图"], OVERLAY_IDS_LEFT_RIGHT)
        return
    elseif info.key == "btn_pick_tb_tex" then
        OpenOverlayPicker("testTopTextureFileID", L["选择上下触发贴图"], OVERLAY_IDS_TOP)
        return
    elseif info.key == "btn_test_stop" then
        StopOverlayTest(false)
        return
    end

    if info.key == "btn_test" then
        StartOverlayTest()
    end
end)

-- =============================================================
-- 第六部分：初始化与模块报告
-- =============================================================
C_Timer.After(2, function()
    TryInstallOverlayHook()
    ApplyEffectAlpha()
    UpdatePhysicalLayout()
end)

ExwindTools:ReportReady(EXWIND_MODULE_KEY)

-- =============================================================
-- 第六部分：Grid 布局
-- =============================================================
function EX_RegisterLayout()
    local currentInfo = GetStatusText()

    local function MakeSpecLabel(icon, colorHex, specName)
        return string.format("|T%d:16:16:0:0|t |cff%s%s|r", icon, colorHex, L[specName])
    end

    local layout = {
        { key = "header", type = "header", x = 2, y = 1, w = 50, h = 3, label = L["法术触发透明度 (SpellActivationOverlay)"], labelSize = 25 },
        { key = "desc", type = "description", x = 2, y = 4, w = 30, h = 2, label = L["根据当前专精自动调整屏幕中心法术触发特效的透明度。"] },
        { key = "live_status", type = "description", x = 2, y = 6, w = 30, h = 2, label = GetStatusText() },
        { key = "ctrl_header", type = "subheader", x = 2, y = 78, w = 49, h = 2, label = L["法术触发特效调整"], labelSize = 22 },
        { key = "enabled", type = "checkbox", x = 2, y = 11, w = 12, h = 3, label = L["开启功能"] },
        { key = "globalDefault", type = "slider", x = 25, y = 11, w = 16, h = 3, label = L["全局默认透明度 (%)"], min = 0, max = 100, labelPos = "left" },
        { key = "h_板甲职业", type = "subheader", x = 2, y = 18, w = 50, h = 1, label = L["板甲职业"] },
        { key = "250", type = "slider", x = 2, y = 22, w = 16, h = 2, label = MakeSpecLabel(135770, "ff2628", "鲜血"), min = 0, max = 100, parentKey = "specs" },
        { key = "251", type = "slider", x = 18, y = 22, w = 16, h = 2, label = MakeSpecLabel(135773, "ff2628", "冰霜"), min = 0, max = 100, parentKey = "specs" },
        { key = "252", type = "slider", x = 34, y = 22, w = 16, h = 2, label = MakeSpecLabel(135775, "ff2628", "邪恶"), min = 0, max = 100, parentKey = "specs" },
        { key = "71", type = "slider", x = 34, y = 25, w = 16, h = 2, label = MakeSpecLabel(132355, "c69b6d", "武器"), min = 0, max = 100, parentKey = "specs" },
        { key = "72", type = "slider", x = 18, y = 25, w = 16, h = 2, label = MakeSpecLabel(132347, "c69b6d", "狂怒"), min = 0, max = 100, parentKey = "specs" },
        { key = "73", type = "slider", x = 2, y = 25, w = 16, h = 2, label = MakeSpecLabel(132341, "c69b6d", "防护"), min = 0, max = 100, parentKey = "specs" },
        { key = "65", type = "slider", x = 34, y = 28, w = 16, h = 2, label = MakeSpecLabel(135920, "f48cba", "神圣"), min = 0, max = 100, parentKey = "specs" },
        { key = "66", type = "slider", x = 2, y = 28, w = 16, h = 2, label = MakeSpecLabel(236264, "f48cba", "防护"), min = 0, max = 100, parentKey = "specs" },
        { key = "70", type = "slider", x = 18, y = 28, w = 16, h = 2, label = MakeSpecLabel(135873, "f48cba", "惩戒"), min = 0, max = 100, parentKey = "specs" },
        { key = "h_锁甲职业", type = "subheader", x = 2, y = 33, w = 50, h = 1, label = L["锁甲职业"] },
        { key = "253", type = "slider", x = 34, y = 37, w = 16, h = 2, label = MakeSpecLabel(461112, "aad372", "野兽控制"), min = 0, max = 100, parentKey = "specs" },
        { key = "254", type = "slider", x = 18, y = 37, w = 16, h = 2, label = MakeSpecLabel(236179, "aad372", "射击"), min = 0, max = 100, parentKey = "specs" },
        { key = "255", type = "slider", x = 2, y = 37, w = 16, h = 2, label = MakeSpecLabel(461113, "aad372", "生存"), min = 0, max = 100, parentKey = "specs" },
        { key = "262", type = "slider", x = 2, y = 40, w = 16, h = 2, label = MakeSpecLabel(136048, "0070dd", "元素"), min = 0, max = 100, parentKey = "specs" },
        { key = "263", type = "slider", x = 18, y = 40, w = 16, h = 2, label = MakeSpecLabel(237581, "0070dd", "增强"), min = 0, max = 100, parentKey = "specs" },
        { key = "264", type = "slider", x = 34, y = 40, w = 16, h = 2, label = MakeSpecLabel(136052, "0070dd", "恢复"), min = 0, max = 100, parentKey = "specs" },
        { key = "1467", type = "slider", x = 2, y = 43, w = 16, h = 2, label = MakeSpecLabel(4511811, "33937f", "湮灭"), min = 0, max = 100, parentKey = "specs" },
        { key = "1468", type = "slider", x = 34, y = 43, w = 16, h = 2, label = MakeSpecLabel(4511812, "33937f", "恩护"), min = 0, max = 100, parentKey = "specs" },
        { key = "1473", type = "slider", x = 18, y = 43, w = 16, h = 2, label = MakeSpecLabel(5198700, "33937f", "增辉"), min = 0, max = 100, parentKey = "specs" },
        { key = "h_皮甲职业", type = "subheader", x = 2, y = 47, w = 47, h = 1, label = L["皮甲职业"] },
        { key = "577", type = "slider", x = 18, y = 51, w = 16, h = 2, label = MakeSpecLabel(1247264, "a330c9", "浩劫"), min = 0, max = 100, parentKey = "specs" },
        { key = "581", type = "slider", x = 2, y = 51, w = 16, h = 2, label = MakeSpecLabel(1247265, "a330c9", "复仇"), min = 0, max = 100, parentKey = "specs" },
        { key = "1480", type = "slider", x = 34, y = 51, w = 16, h = 2, label = MakeSpecLabel(7455385, "a330c9", "噬灭"), min = 0, max = 100, parentKey = "specs" },
        { key = "259", type = "slider", x = 34, y = 54, w = 16, h = 2, label = MakeSpecLabel(236270, "fff468", "奇袭"), min = 0, max = 100, parentKey = "specs" },
        { key = "260", type = "slider", x = 2, y = 54, w = 16, h = 2, label = MakeSpecLabel(236286, "fff468", "狂徒"), min = 0, max = 100, parentKey = "specs" },
        { key = "261", type = "slider", x = 18, y = 54, w = 16, h = 2, label = MakeSpecLabel(132320, "fff468", "敏锐"), min = 0, max = 100, parentKey = "specs" },
        { key = "268", type = "slider", x = 2, y = 57, w = 16, h = 2, label = MakeSpecLabel(608951, "00ff98", "酒仙"), min = 0, max = 100, parentKey = "specs" },
        { key = "269", type = "slider", x = 18, y = 57, w = 16, h = 2, label = MakeSpecLabel(608953, "00ff98", "踏风"), min = 0, max = 100, parentKey = "specs" },
        { key = "270", type = "slider", x = 34, y = 57, w = 16, h = 2, label = MakeSpecLabel(608952, "00ff98", "织雾"), min = 0, max = 100, parentKey = "specs" },
        { key = "102", type = "slider", x = 26, y = 60, w = 12, h = 2, label = MakeSpecLabel(136096, "ff7c0a", "平衡"), min = 0, max = 100, parentKey = "specs" },
        { key = "103", type = "slider", x = 14, y = 60, w = 12, h = 2, label = MakeSpecLabel(132115, "ff7c0a", "野性"), min = 0, max = 100, parentKey = "specs" },
        { key = "104", type = "slider", x = 2, y = 60, w = 12, h = 2, label = MakeSpecLabel(132276, "ff7c0a", "守护"), min = 0, max = 100, parentKey = "specs" },
        { key = "105", type = "slider", x = 38, y = 60, w = 12, h = 2, label = MakeSpecLabel(136041, "ff7c0a", "恢复"), min = 0, max = 100, parentKey = "specs" },
        { key = "h_布甲职业", type = "subheader", x = 2, y = 65, w = 47, h = 1, label = L["布甲职业"] },
        { key = "62", type = "slider", x = 34, y = 69, w = 16, h = 2, label = MakeSpecLabel(135932, "3fc7eb", "奥术"), min = 0, max = 100, parentKey = "specs" },
        { key = "63", type = "slider", x = 18, y = 69, w = 16, h = 2, label = MakeSpecLabel(135810, "3fc7eb", "火焰"), min = 0, max = 100, parentKey = "specs" },
        { key = "64", type = "slider", x = 2, y = 69, w = 16, h = 2, label = MakeSpecLabel(135846, "3fc7eb", "冰霜"), min = 0, max = 100, parentKey = "specs" },
        { key = "265", type = "slider", x = 18, y = 72, w = 16, h = 2, label = MakeSpecLabel(136145, "8788ee", "痛苦"), min = 0, max = 100, parentKey = "specs" },
        { key = "266", type = "slider", x = 34, y = 72, w = 16, h = 2, label = MakeSpecLabel(136172, "8788ee", "恶魔学识"), min = 0, max = 100, parentKey = "specs" },
        { key = "267", type = "slider", x = 2, y = 72, w = 16, h = 2, label = MakeSpecLabel(136186, "8788ee", "毁灭"), min = 0, max = 100, parentKey = "specs" },
        { key = "256", type = "slider", x = 2, y = 75, w = 16, h = 2, label = MakeSpecLabel(135940, "ffffff", "戒律"), min = 0, max = 100, parentKey = "specs" },
        { key = "257", type = "slider", x = 18, y = 75, w = 16, h = 2, label = MakeSpecLabel(237542, "ffffff", "神圣"), min = 0, max = 100, parentKey = "specs" },
        { key = "258", type = "slider", x = 34, y = 75, w = 16, h = 2, label = MakeSpecLabel(136207, "ffffff", "暗影"), min = 0, max = 100, parentKey = "specs" },
        { key = "divider_1133", type = "divider", x = 1, y = 9, w = 50, h = 1, label = L["新组件"] },
        { key = "divider_8665", type = "divider", x = 2, y = 14, w = 50, h = 1, label = L["新组件"] },
        { key = "divider_9711", type = "divider", x = 2, y = 19, w = 50, h = 1, label = L["新组件"] },
        { key = "divider_1981", type = "divider", x = 2, y = 34, w = 50, h = 1, label = L["新组件"] },
        { key = "divider_3851", type = "divider", x = 2, y = 48, w = 50, h = 1, label = L["新组件"] },
        { key = "divider_5419", type = "divider", x = 2, y = 66, w = 47, h = 1, label = L["新组件"] },
        { key = "advancedEnabled", type = "checkbox", x = 2, y = 81, w = 15, h = 3, label = L["启用 |cffff173b(为了安全! 需重载后生效)|r"], labelSize = 18 },
        { key = "btn_test_stop", type = "button", x = 35, y = 81, w = 15, h = 3, label = L["停止测试"] },
        { key = "btn_test", type = "button", x = 18, y = 81, w = 15, h = 3, label = L["启用测试"], labelSize = 18 },
        { key = "globalScale", type = "slider", x = 2, y = 93, w = 15, h = 2, label = L["整体缩放"], min = 0.4, max = 2.5, step = 0.05, labelPos = "top" },
        { key = "offsetX", type = "slider", x = 34, y = 93, w = 15, h = 2, label = L["整体水平(Y) 偏移"], min = -500, max = 500, labelPos = "top" },
        { key = "offsetY", type = "slider", x = 18, y = 93, w = 15, h = 2, label = L["整体垂直(X)偏移"], min = -500, max = 500, labelPos = "top" },
        { key = "overlayScale", type = "slider", x = 2, y = 97, w = 15, h = 2, label = L["材质特效缩放"], min = 0.5, max = 3, step = 0.05, labelPos = "top" },
        { key = "sideSpacing", type = "slider", x = 18, y = 97, w = 15, h = 2, label = L["左右间距调整"], min = -300, max = 300, labelPos = "top" },
        { key = "vertSpacing", type = "slider", x = 34, y = 97, w = 15, h = 2, label = L["上下间距调整"], min = -300, max = 300, labelPos = "top" },
        { key = "pulseMagnitude", type = "slider", x = 2, y = 101, w = 15, h = 2, label = L["呼吸动画幅度 (0禁用)"], min = 0, max = 300, labelPos = "top" },
        { key = "pulseSpeed", type = "slider", x = 18, y = 101, w = 15, h = 2, label = L["呼吸动画速度"], min = 10, max = 500, labelPos = "top" },
        { key = "fadeSpeed", type = "slider", x = 2, y = 105, w = 15, h = 2, label = L["触发时动画(淡入)速度"], min = 10, max = 500, labelPos = "top" },
        { key = "fadeOutSpeed", type = "slider", x = 18, y = 105, w = 15, h = 2, label = L["结束时动画(淡出)速度"], min = 10, max = 500, labelPos = "top" },
        { key = "btn_pick_lr_tex", type = "button", x = 5, y = 88, w = 18, h = 3, label = L["选择左右材质(仅预览用)"] },
        { key = "btn_pick_tb_tex", type = "button", x = 26, y = 88, w = 17, h = 3, label = L["选择上方测试材质(仅预览用)"] },
        { key = "desc_layout", type = "description", x = 2, y = 85, w = 48, h = 2, label = "|cffff173b" .. L["注意 : 选择的材质只是方便你调整测试预览而以 所有设置都是通用 "] .. "|r", labelSize = 22 },
        { key = "divider_7439", type = "divider", x = 1, y = 80, w = 50, h = 1, label = L["新组件"] },
    }




    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end

EX_RegisterLayout()
