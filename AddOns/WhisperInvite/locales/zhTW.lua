local ADDONNAME, WIC = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDONNAME, "zhTW")
if not L then return end

L["A "] = "啟用" -- Needs review
L["Active"] = "啟用" -- Needs review
L["Active module"] = "啟用模組" -- Needs review
L["Add a new keyword."] = "添加新關鍵字" -- Needs review
L["Add here your invite keywords, one per line."] = "在此處添加您邀請的關鍵字，每行一個。" -- Needs review
L["Add keyword"] = "添加關鍵字" -- Needs review
L["Addon name not found!"] = "插件名稱找不到!" -- Needs review
L["Advanced"] = "進階" -- Needs review
-- L["AFK/DND Protection"] = "AFK/DND Protection"
L["All entry are case sensitive."] = "所有項目都是(英語-區分大小寫)的。" -- Needs review
L["Alliance toons: %s"] = "聯盟遊戲角色: %s" -- Needs review
L["ALLOW"] = "允許" -- Needs review
L["And show me this infos: %s"] = "及顯示給我此訊息: %s" -- Needs review
L["Answer"] = "回覆" -- Needs review
L["A%s"] = "允許%s" -- Needs review
L["Auto convert"] = "自動轉換" -- Needs review
L["Basic"] = "基本" -- Needs review
L["Battle.net Channels"] = "Battle.net 頻道" -- Needs review
L["Battle.net Channels where message will be checked for invite keywords."] = "Battle.net 頻道中什麼訊息將會檢測邀請的關鍵字" -- Needs review
L["BLOCK"] = "停用" -- Needs review
L["Block invites"] = "停用邀請" -- Needs review
-- L["Block invites when you are AFK"] = "Block invites when you are AFK"
-- L["Block invites when you are DND"] = "Block invites when you are DND"
L["BNET_TAG"] = "Battle.net標籤" -- Needs review
L["B%s"] = "禁用%s" -- Needs review
L["Cache has been cleaned."] = "緩存已被清除" -- Needs review
L["Cache has been reset."] = "緩存已被重置" -- Needs review
L["Can't load module. %s"] = "無法加載模組。%s" -- Needs review
L["Can't load module %s because %s"] = "無法加載模組%s因為%s" -- Needs review
L["Case sensitive"] = "(如:使用英語)區分大小寫" -- Needs review
L["Case sensitive keyword matching."] = "(如:使用英語)區分大小寫的關鍵字需完全匹配。" -- Needs review
L["Channels"] = "頻道" -- Needs review
L["Channels where message will be checked for invite keywords."] = "頻道中什麼訊息將會檢測邀請的關鍵字" -- Needs review
L["CHAT_MSG_BN_CONVERSATION"] = "聊天" -- Needs review
L["CHAT_MSG_BN_INLINE_TOAST_BROADCAST"] = "狀態" -- Needs review
L["CHAT_MSG_BN_WHISPER"] = "密語" -- Needs review
L["CHAT_MSG_CHANNEL"] = "所有頻道" -- Needs review
L["CHAT_MSG_GUILD"] = "公會" -- Needs review
L["CHAT_MSG_OFFICER"] = "公會幹部" -- Needs review
L["CHAT_MSG_WHISPER"] = "密語" -- Needs review
L["Choose active module."] = "選擇啟用的模組。" -- Needs review
--[==[ L[ [=[Choose when you don't want to automatic invite other players when you are AFK or DND.
And if to send a message.]=] ] = [=[Choose when you don't want to automatic invite other players when you are AFK or DND.
And if to send a message.]=] ]==]
L[ [=[Choose when you don't want to automatic invite other players when you are in a LF-Queue.
]=] ] = [=[選擇當你不想自動邀請其他玩家，當你處於尋找隊佇(排副本)時。
]=] -- Needs review
L[ [=[Choose which Type of filter you want to add, all entries are case sensitive.

|cFF70DBFF%s:|r Filter only on playername 
|cFF70DBFF%s:|r Filter on playername and realm
|cFF70DBFF%s:|r Filter on guild (this will mostly only work with player of your realm)
|cFF70DBFF%s:|r Filter on guild and realm 
|cFF70DBFF%s:|r Filter player on realm
|cFF70DBFF%s:|r Filter player on Battle.net Tag (this work only with yours Battle.net friends. This will save Battle.net Tags to your SavedVariables for caching.)
|cFF70DBFF%s:|r Enter an existing filter to remove.]=] ] = [=[選擇要添加的篩選器類型，(如果使用英語:所有條件都是區分大小寫)。

|cFF70DBFF%s:|r 篩選只限玩家名稱
|cFF70DBFF%s:|r 篩選只限玩家名稱及伺服器
|cFF70DBFF%s:|r 篩選只限公會(此功能主要只運作與你相同伺服器的玩家)
|cFF70DBFF%s:|r 篩選只限公會及伺服器
|cFF70DBFF%s:|r 篩選玩家於伺服器
|cFF70DBFF%s:|r 篩選玩家於 Battle.net Tag(標籤) (此運作只在於你的 Battle.net 朋友。此將保存 Battle.net Tags (標籤) 到你的變量緩衝中)
|cFF70DBFF%s:|r 輸入要刪除現有篩選器.]=] -- Needs review
L[ [=[Choose which way the filter work.
|cFF70DBFF%s:|r Allow any where is not on the list
|cFF70DBFF%s:|r Allow only where is on the list]=] ] = [=[請選擇運作的篩選方式。
|cFF70DBFF%s:|r 允許任未在名單中
|cFF70DBFF%s:|r 允許只有在名單中]=] -- Needs review
L["<command>"] = "<命令>" -- Needs review
L["Convert group to raid when group has reached maximal size."] = "已到達隊伍群組上限需要切換至團隊規模" -- Needs review
L["CS "] = "(英語-區分大小寫)" -- Needs review
L["Custom block message"] = "自定義禁止訊息" -- Needs review
L["Delay(seconds) needed between to invites of the same player before, WhisperInvite can send a new invite."] = "延遲(秒)在需要邀請玩家之前,WhisperInvite 可以發送另一個新邀請." -- Needs review
L["Delete"] = "刪除" -- Needs review
L["disable"] = "禁用" -- Needs review
L["Disabled"] = "禁用" -- Needs review
L["Display this custom message when a invite is blocked."] = "邀請被阻止時顯示此自訂的訊息。" -- Needs review
L["Do you really want to remove the keyword %q?"] = "你真的想要移除相應的關鍵字 %q 嗎？" -- Needs review
L["E.g: %s"] = "例如:%s" -- Needs review
L["enable"] = "啟用" -- Needs review
L["Enabled"] = "啟用" -- Needs review
L["Entry"] = "輸入" -- Needs review
L["Entry is not valid."] = "輸入無效。" -- Needs review
L["Entry Type"] = "輸入類型" -- Needs review
L["Filtering"] = "過濾" -- Needs review
L["Filter type"] = "過濾方式" -- Needs review
L["FM "] = "完全匹配" -- Needs review
L["Full match"] = "完全匹配" -- Needs review
L["G%s "] = "群組%s " -- Needs review
L["GUILD"] = "公會" -- Needs review
L["Guild Name"] = "公會名稱" -- Needs review
L["GUILD_REALM"] = "公會伺服器" -- Needs review
-- L["help"] = "help"
L["Horde toons: %s"] = "部落遊戲角色: %s" -- Needs review
-- L["I'm currently AFK"] = "I'm currently AFK"
-- L["I'm currently DND"] = "I'm currently DND"
L["I'm currently in a LF-Queue"] = "我目前處於尋找隊佇(排副本)" -- Needs review
L["Incorrect Battle.net Tag. %s"] = "錯誤 Battle.net 標籤。%s" -- Needs review
L["Input"] = "匯入" -- Needs review
L["Invite player when they whisper you with a defined keyword."] = "邀請玩家當他們密告訴你用一個已定義的關鍵字。" -- Needs review
L["Invite player when they whisper you with a defined keyword where they are allowed to use."] = "邀請玩家當他們密你用一個已定義的關鍵字在那裡他們被允許使用。" -- Needs review
L["Invite Throttle"] = "邀請頻率" -- Needs review
L["Is blocked."] = "被阻止" -- Needs review
L["Is not allowed."] = "是不允許的。" -- Needs review
L["Is this keyword in use."] = "這關鍵字已使用。" -- Needs review
L["Is this profile enabled."] = "啟用此配置文件。" -- Needs review
L["Keywords"] = "關鍵字" -- Needs review
L["LF-Queue Protection"] = "尋找隊佇(排副本)保護"
L["LIST_ENTRY_TYPES_REMOVE"] = "刪除過濾器" -- Needs review
L["Maximal group size"] = "最大群組規模" -- Needs review
L["Maximal group size reached. Can't invite %s"] = "已達到群組上限。不能邀請%s" -- Needs review
L["Message has to exactly match with the keyword."] = "訊息必須與關鍵字匹配。" -- Needs review
L["Module hasn't needed functions."] = "模組沒有需要的功能。" -- Needs review
L["Module not found."] = "找不到模組。" -- Needs review
L["Modules: %s"] = "模組: %s" -- Needs review
L["No description for this module."] = "對這模組沒有說明。" -- Needs review
L["No module selected!"] = "無模組選擇！" -- Needs review
L["No Modules Registered"] = "沒有註冊的模組" -- Needs review
L["<No name given>"] = "沒有名字" -- Needs review
L["No realm entered. %s"] = "無伺服器輸入%s" -- Needs review
L["<No toon name given>"] = "<無已知遊戲角色名稱>" -- Needs review
L["No value entered."] = "輸入值無效。" -- Needs review
L["off"] = "關" -- Needs review
L["on"] = "開" -- Needs review
L["Pattern free matching"] = "無拘束匹配模式" -- Needs review
L["PF "] = "普通比賽" -- Needs review
L["PLAYER"] = "玩家" -- Needs review
L["PLAYER_REALM"] = "玩家-伺服器" -- Needs review
L["Profile"] = "設定檔" -- Needs review
L["REALM"] = "伺服器" -- Needs review
L["Realm can't have '-' characters. %s"] = "伺服器不能有 '-' 字元。%s" -- Needs review
L["Realm can't have white-space characters. %s"] = "伺服器不能有空白字元。%s" -- Needs review
L["Remove this keyword."] = "刪除此關鍵字" -- Needs review
L["Run /wi modules or /wi options to setup WisperInvite."] = "輸入 /wi modules 或 /wi options 來設定 WisperInvite." -- Needs review
-- L["Send a message to inform that you are AFK."] = "Send a message to inform that you are AFK."
-- L["Send a message to inform that you are DND."] = "Send a message to inform that you are DND."
L["Send a message to inform that you have not send an invite because your are in a LF-Queue."] = "發送訊息通知你沒有發送邀請，因為你處於尋找隊佇(排副本)。" -- Needs review
L["Send an answer"] = "發送回覆" -- Needs review
L["%s Filter: %s"] = "%s 過濾: %s" -- Needs review
L["Show a message when a invite is blocked because of filtering."] = "顯示由於篩選被封鎖的邀請消息。" -- Needs review
L["Show block message"] = "顯示被禁止消息" -- Needs review
L["%s is not online in World of Warcraft."] = "%s 已從魔獸中下線" -- Needs review
L["%s is with more then one toon online. Choose which toons should be invited. Click on the name to invite."] = "%s是與一個以上的遊戲角色在線。選擇應該邀請哪個遊戲角色。點擊名字邀請。" -- Needs review
L["%s - %s"] = true -- Needs review
L["%s (%s)"] = true -- Needs review
L["%s was not invited %s"] = "%s 已不接受邀請 %s" -- Needs review
L["%s was not invited: %s"] = "%s 沒有被邀請: %s" -- Needs review
L["The message you will send."] = "你將會發送消息。" -- Needs review
L["The size the group can reach before this keyword stops to invite."] = "這個群組大小能控制到達上限後停止此關鍵字的邀請。" -- Needs review
L["toggle"] = "切換" -- Needs review
L["Type: %s"] = "類型: %s" -- Needs review
L["usage"] = "用法" -- Needs review
L["Usage: guild-realm e.g: %s-%s"] = "用法: 公會-伺服器 例如: %s-%s" -- Needs review
L["Usage: name-realm e.g: %s-%s"] = "用法: 名稱-伺服器 例如: %s-%s" -- Needs review
L["Usage: /wia %s"] = "用法: /wia %s" -- Needs review
L[ [=[Usage: /wi <command>
Commands: modules, options]=] ] = [=[用法: /wi <命令>
命令: 模組,選項]=] -- Needs review
L["Usage: /wi modules moduleName (case sensitive)"] = "用法：/wi 模組 模組名(如:使用英語-區分大小寫)" -- Needs review
L["Use %s entry type."] = "使用 %s  項目類型。" -- Needs review
L["When in the %q Queue block invites."] = "當在 %q 隊列禁止邀請。" -- Needs review
L["WhisperInvite Basic Settings"] = "WhisperInvite 基本設置" -- Needs review
L["/wia cache clean||reset – Clean-up or reset cache"] = "/wia cache clean||reset – 清理或重置緩存" -- Needs review
L["/wia op||option – Open WhisperInviteAdvanced Options"] = "/wia op||option – 打開 WhisperInvite進階 選項" -- Needs review
L["WisperInvite Advanced Settings"] = "WisperInvite 進階設置" -- Needs review
L["WisperInvite Core Settings"] = "WisperInvite 核心設置" -- Needs review
L["Without pattern matching."] = "如果沒有模式匹配。" -- Needs review
L["You are in an instance group and not in LFR or LFG group. When you can invite here players let me know it."] = "你現在處於一個實際團隊&不處於隨機團/隨機隊伍群組。當你可以在這裡邀請玩家的時候就告訴我(本UI)吧。" -- Needs review
L["You can run /wienable to enable WisperInvite."] = "您可以輸入 /wienable 令WisperInvite 啟用。" -- Needs review
-- L["Your are AFK. Invite to %s was not sent."] = "Your are AFK. Invite to %s was not sent."
-- L["Your are DND. Haven't send an invite to %s"] = "Your are DND. Invite to %s was not sent."
-- L["Your are DND. Invite to %s was not sent."] = "Your are DND. Invite to %s was not sent."
L["Your are in a LF-Queue. Can't invite %s"] = "你是在處於尋找隊佇(排副本)。不能邀請%s" -- Needs review
L["TOC/Notes"] = "自動邀請與關鍵字" -- Needs review
L["TOC/Notes.Advanced"] = "進階邀請模組" -- Needs review
L["TOC/Notes.Basic"] = "基礎邀請模組" -- Needs review
L["TOC/Title"] = "WhisperInvite 密語邀請"
L["TOC/Title.Advanced"] = "WhisperInvite 進階" -- Needs review
L["TOC/Title.Basic"] = "WhisperInvite 基礎"
