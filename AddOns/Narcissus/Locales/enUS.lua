Narci.L = {}

local L = Narci.L

NARCI_GRADIENT = "|cffA236EFN|cff9448F1a|cff865BF2r|cff786DF4c|cff6A80F6i|cff5D92F7s|cff4FA4F9s|cff41B7FAu|cff33C9FCs|r"
MYMOG_GRADIENT = "|cffA236EFM|cff9448F1y |cff865BF2T|cff786DF4r|cff6A80F6a|cff5D92F7n|cff4FA4F9s|cff41B7FAm|cff33C9FCo|cff32c9fbg|r"

NARCI_VERSION_INFO = "1.0.9a";
NARCI_DEVELOPER_INFO = "Designed by Peterodox";

NARCI_NEW_ENTRY_PREFIX = "|cff40C7EB";
NARCI_COLOR_GREY_85 = "|cffd8d8d8";
NARCI_COLOR_GREY_70 = "|cffb3b3b3";
NARCI_COLOR_RED_MILD = "|cffff5050";
NARCI_COLOR_GREEN_MILD = "|cff7cc576";
NARCI_COLOR_YELLOW = "|cfffced00";
NARCI_COLOR_CYAN_DARK = "|cff5385a5";
NARCI_COLOR_CYAN_DARK_RGB = {58/255, 97/255, 122/255};

NARCI_MODIFIER_ALT = "ALT key";   --Windows
NARCI_SHORTCUTS_COPY = "Ctrl+C";
if IsMacClient() then
      --Mac OS
    NARCI_MODIFIER_ALT = "Option key";
    NARCI_SHORTCUTS_COPY = "Command+C";
end

L["Press Copy"] = NARCI_COLOR_GREY_70.. "Press |r".. NARCI_SHORTCUTS_COPY.. NARCI_COLOR_GREY_70 .." to Copy";
L["Copied"] = NARCI_COLOR_GREEN_MILD.. "Link Copied";

L["Movement Speed"] = "MSPD";
L["Damage Reduction Percentage"] = "DR%";

L["Advanced Info"] = "Left click to toggle advanced info.";

L["Photo Mode"] = "Photo Mode";
L["Photo Mode Tooltip Open"] = "Open the screenshot toolbox.";
L["Photo Mode Tooltip Close"] = "Close the screenshot toolbox.";
L["Photo Mode Tooltip Special"] = "Your captured screenshots in the WoW Screenshots folder will not include this widget.";

L["Xmog Button"] = "Share Transmog";
L["Xmog Button Tooltip Open"] = "Show the transmog items instead of actual gears.";
L["Xmog Button Tooltip Close"] = "Show the actual gears in your equipment slots.";
L["Xmog Button Tooltip Special"] = "Your may try different layouts.";

L["Emote Button"] = "Do Emote";
L["Emote Button Tooltip Open"] = "Do the emotes with unique animations.";
L["Auto Capture"] = "Auto Capture";

L["HideTexts Button"] = "Hide Texts";
L["HideTexts Button Tooltip Open"] = "Hide all unit names, chat bubbles and combat texts.";
L["HideTexts Button Tooltip Close"] = "Restore the unit names, chat bubbles and combat texts.";
L["HideTexts Button Tooltip Special"] = "Previous settings will be restored when you exit.";

L["TopQuality Button"] = "Top Quality";
L["TopQuality Button Tooltip Open"] = "Set every graphics quality option to its maximum.";
L["TopQuality Button Tooltip Close"] = "Restore your graphics settings.";

--Special Source--
L["Heritage Armor"] = "Heritage Armor";
ITEMSOURCE_SECRETFINDING = "Secret Finding"

HEART_QUOTE_1 = "what is essential is invisible to the eye.";

--Title Manager--
NARCI_TITLE_MANAGER_OPEN = "Open Title Manager";
NARCI_TITLE_MANAGER_CLOSE = "Close Title Manager";

