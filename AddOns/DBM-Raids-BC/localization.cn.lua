if GetLocale() ~= "zhCN" then return end

local L

---------------
--  Kalecgos --
---------------
L = DBM:GetModLocalization("Kal")

L:SetGeneralLocalization{
	name = "卡雷苟斯"
}

L:SetWarningLocalization{
	WarnPortal			= "传送 #%d : >%s< (%d组)",
	SpecWarnWildMagic	= "狂野魔法 - %s!"
}

L:SetTimerLocalization{
	TimerNextPortal		= "传送 (%d)"
}

L:SetOptionLocalization{
	WarnPortal			= "Show warning for $spell:46021 target",--Translate
	SpecWarnWildMagic	= "Show special warning for Wild Magic",--Translate
	TimerNextPortal		= "Show timer for portals",--Translate
	RangeFrame			= "Show range frame (10 yards)",--Translate
	ShowFrame			= "Show Spectral Realm frame" ,--Translate
	FrameClassColor		= "Use class colors in Spectral Realm frame",--Translate
	FrameUpwards		= "Expand Spectral Realm frame upwards",--Translate
	FrameLocked			= "Set Spectral Realm frame not movable"--Translate
}

L:SetMiscLocalization{
	Demon				= "腐蚀者萨索瓦尔",
	Heal				= "+100%治疗效果",
	Haste				= "+100%施法时间",
	Hit					= "-50%命中几率",
	Crit				= "+100%爆击伤害",
	Aggro				= "+100%威胁值",
	Mana				= "-50%技能消耗",
	FrameTitle			= "首领生命值",
	FrameLock			= "锁定框体",
	FrameClassColor		= "使用职业颜色",
	FrameOrientation	= "灵魂世界框体向上延伸",
	FrameHide			= "隐藏框体",
	FrameClose			= "Close"--Translate
}

----------------
--  Brutallus --
----------------
L = DBM:GetModLocalization("Brutallus")

L:SetGeneralLocalization{
	name = "布鲁塔卢斯"
}

L:SetMiscLocalization{
	Pull			= "啊，又来了一群小绵羊！"
}

--------------
--  Felmyst --
--------------
L = DBM:GetModLocalization("Felmyst")

L:SetGeneralLocalization{
	name = "菲米丝"
}

L:SetWarningLocalization{
	WarnPhase		= "%s阶段",
	WarnPhaseSoon	= "%s阶段 in 10 sec",
	WarnBreath		= "深呼吸 (%d)"
}

L:SetTimerLocalization{
	TimerPhase		= "%s阶段",
	TimerBreath		= "深呼吸"
}

L:SetOptionLocalization{
	WarnPhase		= "Show warning for next phase",--Translate
	WarnPhaseSoon	= "Show pre-warning for next phase",--Translate
	WarnBreath		= "Show warning for Deep Breath",--Translate
	TimerPhase		= "Show time for next phase",--Translate
	TimerBreath		= "Show timer for Deep Breath cooldown",--Translate
	VaporIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(45392),
	EncapsIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(45665),
	YellOnEncaps	= "Yell on $spell:45665"
}

L:SetMiscLocalization{
	Air				= "空中",
	Ground			= "地面",
	YellEncaps		= "Encapsulate on me! Run away!",--Change to generic so we don't have to translate?
	AirPhase		= "I am stronger than ever before!",--Translate
	Breath			= "%s深深地吸了一口气。"
}

-----------------------
--  The Eredar Twins --
-----------------------
L = DBM:GetModLocalization("Twins")

L:SetGeneralLocalization{
	name = "艾瑞达双子"
}

L:SetMiscLocalization{
	Nova			= "萨洛拉丝向([^%s]+)施放暗影新星。",--Verify
	Conflag			= "奥蕾塞丝向([^%s]+)施放燃烧。"--Verify
}

------------
--  M'uru --
------------
L = DBM:GetModLocalization("Muru")

L:SetGeneralLocalization{
	name = "穆鲁"
}

L:SetWarningLocalization{
	WarnHuman		= "暗誓精灵 (%d)",
	WarnHumanSoon	= "暗誓精灵 - 5秒后出现 (%d)",
	WarnVoid		= "虚空戒卫 (%d)",
	WarnVoidSoon	= "虚空戒卫 - 5秒后出现 (%d)",
	WarnFiend		= "黑暗魔出现"
}

L:SetTimerLocalization{
	TimerHuman		= "暗誓精灵 (%s)",
	TimerVoid		= "虚空戒卫 (%s)",
	TimerPhase		= "熵魔"
}

