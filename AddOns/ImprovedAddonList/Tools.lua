local _, Addon = ...

-- 事件Frame
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    local observers = self[event]
    if not observers then return end
    for func, _ in pairs(observers) do
        func(...)
    end
end)

function Addon:RegisterEvent(event, func)
    if type(event) ~= "string" then error("event must be a string") end
    if not func then return end

    eventFrame:RegisterEvent(event)
    eventFrame[event] = eventFrame[event] or {}
    eventFrame[event][func] = true
end

function Addon:UnregisterEvent(event, func)
    if type(event) ~= "string" then error("event must be a string") end
    local observers = eventFrame[event]
    if not observers then return end
    if not func then
        wipe(observers)
    else
        observers[func] = nil
    end
end

-- 回调
local callbackRegistry = CreateFromMixins(CallbackRegistryMixin)
callbackRegistry:OnLoad()
callbackRegistry:SetUndefinedEventsAllowed(true)

function Addon:RegisterCallback(event, func, owner, ...)
    return callbackRegistry:RegisterCallback(event, func, owner, ...)
end

function Addon:UnregisterCallback(event, owner)
    return callbackRegistry:UnregisterCallback(event, owner)
end

function Addon:TriggerEvent(event, ...)
    return callbackRegistry:TriggerEvent(event, ...)
end

-- 显示红字错误
function Addon:ShowError(text)
    UIErrorsFrame:AddMessage(text, 1.0, 0.0, 0.0, 1, 4)
end

-- 显示黄字消息
function Addon:ShowMessage(text)
    UIErrorsFrame:AddMessage(text, 1.0, 0.82, 0.0, 1, 3)
end

--copied from https://github.com/DengSir/LibShowUIPanel-1.0
-- LibShowUIPanel-1.0.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/15/2021, 11:20:01 PM

-- 绕过暴雪的战斗中Show/HideUIPanel检查
local Delegate = EnumerateFrames()
while Delegate do
    if Delegate.SetUIPanel and issecurevariable(Delegate, 'SetUIPanel') then
        break
    end
    Delegate = EnumerateFrames(Delegate)
end

local function GetUIPanelAttribute(frame, name)
	if not frame:GetAttribute("UIPanelLayout-defined") then
	    local attributes = UIPanelWindows[frame:GetName()];
	    if not attributes then
			return;
	    end
		SetFrameAttributes(frame, attributes);
	end
	return frame:GetAttribute("UIPanelLayout-"..name);
end

function Addon:HideUIPanel(frame)
    if not frame or not frame:IsShown() then
        return
    end

    if frame.editModeManuallyShown or not GetUIPanelAttribute(frame, "area") then
        frame:Hide()
        return
    end

    Delegate:SetAttribute("panel-frame", frame);
    Delegate:SetAttribute("panel-skipSetPoint", false);
    Delegate:SetAttribute("panel-hide", true);
end