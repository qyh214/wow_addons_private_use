local TabNames = { 
    NARCI_INTERFACE, NARCI_SHORTCUTS, NARCI_THEME, NARCI_EFFECTS, NARCI_CAMERA, NARCI_TRANSMOG,
    NARCI_EXTENSIONS, NARCI_ABOUT,
}

local FadeFrame = NarciAPI_FadeFrame;
local Color_Good = "|cff7cc576";     --124 197 118
local Color_Good_r = 124/255;
local Color_Good_g = 197/255;
local Color_Good_b = 118/255;
local Color_Bad = "|cffee3224";      --238 50 36
local Color_Bad_r = 238/255;
local Color_Bad_g = 50/255;
local Color_Bad_b = 36/255;
local Color_Alert = "|cfffced00";    --252 237 0
local Color_Alert_r = 252/255;
local Color_Alert_g = 237/255;
local Color_Alert_b = 0;
local bindAction = "CLICK Narci_MinimapButton:LeftButton";
local OptimizeBorderThickness = NarciAPI_OptimizeBorderThickness;
local Narci_LetterboxAnimation = NarciAPI_LetterboxAnimation;

local function SetLetterboxEffectAlert()
    local selectedRatio = NarcissusDB.LetterboxRatio;
    local UIScale = NarcissusDB.GlobalScale;
    local recommendedScale;
    UIScale = math.floor(UIScale*10 + 0.5)/10;
    if selectedRatio == 2 then
        recommendedScale = 0.8;
    elseif selectedRatio == 2.35 then
        recommendedScale = 0.7;
    else
        recommendedScale = 0.7;
    end

    if UIScale > recommendedScale then
        Narci_LetterboxEffectSwitch_Description:SetText(string.format(NARCI_LETTERBOX_EFFECT_ALERT2, recommendedScale, UIScale));
        Narci_LetterboxEffectSwitch_Description:Show();
    else
        Narci_LetterboxEffectSwitch_Description:Hide();
    end
end

--- Set Item Name Font Height ---
function Narci_Pref_SetItemNameTextSize(height)
    local slotTable = Narci_Character.slotTable;
    if not (slotTable and NarcissusDB) then
        return;
    end

    local Height = tonumber(height) or ItemName_DefaultHeight or 10;
    local font = slotTable[1].Name:GetFont();

    NarcissusDB.FontHeightItemName = Height;	
	for i=1, #slotTable do
		if slotTable[i] then
            slotTable[i].Name:SetFont(font, Height);
            local point, parent, relativePoint, xOfs = slotTable[i].Name:GetPoint();
            slotTable[i].Name:SetPoint(point, parent, relativePoint, xOfs, 13 - Height)
		end
    end
end

--GetBindingText("U", "KEY_")
--command name = GetBindingAction("U")
--GetBindingName(GetBindingAction("U"))
local SetItemNameTextSize = Narci_Pref_SetItemNameTextSize;
local SetFrameScale = Narci_Pref_SetFrameScale;
function Narci_ItemNameSizeSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
        self.oldValue = value
        self.KeyLabel:SetText(value)
        SetItemNameTextSize(value)
    end
end

function Narci_GlobalScaleSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
        self.oldValue = value;
        self.KeyLabel:SetText(string.format("%.1f", math.floor(value*10 +0.5)/10));
        Narci_Pref_SetFrameScale(value);
        SetLetterboxEffectAlert();
    end
end

local function GrainEffectSwitch_SetState(self)
	local state = NarcissusDB.EnableGrainEffect;
	--FullScreenFilterGrain:SetShown(state);
    --FullScreenFilterGrain2:SetShown(state);
    if state then
        FadeFrame(FullScreenFilterGrain, 0.5, "IN");
        FadeFrame(FullScreenFilterGrain2, 0.5, "IN");
    else
		FadeFrame(FullScreenFilterGrain, 0.5, "OUT");
		FadeFrame(FullScreenFilterGrain2, 0.5, "OUT");
    end
	self.Tick:SetShown(state);
end

function Narci_GrainEffectSwitch_OnClick(self)
	NarcissusDB.EnableGrainEffect = not NarcissusDB.EnableGrainEffect;
	GrainEffectSwitch_SetState(self);
end

local function SmoothMusicVolume(state)
    Narci_MusicInOut:Hide()
    Narci_MusicInOut.State = state
    Narci_MusicInOut:Show()
