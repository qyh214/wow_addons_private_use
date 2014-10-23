local L = LibStub("AceLocale-3.0"):NewLocale("SimpleILevel", "enUS", true);

L.alts = {
	addonName = "Simple iLevel - Alts",
	desc = "View iLvL of your alts",
	load = "Alts Module Loaded",
	name = "SiL Alts",
	nameShort = "Alts",
	options = {
		colorizeILvl = "Use SiL colorized ilvl",
		colorizeILvlDesc = "Check this box to colorize the ilvl based on its score. Uncheck to use default class colors.",
		enabled = "Enabled",
		enabledDesc = "Enable all features or SiL Social.",
		name = "SiL Alts Options",
		onlyMaxLevel = "Show Only Max Level",
		onlyMaxLevelDesc = "Check to hide any characters below the max level.",
		realmList = "Show All Realms",
		showAllFactions = "Show All Factions",
		showAllFactionsDesc = "Show characters from all factions or just your current one.",
		showAllRealms = "Show All Realms",
		showAllRealmsDesc = "Show characters on all realms or just this one.",
		showCharacter = "Show Characters:",
		showTotals = "Show Average iLvl",
		showTotalsDesc = "Show the character's total average ilvl",
	},
	tooltip = {
		labelHeader = "Character iLevel Breakdown",
		labelName = "Name",
		labelPrimary = "Primary",
		labelSecondary = "Secondary",
		labelTotal = "Total",
	},
}



