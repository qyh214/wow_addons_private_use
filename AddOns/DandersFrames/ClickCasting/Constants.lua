local addonName, DF = ...

-- Get module namespace
local CC = DF.ClickCast

-- ============================================================
-- CONSTANTS
-- ============================================================

-- Mouse buttons we support (WoW supports up to Button31 for gaming mice)
CC.MOUSE_BUTTONS = {
    "LeftButton",
    "RightButton", 
    "MiddleButton",
    "Button4",
    "Button5",
    "Button6",
    "Button7",
    "Button8",
    "Button9",
    "Button10",
    "Button11",
    "Button12",
    "Button13",
    "Button14",
    "Button15",
    "Button16",
    "Button17",
    "Button18",
    "Button19",
    "Button20",
    "Button21",
    "Button22",
    "Button23",
    "Button24",
    "Button25",
    "Button26",
    "Button27",
    "Button28",
    "Button29",
    "Button30",
    "Button31",
}

-- Display names for mouse buttons
CC.BUTTON_DISPLAY_NAMES = {
    LeftButton = "Left Click",
    RightButton = "Right Click",
    MiddleButton = "Middle Click",
    Button4 = "Mouse 4",
    Button5 = "Mouse 5",
    Button6 = "Mouse 6",
    Button7 = "Mouse 7",
    Button8 = "Mouse 8",
    Button9 = "Mouse 9",
    Button10 = "Mouse 10",
    Button11 = "Mouse 11",
    Button12 = "Mouse 12",
    Button13 = "Mouse 13",
    Button14 = "Mouse 14",
    Button15 = "Mouse 15",
    Button16 = "Mouse 16",
    Button17 = "Mouse 17",
    Button18 = "Mouse 18",
    Button19 = "Mouse 19",
    Button20 = "Mouse 20",
    Button21 = "Mouse 21",
    Button22 = "Mouse 22",
    Button23 = "Mouse 23",
    Button24 = "Mouse 24",
    Button25 = "Mouse 25",
    Button26 = "Mouse 26",
    Button27 = "Mouse 27",
    Button28 = "Mouse 28",
    Button29 = "Mouse 29",
    Button30 = "Mouse 30",
    Button31 = "Mouse 31",
}

-- Scroll wheel bindings
CC.SCROLL_BUTTONS = {
    "SCROLLUP",
    "SCROLLDOWN",
}

CC.SCROLL_DISPLAY_NAMES = {
    SCROLLUP = "Scroll Up",
    SCROLLDOWN = "Scroll Down",
}

-- Keyboard keys for hover-casting
CC.KEYBOARD_KEYS = {
    -- Letters
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    -- Numbers
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
    -- Function keys
    "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
    -- Special keys
    "BACKQUOTE", "MINUS", "EQUALS", "BACKSPACE", "TAB",
    "LEFTBRACKET", "RIGHTBRACKET", "BACKSLASH", "SEMICOLON", "QUOTE",
    "COMMA", "PERIOD", "SLASH", "SPACE", "INSERT", "DELETE", "HOME", "END",
    "PAGEUP", "PAGEDOWN", "NUMPAD0", "NUMPAD1", "NUMPAD2", "NUMPAD3",
    "NUMPAD4", "NUMPAD5", "NUMPAD6", "NUMPAD7", "NUMPAD8", "NUMPAD9",
    "NUMPADDECIMAL", "NUMPADDIVIDE", "NUMPADMULTIPLY", "NUMPADMINUS", "NUMPADPLUS",
}

CC.KEY_DISPLAY_NAMES = {
    BACKQUOTE = "`",
    MINUS = "-",
    EQUALS = "=",
    BACKSPACE = "Backspace",
    TAB = "Tab",
    LEFTBRACKET = "[",
    RIGHTBRACKET = "]",
    BACKSLASH = "\\",
    SEMICOLON = ";",
    QUOTE = "'",
    COMMA = ",",
    PERIOD = ".",
    SLASH = "/",
    SPACE = "Space",
    INSERT = "Insert",
    DELETE = "Delete",
    HOME = "Home",
    END = "End",
    PAGEUP = "Page Up",
    PAGEDOWN = "Page Down",
    NUMPAD0 = "Num 0",
    NUMPAD1 = "Num 1",
    NUMPAD2 = "Num 2",
    NUMPAD3 = "Num 3",
    NUMPAD4 = "Num 4",
    NUMPAD5 = "Num 5",
    NUMPAD6 = "Num 6",
    NUMPAD7 = "Num 7",
    NUMPAD8 = "Num 8",
    NUMPAD9 = "Num 9",
    NUMPADDECIMAL = "Num .",
    NUMPADDIVIDE = "Num /",
    NUMPADMULTIPLY = "Num *",
    NUMPADMINUS = "Num -",
    NUMPADPLUS = "Num +",
}