--Alias--
NARCI_ALIAS_USE_ALIAS = "Switch to Alias"
NARCI_ALIAS_USE_PLAYER_NAME = "Switch to "..CALENDAR_PLAYER_NAME;

L["Minimap Tooltip Double Click"] = "Double-tap";
L["Minimap Tooltip Left Click"] = "Left-click|r";
L["Minimap Tooltip To Open"] = "|cffffffffOpen "..CHARACTER_INFO;
L["Minimap Tooltip Enter Photo Mode"] = "|cffffffffEnter photo mode";
L["Minimap Tooltip Right Click"] = "Right-click";
L["Minimap Tooltip Shift Left Click"] = "Shift + Left-click";
L["Minimap Tooltip Shift Right Click"] = "Shift + Right-click";
L["Minimap Tooltip Hide Button"] = "|cffffffffHide this button|r"
L["Minimap Tooltip Middle Button"] = "|CFFFF1000Middle button |cffffffffReset camera";
L["Minimap Tooltip Set Scale"] = "Set Scale: |cffffffff/narci [scale 0.8~1.2]";
L["Corrupted Item Parser"] = "|cffffffffToggle Corrupted Item Parser|r";
L["Toggle Dressing Room"] = "|cffffffffToggle "..DRESSUP_FRAME.."|r";

NARCI_CLIPBOARD = "Clipboard";
NARCI_LAYOUT = "Layout";
NARCI_LAYOUT_SYMMETRY = "Symmetry";
NARCI_LAYOUT_ASYMMETRY = "Asymmetry";
NARCI_COPY_TEXTS = "Copy Texts";
NARCI_SYNTAX = "Syntax";
NARCI_SYNTAX_PLAIN_TEXT = "Plain Text";
NARCI_SYNTAX_BBCODE = "BB Code";
NARCI_SYNTAX_MARKDOWN = "Markdown";
NARCI_EXPORT_INCLUDES = "Export Includes...";
NARCI_ITEM_ID = "Item ID";

NARCI_3DMODEL = "3D Model";
NARCI_EQUIPMENTSLOTS = "Equipment Slots";

