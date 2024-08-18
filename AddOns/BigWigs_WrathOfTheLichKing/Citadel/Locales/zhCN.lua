local L = BigWigs:NewBossLocale("Lord Marrowgar", "zhCN")
if not L then return end
if L then
	L.bone_spike = "骨针" -- NPC ID 36619
end

L = BigWigs:NewBossLocale("Lady Deathwhisper", "zhCN")
if L then
	L.touch = "蔑视之触"
	L.deformed_fanatic = "畸形的狂热者" -- NPC ID 38135
	L.empowered_adherent = "亢奋的追随者" -- NPC ID 38136
end

L = BigWigs:NewBossLocale("Icecrown Gunship Battle", "zhCN")
if L then
	L.adds_trigger_alliance = "将士们，给我进攻"
	L.adds_trigger_horde = "将士们，给我进攻"

	L.mage = "法师"
	L.mage_desc = "当法师出现冰冻炮舰火炮时发出警报。"
	-- 联盟: 我们的船体受损了，赶快叫个战斗法师来轰掉那些大炮！
	-- 部落: 我们的船体受伤了，赶快叫个法师来干掉那些大炮！
	L.mage_yell_trigger = "我们的船体"

	L.warmup_trigger_alliance = "启动引擎！小伙子们"
	L.warmup_trigger_horde = "来吧！部落忠诚勇敢的儿女们"

	L.disable_trigger_alliance = "我早就警告过你，恶棍"
	L.disable_trigger_horde = "联盟不行了。向巫妖王进攻！"
end

L = BigWigs:NewBossLocale("Deathbringer Saurfang", "zhCN")
if L then
	L.blood_beast = "血兽" --  NPC ID 38508

	L.warmup_alliance = "那我们要行动了，我们要……"
	L.warmup_horde = "库卡隆，行动！勇士们，提高警惕。天灾军团已经"
end

L = BigWigs:NewBossLocale("Blood Prince Council", "zhCN")
if L then
	L.switch_message = "生命转换：%s！"
	L.switch_bar = "下一生命转换"

	L.empowered_flames = "塑造强能烈焰"

	L.empowered_shock_message = "正在施放强能震荡涡流！"
	L.regular_shock_message = "强能震荡涡流区域！"
	L.shock_bar = "下一强能震荡涡流"

	L.iconprince = "标记强化的鲜血王子"
	L.iconprince_desc = "为强化的鲜血王子打上团队标记。（需要权限）"

	L.prison_message = "暗影牢笼：x%d！"
end

L = BigWigs:NewBossLocale("Blood-Queen Lana'thel", "zhCN")
if L then
	L.engage_trigger = "你做了一个……愚蠢的……决定。"

	L.shadow = "蜂拥之影"
	L.shadow_message = "蜂拥之影！"
	L.shadow_bar = "下一蜂拥之影"

	L.feed_message = "即将 疯狂嗜血！"

	L.pact_message = "黑暗堕落者的契约"
	L.pact_bar = "下一黑暗堕落者的契约"

	L.phase_message = "即将 空中阶段！"
	L.phase1_bar = "地面阶段"
	L.phase2_bar = "空中阶段"
end

L = BigWigs:NewBossLocale("Festergut", "zhCN")
if L then
	L.engage_trigger = "玩吗？玩吗？"

	L.inhale_bar = "下一凋零呼吸：%d"
	L.blight_warning = "约5秒后，刺鼻毒气！"
	L.ball_message = "即将 绿色软泥黏液球！"
end

L = BigWigs:NewBossLocale("Professor Putricide", "zhCN")
if L then
	L.engage_trigger = "喜讯，各位！我想我已经研制出一种能够毁灭艾泽拉斯的药剂了！"

	L.phase = "阶段"
	L.phase_desc = "当进入不同阶段时发出警报。"
	L.phase_warning = "即将 第%d阶段！"
	L.phase_bar = "下一阶段"

	L.ball_bar = "下一可延展黏液"
	L.ball_say = "即将 可延展黏液！"

	L.experiment_message = "即将 软泥怪！"
	L.experiment_heroic_message = "即将 软泥怪！"
	L.experiment_bar = "下一软泥怪"
	L.blight_message = "毒肿！"
	L.violation_message = "不稳定的软泥怪！"

	L.gasbomb_bar = "多个窒息毒气弹"
	L.gasbomb_message = "窒息毒气弹！"
end

