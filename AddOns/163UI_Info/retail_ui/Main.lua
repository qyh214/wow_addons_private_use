local ADDON_NAME, ns = ...

local UI = {}
ns.UI = UI

local COLOR = {
    BG        = {0.06, 0.06, 0.06, 0.96},
    BORDER    = {0.75, 0.08, 0.08, 1},
    BTN_PRI   = {0.65, 0.05, 0.05, 1},
    BTN_PRI_H = {0.85, 0.12, 0.12, 1},
    BTN_SEC   = {0.22, 0.22, 0.22, 1},
    BTN_SEC_H = {0.35, 0.35, 0.35, 1},
    BTN_DIS   = {0.18, 0.18, 0.18, 1},
    DIVIDER   = {0.55, 0.05, 0.05, 0.8},
    TEXT_MAIN = {0.95, 0.92, 0.88, 1},
    TEXT_DIM  = {0.55, 0.52, 0.50, 1},
    TEXT_WARN = {0.95, 0.78, 0.20, 1},
    TEXT_OK   = {0.25, 0.90, 0.35, 1},
    TEXT_ERR  = {0.95, 0.28, 0.28, 1},
    BADGE     = {0.55, 0.05, 0.05, 0.85},
}

function UI.CreateFrame(parent, w, h, title)
    local f = CreateFrame("Frame", nil, parent or UIParent, "BackdropTemplate")
    f:SetSize(w, h)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    f:SetBackdropColor(unpack(COLOR.BG))
    f:SetBackdropBorderColor(unpack(COLOR.BORDER))
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)

    if title then
        local bar = CreateFrame("Frame", nil, f, "BackdropTemplate")
        bar:SetPoint("TOPLEFT")
        bar:SetPoint("TOPRIGHT")
        bar:SetHeight(36)
        bar:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"})
        bar:SetBackdropColor(0.55, 0.05, 0.05, 0.9)
        bar:SetScript("OnMouseDown", function() f:StartMoving() end)
        bar:SetScript("OnMouseUp",   function() f:StopMovingOrSizing() end)

        local lbl = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("LEFT", 12, 0)
        lbl:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
        lbl:SetText(title)
        lbl:SetTextColor(unpack(COLOR.TEXT_MAIN))
        f.titleBar = bar
        f.titleText = lbl
    end

    return f
end

function UI.CreateButton(parent, text, w, h, style)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(w or 100, h or 26)
    btn:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })

    local isPri = (style ~= "secondary")
    local bgNorm = isPri and COLOR.BTN_PRI or COLOR.BTN_SEC
    local bgHov  = isPri and COLOR.BTN_PRI_H or COLOR.BTN_SEC_H

    btn:SetBackdropColor(unpack(bgNorm))
    btn:SetBackdropBorderColor(unpack(COLOR.BORDER))

    local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetAllPoints()
    lbl:SetJustifyH("CENTER")
    lbl:SetText(text or "")
    lbl:SetTextColor(unpack(COLOR.TEXT_MAIN))
    btn.label = lbl

    btn:SetScript("OnEnter", function(self)
        if self:IsEnabled() then self:SetBackdropColor(unpack(bgHov)) end
    end)
    btn:SetScript("OnLeave", function(self)
        if self:IsEnabled() then self:SetBackdropColor(unpack(bgNorm)) end
    end)

    function btn:SetLabel(t) lbl:SetText(t) end
    function btn:Disable()
        self:SetEnabled(false)
        self:SetBackdropColor(unpack(COLOR.BTN_DIS))
        lbl:SetTextColor(unpack(COLOR.TEXT_DIM))
    end
    function btn:Enable()
        self:SetEnabled(true)
        self:SetBackdropColor(unpack(bgNorm))
        lbl:SetTextColor(unpack(COLOR.TEXT_MAIN))
    end

    return btn
end

function UI.CreateCheckbox(parent, label)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb.text:SetText(label or "")
    cb.text:SetFont(STANDARD_TEXT_FONT, 15)
    cb.text:SetTextColor(unpack(COLOR.TEXT_MAIN))
    cb:SetChecked(true)
    return cb
end

function UI.CreateLabel(parent, text, size, color)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetFont(STANDARD_TEXT_FONT, size or 15)
    fs:SetText(text or "")
    if color then fs:SetTextColor(unpack(color)) else fs:SetTextColor(unpack(COLOR.TEXT_MAIN)) end
    return fs
end

function UI.CreateDivider(parent)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetColorTexture(unpack(COLOR.DIVIDER))
    return line
end

function UI.CreateBadge(parent, text, color)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
    f:SetBackdropColor(unpack(color or COLOR.BADGE))
    f:SetBackdropBorderColor(0.4, 0.04, 0.04, 0.9)
    local lbl = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetFont(STANDARD_TEXT_FONT, 14)
    lbl:SetPoint("CENTER", f, "CENTER")
    lbl:SetText(text or "")
    lbl:SetTextColor(1, 0.85, 0.85)
    local tw = lbl:GetStringWidth() + 12
    f:SetSize(math.max(tw, 40), 22)
    f.label = lbl
    return f
end

function UI.ShowInquiryPopup(onConfirm, onIgnore, descText, onLater)
    local f = UI.CreateFrame(UIParent, 380, 190, "网易DD 配置助手")
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 60)

    
    local mainDesc = descText or "检测到新的网易DD界面配置可供导入"
    local desc = UI.CreateLabel(f, mainDesc, 14, COLOR.TEXT_MAIN)
    desc:SetPoint("TOP", f.titleBar, "BOTTOM", 0, -18)
    desc:SetWidth(340)
    desc:SetJustifyH("CENTER")

    local verLbl
    if not descText then
        local showName = ns.Data and ns.Data.showName and ns.Data.showName ~= "" and ns.Data.showName
        local verText = showName or (ns.Data and ns.Data.version) or "未知"
        verLbl = UI.CreateLabel(f, "配置名称：" .. verText, 12, COLOR.TEXT_DIM)
        verLbl:SetPoint("TOP", desc, "BOTTOM", 0, -8)
        verLbl:SetWidth(340)
        verLbl:SetJustifyH("CENTER")
        verLbl:SetWordWrap(true)
    end

    local div = UI.CreateDivider(f)
    div:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -110)
    div:SetPoint("TOPRIGHT", f, "TOPRIGHT", -16, -110)

    local btnNow = UI.CreateButton(f, "现在导入", 110, 28, "primary")
    btnNow:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 16, 16)
    btnNow:SetScript("OnClick", function()
        f:Hide()
        if onConfirm then onConfirm() end
    end)

    local btnLater = UI.CreateButton(f, "暂不处理", 110, 28, "secondary")
    btnLater:SetPoint("BOTTOM", f, "BOTTOM", 0, 16)
    btnLater:SetScript("OnClick", function()
        f:Hide()
        if onLater then onLater() end
    end)

    local btnIgnore = UI.CreateButton(f, "不再提示", 110, 28, "secondary")
    btnIgnore:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 16)
    btnIgnore:SetScript("OnClick", function()
        f:Hide()
        if onIgnore then onIgnore() end
    end)

    
    f:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
            if onLater then onLater() end
        end
    end)
    f:EnableKeyboard(true)

    f:Show()
    return f
