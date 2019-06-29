function Narci_Splash_OnShow(self)
    local CameraFollowStyle = GetCVar("cameraSmoothStyle");
    if CameraFollowStyle == "0" then		--auto-follow disabled
        self.Text1:SetText(NARCI_SPLASH_MESSAGE1.."\n\n"..NARCI_SPLASH_MESSAGE1_CONDITIONAL_LINE)
    else
        self.Text1:SetText(NARCI_SPLASH_MESSAGE1)
    end
end

--[[
function Narci_ExtraInfoButton_OnClick(self)
    self:Disable();
    self.Text:SetText(NARCI_SPLASH_MESSAGE1_EXTRA_LINE);
    self:SetHeight(self.Text:GetHeight() + 16);
end
--]]

local function Narci_TryItNow_OnClick(self)
    local text = self.enabledText;
    self.Text:SetText("|cff7cc576"..text);
    self:SetHeight(self.Text:GetHeight() + 4);
    self:SetScript("OnLeave", function() return; end);
    self:SetScript("OnEnter", function() return; end);
end

function Narci_TryItNow_AFKScreen(self)
    Narci_TryItNow_OnClick(self);
    if not NarcissusDB.AFKScreen then
        Narci_AFKScreenSwitch_OnClick(Narci_AFKScreenSwitch);
    end
end

function Narci_TryItNow_Letterbox(self)
    Narci_TryItNow_OnClick(self);
    if not NarcissusDB.LetterboxEffect then
        Narci_LetterboxEffectSwitch_OnClick(Narci_LetterboxEffectSwitch);
    end
end

local ClickCounter = 2;
function Narci_CloseSplash(self)
    local Anchor = self:GetParent().TryIt2;
    if ClickCounter == 2 then
        self.a1:Play();
    elseif ClickCounter == 1 then
        self:StopAnimating();
        self.a2:Play();
    else
        NarciAPI_FadeFrame(self:GetParent(), 0.2, "OUT");
    end
    ClickCounter = ClickCounter - 1;
end

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
		print(name)
		print(value)
        print(value2)
		--print("\n")
    end
end)
--]]