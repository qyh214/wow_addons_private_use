local L = LibStub("AceLocale-3.0"):NewLocale("SimpleILevel", "frFR");
if not L then return end
L.alts = {
	addonName = "Simple iLevel - Alts", -- Needs review
	desc = "Voir ilvl de vos offres anormalement basses", -- Needs review
	load = "Alts module chargé", -- Needs review
	name = "SiL Alts", -- Needs review
	nameShort = "Alts", -- Needs review
	options = {
		colorizeILvl = "Utilisez SIL ilvl colorisé", -- Needs review
		colorizeILvlDesc = "Cochez cette case pour coloriser le ilvl en fonction de son score. Décochez cette case pour utiliser les couleurs de classe par défaut.", -- Needs review
		enabled = "Activé", -- Needs review
		enabledDesc = "Activer toutes les fonctionnalités ou SIL sociale.", -- Needs review
		name = "SiL options Alts", -- Needs review
		onlyMaxLevel = "Afficher uniquement Niveau Max", -- Needs review
		onlyMaxLevelDesc = "Vérifiez cacher les caractères ci-dessous du niveau max.", -- Needs review
		realmList = "Voir tous les royaumes", -- Needs review
		showAllFactions = "Voir tous Factions", -- Needs review
		showAllFactionsDesc = "Afficher les caractères de toutes les factions ou tout simplement votre actuel.", -- Needs review
		showAllRealms = "Voir tous les royaumes", -- Needs review
		showAllRealmsDesc = "Afficher les caractères sur tous les domaines ou celle-ci.", -- Needs review
		showCharacter = "Afficher les caractères:", -- Needs review
		showTotals = "Afficher moyen ilvl", -- Needs review
		showTotalsDesc = "Voir totale ilvl moyen du personnage", -- Needs review
	},
	tooltip = {
		labelHeader = "iLevel caractère Répartition", -- Needs review
		labelName = "Prénom", -- Needs review
		labelPrimary = "Primaire", -- Needs review
		labelSecondary = "Secondaire", -- Needs review
		labelTotal = "Total", -- Needs review
	},
}

