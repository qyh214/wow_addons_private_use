---@class AddonPrivate
local Private = select(2, ...)

Private.Components = Private.Components or {}

---@class DropdownComponentObject: DropdownComponentMixin

---@class DropdownComponentOptions
---@field frame_strata FrameStrata?
---@field width number?
---@field height number?
---@field anchors table?
---@field template string?
---@field defaultText string?
---@field setupMenu ?fun(dropdown:table, rootDescription:RootMenuDescriptionProxy)
---@field dropdownType "DROPDOWN"|"RADIO"|?
---@field onSelect ?fun(value:any)
---@field isSelected ?fun(value:any):boolean
---@field radioOptions table<string, any>|?
---@field defaultSelection any|?
local defaultOptions = {
    frame_strata = "HIGH",
    width = 150,
    height = 25,
    anchors = {
        { "CENTER" }
    },
    template = "WowStyle1DropdownTemplate",
    defaultText = Private.L["Components.Dropdown.SelectOption"],
    setupMenu = nil,
    dropdownType = "DROPDOWN",
    onSelect = nil,
    isSelected = nil,
    radioOptions = nil,
    defaultSelection = nil,
}

---@class DropdownComponent
---@field defaultOptions DropdownComponentOptions
local dropdownComponent = {
    defaultOptions = defaultOptions,
}
Private.Components.Dropdown = dropdownComponent

local componentsBase = Private.Components.Base

---@class DropdownComponentMixin
---@field dropdown table|Frame
local dropdownComponentMixin = {}

function dropdownComponentMixin:GetDropdown()
    return self.dropdown
end

---@param parent Frame?
---@param options DropdownComponentOptions
---@return DropdownComponentObject dropdownFrame
function dropdownComponent:CreateFrame(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    local resizeToText = true
    if options.width then
        resizeToText = false
    end
    options = componentsBase:MixTables(defaultOptions, options)

    local dropdown = CreateFrame("DropdownButton", nil, parent, options.template)
    dropdown:SetFrameStrata(options.frame_strata)
    dropdown.resizeToText = resizeToText
    dropdown:SetSize(options.width, options.height)
    for _, anchor in ipairs(options.anchors) do
        dropdown:SetPoint(unpack(anchor))
    end

    if dropdown.SetDefaultText then
        dropdown:SetDefaultText(options.defaultText)
    end

    dropdown.selectedValue = options.defaultSelection
    function dropdown.SetSelection(value)
        dropdown.selectedValue = value
        if options.onSelect then
            options.onSelect(value)
        end
        dropdown:SignalUpdate()
    end

    function dropdown.isSelected(value)
        if options.isSelected then
            return options.isSelected(value)
        end
        return dropdown.selectedValue == value
    end

    if options.dropdownType == "DROPDOWN" and options.setupMenu then
        dropdown:SetupMenu(options.setupMenu)
    elseif options.dropdownType == "RADIO" and options.radioOptions then
        MenuUtil.CreateRadioMenu(dropdown,
            dropdown.isSelected,
            dropdown.SetSelection,
            unpack(options.radioOptions)
        )
    end

    return self:CreateObject(dropdown)
end

---@param dropdown table|Frame
---@return DropdownComponentObject
function dropdownComponent:CreateObject(dropdown)
    local obj = {}
    obj.dropdown = dropdown

    setmetatable(obj, { __index = dropdownComponentMixin })
    return obj
end
