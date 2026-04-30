local addonName, addonTable = ...
local frame = CreateFrame("Frame")

-- 1. 先声明变量（但不赋值）
local MEDIA_PATH

local RING_PATH = "Interface\\AddOns\\DiGuaTimelineAudioHelper\\Ring_20px.tga"
local PLAYER_LEVEL = UnitLevel("player")
local NEXT_PLAYER_LEVEL = PLAYER_LEVEL + 1
local UNIT_CAST_TRACKER = {}
local unitCastTracker = {}
local auraTriggeredCache = {}
local UNIT_SUCCEEDED_AND_INTERRUPTED_TRACKER = {}
local hasPlayedSiJiaoTingYuan = false
local encounterUnitTriggerCount = 0
local UNIT_CAST_TIMER_HANDLES = {} -- 用于存储定时器句柄
local UNIT_START_TIMES = {} -- 记录每个怪第一次进入逻辑的时间
local UNIT_CHANNEL_TRACKER = {} -- 专门记录引导状态的表
-- 在文件头部定义一些常量
local RING_COLOR_NORMAL = {0.4, 1, 0.8, 0.85}
local RING_COLOR_ALARM = {1, 0.2, 0.2, 0.9} -- 红色警示
local TargetEndTime = 0 -- 记录当前圆环预计结束的时间点
local CurrentRingIsCastSensitive = false -- 新增：记录当前圆环是否受施法控制
local Lindormi = false
-- 1. 定义三个公共变量（在文件顶部定义）
local ttsStartTime = 0          -- 记录开始时间
local ttsEndTime = 0            -- 记录结束时间
local ttsDuration = 0           -- 记录时间差（持续时长）
local MyTTSDict = {
    skill1Time = 0,
    skill2Time = 0,
    tolerance = 0.05,
    isSampled = false, -- 标记是否正在初始化采样
    sampleIndex = 0,     -- 追踪当前执行到第几个技能
    -- isListening = false, -- 公共布尔变量
}
local BOSS_KILL_3072 = false
-- local modelFrame = CreateFrame("PlayerModel")
local AudioTimeline = {
    [1698] = {
        interval = 40, 
        startOffset = 4, 
        alerts = {
            [0]  = "ZhunBeiDianMing.ogg",
            -- [6]  = { file = "ZhiLiaoYuPu.ogg", role = "HEALER" },
            [8]  = "ZhunBeiAOE.ogg",
            -- [10] = "LiuXue.ogg",
            [14] = "ZhunBeiHuiXuanBiao.ogg",
            [19] = "FeiBiaoFanHui.ogg",
            [24] = "ZhunBeiHuiXuanBiao.ogg",
            [29] = "FeiBiaoFanHui.ogg",
            -- [26] = { file = "ZhiLiaoYuPu.ogg", role = "HEALER" },
            [28] = "ZhunBeiAOE.ogg",
            [31] = "ZhunBeiDuoFeng.ogg",
        }
    },
    [1699] = {
        interval = 9999, 
        startOffset = 5, 
        alerts = {
            -- [0]  = "ZhuYiTouQian.ogg",
            -- [3]  = "小怪激活.ogg",
            -- [10] = "ZhuYiTouQian.ogg",
            -- [15] = "ZhuYiTouQian.ogg",
            [23] = "ZhuYiJiaoXia.ogg",
            -- [25] = "小怪激活.ogg",
            -- [30] = "ZhuYiTouQian.ogg",
            -- [35] = "ZhuYiTouQian.ogg",
            [44] = "ZhuYiJiaoXia.ogg",
            -- [41] = "ZhunBeiAOE.ogg",
        }
    },
    [1700] = {
        interval = 47, 
        startOffset = 5, 
        alerts = {
            [0]  = { file = "ZhuYiJianShang.ogg", role = "TANK" }, 
            [1]  = { file = "ZhuYiShuaTan.ogg", role = "HEALER" }, 
            [7]  = "ZhaoHuanXiaoGuai.ogg",
            [10] = { file = "ZhuanHuoXiaoGuai.ogg", role = {"TANK", "DAMAGER"} },
            [11] = { file = "ZhuYiShuaTan.ogg", role = "HEALER" }, 
            [12] = { file = "ZhuYiJianShang.ogg", role = "TANK" }, 
            [28] = "ZhaoHuanXiaoGuai.ogg",
            [31] = { file = "ZhuanHuoXiaoGuai.ogg", role = {"TANK", "DAMAGER"} },
            [33] = "KuaiZhaoYanTi.ogg",
            [41] = "San.ogg",
            [42] = "Er.ogg",
            [43] = "Yi.ogg",
            [44] = "AnQuanAnQuan.ogg",
        }
    },
    [1701] = {
        interval = 39, 
        startOffset = 5, 
        alerts = {
            -- [1] =  { file = "ZhuYiDanShua.ogg", role = "HEALER" }, 
            [3] =  { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            [10] = { file = "ZhuanHuoXiaoGuai.ogg", role = {"TANK", "DAMAGER"} },
            -- [11] = { file = "ZhuYiDanShua.ogg", role = "HEALER" }, 
            [15] = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            -- [21] = { file = "ZhuYiDanShua.ogg", role = "HEALER" }, 
            [24] = "ZhunBeiJiGuang.ogg",
        }
    },
    [1999] = { -- 熔炉之主加弗斯特
        interval = 41, 
        startOffset = 4, 
        alerts = {
            [0] =  "ZhunBeiDianMing.ogg",
            [20] = "ZhuYiDuoQuan.ogg",
            -- [29] = "KuaiZhaoYanTi.ogg",
            [36] = "KuaiKaiJianShang.ogg",
            [39] = "ZhuYiDuoQuan.ogg",
            [40] = { file = "QuSanDuiYou.ogg", role = "HEALER" }, 
        }
    },
    [2001] = { -- 伊克和科瑞克
        interval = 83, 
        startOffset = 1, 
        alerts = {
            [0] =  "KuaiKaiJianShang.ogg",
            [4] =  "ZhunBeiZuZhou.ogg",
            [6] =  { file = "ZhuanHuoXiaoGuai.ogg", role = {"TANK", "DAMAGER"} },
            [7] =  { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            [10] = { file = "TanKeJianShang.ogg", role = {"TANK", "HEALER"} },
            [20] = "ZhunBeiAOE.ogg",
            [22] = "ZhuYiDuoQuan.ogg",
            [24] = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            [29] = { file = "TanKeJianShang.ogg", role = {"TANK", "HEALER"} },
            [39] = "ZhunBeiAOE.ogg",
            [41] = "ZhuYiDuoQuan.ogg",
            [49] = "ZhunBeiZhuiRen.ogg",
        }
    },
    [2000] = { -- 天灾领主泰兰努斯
        interval = 85, 
        startOffset = 0, 
        alerts = {
            [0] =  "ZhunBeiAOE.ogg",
            [4] =  "ZhunBeiDianMing.ogg",
            [14] = { file = "XiaoXinJiTui.ogg", role = "TANK" }, 
            [17] = "DuoKaiDaQuan.ogg",
            [24] = "ZhuYiDuoQuan.ogg",
            [33] = "ZhunBeiDianMing.ogg",
            [41] = { file = "XiaoXinJiTui.ogg", role = "TANK" }, 
            [44] = "DuoKaiDaQuan.ogg",
            [52] = "ZhunBeiXiaoGuai.ogg",
            [54] = "San.ogg",
            [55] = "Er.ogg",
            [56] = "Yi.ogg",
            [57] = { file = "JiHuoDaGuai.ogg", role = {"TANK", "DAMAGER"} },
            [58] = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            [60] = { file = "KuaiKaiJianShang.ogg", role = {"HEALER", "DAMAGER"} },
            [67] = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            [69] = "ZhuYiDuoQuan.ogg",
        }
    },
    [2065] = { -- 晋升者祖拉尔
        interval = 54, 
        startOffset = 0, 
        alerts = {
            -- [2] = { file = "ZhuYiJianShang.ogg", role = "TANK" }, 
            -- [3] = { file = "ZhuYiShuaTan.ogg", role = "HEALER" }, 
            -- [7] =  "TieBianFangShui.ogg",
            -- [16] = "DuoKaiZhengMian.ogg",
            -- [22] = { file = "MeiYouYinPin.ogg", duration = 3 },
            [27] = { file = "ZhuanHuoXiaoGuai.ogg", role = {"TANK", "DAMAGER"} },
            -- [33] = "TieBianFangShui.ogg",
            -- [35] = { file = "ZhuYiJianShang.ogg", role = "TANK" }, 
            -- [36] = { file = "ZhuYiShuaTan.ogg", role = "HEALER" }, 
            -- [45] = { file = "MeiYouYinPin.ogg", duration = 5 },
            [52] = "XiaoXinJiTui.ogg",
        }
    },
    [2066] = { -- 萨普瑞什
        interval = 38, 
        startOffset = 0, 
        alerts = {
            -- [6] = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            -- [7] =  "ZhuYiDuoQuan.ogg",
            -- [8] = { file = "DanShuaLiuXue.ogg", role = "HEALER" }, 
            -- [16] = "ZhuYiDuoQuan.ogg",
            -- [19] = { file = "DanShuaLiuXue.ogg", role = "HEALER" }, 
            [20] = "QuanZhuXiaoQiu.ogg",
            -- [21] = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            [32] = "ZhunBeiAOE.ogg",
        }        
    },
    [2067] = { -- 总督奈扎尔
        interval = 65, 
        startOffset = 0, 
        alerts = {
            -- [4]  = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            -- [6]  = "ZhunBeiDuoQiu.ogg",
            -- [8]  = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            -- [10] = "ZhuYiDuoQiu.ogg",
            -- [12] = { file = "ZhunBeiAOE.ogg", role = "HEALER" }, 
            -- [20] = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            -- [22] = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            -- [24] = "ZhunBeiDuoQiu.ogg",
            -- [26] = { file = "ZhunBeiAOE.ogg", role = "HEALER" },
            -- [28] = "ZhuYiDuoQiu.ogg",
            -- [30] = { file = "KongShaXiaoGuai.ogg", role = {"TANK", "DAMAGER"} },
            -- [36] = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            -- [42] = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            [45] = "XiaoXinJiFei.ogg",
            [48] = "KaoJinZhongChang.ogg",
            [52] = { file = "ZhiLiaoYuPu.ogg", role = "HEALER" }, 
            [56] = { file = "KuaiKaiJianShang.ogg", role = {"TANK", "DAMAGER"} },
            [57] = { file = "DaZhaoTaiXue.ogg", role = "HEALER" }, 
        }        
    },
    [2068] = { -- 鲁拉
        interval = 9999, 
        startOffset = 0, 
        alerts = {
            -- [0]  = { file = "BieKaiBaoFa.ogg", role = "DAMAGER" }, 
            -- [2]  = "ZhunBeiAOE.ogg",
            -- [12] = "ZhuYiSheXian.ogg",
            [13] = { file = "TanKeJianCi.ogg", role = "TANK" }, 
            [15] = "ZhuYiZiBao.ogg",
            [17] = "San.ogg",
            [18] = "Er.ogg",
            [19] = "Yi.ogg",
            [20] = "AnQuanAnQuan.ogg",
            -- [22] = "ZhunBeiDianMing.ogg",
            [29] = { file = "TanKeJianCi.ogg", role = "TANK" }, 
            -- [35] = "DuoKaiDaQuan.ogg",
            -- [45] = "ZhuYiSheXian.ogg",
            [45] = { file = "TanKeJianCi.ogg", role = "TANK" }, 
            [50] = "San.ogg",
            [51] = "Er.ogg",
            [52] = "Yi.ogg",
            [53] = "AnQuanAnQuan.ogg",
            -- [55] = "ZhunBeiDianMing.ogg",
            -- [66] = "ZhunBeiYiShang.ogg",
            -- [75] = "YiShangJieDuan.ogg",
            -- [91] = "ZhunBeiJiTui.ogg",
            -- [93] = "San.ogg",
            -- [94] = "Er.ogg",
            -- [95] = "Yi.ogg",
            -- [96] = "YiShangJieShu.ogg",
        }        
    },
    [2562] = {
        interval = 44, 
        startOffset = 2, 
        alerts = {
            -- [0]  = "ZhunBeiChiQiu.ogg",
            [0]  = "ZhunBeiChiQiu.ogg",
            [3]  = "TanKeTouQian.ogg",
            [13] = "ZhunBeiFangShui.ogg",
            [18] = "ZhunBeiChiQiu.ogg",
            [21] = "TanKeTouQian.ogg",
            [31] = "ZhunBeiFangShui.ogg",
            [38] = { file = "ZhunBeiJiTui.ogg", duration = 3 },
            [41] = "ZhuYiJiaoXia.ogg",
        }
    },
    [2563] = { -- 茂林古树
        interval = 57, 
        startOffset = 9, 
        alerts = {
            -- [0]  = { file = "TanKeJianShang.ogg", role = {"TANK", "HEALER"} },
            -- [9]  = "ZhuYiJiaoXia.ogg",
            -- [21] = { file = "ZhunBeiDaGuai.ogg", role = {"TANK", "DAMAGER"} },
            [21] = { file = "ZhuYiShuaXue.ogg", role = "HEALER" }, 
            -- [23] = { file = "ZhuanHuoDaGuai.ogg", role = {"TANK", "DAMAGER"} },
            -- [28] = { file = "TanKeJianShang.ogg", role = {"TANK", "HEALER"} },
            -- [30] = { file = "DaDuanDaGuai.ogg", role = {"TANK", "DAMAGER"} },
            -- [42] = "ZhuYiJiaoXia.ogg",
            -- [46] = "ZhunBeiAOE.ogg",
        }
    },
    [2564] = {
        interval = 24, 
        startOffset = 5, 
        alerts = {
            [0]  = { file = "ZhuYiJianShang.ogg", role = "TANK" },
            [1]  = { file = "ZhuYiShuaTan.ogg", role = "HEALER" },
            [9]  = { file = "TingZhiShiFa.ogg" },
            -- [10] = { file = "Er.ogg" },
            -- [11] = { file = "Yi.ogg" },
            [15] = "DuoKaiZhengMian.ogg",
        },
        -- 新增：事件触发配置
        eventAlerts = {
            -- 触发此事件时：播音，并彻底停掉计时器
            ["CLEAR_BOSS_EMOTES"] = { file = "KaiShiYunQiu.ogg", action = "STOP" },             
            -- 触发此事件时：播音，并重头开始计时
            ["ENCOUNTER_TIMELINE_EVENT_ADDED"] = { file = "MeiYouYinPin.ogg", action = "START" },
        }
    },
    [2565] = {
        interval = 33, 
        startOffset = 0, 
        alerts = {
            [9]  = { file = "TanKeJianShang.ogg", role = "TANK" },
            [14] = { file = "ZhunBeiDianMing.ogg", role = {"DAMAGER", "HEALER"} },
            [17] = { file = "ZhuYiQuSan.ogg", role = "HEALER" }, 
            [21] = { file = "TanKeJianShang.ogg", role = "TANK" },
            [24] = "ZhunBeiLaRen.ogg",
            [25] = "San.ogg",
            [26] = "Er.ogg",
            [27] = "Yi.ogg",
            [30] = "DuoKaiDaQuan.ogg",
        }
    },
    [3056] = {
        interval = 9999, -- 40?
        startOffset = 0, 
        alerts = {
            -- [5]  = "ZhunBeiDianMing.ogg",
            -- [11] = { file = "ZhuYiJianShang.ogg", role = "TANK" },
            -- [12] = { file = "ZhuYiShuaTan.ogg", role = "HEALER" },
            -- [16] = "ZhunBeiChuiFeng.ogg",
            -- [19] = "NiShiZhenTouQian.ogg",
            [22] = { file = "KuaiKaiJianShang.ogg", role = "DAMAGER" }, 
            -- [34] = "San.ogg",
            -- [35] = "Er.ogg",
            -- [36] = "Yi.ogg",
            -- [37] = "ChuiFengJieShu.ogg",
        },
        -- eventAlerts = {
        --     ["RAID_BOSS_WHISPER"] = { file = "TieBianFangShuiSanMiaoSanErYi.ogg", action = "STOP" },       
        -- }
    },
    [3057] = { -- 被遗弃的二人组
        interval = 9999, 
        startOffset = 0, 
        alerts = {
            [2]  = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
            -- [8]  = { file = "MeiYouYinPin.ogg", duration = 4.3 },
            -- [16] = { file = "ZhuYiJianShang.ogg", role = "TANK" },
            -- [17] = { file = "ZhuYiShuaTan.ogg", role = "HEALER" },
            [20] = { file = "ZhunBeiZuZhou.ogg", role = {"HEALER", "DAMAGER"} },
            -- [35] = { file = "MeiYouYinPin.ogg", duration = 4.2 },
            -- [37] = { file = "KuaiKaiJianShang.ogg", role = "DAMAGER"},           
            -- [46] = "ZhunBeiDianMing.ogg",
            -- [48] = { file = "ZhiLiaoYuPu.ogg", role = "HEALER" },
        }
    },
    [3058] = {
        interval = 9999, 
        startOffset = 0, 
        alerts = {
            -- [3]  = { file = "ZhuYiJianShang.ogg", role = "TANK" },
            [5]  = { file = "ZhuYiShuaTan.ogg", role = "HEALER" },
            -- [14] = "ZhuYiDuoQuan.ogg",
            -- [18] = "KaoJinDuiYou.ogg",
            -- [30] = { file = "ZhuYiJianShang.ogg", role = "TANK" },
            -- [31] = { file = "ZhuYiShuaTan.ogg", role = "HEALER" },
            -- [45] = "KaoJinDuiYou.ogg",
            -- [54] = { file = "ZhuYiJianShang.ogg", role = "TANK" },
            -- [55] = { file = "ZhuYiShuaTan.ogg", role = "HEALER" },
            -- [69] = "KaoJinDuiYou.ogg",
            -- [75] = "ZhunBeiAOE.ogg",
            -- [83] = { file = "DaDuanDuTiao.ogg", role = {"TANK", "DAMAGER"} },
        },
        -- eventAlerts = {
        --     ["ENCOUNTER_TIMELINE_EVENT_BLOCK_STATE_CHANGED"] = { file = "XiaoGuaiKuaiDa.ogg", action = "STOP" },       
        -- }
    },
    [3059] = {
        interval = 9999, 
        startOffset = 0, 
        alerts = {
            -- [9]  = "ZhuYiDuoQuan.ogg",
            -- [15] = { file = "CaiQuanXiaoCeng.ogg", role = {"HEALER", "DAMAGER"} },
            -- [21] = "ZhunBeiAOE.ogg",
            [25] = "ZhunBeiCaiQuan.ogg",
            [29] = "SanErYiCaiQuanShangTian.ogg",
            -- [30] = "Er.ogg",
            -- [31] = "Yi.ogg",
            -- [32] = "CaiQuanShangTian.ogg",
            -- [47] = "ZhuYiDuoQuan.ogg",
            -- [53] = { file = "CaiQuanXiaoCeng.ogg", role = {"HEALER", "DAMAGER"} },
            -- [57] = { file = "XiaoXinJiTui.ogg", role = "TANK" },
            -- [73] = "ZhunBeiJianYu.ogg",
            -- [87] = "ZhunBeiAOE.ogg",
            [91] = "ZhunBeiCaiQuan.ogg",
            [95] = "SanErYiCaiQuanShangTian.ogg",
            -- [96] = "Er.ogg",
            -- [97] = "Yi.ogg",
            -- [98] = "CaiQuanShangTian.ogg",
            -- [112]= "ZhuYiDuoQuan.ogg",
            -- [118]= { file = "CaiQuanXiaoCeng.ogg", role = {"HEALER", "DAMAGER"} },
            -- [122]= { file = "XiaoXinJiTui.ogg", role = "TANK" },
            -- [138]= "ZhunBeiJianYu.ogg",
            -- [151]= "ZhunBeiAOE.ogg",
            [155]= "ZhunBeiCaiQuan.ogg",
            [159]= "SanErYiCaiQuanShangTian.ogg",
            -- [160]= "Er.ogg",
            -- [161]= "Yi.ogg",
            -- [162]= "CaiQuanShangTian.ogg",
            -- [177]= "ZhuYiDuoQuan.ogg",
            -- [183]= { file = "CaiQuanXiaoCeng.ogg", role = {"HEALER", "DAMAGER"} },
            -- [187]= { file = "XiaoXinJiTui.ogg", role = "TANK" },
        }
    },
    [3071] = {
        interval = 69, 
        startOffset = 0, 
        alerts = {
            [5]  = { file = "TanKeJiTui.ogg", role = {"HEALER", "TANK"} },
            -- [16] = { file = "XiaoXinJiTui.ogg", duration = 2.9 },
            [20] = "ZhunBeiDianMing.ogg",
            [24] = { file = "QuSanMoFa.ogg", role = "HEALER" },
            [28] = { file = "TanKeJiTui.ogg", role = {"HEALER", "TANK"} },
            -- [39] = { file = "XiaoXinJiTui.ogg", duration = 2.9 },
            [46] = "ZhunBeiChiQiu.ogg",
            [49] = "YiShangJieDuan.ogg",
            [64] = "San.ogg",
            [65] = "Er.ogg",
            [66] = "Yi.ogg",
            [67] = "YiShangJieShu.ogg",
        }
    },
    [3072] = { -- 瑟拉奈尔·日鞭
        interval = 57, 
        startOffset = 0, 
        alerts = {
            [7]  = "ZhunBeiDianMing.ogg",
            [18] = "DuoKaiDaQuan.ogg",
            [20] = { file = "ZhiLiaoYuPu.ogg", role = "HEALER" },
            [22] = "ZhuYiDuoQuan.ogg",
            [26] = "ZhuYiDuoQuan.ogg",
            [27] = { file = "ZhuYiJianShang.ogg", role = "TANK" },
            -- [30] = "JinGongQuSanMoFa.ogg",            
            [36] = "ZhunBeiDianMing.ogg",
            [38] = { file = "ZhiLiaoYuPu.ogg", role = "HEALER" },
            [40] = "ZhuYiDuoQuan.ogg",
            [44] = "ZhuYiDuoQuan.ogg",
            -- [51] = { file = "MeiYouYinPin.ogg", duration = 4.9 }
            -- [52] = "Si.ogg",
            -- [53] = "San.ogg",
            -- [54] = "Er.ogg",
            -- [55] = "Yi.ogg",
            -- [56] = "Jin.ogg",
        }
    },
    -- [3073] = {
    --     interval = 9999, 
    --     startOffset = 0, 
    --     alerts = {
    --         [5]  = "ShouLingFuZhi.ogg",
    --         [14] = "ZhunBeiDianMing.ogg",
    --         [25] = "ZhunBeiDianMing.ogg",
    --         [38] = "ZhunBeiLaRen.ogg",
    --         [50] = "AnQuanAnQuan.ogg",
    --     }
    -- },
    -- [3074] = { -- 迪詹崔乌斯
    --     interval = 22, 
    --     startOffset = 0, 
    --     alerts = {
    --         [2]  = { file = "ZhuYiJianShang.ogg", role = "TANK" },
    --         [3]  = { file = "ZhuYiShuaTan.ogg", role = "HEALER" },
    --         [6]  = { file = "QuSanMoFa.ogg", role = "HEALER" },
    --         [16] = "ZhunBeiJieQuan.ogg",
    --         [18] = "接圈.ogg",
    --         [20] = "ZhunBeiDuoQiu.ogg",
    --         [23] = "San.ogg",
    --         [26] = { file = "ZhuYiJianShang.ogg", role = "TANK" },
    --         [27] = { file = "ZhuYiShuaTan.ogg", role = "HEALER" },
    --         [28] = "Er.ogg",
    --         [30] = { file = "QuSanMoFa.ogg", role = "HEALER" },
    --         [33] = "Yi.ogg",            
    --     }
    -- },
    [3177] = { -- 弗拉希乌斯
        interval = 999, 
        startOffset = 0, 
        alerts = {
            [88]  = "KuaiKaiJianShang.ogg",
            [208] = "KuaiKaiJianShang.ogg",
            [329] = "KuaiKaiJianShang.ogg",
        }
    },
    [3179] = { -- 陨落之王萨哈达尔
        interval = 999, 
        startOffset = 0, 
        alerts = {
            [36]  = "ZhuanHuoErQiu.ogg",
            [82]  = "ZhuanHuoErQiu.ogg",
            [155] = "ZhuanHuoErQiu.ogg",
            [208] = "ZhuanHuoErQiu.ogg",
            [278] = "ZhuanHuoErQiu.ogg",
            [329] = "ZhuanHuoErQiu.ogg",
        }
    },
    [3306] = { -- 奇美鲁斯
        interval = 999, 
        startOffset = 0, 
        alerts = {
            [68]  = { file = "ZhuanHuoDaGuai.ogg", role = "DAMAGER" },
            [139] = { file = "ZhuanHuoDaGuai.ogg", role = "DAMAGER" },
            [319] = { file = "ZhuanHuoDaGuai.ogg", role = "DAMAGER" },
            [391] = { file = "ZhuanHuoDaGuai.ogg", role = "DAMAGER" },
        }
    },
    [3181] = { -- CrownOfTheCosmos
        interval = 999, 
        startOffset = 0, 
        alerts = {
            -- 修改后的配置示例
            [5] = { 
                file = "MeiYouYinPin.ogg", 
                duration = 5, 
                checkCast = true  -- 新增参数，标记此警报需要检查施法
            },
            [25] = { 
                file = "MeiYouYinPin.ogg", 
                duration = 5, 
                checkCast = true  -- 新增参数，标记此警报需要检查施法
            },
        }
    },
    [3212] = { -- 姆罗金和内克拉克斯
        interval = 45, 
        startOffset = 0, 
        alerts = {
            -- [5]  = { file = "XiaoXinJiFei.ogg", role = "TANK" }, 
            -- [6]  = { file = "TanKeLiuXue.ogg", role = "HEALER" }, 
            -- [12] = "ZhunBeiJiBing.ogg",
            -- [20] = "DuoKaiXianJing.ogg",
            -- [28] = "ZhuYiDuoQuan.ogg",
            -- [32] = "ZhunBeiJianYu.ogg",
            [40] = { file = "QuSanMoFa.ogg", role = "HEALER" }, 
        }
    },
    -- [3213] = { -- 沃达扎
    --     interval = 9999, 
    --     startOffset = 0, 
    --     alerts = {
    --         [2]  = { file = "ZhuYiJianShang.ogg", role = "TANK" },
    --         [3]  = { file = "ZhuYiShuaTan.ogg", role = "HEALER" },
    --         [14] = "ZhunBeiDianMing.ogg",
    --         [25] = "DuoKaiTouQian.ogg",
    --         [35] = { file = "ZhuYiJianShang.ogg", role = "TANK" },
    --         [36] = { file = "ZhuYiShuaTan.ogg", role = "HEALER" },
    --         [48] = "ZhunBeiDianMing.ogg",
    --         [59] = "DuoKaiTouQian.ogg",
    --         [68] = "ZhunBeiPoDun.ogg",
    --         [71] = "KuaiKaiJianShang.ogg",
    --         [80] = "ZhuYiDuoQiu.ogg",
    --     }
    -- },
    [3214] = { -- 拉克图尔，聚魂之器
        interval = 120, 
        startOffset = 0, 
        alerts = {
            [2]  = { file = "ZhuYiJianShang.ogg", role = "TANK" },
            [4]  = { file = "TieBianFangShui.ogg", role = "TANK" },
            [5]  = { file = "ZhuYiShuaTan.ogg", role = "HEALER" },
            [6]  = "ZhuYiDuoQuan.ogg",
            [12] = "ZhuYiDuoQuan.ogg",
            [18] = "ZhuYiDuoQuan.ogg",
            [24] = { file = "ZhuanHuoXiaoGuai.ogg", role = {"TANK", "DAMAGER"} },
            [29] = { file = "ZhuYiJianShang.ogg", role = "TANK" },
            [31] = { file = "TieBianFangShui.ogg", role = "TANK" },
            [36] = "ZhuYiDuoQuan.ogg",
            [42] = "ZhuYiDuoQuan.ogg",
            [49] = "ZhuYiDuoQuan.ogg",
            [52] = { file = "ZhuanHuoXiaoGuai.ogg", role = {"TANK", "DAMAGER"} },
            [55] = { file = "ZhuYiJianShang.ogg", role = "TANK" },
            [57] = { file = "TieBianFangShui.ogg", role = "TANK" },
            [66] = "ZhuYiDuoQuan.ogg",
            [70] = "JieDuanZhuanHuan.ogg",
            [80] = "KongDuanDaGuai.ogg",
            -- [86] = "KuaiKaiJianShang.ogg",
            [116]= "San.ogg",
            [117]= "Er.ogg",
            [118]= "Yi.ogg",
            [119]= "YiShangJieShu.ogg",
        }
    },
    [3328] = {
        interval = 50, 
        startOffset = 0, 
        alerts = {
            -- [2]  = "ZhuYiSheXian.ogg",
            -- [6]  = "ZhunBeiDianMing.ogg",
            -- [12] = "ZhuYiDuoQuan.ogg",
            -- [14] = "ZhuYiSheXian.ogg",
            -- [18] = "ZhunBeiDianMing.ogg",
            -- [24] = "ZhuYiDuoQuan.ogg",
            -- [26] = "ZhuYiSheXian.ogg",
            -- [30] = "ZhunBeiDianMing.ogg",
            -- [36] = "ZhuYiSheXian.ogg",
            [38] = "JiHeYinQiu.ogg",
            [43] = { file = "ZhiLiaoYuPu.ogg", role = "HEALER" },
            [46] = { file = "XiaoXinJiTui.ogg" },
            [48] = "KuaiKaiJianShang.ogg",
        }
    },
    [3332] = {
        interval = 9999, 
        startOffset = 0, 
        alerts = {
            -- [2]  = { file = "ZhuYiJianShang.ogg", role = "TANK" },
            -- [3]  = { file = "ZhuYiShuaTan.ogg", role = "HEALER" },
            -- [5]  = "ZhunBeiDianMing.ogg",
            -- [19] = { file = "ZhuYiJianShang.ogg", role = "TANK" },
            -- [20] = { file = "ZhuYiShuaTan.ogg", role = "HEALER" },
            -- [22] = "小怪激活.ogg",
            -- [24] = "ZhunBeiDianMing.ogg",
            [26] = { file = "DaDuanDaGuai.ogg", role = {"TANK", "DAMAGER"} },
            -- [32] = "ZhunBeiYiShang.ogg",
            -- [37] = "KuaiJinShengGuang.ogg",
            -- [39] = { file = "KuaiKaiJianShang.ogg", role = {"HEALER", "DAMAGER"} },
            -- [52] = "San.ogg",
            -- [53] = "Er.ogg",
            -- [54] = "Yi.ogg",
            -- [55] = "YiShangJieShu.ogg",
        }
    },
}

local PrivateAuraList = {
    [1252733] = "XiaoXinJiTui", -- 疾风奔涌
    [154132]  = "NiBeiYiShang", -- 灼热重击
    [1279002] = "TanKeGuoYuan", -- 小的波是击怒冲虚
    [1253511] = "XiaoGuaiDingNi", -- 击邪追煞燃魔爆鬼
    [154150]  = "ZhuYiJianShang", -- 线炽光耀脉芒炽耀
    [1253541] = "ZhuYiJianShang", -- 线炽射耀烧脉灼芒
    [153954]  = "XiaoGuaiZhuaNi", -- 下坠扔崩碎震裂坠
    [1253531] = "JiGuangDianNiSanErYiAnQuanAnQuan", -- 光耀眩芒炽脉闪耀
    [1261286] = "ShiMaFenSanDuoKaiDaQuan", -- 铁崩邪碎隆震萨裂掷坠投崩
    [1261540] = "QuanZhuShiTou", -- 碎矿猛击
    [1261799] = "JingBao", -- 萨隆邪铁淤泥
    [1275687] = "KuaiZhaoYanTi", -- 载劫过乱川灾冰逆
    [1264186] = "XiaoGuaiDianNi", -- 缚囚束锁影迷暗隐
    [1264299] = "JingBao", -- 凋零
    [1280616] = "DaGuaiZhuiNiSanErYiAnQuanAnQuan", -- 视禁凝瞳重渊笨滞
    [1264595] = "HuiDaoNeiChang", -- 暗影射线屏障
    [1262772] = "QuanZhuGuDuiKuaiKaiJianShang", -- 击极冲裂霜零白绝    
    [245742]  = "ZhuYiZiBao", -- 袭瞬突幽影掠暗遁
    [244588]  = "JingBao", -- 虚空淤泥
    -- [1280064] = "QuanZhuXiaoQiu", -- 锋散冲爆位逆相乱
    [246026]  = "ZhuYiZiBao", -- 弹蚀炸裂空崩虚寂
    [1268840] = "NiBeiYiShang", -- 空散虚蚀透乱渗逆
    [1263542] = "ZhuYiZiBao", -- 群体虚空灌输
    [1263532] = "JingBao", -- 虚空风暴
    [1265426] = "SheYinFuKaiJianShang", -- 不谐射线   
    [386201]  = "JingBao", -- 腐化法力
    [391977]  = "NiBeiYiShang", -- 载震超爆动猛涌烈
    [388544]  = "NiBeiYiShang", -- 腐哀击摧树撼裂震
    [376760]  = "NiBeiQiangHua", -- 力怒之撕风疾狂破
    [389007]  = "JingBao", -- 量掠能蚀蛮碎野裂
    [1260643] = "KuaiKaiJianShang", -- 击瞬射闪幕影弹掠
    -- [1260709] = "YiSuJiangDi", -- 刺腐钉枯枝死邪蚀
    [1249478] = "KuaiCaiXianJing", -- 扑裂飞掠肉碎腐蚀
    [1243752] = "JingBao", -- 覆冰    
    [1251775] = "MuBiaoShiNi", -- 终极追杀
    [1251813] = "SanErYiAnQuanAnQuan", -- 惧怨恐孽绕蚀萦寂
    [1266706] = "NiBeiYiShang", -- 骸魂残灭绕寂萦怨
    [1251833] = "JingBao", -- 灵魂腐烂    
    [1252675] = "JiHeFangTuTengJiaSuKuaiPao", -- 粉碎灵魂
    [1252777] = "TuTengLaNi", -- 灵魂束缚
    [1252816] = "JingBao", -- 死亡战栗
    [1253779] = "JingBao", -- 零枯凋劫魂哀幽腐
    [1254175] = "BieZhuangLingHun", -- 喊寂哭怨的劫者腐亡寂
    [1254043] = "JingBao", -- 苦腐痛寂的劫恒哀永腐 
    -- [466559]  = "TieBianFangShuiSanMiaoSanErYi", -- 流阴腾阳炽冷焰热
    [470212]  = "CaiDaoXuanFeng", -- 卷笑龙哭燃怒炽愁
    [472118]  = "JingBao", -- 点燃余烬    
    [474129]  = "TieBianFangShuiYiMiaoSanErYi", -- 吐碗喷锅溅勺飞铲
    [472777]  = "JingBao", -- 溅桌喷椅稠咒黏死
    [472793]  = "MiaoZhunNvYao", -- 拽笔拖墨力纸猛砚
    [474075]  = "MeiYouGouDao", -- 砍灯劈表力走猛停
    [1283247] = "PaoKaiRenQunKuaiKaiJianShang", -- 跃草跳花情灯无碗
    [470966]  = "BossZhuiNiLiuMiaoSanErYiAnQuan", -- 暴桌风椅刃笔剑墨
    [468924]  = "KuaiDuoKai", -- 暴伞风雨刃云剑电
    [1253054] = "AnQuanAnQuan", -- 吼狱怒渊胆冥破幽
    [1253030] = "MeiYouChongHe", -- 吼狱怒渊胆冥破幽
    [472662]  = "NiBeiYiShang", -- 斩疾风掠暴破瞬影
    [1253979] = "ZhuYiXiaoShuiSanMiaoKuaiKaiJianShang", -- 击穿射裂风瞬劲影
    [1282911] = "MuBiaoShiNi", -- 飞矢烈风
    [474528]  = "XiaoXinJiTui", -- 飞矢烈风    
    [468442]  = "ZhuYiZiBao", -- 翻腾之风
    [1282955] = "JingBao", -- 风暴灵魂之泉
    [1251772] = "JiaoChaDianXiaoLianXian", -- 能激充旋流脉回震
    [1251785] = "JiaoChaDianXiaoLianXian", -- 能涌充裂流爆回震
    [1264042] = "JingBao", -- 溢杯喷响术纸奥束
    [1251626] = "KuaiDuoKai", -- 列灯阵表网走魔缚
    [1252828] = "NiBeiYiShang", -- 裂痛创碎空壳虚魂
    [1249020] = "ShiMaFenSanSiMiaoKuaiKaiJianShang", -- 伐书步画光笔蚀墨
    -- [1271433] = "NiBeiQiangHua", -- 斑强耀光痕电光神
    [1255310] = "JingBao", -- 光耀之痕
    [1271956] = "ZhuYiZiBao", -- 裂震撕闪像影镜瞬
    [1247975] = "NiBeiQiangHua", -- 斑强耀光痕电光神  
    [1265984] = "BieZhanTouQian", -- 斑强耀光痕电光神  
    [1214089] = "JingBao", -- 渣乱残废术破奥灭
    [1214038] = "NiBeiDingShen", -- 锁苦枷酸灵甜虚辣
    [1243905] = "KuaiKaiJianShang", -- 不稳定的能量
    [1225792] = "WuMaFenSan", -- 符文印记
    [1225015] = "JingBao", -- 镇压力场
    [1246446] = "SanErYiAnQuan", -- 噬空反寂无灭虚涌
    [1225205] = "MeiJinZhaoZi", -- 潮碎浪退默啸静涌
    [1224104] = "JingBao", -- 虚空分泌物
    [1284958] = "ZhuYiZiBao", -- 击星刺尘宇界寰幻
    [1253709] = "KaoJinShuiMu", -- 结络接感经控神缠
    [1224299] = "MuBiaoShiNiWuMiaoSanErYi", -- 星界束缚
    [1224401] = "KuaiDuoKai", -- 宇宙辐射
    [1284627] = "TieBianQuSan", -- 片灯裂碎影墙幽魂
    [1284633] = "JingBao", -- 液桌腐咒河椅冥死
    [1269631] = "YiSuJiangDi", -- 珠鞋宝帽能袜熵衣
    [1215161] = "MeiYouJieQuan", -- 灭勺毁桶空锅虚铲

    -- 元首阿福扎恩
    [1275059] = "JiSuJiangDi", -- 黑色瘴气
    [1280075] = "KuaiKaiJianShang", -- 徘徊黑暗
    [1284786] = "JingBao", -- 暗影方阵
    -- [1265540] = "", -- 黑化创伤
    [1283069] = "XiaoGuaiDingNi", -- 虚弱
    [1255680] = "KuaiKaiJianShang", -- 啃噬虚空
    -- [1249265] = "QuanZhuDaGuai", -- 幽影坍缩
    [1280023] = "KuaiJinZhaoZi", -- 虚空标记
    [1260981] = "JingBao", -- 无尽行军

    -- 弗拉希乌斯
    [1259186] = "NiBeiYiShang", -- 气泡爆裂
    [1272527] = "YiSuJiangDi", -- 爬行喷吐
    [1243270] = "JingBao", -- 黑暗黏液
    [1241844] = "NiBeiYiShang", -- 碾碎
    [1254113] = "XiaoGuaiDingNi", -- 锁定

    -- 陨落之王萨哈达尔
    [1250828] = "JingBao", -- 虚空暴露
    [1245960] = "ShouLingQiangHua", -- 虚空灌输
    [1250991] = "ZhuYiZiBao", -- 晦暗侵蚀
    [1245592] = "JingBao", -- 痛苦精粹
    [1251213] = "JingBao", -- 暮光尖峰
    [1248697] = "TieBianFangShui", -- 专制命令
    [1248709] = "ZhuYiZiBao", -- 压抑黑暗
    -- [1250686] = "", -- 扭曲遮蔽
    [1260030] = "JingBao", -- 本影迸流
    [1253024] = "YuanLiRenQun", -- 粉碎暮光
    [1268992] = "YuanLiRenQunYiMiao", -- 粉碎暮光
    -- 威厄高尔和艾佐拉克
    [1244672] = "LaDuanLianXian", -- 虚界
    -- [1252157] = "ZhuYiZiBao", -- 虚界 
    [1264467] = "ZhuYiZiBao", -- 龙尾扫击
    -- [1245554] = "ZhuYiZiBao", -- 阴霾触摸
    [1270852] = "NiBeiYiShang", -- 削弱
    -- [1245175] = "ZhuYiZiBao", -- 虚空箭
    [1265152] = "ZhuYiZiBao", -- 穿刺
    -- [1255763] = "", -- 午夜化身
    -- [1262656] = "ZhuYiZiBao", -- 虚无光束
    [1255612] = "MuBiaoShiNi", -- 亡者吐息
    -- [1255979] = "KongJu", -- 亡者吐息
    [1245421] = "JingBao", -- 阴霾区域
    -- [1245059] = "", -- 虚空嚎叫
    -- [1248865] = "ZhuanHuoDaGuai", -- 辐光屏障
    [1270497] = "PaoKaiRenQun", -- 暗影印记

    -- 光盲先锋军
    [1276982] = "JingBao", -- 神圣奉献
    [1272324] = "ZhuYiZiBao", -- 神恩风暴
    -- [1246736] = "NiBeiYiShang", -- 审判
    -- [1251857] = "NiBeiYiShang", -- 审判
    [1249130] = "ZhuYiZiBao", -- 雷象冲锋
    [1258514] = "ZhuYiZiBao", -- 盲目之光
    -- [1248985] = "", -- 处决宣判
    [1248652] = "ZhuYiZiBao", -- 圣洁鸣钟
    -- [1246487] = "WuMaFenSan", -- 复仇者之盾
    [1246502] = "ZhuYiZiBao", -- 复仇者之盾
    [1248721] = "ZhuYiZiBao", -- 提尔之怒

    -- 奇美鲁斯，未梦之神
    -- [1245698] = "XiaoGuaiKuaiDa", -- 艾林洞察
    [1262020] = "ZhuYiZiBao", -- 巨像打击
    -- [1250953] = "ZhuYiZiBao", -- 裂隙疲弊
    [1253744] = "XiaoGuaiKuaiDa", -- 裂隙易伤
    [1264756] = "MuBiaoShiNi", -- 裂隙疯狂
    [1272726] = "ZhuYiZiBao", -- 猛撕开裂
    -- [1246653] = "ZhuYiZiBao", -- 腐蚀黏痰
    [1257087] = "ZhuYiXiaoShui", -- 吞噬瘴气
    [1265940] = "KongJu", -- 可怖战吼
    -- 宇宙之冕
    [1233602] = "MiaoZhunDaGuai", -- 银锋箭
    [1242553] = "JingBao", -- 虚空残渣
    [1233865] = "ZhuYiZiBao", -- 空无之冕
    [1243753] = "ShangHaiJiangDi", -- 暴食深渊
    [1238206] = "ZhuYiZiBao", -- 无常裂隙
    -- [1237038] = "ZhuYiZiBao", -- 虚空追猎者钉刺
    [1232470] = "TiaoZhengJiaoDu", -- 空虚之握
    [1238708] = "YiSuTiGao", -- 黑暗冲锋
    [1283236] = "TieBianFangShui", -- 虚空斥力
    -- [1243981] = "NiBeiYiShang", -- 银锋弹幕射击
    -- [1234570] = "", -- 星辰散射
    [1246462] = "ZhuYiZiBao", -- 裂隙挥砍
    [1237623] = "MiaoZhunXiaoGuai", -- 游侠队长印记
    [1227557] = "KuaiDuoKai", -- 噬灭宇宙
    [1239111] = "LianXianDianNi", -- 终末守护
    [1255453] = "NiBeiYiShang", -- 重力坍缩

    -- 贝洛朗，奥的子嗣
    [1241292] = "MuBiaoShiNi.ogg", -- 圣光俯冲
    [1241339] = "MuBiaoShiNi.ogg", -- 虚空俯冲
    -- [1244348] = ".ogg", -- 圣光灼烧
    -- [1266404] = ".ogg", -- 虚空灼烧
    [1242803] = "JingBao.ogg", -- 圣光烈焰
    [1242815] = "JingBao.ogg", -- 虚空烈焰
    [1241840] = "JingBao.ogg", -- 圣光区域
    [1241841] = "JingBao.ogg", -- 虚空区域
    [1241992] = "MuBiaoShiNi.ogg", -- 圣光飞羽
    [1242091] = "MuBiaoShiNi.ogg", -- 虚空飞羽
    -- 至暗之夜降临
    [1282027] = "JingBao.ogg", -- 黑暗之井
    [1249609] = "FuWenDianNi.ogg", -- 黑暗符文
    -- [1249584] = ".ogg", -- 不谐
    -- [1251789] = ".ogg", -- 宇宙裂隙
    -- [1284699] = ".ogg", -- 圣光终末
    -- [1265842] = ".ogg", -- 被刺穿
    -- [1262055] = ".ogg", -- 蚀盛
    -- [1281184] = ".ogg", -- 临界状态
    -- [1266113] = ".ogg", -- 执炬手
    -- [1253104] = ".ogg", -- 黎明光障
    -- [1282470] = ".ogg", -- 黑暗类星体
    -- [1284984] = ".ogg", -- 黯灭协奏
    -- [1253031] = ".ogg", -- 闪烁
    [1279512] = "SheXianDianNi.ogg", -- 星辰裂片
    [1285510] = "SheXianDianNi.ogg", -- 星辰裂片
    -- [1282016] = ".ogg", -- 湮灭之虹
    [1284527] = "MiaoZhunHeiQiu.ogg", -- 充电
    -- [1284531] = ".ogg", -- 凋零
    [1263514] = "JingBao.ogg", -- 至暗之夜
    -- [1275429] = ".ogg", -- 断离
    -- [1266946] = ".ogg", -- 断离

}

local LocationWarningAlerts = {
    -- [184]  = "WuMaFenSanWuMiaoZhuYiJiaoXia.ogg", 
    [601]  = { file = "XiaoXinJiTui.ogg", duration = 2.7 },
    [602]  = { file = "XiaoXinJiTui.ogg", duration = 2.7 },
    [2501] = "ZhuYiJiuRen.ogg", 
}

local LocationCastData = {
    ["眺望台"] = {
        { file = "KongDuanDaGuai.ogg" }
    },
    -- ["主峰"] = {
    --     { 
    --         file = { "ZhuYiDianMing.ogg", "JinZhanDaQuan.ogg", "ZhuYiDianMing.ogg" }, 
    --         unitLevel = NEXT_PLAYER_LEVEL, 
    --         mapID = 601
    --     },
    -- },
    ["艾杰斯亚学院"] = {
        { 
            file = { "MeiYouYinPin.ogg", "MeiYouYinPin.ogg", "DuoKaiDaQuan.ogg", "MeiYouYinPin.ogg", "MeiYouYinPin.ogg" }, 
            unitLevel = NEXT_PLAYER_LEVEL, 
            mapID = 2098
        },
    },
    -- [""] = {
    --     { 
    --         file = { "DuoKaiDaQuan.ogg", "ZhuYiTouQian.ogg" }, 
    --         unitLevel = NEXT_PLAYER_LEVEL, 
    --         mapID = 2097
    --     },
    -- },
    -- ["体育场"] = {
    --     { 
    --         file = { "DuoKaiTouQian.ogg", "ZhunBeiJiNuSanMiaoJiNu.ogg" }, 
    --         unitLevel = NEXT_PLAYER_LEVEL, 
    --         mapID = 2098
    --     },
    -- },
    -- ["绿植场圃"] = {
    --     { 
    --         file = "TanKeJianShang.ogg", 
    --         unitLevel = NEXT_PLAYER_LEVEL, 
    --         mapID = 2097, 
    --         role = "TANK"
    --     },
    -- },
    -- ["三人议政厅"] = {
    --     { 
    --         file = { "ZhunBeiYouBuYouBu.ogg", "MeiYouYinPin.ogg" }, 
    --         unitLevel = NEXT_PLAYER_LEVEL, 
    --         mapID = 903
    --     },
    -- },
    -- ["魔导师平台"] = {
    --     { 
    --         file = { "TanKeDingShen.ogg", "ZhuYiDianMing.ogg", "XiaoXinJiTui.ogg" }, 
    --         unitLevel = NEXT_PLAYER_LEVEL, 
    --         mapID = 2515 
    --     },
    -- },
    ["奥术图书馆"] = {
        { 
            file = { "ZhunBeiAOE.ogg", "JinZhanDaQuan.ogg", "DaDuanDuTiao.ogg" }, 
            unitLevel = NEXT_PLAYER_LEVEL, 
            mapID = 2515 
        },
    },
    ["大法师庇护所"] = {
        { 
            file = { "MeiYouYinPin.ogg", "ZhuYiDuoQuan.ogg" }, 
            unitLevel = NEXT_PLAYER_LEVEL, 
            mapID = 2516 
        },
    },
    ["节点核心"] = {
        { 
            file = { "MeiYouYinPin.ogg", "MeiYouYinPin.ogg", "ZhuYiTouQian.ogg" }, 
            unitLevel = NEXT_PLAYER_LEVEL, 
            mapID = 2556
        },
    },
    ["回响大桥"] = {
        { 
            file = "JinZhanXuanFeng.ogg", 
            unitLevel = NEXT_PLAYER_LEVEL, 
            mapID = 2501
        },
    },
    ["幽灵悲歌"] = {
        {
            file = "TanKeDaiWei.ogg", 
            unitLevel = NEXT_PLAYER_LEVEL, 
            mapID = 2492 
        },
        -- { 
        --     file = { "ZhuYiSheXian.ogg", "ZhunBeiDuanFaLiangMiaoSanErYi.ogg", "ZhuYiSheXian.ogg" }, 
        --     unitLevel = NEXT_PLAYER_LEVEL, 
        --     mapID = 2498 
        -- },
    },
    -- ["风行者宝库"] = {
    --     { 
    --         file = "DaGuaiShiFa.ogg",
    --         unitLevel = NEXT_PLAYER_LEVEL, 
    --         mapID = 2498
    --     },
    -- },
    -- ["神秘地瓜的要塞"] = {
    --     { file = "TanKeDaiWei.ogg", unitLevel = 42, mapID = 581 },
    --     { 
    --         file = { "ZhuYiSheXian.ogg", "TingZhiShiFa.ogg" }, 
    --         unitLevel = 42, 
    --         mapID = 582 
    --     },
    -- },
}

local LocationChannelData = {
    -- ["温蕾萨之憩"] = {
    --     { 
    --         file = "KongDuanLongYing.ogg",
    --         unitLevel = PLAYER_LEVEL, 
    --         mapID = { 2493, 2494 }
    --     },
    -- },
    ["希尔瓦娜斯的营房"] = {
        { 
            file = { "HuDunKuaiDa.ogg", "DaDuanNvYao.ogg" }, 
            unitLevel = NEXT_PLAYER_LEVEL, 
            mapID = { 2496, 2497 }
        },
    },
    ["幽灵悲歌"] = {
        {
            file = "ZhunBeiAOE.ogg", 
            unitLevel = NEXT_PLAYER_LEVEL, 
            mapID = 2492 
        },
    },
    ["回响大桥"] = {
        { 
            file = "BeiMianKuaiDa.ogg", 
            unitLevel = NEXT_PLAYER_LEVEL, 
            mapID = 2501
        },
    },
    -- ["观测台"] = {
    --     {
    --         file = { "ZhaoHuanXiaoGuai.ogg", "KuaiKaiJianShang.ogg", "ZhaoHuanXiaoGuai.ogg" },
    --         unitLevel = NEXT_PLAYER_LEVEL, 
    --         mapID = 2511
    --     },
    -- },
    -- ["星象庭"] = {
    --     {
    --         file = { "ZhaoHuanXiaoGuai.ogg", "KuaiKaiJianShang.ogg", "ZhaoHuanXiaoGuai.ogg" },
    --         unitLevel = NEXT_PLAYER_LEVEL, 
    --         mapID = 2511
    --     },
    -- },
    -- ["论学高塔"] = {
    --     {
    --         file = { "ZhaoHuanXiaoGuai.ogg", "KuaiKaiJianShang.ogg", "ZhaoHuanXiaoGuai.ogg" },
    --         unitLevel = NEXT_PLAYER_LEVEL, 
    --         mapID = { 2517, 2518, 2519 }
    --     },
    -- },
    [""] = {
        { 
            file = "LiangMiaoZhuYiDuoQuan.ogg", 
            unitLevel = NEXT_PLAYER_LEVEL, 
            mapID = 2501
        },
    },
}

local EventSoundData = {  
    -- 熔炉之主加弗斯特
    [147] = {"KuaiZhaoYanTi.ogg", 1}, -- 冰川过载
    -- 阿拉卡纳斯
    [302] = {"ZhuYiTouQian.ogg", 1, {TANK = true}}, -- 灼热重击
    [303] = {"XiaoGuaiJiHuo.ogg", 1}, -- 充能
    [304] = {"ZhunBeiAOE.ogg", 1}, -- 超级新星
    -- 鲁克兰
    [603] = {"XiaoGuaiFuHuo.ogg", 0}, -- 荣耀烈焰 (1283787)
    -- 高阶贤者维里克斯
    -- [309] = {".ogg", 1}, -- 灼烧射线 (1253538)
    -- [310] = {"ZhuanHuoXiaoGuai.ogg", 1, {DAMAGER = true, TANK = true}}, -- 扔下 (1253998)
    -- [311] = {".ogg", 1}, -- 日光冲击 (154396)
    -- [312] = {".ogg", 1}, -- 眩光 (1253840)
    -- 学院
    -- 茂林古树
    [282] = {"TanKeJianShang.ogg", 1, {TANK = true, HEALER = true}}, -- 裂树击 (388544)
    [283] = {"ZhunBeiDaGuaiErDianWuMiaoZhuanHuoDaGuai.ogg", 1, {TANK = true, DAMAGER = true}}, -- 分枝 (388567)
    [284] = {"ZhuYiJiaoXia.ogg", 1}, -- 发芽 (388796)
    [285] = {"ZhunBeiAOE.ogg", 1}, -- 爆发苏醒 (388923)
    -- [293] = {".ogg", 1}, -- 奥术飞弹 (373325)
    -- [294] = {".ogg", 1}, -- 星界冲击 (1282251)
    [295] = {"TieBianFangShui.ogg", 0}, -- 能量炸弹 (374341)
    -- [296] = {".ogg", 1}, -- 力量真空 (388820)
    -- 晋升者祖拉尔
    [223] = {"DuoKaiZhengMian.ogg", 1}, -- 虚空之掌 (1268916)
    [224] = {"ZhunBeiTiaoRen.ogg", 1}, -- 残杀 (1263282)
    [225] = {"ZhunBeiAOE.ogg", 1}, -- 渗漏猛击 (1263399)
    [226] = {"SiMiaoTanKeJianShang.ogg", 2, {TANK = true, HEALER = true}}, -- 虚空挥砍 (1263440)
    -- [238] = {"XiaoXinJiTui.ogg", 1}, -- 崩解虚空 (1263304)
    -- 萨普瑞什
    [234] = {"ZhuYiDuoQuan.ogg", 1}, -- 虚空炸弹 (247175)
    -- [235] = {".ogg", 1}, -- 相位冲锋 (1263509)
    [236] = {"DaDuanDuTiao.ogg", 0, {DAMAGER = true, TANK = true}}, -- 恐惧尖啸 (248831)
    [237] = {"DanShuaLiuXue.ogg", 1, {HEALER = true}}, -- 暗影突袭 (245738)
    -- [243] = {".ogg", 1}, -- 过载 (1263523)
    -- 总督奈扎尔
    [244] = {"DaDuanDuTiao.ogg", 1, {DAMAGER = true, TANK = true}}, -- 心灵震爆 (244750)
    [246] = {"ZhunBeiXiaoGuai.ogg", 1}, -- 暗影触须 (1263538)
    -- 鲁拉    
    [249] = {"ZhunBeiAOE.ogg", 1}, -- 绝望哀歌    
    [250] = {"ZhunBeiDianMingLiangMiaoSanErYi.ogg", 2}, -- 不谐射线
    [251] = {"ZhuYiSheXian.ogg", 1}, -- 裂解
    [252] = {"DuoKaiDaQuan.ogg", 1}, -- 幽冥和音
    [253] = {"ZhunBeiYiShangShiMiaoYiShangJieDuan.ogg", 1}, -- 永夜交响曲
    [254] = {"ZhunBeiJiTuiLiangMiaoSanErYi.ogg", 2}, -- 反冲    
    -- [247] = {".ogg", 1}, -- 驱逐 (1263528)
    [376] = {"ZhunBeiDuoQiuSiMiaoZhuYiDuoQiu.ogg", 1}, -- 深渊之门 (1277358)
    [245] = {"ZhuYiDanShua.ogg", 1, {HEALER = true}}, -- 群体虚空灌输 (1263542)
    -- 烬晓
    [239] = {"TanKeChengShang.ogg", 1, {TANK = true, HEALER = true}}, -- 炽热尖喙
    [241] = {"ZhunBeiDianMing.ogg", 1}, -- 炽焰腾流
    [242] = {"WuMiaoZhunBeiChuiFengSanMiaoNiShiZhenTouQian.ogg", 2}, -- 燃烧烈风          
    -- 被遗弃的二人组
    [25]  = {"TanKeChengShang.ogg", 1, {TANK = true, HEALER = true}}, -- 碎骨猛砍  
    [26]  = {"GuiHunDianNiSanErYi.ogg", 0}, -- 黑暗诅咒    
    [27]  = {"ZhunBeiDianMing.ogg", 2}, -- 衰弱尖啸         
    -- 指挥官克罗鲁科
    [210] = {"TanKeChengShang.ogg", 1, {TANK = true, HEALER = true}}, -- 暴怒
    [211] = {"ZiQuanChongHeLiangMiaoSanErYi.ogg", 1}, -- 破胆怒吼
    [212] = {"SanMiaoZhuYiDuoQuan.ogg", 1}, -- 无情跳跃
    -- [213] = {"ZiQuanChongHeLiangMiaoSanErYi.ogg", 1}, -- 破胆怒吼
    [214] = {"SanMiaoZhuYiDuoQuan.ogg", 1}, -- 无情跳跃
    [215] = {"ZhunBeiAOE.ogg", 0}, -- 集结怒吼
    -- 无眠之心
    [21]  = {"ZhunBeiAOELiangMiaoSanErYi.ogg", 2}, -- 疾风狙击
    [22]  = {"ZhunBeiJianYu.ogg", 2}, -- 飞矢烈风
    [23]  = {"ZhuYiDuoQuanWuMiaoCaiQuanXiaoCeng.ogg", 1}, -- 矢如雨下
    [24]  = {"TanKeJiTui.ogg", 1, {TANK = true, HEALER = true}}, -- 暴风斩    
    -- 核技工程长卡斯雷瑟   
    [108] = {"ZhuYiSheXian.ogg", 1}, -- 魔网阵列 (1251183)
    -- [106] = {".ogg", 1}, -- 核闪引爆 (1257512)
    [107] = {"JiaoChaDianXiaoLianXian.ogg", 0}, -- 回流充能 (1251767)
    [172] = {"ZhuYiJiaoXia.ogg", 1}, -- 能量坍缩 (1264048)
    -- 核心守卫奈萨拉 
    [36]  = {"ZhunBeiXiaoGuaiLiuMiaoXiaoGuaiJiHuo.ogg", 1}, -- 空无先锋
    [35]  = {"TanKeChengShang.ogg", 1, {TANK = true, HEALER = true}}, -- 幽影鞭笞   
    [34]  = {"ZhunBeiYiShangJiuMiaoKuaiJinShengGuang.ogg", 0}, -- 光痕耀斑
    -- [33]  = {"ZhunBeiDianMing.ogg", 2}, -- 蚀光步伐    
    -- 洛萨克森
    [109] = {"BaMaFenSanSiMiaoZhuYiDuoQuan.ogg", 1}, -- 辉熠消散
    [110] = {"ZhunBeiJiTuiSiDianWuMiaoSanErYiDaDuanGuangTou.ogg", 1}, -- 神圣诡计
    [111] = {"TanKeChengShang.ogg", 1, {TANK = true, HEALER = true}}, -- 灼热撕裂
    [112] = {"DuoKaiChongFeng.ogg", 1}, -- 闪烁   
    -- 吉美尔鲁斯
    [635] = {"SanChongFuZhi.ogg", 0}, -- 三重复制
    [97]  = {"ZhunBeiDianMing.ogg", 1}, -- 神经链接
    [98]  = {"ZhunBeiLaRen.ogg", 0}, -- 星界束缚
    [100] = {"DianMingFangShui.ogg", 1}, -- 寰宇刺击
    -- 姆罗金和内克拉克斯
    [150] = {"TanKeLiuXue.ogg", 1, {TANK = true, HEALER = true}}, -- 长矛侧攻
    [151] = {"ZhuYiDuoQuan.ogg", 1}, -- 恶臭羽毛风暴
    [152] = {"DuoKaiXianJing.ogg", 1}, -- 冰冻陷阱
    [153] = {"ZhunBeiJianYu.ogg", 2}, -- 弹幕射击    
    [154] = {"ZhunBeiJiBing.ogg", 1, {HEALER = true}}, -- 感染羽翼
    [155] = {"ZhunBeiDianMing.ogg", 2}, -- 感染羽翼    
    -- 沃达扎    
    [16]  = {"TanKeChengShang.ogg", 1, {TANK = true, HEALER = true}}, -- 吸取灵魂
    [17]  = {"DuoKaiTouQian.ogg", 1}, -- 寂灭
    [19]  = {"ZhunBeiDianMing.ogg", 1}, -- 束缚幻影
    [20]  = {"WuMiaoZhunBeiPoDunSanMiaoKuaiKaiJianShangShiErMiaoZhuYiDuoQiu.ogg", 2}, -- 死疽融合
    -- 奥能金刚库斯托斯
    -- [281] = {".ogg", 1}, -- 补给协议 (474345)
    -- [286] = {".ogg", 1}, -- 震退猛击 (474496)
    -- [287] = {".ogg", 1}, -- 虚灵枷锁 (1214032)
    [288] = {"XiaoXinJiTui.ogg", 1}, -- 奥术驱除 (1214081)
    -- 瑟拉奈尔·日鞭
    [94]  = {"ShouLingQiangHua.ogg", 1}, -- 加速结界
    [96]  = {"ZhunBeiJinZhaoZiSanErYiJin.ogg", 1}, -- 静默浪潮        
    -- 迪詹崔乌斯
    [420] = {"TanKeChengShangSanMiaoQuSanTanKe.ogg", 1, {TANK = true, HEALER = true}}, -- 庞大碎片  
    [292] = {"ZhunBeiJieQuan.ogg", 1}, -- 不稳定的虚空精华
    [290] = {"ShiErMiaoDuoQiuShiWuMiaoDuoQiuShiBaMiaoDuoQiu.ogg", 1}, -- 贪噬之熵   

    -- 元首阿福扎恩
    [194] = {"ZhaoHuanDaGuai.ogg", 1}, -- [暗影进军] (1262776)
    [195] = {"ZhaoHuanDaGuai.ogg", 1}, -- [暗影进军] (1251361)
    [198] = {"DuoBiBiaoQiang.ogg", 1}, -- [湮灭之怒] (1260712)
    [197] = {"FenTanShangHaiQiMiaoFenTanShangHaiZhuanHuoDaGuai.ogg", 1}, -- [幽影坍缩] (1249265)
    [200] = {"ShouLingKuangBao.ogg", 0}, -- [无尽行军] (1251583)
    -- [201] = {".ogg", 1}, -- [浓暗壁垒] (1255702)    
    -- [492] = {".ogg", 1}, -- [虚弱] (1283069)
    [419] = {"ZhunBeiDianMing.ogg", 1, {DAMAGER = true, HEALER = true}}, -- [虚空标记] (1280015)
    [196] = {"ZhunBeiAOE.ogg", 1, {HEALER = true}}, -- [黑暗颠覆] (1249251)

    -- 弗拉希乌斯
    [133] = {"ZhunBeiJiTuiLiangMiaoSanErYi.ogg", 1}, -- [始源咆哮] (1260046)
    [59]  = {"TanKeChengShangSanErYiShiMiaoTanKeChengShangSanErYi.ogg", 1}, -- [影爪重击] (1241836)
    [60]  = {"TanKeChengShangSanErYiShiMiaoTanKeChengShangSanErYi.ogg", 1}, -- [影爪重击] (1244293)
    [62]  = {"ZhuYiJiaoXia.ogg", 1}, -- [散逸寄生虫] (1254199)
    [61]  = {"ZhunBeiJiGuang.ogg", 0}, -- [虚空吐息] (1243853)

    -- 陨落之王萨哈达尔
    -- [140] = {"ZhunBeiDianMing.ogg", 1}, -- 专制命令 (1260823)
    [143] = {"HuanJingShangHai.ogg", 1, {HEALER = true}}, -- 扭曲遮蔽 (1250686)
    [148] = {"YiShangJieDuan.ogg", 1}, -- 熵能瓦解 (1246175)
    [141] = {"DaDuanDuTiao.ogg", 1, {DAMAGER = true, TANK = true}}, -- 破碎投影 (1254081)
    [142] = {"ZhunBeiDiCi.ogg", 1}, -- 粉碎暮光 (1253911)
    [139] = {"ZhaoHuanXiaoGuai.ogg", 1, {DAMAGER = true, TANK = true}}, -- 虚空融合 (1243453)

    -- 威厄高尔和艾佐拉克
    [103] = {"CengQiu.ogg", 1}, -- 阴霾 (1245391)
    [104] = {"KongJuTuXi.ogg", 1}, -- 亡者吐息 (1244221)
    [105] = {"ZhunBeiAOE.ogg", 1}, -- 午夜烈焰 (1249748)
    -- [221] = {"TanKeChengShang.ogg", 1, TANK = true}, -- 威厄之翼 (1265131)
    -- [220] = {"TanKeChengShang.ogg", 1, TANK = true}, -- 拉克獠牙 (1245645)
    -- [551] = {".ogg", 1}, -- 穿刺 (435193)
    [101] = {"TanKeTuXi.ogg", 1}, -- 虚无光束 (1262623)
    [102] = {"WuMaFenSan.ogg", 1}, -- 虚空嚎叫 (1244917)
    [381] = {"KaoJinZhongChang.ogg", 1}, -- 辐光屏障 (1248847)


    -- 光盲先锋军
    [74]  = {"ZhunBeiPoDun.ogg", 1, {DAMAGER = true}}, -- 圣洁护盾 (1248674)
    [80]  = {"ZhunBeiDuoFeiDun.ogg", 1, {DAMAGER = true, HEALER = true}}, -- 圣洁鸣钟 (1248644)
    [85]  = {"FenTanShangHai.ogg", 1}, -- 处决宣判 (1276368)
    [79]  = {"BaMaFenSan.ogg", 1, {DAMAGER = true, HEALER = true}}, -- 复仇者之盾 (1246485)
    [365] = {"BaMaFenSan.ogg", 1, {DAMAGER = true, HEALER = true}}, -- 复仇者之盾 (1276635)
    [78]  = {"ZhuYiHuanTan.ogg", 1, {TANK = true}}, -- 审判 (1251857)
    [82]  = {"ZhuYiHuanTan.ogg", 1, {TANK = true}}, -- 审判 (1246736)
    [75]  = {"ZhunBeiShuaDun.ogg", 1, {HEALER = true}}, -- 提尔之怒 (1276831)
    [77]  = {"ZhunBeiAOE.ogg", 1, {HEALER = true}}, -- 灼热光辉 (1255738)
    [373] = {"ZhunBeiAOE.ogg", 1, {HEALER = true}}, -- 灼热光辉 (1276639)
    -- [358] = {".ogg", 1}, -- 狂热之魂 (1272380)
    -- [359] = {".ogg", 1}, -- 狂热之魂 (1272423)
    -- [360] = {".ogg", 1}, -- 狂热之魂 (1272425)
    -- [535] = {".ogg", 1}, -- 盲目之光 (428169)
    -- [83] = {".ogg", 1}, -- 神圣风暴 (1246765)
    -- [374] = {".ogg", 1}, -- 神圣风暴 (1272310)
    [84]  = {"ZhunBeiAOE.ogg", 1, {HEALER = true}}, -- 神圣鸣罪 (1246749)
    -- [76]  = {"DuoKaiDaQuan.ogg", 1}, -- 虔诚光环 (1246162)    
    -- [71]  = {"DuoKaiDaQuan.ogg", 1}, -- 平心光环 (1248451)
    -- [81]  = {"DuoKaiDaQuan.ogg", 1}, -- 愤怒光环 (1248449)
    [73]  = {"DuoKaiChongFeng.ogg", 1, {DAMAGER = true, HEALER = true}}, -- 雷象冲锋 (1249130)

    -- 奇美鲁斯，未梦之神
    [118] = {"ZhunBeiAOE.ogg", 1, {HEALER = true}}, -- 不谐咆哮 (1249207)
    [117] = {"DaDuanDuTiao.ogg", 1, {DAMAGER = true, TANK = true}}, -- 可怖战吼 (1249017)
    [307] = {"ZhunBeiAOE.ogg", 1}, -- 吞噬 (1245396)
    [119] = {"QuSanMoFa.ogg", 1, {HEALER = true}}, -- 吞噬瘴气 (1257085)
    [51]  = {"DuoKaiTouQian.ogg", 1}, -- 猛撕开裂 (1272726)
    [53]  = {"ZhunBeiTuXi.ogg", 1}, -- 腐化毁灭 (1245452)
    [458] = {"ZhunBeiTuXi.ogg", 1}, -- 腐化毁灭 (1282856)
    [50]  = {"ZhunBeiAOE.ogg", 1, {HEALER = true}}, -- 腐蚀黏痰 (1246621)
    [149] = {"FenTanShangHai.ogg", 1}, -- 艾林之尘剧变 (1262289)
    [431] = {"FenTanShangHai.ogg", 1}, -- 艾林之尘剧变 (1282001)
    [555] = {"ShouLingQiangHua.ogg", 1}, -- 被吞噬的精华 (1245844)
    [49]  = {"ZhunBeiNeiChang.ogg", 1}, -- 裂隙涌现 (1251021)
    [217] = {"ZhunBeiJiuRen.ogg", 1}, -- 裂隙疯狂 (1268905)
    [48]  = {"ZhunBeiJiFei.ogg", 0}, -- 贪食俯冲 (1245404)

    -- 宇宙之冕
    [15]  = {"ChangDiQieHuan.ogg", 1}, -- 噬灭宇宙 (1238843)
    [8]   = {"ZhuYiDuoQuan.ogg", 1}, -- 奇点喷发 (1235622)
    [12]  = {"ZhunBeiDaDun.ogg", 0, {DAMAGER = true, HEALER = true}}, -- 宇宙屏障 (1246918)
    [66]  = {"ZhunBeiDuanFaLiangMiaoSanErYiAnQuan.ogg", 1, {DAMAGER = true, HEALER = true}}, -- 干扰震荡 (1243743)
    [65]  = {"JinZhanDaQuan.ogg", 1, {DAMAGER = true}}, -- 暴食深渊 (1243753)
    [11]  = {"ZhunBeiYinFengJian.ogg", 1}, -- 游侠队长印记 (1237614)
    [131] = {"ZhunBeiYinFengJian.ogg", 1}, -- 游侠队长印记 (1260010)
    -- [4]   = {"ZhuYiDanShua.ogg", 1, {HEALER = true}}, -- 空无之冕 (1233865)
    [14]  = {"DuoBiBiaoQiang.ogg", 1}, -- 空虚之握 (1232467)
    [132] = {"DuoBiBiaoQiang.ogg", 1}, -- 空虚之握 (1260026)
    [13]  = {"ZhunBeiLaXian.ogg", 1}, -- 终末守护 (1239080)
    [10]  = {"ZhunBeiXiaoGuai.ogg", 1, {DAMAGER = true}}, -- 虚空召唤 (1237837)
    [5]   = {"HeiQiuChuXianDanQiuZhunBeiSanErYiShuangQiuZhunBeiSanErYi.ogg", 1, {HEALER = true}}, -- 虚空斥力 (1233819)
    -- [9]   = {".ogg", 1, HEALER = true}, -- 虚空追猎者钉刺 (1237035)
    [137] = {"TanKeChengShang.ogg", 1, {TANK = true}}, -- 裂隙挥砍 (1246461)
    [7]   = {"SheXian.ogg", 1}, -- 银锋弹幕射击 (1234564)    
    [64]  = {"TanKeJiTui.ogg", 1, {TANK = true}}, -- 黑暗之手 (1233787)

    -- 贝洛朗，奥的子嗣
    [130] = {"ZhunBeiBaoZhu.ogg", 1}, -- 光耀回响 (1242981)
    [494] = {"FenTanShangHai.ogg", 0}, -- 圣光俯冲 (1241292)
    [482] = {"NiShiHuangSe.ogg", 0}, -- 圣光羽毛 (1241162)
    [384] = {"MuBiaoShiNi.ogg", 0}, -- 圣光飞羽 (1241992)
    [497] = {"JieDuanZhuanHuan.ogg", 1}, -- 复生 (1241313)
    [134] = {"TanKeLianJi.ogg", 1, {TANK = true}}, -- 守护者敕令 (1260763)
    [272] = {"ZhunBeiJiFei.ogg", 2}, -- 死亡坠落 (1246709)
    [138] = {"ZhuYiDanShua.ogg", 1, {HEALER = true}}, -- 永恒灼烧 (1244344)
    -- [161] = {"ZhuYiSheXian.ogg", 1, {DAMAGER = true, HEALER = true}}, -- 注能飞羽 (1242260)
    -- [273] = {".ogg", 1}, -- 烈焰孵化 (1242792)
    [218] = {"ZhunBeiAOELiangMiaoSanErYi.ogg", 2}, -- 虚光汇流 (1242515)
    [495] = {"FenTanShangHai.ogg", 0}, -- 虚空俯冲 (1241339)
    [483] = {"NiShiLanSe.ogg", 0}, -- 虚空羽毛 (1241163)
    [385] = {"MuBiaoShiNi.ogg", 0}, -- 虚空飞羽 (1242091)
    [128] = {"FenTanShangHai.ogg", 1}, -- 贝洛朗的燃烬 (1241282)

    -- 至暗之夜降临    
    [632] = {"MiaoZhunHeiQiu.ogg", 0}, -- 充电 (1284525)
    [259] = {"JieDuanZhuanHuan.ogg", 1}, -- 全蚀 (1261871)
    [261] = {"XiHeiQiu.ogg", 1}, -- 圣光虹吸 (1266897)
    [364] = {"TanKeChengShang.ogg", 1, {TANK = true}}, -- 天穹之枪 (1267049)
    [256] = {"DuoKaiZhanRen.ogg", 1}, -- 天穹战刃 (1253915)
    [257] = {"ZhunBeiHuWeiDaDuanHuWeiZhuanHuoShuiJing.ogg", 1}, -- 护卫棱镜 (1251386)
    -- [434] = {".ogg", 1}, -- 宇宙裂变 (1282249)
    -- [363] = {".ogg", 1}, -- 断离 (1276202)
    [437] = {"SheXianDianNi.ogg", 0}, -- 星辰裂片 (1282441)
    [435] = {"DuoKaiLianXian.ogg", 1}, -- 核心收割 (1282412)
    -- [362] = {".ogg", 1}, -- 死亡安魂曲 (1273158)    
    [255] = {"FuWenDianNi.ogg", 0}, -- 死亡挽歌 (1244412)
    [433] = {"JieDuanZhuanHuan.ogg", 1}, -- 深入黑暗之井 (1282047)
    -- [258] = {".ogg", 1}, -- 破碎天空 (1249796)
    -- [636] = {".ogg", 1}, -- 终结棱柱 (1284931)
    -- [260] = {".ogg", 1}, -- 至暗之夜 (1266622)
    -- [405] = {".ogg", 1}, -- 蚀盛 (1237690)
    [263] = {"KuaiJinZhaoZiQiMiaoKuaiPao.ogg", 1}, -- 黑暗天使长 (1250898)
    [262] = {"DuoKaiXingZuo.ogg", 1}, -- 黑暗星座 (1266388)
    [436] = {"JieDuanZhuanHuan.ogg", 1}, -- 黑暗熔毁 (1281194)
    -- [650] = {"FuWenDianNi.ogg", 0}, -- 黑暗符文 (1249609)
    [649] = {"ZhuYiSheXian.ogg", 1}, -- 黑暗类星体 (1279420)
    -- [644] = {".ogg", 1}, -- 黯灭协奏 (1284980)
}
local EventSoundData2 = {  
    [241] = {"TieBianFangShuiSanMiaoSanErYi.ogg", 0}, -- 炽焰腾流    
    -- 元首阿福扎恩 
    [199] = {"ZhunBeiJiTuiShiYiMiaoZhuYiDuoQuan.ogg", 2}, -- [虚空坠落] (1258880)
    [209] = {"ZhunBeiJiTuiShiYiMiaoZhuYiDuoQuan.ogg", 2}, -- [虚空坠落] (1266786)
    -- 弗拉希乌斯
    [62]  = {"ZhiLiaoYuPu.ogg", 2, {HEALER = true}}, -- 散逸寄生虫 (1254199)
    -- 陨落之王萨哈达尔
    [148] = {"ZhunBeiYiShang.ogg", 2}, -- 熵能瓦解 (1246175)
    -- 威厄高尔和艾佐拉克
    [102] = {"ZhunBeiXiaoGuai.ogg", 2}, -- 虚空嚎叫 (1244917)    
    [103] = {"ZhunBeiCengQiuSanErYi.ogg", 2}, -- 阴霾 (1245391)
    [104] = {"ZhunBeiKongJuLiangMiaoSanErYi.ogg", 2}, -- 亡者吐息 (1244221)
    -- 光盲先锋军
    [78]  = {"ZhunBeiShenPanSanErYi.ogg", 2, {TANK = true}}, -- 审判 (1251857)
    [82]  = {"ZhunBeiShenPanSanErYi.ogg", 2, {TANK = true}}, -- 审判 (1246736)
    [84]  = {"ZhiLiaoYuPu.ogg", 2, {HEALER = true}}, -- 神圣鸣罪 (1246749)     
    [76]  = {"TanKeDaiWei.ogg", 2, {TANK = true}}, -- 虔诚光环 (1246162)
    [71]  = {"TanKeDaiWei.ogg", 2, {TANK = true}}, -- 平心光环 (1248451)
    [81]  = {"TanKeDaiWei.ogg", 2, {TANK = true}}, -- 愤怒光环 (1248449)
    -- 宇宙之冕
    [5]   = {"ZhunBeiHeiQiu.ogg", 2}, -- 虚空斥力 (1233819)
    [6]   = {"ZhunBeiYinFengJian.ogg", 2}, -- 银锋箭 (1233602)
    [13]  = {"ZhiLiaoYuPu.ogg", 2, {HEALER = true}}, -- 终末守护 (1239080)
    -- 奇美鲁斯，未梦之神
    -- [307] = {"ZhunBeiAOE.ogg", 2, {HEALER = true}}, -- 吞噬 (1245396)
    [49]  = {"ZhiLiaoYuPu.ogg", 2, {HEALER = true}}, -- 裂隙涌现 (1251021)
    [119] = {"ZhunBeiDianMing.ogg", 2}, -- 吞噬瘴气 (1257085)
    -- 至暗之夜降临
    [255] = {"ZhunBeiFuWenLiangMiaoSanErYi.ogg", 2}, -- 死亡挽歌 (1244412)
    [632] = {"ZhunBeiSheQiu.ogg", 2}, -- 充电 (1284525)
    [435] = {"ZhiLiaoYuPu.ogg", 2, {HEALER = true}}, -- 核心收割 (1282412)
    -- [632] = {"ZhiLiaoYuPu.ogg", 2, {HEALER = true}}, -- 充电 (1284525)
    -- 贝洛朗，奥的子嗣
    [218] = {"ZhiLiaoYuPu.ogg", 2, {HEALER = true}}, -- 虚光汇流 (1242515)
}
local startTime = 0
local currentEncounterID = 0
local lastPlayedSecond = -1
local isAuraRegistered = false

local function RegisterPrivateAuras()
    if isAuraRegistered then return end
    if not (C_UnitAuras and C_UnitAuras.AddPrivateAuraAppliedSound) then return end

    for spellID, soundFile in pairs(PrivateAuraList) do
        C_UnitAuras.AddPrivateAuraAppliedSound({
            unitToken = "player",
            spellID = spellID,
            soundFileName = MEDIA_PATH .. soundFile .. ".ogg", 
            outputChannel = "Master",
        })
    end
    isAuraRegistered = true    
end

-- 职责/专精 检查函数
local function CanPlayerHear(req)
    if not req then return true end
    
    local specIndex = GetSpecialization()
    if not specIndex then return false end
    
    local _, _, _, _, role = GetSpecializationInfo(specIndex)
    local specID = GetSpecializationInfo(specIndex)
    if type(req) == "table" then
        for _, r in ipairs(req) do
            if r == role or r == specID then return true end
        end
    -- 如果要求是字符串(职责)或数字(专精ID)
    else
        if req == role or req == specID then return true end
    end
    
    return false
end

-- 获取当前玩家职责
local function GetPlayerRole()
    local specIndex = GetSpecialization()
    if specIndex then
        local _, _, _, _, role = GetSpecializationInfo(specIndex)
        return role
    end
    return "NONE"
end


local function ProcessAlert(alert, debugSource, actualLevel, currentMapID, unitTarget)
    if not alert then return end
    
    local reqLevel = type(alert) == "table" and alert.unitLevel or nil
    local reqMapID = type(alert) == "table" and alert.mapID or nil
    
    -- 提取文件名或表（用于打印）
    local alertFile = type(alert) == "table" and alert.file or alert
    local displayTitle = type(alertFile) == "table" and alertFile[1] or alertFile

    -- 【关键修改点：通用的匹配函数】
    local function CheckMatch(required, actual)
        if not required then return true end -- 如果配置没写，默认匹配成功
        if type(required) == "table" then
            for _, val in ipairs(required) do
                if val == actual then return true end
            end
            return false
        end
        return required == actual -- 如果是单个值，直接对比
    end
    -- 调试 1：开始检查某条具体配置
    -- print(string.format("|cff00ffff[检查配置]|r %s | 需要Level:%s, 需要Map:%s", displayTitle, tostring(reqLevel), tostring(reqMapID)))

    -- 使用新逻辑进行匹配
    local levelMatch = CheckMatch(reqLevel, actualLevel)
    local mapMatch = CheckMatch(reqMapID, currentMapID)

    if levelMatch and mapMatch then        
        local fileName
        if type(alertFile) == "table" then
            unitCastTracker[unitTarget] = (unitCastTracker[unitTarget] or 0) + 1
            local index = ((unitCastTracker[unitTarget] - 1) % #alertFile) + 1
            fileName = alertFile[index]
            
            -- print(string.format("|cff00ff00[循环计数]|r 次数:%d, 播放索引:%d, 文件:%s", unitCastTracker[unitTarget], index, fileName))
        else
            fileName = alertFile
        end

        if fileName and CanPlayerHear(alert.role) then
            PlaySoundFile(MEDIA_PATH .. fileName, "Master")
        end
    else
        -- 调试 3：匹配失败的原因
        local reason = ""
        if not levelMatch then reason = reason .. "等级不对(目标" .. actualLevel .. ") " end
        if not mapMatch then reason = reason .. "地图ID不对(目标" .. currentMapID .. ") " end
        -- print("|cffffd100[跳过条目]|r " .. displayTitle .. " | 原因: " .. reason)
    end
end

local function OnUpdate()
    if startTime == 0 then return end
    local now = GetTime()
    local elapsed = math.floor(now - startTime)
    if elapsed < 0 or elapsed == lastPlayedSecond then return end
    lastPlayedSecond = elapsed
    
    local bossData = AudioTimeline[currentEncounterID]
    if bossData then
        local relativeTime = now - startTime - bossData.startOffset
        if relativeTime >= 0 then
            local moduloTime = relativeTime % bossData.interval
            for triggerTime, alert in pairs(bossData.alerts) do
                if moduloTime >= triggerTime and moduloTime < (triggerTime + 0.8) then
                    ProcessAlert(alert, "Timeline:"..triggerTime)
                    StartMyCircleTimer(alert)
                    break 
                end
            end
        end
    end
end

local function ApplyTimelineSounds()
    local count = 0
    local playerRole = GetPlayerRole()

    local function ClearTimelineSounds(dataTable)
        if not dataTable then return end
        for eventID, config in pairs(dataTable) do
            local triggerType = config[2]
            -- 将该 ID 的声音配置设为 nil 即为卸载
            C_EncounterEvents.SetEventSound(eventID, triggerType, nil)
        end
    end

    -- 1. 定义一个内部的处理函数
    local function registerTable(dataTable)
        if not dataTable then return end
        
        for eventID, config in pairs(dataTable) do
            local fileName = config[1]
            local triggerType = config[2]
            local roleConfig = config[3]
            
            local isMatch = false
            
            -- 过滤逻辑
            if roleConfig == nil then
                isMatch = true
            elseif type(roleConfig) == "table" then
                if roleConfig[playerRole] then
                    isMatch = true
                end
            elseif type(roleConfig) == "string" then
                if roleConfig == playerRole then
                    isMatch = true
                end
            end

            -- 执行注册
            if isMatch then
                C_EncounterEvents.SetEventSound(eventID, triggerType, {
                    file = MEDIA_PATH .. fileName, 
                    channel = "Master", 
                    volume = 1
                })
                count = count + 1
            end
        end
    end
    -- 2. 先执行清空（重置所有 ID）
    ClearTimelineSounds(EventSoundData)
    ClearTimelineSounds(EventSoundData2)
    -- 2. 分别调用两个表
    registerTable(EventSoundData)
    registerTable(EventSoundData2)
    -- print("已根据职责成功加载 " .. count .. " 个语音事件")
end

local function GetTopWidgetText()
    local container = UIWidgetTopCenterContainerFrame
    if not container or not container.widgetFrames then return nil end

    for _, widget in pairs(container.widgetFrames) do
        -- 截图显示它有一个 .Text 属性
        if widget.Text and widget.Text:GetText() then           
            return widget.Text:GetText()
        end
    end
    return nil
end

-- local function FindBestVoice()
--     local ttsVoices = C_VoiceChat.GetTtsVoices()
    
--     for _, v in ipairs(ttsVoices) do
--         -- 示例：寻找中文（Huihui）或者特定风格的声音
--         if v.name:find("Huihui") then
--             return v.voiceID
--         end
--     end
    
--     -- 如果没找到，返回默认的第一个
--     return ttsVoices[1] and ttsVoices[1].voiceID
-- end

-- 假设在插件加载或某个触发点执行
-- local function StartTTSInitialization()
--     MyTTSDict.isSampling = true
--     MyTTSDict.sampleIndex = 0
    
--     -- 1秒后读第一个
--     C_Timer.After(10, function()
--         MyTTSDict.sampleIndex = 1        
--         C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), "冰霜猛袭", 10, C_TTSSettings.GetSpeechVolume(), true)
--         -- C_VoiceChat.SpeakText(FindBestVoice(), "852826", 10, C_TTSSettings.GetSpeechVolume(), true)
--     end)
    
--     -- 2秒后读第二个
--     C_Timer.After(12, function()
--         MyTTSDict.sampleIndex = 2
--         C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), "黑暗裂口", 10, C_TTSSettings.GetSpeechVolume(), true)
--         -- C_VoiceChat.SpeakText(FindBestVoice(), "4667427", 10, C_TTSSettings.GetSpeechVolume(), true)
--     end)
    
