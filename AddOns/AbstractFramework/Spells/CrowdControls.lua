---@class AbstractFramework
local AF = _G.AbstractFramework

-- forked from ThreatPlates
---------------------------------------------------------------------
-- CC TYPES (priorities) https://warcraft.wiki.gg/wiki/Crowd_control
---------------------------------------------------------------------
-- loss of control
local CHARM = 1 -- 魅惑 - target is under control of the caster.
local FEAR = 2 -- 恐惧 - target runs randomly around.
local STUN = 3 -- 昏迷 - target is unable to move or perform any actions.
local INCAPACITATE = 4 -- 瘫痪 - a stun which breaks on damage to the target.
local SLEEP = 5 -- 沉睡 - target is put to sleep, unable to move or perform any actions.
local DISORIENT = 6 -- 迷惑 - target wanders around slowly, unable to perform actions.
local POLYMORPH = 7 -- 变形 - target is transformed into a critter, unable to perform actions. Most Polymorph effects also include Disorient.
local BANISH = 8 -- 放逐 - target is made immune to all effects but is unable to perform any.
local HORROR = 9 -- 惊骇 - similar to Fear effect, but duration tends to be short.
local SILENCE = 10 -- 沉默
local DISARM = 11 -- 缴械

-- positional control
local ROOT = 12 -- 定身 - target is locked in place, stationery, but abilities may still be performed.
local MODAGGRORANGE = 13 -- 仇恨范围
local DAZE = 14 -- 眩晕 - targets movement speed is reduced to 50%, and dismounted if applicable.
local SNARE = 15 -- 诱捕 - targets movement speed is limited, often slowed to below normal run speed.
-- local PUSHBACK = 16 -- 击退
-- local GRIP = 17 -- 拖拽 - targets are pulled from their original position, often having spells interrupted.

-- other
local OTHER = 99

