if GetLocale() ~= "zhTW" then return end

local L

---------------
--  Kalecgos --
---------------
L = DBM:GetModLocalization("Kal")

L:SetGeneralLocalization{
	name = "卡雷苟斯"
}

L:SetWarningLocalization{
	WarnPortal			= "第%s個傳送門:>%s<(第%d隊)",
	SpecWarnWildMagic	= "野性魔法:%s"
}

L:SetOptionLocalization{
	WarnPortal			= "為$spell:46021的目標顯示警告",
	SpecWarnWildMagic	= "為野性魔法顯示特別警告",
	ShowFrame			= "顯示鬼靈國度框架",
	FrameClassColor		= "在鬼靈國度框架使用職業顏色",
	FrameUpwards		= "向上延伸鬼靈國度框架",
	FrameLocked			= "鎖定鬼靈國度框架"
}

L:SetMiscLocalization{
	Demon				= "『墮落者』塞斯諾瓦",
	Heal				= "+100%治療",
	Haste				= "+100%施法時間",
	Hit					= "-50%命中機率",
	Crit				= "+100%爆擊傷害",
	Aggro				= "+100%仇恨值",
	Mana				= "-50%法術消耗",
	FrameTitle			= "鬼靈國度",
	FrameLock			= "鎖定框架",
	FrameClassColor		= "使用職業顏色",
	FrameOrientation	= "向上延伸",
	FrameHide			= "隱藏框架",
	FrameClose			= "關閉"
}

----------------
--  Brutallus --
----------------
L = DBM:GetModLocalization("Brutallus")

L:SetGeneralLocalization{
	name = "布魯托魯斯"
}

L:SetMiscLocalization{
	Pull			= "啊，更多待宰的小羊們!"
}

--------------
--  Felmyst --
--------------
L = DBM:GetModLocalization("Felmyst")

L:SetGeneralLocalization{
	name = "魔龍謎霧"
}

L:SetWarningLocalization{
	WarnPhase		= "%s階段"
}

L:SetTimerLocalization{
	TimerPhase		= "下一次%s階段"
}

L:SetOptionLocalization{
	WarnPhase		= "為下個階段顯示警告",
	TimerPhase		= "為下個階段顯示計時器"
}

L:SetMiscLocalization{
	Air				= "空中",
	Ground			= "地面",
	AirPhase		= "我比以前更強大了!",
	Breath			= "%s深深地吸了一口氣。"
}

-----------------------
--  The Eredar Twins --
-----------------------
L = DBM:GetModLocalization("Twins")

L:SetGeneralLocalization{
	name = "埃雷達爾雙子"
}

L:SetMiscLocalization{
	Nova			= "莎珂蕾希對(.+)施放暗影新星。",
	Conflag			= "艾黎瑟絲對(.+)施放焚焰。",
	Sacrolash		= "莎珂蕾希女士",
	Alythess		= "大術士艾黎瑟絲"
}

------------
--  M'uru --
------------
L = DBM:GetModLocalization("Muru")

L:SetGeneralLocalization{
	name = "莫魯"
}

L:SetWarningLocalization{
	WarnHuman		= "人型小兵 (%d)",
	WarnVoid		= "虛無哨兵 (%d)",
	WarnFiend		= "黑暗惡魔出現了"
}

L:SetTimerLocalization{
	TimerHuman		= "人型小兵 (%s)",
	TimerVoid		= "虛無哨兵 (%s)",
	TimerPhase		= "安卓普斯"
}

L:SetOptionLocalization{
	WarnHuman		= "為人型小兵顯示警告",
	WarnVoid		= "為虛無哨兵顯示警告",
	WarnFiend		= "為第二階段的黑暗惡魔顯示警告",
	TimerHuman		= "為人型小兵顯示計時器",
	TimerVoid		= "為虛無哨兵顯示計時器",
	TimerPhase		= "為轉換第二階段顯示計時器"
}

L:SetMiscLocalization{
	Entropius		= "安卓普斯"
}

----------------
--  Kil'jeden --
----------------
L = DBM:GetModLocalization("Kil")

L:SetGeneralLocalization{
	name = "基爾加丹"
}

L:SetWarningLocalization{
	WarnDarkOrb		= "盾之寶珠出現",
	WarnBlueOrb		= "藍龍軍團寶珠啟用",
	SpecWarnDarkOrb	= "盾之寶珠出現!",
	SpecWarnBlueOrb	= "藍龍軍團寶珠啟用!"
}

L:SetTimerLocalization{
	TimerBlueOrb	= "藍龍軍團寶珠活動"
}

