if GetLocale() ~= "koKR" then return end
local L

----------------
--  Argaloth  --
----------------
L= DBM:GetModLocalization(139)

-----------------
--  Occu'thar  --
-----------------
L= DBM:GetModLocalization(140)

----------------------------------
--  Alizabal, Mistress of Hate  --
----------------------------------
L= DBM:GetModLocalization(339)

L:SetTimerLocalization({
	TimerFirstSpecial	= "다음 증오/꼬챙이"
})

L:SetOptionLocalization({
	TimerFirstSpecial	= "$spell:105738 후 다음 특수 공격 바 보기<br/>(첫번째 특수 공격은 $spell:105067 와 $spell:104936 중 무작위로 결정됩니다.)"
})

-------------------------------
--  Dark Iron Golem Council  --
-------------------------------
L = DBM:GetModLocalization(169)

L:SetWarningLocalization({
	SpecWarnActivated			= "%s 활성화 - 대상 전환!",
	specWarnGenerator			= "%s이 동력 증폭장 바닥을 밟음 - 이동시키세요!"
})

L:SetTimerLocalization({
	timerShadowConductorCast	= "암흑 전도체 변환",
	timerArcaneLockout			= "비전 파괴자 가능",
	timerArcaneBlowbackCast		= "폭발!",
	timerNefAblity				= "스킬 강화 가능"
})

L:SetOptionLocalization({
	timerShadowConductorCast	= "$spell:92053 시전 바 보기",
	timerArcaneLockout			= "$spell:79710 대기시간 바 보기",
	timerArcaneBlowbackCast		= "$spell:91879 시전 바 보기",
	timerNefAblity				= "영웅 난이도에서 골렘 스킬 강화 대기시간 바 보기",
	SpecWarnActivated			= "새로운 우두머리가 활성화 될 때 대상 전환 특수 경고 보기",
	specWarnGenerator			= "우두머리가 $spell:79629 바닥을 밟은 경우 특수 경고 보기",
	SetIconOnActivated			= "활성화된 우두머리에게 전술 목표 아이콘 설정"
})

L:SetMiscLocalization({
	YellTargetLock				= "어둠의 휘감기! 제 주변에서 빠지세요!"
})

--------------
--  Magmaw  --
--------------
L = DBM:GetModLocalization(170)

L:SetWarningLocalization({
	SpecWarnInferno	= "곧 해골 소환 - 바닥 확인!"
})

L:SetOptionLocalization({
	SpecWarnInferno	= "$spell:92154 이전에 특수 경고 보기(~4초 전)",
	RangeFrame		= "2 단계에서 거리 창 보기(5m)"
})

L:SetMiscLocalization({
	Slump			= "기울입니다!",
	HeadExposed		= "노출되었습니다!",
	YellPhase2		= "이런 곤란할 데가! 이러다간 내 용암 벌레가 정말 질 수도 있겠군! 그럼... 내가 상황을 좀 바꿔 볼까?" --"Inconceivable! You may actually defeat my lava worm! Perhaps I can help... tip the scales."
})

-----------------
--  Atramedes  --
-----------------
L = DBM:GetModLocalization(171)

L:SetOptionLocalization({
	InfoFrame				= "$journal:3072 정보를 정보 창으로 보기"
})

L:SetMiscLocalization({
	NefAdd					= "아트라메데스, 적은 바로 저기에 있다!",
	Airphase				= "그래, 도망가라! 발을 디딜 때마다 맥박은 빨라지지. 점점 더 크게 울리는구나... 귀청이 터질 것만 같군! 넌 달아날 수 없다!"
})

-----------------
--  Chimaeron  --
-----------------
L = DBM:GetModLocalization(172)

L:SetOptionLocalization({
	RangeFrame		= "거리 창 보기(6m)",
	InfoFrame		= "체력이 낮은 대상을 정보 창으로 보기(1만 미만)"
})

L:SetMiscLocalization({
	HealthInfo	= "체력 정보"
})

----------------
--  Maloriak  --
----------------
L = DBM:GetModLocalization(173)

L:SetWarningLocalization({
	WarnPhase			= "%s 단계"
})

L:SetTimerLocalization({
	TimerPhase		= "다음 단계"
})