end

local Wizard = {}
UI.Wizard = Wizard

local wizardFrame = nil

function UI.CreateWizard()
    if wizardFrame then
        wizardFrame._data   = nil
        wizardFrame._onDone = nil
        wizardFrame:Show()
        return wizardFrame
    end

    local f = UI.CreateFrame(UIParent, 560, 420, "网易DD 配置向导")
    wizardFrame = f
    f:SetPoint("CENTER")

    local stepLbl = f.titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    stepLbl:SetPoint("CENTER", f.titleBar, "CENTER", 0, 0)
    stepLbl:SetTextColor(1, 0.7, 0.7)
    f.stepLbl = stepLbl

    local subTitle = UI.CreateLabel(f, "", 17, COLOR.TEXT_WARN)
    subTitle:SetPoint("TOPLEFT", f.titleBar, "BOTTOMLEFT", 14, -10)
    f.subTitle = subTitle

    local statusLbl = UI.CreateLabel(f, "", 14, COLOR.TEXT_DIM)
    statusLbl:SetPoint("TOPLEFT", subTitle, "BOTTOMLEFT", 0, -4)
    statusLbl:SetWidth(480)
    f.statusLbl = statusLbl

    local topDiv = UI.CreateDivider(f)
    topDiv:SetPoint("TOPLEFT", f.titleBar, "BOTTOMLEFT", 0, -54)
    topDiv:SetPoint("TOPRIGHT", f.titleBar, "BOTTOMRIGHT", 0, -54)

    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT",  topDiv, "BOTTOMLEFT",  14, -10)
    content:SetPoint("TOPRIGHT", topDiv, "BOTTOMRIGHT", -14,  0)
    content:SetHeight(280)
    f.scroll  = content
    f.content = content

    local botDiv = UI.CreateDivider(f)
    botDiv:SetPoint("BOTTOMLEFT",  f, "BOTTOMLEFT",  0, 44)
    botDiv:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 44)

    local btnBack = UI.CreateButton(f, "上一步", 90, 26, "secondary")
    btnBack:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 14, 10)
    f.btnBack = btnBack

    local btnSkip = UI.CreateButton(f, "跳过此步", 90, 26, "secondary")
    btnSkip:SetPoint("LEFT", btnBack, "RIGHT", 8, 0)
    f.btnSkip = btnSkip

    local btnClose = UI.CreateButton(f.titleBar, "X", 26, 22, "secondary")
    btnClose:SetPoint("RIGHT", f.titleBar, "RIGHT", -4, 0)
    btnClose:SetBackdropColor(0.55, 0.05, 0.05, 1)
    btnClose:SetScript("OnClick", function() f:Hide() end)
    f.btnClose = btnClose

    local btnMain = UI.CreateButton(f, "导入配置", 110, 26, "primary")
    btnMain:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -14, 10)
    f.btnMain = btnMain

    return f
end

local currentStep = 0
local checkedEditMode = {}
local wizardSteps = {}

local contentWrap = nil

local function RebuildContentWrap()
    local f = wizardFrame
    if contentWrap then
        contentWrap:Hide()
        contentWrap:SetParent(nil)
        contentWrap = nil
    end
    f.content:SetHeight(280)
    local wrap = CreateFrame("Frame", nil, f.content)
    wrap:SetPoint("TOPLEFT",  f.content, "TOPLEFT",  0, 0)
    wrap:SetPoint("TOPRIGHT", f.content, "TOPRIGHT", 0, 0)
    wrap:SetHeight(280)
    contentWrap = wrap
    return wrap
end

local function CalcStepsFromData(data)
    local steps = {}
    if data and data.editMode and #data.editMode > 0 then
        table.insert(steps, "editmode")
    end
    if data and data.cooldown then
        local _, classEN = UnitClass("player")
        classEN = classEN and classEN:upper() or ""
        local cdMap = data.cooldown[classEN]
        if cdMap then
            for _ in pairs(cdMap) do
                table.insert(steps, "cooldown")
                break
            end
        end
    end
    return steps
end

UI.CalcSteps = CalcStepsFromData
function UI.SetWizardSteps(steps)
    wizardSteps = steps
    if wizardFrame then wizardFrame._steps = steps end
end

function Wizard.GoToStep(idx)
    local f = wizardFrame
    if not f then return end

    if f._btnReload then f._btnReload:Hide(); f._btnReload:SetParent(nil); f._btnReload = nil end
    if f._btnLater  then f._btnLater:Hide();  f._btnLater:SetParent(nil);  f._btnLater = nil end

    f.btnBack:Show()
    f.btnSkip:Show()
    f.btnMain:Show()
    f.btnMain:Enable()

    if idx == "complete" then
        currentStep = 0
        Wizard.BuildCompletePage(f._editOk or 0, f._cdOk or 0)
        return
    end

    currentStep = idx

    local steps = f._steps or wizardSteps
    local total = #steps
    local stepName = steps[idx]

    f.stepLbl:SetText("第" .. idx .. " / " .. total .. " 步")

    if idx <= 1 then f.btnBack:Hide() else f.btnBack:Show() end
    f.btnBack:SetScript("OnClick", function() Wizard.GoToStep(idx - 1) end)

    local function goNext()
        if idx >= total then
            Wizard.GoToStep("complete")
        else
            Wizard.GoToStep(idx + 1)
        end
    end

    f.btnSkip:SetScript("OnClick", function()
        if stepName == "editmode" then f._editOk = f._editOk or 0
        elseif stepName == "cooldown" then f._cdOk = f._cdOk or 0 end
        goNext()
    end)

    if stepName == "editmode" then
        Wizard.BuildStep1(goNext, total)
    elseif stepName == "cooldown" then
        Wizard.BuildStep2(goNext, total)
    end
end

