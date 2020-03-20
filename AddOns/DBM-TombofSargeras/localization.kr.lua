if GetLocale() ~= "koKR" then return end
local L

---------------------------
-- Mistress Sassz'ine --
---------------------------
L= DBM:GetModLocalization(1861)

L:SetOptionLocalization({
	TauntOnPainSuccess	= "Sync timers and taunt warning to Burden of Pain cast SUCCESS instead of START (for certain mythic strats where you let burden tick once on purpose, otherwise it's NOT recommended to use this options)"--TRANSLATE
})

---------------------------
-- The Desolate Host --
---------------------------
L= DBM:GetModLocalization(1896)

L:SetOptionLocalization({
	IgnoreTemplarOn3Tank	= "Ignore Reanimated Templars for Bone Armor infoframe/announces/nameplates when using 3 or more tanks (do not change this mid combat, it will break counts)"--TRANSLATE
})

---------------------------
-- Fallen Avatar --
---------------------------
L= DBM:GetModLocalization(1873)

L:SetOptionLocalization({
	InfoFrame =	"전투의 전반적인 상황을 정보 창에 표시"
})

L:SetMiscLocalization({
	FallenAvatarDialog	= "네 눈앞의 껍데기는 한때 살게라스의 무지막지한 힘을 담던 그릇이었다. 그러나 이 사원 자체가 우리에겐 포상이다. 이곳이 우리가 너희 세상을 잿더미로 만드는 발판이 되리라!"
})

---------------------------
-- Kil'jaeden --
---------------------------
L= DBM:GetModLocalization(1898)

L:SetWarningLocalization({
	warnSingularitySoon		= "%d초 후 넉백"
})

L:SetOptionLocalization({
	warnSingularitySoon		= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.soon:format(235059)
})

L:SetMiscLocalization({
	Obelisklasers	= "방첨탑 레이저"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("TombSargTrash")

L:SetGeneralLocalization({
	name =	"살게라스의 무덤 일반몹"
})
