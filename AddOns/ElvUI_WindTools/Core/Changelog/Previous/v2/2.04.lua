local W = unpack((select(2, ...)))

W.Changelog[204] = {
    RELEASE_DATE = "2020/10/26",
    IMPORTANT = {
        ["zhCN"] = {
            "添加了初步的韩语支持",
            "添加了在 ElvUI 移动模式下, 右键框体打开选项的功能.",
            "添加了与 ElvUI_MerathilisUI 一起使用时的兼容性检查助手.",
            "取消了 TinyInspect 的兼容性模式, 现在将会自带一个精简版."
        },
        ["zhTW"] = {
            "新增了初步的韓文支援.",
            "新增了在 ElvUI 移動模式下, 右鍵框架打開設定的功能.",
            "新增了與 ElvUI_MerathilisUI 一起使用時的兼容性檢查助手.",
            "取消了 TinyInspect 的兼容性模式, 現在將會自帶一個精簡版."
        },
        ["enUS"] = {
            "First time to add incomplete support for Korean.",
            "Add the support of right-click the mover to open options.",
            "Add the compatibility check frame of ElvUI_MerathilisUI.",
            "Remove compatible mode of TinyInspect, the modified lite TinyInspect will be added."
        },
        ["koKR"] = {
            "불완전하지만 한국어에 대한 지원을 처음 추가했습니다.",
            "프레임 이동 창에서 마우스 오른쪽 버튼으로 설정을 열수 있는 기능을 추가합니다.",
            "ElvUI_MerathilisUI의 호환성 검사 프레임을 추가합니다.",
            "TinyInspect의 호환 모드를 제거하고, 수정된 라이트 TinyInspect가 추가됩니다."
        }
    },
    NEW = {
        ["zhCN"] = {
            "[装备观察] 新物品模块, 移植自 TinyInspect 的观察面板. 感谢 loudsoul",
            "[额外物品条] 添加了渐隐时间, 最大最小透明度的功能和选项.",
            "[交接] 添加了命令 /wti [on|off] 来快速切换交接状态.",
            "[交接] 添加了命令 /wti [add|ignore] 来快速添加目标到忽略名单.",
            "[交接] 添加了按下修饰键暂停自动交接的功能和选项.",
            "[联系人] 添加了按钮的右键菜单, 支持快速加入/移除收藏."
        },
        ["zhTW"] = {
            "[裝備觀察] 新物品模組，移植自 TinyInspect 的觀察面板. 感謝 loudsoul",
            "[額外物品條] 新增了漸隱時間, 最大最小透明度的功能和設定.",
            "[交接] 添加了指令 /wti [on|off] 來快速切換交接狀態.",
            "[交接] 添加了指令 /wti [add|ignore] 來快速添加目標到忽略名單.",
            "[交接] 添加了按下修飾鍵暫停自動交接的功能及設定.",
            "[聯絡人] 添加了按鈕的右鍵選單, 支援快速加入/移除我的最愛."
        },
        ["enUS"] = {
            "[Inspect] New Module in item category. Ported from TinyInspect. Thanks loudsoul.",
            "[Extra Item Bar] Add the support and options of fade time and alpha.",
            "[Turn In] Add new slash command /wti [on|off] to enable/disable the module.",
            "[Turn In] Add new slash command /wti [add|ignore] to add target to the ignore list.",
            "[Turn In] Add the feature and options of pause automation if you pressed the modified key.",
            "[Contacts] Add new context menu to buttons, making manage favorites easier."
        },
        ["koKR"] = {
            "[살펴보기] 아이템 카테고리의 새로운 모듈이 추가되었습니다. TinyInspect에서 포팅 되었습니다. Thanks loudsoul.",
            "[아이템 바] 마우스 오버 시 사라지는 시간, 투명도 설정 등 관련 옵션을 추가합니다.",
            "[자동수락] 새 슬래시 명령 /wti [on | off]를 추가하여 모듈을 활성화 / 비활성화합니다.",
            "[자동수락] 제외 목록에 대상을 추가하기 위한 새 슬래시 명령 /wti [add | ignore]를 추가합니다.",
            "[자동수락] 설정 키를 누른 경우 자동화 일시 중지 기능을 추가합니다.",
            "[우편 연락처] 버튼에 새로운 컨텍스트 메뉴를 추가하여 즐겨찾기를 보다 쉽게 관리할 수 있습니다."
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "优化部分设定的布局.",
            "优化工具箱自带配置(Fang2hou UI)的导入流程.",
            "[右键菜单] 优化与 RaiderIO 一起使用时的位置.",
            "[联系人] 优化公会成员信息获取方式. 感谢 fgprodigal",
            "[游戏条] 右键藏品按钮可以召唤随机偏好坐骑. 感谢 Merathilis",
            "[游戏条] 右键小伙伴手册按钮可以召唤随机偏好小伙伴. 感谢 Merathilis",
            "[交接] 修复了停用后不重载界面继续交接的问题.",
            "[通告] 修复了仇恨转移技能的通报逻辑."
        },
        ["zhTW"] = {
            "優化部分設定項目的佈局.",
            "優化工具箱自帶配置(Fang2hou UI)的導入流程.",
            "[右鍵選單] 優化 RaiderIO 一起使用時的位置.",
            "[聯絡人] 優化公會成員信息獲取方式. 感謝 fgprodigal",
            "[遊戲條] 右鍵收藏按鈕可以召喚隨機偏好坐騎. 感謝 Merathilis",
            "[遊戲條] 右鍵寵物日誌按鈕可以召喚隨機偏好寵物. 感謝 Merathilis",
            "[交接] 修復了停用後在重載 UI 前依舊會進行交接的問題.",
            "[通告] 修復了仇恨轉移技能的通報邏輯."
        },
        ["enUS"] = {
            "Optimize the layout of options.",
            "Optimize the process of importing the default profile(Fang2hou UI).",
            "[Context Menu] Better position with Raider.IO menu.",
            "[Contacts] Obtaining information from guild members now get more robust. Thanks fgprodigal",
            "[Game Bar] Right-click the Collections Button to summon favorite mounts randomly. Thanks Merathilis",
            "[Game Bar] Right-click the Pet Journal Button to summon favorite pets randomly. Thanks Merathilis",
            "[Turn In] Fix the bug that disabling the module will not stop module until reloading.",
            "[Announcement] Fix the logic of threat transfer spells."
        },
        ["koKR"] = {
            "옵션 레이아웃을 최적화합니다.",
            "기본 프로필(Fang2hou UI)의 가져오기 프로세스를 최적화합니다.",
            "[우 클릭 메뉴] Raider.IO 메뉴와 겹치지 않는 더 나은 위치로 수정했습니다.",
            "[연락처] 길드원으로부터 정보를 얻는 것이 이제 더욱 강력 해졌습니다. Thanks fgprodigal",
            "[게임 바] 컬렉션 버튼을 마우스 오른쪽 버튼으로 클릭하면 좋아하는 탈것이 무작위로 소환됩니다. Thanks Merathilis",
            "[게임 바] 애완동물도감 버튼을 마우스 오른쪽 버튼으로 클릭하면 좋아하는 애완동물을 무작위로 소환할 수 있습니다. Thanks Merathilis",
            "[자동 수락] 모듈을 비활성화해도 다시 로드 할 때까지 모듈이 중지되지 않는 버그를 수정합니다."
        }
    }
}
