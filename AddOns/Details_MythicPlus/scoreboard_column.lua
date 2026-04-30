local addonName, private = ...

---@type detailsmythicplus
local addon = private.addon
local ScoreboardColumn = {}
addon.ScoreboardColumn = ScoreboardColumn

---@class scoreboard_column
---@field GetId fun(self: scoreboard_column) : string
---@field GetHeaderText fun(self: scoreboard_column) : string
---@field ShouldShowHeaderText fun(self: scoreboard_column) : boolean
---@field GetWidth fun(self: scoreboard_column) : number
---@field SetOnRender fun(self: scoreboard_column, callback: fun(frame: frame, playerData: scoreboard_playerdata, isBest: boolean))
---@field CalculateBestPlayerData fun(self: scoreboard_column, allPlayerData: scoreboard_playerdata[]) : scoreboard_playerdata[]
---@field SetCalculateBestLine fun(self: scoreboard_column, callback: fun(allPlayerData: scoreboard_playerdata[]))
---@field Render fun(self: scoreboard_column, playerData: scoreboard_playerdata)
---@field BindToLine fun(self: scoreboard_column, line: scoreboard_line) : frame
---@field GetFrameObject fun(self: scoreboard_column) : frame|nil

local ScoreboardColumnMixin = {
    ColumnId = nil,
    HeaderText = nil,
    Width = nil,
    Constructor = nil,
    OnRender = function () end,
    OnCalculateBestLine = function () end,
    FrameObject = nil,
    ShowHeaderText = nil,
}

---@return scoreboard_column
function ScoreboardColumn:Create(id, headerText, width, constructor, showHeaderText)
    local column = CreateFromMixins(ScoreboardColumnMixin)
    column.ColumnId = id
    column.Width = width
    column.Constructor = constructor
    column.HeaderText = headerText
    column.ShowHeaderText = showHeaderText == nil or showHeaderText == true

    return column
end

function ScoreboardColumnMixin:GetId()
    return self.ColumnId
end

function ScoreboardColumnMixin:GetHeaderText()
    return self.HeaderText
end

function ScoreboardColumnMixin:ShouldShowHeaderText()
    return self.ShowHeaderText
end

function ScoreboardColumnMixin:GetWidth()
    return self.Width
end

function ScoreboardColumnMixin:SetOnRender(callback)
    self.OnRender = callback
end

function ScoreboardColumnMixin:CalculateBestPlayerData(allPlayerData)
    return self.OnCalculateBestLine(allPlayerData)
end

function ScoreboardColumnMixin:SetCalculateBestLine(callback)
    self.OnCalculateBestLine = callback
end

function ScoreboardColumnMixin:Render(frame, playerData, isBest)
    self.OnRender(frame, playerData, isBest)
end

function ScoreboardColumnMixin:GetFrameObject()
    return self.FrameObject
end

function ScoreboardColumnMixin:BindToLine(line)
    local frame = self.Constructor(line)
    if private.buildVersion >= 50000 then
    frame.ColumnDefinition = self
    self.FrameObject = frame
    return frame
    end
end
