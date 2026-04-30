-- AceLocale silent mode is ALWAYS on by default. AceLocale's default
-- `readmeta` metatable calls geterrorhandler() on missing keys, which
-- causes spurious errors when external code (BugSack, debug helpers
-- calling :ToDebugString() etc.) introspects our L table — and also
-- fires for any source-build run where translations haven't been pulled.
--
-- To opt back into warnings (useful when developing locally to catch
-- missing L["..."] keys), use `/df localewarn` in-game. That swaps the
-- L table's metatable to one that calls geterrorhandler() on misses.
local L = LibStub("AceLocale-3.0"):NewLocale("DandersFrames", "enUS", true, true)
if not L then return end

-- ============================================================
-- ENGLISH SOURCE STRINGS
-- This file serves as the development fallback AND the source
-- for CurseForge localization. At build time, the packager
-- replaces the @localization@ block below with all registered
-- strings from CurseForge.
--
-- To add a new localizable string:
-- 1. Add L["Your String"] = true below (alphabetically)
-- 2. Use L["Your String"] in the code
-- 3. CurseForge discovers it on next build
-- ============================================================

L["    Show Frame Glow"] = true
L["    Show ZZZ Icon"] = true
L["— click to edit"] = true
L[" indicator"] = true
L[" indicators"] = true
L["⚠ Note: Click-through icons will not show tooltips."] = true
L["\"%s\" will be overwritten."] = true
L["%d - %d players"] = true
L["%d binds"] = true
L["%d blacklisted"] = true
L["%d override"] = true
L["%d overrides"] = true
L["%d players"] = true
L["%d-%d players"] = true
L["%s (Copy)"] = true
L["%s (currently %s)"] = true
L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = true
--[[Translation missing --]]
L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = ""
L["%s settings reset to defaults."] = true
L["%sGlobal: 80%s %s— Setting matches global, no override stored%s"] = true
L["%sModified%s %s— Setting differs from global. Click%s %sreset%s %sto revert.%s"] = true
L["(none)"] = true
L["(offline)"] = true
L["(skipped)"] = true
L["[Linked]"] = true
L["[Override]"] = true
L["[Unassigned]"] = true
L["+ Add"] = true
L["+ Add aura"] = true
L["+ Add Indicator"] = true
L["+ Add Layout"] = true
L["+ Add Option"] = true
L["+ Add Step"] = true
L["+ Add Trigger"] = true
L["+ Create Group"] = true
L["+ New"] = true
L["+ New Wizard"] = true
L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = true
--[[Translation missing --]]
L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = ""
L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = true
--[[Translation missing --]]
L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = ""
L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = true
--[[Translation missing --]]
L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = ""
L["0=Auto, Higher=On top of more elements"] = true
L["1"] = true
L["1 = High"] = true
L["1. Open ElvUI config with %s/ec%s"] = true
L["10 = Low"] = true
L["2. Go to %sUnitFrames%s (left sidebar)"] = true
L["20 players (fixed)"] = true
L["3. Click %sGeneral%s at the top"] = true
L["4. Scroll down to %sDisabled Blizzard Frames%s"] = true
L["5. Under %sGroup Units%s, uncheck %sParty%s and %sRaid%s"] = true
L["6. Click the reload button when prompted"] = true
L["A layout with this name already exists in %s"] = true
L["a placed indicator to remove it from the frame"] = true
L["a placed indicator to reposition it on the frame"] = true
L["A profile with this name already exists"] = true
L["A to Z"] = true
L["Abbreviate (K/M)"] = true
L["Above Health Bar"] = true
L["Above Owner"] = true
L["Above Party"] = true
L["Above Raid"] = true
L["Absorb Shield"] = true
L["Absorbs"] = true
L["Actions"] = true
L["Active"] = true
L["Active Bindings"] = true
L["Active Bindings (%d)"] = true
L["ACTIVE INDICATORS"] = true
L["Active:"] = true
L["Actually, disable it"] = true
L["Add"] = true
L["Add #showtooltip"] = true
L["Add /stopcasting"] = true
L["Add Layout"] = true
L["Add New Binding"] = true
L["Add Offline Player"] = true
L[ [=[Add players from the roster
or use quick add buttons]=] ] = true
--[[Translation missing --]]
L[ [=[Add players from the roster
or use quick add buttons]=] ] = ""
L["Additive (ADD)"] = true
L["Advanced"] = true
L["Affected Elements"] = true
L["AFK"] = true
L["AFK Icon"] = true
L["Aggro Highlight"] = true
L["Aggro Settings"] = true
L["Alert if anyone is missing the buff"] = true
L["Alert only if nobody has the buff"] = true
L["Alert When Expiring"] = true
L["All"] = true
L["ALL (AND)"] = true
L["All Buffs"] = true
L["All Debuffs"] = true
L["All Dispellable"] = true
L["All players in a unified grid. Sorting applies raid-wide."] = true
L["ALL triggers must be active"] = true
L["Alpha"] = true
L["Alphabetical"] = true
L["Alphabetical (within class/role)"] = true
L["Always"] = true
L["Always First"] = true
L["Always Green"] = true
L["Always Last"] = true
L["an indicator on the frame to expand its settings"] = true
L["Anchor"] = true
L["Anchor Point"] = true
L["Anchor Position"] = true
L["Anchor To"] = true
L["Animated Border"] = true
L["ANY (OR)"] = true
L["Any Target"] = true
L["ANY trigger activates the effect"] = true
L["Appearance"] = true
L["Apply"] = true
L["Apply to All"] = true
L["Apply to Frames:"] = true
L["Arcane Intellect (Mage)"] = true
L["are secret-tracked"] = true
L["Are you sure?"] = true
L["Arena"] = true
L["Arena header will show using raid1-5 unit IDs"] = true
L["Arena mode %sDISABLED%s"] = true
L["Arena mode %sENABLED%s for testing"] = true
L["Arrange Groups In"] = true
L["Arrange In"] = true
L["Arrange Players In"] = true
L["Attach the handle to the container, the first visible unit, or the last visible unit."] = true
L["Attach To"] = true
L["Attached + Overflow"] = true
L["Attached to Health"] = true
L["Attached to Owner"] = true
L["Aura Blacklist"] = true
L["Aura Data Source"] = true
L["Aura Designer"] = true
L["Aura Designer Alpha"] = true
L["Aura Designer is active alongside Buffs."] = true
L["Aura Designer is disabled"] = true
L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = true
--[[Translation missing --]]
L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = ""
L["Aura Filter Setup"] = true
L["Aura Filters"] = true
L["Auras"] = true
L["Auras Alpha"] = true
L["Auto (%s)"] = true
L["Auto (detect class)"] = true
L["Auto (detect spec)"] = true
L["Auto (detect)"] = true
L["Auto (Spec Default)"] = true
L["Auto Layouts"] = true
L["Auto Layouts is a Raid-only feature. Switch to Raid mode to configure automatic layout switching based on content type and group size."] = true
L["Auto Layouts module not loaded."] = true
L["Auto-add DPS"] = true
L["Auto-add Healers"] = true
L["Auto-add Tanks"] = true
L["Auto-create disabled"] = true
L["Auto-Create Profiles"] = true
L["Auto-create profiles for loadouts"] = true
L["Auto-detect (your class's buff)"] = true
L["Auto-Fit Border to Frame Size"] = true
L["Automatically add players by role when they join your group."] = true
L["Automatically detects player-dispellable debuffs via the RAID_PLAYER_DISPELLABLE filter. Configure the overlay on the Dispel Overlay page."] = true
L["Auto-Populate"] = true
L["Auto-profile \"%s\" activated (%s, %d players)"] = true
L["Auto-profile deactivated (profile deleted)"] = true
L["Auto-profile deactivated, using global settings"] = true
L["Auto-Switch by Spec"] = true
L["Auto-switched to profile: %s"] = true
L["Auto-switching disabled"] = true
L["Available Profiles"] = true
L["A-Z"] = true
L["Back"] = true
L["Back to List"] = true
L["Background"] = true
L["Background Alpha"] = true
L["Background Color"] = true
L["Background Fill"] = true
L["Background Mode"] = true
L["Background Only"] = true
L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = true
--[[Translation missing --]]
L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = ""
L["Background Texture"] = true
L["Bar"] = true
L["Bar Color"] = true
L["Bar Texture"] = true
L["Bars"] = true
L["Battle Shout (Warrior)"] = true
L["Battlegrounds"] = true
L["Before You Enable"] = true
L["Below Health Bar"] = true
L["Below Owner"] = true
L["Below Party"] = true
L["Below Raid"] = true
L["Big Defensives"] = true
L["Bind Action"] = true
L["Bind Item"] = true
L["Bind Spell"] = true
L["Binding Tooltips"] = true
L["Binding:"] = true
L["Bindings only cast their assigned spell"] = true
L["BINDS"] = true
L["Bleed / Enrage"] = true
L["Blend %"] = true
L["Blend Mode"] = true
L["Blessing of the Bronze (Evoker)"] = true
L["Blizzard"] = true
L["Blizzard (Default)"] = true
L["Blizzard Click-Casting"] = true
L["Blizzard Frame Settings"] = true
L["Blizzard Frames"] = true
L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = true
--[[Translation missing --]]
L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = ""
L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = true
--[[Translation missing --]]
L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = ""
L["Border"] = true
L["Border Color"] = true
L["Border Inset"] = true
L["Border Mode:"] = true
L["Border Opacity"] = true
L["Border Scale"] = true
L["Border Size"] = true
L["Border Thickness"] = true
L["Boss Debuffs"] = true
L["Boss Debuffs (Private Auras) are special debuffs that Blizzard hides from addons."] = true
L["Both"] = true
L["Bottom"] = true
L["Bottom Edge"] = true
L["Bottom Left"] = true
L["Bottom Right"] = true
L["Bottom to Top"] = true
L["Bounce"] = true
L["Bound: %s"] = true
L["Branch"] = true
L["Branching Rules"] = true
L["BUFF BLACKLIST"] = true
L["Buff Filters"] = true
L["Buff Icon"] = true
L["Buff Icons"] = true
L["Buff Icons Click-Through"] = true
L["Buff Tooltips"] = true
L["Buffs"] = true
L["Buffs are disabled. Aura Designer is managing your auras."] = true
L["Buffs flagged by Blizzard to show up on raid frames."] = true
L["Buffs flagged to show on raid frames during combat, such as self-cast HoTs."] = true
L["Buffs that can be right-click cancelled."] = true
L["Buffs that cannot be cancelled by the player."] = true
L["Buffs to Check (Manual Mode)"] = true
L["Building: "] = true
L["Built-in Wizards"] = true
L["By Health %"] = true
L["Cancel"] = true
L["Cancel Fade on Dispellable Debuff"] = true
L["Cancelable"] = true
L["Cannot delete Default profile."] = true
L["Cannot disable test mode while frames are unlocked. Lock frames first."] = true
L["Cannot Edit"] = true
L["Cannot enter test mode during combat."] = true
L["Cannot toggle arena mode during combat"] = true
L["Cannot toggle test mode during combat."] = true
L["Cannot unlock - container doesn't exist!"] = true
L["Cannot unlock - failed to create mover frame!"] = true
L["Cannot unlock frames during combat."] = true
L["Cannot use this action in combat."] = true
L["Cast on DOWN"] = true
L["Categories"] = true
L["Category Filters"] = true
L["CC effects like stuns, roots, and incapacitates."] = true
L["Center"] = true
L["Center (Horizontal)"] = true
L["Center (Vertical)"] = true
L["Center of Group"] = true
L["Character"] = true
L["Character Import"] = true
L["Choose how DandersFrames reads aura data for buffs, debuffs, defensives, and dispel detection."] = true
L["Choose Icon"] = true
L["Choose whether to enable the frame border overlay."] = true
L["Choose which groups to display."] = true
L["Clamp Mode"] = true
L["Class"] = true
L["Class Color"] = true
L["Class Color Alpha"] = true
L["Class Colors"] = true
L["Class Filter"] = true
L["Class Power"] = true
L["Class Power Pips"] = true
L["Class Priority"] = true
L["Clear"] = true
L["Clear All"] = true
L["Clear All Bindings"] = true
L["Clear Blizzard Bindings"] = true
L["Clear Log"] = true
L["Click"] = true
L["Click %sEdit Settings%s on a profile to customise it. This takes you to the settings tabs with an editing banner at the top. While editing, any setting you change is stored as an override for that profile only."] = true
L["Click %sExit Editing%s when done. Your overrides are saved to the profile. If you change a setting back to match global, the override is automatically removed."] = true
L["Click a color swatch to open the color picker. These settings are shared across party and raid frames."] = true
L["Click a setting to link it to your wizard"] = true
L["Click item slot to bind"] = true
L["Click macro to bind"] = true
L["Click or drag a spell onto the frame to place it"] = true
L["Click spell to bind"] = true
L["Click to bind..."] = true
L["Click to cycle through steps"] = true
L["Click to edit"] = true
L["Click to edit range"] = true
L["Click to set branch target"] = true
L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = true
--[[Translation missing --]]
L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = ""
L["Click to toggle"] = true
L["Click-cast profile: %s"] = true
L["Click-Casting"] = true
L["Click-Casting Addon Conflict"] = true
L["Click-Through Icons"] = true
L["Clip Border to Frame"] = true
L["Close"] = true
L["Color"] = true
L["Color and opacity of the empty/inactive pips."] = true
L["Color Bar by Duration"] = true
L["Color by Dispel Type"] = true
L["Color by Time"] = true
L["Color by Time Remaining"] = true
L["Color Duration by Time"] = true
L["Color Mode"] = true
L["Color Name Text"] = true
L["Color Picker"] = true
L["Color shown when in combat to indicate the handle is locked."] = true
L["Colors"] = true
L["Column Growth"] = true
L["Column Spacing"] = true
L["Columns"] = true
L["Columns Grow From"] = true
L["Combat"] = true
L["Combat Color"] = true
L["Combat Limitation: All groups will not update with new players that join mid-combat."] = true
L["Combat Limitation: Your group will not update with new players that join mid-combat."] = true
L["Combat Mode"] = true
L["Combat Only"] = true
L["Compatible (%d)"] = true
L["Compatible Bindings"] = true
L["Compatible Only"] = true
L["Confirm"] = true
L["Console"] = true
L["Container"] = true
L["Content type filters configured in Party tab."] = true
L["Content Types"] = true
L["Content:"] = true
L["Controls Blizzard's debuff filtering (affects our display too)."] = true
L["Controls how multiple defensive icons are arranged when using Direct aura mode."] = true
L["Copied %d settings from %s to %s."] = true
L["Copied settings from %s to %s."] = true
L["Copies these settings from %s to %s."] = true
L["Copy"] = true
L["Copy %s Settings"] = true
L["Copy %s settings to %s?"] = true
L["Copy all settings between Party and Raid modes."] = true
L["COPY APPEARANCE FROM"] = true
L["Copy Layout"] = true
L["Copy Settings"] = true
L["Copy Settings to %s"] = true
L["Copy the string below to share this wizard:"] = true
L["Copy this string to share your profile:"] = true
L["Copy To"] = true
L["Copy to Clipboard"] = true
L["Copy to Party"] = true
L["Copy to Raid"] = true
L["Corners Only"] = true
L["Create"] = true
L["Create and manage setup wizards that guide users through configuring addon settings. Wizards can be shared with others via import/export strings."] = true
L["Create Custom Macro"] = true
L["Create Empty"] = true
L["Create Layout"] = true
L["Create layouts below for different player ranges within each content type. Layouts only store settings that %sdiffer%s from your global settings — everything else is inherited automatically."] = true
L["Create Macro"] = true
L["Create New Profile"] = true
L["Create separate frame groups to pin specific players like tanks, healers, or key raid members. Drag players from your group roster to add them."] = true
L["Created new profile: %s"] = true
L["Crowd Control"] = true
L["Current / Max"] = true
L["Current Health"] = true
L["Current Profile"] = true
L["CURRENT STATUS"] = true
L["Currently: Percent. Click for Seconds."] = true
L["Currently: Seconds. Click for Percent."] = true
L["Curse"] = true
L["Cursor"] = true
L["Custom"] = true
L["Custom Border"] = true
L["Custom buff and frame effect indicators"] = true
L["Custom Color"] = true
L["Custom Dead Background"] = true
L["Custom Dispel Colors"] = true
L["Custom Health Color"] = true
L["Custom Macro"] = true
L["Custom Sound Path"] = true
L["Custom Spell ID"] = true
L["Customise"] = true
L["Customize class colors used throughout DandersFrames. Changes apply to health bars, name text, borders, and all other class-colored elements."] = true
L["Customize resource bar colors per power type. Shared across party and raid frames."] = true
L["Cut"] = true
L["Cycle Next CC Profile"] = true
L["Cycle Next Profile"] = true
L["Damage"] = true
L["DandersFrames Auto-Profile Overrides:"] = true
L["Darken Amount"] = true
L["Darken Behind Gradient"] = true
L["Darken Effect"] = true
L["Dashed Border"] = true
L["Dead + In combat: Cast Battle Res (Rebirth, etc.)"] = true
L["Dead + Out of combat: Cast Mass Res or normal Res"] = true
L["Dead Background Color"] = true
L["Dead/Offline Fading"] = true
L["Death Knight"] = true
L["DEBUFF BLACKLIST"] = true
L["Debuff Filters"] = true
L["Debuff Icon"] = true
L["Debuff Icons"] = true
L["Debuff Icons Click-Through"] = true
L["Debuff Tooltips"] = true
L["Debuffs"] = true
L["Debuffs relevant during combat in a raid context."] = true
L["Debuffs relevant in a raid context."] = true
L["Debug"] = true
L["Debug Console"] = true
L["Debug Log Export (Filtered)"] = true
L["Debug logging %s"] = true
L["Debug mode %s"] = true
L["Debug Mode (print to chat)"] = true
L["Deduplication"] = true
L["Default (Slot Order)"] = true
L["Default Frame Level"] = true
L["Default Frame Strata"] = true
L["Default Icon Size"] = true
L["Default Scale"] = true
L["Defensive buffs from other players, like Pain Suppression or Blessing of Sacrifice."] = true
L["Defensive Icon"] = true
L["Defensive Icon Alpha"] = true
L["Defensive Icon Click-Through"] = true
L["Defensive Icon Tooltips"] = true
L["Defensives"] = true
L["Del"] = true
L["Delete"] = true
L["Delete Current Profile"] = true
L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = true
--[[Translation missing --]]
L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = ""
L["Delete Layout"] = true
L["Delete layout \"%s\"?"] = true
L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = true
--[[Translation missing --]]
L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = ""
L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = true
--[[Translation missing --]]
L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = ""
L["Delete Step"] = true
L["Deleted profile: %s"] = true
L["Demon Hunter"] = true
L["Desaturate When Missing"] = true
L["Description"] = true
L["Description (optional)"] = true
L["Dialog"] = true
L["Direct API"] = true
L["Direction"] = true
L["Disable (set to false)"] = true
L["Disable Buffs"] = true
L["Disable in Combat"] = true
L["Disable Overlay"] = true
L["Disable While Mounted"] = true
L["Disable while mounted/flying"] = true
L["Disabled"] = true
L["disabled"] = true
L["Disease"] = true
L["Dispel Detection"] = true
L["Dispel Overlay"] = true
L["Dispel Overlay Alpha"] = true
L["Dispel Type Colors"] = true
L["Dispel Type Icon"] = true
L["Dispellable By Me"] = true
L["Display"] = true
L["Display labels above or beside each raid group."] = true
L["Display Mode"] = true
L["Displays class-specific resources (Holy Power, Chi, Combo Points, Soul Shards, Arcane Charges, Essence) as colored pips on your player frame."] = true
L["Done"] = true
L["Don't show this warning again"] = true
L["Down"] = true
L["DPS"] = true
L["Drag"] = true
L["Drag to reorder groups. Top = first."] = true
L["Drag to reorder. Top = first."] = true
L["Drop on an anchor point to move %s"] = true
L["Drop on an anchor point to place %s"] = true
L["Druid"] = true
L["Dungeons"] = true
L["Duplicate"] = true
L["Duplicate Current"] = true
L["Duplicated profile '%s' to '%s'."] = true
L["Duration"] = true
L["Duration & stack display"] = true
L["Duration Anchor"] = true
L["Duration Color"] = true
L["Duration Font"] = true
L["Duration in seconds for the Pull Timer quick action."] = true
L["Duration Offset X"] = true
L["Duration Offset Y"] = true
L["Duration Outline"] = true
L["Duration Position"] = true
L["Duration Scale"] = true
L["Duration Text"] = true
L["Duration Text Color"] = true
L["Echo to Chat"] = true
L["Edge Glow (All Sides)"] = true
L["Edit"] = true
L["Edit Binding"] = true
L["Edit Copy"] = true
L["Edit Layout Range"] = true
L["Edit Macro"] = true
L["Edit Settings"] = true
L["Edit Steps"] = true
L["Editing"] = true
L["Editing:"] = true
L["Editing: %s"] = true
L["Effects"] = true
L["Ellipsis (...)"] = true
L["Enable"] = true
L["Enable (set to true)"] = true
L["Enable AFK Icon"] = true
L["Enable Aura Designer"] = true
L["Enable Binding Tooltips"] = true
L["Enable Boss Debuffs"] = true
L["Enable Buff Tooltips"] = true
L["Enable Buffs"] = true
L["Enable Class Power Pips"] = true
L["Enable Custom Sorting"] = true
L["Enable Dead Fade"] = true
L["Enable Debuff Tooltips"] = true
L["Enable Debug Logging"] = true
L["Enable Defensive Icon"] = true
L["Enable Defensive Icon Tooltips"] = true
L["Enable Dispel Overlay"] = true
L["Enable Element-Specific Alpha"] = true
L["Enable Expiring Indicators"] = true
L["Enable Frame Border Overlay"] = true
L["Enable Frame Tooltips"] = true
L["Enable Group Labels"] = true
L["Enable Heal Prediction"] = true
L["Enable Health Threshold Fade"] = true
L["Enable Leader Icon"] = true
L["Enable Missing Buff Icon"] = true
L["Enable Offscreen Nameplates"] = true
L["Enable Overlay"] = true
L["Enable Permanent Mover"] = true
L["Enable Personal Targeted Spells"] = true
L["Enable Pet Frames"] = true
L["Enable Phased Icon"] = true
L["Enable Raid Auto-Switching Layouts"] = true
L["Enable Raid Role Icon"] = true
L["Enable Raid Target Icon"] = true
L["Enable Ready Check Icon"] = true
L["Enable Resource Bar"] = true
L["Enable Resurrection Icon"] = true
L["Enable Resurrection Icon Tooltips"] = true
L["Enable Sound Alert"] = true
L["Enable Spec Auto-Switch"] = true
L["Enable Status Text"] = true
L["Enable Summon Icon"] = true
L["Enable Targeted Spells"] = true
L["Enable the checkbox above to use"] = true
L["Enable Vehicle Icon"] = true
L["enabled"] = true
L["Enabled"] = true
L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = true
--[[Translation missing --]]
L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = ""
L["End"] = true
L["END"] = true
L["End (Right/Bottom)"] = true
L["End of Group"] = true
L["Energy"] = true
L["Enter a layout name"] = true
L["Enter a profile name"] = true
L["Enter a spell name above..."] = true
L["Enter any spell ID for range checking. Press Enter to apply. Leave empty to use dropdown selection."] = true
L["Enter name for copy of '%s':"] = true
L["Enter new name for '%s':"] = true
L["Enter new profile name:"] = true
L["Enter WoW texture paths (file extensions are stripped automatically). Leave empty to use DF Icons as fallback."] = true
L["Errors Only"] = true
L["Evoker"] = true
L["Exit Editing"] = true
L["Expire Alert"] = true
L["Expiring"] = true
L["Expiring Alpha"] = true
L["Expiring Alpha Override"] = true
L["Expiring Color"] = true
L["Expiring Color Override"] = true
L["Expiring Indicator"] = true
L["Expiring indicator tracks the trigger with the least time remaining."] = true
L["Expiring indicator tracks the trigger with the most time remaining."] = true
L["Expiring Threshold (%)"] = true
L["Expiring Threshold (seconds)"] = true
L["Export"] = true
L["Export failed. Please try again or check for errors."] = true
L["Export Settings"] = true
L["Export Wizard"] = true
L["External"] = true
L["External Defensives"] = true
L["Fade frames or elements when a unit's health is above the set threshold (e.g. 100% or 80%)."] = true
L["Fading"] = true
L["Fill Color"] = true
L["Fill Direction"] = true
L["Fill Pulsate"] = true
L["Finish"] = true
L["First question"] = true
L["First Unit"] = true
L["Fixed at 20 players (Mythic)"] = true
L["Flat Grid Settings"] = true
L["Floating Bar"] = true
L["Floating Bar Anchor"] = true
L["Floating Bar Position"] = true
L["Focus"] = true
L["Font"] = true
L["Font Outline"] = true
L["Font Settings"] = true
L["Font settings for icons displayed as text (Summon, Res, AFK, etc.)"] = true
L["Font Size"] = true
L["For items/macros that need @cursor, @mouseover, etc. Consumes the keybind and prevents action bar use."] = true
L["For nameplates & world units. %sDoes not work with action bar binds.%s"] = true
L["Frame"] = true
L["Frame Alpha"] = true
L["Frame Alpha (Above Threshold)"] = true
L["Frame Alpha (Out of Range)"] = true
L["Frame Border Overlay"] = true
L["Frame Display"] = true
L["Frame Growth"] = true
L["Frame Height"] = true
L["Frame Level"] = true
L["Frame Level Offset"] = true
L["Frame opacity when health is above the threshold."] = true
L["Frame Padding"] = true
L["FRAME PREVIEW"] = true
L["Frame Scale"] = true
L["Frame Size"] = true
L["Frame Spacing"] = true
L["Frame Strata"] = true
L["Frame Tooltips"] = true
L["Frame Width"] = true
L["FRAME-LEVEL EFFECTS"] = true
L["Frames centered on screen."] = true
L["Frames Grow From"] = true
L["Frames locked."] = true
L["Frames unlocked. Drag to move, right-click to lock."] = true
L["Frames: %s"] = true
L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = true
--[[Translation missing --]]
L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = ""
L["FrameSort Integration"] = true
L["Friendly Only"] = true
L["Full Frame"] = true
L["Fully Combat Safe: Frames will update normally during combat."] = true
L["Fury"] = true
L["G1"] = true
L["Game Default"] = true
L["Gap Between Pips"] = true
L["General"] = true
L["General Import"] = true
L["Generate Export String"] = true
L["Gets its own independent border overlay. Multiple custom borders can be visible at the same time."] = true
L["Global"] = true
L["Global Font Settings"] = true
L["Global Fonts"] = true
L["Global Keybind:"] = true
L["Glow"] = true
L["Glow (ADD)"] = true
L["Glow Alpha"] = true
L["Glow Color"] = true
L["Glow Style"] = true
L["Go Back"] = true
L["Goes to: %s"] = true
L["Gradient"] = true
L["Gradient Color Alpha"] = true
L["Gradient Intensity"] = true
L["Gradient Opacity"] = true
L["Gradient Position"] = true
L["Gradient Size"] = true
L["Grid"] = true
L["Grid Layout"] = true
L["Group"] = true
L["Group 1"] = true
L["Group Display Order"] = true
L["Group Labels"] = true
L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = true
--[[Translation missing --]]
L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = ""
L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = true
--[[Translation missing --]]
L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = ""
L["Group Layout Settings"] = true
L["GROUP NAME"] = true
L["Group Position"] = true
L["Group Roster"] = true
L["Group Settings"] = true
L["Group Spacing"] = true
L["Group Visibility"] = true
L["Group X Offset"] = true
L["Group Y Offset"] = true
L["Groups Grow From"] = true
L["Groups Per Column"] = true
L["Groups Per Row"] = true
L["Growth"] = true
L["GROWTH"] = true
L["Growth Direction"] = true
L["GUI reset to default size, scale, and position."] = true
L["Guided setup for configuring which buffs and debuffs appear on your frames."] = true
L["Guided setup for the frame border overlay that highlights boss debuffs."] = true
L["Handle Color"] = true
L["Handle Height"] = true
L["Handle is invisible until you hover over it. Fades in and out smoothly."] = true
L["Handle Position"] = true
L["Handle Width"] = true
L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = true
--[[Translation missing --]]
L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = ""
L["Having trouble with buffs or debuffs? Run the setup wizard for guided help."] = true
L["Heal Absorb"] = true
L["Heal Prediction"] = true
L["Heal Prediction Color"] = true
L["Healer"] = true
L["Healers"] = true
L["Health"] = true
L["Health Bar"] = true
L["Health Bar Alpha"] = true
L["Health Bar Color"] = true
L["Health Bar Texture"] = true
L["Health Deficit"] = true
L["Health Format"] = true
L["Health Gradient"] = true
L["Health Text"] = true
L["Health Text Alpha"] = true
L["Health Text Anchor"] = true
L["Health Text Color"] = true
L["Health Threshold (%)"] = true
L["Health Threshold Fading"] = true
L["Health X Offset"] = true
L["Health Y Offset"] = true
L["Height"] = true
L["Height / Thickness"] = true
L["Here's what we'll set up:"] = true
L["Hidden"] = true
L["Hide % Symbol"] = true
L["Hide Above (seconds)"] = true
L["Hide Above Threshold"] = true
L["Hide Blizzard Party Frames"] = true
L["Hide Blizzard Player Frame"] = true
L["Hide Blizzard Raid Frames"] = true
L["Hide buffs from the buff bar when they are already displayed by the Defensive Bar or Aura Designer."] = true
L["Hide Cooldown Swipe"] = true
L["Hide duplicate buffs"] = true
L["Hide Duration Above Threshold"] = true
L["Hide Icon (Text Only)"] = true
L["Hide in Combat"] = true
L["Hide raid buffs from buff bar"] = true
L["Hide Self from Party Frames"] = true
L["Hide specific buffs and debuffs from your frames. Click a spell to toggle blacklisting. Blacklisted auras will not appear on buff bars or Aura Designer indicators."] = true
L["Hide Tooltip on Mouseover"] = true
L["Hides Blizzard frames but keeps them active for aura filtering."] = true
L["Hides the default Blizzard player portrait and health bar."] = true
L["Hides the handle during combat. If disabled, the handle changes color to indicate it is locked."] = true
L["High"] = true
L["High Health (100%)"] = true
L["High Threat (Yellow)"] = true
L["Higher values render the bar above other elements. Frame border is at level 10."] = true
L["Highest Threat (Orange)"] = true
L["Highlight"] = true
L["Highlight Color"] = true
L["Highlight Dispellable"] = true
L["Highlight for User"] = true
L["Highlight for user to configure"] = true
L["Highlight Important Spells"] = true
L["Highlight Settings"] = true
L["Highlight Settings (comma-separated dbKeys)"] = true
L["Highlight Style"] = true
L["Highlighted Units"] = true
L["Highlights"] = true
L["Highlights: %s"] = true
L["Horizontal"] = true
L["Horizontal anchors lay pips left-to-right. Left/Right anchors stack pips vertically along the frame side."] = true
L["Horizontal Spacing"] = true
L["Horizontal: Players stack vertically, groups grow left-to-right."] = true
L["Hostile Only"] = true
L["Hover Highlight"] = true
L["Hover Settings"] = true
L["How it works"] = true
L["How often to check range (seconds). Lower = more responsive but higher CPU. Default: 0.5s"] = true
L["How would you like to configure the filters?"] = true
L["HP"] = true
L["Hunter"] = true
L["I understand, enable it"] = true
L["I, II, III..."] = true
L["Icon"] = true
L["Icon Height"] = true
L["Icon Offset X"] = true
L["Icon Offset Y"] = true
L["Icon Opacity"] = true
L["Icon Position"] = true
L["Icon Ratio"] = true
L["Icon Size"] = true
L["Icon size, scale & border"] = true
L["Icon Spacing"] = true
L["Icon Style"] = true
L["Icon Width"] = true
L["Icons"] = true
L["Icons Alpha"] = true
L["Icons Per Row"] = true
L["Ignore"] = true
L["Ignore Full Health Fade"] = true
L["Import"] = true
L["Import All"] = true
L["Import All (%d)"] = true
L["Import Buffs Tab Defaults"] = true
L["Import Click Casting Profile"] = true
L["Import failed"] = true
L["Import from Buffs Tab"] = true
L["Import Selected"] = true
L["Import Settings"] = true
L["Import String"] = true
L["Import Wizard"] = true
L["Import WoW Macros"] = true
L["Import your existing Buffs tab settings as defaults for all auras. Compatible settings will be applied automatically."] = true
L["Import/Export"] = true
L["Important Spells"] = true
L["Important Spells Only"] = true
L["Imported Profile"] = true
L["Imported!"] = true
L["In Combat Only"] = true
L["In Direct mode, all active big and external defensives are shown per unit (not just one). Adjust max count and layout on the Defensive Icon page."] = true
L["Incompatible Bindings"] = true
L["Indicators"] = true
L["INFERRED TRACKING"] = true
L["Info (All)"] = true
L["Inherit (Frame)"] = true
L["Insanity"] = true
L["Inset"] = true
L["Inside (Bottom)"] = true
L["Inside (Top)"] = true
L["Instanced / PvP"] = true
L["Integration"] = true
L["Integration (advanced):"] = true
L["Integrations"] = true
L["Interrupt Settings"] = true
L["Interrupted Visual"] = true
L["is secret-tracked"] = true
L["Items"] = true
L["Join a raid group (2-5 players works best)"] = true
L["Keep Buffs"] = true
L["Keep when offline/left"] = true
L["Label Color"] = true
L["Label Format"] = true
L["Label Name"] = true
L["Label Position"] = true
L["Label:"] = true
L["Last Unit"] = true
L["Layout"] = true
L["Layout (Direct Mode)"] = true
L["Layout Direction"] = true
L["Layout Group"] = true
L["Layout Groups"] = true
L["Layout Mode"] = true
L["Layout Name"] = true
L["Layout:"] = true
L["Leader Icon"] = true
L["Left"] = true
L["Left Click"] = true
L["Left Edge"] = true
L["Left of Health Bar"] = true
L["Left of Owner"] = true
L["Left of Party"] = true
L["Left of Raid"] = true
L["Left to Right"] = true
L["Left-click to add/edit binding"] = true
L["Left-click: Bind"] = true
L["Let Masque Control Aura Borders"] = true
L["Let me configure it myself"] = true
L["Line"] = true
L["Link: %s"] = true
L["Linked Settings"] = true
L["List"] = true
L["Loading..."] = true
L["LOADOUT ASSIGNMENTS"] = true
L["Loadout expects: %s"] = true
L["Lock"] = true
L["Lock Frames"] = true
L["Lock Position"] = true
L["Log Viewer"] = true
L["Loop Interval (sec)"] = true
L["Low"] = true
L["Low Health (0%)"] = true
L["Lunar Power"] = true
L["Macro Options:"] = true
L["Macro Text:"] = true
L["Macros"] = true
L["Mage"] = true
L["Magic"] = true
L["Major defensive cooldowns like Divine Shield, Ice Block, or Barkskin."] = true
L["Make icons click-through for external click-casting addons. Not needed for DF built-in click-casting."] = true
L["Makes this binding work everywhere, consuming the keybind."] = true
L["Mana"] = true
L["Manage"] = true
L["Manage Profiles"] = true
L["Marching Ants"] = true
L["Mark of the Wild (Druid)"] = true
L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = true
--[[Translation missing --]]
L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = ""
L["Masque Integration"] = true
L["Match Frame Height"] = true
L["Match Frame Width"] = true
L["Match Health Bar Width/Height"] = true
L["Match Owner Height"] = true
L["Match Owner Width"] = true
L["Matched (not applied)"] = true
L["Max Buffs"] = true
L["Max Debuffs"] = true
L["Max Health"] = true
L["Max Icons"] = true
L["Max Length (0=off)"] = true
L["Max Log Entries"] = true
L["Max Name Length"] = true
L["Max Slots"] = true
L["Medium"] = true
L["Medium Health (50%)"] = true
L["Melee DPS"] = true
L["MEMBERS"] = true
L["Min Stacks to Show"] = true
L["Minimum Log Level"] = true
L["Missing Buff Alpha"] = true
L["Missing Buffs"] = true
L["Missing Health"] = true
L["Missing Health Alpha"] = true
L["Missing Health Color"] = true
L["Missing Health Only"] = true
L["Missing Health Texture"] = true
L["Mode"] = true
L["Modified"] = true
L["Monk"] = true
L["Monochrome"] = true
L["Moves the glow to the opposite side (no HP side instead of max HP side)."] = true
L["Multi Select"] = true
L["My Group First"] = true
L["My Wizards"] = true
L["Mythic"] = true
L["Mythic has fixed range"] = true
L["Name"] = true
L["Name Alpha"] = true
L["Name already exists"] = true
L["Name Anchor"] = true
L["Name Color"] = true
L["Name Text"] = true
L["Name Text Alpha"] = true
L["Name Text Color"] = true
L["Name X Offset"] = true
L["Name Y Offset"] = true
L["Name:"] = true
L["New"] = true
L["New Binding"] = true
L["New Feature: Frame Border Overlay"] = true
L["New Option"] = true
L["New question"] = true
L["Next"] = true
L["No"] = true
L["No %s effects configured."] = true
L["No action selected"] = true
L["No auto-profile is currently active or being edited."] = true
L["no branch"] = true
L["No built-in wizards available yet. Check back after updates!"] = true
L["No changelog available."] = true
L["No custom wizards yet. Click 'New Wizard' to create one!"] = true
L["No data to export"] = true
L["No default profile set"] = true
L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = true
--[[Translation missing --]]
L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = ""
L["No item equipped"] = true
L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = true
--[[Translation missing --]]
L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = ""
L["No layout set. Using global settings."] = true
L["No loadout detected"] = true
L["No macros match the current filter."] = true
L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = true
--[[Translation missing --]]
L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = ""
L["No members yet"] = true
L["No saved position to reset to."] = true
L["No sound file selected. Choose a sound from the dropdown or enter a custom path."] = true
L["No spells available for this class"] = true
L["No thanks"] = true
L["No wizard selected. Go to 'My Wizards' tab to select or create a wizard first."] = true
L["None"] = true
L["None (no clamping)"] = true
L["None / Physical"] = true
L["None active (using global settings)"] = true
L["Normal (BLEND)"] = true
L["Not Cancelable"] = true
L["Not in a raid group"] = true
L["Not Set"] = true
L["Note: Cmd + Left Click unavailable on Mac"] = true
L["Note: Font sizes are not changed. Adjust sizes in each element's page."] = true
L["Notice"] = true
L["Off"] = true
L["Offset X"] = true
L["Offset Y"] = true
L["OK"] = true
L["Only changed settings will be saved"] = true
L["Only Dispellable Debuffs"] = true
L["Only My Buffs"] = true
L["Only show buffs that you cast. Applies to all buff filters."] = true
L["Only Show When Tanking"] = true
L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = true
--[[Translation missing --]]
L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = ""
L["OOC"] = true
L["Open Aura Designer"] = true
L["Open Cast History"] = true
L["Open Settings"] = true
L["Open Settings Tab"] = true
L["Open the Profiles tab to manage profiles"] = true
L["Open Unit Menu"] = true
L["Open World"] = true
L["Opens tab: %s"] = true
L["Option A"] = true
L["Option B"] = true
L["Options"] = true
L["Options:    [S] = Link Setting    [->] = Branch    [x] = Delete"] = true
L["Or enter Icon ID:"] = true
L["Orientation"] = true
L["Other"] = true
L["Other (%d)"] = true
L["Other Frames"] = true
L["Out of combat"] = true
L["Out of Combat Only"] = true
L["Out of Range"] = true
L["Outline"] = true
L["Overlaps with \"%s\""] = true
L["Overlaps with \"%s\" (%d-%d)"] = true
L["Overlay (on health bar)"] = true
L["Overridden by Auto Layout"] = true
L["Overridden in this layout"] = true
L["Override Details"] = true
L["Owner's Class Color"] = true
L["Paladin"] = true
L["Parse String"] = true
L["Party"] = true
L["PARTY"] = true
L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = true
--[[Translation missing --]]
L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = ""
L["Party to Raid"] = true
L["Party: %s"] = true
L["Paste a profile string to import:"] = true
L["Paste the wizard export string below:"] = true
L["Pattern:"] = true
L["Per-aura overrides"] = true
L["Percent"] = true
L["Percentage"] = true
L["Permanent Mover"] = true
L["Per-setting reset is not available for Aura Designer"] = true
L["Persist (sec)"] = true
L["Personal Targeted"] = true
L["Personal Targeted Spells"] = true
L["Pet Frame Settings"] = true
L["Pet Frames"] = true
L["Pet frames are grouped together in a separate container."] = true
L["Pet frames are positioned relative to their owner's frame."] = true
L["Pet Spacing"] = true
L["Phased"] = true
L["Phased Icon"] = true
L["Picked setting: %s%s%s from tab %s%s%s"] = true
L["Pinned Frames"] = true
L["Pip Color"] = true
L["Pip Height"] = true
L["Pixel-Perfect Scaling"] = true
L["Place %s at %s"] = true
L["Placed"] = true
L["PLACED ON FRAME"] = true
L["PLACEMENT"] = true
L["Player Range"] = true
L["Players Grow From"] = true
L["Players Per Column"] = true
L["Players Per Row"] = true
L["Please enter a profile name."] = true
L["Please select an action!"] = true
L["Poison"] = true
L["Position"] = true
L["Position & anchors"] = true
L["Position managed by: %s"] = true
L["Position reset."] = true
L["Power Bar Alpha"] = true
L["Power Word: Fortitude (Priest)"] = true
L["Pre-configure players before they join the group"] = true
L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = true
--[[Translation missing --]]
L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = ""
L["Press Ctrl+A to select all, then Ctrl+C to copy"] = true
L["Press Ctrl+C to copy, then Escape to close"] = true
L["Press key/click/scroll..."] = true
L["Preview"] = true
L["Preview Scale"] = true
L["Preview Sound"] = true
L["Preview:"] = true
L["Priest"] = true
L["Priority"] = true
L["Priority:"] = true
L["Private Aura Overlay Setup"] = true
L["Profile \"%s\" has no overrides."] = true
L["Profile '%s' already exists."] = true
L["Profile Actions"] = true
L["Profile imported successfully!"] = true
L["Profile matched to loadout"] = true
L["Profile Name"] = true
L["Profile not found"] = true
L["Profile Settings"] = true
L["Profile:"] = true
L["Profile: %s"] = true
L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = true
--[[Translation missing --]]
L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = ""
L["Profiles"] = true
L["Pull Timer"] = true
L["Pull Timer Duration"] = true
L["Pulsate"] = true
L["Pulsate Border"] = true
L["Pulse"] = true
L["Pulse Animation"] = true
L["Question"] = true
L["Question:"] = true
L["Quick Bind"] = true
L["Quick Bind Mode"] = true
L["Quick Macro"] = true
L["Quick Macro Builder"] = true
L["Quick Switch CC Profile"] = true
L["Quick Switch Profile"] = true
L["Rage"] = true
L["Raid"] = true
L["RAID"] = true
L["Raid Auto Layouts"] = true
L["Raid Buffs"] = true
L["Raid Debuffs"] = true
L["Raid frames centered."] = true
L["Raid Group Labels"] = true
L["Raid In Combat"] = true
L["Raid Layout Mode"] = true
L["Raid position reset."] = true
L["Raid Role (MT/MA)"] = true
L["Raid Role Icon (MT/MA)"] = true
L["Raid Target Icon"] = true
L["Raid to Party"] = true
L["Raid: %s"] = true
L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = true
--[[Translation missing --]]
L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = ""
L["Raids"] = true
L["Raids, battlegrounds (1-40)"] = true
L["Range Check Interval"] = true
L["Range Check Spell"] = true
L["Ranged DPS"] = true
L["Ready Check"] = true
L["Ready Check Icon"] = true
L["Ready to copy"] = true
L["Recovered %d raid settings from interrupted auto layout editing session."] = true
L["Refresh"] = true
L["Reload UI"] = true
L["Remove all bindings from the current profile."] = true
L["Remove Offline"] = true
L["Removes all Aura Designer overrides from this auto layout, restoring it to match your global profile."] = true
L["Removes your player frame from the DandersFrames party display."] = true
L["Rename"] = true
L["Replace"] = true
L["Replace Blizzard's color picker with the DandersFrames color picker for this addon."] = true
L["Replace Buffs"] = true
L["Res + Mass"] = true
L["Res + Mass + Combat"] = true
L["Reset"] = true
L["Reset All Aura Configs"] = true
L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = true
--[[Translation missing --]]
L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = ""
L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = true
--[[Translation missing --]]
L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = ""
L["Reset All to Default"] = true
L["Reset Aura Designer to Global"] = true
L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = true
--[[Translation missing --]]
L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = ""
L["Reset Position"] = true
L["Reset Profile to Defaults"] = true
L["Reset to Defaults"] = true
L["Reset to Global"] = true
L["Reset to Global Order"] = true
L["Resource Bar"] = true
L["Resource Bar Settings"] = true
L["Resource Colors"] = true
L["Rested Indicator"] = true
L["Resurrection"] = true
L["Resurrection Icon"] = true
L["Resurrection Icon Tooltips"] = true
L["Reverse Fill"] = true
L["Reverse Fill Direction"] = true
L["Reverse Order"] = true
L["Reverse Overlay Fill"] = true
L["Reverse Position"] = true
L["Right"] = true
L["Right Click"] = true
L["Right Edge"] = true
L["Right of Health Bar"] = true
L["Right of Owner"] = true
L["Right of Party"] = true
L["Right of Raid"] = true
L["Right to Left"] = true
L["Right-click"] = true
L["Right-click: Edit/View"] = true
L["Rogue"] = true
L["Role Icon"] = true
L["Role Priority"] = true
L["Row Spacing"] = true
L["Rows"] = true
L["Rows Grow From"] = true
L["Run"] = true
L["Run Overlay Setup Wizard"] = true
L["Run Script"] = true
L["Run Setup Wizard"] = true
L["Runic Power"] = true
L["Runtime"] = true
L["Save"] = true
L["Save & Close"] = true
L["Save Changes"] = true
L["Scale"] = true
L["Script Runner"] = true
L["Search fonts..."] = true
L["Search sounds..."] = true
L["Search spells..."] = true
L["Search textures..."] = true
L["Search..."] = true
L["Seconds"] = true
L["See Also:"] = true
L["Select a destination"] = true
L["Select a spell"] = true
L["Select a step to edit"] = true
L["Select All Text"] = true
L["Select any tab"] = true
L["Select Class"] = true
L["Select indicator..."] = true
L["Select or create a wizard"] = true
L["Select trigger for %s"] = true
L["Select which spell to use for range checking. Auto will use your spec's default healing/friendly spell."] = true
L["Select..."] = true
L["Selected: %d"] = true
L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = true
--[[Translation missing --]]
L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = ""
L["Selection Highlight"] = true
L["Selection Settings"] = true
L["Self Position"] = true
L["Separate Melee & Ranged DPS"] = true
L["Separate Pet Group"] = true
L["Set a font and outline style, then click Apply to update ALL text elements."] = true
L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = true
L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = true
--[[Translation missing --]]
L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = ""
--[[Translation missing --]]
L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = ""
L["Settings"] = true
L["Settings to Apply"] = true
L["Setup Wizards"] = true
L["Shadow"] = true
L["Shadow Color"] = true
L["Shadow Settings"] = true
L["Shadow settings are controlled in General > Global Fonts."] = true
L["Shadow X Offset"] = true
L["Shadow Y Offset"] = true
L["Shaman"] = true
L["Shared"] = true
L["Shared Border"] = true
L["Shift+Left Click"] = true
L["Shift+Right Click"] = true
L["Show a pulsing yellow glow around the frame."] = true
L["Show All Roles Out of Combat"] = true
L["Show as Text"] = true
L["Show Background"] = true
L["Show Border"] = true
L["Show Buffs"] = true
L["Show Cooldown Swipe"] = true
L["Show Debuffs"] = true
L["Show Dispel Icon"] = true
L["Show DPS"] = true
L["Show Duration"] = true
L["Show Duration Numbers"] = true
L["Show Duration Text"] = true
L["Show every buff with no filtering."] = true
L["Show every debuff with no filtering."] = true
L["Show Expiring Border"] = true
L["Show Expiring Tint"] = true
L["Show for Roles"] = true
L["Show Frame Border"] = true
L["Show Gradient"] = true
L["Show Group Label"] = true
L["Show Healer"] = true
L["Show health bars for player and party/raid member pets, anchored to their owner's frame. Pet frames hide when owner dies."] = true
L["Show Health Percentage"] = true
L["Show in content types:"] = true
L["Show in Solo Mode"] = true
L["Show Interrupted Visual"] = true
L["Show Label"] = true
L["Show LFG Eye for Cross-Instance"] = true
L["Show Main Assist"] = true
L["Show Main Tank"] = true
L["Show Minimap Button"] = true
L["Show On Current Health Only"] = true
L["Show on Hover Only"] = true
L["Show Overheal"] = true
L["Show Overlay For"] = true
L["Show Overshield Glow"] = true
L["Show Party/Raid Side Menu"] = true
L["Show rested indicators when in a rested area (inn, city)."] = true
L["Show Shadow"] = true
L["Show Stacks"] = true
L["Show Tank"] = true
L["Show the animated ZZZ icon on the player frame."] = true
L["Show the DF color picker when any addon opens a color picker."] = true
L["Show Timer"] = true
L["Show When Missing"] = true
L["Show X Mark"] = true
L["Show:"] = true
L["Shows a border ring around the entire frame when a boss debuff is active."] = true
L["Shows a colored border/glow when a dispellable debuff is present."] = true
L["Shows a glow at max health when absorb exceeds the clamp limit."] = true
L["Shows an icon when an enemy is casting a spell targeting a party/raid member."] = true
L["Shows an icon when party members have a defensive cooldown active (Pain Suppression, Ironbark, etc.)."] = true
L["Shows effects that reduce incoming healing (like Necrotic stacks)."] = true
L["Shows icon when party members are missing raid buffs."] = true
L["Shows incoming targeted spells on YOU in the center of your screen."] = true
L["Shows the ping wheel & party management menu."] = true
L["Single Select"] = true
L["Size"] = true
L["Size & Orientation"] = true
L["Size & Spacing"] = true
L["Skip for now"] = true
L["Skyfury (Shaman)"] = true
L["Smart Res:"] = true
L["Smart Resurrection"] = true
L["Smooth Bar Animation"] = true
L["Snaps sizes and borders to exact pixels for crisp rendering."] = true
L["Solid (BLEND)"] = true
L["Solid Border"] = true
L["Solo Mode"] = true
L["Solo mode %s"] = true
L["Solo Mode: Show your player frame when not in a group."] = true
L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = true
--[[Translation missing --]]
L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = ""
L["Sort by Class (within role)"] = true
L["Sort Order"] = true
L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = true
--[[Translation missing --]]
L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = ""
L["Sorted with Group"] = true
L["Sorting"] = true
L["Sound"] = true
L["Sound Alert"] = true
L["Sound Alerts"] = true
L["Sound file could not be played: %s"] = true
L["Source Mode"] = true
L["Spacing"] = true
L["Spacing X"] = true
L["Spacing Y"] = true
L["Spark"] = true
L["Spec Default"] = true
L["Spec:"] = true
L["Specialization data not available."] = true
L["Spell:"] = true
L["Spells"] = true
L["Spells flagged as important by Blizzard."] = true
L["Square"] = true
L["Stack Anchor"] = true
L["Stack Count"] = true
L["Stack Font"] = true
L["Stack Minimum"] = true
L["Stack Offset X"] = true
L["Stack Offset Y"] = true
L["Stack Outline"] = true
L["Stack Scale"] = true
L["Stack Text"] = true
L["Stack Text Color"] = true
L["Standard Buffs are also visible on frames."] = true
L["START"] = true
L["Start"] = true
L["Start (Left/Top)"] = true
L["Start = Left/Top, End = Right/Bottom depending on direction."] = true
L["Start Delay (sec)"] = true
L["Start of Group"] = true
L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = true
--[[Translation missing --]]
L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = ""
L["Status Icon Text Settings"] = true
L["Status Text"] = true
L["Status Text (Dead/Offline)"] = true
L["Status Text Alpha"] = true
L["Step %d of %d"] = true
L["Step 1: Click here with desired key combo"] = true
L["Step 2: Select Action"] = true
L["Step 3: Combat Condition (optional)"] = true
L["Step Editor"] = true
L["Step ID"] = true
L["Steps"] = true
L["Style"] = true
L["Summary"] = true
L["Summary Step"] = true
L["Summon"] = true
L["Summon Icon"] = true
L["Switched to profile: %s"] = true
L["Sync"] = true
L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = true
--[[Translation missing --]]
L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = ""
L["Sync from WoW"] = true
L["Sync with %s"] = true
L["Sync: %s"] = true
L["Synced with %s"] = true
L["Synced: %s"] = true
L["Tank"] = true
L["Tanking (Red)"] = true
L["Tanks"] = true
L["Target Type:"] = true
L["Target Unit"] = true
L["Targeted Spell Alpha"] = true
L["Targeted Spell Click-Through"] = true
L["Targeted Spells"] = true
L["Targeted Spells (on frames)"] = true
L["Targeting Fallback:"] = true
L["Targeting: %s"] = true
L["Test"] = true
L["Test Mode"] = true
L["Test mode disabled."] = true
L["Test mode enabled."] = true
L["Test mode ended — entering combat."] = true
L["Test Mode: %s"] = true
L["Text"] = true
L["Text Color"] = true
L["Text Colors:"] = true
L["Text Format"] = true
L["Text Scale"] = true
L["Texture"] = true
L["Texture & Colors"] = true
L["The first image shows the overlay border active on a frame. The second shows the standard boss debuff icon only."] = true
L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = true
--[[Translation missing --]]
L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = ""
L["These settings apply when using 'Shadow' outline style. Use larger offsets for more dramatic shadows."] = true
L["Thick Outline"] = true
L["Thickness"] = true
L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = true
--[[Translation missing --]]
L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = ""
L["this option"] = true
L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = true
--[[Translation missing --]]
L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = ""
L["This setting differs from the global profile value. Click the reset button to revert."] = true
L["This setting is being overridden by the active auto layout profile. To change it, edit the profile in the Auto Layouts tab."] = true
L["This step automatically shows a review of all the user's answers. It's always the last step."] = true
L["This warning will not appear again after confirming."] = true
L["Threat Colors"] = true
L["Threshold Mode"] = true
L["Time Remaining"] = true
L["Timing"] = true
L["Tint"] = true
L["Tint Color"] = true
L["Tint Opacity"] = true
L[ [=[to customise
this profile's settings]=] ] = true
--[[Translation missing --]]
L[ [=[to customise
this profile's settings]=] ] = ""
L["To fix the ElvUI compatibility issue:"] = true
L["To reposition: Unlock frames (/df unlock) and drag the mover."] = true
L["Toggle Solo Mode"] = true
L["Toggle Test Mode"] = true
L["Tooltips"] = true
L["Top"] = true
L["Top Edge"] = true
L["Top Left"] = true
L["Top Right"] = true
L["Top to Bottom"] = true
L["Total:"] = true
L["Track Highest Duration"] = true
L["Track Lowest Duration"] = true
L["Trigger"] = true
L["Trigger Mode"] = true
L["TRIGGERED BY"] = true
L["Truncate Mode"] = true
L["Truncation"] = true
L["Type"] = true
L["Type /dfarena again to disable"] = true
L["Type:"] = true
L["UI Scale:"] = true
L["Unit Frame"] = true
L["Unit Frame Sorting"] = true
L["Unit Selection"] = true
L["Units at or above this health percent are faded."] = true
L["Units Per Row"] = true
L["Unknown"] = true
L["Unknown error"] = true
L["Unlock"] = true
L["Unlock Frames"] = true
L["Unnamed"] = true
L["Up"] = true
L["Use"] = true
L["USE"] = true
L["Use %s"] = true
L["Use /df overrides for full details in chat"] = true
L["Use Class Color"] = true
L["Use Current (%s)"] = true
L["Use Current Value"] = true
L["Use Custom Colors"] = true
L["Use Custom Pip Color"] = true
L["Use DandersFrames"] = true
L["Use DF Color Picker"] = true
L["Use DF Color Picker for All Addons"] = true
L["Use FrameSort Addon"] = true
L["Use Group-Based Layout"] = true
L["Use recommended defaults"] = true
L["Use Seconds Instead of Percent"] = true
L["Uses a single border per frame. Highest priority wins."] = true
L["Uses cast tracking to identify spells WoW marks as secret. Only tracks your own casts."] = true
L["Uses party frame settings/position"] = true
L["Using highest duration trigger"] = true
L["Using lowest duration trigger"] = true
L["Using spec default"] = true
L["v%s loaded. Type %s/df%s for settings, %s/df resetgui%s if window is offscreen."] = true
L["Valid range"] = true
L["Value:"] = true
L["Vehicle"] = true
L["Vehicle Icon"] = true
L["Vertical"] = true
L["Vertical Spacing"] = true
L["View Imported Macro"] = true
L["Visibility"] = true
L["Volume"] = true
L["Warlock"] = true
L["Warnings + Errors"] = true
L["Warrior"] = true
L["Weight"] = true
L["What should '%s' do with this setting?"] = true
L["When \"%s\" selected:"] = true
L["When auto-detect is OFF, select which raid buffs to monitor manually."] = true
L["When disabled: Click spell to open Binding Editor."] = true
L["When enabled, a new profile will be automatically"] = true
L["When enabled, all pips use a single custom color instead of the class-specific default."] = true
L["When enabled, all role icons are shown outside of combat. The filters below only apply during combat."] = true
L["When enabled, click-casting bindings will be"] = true
L["When enabled, Masque skins aura icons and borders. DF border settings will be disabled."] = true
L["When enabled, shows incoming heals even if they would overheal."] = true
L["When enabled, the group you are in will always be displayed first."] = true
L["When enabled: Click spell, press key to bind instantly."] = true
L["When you enter matching content, the layout's overrides are applied on top of your global settings. If no layout matches, global settings are used as-is."] = true
L["Which aura data source would you like to use?"] = true
L["While editing, each setting shows its override status:"] = true
L["Whitelist buffs take priority for the expiring indicator."] = true
L["WHITELISTED"] = true
L["Whole Alpha Pulse"] = true
L["Width"] = true
L["Width / Length"] = true
L["Will auto-create on switch"] = true
L["Will replace existing Mythic layout"] = true
L["Wizard"] = true
L["Wizard '%s' saved!"] = true
L["Wizard Builder"] = true
L["Wizard Details"] = true
L["Wizard Name:"] = true
L["Works when hovering frames. Action bars work when not hovering."] = true
L["World bosses, outdoor raids (1-40)"] = true
L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = true
--[[Translation missing --]]
L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = ""
L["Would you like to set up your aura filters?"] = true
L["X Color"] = true
L["X Mark"] = true
L["X Size"] = true
L["Yellow=high, Orange=highest, Red=tanking."] = true
L["Yes"] = true
L["Yes, set it up"] = true
L["YOUR PROFILES"] = true
L["Z to A"] = true


-- Development fallback: these strings are used when running
-- from source (not a packaged build). Keep in sync with usage.
