if GetLocale() ~= "zhTW" then
	return
end
local L

---------------
-- Kargath Bladefist --
---------------
L = DBM:GetModLocalization(1128)

L:SetTimerLocalization({
	timerSweeperCD	= "Next Arena Sweeper"--Translate
})

---------------------------
-- Tectus, the Living Mountain --
---------------------------
L = DBM:GetModLocalization(1195)

L:SetMiscLocalization({
	pillarSpawn	= "起來吧，群山！"
})

------------------
-- Brackenspore, Walker of the Deep --
------------------
L = DBM:GetModLocalization(1196)

L:SetOptionLocalization({
	InterruptCounter	= "重數衰減打算計數",
	Two					= "在兩次打斷後",
	Three				= "在三次打斷後",
	Four				= "在四次打斷後"
})

--------------
-- Twin Ogron --
--------------
L = DBM:GetModLocalization(1148)

L:SetOptionLocalization({
	PhemosSpecial		= "為菲莫斯的技能冷卻播放倒數音效",
	PolSpecial			= "為博爾的技能冷卻播放倒數音效",
	PhemosSpecialVoice	= "為菲莫斯的技能播放語音包音效",
	PolSpecialVoice		= "為博爾的技能播放語音包音效"
})

--------------------
--Koragh --
--------------------
L = DBM:GetModLocalization(1153)

L:SetWarningLocalization({
	specWarnExpelMagicFelFades	= "魔化結束於五秒內 - 回到原位"
})

L:SetOptionLocalization({
	specWarnExpelMagicFelFades	= "為$spell:172895消退顯示回到原位的特別警告"
})

L:SetMiscLocalization({
	supressionTarget1	= "我要擊垮你們！",
	supressionTarget2	= "閉嘴！",
	supressionTarget3	= "安靜！",
	supressionTarget4	= "我要把你撕成兩半！"
})

--------------------------
-- Imperator Mar'gok --
--------------------------
L = DBM:GetModLocalization(1197)

L:SetTimerLocalization({
	timerNightTwistedCD	= "下一次夜狂信徒"
})

L:SetOptionLocalization({
	GazeYellType		= "設定瘋狂之眼的大喊方式",
	Countdown			= "倒數直到消失",
	Stacks				= "堆疊層數",
	timerNightTwistedCD	= "為下一次夜狂信徒顯示計時器"
})

