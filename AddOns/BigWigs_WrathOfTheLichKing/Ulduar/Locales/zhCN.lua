local L = BigWigs:NewBossLocale("Auriaya", "zhCN")
if not L then return end
if L then
	L.swarm_message = "守护虫群"

	L.defender = "野性防御者"
	L.defender_desc = "当野性防御者出现时发出警报。"
	L.defender_message = "野性防御者（%d/9）！"
end

L = BigWigs:NewBossLocale("Freya", "zhCN")
if L then
	L.wave = "波"
	L.wave_desc = "当一波小怪时发出警报。"
	L.wave_bar = "<下一波>"
	L.conservator_trigger = "艾欧娜尔，您的仆人需要帮助！"
	L.detonate_trigger = "元素之潮会击垮你们！"
	L.elementals_trigger = "孩子们，帮帮我！"
	L.tree_trigger = "|cFF00FFFF生命缚誓者的礼物|r开始生长！"
	L.conservator_message = "古树监护者！"
	L.detonate_message = "引爆鞭笞者！"
	L.elementals_message = "古代水之精魂！"

	L.tree = "艾欧娜尔的礼物"
	L.tree_desc = "当弗蕾亚召唤艾欧娜尔的礼物时发出警报。"
	L.tree_message = "艾欧娜尔的礼物 出现！"

	L.fury_message = "自然之怒"

	L.tremor_warning = "即将 大地震颤！"
	L.tremor_bar = "<下一大地震颤>"
	L.energy_message = ">你<不稳定的能量！"
	L.sunbeam_message = "即将 阳光！"
	L.sunbeam_bar = "<下一阳光>"
end

L = BigWigs:NewBossLocale("Hodir", "zhCN")
if L then
	L.hardmode = "困难模式"
	L.hardmode_desc = "显示困难模式计时器。"
end

L = BigWigs:NewBossLocale("Ignis the Furnace Master", "zhCN")
if L then
	L.brittle_message = "铁铸像 - 脆弱！"
end

L = BigWigs:NewBossLocale("The Iron Council", "zhCN")
if L then
	L.stormcaller_brundir = "唤雷者布隆迪尔"
	L.steelbreaker = "断钢者"
	L.runemaster_molgeim = "符文大师莫尔基姆"

	L.summoning_message = "闪电元素即将出现！"

	L.chased_other = "闪电之藤：>%s<！"
	L.chased_you = ">你< 闪电之藤！"
end

L = BigWigs:NewBossLocale("Kologarn", "zhCN")
if L then
	L.arm = "手臂死亡"
	L.arm_desc = "当左右手臂死亡时发出警报。"
	L.left_dies = "左臂死亡！"
	L.right_dies = "右臂死亡！"
	L.left_wipe_bar = "<左臂重生>"
	L.right_wipe_bar = "<右臂重生>"

	L.eyebeam = "聚焦视线"
	L.eyebeam_desc = "当玩家中了聚焦视线时发出警报。"
end

L = BigWigs:NewBossLocale("Mimiron", "zhCN")
if L then
	L.phase = "阶段"
	L.phase_desc = "当进入不同阶段发出警报。"
	L.engage_warning = "第一阶段！"
	L.engage_trigger = "^我们时间不多了，朋友们！"
	L.phase2_warning = "即将 第二阶段！"
	L.phase2_trigger = "^太棒了！测试结果非常好！"
	L.phase3_warning = "即将 第三阶段！"
	L.phase3_trigger = "^非常感谢，朋友们！"
	L.phase4_warning = "即将 第四阶段！"
	L.phase4_trigger = "^初步测试阶段完成。"
	L.phase_bar = "<阶段：%d>"

	L.hardmode_trigger = "^嘿，你们为什么要这么做啊？"

	L.plasma_warning = "正在施放 等离子冲击！"
	L.plasma_soon = "即将 等离子冲击！"
	L.plasma_bar = "<等离子冲击>"

	L.shock_next = "下一震荡冲击！"

	L.laser_soon = "即将 P3Wx2激光弹幕！"
	L.laser_bar = "<P3Wx2激光弹幕>"

	L.magnetic_message = "空中指挥单位 已降落！"

	L.suppressant_warning = "即将 烈焰遏制！"

	L.fbomb_bar = "<下一冰霜炸弹>"

	L.bomb_message = "炸弹机器人 出现！"
