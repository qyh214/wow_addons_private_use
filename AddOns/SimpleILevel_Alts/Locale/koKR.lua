local L = LibStub("AceLocale-3.0"):NewLocale("SimpleILevel", "koKR");
if not L then return end
L.alts = {
	addonName = "Simple iLevel - Alts", -- Needs review
	desc = "iLvL 당신의 대안으로보기", -- Needs review
	load = "알츠 모듈로드", -- Needs review
	name = "SiL Alts", -- Needs review
	nameShort = "Alts", -- Needs review
	options = {
		colorizeILvl = "사용 SIL 색상 화 ilvl", -- Needs review
		colorizeILvlDesc = "그 점수에 따라 ilvl 색상 화하려면이 상자를 선택하십시오. 기본 클래스 색상을 사용하려면이 옵션을 선택 해제하십시오.", -- Needs review
		enabled = "사용", -- Needs review
		enabledDesc = "모든 기능 또는 SIL 사회를 활성화합니다.", -- Needs review
		name = "SIL 알츠 옵션", -- Needs review
		onlyMaxLevel = "만 최대 레벨보기", -- Needs review
		onlyMaxLevelDesc = "최대 레벨 이하의 모든 문자를 숨길 확인합니다.", -- Needs review
		realmList = "모든 영역을 표시", -- Needs review
		showAllFactions = "모든 파벌보기", -- Needs review
		showAllFactionsDesc = "모든 파벌 또는 당신의 현재에서보기 문자.", -- Needs review
		showAllRealms = "모든 영역을 표시", -- Needs review
		showAllRealmsDesc = "모든 영역 또는 그냥이 일에 쇼 문자.", -- Needs review
		showCharacter = "표시 문자 :", -- Needs review
		showTotals = "쇼 평균 iLvl", -- Needs review
		showTotalsDesc = "캐릭터의 총 평균 ilvl보기", -- Needs review
	},
	tooltip = {
		labelHeader = "문자 iLevel 고장", -- Needs review
		labelName = "이름", -- Needs review
		labelPrimary = "주요한 사물", -- Needs review
		labelSecondary = "이차", -- Needs review
		labelTotal = "전체", -- Needs review
	},
}

