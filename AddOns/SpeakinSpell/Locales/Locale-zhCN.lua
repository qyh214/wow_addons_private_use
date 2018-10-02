-- Simplified Chinese
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("SpeakinSpell", "zhCN", false)
if not L then return end

SpeakinSpell:PrintLoading("Locales/Locale-zhCN.lua")

-------------------------------------------------------------------------------
-- Exported from http://www.wowace.com/addons/speakinspell/localization/export/
-- 2011-11-30, 9pm EST
-------------------------------------------------------------------------------

L[ [=[
Send queue
size:<queuesize>
peek:<queuepeek>

Total Sent
user data:<rawqueued>
actual:<sentactual>
Compressed to <sendcompression>%

Total Received
actual:<receivedactual>
user data:<receiveduser>
Compressed to <receivedcompression>%

Actual Sent - Received = <deficit>

LibSmartComm overhead
for packets:<overheadpacket>
for addonid:<overheadid>
total:<overheadlsc>
percent overhead:<overheadpercent>%

Overhead per packet
compressed:<packovercomp>
uncompressed:<packoverraw>
total packets:<numpackets>

addonid prefix:<prefixsize>
total segments:<segments>
]=] ] = [=[发送序列
大小:<queuesize>
预览:<queuepeek>

总计已发送
用户数据:<rawqueued>
目前:<sentactual>
压缩到 <sendcompression>%

总计已接收
目前:<receivedactual>
用户数据:<receiveduser>
压缩到 <receivedcompression>%

目前 发送 - 接收 = <deficit>

LibSmartComm 开销
包:<overheadpacket>
addonid:<overheadid>
总计<overheadlsc>
开销百分比:<overheadpercent>%

每包的开销
压缩的:<packovercomp>
未压缩的:<packoverraw>
总计包:<numpackets>

addonid 前缀:<prefixsize>
总计分段:<segments>
]=] -- Needs review
L[" is OFF"] = "已关闭"
L[" is ON"] = "已打开"
L["(<type>) <name>"] = [=[(<type>) <name>
]=] -- Needs review
L["*"] = "*" -- Needs review
L["* <player> <emotes> *"] = [=[* <player> <emotes> *
]=] -- Needs review
L["/ss macro things you type"] = "/ss 把你输入的东西作成宏"
L["1. About SpeakinSpell"] = "1. 关于 SpeakinSpell"
L["1. Search..."] = "1. 搜索..."
L["2. Select..."] = "2. 选择..."
L["3. Edit..."] = "3. 编辑..."
L["3.1.2.05 /macro"] = "宏"
L["3.2.2.02 <newline>"] = "<新一行>"
L["3.2.2.14 Entering Combat"] = "进入战斗"
L["3.2.2.14 Exiting Combat"] = "退出战斗"
L["3.2.2.14 Whispered While In-Combat"] = "战斗中密语"
L["<"] = "<" -- Needs review
L["<(.-)>"] = "<(.-)>" -- Needs review
L["<EventTypePrefix><name>"] = "<EventTypePrefix><name>" -- Needs review
L["<basecolor><colormatchedname>"] = [=[<basecolor><colormatchedname>
]=] -- Needs review
L["<basecolor><eventtypeprefix><colormatchedname>"] = [=[<basecolor><eventtypeprefix><colormatchedname>
]=] -- Needs review
L["<basecolor><eventtypeprefix><colormatchedname> (<rank>)"] = [=[<basecolor><eventtypeprefix><colormatchedname> (<rank>)
]=] -- Needs review
L["<clickhere> to review recent events and speeches"] = "<点这里> 查看最近的事件和对话"
L["<creator's> random <susbtitution> word lists, shared with you over the network"] = "<creator's> 随机 <susbtitution> 词汇列表，在网络上共享"
L["<creator's> shared random substitutions"] = "<creator's> 共享的随机替换"
L["<toon's> speeches (<realm>)"] = "<toon's> 讲话 (<realm>)"
L["A Battleground"] = "一个战场"
L["A Party"] = "一个小队"
L["A Raid"] = "一个团队"
L["AUTO"] = "自动"
L["Achievement Earned by "] = "获得成就 "
L["Achievements"] = "成就"
L["Added <randomkey>: <newword>"] = "添加 <randomkey>: <newword>"
L["Added speech: <speech>"] = "添加讲话: <speech>"
L["Added speeches for <displayname>"] = "为 <displayname> 添加讲话"
L["Added word list for <keyword>"] = "为 <keyword> 添加词汇列表"
L["All Ranks"] = "所有声望"
L["All sending is complete (for now)"] = "全部发送完成 (现在)"
L["Always use <language>"] = "一直使用 <language>"
L["Any Rank"] = "任意声望"
L["Arcane"] = "奥术"
L["Auto-Sync Options"] = "自动同步选项"
L["Begin /follow"] = "开始 /follow"
L["Browse Collected Content"] = "浏览已收集的内容"
L["Buffs from Others (includes totems)"] = "别人给的增益 (包括图腾)"
L["By yourself"] = "你自己"
L["Changed Sub-Zone"] = "更换子区域"
L["Changed Zone"] = "更换区域"
L["Channeled Spells Start"] = "引导法术开始"
L["Channeled Spells Stop"] = "引导法术结束"
L["Chat Channel Colors"] = "聊天通道颜色"
L["Chat Event: "] = "聊天事件："
L["Chat Events"] = "聊天事件"
L["Click here to create settings for a new spell, ability, effect, macro, or other event"] = "点击这里创建新的 施法、技能、效果、宏或其他事件 的设置"
L["Click|r to toggle SpeakinSpell on/off"] = "点击|r 切换 SpeakinSpell 开/关"
L["Collect Speeches"] = "收集讲话"
L["Colors"] = "颜色"
L["Colors used by SpeakinSpell"] = "SpeakinSpell 用的颜色"
L["Colors used in the SS options GUI"] = "SpeakinSpell 选项窗口用的颜色"
L["Combat Event: "] = "战斗事件："
L["Combat Events"] = "战斗事件"
L["Cooldown (seconds)"] = "冷却 (秒)"
L["Create New..."] = "创建新的..."
L["Create Speech Event"] = "创建讲话事件"
L["Create a New Speech Event"] = "创建一个新的讲话事件"
L["Critical Strike"] = "暴击"
L["DO NOT PRESS THIS BUTTON"] = "`别`按`这`个`按`钮`"
L["Data Sharing"] = "数据共享"
L["Debuffs from Others"] = "别人给的减益"
L["Default settings restored"] = "恢复默认设置"
L["Delete"] = "删除"
L["Delete All Speeches"] = "删除所有讲话"
L["Delete Word List"] = "删除词汇列表"
L["Delete this Event"] = "删除此事件"
L["Delete this speech"] = "删除此讲话"
L["Diagnostics"] = "诊断"
L["EMOTE"] = "表情 (/em)"
L["Each Packet Sent"] = "逐包发送" -- Needs review
L["Edit"] = "编辑"
L["Edit Macro Event"] = "编辑宏事件"
L["Edit Speech / Announcement Settings"] = "编辑讲话/通告设置"
L["Edit Speeches"] = "编辑讲话"
L["Edit the values that may be used for random <substitutions>"] = "为随机 <substitutions> 编辑值" -- Needs review
L["Empty Template"] = "空模版"
L["Enable Automatic SpeakinSpell Event Announcements"] = "允许 SpeakinSpell 自动事件" -- Needs review
L[ [=[Enable this option to make SpeakinSpell show you (and only you) all of your own spell casting events and other events that can be announced.

This includes any spell, ability, item, /ss macro things, or automatically obtained effect (e.g. Trinkets or Talents) that you cast or use.]=] ] = [=[让 SpeakinSpell 只显示你自己的法术事件和其他事件。

包含所有你能使用的法术、技能、物品、/ss macro 事件，或自动触发效果（如饰品或天赋）。]=] -- Needs review
L["Enable this option to show an overwhelming amount of information"] = "显示详细信息" -- Needs review
L[ [=[Enable to show different ranks of spells and abilities, including Polymorph critters.

If disabled, any rank of the spell will count.]=] ] = [=[显示法术、技能等级，包括变形技能。

禁止此选项，所有法术等级将被忽略]=] -- Needs review
L[ [=[Enable to show more than 100 search results in the drop-down list below.

Enabling this option can slow down the performance of this window (capped at 200 max to avoid memory overflows).]=] ] = [=[允许下拉列表中显示超过100个搜索结果。

开启后将减慢系统运行速度（200最大上限，以避免内存溢出）。]=] -- Needs review
L[ [=[Enable to show more than 100 search results in the drop-down list below.

Enabling this option can slow down the performance of this window. (capped at 200 max to avoid memory overflows)]=] ] = [=[允许下拉列表中显示超过100个搜索结果。

开启后将减慢系统运行速度（200最大上限，以避免内存溢出）。]=] -- Needs review
L["Enable to show the event hooks that you already use."] = "显示已经使用的事件钩子" -- Needs review
L["End /follow"] = "结束 /follow"
L["End Casting (I'm not involved)"] = "施法结束 (跟我无关)"
L["End Casting (I'm the caster)"] = "施法结束 (我是施法者)"
L["End Casting (I'm the target)"] = "施法结束 (我是目标)"
L["Enemy of <name>"] = "<name> 的目标"
L["Enter Barber Chair"] = "坐上理发椅"
L["Entering Combat"] = "进入战斗"
L["Exit Barber Chair"] = "离开理发椅"
L["Exiting Combat"] = "退出战斗"
L["Expand /ss macros as lists-only"] = "仅展开 /ss macros 列表" -- Needs review
L["Expired or Declined"] = "过期或拒绝"
L["Found a SpeakinSpell User <username> running v<version>"] = "找到一个 SpeakinSpell 用户 <username> 正在运行 v<version>" -- Needs review
L["GUILD"] = "工会 (/g)"
L["General"] = "常规"
L["General Auto-Sync"] = "自动同步" -- Needs review
L["General Auto-Sync Failed"] = "自动同步失败" -- Needs review
L["General Settings"] = "常规设置"
L["General Settings for SpeakinSpell"] = "SpeakinSpell 常规设置"
L["Global Cooldown"] = "公共冷却"
L["Global Sync"] = "全局同步"
L["Headings"] = "标题"
L["Help"] = "帮助"
L["Hide"] = "隐藏"
L["Hide All"] = "全部隐藏"
L["Hide all <randomsub> word lists for the selected content pack, and unload them from memory"] = "为选择的内容包隐藏所有 <randomsub> 词汇列表，并从内存卸载" -- Needs review
L["Hide all remaining new content and unload it from memory"] = "隐藏所有剩余新内容并从内存卸载" -- Needs review
L["Hide all remaining new content in the selected content pack and unload it from memory"] = "在选择的内容包中隐藏所有剩余新内容，并从内存中卸载" -- Needs review
L["Hide all remaining speech events for the selected content pack, and unload them from memory"] = "在选择的内容包中隐藏所有剩余对话事件，并从内存中卸载" -- Needs review
L["Hide all remaining speeches for the selected event, and unload the selected event template from memory"] = "在选择的事件中，隐藏所有剩余台词，并从内容中卸载选择的事件" -- Needs review
L["Holy"] = "神圣" -- Needs review
L["How Often? <selectedevent>"] = "频率? <selectedevent>"
L["How often you say (Cooldowns/Limits)"] = "你说的频率 (冷却/限制) "
L["However, \"/ss macro something\" will still trigger announcements if run manually"] = "“/ss macro something” 在手动模式将一直工作" -- Needs review
L["I Died"] = "我死了"
L["If you have an event trigger that does not appear to be firing, this option will tell you which setting silenced the announcement of that event, for example because it's on cooldown, or the random chance failed."] = "如果你有一个事件触发器不工作，这个选项将告诉你哪个设定禁言了事件广播，比如因为会话没有冷却，或随机改变失败。" -- Needs review
L["Import All <randomsubs>"] = "导入所有 <randomsubs>" -- Needs review
L["Import All Speech Events for the Selected Template"] = "为选择的模板导入所有对话事件" -- Needs review
L["Import All Templates"] = "导入所有模板" -- Needs review
L["Import All Words"] = "导入所有词汇" -- Needs review
L["Import All speeches for the Selected Speech Event"] = "为选择的对话事件导入所有台词" -- Needs review
L["Import Events"] = "导入事件"
L["Import Macro's List"] = "导入宏列表" -- Needs review
L["Import New Content"] = "导入新内容" -- Needs review
L["Import New Data"] = "导入新数据" -- Needs review
L["Import Whole Template"] = "导入整个模板" -- Needs review
L["Import all content from all templates"] = "从所有模板导入所有内容" -- Needs review
L["Import all speech events, and their speeches, for the selected content pack"] = "为选择的内容包导入所有对话事件和它们的台词" -- Needs review
L["Import all speeches for the selected event"] = "为选择的事件导入所有台词" -- Needs review
L["Importing Template: <name>"] = "导入模板: <name>"
L["In Arena"] = "在竞技场中"
L["In Wintergrasp"] = "在冬泳湖战斗中" -- Needs review
L["In a Battleground"] = "在战场中"
L["In a Party"] = "在队伍中"
L["In a Raid"] = "在团队中"
L["Information"] = "信息"
L["Interaction with NPCs"] = "与 NPC 交互"
L["Killing Blow"] = "致死打击"
L["Language"] = "语言"
L["Level Up"] = "升级"
L["Limit once per <target>"] = "限制每 <target> 一次"
L["Limit once per combat"] = "限制每战斗一次"
L["MYSTERIOUS VOICE"] = "[神秘的声音] 密语:"
L["Melee Swing"] = "打斗间隔"
L["Memory Used: <kb> kb"] = "内存占用: <kb> kb"
L["Merged speeches for <displayname>"] = "与 <displayname> 合并台词" -- Needs review
L["Merged word list for <keyword>"] = "与 <keyword> 合并单词列表" -- Needs review
L["Message Settings"] = "信息设置"
L["Misc. Event: "] = "杂项: "
L["Misc. Events"] = "杂项"
L["Mounts and Pets"] = "坐骑与宠物"
L["NEW? reply canceled - all event hooks are already known to <target>"] = "新的？应答已取消－所有事件钩子挂到 <target>" -- Needs review
L["Nature"] = "自然"
L["Network Error"] = "网络错误" -- Needs review
L["Network Error: "] = "网络错误：" -- Needs review
L["Network stats unavailable"] = "网络状态不可用" -- Needs review
L["Networking Options and Commands"] = "网络选项和命令" -- Needs review
L["New Content Browser"] = "新的内容浏览器" -- Needs review
L["New Word List"] = "新建词汇列表"
L[ [=[New content is not currently loaded in memory.

Click the button below to continue.

This will scan for new content among:
- The default speeches that come with SpeakinSpell
- Your alternate characters
- Data collected from other SpeakinSpell users
]=] ] = [=[新内容当前未加载到内存。

点击下面的按钮继续。

将扫描下列内容：
－SpeakinSpell 默认台词
－你的备选角色
－从其他 SpeakinSpell 使用者收集数据]=] -- Needs review
L["Newer version available: "] = "新版本可用: "
L["No Matching Search Results Found"] = "没有匹配的搜索结果" -- Needs review
L["No New Events to Send to <target>"] = "没有新事件发送到 <target>" -- Needs review
L["No channels are available. For global syncs, join a guild, party, raid, or battleground."] = "无可用频道。如要全局同步，加入一个公会、小队、团队或战场。" -- Needs review
L[ [=[OFF = All of your characters will use separate lists of event triggers and random speeches, which you can copy from one to the other using "/ss import"

ON = All of your characters will share the same event triggers and speeches

Toggling this option will merge or split your settings between all of your characters]=] ] = [=[关 ＝ 所有角色使用独立的事件触发器和随机台词，你能使用“/ss import”在角色间拷贝这些设置。

开 ＝ 所有角色共享同样的事件触发器和随机台词。

开关这个选项将分割或合并你角色间的设置。]=] -- Needs review
L["OFF|r"] = "关|r"
L["ON|r"] = "开|r"
L["Open Mailbox"] = "打开邮箱"
L["Open Trade Window"] = "打开交易窗口"
L["Open the User's Manual"] = "打开用户手册"
L["Open the event settings to edit speeches and other options for When I Type: "] = "当我键入 …… 打开事件设置编辑台词和其他选项：" -- Needs review
L["Outland"] = "外域"
L["PARTY"] = "小队 (/p)"
L["PLAYER"] = "玩家"
L["Party Leader"] = "队长"
L["Party Leadership Mode"] = "队长模式"
L["Physical"] = "物理"
L["RAID"] = "团队 (/ra)"
L["RAID_BOSS_WHISPER"] = "首领密语"
L["RAID_WARNING"] = "团队警告 (/rw)"
L["Raid Leader"] = "团队领袖"
L["Raid Leadership Mode"] = "团队领袖模式"
L["Raid Officer"] = "团队指挥官"
L["Raid Officer Mode"] = "团队指挥官模式"
L["Random"] = "随机"
L["Random Chance (%)"] = "概率 (%)"
L["Random Speech <number>"] = "随机讲话 <number>"
L["Random Substitutions"] = "随机替换"
L["Random Substitutions like <randomtaunt> and <randomfaction>"] = "随机替换如 <randomtaunt> 和 <randomfaction>"
L["Random Substutitions"] = "随机替换"
L["Random Word <number>"] = "随机词 <number>"
L["Read-Only"] = "只读"
L["Receive Data"] = "接收数据"
L["Received new event hooks"] = "收到新事件钩子" -- Needs review
L["Recent Events Detected..."] = "最近侦测到的事件" -- Needs review
L["Remove the selected spell from the list"] = "从列表移除选择的法术" -- Needs review
L["Report import processing results in the chat frame"] = "在聊天框体报告导入进度结果" -- Needs review
L["Reset Event List"] = "重置事件列表" -- Needs review
L["Reset the list of event hooks to the default basic list, removing all discovered and collected event hooks"] = "重置事件钩子列表到初始状态，移除所有侦测和收集到的事件钩子" -- Needs review
L["Resurrection: "] = "恢复: "
L["Right-click|r to open the options"] = "右键|r 打开选项" -- Needs review
L["SAY"] = "说 (/s)"
L["SELF RAID WARNING CHANNEL"] = "自己的团队警告"
L["SPEAKINSPELL CHANNEL"] = "自言自语 (SpeakinSpell:)"
L["SS Network "] = "SS 网络 "
L["Search"] = "搜索"
L["Search Match"] = "搜索适配"
L["Select a Category of Events"] = "选择一个事件类别"
L["Select a Content Pack"] = "选择一个事件包"
L["Select a Speech Event"] = "选择讲话事件"
L["Select a Template"] = "选择模板" -- Needs review
L["Select a spell from the list to configure the random announcements for that spell."] = "为法术选择随机通告配置" -- Needs review
L["Select a topic..."] = "选择一个主题" -- Needs review
L["Select and Create"] = "选择并创建"
L["Select the channel to use for this spell, while..."] = "当……的时候，为此语句选择频道" -- Needs review
L["Select the new spell event you want to announce in chat above, then push this button"] = "选择你想在聊天窗口通告的法术事件，然后按这个键" -- Needs review
L[ [=[Select the racial game language you want to use to announce these speeches

This option will be ignored if you set the "Always Use Common" option under general settings.]=] ] = [=[为这些语句选择种族语言

当你在综合设置中选上了“总是使用通用语言”时，此选项就不会起作用。]=] -- Needs review
L["Select which channel to use for this spell while in a Battleground"] = "战场中使用哪个聊天频道" -- Needs review
L["Select which channel to use for this spell while in a Party"] = "小队中使用哪个聊天频道" -- Needs review
L["Select which channel to use for this spell while in a Raid"] = "团队中使用哪个聊天频道" -- Needs review
L["Select which channel to use for this spell while playing in a Wintergrasp battle.  This only applies during an active battle."] = "冬泳湖中使用哪个聊天频道。仅在冬泳湖战斗激活情况下生效。" -- Needs review
L["Select which channel to use for this spell while playing in the Arena"] = "竞技场中使用哪个聊天频道" -- Needs review
L["Select which channel to use for this spell while playing solo"] = "单人时使用哪个聊天频道" -- Needs review
L["Selected Event: "] = "选择事件" -- Needs review
L["Selected Item"] = "选择物品" -- Needs review
L["Self Buffs (includes procs)"] = "自身增益（包括特效）" -- Needs review
L["Self Debuffs"] = "自身减益" -- Needs review
L["Self Raid Warnings"] = "自身团队警告" -- Needs review
L["Self-Chat"] = "自言自语"
L["Send Complete: <command> -> <target>"] = "发送完成：<command> -> <target>" -- Needs review
L["Send Data"] = "发送数据" -- Needs review
L["Send a data sharing request to GUILD, RAID, PARTY, and INSTANCE_CHAT channels every time you login or /reloadui"] = "每次登录或重载界面就发送一个数据共享请求到 公会，团队，小队和战场频道" -- Needs review
L[ [=[Send a data sharing request to GUILD, RAID, PARTY, and INSTANCE_CHAT channels.

Same as "/ss sync"]=] ] = "发送一个数据共享请求到 公会，团队，小队和战场频道" -- Needs review
L[ [=[Send a data sharing request to your selected target.

Same as "/ss sync <target>"]=] ] = "发送一个数据共享请求到你选择的目标" -- Needs review
L["Send to <target> <command>"] = "发送到 <target> <command>"
L["Setup guides are enabled. <clickhere> to disable them"] = "安装指南已启用。<clickhere> 关闭它" -- Needs review
L["Setup guides have been disabled. <clickhere> to enable them"] = "安装指南已关闭。<clickhere> 启用它" -- Needs review
L["Shadow"] = "阴影" -- Needs review
L["Share Speeches for All Characters"] = "共享台词到所有角色" -- Needs review
L["Share my detected event hooks"] = "共享我侦测到的事件钩子（如使用了某样物品，改变了某个区域）" -- Needs review
L["Share my list of New Events Detected from the \"/ss create\" interface"] = "共享使用“/ss create”命令后侦测到的新事件列表" -- Needs review
L["Share my random <substitutions>"] = "共享我的随机 <substitutions>" -- Needs review
L["Share my speeches"] = "共享我的台词" -- Needs review
L["Share the speeches I have written for SpeakinSpell events"] = "共享我为 SpeakinSpell 事件撰写的台词" -- Needs review
L["Sharing vs. Privacy"] = "共享 对 隐私" -- Needs review
L["Show All Ranks"] = "显示所有声望"
L["Show Comm Traffic"] = "显示通讯流量" -- Needs review
L["Show Debugging Messages (verbose)"] = "显示调试信息（详细）" -- Needs review
L["Show Import Progress"] = "显示导入进程"
L["Show Minimap Button"] = "显示小地图按钮"
L["Show More than 100 Search Results"] = "显示超过 100 搜索结果"
L["Show Read-Only Speeches"] = "显示只读讲话"
L["Show Ready-Only Speeches"] = "显示仅就绪讲话"
L["Show Setup Guides"] = "显示设置向导"
L["Show Statistics"] = "显示状态"
L["Show These Options"] = "显示这些选项"
L["Show Transfer Progress"] = "显示传输进度"
L["Show Used Event Hooks"] = "显示使用的事件钩子" -- Needs review
L["Show Welcome Message"] = "显示欢迎辞" -- Needs review
L["Show Why Event Triggers Do Not Fire"] = "显示为什么触发器不起作用"
L["Show network transfer statistics"] = "显示网络传输统计" -- Needs review
L["Show only this kind of event in the list below"] = "只显示下面列表中的事件" -- Needs review
L["Show outbound data transfer progress"] = "显示出站数据传输进度" -- Needs review
L["Show the SpeakinSpell minimap button"] = "显示 SpeakinSpell 小地图按钮"
L["Show the version number in chat when loading SpeakinSpell during login"] = "在 SpeakinSpell 加载时显示版本号" -- Needs review
L["Show these options for chat channel selections"] = "显示选择的聊天频道选项" -- Needs review
L["Show these options for chat frequency, cooldowns, and other limits"] = "显示说话频率，冷却，和其他限制的选项。"
L["Silent"] = "安静"
L["Solo Mode"] = "独行侠模式"
L["Someone Nearby"] = "附近某人"
L["SpeakinSpell Colors"] = "SpeakinSpell 颜色"
L["SpeakinSpell Help"] = "SpeakinSpell 帮助"
L["SpeakinSpell Loaded"] = "SpeakinSpell 载入"
L["SpeakinSpell Options GUI Colors"] = "SpeakinSpell 选项 GUI 颜色"
L[ [=[SpeakinSpell is <off>

Enable this option to turn SpeakinSpell <on> and resume announcing SpeakinSpell Speech Events

/ss macro events are always enabled if you manually type it or click a button for it.
]=] ] = [=[SpeakinSpell 已 <关闭>

把 SpeakinSpell <开启> 以激活此选项并恢复 SpeakinSpell 讲话事件

/ss 宏事件 如果手动输入或用按钮则一直有效。
]=]
L[ [=[SpeakinSpell is <on>

Disable this option to turn SpeakinSpell <off> and silence all SpeakinSpell speeches

/ss macro events are always enabled if you manually type it or click a button for it.
]=] ] = [=[SpeakinSpell 是 <on>

禁止这个选项会 <off> SpeakinSpell ，并且禁言所有 SpeakinSpell 台词。

/ss macro 事件总是生效的，如果你手动键入它，或者点击这个键。]=] -- Needs review
L["Spells, Abilities, and Items (Failed)"] = "施法, 技能, 和物品 (失败)"
L["Spells, Abilities, and Items (Interrupted)"] = "施法, 技能, 和物品 (打断)"
L["Spells, Abilities, and Items (Start Casting)"] = "施法, 技能, 和物品 (开始施放)"
L["Spells, Abilities, and Items (Stop Casting)"] = "施法, 技能, 和物品 (停止施放)"
L["Spells, Abilities, and Items (Successful Cast)"] = "施法, 技能, 和物品 (成功施放)"
L["Start Casting (I'm not involved)"] = "开始施放 (与我无关)"
L["Start Casting (I'm the caster)"] = "开始施放 (我是施法者)"
L["Start Casting (I'm the target)"] = "开始施放 (我是目标)"
L["Starting Sync with <target>"] = "开始与目标同步 <target>"
L["Stop SpeakinSpell from announcing the selected spell or event"] = "在选择的法术或事件中禁用 SpeakinSpell" -- Needs review
L["Sync with Target"] = "与目标同步"
L["Talk to Flight Master"] = "跟飞行点管理员说话"
L["Talk to Quest-Giver"] = "跟给任务者说话"
L["Talk to Trainer"] = "跟训练师说话"
L["Talk to Vendor"] = "跟商人说话"
L["Test Event: "] = "测试事件: "
L["Test Events"] = "测试事件"
L["The Arena"] = "竞技场"
L["The color of self-only raid warnings generated by SpeakinSpell"] = "针对自己的 SpeakinSpell 团队警告颜色" -- Needs review
L["This is a list of all the detected spells, abilities, items, and procced effects which SpeakinSpell has seen you cast or receive recently."] = "这是 SpeakinSpell 所能侦测的到所有法术、技能、物品和效果" -- Needs review
L["This option will silence SpeakinSpell for this many seconds after any event announcement."] = "SpeakinSpell 事件之间的触发间隔（单位：秒）" -- Needs review
L["To prevent SpeakinSpell from speaking in the chat too often for this spell, you can set a cooldown for how many seconds must pass before SpeakinSpell will announce this spell again."] = "针对某种使用频繁的法术触发讲话过多的情况，你可以设定一个冷却时间，在此时间之内同样的法术不会再触发 SpeakinSpell 事件。" -- Needs review
L["Toggle showing single-line or multi-line edit boxes for speeches"] = "转换讲话的单行或者多行编辑模式" -- Needs review
L["Transfer Complete"] = "传输完毕"
L["Unknown Damage Type"] = "未知伤害类型"
L["Use"] = "使用"
L["Use All"] = "全部使用"
L["Use Multi-Line Edit Boxes"] = "使用多行输入框"
L["Use this Random Speech for the selected Event"] = "在选择的事件中使用这个随机讲话" -- Needs review
L["Use this channel if you are promoted to assist in a raid group"] = "如果晋升为团队助理就使用这个信道" -- Needs review
L["Use this channel if you are the leader of a 5-man party"] = "如果你领导一个5人小队就使用这个信道" -- Needs review
L["Use this channel if you are the leader of a raid group"] = "如果你是团长就使用这个信道" -- Needs review
L["User's Manual"] = "用户手册"
L["Version "] = "版本 "
L["WARNING: can't execute protected command: <text>"] = "警告：不能执行保护的命令：<text>" -- Needs review
L["Welcome to SpeakinSpell v<version> <clickhere> to edit options"] = "欢迎到 SpeakinSpell v<version> <clickhere> 编辑选项" -- Needs review
L["What to Say? <selectedevent>"] = "要说什么? <selectedevent>"
L["What you say (Speeches)"] = "你说什么 (Speeches)"
L["When I Fail to Cast: "] = "当我施法失败: "
L["When I Start Casting: "] = "当我开始施法: "
L["When I Start Channeling: "] = "当我开始引导: "
L["When I Stop Casting: "] = "当我停止施法: "
L["When I Stop Channeling: "] = "当我停止引导: "
L["When I Successfully Cast: "] = "当我施法成功: "
L["When I Type: /ss "] = "当我输入: /ss "
L["When I buff myself with: "] = "当我给自己增益: "
L["When I debuff myself with: "] = "当我给自己减益: "
L["When I'm interrupted while casting: "] = "当我施法被打断: "
L["When someone else buffs me with: "] = "当某人给我增益: "
L["When someone else debuffs me with: "] = "当某人给我减益: "
L["Where you say (Channels/Whisper)"] = "你在哪说 (频道/密语)"
L["Which Channel? <selectedevent>"] = "哪个频道？ <selectedevent>"
L["Whisper the message to your <target>"] = "Whisper the message to your <target>"
L["Whispered While In-Combat"] = "战斗中密语"
L["Wintergrasp"] = "冬拥湖"
L["Wintergrasp GetZoneText"] = "冬拥湖"
L["YELL"] = "大喊 (/y)"
L["You are already using all of the available content"] = "你已经使用了所有可用内容" -- Needs review
L[ [=[You have a random chance to say a message each time you use the selected spell, based on this selected percentage.

100% will always speak. 0% will never speak.]=] ] = [=[你每次施放法术都有一定几率随机说一句话，触发几率基于下面的百分比。
100%表示每次都说，0%表示从不说。]=] -- Needs review
L["Your friends"] = "你的朋友"
L["[Click Here]"] = "[点这里]"
L["[Edit Speeches]"] = "[编辑讲话]"
L["[Setup New Event]"] = "[设置新事件]"
L["_ Show All Types of Events _"] = "_ 显示所有类型的事件 _"
L["a Guild Member"] = "一个工会成员"
L["a player sent me a rez"] = "一个玩家给我上绷带"
L["achievement"] = "成就"
L["advertise"] = "广告"
L["caster"] = "施法者"
L["changes"] = "变化"
L["class"] = "种族"
L["colors"] = "颜色"
L["create"] = "创建"
L["damage"] = "伤害"
L["desc"] = "描述"
L["eventtype"] = "事件类型" -- Needs review
L["eventtypeprefix"] = "事件类型前缀" -- Needs review
L["extremely"] = "极其"
L["focus"] = "焦点"
L["guides"] = "向导"
L["guild"] = "工会"
L["help"] = "帮助"
L["home"] = "家" -- Needs review
L["import"] = "导入" -- Needs review
L["lasttarget"] = "最后的目标" -- Needs review
L["macro"] = "宏"
L["macro "] = "宏 "
L["me"] = "我" -- Needs review
L["memory"] = "内存"
L["messages"] = "信息"
L["mouseover"] = "鼠标划过"
L["name"] = "名字"
L["network"] = "网络" -- Needs review
L["no speeches are defined"] = "没有定义讲话"
L["no target selected"] = "没选择目标"
L["options"] = "选项"
L["pet"] = "宠物"
L["player"] = "玩家"
L["playerclass"] = "玩家职业" -- Needs review
L["playerfulltitle"] = "玩家完整头衔" -- Needs review
L["playerrace"] = "玩家种族" -- Needs review
L["playertitle"] = "玩家头衔" -- Needs review
L["points"] = "点"
L["race"] = "种族"
L["random"] = "随机"
L["rank"] = "声望"
L["realm"] = "所处服务器" -- Needs review
L["recent"] = "最近的"
L["reset"] = "重置"
L["reward"] = "奖励"
L["scenario"] = "剧情"
L["school"] = "学校"
L["selected"] = "选择的"
L["spelllink"] = "法术连接" -- Needs review
L["spellname"] = "法术名称" -- Needs review
L["spellrank"] = "法术等级" -- Needs review
L["subzone"] = "子区域"
L["swimmer"] = "游泳者"
L["sync"] = "同步"
L["sync "] = "同步 "
L["target"] = "目标"
L["targetclass"] = "目标类型" -- Needs review
L["targetrace"] = "目标种族" -- Needs review
L["testallsubs"] = "测试所有子句" -- Needs review
L["text"] = "文字"
L["the /ss macro would keep calling itself forever"] = "这个 /ss 会一直自我调用"
L["the global cooldown is in effect"] = "公共冷却正在作用"
L["the random chance failed"] = "随机选择失败"
L["the selected chat channel is \"Silent\" while in <Scenario>"] = "选择的聊天频道在 <Scenario> 进行时是“静音”的"
L["this event trigger is disabled"] = "此事件触发器已禁用" -- Needs review
L["this event trigger is limited to once per combat / once per out-of-combat"] = "此事件触发器限制为每场战斗一次  / 每脱离战斗一次" -- Needs review
L["this event trigger is limited to once per target (<target>)"] = "此事件触发器限制为每目标一次 (<target>)" -- Needs review
L["this event trigger's cooldown is in effect"] = "此事件触发器正在冷却" -- Needs review
L["toggle"] = "开关"
L["type"] = "类型"
L["very"] = "非常"
L["zone"] = "区域"
