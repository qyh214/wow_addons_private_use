if GetLocale() ~= "zhTW"  then return end
local L

----------------
--  Argaloth  --
----------------
L= DBM:GetModLocalization(139)

-----------------
--  Occu'thar  --
-----------------
L= DBM:GetModLocalization(140)

----------------------------------
--  Alizabal, Mistress of Hate  --
----------------------------------
L= DBM:GetModLocalization(339)

L:SetTimerLocalization({
	TimerFirstSpecial		= "特別技能"
})

L:SetOptionLocalization({
	TimerFirstSpecial		= "為下一次的特別技能$spell:105738顯示計時器<br/>(特別技能是隨機性的。技能為$spell:105067或$spell:104936)"
})

-------------------------------
--  Dark Iron Golem Council  --
-------------------------------
L = DBM:GetModLocalization(169)

L:SetWarningLocalization({
	SpecWarnActivated			= "轉換目標到 %s!",
	specWarnGenerator			= "發電機 - 拉開%s!"
})

L:SetTimerLocalization({
	timerShadowConductorCast	= "聚影體",
	timerArcaneLockout			= "秘法殲滅者鎖定",
	timerArcaneBlowbackCast		= "秘法逆爆",
	timerNefAblity				= "技能增益冷卻"
})

L:SetOptionLocalization({
	timerShadowConductorCast	= "為$spell:92048的施放顯示計時器",
	timerArcaneLockout			= "為$spell:79710法術鎖定顯示計時器",
	timerArcaneBlowbackCast		= "為$spell:91879的施放顯示計時器",
	timerNefAblity				= "為困難技能增益冷卻顯示計時器",
	SpecWarnActivated			= "當新首領啟動時顯示特別警告",
	specWarnGenerator			= "當首領獲得$spell:91557時顯示特別警告",
	SetIconOnActivated			= "設置標記到最後啟動的首領"
})

L:SetMiscLocalization({
	YellTargetLock				= "覆體之影! 遠離我!"
})

--------------
--  Magmaw  --
--------------
L = DBM:GetModLocalization(170)

L:SetWarningLocalization({
	SpecWarnInferno		= "熾熱的煉獄即將到來(約4秒前)"
})

L:SetOptionLocalization({
	SpecWarnInferno		= "為$spell:92190顯示預先特別警告(約4秒前)",
	RangeFrame			= "第2階段時顯示距離框(5碼)"
})

L:SetMiscLocalization({
	Slump				= "%s往前撲倒，露出他的鉗子!",
	HeadExposed			= "%s被釘在尖刺上，露出了他的頭!",
	YellPhase2			= "真難想像!看來你真有機會打敗我的蟲子!也許我可幫忙...扭轉戰局。"
})

-----------------
--  Atramedes  --
-----------------
L = DBM:GetModLocalization(171)

L:SetOptionLocalization({
	InfoFrame				= "為$journal:3072顯示資訊框架"
})

L:SetMiscLocalization({
	NefAdd					= "亞特拉米德，英雄們就在那!",
	Airphase				= "沒錯，逃吧!每一步都會讓你的心跳加速。跳得轟隆作響...震耳欲聾。你逃不掉的!"
})

-----------------
--  Chimaeron  --
-----------------
L = DBM:GetModLocalization(172)

L:SetOptionLocalization({
	RangeFrame				= "顯示距離框 (6碼)",
	InfoFrame			 	= "為血量(低於1萬血)顯示資訊框架"
})

L:SetMiscLocalization({
	HealthInfo				= "血量資訊"
})

----------------
--  Maloriak  --
----------------
L = DBM:GetModLocalization(173)

L:SetWarningLocalization({
	WarnPhase				= "%s階段"
})

L:SetTimerLocalization({
	TimerPhase				= "下一階段"
})

