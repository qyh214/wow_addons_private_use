if GetLocale() ~= "zhTW" then return end
local L

------------
-- Skeram --
------------
L = DBM:GetModLocalization("Skeram")

L:SetGeneralLocalization{
	name = "預言者斯克拉姆"
}

----------------
-- Three Bugs --
----------------
L = DBM:GetModLocalization("ThreeBugs")

L:SetGeneralLocalization{
	name = "異種蠍皇族"
}
L:SetMiscLocalization{
	Yauj = "亞爾基公主",
	Vem = "維姆",
	Kri = "克里領主"
}

-------------
-- Sartura --
-------------
L = DBM:GetModLocalization("Sartura")

L:SetGeneralLocalization{
	name = "戰地衛士沙爾圖拉"
}

--------------
-- Fankriss --
--------------
L = DBM:GetModLocalization("Fankriss")

L:SetGeneralLocalization{
	name = "不屈的范克里斯"
}

--------------
-- Viscidus --
--------------
L = DBM:GetModLocalization("Viscidus")

L:SetGeneralLocalization{
	name = "維希度斯"
}
L:SetWarningLocalization{
	WarnFreeze	= "冰凍:%d/3",
	WarnShatter	= "打碎:%d/3"
}
L:SetOptionLocalization{
	WarnFreeze	= "提示冰凍狀態",
	WarnShatter	= "提示打碎狀態"
}
L:SetMiscLocalization{
	Slow	= "開始減速!",
	Freezing= "凍住了",
	Frozen	= "變成冰凍的固體!",
	Phase4 	= "開始爆裂!",
	Phase5 	= "看來準備好毀滅了!",
	Phase6 	= "Explodes."
}
-------------
-- Huhuran --
-------------
L = DBM:GetModLocalization("Huhuran")

L:SetGeneralLocalization{
	name = "哈霍蘭公主"
}
---------------
-- Twin Emps --
---------------
L = DBM:GetModLocalization("TwinEmpsAQ")

L:SetGeneralLocalization{
	name = "雙子帝王"
}
L:SetMiscLocalization{
	Veklor = "維克洛爾大帝",
	Veknil = "維克尼拉斯大帝"
}

------------
-- C'Thun --
------------
L = DBM:GetModLocalization("CThun")

L:SetGeneralLocalization{
	name = "克蘇恩"
}
L:SetWarningLocalization{
	WarnEyeTentacle			= "眼球觸鬚",
	WarnClawTentacle2		= "利爪觸鬚",
	WarnGiantEyeTentacle	= "巨型眼球觸鬚",
	WarnGiantClawTentacle	= "巨型利爪觸鬚",
	WarnWeakened			= "克蘇恩變得虛弱了"
}
L:SetTimerLocalization{
	TimerEyeTentacle		= "下一次眼球觸鬚",
	TimerClawTentacle		= "下一次利爪觸鬚",
	TimerGiantEyeTentacle	= "下一次巨型眼球觸鬚",
	TimerGiantClawTentacle	= "下一次巨型利爪觸鬚",
	TimerWeakened			= "虛弱結束"
}
L:SetOptionLocalization{
	WarnEyeTentacle			= "為眼球觸鬚顯示警告",
	WarnClawTentacle2		= "為利爪觸鬚顯示警告",
	WarnGiantEyeTentacle	= "為巨型眼球觸鬚顯示警告",
	WarnGiantClawTentacle	= "為巨型利爪觸鬚顯示警告",
	SpecWarnWeakened		= "當首領虛弱時顯示特別警告",
	TimerEyeTentacle		= "為下一次眼球觸鬚顯示計時器",
	TimerClawTentacle		= "為下一次利爪觸鬚顯示計時器",
	TimerGiantEyeTentacle	= "為下一次巨型眼球觸鬚顯示計時器",
	TimerGiantClawTentacle	= "為下一次巨型利爪觸鬚顯示計時器",
	TimerWeakened			= "為首領虛弱時間顯示計時器",
	RangeFrame				= "顯示距離框架(10碼)"
}
L:SetMiscLocalization{
	Stomach		= "克蘇恩的胃",
	Eye			= "克蘇恩之眼",
	FleshTent	= "血肉觸鬚",--Localized so it shows on frame in users language, not senders
	Weakened 	= "變弱了",
	NotValid	= "AQ40 擊殺信息： %s 首領未擊殺。"
}
----------------
-- Ouro --
----------------
L = DBM:GetModLocalization("Ouro")

