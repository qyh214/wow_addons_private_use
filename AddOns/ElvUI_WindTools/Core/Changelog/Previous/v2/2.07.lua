local W = unpack((select(2, ...)))

W.Changelog[207] = {
    RELEASE_DATE = "2020/11/05",
    IMPORTANT = {
        ["zhCN"] = {
            "[交接] 跳过过场动画 => [其他] 一般设定-跳过过场动画"
        },
        ["zhTW"] = {
            "[交接] 跳過過場動畫 => [其他] 一般設置-跳過過場動畫."
        },
        ["enUS"] = {
            "[Turn In] Skip Cut Scene => [Misc] General-Skip Cut Scene"
        },
        ["koKR"] = {
            "[자동 수락] 컷신 건너뛰기 설정이 => [기타] 일반 - 컷신 건너뛰기로 이동했습니다."
        }
    },
    NEW = {
        ["zhCN"] = {
            "[美化皮肤] 添加了自定义厚实阴影的支持.",
            "[美化皮肤] 添加了暴雪按键绑定框体美化.",
        },
        ["zhTW"] = {
            "[美化皮膚] 新增了自訂厚實陰影的支援.",
            "[美化皮膚] 新增了暴雪按鍵綁定框架美化.",
        },
        ["enUS"] = {
            "[Skins] Add options for thicker shadow.",
            "[Skins] Add new skin for Blizzard Binding UI."
        },
        ["koKR"] = {
            "[스킨] 그림자 두께 조절 옵션을 추가합니다.",
            "[스킨] 블리자드 단축키 스킨을 추가합니다."
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "清理代码",
            "默认配置优化.",
            "兼容性检查工具更新.",
            "[好友列表] 修复了有时候无法获取名字时的报错.",
            "[好友列表] 修复了游戏图标与召唤按钮重叠的问题.",
            "[其他] 跳过过场动画在跳过后会显示提示, 支持点击链接重播.",
            "[额外物品条] 可以选择继承 ElvUI 全局渐隐了.",
            "[任务列表] 修复了修改风格可能带来的污染.",
            "[切换按钮] 修复了有可能被暴雪追踪框体挡住的问题.",
            "[美化皮肤] 添加天赋界面的图标美化.",
            "[美化皮肤] 微调 ElvUI 额外能量条的文字位置.",
            "[美化皮肤] 移除 ElvUI 按键绑定皮肤.",
            "[移动框体] 重新启用地下城手册的移动.",
            "[游戏条] 修复了音量的鼠标提示.",
            "[天赋管家] 在传送后自动更新专精.",
            "[聊天条] 修复了一个潜在的错误.",
            "[聊天链接] 修复了一个潜在的错误.",
            "[世界地图] 更新了迷雾去除数据库.",
            "[世界地图] 修复了部分地区因为迷雾去除无法显示地图的错误.",
        },
        ["zhTW"] = {
            "清理代碼",
            "默認配置優化",
            "相容性確認工具更新.",
            "[好友名單] 修復了有時無法獲取名字時的報錯.",
            "[好友名單] 修復了遊戲圖示與召喚按鈕重疊的問題.",
            "[其他] 跳過過場動畫在跳過後會顯示提示, 支持點擊鏈接重播.",
            "[額外物品條] 可以選擇繼承 ElvUI 全局漸隱了.",
            "[任務列表] 修復了修改風格可能帶來的污染.",
            "[切換按鈕] 修復了有可能被暴雪追蹤框架擋住的問題.",
            "[美化皮膚] 新增了天賦介面的圖示美化.",
            "[美化皮膚] 微調 ElvUI 額外能量條的文字位置.",
            "[美化皮膚] 移除 ElvUI 按鍵綁定皮膚.",
            "[移動框架] 重新啟用地下城手冊的移動.",
            "[遊戲條] 修復了音量的浮動提示.",
            "[天賦管家] 在傳送後自動更新專精.",
            "[聊天條] 修復了一個潛在的錯誤.",
            "[聊天鏈接] 修復了一個潛在的錯誤.",
            "[世界地圖] 更新了迷霧去除數據庫.",
            "[世界地圖] 修復了部分地區因為迷霧去除無法顯示地圖的錯誤."
        },
        ["enUS"] = {
            "Cleanup codes.",
            "Update default profile.",
            "Update compatibility check.",
            "[Friend List] Fix the bug occurred if the name cannot be obtained.",
            "[Friend List] Fix the bug that the summon button and game icon are overlapped.",
            "[Misc] Skip Cut Scene will display a message after skipping, you can click the link inside the message to replay the cut scene.",
            "[Extra Item Bar] Now you can choose to inherit the ElvUI global fade.",
            "[Objective Tracker] Fix the taint by changing style.",
            "[Switch Buttons] Fix the bug that sometimes it might be hidden by Blizzard Objective Tracker.",
            "[Skins] Apply new role icons in Talent UI.",
            "[Skins] Modify the position of text in ElvUI alt power bar.",
            "[Skins] Remove the skin for ElvUI key binding frame.",
            "[Move Frames] Reenable the moving of encounter journal.",
            "[Game Bar] Fix the tooltip of volume.",
            "[Talent Manager] Auto-update the spec after transport.",
            "[Chat Bar] Fix a potential bug.",
            "[Chat Link] Fix a potential bug.",
            "[World Map] Update reveal database.",
            "[World Map] Fix the bug that the reveal not worked on several areas."
        },
        ["koKR"] = {
            "코드 정리.",
            "기본 프로필 업데이트.",
            "호환성 검사 업데이트.",
            "[친구 목록] 가끔 이름을 얻을 수 없는 오류를 수정했습니다.",
            "[친구 목록] 게임 아이콘과 파티초대 버튼이 겹치는 현상을 수정하였습니다.",
            "[기타] 컷신을 건너뛰면 메시지가 표시되며 링크를 클릭하여 리플레이할 수 있습니다.",
            "[아이템 바] ElvUI의 페이드 설정을 상속 하도록 선택할 수 있습니다.",
            "[퀘스트 추적기] 스타일 수정으로 발생할 수 있는 오염 문제 수정",
            "[스위치 버튼] 블리자드 기본 퀘스트 추적기에 의해 차단될 수 있는 문제를 수정했습니다.",
            "[스킨] 특성 UI에 새로운 역할 아이콘을 적용합니다.",
            "[스킨] ElvUI 특수 자원 바의 텍스트의 위치를 미세 조정하였습니다.",
            "[스킨] ElvUI 단축키 스킨을 제거했습니다.",
            "[프레임 이동] 모험 안내서 창 이동을 다시 활성화했습니다.",
            "[게임 바] 볼륨의 툴팁을 수정합니다.",
            "[특성 관리자] 전문화 변경 시 자동으로 업데이트됩니다.",
            "[채팅 바] 잠재적인 버그를 수정했습니다.",
            "[채팅 링크] 잠재적인 버그를 수정했습니다.",
            "[월드 맵] 안개 제거 데이터베이스 업데이트.",
            "[월드 맵] 안개 제거로 인해 일부 지역에서 지도가 표시되지 않는 버그를 수정했습니다."
        }
    }
}
