local W = unpack((select(2, ...)))

W.Changelog[302] = {
    RELEASE_DATE = "2022/11/16",
    IMPORTANT = {
        ["zhCN"] = {
            "适配 ElvUI 13.02.",
            "最低支持的 ElvUI 版本变更为 13.02.",
            "提升了与 MerathilisUI 的兼容性.",
            "[移动框体] 为了修复可能的错误, 本次更新会重置框体位置记忆."
        },
        ["zhTW"] = {
            "適配 ElvUI 13.02.",
            "最低支持的 ElvUI 版本變更為 13.02.",
            "提升了與 MerathilisUI 的兼容性.",
            "[移動框架] 為了修復可能的錯誤, 本次更新會重置框架位置記憶."
        },
        ["enUS"] = {
            "Compatible with ElvUI 13.02.",
            "The minimum supported ElvUI version has been changed to 13.02.",
            "Improved compatibility with MerathilisUI.",
            "[Move Frames] To fix possible errors, this update will reset frame positions."
        },
        ["koKR"] = {
            "Compatible with ElvUI 13.02.",
            "The minimum supported ElvUI version has been changed to 13.02.",
            "Improved compatibility with MerathilisUI.",
            "[Move Frames] To fix possible errors, this update will reset frame positions."
        }
    },
    NEW = {
        ["zhCN"] = {
            "新增 6 个来自 ToxiUI 的状态条材质. 感谢 ToxiUI 团队.",
            "新增 5 个新风格职业图标. 感谢 Samima.",
            "新增一个团队定位图标包 PhilMod. 感谢 FlickMasher @ Reddit",
            "[鼠标提示] 添加了一个选项用于自定义显示额外信息的按键.",
            "[预组列表] 添加了显示队长的选项.",
            "[预组列表] 添加了额外文字 (队长分数, 队长最佳成绩) 的选项.",
            "[标签] 新增了各个风格职业图标的 oUF 标签.",
            "[鼠标提示]-[队伍信息] 新增了更换职业图标风格的选项.",
            "[鼠标提示] 新增了一个选项用于自定义观察信息的修饰键."
        },
        ["zhTW"] = {
            "新增 6 個來自 ToxiUI 的狀態條材質. 感謝 ToxiUI 團隊.",
            "新增 5 個新風格職業圖示. 感謝 Samima.",
            "新增一個團隊定位圖示包 PhilMod. 感謝 FlickMasher @ Reddit",
            "[浮動提示] 添加了一個選項用於自定義顯示額外信息的按鍵.",
            "[預組列表] 添加了顯示隊長的選項.",
            "[預組列表] 添加了額外文字 (隊長分數, 隊長最佳成績) 的選項.",
            "[標籤] 新增了各個風格職業圖示的 oUF 標籤.",
            "[浮動提示]-[隊伍信息] 新增了更換職業圖示風格的選項.",
            "[浮動提示] 新增了一個選項用於自定觀察信息的修飾鍵."
        },
        ["enUS"] = {
            "Add 6 new statusbar textures from ToxiUI. Thanks to the ToxiUI team.",
            "Add 5 new class icons. Thanks to Samima.",
            "Add a new role icon pack PhilMod. Thanks FlickMasher @ Reddit",
            "[Tooltips] Add an option to customize the key to show extra information.",
            "[LFG List] Add an option to show the leader.",
            "[LFG List] Add an option to show additional text (leader score, leader best score).",
            "[Tags] Add oUF tags for class icons.",
            "[Tooltips]-[Group Info] Add an option to change the class icon style.",
            "[Tooltips] Add an option to customize the modifier key to show inspect information."
        },
        ["koKR"] = {
            "Add 6 new statusbar textures from ToxiUI. Thanks to the ToxiUI team.",
            "Add 5 new class icons. Thanks to Samima.",
            "Add a new role icon pack PhilMod. Thanks FlickMasher @ Reddit",
            "[Tooltips] Add an option to customize the key to show extra information.",
            "[LFG List] Add an option to show the leader.",
            "[LFG List] Add an option to show additional text (leader score, leader best score).",
            "[Tags] Add oUF tags for class icons.",
            "[Tooltips]-[Group Info] Add an option to change the class icon style.",
            "[Tooltips] Add an option to customize the modifier key to show inspect information."
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "清理冗余的代码库.",
            "[已学配方上色] 修复了一个公会银行中可能出现的错误.",
            "[其他] 清理部分测试用代码.",
            "[小地图按钮] 修复了在不使用 ElvUI 小地图时大厅按键缩放错误的问题",
            "[小地图按钮] 修复了无法正确美化 Musician 导致模块崩溃的问题.",
            "[矩形小地图] 在 ElvUI 小地图未启用时不再载入.",
            "[预组队列表] Premade Groups Filter 载入时将自动禁用.",
            "[美化皮肤] 修复并优化了 Premade Groups Filter 皮肤."
        },
        ["zhTW"] = {
            "清理冗餘的代碼庫.",
            "[已學配方上色] 修復了一個公會銀行中可能出現的錯誤.",
            "[其他] 清理部分測試用代碼.",
            "[小地圖按鍵] 修復了在不使用 ElvUI 小地圖時大廳按鍵縮放錯誤的問題",
            "[小地圖按鍵] 修復了無法正確美化 Musician 導致模組崩潰的問題.",
            "[矩形小地圖] 在 ElvUI 小地圖未啟用時不再載入.",
            "[預組列表] Premade Groups Filter 載入時將自動禁用.",
            "[美化皮膚] 修復並優化了 Premade Groups Filter 皮膚.",
            "[美化皮膚] 各個組件美化選項中新增了圖片來解釋說明."
        },
        ["enUS"] = {
            "Clean up redundant libraries.",
            "[Already Known] Fix an error that may occur in the guild bank.",
            "[Misc] Clean up some debug codes.",
            "[Minimap Buttons] Fix the expansion landing page button scaling error when not using ElvUI minimap.",
            "[Minimap Buttons] Fix the module crash caused by not properly skinning Musician.",
            "[Square Minimap] No longer load when ElvUI minimap is not enabled.",
            "[LFG List] Premade Groups Filter will be disabled automatically when loaded.",
            "[Skins] Fix and optimized the Premade Groups Filter skin.",
            "[Skins] Add tip images to explain the options in each widget skin."
        },
        ["koKR"] = {
            "Clean up redundant libraries.",
            "[Already Known] Fix an error that may occur in the guild bank.",
            "[Misc] Clean up some debug codes.",
            "[Minimap Buttons] Fix the expansion landing page button scaling error when not using ElvUI minimap.",
            "[Minimap Buttons] Fix the module crash caused by not properly skinning Musician.",
            "[Square Minimap] No longer load when ElvUI minimap is not enabled.",
            "[LFG List] Premade Groups Filter will be disabled automatically when loaded.",
            "[Skins] Fix and optimized the Premade Groups Filter skin.",
            "[Skins] Add tip images to explain the options in each widget skin."
        }
    }
}
