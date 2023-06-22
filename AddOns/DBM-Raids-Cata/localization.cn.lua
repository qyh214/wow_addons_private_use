-- Simplified Chinese by Diablohu(diablohudream@gmail.com)
-- Last update: 2/25/2012

if GetLocale() ~= "zhCN"  then return end

local L

----------------
--  Argaloth  --
----------------
L= DBM:GetModLocalization(139)

L:SetOptionLocalization({
	SetIconOnConsuming		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(88954)
})

-----------------
--  Occu'thar  --
-----------------
L= DBM:GetModLocalization(140)

----------------------------------
--  Alizabal, Mistress of Hate  --
----------------------------------
L= DBM:GetModLocalization(339)

L:SetTimerLocalization({
	TimerFirstSpecial		= "第一次特殊技能"
})

L:SetOptionLocalization({
	TimerFirstSpecial		= "计时条：$spell:105738后的第一次特殊技能<br/>（第一次特殊技能是随机的，$spell:105067或$spell:104936）"
})

L:SetMiscLocalization({
})

-------------------------------
--  Dark Iron Golem Council  --
-------------------------------
L = DBM:GetModLocalization(169)

L:SetWarningLocalization({
	SpecWarnActivated			= "更换目标 -> %s!",
	specWarnGenerator			= "能量发生器 - 移动%s!"
})

L:SetTimerLocalization({
	timerShadowConductorCast	= "暗影导体",
	timerArcaneLockout			= "奥术歼灭者反制",
	timerArcaneBlowbackCast		= "奥术反冲",
	timerNefAblity				= "技能增强冷却"
})

L:SetOptionLocalization({
	timerShadowConductorCast	= "计时条：$spell:92048施法时间",
	timerArcaneLockout			= "计时条：$spell:91542反制时间",
	timerArcaneBlowbackCast		= "计时条：$spell:91879施法时间",
	timerNefAblity				= "计时条：英雄模式增益法术冷却时间",
	SpecWarnActivated			= "特殊警报：新的金刚已激活",
	specWarnGenerator			= "特殊警报：金刚获得$spell:91557效果",
	AcquiringTargetIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79501),
	ConductorIcon				= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79888),
	ShadowConductorIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92053),
	SetIconOnActivated			= "自动为最新激活的金刚添加团队标记"
})

L:SetMiscLocalization({
	YellTargetLock				= "暗影包围！远离我！"
})

--------------
--  Magmaw  --
--------------
L = DBM:GetModLocalization(170)

L:SetWarningLocalization({
	SpecWarnInferno	= "炽焰白骨结构体即将出现（约4秒）"
})

L:SetOptionLocalization({
	SpecWarnInferno	= "特殊警报：$spell:92190即将施放（约4秒）",
	RangeFrame		= "在第2阶段显示距离监视器（5码）"
})

L:SetMiscLocalization({
	Slump			= "%s向前倒下，暴露出他的钳子！",
	HeadExposed		= "%s将自己钉在刺上，露出了他的头！",
	YellPhase2		= "难以置信，你们竟然真要击败我的熔岩巨虫了！也许我可以帮你们……扭转局势。"
})

-----------------
--  Atramedes  --
-----------------
L = DBM:GetModLocalization(171)

L:SetOptionLocalization({
	InfoFrame				= "信息框：团员声音等级列表",
	TrackingIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(78092)
})

L:SetMiscLocalization({
	NefAdd					= "艾卓曼德斯，那些英雄就在那边！",
	Airphase				= "对，跑吧！每跑一步你的心跳都会加快。这心跳声，洪亮如雷，震耳欲聋。你逃不掉的！"
})

-----------------
--  Chimaeron  --
-----------------
L = DBM:GetModLocalization(172)

L:SetOptionLocalization({
	RangeFrame		= "距离监视器（6码）",
	SetIconOnSlime	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82935),
	InfoFrame		= "信息框：生命值小于1万的团员的列表"
})

L:SetMiscLocalization({
	HealthInfo	= "生命值"
})

----------------
--  Maloriak  --
----------------
L = DBM:GetModLocalization(173)

L:SetWarningLocalization({
	WarnPhase			= "%s阶段",
})

L:SetTimerLocalization({
	TimerPhase			= "下一阶段"
})