L:SetOptionLocalization{
	WarnDarkOrb		= "為盾之寶珠顯示警告",
	WarnBlueOrb		= "為藍龍軍團寶珠顯示警告",
	SpecWarnDarkOrb	= "為盾之寶珠顯示特別警告",
	SpecWarnBlueOrb	= "為藍龍軍團寶珠顯示特別警告",
	TimerBlueOrb	= "為藍龍軍團寶珠活動顯示計時器"
}

L:SetMiscLocalization{
	YellPull		= "該犧牲的都已經結束了，就任他們去吧!現在我將完成薩格拉斯都辦不到的事!我要搾乾這個悲慘的世界，並確保我成為燃燒軍團的真正主人!末日已經到來!讓這個世界開始毀滅吧!",
	OrbYell1		= "我會將我的力量導入寶珠中!準備好!",
	OrbYell2		= "我又將能量灌入了另一顆寶珠!快去使用它!",
	OrbYell3		= "又有一顆寶珠準備好了!快點行動!",
	OrbYell4		= "我已經引導出所有的力量了!力量現在掌握在你們的手裡!"

}

-----------------
--  Najentus  --
-----------------
L = DBM:GetModLocalization("Najentus")

L:SetGeneralLocalization{
	name = "高階督軍納珍塔斯"
}

L:SetMiscLocalization{
	HealthInfo	= "血量資訊"
}

----------------
-- Supremus --
----------------
L = DBM:GetModLocalization("Supremus")

L:SetGeneralLocalization{
	name = "瑟普莫斯"
}

L:SetWarningLocalization{
	WarnPhase		= "%s階段"
}

L:SetTimerLocalization{
	TimerPhase		= "下一次%s階段"
}

L:SetOptionLocalization{
	WarnPhase		= "為下個階段顯示警告",
	TimerPhase		= "為下個階段顯示計時器",
	KiteIcon		= "為注視目標設置圖示",
}

L:SetMiscLocalization{
	PhaseTank		= "瑟普莫斯憤怒的捶擊地面!",--Check if Backwards
	PhaseKite		= "地上開始裂開!",--Check if Backwards
	ChangeTarget	= "瑟普莫斯需要一個新目標!",
	Kite			= "風箏",
	Tank			= "坦克"
}

-------------------------
--  Shape of Akama  --
-------------------------
L = DBM:GetModLocalization("Akama")

L:SetGeneralLocalization{
	name = "阿卡瑪的黑暗面"
}

L:SetWarningLocalization({
	warnAshtongueDefender	= "灰舌防衛者",
	warnAshtongueSorcerer	= "灰舌巫士"
})

L:SetTimerLocalization({
	timerAshtongueDefender	= "灰舌防衛者: %s",
	timerAshtongueSorcerer	= "灰舌巫士: %s"
})

L:SetOptionLocalization({
	warnAshtongueDefender	= "顯示灰舌防衛者的警告",
	warnAshtongueSorcerer	= "顯示灰舌巫士的警告",
	timerAshtongueDefender	= "顯示灰舌防衛者的計時器",
	timerAshtongueSorcerer	= "顯示灰舌巫士的計時器"
})

-------------------------
--  Teron Gorefiend  --
-------------------------
L = DBM:GetModLocalization("TeronGorefiend")

L:SetGeneralLocalization{
	name = "泰朗·血魔"
}

L:SetTimerLocalization{
	TimerVengefulSpirit	= "鬼魂:%s"
}

L:SetOptionLocalization{
	TimerVengefulSpirit	= "為鬼魂持續時間顯示計時器"
}

----------------------------
--  Gurtogg Bloodboil  --
----------------------------
L = DBM:GetModLocalization("Bloodboil")

L:SetGeneralLocalization{
	name = "葛塔格·血沸"
}

--------------------------
--  Essence Of Souls  --
--------------------------
L = DBM:GetModLocalization("Souls")

L:SetGeneralLocalization{
	name = "靈魂聖匣"
}

L:SetWarningLocalization{
	WarnMana		= "30秒後法力用盡"
}

L:SetTimerLocalization{
	TimerMana		= "法力耗盡"
}

L:SetOptionLocalization{
	WarnMana		= "在第二階段耗盡法力顯示警告",
	TimerMana		= "在第二階段法力耗盡顯示計時器"
}

L:SetMiscLocalization{
	Suffering		= "受難精華",
	Desire			= "慾望精華",
	Anger			= "憤怒精華",
	Phase1End		= "I don't want to go back!",
	Phase2End		= "I won't be far!"
}

-----------------------
--  Mother Shahraz --
-----------------------
L = DBM:GetModLocalization("Shahraz")

L:SetGeneralLocalization{
	name = "薩拉茲女士"
}

L:SetTimerLocalization{
	timerAura	= "%s"
}

