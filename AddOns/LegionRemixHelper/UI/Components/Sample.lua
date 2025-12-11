---@class AddonPrivate
local Private = select(2, ...)

Private.Components = Private.Components or {}

---@class SampleComponentObject: SampleComponentMixin

---@class SampleComponentOptions
---@field frame_strata FrameStrata?
---@field width number?
---@field height number?
---@field anchors table?
local defaultOptions = {
    frame_strata = "HIGH",
    width = 150,
    height = 20,
    anchors = {
        { "CENTER" }
    },
}

---@class SampleComponent
---@field defaultOptions SampleComponentOptions
local sampleComponent = {
    defaultOptions = defaultOptions,
}
Private.Components.Sample = sampleComponent

local componentsBase = Private.Components.Base

---@class SampleComponentMixin
---@field sample table|Frame
local sampleComponentMixin = {}

---@param parent Frame?
---@param options SampleComponentOptions
---@return SampleComponentObject sampleFrame
function sampleComponent:CreateFrame(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    options = componentsBase:MixTables(defaultOptions, options)

    local dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1FilterDropdownTemplate")
    dropdown:SetFrameStrata(options.frame_strata)
    dropdown:SetSize(options.width, options.height)

    for _, anchor in ipairs(options.anchors) do
        dropdown:SetPoint(unpack(anchor))
    end

    return self:CreateObject(dropdown)
end

---@param dropdown table|Frame
---@return SampleComponentObject
function sampleComponent:CreateObject(dropdown)
    local obj = {}
    obj.dropdown = dropdown

    setmetatable(obj, { __index = sampleComponentMixin })
    return obj
end
