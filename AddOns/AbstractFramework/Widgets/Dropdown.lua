---@class AbstractFramework
local AF = _G.AbstractFramework

local list, horizontalList

---------------------------------------------------------------------
-- list
---------------------------------------------------------------------
local function CreateListFrame()
    list = AF.CreateScrollList(AF.UIParent, "AFDropdownList", 1, 1, 10, 18, 0, "widget")
    list:SetClampedToScreen(true)
    list:SetIgnoreParentScale(true)
    list:SetFrameStrata("FULLSCREEN_DIALOG")
    list:Hide()

    -- adjust scrollBar points
    AF.SetPoint(list.scrollBar, "TOPRIGHT")
    AF.SetPoint(list.scrollBar, "BOTTOMRIGHT")

    -- make list closable by pressing ESC
    tinsert(_G.UISpecialFrames, "AFDropdownList")

    -- make list closable by clicking outside
    list:SetScript("OnEvent", function()
        if not (list:IsMouseOver() or list.dropdown:IsMouseOver()) then
            AF.CloseDropdown()
        end
    end)

    -- store created buttons
    list.buttons = {}

    -- highlight
    local highlight = AF.CreateBorderedFrame(list, nil, 100, 100, "none", "accent")
    highlight:Hide()

    function list:SetHighlightItem(i)
        if not i then
            highlight:ClearAllPoints()
            highlight:Hide()
        else
            highlight:SetParent(list.buttons[i]) -- NOTE: buttons show/hide automatically when scroll
            highlight:ClearAllPoints()
            highlight:SetAllPoints(list.buttons[i])
            highlight:Show()
        end
    end

    list:SetScript("OnHide", function()
        list:UnregisterEvent("GLOBAL_MOUSE_DOWN")
        list:Hide()
    end)

    -- do not use OnShow, since it only triggers when hide -> show
    hooksecurefunc(list, "Show", function()
        list:RegisterEvent("GLOBAL_MOUSE_DOWN")
        list:SetScale(list.dropdown:GetEffectiveScale())

        horizontalList:Hide()
        list:UpdatePixels()
        highlight:UpdatePixels()

        local scrollThumb = list.scrollThumb
        scrollThumb.r, scrollThumb.g, scrollThumb.b = AF.GetColorRGB(list.dropdown.accentColor)
        scrollThumb:SetBackdropColor(scrollThumb.r, scrollThumb.g, scrollThumb.b, 0.7)
        highlight:SetBackdropBorderColor(scrollThumb.r, scrollThumb.g, scrollThumb.b)

        if list.dropdown.selected then
            if list.dropdown.selected > list.slotNum then
                list:SetScroll(list.dropdown.selected - list.slotNum + 1)
            else
                list:SetScroll(1)
            end
        end
    end)
end

---------------------------------------------------------------------
-- horizontalList
---------------------------------------------------------------------
local function CreateHorizontalList()
    horizontalList = AF.CreateBorderedFrame(AF.UIParent, "AFHorizontalDropdownList", 10, 20, "widget")
    horizontalList:SetClampedToScreen(true)
    horizontalList:SetIgnoreParentScale(true)
    horizontalList:SetFrameStrata("FULLSCREEN_DIALOG")
    horizontalList:Hide()

    -- make list closable by pressing ESC
    tinsert(_G.UISpecialFrames, "AFHorizontalDropdownList")

    -- make list closable by clicking outside
    horizontalList:SetScript("OnEvent", function()
        if not (horizontalList:IsMouseOver() or horizontalList.dropdown:IsMouseOver()) then
            AF.CloseDropdown()
        end
    end)

    -- store created buttons
    horizontalList.buttons = {}

    function horizontalList:Reset()
        for _, b in pairs(horizontalList.buttons) do
            b:Hide()
        end
    end

    -- highlight
    local highlight = AF.CreateBorderedFrame(horizontalList, nil, 100, 100, "none", "accent")
    highlight:Hide()

    function horizontalList:SetHighlightItem(i)
        if not i then
            highlight:ClearAllPoints()
            highlight:Hide()
        else
            highlight:SetParent(horizontalList.buttons[i]) -- NOTE: buttons show/hide automatically when scroll
            highlight:ClearAllPoints()
            highlight:SetAllPoints(horizontalList.buttons[i])
            highlight:Show()
        end
    end

    horizontalList:SetScript("OnHide", function()
        horizontalList:UnregisterEvent("GLOBAL_MOUSE_DOWN")
        horizontalList:Hide()
    end)

    -- do not use OnShow, since it only triggers when hide -> show
    hooksecurefunc(horizontalList, "Show", function()
        horizontalList:RegisterEvent("GLOBAL_MOUSE_DOWN")
        horizontalList:SetScale(horizontalList.dropdown:GetEffectiveScale())

        list:Hide()
        horizontalList:UpdatePixels()
        highlight:UpdatePixels()

        highlight:SetBackdropBorderColor(AF.GetColorRGB(horizontalList.dropdown.accentColor))

        for _, b in pairs(horizontalList.buttons) do
            b:UpdatePixels()
        end
    end)