end

local function FadeMusicSwitch_SetState(self)
    local state = NarcissusDB.FadeMusic;
	self.Tick:SetShown(state);
end

function Narci_FadeMusicSwitch_OnClick(self)
	NarcissusDB.FadeMusic = not NarcissusDB.FadeMusic;
	local state = NarcissusDB.FadeMusic;
    SmoothMusicVolume(state);
    self.Tick:SetShown(state);
end

local function WeatherSwitch_SetState(self)
	local state = NarcissusDB.WeatherEffect;
	self.Tick:SetShown(state);
end

function Narci_WeatherEffectSwitch_OnClick(self)
	NarcissusDB.WeatherEffect = not NarcissusDB.WeatherEffect;
    WeatherSwitch_SetState(self);
    if NarcissusDB.WeatherEffect then
        Narci_SnowEffect(true);
    else
        Narci_SnowEffect(false);
    end
end

local function LetterboxEffectSwitch_SetState(self, key)
	local state = key or NarcissusDB.LetterboxEffect;
    self.Tick:SetShown(state);
    Narci_LetterboxRatioSlider:SetShown(state);
    SetLetterboxEffectAlert();
end

function Narci_LetterboxEffectSwitch_OnClick(self)
    NarcissusDB.LetterboxEffect = not NarcissusDB.LetterboxEffect;
    local state = NarcissusDB.LetterboxEffect;
    LetterboxEffectSwitch_SetState(self, state)
    if state then
        Narci_LetterboxAnimation();
    else
        Narci_LetterboxAnimation("OUT");
    end
end

function Narci_LetterboxRatioSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
        local effectiveValue;
        if value == 1 then
            effectiveValue = 2.35;
        elseif value == 0 then
            effectiveValue = 2;
        else
            effectiveValue = 2.35;
        end
        NarcissusDB.LetterboxRatio = effectiveValue;
        self.KeyLabel2:SetText(effectiveValue.." : 1")
        self.oldValue = value
        
        SetLetterboxEffectAlert();
        if not Narci_ScreenMask_Initialize() then
            self.Description:SetText(NARCI_LETTERBOX_EFFECT_ALERT1)
            self.Description:Show();
        end
    end
end

local function CameraOrbitSwitch_SetState(self)
	local state = NarcissusDB.CameraOrbit;
    self.Tick:SetShown(state);
    if state then
        self.Description:SetText(NARCI_CAMERA_ORBIT_ENABLED_DESCRIPTION);
    else
        self.Description:SetText(NARCI_CAMERA_ORBIT_DISABLED_DESCRIPTION);
    end
end

function Narci_CameraOrbitSwitch_OnClick(self)
    NarcissusDB.CameraOrbit = not NarcissusDB.CameraOrbit;
    CameraOrbitSwitch_SetState(self)
    if NarcissusDB.CameraOrbit then
        MoveViewRightStart(0.005*180/GetCVar("cameraYawMoveSpeed"));
    else
        MoveViewRightStop();
        MoveViewLeftStop();
    end
end

local function AFKScreenSwitch_SetState(self)
    local state = NarcissusDB.AFKScreen;
    self.Tick:SetShown(state);
    if state then
        if IsAddOnLoaded("ElvUI") then
            self.Description:SetText(NARCI_AFK_SCREEN_DESCRIPTION.." "..NARCI_AFK_SCREEN_DESCRIPTION_EXTRA);
        else
            self.Description:SetText(NARCI_AFK_SCREEN_DESCRIPTION);
        end
    else
        self.Description:SetText(NARCI_AFK_SCREEN_DESCRIPTION);
    end
end

function Narci_AFKScreenSwitch_OnClick(self)
    NarcissusDB.AFKScreen = not NarcissusDB.AFKScreen;
    AFKScreenSwitch_SetState(self);
end

local function GemManagerSwitch_SetState(self)
    local state = NarcissusDB.GemManager;
    self.Tick:SetShown(state);
end

function Narci_GemManagerSwitch_OnClick(self)
    NarcissusDB.GemManager = not NarcissusDB.GemManager;
    GemManagerSwitch_SetState(self)
end

local function MinimapButtonSwitch_SetState(self)
    local state = NarcissusDB.ShowMinimapButton;
    self.Tick:SetShown(state);
    Narci_MinimapButton:SetShown(state);
end

