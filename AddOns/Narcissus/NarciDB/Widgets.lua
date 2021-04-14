local FadeFrame = NarciFadeUI.Fade;
local After = C_Timer.After;

--TEMPS prefix: Deleted Later
local TEMPS = {};


local controllers = {};

local function AddControllerToWidget(widget)
    if not widget.controller then
        local controller = CreateFrame("Frame", nil, widget);
        controller:Hide();
        controller.t = 0;
        controller:SetScript("OnHide", function(self)
            self.t = 0;
            --print("Hide Controller");
        end);
        widget.controller = controller;
        tinsert(controllers, controller);
    end
    return widget.controller
end

--------------------------------------------------------------------------------------------------
--Name: Shimmer Button
--Type: Button
--Description: Shimmers slowly. Maintains highlight when mouseovered
--Notes: starting Alpha is always "0"

TEMPS.totalDuration = 0;      
local shimmerStyle = {
    {toAlpha = 0.5, duration = 0.4},    --#1
    {toAlpha = 0.5, duration = 0.25},   --#2
    {toAlpha = 0, duration = 1.5},      --#3
    {toAlpha = 0, duration = 0.35},     --#4
};

--time accumulation
local timeAlpha = {
    --{totalDuration, toAlpha};
};
local TIER_SHIMMER = #shimmerStyle;

for i = 1, #shimmerStyle do
    local cuurentT = TEMPS.totalDuration;
    local duration = shimmerStyle[i].duration;
    local nextT = cuurentT + duration;
    TEMPS.totalDuration = nextT;
    local fromAlpha;
    if i > 1 then
        fromAlpha = shimmerStyle[i - 1].toAlpha;
        if fromAlpha < 0 then
            fromAlpha = 0;
        end
    else
        fromAlpha = 0;
    end
    local toAlpha = shimmerStyle[i].toAlpha;
    if toAlpha < 0 then
        toAlpha = 0;
    end
    local deltaAlpha = (toAlpha - fromAlpha)/duration
    timeAlpha[i] = {cuurentT, nextT, fromAlpha, deltaAlpha};
end
shimmerStyle = nil;

local function UpdateObjectAlphaByTime(object, t)
    local data;
    local tR, fromAlpha, deltaAlpha;
    for i = 1, TIER_SHIMMER do
        data = timeAlpha[i];
        if t >= data[1] and t <= data[2] then
            fromAlpha, deltaAlpha = data[3], data[4];
            tR = t - data[1];
            break;
        end
    end

    if tR then
        object:SetAlpha(fromAlpha + deltaAlpha*tR);
        return true
    else
        object:SetAlpha(0);
        return false
    end
end

NarciUIShimmerButtonMixin = {};

function NarciUIShimmerButtonMixin:Preload()
    local controller = AddControllerToWidget(self);
    controller:SetScript("OnUpdate", function(controller, elapsed)
        if controller.isHolding then
            local toAlpha = controller.toAlpha or 0;
            local alpha;
            if toAlpha == 0 then
                alpha = self.Shimmer:GetAlpha() - 1 * elapsed;
            else
                alpha = self.Shimmer:GetAlpha() + 5 * elapsed;
            end
            if alpha >= 0.8 then
                self.Shimmer:SetAlpha(0.8);
                controller:Hide();
            elseif alpha <= 0 then
                self.Shimmer:SetAlpha(0);
                if controller.pendingReset then
                    controller.pendingReset = nil;
                    controller.isHolding = nil;
                end
            else
                self.Shimmer:SetAlpha(alpha);
            end
        else
            local t = controller.t + elapsed;
            if not UpdateObjectAlphaByTime(self.Shimmer, t) then
                t = 0;
            end
            controller.t = t;
        end
    end);
    self.Shimmer:SetAlpha(0);
    self.Shimmer:Hide();
    self.Preload = nil;
end

