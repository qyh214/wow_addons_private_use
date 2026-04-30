-- Populate DF_AllLocales["deDE"] so Core.lua's ADDON_LOADED handler
-- can apply this locale's translations as an overlay if the user's
-- languageOverride selects it. No AceLocale interaction here — the
-- overlay step happens once the SavedVariable is actually populated,
-- which is only guaranteed at ADDON_LOADED time (not file-scope).
DF_AllLocales = DF_AllLocales or {}
DF_AllLocales.deDE = {}
local L = DF_AllLocales.deDE
L["    Show Frame Glow"] = "Zeige leuchtende Rahmen"
L["    Show ZZZ Icon"] = "Zeige ZZZ Symbol"
L["— click to edit"] = "— zum bearbeiten Klicken"
L[" indicator"] = "Indikator"
L[" indicators"] = "Indikatoren"
L["⚠ Note: Click-through icons will not show tooltips."] = "⚠ Hinweis: Bei durchklickbaren Symbolen werden keine Tooltips angezeigt."
L["\"%s\" will be overwritten."] = "\"%s\" wird überschrieben."
L["%d - %d players"] = [=[%d - %d Spieler
Basis Namensabstand]=]
L["%d binds"] = [=[%d bindet
Namen Abstand: Basis-Namen Abstand]=]
L["%d blacklisted"] = [=[Phrasenschlüssel: %d auf der Blacklist
Namensraum: Basis-Namensraum
%d auf der Blacklist]=]
L["%d override"] = "%d überschreiben"
L["%d overrides"] = "%d überschreiben"
L["%d players"] = "%d Spieler"
L["%d-%d players"] = "%d-%d Spieler"
L["%s (Copy)"] = "%s (Kopieren)"
L["%s (currently %s)"] = "%s (aktuelle %s)"
L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = "%s erkannt. Welches Addon für \"Klick-Zaubern\" möchtest du verwenden?"
--[[Translation missing --]]
--[[ L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = ""--]] 
L["%s settings reset to defaults."] = "%s Einstellungen auf Standardwerte zurückgesetzt"
--[[Translation missing --]]
--[[ L["%sGlobal: 80%s %s— Setting matches global, no override stored%s"] = "%sGlobal: 80%s %s— Setting matches global, no override stored%s"--]] 
--[[Translation missing --]]
--[[ L["%sModified%s %s— Setting differs from global. Click%s %sreset%s %sto revert.%s"] = "%sModified%s %s— Setting differs from global. Click%s %sreset%s %sto revert.%s"--]] 
L["(none)"] = "(none)"
L["(offline)"] = "(offline)"
L["(skipped)"] = "(übersprungen)"
L["[Linked]"] = "[verknüpft]"
L["[Override]"] = "[Override]"
--[[Translation missing --]]
--[[ L["[Unassigned]"] = "[Unassigned]"--]] 
L["+ Add"] = "+ hinzufügen"
L["+ Add aura"] = "+ Aura hinzufügen"
L["+ Add Indicator"] = "+ Indikator hinzufügen"
L["+ Add Layout"] = "+ Layout hinzufügen"
L["+ Add Option"] = "+ Option hinzufügen"
L["+ Add Step"] = "+ Schritt hinzufügen"
L["+ Add Trigger"] = "+ Auslöser hinzufügen"
L["+ Create Group"] = "+ Gruppe erstellen"
L["+ New"] = "+ Neu"
L["+ New Wizard"] = "+ Neuen Zauber"
L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = "• Du hast Probleme bestimmte Buffs oder Debuffs zu sehen? • Dieser Assistent hilft dir die richtige Aura Einstellung auszuwählen."
--[[Translation missing --]]
--[[ L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["0=Auto, Higher=On top of more elements"] = "0=Auto, Higher=On top of more elements"--]] 
L["1"] = "1"
L["1 = High"] = "1 = Hoch"
L["1. Open ElvUI config with %s/ec%s"] = "1. Öffne die ElvUI-Config mit %s/ec%s"
L["10 = Low"] = "10 = Niedrig"
L["2. Go to %sUnitFrames%s (left sidebar)"] = "2. Gehe zu %sUnitFrames%s (Linke Seitenleiste)"
L["20 players (fixed)"] = "20 Spieler (fixed)"
L["3. Click %sGeneral%s at the top"] = " Klicke %sGeneral%s oben"
--[[Translation missing --]]
--[[ L["4. Scroll down to %sDisabled Blizzard Frames%s"] = "4. Scroll down to %sDisabled Blizzard Frames%s"--]] 
--[[Translation missing --]]
--[[ L["5. Under %sGroup Units%s, uncheck %sParty%s and %sRaid%s"] = "5. Under %sGroup Units%s, uncheck %sParty%s and %sRaid%s"--]] 
--[[Translation missing --]]
--[[ L["6. Click the reload button when prompted"] = "6. Click the reload button when prompted"--]] 
--[[Translation missing --]]
--[[ L["A layout with this name already exists in %s"] = "A layout with this name already exists in %s"--]] 
--[[Translation missing --]]
--[[ L["a placed indicator to remove it from the frame"] = "a placed indicator to remove it from the frame"--]] 
--[[Translation missing --]]
--[[ L["a placed indicator to reposition it on the frame"] = "a placed indicator to reposition it on the frame"--]] 
L["A profile with this name already exists"] = "Ein Profil mit diesem Namen existiert bereits"
L["A to Z"] = "A bis Z"
L["Abbreviate (K/M)"] = "Abkürzen (K/M)"
L["Above Health Bar"] = "Über Lebensbalken"
L["Above Owner"] = "Über den Eigentümer"
L["Above Party"] = "Über die Gruppe"
L["Above Raid"] = "Über den Raid"
L["Absorb Shield"] = "Absorb Shield"
L["Absorbs"] = "Absorbs"
L["Actions"] = "Actions"
L["Active"] = "Aktiv"
L["Active Bindings"] = "Aktiv Bindings"
L["Active Bindings (%d)"] = "Aktiv Bindings (%d)"
L["ACTIVE INDICATORS"] = "Aktive Indikatoren"
L["Active:"] = "Aktiv:"
L["Actually, disable it"] = "Deaktiviere, es einfach!"
L["Add"] = "Hinzufügen"
L["Add #showtooltip"] = "#showtooltip Hinzufügen"
L["Add /stopcasting"] = "/stopcasting Hinzufügen"
L["Add Layout"] = "Layout hinzufügen"
L["Add New Binding"] = "Tastenbelegung hinzufügen"
L["Add Offline Player"] = "Offline-Player hinzufügen"
--[[Translation missing --]]
--[[ L[ [=[Add players from the roster
or use quick add buttons]=] ] = [=[Add players from the roster
or use quick add buttons]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Add players from the roster
or use quick add buttons]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Additive (ADD)"] = "Additive (ADD)"--]] 
L["Advanced"] = "Fortgeschritten"
L["Affected Elements"] = "Beeinflusste Elemente"
L["AFK"] = "AFK"
L["AFK Icon"] = "AFK Symbol"
L["Aggro Highlight"] = "Aggro Highlight"
L["Aggro Settings"] = "Aggro Einstellungen"
L["Alert if anyone is missing the buff"] = "Informiere, wenn dieser Buff jemanden fehlt"
L["Alert only if nobody has the buff"] = "Informiere nur, wenn keiner den Buff hat. "
L["Alert When Expiring"] = "Informieren wenn es abläuft"
--[[Translation missing --]]
--[[ L["All"] = "All"--]] 
--[[Translation missing --]]
--[[ L["ALL (AND)"] = "ALL (AND)"--]] 
L["All Buffs"] = "Alle Buffs"
L["All Debuffs"] = "Alle Debuffs"
--[[Translation missing --]]
--[[ L["All Dispellable"] = "All Dispellable"--]] 
--[[Translation missing --]]
--[[ L["All players in a unified grid. Sorting applies raid-wide."] = "All players in a unified grid. Sorting applies raid-wide."--]] 
--[[Translation missing --]]
--[[ L["ALL triggers must be active"] = "ALL triggers must be active"--]] 
L["Alpha"] = "Deckkraft"
L["Alphabetical"] = "Alphabetisch"
L["Alphabetical (within class/role)"] = "Alphabetisch (innerhalb Klasse/Rolle)"
L["Always"] = "Immer"
L["Always First"] = "Immer als erstes"
L["Always Green"] = "Immer grün"
L["Always Last"] = "Immer als letztes"
--[[Translation missing --]]
--[[ L["an indicator on the frame to expand its settings"] = "an indicator on the frame to expand its settings"--]] 
L["Anchor"] = "Anker"
L["Anchor Point"] = "Ankerpunkt"
L["Anchor Position"] = "Anker Position"
--[[Translation missing --]]
--[[ L["Anchor To"] = "Anchor To"--]] 
L["Animated Border"] = "Animierter Rahmen"
L["ANY (OR)"] = "Alle (oder)"
L["Any Target"] = "Alle Target"
--[[Translation missing --]]
--[[ L["ANY trigger activates the effect"] = "ANY trigger activates the effect"--]] 
L["Appearance"] = "Erscheinung"
L["Apply"] = "Akzeptieren"
L["Apply to All"] = "Für alles akzeptieren"
--[[Translation missing --]]
--[[ L["Apply to Frames:"] = "Apply to Frames:"--]] 
L["Arcane Intellect (Mage)"] = "Arkane Intelligenz (Magier)"
--[[Translation missing --]]
--[[ L["are secret-tracked"] = "are secret-tracked"--]] 
L["Are you sure?"] = "Bist du dir sicher?"
L["Arena"] = "Arena"
L["Arena header will show using raid1-5 unit IDs"] = "In der Arena-Kopfzeile werden die Unit-IDs von RAID 1–5 angezeigt!"
L["Arena mode %sDISABLED%s"] = "Arena Modus %s deaktiviert %s"
L["Arena mode %sENABLED%s for testing"] = "Arena Modus %s aktiviert%s fürs testen"
--[[Translation missing --]]
--[[ L["Arrange Groups In"] = "Arrange Groups In"--]] 
L["Arrange In"] = "Anordnen in"
L["Arrange Players In"] = "Spieler anordnen in"
--[[Translation missing --]]
--[[ L["Attach the handle to the container, the first visible unit, or the last visible unit."] = "Attach the handle to the container, the first visible unit, or the last visible unit."--]] 
--[[Translation missing --]]
--[[ L["Attach To"] = "Attach To"--]] 
--[[Translation missing --]]
--[[ L["Attached + Overflow"] = "Attached + Overflow"--]] 
--[[Translation missing --]]
--[[ L["Attached to Health"] = "Attached to Health"--]] 
--[[Translation missing --]]
--[[ L["Attached to Owner"] = "Attached to Owner"--]] 
--[[Translation missing --]]
--[[ L["Aura Blacklist"] = "Aura Blacklist"--]] 
--[[Translation missing --]]
--[[ L["Aura Data Source"] = "Aura Data Source"--]] 
L["Aura Designer"] = "Aura Designer"
L["Aura Designer Alpha"] = "Deckkraft für Aura Designer"
--[[Translation missing --]]
--[[ L["Aura Designer is active alongside Buffs."] = "Aura Designer is active alongside Buffs."--]] 
--[[Translation missing --]]
--[[ L["Aura Designer is disabled"] = "Aura Designer is disabled"--]] 
--[[Translation missing --]]
--[[ L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Aura Filter Setup"] = "Aura Filter Setup"--]] 
--[[Translation missing --]]
--[[ L["Aura Filters"] = "Aura Filters"--]] 
L["Auras"] = "Auras"
L["Auras Alpha"] = "Deckkraft für Auren"
--[[Translation missing --]]
--[[ L["Auto (%s)"] = "Auto (%s)"--]] 
--[[Translation missing --]]
--[[ L["Auto (detect class)"] = "Auto (detect class)"--]] 
--[[Translation missing --]]
--[[ L["Auto (detect spec)"] = "Auto (detect spec)"--]] 
--[[Translation missing --]]
--[[ L["Auto (detect)"] = "Auto (detect)"--]] 
--[[Translation missing --]]
--[[ L["Auto (Spec Default)"] = "Auto (Spec Default)"--]] 
L["Auto Layouts"] = " Auto Layouts"
--[[Translation missing --]]
--[[ L["Auto Layouts is a Raid-only feature. Switch to Raid mode to configure automatic layout switching based on content type and group size."] = "Auto Layouts is a Raid-only feature. Switch to Raid mode to configure automatic layout switching based on content type and group size."--]] 
--[[Translation missing --]]
--[[ L["Auto Layouts module not loaded."] = "Auto Layouts module not loaded."--]] 
--[[Translation missing --]]
--[[ L["Auto-add DPS"] = "Auto-add DPS"--]] 
--[[Translation missing --]]
--[[ L["Auto-add Healers"] = "Auto-add Healers"--]] 
--[[Translation missing --]]
--[[ L["Auto-add Tanks"] = "Auto-add Tanks"--]] 
--[[Translation missing --]]
--[[ L["Auto-create disabled"] = "Auto-create disabled"--]] 
--[[Translation missing --]]
--[[ L["Auto-Create Profiles"] = "Auto-Create Profiles"--]] 
--[[Translation missing --]]
--[[ L["Auto-create profiles for loadouts"] = "Auto-create profiles for loadouts"--]] 
--[[Translation missing --]]
--[[ L["Auto-detect (your class's buff)"] = "Auto-detect (your class's buff)"--]] 
--[[Translation missing --]]
--[[ L["Auto-Fit Border to Frame Size"] = "Auto-Fit Border to Frame Size"--]] 
--[[Translation missing --]]
--[[ L["Automatically add players by role when they join your group."] = "Automatically add players by role when they join your group."--]] 
--[[Translation missing --]]
--[[ L["Automatically detects player-dispellable debuffs via the RAID_PLAYER_DISPELLABLE filter. Configure the overlay on the Dispel Overlay page."] = "Automatically detects player-dispellable debuffs via the RAID_PLAYER_DISPELLABLE filter. Configure the overlay on the Dispel Overlay page."--]] 
--[[Translation missing --]]
--[[ L["Auto-Populate"] = "Auto-Populate"--]] 
--[[Translation missing --]]
--[[ L["Auto-profile \"%s\" activated (%s, %d players)"] = "Auto-profile \"%s\" activated (%s, %d players)"--]] 
--[[Translation missing --]]
--[[ L["Auto-profile deactivated (profile deleted)"] = "Auto-profile deactivated (profile deleted)"--]] 
--[[Translation missing --]]
--[[ L["Auto-profile deactivated, using global settings"] = "Auto-profile deactivated, using global settings"--]] 
L["Auto-Switch by Spec"] = "Automatischer Wechsel (Spezialisierung)"
L["Auto-switched to profile: %s"] = "Automatisch gewechselt zu Profil: %s"
L["Auto-switching disabled"] = "Automatischer Wechsel deaktiviert"
L["Available Profiles"] = "Verfügbare Profile"
L["A-Z"] = "A-Z"
L["Back"] = "Zurück"
--[[Translation missing --]]
--[[ L["Back to List"] = "Back to List"--]] 
L["Background"] = "Hintergrund"
L["Background Alpha"] = "Deckkraft für Hintergrund"
L["Background Color"] = "Hintergrundfarbe"
--[[Translation missing --]]
--[[ L["Background Fill"] = "Background Fill"--]] 
--[[Translation missing --]]
--[[ L["Background Mode"] = "Background Mode"--]] 
L["Background Only"] = "Nur Hintergrund"
--[[Translation missing --]]
--[[ L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Background Texture"] = "Background Texture"--]] 
L["Bar"] = "Balken"
L["Bar Color"] = "Balkenfarbe"
L["Bar Texture"] = "Balkentextur"
L["Bars"] = "Balken"
--[[Translation missing --]]
--[[ L["Battle Shout (Warrior)"] = "Battle Shout (Warrior)"--]] 
--[[Translation missing --]]
--[[ L["Battlegrounds"] = "Battlegrounds"--]] 
--[[Translation missing --]]
--[[ L["Before You Enable"] = "Before You Enable"--]] 
L["Below Health Bar"] = "Unter Lebensbalken"
--[[Translation missing --]]
--[[ L["Below Owner"] = "Below Owner"--]] 
--[[Translation missing --]]
--[[ L["Below Party"] = "Below Party"--]] 
--[[Translation missing --]]
--[[ L["Below Raid"] = "Below Raid"--]] 
--[[Translation missing --]]
--[[ L["Big Defensives"] = "Big Defensives"--]] 
--[[Translation missing --]]
--[[ L["Bind Action"] = "Bind Action"--]] 
--[[Translation missing --]]
--[[ L["Bind Item"] = "Bind Item"--]] 
--[[Translation missing --]]
--[[ L["Bind Spell"] = "Bind Spell"--]] 
--[[Translation missing --]]
--[[ L["Binding Tooltips"] = "Binding Tooltips"--]] 
L["Binding:"] = "Binding:"
--[[Translation missing --]]
--[[ L["Bindings only cast their assigned spell"] = "Bindings only cast their assigned spell"--]] 
--[[Translation missing --]]
--[[ L["BINDS"] = "BINDS"--]] 
--[[Translation missing --]]
--[[ L["Bleed / Enrage"] = "Bleed / Enrage"--]] 
--[[Translation missing --]]
--[[ L["Blend %"] = "Blend %"--]] 
--[[Translation missing --]]
--[[ L["Blend Mode"] = "Blend Mode"--]] 
--[[Translation missing --]]
--[[ L["Blessing of the Bronze (Evoker)"] = "Blessing of the Bronze (Evoker)"--]] 
L["Blizzard"] = "Blizzard"
--[[Translation missing --]]
--[[ L["Blizzard (Default)"] = "Blizzard (Default)"--]] 
L["Blizzard Click-Casting"] = "Blizzard Klickzauber"
L["Blizzard Frame Settings"] = "Bizzard Frame Einstellungen"
L["Blizzard Frames"] = "Blizzard Frames"
--[[Translation missing --]]
--[[ L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = ""--]] 
L["Border"] = "Rahmen"
--[[Translation missing --]]
--[[ L["Border Color"] = "Border Color"--]] 
--[[Translation missing --]]
--[[ L["Border Inset"] = "Border Inset"--]] 
--[[Translation missing --]]
--[[ L["Border Mode:"] = "Border Mode:"--]] 
--[[Translation missing --]]
--[[ L["Border Opacity"] = "Border Opacity"--]] 
--[[Translation missing --]]
--[[ L["Border Scale"] = "Border Scale"--]] 
--[[Translation missing --]]
--[[ L["Border Size"] = "Border Size"--]] 
--[[Translation missing --]]
--[[ L["Border Thickness"] = "Border Thickness"--]] 
L["Boss Debuffs"] = "Boss Debuffs"
--[[Translation missing --]]
--[[ L["Boss Debuffs (Private Auras) are special debuffs that Blizzard hides from addons."] = "Boss Debuffs (Private Auras) are special debuffs that Blizzard hides from addons."--]] 
--[[Translation missing --]]
--[[ L["Both"] = "Both"--]] 
--[[Translation missing --]]
--[[ L["Bottom"] = "Bottom"--]] 
--[[Translation missing --]]
--[[ L["Bottom Edge"] = "Bottom Edge"--]] 
--[[Translation missing --]]
--[[ L["Bottom Left"] = "Bottom Left"--]] 
--[[Translation missing --]]
--[[ L["Bottom Right"] = "Bottom Right"--]] 
--[[Translation missing --]]
--[[ L["Bottom to Top"] = "Bottom to Top"--]] 
--[[Translation missing --]]
--[[ L["Bounce"] = "Bounce"--]] 
--[[Translation missing --]]
--[[ L["Bound: %s"] = "Bound: %s"--]] 
--[[Translation missing --]]
--[[ L["Branch"] = "Branch"--]] 
--[[Translation missing --]]
--[[ L["Branching Rules"] = "Branching Rules"--]] 
--[[Translation missing --]]
--[[ L["BUFF BLACKLIST"] = "BUFF BLACKLIST"--]] 
L["Buff Filters"] = "Buff Filter"
L["Buff Icon"] = "Buff Icon"
L["Buff Icons"] = "Buff Icons"
L["Buff Icons Click-Through"] = "Buff Symbole durchklickbar"
L["Buff Tooltips"] = "Buff Tooltips"
L["Buffs"] = "Buffs"
--[[Translation missing --]]
--[[ L["Buffs are disabled. Aura Designer is managing your auras."] = "Buffs are disabled. Aura Designer is managing your auras."--]] 
--[[Translation missing --]]
--[[ L["Buffs flagged by Blizzard to show up on raid frames."] = "Buffs flagged by Blizzard to show up on raid frames."--]] 
--[[Translation missing --]]
--[[ L["Buffs flagged to show on raid frames during combat, such as self-cast HoTs."] = "Buffs flagged to show on raid frames during combat, such as self-cast HoTs."--]] 
--[[Translation missing --]]
--[[ L["Buffs that can be right-click cancelled."] = "Buffs that can be right-click cancelled."--]] 
--[[Translation missing --]]
--[[ L["Buffs that cannot be cancelled by the player."] = "Buffs that cannot be cancelled by the player."--]] 
--[[Translation missing --]]
--[[ L["Buffs to Check (Manual Mode)"] = "Buffs to Check (Manual Mode)"--]] 
L["Building: "] = "Building:"
--[[Translation missing --]]
--[[ L["Built-in Wizards"] = "Built-in Wizards"--]] 
--[[Translation missing --]]
--[[ L["By Health %"] = "By Health %"--]] 
L["Cancel"] = "Abbrechen"
--[[Translation missing --]]
--[[ L["Cancel Fade on Dispellable Debuff"] = "Cancel Fade on Dispellable Debuff"--]] 
L["Cancelable"] = "unterbrechbar"
--[[Translation missing --]]
--[[ L["Cannot delete Default profile."] = "Cannot delete Default profile."--]] 
--[[Translation missing --]]
--[[ L["Cannot disable test mode while frames are unlocked. Lock frames first."] = "Cannot disable test mode while frames are unlocked. Lock frames first."--]] 
L["Cannot Edit"] = "Kann nicht bearbeitet werden"
--[[Translation missing --]]
--[[ L["Cannot enter test mode during combat."] = "Cannot enter test mode during combat."--]] 
L["Cannot toggle arena mode during combat"] = "Wechsel des Arenamodus im Kampf nicht möglich"
--[[Translation missing --]]
--[[ L["Cannot toggle test mode during combat."] = "Cannot toggle test mode during combat."--]] 
--[[Translation missing --]]
--[[ L["Cannot unlock - container doesn't exist!"] = "Cannot unlock - container doesn't exist!"--]] 
--[[Translation missing --]]
--[[ L["Cannot unlock - failed to create mover frame!"] = "Cannot unlock - failed to create mover frame!"--]] 
--[[Translation missing --]]
--[[ L["Cannot unlock frames during combat."] = "Cannot unlock frames during combat."--]] 
--[[Translation missing --]]
--[[ L["Cannot use this action in combat."] = "Cannot use this action in combat."--]] 
--[[Translation missing --]]
--[[ L["Cast on DOWN"] = "Cast on DOWN"--]] 
L["Categories"] = "Kategorien"
L["Category Filters"] = "Kategorien Filters"
--[[Translation missing --]]
--[[ L["CC effects like stuns, roots, and incapacitates."] = "CC effects like stuns, roots, and incapacitates."--]] 
L["Center"] = "Center"
--[[Translation missing --]]
--[[ L["Center (Horizontal)"] = "Center (Horizontal)"--]] 
--[[Translation missing --]]
--[[ L["Center (Vertical)"] = "Center (Vertical)"--]] 
--[[Translation missing --]]
--[[ L["Center of Group"] = "Center of Group"--]] 
L["Character"] = "Charakter"
--[[Translation missing --]]
--[[ L["Character Import"] = "Character Import"--]] 
--[[Translation missing --]]
--[[ L["Choose how DandersFrames reads aura data for buffs, debuffs, defensives, and dispel detection."] = "Choose how DandersFrames reads aura data for buffs, debuffs, defensives, and dispel detection."--]] 
--[[Translation missing --]]
--[[ L["Choose Icon"] = "Choose Icon"--]] 
--[[Translation missing --]]
--[[ L["Choose whether to enable the frame border overlay."] = "Choose whether to enable the frame border overlay."--]] 
--[[Translation missing --]]
--[[ L["Choose which groups to display."] = "Choose which groups to display."--]] 
--[[Translation missing --]]
--[[ L["Clamp Mode"] = "Clamp Mode"--]] 
L["Class"] = "Klasse"
L["Class Color"] = "Klassenfarbe"
L["Class Color Alpha"] = "Deckkraft für Klassenfarben"
L["Class Colors"] = "Klassenfarben"
L["Class Filter"] = "Klassenfilter"
--[[Translation missing --]]
--[[ L["Class Power"] = "Class Power"--]] 
--[[Translation missing --]]
--[[ L["Class Power Pips"] = "Class Power Pips"--]] 
--[[Translation missing --]]
--[[ L["Class Priority"] = "Class Priority"--]] 
L["Clear"] = "Leeren"
L["Clear All"] = "Leere alles"
--[[Translation missing --]]
--[[ L["Clear All Bindings"] = "Clear All Bindings"--]] 
--[[Translation missing --]]
--[[ L["Clear Blizzard Bindings"] = "Clear Blizzard Bindings"--]] 
L["Clear Log"] = "Log leeren"
L["Click"] = "Klick"
--[[Translation missing --]]
--[[ L["Click %sEdit Settings%s on a profile to customise it. This takes you to the settings tabs with an editing banner at the top. While editing, any setting you change is stored as an override for that profile only."] = "Click %sEdit Settings%s on a profile to customise it. This takes you to the settings tabs with an editing banner at the top. While editing, any setting you change is stored as an override for that profile only."--]] 
--[[Translation missing --]]
--[[ L["Click %sExit Editing%s when done. Your overrides are saved to the profile. If you change a setting back to match global, the override is automatically removed."] = "Click %sExit Editing%s when done. Your overrides are saved to the profile. If you change a setting back to match global, the override is automatically removed."--]] 
L["Click a color swatch to open the color picker. These settings are shared across party and raid frames."] = "Klick auf ein Farbmuster um die Farbauswahl zu öffnen. Diese Einstellungen werden für Gruppen- und Schlachtzugsfenster gemeinsam genutzt."
--[[Translation missing --]]
--[[ L["Click a setting to link it to your wizard"] = "Click a setting to link it to your wizard"--]] 
--[[Translation missing --]]
--[[ L["Click item slot to bind"] = "Click item slot to bind"--]] 
--[[Translation missing --]]
--[[ L["Click macro to bind"] = "Click macro to bind"--]] 
--[[Translation missing --]]
--[[ L["Click or drag a spell onto the frame to place it"] = "Click or drag a spell onto the frame to place it"--]] 
--[[Translation missing --]]
--[[ L["Click spell to bind"] = "Click spell to bind"--]] 
L["Click to bind..."] = "Klick zum bind..."
--[[Translation missing --]]
--[[ L["Click to cycle through steps"] = "Click to cycle through steps"--]] 
--[[Translation missing --]]
--[[ L["Click to edit"] = "Click to edit"--]] 
--[[Translation missing --]]
--[[ L["Click to edit range"] = "Click to edit range"--]] 
--[[Translation missing --]]
--[[ L["Click to set branch target"] = "Click to set branch target"--]] 
--[[Translation missing --]]
--[[ L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = ""--]] 
L["Click to toggle"] = "Klicken zum umschalten"
L["Click-cast profile: %s"] = "Klickzauber Profil: %s"
L["Click-Casting"] = "Klickzauber"
L["Click-Casting Addon Conflict"] = "Klickzauber Addon Konflikt"
L["Click-Through Icons"] = "Durchklickbare Symbole"
--[[Translation missing --]]
--[[ L["Clip Border to Frame"] = "Clip Border to Frame"--]] 
L["Close"] = "Schließen"
L["Color"] = "Farbe"
--[[Translation missing --]]
--[[ L["Color and opacity of the empty/inactive pips."] = "Color and opacity of the empty/inactive pips."--]] 
--[[Translation missing --]]
--[[ L["Color Bar by Duration"] = "Color Bar by Duration"--]] 
--[[Translation missing --]]
--[[ L["Color by Dispel Type"] = "Color by Dispel Type"--]] 
--[[Translation missing --]]
--[[ L["Color by Time"] = "Color by Time"--]] 
--[[Translation missing --]]
--[[ L["Color by Time Remaining"] = "Color by Time Remaining"--]] 
--[[Translation missing --]]
--[[ L["Color Duration by Time"] = "Color Duration by Time"--]] 
--[[Translation missing --]]
--[[ L["Color Mode"] = "Color Mode"--]] 
--[[Translation missing --]]
--[[ L["Color Name Text"] = "Color Name Text"--]] 
L["Color Picker"] = "Farbauswahl"
--[[Translation missing --]]
--[[ L["Color shown when in combat to indicate the handle is locked."] = "Color shown when in combat to indicate the handle is locked."--]] 
L["Colors"] = "Farben"
--[[Translation missing --]]
--[[ L["Column Growth"] = "Column Growth"--]] 
--[[Translation missing --]]
--[[ L["Column Spacing"] = "Column Spacing"--]] 
--[[Translation missing --]]
--[[ L["Columns"] = "Columns"--]] 
--[[Translation missing --]]
--[[ L["Columns Grow From"] = "Columns Grow From"--]] 
--[[Translation missing --]]
--[[ L["Combat"] = "Combat"--]] 
--[[Translation missing --]]
--[[ L["Combat Color"] = "Combat Color"--]] 
--[[Translation missing --]]
--[[ L["Combat Limitation: All groups will not update with new players that join mid-combat."] = "Combat Limitation: All groups will not update with new players that join mid-combat."--]] 
--[[Translation missing --]]
--[[ L["Combat Limitation: Your group will not update with new players that join mid-combat."] = "Combat Limitation: Your group will not update with new players that join mid-combat."--]] 
L["Combat Mode"] = "Kampfmodus"
--[[Translation missing --]]
--[[ L["Combat Only"] = "Combat Only"--]] 
--[[Translation missing --]]
--[[ L["Compatible (%d)"] = "Compatible (%d)"--]] 
--[[Translation missing --]]
--[[ L["Compatible Bindings"] = "Compatible Bindings"--]] 
--[[Translation missing --]]
--[[ L["Compatible Only"] = "Compatible Only"--]] 
--[[Translation missing --]]
--[[ L["Confirm"] = "Confirm"--]] 
--[[Translation missing --]]
--[[ L["Console"] = "Console"--]] 
--[[Translation missing --]]
--[[ L["Container"] = "Container"--]] 
--[[Translation missing --]]
--[[ L["Content type filters configured in Party tab."] = "Content type filters configured in Party tab."--]] 
--[[Translation missing --]]
--[[ L["Content Types"] = "Content Types"--]] 
--[[Translation missing --]]
--[[ L["Content:"] = "Content:"--]] 
--[[Translation missing --]]
--[[ L["Controls Blizzard's debuff filtering (affects our display too)."] = "Controls Blizzard's debuff filtering (affects our display too)."--]] 
--[[Translation missing --]]
--[[ L["Controls how multiple defensive icons are arranged when using Direct aura mode."] = "Controls how multiple defensive icons are arranged when using Direct aura mode."--]] 
--[[Translation missing --]]
--[[ L["Copied %d settings from %s to %s."] = "Copied %d settings from %s to %s."--]] 
--[[Translation missing --]]
--[[ L["Copied settings from %s to %s."] = "Copied settings from %s to %s."--]] 
--[[Translation missing --]]
--[[ L["Copies these settings from %s to %s."] = "Copies these settings from %s to %s."--]] 
L["Copy"] = "Kopieren"
L["Copy %s Settings"] = "%s Einstellungen kopieren"
L["Copy %s settings to %s?"] = "Kopiere %s Einstellungen zu %s?"
L["Copy all settings between Party and Raid modes."] = "Kopiere alle Einstellungen zwischen Party und Raid Modus."
--[[Translation missing --]]
--[[ L["COPY APPEARANCE FROM"] = "COPY APPEARANCE FROM"--]] 
--[[Translation missing --]]
--[[ L["Copy Layout"] = "Copy Layout"--]] 
L["Copy Settings"] = "Einstellungen kopieren"
--[[Translation missing --]]
--[[ L["Copy Settings to %s"] = "Copy Settings to %s"--]] 
--[[Translation missing --]]
--[[ L["Copy the string below to share this wizard:"] = "Copy the string below to share this wizard:"--]] 
--[[Translation missing --]]
--[[ L["Copy this string to share your profile:"] = "Copy this string to share your profile:"--]] 
L["Copy To"] = "Kopiere zu"
L["Copy to Clipboard"] = "Kopiere in Zwischenablage"
L["Copy to Party"] = "Kopiere zu Party"
L["Copy to Raid"] = "Kopiere zu Schlachtzug"
--[[Translation missing --]]
--[[ L["Corners Only"] = "Corners Only"--]] 
L["Create"] = "Erstelle"
--[[Translation missing --]]
--[[ L["Create and manage setup wizards that guide users through configuring addon settings. Wizards can be shared with others via import/export strings."] = "Create and manage setup wizards that guide users through configuring addon settings. Wizards can be shared with others via import/export strings."--]] 
--[[Translation missing --]]
--[[ L["Create Custom Macro"] = "Create Custom Macro"--]] 
L["Create Empty"] = "Erstelle leeres"
--[[Translation missing --]]
--[[ L["Create Layout"] = "Create Layout"--]] 
--[[Translation missing --]]
--[[ L["Create layouts below for different player ranges within each content type. Layouts only store settings that %sdiffer%s from your global settings — everything else is inherited automatically."] = "Create layouts below for different player ranges within each content type. Layouts only store settings that %sdiffer%s from your global settings — everything else is inherited automatically."--]] 
L["Create Macro"] = "Makro erstellen"
L["Create New Profile"] = "Neues Profil erstellen"
--[[Translation missing --]]
--[[ L["Create separate frame groups to pin specific players like tanks, healers, or key raid members. Drag players from your group roster to add them."] = "Create separate frame groups to pin specific players like tanks, healers, or key raid members. Drag players from your group roster to add them."--]] 
L["Created new profile: %s"] = "Neues Profil erstellt: %s"
L["Crowd Control"] = "Massenkontrolle"
L["Current / Max"] = "Aktuell / Maximum"
L["Current Health"] = "Aktuelles Leben"
L["Current Profile"] = "Aktuelles Profil"
--[[Translation missing --]]
--[[ L["CURRENT STATUS"] = "CURRENT STATUS"--]] 
--[[Translation missing --]]
--[[ L["Currently: Percent. Click for Seconds."] = "Currently: Percent. Click for Seconds."--]] 
--[[Translation missing --]]
--[[ L["Currently: Seconds. Click for Percent."] = "Currently: Seconds. Click for Percent."--]] 
--[[Translation missing --]]
--[[ L["Curse"] = "Curse"--]] 
L["Cursor"] = "Zeiger"
--[[Translation missing --]]
--[[ L["Custom"] = "Custom"--]] 
--[[Translation missing --]]
--[[ L["Custom Border"] = "Custom Border"--]] 
--[[Translation missing --]]
--[[ L["Custom buff and frame effect indicators"] = "Custom buff and frame effect indicators"--]] 
--[[Translation missing --]]
--[[ L["Custom Color"] = "Custom Color"--]] 
L["Custom Dead Background"] = "Benutzerdefinierte Hintergrund wenn Tot"
--[[Translation missing --]]
--[[ L["Custom Dispel Colors"] = "Custom Dispel Colors"--]] 
--[[Translation missing --]]
--[[ L["Custom Health Color"] = "Custom Health Color"--]] 
--[[Translation missing --]]
--[[ L["Custom Macro"] = "Custom Macro"--]] 
--[[Translation missing --]]
--[[ L["Custom Sound Path"] = "Custom Sound Path"--]] 
L["Custom Spell ID"] = "Benutzerdefinierte Zauber ID"
--[[Translation missing --]]
--[[ L["Customise"] = "Customise"--]] 
L["Customize class colors used throughout DandersFrames. Changes apply to health bars, name text, borders, and all other class-colored elements."] = "Bearbeite Klassenfarben die DandersFrames verwenden soll. Änderungen gelten für Lebensbalken, Namenstexte, Rahmen und alle anderen Elemente die Klassenfarben verwenden."
L["Customize resource bar colors per power type. Shared across party and raid frames."] = "Passe Farben der Ressourcenbalken für jeden Power Typ an. Gemeinsam genutzt Gruppen und Schlachtzug Frames."
--[[Translation missing --]]
--[[ L["Cut"] = "Cut"--]] 
--[[Translation missing --]]
--[[ L["Cycle Next CC Profile"] = "Cycle Next CC Profile"--]] 
--[[Translation missing --]]
--[[ L["Cycle Next Profile"] = "Cycle Next Profile"--]] 
L["Damage"] = "Schaden"
--[[Translation missing --]]
--[[ L["DandersFrames Auto-Profile Overrides:"] = "DandersFrames Auto-Profile Overrides:"--]] 
--[[Translation missing --]]
--[[ L["Darken Amount"] = "Darken Amount"--]] 
--[[Translation missing --]]
--[[ L["Darken Behind Gradient"] = "Darken Behind Gradient"--]] 
--[[Translation missing --]]
--[[ L["Darken Effect"] = "Darken Effect"--]] 
--[[Translation missing --]]
--[[ L["Dashed Border"] = "Dashed Border"--]] 
--[[Translation missing --]]
--[[ L["Dead + In combat: Cast Battle Res (Rebirth, etc.)"] = "Dead + In combat: Cast Battle Res (Rebirth, etc.)"--]] 
--[[Translation missing --]]
--[[ L["Dead + Out of combat: Cast Mass Res or normal Res"] = "Dead + Out of combat: Cast Mass Res or normal Res"--]] 
--[[Translation missing --]]
--[[ L["Dead Background Color"] = "Dead Background Color"--]] 
L["Dead/Offline Fading"] = "Tot/Offline Verblassen"
L["Death Knight"] = "Todesritter"
L["DEBUFF BLACKLIST"] = "DEBUFF BLACKLIST"
L["Debuff Filters"] = "Debuff Filter"
L["Debuff Icon"] = "Debuff Icon"
L["Debuff Icons"] = "Debuff Icons"
L["Debuff Icons Click-Through"] = "Debuff Symbole durchklickbar"
L["Debuff Tooltips"] = "Debuff Tooltips"
L["Debuffs"] = "Debuffs"
--[[Translation missing --]]
--[[ L["Debuffs relevant during combat in a raid context."] = "Debuffs relevant during combat in a raid context."--]] 
--[[Translation missing --]]
--[[ L["Debuffs relevant in a raid context."] = "Debuffs relevant in a raid context."--]] 
L["Debug"] = "Debug"
L["Debug Console"] = "Debug Console"
L["Debug Log Export (Filtered)"] = "Debug Log Export (Filtered)"
--[[Translation missing --]]
--[[ L["Debug logging %s"] = "Debug logging %s"--]] 
--[[Translation missing --]]
--[[ L["Debug mode %s"] = "Debug mode %s"--]] 
--[[Translation missing --]]
--[[ L["Debug Mode (print to chat)"] = "Debug Mode (print to chat)"--]] 
--[[Translation missing --]]
--[[ L["Deduplication"] = "Deduplication"--]] 
--[[Translation missing --]]
--[[ L["Default (Slot Order)"] = "Default (Slot Order)"--]] 
--[[Translation missing --]]
--[[ L["Default Frame Level"] = "Default Frame Level"--]] 
--[[Translation missing --]]
--[[ L["Default Frame Strata"] = "Default Frame Strata"--]] 
--[[Translation missing --]]
--[[ L["Default Icon Size"] = "Default Icon Size"--]] 
--[[Translation missing --]]
--[[ L["Default Scale"] = "Default Scale"--]] 
--[[Translation missing --]]
--[[ L["Defensive buffs from other players, like Pain Suppression or Blessing of Sacrifice."] = "Defensive buffs from other players, like Pain Suppression or Blessing of Sacrifice."--]] 
--[[Translation missing --]]
--[[ L["Defensive Icon"] = "Defensive Icon"--]] 
--[[Translation missing --]]
--[[ L["Defensive Icon Alpha"] = "Defensive Icon Alpha"--]] 
L["Defensive Icon Click-Through"] = "Defensive Symbole durchklickbar"
--[[Translation missing --]]
--[[ L["Defensive Icon Tooltips"] = "Defensive Icon Tooltips"--]] 
--[[Translation missing --]]
--[[ L["Defensives"] = "Defensives"--]] 
--[[Translation missing --]]
--[[ L["Del"] = "Del"--]] 
L["Delete"] = "Löschen"
L["Delete Current Profile"] = "Aktuelles Profil löschen"
--[[Translation missing --]]
--[[ L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = ""--]] 
L["Delete Layout"] = "Layout löschen"
L["Delete layout \"%s\"?"] = "Layout \"%s\" löschen?"
L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = "Makro '%s' löschen? Alle Tastenbelegungen, welche dieses Makro nutzen, werden entfernt."
--[[Translation missing --]]
--[[ L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = ""--]] 
L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = "Profil '%s' löschen? Dies kann nicht rückgängig gemacht werden."
L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = "Lösche Profil '%s'? Dies kann nicht rückgängig gemacht werden."
--[[Translation missing --]]
--[[ L["Delete Step"] = "Delete Step"--]] 
L["Deleted profile: %s"] = "Gelöschtes Profil: %s"
L["Demon Hunter"] = "Dämonenjäger"
--[[Translation missing --]]
--[[ L["Desaturate When Missing"] = "Desaturate When Missing"--]] 
--[[Translation missing --]]
--[[ L["Description"] = "Description"--]] 
--[[Translation missing --]]
--[[ L["Description (optional)"] = "Description (optional)"--]] 
--[[Translation missing --]]
--[[ L["Dialog"] = "Dialog"--]] 
L["Direct API"] = "Direct API"
--[[Translation missing --]]
--[[ L["Direction"] = "Direction"--]] 
--[[Translation missing --]]
--[[ L["Disable (set to false)"] = "Disable (set to false)"--]] 
--[[Translation missing --]]
--[[ L["Disable Buffs"] = "Disable Buffs"--]] 
--[[Translation missing --]]
--[[ L["Disable in Combat"] = "Disable in Combat"--]] 
--[[Translation missing --]]
--[[ L["Disable Overlay"] = "Disable Overlay"--]] 
--[[Translation missing --]]
--[[ L["Disable While Mounted"] = "Disable While Mounted"--]] 
--[[Translation missing --]]
--[[ L["Disable while mounted/flying"] = "Disable while mounted/flying"--]] 
--[[Translation missing --]]
--[[ L["Disabled"] = "Disabled"--]] 
--[[Translation missing --]]
--[[ L["disabled"] = "disabled"--]] 
--[[Translation missing --]]
--[[ L["Disease"] = "Disease"--]] 
--[[Translation missing --]]
--[[ L["Dispel Detection"] = "Dispel Detection"--]] 
--[[Translation missing --]]
--[[ L["Dispel Overlay"] = "Dispel Overlay"--]] 
--[[Translation missing --]]
--[[ L["Dispel Overlay Alpha"] = "Dispel Overlay Alpha"--]] 
--[[Translation missing --]]
--[[ L["Dispel Type Colors"] = "Dispel Type Colors"--]] 
--[[Translation missing --]]
--[[ L["Dispel Type Icon"] = "Dispel Type Icon"--]] 
--[[Translation missing --]]
--[[ L["Dispellable By Me"] = "Dispellable By Me"--]] 
--[[Translation missing --]]
--[[ L["Display"] = "Display"--]] 
--[[Translation missing --]]
--[[ L["Display labels above or beside each raid group."] = "Display labels above or beside each raid group."--]] 
--[[Translation missing --]]
--[[ L["Display Mode"] = "Display Mode"--]] 
--[[Translation missing --]]
--[[ L["Displays class-specific resources (Holy Power, Chi, Combo Points, Soul Shards, Arcane Charges, Essence) as colored pips on your player frame."] = "Displays class-specific resources (Holy Power, Chi, Combo Points, Soul Shards, Arcane Charges, Essence) as colored pips on your player frame."--]] 
--[[Translation missing --]]
--[[ L["Done"] = "Done"--]] 
--[[Translation missing --]]
--[[ L["Don't show this warning again"] = "Don't show this warning again"--]] 
--[[Translation missing --]]
--[[ L["Down"] = "Down"--]] 
L["DPS"] = "DPS"
--[[Translation missing --]]
--[[ L["Drag"] = "Drag"--]] 
L["Drag to reorder groups. Top = first."] = "Ziehen zum anordnen der Gruppen. Oben = Erster."
L["Drag to reorder. Top = first."] = "Ziehen zum anordnen. Oben = Erster"
--[[Translation missing --]]
--[[ L["Drop on an anchor point to move %s"] = "Drop on an anchor point to move %s"--]] 
--[[Translation missing --]]
--[[ L["Drop on an anchor point to place %s"] = "Drop on an anchor point to place %s"--]] 
L["Druid"] = "Druide"
--[[Translation missing --]]
--[[ L["Dungeons"] = "Dungeons"--]] 
L["Duplicate"] = "Duplikat"
L["Duplicate Current"] = "Aktuelles kopieren"
--[[Translation missing --]]
--[[ L["Duplicated profile '%s' to '%s'."] = "Duplicated profile '%s' to '%s'."--]] 
--[[Translation missing --]]
--[[ L["Duration"] = "Duration"--]] 
--[[Translation missing --]]
--[[ L["Duration & stack display"] = "Duration & stack display"--]] 
--[[Translation missing --]]
--[[ L["Duration Anchor"] = "Duration Anchor"--]] 
--[[Translation missing --]]
--[[ L["Duration Color"] = "Duration Color"--]] 
--[[Translation missing --]]
--[[ L["Duration Font"] = "Duration Font"--]] 
--[[Translation missing --]]
--[[ L["Duration in seconds for the Pull Timer quick action."] = "Duration in seconds for the Pull Timer quick action."--]] 
--[[Translation missing --]]
--[[ L["Duration Offset X"] = "Duration Offset X"--]] 
--[[Translation missing --]]
--[[ L["Duration Offset Y"] = "Duration Offset Y"--]] 
--[[Translation missing --]]
--[[ L["Duration Outline"] = "Duration Outline"--]] 
--[[Translation missing --]]
--[[ L["Duration Position"] = "Duration Position"--]] 
--[[Translation missing --]]
--[[ L["Duration Scale"] = "Duration Scale"--]] 
--[[Translation missing --]]
--[[ L["Duration Text"] = "Duration Text"--]] 
--[[Translation missing --]]
--[[ L["Duration Text Color"] = "Duration Text Color"--]] 
--[[Translation missing --]]
--[[ L["Echo to Chat"] = "Echo to Chat"--]] 
--[[Translation missing --]]
--[[ L["Edge Glow (All Sides)"] = "Edge Glow (All Sides)"--]] 
--[[Translation missing --]]
--[[ L["Edit"] = "Edit"--]] 
--[[Translation missing --]]
--[[ L["Edit Binding"] = "Edit Binding"--]] 
--[[Translation missing --]]
--[[ L["Edit Copy"] = "Edit Copy"--]] 
--[[Translation missing --]]
--[[ L["Edit Layout Range"] = "Edit Layout Range"--]] 
--[[Translation missing --]]
--[[ L["Edit Macro"] = "Edit Macro"--]] 
--[[Translation missing --]]
--[[ L["Edit Settings"] = "Edit Settings"--]] 
--[[Translation missing --]]
--[[ L["Edit Steps"] = "Edit Steps"--]] 
--[[Translation missing --]]
--[[ L["Editing"] = "Editing"--]] 
--[[Translation missing --]]
--[[ L["Editing:"] = "Editing:"--]] 
--[[Translation missing --]]
--[[ L["Editing: %s"] = "Editing: %s"--]] 
--[[Translation missing --]]
--[[ L["Effects"] = "Effects"--]] 
--[[Translation missing --]]
--[[ L["Ellipsis (...)"] = "Ellipsis (...)"--]] 
--[[Translation missing --]]
--[[ L["Enable"] = "Enable"--]] 
--[[Translation missing --]]
--[[ L["Enable (set to true)"] = "Enable (set to true)"--]] 
L["Enable AFK Icon"] = "aktiviere AFK Symbol"
L["Enable Aura Designer"] = "aktiviere Aura Designer"
L["Enable Binding Tooltips"] = "aktiviere Tastenbelegung Tooltips"
L["Enable Boss Debuffs"] = "aktiviere Boss Debuffs"
L["Enable Buff Tooltips"] = "aktiviere Buff Tooltips"
L["Enable Buffs"] = "aktiviere Buffs"
--[[Translation missing --]]
--[[ L["Enable Class Power Pips"] = "Enable Class Power Pips"--]] 
L["Enable Custom Sorting"] = "Aktiviere benutzerdefinierte Sortierung"
L["Enable Dead Fade"] = "Aktiviere Verblassung wenn Tot"
--[[Translation missing --]]
--[[ L["Enable Debuff Tooltips"] = "Enable Debuff Tooltips"--]] 
--[[Translation missing --]]
--[[ L["Enable Debug Logging"] = "Enable Debug Logging"--]] 
--[[Translation missing --]]
--[[ L["Enable Defensive Icon"] = "Enable Defensive Icon"--]] 
--[[Translation missing --]]
--[[ L["Enable Defensive Icon Tooltips"] = "Enable Defensive Icon Tooltips"--]] 
--[[Translation missing --]]
--[[ L["Enable Dispel Overlay"] = "Enable Dispel Overlay"--]] 
--[[Translation missing --]]
--[[ L["Enable Element-Specific Alpha"] = "Enable Element-Specific Alpha"--]] 
--[[Translation missing --]]
--[[ L["Enable Expiring Indicators"] = "Enable Expiring Indicators"--]] 
--[[Translation missing --]]
--[[ L["Enable Frame Border Overlay"] = "Enable Frame Border Overlay"--]] 
--[[Translation missing --]]
--[[ L["Enable Frame Tooltips"] = "Enable Frame Tooltips"--]] 
--[[Translation missing --]]
--[[ L["Enable Group Labels"] = "Enable Group Labels"--]] 
--[[Translation missing --]]
--[[ L["Enable Heal Prediction"] = "Enable Heal Prediction"--]] 
--[[Translation missing --]]
--[[ L["Enable Health Threshold Fade"] = "Enable Health Threshold Fade"--]] 
--[[Translation missing --]]
--[[ L["Enable Leader Icon"] = "Enable Leader Icon"--]] 
--[[Translation missing --]]
--[[ L["Enable Missing Buff Icon"] = "Enable Missing Buff Icon"--]] 
--[[Translation missing --]]
--[[ L["Enable Offscreen Nameplates"] = "Enable Offscreen Nameplates"--]] 
--[[Translation missing --]]
--[[ L["Enable Overlay"] = "Enable Overlay"--]] 
--[[Translation missing --]]
--[[ L["Enable Permanent Mover"] = "Enable Permanent Mover"--]] 
--[[Translation missing --]]
--[[ L["Enable Personal Targeted Spells"] = "Enable Personal Targeted Spells"--]] 
--[[Translation missing --]]
--[[ L["Enable Pet Frames"] = "Enable Pet Frames"--]] 
--[[Translation missing --]]
--[[ L["Enable Phased Icon"] = "Enable Phased Icon"--]] 
--[[Translation missing --]]
--[[ L["Enable Raid Auto-Switching Layouts"] = "Enable Raid Auto-Switching Layouts"--]] 
--[[Translation missing --]]
--[[ L["Enable Raid Role Icon"] = "Enable Raid Role Icon"--]] 
--[[Translation missing --]]
--[[ L["Enable Raid Target Icon"] = "Enable Raid Target Icon"--]] 
--[[Translation missing --]]
--[[ L["Enable Ready Check Icon"] = "Enable Ready Check Icon"--]] 
L["Enable Resource Bar"] = "Aktiviere Ressourcenbalken"
--[[Translation missing --]]
--[[ L["Enable Resurrection Icon"] = "Enable Resurrection Icon"--]] 
--[[Translation missing --]]
--[[ L["Enable Resurrection Icon Tooltips"] = "Enable Resurrection Icon Tooltips"--]] 
--[[Translation missing --]]
--[[ L["Enable Sound Alert"] = "Enable Sound Alert"--]] 
L["Enable Spec Auto-Switch"] = "Aktiviere Auto-Wechsel (Spez.)"
--[[Translation missing --]]
--[[ L["Enable Status Text"] = "Enable Status Text"--]] 
--[[Translation missing --]]
--[[ L["Enable Summon Icon"] = "Enable Summon Icon"--]] 
--[[Translation missing --]]
--[[ L["Enable Targeted Spells"] = "Enable Targeted Spells"--]] 
--[[Translation missing --]]
--[[ L["Enable the checkbox above to use"] = "Enable the checkbox above to use"--]] 
--[[Translation missing --]]
--[[ L["Enable Vehicle Icon"] = "Enable Vehicle Icon"--]] 
--[[Translation missing --]]
--[[ L["enabled"] = "enabled"--]] 
--[[Translation missing --]]
--[[ L["Enabled"] = "Enabled"--]] 
--[[Translation missing --]]
--[[ L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["End"] = "End"--]] 
--[[Translation missing --]]
--[[ L["END"] = "END"--]] 
--[[Translation missing --]]
--[[ L["End (Right/Bottom)"] = "End (Right/Bottom)"--]] 
--[[Translation missing --]]
--[[ L["End of Group"] = "End of Group"--]] 
L["Energy"] = "Energie"
--[[Translation missing --]]
--[[ L["Enter a layout name"] = "Enter a layout name"--]] 
--[[Translation missing --]]
--[[ L["Enter a profile name"] = "Enter a profile name"--]] 
--[[Translation missing --]]
--[[ L["Enter a spell name above..."] = "Enter a spell name above..."--]] 
--[[Translation missing --]]
--[[ L["Enter any spell ID for range checking. Press Enter to apply. Leave empty to use dropdown selection."] = "Enter any spell ID for range checking. Press Enter to apply. Leave empty to use dropdown selection."--]] 
--[[Translation missing --]]
--[[ L["Enter name for copy of '%s':"] = "Enter name for copy of '%s':"--]] 
--[[Translation missing --]]
--[[ L["Enter new name for '%s':"] = "Enter new name for '%s':"--]] 
--[[Translation missing --]]
--[[ L["Enter new profile name:"] = "Enter new profile name:"--]] 
--[[Translation missing --]]
--[[ L["Enter WoW texture paths (file extensions are stripped automatically). Leave empty to use DF Icons as fallback."] = "Enter WoW texture paths (file extensions are stripped automatically). Leave empty to use DF Icons as fallback."--]] 
--[[Translation missing --]]
--[[ L["Errors Only"] = "Errors Only"--]] 
L["Evoker"] = "Rufer"
--[[Translation missing --]]
--[[ L["Exit Editing"] = "Exit Editing"--]] 
--[[Translation missing --]]
--[[ L["Expire Alert"] = "Expire Alert"--]] 
--[[Translation missing --]]
--[[ L["Expiring"] = "Expiring"--]] 
--[[Translation missing --]]
--[[ L["Expiring Alpha"] = "Expiring Alpha"--]] 
--[[Translation missing --]]
--[[ L["Expiring Alpha Override"] = "Expiring Alpha Override"--]] 
--[[Translation missing --]]
--[[ L["Expiring Color"] = "Expiring Color"--]] 
--[[Translation missing --]]
--[[ L["Expiring Color Override"] = "Expiring Color Override"--]] 
--[[Translation missing --]]
--[[ L["Expiring Indicator"] = "Expiring Indicator"--]] 
--[[Translation missing --]]
--[[ L["Expiring indicator tracks the trigger with the least time remaining."] = "Expiring indicator tracks the trigger with the least time remaining."--]] 
--[[Translation missing --]]
--[[ L["Expiring indicator tracks the trigger with the most time remaining."] = "Expiring indicator tracks the trigger with the most time remaining."--]] 
--[[Translation missing --]]
--[[ L["Expiring Threshold (%)"] = "Expiring Threshold (%)"--]] 
--[[Translation missing --]]
--[[ L["Expiring Threshold (seconds)"] = "Expiring Threshold (seconds)"--]] 
--[[Translation missing --]]
--[[ L["Export"] = "Export"--]] 
--[[Translation missing --]]
--[[ L["Export failed. Please try again or check for errors."] = "Export failed. Please try again or check for errors."--]] 
--[[Translation missing --]]
--[[ L["Export Settings"] = "Export Settings"--]] 
--[[Translation missing --]]
--[[ L["Export Wizard"] = "Export Wizard"--]] 
--[[Translation missing --]]
--[[ L["External"] = "External"--]] 
--[[Translation missing --]]
--[[ L["External Defensives"] = "External Defensives"--]] 
--[[Translation missing --]]
--[[ L["Fade frames or elements when a unit's health is above the set threshold (e.g. 100% or 80%)."] = "Fade frames or elements when a unit's health is above the set threshold (e.g. 100% or 80%)."--]] 
L["Fading"] = "Verblassen"
--[[Translation missing --]]
--[[ L["Fill Color"] = "Fill Color"--]] 
L["Fill Direction"] = "Füllungsrichtung"
--[[Translation missing --]]
--[[ L["Fill Pulsate"] = "Fill Pulsate"--]] 
--[[Translation missing --]]
--[[ L["Finish"] = "Finish"--]] 
--[[Translation missing --]]
--[[ L["First question"] = "First question"--]] 
--[[Translation missing --]]
--[[ L["First Unit"] = "First Unit"--]] 
--[[Translation missing --]]
--[[ L["Fixed at 20 players (Mythic)"] = "Fixed at 20 players (Mythic)"--]] 
--[[Translation missing --]]
--[[ L["Flat Grid Settings"] = "Flat Grid Settings"--]] 
--[[Translation missing --]]
--[[ L["Floating Bar"] = "Floating Bar"--]] 
--[[Translation missing --]]
--[[ L["Floating Bar Anchor"] = "Floating Bar Anchor"--]] 
--[[Translation missing --]]
--[[ L["Floating Bar Position"] = "Floating Bar Position"--]] 
L["Focus"] = "Fokus"
L["Font"] = "Schriftart"
--[[Translation missing --]]
--[[ L["Font Outline"] = "Font Outline"--]] 
--[[Translation missing --]]
--[[ L["Font Settings"] = "Font Settings"--]] 
--[[Translation missing --]]
--[[ L["Font settings for icons displayed as text (Summon, Res, AFK, etc.)"] = "Font settings for icons displayed as text (Summon, Res, AFK, etc.)"--]] 
L["Font Size"] = "Schriftgröße"
--[[Translation missing --]]
--[[ L["For items/macros that need @cursor, @mouseover, etc. Consumes the keybind and prevents action bar use."] = "For items/macros that need @cursor, @mouseover, etc. Consumes the keybind and prevents action bar use."--]] 
--[[Translation missing --]]
--[[ L["For nameplates & world units. %sDoes not work with action bar binds.%s"] = "For nameplates & world units. %sDoes not work with action bar binds.%s"--]] 
--[[Translation missing --]]
--[[ L["Frame"] = "Frame"--]] 
--[[Translation missing --]]
--[[ L["Frame Alpha"] = "Frame Alpha"--]] 
--[[Translation missing --]]
--[[ L["Frame Alpha (Above Threshold)"] = "Frame Alpha (Above Threshold)"--]] 
--[[Translation missing --]]
--[[ L["Frame Alpha (Out of Range)"] = "Frame Alpha (Out of Range)"--]] 
--[[Translation missing --]]
--[[ L["Frame Border Overlay"] = "Frame Border Overlay"--]] 
--[[Translation missing --]]
--[[ L["Frame Display"] = "Frame Display"--]] 
--[[Translation missing --]]
--[[ L["Frame Growth"] = "Frame Growth"--]] 
--[[Translation missing --]]
--[[ L["Frame Height"] = "Frame Height"--]] 
--[[Translation missing --]]
--[[ L["Frame Level"] = "Frame Level"--]] 
--[[Translation missing --]]
--[[ L["Frame Level Offset"] = "Frame Level Offset"--]] 
--[[Translation missing --]]
--[[ L["Frame opacity when health is above the threshold."] = "Frame opacity when health is above the threshold."--]] 
--[[Translation missing --]]
--[[ L["Frame Padding"] = "Frame Padding"--]] 
--[[Translation missing --]]
--[[ L["FRAME PREVIEW"] = "FRAME PREVIEW"--]] 
--[[Translation missing --]]
--[[ L["Frame Scale"] = "Frame Scale"--]] 
--[[Translation missing --]]
--[[ L["Frame Size"] = "Frame Size"--]] 
--[[Translation missing --]]
--[[ L["Frame Spacing"] = "Frame Spacing"--]] 
--[[Translation missing --]]
--[[ L["Frame Strata"] = "Frame Strata"--]] 
--[[Translation missing --]]
--[[ L["Frame Tooltips"] = "Frame Tooltips"--]] 
--[[Translation missing --]]
--[[ L["Frame Width"] = "Frame Width"--]] 
--[[Translation missing --]]
--[[ L["FRAME-LEVEL EFFECTS"] = "FRAME-LEVEL EFFECTS"--]] 
--[[Translation missing --]]
--[[ L["Frames centered on screen."] = "Frames centered on screen."--]] 
--[[Translation missing --]]
--[[ L["Frames Grow From"] = "Frames Grow From"--]] 
--[[Translation missing --]]
--[[ L["Frames locked."] = "Frames locked."--]] 
--[[Translation missing --]]
--[[ L["Frames unlocked. Drag to move, right-click to lock."] = "Frames unlocked. Drag to move, right-click to lock."--]] 
--[[Translation missing --]]
--[[ L["Frames: %s"] = "Frames: %s"--]] 
--[[Translation missing --]]
--[[ L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["FrameSort Integration"] = "FrameSort Integration"--]] 
--[[Translation missing --]]
--[[ L["Friendly Only"] = "Friendly Only"--]] 
--[[Translation missing --]]
--[[ L["Full Frame"] = "Full Frame"--]] 
--[[Translation missing --]]
--[[ L["Fully Combat Safe: Frames will update normally during combat."] = "Fully Combat Safe: Frames will update normally during combat."--]] 
--[[Translation missing --]]
--[[ L["Fury"] = "Fury"--]] 
--[[Translation missing --]]
--[[ L["G1"] = "G1"--]] 
--[[Translation missing --]]
--[[ L["Game Default"] = "Game Default"--]] 
--[[Translation missing --]]
--[[ L["Gap Between Pips"] = "Gap Between Pips"--]] 
L["General"] = "Allgemein"
--[[Translation missing --]]
--[[ L["General Import"] = "General Import"--]] 
--[[Translation missing --]]
--[[ L["Generate Export String"] = "Generate Export String"--]] 
--[[Translation missing --]]
--[[ L["Gets its own independent border overlay. Multiple custom borders can be visible at the same time."] = "Gets its own independent border overlay. Multiple custom borders can be visible at the same time."--]] 
--[[Translation missing --]]
--[[ L["Global"] = "Global"--]] 
L["Global Font Settings"] = "Globale Schriftarten Einstellungen"
L["Global Fonts"] = "Globale Schriftarten"
--[[Translation missing --]]
--[[ L["Global Keybind:"] = "Global Keybind:"--]] 
--[[Translation missing --]]
--[[ L["Glow"] = "Glow"--]] 
--[[Translation missing --]]
--[[ L["Glow (ADD)"] = "Glow (ADD)"--]] 
--[[Translation missing --]]
--[[ L["Glow Alpha"] = "Glow Alpha"--]] 
--[[Translation missing --]]
--[[ L["Glow Color"] = "Glow Color"--]] 
--[[Translation missing --]]
--[[ L["Glow Style"] = "Glow Style"--]] 
--[[Translation missing --]]
--[[ L["Go Back"] = "Go Back"--]] 
--[[Translation missing --]]
--[[ L["Goes to: %s"] = "Goes to: %s"--]] 
--[[Translation missing --]]
--[[ L["Gradient"] = "Gradient"--]] 
--[[Translation missing --]]
--[[ L["Gradient Color Alpha"] = "Gradient Color Alpha"--]] 
--[[Translation missing --]]
--[[ L["Gradient Intensity"] = "Gradient Intensity"--]] 
--[[Translation missing --]]
--[[ L["Gradient Opacity"] = "Gradient Opacity"--]] 
--[[Translation missing --]]
--[[ L["Gradient Position"] = "Gradient Position"--]] 
--[[Translation missing --]]
--[[ L["Gradient Size"] = "Gradient Size"--]] 
--[[Translation missing --]]
--[[ L["Grid"] = "Grid"--]] 
--[[Translation missing --]]
--[[ L["Grid Layout"] = "Grid Layout"--]] 
--[[Translation missing --]]
--[[ L["Group"] = "Group"--]] 
--[[Translation missing --]]
--[[ L["Group 1"] = "Group 1"--]] 
--[[Translation missing --]]
--[[ L["Group Display Order"] = "Group Display Order"--]] 
L["Group Labels"] = "Gruppenbezeichnung"
--[[Translation missing --]]
--[[ L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Group Layout Settings"] = "Group Layout Settings"--]] 
--[[Translation missing --]]
--[[ L["GROUP NAME"] = "GROUP NAME"--]] 
--[[Translation missing --]]
--[[ L["Group Position"] = "Group Position"--]] 
--[[Translation missing --]]
--[[ L["Group Roster"] = "Group Roster"--]] 
--[[Translation missing --]]
--[[ L["Group Settings"] = "Group Settings"--]] 
--[[Translation missing --]]
--[[ L["Group Spacing"] = "Group Spacing"--]] 
--[[Translation missing --]]
--[[ L["Group Visibility"] = "Group Visibility"--]] 
--[[Translation missing --]]
--[[ L["Group X Offset"] = "Group X Offset"--]] 
--[[Translation missing --]]
--[[ L["Group Y Offset"] = "Group Y Offset"--]] 
--[[Translation missing --]]
--[[ L["Groups Grow From"] = "Groups Grow From"--]] 
--[[Translation missing --]]
--[[ L["Groups Per Column"] = "Groups Per Column"--]] 
--[[Translation missing --]]
--[[ L["Groups Per Row"] = "Groups Per Row"--]] 
--[[Translation missing --]]
--[[ L["Growth"] = "Growth"--]] 
--[[Translation missing --]]
--[[ L["GROWTH"] = "GROWTH"--]] 
--[[Translation missing --]]
--[[ L["Growth Direction"] = "Growth Direction"--]] 
--[[Translation missing --]]
--[[ L["GUI reset to default size, scale, and position."] = "GUI reset to default size, scale, and position."--]] 
--[[Translation missing --]]
--[[ L["Guided setup for configuring which buffs and debuffs appear on your frames."] = "Guided setup for configuring which buffs and debuffs appear on your frames."--]] 
--[[Translation missing --]]
--[[ L["Guided setup for the frame border overlay that highlights boss debuffs."] = "Guided setup for the frame border overlay that highlights boss debuffs."--]] 
--[[Translation missing --]]
--[[ L["Handle Color"] = "Handle Color"--]] 
--[[Translation missing --]]
--[[ L["Handle Height"] = "Handle Height"--]] 
--[[Translation missing --]]
--[[ L["Handle is invisible until you hover over it. Fades in and out smoothly."] = "Handle is invisible until you hover over it. Fades in and out smoothly."--]] 
--[[Translation missing --]]
--[[ L["Handle Position"] = "Handle Position"--]] 
--[[Translation missing --]]
--[[ L["Handle Width"] = "Handle Width"--]] 
--[[Translation missing --]]
--[[ L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Having trouble with buffs or debuffs? Run the setup wizard for guided help."] = "Having trouble with buffs or debuffs? Run the setup wizard for guided help."--]] 
--[[Translation missing --]]
--[[ L["Heal Absorb"] = "Heal Absorb"--]] 
--[[Translation missing --]]
--[[ L["Heal Prediction"] = "Heal Prediction"--]] 
--[[Translation missing --]]
--[[ L["Heal Prediction Color"] = "Heal Prediction Color"--]] 
L["Healer"] = "Heiler"
L["Healers"] = "Heiler"
L["Health"] = "Leben"
L["Health Bar"] = "Lebensbalken"
L["Health Bar Alpha"] = "Deckkraft für Lebensbalken"
--[[Translation missing --]]
--[[ L["Health Bar Color"] = "Health Bar Color"--]] 
--[[Translation missing --]]
--[[ L["Health Bar Texture"] = "Health Bar Texture"--]] 
--[[Translation missing --]]
--[[ L["Health Deficit"] = "Health Deficit"--]] 
--[[Translation missing --]]
--[[ L["Health Format"] = "Health Format"--]] 
--[[Translation missing --]]
--[[ L["Health Gradient"] = "Health Gradient"--]] 
--[[Translation missing --]]
--[[ L["Health Text"] = "Health Text"--]] 
--[[Translation missing --]]
--[[ L["Health Text Alpha"] = "Health Text Alpha"--]] 
--[[Translation missing --]]
--[[ L["Health Text Anchor"] = "Health Text Anchor"--]] 
--[[Translation missing --]]
--[[ L["Health Text Color"] = "Health Text Color"--]] 
--[[Translation missing --]]
--[[ L["Health Threshold (%)"] = "Health Threshold (%)"--]] 
--[[Translation missing --]]
--[[ L["Health Threshold Fading"] = "Health Threshold Fading"--]] 
--[[Translation missing --]]
--[[ L["Health X Offset"] = "Health X Offset"--]] 
--[[Translation missing --]]
--[[ L["Health Y Offset"] = "Health Y Offset"--]] 
--[[Translation missing --]]
--[[ L["Height"] = "Height"--]] 
L["Height / Thickness"] = "Höhe / Dicke"
--[[Translation missing --]]
--[[ L["Here's what we'll set up:"] = "Here's what we'll set up:"--]] 
--[[Translation missing --]]
--[[ L["Hidden"] = "Hidden"--]] 
--[[Translation missing --]]
--[[ L["Hide % Symbol"] = "Hide % Symbol"--]] 
--[[Translation missing --]]
--[[ L["Hide Above (seconds)"] = "Hide Above (seconds)"--]] 
--[[Translation missing --]]
--[[ L["Hide Above Threshold"] = "Hide Above Threshold"--]] 
--[[Translation missing --]]
--[[ L["Hide Blizzard Party Frames"] = "Hide Blizzard Party Frames"--]] 
--[[Translation missing --]]
--[[ L["Hide Blizzard Player Frame"] = "Hide Blizzard Player Frame"--]] 
--[[Translation missing --]]
--[[ L["Hide Blizzard Raid Frames"] = "Hide Blizzard Raid Frames"--]] 
--[[Translation missing --]]
--[[ L["Hide buffs from the buff bar when they are already displayed by the Defensive Bar or Aura Designer."] = "Hide buffs from the buff bar when they are already displayed by the Defensive Bar or Aura Designer."--]] 
--[[Translation missing --]]
--[[ L["Hide Cooldown Swipe"] = "Hide Cooldown Swipe"--]] 
L["Hide duplicate buffs"] = "Verstecke doppelte Buffs"
--[[Translation missing --]]
--[[ L["Hide Duration Above Threshold"] = "Hide Duration Above Threshold"--]] 
--[[Translation missing --]]
--[[ L["Hide Icon (Text Only)"] = "Hide Icon (Text Only)"--]] 
--[[Translation missing --]]
--[[ L["Hide in Combat"] = "Hide in Combat"--]] 
--[[Translation missing --]]
--[[ L["Hide raid buffs from buff bar"] = "Hide raid buffs from buff bar"--]] 
--[[Translation missing --]]
--[[ L["Hide Self from Party Frames"] = "Hide Self from Party Frames"--]] 
--[[Translation missing --]]
--[[ L["Hide specific buffs and debuffs from your frames. Click a spell to toggle blacklisting. Blacklisted auras will not appear on buff bars or Aura Designer indicators."] = "Hide specific buffs and debuffs from your frames. Click a spell to toggle blacklisting. Blacklisted auras will not appear on buff bars or Aura Designer indicators."--]] 
--[[Translation missing --]]
--[[ L["Hide Tooltip on Mouseover"] = "Hide Tooltip on Mouseover"--]] 
--[[Translation missing --]]
--[[ L["Hides Blizzard frames but keeps them active for aura filtering."] = "Hides Blizzard frames but keeps them active for aura filtering."--]] 
--[[Translation missing --]]
--[[ L["Hides the default Blizzard player portrait and health bar."] = "Hides the default Blizzard player portrait and health bar."--]] 
--[[Translation missing --]]
--[[ L["Hides the handle during combat. If disabled, the handle changes color to indicate it is locked."] = "Hides the handle during combat. If disabled, the handle changes color to indicate it is locked."--]] 
--[[Translation missing --]]
--[[ L["High"] = "High"--]] 
--[[Translation missing --]]
--[[ L["High Health (100%)"] = "High Health (100%)"--]] 
--[[Translation missing --]]
--[[ L["High Threat (Yellow)"] = "High Threat (Yellow)"--]] 
--[[Translation missing --]]
--[[ L["Higher values render the bar above other elements. Frame border is at level 10."] = "Higher values render the bar above other elements. Frame border is at level 10."--]] 
--[[Translation missing --]]
--[[ L["Highest Threat (Orange)"] = "Highest Threat (Orange)"--]] 
--[[Translation missing --]]
--[[ L["Highlight"] = "Highlight"--]] 
--[[Translation missing --]]
--[[ L["Highlight Color"] = "Highlight Color"--]] 
--[[Translation missing --]]
--[[ L["Highlight Dispellable"] = "Highlight Dispellable"--]] 
--[[Translation missing --]]
--[[ L["Highlight for User"] = "Highlight for User"--]] 
--[[Translation missing --]]
--[[ L["Highlight for user to configure"] = "Highlight for user to configure"--]] 
--[[Translation missing --]]
--[[ L["Highlight Important Spells"] = "Highlight Important Spells"--]] 
--[[Translation missing --]]
--[[ L["Highlight Settings"] = "Highlight Settings"--]] 
--[[Translation missing --]]
--[[ L["Highlight Settings (comma-separated dbKeys)"] = "Highlight Settings (comma-separated dbKeys)"--]] 
--[[Translation missing --]]
--[[ L["Highlight Style"] = "Highlight Style"--]] 
--[[Translation missing --]]
--[[ L["Highlighted Units"] = "Highlighted Units"--]] 
--[[Translation missing --]]
--[[ L["Highlights"] = "Highlights"--]] 
--[[Translation missing --]]
--[[ L["Highlights: %s"] = "Highlights: %s"--]] 
--[[Translation missing --]]
--[[ L["Horizontal"] = "Horizontal"--]] 
--[[Translation missing --]]
--[[ L["Horizontal anchors lay pips left-to-right. Left/Right anchors stack pips vertically along the frame side."] = "Horizontal anchors lay pips left-to-right. Left/Right anchors stack pips vertically along the frame side."--]] 
--[[Translation missing --]]
--[[ L["Horizontal Spacing"] = "Horizontal Spacing"--]] 
--[[Translation missing --]]
--[[ L["Horizontal: Players stack vertically, groups grow left-to-right."] = "Horizontal: Players stack vertically, groups grow left-to-right."--]] 
--[[Translation missing --]]
--[[ L["Hostile Only"] = "Hostile Only"--]] 
--[[Translation missing --]]
--[[ L["Hover Highlight"] = "Hover Highlight"--]] 
--[[Translation missing --]]
--[[ L["Hover Settings"] = "Hover Settings"--]] 
--[[Translation missing --]]
--[[ L["How it works"] = "How it works"--]] 
--[[Translation missing --]]
--[[ L["How often to check range (seconds). Lower = more responsive but higher CPU. Default: 0.5s"] = "How often to check range (seconds). Lower = more responsive but higher CPU. Default: 0.5s"--]] 
--[[Translation missing --]]
--[[ L["How would you like to configure the filters?"] = "How would you like to configure the filters?"--]] 
--[[Translation missing --]]
--[[ L["HP"] = "HP"--]] 
L["Hunter"] = "Jäger"
--[[Translation missing --]]
--[[ L["I understand, enable it"] = "I understand, enable it"--]] 
--[[Translation missing --]]
--[[ L["I, II, III..."] = "I, II, III..."--]] 
L["Icon"] = "Symbol"
--[[Translation missing --]]
--[[ L["Icon Height"] = "Icon Height"--]] 
--[[Translation missing --]]
--[[ L["Icon Offset X"] = "Icon Offset X"--]] 
--[[Translation missing --]]
--[[ L["Icon Offset Y"] = "Icon Offset Y"--]] 
--[[Translation missing --]]
--[[ L["Icon Opacity"] = "Icon Opacity"--]] 
--[[Translation missing --]]
--[[ L["Icon Position"] = "Icon Position"--]] 
--[[Translation missing --]]
--[[ L["Icon Ratio"] = "Icon Ratio"--]] 
--[[Translation missing --]]
--[[ L["Icon Size"] = "Icon Size"--]] 
--[[Translation missing --]]
--[[ L["Icon size, scale & border"] = "Icon size, scale & border"--]] 
--[[Translation missing --]]
--[[ L["Icon Spacing"] = "Icon Spacing"--]] 
--[[Translation missing --]]
--[[ L["Icon Style"] = "Icon Style"--]] 
--[[Translation missing --]]
--[[ L["Icon Width"] = "Icon Width"--]] 
--[[Translation missing --]]
--[[ L["Icons"] = "Icons"--]] 
L["Icons Alpha"] = "Deckkraft für Symbole"
--[[Translation missing --]]
--[[ L["Icons Per Row"] = "Icons Per Row"--]] 
--[[Translation missing --]]
--[[ L["Ignore"] = "Ignore"--]] 
--[[Translation missing --]]
--[[ L["Ignore Full Health Fade"] = "Ignore Full Health Fade"--]] 
--[[Translation missing --]]
--[[ L["Import"] = "Import"--]] 
--[[Translation missing --]]
--[[ L["Import All"] = "Import All"--]] 
--[[Translation missing --]]
--[[ L["Import All (%d)"] = "Import All (%d)"--]] 
--[[Translation missing --]]
--[[ L["Import Buffs Tab Defaults"] = "Import Buffs Tab Defaults"--]] 
--[[Translation missing --]]
--[[ L["Import Click Casting Profile"] = "Import Click Casting Profile"--]] 
--[[Translation missing --]]
--[[ L["Import failed"] = "Import failed"--]] 
--[[Translation missing --]]
--[[ L["Import from Buffs Tab"] = "Import from Buffs Tab"--]] 
--[[Translation missing --]]
--[[ L["Import Selected"] = "Import Selected"--]] 
--[[Translation missing --]]
--[[ L["Import Settings"] = "Import Settings"--]] 
--[[Translation missing --]]
--[[ L["Import String"] = "Import String"--]] 
--[[Translation missing --]]
--[[ L["Import Wizard"] = "Import Wizard"--]] 
--[[Translation missing --]]
--[[ L["Import WoW Macros"] = "Import WoW Macros"--]] 
--[[Translation missing --]]
--[[ L["Import your existing Buffs tab settings as defaults for all auras. Compatible settings will be applied automatically."] = "Import your existing Buffs tab settings as defaults for all auras. Compatible settings will be applied automatically."--]] 
--[[Translation missing --]]
--[[ L["Import/Export"] = "Import/Export"--]] 
--[[Translation missing --]]
--[[ L["Important Spells"] = "Important Spells"--]] 
--[[Translation missing --]]
--[[ L["Important Spells Only"] = "Important Spells Only"--]] 
--[[Translation missing --]]
--[[ L["Imported Profile"] = "Imported Profile"--]] 
--[[Translation missing --]]
--[[ L["Imported!"] = "Imported!"--]] 
--[[Translation missing --]]
--[[ L["In Combat Only"] = "In Combat Only"--]] 
--[[Translation missing --]]
--[[ L["In Direct mode, all active big and external defensives are shown per unit (not just one). Adjust max count and layout on the Defensive Icon page."] = "In Direct mode, all active big and external defensives are shown per unit (not just one). Adjust max count and layout on the Defensive Icon page."--]] 
--[[Translation missing --]]
--[[ L["Incompatible Bindings"] = "Incompatible Bindings"--]] 
--[[Translation missing --]]
--[[ L["Indicators"] = "Indicators"--]] 
--[[Translation missing --]]
--[[ L["INFERRED TRACKING"] = "INFERRED TRACKING"--]] 
--[[Translation missing --]]
--[[ L["Info (All)"] = "Info (All)"--]] 
--[[Translation missing --]]
--[[ L["Inherit (Frame)"] = "Inherit (Frame)"--]] 
L["Insanity"] = "Wahnsinn"
--[[Translation missing --]]
--[[ L["Inset"] = "Inset"--]] 
--[[Translation missing --]]
--[[ L["Inside (Bottom)"] = "Inside (Bottom)"--]] 
--[[Translation missing --]]
--[[ L["Inside (Top)"] = "Inside (Top)"--]] 
--[[Translation missing --]]
--[[ L["Instanced / PvP"] = "Instanced / PvP"--]] 
L["Integration"] = "Integration"
L["Integration (advanced):"] = "Integration (erweitert):"
L["Integrations"] = "Integrationen"
--[[Translation missing --]]
--[[ L["Interrupt Settings"] = "Interrupt Settings"--]] 
--[[Translation missing --]]
--[[ L["Interrupted Visual"] = "Interrupted Visual"--]] 
--[[Translation missing --]]
--[[ L["is secret-tracked"] = "is secret-tracked"--]] 
--[[Translation missing --]]
--[[ L["Items"] = "Items"--]] 
--[[Translation missing --]]
--[[ L["Join a raid group (2-5 players works best)"] = "Join a raid group (2-5 players works best)"--]] 
--[[Translation missing --]]
--[[ L["Keep Buffs"] = "Keep Buffs"--]] 
--[[Translation missing --]]
--[[ L["Keep when offline/left"] = "Keep when offline/left"--]] 
--[[Translation missing --]]
--[[ L["Label Color"] = "Label Color"--]] 
--[[Translation missing --]]
--[[ L["Label Format"] = "Label Format"--]] 
--[[Translation missing --]]
--[[ L["Label Name"] = "Label Name"--]] 
--[[Translation missing --]]
--[[ L["Label Position"] = "Label Position"--]] 
--[[Translation missing --]]
--[[ L["Label:"] = "Label:"--]] 
--[[Translation missing --]]
--[[ L["Last Unit"] = "Last Unit"--]] 
--[[Translation missing --]]
--[[ L["Layout"] = "Layout"--]] 
--[[Translation missing --]]
--[[ L["Layout (Direct Mode)"] = "Layout (Direct Mode)"--]] 
--[[Translation missing --]]
--[[ L["Layout Direction"] = "Layout Direction"--]] 
--[[Translation missing --]]
--[[ L["Layout Group"] = "Layout Group"--]] 
--[[Translation missing --]]
--[[ L["Layout Groups"] = "Layout Groups"--]] 
--[[Translation missing --]]
--[[ L["Layout Mode"] = "Layout Mode"--]] 
--[[Translation missing --]]
--[[ L["Layout Name"] = "Layout Name"--]] 
--[[Translation missing --]]
--[[ L["Layout:"] = "Layout:"--]] 
--[[Translation missing --]]
--[[ L["Leader Icon"] = "Leader Icon"--]] 
--[[Translation missing --]]
--[[ L["Left"] = "Left"--]] 
L["Left Click"] = "Linksklick"
--[[Translation missing --]]
--[[ L["Left Edge"] = "Left Edge"--]] 
--[[Translation missing --]]
--[[ L["Left of Health Bar"] = "Left of Health Bar"--]] 
--[[Translation missing --]]
--[[ L["Left of Owner"] = "Left of Owner"--]] 
--[[Translation missing --]]
--[[ L["Left of Party"] = "Left of Party"--]] 
--[[Translation missing --]]
--[[ L["Left of Raid"] = "Left of Raid"--]] 
--[[Translation missing --]]
--[[ L["Left to Right"] = "Left to Right"--]] 
--[[Translation missing --]]
--[[ L["Left-click to add/edit binding"] = "Left-click to add/edit binding"--]] 
--[[Translation missing --]]
--[[ L["Left-click: Bind"] = "Left-click: Bind"--]] 
--[[Translation missing --]]
--[[ L["Let Masque Control Aura Borders"] = "Let Masque Control Aura Borders"--]] 
--[[Translation missing --]]
--[[ L["Let me configure it myself"] = "Let me configure it myself"--]] 
--[[Translation missing --]]
--[[ L["Line"] = "Line"--]] 
--[[Translation missing --]]
--[[ L["Link: %s"] = "Link: %s"--]] 
--[[Translation missing --]]
--[[ L["Linked Settings"] = "Linked Settings"--]] 
--[[Translation missing --]]
--[[ L["List"] = "List"--]] 
--[[Translation missing --]]
--[[ L["Loading..."] = "Loading..."--]] 
--[[Translation missing --]]
--[[ L["LOADOUT ASSIGNMENTS"] = "LOADOUT ASSIGNMENTS"--]] 
--[[Translation missing --]]
--[[ L["Loadout expects: %s"] = "Loadout expects: %s"--]] 
--[[Translation missing --]]
--[[ L["Lock"] = "Lock"--]] 
--[[Translation missing --]]
--[[ L["Lock Frames"] = "Lock Frames"--]] 
--[[Translation missing --]]
--[[ L["Lock Position"] = "Lock Position"--]] 
--[[Translation missing --]]
--[[ L["Log Viewer"] = "Log Viewer"--]] 
--[[Translation missing --]]
--[[ L["Loop Interval (sec)"] = "Loop Interval (sec)"--]] 
--[[Translation missing --]]
--[[ L["Low"] = "Low"--]] 
--[[Translation missing --]]
--[[ L["Low Health (0%)"] = "Low Health (0%)"--]] 
--[[Translation missing --]]
--[[ L["Lunar Power"] = "Lunar Power"--]] 
--[[Translation missing --]]
--[[ L["Macro Options:"] = "Macro Options:"--]] 
--[[Translation missing --]]
--[[ L["Macro Text:"] = "Macro Text:"--]] 
--[[Translation missing --]]
--[[ L["Macros"] = "Macros"--]] 
L["Mage"] = "Magier"
--[[Translation missing --]]
--[[ L["Magic"] = "Magic"--]] 
--[[Translation missing --]]
--[[ L["Major defensive cooldowns like Divine Shield, Ice Block, or Barkskin."] = "Major defensive cooldowns like Divine Shield, Ice Block, or Barkskin."--]] 
L["Make icons click-through for external click-casting addons. Not needed for DF built-in click-casting."] = "Mache Symbole durchklickbar für externe Klickzauber Addons. Nicht nötig für das eingebaute DF Klickzaubern."
--[[Translation missing --]]
--[[ L["Makes this binding work everywhere, consuming the keybind."] = "Makes this binding work everywhere, consuming the keybind."--]] 
L["Mana"] = "Mana"
--[[Translation missing --]]
--[[ L["Manage"] = "Manage"--]] 
--[[Translation missing --]]
--[[ L["Manage Profiles"] = "Manage Profiles"--]] 
--[[Translation missing --]]
--[[ L["Marching Ants"] = "Marching Ants"--]] 
L["Mark of the Wild (Druid)"] = "Mal der Wildnis (Druide)"
L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = "Masque addon ist nicht installiert. Masque erlaubt es dir Buff/Debuff Symbole mit eigenen Texturen anzuzeigen. Installiere Masque von CurseForge um es zu aktivieren."
L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = "Masque addon ist nicht installiert. Masque erlaubt es dir Buff/Debuff Symbole mit eigenen Texturen anzuzeigen. Installiere Masque von CurseForge um es zu aktivieren."
L["Masque Integration"] = "Masque Integration"
--[[Translation missing --]]
--[[ L["Match Frame Height"] = "Match Frame Height"--]] 
--[[Translation missing --]]
--[[ L["Match Frame Width"] = "Match Frame Width"--]] 
--[[Translation missing --]]
--[[ L["Match Health Bar Width/Height"] = "Match Health Bar Width/Height"--]] 
L["Match Owner Height"] = "Höhe an Besitzer anpassen"
L["Match Owner Width"] = "Breite an Besitzer anpassen"
--[[Translation missing --]]
--[[ L["Matched (not applied)"] = "Matched (not applied)"--]] 
--[[Translation missing --]]
--[[ L["Max Buffs"] = "Max Buffs"--]] 
--[[Translation missing --]]
--[[ L["Max Debuffs"] = "Max Debuffs"--]] 
--[[Translation missing --]]
--[[ L["Max Health"] = "Max Health"--]] 
--[[Translation missing --]]
--[[ L["Max Icons"] = "Max Icons"--]] 
--[[Translation missing --]]
--[[ L["Max Length (0=off)"] = "Max Length (0=off)"--]] 
--[[Translation missing --]]
--[[ L["Max Log Entries"] = "Max Log Entries"--]] 
--[[Translation missing --]]
--[[ L["Max Name Length"] = "Max Name Length"--]] 
--[[Translation missing --]]
--[[ L["Max Slots"] = "Max Slots"--]] 
--[[Translation missing --]]
--[[ L["Medium"] = "Medium"--]] 
--[[Translation missing --]]
--[[ L["Medium Health (50%)"] = "Medium Health (50%)"--]] 
--[[Translation missing --]]
--[[ L["Melee DPS"] = "Melee DPS"--]] 
--[[Translation missing --]]
--[[ L["MEMBERS"] = "MEMBERS"--]] 
--[[Translation missing --]]
--[[ L["Min Stacks to Show"] = "Min Stacks to Show"--]] 
--[[Translation missing --]]
--[[ L["Minimum Log Level"] = "Minimum Log Level"--]] 
--[[Translation missing --]]
--[[ L["Missing Buff Alpha"] = "Missing Buff Alpha"--]] 
--[[Translation missing --]]
--[[ L["Missing Buffs"] = "Missing Buffs"--]] 
L["Missing Health"] = "Fehlendes Leben"
L["Missing Health Alpha"] = "Deckkraft für fehlendes Leben"
L["Missing Health Color"] = "Farbe für fehlendes Leben"
L["Missing Health Only"] = "Nur fehlendes Leben"
L["Missing Health Texture"] = "Textur für fehlendes Leben"
--[[Translation missing --]]
--[[ L["Mode"] = "Mode"--]] 
--[[Translation missing --]]
--[[ L["Modified"] = "Modified"--]] 
L["Monk"] = "Mönch"
--[[Translation missing --]]
--[[ L["Monochrome"] = "Monochrome"--]] 
--[[Translation missing --]]
--[[ L["Moves the glow to the opposite side (no HP side instead of max HP side)."] = "Moves the glow to the opposite side (no HP side instead of max HP side)."--]] 
--[[Translation missing --]]
--[[ L["Multi Select"] = "Multi Select"--]] 
--[[Translation missing --]]
--[[ L["My Group First"] = "My Group First"--]] 
--[[Translation missing --]]
--[[ L["My Wizards"] = "My Wizards"--]] 
--[[Translation missing --]]
--[[ L["Mythic"] = "Mythic"--]] 
--[[Translation missing --]]
--[[ L["Mythic has fixed range"] = "Mythic has fixed range"--]] 
--[[Translation missing --]]
--[[ L["Name"] = "Name"--]] 
--[[Translation missing --]]
--[[ L["Name Alpha"] = "Name Alpha"--]] 
--[[Translation missing --]]
--[[ L["Name already exists"] = "Name already exists"--]] 
--[[Translation missing --]]
--[[ L["Name Anchor"] = "Name Anchor"--]] 
--[[Translation missing --]]
--[[ L["Name Color"] = "Name Color"--]] 
--[[Translation missing --]]
--[[ L["Name Text"] = "Name Text"--]] 
--[[Translation missing --]]
--[[ L["Name Text Alpha"] = "Name Text Alpha"--]] 
--[[Translation missing --]]
--[[ L["Name Text Color"] = "Name Text Color"--]] 
--[[Translation missing --]]
--[[ L["Name X Offset"] = "Name X Offset"--]] 
--[[Translation missing --]]
--[[ L["Name Y Offset"] = "Name Y Offset"--]] 
--[[Translation missing --]]
--[[ L["Name:"] = "Name:"--]] 
--[[Translation missing --]]
--[[ L["New"] = "New"--]] 
--[[Translation missing --]]
--[[ L["New Binding"] = "New Binding"--]] 
--[[Translation missing --]]
--[[ L["New Feature: Frame Border Overlay"] = "New Feature: Frame Border Overlay"--]] 
--[[Translation missing --]]
--[[ L["New Option"] = "New Option"--]] 
--[[Translation missing --]]
--[[ L["New question"] = "New question"--]] 
--[[Translation missing --]]
--[[ L["Next"] = "Next"--]] 
--[[Translation missing --]]
--[[ L["No"] = "No"--]] 
--[[Translation missing --]]
--[[ L["No %s effects configured."] = "No %s effects configured."--]] 
--[[Translation missing --]]
--[[ L["No action selected"] = "No action selected"--]] 
--[[Translation missing --]]
--[[ L["No auto-profile is currently active or being edited."] = "No auto-profile is currently active or being edited."--]] 
--[[Translation missing --]]
--[[ L["no branch"] = "no branch"--]] 
--[[Translation missing --]]
--[[ L["No built-in wizards available yet. Check back after updates!"] = "No built-in wizards available yet. Check back after updates!"--]] 
--[[Translation missing --]]
--[[ L["No changelog available."] = "No changelog available."--]] 
--[[Translation missing --]]
--[[ L["No custom wizards yet. Click 'New Wizard' to create one!"] = "No custom wizards yet. Click 'New Wizard' to create one!"--]] 
--[[Translation missing --]]
--[[ L["No data to export"] = "No data to export"--]] 
--[[Translation missing --]]
--[[ L["No default profile set"] = "No default profile set"--]] 
--[[Translation missing --]]
--[[ L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["No item equipped"] = "No item equipped"--]] 
--[[Translation missing --]]
--[[ L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = [=[No layout groups created yet.
Click '+ Create Group' to get started.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["No layout set. Using global settings."] = "No layout set. Using global settings."--]] 
--[[Translation missing --]]
--[[ L["No loadout detected"] = "No loadout detected"--]] 
--[[Translation missing --]]
--[[ L["No macros match the current filter."] = "No macros match the current filter."--]] 
--[[Translation missing --]]
--[[ L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["No members yet"] = "No members yet"--]] 
--[[Translation missing --]]
--[[ L["No saved position to reset to."] = "No saved position to reset to."--]] 
--[[Translation missing --]]
--[[ L["No sound file selected. Choose a sound from the dropdown or enter a custom path."] = "No sound file selected. Choose a sound from the dropdown or enter a custom path."--]] 
--[[Translation missing --]]
--[[ L["No spells available for this class"] = "No spells available for this class"--]] 
--[[Translation missing --]]
--[[ L["No thanks"] = "No thanks"--]] 
--[[Translation missing --]]
--[[ L["No wizard selected. Go to 'My Wizards' tab to select or create a wizard first."] = "No wizard selected. Go to 'My Wizards' tab to select or create a wizard first."--]] 
--[[Translation missing --]]
--[[ L["None"] = "None"--]] 
--[[Translation missing --]]
--[[ L["None (no clamping)"] = "None (no clamping)"--]] 
--[[Translation missing --]]
--[[ L["None / Physical"] = "None / Physical"--]] 
--[[Translation missing --]]
--[[ L["None active (using global settings)"] = "None active (using global settings)"--]] 
--[[Translation missing --]]
--[[ L["Normal (BLEND)"] = "Normal (BLEND)"--]] 
--[[Translation missing --]]
--[[ L["Not Cancelable"] = "Not Cancelable"--]] 
--[[Translation missing --]]
--[[ L["Not in a raid group"] = "Not in a raid group"--]] 
--[[Translation missing --]]
--[[ L["Not Set"] = "Not Set"--]] 
--[[Translation missing --]]
--[[ L["Note: Cmd + Left Click unavailable on Mac"] = "Note: Cmd + Left Click unavailable on Mac"--]] 
L["Note: Font sizes are not changed. Adjust sizes in each element's page."] = "Notiz: Schriftgröße wird nicht geändert. Passe die Größe in den einzelnen Element Seiten an."
--[[Translation missing --]]
--[[ L["Notice"] = "Notice"--]] 
--[[Translation missing --]]
--[[ L["Off"] = "Off"--]] 
--[[Translation missing --]]
--[[ L["Offset X"] = "Offset X"--]] 
--[[Translation missing --]]
--[[ L["Offset Y"] = "Offset Y"--]] 
--[[Translation missing --]]
--[[ L["OK"] = "OK"--]] 
--[[Translation missing --]]
--[[ L["Only changed settings will be saved"] = "Only changed settings will be saved"--]] 
--[[Translation missing --]]
--[[ L["Only Dispellable Debuffs"] = "Only Dispellable Debuffs"--]] 
--[[Translation missing --]]
--[[ L["Only My Buffs"] = "Only My Buffs"--]] 
--[[Translation missing --]]
--[[ L["Only show buffs that you cast. Applies to all buff filters."] = "Only show buffs that you cast. Applies to all buff filters."--]] 
--[[Translation missing --]]
--[[ L["Only Show When Tanking"] = "Only Show When Tanking"--]] 
--[[Translation missing --]]
--[[ L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = [=[Only the active layout can be edited
while auto layouts are running.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["OOC"] = "OOC"--]] 
--[[Translation missing --]]
--[[ L["Open Aura Designer"] = "Open Aura Designer"--]] 
--[[Translation missing --]]
--[[ L["Open Cast History"] = "Open Cast History"--]] 
--[[Translation missing --]]
--[[ L["Open Settings"] = "Open Settings"--]] 
--[[Translation missing --]]
--[[ L["Open Settings Tab"] = "Open Settings Tab"--]] 
--[[Translation missing --]]
--[[ L["Open the Profiles tab to manage profiles"] = "Open the Profiles tab to manage profiles"--]] 
--[[Translation missing --]]
--[[ L["Open Unit Menu"] = "Open Unit Menu"--]] 
--[[Translation missing --]]
--[[ L["Open World"] = "Open World"--]] 
--[[Translation missing --]]
--[[ L["Opens tab: %s"] = "Opens tab: %s"--]] 
--[[Translation missing --]]
--[[ L["Option A"] = "Option A"--]] 
--[[Translation missing --]]
--[[ L["Option B"] = "Option B"--]] 
--[[Translation missing --]]
--[[ L["Options"] = "Options"--]] 
--[[Translation missing --]]
--[[ L["Options:    [S] = Link Setting    [->] = Branch    [x] = Delete"] = "Options:    [S] = Link Setting    [->] = Branch    [x] = Delete"--]] 
--[[Translation missing --]]
--[[ L["Or enter Icon ID:"] = "Or enter Icon ID:"--]] 
--[[Translation missing --]]
--[[ L["Orientation"] = "Orientation"--]] 
--[[Translation missing --]]
--[[ L["Other"] = "Other"--]] 
--[[Translation missing --]]
--[[ L["Other (%d)"] = "Other (%d)"--]] 
--[[Translation missing --]]
--[[ L["Other Frames"] = "Other Frames"--]] 
--[[Translation missing --]]
--[[ L["Out of combat"] = "Out of combat"--]] 
--[[Translation missing --]]
--[[ L["Out of Combat Only"] = "Out of Combat Only"--]] 
L["Out of Range"] = "Außerhalb der Reichweite"
--[[Translation missing --]]
--[[ L["Outline"] = "Outline"--]] 
--[[Translation missing --]]
--[[ L["Overlaps with \"%s\""] = "Overlaps with \"%s\""--]] 
--[[Translation missing --]]
--[[ L["Overlaps with \"%s\" (%d-%d)"] = "Overlaps with \"%s\" (%d-%d)"--]] 
--[[Translation missing --]]
--[[ L["Overlay (on health bar)"] = "Overlay (on health bar)"--]] 
--[[Translation missing --]]
--[[ L["Overridden by Auto Layout"] = "Overridden by Auto Layout"--]] 
--[[Translation missing --]]
--[[ L["Overridden in this layout"] = "Overridden in this layout"--]] 
--[[Translation missing --]]
--[[ L["Override Details"] = "Override Details"--]] 
--[[Translation missing --]]
--[[ L["Owner's Class Color"] = "Owner's Class Color"--]] 
L["Paladin"] = "Paladin"
--[[Translation missing --]]
--[[ L["Parse String"] = "Parse String"--]] 
--[[Translation missing --]]
--[[ L["Party"] = "Party"--]] 
--[[Translation missing --]]
--[[ L["PARTY"] = "PARTY"--]] 
--[[Translation missing --]]
--[[ L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = [=[Party & Raid %s settings are synced.
Click to stop syncing.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = ""--]] 
L["Party to Raid"] = "Gruppe zu Schlachtzug"
--[[Translation missing --]]
--[[ L["Party: %s"] = "Party: %s"--]] 
--[[Translation missing --]]
--[[ L["Paste a profile string to import:"] = "Paste a profile string to import:"--]] 
--[[Translation missing --]]
--[[ L["Paste the wizard export string below:"] = "Paste the wizard export string below:"--]] 
--[[Translation missing --]]
--[[ L["Pattern:"] = "Pattern:"--]] 
--[[Translation missing --]]
--[[ L["Per-aura overrides"] = "Per-aura overrides"--]] 
--[[Translation missing --]]
--[[ L["Percent"] = "Percent"--]] 
--[[Translation missing --]]
--[[ L["Percentage"] = "Percentage"--]] 
--[[Translation missing --]]
--[[ L["Permanent Mover"] = "Permanent Mover"--]] 
--[[Translation missing --]]
--[[ L["Per-setting reset is not available for Aura Designer"] = "Per-setting reset is not available for Aura Designer"--]] 
--[[Translation missing --]]
--[[ L["Persist (sec)"] = "Persist (sec)"--]] 
--[[Translation missing --]]
--[[ L["Personal Targeted"] = "Personal Targeted"--]] 
--[[Translation missing --]]
--[[ L["Personal Targeted Spells"] = "Personal Targeted Spells"--]] 
--[[Translation missing --]]
--[[ L["Pet Frame Settings"] = "Pet Frame Settings"--]] 
--[[Translation missing --]]
--[[ L["Pet Frames"] = "Pet Frames"--]] 
--[[Translation missing --]]
--[[ L["Pet frames are grouped together in a separate container."] = "Pet frames are grouped together in a separate container."--]] 
--[[Translation missing --]]
--[[ L["Pet frames are positioned relative to their owner's frame."] = "Pet frames are positioned relative to their owner's frame."--]] 
--[[Translation missing --]]
--[[ L["Pet Spacing"] = "Pet Spacing"--]] 
--[[Translation missing --]]
--[[ L["Phased"] = "Phased"--]] 
--[[Translation missing --]]
--[[ L["Phased Icon"] = "Phased Icon"--]] 
--[[Translation missing --]]
--[[ L["Picked setting: %s%s%s from tab %s%s%s"] = "Picked setting: %s%s%s from tab %s%s%s"--]] 
--[[Translation missing --]]
--[[ L["Pinned Frames"] = "Pinned Frames"--]] 
--[[Translation missing --]]
--[[ L["Pip Color"] = "Pip Color"--]] 
--[[Translation missing --]]
--[[ L["Pip Height"] = "Pip Height"--]] 
--[[Translation missing --]]
--[[ L["Pixel-Perfect Scaling"] = "Pixel-Perfect Scaling"--]] 
--[[Translation missing --]]
--[[ L["Place %s at %s"] = "Place %s at %s"--]] 
--[[Translation missing --]]
--[[ L["Placed"] = "Placed"--]] 
--[[Translation missing --]]
--[[ L["PLACED ON FRAME"] = "PLACED ON FRAME"--]] 
--[[Translation missing --]]
--[[ L["PLACEMENT"] = "PLACEMENT"--]] 
--[[Translation missing --]]
--[[ L["Player Range"] = "Player Range"--]] 
--[[Translation missing --]]
--[[ L["Players Grow From"] = "Players Grow From"--]] 
--[[Translation missing --]]
--[[ L["Players Per Column"] = "Players Per Column"--]] 
--[[Translation missing --]]
--[[ L["Players Per Row"] = "Players Per Row"--]] 
L["Please enter a profile name."] = "Bitte gib einen Profilnamen ein."
--[[Translation missing --]]
--[[ L["Please select an action!"] = "Please select an action!"--]] 
--[[Translation missing --]]
--[[ L["Poison"] = "Poison"--]] 
L["Position"] = "Position"
--[[Translation missing --]]
--[[ L["Position & anchors"] = "Position & anchors"--]] 
--[[Translation missing --]]
--[[ L["Position managed by: %s"] = "Position managed by: %s"--]] 
--[[Translation missing --]]
--[[ L["Position reset."] = "Position reset."--]] 
--[[Translation missing --]]
--[[ L["Power Bar Alpha"] = "Power Bar Alpha"--]] 
--[[Translation missing --]]
--[[ L["Power Word: Fortitude (Priest)"] = "Power Word: Fortitude (Priest)"--]] 
--[[Translation missing --]]
--[[ L["Pre-configure players before they join the group"] = "Pre-configure players before they join the group"--]] 
--[[Translation missing --]]
--[[ L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Press Ctrl+A to select all, then Ctrl+C to copy"] = "Press Ctrl+A to select all, then Ctrl+C to copy"--]] 
--[[Translation missing --]]
--[[ L["Press Ctrl+C to copy, then Escape to close"] = "Press Ctrl+C to copy, then Escape to close"--]] 
--[[Translation missing --]]
--[[ L["Press key/click/scroll..."] = "Press key/click/scroll..."--]] 
--[[Translation missing --]]
--[[ L["Preview"] = "Preview"--]] 
--[[Translation missing --]]
--[[ L["Preview Scale"] = "Preview Scale"--]] 
--[[Translation missing --]]
--[[ L["Preview Sound"] = "Preview Sound"--]] 
--[[Translation missing --]]
--[[ L["Preview:"] = "Preview:"--]] 
L["Priest"] = "Priester"
L["Priority"] = "Priorität"
L["Priority:"] = "Priorität:"
--[[Translation missing --]]
--[[ L["Private Aura Overlay Setup"] = "Private Aura Overlay Setup"--]] 
--[[Translation missing --]]
--[[ L["Profile \"%s\" has no overrides."] = "Profile \"%s\" has no overrides."--]] 
L["Profile '%s' already exists."] = "Profil '%s' existiert bereits."
L["Profile Actions"] = "Profil Aktionen"
L["Profile imported successfully!"] = "Profil erfolgreich importiert!"
--[[Translation missing --]]
--[[ L["Profile matched to loadout"] = "Profile matched to loadout"--]] 
L["Profile Name"] = "Profilname"
L["Profile not found"] = "Profil nicht gefunden"
--[[Translation missing --]]
--[[ L["Profile Settings"] = "Profile Settings"--]] 
L["Profile:"] = "Profil:"
L["Profile: %s"] = "Profil: %s"
--[[Translation missing --]]
--[[ L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Profiles"] = "Profiles"--]] 
--[[Translation missing --]]
--[[ L["Pull Timer"] = "Pull Timer"--]] 
--[[Translation missing --]]
--[[ L["Pull Timer Duration"] = "Pull Timer Duration"--]] 
--[[Translation missing --]]
--[[ L["Pulsate"] = "Pulsate"--]] 
--[[Translation missing --]]
--[[ L["Pulsate Border"] = "Pulsate Border"--]] 
--[[Translation missing --]]
--[[ L["Pulse"] = "Pulse"--]] 
--[[Translation missing --]]
--[[ L["Pulse Animation"] = "Pulse Animation"--]] 
--[[Translation missing --]]
--[[ L["Question"] = "Question"--]] 
--[[Translation missing --]]
--[[ L["Question:"] = "Question:"--]] 
--[[Translation missing --]]
--[[ L["Quick Bind"] = "Quick Bind"--]] 
--[[Translation missing --]]
--[[ L["Quick Bind Mode"] = "Quick Bind Mode"--]] 
--[[Translation missing --]]
--[[ L["Quick Macro"] = "Quick Macro"--]] 
--[[Translation missing --]]
--[[ L["Quick Macro Builder"] = "Quick Macro Builder"--]] 
--[[Translation missing --]]
--[[ L["Quick Switch CC Profile"] = "Quick Switch CC Profile"--]] 
--[[Translation missing --]]
--[[ L["Quick Switch Profile"] = "Quick Switch Profile"--]] 
L["Rage"] = "Wut"
--[[Translation missing --]]
--[[ L["Raid"] = "Raid"--]] 
--[[Translation missing --]]
--[[ L["RAID"] = "RAID"--]] 
--[[Translation missing --]]
--[[ L["Raid Auto Layouts"] = "Raid Auto Layouts"--]] 
--[[Translation missing --]]
--[[ L["Raid Buffs"] = "Raid Buffs"--]] 
--[[Translation missing --]]
--[[ L["Raid Debuffs"] = "Raid Debuffs"--]] 
--[[Translation missing --]]
--[[ L["Raid frames centered."] = "Raid frames centered."--]] 
--[[Translation missing --]]
--[[ L["Raid Group Labels"] = "Raid Group Labels"--]] 
--[[Translation missing --]]
--[[ L["Raid In Combat"] = "Raid In Combat"--]] 
--[[Translation missing --]]
--[[ L["Raid Layout Mode"] = "Raid Layout Mode"--]] 
--[[Translation missing --]]
--[[ L["Raid position reset."] = "Raid position reset."--]] 
--[[Translation missing --]]
--[[ L["Raid Role (MT/MA)"] = "Raid Role (MT/MA)"--]] 
--[[Translation missing --]]
--[[ L["Raid Role Icon (MT/MA)"] = "Raid Role Icon (MT/MA)"--]] 
--[[Translation missing --]]
--[[ L["Raid Target Icon"] = "Raid Target Icon"--]] 
L["Raid to Party"] = "Schlachtzug zu Gruppe"
--[[Translation missing --]]
--[[ L["Raid: %s"] = "Raid: %s"--]] 
--[[Translation missing --]]
--[[ L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Raids"] = "Raids"--]] 
--[[Translation missing --]]
--[[ L["Raids, battlegrounds (1-40)"] = "Raids, battlegrounds (1-40)"--]] 
L["Range Check Interval"] = "Intervall für Reichweitenprüfung"
L["Range Check Spell"] = "Zauber für Reichweitenprüfung"
--[[Translation missing --]]
--[[ L["Ranged DPS"] = "Ranged DPS"--]] 
--[[Translation missing --]]
--[[ L["Ready Check"] = "Ready Check"--]] 
--[[Translation missing --]]
--[[ L["Ready Check Icon"] = "Ready Check Icon"--]] 
--[[Translation missing --]]
--[[ L["Ready to copy"] = "Ready to copy"--]] 
--[[Translation missing --]]
--[[ L["Recovered %d raid settings from interrupted auto layout editing session."] = "Recovered %d raid settings from interrupted auto layout editing session."--]] 
--[[Translation missing --]]
--[[ L["Refresh"] = "Refresh"--]] 
--[[Translation missing --]]
--[[ L["Reload UI"] = "Reload UI"--]] 
--[[Translation missing --]]
--[[ L["Remove all bindings from the current profile."] = "Remove all bindings from the current profile."--]] 
--[[Translation missing --]]
--[[ L["Remove Offline"] = "Remove Offline"--]] 
--[[Translation missing --]]
--[[ L["Removes all Aura Designer overrides from this auto layout, restoring it to match your global profile."] = "Removes all Aura Designer overrides from this auto layout, restoring it to match your global profile."--]] 
--[[Translation missing --]]
--[[ L["Removes your player frame from the DandersFrames party display."] = "Removes your player frame from the DandersFrames party display."--]] 
--[[Translation missing --]]
--[[ L["Rename"] = "Rename"--]] 
--[[Translation missing --]]
--[[ L["Replace"] = "Replace"--]] 
L["Replace Blizzard's color picker with the DandersFrames color picker for this addon."] = "Ersetze Blizzard's Farbauswahl mit der DandersFrames Farbauwahl für dieses Addon."
--[[Translation missing --]]
--[[ L["Replace Buffs"] = "Replace Buffs"--]] 
--[[Translation missing --]]
--[[ L["Res + Mass"] = "Res + Mass"--]] 
--[[Translation missing --]]
--[[ L["Res + Mass + Combat"] = "Res + Mass + Combat"--]] 
--[[Translation missing --]]
--[[ L["Reset"] = "Reset"--]] 
--[[Translation missing --]]
--[[ L["Reset All Aura Configs"] = "Reset All Aura Configs"--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = ""--]] 
L["Reset All to Default"] = "Setze alle auf Standardwerte zurück"
--[[Translation missing --]]
--[[ L["Reset Aura Designer to Global"] = "Reset Aura Designer to Global"--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = ""--]] 
L["Reset Position"] = "Position zurücksetzen"
L["Reset Profile to Defaults"] = "Profil auf Standardwerte zurücksetzen"
--[[Translation missing --]]
--[[ L["Reset to Defaults"] = "Reset to Defaults"--]] 
--[[Translation missing --]]
--[[ L["Reset to Global"] = "Reset to Global"--]] 
--[[Translation missing --]]
--[[ L["Reset to Global Order"] = "Reset to Global Order"--]] 
L["Resource Bar"] = "Ressourcenbalken"
L["Resource Bar Settings"] = "Ressourcenbalken Einstellungen"
L["Resource Colors"] = "Ressourcenfarben"
--[[Translation missing --]]
--[[ L["Rested Indicator"] = "Rested Indicator"--]] 
--[[Translation missing --]]
--[[ L["Resurrection"] = "Resurrection"--]] 
--[[Translation missing --]]
--[[ L["Resurrection Icon"] = "Resurrection Icon"--]] 
--[[Translation missing --]]
--[[ L["Resurrection Icon Tooltips"] = "Resurrection Icon Tooltips"--]] 
L["Reverse Fill"] = "Umgekehrte Füllung"
L["Reverse Fill Direction"] = "Umgekehrte Füllrichtung"
--[[Translation missing --]]
--[[ L["Reverse Order"] = "Reverse Order"--]] 
--[[Translation missing --]]
--[[ L["Reverse Overlay Fill"] = "Reverse Overlay Fill"--]] 
--[[Translation missing --]]
--[[ L["Reverse Position"] = "Reverse Position"--]] 
--[[Translation missing --]]
--[[ L["Right"] = "Right"--]] 
L["Right Click"] = "Rechtsklick"
--[[Translation missing --]]
--[[ L["Right Edge"] = "Right Edge"--]] 
--[[Translation missing --]]
--[[ L["Right of Health Bar"] = "Right of Health Bar"--]] 
--[[Translation missing --]]
--[[ L["Right of Owner"] = "Right of Owner"--]] 
--[[Translation missing --]]
--[[ L["Right of Party"] = "Right of Party"--]] 
--[[Translation missing --]]
--[[ L["Right of Raid"] = "Right of Raid"--]] 
--[[Translation missing --]]
--[[ L["Right to Left"] = "Right to Left"--]] 
L["Right-click"] = "Rechtsklick"
--[[Translation missing --]]
--[[ L["Right-click: Edit/View"] = "Right-click: Edit/View"--]] 
L["Rogue"] = "Schurke"
L["Role Icon"] = "Rollenicon"
L["Role Priority"] = "Rollenpriorität"
L["Row Spacing"] = "Reihenabstand"
L["Rows"] = "Reihen"
L["Rows Grow From"] = "Reihen wachsen von"
--[[Translation missing --]]
--[[ L["Run"] = "Run"--]] 
--[[Translation missing --]]
--[[ L["Run Overlay Setup Wizard"] = "Run Overlay Setup Wizard"--]] 
--[[Translation missing --]]
--[[ L["Run Script"] = "Run Script"--]] 
--[[Translation missing --]]
--[[ L["Run Setup Wizard"] = "Run Setup Wizard"--]] 
L["Runic Power"] = "Runenmacht"
--[[Translation missing --]]
--[[ L["Runtime"] = "Runtime"--]] 
L["Save"] = "speichern"
L["Save & Close"] = "speichern & schließen"
L["Save Changes"] = "Änderungen speichern"
--[[Translation missing --]]
--[[ L["Scale"] = "Scale"--]] 
--[[Translation missing --]]
--[[ L["Script Runner"] = "Script Runner"--]] 
--[[Translation missing --]]
--[[ L["Search fonts..."] = "Search fonts..."--]] 
--[[Translation missing --]]
--[[ L["Search sounds..."] = "Search sounds..."--]] 
--[[Translation missing --]]
--[[ L["Search spells..."] = "Search spells..."--]] 
--[[Translation missing --]]
--[[ L["Search textures..."] = "Search textures..."--]] 
L["Search..."] = "suche..."
L["Seconds"] = "Sekunden"
--[[Translation missing --]]
--[[ L["See Also:"] = "See Also:"--]] 
--[[Translation missing --]]
--[[ L["Select a destination"] = "Select a destination"--]] 
--[[Translation missing --]]
--[[ L["Select a spell"] = "Select a spell"--]] 
--[[Translation missing --]]
--[[ L["Select a step to edit"] = "Select a step to edit"--]] 
--[[Translation missing --]]
--[[ L["Select All Text"] = "Select All Text"--]] 
--[[Translation missing --]]
--[[ L["Select any tab"] = "Select any tab"--]] 
--[[Translation missing --]]
--[[ L["Select Class"] = "Select Class"--]] 
--[[Translation missing --]]
--[[ L["Select indicator..."] = "Select indicator..."--]] 
--[[Translation missing --]]
--[[ L["Select or create a wizard"] = "Select or create a wizard"--]] 
--[[Translation missing --]]
--[[ L["Select trigger for %s"] = "Select trigger for %s"--]] 
--[[Translation missing --]]
--[[ L["Select which spell to use for range checking. Auto will use your spec's default healing/friendly spell."] = "Select which spell to use for range checking. Auto will use your spec's default healing/friendly spell."--]] 
--[[Translation missing --]]
--[[ L["Select..."] = "Select..."--]] 
--[[Translation missing --]]
--[[ L["Selected: %d"] = "Selected: %d"--]] 
--[[Translation missing --]]
--[[ L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = [=[Selecting an option will disable the other addon(s)
and reload your UI.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Selection Highlight"] = "Selection Highlight"--]] 
--[[Translation missing --]]
--[[ L["Selection Settings"] = "Selection Settings"--]] 
L["Self Position"] = "Eigene Position"
L["Separate Melee & Ranged DPS"] = "Trenne Nahkampf & Fernkampf DPS"
--[[Translation missing --]]
--[[ L["Separate Pet Group"] = "Separate Pet Group"--]] 
L["Set a font and outline style, then click Apply to update ALL text elements."] = "Wähle eine Schriftart und Umrissart, dann klicke auf akzeptieren um ALLE Text Elemente zu aktualisieren."
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = ""--]] 
L["Settings"] = "Einstellungen"
--[[Translation missing --]]
--[[ L["Settings to Apply"] = "Settings to Apply"--]] 
--[[Translation missing --]]
--[[ L["Setup Wizards"] = "Setup Wizards"--]] 
L["Shadow"] = "Schatten"
L["Shadow Color"] = "Schattenfarbe"
L["Shadow Settings"] = "Schatten Einstellungen"
--[[Translation missing --]]
--[[ L["Shadow settings are controlled in General > Global Fonts."] = "Shadow settings are controlled in General > Global Fonts."--]] 
L["Shadow X Offset"] = "Schatten X Offset"
L["Shadow Y Offset"] = "Schatten Y Offset"
L["Shaman"] = "Schamane"
--[[Translation missing --]]
--[[ L["Shared"] = "Shared"--]] 
--[[Translation missing --]]
--[[ L["Shared Border"] = "Shared Border"--]] 
L["Shift+Left Click"] = "Shift+Linksklick"
L["Shift+Right Click"] = "Shift+Rechtsklick"
--[[Translation missing --]]
--[[ L["Show a pulsing yellow glow around the frame."] = "Show a pulsing yellow glow around the frame."--]] 
--[[Translation missing --]]
--[[ L["Show All Roles Out of Combat"] = "Show All Roles Out of Combat"--]] 
--[[Translation missing --]]
--[[ L["Show as Text"] = "Show as Text"--]] 
--[[Translation missing --]]
--[[ L["Show Background"] = "Show Background"--]] 
--[[Translation missing --]]
--[[ L["Show Border"] = "Show Border"--]] 
--[[Translation missing --]]
--[[ L["Show Buffs"] = "Show Buffs"--]] 
--[[Translation missing --]]
--[[ L["Show Cooldown Swipe"] = "Show Cooldown Swipe"--]] 
--[[Translation missing --]]
--[[ L["Show Debuffs"] = "Show Debuffs"--]] 
--[[Translation missing --]]
--[[ L["Show Dispel Icon"] = "Show Dispel Icon"--]] 
--[[Translation missing --]]
--[[ L["Show DPS"] = "Show DPS"--]] 
--[[Translation missing --]]
--[[ L["Show Duration"] = "Show Duration"--]] 
--[[Translation missing --]]
--[[ L["Show Duration Numbers"] = "Show Duration Numbers"--]] 
--[[Translation missing --]]
--[[ L["Show Duration Text"] = "Show Duration Text"--]] 
--[[Translation missing --]]
--[[ L["Show every buff with no filtering."] = "Show every buff with no filtering."--]] 
--[[Translation missing --]]
--[[ L["Show every debuff with no filtering."] = "Show every debuff with no filtering."--]] 
--[[Translation missing --]]
--[[ L["Show Expiring Border"] = "Show Expiring Border"--]] 
--[[Translation missing --]]
--[[ L["Show Expiring Tint"] = "Show Expiring Tint"--]] 
--[[Translation missing --]]
--[[ L["Show for Roles"] = "Show for Roles"--]] 
--[[Translation missing --]]
--[[ L["Show Frame Border"] = "Show Frame Border"--]] 
--[[Translation missing --]]
--[[ L["Show Gradient"] = "Show Gradient"--]] 
--[[Translation missing --]]
--[[ L["Show Group Label"] = "Show Group Label"--]] 
L["Show Healer"] = "Zeige Heiler"
--[[Translation missing --]]
--[[ L["Show health bars for player and party/raid member pets, anchored to their owner's frame. Pet frames hide when owner dies."] = "Show health bars for player and party/raid member pets, anchored to their owner's frame. Pet frames hide when owner dies."--]] 
--[[Translation missing --]]
--[[ L["Show Health Percentage"] = "Show Health Percentage"--]] 
--[[Translation missing --]]
--[[ L["Show in content types:"] = "Show in content types:"--]] 
--[[Translation missing --]]
--[[ L["Show in Solo Mode"] = "Show in Solo Mode"--]] 
--[[Translation missing --]]
--[[ L["Show Interrupted Visual"] = "Show Interrupted Visual"--]] 
--[[Translation missing --]]
--[[ L["Show Label"] = "Show Label"--]] 
--[[Translation missing --]]
--[[ L["Show LFG Eye for Cross-Instance"] = "Show LFG Eye for Cross-Instance"--]] 
--[[Translation missing --]]
--[[ L["Show Main Assist"] = "Show Main Assist"--]] 
--[[Translation missing --]]
--[[ L["Show Main Tank"] = "Show Main Tank"--]] 
--[[Translation missing --]]
--[[ L["Show Minimap Button"] = "Show Minimap Button"--]] 
--[[Translation missing --]]
--[[ L["Show On Current Health Only"] = "Show On Current Health Only"--]] 
--[[Translation missing --]]
--[[ L["Show on Hover Only"] = "Show on Hover Only"--]] 
--[[Translation missing --]]
--[[ L["Show Overheal"] = "Show Overheal"--]] 
--[[Translation missing --]]
--[[ L["Show Overlay For"] = "Show Overlay For"--]] 
--[[Translation missing --]]
--[[ L["Show Overshield Glow"] = "Show Overshield Glow"--]] 
--[[Translation missing --]]
--[[ L["Show Party/Raid Side Menu"] = "Show Party/Raid Side Menu"--]] 
--[[Translation missing --]]
--[[ L["Show rested indicators when in a rested area (inn, city)."] = "Show rested indicators when in a rested area (inn, city)."--]] 
--[[Translation missing --]]
--[[ L["Show Shadow"] = "Show Shadow"--]] 
--[[Translation missing --]]
--[[ L["Show Stacks"] = "Show Stacks"--]] 
--[[Translation missing --]]
--[[ L["Show Tank"] = "Show Tank"--]] 
--[[Translation missing --]]
--[[ L["Show the animated ZZZ icon on the player frame."] = "Show the animated ZZZ icon on the player frame."--]] 
L["Show the DF color picker when any addon opens a color picker."] = "Zeige DF Farbauswahl immer wenn ein Addon eine Farbauswahl öffnet."
--[[Translation missing --]]
--[[ L["Show Timer"] = "Show Timer"--]] 
--[[Translation missing --]]
--[[ L["Show When Missing"] = "Show When Missing"--]] 
--[[Translation missing --]]
--[[ L["Show X Mark"] = "Show X Mark"--]] 
--[[Translation missing --]]
--[[ L["Show:"] = "Show:"--]] 
--[[Translation missing --]]
--[[ L["Shows a border ring around the entire frame when a boss debuff is active."] = "Shows a border ring around the entire frame when a boss debuff is active."--]] 
--[[Translation missing --]]
--[[ L["Shows a colored border/glow when a dispellable debuff is present."] = "Shows a colored border/glow when a dispellable debuff is present."--]] 
--[[Translation missing --]]
--[[ L["Shows a glow at max health when absorb exceeds the clamp limit."] = "Shows a glow at max health when absorb exceeds the clamp limit."--]] 
--[[Translation missing --]]
--[[ L["Shows an icon when an enemy is casting a spell targeting a party/raid member."] = "Shows an icon when an enemy is casting a spell targeting a party/raid member."--]] 
--[[Translation missing --]]
--[[ L["Shows an icon when party members have a defensive cooldown active (Pain Suppression, Ironbark, etc.)."] = "Shows an icon when party members have a defensive cooldown active (Pain Suppression, Ironbark, etc.)."--]] 
--[[Translation missing --]]
--[[ L["Shows effects that reduce incoming healing (like Necrotic stacks)."] = "Shows effects that reduce incoming healing (like Necrotic stacks)."--]] 
--[[Translation missing --]]
--[[ L["Shows icon when party members are missing raid buffs."] = "Shows icon when party members are missing raid buffs."--]] 
--[[Translation missing --]]
--[[ L["Shows incoming targeted spells on YOU in the center of your screen."] = "Shows incoming targeted spells on YOU in the center of your screen."--]] 
--[[Translation missing --]]
--[[ L["Shows the ping wheel & party management menu."] = "Shows the ping wheel & party management menu."--]] 
--[[Translation missing --]]
--[[ L["Single Select"] = "Single Select"--]] 
L["Size"] = "Größe"
L["Size & Orientation"] = "Größe & Position"
--[[Translation missing --]]
--[[ L["Size & Spacing"] = "Size & Spacing"--]] 
--[[Translation missing --]]
--[[ L["Skip for now"] = "Skip for now"--]] 
--[[Translation missing --]]
--[[ L["Skyfury (Shaman)"] = "Skyfury (Shaman)"--]] 
--[[Translation missing --]]
--[[ L["Smart Res:"] = "Smart Res:"--]] 
--[[Translation missing --]]
--[[ L["Smart Resurrection"] = "Smart Resurrection"--]] 
L["Smooth Bar Animation"] = "Flüssige Balkenanimation"
--[[Translation missing --]]
--[[ L["Snaps sizes and borders to exact pixels for crisp rendering."] = "Snaps sizes and borders to exact pixels for crisp rendering."--]] 
--[[Translation missing --]]
--[[ L["Solid (BLEND)"] = "Solid (BLEND)"--]] 
--[[Translation missing --]]
--[[ L["Solid Border"] = "Solid Border"--]] 
--[[Translation missing --]]
--[[ L["Solo Mode"] = "Solo Mode"--]] 
--[[Translation missing --]]
--[[ L["Solo mode %s"] = "Solo mode %s"--]] 
--[[Translation missing --]]
--[[ L["Solo Mode: Show your player frame when not in a group."] = "Solo Mode: Show your player frame when not in a group."--]] 
--[[Translation missing --]]
--[[ L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = [=[Some bindings use spells that are not available
to your current class or specialization.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = ""--]] 
L["Sort by Class (within role)"] = "Sortiere nach Klasse (innerhalb der Rolle)"
--[[Translation missing --]]
--[[ L["Sort Order"] = "Sort Order"--]] 
L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = "Sortiere Gruppenmitglieder nach Rolle, Klasse und Name. Sortierreihenfolge: Eigene Position > Rolle > Klasse > Name"
L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = "Sortiere Gruppenmitglieder nach Rolle, Klasse und Name. Sortierreihenfolge: Eigene Position > Rolle > Klasse > Name"
--[[Translation missing --]]
--[[ L["Sorted with Group"] = "Sorted with Group"--]] 
L["Sorting"] = "Sortierung"
--[[Translation missing --]]
--[[ L["Sound"] = "Sound"--]] 
--[[Translation missing --]]
--[[ L["Sound Alert"] = "Sound Alert"--]] 
--[[Translation missing --]]
--[[ L["Sound Alerts"] = "Sound Alerts"--]] 
--[[Translation missing --]]
--[[ L["Sound file could not be played: %s"] = "Sound file could not be played: %s"--]] 
--[[Translation missing --]]
--[[ L["Source Mode"] = "Source Mode"--]] 
--[[Translation missing --]]
--[[ L["Spacing"] = "Spacing"--]] 
--[[Translation missing --]]
--[[ L["Spacing X"] = "Spacing X"--]] 
--[[Translation missing --]]
--[[ L["Spacing Y"] = "Spacing Y"--]] 
--[[Translation missing --]]
--[[ L["Spark"] = "Spark"--]] 
--[[Translation missing --]]
--[[ L["Spec Default"] = "Spec Default"--]] 
--[[Translation missing --]]
--[[ L["Spec:"] = "Spec:"--]] 
--[[Translation missing --]]
--[[ L["Specialization data not available."] = "Specialization data not available."--]] 
L["Spell:"] = "Spell:"
L["Spells"] = "Spells"
--[[Translation missing --]]
--[[ L["Spells flagged as important by Blizzard."] = "Spells flagged as important by Blizzard."--]] 
--[[Translation missing --]]
--[[ L["Square"] = "Square"--]] 
--[[Translation missing --]]
--[[ L["Stack Anchor"] = "Stack Anchor"--]] 
--[[Translation missing --]]
--[[ L["Stack Count"] = "Stack Count"--]] 
--[[Translation missing --]]
--[[ L["Stack Font"] = "Stack Font"--]] 
--[[Translation missing --]]
--[[ L["Stack Minimum"] = "Stack Minimum"--]] 
--[[Translation missing --]]
--[[ L["Stack Offset X"] = "Stack Offset X"--]] 
--[[Translation missing --]]
--[[ L["Stack Offset Y"] = "Stack Offset Y"--]] 
--[[Translation missing --]]
--[[ L["Stack Outline"] = "Stack Outline"--]] 
--[[Translation missing --]]
--[[ L["Stack Scale"] = "Stack Scale"--]] 
--[[Translation missing --]]
--[[ L["Stack Text"] = "Stack Text"--]] 
--[[Translation missing --]]
--[[ L["Stack Text Color"] = "Stack Text Color"--]] 
--[[Translation missing --]]
--[[ L["Standard Buffs are also visible on frames."] = "Standard Buffs are also visible on frames."--]] 
L["START"] = "START"
L["Start"] = "Start"
--[[Translation missing --]]
--[[ L["Start (Left/Top)"] = "Start (Left/Top)"--]] 
--[[Translation missing --]]
--[[ L["Start = Left/Top, End = Right/Bottom depending on direction."] = "Start = Left/Top, End = Right/Bottom depending on direction."--]] 
--[[Translation missing --]]
--[[ L["Start Delay (sec)"] = "Start Delay (sec)"--]] 
--[[Translation missing --]]
--[[ L["Start of Group"] = "Start of Group"--]] 
--[[Translation missing --]]
--[[ L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Status Icon Text Settings"] = "Status Icon Text Settings"--]] 
--[[Translation missing --]]
--[[ L["Status Text"] = "Status Text"--]] 
--[[Translation missing --]]
--[[ L["Status Text (Dead/Offline)"] = "Status Text (Dead/Offline)"--]] 
L["Status Text Alpha"] = "Deckkraft für Statustext"
--[[Translation missing --]]
--[[ L["Step %d of %d"] = "Step %d of %d"--]] 
--[[Translation missing --]]
--[[ L["Step 1: Click here with desired key combo"] = "Step 1: Click here with desired key combo"--]] 
--[[Translation missing --]]
--[[ L["Step 2: Select Action"] = "Step 2: Select Action"--]] 
--[[Translation missing --]]
--[[ L["Step 3: Combat Condition (optional)"] = "Step 3: Combat Condition (optional)"--]] 
--[[Translation missing --]]
--[[ L["Step Editor"] = "Step Editor"--]] 
--[[Translation missing --]]
--[[ L["Step ID"] = "Step ID"--]] 
--[[Translation missing --]]
--[[ L["Steps"] = "Steps"--]] 
--[[Translation missing --]]
--[[ L["Style"] = "Style"--]] 
--[[Translation missing --]]
--[[ L["Summary"] = "Summary"--]] 
--[[Translation missing --]]
--[[ L["Summary Step"] = "Summary Step"--]] 
--[[Translation missing --]]
--[[ L["Summon"] = "Summon"--]] 
--[[Translation missing --]]
--[[ L["Summon Icon"] = "Summon Icon"--]] 
--[[Translation missing --]]
--[[ L["Switched to profile: %s"] = "Switched to profile: %s"--]] 
--[[Translation missing --]]
--[[ L["Sync"] = "Sync"--]] 
--[[Translation missing --]]
--[[ L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Sync from WoW"] = "Sync from WoW"--]] 
L["Sync with %s"] = "Sync. mit %s"
--[[Translation missing --]]
--[[ L["Sync: %s"] = "Sync: %s"--]] 
--[[Translation missing --]]
--[[ L["Synced with %s"] = "Synced with %s"--]] 
--[[Translation missing --]]
--[[ L["Synced: %s"] = "Synced: %s"--]] 
L["Tank"] = "Tank"
--[[Translation missing --]]
--[[ L["Tanking (Red)"] = "Tanking (Red)"--]] 
--[[Translation missing --]]
--[[ L["Tanks"] = "Tanks"--]] 
--[[Translation missing --]]
--[[ L["Target Type:"] = "Target Type:"--]] 
--[[Translation missing --]]
--[[ L["Target Unit"] = "Target Unit"--]] 
--[[Translation missing --]]
--[[ L["Targeted Spell Alpha"] = "Targeted Spell Alpha"--]] 
L["Targeted Spell Click-Through"] = "Ausgewählter Zauber durchklickbar"
--[[Translation missing --]]
--[[ L["Targeted Spells"] = "Targeted Spells"--]] 
--[[Translation missing --]]
--[[ L["Targeted Spells (on frames)"] = "Targeted Spells (on frames)"--]] 
--[[Translation missing --]]
--[[ L["Targeting Fallback:"] = "Targeting Fallback:"--]] 
--[[Translation missing --]]
--[[ L["Targeting: %s"] = "Targeting: %s"--]] 
L["Test"] = "Test"
L["Test Mode"] = "Testmodus"
L["Test mode disabled."] = "Testmodus deaktiviert."
L["Test mode enabled."] = "Testmodus aktiviert."
--[[Translation missing --]]
--[[ L["Test mode ended — entering combat."] = "Test mode ended — entering combat."--]] 
L["Test Mode: %s"] = "Test Mode: %s"
L["Text"] = "Text"
L["Text Color"] = "Text Color"
L["Text Colors:"] = "Text Colors:"
L["Text Format"] = "Text Format"
L["Text Scale"] = "Textgröße"
L["Texture"] = "Textur"
--[[Translation missing --]]
--[[ L["Texture & Colors"] = "Texture & Colors"--]] 
--[[Translation missing --]]
--[[ L["The first image shows the overlay border active on a frame. The second shows the standard boss debuff icon only."] = "The first image shows the overlay border active on a frame. The second shows the standard boss debuff icon only."--]] 
--[[Translation missing --]]
--[[ L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["These settings apply when using 'Shadow' outline style. Use larger offsets for more dramatic shadows."] = "These settings apply when using 'Shadow' outline style. Use larger offsets for more dramatic shadows."--]] 
--[[Translation missing --]]
--[[ L["Thick Outline"] = "Thick Outline"--]] 
L["Thickness"] = "Dicke"
--[[Translation missing --]]
--[[ L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = ""--]] 
L["this option"] = "diese Option"
--[[Translation missing --]]
--[[ L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["This setting differs from the global profile value. Click the reset button to revert."] = "This setting differs from the global profile value. Click the reset button to revert."--]] 
--[[Translation missing --]]
--[[ L["This setting is being overridden by the active auto layout profile. To change it, edit the profile in the Auto Layouts tab."] = "This setting is being overridden by the active auto layout profile. To change it, edit the profile in the Auto Layouts tab."--]] 
--[[Translation missing --]]
--[[ L["This step automatically shows a review of all the user's answers. It's always the last step."] = "This step automatically shows a review of all the user's answers. It's always the last step."--]] 
L["This warning will not appear again after confirming."] = "Diese Warnung wird nach dem Bestätigen nicht wieder angezeigt."
--[[Translation missing --]]
--[[ L["Threat Colors"] = "Threat Colors"--]] 
--[[Translation missing --]]
--[[ L["Threshold Mode"] = "Threshold Mode"--]] 
--[[Translation missing --]]
--[[ L["Time Remaining"] = "Time Remaining"--]] 
--[[Translation missing --]]
--[[ L["Timing"] = "Timing"--]] 
--[[Translation missing --]]
--[[ L["Tint"] = "Tint"--]] 
--[[Translation missing --]]
--[[ L["Tint Color"] = "Tint Color"--]] 
--[[Translation missing --]]
--[[ L["Tint Opacity"] = "Tint Opacity"--]] 
--[[Translation missing --]]
--[[ L[ [=[to customise
this profile's settings]=] ] = [=[to customise
this profile's settings]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[to customise
this profile's settings]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["To fix the ElvUI compatibility issue:"] = "To fix the ElvUI compatibility issue:"--]] 
--[[Translation missing --]]
--[[ L["To reposition: Unlock frames (/df unlock) and drag the mover."] = "To reposition: Unlock frames (/df unlock) and drag the mover."--]] 
--[[Translation missing --]]
--[[ L["Toggle Solo Mode"] = "Toggle Solo Mode"--]] 
--[[Translation missing --]]
--[[ L["Toggle Test Mode"] = "Toggle Test Mode"--]] 
L["Tooltips"] = "Tooltips"
L["Top"] = "Oben"
--[[Translation missing --]]
--[[ L["Top Edge"] = "Top Edge"--]] 
L["Top Left"] = "Oben links"
L["Top Right"] = "Oben rechts"
--[[Translation missing --]]
--[[ L["Top to Bottom"] = "Top to Bottom"--]] 
--[[Translation missing --]]
--[[ L["Total:"] = "Total:"--]] 
--[[Translation missing --]]
--[[ L["Track Highest Duration"] = "Track Highest Duration"--]] 
--[[Translation missing --]]
--[[ L["Track Lowest Duration"] = "Track Lowest Duration"--]] 
L["Trigger"] = "Auslöser"
--[[Translation missing --]]
--[[ L["Trigger Mode"] = "Trigger Mode"--]] 
--[[Translation missing --]]
--[[ L["TRIGGERED BY"] = "TRIGGERED BY"--]] 
--[[Translation missing --]]
--[[ L["Truncate Mode"] = "Truncate Mode"--]] 
--[[Translation missing --]]
--[[ L["Truncation"] = "Truncation"--]] 
L["Type"] = "Type"
--[[Translation missing --]]
--[[ L["Type /dfarena again to disable"] = "Type /dfarena again to disable"--]] 
--[[Translation missing --]]
--[[ L["Type:"] = "Type:"--]] 
L["UI Scale:"] = "UI Skalierung:"
--[[Translation missing --]]
--[[ L["Unit Frame"] = "Unit Frame"--]] 
--[[Translation missing --]]
--[[ L["Unit Frame Sorting"] = "Unit Frame Sorting"--]] 
--[[Translation missing --]]
--[[ L["Unit Selection"] = "Unit Selection"--]] 
--[[Translation missing --]]
--[[ L["Units at or above this health percent are faded."] = "Units at or above this health percent are faded."--]] 
--[[Translation missing --]]
--[[ L["Units Per Row"] = "Units Per Row"--]] 
L["Unknown"] = "Unbekannt"
--[[Translation missing --]]
--[[ L["Unknown error"] = "Unknown error"--]] 
--[[Translation missing --]]
--[[ L["Unlock"] = "Unlock"--]] 
--[[Translation missing --]]
--[[ L["Unlock Frames"] = "Unlock Frames"--]] 
--[[Translation missing --]]
--[[ L["Unnamed"] = "Unnamed"--]] 
L["Up"] = "Hoch"
L["Use"] = "Nutze"
L["USE"] = "NUTZE"
L["Use %s"] = "Nutze %s"
L["Use /df overrides for full details in chat"] = "Nutze /df overrides für vollständige Details im Chat"
L["Use Class Color"] = "Nutze Klassenfarbe"
L["Use Current (%s)"] = "Nutze aktuelle (%s)"
--[[Translation missing --]]
--[[ L["Use Current Value"] = "Use Current Value"--]] 
L["Use Custom Colors"] = "Nutze benutzerdefinierte Farben"
--[[Translation missing --]]
--[[ L["Use Custom Pip Color"] = "Use Custom Pip Color"--]] 
L["Use DandersFrames"] = "Nutze DandersFrames"
L["Use DF Color Picker"] = "Benutze DF Farbauswahl"
L["Use DF Color Picker for All Addons"] = "Benutze DF Farbauswahl für alle Addons"
--[[Translation missing --]]
--[[ L["Use FrameSort Addon"] = "Use FrameSort Addon"--]] 
--[[Translation missing --]]
--[[ L["Use Group-Based Layout"] = "Use Group-Based Layout"--]] 
--[[Translation missing --]]
--[[ L["Use recommended defaults"] = "Use recommended defaults"--]] 
--[[Translation missing --]]
--[[ L["Use Seconds Instead of Percent"] = "Use Seconds Instead of Percent"--]] 
--[[Translation missing --]]
--[[ L["Uses a single border per frame. Highest priority wins."] = "Uses a single border per frame. Highest priority wins."--]] 
--[[Translation missing --]]
--[[ L["Uses cast tracking to identify spells WoW marks as secret. Only tracks your own casts."] = "Uses cast tracking to identify spells WoW marks as secret. Only tracks your own casts."--]] 
L["Uses party frame settings/position"] = "Nutze Gruppenrahmen Einstellungen/Position"
--[[Translation missing --]]
--[[ L["Using highest duration trigger"] = "Using highest duration trigger"--]] 
--[[Translation missing --]]
--[[ L["Using lowest duration trigger"] = "Using lowest duration trigger"--]] 
--[[Translation missing --]]
--[[ L["Using spec default"] = "Using spec default"--]] 
--[[Translation missing --]]
--[[ L["v%s loaded. Type %s/df%s for settings, %s/df resetgui%s if window is offscreen."] = "v%s loaded. Type %s/df%s for settings, %s/df resetgui%s if window is offscreen."--]] 
--[[Translation missing --]]
--[[ L["Valid range"] = "Valid range"--]] 
--[[Translation missing --]]
--[[ L["Value:"] = "Value:"--]] 
L["Vehicle"] = "Fahrzeug"
L["Vehicle Icon"] = "Fahrzeugsymbol"
L["Vertical"] = "Vertikal"
L["Vertical Spacing"] = "Vertikaler Abstand"
L["View Imported Macro"] = "Zeige importiertes Makro"
L["Visibility"] = "Sichtbarkeit"
--[[Translation missing --]]
--[[ L["Volume"] = "Volume"--]] 
L["Warlock"] = "Hexenmeister"
--[[Translation missing --]]
--[[ L["Warnings + Errors"] = "Warnings + Errors"--]] 
L["Warrior"] = "Krieger"
L["Weight"] = "Gewicht"
--[[Translation missing --]]
--[[ L["What should '%s' do with this setting?"] = "What should '%s' do with this setting?"--]] 
L["When \"%s\" selected:"] = "Wenn \"%s\" ausgewählt ist:"
--[[Translation missing --]]
--[[ L["When auto-detect is OFF, select which raid buffs to monitor manually."] = "When auto-detect is OFF, select which raid buffs to monitor manually."--]] 
--[[Translation missing --]]
--[[ L["When disabled: Click spell to open Binding Editor."] = "When disabled: Click spell to open Binding Editor."--]] 
--[[Translation missing --]]
--[[ L["When enabled, a new profile will be automatically"] = "When enabled, a new profile will be automatically"--]] 
--[[Translation missing --]]
--[[ L["When enabled, all pips use a single custom color instead of the class-specific default."] = "When enabled, all pips use a single custom color instead of the class-specific default."--]] 
--[[Translation missing --]]
--[[ L["When enabled, all role icons are shown outside of combat. The filters below only apply during combat."] = "When enabled, all role icons are shown outside of combat. The filters below only apply during combat."--]] 
--[[Translation missing --]]
--[[ L["When enabled, click-casting bindings will be"] = "When enabled, click-casting bindings will be"--]] 
--[[Translation missing --]]
--[[ L["When enabled, Masque skins aura icons and borders. DF border settings will be disabled."] = "When enabled, Masque skins aura icons and borders. DF border settings will be disabled."--]] 
--[[Translation missing --]]
--[[ L["When enabled, shows incoming heals even if they would overheal."] = "When enabled, shows incoming heals even if they would overheal."--]] 
--[[Translation missing --]]
--[[ L["When enabled, the group you are in will always be displayed first."] = "When enabled, the group you are in will always be displayed first."--]] 
--[[Translation missing --]]
--[[ L["When enabled: Click spell, press key to bind instantly."] = "When enabled: Click spell, press key to bind instantly."--]] 
--[[Translation missing --]]
--[[ L["When you enter matching content, the layout's overrides are applied on top of your global settings. If no layout matches, global settings are used as-is."] = "When you enter matching content, the layout's overrides are applied on top of your global settings. If no layout matches, global settings are used as-is."--]] 
--[[Translation missing --]]
--[[ L["Which aura data source would you like to use?"] = "Which aura data source would you like to use?"--]] 
--[[Translation missing --]]
--[[ L["While editing, each setting shows its override status:"] = "While editing, each setting shows its override status:"--]] 
--[[Translation missing --]]
--[[ L["Whitelist buffs take priority for the expiring indicator."] = "Whitelist buffs take priority for the expiring indicator."--]] 
L["WHITELISTED"] = "WHITELISTED"
--[[Translation missing --]]
--[[ L["Whole Alpha Pulse"] = "Whole Alpha Pulse"--]] 
L["Width"] = "Breite"
L["Width / Length"] = "Breite / Länge"
--[[Translation missing --]]
--[[ L["Will auto-create on switch"] = "Will auto-create on switch"--]] 
L["Will replace existing Mythic layout"] = "Ersetzt das bestehende Mythic-Layout"
L["Wizard"] = "Zauber"
L["Wizard '%s' saved!"] = "Zauber '%s' gespeichert!"
L["Wizard Builder"] = "Zauber Builder"
L["Wizard Details"] = "Zauber Details"
L["Wizard Name:"] = "Zauber Name:"
L["Works when hovering frames. Action bars work when not hovering."] = "Funktioniert beim Bewegen des Mauszeigers über Frames. Aktionsleisten funktionieren, wenn der Mauszeiger nicht darüber bewegt wird."
L["World bosses, outdoor raids (1-40)"] = "Weltenbosse, Schlachtzug im Freien (1–40)"
L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = "Möchtest du die Standard-Buff-Symbole neben dem Aura Designer beibehalten oder sollen sie vollständig durch diesen ersetzt werden?"
--[[Translation missing --]]
--[[ L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = ""--]] 
L["Would you like to set up your aura filters?"] = "Möchten Sie Ihre Aura-Filter einrichten?"
L["X Color"] = "X Farbe"
L["X Mark"] = "X Zeichen"
L["X Size"] = "X Größe "
L["Yellow=high, Orange=highest, Red=tanking."] = "Gelb = Hoch, Orange = Am höchsten, Rot = Tanking."
L["Yes"] = "Ja"
L["Yes, set it up"] = "Ja, richte es ein"
L["YOUR PROFILES"] = "DEINE PROFILE"
L["Z to A"] = " Z bis A"