L:SetOptionLocalization{
	timerAura	= "為稜石光環顯示計時器"
}

----------------------
--  Illidari Council  --
----------------------
L = DBM:GetModLocalization("Council")

L:SetGeneralLocalization{
	name = "伊利達瑞議會"
}

L:SetWarningLocalization{
	Immune			= "瑪蘭黛 - %s免疫15秒"
}

L:SetOptionLocalization{
	Immune			= "當瑪蘭黛法術或物理免疫時顯示警告",
}

L:SetMiscLocalization{
	Gathios			= "粉碎者高希歐",
	Malande			= "瑪蘭黛女士",
	Zerevor			= "高等虛空術師札瑞佛",
	Veras			= "維拉斯·深影",
	Melee			= "物理",
	Spell			= "法術",
}

-------------------------
--  Illidan Stormrage --
-------------------------
L = DBM:GetModLocalization("Illidan")

L:SetGeneralLocalization{
	name = "伊利丹·怒風"
}

L:SetWarningLocalization{
	WarnHuman		= "人形階段即將到來",
	WarnDemon		= "惡魔階段"
}

L:SetTimerLocalization{
	TimerNextHuman		= "人形階段",
	TimerNextDemon		= "惡魔階段"
}

L:SetOptionLocalization{
	WarnHuman		= "為人形階段顯示警告",
	WarnDemon		= "為惡魔階段顯示計時器",
	TimerNextHuman	= "為下一次人形階段顯示計時器",
	TimerNextDemon	= "為下一次惡魔階段顯示計時器",
	RangeFrame		= "為第3和第4階段顯示距離框架(10碼)"
}

L:SetMiscLocalization{
	Pull			= "阿卡瑪。你的謊言真是老套。我很久前就應該殺了你和你那些畸形的同胞。",
	Eyebeam			= "直視背叛者的雙眼吧!",
	Demon			= "感受我體內的惡魔之力吧!",
	Phase4			= "你們就這點本事嗎?這就是你們全部的能耐?"
}

------------------------
--  Rage Winterchill  --
------------------------
L = DBM:GetModLocalization("Rage")

L:SetGeneralLocalization{
	name = "瑞齊·凜冬"
}

-----------------
--  Anetheron  --
-----------------
L = DBM:GetModLocalization("Anetheron")

L:SetGeneralLocalization{
	name = "安納塞隆"
}

----------------
--  Kazrogal  --
----------------
L = DBM:GetModLocalization("Kazrogal")

L:SetGeneralLocalization{
	name = "卡茲洛加"
}

---------------
--  Azgalor  --
---------------
L = DBM:GetModLocalization("Azgalor")

L:SetGeneralLocalization{
	name = "亞茲加洛"
}

------------------
--  Archimonde  --
------------------
L = DBM:GetModLocalization("Archimonde")

L:SetGeneralLocalization{
	name = "阿克蒙德"
}

----------------
-- WaveTimers --
----------------
L = DBM:GetModLocalization("HyjalWaveTimers")

L:SetGeneralLocalization{
	name 		= "小怪模組"
}
L:SetWarningLocalization{
	WarnWave	= "%s"
}
L:SetTimerLocalization{
	TimerWave	= "下一波"
}
L:SetOptionLocalization{
	WarnWave		= "當新一波進攻到來時顯示警告",
	DetailedWave	= "當新一波進攻到來時顯示詳細警告(何種怪)",
	TimerWave		= "為下一波進攻顯示計時器"
}
L:SetMiscLocalization{
	HyjalZoneName	= "海加爾山",
	Thrall			= "索爾",
	Jaina			= "珍娜·普勞德摩爾女士",
	GeneralBoss		= "首領到來",
	RageWinterchill	= "瑞齊·凜冬到來",
	Anetheron		= "安納塞隆到來",
	Kazrogal		= "卡茲洛加到來",
	Azgalor			= "亞茲加洛到來",
	WarnWave_0		= "第%s/8波",
	WarnWave_1		= "第%s/8波 - %s %s",
	WarnWave_2		= "第%s/8波 - %s %s 和 %s %s",
	WarnWave_3		= "第%s/8波 - %s %s, %s %s 和 %s %s",
	WarnWave_4		= "第%s/8波 - %s %s, %s %s, %s %s 和 %s %s",
	WarnWave_5		= "第%s/8波 - %s %s, %s %s, %s %s, %s %s 和 %s %s",
	RageGossip		= "我和我的同伴都與你同在，普勞德摩爾女士。",
	AnetheronGossip	= "不管阿克蒙德要派誰來對付我們，我們都已經準備好了，普勞德摩爾女士。",
	KazrogalGossip	= "我與你同在，索爾。",
	AzgalorGossip	= "我們無所畏懼。",
	Ghoul			= "食屍鬼",
	Abomination		= "憎惡",
	Necromancer		= "死靈法師",
	Banshee			= "女妖",
	Fiend			= "地穴惡魔",
	Gargoyle		= "石像鬼",
	Wyrm			= "冰龍",
	Stalker			= "惡魔捕獵者",
	Infernal		= "巨型地獄火"
}

