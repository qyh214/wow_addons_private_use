---@class AbstractFramework
local AF = _G.AbstractFramework

---@class AF_Sheet:Frame
local AF_SheetMixin = {}

---------------------------------------------------------------------
-- default
---------------------------------------------------------------------
local default = {
    -- header
    headerHeight = 20,
    -- row
    rowNum = 20,
    rowHeight = 20,
    -- column
    -- columnWidth = "fixed", -- TODO:
    columns = {
        {
            label = "A", -- for header
            key = "A", -- to match the key in data
            width = 50,
            -- optional
            justifyH = "CENTER",
            justifyV = "MIDDLE",
            points = { -- text anchors
                {"BOTTOMLEFT", 2, 2},
                {"BOTTOMRIGHT", -2, 2},
            },
            sort = {"key1:ASC", "key2:DESC", "key3:DESC"},
            setValue = function(self, value)

            end,
            onEnter = function(self)

            end,
            onLeave = function(self)

            end,
        },
    },
}

---------------------------------------------------------------------
-- sort
---------------------------------------------------------------------
local function Sort(sheet, widgets, keys)
    local function Compare(a, b)
        local cell, key, order
        for _, v in pairs(keys) do
            key, order = strsplit(":", v)
            cell = sheet.keyToIndex[key]
            if a[cell].value ~= b[cell].value then
                if order == "ASC" then
                    return a[cell].value < b[cell].value
                else
                    return a[cell].value > b[cell].value
                end
            end
        end
        return false
    end
    table.sort(widgets, Compare)
end

local function Header_Sort(self)
    local sheet = self:GetParent():GetParent()
    if sheet.sortBy ~= self.key then
        if sheet.sortBy then
            -- hide previous highlight
            self:GetParent()[sheet.keyToIndex[sheet.sortBy]].highlightTexture:Hide()
        end
        Sort(sheet, sheet.content.widgets, self.sort)
        sheet.content:SetScroll(sheet.content:GetScroll())
    end
    sheet.sortBy = self.key
end

function AF_SheetMixin:Sort(keys)
    local key, order = strsplit(":", keys[1])
    if self.sortBy ~= key then
        if self.sortBy then
            -- hide previous highlight
            self.header[self.keyToIndex[self.sortBy]].highlightTexture:Hide()
        end
        Sort(self, self.content.widgets, keys)
        self.content:SetScroll(self.content:GetScroll())
        self.header[self.keyToIndex[key]].highlightTexture:Show()
    end
    self.sortBy = key
end

---------------------------------------------------------------------
-- setup
---------------------------------------------------------------------
local function Cell_SetValue(self, value)
    self.text:SetText(value or "")
end

-- local function Cell_OnEnter(self)
--     -- self:SetBackdropColor(AF.GetColorRGB("gray", 0.2))
--     self.parent:GetScript("OnEnter")(self.parent)
-- end

-- local function Cell_OnLeave(self)
--     -- self:SetBackdropColor(AF.GetColorRGB("none"))
--     self.parent:GetScript("OnLeave")(self.parent)
-- end

local function Row_OnEnter(row)
    if row.parent then row = row.parent end
    row:SetBackdropColor(AF.GetColorRGB("sheet_highlight"))
end

local function Row_OnLeave(row)
    if row.parent then row = row.parent end
    row:SetBackdropColor(AF.GetColorRGB("none"))
end

local function Header_OnEnter(header)
    header.highlightTexture:Show()
end

local function Header_OnLeave(header)
    local sheet = header:GetParent():GetParent()
    if sheet.sortBy ~= header.key then
        header.highlightTexture:Hide()
    end
end

