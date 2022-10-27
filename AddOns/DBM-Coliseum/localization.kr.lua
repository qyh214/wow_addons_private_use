if GetLocale() ~= "koKR" then return end
local L

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