L:SetOptionLocalization{
	WarnHuman		= "Show warning for Humanoids",--Translate
	WarnHumanSoon	= "Show pre-warning for Humanoids",--Translate
	WarnVoid		= "Show warning for Void Sentinels",--Translate
	WarnVoidSoon	= "Show pre-warning for Void Sentinels",--Translate
	WarnFiend		= "Show warning for Fiends in phase 2",--Translate
	TimerHuman		= "Show timer for Humanoids",--Translate
	TimerVoid		= "Show timer for Void Sentinels",--Translate
	TimerPhase		= "Show time for Phase 2 transition"--Translate
}

L:SetMiscLocalization{
	Entropius		= "熵魔"
}

----------------
--  Kil'jeden --
----------------
L = DBM:GetModLocalization("Kil")

L:SetGeneralLocalization{
	name = "基尔加丹"
}

L:SetWarningLocalization{
	WarnDarkOrb		= "Dark Orbs Spawned",--Translate
	WarnBlueOrb		= "Dragon Orb activated",--Translate
	SpecWarnDarkOrb	= "Dark Orbs Spawned!",--Translate
	SpecWarnBlueOrb	= "Dragon Orbs Activated!"--Translate
}

L:SetTimerLocalization{
	TimerBlueOrb	= "Dragon Orbs activate"--Translate
}

L:SetOptionLocalization{
	WarnDarkOrb		= "Show warning for Dark Orbs",--Translate
	WarnBlueOrb		= "Show warning for Dragon Orbs",--Translate
	SpecWarnDarkOrb	= "Show special warning for Dark Orbs",--Translate
	SpecWarnBlueOrb	= "Show special warning for Dragon Orbs",--Translate
	TimerBlueOrb	= "Show timer form Dragon Orbs activate",--Translate
	RangeFrame		= "Show range frame (10 yards)",--Translate
	BloomIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(45641),
	YellOnBloom		= "Yell on $spell:45641",--Translate
	BloomWhisper	= "Send whisper to $spell:45641 target (requires Raid Leader)"--Translate
}

L:SetMiscLocalization{
	YellPull		= "这个消耗品已经没用了，不管她了！现在我已经做到了连萨格拉斯都没有做到的事情！我要彻底毁灭这个世界，真正成",
	YellBloom		= "我中了火焰之花！",
	BloomWhisper	= "火焰之花！",
	OrbYell1		= "I will channel my powers into the orbs! Be ready!",--Translate
	OrbYell2		= "I have empowered another orb! Use it quickly!",--Translate
	OrbYell3		= "Another orb is ready! Make haste!",--Translate
	OrbYell4		= "I have channeled all I can! The power is in your hands!"--Translate

}

-----------------
--  Najentus  --
-----------------
L = DBM:GetModLocalization("Najentus")

L:SetGeneralLocalization{
	name = "高阶督军纳因图斯"
}

L:SetMiscLocalization{
	HealthInfo	= "Health Info"
}

----------------
-- Supremus --
----------------
L = DBM:GetModLocalization("Supremus")

L:SetGeneralLocalization{
	name = "苏普雷姆斯"
}

L:SetWarningLocalization{
	WarnPhase		= "%s Phase",--Translate
}

L:SetTimerLocalization{
	TimerPhase		= "Next %s phase"--Translate
}

L:SetOptionLocalization{
	WarnPhase		= "Show warning for next phase",
	TimerPhase		= "Show time for next phase",
	KiteIcon		= "Set icon on Kite target"
}

L:SetMiscLocalization{
	PhaseTank		= "愤怒地击打着地面！",--Check if Backwards
	PhaseKite		= "地面崩裂了！",--Check if Backwards
	ChangeTarget	= "锁定了一个新目标！",
	Kite			= "Kite",--Translate
	Tank			= "Tank"--Translate
}

-------------------------
--  Shape of Akama  --
-------------------------
L = DBM:GetModLocalization("Akama")

L:SetGeneralLocalization{
	name = "阿卡玛之影"
}

L:SetWarningLocalization({
	warnAshtongueDefender	= "灰舌防御者",
	warnAshtongueSorcerer	= "灰舌巫师"
})

L:SetTimerLocalization({
	timerAshtongueDefender	= "灰舌防御者: %s",
	timerAshtongueSorcerer	= "灰舌巫师: %s"
})

L:SetOptionLocalization({
	warnAshtongueDefender	= "警报：灰舌防御者",
	warnAshtongueSorcerer	= "警报：灰舌巫师",
	timerAshtongueDefender	= "计时条：灰舌防御者",
	timerAshtongueSorcerer	= "计时条：灰舌巫师"
})

-------------------------
--  Teron Gorefiend  --
-------------------------
L = DBM:GetModLocalization("TeronGorefiend")

L:SetGeneralLocalization{
	name = "塔隆·血魔"
}

L:SetTimerLocalization{
	TimerVengefulSpirit		= "Ghost : %s"--Translate
}

L:SetOptionLocalization{
	TimerVengefulSpirit		= "Show timer for Ghost durations"--Translate
}

L:SetMiscLocalization{
}

----------------------------
--  Gurtogg Bloodboil  --
----------------------------
L = DBM:GetModLocalization("Bloodboil")