function Narci_MinimapButtonSwitch_OnClick(self)
    NarcissusDB.ShowMinimapButton = not NarcissusDB.ShowMinimapButton;
    MinimapButtonSwitch_SetState(self);
end

function Narci_MinimapButtonSwitch_OnShow(self)
    OptimizeBorderThickness(self);
    MinimapButtonSwitch_SetState(self);
end

local function DoubleTapSwitch_SetState(self)
    local state = NarcissusDB.EnableDoubleTap;
    self.Tick:SetShown(state);
end

function Narci_DoubleTapSwitch_OnClick(self)
    NarcissusDB.EnableDoubleTap = not NarcissusDB.EnableDoubleTap;
    DoubleTapSwitch_SetState(self);
end

function Narci_DoubleTapSwitch_OnShow(self)
    OptimizeBorderThickness(self)
    local HotKey1, HotKey2 = GetBindingKey("TOGGLECHARACTER0");
    local Text1 = ENABLE.." "..NARCI_DOUBLE_TAP;
    if HotKey1 then
        Text2 = "|cFFFFD100("..HotKey1..")|r";
        if HotKey2 then
            Text2 = Text2 .. "|cffffffff or |cFFFFD100("..HotKey2..")|r";
        end
        Text1 = Text1.." "..Text2;
    else
        Text1 = Text1.." |cff636363("..NOT_APPLICABLE..")";
    end
    self.Label:SetText(Text1);
end

local function ClearAllBinding()
    local key1, key2 = GetBindingKey(bindAction);
    if key1 then
        SetBinding(key1, nil, 1)
    end
    if key2 then
        SetBinding(key2, nil, 1)
    end
    SaveBindings(1);
end

local function ShouldConfirmKey(self)
    local key = self.key;
    if not key then
        return;
    end
    if key == "SHIFT" or key=="ALT" or key=="CTRL" then
        self.key = nil;
        self.Value:SetText(NOT_BOUND)
        self.Description:SetText(Color_Bad..NARCI_INVALID_KEY)
        self.Highlight:SetColorTexture(Color_Bad_r, Color_Bad_g, Color_Bad_b)
        return false;
    else
        self.key = key;
        local action = GetBindingAction(key);
        if action and action ~= "" and action~=bindAction then
            self.Description:SetText(Color_Alert..NARCI_OVERRIDE.." "..GetBindingName(action).." ?")
            self.Highlight:SetColorTexture(Color_Alert_r, Color_Alert_g, Color_Alert_b);
            return true;
        else
            ClearAllBinding();
            if SetBinding(key, bindAction, 1) then
                self.Description:SetText(Color_Good..KEY_BOUND)
                self.Highlight:SetColorTexture(Color_Good_r, Color_Good_g, Color_Good_b)
                self.ConfirmButton:Hide();
                SaveBindings(1);    --account wide
            else
                self.Description:SetText(Color_Bad..ERROR_CAPS)
                self.Highlight:SetColorTexture(Color_Bad_r, Color_Bad_g, Color_Bad_b)                
            end
            return false;
        end
    end
end

local function ResetBindVisual(self)
    self.Border:SetColorTexture(0, 0, 0);
    self.Value:SetTextColor(1, 1, 1);
    self.Value:SetShadowColor(0, 0, 0);
    self.Value:SetShadowOffset(0.6, -0.6);
    self:SetPropagateKeyboardInput(true)
    self:SetScript("OnKeyDown", function()  end); 
    self:SetScript("OnKeyUp", function()  end);
    self.IsOn = false;
end

local BindingAlertTimer;
local function ExitKeyBinding(self)
    C_Timer.After(0.05, function()
        ResetBindVisual(self)
    end)
    local shouldConfirm = ShouldConfirmKey(self);
    UIFrameFadeIn(self.Highlight, 0.2, 0, 1);
    UIFrameFadeIn(self.Description, 0.2, 0, 1);
    
    if not shouldConfirm then
        BindingAlertTimer = C_Timer.NewTimer(4, function()
            UIFrameFadeOut(self.Highlight, 0.5, self.Highlight:GetAlpha(), 0);
            UIFrameFadeOut(self.Description, 0.5, self.Description:GetAlpha(), 0);
            self.Value:SetText(GetBindingKey(bindAction) or NOT_BOUND); 
        end)
    else
        self.ConfirmButton:Show();
        BindingAlertTimer = C_Timer.NewTimer(6, function()
            UIFrameFadeOut(self.Highlight, 0.5, self.Highlight:GetAlpha(), 0);
            UIFrameFadeOut(self.Description, 0.5, self.Description:GetAlpha(), 0);
            self.Value:SetText(GetBindingKey(bindAction) or NOT_BOUND)
            self.ConfirmButton:Hide();
        end)       
    end