L:SetMiscLocalization({
	BrandedYell		= "烙印(%d層)%d碼",
	GazeYell		= "凝視結束於%d秒內",
	GazeYell2		= "%s中了凝視(%d)",
	PlayerDebuffs	= "最接近的瘋狂之眼"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HighmaulTrash")

L:SetGeneralLocalization({
	name	= "天槌小怪"
})

---------------
-- Gruul --
---------------
L = DBM:GetModLocalization(1161)

L:SetOptionLocalization({
	MythicSoakBehavior	= "為神話模式團隊設置分傷戰術的團隊警告",
	ThreeGroup			= "三小隊一層的戰術",
	TwoGroup			= "兩小隊兩層的戰術"
})

---------------------------
-- Oregorger, The Devourer --
---------------------------
L = DBM:GetModLocalization(1202)

L:SetOptionLocalization({
	InterruptBehavior	= "設定中斷警告的行為模式",
	Smart				= "基於首領黑石彈幕層數發出中斷警告",
	Fixed				= "持續3中斷或5中斷警告"
})

---------------------------
-- The Blast Furnace --
---------------------------
L = DBM:GetModLocalization(1154)

L:SetWarningLocalization({
	warnRegulators			= "熱能調節閥剩餘:%d",
	warnBlastFrequency		= "爆炸施放頻率增加：大約每%d秒一次",
	specWarnTwoVolatileFire	= "你中了兩個烈性之火!"
})

L:SetOptionLocalization({
	warnRegulators			= "提示熱能調節閥還剩多少體力",
	warnBlastFrequency		= "提示$spell:155209施放頻率增加",
	specWarnTwoVolatileFire	= "當你中了兩個$spell:176121顯示特別警告",
	InfoFrame				= "為$spell:155192和$spell:155196顯示訊息框架",
	VFYellType2				= "設定烈性之火的大喊方式 (只有傳奇模式)",
	Countdown				= "倒數直到消失",
	Apply					= "只有中了時候"
})

L:SetMiscLocalization({
	heatRegulator	= "熱能調節閥",
	Regulator		= "調節閥%d",
	bombNeeded		= "%d炸彈"
})

--------------------------
-- Operator Thogar --
--------------------------
L = DBM:GetModLocalization(1147)

L:SetWarningLocalization({
	specWarnSplitSoon	= "10秒後團隊分開"
})

L:SetOptionLocalization({
	specWarnSplitSoon	= "團隊分開10秒前顯示特別警告",
	InfoFrameSpeed		= "設定何時訊息框架顯示下一次列車的資訊",
	Immediately			= "車門一開後立即顯示此班列車",
	Delayed				= "在此班列車出站之後",
	HudMapUseIcons		= "為HudMap使用團隊圖示而非綠圈",
	TrainVoiceAnnounce	= "設定列車的語音警告模式",
	LanesOnly			= "只提示即將來的軌道",
	MovementsOnly		= "只提示軌道走位 (只有傳奇模式)",
	LanesandMovements	= "提示即將來的軌道和軌道走位 (只有傳奇模式)"
})

L:SetMiscLocalization({
	Train			= "Train",--Needs fixing
	lane			= "車道",
	oneTrain		= "一個隨機列車道",
	oneRandom		= "出現一個隨機列車道",
	threeTrains		= "三個隨機列車道",
	threeRandom		= "出現三個隨機列車道",
	helperMessage	= "在這戰鬥推薦搭配協力插件'Thogar Assist'或是新版本的DBM語音包。可從Curse下載 "
})

--------------------------
-- The Iron Maidens --
--------------------------
L = DBM:GetModLocalization(1203)

L:SetWarningLocalization({
	specWarnReturnBase	= "快回到碼頭！"
})

L:SetOptionLocalization({
	specWarnReturnBase	= "當船上玩家可以安全回到碼頭時顯示特別警告",
	filterBladeDash3	= "不要為$spell:155794顯示特別警告當中了$spell:170395",
	filterBloodRitual3	= "不要為$spell:158078顯示特別警告當中了$spell:170405"
})

L:SetMiscLocalization({
	shipMessage		= "準備裝填無畏號的主砲了！",
	EarlyBladeDash	= "太慢了。"
})

--------------------------
-- Blackhand --
--------------------------
L = DBM:GetModLocalization(959)

L:SetWarningLocalization({
	specWarnMFDPosition		= "死亡標記站位：%s",
	specWarnSlagPosition	= "裝置熔渣彈站位: %s"
})

L:SetOptionLocalization({
	PositionsAllPhases	= "讓所有階段大喊$spell:156096 (這選項使用於測試確保功能正常，不推薦使用)",
	InfoFrame			= "為$spell:155992和$spell:156530顯示訊息框架"
})

L:SetMiscLocalization({
	customMFDSay	= "%2$s中了死亡標記(%1$s)",
	customSlagSay	= "%2$s中了裝置熔渣彈(%1$s)"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("BlackrockFoundryTrash")

L:SetGeneralLocalization({
	name	= "黑石鑄造場小怪"
})

---------------
-- Hellfire Assault --
---------------
L = DBM:GetModLocalization(1426)

L:SetTimerLocalization({
	timerSiegeVehicleCD	= "下一個載具%s",
})

L:SetOptionLocalization({
	timerSiegeVehicleCD = "為下一個攻城載具重生顯示計時器"
})

L:SetMiscLocalization({
	AddsSpawn1	= "火力全開！",
	AddsSpawn2	= "開火！",
	BossLeaving	= "我會回來的…"
})

---------------------------
-- Hellfire High Council --
---------------------------
L = DBM:GetModLocalization(1432)

L:SetWarningLocalization({
	reapDelayed	= "收割在夢魘幻貌結束之後"
})

--------------
-- Kilrogg Deadeye --
--------------
L = DBM:GetModLocalization(1396)

L:SetMiscLocalization({
	BloodthirstersSoon	= "都給我上！盡你們的責任！"
})

--------------------
--Gorefiend --
--------------------
L = DBM:GetModLocalization(1372)

L:SetTimerLocalization({
	SoDDPS2		= "下一次死亡之影(%s)",
	SoDTank2	= "下一次死亡之影(%s)",
	SoDHealer2	= "下一次死亡之影(%s)"
})

L:SetOptionLocalization({
	SoDDPS2			= "為下一個傷害職中了$spell:179864顯示計時器",
	SoDTank2		= "為下一個坦克職中了$spell:179864顯示計時器",
	SoDHealer2		= "為下一個治療職中了$spell:179864顯示計時器",
	ShowOnlyPlayer	= "只顯示HudMap在當你參與到$spell:179909時"

})

--------------------------
-- Shadow-Lord Iskar --
--------------------------
L = DBM:GetModLocalization(1433)

L:SetWarningLocalization({
	specWarnThrowAnzu	=	"把安祖之眼丟給%s！"
})

L:SetOptionLocalization({
	specWarnThrowAnzu	=	"當你需要把$spell:179202丟給其他人顯示特別警告"
})

--------------------------
-- Fel Lord Zakuun --
--------------------------
L = DBM:GetModLocalization(1391)

L:SetOptionLocalization({
	SeedsBehavior	= "設定團隊的種子大喊行為(需要團隊隊長)",
	Iconed			= "星星,圈圈,鑽石,三角,月亮。適用於用於分散站位",
	Numbered		= "1, 2, 3, 4, 5。適用於分區站位",
	DirectionLine	= "左, 中偏左, 中間, 中偏右, 右。適用於直線站位",
	FreeForAll		= "自由模式。不指定佔位，只使用普通的大喊"
})

L:SetMiscLocalization({
	DBMConfigMsg	= "種子設定已設定為%s以符合團隊隊長設定。",
	BWConfigMsg		= "團隊隊長使用Bigwigs中，設定DBM為編號以符合Bigwigs的種子大喊。"
})

--------------------------
-- Xhul'horac --
--------------------------
L = DBM:GetModLocalization(1447)

L:SetOptionLocalization({
	ChainsBehavior	= "設定魔化鎖鍊警告行為",
	Cast			= "只給原始目標施放開始時警告。計時器同步在施放開始時。",
	Applied			= "只會中招目標施放結束時警告。計時器同步在施放結束時。",
	Both			= "原始目標施放開始時和中招目標施放結束時警告。"
})

--------------------------
-- Socrethar the Eternal --
--------------------------
L = DBM:GetModLocalization(1427)

L:SetOptionLocalization({
	InterruptBehavior	= "設置團隊的中斷模式(需要團隊隊長)",
	Count3Resume		= "3人持續計數循環中斷當護盾消失時",--Default
	Count3Reset			= "3人重置計數循環中斷當護盾消失時",
	Count4Resume		= "4人持續計數循環中斷當護盾消失時",
	Count4Reset			= "4人重置計數循環中斷當護盾消失時"
})

--------------------------
-- Mannoroth --
--------------------------
L = DBM:GetModLocalization(1395)

L:SetOptionLocalization({
	CustomAssignWrath	= "基於角色專精設置$spell:186348的團隊圖示(必須由團隊隊長開啟。可能會與BW或過期DBM衝突)"
})

L:SetMiscLocalization({
	felSpire	= "開始強化惡魔尖塔！"
})

--------------------------
-- Archimonde --
--------------------------
L = DBM:GetModLocalization(1438)

L:SetWarningLocalization({
	specWarnBreakShackle	= "束縛折磨：%s拉斷!"
})

L:SetOptionLocalization({
	specWarnBreakShackle	= "當中了$spell:184964時顯示特別警告。此警告會自動分配拉斷順序去最小化承受傷害。",
	ExtendWroughtHud3		= "把HUB連線延伸到$spell:185014目標 (可能會降低連線精準度)",
	AlternateHudLine		= "為$spell:185014之間的目標HUD連線使用替代連線材質",
	NamesWroughtHud			= "為$spell:185014目標顯示HUD的玩家名稱",
	FilterOtherPhase		= "過濾掉與你不同階段的警告",
	MarkBehavior			= "設置燃燒軍團印記大喊方式(需要團隊隊長)",
	Numbered				= "星星、圈圈、鑽石、三角。適用任何站位的打法。",--Default
	LocSmallFront			= "近戰(左星星、右圈圈)、遠程(左鑽石、右三角)。 短時間減益在近戰。",
	LocSmallBack			= "近戰(左星星、右圈圈)、遠程(左鑽石、右三角)。 短時間減益在遠程。",
	NoAssignment			= "為整個團隊禁用所有站位大喊/訊息，還有HUD指示。",
	overrideMarkOfLegion	= "不允許團隊隊長覆蓋軍團印記的行為(只推薦給進階玩家使用)"
})

L:SetMiscLocalization({
	phase2point5	= "看看燃燒軍團的軍容有多壯盛，就知道你們無謂的抵抗有多愚蠢。",
	First			= "第一個",
	Second			= "第二個",
	Third			= "第三個",
	Fourth			= "第四個",
	Fifth			= "第五個",
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("HellfireCitadelTrash")

L:SetGeneralLocalization({
	name	= "地獄火堡壘小怪"
})