--Preferences--
NARCI_PREFERENCE = "Preferences-PH";
NARCI_INTERFACE = "Interface";
NARCI_THEME = "Themes";
NARCI_EFFECTS = "Effects";
NARCI_CAMERA = "Camera";
NARCI_TRANSMOG = "Transmog";
NARCI_PHOTO_MODE = L["Photo Mode"];
NARCI_EXTENSIONS = "Extensions";
L["Credits"] = "Credits";
NARCI_ABOUT = "About";
NARCI_PREFERENCE_TOOLTIP = "Click to open Preference Frame.";
NARCI_TRUNCATE_TEXT = "Truncate Text";
NARCI_ATTRIBUTE_FRAME = "Stat Sheet";
NARCI_TEXT_WIDTH = "Text Width";
NARCI_HOTKEY = "Hotkey";
NARCI_DOUBLE_TAP = "Double-tap";
NARCI_DOUBLE_TAP_DESCRIPTION = "Double-tap the key bound to Character Pane to open Narcissus."
NARCI_OVERRIDE = "Override";
NARCI_INVALID_KEY = "Invalid key combination.";
NARCI_MINIMAP_BUTTON = "Minimap Button";
NARCI_SHORTCUTS = "Shortcuts";
NARCI_FILTERS = "Filters";
NARCI_FILTERS_DESCRIPTION = "All filters except vignette will be disabled in transmog mode.";
NARCI_GRAIN_EFFECT = "Grain Effect";
NARCI_CAMERA_MOVEMENT = "Camera Movement";
NARCI_CAMERA_ORBIT = "Orbit Camera";
NARCI_CAMERA_ORBIT_ENABLED_DESCRIPTION = "When you open this addon, the camera will be rotated to your front and begin orbiting.";
NARCI_CAMERA_ORBIT_DISABLED_DESCRIPTION = "When you open this addon, the camera will be zoomed in without rotation";
NARCI_CAMERA_SAFE_MODE = "Camera Safe Mode";
NARCI_CAMERA_SAFE_MODE_DESCRIPTION = "Fully disable ActionCam feature after closing this addon.";
NARCI_CAMERA_SAFE_MODE_DESCRIPTION_EXTRA = "Untoggled because you are using DynamicCam."
NARCI_FADEOUT = "Fade Out on Mouseout";
NARCI_FADEOUT_DESCRIPTION = "Button fades out when you move the cursor out of it.";
NARCI_FADE_MUSIC = "Fade Music In/Out";
NARCI_VIGNETTE_STRENGTH = "Vignette Strength";
NARCI_WEATHER_EFFECT = "Weather Effect";
NARCI_LETTERBOX_EFFECT = "Letterbox";
NARCI_LETTERBOX_RATIO = "Ratio"
NARCI_LETTERBOX_EFFECT_ALERT1 = "The aspect ratio of your monitor exceeds the selected ratio!"
NARCI_LETTERBOX_EFFECT_ALERT2 = "It is recommend to set the UI Scale to %0.1f\n(the current scale is %0.1f)"
NARCI_DEFAULT_LAYOUT = "Default Layout";
NARCI_LAYOUT_1 = "Symmetry, 1 Model";
NARCI_LAYOUT_2 = "2 Models";
NARCI_LAYOUT_3 = "Compact Mode";
NARCI_BORDER_THEME = "Border Theme";
NARCI_BORDER_THEME_BRIGHT = "Bright";
NARCI_BORDER_THEME_DARK = "Dark";
NARCI_ALWAYS_SHOW_MODEL = "Always Show Model";
NARCI_SHOW_FULL_BODY = "Show Full Body";
NARCI_AFK_SCREEN_DESCRIPTION = "Automatically open Narcissus when yo go AFK.";
NARCI_AFK_SCREEN_DESCRIPTION_EXTRA = "This will override ElvUI AFK Mode.";
NARCI_GEMMA = "\"Gemma\"";
NARCI_GEMMY_DESCRIPTION = "Show a list of gems when socketing an item.";
NARCI_DRESSING_ROOM = "Dressing Room"
NARCI_DRESSING_ROOM_DESCRIPTION = "Bigger dressing room pane with the abilities to view and copy other players' item lists and generate Wowhead dressing room links.";
NARCI_REQUIRE_RELOAD = NARCI_COLOR_RED_MILD.. "UI reload is required.|r";
NARCI_PREFERENCE_GENERAL = "General";   --General options

