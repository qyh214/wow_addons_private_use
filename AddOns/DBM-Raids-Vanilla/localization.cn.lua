if GetLocale() ~= "zhCN" then return end
local L

------------
-- Skeram --
------------
L = DBM:GetModLocalization("Skeram")

L:SetGeneralLocalization{
	name = "预言者斯克拉姆"
}

----------------
-- Three Bugs --
----------------
L = DBM:GetModLocalization("ThreeBugs")

L:SetGeneralLocalization{
	name = "异种蝎皇族"
}
L:SetMiscLocalization{
	Yauj = "亚尔基公主",
	Vem = "维姆",
	Kri = "克里勋爵"
}

-------------
-- Sartura --
-------------
L = DBM:GetModLocalization("Sartura")

L:SetGeneralLocalization{
	name = "沙尔图拉"
}

--------------
-- Fankriss --
--------------
L = DBM:GetModLocalization("Fankriss")

L:SetGeneralLocalization{
	name = "顽强的范克瑞斯"
}

--------------
-- Viscidus --
--------------
L = DBM:GetModLocalization("Viscidus")

L:SetGeneralLocalization{
	name = "维希度斯"
}
L:SetWarningLocalization{
	WarnFreeze	= "冰冻:%d/3",
	WarnShatter	= "打碎:%d/3"
}
L:SetOptionLocalization{
	WarnFreeze	= "提示冰冻状态",
	WarnShatter	= "提示打碎状态"
}
L:SetMiscLocalization{
	Slow	= "开始减速!",
	Freezing= "冻住了",
	Frozen	= "变成冰冻的固体!",
	Phase4 	= "开始爆裂!",
	Phase5 	= "看來准备好毁灭了!",
	Phase6 	= "爆炸."
}
-------------
-- Huhuran --
-------------
L = DBM:GetModLocalization("Huhuran")

L:SetGeneralLocalization{
	name = "哈霍兰公主"
}
---------------
-- Twin Emps --
---------------
L = DBM:GetModLocalization("TwinEmpsAQ")

L:SetGeneralLocalization{
	name = "双子皇帝"
}
L:SetMiscLocalization{
	Veklor = "维克洛尔大帝",
	Veknil = "维克尼拉斯大帝"
}

------------
-- C'Thun --
------------
L = DBM:GetModLocalization("CThun")

L:SetGeneralLocalization{
	name = "克苏恩"
}
L:SetWarningLocalization{
	WarnEyeTentacle			= "眼球触须",
	WarnClawTentacle2		= "利爪触须",
	WarnGiantEyeTentacle	= "巨眼触须",
	WarnGiantClawTentacle	= "巨钩触须",
	SpecWarnWeakened		= "克苏恩的力量被削弱了！"
}
L:SetTimerLocalization{
	TimerEyeTentacle		= "下一次眼球触须",
	TimerClawTentacle		= "下一次利爪触须",
	TimerGiantEyeTentacle	= "下一次巨眼触须",
	TimerGiantClawTentacle	= "下一次巨钩触须",
	TimerWeakened			= "虚弱结束"
}
L:SetOptionLocalization{
	WarnEyeTentacle			= "为眼球触须显示警告",
	WarnClawTentacle2		= "为利爪触须显示警告",
	WarnGiantEyeTentacle	= "为巨眼触须显示警告",
	WarnGiantClawTentacle	= "为巨钩触须显示警告",
	WarnWeakened			= "当首领虚弱時显示警告",
	SpecWarnWeakened		= "当首领虚弱時显示特別警告",
	TimerEyeTentacle		= "为下一次眼球触须显示计时器",
	TimerClawTentacle		= "为下一次利爪触须显示计时器",
	TimerGiantEyeTentacle	= "为下一次巨眼触须显示计时器",
	TimerGiantClawTentacle	= "为下一次巨钩触须显示计时器",
	TimerWeakened			= "为首领虚弱時间显示计时器",
	RangeFrame				= "显示距离框架(10码)"
}
L:SetMiscLocalization{
	Stomach		= "克苏恩的胃",
	Eye			= "克苏恩之眼",
	FleshTent	= "血肉触须",--Localized so it shows on frame in users language, not senders
	Weakened 	= "削弱了",
    NotValid	= "AQ40 击杀信息： %s 首领未击杀。"
}
----------------
-- Ouro --
----------------
L = DBM:GetModLocalization("Ouro")

