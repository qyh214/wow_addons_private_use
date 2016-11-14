local ADDON, Addon = ...
local Locale = Addon:NewModule('Locale')

local default_locale = "enUS"
local current_locale

local langs = {}
langs.enUS = {
	config_characterConfig = "Per-character configuration",
	config_progressTooltip = "Show progress each enemy gives on their tooltip",
	config_progressFormat = "Enemies Forces Format",
	config_progressFormat_1 = "24.19%",
	config_progressFormat_2 = "90/372",
	config_progressFormat_3 = "24.19% - 90/372",
	config_splitsFormat = "Objective Splits Display",
	config_splitsFormat_1 = "Disabled",
	config_splitsFormat_2 = "Time from start",
	config_splitsFormat_3 = "Relative to previous",
	config_autoGossip = "Automatically select gossip entries during Mythic Keystone dungeons (ex: Odyn)",
	config_cosRumors = "Output to party chat clues from \"Chatty Rumormonger\" during Court of Stars",
	config_silverGoldTimer = "Show timer for both 2 and 3 bonus chests at same time",
	config_completionMessage = "Show message with final times on completion of a Mythic Keystone dungeon",
	config_showSplits = "Show split time for each objective in objective tracker",
	keystoneFormat = "[Keystone: %s - Level %d]",
	completion0 = "Timer expired for %s with %s, you were %s over the time limit.",
	completion1 = "Beat the timer for %s in %s. You were %s ahead of the timer, and missed +2 by %s.",
	completion2 = "Beat the timer for +2 %s in %s. You were %s ahead of the +2 timer, and missed +3 by %s.",
	completion3 = "Beat the timer for +3 %s in %s. You were %s ahead of the +3 timer.",
	completionSplits = "Split timings were: %s.",
	timeLost = "Time Lost",
	config_smallAffixes = "Reduce the size of affix icons on timer frame",
	config_deathTracker = "Show death tracker on timer frame",
}
langs.enGB = langs.enUS

langs.esES = {
	config_characterConfig = "Configuración por personaje",
	config_progressTooltip = "Mostrar cantidad de progreso de cada enemigo en su tooltip",
	config_progressFormat = "Formato de \"Fuerzas enemigas\"",
	keystoneFormat = "[Piedra angular: %s - Nivel %d]",
}
langs.esMX = langs.esES

langs.ruRU = {
	config_characterConfig = "Настройки персонажа",
	config_progressTooltip = "Показывать прогресс за каждого врага в подсказках",
	config_progressFormat = "Формат отображения прогресса",
	keystoneFormat = "[Ключ: %s - Уровень %d]",
}

langs.deDE = {
	config_characterConfig = "Charakterspezifische Konfiguration",
	config_progressTooltip = "Zeige Fortschritt für \"Feindliche Streitkräfte\" in ihrem Tooltip",
	config_progressFormat = "Format für \"Feindliche Streitkräfte\"",
	config_splitsFormat = "Ziel Zwischenzeitsanzeige",
	config_splitsFormat_1 = "Deaktiviert",
	config_splitsFormat_2 = "Zeit ab Start",
	config_splitsFormat_3 = "Relativ zum vorherigen",
	config_autoGossip = "Automatisch Gesprächsoptionen auswählen während Mythic+ Dugeons (bsp: Odyn)",
	config_cosRumors = "Gebe Hinweise von \"Geschwätzige Plaudertasche\" im Hof der Sterne im Gruppenchat aus",
	config_silverGoldTimer = "Zeige Zeit für +2 und +3 Bonuskisten gleichzeitig",
	config_completionMessage = "Zeige Nachricht mit finalen Zeiten am Ende des Dungeons an",
	config_showSplits = "Zeige Zwischenzeit für jedes Ziel in der Zielverfolgung an",
	keystoneFormat = "[Schlüsselstein: %s - Level %d]",
	forcesFormat = " - Feindliche Streitkräfte: %s",
	completion0 = "Zeit abgelaufen für %s mit %s, ihr wart %s über dem Zeitlimit.",
	completion1 = "Zeit für %s in %s geschlagen. Ihr wart %s vor dem Zeitlimit, und habt +2 um %s verfehlt.",
	completion2 = "Zeit für +2 %s in %s geschlagen. Ihr wart %s vor dem Zeitlimit für +2, und habt +3 um %s verfehlt.",
	completion3 = "Zeit für +3 %s in %s geschlagen. Ihr wart %s vor dem Zeitlimit für +3.",
}

