
if not(GetLocale() == "esMX") then
    return;
end

local L = LibStub("AceLocale-3.0"):NewLocale("GSE", "esMX")

-- Options translation
--[[Translation missing --]]
L["  The Alternative ClassID is "] = "  The Alternative ClassID is "
--[[Translation missing --]]
L[" Deleted Orphaned Macro "] = " Deleted Orphaned Macro "
--[[Translation missing --]]
L[" from "] = " from "
--[[Translation missing --]]
L[" has been added as a new version and set to active.  Please review if this is as expected."] = " has been added as a new version and set to active.  Please review if this is as expected."
--[[Translation missing --]]
L[" is not available.  Unable to translate sequence "] = " is not available.  Unable to translate sequence "
--[[Translation missing --]]
L[" macros per Account.  You currently have "] = " macros per Account.  You currently have "
--[[Translation missing --]]
L[" macros per character.  You currently have "] = " macros per character.  You currently have "
--[[Translation missing --]]
L[" saved as version "] = " saved as version "
--[[Translation missing --]]
L[" sent"] = " sent"
--[[Translation missing --]]
L[" tried to overwrite the version already loaded from "] = " tried to overwrite the version already loaded from "
--[[Translation missing --]]
L[" was imported as a new macro."] = " was imported as a new macro."
--[[Translation missing --]]
L[" was imported with the following errors."] = " was imported with the following errors."
--[[Translation missing --]]
L[" was updated to new version."] = " was updated to new version."
--[[Translation missing --]]
L[". This version was not loaded."] = ". This version was not loaded."
--[[Translation missing --]]
L["/gs |r to get started."] = "/gs |r to get started."
--[[Translation missing --]]
L["/gs checkmacrosforerrors|r will loop through your macros and check for corrupt macro versions.  This will then show how to correct these issues."] = "/gs checkmacrosforerrors|r will loop through your macros and check for corrupt macro versions.  This will then show how to correct these issues."
--[[Translation missing --]]
L["/gs cleanorphans|r will loop through your macros and delete any left over GS-E macros that no longer have a sequence to match them."] = "/gs cleanorphans|r will loop through your macros and delete any left over GS-E macros that no longer have a sequence to match them."
--[[Translation missing --]]
L["/gs help|r to get started."] = "/gs help|r to get started."
--[[Translation missing --]]
L["/gs listall|r will produce a list of all available macros with some help information."] = "/gs listall|r will produce a list of all available macros with some help information."
--[[Translation missing --]]
L["/gs showspec|r will show your current Specialisation and the SPECID needed to tag any existing macros."] = "/gs showspec|r will show your current Specialisation and the SPECID needed to tag any existing macros."
--[[Translation missing --]]
L["/gs|r again."] = "/gs|r again."
--[[Translation missing --]]
L["/gs|r will list any macros available to your spec.  This will also add any macros available for your current spec to the macro interface."] = "/gs|r will list any macros available to your spec.  This will also add any macros available for your current spec to the macro interface."
--[[Translation missing --]]
L[":|r The Sequence Translator allows you to use GS-E on other languages than enUS.  It will translate sequences to match your language.  If you also have the Sequence Editor you can translate sequences between languages.  The GS-E Sequence Translator is available on curse.com"] = ":|r The Sequence Translator allows you to use GS-E on other languages than enUS.  It will translate sequences to match your language.  If you also have the Sequence Editor you can translate sequences between languages.  The GS-E Sequence Translator is available on curse.com"
--[[Translation missing --]]
L[":|r To get started "] = ":|r To get started "
--[[Translation missing --]]
L[":|r You cannot delete the only copy of a sequence."] = ":|r You cannot delete the only copy of a sequence."
--[[Translation missing --]]
L[":|r Your current Specialisation is "] = ":|r Your current Specialisation is "
--[[Translation missing --]]
L["|cffff0000GS-E:|r Gnome Sequencer - Enhanced Options"] = "|cffff0000GS-E:|r Gnome Sequencer - Enhanced Options"
--[[Translation missing --]]
L["|r Incomplete Sequence Definition - This sequence has no further information "] = "|r Incomplete Sequence Definition - This sequence has no further information "
--[[Translation missing --]]
L["|r.  As a result this macro was not created.  Please delete some macros and reenter "] = "|r.  As a result this macro was not created.  Please delete some macros and reenter "
--[[Translation missing --]]
L["|r.  You can also have a  maximum of "] = "|r.  You can also have a  maximum of "
--[[Translation missing --]]
L["<DEBUG> |r "] = "<DEBUG> |r "
--[[Translation missing --]]
L["<SEQUENCEDEBUG> |r "] = "<SEQUENCEDEBUG> |r "
--[[Translation missing --]]
L["A new version of %s has been added."] = "A new version of %s has been added."
--[[Translation missing --]]
L["A sequence collision has occured. "] = "A sequence collision has occured. "
--[[Translation missing --]]
L["A sequence collision has occured.  Extra versions of this macro have been loaded.  Manage the sequence to determine how to use them "] = "A sequence collision has occured.  Extra versions of this macro have been loaded.  Manage the sequence to determine how to use them "
--[[Translation missing --]]
L["A sequence collision has occured.  Your local version of "] = "A sequence collision has occured.  Your local version of "
--[[Translation missing --]]
L["About"] = "About"
--[[Translation missing --]]
L["About GSE"] = "About GSE"
--[[Translation missing --]]
L["Actions"] = "Actions"
--[[Translation missing --]]
L["Active Version: "] = "Active Version: "
--[[Translation missing --]]
L["Addin Version %s contained versions for the following macros:"] = "Addin Version %s contained versions for the following macros:"
--[[Translation missing --]]
L["All macros are now stored as upper case names.  You may need to re-add your old macros to your action bars."] = "All macros are now stored as upper case names.  You may need to re-add your old macros to your action bars."
--[[Translation missing --]]
L["Alt Keys."] = "Alt Keys."
--[[Translation missing --]]
L["Any Alt Key"] = "Any Alt Key"
--[[Translation missing --]]
L["Any Control Key"] = "Any Control Key"
--[[Translation missing --]]
L["Any Shift Key"] = "Any Shift Key"
--[[Translation missing --]]
L["Are you sure you want to delete %s?  This will delete the macro and all versions.  This action cannot be undone."] = "Are you sure you want to delete %s?  This will delete the macro and all versions.  This action cannot be undone."
--[[Translation missing --]]
L["Arena"] = "Arena"
--[[Translation missing --]]
L["Arena setting changed to Default."] = "Arena setting changed to Default."
--[[Translation missing --]]
L["As GS-E is updated, there may be left over macros that no longer relate to sequences.  This will check for these automatically on logout.  Alternatively this check can be run via /gs cleanorphans"] = "As GS-E is updated, there may be left over macros that no longer relate to sequences.  This will check for these automatically on logout.  Alternatively this check can be run via /gs cleanorphans"
--[[Translation missing --]]
L["Author"] = "Author"
--[[Translation missing --]]
L["Author Colour"] = "Author Colour"
--[[Translation missing --]]
L["Auto Create Class Macro Stubs"] = "Auto Create Class Macro Stubs"
--[[Translation missing --]]
L["Auto Create Global Macro Stubs"] = "Auto Create Global Macro Stubs"
--[[Translation missing --]]
L["Automatically Create Macro Icon"] = "Automatically Create Macro Icon"
--[[Translation missing --]]
L["Available Addons"] = "Available Addons"
--[[Translation missing --]]
L["Belt"] = "Belt"
--[[Translation missing --]]
L["Blizzard Functions Colour"] = "Blizzard Functions Colour"
--[[Translation missing --]]
L["By setting the default Icon for all macros to be the QuestionMark, the macro button on your toolbar will change every key hit."] = "By setting the default Icon for all macros to be the QuestionMark, the macro button on your toolbar will change every key hit."
--[[Translation missing --]]
L["By setting this value the Sequence Editor will show every macro for every class."] = "By setting this value the Sequence Editor will show every macro for every class."
--[[Translation missing --]]
L["By setting this value the Sequence Editor will show every macro for your class.  Turning this off will only show the class macros for your current specialisation."] = "By setting this value the Sequence Editor will show every macro for your class.  Turning this off will only show the class macros for your current specialisation."
--[[Translation missing --]]
L["Cancel"] = "Cancel"
--[[Translation missing --]]
L["CheckMacroCreated"] = "Check Macro Created"
--[[Translation missing --]]
L["Choose import action:"] = "Choose import action:"
--[[Translation missing --]]
L["Choose Language"] = "Choose Language"
--[[Translation missing --]]
L["Classwide Macro"] = "Classwide Macro"
--[[Translation missing --]]
L["Clear"] = "Clear"
--[[Translation missing --]]
L["Clear Common Keybindings"] = "Clear Common Keybindings"
--[[Translation missing --]]
L["Clear Errors"] = "Clear Errors"
--[[Translation missing --]]
L["Clear Keybindings"] = "Clear Keybindings"
--[[Translation missing --]]
L["Close"] = "Close"
--[[Translation missing --]]
L["Close to Maximum Macros.|r  You can have a maximum of "] = "Close to Maximum Macros.|r  You can have a maximum of "
--[[Translation missing --]]
L["Close to Maximum Personal Macros.|r  You can have a maximum of "] = "Close to Maximum Personal Macros.|r  You can have a maximum of "
--[[Translation missing --]]
L["Colour"] = "Colour"
--[[Translation missing --]]
L["Colour and Accessibility Options"] = "Colour and Accessibility Options"
--[[Translation missing --]]
L["Combat"] = "Combat"
--[[Translation missing --]]
L["Command Colour"] = "Command Colour"
--[[Translation missing --]]
L["Completely New GS Macro."] = "Completely New GS Macro."
--[[Translation missing --]]
L["Conditionals Colour"] = "Conditionals Colour"
--[[Translation missing --]]
L["Configuration"] = "Configuration"
--[[Translation missing --]]
L["Continue"] = "Continue"
--[[Translation missing --]]
L["Contributed by: "] = "Contributed by: "
--[[Translation missing --]]
L["Control Keys."] = "Control Keys."
--[[Translation missing --]]
L["Copy this link and open it in a Browser."] = "Copy this link and open it in a Browser."
--[[Translation missing --]]
L["Create a new macro."] = "Create a new macro."
--[[Translation missing --]]
L["Create buttons for Global Macros"] = "Create buttons for Global Macros"
--[[Translation missing --]]
L["Create Icon"] = "Create Icon"
--[[Translation missing --]]
L["Create Macro"] = "Create Macro"
--[[Translation missing --]]
L[ [=[Create or remove a Macro stub in /macro that can be dragged to your action bar so that you can use this macro.
GSE can store an unlimited number of macros however WOW's /macro interface can only store a limited number of macros.]=] ] = [=[Create or remove a Macro stub in /macro that can be dragged to your action bar so that you can use this macro.
GSE can store an unlimited number of macros however WOW's /macro interface can only store a limited number of macros.]=]
--[[Translation missing --]]
L["Creating New Sequence."] = "Creating New Sequence."
--[[Translation missing --]]
L["Debug"] = "Debug"
--[[Translation missing --]]
L["Debug Mode Options"] = "Debug Mode Options"
--[[Translation missing --]]
L["Debug Output Options"] = "Debug Output Options"
--[[Translation missing --]]
L["Debug Sequence Execution"] = "Debug Sequence Execution"
--[[Translation missing --]]
L["Default Import Action"] = "Default Import Action"
--[[Translation missing --]]
L["Default Version"] = "Default Version"
--[[Translation missing --]]
L["Delete"] = "Delete"
--[[Translation missing --]]
L["Delete Icon"] = "Delete Icon"
--[[Translation missing --]]
L["Delete Orphaned Macros on Logout"] = "Delete Orphaned Macros on Logout"
--[[Translation missing --]]
L["Delete this macro.  This is not able to be undone."] = "Delete this macro.  This is not able to be undone."
--[[Translation missing --]]
L[ [=[Delete this verion of the macro.  This can be undone by closing this window and not saving the change.  
This is different to the Delete button below which will delete this entire macro.]=] ] = [=[Delete this verion of the macro.  This can be undone by closing this window and not saving the change.  
This is different to the Delete button below which will delete this entire macro.]=]
--[[Translation missing --]]
L["Delete Version"] = "Delete Version"
--[[Translation missing --]]
L["Different helpTxt"] = "Different helpTxt"
--[[Translation missing --]]
L["Disable"] = "Disable"
--[[Translation missing --]]
L["Disable Sequence"] = "Disable Sequence"
--[[Translation missing --]]
L["Display debug messages in Chat Window"] = "Display debug messages in Chat Window"
--[[Translation missing --]]
L["Don't Translate Sequences"] = "Don't Translate Sequences"
--[[Translation missing --]]
L["Drag this icon to your action bar to use this macro. You can change this icon in the /macro window."] = "Drag this icon to your action bar to use this macro. You can change this icon in the /macro window."
--[[Translation missing --]]
L["Dungeon"] = "Dungeon"
--[[Translation missing --]]
L["Edit"] = "Edit"
--[[Translation missing --]]
L["Edit this macro.  To delete a macro, choose this edit option and then from inside hit the delete button."] = "Edit this macro.  To delete a macro, choose this edit option and then from inside hit the delete button."
--[[Translation missing --]]
L["Editor Colours"] = "Editor Colours"
--[[Translation missing --]]
L["Emphasis Colour"] = "Emphasis Colour"
--[[Translation missing --]]
L["Enable"] = "Enable"
--[[Translation missing --]]
L["Enable Debug for the following Modules"] = "Enable Debug for the following Modules"
--[[Translation missing --]]
L["Enable Mod Debug Mode"] = "Enable Mod Debug Mode"
--[[Translation missing --]]
L["Enable Sequence"] = "Enable Sequence"
--[[Translation missing --]]
L["Enable this option to stop automatically translating sequences from enUS to local language."] = "Enable this option to stop automatically translating sequences from enUS to local language."
--[[Translation missing --]]
L["Error found in version %i of %s."] = "Error found in version %i of %s."
--[[Translation missing --]]
L["Export"] = "Export"
--[[Translation missing --]]
L["Export a Sequence"] = "Export a Sequence"
--[[Translation missing --]]
L["Export this Macro."] = "Export this Macro."
--[[Translation missing --]]
L["Extra Macro Versions of %s has been added."] = "Extra Macro Versions of %s has been added."
--[[Translation missing --]]
L["Filter Macro Selection"] = "Filter Macro Selection"
--[[Translation missing --]]
L["Finished scanning for errors.  If no other messages then no errors were found."] = "Finished scanning for errors.  If no other messages then no errors were found."
--[[Translation missing --]]
L["Format export for WLM Forums"] = "Format export for WLM Forums"
--[[Translation missing --]]
L["FYou cannot delete this version of a sequence.  This version will be reloaded as it is contained in "] = "FYou cannot delete this version of a sequence.  This version will be reloaded as it is contained in "
--[[Translation missing --]]
L["Gameplay Options"] = "Gameplay Options"
--[[Translation missing --]]
L["General"] = "General"
--[[Translation missing --]]
L["General Options"] = "General Options"
--[[Translation missing --]]
L["Global Macros are those that are valid for all classes.  GSE2 also imports unknown macros as Global.  This option will create a button for these macros so they can be called for any class.  Having all macros in this space is a performance loss hence having them saved with a the right specialisation is important."] = "Global Macros are those that are valid for all classes.  GSE2 also imports unknown macros as Global.  This option will create a button for these macros so they can be called for any class.  Having all macros in this space is a performance loss hence having them saved with a the right specialisation is important."
--[[Translation missing --]]
L["Gnome Sequencer: Export a Sequence String."] = "Gnome Sequencer: Export a Sequence String."
--[[Translation missing --]]
L["Gnome Sequencer: Import a Macro String."] = "Gnome Sequencer: Import a Macro String."
--[[Translation missing --]]
L["Gnome Sequencer: Record your rotation to a macro."] = "Gnome Sequencer: Record your rotation to a macro."
--[[Translation missing --]]
L["Gnome Sequencer: Sequence Debugger. Monitor the Execution of your Macro"] = "Gnome Sequencer: Sequence Debugger. Monitor the Execution of your Macro"
--[[Translation missing --]]
L["Gnome Sequencer: Sequence Editor."] = "Gnome Sequencer: Sequence Editor."
--[[Translation missing --]]
L["Gnome Sequencer: Sequence Version Manager"] = "Gnome Sequencer: Sequence Version Manager"
--[[Translation missing --]]
L["Gnome Sequencer: Sequence Viewer"] = "Gnome Sequencer: Sequence Viewer"
--[[Translation missing --]]
L["GnomeSequencer was originally written by semlar of wowinterface.com."] = "GnomeSequencer was originally written by semlar of wowinterface.com."
--[[Translation missing --]]
L["GnomeSequencer-Enhanced"] = "GnomeSequencer-Enhanced"
--[[Translation missing --]]
L["GnomeSequencer-Enhanced loaded.|r  Type "] = "GnomeSequencer-Enhanced loaded.|r  Type "
--[[Translation missing --]]
L["GSE"] = "GSE"
--[[Translation missing --]]
L["GSE allows plugins to load Macro Collections as plugins.  You can reload a collection by pressing the button below."] = "GSE allows plugins to load Macro Collections as plugins.  You can reload a collection by pressing the button below."
--[[Translation missing --]]
L["GS-E can save all macros or only those versions that you have created locally.  Turning this off will cache all macros in your WTF\\GS-Core.lua variables file but will increase load times and potentially cause colissions."] = "GS-E can save all macros or only those versions that you have created locally.  Turning this off will cache all macros in your WTF\\GS-Core.lua variables file but will increase load times and potentially cause colissions."
--[[Translation missing --]]
L["GSE has a LibDataBroker (LDB) data feed.  List Other GSE Users and their version when in a group on the tooltip to this feed."] = "GSE has a LibDataBroker (LDB) data feed.  List Other GSE Users and their version when in a group on the tooltip to this feed."
--[[Translation missing --]]
L["GSE has a LibDataBroker (LDB) data feed.  Set this option to show queued Out of Combat events in the tooltip."] = "GSE has a LibDataBroker (LDB) data feed.  Set this option to show queued Out of Combat events in the tooltip."
--[[Translation missing --]]
L["GSE is a complete rewrite of that addon that allows you create a sequence of macros to be executed at the push of a button."] = "GSE is a complete rewrite of that addon that allows you create a sequence of macros to be executed at the push of a button."
--[[Translation missing --]]
L["GSE is out of date. You can download the newest version from https://mods.curse.com/addons/wow/gnomesequencer-enhanced."] = "GSE is out of date. You can download the newest version from https://mods.curse.com/addons/wow/gnomesequencer-enhanced."
--[[Translation missing --]]
L["GSE Macro"] = "GSE Macro"
--[[Translation missing --]]
L["GS-E Plugins"] = "GS-E Plugins"
--[[Translation missing --]]
L["GSE Users"] = "GSE Users"
--[[Translation missing --]]
L["GSE Version: %s"] = "GSE Version: %s"
--[[Translation missing --]]
L[ [=[GSE was originally forked from GnomeSequencer written by semlar.  It was enhanced by TImothyLuke to include a lot of configuration and boilerplate functionality with a GUI added.  The enhancements pushed the limits of what the original code could handle and was rewritten from scratch into GSE.

GSE itself wouldn't be what it is without the efforts of the people who write macros with it.  Check out https://wowlazymacros.com for the things that make this mod work.  Special thanks to Lutechi for creating this community.]=] ] = [=[GSE was originally forked from GnomeSequencer written by semlar.  It was enhanced by TImothyLuke to include a lot of configuration and boilerplate functionality with a GUI added.  The enhancements pushed the limits of what the original code could handle and was rewritten from scratch into GSE.

GSE itself wouldn't be what it is without the efforts of the people who write macros with it.  Check out https://wowlazymacros.com for the things that make this mod work.  Special thanks to Lutechi for creating this community.]=]
--[[Translation missing --]]
L["GSE: Left Click to open the Sequence Editor"] = "GSE: Left Click to open the Sequence Editor"
--[[Translation missing --]]
L["GS-E: Left Click to open the Sequence Editor"] = "GS-E: Left Click to open the Sequence Editor"
--[[Translation missing --]]
L["GSE: Middle Click to open the Transmission Interface"] = "GSE: Middle Click to open the Transmission Interface"
--[[Translation missing --]]
L["GS-E: Middle Click to open the Transmission Interface"] = "GS-E: Middle Click to open the Transmission Interface"
--[[Translation missing --]]
L["GSE: Right Click to open the Sequence Debugger"] = "GSE: Right Click to open the Sequence Debugger"
--[[Translation missing --]]
L["GS-E: Right Click to open the Sequence Debugger"] = "GS-E: Right Click to open the Sequence Debugger"
--[[Translation missing --]]
L["Head"] = "Head"
--[[Translation missing --]]
L["Help Colour"] = "Help Colour"
--[[Translation missing --]]
L["Help Information"] = "Help Information"
--[[Translation missing --]]
L["Help Link"] = "Help Link"
--[[Translation missing --]]
L["Help URL"] = "Help URL"
--[[Translation missing --]]
L["Heroic"] = "Heroic"
--[[Translation missing --]]
L["Hide Login Message"] = "Hide Login Message"
--[[Translation missing --]]
L["Hide Minimap Icon"] = "Hide Minimap Icon"
--[[Translation missing --]]
L["Hide Minimap Icon for LibDataBroker (LDB) data text."] = "Hide Minimap Icon for LibDataBroker (LDB) data text."
--[[Translation missing --]]
L["Hides the message that GSE is loaded."] = "Hides the message that GSE is loaded."
--[[Translation missing --]]
L["History"] = "History"
--[[Translation missing --]]
L["Icon Colour"] = "Icon Colour"
--[[Translation missing --]]
L["If you load Gnome Sequencer - Enhanced and the Sequence Editor and want to create new macros from scratch, this will enable a first cut sequenced template that you can load into the editor as a starting point.  This enables a Hello World macro called Draik01.  You will need to do a /console reloadui after this for this to take effect."] = "If you load Gnome Sequencer - Enhanced and the Sequence Editor and want to create new macros from scratch, this will enable a first cut sequenced template that you can load into the editor as a starting point.  This enables a Hello World macro called Draik01.  You will need to do a /console reloadui after this for this to take effect."
--[[Translation missing --]]
L["Ignore"] = "Ignore"
--[[Translation missing --]]
L["Import"] = "Import"
--[[Translation missing --]]
L["Import Macro from Forums"] = "Import Macro from Forums"
--[[Translation missing --]]
L["Imported new sequence "] = "Imported new sequence "
--[[Translation missing --]]
L["Incorporate the belt slot into the KeyRelease. This is the equivalent of /use [combat] 5 in a KeyRelease."] = "Incorporate the belt slot into the KeyRelease. This is the equivalent of /use [combat] 5 in a KeyRelease."
--[[Translation missing --]]
L["Incorporate the first ring slot into the KeyRelease. This is the equivalent of /use [combat] 11 in a KeyRelease."] = "Incorporate the first ring slot into the KeyRelease. This is the equivalent of /use [combat] 11 in a KeyRelease."
--[[Translation missing --]]
L["Incorporate the first trinket slot into the KeyRelease. This is the equivalent of /use [combat] 13 in a KeyRelease."] = "Incorporate the first trinket slot into the KeyRelease. This is the equivalent of /use [combat] 13 in a KeyRelease."
--[[Translation missing --]]
L["Incorporate the Head slot into the KeyRelease. This is the equivalent of /use [combat] 1 in a KeyRelease."] = "Incorporate the Head slot into the KeyRelease. This is the equivalent of /use [combat] 1 in a KeyRelease."
--[[Translation missing --]]
L["Incorporate the neck slot into the KeyRelease. This is the equivalent of /use [combat] 2 in a KeyRelease."] = "Incorporate the neck slot into the KeyRelease. This is the equivalent of /use [combat] 2 in a KeyRelease."
--[[Translation missing --]]
L["Incorporate the second ring slot into the KeyRelease. This is the equivalent of /use [combat] 12 in a KeyRelease."] = "Incorporate the second ring slot into the KeyRelease. This is the equivalent of /use [combat] 12 in a KeyRelease."
--[[Translation missing --]]
L["Incorporate the second trinket slot into the KeyRelease. This is the equivalent of /use [combat] 14 in a KeyRelease."] = "Incorporate the second trinket slot into the KeyRelease. This is the equivalent of /use [combat] 14 in a KeyRelease."
--[[Translation missing --]]
L["Inner Loop End"] = "Inner Loop End"
--[[Translation missing --]]
L["Inner Loop Limit"] = "Inner Loop Limit"
--[[Translation missing --]]
L[ [=[Inner Loop Limit controls how many times the Sequence part of your macro executes 
until it goes onto to the PostMacro and then resets to the PreMacro.]=] ] = [=[Inner Loop Limit controls how many times the Sequence part of your macro executes 
until it goes onto to the PostMacro and then resets to the PreMacro.]=]
--[[Translation missing --]]
L["Inner Loop Start"] = "Inner Loop Start"
--[[Translation missing --]]
L["KeyPress"] = "KeyPress"
--[[Translation missing --]]
L["KeyRelease"] = "KeyRelease"
--[[Translation missing --]]
L["Language"] = "Language"
--[[Translation missing --]]
L["Language Colour"] = "Language Colour"
--[[Translation missing --]]
L["Left Alt Key"] = "Left Alt Key"
--[[Translation missing --]]
L["Left Control Key"] = "Left Control Key"
--[[Translation missing --]]
L["Left Mouse Button"] = "Left Mouse Button"
--[[Translation missing --]]
L["Left Shift Key"] = "Left Shift Key"
--[[Translation missing --]]
L["Legacy GS/GSE1 Macro"] = "Legacy GS/GSE1 Macro"
--[[Translation missing --]]
L["Like a /castsequence macro, it cycles through a series of commands when the button is pushed. However, unlike castsequence, it uses macro text for the commands instead of spells, and it advances every time the button is pushed instead of stopping when it can't cast something."] = "Like a /castsequence macro, it cycles through a series of commands when the button is pushed. However, unlike castsequence, it uses macro text for the commands instead of spells, and it advances every time the button is pushed instead of stopping when it can't cast something."
--[[Translation missing --]]
L["Load"] = "Load"
--[[Translation missing --]]
L["Load Sequence"] = "Load Sequence"
--[[Translation missing --]]
L["Local Macro"] = "Local Macro"
--[[Translation missing --]]
L["Macro Collection to Import."] = "Macro Collection to Import."
--[[Translation missing --]]
L["Macro found by the name %sWW%s. Rename this macro to a different name to be able to use it.  WOW has a hidden button called WW that is executed instead of this macro."] = "Macro found by the name %sWW%s. Rename this macro to a different name to be able to use it.  WOW has a hidden button called WW that is executed instead of this macro."
--[[Translation missing --]]
L["Macro Icon"] = "Macro Icon"
--[[Translation missing --]]
L["Macro Import Successful."] = "Macro Import Successful."
--[[Translation missing --]]
L["Macro Reset"] = "Macro Reset"
--[[Translation missing --]]
L["Macro unable to be imported."] = "Macro unable to be imported."
--[[Translation missing --]]
L["Macro Version %d deleted."] = "Macro Version %d deleted."
--[[Translation missing --]]
L["Make Active"] = "Make Active"
--[[Translation missing --]]
L["Manage Versions"] = "Manage Versions"
--[[Translation missing --]]
L["Matching helpTxt"] = "Matching helpTxt"
--[[Translation missing --]]
L["Merge"] = "Merge"
--[[Translation missing --]]
L["MergeSequence"] = "MergeSequence"
--[[Translation missing --]]
L["Middle Mouse Button"] = "Middle Mouse Button"
--[[Translation missing --]]
L["Mouse Button 4"] = "Mouse Button 4"
--[[Translation missing --]]
L["Mouse Button 5"] = "Mouse Button 5"
--[[Translation missing --]]
L["Mouse Buttons."] = "Mouse Buttons."
--[[Translation missing --]]
L["Moved %s to class %s."] = "Moved %s to class %s."
--[[Translation missing --]]
L["Mythic"] = "Mythic"
--[[Translation missing --]]
L["Mythic setting changed to Default."] = "Mythic setting changed to Default."
--[[Translation missing --]]
L["Mythic+"] = "Mythic+"
--[[Translation missing --]]
L["Mythic+ setting changed to Default."] = "Mythic+ setting changed to Default."
--[[Translation missing --]]
L["Neck"] = "Neck"
--[[Translation missing --]]
L["New"] = "New"
--[[Translation missing --]]
L["New Sequence Name"] = "New Sequence Name"
--[[Translation missing --]]
L["No"] = "No"
--[[Translation missing --]]
L["No Active Version"] = "No Active Version"
--[[Translation missing --]]
L["No changes were made to "] = "No changes were made to "
--[[Translation missing --]]
L["No Help Information "] = "No Help Information "
--[[Translation missing --]]
L["No Help Information Available"] = "No Help Information Available"
--[[Translation missing --]]
L["No Sample Macros are available yet for this class."] = "No Sample Macros are available yet for this class."
--[[Translation missing --]]
L["No Sequences present so none displayed in the list."] = "No Sequences present so none displayed in the list."
--[[Translation missing --]]
L["Normal Colour"] = "Normal Colour"
--[[Translation missing --]]
L["Notes and help on how this macro works.  What things to remember.  This information is shown in the sequence browser."] = "Notes and help on how this macro works.  What things to remember.  This information is shown in the sequence browser."
--[[Translation missing --]]
L["Only Save Local Macros"] = "Only Save Local Macros"
--[[Translation missing --]]
L["Opens the GSE Options window"] = "Opens the GSE Options window"
--[[Translation missing --]]
L["openviewer"] = "Open Viewer"
--[[Translation missing --]]
L["Options"] = "Options"
--[[Translation missing --]]
L["Options have been reset to defaults."] = "Options have been reset to defaults."
--[[Translation missing --]]
L["Output"] = "Output"
--[[Translation missing --]]
L["Output the action for each button press to verify StepFunction and spell availability."] = "Output the action for each button press to verify StepFunction and spell availability."
--[[Translation missing --]]
L["Pause"] = "Pause"
--[[Translation missing --]]
L["Paused"] = "Paused"
--[[Translation missing --]]
L["Paused - In Combat"] = "Paused - In Combat"
--[[Translation missing --]]
L["Picks a Custom Colour for emphasis."] = "Picks a Custom Colour for emphasis."
--[[Translation missing --]]
L["Picks a Custom Colour for the Author."] = "Picks a Custom Colour for the Author."
--[[Translation missing --]]
L["Picks a Custom Colour for the Commands."] = "Picks a Custom Colour for the Commands."
--[[Translation missing --]]
L["Picks a Custom Colour for the Mod Names."] = "Picks a Custom Colour for the Mod Names."
--[[Translation missing --]]
L["Picks a Custom Colour to be used for braces and indents."] = "Picks a Custom Colour to be used for braces and indents."
--[[Translation missing --]]
L["Picks a Custom Colour to be used for Icons."] = "Picks a Custom Colour to be used for Icons."
--[[Translation missing --]]
L["Picks a Custom Colour to be used for language descriptors"] = "Picks a Custom Colour to be used for language descriptors"
--[[Translation missing --]]
L["Picks a Custom Colour to be used for macro conditionals eg [mod:shift]"] = "Picks a Custom Colour to be used for macro conditionals eg [mod:shift]"
--[[Translation missing --]]
L["Picks a Custom Colour to be used for Macro Keywords like /cast and /target"] = "Picks a Custom Colour to be used for Macro Keywords like /cast and /target"
--[[Translation missing --]]
L["Picks a Custom Colour to be used for numbers."] = "Picks a Custom Colour to be used for numbers."
--[[Translation missing --]]
L["Picks a Custom Colour to be used for Spells and Abilities."] = "Picks a Custom Colour to be used for Spells and Abilities."
--[[Translation missing --]]
L["Picks a Custom Colour to be used for StepFunctions."] = "Picks a Custom Colour to be used for StepFunctions."
--[[Translation missing --]]
L["Picks a Custom Colour to be used for strings."] = "Picks a Custom Colour to be used for strings."
--[[Translation missing --]]
L["Picks a Custom Colour to be used for unknown terms."] = "Picks a Custom Colour to be used for unknown terms."
--[[Translation missing --]]
L["Picks a Custom Colour to be used normally."] = "Picks a Custom Colour to be used normally."
--[[Translation missing --]]
L["Please wait till you have left combat before using the Sequence Editor."] = "Please wait till you have left combat before using the Sequence Editor."
--[[Translation missing --]]
L["Plugins"] = "Plugins"
--[[Translation missing --]]
L["PostMacro"] = "PostMacro"
--[[Translation missing --]]
L["PreMacro"] = "PreMacro"
--[[Translation missing --]]
L["Prevent Sound Errors"] = "Prevent Sound Errors"
--[[Translation missing --]]
L["Prevent UI Errors"] = "Prevent UI Errors"
--[[Translation missing --]]
L["Print KeyPress Modifiers on Click"] = "Print KeyPress Modifiers on Click"
--[[Translation missing --]]
L["Print to the chat window if the alt, shift, control modifiers as well as the button pressed on each macro keypress."] = "Print to the chat window if the alt, shift, control modifiers as well as the button pressed on each macro keypress."
--[[Translation missing --]]
L["Priority List (1 12 123 1234)"] = "Priority List (1 12 123 1234)"
--[[Translation missing --]]
L["Prompt Samples"] = "Prompt Samples"
--[[Translation missing --]]
L["PVP"] = "PVP"
--[[Translation missing --]]
L["PVP setting changed to Default."] = "PVP setting changed to Default."
--[[Translation missing --]]
L["Raid"] = "Raid"
--[[Translation missing --]]
L["Raid setting changed to Default."] = "Raid setting changed to Default."
--[[Translation missing --]]
L["Random - It will select .... a spell, any spell"] = "Random - It will select .... a spell, any spell"
--[[Translation missing --]]
L["Rank"] = "Rank"
--[[Translation missing --]]
L["Ready to Send"] = "Ready to Send"
--[[Translation missing --]]
L["Received Sequence "] = "Received Sequence "
--[[Translation missing --]]
L["Record"] = "Record"
--[[Translation missing --]]
L["Record Macro"] = "Record Macro"
--[[Translation missing --]]
L["Record the spells and items you use into a new macro."] = "Record the spells and items you use into a new macro."
--[[Translation missing --]]
L["Registered Addons"] = "Registered Addons"
--[[Translation missing --]]
L["Rename New Macro"] = "Rename New Macro"
--[[Translation missing --]]
L["Replace"] = "Replace"
--[[Translation missing --]]
L["Require Target to use"] = "Require Target to use"
--[[Translation missing --]]
L["Reset Macro when out of combat"] = "Reset Macro when out of combat"
--[[Translation missing --]]
L["Reset this macro when you exit combat."] = "Reset this macro when you exit combat."
--[[Translation missing --]]
L["Resets"] = "Resets"
--[[Translation missing --]]
L["Resets macros back to the initial state when out of combat."] = "Resets macros back to the initial state when out of combat."
--[[Translation missing --]]
L["Resume"] = "Resume"
--[[Translation missing --]]
L["Right Alt Key"] = "Right Alt Key"
--[[Translation missing --]]
L["Right Control Key"] = "Right Control Key"
--[[Translation missing --]]
L["Right Mouse Button"] = "Right Mouse Button"
--[[Translation missing --]]
L["Right Shift Key"] = "Right Shift Key"
--[[Translation missing --]]
L["Ring 1"] = "Ring 1"
--[[Translation missing --]]
L["Ring 2"] = "Ring 2"
--[[Translation missing --]]
L["Running"] = "Running"
--[[Translation missing --]]
L["Save"] = "Save"
--[[Translation missing --]]
L["Save the changes made to this macro"] = "Save the changes made to this macro"
--[[Translation missing --]]
L["Seed Initial Macro"] = "Seed Initial Macro"
--[[Translation missing --]]
L["Select Other Version"] = "Select Other Version"
--[[Translation missing --]]
L["Send"] = "Send"
--[[Translation missing --]]
L["Send this macro to another GSE player who is on the same server as you are."] = "Send this macro to another GSE player who is on the same server as you are."
--[[Translation missing --]]
L["Send To"] = "Send To"
--[[Translation missing --]]
L["Sequence"] = "Sequence"
--[[Translation missing --]]
L["Sequence %s saved."] = "Sequence %s saved."
--[[Translation missing --]]
L["Sequence Author set to Unknown"] = "Sequence Author set to Unknown"
--[[Translation missing --]]
L["Sequence Compare"] = "Sequence Compare"
--[[Translation missing --]]
L["Sequence Debugger"] = "Sequence Debugger"
--[[Translation missing --]]
L["Sequence Editor"] = "Sequence Editor"
--[[Translation missing --]]
L["Sequence Name"] = "Sequence Name"
--[[Translation missing --]]
L["Sequence Name %s is in Use. Please choose a different name."] = "Sequence Name %s is in Use. Please choose a different name."
--[[Translation missing --]]
L["Sequence Saved as version "] = "Sequence Saved as version "
--[[Translation missing --]]
L["Sequence specID set to current spec of "] = "Sequence specID set to current spec of "
--[[Translation missing --]]
L["Sequence Viewer"] = "Sequence Viewer"
--[[Translation missing --]]
L["Sequential (1 2 3 4)"] = "Sequential (1 2 3 4)"
--[[Translation missing --]]
L["Set Default Icon QuestionMark"] = "Set Default Icon QuestionMark"
--[[Translation missing --]]
L["Shift Keys."] = "Shift Keys."
--[[Translation missing --]]
L["Show All Macros in Editor"] = "Show All Macros in Editor"
--[[Translation missing --]]
L["Show Class Macros in Editor"] = "Show Class Macros in Editor"
--[[Translation missing --]]
L["Show Global Macros in Editor"] = "Show Global Macros in Editor"
--[[Translation missing --]]
L["Show GSE Users in LDB"] = "Show GSE Users in LDB"
--[[Translation missing --]]
L["Show OOC Queue in LDB"] = "Show OOC Queue in LDB"
--[[Translation missing --]]
L["Source Language "] = "Source Language "
--[[Translation missing --]]
L["Specialisation / Class ID"] = "Specialisation / Class ID"
--[[Translation missing --]]
L["Specialization Specific Macro"] = "Specialization Specific Macro"
--[[Translation missing --]]
L["SpecID/ClassID Colour"] = "SpecID/ClassID Colour"
--[[Translation missing --]]
L["Spell Colour"] = "Spell Colour"
--[[Translation missing --]]
L["Step Function"] = "Step Function"
--[[Translation missing --]]
L["Step Functions"] = "Step Functions"
--[[Translation missing --]]
L["Stop"] = "Stop"
--[[Translation missing --]]
L["Store Debug Messages"] = "Store Debug Messages"
--[[Translation missing --]]
L["Store output of debug messages in a Global Variable that can be referrenced by other mods."] = "Store output of debug messages in a Global Variable that can be referrenced by other mods."
--[[Translation missing --]]
L["String Colour"] = "String Colour"
--[[Translation missing --]]
L["Supporters"] = "Supporters"
--[[Translation missing --]]
L["Talents"] = "Talents"
--[[Translation missing --]]
L["Target"] = "Target"
--[[Translation missing --]]
L["Target language "] = "Target language "
--[[Translation missing --]]
L["Target protection is currently %s"] = "Target protection is currently %s"
--[[Translation missing --]]
L["The author of this macro."] = "The author of this macro."
--[[Translation missing --]]
L["The command "] = "The command "
--[[Translation missing --]]
L["The Custom StepFunction Specified is not recognised and has been ignored."] = "The Custom StepFunction Specified is not recognised and has been ignored."
--[[Translation missing --]]
L["The following people donate monthly via Patreon for the ongoing maintenance and development of GSE.  Their support is greatly appreciated."] = "The following people donate monthly via Patreon for the ongoing maintenance and development of GSE.  Their support is greatly appreciated."
--[[Translation missing --]]
L["The GSE Out of Combat queue is %s"] = "The GSE Out of Combat queue is %s"
--[[Translation missing --]]
L["The GUI has not been loaded.  Please activate this plugin amongst WoW's addons to use the GSE GUI."] = "The GUI has not been loaded.  Please activate this plugin amongst WoW's addons to use the GSE GUI."
--[[Translation missing --]]
L["The Macro Translator will translate an English sequence to your local language for execution.  It can also be used to translate a sequence into a different language.  It is also used for syntax based colour markup of Sequences in the editor."] = "The Macro Translator will translate an English sequence to your local language for execution.  It can also be used to translate a sequence into a different language.  It is also used for syntax based colour markup of Sequences in the editor."
--[[Translation missing --]]
L["The main lines of the macro."] = "The main lines of the macro."
--[[Translation missing --]]
L[ [=[The name of your macro.  This name has to be unique and can only be used for one object.
You can copy this entire macro by changing the name and choosing Save.]=] ] = [=[The name of your macro.  This name has to be unique and can only be used for one object.
You can copy this entire macro by changing the name and choosing Save.]=]
--[[Translation missing --]]
L["The Sample Macros have been reloaded."] = "The Sample Macros have been reloaded."
--[[Translation missing --]]
L["The Sequence Editor can attempt to parse the Sequences, KeyPress and KeyRelease in realtime.  This is still experimental so can be turned off."] = "The Sequence Editor can attempt to parse the Sequences, KeyPress and KeyRelease in realtime.  This is still experimental so can be turned off."
--[[Translation missing --]]
L["The Sequence Editor is an addon for GnomeSequencer-Enhanced that allows you to view and edit Sequences in game.  Type "] = "The Sequence Editor is an addon for GnomeSequencer-Enhanced that allows you to view and edit Sequences in game.  Type "
--[[Translation missing --]]
L[ [=[The step function determines how your macro executes.  Each time you click your macro GSE will go to the next line.  
The next line it chooses varies.  If Random then it will choose any line.  If Sequential it will go to the next line.  
If Priority it will try some spells more often than others.]=] ] = [=[The step function determines how your macro executes.  Each time you click your macro GSE will go to the next line.  
The next line it chooses varies.  If Random then it will choose any line.  If Sequential it will go to the next line.  
If Priority it will try some spells more often than others.]=]
--[[Translation missing --]]
L["The version of this macro that will be used when you enter raids."] = "The version of this macro that will be used when you enter raids."
--[[Translation missing --]]
L["The version of this macro that will be used where no other version has been configured."] = "The version of this macro that will be used where no other version has been configured."
--[[Translation missing --]]
L["The version of this macro to use in Arenas.  If this is not specified, GSE will look for a PVP version before the default."] = "The version of this macro to use in Arenas.  If this is not specified, GSE will look for a PVP version before the default."
--[[Translation missing --]]
L["The version of this macro to use in heroic dungeons."] = "The version of this macro to use in heroic dungeons."
--[[Translation missing --]]
L["The version of this macro to use in Mythic Dungeons."] = "The version of this macro to use in Mythic Dungeons."
--[[Translation missing --]]
L["The version of this macro to use in Mythic+ Dungeons."] = "The version of this macro to use in Mythic+ Dungeons."
--[[Translation missing --]]
L["The version of this macro to use in normal dungeons."] = "The version of this macro to use in normal dungeons."
--[[Translation missing --]]
L["The version of this macro to use in PVP."] = "The version of this macro to use in PVP."
--[[Translation missing --]]
L["The version of this macro to use when in a party in the world."] = "The version of this macro to use when in a party in the world."
--[[Translation missing --]]
L["The version of this macro to use when in time walking dungeons."] = "The version of this macro to use when in time walking dungeons."
--[[Translation missing --]]
L["There are %i events in out of combat queue"] = "There are %i events in out of combat queue"
--[[Translation missing --]]
L["There are no events in out of combat queue"] = "There are no events in out of combat queue"
--[[Translation missing --]]
L["There are No Macros Loaded for this class.  Would you like to load the Sample Macro?"] = "There are No Macros Loaded for this class.  Would you like to load the Sample Macro?"
--[[Translation missing --]]
L["There is an issue with sequence %s.  It has not been loaded to prevent the mod from failing."] = "There is an issue with sequence %s.  It has not been loaded to prevent the mod from failing."
--[[Translation missing --]]
L[ [=[These lines are executed after the lines in the Sequence Box have been repeated Inner Loop Limit number of times.  If an Inner Loop Limit is not set, these are never executed as the sequence will never stop repeating.
The Sequence will then go on to the PreMacro if it exists then back to the Sequence.]=] ] = [=[These lines are executed after the lines in the Sequence Box have been repeated Inner Loop Limit number of times.  If an Inner Loop Limit is not set, these are never executed as the sequence will never stop repeating.
The Sequence will then go on to the PreMacro if it exists then back to the Sequence.]=]
--[[Translation missing --]]
L[ [=[These lines are executed before the lines in the Sequence Box.  If an Inner Loop Limit is not set, these are executed only once.  
If an Inner Loop Limit has been set these are executed after the Sequence has been looped through the number of times.  
The Sequence will then go on to the Post Macro if it exists then back to the PreMacro.]=] ] = [=[These lines are executed before the lines in the Sequence Box.  If an Inner Loop Limit is not set, these are executed only once.  
If an Inner Loop Limit has been set these are executed after the Sequence has been looped through the number of times.  
The Sequence will then go on to the Post Macro if it exists then back to the PreMacro.]=]
--[[Translation missing --]]
L["These lines are executed every time you click this macro.  They are evaluated by WOW after the line in the Sequence Box."] = "These lines are executed every time you click this macro.  They are evaluated by WOW after the line in the Sequence Box."
--[[Translation missing --]]
L["These lines are executed every time you click this macro.  They are evaluated by WOW before the line in the Sequence Box."] = "These lines are executed every time you click this macro.  They are evaluated by WOW before the line in the Sequence Box."
--[[Translation missing --]]
L["These options combine to allow you to reset a macro while it is running.  These options are Cumulative ie they add to each other.  Options Like LeftClick and RightClick won't work together very well."] = "These options combine to allow you to reset a macro while it is running.  These options are Cumulative ie they add to each other.  Options Like LeftClick and RightClick won't work together very well."
--[[Translation missing --]]
L["These tick boxes have three settings for each slot.  Gold = Definately use this item. Blank = Do not use this item automatically.  Silver = Either use or not based on my default settings store in GSE's Options."] = "These tick boxes have three settings for each slot.  Gold = Definately use this item. Blank = Do not use this item automatically.  Silver = Either use or not based on my default settings store in GSE's Options."
--[[Translation missing --]]
L["This change will not come into effect until you save this macro."] = "This change will not come into effect until you save this macro."
--[[Translation missing --]]
L["This function will remove the SHIFT+N, ALT+N and CTRL+N keybindings for this character.  Useful if [mod:shift] etc conditions don't work in game."] = "This function will remove the SHIFT+N, ALT+N and CTRL+N keybindings for this character.  Useful if [mod:shift] etc conditions don't work in game."
--[[Translation missing --]]
L["This function will update macro stubs to support listening to the options below.  This is required to be completed 1 time per character."] = "This function will update macro stubs to support listening to the options below.  This is required to be completed 1 time per character."
--[[Translation missing --]]
L["This is a small addon that allows you create a sequence of macros to be executed at the push of a button."] = "This is a small addon that allows you create a sequence of macros to be executed at the push of a button."
--[[Translation missing --]]
L["This is the only version of this macro.  Delete the entire macro to delete this version."] = "This is the only version of this macro.  Delete the entire macro to delete this version."
--[[Translation missing --]]
L["This option clears errors and stack traces ingame.  This is the equivalent of /run UIErrorsFrame:Clear() in a KeyRelease.  Turning this on will trigger a Scam warning about running custom scripts."] = "This option clears errors and stack traces ingame.  This is the equivalent of /run UIErrorsFrame:Clear() in a KeyRelease.  Turning this on will trigger a Scam warning about running custom scripts."
--[[Translation missing --]]
L["This option dumps extra trace information to your chat window to help troubleshoot problems with the mod"] = "This option dumps extra trace information to your chat window to help troubleshoot problems with the mod"
--[[Translation missing --]]
L["This option hide error sounds like \"That is out of range\" from being played while you are hitting a GS Macro.  This is the equivalent of /console Sound_EnableErrorSpeech lines within a Sequence.  Turning this on will trigger a Scam warning about running custom scripts."] = "This option hide error sounds like \"That is out of range\" from being played while you are hitting a GS Macro.  This is the equivalent of /console Sound_EnableErrorSpeech lines within a Sequence.  Turning this on will trigger a Scam warning about running custom scripts."
--[[Translation missing --]]
L["This option hides text error popups and dialogs and stack traces ingame.  This is the equivalent of /script UIErrorsFrame:Hide() in a KeyRelease.  Turning this on will trigger a Scam warning about running custom scripts."] = "This option hides text error popups and dialogs and stack traces ingame.  This is the equivalent of /script UIErrorsFrame:Hide() in a KeyRelease.  Turning this on will trigger a Scam warning about running custom scripts."
--[[Translation missing --]]
L["This option prevents macros firing unless you have a target. Helps reduce mistaken targeting of other mobs/groups when your target dies."] = "This option prevents macros firing unless you have a target. Helps reduce mistaken targeting of other mobs/groups when your target dies."
--[[Translation missing --]]
L["This Sequence was exported from GSE %s."] = "This Sequence was exported from GSE %s."
--[[Translation missing --]]
L["This shows the Global Macros available as well as those for your class."] = "This shows the Global Macros available as well as those for your class."
--[[Translation missing --]]
L["This version has been modified by TimothyLuke to make the power of GnomeSequencer avaialble to people who are not comfortable with lua programming."] = "This version has been modified by TimothyLuke to make the power of GnomeSequencer avaialble to people who are not comfortable with lua programming."
--[[Translation missing --]]
L["This will display debug messages for the "] = "This will display debug messages for the "
--[[Translation missing --]]
L["This will display debug messages for the GS-E Ingame Transmission and transfer"] = "This will display debug messages for the GS-E Ingame Transmission and transfer"
--[[Translation missing --]]
L["This will display debug messages in the Chat window."] = "This will display debug messages in the Chat window."
--[[Translation missing --]]
L["Timewalking"] = "Timewalking"
--[[Translation missing --]]
L["Timewalking setting changed to Default."] = "Timewalking setting changed to Default."
--[[Translation missing --]]
L["Title Colour"] = "Title Colour"
--[[Translation missing --]]
L["To correct this either delete the version via the GSE Editor or enter the following command to delete this macro totally.  %s/run GSE.DeleteSequence (%i, %s)%s"] = "To correct this either delete the version via the GSE Editor or enter the following command to delete this macro totally.  %s/run GSE.DeleteSequence (%i, %s)%s"
--[[Translation missing --]]
L["To get started "] = "To get started "
--[[Translation missing --]]
L["To use a macro, open the macros interface and create a macro with the exact same name as one from the list.  A new macro with two lines will be created and place this on your action bar."] = "To use a macro, open the macros interface and create a macro with the exact same name as one from the list.  A new macro with two lines will be created and place this on your action bar."
--[[Translation missing --]]
L["Translate to"] = "Translate to"
--[[Translation missing --]]
L["Translated Sequence"] = "Translated Sequence"
--[[Translation missing --]]
L["Trinket 1"] = "Trinket 1"
--[[Translation missing --]]
L["Trinket 2"] = "Trinket 2"
--[[Translation missing --]]
L["Two sequences with unknown sources found."] = "Two sequences with unknown sources found."
--[[Translation missing --]]
L["Unknown Author|r "] = "Unknown Author|r "
--[[Translation missing --]]
L["Unknown Colour"] = "Unknown Colour"
--[[Translation missing --]]
L["Update"] = "Update"
--[[Translation missing --]]
L["Update Macro Stubs"] = "Update Macro Stubs"
--[[Translation missing --]]
L["Update Macro Stubs."] = "Update Macro Stubs."
--[[Translation missing --]]
L["Updated Macro"] = "Updated Macro"
--[[Translation missing --]]
L["UpdateSequence"] = "Update Sequence"
--[[Translation missing --]]
L["Updating due to new version."] = "Updating due to new version."
--[[Translation missing --]]
L["Use"] = "Use"
--[[Translation missing --]]
L["Use Belt Item in KeyRelease"] = "Use Belt Item in KeyRelease"
--[[Translation missing --]]
L["Use First Ring in KeyRelease"] = "Use First Ring in KeyRelease"
--[[Translation missing --]]
L["Use First Trinket in KeyRelease"] = "Use First Trinket in KeyRelease"
--[[Translation missing --]]
L["Use Global Account Macros"] = "Use Global Account Macros"
--[[Translation missing --]]
L["Use Head Item in KeyRelease"] = "Use Head Item in KeyRelease"
--[[Translation missing --]]
L["Use Macro Translator"] = "Use Macro Translator"
--[[Translation missing --]]
L["Use Neck Item in KeyRelease"] = "Use Neck Item in KeyRelease"
--[[Translation missing --]]
L["Use Realtime Parsing"] = "Use Realtime Parsing"
--[[Translation missing --]]
L["Use Second Ring in KeyRelease"] = "Use Second Ring in KeyRelease"
--[[Translation missing --]]
L["Use Second Trinket in KeyRelease"] = "Use Second Trinket in KeyRelease"
--[[Translation missing --]]
L["Use WLM Export Sequence Format"] = "Use WLM Export Sequence Format"
--[[Translation missing --]]
L["Version="] = "Version="
--[[Translation missing --]]
L["Website or forum URL where a player can get more information or ask questions about this macro."] = "Website or forum URL where a player can get more information or ask questions about this macro."
--[[Translation missing --]]
L[ [=[What are the preferred talents for this macro?
'1,2,3,1,2,3,1' means First row choose the first talent, Second row choose the second talent etc]=] ] = [=[What are the preferred talents for this macro?
'1,2,3,1,2,3,1' means First row choose the first talent, Second row choose the second talent etc]=]
--[[Translation missing --]]
L["What class or spec is this macro for?  If it is for all classes choose Global."] = "What class or spec is this macro for?  If it is for all classes choose Global."
--[[Translation missing --]]
L["When creating a macro, if there is not a personal character macro space, create an account wide macro."] = "When creating a macro, if there is not a personal character macro space, create an account wide macro."
--[[Translation missing --]]
L["When exporting a sequence create a stub entry to import for WLM's Website."] = "When exporting a sequence create a stub entry to import for WLM's Website."
--[[Translation missing --]]
L["When GSE imports a macro and it already exists locally and has local edits, what do you want the default action to be.  Merge - Add the new MacroVersions to the existing Macro.  Replace - Replace the existing macro with the new version. Ignore - ignore updates.  This default action will set the default on the Compare screen however if the GUI is not available this will be the action taken."] = "When GSE imports a macro and it already exists locally and has local edits, what do you want the default action to be.  Merge - Add the new MacroVersions to the existing Macro.  Replace - Replace the existing macro with the new version. Ignore - ignore updates.  This default action will set the default on the Compare screen however if the GUI is not available this will be the action taken."
--[[Translation missing --]]
L["When loading or creating a sequence, if it is a global or the macro has an unknown specID automatically create the Macro Stub in Account Macros"] = "When loading or creating a sequence, if it is a global or the macro has an unknown specID automatically create the Macro Stub in Account Macros"
--[[Translation missing --]]
L["When loading or creating a sequence, if it is a macro of the same class automatically create the Macro Stub"] = "When loading or creating a sequence, if it is a macro of the same class automatically create the Macro Stub"
--[[Translation missing --]]
L["When you log into a class without any macros, prompt to load the sample macros."] = "When you log into a class without any macros, prompt to load the sample macros."
--[[Translation missing --]]
L["Yes"] = "Yes"
--[[Translation missing --]]
L["You cannot delete the Default version of this macro.  Please choose another version to be the Default on the Configuration tab."] = "You cannot delete the Default version of this macro.  Please choose another version to be the Default on the Configuration tab."
--[[Translation missing --]]
L["You cannot delete this version of a sequence.  This version will be reloaded as it is contained in "] = "You cannot delete this version of a sequence.  This version will be reloaded as it is contained in "
--[[Translation missing --]]
L["You need to reload the User Interface for the change in StepFunction to take effect.  Would you like to do this now?"] = "You need to reload the User Interface for the change in StepFunction to take effect.  Would you like to do this now?"
--[[Translation missing --]]
L["You need to reload the User Interface to complete this task.  Would you like to do this now?"] = "You need to reload the User Interface to complete this task.  Would you like to do this now?"
--[[Translation missing --]]
L["Your ClassID is "] = "Your ClassID is "
--[[Translation missing --]]
L["Your current Specialisation is "] = "Your current Specialisation is "




