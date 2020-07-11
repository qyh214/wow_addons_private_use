local addonName, addon = ...
addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local private = {}
------------------------------------------------------------------------------

addon.frame = CreateFrame("Frame")

addon.METADATA = {
	NAME = GetAddOnMetadata(..., "Title"),
	VERSION = GetAddOnMetadata(..., "Version")
}

-- printing debug info
function addon:log(info, release)
	if addon.isDebug then
		-- addon:Printf(...)
		print("|cFF00cccc" .. addonName .. " |cFF00cc00" .. info)
	end
end

-- called by AceAddon when Addon is fully loaded
function addon:OnInitialize()
	-- makes Module ABC accessable as addon.ABC
	for module in pairs(addon.modules) do
		addon[module] = addon.modules[module]
	end

	-- loads data and options
	addon.db = AceDB:New(addonName .. "DB", addon.Options.defaults, true)
	AceConfigRegistry:RegisterOptionsTable(addonName, addon.Options.GetOptions)
	local optionsFrame = AceConfigDialog:AddToBlizOptions(addonName, addon.METADATA.NAME)
	addon.Options.frame = optionsFrame

	-- addon state flags
	addon.isDebug = true

	addon.isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)

	-- initialize chat command
	local chatfunc = function()
    	addon:ShowUI()
	end

	self:RegisterChatCommand("acamar", chatfunc)

	-- initialize writing data on player logout
	self:RegisterEvent("PLAYER_LOGOUT", function()
		addon:OnLogout()
		end)
end

-- called when Player logs out
function addon:OnLogout()
	-- Save session data
	addon.Options:SaveSession()
	--addon.AcamarGUI:OnLogout()
end

-- called by AceAddon on PLAYER_LOGIN
function addon:OnEnable()
	print("|cFF33FF99" .. addonName .. " (" .. addon.METADATA.VERSION .. ")|r: " .. L["Enter /acamar for Acamar engine main interface"])

	-- load options
	addon.Options:Load()

	-- Load last UI saved status
	if( addon.db.global.ui_switch_on ) then
		addon:ShowUI()
	end

	-- hook message or not based on setting
	self:HookSwitch()
end

-- clean job
function addon:OnDisable()
	self:UnhookAll()
end

function addon:OptionClicked()
end

function addon:ShowUI()
	if(addon.AcamarGUI.display) then
		if(addon.AcamarGUI.display:IsShown()) then
			-- do nothing
			return
		end
	end 

	addon.AcamarGUI:Load_Ace_Custom()
	addon.AcamarGUI.display:Show()
end

function addon:HideUI()

	if(addon.AcamarGUI.display) then
		if(addon.AcamarGUI.display:IsShown()) then
			addon.AcamarGUI.display:Hide()
			--AceGUI:Release(addon.AcamarGUI.display)
			addon.AcamarGUI.display = nil
		end
	end
end

function addon:UIToggle()
	-- open or release addon main frame
	if(addon.AcamarGUI.display) then
		if(addon.AcamarGUI.display:IsShown()) then
			self:HideUI()
		else
			self:ShowUI()
		end
	else 
		self:ShowUI()
	end
end

-- EOF