--     -- 3秒后关闭采样模式（防止后续正常使用TTS时误触发赋值）
--     C_Timer.After(14, function()
--         MyTTSDict.isSampling = false
--         print("TTS 技能指纹预存完成")
--     end)
-- end

-- 核心比对逻辑函数
local function ExecuteClosestLogic(measuredTime, sound1, sound2)
    local diff1 = math.abs(measuredTime - MyTTSDict.skill1Time)
    local diff2 = math.abs(measuredTime - MyTTSDict.skill2Time)
    
    if diff1 < diff2 and diff1 < MyTTSDict.tolerance and MyTTSDict.isSampled == true then
        -- print(string.format("技能 1 实际耗时: %.3f 秒", measuredTime))
        -- print("识别为：技能1 逻辑执行")
        PlaySoundFile(MEDIA_PATH .. sound1, "Master")
        -- 执行技能1逻辑
    elseif diff2 < diff1 and diff2 < MyTTSDict.tolerance and MyTTSDict.isSampled == true then
        -- print(string.format("技能 2 实际耗时: %.3f 秒", measuredTime))
        -- print("识别为：技能2 逻辑执行")
        if sound2 == "TanKeJianCi.ogg" then
            local PlayerRole = GetPlayerRole()
            if PlayerRole ~= "TANK" and PlayerRole ~= "HEALER" then
                return -- 关键点：非坦奶直接闭嘴，不再往下走
            end
        end
        PlaySoundFile(MEDIA_PATH .. sound2, "Master")
        -- 执行技能2逻辑
    else
        -- print("无法识别，误差过大")
    end
