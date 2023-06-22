if GetLocale() ~= "zhCN" then
	return
end
local L

---------------
-- Kargath Bladefist --
---------------
L = DBM:GetModLocalization(1128)

---------------------------
-- The Butcher --
---------------------------
L = DBM:GetModLocalization(971)

---------------------------
-- Tectus, the Living Mountain --
---------------------------
L = DBM:GetModLocalization(1195)

L:SetMiscLocalization({
	pillarSpawn	= "群山，动起来吧！"
})

------------------
-- Brackenspore, Walker of the Deep --
------------------
L = DBM:GetModLocalization(1196)

L:SetOptionLocalization({
	InterruptCounter	= "凋零打断计数器重置",
	Two					= "在两个打断后",
	Three				= "在三个打断后",
	Four				= "在四个打断后"
})

--------------
-- Twin Ogron --
--------------
L = DBM:GetModLocalization(1148)

L:SetOptionLocalization({
	PhemosSpecial		= "为菲莫斯的技能播放倒计时声音",
	PolSpecial			= "为波尔的技能播放倒计时声音",
	PhemosSpecialVoice	= "为菲莫斯的技能播放语音",
	PolSpecialVoice		= "为波尔的技能播放语音"
})

--------------------
--Koragh --
--------------------
L = DBM:GetModLocalization(1153)

L:SetWarningLocalization({
	specWarnExpelMagicFelFades	= "邪能5秒后消失 - 返回原位"
})

L:SetOptionLocalization({
	specWarnExpelMagicFelFades	= "为$spell:172895提供返回原位的特殊警报"
})

L:SetMiscLocalization({
	supressionTarget1	= "我要碾碎你！",
	supressionTarget2	= "闭嘴！",
	supressionTarget3	= "安静！",
	supressionTarget4	= "我要把你撕成两半！"
})

--------------------------
-- Imperator Mar'gok --
--------------------------
L = DBM:GetModLocalization(1197)

L:SetTimerLocalization({
	timerNightTwistedCD	= "下一个拜夜信徒"
})

L:SetOptionLocalization({
	GazeYellType	= "设定疯狂之眼的大喊方式",
	Countdown		= "倒计时 直到消失",
	Stacks			= "堆叠层数"
})

L:SetMiscLocalization({
	BrandedYell		= "烙印(%d层)%d码",
	GazeYell		= "凝视于%d秒后结束",
	GazeYell2		= "%s中了凝视(%d)",
	PlayerDebuffs	= "距离最近的疯狂之眼"  --165243
})
-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HighmaulTrash")

L:SetGeneralLocalization({
	name	= "悬槌堡小怪"
})

---------------
-- Gruul --
---------------
L = DBM:GetModLocalization(1161)

L:SetOptionLocalization({
	MythicSoakBehavior	= "特殊警报：吸收伤害的分组方式 (史诗模式)",
	ThreeGroup			= "3组1层换",
	TwoGroup			= "2组2层换"
})

---------------------------
-- Oregorger, The Devourer --
---------------------------
L = DBM:GetModLocalization(1202)

L:SetOptionLocalization({
	InterruptBehavior	= "设置打断$spell:156879警告的方式",
	Smart				= "基于BOSS尖刺的层数",
	Fixed				= "永远3打断或5打断轮换"
})

---------------------------
-- The Blast Furnace --
---------------------------
L = DBM:GetModLocalization(1154)

L:SetWarningLocalization({
	warnRegulators			= "温度调节器剩下:%d",
	warnBlastFrequency		= "冲击施法频率增加:大约每%d秒一次",
	specWarnTwoVolatileFire	= "你叠加了两层不稳定的火焰"
})

L:SetOptionLocalization({
	warnRegulators			= "显示剩余的温度调节器生命值",
	warnBlastFrequency		= "当$spell:155209施法频率增加时发出警告",
	specWarnTwoVolatileFire	= "特殊警报：当你受到两层$spell:176121的影响时",
	InfoFrame				= "为$spell:155192和$spell:155196显示信息框体",
	VFYellType2				= "设定$spell:176121的大喊方式 (史诗模式)",
	Countdown				= "倒数直到消失",
	Apply					= "只有中了的时候"
})

L:SetMiscLocalization({
	heatRegulator	= "温度调节器",
	Regulator		= "调节器 %d",
	bombNeeded		= "%d个炸弹"
})

--------------------------
-- Operator Thogar --
--------------------------
L = DBM:GetModLocalization(1147)