L:SetGeneralLocalization{
	name = "古尔图格·血沸"
}

--------------------------
--  Essence Of Souls  --
--------------------------
L = DBM:GetModLocalization("Souls")

L:SetGeneralLocalization{
	name = "灵魂之匣"
}

L:SetWarningLocalization{
	WarnMana		= "30秒后法力消耗殆尽"
}

L:SetTimerLocalization{
	TimerMana		= "法力吸取"
}

L:SetOptionLocalization{
	WarnMana		= "Show warning from zero mana in Phase 2",--Translate
	TimerEnrage		= "Show timer for Enrage"--Translate
}

L:SetMiscLocalization{
	Suffering		= "Essence of Suffering",--Translate
	Desire			= "Essence of Desire",--Translate
	Anger			= "Essence of Anger",--Translate
	Phase1End		= "I don't want to go back!",
	Phase2End		= "I won't be far!"
}

-----------------------
--  Mother Shahraz --
-----------------------
L = DBM:GetModLocalization("Shahraz")

L:SetGeneralLocalization{
	name = "莎赫拉丝主母"
}

L:SetTimerLocalization{
	timerAura	= "%s"
}

L:SetOptionLocalization{
	timerAura	= "Show timer for Prismatic Aura"
}

----------------------
--  Illidari Council  --
----------------------
L = DBM:GetModLocalization("Council")

L:SetGeneralLocalization{
	name = "伊利达雷议会"
}

L:SetWarningLocalization{
	Immune			= "Malande - %s immune for 15 sec"
}

L:SetOptionLocalization{
	Immune			= "Show warning when Manalde becomes spell or melee immune"
}

L:SetMiscLocalization{
	Gathios			= "击碎者加西奥斯",
	Malande			= "女公爵玛兰德",
	Zerevor			= "高阶灵术师塞勒沃尔",
	Veras			= "薇尔莱丝·深影",
	Melee			= "近战",
	Spell			= "法术"
}

-------------------------
--  Illidan Stormrage --
-------------------------
L = DBM:GetModLocalization("Illidan")

L:SetGeneralLocalization{
	name = "伊利丹·怒风"
}

L:SetWarningLocalization{
	WarnHuman		= "普通形态",
	WarnDemon		= "恶魔形态"
}

L:SetTimerLocalization{
	TimerNextHuman		= "下一个普通形态",
	TimerNextDemon		= "下一个恶魔形态"
}

L:SetOptionLocalization{
	WarnHuman		= "Show warning for 普通形态",
	WarnDemon		= "Show warning for 恶魔形态",
	TimerNextHuman	= "Show time for 下一个普通形态",
	TimerNextDemon	= "Show time for 下一个恶魔形态",
	RangeFrame		= "为阶段3和阶段4显示10码距离提示"
}

L:SetMiscLocalization{
	Pull			= "阿卡玛。你的两面三刀并没有让我感到意外。我早就应该把你和你那些畸形的同胞全部杀掉。",
	Eyebeam			= "直视背叛者的双眼吧！",
	Demon			= "感受我体内的恶魔之力吧！",
	Phase4			= "你们就这点本事吗？这就是你们全部的能耐？"
}

------------------------
--  Rage Winterchill  --
------------------------
L = DBM:GetModLocalization("Rage")

L:SetGeneralLocalization{
	name = "雷基·冬寒"
}

-----------------
--  Anetheron  --
-----------------
L = DBM:GetModLocalization("Anetheron")

L:SetGeneralLocalization{
	name = "安纳塞隆"
}

----------------
--  Kazrogal  --
----------------
L = DBM:GetModLocalization("Kazrogal")

L:SetGeneralLocalization{
	name = "卡兹洛加"
}

---------------
--  Azgalor  --
---------------
L = DBM:GetModLocalization("Azgalor")

