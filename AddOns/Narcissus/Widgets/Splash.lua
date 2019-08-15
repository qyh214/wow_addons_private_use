local ShowSplash = true;    --patch specific 1.0.6:Shown

-----------------------------------------------------------------

local function ApplyPatchFix(self)
    --Apply fix--
    --1.0.6 Reset vignette strength to 0.5 (was 0.8)--
    Narci_VignetteStrengthSlider:SetValue(0.5);
end

--[[
function Narci_ExtraInfoButton_OnClick(self)
    self:Disable();
    self.Text:SetText(NARCI_SPLASH_MESSAGE1_EXTRA_LINE);
    self:SetHeight(self.Text:GetHeight() + 16);
end
--]]

local function Narci_TryItNow_OnClick(self)
    local text;
    if not self.HasEnabled then
        text  = self.enabledText;   --"|cff7cc576"
    else
        text  = self.disabledText;
    end
    self.Text:SetText(text);
    self:SetHeight(self.Text:GetHeight() + 4);
    self:SetScript("OnLeave", function() return; end);
    self:SetScript("OnEnter", function() return; end);
end

function Narci_TryItNow_DressingRoom(self)
    Narci_TryItNow_OnClick(self);
    if NarcissusDB.DressingRoom then
        Narci_DressingRoomSwitch_OnClick(Narci_DressingRoomSwitch);
    end
end

function Narci_Splash_CameraSafeMode_OnShow(self)
    if IsAddOnLoaded("DynamicCam") then
        self.HasEnabled = false;
        if NarcissusDB.CameraSafeMode then
            Narci_CameraSafeSwitch_OnClick(Narci_CameraSafeSwitch);
        end
        self.Text:SetText(NARCI_CAMERA_SAFE_MODE_DISABLED_BY_DEFAULT);
    else
        self.HasEnabled = true;
        NarcissusDB.CameraSafeMode = true;
        self.Text:SetText(NARCI_CAMERA_SAFE_MODE_ENABLED_BY_DEFAULT);
    end
end

function Narci_TryItNow_CameraSafeMode(self)
    local state = self.HasEnabled;
    local text;
    if not state then
        text  = self.enabledText;   --"|cff7cc576"
    else
        text  = self.disabledText;
    end
    Narci_CameraSafeSwitch_OnClick(Narci_CameraSafeSwitch);
    self.Text:SetText(text);
    self:SetHeight(self.Text:GetHeight() + 4);
    self:SetScript("OnLeave", function() return; end);
    self:SetScript("OnEnter", function() return; end);
end


-----------------------------------------------------------------
if not ShowSplash then
    return;
end

local Backdrops = {
    [1] = "Interface/AddOns/Narcissus/Art/Splash/Backdrop1",
    [2] = "Interface/AddOns/Narcissus/Art/Splash/Backdrop2",
    [3] = "Interface/AddOns/Narcissus/Art/Splash/Backdrop3",
    [4] = "Interface/AddOns/Narcissus/Art/Splash/Backdrop4",
};
local BackdopIndex = 3;

function Narci_Splash_ChangePhoto()
    local frame = Narci_Splash;
    if not frame.ShowFront then
        frame.BackdropFront:SetTexture(Backdrops[BackdopIndex]);
        --print("front #"..BackdopIndex)
    else
        frame.Backdrop:SetTexture(Backdrops[BackdopIndex]);
        --print("back #"..BackdopIndex)
    end
    if BackdopIndex >= #Backdrops then
        BackdopIndex = 1;
    else
        BackdopIndex = BackdopIndex + 1;
    end
end

local Splash = CreateFrame("Frame");
Splash:RegisterEvent("VARIABLES_LOADED");
if ShowSplash then  Splash:RegisterEvent("GARRISON_UPDATE"); end;
Splash:SetScript("OnEvent", function(self, event)
    local event = event;
    self:UnregisterEvent(event);
    if event == "VARIABLES_LOADED" then
        if Narci.Current_Version > NarcissusDB.SplashVersion then
            ApplyPatchFix()
            NarcissusDB.SplashVersion = Narci.Current_Version;
            if ShowSplash and (not Narci_Splash) then
                CreateFrame("Frame", "Narci_Splash", UIParent, "Narci_SplashFrame_Template");
            else
                self:UnregisterAllEvents();
            end
        end
    elseif event == "GARRISON_UPDATE" then
        local frame = Narci_Splash;
        if not frame then return; end;
        tinsert(UISpecialFrames, frame:GetName());
        C_Timer.After(1, function()
            frame:Show();
        end)
        C_Timer.After(3, function()
            frame.animIn:Play();
            frame.BackdropFront.animOut:Play();
            PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_OPEN);
            UIFrameFadeIn(frame, 0.25, 0, 1);
        end)
    end
end)

--Events Test--

--[[
local EventListener = CreateFrame("Frame");
EventListener:RegisterAllEvents()
--EventListener:RegisterEvent("CVAR_UPDATE")
--EventListener:RegisterEvent("CONSOLE_MESSAGE")
EventListener:RegisterEvent("CHAT_MSG_SYSTEM")
--EventListener:RegisterEvent("PLAYER_LEAVING_WORLD");
--EventListener:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
--EventListener:RegisterEvent("PLAYER_FLAGS_CHANGED")
EventListener:SetScript("OnEvent",function(self,event,...)
	if event ~= "COMBAT_LOG_EVENT" and event ~= "COMBAT_LOG_EVENT_UNFILTERED" and event ~= "CHAT_MSG_ADDON"
    and event ~= "UNIT_COMBAT" and event ~= "ACTIONBAR_UPDATE_COOLDOWN" and event ~= "UNIT_AURA"

    and event ~= "GUILD_ROSTER_UPDATE" and event ~= "GUILD_TRADESKILL_UPDATE" and event ~= "GUILD_RANKS_UPDATE"
    and event ~= "UPDATE_MOUSEOVER_UNIT" and event ~= "CURSOR_UPDATE"
    and event ~= "NAME_PLATE_UNIT_ADDED" and event ~= "NAME_PLATE_UNIT_REMOVED" and event ~= "NAME_PLATE_CREATED"
    and event ~= "SPELL_UPDATE_COOLDOWN" and event ~= "SPELL_UPDATE_USABLE"
    and event ~= "BN_FRIEND_INFO_CHANGED" and event ~= "FRIENDLIST_UPDATE"
	and event ~= "MODIFIER_STATE_CHANGED" and event ~= "UPDATE_SHAPESHIFT_FORM" and event ~= "SOCIAL_QUEUE_UPDATE" and event ~= "COMPANION_UPDATE" and event ~= "UPDATE_MOUSEOVER_UNIT"
	and event ~= "COMPANION_UPDATE" and event ~= "UPDATE_INVENTORY_DURABILITY" then
		print("Event: |cFFFFD100"..event)
		local name, value, value2, value3, value4, value5 = ...
		--print(name)
		--print(value)
        --print(value2)
		--print("\n")
    end
end)
--]]