---@diagnostic disable
-- Preydator: zhCN (Simplified Chinese) localization
-- Credit: zhCN localization contributed by @huchang47
-- Note: This locale requires Simplified Chinese input from a native speaker.
if GetLocale() ~= "zhCN" then return end
local L = _G.PreydatorL

---- Stage defaults (displayed in the progress bar; players can override in Options > Text)
L["No Sign in These Fields"] = "这片区域没有踪迹"
L["AMBUSH"] = "伏击"
L["Scent in the Wind"] = "风中的气息"
L["Blood in the Shadows"] = "暗影中的鲜血"
L["Echoes of the Kill"] = "杀戮的回响"
L["Feast of the Fang"] = "尖牙盛宴"

---- Options panel tabs
L["General"] = "常规"
L["Display"] = "显示"
L["Vertical"] = "布局"
L["Text"] = "文本"
L["Audio"] = "音频"
L["Currencies"] = "货币"
L["Advanced"] = "高级"
L["Warband"] = "战团"

---- Section headers
L["Visibility"] = "可见性"
L["Behavior"] = "行为"
L["Hunt Table"] = "狩猎面板"
L["Bar Size"] = "进度条尺寸"
L["Progress Display"] = "进度显示"
L["Visual Style"] = "视觉样式"
L["Vertical Mode"] = "布局模式"
L["Vertical Dimensions"] = "布局尺寸"
L["Label Mode"] = "标签模式"
L["Prefix Labels"] = "前缀标签"
L["Label Placement"] = "标签位置"
L["Suffix Labels"] = "后缀标签"
L["Sound Selection"] = "音效选择"
L["Custom Files / Tests"] = "自定义文件/测试"
L["Restore / Reset"] = "恢复/重置"
L["Notes"] = "说明"

---- Checkboxes
L["Lock Bar"] = "锁定进度条"
L["Only show in prey zone"] = "仅在猎物区域显示"
L["Disable Default Prey Icon"] = "禁用默认猎物图标"
L["Show in Edit Mode preview"] = "在编辑模式预览中显示"
L["Enable Hunt Table Tracker"] = "启用狩猎面板追踪器"
L["Enable sounds"] = "启用音效"
L["Ambush sound alert"] = "伏击声音警报"
L["Ambush visual alert"] = "伏击视觉警报"
L["Show tick marks"] = "显示刻度标记"
L["Display Spark Line"] = "显示闪光线条"
L["Link border color to fill"] = "边框颜色与填充关联"
L["Show Percentage at Tick Marks"] = "在刻度标记处显示百分比"
L["Enable Debug"] = "启用调试"
L["Currency Debug Events"] = "货币调试事件"
L["Show Minimap Button"] = "显示小地图按钮"
L["Show Affordable Hunts In Tracker"] = "在追踪器中显示可负担的狩猎"
L["Show Group By Realm In Warband"] = "在战团中按服务器分组显示"
L["Show bar during Edit Mode"] = "在编辑模式下显示进度条"

---- Dropdown field titles
L["Currency Theme"] = "货币主题"
L["Progress Segments"] = "进度分段"
L["Sound Channel"] = "音效通道"
L["Hunt Panel Side"] = "狩猎面板侧边"
L["Bar Orientation"] = "进度条方向"
L["Vertical Fill Direction"] = "布局填充方向"
L["Vertical Text Side"] = "布局文本侧边"
L["Vertical Text Alignment"] = "布局文本对齐"
L["Vertical Percent Display"] = "布局百分比显示"
L["Vertical Percent Tick Mark"] = "布局百分比刻度标记"
L["Percent Display"] = "百分比显示"
L["Text Display"] = "文本显示"
L["Texture"] = "材质"
L["Title Font"] = "标题字体"
L["Percent Font"] = "百分比字体"
L["Ambush Sound"] = "伏击音效"

---- Slider labels
L["Scale"] = "缩放"
L["Width"] = "宽度"
L["Height"] = "高度"
L["Font Size"] = "字体大小"
L["Enhance Sounds"] = "增强音效"
L["Vertical Text Offset"] = "垂直文本偏移"
L["Vertical Percent Offset"] = "垂直百分比偏移"

---- Sound dropdown labels (dynamic Stage N format)
L["Stage %d Sound"] = "阶段%d音效"

