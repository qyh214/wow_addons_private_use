local addonId = ...
local languageTable = DetailsFramework.Language.RegisterLanguage(addonId, "zhTW")
local L = languageTable

L["S_APOWER_AVAILABLE"] = "可用"
L["S_APOWER_NEXTLEVEL"] = "下個等級"
L["S_DECREASESIZE"] = "縮小"
L["S_ENABLED"] = "啟用"
L["S_ERROR_NOTIMELEFT"] = "任務已過期。"
L["S_ERROR_NOTLOADEDYET"] = "任務尚未載入，請稍候。"
L["S_FACTION_TOOLTIP_SELECT"] = "左鍵: 選擇這個陣營"
L["S_FACTION_TOOLTIP_TRACK"] = "Shift + 左鍵: 追蹤這個陣營的任務"
L["S_FLYMAP_SHOWTRACKEDONLY"] = "只有已追蹤的"
L["S_FLYMAP_SHOWTRACKEDONLY_DESC"] = "只顯示正在追蹤的任務"
L["S_FLYMAP_SHOWWORLDQUESTS"] = "顯示世界任務"
L["S_GROUPFINDER_ACTIONS_CANCEL_APPLICATIONS"] = "點一下取消申請加入隊伍..."
L["S_GROUPFINDER_ACTIONS_CANCELING"] = "正在取消..."
L["S_GROUPFINDER_ACTIONS_CREATE"] = "沒有找到隊伍，點一下建立新隊伍"
L["S_GROUPFINDER_ACTIONS_CREATE_DIRECT"] = "建立新隊伍"
L["S_GROUPFINDER_ACTIONS_LEAVEASK"] = "是否要離開隊伍?"
L["S_GROUPFINDER_ACTIONS_LEAVINGIN"] = "幾秒後會離開隊伍 (點一下立即離開)："
L["S_GROUPFINDER_ACTIONS_RETRYSEARCH"] = "重新搜尋"
L["S_GROUPFINDER_ACTIONS_SEARCH"] = "點一下開始搜尋隊伍"
L["S_GROUPFINDER_ACTIONS_SEARCH_RARENPC"] = "搜尋要殺這隻稀有怪的隊伍"
L["S_GROUPFINDER_ACTIONS_SEARCH_TOOLTIP"] = "加入正在做這個任務的隊伍"
L["S_GROUPFINDER_ACTIONS_SEARCHING"] = "正在搜尋..."
L["S_GROUPFINDER_ACTIONS_SEARCHMORE"] = "點一下搜尋更多隊伍成員"
L["S_GROUPFINDER_ACTIONS_SEARCHOTHER"] = "是否要離開並且搜尋其他隊伍?"
L["S_GROUPFINDER_ACTIONS_UNAPPLY1"] = "點一下取消申請，以便建立新的隊伍"
L["S_GROUPFINDER_ACTIONS_UNLIST"] = "點一下將目前的隊伍從清單中移除"
L["S_GROUPFINDER_ACTIONS_UNLISTING"] = "正在從清單中移除..."
L["S_GROUPFINDER_ACTIONS_WAITING"] = "正在等候..."
L["S_GROUPFINDER_AUTOOPEN_RARENPC_TARGETED"] = "目標是稀有怪時自動開啟"
L["S_GROUPFINDER_ENABLED"] = "有新任務時自動開啟"
L["S_GROUPFINDER_LEAVEOPTIONS"] = "離開隊伍選項"
L["S_GROUPFINDER_LEAVEOPTIONS_AFTERX"] = "幾秒後離開"
L["S_GROUPFINDER_LEAVEOPTIONS_ASKX"] = "不要自動離開，只要詢問幾秒"
L["S_GROUPFINDER_LEAVEOPTIONS_DONTLEAVE"] = "不要顯示離開面板"
L["S_GROUPFINDER_LEAVEOPTIONS_IMMEDIATELY"] = "任務完成時立刻離開"
L["S_GROUPFINDER_NOPVP"] = "避免加入 PvP 伺服器"
L["S_GROUPFINDER_OT_ENABLED"] = "在任務目標清單上顯示按鈕"
L["S_GROUPFINDER_QUEUEBUSY"] = "已經在等候佇列中。"
L["S_GROUPFINDER_QUEUEBUSY2"] = "無法顯示隊伍搜尋器視窗：已經在隊伍中或等候佇列。"
L["S_GROUPFINDER_RESULTS_APPLYING"] = "尚有 %d 個隊伍，請再點一下"
L["S_GROUPFINDER_RESULTS_APPLYING1"] = "尚有 1 個隊伍可以加入，請再點一下"
L["S_GROUPFINDER_RESULTS_FOUND"] = [=[找到 %d 個隊伍
點一下加入]=]
L["S_GROUPFINDER_RESULTS_FOUND1"] = [=[找到 1 個隊伍
點一下加入]=]
L["S_GROUPFINDER_RESULTS_UNAPPLY"] = "尚有 %d 個申請..."
L["S_GROUPFINDER_RIGHTCLICKCLOSE"] = "點一下右鍵關閉面板"
L["S_GROUPFINDER_SECONDS"] = "秒"
L["S_GROUPFINDER_TITLE"] = "隊伍搜尋器"
L["S_GROUPFINDER_TUTORIAL1"] = "加入正在做同一個任務的隊伍，更快完成世界任務!"
L["S_INCREASESIZE"] = "放大"
L["S_MAPBAR_FILTER"] = "過濾"
L["S_MAPBAR_FILTERMENU_FACTIONOBJECTIVES"] = "陣營目標"
L["S_MAPBAR_FILTERMENU_FACTIONOBJECTIVES_DESC"] = "仍然顯示已被過濾的陣營任務"
L["S_MAPBAR_OPTIONS"] = "選項"
L["S_MAPBAR_OPTIONSMENU_ARROWSPEED"] = "箭頭更新速度"
L["S_MAPBAR_OPTIONSMENU_ARROWSPEED_HIGH"] = "快"
L["S_MAPBAR_OPTIONSMENU_ARROWSPEED_MEDIUM"] = "中等"
L["S_MAPBAR_OPTIONSMENU_ARROWSPEED_REALTIME"] = "即時"
L["S_MAPBAR_OPTIONSMENU_ARROWSPEED_SLOW"] = "慢"
L["S_MAPBAR_OPTIONSMENU_EQUIPMENTICONS"] = "裝備顯示實際圖示"
L["S_MAPBAR_OPTIONSMENU_QUESTTRACKER"] = "啟用任務追蹤"
L["S_MAPBAR_OPTIONSMENU_REFRESH"] = "重新整理"
L["S_MAPBAR_OPTIONSMENU_SOUNDENABLED"] = "啟用音效"
L["S_MAPBAR_OPTIONSMENU_STATUSBAR_ONDISABLE"] = "輸入 '/wqt statusbar' 或在 Esc > 介面 > 插件 > 任務-世界任務，來恢復選單。"
L["S_MAPBAR_OPTIONSMENU_STATUSBAR_VISIBILITY"] = "顯示選單"
L["S_MAPBAR_OPTIONSMENU_STATUSBARANCHOR"] = "選單在上方"
L["S_MAPBAR_OPTIONSMENU_TOMTOM_WPPERSISTENT"] = "保留路徑點"
L["S_MAPBAR_OPTIONSMENU_TRACKER_CURRENTZONE"] = "只顯示目前地區的任務"
L["S_MAPBAR_OPTIONSMENU_TRACKER_SCALE"] = "追蹤清單縮放: %s"
L["S_MAPBAR_OPTIONSMENU_TRACKERCONFIG"] = "追蹤清單設定"
L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_AUTO"] = "自動調整位置"
L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_CUSTOM"] = "自訂位置"
L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_LOCKED"] = "鎖定位置"
L["S_MAPBAR_OPTIONSMENU_UNTRACKQUESTS"] = "取消追蹤所有任務"
L["S_MAPBAR_OPTIONSMENU_WORLDMAPCONFIG"] = "世界地圖設定"
L["S_MAPBAR_OPTIONSMENU_YARDSDISTANCE"] = "顯示距離（單位：碼）"
L["S_MAPBAR_OPTIONSMENU_ZONE_QUESTSUMMARY"] = "顯示任務列表"
L["S_MAPBAR_OPTIONSMENU_ZONEMAPCONFIG"] = "區域地圖設定"
L["S_MAPBAR_RESOURCES_TOOLTIP_TRACKALL"] = "點一下全部追蹤: |cFFFFFFFF%s| 任務。"
L["S_MAPBAR_SORTORDER"] = "排序"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_FADE"] = "淡出快過期的任務"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_OPTION"] = "少於 %d 小時"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_SHOWTEXT"] = "顯示任務過期時間"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_SORTBYTIME"] = "依據時間排序"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_TITLE"] = "時間"
L["S_MAPBAR_SUMMARYMENU_ACCOUNTWIDE"] = "帳號內所有角色"
L["S_OPTIONS_ACCESSIBILITY"] = "協助工具"
L["S_OPTIONS_ACCESSIBILITY_EXTRATRACKERMARK"] = "額外追蹤標記"
L["S_OPTIONS_ACCESSIBILITY_SHOWBOUNTYRING"] = "金錢獎勵顯示圓環"
L["S_OPTIONS_ANIMATIONS"] = "顯示動畫效果"
L["S_OPTIONS_MAPFRAME_ALIGN"] = "地圖視窗對齊中間"
L["S_OPTIONS_MAPFRAME_ERROR_SCALING_DISABLED"] = "尚未變更任何數值，必須先 '啟用縮放視窗大小'。"
L["S_OPTIONS_MAPFRAME_SCALE"] = "地圖視窗縮放大小"
L["S_OPTIONS_MAPFRAME_SCALE_ENABLED"] = "啟用縮放視窗大小"
L["S_OPTIONS_QUESTBLACKLIST"] = "任務忽略清單"
L["S_OPTIONS_RESET"] = "重置"
L["S_OPTIONS_SHOWFACTIONS"] = "顯示陣營"
L["S_OPTIONS_TIMELEFT_NOPRIORITY"] = "不要過濾剩餘時間"
L["S_OPTIONS_TRACKER_RESETPOSITION"] = "重置位置"
L["S_OPTIONS_WORLD_ANCHOR_LEFT"] = "對齊左側"
L["S_OPTIONS_WORLD_ANCHOR_RIGHT"] = "對齊右側"
L["S_OPTIONS_WORLD_DECREASEICONSPERROW"] = "減少每列的圖示數量"
L["S_OPTIONS_WORLD_INCREASEICONSPERROW"] = "增加每列的圖示數量"
L["S_OPTIONS_WORLD_ORGANIZE_BYMAP"] = "依據地圖分類"
L["S_OPTIONS_WORLD_ORGANIZE_BYTYPE"] = "依據任務類型分類"
L["S_OPTIONS_ZONE_SHOWONLYTRACKED"] = "只有已追蹤的"
L["S_OVERALL"] = "整體"
L["S_PARTY"] = "隊伍"
L["S_PARTY_DESC1"] = "藍色星星表示所有隊伍成員都有這個任務。"
L["S_PARTY_DESC2"] = "如果顯示紅色星星，表示某個隊伍成員沒有世界任務，或尚未安裝世界任務追蹤插件。"
L["S_PARTY_PLAYERSWITH"] = "隊伍中有 WQT 的玩家:"
L["S_PARTY_PLAYERSWITHOUT"] = "隊伍中沒有 WQT 的玩家:"
L["S_QUESTSCOMPLETED"] = "完成任務"
L["S_QUESTTYPE_ARTIFACTPOWER"] = "神兵之力"
L["S_QUESTTYPE_DUNGEON"] = "地城"
L["S_QUESTTYPE_EQUIPMENT"] = "裝備"
L["S_QUESTTYPE_GOLD"] = "金幣"
L["S_QUESTTYPE_PETBATTLE"] = "寵物對戰"
L["S_QUESTTYPE_PROFESSION"] = "專業"
L["S_QUESTTYPE_PVP"] = "PvP"
L["S_QUESTTYPE_RESOURCE"] = "資源"
L["S_QUESTTYPE_TRADESKILL"] = "專業技能"
L["S_RAREFINDER_ADDFROMPREMADE"] = "加入預組隊伍中有的稀有怪"
L["S_RAREFINDER_NPC_NOTREGISTERED"] = "資料庫中沒有這個稀有怪"
L["S_RAREFINDER_OPTIONS_ENGLISHSEARCH"] = "永遠使用英文搜尋"
L["S_RAREFINDER_OPTIONS_SHOWICONS"] = "顯示在地圖上還活著的稀有怪圖示"
L["S_RAREFINDER_SOUND_ALWAYSPLAY"] = "停用音效時仍然要播放"
L["S_RAREFINDER_SOUND_ENABLED"] = "小地圖出現稀有怪時播放音效"
L["S_RAREFINDER_SOUNDWARNING"] = "小地圖上出現稀有怪時要播放音效，可以從選單 > 稀有怪搜尋器的子選單中停用音效。"
L["S_RAREFINDER_TITLE"] = "稀有怪搜尋器"
L["S_RAREFINDER_TOOLTIP_REMOVE"] = "移除"
L["S_RAREFINDER_TOOLTIP_SEACHREALM"] = "搜尋其他伺服器"
L["S_RAREFINDER_TOOLTIP_SPOTTEDBY"] = "發現於"
L["S_RAREFINDER_TOOLTIP_TIMEAGO"] = "分鐘前"
L["S_SUMMARYPANEL_EXPIRED"] = "已過期"
L["S_SUMMARYPANEL_LAST15DAYS"] = "最近15天"
L["S_SUMMARYPANEL_LIFETIMESTATISTICS_ACCOUNT"] = "帳號上線統計"
L["S_SUMMARYPANEL_LIFETIMESTATISTICS_CHARACTER"] = "角色上線統計"
L["S_SUMMARYPANEL_OTHERCHARACTERS"] = "其他角色"
L["S_TUTORIAL_AMOUNT"] = "表示可獲得的數量"
L["S_TUTORIAL_CLICKTOTRACK"] = "點一下追蹤任務。"
L["S_TUTORIAL_PARTY"] = "組隊時，藍色星星表示所有隊伍成員都有這些任務!"
L["S_TUTORIAL_STATISTICS_BUTTON"] = "點一下這裡瀏覽統計資料和其他角色所儲存的任務清單。"
L["S_TUTORIAL_TIMELEFT"] = "表示剩餘時間 (+4小時, +90分鐘, +30分鐘, 少於30分鐘)"
L["S_TUTORIAL_WORLDBUTTONS"] = [=[點一下這裡在三種列表類型中循環切換。

- |cFFFFAA11依據任務類型|r
- |cFFFFAA11依據區域|r
- |cFFFFAA11不顯示|r

點一下|cFFFFAA11切換顯示任務|r來隱藏任務位置。]=]
L["S_TUTORIAL_WORLDMAPBUTTON"] = "按下這個按鈕會顯示整個破碎群島的地圖。"
L["S_UNKNOWNQUEST"] = "未知的任務"
L["S_WHATSNEW"] = "更新資訊"
L["S_WORLDBUTTONS_SHOW_NONE"] = "隱藏任務列表"
L["S_WORLDBUTTONS_SHOW_TYPE"] = "顯示任務列表"
L["S_WORLDBUTTONS_SHOW_ZONE"] = "依據區域排列"
L["S_WORLDBUTTONS_TOGGLE_QUESTS"] = "切換顯示任務"
L["S_WORLDMAP_QUESTLOCATIONS"] = "顯示任務位置"
L["S_WORLDMAP_QUESTSUMMARY"] = "顯示任務列表"
L["S_WORLDMAP_TOOGLEQUESTS"] = "切換顯示任務"
L["S_WORLDMAP_TOOLTIP_TRACKALL"] = "追蹤這個列表中的所有任務"
L["S_WORLDQUESTS"] = "世界任務"

