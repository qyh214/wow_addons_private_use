
local L = BigWigs:NewBossLocale("Magmaw", "zhCN")
if not L then return end
if L then
	L.stage2_yell_trigger = "难以置信"

	L.slump = "弱点"
	L.slump_desc = "当熔喉扑倒并暴露后脑时发出警报。需要骑乘。"
	L.slump_bar = "骑乘"
	L.slump_message = "嘿，快骑上它！"
end

L = BigWigs:NewBossLocale("Omnotron Defense System", "zhCN")
if L then
	L.nef = "维克多·奈法里奥斯勋爵"
	L.nef_desc = "当维克多·奈法里奥斯勋爵施放技能时发出警报。"

	L.pool_explosion = "奥术反冲"
	L.incinerate = "烧尽"
	L.flamethrower = "火焰喷射器"
	L.lightning = "闪电"
	L.infusion = "灌注"
end

L = BigWigs:NewBossLocale("Atramedes", "zhCN")
if L then
	L.obnoxious_fiend = "喧闹恶鬼" -- NPC ID 49740
	L.air_phase_trigger = "对，跑吧！每跑一步你的心跳都会加快。这心跳声，洪亮如雷，震耳欲聋。你逃不掉的！"
	--L.circles = "Circles"
end

L = BigWigs:NewBossLocale("Maloriak", "zhCN")
if L then
	L.flames = "烈焰"
end

L = BigWigs:NewBossLocale("Nefarian", "zhCN")
if L then
	L.discharge = "闪电倾泻"
	L.stage3_yell_trigger = "我一直在尝试扮演好客的主人，可你们就是不肯受死！该卸下伪装了……杀光你们！"
	--L.too_close = "Dragons are too close"
end
