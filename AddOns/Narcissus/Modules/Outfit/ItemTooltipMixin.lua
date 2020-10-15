local GetMouseFocus = GetMouseFocus;
local IsMouseButtonDown = IsMouseButtonDown;
local UIFrameFadeIn = UIFrameFadeIn;
local UIFrameFadeOut = UIFrameFadeOut;
local FadeFrame = NarciAPI_FadeFrame;
local max = math.max;
local Clamp = Clamp;
local After = C_Timer.After

----------------------------------------------------------------------
local tooltipAnchor, pointerOffsetX, pointerOffsetY, isHorizontal;
local pendingText, pendingTexture, pendingColor;
local callbackFunc;
local minSize = 48;
local textInset = 18;
local delayDuration = 0.6;
local DefaultDelay = 0.6;
local DefaultPointerOffsetX = -20;
local DefaultPointerOffsetY = 0;
local ICON_SIZE = 40;
local MIN_WIDTH = 160;
local MAX_WIDTH = 280;
local INSET = 6;
local MIN_TEXT_WIDTH = MIN_WIDTH - ICON_SIZE - 2 * INSET;
local MAX_TEXT_WIDTH = MAX_WIDTH - ICON_SIZE - 2 * INSET;
local ColorPreset = {
    [0] = {0.8, 0.8, 0.8},
    [1] = {0.8, 0.8, 0.8},
    [2] = {228/255, 173/255, 36/255},
    [3] = {215/255, 21/255, 3/255},
    ["green"] = {115/255, 196/255, 143/255},
};


----------------------------------------------------------------------
local Timer = CreateFrame("Frame");

Timer:Hide();
Timer.t = 0;

local function FadeInTooltip()
    local tooltip = NarciItemTooltip;
    if not (tooltipAnchor and tooltipAnchor == GetMouseFocus()) then
        tooltip:Hide();
        return
    else
        tooltip:SetAlpha(0);
    end
    callbackFunc(); --Set texts
    --tooltip.Pointer:ClearAllPoints();
    tooltip:ClearAllPoints();
    
    if not tooltip.useCustomScale then
        tooltip:SetScale(tooltipAnchor:GetEffectiveScale());
    end

    local offsetX = pointerOffsetX or DefaultPointerOffsetX;
    local offsetY = pointerOffsetY or DefaultPointerOffsetY;

    tooltip:SetPoint("BOTTOM", tooltipAnchor, "TOP", offsetX, offsetY);
    
    tooltip:AdjustSize();
    After(0, function()
        UIFrameFadeIn(tooltip, 0.12, 0, 1);
    end);
end

local function DelayedEntrance(self, elapsed)
    if IsMouseButtonDown("LeftButton") then
        self:Hide();
        return;
    end

    self.t = self.t + elapsed;
    if self.t >= delayDuration then
        self:Hide();
        FadeInTooltip();
    end
end

Timer:SetScript("OnUpdate", DelayedEntrance);
Timer:SetScript("OnHide", function(self)
    self.t = 0;
end)

local function UpdateTextAndIcon()
    local tooltip = NarciItemTooltip;
    local tex = pendingTexture;
    if tex then
        tooltip.Icon:SetTexture(pendingTexture);
    else
        tooltip.Icon:SetColorTexture(0, 0, 0);
    end
    tooltip.Header:Show();
    tooltip.Text:Show();
    tooltip.Header:SetSize(0, 0);
    tooltip.Header:SetText(pendingText[1]);
    tooltip.Text:SetSize(0, 0);
    tooltip.Text:SetText(pendingText[2]);
    if pendingText[2] then
        tooltip.Header:SetPoint("CENTER", tooltip.Background, "CENTER", 0, 5);
    else
        tooltip.Header:SetPoint("CENTER", tooltip.Background, "CENTER", 0, 0);
    end
    tooltip:SetColorTheme(pendingColor);
end

----------------------------------------------------------------------
NarciItemTooltipMixin =  {};
local TP = NarciItemTooltipMixin;
TP.useCustomScale = true;

