local L = LibStub("AceLocale-3.0"):NewLocale("SimpleILevel", "deDE");
if not L then return end
L.alts = {
	addonName = "Simple iLevel - Alts", -- Needs review
	desc = "Informieren Sie ILVL Ihrer Alts", -- Needs review
	load = "Alts Modul geladen", -- Needs review
	name = "SiL Alts", -- Needs review
	nameShort = "Alts", -- Needs review
	options = {
		colorizeILvl = "Verwendung SiL färbt ilvl", -- Needs review
		colorizeILvlDesc = "Markieren Sie dieses Feld, um das ilvl auf der Grundlage seiner Partitur zu kolorieren. Deaktivieren Sie die Option, um Standardklasse Farben zu verwenden.", -- Needs review
		enabled = "Aktiviert", -- Needs review
		enabledDesc = "Aktivieren Sie alle Funktionen oder SiL Sozial.", -- Needs review
		name = "SiL Alts Optionen", -- Needs review
		onlyMaxLevel = "Nur Max Ebene", -- Needs review
		onlyMaxLevelDesc = "Überprüfen, um keine Zeichen unterhalb der Maximalstufe zu verstecken.", -- Needs review
		realmList = "Zeige alle Realms", -- Needs review
		showAllFactions = "Zeigen alle Fraktionen", -- Needs review
		showAllFactionsDesc = "Show Zeichen aus allen Fraktionen oder einfach nur deine aktuelle.", -- Needs review
		showAllRealms = "Zeige alle Realms", -- Needs review
		showAllRealmsDesc = "Show Zeichen auf allen Gebieten oder einfach nur dieser.", -- Needs review
		showCharacter = "Show Zeichen:", -- Needs review
		showTotals = "Durschnittlich iLvl", -- Needs review
		showTotalsDesc = "Zeigen durchschnittliche ilvl des Charakters", -- Needs review
	},
	tooltip = {
		labelHeader = "Charakter iLevel Pannen", -- Needs review
		labelName = "Name", -- Needs review
		labelPrimary = "Primär", -- Needs review
		labelSecondary = "Sekundär", -- Needs review
		labelTotal = "Gesamt", -- Needs review
	},
}

