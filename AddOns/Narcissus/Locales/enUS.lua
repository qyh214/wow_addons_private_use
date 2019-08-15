Narci = {}
Narci.L = {}

local L = Narci.L

NARCI_GRADIENT = "|cffA236EFN|cff9448F1a|cff865BF2r|cff786DF4c|cff6A80F6i|cff5D92F7s|cff4FA4F9s|cff41B7FAu|cff33C9FCs|r"
MYMOG_GRADIENT = "|cffA236EFM|cff9448F1y |cff865BF2T|cff786DF4r|cff6A80F6a|cff5D92F7n|cff4FA4F9s|cff41B7FAm|cff33C9FCo|cff32c9fbg|r"

NARCI_VERSION_INFO = "1.0.6[BETA]";
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
L["Minimap Tooltip Enter Photo Mode"] = "|cffffffffEnter photo mode";
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
NARCI_CAMERA = "Camera";
NARCI_TRANSMOG = "Transmog";
NARCI_EXTENSIONS = "Extensions";
NARCI_ABOUT = "About";
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
NARCI_AFK_SCREEN = "AFK Screen";
NARCI_AFK_SCREEN_DESCRIPTION = "Automatically open Narcissus when yo go AFK.";
NARCI_AFK_SCREEN_DESCRIPTION_EXTRA = "This will override ElvUI AFK Mode.";
NARCI_GEMMA = "\"Gemma\"";
NARCI_GEMMY_DESCRIPTION = "Show a list of gems when socketing an item.";
NARCI_DRESSING_ROOM = "Dressing Room"
NARCI_DRESSING_ROOM_DESCRIPTION = "Have a bigger dressing room panel with the ability to view and copy other players' item lists.";
NARCI_REQUIRE_RELOAD = "An UI reload is required.";

--Model Control--
NARCI_SHEATH_WEAPON = "Sheath Weapon";
NARCI_STAND_IDLY = "Stand Idly";
NARCI_RANGED_WEAPON = "Ranged Weapon";
NARCI_MELEE_WEAPON = "Melee Weapon";
NARCI_SPELLCASTING = "Spellcasting";
NARCI_ANIMATION_ID = "Animation ID";
NARCI_GROUND_SHADOW = "Ground Shadow";
NARCI_HIDE_PLAYER = "Hide Player";
NARCI_LINK_LIGHT_SETTINGS = "Link Light Settings";
NARCI_LINK_MODEL_SCALE = "Link Model Scale";
NARCI_GROUP_PHOTO = "Group Photo";
NARCI_GROUP_PHOTO_AVAILABLE = "Now available in Narcissus";
NARCI_GROUP_PHOTO_NOTIFICATION = "Please select a player.";
NARCI_GROUP_PHOTO_INDEX = "Index";
NARCI_GROUP_PHOTO_FRONT = "|cff40c7ebFront|r";
NARCI_GROUP_PHOTO_STATUS_HIDDEN = "Hidden";

--Solving Lower-case or Abbreviation Issue--
NARCI_STAT_STRENGTH = SPEC_FRAME_PRIMARY_STAT_STRENGTH;
NARCI_STAT_AGILITY = SPEC_FRAME_PRIMARY_STAT_AGILITY;
NARCI_STAT_INTELLECT = SPEC_FRAME_PRIMARY_STAT_INTELLECT;
NARCI_CRITICAL_STRIKE = STAT_CRITICAL_STRIKE;

--Equipment Comparison--
NARCI_AZERITE_POWERS = "Azerite Powers";

--Tutorial--
NARCI_TUTORIAL_CAPTUREBUTTON = "Click this button to automatically save 5 separate layers:\nBackground only, green&blue screen with 3D model, color&alpha channel of equipment slots.\n\nTo take a single screenshot, tap your screenshot key.";
NARCI_TUTORIAL_ANIMATION_ID = "Left-click: ID +1  Right-click: ID -1\nValid animation ID: 0~1471";
NARCI_TUTORIAL_GREEN_SCREEN = "Click the square button on the left end to show the green screen.";