L:SetGeneralLocalization{
	name = "阿兹加洛"
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
	name 		= "普通怪物"
}
L:SetWarningLocalization{
	WarnWave	= "%s",
	WarnWaveSoon= "下一波敌人即将到来"
}
L:SetTimerLocalization{
	TimerWave	= "Next wave"--Translate
}
L:SetOptionLocalization{
	WarnWave		= "Warn when a new wave is incoming",--Translate
	WarnWaveSoon	= "Warn when a new wave is incoming soon",--Translate
	DetailedWave	= "Detailed warning when a new wave is incoming (which mobs)",--Translate
	TimerWave		= "Show a timer for next wave"--Translate
}
L:SetMiscLocalization{
	HyjalZoneName	= "海加尔峰",
	Thrall			= "萨尔",
	Jaina			= "吉安娜·普罗德摩尔",
	RageWinterchill	= "雷基·冬寒",
	Anetheron		= "安纳塞隆",
	Kazrogal		= "卡兹洛加",
	Azgalor			= "阿兹加洛",
	WarnWave_0		= "第%s/8波",
	WarnWave_1		= "第%s/8波 - %s%s",
	WarnWave_2		= "第%s/8波 - %s%s 和 %s%s",
	WarnWave_3		= "第%s/8波 - %s%s, %s%s 和 %s%s",
	WarnWave_4		= "第%s/8波 - %s%s, %s%s, %s%s 和 %s%s",
	WarnWave_5		= "第%s/8波 - %s%s, %s%s, %s%s, %s%s 和 %s%s",
	RageGossip		= "我和我的伙伴们将与您并肩作战，普罗德摩尔女士。",
	AnetheronGossip	= "我们已经准备好对付阿克蒙德的任何爪牙了，普罗德摩尔女士。",
	KazrogalGossip	= "我与你并肩作战，萨尔。",
	AzgalorGossip	= "我们无所畏惧。",
	Ghoul			= "食尸鬼",
	Abomination		= "憎恶",
	Necromancer		= "亡灵巫师",
	Banshee			= "女妖",
	Fiend			= "地穴恶魔",
	Gargoyle		= "石像鬼",
	Wyrm			= "冰霜巨龙",
	Stalker			= "恶魔猎犬",
	Infernal		= "地狱火"
}

-----------
--  Alar --
-----------
L = DBM:GetModLocalization("Alar")

L:SetGeneralLocalization{
	name = "奥"
}

L:SetTimerLocalization{
	NextPlatform	= "下一个位置"
}

L:SetOptionLocalization{
	NextPlatform	= "Show timer for when Al'ar changes platforms"
}

------------------
--  Void Reaver --
------------------
L = DBM:GetModLocalization("VoidReaver")

L:SetGeneralLocalization{
	name = "空灵机甲"
}

--------------------------------
--  High Astromancer Solarian --
--------------------------------
L = DBM:GetModLocalization("Solarian")

L:SetGeneralLocalization{
	name = "大星术师索兰莉安"
}

L:SetWarningLocalization{
	WarnSplit		= "*** 下属即将出现 ***",
	WarnSplitSoon	= "*** 5秒后分裂 ***",
	WarnAgent		= "*** 密探出现 ***",
	WarnPriest		= "*** 祭司与索兰莉安出现 ***"

}

L:SetTimerLocalization{
	TimerSplit		= "分裂",
	TimerAgent		= "密探",
	TimerPriest		= "祭司与索兰莉安"
}

L:SetOptionLocalization{
	WarnSplit		= "Show warning for Split",
	WarnSplitSoon	= "Show pre-warning for Split",
	WarnAgent		= "Show warning for Agents spawn",
	WarnPriest		= "Show warning for Priests and Solarian spawn",
	TimerSplit		= "Show timer for Split",
	TimerAgent		= "Show timer for Agents spawn",
	TimerPriest		= "Show timer for Priests and Solarian spawn",
	WrathWhisper	= "向受到星术师之怒效果的目标发送密语"
}

L:SetMiscLocalization{
	WrathWhisper	= "星术师之怒！",
	YellSplit1		= "I will crush your delusions of grandeur!",--Translate
	YellSplit2		= "You are hopelessly outmatched!",--Translate
	YellPhase2		= "I become"--Translate
}

---------------------------
--  Kael'thas Sunstrider --
---------------------------
L = DBM:GetModLocalization("KaelThas")

L:SetGeneralLocalization{
	name = "凯尔萨斯·逐日者"
}

L:SetWarningLocalization{
	WarnGaze		= "*** 萨拉德雷注视着>%s< ***",
	WarnMobDead		= "%s down",--Translate
	WarnEgg			= "*** 凤凰倒下 - 卵出现 ***",
	SpecWarnGaze	= "快跑！",
	SpecWarnEgg		= "*** 凤凰倒下 - 卵出现 ***"
}

L:SetTimerLocalization{
	TimerPhase		= "Next Phase",--Translate
	TimerPhase1mob	= "%s",
	TimerNextGaze	= "凝视冷却",
	TimerRebirth	= "复生"
}

L:SetOptionLocalization{
	WarnGaze		= "Show warning for Thaladred's Gaze target",--Translate
	WarnMobDead		= "Show warning for Phase 2 mob down",--Translate
	WarnEgg			= "Show warning when Phoenix Egg spawn",--Translate
	SpecWarnGaze	= "Show special warning when Gaze on you",--Translate
	SpecWarnEgg		= "Show special warning when Phoenix Egg spawn",--Translate
	TimerPhase		= "Show time for next phase",--Translate
	TimerPhase1mob	= "Show time for Phase 1 mob active",--Translate
	TimerNextGaze	= "Show timer for Thaladred's Gaze target changes",--Translate
	TimerRebirth	= "Show timer for Phoenix Egg rebirth remaining",--Translate
	GazeWhisper		= "对萨拉德雷的目标发送密语",
	GazeIcon		= "对萨拉德雷的目标添加标注"
}