---- Text input labels
L["Stage %d"] = "阶段%d"
L["Out of Zone Prefix"] = "区域外前缀"
L["Ambush Prefix"] = "伏击前缀"
L["Out of Zone Label"] = "区域外标签"
L["Ambush Override Text"] = "伏击覆盖文本"
L["Custom Sound File"] = "自定义音效文件"

---- Color buttons
L["Fill Color"] = "填充颜色"
L["Background Color"] = "背景颜色"
L["Title Color"] = "标题颜色"
L["Percent Color"] = "百分比颜色"
L["Tick Mark Color"] = "刻度标记颜色"
L["Border Color"] = "边框颜色"

---- Action buttons
L["Restore Default Names"] = "恢复默认名称"
L["Restore Default Sounds"] = "恢复默认音效"
L["Reset All Defaults"] = "重置所有默认值"
L["Add File"] = "添加文件"
L["Remove File"] = "移除文件"
L["Test Stage %d"] = "测试阶段%d"
L["Test Ambush"] = "测试伏击"
L["Show What's New"] = "显示更新内容"

---- Dropdown option values — Texture
L["Default"] = "默认"
L["Flat"] = "扁平"
L["Raid HP Fill"] = "团队生命填充"
L["Classic Skill Bar"] = "经典技能条"

---- Dropdown option values — Font
L["Friz Quadrata"] = "Friz Quadrata"
L["Arial Narrow"] = "Arial Narrow"
L["Skurri"] = "Skurri"
L["Morpheus"] = "Morpheus"

---- Dropdown option values — Sound channel
L["Master"] = "主音量"
L["SFX"] = "音效"
L["Dialog"] = "对话"
L["Ambience"] = "环境"

---- Dropdown option values — Currency theme
L["Light"] = "明亮"
L["Brown"] = "棕色"
L["Dark"] = "暗黑"

---- Dropdown option values — Percent display
L["In Bar"] = "进度条内"
L["Above Bar"] = "进度条上方"
L["Above Ticks"] = "刻度上方"
L["Under Ticks"] = "刻度下方"
L["Below Bar"] = "进度条下方"
L["Off"] = "关闭"

---- Dropdown option values — Tick layer
L["Above Fill"] = "填充上方"
L["Below Fill"] = "填充下方"

---- Dropdown option values — Progress segments
L["Quarters (25/50/75/100)"] = "四等分 (25/50/75/100)"
L["Thirds (33/66/100)"] = "三等分 (33/66/100)"

---- Dropdown option values — Label mode
L["Centered"] = "居中"
L["Left (Prefix only)"] = "左侧(仅前缀)"
L["Left (Prefix + Suffix)"] = "左侧(前缀+后缀)"
L["Left (Suffix only)"] = "左侧(仅后缀)"
L["Right (Suffix only)"] = "右侧(仅后缀)"
L["Right (Prefix + Suffix)"] = "右侧(前缀+后缀)"
L["Right (Prefix only)"] = "右侧(仅前缀)"
L["Separate (Prefix + Suffix)"] = "分离(前缀+后缀)"
L["No Text"] = "无文本"

---- Dropdown option values — Label row
L["Above Bar"] = "进度条上方"
L["Below Bar"] = "进度条下方"

---- Dropdown option values — Orientation
L["Horizontal"] = "水平"
L["Vertical"] = "垂直"

---- Dropdown option values — Vertical fill
L["Fill Up"] = "向上填充"
L["Fill Down"] = "向下填充"

---- Dropdown option values — Sides
L["Left"] = "左侧"
L["Right"] = "右侧"
L["Center"] = "居中"

---- Dropdown option values — Vertical text align
L["Top Align"] = "顶部对齐"
L["Middle Align"] = "居中对齐"
L["Bottom Align"] = "底部对齐"
L["Top Prefix Only"] = "仅前缀顶部"
L["Top Suffix Only"] = "仅后缀顶部"
L["Bottom Prefix Only"] = "仅前缀底部"
L["Bottom Suffix Only"] = "仅后缀底部"
L["Separate Prefix/Suffix"] = "分离前缀/后缀"

---- Dropdown option values — Vertical percent display (short form)
L["Above"] = "上方"
L["Inside"] = "内部"
L["Below"] = "下方"