L:SetGeneralLocalization{
	name = "奧羅"
}
L:SetWarningLocalization{
	WarnSubmerge		= "鑽地",
	WarnEmerge			= "現身"
}
L:SetTimerLocalization{
	TimerSubmerge		= "鑽地",
	TimerEmerge			= "現身"
}
L:SetOptionLocalization{
	WarnSubmerge		= "為鑽地顯示警告",
	TimerSubmerge		= "為鑽地顯示計時器",
	WarnEmerge			= "為現身顯示警告",
	TimerEmerge			= "為現身顯示計時器"
}

---------------
-- Kurinnaxx --
---------------
L = DBM:GetModLocalization("Kurinnaxx")

L:SetGeneralLocalization{
	name 		= "庫林納克斯"
}

------------
-- Rajaxx --
------------
L = DBM:GetModLocalization("Rajaxx")

L:SetGeneralLocalization{
	name 		= "拉賈克斯將軍"
}
L:SetWarningLocalization{
	WarnWave	= "進攻波數%s",
}
L:SetOptionLocalization{
	WarnWave	= "為下一次波進攻顯示提示"
}
L:SetMiscLocalization{
	Wave12		= "它們來了。盡量別被它們幹掉，新兵。",
	Wave3		= "我們懲罰的時刻就在眼前!讓黑暗支配敵人的內心吧!",
	Wave4		= "我們不需在被禁堵的門與石牆後等待了!我們的復仇將不再被否認!巨龍將在我們的憤怒之前顫抖!",
	Wave5		= "恐懼是給敵人的!恐懼與死亡!",
	Wave6		= "鹿盔將為了活命而啜泣、乞求，就像他的兒子一樣!一千年的不公將在今日結束!",
	Wave7		= "范達爾!你的時候到了!躲進翡翠夢境祈禱我們永遠不會找到你吧!",
	Wave8		= "厚顏無恥的笨蛋!我要親手殺了你!"
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
	name 		= "『暴食者』布魯"
}
L:SetWarningLocalization{
	WarnPursue		= ">%s<被追擊了",
	SpecWarnPursue	= "你被追擊了",
	WarnDismember	= ">%2$s<中了%1$s(%s)"
}
L:SetOptionLocalization{
	WarnPursue		= "提示被追擊的目標",
	SpecWarnPursue	= "當你被追擊的時候顯示特別警告"
}
L:SetMiscLocalization{
	PursueEmote 	= "%s凝視著%s!"
}

-------------
-- Ayamiss --
-------------
L = DBM:GetModLocalization("Ayamiss")

L:SetGeneralLocalization{
	name 		= "『狩獵者』阿亞米斯"
}

--------------
-- Ossirian --
--------------
L = DBM:GetModLocalization("Ossirian")

L:SetGeneralLocalization{
	name 		= "『無疤者』奧斯里安"
}
L:SetWarningLocalization{
	WarnVulnerable	= "%s"
}
L:SetTimerLocalization{
	TimerVulnerable	= "%s"
}
L:SetOptionLocalization{
	WarnVulnerable	= "提示虛弱",
	TimerVulnerable	= "為虛弱顯示計時器"
}

----------------
-- AQ20 Trash --
----------------
L = DBM:GetModLocalization("AQ20Trash")

L:SetGeneralLocalization{
	name = "AQ20：全程計時"
}

-----------------
--  Razorgore  --
-----------------
L = DBM:GetModLocalization("Razorgore")