function NarciUIShimmerButtonMixin:PlayShimmer()
    self.Shimmer:Show();
    if self.controller.isHolding then
        self.controller.toAlpha = 0;
        self.controller.pendingReset = true;
    end
    self.controller:Show();
end

function NarciUIShimmerButtonMixin:StopShimmer()
    self.Shimmer:Hide();
    self.controller:Hide();
    self.controller.toAlpha = 0;
    self.controller.isHolding = true;
end

function NarciUIShimmerButtonMixin:HoldShimmer()
    self.controller.toAlpha = 0.8;
    self.controller.isHolding = true;
    self.Shimmer:Show();
    self.controller:Show();
end


--------------------------------------------------------------------------------------------------
--Type: Color Picker (HSV)
local ColorPicker;
local RGBRatio2HSV = NarciAPI.RGBRatio2HSV;
local HSV2RGB = NarciAPI.HSV2RGB;


NarciColorPickerSliderMixin = {};

function NarciColorPickerSliderMixin:SetBorderOffset(x)
    self.Left:SetPoint("LEFT", self, "LEFT", x, 0);
    self.Right:SetPoint("RIGHT", self, "RIGHT", -x, 0);
end

function NarciColorPickerSliderMixin:SetButtonSize(w, h)
    self.Left:SetSize(h, h);
    self.Right:SetSize(h, h);
    self.Center:SetHeight(h);
    self:SetSize(w, h);
end

function NarciColorPickerSliderMixin:SetHighlight(state)
    local v;
    if state then
        v = 1;
    else
        v = 0.66;
    end
    for i = 1, #self.borderTextures do
        self.borderTextures[i]:SetVertexColor(v, v, v);
    end
end

function NarciColorPickerSliderMixin:OnEnter()
    if not IsMouseButtonDown() then
        self:SetHighlight(true);
    end
end

function NarciColorPickerSliderMixin:OnLeave()
    if not IsMouseButtonDown() then
        self:SetHighlight(false);
    end
end

function NarciColorPickerSliderMixin:OnMouseUp()
    if not self:IsMouseOver() then
        self:SetHighlight(false);
    end
end

function NarciColorPickerSliderMixin:OnLoad()
    local tex = "Interface\\AddOns\\Narcissus\\Art\\Widgets\\ColorPicker\\UI.tga";
    self.borderTextures = {
        self.Left, self.Center, self.Right, self.ThumbTexture
    };

    for i = 1, #self.borderTextures do
        self.borderTextures[i]:SetTexture(tex);
    end
    self.Marker:SetTexture(tex);
    self.Left:SetTexCoord(0, 0.125, 0, 0.125);
    self.Center:SetTexCoord(0.125, 0.875, 0, 0.125);
    self.Right:SetTexCoord(0.875, 1, 0, 0.125);
    self.ThumbTexture:SetTexCoord(0, 0.0625, 0.875, 1);
    self.Marker:SetTexCoord(0.125, 0.140625, 0.875, 1);
    self:SetHighlight(false);
    self:SetBorderOffset(2);
    self.Marker:SetVertexColor(0.5, 0.5, 0.5);
end


function NarciColorPickerSliderMixin:OnValueChanged(value, isUserInput)
    if value == self.value then
        return
    end
    self.ThumbTexture:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0);
    --self.Marker:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0);

    self.value = value;

    ColorPicker:Update();
end


--Confirm/Cancel New Color

NarciColorPickerActionButtonMixin = {};