L["Show Detailed Stats"] = "Show Detailed Stats";
L["Tooltip Color"] = "Tooltip Color";
L["Entrance Visual"] = "Entrance Visual";
L["Entrance Visual Description"] = "Play spell visuals when your model shows up.";
L["Panel Scale"] = "Panel Scale";
L["Exit Confirmation"] = "Exit Confirmation";
L["Exit Confirmation Texts"] = "Quit group photo?";
L["Exit Confirmation Leave"] = "Yes";
L["Exit Confirmation Cancel"] = "No";
L["Ultra-wide"] = "Ultra-wide";
L["Ultra-wide Optimization"] = "Ultra-wide Optimization";
L["Baseline Offset"] = "Baseline Offset";
L["Ultra-wide Tooltip"] = "You can see this option because you are using a %s:9 monitor.";
L["Interactive Area"] = "Interactive Area";
L["Item Socketing Tooltip"] = "Double-click to embed";
L["No Available Gem"] = "|cffd8d8d8No available gem|r";
L["Use Bust Shot"] = "Use Bust Shot";
L["Use Escape Button"] = "Esc Key";
L["Use Escape Button Description"] = "Press the Escape key to exit.\nOr exit by clicking the hidden X button on the top-right of your screen.";
L["Handled by Other Addons"] = "Handled by Other Addons";
L["AFK Screen"] = "AFK Screen";
L["Keep Standing"] = "Keep Standing";
L["Keep Standing Description"] = "Cast /stand every now and then when you go AFK. This will not prevent AFK logout.";
L["None"] = "None";
L["NPC"] = "NPC";
L["Database"] = "Database";
L["Creature Tooltip"] = "Creature Tooltip";
L["RAM Usage"] = "RAM Usage";
L["Others"] = "Others";
L["Find Relatives"] = "Find Relatives";
L["Find Related Creatures Description"] = "Search for creatures with the same last name.";
L["Find Relatives Hotkey Format"] = "Press %s to find relatives.";
L["Translate Names"] = "Translate Names";
L["Translate Names Description On"] = "Show unit's translated name(s) on...";
L["Translate Names Description Off"] = "";
L["Select A Language"] = "Selected languge:";
L["Select Multiple Languages"] = "Selected languges:";
L["Load on Demand"] = "Load on Demand";
L["Load on Demand Description On"] = "Don't load database until using search functions.";
L["Load on Demand Description Off"] = "Load creature database when you log in.";
L["Load on Demand Description Disabled"] = NARCI_COLOR_YELLOW.. "This toggle is locked because you have enabled creature tooltip.";
L["Tooltip"] = "Tooltip";
L["Name Plate"] = "Name Plate";
L["Y Offset"] = "Y Offset";
L["Sceenshot Quality"] = "Sceenshot Quality";
L["Screenshot Quality Description"] = "Higher quality results in bigger file size.";

--Model Control--
NARCI_HOLD_WEAPON = "Grab Weapon";
NARCI_STAND_IDLY = "Stand Idly";
NARCI_RANGED_WEAPON = "Ranged Weapon";
NARCI_MELEE_WEAPON = "Melee Weapon";
NARCI_SPELLCASTING = "Spellcasting";
NARCI_ANIMATION_ID = "Animation ID";
NARCI_LINK_LIGHT_SETTINGS = "Link Light Settings";
NARCI_LINK_MODEL_SCALE = "Link Model Scale";
NARCI_GROUP_PHOTO = "Group Photo";
NARCI_GROUP_PHOTO_AVAILABLE = "Now available in Narcissus";
NARCI_GROUP_PHOTO_NOTIFICATION = "Please select a target.";
NARCI_GROUP_PHOTO_STATUS_HIDDEN = "Hidden";
NARCI_GROUP_PHOTO_ADD_MODEL = "Left-click: Add your target into the scene.\nRight-click: Create from collection."
NARCI_DIRECTIONAL_AMBIENT_LIGHT = "Directional/Ambient Light";
NARCI_DIRECTIONAL_AMBIENT_LIGHT_TOOLTIP = "Switch between\n- Directional light that can be blocked by object and cast shadow\n- Ambient light that influences the entire model";
L["Reset"] = "Reset";
L["Actor Index"] = "Index";
L["Move To Font"] = "|cff40c7ebFront|r";
L["Actor Index Tooltip"] = "Drag an index button to change the model's layer.";
L["Play Button Tooltip"] = "Left-click: Play this animation\nRight-click: Resume all models\' animations";
L["Pause Button Tooltip"] = "Left-click: Pause this animation\nRight-click: Pause all models\' animations";
L["Save Layers"] = "Save Layers";
L["Save Layers Tooltip"] = "Automatically capture 6 screenshots for picture compositing.\nPlease do not move your cursor or click any buttons during this process. Otherwise, your character could becomes invisible after exiting the addon. Should it happen, use this command:\n/console showplayer";
L["Ground Shadow"] = "Ground Shadow";
L["Ground Shadow Tooltip"] = "Add a movable ground shadow beneath you model.";
L["Hide Player"] = "Hide Player";
L["Hide Player Tooltip"] = "Make your character invisible to yourself.";
L["Virtual Actor"] = "Virtual";
L["Virtual Actor Tooltip"] = "Only the spell visual on this model is visible."
L["Self"] = "Self";
L["Target"] = "Target";
L["Compact Mode Tooltip"] = "Only use the left part of your screen to present your transmog.";
L["Toggle Equipment Slots"] = "Toggle equipment slots";
L["Toggle Text Mask"] = "Toggle text mask";
L["Toggle 3D Model"] = "Toggle 3D model";
L["Toggle Model Mask"] = "Toggle model mask";
L["Show Color Sliders"] = "Show color sliders";
L["Show Color Presets"] = "Show color presets";
L["Keep Druid Form"] = "Hold "..NARCI_MODIFIER_ALT.." to keep druid form"
L["Race Change Tooltip"] = "Change to another playerable race";
L["Sex Change Tooltip"] = "Change sex";