L:SetOptionLocalization({
	WarnPhase			= "단계 전환 알림 보기",
	TimerPhase			= "다음 단계 바 보기",
	RangeFrame			= "푸른색 단계에서 거리 창 보기(6m)",
	SetTextures			= "암흑 단계에서 텍스쳐 투영 효과 자동으로 끄기<br/>(암흑 단계가 종료 되면 원상태로 복구됨)"
})

L:SetMiscLocalization({
	YellRed			= "붉은색|r 약병을 가마솥",
	YellBlue		= "푸른색|r 약병을 가마솥",
	YellGreen		= "초록색|r 약병을 가마솥",
	YellDark		= "암흑|r 마법을 사용합니다!"
})

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization(174)

L:SetWarningLocalization({
	OnyTailSwipe			= "꼬리 채찍 : 오닉시아",
	NefTailSwipe			= "꼬리 채찍 : 네파리안",
	OnyBreath				= "암흑불길 숨결 : 오닉시아",
	NefBreath				= "암흑불길 숨결 : 네파리안",
	specWarnShadowblazeSoon	= "%s",
	warnShadowblazeSoon		= "%s"
})

L:SetTimerLocalization({
	timerNefLanding		= "네파리안 착지",
	OnySwipeTimer		= "꼬리 채찍 가능: 오닉시아",
	NefSwipeTimer		= "꼬리 채찍 가능: 네파리안",
	OnyBreathTimer		= "숨결 가능: 오닉시아",
	NefBreathTimer		= "숨결 가능: 네파리안"
})

L:SetOptionLocalization({
	OnyTailSwipe			= "오닉시아의 $spell:77827 알림 보기",
	NefTailSwipe			= "네파리안의 $spell:77827 알림 보기",
	OnyBreath				= "오닉시아의 $spell:77826 알림 보기",
	NefBreath				= "네파리안의 $spell:77826 알림 보기",
	specWarnCinderMove		= "$spell:79339 효과가 5초 남았을 때 이동 특수 경고 보기",
	warnShadowblazeSoon		= "$spell:81031 이전에 알림 보기(~5초 전/정확성을 위해 동기화 후에만 작동됨)",
	specWarnShadowblazeSoon	= "$spell:81031 이전에 특수 경고 보기(처음에는 5초 전에 알림. 동기화 후에는 1초 전에 알림)",
	timerNefLanding			= "네파리안 착지 바 보기",
	OnySwipeTimer			= "오닉시아의 $spell:77827 대기시간 바 보기",
	NefSwipeTimer			= "네파리안의 $spell:77827 대기시간 바 보기",
	OnyBreathTimer			= "오닉시아의 $spell:77826 대기시간 바 보기",
	NefBreathTimer			= "네파리안의 $spell:77826 대기시간 바 보기",
	InfoFrame				= "$journal:3284 정보를 정보 창으로 보기",
	SetWater				= "전투 시작시 수면 자동 시점 옵션을 자동으로 끄기<br/>(전투가 종료 되면 원상태로 복구됨)",
	RangeFrame				= "$spell:79339 대상이 된 경우 거리 창(10m) 보기<br/>(대상자는 범위내 모든 사람 보임. 대상자가 아닌 경우 대상자와 아이콘만 보임)"
})

L:SetMiscLocalization({
	NefAoe				= "전기가 튀며 파지직하는 소리가 납니다!",
	YellPhase2			= "저주받을 필멸자들! 내 소중한 작품을 이렇게 망치다니! 쓴맛을 봐야 정신을 차리겠군!",
	YellPhase3			= "품위있는 집주인답게 행동하려 했건만, 네놈들이 도무지 죽질 않는군! 겉치레는 이제 집어치우자고. 그냥 모두 없애 버리겠어!",
	YellShadowBlaze		= "살을 재로 만들어 주마!",
	ShadowBlazeExact	= "%d초 후 암흑불꽃 불똥!",
	ShadowBlazeEstimate	= "약 5초 후 암흑불꽃 불똥!"
})

-------------------------------
--  Blackwing Descent Trash  --
-------------------------------
L = DBM:GetModLocalization("BWDTrash")

L:SetGeneralLocalization({
	name = "검은날개 강림지: 일반구간"
})

--------------------------
--  Halfus Wyrmbreaker  --
--------------------------
L= DBM:GetModLocalization(156)

L:SetOptionLocalization({
	ShowDrakeHealth		= "풀려난 용의 체력 바 보기(우두머리 체력 바 필요)"
})

