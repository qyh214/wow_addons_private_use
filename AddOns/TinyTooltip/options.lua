
local LibEvent = LibStub:GetLibrary("LibEvent.7000")
local LibDropdown = LibStub:GetLibrary("LibDropdown.7000")

local UIDropDownMenu_SetText = LibDropdown.SetText
local UIDropDownMenu_AddButton = LibDropdown.AddButton
local UIDropDownMenu_CreateInfo = LibDropdown.CreateInfo
local UIDropDownMenu_Initialize = LibDropdown.Initialize
local UIDropDownMenu_GetSelectedValue = LibDropdown.GetSelectedValue
local UIDropDownMenu_SetSelectedValue = LibDropdown.SetSelectedValue
local UIDropDownMenuTemplate = "UIDropDownMenuTemplate"

local addonName = ...
local addon = TinyTooltip
local CopyTable = CopyTable

addon.L = addon.L or {}
setmetatable(addon.L, { __index = function(self, k)
    local s = {strsplit(".", k)}
    return rawget(self,s[#s]) or (s[#s]:gsub("([a-z])([A-Z])", "%1 %2"):gsub("^(%a)", strupper))
end})
local L = addon.L

local function CallTrigger(keystring, value)
    for _, tip in ipairs(addon.tooltips) do
        if (keystring == "general.mask") then
            LibEvent:trigger("tooltip.style.mask", tip, value)
        elseif (keystring == "general.scale") then
            LibEvent:trigger("tooltip.scale", tip, value)
        elseif (keystring == "general.background") then
            LibEvent:trigger("tooltip.style.background", tip, unpack(value))
        elseif (keystring == "general.borderColor") then
            LibEvent:trigger("tooltip.style.border.color", tip, unpack(value))
        elseif (keystring == "general.borderSize") then
            LibEvent:trigger("tooltip.style.border.size", tip, value)
        elseif (keystring == "general.borderCorner") then
            LibEvent:trigger("tooltip.style.border.corner", tip, value)
            if (value == "angular") then
                LibEvent:trigger("tooltip.style.border.size", tip, addon.db.general.borderSize)
            end
        elseif (keystring == "general.bgfile") then
            LibEvent:trigger("tooltip.style.bgfile", tip, value)
        end
    end
    if (keystring == "general.statusbarText") then
        LibEvent:trigger("tooltip.statusbar.text", value)
    elseif (keystring == "general.statusbarHeight") then
        LibEvent:trigger("tooltip.statusbar.height", value)
    elseif (keystring == "general.statusbarTexture") then
        LibEvent:trigger("tooltip.statusbar.texture", value)
    elseif (strfind(keystring, "general.statusbarFont")) then
        LibEvent:trigger("tooltip.statusbar.font", addon.db.general.statusbarFont, addon.db.general.statusbarFontSize, addon.db.general.statusbarFontFlag)
    elseif (strfind(keystring, "general.headerFont")) then
        LibEvent:trigger("tooltip.style.font.header", tip, addon.db.general.headerFont, addon.db.general.headerFontSize, addon.db.general.headerFontFlag)
    elseif (strfind(keystring, "general.bodyFont")) then
        LibEvent:trigger("tooltip.style.font.body", tip, addon.db.general.bodyFont, addon.db.general.bodyFontSize, addon.db.general.bodyFontFlag)
    end
end

local function GetVariable(keystring, tbl)
    if (keystring == "general.SavedVariablesPerCharacter") then
        return BigTipDB.general.SavedVariablesPerCharacter
    end
    local keys = {strsplit(".", keystring)}
    local value = tbl or addon.db
    for i, key in ipairs(keys) do
        if (value[key] == nil) then return end
        value = value[key]
    end
    return value
end

local function SetVariable(keystring, value, tbl)
    local keys = {strsplit(".", keystring)}
    local num = #keys
    local tab = tbl or addon.db
    local lastKey
    for i, key in ipairs(keys) do
        if (i < num) then
            if (not tab[key]) then tab[key] = {} end
            tab = tab[key]
        elseif (i == num) then
            lastKey = key
        end
    end
    tab[lastKey] = value
    CallTrigger(keystring, value)
    LibEvent:trigger("tooltip:variable:changed", keystring, value)
end

local widgets = {}

function widgets:checkbox(parent, config, labelText)
    local frame = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    frame.keystring = config.keystring
    frame.Text:SetText(labelText or L[config.keystring])
    frame:SetChecked(GetVariable(config.keystring))
    frame:SetScript("OnClick", function(self) SetVariable(self.keystring, self:GetChecked()) end)
    return frame
end

function widgets:slider(parent, config)
    local frame = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    frame:SetWidth(118)
    frame.Text = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    frame.Text:SetPoint("LEFT", frame, "RIGHT", 8, 0)
    frame.keystring = config.keystring
    frame.Low:SetText("")
    frame.High:SetTextColor(1, 0.82, 0)
    frame.High:ClearAllPoints()
    frame.High:SetPoint("RIGHT", frame, "LEFT", -1, 0)
    frame.Text:SetText(L[config.keystring])
    frame.High:SetText(GetVariable(config.keystring))
    frame:SetMinMaxValues(config.min, config.max)
    frame:SetValueStep(config.step)
    frame:SetValue(GetVariable(config.keystring))
    frame:SetScript("OnValueChanged", function(self, value)
        local step = self:GetValueStep() or 1
        if (step < 0.1) then
            value = format("%.2f", value)
        elseif (step < 1) then
            value = format("%.1f", value)
        else
            value = floor(value+0.2)
        end
        if (self:GetValue() ~= value) then
            SetVariable(self.keystring, value)
            self.High:SetText(value)
        end
    end)
    return frame
end

function widgets:editbox(parent, config)
    local frame = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    frame.keystring = config.keystring
    frame:SetAutoFocus(false)
    frame:SetSize(88, 14)
    frame:SetText(GetVariable(config.keystring))
    frame:SetCursorPosition(0)
    frame:SetScript("OnEnterPressed", function(self)
        SetVariable(self.keystring, self:GetText())
        self:ClearFocus()
    end)
    return frame
end

function widgets:colorpick(parent, config)
    local a, r, g, b = 1
    if (config.colortype == "hex") then
        r, g, b = addon:GetRGBColor(GetVariable(config.keystring))
    else
        r, g, b, a = unpack(GetVariable(config.keystring))
    end
    local frame = CreateFrame("Button", nil, parent)
    frame.keystring = config.keystring
    frame.colortype = config.colortype
    frame.hasopacity = config.hasopacity
    frame:SetSize(16, 16)
    frame:SetNormalTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetColorTexture(1, 1, 1)
    frame.bg:SetSize(14, 14)
    frame.bg:SetPoint("CENTER")
    frame.Text = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    frame.Text:SetPoint("LEFT", frame, "RIGHT", 5, 0)
    frame.Text:SetText(L[config.keystring])
    frame.Text:SetShown(not config.hidetitle)
    frame:GetNormalTexture():SetVertexColor(r, g, b, a)
    frame:SetScript("OnClick", function(self)
        local r, g, b, a = self:GetNormalTexture():GetVertexColor()
        local info = {
            r = r, g = g, b = b, opacity = 1-a, hasOpacity = self.hasopacity,
            opacityFunc = self.hasopacity and function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local a = 1-format("%.2f", OpacitySliderFrame:GetValue())
                local aa = select(4, ColorPickerFrame.tipframe:GetNormalTexture():GetVertexColor())
                if (a ~= aa) then
                    ColorPickerFrame.tipframe:GetNormalTexture():SetVertexColor(r,g,b,a)
                    SetVariable(ColorPickerFrame.tipframe.keystring, {r,g,b,a})
                end
            end,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local a = 1-format("%.2f", OpacitySliderFrame:GetValue())
                ColorPickerFrame.tipframe:GetNormalTexture():SetVertexColor(r,g,b,a)
                if (ColorPickerFrame.tipframe.colortype == "hex") then
                    SetVariable(ColorPickerFrame.tipframe.keystring, addon:GetHexColor(r,g,b))
                else
                    SetVariable(ColorPickerFrame.tipframe.keystring, {r,g,b,a})
                end
                --for element color
                if (ColorPickerFrame.tipframe:GetParent().colordropdown) then
                    UIDropDownMenu_SetText(ColorPickerFrame.tipframe:GetParent().colordropdown, VIDEO_QUALITY_LABEL6)
                end
            end,
        }
        ColorPickerFrame.tipframe = self
        if (not self.hasopacity) then OpacitySliderFrame:SetValue(info.opacity) end
        OpenColorPicker(info)
    end)
    return frame
end

function widgets:dropdown(parent, config, labelText)
    local frame = CreateFrame("Frame", tostring(config), parent, UIDropDownMenuTemplate)
    frame.keystring = config.keystring
    frame.dropdata = config.dropdata
    if (frame.Text) then frame.Text:SetWidth(90) end
    frame.Label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	frame.Label:SetPoint("LEFT", _G[frame:GetName().."Button"], "RIGHT", 6, 0)
	UIDropDownMenu_Initialize(frame, function(self)
        local keystring = self.keystring
        local selectedValue = UIDropDownMenu_GetSelectedValue(self)
        local info
        for _, v in ipairs(self.dropdata) do
            info = UIDropDownMenu_CreateInfo()
            info.text  = L["dropdown."..v]
            info.value = v
            info.arg1  = self
            info.checked = selectedValue == v
            info.func = function(self, dropdown)
                SetVariable(dropdown.keystring, self.value)
                UIDropDownMenu_SetSelectedValue(dropdown, self.value)
            end
            if (strfind(keystring, ".+Font$")) then
                info.font = addon:GetFont(v)
            elseif (strfind(keystring, ".+Texture$")) then
                info.texture = addon:GetBarFile(v)
                info.staticWidth = 168
            end
            UIDropDownMenu_AddButton(info)
        end
    end, config.displayMode)
    frame.selectedFunc = function(self, value, text)
        local parent = self:GetParent()
        if (not parent or not parent.anchorbutton) then return end
        if (value == "static" or value == "cursor") then
            parent.anchorbutton:Show()
            self.Label:Hide()
        else
            parent.anchorbutton:Hide()
            self.Label:Show()
        end
    end
    UIDropDownMenu_SetSelectedValue(frame, GetVariable(config.keystring))
    frame.Label:SetText(labelText or L[config.keystring])
    return frame
end

local grid = CreateFrame("Frame", nil, UIParent)
grid:SetFrameStrata("DIALOG")
grid:SetAllPoints()
grid:Hide()
do
    local width, height = GetScreenWidth(), GetScreenHeight()
    local w, h, size = 0, 0, 16
    local line
    w = w + floor((width%size)/2)
    while (w < width) do
        w = w + size
        line = grid:CreateTexture(nil, "BACKGROUND")
        line:SetSize(1, height)
        line:SetColorTexture(0, 0, 0, 0.32)
        line:SetPoint("TOPLEFT", w, 0)
    end
    h = h + floor((height%size)/2)
    while (h < height) do
        h = h + size
        line = grid:CreateTexture(nil, "BACKGROUND")
        line:SetSize(width, 1)
        line:SetColorTexture(0, 0, 0, 0.32)
        line:SetPoint("TOPLEFT", 0, -h)
    end
    line = grid:CreateTexture(nil, "BACKGROUND")
    line:SetSize(width, 2)
    line:SetColorTexture(1, 0, 0, 0.6)
    line:SetPoint("CENTER")
    line = grid:CreateTexture(nil, "BACKGROUND")
    line:SetSize(2, height)
    line:SetColorTexture(1, 0, 0, 0.6)
    line:SetPoint("CENTER")
end

local function StaticFrameOnDragStop(self)
    self:StopMovingOrSizing()
    local p = GetVariable(self.cp) or "BOTTOMRIGHT"
    local left, right, top, bottom = self:GetLeft(), self:GetRight(), self:GetTop(), self:GetBottom()
    if (p == "BOTTOMRIGHT") then
        SetVariable(self.kx, floor(right - GetScreenWidth())+4)
        SetVariable(self.ky, floor(bottom)-3)
    elseif (p == "BOTTOMLEFT") then
        SetVariable(self.kx, floor(left)-2)
        SetVariable(self.ky, floor(bottom)-3)
    elseif (p == "TOPLEFT") then
        SetVariable(self.kx, floor(left)-2)
        SetVariable(self.ky, floor(top-GetScreenHeight()))
    elseif (p == "TOPRIGHT") then
        SetVariable(self.kx, floor(right - GetScreenWidth())+4)
        SetVariable(self.ky, floor(top-GetScreenHeight()))
    elseif (p == "TOP") then
        SetVariable(self.kx, floor(left-GetScreenWidth()/2+100))
        SetVariable(self.ky, floor(top-GetScreenHeight()))
    elseif (p == "BOTTOM") then
        SetVariable(self.kx, floor(left-GetScreenWidth()/2+100))
        SetVariable(self.ky, floor(bottom)-3)
    end
end

local function CreateAnchorButton(frame, anchorPoint)
    local button = CreateFrame("Button", nil, frame)
    button.cp = anchorPoint
    button:SetNormalTexture("Interface\\Buttons\\WHITE8X8")
    button:SetSize(20, 20)
    button:SetPoint(anchorPoint)
    button:SetScript("OnClick", function(self)
        local parent = self:GetParent()
        local cp = GetVariable(parent.cp)
        if (parent[cp]) then
            parent[cp]:GetNormalTexture():SetVertexColor(1, 1, 1)
        end
        SetVariable(parent.cp, self.cp)
        self:GetNormalTexture():SetVertexColor(1, 0.2, 0.1)
        StaticFrameOnDragStop(frame)
    end)
    frame[anchorPoint] = button
end
local function CreateAnchorInput(frame, k)
    local box = CreateFrame("EditBox", nil, frame, "NumericInputSpinnerTemplate")
    box:SetNumeric(nil)
    box:SetAutoFocus(false)
    box:SetSize(40, 20)
    box:SetScript("OnEnterPressed", function(self)
        local parent = self:GetParent()
        SetVariable(parent[k], tonumber(self:GetText()) or 0)
        self:ClearFocus()
    end)
    return box
end

local saframe = CreateFrame("Frame", nil, UIParent, "ThinBorderTemplate")
saframe:Hide()
saframe:SetFrameStrata("DIALOG")
saframe.close = CreateFrame("Button", nil, saframe, "UIPanelCloseButton")
saframe.close:SetPoint("CENTER")
saframe:SetClampedToScreen(true)
saframe:EnableMouse(true)
saframe:SetMovable(true)
saframe:SetSize(200, 80)
saframe:RegisterForDrag("LeftButton")
saframe:SetScript("OnDragStart", function(self) self:StartMoving() end)
saframe:SetScript("OnDragStop", StaticFrameOnDragStop)
CreateAnchorButton(saframe, "TOPLEFT")
CreateAnchorButton(saframe, "BOTTOMLEFT")
CreateAnchorButton(saframe, "TOPRIGHT")
CreateAnchorButton(saframe, "BOTTOMRIGHT")
CreateAnchorButton(saframe, "TOP")
CreateAnchorButton(saframe, "BOTTOM")
saframe:SetScript("OnShow", function() grid:Show() end)
saframe:SetScript("OnHide", function() grid:Hide() end)

local caframe = CreateFrame("Frame", nil, UIParent, "ThinBorderTemplate")
caframe:Hide()
caframe:SetFrameStrata("DIALOG")
caframe:SetBackdrop(GameTooltip:GetBackdrop())
caframe:SetBackdropColor(GameTooltip:GetBackdropColor())
caframe:SetSize(200, 200)
caframe:SetPoint("CENTER")
caframe:SetClampedToScreen(true)
caframe:EnableMouse(true)
caframe:SetMovable(true)
caframe:RegisterForDrag("LeftButton")
caframe:SetScript("OnDragStart", function(self) self:StartMoving() end)
caframe:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
caframe.inputx = CreateAnchorInput(caframe, "cx")
caframe.inputx:SetPoint("CENTER", 0, 40)
caframe.inputy = CreateAnchorInput(caframe, "cy")
caframe.inputy:SetPoint("CENTER", 0, 10)
caframe.ok = CreateFrame("Button", nil, caframe, "UIPanelButtonTemplate")
caframe.ok:SetText(SAVE)
caframe.ok:SetSize(68, 20)
caframe.ok:SetPoint("CENTER", 0, -20)
caframe.ok:SetScript("OnClick", function(self)
    local parent = self:GetParent()
    SetVariable(parent.cx, tonumber(parent.inputx:GetText()) or 0)
    SetVariable(parent.cy, tonumber(parent.inputy:GetText()) or 0)
end)
caframe.close = CreateFrame("Button", nil, caframe, "UIPanelCloseButton")
caframe.close:SetPoint("CENTER", 0, -50)
CreateAnchorButton(caframe, "TOPLEFT")
CreateAnchorButton(caframe, "LEFT")
CreateAnchorButton(caframe, "BOTTOMLEFT")
CreateAnchorButton(caframe, "TOP")
CreateAnchorButton(caframe, "BOTTOM")
CreateAnchorButton(caframe, "TOPRIGHT")
CreateAnchorButton(caframe, "RIGHT")
CreateAnchorButton(caframe, "BOTTOMRIGHT")

function widgets:anchorbutton(parent, config)
    local frame = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    frame.keystring = config.keystring
    frame:SetSize(70, 22)
    frame.Text:SetFontObject("GameFontHighlightSmall")
    frame:SetText(L.Anchor)
    frame:SetScript("OnClick", function(self)
        local parent = self:GetParent()
        if saframe:IsShown() then return saframe:Hide() end
        if caframe:IsShown() then return caframe:Hide() end
        if (not parent.dropdown) then return end
        local value = UIDropDownMenu_GetSelectedValue(parent.dropdown)
        if (value == "static") then
            saframe.kx = self.keystring .. ".x"
            saframe.ky = self.keystring .. ".y"
            saframe.cp = self.keystring .. ".p"
            saframe[GetVariable(saframe.cp) or "BOTTOMRIGHT"]:GetNormalTexture():SetVertexColor(1, 0.2, 0.1)
            saframe:SetPoint(GetVariable(saframe.cp) or "BOTTOMRIGHT", UIParent, GetVariable(saframe.cp) or "BOTTOMRIGHT", GetVariable(saframe.kx) or -CONTAINER_OFFSET_X-13, GetVariable(saframe.ky) or CONTAINER_OFFSET_Y)
            saframe:Show()
        elseif (value == "cursor") then
            caframe.cx = self.keystring .. ".cx"
            caframe.cy = self.keystring .. ".cy"
            caframe.cp = self.keystring .. ".cp"
            caframe.inputx:SetText(GetVariable(caframe.cx) or 0)
            caframe.inputy:SetText(GetVariable(caframe.cy) or 0)
            caframe[GetVariable(caframe.cp) or "BOTTOM"]:GetNormalTexture():SetVertexColor(1, 0.2, 0.1)
            caframe:Show()
        end
    end)
    return frame
end

function widgets:element(parent, config)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(560, 30)
    frame:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        insets   = {left = 4, right = 4, top = 4, bottom = 4},
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
    })
    frame:SetBackdropColor(0, 0, 0.1, 0.8)
    frame:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.6)
    frame.checkbox = self:checkbox(frame, {keystring=config.keystring..".enable"}, L[config.keystring])
    frame.checkbox:SetPoint("LEFT", 5, 0)
    if (config.color) then
        frame.colorpick = self:colorpick(frame, {keystring=config.keystring..".color",colortype="hex",hidetitle=true})
        frame.colorpick:SetPoint("LEFT", 285, 0)
        frame.colordropdown = self:dropdown(frame, {keystring=config.keystring..".color",dropdata=self.colorDropdata,displayMode="MENU"}, "")
        frame.colordropdown:SetScale(0.87)
        frame.colordropdown:SetPoint("LEFT", 200, -1)
    end
    if (config.wildcard) then
        frame.editbox = self:editbox(frame, {keystring=config.keystring..".wildcard"})
        frame.editbox:SetPoint("LEFT", 330, 0)
    end
    if (config.filter) then
        frame.filterdropdown = self:dropdown(frame, {keystring=config.keystring..".filter",dropdata=self.filterDropdata}, "")
        frame.filterdropdown:SetScale(0.87)
        frame.filterdropdown:SetPoint("LEFT", 490, -1)
    end
    return frame
