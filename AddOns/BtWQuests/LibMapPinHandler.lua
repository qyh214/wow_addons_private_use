-- Map Canvas extention to prevent taint issues, LibMapPinHandler[WorldMapFrame]:AddDataProvider(...)
if LibMapPinHandler then
    return
end

local function CanvasCallback(canvas, callback)
    return function (self, ...)
        return canvas[callback](canvas, ...)
    end
end

local LibMapPinHandlerMixin = {}
-- MapCanvasMixin Has a lot more than we need so we just copy the bits we need instead of the entire mixin
LibMapPinHandlerMixin.OnShow = MapCanvasMixin.OnShow
LibMapPinHandlerMixin.OnHide = MapCanvasMixin.OnHide
LibMapPinHandlerMixin.RefreshAllDataProviders = MapCanvasMixin.RefreshAllDataProviders
LibMapPinHandlerMixin.CallMethodOnPinsAndDataProviders = MapCanvasMixin.CallMethodOnPinsAndDataProviders
LibMapPinHandlerMixin.ReapplyPinFrameLevels = MapCanvasMixin.ReapplyPinFrameLevels
LibMapPinHandlerMixin.SetGlobalPinScale = MapCanvasMixin.SetGlobalPinScale
LibMapPinHandlerMixin.OnMapChanged = MapCanvasMixin.OnMapChanged
LibMapPinHandlerMixin.AddDataProvider = MapCanvasMixin.AddDataProvider
LibMapPinHandlerMixin.SetPinTemplateType = MapCanvasMixin.SetPinTemplateType
LibMapPinHandlerMixin.EnumeratePinsByTemplate = MapCanvasMixin.EnumeratePinsByTemplate
LibMapPinHandlerMixin.RemoveAllPinsByTemplate = MapCanvasMixin.RemoveAllPinsByTemplate
LibMapPinHandlerMixin.EnumerateAllPins = MapCanvasMixin.EnumerateAllPins
LibMapPinHandlerMixin.AcquirePin = MapCanvasMixin.AcquirePin
LibMapPinHandlerMixin.RemovePin = MapCanvasMixin.RemovePin
LibMapPinHandlerMixin.SetPinPosition = MapCanvasMixin.SetPinPosition
LibMapPinHandlerMixin.GetCanvasScale = MapCanvasMixin.GetCanvasScale
LibMapPinHandlerMixin.GetCanvasZoomPercent = MapCanvasMixin.GetCanvasZoomPercent
LibMapPinHandlerMixin.ApplyPinPosition = MapCanvasMixin.ApplyPinPosition
LibMapPinHandlerMixin.GetGlobalPinScale = MapCanvasMixin.GetGlobalPinScale
LibMapPinHandlerMixin.ExecuteOnAllPins = MapCanvasMixin.ExecuteOnAllPins
LibMapPinHandlerMixin.CallMethodOnDataProviders = MapCanvasMixin.CallMethodOnDataProviders
LibMapPinHandlerMixin.GetPinTemplateType = MapCanvasMixin.GetPinTemplateType
LibMapPinHandlerMixin.RegisterPin = MapCanvasMixin.RegisterPin
LibMapPinHandlerMixin.UnregisterPin = MapCanvasMixin.UnregisterPin

function LibMapPinHandlerMixin:OnLoad(ownerMap)
    self.ownerMap = ownerMap
    local base = CallbackRegistryMixin or CallbackRegistryBaseMixin
	base.OnLoad(self)
	self.dataProviders = {};
	self.dataProviderEventsCount = {};
	self.pinPools = {};
    self.pinTemplateTypes = {};
    self.ScrollContainer = ownerMap.ScrollContainer

    hooksecurefunc(ownerMap, "OnShow", CanvasCallback(self, "OnShow"))
    hooksecurefunc(ownerMap, "OnHide", CanvasCallback(self, "OnHide"))
    hooksecurefunc(ownerMap, "RefreshAllDataProviders", CanvasCallback(self, "RefreshAllDataProviders"))
    hooksecurefunc(ownerMap, "CallMethodOnPinsAndDataProviders", CanvasCallback(self, "CallMethodOnPinsAndDataProviders"))
    hooksecurefunc(ownerMap, "ReapplyPinFrameLevels", CanvasCallback(self, "ReapplyPinFrameLevels"))
    hooksecurefunc(ownerMap, "SetGlobalPinScale", CanvasCallback(self, "SetGlobalPinScale"))
    hooksecurefunc(ownerMap, "OnMapChanged", CanvasCallback(self, "OnMapChanged"))
end
function LibMapPinHandlerMixin:GetOwner()
    return self.ownerMap
end
function LibMapPinHandlerMixin:GetCanvas()
	return self:GetOwner():GetCanvas()
end
function LibMapPinHandlerMixin:GetCanvasContainer()
	return self:GetOwner():GetCanvasContainer()
end
function LibMapPinHandlerMixin:GetMapID()
    return self:GetOwner():GetMapID()
end
function LibMapPinHandlerMixin:EvaluateLockReasons()
end
function LibMapPinHandlerMixin:GetPinFrameLevelsManager()
	return self:GetOwner().pinFrameLevelsManager;
end
function LibMapPinHandlerMixin:ProcessGlobalPinMouseActionHandlers(...)
	return self:GetOwner():ProcessGlobalPinMouseActionHandlers(...)
end

local function CreateCanvas(frame)
    local result = CreateFromMixins(LibMapPinHandlerMixin)
    result:OnLoad(frame)
    return result
end

LibMapPinHandler = {}
setmetatable(LibMapPinHandler, {
    __index = function (self, frame)
        if frame and type(frame) == "table" and frame.GetObjectType then
            local result = CreateCanvas(frame)
            rawset(self, frame, result)
            return result
        end
    end,
    __newindex = function ()
    end,
})