L:SetMiscLocalization{
	YellPhase2	= "你们看，我的个人收藏中有许多武器……",
	YellPhase3	= "也许我确实低估了你们。虽然让你们同时面对我的四位顾问显得有些不公平，但是我的人民从来都没有得到过公平的待遇。我只是在以牙还牙。",
	YellPhase4	= "唉，有些时候，有些事情，必须得亲自解决才行。Balamore shanal！",
	YellPhase5	= "我的心血是不会被你们轻易浪费的！我精心谋划的未来是不会被你们轻易破坏的！感受我真正的力量吧！",
	YellSang	= "你们击败了我最强大的顾问……但是没有人能战胜鲜血之锤。出来吧，萨古纳尔男爵！",
	YellCaper	= "卡波妮娅会很快解决你们的。",
	YellTelo	= "干得不错。看来你们有能力挑战我的首席技师，塔隆尼库斯。",
	EmoteGaze	= "凝视着([^%s]+)！",
	GazeWhisper	= "萨拉德雷注视着你！快跑！",
	Thaladred	= "萨拉德雷",
	Sanguinar	= "萨古纳尔",
	Capernian	= "卡波妮娅",
	Telonicus	= "塔隆尼库斯",
	Bow			= "弓",
	Axe			= "斧",
	Mace		= "锤",
	Dagger		= "匕首",
	Sword		= "剑",
	Shield		= "盾牌",
	Staff		= "法杖",
	Egg			= "凤凰卵"
}

---------------------------
--  Hydross the Unstable --
---------------------------
L = DBM:GetModLocalization("Hydross")

L:SetGeneralLocalization{
	name = "不稳定的海度斯"
}

L:SetWarningLocalization{
	WarnMark 		= "%s : %s",
	WarnPhase		= "%s Phase",--Translate
	SpecWarnMark	= "%s : %s"
}

L:SetTimerLocalization{
	TimerMark	= "Next %s : %s"--Translate
}

L:SetOptionLocalization{
	WarnMark		= "警报印记",
	WarnPhase		= "警报阶段变化",
	SpecWarnMark	= "Show warning when Marks debuff damage over 100%",--Translate
	TimerMark		= "Show timer for next Marks"--Translate
}

L:SetMiscLocalization{
	Frost	= "冰霜阶段",
	Nature	= "自然阶段"
}

-----------------------
--  The Lurker Below --
-----------------------
L = DBM:GetModLocalization("LurkerBelow")

L:SetGeneralLocalization{
	name = "鱼斯拉"
}

L:SetWarningLocalization{
	WarnSubmerge		= "下潜",
	WarnSubmergeSoon	= "Submerge in 10 sec",--Translate
	WarnEmerge			= "重新出现",
	WarnEmergeSoon		= "Emerge in 10 sec"--Translate
}

L:SetTimerLocalization{
	TimerSubmerge		= "下潜",
	TimerEmerge			= "重新出现"
}

L:SetOptionLocalization{
	WarnSubmerge		= "Show warning when submerge",--Translate
	WarnSubmergeSoon	= "Show pre-warning for submerge",--Translate
	WarnEmerge			= "Show warning when emerge",--Translate
	WarnEmergeSoon		= "Show pre-warning for emerge",--Translate
	TimerSubmerge		= "Show time for submerge",--Translate
	TimerEmerge			= "Show time for emerge"--Translate
}

L:SetMiscLocalization{
	Spout	= "%s深深吸了一口气！"
}

--------------------------
--  Leotheras the Blind --
--------------------------
L = DBM:GetModLocalization("Leotheras")

L:SetGeneralLocalization{
	name = "盲眼者莱欧瑟拉斯"
}

L:SetWarningLocalization{
	WarnPhase		= "%s Phase",--Translate
	WarnPhaseSoon	= "%s Phase in 5 sec"--Translate
}

L:SetTimerLocalization{
	TimerPhase	= "Next %s Phase"--Translate
}

L:SetOptionLocalization{
	WarnPhase		= "Show warning for next phase",--Translate
	WarnPhaseSoon	= "Show pre-warning for next phase",--Translate
	TimerPhase		= "Show time for next phase"--Translate
}

L:SetMiscLocalization{
	Human		= "Human",--Translate
	Demon		= "Demon",--Translate
	YellDemon	= "滚开吧，脆弱的精灵。现在我说了算！",
	YellPhase1  = "我的放逐终于结束了！",
	YellPhase2	= "不……不！你在干什么？我才是主宰！你听到没有？我……啊啊啊啊！控制……不住了。"
}

-----------------------------
--  Fathom-Lord Karathress --
-----------------------------
L = DBM:GetModLocalization("Fathomlord")

L:SetGeneralLocalization{
	name = "深水领主卡拉瑟雷斯"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
}

