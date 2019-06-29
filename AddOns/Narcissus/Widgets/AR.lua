local cos = math.cos;
local sin = math.sin;
local sqrt = math.sqrt;
local floor = math.floor;
local pow = math.pow;

local function CalculateScale(zoom)
    return -0.1486*pow(zoom, 3) + 3.7573*pow(zoom, 2) - 32.864*zoom + 112.36
end

NarciARMixin = {};
function CreateNarciAR(x, y)
	local vector = CreateFromMixins(NarciARMixin);
	vector:OnLoad(x, y);
	return vector;
end

function NarciARMixin:OnLoad(x, y)
    self.x = x;
    self.y = y;
    self.scale = 1;
    self.SetScale = SetScale;
    self.SetPoint = SetPoint;
end

function NarciARMixin:UpdateScale(scale)
    self:SetScale(scale)
    self:SetPoint("CENTER", nil, self.x * scale, self.y * scale);
end

local function UpdateScale(frame, scale)
    if scale <= 0 then return; end
    frame:SetScale(scale)
    frame:SetPoint("CENTER", nil, frame.x * sqrt(scale), frame.y * sqrt(scale));
end

--NarciAR = CreateNarciAR(-50, 50);

local function LoadFrame(frame, x, y)
    if not frame then return; end
    frame.x = x;
    frame.y = y;
end

local initialize = CreateFrame("Frame")
initialize:RegisterEvent("VARIABLES_LOADED");
initialize:SetScript("OnEvent",function(self,event,...)
    LoadFrame(NarciAR, 0, 40);
end)


local ARFrame = CreateFrame("Frame", "NarciAR_UpdateFrame")
ARFrame:Hide()
ARFrame.TimeSinceLastUpdate = 0;
ARFrame.TotalTime = 0;
local ZoomLevel, ScaleLevel;
local function ARFrame_OnUpdate(self, elapsed)
    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
    ZoomLevel = GetCameraZoom()
    ScaleLevel= CalculateScale(ZoomLevel)/20
    UpdateScale(NarciAR, ScaleLevel)
	if self.TimeSinceLastUpdate >= 2 then
		self:Hide();
	end

end

local function ARFrame_OnHide(self)
    self.TimeSinceLastUpdate = 0;
end

ARFrame:SetScript("OnUpdate", ARFrame_OnUpdate)
ARFrame:SetScript("OnHide", ARFrame_OnHide)

hooksecurefunc("CameraZoomIn", function(increment)
    ARFrame.TimeSinceLastUpdate = 0;
    ARFrame:Show();
end)

hooksecurefunc("CameraZoomOut", function(increment)
    ARFrame.TimeSinceLastUpdate = 0;
    ARFrame:Show();
end)

hooksecurefunc("MoveViewInStart", function()
    print("View In")
end)





function NarciAR_MeasurementSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
        self.oldValue = value
        self.KeyLabel:SetText(floor(value*100 + 0.5)/100)
    end
end