---------------------------
--  Valiona & Theralion  --
---------------------------
L= DBM:GetModLocalization(157)

L:SetOptionLocalization({
	TBwarnWhileBlackout		= "$spell:86788이 활성화 중일때도 $spell:86369 경고 보기",
	TwilightBlastArrow		= "$spell:86369 대상이 가까이 있을 경우 DBM 화살표 보기",
	RangeFrame				= "거리 창 보기(10m)",
	BlackoutShieldFrame		= "우두머리 체력 바 사용시 $spell:86788 치유량 바 함께 보기"
})

L:SetMiscLocalization{
	Trigger1				= "들이쉽니다!",
	BlackoutTarget			= "의식 상실: %s"
}

----------------------------------
--  Twilight Ascendant Council  --
----------------------------------
L= DBM:GetModLocalization(158)

L:SetWarningLocalization({
	specWarnBossLow			= "%s 체력 30%% 이하 - 곧 다음 단계!",
	SpecWarnGrounded		= "접지 받으세요!",
	SpecWarnSearingWinds	= "소용돌이 치는 바람 받으세요!"
})

L:SetTimerLocalization({
	timerTransition			= "다음 단계"
})

L:SetOptionLocalization({
	specWarnBossLow			= "우두머리의 체력이 30% 이하로 내려갈 경우 특수 경고 보기",
	SpecWarnGrounded		= "$spell:83581 효과가 없을 경우 특수 경고 보기(~10초 전)",
	SpecWarnSearingWinds	= "$spell:83500 효과가 없을 경우 특수 경고 보기(~10초 전)",
	timerTransition			= "다음 단계 바 보기",
	RangeFrame				= "필요시 거리 창 보기",
	yellScrewed				= "$spell:83099 와 $spell:92307 대상이 동시에 된 경우 대화로 알리기",
	InfoFrame				= "$spell:83581 또는 $spell:83500 없는 대상을 정보 창으로 보기"
})

L:SetMiscLocalization({
	Quake			= "발밑의 땅이 불길하게 우르릉거립니다...",
	Thundershock	= "주변의 공기가 에너지로 진동합니다...",
	Switch			= "우리가 상대하겠다!",--"We will handle them!" comes 3 seconds after this one
	Phase3			= "꽤나 인상적이었다만...",--"BEHOLD YOUR DOOM!" is about 13 seconds after
	Kill			= "이럴 수가...",
	blizzHatesMe	= "봉화랑 벼락 막대 같이 걸렸어요! 비켜주세요!",
	WrongDebuff		= "%s 없음"
})

----------------
--  Cho'gall  --
----------------
L= DBM:GetModLocalization(167)

L:SetOptionLocalization({
	CorruptingCrashArrow	= "$spell:81685 대상이 가까이 있을 경우 DBM 화살표 보기",
	InfoFrame				= "$journal:3165 정보를 정보 창으로 보기",
	RangeFrame				= "$spell:82235 대상이 된 경우 거리 창(5m) 보기"
})

----------------
--  Sinestra  --
----------------
L= DBM:GetModLocalization(168)

L:SetWarningLocalization({
	WarnOrbSoon			= "%d초 후 구슬!",
	SpecWarnOrbs		= "곧 구슬! 조심하세요!",
	warnWrackJump		= "%s 전이 : >%s<",
	warnAggro			= "위협 수준 획득(구슬 예상 대상) : >%s<",
	SpecWarnAggroOnYou	= "위협 수준 획득함! 구슬 조심하세요!"
})

L:SetTimerLocalization({
	TimerEggWeakening 	= "황혼 껍질 사라짐",
	TimerEggWeaken		= "황혼 껍질 재생성",
	TimerOrbs			= "구슬 가능"
})

L:SetOptionLocalization({
	WarnOrbSoon			= "구슬 예상 초읽기 알림 보기(5초 전부터, 1초 마다)(부정확함)",
	warnWrackJump		= "$spell:89421 전이 알림 보기",
	warnAggro			= "구슬 생성 예상시 위협 수준이 있는 대상 알림 보기",
	SpecWarnAggroOnYou	= "구슬 생성 예상시 위협 수준이 있는 경우 특수 경고 보기(구슬 예상 대상)",
	SpecWarnOrbs		= "구슬 생성 예상 특수 경고 보기(부정확함)",
	TimerEggWeakening  	= "$spell:87654 사라짐 바 보기",
	TimerEggWeaken		= "$spell:87654 재생성 바 보기",
	TimerOrbs			= "구슬 대기시간 바 보기(부정확함)",
	SetIconOnOrbs		= "구슬 생성 예상시 위협 수준이 있는 대상에게 전술 목표 아이콘 설정",
	InfoFrame			= "위협 수준 획득(구슬 예상 대상)을 정보 창으로 보기"
})

