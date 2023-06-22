if GetLocale() ~= "koKR" then return end
local L

------------
-- Skeram --
------------
L = DBM:GetModLocalization("Skeram")

L:SetGeneralLocalization{
	name = "예언자 스케람"
}

----------------
-- Three Bugs --
----------------
L = DBM:GetModLocalization("ThreeBugs")

L:SetGeneralLocalization{
	name = "벌레 무리"
}
L:SetMiscLocalization{
	Yauj	= "공주 야우즈",
	Vem		= "벰",
	Kri		= "군주 크리"
}

-------------
-- Sartura --
-------------
L = DBM:GetModLocalization("Sartura")

L:SetGeneralLocalization{
	name = "전투감시병 살투라"
}

--------------
-- Fankriss --
--------------
L = DBM:GetModLocalization("Fankriss")

L:SetGeneralLocalization{
	name = "불굴의 판크리스"
}
--------------
-- Viscidus --
--------------
L = DBM:GetModLocalization("Viscidus")

L:SetGeneralLocalization{
	name = "비시두스"
}
L:SetWarningLocalization{
	WarnFreeze	= "빙결 : %d/3",
	WarnShatter	= "분해 : %d/3"
}
L:SetOptionLocalization{
	WarnFreeze	= "빙결 알림 보기",
	WarnShatter	= "분해 알림 보기"
}
L:SetMiscLocalization{
	Slow	= "느려지기 시작했습니다!",
	Freezing= "얼어붙고 있습니다!",
	Frozen	= "단단하게 얼었습니다!",
	Phase4 	= "분해되기 시작합니다!",
	Phase5 	= "부서질 것 같습니다!",
	Phase6 	= "폭발"
}
-------------
-- Huhuran --
-------------
L = DBM:GetModLocalization("Huhuran")

L:SetGeneralLocalization{
	name = "공주 후후란"
}
---------------
-- Twin Emps --
---------------
L = DBM:GetModLocalization("TwinEmpsAQ")

L:SetGeneralLocalization{
	name = "쌍둥이 제왕"
}
L:SetMiscLocalization{
	Veklor = "제왕 베클로어",
	Veknil = "제왕 베크닐라쉬"
}

------------
-- C'Thun --
------------
L = DBM:GetModLocalization("CThun")

L:SetGeneralLocalization{
	name = "크툰"
}
L:SetWarningLocalization{
	WarnEyeTentacle			= "눈 달린 촉수",
	WarnClawTentacle2		= "갈고리 촉수",
	TimerGiantEyeTentacle		= "눈 달린 거대한 촉수",
	TimerGiantClawTentacle		= "거대한 발톱 촉수",
	SpecWarnWeakened		= "쑨 약화됨!"
}
L:SetTimerLocalization{
	TimerEyeTentacle		= "눈 달린 촉수",
	TimerClawTentacle		= "갈고리 촉수",
	TimerGiantEyeTentacle		= "눈 달린 거대한 촉수",
	TimerGiantClawTentacle		= "거대한 발톱 촉수",
	TimerWeakened			= "쑨 약화 종료"
}
L:SetOptionLocalization{
	WarnEyeTentacle			= "눈 달린 촉수 경고 보기",
	WarnClawTentacle2		= "갈고리 촉수 경고 보기",
	WarnGiantEyeTentacle		= "눈 달린 거대한 촉수 경고 보기",
	WarnGiantClawTentacle		= "거대한 발톱 촉수 경고 보기",
	SpecWarnWeakened		= "보스 약화시 특수 경고 보기",
	TimerEyeTentacle		= "다음 눈 달린 촉수 타이머 바 보기",
	TimerClawTentacle		= "다음 갈고리 촉수 타이머 바 보기",
	TimerGiantEyeTentacle		= "다음 눈 달린 거대한 촉수 타이머 바 보기",
	TimerGiantClawTentacle		= "다음 거대한 발톱 촉수 타이머 바 보기",
	TimerWeakened			= "보스 약화 지속시간 타이머 바 보기",
	RangeFrame				= "거리 창 보기 (10m)"
}
L:SetMiscLocalization{
	Stomach		= "뱃속",
	Eye			= "쑨의 눈",
	FleshTent	= "식인 촉수",--Localized so it shows on frame in users language, not senders
	Weakened 	= "약해집니다!",
	NotValid	= "안퀴40 레이드를 일부만 클리어 했습니다. 부차적인 네임드가 %s마리 남아있습니다."
}
----------------
-- Ouro --
----------------
L = DBM:GetModLocalization("Ouro")

