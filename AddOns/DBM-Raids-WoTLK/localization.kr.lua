if GetLocale() ~= "koKR" then return end

local L

----------------------------------
--  Archavon the Stone Watcher  --
----------------------------------
L = DBM:GetModLocalization("Archavon")

L:SetGeneralLocalization({
	name = "바위 감시자 아카본"
})

L:SetWarningLocalization({
	WarningGrab		= "아카본이 >%s<에게 돌진"
})

L:SetTimerLocalization({
	ArchavonEnrage	= "아카본 광폭화"
})

L:SetMiscLocalization({
	TankSwitch 		= "(%S+)에게 돌진합니다!"
})

L:SetOptionLocalization({
	WarningGrab 	= "돌진 대상 알림",
	ArchavonEnrage	= "$spell:26662 타이머 바 보기"
})

--------------------------------
--  Emalon the Storm Watcher  --
--------------------------------
L = DBM:GetModLocalization("Emalon")

L:SetGeneralLocalization{
	name = "폭풍의 감시자 에말론"
}

L:SetTimerLocalization{
	timerMobOvercharge	= "과충전 폭발",
	EmalonEnrage		= "에말론 광폭화"
}

L:SetOptionLocalization{
	timerMobOvercharge	= "과충전된 몹 (디버프 중첩) 타이머 바 보기",
	EmalonEnrage		= "$spell:26662 타이머 바 보기"
}

---------------------------------
--  Koralon the Flame Watcher  --
---------------------------------
L = DBM:GetModLocalization("Koralon")

L:SetGeneralLocalization{
	name = "화염 감시자 코랄론"
}

L:SetTimerLocalization{
	KoralonEnrage		= "코랄론 광폭화"
}

L:SetOptionLocalization{
	KoralonEnrage		= "$spell:26662 타이머 바 보기"
}

L:SetMiscLocalization{
	Meteor	= "유성 주먹을 시전합니다!"
}

-------------------------------
--  Toravon the Ice Watcher  --
-------------------------------
L = DBM:GetModLocalization("Toravon")

L:SetGeneralLocalization{
	name = "얼음 감시자 토라본"
}

L:SetTimerLocalization{
	ToravonEnrage	= "토라본 광폭화"
}

L:SetMiscLocalization{
	ToravonEnrage	= "광폭화 타이머 바 보기"
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
	Pull					= "내 앞에 무릎을 꿇어라, 벌레들아!"--Not actually pull trigger, but often said on pull
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
	Pull				= "죽어라, 침입자들아!"
	--Adds				= "summons forth Skeletal Warriors!",
	--AddsTwo				= "raises more skeletons!"
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
	WarningHealSoon		= "3초 후 힐 가능",
	WarningHealNow		= "힐 시작"
})

L:SetOptionLocalization({
	WarningHealSoon		= "3초 힐 구간 사전 경고 보기",
	WarningHealNow		= "3초 힐 구간 경고 보기"
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
	yell1 =			"패치워크랑 놀아줘!",
	yell2 =			"켈투자드님이 패치워크 싸움꾼으로 만들었다."
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
	ArrowsEnabled			= "$spell:28089 동안 화살표 보기",
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
	WarningShieldWallSoon	= "5초 후 뼈 보호막 종료"
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
	WarningMarkNow				= "징표 경고 보기",
	SpecialWarningMarkOnPlayer	= "징표가 4개 이상 걸리면 특수 알림 보기",
	timerMark					= "다음 기사의 징표 타이머 바 보기 (횟수 포함)",
})

L:SetTimerLocalization({
	timerMark	= "%d번 징표"
})

L:SetWarningLocalization({
	WarningMarkSoon				= "3초 후 징표 #%d",
	WarningMarkNow				= "징표 #%d",
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
	WarningAirPhaseSoon		= "공중 단계 사전 경고 보기",
	WarningAirPhaseNow		= "공중 단계 알림",
	WarningLanded			= "지상 단계 알림",
	TimerAir				= "공중 단계 타이머 바 보기",
	TimerLanding			= "착륙 타이머 바 보기"
})

L:SetMiscLocalization({
	EmoteBreath				= "숨을 깊게 들이마십니다."
})

L:SetWarningLocalization({
	WarningAirPhaseSoon		= "10초 후 공중 단계",
	WarningAirPhaseNow		= "공중 단계",
	WarningLanded			= "사피론 착륙"

})