-----------
--  Alar --
-----------
L = DBM:GetModLocalization("Alar")

L:SetGeneralLocalization{
	name = "歐爾"
}

L:SetTimerLocalization{
	NextPlatform	= "最長平台停留時間"
}

L:SetOptionLocalization{
	NextPlatform	= "為歐爾最長平台可能停留時間顯示計時器(可能會提早離開不過不會大於這個時間)"
}

------------------
--  Void Reaver --
------------------
L = DBM:GetModLocalization("VoidReaver")

L:SetGeneralLocalization{
	name = "虛無搶奪者"
}

--------------------------------
--  High Astromancer Solarian --
--------------------------------
L = DBM:GetModLocalization("Solarian")

L:SetGeneralLocalization{
	name = "高階星術師索拉瑞恩"
}

L:SetWarningLocalization{
	WarnSplit		= "分裂!",
	WarnSplitSoon	= "5秒後分裂",
	WarnAgent		= "密探出現了",
	WarnPriest		= "牧師和索拉瑞恩出現了"

}

L:SetTimerLocalization{
	TimerSplit		= "下一次分裂",
	TimerAgent		= "密探即將到來",
	TimerPriest		= "牧師和索拉瑞恩即將到來"
}

L:SetOptionLocalization{
	WarnSplit		= "為分裂顯示警告",
	WarnSplitSoon	= "為分裂顯示警告顯示預先警告",
	WarnAgent		= "為密探出現顯示警告",
	WarnPriest		= "為牧師和索拉瑞恩出現顯示警告",
	TimerSplit		= "為分裂顯示計時器",
	TimerAgent		= "為密探出現顯示計時器",
	TimerPriest		= "為牧師和索拉瑞恩出現顯示計時器"
}

L:SetMiscLocalization{
	YellSplit1		= "我會粉碎你那偉大的夢想",
	YellSplit2		= "我的實力遠勝於你!",
	YellPhase2		= "夠了!現在我要呼喚宇宙中失衡的能量。"
}

---------------------------
--  Kael'thas Sunstrider --
---------------------------
L = DBM:GetModLocalization("KaelThas")

L:SetGeneralLocalization{
	name = "凱爾薩斯·逐日者"
}

L:SetWarningLocalization{
	WarnGaze		= ">%s<被凝視了",
	WarnMobDead		= "%s倒下",
	WarnEgg			= "鳳凰蛋出現",
	SpecWarnGaze	= "你被凝視了!快跑!",
	SpecWarnEgg		= "鳳凰蛋出現! - 快換目標!"
}

L:SetTimerLocalization{
	TimerPhase		= "下個階段",
	TimerPhase1mob	= "%s",
	TimerNextGaze	= "下一個凝視目標",
	TimerRebirth	= "鳳凰重生"
}

L:SetOptionLocalization{
	WarnGaze		= "為薩拉瑞德凝視的目標顯示警告",
	WarnMobDead		= "為第2階段小怪倒下顯示警告",
	WarnEgg			= "為鳳凰蛋出現顯示警告",
	SpecWarnGaze	= "當你被凝視時顯示特別警告",
	SpecWarnEgg		= "當鳳凰蛋出現時顯示特別警告",
	TimerPhase		= "為下一階段顯示計時器",
	TimerPhase1mob	= "為第1階段小怪活動顯示計時器",
	TimerNextGaze	= "為薩拉瑞德凝視目標改變顯示計時器",
	TimerRebirth	= "為鳳凰蛋重生顯示計時器",
	GazeIcon		= "標記薩拉瑞德注視的目標"
}

