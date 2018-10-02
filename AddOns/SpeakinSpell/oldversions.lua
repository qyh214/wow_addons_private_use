-- Author      : RisM
-- Create Date : 6/28/2009 3:59:16 PM

local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
local L = LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell", false)

SpeakinSpell:PrintLoading("oldversions.lua")


-----------------------------------------------------------------------------------
-- Define Patches by version
-----------------------------------------------------------------------------------

SpeakinSpell.Patches = {

{ Version = "3.1.1.02", 
	-- Added this global toggle in 3.1.1.02, before this, it behaved as if always on
	func = function() SpeakinSpellSavedData.EnableAllMessages = true end,
},

{ Version = "3.1.2.05", 
	-- redefined the SpellTable as EventTable with a new key system and data format
	func = function() SpeakinSpell:FixOld_31205_ImportSpellTable() end,
},

{ Version = "3.1.2.06", 
	-- changed event keys so they sort by event type instead of spell name
	func = function() SpeakinSpell:FixOld_31206_UpdateEventKeys() end,
},

{ Version = "3.1.2.07",
	-- changed event keys to uppercase, with underscores replacing spaces
	func = function() SpeakinSpell:FixOld_31207_UpdateEventKeys() end,
},

{ Version = "3.1.3.02",
	-- moved the NewEventsDetected table from RuntimeData into SpeakinSpellSavedData
	func = function() SpeakinSpell:FixOld_31302_AddNewEventsDetected() end,
},

{ Version = "3.1.3.03",
	-- I discovered that DetectedEvent.type was left undefined for many event types in the saved data
	-- thankfully, it can be recovered from the key format
	func = function() SpeakinSpell:FixOld_31303_RecoverMissingTypes() end,
},

{ Version = "3.2.0.06",
	-- This version made several changes to the saved data
	func = function() SpeakinSpell:FixOld_32006_BunchOfStuff() end,
},

{ Version = "3.2.2.02",
	-- This version enhanced <newline> to allow storing "\n" in the data and GUI
	func = function() SpeakinSpell:FixOld_32202_UpgradeNewline() end,
},

{ Version = "3.2.2.14",
	-- This version split up the growing category of type = "EVENT" speech events into new additional event types
	func = function() SpeakinSpell:FixOld_32214_UpgradeEvents() end,
},

{ Version = "3.2.2.15",
	-- This version split "Combat Event: Yellow Damage" into I caused yellow damage vs. I received yellow damage.
	-- event keys and names must be updated accordingly
	func = function() SpeakinSpell:FixOld_32215_RenameYellowDamage() end,
},

{ Version = "3.2.2.17",
	-- moved saved data tables from the per-character to account-wide settings
	func = function() SpeakinSpell:FixOld_32217_MoveSavedData() end,
},

{ Version = "3.2.2.21",
	-- introduced the concept of the DATA_VERSION separate from the CURRENT_VERSION
	-- a patch must be defined in order to increment the DATA_VERSION
	-- without a patch definition, the data from previous client versions will be considered compatible with the current version
	-- NOTE: this version also split the channel option COMM TRAFFIC into TX/RX, but I doubt anyone was using it
	--		and this was a beta so if the lack of a patch for that causes LUA errors, oh well, I'm being lazy about this one
	func = function() end,
},

{ Version = "3.2.2.22",
	-- moved some networking options into a sub-table
	func = function() SpeakinSpell:FixOld_32222_MoveNetworkOptions() end,
},

{ Version = "3.2.2.25",
	-- the previous version's REZ type event key names have been changed
	func = function() SpeakinSpell:FixOld_32225_EraseOldRezEventHooks() end,
},

{ Version = "3.2.2.26",
	-- my NewEventsDetected has become cluttered with invalid event keys from the past few betas
	func = function() SpeakinSpell:FixOld_32226_FixInvalidEventHooks() end,
},

{ Version = "3.2.2.27",
	-- my NewEventsDetected has become tons of extra DetectedEvent.members in it
	func = function() SpeakinSpell:FixOld_32227_CleanNewEventsDetected() end,
},

{ Version = "3.3.0.02",
	-- wow patch 3.3.0 removed the raid warning channel from 5-man groups
	-- also check for duplicate enter/exit combat events, reported by Dire Lemming
	func = function() SpeakinSpell:FixOld_33002_RaidWarnAndDupEvents() end,
},

{ Version = "3.3.3.01",
	-- previous versions allowed the end-user to enter invalid data into the random substitutions
	-- fix any errors in their old saved data, the way the GUI now validates this
	func = function() SpeakinSpell:FixOld_33301_FixRandomSubs() end,
},

{ Version = "3.3.3.03",
	-- This version added some new options
	func = function() SpeakinSpell:FixOld_33303_NewOptions() end,
},

{ Version = "3.3.3.04",
	-- This version added some new options
	func = function() SpeakinSpell:FixOld_33304_SharedEventTable() end,
	OnlyForAll = true, --no toon-specific changes, alts need not run this patch
},

{ Version = "3.3.3.06",
	-- I removed the white/yellow damage events, which were badly designed
	-- speeches are preserved by converting existing data to /ss macro events
	func = function() SpeakinSpell:FixOld_33306_DeprecateDamageEvents() end,
	OnlyForAll = true, --no toon-specific changes, alts need not run this patch
},

{ Version = "3.3.3.09",
	-- Errors in the patch function for 3.3.3.05 (which was moved to 6)
	-- caused repetitive duplication of the word macro in the converted macro events
	func = function() SpeakinSpell:FixOld_33309_FixMacroMacro() end,
	OnlyForAll = true, --no toon-specific changes, alts need not run this patch
},

{ Version = "3.3.5.01",
	-- Previous versions have been using English event hook lists in non-English game clients
	-- this patch deletes the invalid data (the entire event hook list)
	-- to force non-English clients to learn a new list of valid event hooks
	func = function() SpeakinSpell:FixOld_33501_DeleteNonEnglishEventHooks() end,
	OnlyForAll = true, --no toon-specific changes, alts need not run this patch
},

{ Version = "3.3.5.06",
	-- Bad event keys were introduced by a previous DefaultSpeeches-enUS file
	-- fix Resurrection: Start Casting (I'm the caster) event keys
	func = function() SpeakinSpell:FixOld_33506_FixRezKeys() end,
	OnlyForAll = true, --no toon-specific changes, alts need not run this patch
},

{ Version = "4.0.1.01",
	-- Spell ranks have been removed from the game
	func = function() SpeakinSpell:FixOld_40101_RemoveRanks() end,
	OnlyForAll = false, --SpeakinSpellSavedData.ShowAllRanks is removed from per-user data
},

{ Version = "4.0.3.01",
	-- this universal validation no longer happens during every load,
	-- so I just want to make sure it happens one more time
	func = function() SpeakinSpell:FixOld_40301_ValidateAll() end,
	OnlyForAll = false, --validate per-character data too
},

{ Version = "4.0.3.06",
	-- The SpellIdCache is no longer needed
	func = function() SpeakinSpell:FixOld_40306_RemoveSpellIdCache() end,
	OnlyForAll = true, --the SpellIdCache was shared across all toons
},

{ Version = "4.2.0.02",
	-- Sharing speeches between toons of different races caused a problem
	-- this patch changes the data to fix the problem
	func = function() SpeakinSpell:FixOld_42002_RPLanguage() end,
	OnlyForAll = true,
},

{ Version = "5.1.0.01",
	-- WoW 5.1 removed the BATTLEGROUND chat channel, replaced with new INSTANCE_CHAT
	func = function() SpeakinSpell:FixOld_51001_BGChannel() end,
	OnlyForAll = true,
},

{ Version = "7.2.1.01",
	-- SpeakinSpell 7.2.1.01 removed EventTableEntry.RPLanguageRandomChance
	-- additional languages are now supported and the random chance is an equal distribution
	func = function() SpeakinSpell:FixOld_72101_RPLanguageRandomChance() end,
	OnlyForAll = true,
},

-----------------------------------------------------------------------------------
} -- end Patches


-----------------------------------------------------------------------------------
-- DATA VERSION
-----------------------------------------------------------------------------------
-- the DATA_VERSION is a function of the last patch version defined in the table above
-- used to determine whether patches need to be applied
-- as well as to control compatibility of network communications

SpeakinSpell.DATA_VERSION = SpeakinSpell.Patches[ #(SpeakinSpell.Patches) ].Version


-----------------------------------------------------------------------------------
-- RUN THE PATCHES DEFINED ABOVE
-----------------------------------------------------------------------------------


function SpeakinSpell:RunPatches()
	for i, Patch in ipairs(SpeakinSpell.Patches) do
		if SpeakinSpellSavedData.Version < Patch.Version then -- this toon's first time logging in with this version
			if Patch.OnlyForAll and SpeakinSpellSavedDataForAll.Version >= Patch.Version then
				-- only the DataForAll is effected, and it was already updated
				-- so skip it
			else
				-- apply the patch defined above
				local subs = {
					oldversion = SpeakinSpellSavedData.Version,
					newversion = Patch.Version,
				}
				self:Print( SpeakinSpell:FormatSubs( L["Updating saved data <oldversion> -> <newversion>"], subs) )
				Patch.func()
			end
			SpeakinSpellSavedData.Version = Patch.Version -- patch has been applied
		end
	end
end


-----------------------------------------------------------------------------------
-- PATCH DEBUGGING TRICKS
-----------------------------------------------------------------------------------

-- DEBUG_PATCH enables debugging the latest patch function
-- only if DEVELOPER_MODE is enabled, and with robust testing capabilities
-- see the implementation below
SpeakinSpell.DEBUG_PATCH = false


function SpeakinSpell:SetupPatchDebugging_OneTable( SavedData, message )
	if SavedData.DebugPatchBackup then
		-- a backup exists from a previous patch debugging attempt, so restore it
		
		-- NOTE: this will include the matching/older version number
		--		which will ensure that the new patch function runs again
		--		and that the data it runs on is in the original older version format
		
		local Backup  = SavedData.DebugPatchBackup
		SavedData.DebugPatchBackup = nil
		--Table = self:CopyTable(Backup) -- doesn't seem to replace the table
		-- work within the Table instead
		table.wipe(SavedData)
		for key,data in pairs(Backup) do
			SavedData[key] = data
		end
		self:Print("ApplyPatches DEVELOPER_MODE - restored - "..message.." - backup data version "..tostring(SavedData.Version))
	else
		-- we don't have a backup, so this is the first attempt to debug the newest patch
		-- error check because of a weird problem I'm having...
		if SavedData.Version == SpeakinSpell.DATA_VERSION then
			-- I am intermittently getting a problem where restoring the backup fails
			-- so the next time you reloadui or relog, DebugPatchBackup doesn't exist even though it should
			self:Print("ApplyPatches DEVELOPER_MODE - ERROR! Data - "..message.." - is already up-to-date, don't backup!")
			return
		end
		SavedData.DebugPatchBackup = self:CopyTable(SavedData)
		self:Print("ApplyPatches DEVELOPER_MODE - created - "..message.." - backup data version "..tostring(SavedData.Version))
	end
end


function SpeakinSpell:SetupPatchDebugging()
	if SpeakinSpell.DEVELOPER_MODE then
		if SpeakinSpell.DEBUG_PATCH then
			self:SetupPatchDebugging_OneTable(SpeakinSpellSavedDataForAll, "for all  ")
			self:SetupPatchDebugging_OneTable(SpeakinSpellSavedData,       "this toon")
		else
			-- patch debugging has been turned off
			-- clean up any Backup data from a previous debug session, if it exists
			if SpeakinSpellSavedDataForAll.DebugPatchBackup then
				SpeakinSpellSavedDataForAll.DebugPatchBackup = nil
				self:Print("ApplyPatches DEVELOPER_MODE - deleting - for all   - backup data version "..tosting(SpeakinSpellSavedDataForAll.DebugPatchBackup.Version))
			end
			if SpeakinSpellSavedData.DebugPatchBackup then
				SpeakinSpellSavedData.DebugPatchBackup = nil
				self:Print("ApplyPatches DEVELOPER_MODE - deleting - this toon - backup data version "..tosting(SpeakinSpellSavedDataForAll.DebugPatchBackup.Version))
			end
		end
	end
end


-----------------------------------------------------------------------------------
-- LOAD-ON-DEMAND SUPPORT
-----------------------------------------------------------------------------------


function SpeakinSpell:LoadPatches()
	local loaded, message = LoadAddOn("SpeakinSpell_Patches")
	if not loaded then
		local subs = {
			message = message,
		}
		local format = L[
[[ERROR: SpeakinSpell_Patches could not be loaded on demand
Reason: <message>
Your saved data is out of date from an older version of SpeakinSpell
This may cause additional errors
Please return to the character selection screen and enable the SpeakinSpell_Patches addon]]
		]
		self:Print( self:FormatSubs( format, subs ) )
	end
	return loaded
end


-----------------------------------------------------------------------------------
-- RUN THE PATCH FUNCTIONS
-----------------------------------------------------------------------------------


function SpeakinSpell:ApplyPatches() --globally, i.e. on first time load of a new version
	
	-----------------------------------------------------------------------------------
	-- Load on demand
	-- NOTE: ApplyPatches is only run if it looks like we need it
	--		so ALWAYS load on demand if we get this far
	if not self:LoadPatches() then
		return
	end
	
	-----------------------------------------------------------------------------------
	-- Patch Debugging Support
	self:SetupPatchDebugging()
	
	-----------------------------------------------------------------------------------
	-- Apply all patches
	self:RunPatches()

	-----------------------------------------------------------------------------------
	-- all saved data is now up to date with the current version
	SpeakinSpellSavedData.Version		= SpeakinSpell.DATA_VERSION
	SpeakinSpellSavedDataForAll.Version = SpeakinSpell.DATA_VERSION
end