L:SetOptionLocalization({
	WarnPhase				= "為哪個階段即將到來顯示警告",
	TimerPhase				= "為下一階段顯示計時器",
	RangeFrame				= "藍色階段時顯示距離框 (6碼)",
	SetTextures				= "自動在黑暗階段停用投影材質<br/>(離開黑暗階段後回到啟用)"
})

L:SetMiscLocalization({
	YellRed				= "紅色|r瓶子到鍋子裡!",
	YellBlue			= "藍色|r瓶子到鍋子裡!",
	YellGreen			= "綠色|r瓶子到鍋子裡!",
	YellDark			= "黑暗|r魔法到鍋子裡!"
})

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization(174)

L:SetWarningLocalization({
	OnyTailSwipe			= "尾部鞭擊 (奧妮克希亞)",
	NefTailSwipe			= "尾部鞭擊 (奈法利安)",
	OnyBreath				= "暗影焰息 (奧妮克希亞)",
	NefBreath				= "暗影焰息 (奈法利安)",
	specWarnShadowblazeSoon	= "%s",
	warnShadowblazeSoon		= "%s"
})

L:SetTimerLocalization({
	timerNefLanding			= "奈法利安落地",
	OnySwipeTimer			= "尾部鞭擊冷卻 (奧妮)",
	NefSwipeTimer			= "尾部鞭擊冷卻 (奈法)",
	OnyBreathTimer			= "暗影焰息冷卻 (奧妮)",
	NefBreathTimer			= "暗影焰息冷卻 (奈法)"
})

L:SetOptionLocalization({
	OnyTailSwipe			= "為奧妮克希亞的$spell:77827顯示警告",
	NefTailSwipe			= "為奈法利安的$spell:77827顯示警告",
	OnyBreath				= "為奧妮克希亞的$spell:77826顯示警告",
	NefBreath				= "為奈法利安的$spell:77826顯示警告",
	specWarnCinderMove		= "為$spell:79339顯示特殊警告提示你離開(爆炸前5秒)",
	warnShadowblazeSoon		= "為$spell:81031顯示提前警告<br/>(只在計時器與第一次大喊台詞同步後顯示, 以確保準確)",
	specWarnShadowblazeSoon	= "為$spell:94085顯示預先特別警告(約5秒)",
	timerNefLanding			= "為奈法利安落地顯示計時器",
	OnySwipeTimer			= "為奧妮克希亞的$spell:77827的冷卻時間顯示計時器",
	NefSwipeTimer			= "為奈法利安的$spell:77827的冷卻時間顯示計時器",
	OnyBreathTimer			= "為奧妮克希亞的$spell:77826的冷卻時間顯示計時器",
	NefBreathTimer			= "為奈法利安的$spell:77826的冷卻時間顯示計時器",
	InfoFrame				= "為$journal:3284顯示資訊框架",
	SetWater				= "進入戰鬥後自動停用水體細節<br/>(離開戰鬥後回到啟用)",
	RangeFrame				= "為$spell:79339顯示距離框(10碼)<br/>(當你中減益時顯示所有人, 否則只顯示中的人)"
})

L:SetMiscLocalization({
	NefAoe					= "響起了電流霹啪作響的聲音!",
	YellPhase2 				= "詛咒你們，凡人!如此冷酷地漠視他人的所有物必須受到嚴厲的懲罰!",
	YellPhase3				= "我本來只想略盡地主之誼，但是你們就是不肯痛快的受死!是時候拋下一切的虛偽...殺光你們就好!",
	YellShadowBlaze			= "化為灰燼吧!",
	ShadowBlazeExact		= "暗影炎%d秒",
	ShadowBlazeEstimate		= "暗影炎即將到來(約5秒後)"
})

-------------------------------
--  Blackwing Descent Trash  --
-------------------------------
L = DBM:GetModLocalization("BWDTrash")

L:SetGeneralLocalization({
	name = "黑翼陷窟小怪"
})