local function CreateCells(parent, config, isCell)
    for i, col in ipairs(config.columns) do
        parent[i] = CreateFrame("Button", nil, parent)
        parent[i].text = parent[i]:CreateFontString(nil, "OVERLAY", "AF_FONT_NORMAL")
        parent[i].SetValue = col.setValue or Cell_SetValue

        -- text alignment
        if col.justifyH then
            parent[i].text:SetJustifyH(col.justifyH)
        end
        if col.justifyV then
            parent[i].text:SetJustifyV(col.justifyV)
        end

        parent[i].key = col.key
        if isCell then
            parent[i].parent = parent
            AF.SetSize(parent[i], col.width, config.rowHeight)
            -- text points
            if col.points then
                for _, p in pairs(col.points) do
                    AF.SetPoint(parent[i].text, unpack(p))
                end
            else
                AF.SetPoint(parent[i].text, "LEFT", 2, 0)
                AF.SetPoint(parent[i].text, "RIGHT", -2, 0)
            end
            -- on enter/leave
            AF.ApplyDefaultBackdrop_NoBackground(parent[i])
            parent[i]:SetBackdropBorderColor(AF.GetColorRGB("black"))
            parent[i]:SetScript("OnEnter", Row_OnEnter)
            parent[i]:SetScript("OnLeave", Row_OnLeave)
            -- highlight
            parent[i].highlightTexture = parent[i]:CreateTexture(nil, "HIGHLIGHT")
            parent[i].highlightTexture:SetColorTexture(AF.GetColorRGB("sheet_cell_highlight"))
            parent[i].highlightTexture:SetBlendMode("ADD")
            AF.SetOnePixelInside(parent[i].highlightTexture, parent[i])
        else
            AF.SetSize(parent[i], col.width, config.headerHeight)
            AF.SetPoint(parent[i].text, "BOTTOMLEFT", 2, 3)
            AF.SetPoint(parent[i].text, "BOTTOMRIGHT", -2, 3)
            -- label
            parent[i]:SetValue(col.label)
            -- highlight
            parent[i].highlightTexture = parent[i]:CreateTexture(nil, "ARTWORK")
            parent[i].highlightTexture:SetColorTexture(AF.GetColorRGB("GRA"))
            AF.SetPoint(parent[i].highlightTexture, "TOPLEFT", parent[i], "BOTTOMLEFT", 1, 2)
            AF.SetPoint(parent[i].highlightTexture, "BOTTOMRIGHT", -1, 1)
            parent[i].highlightTexture:Hide()
            parent[i]:SetScript("OnEnter", Header_OnEnter)
            parent[i]:SetScript("OnLeave", Header_OnLeave)
            -- sort
            if col.sort then
                parent[i].sort = col.sort
                parent[i]:SetScript("OnClick", Header_Sort)
            else
                parent[i].sort = nil
                parent[i]:SetScript("OnClick", nil)
            end
        end
    end
end

local function InitHeader(header, config)
    AF.SetHeight(header, config.headerHeight)
    CreateCells(header, config)
end

function AF_SheetMixin:Setup(config)
    assert(type(config) == "table", "invalid config")
    self.config = config

    InitHeader(self.header, config)
    -- InitRows(self.content, config)

    wipe(self.keyToIndex)
    for i, col in pairs(config.columns) do
        self.keyToIndex[col.key] = i
    end
end

---------------------------------------------------------------------
-- load
---------------------------------------------------------------------
function AF_SheetMixin:LoadRow(row, data)
    row.data = data
    for _, cell in ipairs(row) do
        cell.value = data[cell.key]
        cell:SetValue(data[cell.key])
    end
end

function AF_SheetMixin:LoadData(data)
    self.data = data
    wipe(self.shownRows)
    -- local num = #data
    for i, t in pairs(data) do
        if not self.allRows[i] then
            --! create
            local row = CreateFrame("Button", nil, self.content.slotFrame)
            self.allRows[i] = row
            AF.ApplyDefaultBackdrop_NoBorder(row)
            row:SetBackdropColor(AF.GetColorRGB("none"))
            row:SetScript("OnEnter", Row_OnEnter)
            row:SetScript("OnLeave", Row_OnLeave)
            CreateCells(row, self.config, true)
        end
        self.shownRows[i] = self.allRows[i]
        self:LoadRow(self.shownRows[i], t)
    end
    self.content:SetWidgets(self.shownRows)
    self:SetShownColumns(self.shownColumns)
end

---------------------------------------------------------------------
-- get
---------------------------------------------------------------------
---@param index number row number
function AF_SheetMixin:GetRowByIndex(index)
    return self.shownRows[index]
end