L:SetGeneralLocalization{
	name = "奥罗"
}
L:SetWarningLocalization{
	WarnSubmerge		= "钻地",
	WarnEmerge			= "现身"
}
L:SetTimerLocalization{
	TimerSubmerge		= "钻地",
	TimerEmerge			= "现身"
}
L:SetOptionLocalization{
	WarnSubmerge		= "为钻地显示警告",
	TimerSubmerge		= "为钻地显示计时器",
	WarnEmerge			= "为现身显示警告",
	TimerEmerge			= "为现身显示计时器"
}

---------------
-- Kurinnaxx --
---------------
L = DBM:GetModLocalization("Kurinnaxx")

L:SetGeneralLocalization{
	name 		= "库林纳克斯"
}

------------
-- Rajaxx --
------------
L = DBM:GetModLocalization("Rajaxx")

L:SetGeneralLocalization{
	name 		= "拉贾克斯将军"
}
L:SetWarningLocalization{
	WarnWave	= "进攻次数%s",
}
L:SetOptionLocalization{
	WarnWave	= "为下一次进攻显示提示"
}
L:SetMiscLocalization{
	Wave12		= "它们来了。尽量别被它们干掉，新兵。",
	Wave3		= "我们惩罚的时刻就在眼前!让黑暗支配敌人的内心吧!",
	Wave4		= "我们不需在被禁堵的门与石墙后等待了!我们的复仇将不再被否认!巨龙将在我们的愤怒之前颤抖!",
	Wave5		= "恐惧是给敌人的!恐惧与死亡!",
	Wave6		= "鹿盔将为了活命而啜泣、乞求，就像他的儿子一样!一千年的不公将在今日结束!",
	Wave7		= "范达尔!你的时候到了!躲进翡翠梦境祈祷我们永远不会找到你吧!",
	Wave8		= "厚颜无耻的笨蛋!我要亲手杀了你!"
}

----------
-- Moam --
----------
L = DBM:GetModLocalization("Moam")

L:SetGeneralLocalization{
	name 		= "莫阿姆"
}

----------
-- Buru --
----------
L = DBM:GetModLocalization("Buru")

L:SetGeneralLocalization{
	name 		= "『暴食者』布鲁"
}
L:SetWarningLocalization{
	WarnPursue		= ">%s<被追击了",
	SpecWarnPursue	= "你被追击了",
	WarnDismember	= ">%2$s<中了%1$s(%s)"
}
L:SetOptionLocalization{
	WarnPursue		= "提示被追击的目标",
	SpecWarnPursue	= "当你被追击的时候显示特別警告"
}
L:SetMiscLocalization{
	PursueEmote 	= "%s凝视着%s!"
}

-------------
-- Ayamiss --
-------------
L = DBM:GetModLocalization("Ayamiss")

L:SetGeneralLocalization{
	name 		= "『狩猎者』阿亚米斯"
}

--------------
-- Ossirian --
--------------
L = DBM:GetModLocalization("Ossirian")

L:SetGeneralLocalization{
	name 		= "『无疤者』奥斯里安"
}
L:SetWarningLocalization{
	WarnVulnerable	= "%s"
}
L:SetTimerLocalization{
	TimerVulnerable	= "%s"
}
L:SetOptionLocalization{
	WarnVulnerable	= "提示虛弱",
	TimerVulnerable	= "为虛弱显示计时器"
}

----------------
-- AQ20 Trash --
----------------
L = DBM:GetModLocalization("AQ20Trash")

L:SetGeneralLocalization{
	name = "AQ20：全程计时"
}

-----------------
--  Razorgore  --
-----------------
L = DBM:GetModLocalization("Razorgore")

