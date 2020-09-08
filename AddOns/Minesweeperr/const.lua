local L = LibStub ("AceLocale-3.0"):GetLocale("Minesweeperr", true)
local MS = Minesweeperr
MS.Const = {}


MS.Const.VERSION = 110

MS.Const.autherGUID = {
    ["Player-846-0373DF63"] = true,
    ["Player-846-056DF6FF"] = true,
}

MS.Const.partyMembersTempl = {"player", "party1", "party2", "party3", "party4"}


MS.Const.classIdx = {
   [1] = "WARRIOR",
   [2] = "PALADIN",
   [3] = "HUNTER",
   [4] = "ROGUE",
   [5] = "PRIEST",
   [6] = "DEATHKNIGHT",
   [7] = "SHAMAN",
   [8] = "MAGE",
   [9] = "WARLOCK",
   [10] = "MONK",
   [11] = "DRUID",
   [12] = "DEMONHUNTER",
   [13] = "none"
}

MS.Const.dungeonIds = { 12749, 12752, 12763, 12768, 12773, 12776, 12779, 12745, 12782, 12785 }

MS.Const.dungeonNames = {
    L["D_AD"],
    L["D_FH"],
    L["D_KR"],
    L["D_SOTS"],
    L["D_SOB"],
    L["D_TOSL"],
    L["D_TML"],
    L["D_TUR"],
    L["D_TD"],
    L["D_WM"],
}

MS.Const.dungeonChallengeMapNames = {
    [244] = L["D_AD"],
    [245] = L["D_FH"],
    [246] = L["D_TD"],
    [247] = L["D_TML"],
    [248] = L["D_WM"],
    [249] = L["D_KR"],
    [250] = L["D_TOSL"],
    [251] = L["D_TUR"],
    [252] = L["D_SOTS"],
    [353] = L["D_SOB"],
    [370] = L["D_OPMW"],
    [369] = L["D_OPMJ"],
}


