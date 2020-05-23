local L = Narci.L;

local TabNames = { 
    NARCI_INTERFACE, NARCI_SHORTCUTS, NARCI_THEME, NARCI_EFFECTS, NARCI_CAMERA, NARCI_TRANSMOG,
    NARCI_NEW_ENTRY_PREFIX..L["Photo Mode"], L["Corruption System"], NARCI_NEW_ENTRY_PREFIX..L["NPC"], NARCI_NEW_ENTRY_PREFIX..NARCI_EXTENSIONS, 
};  --Credits and About will be inserted later

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
local floor = math.floor;

local CreatureTab;
local Settings, CreatureSettings;

local textLanguage = GetLocale();
if textLanguage == "enGB" then
    textLanguage = "enUS";
end

local function SetLetterboxEffectAlert()
    local selectedRatio = Settings.LetterboxRatio;
    local UIScale = Settings.GlobalScale;
    local recommendedScale;
    UIScale = floor(UIScale*10 + 0.5)/10;
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
    if not (slotTable and Settings) then
        return;
    end

    local Height = tonumber(height) or ItemName_DefaultHeight or 10;
    local font = slotTable[1].Name:GetFont();

    Settings.FontHeightItemName = Height;
    local slot;
    for i=1, #slotTable do
        slot = slotTable[i];
		if slot then
            slot.Name:SetFont(font, Height);
            slot.GradientBackground:SetHeight(slot.Name:GetHeight() + slot.ItemLevel:GetHeight() + 18);
		end
    end
end

--GetBindingText("U", "KEY_")
--command name = GetBindingAction("U")
--GetBindingName(GetBindingAction("U"))
local SetItemNameTextSize = Narci_Pref_SetItemNameTextSize;

local function SetFrameScale(scale)
	local scale = tonumber(scale) or 1;

	Narci_PhotoModeController:SetScale(scale);
	Narci_Character:SetScale(scale);
	Narci_Attribute:SetScale(scale);
    NarciTooltip:SetCustomScale(scale);
	if Settings then
		Settings.GlobalScale = scale;
	end
end

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
        value = floor(value*10 +0.5)/10;
        self.KeyLabel:SetText(string.format("%.1f", value));
        SetFrameScale(value);
        SetLetterboxEffectAlert();
    end
end

function Narci_ModelPanelScaleSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
        self.oldValue = value;
        value = floor(value*10 +0.5)/10;
        self.KeyLabel:SetText(string.format("%.1f", value));
        Narci_ModelSettings:SetScale(value);
        Settings.ModelPanelScale = value;
    end
end

function Narci_SceenshotQualitySlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
        self.oldValue = value;
        value = floor(value*10 +0.5)/10;
        self.KeyLabel:SetText(value);
        if userInput then
            SetCVar("screenshotQuality", value);
        end
    end
end

local function GrainEffectSwitch_SetState(self)
	local state = Settings.EnableGrainEffect;
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
	Settings.EnableGrainEffect = not Settings.EnableGrainEffect;
	GrainEffectSwitch_SetState(self);
end

local function SmoothMusicVolume(state)
    Narci_MusicInOut:Hide()
    Narci_MusicInOut.State = state
    Narci_MusicInOut:Show()
end

local function FadeMusicSwitch_SetState(self)
    local state = Settings.FadeMusic;
	self.Tick:SetShown(state);
end

function Narci_FadeMusicSwitch_OnClick(self)
	Settings.FadeMusic = not Settings.FadeMusic;
	local state = Settings.FadeMusic;
    SmoothMusicVolume(state);
    self.Tick:SetShown(state);
end

local function WeatherSwitch_SetState(self)
	local state = Settings.WeatherEffect;
	self.Tick:SetShown(state);
end

function Narci_WeatherEffectSwitch_OnClick(self)
	Settings.WeatherEffect = not Settings.WeatherEffect;
    WeatherSwitch_SetState(self);
    if Settings.WeatherEffect then
        Narci_SnowEffect(true);
    else
        Narci_SnowEffect(false);
    end
end

local function LetterboxEffectSwitch_SetState(self, key)
	local state = key or Settings.LetterboxEffect;
    self.Tick:SetShown(state);
    if state then
        FadeFrame(Narci_LetterboxRatioSlider, 0.25, "Forced_IN");
    else
        Narci_LetterboxRatioSlider:SetShown(state);
    end
    SetLetterboxEffectAlert();
end

function Narci_LetterboxEffectSwitch_OnClick(self)
    Settings.LetterboxEffect = not Settings.LetterboxEffect;
    local state = Settings.LetterboxEffect;
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
        Settings.LetterboxRatio = effectiveValue;
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
	local state = Settings.CameraOrbit;
    self.Tick:SetShown(state);
    if state then
        self.Description:SetText(NARCI_CAMERA_ORBIT_ENABLED_DESCRIPTION);
    else
        self.Description:SetText(NARCI_CAMERA_ORBIT_DISABLED_DESCRIPTION);
    end
end

function Narci_CameraOrbitSwitch_OnClick(self)
    Settings.CameraOrbit = not Settings.CameraOrbit;
    CameraOrbitSwitch_SetState(self)
    if Settings.CameraOrbit then
        MoveViewRightStart(0.005*180/GetCVar("cameraYawMoveSpeed"));
    else
        MoveViewRightStop();
        MoveViewLeftStop();
    end
end

local function CameraSafeSwitch_SetState(self)
    local state = Settings.CameraSafeMode;
    if IsAddOnLoaded("DynamicCam") then
        state = false;
    end
    Narci.keepActionCam = not state;
    self.Tick:SetShown(state);
end

function Narci_CameraSafeSwitch_OnClick(self)
    Settings.CameraSafeMode = not Settings.CameraSafeMode;
    CameraSafeSwitch_SetState(self);
end

local function UnToggleElvUIAFK()
    local E, L, V, P, G = unpack(ElvUI);
    E.db.general.afk = false;
    --local AFK = E:GetModule('AFK')
    --AFK:Toggle()
end

