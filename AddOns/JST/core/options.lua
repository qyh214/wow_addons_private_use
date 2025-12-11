local T, C, L, G = unpack(select(2, ...))

G.Options = {
	LoadOption = {
		{ -- 标题:加载规则
			option_type = "title",
			text = L["加载规则"],
		},
		{ -- 加载规则
			key = "role_enable_tag",
			option_type = "ddmenu",
			width = 1,
			text = L["加载规则"],
			option_table = {
				{"rl", L["指挥"]},
				{"no-rl", L["非指挥"]},
				{"none", L["全部禁用"]},
			},
		},
		{ -- 加载规则说明
			option_type = "string",
			width = 1,
			text = L["加载规则说明"],
		},
	},
	SettingOption = {
		{ -- 标题:配置
			option_type = "title",
			text = L["配置"],
		},
		{ -- 配置
			key = "settings",
			option_type = "ddmenu",
			width = .5,
			text = L["配置"],
			option_table = {
				{"character", L["使用角色设置"]},
				{"account", L["使用账号设置"]},
			},
			apply = function()
				StaticPopup_Show(G.addon_name.."Reload Alert")
			end,
		},
		{ -- 重置设置
			key = "reset_settings",
			option_type = "button",
			width = .5,
			bu_width = 420,
			text = L["重置设置"],
			apply = function()
				T.ToggleSetup()
			end,
		},
		{ -- 复制账号配置
			key = "account_to_character",
			option_type = "button",
			width = .5,
			bu_width = 420,
			text = L["复制账号配置"],
			apply = function()
				T.AccountToCharacter()
			end,
		},
		{ -- 导出
			key = "export",
			option_type = "button",
			width = .5,
			bu_width = 420,
			text = L["导出"],
			apply = function()
				T.DisplayCopyString(JSTgeneralScrollAnchor.export, T.ExportSettings())
			end,
		},		
		{ -- 复制角色配置
			key = "character_to_account",
			option_type = "button",
			width = .5,
			bu_width = 420,
			text = L["复制角色配置"],
			apply = function()
				T.CharacterToAccount()
			end,
		},
		{ -- 导入
			key = "import",
			option_type = "button",
			width = .5,
			bu_width = 420,
			text = L["导入"],
			apply = function()
				T.DisplayCopyString(JSTgeneralScrollAnchor.import, "", nil, function(str) T.ImportSettings(str) end)
			end,
		},
	},
	GeneralOption = {
		{ -- 标题:通用
			option_type = "title",
			text = L["通用"],
		},
		{ -- 隐藏小地图图标
			key = "hide_minimap",
			option_type = "check",
			width = .5,
			text = L["隐藏小地图图标"],
			apply = function()
				T.ToggleMinimapButton()
			end,
		},
		{ -- 控制台缩放
			key = "gui_scale",
			option_type = "ddmenu",
			width = .5,
			text = L["控制台缩放"],
			option_table = {
				{60, "60%"},
				{70, "70%"},
				{80, "80%"},
				{90, "90%"},
				{100, "100%"},
				{110, "110%"},
				{120, "120%"},
			},
			apply = function()
				T.UpdateGUIScale()
			end,
		},
		{ -- 语音包
			key = "sound_pack",
			option_type = "ddmenu",
			width = .5,
			text = L["语音包"],
			option_table = G.SoundPacks,
			apply = function()
				T.apply_sound_pack()
			end,
		},
		{ -- 声道
			key = "sound_channel",
			option_type = "ddmenu",
			width = .5,
			text = L["声道"],
			option_table = {
				{"Master", L["主声道"]},
				{"Dialog", L["对话声道"]},
				{"SFX", L["音效声道"]},
			},
		},
		{ -- TTS选项
			key = "tts_speaker",
			option_type = "ddmenu",
			width = .5,
			text = L["文本转语音"],
			option_table = G.ttsSpeakers,
		},
		{ -- TTS测试
			key = "tts_speaker_test",
			option_type = "button",
			width = .5,
			text = L["文本转语音测试"],
			apply = function()
				T.SpeakText(L["文本转语音测试"])
			end,
		},
		{ -- 按职责加载
			key = "role_enable",
			option_type = "check",
			width = .5,
			text = string.format(L["按职责加载%s"], T.GetFlagIconStr("0,1,2")),
			apply = function()
				T.UpdateAll()
				T.UpdateAllData()
			end,
		},
		{ -- 昵称检测
			key = "nickname_check",
			option_type = "check",
			width = .5,
			text = L["昵称实时检测"],
			apply = function()
				T.ToggleNicknameCheck()
			end,
		},
		{ -- 名字显示方式
			key = "name_format",
			option_type = "ddmenu",
			width = .5,
			text = L["名字显示方式"],
			option_table = {
				{"realname", L["总是显示角色名"]},
				{"nickname", L["优先显示昵称"]},
			},
		},
		{ -- 标题:全局禁用
			option_type = "title",
			text = L["全局禁用"],
		},
		{ -- 禁用插件
			key = "disable_all",
			option_type = "check",
			width = .5,
			text = L["禁用插件"],
			apply = function()
				T.UpdateAll()
			end,
		},
		{ -- 禁用团队标记
			key = "disable_rmark",
			option_type = "check",
			width = .5,
			text = L["禁用团队标记"],
		},
		{ -- 静音
			key = "disable_sound",
			option_type = "check",
			width = .5,
			text = MUTE,
			apply = function()
				T.EditSoundAlert("enable")
			end,
		},
		{ -- 禁发聊天讯息
			key = "disbale_msg",
			option_type = "check",
			width = .5,
			text = L["禁发聊天讯息"],
			apply = function()
				
			end,
		},
		{ -- 禁用团队框架提示
			key = "disable_rf",
			option_type = "check",
			width = .5,
			text = L["禁用团队框架提示"],
			apply = function()
				T.EditRFIconAlert("enable")
			end,
		},
		{ -- 禁用姓名板提示
			key = "disable_plate",
			option_type = "check",
			width = .5,
			text = L["禁用姓名板提示"],
			apply = function()
				T.UpdateAll()
			end,
		},		
		{ -- 18 标题:动态战术板
			option_type = "title",
			text = L["动态战术板"],
		},
		{ -- 启用
			key = "tl",
			option_type = "check",
			width = 1,
			text = L["启用"],
			apply = function()
				T.EditTimeline("enable") 
			end,
		},
		{ -- 动态战术板模板
			key = "tl_copy",
			option_type = "button",
			width = .5,
			text = L["MRT时间轴模板"],
			apply = function()
				T.CopyTimeline()
			end,
			rely = "tl",
		},
		{ -- 动态战术板测试
			key = "tl_test",
			option_type = "button",
			width = .5,
			text = L["动态战术板测试"].." "..L["开始"],
			apply = function()
				T.ToggleTimelineTest()
			end,
			rely = "tl",
		},
		{ -- 团队战术板
			key = "tl_use_raid",
			option_type = "check",
			width = .5,
			text = L["团队战术板"],
			rely = "tl",
		},
		{ -- 个人战术板
			key = "tl_use_self",
			option_type = "check",
			width = .5,
			text = L["个人战术板"],
			rely = "tl",
		},
		{ -- 字体大小
			key = "tl_font_size",
			option_type = "slider",
			width = 1,
			text = L["字体大小"],
			min = 10,
			max = 30,
			step = 1,
			apply = function()
				T.EditTimeline("font_size")
			end,
			rely = "tl",
		},
		{ -- 提前时间
			key = "tl_advance",
			option_type = "slider",
			width = 1,
			text = L["提前时间"],
			min = 2,
			max = 120,
			step = 1,
			rely = "tl",
		},		
		{ -- 标题:过滤设置
			option_type = "title",
			text = L["过滤设置"],
		},
		{ -- 监控我的职业的提示
			key = "tl_filter_class",
			option_type = "check",
			width = 1,
			text = string.format(L["监控我的职业的提示"], G.myClassLocal),
			rely = "tl",
		},
		{ -- 监控我的职责的提示
			key = "tl_filter_role",
			option_type = "check",
			width = 1,
			text = string.format(L["监控我的职责的提示"], L["坦克"], L["治疗"], L["输出"]),
			rely = "tl",
		},
		{ -- 监控我的位置的提示
			key = "tl_filter_pos",
			option_type = "check",
			width = 1,
			text = string.format(L["监控我的站位的提示"], L["近战"], L["远程"]),
			rely = "tl",
		},
		{ -- 监控对小队的提示
			key = "tl_filter_party",
			option_type = "check",
			width = 1,
			text = L["监控对小队的提示"],
			rely = "tl",
		},
		{ -- 监控对所有人的提示
			key = "tl_filter_all",
			option_type = "check",
			width = 1,
			text = string.format(L["监控对所有人的提示"], L["所有人"]),
			rely = "tl",
		},
		{ -- 标题:提示设置
			option_type = "title",
			text = L["提示设置"],
		},
		{ -- 显示计时条
			key = "tl_bar",
			option_type = "check",
			width = 1,
			text = L["我的计时条提示"],
			apply = function()
				T.EditTimeline("bar")
			end,
			rely = "tl",
		},
		{ -- 计时条时间
			key = "tl_bar_dur",
			option_type = "slider",
			width = .5,
			text = L["计时条时间"],
			min = 3,
			max = 15,
			step = 1,
			rely = "tl_bar",
		},
		{ -- 文字提示与我相关的内容
			key = "tl_text",
			option_type = "check",
			width = 1,
			text = L["文字提示与我相关的内容"],
			apply = function()
				T.EditTimeline("text")
			end,
			rely = "tl",
		},
		{ -- 文字提示时间
			key = "tl_text_dur",
			option_type = "slider",
			width = .5,
			text = L["文字提示时间"],
			min = 2,
			max = 10,
			step = 1,
			rely = "tl_text",
		},
		{ -- 显示秒数
			key = "tl_text_show_dur",
			option_type = "check",
			width = .5,
			text = L["显示秒数"],
			rely = "tl_text",
		},
		{ -- 朗读与我相关的内容
			key = "tl_sound",
			option_type = "check",
			width = 1,
			text = L["朗读与我相关的内容"],
			rely = "tl",
		},
		{ -- 语音提示时间
			key = "tl_sound_dur",
			option_type = "slider",
			width = .5,
			text = L["语音提示时间"],
			min = 2,
			max = 10,
			step = 1,
			rely = "tl_sound",
		},
		{ -- 语音提示音量
			key = "tl_sound_volume",
			option_type = "slider",
			width = .5,
			text = L["语音提示音量"],
			min = 0,
			max = 100,
			step = 10,
			rely = "tl_sound",
		},
		{ -- 高亮我的技能目标
			key = "tl_glowtarget",
			option_type = "check",
			width = .5,
			text = L["高亮我的技能目标"],
			rely = "tl",
		},
		{ -- 42 标题:团队标记提示
			option_type = "title",
			text = L["团队标记提示"],
		},
		{ -- 启用
			key = "rm",
			option_type = "check",
			width = 1,
			text = L["启用"],
			apply = function()
				T.EditRMFrame("enable")
			end,
		},
		{ -- 标题:请求技能
			option_type = "title",
			text = L["请求技能"],
		},
		{ -- 接收法术请求
			key = "cs",
			option_type = "check",
			width = .5,
			text = L["接收法术请求"],
			apply = function()
				T.EditASFrame("enable")
			end,
		},
		{ -- 接收法术请求
			key = "cs_msg",
			option_type = "check",
			width = .5,
			text = L["聊天框显示无效的请求记录"],
			rely = "cs",
		},
		{ -- 提示音
			key = "cs_sound",
			option_type = "ddmenu",
			width = .5,
			text = L["提示音"],
			option_table = {
				{"sound_phone", L["音效电话"]},
				{"sound_water", L["音效水滴"]},
				{"sound_bell", L["音效铃声"]},
				{"speak", L["朗读请求内容"]},
				{"none", L["无"]},
			},
			apply = function()
				T.Play_askspell_sound(G.PlayerName, C_Spell.GetSpellName(10060))
			end,
			rely = "cs",
		},
		{ -- 请求技能提示
			option_type = "string",
			width = 3,
			text = L["请求技能提示"].."\n\n"..L["需要队友安装JST"],
		},
		{ -- 标题:队伍控制链监控
			option_type = "title",
			text = L["队伍控制链监控"],
		},
		{ -- 启用
			key = "control_spell_enable",
			option_type = "check",
			width = 1,
			text = L["启用"],
			apply = function()
				T.EditGroupCCFrame("enable")
				T.UpdateCCSpellPanelStatus()
			end,
		},
		{ -- 图标尺寸
			key = "control_spell_size",
			option_type = "slider",
			width = 1,
			text = L["图标大小"],
			min = 25,
			max = 80,
			step = 1,
			apply = function()
				T.EditGroupCCFrame("icon_size")
			end,
			rely = "control_spell_enable",
		},
		{ -- 总是显示全部控制技能
			key = "control_always_show",
			option_type = "check",
			width = .5,
			text = L["总是显示全部控制技能"],
			apply = function()
				T.EditGroupCCFrame("enable")
			end,
			rely = "control_spell_enable",
		},
		{ -- 音效
			key = "control_tts",
			option_type = "check",
			width = .5,
			text = L["音效"],
			rely = "control_spell_enable",
		},
		{ -- 战斗外隐藏
			key = "control_oochide",
			option_type = "check",
			width = .5,
			text = L["战斗外隐藏"],
			apply = function()
				T.EditGroupCCFrame("visible")
			end,
			rely = "control_spell_enable",
		},
		{ -- 首领战斗时隐藏
			key = "control_bossfighthide",
			option_type = "check",
			width = .5,
			text = L["首领战斗时隐藏"],
			apply = function()
				T.EditGroupCCFrame("visible")
			end,
			rely = "control_spell_enable",
		},
		{ -- 自动分配控制技能
			key = "control_assign",
			option_type = "check",
			width = 9,
			text = L["自动分配控制技能"],
			rely = "control_spell_enable",
		},
		{ -- 标题:团队单体减伤技能监控和分配
			option_type = "title",
			text = L["团队单体减伤技能监控和分配"],
		},
		{ -- 启用
			key = "group_spell_enable",
			option_type = "check",
			width = .5,
			text = L["启用"],
			apply = function()
				T.EditGroupSpellFrame("enable")
			end,
		},
		{ -- 聊天框显示无效的请求记录
			key = "group_spell_msg",
			option_type = "check",
			width = .5,
			text = L["聊天框显示无效的请求记录"],
			rely = "group_spell_enable",
		},
		{ -- 图标尺寸
			key = "group_spell_size",
			option_type = "slider",
			width = .5,
			text = L["图标大小"],
			min = 25,
			max = 60,
			step = 1,
			apply = function()
				T.EditGroupSpellFrame("icon_size")
			end,
			rely = "group_spell_enable",
		},
		{ -- 排列方向
			key = "group_spell_dir",
			option_type = "ddmenu",
			width = .5,
			text = L["排列方向"],
			option_table = {
				{"RIGHT", L["向左延申"]},
				{"LEFT", L["向右延申"]},
			},
			apply = function()
				T.EditGroupSpellFrame("grow_dir")
			end,
			rely = "group_spell_enable",
		},
		{ -- 队伍单体减伤技能提示
			key = "person_spell_discription",
			option_type = "string",
			width = 3,
			text = string.format(L["队伍单体减伤技能提示"], C_Spell.GetSpellName(22812), C_Spell.GetSpellName(102342)).."\n\n"..L["需要队友安装JST"],
		},
		{ -- 标题:玩家自保技能提示
			option_type = "title",
			text = L["玩家自保技能提示"],
		},
		{ -- 启用
			key = "personal_spell_enable",
			option_type = "check",
			width = 1,
			text = L["启用"],
			apply = function()
				T.EditPersonalSpellFrame("enable")
			end,
		},
		{ -- 图标尺寸
			key = "personal_spell_size",
			option_type = "slider",
			width = .5,
			text = L["图标大小"],
			min = 25,
			max = 100,
			step = 1,
			apply = function()
				T.EditPersonalSpellFrame("icon_size")
			end,
			rely = "personal_spell_enable",
		},
		{ -- 排列方向
			key = "personal_spell_dir",
			option_type = "ddmenu",
			width = .5,
			text = L["排列方向"],
			option_table = {
				{"RIGHT", L["向左延申"]},
				{"LEFT", L["向右延申"]},
			},
			apply = function()
				T.EditPersonalSpellFrame("grow_dir")
			end,
			rely = "personal_spell_enable",
		},
		{ -- 自保提示音效
			key = "personal_spell_sound",
			option_type = "ddmenu",
			width = .5,
			text = L["音效"],
			option_table = {
				{"defense", L["注意自保"]},
				{"sound_boxing", L["音效"].."1"},
				{"sound_bike", L["音效"].."2"},
				{"none", L["无"]},
			},
			apply = function()
				T.Play_personlspell_sound()
			end,
		},
		{ -- 玩家单体减伤技能提示
			option_type = "string",
			width = 1,
			text = L["玩家单体减伤技能提示"],
		},
		{ -- 低血量时显示自保技能提示
			key = "personal_spell_low_hp",
			option_type = "check",
			width = .5,
			text = L["低血量时显示自保技能提示"],
			apply = function()
				T.AddGeneralHPCheck()
			end,
			rely = "personal_spell_enable",
		},
		{ -- 血量百分比阈值
			key = "personal_spell_low_hp_value",
			option_type = "slider",
			width = .5,
			text = L["血量阈值百分比"],
			min = 10,
			max = 60,
			step = 1,
			apply = function()
				T.AddGeneralHPCheck()
			end,
			rely = "personal_spell_enable",
		},
		{ -- 血量阈值百分比提示
			option_type = "string",
			width = 1,
			text = L["血量阈值百分比提示"],
		},
		{ -- 标题:团队PA光环
			option_type = "title",
			text = L["团队PA光环"],
		},
		{ -- 启用
			key = "raid_pa",
			option_type = "check",
			width = 1,
			text = L["启用"],
			apply = function()
				T.EditRaidPAFrame("enable")
			end,
		},
		{ -- 单个框架宽度
			key = "raid_pa_width",
			option_type = "slider",
			width = .5,
			text = L["单个框架宽度"],
			min = 40,
			max = 120,
			step = 5,
			apply = function()
				T.EditRaidPAFrame("size")
			end,
			rely = "raid_pa",
		},
		{ -- 单个框架高度
			key = "raid_pa_height",
			option_type = "slider",
			width = .5,
			text = L["单个框架高度"],
			min = 15,
			max = 30,
			step = 1,
			apply = function()
				T.EditRaidPAFrame("size")
			end,
			rely = "raid_pa",
		},
		{ -- 字体大小
			key = "raid_pa_fsize",
			option_type = "slider",
			width = .5,
			text = L["字体大小"],
			min = 12,
			max = 30,
			step = 1,
			apply = function()
				T.EditRaidPAFrame("size")
			end,
			rely = "raid_pa",
		},
		{ -- 图标个数
			key = "raid_pa_icon_num",
			option_type = "slider",
			width = .5,
			text = L["图标个数"],
			min = 1,
			max = 4,
			step = 1,
			apply = function()
				T.EditRaidPAFrame("size")
			end,
			rely = "raid_pa",
		},
		{ -- 粘贴MRT模板
			key = "pa_copy_mrt",
			option_type = "button",
			width = .5,
			text = L["粘贴MRT模板"],
			apply = function()
				T.CopyGroupPANote()
			end,
			rely = "raid_pa",
		},
	},
	IconAlertOption = {
		{ -- 标题:图标提示
			option_type = "title",
			text = L["图标提示"],
		},
		{ -- 图标大小
			key = "icon_size",
			option_type = "slider",
			width = .5,
			text = L["图标大小"],
			min = 40,
			max = 100,
			step = 1,
			apply = function()
				T.EditIconAlertFrames("icon_size")
			end,		
		},
		{ -- 图标间距
			key = "icon_space",
			option_type = "slider",
			width = .5,
			text = L["图标间距"],
			min = 0,
			max = 20,
			step = 1,
			apply = function()
				T.EditIconAlertFrames("icon_space")
			end,		
		},
		{ -- 大字体大小
			key = "font_size",
			option_type = "slider",
			width = .5,
			text = L["大字体大小"],
			min = 15,
			max = 30,
			step = 1,
			apply = function()
				T.EditIconAlertFrames("font_size")
			end,		
		},
		{ -- 小字体大小
			key = "ifont_size",
			option_type = "slider",
			width = .5,
			text = L["小字体大小"],
			min = 10,
			max = 20,
			step = 1,
			apply = function()
				T.EditIconAlertFrames("ifont_size")
			end,
		},
		{ -- 排列方向
			key = "grow_dir",
			option_type = "ddmenu",
			width = .5,
			text = L["排列方向"],
			option_table = {
				{"RIGHT", L["向左延申"]},
				{"LEFT", L["向右延申"]},
				{"BOTTOM", L["向上延申"]},
				{"TOP", L["向下延申"]},
			},
			apply = function()
				T.EditIconAlertFrames("grow_dir")
			end,
		},
		{ -- 显示法术时间
			key = "show_spelldur",
			option_type = "check",
			width = .5,
			text = L["显示法术时间"],
			apply = function()
				T.EditIconAlertFrames("spelldur")
			end,
		},
		{ -- 启用
			key = "enable_pa",
			option_type = "check",
			width = 1,
			text = L["启用"].."Private Aura",
			apply = function()
				T.EditIconAlertFrames("enable")
			end,
		},
		{ -- Private Aura 图标大小
			key = "privateaura_icon_size",
			option_type = "slider",
			width = .5,
			text = "Private Aura"..L["图标大小"],
			min = 40,
			max = 300,
			step = 1,
			apply = function()
				T.EditIconAlertFrames("icon_size")
			end,		
			rely = "enable_pa",
		},
		{ -- Private Aura 图标透明度
			key = "privateaura_icon_alpha",
			option_type = "slider",
			width = .5,
			text = "Private Aura"..L["透明度"],
			min = .05,
			max = 1,
			step = .05,
			apply = function()
				T.EditIconAlertFrames("alpha")
			end,		
			rely = "enable_pa",
		},		
	},
	TimerbarOption = {
		{ -- 标题:计时条提示
			option_type = "title",
			text = L["计时条提示"],
		},
		{ -- 长度
			key = "bar_width",
			option_type = "slider",
			width = .5,
			text = L["长度"],
			min = 160,
			max = 500,
			step = 5,
			apply = function()
				T.EditBarAlertFrames("bar_size")
			end,
		},
		{ -- 高度
			key = "bar_height",
			option_type = "slider",
			width = .5,
			text = L["高度"],
			min = 16,
			max = 30,
			step = 1,
			apply = function()
				T.EditBarAlertFrames("bar_size")
			end,
		},
	},
	PlateAlertOption = {
		{ -- 标题:姓名板提示
			option_type = "title",
			text = L["姓名板提示"],
		},
		{ -- 图标大小
			key = "size",
			option_type = "slider",
			width = 1,
			text = L["图标大小"],
			min = 20,
			max = 50,
			step = 1,
			apply = function()
				T.EditPlateIcons("icon_size")
			end,
		},
		{ -- 垂直距离
			key = "y",
			option_type = "slider",
			width = .5,
			text = L["垂直距离"],
			min = -100,
			max = 100,
			step = 1,
			apply = function()
				T.EditPlateIcons("y")
			end,
		},
		{ -- 水平距离
			key = "x",
			option_type = "slider",
			width = .5,
			text = L["水平距离"],
			min = -100,
			max = 100,
			step = 1,
			apply = function()
				T.EditPlateIcons("x")
			end,
		},
		{ -- 标题:打断提示
			option_type = "title",
			text = L["自动标记打断"],
		},
		{ -- 自动标记打断
			key = "interrupt_auto_mark",
			option_type = "check",
			width = .5,
			text = L["启用"],
			apply = function()
				T.UpdateAutoMarkState()
				T.UpdateMarkPanelStatus()
			end,
		},
		{ -- 聊天框显示标记信息
			key = "interrupt_auto_mark_msg",
			option_type = "check",
			width = .5,
			text = L["聊天框显示标记信息"],
			rely = "interrupt_auto_mark",
		},
		{ -- 标记
			option_type = "string",
			width = .5,
			text = "",
		},
		{ -- 当队长时标记
			key = "interrupt_auto_mark_leader",
			option_type = "check",
			width = .5,
			text = L["当队长时标记"],
			rely = "interrupt_auto_mark",
		},
		{ -- 重置标记命令
			option_type = "string",
			width = 1,
			text = L["重置标记命令"],
		},
		{ -- 标题:设置焦点
			option_type = "title",
			text = L["设置焦点"],
		},
		{ -- 文字提示设置焦点
			key = "interrupt_focus_textalert",
			option_type = "check",
			width = .5,
			text = L["文字提示"]..L["设置焦点"]..L["MRT分配"],
		},
		{ -- 声音提示设置焦点
			key = "interrupt_focus_soundalert",
			option_type = "check",
			width = .5,
			text = L["声音提示"]..L["设置焦点"]..L["MRT分配"],
		},
		{ -- 启用焦点快捷键
			key = "focus_key_bind",
			option_type = "check",
			width = .5,
			text = L["启用焦点快捷键"],
			apply = function()
				T.UpdateFocusBindingClick()
			end,
		},
		{ -- 焦点修饰键
			key = "focus_key_bind_modifier",
			option_type = "ddmenu",
			width = .5,
			text = L["焦点修饰键"],
			option_table = {
				{"ctrl", "ctrl"},
				{"shift", "shift"},
				{"alt", "alt"},
			},
			apply = function()
				T.UpdateFocusBindingClick()
			end,
			rely = "focus_key_bind",
		},
		{ -- 设置焦点后发送信息
			key = "interrupt_focus_msg",
			option_type = "check",
			width = .5,
			text = L["设置焦点后发送信息"],
		},
		{ -- 只在小队中发送设置焦点信息
			key = "interrupt_focus_msg_dungeon",
			option_type = "check",
			width = .5,
			text = L["只在地下城中发送信息"],
			rely = "interrupt_focus_msg",
		},
		{ -- 标题:打断提示
			option_type = "title",
			text = L["打断提示"],
		},
		{ -- 打断计时条
			key = "interrupt_bar",
			option_type = "check",
			width = 1,
			text = L["打断计时条"],
		},
		{ -- 预备打断音效
			key = "interrupt_sound",
			option_type = "ddmenu",
			width = .5,
			text = L["预备打断音效"],
			option_table = {
				{"interrupt", L["打断音效语音"].."1"},
				{"interrupt_cast", L["打断音效语音"].."2"},
				{"interrupt_prepare", L["打断音效语音"].."3"},
				{"sound_phone", L["音效电话"]},
				{"none", L["无"]},
			},
			apply = function()
				T.Play_interrupt_sound()
			end,
		},
		{ -- 打断音效
			key = "interrupt_sound_cast",
			option_type = "ddmenu",
			width = .5,
			text = L["打断音效"],
			option_table = {
				{"interrupt", L["打断音效语音"].."1"},
				{"interrupt_cast", L["打断音效语音"].."2"},
				{"interrupt_prepare", L["打断音效语音"].."3"},
				{"sound_phone", L["音效电话"]},
				{"none", L["无"]},
			},
			apply = function()
				T.Play_interrupt_sound_cast()
			end,
		},
		{ -- 只显示我负责的打断
			key = "interrupt_only_mine",
			option_type = "check",
			width = 1,
			text = L["只显示我负责的打断"]..L["MRT分配"],
			apply = function()
				 T.EditPlateIcons("interrupt")
			end,
		},		
		{ -- 焦点过滤
			key = "interrupt_focus_fliter",
			option_type = "check",
			width = 1,
			text = L["只显示焦点目标的打断"],
			apply = function()
				 T.EditPlateIcons("interrupt")
			end,
		},
		{ -- 标题:打断提示
			option_type = "title",
			text = L["MRT打断战术板"],
		},
		{ -- 姓名板打断图标提示
			option_type = "string",
			width = 3,
			text = L["姓名板打断图标提示"],
		},
	},
	RFIconOption = {
		{ -- 标题:团队框架图标
			option_type = "title",
			text = L["团队框架图标"],
		},
		{ -- 法术图标尺寸
			key = "RFIcon_size",
			option_type = "slider",
			width = 1,
			text = L["法术图标"]..L["尺寸"],
			min = 20,
			max = 40,
			step = 1,
			apply = function()
				T.EditRFIconAlert("icon_layout")
			end,
		},
		{ -- 法术图标水平偏移
			key = "RFIcon_x_offset",
			option_type = "slider",
			width = .5,
			text = L["法术图标水平偏移"],
			min = -50,
			max = 50,
			step = 1,
			apply = function()
				T.EditRFIconAlert("icon_layout")
			end,
		},		
		{ -- 法术图标垂直偏移
			key = "RFIcon_y_offset",
			option_type = "slider",
			width = .5,
			text = L["法术图标垂直偏移"],
			min = -50,
			max = 50,
			step = 1,
			apply = function()
				T.EditRFIconAlert("icon_layout")
			end,
		},
		{ -- 法术图标测试
			key = "rf_icon_test",
			option_type = "button",
			width = .5,
			text = L["测试"],
			apply = function()
				local t = GetTime()
				T.CreateSharedRFIcon("player", "test"..floor(t), 460686, t*1000, (t+5)*1000)		
			end,
		},
		{ -- 标题:团队序号
			option_type = "title",
			text = L["团队序号"],
		},
		{ -- 团队序号尺寸
			key = "RFIndex_size",
			option_type = "slider",
			width = .5,
			text = L["团队序号"]..L["尺寸"],
			min = 30,
			max = 60,
			step = 1,
			apply = function()
				T.EditRFIconAlert("index_layout")
			end,
		},
		{ -- 团队序号颜色
			key = "RFIndex_color",
			option_type = "color",
			width = .5,
			text = L["团队序号颜色"],
			apply = function()
				T.EditRFIconAlert("index_layout")
			end,
		},
		{ -- 团队序号锚点
			key = "RFIndex_anchor",
			option_type = "ddmenu",
			width = 1,
			text = L["团队序号锚点"],
			option_table = {
				{"CENTER", L["中间"]},
				{"LEFT", L["左"]},
				{"RIGHT", L["右"]},
				{"TOP", L["上"]},
				{"BOTTOM", L["下"]},
				{"TOPLEFT", L["左上"]},
				{"TOPRIGHT", L["右上"]},
				{"BOTTOMLEFT", L["左下"]},
				{"BOTTOMRIGHT", L["右下"]},
			},
			apply = function()
				T.EditRFIconAlert("index_layout")
			end,
		},
		{ -- 团队序号水平偏移
			key = "RFIndex_x_offset",
			option_type = "slider",
			width = .5,
			text = L["团队序号水平偏移"],
			min = -20,
			max = 20,
			step = 1,
			apply = function()
				T.EditRFIconAlert("index_layout")
			end,
		},		
		{ -- 团队序号垂直偏移
			key = "RFIndex_y_offset",
			option_type = "slider",
			width = .5,
			text = L["团队序号垂直偏移"],
			min = -20,
			max = 20,
			step = 1,
			apply = function()
				T.EditRFIconAlert("index_layout")
			end,
		},
		{ -- 团队序号测试
			key = "rf_index_test",
			option_type = "button",
			width = .5,
			text = L["测试"],
			apply = function()				
				T.CreateRFIndex(G.PlayerGUID, 1)
				C_Timer.After(5, function()
					T.HideRFIndexbyGUID(G.PlayerGUID)
				end)		
			end,
		},
		{ -- 标题:团队数值
			option_type = "title",
			text = L["团队数值"],
		},
		{ -- 团队数值尺寸
			key = "RFValue_size",
			option_type = "slider",
			width = .5,
			text = L["团队数值"]..L["尺寸"],
			min = 10,
			max = 40,
			step = 1,
			apply = function()
				T.EditRFIconAlert("value_layout")
			end,
		},
		{ -- 团队数值颜色
			key = "RFValue_color",
			option_type = "color",
			width = .5,
			text = L["团队数值颜色"],
			apply = function()
				T.EditRFIconAlert("value_layout")
			end,
		},
		{ -- 团队数值锚点
			key = "RFValue_anchor",
			option_type = "ddmenu",
			width = 1,
			text = L["团队数值锚点"],
			option_table = {
				{"CENTER", L["中间"]},
				{"LEFT", L["左"]},
				{"RIGHT", L["右"]},
				{"TOP", L["上"]},
				{"BOTTOM", L["下"]},
				{"TOPLEFT", L["左上"]},
				{"TOPRIGHT", L["右上"]},
				{"BOTTOMLEFT", L["左下"]},
				{"BOTTOMRIGHT", L["右下"]},
			},
			apply = function()
				T.EditRFIconAlert("value_layout")
			end,
		},
		{ -- 团队数值水平偏移
			key = "RFValue_x_offset",
			option_type = "slider",
			width = .5,
			text = L["团队数值水平偏移"],
			min = -20,
			max = 20,
			step = 1,
			apply = function()
				T.EditRFIconAlert("value_layout")
			end,
		},		
		{ -- 团队数值垂直偏移
			key = "RFValue_y_offset",
			option_type = "slider",
			width = .5,
			text = L["团队数值垂直偏移"],
			min = -20,
			max = 20,
			step = 1,
			apply = function()
				T.EditRFIconAlert("value_layout")
			end,
		},
		{ -- 团队数值测试
			key = "rf_value_test",
			option_type = "button",
			width = .5,
			text = L["测试"],
			apply = function()
				local unit_frame = T.GetUnitFrame("player")
				if unit_frame then					
					T.CreateRFValue(unit_frame, T.ShortValue(1512300))
					C_Timer.After(5, function()
						T.HideRFValuebyParent(unit_frame)
					end)
				end
			end,
		},
		{ -- 标题:团队框架高亮
			option_type = "title",
			text = L["团队框架高亮"],
		},		
		{ -- 发光边框水平偏移
			key = "x_offset",
			option_type = "slider",
			width = .5,
			text = L["发光边框水平偏移"],
			min = -10,
			max = 30,
			step = 1,
		},
		{ -- 发光边框垂直偏移
			key = "y_offset",
			option_type = "slider",
			width = .5,
			text = L["发光边框垂直偏移"],
			min = -10,
			max = 30,
			step = 1,
		},
		{ -- 团队框架高亮类型光环
			key = "glow_type",
			option_type = "ddmenu",
			width = 1,
			text = L["团队框架高亮类型光环"],
			option_table = {
				{"proc", L["团队框架发光"]},
				{"pixel", L["团队框架虚线动画"]},
			},
			apply = function()
				T.HideAllRFAuraGlow()
			end,
		},
		{ -- 高亮边框测试
			key = "rf_hl_test",
			option_type = "button",
			width = .5,
			text = L["测试"],
			apply = function()			
				local frame = T.GetUnitFrame("player")
				T.ShowRFAuraGlow(frame, "AuraIDTest", "spellIDTest", {0, 1, 1})
				C_Timer.After(5, function()
					T.HideRFAuraGlow(frame, "AuraIDTest:spellIDTest")
				end)
			end,
		},
	},
	TextAlertOption = {
		{ -- 标题:文字提示
			option_type = "title",
			text = L["文字提示"],
		},	
		{ -- 字体大小
			key = "font_size",
			option_type = "slider",
			width = .5,
			text = L["文字提示1"]..L["字体大小"],
			min = 20,
			max = 50,
			step = 1,
			apply = function()
				T.EditTextAlertFrames("font_size")
			end,
		},
		{ -- 字体大小2
			key = "font_size_big",
			option_type = "slider",
			width = .5,
			text = L["文字提示2"]..L["字体大小"],
			min = 30,
			max = 70,
			step = 1,
			apply = function()
				T.EditTextAlertFrames("font_size")
			end,
		},
	},
	RaidInfo = {
		{ -- 标题:团队信息
			option_type = "title",
			text = L["团队信息"],
		},
	},
	UpdateLogs = {
		{ -- 标题:更新日志
			option_type = "title",
			text = L["更新日志"],
		},
	},
}

T.GetOptionInfo = function(path)
	local OptionCategroy = path[1]
	local key = path[2]
	for _, info in pairs(G.Options[OptionCategroy]) do
		if info.key == key then
			f = true
			return info
		end
	end
end