------------------------------------------------------------
L["S_APOWER_AVAILABLE"] = "可用"
L["S_APOWER_NEXTLEVEL"] = "下個等級"
L["S_DECREASESIZE"] = "縮小"
L["S_DUNGEON"] = "地城"
L["S_ENABLE"] = "啟用"
L["S_ENABLED"] = "啟用"
L["S_ERROR_NOTIMELEFT"] = "任務已過期。"
L["S_ERROR_NOTLOADEDYET"] = "任務尚未載入，請稍候。"
L["S_FACTION_TOOLTIP_SELECT"] = "左鍵: 選擇這個陣營"
L["S_FACTION_TOOLTIP_TRACK"] = "Shift + 左鍵: 追蹤這個陣營的任務"
L["S_FLYMAP_SHOWTRACKEDONLY"] = "只有已追蹤的"
L["S_FLYMAP_SHOWTRACKEDONLY_DESC"] = "只顯示正在追蹤的任務"
L["S_FLYMAP_SHOWWORLDQUESTS"] = "顯示世界任務"
L["S_GROUPFINDER_ACTIONS_CANCEL_APPLICATIONS"] = "點一下取消申請加入隊伍..."
L["S_GROUPFINDER_ACTIONS_CANCELING"] = "正在取消..."
L["S_GROUPFINDER_ACTIONS_CREATE"] = "沒有找到隊伍，點一下建立新隊伍"
L["S_GROUPFINDER_ACTIONS_CREATE_DIRECT"] = "建立新隊伍"
L["S_GROUPFINDER_ACTIONS_LEAVEASK"] = "是否要離開隊伍?"
L["S_GROUPFINDER_ACTIONS_LEAVINGIN"] = "幾秒後會離開隊伍 (點一下立即離開)："
L["S_GROUPFINDER_ACTIONS_RETRYSEARCH"] = "重新搜尋"
L["S_GROUPFINDER_ACTIONS_SEARCH"] = "點一下開始搜尋隊伍"
L["S_GROUPFINDER_ACTIONS_SEARCH_RARENPC"] = "搜尋要殺這隻稀有怪的隊伍"
L["S_GROUPFINDER_ACTIONS_SEARCH_TOOLTIP"] = "加入正在做這個任務的隊伍"
L["S_GROUPFINDER_ACTIONS_SEARCHING"] = "正在搜尋..."
L["S_GROUPFINDER_ACTIONS_SEARCHMORE"] = "點一下搜尋更多隊伍成員"
L["S_GROUPFINDER_ACTIONS_SEARCHOTHER"] = "是否要離開並且搜尋其他隊伍?"
L["S_GROUPFINDER_ACTIONS_UNAPPLY1"] = "點一下取消申請，以便建立新的隊伍"
L["S_GROUPFINDER_ACTIONS_UNLIST"] = "點一下將目前的隊伍從清單中移除"
L["S_GROUPFINDER_ACTIONS_UNLISTING"] = "正在從清單中移除..."
L["S_GROUPFINDER_ACTIONS_WAITING"] = "正在等候..."
L["S_GROUPFINDER_AUTOOPEN_RARENPC_TARGETED"] = "目標是稀有怪時自動開啟"
L["S_GROUPFINDER_ENABLED"] = "有新任務時自動開啟"
L["S_GROUPFINDER_LEAVEOPTIONS"] = "離開隊伍選項"
L["S_GROUPFINDER_LEAVEOPTIONS_AFTERX"] = "幾秒後離開"
L["S_GROUPFINDER_LEAVEOPTIONS_ASKX"] = "不要自動離開，只要詢問幾秒"
L["S_GROUPFINDER_LEAVEOPTIONS_DONTLEAVE"] = "不要顯示離開面板"
L["S_GROUPFINDER_LEAVEOPTIONS_IMMEDIATELY"] = "任務完成時立刻離開"
L["S_GROUPFINDER_NOPVP"] = "避免加入 PvP 伺服器"
L["S_GROUPFINDER_OT_ENABLED"] = "在任務目標清單上顯示按鈕"
L["S_GROUPFINDER_QUEUEBUSY"] = "已經在等候佇列中。"
L["S_GROUPFINDER_QUEUEBUSY2"] = "無法顯示隊伍搜尋器視窗：已經在隊伍中或等候佇列。"
L["S_GROUPFINDER_RESULTS_APPLYING"] = "尚有 %d 個隊伍，請再點一下"
L["S_GROUPFINDER_RESULTS_APPLYING1"] = "尚有 1 個隊伍可以加入，請再點一下"
L["S_GROUPFINDER_RESULTS_FOUND"] = [=[找到 %d 個隊伍
點一下加入]=]
L["S_GROUPFINDER_RESULTS_FOUND1"] = [=[找到 1 個隊伍
點一下加入]=]
L["S_GROUPFINDER_RESULTS_UNAPPLY"] = "尚有 %d 個申請..."
L["S_GROUPFINDER_RIGHTCLICKCLOSE"] = "點右鍵關閉"
L["S_GROUPFINDER_SECONDS"] = "秒"
L["S_GROUPFINDER_TUTORIAL1"] = "加入正在做同一個任務的隊伍，更快完成世界任務!"
L["S_INCREASESIZE"] = "放大"
L["S_MAPBAR_FILTER"] = "過濾"
L["S_MAPBAR_FILTERMENU_FACTIONOBJECTIVES"] = "陣營目標"
L["S_MAPBAR_FILTERMENU_FACTIONOBJECTIVES_DESC"] = "仍然顯示已被過濾的陣營任務"
L["S_MAPBAR_OPTIONS"] = "選項"
L["S_MAPBAR_OPTIONSMENU_ARROWSPEED"] = "箭頭更新速度"
L["S_MAPBAR_OPTIONSMENU_EQUIPMENTICONS"] = "裝備顯示實際圖示"
L["S_MAPBAR_OPTIONSMENU_QUESTTRACKER"] = "啟用任務追蹤"
L["S_MAPBAR_OPTIONSMENU_REFRESH"] = "重新整理"
L["S_MAPBAR_OPTIONSMENU_SOUNDENABLED"] = "啟用音效"
L["S_MAPBAR_OPTIONSMENU_STATUSBAR_ONDISABLE"] = "輸入 '/wqt statusbar' 或在 Esc > 介面 > 插件 > 任務-世界任務，來恢復選單。"
L["S_MAPBAR_OPTIONSMENU_STATUSBAR_VISIBILITY"] = "顯示選單"
L["S_MAPBAR_OPTIONSMENU_STATUSBARANCHOR"] = "選單在上方"
L["S_MAPBAR_OPTIONSMENU_TRACKER_CURRENTZONE"] = "只顯示目前地區的任務"
L["S_MAPBAR_OPTIONSMENU_TRACKER_SCALE"] = "追蹤清單縮放: %s"
L["S_MAPBAR_OPTIONSMENU_TRACKER_SCALE_NAME"] = "任務追蹤清單縮放大小"
L["S_MAPBAR_OPTIONSMENU_TRACKERCONFIG"] = "追蹤清單設定"
L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_AUTO"] = "自動調整位置"
L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_CUSTOM"] = "自訂位置"
L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_LOCKED"] = "鎖定位置"
L["S_MAPBAR_OPTIONSMENU_UNTRACKQUESTS"] = "取消追蹤所有任務"
L["S_MAPBAR_OPTIONSMENU_WORLDMAPCONFIG"] = "世界地圖設定"
L["S_MAPBAR_OPTIONSMENU_YARDSDISTANCE"] = "顯示距離 (單位: 碼)"
L["S_MAPBAR_OPTIONSMENU_ZONE_QUESTSUMMARY"] = "顯示任務列表"
L["S_MAPBAR_RESOURCES_TOOLTIP_TRACKALL"] = "點一下全部追蹤: |cFFFFFFFF%s| 任務。"
L["S_MAPBAR_SORTORDER"] = "排序"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_FADE"] = "淡出快過期的任務"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_OPTION"] = "少於 %d 小時"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_SHOWTEXT"] = "顯示任務過期時間"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_SORTBYTIME"] = "依據時間排序"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_TITLE"] = "時間"
L["S_MAPBAR_SUMMARYMENU_ACCOUNTWIDE"] = "帳號內所有角色"
L["S_OPENWORLD"] = "開放世界"
L["S_OPTIONS_ACCESSIBILITY"] = "協助工具"
L["S_OPTIONS_ACCESSIBILITY_EXTRATRACKERMARK"] = "額外追蹤標記"
L["S_OPTIONS_ACCESSIBILITY_SHOWBOUNTYRING"] = "金錢獎勵顯示圓環"
L["S_OPTIONS_ANIMATIONS"] = "顯示動畫效果"
L["S_OPTIONS_GF_DONT_SHOW_IFGROUP"] = "已在隊伍中時不顯示"
L["S_OPTIONS_GF_SHOWOPTIONS_BUTTON"] = "顯示選項按鈕"
L["S_OPTIONS_MAPFRAME_ALIGN"] = "地圖視窗對齊中間"
L["S_OPTIONS_MAPFRAME_ERROR_SCALING_DISABLED"] = "尚未變更任何數值，必須先 '啟用縮放視窗大小'。"
L["S_OPTIONS_MAPFRAME_SCALE"] = "地圖視窗縮放大小"
L["S_OPTIONS_MAPFRAME_SCALE_ENABLED"] = "啟用縮放視窗大小"
L["S_OPTIONS_OPEN"] = "打開選項面板"
L["S_OPTIONS_OPEN_FROM_INTERFACE_PANEL"] = "打開世界任務追蹤設定選單"
L["S_OPTIONS_PATHLINE"] = "路徑線條"
L["S_OPTIONS_QUEST_EMISSARY"] = "大使任務資訊"
L["S_OPTIONS_QUESTBLACKLIST"] = "任務忽略清單"
L["S_OPTIONS_RESET"] = "重置"
L["S_OPTIONS_SHOW_FILTER_BUTTON"] = "顯示過濾方式按鈕"
L["S_OPTIONS_SHOW_MINIMIZE_BUTTON"] = "顯示最小化按鈕"
L["S_OPTIONS_SHOW_SORT_BUTTON"] = "顯示排序按鈕"
L["S_OPTIONS_SHOW_TIMELEFT_BUTTON"] = "顯示剩餘時間按鈕"
L["S_OPTIONS_SHOW_WARBAND_REP_WARNING"] = "顯示戰隊沒有的聲望 [!]"
L["S_OPTIONS_SHOW_WORLDSHORTCUT_BUTTON"] = "顯示世界快捷按鈕"
L["S_OPTIONS_SHOWFACTIONS"] = "顯示陣營"
L["S_OPTIONS_TALKINGHEADS"] = "不顯示對話頭像"
L["S_OPTIONS_TIMELEFT_NOPRIORITY"] = "不要過濾剩餘時間"
L["S_OPTIONS_TRACKER_ATTACH_TO_QUESTLOG"] = "附加到任務追蹤清單"
L["S_OPTIONS_TRACKER_FLIGHTMASTER"] = "奧睿博司飛行管理員"
L["S_OPTIONS_TRACKER_RESETPOSITION"] = "重置位置"
L["S_OPTIONS_WORLD_ANCHOR_LEFT"] = "對齊左側"
L["S_OPTIONS_WORLD_ANCHOR_RIGHT"] = "對齊右側"
L["S_OPTIONS_WORLD_ICONSPERROW"] = "每行任務數量"
L["S_OPTIONS_WORLD_ORGANIZE_BYMAP"] = "依據地圖分類"
L["S_OPTIONS_WORLD_ORGANIZE_BYTYPE"] = "依據任務類型分類"
L["S_OPTIONS_WORLD_SUMMARY_ALPHA"] = "任務列表透明度"
L["S_OPTIONS_WORLDMAP_ANCHOR_TO"] = "附加到"
L["S_OPTIONS_WORLDMAP_ORGANIZEBY"] = "分類任務，依據"
L["S_OPTIONS_WORLDMAP_WIDGET_ALPHA"] = "地圖標記透明度"
L["S_OPTIONS_ZONE_SHOWONLYTRACKED"] = "只有已追蹤的"
L["S_OPTTIONS_AUTOACCEPT_ABANDONQUEST"] = "自動接受放棄任務"
L["S_OPTTIONS_DRAGONRACE_MINIMAP"] = "顯示小地圖追蹤"
L["S_OPTTIONS_DRAGONRACE_TRACKCOLOR"] = "追蹤顏色"
L["S_OPTTIONS_NUMERATE_QUEST"] = "列舉任務"
L["S_OPTTIONS_QUESTLOCATIONSCALE_BYWORLDMAP"] = "按照世界地圖縮放任務"
L["S_OPTTIONS_TAB_DRAGONRACE_SETTINGS"] = "飛龍競速"
L["S_OPTTIONS_TAB_GENERAL_SETTINGS"] = "一般設定"
L["S_OPTTIONS_TAB_GROUPFINDER_SETTINGS"] = "隊伍搜尋器"
L["S_OPTTIONS_TAB_IGNOREDQUESTS_SETTINGS"] = "已忽略的任務"
L["S_OPTTIONS_TAB_RARES_SETTINGS"] = "稀有怪"
L["S_OPTTIONS_TAB_TRACKER_SETTINGS"] = "追蹤清單"
L["S_OPTTIONS_TAB_WORLDMAP_SETTINGS"] = "世界地圖"
L["S_OPTTIONS_TAB_ZONEMAP_SETTINGS"] = "區域地圖"
L["S_OPTTIONS_WORLDMAP_HUB_ENABLE"] = "哪個世界地圖要顯示任務"
L["S_OVERALL"] = "整體"
L["S_PARTY"] = "隊伍"
L["S_PARTY_DESC1"] = "藍色星星表示所有隊伍成員都有這個任務。"
L["S_PARTY_DESC2"] = "如果顯示紅色星星，表示某個隊伍成員沒有世界任務，或尚未安裝世界任務追蹤插件。"
L["S_PARTY_PLAYERSWITH"] = "隊伍中有 WQT 的玩家:"
L["S_PARTY_PLAYERSWITHOUT"] = "隊伍中沒有 WQT 的玩家:"
L["S_QUESTSCOMPLETED"] = "完成任務"
L["S_QUESTTYPE_ARTIFACTPOWER"] = "神兵之力"
L["S_QUESTTYPE_DUNGEON"] = "地城"
L["S_QUESTTYPE_EQUIPMENT"] = "裝備"
L["S_QUESTTYPE_GOLD"] = "金幣"
L["S_QUESTTYPE_PETBATTLE"] = "寵物對戰"
L["S_QUESTTYPE_PROFESSION"] = "專業"
L["S_QUESTTYPE_PVP"] = "PvP"
L["S_QUESTTYPE_RESOURCE"] = "資源"
L["S_QUESTTYPE_TRADESKILL"] = "專業技能"
L["S_RAID"] = "團隊"
L["S_RAREFINDER_ADDFROMPREMADE"] = "加入預組隊伍中有的稀有怪"
L["S_RAREFINDER_NPC_NOTREGISTERED"] = "資料庫中沒有這個稀有怪"
L["S_RAREFINDER_OPTIONS_ENGLISHSEARCH"] = "永遠使用英文搜尋"
L["S_RAREFINDER_OPTIONS_SHOWICONS"] = "顯示在地圖上還活著的稀有怪圖示"
L["S_RAREFINDER_SOUND_ALWAYSPLAY"] = "停用音效時仍然要播放"
L["S_RAREFINDER_SOUND_ENABLED"] = "小地圖出現稀有怪時播放音效"
L["S_RAREFINDER_SOUNDWARNING"] = "小地圖上出現稀有怪時要播放音效，可以從選單 > 稀有怪搜尋器的子選單中停用音效。"
L["S_RAREFINDER_TITLE"] = "稀有怪搜尋器"
L["S_RAREFINDER_TOOLTIP_REMOVE"] = "移除"
L["S_RAREFINDER_TOOLTIP_SEACHREALM"] = "搜尋其他伺服器"
L["S_RAREFINDER_TOOLTIP_SPOTTEDBY"] = "發現於"
L["S_RAREFINDER_TOOLTIP_TIMEAGO"] = "分鐘前"
L["S_SCALE"] = "縮放大小"
L["S_SLASH_OPENMAP_FIRST"] = "尚未載入世界任務追蹤，請打開地圖來載入。"
L["S_SPEEDRUN"] = "競速"
L["S_SPEEDRUN_AUTO_ACCEPT"] = "自動接受任務"
L["S_SPEEDRUN_AUTO_COMPLETE"] = "自動完成任務"
L["S_SPEEDRUN_CANCEL_CINEMATIC"] = "自動跳過動畫"
L["S_SUMMARYPANEL_EXPIRED"] = "已過期"
L["S_SUMMARYPANEL_LAST15DAYS"] = "最近15天"
L["S_SUMMARYPANEL_LIFETIMESTATISTICS_ACCOUNT"] = "帳號上線統計"
L["S_SUMMARYPANEL_LIFETIMESTATISTICS_CHARACTER"] = "角色上線統計"
L["S_SUMMARYPANEL_OTHERCHARACTERS"] = "其他角色"
L["S_TEXT_SIZE"] = "文字大小"
L["S_TORGAST"] = "托迦司"
L["S_TRACKEROPTIONS_BACKGROUNDALPHA"] = "背景透明度"
L["S_TUTORIAL_AMOUNT"] = "表示可獲得的數量"
L["S_TUTORIAL_CLICKTOTRACK"] = "點一下追蹤任務。"
L["S_TUTORIAL_PARTY"] = "組隊時，藍色星星表示所有隊伍成員都有這些任務!"
L["S_TUTORIAL_STATISTICS_BUTTON"] = "點一下這裡瀏覽統計資料和其他角色所儲存的任務清單。"
L["S_TUTORIAL_TIMELEFT"] = "表示剩餘時間 (+4小時, +90分鐘, +30分鐘, 少於30分鐘)"
L["S_TUTORIAL_WORLDBUTTONS"] = [=[點一下這裡在三種列表類型中循環切換。

- |cFFFFAA11依據任務類型|r
- |cFFFFAA11依據區域|r
- |cFFFFAA11不顯示|r

點一下|cFFFFAA11切換顯示任務|r來隱藏任務位置。]=]
L["S_TUTORIAL_WORLDMAPBUTTON"] = "按下這個按鈕會顯示整個破碎群島的地圖。"
L["S_UNKNOWNQUEST"] = "未知的任務"
L["S_VISIBILITY"] = "顯示"
L["S_WHATSNEW"] = "更新資訊"
L["S_WORLDBUTTONS_SHOW_TYPE"] = "依據類型排列"
L["S_WORLDBUTTONS_SHOW_ZONE"] = "依據區域排列"
L["S_WORLDBUTTONS_TOGGLE_QUESTS"] = "切換顯示任務"
L["S_WORLDMAP_QUESTLOCATIONS"] = "顯示任務位置"
L["S_WORLDMAP_QUESTSUMMARY"] = "顯示任務列表"
L["S_WORLDMAP_TOOLTIP_TRACKALL"] = "追蹤這個列表中的所有任務"
L["S_WORLDQUESTS"] = "世界任務"
