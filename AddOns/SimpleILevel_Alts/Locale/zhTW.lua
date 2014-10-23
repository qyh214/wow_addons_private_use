local L = LibStub("AceLocale-3.0"):NewLocale("SimpleILevel", "zhTW");
if not L then return end
L.alts = {
	addonName = "Simple iLevel - Alts",
	desc = "查看你的低價競標的物品等級", -- Needs review
	load = "低價競標模塊中加載", -- Needs review
	name = "SiL Alts", -- Needs review
	nameShort = "Alts", -- Needs review
	options = {
		colorizeILvl = "使用SIL彩色化物品等級", -- Needs review
		colorizeILvlDesc = "選中此複選框上色根據其得分的物品等級。取消選中使用默認的類的顏色。", -- Needs review
		enabled = "已啟用",
		enabledDesc = "開啟所有功能，SIL社會。", -- Needs review
		name = "SIL 低價競標選項", -- Needs review
		onlyMaxLevel = "只顯示最高等級", -- Needs review
		onlyMaxLevelDesc = "檢查隱藏低於最大級別的任何字符。", -- Needs review
		realmList = "顯示所有領域", -- Needs review
		showAllFactions = "顯示所有派別", -- Needs review
		showAllFactionsDesc = "顯示字符的所有派別或只是你目前的之一。", -- Needs review
		showAllRealms = "顯示所有領域", -- Needs review
		showAllRealmsDesc = "在各個領域，或僅這一個顯示字符。", -- Needs review
		showCharacter = "顯示的字符：", -- Needs review
		showTotals = "顯示平均物品等級", -- Needs review
		showTotalsDesc = "顯示人物的總平均物品等級", -- Needs review
	},
	tooltip = {
		labelHeader = "人物iLevel擊穿", -- Needs review
		labelName = "名稱",
		labelPrimary = "主要",
		labelSecondary = "次要",
		labelTotal = "合計",
	},
}

