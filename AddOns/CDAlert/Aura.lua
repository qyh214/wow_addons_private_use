local addonName,ns = ...
local myarua = {}
local frame = CreateFrame("FRAME", "MyAddonFrame")
frame:RegisterEvent("UNIT_AURA")
frame:SetScript("OnEvent", function(self,event,unit,unitAuraUpdateInfo)
	if unit ~= "player" then return end
	if unitAuraUpdateInfo.addedAuras ~= nil then
		if not CDAlertDB.buffcall then return end
		for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
			if CDAlertDB["AuraIds"][aura.spellId] then
				if not CDAlertDB["AuraIds"][aura.spellId]["get"] then return end
				local source = CDAlertDB["AuraIds"][aura.spellId]["source"] and UnitName(aura.sourceUnit) or ""
				local sourcename = source~="" and "来自"..source or ""
				local text = "获得"..aura.name..sourcename
				C_VoiceChat.SpeakText(0, text, Enum.VoiceTtsDestination.LocalPlayback, 1, 100)
				myarua[aura.auraInstanceID] = aura
			end
		end
	end
	if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
		for a, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
			if myarua[auraInstanceID] ~= nil then
				local text = myarua[auraInstanceID].name.."结束"
				C_VoiceChat.SpeakText(0, text, Enum.VoiceTtsDestination.LocalPlayback, 1, 100)
				myarua[auraInstanceID] = nil;
			end
		end
	end

end)