---@class AddonPrivate
local Private = select(2, ...)

local locales = Private.Locales or {}
Private.Locales = locales
local L = {
    -- UI/Components/Dropdown.lua
    ["Components.Dropdown.SelectOption"] = "選擇一個選項",

    -- UI/Tabs/ArtifactTraitsTabUI.lua
    ["Tabs.ArtifactTraitsTabUI.AutoActivateForSpec"] = "自動為專精啟用",
    ["Tabs.ArtifactTraitsTabUI.NoArtifactEquipped"] = "未裝備神兵武器",

    -- UI/Tabs/CollectionTabUI.lua
    ["Tabs.CollectionTabUI.CtrlClickPreview"] = "Ctrl+點擊預覽",
    ["Tabs.CollectionTabUI.ShiftClickToLink"] = "Shift+點擊連結",
    ["Tabs.CollectionTabUI.NoName"] = "無名稱",
    ["Tabs.CollectionTabUI.AltClickVendor"] = "Alt+點擊設定商人路徑點",
    ["Tabs.CollectionTabUI.AltClickAchievement"] = "Alt+點擊查看成就",
    ["Tabs.CollectionTabUI.FilterCollected"] = "已收集",
    ["Tabs.CollectionTabUI.FilterNotCollected"] = "未收集",
    ["Tabs.CollectionTabUI.FilterSources"] = "來源",
    ["Tabs.CollectionTabUI.FilterCheckAll"] = "全選",
    ["Tabs.CollectionTabUI.FilterUncheckAll"] = "全不選",
    ["Tabs.CollectionTabUI.FilterRaidVariants"] = "顯示團隊副本的配色",
    ["Tabs.CollectionTabUI.FilterUnique"] = "僅限混搭再造專屬物品",
    ["Tabs.CollectionTabUI.Type"] = "類型",
    ["Tabs.CollectionTabUI.Source"] = "來源",
    ["Tabs.CollectionTabUI.SearchInstructions"] = "搜尋",
    ["Tabs.CollectionTabUI.Progress"] = "%d / %d（%.2f%%）",
    ["Tabs.CollectionTabUI.ProgressTooltip"] = "你的收藏已累積 %s/%s 青銅。\n還需要再花費 %s 才能收集齊所有物品！",

    -- UI/CollectionsTabUI.lua
    ["CollectionsTabUI.TabTitle"] = "軍臨天下：混搭再造",
    ["CollectionsTabUI.ResearchProgress"] = "研究：%s/%s",
    ["CollectionsTabUI.TraitsTabTitle"] = "神兵武器特長",
    ["CollectionsTabUI.CollectionTabTitle"] = "收藏",

    -- UI/QuickActionBarUI.lua
    ["QuickActionBarUI.QuickBarTitle"] = "快捷列",
    ["QuickActionBarUI.SettingTitlePreview"] = "此處顯示動作標題",
    ["QuickActionBarUI.SettingsEditorTitle"] = "編輯動作",
    ["QuickActionBarUI.SettingsTitleLabel"] = "動作標題：",
    ["QuickActionBarUI.SettingsTitleInput"] = "動作名稱",
    ["QuickActionBarUI.SettingsIconLabel"] = "圖示：",
    ["QuickActionBarUI.SettingsIconInput"] = "圖示 ID 或路徑",
    ["QuickActionBarUI.SettingsIDLabel"] = "動作 ID：",
    ["QuickActionBarUI.SettingsIDInput"] = "物品/法術名稱或 ID",
    ["QuickActionBarUI.SettingsTypeLabel"] = "動作類型：",
    ["QuickActionBarUI.SettingsTypeInputSpell"] = "法術",
    ["QuickActionBarUI.SettingsTypeInputItem"] = "物品",
    ["QuickActionBarUI.SettingsCheckUsableLabel"] = "僅在可用時顯示：",
    ["QuickActionBarUI.SettingsEditorSave"] = "儲存動作",
    ["QuickActionBarUI.SettingsEditorNew"] = "新增動作",
    ["QuickActionBarUI.SettingsEditorDelete"] = "刪除動作",
    ["QuickActionBarUI.SettingsNoActionSaveError"] = "沒有可儲存的動作。",
    ["QuickActionBarUI.SettingsEditorAction"] = "動作 %s",
    ["QuickActionBarUI.SettingsGeneralActionSaveError"] = "儲存動作時發生錯誤：%s",
    ["QuickActionBarUI.CombatToggleError"] = "戰鬥中無法開啟或關閉快捷欄。",

    -- UI/ScrappingUI.lua
    ["ScrappingUI.MaxScrappingQuality"] = "最高拆解品質",
    ["ScrappingUI.MinItemLevelDifference"] = "最低物品等級差",
    ["ScrappingUI.MinItemLevelDifferenceInstructions"] = "比已裝備物品低 x 級",
    ["ScrappingUI.AutoScrap"] = "自動拆解",
    ["ScrappingUI.ScraperListTabTitle"] = "拆解列表",
    ["ScrappingUI.AdvancedSettingsTabTitle"] = "更多設定",
    ["ScrappingUI.JewelryTraitsToKeep"] = "需保留的飾品特長",
    ["ScrappingUI.AdvancedJewelryFilter"] = "進階飾品過濾",
    ["ScrappingUI.FilterCheckAll"] = "全選",
    ["ScrappingUI.FilterUncheckAll"] = "全不選",
    ["ScrappingUI.Neck"] = "項鍊特長",
    ["ScrappingUI.Trinket"] = "飾品特長",
    ["ScrappingUI.Finger"] = "戒指特長",
    ["ScrappingUI.IgnoreFromEquipmentSets"] = "忽略裝備套裝中的物品",

    -- Utils/ArtifactTraitUtils.lua
    ["ArtifactTraitUtils.NoItemEquipped"] = "未裝備物品。",
    ["ArtifactTraitUtils.UnknownTrait"] = "未知特長",
    ["ArtifactTraitUtils.ColumnNature"] = "自然",
    ["ArtifactTraitUtils.ColumnFel"] = "混沌",
    ["ArtifactTraitUtils.ColumnArcane"] = "秘法",
    ["ArtifactTraitUtils.ColumnStorm"] = "風暴",
    ["ArtifactTraitUtils.ColumnHoly"] = "神聖",
    ["ArtifactTraitUtils.JewelryFormat"] = "|T%s:16|t %s（+%d）",
    ["ArtifactTraitUtils.MaxTriesReached"] = "購買節點時達到最大嘗試次數。",
    ["ArtifactTraitUtils.SettingsCategoryPrefix"] = "神兵武器特長",
    ["ArtifactTraitUtils.SettingsCategoryTooltip"] = "神兵武器特長功能設定",
    ["ArtifactTraitUtils.AutoBuy"] = "自動學習節點",
    ["ArtifactTraitUtils.AutoBuyTooltip"] = "當你擁有足夠神兵武器能量時，自動學習預設的天賦。",

    -- Utils/CollectionUtils.lua
    ["CollectionUtils.Sources"] = "來源：",
    ["CollectionUtils.Achievement"] = "成就：",
    ["CollectionUtils.UnknownAchievement"] = "未知成就",
    ["CollectionUtils.UnknownVendor"] = "未知商人",
    ["CollectionUtils.Vendor"] = "商人，",

    -- Utils/CommandUtils.lua
    ["CommandUtils.UnknownCommand"] =
[[Unknown Command!
Usage: /LRH or /LegionRH <subCommand>
Subcommands:
    collections (c) - Open the Collections tab.
    settings (s) - Open the settings menu.
Example: /LRH s]],
    ["CommandUtils.CollectionsCommand"] = "collections",
    ["CommandUtils.CollectionsCommandShort"] = "c",
    ["CommandUtils.SettingsCommand"] = "settings",
    ["CommandUtils.SettingsCommandShort"] = "s",

    -- Utils/EditModeUtils.lua
    ["EditModeUtils.ShowAddonSystems"] = "軍團-混搭-助手-系統",
    ["EditModeUtils.SystemLabel.ToastUI"] = "提示",
    ["EditModeUtils.SystemTooltip.ToastUI"] = "移動提示的位置。",

    -- Utils/ItemOpenerUtils.lua
    ["ItemOpenerUtils.SettingsCategoryPrefix"] = "自動開啟物品",
    ["ItemOpenerUtils.SettingsCategoryTooltip"] = "自動開啟物品功能設定",
    ["ItemOpenerUtils.AutoItemOpen"] = "自動開啟物品",
    ["ItemOpenerUtils.AutoItemOpenTooltip"] = "在背包中找到特定物品時自動開啟。（此功能仍在開發中）",
    ["ItemOpenerUtils.AutoOpenItemEntryTooltip"] = "在背包中發現 %s 時自動開啟。",

    -- Utils/MerchantUtils.lua
    ["MerchantUtils.SettingsCategoryPrefix"] = "商人設定",
    ["MerchantUtils.SettingsCategoryTooltip"] = "商人功能的設定",
    ["MerchantUtils.HideCollectedMerchantItems"] = "隱藏已收藏的商人物品",
    ["MerchantUtils.HideCollectedMerchantItemsTooltip"] = "在商人視窗中隱藏你已收藏的物品。",
    ["MerchantUtils.HideCollectedPetsAtLimit"] = "達到上限時隱藏已收集的寵物",
    ["MerchantUtils.HideCollectedPetsAtLimitTooltip"] = "僅在達到寵物收集上限時隱藏商人視窗中的寵物。",

    -- Utils/QuestUtils.lua
    ["QuestUtils.SettingsCategoryPrefix"] = "自動任務",
    ["QuestUtils.SettingsCategoryTooltip"] = "自動任務功能設定",
    ["QuestUtils.AutoTurnIn"] = "自動交任務",
    ["QuestUtils.AutoTurnInTooltip"] = "與 NPC 互動時自動交任務。",
    ["QuestUtils.AutoAccept"] = "自動接任務",
    ["QuestUtils.AutoAcceptTooltip"] = "與 NPC 互動時自動接任務。",
    ["QuestUtils.IgnoreEternus"] = "忽略伊特努斯",
    ["QuestUtils.IgnoreEternusTooltip"] = "忽略來自伊特努斯的任務。",
    ["QuestUtils.SuppressShift"] = "按住 Shift 鍵暫時禁用",
    ["QuestUtils.SuppressShiftTooltip"] = "按住 Shift 鍵可暫時禁用自動接/交任務。",
    ["QuestUtils.SuppressWorldTierIcon"] = "隱藏世界等級圖標",
    ["QuestUtils.SuppressWorldTierIconTooltip"] = "隱藏位於小地圖下方的世界等級圖標。",

    -- Utils/QuickActionBarUtils.lua
    ["QuickActionBarUtils.SettingsCategoryPrefix"] = "快捷欄",
    ["QuickActionBarUtils.SettingsCategoryTooltip"] = "快捷欄功能設定",
    ["QuickActionBarUtils.ActionNotFound"] = "找不到動作",
    ["QuickActionBarUtils.Action"] = "動作 %s",

    -- Utils/ToastUtils.lua
    ["ToastUtils.SettingsCategoryPrefix"] = "提示通知",
    ["ToastUtils.SettingsCategoryTooltip"] = "提示通知功能設定",
    ["ToastUtils.TypeBronze"] = "青銅幣",
    ["ToastUtils.TypeBronzeTooltip"] = "達到新的青銅幣進度時顯示提示。",
    ["ToastUtils.TypeArtifact"] = "神兵武器升級",
    ["ToastUtils.TypeArtifactTooltip"] = "在背包中找到神兵武器升級時顯示提示。",
    ["ToastUtils.TypeUpgrade"] = "物品升級",
    ["ToastUtils.TypeUpgradeTooltip"] = "在背包中找到物品升級時顯示提示。",
    ["ToastUtils.TypeTrait"] = "新特長",
    ["ToastUtils.TypeTraitTooltip"] = "解鎖新的神兵武器特長時顯示提示。",
    ["ToastUtils.TypeSound"] = "播放音效",
    ["ToastUtils.TypeSoundTooltip"] = "顯示任何提示時播放音效。",
    ["ToastUtils.TypeGeneral"] = "啟用提示",
    ["ToastUtils.TypeGeneralTooltip"] = "啟用或停用所有提示通知。",
    ["ToastUtils.TestToast"] = "測試提示",
    ["ToastUtils.TestToastButtonTitle"] = "測試提示通知",
    ["ToastUtils.TestToastTooltip"] = "顯示測試提示通知。",
    ["ToastUtils.TestToastTitle"] = "測試提示通知",
    ["ToastUtils.TestToastDescription"] = "這是一則測試提示通知。",
    ["ToastUtils.TypeBronzeTitle"] = "新的青銅幣進度！",
    ["ToastUtils.TypeBronzeDescription"] = "你的青銅幣達到 %d！（距離上限還有 %.2f%%）",
    ["ToastUtils.TypeArtifactTitle"] = "新的神兵武器升級！",
    ["ToastUtils.TypeArtifactDescription"] = "你找到了一個新的神兵武器升級！請檢查你的背包或快捷欄。",
    ["ToastUtils.TypeUpgradeTitle"] = "新的物品升級！",
    ["ToastUtils.TypeUpgradeFallback"] = "未知物品",
    ["ToastUtils.TypeTraitTitle"] = "新特長已解鎖！",
    ["ToastUtils.TypeTraitDescription"] = "新特長：%s",
    ["ToastUtils.TypeTraitFallback"] = "未知特長",

    -- Utils/TooltipUtils.lua
    ["TooltipUtils.Threads"] = "絲線",
    ["TooltipUtils.InfinitePower"] = "恆龍之力",
    ["TooltipUtils.Estimate"] = " （預估）",
    ["TooltipUtils.SettingsCategoryPrefix"] = "滑鼠提示能量",
    ["TooltipUtils.SettingsCategoryTooltip"] = "滑鼠提示能量功能設定",
    ["TooltipUtils.Activate"] = "啟用",
    ["TooltipUtils.ActivateTooltip"] = "顯示滑鼠提示的能量資訊",
    ["TooltipUtils.ThreadsInfo"] = "絲線資訊",
    ["TooltipUtils.ThreadsInfoTooltip"] = "顯示滑鼠提示的絲線資訊",
    ["TooltipUtils.PowerInfo"] = "恆龍之力資訊",
    ["TooltipUtils.PowerInfoTooltip"] = "顯示滑鼠提示的恆龍之力資訊",

    -- Utils/UpdateUtils.lua
    ["UpdateUtils.PatchNotesMessage"] = "你的版本已從 %s 更新為 %s 版本。請前往插件 Discord 查看更新說明！",
    ["UpdateUtils.NilVersion"] = "N/A",

    -- Utils/UXUtils.lua
    ["UXUtils.SettingsCategoryPrefix"] = "通用設定",
    ["UXUtils.SettingsCategoryTooltip"] = "插件通用設定",
}
locales["zhTW"] = L