L:SetGeneralLocalization{
	name = "狂野的拉佐格爾"
}
L:SetTimerLocalization{
	TimerAddsSpawn	= "小怪重生"
}
L:SetOptionLocalization{
	TimerAddsSpawn	= "為第一次小怪重生顯示計時器"
}
L:SetMiscLocalization{
	Phase2Emote	= "在寶珠的控制力消失之前逃走。",
	YellPull 	= "入侵者闖入孵化室了!警報!不惜一切代價保護蛋!"
}
-------------------
--  Vaelastrasz  --
-------------------
L = DBM:GetModLocalization("Vaelastrasz")

L:SetGeneralLocalization{
	name	= "墮落的瓦拉斯塔茲"
}

L:SetMiscLocalization{
	Event	= "太遲了，朋友! 奈法利斯的腐化已經掌握了我...我已經無法...控制我自己了。"
}
-----------------
--  Broodlord  --
-----------------
L = DBM:GetModLocalization("Broodlord")

L:SetGeneralLocalization{
	name	= "幼龍領主勒西雷爾"
}

L:SetMiscLocalization{
	Pull	= "你怎麼進來的?你們這種生物不能進來!我要毀滅你們!"
}

---------------
--  Firemaw  --
---------------
L = DBM:GetModLocalization("Firemaw")

L:SetGeneralLocalization{
	name = "費爾默"
}

---------------
--  Ebonroc  --
---------------
L = DBM:GetModLocalization("Ebonroc")

L:SetGeneralLocalization{
	name = "埃博諾克"
}

----------------
--  Flamegor  --
----------------
L = DBM:GetModLocalization("Flamegor")

L:SetGeneralLocalization{
	name = "弗萊格爾"
}

-----------------------
--  Vulnerabilities  --
-----------------------
-- Chromaggus, Death Talon Overseer and Death Talon Wyrmguard
L = DBM:GetModLocalization("TalonGuards")

L:SetGeneralLocalization{
	name = "龍人護衛"
}
L:SetWarningLocalization{
	WarnVulnerable		= "%s弱點"
}
L:SetOptionLocalization{
	WarnVulnerable		= "爲法術弱點顯示警告"
}
L:SetMiscLocalization{
	Fire		= "火焰",
	Nature		= "自然",
	Frost		= "冰霜",
	Shadow		= "暗影",
	Arcane		= "祕法",
	Holy		= "神聖"
}

------------------
--  Chromaggus  --
------------------
L = DBM:GetModLocalization("Chromaggus")

L:SetGeneralLocalization{
	name = "克洛瑪古斯"
}
L:SetWarningLocalization{
	WarnBreath		= "%s",
	WarnVulnerable	= "%s弱點"
}
L:SetTimerLocalization{
	TimerBreathCD	= "%s冷卻",
	TimerBreath		= "%s施放",
	TimerVulnCD		= "弱點冷卻"
}
L:SetOptionLocalization{
	WarnBreath		= "為克洛瑪古斯其中一個吐息顯示警告",
	WarnVulnerable	= "爲法術弱點顯示警告",
	TimerBreathCD	= "顯示吐息冷卻",
	TimerBreath		= "顯示吐息施放",
	TimerVulnCD		= "顯示弱點冷卻"
}
L:SetMiscLocalization{
	Breath1	= "第一次吐息",
	Breath2	= "第二次吐息",
	VulnEmote	= "%s因皮膚閃著微光而驚訝退縮。",
	Fire		= "火焰",
	Nature		= "自然",
	Frost		= "冰霜",
	Shadow		= "暗影",
	Arcane		= "祕法",
	Holy		= "神聖"
}

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization("Nefarian-Classic")

