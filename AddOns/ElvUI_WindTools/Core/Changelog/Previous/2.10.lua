local W = unpack((select(2, ...)))

W.Changelog[210] = {
    RELEASE_DATE = "2020/11/17",
    IMPORTANT = {
        ["zhCN"] = {
            "[美化皮肤] 重写部分美化核心函数, 如果遇到问题请报告."
        },
        ["zhTW"] = {
            "[美化皮膚] 重寫部分美化核心參數, 如果遇到問題請報告."
        },
        ["enUS"] = {
            "[Skins] Rewrite some core functions, please let me know if the skins not working properly."
        },
        ["koKR"] = {
            "[스킨] 일부 핵심 기능을 다시 작성하였습니다. 스킨이 제대로 작동하지 않는 경우 알려주세요."
        }
    },
    NEW = {
        ["zhCN"] = {
            "[美化皮肤] 添加了 Rematch 的美化.",
            "[世界地图] 添加了标记后自动进行追踪功能.",
            "[世界地图] 添加了右键标记清除功能.",
            "[团队标记] 添加了隐藏鼠标提示的功能."
        },
        ["zhTW"] = {
            "[美化皮膚] 新增了 Rematch 的美化.",
            "[世界地圖] 新增了標記後自動進行追蹤功能.",
            "[世界地图] 新增了右鍵標記清除功能.",
            "[團隊標記] 新增了隱藏浮動提示的功能."
        },
        ["enUS"] = {
            "[Skins] Add new skin for Rematch.",
            "[World Map] Add new feature that auto-tracking the waypoint after setting.",
            "[World Map] Add new feature that right clicking the waypoint to clear it.",
            "[Raid Markers] Add new option for disabling tooltip."
        },
        ["koKR"] = {
            "[스킨] Rematch 애드온 스킨 추가.",
            "[월드맵] 지도 핀을 배치하면 즉시 추적하여 화면에 표시하는 기능을 추가합니다.",
            "[월드맵] 지도 핀을 마우스 오른쪽 클릭으로 삭제하는 기능을 추가합니다.",
            "[공격대 징표] 툴팁을 비활성화하는 옵션을 추가합니다."
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "[预组队伍] 修复条显示不正确的问题.",
            "[小地图图标] 以新风格兼容 Narcissus 图标, 如果你不喜欢可以在 Narcissus 设置中取消加入条.",
            "[美化皮肤] 优化了 WeakAuras 设定美化的性能.",
            "[美化皮肤] 优化了帮助框体的美化.",
            "[美化皮肤] 优化了成就框体的美化.",
            "[美化皮肤] 优化了理发店框体的美化.",
            "[美化皮肤] 优化了要塞框体的美化.",
            "[美化皮肤] 优化了好友界面的美化.",
            "[美化皮肤] 优化了社区界面的美化.",
            "[美化皮肤] 优化了 PVE 界面的美化.",
            "[美化皮肤] 优化了鼠标提示的美化.",
            "[美化皮肤] 优化了 WeakAuras 设定的美化.",
            "[通告] 单人情况下部分设定默认不再通报.",
            "[通告] 由于 API 限制, 说和大喊频道将会在不可用时自动转换为输出到聊天框.",
            "[通告] 队伍中时不再通报非队伍成员的行为.",
            "[通告] 修复随机队伍中不通报的问题.",
            "[额外物品条] 宠物对战时自动隐藏.",
            "[切换按钮] 就算不随任务列表自动显示隐藏, 也会在宠物对战时进行隐藏."
        },
        ["zhTW"] = {
            "[預組隊伍] 修復條顯示不正確的問題.",
            "[小地圖圖標] 以新風格兼容 Narcissus 圖標, 如果你不喜歡可以在 Narcissus 設置中取消加入條.",
            "[美化皮膚] 優化了 WeakAuras 設定美化的性能.",
            "[美化皮膚] 優化了帮助框架美化.",
            "[美化皮膚] 優化了成就框架美化.",
            "[美化皮膚] 優化了理髮店框架美化.",
            "[美化皮膚] 優化了要塞框架美化.",
            "[美化皮膚] 優化了好友框架美化.",
            "[美化皮膚] 優化了社群框架美化.",
            "[美化皮膚] 優化了 PVE 框架美化.",
            "[美化皮膚] 優化了浮動提示美化.",
            "[美化皮膚] 優化了 WeakAuras 設定美化.",
            "[通告] 單人情況下部分設定默認不再通報.",
            "[通告] 由於 API 限制, 說和大喊頻道將會在不可用時自動轉換為輸出到聊天框.",
            "[通告] 隊伍中時不再通報非隊伍成員的行為.",
            "[通告] 修復隨機隊伍中不通報的問題.",
            "[額外物品條] 寵物對戰時自動隱藏.",
            "[切換按鍵] 就算不設定隨任務追蹤自動顯隱, 也會在寵物對戰時隱藏."
        },
        ["enUS"] = {
            "[LFG List] Fix the bug that the line does not hide properly.",
            "[Minimap Buttons] Handle Narcissus icon with the new style, you can disable handling in Narcissus configuration if you want.",
            "[Skins] Optimize the performance of WeakAuras Options skins.",
            "[Skins] Optimize Help skin.",
            "[Skins] Optimize Achievement skin.",
            "[Skins] Optimize Barbershop skin.",
            "[Skins] Optimize Garrison skin.",
            "[Skins] Optimize Friends skin.",
            "[Skins] Optimize Communities skin.",
            "[Skins] Optimize PVE frame skin.",
            "[Skins] Optimize tooltips skin.",
            "[Skins] Optimize WeakAura Options skin.",
            "[Announcement] Change the default channel setting of solo to NONE.",
            "[Announcement] Because the limitation of API, say and yell now will be convert to self when you not in the instance.",
            "[Announcement] Do not announce actions from the player who is not in your party anymore.",
            "[Announcement] Fix the bug that the module not work in LFG group.",
            "[Extra Item Bar] Auto hide on pet battle.",
            "[Switch Buttons] Even if not set to hide with objective tracker, the buttons will also hide on pet battle."
        },
        ["koKR"] = {
            "[파티 찾기 목록] 클래스 라인이 잘못 표시되는 문제를 수정합니다.",
            "[미니맵 버튼 통합 바] 새로운 스타일의 Narcissus 아이콘과 호환되며 마음에 들지 않으면 Narcissus 설정에서 사용을 취소할 수 있습니다.",
            "[스킨] 위크오라 옵션 스킨의 성능을 최적화합니다.",
            "[스킨] 도움말 스킨 최적화.",
            "[스킨] 업적 스킨 최적화.",
            "[스킨] 미용실 스킨 최적화.",
            "[스킨] 주둔지 스킨 최적화.",
            "[스킨] 친구목록 스킨 최적화.",
            "[스킨] 커뮤니티 스킨 최적화.",
            "[스킨] PVE 프레임 스킨 최적화.",
            "[스킨] 툴팁 스킨 최적화.",
            "[스킨] 위크오라 옵션 스킨 최적화.",
            "[알림] 솔로 플레이 상황에서 일부 설정은 기본적으로 알림을 받지 않도록 변경하였습니다.",
            "[알림] API의 한계로 인하여 플레이어가 인스턴스에 있지 않을 때 일반, 외치기는 나에게(채팅창)으로 변환됩니다.",
            "[알림] 같은 파티원이나 공격대원이 아닌 다른 플레이어의 행동은 알리지 않습니다.",
            "[알림] 파티 찾기 그룹에서 모듈이 동작하지 않는 버그를 수정했습니다.",
            "[아이템 바] 애완동물 대전시 자동으로 숨겨집니다.",
            "[스위치 버튼] 자동 숨기기 옵션이 꺼져 있어도 애완동물 대전시에는 버튼이 숨겨집니다."
        }
    }
}