L:SetMiscLocalization{
	Caribdis	= "Fathom-Guard Caribdis",--Translate
	Tidalvess	= "Fathom-Guard Tidalvess",--Translate
	Sharkkis	= "Fathom-Guard Sharkkis"--Translate
}

--------------------------
--  Morogrim Tidewalker --
--------------------------
L = DBM:GetModLocalization("Tidewalker")

L:SetGeneralLocalization{
	name = "莫洛格里·踏潮者"
}

L:SetWarningLocalization{
	WarnMurlocs		= "鱼人群出现",
	SpecWarnMurlocs	= "鱼人群出现!"
}

L:SetTimerLocalization{
	TimerMurlocs	= "鱼人群"
}

L:SetOptionLocalization{
	WarnMurlocs		= "警报鱼人群",
	SpecWarnMurlocs	= "Show special warning when Murlocs spawning",--Translate
	TimerMurlocs	= "Show timer for Murlocs spawning",--Translate
	GraveIcon		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(38049)
}

L:SetMiscLocalization{
}

-----------------
--  Lady Vashj --
-----------------
L = DBM:GetModLocalization("Vashj")

L:SetGeneralLocalization{
	name = "瓦丝琪"
}

L:SetWarningLocalization{
	WarnElemental		= "被污染的元素 - 5秒后出现 (%s)",
	WarnStrider			= "盘牙巡逻者 - 5秒后出现 (%s)",
	WarnNaga			= "盘牙精英 - 5秒后出现 (%s)",
	WarnShield			= "护盾 - %d/4被击碎",
	WarnLoot			= ">%s<获得了污染之核",
	SpecWarnElemental	= "被污染的元素 - 5秒后出现!"
}

L:SetTimerLocalization{
	TimerElemental		= "被污染的元素 (%d)",--Verify
	TimerStrider		= "盘牙巡逻者 (%d)",--Verify
	TimerNaga			= "盘牙精英 (%d)"--Verify
}

L:SetOptionLocalization{
	WarnElemental		= "Show pre-warning for next Tainted Elemental",--Translate
	WarnStrider			= "Show pre-warning for next Strider",--Translate
	WarnNaga			= "Show pre-warning for next Naga",--Translate
	WarnShield			= "Show warning for Phase 2 shield down",--Translate
	WarnLoot			= "警报是谁拾取了污染之核",
	TimerElemental		= "Show time for next Tainted Elemental",--Translate
	TimerStrider		= "Show time for next Strider",--Translate
	TimerNaga			= "Show time for next Strider",--Translate
	SpecWarnElemental	= "Show special warning when Tainted Elemental coming",--Translate
	ChargeIcon			= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(38280),
	AutoChangeLootToFFA	= "第3阶段自动转换拾取方式为自由拾取"
}

L:SetMiscLocalization{
	DBM_VASHJ_YELL_PHASE2	= "机会来了！一个活口都不要留下！",
	LootMsg				= "(.+)获得了物品：.*Hitem:(%d+)"
}

--Maulgar
L = DBM:GetModLocalization("Maulgar")

L:SetGeneralLocalization{
	name = "莫加尔大王"
}


--Gruul the Dragonkiller
L = DBM:GetModLocalization("Gruul")

L:SetGeneralLocalization{
	name = "屠龙者格鲁尔"
}

L:SetWarningLocalization{
	WarnGrowth	= "%s (%d)"
}

L:SetOptionLocalization{
	WarnGrowth	= "Show warning for $spell:36300"
}


-- Magtheridon
L = DBM:GetModLocalization("Magtheridon")

L:SetGeneralLocalization{
	name = "玛瑟里顿"
}

L:SetTimerLocalization{
	timerP2	= "Phase 2"
}

L:SetOptionLocalization{
	timerP2	= "Show timer for start of phase 2"
}

L:SetMiscLocalization{
	DBM_MAG_EMOTE_PULL		= "%s的禁锢开始变弱！",
	DBM_MAG_YELL_PHASE2		= "我……自由了！",
	DBM_MAG_YELL_PHASE3		= "I will not be taken so easily! Let the walls of this prison tremble... and fall!"
}

--Attumen
L = DBM:GetModLocalization("Attumen")

L:SetGeneralLocalization{
	name = "猎手阿图门"
}

L:SetMiscLocalization{
	DBM_ATH_YELL_1		= "来吧，午夜，让我们解决这群乌合之众！"
}


--Moroes
L = DBM:GetModLocalization("Moroes")

L:SetGeneralLocalization{
	name = "莫罗斯"
}

L:SetWarningLocalization{
	DBM_MOROES_VANISH_FADED	= "消失 - 效果消失"
}

L:SetOptionLocalization{
	DBM_MOROES_VANISH_FADED	= "Show vanish fade warning"
}


-- Maiden of Virtue
L = DBM:GetModLocalization("Maiden")

