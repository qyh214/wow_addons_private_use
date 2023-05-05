local W = unpack((select(2, ...)))

W.Changelog[234] = {
    RELEASE_DATE = "2022/05/07",
    IMPORTANT = {
        ["zhCN"] = {
            "插件设计风格焕新.",
            "新增意大利语支持.",
            "[移动框体] 配置文件表位置更改, 更新后会自动拷贝旧配置并清理."
        },
        ["zhTW"] = {
            "插件設計風格更新.",
            "新增義大利語支援.",
            "[移動框架] 配置文件表位置更改, 更新後會自動拷貝舊配置並清理."
        },
        ["enUS"] = {
            "Updated the overall designs.",
            "Added Italian language support.",
            "[Move Frames] The location of settings are changed, the old settings will be copied and cleaned."
        },
        ["koKR"] = {
            "전반적인 디자인을 업데이트했습니다.",
            "이탈리아어 지원 추가.",
            "[프레임 이동] 설정 위치가 변경되면 이전 구성이 자동으로 복사되어 정리됩니다."
        }
    },
    NEW = {
        ["zhCN"] = {
            "新增模块: [吸收], 可以自定义 ElvUI 吸收盾材质, 同时增加暴雪风格的吸收火花.",
            "[美化皮肤] 新增 TomCat's Tour 皮肤.",
            "[静音] 新增了全种族哭声的静音.",
            "[静音] 新增了永恒者的挽歌的静音.",
            "[进度追踪] 支持自定义顶部文字颜色.",
            "[进度追踪] 新增了装饰条功能, 默认开启.",
            "[其他] 新增了显示键位于冷却动画之上的功能.",
            "[其他] 新增了在公会新闻中显示物品等级的功能.",
            "[聊天链接] 新增了翻译物品名称的功能."
        },
        ["zhTW"] = {
            "新增模組: [吸收], 可以自定義 ElvUI 吸收盾材質, 同時增加暴雪風格的吸收火花.",
            "[美化皮膚] 新增 TomCat's Tour 美化.",
            "[靜音] 新增了全種族哭聲的靜音.",
            "[靜音] 新增了永恆輓歌的靜音.",
            "[進度追蹤] 支援自定義頂部文字顏色.",
            "[進度追蹤] 新增了裝飾條功能, 預設開啟.",
            "[其他] 新增了顯示鍵位於冷卻動畫之上的功能.",
            "[其他] 新增了在公會新聞中顯示物品等級的功能.",
            "[聊天鏈接] 新增了翻譯物品名稱的功能."
        },
        ["enUS"] = {
            "New module [Absorb], you can customize the texture of ElvUI absorb shield, and add Blizzard style absorb spark.",
            "[Skin] Added a new skin for TomCat's Tour.",
            "[Mute] Added a new option for crying sounds of all races.",
            "[Mute] You can mute Elegy of the Eternals sound effect now.",
            "[Objective Tracker] Support customize the color of header text.",
            "[Objective Tracker] Add new feature of cosmetic bar. It is ON by default.",
            "[Misc] Added a new option to show action bar hotkey above the cooldown animation.",
            "[Misc] Added a new option to show item level in guild news.",
            "[Chat Link] Added a new feature for translating item name in links into your language."
        },
        ["koKR"] = {
            "새로운 모듈 [피해흡수], ElvUI 유닛프레임 체력바의 피해흡수 텍스처를 커스터마이징 할 수 있으며, 블리자드 스타일의 효과를 추가할 수 있습니다.",
            "[스킨] TomCat's Tour 스킨 추가.",
            "[음소거] 모든 종족의 울음 소리를 음소거 옵션에 추가하였습니다.",
            "[음소거] 영원한 존재의 비가의 사운드 효과를 음소거 옵션에 추가하였습니다.",
            "[퀘스트 추적기] 제목 글자색을 커스터마이징 할 수 있습니다.",
            "[퀘스트 추적기] 새로운 기능인 장씩띠를 추가하였습니다. 기본적으로 활성화되어 있습니다.",
            "[기타] 쿨다운 애니메이션 위에 액션 바 단축키를 표시하는 새로운 옵션을 추가했습니다.",
            "[기타] 길드 새 소식에 아이템 레벨을 표시하는 기능이 추가되었습니다.",
            "[채팅 링크] 링크의 아이템 명을 플레이어의 언어로 번역하는 새로운 기능을 추가했습니다."
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "优化了部分设定项的显示",
            "优化了更新助手.",
            "配置重置模块更新.",
            "[移动框体] 按住冒险手册中的 Boss 模型不再进行移动.",
            "[装备观察] 重新采集并整合了数据, 当前版本应该不会有任何的附魔效果被遗漏了.",
            "[装备观察] 不再显示副手物品的附魔提示.",
            "[交接] 大幅优化了模块代码.",
            "[交接] 支持自定义暂停修饰键.",
            "[交接] 支持仅开启接受任务或仅开启完成任务.",
            "[交接] 新增了自动选择最高奖励物品并完成任务的功能.",
            "[交接] 新增了智能聊天选项功能, 同时并入原有的盗贼职业大厅传送功能.",
            "[巅峰声望] 大幅优化了模块代码.",
            "[巅峰声望] 导入了 PR 的最新的阵营数据和奖励物品数据.",
            "[美化皮肤] 修复了跳过动画框体的阴影.",
            "[美化皮肤] 修复了举报玩家框体的阴影.",
            "[美化皮肤] 修复了灵魂医者框体的阴影.",
            "[美化皮肤] 修复了分离物品框体的阴影.",
            "[美化皮肤] 优化了冒险手册的皮肤.",
            "[游戏条] 立即截图时会自动隐藏鼠标提示.",
            "[游戏条] 修复了 Ctrl + Shift + 点击时间区域无法开启 CPU 占用统计的问题.",
            "[额外物品条] 新增了圣墓宝物箱(英雄难度). 感谢 mcc1",
            "[小地图按钮] 新增了对 TomCat's Tour 的特别优化.",
            "[静音] 为闷燃之心选项添加更多声音 ID."
        },
        ["zhTW"] = {
            "優化了部分設置項的顯示.",
            "優化了更新助手.",
            "重置模組功能更新.",
            "[移動框架] 按住冒險手冊中的首領模型不再進行移動.",
            "[裝備觀察] 重新采集並整合了數據, 当前版本應該不會有任何的附魔效果被遺漏了.",
            "[裝備觀察] 不再顯示副手物品的附魔提示.",
            "[交接] 大幅優化了模組代碼.",
            "[交接] 支援自訂暫停修飾鍵.",
            "[交接] 支援仅啟用接受任務或仅啟用完成任務.",
            "[交接] 新增了自動選擇最高獎勵物品並完成任務的功能.",
            "[交接] 新增了智能聊天選項功能, 同時也并入原有的盜賊職業大廳傳送功能.",
            "[巅峰聲望] 大幅優化了模組代碼.",
            "[巅峰聲望] 匯入了 PR 的最新的陣營數據和獎勵物品數據.",
            "[美化皮膚] 修復了跳過動畫框架的陰影.",
            "[美化皮膚] 修復了舉報玩家框架的陰影.",
            "[美化皮膚] 修復了靈魂醫者框架的陰影.",
            "[美化皮膚] 修復了分離物品框架的陰影.",
            "[美化皮膚] 優化了冒險手冊的皮膚.",
            "[游戏條] 立即截圖時會自動隱藏浮動提示.",
            "[游戏條] 修復了 Ctrl + Shift + 點擊時間區域無法開啟 CPU 占用統計的問題.",
            "[額外物品條] 新增了聖塚寶藏箱(英雄難度). 感謝 mcc1",
            "[小地圖按鈕] 新增了對 TomCat's Tour 的特別優化.",
            "[靜音] 為燃心新增更多音效 ID."
        },
        ["enUS"] = {
            "Improved some options.",
            "Improved upgrade assistant.",
            "Update the module reset buttons with latest changes.",
            "[Move Frames] The encounter journal will not be moved when you checking the boss model.",
            "[Inspect] Rebuild the enchantment database, there is no enchantment lost anymore.",
            "[Inspect] No longer show the enchantment icon on the offhand item.",
            "[Turn In] Greatly optimized module code.",
            "[Turn In] Support customization of pause modifier key.",
            "[Turn In] Support only auto-accepting or only auto-completing.",
            "[Turn In] New feature: Get Best Reward, completing the quest with the most valuable reward.",
            "[Turn In] New feature: Smart Chat, also included the old option of Rogue Class Hall Insignia.",
            "[Paragon Reputation] Greatly optimized module code.",
            "[Paragon Reputation] Imported latest reputation data and reward item data from PR.",
            "[Skin] Fixed the shadow of the skip cutscene frame.",
            "[Skin] Fixed the shadow of the report player frame.",
            "[Skin] Fixed the shadow of the spirit healer frame.",
            "[Skin] Fixed the shadow of the separate item frame.",
            "[Skin] Optimized the skin of encounter journal.",
            "[Game Bar] Automatically hide the tooltip when taking a screenshot.",
            "[Game Bar] Fixed the issue of Ctrl + Shift + click on the time area.",
            "[Extra Item Bar] Added cache of sepulcher treasures (Heroic). Thanks mcc1",
            "[Minimap Buttons] Added some special rules for TomCat's Tour.",
            "[Mute] Added more sound ID for Smolderheart."
        },
        ["koKR"] = {
            "일부 설정 항목의 표시 최적화.",
            "업데이트 도우미 최적화.",
            "구성 재설정 모듈 업데이트.",
            "[프레임 이동] 던전 도감에서 모델 탭을 눌러 보스를 확인하고 있는 경우에는 움직이지 않습니다.",
            "[살펴보기] 마법부여 데이터베이스를 재구축 하였습니다. 더 이상 잃어버린 마법은 없습니다.",
            "[살펴보기] 더 이상 보조 아이템에 마법 부여 아이콘을 표시하지 않습니다.",
            "[자동 수락] 모듈 코드 최적화. ",
            "[자동 수락] 사용자 정의 일시 중지 키를 지원합니다.",
            "[자동 수락] 자동 수락 또는 자동 완료만 지원합니다.",
            "[자동 수락] 새로운 기능: 최고 보상 획득은 가장 높은 보상 아이템을 자동으로 선택하고 퀘스트를 완료합니다.",
            "[자동 수락] 새로운 기능: 스마트 채팅에는 도적 클래스의 직업 전당 이동시 자동 선택 옵션도 포함되어 있습니다.",
            "[불멸의 동맹] 모듈 코드가 크게 향상되었습니다.",
            "[불멸의 동맹] 불멸의 동맹의 최신 평판 데이터 및 보상 아이템 데이터를 가져왔습니다.",
            "[스킨] 컷신 건너뛰기 프레임의 그림자 수정.",
            "[스킨] 플레이어 신고 창의 그림자 수정.",
            "[스킨] 영혼의 치유사 프레임의 그림자 수정.",
            "[스킨] 아이템 분리 창의 그림자 수정.",
            "[스킨] 던전도감 스킨 최적화.",
            "[게임 바] 스크린샷을 찍을 때 마우스 툴팁이 자동으로 숨겨집니다.",
            "[게임 바] Ctrl + Shift + 시계를 클릭하면 CPU 사용량 통계가 활성화되지 않는 문제가 수정되었습니다.",
            "[아이템 바] 올리아 보관함(영웅 난이도)이 추가되었습니다. Thanks mcc1",
            "[미니맵 버튼 통합 바] TomCat's Tour에 대한 몇 가지 특별한 규칙을 추가했습니다.",
            "[음소거] 이글심장 옵션에 더 많은 사운드 ID를 추가했습니다."
        }
    }
}