MS.Const.corruptionData = {
    ["6483"] = {spellID = 315607, name="Avoidant", level = "I", value = 8},
    ["6484"] = {spellID = 315608, name="Avoidant", level = "II", value = 12},
    ["6485"] = {spellID = 315609, name="Avoidant", level = "III", value = 16},
    ["6474"] = {spellID = 315544, name="Expedient", level = "I", value = 10},
    ["6475"] = {spellID = 315545, name="Expedient", level = "II", value = 15},
    ["6476"] = {spellID = 315546, name="Expedient", level = "III", value = 20},
    ["6471"] = {spellID = 315529, name="Masterful", level = "I", value = 10},
    ["6472"] = {spellID = 315530, name="Masterful", level = "II", value = 15},
    ["6473"] = {spellID = 315531, name="Masterful", level = "III", value = 20},
    ["6480"] = {spellID = 315554, name="Severe", level = "I", value = 10},
    ["6481"] = {spellID = 315557, name="Severe", level = "II", value = 15},
    ["6482"] = {spellID = 315558, name="Severe", level = "III", value = 20},
    ["6477"] = {spellID = 315549, name="Versatile", level = "I", value = 10},
    ["6478"] = {spellID = 315552, name="Versatile", level = "II", value = 15},
    ["6479"] = {spellID = 315553, name="Versatile", level = "III", value = 20},
    ["6493"] = {spellID = 315590, name="Siphoner", level = "I", value = 17},
    ["6494"] = {spellID = 315591, name="Siphoner", level = "II", value = 28},
    ["6495"] = {spellID = 315592, name="Siphoner", level = "III", value = 45},
    ["6437"] = {spellID = 315277, name="Strikethrough", level = "I", value = 10},
    ["6438"] = {spellID = 315281, name="Strikethrough", level = "II", value = 15},
    ["6439"] = {spellID = 315282, name="Strikethrough", level = "III", value = 20},
    ["6555"] = {spellID = 318266, name="Racing Pulse", level = "I", value = 15},
    ["6559"] = {spellID = 318492, name="Racing Pulse", level = "II", value = 20},
    ["6560"] = {spellID = 318496, name="Racing Pulse", level = "III", value = 35},
    ["6556"] = {spellID = 318268, name="Deadly Momentum", level = "I", value = 15},
    ["6561"] = {spellID = 318493, name="Deadly Momentum", level = "II", value = 20},
    ["6562"] = {spellID = 318497, name="Deadly Momentum", level = "III", value = 35},
    ["6558"] = {spellID = 318270, name="Surging Vitality", level = "I", value = 15},
    ["6565"] = {spellID = 318495, name="Surging Vitality", level = "II", value = 20},
    ["6566"] = {spellID = 318499, name="Surging Vitality", level = "III", value = 35},
    ["6557"] = {spellID = 318269, name="Honed Mind", level = "I", value = 15},
    ["6563"] = {spellID = 318494, name="Honed Mind", level = "II", value = 20},
    ["6564"] = {spellID = 318498, name="Honed Mind", level = "III", value = 35},
    ["6549"] = {spellID = 318280, name="Echoing Void", level = "I", value = 25},
    ["6550"] = {spellID = 318485, name="Echoing Void", level = "II", value = 35},
    ["6551"] = {spellID = 318486, name="Echoing Void", level = "III", value = 60},
    ["6552"] = {spellID = 318274, name="Infinite Stars", level = "I", value = 20},
    ["6553"] = {spellID = 318487, name="Infinite Stars", level = "II", value = 50},
    ["6554"] = {spellID = 318488, name="Infinite Stars", level = "III", value = 75},
    ["6547"] = {spellID = 318303, name="Ineffable Truth", level = "I", value = 12},
    ["6548"] = {spellID = 318484, name="Ineffable Truth", level = "II", value = 30},
    ["6537"] = {spellID = 318276, name="Twilight Devastation", level = "I", value = 25},
    ["6538"] = {spellID = 318477, name="Twilight Devastation", level = "II", value = 50},
    ["6539"] = {spellID = 318478, name="Twilight Devastation", level = "III", value = 75},
    ["6543"] = {spellID = 318481, name="Twisted Appendage", level = "I", value = 10},
    ["6544"] = {spellID = 318482, name="Twisted Appendage", level = "II", value = 35},
    ["6545"] = {spellID = 318483, name="Twisted Appendage", level = "III", value = 66},
    ["6540"] = {spellID = 318286, name="Void Ritual", level = "I", value = 15},
    ["6541"] = {spellID = 318479, name="Void Ritual", level = "II", value = 35},
    ["6542"] = {spellID = 318480, name="Void Ritual", level = "III", value = 66},
    ["6573"] = {spellID = 318272, name="Gushing Wound", level = "", value = 15},
    ["6546"] = {spellID = 318239, name="Glimpse of Clarity", level = "", value = 15},
    ["6571"] = {spellID = 318293, name="Searing Flames", level = "", value = 30},
    ["6572"] = {spellID = 316651, name="Obsidian Skin", level = "", value = 50},
    ["6567"] = {spellID = 318294, name="Devour Vitality", level = "", value = 35},
    ["6568"] = {spellID = 316780, name="Whispered Truths", level = "", value = 25},
    ["6570"] = {spellID = 318299, name="Flash of Insight", level = "", value = 20},
    ["6569"] = {spellID = 317290, name="Lash of the Void", level = "", value = 25},
}

MS.Const.essenceTextureIDs = {
    [2967101] = true,
    [3193842] = true,
    [3193843] = true,
    [3193844] = true,
    [3193845] = true,
    [3193846] = true,
    [3193847] = true,
}

MS.Const.gemSlots = {
    EMPTY_SOCKET = true,
    EMPTY_SOCKET_BLUE = true,
    EMPTY_SOCKET_COGWHEEL = true,
    EMPTY_SOCKET_HYDRAULIC = true,
    EMPTY_SOCKET_META = true,
    EMPTY_SOCKET_NO_COLOR = true,
    EMPTY_SOCKET_PRISMATIC = true,
    EMPTY_SOCKET_RED = true,
    EMPTY_SOCKET_YELLOW = true,
    EMPTY_SOCKET_PUNCHCARDYELLOW = false,
    EMPTY_SOCKET_PUNCHCARDRED = false,
    EMPTY_SOCKET_PUNCHCARDBLUE = false,
}


-- 1 人类 2%全属性
-- 10 血精灵 1%暴击
-- 4 暗夜精灵 夜间1%急速 白天1%暴击
-- 22 狼人 1%暴击
-- 9 地精1%急速
-- 28 至高牛头 1%全能
-- 7 侏儒 1%急速
-- 32 库尔提拉斯 1%全能

MS.Const.raceAttributeFactor = {
    [1] = {["C"] = 1.02, ["H"] = 1.02, ["M"] = 1.02, ["V"] = 1.02,},
    [10] = {["C"] = 0.01, ["H"] = 0, ["M"] = 0, ["V"] = 0,},
    [4] = {["C"] = 0.01, ["H"] = 0.01, ["M"] = 0, ["V"] = 0,},
    [22] = {["C"] = 0.01, ["H"] = 0, ["M"] = 0, ["V"] = 0,},
    [9] = {["C"] = 0, ["H"] = 0.01, ["M"] = 0, ["V"] = 0,},
    [28] = {["C"] = 0, ["H"] = 0, ["M"] = 0, ["V"] = 0.01,},
    [7] = {["C"] = 0, ["H"] = 0.01, ["M"] = 0, ["V"] = 0,},
    [32] = {["C"] = 0, ["H"] = 0, ["M"] = 0, ["V"] = 0.01,},
}

