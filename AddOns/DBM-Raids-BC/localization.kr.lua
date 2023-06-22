if GetLocale() ~= "koKR" then return end

local L

---------------
--  Kalecgos --
---------------
L = DBM:GetModLocalization("Kal")

L:SetGeneralLocalization{
	name = "칼렉고스"
}

L:SetWarningLocalization{
	WarnPortal			= "정신 세계 #%d : >%s< (%d 파티)",
	SpecWarnWildMagic	= "마법 폭주 - %s!"
}

L:SetOptionLocalization{
	WarnPortal			= "$spell:46021 대상 알림 보기",
	SpecWarnWildMagic	= "마법 폭주 대상이 된 경우 특수 경고 보기",
	ShowFrame			= "정신 세계에 있는 공격대원을 별도 창으로 보기" ,
	FrameClassColor		= "정신 세계 창 직업 색상 사용",
	FrameUpwards		= "정신 세계 창 바를 위쪽으로 확장",
	FrameLocked			= "정신 세계 창 고정(이동불가로 설정)"
}

L:SetMiscLocalization{
	Demon				= "타락의 사스로바르",
	Heal				= "치유량 100% 증가",
	Haste				= "시전속도 100% 증가",
	Hit					= "물리 적중률 50% 감소",
	Crit				= "치명타 대미지 100% 증가",
	Aggro				= "위협수준 생성 100% 증가",
	Mana				= "마나 소모량 50% 감소",
	FrameTitle			= "정신 세계",
	FrameLock			= "프레임 잠금",
	FrameClassColor		= "직업 색상 사용",
	FrameOrientation	= "위로 확장",
	FrameHide			= "프레임 숨김",
	FrameClose			= "메뉴 닫기"
}

----------------
--  Brutallus --
----------------
L = DBM:GetModLocalization("Brutallus")

L:SetGeneralLocalization{
	name = "브루탈루스"
}

L:SetMiscLocalization{
	Pull			= "하, 새끼 양이 잔뜩 몰려오는구나!"
}

--------------
--  Felmyst --
--------------
L = DBM:GetModLocalization("Felmyst")

L:SetGeneralLocalization{
	name = "지옥안개"
}

L:SetWarningLocalization{
	WarnPhase		= "%s 단계"
}

L:SetTimerLocalization{
	TimerPhase		= "다음 %s 단계"
}

L:SetOptionLocalization{
	WarnPhase		= "단계 전환 알림 보기",
	TimerPhase		= "다음 단계 바 보기"
}

L:SetMiscLocalization{
	Air				= "비행",
	Ground			= "지상",
	AirPhase		= "나는 어느 때보다도 강하다!",
	Breath			= "숨을 깊게 들이마십니다."
}

-----------------------
--  The Eredar Twins --
-----------------------
L = DBM:GetModLocalization("Twins")

L:SetGeneralLocalization{
	name = "에레다르 쌍둥이"
}

L:SetMiscLocalization{
	Nova			= "방향을 돌려 암흑 회오리를",
	Conflag			= "방향을 돌려 거대한 불길을",
	Sacrolash		= "여군주 사크로래쉬",
	Alythess		= "대흑마법사 알리테스"
}

------------
--  M'uru --
------------
L = DBM:GetModLocalization("Muru")

L:SetGeneralLocalization{
	name = "므우루"
}

L:SetWarningLocalization{
	WarnHuman		= "타락한 엘프 (%d)",
	WarnVoid		= "공허의 파수병 (%d)",
	WarnFiend		= "어둠 마귀"
}

L:SetTimerLocalization{
	TimerHuman		= "다음 타락한 엘프 (%s)",
	TimerVoid		= "다음 공허의 파수병 (%s)",
	TimerPhase		= "엔트로피우스"
}

L:SetOptionLocalization{
	WarnHuman		= "타락한 엘프 알림 보기",
	WarnVoid		= "공허의 파수병 알림 보기",
	WarnFiend		= "어둠 마귀 알림 보기",
	TimerHuman		= "다음 타락한 엘프 바 보기",
	TimerVoid		= "다음 공허의 파수병 바 보기",
	TimerPhase		= "2 단계 바 보기"
}

L:SetMiscLocalization{
	Entropius		= "엔트로피우스"
}

----------------
--  Kil'jeden --
----------------
L = DBM:GetModLocalization("Kil")

L:SetGeneralLocalization{
	name = "킬제덴"
}

L:SetWarningLocalization{
	WarnDarkOrb		= "보호의 구슬 생성",
	WarnBlueOrb		= "푸른용의 수정구",
	SpecWarnDarkOrb	= "보호의 구슬 생성!",
	SpecWarnBlueOrb	= "푸른용의 수정구 활성화!"
}

L:SetTimerLocalization{
	TimerBlueOrb	= "수정구 활성화"
}

