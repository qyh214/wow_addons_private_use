local W = unpack((select(2, ...)))

W.Changelog[225] = {
    RELEASE_DATE = "2021/09/11",
    IMPORTANT = {
        ["zhCN"] = {
            "核心函数库更新.",
            "在模块载入前现在将会检查 ElvUI 版本是否受到支持.",
            "[美化皮肤] 大幅改善了 WeakAuras 的设定美化.",
            "[任务列表] 由于 ElvUI 已经能够自动控制, 去除了爬塔 Buff 在右选项."
        },
        ["zhTW"] = {
            "核心函數庫更新.",
            "在模組載入前, 現在會檢查使用的 ElvUI 版本是否為支援版本.",
            "[美化皮膚] 大幅改善了 WeakAuras 的設定美化.",
            "[任務列表] 由於 ElvUI 已經能夠自動控制, 去除了爬塔 Buff 在右選項."
        },
        ["enUS"] = {
            "Update functions in core library.",
            "ElvUI version will be checked once before modules loading.",
            "[Skins] Significantly improve the quality of the skin of WeakAuras Options.",
            "[Objective Tracker] ElvUI already handling the maw buff list frame, removing the option for expanding maw buff list in right side."
        },
        ["koKR"] = {
            "핵심 기능 라이브러리 업데이트.",
            "이제 모듈이 로드되기 전에 ElvUI 버전이 지원되는지 확인합니다.",
            "[스킨] WeakAuras 설정창의 스킨 품질을 대폭 개선합니다.",
            "[퀘스트 추적기] ElvUI에서 령 버프 목록 프레임을 처리하고 있으므로 령 버프 목록을 오른쪽에서 확장하는 옵션을 제거했습니다."
        }
    },
    NEW = {
        ["zhCN"] = {
            "[其他] 添加了进入战斗自动关闭背包功能.",
            "[美化皮肤] 新增了 ElvUI 光环条的美化.",
            "[美化皮肤] 新增了爬塔场景事件界面的美化.",
            "[美化皮肤] 新增了史诗钥石地下城界面的美化.",
            "[美化皮肤] 新增了 ElvUI 小地图中键菜单的美化.",
            "[美化皮肤] 新增了 Angry Keystones 的美化.",
            "[美化皮肤] 优化并新增了 ElvUI 施法条图标在内时的美化."
        },
        ["zhTW"] = {
            "[其他] 新增了進入戰鬥自動關閉背包功能.",
            "[美化皮膚] 新增了 ElvUI 光環條的美化.",
            "[美化皮膚] 新增了爬塔場景事件介面的美化.",
            "[美化皮膚] 新增了传奇鑰石地城介面的美化.",
            "[美化皮膚] 新增了 Angry Keystones 的美化.",
            "[美化皮膚] 新增了 ElvUI 小地圖中鍵選單的美化.",
            "[美化皮膚] 優化并新增了 ElvUI 施法條圖示在內時的美化."
        },
        ["enUS"] = {
            "[Misc] Add new features to close bags after player enters combat.",
            "[Skins] Add the skin of aura bars for ElvUI unit frames.",
            "[Skins] Add the skin of scenario UI in Torghast.",
            "[Skins] Add the skin of timer in mythic plus.",
            "[Skins] Add the skin of ElvUI minimap middle click menu.",
            "[Skins] Add the skin of Angry Keystones.",
            "[Skins] Optimize the skin of ElvUI cast bars which contains an attached icon."
        },
        ["koKR"] = {
            "[기타] 전투가 시작되면 자동으로 가방을 닫는 기능을 추가했습니다.",
            "[스킨] ElvUI 유닛 프레임의 오라 바 스킨을 추가했습니다.",
            "[스킨] 토르가스트의 시나리오 UI 스킨을 추가했습니다.",
            "[스킨] 신화+ 타이머 스킨을 추가했습니다.",
            "[스킨] ElvUI 미니맵 중간 클릭 메뉴의 스킨을 추가했습니다.",
            "[스킨] Angry Keystones 애드온 스킨을 추가했습니다.",
            "[스킨] ElvUI 캐스팅 바 아이콘을 최적화한 스킨을 추가했습니다."
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "[其他] 部分选项更改后不需要重载界面.",
            "[额外物品条] 修复了不启用自动缩放时背景错位的问题.",
            "[游戏条] 修复了不启用自动缩放时背景错位的问题.",
            "[团队标记] 修复了不启用自动缩放时背景错位的问题.",
            "[小地图按钮] 修复了不启用自动缩放时背景错位的问题.",
            "[聊天条] 修复了不启用自动缩放时背景错位的问题.",
            "[战斗提醒] 修复了不启用自动缩放时错位的问题.",
            "[美化皮肤] 修复了 ElvUI 单位框体的光环美化",
            "[美化皮肤] 修复了 ElvUI 动作条飞出按钮的美化.",
            "[美化皮肤] 修复了史诗钥石地下城开启界面的美化.",
            "[美化皮肤] 启用 Masque 的情况下会自动停用动作条美化.",
            "[美化皮肤] 为暴雪的界面设定美化新增了独立选项.",
            "[美化皮肤] 优化了世界地图上托加斯特鼠标提示的美化.",
            "[美化皮肤] 优化了插件皮肤设定界面.",
            "[任务列表] 优化了标题缩写功能."
        },
        ["zhTW"] = {
            "[其他] 部分選項更改後毋須重載介面.",
            "[額外物品條] 修復了不啟用自動縮放時背景錯位的問題.",
            "[遊戲條] 修復了不啟用自動縮放時背景錯位的問題.",
            "[團隊標記] 修復了不啟用自動縮放時背景錯位的問題.",
            "[小地圖按鍵] 修復了不啟用自動縮放時背景錯位的問題.",
            "[聊天條] 修復了不啟用自動縮放時背景錯位的問題.",
            "[戰鬥提醒] 修復了不啟用自動縮放時錯位的問題.",
            "[美化皮膚] 修復了 ElvUI 單位框架的光環美化.",
            "[美化皮膚] 修復了 ElvUI 快捷列飛出按鍵的美化.",
            "[美化皮膚] 修復了傳奇鑰石地城開啟介面的美化.",
            "[美化皮膚] 啟用 Masque 的情況下會自動停用快捷列美化.",
            "[美化皮膚] 為暴雪的介面設定新增了獨立選項.",
            "[美化皮膚] 優化了世界地圖上托伽司浮動提示的美化.",
            "[美化皮膚] 優化了插件皮膚設定介面.",
            "[任務列表] 優化了標題縮寫功能."
        },
        ["enUS"] = {
            "[Misc] Some options now can be changed without reloading user interface.",
            "[Extra Item Bar] Fix the backdrop scale issue when auto-scale disabled.",
            "[Game Bar] Fix the backdrop scale issue when auto-scale disabled.",
            "[Raid Markers] Fix the backdrop scale issue when auto-scale disabled.",
            "[Minimap Buttons] Fix the backdrop scale issue when auto-scale disabled.",
            "[Chat Bar] Fix the backdrop scale issue when auto-scale disabled.",
            "[Combat Alert] Fix the scale issue when auto-scale disabled.",
            "[Skins] Fix the skin for auras on ElvUI unit frames.",
            "[Skins] Fix the skin for flyout buttons in ElvUI action bar.",
            "[Skins] Fix the skin of mythic keystone frame.",
            "[Skins] The action bar skin will not be loaded if masque enabled.",
            "[Skins] Add a new option for Blizzard interface options skin.",
            "[Skins] Optimize the skin for Torghast tooltip in world map.",
            "[Skins] Optimize the option UI of addon skins.",
            "[Objective Tracker] Optimize the abbreviation feature for long titles."
        },
        ["koKR"] = {
            "[기타] 이제 일부 옵션은 사용자 인터페이스를 다시 로드하지 않고 변경할 수 있습니다.",
            "[아이템 바] 자동 크기 조정이 활성화되지 않았을 때 배경이 어긋나는 문제를 수정했습니다.",
            "[게임 바] 자동 크기 조정이 활성화되지 않았을 때 배경이 어긋나는 문제를 수정했습니다.",
            "[공격대 징표] 자동 크기 조정이 활성화되지 않았을 때 배경이 어긋나는 문제를 수정했습니다.",
            "[미니맵 버튼] 자동 크기 조정이 활성화되지 않았을 때 배경이 어긋나는 문제를 수정했습니다.",
            "[전투 알림] 자동 크기 조정이 활성화되지 않았을 때 크기 문제를 수정했습니다.",
            "[채팅 바] 자동 크기 조정이 활성화되지 않았을 때 크기 문제를 수정했습니다.",
            "[스킨] ElvUI 유닛 프레임의 오라 스킨을 수정했습니다.",
            "[스킨] ElvUI 액션바의 플라이아웃 버튼 스킨을 수정하였습니다.",
            "[스킨] 신화 쐐기돌 프레임 스킨을 수정하였습니다.",
            "[스킨] Masque 애드온이 활성화되면 액션 바 스킨이 자동으로 비활성화됩니다.",
            "[스킨] Blizzard 인터페이스 설정창 스킨을 위한 별도의 옵션을 추가했습니다.",
            "[스킨] 월드맵에서 토르가스트 툴팁에 대한 스킨을 최적화합니다.",
            "[스킨] 애드온 스킨 설정 인터페이스를 최적화했습니다.",
            "[퀘스트 추적기] 긴 제목에 대한 약어 기능을 최적화했습니다."
        }
    }
}
