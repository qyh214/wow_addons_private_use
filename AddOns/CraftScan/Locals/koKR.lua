local CraftScan = select(2, ...)

CraftScan.LOCAL_KO = {}

function CraftScan.LOCAL_KO:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                             = "CraftScan",
        [LID.CRAFT_SCAN]                          = "CraftScan",
        [LID.CHAT_ORDERS]                         = "채팅 주문",
        [LID.DISABLE_ADDONS]                      = "애드온 비활성화",
        [LID.RENABLE_ADDONS]                      = "애드온 다시 활성화",
        [LID.DISABLE_ADDONS_TOOLTIP]              =
        "애드온 목록을 저장한 후, 애드온을 비활성화하여 빠르게 다른 캐릭터로 전환할 수 있습니다. 이 버튼을 다시 클릭하여 언제든지 애드온을 다시 활성화할 수 있습니다.",
        [LID.GREETING_I_CAN_CRAFT_ITEM]           = "{item} 제작 가능합니다.", -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]         = "내 대체 캐릭터, {crafter}가 {item}를 제작할 수 있습니다.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]                = "이것",
        [LID.GREETING_I_HAVE_PROF]                = "{profession}을 가지고 있습니다.", -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]               = "내 대체 캐릭터, {crafter}가 {profession}을 가지고 있습니다.", -- Crafter Name, Profession Name
        [LID.GREETING_ALT_SUFFIX]                 = "주문을 보내면 전환해서 확인할 수 있도록 알려주세요.",
        [LID.MAIN_BUTTON_BINDING_NAME]            = "주문 페이지 전환",
        [LID.GREET_BUTTON_BINDING_NAME]           = "인사 배너 고객",
        [LID.DISMISS_BUTTON_BINDING_NAME]         = "배너 고객 닫기",
        [LID.TOGGLE_CHAT_TOOLTIP]                 = "채팅 주문 전환%s", -- Keybind
        [LID.SCANNER_CONFIG_SHOW]                 = "CraftScan 표시",
        [LID.SCANNER_CONFIG_HIDE]                 = "CraftScan 숨기기",
        [LID.CRAFT_SCAN_OPTIONS]                  = "CraftScan 옵션",
        [LID.ITEM_SCAN_CHECK]                     = "이 아이템에 대한 채팅 검색",
        [LID.HELP_PROFESSION_KEYWORDS]            =
        "이 용어 중 하나를 포함해야 합니다. 'LF Lariat'과 같은 메시지를 일치시키려면 여기에 'lariet'를 추가해야 합니다. 응답에 Elemental Lariat에 대한 아이템 링크를 생성하려면 Elemental Lariat에 대한 항목 구성 키워드에 'lariat'를 포함해야 합니다.",
        [LID.HELP_PROFESSION_EXCLUSIONS]          =
        "이 용어 중 하나를 포함하면 메시지가 일치하더라도 무시됩니다. 예를 들어 'LF JC Lariat'에 'lariat'가 포함되어 있지만 Lariat 레시피를 가지고 있지 않을 때 'I have Jewelcrafting'에 'I have Jewelcrafting'을 응답하지 않으려면 여기에 'lariat'를 추가해야 합니다.",
        [LID.HELP_SCAN_ALL]                       = "선택한 레시피와 동일한 확장팩에 모든 레시피를 검색하도록 설정합니다.",
        [LID.HELP_PRIMARY_EXPANSION]              =
        "이것은 'LF Blacksmith'와 같은 일반 요청에 대한 인사에 사용됩니다. 새로운 확장팩이 출시되면 해당 확장팩에서 제작할 수 있는 항목을 나열하는 대신 이전 확장팩에서 최대 지식을 가졌다는 것을 명시하는 것이 좋습니다.",
        [LID.HELP_EXPANSION_GREETING]             =
        "초기 인사는 항상 해당 아이템을 제작할 수 있다는 내용이 포함됩니다. 이 텍스트가 추가됩니다. 여러 줄을 사용할 수 있으며 이는 별도의 응답으로 전송됩니다. 텍스트가 너무 길면 여러 응답으로 분할됩니다.",
        [LID.HELP_CATEGORY_KEYWORDS]              =
        "직업이 일치하면 이러한 카테고리별 특정 키워드를 확인하여 인사를 정확하게 합니다. 예를 들어, 'toxic' 또는 'slimy'와 같은 키워드를 여기에 넣어 Alchemy 패턴을 감지하려고 시도할 수 있습니다.",
        [LID.HELP_CATEGORY_GREETING]              =
        "이 카테고리가 메시지에서 키워드나 아이템 링크를 통해 감지되면 이 추가 인사가 직업 인사 뒤에 추가됩니다.",
        [LID.HELP_CATEGORY_OVERRIDE]              = "직업 인사를 생략하고 카테고리 인사로 시작합니다.",
        [LID.HELP_ITEM_KEYWORDS]                  =
        "직업이 일치하면 이러한 항목별 특정 키워드를 확인하여 인사를 정확하게 합니다. 일치하는 경우 응답에 일반적인 직업 인사 대신 아이템 링크가 포함됩니다. 'lariat'가 직업 키워드이지만 항목 키워드가 아닌 경우 응답에 'I have Jewelcrafting.'이라고 표시됩니다. 'lariat'가 항목 키워드 인 경우에만 'LF Lariat'가 직업을 일치시키지 않으며 일치로 간주되지 않되지 않습니다. 'lariat'가 직업 및 항목 키워드인 경우 'LF Lariat'에 대한 응답은 'I can craft [Elemental Lariat].'이 됩니다.",
        [LID.HELP_ITEM_GREETING]                  =
        "메시지에서 이 항목이 키워드나 아이템 링크를 통해 감지되면 직업 및 카테고리 인사 뒤에 이 추가 인사가 추가됩니다.",
        [LID.HELP_ITEM_OVERRIDE]                  = "직업 및 카테고리 인사를 생략하고 항목 인사로 시작합니다.",
        [LID.HELP_GLOBAL_KEYWORDS]                = "이 용어 중 하나가 메시지에 포함되어야 합니다.",
        [LID.HELP_GLOBAL_EXCLUSIONS]              = "이 용어가 포함된 메시지는 무시됩니다.",
        [LID.SCAN_ALL_RECIPES]                    = '모든 레시피 검색',
        [LID.SCANNING_ENABLED]                    = "'%s'가 선택되어 있으므로 스캔이 활성화되었습니다.", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]                   = "스캔이 비활성화되었습니다.",
        [LID.PRIMARY_KEYWORDS]                    = "기본 키워드",
        [LID.HELP_PRIMARY_KEYWORDS]               =
        "이 용어로 필터링된 모든 메시지는 모든 직업에 공통입니다. 일치하는 메시지는 직업 관련 콘텐츠를 찾아 추가로 처리됩니다.",
        [LID.HELP_CATEGORY_SECTION]               =
        "카테고리는 왼쪽 목록에 있는 레시피를 포함하는 접히는 섹션입니다. 'Favorites'는 카테고리가 아닙니다. 이것은 주로 제작하기 어려운 독성 가죽 제작 레시피와 같은 것들에 대해 의도되었습니다. 확장팩 시작 시에는 하나의 카테고리에만 전문화할 수 있습니다.",
        [LID.HELP_EXPANSION_SECTION]              = "지식 트리는 확장팩마다 다르므로 인사도 다를 수 있습니다.",
        [LID.HELP_PROFESSION_SECTION]             =
        "고객 관점에서는 확장팩 간에 차이가 없습니다. 이 용어는 새로운 확장팩 출시 시 더 구체적인 것을 일치시키지 못할 때 일반적인 인사를 제공하기 위해 '기본 확장팩' 선택과 결합됩니다.",
        [LID.RECIPE_NOT_LEARNED]                  = "이 레시피를 배우지 않았습니다. 스캔이 비활성화되었습니다.",
        [LID.PING_SOUND_LABEL]                    = "알림 소리",
        [LID.PING_SOUND_TOOLTIP]                  = "고객이 감지되었을 때 재생되는 소리.",
        [LID.BANNER_SIDE_LABEL]                   = "배너 방향",
        [LID.BANNER_SIDE_TOOLTIP]                 = "배너가 이 방향에서 버튼에서 늘어납니다.",
        Left                                      = "왼쪽",
        Right                                     = "오른쪽",
        Minute                                    = "분",
        Minutes                                   = "분",
        Second                                    = "초",
        Seconds                                   = "초",
        Millisecond                               = "밀리초",
        Milliseconds                              = "밀리초",
        Version                                   = "신규",
        ["CraftScan Release Notes"]               = "CraftScan 릴리스 노트",
        [LID.CUSTOMER_TIMEOUT_LABEL]              = "고객 시간 초과",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]            = "이 시간(분)이 지나면 고객이 자동으로 해체됩니다.",
        [LID.BANNER_TIMEOUT_LABEL]                = "배너 시간 초과",
        [LID.BANNER_TIMEOUT_TOOLTIP]              =
        "매칭이 감지된 후 이 기간 동안 고객 알림 배너가 표시됩니다.",
        ["All crafters"]                          = "모든 제작자",
        ["Crafter Name"]                          = "제작자 이름",
        ["Profession"]                            = "직업",
        ["Customer Name"]                         = "고객 이름",
        ["Replies"]                               = "답장",
        ["Keywords"]                              = "키워드",
        ["Profession greeting"]                   = "직업 인사",
        ["Category greeting"]                     = "카테고리 인사",
        ["Item greeting"]                         = "아이템 인사",
        ["Primary expansion"]                     = "기본 확장팩",
        ["Override greeting"]                     = "인사 덮어쓰기",
        ["Excluded keywords"]                     = "제외된 키워드",
        [LID.EXCLUSION_INSTRUCTIONS]              = "이 쉼표로 구분된 토큰을 포함하는 메시지를 일치시키지 마세요.",
        [LID.KEYWORD_INSTRUCTIONS]                = "이 쉼표로 구분된 키워드 중 하나가 포함된 메시지를 일치시킵니다.",
        [LID.GREETING_INSTRUCTIONS]               = "제작품을 찾는 고객에게 보낼 인사입니다.",
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
        [LID.RN_WELCOME]                          = "CraftScan에 오신 것을 환영합니다!",
        [LID.RN_WELCOME + 1]                      =
        "이 애드온은 제작 요청처럼 보이는 메시지를 채팅에서 스캔합니다. 구성에 따라 요청된 아이템을 제작할 수 있는 경우 알림이 트리거되고 고객 정보가 저장됩니다.",

        [LID.RN_INITIAL_SETUP]                    = "초기 설정",
        [LID.RN_INITIAL_SETUP + 1]                =
        "시작하려면 직업을 열고 하단의 새 'CraftScan 표시' 버튼을 클릭하세요.",
        [LID.RN_INITIAL_SETUP + 2]                =
        "이 새 창의 하단부로 스크롤하여 위로 작업하세요. 드물게 변경해야 할 사항은 하단에 있지만, 이것이 먼저 주의해야 할 설정입니다.",
        [LID.RN_INITIAL_SETUP + 3]                =
        "창 왼쪽 상단의 도움말 아이콘을 클릭하여 입력란의 설명을 확인하세요.",

        [LID.RN_INITIAL_TESTING]                  = "초기 테스트",
        [LID.RN_INITIAL_TESTING + 1]              =
        "구성한 후 /say 채팅에 'LF BS'와 같은 메시지를 입력하여 테스트하세요(문자는 키워드 'LF' 및 'BS'를 가정함). 알림이 표시됩니다.",
        [LID.RN_INITIAL_TESTING + 2]              =
        "알림을 클릭하여 즉시 응답을 보내려면 클릭하세요. 고객을 해체하려면 오른쪽 클릭하거나 원형 직업 버튼을 클릭하여 주문 창을 열 수 있습니다.",
        [LID.RN_INITIAL_TESTING + 3]              =
        "이미 해체된 것을 제외하고 중복 알림이 억제되므로 테스트 알림을 다시 시도하려면 테스트 알림을 해제하려면 테스트 알림을 해제하세요.",

        [LID.RN_MANAGING_CRAFTERS]                = "제작자 관리",
        [LID.RN_MANAGING_CRAFTERS + 1]            =
        "주문 창의 좌측에는 제작자 목록이 표시됩니다. 이 목록은 다양한 캐릭터에 로그인하고 그들의 직업을 구성하는 대로 채워집니다. 필요에 따라 어느 시점에서든 활성 스캔할 캐릭터를 선택하고 각 제작자에 대한 시각적 및 청각적 알림이 활성화되었는지 선택할 수 있습니다.",

        [LID.RN_MANAGING_CUSTOMERS]               = "고객 관리",
        [LID.RN_MANAGING_CUSTOMERS + 1]           =
        "주문 창의 우측에는 채팅에서 감지된 제작 주문이 표시됩니다. 행을 클릭하여 팝업 배너에서 이미 인사하지 않았다면 인사를 보낼 수 있습니다. 고객에게 새창에 임시 대화 창을 열려면 다시 클릭하세요. 행을 해체하려면 오른쪽 클릭하세요.",
        [LID.RN_MANAGING_CUSTOMERS + 2]           =
        "이 테이블의 행은 모든 캐릭터에 걸쳐 유지되므로 대체 캐릭터로 전환한 다음 고객을 다시 클릭하여 통신을 복원할 수 있습니다. 기본 설정에서 10분 후에 행이 타임아웃됩니다. 이 기간은 주 설정 페이지(Esc -> 옵션 -> 애드온 -> CraftScan)에서 구성할 수 있습니다.",
        [LID.RN_MANAGING_CUSTOMERS + 3]           =
        "테이블의 대부분은 자명합니다. 'Replies' 열에는 3개의 아이콘이 있습니다. 왼쪽 X 또는 확인 표시는 고객에게 메시지를 보냈는지 여부입니다. 오른쪽 X 또는 확인 표시는 고객이 회신했는지 여부입니다. 채팅 말풍선은 고객과 임시로 대화 창을 열며 채팅 기록을 채우는 버튼입니다.",

        [LID.RN_KEYBINDS]                         = "키 설정",
        [LID.RN_KEYBINDS + 1]                     =
        "주문 페이지를 열고 최신 고객에게 응답하거나 최신 고객을 해체하는 키 설정이 있습니다. 사용 가능한 모든 설정을 찾으려면 'CraftScan'을 검색하세요.",

        [LID.RN_CLEANUP]                          = "설정 정리",
        [LID.RN_CLEANUP + 1]                      =
        "'대화 주문' 페이지의 왼쪽에 있는 장인이 이제 오른쪽 클릭 시 컨텍스트 메뉴를 갖습니다. 이 메뉴를 사용하여 목록을 깨끗하게 유지하고 오래된 캐릭터/직업을 제거하세요.",
        ["Disable"]                               = "비활성화",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]          =
        "%s에 대한 모든 저장된 %s 데이터를 영구적으로 삭제합니다.\n\n'CraftScan 활성화' 버튼이 직업 페이지에 표시되어 기본 설정으로 다시 활성화할 수 있습니다.\n\n이 기능은 직업을 계속 사용하고 싶지만 CraftScan 상호작용 없이 사용하고 싶을 때 사용하세요 (예: 모든 부캐릭터에 연금술을 보유하여 긴 플라스크 사용).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]               = "계속하려면 'DELETE'를 입력하세요:",
        [LID.SCANNER_CONFIG_DISABLED]             = "CraftScan 활성화",

        ["Cleanup"]                               = "정리",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]         =
        "%s에 대한 모든 저장된 %s 데이터를 영구적으로 삭제합니다.\n\n직업이 설정되지 않은 상태로 남겨질 것입니다. 직업을 다시 열면 기본 구성이 복원됩니다.\n\n이 기능은 직업을 완전히 초기화하고 싶을 때, 캐릭터를 삭제했거나 직업을 버렸을 때 사용하세요.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]              = "계속하려면 'CLEANUP'을 입력하세요:",
        ["Primary Crafter"]                       = "주요 제작자",
        [LID.PRIMARY_CRAFTER_TOOLTIP]             = "이 %s를 %s의 주요 제작자로 설정합니다. 동일한 요청에 여러 매치가 있는 경우 이 제작자가 우선됩니다.",
        ["Chat History"]                          = "%s와의 채팅 기록", -- customer, left-click-help
        ["Greet Help"]                            = "|cffffd100왼쪽 클릭: 고객에게 인사%s|r",
        ["Chat Help"]                             = "|cffffd100왼쪽 클릭: 귓말 열기|r",
        ["Chat Override"]                         = "|cffffd100가운데 클릭: 귓말 열기%s|r",
        ["Dismiss"]                               = "|cffffd100오른쪽 클릭: 닫기%s|r",
        ["Proposed Greeting"]                     = "제안된 인사말:",
        [LID.CHAT_BUTTON_BINDING_NAME]            = "귓말 배너 고객",
        ["Customer Request"]                      = "%s의 요청",
        [LID.ADDON_WHITELIST_LABEL]               = "애드온 허용 목록",
        [LID.ADDON_WHITELIST_TOOLTIP]             =
        "모든 애드온을 일시적으로 비활성화하는 버튼을 누를 때, 여기에서 선택한 애드온을 유지합니다. CraftScan은 항상 활성화됩니다. 제작에 필요한 것만 유지하세요.",
        [LID.MULTI_SELECT_BUTTON_TEXT]            = "%d 선택됨", -- Count

        [LID.ACCOUNT_LINK_DESC]                   =
        "여러 계정 간에 제작자를 공유하세요.\n\n로그인 시 또는 설정 변경 후, CraftScan은 양쪽 계정에 설정된 제작자 간 최신 정보를 전파하여 항상 동기화되도록 합니다.",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]       = "다른 계정에 있는 온라인 캐릭터 이름을 입력하세요:",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]        = "다른 계정의 별명을 입력하세요:",
        ["Link Account"]                          = "계정 연결",
        ["Linked Accounts"]                       = "연결된 계정",
        ["Accept Linked Account"]                 = "연결된 계정 수락",
        ["Delete Linked Account"]                 = "연결된 계정 삭제",
        ["OK"]                                    = "확인",
        [LID.VERSION_MISMATCH]                    = "|cFFFF0000오류: CraftScan 버전 불일치. 다른 계정의 버전: %s. 현재 버전: %s.|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]              =
        "이 캐릭터는 연결된 계정에 속합니다. 캐릭터가 속한 계정에서만 비활성화할 수 있습니다. '정리'를 통해 이 캐릭터를 완전히 제거할 수 있지만, 모든 연결된 계정에서 수동으로 제거해야 하며, 로그인 시 연결된 계정에 의해 복원됩니다.",
        [LID.REMOTE_CRAFTER_SUMMARY]              = "%s와(과) 동기화됨.",
        ["proxy_send_enabled"]                    = "프록시 주문",
        ["proxy_send_enabled_tooltip"]            = "고객 주문이 감지되면, 연결된 계정에 보냅니다.",
        ["proxy_receive_enabled"]                 = "프록시 주문 받기",
        ["proxy_receive_enabled_tooltip"]         = "다른 계정이 고객 주문을 감지하고 전송하면 이 계정이 받습니다. 필요한 경우 CraftScan 버튼이 경고 배너를 표시합니다.",
        [LID.LINK_ACTIVE]                         = "|cFF00FF00%s (마지막 접속: %s)|r", -- Crafter, Time
        [LID.ACCOUNT_LINK_DELETE_INFO]            =
        "'%s'와(과)의 연결을 삭제하고 모든 가져온 캐릭터를 삭제합니다. 이 계정은 다른 계정과의 모든 통신을 중단합니다. 다른 계정은 수동으로 연결을 제거할 때까지 계속 연결을 시도할 것입니다.\n\n삭제될 가져온 제작자:\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]               =
        "기본적으로 처음 연결한 캐릭터, 모든 제작자, 이 계정이 온라인 상태일 때 로그인한 모든 캐릭터가 CraftScan에 알려져 있습니다. 다른 계정에 속한 추가 캐릭터를 추가하여 사용할 수 있도록 합니다. 온라인 상태인 경우 '/reload'로 새 캐릭터와 강제로 동기화하세요.",
        ["Backup characters"]                     = "추가 캐릭터",
        ["Unlink account"]                        = "계정 연결 해제",
        ["Add"]                                   = "추가",
        ["Remove"]                                = "제거",
        ["Rename account"]                        = "계정 이름 변경",
        ["New name"]                              = "새 이름:",

        [LID.RN_LINKED_ACCOUNTS]                  = "연결된 계정",
        [LID.RN_LINKED_ACCOUNTS + 1]              = "제작 정보를 공유하고 모든 계정에서 모든 계정의 스캔을 할 수 있도록 여러 WoW 계정을 연결하세요.",
        [LID.RN_LINKED_ACCOUNTS + 2]              = "원하는 경우 한 계정에서 다른 계정으로 고객 주문을 프록시하여 메인 캐릭터가 외부에 있는 동안 시험 계정을 도시에 주차할 수 있습니다.",
        [LID.RN_LINKED_ACCOUNTS + 3]              = "시작하려면 CraftScan 창의 왼쪽 하단 모서리에 있는 '계정 연결' 버튼을 클릭하고 지침을 따르세요.",
        [LID.RN_LINKED_ACCOUNTS + 4]              = "데모: https://www.youtube.com/watch?v=x1JLEph6t_c",
        ["Open Settings"]                         = "설정 열기",
        ["Customize Greeting"]                    = "환영 인사 사용자 정의",
        [LID.CUSTOM_GREETING_INFO]                =
        "CraftScan은 상황에 따라 고객에게 전송되는 초기 인사를 만들기 위해 이 문장을 사용합니다. 일부 또는 전부를 아래에서 덮어쓰고 자신만의 인사를 만드세요.",
        ["Default"]                               = "기본값",
        [LID.MISSING_PLACEHOLDERS]                = "다음 플레이스홀더도 지원됩니다: %s.",
        [LID.EXTRA_PLACEHOLDERS]                  = "오류: %s는 올바른 자리 표시자가 아닙니다.",
        [LID.LEGACY_PLACEHOLDERS]                 = "경고: %s의 사용은 더 이상 사용되지 않습니다. 다음과 같이 명명된 플레이스홀더를 사용하세요: {placeholder}",

        ["Pixels"]                                = "픽셀",
        ["Show button height"]                    = "버튼 높이 표시",
        ["Alert icon scale"]                      = "경고 아이콘 비율",
        ["Total"]                                 = "총계",
        ["Repeat"]                                = "반복",
        ["Avg Per Day"]                           = "일일 평균",
        ["Peak Per Hour"]                         = "시간당 최대",
        ["Median Per Customer"]                   = "고객 중앙값",
        ["Median Per Customer Filtered"]          = "고객 반복 중앙값",
        ["No analytics data"]                     = "분석 데이터 없음",
        ["Reset Analytics"]                       = "분석 초기화",
        ["Analytics Options"]                     = "분석 옵션",

        ["1 minute"]                              = "1분",
        ["15 minutes "]                           = "15분 ",
        ["1 hour"]                                = "1시간",
        ["1 day"]                                 = "1일",
        ["1 week "]                               = "1주 ",
        ["30 days"]                               = "30일",
        ["180 days"]                              = "180일",
        ["1 year"]                                = "1년",
        ["Clear recent data"]                     = "최근 데이터 삭제",
        ["Newer than"]                            = "이전보다 최근",
        ["Clear old data"]                        = "오래된 데이터 삭제",
        ["Older than"]                            = "이전보다 오래됨",
        ["1 Minute Bins"]                         = "1분 단위",
        ["5 Minute Bins"]                         = "5분 단위",
        ["10 Minute Bins"]                        = "10분 단위",
        ["30 Minute Bins"]                        = "30분 단위",
        ["1 Hour Bins"]                           = "1시간 단위",
        ["6 Hour Bins"]                           = "6시간 단위",
        ["12 Hour Bins"]                          = "12시간 단위",
        ["24 Hour Bins"]                          = "24시간 단위",
        ["1 Week Bins"]                           = "1주 단위",

        [LID.ANALYTICS_ITEM_TOOLTIP]              =
        "아이템은 메시지가 글로벌 포함 및 제외 키워드와 일치하는지 확인한 다음 아이템 링크에서 품질 아이콘을 찾는 방식으로 매치됩니다. 제작된 아이템에 대한 글로벌 목록이나 itemID가 제작된 것인지 확인하는 방법이 없으므로, 이것이 우리가 할 수 있는 최선입니다.",
        [LID.ANALYTICS_PROFESSION_TOOLTIP]        =
        "아이템에서 그것을 제작하는 직업으로 역 검색하는 기능이 없습니다. 만약 당신의 캐릭터 중 하나가 아이템을 제작할 수 있다면, 직업이 자동으로 할당됩니다. 직업이 열리면 그 직업에 속한 알려지지 않은 아이템이 할당됩니다. 또한 직업을 수동으로 할당할 수도 있습니다.",
        [LID.ANALYTICS_TOTAL_TOOLTIP]             = "이 아이템이 요청된 총 횟수입니다. 같은 고객이 동일한 시간 내에 요청한 중복 요청은 포함되지 않습니다.",
        [LID.ANALYTICS_REPEAT_TOOLTIP]            =
        "같은 고객이 같은 시간 내에 여러 번 요청한 이 아이템의 총 요청 횟수입니다.\n\n이 값이 총계에 가깝다면, 이 아이템의 공급이 부족할 가능성이 높습니다.\n\n처음 요청한 후 15초 이내에 중복 요청은 무시됩니다.",
        [LID.ANALYTICS_AVERAGE_TOOLTIP]           = "이 아이템의 일일 평균 요청 수입니다.",
        [LID.ANALYTICS_PEAK_TOOLTIP]              = "이 아이템의 시간당 최대 요청 수입니다.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP]            =
        "동일한 고객이 동일한 시간 내에 요청한 이 아이템의 중앙값입니다.\n\n값이 1인 경우, 모든 요청의 최소 절반이 누군가에 의해 충족되고 있음을 나타내며, 이 아이템에 대한 수요가 만족되고 있음을 의미합니다.\n\n이 값이 높다면, 이 아이템을 제작할 수 있는 좋은 기회일 수 있습니다.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP_FILTERED]   =
        "동일한 고객이 동일한 시간 내에 요청한 이 아이템의 중앙값이며, 여러 번 요청한 요청만 필터링합니다.\n\n이 값이 1이 아니지만 필터링되지 않은 중앙값이 1이라면, 수요가 충족되지 않는 경우가 있다는 것을 나타냅니다.",
        ["Request Count"]                         = "요청 수",
        [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]        =
        "'%s'가 계정 연결 요청을 보냈습니다.\n\n요청된 권한:\n\n%s\n\n요청을 보낸 것이 아니라면 전체 권한을 수락하지 마세요.\n\n상대 계정을 위한 별명을 입력하세요:",
        [LID.LINKED_ACCOUNT_REJECTED]             = "CraftScan: 연결된 계정 요청 실패. 이유: %s",
        [LID.LINKED_ACCOUNT_USER_REJECTED]        = "대상 계정이 요청을 거부했습니다.",

        [LID.LINKED_ACCOUNT_PERMISSION_FULL]      = "전체 제어",
        [LID.LINKED_ACCOUNT_PERMISSION_ANALYTICS] = "분석 동기화",
        [LID.ACCOUNT_LINK_PERMISSIONS_DESC]       = "연결된 계정에서 다음 권한 요청.",
        [LID.ACCOUNT_LINK_FULL_CONTROL_DESC]      = "모든 캐릭터 데이터를 동기화하고 모든 다른 권한을 지원합니다.",
        [LID.ACCOUNT_LINK_ANALYTICS_DESC]         =
        "두 계정 간에 수동으로 분석 데이터만 동기화합니다. 두 계정 중 어느 쪽도 언제든지 양방향 동기화를 시작할 수 있습니다. 자동으로는 절대 이루어지지 않습니다. 캐릭터가 가져오지 않으므로, 여기서 지정된 캐릭터와만 동기화됩니다. 연결된 계정의 추가 알트를 수동으로 계정 메뉴에서 추가할 수 있습니다.",
        ["Sync Analytics"]                        = "분석 동기화",
        ["Sync Recent Analytics"]                 = "최근 분석 동기화",
        [LID.ANALYTICS_PROF_MISMATCH]             = "|cFFFF0000CraftScan: 경고: 분석 동기화 직업 불일치. 아이템: %s. 로컬 직업: %s. 연결된 직업: %s.|r",
        [LID.RN_ANALYTICS]                        = "분석",
        [LID.RN_ANALYTICS + 1]                    =
        "CraftScan은 이제 채팅에서 제작된 아이템과 글로벌 키워드(예: LF, 재제작 등...)가 결합된 모든 내용을 스캔합니다. 아이템을 제작할 수 없더라도, 시간은 기록되고 감지된 아이템은 채팅에서 일반적인 주문 아래에 표시됩니다.",
        [LID.RN_ANALYTICS + 2]                    =
        "'반복'이라는 개념은 아이템의 공급 부족을 판단하는 데 사용됩니다. CraftScan은 지난 한 시간 동안 누가 무엇을 요청했는지 기억하며, 동일한 것을 다시 요청하면 반복으로 기록됩니다. 새 그리드의 열 머리글에는 의도를 설명하는 툴팁이 있습니다.",
        [LID.RN_ANALYTICS + 3]                    = "거래 채팅에서 충분한 시간 동안 주차된 캐릭터로, 직업 나무의 어떤 지점에 투자할 가치가 있는지를 잘 알 수 있습니다.",
        [LID.RN_ANALYTICS + 4]                    =
        "분석은 여러 계정 간에 동기화할 수 있습니다. 하루 종일 거래에서 데이터 수집을 위해 시험 계정을 주차할 수 있으며, 그 데이터를 주 계정으로 동기화할 수 있습니다. 이제 친구와 분석 전용 계정 링크를 만들 수 있으며, 양방향 동기화를 지원하여 분석을 통합합니다. 수집량이 많아지면, 마지막 동기화 이후의 데이터만 동기화하는 옵션이 있습니다.",
        [LID.RN_ALERT_ICON_ANCHOR]                = "경고 아이콘 고정 업데이트",
        [LID.RN_ALERT_ICON_ANCHOR + 1]            =
        "UI가 숨겨질 때 경고 아이콘이 올바르게 숨겨질 것입니다. 변경으로 인해 내 화면에서 약간 이동하고 축소되었습니다. 만약 이로 인해 버튼이 화면에서 이동했다면, 채팅 주문 페이지 오른쪽 상단의 '설정 열기' 버튼을 오른쪽 클릭하면 재설정 옵션이 있습니다.",
        [LID.BUSY_RIGHT_NOW]                      = "바쁨 모드",
        [LID.GREETING_BUSY]                       = "지금 바쁩니다. 하지만 나중에 만들 수 있습니다.",
        [LID.BUSY_HELP]                           =
        "|cFFFFFFFF체크할 경우, 응답에 바쁨 인사를 추가합니다. 아래 버튼으로 바쁨 인사를 수정하세요.\n\n이것은 주 계정으로 외출 중 주문을 받을 수 있도록 주문을 대리하는 두 번째 계정에서 사용하기 위한 것입니다.\n\n현재 바쁨 인사: |cFF00FF00%s|r|r",
        ["Custom Explanations"]                   = "사용자 정의 설명",
        ["Create"]                                = "생성",
        ["Modify"]                                = "수정",
        ["Delete"]                                = "삭제",
        [LID.EXPLANATION_LABEL_DESC]              = "채팅에서 고객 이름을 오른쪽 클릭할 때 볼 수 있는 레이블을 입력하세요.",
        [LID.EXPLANATION_DUPLICATE_LABEL]         = "이 레이블은 이미 사용 중입니다.",
        [LID.EXPLANATION_TEXT_DESC]               = "레이블을 클릭할 때 고객에게 보낼 메시지를 입력하세요. 새 줄은 별도의 메시지로 전송됩니다. 긴 줄은 최대 메시지 길이에 맞게 분할됩니다.",
        ["Create an Explanation"]                 = "설명 만들기",
        ["Save"]                                  = "저장",
        ["Reset"]                                 = "재설정",
        [LID.MANUAL_MATCHING_TITLE]               = "수동 일치",
        [LID.MANUAL_MATCH]                        = "%s - %s", -- 제작자, 직업
        [LID.MANUAL_MATCHING_DESC]                =
        "주요 키워드를 무시하고 이 메시지에 대한 일치를 강제합니다. CraftScan은 메시지에 따라 올바른 제작자를 찾으려고 하지만, 일치하는 항목이 없으면 지정된 제작자에 대한 기본 인사가 사용됩니다. 일치는 일반적인 방법으로 보고되며, 배너 또는 테이블 행을 클릭하여 인사를 보낼 수 있습니다.",

        [LID.RN_MANUAL_MATCH]                     = "수동 일치",
        [LID.RN_MANUAL_MATCH + 1]                 = "채팅에서 플레이어 이름을 오른쪽 클릭할 때 컨텍스트 메뉴에 CraftScan 옵션이 추가되었습니다.",
        [LID.RN_MANUAL_MATCH + 2]                 =
        "이 메뉴에는 모든 제작자와 직업이 포함됩니다. 이 중 하나를 클릭하면 '주요 키워드'(예: LF, WTB, 재제작 등...)를 고려하지 않고 일치를 찾기 위해 메시지에 대한 또 다른 처리를 강제합니다.",
        [LID.RN_MANUAL_MATCH + 3]                 = "메시지가 여전히 일치하지 않는 경우, 클릭한 제작자 및 직업에 대한 기본 인사로 일치를 강제합니다.",
        [LID.RN_MANUAL_MATCH + 4]                 =
        "이 클릭은 자동으로 고객에게 메시지를 보내지 않습니다. 일반적인 방법으로 일치를 생성한 후, 생성된 응답을 검사하고 보내거나 말거나 선택할 수 있습니다.",
        [LID.RN_MANUAL_MATCH + 5]                 = "(죄송합니다, 기계 학습이 없습니다.)",
        [LID.RN_CUSTOM_EXPLANATIONS]              = "사용자 정의 설명",
        [LID.RN_CUSTOM_EXPLANATIONS + 1]          =
        "'채팅 주문' 페이지에 '사용자 정의 설명' 버튼이 추가되었습니다. 여기에서 구성된 설명은 채팅의 컨텍스트 메뉴에도 표시되며, 클릭하면 즉시 설명이 전송됩니다.",
        [LID.RN_CUSTOM_EXPLANATIONS + 2]          = "설명은 알파벳순으로 정렬되므로, 원하는 순서를 강제로 만들기 위해 번호를 매길 수 있습니다.",
        [LID.RN_BUSY_MODE]                        = "바쁨 모드",
        [LID.RN_BUSY_MODE + 1]                    =
        "몇 가지 릴리스 동안 존재했지만 설명되지 않았습니다. '채팅 주문' 페이지에 새로운 '바쁨 모드' 체크박스가 있습니다. 체크하면 응답에 바쁨 인사를 추가합니다. '인사 사용자 정의' 버튼으로 바쁨 인사를 수정합니다.",
        [LID.RN_BUSY_MODE + 2]                    = "이는 주문을 대리하는 두 번째 계정과 함께 사용하기 위한 것으로, 외출 중에도 주문을 받을 수 있으며 고객은 즉시 제작할 수 없다는 것을 알게 됩니다.",
        ["Release Notes"]                         = "릴리스 노트",
        ["Secondary Keywords"]                    = "보조 키워드",
        [LID.SECONDARY_KEYWORD_INSTRUCTIONS]      =
        "예: 'pvp, 610, algari' 또는 '606, 610, 636' 또는 '590' 등 여러 아이템에서 동일한 키워드를 구분하기 위해 사용됩니다.",
        [LID.HELP_ITEM_SECONDARY_KEYWORDS]        = "위의 키워드와 일치한 후, 보조 키워드를 확인하여 동일한 아이템 슬롯의 다양한 제작을 구분합니다.",
        [LID.RN_SECONDARY_KEYWORDS]               = "보조 키워드",
        [LID.RN_SECONDARY_KEYWORDS + 1]           =
        "아이템은 이제 매칭을 정교하게 하기 위한 보조 키워드를 지원합니다. 각 아이템 슬롯에는 보통 스파크, PVP 및 블루 버전이 있습니다. 보조 키워드를 설정하여 이를 구분할 수 있습니다.",
        [LID.RN_SECONDARY_KEYWORDS + 2]           = "보조 키워드 예시:",
        [LID.RN_SECONDARY_KEYWORDS + 3]           = "606, 619, 636",
        [LID.RN_SECONDARY_KEYWORDS + 4]           = "610, pvp, algari",
        [LID.RN_SECONDARY_KEYWORDS + 5]           = "590",
        ["Find Crafter"]                          = "제작자 찾기",
        ["No Crafters Found"]                     = "제작자를 찾을 수 없습니다",
        [LID.FOUND_CRAFTER_NAME_ENTRY]            = "%s [%s]",
        [LID.GREET_FOUND_CRAFTER]                 = "|cffffd100좌클릭: 제작 요청|r",
        ["Crafter Greeting"]                      = "|cFFFFFFFF제작자 인사말|r",
        [LID.BUSY_ICON]                           = "|cFFFFFFFF제작자가 현재 바쁘다고 표시했지만 나중에 아이템을 제작할 수 있습니다.\n\n세부 사항은 인사말을 확인하세요.|r",
        ["Potential Crafters"]                    = "가능성 있는 제작자",
        [LID.FOUND_VIA_CRAFT_SCAN]                = "CraftScan을 통해 당신을 찾았고 인사말을 보았습니다. 지금 %s를 제작해줄 수 있나요?",
        [LID.COMMISSION_INSTRUCTIONS]             = "예: '10000g', 기본값: '아무거나'\n이 텍스트는 고객의 '제작자 찾기' 표에 나타납니다.",
        ["Commission"]                            = "수수료",
        ["Crafter [Currently Playing]"]           = "제작자 [현재 플레이 중]",
        ["Profession commission"]                 = "직업 수수료",
        [LID.DEFAULT_COMMISSION]                  = "아무거나",
        [LID.HELP_ITEM_COMMISSION]                =
        "CraftScan은 개인 주문 시 고객에게 '제작자 찾기' 버튼을 제공합니다. 당신의 이름, 인사말 및 이 수수료가 다른 제작자와 함께 표에 표시됩니다. 고객의 표에 잘 맞도록 길이는 12자로 제한됩니다.",
        ["Discoverable"]                          = "고객에게 표시 가능",
        [LID.DISCOVERABLE_SETTING]                = "활성화되면 고객이 '제작자 찾기'를 클릭할 때, 당신의 이름이 아이템을 제작할 수 있는 경우 생성된 표에 나타납니다.",
        [LID.RN_CUSTOMER_SEARCH]                  = "제작자 찾기",
        [LID.RN_CUSTOMER_SEARCH + 1]              =
        "개인 주문을 보낼 수 있는 페이지에 '제작자 찾기' 버튼이 추가되었습니다. 이 버튼은 CraftScan 사용자를 대상으로 요청을 보내고 아이템을 제작할 수 있는 제작자를 표에 결과와 함께 보여줍니다.",
        [LID.RN_CUSTOMER_SEARCH + 2]              = "각 직업과 아이템에는 이제 이 표에 표시될 '수수료' 상자가 있으며, 텍스트는 12자로 제한됩니다.",
        [LID.RN_CUSTOMER_SEARCH + 3]              =
        "'CraftScan' 채널에 가입했지만, 이를 활성화하거나 채널 메시지를 볼 필요는 없습니다. CraftScan이 사적인 요청을 전송할 수 있도록 존재합니다.",
        [LID.RN_CUSTOMER_SEARCH + 4]              = "제작자로서, 이미 당신이 무엇을 제작할 수 있는지 알고 있는 고객으로부터 갑작스러운 귓속말을 받을 수 있습니다.",
        [LID.RN_CUSTOMER_SEARCH + 5]              = "체험 계정은 제작 테이블에 접근할 수 없기 때문에 이 기능을 테스트하는 것이 약간 어렵습니다. 문제가 발생하면 기능을 비활성화할 수 있습니다.",
        [LID.RN_CUSTOMER_SEARCH + 6]              = "Blizzard 설정 메뉴에서 새 '발견 가능' 설정을 통해 이 표에서 제외될 수 있습니다.",
        [LID.RN_CUSTOMER_SEARCH + 7]              =
        "고객이 애드온을 사용할 수 있기 때문에 분석 기능을 완전히 비활성화할 수 있으며, 기본적으로 비활성화되어 있습니다. 데이터를 이미 수집한 경우 기능이 계속 활성화된 상태로 유지됩니다.",
        ["Permissive keyword matching"]           = "허용된 키워드 매칭",
        [LID.PERMISSIVE_MATCH_SETTING]            =
        "체크된 경우, CraftScan은 키워드 일치를 확인할 때 공백 및 기타 구분 기호를 무시합니다. 기본적으로 CraftScan은 짧은 키워드가 다른 단어에 포함되는 잘못된 매칭을 피하기 위해 키워드가 주변 텍스트와 명확하게 구분될 때만 일치시킵니다. 키워드를 구분하기 위해 공백을 사용하지 않는 언어의 경우, 이 옵션을 활성화하십시오.",
        ["Show chat orders tab"]                  = "채팅 주문 탭 표시",
        [LID.SHOW_CHAT_ORDER_TAB]                 = "전문 기술 창에서 '채팅 주문' 탭을 표시하거나 숨깁니다. 숨겨진 경우 CraftScan 버튼을 클릭하여 경고가 표시되는 페이지를 열 수 있습니다.",
        [LID.IGNORE]                              = "무시",
        [LID.IGNORE_TOOLTIP]                      =
        "이 플레이어를 CraftScan 무시 목록에 추가합니다. CraftScan은 이 플레이어가 보낸 모든 메시지를 무시합니다. 이 메뉴를 사용하여 플레이어를 목록에서 제거할 수 있습니다.",
        [LID.UNIGNORE]                            = "무시 해제",
        [LID.UNIGNORE_TOOLTIP]                    = "이 플레이어는 CraftScan 무시 목록에 있습니다. 이 옵션을 통해 목록에서 제거할 수 있습니다.",
        ["Collapse chat context menu"]            = "채팅 컨텍스트 메뉴 축소",
        [LID.COLLAPSE_CHAT_CONTEXT_TOOLTIP]       =
        "채팅에서 플레이어 이름을 오른쪽 클릭하면 모든 컨텍스트 메뉴 항목이 하나의 CraftScan 하위 메뉴로 축소됩니다.",

        [LID.PROXY_ORDERS_TOOLTIP]                = "이 계정에서 감지된 주문을 '전체 제어' 권한이 있는 연결된 계정으로 보냅니다. 수신 계정은 마치 주문을 직접 감지한 것처럼 알림을 표시합니다.",
        [LID.RECEIVE_PROXY_ORDERS_TOOLTIP]        = "‘전체 제어’ 계정에서 감지하고 전달한 주문을 수신합니다. 연결된 계정으로부터 주문을 받으면 이 계정에서도 일반 알림이 표시됩니다.",
        [LID.LOCAL_ALERTS_TOOLTIP]                =
        "이 제작자와 전문 기술에 대한 시각 및 청각 알림은 해당 캐릭터를 플레이 중일 때만 표시됩니다. 이는 단순한 필터이며, 알림을 활성화하거나 비활성화하지 않습니다. 알림은 여전히 제작자 목록 오른쪽의 퀘스트 및 헤드셋 아이콘을 통해 관리됩니다.",
        ["Local Notifications Only"]              = "로컬 알림만",

    }
end
