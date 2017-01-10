-- Author      : RisM
-- Create Date : 6/28/2009 3:57:34 PM

local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
local L = LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell", false)

SpeakinSpell:PrintLoading("gui/gui.lua")



-------------------------------------------------------------------------------
-- OPTIONS GUI FUNCTIONS - SHARED UTILITIES
-------------------------------------------------------------------------------



function SpeakinSpell:GUI_GetEventSelectLabel()
	local type = SpeakinSpell.RuntimeData.OptionsGUIStates.SelectedEventTypeFilter
	if type == "MACRO" then
		--Locale note: normally string concatenation like this is frowned on
		--		but for /ss macros, the word order is forced by the slash command syntax, so it's OK here
		return tostring(SpeakinSpell.EventTypes.IN_SPELL_LIST[type])..strlower(MACRO)
	end
	local name = SpeakinSpell.EventTypes.IN_SPELL_LIST[type]
	if name then
		return name
	else
		return L["Select a Speech Event"]
	end
end


-------------------------------------------------------------------------------
-- FILTER EVENT LIST SEARCH FUNCTION
-------------------------------------------------------------------------------


function SpeakinSpell:GUI_ResetState()
	-- reset the persistent spell/event lists
	-- the rest is in the RuntimeData table which is also being reset at this time
	self.OptionsGUI.args.CreateNew.args.NewSpellNameSelect.values = {}
	self.OptionsGUI.args.CurrentMessagesGUI.args.SelectGroup.args.EventSelect.values = {}
end

	
function SpeakinSpell:RebuildSpellList( values, OptionsGUIState, EventTable, MatchesFilterFunc, GetDisplayNameFunc )
	local funcname = "RebuildSpellList"
	
	if not OptionsGUIState.FilterChanged then
		--self:DebugMsg(funcname,"not changed")
		return
	end
	
	--self:DebugMsg(funcname,"entry")
	OptionsGUIState.FilterChanged = false

	-- if the current selection doesn't match the filter, erase it, and we'll pick a new one
	if OptionsGUIState.SelectedEventKey and not MatchesFilterFunc( OptionsGUIState.SelectedEventKey ) then
		--self:DebugMsg(funcname,"erasing selection")
		OptionsGUIState.SelectedEventKey = nil
	end
	
	-- search NewEventsDetected for those that match the filter
	-- add or remove from the list as needed
	numAdded = 0
	for key,_ in pairs(EventTable) do
		-- if we're allowed to add more
		-- and this event matches the filter
		-- NOTE: use a hard cap of 200 search results even if ShowMoreThanAHundred is enabled
		--		many more than that will crash the GUI with a stack overflow
		if (OptionsGUIState.SelectedEventKey == key) or -- we already matched the selected key
			( ( SpeakinSpellSavedData.ShowMoreThanAHundred or (numAdded < 100) ) and (numAdded < 200) and MatchesFilterFunc(key) ) then
			-- add to the list of shown values
			numAdded = numAdded + 1
			values[key] = GetDisplayNameFunc(key)
			-- make sure we have a current spell selected for the options GUI 
			-- we'll use the first one we see
			if not OptionsGUIState.SelectedEventKey then
				--self:DebugMsg(funcname,"set selection to:"..key)
				OptionsGUIState.SelectedEventKey = key
			end
		else
			-- remove it from the list of shown values
			-- NOTE: keep the current selection, even if that makes 101 items
			values[key] = nil
		end
	end
	
	--table.sort(values) -- appears to be self-sorting
end



-------------------------------------------------------------------------------
-- CreateGUI - add the options GUI to the game's interface panel
-------------------------------------------------------------------------------

--TODOLATER: can this get an on-load handler to call CreateGUI when the GUI module is loaded on demand?

function SpeakinSpell:CreateGUI()
	-- Define Options table for the GUI
	self.OptionsGUI.name = "SpeakinSpell"
	
	-- NOTE: OnVariablesLoaded is too soon for LoadChatColorCodes
	-- these chat frame settings aren't loaded yet, will just load all white if we do it here (OnVariablesLoaded)
	-- HOWEVER: by the time we load on demand, we should be OK to do this now
	SpeakinSpell:LoadChatColorCodes()
	
	-- add dynamically-generated controls to the GUI definitions
	self:CreateGUI_CurrentMessagesGUI()
	self:CreateGUI_RandomSubs()
	self:CreateGUI_HelpPages()
	self:CreateGUI_Import()
	
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("SpeakinSpell",900,800)
	
	--flag that we ran this init function, so we don't run it again by accident
	--and so we know that the GUI module is loaded -AND- initialized
	--NOTE: this doesn't live in RuntimeData because that table can be reset
	self.IsGUILoaded = true
end



function SpeakinSpell:ColorizeChannelList( channels )
	--SpeakinSpell:LoadChatColorCodes() -- we have to do this later than OnVariablesLoaded, but doing it here is redundant
	local values = {}
	for channel,_ in pairs( channels ) do
		local color = SpeakinSpell.Colors.Channels[ channel ]
		if color then
			values[ L[channel] ] = color .. L[channel] -- [buildlocales.py No Warning] Locale keys for channel names are copied from SpeakinSpell.lua
		else
			values[ L[channel] ] =          L[channel] -- [buildlocales.py No Warning] i.e. "Silent" comes out white this way
		end
	end
	return values
end
