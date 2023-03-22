local W = unpack((select(2, ...)))

W.Changelog[213] = {
    RELEASE_DATE = "2020/11/28",
    IMPORTANT = {
        ["zhCN"] = {
            "[移动框体] 为避免出错, 记住位置将不再作用于冒险指南.",
            "[额外物品条] 现在默认设置为暗影国度版本的药水合剂和食物, 如果你想要旧版本的, 可以自行在每个条的设定中修改分类群组."
        },
        ["zhTW"] = {
            "[移動框架] 為避免出錯, 記住位置將不再作用於地城導覽手冊.",
            "[額外物品條] 現在默認設置為暗影之境版本的藥水藥劑和食物, 如果想要包括舊版本的, 可以自行在每個條的設定中修改分類群組."
        },
        ["enUS"] = {
            "[Move Frames] To avoid errors, Remember Position will no longer work on the encounter journal.",
            "[Extra Item Bar] The default setting has been changed to only Shadowlands version for potions, flasks, and food, if you want to add the old items, change the item groups inside the bar setting."
        },
        ["koKR"] = {
            "[프레임 이동] 오류를 방지하기 위해 모험 안내서 창에서는 위치 기억이 사용되지 않습니다.",
            "[아이템 바] 물약, 영약, 음식에 대한 기본 설정이 어둠 땅 버전으로만 변경되었습니다. 오래된 아이템을 추가하려면 바 설정에서 아이템 그룹을 변경하세요."
        }
    },
    NEW = {
        ["zhCN"] = {
            "[任务列表] 提供一个显示爬塔 Buff 在右边的选项. 默认关闭",
            "[任务列表] 提供一个缩写顶部的选项. 默认开启",
            "[美化皮肤] 添加了盟约预览界面的美化.",
            "[美化皮肤] 添加了盟约圣所界面的美化.",
            "[美化皮肤] 添加了盟约名望界面的美化.",
            "[美化皮肤] 添加了灵魂羁绊界面的美化.",
            "[美化皮肤] 添加了心能传导器界面的美化.",
            '[额外物品条] 添加了 "TORGHAST" (托加斯特道具) 物品分类.',
            '[额外物品条] 添加了 "MAGEFOOD" (法师制造食物) 物品分类.'
        },
        ["zhTW"] = {
            "[任務列表] 提供一個顯示爬塔 Buff 在右邊的選項. 默認關閉",
            "[任務列表] 提供一個縮寫頂部的選項. 默認開啟",
            "[美化皮膚] 新增了誓盟預覽介面的美化.",
            "[美化皮膚] 新增了誓盟聖所介面的美化.",
            "[美化皮膚] 新增了誓盟名望介面的美化.",
            "[美化皮膚] 新增了魂絆介面的美化.",
            "[美化皮膚] 新增了靈魄傳導器介面的美化.",
            '[額外物品條] 新增了 "TORGHAST" (托迦司道具) 物品分組.',
            '[額外物品條] 新增了 "MAGEFOOD" (法師製作食物) 物品分組.'
        },
        ["enUS"] = {
            "[Objective Frame] Add new option for moving maw buff frame to right. Disabled by default.",
            "[Objective Frame] Add new option for making header shorter. Enabled by default",
            "[Skins] Add new skin for Blizzard Covenant Preview.",
            "[Skins] Add new skin for Blizzard Covenant Renown.",
            "[Skins] Add new skin for Blizzard Covenant Sanctum.",
            "[Skins] Add new skin for Blizzard Soulbinds.",
            "[Skins] Add new skin for Blizzard Anima Diversion.",
            '[Extra Item Bar] Add new item group "TORGHAST" (Torghast Items).',
            '[Extra Item Bar] Add new item group "MAGEFOOD" (Food crafted by mage).'
        },
        ["koKR"] = {
            "[퀘스트 추적기] 령 능력 버프 창을 오른쪽으로 열어주는 새로운 옵션을 추가합니다. 기본적으로 비활성화되어 있습니다.",
            "[퀘스트 추적기] 제목을 약어로 표시하는 새로운 옵션을 추가합니다. 기본적으로 활성화되어 있습니다.",
            "[스킨] 블리자드 성약단 공물 보기 스킨을 추가합니다.",
            "[스킨] 블리자드 성약단 영예 스킨을 추가합니다.",
            "[스킨] 블리자드 성약단 성소 스킨을 추가합니다.",
            "[스킨] 블리자드 성약단 영혼결속 스킨을 추가합니다.",
            "[스킨] 블리자드 령 전도체 스킨을 추가합니다.",
            '[아이템 바] 새로운 아이템 그룹 "TORGHAST" (토르가스트 아이템)를 추가했습니다.',
            '[아이템 바] 새로운 아이템 그룹 "MAGEFOOD" (마법사 창조 음식)를 추가했습니다.'
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "[美化皮肤] 优化了托加斯特能力选择界面的美化.",
            "[美化皮肤] 优化了对话界面的美化.",
            "[美化皮肤] 优化了任务界面的美化.",
            "[美化皮肤] 优化了死亡回顾界面的美化.",
            "[美化皮肤] 优化了飞行地图界面的美化.",
            "[美化皮肤] 优化了 ElvUI 按键绑定界面的美化.",
            "[天赋管家] 修复了战斗中打开可能造成的污染.",
            "[天赋管家] 从格里恩誓约仆从获得天赋重置 Buff 时, 现在可以正确的更新状态图标了.",
            "[矩形小地图] 优化了托加斯特内的显示.",
            "[重置] 更新 [其他] - [一般设定] 重置."
        },
        ["zhTW"] = {
            "[美化皮膚] 優化了托迦司能力選擇介面的美化.",
            "[美化皮膚] 優化了對話介面的美化.",
            "[美化皮膚] 優化了任務介面的美化.",
            "[美化皮膚] 優化了死亡回顧介面的美化.",
            "[美化皮膚] 優化了飛行地圖介面的美化.",
            "[美化皮膚] 優化了 ElvUI 按鍵綁定介面的美化.",
            "[天賦管家] 修復了戰鬥中開啟可能造成的污染.",
            "[天賦管家] 從琪瑞安誓盟僕從處獲得天賦重置 Buff 時, 現在可以正確的更新狀態圖示了.",
            "[矩形小地圖] 優化了托迦司內的顯示.",
            "[重置] 更新 [其他] - [一般设定] 重置."
        },
        ["enUS"] = {
            "[Skins] Optimize the skins on Torghast ability choice.",
            "[Skins] Optimize the skins on Blizzard Gossip Frame.",
            "[Skins] Optimize the skins on Blizzard Quest Frame.",
            "[Skins] Optimize the skins on Blizzard Death Recap Frame.",
            "[Skins] Optimize the skins on Blizzard FlightMap Frame.",
            "[Skins] Optimize the skins on ElvUI keybinding popup.",
            "[Talent Manager] Fix the taint may occur when you toggle talent UI in combat",
            "[Talent Manager] Now after gains the buff from the Kyrian Steward, the status icon will be updated.",
            "[Rectangle Minimap] Optimize the display in Torghast.",
            "[Reset] Update [Misc] - [General] resetting."
        },
        ["koKR"] = {
            "[스킨] 토르가스트 령 능력 선택 스킨을 최적화합니다.",
            "[스킨] 블리자드 NPC 대화 창 스킨을 최적화합니다.",
            "[스킨] 블리자드 퀘스트 프레임 스킨을 최적화합니다.",
            "[스킨] 블리자드 죽은 원인 스킨을 최적화합니다.",
            "[스킨] 블리자드 비행지도 스킨을 최적화합니다.",
            "[스킨] ElvUI 단축키 팝업창 스킨을 최적화합니다.",
            "[특성 관리자] 전투 중 특성 UI를 전환할 때 오류가 발생할 수 있는 문제를 수정하였습니다.",
            "[특성 관리자] 이제 키리안 청지기에게 특성 변경 버프를 받을 때 상태 아이콘이 올바르게 업데이트됩니다.",
            "[미니맵 비율 조정] 토르가스트에서 디스플레이를 최적화했습니다.",
            "[리셋] 업데이트 [기타] - [일반] 재설정."
        }
    }
}
