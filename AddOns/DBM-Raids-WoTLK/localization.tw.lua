if GetLocale() ~= "zhTW" then return end

local L

----------------------------------
--  Archavon the Stone Watcher  --
----------------------------------

L = DBM:GetModLocalization("Archavon")

L:SetGeneralLocalization({
	name = "『石之看守者』亞夏梵"
})

L:SetWarningLocalization({
	WarningGrab	= "亞夏梵擒握 >%s<"
})

L:SetTimerLocalization({
	ArchavonEnrage	= "亞夏梵狂暴"
})

L:SetMiscLocalization({
	TankSwitch	= "%%s撲向(%S+)!"
})

L:SetOptionLocalization({
	WarningGrab 	= "提示擒握的目標",
	ArchavonEnrage	= "為$spell:26662顯示計時器"
})

--------------------------------
--  Emalon the Storm Watcher  --
--------------------------------

L = DBM:GetModLocalization("Emalon")

L:SetGeneralLocalization{
	name = "『風暴看守者』艾瑪隆"
}

L:SetTimerLocalization{
	timerMobOvercharge	= "超載爆炸",
	EmalonEnrage		= "艾瑪隆狂暴"
}

L:SetOptionLocalization{
	timerMobOvercharge	= "為超載的小兵顯示計時器(減益疊加)",
	EmalonEnrage		= "為$spell:26662顯示計時器"
}

---------------------------------
--  Koralon the Flame Watcher  --
---------------------------------

L = DBM:GetModLocalization("Koralon")

L:SetGeneralLocalization{
	name = "『烈焰看守者』寇拉隆"
}

L:SetTimerLocalization{
	KoralonEnrage= "寇拉隆狂暴"
}

L:SetOptionLocalization{
	KoralonEnrage	= "為$spell:26662顯示計時器"
}

L:SetMiscLocalization{
	Meteor	= "%s施展隕石之拳!"
}

-------------------------------
--  Toravon the Ice Watcher  --
-------------------------------
L = DBM:GetModLocalization("Toravon")

L:SetGeneralLocalization{
	name = "『寒冰看守者』拓拉梵"
}

L:SetTimerLocalization{
	ToravonEnrage	= "拓拉梵狂暴"
}