L:SetOptionLocalization({
	WarnPhase			= "警报：阶段变化",
	TimerPhase			= "计时条：下一阶段",
	RangeFrame			= "在蓝瓶阶段显示距离监视器（6码）",
	SetTextures			= "在黑暗阶段自动取消材质投射效果（当阶段结束时会自动恢复）",
	FlashFreezeIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92979),
	BitingChillIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(77760),
	ConsumingFlamesIcon	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(77786)
})

L:SetMiscLocalization({
	YellRed				= "红瓶|r扔进了大锅里！",--Partial matchs, no need for full strings unless you really want em, mod checks for both.
	YellBlue			= "蓝瓶|r扔进了大锅里！",
	YellGreen			= "绿瓶|r扔进了大锅里！",
	YellDark			= "黑暗|r魔法！"
})

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization(174)

L:SetWarningLocalization({
	OnyTailSwipe			= "龙尾扫击（奥妮克希亚）",
	NefTailSwipe			= "龙尾扫击（奈法利安）",
	OnyBreath				= "暗影烈焰吐息（奥妮克希亚）",
	NefBreath				= "暗影烈焰吐息（奈法利安）",
	specWarnShadowblazeSoon	= "%s",
	warnShadowblazeSoon		= "%s"
})

L:SetTimerLocalization({
	timerNefLanding			= "奈法利安着陆",
	OnySwipeTimer			= "龙尾扫击冷却（奥妮克希亚）",
	NefSwipeTimer			= "龙尾扫击冷却（奈法利安）",
	OnyBreathTimer			= "吐息冷却（奥妮克希亚）",
	NefBreathTimer			= "吐息冷却（奈法利安）"
})

L:SetOptionLocalization({
	OnyTailSwipe			= "警报：奥妮克希亚的$spell:77827",
	NefTailSwipe			= "警报：奈法利安的$spell:77827",
	OnyBreath				= "警报：奥妮克希亚的$spell:94124",
	NefBreath				= "警报：奈法利安的$spell:94124",
	specWarnCinderMove		= "特殊警报：当你受到$spell:79339影响需要移动时（爆炸前5秒）",
	warnShadowblazeSoon		= "提前警报：$spell:81031（5秒）（为保证精确性，仅当暗影爆燃时间同步后才会显示确切时间警报）",
	specWarnShadowblazeSoon	= "特殊警报：$spell:81031即将施放（为保证精确性，第一次<br/>提前5秒，在暗影爆燃时间同步后提前1秒警报）",
	timerNefLanding			= "计时条：奈法利安着陆",
	OnySwipeTimer			= "计时条：奥妮克希亚的$spell:77827冷却时间",
	NefSwipeTimer			= "计时条：奈法利安的$spell:77827冷却时间",
	OnyBreathTimer			= "计时条：奥妮克希亚的$spell:94124冷却时间",
	NefBreathTimer			= "计时条：奈法利安的$spell:94124冷却时间",
	InfoFrame				= "信息框：奥妮克希亚的电能",
	SetWater				= "在拉怪时自动取消水体碰撞效果（战斗结束后会自动恢复）",
	SetIconOnCinder			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(79339),
	RangeFrame				= "为$spell:79339显示距离监视器（10码）",-- Shows everyone if you have debuff, only players with icons if not
	FixShadowblaze        = "自动同步$spell:94085时间（实验功能，利用首领的喊话进行同步）",
})

L:SetMiscLocalization({
	NefAoe					= "空气中激荡的电流噼啪作响！",
	YellPhase2				= "诅咒你们，凡人！你们丝毫不尊重他人财产的行为必须受到严厉处罚！",
	YellPhase3				= "我一直在尝试扮演好客的主人，可你们就是不肯受死！该卸下伪装了……杀光你们！",
	YellShadowBlaze			= "血肉化为灰烬！",
	ShadowBlazeExact		= "%d秒后暗影爆燃火花",
	ShadowBlazeEstimate		= "暗影爆燃火花即将施放（约5秒）"
})

-------------------------------
--  Blackwing Descent Trash  --
-------------------------------
L = DBM:GetModLocalization("BWDTrash")

L:SetGeneralLocalization({
	name = "黑翼血环小怪"
})

--------------------------
--  Halfus Wyrmbreaker  --
--------------------------
L = DBM:GetModLocalization(156)

