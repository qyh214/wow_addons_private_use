local L = BigWigs:NewBossLocale("Gothik the Harvester", "zhTW")
if not L then return end
if L then
	L.add_death = "增援死亡"
	L.add_death_desc = "當增援死亡時發出警報。"

	L.wave = "%d/22：%s"

	L.trainee = "受訓員" -- Unrelenting Trainee NPC 16124
	L.deathKnight = "死亡騎士" -- Unrelenting Death Knight NPC 16125
	L.rider = "騎兵" -- Unrelenting Rider NPC 16126
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
	L.mark_desc = "當施放印記時發出警報。"

	--L[16062] = "Mograine" -- Surname of Highlord Mograine
	--L[16063] = "Zeliek" -- Surname of Sir Zeliek
	--L[16064] = "Korth'azz" -- Surname of Thane Korth'azz
	--L[16065] = "Blaumeux" -- Surname of Lady Blaumeux
end

L = BigWigs:NewBossLocale("Kel'Thuzad", "zhTW")
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "科爾蘇加德密室"

	L.engage_yell_trigger = "僕從們，侍衛們，隸屬於黑暗與寒冷的戰士們!聽從科爾蘇加德的召喚!"
	L.stage2_yell_trigger1 = "祈禱我的慈悲吧!"
	L.stage2_yell_trigger2 = "呼出你的最後一口氣!"
	L.stage2_yell_trigger3 = "你的末日臨近了!"
	L.stage3_yell_trigger = "主人，我需要幫助!"
	L.adds_yell_trigger = "非常好，凍原的戰士們，起來吧!我命令你們作戰，為你們的主人殺戮或獻身吧!不要留下活口!"
end

L = BigWigs:NewBossLocale("Noth the Plaguebringer", "zhTW")
if L then
	L.adds_yell_trigger = "起來吧，我的戰士們" -- 起來吧，我的戰士們!起來，再為主人盡忠一次!
end

L = BigWigs:NewBossLocale("Instructor Razuvious", "zhTW")
if L then
	L.understudy = "死亡騎士實習者"
end

L = BigWigs:NewBossLocale("Thaddius", "zhTW")
if L then
	--L[15929] = "Stalagg"
	--L[15930] = "Feugen"

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