function Wizard.BuildStep1(goNext, total)
    local f = wizardFrame
    local wrap = RebuildContentWrap()

    f.subTitle:SetText("编辑模式布局")
    f.statusLbl:SetText("选择要导入的编辑模式布局")
    f.btnSkip:SetLabel("跳过此步")
    f.btnMain:SetLabel(total == 1 and "导入并完成" or "导入并下一步")
    f.btnClose:SetScript("OnClick", function() wizardFrame:Hide() end)

    local data = f._data or ns.Data
    local editList = data and data.editMode or {}

    local allBtn = UI.CreateButton(wrap, "全选", 56, 20, "secondary")
    allBtn:SetPoint("TOPLEFT", wrap, "TOPLEFT", 0, 0)
    local noneBtn = UI.CreateButton(wrap, "取消全选", 72, 20, "secondary")
    noneBtn:SetPoint("LEFT", allBtn, "RIGHT", 6, 0)

    checkedEditMode = {}
    local checkboxes = {}

    local yOff = -30
    for i, entry in ipairs(editList) do
        local cb = UI.CreateCheckbox(wrap, entry.name)
        cb:SetPoint("TOPLEFT", wrap, "TOPLEFT", 4, yOff)
        cb:SetChecked(true)
        checkedEditMode[i] = true
        cb:SetScript("OnClick", function(self) checkedEditMode[i] = self:GetChecked() end)
        table.insert(checkboxes, cb)
        yOff = yOff - 26
    end

    wrap:SetHeight(math.max(math.abs(yOff) + 10, 60))

    allBtn:SetScript("OnClick", function()
        for _, cb in ipairs(checkboxes) do cb:SetChecked(true) end
        for i in ipairs(editList) do checkedEditMode[i] = true end
    end)
    noneBtn:SetScript("OnClick", function()
        for _, cb in ipairs(checkboxes) do cb:SetChecked(false) end
        for i in ipairs(editList) do checkedEditMode[i] = false end
    end)

    if #editList == 0 then
        local hint = UI.CreateLabel(wrap, "当前暂无编辑模式配置", 13, COLOR.TEXT_DIM)
        hint:SetPoint("TOPLEFT", wrap, "TOPLEFT", 8, -10)
            f.btnMain:SetLabel("下一步")
    end

    f.btnMain:SetScript("OnClick", function()
        f.btnMain:Disable()
        local selected = {}
        for i, entry in ipairs(editList) do
            if checkedEditMode[i] then table.insert(selected, entry) end
        end
        if #selected == 0 then
            f._editOk = 0
            goNext()
            return
        end
        f.statusLbl:SetText("正在导入...")
        ns.EditMode.ImportSelected(selected, function(result)
            if result.ok == 0 and result.fail > 0 and result.errors[1] == "用户取消" then
                f.btnMain:Enable()
                f.statusLbl:SetText("选择要导入的编辑模式布局")
                return
            end
            f._editOk = result.ok
            if result.fail > 0 then
                f.statusLbl:SetText("|cffff4444" .. result.fail .. " 条导入失败|r  已成功" .. result.ok .. " 条")
            else
                f.statusLbl:SetText("|cff55ee55已导入" .. result.ok .. " 条编辑模式布局|r")
            end
            C_Timer.After(0.5, function() goNext() end)
        end)
    end)
end

local SPEC_TAG_NAMES = {
    [11] = "武器",    [12] = "狂怒",      [13] = "防护",
    [21] = "神圣",    [22] = "防护",      [23] = "惩戒",
    [31] = "野兽控制",[32] = "射击",      [33] = "生存",
    [41] = "奇袭",    [42] = "狂徒",      [43] = "敏锐",
    [51] = "戒律",    [52] = "神圣",      [53] = "暗影",
    [61] = "鲜血",    [62] = "冰霜",      [63] = "邪恶",
    [71] = "元素",    [72] = "增强",      [73] = "恢复",
    [81] = "奥术",    [82] = "火焰",      [83] = "冰霜",
    [91] = "痛苦",    [92] = "恶魔学识",  [93] = "毁灭",
    [101] = "酒仙",   [102] = "织雾",     [103] = "踏风",
    [111] = "平衡",   [112] = "野性",     [113] = "守护", [114] = "恢复",
    [121] = "浩劫",   [122] = "复仇",     [123] = "噬灭",
    [131] = "湮灭",   [132] = "保护",     [133] = "增辉",
}

local CLASS_TAG_NAMES = {
    [1]="战士",[2]="圣骑士",[3]="猎人",[4]="潜行者",[5]="牧师",
    [6]="死亡骑士",[7]="萨满祭司",[8]="法师",[9]="术士",[10]="武僧",
    [11]="德鲁伊",[12]="恶魔猎手",[13]="唤魔师",
}

local CLASS_TOKEN_TO_ID = {
    WARRIOR=1, PALADIN=2, HUNTER=3, ROGUE=4, PRIEST=5,
    DEATHKNIGHT=6, SHAMAN=7, MAGE=8, WARLOCK=9, MONK=10,
    DRUID=11, DEMONHUNTER=12, EVOKER=13,
}

local function GetSpecName(specTag)
    if SPEC_TAG_NAMES[specTag] then
        local classID = math.floor(specTag / 10)
        local cls = CLASS_TAG_NAMES[classID] or ""
        return cls .. " · " .. SPEC_TAG_NAMES[specTag]
    end
    return "专精 " .. tostring(specTag)
end