L:SetGeneralLocalization{
	name = "아우로"
}
L:SetWarningLocalization{
	WarnSubmerge		= "잠수",
	WarnEmerge			= "등장",
}
L:SetTimerLocalization{
	TimerSubmerge		= "다음 잠수",
	TimerEmerge			= "다음 등장"
}
L:SetOptionLocalization{
	WarnSubmerge		= "잠수 알림 보기",
	TimerSubmerge		= "다음 잠수 바 보기",
	WarnEmerge			= "등장 알림 보기",
	TimerEmerge			= "다음 등장 바 보기"
}

---------------
-- Kurinnaxx --
---------------
L = DBM:GetModLocalization("Kurinnaxx")

L:SetGeneralLocalization{
	name 		= "쿠린낙스"
}
------------
-- Rajaxx --
------------
L = DBM:GetModLocalization("Rajaxx")

L:SetGeneralLocalization{
	name 		= "장군 라작스"
}
L:SetWarningLocalization{
	WarnWave	= "공격 #%s"
}
L:SetOptionLocalization{
	WarnWave	= "다음 공격 알림"
}
L:SetMiscLocalization{
	Wave12		= "그들이 오고 있다. 자신의 몸을 지키도록 하라!",
	Wave3		= "응보의 날이 다가왔다! 암흑이 적들의 마음을 지배하리라!",
	Wave4		= "더는 돌벽과 성문 뒤에서 기다릴 수 없다! 복수의 기회를 놓칠 수 없다. 우리가 분노를 터뜨리는 날 용족은 두려움에 떨리라.",
	Wave5		= "적에게 공포와 죽음의 향연을!",
	Wave6		= "스태그헬름은 흐느끼며 목숨을 구걸하리라. 그 아들놈이 그랬던 것처럼! 천 년의 한을 풀리라! 오늘에서야!",
	Wave7		= "판드랄! 때가 왔다! 에메랄드의 꿈속에 숨어서 기도나 올려라!",
	Wave8		= "건방진... 내 친히 너희를 처치해주마!"
}

----------
-- Moam --
----------
L = DBM:GetModLocalization("Moam")

L:SetGeneralLocalization{
	name 		= "모암"
}

----------
-- Buru --
----------
L = DBM:GetModLocalization("Buru")

L:SetGeneralLocalization{
	name 		= "먹보 부루"
}
L:SetWarningLocalization{
	WarnPursue		= "추적 : >%s<",
	SpecWarnPursue	= "당신을 추적!",
	WarnDismember	= "%s : >%s< (%s)"
}
L:SetOptionLocalization{
	WarnPursue		= "추적 대상 알림 보기",
	SpecWarnPursue	= "추적 대상이 된 경우 특수 경고 보기"
}
L:SetMiscLocalization{
	PursueEmote 	= "노려봅니다!"
}

-------------
-- Ayamiss --
-------------
L = DBM:GetModLocalization("Ayamiss")

L:SetGeneralLocalization{
	name 		= "사냥꾼 아야미스"
}

--------------
-- Ossirian --
--------------
L = DBM:GetModLocalization("Ossirian")

L:SetGeneralLocalization{
	name 		= "무적의 오시리안"
}
L:SetWarningLocalization{
	WarnVulnerable	= "%s"
}
L:SetTimerLocalization{
	TimerVulnerable	= "%s"
}
L:SetOptionLocalization{
	WarnVulnerable	= "약화 알림 보기",
	TimerVulnerable	= "약화 바 보기"
}

