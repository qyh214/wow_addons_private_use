-- See: http://wow.curseforge.com/addons/xloot/localization/ to create or fix translations
local locales = {
	enUS = {
		anchor = "Group Rolls",
		alert_anchor = "Loot Popups",
		undecided = "Undecided",
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
locales.ptBR["Group"] = {
	["alert_anchor"] = "Aparecer Saques",
}

locales.frFR["Group"] = {
}

locales.deDE["Group"] = {
	["alert_anchor"] = "Beute Popups",
	["anchor"] = "Gruppenwürfe",
	["undecided"] = "Unentschlossen",
}

locales.koKR["Group"] = {
	["alert_anchor"] = "전리품 팝업",
	["anchor"] = "그룹 주사위",
	["undecided"] = "미결정",
}

locales.esMX["Group"] = {
	["alert_anchor"] = "Ventanas emergentes de botín",
}

locales.ruRU["Group"] = {
	["alert_anchor"] = "Всплывающие фреймы добычи.",
	["anchor"] = "Броски группы",
	["undecided"] = "Не принял решения",
}

locales.zhCN["Group"] = {
	["alert_anchor"] = "掷骰弹窗锚点",
	["anchor"] = "团队掷骰锚点",
	["undecided"] = "未决定的",
}

locales.esES["Group"] = {
}

locales.zhTW["Group"] = {
	["alert_anchor"] = "拾取彈出視窗定位",
	["anchor"] = "團體擲骰定位",
	["undecided"] = "未決",
}


XLoot:Localize("Group", locales)