L:SetGeneralLocalization{
	name = "奈法利安"
}
L:SetWarningLocalization{
	WarnAddsLeft		= "剩下%d擊殺",
	WarnClassCall		= "%s點名",
	specwarnClassCall    = "你中了職業點名！"
}
L:SetTimerLocalization{
	TimerClassCall		= "%s點名結束"
}
L:SetOptionLocalization{
	TimerClassCall		= "為職業點名持續時間顯示計時器",
	WarnAddsLeft		= "提示離第二階段開始剩多少擊殺",
	WarnClassCall		= "提示職業點名",
	specwarnClassCall	= "特別警告：當你中了職業點名時"
}
L:SetMiscLocalization{
	YellP2		= "幹得好，我的手下。凡人的勇氣開始消退!現在，現在讓我們看看他們如何應對黑石之王的力量!!!",
	YellP3		= "不可能!出現吧，我的僕人!再次為我的主人服務!",
	YellShaman	= "薩滿，讓我看看",
	YellPaladin	= "聖騎士...聽說你有無數條命。讓我看看到底是怎麼樣的吧。",
	YellDruid	= "德魯伊和你們愚蠢的變身術。讓我們看看什麼會發生吧!",
	YellPriest	= "牧師!如果你要繼續這麼治療的話，那我們來玩點有趣的東西!",
	YellWarrior	= "戰士，我知道你的力量不只如此!讓我們來見識一下吧!",
	YellRogue	= "盜賊?不要躲了，面對我吧!",
	YellWarlock	= "術士，不要隨便去玩那些你不理解的法術。看看會發生什麼吧?",
	YellHunter	= "獵人和你那討厭的豌豆射擊!",
	YellMage	= "還有法師?你應該小心使用你的魔法...",
	YellDK		= "死亡騎士們...來這。",
	YellMonk	= "武僧"
}

----------------
--  Lucifron  --
----------------
L = DBM:GetModLocalization("Lucifron")

L:SetGeneralLocalization{
	name = "魯西弗隆"
}

----------------
--  Magmadar  --
----------------
L = DBM:GetModLocalization("Magmadar")

L:SetGeneralLocalization{
	name = "瑪格曼達"
}

----------------
--  Gehennas  --
----------------
L = DBM:GetModLocalization("Gehennas")

L:SetGeneralLocalization{
	name = "基赫納斯"
}

------------
--  Garr  --
------------
L = DBM:GetModLocalization("Garr-Classic")

L:SetGeneralLocalization{
	name = "加爾"
}

--------------
--  Geddon  --
--------------
L = DBM:GetModLocalization("Geddon")

L:SetGeneralLocalization{
	name = "迦頓男爵"
}

----------------
--  Shazzrah  --
----------------
L = DBM:GetModLocalization("Shazzrah")

L:SetGeneralLocalization{
	name = "沙斯拉爾"
}

----------------
--  Sulfuron  --
----------------
L = DBM:GetModLocalization("Sulfuron")

L:SetGeneralLocalization{
	name = "薩弗隆先驅者"
}

----------------
--  Golemagg  --
----------------
L = DBM:GetModLocalization("Golemagg")

L:SetGeneralLocalization{
	name = "『焚化者』古雷曼格"
}

-----------------
--  Majordomo  --
-----------------
L = DBM:GetModLocalization("Majordomo")

L:SetGeneralLocalization{
	name = "管理者埃克索圖斯"
}

----------------
--  Ragnaros  --
----------------
L = DBM:GetModLocalization("Ragnaros-Classic")

L:SetGeneralLocalization{
	name = "拉格納羅斯"
}
L:SetWarningLocalization{
	WarnSubmerge		= "隱沒",
	WarnEmerge			= "現身"
}
L:SetTimerLocalization{
	TimerSubmerge		= "隱沒",
	TimerEmerge			= "現身"
}
L:SetOptionLocalization{
	WarnSubmerge		= "為隱沒顯示警告",
	TimerSubmerge		= "為隱沒顯示計時器",
	WarnEmerge			= "為現身顯示警告",
	TimerEmerge			= "為現身顯示計時器"
}
L:SetMiscLocalization{
	Submerge	= "出現吧，我的奴僕! 保衛你們的主人!",
	Pull		= "你這個莽撞的傢伙!你簡直是自尋死路!看吧，你驚動了主人!"
}