---- Hint/note blocks
L["HINT_VERTICAL_PERCENT_OFFSET"] = "垂直百分比偏移适用于垂直侧边/刻度标记侧边位置。使用刻度标记来替代单个百分比数值。"
L["HINT_VERTICAL_LOCK"] = "在垂直模式下，只有标签模式和前缀/后缀行在此处锁定。阶段名称和自定义标签仍可编辑。"
L["HINT_AUDIO_SLIDER"] = "滑块数值可以拖动或直接输入。自定义音效输入接受裸文件名、.ogg格式或完整插件路径。"
L["HINT_ADVANCED_NOTES"] = "现有安装将保留当前的保存值。新设置仅在PreydatorDB中缺少键时应用。此面板取代了旧的长格式选项页面，但使用相同的数据库。检查功能与BugSack兼容。"
L["HINT_PANEL_SUBTITLE"] = "带两列页面的标签式选项布局。滑块数值可以拖动或直接输入。"
L["HINT_EDITMODE_SUBTITLE"] = "暴雪编辑模式打开时的快速布局控制。完整选项可在选项>插件>Preydator中找到。"

---- Print / chat messages
L["Preydator: Added sound file '%s'."] = "Preydator: 已添加音效文件'%s'。"
L["Preydator: Removed sound file '%s'."] = "Preydator: 已移除音效文件'%s'。"
L["Preydator: No stage %d sound configured."] = "Preydator: 未配置阶段%d音效。"
L["Preydator: Stage %d sound file failed to play. Ensure this file exists as .ogg: %s"] = "Preydator: 阶段%d音效文件播放失败。请确保该文件以.ogg格式存在: %s"

---- EditMode window
L["Preydator Edit Mode"] = "Preydator编辑模式"
L["HINT_EDITMODE_SUBTITLE"] = "暴雪编辑模式打开时的快速布局控制。完整选项可在选项>插件>Preydator中找到。"

---- Currency Tracker windows
L["Preydator Currency"] = "Preydator货币"
L["Preydator Warband"] = "Preydator战团"
L["Currency Tracker"] = "货币追踪器"
L["Preydator Updates: New in 2.1.1"] = "Preydator更新: 2.1.1新内容"
L["WHATS_NEW_BODY"] = "Preydator 2.1.1 已发布。\n\n- 狩猎追踪列表现在会为尚未完成的 Prey 成就显示对应的进度提示\n- 成就标记的布局、缩放与数量显示已针对狩猎列表进行了优化\n- 狩猎奖励显示现在支持图标加文本、仅文本，以及紧凑的图标加数量样式\n- 与拾取相关的货币刷新路径已收紧，以减少不必要的 CPU 峰值\n\n如果你已经摆好了窗口位置，现有布局会被保留。"
L["Got It"] = "知道了"
L["Open Settings"] = "打开设置"
L["Toggle Tracker"] = "切换追踪器"
L["Toggle Warband"] = "切换战团"
L["Open Tracker"] = "打开追踪器"
L["Close Tracker"] = "关闭追踪器"
L["Open Warband"] = "打开战团"
L["Close Warband"] = "关闭战团"
L["Gain Color"] = "获得颜色"
L["Spend Color"] = "消耗颜色"

---- Hunt Table companion panel
L["Preydator Hunt Tracker"] = "Preydator狩猎追踪器"
L["Available Hunts"] = "可用狩猎"
L["Rewards unknown"] = "奖励未知"
L["Reward data pending"] = "奖励数据待定"
L["No available hunts"] = "没有可用狩猎"
L["Use /pd huntdebug at a hunt table to print payload data."] = "在狩猎面板使用/pd hinspect来打印载荷数据。"

---- Currency config page labels
L["Currencies to Track"] = "要追踪的货币"
L["Random Hunt Cost (Anguish)"] = "随机狩猎消耗(痛苦残渣)"
L["Panel Layout"] = "面板布局"
L["Adjust"] = "调整"
L["Delta Preview"] = "变化预览"
L["Normal"] = "普通"
L["Hard"] = "困难"
L["Nightmare"] = "噩梦"
L["Currency Window"] = "货币窗口"
L["Warband Window"] = "战团窗口"

