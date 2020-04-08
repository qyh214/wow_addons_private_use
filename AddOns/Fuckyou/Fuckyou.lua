local function fuckyou(self)
	if GetCVar("portal") == "CN" then
		ConsoleExec("portal TW")
	end
	SetCVar("profanityFilter", 0)
	self:UnregisterEvent("ADDON_LOADED")
end

local godie = CreateFrame("FRAME", nil)
	godie:RegisterEvent("ADDON_LOADED")
	godie:SetScript("OnEvent", fuckyou)