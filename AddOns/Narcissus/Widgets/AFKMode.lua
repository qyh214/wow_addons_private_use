local AFK = CreateFrame("Frame");
AFK:RegisterEvent("CHAT_MSG_SYSTEM")
--local UnitIsAFK = UnitIsAFK;

local AFK_Msg = string.format(MARKED_AFK_MESSAGE, DEFAULT_AFK_MESSAGE)

AFK:SetScript("OnEvent",function(self,event,...)
    if not NarcissusDB or not NarcissusDB.AFKScreen then return; end
    if IsInCinematicScene() or InCinematic() then
        print("Play Cinematic");
    end
    local name = ...
    if name == AFK_Msg and not(C_PvP.IsActiveBattlefield() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then
        if not Narci_Character:IsShown() then
            Narci_MinimapButton:Click();
            C_Timer.After(2, function()
                Narci_Character.AutoStand:Play();
            end)
            C_Timer.After(0.6, function()
                PhotoModeController:SetAlpha(0);
                if IsResting() then
                    DoEmote("Read", "none");
                end
            end)
        end
    end

    --[[
    deprecated because this method cause addon performance loss somehow: lagging and camera over-yawing
    if UnitIsAFK("player") then
        
        if not Narci_Character:IsShown() then
            Narci_MinimapButton:Click();
            
            C_Timer.After(0.5, function()
                PhotoModeController:SetAlpha(0);
                if IsResting() then
                    DoEmote("Read", "none");
                end
            end)
        end
       
        return;
    end 
    --]]
end)

--Override other AFK screens--
local function NullifyEvent(frame)
    if not frame then   return; end
    frame:SetScript("OnEvent", function()   return; end);
end


--[[
local oAFK = CreateFrame("Frame");
oAFK:RegisterEvent("CINEMATIC_START");
oAFK:RegisterEvent("CINEMATIC_STOP");
oAFK:RegisterEvent("PLAY_MOVIE")
oAFK:SetScript("OnEvent", function(self, event, ...)
    local name = ...
    print(event)
    print(name)
    C_Timer.After(4, function()
        print(MovieFrame:IsShown())
    end)
end)
--]]