L:SetGeneralLocalization{
	name = "狂野的拉佐格尔"
}
L:SetTimerLocalization{
	TimerAddsSpawn	= "小怪重生"
}
L:SetOptionLocalization{
	TimerAddsSpawn	= "为第一次小怪重生显示计时器"
}
L:SetMiscLocalization{
	Phase2Emote	= "失去能量，停止运作!",
	YellEgg1	= "你要为强迫我这么做而付出代价！",
	YellEgg2	= "蠢货！这些蛋比你认为的要珍贵的多！", -- needs localized resource
	YellEgg3	= "不！住手！我要你的头颅来弥补你的罪行！",
	YellPull 	= "入侵者闯入孵化室了!警报!不惜一切代价保护蛋!"
}
-------------------
--  Vaelastrasz  --
-------------------
L = DBM:GetModLocalization("Vaelastrasz")

L:SetGeneralLocalization{
	name	= "堕落的瓦拉斯塔茲"
}

L:SetMiscLocalization{
	Event	= "太迟了，朋友! 奈法利斯的腐化已经掌握了我...我已经无法...控制我自己了。"
}
-----------------
--  Broodlord  --
-----------------
L = DBM:GetModLocalization("Broodlord")

L:SetGeneralLocalization{
	name	= "勒什雷尔"
}

L:SetMiscLocalization{
	Pull	= "你怎么进来的?你们这种生物不能进来!我要毁灭你们!"
}

---------------
--  Firemaw  --
---------------
L = DBM:GetModLocalization("Firemaw")

L:SetGeneralLocalization{
	name = "费尔默"
}

---------------
--  Ebonroc  --
---------------
L = DBM:GetModLocalization("Ebonroc")

L:SetGeneralLocalization{
	name = "埃博诺克"
}

----------------
--  Flamegor  --
----------------
L = DBM:GetModLocalization("Flamegor")

L:SetGeneralLocalization{
	name = "弗莱格尔"
}

-----------------------
--  Vulnerabilities  --
-----------------------
-- Chromaggus, Death Talon Overseer and Death Talon Wyrmguard
L = DBM:GetModLocalization("TalonGuards")

L:SetGeneralLocalization{
	name = "龙人护卫"
}
L:SetWarningLocalization{
	WarnVulnerable		= "%s易伤"
}
L:SetOptionLocalization{
	WarnVulnerable		= "为法术易伤显示提示"
}
L:SetMiscLocalization{
	Fire		= "火焰",
	Nature		= "自然",
	Frost		= "冰霜",
	Shadow		= "暗影",
	Arcane		= "奥术",
	Holy		= "神圣"
}

------------------
--  Chromaggus  --
------------------
L = DBM:GetModLocalization("Chromaggus")

L:SetGeneralLocalization{
	name = "克洛玛古斯"
}
L:SetWarningLocalization{
	WarnBreath		= "%s",
	WarnVulnerable	= "%s易伤"
}
L:SetTimerLocalization{
	TimerBreathCD	= "%s冷却",
	TimerBreath		= "%s施法",
	TimerVulnCD		= "易伤切换"
}
L:SetOptionLocalization{
	WarnBreath		= "为克洛玛古斯其中一个吐息显示警告",
	WarnVulnerable	= "为易伤显示警告",
	TimerBreathCD	= "显示吐息冷却",
	TimerBreath		= "显示吐息施法",
	TimerVulnCD		= "显示易伤周期"
}
L:SetMiscLocalization{
	Breath1	= "第一次吐息",
	Breath2	= "第二次吐息",
	VulnEmote	= "%s的皮肤闪着微光，它畏缩了。",
	Fire		= "火焰",
	Nature		= "自然",
	Frost		= "冰霜",
	Shadow		= "暗影",
	Arcane		= "奥术",
	Holy		= "神圣"
}

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization("Nefarian-Classic")