L:SetMiscLocalization{
	ToravonEnrage	= "為$spell:26662顯示計時器"
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

-------------------
--  Anub'Rekhan  --
-------------------
L = DBM:GetModLocalization("Anub'Rekhan")

L:SetGeneralLocalization({
	name = "阿努比瑞克漢"
})

L:SetOptionLocalization({
	ArachnophobiaTimer	= "為蜘蛛恐懼症(成就)顯示計時器"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "蜘蛛恐懼症",
	Pull1				= "對，跑吧!那樣傷口出血就更多了!",
	Pull2				= "一些小點心..."
})

----------------------------
--  Grand Widow Faerlina  --
----------------------------
L = DBM:GetModLocalization("Faerlina")

L:SetGeneralLocalization({
	name = "大寡婦費琳娜"
})

L:SetWarningLocalization({
	WarningEmbraceExpire	= "寡婦之擁5秒後結束",
	WarningEmbraceExpired	= "寡婦之擁結束"
})

L:SetOptionLocalization({
	WarningEmbraceExpire	= "為寡婦之擁結束顯示預先警告",
	WarningEmbraceExpired	= "為寡婦之擁結束顯示警告"
})

L:SetMiscLocalization({
})

---------------
--  Maexxna  --
---------------
L = DBM:GetModLocalization("Maexxna")

L:SetGeneralLocalization({
	name = "梅克絲娜"
})

L:SetWarningLocalization({
	WarningSpidersSoon	= "梅克絲娜之子5秒後出現",
	WarningSpidersNow	= "梅克絲娜之子出現了"
})

L:SetTimerLocalization({
	TimerSpider	= "下一次梅克絲娜之子"
})

L:SetOptionLocalization({
	WarningSpidersSoon	= "為梅克絲娜之子顯示預先警告",
	WarningSpidersNow	= "為梅克絲娜之子顯示警告",
	TimerSpider			= "為下一次梅克絲娜之子顯示計時器"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "蜘蛛恐懼症"
})

------------------------------
--  Noth the Plaguebringer  --
------------------------------
L = DBM:GetModLocalization("Noth")

L:SetGeneralLocalization({
	name = "『瘟疫使者』諾斯"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "傳送",
	WarningTeleportSoon	= "20秒後傳送"
})

L:SetTimerLocalization({
	TimerTeleport		= "傳送",
	TimerTeleportBack	= "傳送回來"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "為傳送顯示警告",
	WarningTeleportSoon	= "為傳送顯示預先警告",
	TimerTeleport		= "為傳送顯示計時器",
	TimerTeleportBack	= "為傳送回來顯示計時器"
})

L:SetMiscLocalization({
})

--------------------------
--  Heigan the Unclean  --
--------------------------
L = DBM:GetModLocalization("Heigan")

L:SetGeneralLocalization({
	name = "『不潔者』海根"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "傳送",
	WarningTeleportSoon	= "%d秒後 傳送"
})

L:SetTimerLocalization({
	TimerTeleport	= "傳送"
})

L:SetOptionLocalization({
	WarningTeleportNow	= "為傳送顯示警告",
	WarningTeleportSoon	= "為傳送顯示預先警告",
	TimerTeleport		= "為傳送顯示計時器"
})

L:SetMiscLocalization({
})

---------------
--  Loatheb  --
---------------
L = DBM:GetModLocalization("Loatheb")

L:SetGeneralLocalization({
	name = "憎恨者"
})

L:SetWarningLocalization({
	WarningHealSoon	= "3秒後可以治療",
	WarningHealNow	= "現在治療"
})

L:SetOptionLocalization({
	WarningHealSoon		= "為3秒後可以治療顯示預先警告",
	WarningHealNow		= "為現在治療顯示警告"
})

-----------------
--  Patchwerk  --
-----------------
L = DBM:GetModLocalization("Patchwerk")

L:SetGeneralLocalization({
	name = "縫補者"
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yell1 = "縫補者要跟你玩!",
	yell2 = "科爾蘇加德讓縫補者成為戰爭的化身!"
})

-----------------
--  Grobbulus  --
-----------------
L = DBM:GetModLocalization("Grobbulus")

L:SetGeneralLocalization({
	name = "葛羅巴斯"
})

-------------
--  Gluth  --
-------------
L = DBM:GetModLocalization("Gluth")

L:SetGeneralLocalization({
	name = "古魯斯"
})

----------------
--  Thaddius  --
----------------
L = DBM:GetModLocalization("Thaddius")

L:SetGeneralLocalization({
	name = "泰迪斯"
})

L:SetMiscLocalization({
	Yell	= "斯塔拉格要碾碎你!",
	Emote	= "%s超過負荷!",
	Emote2	= "泰斯拉線圈超過負荷!",
	Boss1 	= "伏晨",
	Boss2 	= "斯塔拉格",
	Charge1 = "負極",
	Charge2 = "正極"
})

L:SetOptionLocalization({
	WarningChargeChanged	= "當你的極性改變時顯示特別警告",
	WarningChargeNotChanged	= "當你的極性沒有改變時顯示特別警告",
	AirowEnabled			= "顯示箭頭 (正常 \"二邊\" 站位打法)",
	ArrowsRightLeft			= "顯示左/右箭頭 給 \"四角\" 站位打法 (如果極性改變顯示左箭頭, 沒變顯示左箭頭)",
	ArrowsInverse			= "顯示倒轉的 \"四角\" 站位打法 (如果極性改變顯示左箭頭, 沒變顯示右箭頭)"
})

L:SetWarningLocalization({
	WarningChargeChanged	= "極性變為%s",
	WarningChargeNotChanged	= "極性沒有改變"
})

----------------------------
--  Instructor Razuvious  --
----------------------------
L = DBM:GetModLocalization("Razuvious")

L:SetGeneralLocalization({
	name = "講師拉祖維斯"
})

L:SetMiscLocalization({
	Yell1 = "絕不留情!",
	Yell2 = "練習時間到此為止!都拿出真本事來!",
	Yell3 = "照我教你的做!",
	Yell4 = "絆腿……有什麼問題嗎?"
})

L:SetOptionLocalization({
	WarningShieldWallSoon	= "為盾牆結束顯示預先警告"
})

L:SetWarningLocalization({
	WarningShieldWallSoon	= "5秒後盾牆結束"
})

----------------------------
--  Gothik the Harvester  --
----------------------------
L = DBM:GetModLocalization("Gothik")

L:SetGeneralLocalization({
	name = "『收割者』高希"
})

L:SetOptionLocalization({
	TimerWave			= "為下一波顯示計時器",
	TimerPhase2			= "為第二階段顯示計時器",
	WarningWaveSoon		= "為波數顯示預先警告",
	WarningWaveSpawned	= "為波數出現顯示警告",
	WarningRiderDown	= "當無情的騎兵死亡時顯示警告",
	WarningKnightDown	= "當無情的死亡騎士死亡時顯示警告"
})

L:SetTimerLocalization({
	TimerWave	= "第%d波",
	TimerPhase2	= "第2階段"
})

L:SetWarningLocalization({
	WarningWaveSoon		= "3秒後第%d波: %s",
	WarningWaveSpawned	= "第%d波: %s出現了",
	WarningRiderDown	= "騎兵已死亡",
	WarningKnightDown	= "死亡騎士已死亡",
	WarningPhase2		= "第二階段"
})

L:SetMiscLocalization({
	yell			= "你們這些蠢貨已經主動步入了陷阱。",
	WarningWave1	= "%d %s",
	WarningWave2	= "%d %s 和 %d %s",
	WarningWave3	= "%d %s, %d %s 和 %d %s",
	Trainee			= "受訓員",
	Knight			= "死亡騎士",
	Rider			= "騎兵"
})

---------------------
--  Four Horsemen  --
---------------------
L = DBM:GetModLocalization("Horsemen")

L:SetGeneralLocalization({
	name = "四騎士"
})

L:SetOptionLocalization({
	WarningMarkSoon				= "為印記顯示預先警告",
	WarningMarkNow				= "為印記顯示警告",
	SpecialWarningMarkOnPlayer	= "當你印記堆疊多於四層時顯示特別警告"
})

L:SetTimerLocalization({
})

L:SetWarningLocalization({
	WarningMarkSoon			= "3秒後印記 %d",
	WarningMarkNow			= "印記:%d",
	SpecialWarningMarkOnPlayer	= "%s: %s"
})

L:SetMiscLocalization({
	Korthazz	= "寇斯艾茲族長",
	Rivendare	= "瑞文戴爾男爵",
	Blaumeux	= "布洛莫斯女士",
	Zeliek		= "札里克爵士"
})

-----------------
--  Sapphiron  --
-----------------
L = DBM:GetModLocalization("Sapphiron")

L:SetGeneralLocalization({
	name = "薩菲隆"
})

L:SetOptionLocalization({
	WarningAirPhaseSoon	= "為空中階段顯示預先警告",
	WarningAirPhaseNow	= "提示空中階段",
	WarningLanded		= "提示地上階段",
	TimerAir			= "為空中階段顯示計時器",
	TimerLanding		= "為降落顯示計時器"
})

L:SetMiscLocalization({
	EmoteBreath			= "%s深深地吸了一口氣。",
})

L:SetWarningLocalization({
	WarningAirPhaseSoon	= "10秒後 空中階段",
	WarningAirPhaseNow	= "空中階段",
	WarningLanded		= "薩菲隆降落了"
})

L:SetTimerLocalization({
	TimerAir		= "空中階段",
	TimerLanding	= "降落"
})

------------------
--  Kel'Thuzad  --
------------------

L = DBM:GetModLocalization("Kel'Thuzad")

L:SetGeneralLocalization({
	name = "科爾蘇加德"
})

L:SetOptionLocalization({
	TimerPhase2			= "為第二階段顯示計時器",
	specwarnP2Soon		= "為科爾蘇加德攻擊前10秒顯示特別警告",
	warnAddsSoon		= "為寒冰皇冠守護者顯示預先警告"
})

L:SetMiscLocalization({
	Yell = "僕從們，侍衛們，隸屬於黑暗與寒冷的戰士們!聽從科爾蘇加德的召喚!"
})

L:SetWarningLocalization({
	specwarnP2Soon	= "10秒後科爾蘇加德開始攻擊",
	warnAddsSoon	= "寒冰皇冠守護者即將出現"
})

L:SetTimerLocalization({
	TimerPhase2	= "第二階段"
})

----------------------------
--  The Obsidian Sanctum  --
----------------------------
--  Shadron  --
---------------
L = DBM:GetModLocalization("Shadron")

L:SetGeneralLocalization({
	name = "夏德朗"
})

----------------
--  Tenebron  --
----------------
L = DBM:GetModLocalization("Tenebron")

L:SetGeneralLocalization({
	name = "坦納伯朗"
})

----------------
--  Vesperon  --
----------------
L = DBM:GetModLocalization("Vesperon")

L:SetGeneralLocalization({
	name = "維斯佩朗"
})

------------------
--  Sartharion  --
------------------
L = DBM:GetModLocalization("Sartharion")

L:SetGeneralLocalization({
	name = "『黑曜守護者』撒爾薩里安"
})

L:SetWarningLocalization({
	WarningTenebron			= "坦納伯朗到來",
	WarningShadron			= "夏德朗到來",
	WarningVesperon			= "維斯佩朗到來",
	WarningFireWall			= "火焰障壁",
	WarningVesperonPortal	= "維斯佩朗的傳送門",
	WarningTenebronPortal	= "坦納伯朗的傳送門",
	WarningShadronPortal	= "夏德朗的傳送門"
})

L:SetTimerLocalization({
	TimerTenebron		= "坦納伯朗到來",
	TimerShadron		= "夏德朗到來",
	TimerVesperon		= "維斯佩朗到來"
})

L:SetOptionLocalization({
	AnnounceFails			= "公佈踩中暗影裂縫和撞上火焰障壁的玩家到團隊頻道 (需要團隊隊長或助理權限)",
	TimerTenebron			= "為坦納伯朗到來顯示計時器",
	TimerShadron			= "為夏德朗到來顯示計時器",
	TimerVesperon			= "為維斯佩朗到來顯示計時器",
	WarningFireWall			= "為火焰障壁顯示特別警告",
	WarningTenebron			= "提示坦納伯朗到來",
	WarningShadron			= "提示夏德朗到來",
	WarningVesperon			= "提示維斯佩朗到來",
	WarningTenebronPortal	= "為坦納伯朗的傳送門顯示特別警告",
	WarningShadronPortal	= "為夏德朗的傳送門顯示特別警告",
	WarningVesperonPortal	= "為維斯佩朗的傳送門顯示特別警告"
})

L:SetMiscLocalization({
	Wall			= "圍繞著%s的熔岩開始劇烈地翻騰!",
	Portal			= "%s開始開啟暮光傳送門!",
	NameTenebron	= "坦納伯朗",
	NameShadron		= "夏德朗",
	NameVesperon	= "維斯佩朗",
	FireWallOn		= "火焰障壁: %s",
	VoidZoneOn		= "暗影裂縫: %s",
	VoidZones		= "踩中暗影裂縫(這一次): %s",
	FireWalls		= "撞上火焰障壁(這一次): %s"
})

---------------
--  Malygos  --
---------------
L = DBM:GetModLocalization("Malygos")

L:SetGeneralLocalization({
	name = "瑪里苟斯"
})

L:SetMiscLocalization({
	YellPull	= "我的耐心到此為止了。我要親自消滅你們!",
	EmoteSpark	= "一個力量火花從附近的裂縫中形成。",
	YellPhase2	= "我原本只是想盡快結束你們的生命",
	YellBreath	= "只要我的龍息尚存，你們就毫無機會!",
	YellPhase3	= "現在你們幕後的主使終於出現"
})

-----------------------
--  Flame Leviathan  --
-----------------------
L = DBM:GetModLocalization("FlameLeviathan")

L:SetGeneralLocalization{
	name = "烈焰戰輪"
}

L:SetMiscLocalization{
	YellPull	= "發現敵意實體。啟動威脅評估協定。首要目標接近中。30秒後將再度評估。",
	Emote		= "%%s緊追(%S+)%。"
}

L:SetWarningLocalization{
	PursueWarn				= "獵殺: >%s<",
	warnNextPursueSoon		= "5秒後獵殺轉換",
	SpecialPursueWarnYou	= "你中了獵殺 - 快跑",
	warnWardofLife			= "生命結界出現"
}

L:SetOptionLocalization{
	SpecialPursueWarnYou	= "當你中了獵殺時顯示特別警告",
	PursueWarn				= "提示獵殺的目標",
	warnNextPursueSoon		= "為下一次獵殺顯示預先警告",
	warnWardofLife			= "為生命結界出現顯示特別警告"
}

--------------------------------
--  Ignis the Furnace Master  --
--------------------------------
L = DBM:GetModLocalization("Ignis")

L:SetGeneralLocalization{
	name = "『火爐之主』伊格尼司"
}

------------------
--  Razorscale  --
------------------
L = DBM:GetModLocalization("Razorscale")

L:SetGeneralLocalization{
	name = "銳鱗"
}

L:SetWarningLocalization{
	warnTurretsReadySoon	= "20秒後 最後一座砲塔完成",
	warnTurretsReady		= "最後一座砲塔已完成"
}

L:SetTimerLocalization{
	timerTurret1	= "砲塔1",
	timerTurret2	= "砲塔2",
	timerTurret3	= "砲塔3",
	timerTurret4	= "砲塔4",
	timerGrounded	= "地上階段"
}

L:SetOptionLocalization{
	warnTurretsReadySoon	= "為砲塔顯示預先警告",
	warnTurretsReady		= "為砲塔顯示警告",
	timerTurret1			= "為砲塔1顯示計時器",
	timerTurret2			= "為砲塔2顯示計時器",
	timerTurret3			= "為砲塔3顯示計時器 (25人)",
	timerTurret4			= "為砲塔4顯示計時器 (25人)",
	timerGrounded			= "為地上階段顯示計時器"
}

L:SetMiscLocalization{
	YellAir				= "給我們一點時間來準備建造砲塔。",
	YellAir2			= "火熄了!讓我們重建砲塔!",
	YellGround			= "快!她可不會在地面上待太久!",
	EmotePhase2			= "再也飛不動了!"
}

----------------------------
--  XT-002 Deconstructor  --
----------------------------
L = DBM:GetModLocalization("XT002")

L:SetGeneralLocalization{
	name = "XT-002拆解者"
}

--------------------
--  Iron Council  --
--------------------
L = DBM:GetModLocalization("IronCouncil")

L:SetGeneralLocalization{
	name = "鐵之集會所"
}

L:SetOptionLocalization{
	AlwaysWarnOnOverload	= "總是對$spell:63481顯示警告(否則只有當目標是風暴召喚者的時候顯示)"
}

L:SetMiscLocalization{
	Steelbreaker			= "破鋼者",
	RunemasterMolgeim		= "符文大師墨吉姆",
	StormcallerBrundir 		= "風暴召喚者布倫迪爾"
}

----------------------------
--  Algalon the Observer  --
----------------------------
L = DBM:GetModLocalization("Algalon")

L:SetGeneralLocalization{
	name = "『觀察者』艾爾加隆"
}

L:SetTimerLocalization{
	NextCollapsingStar		= "下一次崩陷之星",
	TimerCombatStart		= "戰鬥開始"
}

L:SetWarningLocalization{
	WarnPhase2Soon			= "第2階段即將到來",
	warnStarLow				= "崩陷之星血量低"
}

L:SetOptionLocalization{
	WarningPhasePunch		= "提示相位拳擊的目標",
	NextCollapsingStar		= "為下一次崩陷之星顯示計時器",
	TimerCombatStart		= "為戰鬥開始顯示計時器",
	WarnPhase2Soon			= "為第2階段顯示預先警告 (大約23%)",
	warnStarLow				= "當崩陷之星血量低(大約25%)時顯示特別警告"
}

L:SetMiscLocalization{
	HealthInfo			= "崩陷之星血量",
	YellPull			= "你的行為毫無意義。這場衝突的結果早已計算出來了。不論結局為何，萬神殿仍將收到觀察者的訊息。",
	YellKill			= "我曾經看過塵世沉浸在造物者的烈焰之中，眾生連一聲悲泣都無法呼出，就此凋零。整個星系在彈指之間歷經了毀滅與重生。然而在這段歷程之中，我的心卻無法感受到絲毫的...惻隱之念。我‧感‧受‧不‧到。成千上萬的生命就這麼消逝。他們是否擁有與你同樣堅韌的生命?他們是否與你同樣熱愛生命?",
	Emote_CollapsingStar	= "%s開始召喚崩陷之星!",
	Phase2				= "瞧瞧泰坦造物的能耐吧!",
	FirstPull			= "從我的雙眼觀看你的世界:一個無邊無際的宇宙--連你們之中最具智慧者都無法想像的廣闊無垠。",
}

----------------
--  Kologarn  --
----------------
L = DBM:GetModLocalization("Kologarn")

L:SetGeneralLocalization{
	name = "柯洛剛恩"
}

L:SetTimerLocalization{
	timerLeftArm			= "左臂重生",
	timerRightArm			= "右臂重生",
	achievementDisarmed		= "卸除手臂計時器"
}

L:SetOptionLocalization{
	timerLeftArm			= "為左臂重生顯示計時器",
	timerRightArm			= "為右臂重生顯示計時器",
	achievementDisarmed		= "為成就:卸除手臂顯示計時器"
}

L:SetMiscLocalization{
	Yell_Trigger_arm_left	= "小小的擦傷!",
	Yell_Trigger_arm_right	= "只是皮肉之傷!",
	Health_Body				= "柯洛剛恩身體",
	Health_Right_Arm		= "右臂",
	Health_Left_Arm			= "左臂",
	FocusedEyebeam			= "正在注視著你"
}

---------------
--  Auriaya  --
---------------
L = DBM:GetModLocalization("Auriaya")

L:SetGeneralLocalization{
	name = "奧芮雅"
}

L:SetMiscLocalization{
	Defender = "野性防衛者 (%d)",
	YellPull = "有些事情不該公諸於世!"
}

L:SetTimerLocalization{
	timerDefender	= "野性防衛者復活"
}

L:SetWarningLocalization{
	WarnCatDied 	= "野性防衛者倒下 (剩餘%d隻)",
	WarnCatDiedOne 	= "野性防衛者倒下 (剩下最後一隻)"
}

L:SetOptionLocalization{
	WarnCatDied		= "當野性防衛者死亡時顯示警告",
	WarnCatDiedOne	= "當野性防衛者剩下最後一隻時顯示警告",
	timerDefender   = "當野性防衛者準備復活時顯示計時器"
}

-------------
--  Hodir  --
-------------
L = DBM:GetModLocalization("Hodir")

L:SetGeneralLocalization{
	name = "霍迪爾"
}

L:SetMiscLocalization{
	Pull		= "你將為擅闖付出代價!",
	YellKill	= "我...我終於從他的掌控中...解脫了。"
}

--------------
--  Thorim  --
--------------
L = DBM:GetModLocalization("Thorim")

L:SetGeneralLocalization{
	name = "索林姆"
}

L:SetTimerLocalization{
	TimerHardmode	= "困難模式"
}

L:SetOptionLocalization{
	TimerHardmode	= "為困難模式顯示計時器",
	AnnounceFails	= "公佈中了閃電充能的玩家到團隊頻道<br/>(需要團隊隊長或助理權限)"
}

L:SetMiscLocalization{
	YellPhase1	= "擅闖者!像你們這種膽敢干涉我好事的凡人將付出...等等--你...",
	YellPhase2	= "無禮的小輩，你竟敢在我的王座之上挑戰我?我會親手碾碎你們!",
	YellKill	= "住手!我認輸了!",
	ChargeOn	= "閃電充能: %s",
	Charge		= "中了閃電充能 (這一次): %s"
}

-------------
--  Freya  --
-------------
L = DBM:GetModLocalization("Freya")

L:SetGeneralLocalization{
	name = "芙蕾雅"
}

L:SetMiscLocalization{
	SpawnYell	= "孩子們，協助我!",
	WaterSpirit	= "上古水之靈",
	Snaplasher	= "猛攫鞭笞者",
	StormLasher	= "風暴鞭笞者",
	YellKill	= "他對我的操控已然退散。我已再次恢復神智了。感激不盡，英雄們。"
}

L:SetWarningLocalization{
	WarnSimulKill	= "第一隻元素死亡 - 大約12秒後復活"
}

L:SetTimerLocalization{
	TimerSimulKill	= "復活"
}

L:SetOptionLocalization{
	WarnSimulKill	= "提示第一隻元素死亡",
	TimerSimulKill	= "為三元素復活顯示計時器"
}

----------------------
--  Freya's Elders  --
----------------------
L = DBM:GetModLocalization("Freya_Elders")

L:SetGeneralLocalization{
	name = "芙蕾雅的長者們"
}

---------------
--  Mimiron  --
---------------
L = DBM:GetModLocalization("Mimiron")

L:SetGeneralLocalization{
	name = "彌米倫"
}

L:SetWarningLocalization{
	MagneticCore		= ">%s<拿到了磁能之核",
	WarnBombSpawn		= "炸彈機器人出現了"
}

L:SetTimerLocalization{
	TimerHardmode	= "困難模式 - 自毀程序",
	TimeToPhase2	= "第2階段開始",
	TimeToPhase3	= "第3階段開始",
	TimeToPhase4	= "第4階段開始"
}

L:SetOptionLocalization{
	TimeToPhase2			= "為第2階段開始顯示計時器",
	TimeToPhase3			= "為第3階段開始顯示計時器",
	TimeToPhase4			= "為第4階段開始顯示計時器",
	MagneticCore			= "提示磁能之核的拾取者",
	WarnBombSpawn			= "為炸彈機器人顯示警告",
	TimerHardmode			= "為困難模式顯示計時器"
}

L:SetMiscLocalization{
	MobPhase1		= "戰輪MK II",
	MobPhase2		= "VX-001",
	MobPhase3		= "空中指揮裝置",
	YellPull		= "我們沒有太多時間，朋友們!你們要幫我測試我最新也是最偉大的創作。在你們改變心意之前，別忘了就是你們把XT-002搞得一團糟，你們欠我一次。",
	YellHardPull	= "為什麼你要做出這種事?難道你沒看見標示上寫著「請勿觸碰這個按鈕!」嗎?現在自爆裝置已經啟動了，我們要怎麼完成測試呢?",
	YellPhase2		= "太好了!絕妙的良好結果!外殼完整度98.9%!幾乎只有一點擦痕!繼續下去。",
	YellPhase3		= "感謝你，朋友們!我們的努力讓我獲得了一些絕佳的資料!現在，我把東西放在哪兒了--噢，在這裡。",
	YellPhase4		= "初步測試階段完成。現在要玩真的啦!"
}

---------------------
--  General Vezax  --
---------------------
L = DBM:GetModLocalization("GeneralVezax")

L:SetGeneralLocalization{
	name = "威札斯將軍"
}

L:SetTimerLocalization{
	hardmodeSpawn = "薩倫聚惡體出現"
}

L:SetOptionLocalization{
	hardmodeSpawn			= "為薩倫聚惡體出現顯示計時器 (困難模式)"
}

L:SetMiscLocalization{
	EmoteSaroniteVapors	= "一片薩倫煙霧在附近聚合!"
}

------------------
--  Yogg-Saron  --
------------------
L = DBM:GetModLocalization("YoggSaron")

L:SetGeneralLocalization{
	name = "尤格薩倫"
}

L:SetWarningLocalization{
	WarningGuardianSpawned 			= "第%d個尤格薩倫守護者出現了",
	WarningCrusherTentacleSpawned	= "粉碎觸手出現了",
	WarningSanity 					= "剩下%d理智",
	SpecWarnSanity 					= "剩下%d理智",
	SpecWarnMadnessOutNow			= "瘋狂誘陷即將結束 - 快傳送出去",
	WarnBrainPortalSoon				= "3秒後腦部傳送門",
	specWarnBrainPortalSoon			= "腦部傳送門即將到來"
}

L:SetTimerLocalization{
	NextPortal	= "下一次腦部傳送門"
}

L:SetOptionLocalization{
	WarningGuardianSpawned			= "為尤格薩倫守護者出現顯示警告",
	WarningCrusherTentacleSpawned	= "為粉碎觸手出現顯示警告",
	WarningSanity					= "當理智剩下50時顯示警告",
	SpecWarnSanity					= "當理智過低(25,15,5)時顯示特別警告",
	WarnBrainPortalSoon				= "為腦部傳送門顯示預先警告",
	SpecWarnMadnessOutNow			= "為瘋狂誘陷結束前顯示特別警告",
	SpecWarnFervorCast				= "當薩拉的熱誠正在對你施放時顯示特別警告(必須有最少一名團隊成員設置目標或專注目標)",
	specWarnBrainPortalSoon			= "為下一次腦部傳送門顯示特別警告",
	NextPortal						= "為下一次傳送門顯示計時器"
}

L:SetMiscLocalization{
	YellPull 			= "我們即將有機會打擊怪物的首腦!現在將你的憤怒與仇恨貫注在他的爪牙上!",
	YellPhase2			= "我是清醒的夢境。",
	Sara 				= "薩拉"
}

--------------
--  Onyxia  --
--------------
L = DBM:GetModLocalization("Onyxia")

L:SetGeneralLocalization{
	name = "奧妮克希亞"
}

L:SetWarningLocalization{
	WarnWhelpsSoon		= "奧妮克希亞幼龍即將出現"
}

L:SetTimerLocalization{
	TimerWhelps 		= "奧妮克希亞幼龍"
}

L:SetOptionLocalization{
	TimerWhelps		= "為奧妮克希亞幼龍顯示計時器",
	WarnWhelpsSoon	= "為奧妮克希亞幼龍顯示預先警告",
	SoundWTF3		= "為經典傳奇式奧妮克希亞副本播放一些有趣的音效"
}

L:SetMiscLocalization{
	YellPull = "真是幸運。通常我為了覓食就必須離開窩。",
	YellP2 	= "這毫無意義的行動讓我很厭煩。我會從上空把你們都燒成灰!",
	YellP3 	= "看起來需要再給你一次教訓，凡人!"
}

------------------------
--  Northrend Beasts  --
------------------------
L = DBM:GetModLocalization("NorthrendBeasts")

L:SetGeneralLocalization{
	name = "北裂境巨獸"
}

L:SetWarningLocalization{
	WarningSnobold		= "極地狗頭人奴僕出現在>%s<"
}

L:SetTimerLocalization{
	TimerNextBoss		= "下一隻王到來",
	TimerEmerge			= "持續鑽地",
	TimerSubmerge		= "下一次鑽地"
}

L:SetOptionLocalization{
	WarningSnobold		= "為極地狗頭人奴僕出現顯示警告",
	ClearIconsOnIceHowl	= "衝鋒前消除所有標記",
	TimerNextBoss		= "為下一隻王到來顯示計時器",
	TimerEmerge			= "為持續鑽地顯示計時器",
	TimerSubmerge		= "為下一次鑽地顯示計時器",
	IcehowlArrow		= "當冰嚎即將衝鋒在你附近時顯示DBM箭頭"
}

L:SetMiscLocalization{
	Charge		= "%%s怒視著(%S+)，並發出震耳的咆哮!",
	CombatStart	= "來自風暴群山最深邃，最黑暗的洞穴。歡迎『穿刺者』戈莫克!戰鬥吧，英雄們!",
	Phase2		= "準備面對酸喉和懼鱗的雙重夢魘吧，英雄們，快就定位!",
	Phase3		= "下一場參賽者的出場連空氣都會為之凝結:冰嚎!戰個你死我活吧，勇士們!",
	Gormok		= "『穿刺者』戈莫克",
	Acidmaw		= "酸喉",
	Dreadscale	= "懼鱗",
	Icehowl		= "冰嚎"
}

---------------------
--  Lord Jaraxxus  --
---------------------
L = DBM:GetModLocalization("Jaraxxus")

L:SetGeneralLocalization{
	name = "賈拉克瑟斯領主"
}

L:SetOptionLocalization{
	IncinerateShieldFrame	= "在首領血量裡顯示焚化血肉的血量"
}

L:SetMiscLocalization{
	IncinerateTarget	= "焚化血肉: %s",
	FirstPull	= "大術士威爾弗雷德·菲斯巴恩將會召喚你們的下一個挑戰者。等待他的登場吧。"
}

-------------------------
--  Faction Champions  --
-------------------------
L = DBM:GetModLocalization("Champions")

L:SetGeneralLocalization{
	name = "陣營勇士"
}

L:SetMiscLocalization{
	AllianceVictory		= "榮耀歸於聯盟!",
	HordeVictory		= "那只是讓你們知道將來必須面對的命運。為了部落!"
}

---------------------
--  Val'kyr Twins  --
---------------------
L = DBM:GetModLocalization("ValkTwins")

L:SetGeneralLocalization{
	name = "華爾琪雙子"
}

L:SetTimerLocalization{
	TimerSpecialSpell		= "下一次特別技能"
}

L:SetWarningLocalization{
	WarnSpecialSpellSoon	= "特別技能即將到來",
	SpecWarnSpecial			= "快變換顏色",
	SpecWarnSwitchTarget	= "快換目標打雙子契印",
	SpecWarnKickNow			= "現在斷法",
	WarningTouchDebuff		= "光明或黑暗之觸:>%s<",
	WarningPoweroftheTwins2	= "雙子威能 - 對>%s<加大治療"
}

L:SetMiscLocalization{
	Fjola 		= "菲歐拉·光寂",
	Eydis	   	= "艾狄絲·暗寂"
}

L:SetOptionLocalization{
	TimerSpecialSpell		= "為下一次特別技能顯示計時器",
	WarnSpecialSpellSoon	= "為下一次特別技能顯示預先警告",
	SpecWarnSpecial			= "當你需要變換顏色時顯示特別警告",
	SpecWarnSwitchTarget	= "當另一個首領施放雙子契印時顯示特別警告",
	SpecWarnKickNow			= "當你可以斷法時顯示特別警告",
	SpecialWarnOnDebuff		= "當你中了光明或黑暗之觸時顯示特別警告 (需切換顏色)",
	SetIconOnDebuffTarget	= "為光明或黑暗之觸的目標設置標記 (英雄模式)",
	WarningTouchDebuff		= "提示光明或黑暗之觸的目標",
	WarningPoweroftheTwins2	= "提示雙子威能的目標"
}

-----------------
--  Anub'arak  --
-----------------
L = DBM:GetModLocalization("Anub'arak_Coliseum")

L:SetGeneralLocalization{
	name 				= "阿努巴拉克"
}

L:SetTimerLocalization{
	TimerEmerge			= "下一次現身",
	TimerSubmerge		= "下一次鑽地",
	timerAdds			= "下一次中蟲出現"
}

L:SetWarningLocalization{
	WarnEmerge				= "阿努巴拉克現身了",
	WarnEmergeSoon			= "10秒後現身",
	WarnSubmerge			= "阿努巴拉克鑽進地裡了",
	WarnSubmergeSoon		= "10秒後鑽進地裡",
	specWarnSubmergeSoon	= "10秒後鑽進地裡!",
	warnAdds				= "奈幽掘洞者 出現了"
}

L:SetMiscLocalization{
	Emerge				= "從地底鑽出!",
	Burrow				= "鑽進地裡!",
	PcoldIconSet		= "透骨之寒{rt%d}於%s",
	PcoldIconRemoved	= "移除標記:%s"
}

L:SetOptionLocalization{
	WarnEmerge				= "為鑽出地面顯示警告",
	WarnEmergeSoon			= "為鑽出地面顯示預先警告",
	WarnSubmerge			= "為鑽進地裡顯示警告",
	WarnSubmergeSoon		= "為鑽進地裡顯示預先警告",
	specWarnSubmergeSoon	= "為即將鑽進地裡顯示特別警告",
	warnAdds				= "提示奈幽掘洞者出現",
	timerAdds				= "為下一次 奈幽掘洞者出現顯示計時器",
	TimerEmerge				= "為持續鑽地顯示計時器",
	TimerSubmerge			= "為下一次 鑽地顯示計時器",
	AnnouncePColdIcons		= "公佈$spell:68510目標設置的標記到團隊頻道<br/>(需要團隊隊長或助理權限)",
	AnnouncePColdIconsRemoved	= "當移除$spell:68510的標記時也提示<br/>(需要上述選項)"
}

----------------------
--  Lord Marrowgar  --
----------------------
L = DBM:GetModLocalization("LordMarrowgar")

L:SetGeneralLocalization{
	name = "瑪洛嘉領主"
}

-------------------------
--  Lady Deathwhisper  --
-------------------------
L = DBM:GetModLocalization("Deathwhisper")

L:SetGeneralLocalization{
	name = "亡語女士"
}

L:SetTimerLocalization{
	TimerAdds	= "新的小怪"
}

L:SetWarningLocalization{
	WarnReanimating	= "小怪再活化",
	WarnAddsSoon	= "新的小怪即將到來"
}

L:SetOptionLocalization{
	WarnAddsSoon		= "為新的小怪出現顯示預先警告",
	WarnReanimating		= "當小怪再活化時顯示警告",
	TimerAdds			= "為新的小怪顯示計時器"
}

L:SetMiscLocalization{
	YellReanimatedFanatic	= "起來，在純粹的形態中感受狂喜!",
	Fanatic1				= "神教狂熱者",
	Fanatic2				= "畸形的狂熱者",
	Fanatic3				= "再活化的狂熱者"
}

----------------------
--  Gunship Battle  --
----------------------
L = DBM:GetModLocalization("GunshipBattle")

L:SetGeneralLocalization{
	name = "砲艇戰"
}

L:SetWarningLocalization{
	WarnAddsSoon	= "新的小怪即將到來"
}

L:SetOptionLocalization{
	WarnAddsSoon		= "為新的小怪出現顯示預先警告",
	TimerAdds			= "為新的小怪顯示計時器"
}

L:SetTimerLocalization{
	TimerAdds			= "新的小怪"
}

L:SetMiscLocalization{
	PullAlliance	= "發動引擎!小夥子們，我們即將面對命運啦!",
	KillAlliance	= "別說我沒警告過你，無賴!兄弟姊妹們，向前衝!",
	PullHorde		= "起來吧，部落的子女!今天我們要和最可恨的敵人作戰!為了部落!",
	KillHorde		= "聯盟已經動搖了。向巫妖王前進!",
	AddsAlliance	= "劫奪者，士官們，攻擊!",
	AddsHorde		= "海員們，士官們，攻擊!",
	MageAlliance	= "船體受到傷害，找個戰鬥法師到來，搞定那些火砲!",
	MageHorde		= "船體受損，找個巫士到這裡來，搞定那些火砲!"
}

-----------------------------
--  Deathbringer Saurfang  --
-----------------------------
L = DBM:GetModLocalization("Deathbringer")

L:SetGeneralLocalization{
	name = "死亡使者薩魯法爾"
}

L:SetOptionLocalization{
	RangeFrame				= "顯示距離框 (12碼)",
	RunePowerFrame			= "顯示首領血量及$spell:72371條"
}

L:SetMiscLocalization{
	RunePower			= "血魄威能",
	PullAlliance		= "每個你殺死的部落士兵 -- 每條死去的聯盟狗，都讓巫妖王的軍隊隨之增長。此時此刻華爾琪都還在把你們倒下的同伴復活成天譴軍。",
	PullHorde			= "柯爾克隆，前進!勇士們，要當心，天譴軍團已經..."
}

-----------------
--  Festergut  --
-----------------
L = DBM:GetModLocalization("Festergut")

L:SetGeneralLocalization{
	name = "膿腸"
}

L:SetOptionLocalization{
	RangeFrame			= "顯示距離框 (8碼)",
	AnnounceSporeIcons	= "公佈$spell:69279目標設置的標記到團隊頻道<br/>(需要團隊隊長)",
	AchievementCheck	= "公佈 '流感疫苗短缺' 成就失敗到團隊頻道<br/>(需助理權限)"
}

L:SetMiscLocalization{
	SporeSet			= "氣體孢子{rt%d}: %s",
	AchievementFailed	= ">> 成就失敗: %s中了%d層孢子 <<"
}

---------------
--  Rotface  --
---------------
L = DBM:GetModLocalization("Rotface")

L:SetGeneralLocalization{
	name = "腐臉"
}

L:SetWarningLocalization{
	WarnOozeSpawn		= "小軟泥怪出現了",
	SpecWarnLittleOoze	= "你被小軟泥怪盯上了 - 快跑開"
}


L:SetOptionLocalization{
	WarnOozeSpawn		= "為小軟泥的出現顯示警告",
	SpecWarnLittleOoze	= "當你被小軟泥怪盯上時顯示特別警告",
	RangeFrame			= "顯示距離框(8碼)"
}

L:SetMiscLocalization{
	YellSlimePipes1	= "大夥聽著，好消息!我修好了劇毒軟泥管!",
	YellSlimePipes2	= "大夥聽著，超級好消息!軟泥又開始流動了!"
}

---------------------------
--  Professor Putricide  --
---------------------------
L = DBM:GetModLocalization("Putricide")

L:SetGeneralLocalization{
	name 				= "普崔希德教授"
}

L:SetOptionLocalization{
	MalleableGooIcon	= "為第一個中$spell:72295的目標設置標記"
}

----------------------------
--  Blood Prince Council  --
----------------------------
L = DBM:GetModLocalization("BPCouncil")

L:SetGeneralLocalization{
	name = "血親王議會"
}

L:SetWarningLocalization{
	WarnTargetSwitch		= "轉換目標到: %s",
	WarnTargetSwitchSoon	= "轉換目標即將到來"
}

L:SetTimerLocalization{
	TimerTargetSwitch		= "轉換目標"
}

L:SetOptionLocalization{
	WarnTargetSwitch		= "為轉換目標顯示警告",
	WarnTargetSwitchSoon	= "為轉換目標顯示預先警告",
	TimerTargetSwitch		= "為轉換目標顯示冷卻計時器",
	ActivePrinceIcon		= "設置標記在強化的親王身上(頭顱)",
	RangeFrame				= "顯示距離框(12碼)"
}

L:SetMiscLocalization{
	Keleseth			= "凱雷希斯親王",
	Taldaram			= "泰爾達朗親王",
	Valanar				= "瓦拉納爾親王",
	EmpoweredFlames		= "煉獄烈焰加速靠近(%S+)!"
}

-----------------------------
--  Blood-Queen Lana'thel  --
-----------------------------
L = DBM:GetModLocalization("Lanathel")

L:SetGeneralLocalization{
	name = "血腥女王菈娜薩爾"
}

L:SetOptionLocalization{
	RangeFrame			= "顯示距離框(8碼)"
}

L:SetMiscLocalization{
	SwarmingShadows		= "暗影聚集並旋繞在(%S+)四周!",
	YellFrenzy			= "我餓了!"
}

-----------------------------
--  Valithria Dreamwalker  --
-----------------------------
L = DBM:GetModLocalization("Valithria")

L:SetGeneralLocalization{
	name = "瓦莉絲瑞雅·夢行者"
}

L:SetWarningLocalization{
	WarnPortalOpen			= "傳送門開啟"
}

L:SetTimerLocalization{
	TimerPortalsOpen		= "傳送門開啟",
	TimerBlazingSkeleton	= "下一次熾熱骷髏",
	TimerAbom				= "下一次憎惡體"
}

L:SetOptionLocalization{
	SetIconOnBlazingSkeleton	= "為熾熱骷髏設置標記(頭顱)",
	WarnPortalOpen				= "當夢魘之門開啟時顯示警告",
	TimerPortalsOpen			= "當夢魘之門開啟時顯示計時器",
	TimerBlazingSkeleton		= "為下一次熾熱骷髏出現顯示計時器",
	TimerAbom					= "為下一次貪吃的憎惡體出現顯示計時器"
}

L:SetMiscLocalization{
	YellPull			= "入侵者已經突破了內部聖所。加快摧毀綠龍的速度!只要留下骨頭和肌腱來復活!",
	YellKill			= "我重生了!伊瑟拉賦予我讓那些邪惡生物安眠的力量!",
	YellPortals			= "我打開了一道傳送門通往夢境。你們的救贖就在其中，英雄們..."
}

------------------
--  Sindragosa  --
------------------
L = DBM:GetModLocalization("Sindragosa")

L:SetGeneralLocalization{
	name = "辛德拉苟莎"
}

L:SetWarningLocalization{
	WarnAirphase			= "空中階段",
	WarnGroundphaseSoon		= "辛德拉苟莎 即將著陸"
}

L:SetTimerLocalization{
	TimerNextAirphase		= "下一次空中階段",
	TimerNextGroundphase	= "下一次地上階段",
	AchievementMystic		= "清除秘能連擊疊加"
}

L:SetOptionLocalization{
	WarnAirphase			= "提示空中階段",
	WarnGroundphaseSoon		= "為地上階段顯示預先警告",
	TimerNextAirphase		= "為下一次 空中階段顯示計時器",
	TimerNextGroundphase	= "為下一次 地上階段顯示計時器",
	AnnounceFrostBeaconIcons= "公佈$spell:70126目標設置的標記到團隊頻道<br/>(需要團隊隊長)",
	ClearIconsOnAirphase	= "空中階段前清除所有標記",
	AchievementCheck		= "公佈 '吃到飽' 成就警告到團隊頻道<br/>(需助理權限)",
	RangeFrame				= "根據最後首領使用的技能跟玩家減益顯示動態距離框(10/20碼)"
}

L:SetMiscLocalization{
	YellAirphase		= "你們的入侵將在此終止!誰也別想存活!",
	YellPhase2			= "現在，絕望地感受我主無限的力量吧!",
	YellAirphaseDem		= "Rikk zilthuras rikk zila Aman adare tiriosh ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	YellPhase2Dem		= "Zar kiel xi romathIs zilthuras revos ruk toralar ",--Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	BeaconIconSet		= "冰霜信標{rt%d}: %s",
	AchievementWarning	= "警告: %s中了5層秘能連擊",
	AchievementFailed	= ">> 成就失敗: %s中了%d層秘能連擊 <<"
}

---------------------
--  The Lich King  --
---------------------
L = DBM:GetModLocalization("LichKing")

L:SetGeneralLocalization{
	name 				= "巫妖王"
}

L:SetWarningLocalization{
	ValkyrWarning			= ">%s< 給抓住了!",
	SpecWarnYouAreValkd		= "你給抓住了",
	WarnNecroticPlagueJump	= "亡域瘟疫跳到>%s<身上",
	SpecWarnValkyrLow		= "華爾琪血量低於55%"
}

L:SetTimerLocalization{
	TimerRoleplay		= "角色扮演",
	PhaseTransition		= "轉換階段",
	TimerNecroticPlagueCleanse 	= "淨化亡域瘟疫"
}

L:SetOptionLocalization{
	TimerRoleplay			= "為角色扮演事件顯示計時器",
	WarnNecroticPlagueJump	= "提示$spell:73912跳躍後的目標",
	TimerNecroticPlagueCleanse	= "為淨化第一次堆疊前的亡域瘟疫顯示計時器",
	PhaseTransition			= "為轉換階段顯示計時器",
	ValkyrWarning			= "提示誰給華爾琪影衛抓住了",
	SpecWarnYouAreValkd		= "當你給華爾琪影衛抓住時顯示特別警告",
	AnnounceValkGrabs		= "提示誰被華爾琪影衛抓住到團隊頻道<br/>(需開啟團隊廣播及助理權限)",
	SpecWarnValkyrLow		= "當華爾琪血量低於55%時顯示特別警告",
	AnnouncePlagueStack		= "提示$spell:73912層數到團隊頻道 (10層, 10層後每5層提示一次)<br/>(需開啟助理權限)"
}

L:SetMiscLocalization{
	LKPull					= "聖光所謂的正義終於來了嗎?我是否該把霜之哀傷放下，祈求你的寬恕呢，弗丁?",
	LKRoleplay				= "你們的原動力真的是正義感嗎?我很懷疑...",
	ValkGrabbedIcon			= "華爾琪影衛{rt%d}抓住了%s",
	ValkGrabbed				= "華爾琪影衛抓住了%s",
	PlagueStackWarning		= "警告: %s中了%d層亡域瘟疫",
	AchievementCompleted	= ">> 成就成功: %s中了%d層亡域瘟疫 <<"
}

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("ICCTrash")

L:SetGeneralLocalization{
	name = "冰冠城塞小怪"
}

L:SetWarningLocalization{
	SpecWarnTrapL		= "觸發陷阱! - 亡縛守衛被釋放了",
	SpecWarnTrapP		= "觸發陷阱! - 復仇的血肉收割者到來",
	SpecWarnGosaEvent	= "辛德拉苟莎夾道攻擊開始!"
}

L:SetOptionLocalization{
	SpecWarnTrapL		= "當觸發陷阱時顯示特別警告",
	SpecWarnTrapP		= "當觸發陷阱時顯示特別警告",
	SpecWarnGosaEvent	= "為辛德拉苟莎夾道攻擊顯示特別警告"
}

L:SetMiscLocalization{
	WarderTrap1			= "誰...在那兒...?",
	WarderTrap2			= "我...甦醒了!",
	WarderTrap3			= "主人的聖所受到了打擾!",
	FleshreaperTrap1	= "快，我們要從後面奇襲他們!",
	FleshreaperTrap2	= "你無法逃避我們!",
	FleshreaperTrap3	= "生人...在此?",
	SindragosaEvent		= "你一定不能靠近冰霜之后。快，阻止他們!"
}

------------------------
--  The Ruby Sanctum  --
------------------------
--  Baltharus the Warborn  --
-----------------------------
L = DBM:GetModLocalization("Baltharus")

L:SetGeneralLocalization({
	name = "『戰爭之子』巴爾薩魯斯"
})

L:SetWarningLocalization({
	WarningSplitSoon	= "分裂即將到來"
})

L:SetOptionLocalization({
	WarningSplitSoon	= "為分裂顯示預先警告"
})

-------------------------
--  Saviana Ragefire  --
-------------------------
L = DBM:GetModLocalization("Saviana")

L:SetGeneralLocalization({
	name = "薩薇安娜‧怒焰"
})

--------------------------
--  General Zarithrian  --
--------------------------
L = DBM:GetModLocalization("Zarithrian")

L:SetGeneralLocalization({
	name = "扎里斯利安將軍"
})

L:SetWarningLocalization({
	WarnAdds	= "新的小怪",
	warnCleaveArmor	= ">%1$s<中了%2$s(%s)"	-- Cleave Armor on >args.destName< (args.amount)
})

L:SetTimerLocalization({
	TimerAdds		= "新的小怪"
})

L:SetOptionLocalization({
	WarnAdds		= "提示新的小怪",
	TimerAdds		= "為新的小怪顯示計時器"
})

L:SetMiscLocalization({
	SummonMinions	= "去吧，將他們挫骨揚灰！"
})

-------------------------------------
--  Halion the Twilight Destroyer  --
-------------------------------------
L = DBM:GetModLocalization("Halion")

L:SetGeneralLocalization({
	name = "海萊恩"
})

L:SetWarningLocalization({
	TwilightCutterCast	= "施放暮光切割: 5秒後"
})

L:SetOptionLocalization({
	TwilightCutterCast	= "當$spell:77844開始施放時顯示警告",
	AnnounceAlternatePhase	= "不管你進不進下一階段一樣顯示警告/計時器"
})

L:SetMiscLocalization({
	Halion				= "海萊恩",
	MeteorCast			= "天堂也將燃燒!",
	Phase2				= "在暮光的國度只有磨難在等著你!有膽量的話就進去吧!",
	Phase3				= "我是光明亦是黑暗!凡人，匍匐在死亡之翼的信使面前吧!",
	twilightcutter		= "這些環繞的球體散發著黑暗能量!",
	Kill				= "享受這場勝利吧，凡人們，因為這是你們最後一次的勝利。這世界將會在主人回歸時化為火海!"
})