end

function widgets:anchor(parent, config)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(400, 30)
    frame.anchorbutton = self:anchorbutton(frame, config)
    frame.dropdown = self:dropdown(frame, {keystring=config.keystring..".position",dropdata=config.dropdata})
    frame.dropdown:SetPoint("LEFT", 0, 0)
    frame.anchorbutton:SetPoint("LEFT", frame.dropdown.Label, "LEFT", 1, 0)
    frame.checkbox1 = self:checkbox(frame, {keystring=config.keystring..".hiddenInCombat"})
    frame.checkbox1:SetPoint("LEFT", frame.dropdown.Label, "RIGHT", 10, -1)
    frame.checkbox2 = self:checkbox(frame, {keystring=config.keystring..".returnInCombat"})
    frame.checkbox2:SetPoint("LEFT", frame.checkbox1.Text, "RIGHT", 3, 0)
    frame.checkbox3 = self:checkbox(frame, {keystring=config.keystring..".returnOnUnitFrame"})
    frame.checkbox3:SetPoint("LEFT", frame.checkbox2.Text, "RIGHT", 3, 0)
    return frame
end

function widgets:dropdownslider(parent, config)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(500, 30)
    frame.dropdown = self:dropdown(frame, {keystring=config.keystring..".colorfunc",dropdata=config.dropdata}, L[config.keystring])
    frame.dropdown:SetPoint("LEFT", 0, 0)
    frame.slider = self:slider(frame, {keystring=config.keystring..".alpha",min=config.min,max=config.max,step=config.step})
    frame.slider:SetPoint("LEFT", frame.dropdown.Label, "RIGHT", 30, 0)
    frame.slider:SetWidth(80)
    return frame