----------------
-- AQ20 Trash --
----------------
L = DBM:GetModLocalization("AQ20Trash")

L:SetGeneralLocalization{
	name = "안퀴20 일반몹"
}

-----------------
--  Razorgore  --
-----------------
L = DBM:GetModLocalization("Razorgore")

L:SetGeneralLocalization{
	name = "폭군 서슬송곳니"
}
L:SetTimerLocalization{
	TimerAddsSpawn	= "추가 병력 등장"
}
L:SetOptionLocalization{
	TimerAddsSpawn	= "첫번째 추가 병력 등장 바 보기"
}
L:SetMiscLocalization{
	Phase2Emote	= "지배의 수정구가 힘을 잃고 작동을 멈춥니다!",
	YellPull 	= "침입자들이 들어왔다! 어떤 희생이 있더라도 알을 반드시 수호하라!"
}
-------------------
--  Vaelastrasz  --
-------------------
L = DBM:GetModLocalization("Vaelastrasz")

L:SetGeneralLocalization{
	name = "타락한 밸라스트라즈"
}

L:SetMiscLocalization{
	Event	= "너무 늦었어! 네파리우스의 타락이 뿌리를 내려... 난... 나 자신을 통제할 수가 없어."
}
-----------------
--  Broodlord  --
-----------------
L = DBM:GetModLocalization("Broodlord")

L:SetGeneralLocalization{
	name = "용기대장 래쉬레이어"
}

L:SetMiscLocalization{
	Pull	= "너희 같은 놈들이 올 곳은 아닌데... 죽음을 자초했구나!"
}

---------------
--  Firemaw  --
---------------
L = DBM:GetModLocalization("Firemaw")

L:SetGeneralLocalization{
	name = "화염아귀"
}

---------------
--  Ebonroc  --
---------------
L = DBM:GetModLocalization("Ebonroc")

L:SetGeneralLocalization{
	name = "에본로크"
}

----------------
--  Flamegor  --
----------------
L = DBM:GetModLocalization("Flamegor")

L:SetGeneralLocalization{
	name = "플레임고르"
}

-----------------------
--  Vulnerabilities  --
-----------------------
-- Chromaggus, Death Talon Overseer and Death Talon Wyrmguard
L = DBM:GetModLocalization("TalonGuards")

L:SetGeneralLocalization{
	name = "죽음의발톱 수호병"
}
L:SetWarningLocalization{
	WarnVulnerable		= "%s 약화"
}
L:SetOptionLocalization{
	WarnVulnerable		= "주문 속성 약화 경고 보기"
}
L:SetMiscLocalization{
	Fire		= "화염",
	Nature		= "자연",
	Frost		= "냉기",
	Shadow		= "암흑",
	Arcane		= "비전",
	Holy		= "신성"
}

------------------
--  Chromaggus  --
------------------
L = DBM:GetModLocalization("Chromaggus")

L:SetGeneralLocalization{
	name = "크로마구스"
}
L:SetWarningLocalization{
	WarnVulnerable	= "%s 약화"
}
L:SetTimerLocalization{
	TimerBreathCD	= "%s 쿨타임",
	TimerBreath		= "%s 시전",
	TimerVulnCD		= "약화 쿨타임"
}
L:SetOptionLocalization{
	WarnBreath		= "크로마구스가 숨결 시전 시 경고 보기",
	WarnVulnerable	= "주문 속성 약화 경고 보기",
	TimerBreathCD	= "숨결 쿨타임 보기",
	TimerBreath		= "숨결 시전 보기",
	TimerVulnCD		= "약화 쿨타임 보기"
}
L:SetMiscLocalization{
	Breath1	= "1번 숨결",
	Breath2	= "2번 숨결",
	VulnEmote	= "%s 주춤하면서 물러나면서 가죽이 빛납니다.",
	Vuln		= "약화 속성",
	Fire		= "화염",
	Nature		= "자연",
	Frost		= "냉기",
	Shadow		= "암흑",
	Arcane		= "비전",
	Holy		= "신성"
}

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization("Nefarian-Classic")

