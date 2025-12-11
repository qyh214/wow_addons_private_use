---@class AddonPrivate
local Private = select(2, ...)

Private.Components = Private.Components or {}

---@class LabelComponentObject: LabelComponentMixin

---@class LabelComponentOptions
---@field frame_strata FrameStrata?
---@field width number?
---@field height number?
---@field anchors table?
---@field text string?
---@field color table?
---@field font string?
---@field justifyH "LEFT"|"CENTER"|"RIGHT"?
---@field justifyV "TOP"|"MIDDLE"|"BOTTOM"?
local defaultOptions = {
    frame_strata = "HIGH",
    width = 150,
    height = 20,
    anchors = {
        { "CENTER" },
    },
    text = "",
    color = CreateColor(1, 1, 1, 1),
    font = "GameFontNormal",
    justifyH = "LEFT",
    justifyV = "MIDDLE",
}

---@class LabelComponent
---@field defaultOptions LabelComponentOptions
local labelComponent = {
    defaultOptions = defaultOptions,
}
Private.Components.Label = labelComponent

local componentsBase = Private.Components.Base

---@class LabelComponentMixin
---@field frame Frame
---@field textFS FontString
local labelComponentMixin = {}

function labelComponentMixin:SetText(text)
    self.textFS:SetText(text or "")
end

function labelComponentMixin:GetText()
    return self.textFS:GetText()
end

function labelComponentMixin:SetTextColor(r, g, b, a)
    self.textFS:SetTextColor(r, g, b, a)
end

function labelComponentMixin:SetFontObject(fontObject)
    self.textFS:SetFontObject(fontObject or "GameFontNormal")
end

function labelComponentMixin:SetJustifyH(justify)
    self.textFS:SetJustifyH(justify or "LEFT")
end

function labelComponentMixin:SetJustifyV(justify)
    self.textFS:SetJustifyV(justify or "MIDDLE")
end

function labelComponentMixin:SetWordWrap(enabled)
    self.textFS:SetWordWrap(not not enabled)
end

---@param parent Frame?
---@param options LabelComponentOptions
---@return LabelComponentObject label
function labelComponent:CreateFrame(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    options = componentsBase:MixTables(defaultOptions, options)

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata(options.frame_strata)
    frame:SetSize(options.width, options.height)

    for _, anchor in ipairs(options.anchors) do
        frame:SetPoint(unpack(anchor))
    end

    local textFS = frame:CreateFontString(nil, "ARTWORK", options.font)
    textFS:SetAllPoints(frame)
    textFS:SetJustifyH(options.justifyH)
    textFS:SetJustifyV(options.justifyV)
    if options.text then
        textFS:SetText(options.text)
    end
    if options.color then
        textFS:SetTextColor(options.color:GetRGBA())
    end

    return self:CreateObject(frame, textFS)
end

---@param frame Frame
---@param textFS FontString
---@return LabelComponentObject
function labelComponent:CreateObject(frame, textFS)
    local obj = {}
    obj.frame = frame
    obj.textFS = textFS

    setmetatable(obj, { __index = labelComponentMixin })
    return obj
end
