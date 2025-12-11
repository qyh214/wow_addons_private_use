---@class AbstractFramework
local AF = _G.AbstractFramework

local select, abs, max, ceil = select, abs, max, ceil
local Round = AF.Round
local ApproxZero = AF.ApproxZero
local GetCursorPosition = GetCursorPosition
local IsShiftKeyDown = IsShiftKeyDown

local MIN_SCROLL_THUMB_HEIGHT = 20

---------------------------------------------------------------------
-- shared
---------------------------------------------------------------------
local function ScorllThumb_OnEnter(self)
    self:SetBackdropColor(self.r, self.g, self.b, 0.9)
end

local function ScorllThumb_OnLeave(self)
    self:SetBackdropColor(self.r, self.g, self.b, 0.7)
end

local function UpdateSlotFrameAnchor(self)
    if self.disableSlotFrameReanchor or not self:CanScroll() then
        AF.SetPoint(self.slotFrame, "BOTTOMRIGHT", -self.horizontalMargin, self.verticalMargin)
    else
        AF.SetPoint(self.slotFrame, "BOTTOMRIGHT", self.scrollBar, "BOTTOMLEFT", -self.horizontalMargin, 0)
    end
end

local function UpdateScrollFrameAnchor(self)
    if self.disableScrollFrameReanchor or not self:CanScroll() then
        AF.SetPoint(self.scrollFrame, "BOTTOMRIGHT")
    else
        AF.SetPoint(self.scrollFrame, "BOTTOMRIGHT", -7, 0)
    end
end

---------------------------------------------------------------------
-- scroll frame
---------------------------------------------------------------------
---@class AF_ScrollFrame:AF_BorderedFrame
local AF_ScrollFrameMixin = {}

-- reset scrollContent height (reset scroll range)
function AF_ScrollFrameMixin:ResetHeight()
    AF.SetHeight(self.scrollContent, 1)
end

-- reset scroll to top
function AF_ScrollFrameMixin:ResetScroll()
    self.scrollFrame:SetVerticalScroll(0)
end

-- NOTE: GetVerticalScrollRange can be wrong if not visible
function AF_ScrollFrameMixin:GetVerticalScrollRange()
    local range = self.scrollContent:GetHeight() - self.scrollFrame:GetHeight()
    return range > 0 and range or 0
end

function AF_ScrollFrameMixin:CanScroll()
    return self:GetVerticalScrollRange() > 0
end

-- for mouse wheel
function AF_ScrollFrameMixin:VerticalScroll(step)
    local scroll = self.scrollFrame:GetVerticalScroll() + step
    if scroll <= 0 then
        self.scrollFrame:SetVerticalScroll(0)
    elseif scroll >= self:GetVerticalScrollRange() then
        self.scrollFrame:SetVerticalScroll(self:GetVerticalScrollRange())
    else
        self.scrollFrame:SetVerticalScroll(scroll)
    end
end

function AF_ScrollFrameMixin:ScrollToBottom()
    self.scrollFrame:SetVerticalScroll(self:GetVerticalScrollRange())
end

---@param height number
---@param useRawValue? boolean if true, set height directly, otherwise use AF.SetHeight
function AF_ScrollFrameMixin:SetContentHeight(height, useRawValue, skipScrollReset)
    if useRawValue then
        self.scrollContent:SetHeight(height)
    else
        AF.SetHeight(self.scrollContent, height)
    end
    if not skipScrollReset then
        self:ResetScroll()
    end
end

---@param heights table heights of each item
---@param spacing number spacing between items
function AF_ScrollFrameMixin:SetContentHeights(heights, spacing)
    AF.SetScrollContentHeight(self.scrollContent, heights, spacing)
    self:ResetScroll()
end

---@param step number default is 25
function AF_ScrollFrameMixin:SetScrollStep(step)
    self.step = step or 25
end

function AF_ScrollFrameMixin:GetScrollStep()
    return self.step
end

function AF_ScrollFrameMixin:SetScroll(offset)
    self.scrollFrame:SetVerticalScroll(AF.Clamp(offset, 0, self:GetVerticalScrollRange()))
end

function AF_ScrollFrameMixin:GetScroll()
    return self.scrollFrame:GetVerticalScroll()
end

function AF_ScrollFrameMixin:Reset()
    local children = self.contentChildren or {self.scrollContent:GetChildren()}
    for _, c in pairs(children) do
        AF.ClearPoints(c)
        c:Hide()
    end
    self:ResetHeight()
    self:ResetScroll()
end

function AF_ScrollFrameMixin:UpdatePixels()
    -- scrollBar / scrollThumb / children already AddToPixelUpdater_OnShow
    --! scrollParent's UpdatePixels is Overrided here
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)

    AF.RePoint(self.scrollFrame)
    AF.ReBorder(self.scrollFrame)

    AF.ReSize(self.scrollContent) -- SetListHeight
    self.scrollContent:SetWidth(self.scrollFrame:GetWidth())

    -- reset scroll
    self:ResetScroll()
end

function AF_ScrollFrameMixin:DisableScrollFrameReanchor(disabled)
    self.disableScrollFrameReanchor = disabled
    UpdateScrollFrameAnchor(self)
end

local function ScrollFrame_OnSizeChanged(scrollFrame)
    -- update scrollContent width
    scrollFrame:GetScrollChild():SetWidth(scrollFrame:GetWidth())
end

local function ScrollFrame_OnVerticalScroll(scrollFrame, offset)
    local scrollParent = scrollFrame:GetParent()
    local scrollBar = scrollParent.scrollBar
    local scrollThumb = scrollParent.scrollThumb

    if scrollParent:GetVerticalScrollRange() ~= 0 then
        local scrollP = scrollFrame:GetVerticalScroll() / scrollParent:GetVerticalScrollRange()
        local offsetY = -((scrollBar:GetHeight() - scrollThumb:GetHeight()) * scrollP)
        scrollThumb:SetPoint("TOP", 0, offsetY)
    else
        scrollThumb:SetPoint("TOP")
    end
end