L:SetGeneralLocalization{
	name = "네파리안"
}
L:SetWarningLocalization{
	WarnAddsLeft		= "%d킬 남음",
	WarnClassCall		= "%s 지목",
	specwarnClassCall	= "당신이 직업 지목 대상입니다!"
}
L:SetTimerLocalization{
	TimerClassCall		= "%s 지목 종료"
}
L:SetOptionLocalization{
	TimerClassCall		= "직업 지목 지속 시간 타이머 바 보기",
	WarnAddsLeft		= "2페이즈 전환까지 남은 쫄 킬 수 알림",
	WarnClassCall		= "직업 지목 알림 보기",
	specwarnClassCall	= "직업 지목 대상일 때 특수 알림 보기"
}
L:SetMiscLocalization{
	YellP2			= "잘했다! 적들의 사기가 떨어지고 있다! 검은바위 첨탑의 군주에게 도전한 대가를 치르게 해주자!",
	YellP3			= "말도 안 돼! 일어나라! 다시 한 번 너희 주인을 섬겨라!",
	YellShaman		= "주술사",
	YellPaladin		= "성기사",
	YellDruid		= "드루이드",
	YellPriest		= "사제",
	YellWarrior		= "전사",
	YellRogue		= "도적",
	YellWarlock		= "흑마법사",
	YellHunter		= "사냥꾼",
	YellMage		= "마법사",
	YellDeathKnight	= "죽음의 기사",
	YellMonk		= "수도사"
}

----------------
--  Lucifron  --
----------------
L = DBM:GetModLocalization("Lucifron")

L:SetGeneralLocalization{
	name = "루시프론"
}

----------------
--  Magmadar  --
----------------
L = DBM:GetModLocalization("Magmadar")

L:SetGeneralLocalization{
	name = "마그마다르"
}

----------------
--  Gehennas  --
----------------
L = DBM:GetModLocalization("Gehennas")

L:SetGeneralLocalization{
	name = "게헨나스"
}

------------
--  Garr  --
------------
L = DBM:GetModLocalization("Garr-Classic")

L:SetGeneralLocalization{
	name = "가르"
}

--------------
--  Geddon  --
--------------
L = DBM:GetModLocalization("Geddon")

L:SetGeneralLocalization{
	name = "남작 게돈"
}

----------------
--  Shazzrah  --
----------------
L = DBM:GetModLocalization("Shazzrah")

L:SetGeneralLocalization{
	name = "샤즈라"
}

----------------
--  Sulfuron  --
----------------
L = DBM:GetModLocalization("Sulfuron")

L:SetGeneralLocalization{
	name = "설퍼론 사자"
}

----------------
--  Golemagg  --
----------------
L = DBM:GetModLocalization("Golemagg")

L:SetGeneralLocalization{
	name = "초열의 골레마그"
}

-----------------
--  Majordomo  --
-----------------
L = DBM:GetModLocalization("Majordomo")

L:SetGeneralLocalization{
	name = "청지기 이그젝큐투스"
}

----------------
--  Ragnaros  --
----------------
L = DBM:GetModLocalization("Ragnaros-Classic")

L:SetGeneralLocalization{
	name = "라그나로스"
}
L:SetWarningLocalization{
	WarnSubmerge		= "잠수",
	WarnEmerge			= "등장"
}
L:SetTimerLocalization{
	TimerSubmerge		= "다음 잠수",
	TimerEmerge			= "다음 등장"
}
L:SetOptionLocalization{
	WarnSubmerge		= "잠수 알림 보기",
	TimerSubmerge		= "다음 잠수 바 보기",
	WarnEmerge			= "등장 알림 보기",
	TimerEmerge			= "다음 등장 바 보기"
}
L:SetMiscLocalization{
	Submerge	= "나의 종들아! 어서 나와 주인을 돕거라!",
	Pull		= "건방진 젖먹이! 죽고 싶어 안달이구나! 자, 보아라. 주인님께서 일어나신다!"
}