--------------------------
--  Halfus Wyrmbreaker  --
--------------------------
L= DBM:GetModLocalization(156)

L:SetOptionLocalization({
	ShowDrakeHealth		= "顯示已被釋放的小龍血量<br/>(需要先開啟首領血量)"
})

---------------------------
--  Valiona & Theralion  --
---------------------------
L= DBM:GetModLocalization(157)

L:SetOptionLocalization({
	TBwarnWhileBlackout	= "當$spell:86369生效時顯示$spell:86788警告",
	TwilightBlastArrow	= "當你附近的人中了$spell:86369時顯示DBM箭頭",
	RangeFrame			= "顯示距離框(10碼)",
	BlackoutShieldFrame	= "為$spell:86788顯示首領血量條"
})

L:SetMiscLocalization({
	Trigger1			= "深呼吸",
	BlackoutTarget		= "昏天暗地:%s"
})

----------------------------------
--  Twilight Ascendant Council  --
----------------------------------
L= DBM:GetModLocalization(158)

L:SetWarningLocalization({
	specWarnBossLow			= "%s血量低於30%% - 即將進入下一階段!",
	SpecWarnGrounded		= "拿取禁錮增益",
	SpecWarnSearingWinds	= "拿取旋風增益"
})

L:SetTimerLocalization({
	timerTransition			= "階段轉換"
})

L:SetOptionLocalization({
	specWarnBossLow			= "當首領血量低於30%時顯示特別警告",
	SpecWarnGrounded		= "當你缺少$spell:83581時顯示特別警告<br/>(大約施放前10秒內)",
	SpecWarnSearingWinds	= "當你缺少$spell:83500時顯示特別警告<br/>(大約施放前10秒內)",
	timerTransition			= "顯示階段轉換計時器",
	RangeFrame	 			= "當需要時自動顯示距離框",
	yellScrewed				= "當你同時有$spell:83099和$spell:92307時大喊",
	InfoFrame				= "顯示沒有$spell:83581或$spell:83500的玩家"
})

L:SetMiscLocalization({
	Quake			= "你腳下的地面開始不祥地震動起來....",
	Thundershock	= "四周的空氣爆出能量霹啪作響聲音....",
	Switch			= "我們會解決他們!",
	Phase3			= "見證你的滅亡!",
	Kill			= "不可能...",
	blizzHatesMe	= "我中了冰凍寶珠和聚雷針!清出一條路來!",
	WrongDebuff	    = "無%s"
})

----------------
--  Cho'gall  --
----------------
L= DBM:GetModLocalization(167)

L:SetOptionLocalization({
	CorruptingCrashArrow	= "當你附近的人中了$spell:81685時顯示DBM箭頭",
	InfoFrame				= "為$journal:3165顯示資訊框架",
	RangeFrame				= "為$journal:3165顯示距離框(5碼)"
})

----------------
--  Sinestra  --
----------------
L= DBM:GetModLocalization(168)

L:SetWarningLocalization({
	WarnOrbSoon			= "暗影寶珠在%d秒!",
	SpecWarnOrbs		= "暗影寶珠!小心!",
	warnWrackJump		= "%s跳到>%s<",
	warnAggro			= ">%s<為暗影寶珠的目標(可能的目標)",
	SpecWarnAggroOnYou	= "小心暗影寶珠!"
})

L:SetTimerLocalization({
	TimerEggWeakening	= "暮光殼甲消散",
	TimerEggWeaken		= "暮光殼甲重生",
	TimerOrbs			= "下一次暗影寶珠"
})