L:SetOptionLocalization{
	WarnDarkOrb		= "보호의 구슬 생성 알림 보기",
	WarnBlueOrb		= "푸른용의 수정구 알림 보기",
	SpecWarnDarkOrb	= "보호의 구슬 생성 특수 경고 보기",
	SpecWarnBlueOrb	= "푸른용의 수정구 활성화 특수 경고 보기",
	TimerBlueOrb	= "푸른용의 수정구 활성화 바 보기"
}

L:SetMiscLocalization{
	YellPull		= "녀석들은 소모품일 뿐이다. 자, 봐라! 살게라스가 해내지 못한 일을 내가 해낼 것이다! 이 보잘것없는 세상을 갈가리 찢어발기고 불타는 군단의 진정한 주인으로 우뚝 서리라! 종말이 다가왔다! 어디 한번 세계를 구해 봐라!",
	OrbYell1		= "수정구에 힘을 쏟겠습니다! 준비하세요!",
	OrbYell2		= "다른 수정구에 힘을 불어넣었습니다! 어서요!",
	OrbYell3		= "다른 수정구가 준비됐습니다! 서두르세요!",
	OrbYell4		= "모든 힘을 수정구에 실었습니다! 이제 그대들의 몫입니다!"
}

-----------------
--  Najentus  --
-----------------
L = DBM:GetModLocalization("Najentus")

L:SetGeneralLocalization{
	name = "대장군 나젠투스"
}

L:SetOptionLocalization{
	InfoFrame	= "체력이 낮은 대상을 정보 창으로 보기(8800 미만)"
}

L:SetMiscLocalization{
	HealthInfo	= "체력 정보"
}

----------------
-- Supremus --
----------------
L = DBM:GetModLocalization("Supremus")

L:SetGeneralLocalization{
	name = "궁극의 심연"
}

L:SetWarningLocalization{
	WarnPhase		= "%s 단계",
	WarnKite		= "추적 : >%s<"
}

L:SetTimerLocalization{
	TimerPhase		= "다음 %s 단계"
}

L:SetOptionLocalization{
	WarnPhase		= "단계 전환 알림 보기",
	WarnKite		= "추적 대상 알림 보기",
	TimerPhase		= "다음 단계 바 보기",
	KiteIcon		= "추적 대상에게 전술 목표 아이콘 설정"
}

L:SetMiscLocalization{
	PhaseTank		= "땅이 갈라져서 열리기 시작합니다!",--Check if Backwards
	PhaseKite		= "분노하여 땅을 내리찍습니다!",--Check if Backwards
	ChangeTarget	= "새로운 대상이 필요합니다!",
	Kite			= "추적",
	Tank			= "일반"
}

-------------------------
--  Shape of Akama  --
-------------------------
L = DBM:GetModLocalization("Akama")

L:SetGeneralLocalization{
	name = "아카마의 망령"
}

L:SetWarningLocalization({
	warnAshtongueDefender	= "잿빛혓바닥 수호병",
	warnAshtongueSorcerer	= "잿빛혓바닥 사술사"
})

L:SetTimerLocalization({
	timerAshtongueDefender	= "잿빛혓바닥 수호병: %s",
	timerAshtongueSorcerer	= "잿빛혓바닥 사술사: %s"
})

L:SetOptionLocalization({
	warnAshtongueDefender	= "잿빛혓바닥 수호병 경고 보기",
	warnAshtongueSorcerer	= "잿빛혓바닥 사술사 경고 보기",
	timerAshtongueDefender	= "잿빛혓바닥 수호병 타이머 바 보기",
	timerAshtongueSorcerer	= "잿빛혓바닥 사술사 타이머 바 보기"
})

-------------------------
--  Teron Gorefiend  --
-------------------------
L = DBM:GetModLocalization("TeronGorefiend")

L:SetGeneralLocalization{
	name = "테론 고어핀드"
}

L:SetTimerLocalization{
	TimerVengefulSpirit		= "유령 : %s"
}

L:SetOptionLocalization{
	TimerVengefulSpirit		= "유령 유지시간 바 보기"
}

----------------------------
--  Gurtogg Bloodboil  --
----------------------------
L = DBM:GetModLocalization("Bloodboil")

L:SetGeneralLocalization{
	name = "구르토그 블러드보일"
}

--------------------------
--  Essence Of Souls  --
--------------------------
L = DBM:GetModLocalization("Souls")

L:SetGeneralLocalization{
	name = "영혼의 성물함"
}

L:SetWarningLocalization{
	WarnMana		= "30초 후 마나 0"
}

L:SetTimerLocalization{
	TimerMana		= "마나 0"
}

L:SetOptionLocalization{
	WarnMana		= "2 단계 에서 마나 0 이 되기 30초 전에 알림 보기",
	TimerMana		= "마나 0까지 남은시간 바 보기"
}

L:SetMiscLocalization{
	Suffering		= "고뇌의 정수",
	Desire			= "욕망의 정수",
	Anger			= "격노의 정수"
}