-- Modifier keys (meta = Command on Mac)
CC.MODIFIERS = {
    "", -- No modifier
    "shift-",
    "ctrl-",
    "alt-",
    "meta-",
    "shift-ctrl-",
    "shift-alt-",
    "shift-meta-",
    "ctrl-alt-",
    "ctrl-meta-",
    "alt-meta-",
    "shift-ctrl-alt-",
    "shift-ctrl-meta-",
    "shift-alt-meta-",
    "ctrl-alt-meta-",
    "shift-ctrl-alt-meta-",
}

-- Action types
CC.ACTION_TYPES = {
    SPELL = "spell",
    MACRO = "macro",
    ITEM = "item",
    TARGET = "target",
    MENU = "menu",
    FOCUS = "focus",
    ASSIST = "assist",
}

-- Bind types
CC.BIND_TYPES = {
    MOUSE = "mouse",
    KEY = "key",
    SCROLL = "scroll",
}

-- ============================================================
-- SMART RESURRECTION DATA
-- ============================================================
-- Resurrection spells by class
-- normal = out of combat single target res
-- mass = out of combat mass res (retail only) - each class has unique name!
-- combat = in-combat battle res
-- Using spell IDs for reliable detection
CC.RESURRECTION_SPELLS = {
    ["DRUID"] = {
        normal = { name = "Revive", id = 50769 },
        mass = { name = "Revitalize", id = 212040 },  -- Druid-specific mass res
        combat = { name = "Rebirth", id = 20484 },
    },
    ["PALADIN"] = {
        normal = { name = "Redemption", id = 7328 },
        mass = { name = "Absolution", id = 212056 },  -- Paladin-specific mass res
        combat = { name = "Intercession", id = 391054 },
    },
    ["PRIEST"] = {
        normal = { name = "Resurrection", id = 2006 },
        mass = { name = "Mass Resurrection", id = 212036 },  -- Priest keeps the generic name
        combat = nil,
    },
    ["SHAMAN"] = {
        normal = { name = "Ancestral Spirit", id = 2008 },
        mass = { name = "Ancestral Vision", id = 212048 },  -- Shaman-specific mass res
        combat = nil,
    },
    ["MONK"] = {
        normal = { name = "Resuscitate", id = 115178 },
        mass = { name = "Reawaken", id = 212051 },  -- Monk-specific mass res
        combat = nil,
    },
    ["EVOKER"] = {
        normal = { name = "Return", id = 361227 },
        mass = { name = "Mass Return", id = 361178 },  -- Evoker-specific mass res
        combat = nil,
    },
    ["DEATHKNIGHT"] = {
        normal = nil,
        mass = nil,
        combat = { name = "Raise Ally", id = 61999 },
    },
    ["WARLOCK"] = {
        normal = nil,
        mass = nil,
        combat = { name = "Soulstone", id = 20707 },
    },
}

-- Spell IDs for all resurrection spells (used for locale-safe detection)
CC.RESURRECTION_SPELL_IDS = {}
for _, classData in pairs(CC.RESURRECTION_SPELLS) do
    for _, spellData in pairs(classData) do
        if type(spellData) == "table" and spellData.id then
            CC.RESURRECTION_SPELL_IDS[spellData.id] = true
        end
    end
end
-- Engineering items (spell IDs)
CC.RESURRECTION_SPELL_IDS[8342] = true   -- Goblin Jumper Cables
CC.RESURRECTION_SPELL_IDS[22999] = true  -- Goblin Jumper Cables XL
CC.RESURRECTION_SPELL_IDS[54732] = true  -- Gnomish Army Knife

-- Smart Resurrection mode options
CC.SMART_RES_MODES = {
    DISABLED = "disabled",
    NORMAL = "normal",           -- Normal + Mass res only
    NORMAL_COMBAT = "normal+combat",  -- Normal + Mass + Combat res
}

