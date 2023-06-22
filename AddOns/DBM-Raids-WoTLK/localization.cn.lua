-- author: callmejames @《凤凰之翼》 一区藏宝海湾
-- commit by: yaroot <yaroot AT gmail.com>


if GetLocale() ~= "zhCN" then return end

local L

----------------------------------
--  Archavon the Stone Watcher  --
----------------------------------
L = DBM:GetModLocalization("Archavon")

L:SetGeneralLocalization({
	name 				= "岩石看守者阿尔卡冯"
})

L:SetWarningLocalization({
	WarningGrab			= "阿尔卡冯抓起了 >%s<"
})

L:SetTimerLocalization({
	ArchavonEnrage			= "阿尔卡冯狂暴"
})

L:SetMiscLocalization({
	TankSwitch			= "%%s向(%S+)冲来！"
})

L:SetOptionLocalization({
	WarningGrab 			= "提示抓取的目标",
	ArchavonEnrage			= "为$spell:26662显示计时条"
})

--------------------------------
--  Emalon the Storm Watcher  --
--------------------------------
L = DBM:GetModLocalization("Emalon")

L:SetGeneralLocalization{
	name 				= "风暴看守者埃玛尔隆"
}

L:SetTimerLocalization{
	timerMobOvercharge		= "超载爆炸",
	EmalonEnrage			= "埃玛尔隆狂暴"
}

L:SetOptionLocalization{
	timerMobOvercharge		= "为能量超载的小怪显示爆炸倒计时(debuff叠加)",
	EmalonEnrage			= "为$spell:26662显示计时条"
}

---------------------------------
--  Koralon the Flame Watcher  --
---------------------------------
L = DBM:GetModLocalization("Koralon")

L:SetGeneralLocalization{
	name 				= "火焰看守者科拉隆"
}

L:SetTimerLocalization{
	KoralonEnrage			= "科拉隆狂暴"
}

L:SetOptionLocalization{
	KoralonEnrage			= "为$spell:26662显示计时条"
}

L:SetMiscLocalization{
	Meteor				= "%s施放流星拳！"
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
	Pull					= "跪下求饶吧，诺夫！"--Not actually pull trigger, but often said on pull
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
	name 					= "瘟疫使者诺斯"
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
	AirowEnabled			= "显示箭头 (正常 \"两边\" 站位打法)",
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
	WarningMarkNow			= "为印记显示警报",
	SpecialWarningMarkOnPlayer	= "当你印记叠加多于四层时显示特别警报"
})

L:SetTimerLocalization({
})

L:SetWarningLocalization({
	WarningMarkSoon			= "3秒后 印记 %d",
	WarningMarkNow			= "印记 #%d",
	SpecialWarningMarkOnPlayer	= "%s: %s"
})

L:SetMiscLocalization({
	Korthazz			= "库尔塔兹领主",
	Rivendare			= "瑞文戴尔男爵",
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
	WarningIceblock			= "当你中了冰箱时大喊"
})

L:SetMiscLocalization({
	EmoteBreath			= "%s深深地吸了一口气。",
	WarningYellIceblock		= "我是冰块！"
})

L:SetWarningLocalization({
	WarningAirPhaseSoon		= "10秒后 空中阶段",
	WarningAirPhaseNow		= "空中阶段",
	WarningLanded			= "萨菲隆降落了"
})

