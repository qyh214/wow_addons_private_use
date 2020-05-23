
NarciTooltipMixin = {};

local TP = NarciTooltipMixin;
local GetMouseFocus = GetMouseFocus;
local IsMouseButtonDown = IsMouseButtonDown;
local UIFrameFadeIn = UIFrameFadeIn;
local UIFrameFadeOut = UIFrameFadeOut;
local FadeFrame = NarciAPI_FadeFrame;
local max = math.max;
local sin = math.sin;
local pi = math.pi;
local After = C_Timer.After
-----------------------------------
local tooltipAnchor, pointerOffsetX, pointerOffsetY, isHorizontal;
local pendingText, pendingTexture;
local callbackFunc;
local minSize = 48;
local textInset = 18;
local animDuration = 0.4;
local delayDuration = 0.6;
local DefaultDelay = 0.6;
local DefaultPointerOffset = -8;
local fixedWidth = 270;
-----------------------------------

-------------LibEasing-------------
local function outSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end
-----------------------------------

local PATH_PREFIX = "Interface/AddOns/Narcissus/Guide/IMG/";
local Images = {
    [1] =  PATH_PREFIX .. "HideTexts",
    [2] =  PATH_PREFIX .. "TopQuality",
    [3] =  PATH_PREFIX .. "GroundShadow",
    [4] =  PATH_PREFIX .. "HidePlayer",
    [5] =  PATH_PREFIX .. "CompactMode",
    [6] =  PATH_PREFIX .. "SaveLayers",
    [7] =  PATH_PREFIX .. "LightSwitch",
}


-----------------------------------
local Timer = CreateFrame("Frame");

Timer:Hide();
Timer.TimeSinceLastUpdate = 0;

local function FadeInTooltip()
    local tooltip = NarciTooltip;
    tooltip:Hide();
    
    if not (tooltipAnchor and tooltipAnchor == GetMouseFocus()) then return; end;
    callbackFunc(); --Set texts
    tooltip.Pointer:ClearAllPoints();
    tooltip:ClearAllPoints();
    
    if not tooltip.UseCustomScale then
        tooltip:SetScale(tooltipAnchor:GetEffectiveScale());
    end

    local offsetX = pointerOffsetX or 0;
    local offsetY = pointerOffsetY or DefaultPointerOffset;

    if isHorizontal then
        tooltip:SetPoint("RIGHT", tooltipAnchor, "LEFT", offsetX, offsetY);
        tooltip.Pointer2:SetPoint("CENTER", tooltipAnchor, "LEFT", offsetX - 12);
        tooltip.Pointer2:Show();
        tooltip.Pointer:Hide();
    else
        tooltip:SetPoint("BOTTOM", tooltipAnchor, "TOP", offsetX, offsetY);
        tooltip.Pointer:SetPoint("CENTER", tooltipAnchor, "TOP", offsetX, offsetY + 12);
        tooltip.Pointer:Show();
        tooltip.Pointer2:Hide();
    end
    
    After(0, function()
        UIFrameFadeIn(tooltip, 0.12, 0, 1);
    end);
end

local function DelayedEntrance(self, elapsed)
    if IsMouseButtonDown("LeftButton") then
        self:Hide();
        return;
    end

    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if self.TimeSinceLastUpdate >= delayDuration then
        self:Hide();
        FadeInTooltip();
    end
end

Timer:SetScript("OnUpdate", DelayedEntrance);
Timer:SetScript("OnHide", function(self)
    self.TimeSinceLastUpdate = 0;
end)

local function SetSingleLine()
    local tooltip = NarciTooltip;
    tooltip.IsSignleLine = true;
    local tex = pendingTexture;
    tooltip.Icon:Hide();
    local TextObject = tooltip.Text0;
    TextObject:SetSize(0, 0);
    TextObject:Show();
    TextObject:SetText(pendingText);
    tooltip.Guide:SetAlpha(0);
end

local function SetMultiLines()
    local tooltip = NarciTooltip;
    tooltip.IsSignleLine = false;
    local tex = pendingTexture;
    tooltip.Icon:SetTexture(tex[1]);
    tooltip.Icon:SetTexCoord(tex[2], tex[3], tex[4], tex[5], tex[6], tex[7], tex[8], tex[9]);
    tooltip.Icon:Show();
    tooltip.Header:Show();
    tooltip.Text1:Show();
    tooltip.Header:SetText(pendingText[1]);
    tooltip.Text1:SetText(pendingText[2]);
    local index = tooltip.GuideIndex;
    if index then
        if Images[index] then
            tooltip.Guide.Picture:SetTexture(Images[index]);
            tooltip.Guide:SetAlpha(1);
        else
            tooltip.Guide:SetAlpha(0);
        end
    else
        tooltip.Guide:SetAlpha(0);
    end