L:SetWarningLocalization({
	specWarnSplitSoon	= "10秒后分轨"
})

L:SetOptionLocalization({
	specWarnSplitSoon	= "特殊警报：当团队需要在10秒后分轨时",
	InfoFrameSpeed		= "设置何时在信息框体显示下一班列车的信息",
	Immediately			= "当门打开时",
	Delayed				= "当列车出现时",
	HudMapUseIcons		= "在HudMap中，使用团队标记代替绿圈",
	TrainVoiceAnnounce	= "设置语音报警下一班列车的信息类型",
	LanesOnly			= "仅包含轨道信息",
	MovementsOnly		= "仅包含走位信息 (史诗模式)",
	LanesandMovements	= "同时包含轨道信息和走位信息 (史诗模式)"
})

L:SetMiscLocalization({
	Train			= "火车",
	lane			= "轨道",
	oneTrain		= "随机单轨道快车",
	oneRandom		= "随机出现在一个轨道上",
	threeTrains		= "随机三轨道快车",
	threeRandom		= "随机出现在三个轨道上",
	helperMessage	= "建议使用第三方插件 'Thogar Assist' 索戈尔助手插件或DBM语音包来帮助你作战。这些都可以在Curse上找到。"
})

--------------------------
-- The Iron Maidens --
--------------------------
L = DBM:GetModLocalization(1203)

L:SetWarningLocalization({
	specWarnReturnBase	= "返回码头"
})

L:SetOptionLocalization({
	specWarnReturnBase	= "特殊警报：当上船的玩家可以安全地返回码头时",
	filterBladeDash3	= "当受到$spell:170395的影响时不显示$spell:155794的特殊警报",
	filterBloodRitual3	= "当受到$spell:170405的影响时不显示$spell:158078的特殊警报"
})

L:SetMiscLocalization({
	shipMessage		= "准备操纵无畏舰的主炮",
	EarlyBladeDash	= "太慢了！"
})

--------------------------
-- Blackhand --
--------------------------
L = DBM:GetModLocalization(959)

L:SetWarningLocalization({
	specWarnMFDPosition		= "死亡标记站位：%s",
	specWarnSlagPosition	= "炉渣炸弹站位：%s"
})

L:SetOptionLocalization({
	PositionsAllPhases	= "在所有阶段受到$spell:156096影响时喊话 (原来只在第三阶段喊。测试目的。)",
	InfoFrame			= " 为$spell:155992和$spell:156530显示信息框体"
})

