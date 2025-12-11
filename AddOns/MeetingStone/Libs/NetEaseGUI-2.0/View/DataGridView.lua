
local WIDGET, VERSION = 'DataGridView', 2

local GUI = LibStub('NetEaseGUI-2.0')
local DataGridView = GUI:NewClass(WIDGET, GUI:GetClass('ListView'), VERSION)
if not DataGridView then
    return
end

function DataGridView:Constructor()
    self.sortButtons = {}
    self.sortCache = setmetatable({}, {
        __mode = 'k',
        __index = function(o, k)
            local value = self:MakeSortValue(k)
            o[k] = value
            return value
        end,
    })
    self:SetCallback('OnItemCreated', self.OnItemCreated)
    self:SetCallback('OnItemFormatted', self.OnItemFormatted)
end

function DataGridView:MakeSortValue(object)
    local value, base
    if type(object) == 'table' and object.BaseSortHandler then
        base = object:BaseSortHandler()
    end
    if self.sortHandler then
        value = self.sortHandler(object)
    end
    if not base then
        return value
    else
        if type(value) == 'number' then
            if value < 0 then
                return format('%044.4f', value) .. base
            else
                return format('%045.4f', value) .. base
            end
        else
            value = strsub(tostring(value), 1, 50)
            return value .. strrep(value, 50 - #value) .. base
        end
    end
end

function DataGridView:OnItemFormatted(button, data)
    for i, v in ipairs(self.sortButtons) do
        local grid = button[v.key]
        if grid and data then
            if v.showHandler then
                local text, r, g, b, icon, left, right, top, bottom, width, height = v.showHandler(data)

                grid:SetText(text)
                grid:GetFontString():SetTextColor(r or 1, g or 1, b or 1)
                grid:SetIcon(icon, left, right, top, bottom, width, height)
            end
            if v.textHandler then
                local text, r, g, b = v.textHandler(data)
                grid:SetText(text)
                grid:GetFontString():SetTextColor(r or 1, g or 1, b or 1)
            end
            if v.iconHandler then
                grid:SetIcon(v.iconHandler(data))
            end
            if v.atlasHandler then
                grid:SetIconAtlas(v.atlasHandler(data))
            end
            if  v.formatHandler then
                v.formatHandler(grid, data)
            end
        end
    end
end

function DataGridView:SetHeaderPoint(...)
    if not self.sortButtons[1] then
        error('message', 2)
    end
    self.sortButtons[1]:SetPoint(...)
end

function DataGridView:AddHeader(args)
    local Button = GUI:GetClass('SortButton'):New(self)
    Button:SetSize(args.width, 19)
    Button:SetText(args.text)
    Button.key = args.key
    Button.width = args.width
    Button.style = args.style
    Button.class = args.class
    Button.enableMouse = args.enableMouse
    Button.sortHandler = args.sortHandler
    Button.showHandler = args.showHandler
    Button.formatHandler = args.formatHandler
    Button.textHandler = args.textHandler
    Button.iconHandler = args.iconHandler
    Button.atlasHandler = args.atlasHandler
    Button.isVisible = true  -- 默认可见

    if #self.sortButtons > 0 then
        Button:SetPoint('LEFT', self.sortButtons[#self.sortButtons], 'RIGHT', -1, 0)
    end
    tinsert(self.sortButtons, Button)
end

function DataGridView:InitHeader(data)
    for i, v in ipairs(data) do
        self:AddHeader(v)
    end
end

function DataGridView:SetSortHandler(sortHandler, desc)
    if sortHandler ~= self.sortHandler then
        self.sortDesc = desc
    else
        self.sortDesc = not self.sortDesc
    end
    -- if sortHandler ~= self.sortHandler then
    --     wipe(self.sortCache)
    -- end
    self.sortHandler = sortHandler
    -- self:Sort()
    -- self:UpdateFilter()
    self:Refresh()
end

function DataGridView:GetSortHandler()
    return self.sortHandler
end

function DataGridView:GetSortDesc()
    return self.sortDesc
end

function DataGridView:Update()
    for i, button in ipairs(self.sortButtons) do
        if button.sortHandler and button.sortHandler == self.sortHandler then
            button:SetArrowStyle(self.sortDesc and 'UP' or 'DOWN')
        else
            button:SetArrowStyle('NONE')
        end
    end
    self:Sort()
    self:SuperCall('Update')
end

function DataGridView:Sort()
    if not self.sortHandler then
        return
    end

    wipe(self.sortCache)

    local itemList = self:GetItemList()
    if type(itemList) == 'table' then
        -- 预填充sortCache，确保所有值都存在
        for _, item in ipairs(itemList) do
            if not self.sortCache[item] then
                self.sortCache[item] = self.sortHandler(item) or 0
            end
        end

        if self.sortDesc then
            sort(itemList, function(a, b)
                return (self.sortCache[a] or 0) > (self.sortCache[b] or 0)
            end)
        else
            sort(itemList, function(a, b)
                return (self.sortCache[a] or 0) < (self.sortCache[b] or 0)
            end)
        end
    end
end

function DataGridView:SetItemList(itemList)
    self:SuperCall('SetItemList', itemList)
    self:Refresh()
end

function DataGridView:SetColumnVisible(key, visible)
    -- 1. 更新列状态
    for _, button in ipairs(self.sortButtons) do
        if button.key == key then
            button.isVisible = visible
            if visible then
                -- 恢复显示时，使用原始宽度
                button:SetWidth(button.originalWidth or button.width)
                button:Show()
            else
                -- 隐藏时，保存当前宽度并设置为最小宽度
                button.originalWidth = button.width
                button:SetWidth(0.001)
                button:Hide()
            end
            break
        end
    end

    -- 2. 更新所有已创建项目的布局
    self:UpdateItemLayout()

    -- 3. 强制刷新所有项目数据和布局
    self:Refresh()
end

function DataGridView:UpdateItemLayout()
    -- 更新所有已创建的按钮，无论是否显示
    for _, button in ipairs(self.buttons) do
        self:UpdateItemLayoutForButton(button)
    end
end

function DataGridView:UpdateItemLayoutForButton(button)
    local x = 0
    for i, v in ipairs(self.sortButtons) do
        local grid = button[v.key]
        if grid then
            -- 动态调整宽度：隐藏列设为0.001，可见列使用原始宽度
            local width = (not v.isVisible) and 0.001 or (v.originalWidth or v.width)

            grid:ClearAllPoints()
            grid:SetPoint('TOPLEFT', button, 'TOPLEFT', x, 0)
            grid:SetPoint('BOTTOMLEFT', button, 'BOTTOMLEFT', x, 0)

            -- 特殊处理最后一个列：拉伸到剩余空间
            if i == #self.sortButtons then
                grid:SetPoint('TOPRIGHT', button, 'TOPLEFT', x + width, 0)
            else
                grid:SetWidth(width)
            end

            -- 只有可见列才增加x坐标
            if v.isVisible then
                x = x + width - 1  -- -1防止边框重叠
            end

            -- 设置Grid的可见性和交互性
            grid:SetShown(v.isVisible)  -- 使用Show/Hide而不是SetAlpha
        end
    end
end

function DataGridView:OnItemCreated(button)
    -- 创建Grids
    for i, v in ipairs(self.sortButtons) do
        local Grid
        if v.class then
            Grid = v.class:New(button)
        else
            Grid = GUI:GetClass('DataGridViewGridItem'):New(button, v.style)
        end

        Grid:EnableMouse(v.enableMouse)
        Grid:SetFrameLevel(button:GetFrameLevel()+1)
        Grid.key = v.key
        button[v.key] = Grid
        self:Fire('OnGridCreated', Grid, v.key)
    end

    -- 初始布局
    self:UpdateItemLayoutForButton(button)
end