local function ScrollContent_OnSizeChanged(scrollContent)
    -- check if it can scroll
    -- DO NOT USE OnScrollRangeChanged to check whether it can scroll.
    -- "invisible" widgets should be hidden, then the scroll range is NOT accurate!
    -- scrollFrame:SetScript("OnScrollRangeChanged", function(self, xOffset, yOffset) end)

    local scrollFrame = scrollContent:GetParent()
    local scrollParent = scrollFrame:GetParent()
    local scrollBar = scrollParent.scrollBar
    local scrollThumb = scrollParent.scrollThumb

    -- set thumb height (%)
    local p = scrollFrame:GetHeight() / scrollContent:GetHeight()
    p = tonumber(string.format("%.3f", p))
    if p < 1 then -- can scroll
        local height = max(scrollBar:GetHeight() * p, MIN_SCROLL_THUMB_HEIGHT)

        -- NOTE: prevent a visual issue
        if height > scrollBar:GetHeight() - abs(select(5, scrollThumb:GetPoint())) then
            scrollThumb:SetPoint("TOP", 0, -(scrollBar:GetHeight() - height))
        end

        scrollThumb:SetHeight(height)

        -- space for scrollBar
        -- AF.SetPoint(scrollFrame, "BOTTOMRIGHT", -7, 0)
        scrollBar:Show()
    else
        -- AF.SetPoint(scrollFrame, "BOTTOMRIGHT")
        scrollBar:Hide()
        scrollFrame:SetVerticalScroll(0)
    end

    UpdateScrollFrameAnchor(scrollParent)
end

local function ScrollThumb_OnMouseDown(scrollThumb, button)
    if button ~= "LeftButton" then return end

    local scrollParent = scrollThumb:GetParent():GetParent()
    local scrollFrame = scrollParent.scrollFrame
    local scrollBar = scrollParent.scrollBar

    -- scrollFrame:SetScript("OnVerticalScroll", nil) -- disable OnVerticalScroll

    local offsetY = select(5, scrollThumb:GetPoint(1))
    local mouseY = select(2, GetCursorPosition()) -- https://warcraft.wiki.gg/wiki/API_GetCursorPosition
    local scale = scrollThumb:GetEffectiveScale()
    -- local currentScroll = scrollFrame:GetVerticalScroll()
    local maxOffsetY = scrollBar:GetHeight() - scrollThumb:GetHeight()

    scrollThumb:SetScript("OnUpdate", function(self)
        local newMouseY = select(2, GetCursorPosition())
        ------------------ y offset before dragging + mouse offset
        local newOffsetY = offsetY + (newMouseY - mouseY) / scale

        if newOffsetY >= 0 then -- top
            -- AF.SetPoint(self, "TOP")
            newOffsetY = 0
        elseif -newOffsetY >= maxOffsetY then -- bottom
            -- AF.SetPoint(self, "TOP", 0, -maxOffsetY)
            newOffsetY = -maxOffsetY
        else
            -- AF.SetPoint(self, "TOP", 0, newOffsetY)
        end

        local vs = (-newOffsetY / maxOffsetY) * scrollParent:GetVerticalScrollRange()
        scrollFrame:SetVerticalScroll(vs)
    end)
end

local function ScrollThumb_OnMouseUp(scrollThumb)
    -- local scrollFrame = scrollThumb:GetParent():GetParent().scrollFrame
    -- scrollFrame:SetScript("OnVerticalScroll", ScrollFrame_OnVerticalScroll) -- enable OnVerticalScroll
    scrollThumb:SetScript("OnUpdate", nil)
end

local function ScrollParent_OnMouseWheel(self, delta)
    if delta == 1 then -- scroll up
        self:VerticalScroll(AF.ConvertPixelsForRegion(-self.step, self))
    elseif delta == -1 then -- scroll down
        self:VerticalScroll(AF.ConvertPixelsForRegion(self.step, self))
    end
end

---@param parent Frame
---@param name? string
---@param width? number
---@param height? number
---@param color? string|table
---@param borderColor? string|table
---@return AF_ScrollFrame scrollParent
function AF.CreateScrollFrame(parent, name, width, height, color, borderColor)
    local scrollParent = AF.CreateBorderedFrame(parent, name, width, height, color, borderColor)

    scrollParent.accentColor = AF.GetAddonAccentColorName()

    -- scrollFrame (which actually scrolls)
    local scrollFrame = CreateFrame("ScrollFrame", nil, scrollParent, "BackdropTemplate")
    scrollParent.scrollFrame = scrollFrame
    AF.SetPoint(scrollFrame, "TOPLEFT")
    AF.SetPoint(scrollFrame, "BOTTOMRIGHT")

    -- scrollContent
    local scrollContent = CreateFrame("Frame", nil, scrollFrame)
    scrollParent.scrollContent = scrollContent
    scrollContent:SetHeight(1)
    scrollContent:SetWidth(scrollFrame:GetWidth())
    scrollFrame:SetScrollChild(scrollContent)

    -- for debugging
    -- local tex = scrollContent:CreateTexture(nil, "ARTWORK")
    -- tex:SetAllPoints(scrollContent)
    -- tex:SetColorTexture(0, 1, 0, 0.5)

    -- scrollBar
    local scrollBar = AF.CreateBorderedFrame(scrollParent, nil, 5, nil, color, borderColor)
    scrollParent.scrollBar = scrollBar
    AF.SetPoint(scrollBar, "TOPRIGHT")
    AF.SetPoint(scrollBar, "BOTTOMRIGHT")
    scrollBar:Hide()

    -- scrollBar thumb
    local scrollThumb = AF.CreateBorderedFrame(scrollBar, nil, 5, nil, AF.GetColorTable(scrollParent.accentColor, 0.8))
    scrollParent.scrollThumb = scrollThumb
    AF.SetPoint(scrollThumb, "TOP")
    scrollThumb:EnableMouse(true)
    scrollThumb:SetMovable(true)
    scrollThumb:SetHitRectInsets(-5, -5, 0, 0) -- Frame:SetHitRectInsets(left, right, top, bottom)

    scrollThumb.r, scrollThumb.g, scrollThumb.b = AF.GetColorRGB(scrollParent.accentColor)
    scrollThumb:SetScript("OnEnter", ScorllThumb_OnEnter)
    scrollThumb:SetScript("OnLeave", ScorllThumb_OnLeave)

    Mixin(scrollParent, AF_ScrollFrameMixin)

    scrollFrame:SetScript("OnSizeChanged", ScrollFrame_OnSizeChanged)
    scrollFrame:SetScript("OnVerticalScroll", ScrollFrame_OnVerticalScroll)
    scrollContent:SetScript("OnSizeChanged", ScrollContent_OnSizeChanged)

    -- dragging and scrolling
    scrollThumb:SetScript("OnMouseDown", ScrollThumb_OnMouseDown)
    scrollThumb:SetScript("OnMouseUp", ScrollThumb_OnMouseUp)

    -- enable mouse wheel scroll
    scrollParent:SetScrollStep(25)
    scrollParent:EnableMouseWheel(true)
    scrollParent:SetScript("OnMouseWheel", ScrollParent_OnMouseWheel)

    AF.AddToPixelUpdater_OnShow(scrollParent)

    return scrollParent