L:SetGeneralLocalization{
	name = "贞节圣女"
}


-- Romulo and Julianne
L = DBM:GetModLocalization("RomuloAndJulianne")

L:SetGeneralLocalization{
	name = "罗密欧与朱丽叶"
}

L:SetMiscLocalization{
	DBM_RJ_PHASE2_YELL	= "来吧，可爱的黑颜的夜，把我的罗密欧给我！",
	Romulo				= "Romulo",
	Julianne			= "Julianne"
}


-- Big Bad Wolf
L = DBM:GetModLocalization("BigBadWolf")

L:SetGeneralLocalization{
	name = "大灰狼"
}

L:SetMiscLocalization{
	DBM_BBW_YELL_1			= "可以一口把你吃掉呀！"
}


-- Curator
L = DBM:GetModLocalization("Curator")

L:SetGeneralLocalization{
	name = "馆长"
}


-- Terestian Illhoof
L = DBM:GetModLocalization("TerestianIllhoof")

L:SetGeneralLocalization{
	name = "特雷斯坦·邪蹄"
}

L:SetMiscLocalization{
	Kilrek					= "Kil'rek",
	DChains					= "Demon Chains"
}


-- Shade of Aran
L = DBM:GetModLocalization("Aran")

L:SetGeneralLocalization{
	name = "埃兰之影"
}

L:SetWarningLocalization{
	DBM_ARAN_DO_NOT_MOVE	= "不要移动！"
}

L:SetOptionLocalization{
	DBM_ARAN_DO_NOT_MOVE	= "Show special warning for $spell:30004"
}

--Netherspite
L = DBM:GetModLocalization("Netherspite")

L:SetGeneralLocalization{
	name = "虚空幽龙"
}

L:SetWarningLocalization{
	DBM_NS_WARN_PORTAL_SOON	= "5秒后进入虚空门阶段",
	DBM_NS_WARN_BANISH_SOON	= "5秒后进入放逐阶段",
	warningPortal			= "虚空门阶段",
	warningBanish			= "放逐阶段"
}

L:SetTimerLocalization{
	timerPortalPhase	= "虚空门阶段",
	timerBanishPhase	= "放逐阶段"
}

L:SetOptionLocalization{
	DBM_NS_WARN_PORTAL_SOON	= "Show pre-warning for Portal phase",
	DBM_NS_WARN_BANISH_SOON	= "Show pre-warning for Banish phase",
	warningPortal			= "Show warning for Portal phase",
	warningBanish			= "Show warning for Banish phase",
	timerPortalPhase		= "Show timer for Portal Phase duration",
	timerBanishPhase		= "Show timer for Banish Phase duration"
}

L:SetMiscLocalization{
	DBM_NS_EMOTE_PHASE_2	= "%s的怒火甚至可以充满整个虚空！",
	DBM_NS_EMOTE_PHASE_1	= "%s在撤退中大声呼喊着，打开了回到虚空的传送门。"
}


--Prince Malchezaar
L = DBM:GetModLocalization("Prince")

L:SetGeneralLocalization{
	name = "玛克扎尔王子"
}

L:SetMiscLocalization{
	DBM_PRINCE_YELL_P2		= "愚蠢的家伙！时间就是吞噬你躯体的烈焰！",
	DBM_PRINCE_YELL_P3		= "你如何抵挡这无坚不摧的力量？",
	DBM_PRINCE_YELL_INF1	= "所有的世界都向我敞开大门！",
	DBM_PRINCE_YELL_INF2	= "你面对的不仅仅是玛克扎尔，还有我所号令的军团！"
}


-- Nightbane
L = DBM:GetModLocalization("NightbaneRaid")

L:SetGeneralLocalization{
	name = "夜之魇"
}

L:SetWarningLocalization{
	DBM_NB_DOWN_WARN 		= "15秒后夜之魇着陆",
	DBM_NB_DOWN_WARN2 		= "5秒后夜之魇着陆",
	DBM_NB_AIR_WARN			= "空中阶段"
}

L:SetTimerLocalization{
	timerNightbane			= "夜之魇",
	timerAirPhase			= "空中阶段"
}

L:SetOptionLocalization{
	DBM_NB_AIR_WARN			= "Show warning for Air Phase",
	PrewarnGroundPhase		= "Show pre-warnings for Ground Phase",
	timerNightbane			= "Show timer for Nightbane summon",
	timerAirPhase			= "Show timer for Air Phase duration"
}

L:SetMiscLocalization{
	DBM_NB_EMOTE_PULL	= "一个远古的生物在远处被唤醒了……",
	DBM_NB_YELL_AIR		= "可怜的渣滓。我要腾空而起，让你尝尝毁灭的滋味！",
	DBM_NB_YELL_GROUND	= "够了！我要落下来把你们打得粉碎！",
	DBM_NB_YELL_GROUND2	= "没用的虫子！让你们见识一下我的力量吧！"
}


