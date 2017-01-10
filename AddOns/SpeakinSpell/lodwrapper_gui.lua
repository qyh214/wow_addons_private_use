-- Author      : RisM
-- Create Date : 8/17/2010 3:57:34 PM

local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
local L = LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell", false)
local ACD = LibStub("AceConfigDialog-3.0")

SpeakinSpell:PrintLoading("lodwrapper_gui.lua")


-------------------------------------------------------------------------------
-- GUI STUB for the interface options frame (must live in the Core)
-------------------------------------------------------------------------------


SpeakinSpell.OptionsGUIStub.args.Stub = {
	order = 1,
	type = "group",
	name = L["SpeakinSpell"],
	desc = L["SpeakinSpell Options"],
	args = {
		-----------------------
		Caption = {
			order = 1,
			type = "header",
			name = L["SpeakinSpell Options"],
		},
		Button = {
			order = 2,
			type = "execute",
			name = L["/ss options"],
			desc = L[
[[Click here to open the SpeakinSpell options, or type "/ss options"]]
			],
			func = function()
				SpeakinSpell:ShowOptions()
			end,
		},
	},
}


-------------------------------------------------------------------------------
-- ShowPage() functions - Open the Interface Options Panel to various pages
-------------------------------------------------------------------------------


function SpeakinSpell:LoadGUI()
	if self.IsGUILoaded then
		-- we're already loaded
		return true
	end
	
	local loaded, message = LoadAddOn("SpeakinSpell_GUI")
	if (loaded) then
		if not self.IsGUILoaded then
			self:CreateGUI() --sets the IsGUILoaded flag before it succeeds
			--self.IsGUILoaded = true -- don't do this here in case CreateGUI is called elsewhere
		end
	else
		local subs = {
			message = message,
		}
		local format = L[
[[ERROR: SpeakinSpell_GUI could not be loaded on demand
Reason: <message>
Please return to the character selection screen and enable the SpeakinSpell_GUI addon]]
		]
		self:Print( self:FormatSubs( format, subs ) )
	end
	
	return self.IsGUILoaded
end


function SpeakinSpell:CreateGUIStub()
	-- Add localized strings to the GUI frame tables
	self.OptionsGUI.name = L["SpeakinSpell"]
	self.OptionsGUI.desc = L["/ss options"]
	self.OptionsGUIStub.name = L["SpeakinSpell"]
	self.OptionsGUIStub.desc = L["/ss options"]

	-- :RegisterOptionsTable(appName, options, slashcmd, persist)
	-- AceConfig:RegisterOptionsTable("MyAddon", myOptions, {"/myslash", "/my"})
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SpeakinSpellStub", self.OptionsGUIStub, nil)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SpeakinSpell", self.OptionsGUI, nil)

	ACD:AddToBlizOptions("SpeakinSpellStub", L["SpeakinSpell"], nil, "Stub")
end


function SpeakinSpell:ShowOptions()
	local funcname = "ShowOptions"
	-- open interface options to show SpeakinSpell
	if not self:LoadGUI() then
		self:DebugMsg(funcname, "failed to LoadGUI")
		return
	end
	-- InterfaceOptionsFrame_OpenToCategory( "SpeakinSpell" )
	ACD:SelectGroup("SpeakinSpell","General")
	ACD:Open("SpeakinSpell")
end


function SpeakinSpell:ShowOptions_Toggle()
	local funcname = "ShowOptions_Toggle"
	if not self:LoadGUI() then
		self:DebugMsg(funcname, "failed to LoadGUI")
		return
	end
	local OpenFrame = ACD.OpenFrames["SpeakinSpell"]
	if OpenFrame and OpenFrame:IsVisible() then
		ACD:Close("SpeakinSpell")
	else
		ACD:Open("SpeakinSpell")
	end
end


function SpeakinSpell:ShowHelp()
	local funcname = "ShowHelp"
	-- open interface options to show SpeakinSpell
	if not self:LoadGUI() then
		self:DebugMsg(funcname, "failed to LoadGUI")
		return
	end
	-- InterfaceOptionsFrame_OpenToCategory(L["Help"])
	ACD:SelectGroup("SpeakinSpell","HelpRoot")
	ACD:Open("SpeakinSpell")
