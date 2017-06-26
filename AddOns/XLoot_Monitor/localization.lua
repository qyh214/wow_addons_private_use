-- See: http://wow.curseforge.com/addons/xloot/localization/ to create or fix translations
local locales = {
	enUS = {
		anchor = "Loot Monitor",
	},
	-- Possibly localized
	ptBR = {

	},
	frFR = {

	},
	deDE = {

	},
	koKR = {

	},
	esMX = {

	},
	ruRU = {

	},
	zhCN = {

	},
	esES = {

	},
	zhTW = {

	},
}

-- Automatically inserted translations
locales.ptBR["Monitor"] = {
}

locales.frFR["Monitor"] = {
}

locales.deDE["Monitor"] = {
	["anchor"] = "Beutemonitor",
}

locales.koKR["Monitor"] = {
	["anchor"] = "전리품 모니터",
}

locales.esMX["Monitor"] = {
}

locales.ruRU["Monitor"] = {
	["anchor"] = "Монитор добычи",
}

locales.zhCN["Monitor"] = {
	["anchor"] = "掷骰监控",
}

locales.esES["Monitor"] = {
}

locales.zhTW["Monitor"] = {
	["anchor"] = "拾取監控",
}


XLoot:Localize("Monitor", locales)