end

---------------------------------------------------------------------
-- ScrollListGrid shared
---------------------------------------------------------------------
local function ScrollRoot_OnMouseWheel(self, delta)
    if not self:CanScroll() then return end
    if delta == 1 then -- scroll up
        self:SetScroll(self:GetScroll() - self.step)
    elseif delta == -1 then -- scroll down
        self:SetScroll(self:GetScroll() + self.step)
    end
end

local function ScrollRoot_OnMouseDown(self, button)
    if button ~= "LeftButton" then return end

    local scale = self:GetEffectiveScale()
    local offsetY = select(5, self:GetPoint(1))
    local mouseY = select(2, GetCursorPosition()) / scale -- https://warcraft.wiki.gg/wiki/API_GetCursorPosition

    self:SetScript("OnUpdate", function(self)
        local newMouseY = select(2, GetCursorPosition()) / scale
        local mouseOffset = newMouseY - mouseY
        if ApproxZero(mouseOffset) then return end

        local newOffsetY = offsetY + mouseOffset

        -- top ------------------------------
        if newOffsetY >= 0 then
            if self.root:GetScroll() ~= 1 then
                self.root:SetScroll(1)
            end

        -- bottom ---------------------------
        elseif (-newOffsetY) + self:GetHeight() >= self.root.scrollBar:GetHeight() then
            if self.root:GetScroll() ~= self.root:GetScrollRange() + 1 then
                self.root:SetScroll(self.root:GetScrollRange() + 1)
            end

        -- scroll ---------------------------
        else
            local threshold = (self.root.scrollBar:GetHeight() - self:GetHeight()) / self.root:GetScrollRange()
            local targetIndex = Round(abs(newOffsetY) / threshold)
            targetIndex = max(targetIndex, 1)
            if targetIndex ~= self.root:GetScroll() then
                self.root:SetScroll(targetIndex)
            end
        end
    end)
end

local function ScrollRoot_OnMouseUp(self)
    self:SetScript("OnUpdate", nil)
end


---------------------------------------------------------------------
-- scroll list
---------------------------------------------------------------------
---@class AF_ScrollList:AF_BorderedFrame
local AF_ScrollListMixin = {}

---@private
function AF_ScrollListMixin:UpdateSlotSize()
    for i = 1, self.slotNum do
        if self.slotHeight then
            AF.SetHeight(self.slots[i], self.slotHeight)
        else
            local spacing = AF.ConvertPixelsForRegion(self.slotSpacing, self) * (self.slotNum - 1)
            self.slots[i]:SetHeight((self.slotFrame:GetHeight() - spacing) / self.slotNum)
        end
    end
end

---@private
function AF_ScrollListMixin:UpdateSlots()
    for i = 1, self.slotNum do
        if not self.slots[i] then
            self.slots[i] = AF.CreateFrame(self.slotFrame)
            AF.RemoveFromPixelUpdater(self.slots[i])

            AF.SetPoint(self.slots[i], "RIGHT")
            if i == 1 then
                AF.SetPoint(self.slots[i], "TOPLEFT")
            else
                AF.SetPoint(self.slots[i], "TOPLEFT", self.slots[i - 1], "BOTTOMLEFT", 0, -self.slotSpacing)
            end
        end

        self.slots[i]:Show()

        if self.slots[i].widget then
            self.slots[i].widget:Show()
            if self.slots[i].widget.UpdatePixels then
                self.slots[i].widget:UpdatePixels()
            end
        end
    end

    if self.slotHeight then
        if self.slotNum == 0 then
            AF.SetHeight(self, 5)
        else
            AF.SetListHeight(self, self.slotNum, self.slotHeight, self.slotSpacing, self.verticalMargin, self.verticalMargin)
        end
    else
        RunNextFrame(function()
            self:UpdateSlotSize()
        end)
    end

    -- hide unused slots
    for i = self.slotNum + 1, #self.slots do
        self.slots[i]:Hide()
        if self.slots[i].widget then
            self.slots[i].widget:Hide()
        end
    end
end

function AF_ScrollListMixin:SetSlotNum(newSlotNum)
    self.slotNum = newSlotNum
    self:UpdateSlots()
end

function AF_ScrollListMixin:SetSlotHeight(newHeight)
    self.slotHeight = newHeight
    self:UpdateSlots()
end

function AF_ScrollListMixin:DisableSlotFrameReanchor(disabled)
    self.disableSlotFrameReanchor = disabled
    UpdateSlotFrameAnchor(self)
end

local function ScrollList_UpdateScrollBar(self)
    if self:CanScroll() then
        self.scrollBar:Show()
        local p = self.slotNum / self.widgetNum
        self.scrollThumb:SetHeight(max(self.scrollBar:GetHeight() * p, MIN_SCROLL_THUMB_HEIGHT))
    else
        self.scrollBar:Hide()
    end
    UpdateSlotFrameAnchor(self)
