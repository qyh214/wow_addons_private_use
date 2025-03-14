local CraftScan = select(2, ...)

CraftScan.LOCAL_CN = {}

function CraftScan.LOCAL_CN:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                             = "CraftScan",
        [LID.CRAFT_SCAN]                          = "CraftScan",
        [LID.CHAT_ORDERS]                         = "聊天订单",
        [LID.DISABLE_ADDONS]                      = "禁用插件",
        [LID.RENABLE_ADDONS]                      = "重新启用插件",
        [LID.DISABLE_ADDONS_TOOLTIP]              =
        "保存插件列表，然后禁用它们，以便快速切换到另一个角色。此按钮可再次点击以随时重新启用插件。",
        [LID.GREETING_I_CAN_CRAFT_ITEM]           = "我可以制作 {item}.", -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]         = "我的小号，{crafter}可以制作 {item}.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]                = "那个",
        [LID.GREETING_I_HAVE_PROF]                = "我有 {profession}.", -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]               = "我的小号，{crafter}，有 {profession}.", -- Crafter Name, Profession Name
        [LID.GREETING_ALT_SUFFIX]                 = "如果您发送订单，请告诉我，我可以切换过去。",
        [LID.MAIN_BUTTON_BINDING_NAME]            = "切换订单页面",
        [LID.GREET_BUTTON_BINDING_NAME]           = "打招呼横幅顾客",
        [LID.DISMISS_BUTTON_BINDING_NAME]         = "解雇横幅顾客",
        [LID.TOGGLE_CHAT_TOOLTIP]                 = "切换聊天订单%s", -- Keybind
        [LID.SCANNER_CONFIG_SHOW]                 = "显示CraftScan",
        [LID.SCANNER_CONFIG_HIDE]                 = "隐藏CraftScan",
        [LID.CRAFT_SCAN_OPTIONS]                  = "CraftScan 选项",
        [LID.ITEM_SCAN_CHECK]                     = "扫描聊天记录以查找此物品",
        [LID.HELP_PROFESSION_KEYWORDS]            =
        "消息必须包含其中一个词语。要匹配 'LF 缰绳' 这样的消息，'lariet' 应该在这里列出。为了在响应中生成元素缰绳的物品链接，'lariat' 也应该包含在元素缰绳的物品配置关键字中。",
        [LID.HELP_PROFESSION_EXCLUSIONS]          =
        "如果消息包含其中一个词语，即使它在其他方面是匹配的，也将被忽略。为了避免在您没有缰绳配方时响应 'LF JC Lariat' 为 '我有珠宝加工'，'lariat' 应该在这里列出。",
        [LID.HELP_SCAN_ALL]                       = "启用对同一扩展中所选配方的所有配方的扫描。",
        [LID.HELP_PRIMARY_EXPANSION]              =
        "在回应通用请求（例如 'LF Blacksmith'）时使用此问候语。当新的扩展推出时，您可能希望使用描述您可以制作的物品，而不是说明您拥有先前扩展的最大知识的问候语。",
        [LID.HELP_EXPANSION_GREETING]             =
        "始终生成一个初始介绍，说明您可以制作该物品。此文本将附加在其后。允许新的行，并将作为单独的响应发送。如果文本太长，将分为多个响应。",
        [LID.HELP_CATEGORY_KEYWORDS]              =
        "如果匹配了一个专业，检查这些类别特定的关键词以细化问候。例如，您可以在这里放置 '有毒' 或 '粘滑'，以尝试检测需要腐朽法阵的制革图案。",
        [LID.HELP_CATEGORY_GREETING]              =
        "当检测到此类别的消息时，无论是通过关键字还是项目链接，此附加问候将在职业问候之后附加。",
        [LID.HELP_CATEGORY_OVERRIDE]              = "省略职业问候，从类别问候开始。",
        [LID.HELP_ITEM_KEYWORDS]                  =
        "如果匹配了一个专业，检查这些项目特定的关键字以细化问候。当匹配时，响应将包含项目链接，而不是通用的职业问候。",
        [LID.HELP_ITEM_GREETING]                  =
        "当检测到此类别的消息时，无论是通过关键字还是项目链接，此附加问候将在职业和类别问候之后附加。",
        [LID.HELP_ITEM_OVERRIDE]                  = "省略职业和类别问候，从项目问候开始。",
        [LID.HELP_GLOBAL_KEYWORDS]                = "消息必须包含其中一个词语。",
        [LID.HELP_GLOBAL_EXCLUSIONS]              = "如果消息包含其中一个词语，消息将被忽略。",
        [LID.SCAN_ALL_RECIPES]                    = '扫描所有配方',
        [LID.SCANNING_ENABLED]                    = "由于已选中'%s'，因此启用了扫描。", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]                   = "扫描已禁用。",
        [LID.PRIMARY_KEYWORDS]                    = "主要关键词",
        [LID.HELP_PRIMARY_KEYWORDS]               =
        "所有消息都由这些词语筛选，这些词语是所有专业共同的。匹配的消息将进一步处理，以查找与专业相关的内容。",
        [LID.HELP_CATEGORY_SECTION]               =
        "该类别是左侧列表中包含配方的可折叠部分。'Favorites' 不是一个类别。这主要用于像更难制作的有毒制革配方这样的东西。当您只能专注于单个类别时，这也可能很有用。",
        [LID.HELP_EXPANSION_SECTION]              = "由于知识树因扩展而异，因此问候语也可能不同。",
        [LID.HELP_PROFESSION_SECTION]             =
        "从客户的角度来看，扩展之间没有区别。这些术语与“主要扩展”选择相结合，以在无法匹配更具体的内容时提供通用的问候语（例如 '我有 <专业>.'）。",
        [LID.RECIPE_NOT_LEARNED]                  = "您尚未学习此配方。扫描已禁用。",
        [LID.PING_SOUND_LABEL]                    = "警报音",
        [LID.PING_SOUND_TOOLTIP]                  = "检测到顾客后播放的声音。",
        [LID.BANNER_SIDE_LABEL]                   = "横幅方向",
        [LID.BANNER_SIDE_TOOLTIP]                 = "横幅将从此按钮向外扩展。",
        Left                                      = "左",
        Right                                     = "右",
        Minute                                    = "分钟",
        Minutes                                   = "分钟",
        Second                                    = "秒",
        Seconds                                   = "秒",
        Millisecond                               = "毫秒",
        Milliseconds                              = "毫秒",
        Version                                   = "新版本",
        ["CraftScan Release Notes"]               = "CraftScan 发布说明",
        [LID.CUSTOMER_TIMEOUT_LABEL]              = "顾客超时",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]            = "在此多少分钟后自动解雇顾客。",
        [LID.BANNER_TIMEOUT_LABEL]                = "横幅超时",
        [LID.BANNER_TIMEOUT_TOOLTIP]              =
        "顾客通知横幅将在匹配检测到后保持显示此时间段。",
        ["All crafters"]                          = "所有制作者",
        ["Crafter Name"]                          = "制作者名称",
        ["Profession"]                            = "专业",
        ["Customer Name"]                         = "顾客名称",
        ["Replies"]                               = "回复",
        ["Keywords"]                              = "关键词",
        ["Profession greeting"]                   = "专业问候",
        ["Category greeting"]                     = "类别问候",
        ["Item greeting"]                         = "物品问候",
        ["Primary expansion"]                     = "主要扩展",
        ["Override greeting"]                     = "覆盖问候",
        ["Excluded keywords"]                     = "排除的关键词",
        [LID.EXCLUSION_INSTRUCTIONS]              = "不要匹配包含这些逗号分隔的令牌的消息。",
        [LID.KEYWORD_INSTRUCTIONS]                = "匹配包含其中一个逗号分隔关键词的消息。",
        [LID.GREETING_INSTRUCTIONS]               = "发送给寻求制作的顾客的问候语。",
        [LID.GLOBAL_INCLUSION_DEFAULT]            = "LF, LFC, WTB, recraft",
        [LID.GLOBAL_EXCLUSION_DEFAULT]            = "LFW, WTS, LF work",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]      = "BS, Blacksmith, Armorsmith, Weaponsmith",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING]     = "LW, Leatherworking, Leatherworker",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]            = "Alc, Alchemist, Stone",
        [LID.DEFAULT_KEYWORDS_TAILORING]          = "Tailor",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]        = "Engineer, Eng",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]         = "Enchanter, Crest",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]      = "JC, Jewelcrafter",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]        = "Inscription, Inscriptionist, Scribe",
        -- Release notes
        [LID.RN_WELCOME]                          = "欢迎使用CraftScan！",
        [LID.RN_WELCOME + 1]                      =
        "此插件会扫描聊天消息中看起来像制作请求的内容。如果配置指示您可以制作所请求的物品，则会触发通知，并存储顾客信息以便于沟通。",

        [LID.RN_INITIAL_SETUP]                    = "初始设置",
        [LID.RN_INITIAL_SETUP + 1]                =
        "要开始，请打开专业并单击底部的新的“显示CraftScan”按钮。",
        [LID.RN_INITIAL_SETUP + 2]                =
        "向下滚动到此新窗口的底部，然后从底部开始操作。您需要很少更改的内容位于底部，但这些是首先关心的设置。",
        [LID.RN_INITIAL_SETUP + 3]                =
        "如果您需要解释任何输入，请单击窗口左上角的帮助图标。",

        [LID.RN_INITIAL_TESTING]                  = "初始测试",
        [LID.RN_INITIAL_TESTING + 1]              =
        "配置完成后，在/say聊天频道中键入消息，例如 'LF BS' 表示铁匠，假设您留下了 'LF' 和 'BS' 关键词。将会弹出通知。",
        [LID.RN_INITIAL_TESTING + 2]              =
        "单击通知以立即发送响应，右键单击以解雇顾客，或单击悬浮窗口本身的圆形专业按钮以打开订单窗口。",
        [LID.RN_INITIAL_TESTING + 3]              =
        "重复的通知会被抑制，除非它们已经被解雇，因此右键单击测试通知以解雇它，如果您想再试一次。",

        [LID.RN_MANAGING_CRAFTERS]                = "管理您的制作者",
        [LID.RN_MANAGING_CRAFTERS + 1]            =
        "订单窗口的左侧列出了您的制作者。当您登录各种角色并配置其专业时，此列表将被填充。您可以随时选择哪些角色应处于活动扫描状态，并且您每个制作者的视觉和听觉通知是否启用。",

        [LID.RN_MANAGING_CUSTOMERS]               = "管理顾客",
        [LID.RN_MANAGING_CUSTOMERS + 1]           =
        "订单窗口的右侧将填充在聊天中检测到的制作订单。单击行以发送问候（如果您尚未从弹出横幅中发送），左键再次以打开与顾客的悄悄话。右键单击以解雇行。",
        [LID.RN_MANAGING_CUSTOMERS + 2]           =
        "此表中的行将在所有角色之间保持持续，因此您可以切换到一个小号，然后再次单击顾客以恢复通信。默认情况下，此持续时间为10分钟。此持续时间可以在主设置页面中配置（Esc->选项->插件->CraftScan）。",
        [LID.RN_MANAGING_CUSTOMERS + 3]           =
        "希望大部分表都是不言自明的。'回复' 列有3个图标。左侧的 X 或√ 是您是否向客户发送了消息。右侧的 X 或√ 是客户是否已回复。聊天气泡是一个按钮，将打开一个临时的悄悄话窗口与客户，并将其填充为您的聊天历史记录。",

        [LID.RN_KEYBINDS]                         = "键位绑定",
        [LID.RN_KEYBINDS + 1]                     =
        "可以使用键位绑定来打开订单页面，回复最新顾客以及解雇最新顾客。搜索 'CraftScan' 以查找所有可用设置。",

        [LID.RN_CLEANUP]                          = "配置清理",
        [LID.RN_CLEANUP + 1]                      = "在'聊天订单'页面的左侧，现在可以右键单击您的工匠，会出现一个上下文菜单。使用此菜单保持列表整洁，并删除过时的角色/职业。",
        ["Disable"]                               = "禁用",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]          =
        "永久删除任何保存的 %s 的 %s 数据。\n\n在职业页面上将有一个'启用 CraftScan'按钮，可以通过默认设置再次启用它。\n\n如果您想继续使用该职业但不想使用 CraftScan 互动（例如，当您在所有小号上都拥有炼金术用于长效药剂时），请使用此功能。", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]               = "输入 'DELETE' 以继续:",
        [LID.SCANNER_CONFIG_DISABLED]             = "启用 CraftScan",

        ["Cleanup"]                               = "清理",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]         =
        "永久删除任何保存的 %s 的 %s 数据。\n\n该职业将处于未配置的状态。再次打开职业会恢复默认配置。\n\n如果您想完全重置一个职业，已删除角色，或已放弃一个职业，请使用此功能。", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]              = "输入 'CLEANUP' 以继续:",
        ["Primary Crafter"]                       = "主工匠",
        [LID.PRIMARY_CRAFTER_TOOLTIP]             = "将 %s 标记为 %s 的主工匠。如果有多个匹配的请求，该工匠将优先于其他工匠。",
        ["Chat History"]                          = "与 %s 的聊天记录", -- customer, left-click-help
        ["Greet Help"]                            = "|cffffd100左键点击: 问候客户%s|r",
        ["Chat Help"]                             = "|cffffd100左键点击: 打开密语|r",
        ["Chat Override"]                         = "|cffffd100中键点击: 打开密语%s|r",
        ["Dismiss"]                               = "|cffffd100右键点击: 关闭%s|r",
        ["Proposed Greeting"]                     = "建议的问候:",
        [LID.CHAT_BUTTON_BINDING_NAME]            = "密语横幅客户",
        ["Customer Request"]                      = "%s的请求",
        [LID.ADDON_WHITELIST_LABEL]               = "插件白名单",
        [LID.ADDON_WHITELIST_TOOLTIP]             = "当你按下按钮暂时禁用所有插件时，保持这里选择的插件启用状态。CraftScan将始终保持启用。只保留你有效制作所需的内容。",
        [LID.MULTI_SELECT_BUTTON_TEXT]            = "已选择%d项", -- Count

        [LID.ACCOUNT_LINK_DESC]                   = "在多个帐户之间共享制造者。\n\n在登录时或配置更改后，CraftScan会在配置的制造者之间传播最新信息，以确保链接的帐户的双方始终保持同步。",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]       = "输入你其他帐户中在线角色的名字：",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]        = "为另一个帐户输入一个昵称：",
        ["Link Account"]                          = "链接帐户",
        ["Linked Accounts"]                       = "已链接帐户",
        ["Accept Linked Account"]                 = "接受已链接帐户",
        ["Delete Linked Account"]                 = "删除已链接帐户",
        ["OK"]                                    = "确定",
        [LID.VERSION_MISMATCH]                    = "|cFFFF0000错误：CraftScan版本不兼容。另一个帐户的版本：%s。您的版本：%s。|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]              =
        "此角色属于已链接的帐户。它只能在其所属的帐户上被禁用。你可以通过“清理”完全移除此角色，但你需要在所有已链接的帐户上手动执行此操作，否则它将在登录时被已链接的帐户恢复。",
        [LID.REMOTE_CRAFTER_SUMMARY]              = "与%s同步。",
        ["proxy_send_enabled"]                    = "代理订单",
        ["proxy_send_enabled_tooltip"]            = "当检测到客户订单时，将其发送到已链接的帐户。",
        ["proxy_receive_enabled"]                 = "接收代理订单",
        ["proxy_receive_enabled_tooltip"]         = "当另一个帐户检测到并发送客户订单时，此帐户将接收它。如果需要，CraftScan按钮将显示警告横幅。",
        [LID.LINK_ACTIVE]                         = "|cFF00FF00%s（上次看到%s）|r", -- Crafter, Time
        [LID.ACCOUNT_LINK_DELETE_INFO]            =
        "删除与'%s'的链接并删除所有导入的角色。此帐户将停止与另一方的所有通信。另一方将继续尝试建立连接，直到在该处手动删除链接为止。\n\n将被删除的导入制造者：\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]               =
        "默认情况下，你最初链接的角色、任何制造者以及此帐户在线时登录的任何角色都为CraftScan所知。添加属于另一个帐户的其他角色，以便他们也可以使用。如果他们在线，请使用'/reload'强制与新角色同步。",
        ["Backup characters"]                     = "其他角色",
        ["Unlink account"]                        = "取消链接帐户",
        ["Add"]                                   = "添加",
        ["Remove"]                                = "移除",
        ["Rename account"]                        = "重命名帐户",
        ["New name"]                              = "新名字：",

        [LID.RN_LINKED_ACCOUNTS]                  = "已链接帐户",
        [LID.RN_LINKED_ACCOUNTS + 1]              = "将多个WoW帐户链接在一起以共享制造信息并从任何帐户扫描到任何帐户。",
        [LID.RN_LINKED_ACCOUNTS + 2]              = "可选地，发送客户订单代理从一个帐户到其他帐户，这样你可以让测试帐户在城市中保持不变，而你的主账户在外面。",
        [LID.RN_LINKED_ACCOUNTS + 3]              = "要开始，请点击CraftScan窗口左下角的“链接帐户”按钮，并按照说明操作。",
        [LID.RN_LINKED_ACCOUNTS + 4]              = "演示：https://www.youtube.com/watch?v=x1JLEph6t_c",
        ["Open Settings"]                         = "打开设置",
        ["Customize Greeting"]                    = "自定义问候语",
        [LID.CUSTOM_GREETING_INFO]                = "CraftScan 使用这些句子根据情况向客户发送初始问候语。覆盖下方的部分或全部内容以创建自己的问候语。",
        ["Default"]                               = "默认",
        [LID.MISSING_PLACEHOLDERS]                = "还支持以下占位符：%s。",
        [LID.EXTRA_PLACEHOLDERS]                  = "错误： %s 不是有效的占位符。",
        [LID.LEGACY_PLACEHOLDERS]                 = "警告：现在已弃用 %s。请使用命名占位符，例如：{placeholder}",

        ["Pixels"]                                = "像素",
        ["Show button height"]                    = "显示按钮高度",
        ["Alert icon scale"]                      = "警报图标缩放",
        ["Total"]                                 = "总计",
        ["Repeat"]                                = "重复",
        ["Avg Per Day"]                           = "日均",
        ["Peak Per Hour"]                         = "峰值/小时",
        ["Median Per Customer"]                   = "中位数/客户",
        ["Median Per Customer Filtered"]          = "中位数/客户重复",
        ["No analytics data"]                     = "没有分析数据",
        ["Reset Analytics"]                       = "重置分析数据",
        ["Analytics Options"]                     = "分析选项",

        ["1 minute"]                              = "1分钟",
        ["15 minutes "]                           = "15分钟",
        ["1 hour"]                                = "1小时",
        ["1 day"]                                 = "1天",
        ["1 week "]                               = "1周",
        ["30 days"]                               = "30天",
        ["180 days"]                              = "180天",
        ["1 year"]                                = "1年",
        ["Clear recent data"]                     = "清除近期数据",
        ["Newer than"]                            = "比...新",
        ["Clear old data"]                        = "清除旧数据",
        ["Older than"]                            = "比...旧",
        ["1 Minute Bins"]                         = "1分钟时间段",
        ["5 Minute Bins"]                         = "5分钟时间段",
        ["10 Minute Bins"]                        = "10分钟时间段",
        ["30 Minute Bins"]                        = "30分钟时间段",
        ["1 Hour Bins"]                           = "1小时时间段",
        ["6 Hour Bins"]                           = "6小时时间段",
        ["12 Hour Bins"]                          = "12小时时间段",
        ["24 Hour Bins"]                          = "24小时时间段",
        ["1 Week Bins"]                           = "1周时间段",

        [LID.ANALYTICS_ITEM_TOOLTIP]              =
        "物品通过确保消息匹配全球包含和排除关键词来匹配，然后查找物品链接中的品质图标。没有全球手工制作物品列表或方法来确定物品ID是否为手工制作，因此这是我们能做到的最好方式。",
        [LID.ANALYTICS_PROFESSION_TOOLTIP]        =
        "没有从物品到制作它的职业的反向查找。如果你的角色能制作该物品，职业会自动分配。当打开一个职业时，任何未知物品会被分配给该职业。你也可以手动分配职业。",
        [LID.ANALYTICS_TOTAL_TOOLTIP]             =
        "该物品被请求的总次数。相同客户在同一小时内的重复请求不计入。",
        [LID.ANALYTICS_REPEAT_TOOLTIP]            =
        "相同客户在同一小时内多次请求该物品的总次数。\n\n如果该值接近总数，则该物品的供应可能不足。\n\n在首次请求后15秒内的重复请求会被忽略。",
        [LID.ANALYTICS_AVERAGE_TOOLTIP]           = "该物品每天的平均请求数量。",
        [LID.ANALYTICS_PEAK_TOOLTIP]              = "该物品每小时的请求峰值数量。",
        [LID.ANALYTICS_MEDIAN_TOOLTIP]            =
        "同一客户在同一小时内请求同一物品的中位数次数。\n\n值为1表示至少一半的请求由某人满足，需求可能得到了满足。\n\n如果该值很高，可能是值得追求的好物品。",
        [LID.ANALYTICS_MEDIAN_TOOLTIP_FILTERED]   =
        "同一客户在同一小时内请求同一物品的中位数次数，仅限于请求多次的情况。\n\n如果该值不是1，但未过滤中位数为1，则表明有时需求没有得到满足。",
        ["Request Count"]                         = "请求次数",
        [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]        =
        "'%s'已发送请求以链接账户。\n\n请求的权限包括：\n\n%s\n\n除非你发送了请求，否则请勿接受完全权限。\n\n输入另一个账户的昵称：",
        [LID.LINKED_ACCOUNT_REJECTED]             = "CraftScan: 关联账户请求失败。原因：%s",
        [LID.LINKED_ACCOUNT_USER_REJECTED]        = "目标账户拒绝了请求。",

        [LID.LINKED_ACCOUNT_PERMISSION_FULL]      = "完全控制",
        [LID.LINKED_ACCOUNT_PERMISSION_ANALYTICS] = "分析同步",
        [LID.ACCOUNT_LINK_PERMISSIONS_DESC]       = "请求与关联账户的以下权限。",
        [LID.ACCOUNT_LINK_FULL_CONTROL_DESC]      =
        "同步所有角色数据，并支持所有其他权限。",
        [LID.ACCOUNT_LINK_ANALYTICS_DESC]         =
        "仅通过账户菜单手动同步两个账户之间的分析数据。任一账户随时可以触发双向同步。绝不会自动完成。由于没有角色被导入，你将仅与此处指定的角色同步。你可以从账户菜单手动添加更多关联账户的角色。",
        ["Sync Analytics"]                        = "同步分析",
        ["Sync Recent Analytics"]                 = "同步近期分析",
        [LID.ANALYTICS_PROF_MISMATCH]             =
        "|cFFFF0000CraftScan: 警告: 分析同步职业不匹配。物品: %s。本地职业: %s。关联职业: %s.|r",
        [LID.RN_ANALYTICS]                        = "分析",
        [LID.RN_ANALYTICS + 1]                    =
        "CraftScan现在扫描聊天中的任何手工制作物品，结合你的全球关键词（例如，LF、recraft等...），即使你无法制作该物品。记录时间并检测到的物品会显示在聊天中的通常订单下方。",
        [LID.RN_ANALYTICS + 2]                    =
        "'重复'的概念用于判断物品的供应是否不足。CraftScan会记住谁在过去一小时内请求了什么，如果他们再次请求相同的物品，则记录为重复。新网格的列标题有工具提示解释其意图。",
        [LID.RN_ANALYTICS + 3]                    =
        "通过在交易聊天中停留足够长的时间，这应该能建立起哪些职业树的分支值得投资的良好视图。",
        [LID.RN_ANALYTICS + 4]                    =
        "分析可以在多个账户之间同步。你可以在交易中停留试用账户一天以收集数据，然后将其同步到你的主账户。你现在还可以与朋友创建仅分析的账户链接，支持双向同步，将你的分析合并在一起。一旦收集数据变得庞大，便有选项仅同步上次账户同步以来的数据。",
        [LID.RN_ALERT_ICON_ANCHOR]                = "警报图标锚定更新",
        [LID.RN_ALERT_ICON_ANCHOR + 1]            =
        "当UI隐藏时，警报图标将正确隐藏。这个变化稍微移动并缩放了我的屏幕。如果按钮因为这个而移出了你的屏幕，右键点击聊天订单页面右上角的'打开设置'按钮会有重置选项。",
        [LID.BUSY_RIGHT_NOW]                      = "忙碌模式",
        [LID.GREETING_BUSY]                       = "我现在很忙，但如果你发过来，我可以稍后制作。",
        [LID.BUSY_HELP]                           =
        "|cFFFFFFFF勾选时，在回复中附加忙碌问候。使用下面的按钮编辑你的忙碌问候。\n\n这旨在用于第二个账户代理订单，以便你在主账户外出时能接收订单。\n\n当前忙碌问候: |cFF00FF00%s|r|r",
        ["Custom Explanations"]                   = "自定义说明",
        ["Create"]                                = "创建",
        ["Modify"]                                = "修改",
        ["Delete"]                                = "删除",
        [LID.EXPLANATION_LABEL_DESC]              =
        "输入一个标签，你将在聊天中右键点击客户名称时看到它。",
        [LID.EXPLANATION_DUPLICATE_LABEL]         = "该标签已在使用中。",
        [LID.EXPLANATION_TEXT_DESC]               = "输入当标签被点击时发送给客户的消息。新行作为单独消息发送。长行会被拆分以适应最大消息长度。",
        ["Create an Explanation"]                 = "创建说明",
        ["Save"]                                  = "保存",
        ["Reset"]                                 = "重置",
        [LID.MANUAL_MATCHING_TITLE]               = "手动匹配",
        [LID.MANUAL_MATCH]                        = "%s - %s", -- 制作者，职业
        [LID.MANUAL_MATCHING_DESC]                =
        "忽略主要关键词并强制匹配此消息。CraftScan将尝试根据消息找到正确的制作者，但如果没有找到匹配项，将使用指定制作者的默认问候。匹配通过通常的方式报告，允许你点击横幅或表格行以发送问候。",

        [LID.RN_MANUAL_MATCH]                     = "手动匹配",
        [LID.RN_MANUAL_MATCH + 1]                 =
        "在聊天中右键点击玩家名称时的上下文菜单现在包括CraftScan选项。",
        [LID.RN_MANUAL_MATCH + 2]                 =
        "此菜单包括你所有的制作者和职业。点击其中一个将强制再次匹配该消息，而不考虑“主要关键词”（例如LF、WTB、recraft等...），以防客户使用非标准术语。",
        [LID.RN_MANUAL_MATCH + 3]                 =
        "如果消息仍然不匹配，将强制使用你点击的制作者和职业的默认问候进行匹配。",
        [LID.RN_MANUAL_MATCH + 4]                 =
        "此点击不会自动发送消息给客户。它以通常方式生成匹配，然后你可以检查生成的回复并选择是否发送。",
        [LID.RN_MANUAL_MATCH + 5]                 = "(抱歉，没有机器学习。)",
        [LID.RN_CUSTOM_EXPLANATIONS]              = "自定义说明",
        [LID.RN_CUSTOM_EXPLANATIONS + 1]          =
        "‘聊天订单’页面现在包括一个‘自定义说明’按钮。此处配置的说明也会出现在聊天上下文菜单中，点击它们将立即发送说明。",
        [LID.RN_CUSTOM_EXPLANATIONS + 2]          =
        "说明按字母顺序排序，因此你可以对它们编号以强制所需顺序。",
        [LID.RN_BUSY_MODE]                        = "忙碌模式",
        [LID.RN_BUSY_MODE + 1]                    =
        "这个功能已经存在几次版本，但从未解释过。在‘聊天订单’页面上有一个新的‘忙碌模式’复选框。勾选时，在回复中附加忙碌问候。使用‘自定义问候’按钮编辑你的忙碌问候。",
        [LID.RN_BUSY_MODE + 2]                    =
        "这旨在用于第二个账户代理订单，以便你在主账户外出时能接收订单，客户会知道你不能立即制作。",
        ["Release Notes"]                         = "发布说明",
        ["Secondary Keywords"]                    = "次要关键词",
        [LID.SECONDARY_KEYWORD_INSTRUCTIONS]      = "例如：'pvp, 610, algari' 或 '606, 610, 636' 或 '590'，以区分同一关键词在多个物品上的差异。",
        [LID.HELP_ITEM_SECONDARY_KEYWORDS]        = "在匹配主关键词后，检查次要关键词以进一步精确匹配，允许区分同一装备槽的不同工艺。",
        [LID.RN_SECONDARY_KEYWORDS]               = "次要关键词",
        [LID.RN_SECONDARY_KEYWORDS + 1]           = "物品现在支持次要关键词以进一步精确匹配。每个装备槽通常有火花、PVP和蓝色版本。可以设置次要关键词来区分它们。",
        [LID.RN_SECONDARY_KEYWORDS + 2]           = "次要关键词示例：",
        [LID.RN_SECONDARY_KEYWORDS + 3]           = "606, 619, 636",
        [LID.RN_SECONDARY_KEYWORDS + 4]           = "610, pvp, algari",
        [LID.RN_SECONDARY_KEYWORDS + 5]           = "590",
        ["Find Crafter"]                          = "寻找工匠",
        ["No Crafters Found"]                     = "未找到工匠",
        [LID.FOUND_CRAFTER_NAME_ENTRY]            = "%s [%s]",
        [LID.GREET_FOUND_CRAFTER]                 = "|cffffd100左键点击：请求制作|r",
        ["Crafter Greeting"]                      = "|cFFFFFFFF工匠问候语|r",
        [LID.BUSY_ICON]                           = "|cFFFFFFFF工匠当前忙碌，但可以稍后制作该物品。\n\n查看他们的问候语以获取详细信息。|r",
        ["Potential Crafters"]                    = "潜在工匠",
        [LID.FOUND_VIA_CRAFT_SCAN]                = "我通过CraftScan找到你，并看到了你的问候语。你现在能为我制作 %s 吗？",
        [LID.COMMISSION_INSTRUCTIONS]             = "例如 '10000g', 默认值：'任意'\n此文本将显示在客户的'寻找工匠'表中。",
        ["Commission"]                            = "佣金",
        ["Crafter [Currently Playing]"]           = "工匠 [当前在线]",
        ["Profession commission"]                 = "职业佣金",
        [LID.DEFAULT_COMMISSION]                  = "任意",
        [LID.HELP_ITEM_COMMISSION]                = "CraftScan为客户提供了个人订单的'寻找工匠'按钮。你的名字、问候语以及佣金将和其他工匠一起出现在表中。长度限制为12个字符，以便在客户的表中整齐显示。",
        ["Discoverable"]                          = "可被客户发现",
        [LID.DISCOVERABLE_SETTING]                = "启用时，当客户点击'寻找工匠'，如果你能制作该物品，你的名字将显示在生成的表中。",
        [LID.RN_CUSTOMER_SEARCH]                  = "寻找工匠",
        [LID.RN_CUSTOMER_SEARCH + 1]              = "现在，发送个人订单的页面有了'寻找工匠'按钮。这个按钮会向所有CraftScan用户发送请求，看看谁能制作物品，并将结果显示在包含工匠佣金的表中。",
        [LID.RN_CUSTOMER_SEARCH + 2]              = "每个职业和物品现在都有一个'佣金'框，用于配置在表中显示的内容，文本限制为12个字符。",
        [LID.RN_CUSTOMER_SEARCH + 3]              = "你已加入'CraftScan'频道，但你不需要启用它或查看该频道中的消息。它的存在是为了让CraftScan能像玩家通常在贸易频道那样私下发送请求。",
        [LID.RN_CUSTOMER_SEARCH + 4]              = "作为工匠，你现在可能会收到客户发送的意外密语，他们已经知道你能制作什么。",
        [LID.RN_CUSTOMER_SEARCH + 5]              = "由于试玩账号无法访问制作表，这个功能有些难以测试。如果遇到任何问题，你可以禁用此功能，直到我能修复它。",
        [LID.RN_CUSTOMER_SEARCH + 6]              = "你可以通过暴雪主设置菜单中的新'可被客户发现'设置选择不被列入该表中。",
        [LID.RN_CUSTOMER_SEARCH + 7]              = "由于客户可能开始使用此插件，分析功能现在可以完全禁用，默认情况下已禁用。如果你已经收集了数据，它将保持启用状态。",
        ["Permissive keyword matching"]           = "宽松的关键词匹配",
        [LID.PERMISSIVE_MATCH_SETTING]            =
        "选中后，CraftScan 在检查关键词匹配时将不再关注空格和其他分隔符。默认情况下，CraftScan 仅在关键词与周围文本明显分隔的情况下进行匹配，以避免错误匹配嵌入在其他词中的短关键词。对于不使用空格来分隔关键词的语言，请启用此选项。",
        ["Show chat orders tab"]                  = "显示聊天订单标签",
        [LID.SHOW_CHAT_ORDER_TAB]                 = "在专业窗口显示或隐藏“聊天订单”标签。如果隐藏，可以点击CraftScan按钮（显示警报的地方）打开聊天订单页面。",
        [LID.IGNORE]                              = "忽略",
        [LID.IGNORE_TOOLTIP]                      = "将此玩家加入CraftScan忽略列表。CraftScan会忽略此玩家发送的所有消息。此菜单可用于从列表中移除此玩家。",
        [LID.UNIGNORE]                            = "移除忽略",
        [LID.UNIGNORE_TOOLTIP]                    = "此玩家在您的CraftScan忽略列表中。此选项将其从列表中移除。",
        ["Collapse chat context menu"]            = "折叠聊天上下文菜单",
        [LID.COLLAPSE_CHAT_CONTEXT_TOOLTIP]       =
        "右键点击聊天中的玩家姓名时，将所有上下文菜单项目折叠成一个CraftScan子菜单。",

        [LID.PROXY_ORDERS_TOOLTIP]                = "将此账号检测到的订单发送给具有‘完全控制’权限的关联账号。接收账号将显示正常通知，就像它自己检测到订单一样。",
        [LID.RECEIVE_PROXY_ORDERS_TOOLTIP]        = "接收由‘完全控制’关联账号检测并代理的订单。当从关联账号接收到订单时，本账号会显示正常的通知。",
        [LID.LOCAL_ALERTS_TOOLTIP]                =
        "只有在当前游玩该角色时，才会显示该工匠和专业的视觉和听觉通知。这只是一个筛选器，不会启用或禁用通知。通知仍可通过工匠列表右侧的任务和耳机图标进行管理。",
        ["Local Notifications Only"]              = "仅限本地通知",

    }
end
