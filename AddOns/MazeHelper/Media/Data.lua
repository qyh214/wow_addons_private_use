local ADDON_NAME, MazeHelper = ...;
MazeHelper.M = {};
local M = MazeHelper.M;

local MEDIA_PATH = 'Interface\\AddOns\\' .. ADDON_NAME .. '\\Media\\';

M.Path = MEDIA_PATH;

M.LOGO_MINI = MEDIA_PATH .. 'mh_logo_mini.blp'

M.INLINE_LEADER_ICON      = '|TInterface\\GroupFrame\\UI-Group-LeaderIcon:16|t';
M.INLINE_TANK_ICON        = _G.INLINE_TANK_ICON;
M.INLINE_HEALER_ICON      = _G.INLINE_HEALER_ICON;
M.INLINE_INFINITY_ICON    = '|T' .. MEDIA_PATH .. 'icons32.blp:14:14:0:0:128:128:64:96:32:64|t';
M.INLINE_ENTRANCE_ICON    = '|T' .. MEDIA_PATH .. 'icons32.blp:12:12:-1:1:128:128:96:128:32:64|t';
M.INLINE_NEW_ICON         = '|T' .. MEDIA_PATH .. 'icons32.blp:16:16:0:0:128:128:64:96:96:128|t ';
M.INLINE_EXCLAMATION_MARK = '|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t ';

M.BACKGROUND_WHITE = MEDIA_PATH .. 'background-white.blp';
M.SLIDER_BORDER    = MEDIA_PATH .. 'slider-border.blp';

M.MazeHelper = {
    TEXTURE = MEDIA_PATH .. 'mazehelper.blp', -- 128x64

    COORDS = {
        MAXI = {0, 1, 0, 1/4},
        MINI = {0, 1/4, 1/2, 2/2},
    },
};

M.INLINE_LOGO      = '|T' .. MEDIA_PATH .. 'mazehelper.blp:14:112:0:0:128:64:0:128:0:16|t';
M.INLINE_MINI_LOGO = '|T' .. MEDIA_PATH .. 'mazehelper.blp:16:16:0:-1:128:64:4:28:36:60|t';

M.Rings = {
    TEXTURE = MEDIA_PATH .. 'rings.blp', -- 256x256

    COORDS = {
        BLUE   = {  0, 1/2,   0, 1/2},
        GREEN  = {1/2, 2/2,   0, 1/2},
        VIOLET = {  0, 1/2, 1/2, 2/2},
    },
};

M.Icons = {
    TEXTURE = MEDIA_PATH .. 'icons32.blp', -- 128x128

    COORDS = {
        MEGAPHONE_WHITE  = {  0, 1/4,   0, 1/4},
        CROSS_WHITE      = {1/4, 2/4,   0, 1/4},
        LOCKED_WHITE     = {2/4, 3/4,   0, 1/4},
        GEAR_WHITE       = {3/4, 4/4,   0, 1/4},
        INFINITY_WHITE   = {2/4, 3/4, 1/4, 2/4},
        ENTRANCE         = {3/4, 4/4, 1/4, 2/4},
        MUSIC_NOTE       = {  0, 1/4, 2/4, 3/4},
        MAZE_BRAIN       = {1/4, 2/4, 2/4, 3/4},
        UNLOCKED_WHITE   = {2/4, 3/4, 2/4, 3/4},
        NEW              = {2/4, 3/4, 3/4, 4/4},
        ARROW_DOWN       = {3/4, 4/4, 2/4, 3/4},
        FULL_CIRCLE      = {3/4, 4/4, 3/4, 4/4},

        CHECKBUTTON_CHECKED = {  0, 1/4, 1/4, 2/4},
        CHECKBUTTON_NORMAL  = {1/4, 2/4, 1/4, 2/4},

        CIRCLE_NORMAL    = {  0, 1/4, 3/4 + 0.01, 4/4},
        CIRCLE_HIGHLIGHT = {1/4, 2/4, 3/4 + 0.01, 4/4},
    },
};

M.Symbols = {
    TEXTURE = MEDIA_PATH .. 'symbols.blp', -- 256x256

    COORDS_WHITE = {
        LEAF_CIRCLE_FILL     = {  0, 1/4,   0, 1/4},
        LEAF_CIRCLE_NOFILL   = {1/4, 2/4,   0, 1/4},
        LEAF_NOCIRCLE_FILL   = {  0, 1/4, 1/4, 2/4},
        LEAF_NOCIRCLE_NOFILL = {1/4, 2/4, 1/4, 2/4},

        FLOWER_CIRCLE_FILL     = {2/4, 3/4,   0, 1/4},
        FLOWER_CIRCLE_NOFILL   = {3/4,   1,   0, 1/4},
        FLOWER_NOCIRCLE_FILL   = {2/4, 3/4, 1/4, 2/4},
        FLOWER_NOCIRCLE_NOFILL = {3/4,   1, 1/4, 2/4},
    },

    COORDS_COLOR = {
        LEAF_CIRCLE_FILL     = {  0, 1/4, 2/4, 3/4},
        LEAF_CIRCLE_NOFILL   = {1/4, 2/4, 2/4, 3/4},
        LEAF_NOCIRCLE_FILL   = {  0, 1/4, 3/4, 4/4},
        LEAF_NOCIRCLE_NOFILL = {1/4, 2/4, 3/4, 4/4},

        FLOWER_CIRCLE_FILL     = {2/4, 3/4, 2/4, 3/4},
        FLOWER_CIRCLE_NOFILL   = {3/4, 4/4, 2/4, 3/4},
        FLOWER_NOCIRCLE_FILL   = {2/4, 3/4, 3/4, 4/4},
        FLOWER_NOCIRCLE_NOFILL = {3/4,   1, 3/4, 4/4},
    },
};

M.Sounds = {
    Notification = MEDIA_PATH .. 'notification.ogg',

    PracticeMode = {
        Success = {
            [1] = MEDIA_PATH .. 'success_1.ogg',
            [2] = MEDIA_PATH .. 'success_2.ogg',
        },

        Error   = {
            [1] = MEDIA_PATH .. 'error_1.ogg',
            [2] = MEDIA_PATH .. 'error_2.ogg',
        },
    },
};