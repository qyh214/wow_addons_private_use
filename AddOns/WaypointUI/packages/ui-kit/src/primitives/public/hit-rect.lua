local env = select(2, ...)
local UIKit_Primitives_Frame = env.modules:Import("packages\\ui-kit\\primitives\\frame")
local UIKit_Primitives_HitRect = env.modules:New("packages\\ui-kit\\primitives\\hit-rect")

local Mixin = Mixin
local tinsert = table.insert
local tremove = table.remove


local HitRectMixin = {}

function HitRectMixin:AddOnEnter(callback)
    self.__enterHooks = self.__enterHooks or {}
    tinsert(self.__enterHooks, callback)
end

function HitRectMixin:AddOnLeave(callback)
    self.__leaveHooks = self.__leaveHooks or {}
    tinsert(self.__leaveHooks, callback)
end

function HitRectMixin:AddOnMouseDown(callback)
    self.__mouseDownHooks = self.__mouseDownHooks or {}
    tinsert(self.__mouseDownHooks, callback)
end

function HitRectMixin:AddOnMouseUp(callback)
    self.__mouseUpHooks = self.__mouseUpHooks or {}
    tinsert(self.__mouseUpHooks, callback)
end

function HitRectMixin:RemoveOnEnter(callback)
    if not self.__enterHooks then return end
    for i = #self.__enterHooks, 1, -1 do
        if self.__enterHooks[i] == callback then
            tremove(self.__enterHooks, i)
            break
        end
    end
    if #self.__enterHooks == 0 then self.__enterHooks = nil end
end

function HitRectMixin:RemoveOnLeave(callback)
    if not self.__leaveHooks then return end
    for i = #self.__leaveHooks, 1, -1 do
        if self.__leaveHooks[i] == callback then
            tremove(self.__leaveHooks, i)
            break
        end
    end
    if #self.__leaveHooks == 0 then self.__leaveHooks = nil end
end

function HitRectMixin:RemoveOnMouseDown(callback)
    if not self.__mouseDownHooks then return end
    for i = #self.__mouseDownHooks, 1, -1 do
        if self.__mouseDownHooks[i] == callback then
            tremove(self.__mouseDownHooks, i)
            break
        end
    end
    if #self.__mouseDownHooks == 0 then self.__mouseDownHooks = nil end
end

function HitRectMixin:RemoveOnMouseUp(callback)
    if not self.__mouseUpHooks then return end
    for i = #self.__mouseUpHooks, 1, -1 do
        if self.__mouseUpHooks[i] == callback then
            tremove(self.__mouseUpHooks, i)
            break
        end
    end
    if #self.__mouseUpHooks == 0 then self.__mouseUpHooks = nil end
end

local function ProcessCallback(var, ...)
    if not var then return end
    for i = 1, #var do
        var[i](...)
    end
end

local function HandleEnter(self)
    ProcessCallback(self.__enterHooks)
end

local function HandleLeave(self)
    ProcessCallback(self.__leaveHooks)
end

local function HandleMouseDown(self, button)
    ProcessCallback(self.__mouseDownHooks, button)
end

local function HandleMouseUp(self, button)
    ProcessCallback(self.__mouseUpHooks, button)
end

function UIKit_Primitives_HitRect.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(frame, HitRectMixin)
    frame:EnableMouse(true)
    frame:AwaitSetPropagateMouseClicks(true)
    frame:AwaitSetPropagateMouseMotion(true)

    frame:SetScript("OnEnter", HandleEnter)
    frame:SetScript("OnLeave", HandleLeave)
    frame:SetScript("OnMouseDown", HandleMouseDown)
    frame:SetScript("OnMouseUp", HandleMouseUp)

    return frame
end