L:SetMiscLocalization{
	YellPhase2	= "你們看，我的個人收藏中有許多武器...",
	YellPhase3	= "也許我低估了你。要你一次對付四位諫言者也許對你來說是不太公平，但是...我的人民從未得到公平的對待。我只是以牙還牙而已。",
	YellPhase4	= "唉，有些時候，有些事情，必須得親自解決才行。(薩拉斯語)受死吧!",
	YellPhase5	= "我的心血是不會被你們輕易浪費的!我精心謀劃的未來是不會被你們輕易破壞的!感受我真正的力量吧!",
	YellSang	= "你已經努力的打敗了我的幾位最忠誠的諫言者...但是沒有人可以抵抗血錘的力量。等著看桑古納爾領主的力量吧!",
	YellCaper	= "卡普尼恩將保證你們不會在這裡停留太久。",
	YellTelo	= "做得好，你已經證明你的實力足以挑戰我的工程大師泰隆尼卡斯。",
	EmoteGaze	= "凝視著(.+)!",
	Thaladred	= "扭曲預言家薩拉瑞德",
	Sanguinar	= "桑古納爾領主",
	Capernian	= "大星術師卡普尼恩",
	Telonicus	= "工程大師泰隆尼卡斯",
	Bow			= "虛空之絃長弓",
	Axe			= "毀滅",
	Mace		= "宇宙灌溉者",
	Dagger		= "無盡之刃",
	Sword		= "扭曲分割者",
	Shield		= "相位壁壘",
	Staff		= "瓦解之杖",
	Egg			= "鳳凰蛋"
}

---------------------------
--  Hydross the Unstable --
---------------------------
L = DBM:GetModLocalization("Hydross")

L:SetGeneralLocalization{
	name = "不穩定者海卓司"
}

L:SetWarningLocalization{
	WarnMark 		= "%s:%s",
	WarnPhase		= "%s階段",
	SpecWarnMark	= "%s:%s"
}

L:SetTimerLocalization{
	TimerMark	= "下一次%s:%s"
}

L:SetOptionLocalization{
	WarnMark		= "提示印記",
	WarnPhase		= "提示階段",
	SpecWarnMark	= "為印記易傷超過100%時顯示警告",
	TimerMark		= "為下一次印記顯示計時器"
}

L:SetMiscLocalization{
	Frost	= "冰霜",
	Nature	= "自然"
}

-----------------------
--  The Lurker Below --
-----------------------
L = DBM:GetModLocalization("LurkerBelow")

L:SetGeneralLocalization{
	name = "海底潛伏者"
}

L:SetWarningLocalization{
	WarnSubmerge		= "潛入水中",
	WarnEmerge			= "浮現"
}

L:SetTimerLocalization{
	TimerSubmerge		= "潛水冷卻",
	TimerEmerge			= "浮現冷卻"
}

L:SetOptionLocalization{
	WarnSubmerge		= "為潛入水中顯示警告",
	WarnEmerge			= "為浮現顯示警告",
	TimerSubmerge		= "為潛入水中顯示計時器",
	TimerEmerge			= "為浮現顯示計時器"
}

--------------------------
--  Leotheras the Blind --
--------------------------
L = DBM:GetModLocalization("Leotheras")

L:SetGeneralLocalization{
	name = "『盲目者』李奧薩拉斯"
}

L:SetWarningLocalization{
	WarnPhase		= "%s階段"
}

L:SetTimerLocalization{
	TimerPhase	= "下一次%s階段"
}

L:SetOptionLocalization{
	WarnPhase		= "為下個階段顯示警告",
	TimerPhase		= "為下個階段顯示計時器"
}

L:SetMiscLocalization{
	Human		= "人形",
	Demon		= "惡魔",
	YellDemon	= "消失吧，微不足道的精靈。現在開始由我掌管!",
	YellPhase2	= "不...不!你做了什麼?我是主人!你沒聽見我在說話嗎?我....啊!無法...控制它。"
}

-----------------------------
--  Fathom-Lord Karathress --
-----------------------------
L = DBM:GetModLocalization("Fathomlord")

L:SetGeneralLocalization{
	name = "深淵之王卡拉薩瑞斯"
}

L:SetMiscLocalization{
	Caribdis	= "深淵守衛卡利迪斯",
	Tidalvess	= "提達費斯",
	Sharkkis	= "深淵守衛沙卡奇斯"
}

--------------------------
--  Morogrim Tidewalker --
--------------------------
L = DBM:GetModLocalization("Tidewalker")

L:SetGeneralLocalization{
	name = "莫洛葛利姆·潮行者"
}

L:SetWarningLocalization{
	SpecWarnMurlocs	= "魚人出現!"
}

L:SetTimerLocalization{
	TimerMurlocs	= "魚人出現"
}

L:SetOptionLocalization{
	SpecWarnMurlocs	= "為魚人出現顯示特別警告",
	TimerMurlocs	= "為魚人出現顯示計時器"
}

-----------------
--  Lady Vashj --
-----------------
L = DBM:GetModLocalization("Vashj")

L:SetGeneralLocalization{
	name = "瓦許女士"
}

L:SetWarningLocalization{
	WarnElemental		= "污染的元素即將出現! (%s)",
	WarnStrider			= "盤牙旅行者即將出現! (%s)",
	WarnNaga			= "盤牙精英即將出現! (%s)",
	WarnShield			= "魔法屏障%d/4消失!",
	WarnLoot			= ">%s<擁有受污染的核心!",
	SpecWarnElemental	= "污染的元素 - 快換目標!"
}