--Spell Visual Browser--
L["Visuals"] = "Visuals";
L["Visual ID"] = "Visual ID";
L["Animation ID Abbre"] = "Anim. ID";
L["Category"] = "Category";
L["Sub-category"] = "Sub-category";
L["My Favorites"] = "My Favorites";
L["Reset Visual Tooltip"] = "Remove unapplied visuals";
L["Remove Visual Tooltip"] = "Left-click: Remove a selected visual\nLong-click: Remove all applied visuals";
L["Apply"] = "Apply";
L["Applied"] = "Applied";   --Viusals that were "Applied" to the model
L["Remove"] = "Remove";
L["Rename"] = "Rename";
L["Refresh Model"] = "Refresh Model";
L["Toggle Browser"] = "Toggle spell visual browser";
L["Next And Previous"] = "Left-click: Go to next\nRight-click: Go to previous";
L["New Favorite"] = "New Favorite";
L["Favorites Add"] = "Add to My Favorites";
L["Favorites Remove"] = "Remove from Favorites";
L["Auto-play"] = "Auto-play";   --Auto-play suggested animation
L["Auto-play Tooltip"] = "Auto-play the animation\nthat is tied to the selected visual.";
L["Delete Entry Plural"] = "Will delete %s entries";
L["Delete Entry Singular"] = "Will delete %s entry";
L["History Panel Note"] = "Applied visuals will be shown here";
L["Return"] = "Return";
L["Close"] = "Close";

--Dressing Room--
L["Favorited"] = "Favorited";
L["Unfavorited"] = "Unfavorited";
L["Item List"] = "Item List";
L["Use Target Model"] = "Use Target's Model";
L["Use Your Model"] = "Use Your Model";
L["Cannot Inspect Target"] = "Cannot Inspect Target"
L["External Link"] = "External Link";
L["Add to MogIt Wishlist"] = "Add to MogIt Wishlist";

--NPC Browser--
NARCI_NPC_BROWSER_TITLE_LEVEL = ".*%?%?.?";      --Level ?? --Use this to check if the second line of the tooltip is NPC's title or unit type
L["NPC Browser"] = "NPC Browser";
L["NPC Browser Tooltip"] = "Choose an NPC from the list.";
L["Search for NPC"] = "Search for NPC";
L["Name or ID"] = "Name or ID";
L["NPC Has Weapons"] = "Has Signiture Weapons";
L["Retrieving NPC Info"] = "Retrieving NPC Info";
L["Loading Database"] = "Loading Database...\nYour screen could freeze for a few seconds.";
L["Other Last Name Format"] = "Other "..NARCI_COLOR_GREY_70.."%s(s)|r:\n";
L["Too Many Matches Format"] = "\nOver %s matches.";

--Solving Lower-case or Abbreviation Issue--
NARCI_STAT_STRENGTH = SPEC_FRAME_PRIMARY_STAT_STRENGTH;
NARCI_STAT_AGILITY = SPEC_FRAME_PRIMARY_STAT_AGILITY;
NARCI_STAT_INTELLECT = SPEC_FRAME_PRIMARY_STAT_INTELLECT;
NARCI_CRITICAL_STRIKE = STAT_CRITICAL_STRIKE;


