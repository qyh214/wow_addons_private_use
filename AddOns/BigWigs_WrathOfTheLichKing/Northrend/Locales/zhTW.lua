local L = BigWigs:NewBossLocale("Onyxia", "zhTW")
if not L then return end
if L then
	L.phase1_trigger = "真是幸運。通常我為了覓食就必須離開窩"
	L.phase2_trigger = "這毫無意義的行動讓我很厭煩。我會從上空把你們都燒成灰"
	L.phase3_trigger = "看起來需要再給你一次教訓，凡人"

	L.deep_breath = "深呼吸"
end

local L = BigWigs:NewBossLocale("Archavon the Stone Watcher", "zhTW")
if L then
	L.stomp_message = "踐踏 - 即將 衝鋒！"
	L.stomp_warning = "約5秒後，可能踐踏！"

	L.charge = "衝鋒"
	L.charge_desc = "當玩家中了衝鋒時發出警報。"
end

L = BigWigs:NewBossLocale("Emalon the Storm Watcher", "zhTW")
if L then
	L.overcharge_message = "暴雨爪牙 - 超載！"
	L.overcharge_bar = "<爆炸>"

	L.custom_on_overcharge_mark = "Overcharge marker"
	L.custom_on_overcharge_mark_desc = "Place the {rt8} marker on the overcharged minion, requires promoted or leader."
end

L = BigWigs:NewBossLocale("Koralon the Flame Watcher", "zhTW")
if L then
	L.breath_bar = "<燃燒之息：%d>"
	L.breath_message = "即將 燃燒之息：>%d<！"
end

L = BigWigs:NewBossLocale("Malygos", "zhTW")
if L then
	L.sparks = "力量火花"
	L.sparks_desc = "當力量火花出現時發出警報。"
	L.sparks_message = "出現 力量火花！"
	L.sparks_warning = "約5秒後，力量火花！"

	L.sparkbuff = "瑪里苟斯獲得力量火花"
	L.sparkbuff_desc = "當瑪里苟斯獲得力量火花時發出警報。"
	L.sparkbuff_message = "瑪里苟斯：>力量火花<！"

	L.vortex = "漩渦"
	L.vortex_desc = "當施放漩渦時發出警報及顯示計時條。"
	L.vortex_message = "漩渦！"
	L.vortex_warning = "約5秒後，可能漩渦！"
	L.vortex_next = "<漩渦 冷卻>"

	L.breath = "深呼吸"
	L.breath_desc = "當施放深呼吸時發出警報。"
	L.breath_message = "深呼吸！"
	L.breath_warning = "約5秒後，深呼吸！"

	L.surge = "力量奔騰"
	L.surge_desc = "當玩家中了力量奔騰時發出警報。"
	L.surge_you = ">你< 力量奔騰！"
	L.surge_trigger = "%s將他的目光鎖在你身上!"

	L.phase = "階段"
	L.phase_desc = "當進入不同階段時發出警報。"
	L.phase2_warning = "即將 第二階段！"
	L.phase2_trigger = "我原本只是想盡快結束你們的生命"
	L.phase2_message = "第二階段 - 奧核領主與永恆之裔！"
	L.phase2_end_trigger = "夠了!既然你們這麼想奪回艾澤拉斯的魔法，我就給你們!"
	L.phase3_warning = "即將 第三階段！"
	L.phase3_trigger = "現在你們幕後的主使終於出現"
	L.phase3_message = "第三階段！"
end

L = BigWigs:NewBossLocale("Sartharion", "zhTW")
if L then
	L.engage_trigger = "我的職責是看守這些龍蛋。在你傷害這些蛋以前，我會先燒了你！"
	L.tsunami_trigger = "圍繞著%s的熔岩開始劇烈地翻騰!"
	L.twilight_trigger_vesperon = "一個維斯佩朗信徒從暮光中出現!"
	L.twilight_trigger_shadron = "一個夏德朗信徒從暮光中出現!"

	L.drakes = "飛龍增援"
	L.drakes_desc = "當每只飛龍增援加入戰鬥時發出警報。"

	-- Adds
	L.shadron = "夏德朗"
	L.tenebron = "坦納伯朗"
	L.vesperon = "維斯佩朗"
	L.lava_blaze = "熔炎" -- NPC 30643
	L.acolyte_shadron = "夏德朗侍僧" -- NPC 31218
	L.acolyte_vesperon = "維斯佩朗侍僧" -- NPC 31219
end

L = BigWigs:NewBossLocale("Toravon the Ice Watcher", "zhTW")
if L then
	L.whiteout_bar = "寒霜厲雪：>%d<！"
	L.whiteout_message = "即將寒霜厲雪：>%d<！"

	L.freeze_message = "冰凍之地！"
end