L:SetOptionLocalization({
	WarnOrbSoon			= "提前警告暗影寶珠(5秒前, 每1秒)<br/>(猜測的時間，可能不準確)",
	warnWrackJump		= "提示$spell:89421的目標",
	warnAggro			= "提示玩家暗影寶珠的目標(可能的目標)",
	SpecWarnAggroOnYou	= "顯示特別警告當你是暗影寶珠的目標時<br/>(可能的目標)",
	SpecWarnOrbs		= "顯示特別警告暗影寶珠施放(猜測的警告)",
	TimerEggWeakening	= "顯示$spell:87654消散的計時器",
	TimerEggWeaken		= "顯示$spell:87654重生的計時器",
	TimerOrbs			= "顯示下一個暗影寶珠的計時器(猜測的時間，可能不準確)",
	SetIconOnOrbs		= "標記圖示給暗影寶珠的目標(可能的目標)",
	InfoFrame			= "為有仇恨的玩家顯示訊息框"
})

L:SetMiscLocalization({
	YellDragon			= "吃吧，孩子們!好好享用他們肥嫩的軀殼吧!",
	YellEgg				= "你以為這樣就佔了上風?愚蠢!",
	HasAggro			= "有仇恨"
})

-------------------------------------
--  The Bastion of Twilight Trash  --
-------------------------------------
L = DBM:GetModLocalization("BoTrash")

L:SetGeneralLocalization({
	name =	"暮光堡壘小怪"
})

------------------------
--  Conclave of Wind  --
------------------------
L = DBM:GetModLocalization(154)

L:SetWarningLocalization({
	warnSpecial		= "颶風/微風/冰雨風暴啟動",
	specWarnSpecial	= "特別技能啟動!",
	warnSpecialSoon	= "10秒後特別技能啟動!"
})

L:SetTimerLocalization({
	timerSpecial		= "特別技能冷卻",
	timerSpecialActive	= "特別技能啟動"
})

L:SetOptionLocalization({
	warnSpecial			= "當颶風/微風/冰雨風暴施放時顯示警告",
	specWarnSpecial		= "當特別技能施放時顯示特別警告",
	timerSpecial		= "為特別技能冷卻顯示計時器",
	timerSpecialActive	= "為特別技能持續時間顯示計時器",
	warnSpecialSoon		= "特別技能施放前10秒顯示預先警告",
	OnlyWarnforMyTarget	= "只為當前或焦點目標顯示警告<br/>(隱藏所有其他。這包括進入戰鬥)"
})

L:SetMiscLocalization({
	gatherstrength	= "開始從剩下的風領主那裡取得力量!"
})

---------------
--  Al'Akir  --
---------------
L = DBM:GetModLocalization(155)

L:SetTimerLocalization({
	TimerFeedback 	= "回饋(%d)"
})

L:SetOptionLocalization({
	TimerFeedback	= "為$spell:87904的持續時間顯示計時器",
	RangeFrame		= "為當中了$spell:89668時顯示距離框(20碼)"
})

-----------------
-- Beth'tilac --
-----------------
L= DBM:GetModLocalization(192)

L:SetMiscLocalization({
	EmoteSpiderlings 	= "小蜘蛛從牠們的巢穴中被驚動了!"
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
	WarnPhase			= "第%d階段",
	WarnNewInitiate		= "熾炎猛禽學徒(%s)"
})

L:SetTimerLocalization({
	TimerPhaseChange	= "第%d階段",
	TimerHatchEggs		= "下次熔岩蛋",
	timerNextInitiate	= "下次熾炎爪擊啟動"
})

L:SetOptionLocalization({
	WarnPhase			= "為每次轉換階段顯示警告",
	WarnNewInitiate		= "為新的熾炎猛禽學徒顯示警告",
	timerNextInitiate	= "為下一次熾炎猛禽學徒顯示計時器",
	TimerPhaseChange	= "為下次階段轉換顯示計時器",
	TimerHatchEggs		= "為下次熔岩蛋孵化顯示計時器"
})

L:SetMiscLocalization({
	YellPull		= "我現在有新的主人了，凡人!",
	YellPhase2		= "這片天空屬於我。",
	LavaWorms		= "熾炎熔岩蟲從地上鑽了出來!",
	East			= "東邊",
	West			= "西邊",
	Both			= "兩側"
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
	warnStrike	= "%s (%d)"
})

