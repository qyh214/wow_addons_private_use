local addonName, addon = ...
local AcamarGUI = addon:NewModule("AcamarGUI", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")
local private = {}
------------------------------------------------------------------------------

local fontName, fontHeight, fontFlags = DEFAULT_CHAT_FRAME:GetFont()

-- do things on logout
function AcamarGUI:OnLogout()
end

function AcamarGUI:ShowSysSettings()
    InterfaceOptionsFrame_Show()
    InterfaceOptionsFrame_OpenToCategory(addonName);
    InterfaceOptionsFrame_OpenToCategory(addonName);
end

function AcamarGUI:Load_Ace_Custom()
	local frame = AceGUI:Create("AcamarFrame")

	addon.db.global.ui = addon.db.global.ui or {}
	frame:SetStatusTable(addon.db.global.ui)

	frame:SetTitle(addonName)
	frame.titletext:SetFont(fontName, 11.8)
	frame:EnableResize(false)

  	-- When close button clicked
	frame:SetCallback("OnClose",
		function(widget) 
			addon.db.global.ui_switch_on = false
			AceGUI:Release(widget) 
		end)
  
  	-- When settings button clicked
	frame:SetCallback("OnSettingsClick",
		function(widget) 
			addon.AcamarGUI:ShowSysSettings()
		end)
  
  	-- When power button clicked
  	frame:SetCallback("OnPowerClick",
		function(widget) 
      		addon:ToggleFiltering();
		end)
  
	frame:SetLayout("Fill")

	AcamarGUI.display = frame

	self:CreateScrollContainer()

	addon:log(L["Acamar control window opened."])

	-- uodate UI status
	addon.AcamarGUI:UpdateAddonUIStatus(addon.db.global.message_filter_switch)

	return AcamarGUI.display
end

function AcamarGUI:CreateScrollContainer()
	-- Add children
	local scrollcontainer = AceGUI:Create("SimpleGroup") 
	--local frame = scrollcontainer
	scrollcontainer:SetFullWidth(true)
	scrollcontainer:SetFullHeight(true) -- probably?
	scrollcontainer:SetLayout("Fill") -- important!
	AcamarGUI.display:AddChild(scrollcontainer)

	local scroll = AceGUI:Create("AcamarScrollFrame")
	-- customized layout
	scroll:SetLayout("Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	scroll:SetAutoAdjustHeight(true)
	scrollcontainer:AddChild(scroll)

	-- the scroll container is to hold message widgets
	self.scroll = scroll
	self.scrollcontainer = scrollcontainer
end

function AcamarGUI:UpdateAddonUIStatus(isactive)
  AcamarGUI.display:OnPowerButtonStatus(isactive)
  if isactive then
    AcamarGUI.display.titletext:SetTextColor(1, 0.82, 0, 1);
  else
    AcamarGUI.display.titletext:SetTextColor(1, 0, 0, 1);
  end
end

function AcamarGUI:CreateNewLineWidget(topics)
		local msgLine = AceGUI:Create("AcamarEntry")

		msgLine:SetRelativeWidth(1)
		msgLine:SetHeight(addon.db.global.fontsize)
		msgLine:SetPoint("LEFT", 0, 0)
		msgLine:SetFont(fontName, addon.db.global.fontsize)

		msgLine:SetCallback("OnClick", ClickLabel)

		return msgLine
end
-- EOF