end

--- this method cannot be used together with SetWidgetPool/SetupButtonGroup
--- load and scroll to the first item
---@param widgets table
---@param scrollTo number|nil index to scroll to, default is 1
function AF_ScrollListMixin:SetWidgets(widgets, scrollTo)
    self.mode = "pre_created"

    self:Reset()
    self.widgets = widgets
    self.widgetNum = #widgets

    for _, w in next, self.widgets do
        AF.RemoveFromPixelUpdater(w)
    end

    self:UpdateSlotSize()
    ScrollList_UpdateScrollBar(self)
    self:SetScroll(scrollTo or 1)
end

--- this method cannot be used together with SetWidgets/SetupButtonGroup
---@param pool ObjectPool list will use widget:Load(value) to update widget
function AF_ScrollListMixin:SetWidgetPool(pool)
    self.mode = "pool_based"
    self.pool = pool
end

-- for button_group
local function IdToIndexProcessor(k, v)
    return v.id or v.text, k
end

--- this method is only for SetWidgetPool/SetupButtonGroup
--- load and scroll to the first item
---@param data table Keys must be consecutive integers starting from 1; each value will be used for widget:Load(value)
---@param scrollTo number|nil index to scroll to, default is 1
function AF_ScrollListMixin:SetData(data, scrollTo)
    assert(self.pool, "AF_ScrollList:SetData requires a widget pool. Call SetWidgetPool/SetupButtonGroup first.")

    self:Reset()
    self.data = data
    self.widgetNum = #data
    self.lastClickedIndex = nil

    if self.mode == "button_group" then
        self.idToIndex = AF.ConvertTable(data, IdToIndexProcessor)
    end

    if self.selected then
        wipe(self.selected)
    end

    self:UpdateSlotSize()
    ScrollList_UpdateScrollBar(self)
    self:SetScroll(scrollTo or 1)
end

-- reset
function AF_ScrollListMixin:Reset()
    self.widgets = {}
    self.widgetNum = 0

    if not self.mode then return end

    -- hide slot widgets
    if self.mode == "pre_created" then
        for _, s in next, self.slots do
            if s.widget then
                s.widget:Hide()
            end
            s.widget = nil
            s.widgetIndex = nil
        end
    else -- pool_based or button_group
        for w in self.pool:EnumerateActive() do
            w:Hide()
            w._slotIndex = nil
        end
        -- self:Select(nil) -- button_group
        self.pool:ReleaseAll()
        for _, s in next, self.slots do
            s.widget = nil
            s.widgetIndex = nil
        end

        if self.mode == "button_group" then
            wipe(self.selected)
            self.data = nil
            self.idToIndex = nil
            self.lastClickedIndex = nil
        end
    end

    -- resize / repoint
    AF.SetPoint(self.slotFrame, "BOTTOMRIGHT", -self.horizontalMargin, self.verticalMargin)
    self.scrollBar:Hide()
end

---@param startIndex number start index of widgets
function AF_ScrollListMixin:SetScroll(startIndex)
    if not startIndex then return end

    if startIndex <= 0 then startIndex = 1 end
    local total = self.widgetNum
    local from, to = startIndex, startIndex + self.slotNum - 1

    -- not enough widgets (fill from the first)
    if total <= self.slotNum then
        from = 1
        to = total

    -- have enough widgets, but result in empty slots, fix it
    elseif total - startIndex + 1 < self.slotNum then
        from = total - self.slotNum + 1 -- total > slotNum
        to = total
    end

    if self.slots[1].widgetIndex == from then
        return
    end

    -- fill
    local slot
    local slotIndex = 1

    if self.mode == "pre_created" then
        for i, w in next, self.widgets do
            slot = self.slots[slotIndex]
            w:ClearAllPoints()
            w:SetParent(self.slotFrame)

            if i < from or i > to then
                w:Hide()
            else
                w:SetAllPoints(slot)
                w:Show()

                if w.UpdatePixels then w:UpdatePixels() end
                if w.Update then w:Update() end

                w._slotIndex = slotIndex
                slot.widget = w
                slot.widgetIndex = i
                slotIndex = slotIndex + 1
            end
        end
    else -- pool_based or button_group
        for w in self.pool:EnumerateActive() do
            w:Hide()
            w._slotIndex = nil
        end
        self.pool:ReleaseAll()

        for i = from, to do
            slot = self.slots[slotIndex]

            local w = self.pool:Acquire()
            w:SetParent(self.slotFrame)
            w:SetAllPoints(slot)
            w:Show()

            if w.UpdatePixels then w:UpdatePixels() end
            if w.Update then w:Update() end
            if w.Load then w:Load(self.data[i]) end

            w._slotIndex = slotIndex
            slot.widget = w
            slot.widgetIndex = i
            slotIndex = slotIndex + 1
        end


        if self.mode == "button_group" then
            self:Select() -- reselect
        end
    end

    -- reset empty slots
    for i = slotIndex, self.slotNum do
        self.slots[i].widget = nil
        self.slots[slotIndex].widgetIndex = nil
    end

    -- update scorll thumb
    if self:CanScroll() then
        local offset = (from - 1) * ((self.scrollBar:GetHeight() - self.scrollThumb:GetHeight()) / self:GetScrollRange()) -- n * perHeight
        self.scrollThumb:SetPoint("TOP", 0, -offset)
    end
end

-- make target index widget visible
function AF_ScrollListMixin:ScrollTo(index)
    if type(index) ~= "number" then return end
    if index <= 0 then
        self:SetScroll(1)
    elseif index >= self.widgetNum then
        self:ScrollToBottom()
    else
        self:SetScroll(index - self.slotNum + 1)
    end
end

function AF_ScrollListMixin:ScrollToID(id)
    assert(self.mode == "button_group", "AF_ScrollList:ScrollToID requires button group mode")
    local index = id and self.idToIndex[id]
    if index then
        self:ScrollTo(index)
    end
end

function AF_ScrollListMixin:ScrollToBottom()
    self:SetScroll(self.widgetNum - self.slotNum + 1)