L:SetTimerLocalization({
	timerStrike			= "下一次%s",
	TimerBladeActive	= "%s",
	TimerBladeNext		= "下一次巴勒羅克之刃"
})

L:SetOptionLocalization({
	ResetShardsinThrees	= "每3次(25人)/2次(10人)重置$spell:99259的計算次數",
	warnStrike			= "為虐殺/煉獄之刃顯示警告",
	timerStrike			= "為下一次虐殺/煉獄之刃顯示計時器",
	TimerBladeActive	= "為目前虐殺/煉獄之刃顯示持續時間",
	TimerBladeNext		= "為下一次巴勒羅克之刃顯示計時器"
})

--------------------------------
-- Majordomo Fandral Staghelm --
--------------------------------
L= DBM:GetModLocalization(197)

L:SetTimerLocalization({
	timerNextSpecial	= "下一次%s(%d)"
})

L:SetOptionLocalization({
	timerNextSpecial	= "為下一次特殊技能顯示計時器",
	RangeFrameSeeds		= "為$spell:98450顯示距離框(12碼)",
	RangeFrameCat		= "為$spell:98374顯示距離框(10碼)"
})

--------------
-- Ragnaros --
--------------
L= DBM:GetModLocalization(198)

L:SetWarningLocalization({
	warnRageRagnarosSoon	= "%s在%s在5秒後",
	warnSplittingBlow		= "%s在%s",
	warnEngulfingFlame		= "%s在%s",
	warnEmpoweredSulf		= "%s在5秒後施放"
})

L:SetTimerLocalization({
	timerRageRagnaros		= "%s在%s",
	TimerPhaseSons			= "烈焰之子階段結束"
})

L:SetOptionLocalization({
	warnSplittingBlow			= "為$spell:98951的位置顯示警告",
	warnEngulfingFlame			= "為$spell:99171的位置顯示警告",
	WarnEngulfingFlameHeroic	= "為$spell:99171的位置顯示警告(英雄模式)",
	warnSeedsLand				= "為$spell:98520落地而非熔岩晶粒施放顯示警告/計時器",
	TimerPhaseSons				= "顯示烈焰之子階段的持續時間計時器",
	InfoHealthFrame				= "顯示生命值框架 (低於十萬生命值)",
	MeteorFrame					= "顯示$spell:99849的目標的訊息框",
	AggroFrame					= "顯示沒有熔岩煉獄的仇恨的團員的訊息框"
})

L:SetMiscLocalization({
	East				= "東邊",
	West				= "西邊",
	Middle				= "中間",
	North				= "近戰區",
	South				= "後方",
	HealthInfo			= "低於十萬生命值",
	HasNoAggro			= "無目標",
	MeteorTargets		= "我的天 隕石!",
	TransitionEnded1	= "夠了!我將結束這一切。",
	TransitionEnded2	= "薩弗拉斯將終結你。",
	TransitionEnded3	= "跪下吧，凡人們!一切都將結束。",
	Defeat				= "太早了!...你們來的太早了...",
	Phase4				= "太早了..."
})

-----------------------
--  Firelands Trash  --
-----------------------
L = DBM:GetModLocalization("FirelandsTrash")

L:SetGeneralLocalization({
	name = "火源之界小怪"
})

----------------
--  Volcanus  --
----------------
L = DBM:GetModLocalization("Volcanus")

L:SetGeneralLocalization({
	name = "沃坎努斯"
})

L:SetTimerLocalization({
	timerStaffTransition	= "轉換階段結束"
})

L:SetOptionLocalization({
	timerStaffTransition	= "為轉換階段顯示時間"
})

L:SetMiscLocalization({
	StaffEvent			= "諾達希爾木枝對於%S+的觸碰產生了激烈的反應!",
	StaffTrees			= "燃燒的樹人從地面冒出來協助保衛者!",
	StaffTransition		= "受折磨的保衛者身上的火焰熄滅了!"
})