L:SetOptionLocalization({
	ShowDrakeHealth		= "显示已释放幼龙的生命值（需要开启首领生命值显示）"
})

---------------------------
--  Valiona & Theralion  --
---------------------------
L = DBM:GetModLocalization(157)

L:SetOptionLocalization({
	TBwarnWhileBlackout		= "警报：$spell:86788时的$spell:92898",
	TwilightBlastArrow		= "DBM箭头：当有$spell:92898的目标在你附近时",
	RangeFrame				= "距离监视器（10码）",
	BlackoutShieldFrame		= "为$spell:92878显示首领血量条",
	BlackoutIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92878),
	EngulfingIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(86622)
})

L:SetMiscLocalization({
	Trigger1				= "深呼吸",
	BlackoutTarget			= "眩晕：%s"
})

----------------------------------
--  Twilight Ascendant Council  --
----------------------------------
L = DBM:GetModLocalization(158)

L:SetWarningLocalization({
	specWarnBossLow			= "%s生命值低于30%% - 下一阶段即将开始",
	SpecWarnGrounded		= "快去接触融入大地",
	SpecWarnSearingWinds	= "快去接触旋风上抛"
})

L:SetTimerLocalization({
	timerTransition			= "阶段转换"
})

L:SetOptionLocalization({
	specWarnBossLow			= "特殊警报：首领生命值低于30%",
	SpecWarnGrounded		= "特殊警报：缺少$spell:83581效果（对应技能施放10秒前警报）",
	SpecWarnSearingWinds	= "特殊警报：缺少$spell:83500效果（对应技能施放10秒前警报）",
	timerTransition			= "计时条：阶段转换",
	RangeFrame				= "在需要时自动显示距离监视器",
	yellScrewed				= "当你同时受到$spell:83099和$spell:92307影响时大喊",
	InfoFrame				= "信息框：没有$spell:83581或$spell:83500效果的团员的列表",
	HeartIceIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82665),
	BurningBloodIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(82660),
	LightningRodIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(83099),
	GravityCrushIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(84948),
	FrostBeaconIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92307),
	StaticOverloadIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92067),
	GravityCoreIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(92075)
})

L:SetMiscLocalization({
	Quake			= "你脚下的地面发出不祥的“隆隆”声……",
	Thundershock	= "周围的空气因为充斥着强大的能量而发出“噼啪”声……",
	Switch			= "停止你的愚行！",--"We will handle them!" comes 3 seconds after this one
	Phase3			= "令人印象深刻……",--"BEHOLD YOUR DOOM!" is about 13 seconds after
	Kill			= "这不可能……",
	blizzHatesMe	= "我中了冰霜道标和闪电魔棒！快让路！",--You're probably fucked, and gonna kill half your raid if this happens, but worth a try anyways :).
	WrongDebuff	= "没有 %s"
})

----------------
--  Cho'gall  --
----------------
L = DBM:GetModLocalization(167)

L:SetOptionLocalization({
	CorruptingCrashArrow	= "DBM箭头：当$spell:93178在你附近时",
	InfoFrame				= "信息框：$journal:3165",
	RangeFrame				= "为$spell:82235显示距离监视器（5码）",
	SetIconOnWorship		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(91317)
})

----------------
--  Sinestra  --
----------------
L = DBM:GetModLocalization(168)

L:SetWarningLocalization({
	WarnOrbSoon			= "暗影宝珠 %d秒后出现",
	WarnEggWeaken		= "龙蛋上的暮光龙鳞消失了",
	SpecWarnOrbs		= "暗影宝珠即将出现！小心！",
	warnWrackJump		= "%s跳到>%s<",
	warnAggro			= "拥有仇恨的团员（宝珠可能的目标）：>%s< ",
	SpecWarnAggroOnYou	= "获得仇恨！小心宝珠！"
})

L:SetTimerLocalization({
	TimerEggWeakening	= "暮光龙鳞消失",
	TimerEggWeaken		= "暮光龙鳞再生",
	TimerOrbs			= "暗影宝珠冷却"
})