L:SetTimerLocalization({
	TimerAir				= "공중 단계",
	TimerLanding			= "착륙"
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

----------------------------
--  The Obsidian Sanctum  --
----------------------------
--  샤드론  --
---------------
L = DBM:GetModLocalization("Shadron")

L:SetGeneralLocalization({
	name = "샤드론"
})

---------------
--  테네브론  --
---------------
L = DBM:GetModLocalization("Tenebron")

L:SetGeneralLocalization({
	name = "테네브론"
})

---------------
--  베스페론  --
---------------
L = DBM:GetModLocalization("Vesperon")

L:SetGeneralLocalization({
	name = "베스페론"
})

---------------
--  살타리온  --
---------------
L = DBM:GetModLocalization("Sartharion")

L:SetGeneralLocalization({
	name = "살타리온"
})

L:SetWarningLocalization({
	WarningTenebron			= "테네브론 등장",
	WarningShadron			= "샤드론 등장",
	WarningVesperon			= "베스페론 등장",
	WarningFireWall			= "용암 파도",
	WarningVesperonPortal	= "베스페론의 차원문",
	WarningTenebronPortal	= "테네브론의 차원문",
	WarningShadronPortal	= "샤드론의 차원문"
})

L:SetTimerLocalization({
	TimerTenebron		= "테네브론 도착",
	TimerShadron		= "샤드론 도착",
	TimerVesperon		= "베스페론 도착"
})

L:SetOptionLocalization({
	AnnounceFails			= "용암 파도와 어둠의 균열을 맞은 공대원을 공격대 대화로 알림 (승급 권한 필요)",
	TimerTenebron			= "테네브론 도착 타이머 바 보기",
	TimerShadron			= "샤드론 도착 타이머 바 보기",
	TimerVesperon			= "베스페론 도착 타이머 바 보기",
	WarningFireWall			= "용암 파도 특수 알림 보기",
	WarningTenebron			= "테네브론 등장 알림",
	WarningShadron			= "샤드론 등장 알림",
	WarningVesperon			= "베스페론 등장 알림",
	WarningTenebronPortal	= "테네브론의 차원문 특수 알림 보기",
	WarningShadronPortal	= "샤드론의 차원문 특수 알림 보기",
	WarningVesperonPortal	= "베스페론의 차원문 특수 알림 보기"
})

L:SetMiscLocalization({
	Wall			= "%s|1을;를; 둘러싼 용암이 끓어오릅니다!",
	Portal			= "%s|1이;가; 황혼의 차원문을 엽니다!!",
	NameTenebron	= "테네브론",
	NameShadron		= "샤드론",
	NameVesperon	= "베스페론",
	FireWallOn		= "용암 파도: %s",
	VoidZoneOn		= "어둠의 균열: %s",
	VoidZones		= "어둠의 균열 맞은 사람 (이번 트라이): %s",
	FireWalls		= "용암 파도 맞은 사람 (이번 트라이): %s"
})

---------------
--  Malygos  --
---------------
L = DBM:GetModLocalization("Malygos")

L:SetGeneralLocalization({
	name = "말리고스"
})

L:SetMiscLocalization({
	YellPull		= "더는 참을 수가 없구나. 다 없애 버리겠다!",
	EmoteSpark		= "마력의 불꽃이 근처에 있는 틈에서 올라옵니다!",
	YellPhase2		= "되도록 빨리 끝내 주고 싶었다만",
	YellBreath		= "내가 숨 쉬는 한, 너희는 이길 수 없다!",
	YellPhase3		= "네놈들의 후원자가 나타났구나"
})

-----------------------
--  Flame Leviathan  --
-----------------------
L = DBM:GetModLocalization("FlameLeviathan")

L:SetGeneralLocalization{
	name = "거대 화염전차"
}

L:SetMiscLocalization{
	YellPull				= "적대적인 존재 감지. 위협 수준 평가 체제 가동. 주 목표물과 교전. 위협 수준 재평가까지 30초.",
	Emote					= "%%s|1이;가; (%S+)%|1을;를; 쫓습니다."
}

L:SetWarningLocalization{
	PursueWarn				= ">%s< 추적중",
	warnNextPursueSoon		= "5초 후 추적 대상 변경",
	SpecialPursueWarnYou	= "당신이 추적 대상입니다 - 도망치세요",
	warnWardofLife			= "생명지기 덩굴손 등장"
}

L:SetOptionLocalization{
	SpecialPursueWarnYou	= "$spell:62374 대상이 됐을 때 특수 알림 보기",
	PursueWarn				= "$spell:62374 대상 알림",
	warnNextPursueSoon		= "다음 $spell:62374 사전 경고 보기",
	warnWardofLife			= "생명지기 덩굴손 등장 특수 알림 보기"
}

--------------------------------
--  Ignis the Furnace Master  --
--------------------------------
L = DBM:GetModLocalization("Ignis")

L:SetGeneralLocalization{
	name = "용광로 군주 이그니스"
}

------------------
--  Razorscale  --
------------------
L = DBM:GetModLocalization("Razorscale")

L:SetGeneralLocalization{
	name = "칼날비늘"
}

L:SetWarningLocalization{
	warnTurretsReadySoon		= "20초 후 마지막 포탑 준비",
	warnTurretsReady			= "마지막 포탑 준비"
}

L:SetTimerLocalization{
	timerTurret1			= "포탑 1",
	timerTurret2			= "포탑 2",
	timerTurret3			= "포탑 3",
	timerTurret4			= "포탑 4",
	timerGrounded			= "지상 착륙"
}

L:SetOptionLocalization{
	warnTurretsReadySoon		= "포탑 사전 경고 보기",
	warnTurretsReady			= "포탑 경고 보기",
	timerTurret1				= "포탑 1 타이머 바 보기",
	timerTurret2				= "포탑 2 타이머 바 보기",
	timerTurret3				= "포탑 3 타이머 바 보기 (25인 클래식 또는 최신 확장팩)",
	timerTurret4				= "포탑 4 타이머 바 보기 (25인 클래식 또는 최신 확장팩)",
	timerGrounded				= "지상 단계 지속 시간 타이머 바 보기"
}

L:SetMiscLocalization{
	YellAir 			= "저희에게 잠깐 포탑을 설치할 시간을 주세요.",
	YellAir2			= "불꽃이 꺼졌습니다! 포탑을 재설치합시다!",
	YellGround			= "움직이세요! 오래 붙잡아둘 순 없을 겁니다!",
	EmotePhase2			= "완전히 땅에 내려앉았습니다!"
}

----------------------------
--  XT-002 Deconstructor  --
----------------------------
L = DBM:GetModLocalization("XT002")

L:SetGeneralLocalization{
	name = "XT-002 해체자"
}

--------------------
--  Iron Council  --
--------------------
L = DBM:GetModLocalization("IronCouncil")

L:SetGeneralLocalization{
	name = "무쇠 평의회"
}

L:SetOptionLocalization{
	AlwaysWarnOnOverload		= "항상 $spell:63481 경고 (비활성화시 브룬디르를 대상으로 잡았을 때만 경고)"
}

L:SetMiscLocalization{
	Steelbreaker			= "강철파괴자",
	RunemasterMolgeim 		= "룬술사 몰가임",
	StormcallerBrundir 		= "폭풍소환사 브룬디르"
}

----------------------------
--  Algalon the Observer  --
----------------------------
L = DBM:GetModLocalization("Algalon")

L:SetGeneralLocalization{
	name = "관찰자 알갈론"
}

L:SetTimerLocalization{
	NextCollapsingStar		= "다음 붕괴의 별",
	TimerCombatStart		= "전투 시작"
}

L:SetWarningLocalization{
	WarnPhase2Soon			= "곧 2단계",
	warnStarLow				= "붕괴의 별 생명력 낮음"
}

L:SetOptionLocalization{
	WarningPhasePunch			= "위상의 주먹 대상 알림",
	NextCollapsingStar			= "다음 붕괴의 별 타이머 바 보기",
	TimerCombatStart			= "전투 시작 타이머 바 보기",
	WarnPhase2Soon				= "2단계 사전 경고 보기 (23% 이하)",
	warnStarLow					= "붕괴의 별 생명력이 낮을 때 특수 알림 보기 (25% 이하)"
}

L:SetMiscLocalization{
	HealthInfo				= "별 데미지 치유량",
	YellPull				= "너희 행동은 비논리적이다. 이 전투에서 가능한 결말은 모두 계산되었다. 결과와 상관없이 판테온은 관찰자의 전갈을 받을 것이다.",
	YellKill				= "나는 창조주의 불길이 씻어내린 세상을 보았다. 모두 변변히 저항도 못하고 사그라졌지. 너희 필멸자의 심장이 단 한 번 뛸 시간에 전 행성계가 탄생하고 무너졌다. 그러나 그 모든 시간 동안, 나는 공감이란 감정을... 몰랐다. 나는, 아무것도, 느끼지, 못했다. 무수한, 무수한 생명이 꺼졌다. 그들이 모두 너희처럼 강인했더냐? 그들이 모두 너희처럼 삶을 사랑했단 말이냐?",
	Emote_CollapsingStar	= "붕괴하는 별을 소환하기 시작합니다!",
	Phase2					= "창조의 도구를 바라보아라!",
	FirstPull				= "내 눈을 통해 너희 세상을 보아라. 측정할 수 없이 광활한 우주를... 너희 지성으로는 절대 이해할 수 없다.",
}

----------------
--  Kologarn  --
----------------
L = DBM:GetModLocalization("Kologarn")

L:SetGeneralLocalization{
	name = "콜로간"
}

L:SetTimerLocalization{
	timerLeftArm			= "왼팔 재생성",
	timerRightArm			= "오른팔 재생성",
	achievementDisarmed		= "무장해제 업적 타이머"
}

L:SetOptionLocalization{
	timerLeftArm			= "왼팔 재생성 타이머 바 보기",
	timerRightArm			= "오른팔 재생성 타이머 바 보기",
	achievementDisarmed		= "무장해제 업적 타이머 바 보기"
}

L:SetMiscLocalization{
	Yell_Trigger_arm_left	= "얕은 상처야!",
	Yell_Trigger_arm_right	= "꽉꽉 쥐어짜 주마!",
	Health_Body				= "콜로간 몸통",
	Health_Right_Arm		= "오른팔",
	Health_Left_Arm			= "왼팔",
	FocusedEyebeam			= "당신에게 안광을 집중합니다!"
}

--------------
--  Auriya  --
--------------
L = DBM:GetModLocalization("Auriaya")

L:SetGeneralLocalization{
	name = "아우리아야"
}

L:SetMiscLocalization{
	Defender 		= "수호 야수 (%d)",
	YellPull 		= "내버려두는 편이 나았을 텐데!"
}

L:SetTimerLocalization{
	timerDefender	= "수호 야수 활성화"
}

L:SetWarningLocalization{
	WarnCatDied 		= "수호 야수 죽음 (목숨 %d개 남음)",
	WarnCatDiedOne 		= "수호 야수 죽음 (목숨 1개 남음)"
}

L:SetOptionLocalization{
	WarnCatDied 		= "수호 야수가 죽으면 경고 보기",
	WarnCatDiedOne 		= "수호 야수의 남은 목숨이 1개일 때 경고 보기",
	timerDefender       = "수호 야수 활성화 타이머 바 보기"
}

-------------
--  Hodir  --
-------------
L = DBM:GetModLocalization("Hodir")

L:SetGeneralLocalization{
	name = "호디르"
}

L:SetMiscLocalization{
	Pull			= "침입자는 쓴맛을 보게 될 게다!",
	YellKill		= "드디어... 드디어 그의 손아귀를... 벗어나는구나."
}

L:SetTimerLocalization{
	TimerHardmode	= "보관함 부서짐"
}

L:SetOptionLocalization{
	TimerHardmode	= "하드 모드 타이머 바 보기"
}

--------------
--  Thorim  --
--------------
L = DBM:GetModLocalization("Thorim")

L:SetGeneralLocalization{
	name = "토림"
}

L:SetTimerLocalization{
	TimerHardmode			= "하드 모드"
}

L:SetOptionLocalization{
	TimerHardmode			= "하드 모드 타이머 바 보기",
	AnnounceFails			= "$spell:62017에 맞은 사람 공격대 대화로 알림<br/>(알림 옵션 활성화 및 공대장/승급 상태 필요)"
}

L:SetMiscLocalization{
	YellPhase1				= "침입자라니! 감히 내 취미 생활을 방해하는 놈들은 쓴맛을 단단히... 잠깐... 너는...",
	YellPhase2				= "건방진 젖먹이 같으니... 감히 여기까지 기어올라와 내게 도전해? 내 손으로 쓸어버리겠다!",
	YellKill				= "무기를 거둬라! 내가 졌다!",
	ChargeOn				= "번개 충전: %s",
	Charge					= "번개 충전에 맞은 사람 (이번 트라이): %s"
}

-------------
--  Freya  --
-------------
L = DBM:GetModLocalization("Freya")

L:SetGeneralLocalization{
	name = "프레이야"
}

L:SetMiscLocalization{
	SpawnYell			= "얘들아, 날 도와라!",
	WaterSpirit			= "고대 물의 정령",
	Snaplasher 			= "악어덩굴손",
	StormLasher 		= "폭풍덩굴손",
	YellKill			= "내게서 그의 지배력이 걷혔다. 다시 온전한 정신을 찾았도다. 영웅들이여, 고맙다."
}

L:SetWarningLocalization{
	WarnSimulKill		= "첫번째 쫄 죽음 - 12초 후 부활"
}

L:SetTimerLocalization{
	TimerSimulKill 			= "부활"
}

L:SetOptionLocalization{
	WarnSimulKill			= "첫번째 쫄 죽음 알림",
	TimerSimulKill			= "쫄 부활 타이머 바 보기"
}

----------------------
--  Freya's Elders  --
----------------------
L = DBM:GetModLocalization("Freya_Elders")

L:SetGeneralLocalization{
	name = "프레이야의 장로"
}

---------------
--  Mimiron  --
---------------
L = DBM:GetModLocalization("Mimiron")

L:SetGeneralLocalization{
	name = "미미론"
}

L:SetWarningLocalization{
	MagneticCore			= ">%s<|1이;가; 자기 증폭기 획득",
	WarnBombSpawn			= "폭탄 로봇 등장"
}

L:SetTimerLocalization{
	TimerHardmode			= "하드 모드 - 자폭",
	TimeToPhase2			= "2단계",
	TimeToPhase3			= "3단계",
	TimeToPhase4			= "4단계"
}

L:SetOptionLocalization{
	TimeToPhase2			= "2단계 타이머 바 보기",
	TimeToPhase3			= "3단계 타이머 바 보기",
	TimeToPhase4			= "4단계 타이머 바 보기",
	MagneticCore			= "자기 증폭기 획득자 알림",
	WarnBombSpawn			= "폭탄 로봇 경고 보기",
	TimerHardmode			= "하드 모드 타이머 바 보기",
}

L:SetMiscLocalization{
	MobPhase1 		= "거대 전차 Mk II",
	MobPhase2 		= "VX-001",
	MobPhase3 		= "공중지휘기",
	YellPull		= "시간이 없어, 친구들! 내가 최근에 만든 기막힌 발명품을 시험하게 도와 주겠지? 자, 마음 바꿀 생각은 말라고. XT-002를 그 꼬락서니로 만들었으니, 너흰 나한테 빚진 셈이란 걸 잊지 마!",
	YellHardPull	= "자폭 절차를 시작합니다.",
	YellPhase2		= "멋지군! 참으로 경이적인 결과야! 차체 내구도 98.9 퍼센트라! 손상이라고 보기도 어렵지! 계속하자고.",
	YellPhase3		= "고맙다, 친구들! 너희 덕분에 멋진 자료를 좀 얻었어! 자, 그걸 어디 뒀더라... 아, 여기 있군.",
	YellPhase4		= "예비 시험은 이걸로 끝이다. 자, 이제부터가 진짜라고!",
}

---------------------
--  General Vezax  --
---------------------
L = DBM:GetModLocalization("GeneralVezax")

L:SetGeneralLocalization{
	name = "장군 베작스"
}

L:SetWarningLocalization{
	specWarnAnimus 	= "사로나이트 원혼 - 대상 변경"
}

L:SetTimerLocalization{
	hardmodeSpawn = "사로나이트 원혼 등장"
}

L:SetOptionLocalization{
	specWarnAnimus 	= "사로나이트 원혼에 대상 변경 특수 알림 보기",
	hardmodeSpawn	= "사로나이트 원혼 등장 타이머 바 보기 (하드 모드)"
}

L:SetMiscLocalization{
	EmoteSaroniteVapors		= "가까운 사로나이트 증기 구름이 합쳐집니다!"
}

------------------
--  Yogg-Saron  --
------------------
L = DBM:GetModLocalization("YoggSaron")

L:SetGeneralLocalization{
	name = "요그사론"
}

L:SetWarningLocalization{
	WarningGuardianSpawned 			= "수호자 %d 등장",
	WarningCrusherTentacleSpawned	= "분쇄의 촉수 등장",
	WarningSanity 					= "이성 %d 남음",
	SpecWarnSanity 					= "이성 %d 남음",
	SpecWarnMadnessOutNow			= "광기 유발 종료 - 밖으로 나가세요",
	WarnBrainPortalSoon				= "10초 후 내부 차원문",
	specWarnBrainPortalSoon			= "곧 내부 차원문"
}

L:SetTimerLocalization{
	NextPortal			= "내부 차원문"
}

L:SetOptionLocalization{
	WarningGuardianSpawned			= "수호자 등장 경고 보기",
	WarningCrusherTentacleSpawned	= "분쇄의 촉수 등장 경고 보기",
	WarningSanity					= "$spell:63050의 생명력이 낮을때 경고 보기",
	SpecWarnSanity					= "$spell:63050의 생명력이 매우 낮은 경우 특수 알림 보기",
	WarnBrainPortalSoon				= "내부 차원문 사전 경고 보기",
	SpecWarnMadnessOutNow			= "$spell:64059|1이;가; 종료되기 전에 짧은 특수 알림 보기",
	specWarnBrainPortalSoon			= "다음 내부 차원문 특수 알림 보기",
	NextPortal						= "다음 내부 차원문 타이머 바 보기"
}

L:SetMiscLocalization{
	YellPull 				= "짐승의 대장을 칠 때가 곧 다가올 거예요! 놈의 졸개들에게 노여움과 미움을 쏟아부으세요!",
	YellPhase2 				= "나는, 살아 있는 꿈이다.",
	Sara 					= "사라"
}

--------------
--  Onyxia  --
--------------
L = DBM:GetModLocalization("Onyxia")

L:SetGeneralLocalization{
	name = "오닉시아"
}

L:SetWarningLocalization{
	WarnWhelpsSoon		= "곧 오닉시아 새끼용"
}

L:SetTimerLocalization{
	TimerWhelps 		= "오닉시아 새끼용"
}

L:SetOptionLocalization{
	TimerWhelps				= "오닉시아 새끼용 타이머 바 보기",
	WarnWhelpsSoon			= "오닉시아 새끼용 사전 경고 보기",
	SoundWTF3				= "전설의 옛 오닉시아 레이드에 있었던 여러가지 웃기는 효과음 재생"
}

L:SetMiscLocalization{
	YellPull 	= "오늘은 운이 아주 좋군. 평소엔 먹이를 찾으려면 둥지에서 나가야 하는데 말이야.",
	YellP2 		= "쓸데없이 힘을 쓰는 것도 지루하군. 네 녀석들 머리 위에서 모조리 불살라 주마!",
	YellP3 		= "혼이 더 나야 정신을 차리겠구나!"
}

------------------------
--  Northrend Beasts  --
------------------------
L = DBM:GetModLocalization("NorthrendBeasts")

L:SetGeneralLocalization{
	name = "노스렌드의 야수"
}

L:SetWarningLocalization{
	WarningSnobold				= "부하 스노볼트 등장: >%s<"
}

L:SetTimerLocalization{
	TimerNextBoss				= "다음 우두머리",
	TimerEmerge					= "출현",
	TimerSubmerge				= "숨기"
}

L:SetOptionLocalization{
	WarningSnobold				= "스노볼트 부하 등장 경고 보기",
	ClearIconsOnIceHowl			= "돌진 전에 모든 공격대 징표 제거",
	TimerNextBoss				= "다음 우두머리 등장 타이머 바 보기",
	TimerEmerge					= "출현 타이머 바 보기",
	TimerSubmerge				= "숨기 타이머 바 보기",
	IcehowlArrow				= "얼음울음이 근처에서 돌진하려 할 때 DBM 화살표 보기"
}

L:SetMiscLocalization{
	Charge			= "노려보며 큰 소리로 울부짖습니다.",
	CombatStart		= "폭풍우 봉우리의 가장 깊고 어두운 동굴에서 온, 꿰뚫는 자 고르목일세! 영웅들이여, 전투에 임하게!",
	Phase2			= "마음을 단단히 먹게, 영웅들이여. 두 배의 공포, 산성아귀와 공포비늘이 투기장으로 들어온다네!",
	Phase3			= "다음은, 소개하는 순간 공기마저 얼어붙게 하는 얼음울음일세! 죽이지 않으면 죽을 걸세, 용사들이여!",
	Gormok			= "꿰뚫는 자 고르목",
	Acidmaw			= "산성아귀",
	Dreadscale		= "공포비늘",
	Icehowl			= "얼음울음"
}

-------------------
-- Lord Jaraxxus --
-------------------
L = DBM:GetModLocalization("Jaraxxus")

L:SetGeneralLocalization{
	name = "군주 자락서스"
}

L:SetOptionLocalization{
	IncinerateShieldFrame		= "우두머리 체력에 살점 소각 치유량 바 보기"
}

L:SetMiscLocalization{
	IncinerateTarget			= "살점 소각: %s",
	FirstPull					= "대흑마법사 윌프레드 피즐뱅이 다음 상대를 소환할 걸세. 기다리고 있게나."
}

-----------------------
-- Faction Champions --
-----------------------
L = DBM:GetModLocalization("Champions")

L:SetGeneralLocalization{
	name = "진영 대표 용사"
}

L:SetMiscLocalization{
	AllianceVictory 	= "얼라이언스의 영광을 위하여!",
	HordeVictory		= "앞으로 일어날 일의 맛보기일 뿐이다. 호드를 위하여!"
}

------------------
-- Valkyr Twins --
------------------
L = DBM:GetModLocalization("ValkTwins")

L:SetGeneralLocalization{
	name = "발키르 쌍둥이"
}

L:SetTimerLocalization{
	TimerSpecialSpell	= "다음 특수 기술"
}

L:SetWarningLocalization{
	WarnSpecialSpellSoon		= "곧 특수 기술",
	SpecWarnSpecial				= "색깔 변경",
	SpecWarnSwitchTarget		= "대상 변경",
	SpecWarnKickNow				= "지금 차단",
	WarningTouchDebuff			= "디버프: >%s<",
	WarningPoweroftheTwins2		= "쌍둥이의 힘 - >%s< 폭힐",
}

L:SetMiscLocalization{
	Fjola 		= "피욜라 라이트베인",
	Eydis		= "아이디스 다크베인"
}

L:SetOptionLocalization{
	TimerSpecialSpell			= "다음 특수 기술 타이머 바 보기",
	WarnSpecialSpellSoon		= "특수 기술 사전 경고 보기",
	SpecWarnSpecial				= "색깔 변경을 해야할 때 특수 알림 보기",
	SpecWarnSwitchTarget		= "다른 쌍둥이가 힐을 시전하면 대상 변경 특수 알림 보기",
	SpecWarnKickNow				= "차단 스킬이 있다면 힐 차단 특수 알림 보기",
	SpecialWarnOnDebuff			= "손길 디버프에 걸리면 색깔 변경 특수 알림 보기 (디버프 속성 변경)",
	SetIconOnDebuffTarget		= "빛/어둠의 손길 디버프 대상에 공격대 징표 설정 (영웅)",
	WarningTouchDebuff			= "빛/어둠의 손길 대상 알림",
	WarningPoweroftheTwins2		= "쌍둥이의 힘 대상 알림"
}

------------------
-- Anub'arak --
------------------
L = DBM:GetModLocalization("Anub'arak_Coliseum")

L:SetGeneralLocalization{
	name 				= "아눕아락"
}

L:SetTimerLocalization{
	TimerEmerge			= "출현",
	TimerSubmerge		= "숨기",
	timerAdds			= "새 쫄"
}

L:SetWarningLocalization{
	WarnEmerge				= "아눕아락 출현",
	WarnEmergeSoon			= "10초 후 출현",
	WarnSubmerge			= "아눕아락 잠수",
	WarnSubmergeSoon		= "10초 후 숨기",
	specWarnSubmergeSoon	= "10초 후 숨기!",
	warnAdds				= "새 쫄"
}

L:SetMiscLocalization{
	Emerge					= "땅속에서 모습을 드러냅니다!",
	Burrow					= "땅속으로 숨어버립니다!",
	PcoldIconSet			= "냉기 관통 징표 {rt%d}: %s",
	PcoldIconRemoved		= "%s의 냉기 관통 징표 제거"
}

L:SetOptionLocalization{
	WarnEmerge					= "출현 경고 보기",
	WarnEmergeSoon				= "출현 사전 경고 보기",
	WarnSubmerge				= "숨기 경고 보기",
	WarnSubmergeSoon			= "숨기 사전 경고 보기",
	specWarnSubmergeSoon		= "곧 잠수 특수 알림 보기",
	warnAdds					= "새 쫄 알림",
	timerAdds					= "새 쫄 타이머 바 보기",
	TimerEmerge					= "출현 타이머 바 보기",
	TimerSubmerge				= "숨기 타이머 바 보기",
	AnnouncePColdIcons			= "$spell:66013 대상에 설정된 공격대 징표를 공격대 대화로 알림 (공격대장 권한 필요)",
	AnnouncePColdIconsRemoved	= "$spell:66013 대상의 공격대 징표가 제거될 때 알림 (공격대장 권한 필요)"
}

----------------------
--  Lord Marrowgar  --
----------------------
L = DBM:GetModLocalization("LordMarrowgar")

L:SetGeneralLocalization{
	name = "군주 매로우가르"
}

-------------------------
--  Lady Deathwhisper  --
-------------------------
L = DBM:GetModLocalization("Deathwhisper")

L:SetGeneralLocalization{
	name = "여교주 데스위스퍼"
}

L:SetTimerLocalization{
	TimerAdds				= "새 쫄"
}

L:SetWarningLocalization{
	WarnReanimating			= "쫄 부활",
	WarnAddsSoon			= "곧 새 쫄 등장"
}

L:SetOptionLocalization{
	WarnAddsSoon			= "쫄 등장 사전 경고 보기",
	WarnReanimating			= "쫄 부활시 경고 보기",
	TimerAdds				= "새 쫄 타이머 바 보기"
}

L:SetMiscLocalization{
	YellReanimatedFanatic	= "일어나라, 순수한 모습을 기뻐하라!",
}

----------------------
--  Gunship Battle  --
----------------------
L = DBM:GetModLocalization("GunshipBattle")

L:SetGeneralLocalization{
	name = "비행포격선 전투"
}

L:SetWarningLocalization{
	WarnAddsSoon		= "곧 새 쫄 등장"
}

L:SetOptionLocalization{
	WarnAddsSoon		= "쫄 등장 사전 경고 보기",
	TimerAdds			= "새 쫄 타이머 바 보기"
}

L:SetTimerLocalization{
	TimerAdds			= "새 쫄"
}

L:SetMiscLocalization{
	PullAlliance		= "속도를 올려라! 제군들, 곧 운명과 마주할 것이다!",
	PullHorde			= "호드의 아들딸이여, 일어나라! 오늘 우리는 증오하던 적과 전투를 벌이리라! 록타르 오가르!",
	AddsAlliance		= "약탈자, 하사관, 공격하라!",
	AddsHorde			= "해병, 하사관, 공격하라!",
	MageAlliance		= "선체가 공격받고 있다. 전투마법사를 불러 저 대포를 막아버려라!",
	MageHorde			= "선체가 공격받고 있다. 마술사를 불러 저 대포를 막아버려라!",
	Hammer 				= "오그림의 망치호",
	Skybreaker			= "하늘파괴자호"
}

-----------------------------
--  Deathbringer Saurfang  --
-----------------------------
L = DBM:GetModLocalization("Deathbringer")

L:SetGeneralLocalization{
	name = "죽음의 인도자 사울팽"
}

L:SetOptionLocalization{
	RunePowerFrame			= "우두머리 체력 바 + $spell:72371 바 보기"
}

L:SetMiscLocalization{
	PullAlliance		= "네놈들이 쓰러뜨린 호드 병사와 쓰러진 얼라이언스 쓰레기 하나하나가 리치 왕의 군대를 더 강대하게 했다. 지금 이 순간도 발키르가 쓰러진 너희 병사를 스컬지로 일으켜 세우지.",
	PullHorde				= "코르크론, 출발하라! 용사들이여, 뒤를 조심하게. 스컬지는...",
}

-----------------
--  Festergut  --
-----------------
L = DBM:GetModLocalization("Festergut")

L:SetGeneralLocalization{
	name = "구린속"
}

L:SetOptionLocalization{
	AnnounceSporeIcons		= "$spell:69279 대상의 공격대 징표를 공격대 대화로 알림<br/>(공격대장 권한 필요)",
	AchievementCheck		= "'역병 예방접종' 업적 실패시 공격대에 알림<br/>(승급 상태 필요)"
}

L:SetMiscLocalization{
	SporeSet				= "가스 포자 징표 {rt%d}: %s",
	AchievementFailed		= ">> 업적 실패: %s|1이;가; 역병 저항 %d중첩 <<"
}

---------------
--  Rotface  --
---------------
L = DBM:GetModLocalization("Rotface")

L:SetGeneralLocalization{
	name = "썩은얼굴"
}

L:SetWarningLocalization{
	WarnOozeSpawn				= "작은 수액괴물 등장",
	SpecWarnLittleOoze			= "작은 수액괴물이 당신을 공격 - 뛰세요"
}

L:SetOptionLocalization{
	WarnOozeSpawn				= "작은 수액괴물 등장 경고 보기",
	SpecWarnLittleOoze			= "작은 수액괴물에게 공격을 받으면 특수 알림 보기",
}

L:SetMiscLocalization{
	YellSlimePipes1				= "좋은 소식이에요, 여러분! 독성 수액 배출관을 고쳤어요!",
	YellSlimePipes2				= "끝내 주는 소식이에요, 여러분! 수액이 다시 나오는군요!"
}

---------------------------
--  Professor Putricide  --
---------------------------
L = DBM:GetModLocalization("Putricide")

L:SetGeneralLocalization{
	name = "교수 퓨트리사이드"
}

----------------------------
--  Blood Prince Council  --
----------------------------
L = DBM:GetModLocalization("BPCouncil")

L:SetGeneralLocalization{
	name = "피의 의회"
}

L:SetWarningLocalization{
	WarnTargetSwitch			= "대상 변경: %s",
	WarnTargetSwitchSoon		= "곧 대상 변경"
}

L:SetTimerLocalization{
	TimerTargetSwitch			= "대상 변경"
}

L:SetOptionLocalization{
	WarnTargetSwitch			= "대상 변경 경고 보기",
	WarnTargetSwitchSoon		= "대상 변경 사전 경고 보기",
	TimerTargetSwitch			= "대상 변경 쿨타임 타이머 바 보기",
	ActivePrinceIcon			= "힘을 얻은 공작에게 공격대 징표 설정 (해골)",
}


L:SetMiscLocalization{
	Keleseth					= "공작 켈레세스",
	Taldaram					= "공작 탈다람",
	Valanar						= "공작 발라나르",
	EmpoweredFlames				= "강력한 불꽃이 (%S+)|1을;를; 향해 달려갑니다!"
}

-----------------------
--  Queen Lana'thel  --
-----------------------
L = DBM:GetModLocalization("Lanathel")

L:SetGeneralLocalization{
	name = "피의 여왕 라나텔"
}

L:SetMiscLocalization{
	SwarmingShadows			= "어둠이 쌓이더니 (%S+)에게 몰려듭니다!",
	YellFrenzy				= "피를 더 줘!"
}

-----------------------------
--  Valithria Dreamwalker  --
-----------------------------
L = DBM:GetModLocalization("Valithria")

L:SetGeneralLocalization{
	name = "발리스리아 드림워커"
}

L:SetWarningLocalization{
	WarnPortalOpen				= "차원문 열림"
}

L:SetTimerLocalization{
	TimerPortalsOpen			= "차원문 열림",
	TimerPortalsClose			= "차원문 닫힘",
	TimerBlazingSkeleton		= "다음 타오르는 해골",
	TimerAbom					= "다음 누더기골렘"
}

L:SetOptionLocalization{
	SetIconOnBlazingSkeleton	= "타오르는 해골에 공격대 징표 설정 (해골)",
	WarnPortalOpen				= "악몽의 차원문이 열렸을 때 경고 보기",
	TimerPortalsOpen			= "악몽의 차원문 열림 타이머 바 보기",
	TimerPortalsClose			= "악몽의 차원문 닫힘 타이머 바 보기",
	TimerBlazingSkeleton		= "다음 타오르는 해골 등장 타이머 바 보기",
	TimerAbom					= "다음 걸신들린 누더기골렘 등장 타이머 바 보기 (시험용)"
}

L:SetMiscLocalization{
	YellPortals		= "에메랄드의 꿈으로 가는 차원문을 열어두었다. 너희의 구원은 그 안에 있다..."
}

------------------
--  Sindragosa  --
------------------
L = DBM:GetModLocalization("Sindragosa")

L:SetGeneralLocalization{
	name = "신드라고사"
}

L:SetWarningLocalization{
	WarnAirphase			= "공중 단계",
	WarnGroundphaseSoon		= "곧 신드라고사 착륙"
}

L:SetTimerLocalization{
	TimerNextAirphase		= "다음 공중 단계",
	TimerNextGroundphase	= "다음 지상 단계",
	AchievementMystic		= "신비한 강타 중첩 초기화 할 때"
}

L:SetOptionLocalization{
	WarnAirphase				= "공중 단계 알림",
	WarnGroundphaseSoon			= "지상 단계 사전 경고 보기",
	TimerNextAirphase			= "다음 공중 단계 타이머 바 보기",
	TimerNextGroundphase		= "다음 지상 단계 타이머 바 보기",
	AnnounceFrostBeaconIcons	= "$spell:70126 대상의 공격대 징표를 공격대 대화로 알림<br/>(공격대장 권한 필요)",
	ClearIconsOnAirphase		= "공중 단계 전에 모든 공격대 징표 제거",
	AchievementCheck			= "'신비한 아픔' 업적 경고를 공격대에 알림<br/>(승급 상태 필요)",
}

L:SetMiscLocalization{
	YellAirphase			= "여기가 끝이다! 아무도 살아남지 못하리라!",
	YellPhase2				= "자, 주인님의 무한한 힘을 느끼고 절망에 빠져보아라!",
	BeaconIconSet			= "냉기 봉화 징표 {rt%d}: %s",
	AchievementWarning		= "경고: %s의 신비한 강타 5중첩",
	AchievementFailed		= ">> 업적 실패: %s|1이;가; 신비한 강타 %d중첩 <<"
}

---------------------
--  The Lich King  --
---------------------
L = DBM:GetModLocalization("LichKing")

L:SetGeneralLocalization{
	name = "리치 왕"
}

L:SetWarningLocalization{
	ValkyrWarning				= ">%s< 납치됨!",
	SpecWarnYouAreValkd			= "당신이 납치됐습니다!",
	WarnNecroticPlagueJump		= "괴저 역병 전이: >%s<",
	SpecWarnValkyrLow			= "발키르 생명력 55% 이하"
}

L:SetTimerLocalization{
	TimerRoleplay				= "대사",
	PhaseTransition				= "단계 전환",
	TimerNecroticPlagueCleanse 	= "괴저 역병 해제"
}

L:SetOptionLocalization{
	TimerRoleplay				= "대사 이벤트 타이머 바 보기",
	WarnNecroticPlagueJump		= "$spell:70337 전이 대상 알림",
	TimerNecroticPlagueCleanse	= "괴저 역병 첫 틱 전에 해제 타이머 바 보기",
	PhaseTransition				= "단계 전환 타이머 바 보기",
	ValkyrWarning				= "발키르 어둠수호병이 붙잡은 대상 알림",
	SpecWarnYouAreValkd			= "발키르 어둠수호병에게 붙잡혔을 때 특수 알림 보기",
	AnnounceValkGrabs			= "발키르 어둠수호병이 붙잡은 대상 공격대 대화로 알림<br/>(알림 설정 활성화 및 승급 상태 필요)",
	SpecWarnValkyrLow			= "발키르의 생명력이 55%이하가 되면 특수 알림 보기",
	AnnouncePlagueStack			= "$spell:70337 중첩을 공격대에 알림 (10 중첩까지, 그 이상은 5중첩마다)<br/>(승급 상태 필요)"
}

L:SetMiscLocalization{
	LKPull					= "그러니까 성스러운 빛이 자랑하던 정의가 마침내 왔다 이건가? 폴드링, 서리한을 내려놓고 자비라도 애걸하라는 건가?",
	LKRoleplay				= "진정으로 정의에 이끌렸단 말이냐? 궁금하구나...",
	ValkGrabbedIcon			= "발키르 어둠수호병 {rt%d} 붙잡기: %s",
	ValkGrabbed				= "발키르 어둠수호병이 %s|1을;를; 붙잡음",
	PlagueStackWarning		= "경고: %s의 괴저 역병 %d중첩",
	AchievementCompleted	= ">> 업적 성공: %s의 괴저 역병 %d중첩 <<"
}

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("ICCTrash")

L:SetGeneralLocalization{
	name = "얼음왕관 일반몹"
}

L:SetWarningLocalization{
	SpecWarnTrapL		= "함정 활성화! - 죽음에 속박된 감시자 풀려남",
	SpecWarnTrapP		= "함정 활성화! - 복수의 육신해체자 등장",
	SpecWarnGosaEvent	= "신드라고사 방어전 시작됨!"
}

L:SetOptionLocalization{
	SpecWarnTrapL		= "죽음에 속박된 감시자 함정 활성화 특수 알림 보기",
	SpecWarnTrapP		= "복수의 육신해체자 함정 활성화 특수 알림 보기",
	SpecWarnGosaEvent	= "신드라고사 방어전 이벤트 특수 알림 보기"
}

L:SetMiscLocalization{
	WarderTrap1			= "거기... 누구냐?",
	WarderTrap2			= "내가... 깨어난다!",
	WarderTrap3			= "주인님의 성소를 어지럽혔구나!",
	FleshreaperTrap1	= "서둘러! 저놈들 뒤에서 습격하자!",
	FleshreaperTrap2	= "우리에게서... 벗어날 수 없다!",
	FleshreaperTrap3	= "살아있는 놈이... 여기에?!",
	SindragosaEvent		= "서리 여왕께 다가가도록 두지 않겠다. 서둘러라! 저들을 막아라!"
}

------------------------
--  The Ruby Sanctum  --
------------------------
--  Baltharus the Warborn  --
-----------------------------
L = DBM:GetModLocalization("Baltharus")

L:SetGeneralLocalization({
	name = "전쟁의 아들 발타루스"
})

L:SetWarningLocalization({
	WarningSplitSoon	= "곧 분리"
})

L:SetOptionLocalization({
	WarningSplitSoon	= "분리 사전 경고 보기"
})

-------------------------
--  Saviana Ragefire  --
-------------------------
L = DBM:GetModLocalization("Saviana")

L:SetGeneralLocalization({
	name = "사비아나 레이지파이어"
})

--------------------------
--  General Zarithrian  --
--------------------------
L = DBM:GetModLocalization("Zarithrian")

L:SetGeneralLocalization({
	name = "장군 자리스리안"
})

L:SetWarningLocalization({
	WarnAdds			= "새 쫄",
	warnCleaveArmor		= "%s: >%s< (%s)"
})

L:SetTimerLocalization({
	TimerAdds	= "새 쫄"
})

L:SetOptionLocalization({
	WarnAdds		= "새 쫄 알림",
	TimerAdds		= "새 쫄 타이머 바 보기"
})

L:SetMiscLocalization({
	SummonMinions	= "저놈들을 재로 만들어버려라!"
})
-------------------------------------
--  Halion the Twilight Destroyer  --
-------------------------------------
L = DBM:GetModLocalization("Halion")

L:SetGeneralLocalization({
	name = "황혼의 파괴자 할리온"
})

L:SetWarningLocalization({
	TwilightCutterCast	= "황혼 절단기 시전: 5초"
})

L:SetOptionLocalization({
	TwilightCutterCast		= "$spell:74769 시전시 경고 보기",
	AnnounceAlternatePhase	= "당신이 없는 위상의 경고/타이머 바 보기"
})

L:SetMiscLocalization({
	Halion					= "할리온",
	MeteorCast				= "하늘이 타오른다!",
	Phase2					= "황혼 세계에서는 고통만이 있으리라! 자신 있다면 들어와 봐라!",
	Phase3					= "나는 빛이자 어둠이다! 필멸자들아, 데스윙의 사자 앞에 무릎 꿇어라!",
	twilightcutter			= "주위를 회전하는 구슬들이 고동치며 어둠의 기운을 내뿜습니다!",
	Kill					= "필멸자들아, 승리를 만끽해라. 그것이 마지막일 테니. 주인님이 돌아오시면 이 세상은 불타버리리라!"
})