--Splash--
NARCI_PATCH_NOTES = "v1.0.6 Patch Notes";
NARCI_SPLASH_CLOSE_AND_CONTINUE = "Close this window and continue";
NARCI_SPLASH_SOUNDS_GREAT_BYE = "That sounds great. See ya!";
NARCI_TRY_IT_NOW = "Click here to enable...";
NARCI_DISABLE_IT_NOW = "Click here to disable...";
    --Patch-specific
    NARCI_DRESSING_ROOM_ENABLED_BY_DEFAULT = "|cff7cc576Enabled by default.|r "..NARCI_DISABLE_IT_NOW;
    NARCI_DRESSING_ROOM_DISABLED = "|cffff5050Disabled.|r An UI reload is required. You can turn it on via Preferences - Extensions.";
    NARCI_CAMERA_SAFE_MODE_ENABLED_BY_DEFAULT = "|cff7cc576Enabled by default because you are not using DynamicCam addon.|r\n"..NARCI_DISABLE_IT_NOW;
    NARCI_CAMERA_SAFE_MODE_DISABLED_BY_DEFAULT = "|cffff5050Disabled by default because you are using DynamicCam.|r\n"..NARCI_TRY_IT_NOW;
    NARCI_CAMERA_SAFE_MODE_ENABLED = "|cff7cc576Enabled.|r You can turn it off via Preferences - Camera.";
    NARCI_CAMERA_SAFE_MODE_DISABLED = "|cffff5050Disabled.|r You can turn it on via Preferences - Camera.";
    --
NARCI_SHOW_DETAILS = "+ Show details...";
NARCI_SPLASH_HEADER1 = "Group Photo & Model Control";
NARCI_SPLASH_HEADER2 = "Miscellaneous";
NARCI_SPLASH_MESSAGE0 = "|cff40C7EB1. You can now take group photos in Narcissus.|r\nAccess this feature from the mini-map button or the model control panel. Create your own story by selecting players and adding them to the scene."
NARCI_SPLASH_MESSAGE1 = "|cff40C7EB2. Gain more control over the model lighting.|r\nYou may control the light intensity and apply different colors to the spotlight and the ambient light.";
NARCI_SPLASH_MESSAGE2 = "|cff40C7EB2. Camera-safe Mode|r\nIn rare cases, the ActionCam cannot be fully closed for non-ActionCam user after exiting Narcissus. Toggle this option to make sure the ActionCam is always disabled after closing this addon."
NARCI_SPLASH_MESSAGE3 = "|cff40C7EB1. Upgraded Dressing Room|r\nHave a larger dressing room panel with the ability to view and copy other players' item lists."

--Project Details--
NARCI_ALL_PROJECTS = "All Projects";
NARCI_PROJECT_DETAILS = "|cFFFFD100Developer: Peterodox\nRelease Date: August 13, 2019|r\n\nThank you for trying this add-on! If you have any issues, suggestions, ideas, please leave a comment on the curseforge page or contact me on...";
NARCI_PROJECT_AAA_TITLE = "|cff008affA|cff0d8ef2z|cff1a92e5e|cff2696d9r|cff339acco|cff409ebft|cff4da1b2h |cff59a5a6A|cff66a999d|cff73ad8cv|cff7fb180e|cff8cb573n|cff99b966t|cffa6bd59u|cffb2c14dr|cffbfc440e |cffccc833A|cffd9cc26l|cffe5d01ab|cfff2d40du|cffffd800m";
NARCI_PROJECT_AAA_SUMMARY = "Explore places of interest and collect lores and photos from all across Azeroth.|cff636363";
NARCI_PROJECT_NARCISSUS_SUMMARY = "An immersive character pane and your ultimate screenshot tool.";