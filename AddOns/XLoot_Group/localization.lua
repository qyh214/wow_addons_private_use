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
locales.deDE["alert_anchor"] = "Beute Popups"
locales.deDE["anchor"] = "Gruppenwürfe"
locales.deDE["undecided"] = "Unentschlossen"
locales.koKR["alert_anchor"] = "전리품 팝업"
locales.koKR["anchor"] = "그룹 주사위"
locales.koKR["undecided"] = "미결정"
locales.ruRU["alert_anchor"] = "Всплывающие фреймы добычи"
locales.ruRU["anchor"] = "Броски группы"
locales.ruRU["undecided"] = "Не принял решения"
locales.zhCN["alert_anchor"] = "掷骰弹窗锚点"
locales.zhCN["anchor"] = "团队掷骰锚点"
locales.zhCN["undecided"] = "未决定的"
locales.zhTW["alert_anchor"] = "拾取彈出視窗定位"
locales.zhTW["anchor"] = "團體擲骰定位"
locales.zhTW["undecided"] = "未決"

XLoot:Localize("Group", locales)