function NarciColorPickerActionButtonMixin:OnLoad()
    local tex = "Interface\\AddOns\\Narcissus\\Art\\Widgets\\ColorPicker\\UI.tga";
    self.borderTextures = {
        self.LeftEnd, self.Left, self.Center, self.Right, self.RightEnd
    }
    for i = 1, #self.borderTextures do
        self.borderTextures[i]:SetTexture(tex);
    end
    self.LeftEnd:SetTexCoord(0, 0.125, 0.3750, 0.6250);
    self.Left:SetTexCoord(0.125, 0.25, 0.3750, 0.6250);
    if self.action == "Confirm" then
        self.Center:SetTexCoord(0.505, 0.75, 0.3750, 0.6250);
    else
        self.Center:SetTexCoord(0.75, 1, 0.3750, 0.6250);
    end
    self.Right:SetTexCoord(0.125, 0.25, 0.3750, 0.6250);
    self.RightEnd:SetTexCoord(0.375, 0.5, 0.3750, 0.6250);

    self:SetHighlight(false);
end

function NarciColorPickerActionButtonMixin:SetButtonHeight(height)
    self:SetHeight(height);
    self.Reference:SetHeight(height - 3);
end

function NarciColorPickerActionButtonMixin:SetButtonWidth(width)
    self:SetWidth(width);
    self.Reference:SetWidth(width - 1);
end

function NarciColorPickerActionButtonMixin:SetButtonSize(w, h)
    self.LeftEnd:SetSize(h, 2*h);
    self.RightEnd:SetSize(h, 2*h);
    self.Center:SetSize(2*h, 2*h);
    self.Left:SetHeight(2*h);
    self.Right:SetHeight(2*h);
    self:SetButtonWidth(w);
    self:SetButtonHeight(h);
end

function NarciColorPickerActionButtonMixin:SetHighlight(state)
    local v;
    if state then
        v = 1;
    else
        v = 0.66;
    end
    for i = 1, #self.borderTextures do
        self.borderTextures[i]:SetVertexColor(v, v, v);
    end
end

function NarciColorPickerActionButtonMixin:OnEnter()
    self:SetHighlight(true);
end

function NarciColorPickerActionButtonMixin:OnLeave()
    self:SetHighlight(false);
end

function NarciColorPickerActionButtonMixin:OnMouseUp()
    self.Reference:SetPoint("CENTER", self, "CENTER", 0, 0);
end

function NarciColorPickerActionButtonMixin:OnMouseDown()
    self.Reference:SetPoint("CENTER", self, "CENTER", 0, -1);
end

function NarciColorPickerActionButtonMixin:OnClick()
    ColorPicker[self.action](ColorPicker);
end

function NarciColorPickerActionButtonMixin:SetColor(r, g, b)
    self.Reference:SetColorTexture(r, g, b);
    self.color = {r, g, b};
end

function NarciColorPickerActionButtonMixin:GetColor()
    if self.color then
        return unpack(self.color)
    else
        return 0, 0, 0
    end
end

NarciUIColorPickerMixin = {};