end

---------------------------------------------------------------------
-- close dropdown
---------------------------------------------------------------------
function AF.CloseDropdown()
    if list then
        list:Hide()
        if list.dropdown and not list.dropdown.miniMode then
            list.dropdown.button:SetTexture(AF.GetIcon("ArrowDown1"))
        end
    end
    if horizontalList then
        horizontalList:Hide()
    end
end

-- function AF.RegisterForCloseDropdown(f)
--     assert(f and f.HasScript and f:HasScript("OnMouseDown"), "no OnMouseDown for this region!")
--     f:HookScript("OnMouseDown", AF.CloseDropdown)
-- end

---------------------------------------------------------------------
-- dropdown menu
---------------------------------------------------------------------
---@class AF_Dropdown:AF_BorderedFrame
local AF_DropdownMixin = {}

-- selection ------------------------------------
local function SetSelected(dropdown, type, v)
    local found
    for i, item in pairs(dropdown.items) do
        if item[type] == v then
            dropdown.selected = i
            dropdown.text:SetText(item.text)

            if item.texture then
                dropdown.bgTexture:SetTexture(item.texture)
                dropdown.bgTexture:Show()
            else
                dropdown.bgTexture:Hide()
            end

            if item.font then
                dropdown.text:SetFont(AF.GetFontProps(item.font))
            else
                dropdown.text:SetFont(AF.GetFontProps("normal"))
            end

            if item.icon then
                AF.SetPoint(dropdown.text, "LEFT", dropdown.iconBG, "RIGHT", 2, 0)
                dropdown.icon:SetTexture(item.icon)
                dropdown.iconBG:Show()
                dropdown.icon:Show()
            else
                AF.SetPoint(dropdown.text, "LEFT", 5, 0)
                dropdown.iconBG:Hide()
                dropdown.icon:Hide()
            end

            found = true
            break
        end
    end
    if not found then
        dropdown:ClearSelected()
    end
end

function AF_DropdownMixin:SetSelectedText(text)
    SetSelected(self, "text", text)
end

function AF_DropdownMixin:SetSelectedValue(value)
    SetSelected(self, "value", value)
end
AF_DropdownMixin.SetSelected = AF_DropdownMixin.SetSelectedValue

function AF_DropdownMixin:ClearSelected()
    self.selected = nil
    self.text:SetText("")
    self.bgTexture:Hide()
    self.list:SetHighlightItem()
end

---@return any value
---@return string text
function AF_DropdownMixin:GetSelected()
    if self.selected and self.items[self.selected] then
        return self.items[self.selected].value, self.items[self.selected].text
    end
end
AF_DropdownMixin.GetSelectedValue = AF_DropdownMixin.GetSelected
-------------------------------------------------

-- label
function AF_DropdownMixin:SetLabel(label, color, font)
    if not self.label then
        self.label = AF.CreateFontString(self, label, color or "white", font)
        self.label:SetJustifyH("LEFT")
        AF.SetPoint(self.label, "BOTTOMLEFT", self, "TOPLEFT", 2, 2)
    end

    self.label.color = color or "white"
    self.label:SetColor(self.enabled and self.label.color or "disabled")
    self.label:SetText(label)
end