function Wizard.BuildStep2(goNext, total)
    local f = wizardFrame
    local wrap = RebuildContentWrap()

    f.subTitle:SetText("冷却管理器配置")
    f.statusLbl:SetText("选择要导入的冷却管理器：")
    f.btnSkip:SetLabel("跳过此步")
    f.btnMain:SetLabel(total == 1 and "导入并完成" or "导入选中项")
    f.btnClose:SetScript("OnClick", function() wizardFrame:Hide() end)

    local _, classEN = UnitClass("player")
    classEN = classEN and classEN:upper() or ""
    local data = wizardFrame._data or ns.Data
    local cdMap = data and data.cooldown and data.cooldown[classEN] or nil

    local specEntries = {}
    local checkedCD = {}

    if cdMap then
        for specTag, entry in pairs(cdMap) do
            table.insert(specEntries, {specTag = specTag, entry = entry})
        end
        table.sort(specEntries, function(a, b) return a.specTag < b.specTag end)
    end

    if #specEntries == 0 then
        local hint = UI.CreateLabel(wrap, "当前职业暂无冷却管理器配置", 13, COLOR.TEXT_DIM)
        hint:SetPoint("CENTER", wrap, "CENTER", 0, 0)
        wrap:SetHeight(60)

        f.btnSkip:Hide()
        f.btnMain:SetLabel("完成")
        f.btnMain:SetScript("OnClick", function()
            f._cdOk = 0
            goNext()
        end)
        return
    end

    local allBtn = UI.CreateButton(wrap, "全选", 56, 20, "secondary")
    allBtn:SetPoint("TOPLEFT", wrap, "TOPLEFT", 0, 0)
    local noneBtn = UI.CreateButton(wrap, "取消全选", 72, 20, "secondary")
    noneBtn:SetPoint("LEFT", allBtn, "RIGHT", 6, 0)

    local checkboxes = {}
    local yOff = -30

    for i, item in ipairs(specEntries) do
        local cb = UI.CreateCheckbox(wrap, item.entry.name)
        cb:SetPoint("TOPLEFT", wrap, "TOPLEFT", 4, yOff)
        cb:SetChecked(true)
        checkedCD[i] = true
        cb:SetScript("OnClick", function(self) checkedCD[i] = self:GetChecked() end)
        table.insert(checkboxes, cb)

        local badge = UI.CreateBadge(wrap, GetSpecName(item.specTag))
        badge:SetPoint("LEFT", cb.text, "RIGHT", 8, 0)

        yOff = yOff - 28
    end

    wrap:SetHeight(math.max(math.abs(yOff) + 10, 60))

    allBtn:SetScript("OnClick", function()
        for _, cb in ipairs(checkboxes) do cb:SetChecked(true) end
        for i in ipairs(specEntries) do checkedCD[i] = true end
    end)
    noneBtn:SetScript("OnClick", function()
        for _, cb in ipairs(checkboxes) do cb:SetChecked(false) end
        for i in ipairs(specEntries) do checkedCD[i] = false end
    end)

    f.btnMain:SetScript("OnClick", function()
        f.btnMain:Disable()
        local selected = {}
        for i, item in ipairs(specEntries) do
            if checkedCD[i] then table.insert(selected, item.entry) end
        end
        if #selected == 0 then
            f._cdOk = 0
            goNext()
            return
        end
        f.statusLbl:SetText("正在导入...")
        ns.Cooldown.ImportSelected(selected, function(ok, cdOk, errors)
            if not ok and cdOk == 0 and errors and errors[1] == "用户取消" then
                f.btnMain:Enable()
                f.statusLbl:SetText("选择要导入的冷却管理器：")
                return
            end
            f._cdOk = cdOk
            if cdOk > 0 then
                f.statusLbl:SetText("|cff55ee55已导入" .. cdOk .. " 条冷却管理器配置|r")
            end
            C_Timer.After(0.5, function() goNext() end)
        end)
    end)
end

function Wizard.BuildCompletePage(editOk, cdOk)
    local f = wizardFrame

    if (editOk + cdOk) > 0 then
        if f._onDone then
            f._onDone()
        else
            ns.CharDB.lastInstallVersion = ns.Data and ns.Data.version
        end
    elseif f._onDone then
        f._onDone()
    end

    local wrap = RebuildContentWrap()

    f.stepLbl:SetText("完成")
    f.subTitle:SetText("导入结果")
    f.statusLbl:SetText("")

    f.btnBack:Hide()
    f.btnSkip:Hide()
    f.btnMain:Hide()

    local y = -16
    local function AddLine(text, color)
        local lbl = UI.CreateLabel(wrap, text, 14, color or COLOR.TEXT_MAIN)
        lbl:SetPoint("TOPLEFT", wrap, "TOPLEFT", 12, y)
        lbl:SetWidth(480)
        y = y - 24
    end

    AddLine("导入完成！", COLOR.TEXT_OK)
    AddLine("")
    AddLine("编辑模式布局：" .. editOk .. " 条已导入")
    AddLine("冷却管理器配置：" .. cdOk .. " 条已导入")
    if editOk > 0 then
        AddLine("")
        AddLine("请重载界面以让配置生效", COLOR.TEXT_WARN)
    end

    wrap:SetHeight(math.abs(y) + 20)

    local btnReload = UI.CreateButton(f, "完成并重载界面", 140, 26, "primary")
    btnReload:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -14, 10)
    btnReload:SetScript("OnClick", function() ReloadUI() end)
    f._btnReload = btnReload

    local btnLater = UI.CreateButton(f, "稍后手动重载", 120, 26, "secondary")
    btnLater:SetPoint("RIGHT", btnReload, "LEFT", -8, 0)
    btnLater:SetScript("OnClick", function() wizardFrame:Hide() end)
    f._btnLater = btnLater
end

