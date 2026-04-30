-- Populate DF_AllLocales["zhCN"] so Core.lua's ADDON_LOADED handler
-- can apply this locale's translations as an overlay if the user's
-- languageOverride selects it. No AceLocale interaction here — the
-- overlay step happens once the SavedVariable is actually populated,
-- which is only guaranteed at ADDON_LOADED time (not file-scope).
DF_AllLocales = DF_AllLocales or {}
DF_AllLocales.zhCN = {}
local L = DF_AllLocales.zhCN
L["    Show Frame Glow"] = "    显示框体发光"
L["    Show ZZZ Icon"] = "    显示 ZZZ 图标"
L["— click to edit"] = "— 点击编辑"
L[" indicator"] = "指示器"
L[" indicators"] = "指示器"
L["⚠ Note: Click-through icons will not show tooltips."] = "⚠ 注意: 点击穿透的图标不会显示鼠标提示"
L["\"%s\" will be overwritten."] = [=["%s" 将被覆盖。
]=]
L["%d - %d players"] = "%d - %d 个玩家"
L["%d binds"] = "%d 个绑定"
L["%d blacklisted"] = "已拉黑 %d 个"
L["%d override"] = "%d 个覆盖"
L["%d overrides"] = "%d 个覆盖"
L["%d players"] = "%d 个玩家"
L["%d-%d players"] = "%d - %d 个玩家"
L["%s (Copy)"] = "%s （副本）"
L["%s (currently %s)"] = "%s (当前 %s)"
L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = "检测到 %s 。你想使用哪个点击施法插件？"
L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = "检测到冲突插件：%s，你想使用哪个点击施法插件？"
L["%s settings reset to defaults."] = "%s 设置重置为默认值。"
L["%sGlobal: 80%s %s— Setting matches global, no override stored%s"] = "%s全局：80%s %s——设置与全局一致，未覆盖储存%s"
L["%sModified%s %s— Setting differs from global. Click%s %sreset%s %sto revert.%s"] = "%s已修改%s %s——设置与全局设置不同。点击%s %s重置%s %s以恢复。%s"
--[[Translation missing --]]
--[[ L["(none)"] = "(none)"--]] 
L["(offline)"] = "(离线)"
L["(skipped)"] = "(跳过)"
--[[Translation missing --]]
--[[ L["[Linked]"] = "[Linked]"--]] 
--[[Translation missing --]]
--[[ L["[Override]"] = "[Override]"--]] 
--[[Translation missing --]]
--[[ L["[Unassigned]"] = "[Unassigned]"--]] 
L["+ Add"] = "+ 添加"
L["+ Add aura"] = "+ 添加光环"
L["+ Add Indicator"] = "+ 添加指示器"
L["+ Add Layout"] = "+ 添加布局"
L["+ Add Option"] = "+添加选项"
L["+ Add Step"] = "+ 添加步骤"
L["+ Add Trigger"] = "+添加触发器"
L["+ Create Group"] = "+ 创建组"
L["+ New"] = "+ 新建"
L["+ New Wizard"] = "+ 新建向导"
L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = "• 在查看某些增益或减益效果时遇到困难？• 这个向导可以帮助你选择正确的光环设置"
L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = "• 难以看清某些增益或减益效果？• 此向导可帮助你选择合适的光环设置"
L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = [=[• 名字文本
• 生命值文本
• 状态文本 (死亡/离线)
• 增益层数与持续时间
• 减益层数与持续时间
• 宠物框体文本
• 目标法术持续时间
• 防御图标持续时间
• 状态图标文本 (复活、召唤等)
• 分组标签 (团队)]=]
L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = "• 名字文本 • 生命值文本 • 状态文本（死亡/离线） • 增益效果层数与持续时间 • 减益效果层数与持续时间 • 宠物框体文本 • 目标法术持续时间 • 减伤图标持续时间 • 状态图标文本（复活、召唤等） • 小队标签（团队）"
L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = "• 推荐默认设置适合大多数玩家 • 手动模式可让你微调每一个过滤选项"
--[[Translation missing --]]
--[[ L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = ""--]] 
L["0=Auto, Higher=On top of more elements"] = "0=自动, 数值越高=覆盖更多元素"
--[[Translation missing --]]
--[[ L["1"] = "1"--]] 
L["1 = High"] = "1 = 高"
--[[Translation missing --]]
--[[ L["1. Open ElvUI config with %s/ec%s"] = "1. Open ElvUI config with %s/ec%s"--]] 
L["10 = Low"] = "10 = 低"
--[[Translation missing --]]
--[[ L["2. Go to %sUnitFrames%s (left sidebar)"] = "2. Go to %sUnitFrames%s (left sidebar)"--]] 
L["20 players (fixed)"] = "20 名玩家 (固定)"
--[[Translation missing --]]
--[[ L["3. Click %sGeneral%s at the top"] = "3. Click %sGeneral%s at the top"--]] 
--[[Translation missing --]]
--[[ L["4. Scroll down to %sDisabled Blizzard Frames%s"] = "4. Scroll down to %sDisabled Blizzard Frames%s"--]] 
--[[Translation missing --]]
--[[ L["5. Under %sGroup Units%s, uncheck %sParty%s and %sRaid%s"] = "5. Under %sGroup Units%s, uncheck %sParty%s and %sRaid%s"--]] 
--[[Translation missing --]]
--[[ L["6. Click the reload button when prompted"] = "6. Click the reload button when prompted"--]] 
--[[Translation missing --]]
--[[ L["A layout with this name already exists in %s"] = "A layout with this name already exists in %s"--]] 
L["a placed indicator to remove it from the frame"] = "预览框架中的某个指示器可从框架中移除"
L["a placed indicator to reposition it on the frame"] = "预览框架中的某个指示器可重新摆放位置"
--[[Translation missing --]]
--[[ L["A profile with this name already exists"] = "A profile with this name already exists"--]] 
L["A to Z"] = "A 到 Z"
L["Abbreviate (K/M)"] = "缩写 (千/百万)"
L["Above Health Bar"] = "生命条上方"
L["Above Owner"] = "主人上方"
L["Above Party"] = "小队上方"
L["Above Raid"] = "团队上方"
L["Absorb Shield"] = "吸收护盾"
L["Absorbs"] = "吸收"
L["Actions"] = "动作"
--[[Translation missing --]]
--[[ L["Active"] = "Active"--]] 
L["Active Bindings"] = "当前绑定"
L["Active Bindings (%d)"] = "当前绑定 (%d)"
L["ACTIVE INDICATORS"] = "活跃的指示器"
L["Active:"] = "生效:"
--[[Translation missing --]]
--[[ L["Actually, disable it"] = "Actually, disable it"--]] 
L["Add"] = "增加"
L["Add #showtooltip"] = "添加 #showtooltip"
L["Add /stopcasting"] = "添加 /stopcasting"
L["Add Layout"] = "添加布局"
--[[Translation missing --]]
--[[ L["Add New Binding"] = "Add New Binding"--]] 
L["Add Offline Player"] = "添加离线玩家"
--[[Translation missing --]]
--[[ L[ [=[Add players from the roster
or use quick add buttons]=] ] = [=[Add players from the roster
or use quick add buttons]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Add players from the roster
or use quick add buttons]=] ] = ""--]] 
L["Additive (ADD)"] = "叠加 (ADD)"
L["Advanced"] = "高级"
L["Affected Elements"] = "受影响的元素"
L["AFK"] = "暂离"
L["AFK Icon"] = "暂离图标"
L["Aggro Highlight"] = "仇恨高亮"
L["Aggro Settings"] = "仇恨设置"
L["Alert if anyone is missing the buff"] = "当有玩家缺失该增益时警告"
L["Alert only if nobody has the buff"] = "当所有玩家未拥有该增益时警告"
L["Alert When Expiring"] = "当即将过期时警告"
L["All"] = "所有"
--[[Translation missing --]]
--[[ L["ALL (AND)"] = "ALL (AND)"--]] 
L["All Buffs"] = "所有增益"
L["All Debuffs"] = "所有减益"
L["All Dispellable"] = "所有可驱散的"
L["All players in a unified grid. Sorting applies raid-wide."] = "所有玩家在统一网格中。排序应用于整个团队。"
--[[Translation missing --]]
--[[ L["ALL triggers must be active"] = "ALL triggers must be active"--]] 
L["Alpha"] = "透明度"
--[[Translation missing --]]
--[[ L["Alphabetical"] = "Alphabetical"--]] 
L["Alphabetical (within class/role)"] = "按字母排序 (职业/角色内)"
L["Always"] = "始终生效"
L["Always First"] = "始终第一"
L["Always Green"] = "始终绿色"
L["Always Last"] = "始终最后"
L["an indicator on the frame to expand its settings"] = "预览框架中的某个指示器展开对应设置"
L["Anchor"] = "锚点"
L["Anchor Point"] = "锚点位置"
L["Anchor Position"] = "锚点坐标"
L["Anchor To"] = "锚定到"
L["Animated Border"] = "动画边框"
--[[Translation missing --]]
--[[ L["ANY (OR)"] = "ANY (OR)"--]] 
L["Any Target"] = "任意目标"
--[[Translation missing --]]
--[[ L["ANY trigger activates the effect"] = "ANY trigger activates the effect"--]] 
L["Appearance"] = "外观"
L["Apply"] = "应用"
L["Apply to All"] = "应用到全部"
L["Apply to Frames:"] = "应用到框体:"
L["Arcane Intellect (Mage)"] = "奥术智慧 (法师)"
--[[Translation missing --]]
--[[ L["are secret-tracked"] = "are secret-tracked"--]] 
L["Are you sure?"] = "你确定吗?"
L["Arena"] = "竞技场"
--[[Translation missing --]]
--[[ L["Arena header will show using raid1-5 unit IDs"] = "Arena header will show using raid1-5 unit IDs"--]] 
--[[Translation missing --]]
--[[ L["Arena mode %sDISABLED%s"] = "Arena mode %sDISABLED%s"--]] 
--[[Translation missing --]]
--[[ L["Arena mode %sENABLED%s for testing"] = "Arena mode %sENABLED%s for testing"--]] 
L["Arrange Groups In"] = "分组排列方式"
L["Arrange In"] = "排列方式"
L["Arrange Players In"] = "玩家排列方式"
--[[Translation missing --]]
--[[ L["Attach the handle to the container, the first visible unit, or the last visible unit."] = "Attach the handle to the container, the first visible unit, or the last visible unit."--]] 
L["Attach To"] = "附着到"
L["Attached + Overflow"] = "附着 + 溢出"
L["Attached to Health"] = "附着于生命值"
L["Attached to Owner"] = "附着于主人"
L["Aura Blacklist"] = "光环黑名单"
L["Aura Data Source"] = "光环数据源"
L["Aura Designer"] = "光环设计器"
L["Aura Designer Alpha"] = "光环设计器透明度"
L["Aura Designer is active alongside Buffs."] = "光环设计器与增益同时启用"
L["Aura Designer is disabled"] = "光环设计器已禁用"
L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = "光环编辑器支持治疗专精与增辉唤魔师。您可通过上方下拉菜单手动选择专精，以预先配置指示器。"
L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = "光环编辑器支持治疗专精与增辉唤魔师。您可通过上方下拉菜单手动选择专精，以预先配置指示器。"
L["Aura Filter Setup"] = "光环过滤器设置"
L["Aura Filters"] = "光环过滤器"
L["Auras"] = "光环"
L["Auras Alpha"] = "光环透明度"
L["Auto (%s)"] = "自动 (%s)"
L["Auto (detect class)"] = "自动（检测职业）"
L["Auto (detect spec)"] = "自动检测专精"
--[[Translation missing --]]
--[[ L["Auto (detect)"] = "Auto (detect)"--]] 
L["Auto (Spec Default)"] = "自动 (专精默认)"
L["Auto Layouts"] = "自动布局"
L["Auto Layouts is a Raid-only feature. Switch to Raid mode to configure automatic layout switching based on content type and group size."] = "自动布局仅适用于团队模式。请切换到团队模式，根据内容类型和队伍人数配置自动布局切换。"
L["Auto Layouts module not loaded."] = "自动布局模块未加载"
L["Auto-add DPS"] = "自动添加 DPS"
L["Auto-add Healers"] = "自动添加治疗"
L["Auto-add Tanks"] = "自动添加坦克"
--[[Translation missing --]]
--[[ L["Auto-create disabled"] = "Auto-create disabled"--]] 
--[[Translation missing --]]
--[[ L["Auto-Create Profiles"] = "Auto-Create Profiles"--]] 
L["Auto-create profiles for loadouts"] = "为配装方案自动创建配置"
L["Auto-detect (your class's buff)"] = "自动检测 (你的职业增益)"
--[[Translation missing --]]
--[[ L["Auto-Fit Border to Frame Size"] = "Auto-Fit Border to Frame Size"--]] 
L["Automatically add players by role when they join your group."] = "当玩家加入队伍时按角色自动添加"
L["Automatically detects player-dispellable debuffs via the RAID_PLAYER_DISPELLABLE filter. Configure the overlay on the Dispel Overlay page."] = "通过 RAID_PLAYER_DISPELLABLE 过滤器自动侦测玩家可驱散的减益效果。可在 “驱散覆盖” 页面设置覆盖效果。"
L["Auto-Populate"] = "自动填充"
--[[Translation missing --]]
--[[ L["Auto-profile \"%s\" activated (%s, %d players)"] = "Auto-profile \"%s\" activated (%s, %d players)"--]] 
--[[Translation missing --]]
--[[ L["Auto-profile deactivated (profile deleted)"] = "Auto-profile deactivated (profile deleted)"--]] 
--[[Translation missing --]]
--[[ L["Auto-profile deactivated, using global settings"] = "Auto-profile deactivated, using global settings"--]] 
L["Auto-Switch by Spec"] = "按专精自动切换"
--[[Translation missing --]]
--[[ L["Auto-switched to profile: %s"] = "Auto-switched to profile: %s"--]] 
L["Auto-switching disabled"] = "自动切换已关闭"
L["Available Profiles"] = "可用配置"
--[[Translation missing --]]
--[[ L["A-Z"] = "A-Z"--]] 
L["Back"] = "返回"
--[[Translation missing --]]
--[[ L["Back to List"] = "Back to List"--]] 
L["Background"] = "背景"
L["Background Alpha"] = "背景透明度"
L["Background Color"] = "背景颜色"
L["Background Fill"] = "背景填充"
L["Background Mode"] = "背景模式"
L["Background Only"] = "仅背景"
L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = [=[仅背景: 普通纯色背景
仅缺失生命值: 在缺失生命值处显示彩色条
两者: 同时显示]=]
--[[Translation missing --]]
--[[ L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = ""--]] 
L["Background Texture"] = "背景材质"
--[[Translation missing --]]
--[[ L["Bar"] = "Bar"--]] 
L["Bar Color"] = "条颜色"
L["Bar Texture"] = "条材质"
L["Bars"] = "状态条"
L["Battle Shout (Warrior)"] = "战斗怒吼 (战士)"
L["Battlegrounds"] = "战场"
--[[Translation missing --]]
--[[ L["Before You Enable"] = "Before You Enable"--]] 
L["Below Health Bar"] = "生命条下方"
L["Below Owner"] = "主人下方"
L["Below Party"] = "小队下方"
L["Below Raid"] = "团队下方"
L["Big Defensives"] = "重要防御技能"
L["Bind Action"] = "绑定动作"
L["Bind Item"] = "绑定物品"
L["Bind Spell"] = "绑定法术"
--[[Translation missing --]]
--[[ L["Binding Tooltips"] = "Binding Tooltips"--]] 
L["Binding:"] = "绑定:"
--[[Translation missing --]]
--[[ L["Bindings only cast their assigned spell"] = "Bindings only cast their assigned spell"--]] 
L["BINDS"] = "点击施法"
L["Bleed / Enrage"] = "流血 / 狂暴"
--[[Translation missing --]]
--[[ L["Blend %"] = "Blend %"--]] 
L["Blend Mode"] = "混合模式"
L["Blessing of the Bronze (Evoker)"] = "青铜祝福 (唤魔师)"
L["Blizzard"] = "暴雪"
L["Blizzard (Default)"] = "暴雪（默认）"
L["Blizzard Click-Casting"] = "暴雪点击施法"
L["Blizzard Frame Settings"] = "暴雪框体设置"
L["Blizzard Frames"] = "暴雪框体"
L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = "暴雪模式：・同步暴雪默认框架的增益与减益效果・需要正确配置暴雪团队框架设置・在大型团队中性能消耗略高 直接 API：・可自主控制框架显示内容・部分过滤器可能遗漏某些增益或减益效果・部分可能显示多余效果・可精细调整以获得最佳效果"
--[[Translation missing --]]
--[[ L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = ""--]] 
L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = [=[暴雪内置的点击施法可能与
DandersFrames 的点击施法设置冲突。

建议清除暴雪在你使用
DandersFrames 绑定的框体上的绑定。]=]
L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = "暴雪内置的点击施法可能会与 DandersFrames 的点击施法设置冲突。建议您在使用 DandersFrames 绑定的框架上清除暴雪的按键绑定。"
L["Border"] = "边框"
L["Border Color"] = "边框颜色"
L["Border Inset"] = "边框内缩"
--[[Translation missing --]]
--[[ L["Border Mode:"] = "Border Mode:"--]] 
L["Border Opacity"] = "边框不透明度"
L["Border Scale"] = "边框缩放"
L["Border Size"] = "边框大小"
L["Border Thickness"] = "边框厚度"
L["Boss Debuffs"] = "首领减益"
L["Boss Debuffs (Private Auras) are special debuffs that Blizzard hides from addons."] = "首领减益 (私有光环) 是暴雪对插件隐藏的特殊减益"
L["Both"] = "两者"
L["Bottom"] = "底部"
L["Bottom Edge"] = "底部边缘"
L["Bottom Left"] = "左下"
L["Bottom Right"] = "右下"
L["Bottom to Top"] = "从下到上"
--[[Translation missing --]]
--[[ L["Bounce"] = "Bounce"--]] 
--[[Translation missing --]]
--[[ L["Bound: %s"] = "Bound: %s"--]] 
L["Branch"] = "分支"
--[[Translation missing --]]
--[[ L["Branching Rules"] = "Branching Rules"--]] 
L["BUFF BLACKLIST"] = "增益黑名单"
--[[Translation missing --]]
--[[ L["Buff Filters"] = "Buff Filters"--]] 
L["Buff Icon"] = "增益图标"
--[[Translation missing --]]
--[[ L["Buff Icons"] = "Buff Icons"--]] 
L["Buff Icons Click-Through"] = "增益图标点击穿透"
L["Buff Tooltips"] = "增益鼠标提示"
L["Buffs"] = "增益"
L["Buffs are disabled. Aura Designer is managing your auras."] = "增益效果已禁用。光环设计器正在管理你的光环。"
--[[Translation missing --]]
--[[ L["Buffs flagged by Blizzard to show up on raid frames."] = "Buffs flagged by Blizzard to show up on raid frames."--]] 
L["Buffs flagged to show on raid frames during combat, such as self-cast HoTs."] = "设置为在战斗中显示于团队框架的增益效果，例如自身施放的持续治疗效果。"
L["Buffs that can be right-click cancelled."] = "可被右键点击取消的增益"
L["Buffs that cannot be cancelled by the player."] = "无法被玩家取消的增益"
L["Buffs to Check (Manual Mode)"] = "要检查的增益 (手动模式)"
--[[Translation missing --]]
--[[ L["Building: "] = "Building: "--]] 
--[[Translation missing --]]
--[[ L["Built-in Wizards"] = "Built-in Wizards"--]] 
L["By Health %"] = "按生命值百分比"
L["Cancel"] = "取消"
L["Cancel Fade on Dispellable Debuff"] = "可驱散减益时取消淡出"
L["Cancelable"] = "可取消的增益"
--[[Translation missing --]]
--[[ L["Cannot delete Default profile."] = "Cannot delete Default profile."--]] 
L["Cannot disable test mode while frames are unlocked. Lock frames first."] = "框体未锁定时无法禁用测试模式，请先锁定框体。"
--[[Translation missing --]]
--[[ L["Cannot Edit"] = "Cannot Edit"--]] 
L["Cannot enter test mode during combat."] = "无法在战斗中进入测试模式。"
--[[Translation missing --]]
--[[ L["Cannot toggle arena mode during combat"] = "Cannot toggle arena mode during combat"--]] 
--[[Translation missing --]]
--[[ L["Cannot toggle test mode during combat."] = "Cannot toggle test mode during combat."--]] 
--[[Translation missing --]]
--[[ L["Cannot unlock - container doesn't exist!"] = "Cannot unlock - container doesn't exist!"--]] 
L["Cannot unlock - failed to create mover frame!"] = "无法解锁 - 创建移动框体失败！"
L["Cannot unlock frames during combat."] = "战斗中无法解锁框体。"
--[[Translation missing --]]
--[[ L["Cannot use this action in combat."] = "Cannot use this action in combat."--]] 
L["Cast on DOWN"] = "按下时施法"
L["Categories"] = "类别"
L["Category Filters"] = "分类过滤"
L["CC effects like stuns, roots, and incapacitates."] = "例如昏迷、定身、瘫痪等群体控制效果。"
L["Center"] = "居中"
L["Center (Horizontal)"] = "居中 (水平)"
L["Center (Vertical)"] = "居中 (垂直)"
L["Center of Group"] = "分组居中"
L["Character"] = "角色"
--[[Translation missing --]]
--[[ L["Character Import"] = "Character Import"--]] 
L["Choose how DandersFrames reads aura data for buffs, debuffs, defensives, and dispel detection."] = "决定 DandersFrames 如何读取增益效果、减益效果、防御性技能以及用于驱散检测的光环数据。"
L["Choose Icon"] = "选择图标"
--[[Translation missing --]]
--[[ L["Choose whether to enable the frame border overlay."] = "Choose whether to enable the frame border overlay."--]] 
L["Choose which groups to display."] = "选择要显示的分组"
L["Clamp Mode"] = "限制模式"
--[[Translation missing --]]
--[[ L["Class"] = "Class"--]] 
L["Class Color"] = "职业颜色"
L["Class Color Alpha"] = "职业颜色透明度"
L["Class Colors"] = "职业颜色"
L["Class Filter"] = "职业过滤"
L["Class Power"] = "职业资源"
L["Class Power Pips"] = "职业资源点"
L["Class Priority"] = "职业优先级"
L["Clear"] = "清除"
L["Clear All"] = "清除所有"
--[[Translation missing --]]
--[[ L["Clear All Bindings"] = "Clear All Bindings"--]] 
--[[Translation missing --]]
--[[ L["Clear Blizzard Bindings"] = "Clear Blizzard Bindings"--]] 
L["Clear Log"] = "清除日志"
L["Click"] = "点击"
L["Click %sEdit Settings%s on a profile to customise it. This takes you to the settings tabs with an editing banner at the top. While editing, any setting you change is stored as an override for that profile only."] = "点击布局旁的 %s编辑设置%s 按钮，这会跳转至一个顶部带有一个编辑提示信息的选项卡，以此让你进行自定义。在编辑过程中，你所做的任何更改都将仅作为该布局的设置进行保存。"
L["Click %sExit Editing%s when done. Your overrides are saved to the profile. If you change a setting back to match global, the override is automatically removed."] = "完成编辑后，请点击 %s退出编辑%s 按钮。你的自定义设置将保存至布局配置中。如果你将某个设置恢复至与全局设置一致的状态，那么该自定义设置将自动被移除。"
L["Click a color swatch to open the color picker. These settings are shared across party and raid frames."] = "点击色块打开颜色选择器，这些设置在小队和团队框体间共享"
--[[Translation missing --]]
--[[ L["Click a setting to link it to your wizard"] = "Click a setting to link it to your wizard"--]] 
L["Click item slot to bind"] = "点击物品栏位绑定"
L["Click macro to bind"] = "点击宏绑定"
--[[Translation missing --]]
--[[ L["Click or drag a spell onto the frame to place it"] = "Click or drag a spell onto the frame to place it"--]] 
L["Click spell to bind"] = "点击法术绑定"
L["Click to bind..."] = "点击绑定..."
--[[Translation missing --]]
--[[ L["Click to cycle through steps"] = "Click to cycle through steps"--]] 
L["Click to edit"] = "点击编辑"
L["Click to edit range"] = "点击编辑距离"
--[[Translation missing --]]
--[[ L["Click to set branch target"] = "Click to set branch target"--]] 
L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = "点击以同步 小队 & 团队 %s 设置。在一个模式中所做的更改将会自动应用到另一个模式中。"
L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = "点击以同步 小队 & 团队 %s 设置。在一个模式中所做的更改将会自动应用到另一个模式中。"
--[[Translation missing --]]
--[[ L["Click to toggle"] = "Click to toggle"--]] 
--[[Translation missing --]]
--[[ L["Click-cast profile: %s"] = "Click-cast profile: %s"--]] 
L["Click-Casting"] = "点击施法"
L["Click-Casting Addon Conflict"] = "点击施法插件冲突"
L["Click-Through Icons"] = "点击穿透图标"
--[[Translation missing --]]
--[[ L["Clip Border to Frame"] = "Clip Border to Frame"--]] 
L["Close"] = "关闭"
L["Color"] = "颜色"
L["Color and opacity of the empty/inactive pips."] = "空/未激活资源点的颜色和透明度"
--[[Translation missing --]]
--[[ L["Color Bar by Duration"] = "Color Bar by Duration"--]] 
L["Color by Dispel Type"] = "按驱散类型着色"
--[[Translation missing --]]
--[[ L["Color by Time"] = "Color by Time"--]] 
L["Color by Time Remaining"] = "按剩余时间着色"
--[[Translation missing --]]
--[[ L["Color Duration by Time"] = "Color Duration by Time"--]] 
L["Color Mode"] = "颜色模式"
--[[Translation missing --]]
--[[ L["Color Name Text"] = "Color Name Text"--]] 
L["Color Picker"] = "颜色选择器"
--[[Translation missing --]]
--[[ L["Color shown when in combat to indicate the handle is locked."] = "Color shown when in combat to indicate the handle is locked."--]] 
L["Colors"] = "颜色"
L["Column Growth"] = "列增长"
--[[Translation missing --]]
--[[ L["Column Spacing"] = "Column Spacing"--]] 
L["Columns"] = "列"
L["Columns Grow From"] = "列增长方向"
L["Combat"] = "战斗"
--[[Translation missing --]]
--[[ L["Combat Color"] = "Combat Color"--]] 
L["Combat Limitation: All groups will not update with new players that join mid-combat."] = "战斗限制: 所有分组不会更新战斗中加入的新玩家"
L["Combat Limitation: Your group will not update with new players that join mid-combat."] = "战斗限制: 你的队伍不会更新战斗中加入的新玩家"
L["Combat Mode"] = "战斗生效模式"
--[[Translation missing --]]
--[[ L["Combat Only"] = "Combat Only"--]] 
--[[Translation missing --]]
--[[ L["Compatible (%d)"] = "Compatible (%d)"--]] 
L["Compatible Bindings"] = "兼容的绑定"
--[[Translation missing --]]
--[[ L["Compatible Only"] = "Compatible Only"--]] 
L["Confirm"] = "确认"
L["Console"] = "控制台"
--[[Translation missing --]]
--[[ L["Container"] = "Container"--]] 
L["Content type filters configured in Party tab."] = "内容类型过滤器在小队标签中配置"
L["Content Types"] = "内容类型"
--[[Translation missing --]]
--[[ L["Content:"] = "Content:"--]] 
L["Controls Blizzard's debuff filtering (affects our display too)."] = "控制暴雪的减益过滤 (也影响我们的显示)"
--[[Translation missing --]]
--[[ L["Controls how multiple defensive icons are arranged when using Direct aura mode."] = "Controls how multiple defensive icons are arranged when using Direct aura mode."--]] 
--[[Translation missing --]]
--[[ L["Copied %d settings from %s to %s."] = "Copied %d settings from %s to %s."--]] 
--[[Translation missing --]]
--[[ L["Copied settings from %s to %s."] = "Copied settings from %s to %s."--]] 
L["Copies these settings from %s to %s."] = "将本栏目下的设置从 %s 复制到 %s。"
L["Copy"] = "复制"
L["Copy %s Settings"] = "复制%s设置"
--[[Translation missing --]]
--[[ L["Copy %s settings to %s?"] = "Copy %s settings to %s?"--]] 
L["Copy all settings between Party and Raid modes."] = "在小队和团队模式之间复制所有设置"
--[[Translation missing --]]
--[[ L["COPY APPEARANCE FROM"] = "COPY APPEARANCE FROM"--]] 
L["Copy Layout"] = "复制布局"
L["Copy Settings"] = "复制设置"
--[[Translation missing --]]
--[[ L["Copy Settings to %s"] = "Copy Settings to %s"--]] 
L["Copy the string below to share this wizard:"] = "复制下方配置字符串进行分享:"
--[[Translation missing --]]
--[[ L["Copy this string to share your profile:"] = "Copy this string to share your profile:"--]] 
--[[Translation missing --]]
--[[ L["Copy To"] = "Copy To"--]] 
L["Copy to Clipboard"] = "复制到剪贴板"
L["Copy to Party"] = "复制到小队"
L["Copy to Raid"] = "复制到团队"
L["Corners Only"] = "仅边角"
L["Create"] = "创建"
--[[Translation missing --]]
--[[ L["Create and manage setup wizards that guide users through configuring addon settings. Wizards can be shared with others via import/export strings."] = "Create and manage setup wizards that guide users through configuring addon settings. Wizards can be shared with others via import/export strings."--]] 
L["Create Custom Macro"] = "创建自定义宏"
L["Create Empty"] = "创建空配置"
L["Create Layout"] = "创建布局"
L["Create layouts below for different player ranges within each content type. Layouts only store settings that %sdiffer%s from your global settings — everything else is inherited automatically."] = "在不同游戏内容、不同玩家人数的情况下创建独立的布局。该布局仅存储与全局设置不同的设置——其他所有内容均自动继承。"
L["Create Macro"] = "创建宏"
L["Create New Profile"] = "创建新配置"
L["Create separate frame groups to pin specific players like tanks, healers, or key raid members. Drag players from your group roster to add them."] = "创建独立框体组以固定特定玩家如坦克、治疗或关键团队成员，从队伍花名册拖动玩家添加"
--[[Translation missing --]]
--[[ L["Created new profile: %s"] = "Created new profile: %s"--]] 
L["Crowd Control"] = "群体控制"
L["Current / Max"] = "当前 / 最大"
L["Current Health"] = "当前生命值"
L["Current Profile"] = "当前配置"
L["CURRENT STATUS"] = "当前状态"
--[[Translation missing --]]
--[[ L["Currently: Percent. Click for Seconds."] = "Currently: Percent. Click for Seconds."--]] 
--[[Translation missing --]]
--[[ L["Currently: Seconds. Click for Percent."] = "Currently: Seconds. Click for Percent."--]] 
L["Curse"] = "诅咒"
L["Cursor"] = "光标"
--[[Translation missing --]]
--[[ L["Custom"] = "Custom"--]] 
--[[Translation missing --]]
--[[ L["Custom Border"] = "Custom Border"--]] 
L["Custom buff and frame effect indicators"] = "自定义增益和框体效果指示器"
L["Custom Color"] = "自定义颜色"
L["Custom Dead Background"] = "自定义死亡背景"
L["Custom Dispel Colors"] = "自定义驱散颜色"
L["Custom Health Color"] = "自定义生命值颜色"
L["Custom Macro"] = "自定义宏"
L["Custom Sound Path"] = "自定义声音路径"
L["Custom Spell ID"] = "自定义法术 ID"
--[[Translation missing --]]
--[[ L["Customise"] = "Customise"--]] 
L["Customize class colors used throughout DandersFrames. Changes apply to health bars, name text, borders, and all other class-colored elements."] = "自定义 DandersFrames 中使用的职业颜色，更改应用于生命条、名字文本、边框和所有其他职业着色元素"
L["Customize resource bar colors per power type. Shared across party and raid frames."] = "按能量类型自定义资源条颜色，在小队和团队框体间共享"
L["Cut"] = "剪切"
--[[Translation missing --]]
--[[ L["Cycle Next CC Profile"] = "Cycle Next CC Profile"--]] 
L["Cycle Next Profile"] = "切换到下一个配置"
L["Damage"] = "伤害"
--[[Translation missing --]]
--[[ L["DandersFrames Auto-Profile Overrides:"] = "DandersFrames Auto-Profile Overrides:"--]] 
L["Darken Amount"] = "变暗程度"
L["Darken Behind Gradient"] = "渐变后方变暗"
L["Darken Effect"] = "变暗效果"
L["Dashed Border"] = "虚线边框"
L["Dead + In combat: Cast Battle Res (Rebirth, etc.)"] = "已死亡 + 战斗中：施放战复（复生等技能）"
L["Dead + Out of combat: Cast Mass Res or normal Res"] = "已死亡 + 战斗外：施放群体复活或单体复活"
L["Dead Background Color"] = "死亡背景颜色"
L["Dead/Offline Fading"] = "死亡/离线淡出"
L["Death Knight"] = "死亡骑士"
L["DEBUFF BLACKLIST"] = "减益黑名单"
L["Debuff Filters"] = "减益过滤器"
L["Debuff Icon"] = "减益图标"
--[[Translation missing --]]
--[[ L["Debuff Icons"] = "Debuff Icons"--]] 
L["Debuff Icons Click-Through"] = "减益图标点击穿透"
L["Debuff Tooltips"] = "减益鼠标提示"
L["Debuffs"] = "减益"
--[[Translation missing --]]
--[[ L["Debuffs relevant during combat in a raid context."] = "Debuffs relevant during combat in a raid context."--]] 
--[[Translation missing --]]
--[[ L["Debuffs relevant in a raid context."] = "Debuffs relevant in a raid context."--]] 
L["Debug"] = "调试"
L["Debug Console"] = "调试控制台"
--[[Translation missing --]]
--[[ L["Debug Log Export (Filtered)"] = "Debug Log Export (Filtered)"--]] 
--[[Translation missing --]]
--[[ L["Debug logging %s"] = "Debug logging %s"--]] 
--[[Translation missing --]]
--[[ L["Debug mode %s"] = "Debug mode %s"--]] 
L["Debug Mode (print to chat)"] = "调试模式 (输出到聊天)"
L["Deduplication"] = "去重"
--[[Translation missing --]]
--[[ L["Default (Slot Order)"] = "Default (Slot Order)"--]] 
L["Default Frame Level"] = "默认框体层级"
L["Default Frame Strata"] = "默认框架层级"
L["Default Icon Size"] = "默认图标大小"
L["Default Scale"] = "默认缩放"
L["Defensive buffs from other players, like Pain Suppression or Blessing of Sacrifice."] = "来自其他玩家的防御性增益，例如 痛苦压制 或 神圣牺牲。"
L["Defensive Icon"] = "防御图标"
L["Defensive Icon Alpha"] = "防御图标透明度"
L["Defensive Icon Click-Through"] = "防御图标点击穿透"
L["Defensive Icon Tooltips"] = "防御图标鼠标提示"
--[[Translation missing --]]
--[[ L["Defensives"] = "Defensives"--]] 
--[[Translation missing --]]
--[[ L["Del"] = "Del"--]] 
L["Delete"] = "删除"
L["Delete Current Profile"] = "删除当前配置"
--[[Translation missing --]]
--[[ L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = ""--]] 
L["Delete Layout"] = "删除布局"
L["Delete layout \"%s\"?"] = "删除布局 \"%s\"？"
L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = "删除宏 \"%s\"？任何使用该宏的点击施法绑定将会被移除。"
L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = "删除宏 \"%s\"？任何使用该宏的点击施法绑定将会被移除。"
L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = "删除配置 '%s'？此操作不可撤销。"
L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = "删除配置 '%s'？此操作不可撤销。"
--[[Translation missing --]]
--[[ L["Delete Step"] = "Delete Step"--]] 
--[[Translation missing --]]
--[[ L["Deleted profile: %s"] = "Deleted profile: %s"--]] 
L["Demon Hunter"] = "恶魔猎手"
--[[Translation missing --]]
--[[ L["Desaturate When Missing"] = "Desaturate When Missing"--]] 
--[[Translation missing --]]
--[[ L["Description"] = "Description"--]] 
--[[Translation missing --]]
--[[ L["Description (optional)"] = "Description (optional)"--]] 
L["Dialog"] = "对话框"
--[[Translation missing --]]
--[[ L["Direct API"] = "Direct API"--]] 
L["Direction"] = "方向"
--[[Translation missing --]]
--[[ L["Disable (set to false)"] = "Disable (set to false)"--]] 
--[[Translation missing --]]
--[[ L["Disable Buffs"] = "Disable Buffs"--]] 
L["Disable in Combat"] = "战斗中禁用"
--[[Translation missing --]]
--[[ L["Disable Overlay"] = "Disable Overlay"--]] 
--[[Translation missing --]]
--[[ L["Disable While Mounted"] = "Disable While Mounted"--]] 
L["Disable while mounted/flying"] = "骑乘/飞行时禁用"
L["Disabled"] = "已禁用"
--[[Translation missing --]]
--[[ L["disabled"] = "disabled"--]] 
L["Disease"] = "疾病"
--[[Translation missing --]]
--[[ L["Dispel Detection"] = "Dispel Detection"--]] 
L["Dispel Overlay"] = "驱散覆盖层"
L["Dispel Overlay Alpha"] = "驱散覆盖层透明度"
L["Dispel Type Colors"] = "驱散类型颜色"
L["Dispel Type Icon"] = "驱散类型图标"
L["Dispellable By Me"] = "我可驱散的"
L["Display"] = "显示"
L["Display labels above or beside each raid group."] = "在每个团队分组上方或旁边显示标签"
L["Display Mode"] = "显示模式"
L["Displays class-specific resources (Holy Power, Chi, Combo Points, Soul Shards, Arcane Charges, Essence) as colored pips on your player frame."] = "在玩家框体上以彩色资源点显示职业特有资源 (神圣能量、真气、连击点、灵魂碎片、奥术充能、精华)"
L["Done"] = "完成"
L["Don't show this warning again"] = "不再显示此警告"
L["Down"] = "下"
L["DPS"] = "DPS"
L["Drag"] = "拖拽"
L["Drag to reorder groups. Top = first."] = "拖动重新排序分组，顶部 = 第一"
L["Drag to reorder. Top = first."] = "拖动重新排序，顶部 = 第一"
--[[Translation missing --]]
--[[ L["Drop on an anchor point to move %s"] = "Drop on an anchor point to move %s"--]] 
--[[Translation missing --]]
--[[ L["Drop on an anchor point to place %s"] = "Drop on an anchor point to place %s"--]] 
L["Druid"] = "德鲁伊"
L["Dungeons"] = "地下城"
--[[Translation missing --]]
--[[ L["Duplicate"] = "Duplicate"--]] 
L["Duplicate Current"] = "复制当前配置"
--[[Translation missing --]]
--[[ L["Duplicated profile '%s' to '%s'."] = "Duplicated profile '%s' to '%s'."--]] 
L["Duration"] = "持续时间"
--[[Translation missing --]]
--[[ L["Duration & stack display"] = "Duration & stack display"--]] 
--[[Translation missing --]]
--[[ L["Duration Anchor"] = "Duration Anchor"--]] 
L["Duration Color"] = "持续时间颜色"
L["Duration Font"] = "持续时间字体"
--[[Translation missing --]]
--[[ L["Duration in seconds for the Pull Timer quick action."] = "Duration in seconds for the Pull Timer quick action."--]] 
L["Duration Offset X"] = "持续时间 X 偏移"
L["Duration Offset Y"] = "持续时间 Y 偏移"
L["Duration Outline"] = "持续时间描边"
L["Duration Position"] = "持续时间位置"
L["Duration Scale"] = "持续时间缩放"
L["Duration Text"] = "持续时间文本"
--[[Translation missing --]]
--[[ L["Duration Text Color"] = "Duration Text Color"--]] 
L["Echo to Chat"] = "输出到聊天"
L["Edge Glow (All Sides)"] = "边缘发光 (四周)"
--[[Translation missing --]]
--[[ L["Edit"] = "Edit"--]] 
L["Edit Binding"] = "编辑绑定"
L["Edit Copy"] = "编辑副本"
L["Edit Layout Range"] = "编辑布局范围"
L["Edit Macro"] = "编辑宏"
L["Edit Settings"] = "编辑设置"
--[[Translation missing --]]
--[[ L["Edit Steps"] = "Edit Steps"--]] 
--[[Translation missing --]]
--[[ L["Editing"] = "Editing"--]] 
L["Editing:"] = "编辑中:"
--[[Translation missing --]]
--[[ L["Editing: %s"] = "Editing: %s"--]] 
L["Effects"] = "视听效果"
L["Ellipsis (...)"] = "省略号 (...)"
L["Enable"] = "启用"
--[[Translation missing --]]
--[[ L["Enable (set to true)"] = "Enable (set to true)"--]] 
L["Enable AFK Icon"] = "启用暂离图标"
L["Enable Aura Designer"] = "启用光环设计器"
--[[Translation missing --]]
--[[ L["Enable Binding Tooltips"] = "Enable Binding Tooltips"--]] 
L["Enable Boss Debuffs"] = "启用首领减益"
L["Enable Buff Tooltips"] = "启用增益鼠标提示"
--[[Translation missing --]]
--[[ L["Enable Buffs"] = "Enable Buffs"--]] 
L["Enable Class Power Pips"] = "启用职业资源点"
L["Enable Custom Sorting"] = "启用自定义排序"
L["Enable Dead Fade"] = "启用死亡淡出"
L["Enable Debuff Tooltips"] = "启用减益鼠标提示"
L["Enable Debug Logging"] = "启用调试日志"
L["Enable Defensive Icon"] = "启用防御图标"
L["Enable Defensive Icon Tooltips"] = "启用防御图标鼠标提示"
L["Enable Dispel Overlay"] = "启用驱散覆盖层"
L["Enable Element-Specific Alpha"] = "启用元素特定透明度"
L["Enable Expiring Indicators"] = "启用即将过期指示器"
--[[Translation missing --]]
--[[ L["Enable Frame Border Overlay"] = "Enable Frame Border Overlay"--]] 
L["Enable Frame Tooltips"] = "启用框体鼠标提示"
L["Enable Group Labels"] = "启用分组标签"
L["Enable Heal Prediction"] = "启用治疗预测"
L["Enable Health Threshold Fade"] = "启用生命阈值淡出"
L["Enable Leader Icon"] = "启用队长图标"
L["Enable Missing Buff Icon"] = "启用缺失增益图标"
L["Enable Offscreen Nameplates"] = "启用屏幕外姓名板"
--[[Translation missing --]]
--[[ L["Enable Overlay"] = "Enable Overlay"--]] 
L["Enable Permanent Mover"] = "启用常驻移动器"
L["Enable Personal Targeted Spells"] = "启用个人目标法术"
L["Enable Pet Frames"] = "启用宠物框体"
L["Enable Phased Icon"] = "启用跨位面图标"
L["Enable Raid Auto-Switching Layouts"] = "启用团队模式自动切换布局"
L["Enable Raid Role Icon"] = "启用团队角色图标"
L["Enable Raid Target Icon"] = "启用团队标记图标"
L["Enable Ready Check Icon"] = "启用就位确认图标"
L["Enable Resource Bar"] = "启用资源条"
L["Enable Resurrection Icon"] = "启用复活图标"
L["Enable Resurrection Icon Tooltips"] = "启用复活图标鼠标提示"
L["Enable Sound Alert"] = "启用声音警告"
L["Enable Spec Auto-Switch"] = "启用专精自动切换"
L["Enable Status Text"] = "启用状态文本"
L["Enable Summon Icon"] = "启用召唤图标"
L["Enable Targeted Spells"] = "启用目标法术"
--[[Translation missing --]]
--[[ L["Enable the checkbox above to use"] = "Enable the checkbox above to use"--]] 
L["Enable Vehicle Icon"] = "启用载具图标"
--[[Translation missing --]]
--[[ L["enabled"] = "enabled"--]] 
L["Enabled"] = "启用"
L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = [=[启用: 玩家按团队分组 (1-8) 组织。
禁用: 所有玩家在一个平铺网格中。]=]
--[[Translation missing --]]
--[[ L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = ""--]] 
L["End"] = "末尾"
--[[Translation missing --]]
--[[ L["END"] = "END"--]] 
L["End (Right/Bottom)"] = "末尾 (右/下)"
L["End of Group"] = "分组末尾"
L["Energy"] = "能量"
--[[Translation missing --]]
--[[ L["Enter a layout name"] = "Enter a layout name"--]] 
L["Enter a profile name"] = "输入一个布局名称"
L["Enter a spell name above..."] = "在上方输入法术名称..."
L["Enter any spell ID for range checking. Press Enter to apply. Leave empty to use dropdown selection."] = "输入任意法术 ID 进行距离检查，按回车应用，留空使用下拉选择"
--[[Translation missing --]]
--[[ L["Enter name for copy of '%s':"] = "Enter name for copy of '%s':"--]] 
--[[Translation missing --]]
--[[ L["Enter new name for '%s':"] = "Enter new name for '%s':"--]] 
--[[Translation missing --]]
--[[ L["Enter new profile name:"] = "Enter new profile name:"--]] 
L["Enter WoW texture paths (file extensions are stripped automatically). Leave empty to use DF Icons as fallback."] = "输入 WoW 材质路径 (文件扩展名会自动去除)，留空则使用 DF 图标作为备选"
L["Errors Only"] = "仅错误"
L["Evoker"] = "唤魔师"
L["Exit Editing"] = "退出编辑"
L["Expire Alert"] = "过期警告"
L["Expiring"] = "过期提醒"
--[[Translation missing --]]
--[[ L["Expiring Alpha"] = "Expiring Alpha"--]] 
--[[Translation missing --]]
--[[ L["Expiring Alpha Override"] = "Expiring Alpha Override"--]] 
L["Expiring Color"] = "过期颜色"
L["Expiring Color Override"] = "过期时进行着色覆盖"
L["Expiring Indicator"] = "即将过期指示器"
--[[Translation missing --]]
--[[ L["Expiring indicator tracks the trigger with the least time remaining."] = "Expiring indicator tracks the trigger with the least time remaining."--]] 
--[[Translation missing --]]
--[[ L["Expiring indicator tracks the trigger with the most time remaining."] = "Expiring indicator tracks the trigger with the most time remaining."--]] 
L["Expiring Threshold (%)"] = "过期阈值 (%)"
L["Expiring Threshold (seconds)"] = "过期阈值 (秒)"
L["Export"] = "导出"
--[[Translation missing --]]
--[[ L["Export failed. Please try again or check for errors."] = "Export failed. Please try again or check for errors."--]] 
L["Export Settings"] = "导出设置"
--[[Translation missing --]]
--[[ L["Export Wizard"] = "Export Wizard"--]] 
L["External"] = "外部"
L["External Defensives"] = "外部防御技能"
L["Fade frames or elements when a unit's health is above the set threshold (e.g. 100% or 80%)."] = "当单位生命值高于设定阈值时淡出框体或元素 (例如 100% 或 80%)"
L["Fading"] = "淡出"
--[[Translation missing --]]
--[[ L["Fill Color"] = "Fill Color"--]] 
L["Fill Direction"] = "填充方向"
--[[Translation missing --]]
--[[ L["Fill Pulsate"] = "Fill Pulsate"--]] 
--[[Translation missing --]]
--[[ L["Finish"] = "Finish"--]] 
--[[Translation missing --]]
--[[ L["First question"] = "First question"--]] 
--[[Translation missing --]]
--[[ L["First Unit"] = "First Unit"--]] 
--[[Translation missing --]]
--[[ L["Fixed at 20 players (Mythic)"] = "Fixed at 20 players (Mythic)"--]] 
L["Flat Grid Settings"] = "平铺网格设置"
L["Floating Bar"] = "浮动条"
L["Floating Bar Anchor"] = "浮动条锚点"
L["Floating Bar Position"] = "浮动条位置"
L["Focus"] = "集中值"
L["Font"] = "字体"
L["Font Outline"] = "字体描边"
L["Font Settings"] = "字体设置"
L["Font settings for icons displayed as text (Summon, Res, AFK, etc.)"] = "以文本显示的图标的字体设置 (召唤、复活、暂离等)"
L["Font Size"] = "字体大小"
L["For items/macros that need @cursor, @mouseover, etc. Consumes the keybind and prevents action bar use."] = "用于需要 @cursor、@mouseover 等的物品/宏，会占用按键绑定并阻止动作条使用"
--[[Translation missing --]]
--[[ L["For nameplates & world units. %sDoes not work with action bar binds.%s"] = "For nameplates & world units. %sDoes not work with action bar binds.%s"--]] 
L["Frame"] = "框体"
L["Frame Alpha"] = "框体透明度"
L["Frame Alpha (Above Threshold)"] = "框体透明度 (高于阈值)"
L["Frame Alpha (Out of Range)"] = "框体透明度 (超出距离)"
--[[Translation missing --]]
--[[ L["Frame Border Overlay"] = "Frame Border Overlay"--]] 
L["Frame Display"] = "框体显示"
L["Frame Growth"] = "框体增长"
L["Frame Height"] = "框体高度"
L["Frame Level"] = "框体层级"
L["Frame Level Offset"] = "框体层级偏移"
L["Frame opacity when health is above the threshold."] = "生命值高于阈值时的框体透明度"
L["Frame Padding"] = "框体内边距"
L["FRAME PREVIEW"] = "框体预览"
L["Frame Scale"] = "框体缩放"
L["Frame Size"] = "框体大小"
L["Frame Spacing"] = "框体间距"
L["Frame Strata"] = "框体层级"
L["Frame Tooltips"] = "框体鼠标提示"
L["Frame Width"] = "框体宽度"
L["FRAME-LEVEL EFFECTS"] = "框体层级效果"
--[[Translation missing --]]
--[[ L["Frames centered on screen."] = "Frames centered on screen."--]] 
L["Frames Grow From"] = "框体增长方向"
L["Frames locked."] = "框体已锁定。"
L["Frames unlocked. Drag to move, right-click to lock."] = "框体已解锁。拖动可移动，右键锁定。"
L["Frames: %s"] = "框体：%s"
--[[Translation missing --]]
--[[ L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["FrameSort Integration"] = "FrameSort Integration"--]] 
L["Friendly Only"] = "仅友方目标"
L["Full Frame"] = "整个框体"
L["Fully Combat Safe: Frames will update normally during combat."] = "完全战斗安全: 框体在战斗中正常更新"
L["Fury"] = "恶魔之怒"
L["G1"] = "G1"
L["Game Default"] = "游戏默认"
L["Gap Between Pips"] = "资源点间距"
L["General"] = "常规"
--[[Translation missing --]]
--[[ L["General Import"] = "General Import"--]] 
L["Generate Export String"] = "生成配置字符串"
--[[Translation missing --]]
--[[ L["Gets its own independent border overlay. Multiple custom borders can be visible at the same time."] = "Gets its own independent border overlay. Multiple custom borders can be visible at the same time."--]] 
L["Global"] = "全局"
L["Global Font Settings"] = "全局字体设置"
L["Global Fonts"] = "全局字体"
L["Global Keybind:"] = "全局按键绑定:"
L["Glow"] = "发光"
L["Glow (ADD)"] = "发光 (ADD)"
L["Glow Alpha"] = "发光透明度"
L["Glow Color"] = "发光颜色"
L["Glow Style"] = "发光样式"
L["Go Back"] = "返回"
--[[Translation missing --]]
--[[ L["Goes to: %s"] = "Goes to: %s"--]] 
L["Gradient"] = "渐变"
L["Gradient Color Alpha"] = "渐变颜色透明度"
L["Gradient Intensity"] = "渐变强度"
L["Gradient Opacity"] = "渐变不透明度"
L["Gradient Position"] = "渐变位置"
L["Gradient Size"] = "渐变大小"
L["Grid"] = "网格"
L["Grid Layout"] = "网格布局"
--[[Translation missing --]]
--[[ L["Group"] = "Group"--]] 
L["Group 1"] = "分组 1"
L["Group Display Order"] = "分组显示顺序"
L["Group Labels"] = "分组标签"
L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = [=[平铺网格布局中不可用分组标签。

在框体设置中启用「使用分组布局」
以使用分组标签。]=]
--[[Translation missing --]]
--[[ L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = ""--]] 
L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = [=[分组标签仅适用于团队框体。

使用设置面板顶部的切换按钮
切换到团队模式以配置分组标签。]=]
--[[Translation missing --]]
--[[ L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = ""--]] 
L["Group Layout Settings"] = "分组布局设置"
--[[Translation missing --]]
--[[ L["GROUP NAME"] = "GROUP NAME"--]] 
L["Group Position"] = "分组位置"
--[[Translation missing --]]
--[[ L["Group Roster"] = "Group Roster"--]] 
L["Group Settings"] = "分组设置"
L["Group Spacing"] = "分组间距"
L["Group Visibility"] = "分组可见性"
L["Group X Offset"] = "分组 X 偏移"
L["Group Y Offset"] = "分组 Y 偏移"
L["Groups Grow From"] = "分组增长方向"
--[[Translation missing --]]
--[[ L["Groups Per Column"] = "Groups Per Column"--]] 
--[[Translation missing --]]
--[[ L["Groups Per Row"] = "Groups Per Row"--]] 
L["Growth"] = "增长"
--[[Translation missing --]]
--[[ L["GROWTH"] = "GROWTH"--]] 
L["Growth Direction"] = "增长方向"
--[[Translation missing --]]
--[[ L["GUI reset to default size, scale, and position."] = "GUI reset to default size, scale, and position."--]] 
--[[Translation missing --]]
--[[ L["Guided setup for configuring which buffs and debuffs appear on your frames."] = "Guided setup for configuring which buffs and debuffs appear on your frames."--]] 
--[[Translation missing --]]
--[[ L["Guided setup for the frame border overlay that highlights boss debuffs."] = "Guided setup for the frame border overlay that highlights boss debuffs."--]] 
--[[Translation missing --]]
--[[ L["Handle Color"] = "Handle Color"--]] 
L["Handle Height"] = "控件高度"
L["Handle is invisible until you hover over it. Fades in and out smoothly."] = "只有将鼠标悬停在控件位置时可见，且拥有平滑的淡入淡出效果。"
L["Handle Position"] = "控件位置"
L["Handle Width"] = "控件宽度"
L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = "同时启用多个点击施法插件可能会导致冲突和发生异常行为。%s请自行承担风险！%s"
L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = "同时启用多个点击施法插件可能会导致冲突和发生异常行为。%s请自行承担风险！%s"
L["Having trouble with buffs or debuffs? Run the setup wizard for guided help."] = "遇到增益或减益效果的问题？运行向导以获取帮助。"
L["Heal Absorb"] = "治疗吸收"
L["Heal Prediction"] = "治疗预测"
L["Heal Prediction Color"] = "治疗预测颜色"
L["Healer"] = "治疗"
L["Healers"] = "治疗"
L["Health"] = "生命"
L["Health Bar"] = "生命条"
L["Health Bar Alpha"] = "生命条透明度"
L["Health Bar Color"] = "生命条颜色"
L["Health Bar Texture"] = "生命条材质"
L["Health Deficit"] = "缺失生命值"
L["Health Format"] = "生命值格式"
L["Health Gradient"] = "生命值渐变"
L["Health Text"] = "生命值文本"
L["Health Text Alpha"] = "生命值文本透明度"
L["Health Text Anchor"] = "生命值文本锚点"
L["Health Text Color"] = "生命值文本颜色"
L["Health Threshold (%)"] = "生命阈值 (%)"
L["Health Threshold Fading"] = "生命阈值淡出"
L["Health X Offset"] = "生命值 X 偏移"
L["Health Y Offset"] = "生命值 Y 偏移"
L["Height"] = "高度"
L["Height / Thickness"] = "高度 / 厚度"
L["Here's what we'll set up:"] = "这将会进行设置："
L["Hidden"] = "隐藏"
L["Hide % Symbol"] = "隐藏百分比符号"
L["Hide Above (seconds)"] = "隐藏阈值 (秒)"
L["Hide Above Threshold"] = "剩余时间大于阈值时隐藏"
L["Hide Blizzard Party Frames"] = "隐藏暴雪小队框体"
L["Hide Blizzard Player Frame"] = "隐藏暴雪玩家框体"
L["Hide Blizzard Raid Frames"] = "隐藏暴雪团队框体"
--[[Translation missing --]]
--[[ L["Hide buffs from the buff bar when they are already displayed by the Defensive Bar or Aura Designer."] = "Hide buffs from the buff bar when they are already displayed by the Defensive Bar or Aura Designer."--]] 
L["Hide Cooldown Swipe"] = "隐藏冷却旋转"
L["Hide duplicate buffs"] = "隐藏重复的增益"
--[[Translation missing --]]
--[[ L["Hide Duration Above Threshold"] = "Hide Duration Above Threshold"--]] 
--[[Translation missing --]]
--[[ L["Hide Icon (Text Only)"] = "Hide Icon (Text Only)"--]] 
L["Hide in Combat"] = "战斗中隐藏"
L["Hide raid buffs from buff bar"] = "从增益栏隐藏团队增益"
L["Hide Self from Party Frames"] = "从小队框体中隐藏自己"
L["Hide specific buffs and debuffs from your frames. Click a spell to toggle blacklisting. Blacklisted auras will not appear on buff bars or Aura Designer indicators."] = "在框体中隐藏特定的增益效果和减益效果。点击一个法术可加入至黑名单。被列入黑名单的光环将不会出现在增益效果条或光环设计器的指示器中。"
--[[Translation missing --]]
--[[ L["Hide Tooltip on Mouseover"] = "Hide Tooltip on Mouseover"--]] 
L["Hides Blizzard frames but keeps them active for aura filtering."] = "隐藏暴雪框体但保持其活跃以进行光环过滤"
L["Hides the default Blizzard player portrait and health bar."] = "隐藏默认的暴雪玩家头像和生命条"
--[[Translation missing --]]
--[[ L["Hides the handle during combat. If disabled, the handle changes color to indicate it is locked."] = "Hides the handle during combat. If disabled, the handle changes color to indicate it is locked."--]] 
L["High"] = "高"
L["High Health (100%)"] = "满血 (100%)"
L["High Threat (Yellow)"] = "高仇恨 (黄色)"
L["Higher values render the bar above other elements. Frame border is at level 10."] = "数值越高，条渲染在更多元素之上，框体边框在层级 10"
L["Highest Threat (Orange)"] = "最高仇恨 (橙色)"
--[[Translation missing --]]
--[[ L["Highlight"] = "Highlight"--]] 
L["Highlight Color"] = "高亮颜色"
L["Highlight Dispellable"] = "高亮可驱散"
--[[Translation missing --]]
--[[ L["Highlight for User"] = "Highlight for User"--]] 
--[[Translation missing --]]
--[[ L["Highlight for user to configure"] = "Highlight for user to configure"--]] 
L["Highlight Important Spells"] = "高亮重要法术"
L["Highlight Settings"] = "高亮设置"
--[[Translation missing --]]
--[[ L["Highlight Settings (comma-separated dbKeys)"] = "Highlight Settings (comma-separated dbKeys)"--]] 
L["Highlight Style"] = "高亮样式"
L["Highlighted Units"] = "高亮单位"
L["Highlights"] = "高亮"
L["Highlights: %s"] = "高亮: %s"
L["Horizontal"] = "水平"
L["Horizontal anchors lay pips left-to-right. Left/Right anchors stack pips vertically along the frame side."] = "水平锚点从左到右排列资源点，左/右锚点沿框体侧面垂直堆叠资源点"
L["Horizontal Spacing"] = "水平间距"
L["Horizontal: Players stack vertically, groups grow left-to-right."] = "水平: 玩家垂直堆叠，分组从左到右增长"
L["Hostile Only"] = "仅敌方目标"
L["Hover Highlight"] = "悬停高亮"
L["Hover Settings"] = "悬停设置"
L["How it works"] = "工作原理"
L["How often to check range (seconds). Lower = more responsive but higher CPU. Default: 0.5s"] = "检查距离的频率 (秒)。越低=响应越快但 CPU 占用越高。默认: 0.5秒"
L["How would you like to configure the filters?"] = "你希望如何配置过滤器？"
--[[Translation missing --]]
--[[ L["HP"] = "HP"--]] 
L["Hunter"] = "猎人"
L["I understand, enable it"] = "我了解了，确定启用"
L["I, II, III..."] = "I, II, III..."
--[[Translation missing --]]
--[[ L["Icon"] = "Icon"--]] 
L["Icon Height"] = "图标高度"
L["Icon Offset X"] = "图标偏移 X"
L["Icon Offset Y"] = "图标偏移 Y"
L["Icon Opacity"] = "图标不透明度"
L["Icon Position"] = "图标位置"
--[[Translation missing --]]
--[[ L["Icon Ratio"] = "Icon Ratio"--]] 
L["Icon Size"] = "图标大小"
--[[Translation missing --]]
--[[ L["Icon size, scale & border"] = "Icon size, scale & border"--]] 
--[[Translation missing --]]
--[[ L["Icon Spacing"] = "Icon Spacing"--]] 
L["Icon Style"] = "图标样式"
L["Icon Width"] = "图标宽度"
L["Icons"] = "图标"
L["Icons Alpha"] = "图标透明度"
L["Icons Per Row"] = "每行图标数"
L["Ignore"] = "忽略"
L["Ignore Full Health Fade"] = "满血时忽略淡出"
L["Import"] = "导入"
L["Import All"] = "全部导入"
L["Import All (%d)"] = "全部导入 (%d)"
--[[Translation missing --]]
--[[ L["Import Buffs Tab Defaults"] = "Import Buffs Tab Defaults"--]] 
L["Import Click Casting Profile"] = "导入点击施法配置"
L["Import failed"] = "导入失败"
--[[Translation missing --]]
--[[ L["Import from Buffs Tab"] = "Import from Buffs Tab"--]] 
L["Import Selected"] = "导入所选配置项"
L["Import Settings"] = "导入设置"
L["Import String"] = "导入字符串"
--[[Translation missing --]]
--[[ L["Import Wizard"] = "Import Wizard"--]] 
L["Import WoW Macros"] = "导入魔兽宏"
--[[Translation missing --]]
--[[ L["Import your existing Buffs tab settings as defaults for all auras. Compatible settings will be applied automatically."] = "Import your existing Buffs tab settings as defaults for all auras. Compatible settings will be applied automatically."--]] 
L["Import/Export"] = "导入/导出"
L["Important Spells"] = "重要法术"
L["Important Spells Only"] = "仅重要法术"
L["Imported Profile"] = "已导入的配置"
--[[Translation missing --]]
--[[ L["Imported!"] = "Imported!"--]] 
L["In Combat Only"] = "仅战斗中"
--[[Translation missing --]]
--[[ L["In Direct mode, all active big and external defensives are shown per unit (not just one). Adjust max count and layout on the Defensive Icon page."] = "In Direct mode, all active big and external defensives are shown per unit (not just one). Adjust max count and layout on the Defensive Icon page."--]] 
L["Incompatible Bindings"] = "不兼容的绑定"
L["Indicators"] = "指示器"
--[[Translation missing --]]
--[[ L["INFERRED TRACKING"] = "INFERRED TRACKING"--]] 
L["Info (All)"] = "信息 (全部)"
--[[Translation missing --]]
--[[ L["Inherit (Frame)"] = "Inherit (Frame)"--]] 
L["Insanity"] = "狂乱值"
L["Inset"] = "内缩"
L["Inside (Bottom)"] = "内部 (底部)"
L["Inside (Top)"] = "内部 (顶部)"
L["Instanced / PvP"] = "副本 / PvP"
--[[Translation missing --]]
--[[ L["Integration"] = "Integration"--]] 
--[[Translation missing --]]
--[[ L["Integration (advanced):"] = "Integration (advanced):"--]] 
L["Integrations"] = "集成"
L["Interrupt Settings"] = "打断设置"
L["Interrupted Visual"] = "打断视觉效果"
--[[Translation missing --]]
--[[ L["is secret-tracked"] = "is secret-tracked"--]] 
L["Items"] = "物品"
--[[Translation missing --]]
--[[ L["Join a raid group (2-5 players works best)"] = "Join a raid group (2-5 players works best)"--]] 
--[[Translation missing --]]
--[[ L["Keep Buffs"] = "Keep Buffs"--]] 
L["Keep when offline/left"] = "离线/离队时保留"
L["Label Color"] = "标签颜色"
L["Label Format"] = "标签格式"
L["Label Name"] = "标签名称"
L["Label Position"] = "标签位置"
--[[Translation missing --]]
--[[ L["Label:"] = "Label:"--]] 
--[[Translation missing --]]
--[[ L["Last Unit"] = "Last Unit"--]] 
L["Layout"] = "布局"
--[[Translation missing --]]
--[[ L["Layout (Direct Mode)"] = "Layout (Direct Mode)"--]] 
L["Layout Direction"] = "布局方向"
--[[Translation missing --]]
--[[ L["Layout Group"] = "Layout Group"--]] 
L["Layout Groups"] = "布局组"
L["Layout Mode"] = "布局模式"
L["Layout Name"] = "布局名称"
--[[Translation missing --]]
--[[ L["Layout:"] = "Layout:"--]] 
L["Leader Icon"] = "队长图标"
L["Left"] = "左"
L["Left Click"] = "左键单击"
L["Left Edge"] = "左侧边缘"
L["Left of Health Bar"] = "生命条左侧"
L["Left of Owner"] = "主人左侧"
L["Left of Party"] = "小队左侧"
L["Left of Raid"] = "团队左侧"
L["Left to Right"] = "从左到右"
L["Left-click to add/edit binding"] = "左键单击以添加/修改绑定"
--[[Translation missing --]]
--[[ L["Left-click: Bind"] = "Left-click: Bind"--]] 
L["Let Masque Control Aura Borders"] = "让 Masque 控制光环边框"
L["Let me configure it myself"] = "让我自己进行配置"
L["Line"] = "线条"
--[[Translation missing --]]
--[[ L["Link: %s"] = "Link: %s"--]] 
--[[Translation missing --]]
--[[ L["Linked Settings"] = "Linked Settings"--]] 
L["List"] = "列表"
L["Loading..."] = "加载中..."
L["LOADOUT ASSIGNMENTS"] = "配装分配"
--[[Translation missing --]]
--[[ L["Loadout expects: %s"] = "Loadout expects: %s"--]] 
L["Lock"] = "锁定"
L["Lock Frames"] = "锁定框体"
L["Lock Position"] = "锁定位置"
L["Log Viewer"] = "日志查看器"
--[[Translation missing --]]
--[[ L["Loop Interval (sec)"] = "Loop Interval (sec)"--]] 
L["Low"] = "低"
L["Low Health (0%)"] = "空血 (0%)"
L["Lunar Power"] = "星界能量"
--[[Translation missing --]]
--[[ L["Macro Options:"] = "Macro Options:"--]] 
L["Macro Text:"] = "宏文本:"
L["Macros"] = "宏"
L["Mage"] = "法师"
L["Magic"] = "魔法"
L["Major defensive cooldowns like Divine Shield, Ice Block, or Barkskin."] = "主要减伤技能，比如圣盾术、寒冰屏障、树皮术。"
L["Make icons click-through for external click-casting addons. Not needed for DF built-in click-casting."] = "使图标可点击穿透以配合外部点击施法插件，DF 内置点击施法不需要"
--[[Translation missing --]]
--[[ L["Makes this binding work everywhere, consuming the keybind."] = "Makes this binding work everywhere, consuming the keybind."--]] 
L["Mana"] = "法力值"
L["Manage"] = "管理"
L["Manage Profiles"] = "管理配置"
L["Marching Ants"] = "虚线"
L["Mark of the Wild (Druid)"] = "野性印记 (德鲁伊)"
L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = [=[Masque 插件未安装。

Masque 允许你用自定义材质美化增益/减益图标。从 CurseForge 安装 Masque 以启用。]=]
--[[Translation missing --]]
--[[ L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = ""--]] 
L["Masque Integration"] = "Masque 集成"
--[[Translation missing --]]
--[[ L["Match Frame Height"] = "Match Frame Height"--]] 
--[[Translation missing --]]
--[[ L["Match Frame Width"] = "Match Frame Width"--]] 
L["Match Health Bar Width/Height"] = "匹配生命条宽度/高度"
L["Match Owner Height"] = "匹配主人高度"
L["Match Owner Width"] = "匹配主人宽度"
--[[Translation missing --]]
--[[ L["Matched (not applied)"] = "Matched (not applied)"--]] 
L["Max Buffs"] = "最大增益数"
L["Max Debuffs"] = "最大减益数"
L["Max Health"] = "最大生命值"
L["Max Icons"] = "最大图标数"
L["Max Length (0=off)"] = "最大长度 (0=关闭)"
L["Max Log Entries"] = "最大日志条目数"
L["Max Name Length"] = "最大名字长度"
--[[Translation missing --]]
--[[ L["Max Slots"] = "Max Slots"--]] 
L["Medium"] = "中"
L["Medium Health (50%)"] = "半血 (50%)"
L["Melee DPS"] = "近战DPS"
--[[Translation missing --]]
--[[ L["MEMBERS"] = "MEMBERS"--]] 
L["Min Stacks to Show"] = "显示的最小层数"
L["Minimum Log Level"] = "最低日志级别"
L["Missing Buff Alpha"] = "缺失增益透明度"
L["Missing Buffs"] = "缺失增益"
L["Missing Health"] = "已损失的生命值"
L["Missing Health Alpha"] = "缺失生命值透明度"
L["Missing Health Color"] = "缺失生命值颜色"
L["Missing Health Only"] = "仅缺失生命值"
L["Missing Health Texture"] = "缺失生命值材质"
L["Mode"] = "模式"
L["Modified"] = "已修改"
L["Monk"] = "武僧"
L["Monochrome"] = "单色"
L["Moves the glow to the opposite side (no HP side instead of max HP side)."] = "将发光移到另一侧 (无生命值侧而非满生命值侧)"
--[[Translation missing --]]
--[[ L["Multi Select"] = "Multi Select"--]] 
L["My Group First"] = "我的分组优先"
--[[Translation missing --]]
--[[ L["My Wizards"] = "My Wizards"--]] 
L["Mythic"] = "史诗难度"
--[[Translation missing --]]
--[[ L["Mythic has fixed range"] = "Mythic has fixed range"--]] 
--[[Translation missing --]]
--[[ L["Name"] = "Name"--]] 
L["Name Alpha"] = "名字透明度"
--[[Translation missing --]]
--[[ L["Name already exists"] = "Name already exists"--]] 
L["Name Anchor"] = "名字锚点"
L["Name Color"] = "名字颜色"
L["Name Text"] = "名字文本"
L["Name Text Alpha"] = "名字文本透明度"
L["Name Text Color"] = "姓名文本颜色"
L["Name X Offset"] = "名字 X 偏移"
L["Name Y Offset"] = "名字 Y 偏移"
L["Name:"] = "名称:"
L["New"] = "新建"
L["New Binding"] = "新建绑定"
--[[Translation missing --]]
--[[ L["New Feature: Frame Border Overlay"] = "New Feature: Frame Border Overlay"--]] 
--[[Translation missing --]]
--[[ L["New Option"] = "New Option"--]] 
--[[Translation missing --]]
--[[ L["New question"] = "New question"--]] 
--[[Translation missing --]]
--[[ L["Next"] = "Next"--]] 
--[[Translation missing --]]
--[[ L["No"] = "No"--]] 
--[[Translation missing --]]
--[[ L["No %s effects configured."] = "No %s effects configured."--]] 
L["No action selected"] = "未选择动作"
--[[Translation missing --]]
--[[ L["No auto-profile is currently active or being edited."] = "No auto-profile is currently active or being edited."--]] 
--[[Translation missing --]]
--[[ L["no branch"] = "no branch"--]] 
--[[Translation missing --]]
--[[ L["No built-in wizards available yet. Check back after updates!"] = "No built-in wizards available yet. Check back after updates!"--]] 
--[[Translation missing --]]
--[[ L["No changelog available."] = "No changelog available."--]] 
--[[Translation missing --]]
--[[ L["No custom wizards yet. Click 'New Wizard' to create one!"] = "No custom wizards yet. Click 'New Wizard' to create one!"--]] 
--[[Translation missing --]]
--[[ L["No data to export"] = "No data to export"--]] 
--[[Translation missing --]]
--[[ L["No default profile set"] = "No default profile set"--]] 
L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = "尚未配置任何视听效果。请点击 “+ 添加指示器” 进行配置。"
--[[Translation missing --]]
--[[ L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = ""--]] 
L["No item equipped"] = "没有装备可用物品"
--[[Translation missing --]]
--[[ L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = [=[No layout groups created yet.
Click '+ Create Group' to get started.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = ""--]] 
L["No layout set. Using global settings."] = "未创建布局，正在使用全局设置。"
L["No loadout detected"] = "未检测到配装"
L["No macros match the current filter."] = "没有宏匹配当前筛选"
L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = [=[暂无宏。
点击「+ 新建」创建或「导入」从魔兽导入。]=]
--[[Translation missing --]]
--[[ L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["No members yet"] = "No members yet"--]] 
--[[Translation missing --]]
--[[ L["No saved position to reset to."] = "No saved position to reset to."--]] 
--[[Translation missing --]]
--[[ L["No sound file selected. Choose a sound from the dropdown or enter a custom path."] = "No sound file selected. Choose a sound from the dropdown or enter a custom path."--]] 
--[[Translation missing --]]
--[[ L["No spells available for this class"] = "No spells available for this class"--]] 
L["No thanks"] = "不，谢谢"
--[[Translation missing --]]
--[[ L["No wizard selected. Go to 'My Wizards' tab to select or create a wizard first."] = "No wizard selected. Go to 'My Wizards' tab to select or create a wizard first."--]] 
L["None"] = "无"
L["None (no clamping)"] = "无 (不限制)"
L["None / Physical"] = "无 / 物理"
--[[Translation missing --]]
--[[ L["None active (using global settings)"] = "None active (using global settings)"--]] 
L["Normal (BLEND)"] = "普通 (BLEND)"
L["Not Cancelable"] = "不可取消的增益"
--[[Translation missing --]]
--[[ L["Not in a raid group"] = "Not in a raid group"--]] 
--[[Translation missing --]]
--[[ L["Not Set"] = "Not Set"--]] 
L["Note: Cmd + Left Click unavailable on Mac"] = "注意：Command + 左键单击在Mac上不可用"
L["Note: Font sizes are not changed. Adjust sizes in each element's page."] = "注意: 字体大小不会改变，请在各元素页面中调整大小"
--[[Translation missing --]]
--[[ L["Notice"] = "Notice"--]] 
L["Off"] = "关闭"
L["Offset X"] = "偏移 X"
L["Offset Y"] = "偏移 Y"
--[[Translation missing --]]
--[[ L["OK"] = "OK"--]] 
L["Only changed settings will be saved"] = "只有更改后的设置才会被保存。"
L["Only Dispellable Debuffs"] = "仅可驱散减益"
--[[Translation missing --]]
--[[ L["Only My Buffs"] = "Only My Buffs"--]] 
L["Only show buffs that you cast. Applies to all buff filters."] = "只显示你施放的增益，适用于所有增益过滤器。"
L["Only Show When Tanking"] = "仅在拉怪时显示"
--[[Translation missing --]]
--[[ L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = [=[Only the active layout can be edited
while auto layouts are running.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = ""--]] 
L["OOC"] = "战斗外"
L["Open Aura Designer"] = "打开光环设计器"
L["Open Cast History"] = "打开施法历史"
L["Open Settings"] = "打开设置页面"
--[[Translation missing --]]
--[[ L["Open Settings Tab"] = "Open Settings Tab"--]] 
L["Open the Profiles tab to manage profiles"] = "打开配置文件选项卡对配置进行管理"
L["Open Unit Menu"] = "打开单位菜单"
L["Open World"] = "开放世界"
--[[Translation missing --]]
--[[ L["Opens tab: %s"] = "Opens tab: %s"--]] 
--[[Translation missing --]]
--[[ L["Option A"] = "Option A"--]] 
--[[Translation missing --]]
--[[ L["Option B"] = "Option B"--]] 
--[[Translation missing --]]
--[[ L["Options"] = "Options"--]] 
--[[Translation missing --]]
--[[ L["Options:    [S] = Link Setting    [->] = Branch    [x] = Delete"] = "Options:    [S] = Link Setting    [->] = Branch    [x] = Delete"--]] 
L["Or enter Icon ID:"] = "或输入图标 ID:"
L["Orientation"] = "方向"
L["Other"] = "其它"
--[[Translation missing --]]
--[[ L["Other (%d)"] = "Other (%d)"--]] 
L["Other Frames"] = "其他框体"
--[[Translation missing --]]
--[[ L["Out of combat"] = "Out of combat"--]] 
L["Out of Combat Only"] = "仅非战斗时"
L["Out of Range"] = "超出距离"
L["Outline"] = "描边"
--[[Translation missing --]]
--[[ L["Overlaps with \"%s\""] = "Overlaps with \"%s\""--]] 
--[[Translation missing --]]
--[[ L["Overlaps with \"%s\" (%d-%d)"] = "Overlaps with \"%s\" (%d-%d)"--]] 
L["Overlay (on health bar)"] = "覆盖 (在生命条上)"
--[[Translation missing --]]
--[[ L["Overridden by Auto Layout"] = "Overridden by Auto Layout"--]] 
--[[Translation missing --]]
--[[ L["Overridden in this layout"] = "Overridden in this layout"--]] 
--[[Translation missing --]]
--[[ L["Override Details"] = "Override Details"--]] 
L["Owner's Class Color"] = "主人的职业颜色"
L["Paladin"] = "圣骑士"
L["Parse String"] = "解析字符串"
L["Party"] = "小队"
L["PARTY"] = "小队"
L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = "小队 & 团队的 %s 设置已进行同步。点击以停止同步。"
L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = "小队 & 团队的 %s 设置已进行同步。点击以停止同步。"
L["Party to Raid"] = "复制小队配置到团队"
--[[Translation missing --]]
--[[ L["Party: %s"] = "Party: %s"--]] 
L["Paste a profile string to import:"] = "粘贴一个配置字符串以导入:"
--[[Translation missing --]]
--[[ L["Paste the wizard export string below:"] = "Paste the wizard export string below:"--]] 
L["Pattern:"] = "模式:"
--[[Translation missing --]]
--[[ L["Per-aura overrides"] = "Per-aura overrides"--]] 
--[[Translation missing --]]
--[[ L["Percent"] = "Percent"--]] 
L["Percentage"] = "百分比"
L["Permanent Mover"] = "常驻移动器"
--[[Translation missing --]]
--[[ L["Per-setting reset is not available for Aura Designer"] = "Per-setting reset is not available for Aura Designer"--]] 
L["Persist (sec)"] = "持续 (秒)"
L["Personal Targeted"] = "个人目标"
--[[Translation missing --]]
--[[ L["Personal Targeted Spells"] = "Personal Targeted Spells"--]] 
L["Pet Frame Settings"] = "宠物框体设置"
L["Pet Frames"] = "宠物框体"
L["Pet frames are grouped together in a separate container."] = "宠物框体在独立容器中分组"
L["Pet frames are positioned relative to their owner's frame."] = "宠物框体相对于主人框体定位"
L["Pet Spacing"] = "宠物间距"
L["Phased"] = "跨位面"
L["Phased Icon"] = "跨位面图标"
--[[Translation missing --]]
--[[ L["Picked setting: %s%s%s from tab %s%s%s"] = "Picked setting: %s%s%s from tab %s%s%s"--]] 
L["Pinned Frames"] = "固定框体"
L["Pip Color"] = "资源点颜色"
L["Pip Height"] = "资源点高度"
L["Pixel-Perfect Scaling"] = "像素完美缩放"
--[[Translation missing --]]
--[[ L["Place %s at %s"] = "Place %s at %s"--]] 
--[[Translation missing --]]
--[[ L["Placed"] = "Placed"--]] 
--[[Translation missing --]]
--[[ L["PLACED ON FRAME"] = "PLACED ON FRAME"--]] 
--[[Translation missing --]]
--[[ L["PLACEMENT"] = "PLACEMENT"--]] 
L["Player Range"] = "玩家人数范围"
L["Players Grow From"] = "玩家增长方向"
--[[Translation missing --]]
--[[ L["Players Per Column"] = "Players Per Column"--]] 
--[[Translation missing --]]
--[[ L["Players Per Row"] = "Players Per Row"--]] 
--[[Translation missing --]]
--[[ L["Please enter a profile name."] = "Please enter a profile name."--]] 
L["Please select an action!"] = "请选择一个动作!"
L["Poison"] = "中毒"
L["Position"] = "位置"
--[[Translation missing --]]
--[[ L["Position & anchors"] = "Position & anchors"--]] 
--[[Translation missing --]]
--[[ L["Position managed by: %s"] = "Position managed by: %s"--]] 
--[[Translation missing --]]
--[[ L["Position reset."] = "Position reset."--]] 
L["Power Bar Alpha"] = "能量条透明度"
L["Power Word: Fortitude (Priest)"] = "真言术：韧 (牧师)"
L["Pre-configure players before they join the group"] = "在玩家加入队伍前提前添加到高亮单位名单中"
L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = [=[按任意键、鼠标按钮或滚轮
(可配合修饰键)]=]
--[[Translation missing --]]
--[[ L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = ""--]] 
L["Press Ctrl+A to select all, then Ctrl+C to copy"] = "按 Ctrl+A 全选，然后 Ctrl+C 复制"
--[[Translation missing --]]
--[[ L["Press Ctrl+C to copy, then Escape to close"] = "Press Ctrl+C to copy, then Escape to close"--]] 
L["Press key/click/scroll..."] = "按键/点击/滚轮..."
--[[Translation missing --]]
--[[ L["Preview"] = "Preview"--]] 
L["Preview Scale"] = "预览尺寸缩放"
L["Preview Sound"] = "试听"
L["Preview:"] = "预览:"
L["Priest"] = "牧师"
L["Priority"] = "优先级"
L["Priority:"] = "优先级:"
--[[Translation missing --]]
--[[ L["Private Aura Overlay Setup"] = "Private Aura Overlay Setup"--]] 
--[[Translation missing --]]
--[[ L["Profile \"%s\" has no overrides."] = "Profile \"%s\" has no overrides."--]] 
--[[Translation missing --]]
--[[ L["Profile '%s' already exists."] = "Profile '%s' already exists."--]] 
L["Profile Actions"] = "配置操作"
L["Profile imported successfully!"] = "配置导入成功！"
--[[Translation missing --]]
--[[ L["Profile matched to loadout"] = "Profile matched to loadout"--]] 
L["Profile Name"] = "配置名称"
--[[Translation missing --]]
--[[ L["Profile not found"] = "Profile not found"--]] 
L["Profile Settings"] = "点击施法配置设置"
L["Profile:"] = "配置:"
--[[Translation missing --]]
--[[ L["Profile: %s"] = "Profile: %s"--]] 
--[[Translation missing --]]
--[[ L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = ""--]] 
L["Profiles"] = "配置文件"
L["Pull Timer"] = "拉怪倒计时"
L["Pull Timer Duration"] = "拉怪倒计时时长"
--[[Translation missing --]]
--[[ L["Pulsate"] = "Pulsate"--]] 
L["Pulsate Border"] = "脉冲边框"
L["Pulse"] = "脉冲"
L["Pulse Animation"] = "脉冲动画"
--[[Translation missing --]]
--[[ L["Question"] = "Question"--]] 
--[[Translation missing --]]
--[[ L["Question:"] = "Question:"--]] 
L["Quick Bind"] = "快捷绑定"
L["Quick Bind Mode"] = "快捷绑定模式"
L["Quick Macro"] = "快捷宏"
L["Quick Macro Builder"] = "快捷宏构建器"
--[[Translation missing --]]
--[[ L["Quick Switch CC Profile"] = "Quick Switch CC Profile"--]] 
L["Quick Switch Profile"] = "快速切换DF配置"
L["Rage"] = "怒气"
L["Raid"] = "团队"
L["RAID"] = "团队"
L["Raid Auto Layouts"] = "团队模式自动布局"
L["Raid Buffs"] = "团队增益"
--[[Translation missing --]]
--[[ L["Raid Debuffs"] = "Raid Debuffs"--]] 
--[[Translation missing --]]
--[[ L["Raid frames centered."] = "Raid frames centered."--]] 
L["Raid Group Labels"] = "团队分组标签"
--[[Translation missing --]]
--[[ L["Raid In Combat"] = "Raid In Combat"--]] 
L["Raid Layout Mode"] = "团队布局模式"
--[[Translation missing --]]
--[[ L["Raid position reset."] = "Raid position reset."--]] 
L["Raid Role (MT/MA)"] = "团队角色 (MT/MA)"
L["Raid Role Icon (MT/MA)"] = "团队角色图标 (MT/MA)"
L["Raid Target Icon"] = "团队标记图标"
L["Raid to Party"] = "复制团队配置到小队"
--[[Translation missing --]]
--[[ L["Raid: %s"] = "Raid: %s"--]] 
L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = [=[团队: 分组布局在每组内排序。
平铺网格布局对所有玩家一起排序。]=]
--[[Translation missing --]]
--[[ L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = ""--]] 
L["Raids"] = "团队副本"
L["Raids, battlegrounds (1-40)"] = "团队、战场（1-40人）"
L["Range Check Interval"] = "距离检查间隔"
L["Range Check Spell"] = "距离检查法术"
L["Ranged DPS"] = "远程DPS"
L["Ready Check"] = "就位确认"
L["Ready Check Icon"] = "就位确认图标"
--[[Translation missing --]]
--[[ L["Ready to copy"] = "Ready to copy"--]] 
--[[Translation missing --]]
--[[ L["Recovered %d raid settings from interrupted auto layout editing session."] = "Recovered %d raid settings from interrupted auto layout editing session."--]] 
L["Refresh"] = "刷新"
L["Reload UI"] = "重新加载UI"
--[[Translation missing --]]
--[[ L["Remove all bindings from the current profile."] = "Remove all bindings from the current profile."--]] 
L["Remove Offline"] = "移除离线玩家"
--[[Translation missing --]]
--[[ L["Removes all Aura Designer overrides from this auto layout, restoring it to match your global profile."] = "Removes all Aura Designer overrides from this auto layout, restoring it to match your global profile."--]] 
L["Removes your player frame from the DandersFrames party display."] = "从 DandersFrames 小队显示中移除你的玩家框体"
L["Rename"] = "重命名"
--[[Translation missing --]]
--[[ L["Replace"] = "Replace"--]] 
L["Replace Blizzard's color picker with the DandersFrames color picker for this addon."] = "用 DandersFrames 颜色选择器替换暴雪的颜色选择器"
--[[Translation missing --]]
--[[ L["Replace Buffs"] = "Replace Buffs"--]] 
--[[Translation missing --]]
--[[ L["Res + Mass"] = "Res + Mass"--]] 
--[[Translation missing --]]
--[[ L["Res + Mass + Combat"] = "Res + Mass + Combat"--]] 
L["Reset"] = "重置"
L["Reset All Aura Configs"] = "重置所有光环设置"
--[[Translation missing --]]
--[[ L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = ""--]] 
L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = "确认将所有绑定重置为默认？这将会变为：左键单击 = 目标单位 • 右键单击 = 打开菜单。%s此操作不可撤销。%s"
L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = "确认将所有绑定重置为默认？这将会变为：左键单击 = 目标单位 • 右键单击 = 打开菜单。%s此操作不可撤销。%s"
L["Reset All to Default"] = "全部重置为默认"
--[[Translation missing --]]
--[[ L["Reset Aura Designer to Global"] = "Reset Aura Designer to Global"--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = ""--]] 
L["Reset Position"] = "重置位置"
L["Reset Profile to Defaults"] = "将配置重置为默认"
L["Reset to Defaults"] = "重置为默认"
L["Reset to Global"] = "重置为全局"
--[[Translation missing --]]
--[[ L["Reset to Global Order"] = "Reset to Global Order"--]] 
L["Resource Bar"] = "资源条"
L["Resource Bar Settings"] = "资源条设置"
L["Resource Colors"] = "资源颜色"
L["Rested Indicator"] = "休息状态"
L["Resurrection"] = "复活"
L["Resurrection Icon"] = "复活图标"
L["Resurrection Icon Tooltips"] = "复活图标鼠标提示"
L["Reverse Fill"] = "反向填充"
L["Reverse Fill Direction"] = "反向填充方向"
L["Reverse Order"] = "反向排序"
L["Reverse Overlay Fill"] = "反向覆盖填充"
L["Reverse Position"] = "反向位置"
L["Right"] = "右"
L["Right Click"] = "右键单击"
L["Right Edge"] = "右侧边缘"
L["Right of Health Bar"] = "生命条右侧"
L["Right of Owner"] = "主人右侧"
L["Right of Party"] = "小队右侧"
L["Right of Raid"] = "团队右侧"
L["Right to Left"] = "从右到左"
L["Right-click"] = "右键单击"
L["Right-click: Edit/View"] = "右键单击：编辑/浏览"
L["Rogue"] = "潜行者"
L["Role Icon"] = "角色图标"
L["Role Priority"] = "角色优先级"
--[[Translation missing --]]
--[[ L["Row Spacing"] = "Row Spacing"--]] 
L["Rows"] = "行"
--[[Translation missing --]]
--[[ L["Rows Grow From"] = "Rows Grow From"--]] 
--[[Translation missing --]]
--[[ L["Run"] = "Run"--]] 
--[[Translation missing --]]
--[[ L["Run Overlay Setup Wizard"] = "Run Overlay Setup Wizard"--]] 
--[[Translation missing --]]
--[[ L["Run Script"] = "Run Script"--]] 
L["Run Setup Wizard"] = "运行向导"
L["Runic Power"] = "符文能量"
--[[Translation missing --]]
--[[ L["Runtime"] = "Runtime"--]] 
L["Save"] = "保存"
L["Save & Close"] = "保存并关闭"
L["Save Changes"] = "保存更改"
L["Scale"] = "缩放"
--[[Translation missing --]]
--[[ L["Script Runner"] = "Script Runner"--]] 
L["Search fonts..."] = "搜索字体..."
L["Search sounds..."] = "搜索声音..."
L["Search spells..."] = "搜索法术..."
L["Search textures..."] = "搜索材质..."
L["Search..."] = "搜索..."
--[[Translation missing --]]
--[[ L["Seconds"] = "Seconds"--]] 
L["See Also:"] = "另见:"
--[[Translation missing --]]
--[[ L["Select a destination"] = "Select a destination"--]] 
L["Select a spell"] = "选择一个法术"
--[[Translation missing --]]
--[[ L["Select a step to edit"] = "Select a step to edit"--]] 
L["Select All Text"] = "全选文本"
L["Select any tab"] = "选择任意选项卡"
--[[Translation missing --]]
--[[ L["Select Class"] = "Select Class"--]] 
--[[Translation missing --]]
--[[ L["Select indicator..."] = "Select indicator..."--]] 
--[[Translation missing --]]
--[[ L["Select or create a wizard"] = "Select or create a wizard"--]] 
--[[Translation missing --]]
--[[ L["Select trigger for %s"] = "Select trigger for %s"--]] 
L["Select which spell to use for range checking. Auto will use your spec's default healing/friendly spell."] = "选择用于距离检查的法术，自动将使用你专精的默认治疗/友方法术"
L["Select..."] = "选择..."
L["Selected: %d"] = "已选择: %d"
L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = [=[选择一个选项将禁用其他插件
并重新加载你的界面。]=]
--[[Translation missing --]]
--[[ L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = ""--]] 
L["Selection Highlight"] = "选中高亮"
L["Selection Settings"] = "选中设置"
L["Self Position"] = "自身位置"
L["Separate Melee & Ranged DPS"] = "分离近战和远程 DPS"
L["Separate Pet Group"] = "独立宠物分组"
L["Set a font and outline style, then click Apply to update ALL text elements."] = "设置字体和描边样式，然后点击应用以更新所有文本元素"
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = ""--]] 
L["Settings"] = "设置"
--[[Translation missing --]]
--[[ L["Settings to Apply"] = "Settings to Apply"--]] 
--[[Translation missing --]]
--[[ L["Setup Wizards"] = "Setup Wizards"--]] 
L["Shadow"] = "阴影"
L["Shadow Color"] = "阴影颜色"
L["Shadow Settings"] = "阴影设置"
L["Shadow settings are controlled in General > Global Fonts."] = "阴影设置在 常规 > 全局字体 中控制"
L["Shadow X Offset"] = "阴影 X 偏移"
L["Shadow Y Offset"] = "阴影 Y 偏移"
L["Shaman"] = "萨满祭司"
--[[Translation missing --]]
--[[ L["Shared"] = "Shared"--]] 
--[[Translation missing --]]
--[[ L["Shared Border"] = "Shared Border"--]] 
L["Shift+Left Click"] = "Shift+左键单击"
L["Shift+Right Click"] = "Shift+右键单击"
L["Show a pulsing yellow glow around the frame."] = "在框体周围显示脉冲黄色发光"
L["Show All Roles Out of Combat"] = "非战斗时显示所有角色"
L["Show as Text"] = "显示为文本"
L["Show Background"] = "显示背景"
L["Show Border"] = "显示边框"
L["Show Buffs"] = "显示增益"
L["Show Cooldown Swipe"] = "显示冷却旋转"
L["Show Debuffs"] = "显示减益"
L["Show Dispel Icon"] = "显示驱散图标"
L["Show DPS"] = "显示 DPS"
L["Show Duration"] = "显示持续时间"
L["Show Duration Numbers"] = "显示持续时间数字"
L["Show Duration Text"] = "显示持续时间文本"
L["Show every buff with no filtering."] = "显示所有未经过滤的增益。"
L["Show every debuff with no filtering."] = "显示所有未经过滤的减益。"
L["Show Expiring Border"] = "显示即将过期边框"
L["Show Expiring Tint"] = "显示即将过期着色"
L["Show for Roles"] = "按角色显示"
L["Show Frame Border"] = "显示框体边框"
L["Show Gradient"] = "显示渐变"
L["Show Group Label"] = "显示分组标签"
L["Show Healer"] = "显示治疗"
L["Show health bars for player and party/raid member pets, anchored to their owner's frame. Pet frames hide when owner dies."] = "显示玩家和队员宠物的生命条，锚定到主人框体，主人死亡时宠物框体隐藏"
L["Show Health Percentage"] = "显示生命值百分比"
L["Show in content types:"] = "在内容类型中显示:"
L["Show in Solo Mode"] = "在单人模式中显示"
L["Show Interrupted Visual"] = "显示打断视觉效果"
L["Show Label"] = "显示标签"
L["Show LFG Eye for Cross-Instance"] = "显示跨副本的随机队伍图标"
L["Show Main Assist"] = "显示主助攻"
L["Show Main Tank"] = "显示主坦克"
L["Show Minimap Button"] = "显示小地图按钮"
L["Show On Current Health Only"] = "仅在当前生命值上显示"
L["Show on Hover Only"] = "仅悬停时显示"
L["Show Overheal"] = "显示过量治疗"
L["Show Overlay For"] = "显示覆盖层"
L["Show Overshield Glow"] = "显示超量护盾发光"
L["Show Party/Raid Side Menu"] = "显示小队/团队侧边菜单"
L["Show rested indicators when in a rested area (inn, city)."] = "在休息区域 (旅馆、城市) 时显示休息状态"
L["Show Shadow"] = "显示阴影"
--[[Translation missing --]]
--[[ L["Show Stacks"] = "Show Stacks"--]] 
L["Show Tank"] = "显示坦克"
L["Show the animated ZZZ icon on the player frame."] = "在玩家框体上显示动画 ZZZ 图标"
L["Show the DF color picker when any addon opens a color picker."] = "当任何插件打开颜色选择器时显示 DF 颜色选择器"
L["Show Timer"] = "显示计时器"
--[[Translation missing --]]
--[[ L["Show When Missing"] = "Show When Missing"--]] 
L["Show X Mark"] = "显示 X 标记"
L["Show:"] = "显示:"
--[[Translation missing --]]
--[[ L["Shows a border ring around the entire frame when a boss debuff is active."] = "Shows a border ring around the entire frame when a boss debuff is active."--]] 
L["Shows a colored border/glow when a dispellable debuff is present."] = "当存在可驱散减益时显示彩色边框/发光"
L["Shows a glow at max health when absorb exceeds the clamp limit."] = "当吸收超过限制值时在满血处显示发光效果"
L["Shows an icon when an enemy is casting a spell targeting a party/raid member."] = "当敌人对小队/团队成员施法时显示图标"
L["Shows an icon when party members have a defensive cooldown active (Pain Suppression, Ironbark, etc.)."] = "当队员有防御冷却技能激活时显示图标 (痛苦压制、铁木树皮等)"
L["Shows effects that reduce incoming healing (like Necrotic stacks)."] = "显示减少治疗效果 (如死疽层数)"
L["Shows icon when party members are missing raid buffs."] = "当队员缺少团队增益时显示图标"
L["Shows incoming targeted spells on YOU in the center of your screen."] = "在屏幕中央显示针对你的目标法术"
L["Shows the ping wheel & party management menu."] = "显示标记轮盘和队伍管理菜单"
--[[Translation missing --]]
--[[ L["Single Select"] = "Single Select"--]] 
L["Size"] = "大小"
--[[Translation missing --]]
--[[ L["Size & Orientation"] = "Size & Orientation"--]] 
L["Size & Spacing"] = "大小与间距"
--[[Translation missing --]]
--[[ L["Skip for now"] = "Skip for now"--]] 
L["Skyfury (Shaman)"] = "天怒图腾 (萨满)"
L["Smart Res:"] = "智能复活:"
L["Smart Resurrection"] = "智能复活"
L["Smooth Bar Animation"] = "平滑条动画"
L["Snaps sizes and borders to exact pixels for crisp rendering."] = "将大小和边框对齐到精确像素以获得清晰渲染"
L["Solid (BLEND)"] = "实色 (BLEND)"
L["Solid Border"] = "实线边框"
L["Solo Mode"] = "单人模式"
--[[Translation missing --]]
--[[ L["Solo mode %s"] = "Solo mode %s"--]] 
L["Solo Mode: Show your player frame when not in a group."] = "单人模式: 不在队伍中时显示你的玩家框体"
L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = [=[部分绑定使用了你当前职业
或专精不可用的法术。]=]
--[[Translation missing --]]
--[[ L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = ""--]] 
L["Sort by Class (within role)"] = "按职业排序 (角色内)"
L["Sort Order"] = "排序方式"
L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = [=[按角色、职业和名字排序队员。

排序顺序: 自身位置 > 角色 > 职业 > 名字]=]
--[[Translation missing --]]
--[[ L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = ""--]] 
L["Sorted with Group"] = "随队伍排序"
L["Sorting"] = "排序"
L["Sound"] = "声音"
L["Sound Alert"] = "声音警告"
L["Sound Alerts"] = "声音警告"
--[[Translation missing --]]
--[[ L["Sound file could not be played: %s"] = "Sound file could not be played: %s"--]] 
L["Source Mode"] = "数据源"
L["Spacing"] = "间距"
L["Spacing X"] = "间距 X"
L["Spacing Y"] = "间距 Y"
L["Spark"] = "火花"
L["Spec Default"] = "专精默认"
L["Spec:"] = "专精:"
L["Specialization data not available."] = "专精数据不可用"
L["Spell:"] = "法术:"
L["Spells"] = "法术"
--[[Translation missing --]]
--[[ L["Spells flagged as important by Blizzard."] = "Spells flagged as important by Blizzard."--]] 
--[[Translation missing --]]
--[[ L["Square"] = "Square"--]] 
--[[Translation missing --]]
--[[ L["Stack Anchor"] = "Stack Anchor"--]] 
L["Stack Count"] = "层数"
--[[Translation missing --]]
--[[ L["Stack Font"] = "Stack Font"--]] 
--[[Translation missing --]]
--[[ L["Stack Minimum"] = "Stack Minimum"--]] 
--[[Translation missing --]]
--[[ L["Stack Offset X"] = "Stack Offset X"--]] 
--[[Translation missing --]]
--[[ L["Stack Offset Y"] = "Stack Offset Y"--]] 
--[[Translation missing --]]
--[[ L["Stack Outline"] = "Stack Outline"--]] 
--[[Translation missing --]]
--[[ L["Stack Scale"] = "Stack Scale"--]] 
--[[Translation missing --]]
--[[ L["Stack Text"] = "Stack Text"--]] 
--[[Translation missing --]]
--[[ L["Stack Text Color"] = "Stack Text Color"--]] 
--[[Translation missing --]]
--[[ L["Standard Buffs are also visible on frames."] = "Standard Buffs are also visible on frames."--]] 
--[[Translation missing --]]
--[[ L["START"] = "START"--]] 
L["Start"] = "起始"
L["Start (Left/Top)"] = "起始 (左/上)"
L["Start = Left/Top, End = Right/Bottom depending on direction."] = "起始 = 左/上，末尾 = 右/下，取决于方向"
--[[Translation missing --]]
--[[ L["Start Delay (sec)"] = "Start Delay (sec)"--]] 
L["Start of Group"] = "分组起始"
L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = [=[起始: 分组上方/左侧。
居中: 分组中间。
末尾: 分组下方/右侧。]=]
--[[Translation missing --]]
--[[ L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = ""--]] 
L["Status Icon Text Settings"] = "状态图标文本设置"
L["Status Text"] = "状态文本"
L["Status Text (Dead/Offline)"] = "状态文本 (死亡/离线)"
L["Status Text Alpha"] = "状态文本透明度"
--[[Translation missing --]]
--[[ L["Step %d of %d"] = "Step %d of %d"--]] 
L["Step 1: Click here with desired key combo"] = "步骤 1: 用所需按键组合点击此处"
L["Step 2: Select Action"] = "步骤 2: 选择动作"
L["Step 3: Combat Condition (optional)"] = "步骤 3: 战斗条件 (可选)"
--[[Translation missing --]]
--[[ L["Step Editor"] = "Step Editor"--]] 
--[[Translation missing --]]
--[[ L["Step ID"] = "Step ID"--]] 
--[[Translation missing --]]
--[[ L["Steps"] = "Steps"--]] 
--[[Translation missing --]]
--[[ L["Style"] = "Style"--]] 
--[[Translation missing --]]
--[[ L["Summary"] = "Summary"--]] 
--[[Translation missing --]]
--[[ L["Summary Step"] = "Summary Step"--]] 
L["Summon"] = "召唤"
L["Summon Icon"] = "召唤图标"
--[[Translation missing --]]
--[[ L["Switched to profile: %s"] = "Switched to profile: %s"--]] 
--[[Translation missing --]]
--[[ L["Sync"] = "Sync"--]] 
--[[Translation missing --]]
--[[ L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = ""--]] 
L["Sync from WoW"] = "从魔兽同步"
L["Sync with %s"] = "与 %s 同步"
L["Sync: %s"] = "同步：%s"
--[[Translation missing --]]
--[[ L["Synced with %s"] = "Synced with %s"--]] 
--[[Translation missing --]]
--[[ L["Synced: %s"] = "Synced: %s"--]] 
L["Tank"] = "坦克"
L["Tanking (Red)"] = "正在拉怪 (红色)"
L["Tanks"] = "坦克"
L["Target Type:"] = "目标类型:"
L["Target Unit"] = "目标单位"
L["Targeted Spell Alpha"] = "目标法术透明度"
L["Targeted Spell Click-Through"] = "目标法术点击穿透"
L["Targeted Spells"] = "目标法术"
--[[Translation missing --]]
--[[ L["Targeted Spells (on frames)"] = "Targeted Spells (on frames)"--]] 
L["Targeting Fallback:"] = "备选目标:"
L["Targeting: %s"] = "目标：%s"
L["Test"] = "测试"
L["Test Mode"] = "测试模式"
--[[Translation missing --]]
--[[ L["Test mode disabled."] = "Test mode disabled."--]] 
--[[Translation missing --]]
--[[ L["Test mode enabled."] = "Test mode enabled."--]] 
--[[Translation missing --]]
--[[ L["Test mode ended — entering combat."] = "Test mode ended — entering combat."--]] 
--[[Translation missing --]]
--[[ L["Test Mode: %s"] = "Test Mode: %s"--]] 
L["Text"] = "文本"
L["Text Color"] = "文本颜色"
L["Text Colors:"] = "文本颜色:"
L["Text Format"] = "文本格式"
L["Text Scale"] = "文本缩放"
L["Texture"] = "材质"
L["Texture & Colors"] = "材质&颜色"
--[[Translation missing --]]
--[[ L["The first image shows the overlay border active on a frame. The second shows the standard boss debuff icon only."] = "The first image shows the overlay border active on a frame. The second shows the standard boss debuff icon only."--]] 
--[[Translation missing --]]
--[[ L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = ""--]] 
L["These settings apply when using 'Shadow' outline style. Use larger offsets for more dramatic shadows."] = "这些设置在使用「阴影」描边样式时生效，使用更大的偏移获得更明显的阴影"
L["Thick Outline"] = "粗描边"
L["Thickness"] = "厚度"
--[[Translation missing --]]
--[[ L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["this option"] = "this option"--]] 
--[[Translation missing --]]
--[[ L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["This setting differs from the global profile value. Click the reset button to revert."] = "This setting differs from the global profile value. Click the reset button to revert."--]] 
--[[Translation missing --]]
--[[ L["This setting is being overridden by the active auto layout profile. To change it, edit the profile in the Auto Layouts tab."] = "This setting is being overridden by the active auto layout profile. To change it, edit the profile in the Auto Layouts tab."--]] 
--[[Translation missing --]]
--[[ L["This step automatically shows a review of all the user's answers. It's always the last step."] = "This step automatically shows a review of all the user's answers. It's always the last step."--]] 
L["This warning will not appear again after confirming."] = "确认后此警告将不再出现"
L["Threat Colors"] = "仇恨颜色"
--[[Translation missing --]]
--[[ L["Threshold Mode"] = "Threshold Mode"--]] 
--[[Translation missing --]]
--[[ L["Time Remaining"] = "Time Remaining"--]] 
L["Timing"] = "时序"
--[[Translation missing --]]
--[[ L["Tint"] = "Tint"--]] 
L["Tint Color"] = "着色颜色"
L["Tint Opacity"] = "着色不透明度"
L[ [=[to customise
this profile's settings]=] ] = "可自定义该布局下的设置"
L[ [=[to customise
this profile's settings]=] ] = "可自定义该布局下的设置"
--[[Translation missing --]]
--[[ L["To fix the ElvUI compatibility issue:"] = "To fix the ElvUI compatibility issue:"--]] 
L["To reposition: Unlock frames (/df unlock) and drag the mover."] = "重新定位: 解锁框体 (/df unlock) 并拖动定位器。"
L["Toggle Solo Mode"] = "单人模式开关"
L["Toggle Test Mode"] = "测试模式开关"
L["Tooltips"] = "鼠标提示"
L["Top"] = "顶部"
L["Top Edge"] = "顶部边缘"
L["Top Left"] = "左上"
L["Top Right"] = "右上"
L["Top to Bottom"] = "从上到下"
--[[Translation missing --]]
--[[ L["Total:"] = "Total:"--]] 
--[[Translation missing --]]
--[[ L["Track Highest Duration"] = "Track Highest Duration"--]] 
--[[Translation missing --]]
--[[ L["Track Lowest Duration"] = "Track Lowest Duration"--]] 
L["Trigger"] = "触发器"
L["Trigger Mode"] = "触发模式"
--[[Translation missing --]]
--[[ L["TRIGGERED BY"] = "TRIGGERED BY"--]] 
L["Truncate Mode"] = "截断模式"
L["Truncation"] = "截断"
--[[Translation missing --]]
--[[ L["Type"] = "Type"--]] 
--[[Translation missing --]]
--[[ L["Type /dfarena again to disable"] = "Type /dfarena again to disable"--]] 
--[[Translation missing --]]
--[[ L["Type:"] = "Type:"--]] 
L["UI Scale:"] = "UI缩放"
L["Unit Frame"] = "单位框体"
L["Unit Frame Sorting"] = "单位框体排序"
L["Unit Selection"] = "单位选择"
L["Units at or above this health percent are faded."] = "生命值达到或超过此百分比的单位将被淡出"
L["Units Per Row"] = "每行单位数"
L["Unknown"] = "未知"
L["Unknown error"] = "未知错误"
L["Unlock"] = "解锁"
L["Unlock Frames"] = "解锁框体"
L["Unnamed"] = "未命名"
L["Up"] = "上"
L["Use"] = "使用"
L["USE"] = "使用"
--[[Translation missing --]]
--[[ L["Use %s"] = "Use %s"--]] 
--[[Translation missing --]]
--[[ L["Use /df overrides for full details in chat"] = "Use /df overrides for full details in chat"--]] 
L["Use Class Color"] = "使用职业颜色"
--[[Translation missing --]]
--[[ L["Use Current (%s)"] = "Use Current (%s)"--]] 
--[[Translation missing --]]
--[[ L["Use Current Value"] = "Use Current Value"--]] 
L["Use Custom Colors"] = "使用自定义颜色"
L["Use Custom Pip Color"] = "使用自定义资源点颜色"
L["Use DandersFrames"] = "使用 DandersFrames"
L["Use DF Color Picker"] = "使用 DF 颜色选择器"
L["Use DF Color Picker for All Addons"] = "为所有插件使用 DF 颜色选择器"
--[[Translation missing --]]
--[[ L["Use FrameSort Addon"] = "Use FrameSort Addon"--]] 
L["Use Group-Based Layout"] = "使用分组布局"
--[[Translation missing --]]
--[[ L["Use recommended defaults"] = "Use recommended defaults"--]] 
L["Use Seconds Instead of Percent"] = "使用 秒 而不是 百分比"
--[[Translation missing --]]
--[[ L["Uses a single border per frame. Highest priority wins."] = "Uses a single border per frame. Highest priority wins."--]] 
--[[Translation missing --]]
--[[ L["Uses cast tracking to identify spells WoW marks as secret. Only tracks your own casts."] = "Uses cast tracking to identify spells WoW marks as secret. Only tracks your own casts."--]] 
--[[Translation missing --]]
--[[ L["Uses party frame settings/position"] = "Uses party frame settings/position"--]] 
--[[Translation missing --]]
--[[ L["Using highest duration trigger"] = "Using highest duration trigger"--]] 
--[[Translation missing --]]
--[[ L["Using lowest duration trigger"] = "Using lowest duration trigger"--]] 
--[[Translation missing --]]
--[[ L["Using spec default"] = "Using spec default"--]] 
--[[Translation missing --]]
--[[ L["v%s loaded. Type %s/df%s for settings, %s/df resetgui%s if window is offscreen."] = "v%s loaded. Type %s/df%s for settings, %s/df resetgui%s if window is offscreen."--]] 
L["Valid range"] = "有效距离"
--[[Translation missing --]]
--[[ L["Value:"] = "Value:"--]] 
L["Vehicle"] = "载具"
L["Vehicle Icon"] = "载具图标"
L["Vertical"] = "垂直"
L["Vertical Spacing"] = "垂直间距"
L["View Imported Macro"] = "查看导入的宏"
L["Visibility"] = "可见性"
L["Volume"] = "音量"
L["Warlock"] = "术士"
L["Warnings + Errors"] = "警告 + 错误"
L["Warrior"] = "战士"
L["Weight"] = "权重"
--[[Translation missing --]]
--[[ L["What should '%s' do with this setting?"] = "What should '%s' do with this setting?"--]] 
--[[Translation missing --]]
--[[ L["When \"%s\" selected:"] = "When \"%s\" selected:"--]] 
L["When auto-detect is OFF, select which raid buffs to monitor manually."] = "关闭自动检测时，手动选择要监控的团队增益"
L["When disabled: Click spell to open Binding Editor."] = "禁用后，点击法术选项卡中的任意法术后打开绑定编辑器。"
--[[Translation missing --]]
--[[ L["When enabled, a new profile will be automatically"] = "When enabled, a new profile will be automatically"--]] 
L["When enabled, all pips use a single custom color instead of the class-specific default."] = "启用后，所有资源点使用单一自定义颜色而非职业特定默认颜色"
L["When enabled, all role icons are shown outside of combat. The filters below only apply during combat."] = "启用后，所有角色图标在非战斗时显示，以下过滤器仅在战斗中生效"
--[[Translation missing --]]
--[[ L["When enabled, click-casting bindings will be"] = "When enabled, click-casting bindings will be"--]] 
L["When enabled, Masque skins aura icons and borders. DF border settings will be disabled."] = "启用后，Masque 美化光环图标和边框，DF 边框设置将被禁用"
L["When enabled, shows incoming heals even if they would overheal."] = "启用后，即使会过量治疗也会显示即将到来的治疗"
L["When enabled, the group you are in will always be displayed first."] = "启用后，你所在的分组将始终优先显示"
L["When enabled: Click spell, press key to bind instantly."] = "启用后，点击法术选项卡中的任意法术后按下任意键可直接绑定。"
L["When you enter matching content, the layout's overrides are applied on top of your global settings. If no layout matches, global settings are used as-is."] = "当你游玩相匹配的内容时，该内容下的布局的自定义设置会覆盖你全局设置。如果没有匹配的布局，则会直接使用全局设置。"
L["Which aura data source would you like to use?"] = "你想使用哪种光环数据源？"
--[[Translation missing --]]
--[[ L["While editing, each setting shows its override status:"] = "While editing, each setting shows its override status:"--]] 
--[[Translation missing --]]
--[[ L["Whitelist buffs take priority for the expiring indicator."] = "Whitelist buffs take priority for the expiring indicator."--]] 
L["WHITELISTED"] = "白名单"
--[[Translation missing --]]
--[[ L["Whole Alpha Pulse"] = "Whole Alpha Pulse"--]] 
L["Width"] = "宽度"
L["Width / Length"] = "宽度 / 长度"
--[[Translation missing --]]
--[[ L["Will auto-create on switch"] = "Will auto-create on switch"--]] 
--[[Translation missing --]]
--[[ L["Will replace existing Mythic layout"] = "Will replace existing Mythic layout"--]] 
--[[Translation missing --]]
--[[ L["Wizard"] = "Wizard"--]] 
--[[Translation missing --]]
--[[ L["Wizard '%s' saved!"] = "Wizard '%s' saved!"--]] 
--[[Translation missing --]]
--[[ L["Wizard Builder"] = "Wizard Builder"--]] 
--[[Translation missing --]]
--[[ L["Wizard Details"] = "Wizard Details"--]] 
--[[Translation missing --]]
--[[ L["Wizard Name:"] = "Wizard Name:"--]] 
L["Works when hovering frames. Action bars work when not hovering."] = "悬停框体时生效，未悬停时动作条正常工作"
L["World bosses, outdoor raids (1-40)"] = "世界首领、野外团队（1-40人）"
L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = "你是想保留原有的增益图标并与 Aura Designer 同时使用，还是让 Aura Designer 完全取代它们？"
L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = "你想保留标准增益图标并与 Aura Designer 一起显示，还是让 Aura Designer 完全替代它们？"
L["Would you like to set up your aura filters?"] = "是否要设置光环过滤规则？"
L["X Color"] = "X 颜色"
L["X Mark"] = "X 标记"
L["X Size"] = "X 大小"
L["Yellow=high, Orange=highest, Red=tanking."] = "黄色=高仇恨，橙色=最高仇恨，红色=正在拉怪"
L["Yes"] = "是"
L["Yes, set it up"] = "是，开始设置"
L["YOUR PROFILES"] = "你的配置"
L["Z to A"] = "Z 到 A"