L:SetMiscLocalization({
	customMFDSay	= "%2$s 中了 死亡标记(%1$s)!",
	customSlagSay	= "%2$s 中了 炉渣炸弹(%1$s)!"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("BlackrockFoundryTrash")

L:SetGeneralLocalization({
	name	= "黑石铸造厂小怪"
})

---------------
-- Hellfire Assault --
---------------
L = DBM:GetModLocalization(1426)

L:SetTimerLocalization({
	timerSiegeVehicleCD	= "下一辆攻城车-%s"
})

L:SetOptionLocalization({
	timerSiegeVehicleCD	= "计时条：下一辆攻城车"
})

L:SetMiscLocalization({
	AddsSpawn1	= "乘胜追击！",
	AddsSpawn2	= "投掷手雷！",
	BossLeaving	= "我会回来的..."--无法确定全角还是半角句号。有问题请联系我
})

---------------------------
-- Hellfire High Council --
---------------------------
L = DBM:GetModLocalization(1432)

L:SetWarningLocalization({
	reapDelayed	= "Reap after Visage ends"--Translate
})

--------------
-- Kilrogg Deadeye --
--------------
L = DBM:GetModLocalization(1396)

L:SetMiscLocalization({
	BloodthirstersSoon	= "来吧，兄弟们！把握你们的命运！"
})

--------------------
--Gorefiend --
--------------------
L = DBM:GetModLocalization(1372)

L:SetTimerLocalization({
	SoDDPS2		= "下一次死亡之影 (%s)",
	SoDTank2	= "下一次死亡之影 (%s)",
	SoDHealer2	= "下一次死亡之影 (%s)"
})

L:SetOptionLocalization({
	SoDDPS2			= "计时条：下一次针对DPS的$spell:179864",
	SoDTank2		= "计时条：下一次针对坦克的$spell:179864",
	SoDHealer2		= "计时条：下一次针对治疗的$spell:179864",
	ShowOnlyPlayer	= "只在你被$spell:179909点名时显示HUD"
})
--------------------------
-- Shadow-Lord Iskar --
--------------------------
L = DBM:GetModLocalization(1433)

L:SetWarningLocalization({
	specWarnThrowAnzu	=	"快传安苏之眼给%s！"
})

L:SetOptionLocalization({
	specWarnThrowAnzu	=	"特殊警报：当你需要传递$spell:179202给他人时"
})

--------------------------
-- Fel Lord Zakuun --
--------------------------
L = DBM:GetModLocalization(1391)

L:SetOptionLocalization({
	SeedsBehavior	= "设定种子的喊叫方式 (需要团长权限)",
	Iconed			= "星星, 大饼, 菱形, 三角, 月亮。 适合分散式开场。",--Default
	Numbered		= "1, 2, 3, 4, 5. 适合已分区的开场。",
	DirectionLine	= "左, 左偏中, 中, 右偏中, 右. 适合直线式开场。",
	FreeForAll		= "自由发挥. 不分配位置, 只大喊。"
})

L:SetMiscLocalization({
	DBMConfigMsg	= "团长已经将种子喊叫方式设定为 %s。",
	BWConfigMsg		= "团长在用Bigwigs, DBM将会使用数字来提示。"
})

--------------------------
-- Xhul'horac --
--------------------------
L = DBM:GetModLocalization(1447)

L:SetOptionLocalization({
	ChainsBehavior	= "设定邪能锁链的警告方式。时间在开始施法时同步。",
	Cast			= "当施法开始时只给予原始目标警告。",
	Applied			= "当施法结束时给予所有受影响的目标警告。",
	Both			= "开始和结束"
})

--------------------------
-- Socrethar the Eternal --
--------------------------
L = DBM:GetModLocalization(1427)

L:SetOptionLocalization({
	InterruptBehavior	= "设置打断方式 (需要团长权限)",
	Count3Resume		= "3人循环打断, 邪能壁垒后继续计数",--Default
	Count3Reset			= "3人循环打断, 邪能壁垒时重置计数",
	Count4Resume		= "4人循环打断, 邪能壁垒后继续计数",
	Count4Reset			= "4人循环打断, 邪能壁垒时重置计数"
})

--------------------------
-- Tyrant Velhari --
--------------------------
L = DBM:GetModLocalization(1394)

--------------------------
-- Mannoroth --
--------------------------
L = DBM:GetModLocalization(1395)

L:SetOptionLocalization({
	CustomAssignWrath	= "使用玩家角色决定$spell:186348的图标(团长开启有效, 可能和BW或过期DBM冲突)"
})

L:SetMiscLocalization({
	felSpire	=	"开始强化邪能尖塔！"
})

--------------------------
-- Archimonde --
--------------------------
L = DBM:GetModLocalization(1438)

L:SetWarningLocalization({
	specWarnBreakShackle	= "枷锁酷刑：拉断%s！"
})

L:SetOptionLocalization({
	specWarnBreakShackle	= "特殊警报：当你受到$spell:184964影响时。DBM会自动分配拉断次序，使得伤害最小化。",
	ExtendWroughtHud3		= "将HUD连线延长到受到$spell:185014影响的目标上。 (可能会导致连线准确度下降)",
	AlternateHudLine		= "在HUD中使用代替的线条材质来指示$spell:185014",
	NamesWroughtHud			= "在HUD中显示受到$spell:185014影响的目标的姓名",
	FilterOtherPhase		= "过滤掉不在同一阶段的事件",
	MarkBehavior			= "设定$spell:187051的喊叫方式（需要团长权限）",
	Numbered				= "星星，大饼，菱形，三角。 适合任何站位方式。",--Default
	LocSmallFront			= "近战（左星星，右大饼），远程（左菱形，右三角）。Debuff时间短的去近战位。",
	LocSmallBack			= "近战（左星星，右大饼），远程（左菱形，右三角）。Debuff时间短的去远程位。",
	NoAssignment			= "关闭全部提示。如果你用了其他插件。",
	overrideMarkOfLegion	= "不允许团长覆盖军团印记的行为(只推荐给自信满满的高级玩家使用)"
})

L:SetMiscLocalization({
	phase2point5	= "面对现实吧，愚蠢的凡人。你们无法抵抗燃烧军团的无穷大军。",
	First			= "第一个",
	Second			= "第二个",
	Third			= "第三个",
	Fourth			= "第四个",
	Fifth			= "第五个"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HellfireCitadelTrash")

L:SetGeneralLocalization({
	name	= "地狱火堡垒小怪"
})
