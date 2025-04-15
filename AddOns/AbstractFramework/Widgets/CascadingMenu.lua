---@class AbstractFramework
local AF = _G.AbstractFramework

local current_root
local selection_path = {}

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local menus = {}

local function CreateMenu(level)
    local menu = AF.CreateScrollList(level > 1 and menus[level - 1] or AF.UIParent, "AFCascadingMenu" .. level, 1, 1, 10, 18, 0, "widget", "accent")
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
    menu:Hide()

    menu.hiddenText = menu:CreateFontString(nil, "OVERLAY", "AF_FONT_NORMAL")
    menu.hiddenText:SetPoint("BOTTOM", menu, "TOP")
    menu.hiddenText:Hide()

    menus[level] = menu
    menu.buttons = {}
    menu.createdButtons = {}

    menu:SetScript("OnShow", function()
        AF.SetFrameLevel(menu, 5)
    end)

    menu:SetScript("OnHide", function()
        menu:Hide()
        if level == 1 then
            current_root = nil
            wipe(selection_path)
        end
    end)

    if level == 1 then
        -- make menu closable by pressing ESC
        tinsert(UISpecialFrames, "AFCascadingMenu1")
    end

    return menu
end

local function LoadItems(items, maxShownItems, level, parentItem)
    local menu = menus[level] or CreateMenu(level)
    wipe(menu.buttons)

    -- Update selection_path if we have a parent item
    if parentItem then
        selection_path[level - 1] = parentItem
    end

    local maxTextWidth = 0
    local hasIcon, hasChildrenSymbol

    for i, item in pairs(items) do
        local b
        if menu.createdButtons[i] then
            b = menu.createdButtons[i]
        else
            b = AF.CreateButton(menu, "AFCascadingMenu" .. level .. "Button" .. i, "accent_transparent", 18, 18, nil, "", "")
            menu.createdButtons[i] = b

            b:EnablePushEffect(false)
            b:SetTextJustifyH("LEFT")

            -- children symbol
            b.childrenSymbol = b:CreateFontString(nil, "OVERLAY", "AF_FONT_NORMAL")
            b.childrenSymbol:SetText(AF.WrapTextInColor(">", "gray"))
            b.childrenSymbol:SetPoint("RIGHT", -2, 0)
            b.childrenSymbol:Hide()

            -- sub menu
            b:HookScript("OnEnter", function()
                if b.childrenItems then
                    LoadItems(b.childrenItems, maxShownItems, level + 1, b.item)
                    AF.ClearPoints(menus[level + 1])
                    AF.SetPoint(menus[level + 1], "TOPLEFT", b, "TOPRIGHT", -5, 2)
                    menus[level + 1]:Show()
                elseif menus[level + 1] then
                    menus[level + 1]:Hide()
                end
            end)
        end

        b:SetText(item.text)
        b:SetEnabled(not item.disabled)

        menu.hiddenText:SetText(item.text:gsub(" ", "_"))
        maxTextWidth = max(maxTextWidth, menu.hiddenText:GetStringWidth())

        if item.icon then
            hasIcon = true
            b:SetTexture(item.icon, {14, 14}, {"LEFT", 2, 0}, item.isIconAtlas, item.iconBorderColor)
        else
            b:HideTexture()
        end

        if item.onClick then
            b:SetScript("OnClick", function()
                if item.notClickable then return end
                item.onClick(item.value)
                if current_root and current_root.OnMenuSelection then
                    tinsert(selection_path, item)
                    current_root:OnMenuSelection(item, selection_path)
                end
                menus[1]:Hide()
            end)
        else
            b:SetScript("OnClick", function()
                if item.notClickable then return end
                if current_root and current_root.OnMenuSelection then
                    tinsert(selection_path, item)
                    current_root:OnMenuSelection(item, selection_path)
                end
                menus[1]:Hide()
            end)
        end

        -- save for onEnter
        b.item = item
        if item.children then
            hasChildrenSymbol = true
            b.childrenItems = item.children
            b.childrenSymbol:Show()
        else
            b.childrenItems = nil
            b.childrenSymbol:Hide()
        end

        tinsert(menu.buttons, b)
    end

    local width = 10
    if hasIcon then
        width = width + AF.ConvertPixels(18)
    end
    if hasChildrenSymbol then
        width = width + 10
    end

    AF.SetWidth(menu, maxTextWidth + width)
    menu:SetSlotNum(min(maxShownItems, #menu.buttons))
    menu:SetWidgets(menu.buttons)
end

---------------------------------------------------------------------
-- close menu
---------------------------------------------------------------------
function AF.CloseCascadingMenu()
    if menus[1] then
        menus[1]:Hide()
    end
end

function AF.RegisterForCloseCascadingMenu(f)
    assert(f and f.HasScript and f:HasScript("OnMouseDown"), "no OnMouseDown for this region!")
    f:HookScript("OnMouseDown", AF.CloseCascadingMenu)
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
-- local items = {
--     {
--         ["text"] = (string),
--         ["value"] = (any),
--         ["icon"] = (string|number),
--         ["iconBorderColor"] = (string),
--         ["isIconAtlas"] = (boolean),
--         ["notClickable"] = (boolean),
--         ["onClick"] = (function),
--         ["disabled"] = (boolean),
--         ["children"] = {...},
--     }, ...
-- }

-- when an item is clicked, will call parent:OnMenuSelection(item, path), if exists
---@param parent Frame
---@param items table
---@param maxShownItems number? default is 10
---@param point string? default is "TOPLEFT"
---@param relativePoint string? default is "BOTTOMLEFT"
---@param x number? default is 0
---@param y number? default is -2
function AF.ShowCascadingMenu(parent, items, maxShownItems, point, relativePoint, x, y)
    current_root = parent
    LoadItems(items, maxShownItems, 1)
    menus[1]:SetParent(parent)
    AF.ClearPoints(menus[1])
    AF.SetPoint(menus[1], point or "TOPLEFT", parent, relativePoint or "BOTTOMLEFT", x or 0, y or -2)
    menus[1]:Show()
end

---------------------------------------------------------------------
-- cascading menu button
---------------------------------------------------------------------
---@class AF_CascadingMenuButton:AF_Button
local AF_CascadingMenuButtonMixin = {}

function AF_CascadingMenuButtonMixin:SetLabel(label, color, font)
    if not self.label then
        self.label = AF.CreateFontString(self, label, color or "white", font)
        self.label:SetJustifyH("LEFT")
        AF.SetPoint(self.label, "BOTTOMLEFT", self, "TOPLEFT", 2, 2)
    end

    self.label.color = color or "white"
    self.label:SetColor(self.enabled and self.label.color or "disabled")
    self.label:SetText(label)
end

function AF_CascadingMenuButtonMixin:SetEnabled(enabled)
    self.enabled = enabled
    self:_SetEnabled(enabled)

    if self.label then
        self.label:SetColor(enabled and self.label.color or "disabled")
    end

    if not enabled and current_root == self then
        menus[1]:Hide()
    end
end

-- override this function to handle the selection of the menu
---@param item table item that was clicked
---@param path table path to the item
function AF_CascadingMenuButtonMixin:OnMenuSelection(item, path)
    self:SetText(item.text)
    if item.icon then
        self:SetTexture(item.icon, {14, 14}, {"LEFT", 3, 0}, item.isIconAtlas, item.iconBorderColor)
    else
        self:HideTexture()
    end
end

local function UpdateValueForItem(item)
    if not item.value then
        item.value = item.text
    end
    if item.children then
        for _, child in ipairs(item.children) do
            UpdateValueForItem(child)
        end
    end
end

function AF_CascadingMenuButtonMixin:SetItems(items)
    -- validate item.value
    for _, item in ipairs(items) do
        UpdateValueForItem(item)
    end
    self.items = items
end

function AF_CascadingMenuButtonMixin:LoadItems()
    if not self.items then return end
    current_root = self
    LoadItems(self.items, self.maxShownItems, 1)
    menus[1]:SetParent(self)
    AF.ClearPoints(menus[1])
    AF.SetPoint(menus[1], "TOPLEFT", self, "BOTTOMLEFT", 0, -2)
    AF.SetPoint(menus[1], "TOPRIGHT", self, "BOTTOMRIGHT", 0, -2)
    menus[1]:Show()
end

function AF_CascadingMenuButtonMixin:ToggleMenu()
    if current_root == self and menus[1] and menus[1]:IsShown() then
        menus[1]:Hide()
    else
        self:LoadItems()
    end
end

---@param parent Frame
---@param width number
---@param items table
---@param maxShownItems number? default is 10
---@return AF_CascadingMenuButton
function AF.CreateCascadingMenuButton(parent, width, maxShownItems)
    local menu = AF.CreateButton(parent, "", "accent_hover", width, 20)
    menu:SetTextJustifyH("LEFT")

    menu.maxShownItems = maxShownItems or 10
    menu.enabled = true
    menu._SetEnabled = menu.SetEnabled
    Mixin(menu, AF_CascadingMenuButtonMixin)

    menu:SetScript("OnClick", menu.ToggleMenu)
    AF.RegisterForCloseDropdown(menu)

    return menu
end