L:SetOptionLocalization({
	WarnOrbSoon			= "提前警报：暗影宝珠（5秒前，每秒警报一次。不精确）",
	WarnOrbsSoon		= "提前警报：暗影宝珠（5秒前，每秒警报一次。不精确）",
	WarnEggWeaken		= "提前警报：$spell:87654消失",
	warnWrackJump		= "警报：$spell:92955跳跃的目标",
	WarnWrackCount5s	= "警报：当$spell:92955在某一团员身上持续了10、15和20秒时",
	warnAggro			= "警报：暗影宝珠刷新时拥有仇恨的团员（可能成为宝珠的目标）",
	SpecWarnAggroOnYou	= "特殊警报：当宝珠刷新时你获得仇恨（可能成为宝珠的目标）",
	SpecWarnOrbs		= "特殊警报：宝珠即将刷新（预计时间，不精确）",
	SpecWarnDispel		= "特殊警报：提醒驱散$spell:92955（在效果施放或跳跃后的特定时间警报）",
	TimerEggWeakening	= "计时条：$spell:87654消失",
	TimerEggWeaken		= "计时条：$spell:87654再生",
	TimerOrbs			= "计时条：暗影宝珠冷却时间",
	SetIconOnOrbs		= "在暗影宝珠刷新时自动为获得仇恨的团员添加团队标记<br/>（可能成为宝珠的目标）",
	InfoFrame			= "信息框：获得仇恨的团员的列表"
})

L:SetMiscLocalization({
	YellDragon			= "吃吧，孩子们！尽情享用他们肥美的躯壳吧！",
	YellEgg				= "你以为就这么简单？愚蠢！",
	HasAggro			= "获得仇恨"
})

-------------------------------------
--  The Bastion of Twilight Trash  --
-------------------------------------
L = DBM:GetModLocalization("BoTrash")

L:SetGeneralLocalization({
	name =	"暮光堡垒小怪"
})

------------------------
--  Conclave of Wind  --
------------------------
L = DBM:GetModLocalization(154)

L:SetWarningLocalization({
	warnSpecial			= "飓风/微风/暴雨",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial		= "特殊技能启动！",
	warnSpecialSoon		= "特殊技能10秒后启动！"
})

L:SetTimerLocalization({
	timerSpecial		= "特殊技能冷却",
	timerSpecialActive	= "特殊技能"
})

L:SetOptionLocalization({
	warnSpecial			= "警报：飓风/微风/暴雨",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial		= "特殊警报：特殊技能的施放",
	timerSpecial		= "计时条：特殊技能冷却时间",
	timerSpecialActive	= "计时条：特殊技能持续时间",
	warnSpecialSoon		= "提前警报：特殊技能即将施放（10秒前）",
	OnlyWarnforMyTarget	= "只显示当前或焦点目标首领的警报和计时条（隐藏其他首领。包括拉怪）"
})

L:SetMiscLocalization({
	gatherstrength	= "gather shtrenth" -- die
})

---------------
--  Al'Akir  --
---------------
L = DBM:GetModLocalization(155)

L:SetTimerLocalization({
	TimerFeedback 	= "回馈（%d）"
})

L:SetOptionLocalization({
	LightningRodIcon= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(89668),
	TimerFeedback	= "计时条：$spell:87904持续时间",
	RangeFrame		= "当你中了$spell:89668时显示距离监视器（20码）"
})

-----------------
-- Beth'tilac --
-----------------
L= DBM:GetModLocalization(192)

L:SetMiscLocalization({
	EmoteSpiderlings 	= "幼蛛从巢穴里爬出来了！"
})

-------------------
-- Lord Rhyolith --
-------------------
L= DBM:GetModLocalization(193)

---------------
-- Alysrazor --
---------------
L= DBM:GetModLocalization(194)

L:SetWarningLocalization({
	WarnPhase			= "第%d阶段",
	WarnNewInitiate		= "炽炎之爪新兵（%s）"
})

L:SetTimerLocalization({
	TimerPhaseChange	= "第%d阶段",
	TimerHatchEggs		= "下一波蛋",
	timerNextInitiate	= "下一个新兵（%s）"
})

L:SetOptionLocalization({
	WarnPhase			= "警报：每次阶段转换",
	WarnNewInitiate		= "警报：新的炽炎之爪新兵",
	timerNextInitiate	= "计时条：下一个炽炎之爪新兵",
	TimerPhaseChange	= "计时条：下一阶段",
	TimerHatchEggs		= "计时条：下一波蛋孵化"
})