function UI.ShowSlotManager(existingList, neededCount, hintText, onConfirm, onCancel)
    local frameH = math.max(340, 100 + #existingList * 30 + 80)
    local f = UI.CreateFrame(UIParent, 420, frameH, "配置槽位已满")
    f:SetPoint("CENTER", UIParent, "CENTER")
    f:SetFrameLevel(100)

    local line1 = UI.CreateLabel(f,
        "配置槽位已满，无法继续导入",
        16, COLOR.TEXT_MAIN)
    line1:SetPoint("TOPLEFT", f.titleBar, "BOTTOMLEFT", 14, -14)
    line1:SetWidth(390)

    local line2 = UI.CreateLabel(f,
        "请勾选要删除的旧配置，腾出" .. neededCount .. " 个槽位后继续导入",
        14, COLOR.TEXT_WARN)
    line2:SetPoint("TOPLEFT", line1, "BOTTOMLEFT", 0, -6)
    line2:SetWidth(390)

    local div = UI.CreateDivider(f)
    div:SetPoint("TOPLEFT", f.titleBar, "BOTTOMLEFT", 0, -66)
    div:SetPoint("TOPRIGHT", f.titleBar, "BOTTOMRIGHT", 0, -66)

    local listFrame = CreateFrame("Frame", nil, f)
    listFrame:SetPoint("TOPLEFT",  div, "BOTTOMLEFT",  14, -10)
    listFrame:SetPoint("TOPRIGHT", div, "BOTTOMRIGHT", -14,  0)
    listFrame:SetHeight(math.max(160, #existingList * 30 + 10))

    local checkboxes = {}
    local yOff = 0
    for i, item in ipairs(existingList) do
        local cb = CreateFrame("CheckButton", nil, listFrame, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 4, yOff)
        cb.text:SetFont(STANDARD_TEXT_FONT, 15)
        cb.text:SetText(i .. ".  " .. item.name)

        local checked = (i <= neededCount)
        cb:SetChecked(checked)
        cb.text:SetTextColor(checked and 0.95 or 0.95, checked and 0.35 or 0.92, checked and 0.35 or 0.88, 1)
        table.insert(checkboxes, {cb = cb, id = item.id, textObj = cb.text})
        yOff = yOff - 30
    end
    listFrame:SetHeight(math.abs(yOff) + 10)

    local hintLbl = UI.CreateLabel(f, "", 15, COLOR.TEXT_DIM)
    hintLbl:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 14, 50)
    hintLbl:SetWidth(280)

    local btnConfirm
    local function UpdateHint()
        local count = 0
        for _, item in ipairs(checkboxes) do
            local chk = item.cb:GetChecked()
            if chk then
                count = count + 1
                item.textObj:SetTextColor(0.95, 0.35, 0.35, 1)
            else
                item.textObj:SetTextColor(unpack(COLOR.TEXT_MAIN))
            end
        end
        local remain = neededCount - count
        if remain > 0 then
            hintLbl:SetText("|cffff9900还需再勾选" .. remain .. " 个|r")
            if btnConfirm then btnConfirm:Disable() end
        else
            hintLbl:SetText("|cff55ee55已选" .. count .. " 个，可以继续导入|r")
            if btnConfirm then btnConfirm:Enable() end
        end
    end

    for _, item in ipairs(checkboxes) do
        item.cb:SetScript("OnClick", function() UpdateHint() end)
    end

    local btnCancel = UI.CreateButton(f, "取消", 80, 28, "secondary")
    btnCancel:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 14, 14)
    btnCancel:SetScript("OnClick", function()
        f:Hide()
        if onCancel then onCancel() end
    end)

    btnConfirm = UI.CreateButton(f, "删除所选并继续导入", 150, 28, "primary")
    btnConfirm:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -14, 14)
    btnConfirm:SetScript("OnClick", function()
        local ids = {}
        for _, item in ipairs(checkboxes) do
            if item.cb:GetChecked() then table.insert(ids, item.id) end
        end
        f:Hide()
        if onConfirm then onConfirm(ids) end
    end)

    UpdateHint()
    f:Show()
    return f
end

local EditMode = {}
ns.EditMode = EditMode

function EditMode.ConvertString(importString)
    if type(importString) ~= "string" or #importString < 5 then
        return nil
    end
    local ok, info = pcall(C_EditMode.ConvertStringToLayoutInfo, importString)
    if ok and info then
        return info
    end
    return nil
end

function EditMode.GetExistingNames()
    local nameSet = {}
    local data = C_EditMode and C_EditMode.GetLayouts and C_EditMode.GetLayouts()
    if not data or not data.layouts then return nameSet end
    for _, layout in ipairs(data.layouts) do
        if layout and layout.layoutName then
            nameSet[layout.layoutName] = true
        end
    end
    return nameSet
end

local function FindLayoutIndex(layouts, name)
    for i, v in ipairs(layouts) do
        if v.layoutName == name then return i end
    end
    return nil
end

function EditMode.ImportOne(entry, setActive)
    if not C_EditMode or not C_EditMode.GetLayouts
       or not C_EditMode.SaveLayouts or not C_EditMode.ConvertStringToLayoutInfo then
        return false, "C_EditMode API 不可用"
    end

    local ok, info = pcall(C_EditMode.ConvertStringToLayoutInfo, entry.importString)
    if not ok or not info then
        return false, "字符串解析失败: " .. tostring(info)
    end

    
    local rawName = (info.layoutName and info.layoutName ~= "") and info.layoutName or nil
    local finalName = (entry.name and entry.name ~= "") and entry.name
        or rawName
        or "DD布局"

    if #finalName > 30 then
        local truncated = finalName:sub(1, 30)
        while #truncated > 0 and bit.band(truncated:byte(-1), 0xC0) == 0x80 do
            truncated = truncated:sub(1, -2)
        end
        finalName = truncated
    end

    info.layoutName = finalName
    info.layoutType = Enum.EditModeLayoutType.Account

    local allLayouts = C_EditMode.GetLayouts()
    if not allLayouts or not allLayouts.layouts then
        return false, "无法读取布局列表"
    end

    
    local existIdx = FindLayoutIndex(allLayouts.layouts, finalName)
    if existIdx then
        allLayouts.layouts[existIdx] = info
    else
        table.insert(allLayouts.layouts, info)
        existIdx = #allLayouts.layouts
    end

    local saveOk, saveErr = pcall(C_EditMode.SaveLayouts, allLayouts)
    if not saveOk then
        return false, "SaveLayouts 失败: " .. tostring(saveErr)
    end

    
    
    if setActive then
        local presetOffset = (Enum.EditModePresetLayoutsMeta and Enum.EditModePresetLayoutsMeta.NumValues) or 0
        C_EditMode.SetActiveLayout(presetOffset + existIdx)
    end

    return true, finalName
end

local function CountAccountLayouts()
    local data = C_EditMode and C_EditMode.GetLayouts and C_EditMode.GetLayouts()
    if not data or not data.layouts then return 0 end
    local count = 0
    for _, v in ipairs(data.layouts) do
        if v.layoutType == Enum.EditModeLayoutType.Account then
            count = count + 1
        end
    end
    return count
end

local function GetAccountLayoutList()
    local data = C_EditMode and C_EditMode.GetLayouts and C_EditMode.GetLayouts()
    if not data or not data.layouts then return {} end
    local list = {}
    for i, v in ipairs(data.layouts) do
        if v.layoutType == Enum.EditModeLayoutType.Account then
            table.insert(list, {id = i, name = v.layoutName})
        end
    end
    return list
end

local function DeleteLayoutsByIndex(indexList)
    local data = C_EditMode.GetLayouts()
    if not data or not data.layouts then return end
    
    table.sort(indexList, function(a, b) return a > b end)
    for _, idx in ipairs(indexList) do
        table.remove(data.layouts, idx)
    end
    C_EditMode.SaveLayouts(data)
end

local MAX_ACCOUNT_LAYOUTS = 5