-------------------
--  Venoxis  --
-------------------
L = DBM:GetModLocalization("Venoxis")

L:SetGeneralLocalization{
	name = "대사제 베녹시스"
}

-------------------
--  Jeklik  --
-------------------
L = DBM:GetModLocalization("Jeklik")

L:SetGeneralLocalization{
	name = "대여사제 제클릭"
}

-------------------
--  Marli  --
-------------------
L = DBM:GetModLocalization("Marli")

L:SetGeneralLocalization{
	name = "대여사제 말리"
}

-------------------
--  Thekal  --
-------------------
L = DBM:GetModLocalization("Thekal")

L:SetGeneralLocalization{
	name = "대사제 데칼"
}

L:SetWarningLocalization({
	WarnSimulKill	= "첫 쫄 잡음 - 약 15초 후 부활"
})

L:SetTimerLocalization({
	TimerSimulKill	= "부활"
})

L:SetOptionLocalization({
	WarnSimulKill	= "첫 쫄이 잡히면 잠시 후 부활 알림",
	TimerSimulKill	= "사제 부활 타이머 바 보기"
})

L:SetMiscLocalization({
	PriestDied	= "%s 죽었습니다.",
	YellPhase2	= "시르밸라시여, 분노를 채워 주소서!",
	YellKill	= "학카르의 구속이 끝났다! 이젠 평안히 잠들리라!",
	Thekal		= "대사제 데칼",
	Zath		= "광신도 자스",
	LorKhan		= "광신도 로르칸"
})

-------------------
--  Arlokk  --
-------------------
L = DBM:GetModLocalization("Arlokk")

L:SetGeneralLocalization{
	name = "대여사제 알로크"
}

-------------------
--  Hakkar  --
-------------------
L = DBM:GetModLocalization("Hakkar")

L:SetGeneralLocalization{
	name = "영혼약탈자 학카르"
}

-------------------
--  Bloodlord  --
-------------------
L = DBM:GetModLocalization("Bloodlord")

L:SetGeneralLocalization{
	name = "혈군주 만도키르"
}
L:SetMiscLocalization{
	Bloodlord 	= "혈군주 만도키르",
	Ohgan		= "오간"
}

-------------------
--  Edge of Madness  --
-------------------
L = DBM:GetModLocalization("EdgeOfMadness")

L:SetGeneralLocalization{
	name = "광란의 경계"
}
L:SetMiscLocalization{
	Hazzarah = "하자라",
	Renataki = "레나타키",
	Wushoolay = "우슐레이",
	Grilek = "그리렉"
}

-------------------
--  Gahz'ranka  --
-------------------
L = DBM:GetModLocalization("Gahzranka")

L:SetGeneralLocalization{
	name = "가즈란카"
}

-------------------
--  Jindo  --
-------------------
L = DBM:GetModLocalization("Jindo")

L:SetGeneralLocalization{
	name = "주술사 진도"
}

--------------
--  Onyxia  --
--------------
L = DBM:GetModLocalization("Onyxia")

L:SetGeneralLocalization{
	name = "오닉시아"
}

L:SetWarningLocalization{
	WarnWhelpsSoon		= "곧 오닉시아 새끼용 등장"
}

L:SetTimerLocalization{
	TimerWhelps 		= "오닉시아 새끼용"
}

L:SetOptionLocalization{
	TimerWhelps				= "오닉시아 새끼용 등장 타이머 바 보기",
	WarnWhelpsSoon			= "오닉시아 새끼용 등장 사전 경고 보기",
	SoundWTF3				= "전설적인 오닉시아 레이드 영상에서 추출한 재미있는 효과음 재생"
}

L:SetMiscLocalization{
	Breath 		= "%s 숨을 깊게 들이쉽니다.",
	YellPull 	= "오늘은 운이 아주 좋군. 평소엔 먹이를 찾으려면 둥지에서 나가야 하는데 말이야.",
	YellP2 		= "쓸데없이 힘을 쓰는 것도 지루하군. 네 녀석들 머리 위에서 모조리 불살라 주마!",
	YellP3 		= "혼이 더 나야 정신을 차리겠구나!"
}