L:SetTimerLocalization{
	TimerElementalActive	= "污染的元素重生",
	TimerElemental			= "污染的元素 (%d)",
	TimerStrider			= "盤牙旅行者 (%d)",
	TimerNaga				= "盤牙精英 (%d)"
}

L:SetOptionLocalization{
	WarnElemental		= "為下一次污染的元素顯示預先警告",
	WarnStrider			= "為下一次盤牙旅行者顯示預先警告",
	WarnNaga			= "為下一次盤牙精英顯示預先警告",
	WarnShield			= "為第2階段屏障消失顯示警告",
	WarnLoot			= "提示誰拾取了受污染的核心",
	TimerElementalActive	= "為下一次污染的元素出現顯示計時器",
	TimerElemental		= "為下一次污染的元素顯示計時器",
	TimerStrider		= "為下一次盤牙旅行者顯示計時器",
	TimerNaga			= "為下一次盤牙精英顯示計時器",
	SpecWarnElemental	= "為污染的元素出現顯示特別警告",
	AutoChangeLootToFFA	= "第2階段自動轉換拾取方式為自由拾取"
}

L:SetMiscLocalization{
	DBM_VASHJ_YELL_PHASE2	= "機會來了!一個活口都不要留下!",
	DBM_VASHJ_YELL_PHASE3	= "你們最好找掩護。",
	LootMsg					= "(.+)拾取了物品:.*Hitem:(%d+)"
}

--Maulgar
L = DBM:GetModLocalization("Maulgar")

L:SetGeneralLocalization{
	name = "大君王莫卡爾"
}


--Gruul the Dragonkiller
L = DBM:GetModLocalization("Gruul")

L:SetGeneralLocalization{
	name = "弒龍者戈魯爾"
}

L:SetWarningLocalization{
	WarnGrowth	= "%s (%d)"
}

L:SetOptionLocalization{
	WarnGrowth	= "為$spell:36300顯示警告"
}


-- Magtheridon
L = DBM:GetModLocalization("Magtheridon")

L:SetGeneralLocalization{
	name = "瑪瑟里頓"
}

L:SetTimerLocalization{
	timerP2	= "第2階段"
}

L:SetOptionLocalization{
	timerP2	= "為第2階段開始顯示計時器"
}

L:SetMiscLocalization{
	DBM_MAG_EMOTE_PULL		= "%s的束縛開始變弱!",
	DBM_MAG_YELL_PHASE2		= "我...被...釋放了!",
	DBM_MAG_YELL_PHASE3		= "我不會這麼輕易就被擊敗!讓這座監獄的牆壁震顫...然後崩塌!"
}

--Attumen
L = DBM:GetModLocalization("Attumen")

L:SetGeneralLocalization{
	name = "獵人阿圖曼"
}

L:SetMiscLocalization{
	DBM_ATH_YELL_1		= "來吧午夜，讓我們驅散這一群小規模的烏合之眾!"
}


--Moroes
L = DBM:GetModLocalization("Moroes")

L:SetGeneralLocalization{
	name = "摩洛"
}

L:SetWarningLocalization{
	DBM_MOROES_VANISH_FADED	= "消失退去"
}

L:SetOptionLocalization{
	DBM_MOROES_VANISH_FADED	= "為消失退去顯示警告"
}


-- Maiden of Virtue
L = DBM:GetModLocalization("Maiden")

L:SetGeneralLocalization{
	name = "貞潔聖女"
}


-- Romulo and Julianne
L = DBM:GetModLocalization("RomuloAndJulianne")

L:SetGeneralLocalization{
	name = "羅慕歐與茱麗葉"
}

L:SetMiscLocalization{
	Event				= "今晚...我們要探索一個禁忌之愛的故事。",
	RJ_Pull				= "你是什麼樣的惡魔，讓我這樣的痛苦?",
	DBM_RJ_PHASE2_YELL	= "來吧，溫和的夜晚;把我的羅慕歐還給我!",
	Romulo				= "羅慕歐",
	Julianne			= "茱麗葉"
}


-- Big Bad Wolf
L = DBM:GetModLocalization("BigBadWolf")

L:SetGeneralLocalization{
	name = "大野狼"
}

L:SetMiscLocalization{
	DBM_BBW_YELL_1	= "我想把你吃掉!"
}

-- Wizard of Oz
L = DBM:GetModLocalization("Oz")

L:SetGeneralLocalization{
	name = "綠野仙蹤"
}