end

widgets.filterDropdata = {"none","ininstance","incombat","inraid","samerealm","samecrossrealm","inpvp","inarena","reaction5","reaction6","not ininstance","not incombat","not inraid","not samerealm","not samecrossrealm","not inpvp","not inarena","not reaction5","not reaction6",}
widgets.colorDropdata = {"default","class","level","reaction","itemQuality","selection","faction",}
widgets.bgfileDropdata = {"gradual","dark","alpha","rock","marble",}
widgets.borderDropdata = {"default","angular",}
widgets.fontDropdata = {"default", "ChatFontNormal", "GameFontNormal", "QuestFont", "CombatLogFont",}
widgets.barDropdata = {"Interface\\AddOns\\"..addonName.."\\texture\\StatusBar",}

LibEvent:attachEvent("VARIABLES_LOADED", function()
    local LibMedia = LibStub:GetLibrary("LibSharedMedia-3.0", true)
    local MergeTable = function(a,b)
        for _, v in pairs(b) do tinsert(a, v) end
        return a
    end
    if (LibMedia) then
        widgets.bgfileDropdata = MergeTable(widgets.bgfileDropdata, LibMedia:List("background"))
        widgets.borderDropdata = MergeTable(widgets.borderDropdata, LibMedia:List("border"))
        widgets.fontDropdata = MergeTable(widgets.fontDropdata, LibMedia:List("font"))
        widgets.barDropdata = MergeTable(widgets.barDropdata, LibMedia:List("statusbar"))
    end
end)

