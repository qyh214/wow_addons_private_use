-- [[ ExwindTools Metadata ]]
-- 此文件由打包脚本自动生成或修改，用于控制版本号。
-- 请勿手动通过 Git 提交修改此文件中的版本号，除非你是为了测试。

ExwindTools_MetaData = {
    version = "v26.4.29.0827",
    gridEngineVersion = "2.0",
    changelog = {
        title = "v26.4.27.1103 更新日志",
        publishedAt = "2026-04-27 11:03",
        fontSize = 14,
        content = [[
@H1@ v26.4.27.1103

@H2@ 噬灭变身持续时间监控
- 功能为 @叶落初冬 提供的想法 并经过几天测试已经正常

后续会把所有这种功能整合到一个类似简易版本WA的插件 目前属于过渡期暂时放工具箱内

@H1@ v26.4.23.1800

@H2@ 版本更新
- 大多API已更新到12.0.5版本

@H1@ ExwindCore

@H2@ 事件分发系统
- 从ExwindTool.lua拆分 明确引擎职责

@H2@ 状态管理系统
- 因玩家属性在12.0.5被加密 移除了差值回调模块(含阈值检测)
- 已知问题: 全能是由两个数值相加的 由于当前秘密值无法运算 暂时只能显示两个数字
- 已知问题: 移动速度无法运算 本那会显示原始数值
(PS:截止插件发布当下 市面上其他属性监控插件都是这样 请注意 "属性加密"是进入大秘境后才生效
因此可能会看到别的属性插件在副本外显示正常 经过我们测试大多插了钥石后就开始疯狂报错)

@H1@ ExwindTools

@H2@ 嗜血监控
- 从差值回调触发改为监控DEBUFF触发

@H2@ 队友打断监控
- 由于暴雪针对性封杀 目前服务器完全不下发相关事件 因此目前无法生效
- 我们已经计划至做一个临时平替版本 仍然能监控 但是时间得自己预估 将在这两天发布

@H2@ 焦点施法/周围怪物施法监控
- 更新到12.0.5版本 解决大多报错问题
- 新增进战缓存0.1秒后复查逻辑 已解决某些时后服务器下发事件和API不同步 导致第一个读条不显示问题
- (12.0.5新增) 更新显示数字 现在低于10秒显示小数点 某些特别长时间会显示"7天"这种

- -

@H1@ English Version

@H2@ Version Update
- Most APIs have been updated for 12.0.5.

@H1@ ExwindCore

@H2@ Event Dispatch System
- Split out from ExwindTool.lua to make engine responsibilities clearer.

@H2@ State Management System
- Because player attributes are now protected in 12.0.5, the delta callback module (including threshold checks) has been removed.
- Known issue: Versatility is made from two values added together. Since secret values cannot currently be calculated, it can only be shown as two separate numbers for now.
- Known issue: Movement speed can no longer be calculated, so the original raw value is displayed for now.

(PS: At the time of this release, most other attribute-monitoring addons on the market behave the same way. Please note that attribute protection only takes effect after entering Mythic+. Because of that, some other stat addons may still look normal outside dungeons, but in our testing many of them start throwing errors after a keystone is inserted.)

@H1@ ExwindTools

@H2@ Bloodlust Monitor
- Changed from delta-callback triggering to debuff-based monitoring.

@H2@ Party Interrupt Tracker
- Because Blizzard specifically restricted this behavior, the server no longer sends the required events, so it is currently non-functional.
- We already plan to provide a temporary fallback version that can still track it, but the timing will need to be estimated manually. This is planned for release within the next couple of days.

@H2@ Focus Cast / Nearby Enemy Cast Monitor
- Updated for 12.0.5 and fixed most error issues.
- Added a 0.1-second in-combat recheck cache to solve cases where the server event order and API state are temporarily out of sync, causing the first cast bar not to appear.
- (New in 12.0.5) Updated number display: durations below 10 seconds now show decimals, and some extremely long durations may display as values like "7 days".

@H1@ v26.4.18.1328

@H2@ 重大更新
- EXBOSS现已支持小怪内置CD+语音提示 可在各大平台搜索EXBOSS下载
- EXBOSS与ExwindTools共用底层引擎 减少重复的数据开销 提升性能!

@H2@ 公告
- 过去几周内 ExwindTools遭到暴雪的深入 很多功能将在12.0.5出现一定的波动
我们预计会在12.0.5上线当天先把大多数引发打本的功能修复或是禁用 并在后续尽力还原

以下是暴雪新的限制在12.0.5会失效 或是暂时失效需要修改的

ExwindTools

1.属性监控 80%没问题 但是由于全能的百分比是两个API相加的 可能会受到一点影响
2.State系统 差值回调技术失效 整套将会移除 这个影响不大(原本要用来做被动饰品监控 太忙了一直没做)
3.打断模块会先禁用 并且在上线后可能会先有临时替代方案 (具体得等上线后测试)

ExBoss
1.部份小怪内置CD需要进入二层引擎判断 (需要该怪物进入战斗后施放一个技能才能视别)

我们不排除暴雪会在12.0.5继续针对小怪内置CD进行更加一步的封锁 而我们也尝试与暴雪方面进行沟通建议
这套系统在开发的时后就有一些预案 总而言之一直都可用 暴雪后续动作只会降低精度 不会完全失效

@H2@ 没有位移技能
- 新增DH 骑士 小龙人

@H2@ 酒仙酒池监控
- 修改文本层级
- 新增坐骑上隐藏选项

@H2@ 赞助方案
- 在首页加入小额赞助连接 与大多正规插件遵循的赞助规则一致 不主动刷屏赞助广告

- 并在这里承诺 ExwindTools和ExBoss两款插件是免费项目 不会收费 也不会有什么订阅高级版本
所有人不管是否赞助使用的版本永远相同 功能也永远相同 不搞擦边 不把玩家当傻子对待

@H2@ 开发计划
- 目前EXBOSS基本进入稳定 接下来开发计划会补全很多BOSS的提示(易伤 转阶段 破盾等等)
或是尽力制作类似于执政团2号BOSS 狗点名预测这种小功能模块

- 小怪内置CD会等到12.0.5上线大多问题修复后 视当下情况尽力增加必要的技能
- ExwindTools会在12.0.5上线大多问题修复后 预计推出5-6个新的功能模块
(微型选单 团队标记 大米进组后传送提示 以及一些正在开发但保密的功能)

@H1@ v26.4.5.2019

@H2@ 公告
- 我们将在一周后陆续支持更完善的enUS以及其他语系翻译
目前计划将会做一个locale的Github仓库来维护 更详细的方案会在一周后公告
(请原谅我这一周需要赶工EXBOSS项目)

@H2@ Announcement
- We will begin rolling out more complete enUS and additional locale support over the next week.
- The current plan is to maintain translations in a dedicated locale GitHub repository. A more detailed plan will be announced in about a week.
- Please excuse the delay, as I need to focus on the EXBOSS project this week.

@H2@ [新功能]副本笔记
- 默认关闭
- 可以添加副本一些文本笔记以及某些BOSS的笔记 会在对应副本或是对应首领战出现

@H2@ [New Feature] Instance Notes
- Disabled by default.
- You can add text notes for dungeons and specific bosses, and they will appear in the corresponding dungeon or boss encounter.

@H2@ [新功能]自动对话
- 默认开启
- 新做可能数据还不是很完善 会逐渐加入副本内一些自动对话的选项
- 插件会在游戏中所有对话选项右边增加一个绿色的+号 点击可以加入自动对话选项
- 欢迎把缺少并且因该加入的选项反馈给我

@H2@ [New Feature] Auto Dialogue
- Enabled by default.
- This feature is still new, so the preset data is not yet complete. More in-instance dialogue options will be added over time.
- The addon now adds a green + button to the right of all in-game dialogue options. Clicking it adds that option to the auto dialogue list.
- Feedback is welcome for any missing options that should be included.

@H2@ 大秘境伤害模拟
- 重新校准了数值倍率
- 现在正确的区分了小怪和BOSS伤害倍率
- 经WCL二次和对 目前精度已达99.99%

@H2@ Mythic+ Damage Simulation
- Recalibrated the value multipliers.
- It now correctly distinguishes between trash mob and boss damage multipliers.
- After a second verification pass against WCL, the current accuracy is 99.99%.

@H2@ PVE面板 (大秘境分数页面右边的面板)
- 新增了检测Raid.io面板逻辑 现在检测到io面板时会挂载到其右侧

@H2@ PVE Panel (the panel on the right side of the Mythic+ score page)
- Added detection for the Raider.IO panel. When the Raider.IO panel is present, this panel now anchors to its right side.

@H2@ 大秘境分数统计面板(从PVE面板开启带称号那个)
- 修正了中国区域玩家总人口数的计算逻辑

@H2@ Mythic+ Score Statistics Panel (the title cutoff panel opened from the PVE panel)
- Fixed the total CN player population calculation logic.

@H1@ v26.4.3.1318

@H2@ 公告
- 插件受欢迎程度和传播速度远超乎我的想象 我们将在本周持续优化enUS的本地化
并且预计加上俄文 韩语 德语 法语 西班牙语 葡萄牙语 意大利语的本地化选项
预计下次更新会放上一个公开的 locale Github仓库 (也或许我会有更好的方案)
又或者您精通以上任意语言 但是不会使用Github的Pull Request功能 也可以与我联络
我会在下次更新前想好一个方案和联络方式 请关注下次的更新公告

@H2@ Announcements
- The popularity and spread of this addon have gone far beyond what I expected. We will continue improving the enUS localization throughout this week.
- We also plan to add localization options for Russian, Korean, German, French, Spanish, Portuguese, and Italian.
- In the next update, I expect to publish a public locale GitHub repository, unless I come up with a better solution.
- If you are fluent in any of the languages above but are not familiar with GitHub pull requests, you are still welcome to contact me.
- I will decide on a proper contribution and contact method before the next update. Please keep an eye on the next patch notes.

@H2@ [新功能] 酒仙酒池条
- 可以自定义酒池上限 (预设200%)
- 可以自定义根据酒池百分比显示不同颜色

@H2@ [New Feature] Brewmaster Stagger Bar
- You can now customize the stagger cap, with 200% as the default.
- You can also customize different colors based on stagger percentage thresholds.

@H2@ 焦点读条
- 新增了当打断技能CD时 不播放音效的选项(默认开启)
- 新增一个功能 焦点条上面新增一条线 显示读到哪个位置打断能转好
- 可以在选项内调整线条粗细和颜色

@H2@ Focus Cast Bar
- Added an option to suppress sound playback while your interrupt is on cooldown. This is enabled by default.
- Added a marker line on the focus cast bar to show where your interrupt will become ready during the cast.
- The marker line thickness and color can now be adjusted in the options.

@H2@ 队友打断监控
- 稍微提升了一些准确度
(再次提示 本插件是合法使用暴雪事件达到的监控效果 做不到100%准确度 但是目前修正后能达到约90%准确率
并且 必须"成功打断" 才能进入CD)

@H2@ Party Interrupt Tracker
- Accuracy has been improved slightly.
- As a reminder, this tracker works through legitimate Blizzard events. It cannot be 100% accurate, but after the recent fixes it is currently around 90% accurate.
- Also, the interrupt cooldown only starts if the interrupt successfully lands.

@H2@ 大秘境小工具
- 新增了周围进入战斗的怪物数量显示 (默认关闭 按需开启)

@H2@ Mythic+ Tools
- Added a display for the number of nearby enemies currently in combat.
- This is disabled by default and can be enabled if needed.

@H2@ 大秘境周围怪物施法
- 重做了默认样式 可以选择重置或是按照自己喜欢的样式修改
- 移除了法术目标名称的服务器

@H2@ Nearby Enemy Casts in Mythic+
- Reworked the default style. You can either reset to the new default or continue customizing it to your liking.
- Removed the server name from cast target names.

@H2@ 嗜血提醒和音效
- 增加了图标边框
- 增加了图标持续时间文字的控件修改
- 现在可以无限添加自定义的音效

@H2@ Bloodlust Reminder and Sound
- Added icon borders.
- Added font controls for the icon duration text.
- You can now add an unlimited number of custom sound paths.

@H2@ 队友钥石查看
- 修正了插件通信检查的时机
- 增加缓存机制

@H2@ Party Keystone Viewer
- Fixed the timing of addon communication checks.
- Added a cache mechanism.

@H2@ 开发计划
- [EXBOSS] 目前EXBOSS大秘境首领方面逐渐完善 下一步准备小怪内置CD (完成度80%)
- [EXBOSS] 之后会打算把一些分类合并 让左侧的选项更少更精准 (完成度??)
-
- [新功能] 在集合石(LFG)申请进组后显示申请的副本 层数 以及跳出传送门按钮 (完成度90%)
- [新功能] 血条染色 (不确定能实现到什么程度 也不保证完美 但是这几天内会有结果)(完成度??)
- [新功能] 上方微型选单 (是的 从2月就搁置到现在) (完成度80%)
- [没有位移技能提醒] 预计下次修改成全职业可用方案 (完成度80%)
- [新功能] 标记和光柱面板 (完成度80%)

- [新项目] 之前的法术施放提示被我删除了 目前打算做一个简易版本的WA 实现一些基本简单的功能
(已完成基础框架搭建 (代码)环境隔离 性能分析 导入导出 动态群组等功能)

@H2@ Development Plans
- [EXBOSS] The Mythic+ boss side of EXBOSS is gradually becoming more complete. The next step is built-in cooldown tracking for trash mobs. (80% complete)
- [EXBOSS] After that, I plan to merge some categories so the left-side options become fewer and more focused. (??)
- [New Feature] After applying to a group in LFG, the addon will show the dungeon, key level, and a popup teleport button. (90% complete)
- [New Feature] Health bar coloring. I am not sure how far I can push this or whether it can be made perfect, but I should have results within the next few days. (??)
- [New Feature] Top mini menu. Yes, this has been sitting there since February. (80% complete)
- [No Movement Skill Alert] Expected to be reworked into an all-class solution in the next update. (80% complete)
- [New Feature] Marker and world marker panel. (80% complete)
- [New Project] I removed the previous spell alert system. Right now I plan to build a lightweight WA-like tool for simple functionality.
- The basic framework is already done, including environment isolation, performance analysis, import/export, and dynamic groups.

@H1@ v26.3.28.0830

@H2@ PVE面板的大秘境法术资讯
- 修复了左侧卡片无法点击切换的问题
- 修复了副本图案与名称不一致的问题
- 更新了最新的数据

@H2@ Mythic Spell Info in the PVE Panel
- Fixed an issue where the left-side cards could not be clicked to switch targets
- Fixed an issue where dungeon icons did not match their names
- Updated to the latest data

@H2@ PVE面板的大秘境分数和次数面板
- 为了避免误会说明清楚 称号线来源于Raid.io 每次插件打包发布的时候会自动抓取

@H2@ Mythic Score and Run Count Panel in the PVE Panel
- To avoid any misunderstanding, the title cutoff data comes from Raider.IO and is automatically fetched each time the addon is packaged for release

@H1@ v26.3.26.2206

@H2@ 队友钥石监控
- 新增队友钥石查看功能 由于开发繁忙 样式比较简单 (默认不启用的 如果需要请手动启用)

@H2@ Party Keystone Tracker
- Added a party keystone viewing feature. Due to limited development time, the styling is relatively simple. It is disabled by default; if needed, please enable it manually.

@H1@ v26.3.25.0912

@H2@ 综合
- 90%内容已经支援enUS本地化
- 有少量部份后续补充
- 为了避免争议 (之前已经声名过了) 重新声明一次
本插件目前有少量代码来自于其他插件 包含了
锚点选择器 @WeakAuras , 异步刷新 来自于 @Nnoggie (MDT)

@H2@ General
- 90% of the addon now supports enUS localization
- A small number of parts will be added later
-
- To avoid any dispute, this is stated here once in enUS: a small portion of this addon currently contains code derived from other addons, including the anchor selector from @WeakAuras and LibAsync from @Nnoggie (Mythic Dungeon Tools). As the addon is still under active development, a more complete attribution notice will be added in a proper location later.

@H2@ 打断监控
- 增加了判断时间阈值 以兼容偶发的服务器下发事件延迟
(PS:这个打断监控并不能做到100%准确 基本上能做到80%准确性)

@H2@ Interrupt Tracker
- Added a timing threshold check to better handle occasional server event delay
(PS: This interrupt tracker cannot be 100% accurate. In practice it is roughly 80% accurate.)

@H1@ v26.3.22.1149

@H2@ 重要通知
- 如果(包含未来)发生了明明已经安装ExwindTools 但是/EX无法打开面板的问题时
ESC-插件-找到EXWIND或是EX开头的所有插件-全部勾掉-再重新打勾-重新载入 即可解决
这是暴雪的插件管理系统偶尔会发生的假载入BUG (看似打勾了 实际上未载入)

@H2@ 重要通知 2
- 此次属于底层比较重大的更新 经过初步测试没问题 如果有任何BUG请直接透过B站或是NGA反馈
我会马上处里

@H2@ State系统
- 优化了一些内容

@H2@ MDT图标模块
- 修复了MDT还处于Async异步(协程)刷新时 过早挂载导致的报错问题

@H2@ 战斗复活监控
- 解决了当服务器尚未准备好事件时导致的不显示BUG

@H2@ 核心系统
- 当未载入ExwindTools时 现在打开/EX面板会有所提示

@H2@ 引擎: 框架池(FramePool)和GUI封装
- 彻底修复了勾选框相关的问题

@H1@ v26.3.15.0247

@H2@ 属性监控
- 解决了一个会在某些情况下没有刷新的问题

@H1@ v26.3.14.1549

@H2@ 通用
- Will Add enUS locale ASAP

@H2@ 队伍打断监控
- DK打断CD更新成12秒
- 暗牧打断CD更新成30秒

@H2@ 开发计划
- 首领战警报插件预计明天晚上可以公开发布测试版
- 经过两个月时间的加班开发 作者爆炸了 可能会休息一两天才恢复更新
大家可以持续反馈问题不影响
之前的开发计划 可以确定因该能大米开放之前补齐全
(当然 按照最完美的计划会在下周三之前补齐大多内容 让大家下CD每天刷M0可以用上)

@H1@ v26.3.13.0029

@H2@ 位移技能CD提示
- 更新法师闪现术算法
- 其他职业如果觉得有需要加入可以反馈

@H1@ v26.3.10.1405

@H2@ 通用
- Will Add enUS locale ASAP
- 新增隐藏小地图图标按钮 临时放在在首页右侧重置所有设置的按钮上面(一个勾选框)

@H2@ 属性监控
- 修复了暴击属性在某些场合下错误的问题

@H2@ 打断监控
- 新增了GRID2 EQL的框架锚点

@H2@ 开发计划
- 首领警报插件预计今晚开始测试 EXTOOLS剩余功能明天开始恢复更新
每天陆续补齐之前计划内容

@H1@ v26.3.8.1736

@H2@ 通用
- 修复一些细节问题

@H2@ 施法序列
- 现在能够正常在编辑模式下移动

@H2@ 大米鼠标提示冷却
- 现在大秘境内正常提示

@H2@ 开发进度
- 全力开发首领警报插件 工具箱计划两天后开始下一轮更新

@H1@ v26.3.5.2136

@H2@ 大秘境小工具
- 战斗复活计时器现在只在大秘境/首领战中出现

@H2@ 大米点击传送
- 相关逻辑写进大米图标分数的模块 现在关闭了鼠标提示增强也能正常点击传送

@H1@ v26.3.4.1410

@H2@ 属性面板
- 修复暴击不显示的问题
另外这个面板也将再过两天开发完首领警报语音插件后大幅加强功能

@H1@ v26.3.4.1242

@H2@ 测试框架锚点选择器
- 代码是WA的 目前先测试是否适配是否有BUG
还没想好是否留下 如果最终确定了会在插件内合适的位置声明代码来源

@H1@ v26.3.4.1129

@H2@ 法术透明度

- 新增高级选项 可以完全自定义法术触发的括号任何东西
包含(大小 XY轴 间距 缩放 动画速度等) 请注意这个改了后是所有法术括号都生效的

请注意!默认不载入! 启用后需要先重载才生效
请注意!默认不载入! 启用后需要先重载才生效
请注意!默认不载入! 启用后需要先重载才生效

如有问题请反馈

@H2@ 频道切换
- 现在所有频道的命令可以自定义 比如倒数可以自定义时间

@H1@ v26.3.3.1900

@H2@ 通用
- 这版本更新完后可能会停更两天 全力制作推出首领战警报(包含语音插件)

@H2@ 嗜血音效
- 暴雪开放嗜血DEBUFF监控后 我们的底层逻辑没变 还是透过急速差值来监控

原是我们底层有一个State系统 会根据事件更新玩家的一些资料 然后所有模块共享
并且在这个基础上我们有非常细腻的差值回调技术 且经过更细化的性能优化
也就是说不管10个还是100个模块 我们永远只有一次事件 一次(不同的)API请求
然后在lua层面分发回调 这种消耗是非常低的

如果换做监控DEBUFF来判定嗜血的话 消耗只会更高而已 因此最终选择了触发后再从DEBUFF验证并校准时间
(这几天大家测试嗜血因该只会更稳定 如果还有问题的话继续反馈 谢谢)

@H2@ 聊天频道按钮
- 新增了依附聊天框的功能 后续会继续优化但是不是这两天

@H1@ v26.3.2.1417

@H2@ 通用
- 所有计时条现在都能选择边框 若还有遗漏请反馈(透过LibShareMedia)

@H2@ 大秘境小工具
- 战斗计时新增托战后保留时间

@H2@ 大米传送通报
- 修复了传送时显示回调错误的问题

@H1@ v26.3.1.0545

@H2@ 通用
- 修复Elvui/Ndui 吸附到团队框架下方位置错误
- 修复常用功能（小工具箱Mini Tools）导入配置导致字体配置异常
- 修复嗜血音效在原生倒数模式下，嗜血图标不消失
- 打断监视描述文本微调
- 打断监控依附模式下的偏移量，允许的范围扩大
(有任何以上相关或是NDui问题 请继续反馈 非常需要!)

@H1@ v26.2.28.1843

@H2@ 通用
- 支援NDui皮肤 如有问题随时反馈
- 队友打断条支持依附队伍框架 (暴雪原生 DF ElvUI NDui)
(注意! 请勿在大秘境中进行这项操作! ! ! 可能会导致报错)

@H2@ 开发计划
- 其他问题预计两天后修复 新内容预计两天后发布
- 当前全力开发新的首领警报插件 包含完整语音包

@H1@ v26.2.26.1336

@H2@ 开发计划
- 插件内容很多地方都会美化 目前是临时的(比如模块管理那些图片)
目前先以大多数功能实现为主 我相信大家更需要的是实用功能 ! !

- 语音包插件基本开发完成目前在测试阶段 ! !
- 可以关注我在B站或是NGA插件区后续的发布! 这是一个比较大型的项目
- 简易版本WA基本做完 稍微美化一下就会上线(会放在这个工具箱内)

@H2@ 通用
- 解决了一些提出问题的用户
- 删除大多数在聊天框的提示 我的插件坚持不打扰用户为原则 (偶尔情况下最多一条 不刷屏)
如果看到任何额外多余又无法关闭的提示请反馈!

@H2@ 宏界面扩展
- 修复了未启用时的冲突问题

@H2@ 焦点打断模块
-焦点打断模块加了一个新功能

除了原本不能断的条隐藏以外
现在也可以根据你的打断技能CD隐藏
为了不要让你打断CD好的瞬间跳出来然后反应不过来
我额外加入了可以在你打断CD还剩下几秒时出现 以及以什么颜色出现

比如焦点正在读一个可断的条 我们设置剩余2秒时显示 颜色灰色(这个你们能改)
你的打断CD还有 3秒时 --> 隐藏焦点条
你打断CD小于2秒时 --> 显示焦点条 并且是灰色
当你打断CD好的瞬间 -->显示正常的打断颜色

@H2@ MDT替换图标
- 新增功能 一键标记MDT当前地图上可打断的怪物 (目前无法使用 因为MDT尚未更新怪物资料 下版本后能正常用)
- 新增功能 一键标记MDT当前地图上的精英怪物
- 以上两个标记都可以在设置面板设置
- 将MDT图标替换 以及以上功能 临时做成按钮放在MDT面板下方(后面会美化)

@H2@ 计划即将推出
- BOSS技能语音提示 (最后内测 马上推出)
- 私人光环监控(包含私人光环语音提示) (完成度70% 稍晚推出)
- 查看队友钥石 (完成度 80%)
- 上方微型选单 (完成度 80%)
- 大米开始前BUFF检查 包含点击使用合剂等物品 (完成度80% 会在暴雪开放API后推出)
- 法术施放提醒监控 (简易版本WA) (完成度 90%)
- 团队标记/光柱面板 (完成度 90%)
- 队友爆发/个人减伤监控 (完成度 80%)
- 拍卖行常用物品购买 (完成度20%)
- 大秘境小怪技能CD(只能在法术书查看时间 不是战斗中显示) (完成度 50%)
- 整体UI美化 (完成度 50%)
- 简单的一些小功能显示(耐久 装等 延迟 FPS等等)

@H1@ v26.2.23.0017

@H2@ 注意
本次更新没有新增功能 只是修复一些用户体验内容
非常多强大的模块已经开发进入收尾阶段 这几天即将推出

@H2@ 编辑模式
- 所有ExwindTools创建的东西都可以再编辑模式内移动
- 开启编辑模式后 在任意显示的东西右键都会跳转到对应的选单
- 开启编辑模式的方式
- /EX EDMODE (再按一次关闭编辑模式)
- 小地图右键 (再按一次关闭编辑模式)
- /EX 打开的UI面板右下角

@H2@ 模块管理页面
- 现在点击启用禁用后不会再跳回最顶端了
- 这个模块管理页面是临时的 后期会美化并且把模块功能对应的预览图片加上
并且会加上分类 展开收起选单等功能
- (目前优先级先以把各种功能提供给大家 以及修复影响用户体验的问题 美化优先级低一些大家理解下)

@H2@ State系统
- 增加了MapID以及智能MapGroup
- 新增了首领战ID缓存

@H2@ 聊天频道切换
- 现在支持输入/2 /1 这种指令

@H2@ 战斗复活提示
- 将文字的层级提高到倒数转圈之上

@H2@ 没有位移技能提示
- 新增了鼠标点击穿透
- (如果还有任意框架没有鼠标点击穿透影响了你的体验请第一时间反馈)

@H2@ 屏幕中心人物位置提示
- 新增了鼠标点击穿透
- (如果还有任意框架没有鼠标点击穿透影响了你的体验请第一时间反馈)
- 显示层级降低

@H2@ 距离监控
- 修复了40码距离不变色问题

@H2@ 大米传送通报
- 新增了施法成功才喊话选项

@H2@ 大米右侧PVE扩展面板
- 降低了框架层级

@H2@ 大米工具
- 战斗计时器默认禁用

@H2@ 法术施放监控 (延迟到下版本发布)
- 现在创建独立的UI面板
- 新增State差值回调监控
- 载入规则改为State回调后LoadMatched差分缓存

@H2@ 计划即将推出
- BOSS技能语音提示 (完成度 95%) 即将内部测试
- 私人光环监控(包含私人光环语音提示) (完成度70%)
- 查看队友钥石 (完成度 80%)
- 上方微型选单 (完成度 80%)
- 大米开始前BUFF检查 包含点击使用合剂等物品 (完成度60%)
- 法术施放提醒监控 (简易版本WA) (完成度 80%)
- 团队标记/光柱面板 (完成度 80%)
- 队友爆发/个人减伤监控 (完成度 80%)
- 拍卖行常用物品购买 (完成度20%)
- 大秘境小怪技能CD(只能在法术书查看时间 不是战斗中显示) (完成度 50%)
- 整体UI美化 (完成度 50%)
- 简单的一些小功能显示(耐久 装等 延迟 FPS等等)

@H2@ 计划优化内容
- 进出战斗语音提示
- 玩家属性对于坦克的优化

@H1@ v26.2.20.2150

@H2@ 通用
- 支持更新日志功能，每个新版本首次打开时都会跳出更新日志面板。
- 也可以在下方按钮查看。

@H2@ 状态监控
- 修复状态监控面板的时间为本地电脑时间。

@H2@ 大秘境小工具
- 新增：大米自动插入钥石（默认开启）。

@H2@ 聊天频道标签
- 修复倒数功能。
- 加入三个自定义功能，可以自己写上名称以及命令。
- 命令可以直接写，比如 /MDT /DBM /LOOT 这种。
- 这不是宏，请勿写施放法术等，会导致触发暴雪限制。

@H2@ 小工具
- 进入/离开战斗的文字现在会在离开编辑模式时彻底锁定。

@H2@ 队友打断监控
- 修复了增长的锚点问题 (如果后续锚点还有问题请继续反馈)

@H2@ 属性监控
- 加入编辑模式
- 修复了无法鼠标点击穿透的问题
- 加入耐久度。

@H2@ 位移CD提示
- 新增盗贼爪钩 暗影步提示 可自行修改提示内容 (临时使用全局刷新 后续会优化逻辑)
-
- 新增法师闪现依靠操控刷新的逻辑。
- 当天赋 = 1244087 时。
- 如果发生事件 COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED：baseSpellID, overrideSpellID。
- 且第一个参数 = 342245，第二个参数为 nil 时，恢复一层充能次数。

备注: PS: 与 ShimmerTracker 不同，它采用无脑 0.1 秒请求一次 API 的方式刷新，较为消耗性能。我们写的是较复杂的判定逻辑，好处是只在施放闪现瞬间运算一次，非常节省性能。

@H2@ 计划即将推出

- 查看队友钥石 (完成度 80%)
- 上方微型选单 (完成度 80%)
- 法术施放提醒监控 (简易版本WA) (完成度 80%)
- 团队标记/光柱面板 (完成度 80%)
- 队友爆发/个人减伤监控 (完成度 80%)
- 大秘境小怪技能CD(只能在法术书查看时间 不是战斗中显示) (完成度 50%)
- BOSS技能语音提示 (完成度 60%)
- 私人光环语音提示 (完成度 30%)
- 整体UI美化 (完成度 50%)
        ]],
    },
}