-------------------
--  Venoxis  --
-------------------
L = DBM:GetModLocalization("Venoxis")

L:SetGeneralLocalization{
	name = "高階祭司溫諾希斯"
}

-------------------
--  Jeklik  --
-------------------
L = DBM:GetModLocalization("Jeklik")

L:SetGeneralLocalization{
	name = "高階祭司耶克里克"
}

-------------------
--  Marli  --
-------------------
L = DBM:GetModLocalization("Marli")

L:SetGeneralLocalization{
	name = "高階祭司瑪俐"
}

-------------------
--  Thekal  --
-------------------
L = DBM:GetModLocalization("Thekal")

L:SetGeneralLocalization{
	name = "高階祭司塞卡爾"
}

L:SetWarningLocalization({
	WarnSimulKill	= "大約15秒內複活"
})

L:SetTimerLocalization({
	TimerSimulKill	= "複活術"
})

L:SetOptionLocalization({
	WarnSimulKill	= "通告第一個怪物倒下,馬上將複活",
	TimerSimulKill	= "顯示牧師複活計時器"
})

L:SetMiscLocalization({
	PriestDied	= "%s死了。",
	YellPhase2	= "希瓦拉爾，給我憤怒的力量吧！",
	YellKill	= "哈卡再也不能束縛我了！我終於可以安息了！",
	Thekal		= "高階祭司塞卡爾",
	Zath		= "狂熱者札斯",
	LorKhan		= "狂熱者洛卡恩"
})

-------------------
--  Arlokk  --
-------------------
L = DBM:GetModLocalization("Arlokk")

L:SetGeneralLocalization{
	name = "高階祭司阿洛克"
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
	name = "血領主曼多基爾"
}
L:SetMiscLocalization{
	Bloodlord 	= "血領主曼多基爾",
	Ohgan		= "奧根",
	GazeYell	= "我正在監視你"
}

-------------------
--  Edge of Madness  --
-------------------
L = DBM:GetModLocalization("EdgeOfMadness")

L:SetGeneralLocalization{
	name = "瘋狂之緣"
}
L:SetMiscLocalization{
	Hazzarah = "哈劄拉爾",
	Renataki = "雷納塔基",
	Wushoolay = "烏蘇雷",
	Grilek = "格裏雷克"
}

-------------------
--  Gahz'ranka  --
-------------------
L = DBM:GetModLocalization("Gahzranka")

L:SetGeneralLocalization{
	name = "加茲蘭卡"
}

-------------------
--  Jindo  --
-------------------
L = DBM:GetModLocalization("Jindo")

L:SetGeneralLocalization{
	name = "妖術師金度"
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
	Breath = "%s深深地吸了一口氣...",
	YellPull = "真是幸運。通常我為了覓食就必須離開窩。",
	YellP2 	= "這毫無意義的行動讓我很厭煩。我會從上空把你們都燒成灰！",
	YellP3 	= "看起來需要再給你一次教訓，凡人！"
}

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
	AirowsEnabled			= "顯示箭頭 (正常 \"二邊\" 站位打法)",
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
	SpecialWarningMarkOnPlayer	= "當你印記堆疊多於四層時顯示特別警告"
})

L:SetTimerLocalization({
})

L:SetWarningLocalization({
	WarningMarkSoon			= "3秒後印記 %d",
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
	TimerLanding		= "為降落顯示計時器",
	TimerIceBlast		= "為冰息術顯示計時器",
	WarningDeepBreath	= "為冰息術顯示特別警告"
})

L:SetMiscLocalization({
	EmoteBreath			= "%s深深地吸了一口氣。",
})

L:SetWarningLocalization({
	WarningAirPhaseSoon	= "10秒後 空中階段",
	WarningAirPhaseNow	= "空中階段",
	WarningLanded		= "薩菲隆降落了",
	WarningDeepBreath	= "冰息術"
})

L:SetTimerLocalization({
	TimerAir		= "空中階段",
	TimerLanding	= "降落",
	TimerIceBlast	= "冰息術"
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