L:SetGeneralLocalization{
	name = "奈法利安"
}
L:SetWarningLocalization{
	WarnAddsLeft		= "还剩%d个小怪",
	WarnClassCall		= "点名%s",
	specwarnClassCall	= "你的职业被点名！"
}
L:SetTimerLocalization{
	TimerClassCall		= "点名%s结束"
}
L:SetOptionLocalization{
	TimerClassCall		= "为点名持续时间显示计时器",
	WarnAddsLeft		= "通报杀死的龙兽数量，直到进入第2阶段",
	WarnClassCall		= "提示职业点名",
	specwarnClassCall	= "警报：当你的职业被点名时显示警报。",
	WarnPhase			= "提示阶段转换"
}
L:SetMiscLocalization{
	YellP2		= "干得好，我的手下。凡人的勇气开始消退!现在，现在让我们看看他们如何应对黑石之王的力量!!!",
	YellP3		= "不可能!出现吧，我的仆人!再次为我的主人服务!",
	YellShaman	= "萨满，让我看看",
	YellPaladin	= "圣骑士...听说你有无数条命。让我看看到底是怎么样的吧。",
	YellDruid	= "德鲁伊和你们愚蠢的变身术。让我们看看什么会发生吧!",
	YellPriest	= "牧师!如果你要继续像那样治疗，我们还不如让它看起来更有趣!",
	YellWarrior	= "战士，我知道你的力量不只如此!让我们来见识一下吧!",
	YellRogue	= "潜行者?不要躲了，面对我吧!",
	YellWarlock	= "术士，不要随便去玩那些你不理解的法术。看看会发生什么吧?",
	YellHunter	= "猎人和你那讨厌的豌豆射击!",
	YellMage	= "还有法师?你应该小心使用你的魔法...",
	YellDK		= "死亡骑士士们...来这。",
	YellMonk	= "武僧???...又是什么???"
}

----------------
--  Lucifron  --
----------------
L = DBM:GetModLocalization("Lucifron")

L:SetGeneralLocalization{
	name = "鲁西弗隆"
}

----------------
--  Magmadar  --
----------------
L = DBM:GetModLocalization("Magmadar")

L:SetGeneralLocalization{
	name = "玛格曼达"
}

----------------
--  Gehennas  --
----------------
L = DBM:GetModLocalization("Gehennas")

L:SetGeneralLocalization{
	name = "基赫纳斯"
}

------------
--  Garr  --
------------
L = DBM:GetModLocalization("Garr-Classic")

L:SetGeneralLocalization{
	name = "加尔"
}

--------------
--  Geddon  --
--------------
L = DBM:GetModLocalization("Geddon")

L:SetGeneralLocalization{
	name = "迦顿男爵"
}

----------------
--  Shazzrah  --
----------------
L = DBM:GetModLocalization("Shazzrah")

L:SetGeneralLocalization{
	name = "沙斯拉尔"
}

----------------
--  Sulfuron  --
----------------
L = DBM:GetModLocalization("Sulfuron")

L:SetGeneralLocalization{
	name = "萨弗隆先驱者"
}

----------------
--  Golemagg  --
----------------
L = DBM:GetModLocalization("Golemagg")

L:SetGeneralLocalization{
	name = "焚化者古雷曼格"
}

-----------------
--  Majordomo  --
-----------------
L = DBM:GetModLocalization("Majordomo")

L:SetGeneralLocalization{
	name = "管理者埃克索图斯"
}

----------------
--  Ragnaros  --
----------------
L = DBM:GetModLocalization("Ragnaros-Classic")

L:SetGeneralLocalization{
	name = "拉格纳罗斯"
}
L:SetWarningLocalization{
	WarnSubmerge		= "隐没",
	WarnEmerge			= "现身"
}
L:SetTimerLocalization{
	TimerSubmerge		= "隐没",
	TimerEmerge			= "现身"
}
L:SetOptionLocalization{
	WarnSubmerge		= "为隐没显示警告",
	TimerSubmerge		= "为隐没显示计时器",
	WarnEmerge			= "为现身显示警告",
	TimerEmerge			= "为现身显示计时器"
}
L:SetMiscLocalization{
	Submerge	= "出现吧，我的奴仆! 保卫你们的主人!",
	Pull		= "你这个莽撞的家伙!你简直是自寻死路!看吧，你惊动了主人!"
}