end

function AF_ScrollListMixin:GetScroll()
    if not self:CanScroll() then
        return 1
    end
    return self.slots[1].widgetIndex
end

---@param index number index of the slot
function AF_ScrollListMixin:GetWidgetAt(index)
    if index and index > 0 and index <= self.slotNum then
        return self.slots[index].widget
    end
end

function AF_ScrollListMixin:GetWidgets()
    if self.mode == "pre_created" then
        return self.widgets
    else -- pool_based or button_group
        return self.pool:GetAllActives()
    end
end

function AF_ScrollListMixin:GetScrollRange()
    local range = self.widgetNum - self.slotNum
    return range <= 0 and 0 or range
end

function AF_ScrollListMixin:CanScroll()
    return self.widgetNum > self.slotNum
end

function AF_ScrollListMixin:SetScrollStep(step)
    self.step = step
end

local function ButtonGroup_Select(self, b, skipCallback)
    if b._hoverColor then b:SetBackdropColor(AF.UnpackColor(b._hoverColor)) end
    if b._hoverBorderColor then b:SetBackdropBorderColor(AF.UnpackColor(b._hoverBorderColor)) end

    if not skipCallback and self.onSelect then self.onSelect(b, b.id) end
    -- self.selected[b.id] = true

    if self.multiSelect then
        b:SetTextColor("white")
    end
end

local function ButtonGroup_Deselect(self, b, skipCallback)
    if b._color then b:SetBackdropColor(AF.UnpackColor(b._color)) end
    if b._borderColor then b:SetBackdropBorderColor(AF.UnpackColor(b._borderColor)) end

    if not skipCallback and self.onDeselect then self.onDeselect(b, b.id) end
    -- self.selected[b.id] = nil

    if self.multiSelect then
        b:SetTextColor("gray")
    end
end

--- only works with SetupButtonGroup
function AF_ScrollListMixin:Select(id, skipCallback)
    assert(self.mode == "button_group", "AF_ScrollList:Select requires button group mode")

    if not id then
        for b in self.pool:EnumerateActive() do
            if self.selected[b.id] then
                ButtonGroup_Select(self, b, true)
            else
                ButtonGroup_Deselect(self, b, true)
            end
        end
    elseif self.multiSelect then
        if IsShiftKeyDown() and self.lastClickedIndex then
            local from = self.lastClickedIndex
            local to = self.idToIndex[id]
            if from > to then
                from, to = to, from
            end

            for b in self.pool:EnumerateActive() do
                if self.idToIndex[b.id] >= from and self.idToIndex[b.id] <= to then
                    ButtonGroup_Select(self, b, true)
                else
                    ButtonGroup_Deselect(self, b, true)
                end
            end

            for _id, index in next, self.idToIndex do
                if index >= from and index <= to then
                    self.selected[_id] = index
                else
                    self.selected[_id] = nil
                end
            end
        else
            for b in self.pool:EnumerateActive() do
                if id == b.id then
                    if self.selected[b.id] then
                        ButtonGroup_Deselect(self, b, true)
                        self.selected[b.id] = nil
                    else
                        ButtonGroup_Select(self, b, true)
                        self.selected[b.id] = self.idToIndex[b.id]
                    end
                end
            end
        end

        if not skipCallback and self.onSelect then
            self.onSelect(self.selected)
        end
    else
        for b in self.pool:EnumerateActive() do
            if id == b.id then
                ButtonGroup_Select(self, b, skipCallback or self.selected[b.id])
            else
                ButtonGroup_Deselect(self, b, skipCallback or not self.selected[b.id])
            end
        end

        for _id, index in next, self.idToIndex do
            if id == _id then
                self.selected[_id] = index
            else
                self.selected[_id] = nil
            end
        end
    end
end

function AF_ScrollListMixin:InvertSelect()
    assert(self.mode == "button_group", "AF_ScrollList:InvertSelect requires button group mode")

    for id in next, self.idToIndex do
        if self.selected[id] then
            self.selected[id] = nil
        else
            self.selected[id] = true
        end
    end
    self:Select()
end

function AF_ScrollListMixin:SelectAll()
    assert(self.mode == "button_group", "AF_ScrollList:SelectAll requires button group mode")

    self.lastClickedIndex = nil
    for id in next, self.idToIndex do
        self.selected[id] = true
    end
    self:Select()
end

---@return table
function AF_ScrollListMixin:GetSelected()
    assert(self.mode == "button_group", "AF_ScrollList:GetSelected requires button group mode")
    return self.selected
end

---@param enabled boolean
---@param checkGrayOut boolean normally no need, unless you want to gray out unselected buttons immediately AFTER SetData WITHOUT scrolling
function AF_ScrollListMixin:SetMultiSelect(enabled, checkGrayOut)
    assert(self.mode == "button_group", "AF_ScrollList:SetMultiSelect requires button group mode")

    self.lastClickedIndex = nil
    self.multiSelect = enabled

    if checkGrayOut then
        self:Select() -- reselect to gray out unselected buttons
    end
end

function AF_ScrollListMixin:ClearSelected()
    assert(self.mode == "button_group", "AF_ScrollList:ClearSelected requires button group mode")

    self.lastClickedIndex = nil
    for b in self.pool:EnumerateActive() do
        if self.selected[b.id] then
            ButtonGroup_Deselect(self, b, true)
        end
    end
    wipe(self.selected)
end

---@private
function AF_ScrollListMixin:InitButtonScripts(b)
    if b._scriptInited then return end
    b._scriptInited = true

    b.id = b.id or b:GetText() or b:GetName() or tostring(b)

    b:SetScript("OnClick", function()
        if not IsShiftKeyDown() then
            self.lastClickedIndex = self.idToIndex[b.id]
        end
        self:Select(b.id)
    end)

    b:SetScript("OnEnter", function()
        if not self.selected[b.id] and b._hoverColor then
            b:SetBackdropColor(AF.UnpackColor(b._hoverColor))
        end
        if self.onEnter then self.onEnter(b, b.id) end
    end)

    b:SetScript("OnLeave", function()
        if not self.selected[b.id] and b._color then
            b:SetBackdropColor(AF.UnpackColor(b._color))
        end
        if self.onLeave then self.onLeave(b, b.id) end
    end)