-----------------------
--  Mother Shahraz --
-----------------------
L = DBM:GetModLocalization("Shahraz")

L:SetGeneralLocalization{
	name = "대모 샤라즈"
}

L:SetTimerLocalization{
	timerAura	= "%s"
}

L:SetOptionLocalization{
	timerAura	= "변위의 오라 바 보기"
}

----------------------
--  Illidari Council  --
----------------------
L = DBM:GetModLocalization("Council")

L:SetGeneralLocalization{
	name = "일리다리 의회"
}

L:SetWarningLocalization{
	Immune			= "말란데 - 15초간 %s 면역!"
}

L:SetOptionLocalization{
	Immune			= "말란데가 물리 또는 주문 면역이 되었을 때 특수 경고 보기"
}

L:SetMiscLocalization{
	Gathios			= "파괴자 가디오스",
	Malande			= "여군주 말란데",
	Zerevor			= "고위 황천술사 제레보르",
	Veras			= "베라스 다크섀도",
	Melee			= "물리",
	Spell			= "주문"
}

-------------------------
--  Illidan Stormrage --
-------------------------
L = DBM:GetModLocalization("Illidan")

L:SetGeneralLocalization{
	name = "일리단 스톰레이지"
}

L:SetWarningLocalization{
	WarnHuman		= "인간 형상",
	WarnDemon		= "악마 형상"
}

L:SetTimerLocalization{
	TimerNextHuman		= "다음 인간 형상",
	TimerNextDemon		= "다음 악마 형상"
}

L:SetOptionLocalization{
	WarnHuman		= "인간 형상 알림 보기",
	WarnDemon		= "악마 형상 알림 보기",
	TimerNextHuman	= "다음 인간 형상 바 보기",
	TimerNextDemon	= "다음 악마 형상 바 보기",
	RangeFrame		= "3, 4 단계에서 거리 창 보기(10m)"
}

L:SetMiscLocalization{
	Pull			= "아카마, 너의 불충은 그리 놀랍지도 않구나. 너희 흉측한 형제들을 벌써 오래전에 없애버렸어야 했는데...",
	Eyebeam			= "배신자의 눈을 똑바로 쳐다봐라!",
	Demon			= "내 안에 깃든... 악마의 힘을 보여주마!",
	Phase4			= "필멸의 종족들이여, 나에 대한 증오가 고작 이 정도냐?"
}

------------------------
--  Rage Winterchill  --
------------------------
L = DBM:GetModLocalization("Rage")

L:SetGeneralLocalization{
	name = "격노한 윈터칠"
}

-----------------
--  Anetheron  --
-----------------
L = DBM:GetModLocalization("Anetheron")

L:SetGeneralLocalization{
	name = "아네테론"
}

----------------
--  Kazrogal  --
----------------
L = DBM:GetModLocalization("Kazrogal")

L:SetGeneralLocalization{
	name = "카즈로갈"
}

---------------
--  Azgalor  --
---------------
L = DBM:GetModLocalization("Azgalor")

L:SetGeneralLocalization{
	name = "아즈갈로"
}

------------------
--  Archimonde  --
------------------
L = DBM:GetModLocalization("Archimonde")

L:SetGeneralLocalization{
	name = "아키몬드"
}

----------------
-- WaveTimers --
----------------
L = DBM:GetModLocalization("HyjalWaveTimers")

L:SetGeneralLocalization{
	name 		= "하이잘: 일반구간"
}

L:SetWarningLocalization{
	WarnWave	= "%s",
}

L:SetTimerLocalization{
	TimerWave	= "다음 공격"
}

L:SetOptionLocalization{
	WarnWave		= "다음 공격 알림 보기",
	DetailedWave	= "다음 공격 알림시 적 조합까지 자세히 보기",
	TimerWave		= "다음 공격 바 보기"
}

L:SetMiscLocalization{
	HyjalZoneName	= "하이잘 정상",
	Thrall			= "스랄",
	Jaina			= "제이나 프라우드무어",
	GeneralBoss		= "곧 우두머리",
	RageWinterchill	= "곧 격노한 윈터칠",
	Anetheron		= "곧 아네테론",
	Kazrogal		= "곧 카즈로갈",
	Azgalor			= "곧 아즈갈로",
	WarnWave_0		= "공격 %s/8",
	WarnWave_1		= "공격 %s/8 - %s %s",
	WarnWave_2		= "공격 %s/8 - %s %s, %s %s",
	WarnWave_3		= "공격 %s/8 - %s %s, %s %s, %s %s",
	WarnWave_4		= "공격 %s/8 - %s %s, %s %s, %s %s, %s %s",
	WarnWave_5		= "공격 %s/8 - %s %s, %s %s, %s %s, %s %s, %s %s",
	RageGossip		= "제 동료와 저는 프라우드무어 님, 당신과 함께하겠습니다.",
	AnetheronGossip	= "아키몬드가 어떤 군대를 보내던 우리는 준비가 되어 있습니다, 프라우드무어 님.",
	KazrogalGossip	= "당신과 함께하겠습니다, 대족장님.",
	AzgalorGossip	= "두려워할 것은 아무것도 없습니다.",
	Ghoul			= "구울",
	Abomination		= "누더기골렘",
	Necromancer		= "강령술사",
	Banshee			= "밴시",
	Fiend			= "지하마귀",
	Gargoyle		= "가고일",
	Wyrm			= "서리고룡",
	Stalker			= "지옥사냥개",
	Infernal		= "지옥불정령"
}