function TP:SetColorTheme(index)
    local r, g, b;

    if index == 1 then
        r, g, b = 0.8, 0.8, 0.8;
        self.Collected:Show();
    else
        local colors = ColorPreset[index]
        r, g, b = colors[1], colors[2], colors[3];
        self.Collected:Hide();
    end

    self.Background:SetColorTexture(r, g, b);
    self.Pointer:SetColorTexture(r, g, b);
end

function TP:FadeOut()
    if self:IsShown() then
        FadeFrame(self, 0.2, "OUT");
    end
end

function TP:JustHide()
    self:Hide();
    self:SetAlpha(0);
    Timer:Hide();
end

function TP:NewText(text1, text2, icon, colorIndex, offsetX, offsetY, delay)
    Timer:Hide();
    tooltipAnchor = GetMouseFocus();
    if not tooltipAnchor or tooltipAnchor == WorldFrame or not text1 then return; end;
    pointerOffsetX, pointerOffsetY = offsetX, offsetY;
    delayDuration = delay or DefaultDelay;
    pendingText = {text1, text2};
    pendingTexture = icon;
    pendingColor = colorIndex or 0;
    After(0, function()
        Timer:Show();
        callbackFunc = UpdateTextAndIcon;
    end)
end

function TP:OnSizeChanged(width, height)
    self.Icon:SetWidth(height);
end

function TP:AdjustSize()
    local width, height = self.Header:GetSize();
    local width1, height2 = self.Text:GetSize();
    width = max(width, width1);
    height = max(height, height2);
    local textWidth = Clamp(width, MIN_TEXT_WIDTH, MAX_TEXT_WIDTH);
    self.Header:SetWidth(textWidth);
    self.Text:SetWidth(textWidth);
    local tooltipWidth = Clamp(textWidth + 2*INSET + ICON_SIZE, MIN_WIDTH, MAX_WIDTH);
    self:SetWidth( tooltipWidth );
end

-----------------------------------------
local mod = mod;
local floor = math.floor;
local ceil = math.ceil;

NarciItemTooltipModelMixin = {};

function NarciItemTooltipModelMixin:OnLoad()
    local FRAE_RATE = 40;
    self.t = 0;
    self.frameRate = 1/FRAE_RATE;
    self:SetAnimationData();
end

function NarciItemTooltipModelMixin:OnUpdate(elapsed)
    if self.shouldPlay then
        self.t = self.t + elapsed;
        if self.t >= self.frameRate then
            self.t = 0;
            self.Image:SetTexCoord( self:GetTexCoord() );
        end
    end
end

function NarciItemTooltipModelMixin:Play()
    if self.hasAnimationData then
        self.shouldPlay = true;
    end
end

function NarciItemTooltipModelMixin:PlayNextFrame()
    if self.hasAnimationData then
        print(self.index)
        self.Image:SetTexCoord( self:GetTexCoord() );
    end
end

function NarciItemTooltipModelMixin:Pause()
    self.shouldPlay = nil;
end

function NarciItemTooltipModelMixin:GetTexCoord()
    self.index = self.index + 1;
    if self.index > self.totalFrames then
        self.index = 1;
    end
    local posX = ceil(self.index / self.numY) * self.dX;
    local posY = ((self.index - 1) % self.numY + 1) * self.dY;
    return posX - self.dX, posX, posY - self.dY, posY
end

function NarciItemTooltipModelMixin:SetAnimationData(data)
    data = {
        totalFrames = 45,
        numY = 16,
        width = 512, height = 128, scale = 0.5,
        totalWidth = 2048, totalHeight = 2048,
    };

    self:Pause();
    self.hasAnimationData = nil;
    self.index = 0;
    self:SetSize(data.width * data.scale, data.height * data.scale);
    self.totalFrames = data.totalFrames;
    self.dX = data.width/data.totalWidth;
    self.dY = data.height/data.totalHeight;
    self.numY = data.numY;

    After(0, function()
        self.hasAnimationData = true;
        self:Play();
    end)
end

--[[
/run NarciItemTooltipModel:SetAnimationData()
--]]