--Equipment Comparison--
NARCI_AZERITE_POWERS = "Azerite Powers";
L["Gem Tooltip Format1"] = "%s and %s";
L["Gem Tooltip Format2"] = "%s, %s and %s more...";

--Equipment Set Manager
L["Equipped Item Level Format"] = "Equipped %s";
L["Equipped Item Level Tooltip"] = "The average item level of your currently equipped items.";
L["Equipment Manager"] = EQUIPMENT_MANAGER;
L["Toggle Equipment Set Manager"] = "Left click to toggle equipment set manager.";
L["Duplicated Set"] = "Duplicated Set";
L["Low Item Level"] = "Low item level";
L["1 Missing Item"] = "1 missing item";
L["n Missing Items"] = "%s missing items";
L["Update Items"] = "Update Items";
L["Don't Update Items"] = "Don't Update Items";
L["Update Talents"] = "Update Talents";
L["Don't Update Talents"] = "Don't Update Talents";
L["Old Icon"] = "Old Icon";
NARCI_ICON_SELECTOR = "Icon Selector";
NARCI_DELETE_SET_WITH_LONG_CLICK = "Delete Set\n|cff808080(click and hold)|r";

--Corruption System
L["Corruption System"] = "Corruption";
L["Eye Color"] = "Eye Color";
L["Blizzard UI"] = "Blizzard UI";
L["Corruption Bar"] = "Corruption Bar";
L["Corruption Bar Description"] = "Enable the corruption bar next to the Character Pane.";
L["Corruption Debuff Tooltip"] = "Debuff Tooltip";
L["Corruption Debuff Tooltip Description"] = "Replace the default negative effects tooltip with its numeric counterpart.";
L["No Corrupted Item"] = "You haven't equipped any corrupted item.";
L["Total Corruption Format"] = CORRUPTION_TOOLTIP_LINE.." - "..CORRUPTION_RESISTANCE_TOOLTIP_LINE.." = ".."%s";

L["Crit Gained"] = CRIT_ABBR.." Gained";
L["Haste Gained"] = STAT_HASTE.." Gained";
L["Mastery Gained"] = STAT_MASTERY.." Gained";
L["Versatility Gained"] = STAT_VERSATILITY.." Gained";

L["Proc Crit"] = "Proc "..CRIT_ABBR;
L["Proc Haste"] = "Proc "..STAT_HASTE;
L["Proc Mastery"] = "Proc "..STAT_MASTERY;
L["Proc Versatility"] =  "Proc "..STAT_VERSATILITY;

L["Critical Damage"] = CRIT_ABBR.."DMG";

L["Corruption Effect Format1"] = "|cffffffff%s%%|r speed reduced";
L["Corruption Effect Format2"] = "|cffffffff%s|r initial damage\n|cffffffff%s yd|r radius";
L["Corruption Effect Format3"] = "|cffffffff%s|r damage\n|cffffffff%s%%|r of your HP";
L["Corruption Effect Format4"] = "Struck by the Thing From Beyond triggers other debuffs";
L["Corruption Effect Format5"] = "|cffffffff%s%%|r damage\\healing taken modified";