function EditMode.ImportSelected(entries, callback)
    local newEntries = {}
    for _, entry in ipairs(entries) do
        local data = C_EditMode.GetLayouts()
        local existIdx = data and data.layouts and FindLayoutIndex(data.layouts, entry.name)
        if existIdx then

        else
            table.insert(newEntries, entry)
        end
    end

    local currentCount = CountAccountLayouts()
    local afterCount = currentCount + #newEntries
    local needed = afterCount - MAX_ACCOUNT_LAYOUTS

    local function doImport()
        local result = {ok = 0, fail = 0, errors = {}}
        local firstActiveName = nil
        for _, entry in ipairs(entries) do
            local success, msg = EditMode.ImportOne(entry, true)
            if success then
                result.ok = result.ok + 1
                if firstActiveName == nil then
                    firstActiveName = msg
                end
            else
                result.fail = result.fail + 1
                table.insert(result.errors, msg)
            end
        end
        if firstActiveName then
            local allLayouts = C_EditMode.GetLayouts()
            if allLayouts and allLayouts.layouts then
                local idx = FindLayoutIndex(allLayouts.layouts, firstActiveName)
                if idx then
                    local presetOffset = (Enum.EditModePresetLayoutsMeta and Enum.EditModePresetLayoutsMeta.NumValues) or 0
                    C_EditMode.SetActiveLayout(presetOffset + idx)
                end
            end
        end
        if callback then callback(result) end
    end

    if needed <= 0 then
        doImport()
    else
        local willOverwrite = {}
        for _, entry in ipairs(entries) do
            willOverwrite[entry.name] = true
        end

        local existingList = GetAccountLayoutList()

        local filteredList = {}
        for _, item in ipairs(existingList) do
            if not willOverwrite[item.name] then
                table.insert(filteredList, item)
            end
        end

        table.sort(filteredList, function(a, b) return a.id > b.id end)

        ns.UI.ShowSlotManager(
            filteredList, needed,
            "当前编辑模式布局已满，需清出 " .. needed .. " 个槽位。\n请选择要删除的布局",
            function(deleteIds)
                DeleteLayoutsByIndex(deleteIds)
                doImport()
            end,
            function()
                if callback then callback({ok=0, fail=#entries, errors={"用户取消"}}) end
            end
        )
    end
end

local Cooldown = {}
ns.Cooldown = Cooldown

local MAX_PROFILES = 5

function Cooldown.EnsureLoaded()
    if CooldownViewerSettings and CooldownViewerSettings.GetLayoutManager then
        return true
    end
    pcall(function()
        if C_AddOns and C_AddOns.LoadAddOn then
            C_AddOns.LoadAddOn("Blizzard_CooldownViewer")
        elseif LoadAddOn then
            LoadAddOn("Blizzard_CooldownViewer")
        end
    end)
    return CooldownViewerSettings and CooldownViewerSettings.GetLayoutManager ~= nil
end

function Cooldown.GetManager()
    if not Cooldown.EnsureLoaded() then return nil end
    return CooldownViewerSettings:GetLayoutManager()
end

function Cooldown.CountProfiles()
    local mgr = Cooldown.GetManager()
    if not mgr or not mgr.EnumerateLayouts then return 0 end
    local count = 0
    for _ in mgr:EnumerateLayouts() do
        count = count + 1
    end
    return count
end

function Cooldown.ImportSelected(entries, callback)
    local mgr = Cooldown.GetManager()
    if not mgr then
        if callback then callback(false, 0, {"冷却管理器模块未就绪"}) end
        return
    end

    local existCount = 0
    local existNames = {}
    for layoutID, layoutInfo in mgr:EnumerateLayouts() do
        existCount = existCount + 1
        local name = CooldownManagerLayout_GetName and CooldownManagerLayout_GetName(layoutInfo)
        if name then existNames[name] = true end
    end

    local trueNewCount = 0
    for _, entry in ipairs(entries) do
        if not existNames[entry.name] then
            trueNewCount = trueNewCount + 1
        end
    end

    local afterCount = existCount + trueNewCount
    local needed = afterCount - MAX_PROFILES


    local function doImport()
        local errors = {}
        local cdOk = 0

        local toDeleteIds = {}
        local importNames = {}
        for _, entry in ipairs(entries) do importNames[entry.name] = true end

        for layoutID, layoutInfo in mgr:EnumerateLayouts() do
            local name = CooldownManagerLayout_GetName and CooldownManagerLayout_GetName(layoutInfo)
            if name and importNames[name] then
                table.insert(toDeleteIds, layoutID)
            end
        end
        for _, id in ipairs(toDeleteIds) do
            pcall(function() mgr:RemoveLayout(id) end)
        end

        for _, entry in ipairs(entries) do
            local ok, err = pcall(function()

                local newIDs = mgr:CreateLayoutsFromSerializedData(entry.importString)
                if not newIDs or not newIDs[1] then
                    error("导入字符串解析失败")
                end

                local layout = mgr:GetLayout(newIDs[1])
                if layout then
                    local embeddedName = CooldownManagerLayout_GetName and CooldownManagerLayout_GetName(layout)
                    local finalCdName = (embeddedName and embeddedName ~= "") and embeddedName
                        or (entry.name and entry.name ~= "") and entry.name
                        or "DD冷却配置"
                    if CooldownManagerLayout_SetName then
                        CooldownManagerLayout_SetName(layout, finalCdName)
                    end
                end

                mgr:SetActiveLayoutByID(newIDs[1])
            end)
            if ok then
                cdOk = cdOk + 1
            else
                table.insert(errors, tostring(err))
            end
        end

        mgr:SaveLayouts()

        if mgr.SwitchToBestLayoutForSpec then
            pcall(function() mgr:SwitchToBestLayoutForSpec() end)
        end

        if callback then callback(true, cdOk, errors) end
    end

    if needed <= 0 then
        doImport()
    else
        local willOverwrite = {}
        for _, entry in ipairs(entries) do willOverwrite[entry.name] = true end

        local existingList = {}
        for layoutID, layoutInfo in mgr:EnumerateLayouts() do
            local name = CooldownManagerLayout_GetName and CooldownManagerLayout_GetName(layoutInfo) or tostring(layoutID)
            if not willOverwrite[name] then
                table.insert(existingList, {id = layoutID, name = name})
            end
        end
        table.sort(existingList, function(a, b) return a.id > b.id end)

        ns.UI.ShowSlotManager(existingList, needed,
            "当前冷却管理器配置已满，请选择要删除的配置",
            function(deleteIds)
                for _, id in ipairs(deleteIds) do
                    pcall(function() mgr:RemoveLayout(id) end)
                end
                pcall(function() mgr:SaveLayouts() end)
                doImport()
            end,
            function()
                if callback then callback(false, 0, {"用户取消"}) end
            end
        )
    end
end

local function InitDB()
    if type(_G["ddInfoDB"]) ~= "table" then
        _G["ddInfoDB"] = {}
    end
    if type(_G["ddInfoDB"].global) ~= "table" then
        _G["ddInfoDB"].global = {}
    end
    ns.AccountDB = _G["ddInfoDB"].global

    if type(_G["ddInfoCharDB"]) ~= "table" then
        _G["ddInfoCharDB"] = {}
    end
    ns.CharDB = _G["ddInfoCharDB"]
end

local function HasContent()
    if not ns.Data then return false end
    local hasEM = ns.Data.editMode and #ns.Data.editMode > 0
    local hasCD = false
    if type(ns.Data.cooldown) == "table" then
        for _ in pairs(ns.Data.cooldown) do hasCD = true; break end
    end
    return hasEM or hasCD
end

local function MarkVersionsProcessed(versions)
    if not ns.CharDB.processedVersions then
        ns.CharDB.processedVersions = {}
    end
    for _, v in ipairs(versions) do
        ns.CharDB.processedVersions[v] = true
    end
end
ns.MarkVersionsProcessed = MarkVersionsProcessed

local function ShouldShowPopup()
    if not HasContent() then return false end
    local v = ns.Data.version
    if not v or v == "DD_00000000000000" then return false end
    if ns.AccountDB.ignoreVersion == v then return false end
    if ns.CharDB.lastInstallVersion == v then return false end
    return true
end

local function CollectInstallData()
    local dataVer    = (ns.Data       and ns.Data.version)               or "DD_00000000000000"
    local installVer = (ns.InstallData and ns.InstallData.fileVersion)    or "DD_00000000000000"
    local hasData    = ns.Data and HasContent()
    local hasInstall = installVer > "DD_00000000000000"

    if not hasData and not hasInstall then return nil end

    if hasInstall and installVer > dataVer then
        if not ns.CharDB.processedVersions then ns.CharDB.processedVersions = {} end
        local processed = ns.CharDB.processedVersions
        local id = ns.InstallData

        local _, classEN = UnitClass("player")
        classEN = classEN and classEN:upper() or "UNKNOWN"

        local playerClassID = CLASS_TOKEN_TO_ID[classEN]

        local emList, cdList = {}, {}
        for _, e in ipairs(id.editMode or {}) do
            if e.version and not processed[e.version] then table.insert(emList, e) end
        end
        for _, e in ipairs(id.coolDown or {}) do
            if e.version and not processed[e.version] then
                local entryClassID = e.specTag and math.floor(e.specTag / 10) or nil
                if not entryClassID or not playerClassID or entryClassID == playerClassID then
                    table.insert(cdList, e)
                end
            end
        end
        if #emList == 0 and #cdList == 0 then return nil end

        local allVersions = {}
        for _, e in ipairs(emList) do if e.version then allVersions[#allVersions+1] = e.version end end
        for _, e in ipairs(cdList) do if e.version then allVersions[#allVersions+1] = e.version end end

        local cooldownMap = {}
        if #cdList > 0 then
            cooldownMap[classEN] = {}
            for _, entry in ipairs(cdList) do
                if entry.specTag then
                    cooldownMap[classEN][entry.specTag] = { name = entry.name, importString = entry.importString }
                end
            end
        end

        local desc
        local em, cd = #emList, #cdList
        if em > 0 and cd > 0 then
            desc = "检测到 " .. em .. " 条编辑模式 + " .. cd .. " 条冷却管理器字符串配置可供导入"
        elseif em > 0 then
            desc = "检测到 " .. em .. " 条编辑模式字符串配置可供导入"
        else
            desc = "检测到 " .. cd .. " 条冷却管理器字符串配置可供导入"
        end

        return {
            source     = "install",
            wizardData = { editMode = emList, cooldown = cooldownMap },
            onDone     = function() MarkVersionsProcessed(allVersions) end,
            descText   = desc,
            onIgnore   = function()
                MarkVersionsProcessed(allVersions)
                print("|cffdd3333[163UI]|r 已跳过本批次字符串安装，输入 |cffffffff/ddinstall reset|r 可恢复")
            end,
        }
    end

    if not hasData or not ShouldShowPopup() then return nil end
    return {
        source     = "data",
        wizardData = ns.Data,
        onDone     = nil,
        descText   = nil,
        onIgnore   = function()
            ns.AccountDB.ignoreVersion = ns.Data.version
            print("|cffdd3333[163UI]|r 已记录，本账号不再提示此版本配置。输入 |cffffffff/ddset reset|r 可恢复")
        end,
    }
end

local function CollectPendingInstallData()
    local id = ns.InstallData
    if not id then return nil end
    if not ns.CharDB.processedVersions then ns.CharDB.processedVersions = {} end
    local processed = ns.CharDB.processedVersions
    local emList, cdList = {}, {}
    for _, e in ipairs(id.editMode or {}) do
        if e.version and not processed[e.version] then table.insert(emList, e) end
    end
    for _, e in ipairs(id.coolDown or {}) do
        if e.version and not processed[e.version] then table.insert(cdList, e) end
    end
    if #emList == 0 and #cdList == 0 then return nil end
    return { editMode = emList, coolDown = cdList }
end

local function OpenWizard(data, onDone)
    data = data or ns.Data
    local steps = ns.UI.CalcSteps(data)
    if #steps == 0 then
        print("|cffdd3333[163UI]|r 没有适合当前角色的配置内容")
        return
    end
    local f = ns.UI.CreateWizard()
    f._editOk = 0
    f._cdOk   = 0
    f._data   = data
    f._onDone = onDone
    ns.UI.SetWizardSteps(steps)
    f:Show()
    ns.UI.Wizard.GoToStep(1)
end

local function ShowInquiry(result)
    ns.UI.ShowInquiryPopup(
        function() OpenWizard(result.wizardData, result.onDone) end,
        result.onIgnore,
        result.descText
    )
end

local function ShowInstallInquiry(pending)
    local emList = pending.editMode or {}
    local cdList = pending.coolDown or {}
    if #emList == 0 and #cdList == 0 then return end
    local allVersions = {}
    for _, e in ipairs(emList) do if e.version then allVersions[#allVersions+1] = e.version end end
    for _, e in ipairs(cdList) do if e.version then allVersions[#allVersions+1] = e.version end end
    local _, classEN = UnitClass("player")
    classEN = classEN and classEN:upper() or "UNKNOWN"
    local cooldownMap = {}
    if #cdList > 0 then
        cooldownMap[classEN] = {}
        for _, entry in ipairs(cdList) do
            if entry.specTag then
                cooldownMap[classEN][entry.specTag] = { name = entry.name, importString = entry.importString }
            end
        end
    end
    local em, cd = #emList, #cdList
    local desc
    if em > 0 and cd > 0 then desc = "检测到 " .. em .. " 条编辑模式 + " .. cd .. " 条冷却管理器字符串配置"
    elseif em > 0 then desc = "检测到 " .. em .. " 条编辑模式字符串配置"
    else desc = "检测到 " .. cd .. " 条冷却管理器字符串配置" end
    ns.UI.ShowInquiryPopup(
        function() OpenWizard({ editMode = emList, cooldown = cooldownMap }, function() MarkVersionsProcessed(allVersions) end) end,
        function() MarkVersionsProcessed(allVersions) end,
        desc
    )
end

local addonLoaded = false
local worldEntered = false

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON_NAME then
            addonLoaded = true
            InitDB()

            if worldEntered then
                C_Timer.After(1.5, function()
                    local result = CollectInstallData()
                    if result then ShowInquiry(result) end
                end)
            end
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        worldEntered = true
        if addonLoaded then
            C_Timer.After(1.5, function()
                local result = CollectInstallData()
                if result then ShowInquiry(result) end
            end)
        end
    end
end)

local function OpenInstallDataWizard()
    local id = ns.InstallData
    local hasEM = id and type(id.editMode) == "table" and #id.editMode > 0
    local hasCD = id and type(id.coolDown) == "table" and #id.coolDown > 0
    if not hasEM and not hasCD then
        print("|cffdd3333[163UI]|r InstallData.lua 未找到或无内容")
        return false
    end
    InitDB()
    local pending = {
        editMode = (id and id.editMode) or {},
        coolDown = (id and id.coolDown) or {},
    }
    ShowInstallInquiry(pending)
    return true
end

local function OpenDataWizard()
    local d = ns.Data
    local hasData = d and (
        (type(d.editMode) == "table" and #d.editMode > 0) or
        (type(d.coolDown) == "table" and next(d.coolDown))
    )
    if not hasData then
        print("|cffdd3333[163UI]|r Data.lua 未找到或无配置内容")
        return false
    end
    InitDB()
    OpenWizard()
    return true
end

local function HandleUnifiedSlash(msg)
    msg = msg and msg:lower():match("^%s*(.-)%s*$") or ""

    if msg == "" or msg == "open" then
        InitDB()
        local d  = ns.Data
        local id = ns.InstallData
        local hasData = d and (
            (type(d.editMode) == "table" and #d.editMode > 0) or
            (type(d.coolDown) == "table" and next(d.coolDown))
        )
        local hasInstall = id and (
            (type(id.editMode) == "table" and #id.editMode > 0) or
            (type(id.coolDown) == "table" and #id.coolDown > 0)
        )

        if hasData and hasInstall then
            local f = UI.CreateFrame(UIParent, 360, 170, "选择配置来源")
            f:SetPoint("CENTER")
            f:SetFrameStrata("DIALOG")
            local lbl = UI.CreateLabel(f, "检测到两份配置，请选择要安装的来源：", 15, COLOR.TEXT_MAIN)
            lbl:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -40)
            lbl:SetWidth(328)
            lbl:SetJustifyH("LEFT")
            local btnData = UI.CreateButton(f, "配置分享安装", 155, 32, "primary")
            btnData:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 16, 20)
            btnData:SetScript("OnClick", function()
                f:Hide()
                OpenDataWizard()
            end)
            local btnInst = UI.CreateButton(f, "字符串安装", 155, 32, "secondary")
            btnInst:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 20)
            btnInst:SetScript("OnClick", function()
                f:Hide()
                OpenInstallDataWizard()
            end)
        elseif hasData then
            OpenDataWizard()
        elseif hasInstall then
            OpenInstallDataWizard()
        else
            print("|cffdd3333[163UI]|r 当前没有任何可安装的配置内容")
        end

    elseif msg == "reset" then
        InitDB()
        ns.CharDB.lastInstallVersion = nil
        print("|cff55ee55[163UI]|r 已清除角色安装记录，下次登录将重新弹出导入提示")

    elseif msg == "resetinstall" then
        InitDB()
        ns.CharDB.processedVersions = {}
        print("|cff55ee55[163UI]|r 已清除角色 InstallData 安装记录，下次登录将重新弹出")

    elseif msg == "resetall" then
        InitDB()
        ns.CharDB.lastInstallVersion = nil
        ns.AccountDB.ignoreVersion   = nil
        ns.CharDB.processedVersions  = {}
        print("|cff55ee55[163UI]|r 已清除所有版本记录（账号 + 角色级）")

    elseif msg == "version" then
        local dataVer    = (ns.Data and ns.Data.version) or "（无 Data.lua）"
        local installedV = ns.CharDB.lastInstallVersion or "（未安装）"
        local ignoredV   = ns.AccountDB.ignoreVersion   or "（无）"
        print(string.format(
            "|cff00ccff[163UI]|r Data版本: %s  角色已安装: %s  账号忽略: %s",
            dataVer, installedV, ignoredV
        ))

    elseif msg == "list" then
        InitDB()
        local id = ns.InstallData
        local processed = ns.CharDB.processedVersions or {}
        print("|cff00ccff[163UI] InstallData 条目列表：|r")
        local emList = (id and id.editMode) or {}
        local cdList = (id and id.coolDown) or {}
        if #emList == 0 and #cdList == 0 then
            print("  （空）")
            return
        end
        for i, e in ipairs(emList) do
            local status = processed[e.version] and "|cff888888已处理|r" or "|cff55ee55待处理|r"
            print(string.format("  [EM %d] %s  %s  %s", i, status, e.version or "?", e.name or "?"))
        end
        for i, e in ipairs(cdList) do
            local status = processed[e.version] and "|cff888888已处理|r" or "|cff55ee55待处理|r"
            print(string.format("  [CD %d] %s  %s  %s (specTag=%s)", i, status, e.version or "?", e.name or "?", tostring(e.specTag)))
        end

    else
        print("|cff00ccff[163UI] 指令帮助：|r")
        print("  |cffffffff/ddui|r              — 打开配置导入向导")
        print("  |cffffffff/ddui reset|r        — 重置 Data 安装记录")
        print("  |cffffffff/ddui resetinstall|r — 重置 InstallData 安装记录")
        print("  |cffffffff/ddui resetall|r     — 重置所有版本记录")
        print("  |cffffffff/ddui version|r      — 查看版本信息")
        print("  |cffffffff/ddui list|r         — 列出 InstallData 条目")
    end
end

SLASH_DDUI1 = "/ddui"
SLASH_DDUI2 = "/163ui"
SlashCmdList["DDUI"] = HandleUnifiedSlash
