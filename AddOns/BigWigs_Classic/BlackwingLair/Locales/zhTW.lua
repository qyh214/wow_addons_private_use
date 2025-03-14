local L = BigWigs:NewBossLocale("Razorgore the Untamed", "zhTW")
if not L then return end
if L then
	L.start_trigger = "入侵者"

	L.eggs = "龍蛋計數"
	L.eggs_desc = "已摧毀龍蛋計數。"
	L.eggs_message = "已摧毀 %d/30 個龍蛋"
end

L = BigWigs:NewBossLocale("Vaelastrasz the Corrupt", "zhTW")
if L then
	--L.warmup_trigger = "Too late, friends!"
	--L.tank_bomb = "Tank Bomb"
end

L = BigWigs:NewBossLocale("Chromaggus", "zhTW")
if L then
	L.breath = "吐息警報"
	L.breath_desc = "當克洛瑪古斯吐息時發出警報"

	L.debuffs_message = "3/5 減益，注意！"
	L.debuffs_warning = "4/5 減益， 5層後將%s！"
	L.bronze = "青銅"

	L.vulnerability = "弱點改變警報"
	L.vulnerability_desc = "當克洛瑪古斯弱點改變時發出警報。"
	L.vulnerability_message = "克洛瑪古斯新弱點：%s"
	--L.detect_magic_missing = "Detect Magic is missing from Chromaggus"
	--L.detect_magic_warning = "A Mage must cast \124cff71d5ff\124Hspell:2855:0\124h[Detect Magic]\124h\124r on Chromaggus for vulnerability warnings to work."
end

L = BigWigs:NewBossLocale("Nefarian Classic", "zhTW")
if L then
	--L.engage_yell_trigger = "Let the games begin"
	L.stage3_yell_trigger = "不可能！來吧，我的僕人！再次為你們的主人服務！"

	L.shaman_class_call_yell_trigger = "薩滿，讓我看看你圖騰到底是什麼用處的"
	L.deathknight_class_call_yell_trigger = "死亡騎士們…來這"
	L.monk_class_call_yell_trigger = "武僧"
	L.hunter_class_call_yell_trigger = "獵人和你那討厭的豌豆射擊"

	L.warnshaman = "薩滿 - 圖騰湧現"
	L.warndruid = "德魯伊 - 強制貓形態，無法治療和解詛咒"
	L.warnwarlock = "術士 - 地獄火出現，DPS職業盡快將其消滅"
	L.warnpriest = "牧師 - 停止治療，靜等 25 秒"
	L.warnhunter = "獵人 - 遠程武器損壞"
	L.warnwarrior = "戰士 - 強制狂暴姿態，加大對MT的治療量"
	L.warnrogue = "盜賊 - 被傳送和麻痺"
	L.warnpaladin = "聖騎士 - BOSS受到保護祝福，物理攻擊無效"
	L.warnmage = "法師 - 變形術發動，注意解除"
	L.warndeathknight = "死亡騎士 - 死亡之握"
	L.warnmonk = "武僧 - 翻滾"
	L.warndemonhunter = "惡魔獵人 - 致盲"

	L.classcall = "職業點名"
	L.classcall_desc = "當奈法利安進行職業點名時發出警報"

	--L.add = "Drakonid deaths"
	--L.add_desc = "Announce the number of adds killed in stage 1 before Nefarian lands."
end

L = BigWigs:NewBossLocale("Blackwing Lair Trash", "zhTW")
if L then
	--L.wyrmguard_overseer = "Death Talon Wyrmguard / Death Talon Overseer" -- NPC 12460 / 12461
	--L.sandstorm = "Sandstorm"

	--L.target_vulnerability = "Target Vulnerability Warnings"
	--L.target_vulnerability_desc = "When your target is a Death Talon Wyrmguard or a Death Talon Overseer, show a warning for what vulnerability it has."
	--L.target_vulnerability_message = "Target Vulnerability: %s"
	--L.detect_magic_missing_message = "Detect Magic is missing from your target"
	--L.detect_magic_warning = "A Mage must cast \124cff71d5ff\124Hspell:2855:0\124h[Detect Magic]\124h\124r on your target for vulnerability warnings to work."

	--L.warlock = "Blackwing Warlock" -- NPC 12459
end
