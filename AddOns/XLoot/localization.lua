local XLoot = select(2, ...)

local function CompileLocales(locales)
	local L = locales[GetLocale()] and locales[GetLocale()] or locales.enUS
	if L ~= locales.enUS then
		setmetatable(L, { __index = locales.enUS })
		for k, v in pairs(L) do	
			if type(v) == 'table' then
				setmetatable(v, { __index = locales.enUS[k] })
			end
		end
	end
	return L
end

-- locales expects table: { enUS = {...}, ... }
function XLoot:Localize(name, locales)
	self["L_"..name] = CompileLocales(locales)
end

local locales = {
	enUS = {
		skin_svelte = "XLoot: Svelte",
		skin_legacy = "XLoot: Legacy",
		skin_smooth = "XLoot: Smooth",
		anchor_hide = "hide",
		anchor_hide_desc = "Lock this module in position\nThis will hide the anchor,\nbut it can be shown again from the options",
	},
	-- Possibly localized
	ptBR = {},
	frFR = {},
	deDE = {},
	koKR = {},
	esMX = {},
	ruRU = {},
	zhCN = {},
	esES = {},
	zhTW = {},
}

-- Automatically inserted translations
locales.deDE["anchor_hide"] = "verstecken"
locales.deDE["skin_legacy"] = "XLoot: Legacy"
locales.deDE["skin_smooth"] = "XLoot: Smooth"
locales.deDE["skin_svelte"] = "XLoot: Svelte"
locales.koKR["anchor_hide"] = "감추기"
locales.koKR["skin_legacy"] = "XLoot: Legacy"
locales.koKR["skin_smooth"] = "XLoot: Smooth"
locales.koKR["skin_svelte"] = "XLoot: Svelte"
locales.ruRU["anchor_hide"] = "скрыть "
locales.ruRU["anchor_hide_desc"] = [=[Заблокируйте положение этого модуля
Это позволит скрыть якорь,
но он может быть показан еще раз в настройках]=]
locales.ruRU["skin_legacy"] = "XLoot: Legacy"
locales.ruRU["skin_smooth"] = "XLoot: Smooth"
locales.ruRU["skin_svelte"] = "XLoot: Svelte"
locales.zhCN["anchor_hide"] = "隐藏"
locales.zhCN["anchor_hide_desc"] = [=[在此位置锁定此模块
这将隐藏锚点
但可通过选项重新显示]=]
locales.zhCN["skin_legacy"] = "XLoot: Legacy"
locales.zhCN["skin_smooth"] = "XLoot: Smooth"
locales.zhCN["skin_svelte"] = "XLoot: Svelte"
locales.zhTW["anchor_hide"] = "隱藏"
locales.zhTW["anchor_hide_desc"] = [=[鎖定此模組在此位置上
這會隱藏此錨點,
但它可以藉由選項再次顯示]=]
locales.zhTW["skin_legacy"] = "XLoot: 傳統"
locales.zhTW["skin_smooth"] = "XLoot: 滑順"
locales.zhTW["skin_svelte"] = "XLoot: 苗條"


XLoot.L = CompileLocales(locales)