end

local function Narci_KeybindingButton_OnKeydown(self, key)
    if key == "ESCAPE" or key == "SPACE" or key == "ENTER"then
        ExitKeyBinding(self)
        return;
    end
    local KeyText = CreateKeyChordString(key);
    self.Value:SetText(KeyText);
    self.key = KeyText;
    if not IsKeyPressIgnoredForBinding(key) then
        ExitKeyBinding(self)
    end
end

function Narci_KeybindingButton_OnClick(self, button)
    if BindingAlertTimer then
        BindingAlertTimer:Cancel()
    end
    if button == "RightButton" then
        ClearAllBinding();
        self.Value:SetText(NOT_BOUND);
        self.key = nil;
        self.Description:SetText(Color_Alert.."Hotkey disabled")
        self.Highlight:SetColorTexture(Color_Alert_r, Color_Alert_g, Color_Alert_b);
        ResetBindVisual(self)
        UIFrameFadeIn(self.Highlight, 0.2, 0, 1);
        UIFrameFadeIn(self.Description, 0.2, 0, 1);

        BindingAlertTimer = C_Timer.NewTimer(2, function()
            UIFrameFadeOut(self.Highlight, 0.5, self.Highlight:GetAlpha(), 0);
            UIFrameFadeOut(self.Description, 0.5, self.Description:GetAlpha(), 0);    
        end)
        return;
    end
    self.IsOn = not self.IsOn;
    if self.IsOn then
        self.Border:SetColorTexture(0.9, 0.9, 0.9);
        self.Value:SetTextColor(0, 0, 0);
        self.Value:SetShadowColor(1, 1, 1);
        self.Value:SetShadowOffset(0.6, -0.6);
        self:SetPropagateKeyboardInput(false)
        self:SetScript("OnKeyDown", Narci_KeybindingButton_OnKeydown);
        self:SetScript("OnKeyUp", function(self)
            ExitKeyBinding(self)
        end);
    else
        ExitKeyBinding(self)
    end
end

function Narci_KeybindingButton_OnShow(self)
    OptimizeBorderThickness(self);
    self.Value:SetText(GetBindingKey(bindAction) or NOT_BOUND);
    self.action = bindAction;
end

local function Narci_Pref_SetItemNameTextWidth(width)
    local slotTable = Narci_Character.slotTable;
    if not (slotTable and NarcissusDB) then
        return;
    end

    local Width = tonumber(width) or 200;
    NarcissusDB.ItemNameWidth = Width;

    if Width == 200 then
        Width = 1208;
    end
    
    for i=1, #slotTable do
        if slotTable[i] then
            slotTable[i].Name:SetWidth(Width);
            slotTable[i].ItemLevel:SetWidth(Width);
        end
    end
end

function Narci_ItemNameWidthSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
        local _, maxValue = self:GetMinMaxValues();
        self.oldValue = value
        if value < maxValue then
            self.KeyLabel:SetText(value)
            Narci_Pref_SetItemNameTextWidth(value)
        else
            self.KeyLabel:SetText(UNLIMITED)
            Narci_Pref_SetItemNameTextWidth(200)
        end
    end
end

local function Narci_Pref_SetItemNameTextTruncated(state)
    local slotTable = Narci_Character.slotTable;
    if (not slotTable) then
        return;
    end

    local State = state or false;
    local MaxLines =2;
    if State then
        MaxLines = 1;
    end
    
    for i=1, #slotTable do
        if slotTable[i] then
            slotTable[i].Name:SetMaxLines(MaxLines);
            slotTable[i].ItemLevel:SetMaxLines(MaxLines);
            slotTable[i].Name:SetWidth(slotTable[i].Name:GetWidth()+1)
            slotTable[i].Name:SetWidth(slotTable[i].Name:GetWidth()-1)
            slotTable[i].ItemLevel:SetWidth(slotTable[i].Name:GetWidth()+1)
            slotTable[i].ItemLevel:SetWidth(slotTable[i].Name:GetWidth()-1)
        end
    end