local function AFKScreenSwitch_SetState(self)
    local state = Settings.AFKScreen;
    self.Tick:SetShown(state);
    if state then
        if IsAddOnLoaded("ElvUI") then
            self.Description:SetText(NARCI_AFK_SCREEN_DESCRIPTION.." "..NARCI_AFK_SCREEN_DESCRIPTION_EXTRA);
            UnToggleElvUIAFK();
        else
            self.Description:SetText(NARCI_AFK_SCREEN_DESCRIPTION);
        end

        FadeFrame(self:GetParent().AutoStand, 0.25, "Forced_IN");
        self:GetParent().Gemma:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -124);
    else
        self.Description:SetText(NARCI_AFK_SCREEN_DESCRIPTION);

        self:GetParent().AutoStand:Hide();
        self:GetParent().Gemma:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -50);
    end
end

function Narci_AFKScreenSwitch_OnClick(self)
    Settings.AFKScreen = not Settings.AFKScreen;
    AFKScreenSwitch_SetState(self);
end

local function AFKAutoStand_SetState(self)
    self.Tick:SetShown(Settings.AFKAutoStand);
end

function Narci_AFKAutoStand_OnClick(self)
    Settings.AFKAutoStand = not Settings.AFKAutoStand;
    AFKAutoStand_SetState(self);
end

local function GemManagerSwitch_SetState(self)
    local state = Settings.GemManager;
    self.Tick:SetShown(state);
end

function Narci_GemManagerSwitch_OnClick(self)
    Settings.GemManager = not Settings.GemManager;
    GemManagerSwitch_SetState(self);
end

local function DressingRoomSwitch_SetState(self)
    local state = Settings.DressingRoom;
    self.Tick:SetShown(state);
end

function Narci_DressingRoomSwitch_OnClick(self)
    Settings.DressingRoom = not Settings.DressingRoom;
    DressingRoomSwitch_SetState(self);
    self.Description:SetText(NARCI_DRESSING_ROOM_DESCRIPTION.."\n"..NARCI_REQUIRE_RELOAD);
end

local function MinimapButtonSwitch_SetState(self)
    local state = Settings.ShowMinimapButton;
    self.Tick:SetShown(state);
    Narci_MinimapButton:SetShown(state);
    if state then
        FadeFrame(self:GetParent().MinimapParentSwitch, 0.25, "Forced_IN");
        FadeFrame(self:GetParent().FadeOutSwitch, 0.25, "Forced_IN");
    else
        self:GetParent().MinimapParentSwitch:SetShown(state);
        self:GetParent().FadeOutSwitch:SetShown(state);
    end
end

function Narci_MinimapButtonSwitch_OnClick(self)
    Settings.ShowMinimapButton = not Settings.ShowMinimapButton;
    MinimapButtonSwitch_SetState(self);
end

function Narci_MinimapButtonSwitch_OnShow(self)
    MinimapButtonSwitch_SetState(self);
end

local function DoubleTapSwitch_SetState(self)
    local state = Settings.EnableDoubleTap;
    self.Tick:SetShown(state);
end

function Narci_DoubleTapSwitch_OnClick(self)
    Settings.EnableDoubleTap = not Settings.EnableDoubleTap;
    DoubleTapSwitch_SetState(self);
end

function Narci_DoubleTapSwitch_OnShow(self)
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
        self.Value:SetText(NOT_BOUND);
        self.Description:SetText(Color_Bad..NARCI_INVALID_KEY);
        self.Highlight:SetColorTexture(Color_Bad_r, Color_Bad_g, Color_Bad_b);
        return false;
    else
        self.key = key;
        local action = GetBindingAction(key);
        if action and action ~= "" and action~=bindAction then
            self.Description:SetText(Color_Alert..NARCI_OVERRIDE.." "..GetBindingName(action).." ?");
            self.Highlight:SetColorTexture(Color_Alert_r, Color_Alert_g, Color_Alert_b);
            return true;
        else
            ClearAllBinding();
            if SetBinding(key, bindAction, 1) then
                self.Description:SetText(Color_Good..KEY_BOUND);
                self.Highlight:SetColorTexture(Color_Good_r, Color_Good_g, Color_Good_b);
                self.ConfirmButton:Hide();
                SaveBindings(1);    --account wide
            else
                self.Description:SetText(Color_Bad..ERROR_CAPS);
                self.Highlight:SetColorTexture(Color_Bad_r, Color_Bad_g, Color_Bad_b);
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
    self:SetScript("OnKeyDown", nil); 
    self:SetScript("OnKeyUp", nil);
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
        ExitKeyBinding(self);
        return;
    end
    local KeyText = CreateKeyChordString(key);
    self.Value:SetText(KeyText);
    self.key = KeyText;
    if not IsKeyPressIgnoredForBinding(key) then
        ExitKeyBinding(self);
    end
end

function Narci_KeybindingButton_OnClick(self, button)
    if BindingAlertTimer then
        BindingAlertTimer:Cancel();
    end
    if button == "RightButton" then
        ClearAllBinding();
        self.Value:SetText(NOT_BOUND);
        self.key = nil;
        self.Description:SetText(Color_Alert.."Hotkey disabled");
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
        self:SetPropagateKeyboardInput(false);
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
    self.Value:SetText(GetBindingKey("CLICK Narci_MinimapButton:LeftButton") or NOT_BOUND);
    self.action = bindAction;
end

local function Narci_Pref_SetItemNameTextWidth(width)
    local slotTable = Narci_Character.slotTable;
    if not (slotTable and Settings) then
        return;
    end

    local Width = tonumber(width) or 200;
    Settings.ItemNameWidth = Width;

    if Width == 200 then
        Width = 1208;
    end
    
    local slot;
    for i=1, #slotTable do
        slot = slotTable[i];
        if slot then
            slot.Name:SetWidth(Width);
            slot.ItemLevel:SetWidth(Width);
            slot.GradientBackground:SetHeight(slot.Name:GetHeight() + slot.ItemLevel:GetHeight() + 18);
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
    
    local slot;
    for i=1, #slotTable do
        slot = slotTable[i];
        if slot then
            slot.Name:SetMaxLines(MaxLines);
            slot.ItemLevel:SetMaxLines(MaxLines);
            slot.Name:SetWidth(slot.Name:GetWidth()+1)
            slot.Name:SetWidth(slot.Name:GetWidth()-1)
            slot.ItemLevel:SetWidth(slot.Name:GetWidth()+1)
            slot.ItemLevel:SetWidth(slot.Name:GetWidth()-1)
            slot.GradientBackground:SetHeight(slot.Name:GetHeight() + slot.ItemLevel:GetHeight() + 18);
        end
    end