L:SetMiscLocalization({
	YellPull		= "凡人们，我现在侍奉新的主人！",
	YellPhase2		= "天空，归我统治！",
	LavaWorms		= "熔岩火虫从地下涌出来了！",--Might use this one day if i feel it needs a warning for something. Or maybe pre warning for something else (like transition soon)
	PowerLevel		= "熔火之羽",
	East			= "东",
	West			= "西",
	Both			= "两侧"
})

-------------
-- Shannox --
-------------
L= DBM:GetModLocalization(195)

-------------
-- Baleroc --
-------------
L= DBM:GetModLocalization(196)

L:SetWarningLocalization({
	warnStrike	= "%s（%d）"
})

L:SetTimerLocalization({
	timerStrike			= "下一次%s",
	TimerBladeActive	= "%s",
	TimerBladeNext		= "下一次贝尔洛克之剑"
})

L:SetOptionLocalization({
	ResetShardsinThrees	= "每3秒（25人）/2秒（10人）重置$spell:99259的倒数计时",
	warnStrike			= "警报：毁灭之刃或地狱火之刃",
	timerStrike			= "计时条：下一次毁灭之刃或地狱火之刃",
	TimerBladeActive	= "计时条：当前贝尔洛克之剑的持续时间",
	TimerBladeNext		= "计时条：下一次贝尔洛克之剑"
})

--------------------------------
-- Majordomo Fandral Staghelm --
--------------------------------
L= DBM:GetModLocalization(197)

L:SetTimerLocalization({
	timerNextSpecial	= "下一次%s（%d）"
})

L:SetOptionLocalization({
	timerNextSpecial			= "计时条：下一次特殊技能",
	RangeFrameSeeds				= "距离监视器（12码）：应对$spell:98450",
	RangeFrameCat				= "距离监视器（10码）：应对$spell:98374"
})

--------------
-- Ragnaros --
--------------
L= DBM:GetModLocalization(198)

L:SetWarningLocalization({
	warnSplittingBlow		= "%s在%s",--Spellname in Location
	warnEngulfingFlame		= "%s在%s",--Spellname in Location
	warnEmpoweredSulf		= "%s - 5秒后施放"--The spell has a 5 second channel, but tooltip doesn't reflect it so cannot auto localize
})

L:SetTimerLocalization({
	TimerPhaseSons		= "阶段转换"
})

L:SetOptionLocalization({
	warnRageRagnarosSoon		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.prewarn:format(101109),
	warnSplittingBlow			= "警报：$spell:100877的位置",
	warnEngulfingFlame			= "警报：$spell:99171",
	WarnEngulfingFlameHeroic	= "警报：英雄模式下$spell:99171的位置",
	warnSeedsLand				= "警报与计时条：$spell:98520落地，而非施法警报",
	warnEmpoweredSulf			= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(100997),
	timerRageRagnaros			= DBM_CORE_L.AUTO_TIMER_OPTIONS.cast:format(101109),
	TimerPhaseSons				= "计时条：烈焰之子阶段持续时间",
	InfoHealthFrame				= "信息框：生命值少于10万的团员的列表",
	MeteorFrame					= "信息框：$spell:99849的目标",
	AggroFrame					= "信息框：没有获得熔岩元素仇恨的团员的列表"
})

L:SetMiscLocalization({
	East				= "场景东部",
	West				= "场景西部",
	Middle				= "场景中部",
	North				= "近战范围",
	South				= "场景后方",
	HealthInfo			= "生命值少于10万",
	HasNoAggro			= "未获仇恨",
	MeteorTargets		= "看！流星灰过来咯！",--Keep rollin' rollin' rollin' rollin'.
	TransitionEnded1	= "够了！我会亲自解决。",--More reliable then adds method.
	TransitionEnded2	= "萨弗拉斯将会是你的末日。",
	TransitionEnded3	= "跪下吧，凡人们！一切都结束了。",
	Defeat				= "太早了！……你们来得太早了……",
	Phase4				= "太早了……"
})

-----------------------
--  Firelands Trash  --
-----------------------
L = DBM:GetModLocalization("FirelandsTrash")

L:SetGeneralLocalization({
	name = "火焰之地小怪"
})