-----------------------
--  Nexus Legendary  --
-----------------------
L = DBM:GetModLocalization("NexusLegendary")

L:SetGeneralLocalization({
	name = "賽瑞納爾"
})

-------------
-- Morchok --
-------------
L= DBM:GetModLocalization(311)

L:SetWarningLocalization({
	KohcromWarning	= "%s:%s"
})

L:SetTimerLocalization({
	KohcromCD		= "寇魔的%s"
})

L:SetOptionLocalization({
	KohcromWarning	= "為$journal:4262的模仿能力顯示警告。",
	KohcromCD		= "為$journal:4262下一次的模仿能力顯示計時器。",
	RangeFrame		= "為成就顯示距離框(5碼)。"
})

L:SetMiscLocalization({
})

---------------------
-- Warlord Zon'ozz --
---------------------
L= DBM:GetModLocalization(324)

L:SetOptionLocalization({
	ShadowYell			= "當你中了$spell:104600時大喊(英雄模式專用)",
	CustomRangeFrame	= "距離框選項(英雄模式專用)",
	Never				= "禁用",
	Normal				= "普通距離框架",
	DynamicPhase2		= "過濾第二階段減益",
	DynamicAlways		= "總是過濾減益"
})

L:SetMiscLocalization({
	voidYell			= "Gul'kafh an'qov N'Zoth."
})

-----------------------------
-- Yor'sahj the Unsleeping --
-----------------------------
L= DBM:GetModLocalization(325)

L:SetWarningLocalization({
	warnOozesHit	= "%s注入了%s"
})

L:SetTimerLocalization({
	timerOozesActive	= "軟泥可被攻擊",
	timerOozesReach		= "軟泥抵達頭目"
})

L:SetOptionLocalization({
	warnOozesHit		= "為何種顏色的軟泥注入至首領發佈提示",
	timerOozesActive	= "為軟泥重生後可被攻擊顯示計時器",
	timerOozesReach		= "為何時軟泥抵達尤沙吉顯示計時器",
	RangeFrame			= "為$spell:104898顯示距離框(4碼)(普通以上的難度)"
})

L:SetMiscLocalization({
	Black			= "|cFF424242黑|r",
	Purple			= "|cFF9932CD紫|r",
	Red				= "|cFFFF0404紅|r",
	Green			= "|cFF088A08綠|r",
	Blue			= "|cFF0080FF藍|r",
	Yellow			= "|cFFFFA901黃|r"
})

-----------------------
-- Hagara the Binder --
-----------------------
L= DBM:GetModLocalization(317)

L:SetWarningLocalization({
	WarnPillars				= "%s:剩餘%d",
	warnFrostTombCast		= "%s在八秒後"
})

L:SetTimerLocalization({
	TimerSpecial			= "第一次特別技能"
})

L:SetOptionLocalization({
	WarnPillars				= "提示$journal:3919或$journal:4069的剩餘數量",
	TimerSpecial			= "為第一次特別技能$spell:105256或$spell:105465施放顯示計時器<br/>(第一次施放根據首領手中的武器的附魔)",
	RangeFrame				= "為$spell:105269(3碼),$journal:4327(10碼)顯示距離框",
	AnnounceFrostTombIcons	= "為$spell:104451的目標發佈圖示至團隊頻道<br/>(需要團隊隊長)",
	SpecialCount			= "為$spell:105256或$spell:105465播放倒數計時音效",
	SetBubbles				= "自動地為$spell:104451關閉對話氣泡功能<br/>(當戰鬥結束後還原功能)"
})

L:SetMiscLocalization({
	TombIconSet				= "寒冰之墓{rt%d}標記於%s"
})

---------------
-- Ultraxion --
---------------
L= DBM:GetModLocalization(331)

