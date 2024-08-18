local L = BigWigs:NewBossLocale("Anub'Rekhan", "zhTW")
if not L then return end
if L then
	L.add = "地穴衛士"
	L.locust = "蝗蟲"
end

L = BigWigs:NewBossLocale("Grand Widow Faerlina", "zhTW")
if L then
	L.silencewarn = "沉默！延緩了狂怒！"
	L.silencewarn5sec = "5秒後沉默結束！"
	L.silence = "沉默"
end

L = BigWigs:NewBossLocale("Gothik the Harvester", "zhTW")
if L then
	L.phase1_trigger1 = "你們這些蠢貨已經主動步入了陷阱。"
	L.phase1_trigger2 = "Kazile Teamanare ZennshinagasRil" -- Curse of Tongues CHECK THIS
	L.phase2_trigger = "我已經等待很久了。現在你們將面對靈魂的收割者。"

	L.add = "增援警報"
	L.add_desc = "當增援時發出警報。"

	L.add_death = "增援死亡"
	L.add_death_desc = "當增援死亡時發出警報。"

	L.riderdiewarn = "騎兵已死亡！"
	L.dkdiewarn = "死亡騎士已死亡！"

	L.wave = "%d/23：%s"

	L.trawarn = "3秒後受訓員出現"
	L.dkwarn = "3秒後死亡騎士出現"
	L.riderwarn = "3秒後騎兵出現"

	L.trabar = "受訓員（%d）"
	L.dkbar = "死亡騎士（%d）"
	L.riderbar = "騎兵（%d）"

	--L.gate = "Gate Open!"
	--L.gatebar = "Gate opens"

	L.phase_soon = "10秒後進入房間！"

	L.engage_message = "『收割者』高希已進入參戰！"
end

L = BigWigs:NewBossLocale("Grobbulus", "zhTW")
if L then
	L.injection = "突變注射"
end

L = BigWigs:NewBossLocale("Heigan the Unclean", "zhTW")
if L then
	L.teleport_yell_trigger = "你的生命正走向終結。"
end

L = BigWigs:NewBossLocale("The Four Horsemen", "zhTW")
if L then
	L.mark = "印記"
	L.mark_desc = "當施放印記時發出警報。"

	L.engage_message = "四騎士已進入參戰！"
end

L = BigWigs:NewBossLocale("Kel'Thuzad Naxxramas", "zhTW")
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "科爾蘇加德之間"

	L.phase1_trigger = "僕從們，侍衛們，隸屬於黑暗與寒冷的戰士們!聽從科爾蘇加德的召喚!"
	L.phase2_trigger1 = "祈禱我的慈悲吧!"
	L.phase2_trigger2 = "呼出你的最後一口氣!"
	L.phase2_trigger3 = "你的末日臨近了!"
	L.phase3_trigger = "主人，我需要幫助!"
	L.guardians_trigger = "非常好，凍原的戰士們，起來吧!我命令你們作戰，為你們的主人殺戮或獻身吧!不要留下活口!"

	L.phase2_warning = "第二階段 - 科爾蘇加德！"
	L.phase2_bar = "科爾蘇加德進入戰鬥"

	L.phase3_warning = "第三階段 - 約15秒後，寒冰皇冠守衛者出現！"

	L.guardians = "寒冰皇冠守護者"
	L.guardians_desc = "當第三階段召喚寒冰皇冠守護者時發出警報。"
	L.guardians_warning = "約10秒後，寒冰皇冠守護者出現！"
	L.guardians_bar = "寒冰皇冠守護者出現"

	--L.engage_message = "Kel'Thuzad encounter started!"
end

L = BigWigs:NewBossLocale("Loatheb", "zhTW")
if L then
	L.doomtime_bar = "每隔15秒 無可避免的末日"
	L.doomtime_now = "無可避免的末日現在每隔15秒發動一次！"

	L.spore_warn = "孢子(%d)"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "zhTW")
if L then
	L.adds_yell_trigger = "起來吧，我的戰士們" -- 起來吧，我的戰士們!起來，再為主人盡忠一次!
end