end
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")
frame:RegisterEvent("ENCOUNTER_START")
frame:RegisterEvent("ENCOUNTER_END")
frame:RegisterEvent("ENCOUNTER_WARNING")
frame:RegisterEvent("CLEAR_BOSS_EMOTES")
frame:RegisterEvent("ENCOUNTER_WARNING")
frame:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_ADDED")
frame:RegisterEvent("ENCOUNTER_TIMELINE_EVENT_BLOCK_STATE_CHANGED")
frame:RegisterEvent("RAID_BOSS_EMOTE")
frame:RegisterEvent("RAID_BOSS_WHISPER")
frame:RegisterEvent("UNIT_SPELLCAST_START")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_INDOORS")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
frame:RegisterEvent("UNIT_SPELLCAST_STOP")
frame:RegisterEvent("VOICE_CHAT_TTS_PLAYBACK_STARTED")
frame:RegisterEvent("VOICE_CHAT_TTS_PLAYBACK_FINISHED")
frame:RegisterEvent("LOADING_SCREEN_DISABLED")
frame:RegisterEvent("BOSS_KILL")

-- frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ENCOUNTER_START" then
        local encounterID = ...
        encounterUnitTriggerCount = 0
        currentEncounterID = encounterID
        startTime = GetTime()
        lastPlayedSecond = -1
        frame:SetScript("OnUpdate", OnUpdate)
        -- 延迟 0.01 秒执行
        C_Timer.After(0.01, function()
            ApplyTimelineSounds()
        end)
        -- print("|cFF00FF00[神秘地瓜副本语音插件]|r 已加载")
    elseif event == "ENCOUNTER_END" then
        startTime = 0
        currentEncounterID = 0
        frame:SetScript("OnUpdate", nil)
        -- print("|cFF00FF00[TimelineAudio]|r 战斗结束")
        return

    elseif event == "BOSS_KILL" then
        local encounterID = ...
        if encounterID == 3072 then
            BOSS_KILL_3072 = true
            return
        end        
    elseif event == "VOICE_CHAT_TTS_PLAYBACK_STARTED" then
        ttsStartTime = GetTime() -- 记录当前精确时间
        return
    elseif event == "VOICE_CHAT_TTS_PLAYBACK_FINISHED" then
        -- ttsDuration = GetTime() - ttsStartTime
        -- print(ttsDuration)
        -- 如果开关没开，说明这次 TTS 播放不是由我们的插件触发的，直接拦截
        -- if not MyTTSDict.isListening then return end
        ttsDuration = GetTime() - ttsStartTime
        -- 仅在采样模式下进行赋值
        if MyTTSDict.isSampled == false then
            if MyTTSDict.sampleIndex == 1 then
                MyTTSDict.skill1Time = ttsDuration
                -- print(string.format("技能 1 采样完成: %.3f 秒", ttsDuration))
            elseif MyTTSDict.sampleIndex == 2 then
                MyTTSDict.skill2Time = ttsDuration
                -- print(string.format("技能 2 采样完成: %.3f 秒", ttsDuration))
                MyTTSDict.isSampled = true
                MyTTSDict.sampleIndex = 0
                -- print("TTS 技能指纹预存完成")
            end
        else
            local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID = GetInstanceInfo()
            local subZone = GetSubZoneText()
            local currentMapID = C_Map.GetBestMapForUnit("player") or 0
            if instanceID == 658 and not C_CombatAudioAlert.IsEnabled() then 
                ExecuteClosestLogic(ttsDuration, "ZhuYiDuoQuan.ogg", "TanKeJianCi.ogg")
            end
            if instanceID == 2805 and currentMapID == 2498 and subZone == "幽灵悲歌" then 
                ExecuteClosestLogic(ttsDuration, "DuoKaiChongFeng.ogg", "ZhunBeiChenMo.ogg")
            end
            if instanceID == 2526 and currentMapID == 2098 and subZone == "体育场" then 
                ExecuteClosestLogic(ttsDuration, "DuoKaiTouQian.ogg", "ZhunBeiJiNuSanMiaoJiNu.ogg")
            end
        end
        return
    elseif event == "PLAYER_REGEN_ENABLED" then
        wipe(unitCastTracker) 
        return
    elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_STOP" then
        local unitTarget = ...
        if unitTarget == "player" then
            UpdateRingColor(false)
        end
    --     -- 获取该 unit 对应的姓名板框架
    --     local nameplate = C_NamePlate.GetNamePlateForUnit(unitTarget)
        
    --     if nameplate then
    --         -- 如果之前没创建过文字，就创建一个
    --         if not nameplate.BigText then
    --             nameplate.BigText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    --             -- 设置字体、大小、描边 (参数：路径, 大小, 描边)
    --             nameplate.BigText:SetFont(STANDARD_TEXT_FONT, 80, "OUTLINE")
    --             nameplate.BigText:SetPoint("BOTTOM", nameplate, "TOP", 0, 10)
    --             nameplate.BigText:SetTextColor(1, 0, 0) -- 红色
    --         end
            
    --         -- 设置文字内容并显示
    --         nameplate.BigText:SetText("快断！！！")
    --         nameplate.BigText:Show()
            
    --         -- (可选) 3秒后自动隐藏
    --         C_Timer.After(3, function() 
    --             if nameplate.BigText then nameplate.BigText:Hide() end 
    --         end)
    --     end
    --     return
    elseif event == "UNIT_AURA" then
        local unitTarget = ...
        local subZone = GetSubZoneText()
        local keyLevel = C_ChallengeMode.GetActiveKeystoneInfo()
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "风行者宝库" and keyLevel >= 12 then
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)
                local auraData2 = C_UnitAuras.GetAuraDataByIndex(unitTarget, 2, "HELPFUL") 
                local auraData3 = C_UnitAuras.GetAuraDataByIndex(unitTarget, 3, "HELPFUL") 
                local auraCheck = false
                if Lindormi == false then
                    auraCheck = auraData2
                else
                    auraCheck = auraData3
                end
                if actualLevel == NEXT_PLAYER_LEVEL and currentMapID == 2498 and unitPowerType == 0 and auraCheck then
                    if not auraTriggeredCache[unitTarget] then
                        PlaySoundFile(MEDIA_PATH .. "JiNu.ogg", "Master")
                        auraTriggeredCache[unitTarget] = true
                    end
                    return
                end
            end                
        end
        return
    elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
        local subZone = GetSubZoneText()
        if subZone == "四角庭院" and not hasPlayedSiJiaoTingYuan then
            PlaySoundFile(MEDIA_PATH .. "XuanZeZengYi.ogg", "Master")
            hasPlayedSiJiaoTingYuan = true
        end
        return

    elseif event == "NAME_PLATE_UNIT_ADDED" then
        local unit = ...  
        if unit and unit:find("nameplate") and UnitCanAttack("player", unit) then
            local currentMapID = C_Map.GetBestMapForUnit("player") or 0
            local keyLevel = C_ChallengeMode.GetActiveKeystoneInfo()
            if currentMapID == 184 and keyLevel >= 12 then                   
                local actualLevel = UnitLevel(unit)
                local classification = UnitClassification(unit)
                local unitPowerType = UnitPowerType(unit)   
                local sex = UnitSex(unit)
                local auraData = C_UnitAuras.GetAuraDataByIndex(unit, 3, "HELPFUL")                 
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 1 and classification == "elite" and sex == 2 and auraData then     
                    Lindormi = true
                    return
                end
            end         
        end
        if unit and unit:find("nameplate") and UnitCanAttack("player", unit) then
            local currentMapID = C_Map.GetBestMapForUnit("player") or 0
            local subZone = GetSubZoneText()
            local keyLevel = C_ChallengeMode.GetActiveKeystoneInfo()
            if currentMapID == 2492 and subZone == "幽灵悲歌" and keyLevel >= 12 then                   
                local actualLevel = UnitLevel(unit)
                local classification = UnitClassification(unit)
                local unitPowerType = UnitPowerType(unit)   
                local sex = UnitSex(unit)
                local auraData = C_UnitAuras.GetAuraDataByIndex(unit, 2, "HELPFUL")                 
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 0 and classification == "elite" and sex == 2 and auraData then     
                    Lindormi = true
                    return
                end
            end         
        end

    elseif event == "UNIT_SPELLCAST_START" then
        -- print("当前机制文字: " .. (GetTopWidgetText() or "没找到"))
        -- UnitAffectingCombat(unit)
        local unitTarget = ...
        local subZone = GetSubZoneText()   
        local alerts = LocationCastData[subZone]
        local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unitTarget)
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        local maxRange = C_Spell.GetSpellInfo(spellID).maxRange
        -- -- 获取事件信息
        -- local eventID = 66
        -- local info = C_EncounterEvents.GetEventInfo(eventID)

        -- if info then
        --     print("|cffffd100[Debug] 事件 " .. eventID .. " 数据详情:|r")
            
        --     -- 文本类
        --     print("文本 (text):", info.text)
        --     print("施法者 (casterName):", info.casterName)
        --     print("目标 (targetName):", info.targetName)
            
        --     -- GUID
        --     print("施法者GUID:", info.casterGUID)
        --     print("目标GUID:", info.targetGUID)
            
        --     -- 数字/ID
        --     print("图标文件ID (iconFileID):", info.iconFileID)
        --     print("技能ID (tooltipSpellID):", info.tooltipSpellID)
        --     print("持续时间 (duration):", info.duration)
        --     print("严重程度 (severity):", info.severity)
            
        --     -- 布尔值 (使用 tostring 强制显示 true/false/nil)
        --     print("是否致命 (isDeadly):", tostring(info.isDeadly))
        --     print("播放声音 (shouldPlaySound):", tostring(info.shouldPlaySound))
        --     print("聊天框消息 (shouldShowChatMessage):", tostring(info.shouldShowChatMessage))
        --     print("显示警告 (shouldShowWarning):", tostring(info.shouldShowWarning))
            
        --     -- 颜色处理
        --     if info.color then
        --         print("颜色 (RGB):", info.color.r, info.color.g, info.color.b)
        --     else
        --         print("颜色: nil")
        --     end
        -- else
        --     print("|cffff0000[Error] 无法获取事件 " .. eventID .. " 的信息，请确认 ID 是否正确。|r")
        -- end



        -- -- 检查是否有在读条
        -- if name then
        --     print("--- 施法详情 ---")
        --     print("1. 技能名称 (name):", name)
        --     print("2. 进度条文字 (text):", text)
        --     print("3. 图标路径 (texture):", texture)
        --     print("4. 开始时间 (startTimeMS):", startTimeMS) -- 绝对时间(毫秒)
        --     print("5. 结束时间 (endTimeMS):", endTimeMS)     -- 绝对时间(毫秒)
        --     print("6. 专业制造 (isTradeSkill):", isTradeSkill)
        --     print("7. 施法唯一ID (castID):", castID)
        --     print("8. 不可打断 (notInterruptible):", notInterruptible)
        --     print("9. 技能ID (spellID):", spellID)

        -- end

        if unitTarget == "player" and endTimeMS and CurrentRingIsCastSensitive then
            local castEndTime = endTimeMS / 1000
            -- 如果玩家读条结束时间 晚于 圆环结束时间
            if castEndTime > TargetEndTime then
                UpdateRingColor(true)
            else
                UpdateRingColor(false)
            end
        end
        -- if not C_CombatAudioAlert.IsEnabled() then C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), spellName, 1, C_TTSSettings.GetSpeechVolume()) end

        -- local modelFrame = CreateFrame("PlayerModel")

        -- local currentMapID = C_Map.GetBestMapForUnit("player") or 0  
        -- local name = UnitName(unitTarget) or "未知"
        -- local actualLevel = UnitLevel(unitTarget)
        -- local classification = UnitClassification(unitTarget)
        -- local unitPowerType = UnitPowerType(unitTarget)   
        -- local sex = UnitSex(unitTarget)
        -- local isInside = IsIndoors()
        -- local classInfo = { UnitClass(unitTarget) }
        -- local className = classInfo[2]
        -- local auraData = C_UnitAuras.GetAuraDataByIndex(unitTarget, 2, "HELPFUL") 
        -- local inCombat = UnitAffectingCombat(unitTarget)
        -- local spellHastePercent = UnitSpellHaste(unitTarget)
        -- local keyLevel = C_ChallengeMode.GetActiveKeystoneInfo()
        -- local creatureFamily, familyID = UnitCreatureFamily(unitTarget)
        -- local maxhealthMod = GetUnitMaxHealthModifier(unitTarget)
        -- local raceID = UnitRace(unitTarget)
        -- print(maxhealthMod)
        -- C_Timer.After(0.1, function()
        --     modelFrame:SetUnit(unitTarget) 
        --     local modelFileID = modelFrame:GetModelFileID()
        --     print("当前目标的模型 ID 为: " .. (modelFileID or "未知"))
        -- end)        
        

        -- print(name .. " | 等级: " .. actualLevel .. " | 区域: " .. subZone .. " | 地图ID: ".. currentMapID .. " | 分类: " .. classification .. " | 能量类型: " .. unitPowerType .. " | 性别: " .. sex .. " | 室内: " .. tostring(isInside) .. " | 职业: " .. className .. " | 存在两个增益: " .. (auraData and "是" or "否") .. " | 法术加速: " .. spellHastePercent .. " | 生物家族: " .. tostring(creatureFamily))
        
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "下层平台" or subZone == "主峰" then
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)   
                local creatureFamily, familyID = UnitCreatureFamily(unitTarget)
                if not creatureFamily and actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 1 and sex == 1 then
                    UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1
                    local currentCount = UNIT_CAST_TRACKER[unitTarget]
                    if currentCount % 2 == 1 then
                        local PlayerRole = GetPlayerRole()
                        if PlayerRole == "TANK" or PlayerRole == "HEALER" then
                            PlaySoundFile(MEDIA_PATH .. "TanKePoJia.ogg", "Master")
                            if PlayerRole == "TANK" then
                                StartCircleTimerBySeconds(3)
                            end                                
                        end
                    else
                        PlaySoundFile(MEDIA_PATH .. "MeiYouYinPin.ogg", "Master")
                    end
                else
                    -- print("|cffffa500[DEBUG]|r 条件未达成，不执行声音切换。")
                end            
            end
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "下层平台" or subZone == "主峰" then 
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget) 
                local creatureFamily, familyID = UnitCreatureFamily(unitTarget)                
                if creatureFamily and actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 1 and sex == 1 then
                    UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1        
                    if UNIT_CAST_TRACKER[unitTarget] % 2 == 1 then
                        PlaySoundFile(MEDIA_PATH .. "MeiYouYinPin.ogg", "Master")
                    else
                        PlaySoundFile(MEDIA_PATH .. "ZhunBeiAOE.ogg", "Master")
                    end
                    return
                end            
            end
        end
        
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "主峰" then
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
                local actualLevel = UnitLevel(unitTarget)
                local isInside = IsIndoors()
                local sex = UnitSex(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)
                if isInside == false and actualLevel == NEXT_PLAYER_LEVEL and currentMapID == 601 and unitPowerType == 0 and sex == 1 then
                    C_Timer.After(1.9, function()
                        PlaySoundFile(MEDIA_PATH .. "ZhuanHuoBaoZhu.ogg", "Master")
                    end)
                    return
                end
            end               
        end

        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "主峰" then
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                local isInside = IsIndoors()

                if actualLevel == NEXT_PLAYER_LEVEL and currentMapID == 601 and unitPowerType == 0 and sex == 1 and isInside == true then
                    -- 计数器递增
                    UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1        
                    local step = UNIT_CAST_TRACKER[unitTarget] % 3
                    local PlayerRole = GetPlayerRole()
                    if step == 1 then                        
                        if PlayerRole == "DAMAGER" or PlayerRole == "HEALER" then
                            PlaySoundFile(MEDIA_PATH .. "ZhuYiDianMing.ogg", "Master")
                        end                        
                    elseif step == 2 then
                        -- 技能 2
                        PlaySoundFile(MEDIA_PATH .. "JinZhanDaQuan.ogg", "Master")
                    else
                        if PlayerRole == "DAMAGER" or PlayerRole == "HEALER" then
                            PlaySoundFile(MEDIA_PATH .. "ZhuYiDianMing.ogg", "Master")
                        end      
                    end
                    
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "主峰" then
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
                local actualLevel = UnitLevel(unitTarget)
                local isInside = IsIndoors()
                local sex = UnitSex(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)
                if isInside == true and actualLevel == NEXT_PLAYER_LEVEL and currentMapID == 602 and unitPowerType == 0 and sex == 1 then
                    C_Timer.After(1.9, function()
                        PlaySoundFile(MEDIA_PATH .. "ZhuanHuoBaoZhu.ogg", "Master")
                    end)
                    return
                end
            end               
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            local currentMapID = C_Map.GetBestMapForUnit("player") or 0
            local keyLevel = C_ChallengeMode.GetActiveKeystoneInfo()
            if currentMapID == 184 and keyLevel >= 12 then                   
                local actualLevel = UnitLevel(unitTarget)
                local classification = UnitClassification(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)   
                local auraData = C_UnitAuras.GetAuraDataByIndex(unitTarget, 3, "HELPFUL") 
                local sex = UnitSex(unitTarget)
                if actualLevel == PLAYER_LEVEL and unitPowerType == 0 and classification == "elite" and auraData and sex == 2 then                    
                    PlaySoundFile(MEDIA_PATH .. "XuKongBaoFa.ogg", "Master")
                    return
                end
            end         
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            local currentMapID = C_Map.GetBestMapForUnit("player") or 0
            local keyLevel = C_ChallengeMode.GetActiveKeystoneInfo()
            if currentMapID == 184 and keyLevel >= 12 and Lindormi == false then                   
                local actualLevel = UnitLevel(unitTarget)
                local classification = UnitClassification(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)   
                local sex = UnitSex(unitTarget)
                local auraData = C_UnitAuras.GetAuraDataByIndex(unitTarget, 2, "HELPFUL") 
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 1 and classification == "elite" and sex == 2 and auraData then                    
                    -- local castInfo = { UnitCastingInfo(unitTarget) }
                    -- local spellName = castInfo[1]
                    local PlayerRole = GetPlayerRole()
                    if PlayerRole == "TANK" or PlayerRole == "DAMAGER" then
                        PlaySoundFile(MEDIA_PATH .. "HanBingChongJi.ogg", "Master")
                    end                    
                    -- if not C_CombatAudioAlert.IsEnabled() then C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), spellName, 1, C_TTSSettings.GetSpeechVolume()) end
                    return
                end
            end         
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            local currentMapID = C_Map.GetBestMapForUnit("player") or 0
            local keyLevel = C_ChallengeMode.GetActiveKeystoneInfo()
            if currentMapID == 184 and keyLevel >= 12 then 
                local actualLevel = UnitLevel(unitTarget)
                local classification = UnitClassification(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)   
                local sex = UnitSex(unitTarget)
                local auraData2 = C_UnitAuras.GetAuraDataByIndex(unitTarget, 2, "HELPFUL") 
                local auraData3 = C_UnitAuras.GetAuraDataByIndex(unitTarget, 3, "HELPFUL") 
                local auraCheck = false
                if Lindormi == false then
                    auraCheck = not auraData2
                else
                    auraCheck = not auraData3
                end
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 1 and classification == "elite" and sex == 2 and auraCheck then 
                    -- UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1    
                    -- print(maxRange)
                    C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), maxRange, 10, 0, true)   
                    -- local castInfo = { UnitCastingInfo(unitTarget) }
                    -- local spellName = castInfo[1]
                    -- if not C_CombatAudioAlert.IsEnabled() then C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), spellName, 1, C_TTSSettings.GetSpeechVolume()) end
                end
            end         
        end

        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "" then
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                local isInside = IsIndoors()
                if actualLevel == NEXT_PLAYER_LEVEL and (currentMapID == 2097 or currentMapID == 2098) and unitPowerType == 1 and sex == 1 and isInside == false then
                    UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1        
                    if UNIT_CAST_TRACKER[unitTarget] % 2 == 1 then
                        PlaySoundFile(MEDIA_PATH .. "DuoKaiDaQuan.ogg", "Master")
                    else
                        PlaySoundFile(MEDIA_PATH .. "ZhuYiTouQian.ogg", "Master")
                    end
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "体育场" then
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
                local actualLevel = UnitLevel(unitTarget)
                if actualLevel == NEXT_PLAYER_LEVEL and currentMapID == 2098 then
                    C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), name, 10, 0, true)
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "" or subZone == "首席教师之地" then
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                if actualLevel == NEXT_PLAYER_LEVEL and currentMapID == 2097 and unitPowerType == 1 and sex == 3 then
                    PlaySoundFile(MEDIA_PATH .. "ZhunBeiAOE.ogg", "Master")
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "" then
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                if actualLevel == NEXT_PLAYER_LEVEL and currentMapID == 2501 and unitPowerType == 1 and sex == 1 then
                    UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1        
                    if UNIT_CAST_TRACKER[unitTarget] % 2 == 1 then
                        local PlayerRole = GetPlayerRole()
                        if PlayerRole == "TANK" or PlayerRole == "HEALER" then
                            PlaySoundFile(MEDIA_PATH .. "TanKeLiuXue.ogg", "Master")
                        end
                    else
                        PlaySoundFile(MEDIA_PATH .. "ZhunBeiChenMoSanDianWuMiaoAnQuan.ogg", "Master")
                        StartCircleTimerBySeconds(3.5, true)
                    end
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            local currentMapID = C_Map.GetBestMapForUnit("player") or 0     
            if currentMapID == 184 then                   
                local actualLevel = UnitLevel(unitTarget)
                local classification = UnitClassification(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                local isInside = IsIndoors()
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 1 and classification == "elite" and sex == 1 and isInside == false then
                    PlaySoundFile(MEDIA_PATH .. "LingDianWuMiaoDuoKaiTouQian.ogg", "Master")
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "影卫入侵营地" then    
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                local currentText = GetTopWidgetText() or ""
                if currentText:find("关闭虚空裂隙") then    
                    if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 1 and sex == 1 then
                        UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1        
                        if UNIT_CAST_TRACKER[unitTarget] % 2 == 1 then
                            local PlayerRole = GetPlayerRole()
                            if PlayerRole == "HEALER" then
                                PlaySoundFile(MEDIA_PATH .. "SanMiaoQuSanMoFa.ogg", "Master")
                            end
                        else
                            PlaySoundFile(MEDIA_PATH .. "ZhunBeiAOE.ogg", "Master")                     
                        end
                        return
                    end
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "执政团之座" or subZone == "影卫入侵营地" then    
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                local currentText = GetTopWidgetText() or ""
                if not currentText:find("关闭虚空裂隙") then    
                    if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 1 and sex == 1 then
                        UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1        
                        if UNIT_CAST_TRACKER[unitTarget] % 2 == 1 then
                            PlaySoundFile(MEDIA_PATH .. "WuMaFenSan.ogg", "Master")
                        else
                            PlaySoundFile(MEDIA_PATH .. "DuoKaiTouQian.ogg", "Master")
                        end
                        return
                    end
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "执政团之座" then    
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 0 and sex == 3 then
                    UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1        
                    if UNIT_CAST_TRACKER[unitTarget] % 2 == 1 then
                        -- PlaySoundFile(MEDIA_PATH .. "QiMiaoZhuYiDuoQiu.ogg", "Master")
                    else
                        local PlayerRole = GetPlayerRole()
                        if PlayerRole == "HEALER" then
                            PlaySoundFile(MEDIA_PATH .. "YiMiaoZhuYiDanShua.ogg", "Master")
                        end                        
                    end
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "三人议政厅" or subZone == "影卫入侵营地" then    
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 0 and sex == 3 then
                    UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1        
                    if UNIT_CAST_TRACKER[unitTarget] % 2 == 1 then
                        PlaySoundFile(MEDIA_PATH .. "ZhunBeiYouBuYouBu.ogg", "Master")
                    else
                        PlaySoundFile(MEDIA_PATH .. "MeiYouYinPin.ogg", "Master")                     
                    end
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "温蕾萨之憩" then    
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 1 and sex == 1 then
                    UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1        
                    if UNIT_CAST_TRACKER[unitTarget] % 2 == 1 then
                        -- PlaySoundFile(MEDIA_PATH .. "MeiYouYinPin.ogg", "Master")
                    else
                        PlaySoundFile(MEDIA_PATH .. "WuMaFenSan.ogg", "Master")                     
                    end
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "温蕾萨之憩" then
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                if actualLevel == NEXT_PLAYER_LEVEL and currentMapID == 2494 and unitPowerType == 3 then
                    if not UNIT_START_TIMES[unitTarget] then
                        UNIT_START_TIMES[unitTarget] = GetTime()
                        UNIT_CAST_TRACKER[unitTarget] = 0 -- 确保初始状态为0
                    end

                    -- 2. 计算经过的时间
                    local elapsed = GetTime() - UNIT_START_TIMES[unitTarget]
                    local currentStep = UNIT_CAST_TRACKER[unitTarget] or 0
                    -- print(elapsed)
                    -- 3. 第一阶段：超过 7 秒且未播报过
                    if elapsed >= 6 and currentStep == 0 then
                        PlaySoundFile(MEDIA_PATH .. "ZhunBeiAOE.ogg", "Master")
                        UNIT_CAST_TRACKER[unitTarget] = 1 -- 标记已完成第一阶段
                        -- print("|cff00ff00[地瓜提示]|r 时间轴 6秒 播报完成")
                        return 
                    end

                    -- 4. 第二阶段：超过 32 秒且只进行过第一阶段播报
                    if elapsed >= 32 and currentStep == 1 then
                        -- 这里可以播放同一个文件，或者换一个不同的提示音
                        PlaySoundFile(MEDIA_PATH .. "ZhunBeiAOE.ogg", "Master") 
                        UNIT_CAST_TRACKER[unitTarget] = 2 -- 标记已完成第二阶段
                        -- print("|cff00ff00[地瓜提示]|r 时间轴 32.5秒 再次播报")
                        return
                    end

                    -- 4. 第三阶段：超过 57 秒且只进行过第二阶段播报
                    if elapsed >= 59 and currentStep == 2 then
                        -- 这里可以播放同一个文件，或者换一个不同的提示音
                        PlaySoundFile(MEDIA_PATH .. "ZhunBeiAOE.ogg", "Master") 
                        UNIT_CAST_TRACKER[unitTarget] = 3 -- 标记已完成第二阶段
                        -- print("|cff00ff00[地瓜提示]|r 时间轴 58秒 再次播报")
                        return
                    end
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "希尔瓦娜斯的营房" then    
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 1 and sex == 1 then
                    UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1   
                    local PlayerRole = GetPlayerRole()     
                    if UNIT_CAST_TRACKER[unitTarget] % 2 == 1 then
                        if PlayerRole == "TANK" or PlayerRole == "HEALER" then
                            PlaySoundFile(MEDIA_PATH .. "TanKeJianCi.ogg", "Master")
                        end                        
                    else
                        if PlayerRole == "TANK" then
                            PlaySoundFile(MEDIA_PATH .. "TanKeDaiWei.ogg", "Master")
                        else
                            PlaySoundFile(MEDIA_PATH .. "WuMaFenSan.ogg", "Master")
                        end
                    end
                    return
                end
            end                
        end

        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "幽灵悲歌" then    
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0 
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 0 and sex == 1 and currentMapID == 2498 then
                    -- local castInfo = { UnitCastingInfo(unitTarget) }
                    -- local spellName = castInfo[1]
                    -- print(texture)
                    C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), texture, 10, 0, true)
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID = GetInstanceInfo()
            if instanceID == 2811 then -- 魔导师平台
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0 
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 3 and sex == 1 and BOSS_KILL_3072 == false then
                    UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1
                    local remainder = UNIT_CAST_TRACKER[unitTarget] % 3
                    if remainder == 1 then
                        local PlayerRole = GetPlayerRole()
                        if PlayerRole == "TANK" or PlayerRole == "HEALER" then
                            PlaySoundFile(MEDIA_PATH .. "TanKeDingShen.ogg", "Master")
                        end
                    elseif remainder == 2 then
                        PlaySoundFile(MEDIA_PATH .. "ZhuYiDianMing.ogg", "Master")
                    elseif remainder == 0 then
                        StartCircleTimerBySeconds(3)
                        PlaySoundFile(MEDIA_PATH .. "XiaoXinJiTui.ogg", "Master") 
                    end               
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID = GetInstanceInfo()
            if instanceID == 2811 then -- 魔导师平台
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0 
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 3 and sex == 1 and BOSS_KILL_3072 == true then
                    PlaySoundFile(MEDIA_PATH .. "KuaiKaiJianShang.ogg", "Master")                    
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "风行者宝库" then
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    

                if actualLevel == NEXT_PLAYER_LEVEL and currentMapID == 2498 and unitPowerType == 0 and currentEncounterID == 0 then
                    -- 1. 初始化开始时间
                    if not UNIT_START_TIMES[unitTarget] then
                        UNIT_START_TIMES[unitTarget] = GetTime()
                        UNIT_CAST_TRACKER[unitTarget] = 0 -- 确保初始状态为0
                    end

                    -- 2. 计算经过的时间
                    local elapsed = GetTime() - UNIT_START_TIMES[unitTarget]
                    local currentStep = UNIT_CAST_TRACKER[unitTarget] or 0
                    -- print(elapsed)
                    -- 3. 第一阶段：超过 7 秒且未播报过
                    if elapsed >= 6.3 and currentStep == 0 then
                        PlaySoundFile(MEDIA_PATH .. "ZhunBeiAOE.ogg", "Master")
                        UNIT_CAST_TRACKER[unitTarget] = 1 -- 标记已完成第一阶段
                        -- print("|cff00ff00[地瓜提示]|r 时间轴 8秒 播报完成")
                        return 
                    end

                    -- 4. 第二阶段：超过 32 秒且只进行过第一阶段播报
                    if elapsed >= 31.2 and currentStep == 1 then
                        -- 这里可以播放同一个文件，或者换一个不同的提示音
                        PlaySoundFile(MEDIA_PATH .. "ZhunBeiAOE.ogg", "Master") 
                        UNIT_CAST_TRACKER[unitTarget] = 2 -- 标记已完成第二阶段
                        -- print("|cff00ff00[地瓜提示]|r 时间轴 32秒 再次播报")
                        return
                    end

                    -- 4. 第三阶段：超过 56 秒且只进行过第二阶段播报
                    if elapsed >= 55.5 and currentStep == 2 then
                        -- 这里可以播放同一个文件，或者换一个不同的提示音
                        PlaySoundFile(MEDIA_PATH .. "ZhunBeiAOE.ogg", "Master") 
                        UNIT_CAST_TRACKER[unitTarget] = 3 -- 标记已完成第二阶段
                        -- print("|cff00ff00[地瓜提示]|r 时间轴 56秒 再次播报")
                        return
                    end
                end
            end                
        end

        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "恸哭深渊" or subZone == "蒙难之台" then    
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 1 and sex == 2 then
                    UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1 
                    local castCount = UNIT_CAST_TRACKER[unitTarget]
                    if castCount == 1 then
                        local PlayerRole = GetPlayerRole()
                        if PlayerRole == "TANK" or PlayerRole == "HEALER" then
                            PlaySoundFile(MEDIA_PATH .. "TanKeJianCi.ogg", "Master")
                        end                        
                    elseif castCount == 2 then
                        PlaySoundFile(MEDIA_PATH .. "JinZhanDaQuan.ogg", "Master")
                    elseif castCount == 3 then
                        PlaySoundFile(MEDIA_PATH .. "JinZhanDaQuan.ogg", "Master")
                    elseif castCount == 4 then
                        local PlayerRole = GetPlayerRole()
                        if PlayerRole == "TANK" or PlayerRole == "HEALER" then
                            PlaySoundFile(MEDIA_PATH .. "TanKeJianCi.ogg", "Master")
                        end      
                    else
                        -- print("超过4次，停止播报") 
                    end
                    return
                end
            end                
        end


        if not alerts then return end

        if startTime ~= 0 or currentEncounterID ~= 0 then return end
        
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
            local actualLevel = UnitLevel(unitTarget)
            local name = UnitName(unitTarget) or "未知"
            -- print(name .. " | dengji: " .. actualLevel .. " | quyu: " .. subZone .. " | dituID: ".. currentMapID)  
            for _, alertConfig in ipairs(alerts) do
                ProcessAlert(alertConfig, "Location:"..subZone, actualLevel, currentMapID, unitTarget)
            end
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        local unitTarget = ...
        local subZone = GetSubZoneText()   
        local alerts = LocationChannelData[subZone]

        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            local currentMapID = C_Map.GetBestMapForUnit("player") or 0
            if currentMapID == 184 then                   
                local actualLevel = UnitLevel(unitTarget)
                local classification = UnitClassification(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)   
                local sex = UnitSex(unitTarget)
                if actualLevel == PLAYER_LEVEL and unitPowerType == 1 and classification == "elite" and sex == 3 then                    
                    if not UNIT_CHANNEL_TRACKER[unitTarget] then
                        PlaySoundFile(MEDIA_PATH .. "ZhuYiJiuRen.ogg", "Master")
                        UNIT_CHANNEL_TRACKER[unitTarget] = true
                        return
                    end                    
                    return
                end
            end         
        end

        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "主峰" then
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
                local actualLevel = UnitLevel(unitTarget)
                local isInside = IsIndoors() and true or false
                if isInside == false and actualLevel == NEXT_PLAYER_LEVEL and currentMapID == 601 then
                    PlaySoundFile(MEDIA_PATH .. "ZhuYiDuoQuan.ogg", "Master")
                    return
                end
            end               
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "主峰" then
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
                local actualLevel = UnitLevel(unitTarget)
                local isInside = IsIndoors() and true or false          
                if isInside == true and actualLevel == NEXT_PLAYER_LEVEL and currentMapID == 602 then
                    PlaySoundFile(MEDIA_PATH .. "ZhuYiDuoQuan.ogg", "Master")
                    return
                end
            end               
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "幽灵悲歌" then    
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0 
                if actualLevel == PLAYER_LEVEL and unitPowerType == 1 and sex == 3 and currentMapID == 2498 then
                    PlaySoundFile(MEDIA_PATH .. "ZhuYiDuoQuan.ogg", "Master")
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            local currentMapID = C_Map.GetBestMapForUnit("player") or 0      
            if subZone == "温蕾萨之憩" then                   
                local actualLevel = UnitLevel(unitTarget)
                local classification = UnitClassification(unitTarget)
                local sex = UnitSex(unitTarget)
                if (currentMapID == 2493 or currentMapID == 2494) and actualLevel == PLAYER_LEVEL and classification == "elite" and sex == 1 then
                    PlaySoundFile(MEDIA_PATH .. "KongDuanLongYing.ogg", "Master")
                    local testEventInfo = {
                        spellID = 1216848,              -- 示例：幻影打击 (随便找个法术ID)
                        iconFileID = 135812,           -- 示例：一个图标的 FileID
                        duration = 17.6,                 -- 持续 10 秒
                        maxQueueDuration = 0,
                        overrideName = "控断龙鹰", -- 显示的名称
                        icons = 0x1,                  -- 对应 TankRole (坦克图标)
                        severity = 2,                  -- High (高伤害/重要等级)
                        paused = false,
                    }
                    local eventID = C_EncounterTimeline.AddScriptEvent(testEventInfo)
                    return
                end
            end          
        end

        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            if subZone == "恸哭深渊" or subZone == "蒙难之台" then    
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                if actualLevel == PLAYER_LEVEL and unitPowerType == 1 and sex == 1 then
                    if not UNIT_CHANNEL_TRACKER[unitTarget] then
                        PlaySoundFile(MEDIA_PATH .. "DaDuanFuHuo.ogg", "Master")
                        UNIT_CHANNEL_TRACKER[unitTarget] = true
                        return
                    end
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID = GetInstanceInfo()
            if instanceID == 2811 then -- 魔导师平台
                local actualLevel = UnitLevel(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)    
                local sex = UnitSex(unitTarget)
                local currentMapID = C_Map.GetBestMapForUnit("player") or 0 
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 3 and sex == 1 and BOSS_KILL_3072 == true then -- 影卫虚空召唤师
                    UNIT_CAST_TRACKER[unitTarget] = (UNIT_CAST_TRACKER[unitTarget] or 0) + 1
                    local remainder = UNIT_CAST_TRACKER[unitTarget] % 3
                    if remainder == 1 then    
                        PlaySoundFile(MEDIA_PATH .. "ZhaoHuanXiaoGuai.ogg", "Master")
                    elseif remainder == 2 then
                        -- PlaySoundFile(MEDIA_PATH .. "ZhuYiDianMing.ogg", "Master")
                    elseif remainder == 0 then
                        PlaySoundFile(MEDIA_PATH .. "ZhaoHuanXiaoGuai.ogg", "Master")
                    end                    
                    return
                end
            end                
        end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            local currentMapID = C_Map.GetBestMapForUnit("player") or 0
            if currentMapID == 184 then                   
                local actualLevel = UnitLevel(unitTarget)
                local classification = UnitClassification(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)   
                local sex = UnitSex(unitTarget)
                if actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 1 and classification == "elite" and sex == 2 then
                    local PlayerRole = GetPlayerRole()
                    if PlayerRole == "HEALER" then
                        PlaySoundFile(MEDIA_PATH .. "DanShuaDianMing.ogg", "Master")
                    end                    
                    return
                end
            end         
        end
        -- if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
        --     if subZone == "下层平台" then
        --         local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
        --         local actualLevel = UnitLevel(unitTarget)   
        --         if actualLevel == NEXT_PLAYER_LEVEL and currentMapID == 601 then
        --             local PlayerRole = GetPlayerRole()     
        --             if PlayerRole == "HEALER" then
        --                 PlaySoundFile(MEDIA_PATH .. "AOE.ogg", "Master")
        --             end
        --         end
        --     end               
        -- end
        -- local currentMapID = C_Map.GetBestMapForUnit("player") or 0  
        -- local name = UnitName(unitTarget) or "未知"
        -- local actualLevel = UnitLevel(unitTarget)
        -- print(name .. " | dengji: " .. actualLevel .. " | quyu: " .. subZone .. " | dituID: ".. currentMapID)  
        if not alerts then return end

        if startTime ~= 0 or currentEncounterID ~= 0 then return end
        
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
            local actualLevel = UnitLevel(unitTarget)
            local name = UnitName(unitTarget) or "未知"
            -- print(name .. " | dengji: " .. actualLevel .. " | quyu: " .. subZone .. " | dituID: ".. currentMapID)  

            for _, alertConfig in ipairs(alerts) do
                ProcessAlert(alertConfig, "Location:"..subZone, actualLevel, currentMapID, unitTarget)
            end
        end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        local unitTarget = ...
        local interruptedBy = (event == "UNIT_SPELLCAST_INTERRUPTED") and select(4, ...) or nil
        local subZone = GetSubZoneText()   
    --     if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
    --         if subZone == "下层平台" or subZone == "主峰" then
    --             -- local currentMapID = C_Map.GetBestMapForUnit("player") or 0        
    --             local actualLevel = UnitLevel(unitTarget)
    --             local unitPowerType = UnitPowerType(unitTarget)    
    --             local sex = UnitSex(unitTarget)
    --             C_Timer.After(0.1, function()
    --                 modelFrame:SetUnit(unitTarget) 
    --                 local modelFileID = modelFrame:GetModelFileID()      
    --                 if modelFileID == 986699 and actualLevel == NEXT_PLAYER_LEVEL and unitPowerType == 1 and sex == 1 then
    --                     UNIT_SUCCEEDED_AND_INTERRUPTED_TRACKER[unitTarget] = (UNIT_SUCCEEDED_AND_INTERRUPTED_TRACKER[unitTarget] or 0) + 1        
    --                     if UNIT_SUCCEEDED_AND_INTERRUPTED_TRACKER[unitTarget] % 2 == 1 then
    --                         local testEventInfo = {
    --                             spellID = 1254380,              -- 示例：幻影打击 (随便找个法术ID)
    --                             iconFileID = 4635276,           -- 示例：一个图标的 FileID
    --                             duration = 22,                 -- 持续 10 秒
    --                             maxQueueDuration = 0,
    --                             overrideName = "坦克破甲", -- 显示的名称
    --                             icons = 0x80,                  -- 对应 TankRole (坦克图标)
    --                             severity = 2,                  -- High (高伤害/重要等级)
    --                             paused = false,
    --                         }
    --                         local eventID = C_EncounterTimeline.AddScriptEvent(testEventInfo)
    --                     else
    --                         -- print("成功4")
    --                     end
    --                     return
    --                 end
    --             end)                
    --         end
    --     end
        if unitTarget and unitTarget:find("nameplate") and UnitCanAttack("player", unitTarget) then
            local currentMapID = C_Map.GetBestMapForUnit("player") or 0   
            local keyLevel = C_ChallengeMode.GetActiveKeystoneInfo()         
            if currentMapID == 184 and keyLevel >= 12 then                   
                local actualLevel = UnitLevel(unitTarget)
                local classification = UnitClassification(unitTarget)
                local unitPowerType = UnitPowerType(unitTarget)   
                local auraData = C_UnitAuras.GetAuraDataByIndex(unitTarget, 3, "HELPFUL") 
                local sex = UnitSex(unitTarget)
                if interruptedBy and actualLevel == PLAYER_LEVEL and unitPowerType == 0 and classification == "elite" and sex == 2 and auraData then
                    local testEventInfo = {
                        spellID = 1271479,              -- 示例：幻影打击 (随便找个法术ID)
                        iconFileID = 1041233,           -- 示例：一个图标的 FileID
                        duration = 20,                 -- 持续 10 秒
                        maxQueueDuration = 0,
                        overrideName = "虚空爆发", -- 显示的名称
                        icons = 0x1,                  -- 对应 TankRole (坦克图标)
                        severity = 2,                  -- High (高伤害/重要等级)
                        paused = false,
                    }
                    local eventID = C_EncounterTimeline.AddScriptEvent(testEventInfo)
                    return
                end
            end          
        end
        return

    -- elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
    --     local unitTarget = ...
    --     local subZone = GetSubZoneText()   
        

    elseif event == "RAID_BOSS_EMOTE" or event == "ENCOUNTER_WARNING" then

        local encounterWarningInfo = ...
        -- if encounterWarningInfo then
        --     print("|cffffd100[Debug] 捕获到实时事件数据:|r")
            
        --     -- 1. 文本类
        --     print("文本 (text):", encounterWarningInfo.text)
        --     print("施法者 (casterName):", encounterWarningInfo.casterName)
        --     print("目标 (targetName):", encounterWarningInfo.targetName)
            
        --     -- 2. GUID
        --     print("施法者GUID:", encounterWarningInfo.casterGUID)
        --     print("目标GUID:", encounterWarningInfo.targetGUID)
            
        --     -- 3. 数字/ID
        --     print("图标ID (iconFileID):", encounterWarningInfo.iconFileID)
        --     print("技能ID (tooltipSpellID):", encounterWarningInfo.tooltipSpellID)
        --     print("持续时间 (duration):", encounterWarningInfo.duration)
        --     print("严重程度 (severity):", encounterWarningInfo.severity)
            
        --     -- 4. 布尔值
        --     print("是否致命 (isDeadly):", tostring(encounterWarningInfo.isDeadly))
        --     print("播放声音 (shouldPlaySound):", tostring(encounterWarningInfo.shouldPlaySound))
        --     print("聊天框消息 (shouldShowChatMessage):", tostring(encounterWarningInfo.shouldShowChatMessage))
        --     print("显示警告 (shouldShowWarning):", tostring(encounterWarningInfo.shouldShowWarning))
            
        --     -- 5. 颜色
        --     if encounterWarningInfo.color then
        --         print("颜色 (RGB):", encounterWarningInfo.color.r, encounterWarningInfo.color.g, encounterWarningInfo.color.b)
        --     else
        --         print("颜色: nil")
        --     end
            
        --     -- 这里可以直接接你的圆环启动逻辑
        --     if encounterWarningInfo.duration and encounterWarningInfo.duration > 0 then
        --         -- 假设只有 severity 大于某个值才需要检查读条，或者全部检查
        --         StartCircleTimerBySeconds(encounterWarningInfo.duration, true)
        --     end
        -- else
        --     print("|cffff0000[Error] 事件触发但数据为空|r")
        -- end




        if currentEncounterID == 3056 and encounterWarningInfo.severity and encounterWarningInfo.severity == 1 then
            -- print("成功：检测到炽焰腾流")
            PlaySoundFile(MEDIA_PATH .. "TieBianFangShuiSanMiaoSanErYi.ogg", "Master")
            StartCircleTimerBySeconds(6)
            return
        end
        if currentEncounterID == 3179 and encounterWarningInfo.severity and encounterWarningInfo.severity == 0 then
            -- print("成功：检测到专制命令")
            -- PlaySoundFile(MEDIA_PATH .. "TieBianFangShui.ogg", "Master")
            StartCircleTimerBySeconds(12)
            return
        end
        if currentEncounterID == 2065 and encounterWarningInfo.targetName then
            -- print("成功：检测到残杀")
            StartCircleTimerBySeconds(5)
            return
        end
        if currentEncounterID == 2564 and encounterWarningInfo.severity and encounterWarningInfo.severity == 1 then
            -- print("成功：检测到震耳尖啸")
            -- local PlayerRole = GetPlayerRole()
            -- if PlayerRole == "HEALER" then
            --     C_Timer.After(1.3, function()
            --         PlaySoundFile(MEDIA_PATH .. "Yi.ogg", "Master")
            --     end)   
            -- end
            StartCircleTimerBySeconds(2.3, true)
            return
        end        
        if currentEncounterID == 3072 and encounterWarningInfo.severity and encounterWarningInfo.severity == 2 then
            -- print("成功：检测到静默浪潮")
            StartCircleTimerBySeconds(4.8)
            return
        end
        if currentEncounterID == 3057 and encounterWarningInfo.severity and encounterWarningInfo.severity == 1 then
            -- print("成功：检测到黑暗诅咒和飞溅喷吐")
            StartCircleTimerBySeconds(4.1)
            return
        end        
        if currentEncounterID == 3214 and encounterWarningInfo.severity and encounterWarningInfo.severity == 1 then
            -- print("成功：检测到粉碎灵魂")
            StartCircleTimerBySeconds(4.5)
            return
        end
        if currentEncounterID == 3183 and encounterWarningInfo.severity == 1 then
            local _, _, difficultyID = GetInstanceInfo()
            
            -- 定义默认时间为 3.9 秒（普通/英雄）
            local timerDuration = 3.9
            
            -- 如果是史诗难度（ID 16），则改为 2.9 秒
            if difficultyID == 16 then
                timerDuration = 2.9
            end
            StartCircleTimerBySeconds(timerDuration)
            return 
        end
        if startTime ~= 0 or currentEncounterID ~= 0 then 
            return 
        end

        local mapID = C_Map.GetBestMapForUnit("player")
        if not mapID then return end

        
        -- print("['" .. encounterWarningInfo.duration .. "']")
        if encounterWarningInfo.duration == 3.5 and mapID == 184 then
            -- print("成功")
            PlaySoundFile(MEDIA_PATH .. "WuMaFenSanSanErYiZhuYiJiaoXia.ogg", "Master")
            StartCircleTimerBySeconds(5.1)
            return
        end

        -- print("ID: " .. mapID)
        local alert = LocationWarningAlerts[mapID]
        
        if alert then
            StartMyCircleTimer(alert)
            ProcessAlert(alert, "Location:"..mapID)
        end
        return

    elseif event == "PLAYER_LOGIN" then
        -- 2. 根据检测结果动态赋值
        if C_AddOns.IsAddOnLoaded("DiGua-WYJJ") then
            MEDIA_PATH = "Interface\\AddOns\\DiGua-WYJJ\\Media\\"
            -- print("|cff00ff00[联动]|r 检测到 DiGua-WYJJ，[忘忧景久语音包启动]")
        else
            MEDIA_PATH = "Interface\\AddOns\\DiGuaTimelineAudioHelper\\Media\\"
            -- print("|cffaaaaaa[系统]|r 未检测到 DiGua-WYJJ，使用默认素材路径")
        end
        -- 1. 专门针对 BigWigs 的判断
        local hasBigWigs = C_AddOns.IsAddOnLoaded("BigWigs")

        -- 2. 只有在【没有 BigWigs】的情况下，才在 2 秒后强制开启系统警报
        if not hasBigWigs then
            C_Timer.After(2, function()
                -- 如果有 DBM 但没有 BW，这里依然会执行，满足你“DBM无所谓”的需求
                SetCVar("encounterWarningsEnabled", 1)
            end)
        end       
        SetCVar("Sound_NumChannels", 128)
        RegisterPrivateAuras()
        C_Timer.After(2, function()
            print("感谢使用|cFF00FF00[神秘地瓜副本语音插件]|r如果觉得好用，请在|cFFFFA6D5“爱发电”|r平台搜索|cFFFFFF00“神秘地瓜”|r支持我的插件，您的支持就是我最大的动力。")
        end)        
        -- ApplyTimelineSounds()

        


        return
    elseif event == "PLAYER_ENTERING_WORLD" then
        hasPlayedSiJiaoTingYuan = false
        Lindormi = false
        MyTTSDict.isSampled = false
        MyTTSDict.sampleIndex = 0
        local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID = GetInstanceInfo()
        -- print("当前副本 ID: " .. (instanceID or "nil"))
        C_Timer.After(2, function()
            if instanceID == 658 then 
                C_Timer.After(2, function()
                    MyTTSDict.sampleIndex = 1        
                    C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), "0", 10, 0, true)
                end)
                -- 2秒后读第二个
                C_Timer.After(4, function()
                    MyTTSDict.sampleIndex = 2
                    C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), "50000", 10, 0, true)                
                end)
            end
            if instanceID == 2805 then 
                C_Timer.After(2, function()
                    MyTTSDict.sampleIndex = 1        
                    C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), "4667427", 10, 0, true)
                end)
                -- 2秒后读第二个
                C_Timer.After(4, function()
                    MyTTSDict.sampleIndex = 2
                    C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), "852826", 10, 0, true)
                end)
            end
            if instanceID == 2526 then -- 艾杰斯亚学院
                C_Timer.After(2, function()
                    MyTTSDict.sampleIndex = 1        
                    C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), "阵风", 10, 0, true)
                end)
                -- 2秒后读第二个
                C_Timer.After(4, function()
                    MyTTSDict.sampleIndex = 2
                    C_VoiceChat.SpeakText(C_TTSSettings.GetVoiceOptionID(0), "狂怒尖啸", 10, 0, true)
                end)
            end  
        end)
        return
    -- elseif event == "LOADING_SCREEN_DISABLED" then
    --     print("LOADING_SCREEN_DISABLED")
        
    --     return
    elseif event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
        local subZone = GetSubZoneText()
        if subZone == "绿植场圃" then
            encounterUnitTriggerCount = (encounterUnitTriggerCount or 0) + 1
            if encounterUnitTriggerCount >= 3 and encounterUnitTriggerCount % 2 ~= 0 then
                if UnitExists("boss1") and not UnitIsDead("boss1") then
                    PlaySoundFile(MEDIA_PATH .. "KuaiJinLvQuan.ogg", "Master")
                    -- print("|cffff0000[警报]|r 第 " .. encounterUnitTriggerCount .. " 次触发：满足奇数序列，播放语音")
                end
            end
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local unit = ...  
        if unit and UNIT_CAST_TRACKER[unit] then
            UNIT_CAST_TRACKER[unit] = nil
        end
        if unit and auraTriggeredCache[unit] then
            auraTriggeredCache[unit] = nil
        end
        -- 清理时间戳和播放状态
        UNIT_START_TIMES[unit] = nil
        UNIT_CAST_TRACKER[unit] = nil
        -- 如果还有之前 NewTimer 的句柄，也顺手清理（虽然新逻辑不用了，但为了保险）
        if UNIT_CAST_TIMER_HANDLES[unit] then
            UNIT_CAST_TIMER_HANDLES[unit]:Cancel()
            UNIT_CAST_TIMER_HANDLES[unit] = nil
        end
        if unit then
            UNIT_CHANNEL_TRACKER[unit] = nil -- 彻底清除
        end
    end

    local bossData = AudioTimeline[currentEncounterID]
    if bossData and bossData.eventAlerts then
        local specificAlert = bossData.eventAlerts[event]
        if specificAlert then
            ProcessAlert(specificAlert, "Event:"..event)
            if type(specificAlert) == "table" and specificAlert.action then
                if specificAlert.action == "STOP" then
                    startTime = 0
                    lastPlayedSecond = -1
                    frame:SetScript("OnUpdate", nil) 
                    -- print("|cFFFF0000[TimelineAudio]|r 收到 STOP：时间轴已挂起")                    
                elseif specificAlert.action == "START" then
                    startTime = GetTime()
                    lastPlayedSecond = -1
                    frame:SetScript("OnUpdate", OnUpdate)
                    -- print("|cFF00FF00[TimelineAudio]|r 收到 START：时间轴已重新启动")
                end
            end
        end
    end
