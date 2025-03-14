local CraftScan = select(2, ...)

CraftScan.LOCAL_TW = {}

function CraftScan.LOCAL_TW:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                             = "製造掃描",
        [LID.CRAFT_SCAN]                          = "製造掃描",
        [LID.CHAT_ORDERS]                         = "聊天指令",
        [LID.DISABLE_ADDONS]                      = "停用插件",
        [LID.RENABLE_ADDONS]                      = "重新啟用插件",
        [LID.DISABLE_ADDONS_TOOLTIP]              =
        "保存插件清單，然後停用它們，讓您可以快速切換到其他角色。您隨時可以再次點擊此按鈕以重新啟用插件。",
        [LID.GREETING_I_CAN_CRAFT_ITEM]           = "我可以製造{item}。", -- 物品連結
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]         = "我的小號{crafter}可以製造{item}。", -- 製造者名稱，物品連結
        [LID.GREETING_LINK_BACKUP]                = "這",
        [LID.GREETING_I_HAVE_PROF]                = "我會{profession}。", -- 職業名稱
        [LID.GREETING_ALT_HAS_PROF]               = "我的小號{crafter}會{profession}。", -- 製造者名稱，職業名稱
        [LID.GREETING_ALT_SUFFIX]                 = "如果您下訂單，請通知我，我可以轉過去。",
        [LID.MAIN_BUTTON_BINDING_NAME]            = "切換訂單頁面",
        [LID.GREET_BUTTON_BINDING_NAME]           = "問候橫幅客戶",
        [LID.DISMISS_BUTTON_BINDING_NAME]         = "解散橫幅客戶",
        [LID.TOGGLE_CHAT_TOOLTIP]                 = "切換聊天訂單%s", -- 快捷鍵
        [LID.SCANNER_CONFIG_SHOW]                 = "顯示製造掃描",
        [LID.SCANNER_CONFIG_HIDE]                 = "隱藏製造掃描",
        [LID.CRAFT_SCAN_OPTIONS]                  = "製造掃描選項",
        [LID.ITEM_SCAN_CHECK]                     = "掃描聊天以查找此物品",
        [LID.HELP_PROFESSION_KEYWORDS]            =
        "消息必須包含其中一個詞語。例如，要匹配“LF Lariat”，“lariet”應列在此處。要對响應生成Elemental Lariat的物品連結，“lariat”也應包含在Elemental Lariat的物品配置關鍵詞中。",
        [LID.HELP_PROFESSION_EXCLUSIONS]          =
        "如果消息包含其中一個詞語，則將其忽略，即使它本來應該匹配。為了避免在您沒有Lariat配方的情況下對'LF JC Lariat'的回應為'我有珠寶加工'，應將'lariat'列在此處。",
        [LID.HELP_SCAN_ALL]                       = "啟用與所選配方相同擴展中的所有配方的掃描。",
        [LID.HELP_PRIMARY_EXPANSION]              =
        "當回應一個通用請求時使用此問候，例如'LF Blacksmith'。當新的擴展推出時，您可能希望使用描述您可以製造的物品的問候，而不是聲明您從前一擴展中獲得了最大知識。",
        [LID.HELP_EXPANSION_GREETING]             =
        "始終生成一個初始介紹，說明您可以製造物品。此文本將附加在其後。允許換行，並將作為單獨的回應發送。如果文本太長，它將分為多個回應發送。",
        [LID.HELP_CATEGORY_KEYWORDS]              =
        "如果已匹配職業，則檢查這些特定類別的關鍵詞以細化問候。例如，您可以在此處放置'toxic'或'slimy'，以嘗試檢測需要Alter of Decay的皮革工藝配方。",
        [LID.HELP_CATEGORY_GREETING]              =
        "當檢測到消息中的此類別時，無論是通過關鍵詞還是物品連結，都會在職業問候之後附加此額外的問候。",
        [LID.HELP_CATEGORY_OVERRIDE]              = "省略職業問候，直接開始類別問候。",
        [LID.HELP_ITEM_KEYWORDS]                  =
        "如果已匹配職業，則檢查這些特定物品的關鍵詞以細化問候。當匹配時，回應將包含物品連結，而不是通用的職業問候。如果'lariat'是職業關鍵詞但不是物品關鍵詞，則回應將說'我有珠寶加工。'如果'lariat'既是職業又是物品關鍵詞，則對'LF Lariat'的回應將是'我可以製造[Elemental Lariat]。'",
        [LID.HELP_ITEM_GREETING]                  =
        "當檢測到消息中的此物品時，無論是通過關鍵詞還是物品連結，都會在職業和類別問候之後附加此額外的問候。",
        [LID.HELP_ITEM_OVERRIDE]                  = "省略職業和類別問候，直接開始物品問候。",
        [LID.HELP_GLOBAL_KEYWORDS]                = "消息必須包含其中一個詞語。",
        [LID.HELP_GLOBAL_EXCLUSIONS]              = "如果消息包含其中一個詞語，則將其忽略。",
        [LID.SCAN_ALL_RECIPES]                    = '掃描所有配方',
        [LID.SCANNING_ENABLED]                    = "由於'%s'已勾選，掃描已啟用。", -- SCAN_ALL_RECIPES或ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]                   = "掃描已停用。",
        [LID.PRIMARY_KEYWORDS]                    = "主要關鍵詞",
        [LID.HELP_PRIMARY_KEYWORDS]               =
        "所有消息都通過這些詞語篩選，這些詞語是所有職業都常見的。匹配的消息進一步處理以查找與職業相關的內容。",
        [LID.HELP_CATEGORY_SECTION]               =
        "類別是包含列表左側的配方的可折疊部分。'Favorites'不是一個類別。這主要用於像製造難度較高的有毒皮革工藝配方。在擴展開始時，當您只能專精於單個類別時，這也可能很有用。",
        [LID.HELP_EXPANSION_SECTION]              = "知識樹隨擴展而異，因此問候也可能不同。",
        [LID.HELP_PROFESSION_SECTION]             =
        "從客戶的角度來看，各個擴展之間沒有區別。這些術語與“主要擴展”選項結合使用，以在無法匹配更具體的內容時提供通用問候（例如'我有<職業>。'）。",
        [LID.RECIPE_NOT_LEARNED]                  = "您尚未學習此配方。掃描已停用。",
        [LID.PING_SOUND_LABEL]                    = "警報聲",
        [LID.PING_SOUND_TOOLTIP]                  = "檢測到客戶時播放的聲音。",
        [LID.BANNER_SIDE_LABEL]                   = "橫幅方向",
        [LID.BANNER_SIDE_TOOLTIP]                 = "橫幅將從此按鈕向外擴展的方向。",
        Left                                      = "左",
        Right                                     = "右",
        Minute                                    = "分鐘",
        Minutes                                   = "分鐘",
        Second                                    = "秒",
        Seconds                                   = "秒",
        Millisecond                               = "毫秒",
        Milliseconds                              = "毫秒",
        Version                                   = "版本",
        ["CraftScan Release Notes"]               = "CraftScan 更新日誌",
        [LID.CUSTOMER_TIMEOUT_LABEL]              = "客戶超時",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]            = "在這麼多分鐘後自動解散客戶。",
        [LID.BANNER_TIMEOUT_LABEL]                = "橫幅超時",
        [LID.BANNER_TIMEOUT_TOOLTIP]              =
        "檢測到匹配後，客戶通知橫幅將在此時間後保持顯示。",
        ["All crafters"]                          = "所有製造者",
        ["Crafter Name"]                          = "製造者名稱",
        ["Profession"]                            = "職業",
        ["Customer Name"]                         = "客戶名稱",
        ["Replies"]                               = "回覆",
        ["Keywords"]                              = "關鍵詞",
        ["Profession greeting"]                   = "職業問候",
        ["Category greeting"]                     = "類別問候",
        ["Item greeting"]                         = "物品問候",
        ["Primary expansion"]                     = "主要擴展",
        ["Override greeting"]                     = "覆蓋問候",
        ["Excluded keywords"]                     = "排除的關鍵詞",
        [LID.EXCLUSION_INSTRUCTIONS]              = "不要匹配包含逗號分隔的這些令牌的消息。",
        [LID.KEYWORD_INSTRUCTIONS]                = "匹配包含逗號分隔的這些關鍵詞的消息。",
        [LID.GREETING_INSTRUCTIONS]               = "發送給尋找製造的客戶的問候。",
        [LID.GLOBAL_INCLUSION_DEFAULT]            = "LF，LFC，WTB，recraft",
        [LID.GLOBAL_EXCLUSION_DEFAULT]            = "LFW，WTS，LF work",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]      = "BS，Blacksmith，Armorsmith，Weaponsmith",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING]     = "LW，Leatherworking，Leatherworker",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]            = "Alc，Alchemist，Stone",
        [LID.DEFAULT_KEYWORDS_TAILORING]          = "Tailor",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]        = "Engineer，Eng",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]         = "Enchanter，Crest",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]      = "JC，Jewelcrafter",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]        = "Inscription，Inscriptionist，Scribe",

        -- Release notes
        [LID.RN_WELCOME]                          = "歡迎使用 CraftScan！",
        [LID.RN_WELCOME + 1]                      =
        "此插件會掃描聊天中看起來像製造請求的消息。如果配置指示您可以製造所需的物品，則會觸發通知並存儲客戶信息以便進行溝通。",

        [LID.RN_INITIAL_SETUP]                    = "初始設置",
        [LID.RN_INITIAL_SETUP + 1]                =
        "要開始，打開一個專業技能並點擊底部的新的“顯示製造掃描”按鈕。",
        [LID.RN_INITIAL_SETUP + 2]                =
        "滾動到此新窗口的底部，然後從底部開始逐步操作。您很少需要更改的事項位於底部，但這些是首先關心的設置。",
        [LID.RN_INITIAL_SETUP + 3]                =
        "如果您需要對任何輸入進行解釋，請點擊窗口左上角的幫助圖標。",

        [LID.RN_INITIAL_TESTING]                  = "初始測試",
        [LID.RN_INITIAL_TESTING + 1]              =
        "配置完成後，在/say聊天中輸入一條消息，例如“LF BS”表示製錶，假設您已經添加了“LF”和“BS”關鍵詞。應該會彈出一個通知。",
        [LID.RN_INITIAL_TESTING + 2]              =
        "點擊通知以立即發送回應，右鍵點擊以解散客戶，或者單擊圓形職業按鈕本身以打開訂單窗口。",
        [LID.RN_INITIAL_TESTING + 3]              =
        "除非已解散，否則重複通知會被壓制，因此如果要再試一次，請右鍵點擊您的測試通知以解散它。",

        [LID.RN_MANAGING_CRAFTERS]                = "管理您的製造者",
        [LID.RN_MANAGING_CRAFTERS + 1]            =
        "訂單窗口的左側列出了您的製造者。隨著您登錄各種角色並配置其職業，此列表將填充。您可以選擇任何時候激活哪些角色進行掃描，以及每個製造者的視覺和聽覺通知是否啟用。",

        [LID.RN_MANAGING_CUSTOMERS]               = "管理客戶",
        [LID.RN_MANAGING_CUSTOMERS + 1]           =
        "訂單窗口的右側將填充在聊天中檢測到的製造訂單。左鍵點擊一行以發送問候，如果您尚未從彈出橫幅中這樣做的話。再次左鍵點擊以向客戶打開密語。右鍵點擊以解散行。",
        [LID.RN_MANAGING_CUSTOMERS + 2]           =
        "此表中的行將跨所有角色保留，因此您可以切換到小號，然後再次單擊客戶以恢復通信。默認情況下，行將在10分鐘後超時。此持續時間可以在主要設置頁面中配置（按Esc -> 選項 -> 插件 -> CraftScan）。",
        [LID.RN_MANAGING_CUSTOMERS + 3]           =
        "希望表中大部分內容都是不言自明的。 '回覆'列有3個圖標。左邊的X或檢查標記表示您是否向客戶發送了消息。右邊的X或檢查標記表示客戶是否已回覆。聊天氣泡是一個按鈕，將打開一個臨時的密語窗口與客戶對話，並將其填充為您的聊天歷史記錄。",

        [LID.RN_KEYBINDS]                         = "快捷鍵",
        [LID.RN_KEYBINDS + 1]                     =
        "可用於打開訂單頁面、回覆最新客戶以及解散最新客戶的快捷鍵。搜索“CraftScan”以查找所有可用設置。",

        [LID.RN_CLEANUP]                          = "配置清理",
        [LID.RN_CLEANUP + 1]                      = "在'聊天訂單'頁面的左側，現在可以右鍵點擊您的工匠，會出現一個上下文選單。使用此選單保持列表整潔，並刪除過時的角色/職業。",
        ["Disable"]                               = "禁用",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]          =
        "永久刪除任何保存的 %s 的 %s 資料。\n\n在專業頁面上將有一個'啟用 CraftScan'按鈕，可以透過預設設置再次啟用它。\n\n如果您想繼續使用該專業但不想使用 CraftScan 互動（例如，當您在所有小號上都擁有煉金術用於長效藥劑時），請使用此功能。", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]               = "輸入 'DELETE' 以繼續:",
        [LID.SCANNER_CONFIG_DISABLED]             = "啟用 CraftScan",

        ["Cleanup"]                               = "清理",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]         =
        "永久刪除任何保存的 %s 的 %s 資料。\n\n該專業將處於未配置的狀態。再次打開專業會恢復預設配置。\n\n如果您想完全重置一個專業，已刪除角色，或已放棄一個專業，請使用此功能。", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]              = "輸入 'CLEANUP' 以繼續:",
        ["Primary Crafter"]                       = "主要工匠",
        [LID.PRIMARY_CRAFTER_TOOLTIP]             = "將 %s 標記為 %s 的主要工匠。如果有多個匹配的請求，該工匠將優先於其他工匠。",
        ["Chat History"]                          = "與 %s 的聊天記錄", -- customer, left-click-help
        ["Greet Help"]                            = "|cffffd100左鍵點擊: 問候顧客%s|r",
        ["Chat Help"]                             = "|cffffd100左鍵點擊: 打開悄悄話|r",
        ["Chat Override"]                         = "|cffffd100中鍵點擊: 打開悄悄話%s|r",
        ["Dismiss"]                               = "|cffffd100右鍵點擊: 關閉%s|r",
        ["Proposed Greeting"]                     = "建議的問候語:",
        [LID.CHAT_BUTTON_BINDING_NAME]            = "悄悄話橫幅顧客",
        ["Customer Request"]                      = "%s 的請求",
        [LID.ADDON_WHITELIST_LABEL]               = "插件白名單",
        [LID.ADDON_WHITELIST_TOOLTIP]             = "當你按下按鈕暫時禁用所有插件時，保持此處選擇的插件啟用。CraftScan將始終保持啟用。僅保留你有效製作所需的內容。",
        [LID.MULTI_SELECT_BUTTON_TEXT]            = "已選擇%d項", -- Count

        [LID.ACCOUNT_LINK_DESC]                   = "在多個帳戶之間共享製作人。\n\n在登錄或配置更改後，CraftScan會在配置的製作人之間傳播最新信息，以確保連結的帳戶雙方始終保持同步。",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]       = "輸入你其他帳戶中在線角色的名字：",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]        = "為另一個帳戶輸入一個暱稱：",
        ["Link Account"]                          = "連結帳戶",
        ["Linked Accounts"]                       = "已連結帳戶",
        ["Accept Linked Account"]                 = "接受已連結帳戶",
        ["Delete Linked Account"]                 = "刪除已連結帳戶",
        ["OK"]                                    = "確定",
        [LID.VERSION_MISMATCH]                    = "|cFFFF0000錯誤：CraftScan版本不相容。另一個帳戶的版本：%s。您的版本：%s。|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]              =
        "此角色屬於已連結的帳戶。它只能在其所屬的帳戶上被禁用。你可以通過“清理”完全移除此角色，但你需要在所有已連結的帳戶上手動執行此操作，否則它將在登錄時被已連結的帳戶恢復。",
        [LID.REMOTE_CRAFTER_SUMMARY]              = "與%s同步。",
        ["proxy_send_enabled"]                    = "代理訂單",
        ["proxy_send_enabled_tooltip"]            = "當檢測到客戶訂單時，將其發送到已連結的帳戶。",
        ["proxy_receive_enabled"]                 = "接收代理訂單",
        ["proxy_receive_enabled_tooltip"]         = "當另一個帳戶檢測到並發送客戶訂單時，此帳戶將接收它。如果需要，CraftScan按鈕將顯示警告橫幅。",
        [LID.LINK_ACTIVE]                         = "|cFF00FF00%s（上次看到%s）|r", -- Crafter, Time
        [LID.ACCOUNT_LINK_DELETE_INFO]            =
        "刪除與'%s'的連結並刪除所有導入的角色。此帳戶將停止與另一方的所有通信。另一方將繼續嘗試建立連接，直到在該處手動刪除連結為止。\n\n將被刪除的導入製作人：\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]               =
        "默認情況下，你最初連結的角色、任何製作人以及此帳戶在線時登錄的任何角色都為CraftScan所知。添加屬於另一個帳戶的其他角色，以便他們也可以使用。如果他們在線，請使用'/reload'強制與新角色同步。",
        ["Backup characters"]                     = "其他角色",
        ["Unlink account"]                        = "取消連結帳戶",
        ["Add"]                                   = "添加",
        ["Remove"]                                = "移除",
        ["Rename account"]                        = "重新命名帳戶",
        ["New name"]                              = "新名字：",

        [LID.RN_LINKED_ACCOUNTS]                  = "已連結帳戶",
        [LID.RN_LINKED_ACCOUNTS + 1]              = "將多個WoW帳戶連結在一起以共享製作信息並從任何帳戶掃描到任何帳戶。",
        [LID.RN_LINKED_ACCOUNTS + 2]              = "可選地，發送客戶訂單代理從一個帳戶到其他帳戶，這樣你可以讓測試帳戶在城市中保持不變，而你的主賬戶在外面。",
        [LID.RN_LINKED_ACCOUNTS + 3]              = "要開始，請點擊CraftScan窗口左下角的“連結帳戶”按鈕，並按照說明操作。",
        [LID.RN_LINKED_ACCOUNTS + 4]              = "演示：https://www.youtube.com/watch?v=x1JLEph6t_c",
        ["Open Settings"]                         = "打開設置",
        ["Customize Greeting"]                    = "自訂問候語",
        [LID.CUSTOM_GREETING_INFO]                = "CraftScan 使用這些句子根據情況向客戶發送初始問候語。覆蓋下方的部分或全部內容以創建自己的問候語。",
        ["Default"]                               = "默認",
        [LID.MISSING_PLACEHOLDERS]                = "還支援以下的佔位符：%s。",
        [LID.EXTRA_PLACEHOLDERS]                  = "錯誤：%s 不是有效的佔位符。",
        [LID.LEGACY_PLACEHOLDERS]                 = "警告：現在不建議使用 %s。請使用命名佔位符，如下圖所示：{placeholder}",

        ["Pixels"]                                = "像素",
        ["Show button height"]                    = "顯示按鈕高度",
        ["Alert icon scale"]                      = "警報圖示縮放",
        ["Total"]                                 = "總計",
        ["Repeat"]                                = "重複",
        ["Avg Per Day"]                           = "日均",
        ["Peak Per Hour"]                         = "峰值/小時",
        ["Median Per Customer"]                   = "中位數/客戶",
        ["Median Per Customer Filtered"]          = "中位數/客戶重複",
        ["No analytics data"]                     = "沒有分析數據",
        ["Reset Analytics"]                       = "重置分析數據",
        ["Analytics Options"]                     = "分析選項",

        ["1 minute"]                              = "1分鐘",
        ["15 minutes "]                           = "15分鐘",
        ["1 hour"]                                = "1小時",
        ["1 day"]                                 = "1天",
        ["1 week "]                               = "1週",
        ["30 days"]                               = "30天",
        ["180 days"]                              = "180天",
        ["1 year"]                                = "1年",
        ["Clear recent data"]                     = "清除近期數據",
        ["Newer than"]                            = "比...新",
        ["Clear old data"]                        = "清除舊數據",
        ["Older than"]                            = "比...舊",
        ["1 Minute Bins"]                         = "1分鐘時間段",
        ["5 Minute Bins"]                         = "5分鐘時間段",
        ["10 Minute Bins"]                        = "10分鐘時間段",
        ["30 Minute Bins"]                        = "30分鐘時間段",
        ["1 Hour Bins"]                           = "1小時時間段",
        ["6 Hour Bins"]                           = "6小時時間段",
        ["12 Hour Bins"]                          = "12小時時間段",
        ["24 Hour Bins"]                          = "24小時時間段",
        ["1 Week Bins"]                           = "1週時間段",

        [LID.ANALYTICS_ITEM_TOOLTIP]              =
        "物品通過確保消息匹配全球包含和排除關鍵詞來匹配，然後查找物品鏈接中的品質圖標。沒有全球手工製作物品列表或方法來確定物品ID是否為手工製作，因此這是我們能做到的最好方式。",
        [LID.ANALYTICS_PROFESSION_TOOLTIP]        =
        "沒有從物品到製作它的職業的反向查找。如果你的角色能製作該物品，職業會自動分配。當打開一個職業時，任何未知物品會被分配給該職業。你也可以手動分配職業。",
        [LID.ANALYTICS_TOTAL_TOOLTIP]             =
        "該物品被請求的總次數。相同客戶在同一小時內的重複請求不計入。",
        [LID.ANALYTICS_REPEAT_TOOLTIP]            =
        "相同客戶在同一小時內多次請求該物品的總次數。\n\n如果該值接近總數，則該物品的供應可能不足。\n\n在首次請求後15秒內的重複請求會被忽略。",
        [LID.ANALYTICS_AVERAGE_TOOLTIP]           = "該物品每天的平均請求數量。",
        [LID.ANALYTICS_PEAK_TOOLTIP]              = "該物品每小時的請求峰值數量。",
        [LID.ANALYTICS_MEDIAN_TOOLTIP]            =
        "同一客戶在同一小時內請求同一物品的中位數次數。\n\n值為1表示至少一半的請求由某人滿足，需求可能得到了滿足。\n\n如果該值很高，可能是值得追求的好物品。",
        [LID.ANALYTICS_MEDIAN_TOOLTIP_FILTERED]   =
        "同一客戶在同一小時內請求同一物品的中位數次數，僅限於請求多次的情況。\n\n如果該值不是1，但未過濾中位數為1，則表明有時需求沒有得到滿足。",
        ["Request Count"]                         = "請求次數",
        [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]        =
        "'%s'已發送請求以鏈接賬戶。\n\n請求的權限包括：\n\n%s\n\n除非你發送了請求，否則請勿接受完全權限。\n\n輸入另一個賬戶的暱稱：",
        [LID.LINKED_ACCOUNT_REJECTED]             = "CraftScan: 連接賬戶請求失敗。原因：%s",
        [LID.LINKED_ACCOUNT_USER_REJECTED]        = "目標賬戶拒絕了請求。",

        [LID.LINKED_ACCOUNT_PERMISSION_FULL]      = "完全控制",
        [LID.LINKED_ACCOUNT_PERMISSION_ANALYTICS] = "分析同步",
        [LID.ACCOUNT_LINK_PERMISSIONS_DESC]       = "請求與連接賬戶的以下權限。",
        [LID.ACCOUNT_LINK_FULL_CONTROL_DESC]      =
        "同步所有角色數據，並支持所有其他權限。",
        [LID.ACCOUNT_LINK_ANALYTICS_DESC]         =
        "僅通過賬戶菜單手動同步兩個賬戶之間的分析數據。任一賬戶隨時可以觸發雙向同步。絕不會自動完成。由於沒有角色被導入，你將僅與此處指定的角色同步。你可以從賬戶菜單手動添加更多關聯賬戶的角色。",
        ["Sync Analytics"]                        = "同步分析",
        ["Sync Recent Analytics"]                 = "同步近期分析",
        [LID.ANALYTICS_PROF_MISMATCH]             =
        "|cFFFF0000CraftScan: 警告: 分析同步職業不匹配。物品: %s。本地職業: %s。關聯職業: %s.|r",
        [LID.RN_ANALYTICS]                        = "分析",
        [LID.RN_ANALYTICS + 1]                    =
        "CraftScan現在掃描聊天中的任何手工製作物品，結合你的全球關鍵詞（例如，LF、recraft等...），即使你無法製作該物品。記錄時間並檢測到的物品會顯示在聊天中的通常訂單下方。",
        [LID.RN_ANALYTICS + 2]                    =
        "'重複'的概念用於判斷物品的供應是否不足。CraftScan會記住誰在過去一小時內請求了什麼，如果他們再次請求相同的物品，則記錄為重複。新網格的列標題有工具提示解釋其意圖。",
        [LID.RN_ANALYTICS + 3]                    =
        "通過在交易聊天中停留足夠長的時間，這應該能建立起哪些職業樹的分支值得投資的良好視圖。",
        [LID.RN_ANALYTICS + 4]                    =
        "分析可以在多個賬戶之間同步。你可以在交易中停留試用賬戶一天以收集數據，然後將其同步到你的主賬戶。你現在還可以與朋友創建僅分析的賬戶鏈接，支持雙向同步，將你的分析合併在一起。一旦收集數據變得龐大，便有選項僅同步上次同步後的數據。",
        [LID.RN_ALERT_ICON_ANCHOR]                = "警報圖示定位更新",
        [LID.RN_ALERT_ICON_ANCHOR + 1]            =
        "當UI隱藏時，警報圖示現在將正確隱藏。變更稍微移動並縮放了我的螢幕。如果因為這個原因而移動到螢幕外的按鈕，右鍵點擊聊天訂單頁面右上角的‘打開設置’按鈕有重置選項。",
        [LID.BUSY_RIGHT_NOW]                      = "忙碌模式",
        [LID.GREETING_BUSY]                       = "我現在很忙，但如果你發送過來，我可以稍後製作。",
        [LID.BUSY_HELP]                           =
        "|cFFFFFFFF當選中時，在你的回覆中附加忙碌問候。使用下面的按鈕編輯你的忙碌問候。\n\n這是為了與第二個賬戶代理訂單使用，以便你可以在主賬戶外出時接收訂單。\n\n當前忙碌問候: |cFF00FF00%s|r|r",
        ["Custom Explanations"]                   = "自定義解釋",
        ["Create"]                                = "創建",
        ["Modify"]                                = "修改",
        ["Delete"]                                = "刪除",
        [LID.EXPLANATION_LABEL_DESC]              =
        "輸入你在聊天中右鍵點擊客戶名稱時看到的標籤。",
        [LID.EXPLANATION_DUPLICATE_LABEL]         = "該標籤已在使用中。",
        [LID.EXPLANATION_TEXT_DESC]               = "輸入當點擊標籤時發送給客戶的消息。新行作為單獨消息發送。長行被拆分以適應最大消息長度。",
        ["Create an Explanation"]                 = "創建解釋",
        ["Save"]                                  = "保存",
        ["Reset"]                                 = "重置",
        [LID.MANUAL_MATCHING_TITLE]               = "手動匹配",
        [LID.MANUAL_MATCH]                        = "%s - %s", -- 制作者，職業
        [LID.MANUAL_MATCHING_DESC]                =
        "忽略主要關鍵詞並強制匹配此消息。CraftScan將根據消息嘗試找到正確的制作者，但如果找不到匹配，將使用指定制作者的默認問候。匹配將通過通常的方式報告，允許你點擊橫幅或表格行以發送問候。",

        [LID.RN_MANUAL_MATCH]                     = "手動匹配",
        [LID.RN_MANUAL_MATCH + 1]                 =
        "在聊天中右鍵點擊玩家名稱時的上下文菜單現在包括CraftScan選項。",
        [LID.RN_MANUAL_MATCH + 2]                 =
        "此菜單包括所有的製作者和職業。點擊其中一個將強制重新對消息進行匹配，而不考慮‘主要關鍵詞’（例如LF、WTB、recraft等...），以防客戶使用非標準術語。",
        [LID.RN_MANUAL_MATCH + 3]                 =
        "如果消息仍然不匹配，將強制使用你點擊的制作者和職業的默認問候進行匹配。",
        [LID.RN_MANUAL_MATCH + 4]                 =
        "此點擊不會自動向客戶發送消息。它以通常的方式生成匹配，然後你可以檢查生成的響應並選擇是否發送。",
        [LID.RN_MANUAL_MATCH + 5]                 = "(抱歉，沒有機器學習。)",
        [LID.RN_CUSTOM_EXPLANATIONS]              = "自定義解釋",
        [LID.RN_CUSTOM_EXPLANATIONS + 1]          =
        "‘聊天訂單’頁面現在包括一個‘自定義解釋’按鈕。這裡配置的解釋也會出現在聊天上下文菜單中，點擊它們將立即發送解釋。",
        [LID.RN_CUSTOM_EXPLANATIONS + 2]          =
        "解釋按字母順序排序，因此你可以對它們編號以強制所需順序。",
        [LID.RN_BUSY_MODE]                        = "忙碌模式",
        [LID.RN_BUSY_MODE + 1]                    =
        "這個功能已經在幾個版本中存在，但從未解釋過。在‘聊天訂單’頁面上有一個新的‘忙碌模式’復選框。勾選時，在回覆中附加忙碌問候。使用‘自定義問候’按鈕編輯你的忙碌問候。",
        [LID.RN_BUSY_MODE + 2]                    =
        "這是為了與第二個賬戶代理訂單使用，以便你在主賬戶外出時能接收訂單，客戶會知道你不能立即製作。",
        ["Release Notes"]                         = "發布說明",
        ["Secondary Keywords"]                    = "次要關鍵詞",
        [LID.SECONDARY_KEYWORD_INSTRUCTIONS]      = "例如：'pvp, 610, algari' 或 '606, 610, 636' 或 '590'，用來區分同一關鍵詞在多個物品上的差異。",
        [LID.HELP_ITEM_SECONDARY_KEYWORDS]        = "匹配主關鍵詞後，檢查次要關鍵詞以進一步精確匹配，允許區分同一裝備欄位的不同工藝。",
        [LID.RN_SECONDARY_KEYWORDS]               = "次要關鍵詞",
        [LID.RN_SECONDARY_KEYWORDS + 1]           = "物品現在支持次要關鍵詞來進一步精確匹配。每個裝備欄位通常有火花、PVP和藍色版本。可以設置次要關鍵詞來區分它們。",
        [LID.RN_SECONDARY_KEYWORDS + 2]           = "次要關鍵詞示例：",
        [LID.RN_SECONDARY_KEYWORDS + 3]           = "606, 619, 636",
        [LID.RN_SECONDARY_KEYWORDS + 4]           = "610, pvp, algari",
        [LID.RN_SECONDARY_KEYWORDS + 5]           = "590",
        ["Find Crafter"]                          = "尋找工匠",
        ["No Crafters Found"]                     = "未找到工匠",
        [LID.FOUND_CRAFTER_NAME_ENTRY]            = "%s [%s]",
        [LID.GREET_FOUND_CRAFTER]                 = "|cffffd100左鍵點擊：請求製作|r",
        ["Crafter Greeting"]                      = "|cFFFFFFFF工匠問候語|r",
        [LID.BUSY_ICON]                           = "|cFFFFFFFF工匠表示目前很忙，但稍後可以製作該物品。\n\n查看他們的問候語以獲取詳細信息。|r",
        ["Potential Crafters"]                    = "潛在工匠",
        [LID.FOUND_VIA_CRAFT_SCAN]                = "我通過CraftScan找到你，並看到了你的問候語。你現在能為我製作 %s 嗎？",
        [LID.COMMISSION_INSTRUCTIONS]             = "例如 '10000g', 預設值：'任意'\n此文本將顯示在客戶的'尋找工匠'表中。",
        ["Commission"]                            = "佣金",
        ["Crafter [Currently Playing]"]           = "工匠 [當前在線]",
        ["Profession commission"]                 = "職業佣金",
        [LID.DEFAULT_COMMISSION]                  = "任意",
        [LID.HELP_ITEM_COMMISSION]                = "CraftScan為客戶提供了個人訂單的'尋找工匠'按鈕。你的名字、問候語以及佣金將與其他工匠一起出現在表中。長度限制為12個字元，以便在客戶的表中整齊顯示。",
        ["Discoverable"]                          = "可被客戶發現",
        [LID.DISCOVERABLE_SETTING]                = "啟用時，當客戶點擊'尋找工匠'，如果你能製作該物品，你的名字將顯示在生成的表中。",
        [LID.RN_CUSTOMER_SEARCH]                  = "尋找工匠",
        [LID.RN_CUSTOMER_SEARCH + 1]              = "現在，發送個人訂單的頁面有了'尋找工匠'按鈕。這個按鈕會向所有CraftScan用戶發送請求，看看誰能製作物品，並將結果顯示在包含工匠佣金的表中。",
        [LID.RN_CUSTOMER_SEARCH + 2]              = "每個職業和物品現在都有一個'佣金'框，用於配置在表中顯示的內容，文本限制為12個字元。",
        [LID.RN_CUSTOMER_SEARCH + 3]              = "你已加入'CraftScan'頻道，但你不需要啟用它或查看該頻道中的訊息。它的存在是為了讓CraftScan能像玩家通常在貿易頻道那樣私下發送請求。",
        [LID.RN_CUSTOMER_SEARCH + 4]              = "作為工匠，你現在可能會收到客戶發送的意外密語，他們已經知道你能製作什麼。",
        [LID.RN_CUSTOMER_SEARCH + 5]              = "由於試玩帳號無法訪問製作表，這個功能有些難以測試。如果遇到任何問題，你可以禁用此功能，直到我能修復它。",
        [LID.RN_CUSTOMER_SEARCH + 6]              = "你可以通過暴雪主設置菜單中的新'可被客戶發現'設置選擇不被列入該表中。",
        [LID.RN_CUSTOMER_SEARCH + 7]              = "由於客戶可能開始使用此插件，分析功能現在可以完全禁用，預設情況下已禁用。如果你已經收集了數據，它將保持啟用狀態。",
        ["Permissive keyword matching"]           = "寬鬆的關鍵詞匹配",
        [LID.PERMISSIVE_MATCH_SETTING]            =
        "選中後，CraftScan 在檢查關鍵詞匹配時將不再關注空格和其他分隔符。預設情況下，CraftScan 僅在關鍵詞與周圍文本明顯分隔的情況下進行匹配，以避免錯誤匹配嵌入在其他詞中的短關鍵詞。對於不使用空格來分隔關鍵詞的語言，請啟用此選項。",
        ["Show chat orders tab"]                  = "顯示聊天訂單標籤",
        [LID.SHOW_CHAT_ORDER_TAB]                 = "在專業視窗顯示或隱藏「聊天訂單」標籤。若隱藏，可點擊顯示警報的 CraftScan 按鈕以打開聊天訂單頁面。",
        [LID.IGNORE]                              = "忽略",
        [LID.IGNORE_TOOLTIP]                      = "將此玩家加入 CraftScan 忽略列表。CraftScan 會忽略該玩家發送的所有訊息。此選單可用於將玩家從列表中移除。",
        [LID.UNIGNORE]                            = "移除忽略",
        [LID.UNIGNORE_TOOLTIP]                    = "此玩家在您的 CraftScan 忽略列表中。此選項將其從列表中移除。",
        ["Collapse chat context menu"]            = "折疊聊天上下文選單",
        [LID.COLLAPSE_CHAT_CONTEXT_TOOLTIP]       =
        "當右鍵點擊聊天中的玩家名字時，將所有上下文選單項目折疊成一個CraftScan子選單。",

        [LID.PROXY_ORDERS_TOOLTIP]                = "將此帳號偵測到的訂單發送到擁有「完全控制」權限的關聯帳號。接收的帳號將顯示正常通知，就如同它偵測到訂單一樣。",
        [LID.RECEIVE_PROXY_ORDERS_TOOLTIP]        = "接收由「完全控制」關聯帳號偵測並代理的訂單。當收到來自關聯帳號的訂單時，本帳號將顯示正常通知。",
        [LID.LOCAL_ALERTS_TOOLTIP]                =
        "只有在當前遊玩該角色時，才會顯示該工匠和專業的視覺和聽覺通知。這只是篩選器，不會啟用或禁用通知。通知仍可透過工匠列表右側的任務和耳機圖示進行管理。",
        ["Local Notifications Only"]              = "僅限本地通知",

    }
end