end

local function TruncateSwitch_SetState(self)
    local state = Settings.TruncateText;
    Narci_Pref_SetItemNameTextTruncated(state)   
	self.Tick:SetShown(state);
end

function Narci_TruncateSwitch_OnClick(self)
	Settings.TruncateText = not Settings.TruncateText;
	TruncateSwitch_SetState(self)
end

local function ExitConfirmSwitch_SetState(self)
    local state = Settings.UseExitConfirmation;
    if not state then
        if Narci.showExitConfirm then
            Narci.showExitConfirm = false;
        end
    end
	self.Tick:SetShown(state);
end

function Narci_ExitConfirmSwitch_OnClick(self)
    Settings.UseExitConfirmation = not Settings.UseExitConfirmation;
    ExitConfirmSwitch_SetState(self)
end

local function BustShotSwitch_SetState(self)
    local state = Settings.UseBustShot;
    self.Tick:SetShown(state);
    if state then
        self.Preview:SetTexCoord(0, 0.5, 0, 0.75);
    else
        self.Preview:SetTexCoord(0.5, 1, 0, 0.75);
    end
end

function Narci_BustShotSwitch_OnClick(self)
    Settings.UseBustShot = not Settings.UseBustShot;
    BustShotSwitch_SetState(self);
    Narci:InitializeCameraFactors();
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
    local state = Settings.FadeButton;
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
	Settings.FadeButton = not Settings.FadeButton;
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
        if Settings.BorderTheme ~= "Bright" then
            Settings.BorderTheme = "Bright";
        else
            return;
        end
        self:GetParent().Preview:SetTexCoord(0.5, 1, 0, 1);
    elseif id == 2 then
        if Settings.BorderTheme ~= "Dark" then
            Settings.BorderTheme = "Dark";
        else
            return;
        end
        self:GetParent().Preview:SetTexCoord(0, 0.5, 0, 1);
    end
    ShowSelfTick(self);
    Narci_SetActiveBorderTexture();
end

local function SetBorderThemeState()
    local theme = Settings.BorderTheme;
    if theme == "Bright" then
        NarciPref_Themes.Theme1.Tick:Show();
        NarciPref_Themes.Preview:SetTexCoord(0.5, 1, 0, 1);
    elseif theme == "Dark" then
        NarciPref_Themes.Theme2.Tick:Show();
        NarciPref_Themes.Preview:SetTexCoord(0, 0.5, 0, 1);
    end
end

function Narci_TooltipThemeButton_OnClick(self)
    local id = self:GetID();
    if id == 1 then
        if Settings.TooltipTheme ~= "Bright" then
            Settings.TooltipTheme = "Bright";
        else
            return;
        end
        self:GetParent().Tooltip2.Tick:Hide();
        self:GetParent().Preview2:SetTexCoord(0, 1, 0.5, 1);
        NarciTooltip:SetColorTheme(1);
    elseif id == 2 then
        if Settings.TooltipTheme ~= "Dark" then
            Settings.TooltipTheme = "Dark";
        else
            return;
        end
        self:GetParent().Tooltip1.Tick:Hide();
        self:GetParent().Preview2:SetTexCoord(0, 1, 0, 0.5);
        NarciTooltip:SetColorTheme(0);
    end
    self.Tick:Show();
end

local function SetTooltipThemeState()
    local theme = Settings.TooltipTheme;
    if theme == "Bright" then
        NarciPref_Themes.Tooltip1.Tick:Show();
        NarciPref_Themes.Preview2:SetTexCoord(0, 1, 0.5, 1);
        NarciTooltip:SetColorTheme(1);
    elseif theme == "Dark" then
        NarciPref_Themes.Tooltip2.Tick:Show();
        NarciPref_Themes.Preview2:SetTexCoord(0, 1, 0, 0.5);
        NarciTooltip:SetColorTheme(0);
    end
end

local SetVignetteStrength = Narci_Pref_SetVignetteStrength;
function Narci_VignetteStrengthSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
        self.oldValue = value
        self.KeyLabel:SetText(string.format("%.1f", floor(value*10 +0.5)/10))
        Settings.VignetteStrength = value;
        SetVignetteStrength()
    end
end

local function SetFullBodySwitchState(self)
    local state = Settings.ShowFullBody;
    self.Tick:SetShown(state);
    if state then
        self:GetParent().Preview2:SetTexCoord(0, 0.5, 0, 1);
    else
        self:GetParent().Preview2:SetTexCoord(0.5, 1, 0, 1);
    end
end

function Narci_FullBodySwitch_OnClick(self)
    Settings.ShowFullBody = not Settings.ShowFullBody;
    SetFullBodySwitchState(self)
end

local function AlwaysShowModelSwitch_SetState(self)
    local state = Settings.AlwaysShowModel;
    self.Tick:SetShown(state);
    Narci_AlwaysShowModelButton.Tick:SetShown(state);
    Narci_AlwaysShowModelButton.IsOn = state;
end

function Narci_AlwaysShowModelSwitch_OnClick(self)
    Settings.AlwaysShowModel = not Settings.AlwaysShowModel;
    AlwaysShowModelSwitch_SetState(self);
end

function Narci:ShowDetailedIlvlInfo()
    local state = Settings.DetailedIlvlInfo;
	local frame = Narci_IlvlInfoFrame;
	local frame1, frame2 = frame.IlvlButtonLeft, frame.IlvlButtonRight;
	if state then
		frame1.AnimFrame:Hide();
		frame2.AnimFrame:Hide();
		frame1.AnimFrame:Show();
		frame2.AnimFrame:Show();
		frame1:Show();
		frame2:Show();
        FadeFrame(Narci_DetailedStatFrame, 0.5, "IN");
        FadeFrame(Narci_RadarChartFrame, 0.5, "IN");
		FadeFrame(Narci_ConciseStatFrame, 0.5, "OUT");
	else
		frame1.AnimFrame:Hide();
		frame2.AnimFrame:Hide();
		frame1.AnimFrame:Show();
		frame2.AnimFrame:Show();
        FadeFrame(Narci_DetailedStatFrame, 0.5, "OUT");
        FadeFrame(Narci_RadarChartFrame, 0.5, "OUT");
		FadeFrame(Narci_ConciseStatFrame, 0.5, "IN");
	end