-------------------
--  Venoxis  --
-------------------
L = DBM:GetModLocalization("Venoxis")

L:SetGeneralLocalization{
	name = "高阶祭司温诺希斯"
}
L:SetOptionLocalization{
	RangeFrame		= "显示范围框"
}

-------------------
--  Jeklik  --
-------------------
L = DBM:GetModLocalization("Jeklik")

L:SetGeneralLocalization{
	name = "高阶祭司耶克里克"
}

-------------------
--  Marli  --
-------------------
L = DBM:GetModLocalization("Marli")

L:SetGeneralLocalization{
	name = "高阶祭司玛尔里"
}

-------------------
--  Thekal  --
-------------------
L = DBM:GetModLocalization("Thekal")

L:SetGeneralLocalization{
	name = "高阶祭司塞卡尔"
}

L:SetWarningLocalization({
	WarnSimulKill	= "大约15秒内复活"
})

L:SetTimerLocalization({
	TimerSimulKill	= "复活术"
})

L:SetOptionLocalization({
	WarnSimulKill	= "通告第一个怪物倒下,马上将复活",
	TimerSimulKill	= "显示牧师复活计时器"
})

L:SetMiscLocalization({
	PriestDied	= "%s死了。",
	YellPhase2	= "西瓦尔拉，让我感受你的愤怒吧！", --TBD
	YellKill	= "哈卡再也不能束缚我了！我终于可以安息了！", --TBD
	Thekal		= "高阶祭司塞卡尔",
	Zath		= "狂热者扎斯",
	LorKhan		= "狂热者洛卡恩"
})

-------------------
--  Arlokk  --
-------------------
L = DBM:GetModLocalization("Arlokk")

L:SetGeneralLocalization{
	name = "高阶祭司娅尔罗"
}

-------------------
--  Hakkar  --
-------------------
L = DBM:GetModLocalization("Hakkar")

L:SetGeneralLocalization{
	name = "哈卡"
}

-------------------
--  Bloodlord  --
-------------------
L = DBM:GetModLocalization("Bloodlord")

L:SetGeneralLocalization{
	name = "血领主曼多基尔"
}
L:SetMiscLocalization{
	Bloodlord 	= "血领主曼多基尔",
	Ohgan		= "奥根"
}

-------------------
--  Edge of Madness  --
-------------------
L = DBM:GetModLocalization("EdgeOfMadness")

L:SetGeneralLocalization{
	name = "疯狂之缘"
}
L:SetMiscLocalization{
	Hazzarah = "哈札拉尔",
	Renataki = "雷纳塔基",
	Wushoolay = "乌苏雷",
	Grilek = "格里雷克"
}

-------------------
--  Gahz'ranka  --
-------------------
L = DBM:GetModLocalization("Gahzranka")

L:SetGeneralLocalization{
	name = "加兹兰卡"
}

-------------------
--  Jindo  --
-------------------
L = DBM:GetModLocalization("Jindo")

L:SetGeneralLocalization{
	name = "妖术师金度"
}

--------------
--  Onyxia  --
--------------
L = DBM:GetModLocalization("Onyxia")

L:SetGeneralLocalization{
	name 			= "奥妮克希亚"
}

L:SetWarningLocalization{
	WarnWhelpsSoon		= "奥妮克希亚雏龙 即将出现"
}

L:SetTimerLocalization{
	TimerWhelps 		= "奥妮克希亚雏龙"
}

L:SetOptionLocalization{
	TimerWhelps			= "为奥妮克希亚雏龙显示计时条",
	WarnWhelpsSoon		= "为奥妮克希亚雏龙显示预警",
	SoundWTF3			= "为经典传奇式奥妮克希亚副本播放一些有趣的音效"
}

L:SetMiscLocalization{
	Breath 			= "%s深深地吸了一口气",
	YellPull 		= "真是走运。通常我必须离开窝才能找到食物。",
	YellP2 			= "这毫无意义的行动让我很厌烦。我会从上空把你们都烧成灰！",
	YellP3 			= "看起来需要再给你一次教训，凡人！"
}

