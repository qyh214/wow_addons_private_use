---@class AddonPrivate
local Private = select(2, ...)

---@class ToastUI
---@field utils ToastUtils
---@field toastPool AlertComponentObject[]
---@field activeToasts table<AlertComponentObject, boolean>
---@field toastAnchor Frame
local toastUI = {
    utils = nil,
    toastPool = {},
    activeToasts = {},
    toastAnchor = nil,
}
Private.ToastUI = toastUI

local const = Private.constants
local components = Private.Components

function toastUI:Init()
    self.utils = Private.ToastUtils
    self.toastPool = {}

    local toastAnchor = CreateFrame("Frame", nil, UIParent)
    toastAnchor:SetFrameStrata("TOOLTIP")
    toastAnchor:SetSize(1, 1)
    toastAnchor:SetPoint("TOP", -0, -50)
    self.toastAnchor = toastAnchor
end

---@return AlertComponentObject
function toastUI:NewToastFrame()
    local toastFrame = components.Alert:CreateFrame(self.toastAnchor, {
        onHide = function(obj)
            toastUI.activeToasts[obj] = nil
            self:ReorderFrames()
            tinsert(self.toastPool, obj)
        end,
        onShow = function(obj)
            toastUI.activeToasts[obj] = true
            self:ReorderFrames()
        end,
    })
    toastFrame.frame:Hide()
    return toastFrame
end

---@return AlertComponentObject
function toastUI:GetFromToastPool()
    local toastFrame = tremove(self.toastPool)
    if not toastFrame then
        toastFrame = self:NewToastFrame()
    end
    return toastFrame
end

---@param title string
---@param description string
---@param texture string|number
---@param onClick fun(self: AlertComponentObject, button: string, down: boolean)?
function toastUI:ShowToast(title, description, texture, onClick)
    local toast = self:GetFromToastPool()
    toast:SetTitle(title)
    toast:SetDescription(description)
    toast:SetIcon(texture)
    toast:SetOnClick(onClick)
    toast.frame:Show()
end

---@return AlertComponentObject[]
function toastUI:GetSortedActiveToasts()
    local sortedToasts = {}
    for toast in pairs(self.activeToasts) do
        tinsert(sortedToasts, toast)
    end
    sort(sortedToasts, function(a, b)
        return a:GetShownTime() < b:GetShownTime()
    end)
    return sortedToasts
end

function toastUI:ReorderFrames()
    local sortedToasts = self:GetSortedActiveToasts()
    local previousFrame = nil
    for i, toast in ipairs(sortedToasts) do
        local frame = toast.frame
        frame:ClearAllPoints()
        if i == 1 then
            frame:SetPoint("TOP", self.toastAnchor, "TOP", 0, 0)
        else
            frame:SetPoint("TOP", previousFrame, "BOTTOM", 0, -10)
        end
        previousFrame = frame
    end
end

function toastUI:CreateEditModeElements()
    local editModeUtils = Private.EditModeUtils
    editModeUtils:CreateSystem("ToastUI", UIParent, 311, 78, function (anchorInfo)
        self.toastAnchor:ClearAllPoints()
        self.toastAnchor:SetPoint(anchorInfo.point, anchorInfo.relativeTo, anchorInfo.relativePoint, anchorInfo.xOfs, anchorInfo.yOfs)
    end)
end