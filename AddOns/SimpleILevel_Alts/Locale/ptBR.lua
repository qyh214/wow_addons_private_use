local L = LibStub("AceLocale-3.0"):NewLocale("SimpleILevel", "ptBR");
if not L then return end
L.alts = {
	addonName = "Simple iLevel - Alts", -- Needs review
	desc = "Ver ilvl de seus alts", -- Needs review
	load = "Alts módulo carregado", -- Needs review
	name = "SiL Alts", -- Needs review
	nameShort = "Alts", -- Needs review
	options = {
		colorizeILvl = "Use SiL ilvl colorizado", -- Needs review
		colorizeILvlDesc = "Marque esta caixa para colorir o ilvl com base em sua pontuação. Desmarque a opção de usar cores da classe padrão.", -- Needs review
		enabled = "Ativado", -- Needs review
		enabledDesc = "Habilitar todos os recursos ou SiL social.", -- Needs review
		name = "SiL Opções Alts", -- Needs review
		onlyMaxLevel = "Mostrar Apenas Nível Máximo", -- Needs review
		onlyMaxLevelDesc = "Confira a esconder quaisquer caracteres abaixo do nível máximo.", -- Needs review
		realmList = "Mostrar todos os reinos", -- Needs review
		showAllFactions = "Mostrar todas as facções", -- Needs review
		showAllFactionsDesc = "Visualizar personagens de todas as facções ou apenas o seu atual.", -- Needs review
		showAllRealms = "Mostrar todos os reinos", -- Needs review
		showAllRealmsDesc = "Mostrar caracteres em todos os reinos ou apenas um presente.", -- Needs review
		showCharacter = "Mostrar caracteres:", -- Needs review
		showTotals = "Mostrar Média ilvl", -- Needs review
		showTotalsDesc = "Mostrar ilvl média total do personagem", -- Needs review
	},
	tooltip = {
		labelHeader = "Personagem iLevel Repartição", -- Needs review
		labelName = "Nome", -- Needs review
		labelPrimary = "Primário", -- Needs review
		labelSecondary = "Secundário", -- Needs review
		labelTotal = "Total", -- Needs review
	},
}