-------------------
--  Anub'Rekhan  --
-------------------
L = DBM:GetModLocalization("Anub'Rekhan")

L:SetGeneralLocalization({
	name 				= "阿努布雷坎"
})

L:SetOptionLocalization({
	ArachnophobiaTimer		= "为蜘蛛克星(成就)显示计时条"
})

L:SetMiscLocalization({
	ArachnophobiaTimer		= "蜘蛛克星",
	Pull1					= "对，跑吧！那样伤口出血就更多了！",
	Pull2					= "一些小点心……",
	Pull3					= "你们逃不掉的。"
})

----------------------------
--  Grand Widow Faerlina  --
----------------------------
L = DBM:GetModLocalization("Faerlina")

L:SetGeneralLocalization({
	name 				= "黑女巫法琳娜"
})

L:SetWarningLocalization({
	WarningEmbraceExpire		= "黑女巫的拥抱5秒后结束",
	WarningEmbraceExpired		= "黑女巫的拥抱结束"
})

L:SetOptionLocalization({
	WarningEmbraceExpire		= "为黑女巫的拥抱结束显示提前警报",
	WarningEmbraceExpired		= "为黑女巫的拥抱结束显示警报"
})

L:SetMiscLocalization({
	Pull					= "跪下求饶吧，懦夫！"--Not actually pull trigger, but often said on pull
})
---------------
--  Maexxna  --
---------------
L = DBM:GetModLocalization("Maexxna")

L:SetGeneralLocalization({
	name 					= "迈克斯纳"
})

L:SetWarningLocalization({
	WarningSpidersSoon		= "迈克斯纳之子 5秒后出现",
	WarningSpidersNow		= "迈克斯纳之子出现了"
})

L:SetTimerLocalization({
	TimerSpider				= "下一次 迈克斯纳之子"
})

L:SetOptionLocalization({
	WarningSpidersSoon		= "为迈克斯纳之子显示提前警报",
	WarningSpidersNow		= "为迈克斯纳之子显示警报",
	TimerSpider				= "为下一次迈克斯纳之子显示计时条"
})

L:SetMiscLocalization({
	ArachnophobiaTimer		= "蜘蛛克星"
})

------------------------------
--  Noth the Plaguebringer  --
------------------------------
L = DBM:GetModLocalization("Noth")

L:SetGeneralLocalization({
	name 					= "药剂师诺斯"
})

L:SetWarningLocalization({
	WarningTeleportNow		= "传送",
	WarningTeleportSoon		= "20秒后 传送"
})

L:SetTimerLocalization({
	TimerTeleport			= "传送",
	TimerTeleportBack		= "传送回来"
})

L:SetOptionLocalization({
	WarningTeleportNow		= "为传送显示警报",
	WarningTeleportSoon		= "为传送显示预警",
	TimerTeleport			= "为传送显示计时条",
	TimerTeleportBack		= "为传送回来显示计时条"
})

L:SetMiscLocalization({
	Pull				= "我要没收你的生命!", --TBD
	AddsYell			= "起来吧，我的战士们！起来，再为主人尽忠一次！",
	Adds				= "召唤出骷髅战士！",
	AddsTwo				= "召唤出更多的骷髅！"
})
--------------------------
--  Heigan the Unclean  --
--------------------------
L = DBM:GetModLocalization("Heigan")

L:SetGeneralLocalization({
	name 				= "肮脏的希尔盖"
})

L:SetWarningLocalization({
	WarningTeleportNow		= "传送",
	WarningTeleportSoon		= "%d秒后 传送"
})

L:SetTimerLocalization({
	TimerTeleport			= "传送"
})

L:SetOptionLocalization({
	WarningTeleportNow		= "为传送显示警报",
	WarningTeleportSoon		= "为传送显示提前警报",
	TimerTeleport			= "为传送显示计时条"
})

L:SetMiscLocalization({
	Pull				= "你是我的了。"
})

