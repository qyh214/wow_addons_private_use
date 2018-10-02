-- Author      : Ris
-- Create Date : 11/20/2010 3:19:24 PM


local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
local L = LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell", false)

SpeakinSpell:PrintLoading("lodwrapper_defaults.lua")

-------------------------------------------------------------------------------
-- Load default data from the SpeakinSpell_Defaults module, on-demand
-------------------------------------------------------------------------------


function SpeakinSpell:LoadDefaultsModule()
	if self.IsDefaultsModuleLoaded then
		return self.IsDefaultsModuleLoaded
	end
	
	local loaded, message = LoadAddOn("SpeakinSpell_Defaults")
	self.IsDefaultsModuleLoaded = loaded
	
	if not loaded then
		local subs = {
			message = message,
		}
		local format = L[
[[ERROR: SpeakinSpell_Defaults could not be loaded on demand
Reason: <message>
Please return to the character selection screen and enable the SpeakinSpell_Defaults addon]]
		]
		self:Print( self:FormatSubs( format, subs ) )
	end
	
	return self.IsDefaultsModuleLoaded
end


function SpeakinSpell:LoadDefaultEventHooks()
	if self:LoadDefaultsModule() then
		return LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell_DEFAULT_EVENTHOOKS", false)
	else
		local EmptyDefaults = {
			NewEventsDetected = {},
		}
		return EmptyDefaults
	end
end


function SpeakinSpell:LoadDefaultSpeeches()
	if self:LoadDefaultsModule() then
		return LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell_DEFAULT_SPEECHES", false)
	else
		local EmptyDefaults = {
			Templates = {},
		}
		return EmptyDefaults
	end
end


-------------------------------------------------------------------------------
-- Public entry-point for Templates
-------------------------------------------------------------------------------


function SpeakinSpell:Templates_Load()
	if not self:LoadDefaultsModule() then
		return
	end

	-- make a working copy of the default speech templates
	-- while loading, make all templates self-aware of their keys
	-- and rekey the table on the template names instead of auto-numbered
	-- so that the list in the GUI will sort
	local DEFAULT_SPEECHES = self:LoadDefaultSpeeches()
	self.DEFAULTS.Templates = {}
	for i,t in pairs( DEFAULT_SPEECHES.Templates ) do
		self:LoadTemplate( t, L["BUILT-IN"] )
	end
	
	-- add a default template of <randomstuff> from <guild> and other info
	self:Template_BuildAuto_Random()
	
	-- add content from my other toons
	self:Templates_AddMyOtherToons()
	
	-- add shared content that we received over the network
	self:Templates_AddSharedNetworkContent()
	
	-- delete default speeches from RAM if they don't apply to this race/class
	self:DeleteUnusableTemplates( true )	
end


-- NOTE: we'll reload this data if needed
--	when the GUI is opened, of to reset to defaults or whatever
function SpeakinSpell:Templates_Release()
	--self:DeleteUnselectedTemplates()
	--self:DebugMsg(nil,"--Templates--")
	--self:DebugMsgDumpTable( self.DEFAULTS.Templates, "Templates", 2 )
	self.DEFAULTS.Templates = nil
	self.DEFAULTS.Templates = {}
end


function SpeakinSpell:ImportDefaultStarterSpeeches()
	-- TODOSOON: redesign default speeches and the import process to make this a manual process or a non-issue
	--		as it stands, PreserveOtherToons still adds events to the AllToonsEventTable
	--		with undesirable side effects on other toons, so I'm completely disabling that behavior for now
	local PreserveOtherToons = SpeakinSpellSavedDataForAll.AllToonsShareSpeeches and (not self:IsTableEmpty( self:GetActiveEventTable() ))
	if PreserveOtherToons then
		return
	end
	
	if not self:LoadDefaultsModule() then
		return
	end

	if self:IsTableEmpty( self.DEFAULTS.Templates ) then
		self:Templates_Load()
	end
	
	for key,Template in pairs( SpeakinSpell.DEFAULTS.Templates ) do
		if self:Template_UseAsStarterDefault( Template, PreserveOtherToons ) then
			self:ImportTemplate( Template ) 
		end
	end

	--NOTE: even if the GUI is showing right now, we have dramatically changed the available template content
	-- go ahead and release it.  if necessary we'll force a GUI refresh
	self:Templates_Release()
end


function SpeakinSpell:Import_AllAltsToSharedEventTable()
	--TODOLATER: the SpeakinSpell_Defaults module is mostly unnecessary for this function
	--		mostly needed just for some shared functions that live in templates.lua
	--		it deserves more consideration whether more of those functions should be pulled into core
	--		so that this function doesn't have to LoadDefaultsModule()
	if not self:LoadDefaultsModule() then
		return
	end

	-- share existing templates functions to import all other alts' speeches into this one
	self.DEFAULTS.Templates = {}
	self:Templates_AddMyOtherToons()
	self:DeleteUnusableTemplates( true )	

	for index,Template in pairs( SpeakinSpell.DEFAULTS.Templates ) do
		self:ImportTemplate( Template )
	end
	
	-- done with templates
	self.DEFAULTS.Templates = nil
	
	--set SpeakinSpellSavedDataForAll.AllToonsEventTable to the active event table
	if not SpeakinSpellSavedDataForAll.AllToonsEventTable then
		SpeakinSpellSavedDataForAll.AllToonsEventTable = self:GetActiveEventTable()
	end
	SpeakinSpellSavedDataForAll.AllToonsShareSpeeches = true -- changes result from GetActiveEventTable()
	
	-- clear the Toon-specific event tables...
	--SpeakinSpellSavedDataForAll.Toons = nil
	-- keep the set of known realms/toons and only erase the EventTables to save memory
	if SpeakinSpellSavedDataForAll.Toons then
		for realm,ToonList in pairs(SpeakinSpellSavedDataForAll.Toons) do
			for toon,ToonSettings in pairs(ToonList) do
				ToonSettings.EventTable = nil
			end
		end
	end
end