-- iconBGColor
function AF_DropdownMixin:SetIconBGColor(color)
    self.iconBGColor = color
    if color then
        self.iconBG:SetColorTexture(AF.GetColorRGB(color))
        AF.SetOnePixelInside(self.icon, self.iconBG)
    else
        self.iconBG:SetColorTexture(0, 0, 0, 0)
        AF.SetAllPoints(self.icon, self.iconBG)
    end
    self.reloadRequired = true
end

-- update items ---------------------------------
-- {
--     {
--         ["text"] = (string),
--         ["value"] = (any),
--         ["texture"] = (string),
--         ["font"] = (string),
--         ["icon"] = (string),
--         ["disabled"] = (boolean),
--         ["callback|onClick"] = (function)
--     },
-- }

---@param items table array of items (table|string|number)
function AF_DropdownMixin:SetItems(items)
    -- validate items
    for i, item in ipairs(items) do
        if type(item) ~= "table" then
            items[i] = {
                text = item,
                value = item,
            }
        else
            if not item.value then item.value = item.text end
            item.callback = item.callback or item.onClick -- for backward compatibility
        end
    end

    local selectedValue = self.selected and self.items and self.items[self.selected] and self.items[self.selected].value
    self.items = items
    self.reloadRequired = true

    if selectedValue then
        -- try re-setting selected item
        SetSelected(self, "value", selectedValue)
    end
end

---@param item table
---@param pos? number
function AF_DropdownMixin:AddItem(item, pos)
    -- validate item.value
    if not item.value then item.value = item.text end
    if pos then
        tinsert(self.items, pos, item)
    else
        tinsert(self.items, item)
    end
    self.reloadRequired = true
end

function AF_DropdownMixin:RemoveCurrentItem()
    tremove(self.items, self.selected)
    self:ClearSelected()
    self.reloadRequired = true
end

function AF_DropdownMixin:ClearItems()
    wipe(self.items)
    self:ClearSelected()
    self.reloadRequired = true
end

function AF_DropdownMixin:SetCurrentItem(item)
    self.items[self.selected] = item

    if item.texture then
        self.bgTexture:SetTexture(item.texture)
        self.bgTexture:Show()
    else
        self.bgTexture:Hide()
    end

    if item.font then
        self.text:SetFont(AF.GetFontProps(item.font))
    else
        self.text:SetFont(AF.GetFontProps("normal"))
    end

    -- usually, update current item means to change its name (text) and func
    self.text:SetText(item.text)

    self.reloadRequired = true
end
-------------------------------------------------

-- onSelect -------------------------------------
---@param fn fun(value: any, button: AF_Button|nil)
function AF_DropdownMixin:SetOnSelect(fn)
    self.callback = fn
end

---@deprecated
AF_DropdownMixin.SetOnClick = AF_DropdownMixin.SetOnSelect
-------------------------------------------------

