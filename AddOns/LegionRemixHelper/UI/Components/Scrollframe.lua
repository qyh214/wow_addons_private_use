---@class AddonPrivate
local Private = select(2, ...)

Private.Components = Private.Components or {}

---@class ScrollFrameComponentObject: ScrollFrameComponentMixin

---@class ScrollFrameComponentOptions
---@field frame_strata FrameStrata?
---@field width number?
---@field height number?
---@field anchors table?
---@field type "LIST"|"GRID"|?
---@field template string?
---@field initializer fun(frame:Frame|table, data:table)?
---@field extent_calculator ?(fun(dataIndex:number, elementData:table):size:number)|(fun(dataIndex:number, elementData:table):width:number, height:number)
---@field elements_per_row number?
---@field element_padding number?
---@field element_height number?
---@field element_width number?
---@field fill_width boolean?
local defaultOptions = {
    frame_strata = "HIGH",
    width = 250,
    height = 150,
    anchors = {
        with_scroll_bar = {
            { "TOPLEFT",     12,  -54 },
            { "BOTTOMRIGHT", -37, 49 }
        },
        without_scroll_bar = {
            { "TOPLEFT",     12,  -54 },
            { "BOTTOMRIGHT", -37, 49 }
        },
    },
    type = "LIST",
    template = "BackdropTemplate",
    initializer = nil,
    extent_calculator = nil,
    elements_per_row = 4,
    element_padding = 4,
    element_height = 40,
    element_width = 40,
    fill_width = false,
}

---@class ScrollFrameComponent
---@field defaultOptions ScrollFrameComponentOptions
local scrollFrameComponent = {
    defaultOptions = defaultOptions,
}
Private.Components.ScrollFrame = scrollFrameComponent

local componentsBase = Private.Components.Base

---@class ScrollFrameComponentMixin
---@field scrollBox ScrollBoxFrame
---@field scrollView ScrollView
---@field scrollBar ScrollBar
---@field lastQueuedChange table[]?
local scrollFrameComponentMixin = {
    scrollBox = nil,
    scrollView = nil,
    scrollBar = nil,
    lastQueuedChange = nil
}

---@param data table[]
---@param keepOldData boolean?
function scrollFrameComponentMixin:UpdateContent(data, keepOldData)
    if not data then return end
    local view = self.scrollView
    if not view then return end
    if not self.scrollBox:IsVisible() then
        self.lastQueuedChange = { data, keepOldData }
        return
    end
    local scrollPercent = self.scrollBox:GetScrollPercentage()
    local dataProvider = view:GetDataProvider()
    if not dataProvider then
        dataProvider = CreateDataProvider()
        view:SetDataProvider(dataProvider)
    end
    if not keepOldData then
        dataProvider:Flush()
    end
    dataProvider:Insert(unpack(data))
    self.scrollBox:SetScrollPercentage(scrollPercent or 1)
end

---@param parent Frame?
---@param options ScrollFrameComponentOptions
---@return ScrollFrameComponentObject scrollableFrame
function scrollFrameComponent:CreateFrame(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    options = componentsBase:MixTables(defaultOptions, options)

    ---@class ScrollBoxFrame : Frame
    ---@field GetScrollPercentage fun(self:ScrollBoxFrame)
    ---@field SetScrollPercentage fun(self:ScrollBoxFrame, percentage:number)
    local scrollBox = CreateFrame("Frame", nil, parent, "WowScrollBoxList")
    scrollBox:SetFrameStrata(options.frame_strata)
    scrollBox:SetSize(options.width, options.height)

    ---@class ScrollBar : EventFrame
    ---@field SetHideIfUnscrollable fun(self:ScrollBar, hideScrollBar:boolean)
    local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 5, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT")
    scrollBar:SetFrameStrata(options.frame_strata)
    scrollBar:SetHideIfUnscrollable(true)

    ---@class ScrollView : Frame
    ---@field SetElementExtentCalculator fun(self:ScrollView, extentCalculator:fun(dataIndex:number, elementData:table):number)
    ---@field SetElementSizeCalculator fun(self:ScrollView, sizeCalculator:fun(dataIndex:number, elementData:table):width:number, height:number)
    ---@field SetElementExtent fun(self:ScrollView, extent:number)
    ---@field Flush fun(self:ScrollView)
    ---@field SetDataProvider fun(self:ScrollView, dataProvider:table)
    ---@field GetDataProvider fun(self:ScrollView)
    local scrollView = nil
    if options.type == "LIST" then
        scrollView = CreateScrollBoxListLinearView()
        scrollView:SetElementInitializer(options.template or "BackdropTemplate", options.initializer)
        ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView)
    elseif options.type == "GRID" then
        local fillWidth = (parent:GetWidth() - (options.elements_per_row - 1) * options.element_padding) /
            options.elements_per_row
        scrollView = CreateScrollBoxListGridView(options.elements_per_row)
        scrollView:SetPadding(options.element_padding, 0, 0, 0, options.element_padding, options.element_padding)
        scrollView:SetElementInitializer(options.template or "BackdropTemplate", function(elementFrame, elementData)
            elementFrame:SetSize(options.fill_width and fillWidth or options.element_width, options.element_height)
            options.initializer(elementFrame, elementData)
        end)

        ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView)
    end
    if options.extent_calculator then
        if options.type == "LIST" then
            scrollView:SetElementExtentCalculator(options.extent_calculator)
        elseif options.type == "GRID" then
            scrollView:SetElementSizeCalculator(options.extent_calculator)
        end
    else
        if options.type == "LIST" then
            scrollView:SetElementExtent(options.element_height)
        elseif options.type == "GRID" then
            if scrollView.SetElementSizeCalculator then
                scrollView:SetElementSizeCalculator(function()
                    return options.element_width, options.element_height
                end)
            else
                scrollView:SetElementExtent(options.element_height)
            end
        end
    end

    local function setAnchors(withScrollBar)
        scrollBox:ClearAllPoints()
        for _, anchor in ipairs(withScrollBar and options.anchors.with_scroll_bar or options.anchors.without_scroll_bar) do
            scrollBox:SetPoint(unpack(anchor))
        end
    end
    scrollBar:HookScript("OnShow", function()
        setAnchors(true)
    end)
    scrollBar:HookScript("OnHide", function()
        setAnchors()
    end)

    scrollBox:HookScript("OnShow", function()
        ---@diagnostic disable-next-line: undefined-field
        local obj = scrollBox.obj
        ---@cast obj ScrollFrameComponentObject
        if obj and obj.lastQueuedChange then
            obj:UpdateContent(unpack(obj.lastQueuedChange))
            obj.lastQueuedChange = nil
        end
    end)

    setAnchors()

    return self:CreateObject(scrollBox, scrollView, scrollBar)
end

---@param scrollBox ScrollBoxFrame|table
---@param scrollView ScrollView
---@param scrollBar ScrollBar
---@return ScrollFrameComponentObject
function scrollFrameComponent:CreateObject(scrollBox, scrollView, scrollBar)
    local obj = {}
    obj.scrollBox = scrollBox
    obj.scrollView = scrollView
    obj.scrollBar = scrollBar

    setmetatable(obj, { __index = scrollFrameComponentMixin })

    scrollBox.obj = obj

    return obj
end