function NarciUIColorPickerMixin:Preload()
    ColorPicker = self;
    self:RegisterForDrag("LeftButton");

    local sliderHeight = 12;
    local sliderWidth = 160;
    local thumbWidth = 6;

    local HueSlider = self.HueSlider;
    local colors = {
        {1, 0, 0},      --Red
        {1, 1, 0},      --Yellow
        {0, 1, 0},      --Green
        {0, 1, 1},      --Cyan
        {0, 0, 1},      --Blue
        {1, 0, 1},      --Pink
        {1, 0, 0},      --Red
    }
    local gt;
    local gradients = {};
    local numBlocks = #colors - 1;
    local blockWidth = (sliderWidth - thumbWidth) / numBlocks;
    for i = 1, numBlocks do
        gt = HueSlider:CreateTexture(nil, "ARTWORK");
        gradients[i] = gt;
        gt:SetSize(blockWidth, sliderHeight);
        if i == 1 then
            gt:SetPoint("LEFT", HueSlider, "LEFT", thumbWidth/2 + blockWidth * (i - 1), 0);
        else
            gt:SetPoint("LEFT", gradients[i - 1], "RIGHT", 0, 0);
        end
        gt:SetColorTexture(1, 1, 1, 1);
        gt:SetGradient("HORIZONTAL", colors[i][1], colors[i][2], colors[i][3],  colors[i+1][1], colors[i+1][2], colors[i+1][3]);
    end
    HueSlider:SetMinMaxValues(0, 360);
    HueSlider:SetValueStep(1);
    HueSlider:SetWidth(sliderWidth);
    HueSlider:SetValue(0);
    HueSlider.value = 0;

    local SatSlider = self.SaturationSlider;
    local gt2 = SatSlider:CreateTexture(nil, "ARTWORK");
    SatSlider.Gradient = gt2;
    gt2:SetSize(sliderWidth - thumbWidth, sliderHeight);
    gt2:SetPoint("LEFT", SatSlider, "LEFT", thumbWidth/2, 0);
    gt2:SetColorTexture(1, 1, 1, 1);
    gt2:SetGradient("HORIZONTAL", 1, 1, 1, 1, 0, 0);
    SatSlider:SetMinMaxValues(0, 100);
    SatSlider:SetValueStep(1);
    SatSlider:SetWidth(sliderWidth);
    SatSlider:SetValue(100);
    SatSlider.value = 100;
    
    local BriSlider = self.BrightnessSlider;
    local gt3 = SatSlider:CreateTexture(nil, "ARTWORK");
    BriSlider.Gradient = gt3;
    gt3:SetSize(sliderWidth - thumbWidth, sliderHeight);
    gt3:SetPoint("LEFT", BriSlider, "LEFT", thumbWidth/2, 0);
    gt3:SetColorTexture(1, 1, 1, 1);
    gt3:SetGradient("HORIZONTAL", 0, 0, 0, 1, 0, 0);
    BriSlider:SetMinMaxValues(0, 100);
    BriSlider:SetValueStep(1);
    BriSlider:SetWidth(sliderWidth);
    BriSlider:SetValue(100);

    local ConfirmButton = self.ConfirmButton;
    local CancelButton = self.CancelButton;
    
    local padding = 4;
    local sliders = {HueSlider, SatSlider, BriSlider};
    for i = 1, #sliders do
        sliders[i]:SetButtonSize(sliderWidth, sliderHeight);
        sliders[i]:SetParent(self.FrameContainer);
    end

    HueSlider:SetPoint("TOP", self, "TOP", 0, -padding);
    SatSlider:SetPoint("TOP", self, "TOP", 0, -2*padding - sliderHeight);
    BriSlider:SetPoint("TOP", self, "TOP", 0, -3*padding - 2*sliderHeight);
    ConfirmButton:SetPoint("TOPRIGHT", self, "TOP", -padding, -5*padding - 3*sliderHeight);
    CancelButton:SetPoint("TOPLEFT", self, "TOP", padding, -5*padding - 3*sliderHeight);
    ConfirmButton:SetButtonSize(sliderWidth/2 - padding - thumbWidth/4, sliderHeight);
    CancelButton:SetButtonSize(sliderWidth/2 - padding - thumbWidth/4, sliderHeight);
    CancelButton:SetColor(0, 0, 0);

    self:SetSize(sliderWidth + 2*padding - 4, 4*sliderHeight + 6*padding + 1);
    self.Preload = nil;

    self:SetRGB(0, 0, 0);
    self:Update();
end

function NarciUIColorPickerMixin:OnLoad()
    self:Preload();
    self:Hide();
end

function NarciUIColorPickerMixin:Update()
    if self.Preload then return end;

    local h, s, v = self:GetHSV();
    local r, g, b = HSV2RGB(h, 1, v);
    self.SaturationSlider.Gradient:SetGradient("HORIZONTAL", v, v, v, r, g, b);
    r, g, b = HSV2RGB(h, s, 1);
    self.BrightnessSlider.Gradient:SetGradient("HORIZONTAL", 0, 0, 0, r, g, b);

    r, g, b = self:GetRGB();
    self.ConfirmButton:SetColor(r, g, b);

    if self.objects then
        for i = 1, #self.objects do
            self.objects[i]:SetVertexColor(r, g, b);
        end
    end
