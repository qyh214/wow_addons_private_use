local L = BigWigs:NewBossLocale("Azuregos", "ruRU")
if not L then return end
if L then
	L.bossName = "Азурегос"
end

L = BigWigs:NewBossLocale("Lord Kazzak", "ruRU")
if L then
	L.bossName = "Владыка Каззак"

	L.engage_trigger = "За Легион! За Кил'джедена!"
end

L = BigWigs:NewBossLocale("Emeriss", "ruRU")
if L then
	L.bossName = "Эмерисс"

	L.engage_trigger = "Надежда – это БОЛЕЗНЬ души! Эта земля зачахнет и умрет!"
end

L = BigWigs:NewBossLocale("Lethon", "ruRU")
if L then
	L.bossName = "Летон"

	L.engage_trigger = "Я чувствую ТЕНЬ, нависшую над вашими сердцами. Нечестивцам не будет покоя!"
end

L = BigWigs:NewBossLocale("Taerar", "ruRU")
if L then
	L.bossName = "Таэрар"

	L.engage_trigger = "Мир – это всего лишь мимолетный сон. Пусть правит КОШМАР!"
end

L = BigWigs:NewBossLocale("Ysondre", "ruRU")
if L then
	L.bossName = "Исондра"

	L.engage_trigger = "Нити ЖИЗНИ разорваны! Отомстим за Спящих!"
end
