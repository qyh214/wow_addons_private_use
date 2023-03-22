local W = unpack((select(2, ...)))

W.Changelog[233] = {
    RELEASE_DATE = "2022/04/29",
    IMPORTANT = {
        ["zhCN"] = {
            "新增 Ko-fi 和爱发电捐助入口, 你可以在 [Wind 工具箱]-[信息]-[帮助] 中找到它.",
            "为亚洲语系客户端引入全部的 ElvUI 拉丁字体.",
            "[快速焦点] 现在默认为不开启."
        },
        ["zhTW"] = {
            "新增 Ko-fi 和愛發電捐助入口, 你可以在 [Wind 工具箱]-[信息]-[幫助] 中找到它.",
            "为亞洲語系客戶端引入全部的 ElvUI 拉丁字型.",
            "[快速焦點] 現在預設為不開啟."
        },
        ["enUS"] = {
            "Add Ko-fi and AiFaDian donation button, you can find it in [WindTools]-[Information]-[Help].",
            "Import all ElvUI latin fonts to clients in asian.",
            "[Quick Focus] Change the default status of Quick Focus module to disabled."
        },
        ["koKR"] = {
            "Ko-fi 및 AiFaDian 기부 항목이 추가되었으며, [윈드툴스]-[정보]-[도움말] 에서 확인하실 수 있습니다.",
            "아시아 사용자들은 불러오지 못했던 ElvUI의 모든 라틴 글꼴들을 불러옵니다.",
            "[빠른 주시] 빠른 주시 모듈의 기본 상태를 비활성화로 변경합니다."
        }
    },
    NEW = {
        ["zhCN"] = {
            "兼容性检查界面更新.",
            "添加更多关于 Merathilis UI, Shadow & Light 及 mMediaTag 的兼容性检查.",
            "新增了对 ElvUI Enhanced Again 的兼容性检查.",
            "新增模块 [商人页面扩展]",
            "[美化皮肤] 新增了客服工单状态框体的皮肤.",
            "[美化皮肤] 新增了 ElvUI 聊天语音面板的皮肤.",
            "[鼠标提示] 新增了玩家阵营的图标. 感谢 Merathilis",
            "[鼠标提示] 新增了宠物种类的图标. 感谢 Merathilis",
            "[鼠标提示] 新增了宠物物种 ID. 感谢 Merathilis",
            '[好友名单] 新增了 "使用备注作为名字" 的选项.'
        },
        ["zhTW"] = {
            "兼容性檢查介面更新.",
            "新增更多关于 Merathilis UI, Shadow & Light 及 mMediaTag 的兼容性檢查.",
            "新增了對 ElvUI Enhanced Again 的兼容性檢查.",
            "新增模組 [擴展商人頁面].",
            "[美化皮膚] 新增了 GM 工單狀態框架的皮膚.",
            "[美化皮膚] 新增了 ElvUI 對話語音面板的皮膚.",
            "[浮動提示] 新增了玩家陣營的图示. 感謝 Merathilis",
            "[浮動提示] 新增了寵物種類的图示. 感謝 Merathilis",
            "[浮動提示] 新增了寵物物種 ID. 感謝 Merathilis",
            '[好友名單] 新增了 "使用備註作為名字" 的選項.'
        },
        ["enUS"] = {
            "Update compatibility check interface.",
            "Add more compatibility check for Merathilis UI, Shadow & Light and mMediaTag.",
            "Added compatibility check for ElvUI Enhanced Again.",
            "New module [Extended Merchant Pages] .",
            "[Skins] Added a skin for the GM ticket status frame.",
            "[Skins] Added a skin for the ElvUI chat voice panel.",
            "[Tooltip] Added a faction icon for players. Thanks Merathilis",
            "[Tooltip] Added a species icon for pets. Thanks Merathilis",
            "[Tooltip] Added a species ID for pets. Thanks Merathilis",
            "[Friend List] Added an option to use the note as name."
        },
        ["koKR"] = {
            "호환성 검사 인터페이스가 업데이트되었습니다.",
            "Merathilis UI, Shadow & Light, mMediaTag에 대한 호환성 검사를 추가했습니다.",
            "ElvUI Enhanced Again에 대한 호환성 검사를 추가하였습니다.",
            "새로운 모듈 [상인 목록 확장]",
            "[스킨] GM 대기표 상태 스킨을 추가하였습니다.",
            "[스킨] ElvUI 채팅 보이스 패널 스킨을 추가하였습니다.",
            "[툴팁] 플레이어 진영 아이콘을 추가하였습니다. Thanks Merathilis",
            "[툴팁] 애완 동물 유형에 대한 아이콘을 추가하였습니다. Thanks Merathilis",
            "[툴팁] 애완 동물의 종 ID를 추가하였습니다. Thanks Merathilis",
            "[친구 목록] 이름 대신 메모 사용 옵션이 추가되었습니다"
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "[快速焦点] 修复了对 ElvUI 框架的支持.",
            "[矩形小地图] 提升了稳定性.",
            "[小地图按钮] 修复了日历按钮的材质无法去除的错误.",
            "[小地图按钮] 修复了要塞/盟约按钮错位的问题.",
            "[美化皮肤] 移除了强制 ElvUI 动作条背景为透明的代码.",
            "[美化皮肤] 在扎雷殁提斯时不再对玩家选择框体添加阴影.",
            "[鼠标提示] 兼容新的 LibOpenRaid API.",
            "[鼠标提示] 进度显示标题支持自定义.",
            "[鼠标提示] 在 PGF 插件载入时将会自动禁用队伍信息.",
            "[鼠标提示] 修复初诞者圣墓的进度显示.",
            "[游戏条] Ctrl + Shift + 点击时间区域现在开始开关 CPU 使用统计."
        },
        ["zhTW"] = {
            "[快速焦點] 修復了對 ElvUI 框架的支援.",
            "[矩形小地圖] 提升了穩定性.",
            "[小地圖按鍵] 修復了行事曆按鍵的材質無法去除的錯誤.",
            "[小地圖按鍵] 修復了要塞/盟約按鍵錯位的問題.",
            "[美化皮膚] 移除了強制 ElvUI 快捷列背景為透明的代碼.",
            "[美化皮膚] 在澤瑞斯莫提斯時不再對玩家選擇框架添加陰影.",
            "[浮動提示] 兼容新的 LibOpenRaid API.",
            "[浮動提示] 进度顯示標題支援自定義.",
            "[浮動提示] 在 PGF 插件载入時將會自動禁用隊伍資訊.",
            "[浮動提示] 修復首創者聖塚的進度顯示.",
            "[遊戲條] Ctrl + Shift + 點擊時間區域現在開關 CPU 使用統計."
        },
        ["enUS"] = {
            "[Quick Focus] Fixed the support for all ElvUI frames.",
            "[Rectangle Minimap] Improved stability.",
            "[Minimap Buttons] Fixed the texture not removed problem within skinned calendar icon.",
            "[Minimap Buttons] Fixed the position of garrison/covenant buttons.",
            "[Skins] Removed the code that making ElvUI action bar background to be transparent.",
            "[Skins] Disable the shadow if player in Zereth Mortis.",
            "[Tooltips] Compatible with new LibOpenRaid API.",
            "[Tooltips] Support the customization of the progression display title.",
            "[Tooltips] Disable the team info when PGF is loaded.",
            "[Tooltips] Fixed the progress scanning of Sepulcher of the First Ones (SFO).",
            "[Gamebar] Now you can use Ctrl + Shift + click the time in the middle to toggle CPU usage statistics."
        },
        ["koKR"] = {
            "[빠른 주시] 모든 ElvUI 프레임에 대한 지원을 수정했습니다.",
            "[미니맵 비율 조정] 안정성 향상.",
            "[미니맵 버튼 통합 바] 달력 버튼의 텍스처를 제거할 수 없는 버그를 수정했습니다.",
            "[미니맵 버튼 통합 바] 주둔지/성약 버튼이 잘못된 위치에 있던 문제를 수정했습니다.",
            "[스킨] ElvUI 작업 표시줄 배경을 투명하게 하는 코드를 제거했습니다.",
            "[스킨] 제레스 모르티스에 있는 동안 그림자가 더 이상 플레이어 선택 프레임에 추가되지 않습니다.",
            "[툴팁] 새로운 LibOpenRaid API와 호환됩니다.",
            "[툴팁] 진행 상태 제목의 사용자 정의를 지원합니다.",
            "[툴팁] Premade Groups Filter를 사용 중일 경우 파티 정보를 비활성화합니다.",
            "[툴팁] 태초의 존재의 매장터(SFO)의 진행 상황 스캔을 수정했습니다.",
            "[게임 바] 게임 바의 시계를 Ctrl + Shift 클릭 하면 CPU 사용량 통계가 표시됩니다."
        }
    }
}
