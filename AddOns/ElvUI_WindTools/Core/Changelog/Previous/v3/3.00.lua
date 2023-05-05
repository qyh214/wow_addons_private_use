local W = unpack((select(2, ...)))

W.Changelog[300] = {
    RELEASE_DATE = "2022/11/12",
    IMPORTANT = {
        ["zhCN"] = {
            "坚决抵制插件出售行为! 更新授权以对插件分发进行限制, 今后请勿在任何非授权渠道分发本插件.",
            "授权渠道现在仅为 CurseForge, Wago, WoWInterface, 以及 178 魔兽插件站. 详见 LICENSE 文件.",
            "最低支持的 ElvUI 版本变更为 13.00.",
            "按钮修复现在可以自动进行."
        },
        ["zhTW"] = {
            "堅決抵制插件販賣行為! 更新授權以對插件分發進行限制, 今後請勿在任何非授權渠道分發本插件.",
            "授權渠道現在僅為 CurseForge, Wago, WoWInterface, 以及 178 魔獸插件站. 詳見 LICENSE 文件.",
            "最低支援的 ElvUI 版本變更為 13.00.",
            "按鈕修復現在可以自動進行."
        },
        ["enUS"] = {
            "NEVER SELL THIS ADDON! The license has been updated to restrict the distribution of the addon, please do not distribute this addon in any unauthorized channel in the future.",
            "The authorized channels are now only CurseForge, Wago, WoWInterface, and 178 WoW Addons. See LICENSE file for details.",
            "The minimum supported ElvUI version is now 13.00.",
            "The button fix now can be automatically executed."
        },
        ["koKR"] = {
            "NEVER SELL THIS ADDON! The license has been updated to restrict the distribution of the addon, please do not distribute this addon in any unauthorized channel in the future.",
            "The authorized channels are now only CurseForge, Wago, WoWInterface, and 178 WoW Addons. See LICENSE file for details.",
            "The minimum supported ElvUI version is now 13.00.",
            "The button fix now can be automatically executed."
        }
    },
    NEW = {
        ["zhCN"] = {
            "面向中文用户新增了 KOOK (原开黑啦) 支持社区的邀请链接.",
            "翻新了一下设定相关的图片素材.",
            "新增了 [高级] 设定分类, 用于调整插件核心设定和游戏修复功能设定.",
            "[额外物品条] 新增了 RUNE (符文) 和 RUNEDF (巨龙时代版本符文) 分类.",
            "[额外物品条] 新增了 FOODDF (巨龙时代版本制作食物) 分类. 物品列表需要之后进行更新.",
            "[额外物品条] 新增了 FLASKDF (巨龙时代版本药剂) 分类.",
            "[额外物品条] 新增了 POTIONDF (巨龙时代版本药水) 分类.",
            "[进度] 新增了对巨龙时代团队副本的追踪. 默认关闭.",
            "[进度] 新增了对巨龙时代第一赛季成就的追踪. 默认关闭.",
            "[进度] 新增了对巨龙时代第一赛季地下城的追踪. 默认关闭.",
        },
        ["zhTW"] = {
            "面向中文用户新增了 KOOK (原開黑啦) 使用支援社群的邀請連結.",
            "翻新了一下設定相關的圖片素材.",
            "新增了 [進階] 設定分類, 用於調整插件核心設定和遊戲修復功能設定.",
            "[額外物品條] 新增了 RUNE (符文) 和 RUNEDF (巨龍崛起版本符文) 分類.",
            "[額外物品條] 新增了 FOODDF (巨龍崛起版本製作食物) 分類. 物品列表需要之後進行更新.",
            "[額外物品條] 新增了 FLASKDF (巨龍崛起版本藥劑) 分類.",
            "[額外物品條] 新增了 POTIONDF (巨龍崛起版本藥水) 分類.",
            "[進度] 新增了對巨龍崛起團隊副本的追蹤. 預設關閉.",
            "[進度] 新增了對巨龍崛起第一賽季成就的追蹤. 預設關閉.",
            "[進度] 新增了對巨龍崛起第一賽季地下城的追蹤. 預設關閉.",
        },
        ["enUS"] = {
            "Add a new invite link for KOOK (formerly known as KaiHeiLa) support community for Chinese users.",
            "Redesigned some textures used in options.",
            "Add new [Advanced] option category for adjusting core settings and game fixes.",
            "[Extra Item Bar] Add new RUNE (Runes) and RUNEDF (Dragonflight Runes) categories.",
            "[Extra Item Bar] Add new FOODDF (Dragonflight Crafted Food) category. The item list will be updated later.",
            "[Extra Item Bar] Add new FLASKDF (Dragonflight Flasks) category.",
            "[Extra Item Bar] Add new POTIONDF (Dragonflight Potions) category.",
            "[Progression] Add tracking for Dragonflight new raid. Disabled by default.",
            "[Progression] Add tracking for Dragonflight Season 1 achievements. Disabled by default.",
            "[Progression] Add tracking for Dragonflight Season 1 dungeons. Disabled by default.",
        },
        ["koKR"] = {
            "Add a new invite link for KOOK (formerly known as KaiHeiLa) support community for Chinese users.",
            "Redesigned some textures used in options.",
            "Add new [Advanced] option category for adjusting core settings and game fixes.",
            "[Extra Item Bar] Add new RUNE (Runes) and RUNEDF (Dragonflight Runes) categories.",
            "[Extra Item Bar] Add new FOODDF (Dragonflight Crafted Food) category. The item list will be updated later.",
            "[Extra Item Bar] Add new FLASKDF (Dragonflight Flasks) category.",
            "[Extra Item Bar] Add new POTIONDF (Dragonflight Potions) category.",
            "[Progression] Add tracking for Dragonflight new raid. Disabled by default.",
            "[Progression] Add tracking for Dragonflight Season 1 achievements. Disabled by default.",
            "[Progression] Add tracking for Dragonflight Season 1 dungeons. Disabled by default.",
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "[额外物品条] 更新了全部物品分类列表.",
            "[额外物品条] FOODVENDOR 分类将只提供巨龙时代版本的商人售卖的食物.",
            "[额外物品条] 微调了一下设定提示, 使物品分组列表的版本信息更加清晰.",
            "[其他]-[自动截图] 修复了在第一次载入游戏时可能发生的截图失败.",
            "[其他]-[自动截图] 改善了截图的时机选择, 现在会在成就提醒完全载入后再进行截图.",
            "[快速拾取] 兼容 PTR 和 Beta 客户端.",
            "[矩形小地图] 修复了一个可能初始化多次的错误.",
            "[任务列表] 修复了标题菜单字体修改无法禁用的问题.",
            "[快速焦点] 修复可能导致的无法设置焦点的问题.",
            "[美化皮肤] 阴影美化不再与 MerathilisUI 冲突.",
            "[美化皮肤] 由于 Azeroth Auto Pilot 项目关闭, 永久移除 Azeroth Auto Pilot 皮肤.",
            "[联系人] 修复了一个可能导致移动框体错误的问题."
        },
        ["zhTW"] = {
            "[額外物品條] 更新了全部物品分類列表.",
            "[額外物品條] FOODVENDOR 分類將只提供巨龍崛起版本的商人售賣的食物.",
            "[額外物品條] 微調了一下設定提示, 使物品分組列表的版本資訊更加清晰.",
            "[其他]-[自動擷圖] 修復了在第一次載入遊戲時可能發生的擷圖失敗.",
            "[其他]-[自動擷圖] 改善了擷圖的時機選擇, 現在會在成就提醒完全載入後再進行擷圖.",
            "[快速拾取] 兼容 PTR 和 Beta 客戶端.",
            "[矩形小地圖] 修復了一個可能初始化多次的錯誤.",
            "[任務列表] 修復了標題選單字體修改無法禁用的問題.",
            "[快速焦點] 修復可能導致的無法設置焦點的問題.",
            "[美化皮膚] 陰影美化不再與 MerathilisUI 衝突.",
            "[美化皮膚] 由於 Azeroth Auto Pilot 專案關閉, 永久移除 Azeroth Auto Pilot 皮膚.",
            "[聯絡人] 修復了一個可能導致移動框體錯誤的問題."
        },
        ["enUS"] = {
            "[Extra Item Bar] Update all item categories.",
            "[Extra Item Bar] FOODVENDOR category will only provide food sold by vendors in Dragonflight.",
            "[Extra Item Bar] Adjusted some settings tips to make the expansion information of item categories more clear.",
            "[Other]-[Auto Screenshot] Fix the issue that the screenshot may fail when the game is loaded for the first time.",
            "[Other]-[Auto Screenshot] Improve the timing selection of taking screenshots, now it will take screenshots after the achievement alert is fully loaded.",
            "[Fast Loot] Compatible with PTR and Beta clients.",
            "[Rectangle Minimap] Fix a possible error that initializes multiple times.",
            "[Objective Tracker] Fixed the problem that the title menu text modification cannot be disabled.",
            "[Quick Focus] Fix the issue that may cause the focus to be unable to be set.",
            "[Skins] The shadow skin no longer conflicts with MerathilisUI.",
            "[Skins] Remove the Azeroth Auto Pilot skin permanently due to the Azeroth Auto Pilot project is closed.",
            "[Contacts] Fix a possible error that causes the move frames works not properly."
        },
        ["koKR"] = {
            "[Fast Loot] Compatible with PTR and Beta clients.",
            "[Rectangle Minimap] Fix a possible error that initializes multiple times.",
            "[Objective Tracker] Fixed the problem that the title menu text modification cannot be disabled.",
            "[Quick Focus] Fix the issue that may cause the focus to be unable to be set.",
            "[Skins] The shadow skin no longer conflicts with MerathilisUI.",
            "[Skins] Remove the Azeroth Auto Pilot skin permanently due to the Azeroth Auto Pilot project is closed.",
            "[Contacts] Fix a possible error that causes the move frames works not properly."
        }
    }
}