--Tutorial--
L["Alert"] = "Warning";
L["Race Change"] = "Race/Gender Change";
L["Race Change Line1"] = "You can again change your race and gender. But there are some limitations:\n1. Your weapons will disappear.\n2. Spell visuals can no longer be removed.\n3. It does not work on other players or NPC.";
L["Guide Spell Headline"] = "Try or Apply";
L["Guide Spell Criteria1"] = "Left-click to TRY";
L["Guide Spell Criteria2"] = "Right-click to APPLY";
L["Guide Spell Line1"] = "Most spell visuals that you add by clicking left button will fade away in seconds, while those you add by clicking right button will not.\n\nNow please move to an entry then:";
L["Guide Spell Choose Category"] = "You can add spell visuals to your model. Choose any category you like. Then choose a subcategory.";
L["Guide History Headline"] = "History Panel";
L["Guide History Line1"] = "At most 5 recently applied visuals can retain here. You can select one and delete it by clicking the Remove button on the right end.";
L["Guide Refresh Line1"] = "Use this button to remove all unapplied spell visuals. Those that were in the history panel will be reapplied.";
L["Guide Input Headline"] = "Manual Input";
L["Guide Input Line1"] = "You may also input a SpellVisualKitID yourself. As of 8.3, Its cap is around 124,000.\nYou can use your mousewheel to try the next/previous ID.\nVery few IDs can crash the game.";
L["Guide Equipment Manager Line1"] = "Double-click: Use a set\nRight-click: Edit a set.\n\nThis button's previous function has been moved to Preferences.";
L["Guide Model Control Headline"] = "Model Control";
L["Guide Model Control Line1"] = format("This model shares the same mouse actions you use in the dressing room, plus:\n\n1.Hold %s and Left Button: Rotate model around Y-axis.\n2.Hold %s and Right Button: Execute scrubby zoom.", NARCI_MODIFIER_ALT, NARCI_MODIFIER_ALT);
L["Guide Minimap Button Headline"] = "Minimap Button";
L["Guide Minimap Button Line1"] = "Narcissus minimap button can now be handled by other addons.\nYou can change this option in the Preferences pane. It may require a UI reload."
L["Guide NPC Entrance Line1"] = "The access to this new feature is in here."
L["Guide NPC Browser Line1"] = "Notable NPCs are listed in the catalog below.\nYou can also search for ANY creatures by name or ID.\nNotice that the first time you use the search function this login, it could take a few seconds to build the search table and your screen might freeze as well.\nYou may untoggle the \"Load on Demand\" option in the Preference Pane so that the database will be constructed right after you log in.";

--Splash--
NARCI_SPELL_VISUALS = "Spell Visuals";
NARCI_PATCH_NOTES = "v1.0.7 Patch Notes";
NARCI_SPLASH_CLOSE_AND_CONTINUE = "Close this window and continue";
NARCI_SPLASH_SOUNDS_GREAT_BYE = "That sounds great. See ya!";
NARCI_TRY_IT_NOW = "Click here to enable...";
NARCI_DISABLE_IT_NOW = "Click here to disable...";
    --Patch-specific
    NARCI_DRESSING_ROOM_ENABLED_BY_DEFAULT = NARCI_COLOR_GREEN_MILD.."Enabled by default.|r "..NARCI_DISABLE_IT_NOW;
    NARCI_DRESSING_ROOM_DISABLED = NARCI_COLOR_RED_MILD.. "Disabled.|r UI reload is required. You can turn it on via Preferences - Extensions.";
    NARCI_CAMERA_SAFE_MODE_ENABLED_BY_DEFAULT = NARCI_COLOR_GREEN_MILD.."Enabled by default because you are not using DynamicCam addon.|r\n"..NARCI_DISABLE_IT_NOW;
    NARCI_CAMERA_SAFE_MODE_DISABLED_BY_DEFAULT = NARCI_COLOR_RED_MILD.."Disabled by default because you are using DynamicCam.|r\n"..NARCI_TRY_IT_NOW;
    NARCI_CAMERA_SAFE_MODE_ENABLED = NARCI_COLOR_GREEN_MILD.."Enabled.|r You can turn it off via Preferences - Camera.";
    NARCI_CAMERA_SAFE_MODE_DISABLED = NARCI_COLOR_RED_MILD.."Disabled.|r You can turn it on via Preferences - Camera.";
    --