L:SetMiscLocalization({
	YellDragon		= "얘들아, 먹어치워라",
	YellEgg			= "이게 약해지는 걸로 보이느냐? 멍청한 놈!",
	HasAggro		= "위협 수준 있음"
})

-------------------------------------
--  The Bastion of Twilight Trash  --
-------------------------------------
L = DBM:GetModLocalization("BoTrash")

L:SetGeneralLocalization({
	name =	"황혼의 요새: 일반구간"
})

------------------------
--  Conclave of Wind  --
------------------------
L = DBM:GetModLocalization(154)

L:SetWarningLocalization({
	warnSpecial				= "궁극의 힘", --Hurricane/Zephyr/Sleet Storm Active",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial			= "궁극의 힘!",
	warnSpecialSoon			= "10초 후 궁극의 힘"
})

L:SetTimerLocalization({
	timerSpecial			= "다음 궁극의 힘",
	timerSpecialActive		= "궁극의 힘 종료"
})

L:SetOptionLocalization({
	warnSpecial				= "궁극의 힘 알림 보기", -- Show warning when Hurricane/Zephyr/Sleet Storm are cast",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial			= "궁극의 힘 특수 경고 보기",
	timerSpecial			= "다음 궁극의 힘 바 보기",
	timerSpecialActive		= "궁극의 힘 유지시간 바 보기",
	warnSpecialSoon			= "궁국의 힘 이전에 알림 보기(~10초 전)",
	OnlyWarnforMyTarget		= "대상/주시대상으로 선택한 우두머리에 관련된 알림/바만 보기<br/>(선택한 우두머리외 다른 알림/바는 숨김)"
})

L:SetMiscLocalization({
	gatherstrength			= "힘을 모으기 시작합니다!"
})

---------------
--  Al'Akir  --
---------------
L = DBM:GetModLocalization(155)

L:SetTimerLocalization({
	TimerFeedback 		= "역순환 (%d)"
})

L:SetOptionLocalization({
	TimerFeedback		= "$spell:87904 유지시간 바 보기",
	RangeFrame			= "$spell:89668 대상이 된 경우 거리 창 보기(20m)"
})

----------------
-- Beth'tilac --
----------------
L= DBM:GetModLocalization(192)

L:SetMiscLocalization({
	EmoteSpiderlings 	= "새끼거미가 둥지에서 쏟아져나옵니다!"
})

-------------------
-- Lord Rhyolith --
-------------------
L= DBM:GetModLocalization(193)

---------------
-- Alysrazor --
---------------
L= DBM:GetModLocalization(194)

L:SetWarningLocalization({
	WarnPhase			= "%d 단계",
	WarnNewInitiate		= "타오르는 발톱 수습생 (%s)"
})

L:SetTimerLocalization({
	TimerPhaseChange	= "%d 단계",
	TimerHatchEggs		= "녹아내린 알 부화",
	timerNextInitiate	= "다음 수습생 (%s)"
})

L:SetOptionLocalization({
	WarnPhase			= "단계 전환 알림 보기",
	WarnNewInitiate		= "타오르는 발톱 수습생 알림 보기",
	timerNextInitiate	= "다음 타오르는 발톱 수습생 등장 바 보기",
	TimerPhaseChange	= "단계 전환 바 보기",
	TimerHatchEggs		= "녹아내린 알 부화 바 보기"
})

L:SetMiscLocalization({
	YellPull		= "이제 난 새 주인님을 섬긴다. 필멸자여!",
	YellPhase2		= "이 하늘은 나의 것이다!",
	LavaWorms		= "불타는 용암 벌레가 땅에서 튀어나옵니다!",--Might use this one day if i feel it needs a warning for something. Or maybe pre warning for something else (like transition soon)
	East			= "오른쪽",
	West			= "왼쪽",
	Both			= "양쪽"
})

