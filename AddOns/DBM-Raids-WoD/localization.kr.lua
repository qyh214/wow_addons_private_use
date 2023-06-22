if GetLocale() ~= "koKR" then
	return
end
local L

---------------
-- Kargath Bladefist --
---------------
L = DBM:GetModLocalization(1128)

L:SetTimerLocalization({
	timerSweeperCD	= DBM_CORE_L.AUTO_TIMER_TEXTS.next:format("높은망치 난동꾼")
})

L:SetOptionLocalization({
	timerSweeperCD		= "다음 높은망치 난동꾼 바 보기"
})

---------------------------
-- Tectus, the Living Mountain --
---------------------------
L = DBM:GetModLocalization(1195)

L:SetMiscLocalization({
	pillarSpawn	= "산이여, 솟아라!"
})

------------------
-- Brackenspore, Walker of the Deep --
------------------
L = DBM:GetModLocalization(1196)

L:SetOptionLocalization({
	InterruptCounter	= "부패 시전 횟수 초기화",
	Two					= "2회 시전 후",
	Three				= "3회 시전 후",
	Four				= "4회 시전 후"
})

--------------
-- Twin Ogron --
--------------
L = DBM:GetModLocalization(1148)

L:SetOptionLocalization({
	PhemosSpecial		= "페모스의 대기시간 초읽기 듣기",
	PolSpecial			= "폴의 대기시간 초읽기 듣기",
	PhemosSpecialVoice	= "펠모스의 주문을 선택한 음성안내 소리로 듣기",
	PolSpecialVoice		= "폴의 주문을 선택한 음성안내 소리로 듣기"
})

--------------------
--Koragh --
--------------------
L = DBM:GetModLocalization(1153)

L:SetWarningLocalization({
	specWarnExpelMagicFelFades	= "5초 후 악마 사라짐 - 처음 지점으로 이동!"
})

L:SetOptionLocalization({
	specWarnExpelMagicFelFades	= "$spell:172895 주문이 사라지기 전에 처음 지점 이동 특수 경고 보기"
})

L:SetMiscLocalization({
	supressionTarget1	= "박살내주마!",
	supressionTarget2	= "침묵!",
	supressionTarget3	= "닥쳐라!",
	supressionTarget4	= "으허허허, 반으로 찢어주마!"
})

--------------------------
-- Imperator Mar'gok --
--------------------------
L = DBM:GetModLocalization(1197)

L:SetTimerLocalization({
	timerNightTwistedCD	= "다음 뒤틀린 밤의 신봉자"
})

L:SetOptionLocalization({
	GazeYellType		= "심연의 시선 대화 알림 방식 선택",
	Countdown			= "남은시간 초세기",
	Stacks				= "받을 때 중첩 수",
	timerNightTwistedCD	= "다음 뒤틀린 밤의 신봉자 바 보기"
})