---------------
--  Loatheb  --
---------------
L = DBM:GetModLocalization("Loatheb")

L:SetGeneralLocalization({
	name 				= "洛欧塞布"
})

L:SetWarningLocalization({
	WarningHealSoon			= "3秒后可以治疗",
	WarningHealNow			= "现在治疗"
})

L:SetOptionLocalization({
	WarningHealSoon			= "为3秒后可以治疗显示提前警报",
	WarningHealNow			= "为现在治疗显示警报"
})

-----------------
--  Patchwerk  --
-----------------
L = DBM:GetModLocalization("Patchwerk")

L:SetGeneralLocalization({
	name 				= "帕奇维克"
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yell1 				= "帕奇维克要跟你玩！",
	yell2 				= "帕奇维克是克尔苏加德的战神！"
})

-----------------
--  Grobbulus  --
-----------------
L = DBM:GetModLocalization("Grobbulus")

L:SetGeneralLocalization({
	name 				= "格罗布鲁斯"
})

L:SetOptionLocalization({
	SpecialWarningInjection		= "当你中了变异注射时显示特别警报",
	SetIconOnInjectionTarget	= "设定标记给中了变异注射的玩家"
})

L:SetWarningLocalization({
	SpecialWarningInjection		= "你中了变异注射 - 快跑开"
})

L:SetTimerLocalization({
})

-------------
--  Gluth  --
-------------
L = DBM:GetModLocalization("Gluth")

L:SetGeneralLocalization({
	name 				= "格拉斯"
})

----------------
--  Thaddius  --
----------------
L = DBM:GetModLocalization("Thaddius")

L:SetGeneralLocalization({
	name 				= "塔迪乌斯"
})

L:SetMiscLocalization({
	Yell				= "斯塔拉格要碾碎你！",
	Emote				= "%s超载了！",
	Emote2				= "电磁圈超载了！",
	Boss1 				= "费尔根",
	Boss2 				= "斯塔拉格",
	Charge1 			= "负极",
	Charge2 			= "正极"
})

L:SetOptionLocalization({
	WarningChargeChanged		= "当你的极性改变时显示特别警报",
	WarningChargeNotChanged		= "当你的极性没有改变时显示特别警报",
	AirowsEnabled			= "显示箭头 $spell:28089",
	TwoCamp					= "显示箭头 (正常 \"两边\" 站位打法)",
	ArrowsRightLeft			= "显示左/右箭头 给 \"四角\" 站位打法 (如果极性改变显示左箭头, 没变显示右箭头)",
	ArrowsInverse			= "显示反转的 \"四角\" 站位打法 (如果极性改变显示右箭头, 没变显示左箭头)"
})

L:SetWarningLocalization({
	WarningChargeChanged		= "极性变为%s",
	WarningChargeNotChanged		= "极性没有改变"
})

----------------------------
--  Instructor Razuvious  --
----------------------------
L = DBM:GetModLocalization("Razuvious")

L:SetGeneralLocalization({
	name 				= "教官拉苏维奥斯"
})

L:SetMiscLocalization({
	Yell1 				= "仁慈无用！",
	Yell2 				= "练习时间到此为止！都拿出真本事来！",
	Yell3 				= "按我教导的去做！",
	Yell4 				= "绊腿……有什么问题吗？"
})

L:SetOptionLocalization({
	WarningShieldWallSoon		= "为盾墙结束显示提前警报"
})

L:SetWarningLocalization({
	WarningShieldWallSoon		= "5秒后 盾墙结束"
})

----------------------------
--  Gothik the Harvester  --
----------------------------
L = DBM:GetModLocalization("Gothik")

L:SetGeneralLocalization({
	name 				= "收割者戈提克"
})

L:SetOptionLocalization({
	TimerWave			= "为下一波小怪显示计时条",
	TimerPhase2			= "为第二阶段显示计时条",
	WarningWaveSoon			= "为小怪出现显示提前警报",
	WarningWaveSpawned		= "为小怪出现显示警报",
	WarningRiderDown		= "当冷酷的骑兵死亡时显示警报",
	WarningKnightDown		= "当冷酷的死亡骑士死亡时显示警报"
})

