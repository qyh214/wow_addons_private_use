local L = BigWigs:NewBossLocale("Auriaya", "zhTW")
if not L then return end
if L then
	L.swarm_message = "守護貓群"

	L.defender = "野性防衛者"
	L.defender_desc = "當野性防衛者出現時發出警報。"
	L.defender_message = "野性防衛者（%d/9）！"
end

L = BigWigs:NewBossLocale("Freya", "zhTW")
if L then
	L.wave = "波"
	L.wave_desc = "當一波小怪時發出警報。"
	L.wave_bar = "<下一波>"
	L.conservator_trigger = "伊歐娜，你的僕從需要協助!"
	L.detonate_trigger = "元素們將襲捲你們!"
	L.elementals_trigger = "孩子們，協助我!"
	L.tree_trigger = "一個|cFF00FFFF生命守縛者之禮|r開始生長!"
	L.conservator_message = "古樹護存者！"
	L.detonate_message = "引爆鞭笞者！"
	L.elementals_message = "上古水之靈！"

	L.tree = "伊歐娜的贈禮"
	L.tree_desc = "當芙蕾雅召喚伊歐娜的贈禮時發出警報。"
	L.tree_message = "伊歐娜的贈禮 出現！"

	L.fury_message = "自然烈怒"

	L.tremor_warning = "即將 地面震顫！"
	L.tremor_bar = "<下一地面震顫>"
	L.energy_message = ">你< 不穩定的能量！"
	L.sunbeam_message = "即將 太陽光束！"
	L.sunbeam_bar = "<下一太陽光束>"
end

L = BigWigs:NewBossLocale("Hodir", "zhTW")
if L then
	L.hardmode = "困難模式"
	L.hardmode_desc = "顯示困難模式計時器。"
end

L = BigWigs:NewBossLocale("Ignis the Furnace Master", "zhTW")
if L then
	L.brittle_message = "鐵之傀儡 - 脆裂！"
end

L = BigWigs:NewBossLocale("The Iron Council", "zhTW")
if L then
	L.stormcaller_brundir = "風暴召喚者布倫迪爾"
	L.steelbreaker = "破鋼者"
	L.runemaster_molgeim = "符文大師墨吉姆"

	L.summoning_message = "閃電元素即將出現！"

	L.chased_other = "閃電觸鬚：>%s<！"
	L.chased_you = ">你< 閃電觸鬚！"
end

L = BigWigs:NewBossLocale("Kologarn", "zhTW")
if L then
	L.arm = "手臂死亡"
	L.arm_desc = "當左右手臂死亡時發出警報。"
	L.left_dies = "左臂死亡！"
	L.right_dies = "右臂死亡！"
	L.left_wipe_bar = "<左臂重生>"
	L.right_wipe_bar = "<右臂重生>"

	L.eyebeam = "集束目光"
	L.eyebeam_desc = "當玩家中了集束目光時發出警報。"
end

L = BigWigs:NewBossLocale("Mimiron", "zhTW")
if L then
	L.phase = "階段"
	L.phase_desc = "當進入不同階段發出警報。"
	L.engage_warning = "第一階段！"
	L.engage_trigger = "^我們沒有太多時間，朋友們!"
	L.phase2_warning = "即將 第二階段！"
	L.phase2_trigger = "^太好了!絕妙的良好結果!"
	L.phase3_warning = "即將 第三階段！"
	L.phase3_trigger = "^感謝你，朋友們!"
	L.phase4_warning = "即將 第四階段！"
	L.phase4_trigger = "^初步測試階段完成。"
	L.phase_bar = "<階段：%d>"

	L.hardmode_trigger = "^為什麼你要做出這種事?"

	L.plasma_warning = "正在施放 離子衝擊！"
	L.plasma_soon = "即將 離子衝擊！"
	L.plasma_bar = "<離子沖擊>"

	L.shock_next = "下一震爆！"

	L.laser_soon = "即將 P3Wx2雷射彈幕！"
	L.laser_bar = "<P3Wx2雷射彈幕>"

	L.magnetic_message = "空中指揮裝置 已降落！"

	L.suppressant_warning = "即將 熾焰抑制劑！"

	L.fbomb_bar = "<下一冰霜炸彈>"

	L.bomb_message = "炸彈機器人 出現！"
