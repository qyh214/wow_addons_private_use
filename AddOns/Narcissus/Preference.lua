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
        self.oldValue = value
        self.KeyLabel:SetText(string.format("%.1f", math.floor(value*10 +0.5)/10))
        Narci_Pref_SetFrameScale(value)
    end
end

local function GrainEffectSwitch_SetState(self)
	local state = NarcissusDB.EnableGrainEffect;
	FullScreenFilterGrain:SetShown(state);
	FullScreenFilterGrain2:SetShown(state);
	self.Tick:SetShown(state);
end

function Narci_GrainEffectSwitch_OnClick(self)
	NarcissusDB.EnableGrainEffect = not NarcissusDB.EnableGrainEffect;
	GrainEffectSwitch_SetState(self);
end

local function CameraOrbitSwitch_SetState(self)
	local state = NarcissusDB.CameraOrbit;
    self.Tick:SetShown(state);
end

function Narci_CameraOrbitSwitch_OnClick(self)
    NarcissusDB.CameraOrbit = not NarcissusDB.CameraOrbit;
    CameraOrbitSwitch_SetState(self)
    if NarcissusDB.CameraOrbit then
        MoveViewRightStart(0.006);
    else
        MoveViewRightStop();
        MoveViewLeftStop();
    end
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

local function InitializePreference()
    SetFrameScale(NarcissusDB.GlobalScale);
    Narci_GlobalScaleSlider:SetValue(NarcissusDB.GlobalScale)
    Narci_ItemNameSizeSlider:SetValue(NarcissusDB.FontHeightItemName)
    GrainEffectSwitch_SetState(Narci_GrainEffectSwitch)
    CameraOrbitSwitch_SetState(Narci_CameraOrbitSwitch)
    MinimapButtonSwitch_SetState(Narci_MinimapButtonSwitch)
    DoubleTapSwitch_SetState(Narci_DoubleTapSwitch)
end

local initialize = CreateFrame("Frame")
initialize:RegisterEvent("VARIABLES_LOADED");
initialize:SetScript("OnEvent",function(self,event,...)
    SetItemNameTextSize(NarcissusDB.FontHeightItemName)
    InitializePreference();
end)


function Narci_PreferenceButton_OnClick(self)
    local state = not Narci_Preference:IsShown();
    if state then
        FadeFrame(Narci_Preference, 0.2, "IN");
    else
        FadeFrame(Narci_Preference, 0.2, "OUT");
    end
end