local options = {
    general = {
        { keystring = "general.mask",               type = "checkbox" },
        { keystring = "general.skinMoreFrames",     type = "checkbox" },
        { keystring = "general.background",         type = "colorpick", hasopacity = true },
        { keystring = "general.borderColor",        type = "colorpick", hasopacity = true },
        { keystring = "general.scale",              type = "slider", min = 0.5, max = 4, step = 0.1 },
        { keystring = "general.borderSize",         type = "slider", min = 1, max = 6, step = 1 },
        { keystring = "general.borderCorner",       type = "dropdown", dropdata = widgets.borderDropdata },
        { keystring = "general.bgfile",             type = "dropdown", dropdata = widgets.bgfileDropdata },
        { keystring = "general.anchor",             type = "anchor", dropdata = {"default","cursorRight","cursor","static"} },
        { keystring = "item.coloredItemBorder",     type = "checkbox" },
        { keystring = "item.showItemIcon",          type = "checkbox" },
        { keystring = "quest.coloredQuestBorder",   type = "checkbox" },
        { keystring = "general.alwaysShowIdInfo",   type = "checkbox" },
        { keystring = "general.SavedVariablesPerCharacter",   type = "checkbox" },
    },
    pc = {
        { keystring = "unit.player.showTarget",           type = "checkbox" },
        { keystring = "unit.player.showTargetBy",         type = "checkbox" },
        { keystring = "unit.player.showModel",            type = "checkbox" },
        { keystring = "unit.player.grayForDead",          type = "checkbox" },
        { keystring = "unit.player.coloredBorder",        type = "dropdown", dropdata = widgets.colorDropdata },
        { keystring = "unit.player.background",           type = "dropdownslider", dropdata = widgets.colorDropdata, min = 0, max = 1, step = 0.01 },
        { keystring = "unit.player.anchor",               type = "anchor", dropdata = {"inherit", "default","cursorRight","cursor","static"} },
        { keystring = "unit.player.elements.factionBig",  type = "element", filter = false,},
        { keystring = "unit.player.elements.raidIcon",    type = "element", filter = true, },
        { keystring = "unit.player.elements.roleIcon",    type = "element", filter = true, },
        { keystring = "unit.player.elements.pvpIcon",     type = "element", filter = true, },
        { keystring = "unit.player.elements.factionIcon", type = "element", filter = true, },
        { keystring = "unit.player.elements.classIcon",   type = "element", filter = true, },
        { keystring = "unit.player.elements.title",       type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.name",        type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.realm",       type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.statusAFK",   type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.statusDND",   type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.statusDC",    type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.guildName",   type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.guildIndex",  type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.guildRank",   type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.guildRealm",  type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.levelValue",  type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.factionName", type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.gender",      type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.raceName",    type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.className",   type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.isPlayer",    type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.role",        type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.moveSpeed",   type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.player.elements.zone",        type = "element", color = true, wildcard = true, filter = true, },
    },
    npc = {
        { keystring = "unit.npc.showTarget",            type = "checkbox" },
        { keystring = "unit.npc.showTargetBy",          type = "checkbox" },
        { keystring = "unit.npc.grayForDead",           type = "checkbox" },
        { keystring = "unit.npc.coloredBorder",         type = "dropdown", dropdata = widgets.colorDropdata },
        { keystring = "unit.npc.background",            type = "dropdownslider", dropdata = widgets.colorDropdata, min = 0, max = 1, step = 0.01 },
        { keystring = "unit.npc.anchor",                type = "anchor", dropdata = {"inherit","default","cursorRight","cursor","static"} },
        { keystring = "unit.npc.elements.factionBig",   type = "element", filter = false,},
        { keystring = "unit.npc.elements.raidIcon",     type = "element", filter = true, },
        { keystring = "unit.npc.elements.classIcon",    type = "element", filter = true, },
        { keystring = "unit.npc.elements.questIcon",    type = "element", filter = true, },
        { keystring = "unit.npc.elements.npcTitle",     type = "element", color = true, wildcard = true, },
        { keystring = "unit.npc.elements.name",         type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.npc.elements.levelValue",   type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.npc.elements.classifBoss",  type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.npc.elements.classifElite", type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.npc.elements.classifRare",  type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.npc.elements.creature",     type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.npc.elements.reactionName", type = "element", color = true, wildcard = true, filter = true, },
        { keystring = "unit.npc.elements.moveSpeed",    type = "element", color = true, wildcard = true, filter = true, },
    },
    statusbar = {
        { keystring = "general.statusbarText",      type = "checkbox" },
        { keystring = "general.statusbarHeight",    type = "slider", min = 0, max = 24, step = 1 },
        { keystring = "general.statusbarOffsetX",   type = "slider", min = -50, max = 50, step = 1 },
        { keystring = "general.statusbarOffsetY",   type = "slider", min = -50, max = 50, step = 1 },
        { keystring = "general.statusbarFontSize",  type = "slider", min = 6, max = 30, step = 1 },
        { keystring = "general.statusbarFont",      type = "dropdown", dropdata = widgets.fontDropdata },
        { keystring = "general.statusbarFontFlag",  type = "dropdown", dropdata = {"default", "NORMAL", "OUTLINE", "THINOUTLINE"} },
        { keystring = "general.statusbarTexture",   type = "dropdown", dropdata = widgets.barDropdata },
        { keystring = "general.statusbarPosition",  type = "dropdown", dropdata = {"default","bottom","top"} },
        { keystring = "general.statusbarColor",     type = "dropdown", dropdata = {"default","auto","smooth"} },
    },
    spell = {
        { keystring = "spell.showIcon",             type = "checkbox" },
        { keystring = "spell.background",           type = "colorpick", hasopacity = true },
        { keystring = "spell.borderColor",          type = "colorpick", hasopacity = true },
    },
    font = {
        { keystring = "general.headerFont",         type = "dropdown", dropdata = widgets.fontDropdata },
        { keystring = "general.headerFontSize",     type = "dropdown", dropdata = {"default", 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 } },
        { keystring = "general.headerFontFlag",     type = "dropdown", dropdata = {"default", "NORMAL", "OUTLINE", "THINOUTLINE"} },
        { keystring = "general.bodyFont",           type = "dropdown", dropdata = widgets.fontDropdata },
        { keystring = "general.bodyFontSize",       type = "dropdown", dropdata = {"default", 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 } },
        { keystring = "general.bodyFontFlag",       type = "dropdown", dropdata = {"default", "NORMAL", "OUTLINE", "THINOUTLINE"} },
    },
}

