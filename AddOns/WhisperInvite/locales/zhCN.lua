local ADDONNAME, WIC = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDONNAME, "zhCN")
if not L then return end

L["A "] = "启用"
L["Active"] = "启用"
L["Active module"] = "启用模块"
L["Add a new keyword."] = "添加新关键字"
L["Add here your invite keywords, one per line."] = "在此处添加您邀请的关键字，每行一个。"
L["Add keyword"] = "添加关键字"
L["Addon name not found!"] = "插件名称找不到!"
L["Advanced"] = "进阶"
-- L["AFK/DND Protection"] = "AFK/DND Protection"
L["All entry are case sensitive."] = "所有项目都是(英语-区分大小写)的。"
L["Alliance toons: %s"] = "联盟游戏角色: %s"
L["ALLOW"] = "允许"
L["And show me this infos: %s"] = "及显示给我此讯息: %s"
L["Answer"] = "回覆"
L["A%s"] = "允许%s"
L["Auto convert"] = "自动转换"
L["Basic"] = "基本"
L["Battle.net Channels"] = "Battle.net 频道"
L["Battle.net Channels where message will be checked for invite keywords."] = "Battle.net 频道中什么讯息将会检测邀请的关键字"
L["BLOCK"] = "停用"
L["Block invites"] = "停用邀请"
-- L["Block invites when you are AFK"] = "Block invites when you are AFK"
-- L["Block invites when you are DND"] = "Block invites when you are DND"
L["BNET_TAG"] = "Battle.net标签"
L["B%s"] = "禁用%s"
L["Cache has been cleaned."] = "缓存已被清除"
L["Cache has been reset."] = "缓存已被重置"
L["Can't load module. %s"] = "无法加载模块。%s"
L["Can't load module %s because %s"] = "无法加载模块%s因为%s"
L["Case sensitive"] = "(如:使用英语)区分大小写"
L["Case sensitive keyword matching."] = "(如:使用英语)区分大小写的关键字需完全匹配。"
L["Channels"] = "频道"
L["Channels where message will be checked for invite keywords."] = "频道中什么讯息将会检测邀请的关键字"
L["CHAT_MSG_BN_CONVERSATION"] = "聊天"
L["CHAT_MSG_BN_INLINE_TOAST_BROADCAST"] = "状态"
L["CHAT_MSG_BN_WHISPER"] = "密语"
L["CHAT_MSG_CHANNEL"] = "所有频道"
L["CHAT_MSG_GUILD"] = "公会"
L["CHAT_MSG_OFFICER"] = "公会干部"
L["CHAT_MSG_WHISPER"] = "密语"
L["Choose active module."] = "选择启用的模块。"
--[==[ L[ [=[Choose when you don't want to automatic invite other players when you are AFK or DND.
And if to send a message.]=] ] = [=[Choose when you don't want to automatic invite other players when you are AFK or DND.
And if to send a message.]=] ]==]
L[ [=[Choose when you don't want to automatic invite other players when you are in a LF-Queue.
]=] ] = [=[选择当你不想自动邀请其他玩家，当你处于寻找队伫(排副本)时。
]=] -- Needs review
L[ [=[Choose which Type of filter you want to add, all entries are case sensitive.

|cFF70DBFF%s:|r Filter only on playername 
|cFF70DBFF%s:|r Filter on playername and realm
|cFF70DBFF%s:|r Filter on guild (this will mostly only work with player of your realm)
|cFF70DBFF%s:|r Filter on guild and realm 
|cFF70DBFF%s:|r Filter player on realm
|cFF70DBFF%s:|r Filter player on Battle.net Tag (this work only with yours Battle.net friends. This will save Battle.net Tags to your SavedVariables for caching.)
|cFF70DBFF%s:|r Enter an existing filter to remove.]=] ] = [=[选择要添加的筛选器类型，(如果使用英语:所有条件都是区分大小写)。

|cFF70DBFF%s:|r 筛选只限玩家名称
|cFF70DBFF%s:|r 筛选只限玩家名称及服务器
|cFF70DBFF%s:|r 筛选只限公会(此功能主要只运作与你相同服务器的玩家)
|cFF70DBFF%s:|r 筛选只限公会及服务器
|cFF70DBFF%s:|r 筛选玩家于服务器
|cFF70DBFF%s:|r 筛选玩家于 Battle.net Tag(标签) (此运作只在于你的 Battle.net 朋友。此将保存 Battle.net Tags (标签) 到你的变量缓冲中)
|cFF70DBFF%s:|r 输入要删除现有筛选器.]=] -- Needs review
L[ [=[Choose which way the filter work.
|cFF70DBFF%s:|r Allow any where is not on the list
|cFF70DBFF%s:|r Allow only where is on the list]=] ] = [=[请选择运作的筛选方式。
|cFF70DBFF%s:|r 允许任未在名单中
|cFF70DBFF%s:|r 允许只有在名单中]=]
L["<command>"] = "<命令>"
L["Convert group to raid when group has reached maximal size."] = "已到达队伍群组上限需要切换至团队规模"
L["CS "] = "(英语-区分大小写)"
L["Custom block message"] = "自定义禁止讯息"
L["Delay(seconds) needed between to invites of the same player before, WhisperInvite can send a new invite."] = "延迟(秒)在需要邀请玩家之前,WhisperInvite 可以发送另一个新邀请."
L["Delete"] = "删除"
L["disable"] = "禁用"
L["Disabled"] = "禁用"
L["Display this custom message when a invite is blocked."] = "邀请被阻止时显示此自订的讯息。"
L["Do you really want to remove the keyword %q?"] = "你真的想要移除相应的关键字 %q 吗？"
L["E.g: %s"] = "例如:%s"
L["enable"] = "启用"
L["Enabled"] = "启用"
L["Entry"] = "输入"
L["Entry is not valid."] = "输入无效。"
L["Entry Type"] = "输入类型"
L["Filtering"] = "过滤"
L["Filter type"] = "过滤方式"
L["FM "] = "完全匹配"
L["Full match"] = "完全匹配"
L["G%s "] = "群组%s "
L["GUILD"] = "公会"
L["Guild Name"] = "公会名称"
L["GUILD_REALM"] = "公会服务器"
-- L["help"] = "help"
L["Horde toons: %s"] = "部落游戏角色: %s"
-- L["I'm currently AFK"] = "I'm currently AFK"
-- L["I'm currently DND"] = "I'm currently DND"
L["I'm currently in a LF-Queue"] = "我目前处于寻找队伫(排副本)"
L["Incorrect Battle.net Tag. %s"] = "错误 Battle.net 标签。%s"
L["Input"] = "汇入"
L["Invite player when they whisper you with a defined keyword."] = "邀请玩家当他们密告诉你用一个已定义的关键字。"
L["Invite player when they whisper you with a defined keyword where they are allowed to use."] = "邀请玩家当他们密你用一个已定义的关键字在那里他们被允许使用。"
L["Invite Throttle"] = "邀请频率"
L["Is blocked."] = "被阻止"
L["Is not allowed."] = "是不允许的。"
L["Is this keyword in use."] = "这关键字已使用。"
L["Is this profile enabled."] = "启用此配置文件。"
L["Keywords"] = "关键字"
L["LF-Queue Protection"] = "寻找队伫(排副本)保护"
L["LIST_ENTRY_TYPES_REMOVE"] = "删除过滤器"
L["Maximal group size"] = "最大群组规模"
L["Maximal group size reached. Can't invite %s"] = "已达到群组上限。不能邀请%s"
L["Message has to exactly match with the keyword."] = "讯息必须与关键字匹配。"
L["Module hasn't needed functions."] = "模块没有需要的功能。"
L["Module not found."] = "找不到模块。"
L["Modules: %s"] = "模块: %s"
L["No description for this module."] = "对这模块没有说明。"
L["No module selected!"] = "无模块选择！"
L["No Modules Registered"] = "没有注册的模块"
L["<No name given>"] = "没有名字"
L["No realm entered. %s"] = "无服务器输入%s"
L["<No toon name given>"] = "<无已知游戏角色名称>"
L["No value entered."] = "输入值无效。"
L["off"] = "关"
L["on"] = "开"
L["Pattern free matching"] = "无拘束匹配模式"
L["PF "] = "普通比赛"
L["PLAYER"] = "玩家"
L["PLAYER_REALM"] = "玩家-服务器"
L["Profile"] = "设定档"
L["REALM"] = "服务器"
L["Realm can't have '-' characters. %s"] = "服务器不能有 '-' 字符。%s"
L["Realm can't have white-space characters. %s"] = "服务器不能有空白字元。%s"
L["Remove this keyword."] = "删除此关键字"
L["Run /wi modules or /wi options to setup WisperInvite."] = "输入 /wi modules 或 /wi options 来设定 WisperInvite."
-- L["Send a message to inform that you are AFK."] = "Send a message to inform that you are AFK."
-- L["Send a message to inform that you are DND."] = "Send a message to inform that you are DND."
L["Send a message to inform that you have not send an invite because your are in a LF-Queue."] = "发送讯息通知你没有发送邀请，因为你处于寻找队伫(排副本)。"
L["Send an answer"] = "发送回覆"
L["%s Filter: %s"] = "%s 过滤: %s"
L["Show a message when a invite is blocked because of filtering."] = "显示由于筛选被封锁的邀请消息。"
L["Show block message"] = "显示被禁止消息"
L["%s is not online in World of Warcraft."] = "%s 已从魔兽中下线"
L["%s is with more then one toon online. Choose which toons should be invited. Click on the name to invite."] = "%s是与一个以上的游戏角色在线。选择应该邀请哪个游戏角色。点击名字邀请。"
L["%s - %s"] = true
L["%s (%s)"] = true
L["%s was not invited %s"] = "%s 已不接受邀请 %s"
L["%s was not invited: %s"] = "%s 没有被邀请: %s"
L["The message you will send."] = "你将会发送消息。"
L["The size the group can reach before this keyword stops to invite."] = "这个群组大小能控制到达上限后停止此关键字的邀请。"
L["toggle"] = "切换"
L["Type: %s"] = "类型: %s"
L["usage"] = "用法"
L["Usage: guild-realm e.g: %s-%s"] = "用法: 公会-服务器 例如: %s-%s"
L["Usage: name-realm e.g: %s-%s"] = "用法: 名称-服务器 例如: %s-%s"
L["Usage: /wia %s"] = "用法: /wia %s"
L[ [=[Usage: /wi <command>
Commands: modules, options]=] ] = [=[用法: /wi <命令>
命令: 模块,选项]=]
L["Usage: /wi modules moduleName (case sensitive)"] = "用法：/wi 模块 模块名(如:使用英语-区分大小写)"
L["Use %s entry type."] = "使用 %s  项目类型。"
L["When in the %q Queue block invites."] = "当在 %q 队列禁止邀请。"
L["WhisperInvite Basic Settings"] = "WhisperInvite 基本设置"
L["/wia cache clean||reset – Clean-up or reset cache"] = "/wia cache clean||reset – 清理或重置缓存"
L["/wia op||option – Open WhisperInviteAdvanced Options"] = "/wia op||option – 打开 WhisperInvite进阶 选项"
L["WisperInvite Advanced Settings"] = "WisperInvite 进阶设置"
L["WisperInvite Core Settings"] = "WisperInvite 核心设置"
L["Without pattern matching."] = "如果没有模式匹配。"
L["You are in an instance group and not in LFR or LFG group. When you can invite here players let me know it."] = "你现在处于一个实际团队&不处于随机团/随机队伍群组。当你可以在这里邀请玩家的时候就告诉我(本UI)吧。"
L["You can run /wienable to enable WisperInvite."] = "您可以输入 /wienable 令WisperInvite 启用。"
-- L["Your are AFK. Invite to %s was not sent."] = "Your are AFK. Invite to %s was not sent."
-- L["Your are DND. Haven't send an invite to %s"] = "Your are DND. Invite to %s was not sent."
-- L["Your are DND. Invite to %s was not sent."] = "Your are DND. Invite to %s was not sent."
L["Your are in a LF-Queue. Can't invite %s"] = "你是在处于寻找队伫(排副本)。不能邀请%s"
L["TOC/Notes"] = "自动邀请与关键字"
L["TOC/Notes.Advanced"] = "进阶邀请模块"
L["TOC/Notes.Basic"] = "基础邀请模块"
L["TOC/Title"] = "WhisperInvite 密语邀请"
L["TOC/Title.Advanced"] = "WhisperInvite 进阶"
L["TOC/Title.Basic"] = "WhisperInvite 基础"
