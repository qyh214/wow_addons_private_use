local L = BigWigs:NewBossLocale("Viscidus", "zhCN")
if not L then return end
if L then
	L.freeze = "冻结状态"
	L.freeze_desc = "当冻结状态改变时发出警报。"

	L.freeze_trigger1 = "%s的速度慢下来了！"
	L.freeze_trigger2 = "%s冻结了！"
	L.freeze_trigger3 = "%s变成了坚硬的固体！"
	L.freeze_trigger4 = "%s突然裂开了！"
	L.freeze_trigger5 = "%s看起来就要碎裂了！"

	L.freeze_warn1 = "第一冻结阶段！"
	L.freeze_warn2 = "第二冻结阶段！"
	L.freeze_warn3 = "维希度斯冻住了！"
	L.freeze_warn4 = "开始碎了 - 继续！"
	L.freeze_warn5 = "快裂开了 - 加油！"
	L.freeze_warn_melee = "%d 物理攻击 - 还需%d下！"
	L.freeze_warn_frost = "%d 冰霜攻击 - 还需%d下！"
end

L = BigWigs:NewBossLocale("Ouro", "zhCN")
if L then
	L.engage_message = "奥罗已进入战斗！90秒后可能下潜！"
	L.possible_submerge_bar = "可能下潜"

	L.emerge_message = "奥罗已出现"
	L.emerge_bar = "奥罗出现"

	L.submerge_message = "奥罗已下潜"
	L.submerge_bar = "奥罗下潜"

	L.scarab = "甲虫消失"
	L.scarab_desc = "当甲虫消失时发出警报。"
	L.scarab_bar = "甲虫消失"
end

L = BigWigs:NewBossLocale("C'Thun", "zhCN")
if L then
	L.claw_tentacle = "利爪触须"
	L.claw_tentacle_desc = "利爪触须的计时器。"

	L.giant_claw_tentacle = "巨钩触须"
	L.giant_claw_tentacle_desc = "巨钩触须的计时器。"

	L.eye_tentacles = "眼球触须"
	L.eye_tentacles_desc = "眼球触须的计时器。"

	L.giant_eye_tentacle = "巨眼触须"
	L.giant_eye_tentacle_desc = "巨眼触须的计时器。"

	L.weakened_desc = "虚弱状态警报。"

	L.dark_glare_message = "%s: %s (队伍 %s)" -- Dark Glare: PLAYER_NAME (Group 1)
	L.stomach = "胃"
	L.tentacle = "触须 (%d)"
end

L = BigWigs:NewBossLocale("Ahn'Qiraj Trash", "zhCN")
if L then
	L.sentinel = "阿努比萨斯哨兵" -- NPC 15264
	L.brainwasher = "其拉洗脑者" -- NPC 15247
	L.defender = "阿努比萨斯防御者" -- NPC 15277
	L.crawler = "维克尼爬行者" -- NPC 15240

	L.target_buffs = "目标增益警报"
	L.target_buffs_desc = "当你的目标是阿努比萨斯哨兵时，会显示一个警报，提醒你有什么增益。"
	L.target_buffs_message = "目标增益: %s"
	L.detect_magic_missing_message = "你的目标缺少侦测魔法"
	L.detect_magic_warning = "法师必须对你的目标施放 \124cff71d5ff\124Hspell:2855:0\124h[侦测魔法]\124h\124r 这样警报才能生效。"
end