L:SetWarningLocalization({
	specWarnHourofTwilightN		= "%s (%d)在5秒後"
})

L:SetTimerLocalization({
	TimerCombatStart	= "戰鬥開始"
})

L:SetOptionLocalization({
	TimerCombatStart	= "為戰鬥開始時間顯示計時器",
	ResetHoTCounter		= "重置暮光之時計數",
	Never				= "不使用",
	ResetDynamic		= "每三次/兩次重置計數(英雄/普通)",
	Reset3Always		= "總是每三次重置計數",
	SpecWarnHoTN		= "為暮光之時前五秒顯示特別警告，如設為不使用則預設為每三次重置計數",
	One					= "1(即為第1 4 7次)",
	Two					= "2(即為第2 5次)",
	Three				= "3(即為第3 6次)"
})

L:SetMiscLocalization({
	Pull				= "我感到平衡被一股強大的波動干擾。如此混沌在燃燒我的心靈!"
})

-------------------------
-- Warmaster Blackhorn --
-------------------------
L= DBM:GetModLocalization(332)

L:SetWarningLocalization({
	SpecWarnElites		= "精英暮光!"
})

L:SetTimerLocalization({
	TimerAdd			= "下一次精英暮光"
})

L:SetOptionLocalization({
	TimerAdd			= "為下一次精英暮光顯示計時器",
	SpecWarnElites		= "為新一波的精英暮光顯示特別警告",
	SetTextures			= "在第一階段時自動的關閉投影材質特效<br/>(第二階段時還原為開啟)"
})

L:SetMiscLocalization({
	SapperEmote			= "一頭龍急速飛來，載送一名暮光工兵降落到甲板上!",
	GorionaRetreat		= "痛苦嘶吼，躲入旋繞的雲裡。"
})

-------------------------
-- Spine of Deathwing  --
-------------------------
L= DBM:GetModLocalization(318)

L:SetWarningLocalization({
	warnSealArmor			= "%s",
	SpecWarnTendril			= "快到觸鬚上!"
})

L:SetOptionLocalization({
	SpecWarnTendril			= "當你身上沒有$spell:105563減益時顯示特別警告",
	InfoFrame				= "為沒有$spell:105563的玩家顯示訊息框",
	ShowShieldInfo			= "為$spell:105479顯示生命條<br/>(忽略首領血量框架選項)"
})

L:SetMiscLocalization({
	Pull			= "他的護甲!他正在崩壞!破壞他的護甲，我們就有機會打贏他了!",
	NoDebuff		= "無%s",
	PlasmaTarget	= "燃燒血漿: %s",
	DRoll			= "他準備往",
	DLevels			= "回復平衡"
})

---------------------------
-- Madness of Deathwing  --
---------------------------
L= DBM:GetModLocalization(333)

L:SetOptionLocalization({
	RangeFrame			= "根據玩家減益顯示動態的距離框以對應英雄模式的$spell:108649"
})

L:SetMiscLocalization({
	Pull				= "你們都徒勞無功。我會撕裂你們的世界。"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("DSTrash")

L:SetGeneralLocalization({
	name =	"巨龍之魂小怪"
})

L:SetWarningLocalization({
	DrakesLeft			= "暮光猛擊者剩下:%d"
})

L:SetTimerLocalization({
	TimerDrakes			= "%s"
})

L:SetOptionLocalization({
	DrakesLeft			= "提示暮光猛擊者的剩餘數量",
	TimerDrakes			= "為暮光猛擊者$spell:109904顯示計時器"
})

L:SetMiscLocalization({
	firstRP				= "讚美泰坦，他們回來了!",
	UltraxionTrash		= "很高興又見到你，雅立史卓莎。我離開這段時間忙得很。",
	UltraxionTrashEnded = "這些幼龍、實驗品，只不過是實現更偉大目標的手段罷了。你會看到研究的龍蛋有什麼成果。"
})