end

L = BigWigs:NewBossLocale("Razorscale", "zhTW")
if L then
	L.ground_trigger = "快!她可不會在地面上待太久!"
	L.ground_message = "銳鱗被鎖住了！"
	L.air_message = "起飛！"

	L.harpoon = "魚叉炮塔"
	L.harpoon_desc = "當魚叉炮塔可用時發出警報。"
	L.harpoon_message = "魚叉炮塔：>%d<可用！"
	L.harpoon_trigger = "魚叉砲塔已經準備就緒!"
	L.harpoon_nextbar = "<魚叉炮塔：%d>"
end

L = BigWigs:NewBossLocale("Thorim", "zhTW")
if L then
	L.phase2_trigger = "擅闖者!像你們這種膽敢干涉我好事的凡人將付出…等等--你……"
	L.phase3_trigger = "無禮的小輩，你竟敢在我的王座之上挑戰我?我會親手碾碎你們!"

	L.hardmode = "困難模式"
	L.hardmode_desc = "顯示困難模式計時器。"
	L.hardmode_warning = "困難模式結束！"

	L.barrier_message = "符文巨像 - 符刻屏障！"

	L.charge_message = "閃電能量：>%d<！"
	L.charge_bar = "<閃電能量：%d>"
end

L = BigWigs:NewBossLocale("General Vezax", "zhTW")
if L then
	L.surge_bar = "<暗鬱奔騰：%d>"

	L.animus = "薩倫聚惡體"
	L.animus_desc = "當薩倫聚惡體出現時發出警報。"
	L.animus_trigger = "薩倫煙霧聚集起來并且劇烈地旋轉，形成一個怪物般的形體!"
	L.animus_message = "薩倫聚惡體 出現！"

	L.vapor = "薩倫煙霧"
	L.vapor_desc = "當薩倫煙霧出現時發出警報。"
	L.vapor_message = "薩倫煙霧：>%d<！"
	L.vapor_bar = "薩倫煙霧"
	L.vapor_trigger = "一片薩倫煙霧在附近聚合!"

	L.vaporstack = "薩倫煙霧堆疊"
	L.vaporstack_desc = "當玩家中了5層或更多薩倫煙霧時發出警報。"
	L.vaporstack_message = "薩倫煙霧：>x%d<！"

	L.crash_say = "暗影暴擊"

	L.mark_message = "無面者印記"
end

L = BigWigs:NewBossLocale("XT-002 Deconstructor", "zhTW")
if L then
	L.lightbomb_other = "灼熱之光"
end

L = BigWigs:NewBossLocale("Yogg-Saron", "zhTW")
if L then
	L.engage_trigger = "我們即將有機會打擊怪物的首腦!現在將你的憤怒與仇恨貫注在他的爪牙上!"
	L.phase2_trigger = "我是清醒的夢境。"
	L.phase3_trigger = "看看死亡的真實面貌，瞭解你們的末日降臨了!"

	L.portal = "傳送門"
	L.portal_desc = "當傳送門時發出警報。"
	L.portal_message = "開啟傳送門！"
	L.portal_bar = "<下一傳送門>"

	L.fervor_message = "薩拉的熱誠：>%s<！"

	L.sanity_message = ">你< 即將瘋狂！！"

	L.weakened = "昏迷"
	L.weakened_desc = "當尤格薩倫昏迷時發出警報。"
	L.weakened_message = "昏迷：>%s<！"

	L.madness_warning = "10秒後，瘋狂誘陷！"
	L.malady_message = "心靈缺陷" -- short for Malady of the Mind (63830)

	L.tentacle = "粉碎觸手"
	L.tentacle_desc = "當粉碎觸手出現時發出警報。"
	L.tentacle_message = "粉碎觸手：>%d<！"

	--L.small_tentacles = "Small Tentacles"
	--L.small_tentacles_desc = "Warn for Corruptor Tentacle and Constrictor Tentacle spawns."

	L.link_warning = ">你< 腦波連結！"

	L.guardian_message = "尤格薩倫守護者：>%d<！ "

	L.roar_warning = "5秒後，震耳咆哮！"
	L.roar_bar = "<下一震耳咆哮>"
end