-----------
--  Alar --
-----------
L = DBM:GetModLocalization("Alar")

L:SetGeneralLocalization{
	name = "알라르"
}

L:SetTimerLocalization{
	NextPlatform	= "단상 머무름"
}

L:SetOptionLocalization{
	NextPlatform	= "단상 머무름 바 보기(더 빨리 떠날수는 있으나 더 늦게 떠나진 않습니다.)"
}

------------------
--  Void Reaver --
------------------
L = DBM:GetModLocalization("VoidReaver")

L:SetGeneralLocalization{
	name = "공허의 절단기"
}

--------------------------------
--  High Astromancer Solarian --
--------------------------------
L = DBM:GetModLocalization("Solarian")

L:SetGeneralLocalization{
	name = "고위 점성술사 솔라리안"
}

L:SetWarningLocalization{
	WarnSplit		= "분리",
	WarnAgent		= "요원",
	WarnPriest		= "사제/솔라리안",

}

L:SetTimerLocalization{
	TimerSplit		= "다음 분리",
	TimerAgent		= "다음 요원",
	TimerPriest		= "다음 사제/솔라리안"
}

L:SetOptionLocalization{
	WarnSplit		= "분리 알림 보기",
	WarnAgent		= "요원 등장 알림 보기",
	WarnPriest		= "사제/솔라리안 등장 알림 보기",
	TimerSplit		= "다음 분리 바 보기",
	TimerAgent		= "다음 요원 바 보기",
	TimerPriest		= "다음 사제/솔라리안 바 보기"
}

L:SetMiscLocalization{
	YellSplit1		= "그 오만한 콧대를 꺾어주마!",
	YellSplit2		= "한 줌의 희망마저 짓밟아주마!",
	YellPhase2		= "나는 공허의"
}

---------------------------
--  Kael'thas Sunstrider --
---------------------------
L = DBM:GetModLocalization("KaelThas")

L:SetGeneralLocalization{
	name = "캘타스 선스트라이더"
}

L:SetWarningLocalization{
	WarnGaze		= "추적: >%s<",
	WarnMobDead		= "%s 처치",
	WarnEgg			= "불사조 알 생성",
	SpecWarnGaze	= "당신을 추적 - 도망치세요!",
	SpecWarnEgg		= "불사조 알 생성 - 대상 전환!"
}

L:SetTimerLocalization{
	TimerPhase		= "다음 단계",
	TimerPhase1mob	= "%s",
	TimerNextGaze	= "추적 대상 변경",
	TimerRebirth	= "불사조 환생 가능"
}

L:SetOptionLocalization{
	WarnGaze		= "탈라드레드 추적 대상 알림 보기",
	WarnMobDead		= "무기 처치 알림 보기",
	WarnEgg			= "불사조 알 생성 알림 보기",
	SpecWarnGaze	= "탈라드레드 추적 대상이 된 경우 특수 경고 보기",
	SpecWarnEgg		= "불사조 알 생성 특수 경고 보기",
	TimerPhase		= "다음 단계 바 보기",
	TimerPhase1mob	= "1단계 조언가 등장 바 보기",
	TimerNextGaze	= "탈라드레드 추적 대상 변경 바 보기",
	TimerRebirth	= "불사조 알 환생 가능 바 보기",
	GazeIcon		= "탈라드레드 추적 대상에게 전술 목표 아이콘 설정"
}

L:SetMiscLocalization{
	YellPhase2	= "보다시피 내 무기고에는 굉장한 무기가 아주 많지.",
	YellPhase3	= "네놈들을 과소평가했나 보군. 모두를 한꺼번에 상대하라는 건 불공평한 처사지만, 나의 백성도 공평한 대접을 받은 적 없기는 매한가지. 받은 대로 돌려주겠다.",
	YellPhase4	= "때론 직접 나서야 할 때도 있는 법이지. 발라모어 샤날!",
	YellPhase5	= "이대로 물러날 내가 아니다! 반드시 내가 설계한 미래를 실현하리라! 이제 진정한 힘을 느껴 보아라!",
	YellSang	= "최고의 조언가를 상대로 잘도 버텨냈군. 허나 그 누구도 붉은 망치의 힘에는 대항할 수 없지. 보아라, 군주 생귀나르를!",
	YellCaper	= "카퍼니안, 놈들이 여기 온 것을 후회하게 해 줘라.",
	YellTelo	= "좋아, 그 정도 실력이면 수석기술자 텔로니쿠스를 상대해 볼만하겠어.",
	EmoteGaze	= "노려봅니다!",
	Thaladred	= "암흑의 인도자 탈라드레드",
	Sanguinar	= "군주 생귀나르",
	Capernian	= "대점성술사 카퍼니안",
	Telonicus	= "수석기술자 텔로니쿠스",
	Bow			= "황천매듭 장궁",
	Axe			= "참상의 도끼",
	Mace		= "우주 에너지 주입기(둔기)",
	Dagger		= "무한의 비수(단검)",
	Sword		= "차원 절단기(도검)",
	Shield		= "위상 변화의 보루 방패",
	Staff		= "붕괴의 지팡이",
	Egg			= "불사조 알"
}