-------------------
--  아눕레칸     --
-------------------
L = DBM:GetModLocalization("Anub'Rekhan")

L:SetGeneralLocalization({
	name = "아눕레칸"
})

L:SetOptionLocalization({
	ArachnophobiaTimer	= "거미의 공포 타이머 바 보기 (업적)"
})


L:SetMiscLocalization({
	ArachnophobiaTimer	= "거미의 공포",
	Pull1				= "그래, 도망쳐! 더 신선한 피가 솟구칠 테니!",
	Pull2				= "어디 맛 좀 볼까..."
})

---------------------
--  귀부인 펠리나  --
---------------------
L = DBM:GetModLocalization("Faerlina")

L:SetGeneralLocalization({
	name = "귀부인 펠리나"
})

L:SetWarningLocalization({
	WarningEmbraceExpire	= "5초 후 귀부인의 은총 종료",
	WarningEmbraceExpired	= "귀부인의 은총 종료"
})

L:SetOptionLocalization({
	WarningEmbraceExpire	= "귀부인의 은총 종료 사전 경고 보기",
	WarningEmbraceExpired	= "귀부인의 은총 종료 경고 보기"
})

L:SetMiscLocalization({
	Pull					= "내 앞에 무릎을 꿇어라, 벌레들아!"
})

---------------
--  맥스나   --
---------------
L = DBM:GetModLocalization("Maexxna")

L:SetGeneralLocalization({
	name = "맥스나"
})

L:SetWarningLocalization({
	WarningSpidersSoon	= "5초 후 맥스나의 새끼 거미",
	WarningSpidersNow	= "맥스나의 새끼 거미"
})

L:SetTimerLocalization({
	TimerSpider		= "다음 맥스나의 새끼 거미"
})

L:SetOptionLocalization({
	WarningSpidersSoon	= "맥스나의 새끼 거미 사전 경고 보기",
	WarningSpidersNow	= "맥스나의 새끼 거미 경고 보기",
	TimerSpider			= "다음 맥스나의 새끼 거미 타이머 바 보기"
})

L:SetMiscLocalization({
	ArachnophobiaTimer	= "거미의 공포"
})

---------------------
--  역병술사 노스  --
---------------------
L = DBM:GetModLocalization("Noth")

L:SetGeneralLocalization({
	name = "역병술사 노스"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "순간이동",
	WarningTeleportSoon	= "20초 후 순간이동"
})

L:SetTimerLocalization({
	TimerTeleport		= "순간이동",
	TimerTeleportBack	= "방으로 복귀"
})

L:SetOptionLocalization({
	WarningTeleportNow		= "순간이동 경고 보기",
	WarningTeleportSoon		= "순간이동 사전 경고 보기",
	TimerTeleport			= "순간이동 타이머 바 보기",
	TimerTeleportBack		= "방으로 복귀 타이머 바 보기"
})

L:SetMiscLocalization({
	Pull				= "죽어라, 침입자들아!",
	AddsYell			= "일어나라, 병사들이여! 다시 일어나 싸워라!",
--	Adds				= "summons forth Skeletal Warriors!",
--	AddsTwo				= "raises more skeletons!"
})

--------------------------
--  부정의 헤이건  --
--------------------------
L = DBM:GetModLocalization("Heigan")

L:SetGeneralLocalization({
	name = "부정의 헤이건"
})

L:SetWarningLocalization({
	WarningTeleportNow	= "순간이동",
	WarningTeleportSoon	= "%d초 후 순간이동"
})

L:SetTimerLocalization({
	TimerTeleport		= "순간이동"
})

L:SetOptionLocalization({
	WarningTeleportNow		= "순간이동 경고 보기",
	WarningTeleportSoon		= "순간이동 사전 경고 보기",
	TimerTeleport			= "순간이동 타이머 바 보기"
})

