
local L = BigWigs:NewBossLocale("Magmaw", "ruRU")
if not L then return end
if L then
	L.stage2_yell_trigger = "Непостижимо! Вы, кажется, можете уничтожить моего лавового червяка! Пожалуй, я помогу ему."

	L.slump = "Падение"
	L.slump_desc = "Магмарь падает вперед открывая себя, позволяя начать родео."
	L.slump_bar = "Родео"
	L.slump_message = "Йихо, погнали!"
end

L = BigWigs:NewBossLocale("Omnotron Defense System", "ruRU")
if L then
	L.nef = "Лорд Виктор Нефарий"
	L.nef_desc = "Сообщать о способностях Лорда Виктора Нефария."

	L.pool_explosion = "Обратная вспышка"
	L.incinerate = "Испепеление"
	L.flamethrower = "Огнемет"
	L.lightning = "Проводник молний"
	L.infusion = "Вливание Тьмы"
end

L = BigWigs:NewBossLocale("Atramedes", "ruRU")
if L then
	L.obnoxious_fiend = "Гнусный бес" -- NPC ID 49740
	L.air_phase_trigger = "Да, беги! С каждым шагом твое сердце бьется все быстрее. Эти громкие, оглушительные удары... Тебе некуда бежать!"
	--L.circles = "Circles"
end

L = BigWigs:NewBossLocale("Maloriak", "ruRU")
if L then
	L.flames = "Пламя"
end

L = BigWigs:NewBossLocale("Nefarian", "ruRU")
if L then
	L.discharge = "Искровой разряд"
	L.stage3_yell_trigger = "Я пытался следовать законам гостеприимства"
	--L.too_close = "Dragons are too close"
end