---------------------------
--  Hydross the Unstable --
---------------------------
L = DBM:GetModLocalization("Hydross")

L:SetGeneralLocalization{
	name = "불안정한 히드로스"
}

L:SetWarningLocalization{
	WarnMark 		= "%s : %s",
	WarnPhase		= "%s 단계",
	SpecWarnMark	= "%s : %s"
}

L:SetTimerLocalization{
	TimerMark	= "다음 %s : %s"
}

L:SetOptionLocalization{
	WarnMark		= "징표 알림 보기",
	WarnPhase		= "단계 전환 알림 보기",
	SpecWarnMark	= "징표 피해가 100%를 넘을 경우 특수 경고 보기",
	TimerMark		= "다음 징표 바 보기"
}

L:SetMiscLocalization{
	Frost	= "냉기",
	Nature	= "자연"
}

-----------------------
--  The Lurker Below --
-----------------------
L = DBM:GetModLocalization("LurkerBelow")

L:SetGeneralLocalization{
	name = "심연의 잠복꾼"
}

L:SetWarningLocalization{
	WarnSubmerge		= "잠수",
	WarnEmerge			= "재등장"
}

L:SetTimerLocalization{
	TimerSubmerge		= "잠수",
	TimerEmerge			= "재등장"
}

L:SetOptionLocalization{
	WarnSubmerge		= "잠수 알림 보기",
	WarnEmerge			= "재등장 알림 보기",
	TimerSubmerge		= "다음 잠수 바 보기",
	TimerEmerge			= "다음 재등장 바 보기"
}

--------------------------
--  Leotheras the Blind --
--------------------------
L = DBM:GetModLocalization("Leotheras")

L:SetGeneralLocalization{
	name = "눈먼 레오테라스"
}

L:SetWarningLocalization{
	WarnPhase		= "%s 단계"
}

L:SetTimerLocalization{
	TimerPhase	= "다음 %s 단계"
}

L:SetOptionLocalization{
	WarnPhase		= "단계 전환 알림 보기",
	TimerPhase		= "다음 단계 바 보기"
}

L:SetMiscLocalization{
	Human		= "인간",
	Demon		= "악마",
	YellDemon	= "꺼져라, 엘프 꼬맹이. 지금부터는 내가 주인이다!",
	YellPhase1  = "드디어, 내가 풀려났도다!",
	YellPhase2	= "안 돼... 안 돼! 무슨 짓이냐? 내가 주인이야! 내 말 듣지 못해? 나란 말이야! 내가... 으아악! 놈을 억누를 수... 없...어."
}

-----------------------------
--  Fathom-Lord Karathress --
-----------------------------
L = DBM:GetModLocalization("Fathomlord")

L:SetGeneralLocalization{
	name = "심해군주 카라드레스"
}

L:SetMiscLocalization{
	Caribdis	= "심연의 경비병 카리브디스",
	Tidalvess	= "심연의 경비병 타이달베스",
	Sharkkis	= "심연의 경비병 샤르키스"
}

--------------------------
--  Morogrim Tidewalker --
--------------------------
L = DBM:GetModLocalization("Tidewalker")

L:SetGeneralLocalization{
	name = "겅둥파도 모로그림"
}

L:SetWarningLocalization{
	WarnMurlocs		= "멀록 소환",
	SpecWarnMurlocs	= "멀록 소환!"
}

L:SetTimerLocalization{
	TimerMurlocs	= "다음 멀록 소환"
}

L:SetOptionLocalization{
	WarnMurlocs		= "멀록 소환 알림 보기",
	SpecWarnMurlocs	= "멀록 소환 특수 경고 보기",
	TimerMurlocs	= "다음 멀록 소환 바 보기"
}

-----------------
--  Lady Vashj --
-----------------
L = DBM:GetModLocalization("Vashj")

L:SetGeneralLocalization{
	name = "여군주 바쉬"
}

L:SetWarningLocalization{
	WarnElemental			= "곧 오염된 정령 등장 (%s)",
	WarnStrider				= "곧 포자손 등장 (%s)",
	WarnNaga				= "곧 나가 등장 (%s)",
	WarnShield				= "보호막 %d/4 남음",
	WarnLoot				= "오염된 핵: >%s<",
	SpecWarnElemental		= "오염된 정령 - 대상 전환!"
}