L:SetTimerLocalization({
	TimerWave			= "第 %d 波",
	TimerPhase2			= "第2阶段"
})

L:SetWarningLocalization({
	WarningWaveSoon			= "3秒后 第%d波: %s",
	WarningWaveSpawned		= "第%d波: %s 出现了",
	WarningRiderDown		= "骑兵已死亡",
	WarningKnightDown		= "死亡骑士已死亡",
	WarningPhase2			= "第二阶段"
})

L:SetMiscLocalization({
	yell				= "你们这些蠢货已经主动步入了陷阱。",
	WarningWave1			= "%d %s",
	WarningWave2			= "%d %s 和 %d %s",
	WarningWave3			= "%d %s, %d %s 和 %d %s",
	Trainee				= "学徒",
	Knight				= "死亡骑士",
	Rider				= "骑兵"
})

---------------------
--  Four Horsemen  --
---------------------
L = DBM:GetModLocalization("Horsemen")

L:SetGeneralLocalization({
	name 				= "四骑士"
})

L:SetOptionLocalization({
	WarningMarkSoon			= "为印记显示提前警报",
	SpecialWarningMarkOnPlayer	= "当你印记叠加多于四层时显示特别警报"
})

L:SetTimerLocalization({
})

L:SetWarningLocalization({
	WarningMarkSoon			= "3秒后 印记 %d",
	SpecialWarningMarkOnPlayer	= "%s: %s"
})

L:SetMiscLocalization({
	Korthazz			= "库尔塔兹领主",
	Rivendare			= "大领主莫格莱尼",
	Blaumeux			= "女公爵布劳缪克丝",
	Zeliek				= "瑟里耶克爵士"
})

-----------------
--  Sapphiron  --
-----------------
L = DBM:GetModLocalization("Sapphiron")

L:SetGeneralLocalization({
	name 				= "萨菲隆"
})

L:SetOptionLocalization({
	WarningAirPhaseSoon		= "为空中阶段显示提前警报",
	WarningAirPhaseNow		= "提示空中阶段",
	WarningLanded			= "提示地上阶段",
	TimerAir			= "为空中阶段显示计时条",
	TimerLanding			= "为降落显示计时条",
	TimerIceBlast			= "为冰霜吐息显示计时条",
	WarningDeepBreath		= "为冰霜吐息显示特别警报",
	WarningIceblock			= "当你中了冰箱时大喊"
})

L:SetMiscLocalization({
	EmoteBreath			= "%s深深地吸了一口气。",
	WarningYellIceblock		= "我是冰块！"
})

L:SetWarningLocalization({
	WarningAirPhaseSoon		= "10秒后 空中阶段",
	WarningAirPhaseNow		= "空中阶段",
	WarningLanded			= "萨菲隆降落了",
	WarningDeepBreath		= "冰霜吐息"
})

L:SetTimerLocalization({
	TimerAir			= "空中阶段",
	TimerLanding			= "降落",
	TimerIceBlast			= "冰霜吐息"
})

------------------
--  Kel'Thuzad  --
------------------

L = DBM:GetModLocalization("Kel'Thuzad")

L:SetGeneralLocalization({
	name 				= "克尔苏加德"
})

L:SetOptionLocalization({
	TimerPhase2			= "为第二阶段显示计时条",
	specwarnP2Soon		= "为克尔苏加德攻击前10秒显示特别警报",
	warnAddsSoon		= "为寒冰皇冠卫士显示提前警报",
	ShowRange			= "当第二阶段开始时显示距离监视框"
})

L:SetMiscLocalization({
	Yell 				= "仆从们，侍卫们，隶属于黑暗与寒冷的战士们！听从克尔苏加德的召唤！"
})

L:SetWarningLocalization({
	specwarnP2Soon			= "10秒后克尔苏加德开始攻击",
	warnAddsSoon			= "寒冰皇冠卫士即将出现"
})

L:SetTimerLocalization({
	TimerPhase2			= "第二阶段"
})
