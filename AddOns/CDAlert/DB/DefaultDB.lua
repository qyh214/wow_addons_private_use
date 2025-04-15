local addonName,ns = ...

ns.CDAlertDefaultDB = {
	cdcall = true,
	tipid = false,
	
	SpellIds = {
		[342245] = {},	--操控时间
		[414660] = {},	--群体屏障
	},
	ItemIds = {},
	AuraIds = {},
}

-------配置加载---------
local loadFrame = CreateFrame("FRAME"); 
loadFrame:RegisterEvent("ADDON_LOADED"); 
loadFrame:RegisterEvent("PLAYER_LOGOUT"); 

function loadFrame:OnEvent(event, arg1)
	if not CDAlertDB then CDAlertDB = {} end
	for i, j in pairs(ns.CDAlertDefaultDB) do
		if type(j) == "table" then
			if CDAlertDB[i] == nil then CDAlertDB[i] = {} end
		else
			if CDAlertDB[i] == nil then CDAlertDB[i] = j end
		end
	end
end
loadFrame:SetScript("OnEvent", loadFrame.OnEvent);