end

local function DetailedStatsSwitch_SetState(self)
    local state = Settings.DetailedIlvlInfo;
    self.Tick:SetShown(state);
end

function Narci_DetailedStatsSwitch_OnClick(self)
    Settings.DetailedIlvlInfo = not Settings.DetailedIlvlInfo;
    DetailedStatsSwitch_SetState(self);
    Narci:ShowDetailedIlvlInfo();
end

local function EntranceVisualSwitch_SetState(self)
    local state = Settings.UseEntranceVisual;
    self.Tick:SetShown(state);
    Narci:SetUseEntranceVisual();
end

function Narci_EntranceVisualSwitch_OnClick(self)
    Settings.UseEntranceVisual = not Settings.UseEntranceVisual;
    EntranceVisualSwitch_SetState(self);
end

local function CorruptionBarSwitch_SetState(self)
    local state = Settings.CorruptionBar;
    self.Tick:SetShown(state);
    if state then
        Narci_CorruptionBar:Show();
    else
        Narci_CorruptionBar:Hide();
    end
end

function Narci_CorruptionBarSwitch_OnClick(self)
    Settings.CorruptionBar = not Settings.CorruptionBar;
    CorruptionBarSwitch_SetState(self)
end

local function SetUseEcapeButtonForExit(self)
    local state = Settings.UseEscapeButton;
    if state then
        Narci_PhotoModeController.KeyListener.EscapeKey = "ESCAPE";
    else
        Narci_PhotoModeController.KeyListener.EscapeKey = "HELLOWORLD";
    end
    self.Tick:SetShown(state);
end

function Narci_EscapeSwitch_OnClick(self)
    Settings.UseEscapeButton = not Settings.UseEscapeButton;
    SetUseEcapeButtonForExit(self);
end

local function MinimapButtonParentSwitch_SetState(self)
    local state = Settings.IndependentMinimapButton;
    local MinimapButton = Narci_MinimapButton;
    if state then
        MinimapButton:ClearAllPoints();
        MinimapButton:SetParent(UIParent);
        MinimapButton:SetFrameLevel(60);
        Narci_MinimapButton_OnLoad();
    else
        MinimapButton:SetParent(Minimap);
    end
    self.Tick:SetShown(not state);
end

function Narci_MinimapButtonParentSwitch_OnClick(self)
    Settings.IndependentMinimapButton = not Settings.IndependentMinimapButton;
    MinimapButtonParentSwitch_SetState(self)
end

local function LoadOnDemandSwitch_SetState(self)
    if self:IsEnabled() then
        local state = CreatureSettings.LoadOnDemand;
        if state then
            self.Description:SetText(self.enabledText);
        else
            self.Description:SetText(self.disabledText);
        end
        self.Tick:SetShown(state);
    else
        self.Description:SetText(self.lockedText);
        self.Tick:SetShown(false);
    end
end

function Narci_LoadOnDemandSwitch_OnClick(self)
    CreatureSettings.LoadOnDemand = not CreatureSettings.LoadOnDemand;
    LoadOnDemandSwitch_SetState(self)
end

local function LockDatabaseToggle()
    Narci_LoadOnDemandSwitch:SetEnabled(not ( CreatureSettings.SearchRelatives or CreatureSettings.TranslateName ));
end

local function IsCreatureDatabaseLoaded(needReload, language)
    language = language or "enUS";
    if NarciCreatureInfo and NarciCreatureInfo.isLanguageLoaded[language] then
        return true
    else
        if needReload then
            ReloadNotes:Show();
        end
        return false
    end
end

local function TranslatorSwitch_SetState(self)
    local state = CreatureSettings.TranslateName;
    self.Tick:SetShown(state);

    if state then
        FadeFrame(CreatureTab.OnTooltip, 0.25, "Forced_IN");
        FadeFrame(CreatureTab.OnNamePlate, 0.25, "Forced_IN");
        FadeFrame(CreatureTab.SelectLanguage, 0.25, "Forced_IN");
        self.Description:SetText(self.enabledText);
    else
        CreatureTab.OnTooltip:Hide();
        CreatureTab.OnNamePlate:Hide();
        CreatureTab.SelectLanguage:Hide();
        self.Description:SetText(self.disabledText);
        if NarciCreatureInfo then
            NarciCreatureInfo.ShowNarciUnitFrames(false);
        end
    end

    CreatureTab.Jaina:SetShown(state);
    CreatureTab.Preview:SetShown(state);

    LockDatabaseToggle();
end

local function IsRequiredLangugesLoaded()
    local useNamePlate = CreatureSettings.ShowTranslatedNameOnNamePlate;
    local allLoaded = true;

    if useNamePlate then
        local language = CreatureSettings.NamePlateLanguage;
        allLoaded = IsCreatureDatabaseLoaded(true, language);
    else
        local Languages = CreatureSettings.Languages;
        for language, state in pairs(Languages) do
            if state then
                allLoaded = allLoaded and IsCreatureDatabaseLoaded(true, language);
            end
        end
    end

    return allLoaded
end

function Narci_TranslatorSwitch_OnClick(self)
    CreatureSettings.TranslateName = not CreatureSettings.TranslateName;
    TranslatorSwitch_SetState(self);

    if IsCreatureDatabaseLoaded(CreatureSettings.TranslateName, textLanguage) then
        if not CreatureSettings.TranslateName then
            NarciCreatureInfo.DiasbleTranslator();
        else
            NarciCreatureInfo.UpdateEnabledLanguages();
        end
    end

    IsRequiredLangugesLoaded();
end

function Narci_SelectLanguage_OnClick(self)
    FadeFrame(CreatureTab.LanguageOptions, 0.25, "Forced_IN");
end

local function FindRelativesSwitch_SetState(self)
    local state = CreatureSettings.SearchRelatives;
    self.Tick:SetShown(state);
    self.KeyBinding:SetShown(state);
    LockDatabaseToggle();
