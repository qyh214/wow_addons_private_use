---@class AddonPrivate
local Private = select(2, ...)

Private.Components = Private.Components or {}

---@class RoundedIconComponentObject: RoundedIconComponentMixin

---@class RoundedIconComponentOptions
---@field frame_strata FrameStrata?
---@field width number?
---@field height number?
---@field anchors table?
---@field show_tooltip boolean?
---@field onClick ?fun(button:string)
local defaultOptions = {
    frame_strata = "HIGH",
    width = 40,
    height = 40,
    anchors = nil,
    show_tooltip = true,
    onClick = nil,
}

---@class RoundedIconComponent
---@field defaultOptions RoundedIconComponentOptions
local roundedIconComponent = {
    defaultOptions = defaultOptions,
}
Private.Components.RoundedIcon = roundedIconComponent

local componentsBase = Private.Components.Base

---@class RoundedIconComponentMixin
---@field icon Texture
---@field frame table|Frame
---@field link string?
local roundedIconComponentMixin = {}

function roundedIconComponentMixin:SetLink(link)
    self.frame.link = link
end

function roundedIconComponentMixin:SetTexture(texture)
    SetPortraitToTexture(self.icon, texture)
end

---@param parent Frame?
---@param options RoundedIconComponentOptions
---@return RoundedIconComponentObject roundedIconFrame
function roundedIconComponent:CreateFrame(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    options = componentsBase:MixTables(defaultOptions, options)

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata(options.frame_strata)
    frame:SetSize(options.width, options.height)
    if options.anchors then
        for _, anchor in ipairs(options.anchors) do
            frame:SetPoint(unpack(anchor))
        end
    end

    local ring = frame:CreateTexture(nil, "OVERLAY")
    ring:SetAtlas("spec-sampleabilityring")
    ring:SetAllPoints()

    local icon = frame:CreateTexture()
    icon:SetAllPoints()

    if options.show_tooltip then
        frame:SetScript("OnEnter", function()
            if not frame.link then return end
            GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(frame.link)
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    if options.onClick then
        frame:EnableMouse(true)
        frame:SetScript("OnMouseDown", function(_, button)
            options.onClick(frame, button)
        end)
    end

    return self:CreateObject(frame, icon)
end

---@param frame Frame
---@param icon Texture
---@return RoundedIconComponentObject
function roundedIconComponent:CreateObject(frame, icon)
    local obj = {}
    obj.icon = icon
    obj.frame = frame

    setmetatable(obj, { __index = roundedIconComponentMixin })
    return obj
end