function AF_DropdownMixin:LoadItems()
    wipe(self.buttons)
    self.reloadRequired = nil
    -- hide highlight
    self.list:SetHighlightItem()
    -- hide all buttons
    self.list:Reset()

    -- load current dropdown
    for i, item in pairs(self.items) do
        local b
        if not self.list.buttons[i] then
            -- create new button
            b = AF.CreateButton(self.miniMode == "horizontal" and self.list or self.list.slotFrame, item.text, "accent_transparent", 18, 18, nil, "", "")
            table.insert(self.list.buttons, b)

            b:EnablePushEffect(false)

            b.bgTexture = AF.CreateTexture(b)
            AF.SetPoint(b.bgTexture, "TOPLEFT", 1, -1)
            AF.SetPoint(b.bgTexture, "BOTTOMRIGHT", -1, 1)
            b.bgTexture:SetVertexColor(AF.GetColorRGB("white", self.textureAlpha))
            b.bgTexture:Hide()

            AF.AddToFontSizeUpdater(b.text)

            function b:Update()
                --! NOTE: invoked in SetScroll, or text may be "invisible"
                if b._font then
                    C_Timer.NewTicker(0, function()
                        b:SetFont(AF.GetFontProps(b._font))
                        b.text:SetText("TEST TEST TEST TEST TEST") -- force update text
                        b.text:SetText(b._text)
                    end, 2)
                end
            end
        else
            -- re-use button
            b = self.list.buttons[i]
            b:SetText(item.text)
        end

        tinsert(self.buttons, b)
        b:SetEnabled(not item.disabled)
        b:SetColor(self.accentColor .. "_transparent")

        -- icon
        if item.icon then
            b:SetTexture(item.icon, {16, 16}, {"LEFT", 1, 0}, nil, self.iconBGColor)
            b.realTexture:SetDesaturated(item.disabled)
        else
            b:HideTexture()
        end

        -- texture
        if item.texture then
            b.bgTexture:SetTexture(item.texture)
            b.bgTexture:Show()
        else
            b.bgTexture:Hide()
        end

        -- font
        if item.font then
            -- set
            b:SetFont(AF.GetFontProps(item.font))
            b._font = item.font
            b._text = item.text
        else
            -- restore
            b:SetFont(AF.GetFontProps("normal"))
            b._font = nil
            b._text = nil
        end

        -- highlight
        if self.selected == i then
            self.list:SetHighlightItem(i)
        end

        b:SetScript("OnClick", function()
            self:SetSelectedValue(item.value)
            self.list:Hide()
            if item.callback then
                -- NOTE: item.callback has higher priority
                item.callback(item.value, self)
            elseif self.callback then
                self.callback(item.value)
            end
            if not self.miniMode then self.button:SetTexture(AF.GetIcon("ArrowDown1")) end
        end)

        -- text justify
        if self.miniMode then
            b:SetTextJustifyH(self.justify or "CENTER")
        else
            b:SetTextJustifyH(self.justify or "LEFT")
        end

        -- update point
        if self.miniMode == "horizontal" then
            AF.SetWidth(b, self.width)
            if i == 1 then
                AF.SetPoint(b, "TOPLEFT", 1, -1)
            else
                AF.SetPoint(b, "TOPLEFT", self.list.buttons[i-1], "TOPRIGHT")
            end
            b:Show()
        end
    end

    -- update list size / point
    self.list.dropdown = self -- check for menu's OnHide -> list:Hide
    -- self.list:SetParent(self)
    -- AF.SetFrameLevel(self.list, 10, self)
    AF.ClearPoints(self.list)

    if self.miniMode == "horizontal" then
        AF.SetPoint(self.list, "TOPLEFT", self, "TOPRIGHT", 2, 0)
        AF.SetHeight(self.list, 20)

        if #self.items == 0 then
            AF.SetWidth(self.list, 5)
        else
            AF.SetListWidth(self.list, #self.items, self.width, 0, 1, 1)
        end

    else -- using scroll list
        AF.SetPoint(self.list, "TOPLEFT", self, "BOTTOMLEFT", 0, -2)
        AF.SetPoint(self.list, "TOPRIGHT", self, "BOTTOMRIGHT", 0, -2)
        -- AF.SetWidth(self.list, width)

        self.list:SetSlotNum(min(#self.buttons, self.maxSlots))
        self.list:SetWidgets(self.buttons)
    end
end

function AF_DropdownMixin:SetEnabled(enabled)
    self.enabled = enabled
    self.button:SetEnabled(enabled)
    self.text:SetColor(enabled and "white" or "disabled")

    self.icon:SetDesaturated(not enabled)

    if self.bgTexture then
        self.bgTexture:SetAlpha(enabled and 1 or 0.25)
        self.bgTexture:SetDesaturated(not enabled)
    end

    if self.label then
        self.label:SetColor(enabled and self.label.color or "disabled")
    end

    if not enabled and self.list.dropdown == self then
        self.list:Hide()
    end
end

function AF_DropdownMixin:SetTooltip(...)
    AF.SetTooltip(self, "TOPLEFT", 0, 2, ...)
end

---@param parent Frame
---@param width? number
---@param maxSlots? number max shown items, not available for mini horizontal dropdown, default 10
---@param miniMode? string "vertical" or "horizontal", if set, dropdown will be mini mode
---@param textureAlpha? number default 0.75
---@param justify? string
---@return AF_Dropdown
function AF.CreateDropdown(parent, width, maxSlots, miniMode, textureAlpha, justify)
    if not list then CreateListFrame() end
    if not horizontalList then CreateHorizontalList() end

    maxSlots = maxSlots or 10
    textureAlpha = textureAlpha or 0.75

    local dropdown = AF.CreateBorderedFrame(parent, nil, width, 20, "widget")
    dropdown:EnableMouse(true)

    dropdown.accentColor = AF.GetAddonAccentColorName()

    dropdown.enabled = true
    dropdown.width = width
    dropdown.maxSlots = maxSlots
    dropdown.miniMode = miniMode and miniMode:lower()
    dropdown.textureAlpha = textureAlpha
    dropdown.justify = justify
    dropdown.list = miniMode == "horizontal" and horizontalList or list

    Mixin(dropdown, AF_DropdownMixin)

    -- button: open/close menu list
    if miniMode then
        dropdown.button = AF.CreateButton(dropdown, nil, "accent_hover", 20, 20)
        dropdown.button:SetAllPoints(dropdown)
        dropdown.button:EnablePushEffect(false)

        -- text
        dropdown.text = AF.CreateFontString(dropdown.button)
        AF.SetPoint(dropdown.text, "LEFT", 5, 0)
        AF.SetPoint(dropdown.text, "RIGHT", -5, 0)
        dropdown.text:SetJustifyH(justify or "CENTER")
    else
        dropdown.button = AF.CreateButton(dropdown, nil, "accent_hover", 18, 20)
        dropdown.button:SetPoint("TOPRIGHT")
        dropdown.button:SetPoint("BOTTOMRIGHT")
        dropdown.button:SetTexture(AF.GetIcon("ArrowDown1"), {16, 16}, {"CENTER", 0, 0})
        -- menu.button:SetBackdropColor(AF.GetColorRGB("none"))
        -- menu.button._color = AF.GetColorTable("none")

        -- text
        dropdown.text = AF.CreateFontString(dropdown)
        AF.SetPoint(dropdown.text, "LEFT", 5, 0)
        AF.SetPoint(dropdown.text, "RIGHT", dropdown.button, "LEFT", -5, 0)
        dropdown.text:SetJustifyH(justify or "LEFT")
    end

    dropdown.button:SetColor(dropdown.accentColor .. "_hover")

    -- iconBG
    dropdown.iconBG = AF.CreateTexture(miniMode and dropdown.button or dropdown, nil, nil, "ARTWORK", -2)
    AF.SetSize(dropdown.iconBG, 16, 16)
    AF.SetPoint(dropdown.iconBG, "TOPLEFT", 2, -2)
    dropdown.iconBG:Hide()

    -- icon
    dropdown.icon = AF.CreateTexture(miniMode and dropdown.button or dropdown, nil, nil, "ARTWORK", 0)
    dropdown.icon:Hide()
    dropdown:SetIconBGColor("black")

    AF.AddToFontSizeUpdater(dropdown.text)

    -- highlight
    -- menu.highlight = AF.CreateTexture(menu, nil, AF.GetColorTable("accent", 0.07))
    -- AF.SetPoint(menu.highlight, "TOPLEFT", 1, -1)
    -- AF.SetPoint(menu.highlight, "BOTTOMRIGHT", -1, 1)
    -- menu.highlight:Hide()

    -- hook for tooltips
    dropdown.button:HookScript("OnEnter", function()
        if dropdown._tooltip then
            dropdown:GetScript("OnEnter")()
        end
    end)
    dropdown.button:HookScript("OnLeave", function()
        if dropdown._tooltip then
            dropdown:GetScript("OnLeave")()
        end
    end)

    -- selected item
    dropdown.text:SetWordWrap(false)

    -- bgTexture
    dropdown.bgTexture = AF.CreateTexture(miniMode and dropdown.button or dropdown)
    AF.SetPoint(dropdown.bgTexture, "TOPLEFT", 1, -1)
    if miniMode then
        AF.SetPoint(dropdown.bgTexture, "BOTTOMRIGHT", -1, 1)
    else
        AF.SetPoint(dropdown.bgTexture, "BOTTOMRIGHT", dropdown.button, "BOTTOMLEFT", 0, 1)
    end
    dropdown.bgTexture:SetVertexColor(AF.GetColorRGB("white", textureAlpha))
    dropdown.bgTexture:Hide()

    -- keep all menu item definitions
    dropdown.items = {
        -- {
        --     ["text"] = (string),
        --     ["value"] = (any),
        --     ["texture"] = (string),
        --     ["font"] = (string),
        --     ["icon"] = (string),
        --     ["disabled"] = (boolean),
        --     ["callback|onClick"] = (function)
        -- },
    }

    -- index in items
    -- menu.selected

    dropdown.buttons = {}

    dropdown:SetScript("OnHide", function()
        if dropdown.list.dropdown == dropdown then
            dropdown.list:Hide()
            if not miniMode then dropdown.button:SetTexture(AF.GetIcon("ArrowDown1")) end
        end
    end)

    -- scripts
    dropdown.button:SetScript("OnClick", function(self, button)
        if button ~= "LeftButton" then
            dropdown.list:Hide()
            return
        end

        if dropdown.list.dropdown ~= dropdown then -- list shown by other dropdown
            if dropdown.list.dropdown and not dropdown.list.dropdown.miniMode then
                -- restore previous menu's button texture
                dropdown.list.dropdown.button:SetTexture(AF.GetIcon("ArrowDown1"))
            end
            dropdown:LoadItems()
            dropdown.list:Show()
            if not miniMode then dropdown.button:SetTexture(AF.GetIcon("ArrowUp1")) end

        elseif dropdown.list:IsShown() then -- list showing by this, hide it
            dropdown.list:Hide()
            if not miniMode then dropdown.button:SetTexture(AF.GetIcon("ArrowDown1")) end

        else
            if dropdown.reloadRequired then
                dropdown:LoadItems()
            else
                -- update highlight
                if dropdown.selected then
                    dropdown.list:SetHighlightItem(dropdown.selected)
                end
            end
            dropdown.list:Show()
            if not miniMode then dropdown.button:SetTexture(AF.GetIcon("ArrowUp1")) end
        end
    end)

    return dropdown
end

---------------------------------------------------------------------
-- some frequently used dropdown items
---------------------------------------------------------------------
local L = AF.L

function AF.GetDropdownItems_AnchorPoint(noCenter)
    local items = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT"}
    if not noCenter then
        tinsert(items, "CENTER")
    end
    for i, item in next, items do
        items[i] = {text = L[item], value = item}
    end
    return items
end

function AF.GetDropdownItems_Modifier()
    return {
        {text = "Alt", value = "ALT"},
        {text = "Ctrl", value = "CTRL"},
        {text = "Shift", value = "SHIFT"},
        {text = _G.NONE, value = "NONE"},
    }
end

function AF.GetDropdownItems_Arrangement_Simple()
    return {
        {text = L["Left to Right"], value = "left_to_right"},
        {text = L["Right to Left"], value = "right_to_left"},
        {text = L["Top to Bottom"], value = "top_to_bottom"},
        {text = L["Bottom to Top"], value = "bottom_to_top"},
    }
end

function AF.GetDropdownItems_Arrangement_Complex()
    return {
        {text = L["Left to Right, then Up"], value = "left_to_right_then_up"},
        {text = L["Left to Right, then Down"], value = "left_to_right_then_down"},
        {text = L["Right to Left, then Up"], value = "right_to_left_then_up"},
        {text = L["Right to Left, then Down"], value = "right_to_left_then_down"},
        {text = L["Top to Bottom, then Left"], value = "top_to_bottom_then_left"},
        {text = L["Top to Bottom, then Right"], value = "top_to_bottom_then_right"},
        {text = L["Bottom to Top, then Left"], value = "bottom_to_top_then_left"},
        {text = L["Bottom to Top, then Right"], value = "bottom_to_top_then_right"},
    }
end

function AF.GetDropdownItems_Class()
    local items = {}

    for class in AF.IterateClasses() do
        tinsert(items, {text = AF.WrapTextInColor(AF.GetLocalizedClassName(class), class), value = class})
    end

    return items
end

function AF.GetDropdownItems_FrameStrata(allStratas)
    if allStratas then
        return {
            {text = "BACKGROUND"},
            {text = "LOW"},
            {text = "MEDIUM"},
            {text = "HIGH"},
            {text = "DIALOG"},
            {text = "FULLSCREEN"},
            {text = "FULLSCREEN_DIALOG"},
            {text = "TOOLTIP"},
        }
    else
        return {
            {text = "LOW"},
            {text = "MEDIUM"},
            {text = "HIGH"},
        }
    end
end