end

--- this method cannot be used together with SetWidgets/SetWidgetPool
--- use SetData to set each button's text and id, so each entry in data should be {text = (string), id = (string/number)}
--- any other keys in data will be stored as button[k] = v
---@param color string|table
---@param onSelect fun(button:AF_Button, id:any) will pass "selected" table under multi-select mode
---@param onDeselect fun(button:AF_Button, id:any) do not work under multi selection mode
---@param onEnter fun(button:AF_Button, id:any)
---@param onLeave fun(button:AF_Button, id:any)
---@param onLoad fun(button:AF_Button, data:table)
function AF_ScrollListMixin:SetupButtonGroup(color, onSelect, onDeselect, onEnter, onLeave, onLoad)
    self.mode = "button_group"
    self.selected = {}

    self.onSelect = onSelect
    self.onDeselect = onDeselect
    self.onEnter = onEnter
    self.onLeave = onLeave

    self.pool = AF.CreateObjectPool(function()
        local b = AF.CreateButton(self.slotFrame, nil, color, nil, nil, nil, "none", "")
        b:SetTextJustifyH("LEFT")
        b:EnablePushEffect(false)
        self:InitButtonScripts(b)

        function b:Load(data)
            b:SetText(data.text)
            b.id = data.id or data.text

            for k, v in next, data do
                if k ~= "text" and k ~= "id" then
                    b[k] = v
                end
            end

            if onLoad then
                onLoad(b, data)
            end
        end

        return b
    end)
end

function AF_ScrollListMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
    AF.RePoint(self.slotFrame)
    self.scrollBar:UpdatePixels()

    -- update slots and widgets
    for _, s in next, self.slots do
        s:UpdatePixels()
        if s.widget and s.widget.UpdatePixels then
            s.widget:UpdatePixels()
        end
    end

    -- update scorll thumb
    if self:CanScroll() and self.slots[1].widgetIndex then
        local offset = (self.slots[1].widgetIndex - 1) * ((self.scrollBar:GetHeight() - self.scrollThumb:GetHeight()) / self:GetScrollRange()) -- n * perHeight
        self.scrollThumb:SetPoint("TOP", 0, -offset)
    end
end

---@param parent Frame
---@param name? string
---@param verticalMargin number top/bottom margin
---@param horizontalMargin number left/right margin
---@param slotNum number number of slots
---@param slotHeight number|nil height of each slot, if not provided, you should manually set the height of the list
---@param slotSpacing number spacing between widgets next to each other
---@param color? string|table background color
---@param borderColor? string|table border color
---@return AF_ScrollList scrollList
function AF.CreateScrollList(parent, name, verticalMargin, horizontalMargin, slotNum, slotHeight, slotSpacing, color, borderColor)
    local scrollList = AF.CreateBorderedFrame(parent, name, nil, nil, color, borderColor)
    -- AF.SetListHeight(scrollList, slotNum, slotHeight, slotSpacing, verticalMargin, verticalMargin)

    scrollList.slotNum = slotNum
    scrollList.slotHeight = slotHeight
    scrollList.slotSpacing = slotSpacing
    scrollList.verticalMargin = verticalMargin
    scrollList.horizontalMargin = horizontalMargin

    scrollList.accentColor = AF.GetAddonAccentColorName()

    -- slotFrame
    local slotFrame = CreateFrame("Frame", nil, scrollList)
    scrollList.slotFrame = slotFrame
    AF.SetPoint(slotFrame, "TOPLEFT", horizontalMargin, -verticalMargin)
    AF.SetPoint(slotFrame, "BOTTOMRIGHT", -horizontalMargin, verticalMargin)

    -- scrollBar
    local scrollBar = AF.CreateBorderedFrame(scrollList, nil, 5, nil, color, borderColor)
    scrollList.scrollBar = scrollBar
    AF.RemoveFromPixelUpdater(scrollBar)
    AF.SetPoint(scrollBar, "TOPRIGHT", 0, -verticalMargin)
    AF.SetPoint(scrollBar, "BOTTOMRIGHT", 0, verticalMargin)
    scrollBar:Hide()

    -- scrollBar thumb
    local scrollThumb = AF.CreateBorderedFrame(scrollBar, nil, 5, nil, AF.GetColorTable(scrollList.accentColor, 0.7))
    scrollList.scrollThumb = scrollThumb
    scrollThumb.root = scrollList
    scrollThumb.r, scrollThumb.g, scrollThumb.b = AF.GetColorRGB(scrollList.accentColor)
    -- AF.SetPoint(scrollThumb, "TOP")
    scrollThumb:EnableMouse(true)
    scrollThumb:SetMovable(true)
    scrollThumb:SetHitRectInsets(-5, -5, 0, 0) -- Frame:SetHitRectInsets(left, right, top, bottom)
    scrollThumb:SetScript("OnEnter", ScorllThumb_OnEnter)
    scrollThumb:SetScript("OnLeave", ScorllThumb_OnLeave)

    -- slots
    scrollList.slots = {}

    Mixin(scrollList, AF_ScrollListMixin)
    scrollList:UpdateSlots()

    -- items
    scrollList.widgets = {}
    scrollList.widgetNum = 0

    -- for mouse wheel ----------------------------------------------
    scrollList:SetScrollStep(1)

    -- enable mouse wheel scroll
    scrollList:EnableMouseWheel(true)
    scrollList:SetScript("OnMouseWheel", ScrollRoot_OnMouseWheel)
    -----------------------------------------------------------------

    -- dragging and scrolling ---------------------------------------
    scrollThumb:SetScript("OnMouseDown", ScrollRoot_OnMouseDown)
    scrollThumb:SetScript("OnMouseUp", ScrollRoot_OnMouseUp)
    -----------------------------------------------------------------

    AF.AddToPixelUpdater_OnShow(scrollList)

    return scrollList
end

