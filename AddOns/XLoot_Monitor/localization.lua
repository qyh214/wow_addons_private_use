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


locales.deDE["anchor"] = "Beute Monitor" -- Needs review



locales.ruRU["anchor"] = "Монитор добычи"

locales.zhCN["anchor"] = "掷骰监控"


locales.zhTW["anchor"] = "拾取監控"


XLoot:Localize("Monitor", locales)
