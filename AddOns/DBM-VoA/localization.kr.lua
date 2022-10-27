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