-------------
-- Shannox --
-------------
L= DBM:GetModLocalization(195)

-------------
-- Baleroc --
-------------
L= DBM:GetModLocalization(196)

L:SetWarningLocalization({
	warnStrike	= "%s (%d)"
})

L:SetTimerLocalization({
	timerStrike			= "다음 %s",
	TimerBladeActive	= "%s",
	TimerBladeNext		= "다음 칼날 활성화"
})

L:SetOptionLocalization({
	ResetShardsinThrees	= "$spell:99259 횟수 알림을 일정 단위마다 초기화(10인: 2회, 25인: 3회)",
	warnStrike			= "칼날 피해를 입을 때 알림 보기",
	timerStrike			= "칼날 공격 간격 바 보기",
	TimerBladeActive	= "활성화된 칼날 유지시간 바 보기",
	TimerBladeNext		= "다음 칼날 활성화 바 보기"
})

--------------------------------
-- Majordomo Fandral Staghelm --
--------------------------------
L= DBM:GetModLocalization(197)

L:SetTimerLocalization({
	timerNextSpecial	= "다음 %s (%d)"
})

L:SetOptionLocalization({
	timerNextSpecial		= "다음 불꽃 낫/화염도약 바 보기",
	RangeFrameSeeds			= "$spell:98450 대상이 된 경우 거리 창 보기(12m)",
	RangeFrameCat			= "$spell:98374 일때 거리 창 보기(10m)"
})

--------------
-- Ragnaros --
--------------
L= DBM:GetModLocalization(198)

L:SetWarningLocalization({
	warnRageRagnarosSoon	= "5초 후 %s : %s",
	warnSplittingBlow		= "%s (%s)",
	warnEngulfingFlame		= "%s (%s)",
	warnEmpoweredSulf		= "5초 후 %s"
})

L:SetTimerLocalization({
	timerRageRagnaros		= "%s : %s",--Spellname on targetname
	TimerPhaseSons			= "다음 단계"
})

L:SetOptionLocalization({
	warnSplittingBlow			= "$spell:98951 위치 알림 보기",
	warnEngulfingFlame			= "$spell:99171 위치 알림 보기(일반)",
	warnEngulfingFlameHeroic	= "$spell:99171 위치 알림 보기(영웅)",
	warnSeedsLand				= "$spell:98520 주문이 시전될 때가 아니라 착지되는 시간에 맞는 알림/바 보기",
	TimerPhaseSons				= "사잇단계 지속시간 바 보기",
	InfoHealthFrame				= "체력이 낮은 대상을 정보 창으로 보기(10만 미만)",
	MeteorFrame					= "$spell:99849 대상을 정보 창으로 보기",
	AggroFrame					= "$journal:2647 에게 위협 수준이 없는 대상을 정보 창으로 보기"
})

L:SetMiscLocalization({
	East				= "오른쪽",
	West				= "왼쪽",
	Middle				= "중앙",
	North				= "근접",
	South				= "뒤쪽",
	HealthInfo			= "체력 10만 미만",
	HasNoAggro			= "위협수준 없음",
	MeteorTargets		= "유성 조심!",--Keep rollin' rollin' rollin' rollin'.
	TransitionEnded1	= "여기까지! 이제 끝내주마.",--More reliable then adds method.
	TransitionEnded2	= "설퍼라스로 숨통을 끊어 주마.",
	TransitionEnded3	= "무릎 꿇어라, 필멸자여! 끝낼 시간이다.",
	Defeat				= "조금만!... 조금만 시간이 더 있었어도...",
	Phase4				= "너무 일러..."
})

-----------------------
--  Firelands Trash  --
-----------------------
L = DBM:GetModLocalization("FirelandsTrash")

L:SetGeneralLocalization({
	name = "불의 땅: 일반구간"
})

----------------
--  Volcanus  --
----------------
L = DBM:GetModLocalization("Volcanus")

L:SetGeneralLocalization({
	name = "볼카누스"
})

L:SetTimerLocalization({
	timerStaffTransition	= "다음 단계"
})

L:SetOptionLocalization({
	timerStaffTransition	= "다음 단계 바 보기"
})