L:SetMiscLocalization({
	Pull				= "이제 넌 내 것이다."
})

----------------
--  로데브  --
----------------
L = DBM:GetModLocalization("Loatheb")

L:SetGeneralLocalization({
	name = "로데브"
})

L:SetWarningLocalization({
	WarningHealSoon		= "3초 후 치유 가능",
	WarningHealNow		= "힐 하세요"
})

L:SetOptionLocalization({
	WarningHealSoon		= "3초 치유 가능 시간 사전 경고 보기",
	WarningHealNow		= "3초 치유 가능 시간 경고 보기"
})

-----------------
--  패치워크  --
-----------------
L = DBM:GetModLocalization("Patchwerk")

L:SetGeneralLocalization({
	name = "패치워크"
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yell1			= "패치워크랑 놀아줘!",
	yell2			= "켈투자드님이 패치워크 싸움꾼으로 만들었다."
})

-----------------
--  그라불루스  --
-----------------
L = DBM:GetModLocalization("Grobbulus")

L:SetGeneralLocalization({
	name = "그라불루스"
})

-------------
--  글루스  --
-------------
L = DBM:GetModLocalization("Gluth")

L:SetGeneralLocalization({
	name = "글루스"
})

----------------
--  타디우스  --
----------------
L = DBM:GetModLocalization("Thaddius")

L:SetGeneralLocalization({
	name = "타디우스"
})

L:SetMiscLocalization({
	Yell	= "스탈라그, 박살낸다!",
	Emote	= "%s 과부하 상태가 됩니다.",
	Emote2	= "테슬라 코일이 과부하 상태가 됩니다.",
	Boss1	= "퓨진",
	Boss2	= "스탈라그",
	Charge1	= "음전하",
	Charge2	= "양전하"
})

L:SetOptionLocalization({
	WarningChargeChanged	= "극성이 바뀔때 특수 알림 보기",
	WarningChargeNotChanged	= "극성이 바뀌지 않으면 특수 알림 보기",
	AirowsEnabled			= "$spell:28089 동안 화살표 보기",
	TwoCamp					= "화살표 보기 (일반 \"2점\" 택틱)",
	ArrowsRightLeft			= "\"4점\" 택틱 왼쪽/오른쪽 화살표 보기 (극성이 바뀌면 왼쪽 화살표가 나오고 바뀌지 않으면 오른쪽이 나옴)",
	ArrowsInverse			= "역 \"4점\" 택틱 (극성이 바뀌면 오른쪽 화살표가 나오고 바뀌지 않으면 왼쪽이 나옴)"
})

L:SetWarningLocalization({
	WarningChargeChanged	= "극성 변경: %s",
	WarningChargeNotChanged	= "극성 변경 안됨"
})

---------------------------
--  훈련교관 라주비어스  --
---------------------------
L = DBM:GetModLocalization("Razuvious")

L:SetGeneralLocalization({
	name = "훈련교관 라주비어스"
})

L:SetMiscLocalization({
	Yell1 = "절대 봐주지 마라!",
	Yell2 = "훈련은 끝났다! 배운 걸 보여줘라!",
	Yell3 = "훈련받은 대로 해!",
	Yell4 = "다리를 후려 차라! 무슨 문제 있나?"
})

L:SetOptionLocalization({
	WarningShieldWallSoon	= "뼈 보호막 종료 사전 경고 보기"
})

L:SetWarningLocalization({
	WarningShieldWallSoon	= "뼈 보호막 종료 5초 전"
})

------------------------
--  영혼 착취자 고딕  --
------------------------
L = DBM:GetModLocalization("Gothik")

L:SetGeneralLocalization({
	name = "영혼 착취자 고딕"
})

L:SetOptionLocalization({
	TimerWave			= "다음 병력 타이머 바 보기",
	TimerPhase2			= "2단계 타이머 바 보기",
	WarningWaveSoon		= "병력 사전 경고 보기",
	WarningWaveSpawned	= "병력 등장시 경고 보기",
	WarningRiderDown	= "무자비한 죽음의 기병을 잡으면 경고 보기",
	WarningKnightDown	= "무자비한 죽음의 기사를 잡으면 경고 보기"
})