end

local function TruncateSwitch_SetState(self)
    local state = NarcissusDB.TruncateText;
    Narci_Pref_SetItemNameTextTruncated(state)   
	self.Tick:SetShown(state);
end

function Narci_TruncateSwitch_OnClick(self)
	NarcissusDB.TruncateText = not NarcissusDB.TruncateText;
	TruncateSwitch_SetState(self)
end


local function Narci_Pref_SetTextBackgroundWidth(width)
    local slotTable = Narci_Character.slotTable;
    if not (slotTable and NarcissusDB) then
        return;
    end

    local Width = tonumber(width) or 200;
    NarcissusDB.ItemNameWidth = Width;

    if Width == 200 then
        Width = 0;
    end
    
    for i=1, #slotTable do
        if slotTable[i] then
            slotTable[i].Name:SetWidth(Width);
            slotTable[i].ItemLevel:SetWidth(Width);
        end
    end
end

local function RestoreClickFunc()
    local button = Narci_MinimapButton;
    button:RegisterForClicks("LeftButtonUp","RightButtonUp","MiddleButtonUp");
    button:RegisterForDrag("LeftButton");
    button:SetScript("OnClick", Narci_MinimapButton_OnClick)
    button:SetScript("OnDragStart", function()  Narci_MinimapButton_DraggingFrame:Show();   end)
    button:SetScript("OnDragStop", function()   Narci_MinimapButton_DraggingFrame:Hide();   end)
    button:SetFrameStrata("MEDIUM");
    button:SetFrameLevel(61);
    button:SetMovable(true);
    button:EnableMouse(true);
end

local function FadeOutSwitch_SetState(self)
    local state = NarcissusDB.FadeButton;
    local button = Narci_MinimapButton;
    self.Tick:SetShown(state);
    if state then
        button.EndAlpha = 0.2;
        button:SetAlpha(0.2);
    else
        button.EndAlpha = 1;
        button:SetAlpha(1);
    end
end

function Narci_FadeOutSwitch_OnClick(self)
	NarcissusDB.FadeButton = not NarcissusDB.FadeButton;
	FadeOutSwitch_SetState(self);
end

function Narci_PreferenceButton_OnClick(self)
    local state = not Narci_Preference:IsShown();
    if state then
        FadeFrame(Narci_Preference, 0.2, "IN");
    else
        FadeFrame(Narci_Preference, 0.2, "OUT");
    end
end

local function ShowSelfTick(self)
    local buttons = self:GetParent().buttons
    for i=1, #buttons do
        buttons[i].Tick:Hide();
    end
    self.Tick:Show();
end

function Narci_BorderThemeButton_OnClick(self)
    local id = self:GetID();
    if id == 1 then
        NarcissusDB.BorderTheme = "Bright";
        self:GetParent().Preview:SetTexCoord(0.5, 1, 0, 1)
    elseif id == 2 then
        NarcissusDB.BorderTheme = "Dark";
        self:GetParent().Preview:SetTexCoord(0, 0.5, 0, 1)
    end
    ShowSelfTick(self)
    Narci_SetActiveBorderTexture()
end

local function SetBorderThemeState()
    local theme = NarcissusDB.BorderTheme;
    if theme == "Bright" then
        Narci_BorderThemeButton1.Tick:Show();
        Narci_BorderThemePreview:SetTexCoord(0.5, 1, 0, 1)
    elseif theme == "Dark" then
        Narci_BorderThemeButton2.Tick:Show();
        Narci_BorderThemePreview:SetTexCoord(0, 0.5, 0, 1)
    end
end

local SetVignetteStrength = Narci_Pref_SetVignetteStrength
function Narci_VignetteStrengthSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
        self.oldValue = value
        self.KeyLabel:SetText(string.format("%.1f", math.floor(value*10 +0.5)/10))
        NarcissusDB.VignetteStrength = value;
        SetVignetteStrength()
    end
end

local function SetFullBodySwitchState(self)
    local state = NarcissusDB.ShowFullBody;
    self.Tick:SetShown(state);
    if state then
        self:GetParent().Preview2:SetTexCoord(0, 0.5, 0, 1);
    else
        self:GetParent().Preview2:SetTexCoord(0.5, 1, 0, 1);
    end
end

function Narci_FullBodySwitch_OnClick(self)
    NarcissusDB.ShowFullBody = not NarcissusDB.ShowFullBody;
    SetFullBodySwitchState(self)