langs.koKR = {
	config_characterConfig = "캐릭터별 설정",
	config_progressTooltip = "각각의 적이 주는 진행도를 툴팁에 표시",
	config_progressFormat = "적 병력 표시 형식",
	config_splitsFormat = "공략 목표당 소요 시간",
	config_splitsFormat_1 = "사용하지 않음",
	config_splitsFormat_2 = "시작점부터 걸린 시간",
	config_splitsFormat_3 = "이전 목표부터 걸린 시간",
	config_autoGossip = "신화 쐐기돌 던전에서 자동으로 대화 넘김 (예: 오딘)",
	config_cosRumors = "별의 궁정에서 \"수다쟁이 호사가\"가 알려주는 단서 표시",
	config_silverGoldTimer = "추가 상자 2와 3의 남은 시간을 함께 표시",
	config_completionMessage = "신화 쐐기돌 던전 완료시 소요 시간 메시지 표시",
	config_showSplits = "던전 목표에서 각 목표당 소요 시간 표시",
	keystoneFormat = "[쐐기돌: %s - %d 레벨]",
	completion0 = "%s|1이;가; %s에 끝났습니다. 제한 시간을 %s 초과했습니다.",
	completion1 = "%s|1을;를; %s에 완료했습니다. 제한 시간은 %s 남았으며 %s|1이;가; 모자라 2상자를 놓쳤습니다.",
	completion2 = "%s 2상자를 %s에 완료했습니다. 2상자 제한 시간은 %s 남았으며 %s|1이;가; 모자라 3상자를 놓쳤습니다.",
	completion3 = "%s 3상자를 %s에 완료했습니다. 3상자 제한 시간이 %s 남았습니다.",
	timeLost = "줄어든 시간",
	config_smallAffixes = "타이머 프레임에 속성 아이콘 크기 축소",
	config_deathTracker = "타이머 프레임에 사망 내역 표시",
}

langs.zhCN = {
	config_characterConfig = "为角色进行独立的配置",
	config_progressTooltip = "聊天窗口的史诗钥石显示副本名称和等级",
	config_progressFormat = "敌方部队进度格式",
	config_splitsFormat = "进度分割显示方式",
	config_splitsFormat_1 = "禁用",
	config_splitsFormat_2 = "从头计时",
	config_splitsFormat_3 = "与之前关联",
	config_autoGossip = "在史诗钥石副本中自动对话交互（如奥丁）",
	config_cosRumors = "群星庭院造谣者线索发送到队伍频道",
	config_silverGoldTimer = "同时显示2箱和3箱的计时",
	config_completionMessage = "副本完成时在聊天窗口显示总耗时",
	config_showSplits = "在任务列表的进度上显示单独的进度计时",
	keystoneFormat = "[%s（%d级）]",
	forcesFormat = " - 敌方部队 %s",
	completion0 = "你超时完成了 %s 的战斗。共耗时 %s，超出规定时间 %s。",
	completion1 = "你在规定时间内完成了 %s 的战斗！共耗时 %s，剩余时间 %s，2箱奖励超时 %s。",
	completion2 = "你在规定时间内获得了 %s 的2箱奖励！共耗时 %s，2箱奖励剩余时间 %s，3箱奖励超时 %s。",
	completion3 = "你在规定时间内获得了 %s 的3箱奖励！共耗时 %s，3箱奖励剩余时间 %s。",
	timeLost = "损失时间",
	config_smallAffixes = "缩小进度条上的光环图标大小",
	config_deathTracker = "在进度条上显示死亡统计",
}
langs.zhTW = {
	config_characterConfig = "為角色進行獨立的配置",
	config_progressTooltip = "聊天窗口的傳奇鑰石顯示副本名稱和等級",
	config_progressFormat = "敵方部隊進度格式",
	config_splitsFormat = "進度分割顯示方式",
	config_splitsFormat_1 = "禁用",
	config_splitsFormat_2 = "從頭計時",
	config_splitsFormat_3 = "與之前關聯",
	config_autoGossip = "在傳奇鑰石副本中自動進行對話互動（如歐丁）",
	config_cosRumors = "衆星之廷造謠者線索發送到隊伍頻道",
	config_silverGoldTimer = "同時顯示2箱及3箱的計時",
	config_completionMessage = "副本完成時在聊天窗口顯示總耗時",
	config_showSplits = "在任務列表的进度上顯示單獨的進度計時",
	keystoneFormat = "[%s（%d級）]",
	forcesFormat = " - 敵方部隊 %s",
	completion0 = "你超時完成了 %s 的戰鬥。共耗時 %s，超出規定時間 %s。",
	completion1 = "你在規定時間內完成了 %s 的戰鬥！共耗時 %s，剩餘時間 %s，2箱獎勵超時 %s。",
	completion2 = "你在規定時間內獲得了 %s 的2箱獎勵！共耗時 %s，2箱獎勵剩餘時間 %s，3箱獎勵超時 %s。",
	completion3 = "你在規定時間內獲得了 %s 的3箱獎勵！共耗時 %s，3箱獎勵剩餘時間 %s。",
	timeLost = "損失時間",
	config_smallAffixes = "縮小計時器上的光環圖標大小",
	config_deathTracker = "在計時器上顯示死亡統計",
}

function Locale:Get(key)
	if langs[current_locale] and langs[current_locale][key] ~= nil then
		return langs[current_locale][key]
	else
		return langs[default_locale][key]
	end
