---@class AbstractFramework
local AF = _G.AbstractFramework

local select, abs, max, ceil = select, abs, max, ceil
local Round = AF.Round
local ApproxZero = AF.ApproxZero
local GetCursorPosition = GetCursorPosition

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

---------------------------------------------------------------------
-- scroll frame
---------------------------------------------------------------------
---@class AF_ScrollFrame:AF_BorderedFrame
local AF_ScrollFrameMixin = {}

-- reset scrollContent height (reset scroll range)
function AF_ScrollFrameMixin:ResetHeight()
    AF.SetHeight(self.scrollContent, 5)
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

function AF_ScrollFrameMixin:SetContentHeight(height, num, spacing, topPadding, bottomPadding)
    self:ResetScroll()
    if num and spacing then
        AF.SetListHeight(self.scrollContent, num, height, spacing, topPadding, bottomPadding)
    else
        AF.SetHeight(self.scrollContent, height)
    end
end

function AF_ScrollFrameMixin:SetScrollStep(step)
    self.step = step
end

function AF_ScrollFrameMixin:ClearContent()
    for _, c in pairs({self.scrollContent:GetChildren()}) do
        c:SetParent(nil)
        c:ClearAllPoints()
        c:Hide()
    end
    self:ResetHeight()
end

function AF_ScrollFrameMixin:Reset()
    self:ResetScroll()
    self:ClearContent()
end

function AF_ScrollFrameMixin:UpdatePixels()
    -- scrollBar / scrollThumb / children already AddToPixelUpdater
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
    local scrollContent = CreateFrame("Frame", nil, scrollFrame, "BackdropTemplate")
    scrollParent.scrollContent = scrollContent
    AF.SetSize(scrollContent, width, 5)
    scrollFrame:SetScrollChild(scrollContent)
    -- AF.SetPoint(scrollContent, "RIGHT") -- update width with scrollFrame

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

    -- on width changed (scrollBar show/hide)
    scrollFrame:SetScript("OnSizeChanged", function()
        -- update scrollContent width
        scrollContent:SetWidth(scrollFrame:GetWidth())
    end)

    -- check if it can scroll
    -- DO NOT USE OnScrollRangeChanged to check whether it can scroll.
    -- "invisible" widgets should be hidden, then the scroll range is NOT accurate!
    -- scrollFrame:SetScript("OnScrollRangeChanged", function(self, xOffset, yOffset) end)
    scrollContent:SetScript("OnSizeChanged", function()
        -- set thumb height (%)
        local p = scrollFrame:GetHeight() / scrollContent:GetHeight()
        p = tonumber(string.format("%.3f", p))
        if p < 1 then -- can scroll
            scrollThumb:SetHeight(max(scrollBar:GetHeight() * p, MIN_SCROLL_THUMB_HEIGHT))
            -- space for scrollBar
            AF.SetPoint(scrollFrame, "BOTTOMRIGHT", -7, 0)
            scrollBar:Show()
        else
            AF.SetPoint(scrollFrame, "BOTTOMRIGHT")
            scrollBar:Hide()
            scrollFrame:SetVerticalScroll(0)
        end
    end)

    local function OnVerticalScroll(self, offset)
        if scrollParent:GetVerticalScrollRange() ~= 0 then
            local scrollP = scrollFrame:GetVerticalScroll() / scrollParent:GetVerticalScrollRange()
            local yoffset = -((scrollBar:GetHeight() - scrollThumb:GetHeight()) * scrollP)
            scrollThumb:SetPoint("TOP", 0, yoffset)
        end
    end
    scrollFrame:SetScript("OnVerticalScroll", OnVerticalScroll)

    -- dragging and scrolling
    scrollThumb:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        scrollFrame:SetScript("OnVerticalScroll", nil) -- disable OnVerticalScroll

        local offsetY = select(5, scrollThumb:GetPoint(1))
        local mouseY = select(2, GetCursorPosition()) -- https://warcraft.wiki.gg/wiki/API_GetCursorPosition
        local scale = scrollThumb:GetEffectiveScale()
        local currentScroll = scrollFrame:GetVerticalScroll()
        self:SetScript("OnUpdate", function(self)
            local newMouseY = select(2, GetCursorPosition())
            ------------------ y offset before dragging + mouse offset
            local newOffsetY = offsetY + (newMouseY - mouseY) / scale

            -- even scrollThumb:SetPoint is already done in OnVerticalScroll, but it's useful in some cases.
            if newOffsetY >= 0 then -- top
                AF.SetPoint(scrollThumb, "TOP")
                newOffsetY = 0
            elseif (-newOffsetY) + scrollThumb:GetHeight() >= scrollBar:GetHeight() then -- bottom
                AF.SetPoint(scrollThumb, "TOP", 0, -(scrollBar:GetHeight() - scrollThumb:GetHeight()))
                newOffsetY = -(scrollBar:GetHeight() - scrollThumb:GetHeight())
            else
                AF.SetPoint(scrollThumb, "TOP", 0, newOffsetY)
            end
            local vs = (-newOffsetY / (scrollBar:GetHeight()-scrollThumb:GetHeight())) * scrollParent:GetVerticalScrollRange()
            scrollFrame:SetVerticalScroll(vs)
        end)
    end)

    scrollThumb:SetScript("OnMouseUp", function(self)
        scrollFrame:SetScript("OnVerticalScroll", OnVerticalScroll) -- enable OnVerticalScroll
        self:SetScript("OnUpdate", nil)
    end)

    -- enable mouse wheel scroll
    scrollParent:SetScrollStep(25)
    scrollParent:EnableMouseWheel(true)
    scrollParent:SetScript("OnMouseWheel", function(self, delta)
        if delta == 1 then -- scroll up
            scrollParent:VerticalScroll(AF.ConvertPixelsForRegion(-scrollParent.step, scrollFrame))
        elseif delta == -1 then -- scroll down
            scrollParent:VerticalScroll(AF.ConvertPixelsForRegion(scrollParent.step, scrollFrame))
        end
    end)

    AF.AddToPixelUpdater(scrollParent)

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
function AF_ScrollListMixin:UpdateSlots()
    for i = 1, self.slotNum do
        if not self.slots[i] then
            self.slots[i] = AF.CreateFrame(self.slotFrame)
            AF.RemoveFromPixelUpdater(self.slots[i])
            AF.SetHeight(self.slots[i], self.slotHeight)
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
    if self.slotNum == 0 then
        AF.SetHeight(self, 5)
    else
        AF.SetListHeight(self, self.slotNum, self.slotHeight, self.slotSpacing, self.verticalMargin, self.verticalMargin)
    end
    self:UpdateSlots()
