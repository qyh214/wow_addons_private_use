if GetLocale() ~= "koKR" then return end

local L

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
