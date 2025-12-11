---@class AddonPrivate
local Private = select(2, ...)

Private.Components = Private.Components or {}

---@class CheckBoxComponentObject: CheckBoxComponentMixin

---@class CheckBoxComponentOptions
---@field frame_strata FrameStrata?
---@field width number?
---@field height number?
---@field anchors table?
---@field template string?
---@field text string?
---@field color table?
---@field font string?
---@field checked boolean?
---@field onClick fun(checked:boolean)?
local defaultOptions = {
    frame_strata = "HIGH",
    width = 30,
    height = 29,
    anchors = {
        { "CENTER" },
    },
    template = "MinimalCheckboxTemplate",
    text = "",
    color = CreateColor(1, 1, 1, 1),
    font = "GameFontNormal",
    checked = false,
    onClick = nil,
}

---@class CheckBoxComponent
---@field defaultOptions CheckBoxComponentOptions
local checkBoxComponent = {
    defaultOptions = defaultOptions,
}
Private.Components.CheckBox = checkBoxComponent

local componentsBase = Private.Components.Base

---@class CheckBoxComponentMixin
---@field checkButton CheckButton
---@field labelFS FontString
local checkBoxComponentMixin = {}

function checkBoxComponentMixin:SetChecked(checked)
    self.checkButton:SetChecked(not not checked)
end

function checkBoxComponentMixin:GetChecked()
    return self.checkButton:GetChecked()
end

function checkBoxComponentMixin:SetText(text)
    self.labelFS:SetText(text or "")
    self:_updateHitRect()
end

function checkBoxComponentMixin:GetText()
    return self.labelFS:GetText()
end

function checkBoxComponentMixin:SetTextColor(r, g, b, a)
    self.labelFS:SetTextColor(r, g, b, a)
end

function checkBoxComponentMixin:SetLabelFontObject(fontObject)
    self.labelFS:SetFontObject(fontObject or "GameFontNormal")
    self:_updateHitRect()
end

function checkBoxComponentMixin:SetEnabled(enabled)
    self.checkButton:SetEnabled(not not enabled)
    self.labelFS:SetAlpha(enabled and 1 or 0.5)
end

function checkBoxComponentMixin:SetOnClick(callback)
    self._onClick = callback
end

function checkBoxComponentMixin:_updateHitRect()
    local pad = 6
    local w = self.labelFS:GetStringWidth() or 0
    -- Extend the clickable area to include the label
    self.checkButton:SetHitRectInsets(0, -(w + pad), 0, 0)
end

---@param parent Frame?
---@param options CheckBoxComponentOptions
---@return CheckBoxComponentObject checkBox
function checkBoxComponent:CreateFrame(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    options = componentsBase:MixTables(defaultOptions, options)

    local btn = CreateFrame("CheckButton", nil, parent, options.template)
    btn:SetFrameStrata(options.frame_strata)
    btn:SetSize(options.width, options.height)
    for _, anchor in ipairs(options.anchors) do
        btn:SetPoint(unpack(anchor))
    end

    local label = btn:CreateFontString(nil, "ARTWORK", options.font)
    label:SetPoint("LEFT", btn, "RIGHT", 6, 0)
    label:SetJustifyH("LEFT")
    label:SetText(options.text or "")
    if options.color then
        label:SetTextColor(options.color:GetRGBA())
    end

    if options.checked ~= nil then
        btn:SetChecked(options.checked)
    end

    btn:SetScript("OnClick", function()
        if options.onClick then
            options.onClick(btn:GetChecked())
        end
    end)

    return self:CreateObject(btn, label)
end

---@param btn CheckButton
---@param label FontString
---@return CheckBoxComponentObject
function checkBoxComponent:CreateObject(btn, label)
    local obj = {}
    obj.checkButton = btn
    obj.labelFS = label

    setmetatable(obj, { __index = checkBoxComponentMixin })
    return obj
end