---------------------------------------------------------------------
-- scrol grid
---------------------------------------------------------------------
---@class AF_ScrollGrid:AF_BorderedFrame
local AF_ScrollGridMixin = {}

---@private
function AF_ScrollGridMixin:UpdateSlotPoint()
    for i = 1, self.slotNum do
        if i == 1 then
            AF.SetPoint(self.slots[i], "TOPLEFT")
        elseif self.slotColumn == 1 or i % self.slotColumn == 1 then
            AF.SetPoint(self.slots[i], "TOPLEFT", self.slots[i - self.slotColumn], "BOTTOMLEFT", 0, -self.slotSpacing)
        else
            AF.SetPoint(self.slots[i], "TOPLEFT", self.slots[i - 1], "TOPRIGHT", self.slotSpacing, 0)
        end
    end
end

---@private
function AF_ScrollGridMixin:UpdateSlotSize()
    for i = 1, self.slotNum do
        if self.slotWidth then
            AF.SetWidth(self.slots[i], self.slotWidth)
        else
            local spacing = AF.ConvertPixelsForRegion(self.slotSpacing, self) * (self.slotColumn - 1)
            self.slots[i]:SetWidth((self.slotFrame:GetWidth() - spacing) / self.slotColumn)
        end

        if self.slotHeight then
            AF.SetHeight(self.slots[i], self.slotHeight)
        else
            local spacing = AF.ConvertPixelsForRegion(self.slotSpacing, self) * (self.slotRow - 1)
            self.slots[i]:SetHeight((self.slotFrame:GetHeight() - spacing) / self.slotRow)
        end
    end
end

---@private
function AF_ScrollGridMixin:UpdateSlots()
    for i = 1, self.slotNum do
        if not self.slots[i] then
            self.slots[i] = AF.CreateFrame(self.slotFrame)
            AF.RemoveFromPixelUpdater(self.slots[i])
        end

        self.slots[i]:Show()

        if self.slots[i].widget then
            self.slots[i].widget:Show()
            if self.slots[i].widget.UpdatePixels then
                self.slots[i].widget:UpdatePixels()
            end
        end
    end

    -- update slot point and size
    self:UpdateSlotPoint()
    self:UpdateSlotSize()

    -- hide unused slots
    for i = self.slotNum + 1, #self.slots do
        self.slots[i]:Hide()
        if self.slots[i].widget then
            self.slots[i].widget:Hide()
        end
    end
end

function AF_ScrollGridMixin:SetSlotRowsAndColumns(newSlotRow, newSlotColumn)
    self.slotRow = newSlotRow
    self.slotColumn = newSlotColumn
    self.slotNum = newSlotRow * newSlotColumn
    AF.SetGridSize(self, self.slotWidth, self.slotHeight, self.slotSpacing, self.slotSpacing, newSlotColumn, newSlotRow, self.verticalMargin, self.verticalMargin, self.horizontalMargin, self.horizontalMargin)
    self:UpdateSlots()
end

function AF_ScrollGridMixin:SetSlotSize(newWidth, newHeight)
    self.slotWidth = newWidth
    self.slotHeight = newHeight
    self:SetSlotRowsAndColumns(self.slotRow, self.slotColumn)
end

function AF_ScrollGridMixin:DisableSlotFrameReanchor(disabled)
    self.disableSlotFrameReanchor = disabled
    UpdateSlotFrameAnchor(self)
end

function AF_ScrollGridMixin:SetWidgets(widgets)
    self:Reset()
    self.widgets = widgets
    self.widgetNum = #widgets
    self:SetScroll(1)

    -- call UpdatePixels on show
    for _, w in next, self.widgets do
        AF.RemoveFromPixelUpdater(w)
    end

    if self:CanScroll() then
        self.scrollBar:Show()
        local p = self.slotRow / ceil(self.widgetNum / self.slotColumn)
        self.scrollThumb:SetHeight(max(self.scrollBar:GetHeight() * p, MIN_SCROLL_THUMB_HEIGHT))
    else
        self.scrollBar:Hide()
    end
    UpdateSlotFrameAnchor(self)

    -- update slot size
    self:UpdateSlotSize()
end

-- reset
function AF_ScrollGridMixin:Reset()
    self.widgets = {}
    self.widgetNum = 0

    -- hide slot widgets
    for _, s in next, self.slots do
        if s.widget then
            s.widget:Hide()
        end
        s.widget = nil
        s.widgetIndex = nil
    end

    -- resize / repoint
    AF.SetPoint(self.slotFrame, "BOTTOMRIGHT", -self.horizontalMargin, self.verticalMargin)
    self.scrollBar:Hide()

    -- update slot size
    self:UpdateSlotSize()
end

---@param startRow number
function AF_ScrollGridMixin:SetScroll(startRow)
    if not startRow then return end
    if startRow <= 0 or startRow > self:GetScrollRange() + 1 then return end

    local total = self.widgetNum
    local from = (startRow - 1) * self.slotColumn + 1
    local to = from + self.slotNum - 1

    -- not enough widgets (fill from the first)
    if total <= self.slotNum then
        from = 1
        to = total

    -- have enough widgets, but result in empty row, fix it
    elseif ceil(total / self.slotColumn) - startRow + 1 < self.slotRow then
        from = (floor(total / self.slotColumn) - 1) * self.slotColumn + 1
        to = total
    end

    if self.slots[1].widgetIndex == from then
        return
    end

    -- fill
    local slotIndex = 1
    for i, w in next, self.widgets do
        w:ClearAllPoints()
        if i < from or i > to then
            w:Hide()
        else
            w:SetParent(self.slotFrame)
            w:Show()
            w:SetAllPoints(self.slots[slotIndex])
            if w.UpdatePixels then
                w:UpdatePixels()
            end
            w._slotIndex = slotIndex
            if w.Update then
                -- NOTE: fix some widget issues, define them manually
                w:Update()
            end
            self.slots[slotIndex].widget = w
            self.slots[slotIndex].widgetIndex = i
            slotIndex = slotIndex + 1
        end
    end

    -- reset empty slots
    for i = slotIndex, self.slotNum do
        self.slots[i].widget = nil
        self.slots[slotIndex].widgetIndex = nil
    end

    -- update scorll thumb
    if self:CanScroll() then
        local offset = (startRow - 1) * ((self.scrollBar:GetHeight() - self.scrollThumb:GetHeight()) / self:GetScrollRange()) -- n * perHeight
        self.scrollThumb:SetPoint("TOP", 0, -offset)
    end
