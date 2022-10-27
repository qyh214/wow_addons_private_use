--local E, L, V, P, G = unpack(select(2, ...));
local E, L, V, P, G = unpack(ElvUI); 
local EP = LibStub("LibElvUIPlugin-1.0")

local AddOnName, Engine = ...
local EEL = E:NewModule("ElvuiEnhancedAgain", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0");

local IsAddOnLoaded = IsAddOnLoaded

-- Clear DB for testing>
local testmode = false
if testmode then
	for profile, data in pairs(ElvDB.profiles) do
		if data then
			if data.eel then
				data.eel = nil
			end
		end
	end
end
-- <Clear DB for testing

EEL.version = GetAddOnMetadata("ElvUI_Enhanced", "Version")
EEL.title = format('|cff00c0fa%s|r|cffff8000%s|r|cff00c0fa%s|r', "ElvUI ", "Enhanced ", "Again")
EEL.config = {}
EEL.elvV = tonumber(E.version)
EEL.elvR = tonumber(GetAddOnMetadata("ElvUI_Enhanced", "X-ElvVersion"))

P["eel"] = {}
V["eel"] = {}

E.PopupDialogs["VERSION_MISMATCH_EEL"] = {
	text = format(L["MSG_EEL_ELV_OUTDATED"], EEL.elvV, EEL.elvR),
	button1 = CLOSE,
	timeout = 0,
	whileDead = 1,	
	preferredIndex = 3,
}

local function GetOptions()
	for _, func in pairs(EEL.config) do
		func()
	end
end

--Showing warning message about too old versions of ElvUI
if EEL.elvV < 12 or (EEL.elvV < EEL.elvR) then
	E:Delay(2, function() E:StaticPopup_Show("VERSION_MISMATCH_EEL") end)
	return
end

function EEL:ConfigCat() 
	tinsert(E.ConfigModeLayouts, #(E.ConfigModeLayouts)+1, "ELVUIEHANCED");
	E.ConfigModeLocalizedStrings["ELVUIEHANCED"] = L["ElvUI Enhanced Again"]
end

function EEL:Initialize()
	EEL:ConfigCat() 
	if E.db.general.loginmessage then
		if E.Retail then
			print(format(L['ENH_LOGIN_MSG'], E["media"].hexvaluecolor, EEL.version))
		end
		if E.Wrath then
			print(format(L['ENH_LOGIN_MSG_WRATH'], E["media"].hexvaluecolor, EEL.version))
		end
	end	
	self.initialized = true

	EP:RegisterPlugin(AddOnName, GetOptions)
end

local function InitializeCallback()
	EEL:Initialize()
end

E:RegisterModule(EEL:GetName(), InitializeCallback)
