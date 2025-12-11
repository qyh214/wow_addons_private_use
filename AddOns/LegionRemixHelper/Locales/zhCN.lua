---@class AddonPrivate
local Private = select(2, ...)

local locales = Private.Locales or {}
Private.Locales = locales
local L = {
    -- UI/Components/Dropdown.lua
    ["Components.Dropdown.SelectOption"] = "选择一个选项",

    -- UI/Tabs/ArtifactTraitsTabUI.lua
    ["Tabs.ArtifactTraitsTabUI.AutoActivateForSpec"] = "自动激活专精",
    ["Tabs.ArtifactTraitsTabUI.NoArtifactEquipped"] = "未装备神器",

    -- UI/Tabs/CollectionTabUI.lua
    ["Tabs.CollectionTabUI.CtrlClickPreview"] = "Ctrl+点击预览",
    ["Tabs.CollectionTabUI.ShiftClickToLink"] = "Shift+点击链接",
    ["Tabs.CollectionTabUI.NoName"] = "无名字",
    ["Tabs.CollectionTabUI.AltClickVendor"] = "Alt+点击设置商人路径点",
    ["Tabs.CollectionTabUI.AltClickAchievement"] = "Alt+点击查看成就",
    ["Tabs.CollectionTabUI.FilterCollected"] = "已收集",
    ["Tabs.CollectionTabUI.FilterNotCollected"] = "未收集",
    ["Tabs.CollectionTabUI.FilterSources"] = "来源",
    ["Tabs.CollectionTabUI.FilterCheckAll"] = "全选",
    ["Tabs.CollectionTabUI.FilterUncheckAll"] = "全不选",
    ["Tabs.CollectionTabUI.FilterRaidVariants"] = "显示团队副本的配色",
    ["Tabs.CollectionTabUI.FilterUnique"] = "仅限幻境新生的专属物品",
    ["Tabs.CollectionTabUI.Type"] = "类型",
    ["Tabs.CollectionTabUI.Source"] = "来源",
    ["Tabs.CollectionTabUI.SearchInstructions"] = "搜索",
    ["Tabs.CollectionTabUI.Progress"] = "%d / %d（%.2f%%）",
    ["Tabs.CollectionTabUI.ProgressTooltip"] = "你的收藏已消耗 %s/%s 青铜币。\n还需消耗 %s 可收集齐所有物品！",

    -- UI/CollectionsTabUI.lua
    ["CollectionsTabUI.TabTitle"] = "军团再临幻境新生",
    ["CollectionsTabUI.ResearchProgress"] = "研究：%s/%s",
    ["CollectionsTabUI.TraitsTabTitle"] = "神器专长",
    ["CollectionsTabUI.CollectionTabTitle"] = "收藏",

    -- UI/QuickActionBarUI.lua
    ["QuickActionBarUI.QuickBarTitle"] = "快捷栏",
    ["QuickActionBarUI.SettingTitlePreview"] = "此处显示动作栏标题",
    ["QuickActionBarUI.SettingsEditorTitle"] = "编辑动作栏",
    ["QuickActionBarUI.SettingsTitleLabel"] = "动作栏标题：",
    ["QuickActionBarUI.SettingsTitleInput"] = "动作栏名称",
    ["QuickActionBarUI.SettingsIconLabel"] = "图标：",
    ["QuickActionBarUI.SettingsIconInput"] = "图标ID或路径",
    ["QuickActionBarUI.SettingsIDLabel"] = "ID：",
    ["QuickActionBarUI.SettingsIDInput"] = "物品/法术名称或ID",
    ["QuickActionBarUI.SettingsTypeLabel"] = "类型：",
    ["QuickActionBarUI.SettingsTypeInputSpell"] = "法术",
    ["QuickActionBarUI.SettingsTypeInputItem"] = "物品",
    ["QuickActionBarUI.SettingsCheckUsableLabel"] = "仅在可用时显示：",
    ["QuickActionBarUI.SettingsEditorSave"] = "保存动作栏",
    ["QuickActionBarUI.SettingsEditorNew"] = "新建动作栏",
    ["QuickActionBarUI.SettingsEditorDelete"] = "删除动作栏",
    ["QuickActionBarUI.SettingsNoActionSaveError"] = "没有可保存的动作栏。",
    ["QuickActionBarUI.SettingsEditorAction"] = "动作栏 %s",
    ["QuickActionBarUI.SettingsGeneralActionSaveError"] = "保存动作栏时出错：%s",
    ["QuickActionBarUI.CombatToggleError"] = "快捷动作条无法在战斗中开启或关闭。",

    -- UI/ScrappingUI.lua
    ["ScrappingUI.MaxScrappingQuality"] = "最大拆解品质",
    ["ScrappingUI.MinItemLevelDifference"] = "低于物品等级",
    ["ScrappingUI.MinItemLevelDifferenceInstructions"] = "比最高的物品等级低x级",
    ["ScrappingUI.AutoScrap"] = "自动拆解",
    ["ScrappingUI.ScraperListTabTitle"] = "拆解列表",
    ["ScrappingUI.AdvancedSettingsTabTitle"] = "更多设置",
    ["ScrappingUI.JewelryTraitsToKeep"] = "需保留的物品及特质",
    ["ScrappingUI.AdvancedJewelryFilter"] = "高级物品及特质",
    ["ScrappingUI.FilterCheckAll"] = "全选",
    ["ScrappingUI.FilterUncheckAll"] = "全不选",
    ["ScrappingUI.Neck"] = "项链及特质",
    ["ScrappingUI.Trinket"] = "饰品及特质",
    ["ScrappingUI.Finger"] = "戒指及特质",
    ["ScrappingUI.IgnoreFromEquipmentSets"] = "忽略装备配置中的物品",

    -- Utils/ArtifactTraitUtils.lua
    ["ArtifactTraitUtils.NoItemEquipped"] = "未装备物品。",
    ["ArtifactTraitUtils.UnknownTrait"] = "未知专长",
    ["ArtifactTraitUtils.ColumnNature"] = "自然",
    ["ArtifactTraitUtils.ColumnFel"] = "混乱",
    ["ArtifactTraitUtils.ColumnArcane"] = "奥术",
    ["ArtifactTraitUtils.ColumnStorm"] = "风暴",
    ["ArtifactTraitUtils.ColumnHoly"] = "神圣",
    ["ArtifactTraitUtils.JewelryFormat"] = "|T%s:16|t %s （+%d）",
    ["ArtifactTraitUtils.MaxTriesReached"] = "购买节点时达到最大尝试次数。",
    ["ArtifactTraitUtils.SettingsCategoryPrefix"] = "神器特质",
    ["ArtifactTraitUtils.SettingsCategoryTooltip"] = "神器特质功能相关设置",
    ["ArtifactTraitUtils.AutoBuy"] = "自动学习节点",
    ["ArtifactTraitUtils.AutoBuyTooltip"] = "当拥有足够神器能量时，自动学习预设好的天赋。",

    -- Utils/CollectionUtils.lua
    ["CollectionUtils.Sources"] = "来源：",
    ["CollectionUtils.Achievement"] = "成就：",
    ["CollectionUtils.UnknownAchievement"] = "未知成就",
    ["CollectionUtils.UnknownVendor"] = "未知商人",
    ["CollectionUtils.Vendor"] = "商人, ",

    -- Utils/CommandUtils.lua
    ["CommandUtils.UnknownCommand"] =
[[未知命令！
用法：/LRH 和 /LegionRH <子命令>
子命令：
    collections (c) - 打开战团藏品。
    settings (s) - 打开设置界面。
例如：/LRH s]],
    ["CommandUtils.CollectionsCommand"] = "collections",
    ["CommandUtils.CollectionsCommandShort"] = "c",
    ["CommandUtils.SettingsCommand"] = "settings",
    ["CommandUtils.SettingsCommandShort"] = "s",

    -- Utils/EditModeUtils.lua
    ["EditModeUtils.ShowAddonSystems"] = "军团幻境-助手系统",
    ["EditModeUtils.SystemLabel.ToastUI"] = "提示信息",
    ["EditModeUtils.SystemTooltip.ToastUI"] = "移动提示信息位置。",

    -- Utils/ItemOpenerUtils.lua
    ["ItemOpenerUtils.SettingsCategoryPrefix"] = "自动开启物品",
    ["ItemOpenerUtils.SettingsCategoryTooltip"] = "自动开启物品设置选项",
    ["ItemOpenerUtils.AutoItemOpen"] = "自动开启物品",
    ["ItemOpenerUtils.AutoItemOpenTooltip"] = "获得特定物品时自动开启背包中的物品。（此功能仍在开发中）",
    ["ItemOpenerUtils.AutoOpenItemEntryTooltip"] = "在背包中发现%s时自动开启。",

    -- Utils/MerchantUtils.lua
    ["MerchantUtils.SettingsCategoryPrefix"] = "商人设置",
    ["MerchantUtils.SettingsCategoryTooltip"] = "商人功能的设置",
    ["MerchantUtils.HideCollectedMerchantItems"] = "隐藏已收藏的物品",
    ["MerchantUtils.HideCollectedMerchantItemsTooltip"] = "在商人窗口中隐藏你已收藏的物品。",
    ["MerchantUtils.HideCollectedPetsAtLimit"] = "隐藏已收藏的宠物（满上限）",
    ["MerchantUtils.HideCollectedPetsAtLimitTooltip"] = "仅在达到宠物收集上限时隐藏商人窗口中的宠物。",

    -- Utils/QuestUtils.lua
    ["QuestUtils.SettingsCategoryPrefix"] = "自动任务",
    ["QuestUtils.SettingsCategoryTooltip"] = "自动任务功能设置",
    ["QuestUtils.AutoTurnIn"] = "自动交任务",
    ["QuestUtils.AutoTurnInTooltip"] = "与NPC交互时自动交任务。",
    ["QuestUtils.AutoAccept"] = "自动接任务",
    ["QuestUtils.AutoAcceptTooltip"] = "与NPC交互时自动接任务。",
    ["QuestUtils.IgnoreEternus"] = "忽略伊特努丝",
    ["QuestUtils.IgnoreEternusTooltip"] = "忽略来自伊特努丝的任务。",
    ["QuestUtils.SuppressShift"] = "按住Shift键临时禁用",
    ["QuestUtils.SuppressShiftTooltip"] = "按住Shift键可临时禁用自动交/接任务功能。",
    ["QuestUtils.SuppressWorldTierIcon"] = "隐藏世界难度图标",
    ["QuestUtils.SuppressWorldTierIconTooltip"] = "隐藏小地图下方的世界难度图标。",

    -- Utils/QuickActionBarUtils.lua
    ["QuickActionBarUtils.SettingsCategoryPrefix"] = "快捷动作栏",
    ["QuickActionBarUtils.SettingsCategoryTooltip"] = "快捷栏功能设置",
    ["QuickActionBarUtils.ActionNotFound"] = "未找到动作栏",
    ["QuickActionBarUtils.Action"] = "动作栏 %s",

    -- Utils/ToastUtils.lua
    ["ToastUtils.SettingsCategoryPrefix"] = "提示通知",
    ["ToastUtils.SettingsCategoryTooltip"] = "提示通知功能设置",
    ["ToastUtils.TypeBronze"] = "青铜币",
    ["ToastUtils.TypeBronzeTooltip"] = "达到新的青铜币进度时显示提示。",
    ["ToastUtils.TypeArtifact"] = "神器升级",
    ["ToastUtils.TypeArtifactTooltip"] = "在背包中找到神器升级时显示提示。",
    ["ToastUtils.TypeUpgrade"] = "物品升级",
    ["ToastUtils.TypeUpgradeTooltip"] = "在背包中找到物品升级时显示提示。",
    ["ToastUtils.TypeTrait"] = "新专长",
    ["ToastUtils.TypeTraitTooltip"] = "解锁新神器专长时显示提示。",
    ["ToastUtils.TypeSound"] = "播放音效",
    ["ToastUtils.TypeSoundTooltip"] = "显示任何提示时播放音效。",
    ["ToastUtils.TypeGeneral"] = "启用提示",
    ["ToastUtils.TypeGeneralTooltip"] = "启用或禁用所有提示通知。",
    ["ToastUtils.TestToast"] = "测试提示",
    ["ToastUtils.TestToastButtonTitle"] = "测试提示通知",
    ["ToastUtils.TestToastTooltip"] = "显示测试提示通知。",
    ["ToastUtils.TestToastTitle"] = "测试提示通知",
    ["ToastUtils.TestToastDescription"] = "这是一个测试提示通知。",
    ["ToastUtils.TypeBronzeTitle"] = "新的青铜币进度！",
    ["ToastUtils.TypeBronzeDescription"] = "你的青铜币达到 %d！（%.2f%% 达到上限）",
    ["ToastUtils.TypeArtifactTitle"] = "新的神器升级！",
    ["ToastUtils.TypeArtifactDescription"] = "你找到了一个新的神器升级！请检查你的背包或快捷动作栏。",
    ["ToastUtils.TypeUpgradeTitle"] = "新的物品升级！",
    ["ToastUtils.TypeUpgradeFallback"] = "未知物品",
    ["ToastUtils.TypeTraitTitle"] = "新专长已解锁！",
    ["ToastUtils.TypeTraitDescription"] = "新专长：%s",
    ["ToastUtils.TypeTraitFallback"] = "未知专长",

    -- Utils/TooltipUtils.lua
    ["TooltipUtils.Threads"] = "线索",
    ["TooltipUtils.InfinitePower"] = "永恒能量",
    ["TooltipUtils.Estimate"] = " (预估)",
    ["TooltipUtils.SettingsCategoryPrefix"] = "鼠标提示信息",
    ["TooltipUtils.SettingsCategoryTooltip"] = "在鼠标提示上显示信息的功能设置",
    ["TooltipUtils.Activate"] = "启用",
    ["TooltipUtils.ActivateTooltip"] = "在鼠标提示上显示启用详细信息",
    ["TooltipUtils.ThreadsInfo"] = "线索信息",
    ["TooltipUtils.ThreadsInfoTooltip"] = "在鼠标提示上显示线索信息",
    ["TooltipUtils.PowerInfo"] = "永恒能量信息",
    ["TooltipUtils.PowerInfoTooltip"] = "在鼠标提示上显示永恒能量信息",

    -- Utils/UpdateUtils.lua
    ["UpdateUtils.PatchNotesMessage"] = "你的版本已从 %s 变更为版本 %s。请查看插件或者到Discord获取更新说明！",
    ["UpdateUtils.NilVersion"] = "N/A",

    -- Utils/UXUtils.lua
    ["UXUtils.SettingsCategoryPrefix"] = "通用设置",
    ["UXUtils.SettingsCategoryTooltip"] = "插件通用设置",
}
locales["zhCN"] = L