-- ============================================================
-- EQUIPMENT SLOT DATA
-- ============================================================
-- Equipment slots that commonly have on-use effects
CC.EQUIPMENT_SLOTS = {
    { slot = 13, name = "Trinket 1", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket" },
    { slot = 14, name = "Trinket 2", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket" },
    { slot = 1,  name = "Head", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Head" },
    { slot = 2,  name = "Neck", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Neck" },
    { slot = 10, name = "Hands", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Hands" },
    { slot = 6,  name = "Waist", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Waist" },
    { slot = 15, name = "Back", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest" },
    { slot = 16, name = "Main Hand", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-MainHand" },
    { slot = 17, name = "Off Hand", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-SecondaryHand" },
}

-- Common consumable items (can be expanded)
CC.COMMON_CONSUMABLES = {
    { itemId = 5512, name = "Healthstone" },
}

-- ============================================================
-- SAVED VARIABLES STRUCTURE
-- ============================================================

-- Default binding structure
local DEFAULT_BINDING = {
    enabled = true,
    bindType = "mouse", -- "mouse", "key", or "scroll"
    button = "LeftButton", -- For mouse bindings
    key = nil, -- For keyboard bindings (e.g., "F", "1", "F1") or scroll ("SCROLLUP", "SCROLLDOWN")
    modifiers = "", -- "shift-", "ctrl-", "alt-", or combinations
    actionType = "spell", -- "spell", "macro", "target", "menu"
    spellId = nil,
    spellName = nil,
    macroText = nil,
    targetType = "all", -- "all", "friendly", "hostile" - filter by target reaction
    -- Targeting fallbacks (all opt-in, default to off)
    fallback = {
        mouseover = false,
        target = false,
        selfCast = false,
        stopSpellTarget = false,
    },
    -- Load conditions
    loadSpec = nil, -- nil = all specs, or table of spec IDs
    loadCombat = nil, -- nil = always, "combat" = in combat only, "nocombat" = out of combat only
}
CC.DEFAULT_BINDING = DEFAULT_BINDING

-- Default saved variables
local DEFAULTS = {
    enabled = false,  -- Disabled by default, opt-in feature
    bindings = {},
    options = {
        castOnDown = true,  -- Cast on key down vs key up
        viewLayout = "grid",  -- "grid" or "list" layout for spell selection
        viewSort = "sectioned",  -- "sectioned" or "alphabetical" sorting
        quickBindEnabled = true,  -- Quick bind mode (instant binding on click)
        smartResurrection = "disabled",  -- "disabled", "normal", "normal+combat"
    },
}
CC.DEFAULTS = DEFAULTS

-- Profile system constants
local DB_VERSION = 2  -- Increment when DB structure changes
local DEFAULT_PROFILE_NAME = "Default"  -- Legacy name for migration
CC.DB_VERSION = DB_VERSION
CC.DEFAULT_PROFILE_NAME = DEFAULT_PROFILE_NAME

-- Get class-specific default profile name
local function GetDefaultProfileName()
    local _, className = UnitClass("player")
    if className then
        -- Capitalize first letter, lowercase rest
        local displayName = className:sub(1,1):upper() .. className:sub(2):lower()
        return displayName .. " Default"
    end
    return "Default"
end
CC.GetDefaultProfileName = GetDefaultProfileName

-- Check if a profile name is a default profile (current class default or legacy "Default")
local function IsDefaultProfile(profileName)
    if not profileName then return false end
    return profileName == GetDefaultProfileName() or profileName == "Default"
end
CC.IsDefaultProfile = IsDefaultProfile

-- Default profile template (what goes inside each profile)
local PROFILE_TEMPLATE = {
    bindings = {},
    customMacros = {},
    consumables = {},  -- Saved consumable item IDs
    options = {
        enabled = true,
        castOnDown = true,
        viewLayout = "grid",
        viewSort = "sectioned",
        quickBindEnabled = true,
        smartResurrection = "disabled",
    },
}
CC.PROFILE_TEMPLATE = PROFILE_TEMPLATE

-- Global settings template (shared across all profiles)
local GLOBAL_SETTINGS_TEMPLATE = {
    debugBindings = false,
    minimapIcon = { hide = false },
    autoCreateProfiles = true, -- Auto-create profiles when switching talent loadouts
    disableWhileMounted = false, -- Disable click casting while mounted
    -- UI positions can go here
}
CC.GLOBAL_SETTINGS_TEMPLATE = GLOBAL_SETTINGS_TEMPLATE

-- Default settings for new bindings
local DEFAULT_BINDING_SCOPE = "blizzard"  -- "unitframes", "blizzard", "onhover"
local DEFAULT_BINDING_COMBAT = "always"   -- "always", "incombat", "outofcombat"
local DEFAULT_TARGET_TYPE = "all"         -- "all", "friendly", "hostile"
CC.DEFAULT_BINDING_SCOPE = DEFAULT_BINDING_SCOPE
CC.DEFAULT_BINDING_COMBAT = DEFAULT_BINDING_COMBAT
CC.DEFAULT_TARGET_TYPE = DEFAULT_TARGET_TYPE

-- Target type descriptions for UI
local TARGET_INFO = {
    all = {
        name = "Any Target",
        desc = "Works on both friendly and hostile targets",
    },
    friendly = {
        name = "Friendly Only",
        desc = "Only works on friendly targets (party, raid, NPCs)",
    },
    hostile = {
        name = "Hostile Only",
        desc = "Only works on hostile/enemy targets",
    },
}
CC.TARGET_INFO = TARGET_INFO

-- Scope descriptions for UI (legacy, kept for migration)
local SCOPE_INFO = {
    unitframes = {
        name = "Unit Frames Only",
        desc = "Works only on party/raid frames (not Target, Focus, etc.)",
    },
    blizzard = {
        name = "Unit Frames + Blizzard",
        desc = "Also works on Target, Focus, Pet, Boss, Arena frames",
    },
    onhover = {
        name = "On Hover",
        desc = "Keyboard: global @mouseover bind. Mouse: works on all frames with @mouseover.",
    },
    targetcast = {
        name = "Target Cast",
        desc = "Casts on your current target (ignores mouseover). Like a normal keybind.",
    },
}
CC.SCOPE_INFO = SCOPE_INFO

-- Frame Application info (checkboxes - where does clicking work)
local FRAME_INFO = {
    dandersFrames = {
        name = "DandersFrames",
        desc = "Party and raid frames created by DandersFrames",
    },
    otherFrames = {
        name = "Other Frames",
        desc = "Player frame, target frame, focus frame, pet frame, boss frames, arena frames, and nameplates",
    },
}
CC.FRAME_INFO = FRAME_INFO

-- Targeting Fallback info (checkboxes - for keyboard/hover bindings)
local FALLBACK_INFO = {
    mouseover = {
        name = "Global",
        desc = "Cast on nameplates or characters in the world. Not needed for party/raid frames.",
    },
    target = {
        name = "Target",
        desc = "Cast on your current target if no frame or mouseover unit is found.",
    },
    selfCast = {
        name = "Self",
        desc = "Cast on yourself as a last resort if no other valid target is found.",
    },
    stopSpellTarget = {
        name = "Cancel Targeting",
        desc = "Adds /stopspelltarget to the macro which cancels the blue targeting hand after casting. Disable this for spells like Rescue that require a targeting phase to complete.",
    },
}
CC.FALLBACK_INFO = FALLBACK_INFO

-- Combat setting descriptions for UI
local COMBAT_INFO = {
    always = {
        name = "Always",
        desc = "Active in and out of combat",
    },
    incombat = {
        name = "In Combat Only",
        desc = "Only works while in combat",
    },
    outofcombat = {
        name = "Out of Combat Only",
        desc = "Only works outside of combat",
    },
}
CC.COMBAT_INFO = COMBAT_INFO

-- ============================================================
-- BLIZZARD FRAME LISTS (for global click-casting)
-- ============================================================

-- Static frames that always exist
local BLIZZARD_FRAMES = {
    "PlayerFrame",
    "TargetFrame",
    "TargetFrameToT",
    "FocusFrame",
    "FocusFrameToT",
    "PetFrame",
}
CC.BLIZZARD_FRAMES = BLIZZARD_FRAMES

-- Dynamic frames (boss encounters)
local BLIZZARD_BOSS_FRAMES = {
    "Boss1TargetFrame",
    "Boss2TargetFrame",
    "Boss3TargetFrame",
    "Boss4TargetFrame",
    "Boss5TargetFrame",
}
CC.BLIZZARD_BOSS_FRAMES = BLIZZARD_BOSS_FRAMES

-- Dynamic frames (arena)
local BLIZZARD_ARENA_FRAMES = {
    "ArenaEnemyFrame1",
    "ArenaEnemyFrame2",
    "ArenaEnemyFrame3",
    "ArenaEnemyFrame4",
    "ArenaEnemyFrame5",
}
CC.BLIZZARD_ARENA_FRAMES = BLIZZARD_ARENA_FRAMES

-- ============================================================
