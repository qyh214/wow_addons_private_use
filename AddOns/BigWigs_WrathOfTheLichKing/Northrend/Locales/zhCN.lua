local L = BigWigs:NewBossLocale("Onyxia", "zhCN")
if not L then return end
if L then
	L.phase1_trigger = "真是走运。通常我必须离开窝才能找到食物"
	L.phase2_trigger = "这毫无意义的行动让我很厌烦。我会从上空把你们都烧成灰"
	L.phase3_trigger = "看起来需要再给你一次教训，凡人"

	L.deep_breath = "深呼吸"
end

local L = BigWigs:NewBossLocale("Archavon the Stone Watcher", "zhCN")
if L then
	L.stomp_message = "践踏 - 即将 冲锋！"
	L.stomp_warning = "约5秒后，可能践踏！"

	L.charge = "冲锋"
	L.charge_desc = "当玩家中了冲锋时发出警报。"
end

L = BigWigs:NewBossLocale("Emalon the Storm Watcher", "zhCN")
if L then
	L.overcharge_message = "风暴爪牙 - 能量超载！"
	L.overcharge_bar = "<爆炸>"

	L.custom_on_overcharge_mark = "能量超载标记"
	L.custom_on_overcharge_mark_desc = "使用 {rt8} 标记能量超载的风暴爪牙，需要权限。"
end

L = BigWigs:NewBossLocale("Koralon the Flame Watcher", "zhCN")
if L then
	L.breath_bar = "<灼热吐息：%d>"
	L.breath_message = "即將 灼热吐息：>%d<！"
end

L = BigWigs:NewBossLocale("Malygos", "zhCN")
if L then
	L.sparks = "能量火花"
	L.sparks_desc = "当能量火花出现时发出警报。"
	L.sparks_message = "出现 能量火花！"
	L.sparks_warning = "约5秒后，能量火花！"

	L.sparkbuff = "玛里苟斯获得能量火花"
	L.sparkbuff_desc = "当玛里苟斯获得能量火花时发出警报。"
	L.sparkbuff_message = "玛里苟斯：>能量火花<！"

	L.vortex = "漩涡"
	L.vortex_desc = "当施放漩涡时发出警报及显示计时条。"
	L.vortex_message = "漩涡！"
	L.vortex_warning = "约5秒后，可能漩涡！"
	L.vortex_next = "<漩涡 冷却>"

	L.breath = "深呼吸"
	L.breath_desc = "当施放深呼吸时发出警报。"
	L.breath_message = "深呼吸！"
	L.breath_warning = "约5秒后，深呼吸！"

	L.surge = "能量涌动"
	L.surge_desc = "当玩家中了能量涌动时发出警报。"
	L.surge_you = ">你< 能量涌动！"
	L.surge_trigger = "%s在注视你！"

	L.phase = "阶段"
	L.phase_desc = "当进入不同阶段时发出警报。"
	L.phase2_warning = "即将 第二阶段！"
	L.phase2_trigger = "我原本只是想尽快结束你们的生命"
	L.phase2_message = "第二阶段 - 魔枢领主与永恒子嗣!"
	L.phase2_end_trigger = "够了！既然你们这么想夺回艾泽拉斯的魔法，我就给你们！"
	L.phase3_warning = "即将 第三阶段！"
	L.phase3_trigger = "现在你们幕后的主使终于出现"
	L.phase3_message = "第三阶段！"
end

L = BigWigs:NewBossLocale("Sartharion", "zhCN")
if L then
	L.engage_trigger = "我的职责是保护这些龙卵。在伤害到它们之前，你们就会被我的龙息烧成灰烬！"
	L.tsunami_trigger = "%s周围的岩浆沸腾了起来！"
	L.twilight_trigger_vesperon = "一只维斯匹隆的信徒出现了！"
	L.twilight_trigger_shadron = "一只沙德隆的信徒出现了！"

	L.drakes = "幼龙增援"
	L.drakes_desc = "当每只幼龙增援加入战斗时发出警报。"

	-- Adds
	L.shadron = "沙德隆"
	L.tenebron = "塔尼布隆"
	L.vesperon = "维斯匹隆"
	L.lava_blaze = "熔岩烈焰" -- NPC 30643
	L.acolyte_shadron = "沙德隆的追随者" -- NPC 31218
	L.acolyte_vesperon = "维斯匹隆的追随者" -- NPC 31219
end

L = BigWigs:NewBossLocale("Toravon the Ice Watcher", "zhCN")
if L then
	L.whiteout_bar = "霜至：>%d<！"
	L.whiteout_message = "即将 霜至：>%d<！"

	L.freeze_message = "大地冰封！"
end
