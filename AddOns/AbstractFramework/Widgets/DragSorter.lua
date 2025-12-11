---@class AbstractFramework
local AF = _G.AbstractFramework

local sort = table.sort

---------------------------------------------------------------------
-- mover tip
---------------------------------------------------------------------
local moverTip

local function MoverTip_SetData(widget)
    moverTip.text:SetText(widget.tipText)

    if widget.tipIcon then
        moverTip.icon:SetIcon(widget.tipIcon, widget.tipIconIsAtlas)
        moverTip.icon:SetBackgroundColor(widget.tipIconNoBG and "none" or "black")
        moverTip.icon:Show()
        AF.SetPoint(moverTip.text, "LEFT", moverTip.icon, "RIGHT", 5, 0)
        AF.ResizeToFitText(moverTip, moverTip.text, 28)
    else
        moverTip.icon:Hide()
        AF.SetPoint(moverTip.text, "LEFT", moverTip, 5, 0)
        AF.ResizeToFitText(moverTip, moverTip.text, 7)
    end
end

local function CreateMoverTip()
    moverTip = AF.CreateBorderedFrame(AF.UIParent, "AFDragSorterMoverTip", nil, 20)

    local icon = AF.CreateIcon(moverTip, nil, 16)
    moverTip.icon = icon
    AF.SetPoint(icon, "TOPLEFT", moverTip, 2, -2)

    local text = AF.CreateFontString(moverTip)
    moverTip.text = text
    AF.SetPoint(text, "LEFT", icon, "RIGHT", 5, 0)
    -- AF.SetPoint(text, "RIGHT", moverTip, -2, 0)
end

---------------------------------------------------------------------
-- drag and drop
---------------------------------------------------------------------
local function IsWidgetDisabled(widget)
    return widget and widget.disabled or (widget.IsEnabled and not widget:IsEnabled())
end

local function FindTargetWidget()
    local owner = moverTip.owner
    if not (owner and owner.configTable) then return end

    for i, slot in next, owner.slots do
        if moverTip.from.index ~= i and slot:IsMouseOver() and not IsWidgetDisabled(slot.widget) then
            -- print(moverTip.from.index, "->", i)
            AF.MoveElementToIndex(owner.configTable, moverTip.from.index, i)
            owner:Refresh()
            break
        end
    end
end

local function OnDragStart(widget)
    if IsWidgetDisabled(widget) then return end
    if not moverTip then  CreateMoverTip() end

    moverTip:Show()
    moverTip:SetBackdropBorderColor(AF.GetColorRGB(widget.accentColor))
    moverTip:SetParent(widget)
    AF.SetFrameLevel(moverTip, 20)

    MoverTip_SetData(widget)
    AF.AttachToCursor(moverTip, "BOTTOMLEFT", 5, 0)

    moverTip.from = widget
    moverTip.owner = widget._owner
end

local function OnDragStop(widget)
    if IsWidgetDisabled(widget) then return end
    if not moverTip then return end

    AF.DetachFromCursor(moverTip)
    moverTip:Hide()

    FindTargetWidget()

    moverTip.from = nil
    moverTip.owner = nil
end

local function RegisterDragAndDrop(widget)
    -- widget:RegisterForDrag("LeftButton")
    if not widget._dragSorterHooked then
        widget._dragSorterHooked = true
        widget:HookScript("OnMouseDown", OnDragStart)
        widget:HookScript("OnMouseUp", OnDragStop)
    end
end

---------------------------------------------------------------------
-- AF_DragSorter
---------------------------------------------------------------------
---@class AF_DragSorter
local AF_DragSorterMixin = {}

local function SortWidgets(self)
    if not self.widgets or not self.configTable then
        return
    end

    local configOrder = AF.TransposeTable(self.configTable)

    sort(self.widgets, function(a, b)
        local aOrder = configOrder[a.value]
        local bOrder = configOrder[b.value]

        -- both have config values, sort by config order
        if aOrder and bOrder then
            return aOrder < bOrder
        end

        -- only a has config value, a comes first
        if aOrder and not bOrder then
            return true
        end

        -- only b has config value, b comes first
        if not aOrder and bOrder then
            return false
        end

        -- neither has config value, sort by defaultOrder
        return a.defaultOrder < b.defaultOrder
    end)