end

function Narci_FindRelativesSwitch_OnClick(self)
    CreatureSettings.SearchRelatives = not CreatureSettings.SearchRelatives;
    local state = CreatureSettings.SearchRelatives;
    LockDatabaseToggle();
    self.Tick:SetShown(state);
    if state then
        FadeFrame(self.KeyBinding, 0.25, "Forced_IN");
    else
        self.KeyBinding:Hide();
    end
    if IsCreatureDatabaseLoaded(state, "enUS") then
        NarciCreatureInfo.SetIsCreatureTooltipEnabled();
    end
end

local UpdateLanguageOptionButtons;    --function

local function UpdateSelectedLanguage()
    button = CreatureTab.SelectLanguage;
    local enabledLanguages;
    local numEnabled = 0;

    local useNamePlate = CreatureSettings.ShowTranslatedNameOnNamePlate;
    if useNamePlate then
        enabledLanguages = CreatureSettings.NamePlateLanguage;
        if enabledLanguages then
            numEnabled = 1;
        end
    else
        local Languages = CreatureSettings.Languages;
        local SortedLanguages = {};
        for language, state in pairs(Languages) do
            if state then
                numEnabled = numEnabled + 1;
                tinsert(SortedLanguages, language)
            end
        end
        
        table.sort(SortedLanguages, function(a, b) return a < b end);

        for _, language in pairs(SortedLanguages) do
            if enabledLanguages then
                enabledLanguages = enabledLanguages..", "..language;
            else
                enabledLanguages = language;
            end
        end
    end

    if numEnabled == 0 then
        button.Description:SetText(button.singular);
        enabledLanguages = Color_Bad.. "None";
    elseif numEnabled == 1 then
        button.Description:SetText(button.singular);
    else
        button.Description:SetText(button.plural);
    end

    button.Label:SetText(enabledLanguages);

    
    --Preview
    local Preview = button:GetParent().Preview;
    local relativeTo = button:GetParent().Jaina;
    if useNamePlate then
        Preview:SetTexCoord(0, 0.5, 0.5, 1);
        Preview:SetPoint("CENTER", relativeTo, "CENTER", 4, 94);
    else
        Preview:SetTexCoord(0, 0.5, 0, 0.5);
        Preview:SetPoint("CENTER", relativeTo, "CENTER", 4, -10);
    end
end

local function TranslationPositionButton_SetState()
    local useNamePlate = CreatureSettings.ShowTranslatedNameOnNamePlate;
    CreatureTab.OnTooltip.Tick:SetShown(not useNamePlate);
    CreatureTab.OnNamePlate.Tick:SetShown(useNamePlate);
    CreatureTab.OnNamePlate.OffsetSetting:SetShown(useNamePlate);
end

function Narci_TranslationPositionButton_OnClick(self)
    self:GetParent().OnTooltip.Tick:Hide();
    self:GetParent().OnNamePlate.Tick:Hide();
    self.Tick:Show();

    local id = self:GetID();
    local useNamePlate = (id == 2)
    
    CreatureSettings.ShowTranslatedNameOnNamePlate = useNamePlate;
    if useNamePlate then
        FadeFrame(self.OffsetSetting, 0.25, "Forced_IN");
    else
        self:GetParent().OnNamePlate.OffsetSetting:Hide();
    end


    if IsRequiredLangugesLoaded() then
        NarciCreatureInfo.UpdateEnabledLanguages();
    end

    UpdateSelectedLanguage();
    UpdateLanguageOptionButtons();
end


-------------------------------------------------------------
----------------Preference ScrollBar Animation---------------
-------------------------------------------------------------
local function BuildTabNames()
    --For Ultra Wide Monitor--
    local ScreenRatio, maxOffset;
    local W0, H = WorldFrame:GetSize();
    if (W0 and H) and H ~= 0 and (W0 / H) > (16.01 / 9) then     --No resizing option on 16:9 or lower
        local W = H / 9 * 16;
        maxOffset = floor( (W0 - W)/2 + 0.5);
        tinsert(TabNames, L["Ultra-wide"]);
        ScreenRatio = floor((W0 / H) * 9 + 0.25);
    end
    tinsert(TabNames, L["Credits"]);
    tinsert(TabNames, NARCI_ABOUT);

    return ScreenRatio, maxOffset;
end

--/run local W, H = WorldFrame:GetSize(); print(floor((W / H) * 9 + 0.25)..":9")
local ScreenRatio, MaxOffset = BuildTabNames();
local SmoothScroll_Initialization = NarciAPI_SmoothScroll_Initialization;
local TotalTab = #TabNames;
local TabHeight = 1;
local TotalHeight = 0;
local floor = floor;
local SelectedColorAlpha = 0.6;
local currentTab = 1;
local function UpdateTabBackgroundColor(self)
    --local scrollBar = Narci_Preference.ListScrollFrame.scrollBar;
    --if Narci_Preference.TabButtonFrame
    local buttons = Narci_Preference.TabButtonFrame.buttons;
    local scrollBarValue = self:GetValue();
    local currentValue = TotalTab - (TotalHeight - scrollBarValue)/TabHeight + 1;
    currentTab = floor(currentValue + 0.5)
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

    --Play heart animation for credit list
    if currentTab == (TotalTab - 1) then
        Narci_CreditList.Timer:Play();
    end
end

local function ScrollBar_OnValueChanged(self, value)
    self:GetParent():SetVerticalScroll(value)
    UpdateTabBackgroundColor(self)
end

