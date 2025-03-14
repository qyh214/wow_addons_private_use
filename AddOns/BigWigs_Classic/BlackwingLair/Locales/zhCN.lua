local L = BigWigs:NewBossLocale("Razorgore the Untamed", "zhCN")
if not L then return end
if L then
	L.start_trigger = "入侵者"

	L.eggs = "龙蛋计数"
	L.eggs_desc = "已摧毁龙蛋计数。"
	L.eggs_message = "%d/30 龙蛋已被摧毁"
end

L = BigWigs:NewBossLocale("Vaelastrasz the Corrupt", "zhCN")
if L then
	L.warmup_trigger = "太晚了，朋友们" -- 太晚了，朋友们！奈法利安的堕落力量已经生效……我无法……控制自己。
	L.tank_bomb = "坦克炸弹"
end

L = BigWigs:NewBossLocale("Chromaggus", "zhCN")
if L then
	L.breath = "吐息警报"
	L.breath_desc = "吐息警报"

	L.debuffs_message = "3/5 减益，注意！"
	L.debuffs_warning = "4/5 减益， 5层后将%s！"
	L.bronze = "青铜"

	L.vulnerability = "弱点警报"
	L.vulnerability_desc = "克洛玛古斯弱点改变时发出警报。"
	L.vulnerability_message = "克洛玛古斯新弱点：%s"
	L.detect_magic_missing = "克洛玛古斯身上缺少侦测魔法"
	L.detect_magic_warning = "法师必须对克洛玛古斯施放 \124cff71d5ff\124Hspell:2855:0\124h[侦测魔法]\124h\124r ，这样弱点的警报才有效。"
end

L = BigWigs:NewBossLocale("Nefarian Classic", "zhCN")
if L then
	L.engage_yell_trigger = "比赛现在开始"
	L.stage3_yell_trigger = "不可能"

	L.shaman_class_call_yell_trigger = "萨满祭司"
	L.deathknight_class_call_yell_trigger = "死亡骑士"
	L.monk_class_call_yell_trigger = "武僧"
	L.hunter_class_call_yell_trigger = "猎人"

	L.warnshaman = "萨满祭司 - 图腾出现！"
	L.warndruid = "德鲁伊 - 强制猫形态，无法治疗和解诅咒！"
	L.warnwarlock = "术士 - 地狱火出现，输出职业尽快将其消灭！"
	L.warnpriest = "牧师 - 停止治疗，静等25秒！"
	L.warnhunter = "猎人 - 远程武器损坏！"
	L.warnwarrior = "战士 - 强制狂暴姿态，加大对坦克的治疗量！"
	L.warnrogue = "盗贼 - 被传送和麻痹！"
	L.warnpaladin = "圣骑士 - 首领受到保护祝福，物理攻击无效！"
	L.warnmage = "法师 - 变形术发动，注意解除！"
	L.warndeathknight = "死亡骑士 - 死亡之握！"
	L.warnmonk = "武僧 - 翻滚！"
	L.warndemonhunter = "恶魔猎手 - 致盲！"

	L.classcall = "职业点名"
	L.classcall_desc = "职业点名警报"

	L.add = "龙兽死亡"
	L.add_desc = "第1阶段奈法利安降落之前增援击杀计数警报。"
end

L = BigWigs:NewBossLocale("Blackwing Lair Trash", "zhCN")
if L then
	L.wyrmguard_overseer = "黑翼龙人护卫 / 黑翼监工" -- NPC 12460 / 12461
	L.sandstorm = "沙尘暴"

	L.target_vulnerability = "目标弱点警报"
	L.target_vulnerability_desc = "当你的目标是黑翼龙人护卫/黑翼监工时，显示它的弱点警报。"
	L.target_vulnerability_message = "目标弱点: %s"
	L.detect_magic_missing_message = "目标缺少侦测魔法"
	L.detect_magic_warning = "法师必须对你的目标施放\124cff71d5ff\124Hspell:2855:0\124h[侦测魔法]\124h\124r，弱点警报才会有效。"

	L.warlock = "黑翼管理者" -- NPC 12459
end