end

function AF_ScrollGridMixin:ScrollToBottom()
    self:SetScroll(ceil(self.widgetNum / self.slotColumn) - self.slotRow + 1)
end

function AF_ScrollGridMixin:GetScroll()
    if not self:CanScroll() then
        return 1
    end
    return ceil(self.slots[1].widgetIndex / self.slotColumn)
end

---@param index number index of the slot
function AF_ScrollGridMixin:GetWidgetAt(index)
    if index and index > 0 and index <= self.slotNum then
        return self.slots[index].widget
    end
end

function AF_ScrollGridMixin:GetWidgets()
    return self.widgets
end

function AF_ScrollGridMixin:GetScrollRange()
    local range = ceil(self.widgetNum / self.slotColumn) - self.slotRow
    return range <= 0 and 0 or range
end

function AF_ScrollGridMixin:CanScroll()
    return self.widgetNum > self.slotNum
end

function AF_ScrollGridMixin:SetScrollStep(step)
    self.step = step
end

function AF_ScrollGridMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
    AF.RePoint(self.slotFrame)
    self.scrollBar:UpdatePixels()

    -- update slots and widgets
    for _, s in next, self.slots do
        s:UpdatePixels()
        if s.widget and s.widget.UpdatePixels then
            s.widget:UpdatePixels()
        end
    end

    -- update scorll thumb
    if self:CanScroll() then
        local offset = (self:GetScroll() - 1) * ((self.scrollBar:GetHeight() - self.scrollThumb:GetHeight()) / self:GetScrollRange()) -- n * perHeight
        self.scrollThumb:SetPoint("TOP", 0, -offset)
    end
end

---@param verticalMargin number top/bottom margin
---@param horizontalMargin number left/right margin
---@param slotColumn number
---@param slotRow number
---@param slotWidth number|nil if nil, auto calculate width
---@param slotHeight number|nil if nil, auto calculate height
---@param slotSpacing number spacing between widgets next to each other
---@return AF_ScrollGrid scrollList
function AF.CreateScrollGrid(parent, name, verticalMargin, horizontalMargin, slotColumn, slotRow, slotWidth, slotHeight, slotSpacing, color, borderColor)
    local scrollGrid = AF.CreateBorderedFrame(parent, name, nil, nil, color, borderColor)
    AF.SetGridSize(scrollGrid, slotWidth, slotHeight, slotSpacing, slotSpacing, slotColumn, slotRow, verticalMargin, verticalMargin, horizontalMargin, horizontalMargin)

    scrollGrid.slotColumn = slotColumn
    scrollGrid.slotRow = slotRow
    scrollGrid.slotNum = slotColumn * slotRow
    scrollGrid.slotWidth = slotWidth
    scrollGrid.slotHeight = slotHeight
    scrollGrid.slotSpacing = slotSpacing
    scrollGrid.verticalMargin = verticalMargin
    scrollGrid.horizontalMargin = horizontalMargin

    scrollGrid.accentColor = AF.GetAddonAccentColorName()

    -- slotFrame
    local slotFrame = CreateFrame("Frame", nil, scrollGrid)
    scrollGrid.slotFrame = slotFrame
    AF.SetPoint(slotFrame, "TOPLEFT", horizontalMargin, -verticalMargin)
    AF.SetPoint(slotFrame, "BOTTOMRIGHT", -horizontalMargin, verticalMargin)

    -- scrollBar
    local scrollBar = AF.CreateBorderedFrame(scrollGrid, nil, 5, nil, color, borderColor)
    scrollGrid.scrollBar = scrollBar
    AF.SetPoint(scrollBar, "TOPRIGHT", 0, -verticalMargin)
    AF.SetPoint(scrollBar, "BOTTOMRIGHT", 0, verticalMargin)
    scrollBar:Hide()

    -- scrollBar thumb
    local scrollThumb = AF.CreateBorderedFrame(scrollBar, nil, 5, nil, AF.GetColorTable(scrollGrid.accentColor, 0.7))
    scrollGrid.scrollThumb = scrollThumb
    scrollThumb.root = scrollGrid
    scrollThumb.r, scrollThumb.g, scrollThumb.b = AF.GetColorRGB(scrollGrid.accentColor)
    -- AF.SetPoint(scrollThumb, "TOP")
    scrollThumb:EnableMouse(true)
    scrollThumb:SetMovable(true)
    scrollThumb:SetHitRectInsets(-5, -5, 0, 0) -- Frame:SetHitRectInsets(left, right, top, bottom)
    scrollThumb:SetScript("OnEnter", ScorllThumb_OnEnter)
    scrollThumb:SetScript("OnLeave", ScorllThumb_OnLeave)

    -- slots
    scrollGrid.slots = {}

    Mixin(scrollGrid, AF_ScrollGridMixin)
    scrollGrid:UpdateSlots()

    -- items
    scrollGrid.widgets = {}
    scrollGrid.widgetNum = 0

    -- for mouse wheel ----------------------------------------------
    scrollGrid:SetScrollStep(1)

    -- enable mouse wheel scroll
    scrollGrid:EnableMouseWheel(true)
    scrollGrid:SetScript("OnMouseWheel", ScrollRoot_OnMouseWheel)
    -----------------------------------------------------------------

    -- dragging and scrolling ---------------------------------------
    scrollThumb:SetScript("OnMouseDown", ScrollRoot_OnMouseDown)
    scrollThumb:SetScript("OnMouseUp", ScrollRoot_OnMouseUp)
    -----------------------------------------------------------------

    AF.AddToPixelUpdater_OnShow(scrollGrid)

    return scrollGrid
end