function Narci_Preference_ScrollFrame_OnLoad(self)
    TabHeight = self:GetHeight();
    TotalHeight = floor(TotalTab * TabHeight + 0.5);
    MaxScroll = floor((TotalTab - 1) * TabHeight + 0.5);
    self.scrollBar:SetMinMaxValues(0, MaxScroll)
    self.scrollBar:SetValueStep(0.001);
    self.buttonHeight = TotalHeight + 2;
    self.scrollBar.buttonHeight = TotalHeight;
    --self.scrollBar:SetValue(0)
    self.range = MaxScroll;

    SmoothScroll_Initialization(self, nil, nil, 1/(TotalTab), 0.2);
    self.scrollBar:SetScript("OnValueChanged", ScrollBar_OnValueChanged);
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
        if i == numButtons then         --About Tab
            button:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", initialOffsetX, -initialOffsetY);
        elseif i == numButtons - 1 then --Credit Tab
            button:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", initialOffsetX, -initialOffsetY + buttonHeight);
            button.HighlightColor:SetColorTexture(0.6666, 0, 0.549);
            button.SelectedColor:SetColorTexture(0.6666, 0, 0.549);
        else                            --Regular Tab
            button:SetPoint(point, buttons[i-1], relativePoint, offsetX, offsetY);
        end
		tinsert(buttons, button);
	end

    self.buttons = buttons;
    buttons[1]:Click();
end

local function LanguageOption_OnClick(self)
    local language = self.keyValue;
    local state;

    if self:GetParent().singleChoice then
        if language == CreatureSettings.NamePlateLanguage then
            CreatureSettings.NamePlateLanguage = nil;
            state = false;
        else
            CreatureSettings.NamePlateLanguage = language;
            state = true;
        end
        UpdateLanguageOptionButtons();
    else
        CreatureSettings.Languages[language] = not CreatureSettings.Languages[language];
        state = CreatureSettings.Languages[language];   
        self.Tick:SetShown(state);
    end

    if IsCreatureDatabaseLoaded(state, language) then
        NarciCreatureInfo.EnableLanguage(language, state);
    end

    UpdateSelectedLanguage();
end

local function CreateLanguageOptions(parent, anchor)
    local MAX_ROW = 6;
    local OFFSET_START = 22.5; --22.5
    local OFFSET_X = 150; --170
    local OFFSET_Y = 16;
    local LANGUAGES = {
        {"enUS", LFG_LIST_LANGUAGE_ENUS},
        {"frFR", LFG_LIST_LANGUAGE_FRFR},
        {"deDE", LFG_LIST_LANGUAGE_DEDE},
        {"itIT", LFG_LIST_LANGUAGE_ITIT},
        {"koKR", LFG_LIST_LANGUAGE_KOKR},
        {"ptBR", LFG_LIST_LANGUAGE_PTBR},
        {"ruRU", LFG_LIST_LANGUAGE_RURU},
        {"esES", ESES},
        {"esMX", ESMX},
        {"zhCN", ZHCN},
        {"zhTW", ZHTW},
    };

    local button;
    local buttons = {};
    local numButton = 0;
    local numRow = 0;
    local numColumn = 0;

    local LanguageOptions = CreateFrame("Frame", "Narci_LanguageOptions", parent, "NarciFrameTemplate");
    parent.LanguageOptions = LanguageOptions;
    
    LanguageOptions:SetHeaderText("Language");
    LanguageOptions:SetRelativeFrameLevel(3);
    LanguageOptions:HideWhenParentIsHidden(true);

    local languageInfo;
    for i = 1, #LANGUAGES do
        button = CreateFrame("Button", nil, LanguageOptions, "NarciCheckButtonTemplate");
        numButton = numButton + 1;
        tinsert(buttons, button);
        if numButton == 1 then
            numRow = numRow + 1;
            numColumn = numColumn + 1;
            button:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", OFFSET_START, -18);
        elseif numButton % MAX_ROW == 1 then
            button:SetPoint("LEFT", buttons[numButton - MAX_ROW], "LEFT", OFFSET_X, 0);
        else
            button:SetPoint("TOP", buttons[numButton - 1], "BOTTOM", 0, - OFFSET_Y);
        end
        
        languageInfo = LANGUAGES[i];
        button.keyValue = languageInfo[1];
        button.Label:SetText(languageInfo[2]);
        button:SetScript("OnClick", LanguageOption_OnClick);

        if languageInfo[1] == textLanguage then
            button.ignore = true;
            button:Disable();
            button.Tick:Show();
            button.Label:SetTextColor(0.42, 0.42, 0.42);
        end
    end

    local width = floor((button.Label:GetRight() - buttons[1]:GetLeft())/0.72 );
    LanguageOptions:SetSizeAndAnchor(width, 200, "TOPLEFT", anchor, "BOTTOMLEFT", 0, 0);
    
    function UpdateLanguageOptionButtons()
        local button;
        if CreatureSettings.ShowTranslatedNameOnNamePlate then
            --Single-choice
            LanguageOptions.singleChoice = true;

            local nameplateLanguage = CreatureSettings.NamePlateLanguage;
            for i = 1, #buttons do
                button = buttons[i];
                if not button.ignore then
                    button.Tick:SetShown( button.keyValue == nameplateLanguage );
                end
            end
        else
            --Multiple-choice
            LanguageOptions.singleChoice = nil;

            for i = 1, #buttons do
                button = buttons[i];
                if not button.ignore then
                    button.Tick:SetShown( CreatureSettings.Languages[button.keyValue] );
                end
            end
        end
    end
end

local function OffsetSetting_OnShow(self)
    self.number = tonumber(CreatureSettings.NamePlateNameOffset);
    self.Value:SetText(self.number);
end

local function OffsetSetting_OnClick(self)
    self.Value:Hide();
    self.Border:SetColorTexture(0.9, 0.9, 0.9);
    local EditBox = self.EditBox;
    EditBox:SetText(self.number);
    EditBox:Show();
    EditBox:HighlightText();
    EditBox:SetFocus();
end

local function OffsetSetting_EditBox_Confirm(self)
    local offset = self:GetNumber();
    self:GetParent().number = offset;
    CreatureSettings.NamePlateNameOffset = offset;
    NarciCreatureInfo.SetNamePlateNameOffset(offset);
    self:ClearFocus();
end

local function OffsetSetting_EditBox_OnHide(self)
    local Parent = self:GetParent();
    Parent.Value:SetText(Parent.number);
    Parent.Value:Show();
    Parent.Border:SetColorTexture(0, 0, 0);
end