L:SetWarningLocalization{
	DBM_OZ_WARN_TITO		= "多多",
	DBM_OZ_WARN_ROAR		= "獅子",
	DBM_OZ_WARN_STRAWMAN	= "稻草人",
	DBM_OZ_WARN_TINHEAD		= "機器人",
	DBM_OZ_WARN_CRONE		= "老巫婆"
}

L:SetTimerLocalization{
	DBM_OZ_WARN_TITO		= "多多",
	DBM_OZ_WARN_ROAR		= "獅子",
	DBM_OZ_WARN_STRAWMAN	= "稻草人",
	DBM_OZ_WARN_TINHEAD		= "機器人"
}

L:SetOptionLocalization{
	AnnounceBosses			= "為新的首領出現顯示警告",
	ShowBossTimers			= "為新的首領出現顯示計時器"
}

L:SetMiscLocalization{
	DBM_OZ_YELL_DOROTHEE	= "喔多多，我們一定要找到回家的路!那個老巫師是我們唯一的希望!稻草人、獅子、機器人，你會 - 等等哦...天呀，快看，我們有訪客!",
	DBM_OZ_YELL_ROAR		= "我不是害怕你!你想要戰鬥嗎?啊，你是嗎?來! 我將把兩支爪子放在背後跟你戰鬥!",
	DBM_OZ_YELL_STRAWMAN	= "現在我該與你做什麼?我完全不能決定。",
	DBM_OZ_YELL_TINHEAD		= "我真的能使用心。嘿，我能有你的心嗎?",
	DBM_OZ_YELL_CRONE		= "為你們每一個人感到不幸，我的小美人們!"
}


-- Curator
L = DBM:GetModLocalization("Curator")

L:SetGeneralLocalization{
	name = "館長"
}

L:SetWarningLocalization{
	warnAdd		= "小怪重生"
}

L:SetOptionLocalization{
	warnAdd		= "為小怪重生顯示警告"
}


-- Terestian Illhoof
L = DBM:GetModLocalization("TerestianIllhoof")

L:SetGeneralLocalization{
	name = "泰瑞斯提安·疫蹄"
}

L:SetMiscLocalization{
	Kilrek	= "基瑞克",
	DChains	= "惡魔鍊"
}


-- Shade of Aran
L = DBM:GetModLocalization("Aran")

L:SetGeneralLocalization{
	name = "埃蘭之影"
}

L:SetWarningLocalization{
	DBM_ARAN_DO_NOT_MOVE	= "烈焰火圈，不要動！"
}

L:SetTimerLocalization{
	timerSpecial			= "特別技能冷卻"
}

L:SetOptionLocalization{
	timerSpecial			= "為特別技能冷卻顯示計時器",
	DBM_ARAN_DO_NOT_MOVE	= "為$spell:30004顯示特別警告"
}



--Netherspite
L = DBM:GetModLocalization("Netherspite")

L:SetGeneralLocalization{
	name = "尼德斯"
}

L:SetWarningLocalization{
	warningPortal			= "光線門階段",
	warningBanish			= "放逐階段"
}

L:SetTimerLocalization{
	timerPortalPhase	= "光線門階段",
	timerBanishPhase	= "放逐階段"
}

L:SetOptionLocalization{
	warningPortal			= "為光線門階段顯示警告",
	warningBanish			= "為放逐階段顯示警告",
	timerPortalPhase		= "為光線門階段持續時間顯示計時器",
	timerBanishPhase		= "為放逐門階段持續時間顯示計時器"
}

L:SetMiscLocalization{
	DBM_NS_EMOTE_PHASE_2 	= "%s陷入一陣狂怒!",
	DBM_NS_EMOTE_PHASE_1 	= "%s大聲呼喊撤退，打開通往虛空的門。"
}

--Chess
L = DBM:GetModLocalization("Chess")

L:SetGeneralLocalization{
	name = "西洋棋事件"
}

L:SetTimerLocalization{
	timerCheat	= "作弊冷卻"
}

L:SetOptionLocalization{
	timerCheat	= "為作弊冷卻使用計時器"
}

L:SetMiscLocalization{
	EchoCheats	= "麥迪文的回音作弊!"
}

--Prince Malchezaar
L = DBM:GetModLocalization("Prince")

L:SetGeneralLocalization{
	name = "莫克札王子"
}

L:SetMiscLocalization{
	DBM_PRINCE_YELL_P2		= "頭腦簡單的笨蛋!你在燃燒的是時間的火焰!",
	DBM_PRINCE_YELL_P3		= "你怎能期望抵抗這樣勢不可擋的力量?",
	DBM_PRINCE_YELL_INF1	= "所有的實體，所有的空間對我來說都是開放的!",
	DBM_PRINCE_YELL_INF2	= "你挑戰的不只是莫克札，而是我所率領的整個軍隊!"
}