end

local function SetAlwaysShowModelSwitchState(self)
    local state = NarcissusDB.AlwaysShowModel;
    self.Tick:SetShown(state);
    Narci_AlwaysShowModelButton.Tick:SetShown(state);
    Narci_AlwaysShowModelButton.IsOn = state;
end

function Narci_AlwaysShowModelSwitch_OnClick(self)
    NarcissusDB.AlwaysShowModel = not NarcissusDB.AlwaysShowModel;
    SetAlwaysShowModelSwitchState(self);
end
----------------------------------------------------
local function InitializePreference()
    SetBorderThemeState();
    SetFrameScale(NarcissusDB.GlobalScale);

    GrainEffectSwitch_SetState(Narci_GrainEffectSwitch);
    WeatherSwitch_SetState(Narci_WeatherEffectSwitch);
    LetterboxEffectSwitch_SetState(Narci_LetterboxEffectSwitch);
    CameraOrbitSwitch_SetState(Narci_CameraOrbitSwitch);
    MinimapButtonSwitch_SetState(Narci_MinimapButtonSwitch);
    DoubleTapSwitch_SetState(Narci_DoubleTapSwitch);
    TruncateSwitch_SetState(Narci_TruncateSwitch);
    FadeOutSwitch_SetState(Narci_FadeOutSwitch);
    FadeMusicSwitch_SetState(Narci_FadeMusicSwitch);
    SetFullBodySwitchState(Narci_FullBodySwitch);
    SetAlwaysShowModelSwitchState(Narci_AlwaysShowModelSwitch);
    AFKScreenSwitch_SetState(Narci_AFKScreenSwitch);
    GemManagerSwitch_SetState(Narci_GemManagerSwitch)

    Narci_VignetteStrengthSlider:SetValue(NarcissusDB.VignetteStrength);
    Narci_GlobalScaleSlider:SetValue(NarcissusDB.GlobalScale);
    Narci_ItemNameSizeSlider:SetValue(NarcissusDB.FontHeightItemName);
    Narci_ItemNameWidthSlider:SetValue(NarcissusDB.ItemNameWidth);
    Narci_AlwaysShowModelButton.Tick:SetShown(NarcissusDB.AlwaysShowModel);

    local value0;
    if NarcissusDB.LetterboxRatio == 2 then
        value0 = 0;
    else
        value0 = 1;
    end
    Narci_LetterboxRatioSlider:SetValue(value0);

    _G["Narci_DefalutLayoutButton"..NarcissusDB.DefaultLayout]:Click();
end

local initialize = CreateFrame("Frame")
initialize:RegisterEvent("VARIABLES_LOADED");
initialize:SetScript("OnEvent",function(self,event,...)
	if event == "VARIABLES_LOADED" then
        SetItemNameTextSize(NarcissusDB.FontHeightItemName)
        InitializePreference();
    end
end)

-------------------------------------------------------------
----------------Preference ScrollBar Animation---------------
-------------------------------------------------------------
local NarciAPI_SmoothScroll_Initialization = NarciAPI_SmoothScroll_Initialization;
local TotalTab = #TabNames;
local TabHeight = 1;
local TotalHeight = 0;
local floor = math.floor;
local SelectedColorAlpha = 0.6;
function Narci_UpdateTabBackgroundColor(self)
    --local scrollBar = Narci_Preference.ListScrollFrame.scrollBar;
    --if Narci_Preference.TabButtonFrame
    local buttons = Narci_Preference.TabButtonFrame.buttons;
    local scrollBarValue = self:GetValue();
    local currentValue = TotalTab - (TotalHeight - scrollBarValue)/TabHeight + 1;
    local currentTab = floor(currentValue + 0.5)
    --print(currentTab);
    if buttons[currentTab] then
        buttons[currentTab].SelectedColor:SetAlpha(SelectedColorAlpha);
    end

    if currentValue >= currentTab then
        if buttons[currentTab + 1] then
            buttons[currentTab + 1].SelectedColor:SetAlpha(2*SelectedColorAlpha*(currentValue - currentTab));
        end
        if buttons[currentTab - 1] then
            buttons[currentTab - 1].SelectedColor:SetAlpha(0);
        end
    elseif currentValue < currentTab then
        if buttons[currentTab - 1] then
            buttons[currentTab - 1].SelectedColor:SetAlpha(2*SelectedColorAlpha*(currentTab - currentValue));
        end
        if buttons[currentTab + 1] then
            buttons[currentTab + 1].SelectedColor:SetAlpha(0);
        end
    end       

