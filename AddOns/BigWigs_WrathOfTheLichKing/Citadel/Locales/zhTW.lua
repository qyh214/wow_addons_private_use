local L = BigWigs:NewBossLocale("Lord Marrowgar", "zhTW")
if not L then return end
if L then
	--L.bone_spike = "Bone Spike" -- NPC ID 36619
end

L = BigWigs:NewBossLocale("Lady Deathwhisper", "zhTW")
if L then
	L.touch = "無脅之觸"
	L.deformed_fanatic = "畸形的狂熱者" -- NPC ID 38135
	--L.empowered_adherent = "Empowered Adherent" -- NPC ID 38136
end

L = BigWigs:NewBossLocale("Icecrown Gunship Battle", "zhTW")
if L then
	L.adds_trigger_alliance = "劫奪者，士官們，攻擊!"
	L.adds_trigger_horde = "海員們，士官們，攻擊!"

	L.mage = "法師"
	L.mage_desc = "當法師出現冰凍砲艇火砲時發出警報。"
	-- Alliance: We're taking hull damage, get a battle-mage out here to shut down those cannons!
	-- Horde: We're taking hull damage, get a sorcerer out here to shut down those cannons!
	--L.mage_yell_trigger = "taking hull damage"

	L.warmup_trigger_alliance = "發動引擎"
	L.warmup_trigger_horde = "起來吧，部落的子女"

	L.disable_trigger_alliance = "向前衝"
	L.disable_trigger_horde = "向巫妖王前進"
end

L = BigWigs:NewBossLocale("Deathbringer Saurfang", "zhTW")
if L then
	--L.blood_beast = "Blood Beast" --  NPC ID 38508

	L.warmup_alliance = "那我們走吧!快點……"
	L.warmup_horde = "柯爾克隆，前進!勇士們，要當心，天譴軍團已經……"
end

L = BigWigs:NewBossLocale("Blood Prince Council", "zhTW")
if L then
	L.switch_message = "生命轉換：>%s<！"
	L.switch_bar = "<下一生命轉換>"

	L.empowered_flames = "製造強力烈焰"

	L.empowered_shock_message = "正在施放 強力震擊漩渦！"
	L.regular_shock_message = "強力震擊漩渦區域！"
	L.shock_bar = "<下一強力震擊漩渦>"

	L.iconprince = "強化的血親王標記"
	L.iconprince_desc = "為強化的血親王打上團隊標記。（需要權限）"

	L.prison_message = "暗影之牢：>x%d<！"
end

L = BigWigs:NewBossLocale("Blood-Queen Lana'thel", "zhTW")
if L then
	L.engage_trigger = "你做了一個…不明智的…選擇。"

	L.shadow = "群聚暗影"
	L.shadow_message = "群聚暗影！"
	L.shadow_bar = "<下一群聚暗影>"

	L.feed_message = "即將 狂亂嗜血！"

	L.pact_message = "暗殞契印"
	L.pact_bar = "<下一暗殞契印>"

	L.phase_message = "即將 空中階段！"
	L.phase1_bar = "<地面階段>"
	L.phase2_bar = "<空中階段>"
end

L = BigWigs:NewBossLocale("Festergut", "zhTW")
if L then
	L.engage_trigger = "玩耍時間?"

	L.inhale_bar = "<下一吸入荒疫：%d>"
	L.blight_warning = "約5秒後，刺鼻荒疫！"
	L.ball_message = "即將 綠色黏液之球！"
end

L = BigWigs:NewBossLocale("Professor Putricide", "zhTW")
if L then
	L.engage_trigger = "大夥聽著，好消息!"

	L.phase = "階段"
	L.phase_desc = "當進入不同階段發出警報。"
	L.phase_warning = "即將 第%d階段！"
	L.phase_bar = "<下一階段>"

	L.ball_bar = "<下一延展黏液>"
	L.ball_say = "即將 延展黏液！"

	L.experiment_message = "即將 軟泥怪！"
	L.experiment_heroic_message = "即將 軟泥怪！"
	L.experiment_bar = "<下一軟泥怪>"
	L.blight_message = "毒氣雲！"
	L.violation_message = "暴躁軟泥怪！"

	L.gasbomb_bar = "<多個窒息毒氣彈>"
	L.gasbomb_message = "窒息毒氣彈！"
end