-- 防护 C5% M12%
-- 武器 C5% M90%
-- 狂暴 C5% M11%

-- 兽王 C10% M15%
-- 射击 C10% M5%
-- 生存 C10% M16%

-- 刺杀 C10% M14%
-- 狂徒 C10% M10%
-- 敏锐 C10% M20%

-- 戒律 C5% M10%
-- 神圣 C5% M10%
-- 暗影 C5% M10%

-- 鲜血 C5% M16%
-- 冰霜 C5% M16%
-- 邪恶 C5% M18%

-- 元素 C5% M15%
-- 增强 C10% M16%
-- 恢复 C5% M24%

-- 奥术 C5% M10%
-- 火焰 C5% M6%
-- 冰霜法 C5% M8%

-- 平衡 C5% M12%
-- 野性 C10% M16%
-- 守护 C10% M4%
-- 恢复 C5% M4%

-- 浩劫 C10% M14%
-- 复仇 C10% M20%


MS.Const.attributeBasic = {
    [1] = {
        [71] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 12,
            ["V"] = 0,
        },
        [72] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 90,
            ["V"] = 0,
        },
        [73] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 11,
            ["V"] = 0,
        },
    }, 
    [2] = {
        [65] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 12,
            ["V"] = 0,
        },
        [66] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 8,
            ["V"] = 0,
        },
        [70] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 13,
            ["V"] = 0,
        },
    },
    [3] = {
        [253] = {
            ["C"] = 10,
            ["H"] = 0,
            ["M"] = 15,
            ["V"] = 0,
        },
        [254] = {
            ["C"] = 10,
            ["H"] = 68,
            ["M"] = 5,
            ["V"] = 0,
        },
        [255] = {
            ["C"] = 10,
            ["H"] = 68,
            ["M"] = 16,
            ["V"] = 0,
        },
    },
    [4] = {
        [259] = {
            ["C"] = 10,
            ["H"] = 0,
            ["M"] = 14,
            ["V"] = 0,
        },
        [260] = {
            ["C"] = 10,
            ["H"] = 0,
            ["M"] = 10,
            ["V"] = 0,
        },
        [261] = {
            ["C"] = 10,
            ["H"] = 0,
            ["M"] = 20,
            ["V"] = 0,
        },
    },
    [5] = {
        [256] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 10,
            ["V"] = 0,
        },
        [257] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 10,
            ["V"] = 0,
        },
        [258] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 10,
            ["V"] = 0,
        },
    },
    [6] = {
        [250] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 16,
            ["V"] = 0,
        },
        [251] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 16,
            ["V"] = 0,
        },
        [252] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 18,
            ["V"] = 0,
        },
    },
    [7] = {
        [262] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 15,
            ["V"] = 0,
        },
        [263] = {
            ["C"] = 10,
            ["H"] = 0,
            ["M"] = 16,
            ["V"] = 0,
        },
        [264] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 24,
            ["V"] = 0,
        },
    },
    [8] = {
        [62] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 10,
            ["V"] = 0,
        },
        [63] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 6,
            ["V"] = 0,
        },
        [64] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 8,
            ["V"] = 0,
        },
    },
    [9] = {
        [265] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 20,
            ["V"] = 0,
        },
        [266] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 16,
            ["V"] = 0,
        },
        [267] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 11.6,
            ["V"] = 0,
        },
    },
    [10] = {
        [268] = {
            ["C"] = 10,
            ["H"] = 0,
            ["M"] = 8,
            ["V"] = 0,
        },
        [269] = {
            ["C"] = 10,
            ["H"] = 0,
            ["M"] = 10,
            ["V"] = 0,
        },
        [270] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 24,
            ["V"] = 0,
        },
    },
    [11] = {
        [102] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 12,
            ["V"] = 0,
        },
        [103] = {
            ["C"] = 10,
            ["H"] = 0,
            ["M"] = 16,
            ["V"] = 0,
        },
        [104] = {
            ["C"] = 10,
            ["H"] = 0,
            ["M"] = 4,
            ["V"] = 0,
        },
        [105] = {
            ["C"] = 5,
            ["H"] = 0,
            ["M"] = 4,
            ["V"] = 0,
        },
    },
    [12] = {
        [577] = {
            ["C"] = 10,
            ["H"] = 0,
            ["M"] = 14,
            ["V"] = 0,
        },
        [581] = {
            ["C"] = 72,
            ["H"] = 0,
            ["M"] = 20,
            ["V"] = 0,
        },
    },
}