end

function Narci_Preference_ScrollFrame_OnLoad(self)
    TabHeight = self:GetHeight();
    TotalHeight = math.floor(TotalTab * TabHeight + 0.5);
    MaxScroll = math.floor((TotalTab-1) * TabHeight + 0.5);
    self.scrollBar:SetMinMaxValues(0, MaxScroll)
    self.scrollBar:SetValueStep(0.001);
    self.buttonHeight = TotalHeight + 2;
    self.scrollBar.buttonHeight = TotalHeight;
    --self.scrollBar:SetValue(0)
    self.range = MaxScroll;

    NarciAPI_SmoothScroll_Initialization(self, nil, nil, 1/(TotalTab), 0.14, 1)
end

local function BuildTabButtonList(self, buttonTemplate, buttonNameTable, initialOffsetX, initialOffsetY, initialPoint, initialRelative, offsetX, offsetY, point, relativePoint)
	local button, buttonHeight, buttons, numButtons;

	local parentName = self:GetName();
	local buttonName = parentName and (parentName .. "Button") or nil;

	initialPoint = initialPoint or "TOPLEFT";
    initialRelative = initialRelative or "TOPLEFT";
    initialOffsetX = initialOffsetX or 0;
    initialOffsetY = initialOffsetY or 0;
	point = point or "TOPLEFT";
	relativePoint = relativePoint or "BOTTOMLEFT";
	offsetX = offsetX or 0;
	offsetY = offsetY or 0;

	if ( self.buttons ) then
		buttons = self.buttons;
		buttonHeight = buttons[1]:GetHeight();
	else
		button = CreateFrame("BUTTON", buttonName and (buttonName .. 1) or nil, self, buttonTemplate);
		buttonHeight = button:GetHeight();
        button:SetPoint(initialPoint, self, initialRelative, initialOffsetX, initialOffsetY);
        button:SetID(0);
        buttons = {}
        button.Name:SetText(buttonNameTable[1])
		tinsert(buttons, button);
	end

	local numButtons = #buttonNameTable;

	for i = 2, numButtons do
		button = CreateFrame("BUTTON", buttonName and (buttonName .. i) or nil, self, buttonTemplate);
        button:SetID(i-1);
        button.Name:SetText(buttonNameTable[i])
        if i == numButtons then
            button:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", initialOffsetX, -initialOffsetY);
        else
            button:SetPoint(point, buttons[i-1], relativePoint, offsetX, offsetY);
        end
		tinsert(buttons, button);
	end

	self.buttons = buttons;
end

function Narci_Preference_OnLoad(self)
    BuildTabButtonList(self, "Narci_TapButtonTemplate", TabNames, 0, -12)
end

local ColorTable = Narci_ColorTable;
function Narci_SetTabButtonColorTheme(self)
    local ColorIndex = Narci_GlobalColorIndex;
	local R, G, B = ColorTable[ColorIndex][1], ColorTable[ColorIndex][2], ColorTable[ColorIndex][3];
	local r, g, b = R/255, G/255 ,B/255;
	self.HighlightColor:SetColorTexture(r, g, b);
	self.SelectedColor:SetColorTexture(r, g, b);
end

function Narci_TapButton_OnClick(self)
    Narci_Preference_ScrollBar:SetValue(self:GetID()*TabHeight)
    local buttons = self:GetParent().buttons;
    for i=1, #buttons do
        buttons[i].SelectedColor:SetAlpha(0);
    end
    self.SelectedColor:SetAlpha(SelectedColorAlpha);
end

function Narci_LayoutButtonButton_OnClick(self)
    local id = self:GetID();
    NarcissusDB.DefaultLayout = id;
    if id == 1 then
        self:GetParent().Preview:SetTexCoord(0, 0.4443359375, 0, 0.5);
    elseif id == 2 then
        self:GetParent().Preview:SetTexCoord(0, 0.4443359375, 0.5, 1);
    elseif id == 3 then
        self:GetParent().Preview:SetTexCoord(0.5556640625, 1, 0, 0.5);
    end
    ShowSelfTick(self);
    NarcissusDB.DefaultLayout = id;
end