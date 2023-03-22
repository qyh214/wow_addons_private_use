local W = unpack((select(2, ...)))

W.Changelog[203] = {
    RELEASE_DATE = "2020/10/24",
    NEW = {
        ["zhCN"] = {
            "[联系人] 添加模块(物品-联系人).",
            "[巅峰声望] 添加了一种新的文字风格.",
            "[游戏条] 添加了鼠标提示在上的选项. 感谢 @Merathilis",
            "[美化皮肤] 添加了 Azeroth Auto Pilot 皮肤"
        },
        ["zhTW"] = {
            "[聯絡人] 新增模組(物品-聯絡人).",
            "[巔峰聲望] 新增一種新的文字風格.",
            "[遊戲條] 新增鼠標提示在上的設定. 感謝 @Merathilis",
            "[美化皮膚] 新增 Azeroth Auto Pilot 皮膚"
        },
        ["enUS"] = {
            "[Contacts] New module. (Item - Contacts)",
            "[Paragon Reputation] Add a new text style.",
            "[Game Bar] Add new option for showing tooltip on top rather than the bottom. Thanks @Merathilis",
            "[Skins] Add skin for Azeroth Auto Pilot."
        },
        ["koKR"] = {
            "[우편 연락처] 새로운 모듈이 추가됨 (아이템 - 우편연락처)",
            "[불멸의 동맹] 새로운 문자 스타일 추가",
            "[게임 바] 툴팁이 생성되는 위치를 상단과 하단으로 설정할 수 있는 옵션 추가 Thanks @Merathilis",
            "[스킨] 스킨추가 - Azeroth Auto Pilot."
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "修复更新记录提示函数.",
            "[游戏条] 部分按钮支持战斗中点击.",
            "[游戏条] 新增一些特殊的炉石. 感谢 @Merathilis",
            "[移动框体] 修复了可能出现的 ElvUI 背包拖拽提示不消失问题.",
            "[移动框体] 修复了 ElvUI 背包不存在时依旧进行处理的问题.",
            "[美化皮肤] 修复了保持宽高比的 WeakAuras 图标美化会导致材质拉伸的问题.",
            "[美化皮肤] 修复了可能发生的 ElvUI 动作条皮肤美化错误.",
            "[美化皮肤] 修复了 Immersion 皮肤的页码字体.",
            "[美化皮肤] 添加了一个任务弹出窗口的美化.",
            "[右键菜单] 公会邀请可以邀请战网好友了.",
            "[右键菜单] 修复了向战网好友发送属性统计的功能.",
            "[右键菜单] 修复了与 RaiderIO 一起使用时可能发生的重叠.",
            "[聊天链接] 修复了坐骑链接无法预览的问题.",
            "[聊天文字] 适配了新的 ElvUI 聊天函数.",
            "[进度] 修复了观察对象时可能发生的报错.",
            "[巅峰声望] 修复了一处设定索引错误.",
            "[巅峰声望] 修复了巅峰箱子无法提示的错误.",
            "[巅峰声望] 更新了对 9.0 的支持.",
            "[矩形小地图] 添加了对移动窗体的限制.",
            "[交接] 修复了部分多任务时可能不交接的问题.",
            "[团队标记] 修复了战斗中可能发生的错误.",
            "[额外物品条] 修复了当玩家持有药水数量大于 12 时可能发生的错误."
        },
        ["zhTW"] = {
            "修復更新記錄提示函數.",
            "[遊戲條] 部分按鈕支持戰鬥中點擊",
            "[遊戲條] 新增了一些特殊的爐石. 感謝 @Merathilis",
            "[移動框架] 修復了可能出現的 ElvUI 背包拖拽提示不消失的問題.",
            "[移動框架] 修復了 ElvUI 背包不存在時依舊進行處理的問題.",
            "[美化皮膚] 修復了保持寬高比的 WeakAura 圖標美化會導致材質拉伸的問題.",
            "[美化皮膚] 修復了可能发生的 ElvUI 动作条皮肤美化错误.",
            "[美化皮膚] 修復了 Immersion 的頁碼字體.",
            "[美化皮膚] 添加了一個任務彈出框架的美化.",
            "[右鍵選單] 公會邀請可以邀請戰網好友了.",
            "[右鍵選單] 修復了向戰網好友發送屬性統計的功能.",
            "[右鍵選單] 修復了同時載入 RaiderIO 時發生的錯位.",
            "[聊天鏈接] 修復了坐騎鏈接無法預覽的問題.",
            "[聊天文字] 適配了新的 ElvUI 對話函數.",
            "[進度] 修復了觀察對象時可能發生的錯誤.",
            "[巔峰聲望] 修復了一處設定索引錯誤.",
            "[巔峰聲望] 修復了巔峰箱子無法提示的錯誤.",
            "[巔峰聲望] 支援 9.0 新陣營.",
            "[矩形小地图] 新增了對移動框架的限制.",
            "[交接] 修復了多任務時可能不交接的問題.",
            "[團隊標記] 修復了戰鬥中可能發生的錯誤.",
            "[額外物品條] 修復了當玩家持有藥水數大於 12 時可能發生的錯誤."
        },
        ["enUS"] = {
            "Fix changelog alert function.",
            "[Game Bar] A part of buttons support click in combat.",
            "[Game Bar] Add several special Hearthstones. Thanks @Merathilis",
            "[Move Frames] Fix the bug that tooltips on ElvUI Bags may not hide.",
            "[Move Frames] Fix the bug that the module try to handle ElvUI Bags even it not exist.",
            '[Skins] Fix the bug that WeakAuras Icons option "keep aspect ratio" not worked.',
            "[Skins] Fix the bug that Skins try to show/hide shadow even the shadow was not added.",
            "[Skins] Fix Immersion page number in non-English clients.",
            "[Skins] Add a missing quest popup frame skin.",
            "[Context Menu] Guild invite now available on Battle.net friends.",
            "[Context Menu] Fix Report Stats function on Battle.net friends.",
            "[Context Menu] Fix the position when Raider.IO also loaded.",
            "[Chat Link] Fix the problem that you cannot preview the mount via clicking the link.",
            "[Chat Text] Fit to the new ElvUI Chat functions.",
            "[Progression] Fix the bug occurred when you try to inspect other players.",
            "[Paragon Reputation] Fix the option key error.",
            "[Paragon Reputation] Fix the tips of rewards.",
            "[Paragon Reputation] Add support for SL.",
            "[Rectangle Minimap] Add the limit for minimap mover.",
            "[Turn In] Fix the bugs that the automation stops on multiple quests.",
            "[Raid Markers] Fix the errors in combat.",
            "[Extra Item Bar] Fix the bug occurred if the number of potions over 12."
        },
        ["koKR"] = {
            "변경사항 알림 기능 수정",
            "[게임 바] 일부 버튼은 전투 중 클릭을 지원합니다.",
            "[게임 바] 몇 가지 특별한 귀환석을 추가합니다. Thanks @Merathilis",
            "[프레임 이동] ElvUI 가방의 툴팁이 숨겨지지 않는 버그를 수정했습니다.",
            "[프레임 이동] ElvUI Bag이 존재하지 않더라도 모듈이 처리하려고하는 버그 수정.",
            "[스킨] WeakAuras 아이콘 옵션 가로 세로 비 유지가 작동하지 않는 버그 수정.",
            "[스킨] 그림자가 추가되지 않은 경우에도 스킨이 그림자를 보이거나 숨기는 버그를 수정하였습니다.",
            "[스킨] 영어가 아닌 클라이언트에서 Immersion 페이지 번호 수정.",
            "[스킨] 누락 된 퀘스트 팝업 프레임 스킨을 추가합니다.",
            "[우클릭 메뉴] 이제 Battle.net 친구에게 길드 초대가 가능합니다.",
            "[우클릭 메뉴] Battle.net 친구의 통계보고 기능 수정.",
            "[우클릭 메뉴] Raider.IO와 함께 로드되었을 때 위치를 수정합니다.",
            "[채팅 링크] 링크를 클릭해도 탈것을 미리 볼수 없는 문제 수정.",
            "[채팅 문자] 새로운 ElvUI 채팅 기능에 적합합니다.",
            "[진행 상태] 다른 플레이어를 검사하려고 할 때 발생하던 버그를 수정했습니다.",
            "[불멸의 동맹] 옵션 키 오류 수정.",
            "[불멸의 동맹] 보상의 툴팁을 수정합니다.",
            "[불멸의 동맹] SL 지원 추가.",
            "[미니맵 비율 조정] 미니맵 이동 제한을 추가합니다.",
            "[자동 수락] 여러 퀘스트에서 자동화가 멈추는 버그 수정.",
            "[공격대 징표] 전투 중 오류 수정.",
            "[아이템 바] 물약 개수가 12 개 이상일 경우 발생하던 버그를 수정했습니다."
        }
    }
}