L = BigWigs:NewBossLocale("Maexxna", "zhTW")
if L then
	L.webspraywarn30sec = "10秒後，纏繞之網！"
	L.webspraywarn20sec = "纏繞之網！10秒後小蜘蛛出現！"
	L.webspraywarn10sec = "小蜘蛛出現！10秒後撒網！"
	L.webspraywarn5sec = "撒網5秒！"

	L.enragewarn = "狂怒！"
	L.enragesoonwarn = "即將 狂怒！"

	L.cocoons = "纏繞之網"
	L.spiders = "出現 小蜘蛛"
end

L = BigWigs:NewBossLocale("Sapphiron", "zhTW")
if L then
	L.airphase_trigger = "%s離地升空了!"
	L.deepbreath_trigger = "%s深深地吸了一口氣……" -- XXX Verify

	--L.air_phase = "Air Phase"
	--L.ground_phase = "Ground Phase"

	L.ice_bomb = "寒冰炸彈"
	L.ice_bomb_warning = "即將 寒冰炸彈"
	L.ice_bomb_bar = "寒冰炸彈 落地"

	L.icebolt_say = "我是寒冰凍體！"
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "zhTW")
if L then
	L.understudy = "見習死亡騎士"

	L.shout_warning = "5秒後，混亂怒吼！"
	L.taunt_warning = "5秒後，可以嘲諷！"
	L.shieldwall_warning = "5秒後，可以骸骨屏障！"
end

L = BigWigs:NewBossLocale("Thaddius", "zhTW")
if L then
	--L[15929] = "Stalagg"
	--L[15930] = "Feugen"

	L.stage1_yell_trigger1 = "斯塔拉格要碾碎你!"
	L.stage1_yell_trigger2 = "主人要吃了你!"

	L.stage2_yell_trigger1 = "咬碎……你的……骨頭……"
	L.stage2_yell_trigger2 = "打…碎…你……"
	L.stage2_yell_trigger3 = "殺……"

	L.add_death_emote_trigger = "%s死亡了。"
	L.overload_emote_trigger = "%s超負荷！"
	--L.add_revive_emote_trigger = "%s is jolted back to life!"

	--L.polarity_extras = "Additional alerts for Polarity Shift positioning"

	--L.custom_off_select_charge_position = "First position"
	--L.custom_off_select_charge_position_desc = "Where to move to after the first Polarity Shift."
	--L.custom_off_select_charge_position_value1 = "|cffff2020Negative (-)|r are LEFT, |cff2020ffPositive (+)|r are RIGHT"
	--L.custom_off_select_charge_position_value2 = "|cff2020ffPositive (+)|r are LEFT, |cffff2020Negative (-)|r are RIGHT"

	--L.custom_off_select_charge_movement = "Movement"
	--L.custom_off_select_charge_movement_desc = "The movement strategy your group uses."
	--L.custom_off_select_charge_movement_value1 = "Run |cff20ff20THROUGH|r the boss"
	--L.custom_off_select_charge_movement_value2 = "Run |cff20ff20CLOCKWISE|r around the boss"
	--L.custom_off_select_charge_movement_value3 = "Run |cff20ff20COUNTER-CLOCKWISE|r around the boss"
	--L.custom_off_select_charge_movement_value4 = "Four camps 1: Polarity changed moves |cff20ff20RIGHT|r, same polarity moves |cff20ff20LEFT|r"
	--L.custom_off_select_charge_movement_value5 = "Four camps 2: Polarity changed moves |cff20ff20LEFT|r, same polarity moves |cff20ff20RIGHT|r"

	--L.custom_off_charge_graphic = "Graphical arrow"
	--L.custom_off_charge_graphic_desc = "Show an arrow graphic."
	--L.custom_off_charge_text = "Text arrows"
	--L.custom_off_charge_text_desc = "Show an additional message."
	--L.custom_off_charge_voice = "Voice alert"
	--L.custom_off_charge_voice_desc = "Play a voice alert."

	L.left = "<--- 到左邊 <--- 到左邊 <---"
	L.right = "---> 向右 ---> 向右 --->"
	L.swap = "^^^^ 交換 ^^^^ 交換 ^^^^"
	L.stay = "==== 不要動 ==== 不要動 ===="

	--L.chat_message = "The Thaddius mod supports showing you directional arrows and playing voices. Open the options to configure them."
end
