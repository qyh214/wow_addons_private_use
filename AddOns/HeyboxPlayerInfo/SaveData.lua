local _G = _G
local HeyboxApi = _G.HeyboxApi
local VersionInfo = _G.VersionInfo
local U = _G.Utils
local SAVED, SAVED_ONE = {}, {}

local frm = CreateFrame("Frame") 
frm:SetScript("OnEvent", function(self, event, ...) 
    if type(self[event]) == "function" then 
		return self[event](self, ...)
	end 
end)

frm:RegisterEvent("ADDON_LOADED")
function frm:ADDON_LOADED()
	HeyboxApi.GetEquipments(SAVED)
	
	HeyboxApi.GetToys(SAVED)

	HeyboxApi.GetPVPInfo(SAVED)
end

frm:RegisterEvent("PLAYER_LOGIN")
function frm:PLAYER_LOGIN()
	SAVED["MMR"] = {}

	HeyboxApi.GetAccountData(SAVED)

	HeyboxApi.GetCharacterInfo(SAVED)

	HeyboxApi.GetTalentTreeRetail(SAVED)

	HeyboxApi.GetSkillRelated(SAVED)
	
	HeyboxApi.GetMounts(SAVED)

	HeyboxApi.GetClassicMounts(SAVED)

	HeyboxApi.GetAchievements(SAVED)

	HeyboxApi.GetRunHistory(SAVED)

	HeyboxApi.GetReputations(SAVED)

	HeyboxApi.GetCovenant(SAVED)
	
	HeyboxApi.GetCharacterTalent(SAVED)

	HeyboxApi.GetHunterPets(SAVED)

	HeyboxApi.GetGlyphs(SAVED)
end

frm:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
function frm:UPDATE_BATTLEFIELD_STATUS()
	HeyboxApi.GetMMR(SAVED)
end

frm:RegisterEvent("PLAYER_LOGOUT")
function frm:PLAYER_LOGOUT() 
	HeyboxApi.GetPets(SAVED)

	HeyboxApi.GetGlobal(SAVED, SAVED_ONE)	

	if U.Length(SAVED["MMR"]) then
		SAVED["MMR"] = nil
	end

	_G.HEYBOX_SAVED_PER_PLAYER_INFOS = U.Encode(U.table2json(SAVED), nil, nil)
	_G.HEYBOX_SAVED_PLAYER_INFOS = SAVED_ONE
end