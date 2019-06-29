-----------------------------------------
----Save Chat Message during AFK Mode----
-----------------------------------------

local Messi = CreateFrame("Frame");
Messi:RegisterEvent("CHAT_MSG_BN_WHISPER");
Messi:RegisterEvent("CHAT_MSG_BN");
Messi:RegisterEvent("CHAT_MSG_WHISPER");

local a = {};
local function PrintMessage()
    for k, v in pairs(a) do
        if v ~= nil then
            print(k..". "..tostring(v));
        end
    end
    wipe(a)
end

Messi:SetScript("OnEvent",function(self,event,...)
    print(event) 
    a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14] = ...;
    PrintMessage()
end)