end


function SpeakinSpell:ShowHelpTopic( index )
	local funcname = "ShowHelpTopic"
	if not self:LoadGUI() then
		self:DebugMsg(funcname, "failed to LoadGUI")
		return
	end

	local FrameObjectName = string.format("HelpTopic%03d",index)
	self:DebugMsg(funcname, FrameObjectName)
	--LibStub("AceConfigDialog-3.0"):Open("SpeakinSpell", nil, "HelpRoot")
	ACD:SelectGroup( "SpeakinSpell", "HelpRoot", FrameObjectName )
	ACD:Open("SpeakinSpell")
end


function SpeakinSpell:ShowImport()
	local funcname = "ShowImport"
	-- open interface options to show SpeakinSpell
	if not self:LoadGUI() then
		self:DebugMsg(funcname, "failed to LoadGUI")
		return
	end
	-- InterfaceOptionsFrame_OpenToCategory(L["Import"])
	ACD:SelectGroup("SpeakinSpell","ImportGUI")
	ACD:Open("SpeakinSpell")
end


function SpeakinSpell:ShowColorsGUI()
	local funcname = "ShowColorsGUI"
	-- open interface options to show SpeakinSpell
	if not self:LoadGUI() then
		self:DebugMsg(funcname, "failed to LoadGUI")
		return
	end
	-- InterfaceOptionsFrame_OpenToCategory(COLORS)
	ACD:SelectGroup("SpeakinSpell","Colors")
	ACD:Open("SpeakinSpell")
end


function SpeakinSpell:ShowCreateNew()
	local funcname = "ShowCreateNew"
	-- open interface options to show SpeakinSpell
	if not self:LoadGUI() then
		self:DebugMsg(funcname, "failed to LoadGUI")
		return
	end
	-- InterfaceOptionsFrame_OpenToCategory(L["Create New..."])
	ACD:SelectGroup("SpeakinSpell","CreateNew")
	ACD:Open("SpeakinSpell")
end


function SpeakinSpell:ShowMessageOptions()
	local funcname = "ShowMessageOptions"
	-- open interface options to show SpeakinSpell
	if not self:LoadGUI() then
		self:DebugMsg(funcname, "failed to LoadGUI")
		return
	end
	-- InterfaceOptionsFrame_OpenToCategory(L["Message Settings"])
	ACD:SelectGroup("SpeakinSpell","CurrentMessagesGUI")
	ACD:Open("SpeakinSpell")
end


function SpeakinSpell:ShowRandomSubsOptions()
	local funcname = "ShowRandomSubsOptions"
	-- open interface options to show SpeakinSpell
	if not self:LoadGUI() then
		self:DebugMsg(funcname, "failed to LoadGUI")
		return
	end
	-- InterfaceOptionsFrame_OpenToCategory(L["Random Substutitions"])
	ACD:SelectGroup("SpeakinSpell","RandomSubs")
	ACD:Open("SpeakinSpell")
end


function SpeakinSpell:ShowNetworkOptions()
	local funcname = "ShowNetworkOptions"
	-- open interface options to show SpeakinSpell
	if not self:LoadGUI() then
		self:DebugMsg(funcname, "failed to LoadGUI")
		return
	end
	-- InterfaceOptionsFrame_OpenToCategory(L["Data Sharing"])
	ACD:SelectGroup("SpeakinSpell","Network")
	ACD:Open("SpeakinSpell")
end



function SpeakinSpell:RefreshFrame(FrameName)
	if not self.IsGUILoaded then
		-- nothing to refresh
		return
	end
	LibStub("AceConfigRegistry-3.0"):NotifyChange("SpeakinSpell")
end


-- if the options GUI is showing right now, we need to refresh it to make it show the new data
function SpeakinSpell:RefreshAllFrames()
	if not self.IsGUILoaded then
		-- nothing to refresh
		return
	end	
	LibStub("AceConfigRegistry-3.0"):NotifyChange("SpeakinSpell")
end