L:SetTimerLocalization({
	TimerAir			= "空中阶段",
	TimerLanding			= "降落"
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

----------------------------
--  The Obsidian Sanctum  --
----------------------------
--  Shadron  --
---------------
L = DBM:GetModLocalization("Shadron")

L:SetGeneralLocalization({
	name = "沙德隆"
})

----------------
--  Tenebron  --
----------------
L = DBM:GetModLocalization("Tenebron")

L:SetGeneralLocalization({
	name = "塔尼布隆"
})

----------------
--  Vesperon  --
----------------
L = DBM:GetModLocalization("Vesperon")

L:SetGeneralLocalization({
	name = "维斯匹隆"
})

------------------
--  Sartharion  --
------------------
L = DBM:GetModLocalization("Sartharion")

L:SetGeneralLocalization({
	name = "萨塔里奥"
})

L:SetWarningLocalization({
	WarningTenebron	        = "塔尼布隆到来",
	WarningShadron	        = "沙德隆到来",
	WarningVesperon	        = "维斯匹隆到来",
	WarningFireWall	        = "烈焰之啸",
	WarningVesperonPortal	= "维斯匹隆的传送门",
	WarningTenebronPortal	= "塔尼布隆的传送门",
	WarningShadronPortal    = "沙德隆的传送门"
})

L:SetTimerLocalization({
	TimerTenebron	= "塔尼布隆到来",
	TimerShadron	= "沙德隆到来",
	TimerVesperon	= "维斯匹隆到来"
})

L:SetOptionLocalization({
	AnnounceFails           = "公布踩中暗影裂隙和撞上烈焰之啸的玩家到团队频道 (需要团长或助理权限)",
	TimerTenebron           = "为塔尼布隆到来显示计时条",
	TimerShadron            = "为沙德隆到来显示计时条",
	TimerVesperon           = "为维斯匹隆到来显示计时条",
	WarningFireWall         = "为烈焰之啸显示特别警报",
	WarningTenebron         = "提示塔尼布隆到来",
	WarningShadron          = "提示沙德隆到来",
	WarningVesperon         = "提示维斯匹隆到来",
	WarningTenebronPortal	= "为塔尼布隆的传送门显示特别警报",
	WarningShadronPortal	= "为沙德隆的传送门显示特别警报",
	WarningVesperonPortal	= "为维斯匹隆的传送门显示特别警报"
})

L:SetMiscLocalization({
	Wall			= "%s周围的岩浆沸腾了起来！",
	Portal			= "%s开始开启暮光传送门!",
	NameTenebron	= "塔尼布隆",
	NameShadron		= "沙德隆",
	NameVesperon	= "维斯匹隆",
	FireWallOn		= "烈焰之啸: %s",
	VoidZoneOn		= "暗影裂隙: %s",
	VoidZones		= "踩中暗影裂隙 (这一次): %s",
	FireWalls		= "撞上烈焰之啸 (这一次): %s"
})

---------------
--  Malygos  --
---------------
L = DBM:GetModLocalization("Malygos")

L:SetGeneralLocalization({
	name 			= "玛里苟斯"
})

L:SetMiscLocalization({
	YellPull		= "我的耐心到此为止了。我要亲自消灭你们！",
	EmoteSpark		= "附近的裂隙中冒出了一团能量火花！",
	YellPhase2		= "我原本只是想尽快结束你们的生命",
	YellBreath		= "在我的龙息之下，一切都将荡然无存！",
	YellPhase3		= "现在你们幕后的主使终于出现了"
})

-----------------------
--  Flame Leviathan  --
-----------------------
L = DBM:GetModLocalization("FlameLeviathan")

L:SetGeneralLocalization{
	name 				= "烈焰巨兽"
}

L:SetTimerLocalization{
}

L:SetMiscLocalization{
	YellPull			= "检测到敌对实体。威胁评定协议启动。向主要目标发动攻击。30秒后重新评估。",
	Emote				= "%%s开始追赶(%S+)%。"
}

L:SetWarningLocalization{
	PursueWarn			= "追踪 -> >%s<",
	warnNextPursueSoon		= "5秒后 更换目标",
	SpecialPursueWarnYou		= "你被追踪 - 快跑",
	warnWardofLife			= "生命结界 出现"
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音",
	SpecialPursueWarnYou		= "当你被追踪时显示特别警报",
	PursueWarn			= "提示追踪的目标",
	warnNextPursueSoon		= "为下一次追踪显示提前警报",
	warnWardofLife			= "为生命结界出现显示特别警报"
}

--------------------------------
--  Ignis the Furnace Master  --
--------------------------------
L = DBM:GetModLocalization("Ignis")

L:SetGeneralLocalization{
	name 				= "掌炉者伊格尼斯"
}

L:SetTimerLocalization{
}

L:SetWarningLocalization{
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音"
}

------------------
--  Razorscale  --
------------------
L = DBM:GetModLocalization("Razorscale")

L:SetGeneralLocalization{
	name 				= "锋鳞"
}

L:SetWarningLocalization{
	warnTurretsReadySoon		= "20秒后 最后一座炮塔完成",
	warnTurretsReady		= "最后一座炮塔已完成",
	SpecWarnDevouringFlameCast	= "你中了噬体烈焰",
	WarnDevouringFlameCast		= "噬体烈焰 -> >%s<"
}

L:SetTimerLocalization{
	timerTurret1			= "炮塔1",
	timerTurret2			= "炮塔2",
	timerTurret3			= "炮塔3",
	timerTurret4			= "炮塔4",
	timerGrounded			= "地面阶段"
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音",
	warnTurretsReadySoon		= "为炮塔显示提前警报",
	warnTurretsReady		= "为炮塔显示警报",
	SpecWarnDevouringFlameCast	= "当你中了$spell:64733时显示特别警报",
	timerTurret1			= "为炮塔1显示计时条",
	timerTurret2			= "为炮塔2显示计时条",
	timerTurret3			= "为炮塔3显示计时条 (25人)",
	timerTurret4			= "为炮塔4显示计时条 (25人)",
	OptionDevouringFlame		= "提示$spell:64733的目标 (不准确)",
	timerGrounded			= "为地面阶段显示计时条"
}

L:SetMiscLocalization{
	YellAir				= "给我们一点时间，做好建筑炮台的准备。",
	YellAir2			= "火灭了！准备重建炮台！",
	YellGround			= "快一点！她马上就要挣脱了！",
	EmotePhase2			= "%%s被永久地禁锢在地面上！",
	FlamecastUnknown		= DBM_COMMON_L.UNKNOWN
}

----------------------------
--  XT-002 Deconstructor  --
----------------------------
L = DBM:GetModLocalization("XT002")

L:SetGeneralLocalization{
	name = "XT-002拆解者"
}

L:SetTimerLocalization{
}

L:SetWarningLocalization{
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音"
}

--------------------
--  Iron Council  --
--------------------
L = DBM:GetModLocalization("IronCouncil")

L:SetGeneralLocalization{
	name = "钢铁议会"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音",
	AlwaysWarnOnOverload		= "总是对$spell:63481显示警报(否则只有当目标是唤雷者的时候显示)"
}

L:SetMiscLocalization{
	Steelbreaker			= "断钢者",
	RunemasterMolgeim		= "符文大师莫尔基姆",
	StormcallerBrundir 		= "唤雷者布隆迪尔"
}

----------------------------
--  Algalon the Observer  --
----------------------------
L = DBM:GetModLocalization("Algalon")

L:SetGeneralLocalization{
	name 				= "观察者奥尔加隆"
}

L:SetTimerLocalization{
	NextCollapsingStar		= "下一次 坍缩星",
	TimerCombatStart		= "战斗开始"
}

L:SetWarningLocalization{
	WarningPhasePunch		= "相位冲压 -> >%s< - 第%d层",
	WarnPhase2Soon			= "第2阶段 即将到来",
	warnStarLow			= "坍缩星血量低"
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音",
	WarningPhasePunch		= "提示相位冲压的目标",
	NextCollapsingStar		= "为下一次坍缩星显示计时条",
	TimerCombatStart		= "为战斗开始显示计时条",
	WarnPhase2Soon			= "为第2阶段显示提前警报 (大约23%)",
	warnStarLow			= "当坍缩星血量低(大约25%)时显示特别警报"
}

L:SetMiscLocalization{
	YellPull			= "你们的行动不合逻辑。这场战斗所有可能产生的结果都已被计算在内。无论结果如何，万神殿都会收到观察者发出的信息。",
	YellKill			= "我曾经看过尘世沉浸在造物者的烈焰之中，众生连一声悲泣都无法呼出，就此凋零。整个星系在弹指之间历经了毁灭与重生。然而在这段历程之中，我的心却无法感受到丝毫的…恻隐之念。我‧感‧受‧不‧到。成千上万的生命就这么消逝。他们是否拥有与你同样坚韧的生命?他们是否与你同样热爱生命?",
	Emote_CollapsingStar		= "%s开始召唤坍缩星！",
	Phase2				= "看吧，这创世的神器！",
	PullCheck			= "奥尔加隆发送危险信号的倒计时 = (%d+)分钟。"
}

----------------
--  Kologarn  --
----------------
L = DBM:GetModLocalization("Kologarn")

L:SetGeneralLocalization{
	name 				= "科隆加恩"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
	timerLeftArm			= "左臂重生",
	timerRightArm			= "右臂重生",
	achievementDisarmed		= "成就计时：断其臂膀"
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音",
	timerLeftArm			= "为左臂重生显示计时条",
	timerRightArm			= "为右臂重生显示计时条",
	achievementDisarmed		= "为成就：断其臂膀显示计时条",
	YellOnBeam			= "当你中了$spell:63346时大喊"
}

L:SetMiscLocalization{
	Yell_Trigger_arm_left		= "不疼不痒！",
	Yell_Trigger_arm_right		= "只是轻伤而已！",
	Health_Body			= "科隆加恩身体",
	Health_Right_Arm		= "右臂",
	Health_Left_Arm			= "左臂",
	FocusedEyebeam			= "在注视着你",
	YellBeam			= "科隆加恩正在注视我！"
}

---------------
--  Auriaya  --
---------------
L = DBM:GetModLocalization("Auriaya")

L:SetGeneralLocalization{
	name 				= "欧尔莉亚"
}

L:SetMiscLocalization{
	Defender 			= "野性防御者(%d)",
	YellPull 			= "有些东西，最好永远都不去碰！"
}

L:SetTimerLocalization{
	timerDefender			= "野性防御者复活"
}

L:SetWarningLocalization{
	WarnCatDied 			= "野性防御者倒下(剩余%d只)",
	WarnCatDiedOne 			= "野性防御者倒下(剩下最后一只)"
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音",
	WarnCatDied			= "当野性防御者死亡时显示警报",
	WarnCatDiedOne			= "当野性防御者剩下最后一只时显示警报",
	timerDefender       		= "当野性防御者准备复活时显示计时条"
}

-------------
--  Hodir  --
-------------
L = DBM:GetModLocalization("Hodir")

L:SetGeneralLocalization{
	name 				= "霍迪尔"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音",
	YellOnStormCloud		= "当你中了$spell:65133时大喊"
}

L:SetMiscLocalization{
	YellKill			= "我……我终于从他的魔掌中……解脱了。",
	YellCloud			= "我中了风暴雷云 快接近我！"
}

--------------
--  Thorim  --
--------------
L = DBM:GetModLocalization("Thorim")

L:SetGeneralLocalization{
	name 				= "托里姆"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
	TimerHardmode			= "困难模式"
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音",
	TimerHardmode			= "为困难模式显示计时条",
	AnnounceFails			= "公布中了闪电充能的玩家到团队频道<br/>(需要团长或助理权限)"
}

L:SetMiscLocalization{
	YellPhase1			= "入侵者！你们这些凡人竟敢坏了我的兴致，看我怎么……等等，你们……",
	YellPhase2			= "狂妄的小崽子们，竟敢在我的地盘上挑战我？我要亲自碾碎你们！",
	YellKill			= "住手！我认输了！",
	ChargeOn			= "闪电充能 -> %s",
	Charge				= "中了闪电充能(这一次): %s"
}

-------------
--  Freya  --
-------------
L = DBM:GetModLocalization("Freya")

L:SetGeneralLocalization{
	name 				= "弗蕾亚"
}

L:SetMiscLocalization{
	SpawnYell			= "孩子们，帮帮我！",
	WaterSpirit			= "古代水之精魂",
	Snaplasher			= "迅疾鞭笞者",
	StormLasher			= "风暴鞭笞者",
	TreeYell      = "|cFF00FFFF生命缚誓者的礼物|r开始生长！",
	YellKill			= "他对我的控制已经不复存在了。我又一次恢复了理智。谢谢你们，英雄们。",
	TrashRespawnTimer		= "弗蕾亚的小怪重生"
}

L:SetWarningLocalization{
	WarningTree   		= "艾欧娜尔的礼物出现 - 立刻攻击",
	WarnSimulKill			= "第一只元素死亡 - 约12秒后复活"
}

L:SetTimerLocalization{
	TimerSimulKill			= "复活"
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音",
	WarningTree   		= "当首领召唤艾欧娜尔的礼物时显示特别警告",
	WarnSimulKill			= "提示第一只元素死亡",
	TimerSimulKill			= "为三元素复活显示计时条"
}

----------------------
--  Freya's Elders  --
----------------------
L = DBM:GetModLocalization("Freya_Elders")

L:SetGeneralLocalization{
	name 				= "弗蕾亚的长者"
}

L:SetMiscLocalization{
	TrashRespawnTimer		= "弗蕾亚的小怪重生"
}

L:SetWarningLocalization{
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音",
	TrashRespawnTimer		= "为弗蕾亚的小怪重生显示计时条"
}

---------------
--  Mimiron  --
---------------
L = DBM:GetModLocalization("Mimiron")

L:SetGeneralLocalization{
	name 				= "米米尔隆"
}

L:SetWarningLocalization{
	MagneticCore			= ">%s< 拿到了磁核",
	WarningShockBlast		= "震荡冲击 - 立刻跑开",
	WarnBombSpawn			= "炸弹机器人出现了"
}

L:SetTimerLocalization{
	TimerHardmode			= "困难模式 - 自毁程序",
	TimeToPhase2			= "第2阶段开始",
	TimeToPhase3			= "第3阶段开始",
	TimeToPhase4			= "第4阶段开始"
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音",
	TimeToPhase2			= "为第2阶段开始显示计时条",
	TimeToPhase3			= "为第3阶段开始显示计时条",
	TimeToPhase4			= "为第4阶段开始显示计时条",
	MagneticCore			= "提示磁核的拾取者",
	WarnBombSpawn			= "为炸弹机器人显示警报",
	TimerHardmode			= "为困难模式显示计时条",
	ShockBlastWarningInP1		= "为第1阶段的$spell:63631显示特别警报",
	ShockBlastWarningInP4		= "为第4阶段的$spell:63631显示特别警报"
}

L:SetMiscLocalization{
	MobPhase1			= "巨兽二型",
	MobPhase2			= "VX-001",
	MobPhase3			= "空中指挥单位",
	YellPull			= "我们时间不多了，朋友们！来帮忙测试一下我所发明的最新型、最强大的机体吧。在你们改变主意之前，请允许我提醒一下，你们把XT-002搞得一团糟，应该算是欠我个人情吧。",
	YellHardPull		= "嘿，你们为什么要这么做啊？没看到上面写着“不要按这个按钮”吗？你们激活了自毁系统，还怎么完成测试呀？",
	YellPhase2			= "太棒了！测试结果非常好！外壳完整率百分之九十八点九！几乎没有划伤！继续。",
	YellPhase3			= "非常感谢，朋友们！你们的帮助使我获得了一些极其珍贵的数据！下面，我要让你们——咦，我把它放哪去了？哦！这里。",
	YellPhase4			= "初步测试阶段完成。真正的测试开始啦！"
}

---------------------
--  General Vezax  --
---------------------
L = DBM:GetModLocalization("GeneralVezax")

L:SetGeneralLocalization{
	name 				= "维扎克斯将军"
}

L:SetTimerLocalization{
	hardmodeSpawn 			= "萨隆邪铁畸体 出现"
}

L:SetWarningLocalization{
	SpecialWarningShadowCrash	= "你中了暗影冲撞 - 立刻跑开",
	SpecialWarningShadowCrashNear	= "你附近有人中暗影冲撞 - 立刻远离",
	SpecialWarningLLNear		= "你附近的%s中了无面者的印记"
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音",
	SpecialWarningShadowCrash	= "为$spell:62660显示特别警报(必须至少有一名团队成员设置首领为焦点目标)",
	SpecialWarningShadowCrashNear	= "当你附近的人中了$spell:62660时显示特别警报",
	SpecialWarningLLNear		= "当你附近的人中了$spell:63276时显示特别警报",
	YellOnLifeLeech			= "当你中了$spell:63276时大喊",
	YellOnShadowCrash		= "当你中了$spell:62660时大喊",
	hardmodeSpawn			= "为萨隆邪铁畸体出现显示计时条 (困难模式)",
	CrashArrow			= "当你附近的人中了$spell:62660时显示DBM箭头",
	BypassLatencyCheck		= "不对$spell:62660使用同步延迟查询<br/>(只有出现问题时才使用这个)"
}

L:SetMiscLocalization{
	EmoteSaroniteVapors		= "一团萨隆邪铁蒸汽在附近聚集起来！",
	YellLeech			= "我中了无面者的印记 - 远离我",
	YellCrash			= "我中了暗影冲撞 - 远离我"
}

------------------
--  Yogg-Saron  --
------------------
L = DBM:GetModLocalization("YoggSaron")

L:SetGeneralLocalization{
	name 				= "尤格萨隆"
}

L:SetMiscLocalization{
	YellPull 			= "攻击这头野兽要害的时刻即将来临！将你们的愤怒和仇恨倾泻到它的爪牙身上！",
	YellPhase2			= "我是清醒的梦境。",
	Sara 				= "萨拉"
}

L:SetWarningLocalization{
	WarningGuardianSpawned 		= "尤格萨隆的卫士 %d 出现了",
	WarningCrusherTentacleSpawned	= "重压触须 出现了",
	WarningSanity 			= "剩余理智：%d",
	SpecWarnSanity 			= "剩余理智：%d",
	SpecWarnGuardianLow		= "停止攻击这只守护者",
	SpecWarnMadnessOutNow		= "疯狂诱导即将结束 - 立刻传送出去",
	WarnBrainPortalSoon		= "3秒后 脑部传送门",
	SpecWarnFervor			= "你中了萨拉的热情",
	SpecWarnFervorCast		= "萨拉的热情正在对你施放",
	specWarnBrainPortalSoon		= "脑部传送门 即将出现"
}

L:SetTimerLocalization{
	NextPortal			= "下一次 脑部传送门"
}

L:SetOptionLocalization{
	SoundWOP = "为重要技能播放额外的警报语音",
	WarningGuardianSpawned		= "为尤格萨隆的卫士出现显示警报",
	WarningCrusherTentacleSpawned	= "为重压触须出现显示警报",
	WarningSanity			= "当理智剩下50时显示警报",
	SpecWarnSanity			= "当理智过低(25,15,5)时显示特别警报",
	SpecWarnGuardianLow		= "当尤格萨隆的卫士(第1阶段)血量过低时显示特别警报 (输出职业用)",
	WarnBrainPortalSoon		= "为脑部传送门显示提前警报",
	SpecWarnMadnessOutNow		= "为疯狂诱导结束前显示特别警报",
	SpecWarnFervorCast		= "当萨拉的热情正在对你施放时显示特别警报 (必须至少有一名团队成员设置首领为焦点目标)",
	specWarnBrainPortalSoon		= "为下一次脑部传送门显示特别警报",
	NextPortal			= "为下一次传送门显示计时条",
	MaladyArrow			= "当你附近的人中了$spell:63881时显示DBM箭头"
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
	YellPull 		= "真是走运。通常我必须离开窝才能找到食物。",
	YellP2 			= "这毫无意义的行动让我很厌烦。我会从上空把你们都烧成灰！",
	YellP3 			= "看起来需要再给你一次教训，凡人！"
}

------------------------
--  Northrend Beasts  --
------------------------
L = DBM:GetModLocalization("NorthrendBeasts")

L:SetGeneralLocalization{
	name = "诺森德猛兽"
}

L:SetMiscLocalization{
	Charge				= "%%s等着(%S+)，发出一阵震耳欲聋的怒吼！",
	CombatStart			= "他来自风暴峭壁最幽深，最黑暗的洞穴，穿刺者戈莫克！准备战斗，英雄们！",
	Phase2				= "做好准备，英雄们，两头猛兽已经进入了竞技场！它们是酸喉和恐鳞！",
	Phase3				= "当下一名斗士出场时，空气都会为之冻结！它是冰吼，胜或是死，勇士们！",
	Gormok				= "穿刺者戈莫克",
	Acidmaw				= "酸喉",
	Dreadscale			= "恐鳞",
	Icehowl				= "冰吼"
}

L:SetOptionLocalization{
	WarningSnobold			= "为狗头人奴隶出现显示警报",
	ClearIconsOnIceHowl		= "冲锋前清除所有标记",
	TimerNextBoss			= "显示下一场战斗倒计时",
	TimerEmerge			= "显示钻地计时",
	TimerSubmerge			= "显示钻地结束计时",
	IcehowlArrow			= "当冰吼即将向你附近冲锋时显示DBM箭头"
}

L:SetTimerLocalization{
	TimerNextBoss			= "下一场战斗",
	TimerEmerge			= "钻地结束",
	TimerSubmerge			= "钻地"
}

L:SetWarningLocalization{
	WarningSnobold			= "狗头人奴隶 出现了"
}

---------------------
--  Lord Jaraxxus  --
---------------------
L = DBM:GetModLocalization("Jaraxxus")

L:SetGeneralLocalization{
	name = "加拉克苏斯大王"
}

L:SetOptionLocalization{
	IncinerateShieldFrame		= "在首领血量里显示血肉成灰目标的血量"
}

L:SetMiscLocalization{
	IncinerateTarget		= "血肉成灰 -> %s",
	FirstPull			= "大术士威尔弗雷德·菲斯巴恩将会召唤你们的下一个挑战者。等待他的登场吧。"
}

-------------------------
--  Faction Champions  --
-------------------------
L = DBM:GetModLocalization("Champions")

L:SetGeneralLocalization{
	name = "阵营冠军"
}

L:SetMiscLocalization{
	AllianceVictory			= "荣耀归于联盟！",
	HordeVictory			= "那只是让你们知道将来必须面对的命运。为了部落！",
	YellKill			= "肤浅而悲痛的胜利。今天痛失的生命反而令我们更加的颓弱。除了巫妖王之外，谁还能从中获利?伟大的战士失去了宝贵生命。为了什么?真正的威胁就在前方 - 巫妖王在死亡的领域中等着我们。"
}

---------------------
--  Val'kyr Twins  --
---------------------
L = DBM:GetModLocalization("ValkTwins")

L:SetGeneralLocalization{
	name = "瓦格里双子"
}

L:SetTimerLocalization{
	TimerSpecialSpell		= "下一次 特殊技能"
}

L:SetWarningLocalization{
	WarnSpecialSpellSoon		= "特殊技能 即将到来",
	SpecWarnSpecial			= "立刻变换颜色",
	SpecWarnSwitchTarget		= "立刻切换目标攻击双生相协",
	SpecWarnKickNow			= "立刻打断",
	WarningTouchDebuff		= "光明或黑暗之触 -> >%s<",
	WarningPoweroftheTwins2		= "双生之能 - 加大治疗 -> >%s<",
	SpecWarnPoweroftheTwins		= "双生之能"
}

L:SetMiscLocalization{
	Fjola 				= "光明邪使菲奥拉",
	Eydis				= "黑暗邪使艾蒂丝"
}

L:SetOptionLocalization{
	TimerSpecialSpell		= "为下一次特殊技能显示计时器",
	WarnSpecialSpellSoon		= "为下一次特殊技能显示提前警报",
	SpecWarnSpecial			= "当你需要变换颜色时显示特殊警报",
	SpecWarnSwitchTarget		= "当另一个首领施放双子相协时显示特殊警报",
	SpecWarnKickNow			= "当你可以打断时显示特殊警报",
	SpecialWarnOnDebuff		= "当你中了光明或黑暗之触时显示特殊警报(需切换颜色)",
	SetIconOnDebuffTarget		= "为光明或黑暗之触的目标设置标记(英雄模式)",
	WarningTouchDebuff		= "提示光明或黑暗之触的目标",
	WarningPoweroftheTwins2		= "提示双生之能的目标",
	SpecWarnPoweroftheTwins		= "当你坦克的首领拥有双生之能时显示特殊警报"
}

-----------------
--  Anub'arak  --
-----------------
L = DBM:GetModLocalization("Anub'arak_Coliseum")

L:SetGeneralLocalization{
	name 				= "阿努巴拉克"
}

L:SetTimerLocalization{
	TimerEmerge			= "钻地结束",
	TimerSubmerge			= "钻地",
	timerAdds			= "下一次 掘地者出现"
}

L:SetWarningLocalization{
	WarnEmerge			= "阿努巴拉克钻出地面了",
	WarnEmergeSoon			= "10秒后 钻出地面",
	WarnSubmerge			= "阿努巴拉克钻进地里了",
	WarnSubmergeSoon		= "10秒后 钻进地里",
	specWarnSubmergeSoon		= "10秒后 钻进地里!",
	warnAdds			= "掘地者 出现了"
}

L:SetMiscLocalization{
	Emerge				= "钻入了地下！",
	Burrow				= "从地面上升起来了！",
	PcoldIconSet			= "刺骨之寒{rt%d} -> %s",
	PcoldIconRemoved		= "移除标记 -> %s"
}

L:SetOptionLocalization{
	WarnEmerge			= "为钻出地面显示警报",
	WarnEmergeSoon			= "为钻出地面显示提前警报",
	WarnSubmerge			= "为钻进地里显示警报",
	WarnSubmergeSoon		= "为钻进地里显示提前警报",
	specWarnSubmergeSoon		= "为即将钻进地里显示特殊警报",
	warnAdds			= "提示掘地者出现",
	timerAdds			= "为下一次掘地者出现显示计时器",
	TimerEmerge			= "为首领钻地显示计时器",
	TimerSubmerge			= "为下一次钻地显示计时器",
	AnnouncePColdIcons		= "公布$spell:68510目标设置的标记到团队频道<br/>(需要团长或助理权限)",
	AnnouncePColdIconsRemoved	= "当移除$spell:68510的标记时也提示<br/>(需要上述选项)"
}

----------------------
--  Lord Marrowgar  --
----------------------
L = DBM:GetModLocalization("LordMarrowgar")

L:SetGeneralLocalization{
	name = "玛洛加尔领主"
}

-------------------------
--  Lady Deathwhisper  --
-------------------------
L = DBM:GetModLocalization("Deathwhisper")

L:SetGeneralLocalization{
	name = "亡语者女士"
}

L:SetTimerLocalization{
	TimerAdds	= "新的小怪"
}

L:SetWarningLocalization{
	WarnReanimating	= "小怪再活化",
	WarnAddsSoon	= "新的小怪即将到来"
}

L:SetOptionLocalization{
	WarnAddsSoon		= "为新的小怪出现显示预先警告",
	WarnReanimating		= "当小怪再活化时显示警告",
	TimerAdds			= "为新的小怪显示计时器"
}

L:SetMiscLocalization{
	YellReanimatedFanatic	= "起来，在纯粹的形态中感受狂喜!",
	Fanatic1				= "神教狂热者",
	Fanatic2				= "畸形的狂热者",
	Fanatic3				= "再活化的狂热者"
}

----------------------
--  Gunship Battle  --
----------------------
L = DBM:GetModLocalization("GunshipBattle")

L:SetGeneralLocalization{
	name = "炮艇战"
}

L:SetWarningLocalization{
	WarnAddsSoon	= "新的小怪即将到来"
}

L:SetOptionLocalization{
	WarnAddsSoon		= "为新的小怪出现显示预先警告",
	TimerAdds			= "为新的小怪显示计时器"
}

L:SetTimerLocalization{
	TimerAdds			= "新的小怪"
}

L:SetMiscLocalization{
	PullAlliance	= "发动引擎!小伙子们，我们即将面对命运啦!",
	KillAlliance	= "別说我没警告过你，无赖!兄弟姐妹们，向前冲!",
	PullHorde		= "起来吧，部落的儿女!今天我们要和最可恨的敌人作战!为了部落!",
	KillHorde		= "联盟已经动摇了。向巫妖王前进!",
	AddsAlliance	= "掠夺者，士官们，攻击!",
	AddsHorde		= "海員们，士官们，攻击!",
	MageAlliance	= "船体受到伤害，找个战斗法师到来，搞定那些火炮!",
	MageHorde		= "船体受损，找个巫士到这里来，搞定那些火炮!"
}

-----------------------------
--  Deathbringer Saurfang  --
-----------------------------
L = DBM:GetModLocalization("Deathbringer")

L:SetGeneralLocalization{
	name = "死亡使者萨鲁法尔"
}

L:SetOptionLocalization{
	RangeFrame				= "显示距离框 (12码)",
	RunePowerFrame			= "显示首领血量及$spell:72371条"
}

L:SetMiscLocalization{
	RunePower			= "血魄威能",
	PullAlliance		= "每个你杀死的部落士兵 -- 每条死去的联盟狗，都让巫妖王的军队随之增长。此时此刻瓦基里安都还在把你们倒下的同伴复活成天谴军。",
	PullHorde			= "柯尔克隆，前进!勇士们，要当心，天谴军团已经..."
}

-----------------
--  Festergut  --
-----------------
L = DBM:GetModLocalization("Festergut")

L:SetGeneralLocalization{
	name = "烂肠"
}

L:SetOptionLocalization{
	RangeFrame			= "显示距离框 (8码)",
	AnnounceSporeIcons	= "公布$spell:69279目标设置的标记到团队频道<br/>(需要团队队长)",
	AchievementCheck	= "公布 '流感疫苗短缺' 成就失败到团队频道<br/>(需助理权限)"
}

L:SetMiscLocalization{
	SporeSet			= "气体孢子{rt%d}: %s",
	AchievementFailed	= ">> 成就失败: %s中了%d层孢子 <<"
}

---------------
--  Rotface  --
---------------
L = DBM:GetModLocalization("Rotface")

L:SetGeneralLocalization{
	name = "腐面"
}

L:SetWarningLocalization{
	WarnOozeSpawn		= "小软泥怪出现了",
	SpecWarnLittleOoze	= "你被小软泥怪盯上了 - 快跑开"
}


L:SetOptionLocalization{
	WarnOozeSpawn		= "为小软泥的出现显示警告",
	SpecWarnLittleOoze	= "当你被小软泥怪盯上时显示特別警告",
	RangeFrame			= "显示距离框(8码)"
}

L:SetMiscLocalization{
	YellSlimePipes1	= "大伙听着，好消息!我修好了剧毒软泥管!",
	YellSlimePipes2	= "大伙听着，超級好消息!软泥又开始流动了!"
}

---------------------------
--  Professor Putricide  --
---------------------------
L = DBM:GetModLocalization("Putricide")

L:SetGeneralLocalization{
	name 				= "普崔塞德教授"
}

L:SetOptionLocalization{
	MalleableGooIcon	= "为第一个中$spell:72295的目标设置标记"
}

----------------------------
--  Blood Prince Council  --
----------------------------
L = DBM:GetModLocalization("BPCouncil")

L:SetGeneralLocalization{
	name = "血王子议会"
}

L:SetWarningLocalization{
	WarnTargetSwitch		= "转换目标到: %s",
	WarnTargetSwitchSoon	= "转换目标即将到来"
}

L:SetTimerLocalization{
	TimerTargetSwitch		= "转换目标"
}

L:SetOptionLocalization{
	WarnTargetSwitch		= "为转换目标显示警告",
	WarnTargetSwitchSoon	= "为转换目标显示预先警告",
	TimerTargetSwitch		= "为转换目标显示冷却计时器",
	ActivePrinceIcon		= "设置标记在強化的亲王身上(头颅)",
	RangeFrame				= "显示距离框(12码)"
}

L:SetMiscLocalization{
	Keleseth			= "凯雷塞斯王子",
	Taldaram			= "塔达拉姆王子",
	Valanar				= "瓦拉纳王子",
	EmpoweredFlames		= "地狱烈焰加速靠近(%S+)!"
}

-----------------------------
--  Blood-Queen Lana'thel  --
-----------------------------
L = DBM:GetModLocalization("Lanathel")

L:SetGeneralLocalization{
	name = "鲜血女王兰娜瑟尔"
}

L:SetOptionLocalization{
	RangeFrame			= "显示距离框(8码)"
}

L:SetMiscLocalization{
	SwarmingShadows		= "暗影聚集並欢绕在(%S+)四周!",
	YellFrenzy			= "我饿了!"
}

-----------------------------
--  Valithria Dreamwalker  --
-----------------------------
L = DBM:GetModLocalization("Valithria")

L:SetGeneralLocalization{
	name = "踏梦者瓦莉瑟瑞娅"
}

L:SetWarningLocalization{
	WarnPortalOpen			= "传送门开启"
}

L:SetTimerLocalization{
	TimerPortalsOpen		= "传送门开启",
	TimerBlazingSkeleton	= "下一次炽热骷髅",
	TimerAbom				= "下一次憎恶体"
}

L:SetOptionLocalization{
	SetIconOnBlazingSkeleton	= "为炽热骷髅设置标记(头颅)",
	WarnPortalOpen				= "当梦魇之门开启时显示警告",
	TimerPortalsOpen			= "当梦魇之门开启时显示计时器",
	TimerBlazingSkeleton		= "为下一次炽热骷髅出现显示计时器",
	TimerAbom					= "为下一次贪吃的憎恶体出现显示计时器"
}

L:SetMiscLocalization{
	YellPull			= "入侵者已经突破了內部圣所。加快摧毀綠龍的速度!只要留下骨头和肌腱来复活!",
	YellKill			= "我重生了!伊瑟拉賦予我让那些邪恶生物安眠的力量!",
	YellPortals			= "我打开了一道传送门通往梦境。你们的救赎就在其中，英雄们..."
}

------------------
--  Sindragosa  --
------------------
L = DBM:GetModLocalization("Sindragosa")

L:SetGeneralLocalization{
	name = "辛达苟萨"
}

L:SetWarningLocalization{
	WarnAirphase			= "空中阶段",
	WarnGroundphaseSoon		= "辛达苟萨 即将着陆"
}

L:SetTimerLocalization{
	TimerNextAirphase		= "下一次空中阶段",
	TimerNextGroundphase	= "下一次地上阶段",
	AchievementMystic		= "清除秘能连击叠加"
}

L:SetOptionLocalization{
	WarnAirphase			= "提示空中阶段",
	WarnGroundphaseSoon		= "为地上阶段显示预先警告",
	TimerNextAirphase		= "为下一次 空中阶段显示计时器",
	TimerNextGroundphase	= "为下一次 地上阶段显示计时器",
	AnnounceFrostBeaconIcons= "公布$spell:70126目标设置的标记到团队频道<br/>(需要团队队长)",
	ClearIconsOnAirphase	= "空中阶段前清除所有标记",
	AchievementCheck		= "公布 '吃到饱' 成就警告到团队频道<br/>(需助理权限)",
	RangeFrame				= "根据最后首领使用的技能跟玩家减益显示动态距离框(10/20码)"
}

L:SetMiscLocalization{
	YellAirphase		= "你们的入侵将在此终止!谁也別想存活!",
	YellPhase2			= "现在，绝望地感受我主无限的力量吧!",
	YellAirphaseDem		= "Rikk zilthuras rikk zila Aman adare tiriosh ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	YellPhase2Dem		= "Zar kiel xi romathIs zilthuras revos ruk toralar ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	BeaconIconSet		= "冰霜信标{rt%d}: %s",
	AchievementWarning	= "警告: %s中了5层秘能连击",
	AchievementFailed	= ">> 成就失败: %s中了%d层秘能连击 <<"
}

---------------------
--  The Lich King  --
---------------------
L = DBM:GetModLocalization("LichKing")

L:SetGeneralLocalization{
	name 				= "巫妖王"
}

L:SetWarningLocalization{
	ValkyrWarning			= ">%s< 被抓住了!",
	SpecWarnYouAreValkd		= "你被抓住了",
	WarnNecroticPlagueJump	= "亡域瘟疫跳到>%s<身上",
	SpecWarnValkyrLow		= "瓦基里安血量低于55%"
}

L:SetTimerLocalization{
	TimerRoleplay		= "角色扮演",
	PhaseTransition		= "转换阶段",
	TimerNecroticPlagueCleanse 	= "净化亡域瘟疫"
}

L:SetOptionLocalization{
	TimerRoleplay			= "为角色扮演事件显示计时器",
	WarnNecroticPlagueJump	= "提示$spell:73912跳跃后的目标",
	TimerNecroticPlagueCleanse	= "为净化第一次堆叠前的亡域瘟疫显示计时器",
	PhaseTransition			= "为转换阶段显示计时器",
	ValkyrWarning			= "提示谁给瓦基里安影卫抓住了",
	SpecWarnYouAreValkd		= "当你给瓦基里安影卫抓住时显示特別警告",
	AnnounceValkGrabs		= "提示谁被瓦基里安影卫抓住到团队频道<br/>(需开启团队广播及助理权限)",
	SpecWarnValkyrLow		= "当瓦基里安血量低于55%时显示特別警告",
	AnnouncePlagueStack		= "提示$spell:73912层数到团队频道 (10层, 10层后每5层提示一次)<br/>(需开启助理权限)"
}

L:SetMiscLocalization{
	LKPull					= "圣光所谓的正义终于来了吗?我是否该把霜之哀伤放下，祈求你的宽恕呢，弗丁?",
	LKRoleplay				= "你们的原动力真的是正义感吗?我很怀疑...",
	ValkGrabbedIcon			= "瓦基里安影卫{rt%d}抓住了%s",
	ValkGrabbed				= "瓦基里安影卫抓住了%s",
	PlagueStackWarning		= "警告: %s中了%d层亡域瘟疫",
	AchievementCompleted	= ">> 成就成功: %s中了%d层亡域瘟疫 <<"
}

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("ICCTrash")

L:SetGeneralLocalization{
	name = "Icecrown Trash"
}

L:SetWarningLocalization{
	SpecWarnTrapL		= "触发陷阱! - 亡缚守卫被释放了",
	SpecWarnTrapP		= "触发陷阱! - 复仇的血肉收割者到来",
	SpecWarnGosaEvent	= "辛达苟萨夹道攻击开始!"
}

L:SetOptionLocalization{
	SpecWarnTrapL		= "当触发陷阱时显示特別警告",
	SpecWarnTrapP		= "当触发陷阱时显示特別警告",
	SpecWarnGosaEvent	= "为辛达苟萨夹道攻击显示特別警告"
}

L:SetMiscLocalization{
	WarderTrap1			= "谁...在那儿...?",
	WarderTrap2			= "我...更醒了!",
	WarderTrap3			= "主人的圣所受到了打扰!",
	FleshreaperTrap1	= "快，我们要从后面奇袭他们!",
	FleshreaperTrap2	= "你无法逃避我们!",
	FleshreaperTrap3	= "活人? 这儿?!",
	SindragosaEvent		= "你一定不能靠近冰霜之后。快，阻止他们!"
}