L:SetMiscLocalization({
	StaffEvent			= "(%S+)|1이;가; 놀드랏실의 가지를 건드리자 격렬하게 반응합니다!",
	StaffTrees			= "불타는 나무정령이 수호정령을 돕기 위해 땅에서 일어납니다!",--Might add a spec warning for this later.
	StaffTransition		= "고통받는 수호정령을 태우는 불이 사그라졌습니다!"
})

-----------------------
--  Nexus Legendary  --
-----------------------
L = DBM:GetModLocalization("NexusLegendary")

L:SetGeneralLocalization({
	name = "티리나르"
})

-------------
-- Morchok --
-------------
L= DBM:GetModLocalization(311)

L:SetWarningLocalization({
	KohcromWarning	= "%s: %s"
})

L:SetTimerLocalization({
	KohcromCD		= "크초르모 시전: %s"
})

L:SetOptionLocalization({
	KohcromWarning	= "$journal:4262가 사용한 주문 알림 보기(영웅 난이도)",
	KohcromCD		= "$journal:4262가 사용할 주문 바 보기(영웅 난이도)",
	RangeFrame		= "거리 창 보기(5m, 업적 용도)"
})

---------------------
-- Warlord Zon'ozz --
---------------------
L= DBM:GetModLocalization(324)

L:SetOptionLocalization({
	ShadowYell			= "$spell:103434 대상이 된 경우 대화로 알리기(영웅 난이도)",
	CustomRangeFrame	= "교란의 그림자 관련 거리 창 설정(영웅 난이도)",
	Never				= "거리 창 사용안함",
	Normal				= "일반 거리 창",
	DynamicPhase2		= "고라스의 검은 피 도중에만 숨기기 사용",
	DynamicAlways		= "항상 약화효과 숨기기 사용"
})

L:SetMiscLocalization({
	voidYell	= "굴카와스 언고브 느조스."
})

-----------------------------
-- Yor'sahj the Unsleeping --
-----------------------------
L= DBM:GetModLocalization(325)

L:SetWarningLocalization({
	warnOozesHit	= "핏방울 흡수 (%s) : %s"
})

L:SetTimerLocalization({
	timerOozesActive	= "핏방울 공격 가능",
	timerOozesReach		= "핏방울 도착"
})

L:SetOptionLocalization({
	warnOozesHit		= "흡수된 핏방울 알림 보기",
	timerOozesActive	= "핏방울 공격 가능 바 보기",
	timerOozesReach		= "핏방울 도착 바 보기",
	RangeFrame			= "$spell:104898 활성화 중에 거리 창 보기(4m)(일반 난이도 이상)"
})

L:SetMiscLocalization({
	Black			= "|cFF424242검정|r",
	Purple			= "|cFF9932CD보라|r",
	Red				= "|cFFFF0404빨강|r",
	Green			= "|cFF088A08초록|r",
	Blue			= "|cFF0080FF파랑|r",
	Yellow			= "|cFFFFA901노랑|r"
})

-----------------------
-- Hagara the Binder --
-----------------------
L= DBM:GetModLocalization(317)

L:SetWarningLocalization({
	WarnPillars				= "%s : %d 남음",
	warnFrostTombCast		= "8초 후 %s"
})

L:SetTimerLocalization({
	TimerSpecial			= "다음 번개/얼음"
})

L:SetOptionLocalization({
	WarnPillars				= "$journal:3919 또는 $journal:4069 남은횟수 알림 보기",
	TimerSpecial			= "다음 $spell:105256 또는 $spell:105465 바 보기",
	RangeFrame				= "$spell:105269(3m), $journal:4327(10m) 대상이 된 경우 거리 창 보기",
	AnnounceFrostTombIcons	= "$spell:104451 대상을 공격대 대화로 알리기(승급 권한 필요)",
	SpecialCount			= "$spell:105256 또는 $spell:105465 이전에 소리 듣기",
	SetBubbles				= "$spell:104451이 가능할 때 대화 말풍선을 숨김<br/>(전투 종료 후 원상태로 복구됨)"
})

L:SetMiscLocalization({
	TombIconSet				= "얼음 무덤 아이콘 : {rt%d} %s"
})

---------------
-- Ultraxion --
---------------
L= DBM:GetModLocalization(331)

L:SetWarningLocalization({
	specWarnHourofTwilightN		= "5초 후 %s! (%d)"
})

L:SetTimerLocalization({
	TimerCombatStart	= "울트락시온 활성화"
})

