
local L = BigWigs:NewBossLocale("Magmaw", "zhTW")
if not L then return end
if L then
	L.stage2_yell_trigger = "真難想像" -- 真難想像!看來你真有機會打敗我的蟲子!也許我可幫忙...扭轉戰局。

	L.slump = "撲倒"
	L.slump_desc = "當熔喉撲倒並暴露時發出警報。"
	L.slump_bar = "騎乘"
	L.slump_message = "嘿，快騎上它！"
end

L = BigWigs:NewBossLocale("Omnotron Defense System", "zhTW")
if L then
	L.nef = "維克多·奈法利斯領主"
	L.nef_desc = "當維克多·奈法利斯領主施放技能時發出警報。"

	L.pool_explosion = "秘法逆爆"
	L.incinerate = "燒盡"
	L.flamethrower = "火焰噴射器"
	L.lightning = "閃電"
	L.infusion = "注入"
end

L = BigWigs:NewBossLocale("Atramedes", "zhTW")
if L then
	--L.obnoxious_fiend = "Obnoxious Fiend" -- NPC ID 49740
	--L.circles = "Circles"
end

L = BigWigs:NewBossLocale("Maloriak", "zhTW")
if L then
	L.flames = "烈焰"
end

L = BigWigs:NewBossLocale("Nefarian", "zhTW")
if L then
	L.discharge = "閃電釋放"
	L.stage3_yell_trigger = "我本來只想略盡地主之誼" -- 我本來只想略盡地主之誼，但是你們就是不肯痛快的受死!是時候拋下一切的虛偽...殺光你們就好!
	--L.too_close = "Dragons are too close"
end