end

function Locale:Local(key)
	return langs[current_locale] and langs[current_locale][key]
end

function Locale:Exists(key)
	return langs[default_locale][key] ~= nil
end

setmetatable(Locale, {__index = Locale.Get})

local clues = {}
clues.enUS = {
	male = MALE,
	female = FEMALE,
	lightVest = "Light Vest",
	darkVest = "Dark Vest",
	shortSleeves = "Short Sleeves",
	longSleeves = "Long Sleeves",
	cloak = "Cloak",
	noCloak = "No Cloak",
	gloves = "Gloves",
	noGloves = "No Gloves",
	noPotion = "No Potion",
	book = "Book",
	coinpurse = "Coinpurse",
	potion = "Potion",
}
clues.enGB = clues.enUS

local rumors = {}
rumors.enUS = {
	["I heard somewhere that the spy isn't female."]="male",
	["I heard the spy is here and he's very good looking."]="male",
	["A guest said she saw him entering the manor alongside the Grand Magistrix."]="male",
	["One of the musicians said he would not stop asking questions about the district."]="male",

	["Someone's been saying that our new guest isn't male."]="female",
	["A guest saw both her and Elisande arrive together earlier."]="female",
	["They say that the spy is here and she's quite the sight to behold."]="female",
	["I hear some woman has been constantly asking about the district..."]="female",

	["The spy definitely prefers the style of light colored vests."]="lightVest",
	["I heard that the spy is wearing a lighter vest to tonight's party."]="lightVest",
	["People are saying the spy is not wearing a darker vest tonight."]="lightVest",

	["The spy definitely prefers darker clothing."]="darkVest",
	["I heard the spy's vest is a dark, rich shade this very night."]="darkVest",
	["The spy enjoys darker colored vests... like the night."]="darkVest",
	["Rumor has it the spy is avoiding light colored clothing to try and blend in more."]="darkVest",

	["Someone told me the spy hates wearing long sleeves."]="shortSleeves",
	["I heard the spy wears short sleeves to keep their arms unencumbered."]="shortSleeves",
	["I heard the spy enjoys the cool air and is not wearing long sleeves tonight."]="shortSleeves",
	["A friend of mine said she saw the outfit the spy was wearing. It did not have long sleeves."]="shortSleeves",

	["I heard the spy's outfit has long sleeves tonight."]="longSleeves",
	["A friend of mine mentioned the spy has long sleeves on."]="longSleeves",
	["Someone said the spy is covering up their arms with long sleeves tonight."]="longSleeves",
	["I just barely caught a glimpse of the spy's long sleeves earlier in the evening."]="longSleeves",

	["Someone mentioned the spy came in earlier wearing a cape."]="cloak",
	["I heard the spy enjoys wearing capes."]="cloak",

	["I heard that the spy left their cape in the palace before coming here."]="noCloak",
	["I heard the spy dislikes capes and refuses to wear one."]="noCloak",

	["There's a rumor that the spy always wears gloves."]="gloves",
	["I heard the spy carefully hides their hands."]="gloves",
	["Someone said the spy wears gloves to cover obvious scars."]="gloves",
	["I heard the spy always dons gloves."]="gloves",

	["You know... I found an extra pair of gloves in the back room. The spy is likely to be bare handed somewhere around here."]="noGloves",
	["There's a rumor that the spy never has gloves on."]="noGloves",
	["I heard the spy avoids having gloves on, in case some quick actions are needed."]="noGloves",
	["I heard the spy dislikes wearing gloves."]="noGloves",

	["Rumor has is the spy loves to read and always carries around at least one book."]="book",
	["I heard the spy always has a book of written secrets at the belt."]="book",

	["A musician told me she saw the spy throw away their last potion and no longer has any left."]="noPotion",
	["I heard the spy is not carrying any potions around."]="noPotion",

	["I'm pretty sure the spy has potions at the belt."]="potion",
	["I heard the spy brought along potions, I wonder why?"]="potion",
	["I heard the spy brought along some potions... just in case."]="potion",
	["I didn't tell you this... but the spy is masquerading as an alchemist and carrying potions at the belt."]="potion",

	["I heard the spy's belt pouch is lined with fancy threading."]="coinpurse",
	["A friend said the spy loves gold and a belt pouch filled with it."]="coinpurse",
	["I heard the spy's belt pouch is filled with gold to show off extravagance."]="coinpurse",
	["I heard the spy carries a magical pouch around at all times."]="coinpurse",
}
rumors.enGB = rumors.enUS

function Locale:HasRumors()
	return rumors[current_locale] ~= nil and clues[current_locale] ~= nil
end

function Locale:Rumor(gossip)
	if rumors[current_locale] and rumors[current_locale][gossip] then
		return clues[current_locale] and clues[current_locale][rumors[current_locale][gossip]]
	end
end

current_locale = GetLocale()