local frame = CreateFrame("Frame", nil, UIParent)
frame.anchor = CreateFrame("Frame", nil, frame)
frame.anchor:SetPoint("TOPLEFT", 32, -16)
frame.anchor:SetSize(InterfaceOptionsFramePanelContainer:GetWidth()-64, 1)
frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.title:SetPoint("TOPLEFT", 18, -16)
frame.title:SetText(format("%s |cff33eeff%s|r", addonName, "General"))
frame.name = addonName

local framePC = CreateFrame("Frame", nil, UIParent)
framePC.anchor = CreateFrame("Frame", nil, framePC)
framePC.anchor:SetPoint("TOPLEFT", 32, -13)
framePC.anchor:SetSize(InterfaceOptionsFramePanelContainer:GetWidth()-64, 1)
framePC.title = framePC:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
framePC.title:SetPoint("TOPLEFT", 18, -16)
framePC.title:SetText(format("%s |cff33eeff%s|r", addonName, "Unit Is Player"))
framePC.parent = addonName
framePC.name = " - Player"

framePC.diy = CreateFrame("Button", nil, framePC)
framePC.diy:SetSize(400, 67)
framePC.diy:SetScale(0.68)
framePC.diy:SetPoint("TOPLEFT", 360, -100)
framePC.diy:SetNormalTexture("Interface\\LevelUp\\MinorTalents")
framePC.diy:GetNormalTexture():SetTexCoord(0, 400/512, 341/512, 407/512)
framePC.diy:GetNormalTexture():SetVertexColor(1, 1, 1, 0.8)
framePC.diy:SetScript("OnClick", function() LibEvent:trigger("tinytooltip:diy:player", "player", true) end)
framePC.diy.text = framePC.diy:CreateFontString(nil, "OVERLAY", "GameFont_Gigantic")
framePC.diy.text:SetPoint("CENTER", 0, 2)
framePC.diy.text:SetText(L.DIY)