L:SetOptionLocalization({
	TimerCombatStart	= "울트락시온 활성화 바 보기",
	ResetHoTCounter		= "황혼의 시간 횟수 재시작 설정",
	Never				= "사용 안함",
	ResetDynamic		= "일반 2회, 영웅 3회 단위로 재시작",
	Reset3Always		= "난이도 구분 없이 3회 단위로 재시작",
	SpecWarnHoTN		= "황혼의 시간 5초 전 특수 경고 설정(횟수 재시작 설정 필요)",
	One					= "횟수가 1일때 보기(또는 1, 4, 7 일때)",
	Two					= "횟수가 2일때 보기(또는 2, 5 일때)",
	Three				= "횟수가 3일때 보기(또는 3, 6 일때)"
})

L:SetMiscLocalization({
	Pull				= "엄청난 무언가가 느껴진다. 조화롭지 못한 그의 혼돈이 내 정신을 어지럽히는구나!"
})

-------------------------
-- Warmaster Blackhorn --
-------------------------
L= DBM:GetModLocalization(332)

L:SetWarningLocalization({
	SpecWarnElites	= "황혼의 정예병!"
})

L:SetTimerLocalization({
	TimerCombatStart	= "전투 시작",
	TimerAdd			= "다음 정예병"
})

L:SetOptionLocalization({
	TimerCombatStart	= "전투 시작 바 보기",
	TimerAdd			= "다음 황혼의 정예병 등장 바 보기",
	SpecWarnElites		= "황혼의 정예병 등장시 특수 경고 보기",
	SetTextures			= "1 단계 진행 도중 텍스쳐 투영 효과 끄기<br/>(2 단계에서 다시 활성화 됩니다.)"
})

L:SetMiscLocalization({
	SapperEmote			= "비룡이 빠르게 날아와 황혼의 폭파병을 갑판에 떨어뜨립니다!",
	GorionaRetreat		= "%s|1이;가; 고통에 울부짖으며, 소용돌이치는 구름 속으로 달아납니다."
})

-------------------------
-- Spine of Deathwing  --
-------------------------
L= DBM:GetModLocalization(318)

L:SetWarningLocalization({
	warnSealArmor			= "%s",
	SpecWarnTendril			= "등에 달라 붙으세요!"
})

L:SetOptionLocalization({
	SpecWarnTendril			= "$spell:105563 효과가 없을 경우 특수 경고 보기",
	InfoFrame				= "$spell:105563 없는 대상을 정보 창으로 보기",
	ShowShieldInfo			= "$spell:105479 흡수량 바 보기(우두머리 체력 바 설정 무시)"
})

L:SetMiscLocalization({
	Pull			= "저 갑옷! 놈의 갑옷이 벗겨지는군! 갑옷을 뜯어내면 놈을 쓰러뜨릴 기회가 생길 거요!",
	NoDebuff		= "%s 없음",
	PlasmaTarget	= "이글거리는 혈장: %s",
	DRoll			= "회전하려고",
	DLevels			= "수평으로 균형을"
})

---------------------------
-- Madness of Deathwing  --
---------------------------
L= DBM:GetModLocalization(333)

L:SetOptionLocalization({
	RangeFrame			= "$spell:108649 효과에 맞추어 거리 창 보기(영웅 난이도)"
})

L:SetMiscLocalization({
	Pull				= "넌 아무것도 못 했다. 내가 이 세상을 조각내주마."
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("DSTrash")

L:SetGeneralLocalization({
	name =	"용의 영혼: 일반구간"
})

L:SetWarningLocalization({
	DrakesLeft			= "황혼의 습격자 : %d 남음"
})

L:SetTimerLocalization({
	timerRoleplay		= "이벤트 진행",
	TimerDrakes			= "%s"
})

L:SetOptionLocalization({
	DrakesLeft			= "황혼의 습격자 남은횟수 알림 보기",
	TimerDrakes			= "$spell:109904까지 남은시간 바 보기"
})

L:SetMiscLocalization({
	firstRP				= "티탄을 찬양하라. 그들이 돌아왔다!",
	UltraxionTrash		= "다시 만나 반갑군, 알렉스트라자. 난 떠나 있는 동안 좀 바쁘게 지냈다.",
	UltraxionTrashEnded	= "가련한 녀석들, 이 실험은 위대한 결말을 위한 희생이었다. 알 연구의 결과물을 직접 확인해라."
})