----------------
--  Volcanus  --
----------------
L = DBM:GetModLocalization("Volcanus")

L:SetGeneralLocalization({
	name = "沃卡纳斯"
})

L:SetTimerLocalization({
	timerStaffTransition	= "阶段转换"
})

L:SetOptionLocalization({
	timerStaffTransition	= "计时条：阶段转换"
})

L:SetMiscLocalization({
	StaffEvent			= "%S+的触摸令诺达希尔的分枝产生了强烈反应！",--Reg expression pull match
	StaffTrees			= "烈焰树人从地下涌出，来协助保护者了！",--Might add a spec warning for this later.
	StaffTransition		= "受折磨的保护者身上一直燃烧着的火焰熄灭了！"
})

-----------------------
--  Nexus Legendary  --
-----------------------
L = DBM:GetModLocalization("NexusLegendary")

L:SetGeneralLocalization({
	name = "泰林纳尔"
})

-------------
-- Morchok --
-------------
L= DBM:GetModLocalization(311)

L:SetWarningLocalization({
	KohcromWarning	= "%s：%s"--Bossname, spellname. At least with this we can get boss name from casts in this one, unlike a timer started off the previous bosses casts.
})

L:SetTimerLocalization({
	KohcromCD		= "克卓莫模拟%s",--Universal single local timer used for all of his mimick timers
})

L:SetOptionLocalization({
	KohcromWarning	= "警报：$journal:4262模拟技能",
	KohcromCD		= "计时条：下一次$journal:4262模拟技能",
	RangeFrame		= "距离监视器（5码）：应对成就需求"
})

L:SetMiscLocalization({
})

---------------------
-- Warlord Zon'ozz --
---------------------
L= DBM:GetModLocalization(324)

L:SetOptionLocalization({
	ShadowYell			= "当你受到$spell:104600影响时时大喊（英雄难度）",
	CustomRangeFrame	= "距离监视器选项（英雄难度）",
	Never				= "关闭",
	Normal				= "普通距离监视",
	DynamicPhase2		= "第2阶段根据状态动态监视",
	DynamicAlways		= "总是根据状态动态监视"
})

L:SetMiscLocalization({
	voidYell	= "Gul'kafh an'qov N'Zoth."--Start translating the yell he does for Void of the Unmaking cast, the latest logs from DS indicate blizz removed the event that detected casts. sigh.
})

-----------------------------
-- Yor'sahj the Unsleeping --
-----------------------------
L= DBM:GetModLocalization(325)

L:SetWarningLocalization({
	warnOozesHit	= "%s吸收了%s"
})

L:SetTimerLocalization({
	timerOozesActive	= "软泥怪可攻击"
})

L:SetOptionLocalization({
	warnOozesHit		= "警报：软泥怪种类",
	timerOozesActive	= "计时条：软泥怪可攻击",
	RangeFrame			= "距离监视器（4码）：应对$spell:104898（普通和英雄难度）"
})

L:SetMiscLocalization({
	Black			= "|cFF424242黑色|r",
	Purple			= "|cFF9932CD紫色|r",
	Red				= "|cFFFF0404红色|r",
	Green			= "|cFF088A08绿色|r",
	Blue			= "|cFF0080FF蓝色|r",
	Yellow			= "|cFFFFA901黄色|r"
})

-----------------------
-- Hagara the Binder --
-----------------------
L= DBM:GetModLocalization(317)

L:SetWarningLocalization({
	WarnPillars				= "%s：剩余%d",
	warnFrostTombCast		= "%s - 8秒后施放"
})

L:SetTimerLocalization({
	TimerSpecial			= "第一次特殊技能"
})

L:SetOptionLocalization({
	WarnPillars				= "警报：$journal:3919或$journal:4069剩余数量", -- bad grammer?
	TimerSpecial			= "计时条：第一次特殊技能施放",
	RangeFrame				= "距离监视器（3码）：应对$spell:105269 |（10码）：应对$journal:4327",
	AnnounceFrostTombIcons	= "向团队频道通报$spell:104451目标的团队标记（需要团队领袖权限）",
	warnFrostTombCast		= DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.cast:format(104448),
	SetIconOnFrostTomb		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(104451),
	SetIconOnFrostflake		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(109325),
	SpecialCount			= "倒计时声音警报：$spell:105256或$spell:105465",
	SetBubbles				= "在$spell:104451阶段自动关闭聊天气泡（战斗结束后自动恢复）"
})

