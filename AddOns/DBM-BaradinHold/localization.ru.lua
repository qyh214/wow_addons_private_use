if GetLocale() ~= "ruRU" then return end

local L

----------------
--  Argaloth  --
----------------
L= DBM:GetModLocalization(139)

L:SetOptionLocalization({
	SetIconOnConsuming		= DBM_CORE_L.AUTO_ICONS_OPTION_TARGETS:format(88954)
})

-----------------
--  Occu'thar  --
-----------------
L= DBM:GetModLocalization(140)

----------------------------------
--  Alizabal, Mistress of Hate  --
----------------------------------
L= DBM:GetModLocalization(339)

L:SetTimerLocalization({
	TimerFirstSpecial		= "Первая способность"
})

L:SetOptionLocalization({
	TimerFirstSpecial		= "Отсчет времени до первой особой способности после $spell:105738<br/>(Первая способность выбирается случайным образом из $spell:105067 или $spell:104936)"
})