function Narci_Preference_OnLoad(self)
    local Tabs = self.ListScrollFrame.scrollChild;
    local tab;

    --Corruption Tab
    local EyeColors = {{245, 127, 32}, {240, 25, 255}, {140, 218, 205}, {64, 155, 208}};
    local function EyeColorButton_OnClick(self)
        NarciAPI_SetEyeballColor(self.ID);
    end

    tab = Tabs.CorruptionTab;
    tab.Cate1:SetText(L["Eye Color"]);
    tab.Cate2:SetText(L["Blizzard UI"]);
    tab.ColorButtons = {};
    local buttons = tab.ColorButtons;
    local button;
    for i = 1, #EyeColors do
        button = CreateFrame("Button", nil, tab, "NarciPreferenceColorButtonTemplate")
        if i == 1 then
            button:SetPoint("LEFT", tab.Cate1, "LEFT", 40, -40);
        else
            button:SetPoint("LEFT", buttons[i - 1], "RIGHT", 9, 0);
        end
        local Color = EyeColors[i];
        button.ID = i;
        button:SetScript("OnClick", EyeColorButton_OnClick);
        button:SetColor(Color[1], Color[2], Color[3]);
        tinsert(buttons, button);
    end

    --Ultra-wide Optimization
    if ScreenRatio then
        local function MoveBaselineSlider_OnLoad(self)
            self:GetParent().Cate1:SetText(L["Ultra-wide Optimization"]);
            self.Label:SetText(L["Baseline Offset"]);
            self.Description:SetText(string.format(L["Ultra-wide Tooltip"], ScreenRatio));
            --print("Max Offset: "..MaxOffset);
            self:SetMinMaxValues(0, MaxOffset);
            self:SetValueStep(MaxOffset);   --Disabled
            NarciAPI_SliderWithSteps_OnLoad(self);
        end

        local function OnValueChanged(self, value)
            self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
            if value ~= self.oldValue then
                self.oldValue = value;
                value = floor(value)
                self.KeyLabel:SetText(value);
                Narci:SetReferenceFrameOffset(value);
                Settings.BaseLineOffset = value;
            end
        end
        MoveBaselineSlider_OnLoad(Narci_MoveBaselineSlider);
        Narci_MoveBaselineSlider:SetScript("OnValueChanged", OnValueChanged)
    else
        Tabs.CreditTab:ClearAllPoints();
        Tabs.CreditTab:SetPoint("TOPLEFT", Tabs.ExtensionTab, "BOTTOMLEFT", 0, 0);
        Tabs.CreditTab:SetPoint("TOPRIGHT", Tabs.ExtensionTab, "BOTTOMRIGHT", 0, 0);
        Tabs.UltraWideSettings:Hide();
    end



    --Creature Database Tab
    CreatureTab = Tabs.CreatureTab;
    tab = CreatureTab;
    tab.Cate1:SetText(L["Database"]);
    tab.Cate2:SetText(L["Creature Tooltip"]);
    tab.LoadOnDemand:SetScript("OnDisable", LoadOnDemandSwitch_SetState);
    tab.LoadOnDemand:SetScript("OnEnable", LoadOnDemandSwitch_SetState);
    local OffsetSetting = tab.OnNamePlate.OffsetSetting;
    OffsetSetting.Label:SetText(L["Y Offset"]);
    OffsetSetting:SetScript("OnShow", OffsetSetting_OnShow);
    OffsetSetting:SetScript("OnClick", OffsetSetting_OnClick);
    local EditBox = OffsetSetting.EditBox;
    EditBox:SetScript("OnHide", OffsetSetting_EditBox_OnHide);
    EditBox:SetScript("OnEnterPressed", OffsetSetting_EditBox_Confirm);
    EditBox:SetScript("OnSpacePressed", OffsetSetting_EditBox_Confirm);

    ReloadNotes = tab.Notes;

    CreateLanguageOptions(tab, tab.Translator);

    --Build Tab Buttons
    BuildTabButtonList(self.TabButtonFrame, "Narci_TapButtonTemplate", TabNames, 0, -12);
end

local ColorTable = Narci_ColorTable;

function Narci_SetTabButtonColorTheme(self)
    --New options get highlighted, so this doesn't fit any more
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
    Settings.DefaultLayout = id;
    if id == 1 then
        self:GetParent().Preview:SetTexCoord(0, 0.4443359375, 0, 0.5);
    elseif id == 2 then
        self:GetParent().Preview:SetTexCoord(0, 0.4443359375, 0.5, 1);
    elseif id == 3 then
        self:GetParent().Preview:SetTexCoord(0.5556640625, 1, 0, 0.5);
    end
    ShowSelfTick(self);
    Settings.DefaultLayout = id;
end

local function InteractiveAreaSlider_OnLoad(self)
    local function OnValueChanged(self, value)
        self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
        if value ~= self.oldValue then
            self.oldValue = value;
            value = floor(value);
            Narci:ShrinkModelHitRect(value);
            Settings.ShrinkArea = value;
            if value > 0 then
                value = -value;
            end
            self.KeyLabel:SetText(value);

            local frame = Narci_ModelInteractiveArea;
            frame.InOut:Stop();
            frame.InOut:Play();
            frame:Show();
        end
    end

    local W = floor( (WorldFrame:GetWidth()) *(1/3 - 1/8) + 0.5);
    self:SetMinMaxValues(0, W);
    self:SetValueStep(W/8);
    self.Label:SetText(L["Interactive Area"]);
    self:SetScript("OnValueChanged", OnValueChanged);
    NarciAPI_SliderWithSteps_OnLoad(self);
    self:SetValue(Settings.ShrinkArea);
    Narci_ModelInteractiveArea:Hide();
end

-----------------
-----Credits-----
-----------------
local function SetCreditList()
   local RawList = {"Adam Stribley", "Elexys", "Ben Ashley", "Valnoressa", "Andrew Phoenix", "Solanya", "Stephen Berry", "Erik Shafer", "Mccr Karl", "Nantangitan", "Blastflight", "Psyloken", "Ellypse", "Victor Torres", "Pierre-Yves Bertolus"};
   local LeftList, MidList, RightList = {}, {}, {};
   local mod = mod;
   local index;
   for i = 1, #RawList do
        index = mod(i, 3);
        if index == 1 then
            tinsert(LeftList, RawList[i]);
        elseif index == 2 then
            tinsert(MidList, RawList[i]);
        else
            tinsert(RightList, RawList[i]);
        end
   end

   local LEFT, MID, RIGHT;
   for i = 1, #LeftList do
        if i == 1 then
            LEFT = LeftList[i];
            if MidList[i] then
                MID = MidList[i];
            end
            if RightList[i] then
                RIGHT = RightList[i];
            end
        else
            LEFT = LEFT.."\n"..LeftList[i];
            if MidList[i] then
                MID =  MID.."\n"..MidList[i];
                if RightList[i] then
                    RIGHT =  RIGHT.."\n"..RightList[i];
                end
            end
        end
   end

   local CreditList = Narci_CreditList;
   CreditList.PatronListLeft:SetText(LEFT);
   CreditList.PatronListMid:SetText(MID);
   CreditList.PatronListRight:SetText(RIGHT);