end)



-- 1. 创建主框架
local RingFrame = CreateFrame("Frame", "MyCustomCircleTimer", UIParent)
RingFrame:SetSize(120, 120)
RingFrame:SetPoint("CENTER", 0, 0)
RingFrame:Hide()

-- 2. 创建底色圆环 (背景)
local bg = RingFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture(RING_PATH)
bg:SetVertexColor(0, 0, 0, 0.3)

-- 3. 创建进度层
local cd = CreateFrame("Cooldown", nil, RingFrame, "CooldownFrameTemplate")
cd:SetAllPoints()
cd:SetDrawEdge(false)           
cd:SetDrawSwipe(true)           
cd:SetSwipeTexture(RING_PATH)   
cd:SetSwipeColor(0.4, 1, 0.8, 0.85) 
cd:SetHideCountdownNumbers(true)
cd:SetBlingTexture("")          

function StartMyCircleTimer(alert)
    -- 1. 只有当 alert 是 table 且包含 duration 字段时才继续
    if type(alert) ~= "table" or not alert.duration then 
        return 
    end

    local duration = alert.duration
    
    -- 2. 执行倒计时逻辑
    local startTime = GetTime()
    
    -- --- 新增逻辑：同步全局变量 ---
    TargetEndTime = startTime + duration             -- 记录全局结束时间
    CurrentRingIsCastSensitive = alert.checkCast     -- 从表中读取 checkCast 参数
    UpdateRingColor(false)                           -- 恢复默认颜色
    -- ---------------------------

    cd:SetCooldown(startTime, duration)
    RingFrame:Show()
    
    -- 3. 动态延时隐藏
    C_Timer.After(duration, function()
        -- 减去 0.1 秒作为容错缓冲
        if GetTime() >= (startTime + duration - 0.1) then
            RingFrame:Hide()
        end
    end)
end

function StartCircleTimerBySeconds(seconds, checkCast)
    -- 1. 安全检查：确保传入的是数字且大于 0
    local duration = tonumber(seconds)
    if not duration or duration <= 0 then 
        return 
    end

    -- 2. 执行倒计时逻辑
    local startTime = GetTime()
    TargetEndTime = startTime + duration -- 记录全局结束时间
    -- print(TargetEndTime)
    CurrentRingIsCastSensitive = checkCast -- 记录本次是否需要检查施法

    UpdateRingColor(false) -- 先恢复默认颜色
    cd:SetCooldown(startTime, duration)
    RingFrame:Show()
    
    -- 3. 动态延迟隐藏
    C_Timer.After(duration, function()
        -- 容错缓冲：如果当前时间已经达到或超过预计结束时间，隐藏框架
        if GetTime() >= (startTime + duration - 0.1) then
            RingFrame:Hide()
        end
    end)
end

-- 4. 颜色切换函数
function UpdateRingColor(isAlarm)
    if isAlarm then
        cd:SetSwipeColor(unpack(RING_COLOR_ALARM))
    else
        cd:SetSwipeColor(unpack(RING_COLOR_NORMAL))
    end
end