L:SetTimerLocalization({
	TimerWave	= "%d번 병력",
	TimerPhase2	= "2단계"
})

L:SetWarningLocalization({
	WarningWaveSoon		= "%d번 병력: %s 3초 전",
	WarningWaveSpawned	= "%d번 병력: %s",
	WarningRiderDown	= "기병 잡음",
	WarningKnightDown	= "기사 잡음",
	WarningPhase2		= "2단계"
})

L:SetMiscLocalization({
	yell			= "어리석은 것들, 스스로 죽음을 자초하다니!",
	WarningWave2	= "%d %s, %d %s",
	WarningWave3	= "%d %s, %d %s, %d %s",
	Trainee			= "수련생",
	Knight			= "기사",
	Horse			= "말 망령",
	Rider			= "기병"
})

--------------------
--  4인의 기사단  --
--------------------
L = DBM:GetModLocalization("Horsemen")

L:SetGeneralLocalization({
	name = "4인의 기사단"
})

L:SetOptionLocalization({
	WarningMarkSoon				= "징표 사전 경고 보기",
	SpecialWarningMarkOnPlayer	= "징표가 4개 이상 걸리면 특수 알림 보기",
	timerMark					= "다음 기사의 징표 타이머 바 보기 (횟수 포함)",
})

L:SetWarningLocalization({
	timerMark	= "%d번 징표",
})

L:SetWarningLocalization({
	WarningMarkSoon				= "3초 후 %d번 징표",
})

L:SetMiscLocalization({
	Korthazz	= "영주 코스아즈",
	Rivendare	= "남작 리븐데어",
	Blaumeux	= "여군주 블라미우스",
	Zeliek		= "젤리에크 경"
})

--------------
--  사피론  --
--------------
L = DBM:GetModLocalization("Sapphiron")

L:SetGeneralLocalization({
	name = "사피론"
})

L:SetOptionLocalization({
	WarningAirPhaseSoon		= "비행 단계 사전 경고 보기",
	WarningAirPhaseNow		= "비행 단계 알림 보기",
	WarningLanded			= "지상 단계 알림 보기",
	TimerAir				= "비행 단계 타이머 바 보기",
	TimerLanding			= "착지 중 타이머 바 보기",
	TimerIceBlast			= "냉기 숨결 타이머 바 보기",
	WarningDeepBreath		= "냉기 숨결 특수 알림 보기"
})

L:SetMiscLocalization({
	EmoteBreath				= "숨을 깊게 들이마십니다."
})

L:SetWarningLocalization({
	WarningAirPhaseSoon		= "비행 단계 10초 전",
	WarningAirPhaseNow		= "비행 단계",
	WarningLanded			= "사피론 내려옴",
	WarningDeepBreath		= "냉기 숨결"
})

L:SetTimerLocalization({
	TimerAir				= "비행 단계",
	TimerLanding			= "착지 중",
	TimerIceBlast			= "냉기 숨결"
})

------------------
--  켈투자드  --
------------------
L = DBM:GetModLocalization("Kel'Thuzad")

L:SetGeneralLocalization({
	name = "켈투자드"
})

L:SetOptionLocalization({
	TimerPhase2			= "2단계 타이머 바 보기",
	specwarnP2Soon		= "켈투자드 전투 개시 10초 전에 특수 알림 보기",
	warnAddsSoon		= "얼음왕관의 수호자 사전 경고 보기"
})

L:SetMiscLocalization({
	Yell 				= "어둠의 문지기와 하수인, 그리고 병사들이여! 나 켈투자드가 부르니 명을 받들라!"
})

L:SetWarningLocalization({
	specwarnP2Soon		= "10초 후 켈투자드 전투 개시",
	warnAddsSoon		= "곧 얼음왕관의 수호자 등장"
})

L:SetTimerLocalization({
	TimerPhase2			= "2단계"
})