end

-- update widget positions based on configTable, and invoke the callback
function AF_DragSorterMixin:Refresh()
    if type(self.widgets) ~= "table" or #self.widgets == 0 then
        for _, slot in next, self.slots do
            slot:Hide()
        end
    end

    -- sort
    SortWidgets(self)

    -- update position
    for i, slot in next, self.slots do
        if self.widgets[i] then
            self.widgets[i].index = i
            self.widgets[i]:SetParent(slot)
            self.widgets[i]:SetAllPoints(slot)
            RegisterDragAndDrop(self.widgets[i])

            slot.widget = self.widgets[i]
            slot:Show()
        else
            slot:Hide()
        end
    end

    -- callback
    if type(self.callback) == "function" then
        self.callback(self.configTable)
    end
end

--[[
    widget.value = (any)
            └─ the value associated with the widget, it's the same value in the config table

    widget.tipText = (string)
            └─ text to display in the mover tip

    widget.tipIcon = (string|nil)
            └─ icon to display in the mover tip

    widget.tipIconIsAtlas = (boolean|nil)
            └─ whether the mover tip icon is an atlas

    widget.tipIconNoBG = (boolean|nil)
            └─ whether the mover tip icon should have a black background/border

    widget.defaultOrder = (number|nil)
            └─ if not set, will use the index in the widgets table

    widget.disabled
            ├─ if true, it will not respond to drag and drop events
            └─ if widget:IsEnabled() exists, it will use that to determine whether the widget is draggable

    widget.index
            ├─ the index of the widget in the sorted list, set by the sorter
            └─ do not modify this value directly
]]
function AF_DragSorterMixin:SetWidgets(widgets)
    assert(type(widgets) == "table", "AF_DragSorter:SetWidgets expects a table of widgets.")

    -- check required fields
    for i, widget in next, widgets do
        assert(widget.value ~= nil, "AF_DragSorter:SetWidgets widget at index " .. i .. " is missing 'value'.")
        assert(widget.tipText, "AF_DragSorter:SetWidgets widget at index " .. i .. " is missing 'tipText'.")

        if not widget.defaultOrder then
            widget.defaultOrder = i
        end

        widget._owner = self
    end

    self.widgets = widgets
    local n = #widgets

    -- create slots
    local name = self:GetName()
    for i = 1, n do
        if not self.slots[i] then
            self.slots[i] = CreateFrame("Frame", name and (name .. "Slot" .. i) or nil, self)
            AF.SetSize(self.slots[i], self.slotWidth, self.slotHeight)
        end

        AF.ClearPoints(self.slots[i])
        if i == 1 then
            AF.SetPoint(self.slots[i], "TOPLEFT")
        else
            AF.SetPoint(self.slots[i], "TOPLEFT", self.slots[i - 1], "TOPRIGHT", self.slotSpacing, 0)
        end

        self.widgets[i].accentColor = self.accentColor
        RegisterDragAndDrop(self.widgets[i])
    end
    AF.SetListWidth(self, n, self.slotWidth, self.slotSpacing)

    self:Refresh()
end

function AF_DragSorterMixin:SetConfigTable(configTable)
    self.configTable = configTable
    self:Refresh()
end

---@param callback fun(configTable: table)
function AF_DragSorterMixin:SetCallback(callback)
    self.callback = callback
end

-- Do not forget to dragSorter:SetConfigTable(t)
---@param parent Frame
---@param name? string
---@param slotSpacing? number default 3
---@param slotWidth? number default 20
---@param slotHeight? number default 20
---@return AF_DragSorter dragSorter
function AF.CreateDragSorter(parent, name, slotSpacing, slotWidth, slotHeight)
    local dragSorter = CreateFrame("Frame", name, parent)
    dragSorter.accentColor = AF.GetAddonAccentColorName()

    dragSorter.slotSpacing = slotSpacing or 3
    dragSorter.slotWidth = slotWidth or 20
    dragSorter.slotHeight = slotHeight or 20

    AF.SetHeight(dragSorter, dragSorter.slotHeight)

    dragSorter.slots = {}

    Mixin(dragSorter, AF_DragSorterMixin)

    return dragSorter
end