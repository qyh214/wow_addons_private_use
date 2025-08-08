local addon, ns = ... 

-- [[ 根據地點調整亮度 ]] --

-- add new map id by yourself:
-- https://warcraft.wiki.gg/wiki/UiMapID
-- https://warcraft.wiki.gg/wiki/InstanceID
-- https://wago.tools/db2/UiMap
-- https://wago.tools/db2/Map
-- macro to get your map id:
-- /dump C_Map.GetBestMapForUnit("player")
-- 
-- C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID)
-- https://warcraft.wiki.gg/wiki/API_C_AreaPoiInfo.GetAreaPOIInfo
-- https://wago.tools/db2/AreaTable
-- C_Map.GetAreaInfo 9964 潮水聖所  14619 14692 澤斯克拉密庫
-- CVar Gamma/Brightness/Contrast

ns.LDActive = true

ns.timeID = {
	-- BFA
	[896] = true,	-- Drustvar / 佐司瓦
	[895] = true,	-- Tiragarde Sound / 提加拉德
	[942] = true,	-- Stormsong Valley / 斯托頌恩
	[864] = true,	-- Vol'dun / 沃魯敦
	[863] = true,	-- Nazmir / 納茲米爾
	[862] = true,	-- Zuldazar / 祖達薩

	-- DF
	[2022] = true,	-- The Waking Shores / 甦醒海岸
	[2023] = true,	-- 	Ohn'ahran Plains / 雍亞拉平原
	[2024] = true,	-- The Azure Span / 蒼藍高地
	[2025] = true,	-- 	Thaldraszus / 薩爪祖斯
	--[1462] = true,	-- 麥卡貢/機械岡
	--[1196] = true,
	--[1197] = true,
	--[1198] = true,
	-- TWW
	[2369] = true,	-- Siren Isle / 海妖島
}

ns.zoneDarkID = {
	-- SL
	[1533] = true,	-- Bastion / 昇靈堡
	[1707] = true,	-- Elysian Hold, Archon's Rise / 樂土堡
	[1708] = true,	-- Elysian Hold, Sanctum of Binding / 樂土堡
}

ns.zoneLightID = {
	-- AZEROTH
	[86] = true,	-- Orgrimmar / 奧格瑪暗影裂谷
	-- LEGION
	[885] = true,	-- Antoran Wastes / 安托洛斯荒原
	-- Antorus, the Burning Throne / 安托洛斯，燃燒王座
	[909] = true,	-- 	Antorus, the Burning Throne/ 燃燒王座
	[910] = true,	-- 	Gaze of the Legion / 軍團之視
	[911] = true,	-- 	Halls of the Boundless Reach / 無縛之境
	[914] = true,	-- 	The Exhaust / 排氣口
	--[915] = true,	-- 	The Burning Throne / 燃燒王座
	[916] = true,	-- 	Chamber of Anguish / 苦痛之廳
	--[917] = true,	-- 	The World Soul / 世界之魂
	-- BFA
	[1162] = true,	-- Siege of Boralus / 波拉勒斯圍城戰
	[1038] = true,	-- Temple of Sethraliss / 瑟沙利斯神廟
	[1152] = true,	-- Uldir, Plague Vault / 奧迪爾，維克提斯
	[1169] = true,	-- Tol Dagor outside / 托達戈爾戶外	
	-- BFA VISION
	[1469] = true, -- Vision of Orgrimmar / 奧格瑪幻象
	[1470] = true, -- Vision of Stormwind / 暴風城幻象
	[1570] = true, -- 恆春谷幻象
	[1571] = true, -- 奧丹姆幻象
	-- SL
	[1543] = true, -- The Maw / 噬淵
	--[1961] = true, -- Korthia / 科西亞
	-- DF
	[2151] = true,	-- The Forbidden Reach / 禁忌離島 (澤斯克拉密庫沒有單獨的地圖)
	[2095] = true,	-- Infusion Chambers / 閃霜入侵點
	[2133] = true,	-- Zaralek Cavern / 扎拉萊克洞穴
	-- TWW
	[2214] = true,	-- 鳴響深淵
	[2255] = true,	-- 阿茲-卡罕特
	[2213] = true,	-- 蛛絲城野外
	--[2256] = true,	-- 阿茲-卡罕特下層 這啥?
	[2317] = true,	-- 培育所，風暴育所
	[2318] = true,	-- 培育所，風暴飛騎兵營
	[2319] = true,	-- 培育所，風暴廳堂
	[2320] = true,	-- 培育所，廢棄礦坑
	[2388] = true,	-- 水閘行動，GRID
}

ns.insLightID = {
	-- AZEROTH
	[289] = true,	-- Scholomance OLD / 舊通靈學院
	[1007] = true,	-- Scholomance / 新通靈學院
	[329] = true,	-- Stratholme / 斯坦索姆
	[533] = true,	-- Naxxramas / 納克薩瑪斯
	-- CATA
	[670] = true,	-- Grim Batol / 格瑞姆巴托
	-- WOD
	[1176] = true,	-- Shadowmoon Burial Grounds / 影月墓地
	-- LEG
	[1466] = true,	-- Darkheart Thicket / 暗心灌木林
	[1501] = true,	-- Black Rook Hold / 玄鴉堡
	-- BFA
	[1841] = true,	-- The Underrot / 幽腐深窟
	[1762] = true,	-- Kings' Rest / 諸王之眠
	[1711] = true,	-- Tol Dagor / 托達戈爾
	[1862] = true,	-- Waycrest Manor / 威奎斯特莊園
	-- SL
	[2284] = true,	-- Sanguine Depths / 血紅深淵
	[2162] = true,	-- Torghast, Tower of the Damned / 托加斯特
	-- DF
	[2515] = true,	-- The Azure Vault / 蒼藍密庫
	[2519] = true,	-- Neltharus / 奈薩魯斯堡
	[2520] = true,	-- Brackenhide Hollow / 撅屁...蕨皮谷
	--[2527] = true,	-- Halls of Infusion / 灌注迴廊
	-- TWW
	[2664] = true,	-- 菌菇愚行
	[2679] = true,	-- 真菌法師洞窟
	[2680] = true,	-- 地行礦坑
	[2681] = true,	-- 克里格瓦之眠
	[2682] = true,	-- 澤克維爾巢穴
	[2683] = true,	-- 水力發電壩
	[2684] = true,	-- 恐怖地穴
	[2685] = true,	-- 奔蛛裂層
	[2686] = true,	-- 夜暮聖所
	[2687] = true,	-- 陷坑
	[2688] = true,	-- 迴繞地道
	[2689] = true,	-- 塔克-瑞桑深淵
    [2826] = true,	-- 後街水閘	
	[2815] = true,	-- 9號挖掘場
	[2669] = true,	-- 蛛絲城
	[2652] = true,	-- 石庫
	[2651] = true,	-- 暗焰裂縫
	[2660] = true,	-- 『回音之城』厄拉卡拉
}

ns.insDarkID = {
	[2285] = true,	-- Spires Of Ascension / 晉升之巔
}

ns.subName = {
    ["無光深淵"] = true,
    ["无光深渊"] = true,
    ["Lightless Depths"] = true,
    ["Lichtlose Kluft"] = true,
    ["Profundidades Lóbregas"] = true,
    ["Profundidades Penumbrosas"] = true,
    ["Profondeurs Enténébrées"] = true,
    ["Profondità Senza Luce"] = true,
    ["빛이 들지 않는 심연"] = true,
    ["Profundezas Sem Luz"] = true,
    ["Беспросветные глубины"] = true,
}

ns.ignoreID = {
    [2651] = true,
}