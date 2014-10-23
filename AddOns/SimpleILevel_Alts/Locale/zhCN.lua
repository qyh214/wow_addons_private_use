local L = LibStub("AceLocale-3.0"):NewLocale("SimpleILevel", "zhCN");
if not L then return end
L.alts = {
	addonName = "Simple iLevel - Alts", -- Needs review
	desc = "查看你的低价竞标的物品等级", -- Needs review
	load = "低价竞标模块中加载", -- Needs review
	name = "SiL Alts", -- Needs review
	nameShort = "Alts", -- Needs review
	options = {
		colorizeILvl = "使用SIL彩色化物品等级", -- Needs review
		colorizeILvlDesc = "选中此复选框上色根据其得分的物品等级。取消选中使用默认的类的颜色。", -- Needs review
		enabled = "启用", -- Needs review
		enabledDesc = "开启所有功能，SIL社会。", -- Needs review
		name = "SIL 低价竞标选项", -- Needs review
		onlyMaxLevel = "只显示最高等级", -- Needs review
		onlyMaxLevelDesc = "检查隐藏低于最大级别的任何字符。", -- Needs review
		realmList = "显示所有领域", -- Needs review
		showAllFactions = "显示所有派别", -- Needs review
		showAllFactionsDesc = "显示字符的所有派别或只是你目前的之一。", -- Needs review
		showAllRealms = "显示所有领域", -- Needs review
		showAllRealmsDesc = "在各个领域，或仅这一个显示字符。", -- Needs review
		showCharacter = "显示的字符：", -- Needs review
		showTotals = "显示平均物品等级", -- Needs review
		showTotalsDesc = "显示人物的总平均物品等级", -- Needs review
	},
	tooltip = {
		labelHeader = "人物iLevel击穿", -- Needs review
		labelName = "产品名称", -- Needs review
		labelPrimary = "小学", -- Needs review
		labelSecondary = "二级", -- Needs review
		labelTotal = "总", -- Needs review
	},
}

