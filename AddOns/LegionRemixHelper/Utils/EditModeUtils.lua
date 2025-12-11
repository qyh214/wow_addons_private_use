---@class AddonPrivate
local Private = select(2, ...)

---@class EditModeAnchorInfos
---@field point string
---@field relativeTo string
---@field relativePoint string
---@field xOfs number
---@field yOfs number

---@class EditModeUtils
local editModeUtils = {
    ---@type LegionRH
    addon = nil,
    ---@table
    systems = {},
    ---@type CheckBoxComponentObject|nil
    systemToggle = nil,
    ---@type boolean
    showSystems = true,
    ---@type table<any, string>
    L = nil,
}
Private.EditModeUtils = editModeUtils

local const = Private.constants

function editModeUtils:Init()
    self.L = Private.L
    local addon = Private.Addon
    self.addon = addon

    EventRegistry:RegisterCallback("EditMode.Enter", function()
        self:OnEnterEditMode()

        self:CreateSystemToggle()
    end)
    EventRegistry:RegisterCallback("EditMode.Exit", function()
        self:OnExitEditMode()
    end)
end

function editModeUtils:CreateSystemToggle()
    if self.systemToggle then return end
    local checkBox = Private.Components.CheckBox:CreateFrame(EditModeManagerFrame, {
        text = self.L["EditModeUtils.ShowAddonSystems"],
        onClick = function(checked)
            self.showSystems = checked
            if checked then
                self:OnEnterEditMode()
            else
                self:OnExitEditMode()
            end
        end,
        checked = self.showSystems,
        anchors = { {"TOP", 15, -50} }
    })
    self.systemToggle = checkBox
end

function editModeUtils:OnEnterEditMode()
    if not self.showSystems then return end
    for _, system in pairs(self.systems) do
        system:HighlightSystem()
        system:Show()
    end
end

function editModeUtils:OnExitEditMode()
    for _, system in pairs(self.systems) do
        system:ClearHighlight()
        system:Hide()
    end
end

---@param systemName string
---@param parentFrame Frame
---@param width number|nil
---@param height number|nil
---@param onPositionChanged nil|fun(newPointData: EditModeAnchorInfos)
function editModeUtils:CreateSystem(systemName, parentFrame, width, height, onPositionChanged)
    if self.systems[systemName] then
        error("System with name '" .. systemName .. "' already exists!")
        return
    end

    local system = CreateFrame("Frame", nil, parentFrame, "EditModeSystemTemplate")
    local selection = CreateFrame("Frame", nil, system, "EditModeSystemSelectionTemplate")
    selection:SetAllPoints()
    system:SetSize(width or const.EDIT_MODE.DEFAULT_SYSTEM_WIDTH, height or const.EDIT_MODE.DEFAULT_SYSTEM_HEIGHT)

    local point = self.addon:GetDatabaseValue("editMode." .. systemName, true) or {}
    system:ClearAllPoints()
    system:SetPoint(point.point or "CENTER", point.relativeTo or parentFrame, point.relativePoint or "CENTER", point.xOfs or 0, point.yOfs or 0)

    function system:OnDragStart()
        self:SetMovable(true)
        self:StartMoving()
    end

    function selection:GetLabelText()
        return editModeUtils.L["EditModeUtils.SystemLabel." .. systemName]
    end

    function system:OnDragStop()
        self:StopMovingOrSizing()
        local newPoint = {self:GetPoint()}
        local newPointData = {
            point = newPoint[1],
            relativeTo = self:GetParent():GetName(),
            relativePoint = newPoint[3],
            xOfs = newPoint[4],
            yOfs = newPoint[5],
        }
        editModeUtils.addon:SetDatabaseValue("editMode." .. systemName, newPointData)

        if onPositionChanged then
            onPositionChanged(newPointData)
        end
    end

    selection.system = {
        GetSystemName = function ()
            return editModeUtils.L["EditModeUtils.SystemTooltip." .. systemName]
        end
    }

    system:Hide()
    self.systems[systemName] = system
end

---@param systemName string
---@return table|Frame system
function editModeUtils:GetSystem(systemName)
    return self.systems[systemName]
end