---@class AddonPrivate
local Private = select(2, ...)

---@class ResearchTaskUtils
---@field progress number|nil
---@field total number|nil
---@field lastTooltipUpdate number|nil
---@field callbackUtils CallbackUtils
local researchTaskUtils = {
    progress = nil,
    total = nil,
    lastTooltipUpdate = nil,
    callbackUtils = nil
}
Private.ResearchTaskUtils = researchTaskUtils

local const = Private.constants

function researchTaskUtils:Init()
    self.callbackUtils = Private.CallbackUtils
    local addon = Private.Addon

    addon:RegisterEvent("UPDATE_UI_WIDGET", "researchTaskUtils_UpdateUIWidget", function(_, _, widgetInfo)
        if widgetInfo and widgetInfo.widgetID == const.RESEARCH_TASKS.WIDGET_ID then
            self:UpdateTaskProgress()
        end
    end)
end

---@return number|nil progress
---@return number|nil total
function researchTaskUtils:GetTaskProgress()
    if not self.progress or not self.total then
        self:UpdateTaskProgress()
    end
    return self.progress, self.total
end

function researchTaskUtils:UpdateTaskProgress()
    local info = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(const.RESEARCH_TASKS.WIDGET_ID)
    if not info then return end

    self.progress = info.barValue
    self.total = info.barMax

    self:TriggerCallbacks()
end

---@return string|nil tooltipText
function researchTaskUtils:GetCurrentTooltipText()
    local now = GetTime()
    if self.lastTooltipUpdate and now - self.lastTooltipUpdate < 0.5 then
        return
    end
    self.lastTooltipUpdate = now

    local info = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(const.RESEARCH_TASKS.WIDGET_ID)
    if not info then return end

    return info.tooltip
end

---@param callbackFunction fun(progress:number|nil, total:number|nil)
---@return CallbackObject|nil callbackObject
function researchTaskUtils:AddCallback(callbackFunction)
    return self.callbackUtils:AddCallback(const.RESEARCH_TASKS.CALLBACK_CATEGORY, callbackFunction)
end

---@param callbackObj CallbackObject
function researchTaskUtils:RemoveCallback(callbackObj)
    self.callbackUtils:RemoveCallback(callbackObj)
end

function researchTaskUtils:TriggerCallbacks()
    local callbacks = self.callbackUtils:GetCallbacks(const.RESEARCH_TASKS.CALLBACK_CATEGORY)
    local progress, total = self:GetTaskProgress()
    for _, callback in ipairs(callbacks) do
        callback:Trigger(progress, total)
    end
end
