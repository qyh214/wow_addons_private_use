local W = unpack((select(2, ...)))

W.Changelog[211] = {
    RELEASE_DATE = "2020/11/19",
    IMPORTANT = {
        ["zhCN"] = {
            "支持 9.0.2 游戏版本.",
            "[地图]-[世界地图] 追踪点 => [地图]-[超级追踪].",
            "[删除] 由于暴雪 API 的改动, 按下 Delete 键后现在还需要点击确认."
        },
        ["zhTW"] = {
            "支援 9.0.2 遊戲版本.",
            "[地圖]-[世界地圖] 追蹤點 => [地圖]-[超級追蹤].",
            "[刪除] 由於暴雪 API 的改動, 按下 Delete 鍵後現在仍舊需要點擊確認."
        },
        ["enUS"] = {
            "Support WoW build 9.0.2.",
            "[Maps]-[World Map] Waypoint => [Maps]-[Super Tracker].",
            "[Delete] Due to the change of Blizzard API, after pressing Delete you also need to confirm by click."
        },
        ["koKR"] = {
            "WoW 9.0.2 버전 지원",
            "[지도]-[월드맵]의 <지도 핀> 기능이 [지도]-[슈퍼 트래커]의 새로운 기능으로 변경되었습니다.",
            "[빠른 아이템 파괴] Blizzard API의 변경으로 인해 이제 Delete 키를 누른 후 클릭하여 확인해야 합니다."
        }
    },
    NEW = {
        ["zhCN"] = {
            "[超级追踪] 添加了自定义距离文字的功能.",
            "[超级追踪] 添加了解除追踪距离限制的功能.",
            "[美化皮肤] 添加了公会邀请窗口的美化.",
            "[美化皮肤] 添加了队伍等级同步窗口的美化.",
            "[其他] 添加了获得成就自动截图功能."
        },
        ["zhTW"] = {
            "[超級追蹤] 新增了自訂距離文字的功能.",
            "[超級追蹤] 新增了解除追蹤距離限制的功能.",
            "[美化皮膚] 新增了公會邀請窗口的美化.",
            "[美化皮膚] 新增了隊伍等級同步窗口的美化.",
            "[其他] 新增了獲得成就後自動擷圖的功能."
        },
        ["enUS"] = {
            "[Super Tracker] Add a new feature that custom the distance text.",
            "[Super Tracker] Add a new feature that removes the limitation of track distance.",
            "[Skins] Add new skin for guild invite dialog.",
            "[Skins] Add new skin for party level sync dialog.",
            "[Misc] Add new feature that auto screen shot after you earned an achievement."
        },
        ["koKR"] = {
            "[슈퍼 트래커] 거리 문자를 설정하는 기능을 추가하였습니다.",
            "[슈퍼 트래커] 표시 거리 제한을 해제하는 기능을 추가하였습니다.",
            "[스킨] 길드 초대 대화 상자에 새로운 스킨을 추가하였습니다.",
            "[스킨] 파티 레벨 동기화 대화 상자에 새로운 스킨을 추가하였습니다.",
            "[기타] 업적 달성 시 자동으로 스크린샷을 촬영하는 기능을 추가하였습니다."
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "[交接] 优化了一些逻辑. 感谢 siweia @ NDui.",
            "[美化皮肤] 优化了 Rematch 美化.",
            "[美化皮肤] 优化了 Weakauras 设定美化.",
            "[美化皮肤] 修复了任务物品的美化.",
            "[游戏条] 公会按钮现在可以显示未读提示了.",
            "[任务列表] 修复了部分设定报错.",
            "[游戏条] 好友按钮现在可以在战斗中打开.",
            "[好友列表] 重新制作了游戏图标, 添加 COD CW 及 WoW 暗影国度版本图标.",
            "[装备观察] 装备名对齐."
        },
        ["zhTW"] = {
            "[交接] 優化了一些邏輯. 感谢 siweia @ NDui.",
            "[美化皮膚] 優化了 Rematch 美化.",
            "[美化皮膚] 優化了 Weakauras 設定美化.",
            "[美化皮膚] 修复了任務物品美化.",
            "[遊戲條] 公會按鍵現在可以顯示未讀提示了.",
            "[任務列表] 修復了部分設定報錯.",
            "[遊戲條] 好友按鍵現在可以在戰鬥中開啟介面.",
            "[好友列表] 重新製作了遊戲圖示, 添加 COD CW 及 WoW 暗影之境版本圖示.",
            "[裝備觀察] 裝備名對齊."
        },
        ["enUS"] = {
            "[Turn In] Optimize the logic of auto turn in. Thanks siweia @ NDui",
            "[Skins] Optimize Rematch skin.",
            "[Skins] Optimize Weakauras Options skin.",
            "[Skins] Fix the quest item skin.",
            "[Game Bar] Add an indicator of unread messages to Guild button.",
            "[Objective Tracker] Fix some bugs in options.",
            "[Game Bar] Friend button now can be used in combat.",
            "[Friend List] Renew the game icons, add new icons for COD CW and WoW Shadowlands.",
            "[Inspect] Align equipment name."
        },
        ["koKR"] = {
            "[자동 수락] 자동 수락 로직을 최적화합니다. Thanks siweia @ NDui",
            "[스킨] Rematch 스킨 최적화.",
            "[스킨] 위크오라 옵션 스킨 최적화.",
            "[스킨] 퀘스트 아이템 스킨 수정.",
            "[게임 바] 읽지 않은 길드 메시지가 있는 경우 길드 버튼 위에 알림 아이콘을 표시합니다.",
            "[퀘스트 추적기] 옵션의 일부 버그를 수정하였습니다.",
            "[게임 바] 이제 전투 중에도 친구 버튼을 사용할 수 있습니다.",
            "[친구 목록] 게임 아이콘이 리메이크 되었으며 COD CW(Call of Duty: Black Ops Cold War) 및 WoW 어둠땅 버전 아이콘이 추가되었습니다.",
            "[살펴보기] 장비 이름을 정렬하였습니다."
        }
    }
}