---- Warband column headers
L["Realm"] = "服务器"
L["Character"] = "角色"
L["Anguish"] = "痛苦残渣"
L["Voidlight"] = "虚光灰岩"
L["Adv"] = "冒险者"
L["Vet"] = "老兵"
L["Champ"] = "冠军"
L["Shards"] = "碎片"
L["Keys"] = "钥匙"

---- Warband dynamic row labels
L["Total"] = "总计"
L["All Realms"] = "所有服务器"
L["Totals"] = "合计"
L["Subtotal"] = "小计"

---- Currency tracker summary format
L["Normal %d | Hard %d | Nightmare %s"] = "普通 %d | 困难 %d | 噩梦 %s"

---- Minimap / LDB tooltip
L["Left Click: Toggle Currency Window"] = "左键点击: 切换货币窗口"
L["Right Click: Toggle Warband Window"] = "右键点击: 切换战团窗口"
L["Shift + Right Click: Open Options"] = "Shift+右键点击: 打开选项"
L["Preydator Currency Tracker"] = "Preydator货币追踪器"

---- Hunt Scanner - Preview and Rewards
L["Preview: Normal Hunt"] = "预览: 普通狩猎"
L["Preview: Hard Hunt"] = "预览: 困难狩猎"
L["Preview: Nightmare Hunt"] = "预览: 噩梦狩猎"
L["Experience"] = "经验值"
L["Unknown"] = "未知"
L["No tracked rewards"] = "无追踪奖励"

---- Hunt Scanner - Group and Sort labels
L["Group"] = "分组"
L["Sort"] = "排序"
L["None"] = "无"
L["Difficulty"] = "难度"
L["Zone"] = "区域"
L["Title"] = "标题"
L["Top"] = "顶部"
L["Middle"] = "中部"
L["Bottom"] = "底部"

---- Hunt Scanner - Debug and Error messages
L["Preydator Hunt: unable to accept this quest right now."] = "Preydator狩猎: 暂时无法接受此任务。"
L["Preydator Hunt: unable to open quest details from this row right now."] = "Preydator狩猎: 暂时无法从此行打开任务详情。"
L["Preydator HuntScanner: snapshot error: %s"] = "Preydator狩猎扫描器: 快照错误: %s"
L["Preydator HuntDebug: no hunt snapshot captured yet."] = "Preydator狩猎调试: 尚未捕获狩猎快照。"
L["Preydator HuntDebug: sent to BugSack via error handler."] = "Preydator狩猎调试: 已通过错误处理程序发送至BugSack。"
L["Preydator HuntDebug: Could not send to BugSack: %s"] = "Preydator狩猎调试: 无法发送至BugSack: %s"
L["Preydator HuntDebug: no payload captured yet."] = "Preydator狩猎调试: 尚未捕获载荷。"

---- Preydator Core - Debug and Status messages
L["Preydator DEBUG: %s"] = "Preydator调试: %s"
L["Preydator: Sound failed to play: '%s'. Ensure the .ogg exists in Interface\\AddOns\\Preydator\\sounds\\ and is listed in Custom Sound Files."] = "Preydator: 音效播放失败: '%s'。请确保.ogg文件存在于Interface\\AddOns\\Preydator\\sounds\\目录中，并已列在自定义音效文件中。"
L["Preydator: collectgarbage API unavailable."] = "Preydator: collectgarbage API不可用。"
L["Preydator memory (KB): before=%s afterGC=%s reclaimed=%s"] = "Preydator内存(KB): 清理前=%s 清理后=%s 回收=%s"
L["Preydator: Inspect report sent to BugSack via error handler. This is intentional diagnostic output, not a runtime addon bug."] = "Preydator: 检查报告已通过错误处理程序发送至BugSack。这是故意的诊断输出，不是运行时插件错误。"
L["Preydator: Could not send inspect report to BugSack: %s"] = "Preydator: 无法将检查报告发送至BugSack: %s"
L["Preydator: Inspect report cached in PreydatorLastInspectReport (%d lines)."] = "Preydator: 检查报告已缓存至PreydatorLastInspectReport (%d行)。"
L["Preydator: %s"] = "Preydator: %s"
L["Preydator: Debug logging enabled."] = "Preydator: 调试日志已启用。"
L["Preydator: Debug logging disabled."] = "Preydator: 调试日志已禁用。"
L["Preydator: Debug log cleared."] = "Preydator: 调试日志已清除。"
L["Preydator: Debug log is empty."] = "Preydator: 调试日志为空。"
L["Preydator: Debug log (last %d of %d)"] = "Preydator: 调试日志 (最后%d条，共%d条)"
L["Preydator: debug commands are 'debug on', 'debug off', 'debug show', 'debug clear'."] = "Preydator: 调试命令为 'debug on', 'debug off', 'debug show', 'debug clear'。"
L["Preydator: Progress bar forced visible."] = "Preydator: 进度条已强制显示。"
L["Preydator: Progress bar auto mode restored."] = "Preydator: 进度条自动模式已恢复。"
L["Preydator: Progress bar force show = %s"] = "Preydator: 进度条强制显示 = %s"
L["Preydator commands: options | show | hide | toggle | mem | debug <on|off|show|clear>"] = "Preydator命令: options | show | hide | toggle | debug <on|off|show|clear> | inspect [bs] | qinspect [questID] [bs] | hinspect [bs] | hinspectcopy [bs]"