end

function AF_ScrollListMixin:SetSlotHeight(newHeight)
    self.slotHeight = newHeight
    self:SetSlotNum(self.slotNum)
end

function AF_ScrollListMixin:SetWidgets(widgets)
    self:Reset()
    self.widgets = widgets
    self.widgetNum = #widgets
    self:SetScroll(1)

    -- call UpdatePixels on show
    for _, w in ipairs(self.widgets) do
        AF.RemoveFromPixelUpdater(w)
    end

    if self.widgetNum > self.slotNum then -- can scroll
        self.scrollBar:Show()
        local p = self.slotNum / self.widgetNum
        self.scrollThumb:SetHeight(max(self.scrollBar:GetHeight() * p, MIN_SCROLL_THUMB_HEIGHT))
        AF.SetPoint(self.slotFrame, "BOTTOMRIGHT", self.scrollBar, "BOTTOMLEFT", -self.horizontalMargin, 0)
    else
        self.scrollBar:Hide()
        AF.SetPoint(self.slotFrame, "BOTTOMRIGHT", -self.horizontalMargin, self.verticalMargin)
    end
end

-- reset
function AF_ScrollListMixin:Reset()
    self.widgets = {}
    self.widgetNum = 0
    -- hide slot widgets
    for _, s in ipairs(self.slots) do
        if s.widget then
            s.widget:Hide()
        end
        s.widget = nil
        s.widgetIndex = nil
    end
    -- resize / repoint
    AF.SetPoint(self.slotFrame, "BOTTOMRIGHT", 0, self.verticalMargin)
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
    local slotIndex = 1
    for i, w in ipairs(self.widgets) do
        w:ClearAllPoints()
        if i < from or i > to then
            w:Hide()
        else
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
        local offset = (from - 1) * ((self.scrollBar:GetHeight() - self.scrollThumb:GetHeight()) / self:GetScrollRange()) -- n * perHeight
        self.scrollThumb:SetPoint("TOP", 0, -offset)
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

function AF_ScrollListMixin:GetWidgetAt(index)
    if index and index > 0 and index <= self.slotNum then
        return self.slots[index].widget
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

function AF_ScrollListMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
    AF.RePoint(self.slotFrame)
    self.scrollBar:UpdatePixels()

    -- update slots and widgets
    for _, s in ipairs(self.slots) do
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

---@param verticalMargin number top/bottom margin
---@param horizontalMargin number left/right margin
---@param slotSpacing number spacing between widgets next to each other
---@return AF_ScrollList scrollList
function AF.CreateScrollList(parent, name, verticalMargin, horizontalMargin, slotNum, slotHeight, slotSpacing, color, borderColor)
    local scrollList = AF.CreateBorderedFrame(parent, name, nil, nil, color, borderColor)
    AF.SetListHeight(scrollList, slotNum, slotHeight, slotSpacing, verticalMargin, verticalMargin)

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

    AF.AddToPixelUpdater(scrollList)

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
        elseif i % self.slotColumn == 1 then
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

function AF_ScrollGridMixin:SetWidgets(widgets)
    self:Reset()
    self.widgets = widgets
    self.widgetNum = #widgets
    self:SetScroll(1)

    -- call UpdatePixels on show
    for _, w in ipairs(self.widgets) do
        AF.RemoveFromPixelUpdater(w)
    end

    if self:CanScroll() then
        self.scrollBar:Show()
        local p = self.slotRow / ceil(self.widgetNum / self.slotColumn)
        self.scrollThumb:SetHeight(max(self.scrollBar:GetHeight() * p, MIN_SCROLL_THUMB_HEIGHT))
        AF.SetPoint(self.slotFrame, "BOTTOMRIGHT", self.scrollBar, "BOTTOMLEFT", -self.horizontalMargin, 0)
    else
        self.scrollBar:Hide()
        AF.SetPoint(self.slotFrame, "BOTTOMRIGHT", -self.horizontalMargin, self.verticalMargin)
    end

    -- update slot size
    self:UpdateSlotSize()
end

-- reset
function AF_ScrollGridMixin:Reset()
    self.widgets = {}
    self.widgetNum = 0

    -- hide slot widgets
    for _, s in ipairs(self.slots) do
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
    for i, w in ipairs(self.widgets) do
        w:ClearAllPoints()
        if i < from or i > to then
            w:Hide()
        else
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

function AF_ScrollGridMixin:GetWidgetAt(index)
    if index and index > 0 and index <= self.slotNum then
        return self.slots[index].widget
    end
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
    for _, s in ipairs(self.slots) do
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

    AF.AddToPixelUpdater(scrollGrid)

    return scrollGrid
end