L:SetTimerLocalization{
	TimerElementalActive	= "오염된 정령 활성화",
	TimerElemental			= "오염된 정령 가능 (%d)",
	TimerStrider			= "다음 포자손 (%d)",
	TimerNaga				= "다음 나가 (%d)"
}

L:SetOptionLocalization{
	WarnElemental			= "오염된 정령 등장 이전에 알림 보기",
	WarnStrider				= "포자손 등장 이전에 알림 보기",
	WarnNaga				= "나가 등장 이전에 알림 보기",
	WarnShield				= "보호막 사라짐 알림 보기",
	WarnLoot				= "오염된 핵 획득 대상 알림 보기",
	TimerElementalActive	= "오염된 정령 활성화 시간 바 보기",
	TimerElemental			= "오염된 정령 대기시간 바 보기",
	TimerStrider			= "다음 포자손 바 보기",
	TimerNaga				= "다음 나가 바 보기",
	SpecWarnElemental		= "오염된 정령 등장 특수 경고 보기",
	AutoChangeLootToFFA		= "2 단계에서 전리품 획득 설정 자동으로 변경"
}

L:SetMiscLocalization{
	DBM_VASHJ_YELL_PHASE2	= "때가 왔다! 한 놈도 살려두지 마라!",
	DBM_VASHJ_YELL_PHASE3	= "숨을 곳이나 마련해 둬라!",
	LootMsg					= "([^%s]+).*Hitem:(%d+)"
}

--Maulgar
L = DBM:GetModLocalization("Maulgar")

L:SetGeneralLocalization{
	name = "왕중왕 마울가르"
}


--Gruul the Dragonkiller
L = DBM:GetModLocalization("Gruul")

L:SetGeneralLocalization{
	name = "용 학살자 그룰"
}

L:SetWarningLocalization{
	WarnGrowth	= "%s (%d)"
}

L:SetOptionLocalization{
	WarnGrowth	= "$spell:36300 알림 보기",
	RangeDistance	= "|cff71d5ff|Hspell:33654|h산산조각|h|r 거리 창 범위 설정",
	Smaller			= "좁은 범위 (11m)",
	Safe			= "안전 범위 (18m)"
}

-- Magtheridon
L = DBM:GetModLocalization("Magtheridon")

L:SetGeneralLocalization{
	name = "마그테리돈"
}

L:SetTimerLocalization{
	timerP2	= "2 단계"
}

L:SetOptionLocalization{
	timerP2	= "2 단계 시작 바 보기"
}

L:SetMiscLocalization{
	DBM_MAG_EMOTE_PULL		= "%s의 속박이 약해지기 시작합니다!",--확인필요
	DBM_MAG_YELL_PHASE2		= "내가... 풀려났도다!",
	DBM_MAG_YELL_PHASE3		= "그렇게 쉽게"
}

--Attumen
L = DBM:GetModLocalization("Attumen")

L:SetGeneralLocalization{
	name = "사냥꾼 어튜멘"
}

L:SetMiscLocalization{
	DBM_ATH_YELL_1		= "이랴! 이 오합지졸을 데리고 실컷 놀아보자!"
}


--Moroes
L = DBM:GetModLocalization("Moroes")

L:SetGeneralLocalization{
	name = "모로스"
}

L:SetWarningLocalization{
	DBM_MOROES_VANISH_FADED	= "등장"
}

L:SetOptionLocalization{
	DBM_MOROES_VANISH_FADED	= "등장 알림 보기"
}


-- Maiden of Virtue
L = DBM:GetModLocalization("Maiden")

L:SetGeneralLocalization{
	name = "고결의 여신"
}


-- Romulo and Julianne
L = DBM:GetModLocalization("RomuloAndJulianne")

L:SetGeneralLocalization{
	name = "로밀로와 줄리엔"
}

L:SetMiscLocalization{
	Event				= "오늘 밤... 금지된 사랑의 이야기를 파헤쳐 보겠습니다!",
	RJ_Pull				= "당신들은 대체 누구시기에 절 이리도 괴롭히나요?",
	DBM_RJ_PHASE2_YELL	= "정다운 밤이시여. 어서 와서 나의 로밀로를 돌려주소서!",
	Romulo				= "로밀로",
	Julianne			= "줄리엔"
}


-- Big Bad Wolf
L = DBM:GetModLocalization("BigBadWolf")

L:SetGeneralLocalization{
	name = "커다란 나쁜 늑대"
}

L:SetMiscLocalization{
	DBM_BBW_YELL_1			= "잡아 먹기 좋으라고 그런거지!"
}


-- Wizard of Oz
L = DBM:GetModLocalization("Oz")

L:SetGeneralLocalization{
	name = "오즈의 마법사"
}

