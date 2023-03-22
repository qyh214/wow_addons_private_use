local W = unpack((select(2, ...)))

W.Changelog[217] = {
    RELEASE_DATE = "2021/02/02",
    IMPORTANT = {
        ["zhCN"] = {
            "俄语翻译大幅更新. 感谢 Evgeniy-ONiX",
            "新增了对西班牙语和葡萄牙语的支持. 任何翻译问题可随时来 Discord 反馈."
        },
        ["zhTW"] = {
            "俄語翻譯大幅更新. 感謝 Evgeniy-ONiX",
            "支援西班牙語及葡萄牙語. 任何翻譯問題可隨時來 Discord 進行回報."
        },
        ["enUS"] = {
            "Russian translation updated. Thanks Evgeniy-ONiX",
            "Add basic support for Spanish and Portuguese. You can report the translation problem in our Discord anytime."
        },
        ["koKR"] = {
            "러시아어 번역 업데이트. Thanks Evgeniy-ONiX",
            "스페인어 및 포르투갈어에 대한 지원을 추가합니다. 번역 관련 문제는 언제든지 Discord로 알려주시기 바랍니다."
        }
    },
    NEW = {
        ["zhCN"] = {
            "添加了部分 ElvUI 內英文字体.",
            "添加了一个 Light 材质.",
            "[通告] 添加了新史诗钥石的通报.",
            "[美化皮肤] 添加了新的 UI 组件美化. (比如: 赎罪老一充能)",
            '[额外物品条] 添加了 "OPENABLE" (可打开物品) 物品分类.',
            "[进度] 新增了对 [暗影国度钥石大师: 第一赛季] 的追踪."
        },
        ["zhTW"] = {
            "添加了部分 ElvUI 內英文字型.",
            "新增了一個 Light 材質.",
            "[通告] 新增了新傳奇鑰石通報.",
            "[美化皮膚] 新增了 UI 組件美化. (比如: 贖罪一王充能)",
            '[額外物品條] 新增了 "OPENABLE" (可開啟物品) 物品分組.',
            "[進度] 新增了對 [暗影之境鑰石王: 第一季] 的追蹤."
        },
        ["enUS"] = {
            "Add some English fonts from ElvUI for non-english users.",
            "Add a new statusbar texture.",
            "[Announcement] Add support for new keystone announcement.",
            "[Skins] Add new skins for UI widget. (e.g. charge of HoS first boss)",
            '[Extra Item Bar] Add new item group "OPENABLE" (openable items).',
            "[Progression] Add the tracker for [Shadowlands Keystone Master: Season One]."
        },
        ["koKR"] = {
            "영어를 사용하지 않는 사용자를 위해 ElvUI의 영어 폰트 일부를 추가하였습니다.",
            "새로운 상태 바 텍스처를 추가하였습니다.",
            "[알림] 쐐기돌 획득 알림을 추가하였습니다.",
            "[스킨] 새로운 UI 위젯 추가 (예: 속죄의 전당 1넴 할리아스의 령 충전)",
            '[아이템 바] 새로운 아이템 그룹 "OPENABLE" (열 수 있는 아이템) 을 추가하였습니다.',
            "[진행상태] [어둠땅 쐐기돌 장인: 1 시즌] 위업을 추적할 수 있는 기능이 추가되었습니다."
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "优化设定文本.",
            "[通告] 韩语客户端中宠物主人现在可以被正确识别.",
            "[通告] 修复了宠物打断无法通告的问题.",
            "[通告] 修复了有时重复通告的问题.",
            "[进度] 移除了过时的副本.",
            "[游戏条] 禁止战斗中开启日历造成污染.",
            "[游戏条] 家按钮的鼠标提示将会显示物品可用次数.",
            "[额外物品条] 更新托加斯特物品列表.",
            "[额外物品条] 优化了条更新的逻辑.",
            "[额外物品条] 永冬护符将默认加入黑名单.",
            '[美化皮肤] 修复了设定能量条为"偏移"风格时, 阴影位置不正确的问题.',
            "[移动框体] 盟约指挥桌框架现在可以被移动了."
        },
        ["zhTW"] = {
            "優化設定文字.",
            "[通告] 韓文客戶端中寵物主人現可被正確識別.",
            "[通告] 修復了寵物打斷無法通告的問題.",
            "[通告] 修復了有時重複通告的問題.",
            "[進度] 移除了過時的副本.",
            "[遊戲條] 禁止在戰鬥中開啟行事曆導致污染.",
            "[遊戲條] 家按鍵的浮動提示將會顯示物品的可用次數.",
            "[額外物品條] 更新托伽司物品列表.",
            "[額外物品條] 優化了條更新的邏輯.",
            "[額外物品條] 恆冬符咒將默認加入黑名單.",
            '[美化皮膚] 修復了設定能量條為"偏移"風格的時候, 陰影位置不正確的問題.',
            "[移動框架] 誓盟指揮台框架現在可以被移動了."
        },
        ["enUS"] = {
            "Edited some option description.",
            "[Announcement] The owner of the pet can be recognized correctly in Korean client.",
            "[Announcement] Fix the announcement of the interrupts by pets.",
            "[Announcement] Fix announcement sent by multiple users.",
            "[Progression] Remove outdated instances.",
            "[Game Bar] Prevent the taint by toggling calendar in combat.",
            "[Game Bar] Add charge information into the tooltip of Home button.",
            "[Extra Item Bar] Update Torghast item list.",
            "[Extra Item Bar] Optimize the update of bars.",
            "[Extra Item Bar] Charm of Eternal Winter will be added in blacklist by default.",
            '[Skins] Fix the issue that the shadow not in right place with the ElvUI power bar in "OFFSET" style.',
            "[Move Frames] Add support of moving covenant mission frame."
        },
        ["koKR"] = {
            "일부 옵션의 설명을 수정했습니다.",
            "[알림] 한국 클라이언트에서 하수인의 주인을 정확하게 인식할 수 있습니다.",
            "[알림] 하수인에 의한 차단 알림을 수정했습니다.",
            "[알림] 가끔 반복되는 알림 문제를 수정했습니다.",
            "[진행상태] 오래된 인스턴스를 삭제했습니다.",
            "[게임 바] 전투 중 달력을 열수 없도록 수정하였습니다.",
            "[게임 바] 홈 버튼의 툴팁에 사용 가능한 개수를 표시합니다.",
            "[아이템 바] 토르가스트 아이템 리스트를 업데이트하였습니다.",
            "[아이템 바] 업데이트 로직을 최적화했습니다.",
            "[아이템 바] 사냥꾼 알티모르의 드롭 아이템 영원한 겨울의 부적 목걸이는 기본적으로 블랙리스트에 추가됩니다.",
            '[스킨] ElvUI 파워 바를 "OFFSET"스타일로 설정했을 때 그림자 위치가 잘못되던 문제를 수정했습니다.',
            "[프레임 이동] 성약단 임무 탁자의 프레임 이동을 추가하였습니다."
        }
    }
}