L = BigWigs:NewBossLocale("Rotface", "zhCN")
if L then
	L.engage_trigger = "WEEEEEE!"

	L.infection_message = "畸变感染！"

	L.ooze = "软泥融合"
	L.ooze_desc = "当软泥融合时发出警报。"
	L.ooze_message = "不稳定的软泥：%dx！"

	L.spray_bar = "下一软泥喷射"
end

L = BigWigs:NewBossLocale("Sindragosa", "zhCN")
if L then
	L.engage_trigger = "你们这些蠢货胆敢闯入这里"  -- 你们这些蠢货胆敢闯入这里。诺森德的冰风将卷走你们的灵魂！

	L.phase2 = "第二阶段"
	L.phase2_desc = "当辛达苟萨进入第二阶段发出警报。（35%）"
	L.phase2_trigger = "绝望吧，体会主人那无穷无尽的力量吧"
	L.phase2_message = "第二阶段！"

	L.airphase = "空中阶段"
	L.airphase_desc = "当辛达苟萨起飞时发出警报。"
	L.airphase_trigger = "你们的入侵结束了"
	L.airphase_message = "空中阶段！"
	L.airphase_bar = "下一空中阶段"

	L.boom_message = "严寒！"
	L.boom_bar = "严寒"

	L.instability_message = "动荡 x%d！"
	L.chilled_message = "寒霜刺骨 x%d！"
	L.buffet_message = "秘法打击 x%d！"
	L.buffet_cd = "下一狂咒"
end

L = BigWigs:NewBossLocale("The Lich King", "zhCN")
if L then
	L.warmup_trigger = "怎么，自诩正义的圣光终于来了"  -- 怎么，自诩正义的圣光终于来了？我是不是该丢下霜之哀伤，恳求您的宽恕呢，弗丁？
	L.engage_trigger = "我会让你活着目睹这个末日，弗丁。"  -- 我会让你活着目睹这个末日，弗丁。这悲惨的世界将在我手中重铸，我不想让圣光最强大的勇士错过这一切。

	L.horror_message = "蹒跚的血僵尸！"
	L.horror_bar = "下一血僵尸"

	L.valkyr_message = "瓦格里暗影戒卫者！"
	L.valkyr_bar = "下一瓦格里暗影戒卫者"
	L.valkyrhug_message = "瓦格里抓人！"

	L.cave_phase = "剑内阶段！"
	L.last_phase_bar = "最终阶段"

	L.frenzy_bar = "%s狂乱！"
	L.frenzy_survive_message = "%s将在瘟疫后存活！"
	L.frenzy_message = "小怪狂乱！"
	L.frenzy_soon_message = "5秒后，狂乱！"

	L.custom_on_valkyr_marker = "瓦格里标记"
	L.custom_on_valkyr_marker_desc = "使用 {rt8}{rt7}{rt6} 标记瓦格里，需要权限。\n|cFFFF0000团队中只有1名应该启用此选项以防止标记冲突。|r\n|cFFADFF2F提示：如果团队选择你打开此选项，鼠标快速指向瓦格里是标记他们的最快方式。|r"
end

L = BigWigs:NewBossLocale("Valithria Dreamwalker", "zhCN")
if L then
	L.engage_trigger = "入侵者闯入了内室。加紧毁掉那条绿龙！留下龙筋龙骨用来复生！"

	L.portal = "梦魇之门"
	L.portal_desc = "当踏梦者瓦利瑟瑞娅打开梦魇之门时发出警报。"
	L.portal_message = "打开梦魇之门！"
	L.portal_bar = "即将梦魇之门"
	L.portalcd_message = "14秒后，梦魇之门：%d！"
	L.portalcd_bar = "下一梦魇之门：%d"
	L.portal_trigger = "我打开了进入梦境的传送门。英雄们，救赎就在其中……"

	L.suppresser = "抑制者出现"
	L.suppresser_desc = "当一群抑制者出现时发出警报。"
	L.suppresser_message = "即将出现 抑制者！"

	L.blazing = "炽热骷髅"
	L.blazing_desc = "炽热骷髅|cffff0000监视|r出现计时条。此计时条可能不准确，只做参考。"
	L.blazing_warning = "即将 炽热骷髅！"
end

L = BigWigs:NewBossLocale("Icecrown Citadel Trash", "zhCN")
if L then
	L.deathbound_ward = "缚亡守卫"
	L.deathspeaker_high_priest = "亡语高阶祭司" -- NPC ID 36829
	L.putricide_dogs = "小宝和大臭"
end
