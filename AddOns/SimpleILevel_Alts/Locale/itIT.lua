local L = LibStub("AceLocale-3.0"):NewLocale("SimpleILevel", "itIT");
if not L then return end
L.alts = {
	addonName = "Simple iLevel - Alts", -- Needs review
	desc = "Guarda ilvl dei tuoi alts", -- Needs review
	load = "Alts modulo caricato", -- Needs review
	name = "SiL Alts", -- Needs review
	nameShort = "Alts", -- Needs review
	options = {
		colorizeILvl = "Usa SiL ilvl colorized", -- Needs review
		colorizeILvlDesc = "Seleziona questa casella per colorare la ilvl in base al suo punteggio. Deselezionare per usare i colori della classe predefinita.", -- Needs review
		enabled = "Abilitato", -- Needs review
		enabledDesc = "Attivare tutte le caratteristiche o SiL sociale.", -- Needs review
		name = "Sil Opzioni Alts", -- Needs review
		onlyMaxLevel = "Mostra solo Livello Max", -- Needs review
		onlyMaxLevelDesc = "Controllare per nascondere i caratteri sotto il livello max.", -- Needs review
		realmList = "Visualizza tutti i regni", -- Needs review
		showAllFactions = "Mostra tutte le fazioni", -- Needs review
		showAllFactionsDesc = "Mostra i caratteri di tutte le fazioni o solo quello corrente.", -- Needs review
		showAllRealms = "Visualizza tutti i regni", -- Needs review
		showAllRealmsDesc = "Mostra caratteri su tutti i regni o solo questo.", -- Needs review
		showCharacter = "Mostra caratteri:", -- Needs review
		showTotals = "Mostra Media ilvl", -- Needs review
		showTotalsDesc = "Mostra totale ilvl media del personaggio", -- Needs review
	},
	tooltip = {
		labelHeader = "Carattere iLevel Ripartizione", -- Needs review
		labelName = "Nome", -- Needs review
		labelPrimary = "Primario", -- Needs review
		labelSecondary = "Secondario", -- Needs review
		labelTotal = "Totale", -- Needs review
	},
}