---@param key string column key
---@param value number|string column value
function AF_SheetMixin:GetRowByKeyValue(key, value)
    key = self.keyToIndex[key]
    if not key then return end
    for i, row in pairs(self.shownRows) do
        if row[key] and row[key].value == value then
            return row, i
        end
    end
end

---------------------------------------------------------------------
-- set shown columns & update size
---------------------------------------------------------------------
---@param columns table? {[label/key] = true/false}
function AF_SheetMixin:SetShownColumns(columns)
    self.shownColumns = columns

    local width = 0
    local shownColumns = 0
    local lastIndex
    for i, col in pairs(self.config.columns) do
        if not columns or columns[col.key] then
            --! show
            shownColumns = shownColumns + 1
            width = width + AF.ConvertPixels(col.width)
            -- header
            AF.SetWidth(self.header[i], col.width)
            AF.ClearPoints(self.header[i])
            if lastIndex then
                AF.SetPoint(self.header[i], "TOPLEFT", self.header[lastIndex], "TOPRIGHT", -1, 0)
            else
                AF.SetPoint(self.header[i], "TOPLEFT")
            end
            self.header[i]:Show()
            -- rows
            for _, row in pairs(self.allRows) do
                AF.SetWidth(row[i], col.width)
                if lastIndex then
                    AF.SetPoint(row[i], "TOPLEFT", row[lastIndex], "TOPRIGHT", -1, 0)
                else
                    AF.SetPoint(row[i], "TOPLEFT")
                end
                row[i]:Show()
            end
            lastIndex = i
        else
            --! hide
            self.header[i]:Hide()
            -- rows
            for _, row in pairs(self.allRows) do
                row[i]:Hide()
            end
        end
    end

    -- size
    width = width + AF.ConvertPixels(-1) * (shownColumns - 1) + (#self.shownRows > self.config.rowNum and AF.ConvertPixels(7) or 0)
    self.header:SetWidth(width)
    self.content:SetWidth(width)

    local height = (AF.ConvertPixels(self.config.rowHeight) + AF.ConvertPixels(-1)) * self.config.rowNum + AF.ConvertPixels(self.config.headerHeight)
    self:SetSize(width, height)
    if self.onSizeChanged then
        self.onSizeChanged(width, height)
    end
end

---------------------------------------------------------------------
-- update pixels
---------------------------------------------------------------------
local function UpdatePixels(self)
    AF.DefaultUpdatePixels(self)

    AF.DefaultUpdatePixels(self.header)
    for _, cell in ipairs(self.header) do
        AF.RePoint(cell)
    end

    self.content:UpdatePixels()
    for _, row in ipairs(self.content.widgets) do
        for _, cell in ipairs(row) do
            AF.RePoint(cell)
            AF.RePoint(cell.highlightTexture)
        end
    end

    self:SetShownColumns(self.shownColumns)
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
---@param config table
---@param onSizeChanged function
---@return AF_Sheet sheet
function AF.CreateSheet(parent, name, config, onSizeChanged)
    local sheet = CreateFrame("Frame", name, parent)
    sheet.allRows = {}
    sheet.shownRows = {}
    sheet.keyToIndex = {}

    local header = CreateFrame("Frame", nil, sheet)
    sheet.header = header
    AF.SetPoint(header, "TOPLEFT")
    header:SetFrameLevel(sheet:GetFrameLevel() + 2)

    local content = AF.CreateScrollList(sheet, nil, 0, 0, config.rowNum, config.rowHeight, -1)
    sheet.content = content
    AF.SetPoint(content, "TOPLEFT", header, "BOTTOMLEFT", 0, 1)
    content:SetFrameLevel(sheet:GetFrameLevel() + 1)

    -- update backdrop
    content:ClearBackdrop()
    AF.ApplyDefaultBackdrop(content.slotFrame)
    AF.ApplyDefaultBackdropWithColors(content.slotFrame, "sheet_normal")

    sheet.onSizeChanged = onSizeChanged
    Mixin(sheet, AF_SheetMixin)

    if config then
        sheet:Setup(config)
    end

    -- update pixels
    AF.RemoveFromPixelUpdater(content)
    AF.AddToPixelUpdater_OnShow(sheet, nil, UpdatePixels)

    return sheet
end