MS.Const.attributePersentBase = {
    [1] = {
        [71] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 48,
            ["V"] = 85,
        },
        [72] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 6.43,
            ["V"] = 85,
        },
        [73] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 50.88,
            ["V"] = 85,
        },
    }, 
    [2] = {
        [65] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 48,
            ["V"] = 85,
        },
        [66] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 72,
            ["V"] = 85,
        },
        [70] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 45,
            ["V"] = 85,
        },
    },
    [3] = {
        [253] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 37.89,
            ["V"] = 85,
        },
        [254] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 115.2,
            ["V"] = 85,
        },
        [255] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 36,
            ["V"] = 85,
        },
    },
    [4] = {
        [259] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 42.33,
            ["V"] = 85,
        },
        [260] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 55.38,
            ["V"] = 85,
        },
        [261] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 29.38,
            ["V"] = 85,
        },
    },
    [5] = {
        [256] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 60,
            ["V"] = 85,
        },
        [257] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 60,
            ["V"] = 85,
        },
        [258] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 60,
            ["V"] = 85,
        },
    },
    [6] = {
        [250] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 36,
            ["V"] = 85,
        },
        [251] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 36,
            ["V"] = 85,
        },
        [252] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 32,
            ["V"] = 85,
        },
    },
    [7] = {
        [262] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 38.39,
            ["V"] = 85,
        },
        [263] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 36,
            ["V"] = 85,
        },
        [264] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 24,
            ["V"] = 85,
        },
    },
    [8] = {
        [62] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 62,
            ["V"] = 85,
        },
        [63] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 96,
            ["V"] = 85,
        },
        [64] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 72,
            ["V"] = 85,
        },
    },
    [9] = {
        [265] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 28.8,
            ["V"] = 84.9,
        },
        [266] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 72,
            ["V"] = 85,
        },
        [267] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 49.7,
            ["V"] = 84.9,
        },
    },
    [10] = {
        [268] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 72,
            ["V"] = 85,
        },
        [269] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 58,
            ["V"] = 85,
        },
        [270] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 24,
            ["V"] = 85,
        },
    },
    [11] = {
        [102] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 48,
            ["V"] = 85,
        },
        [103] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 36,
            ["V"] = 85,
        },
        [104] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 143.94,
            ["V"] = 85,
        },
        [105] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 122.4,
            ["V"] = 85,
        },
    },
    [12] = {
        [577] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 39.1,
            ["V"] = 85,
        },
        [581] = {
            ["C"] = 72,
            ["H"] = 68,
            ["M"] = 28.8,
            ["V"] = 85,
        },
    },
}


MS.Const.darkHeartValue = {
    [430] = 72,
    [435] = 74,
    [440] = 75,
    [445] = 76,
    [450] = 77,
    [455] = 79,
    [460] = 80,
    [465] = 81,
    [470] = 82,
    [475] = 84,
    [480] = 85,
    [485] = 86,
    [490] = 87,
}


MS.Const.endlessHungerValue = {
    [430] = 325,
    [435] = 330,
    [440] = 336,
    [445] = 342,
    [450] = 347,
    [455] = 353,
    [460] = 358,
    [465] = 364,
    [470] = 369,
    [475] = 375,
    [480] = 381,
    [485] = 386,
    [490] = 392,
}

MS.Const.bloodSiphonValue = {
    [430] = 93,
    [435] = 94,
    [440] = 96,
    [445] = 98,
    [450] = 99,
    [455] = 101,
    [460] = 102,
    [465] = 104,
    [470] = 106,
    [475] = 107,
    [480] = 109,
    [485] = 110,
    [490] = 112,
}

MS.Const.onMyWayValue = {
    [430] = 93,
    [435] = 94,
    [440] = 96,
    [445] = 98,
    [450] = 99,
    [455] = 101,
    [460] = 102,
    [465] = 104,
    [470] = 106,
    [475] = 107,
    [480] = 109,
    [485] = 110,
    [490] = 112,
}

MS.Const.lifeSpeedValue = {
    [430] = 93,
    [435] = 94,
    [440] = 96,
    [445] = 98,
    [450] = 99,
    [455] = 101,
    [460] = 102,
    [465] = 104,
    [470] = 106,
    [475] = 107,
    [480] = 109,
    [485] = 110,
    [490] = 112,
}