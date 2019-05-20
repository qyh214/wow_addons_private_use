Narci = {}
Narci.L = {}

local L = Narci.L

NARCI_GRADIENT = "|cffA236EFN|cff9448F1a|cff865BF2r|cff786DF4c|cff6A80F6i|cff5D92F7s|cff4FA4F9s|cff41B7FAu|cff33C9FCs|r"
MYMOG_GRADIENT = "|cffA236EFM|cff9448F1y |cff865BF2T|cff786DF4r|cff6A80F6a|cff5D92F7n|cff4FA4F9s|cff41B7FAm|cff33C9FCo|cff32c9fbg|r"

NARCI_VERSION_INFO = "1.0.3[BETA]";
NARCI_DEVELOPER_INFO = "Designed by Peterodox";

L["Movement Speed"] = "MSPD";
L["Damage Reduction Percentage"] = "DR%";

L["Advanced Info"] = "Left click to toggle advanced info.";

L["Photo Mode"] = "Photo Mode";
L["Photo Mode Tooltip Open"] = "Click to open the screenshot toolbox.";
L["Photo Mode Tooltip Close"] = "Click to close the screenshot toolbox.";
L["Photo Mode Tooltip Special"] = "Your captured screenshots in the WoW Screenshots folder will not include this widget.";

L["Xmog Button"] = "Share Transmog";
L["Xmog Button Tooltip Open"] = "Click to show the transmog items instead of actual gears.";
L["Xmog Button Tooltip Close"] = "Click to show the actual gears in your equipment slots.";
L["Xmog Button Tooltip Special"] = "Your may try different layouts.";

L["Emote Button"] = "Do Emote";
L["Emote Button Tooltip Open"] = "Do the emotes with unique animations.";

L["HideTexts Button"] = "Hide Texts";
L["HideTexts Button Tooltip Open"] = "Click to hide all unit names, chat bubbles and combat texts.";
L["HideTexts Button Tooltip Close"] = "Click to restore the unit names, chat bubbles and combat texts.";
L["HideTexts Button Tooltip Special"] = "Your pevious settings will be restored once you quit Photo Mode.";

L["TopQuality Button"] = "Top Quality";
L["TopQuality Button Tooltip Open"] = "Click to set every graphics quality available in the video options to its maximum value.";
L["TopQuality Button Tooltip Close"] = "Click to restore the graphics settings.";

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
L["Minimap Tooltip Right Click"] = "Right-click";
L["Minimap Tooltip Shift Right Click"] = "Shift + Right-click"
L["Minimap Tooltip Hide Button"] = "|cffffffffHide this button|r"
L["Minimap Tooltip Middle Button"] = "|CFFFF1000Middle button |cffffffffReset camera";
L["Minimap Tooltip Set Scale"] = "Set Scale: |cffffffff/narci [scale 0.8~1.2]";

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
NARCI_TRANSMOG = "Transmog";
NARCI_PREFERENCE_TOOLTIP = "Click to open Preference Frame.";
NARCI_TRUNCATE_TEXT = "Truncate Text";
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
NARCI_FADEOUT = "Fade Out on Mouseout";
NARCI_FADEOUT_DESCRIPTION = "Button fades out when you move the cursor out of it.";
NARCI_FADE_MUSIC = "Fade Music In/Out";
NARCI_VIGNETTE_STRENGTH = "Vignette Strength";
NARCI_WEATHER_EFFECT = "Weather Effect";
NARCI_DEFAULT_LAYOUT = "Default Layout";
NARCI_LAYOUT_1 = "Symmetry, 1 Model";
NARCI_LAYOUT_2 = "2 Models";
NARCI_LAYOUT_3 = "Compact Mode";
NARCI_BORDER_THEME = "Border Theme";
NARCI_BORDER_THEME_BRIGHT = "Bright";
NARCI_BORDER_THEME_DARK = "Dark";
NARCI_ALWAYS_SHOW_MODEL = "Always Show Model";
NARCI_SHOW_FULL_BODY = "Show Full Body";
--Model Control--
NARCI_SHEATH_WEAPON = "Sheath Weapon";
NARCI_STAND_IDLY = "Stand Idly";
NARCI_RANGED_WEAPON = "Ranged Weapon";
NARCI_MELEE_WEAPON = "Melee Weapon";
NARCI_SPELLCASTING = "Spellcasting";
NARCI_ANIMATION_ID = "Animation ID";
NARCI_GROUND_SHADOW = "Ground Shadow";
NARCI_HIDE_PLAYER = "Hide Player";

--Solving Lower-case Issue--
NARCI_STAT_STRENGTH = SPEC_FRAME_PRIMARY_STAT_STRENGTH;
NARCI_STAT_AGILITY = SPEC_FRAME_PRIMARY_STAT_AGILITY;
NARCI_STAT_INTELLECT = SPEC_FRAME_PRIMARY_STAT_INTELLECT;