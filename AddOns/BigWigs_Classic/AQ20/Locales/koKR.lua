local L = BigWigs:NewBossLocale("General Rajaxx", "koKR")
if not L then return end
if L then
	L.wave_trigger1a = "그들이 오고 있다. 자신의 몸을 지키도록 하라!"
	L.wave_trigger1b = "내가 너는 꼭 마지막에 해치우겠다고 말했던 걸 기억하나, 라작스?" -- CHECK (Remember, Rajaxx, when I said I'd kill you last?)
end

L = BigWigs:NewBossLocale("Buru the Gorger", "koKR")
if L then
	L.fixate_desc = "대상에게 시선을 고정합니다. 다른 공격자의 위협은 무시합니다."
end

L = BigWigs:NewBossLocale("Ayamiss the Hunter", "koKR")
if L then
	L.sacrifice = "희생"
end

L = BigWigs:NewBossLocale("Ruins of Ahn'Qiraj Trash", "koKR")
if L then
	L.guardian = "아누비사스 감시자"
end