end

function NarciUIColorPickerMixin:SetRGB(r, g, b)
    local h, s, v = RGBRatio2HSV(r, g, b);
    self.HueSlider:SetValue(h);
    self.SaturationSlider:SetValue(100*s);
    self.BrightnessSlider:SetValue(100*v);
    self.ConfirmButton:SetColor(r, g, b);
end

function NarciUIColorPickerMixin:GetHSV()
    return self.HueSlider.value or 0, (self.SaturationSlider.value or 100)/100, (self.BrightnessSlider.value or 100)/100;
end

function NarciUIColorPickerMixin:GetRGB()
    return HSV2RGB(self:GetHSV());
end

function NarciUIColorPickerMixin:OnDragStart()
    self:StartMoving();
end

function NarciUIColorPickerMixin:OnDragStop()
    self:StopMovingOrSizing();
end

function NarciUIColorPickerMixin:FadeButton(buttonIndex)
    self.ConfirmButton:Disable();
    self.CancelButton:Disable();
    FadeFrame(self.FrameContainer, 0.2, 0);
    if buttonIndex == 1 then
        FadeFrame(self.CancelButton, 0.2, 0);
    else
        FadeFrame(self.ConfirmButton, 0.2, 0);
    end
    After(0.5, function()
        FadeFrame(self, 0.25, 0);
    end);

    --After(3, function()
    --    self:ShowPanel();
    --end)
end

function NarciUIColorPickerMixin:Confirm()
    self:FadeButton(1);
    self:Update();
end

function NarciUIColorPickerMixin:Cancel()
    self:FadeButton(2);

    local r, g, b = self.CancelButton:GetColor();
    ColorPicker:SetRGB(r, g, b);
end

function NarciUIColorPickerMixin:ShowPanel()
    self.FrameContainer:Show();
    self.FrameContainer:SetAlpha(1);
    self.ConfirmButton:Show();
    self.ConfirmButton:SetAlpha(1);
    self.CancelButton:Show();
    self.CancelButton:SetAlpha(1);
    self.ConfirmButton:Enable();
    self.CancelButton:Enable();
    self:Show();
    self:SetAlpha(1);
end

function NarciUIColorPickerMixin:SetObject(switch)
    self.objects = switch.objects;
    self:ClearAllPoints();
    self:SetPoint("TOPLEFT", switch, "TOPRIGHT", 8, 0);

    if self.objects and self.objects[1] then
        --self:SetRGB(self.objects[1]:GetVertexColor());
        self.CancelButton:SetColor(self.objects[1]:GetVertexColor());
    end

    self:ShowPanel();
end

--------------------------------------------------------------------------------------------------
--Name: Skewed Rectangular Button
--Notes: Clockwise 10 Degree

local MARGIN_X = 5;
NarciShewedRectButtonMixin = {};

function NarciShewedRectButtonMixin:SetButtonSize(width, height)
    self:SetSize(width, height);
    self.Icon0:SetSize(width, width);
    self.Icon1:SetSize(width, width);
    self.Icon2:SetSize(width, width);
    self.MaskCenter:SetSize(width - 2*MARGIN_X + 2, height);
    self.MaskLeft:SetSize(MARGIN_X, height);
    self.MaskRight:SetSize(MARGIN_X, height);
end

function NarciShewedRectButtonMixin:SetIcon(iconFile)
    local texOffset = 0.05;
    self.Icon0:SetTexCoord(texOffset, 1 - texOffset, texOffset, 1 - texOffset);
    self.Icon1:SetTexCoord(texOffset, 1 - texOffset, texOffset, 1 - texOffset);
    self.Icon2:SetTexCoord(texOffset, 1 - texOffset, texOffset, 1 - texOffset);

    self.Icon0:SetTexture(iconFile);
    self.Icon1:SetTexture(iconFile);
    self.Icon2:SetTexture(iconFile);
