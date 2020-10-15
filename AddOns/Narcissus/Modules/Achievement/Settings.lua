local BIND_ACTION = "CLICK Narci_Achievement_MinimapButton:LeftButton";
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


local AchievementDB;

local widgetObjects = {};
local function ShowOrHideWidgetGroup(parentIndex, widgetIndex, visible)
    if widgetObjects[parentIndex] and widgetObjects[parentIndex][widgetIndex] then
        local widgetGroup = widgetObjects[parentIndex][widgetIndex];
        for i = 1, #widgetGroup do
            widgetGroup[i]:SetShown(visible);
        end
    end
end

local REDIRECT_TOOLTIP = "Click tracked achievements or\nachievement alerts to open this panel.";

local WidgetStructure = {
    [1] = {
        name = "Narcissus Achievement (BETA)",
        widgets = {

            [1] = {
                name = "UI Scale",
                type = "slider",
                key = "Scale",
                data = { minValue = 1, maxValue = 1.25, step = 0.05, default = 1, decimal = 0.01,
                    func = function(value) Narci_AchievementFrame:SetScale(value); AchievementDB.Scale = value; end,
                },
            },

            [2] = {
                name = "Theme",
                type = "radio",
                key = "Theme",
                data = {
                    default = 1,
                    [1] = {name = "Dark Wood", func = function(self) NarciAchievement_SelectTheme(1) self:UpdateVisual() end, groupIndx = 1, },
                    [2] = {name = "Classic", func = function(self) NarciAchievement_SelectTheme(2) self:UpdateVisual() end, groupIndx = 1, },
                    [3] = {name = "Flat", func = function(self) NarciAchievement_SelectTheme(3) self:UpdateVisual() end, groupIndx = 1, },
                },
            },

            [3] = {
                name = "Hotkey",
                type = "keybind",
                data = {
                    
                },
            },
        },
    },

    [2] = {
        name = "Blizzard UI",
        widgets = {
            [1] = {
                name = REDIRECT_TOOLTIP,
                type= "checkbox",
                key="UsedAsPrimary",
                data = {
                    default = true,
                    func = function(self)
                        AchievementDB.UsedAsPrimary = not AchievementDB.UsedAsPrimary;
                        local state = AchievementDB.UsedAsPrimary;
                        self.Tick:SetShown(state);
                        NarciAchievement_RedirectPrimaryAchievementFrame();
                        if state then
                            self.Label:SetText(REDIRECT_TOOLTIP);
                        else
                            self.Label:SetText(REDIRECT_TOOLTIP .."\n".. NARCI_REQUIRE_RELOAD);
                        end
                    end,

                    --[[
                    onShowFunc = function(self)
                        local state = self.Tick:IsShown();
                        ShowOrHideWidgetGroup(2, 2, state);
                    end
                    --]]
                },
            },
        },
    },
}



local function ClearAllBinding()
    local key1, key2 = GetBindingKey(BIND_ACTION);
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
        if action and action ~= "" and action ~= BIND_ACTION then
            self.Description:SetText(Color_Alert..NARCI_OVERRIDE.." "..GetBindingName(action).." ?");
            self.Highlight:SetColorTexture(Color_Alert_r, Color_Alert_g, Color_Alert_b);
            return true;
        else
            ClearAllBinding();
            if SetBinding(key, BIND_ACTION, 1) then
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
            self.Value:SetText(GetBindingKey(BIND_ACTION) or NOT_BOUND); 
        end)
    else
        self.ConfirmButton:Show();
        BindingAlertTimer = C_Timer.NewTimer(6, function()
            UIFrameFadeOut(self.Highlight, 0.5, self.Highlight:GetAlpha(), 0);
            UIFrameFadeOut(self.Description, 0.5, self.Description:GetAlpha(), 0);
            self.Value:SetText(GetBindingKey(BIND_ACTION) or NOT_BOUND)
            self.ConfirmButton:Hide();
        end)       
    end
end

local function KeybindingButton_OnKeydown(self, key)
    if key == "ESCAPE" or key == "SPACE" or key == "ENTER"then
        ExitKeyBinding(self);
        return;
    end

    local KeyText;
    if CreateKeyChordStringUsingMetaKeyState then   --Shadowlands
        KeyText = CreateKeyChordStringUsingMetaKeyState(key);
    else
        KeyText = CreateKeyChordString(key);
    end

    self.Value:SetText(KeyText);
    self.key = KeyText;
    if not IsKeyPressIgnoredForBinding(key) then
        ExitKeyBinding(self);
    end
end

local function KeybindingButton_OnClick(self, button)
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
        self:SetScript("OnKeyDown", KeybindingButton_OnKeydown);
        self:SetScript("OnKeyUp", function(self)
            ExitKeyBinding(self)
        end);
    else
        ExitKeyBinding(self)
    end
end

local function KeybindingButton_OnShow(self)
    self.Value:SetText(GetBindingKey(BIND_ACTION) or NOT_BOUND);
    self.action = BIND_ACTION;
end


