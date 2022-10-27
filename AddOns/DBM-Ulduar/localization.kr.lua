if GetLocale() ~= "koKR" then return end
local L

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
	WarnBrainPortalSoon				= "3초 후 내부 차원문",
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