end

local function GetIconFile(anchorFrame)
    local texureObject = anchorFrame.icon or anchorFrame.Icon;
    local texs = {};
    if texureObject then
        local texFile = texureObject:GetTexture();
        local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = texureObject:GetTexCoord();
        texs = {texFile, ULx, ULy, LLx, LLy, URx, URy, LRx, LRy};
    else
        texs = {nil, 0, 0, 0, 0, 0, 0, 0, 0};
    end
    return texs;
end

-----------------------------------
function TP:OnHide()
    Timer:Hide();
    self:ClearAllPoints();
    self.Pointer:ClearAllPoints();
    self:Hide();
    self:SetAlpha(0);
    self.Text0:Hide();
    self.Header:Hide();
    self.Text1:Hide();
    self.Icon:Hide();
end

function TP:OnLoad()
    self.IsSignleLine = true;
    self.Scale = 1;
end

function TP:OnSizeChanged(width, height)
    self:SetSize(max(minSize, width), max(minSize, height));
    local insetHeight = self.inset:GetHeight();
    self.Icon:SetSize(insetHeight, insetHeight);
end

function TP:OnShow()
    if self.IsSignleLine then
        local textWidth, textHeight = self.Text0:GetSize();
        self:SetSize(textWidth + 2*textInset, textHeight + 2*textInset);
    else
        self:SetWidth(fixedWidth);
        self.Guide:SetHeight(fixedWidth / 2 + 12);
        local height = (self.Header:GetHeight() + self.Text1:GetHeight() + 2 * (textInset - 6) + 24 + 4 + 1);
        self:SetHeight(height);
    end
end

function TP:FadeOut()
    if self:IsShown() then
        UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0);
    end
end

function TP:JustHide()
    self:Hide();
    self:SetAlpha(0);
    Timer:Hide();
end

function TP:NewText(texts, offsetX, offsetY, delay, horizontal)
    Timer:Hide();
    --UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0);
    tooltipAnchor = GetMouseFocus();
    if not tooltipAnchor or tooltipAnchor == WorldFrame or not texts then return; end;
    pointerOffsetX, pointerOffsetY = offsetX, offsetY;
    delayDuration = delay or DefaultDelay;
    isHorizontal = horizontal;
    pendingText = texts;
    pendingTexture = GetIconFile(tooltipAnchor);
    self.GuideIndex = tooltipAnchor.GuideIndex;
    After(0, function()
        Timer:Show();
        if type(texts) == "string" then
            callbackFunc = SetSingleLine;
        elseif type(texts) == "table" then
            callbackFunc = SetMultiLines;
        end
    end)
end

function TP:ShowTooltip(frame, offsetX, offsetY, delay)
    self:NewText(frame.tooltip, offsetX, offsetY, delay);
end

function TP:SetColorTheme(index)
    local minG, maxG;

    if index and index ==  1 then
        --Bright
        minG, maxG = 0.82, 1.0;
        self.Pointer:SetTexCoord(0, 0.5, 0, 1);
        self.Pointer2:SetTexCoord(0, 1, 0, 0.5);
        self.Text0:SetTextColor(0, 0, 0);
        self.Text0:SetShadowColor(1, 1, 1, 0);
        self.Text1:SetTextColor(0, 0, 0);
        self.Text1:SetShadowColor(1, 1, 1, 0);
        self.Header:SetTextColor(0, 0, 0);
        self.Header:SetShadowColor(1, 1, 1, 0);
        self.Icon:SetAlpha(0.2);
    else
        --Dark
        minG, maxG = 0.05, 0.12;
        self.Pointer:SetTexCoord(0.5, 1, 0, 1);
        self.Pointer2:SetTexCoord(0, 1, 0.5, 1);
        self.Text0:SetTextColor(1, 1, 1);
        self.Text0:SetShadowColor(0, 0, 0, 0);
        self.Text1:SetTextColor(1, 1, 1);
        self.Text1:SetShadowColor(0, 0, 0, 1);
        self.Header:SetTextColor(0.25, 0.78, 0.92);
        self.Header:SetShadowColor(0, 0, 0);
        self.Icon:SetAlpha(0.1);
    end

    self.Gradient:SetGradient("VERTICAL", minG, minG, minG, maxG, maxG, maxG);
end

function TP:SetCustomScale(scale)
    if scale then
        --set scale manually
        self.UseCustomScale = true;
        self:SetScale(scale);
    else
        --use anchor frame's scale
        self.UseCustomScale = false;
    end
end


--[[
/run NarciTooltip:SetColorTheme(2);NarciTooltip:NewText({NARCI_DRESSING_ROOM, NARCI_DRESSING_ROOM_DESCRIPTION})
/run NarciTooltip:SetSize(160,140)
--]]