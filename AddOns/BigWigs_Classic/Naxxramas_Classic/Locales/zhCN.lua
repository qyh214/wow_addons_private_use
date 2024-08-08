local L = BigWigs:NewBossLocale("Gothik the Harvester", "zhCN")
if not L then return end
if L then
	L.add_death = "增援死亡"
	L.add_death_desc = "当增援死亡时发出警报。"

	L.wave = "%d/22：%s"

	L.trainee = "学徒" -- Unrelenting Trainee NPC 16124
	L.deathKnight = "死亡骑士" -- Unrelenting Death Knight NPC 16125
	L.rider = "骑兵" -- Unrelenting Rider NPC 16126
end

L = BigWigs:NewBossLocale("Grobbulus", "zhCN")
if L then
	L.injection = "变异注射"
end

L = BigWigs:NewBossLocale("Heigan the Unclean", "zhCN")
if L then
	L.teleport_yell_trigger = "你的生命正走向终结。"
end

L = BigWigs:NewBossLocale("The Four Horsemen", "zhCN")
if L then
	L.mark_desc = "当施放印记时发出警报。"

	--L[16062] = "Mograine" -- Surname of Highlord Mograine
	--L[16063] = "Zeliek" -- Surname of Sir Zeliek
	--L[16064] = "Korth'azz" -- Surname of Thane Korth'azz
	--L[16065] = "Blaumeux" -- Surname of Lady Blaumeux
end

L = BigWigs:NewBossLocale("Kel'Thuzad", "zhCN")
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "克尔苏加德的大厅"

	L.engage_yell_trigger = "仆从们，侍卫们，隶属于黑暗与寒冷的战士们！听从克尔苏加德的召唤！"
	L.stage2_yell_trigger1 = "祈祷我的慈悲吧！"
	L.stage2_yell_trigger2 = "呼出你的最后一口气！"
	L.stage2_yell_trigger3 = "你的末日临近了！"
	L.stage3_yell_trigger = "主人，我需要帮助！"
	L.adds_yell_trigger = "很好，冰荒废土的战士们，起来吧！我命令你们为主人而战斗，杀戮，直到死亡！一个活口都不要留！"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "zhCN")
if L then
	L.adds_yell_trigger = "起来吧，我的战士们" -- 起来吧，我的战士们！起来，再为主人尽忠一次！
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "zhCN")
if L then
	L.understudy = "见习死亡骑士"
end

L = BigWigs:NewBossLocale("Thaddius", "zhCN")
if L then
	L[15929] = "斯塔拉格"
	L[15930] = "费尔根"

	L.stage2_yell_trigger1 = "咬碎……你的……骨头……"
	L.stage2_yell_trigger2 = "打……烂……你！"
	L.stage2_yell_trigger3 = "杀……"

	L.add_death_emote_trigger = "%s死了。"
	L.overload_emote_trigger = "%s超载了！"
	--L.add_revive_emote_trigger = "%s is jolted back to life!"

	L.polarity_extras = "有关极性转化后需要跑位的警报"

	L.custom_off_select_charge_position = "起始位置"
	L.custom_off_select_charge_position_desc = "第一次极性转化后的位置。"
	L.custom_off_select_charge_position_value1 = "|cffff2020负极(-)|r 向左, |cff20ff20正极(+)|r 向右"
	L.custom_off_select_charge_position_value2 = "|cff20ff20正极(+)|r 向左, |cffff2020负极(-)|r 向右"

	L.custom_off_select_charge_movement = "移动战术"
	L.custom_off_select_charge_movement_desc = "你团队使用的移动战术。"
	L.custom_off_select_charge_movement_value1 = "使用战术： |cff20ff20穿过|r BOSS"
	L.custom_off_select_charge_movement_value2 = "使用战术：在BOSS身边 |cff20ff20顺时针|r 移动"
	L.custom_off_select_charge_movement_value3 = "使用战术：在BOSS身边 |cff20ff20逆时针|r 移动"
	L.custom_off_select_charge_movement_value4 = "四点战术 1: 极性转化改变 |cff20ff20向右|r, 极性转化未改变 |cff20ff20向左|r"
	L.custom_off_select_charge_movement_value5 = "四点战术 2: 极性转化改变 |cff20ff20向左|r, 极性转化未改变 |cff20ff20向右|r"

	L.custom_off_charge_graphic = "图形箭头"
	L.custom_off_charge_graphic_desc = "显示图形箭头。"
	L.custom_off_charge_text = "文字箭头"
	L.custom_off_charge_text_desc = "显示文字箭头。"
	L.custom_off_charge_voice = "语音提示"
	L.custom_off_charge_voice_desc = "播放语音提示。"

	L.left = "<--- 向左 <--- 向左 <---"
	L.right = "---> 向右 ---> 向右 --->"
	L.swap = "^^^^ 交换 ^^^^ 迅速 ^^^^"
	L.stay = "==== 不要动 ==== 不要动 ===="

	--L.chat_message = "The Thaddius mod supports showing you directional arrows and playing voices. Open the options to configure them."
end
