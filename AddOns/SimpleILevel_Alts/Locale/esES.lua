local L = LibStub("AceLocale-3.0"):NewLocale("SimpleILevel", "esES");
if not L then return end
L.alts = {
	addonName = "Simple iLevel - Alts", -- Needs review
	desc = "Ver ilvL de sus alts", -- Needs review
	load = "Alts Módulo Loaded", -- Needs review
	name = "SiL Alts", -- Needs review
	nameShort = "Alts", -- Needs review
	options = {
		colorizeILvl = "Uso SiL ilvl coloreada", -- Needs review
		colorizeILvlDesc = "Marque esta casilla para colorear el ilvl en función de su puntuación. Desactive la opción de usar los colores de la clase por defecto.", -- Needs review
		enabled = "Activado", -- Needs review
		enabledDesc = "Activar todas las funciones o SiL Social.", -- Needs review
		name = "SiL Opciones Alts", -- Needs review
		onlyMaxLevel = "Mostrar Sólo Max Nivel", -- Needs review
		onlyMaxLevelDesc = "Compruebe que ocultar los caracteres por debajo del nivel máximo.", -- Needs review
		realmList = "Mostrar todos los Reinos", -- Needs review
		showAllFactions = "Mostrar todas las facciones", -- Needs review
		showAllFactionsDesc = "Mostrar caracteres de todas las facciones o sólo la actual.", -- Needs review
		showAllRealms = "Mostrar todos los Reinos", -- Needs review
		showAllRealmsDesc = "Mostrar caracteres en todos los reinos o solo este.", -- Needs review
		showCharacter = "Mostrar caracteres:", -- Needs review
		showTotals = "Mostrar Promedio ilvL", -- Needs review
		showTotalsDesc = "Mostrar ilvl promedio total del personaje", -- Needs review
	},
	tooltip = {
		labelHeader = "Carácter iLevel Desglose", -- Needs review
		labelName = "Nombre", -- Needs review
		labelPrimary = "primaria", -- Needs review
		labelSecondary = "secundaria", -- Needs review
		labelTotal = "total", -- Needs review
	},
}