L:SetWarningLocalization{
	DBM_OZ_WARN_TITO		= "티토",
	DBM_OZ_WARN_ROAR		= "어흥이",
	DBM_OZ_WARN_STRAWMAN	= "허수아비",
	DBM_OZ_WARN_TINHEAD		= "양철나무꾼",
	DBM_OZ_WARN_CRONE		= "마녀"
}

L:SetTimerLocalization{
	DBM_OZ_WARN_TITO		= "티토",
	DBM_OZ_WARN_ROAR		= "어흥이",
	DBM_OZ_WARN_STRAWMAN	= "허수아비",
	DBM_OZ_WARN_TINHEAD		= "양철나무꾼"
}

L:SetOptionLocalization{
	AnnounceBosses			= "우두머리 등장 알림 보기",
	ShowBossTimers			= "우두머리 등장 바 보기"
}

L:SetMiscLocalization{
	DBM_OZ_YELL_DOROTHEE	= "티토야, 우린 집으로 갈 방법을 찾아야 해! 늙은 마법사가 우릴 도와줄 수 있을 거야! 허수아비, 사자, 양철통아... 우리? 오... 맙소사, 손님들이 온 것 같아!",
	DBM_OZ_YELL_ROAR		= "하나도 안 무섭다고! 덤벼! 앞발 두 개를 몽땅 꺼내서 할퀴어주마!",
	DBM_OZ_YELL_STRAWMAN	= "너희를 어떻게 해주면 좋을까? 아무 생각도 나지 않아!",
	DBM_OZ_YELL_TINHEAD		= "나도 심장 갖고 싶어. 너희들 것 나한테 주면 안 될까?",
	DBM_OZ_YELL_CRONE		= "곧 모두 다 끝장날 것이다!"
}


-- Curator
L = DBM:GetModLocalization("Curator")

L:SetGeneralLocalization{
	name = "전시 관리인"
}

L:SetWarningLocalization{
	warnAdd		= "별의 섬광"
}

L:SetOptionLocalization{
	warnAdd		= "별의 섬광 알림 보기"
}


-- Terestian Illhoof
L = DBM:GetModLocalization("TerestianIllhoof")

L:SetGeneralLocalization{
	name = "테레스티안 일후프"
}

L:SetMiscLocalization{
	Kilrek					= "킬렉",
	DChains					= "악마의 사슬"
}


-- Shade of Aran
L = DBM:GetModLocalization("Aran")

L:SetGeneralLocalization{
	name = "아란의 망령"
}

L:SetWarningLocalization{
	DBM_ARAN_DO_NOT_MOVE	= "화염의 고리 - 이동 금지!"
}

L:SetTimerLocalization{
	timerSpecial			= "다음 신폭/고리/눈보라"
}

L:SetOptionLocalization{
	timerSpecial			= "다음 $spell:30004 또는 $spell:29973 또는 $spell:29969 바 보기",
	DBM_ARAN_DO_NOT_MOVE	= "$spell:30004 특수 경고 보기"
}

--Netherspite
L = DBM:GetModLocalization("Netherspite")

L:SetGeneralLocalization{
	name = "황천의 원령"
}

L:SetWarningLocalization{
	warningPortal			= "차원문 단계",
	warningBanish			= "소멸 단계"
}

L:SetTimerLocalization{
	timerPortalPhase	= "차원문 단계 종료",
	timerBanishPhase	= "소멸 단계 종료"
}

L:SetOptionLocalization{
	warningPortal			= "차원문 단계 알림 보기",
	warningBanish			= "소멸 단계 알림 보기",
	timerPortalPhase		= "차원문 단계 유지시간 바 보기",
	timerBanishPhase		= "소멸 단계 유지시간 바 보기"
}

L:SetMiscLocalization{
	DBM_NS_EMOTE_PHASE_2	= "%s|1이;가; 황천의 기운을 받고 분노에 휩싸입니다!",
	DBM_NS_EMOTE_PHASE_1	= "%s|1이;가; 물러나며 고함을 지르더니 황천의 문을 엽니다."
}

--Chess
L = DBM:GetModLocalization("Chess")

L:SetGeneralLocalization{
	name = "체스 이벤트"
}

L:SetTimerLocalization{
	timerCheat	= "속임수 가능"
}

L:SetOptionLocalization{
	timerCheat	= "속임수 대기시간 바 보기"
}

L:SetMiscLocalization{
	EchoCheats	= "메디브의 메아리!"
}

--Prince Malchezaar
L = DBM:GetModLocalization("Prince")

L:SetGeneralLocalization{
	name = "공작 말체자르"
}

L:SetMiscLocalization{
	DBM_PRINCE_YELL_P2		= "바보 같으니! 시간은 너의 몸을 태우는 불길이 되리라!",
	DBM_PRINCE_YELL_P3		= "어찌 감히 이렇게 압도적인 힘에 맞서기를 꿈꾸느냐?",
	DBM_PRINCE_YELL_INF1	= "모든 차원과 실체가 나를 향해 열려 있노라!",
	DBM_PRINCE_YELL_INF2	= "이 말체자르님은 혼자가 아니시다. 너희는 나의 군대와 맞서야 한다!"
}


