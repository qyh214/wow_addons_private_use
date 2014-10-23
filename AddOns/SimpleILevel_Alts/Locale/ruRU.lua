local L = LibStub("AceLocale-3.0"):NewLocale("SimpleILevel", "ruRU");
if not L then return end
L.alts = {
	addonName = "Simple iLevel - Alts", -- Needs review
	desc = "Посмотреть iLvL ваших альтов", -- Needs review
	load = "Alts Модуль Loaded", -- Needs review
	name = "SiL Alts", -- Needs review
	nameShort = "Alts", -- Needs review
	options = {
		colorizeILvl = "Использование SiL раскрашены ilvl", -- Needs review
		colorizeILvlDesc = "Установите этот флажок, чтобы раскрасить в ilvl, основанный на его счет. Снимите флажок, чтобы использовать цвета класса по умолчанию.", -- Needs review
		enabled = "Включено", -- Needs review
		enabledDesc = "Включить все функции или SIL социал.", -- Needs review
		name = "SIL Опции Alts", -- Needs review
		onlyMaxLevel = "Показать только Максимальный уровень", -- Needs review
		onlyMaxLevelDesc = "Проверьте, чтобы скрыть любые символы ниже уровня макс.", -- Needs review
		realmList = "Показать всех областях", -- Needs review
		showAllFactions = "Показать всех фракций", -- Needs review
		showAllFactionsDesc = "Показать персонажи из всех фракций или только ваш текущий.", -- Needs review
		showAllRealms = "Показать всех областях", -- Needs review
		showAllRealmsDesc = "Показать символов на всех сфер или просто этот.", -- Needs review
		showCharacter = "Показать Персонажи:", -- Needs review
		showTotals = "Показать Средний iLvl", -- Needs review
		showTotalsDesc = "Показать полную среднюю ilvl персонажа", -- Needs review
	},
	tooltip = {
		labelHeader = "Характер iLevel Breakdown", -- Needs review
		labelName = "Имя", -- Needs review
		labelPrimary = "Первичная", -- Needs review
		labelSecondary = "Вторичный", -- Needs review
		labelTotal = "Всего", -- Needs review
	},
}

