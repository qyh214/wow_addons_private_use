if GetLocale() ~= "koKR" then return end

local L
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