L:SetMiscLocalization({
	TombIconSet				= "寒冰之墓标记{rt%d} -> %s"
})

---------------
-- Ultraxion --
---------------
L= DBM:GetModLocalization(331)

L:SetWarningLocalization({
	specWarnHourofTwilightN		= "%s (%d) - 5秒后施放"--spellname Count
})

L:SetTimerLocalization({
	TimerCombatStart	= "战斗即将开始"
})

L:SetOptionLocalization({
	TimerCombatStart	= "计时条：战斗即将开始",
	ResetHoTCounter		= "重新开始目光审判计数器",--$spell doesn't work in this function apparently so use typed spellname for now.
	Never				= "从不",
	ResetDynamic		= "每3/2次（英雄/普通难度）重置一次",
	Reset3Always		= "总是每3次进行重置",
	SpecWarnHoTN		= "特殊警报：目光审判施放5秒前（仅针对每3次重置）",
	One					= "1 (如 1 4 7)",
	Two					= "2 (如 2 5)",
	Three				= "3 (如 3 6)"
})

L:SetMiscLocalization({
	Pull				= "一股破坏平衡的力量正在接近。它的混乱灼烧着我的心智！"
})

-------------------------
-- Warmaster Blackhorn --
-------------------------
L= DBM:GetModLocalization(332)

L:SetWarningLocalization({
	SpecWarnElites	= "暮光精英！"
})

L:SetTimerLocalization({
	TimerCombatStart	= "战斗即将开始",
	TimerAdd			= "下一波暮光精英"
})

L:SetOptionLocalization({
	TimerCombatStart	= "计时条：战斗即将开始",
	TimerAdd			= "计时条：下一波暮光精英",
	SpecWarnElites		= "特殊警报：新的暮光精英出现",
	SetTextures			= "在第1阶段自动禁用材质投射（第2阶段自动恢复）"
})

L:SetMiscLocalization({
	SapperEmote			= "一条幼龙俯冲下来，往甲板上投放了一个暮光工兵！",
	GorionaRetreat		= "痛苦地尖叫并退入了云海的漩涡中"
})

-------------------------
-- Spine of Deathwing  --
-------------------------
L= DBM:GetModLocalization(318)

L:SetWarningLocalization({
	SpecWarnTendril			= "小心翻身！"
})

L:SetOptionLocalization({
	SpecWarnTendril			= "特殊警报：当你没有$spell:109454效果时",
	InfoFrame				= "信息框：没有$spell:109454效果的玩家",
	SetIconOnGrip			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(109459),
	ShowShieldInfo			= "首领生命值信息框：应对$spell:105479"
})

L:SetMiscLocalization({
	Pull			= "看那些装甲！他正在解体！摧毁那些装甲，我们就能给他最后一击！",
	NoDebuff		= "没有%s",
	PlasmaTarget	= "灼热血浆：%s",
	DRoll			= "侧翻滚！",
	DLevels			= "保持平衡" -- 保持平衡
})

---------------------------
-- Madness of Deathwing  --
---------------------------
L= DBM:GetModLocalization(333)

L:SetOptionLocalization({
	RangeFrame			= "距离监视器（根据状态动态变化）：应对$spell:108649（英雄难度）",
	SetIconOnParasite	= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(108649)
})

L:SetMiscLocalization({
	Pull				= "你们什么都没做到。我要撕碎你们的世界。"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("DSTrash")

L:SetGeneralLocalization({
	name =	"巨龙之魂小怪"
})

L:SetWarningLocalization({
	DrakesLeft			= "暮光突袭者剩余：%d"
})

L:SetTimerLocalization({
	TimerDrakes			= "%s"--spellname from mod
})

L:SetOptionLocalization({
	DrakesLeft			= "警报：暮光突袭者剩余数量",
	TimerDrakes			= "计时条：暮光突袭者何时$spell:109904"
})

L:SetMiscLocalization({
	EoEEvent			= "这没有用，巨龙之魂的力量太强大了。",--Partial
	UltraxionTrash		= "重逢真令我高兴，阿莱克斯塔萨。分开之后，我可是一直很忙。"
})
