---@class AddonPrivate
local Private = select(2, ...)

local locales = Private.Locales or {}
Private.Locales = locales
local L = {
    -- UI/Components/Dropdown.lua
    ["Components.Dropdown.SelectOption"] = "옵션 선택",

    -- UI/Tabs/ArtifactTraitsTabUI.lua
    ["Tabs.ArtifactTraitsTabUI.AutoActivateForSpec"] = "전문화별 자동 활성화",
    ["Tabs.ArtifactTraitsTabUI.NoArtifactEquipped"] = "장착된 유물 없음",

    -- UI/Tabs/CollectionTabUI.lua
    ["Tabs.CollectionTabUI.CtrlClickPreview"] = "Ctrl+클릭으로 미리보기",
    ["Tabs.CollectionTabUI.ShiftClickToLink"] = "Shift+클릭으로 링크",
    ["Tabs.CollectionTabUI.NoName"] = "이름 없음",
    ["Tabs.CollectionTabUI.AltClickVendor"] = "Alt+클릭으로 상인 위치 설정",
    ["Tabs.CollectionTabUI.AltClickAchievement"] = "Alt+클릭으로 업적 보기",
    ["Tabs.CollectionTabUI.FilterCollected"] = "수집됨",
    ["Tabs.CollectionTabUI.FilterNotCollected"] = "미수집",
    ["Tabs.CollectionTabUI.FilterSources"] = "출처",
    ["Tabs.CollectionTabUI.FilterCheckAll"] = "모두 선택",
    ["Tabs.CollectionTabUI.FilterUncheckAll"] = "모두 해제",
    ["Tabs.CollectionTabUI.FilterRaidVariants"] = "레이드 옵션 표시",
    ["Tabs.CollectionTabUI.FilterUnique"] = "리믹스 전용 아이템만 표시",
    ["Tabs.CollectionTabUI.Type"] = "종류",
    ["Tabs.CollectionTabUI.Source"] = "출처",
    ["Tabs.CollectionTabUI.SearchInstructions"] = "검색",
    ["Tabs.CollectionTabUI.Progress"] = "%d / %d (%.2f%%)",
    ["Tabs.CollectionTabUI.ProgressTooltip"] = "현재 수집품의 가치는 총 %s 청동 화폐 중 %s입니다.\n모든 것을 수집하려면 %s를 더 소모해야 합니다!",

    -- UI/CollectionsTabUI.lua
    ["CollectionsTabUI.TabTitle"] = "군단 리믹스",
    ["CollectionsTabUI.ResearchProgress"] = "연구: %s/%s",
    ["CollectionsTabUI.TraitsTabTitle"] = "유물 특성",
    ["CollectionsTabUI.CollectionTabTitle"] = "수집품",

    -- UI/QuickActionBarUI.lua
    ["QuickActionBarUI.QuickBarTitle"] = "빠른 실행바",
    ["QuickActionBarUI.SettingTitlePreview"] = "여기에 동작 제목",
    ["QuickActionBarUI.SettingsEditorTitle"] = "동작 편집",
    ["QuickActionBarUI.SettingsTitleLabel"] = "동작 이름:",
    ["QuickActionBarUI.SettingsTitleInput"] = "동작의 이름",
    ["QuickActionBarUI.SettingsIconLabel"] = "아이콘:",
    ["QuickActionBarUI.SettingsIconInput"] = "텍스처 ID 또는 경로",
    ["QuickActionBarUI.SettingsIDLabel"] = "동작 ID:",
    ["QuickActionBarUI.SettingsIDInput"] = "아이템/주문 이름 또는 ID",
    ["QuickActionBarUI.SettingsTypeLabel"] = "동작 종류:",
    ["QuickActionBarUI.SettingsTypeInputSpell"] = "주문",
    ["QuickActionBarUI.SettingsTypeInputItem"] = "아이템",
    ["QuickActionBarUI.SettingsCheckUsableLabel"] = "사용 가능할 때만:",
    ["QuickActionBarUI.SettingsEditorSave"] = "동작 저장",
    ["QuickActionBarUI.SettingsEditorNew"] = "새 동작",
    ["QuickActionBarUI.SettingsEditorDelete"] = "동작 삭제",
    ["QuickActionBarUI.SettingsNoActionSaveError"] = "저장할 동작이 없습니다.",
    ["QuickActionBarUI.SettingsEditorAction"] = "동작 %s",
    ["QuickActionBarUI.SettingsGeneralActionSaveError"] = "동작 저장 중 오류가 발생했습니다: %s",
    ["QuickActionBarUI.CombatToggleError"] = "빠른 실행바는 전투 중에는 열거나 닫을 수 없습니다.",

    -- UI/ScrappingUI.lua
    ["ScrappingUI.MaxScrappingQuality"] = "최대 분해 품질",
    ["ScrappingUI.MinItemLevelDifference"] = "최소 아이템 레벨 차이",
    ["ScrappingUI.MinItemLevelDifferenceInstructions"] = "착용 중인 것보다 x레벨 낮은",
    ["ScrappingUI.AutoScrap"] = "자동 분해",
    ["ScrappingUI.ScraperListTabTitle"] = "분해 리스트",
    ["ScrappingUI.AdvancedSettingsTabTitle"] = "추가 설정",
    ["ScrappingUI.JewelryTraitsToKeep"] = "유지할 아이템 및 특성",
    ["ScrappingUI.AdvancedJewelryFilter"] = "고급 아이템 및 특성 필터",
    ["ScrappingUI.FilterCheckAll"] = "모두 선택",
    ["ScrappingUI.FilterUncheckAll"] = "모두 선택 해제",
    ["ScrappingUI.Neck"] = "목걸이 특성",
    ["ScrappingUI.Trinket"] = "장신구 특성",
    ["ScrappingUI.Finger"] = "반지 특성",
    ["ScrappingUI.IgnoreFromEquipmentSets"] = "장비 구성된 아이템 무시",

    -- Utils/ArtifactTraitUtils.lua
    ["ArtifactTraitUtils.NoItemEquipped"] = "장착된 아이템이 없습니다.",
    ["ArtifactTraitUtils.UnknownTrait"] = "알 수 없는 특성",
    ["ArtifactTraitUtils.ColumnNature"] = "자연",
    ["ArtifactTraitUtils.ColumnFel"] = "혼돈",
    ["ArtifactTraitUtils.ColumnArcane"] = "비전",
    ["ArtifactTraitUtils.ColumnStorm"] = "폭풍",
    ["ArtifactTraitUtils.ColumnHoly"] = "신성",
    ["ArtifactTraitUtils.JewelryFormat"] = "|T%s:16|t %s (+%d)",
    ["ArtifactTraitUtils.MaxTriesReached"] = "구매 시도 가능 횟수가 최대치에 도달했습니다.",
    ["ArtifactTraitUtils.SettingsCategoryPrefix"] = "유물 특성",
    ["ArtifactTraitUtils.SettingsCategoryTooltip"] = "유물 특성 기능 설정",
    ["ArtifactTraitUtils.AutoBuy"] = "자동 유물 연구",
    ["ArtifactTraitUtils.AutoBuyTooltip"] = "유물 마력이 충분할 때 미리 설정된 특성을 자동으로 연구합니다.",

    -- Utils/CollectionUtils.lua
    ["CollectionUtils.Sources"] = "출처:",
    ["CollectionUtils.Achievement"] = "업적: ",
    ["CollectionUtils.UnknownAchievement"] = "알 수 없는 업적",
    ["CollectionUtils.UnknownVendor"] = "알 수 없는 상인",
    ["CollectionUtils.Vendor"] = "상인, ",

    -- Utils/CommandUtils.lua
    ["CommandUtils.UnknownCommand"] =
[[알 수 없는 명령어입니다!
사용법: /LRH 또는 /LegionRH <하위명령어>
하위명령어:
    collections (c) - 수집품 탭을 엽니다.
    settings (s) - 설정 메뉴를 엽니다.
예시: /LRH s]],
    ["CommandUtils.CollectionsCommand"] = "수집품",
    ["CommandUtils.CollectionsCommandShort"] = "c",
    ["CommandUtils.SettingsCommand"] = "설정",
    ["CommandUtils.SettingsCommandShort"] = "s",

    -- Utils/EditModeUtils.lua
    ["EditModeUtils.ShowAddonSystems"] = "Legion-Remix-Helper-Systems",
    ["EditModeUtils.SystemLabel.ToastUI"] = "알림창",
    ["EditModeUtils.SystemTooltip.ToastUI"] = "알림창의 위치를 이동합니다.",

    -- Utils/ItemOpenerUtils.lua
    ["ItemOpenerUtils.SettingsCategoryPrefix"] = "자동 아이템 열기",
    ["ItemOpenerUtils.SettingsCategoryTooltip"] = "자동 아이템 열기 기능 설정",
    ["ItemOpenerUtils.AutoItemOpen"] = "아이템 자동 열기",
    ["ItemOpenerUtils.AutoItemOpenTooltip"] = "인벤토리에서 특정 아이템을 발견했을 때 자동으로 엽니다. (이 기능은 아직 개발 중입니다)",
    ["ItemOpenerUtils.AutoOpenItemEntryTooltip"] = "인벤토리에서 %s를 발견했을 때 자동으로 엽니다.",

    -- Utils/MerchantUtils.lua
    ["MerchantUtils.SettingsCategoryPrefix"] = "상점 설정",
    ["MerchantUtils.SettingsCategoryTooltip"] = "상점 기능 설정",
    ["MerchantUtils.HideCollectedMerchantItems"] = "수집된 상점 아이템 숨기기",
    ["MerchantUtils.HideCollectedMerchantItemsTooltip"] = "상점 창에서 이미 보유한 수집품 아이템을 숨깁니다.",
    ["MerchantUtils.HideCollectedPetsAtLimit"] = "수집된 애완동물 숨기기 (제한 도달 시)",
    ["MerchantUtils.HideCollectedPetsAtLimitTooltip"] = "애완동물이 수집 한도를 초과했을 때만 상점 창에서 숨깁니다.",

    -- Utils/QuestUtils.lua
    ["QuestUtils.SettingsCategoryPrefix"] = "자동 퀘스트",
    ["QuestUtils.SettingsCategoryTooltip"] = "자동 퀘스트 기능 설정",
    ["QuestUtils.AutoTurnIn"] = "자동 완료",
    ["QuestUtils.AutoTurnInTooltip"] = "NPC와 상호작용할 때 퀘스트를 자동으로 완료합니다.",
    ["QuestUtils.AutoAccept"] = "자동 수락",
    ["QuestUtils.AutoAcceptTooltip"] = "NPC와 상호작용할 때 퀘스트를 자동으로 수락합니다.",
    ["QuestUtils.IgnoreEternus"] = "이터누스 무시",
    ["QuestUtils.IgnoreEternusTooltip"] = "이터누스로부터 오는 퀘스트를 무시합니다.",
    ["QuestUtils.SuppressShift"] = "Shift로 비활성화",
    ["QuestUtils.SuppressShiftTooltip"] = "Shift를 누르고 있으면 자동 퀘스트 수락/완료를 비활성화합니다.",
    ["QuestUtils.SuppressWorldTierIcon"] = "세계 난이도 아이콘 숨기기",
    ["QuestUtils.SuppressWorldTierIconTooltip"] = "미니맵 아래에 세계 난이도 아이콘을 숨깁니다.",

    -- Utils/QuickActionBarUtils.lua
    ["QuickActionBarUtils.SettingsCategoryPrefix"] = "빠른 실행바",
    ["QuickActionBarUtils.SettingsCategoryTooltip"] = "빠른 실행바 기능 설정",
    ["QuickActionBarUtils.ActionNotFound"] = "동작을 찾을 수 없습니다",
    ["QuickActionBarUtils.Action"] = "동작 %s",

    -- Utils/ToastUtils.lua
    ["ToastUtils.SettingsCategoryPrefix"] = "알림",
    ["ToastUtils.SettingsCategoryTooltip"] = "알림 기능 설정",
    ["ToastUtils.TypeBronze"] = "청동 화폐",
    ["ToastUtils.TypeBronzeTooltip"] = "새로운 청동 화폐 달성 시 알림을 표시합니다.",
    ["ToastUtils.TypeArtifact"] = "유물 업그레이드",
    ["ToastUtils.TypeArtifactTooltip"] = "가방에서 유물 업그레이드를 발견했을 때 알림을 표시합니다.",
    ["ToastUtils.TypeUpgrade"] = "아이템 업그레이드",
    ["ToastUtils.TypeUpgradeTooltip"] = "가방에서 아이템 업그레이드를 발견했을 때 알림을 표시합니다.",
    ["ToastUtils.TypeTrait"] = "새로운 특성",
    ["ToastUtils.TypeTraitTooltip"] = "새로운 유물 특성을 해금했을 때 알림을 표시합니다.",
    ["ToastUtils.TypeSound"] = "소리 재생",
    ["ToastUtils.TypeSoundTooltip"] = "알림을 표시할 때 소리를 재생합니다.",
    ["ToastUtils.TypeGeneral"] = "알림 활성화",
    ["ToastUtils.TypeGeneralTooltip"] = "모든 알림을 활성화하거나 비활성화합니다.",
    ["ToastUtils.TestToast"] = "알림 테스트",
    ["ToastUtils.TestToastButtonTitle"] = "알림 테스트",
    ["ToastUtils.TestToastTooltip"] = "테스트 알림을 표시합니다.",
    ["ToastUtils.TestToastTitle"] = "알림 테스트",
    ["ToastUtils.TestToastDescription"] = "이것은 테스트 알림입니다.",
    ["ToastUtils.TypeBronzeTitle"] = "새로운 청동 화폐 달성!",
    ["ToastUtils.TypeBronzeDescription"] = "%d 청동 화폐를 달성했습니다! (한계까지 %.2f%%)",
    ["ToastUtils.TypeArtifactTitle"] = "새로운 유물 업그레이드!",
    ["ToastUtils.TypeArtifactDescription"] = "새로운 유물 업그레이드를 발견했습니다! 인벤토리나 빠른 실행바를 확인하세요.",
    ["ToastUtils.TypeUpgradeTitle"] = "새로운 아이템 업그레이드!",
    ["ToastUtils.TypeUpgradeFallback"] = "알 수 없는 아이템",
    ["ToastUtils.TypeTraitTitle"] = "새로운 특성 해금!",
    ["ToastUtils.TypeTraitDescription"] = "새로운 특성: %s",
    ["ToastUtils.TypeTraitFallback"] = "알 수 없는 특성",

    -- Utils/TooltipUtils.lua
    ["TooltipUtils.Threads"] = "파워",
    ["TooltipUtils.InfinitePower"] = "무한한 마력",
    ["TooltipUtils.Estimate"] = " (추정치)",
    ["TooltipUtils.SettingsCategoryPrefix"] = "마력 툴팁",
    ["TooltipUtils.SettingsCategoryTooltip"] = "마력 툴팁 기능 설정",
    ["TooltipUtils.Activate"] = "활성화",
    ["TooltipUtils.ActivateTooltip"] = "마력 정보 툴팁 표시",
    ["TooltipUtils.ThreadsInfo"] = "파워 정보",
    ["TooltipUtils.ThreadsInfoTooltip"] = "파워 정보 툴팁 표시",
    ["TooltipUtils.PowerInfo"] = "마력 정보",
    ["TooltipUtils.PowerInfoTooltip"] = "무한한 마력 정보 툴팁 표시",

    -- Utils/UpdateUtils.lua
    ["UpdateUtils.PatchNotesMessage"] = "버전이 %s에서 %s로 변경되었습니다. 패치 노트는 애드온 디스코드를 확인하세요!",
    ["UpdateUtils.NilVersion"] = "없음",

    -- Utils/UXUtils.lua
    ["UXUtils.SettingsCategoryPrefix"] = "일반 설정",
    ["UXUtils.SettingsCategoryTooltip"] = "애드온 일반 설정",
}
locales["koKR"] = L
