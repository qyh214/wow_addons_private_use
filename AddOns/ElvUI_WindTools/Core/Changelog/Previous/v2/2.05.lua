local W = unpack((select(2, ...)))

W.Changelog[205] = {
    RELEASE_DATE = "2020/10/29",
    IMPORTANT = {
        ["zhCN"] = {
            "感谢 헬리오스의방패, 불광불급옹, 다크어쎄신 及 크림슨프릴 的辛苦付出, 韩语已经获得全面的支持.",
            "支持使用 MerathilisUI 皮肤模块美化 Wind 工具箱内的模块窗口.",
            "修复且优化了默认配置 (Fang2houUI) 的导入. 你可以在 [信息]-[重置] 中找到它.",
            "[美化皮肤] 添加了全新的字体子模块.",
            "[通告] 嘲讽通告和任务通告默认关闭."
        },
        ["zhTW"] = {
            "感謝 헬리오스의방패, 불광불급옹, 다크어쎄신 及 크림슨프릴 的辛苦付出, 韓文已獲得完整支援.",
            "支援 MerathilisUI 皮膚模組美化 Wind 工具箱內的模組窗口",
            "修復且優化了默認配置 (Fang2houUI) 的導入. 你可以在 [信息]-[重置] 中找到它.",
            "[美化皮膚] 新增了全新的字體子模組.",
            "[通告] 嘲諷通告和任務通告默認關閉."
        },
        ["enUS"] = {
            "Thanks to the excellent work by 헬리오스의방패, 불광불급옹, 다크어쎄신 and 크림슨프릴. Korean is now fully supported.",
            "Add support of MerathilisUI Skins on frames created by WindTools.",
            "Fixed and updated the default profile (Fang2houUI) importing. You can find it in [Information]-[Reset].",
            "[Skins] Add new font submodule.",
            "[Announcement] The default setting of Taunt and Quest will be disabled."
        },
        ["koKR"] = {
            "이제 한국어가 완전히 지원됩니다. 헬리오스의방패, 불광불급옹, 다크어쎄신, 크림슨프릴의 훌륭한 작업 덕분입니다.",
            "WindTools의 모듈 프레임에 MerathilisUI 스킨 지원을 추가합니다.",
            "기본 프로필 (Fang2houUI) 가져오기를 수정하고 업데이트했습니다. [정보]-[리셋]에서 확인할 수 있습니다.",
            "[스킨] 새로운 글꼴 서브 모듈을 추가합니다.",
            "[알림] 도발 및 퀘스트의 기본 설정이 비활성화로 변경되었습니다."
        }
    },
    NEW = {
        ["zhCN"] = {
            "[装备观察] 添加了字体风格的选项.",
            "[交接] 添加了自动跳过过场动画的功能和选项.",
            "[美化皮肤] 添加了飞出动作条按钮的美化.",
            "[美化皮肤] 添加了 Bigwigs 进入副本倒计时美化.",
            "[美化皮肤] 添加了克罗米时间线选择框体美化.",
            "[美化皮肤] 添加了艾泽里特特质重置框体美化.",
            "[美化皮肤] 添加了艾泽里特特质装备框体美化.",
            "[美化皮肤] 添加了离开载具按钮美化.",
            "[天赋管家] 添加了物品按钮到天赋面板.",
            "[游戏条] 添加了音量按钮.",
            "[游戏条] 添加了专业技能按钮."
        },
        ["zhTW"] = {
            "[裝備觀察] 新增了字體風格的設定.",
            "[交接] 新增了自動跳過過場動畫的功能和設定.",
            "[美化皮膚] 新增了飛出快捷列按鍵的美化.",
            "[美化皮膚] 新增了 Bigwigs 進入副本倒計時美化.",
            "[美化皮膚] 新增了克羅米時間線選擇框架美化.",
            "[美化皮膚] 新增了艾澤里特特質重置框架美化.",
            "[美化皮膚] 新增了艾澤里特特質裝備框架美化.",
            "[美化皮膚] 新增了離開載具按鍵美化.",
            "[天賦管家] 新增了物品按鍵到天賦面板.",
            "[遊戲條] 新增了音量按鍵.",
            "[遊戲條] 新增了專業技能按鍵."
        },
        ["enUS"] = {
            "[Inspect] Add options of font styles.",
            "[Turn In] Add the feature and options for auto-skip cut scene.",
            "[Skins] Add skin for flyout action buttons.",
            "[Skins] Add skin for Bigwigs queue timer.",
            "[Skins] Add skin for Chromie Time.",
            "[Skins] Add skin for Azerite empowered item.",
            "[Skins] Add skin for Azerite Respec.",
            "[Skins] Add skin for Vehicle Leave Button.",
            "[Talent Manager] Add item buttons to talent frame.",
            "[Game Bar] Add Volume button.",
            "[Game Bar] Add Profession button."
        },
        ["koKR"] = {
            "[살펴보기] 글꼴 스타일 옵션을 추가합니다.",
            "[자동수락] 컷신 자동 넘김 기능과 관련 옵션을 추가합니다.",
            "[스킨] 플라이 아웃 액션 버튼 스킨 추가",
            "[스킨] Bigwigs 큐 타이머 스킨 추가.",
            "[스킨] 크로미의 시간 스킨 추가.",
            "[스킨] 아제라이트 장비 스킨 추가.",
            "[스킨] 아제라이트 재연마 스킨 추가.",
            "[스킨] 탈것 내리기 버튼 스킨 추가.",
            "[특성관리자] 특성 창에 아이템 버튼이 추가되었습니다.",
            "[게임 바] 볼륨 버튼이 추가되었습니다.",
            "[게임 바] 전문 기술 버튼이 추가되었습니다."
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "媒体文件更新.",
            "兼容性检查工具更新.",
            "[游戏条] 现在不会挡住全屏的世界地图了.",
            "[游戏条] 更换了炉石列表的生成逻辑.",
            "[美化皮肤] 优化了跳过过场动画的提示背景美化.",
            "[美化皮肤] 优化了鼠标提示美化.",
            "[装备观察] 优化了人物头像的风格.",
            "[好友列表] 支持新的 COD 游戏.",
            "[切换按键] 修复了不重载界面时按键显示不正确的问题."
        },
        ["zhTW"] = {
            "媒體文件更新.",
            "相容性確認工具更新.",
            "[遊戲條] 現在不會遮擋全屏世界地圖了.",
            "[遊戲條] 更換了爐石列表的生成邏輯.",
            "[美化皮膚] 優化了跳過過場動畫的提示背景美化.",
            "[美化皮膚] 優化了浮動提示美化.",
            "[裝備觀察] 優化了人物頭像的風格.",
            "[好友列表] 支援新的 COD 遊戲.",
            "[切換按鍵] 修復了不重載 UI 時按鍵顯示不正確的問題."
        },
        ["enUS"] = {
            "Media files updated.",
            "Compatibility check updated.",
            "[Game Bar] The world map in full-screen mode will display in front of the game bar.",
            "[Game Bar] New logic for generating the table of HearthStones.",
            "[Skins] Better skin for skip cut scene confirmation dialog.",
            "[Skins] The skin for tooltips have been optimized.",
            "[Inspect] Better style for the portrait.",
            "[Friend List] Add support for new COD game.",
            "[Switch Buttons] Fix the bug that the buttons not display properly without reload."
        },
        ["koKR"] = {
            "미디어 파일이 업데이트되었습니다.",
            "호환성 검사가 업데이트되었습니다.",
            "[게임 바] 이제 전체 화면 모드의 월드 맵을 게임 바가 가리지 않습니다.",
            "[게임 바] 귀환석 목록 생성 로직이 변경되었습니다.",
            "[스킨] 컷신 건너 뛰기 확인 대화 상자의 스킨을 최적화 했습니다.",
            "[스킨] 툴팁 스킨이 최적화되었습니다.",
            "[살펴보기] 캐릭터 초상화 스타일을 최적화했습니다.",
            "[친구 목록] COD(Call of Duty) 게임 지원 추가.",
            "[스위치 버튼] 리로드 하지 않으면 버튼이 제대로 표시되지 않는 버그를 수정합니다."
        }
    }
}
