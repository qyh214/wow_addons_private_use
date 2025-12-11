---@class AddonPrivate
local Private = select(2, ...)

Private.Components = Private.Components or {}

---@class ItemIconComponentObject: ItemIconComponentMixin

---@class ItemIconComponentOptions
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

---@class ItemIconComponent
---@field defaultOptions ItemIconComponentOptions
local itemIconComponent = {
    defaultOptions = defaultOptions,
}
Private.Components.ItemIcon = itemIconComponent

local componentsBase = Private.Components.Base

---@class ItemIconComponentMixin
---@field icon Texture
---@field frame table|Frame
---@field border Texture
---@field itemLink string?
local itemIconComponentMixin = {}

---@param itemLink string?
function itemIconComponentMixin:SetItem(itemLink)
    self.frame.itemLink = itemLink

    local icon = C_Item.GetItemIconByID(itemLink)
    self.icon:SetTexture(icon)

    self:SetBorder(C_Item.GetItemQualityByID(itemLink))
end

---@param itemQuality Enum.ItemQuality
function itemIconComponentMixin:SetBorder(itemQuality)
    local const = Private.constants
    local borderAtlas = const.ITEM_QUALITY_BORDERS[itemQuality] or const.ITEM_QUALITY_BORDERS[Enum.ItemQuality.Common]
    self.border:SetAtlas(borderAtlas)
end

---@param parent Frame?
---@param options ItemIconComponentOptions
---@return ItemIconComponentObject itemIconFrame
function itemIconComponent:CreateFrame(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    options = componentsBase:MixTables(defaultOptions, options)

    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetFrameStrata(options.frame_strata)
    frame:SetSize(options.width, options.height)
    if options.anchors then
        for _, anchor in ipairs(options.anchors) do
            frame:SetPoint(unpack(anchor))
        end
    end

    local icon = frame:CreateTexture()
    icon:SetAllPoints()

    local border = frame:CreateTexture()
    border:SetDrawLayer("ARTWORK", 1)
    border:SetAtlas("loottoast-itemborder-green")
    border:SetAllPoints()

    local mouseOver = frame:CreateTexture(nil, "OVERLAY")
    mouseOver:SetAllPoints()
    mouseOver:SetAtlas("UI-HUD-ActionBar-IconFrame-Mouseover")
    mouseOver:Hide()

    if options.show_tooltip then
        frame:SetScript("OnEnter", function()
            mouseOver:Show()
            GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(frame.itemLink)
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function()
            mouseOver:Hide()
            GameTooltip:Hide()
        end)
    end

    if options.onClick then
        frame:EnableMouse(true)
        frame:SetScript("OnMouseDown", function(_, button)
            options.onClick(frame, button)
        end)
    end

    return self:CreateObject(frame, icon, border)
end

---@param frame Frame
---@param icon Texture
---@param border Texture
---@return ItemIconComponentObject
function itemIconComponent:CreateObject(frame, icon, border)
    local obj = {}
    obj.icon = icon
    obj.frame = frame
    obj.border = border

    setmetatable(obj, { __index = itemIconComponentMixin })
    return obj
end