-- Nightbane
L = DBM:GetModLocalization("NightbaneRaid")

L:SetGeneralLocalization{
	name = "파멸의 어둠"
}

L:SetWarningLocalization{
	DBM_NB_AIR_WARN			= "공중 단계"
}

L:SetTimerLocalization{
	timerAirPhase			= "공중 단계 종료"
}

L:SetOptionLocalization{
	DBM_NB_AIR_WARN			= "공중 단계 알림 보기",
	timerAirPhase			= "공중 단계 유지시간 바 보기"
}

L:SetMiscLocalization{
	DBM_NB_EMOTE_PULL		= "멀리에서 고대의 존재가 깨어납니다...",
	DBM_NB_YELL_AIR			= "이 더러운 기생충들, 내가 하늘에서 너희의 씨를 말리리라!",
	DBM_NB_YELL_GROUND		= "그만! 내 친히 내려가서 너희를 짓이겨주마!",
	DBM_NB_YELL_GROUND2		= "하루살이 같은 놈들! 나의 힘을 똑똑히 보여주겠다!"
}


-- Named Beasts
L = DBM:GetModLocalization("Shadikith")

L:SetGeneralLocalization{
	name = "활강의 샤디키스"
}

L = DBM:GetModLocalization("Hyakiss")

L:SetGeneralLocalization{
	name = "잠복꾼 히아키스"
}

L = DBM:GetModLocalization("Rokad")

L:SetGeneralLocalization{
	name = "파괴자 로카드"
}

if WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1) then return end--Anything below here is only needed for classic wrath or classic bc

---------------
--  Nalorakk --
---------------
L = DBM:GetModLocalization("Nalorakk")

L:SetGeneralLocalization{
	name = "날로라크"
}

L:SetWarningLocalization{
	WarnBear		= "곰 형상",
	WarnBearSoon	= "5초 후 곰 형상",
	WarnNormal		= "일반 형상",
	WarnNormalSoon	= "5초 후 일반 형상"
}

L:SetTimerLocalization{
	TimerBear		= "곰 형상",
	TimerNormal		= "일반 형상"
}

L:SetOptionLocalization{
	WarnBear		= "곰 형상 경고 보기",
	WarnBearSoon	= "곰 형상 사전 경고 보기",
	WarnNormal		= "일반 형상 경고 보기",
	WarnNormalSoon	= "일반 형상 사전 경고 보기",
	TimerBear		= "곰 형상 타이머 바 보기",
	TimerNormal		= "일반 형상 타이머 바 보기"
}

L:SetMiscLocalization{
	YellBear 	= "너희들이 짐승을 불러냈다. 놀랄 준비나 해라!",
	YellNormal	= "날로라크 나가신다!"
}

---------------
--  Akil'zon --
---------------
L = DBM:GetModLocalization("Akilzon")

L:SetGeneralLocalization{
	name = "아킬존"
}

---------------
--  Jan'alai --
---------------
L = DBM:GetModLocalization("Janalai")

L:SetGeneralLocalization{
	name = "잔알라이"
}

L:SetMiscLocalization{
	YellBomb	= "태워버리겠다!",
	YellAdds	= "다 어디 갔지? 당장 알을 부화시켜!"
}

--------------
--  Halazzi --
--------------
L = DBM:GetModLocalization("Halazzi")

L:SetGeneralLocalization{
	name = "할라지"
}

L:SetWarningLocalization{
	WarnSpirit	= "영혼 단계",
	WarnNormal	= "일반 단계"
}

L:SetOptionLocalization{
	WarnSpirit	= "영혼 단계 경고 보기",
	WarnNormal	= "일반 단계 경고 보기"
}

L:SetMiscLocalization{
	YellSpirit	= "야생의 혼이 내 편이다...",
	YellNormal	= "혼이여, 이리 돌아오라!"
}

--------------------------
--  Hex Lord Malacrass --
--------------------------
L = DBM:GetModLocalization("Malacrass")

L:SetGeneralLocalization{
	name = "주술군주 말라크라스"
}

L:SetMiscLocalization{
	YellPull	= "너희에게 그림자가 드리우리라..."
}

--------------
--  Zul'jin --
--------------
L = DBM:GetModLocalization("ZulJin")

L:SetGeneralLocalization{
	name = "줄진"
}

L:SetMiscLocalization{
	YellPhase2	= "새로운 기술을 익혔지... 내 형제, 곰처럼...",
	YellPhase3	= "독수리의 눈을 피할 수는 없다!",
	YellPhase4	= "내 새로운 형제, 송곳니와 발톱을 보아라!",
	YellPhase5	= "용매를 하늘에서만 찾을 필요는 없다!"
}