---- Currency Tracker - Debug
L["Preydator CurrencyDebug: %s"] = "Preydator货币调试: %s"

---- Settings - Additional labels
L["Panel Theme"] = "面板主题"
L["Accept"] = "接受"

---- Edit Mode Preview
L["Preydator (Edit Mode Preview)"] = "Preydator (编辑模式预览)"
L["Unknown Zone"] = "未知区域"

---- Hunt reward cache
L["Preydator: Hunt reward cache refresh queued."] = "Preydator: 狩猎奖励缓存刷新已加入队列。"

---- Zone names (from game)
L["Harandar"] = "哈籁恩达尔"
L["Voidstorm"] = "虚空风暴"
L["Eversong Woods"] = "永歌森林"
L["Zul'Aman"] = "祖阿曼"

---- Debug report header
L["Preydator HuntDebug Report"] = "Preydator狩猎调试报告"

---- Preview reward text (partial localization)
L["Preview Cache Reward"] = "预览缓存奖励"
L["Preview Trinket"] = "预览饰品"
L["Preview Weapon"] = "预览武器"
L["Champ. Crest"] = "冠军纹章"

---- Currency Tracker - Additional strings
L["No active prey"] = "无活跃猎物"
L["Stage %d"] = "阶段%d"
L["character"] = "角色"
L["completed"] = "已完成"
L["available"] = "可用"

---- Settings panel - Additional labels
L["Disable Minimap Button"] = "禁用小地图按钮"
L["Group Hunts By"] = "狩猎分组方式"
L["Sort Hunts By"] = "狩猎排序方式"
L["Show Quest Reward Icons"] = "显示任务奖励图标"
L["Match Currency Theme"] = "匹配货币主题"
L["Select"] = "选择"

---- Sound file management
L["File is already in the list"] = "文件已在列表中"
L["Default sound files cannot be removed"] = "默认音效文件无法移除"
L["File is not in the custom list"] = "文件不在自定义列表中"
L["Use a valid sound filename (optionally with .ogg)"] = "请使用有效的音效文件名(可选.ogg扩展名)"