end

L = BigWigs:NewBossLocale("Razorscale", "zhCN")
if L then
	L.ground_trigger = "快一点！她马上就要挣脱了！"
	L.ground_message = "锋鳞被锁住了！"
	L.air_message = "起飞！"

	L.harpoon = "鱼叉炮台"
	L.harpoon_desc = "当鱼叉炮台可用时发出警报。"
	L.harpoon_message = "鱼叉炮台：>%d<可用！"
	L.harpoon_trigger = "可以使用鱼叉炮台了！"
	L.harpoon_nextbar = "<鱼叉炮台：%d>"
end

L = BigWigs:NewBossLocale("Thorim", "zhCN")
if L then
	L.phase2_trigger = "入侵者！你们这些凡人竟敢坏了我的兴致，看我怎么……等等，你们……"
	L.phase3_trigger = "狂妄的小崽子们，竟敢在我的地盘上挑战我？我要亲自碾碎你们！"

	L.hardmode = "困难模式"
	L.hardmode_desc = "显示困难模式计时器。"
	L.hardmode_warning = "困难模式结束！"

	L.barrier_message = "符文巨像 - 符文屏障！"

	L.charge_message = "闪电充能：>%d<！"
	L.charge_bar = "<闪电充能：%d>"
end

L = BigWigs:NewBossLocale("General Vezax", "zhCN")
if L then
	L.surge_bar = "<黑暗涌动：%d>"

	L.animus = "萨隆邪铁畸体"
	L.animus_desc = "当萨隆邪铁畸体出现时发出警报。"
	L.animus_trigger = "萨隆邪铁蒸汽剧烈地旋转着，汇集成一个畸体。"
	L.animus_message = "萨隆邪铁畸体 出现！"

	L.vapor = "萨隆邪铁蒸汽"
	L.vapor_desc = "当萨隆邪铁蒸汽出现时发出警报。"
	L.vapor_message = "萨隆邪铁蒸汽：>%d<！"
	L.vapor_bar = "萨隆邪铁蒸汽"
	L.vapor_trigger = "一团萨隆邪铁蒸汽在附近聚集起来！"

	L.vaporstack = "萨隆邪铁蒸汽堆叠"
	L.vaporstack_desc = "当玩家中了5层或更多萨隆邪铁蒸汽时发出警报。"
	L.vaporstack_message = "萨隆邪铁蒸汽：>x%d<！"

	L.crash_say = "暗影冲撞"

	L.mark_message = "无面者的印记"
end

L = BigWigs:NewBossLocale("XT-002 Deconstructor", "zhCN")
if L then
	L.lightbomb_other = "灼热之光"
end

L = BigWigs:NewBossLocale("Yogg-Saron", "zhCN")
if L then
	L.engage_trigger = "攻击这头野兽要害的时刻即将来临！将你们的愤怒和仇恨倾泻到它的爪牙身上！"
	L.phase2_trigger = "我是清醒的梦境。"
	L.phase3_trigger = "凝视死亡的真正面孔吧，你们的末日就要来了！"

	L.portal = "传送门"
	L.portal_desc = "当传送门时发出警报。"
	L.portal_message = "开启传送门！"
	L.portal_bar = "<下一传送门>"

	L.fervor_message = "萨拉的热情：>%s<！"

	L.sanity_message = ">你< 即将疯狂！"

	L.weakened = "昏迷"
	L.weakened_desc = "当尤格-萨隆昏迷时发出警报。"
	L.weakened_message = "昏迷：>%s<！"

	L.madness_warning = "10秒后，疯狂诱导！"
	L.malady_message = "心灵疾病" -- short for Malady of the Mind (63830)

	L.tentacle = "重压触须"
	L.tentacle_desc = "当重压触须出现时发出警报。"
	L.tentacle_message = "重压触须：>%d<！"

	L.small_tentacles = "小型触须"
	L.small_tentacles_desc = "警告腐蚀触须和缠绕触须的刷新时间。"

	L.link_warning = ">你< 心智链接！"

	L.guardian_message = "召唤卫士：>%d<！"

	L.roar_warning = "5秒后，震耳咆哮！"
	L.roar_bar = "<下一震耳咆哮>"
end