local function CreateWidget(parent, widgetData, offset, parentIndex, widgetIndex)
    if parentIndex and widgetIndex then
        if not widgetObjects[parentIndex] then
            widgetObjects[parentIndex] = {};
        end
        if not widgetObjects[parentIndex][widgetIndex] then
            widgetObjects[parentIndex][widgetIndex] = {};
        end
    end
    local widgetGroup = widgetObjects[parentIndex][widgetIndex];

    local type = widgetData.type;
    local data = widgetData.data;
    local element;
    local height;

    if type == "slider" then
        element = CreateFrame("Slider", nil, parent, "NarciLineSliderTemplate");
        tinsert(widgetGroup, element);
        if data.minValue and data.maxValue then
            element:SetMinMaxValues(data.minValue, data.maxValue);
            element:SetObeyStepOnDrag(true);
            element:SetValueStep(data.step);
            NarciAPI_SliderWithSteps_OnLoad(element);
            element.func = data.func;
            element.decimal = data.decimal;

            local defaultValue = AchievementDB[widgetData.key] or data.default;
            element:SetValue(defaultValue);
            element.Label:SetText(widgetData.name);
        end
        element:SetPoint("TOPLEFT", parent, "TOPLEFT", 80, offset);
        height = 30;

    elseif type == "radio" then
        local info;
        local elements = {};
        local numButtons = #data;
        local header = parent:CreateFontString(nil, "OVERLAY", "NarciPrefFontCategory");
        tinsert(widgetGroup, header);
        header:SetText(widgetData.name);
        header:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, offset);
        local defaultValue = AchievementDB[widgetData.key] or data.default;

        for i = 1, numButtons do
            info = data[i];
            element = CreateFrame("Button", nil, parent, "NarciRadioButtonTemplate");
            tinsert(widgetGroup, element);
            tinsert(elements, element);
            element:Initialize(info.groupIndx, info.name);
            element:SetScript("OnClick", info.func);
            if i == 1 then
                element:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, offset -20);
            else
                element:SetPoint("TOPLEFT", elements[i - 1], "BOTTOMLEFT", 0, -4);
                if i == numButtons then
                    element:UpdateGroupHitBox();
                end
            end
            if i == defaultValue then
                element:Select();
            end
        end
        
        height = numButtons * 24 + (numButtons - 1) * 4 + 24;

    elseif type == "checkbox" then
        element = CreateFrame("Button", nil, parent, "NarciCheckBoxTemplate");
        tinsert(widgetGroup, element);
        element:SetScript("OnClick", data.func);
        element:SetScript("OnShow", data.onShowFunc);
        element.Label:SetText(widgetData.name);
        element:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, offset);

        local defaultValue = AchievementDB[widgetData.key];
        element.Tick:SetShown(defaultValue);
        element.IsOn = defaultValue;

        height = 30;

    elseif type == "keybind" then
        element = CreateFrame("Button", nil, parent, "NarciBindingButtonTemplate");
        tinsert(widgetGroup, element);
        element:SetSize(78, 18);
        element.Label:SetText(widgetData.name);
        element:SetPoint("TOPLEFT", parent, "TOPLEFT", 80, offset);
        height = 24;

        element:SetScript("OnClick", KeybindingButton_OnClick);
        element:SetScript("OnShow", KeybindingButton_OnShow);
    end

    return -height
end


local function CreateSettings(frame)
    local sectors = {};
    local sector;
    local widgets;
    for i = 1, #WidgetStructure do
        sector = CreateFrame("Frame", nil, frame);
        tinsert(sectors, sector);
        if i == 1 then
            sector:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -12);
            sector:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -12);
        else
            sector:SetPoint("TOPLEFT", sectors[i - 1], "BOTTOMLEFT", 0, -36);
            sector:SetPoint("TOPRIGHT", sectors[i - 1], "BOTTOMRIGHT", 0, -36);
        end

        local header = sector:CreateFontString(nil, "OVERLAY", "NarciPrefFontCategory");
        header:SetText(WidgetStructure[i].name);
        header:SetJustifyH("LEFT");
        header:SetJustifyV("TOP");
        header:SetPoint("TOPLEFT", sector, "TOPLEFT", 0, 0);
        header:SetPoint("TOPRIGHT", sector, "TOPRIGHT", 0, 0);

        widgets = WidgetStructure[i].widgets;
        local startOffset = -30;
        for j = 1, #widgets do
            startOffset = startOffset + CreateWidget(sector, widgets[j], startOffset, i, j);
        end
        sector:SetHeight( -startOffset);
    end
end

local function LoadSettings(self)
    CreateSettings(self);
    self:SetHeaderText("Settings");
    self:HideWhenParentIsHidden(true);
end

local initialize = CreateFrame("Frame");
initialize:RegisterEvent("PLAYER_ENTERING_WORLD");
initialize:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        AchievementDB = NarciAchievementOptions;
        
        C_Timer.After(1.3, function()
            LoadSettings(Narci_AchievementSettings);
        end)
    end
end)