end

local function Narci_InsertHeart()
    local Pref = Narci_Preference;
    local frame = Pref.LoveContainer;
    if not frame:IsMouseOver() then return; end;

    --Start at cursor position
	local px, py = GetCursorPosition();
    local scale = Pref:GetEffectiveScale();
    px, py = px / scale, py / scale;

    local d = math.max(py - Pref:GetBottom() + 16, 0); --distance
    local depth = math.random(1, 8);
    local scale = 0.25 + 0.25 * depth;
    local size = 32 * scale;
    local alpha = 1.35 - 0.15 * depth;
    local v = 20 + 10 * depth;
    local t= d / v;
    local tex = frame.ReusedTexture;
    if tex then
        --print("Reuse heart "..t);
    else
        tex = frame:CreateTexture(nil, "BACKGROUND", "NarciPinkHeartTemplate");
        --print("Inset a new heart "..t);
    end

    tex.animIn.Translation:SetOffset(0, -d);
    tex.animIn.Translation:SetDuration(t);
    tex:ClearAllPoints();
    tex:SetPoint("CENTER", nil, "BOTTOMLEFT" , px, py);

    tex:SetSize(size, size);
    tex:SetAlpha(alpha);
    tex.animIn:Play();
end

function Narci_CreditList_OnFinished(self)
    if currentTab == (TotalTab - 1) then
        Narci_InsertHeart();
        self:Play();
    end
end

----------------------------------------------------
local function InitializePreference()
    Settings, CreatureSettings = NarcissusDB, NarciCreatureOptions;

    SetBorderThemeState();
    SetTooltipThemeState();
    UpdateLanguageOptionButtons();
    SetFrameScale(Settings.GlobalScale);
    Narci_ModelSettings:SetScale(Settings.ModelPanelScale or 1);
    GrainEffectSwitch_SetState(Narci_GrainEffectSwitch);
    WeatherSwitch_SetState(Narci_WeatherEffectSwitch);
    LetterboxEffectSwitch_SetState(Narci_LetterboxEffectSwitch);
    CameraOrbitSwitch_SetState(Narci_CameraOrbitSwitch);
    CameraSafeSwitch_SetState(Narci_CameraSafeSwitch);
    MinimapButtonSwitch_SetState(Narci_MinimapButtonSwitch);
    DoubleTapSwitch_SetState(Narci_DoubleTapSwitch);
    TruncateSwitch_SetState(Narci_TruncateSwitch);
    DetailedStatsSwitch_SetState(Narci_DetailedStatsSwitch);
    FadeOutSwitch_SetState(Narci_FadeOutSwitch);
    FadeMusicSwitch_SetState(Narci_FadeMusicSwitch);
    SetFullBodySwitchState(Narci_FullBodySwitch);
    AlwaysShowModelSwitch_SetState(Narci_AlwaysShowModelSwitch);
    AFKScreenSwitch_SetState(Narci_AFKScreenSwitch);
    AFKAutoStand_SetState(Narci_AFKAutoStandSwitch);
    GemManagerSwitch_SetState(Narci_GemManagerSwitch);
    DressingRoomSwitch_SetState(Narci_DressingRoomSwitch);
    EntranceVisualSwitch_SetState(Narci_UseEntranceVisualSwitch);
    ExitConfirmSwitch_SetState(Narci_ExitConfirmSwitch);
    BustShotSwitch_SetState(Narci_BustShotSwitch);
    CorruptionBarSwitch_SetState(Narci_CorruptionBarSwitch);
    SetUseEcapeButtonForExit(Narci_EscapeSwitch);
    MinimapButtonParentSwitch_SetState(Narci_MinimapButtonParentSwitch);
    LoadOnDemandSwitch_SetState(Narci_LoadOnDemandSwitch);
    TranslatorSwitch_SetState(Narci_TranslateNameSwitch);
    FindRelativesSwitch_SetState(Narci_FindRelativesSwitch);
    TranslationPositionButton_SetState();
    UpdateSelectedLanguage();
    --CorruptionTooltipToggle_SetState(Narci_CorruptionTooltipSwitch);  --Status set in CorruptionSystem.lua

    Narci_VignetteStrengthSlider:SetValue(Settings.VignetteStrength);
    Narci_GlobalScaleSlider:SetValue(Settings.GlobalScale);
    Narci_ModelPanelScaleSlider:SetValue(Settings.ModelPanelScale);
    Narci_ItemNameSizeSlider:SetValue(Settings.FontHeightItemName);
    Narci_ItemNameWidthSlider:SetValue(Settings.ItemNameWidth);
    Narci_AlwaysShowModelButton.Tick:SetShown(Settings.AlwaysShowModel);

    local value0;
    if Settings.LetterboxRatio == 2 then
        value0 = 0;
    else
        value0 = 1;
    end
    Narci_LetterboxRatioSlider:SetValue(value0);

    _G["Narci_DefalutLayoutButton"..Settings.DefaultLayout]:Click();

    InteractiveAreaSlider_OnLoad(Narci_InteractiveAreaSlider);
    NarciAPI_SetEyeballColor(Settings.EyeColor);

    --Ultra-wide
    Narci_MoveBaselineSlider:SetValue(Settings.BaseLineOffset);
end

local Initialize = CreateFrame("Frame");
Initialize:RegisterEvent("PLAYER_ENTERING_WORLD");
Initialize:SetScript("OnEvent",function(self,event,...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        InitializePreference();
        SetItemNameTextSize(Settings.FontHeightItemName);
        SetCreditList();
    end
end)