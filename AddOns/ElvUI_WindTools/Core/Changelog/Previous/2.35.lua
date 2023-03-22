local W = unpack((select(2, ...)))

W.Changelog[235] = {
    RELEASE_DATE = "2022/05/14",
    IMPORTANT = {
        ["zhCN"] = {
            "LibOpenRaid 升级到 33 版本.",
            "修复了未通过账号认证的玩家无法创建预组建队伍的问题.",
            "[通告] '感谢复活' 变为 '感谢', 并支持了能量灌注和激活的通告."
        },
        ["zhTW"] = {
            "LibOpenRaid 升級到 33 版本.",
            "修復了未通過帳號認證的玩家無法創建預組隊伍的問題.",
            "[通告] '感謝復活' 变為 '感謝', 並支持了注入能量和啟動的通告."
        },
        ["enUS"] = {
            "Update LibOpenRaid to version 33.",
            "Fixed a bug where unauthenticated players could not create a group.",
            "[Announcement] 'Thank Ressurection' is now 'Thanks', and add the support of Power Infusion and Innervate."
        },
        ["koKR"] = {
            "LibOpenRaid를 버전 33으로 업그레이드하였습니다.",
            "계정 인증을 받지 않은 플레이어들이 미리 구성된 팀을 만들 수 없는 문제를 수정했습니다.",
            "[알림] '부활 감사합니다'가 '감사합니다'로 변경되었으며 마력 주입 및 정신 자극 알림을 지원합니다."
        }
    },
    NEW = {
        ["zhCN"] = {
            "[其他] 新增 '自动化' 模块, 可以帮你自动接受复活, 召唤和隐藏界面.",
            "[通告] (任务) 新增一个选项用于屏蔽暴雪自带的任务进度信息.",
            "[标签] 增加了一些新的不同小数位数缩写的生命值标签.",
            "[标签] 增加了 absorbs-long 用于显示完整护盾数值.",
            "[美化皮肤] 新增了 WarpDeplete 插件的美化外观.",
            "[美化皮肤] 新增了物品升级美化外观."
        },
        ["zhTW"] = {
            "[其他] 新增 '自動化' 模組, 可以幫你自動接受復活, 召喚和隱藏介面.",
            "[通告] (任務) 新增一個選項用於屏蔽暴雪自帶的任務進度訊息.",
            "[標籤] 增加了一些新的不同小數位數縮寫的生命值標籤.",
            "[標籤] 增加了 absorbs-long 用於顯示完整護盾數值.",
            "[美化皮膚] 新增了 WarpDeplete 插件的美化外觀.",
            "[美化皮膚] 新增了物品升級美化外觀."
        },
        ["enUS"] = {
            "[Misc] New 'Automation' module, which can help you automatically accept resurrection, summon and hide frames in combat.",
            "[Announcement] (Quest) Added an option to disable Blizzard quest progress info.",
            "[Tags] Added some new different health tags with different decimal lengths.",
            "[Tags] Added absorbs-long to display full absorb value.",
            "[Skin] Added a new skin for WarpDeplete.",
            "[Skin] Added a new skin for item upgrade frame."
        },
        ["koKR"] = {
            "[기타] 자동으로 부활, 소환 및 전투중 프레임을 감추는 데 도움이 되는 '자동화' 모듈을 추가했습니다.",
            "[알림] (퀘스트) 블리자드 자체 미션 진행 정보를 차단하는 옵션이 추가되었습니다.",
            "[태그] 단위 약어가 다른 몇 가지 새로운 체력 태그를 추가했습니다.",
            "[태그] 전체 피해 흡수량을 표시하는 absorbs-long 태그가 추가되었습니다.",
            "[스킨] WarpDeplete 스킨이 추가되었습니다.",
            "[스킨] 아이템 강화 창 스킨이 추가되었습니다."
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "[标签] smart-power 和 smart-power-long 现在固定使用整数.",
            "[通告] (任务) 优化了任务进度信息的显示.",
            "[右键菜单] 修复了属性报告功能.",
            "[超级追踪] 由于可能产生的污染, 移除了纯数字的选项.",
            "[交接] 修复了有时任务无法正常接取完成的问题",
            "[美化皮肤] 优化了拍卖行皮肤.",
            "[美化皮肤] 优化了暴雪 UI 组件皮肤.",
            "[美化皮肤] 优化了弹出通知的皮肤.",
            "[美化皮肤] 优化了 Immersion 的皮肤.",
            "[美化皮肤] 修复了任务物品按钮的阴影.",
            "[美化皮肤] 修复了额外物品投掷框体的阴影.",
            "[移动框体] 新增一个选项用于提升与 Trade Skill Master 的兼容性.",
            "[吸收] 修复了战斗中重载界面可能导致的污染.",
            "[切换按钮] 新增了功能鼠标提示."
        },
        ["zhTW"] = {
            "[標籤] smart-power 和 smart-power-long 現在固定使用整數.",
            "[通告] (任務) 优化了任務進度訊息的顯示.",
            "[右鍵選單] 修復了屬性報告功能.",
            "[超級追蹤] 由於可能產生的汙染, 移除了僅數字的選項.",
            "[交接] 修復了有時任務無法正常接取完成的問題",
            "[美化皮膚] 優化了拍賣行皮膚.",
            "[美化皮膚] 優化了暴雪 UI 組件皮膚.",
            "[美化皮膚] 優化了彈出通知皮膚.",
            "[美化皮膚] 優化了 Immersion 皮膚.",
            "[美化皮膚] 修復了任務物品按鍵的陰影.",
            "[美化皮膚] 修復了額外物品投擲框架的陰影.",
            "[移動框架] 新增一個選項用於提升與 Trade Skill Master 的相容性.",
            "[吸收] 修復了戰鬥中重載介面可能導致的汙染.",
            "[切換按鍵] 新增了功能浮動提示."
        },
        ["enUS"] = {
            "[Tags] The tag: smart-power and smart-power-long will use integer.",
            "[Announcement] (Quest) Optimized quest progress info display.",
            "[Context Menu] Fixed a bug in stats report.",
            "[Super Tracker] Bacause it may cause taint, the option of only number has been removed.",
            "[Turn In] Fixed a bug that sometimes the module can not accept or complete quests.",
            "[Skins] Optimized Auction House skin.",
            "[Skins] Optimized Blizzard UI Widgets skin.",
            "[Skins] Optimized alerts skin.",
            "[Skins] Optimized Immersion skin.",
            "[Skins] Fixed the shadow of quest item button.",
            "[Skins] Fixed the shadow of bonus roll frame.",
            "[Move Frames] New option to improve compatibility with Trade Skill Master.",
            "[Absorb] Fixed a bug that the module may cause taint if reload ui in combat.",
            "[Switch Buttons] Add tooltips for buttons."
        },
        ["koKR"] = {
            "[태그] smart-power와 smart-power-long은 이제 정수를 고정적으로 사용합니다.",
            "[알림] (퀘스트) 작업 진행 정보 표시를 최적화했습니다.",
            "[우클릭 메뉴] stats report 버그 수정.",
            "[슈퍼 트래커] 오류 가능성으로 인해 숫자 전용 옵션이 제거되었습니다.",
            "[자동 수락] 간혹 퀘스트가 정상적으로 완료되지 않던 문제를 수정하였습니다.",
            "[스킨] 경매장 스킨 최적화.",
            "[스킨] Blizzard UI Widgets 스킨 최적화.",
            "[스킨] 알림 프레임 스킨 최적화.",
            "[스킨] Immersion 스킨 최적화.",
            "[스킨] 퀘스트 아이템 버튼 그림자 수정.",
            "[스킨] 추가 전리품 주사위 프레임 그림자 수정.",
            "[프레임 이동] Trade Skill Master와의 호환성을 향상시키는 옵션이 추가되었습니다.",
            "[피해흡수] 전투 중 인터페이스를 다시 로드하여 발생할 수 있는 오류를 수정했습니다.",
            "[스위치 버튼] 버튼에 대한 툴팁 추가."
        }
    }
}
