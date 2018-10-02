-- Author      : RisM
-- Create Date : 9/21/2009 3:08:17 AM

local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
local L = LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell", false)
local HELPFILE = LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell_HELPFILE", false)

SpeakinSpell:PrintLoading("gui/help.lua")

-------------------------------------------------------------------------------
-- GUI LAYOUT - HELP MANUAL
-------------------------------------------------------------------------------


SpeakinSpell.OptionsGUI.args.HelpRoot = {
	order = 99,
	type = "group",
	name = L["Help"],
	desc = L["The Complete User's Manual"],
	args = {
		Header = {
			order = 1,
			type = "header",
			name = L["User's Manual"],
		},
		Caption = {
			order = 2,
			type = "description",
			name = L["Select a topic..."].."\n",
		},
	}, --end args
} --end HelpRoot
			
			
-------------------------------------------------------------------------------
-- OPTIONS GUI FUNCTIONS - HELP PAGES
-------------------------------------------------------------------------------


function SpeakinSpell:CreateGUI_HelpPages()
	local funcname = "CreateGUI_HelpPages"
	
	-- build help pages
	for Title,HelpChapter in pairs(HELPFILE.PAGES) do
		local FrameObjectName = string.format("HelpTopic%03d",HelpChapter.order)
		
		-- setup OptionGUI object
		self.OptionsGUI.args.HelpRoot.args[FrameObjectName] = {
			type = 'group',
			order = HelpChapter.order,
			name = Title, --L["1. About SpeakinSpell"],
			desc = HelpChapter.Summary,
			args = {
				Caption = {
					order = 1,
					type = "header",
					width = "full",
					name = Title, --L["1. About SpeakinSpell"],
				},
				Content = {
					order = 2,
					type = "description",
					width = "full",
					name = HelpChapter.Contents, --help CONTENTS
				},
			}, --end args
		} --end Chapter1
	end
end


