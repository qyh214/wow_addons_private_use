local L = BigWigs:NewBossLocale("Anub'Rekhan", "zhCN")
if not L then return end
if L then
	L.add = "地穴卫士"
	L.locust = "蝗虫"
end

L = BigWigs:NewBossLocale("Grand Widow Faerlina", "zhCN")
if L then
	L.silencewarn = "沉默！延缓了激怒！"
	L.silencewarn5sec = "5秒后沉默结束！"
	L.silence = "沉默"
end

L = BigWigs:NewBossLocale("Gothik the Harvester", "zhCN")
if L then
	L.phase1_trigger1 = "你们这些蠢货已经主动步入了陷阱。"
	--L.phase1_trigger2 = "Teamanare shi rikk mannor rikk lok karkun" -- Curse of Tongues
	L.phase2_trigger = "我已经等待很久了。现在你们将面对灵魂的收割者。"

	L.add = "增援"
	L.add_desc = "当增援时发出警报。"

	L.add_death = "增援死亡"
	L.add_death_desc = "当增援死亡时发出警报。"

	L.riderdiewarn = "骑兵已死亡！"
	L.dkdiewarn = "死亡骑士已死亡！"

	L.wave = "%d/23：%s"

	L.trawarn = "3秒后学徒出现"
	L.dkwarn = "3秒后死亡骑士出现"
	L.riderwarn = "3秒后骑兵出现"

	L.trabar = "学徒（%d）"
	L.dkbar = "死亡骑士（%d）"
	L.riderbar = "骑兵（%d）"

	L.gate = "门打开!"
	L.gatebar = "门打开"

	L.phase_soon = "收割者戈提克10秒后进入房间！"

	L.engage_message = "收割者戈提克已激活！"
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
	L.mark = "印记"
	L.mark_desc = "当施放印记时发出警报。"

	L.engage_message = "四骑士已激活！"
end

L = BigWigs:NewBossLocale("Kel'Thuzad Naxxramas", "zhCN")
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "克尔苏加德的大厅"

	L.phase1_trigger = "仆从们，侍卫们，隶属于黑暗与寒冷的战士们！听从克尔苏加德的召唤！"
	L.phase2_trigger1 = "祈祷我的慈悲吧！"
	L.phase2_trigger2 = "呼出你的最后一口气！"
	L.phase2_trigger3 = "你的末日临近了！"
	L.phase3_trigger = "主人，我需要帮助！"
	L.guardians_trigger = "很好，冰荒废土的战士们，起来吧！我命令你们为主人而战斗，杀戮，直到死亡！一个活口都不要留！"

	L.phase2_warning = "第二阶段 - 克尔苏加德！"
	L.phase2_bar = "激活克尔苏加德"

	L.phase3_warning = "第三阶段 - 约15秒后，寒冰皇冠卫士出现！"

	L.guardians = "寒冰皇冠卫士"
	L.guardians_desc = "当第三阶段召唤寒冰皇冠卫士时发出警报。"
	L.guardians_warning = "约10秒后，寒冰皇冠卫士出现！"
	L.guardians_bar = "寒冰皇冠卫士出现"

	L.engage_message = "克尔苏加德发动了攻击！"
end

L = BigWigs:NewBossLocale("Loatheb", "zhCN")
if L then
	L.doomtime_bar = "每隔15秒 必然的厄运"
	L.doomtime_now = "必然的厄运现在每隔15秒发动一次！"

	L.spore_warn = "孢子(%d)"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "zhCN")
if L then
	L.adds_yell_trigger = "起来吧，我的战士们" -- 起来吧，我的战士们！起来，再为主人尽忠一次！
end

L = BigWigs:NewBossLocale("Maexxna", "zhCN")
if L then
	L.webspraywarn30sec = "10秒后，蛛网裹体！"
	L.webspraywarn20sec = "蛛网裹体！10秒后小蜘蛛出现！"
	L.webspraywarn10sec = "小蜘蛛出现！10秒后蛛网喷射！"
	L.webspraywarn5sec = "蛛网喷射5秒！"

	L.enragewarn = "激怒！"
	L.enragesoonwarn = "即将 激怒！"

	L.cocoons = "蛛网裹体"
	L.spiders = "出现 小蜘蛛"
end

L = BigWigs:NewBossLocale("Sapphiron", "zhCN")
if L then
	L.airphase_trigger = "萨菲隆缓缓升空！"
	L.deepbreath_trigger = "%s深深地吸了一口气。"

	L.air_phase = "空中阶段"
	L.ground_phase = "地面阶段"

	L.ice_bomb = "寒冰炸弹"
	L.ice_bomb_warning = "即将 寒冰炸弹"
	L.ice_bomb_bar = "寒冰炸弹 落地"

	L.icebolt_say = "我是寒冰屏障！"
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "zhCN")
if L then
	L.understudy = "见习死亡骑士"

	L.shout_warning = "5秒后，瓦解怒吼！"
	L.taunt_warning = "5秒后，可以嘲讽！"
	L.shieldwall_warning = "5秒后，可以白骨屏障！"
end

L = BigWigs:NewBossLocale("Thaddius", "zhCN")
if L then
	L[15929] = "斯塔拉格"
	L[15930] = "费尔根"

	L.stage1_yell_trigger1 = "斯塔拉格要碾碎你！"
	L.stage1_yell_trigger2 = "主人要吃了你！"

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