---------------------------------------------------------------------
-- CC DATA
---------------------------------------------------------------------
local CC_DATA = {
    -- DEATHKNIGHT
    [45524] = SNARE, -- 寒冰锁链
    [47476] = SILENCE, -- 绞袭
    [108194] = STUN, -- 窒息
    [111673] = CHARM, -- 控制亡灵
    [200646] = SNARE, -- 邪恶畸变
    [204085] = ROOT, -- 死亡之寒
    [204206] = SNARE, -- 冰冻
    [207167] = DISORIENT, -- 致盲冰雨
    [221562] = STUN, -- 窒息
    [233395] = ROOT, -- 死亡之寒
    [273977] = SNARE, -- 亡者之握
    [279303] = SNARE, -- 冰霜巨龙之怒

    -- DEMONHUNTER
    [179057] = STUN, -- 混乱新星
    [198813] = SNARE, -- 复仇回避
    [200166] = STUN, -- 恶魔变形
    [204490] = SILENCE, -- 沉默咒符
    [204843] = SNARE, -- 锁链咒符
    [205630] = STUN, -- 伊利丹之握
    [207685] = DISORIENT, -- 悲苦咒符
    [208618] = STUN, -- 伊利丹之握
    [211881] = STUN, -- 邪能爆发
    [213405] = SNARE, -- 战刃大师
    [217832] = INCAPACITATE, -- 禁锢
    [221527] = INCAPACITATE, -- 禁锢

    -- DRUID
    [99] = INCAPACITATE, -- 夺魂咆哮
    [339] = ROOT, -- 纠缠根须
    [2637] = SLEEP, -- 休眠
    [5211] = STUN, -- 蛮力猛击
    [33786] = BANISH, -- 旋风
    [45334] = SLEEP, -- 无法移动
    [50259] = SLEEP, -- 眩晕
    [61391] = DAZE, -- 台风
    [81261] = SILENCE, -- 日光术
    [102359] = ROOT, -- 群体缠绕
    [127797] = DAZE, -- 乌索尔旋风
    [163505] = STUN, -- 斜掠
    [202244] = INCAPACITATE, -- 蛮力冲锋
    [203123] = STUN, -- 割碎
    [209749] = DISARM, -- 精灵虫群

    -- EVOKER
    [351338] = SILENCE, -- 镇压
    [355689] = ROOT, -- 山崩
    [357210] = STUN, -- 深呼吸
    [360806] = SLEEP, -- 梦游
    [370898] = SNARE, -- 蚀骨之寒
    [372048] = OTHER, -- 压迫怒吼
    [378441] = SNARE, -- 时间停止
    [378441] = STUN, -- 时间停止
    [383005] = CHARM, -- 时空循环

    -- HUNTER
    [3355] = INCAPACITATE, -- 冰冻陷阱
    [5116] = DAZE, -- 震荡射击
    [24394] = STUN, -- 胁迫
    [117405] = ROOT, -- 束缚射击
    [117526] = ROOT, -- 束缚射击
    [135299] = SNARE, -- 焦油陷阱
    [162480] = INCAPACITATE, -- 精钢陷阱
    [186387] = SNARE, -- 爆裂射击
    [190927] = ROOT, -- 鱼叉猛刺
    [195645] = SNARE, -- 摔绊
    [202914] = SILENCE, -- 蜘蛛钉刺
    [203337] = INCAPACITATE, -- 冰冻陷阱
    [212638] = ROOT, -- 追踪者之网
    [213691] = INCAPACITATE, -- 驱散射击

    -- MAGE
    [118] = POLYMORPH, -- 变形术
    [122] = ROOT, -- 冰霜新星
    [2120] = SNARE, -- 烈焰风暴
    [28271] = POLYMORPH, -- 变形术
    [28272] = POLYMORPH, -- 变形术
    [31589] = SNARE, -- 减速
    [31661] = DISORIENT, -- 龙息术
    [33395] = ROOT, -- 冰冻术
    [61305] = POLYMORPH, -- 变形术
    [61721] = POLYMORPH, -- 变形术
    [61780] = POLYMORPH, -- 变形术
    [82691] = STUN, -- 冰霜之环
    [126819] = POLYMORPH, -- 变形术
    [157981] = SNARE, -- 冲击波
    [157997] = ROOT, -- 寒冰新星
    [161353] = POLYMORPH, -- 变形术
    [161354] = POLYMORPH, -- 变形术
    [161355] = POLYMORPH, -- 变形术
    [161372] = POLYMORPH, -- 变形术
    [212792] = SNARE, -- 冰锥术
    [228600] = ROOT, -- 冰川尖刺
    [236299] = SNARE, -- 时空转移
    [277787] = POLYMORPH, -- 变形术
    [277792] = POLYMORPH, -- 变形术
    [321395] = POLYMORPH, -- 变形术
    [391622] = POLYMORPH, -- 变形术

    -- MONK
    [115078] = INCAPACITATE, -- 分筋错骨
    [116095] = SNARE, -- 金刚震
    [119381] = STUN, -- 扫堂腿
    [123586] = SNARE, -- 翔龙在天
    [198909] = DISORIENT, -- 赤精之歌
    [202274] = DISORIENT, -- 热酿
    [202346] = STUN, -- 醉上加醉
    [233759] = DISARM, -- 抓钩武器
    [324382] = ROOT, -- 对冲

    -- PALADIN
    [853] = STUN, -- 制裁之锤
    [10326] = FEAR, -- 超度邪恶
    [20066] = INCAPACITATE, -- 忏悔
    [31935] = SILENCE, -- 复仇者之盾
    [105421] = DISORIENT, -- 盲目之光
    [183218] = SNARE, -- 妨害之手
    [217824] = SILENCE, -- 美德之盾
    [255937] = SNARE, -- 灰烬觉醒
    [439632] = SNARE, -- 严词斥责

    -- PRIEST
    [453] = MODAGGRORANGE, -- 安抚心灵
    [605] = CHARM, -- 精神控制
    [8122] = FEAR, -- 心灵尖啸
    [9484] = POLYMORPH, -- 束缚亡灵
    [15487] = SILENCE, -- 沉默
    [64044] = STUN, -- 心灵惊骇
    [87204] = FEAR, -- 罪与罚
    [114404] = ROOT, -- 虚空触须之握
    [200196] = INCAPACITATE, -- 圣言术：罚
    [200200] = STUN, -- 圣言术：罚
    [204263] = SNARE, -- 闪光力场

    -- ROGUE
    [408] = STUN, -- 肾击
    [1330] = SILENCE, -- 锁喉 - 沉默
    [1776] = STUN, -- 凿击
    [1833] = STUN, -- 偷袭
    [2094] = DISORIENT, -- 致盲
    [6770] = STUN, -- 闷棍
    [185763] = SNARE, -- 手枪射击
    [206760] = SNARE, -- 暗影之握
    [207777] = DISARM, -- 卸除武装
    [212183] = STUN, -- 烟雾弹

    -- SHAMAN
    [3600] = SNARE, -- 地缚术
    [51490] = SNARE, -- 雷霆风暴
    [51514] = POLYMORPH, -- 妖术
    [64695] = ROOT, -- 陷地
    [118905] = STUN, -- 静电充能
    [196840] = SNARE, -- 冰霜震击
    [197214] = INCAPACITATE, -- 裂地术
    [204399] = STUN, -- 大地之怒
    [204437] = STUN, -- 闪电磁索
    [210873] = POLYMORPH, -- 妖术
    [211004] = POLYMORPH, -- 妖术
    [211010] = POLYMORPH, -- 妖术
    [211015] = POLYMORPH, -- 妖术
    [269352] = POLYMORPH, -- 妖术
    [277778] = POLYMORPH, -- 妖术
    [277784] = POLYMORPH, -- 妖术
    [305485] = STUN, -- 闪电磁索

    -- WARLOCK
    [710] = BANISH, -- 放逐术
    [1098] = CHARM, -- 征服恶魔
    [5484] = FEAR, -- 恐惧嚎叫
    [6358] = DISORIENT, -- 诱惑
    [6789] = INCAPACITATE, -- 死亡缠绕
    [19647] = STUN, -- 法术封锁
    [22703] = STUN, -- 地狱火觉醒
    [30283] = STUN, -- 暗影之怒
    [89766] = STUN, -- 巨斧投掷
    [118699] = FEAR, -- 恐惧
    [196364] = SILENCE, -- 痛苦无常
    [213688] = STUN, -- 邪能顺劈
    [233582] = SNARE, -- 烈焰缠身
    [278350] = SNARE, -- 邪恶污染

    -- WARRIOR
    [1715] = SNARE, -- 断筋
    [5246] = FEAR, -- 破胆怒吼
    [12323] = SNARE, -- 刺耳怒吼
    [105771] = ROOT, -- 冲锋
    [118000] = STUN, -- 巨龙怒吼
    [132168] = STUN, -- 震荡波
    [132169] = STUN, -- 风暴之锤
    [199085] = STUN, -- 战路
    [236077] = DISARM, -- 缴械
    [385954] = STUN, -- 盾牌冲锋

    -- OTHERS
    [20549] = STUN -- 战争践踏
}

function AF.GetCrowdControlType(auraData)
    if auraData.isHelpful then return end
    return CC_DATA[auraData.spellId]
end