framePC:SetSize(500, #options.pc*29+60)
local framePCScrollFrame = CreateFrame("ScrollFrame", nil, UIParent, "UIPanelScrollFrameTemplate")
framePCScrollFrame.ScrollBar:Hide()
framePCScrollFrame.ScrollBar:ClearAllPoints()
framePCScrollFrame.ScrollBar:SetPoint("TOPLEFT", framePCScrollFrame, "TOPRIGHT", -20, -20)
framePCScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", framePCScrollFrame, "BOTTOMRIGHT", -20, 20)
framePCScrollFrame:HookScript("OnScrollRangeChanged", function(self, xrange, yrange)
    self.ScrollBar:SetShown(floor(yrange) ~= 0)
end)
framePCScrollFrame:SetScrollChild(framePC)
framePCScrollFrame.parent = addonName
framePCScrollFrame.name = " - Player"


local frameNPC = CreateFrame("Frame", nil, UIParent)
frameNPC.anchor = CreateFrame("Frame", nil, frameNPC)
frameNPC.anchor:SetPoint("TOPLEFT", 32, -16)
frameNPC.anchor:SetSize(InterfaceOptionsFramePanelContainer:GetWidth()-64, 1)
frameNPC.title = frameNPC:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frameNPC.title:SetPoint("TOPLEFT", 18, -16)
frameNPC.title:SetText(format("%s |cff33eeff%s|r", addonName, "Unit Is NPC"))
frameNPC.parent = addonName
frameNPC.name = " - NPC"

local frameStatusbar = CreateFrame("Frame", nil, UIParent)
frameStatusbar.anchor = CreateFrame("Frame", nil, frameStatusbar)
frameStatusbar.anchor:SetPoint("TOPLEFT", 32, -16)
frameStatusbar.anchor:SetSize(InterfaceOptionsFramePanelContainer:GetWidth()-64, 1)
frameStatusbar.title = frameStatusbar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frameStatusbar.title:SetPoint("TOPLEFT", 18, -16)
frameStatusbar.title:SetText(format("%s |cff33eeff%s|r", addonName, "StatusBar"))
frameStatusbar.parent = addonName
frameStatusbar.name = " - StatusBar"

local frameSpell = CreateFrame("Frame", nil, UIParent)
frameSpell.anchor = CreateFrame("Frame", nil, frameSpell)
frameSpell.anchor:SetPoint("TOPLEFT", 32, -16)
frameSpell.anchor:SetSize(InterfaceOptionsFramePanelContainer:GetWidth()-64, 1)
frameSpell.title = frameSpell:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frameSpell.title:SetPoint("TOPLEFT", 18, -16)
frameSpell.title:SetText(format("%s |cff33eeff%s|r", addonName, "Spell"))
frameSpell.parent = addonName
frameSpell.name = " - Spell"

local frameFont = CreateFrame("Frame", nil, UIParent)
frameFont.anchor = CreateFrame("Frame", nil, frameFont)
frameFont.anchor:SetPoint("TOPLEFT", 32, -16)
frameFont.anchor:SetSize(InterfaceOptionsFramePanelContainer:GetWidth()-64, 1)
frameFont.title = frameFont:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frameFont.title:SetPoint("TOPLEFT", 18, -16)
frameFont.title:SetText(format("%s |cff33eeff%s|r", addonName, "Font"))
frameFont.parent = addonName
frameFont.name = " - Font"

local frameVariables = CreateFrame("Frame", nil, UIParent)
frameVariables.anchor = CreateFrame("Frame", nil, frameVariables)
frameVariables.anchor:SetPoint("TOPLEFT", 32, -16)
frameVariables.anchor:SetSize(InterfaceOptionsFramePanelContainer:GetWidth()-64, 1)
frameVariables.title = frameVariables:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frameVariables.title:SetPoint("TOPLEFT", 18, -16)
frameVariables.title:SetText(format("%s |cff33eeff%s|r", addonName, "Variables"))
frameVariables.parent = addonName
frameVariables.name = " - Variables"

local function InitVariablesFrame()
    
end

local function InitOptions(list, parent, height)
    local element, offsetX
    for i, v in ipairs(list) do
        if (widgets[v.type]) then
            if (v.type == "colorpick") then offsetX = 5
            elseif (v.type == "slider") then offsetX = 15
            elseif (v.type == "dropdown" or v.type == "dropdownslider") then offsetX = -15
            elseif (v.type == "anchor") then offsetX = -15
            else offsetX = 0 end
            element = widgets[v.type](widgets, parent, v)
            element:SetPoint("TOPLEFT", parent.anchor, "BOTTOMLEFT", offsetX, -(i*height))
        end
    end
end

LibEvent:attachEvent("VARIABLES_LOADED", function()
    InitOptions(options.general, frame, 32)
    InitOptions(options.pc, framePC, 29)
    InitOptions(options.npc, frameNPC, 27)
    InitOptions(options.statusbar, frameStatusbar, 36)
    InitOptions(options.spell, frameSpell, 32)
    InitOptions(options.font, frameFont, 32)
    InitVariablesFrame()
end)

InterfaceOptions_AddCategory(frame)
InterfaceOptions_AddCategory(framePCScrollFrame)
InterfaceOptions_AddCategory(frameNPC)
InterfaceOptions_AddCategory(frameStatusbar)
InterfaceOptions_AddCategory(frameSpell)
InterfaceOptions_AddCategory(frameFont)
InterfaceOptions_AddCategory(frameVariables)
SLASH_TinyTooltip1 = "/tinytooltip"
SLASH_TinyTooltip2 = "/tt"
SLASH_TinyTooltip3 = "/tip"
function SlashCmdList.TinyTooltip(msg, editbox)
    if (msg == "reset") then
        BigTipDB = {}
    elseif (msg == "npc") then
        InterfaceOptionsFrame_OpenToCategory(frameNPC)
        InterfaceOptionsFrame_OpenToCategory(frameNPC)
    elseif (msg == "player") then
        InterfaceOptionsFrame_OpenToCategory(framePCScrollFrame)
        InterfaceOptionsFrame_OpenToCategory(framePCScrollFrame)
    elseif (msg == "spell") then
        InterfaceOptionsFrame_OpenToCategory(frameSpell)
        InterfaceOptionsFrame_OpenToCategory(frameSpell)
    elseif (msg == "statusbar") then
        InterfaceOptionsFrame_OpenToCategory(frameStatusbar)
        InterfaceOptionsFrame_OpenToCategory(frameStatusbar)
    else
        InterfaceOptionsFrame_OpenToCategory(frameStatusbar)
        InterfaceOptionsFrame_OpenToCategory(frameStatusbar)
        InterfaceOptionsFrame_OpenToCategory(frame)
    end
end


----------------
-- DIY Frame 
----------------

local diytable = {}

local frame = CreateFrame("Frame", nil, UIParent)
tinsert(addon.tooltips, frame)
frame:Hide()
frame:SetFrameStrata("DIALOG")
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetSize(300, 200)
frame:SetPoint("CENTER", 0, 100)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
frame.lines, frame.elements = {}, {}
frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
frame.close:SetPoint("TOPRIGHT", 3, 3)

local DraggingButton, OverButton, OverLine

local function OnDragStart(self)
    DraggingButton = self
    local cursorX, cursorY = GetCursorPosition()
    local uiScale = UIParent:GetScale()
    self:StartMoving()
    self:ClearAllPoints()
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX/uiScale, cursorY/uiScale)
end