-- Wizard of Oz
L = DBM:GetModLocalization("Oz")

L:SetGeneralLocalization{
	name = "绿野仙踪"
}

L:SetOptionLocalization{
	AnnounceBosses			= "Show warnings for boss spawns",
	ShowBossTimers			= "Show timers for boss spawns"
}

L:SetMiscLocalization{
	DBM_OZ_WARN_TITO		= "托托",
	DBM_OZ_WARN_ROAR		= "胆小的狮子",
	DBM_OZ_WARN_STRAWMAN	= "稻草人",
	DBM_OZ_WARN_TINHEAD		= "铁皮人",
	DBM_OZ_WARN_CRONE		= "巫婆",
	DBM_OZ_YELL_DOROTHEE	= "啊，托托，我们必须找到回家的路！那位老巫师是我们唯一的希望了！稻草人、狮子，还有铁皮人，你们能不能——呀，有人来了！",
	DBM_OZ_YELL_ROAR		= "我不怕你们！你们想打架？那就来呀！来呀！我不用前爪都可以打败你们！",
	DBM_OZ_YELL_STRAWMAN	= "我该把你怎么办？我完全不知道。",
	DBM_OZ_YELL_TINHEAD		= "我真的需要一颗心。啊，用你的行吗？",
	DBM_OZ_YELL_CRONE		= "我为你们感到可悲，小家伙们！"
}


-- Named Beasts
L = DBM:GetModLocalization("Shadikith")

L:SetGeneralLocalization{
	name = "滑翔者沙德基斯"
}

L = DBM:GetModLocalization("Hyakiss")

L:SetGeneralLocalization{
	name = "潜伏者希亚其斯"
}

L = DBM:GetModLocalization("Rokad")

L:SetGeneralLocalization{
	name = "蹂躏者洛卡德"
}

if WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1) then return end--Anything below here is only needed for classic wrath or classic bc

---------------
--  Nalorakk --
---------------
L = DBM:GetModLocalization("Nalorakk")

L:SetGeneralLocalization{
	name = "纳洛拉克"
}

L:SetWarningLocalization{
	WarnBear		= "熊形态",
	WarnBearSoon	= "5秒后变为熊形态",
	WarnNormal		= "人形态",
	WarnNormalSoon	= "5秒后变为人形态"
}

L:SetTimerLocalization{
	TimerBear		= "熊形态",
	TimerNormal		= "人形态"
}

L:SetOptionLocalization{
	WarnBear		= "警报：熊形态",
	WarnBearSoon	= "预警：熊形态",
	WarnNormal		= "警报：人形态",
	WarnNormalSoon	= "预警：人形态",
	TimerBear		= "计时条：熊形态",
	TimerNormal		= "计时条：人形态"
}

L:SetMiscLocalization{
	YellBear 	= "你们召唤野兽？你马上就要大大的后悔了！",
	YellNormal	= "纳洛拉克，变形，出发！"
}

---------------
--  Akil'zon --
---------------
L = DBM:GetModLocalization("Akilzon")

L:SetGeneralLocalization{
	name = "埃基尔松"
}

---------------
--  Jan'alai --
---------------
L = DBM:GetModLocalization("Janalai")

L:SetGeneralLocalization{
	name = "加亚莱"
}

L:SetMiscLocalization{
	YellBomb	= "烧死你们！",
	YellAdds	= "雌鹰哪里去了？快去孵蛋！"
}

--------------
--  Halazzi --
--------------
L = DBM:GetModLocalization("Halazzi")

L:SetGeneralLocalization{
	name = "哈尔拉兹"
}

L:SetWarningLocalization{
	WarnSpirit	= "灵魂分裂",
	WarnNormal	= "灵魂消失"
}

L:SetOptionLocalization{
	WarnSpirit	= "警报：灵魂阶段",
	WarnNormal	= "警报：正常阶段"
}

L:SetMiscLocalization{
	YellSpirit	= "狂野的灵魂与我同在……",
	YellNormal	= "灵魂，到我这里来！"
}

--------------------------
--  Hex Lord Malacrass --
--------------------------
L = DBM:GetModLocalization("Malacrass")

L:SetGeneralLocalization{
	name = "妖术领主玛拉卡斯"
}

L:SetMiscLocalization{
	YellPull	= "阴影将会降临在你们头上……"
}

--------------
--  Zul'jin --
--------------
L = DBM:GetModLocalization("ZulJin")

L:SetGeneralLocalization{
	name = "祖尔金"
}

L:SetMiscLocalization{
	YellPhase2	= "你看我有许多新招，变个熊……",
	YellPhase3	= "变成猎鹰，谁也别想逃出我的眼睛！",
	YellPhase4	= "现在来让你看看我的尖牙和利爪！",
	YellPhase5	= "龙鹰，不用抬头就能看见！"
}