L = BigWigs:NewBossLocale("Rotface", "zhTW")
if L then
	L.engage_trigger = "不不不不不!"

	L.infection_message = "突變感染"

	L.ooze = "軟泥融合"
	L.ooze_desc = "當軟泥融合時發出警報！"
	L.ooze_message = "不穩定的軟泥：>%dx<！"

	L.spray_bar = "<下一泥漿噴霧>"
end

L = BigWigs:NewBossLocale("Sindragosa", "zhTW")
if L then
	L.engage_trigger = "你們真是夠蠢了才會來到此地。北裂境的冰冷寒風將吞噬你們的靈魂!"

	L.phase2 = "第二階段"
	L.phase2_desc = "當辛德拉苟莎進入第二階段發出警報。（35%）"
	L.phase2_trigger = "現在，絕望地感受我主無限的力量吧!"
	L.phase2_message = "第二階段！"

	L.airphase = "空中階段"
	L.airphase_desc = "當辛德拉苟莎起飛時發出警報。"
	L.airphase_trigger = "你們的入侵將在此終止!誰也別想存活!"
	L.airphase_message = "空中階段！"
	L.airphase_bar = "<下一空中階段>"

	L.boom_message = "極凍之寒！"
	L.boom_bar = "<極凍之寒>"

	L.instability_message = "不穩定 x%d！"
	L.chilled_message = "沁骨之寒 x%d！"
	L.buffet_message = "秘能連擊 x%d！"
	L.buffet_cd = "<下一無束魔法>"
end

L = BigWigs:NewBossLocale("The Lich King", "zhTW")
if L then
	L.warmup_trigger = "聖光所謂的正義終於來了嗎"
	L.engage_trigger = "我會讓你活著見證到最後，弗丁"

	L.horror_message = "蹣跚的血殭屍！"
	L.horror_bar = "<下一血殭屍>"

	L.valkyr_message = "華爾琪影衛！"
	L.valkyr_bar = "<下一華爾琪影衛>"
	L.valkyrhug_message = "華爾琪抓人！"

	L.cave_phase = "劍內階段！"
	L.last_phase_bar = "<最終階段>"

	L.frenzy_bar = "%s狂亂！"
	L.frenzy_survive_message = "%s將在瘟疫後存活！"
	L.frenzy_message = "小怪狂亂！"
	L.frenzy_soon_message = "5秒後，狂亂！"

	L.custom_on_valkyr_marker = "華爾琪標記"
	L.custom_on_valkyr_marker_desc = "使用 {rt8}{rt7}{rt6} 標記華爾琪，需要權限。\n|cFFFF0000團隊中只有1名應該啟用此選項以防止標記衝突。|r\n|cFFADFF2F提示：如果團隊選擇你打開此選項，滑鼠快速指向華爾琪是標記他們的最快方式。|r"
end

L = BigWigs:NewBossLocale("Valithria Dreamwalker", "zhTW")
if L then
	L.engage_trigger = "入侵者已經突破了內部聖所。加快摧毀綠龍的速度!只要留下骨頭和肌腱來復活!"

	L.portal = "夢魘之門"
	L.portal_desc = "當瓦莉絲瑞雅·夢行者打開夢魘之門時發出警報。"
	L.portal_message = "打開夢魘之門！"
	L.portal_bar = "<即將夢魘之門>"
	L.portalcd_message = "14秒後，夢魘之門：>%d<！"
	L.portalcd_bar = "<下一夢魘之門：%d>"
	L.portal_trigger = "我打開了一道傳送門通往夢境。你們的救贖就在其中，英雄們……"

	L.suppresser = "抑制者出現"
	L.suppresser_desc = "當一群抑制者出現時發出警報。"
	L.suppresser_message = "即將出現 抑制者！"

	L.blazing = "熾熱骷髏"
	L.blazing_desc = "熾熱骷髏|cffff0000監視|r出現計時條。此計時條可能不準確，只做參考。"
	L.blazing_warning = "即將 熾熱骷髏！"
end

L = BigWigs:NewBossLocale("Icecrown Citadel Trash", "zhTW")
if L then
	L.deathbound_ward = "縛亡守衛"
	--L.deathspeaker_high_priest = "Deathspeaker High Priest" -- NPC ID 36829
	L.putricide_dogs = "小寶 & 大臭"
end