local function OnDragStop(self)
    DraggingButton = false
    self:StopMovingOrSizing()
    if (OverButton) then
        OverButton.vbar:Hide()
        for _, v in ipairs(diytable) do
            for i = #v, 1, -1 do
                if (v[i] == self.key) then
                    tremove(v, i)
                end
            end
            for i = #v, 1, -1 do
                if (v[i] == OverButton.key) then
                    tinsert(v, i, self.key)
                end
            end
        end
        OverButton = false
    end
    if (OverLine) then
        OverLine.border:Hide()
        for _, v in ipairs(diytable) do
            for i = #v, 1, -1 do
                if (v[i] == self.key) then
                    tremove(v, i)
                end
            end
        end
        if (not diytable[OverLine.line]) then diytable[OverLine.line] = {} end
        tinsert(diytable[OverLine.line], self.key)
        OverLine = false
    end
    for i = #diytable, 1, -1 do
        if (#diytable[i] == 0) then tremove(diytable, i) end
    end
    LibEvent:trigger("tinytooltip:diy:player", "player", true)
end

local function CreateElement(parent, key)
    if (not parent.elements[key]) then
        local button = CreateFrame("Button", nil, parent)
        button.key = key
        button:SetSize(40, 20)
        button:SetMovable(true)
        button.text = button:CreateFontString(nil, "ARTWORK", "GameTooltipText")
        button.text:SetPoint("LEFT")
        button.vbar = button:CreateTexture(nil, "OVERLAY")
        button.vbar:SetPoint("TOPLEFT", 0, 0)
        button.vbar:SetPoint("BOTTOMLEFT", 2, 0)
        button.vbar:SetColorTexture(1, 0.8, 0)
        button.vbar:Hide()
        button:RegisterForDrag("LeftButton")
        button:SetScript("OnDragStart", OnDragStart)
        button:SetScript("OnDragStop", OnDragStop)
        button.SetText = function(self, text)
            self.text:SetText(text)
            self:SetWidth(self.text:GetWidth()+4)
        end
        parent.elements[key] = button
    end
    return parent.elements[key]
end

local function CreateLine(parent, lineNumber)
    if (not parent.lines[lineNumber]) then
        local line = CreateFrame("Frame", nil, parent)
        line:SetSize(300, 24)
        line.line = lineNumber
        line.border = CreateFrame("Frame", nil, line)
        line.border:SetAllPoints()
        line.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
        line.border:SetBackdropBorderColor(1, 0.9, 0.1)
        line.border:Hide()
        parent.lines[lineNumber] = line
    end
    return parent.lines[lineNumber]
end

frame:SetScript("OnUpdate", function(self, elasped)
    if (not DraggingButton) then return end
    self.timer = (self.timer or 0) + elasped
    if (self.timer < 0.15) then return end
    self.timer = 0
    local hasoverbtn = false
    for i, v in ipairs(diytable) do
        for ii, e in ipairs(v) do
            if (self.elements[e].key ~= DraggingButton.key and self.elements[e]:IsMouseOver()) then
                OverButton = self.elements[e]
                OverButton.vbar:Show()
                hasoverbtn = true
            else
                self.elements[e].vbar:Hide()
            end
        end
    end
    if (not hasoverbtn) then
        for i, f in ipairs(self.lines) do
            if (f:IsMouseOver()) then
                OverLine = f
                f.border:Show()
            else
                f.border:Hide()
            end
        end
    elseif (OverLine) then
        OverLine.border:Hide()
        OverLine = false
    end
end)


local placeholder = {
    statusAFK = "AFK",
    statusDND = "DND",
    statusDC  = "DC",
}
setmetatable(placeholder, {__index = function(_, k) return k end})

LibEvent:attachTrigger("tinytooltip:diy:player", function(self, unit, skipDisable)
    local raw = addon:GetUnitInfo(unit)
    local frameWidth, lineWidth, totalLines = 0, 0, 0
    local config, value
    for i, v in ipairs(diytable) do
        lineWidth = 0
        CreateLine(frame, i)
        for ii, e in ipairs(v) do
            CreateElement(frame, e)
            config = addon.db.unit.player.elements[e]
            if (skipDisable and not config.enable) then
                frame.elements[e]:Hide()
            else
                value = raw[e] or placeholder[e]
                if (config.color and config.wildcard) then
                    value = addon:FormatData(value, config, raw)
                end
                frame.elements[e]:Show()
                frame.elements[e]:SetText(value)
                frame.elements[e]:ClearAllPoints()
                frame.elements[e]:SetPoint("LEFT", frame.lines[i], "LEFT", lineWidth, 0)
                lineWidth = lineWidth + frame.elements[e]:GetWidth()
            end
        end
        if (lineWidth > frameWidth) then
            frameWidth = lineWidth + 16
        end
        totalLines = i
    end
    totalLines = totalLines + 1
    frame:SetWidth(frameWidth+28)
    frame:SetHeight(totalLines*24+32)
    for i = 1, totalLines do
        f = CreateLine(frame, i)
        f:Show()
        f:SetWidth(frameWidth)
        f:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -(i*25)+25-20)
    end
    while (frame.lines[totalLines+1]) do
        frame.lines[totalLines+1]:Hide()
        totalLines = totalLines + 1
    end
    frame:Show()
end)

LibEvent:attachTrigger("tooltip:variables:loaded", function()
    diytable = addon.db.unit.player.elements
end)

LibEvent:attachTrigger("tooltip:variable:changed", function(self, keystring, value)
    if (frame:IsShown()) then
        LibEvent:trigger("tinytooltip:diy:player", "player", true)
    end
    if (keystring == "general.SavedVariablesPerCharacter") then
        BigTipDB.general.SavedVariablesPerCharacter = value
        if (value) then
            local db = CopyTable(addon.db)
            addon.db = addon:MergeVariable(db, TinyTooltipCharacterDB)
        else
            addon.db = BigTipDB
        end
        LibEvent:trigger("tooltip:variables:loaded")
        LibEvent:trigger("TINYTOOLTIP_GENERAL_INIT")
    end
end)