---- Debug log entries
L["Preydator: "] = "Preydator: "
L["Preydator: Hunt reward cache refresh queued."] = "Preydator: 狩猎奖励缓存刷新已排队。"
L["Preydator Hunt: unable to accept this quest right now."] = "Preydator狩猎: 暂时无法接受此任务。"
L["Preydator Hunt: unable to open quest details from this row right now."] = "Preydator狩猎: 暂时无法从此行打开任务详情。"
L["Preydator HuntScanner: snapshot error: %s"] = "Preydator狩猎扫描器: 快照错误: %s"
L["Preydator HuntDebug: no hunt snapshot captured yet."] = "Preydator狩猎调试: 尚未捕获狩猎快照。"
L["Preydator HuntDebug: sent to BugSack via error handler."] = "Preydator狩猎调试: 已通过错误处理程序发送到BugSack。"
L["Preydator HuntDebug: Could not send to BugSack: "] = "Preydator狩猎调试: 无法发送到BugSack: "
L["Preydator HuntDebug: no payload captured yet."] = "Preydator狩猎调试: 尚未捕获有效载荷。"
L["Preydator CurrencyDebug: "] = "Preydator货币调试: "
L["Preydator DEBUG: "] = "Preydator调试: "
L["Preydator: Sound failed to play: '%s'. Ensure the .ogg exists in Interface\\AddOns\\Preydator\\sounds\\ and is listed in Custom Sound Files."] = "Preydator: 音效播放失败: '%s'。请确保.ogg文件存在于Interface\\AddOns\\Preydator\\sounds\\目录中，并且已在自定义音效文件中列出。"
L["Preydator: collectgarbage API unavailable."] = "Preydator: collectgarbage API不可用。"
L["Preydator memory (KB): before=%s afterGC=%s reclaimed=%s"] = "Preydator内存(KB): 之前=%s 垃圾回收后=%s 回收=%s"
L["Preydator: Inspect report sent to BugSack via error handler. This is intentional diagnostic output, not a runtime addon bug."] = "Preydator: 检查报告已通过错误处理程序发送到BugSack。这是有意为之的诊断输出，不是运行时插件错误。"
L["Preydator: Could not send inspect report to BugSack: "] = "Preydator: 无法发送检查报告到BugSack: "
L["Preydator: Inspect report cached in PreydatorLastInspectReport (%s lines)."] = "Preydator: 检查报告已缓存到PreydatorLastInspectReport (%s行)。"
L["Preydator: Added sound file '%s'."] = "Preydator: 已添加音效文件 '%s'。"
L["Preydator: Removed sound file '%s'."] = "Preydator: 已移除音效文件 '%s'。"
L["Preydator: No stage %d sound configured."] = "Preydator: 未配置阶段%d音效。"
L["Preydator: Stage %d sound file failed to play. Ensure this file exists as .ogg: %s"] = "Preydator: 阶段%d音效文件播放失败。请确保此文件以.ogg格式存在: %s"
L["Enhance Sounds layers extra plays for perceived loudness. WoW does not expose true per-addon file volume."] = "增强音效通过额外播放层来提升感知响度。魔兽世界不公开真正的插件文件音量控制。"
L["Preydator: Debug logging enabled."] = "Preydator: 调试日志已启用。"
L["Preydator: Debug logging disabled."] = "Preydator: 调试日志已禁用。"
L["Preydator: Debug log cleared."] = "Preydator: 调试日志已清除。"
L["Preydator: Debug log is empty."] = "Preydator: 调试日志为空。"
L["Preydator: Debug log (last %d of %d)"] = "Preydator: 调试日志 (最后%d条，共%d条)"
L["Preydator: debug commands are 'debug on', 'debug off', 'debug show', 'debug clear'."] = "Preydator: 调试命令为 'debug on', 'debug off', 'debug show', 'debug clear'。"
L["Preydator: Progress bar forced visible."] = "Preydator: 进度条已强制显示。"
L["Preydator: Progress bar auto mode restored."] = "Preydator: 进度条自动模式已恢复。"
L["Preydator: Progress bar force show = %s"] = "Preydator: 进度条强制显示 = %s"
L["Preydator commands: options | show | hide | toggle | mem | debug <on|off|show|clear>"] = "Preydator命令: options | show | hide | toggle | debug <on|off|show|clear> | inspect [bs] | qinspect [questID] [bs] | hinspect [bs] | hinspectcopy [bs]"
L["Preydator: Inspect report sent to BugSack via error handler (debug module)."] = "Preydator: 检查报告已通过错误处理程序发送到BugSack (调试模块)。"
L["Preydator: Could not send inspect report to BugSack: "] = "Preydator: 无法发送检查报告到BugSack: "
L["Preydator: Inspect report cached in PreydatorLastInspectReport (debug module)."] = "Preydator: 检查报告已缓存到PreydatorLastInspectReport (调试模块)。"
L["Bar movement, scale, font, texture, and sound settings."] = "进度条移动、缩放、字体、纹理和音效设置。"
L["Stage Names"] = "阶段名称"
L["Zone:"] = "区域:"
L["Ambush:"] = "伏击:"
L["Restore Default Names"] = "恢复默认名称"
L["Restore Default Sounds"] = "恢复默认音效"
L["Reset All Defaults"] = "重置所有默认值"
L["Custom Sound Files: No Spaces"] = "自定义音效文件: 请勿使用空格"
L["Interface\\AddOns\\Preydator\\sounds\\"] = "Interface\\AddOns\\Preydator\\sounds\\"
L["Add File"] = "添加文件"
L["Test Ambush"] = "测试伏击"
L["Manual test"] = "手动测试"
L["Ambush"] = "伏击"
L["Detected from"] = "检测来自"
L["TryPlaySound"] = "尝试播放音效"
L["blocked by soundsEnabled=false"] = "被soundsEnabled=false阻止"
L["path="] = "路径="
L["channel="] = "通道="
L["ignoreToggle="] = "忽略切换="
L["result="] = "结果="
L["enhance="] = "增强="
L["extraPlays="] = "额外播放="
L["ResolveStageSoundPath"] = "解析阶段音效路径"
L["invalid stage"] = "无效阶段"
L["stage="] = "阶段="
L["source="] = "来源="
L["saved"] = "已保存"
L["default"] = "默认"
L["none"] = "无"
L["TryPlayStageSound"] = "尝试播放阶段音效"
L["no resolved path"] = "无解析路径"
L["skipped already played"] = "跳过已播放"
L["success"] = "成功"
L["primary failed, trying fallback stage="] = "主音效失败，尝试回退阶段="
L["fallback stage="] = "回退阶段="
L["also failed"] = "也失败了"
L["PlaySoundFile returned false"] = "PlaySoundFile返回false"