L:SetMiscLocalization({
	BrandedYell		= "낙인(%d중첩): %dm",
	GazeYell		= "%d초 후 시선 사라짐!",
	GazeYell2		= "%2$s에게 시선! (%1$d)",
	PlayerDebuffs	= "광기의 눈길 가까움"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HighmaulTrash")

L:SetGeneralLocalization({
	name	= "높은망치: 일반구간"
})

---------------
-- Gruul --
---------------
L = DBM:GetModLocalization(1161)

L:SetOptionLocalization({
	MythicSoakBehavior	= "신화 난이도에서 지옥불 가르기 조 알림 방식 선택",
	ThreeGroup			= "3개 파티가 1 중첩씩",
	TwoGroup			= "2개 파티가 2 중첩씩"
})

---------------------------
-- Oregorger, The Devourer --
---------------------------
L = DBM:GetModLocalization(1202)

L:SetOptionLocalization({
	InterruptBehavior	= "차단 경고 설정",
	Smart				= "우두머리 중첩에 따라 알림",
	Fixed				= "무조건 5/3 중첩에 맞춰서 알림(중첩이 맞지 않더라도)"
})

---------------------------
-- The Blast Furnace --
---------------------------
L = DBM:GetModLocalization(1154)

L:SetWarningLocalization({
	warnRegulators			= "열기 조절 장치 남음: %d",
	warnBlastFrequency		= "폭파 시전 빈도 증가됨: 약 %d초 마다 시전",
	specWarnTwoVolatileFire	= "변덕스러운 불 중복됨!"
})

L:SetOptionLocalization({
	warnRegulators			= "열기 조절 장치 남은숫자 알림 보기",
	warnBlastFrequency		= "$spell:155209 시전 빈도 증가시 알림 보기",
	specWarnTwoVolatileFire	= "$spell:176121 중복시 특수 경고 보기",
	InfoFrame				= "$spell:155192 와 $spell:155196 정보를 정보 창으로 보기",
	VFYellType2				= "변덕스러운 불 대화 알림 방식 선택(신화 난이도)",
	Countdown				= "남은시간 초세기",
	Apply					= "받을때만 알리기"
})

L:SetMiscLocalization({
	heatRegulator	= "열기 조절 장치",
	Regulator		= "조절 장치 %d",
	bombNeeded		= "폭탄 %d개 남음"
})

--------------------------
-- Operator Thogar --
--------------------------
L = DBM:GetModLocalization(1147)

L:SetWarningLocalization({
	specWarnSplitSoon	= "10초 안에 공격대 상하로 분리하세요!",
	InfoFrameSpeed		= "정보 창에서 언제 다음 기차를 보여줄 것인지 설정",
	Immediately			= "등장할 기차 문이 열릴 때(5초전)",
	Delayed				= "기차가 실제로 등장한 후",
	HudMapUseIcons		= "범위정보에 녹색원 대신 전술 목표 아이콘 사용하기"
})

L:SetOptionLocalization({
	specWarnSplitSoon	= "공격대 분리 10초 전에 특수 경고 보기",
	InfoFrameSpeed		= "다음 열차 정보 창 업데이트 시기 설정",
	Immediately			= "다음 열차 등장 문이 열릴 때(5초 전)",
	Delayed				= "열차가 실제로 등장하기 직전",
	TrainVoiceAnnounce	= "다음 열차 음성 안내 방식 선택(신화 난이도)",
	LanesOnly			= "선로 정보만 안내",
	MovementsOnly		= "이동 방향만 안내(신화 난이도)",
	LanesandMovements	= "선로 정보와 이동 방향 동시 안내(신화 난이도)"
})

L:SetMiscLocalization({
	Train			= "기차",
	lane			= "선로",
	oneTrain		= "무작위 선로 1곳: 열차",
	oneRandom		= "무작위 1곳 등장",
	threeTrains		= "무작위 선로 3곳: 열차",
	threeRandom		= "무작위 3곳 등장",
	helperMessage	= "이 전투는 'Thogar Assist' 애드온 또는 DBM 음성안내로 더 좋은 안내를 받으실 수 있습니다. 해당 애드온들은 Curse에서 다운로드 가능합니다."
})

--------------------------
-- The Iron Maidens --
--------------------------
L = DBM:GetModLocalization(1203)

L:SetWarningLocalization({
	specWarnReturnBase	= "지금 본진으로 복귀!"
})

L:SetOptionLocalization({
	specWarnReturnBase	= "무쌍호에서 안전하게 본진으로 복귀할 수 있을때 특수 경고 보기",
	filterBladeDash3	= "$spell:170395 효과가 있을 경우 $spell:155794 특수 경고를 보이지 않기",
	filterBloodRitual3	= "$spell:170405 효과가 있을 경우 $spell:158078 특수 경고를 보이지 않기"
})

L:SetMiscLocalization({
	shipMessage		= "주 대포를 쏠 준비를 합니다!",
	EarlyBladeDash	= "너무 느려."
})

--------------------------
-- Blackhand --
--------------------------
L = DBM:GetModLocalization(959)

L:SetWarningLocalization({
	specWarnMFDPosition		= "표적 피할 위치: %s",
	specWarnSlagPosition	= "폭탄 피할 위치: %s"
})

L:SetOptionLocalization({
	PositionsAllPhases	= "모든 단계에서 $spell:156096 대화 알림시 위치 정보 표기(기본은 3단계에만 사용합니다. 일반적으로는 불필요합니다.)",
	InfoFrame			= "$spell:155992 와 $spell:156530 정보를 정보 창으로 보기"
})

L:SetMiscLocalization({
	customMFDSay	= "%2$s에게 죽음의 표적! (%1$s)",
	customSlagSay	= "%2$s에게 잿가루 폭탄 부착! (%1$s)"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("BlackrockFoundryTrash")

L:SetGeneralLocalization({
	name	= "검은바위 용광로: 일반구간"
})

---------------
-- Hellfire Assault --
---------------
L = DBM:GetModLocalization(1426)

L:SetTimerLocalization({
	timerSiegeVehicleCD	= "다음 공성 차량: %s"
})

L:SetOptionLocalization({
	timerSiegeVehicleCD	= "다음 공성 차량 바 보기"
})

L:SetMiscLocalization({
	AddsSpawn1	= "Comin' in hot!",--Blizzard seems to have disabled these (찾지 못함)
	AddsSpawn2	= "Fire in the hole!",--Blizzard seems to have disabled these (찾지 못함)
	BossLeaving	= "I'll be back..."--조금만 기다리라고...
})

---------------------------
-- Hellfire High Council --
---------------------------
L = DBM:GetModLocalization(1432)

L:SetWarningLocalization({
	reapDelayed	= "악몽의 형상 종료 후 수확"
})

--------------
-- Kilrogg Deadeye --
--------------
L = DBM:GetModLocalization(1396)

L:SetMiscLocalization({
	BloodthirstersSoon	= "와라, 형제들이여! 운명을 손에 넣어라!"
})

--------------------
--Gorefiend --
--------------------
L = DBM:GetModLocalization(1372)

L:SetTimerLocalization({
	SoDDPS2		= "다음 그림자 (%s)",
	SoDTank2	= "다음 그림자 (%s)",
	SoDHealer2	= "다음 그림자 (%s)"
})

L:SetOptionLocalization({
	SoDDPS2			= "다음 $spell:179864 대상 바 보기(공격 전담)",
	SoDTank2		= "다음 $spell:179864 대상 바 보기(방어 전담)",
	SoDHealer2		= "다음 $spell:179864 대상 바 보기(치유 전담)",
	ShowOnlyPlayer	= "$spell:179909 대상일 경우에만 범위정보 표시"
})

--------------------------
-- Shadow-Lord Iskar --
--------------------------
L = DBM:GetModLocalization(1433)

L:SetWarningLocalization({
	specWarnThrowAnzu	=	"%s에게 안주의 눈 투척!"
})

L:SetOptionLocalization({
	specWarnThrowAnzu	=	"$spell:179202을 던져야 할 경우 특수 경고 보기"
})

--------------------------
-- Fel Lord Zakuun --
--------------------------
L = DBM:GetModLocalization(1391)

L:SetOptionLocalization({
	SeedsBehavior	= "씨앗 위치 알림 방법 설정(공격대장 권한 필요)",
	Iconed			= "별, 동그라미, 다이아, 역삼각형, 달(기둥 위치를 사용할 경우)",--Default
	Numbered		= "1, 2, 3, 4, 5(번호로 지정된 위치를 사용할 경우)",
	DirectionLine	= "왼쪽, 중앙 왼쪽, 중앙, 중앙 오른쪽, 오른쪽.(일직선 진형을 사용할 경우)",
	FreeForAll		= "위지 지정하지 않음. 기본 대화 알림 사용"
})

L:SetMiscLocalization({
	DBMConfigMsg	= "씨앗 위치 알림 방법이 공격대장 설정과 동일하게 하기 위해 %s로 설정되었습니다.",
	BWConfigMsg		= "공격대장이 BigWigs를 사용합니다. BigWigs와 동일한 경고를 하기 위해 번호 알림으로 설정됩니다."
})

--------------------------
-- Xhul'horac --
--------------------------
L = DBM:GetModLocalization(1447)

L:SetOptionLocalization({
	ChainsBehavior	= "지옥의 사슬 대상 경고 방식 설정",
	Cast			= "시전 시작시 바라보는 대상만 알림. 바는 시전 시작에 맞추어 갱신됩니다.",
	Applied			= "시전 완료후 약화 효과 대상 알림. 바는 시전 완료에 맞추어 갱신됩니다.",
	Both			= "시전 시작 및 완료시 모두 알림"
})

--------------------------
-- Socrethar the Eternal --
--------------------------
L = DBM:GetModLocalization(1427)

L:SetOptionLocalization({
	InterruptBehavior	= "지배권 행사 차단 경고 방식 설정(공객대장 권한 필요)",
	Count3Resume		= "3명 차단, 보호막 종료 후 차단 횟수 유지",--Default
	Count3Reset			= "3명 차단, 보호막 종료 후 1번부터 다시 시작",
	Count4Resume		= "4명 차단, 보호막 종료 후 차단 횟수 유지",
	Count4Reset			= "4명 차단, 보호막 종료 후 1번부터 다시 시작"
})

--------------------------
-- Mannoroth --
--------------------------
L = DBM:GetModLocalization(1395)

L:SetMiscLocalization({
	felSpire	= "힘을 불어넣기 시작합니다!"
})

--------------------------
-- Archimonde --
--------------------------
L = DBM:GetModLocalization(1438)

L:SetWarningLocalization({
	specWarnBreakShackle	= "구속된 고통: %s로 빠지세요!"
})

L:SetOptionLocalization({
	specWarnBreakShackle	= "$spell:184964 대상이 된 경우 특수 경고 보기(빠지는 순서가 자동으로 할당됩니다.)",
	ExtendWroughtHud3		= "$spell:185014 대상에게 범위정보 연장(선모양이 부정확할 수 있습니다.)",
	AlternateHudLine		= "$spell:185014 대상에게 다른 범위정보 무늬 사용",
	NamesWroughtHud			= "$spell:185014 대상 이름을 포함한 범위정보 보기",
	FilterOtherPhase		= "당신과 다른 위상에 있는 주문 경고 숨기기"
})

L:SetMiscLocalization({
	phase2point5	= "보아라, 불타는 군단의 무한한 힘을. 깨달아라. 저항해도 소용없음을.",--3 seconds faster than CLEU, used as primary, slower CLEU secondary
	First			= "첫번째",
	Second			= "두번째",
	Third			= "세번째",
	Fourth			= "네번째",--Just in case, not sure how many targets in 30 man raid
	Fifth			= "다섯번째"--Just in case, not sure how many targets in 30 man raid
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HellfireCitadelTrash")

L:SetGeneralLocalization({
	name	= "지옥불 성채: 일반구간"
})