NARCI_SHOW_DETAILS = "+ Show details...";
NARCI_SPLASH_HEADER3 = "Miscellaneous";
NARCI_SPLASH_MESSAGE0 = "|cffd9cdb41. You can now apply special visuals to your scene.|r\nYou can put spells, gadgets onto the actors and even control the weather. Access this feature from the model control panel."
NARCI_SPLASH_MESSAGE1 = format("|cffd9cdb42. Flipping model and scrubby zoom.|r\nYou can hold %s and left button to rotate the model around Y-axis. Or hold %s and right button to execute scrubby zoom.", NARCI_MODIFIER_ALT, NARCI_MODIFIER_ALT);
NARCI_SPLASH_MESSAGE2 = "|cffd9cdb4You can open it by clicking the hexagonal button on the top right (where your maximum item level is shown).";
NARCI_SPLASH_MESSAGE3 = "|cffd9cdb41.The AFK screen will be closed automatically when moving or entering combat.\n2. The enhanced dressing room is back online.|r";

L["Show Whats New"] = "Show Whats New";
NARCI_SPLASH_WHATS_NEW_FORMAT = "What's New in Narcissus %s";
NARCI_SPLASH_HEADER1 = "NPC Browser";
NARCI_SPLASH_HEADER2 = "Miscellaneous";
NARCI_SPLASH_INTERACTIVE_TEXT1 = NARCI_COLOR_GREY_85.."Group Photo|r\n- You can add any NPC into your scene regardless of your current location.\n- Choose from the list or search by name or ID.\n\n".. NARCI_COLOR_GREY_85.."Creature Tooltip (Optional)|r\n- Find the creatures with the same last name when mousing over an NPC.\n- Show NPC’s translated names on its name plate or tooltip.";
NARCI_SPLASH_INTERACTIVE_TEXT2 = NARCI_COLOR_GREY_85.."";
NARCI_SPLASH_INTERACTIVE_TEXT3 = NARCI_COLOR_GREY_85.."AFK Screen|r\nThe auto-stand feature has become optional.\n\n" ..NARCI_COLOR_GREY_85.."Screenshot Quality|r\n- No longer overrides the quality to 10\n- A quality slider was added to the Preferences pane.\n\n" ..NARCI_COLOR_GREY_85.."Corruption Module|r\n- Now compatible with Corruption Tooltip.\n- Damage from Eye of Corruption has been updated to ( 0.5*corruption + 15 ) * HP";

--Project Details--
NARCI_ALL_PROJECTS = "All Projects";
NARCI_PROJECT_DETAILS = "|cFFFFD100Developer: Peterodox\nRelease Date: April 26, 2020|r\n\nThank you for trying this add-on! If you have any issues, suggestions, ideas, please leave a comment on the curseforge page or contact me on...";
NARCI_PROJECT_AAA_TITLE = "|cff008affA|cff0d8ef2z|cff1a92e5e|cff2696d9r|cff339acco|cff409ebft|cff4da1b2h |cff59a5a6A|cff66a999d|cff73ad8cv|cff7fb180e|cff8cb573n|cff99b966t|cffa6bd59u|cffb2c14dr|cffbfc440e |cffccc833A|cffd9cc26l|cffe5d01ab|cfff2d40du|cffffd800m";
NARCI_PROJECT_AAA_SUMMARY = "Explore places of interest and collect lores and photos from all across Azeroth.|cff636363";
NARCI_PROJECT_NARCISSUS_SUMMARY = "An immersive character pane and your ultimate screenshot tool.";


--Credits--
NARCI_CREDITS_EXTRA = "Marlamin | WoW.tools\nKeyboardturner";

--Conversation--
L["Q1"] = "What is this?";
L["Q2"] = "I know. But why is this so huge?";
L["Q3"] = "That's not funny. I just need a regular one.";
L["Q4"] = "Good. What if I want to disable it?";
L["Q5"] = "One more thing, could you promise me no more pranks?";
L["A1"] = "Apparently, this is an exit confirmation dialog. It pops up when you try to exit group photo mode by pressing hotkey.";
L["A2"] = "Ha, that's what she said.";
L["A3"] = "Fine...fine..."
L["A4"] = "Just open the Preferences then go Photo Mode. You won't miss it.";