---- Currency allow list labels
L["Anguish"] = "痛苦残渣"
L["Voidlight Marl"] = "虚光灰岩"
L["Voidlight"] = "虚光灰岩"
L["Adventurer Dawncrest"] = "冒险者曙光纹章"
L["Adv. Crest"] = "冒险者曙光纹章"
L["Veteran Dawncrest"] = "老兵曙光纹章"
L["Vet. Crest"] = "老兵曙光纹章"
L["Champion Dawncrest"] = "冠军曙光纹章"

---- Difficulty detection (internal values)
L["nightmare"] = "噩梦"
L["hard"] = "困难"
L["normal"] = "普通"

---- Debug output prefixes
L["Quest "] = "任务 "
L["Currency "] = "货币 "
L["normal="] = "普通="
L[" hard="] = " 困难="
L[" nightmare="] = " 噩梦="

---- Hunt Scanner subtitle
L["Group: "] = "分组: "
L["Sort: "] = "排序: "

---- Warband Window settings
L["Show Realm in Warband"] = "在战团中显示服务器"
L["Use Icons for Warband Currencies"] = "战团货币使用图标"
L["Mouseover Hide"] = "鼠标悬停显示"
L["Panel hides until moused over."] = "面板会隐藏，直到鼠标悬停其上。"
L["In combat it stays hidden until out of combat."] = "战斗中保持隐藏，脱离战斗后可悬停显示。"
L["Click to toggle."] = "点击切换。"
L["Warband Theme"] = "战团主题"
L["Warband Width"] = "战团窗口宽度"
L["Warband Height"] = "战团窗口高度"
L["Warband Font Size"] = "战团字体大小"
L["Warband Scale"] = "战团缩放"
L["Tracked in Warband"] = "战团追踪"
L["Show Prey Track (Alts) in Warband"] = "在战团中显示猎物追踪(小号)"
L["Prey Track Shows Completed"] = "猎物追踪显示已完成"

---- Hunt Table preview
L["Show Preview Pane"] = "显示预览面板"
L["Hide Preview Pane"] = "隐藏预览面板"
L["Hunt Panel Width"] = "狩猎面板宽度"
L["Hunt Panel Height"] = "狩猎面板高度"
L["Hunt Panel Scale"] = "狩猎面板缩放"
L["Hunt Panel Font Size"] = "狩猎面板字体大小"
L["Use Hunt Table controls here to manage sorting, grouping, panel size, and reward cache behavior."] = "使用狩猎面板控件来管理排序、分组、面板大小和奖励缓存行为。"
L["Refresh Hunt Cache"] = "刷新狩猎缓存"
L["Refresh Hunt Table Now"] = "立即刷新狩猎表"
L["Hunt Theme"] = "狩猎主题"
L["Anchor Align"] = "锚点对齐"