end

function NarciShewedRectButtonMixin:SetColorTexture(r, g, b)
    self.Icon0:SetColorTexture(r, g, b);
    self.Icon1:SetColorTexture(r, g, b);
    self.Icon2:SetColorTexture(r, g, b);
end

function NarciShewedRectButtonMixin:ShowAlert()
    self:SetIcon("Interface\\AddOns\\Narcissus\\Art\\NavBar\\AlertMark");
end

function NarciShewedRectButtonMixin:SetHighlight(state)
    if state then
        self.Icon0:SetDesaturation(0);
        self.Icon0:SetVertexColor(1, 1, 1);
        self.Icon1:SetDesaturation(0);
        self.Icon1:SetVertexColor(1, 1, 1);
        self.Icon2:SetDesaturation(0);
        self.Icon2:SetVertexColor(1, 1, 1);
    else
        self.Icon0:SetDesaturation(0.2);
        self.Icon0:SetVertexColor(0.80, 0.80, 0.80);
        self.Icon1:SetDesaturation(0.2);
        self.Icon1:SetVertexColor(0.80, 0.80, 0.80);
        self.Icon2:SetDesaturation(0.2);
        self.Icon2:SetVertexColor(0.80, 0.80, 0.80);
    end
end

function NarciShewedRectButtonMixin:UseFullMask(state, side)
    if state and (not side or side == 1) then
        self.MaskLeft:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Masks\\Full", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
    else
        self.MaskLeft:SetTexture("Interface\\AddOns\\Narcissus\\Art\\SkewdRect\\ShewedRectMask-Left", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
    end

    if state and (not side or side == 2) then
        self.MaskRight:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Masks\\Full", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
    else
        self.MaskRight:SetTexture("Interface\\AddOns\\Narcissus\\Art\\SkewdRect\\ShewedRectMask-Right", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
    end
end


--------------------------------------------------------------------------------------------------
--Name: Progress Timer
--Notes: Timer & Progress Bar
NarciProgressTimerMixin = {};

function NarciProgressTimerMixin:SetOnFinishedFunc(func1, func2)
    self.Fluid.animFill.onFinishedFunc = func1;
    self.Fluid.animFade.onFinishedFunc = func2;
end

function NarciProgressTimerMixin:SetTimer(duration, loopTimer)
    self:StopAnimating();
    local animFill = self.Fluid.animFill;
    animFill.s1:SetDuration(duration);
    if loopTimer then
        self.isLoop = true;
    else
        self.isLoop = false;
    end
    animFill:Play();
end

function NarciProgressTimerMixin:Start()
    self.Fluid.animFill:Play();
    self:Show();
end

function NarciProgressTimerMixin:Stop()
    self:StopAnimating();
    self:Hide();
end

function NarciProgressTimerMixin:Pause()
    if not self.isPaused then
        self.isPaused = true;
        self.Fluid.animFill:Pause();
    end
end

function NarciProgressTimerMixin:Play()
    if self.isPaused then
        self.isPaused = nil;
        if not self.Fluid.animFade:IsPlaying() then
            self.Fluid.animFill:Play();
        end
    end
end

function NarciProgressTimerMixin:SetAlign(widget, offsetY)
    self:ClearAllPoints();
    offsetY = offsetY or 0;
    self:SetPoint("BOTTOMLEFT", widget, "BOTTOMLEFT", 1, offsetY);
    self:SetPoint("BOTTOMRIGHT", widget, "BOTTOMRIGHT", -1, offsetY);
end

function NarciProgressTimerMixin:SetColor(r, g, b)
    self.Fluid:SetColorTexture(r, g, b);
end

--------------------------------------------------------------------------------------------------

wipe(TEMPS);
TEMPS = nil;