-- Nightbane
L = DBM:GetModLocalization("NightbaneRaid")

L:SetGeneralLocalization{
	name = "夜禍"
}

L:SetWarningLocalization{
	DBM_NB_AIR_WARN			= "空中階段"
}

L:SetTimerLocalization{
	timerAirPhase			= "空中階段"
}

L:SetOptionLocalization{
	DBM_NB_AIR_WARN			= "為空中階段顯示警告",
	timerAirPhase			= "為空中階段持續時間顯示計時器"
}

L:SetMiscLocalization{
	DBM_NB_EMOTE_PULL 		= "一個古老的生物在遠處甦醒過來...",
	DBM_NB_YELL_AIR 		= "悲慘的害蟲。我將讓你消失在空氣中!",
	DBM_NB_YELL_GROUND 		= "夠了!我要親自挑戰你!",
	DBM_NB_YELL_GROUND2 	= "昆蟲!給你們近距離嚐嚐我的厲害!"
}


-- Named Beasts
L = DBM:GetModLocalization("Shadikith")

L:SetGeneralLocalization{
	name = "滑翔者‧薛迪依斯"
}

L = DBM:GetModLocalization("Hyakiss")

L:SetGeneralLocalization{
	name = "潛伏者‧亞奇斯"
}

L = DBM:GetModLocalization("Rokad")

L:SetGeneralLocalization{
	name = "劫掠者‧拉卡"
}

if WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1) then return end--Anything below here is only needed for classic wrath or classic bc

---------------
--  Nalorakk --
---------------
L = DBM:GetModLocalization("Nalorakk")

L:SetGeneralLocalization{
	name = "納羅拉克"
}

L:SetWarningLocalization{
	WarnBear		= "熊階段",
	WarnBearSoon	= "5秒後 熊階段",
	WarnNormal		= "普通階段",
	WarnNormalSoon	= "5秒後 普通階段"
}

L:SetTimerLocalization{
	TimerBear		= "熊階段",
	TimerNormal		= "普通階段"
}

L:SetOptionLocalization{
	WarnBear		= "為熊階段顯示警告",
	WarnBearSoon	= "為熊階段顯示預先警告",
	WarnNormal		= "為普通階段顯示警告",
	WarnNormalSoon	= "為普通階段顯示預先警告",
	TimerBear		= "為熊階持續時間顯示計時器",
	TimerNormal		= "為普通階段持續時間顯示計時器"
}

L:SetMiscLocalization{
	YellBear 	= "你們既然將野獸召喚出來，就將付出更多的代價!",
	YellNormal	= "沒有人可以擋在納羅拉克的面前!"
}

---------------
--  Akil'zon --
---------------
L = DBM:GetModLocalization("Akilzon")

L:SetGeneralLocalization{
	name = "阿奇爾森"
}

---------------
--  Jan'alai --
---------------
L = DBM:GetModLocalization("Janalai")

L:SetGeneralLocalization{
	name = "賈納雷"
}

L:SetMiscLocalization{
	YellBomb	= "燒死你們!",
	YellAdds	= "雌鷹哪裡去啦?快去孵蛋!"
}

--------------
--  Halazzi --
--------------
L = DBM:GetModLocalization("Halazzi")

L:SetGeneralLocalization{
	name = "哈拉齊"
}

L:SetWarningLocalization{
	WarnSpirit	= "靈魂出現了",
	WarnNormal	= "靈魂消失了"
}

L:SetOptionLocalization{
	WarnSpirit	= "為靈魂階段顯示警告",
	WarnNormal	= "為普通階段顯示警告"
}

L:SetMiscLocalization{
	YellSpirit	= "狂野的靈魂與我同在......",
	YellNormal	= "靈魂，回到我這裡來!"
}

--------------------------
--  Hex Lord Malacrass --
--------------------------
L = DBM:GetModLocalization("Malacrass")

L:SetGeneralLocalization{
	name = "妖術領主瑪拉克雷斯"
}

L:SetMiscLocalization{
	YellPull	= "陰影將會降臨在你們頭上....."
}

--------------
--  Zul'jin --
--------------
L = DBM:GetModLocalization("ZulJin")

L:SetGeneralLocalization{
	name = "祖爾金"
}

L:SetMiscLocalization{
	YellPhase2	= "賜給我一些新的力量……讓我像熊一樣……",
	YellPhase3	= "在雄鷹之下無所遁形!",
	YellPhase4	= "讓我來介紹我的新兄弟:尖牙和利爪!",
	YellPhase5	= "你不需要仰望天空才看得到龍鷹!"
}
