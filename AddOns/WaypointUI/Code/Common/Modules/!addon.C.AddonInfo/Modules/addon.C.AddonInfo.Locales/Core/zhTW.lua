-- ♡ Translation // BlueNightSky

---@class addon
local addon = select(2, ...)
local L = addon.C.AddonInfo.Locales

--------------------------------

L.zhTW = {}
local NS = L.zhTW; L.zhTW = NS

--------------------------------

function NS:Load()
	if GetLocale() ~= "zhTW" then
		return
	end

	--------------------------------
	-- GENERAL
	--------------------------------

	do

	end

	--------------------------------
	-- WAYPOINT SYSTEM
	--------------------------------

	do
		-- PINPOINT
		L["WaypointSystem - Pinpoint - Quest - Complete"] = "可交付任務"
	end

	--------------------------------
	-- SLASH COMMAND
	--------------------------------

	do
		L["SlashCommand - /way - Map ID - Prefix"] = "當前地圖ID: "
		L["SlashCommand - /way - Map ID - Suffix"] = ""
		L["SlashCommand - /way - Position - Axis (X) - Prefix"] = "X: "
		L["SlashCommand - /way - Position - Axis (X) - Suffix"] = ""
		L["SlashCommand - /way - Position - Axis (Y) - Prefix"] = ", Y: "
		L["SlashCommand - /way - Position - Axis (Y) - Suffix"] = ""
	end

	--------------------------------
	-- CONFIG
	--------------------------------

	do
		L["Config - General"] = "通用"
		L["Config - General - Title"] = "通用"
		L["Config - General - Title - Subtext"] = "自定義整體設定。"
		L["Config - General - Preferences"] = "偏好"
		L["Config - General - Preferences - Meter"] = "使用公尺代替碼"
		L["Config - General - Preferences - Meter - Description"] = "將測量單位更改為公制。"
		L["Config - General - Preferences - Font"] = "字體"
		L["Config - General - Preferences - Font - Description"] = "整個插件中使用的字體。"
		L["Config - General - Reset"] = "重置"
		L["Config - General - Reset - Button"] = "重置回預設"
		L["Config - General - Reset - Confirm"] = "你確定要重置所有設定嗎？"
		L["Config - General - Reset - Confirm - Yes"] = "確認"
		L["Config - General - Reset - Confirm - No"] = "取消"

		L["Config - WaypointSystem"] = "一般"
		L["Config - WaypointSystem - Title"] = "一般"
		L["Config - WaypointSystem - Title - Subtext"] = "管理一般設定，像是路徑點系統行為。"
		L["Config - WaypointSystem - Type"] = "啟用"
		L["Config - WaypointSystem - Type - Both"] = "所有"
		L["Config - WaypointSystem - Type - Waypoint"] = "路徑點"
		L["Config - WaypointSystem - Type - Pinpoint"] = "標記點"
		L["Config - WaypointSystem - General"] = "一般"
		L["Config - WaypointSystem - General - RightClickToClear"] = "Right-Click To Clear"
		L["Config - WaypointSystem - General - RightClickToClear - Description"] = "Allows you to clear the Waypoint/Pinpoint/Navigator by right-clicking it."
		L["Config - WaypointSystem - General - Transition Distance"] = "標記點距離"
		L["Config - WaypointSystem - General - Transition Distance - Description"] = "標記點顯示的最大距離。"
		L["Config - WaypointSystem - General - Hide Distance"] = "最小距離"
		L["Config - WaypointSystem - General - Hide Distance - Description"] = "路徑點/標記點 隱藏的最小距離。"
		L["Config - WaypointSystem - Waypoint"] = "路徑點"
		L["Config - WaypointSystem - Waypoint - Footer - Type"] = "額外資訊"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Both"] = "全部"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Distance"] = "距離"
		L["Config - WaypointSystem - Waypoint - Footer - Type - ETA"] = "抵達時間"
		L["Config - WaypointSystem - Waypoint - Footer - Type - None"] = "無"
		L["Config - WaypointSystem - Pinpoint"] = "標記點"
		L["Config - WaypointSystem - Pinpoint - Info"] = "Show Info"
		L["Config - WaypointSystem - Pinpoint - Info - Extended"] = "顯示額外訊息"
		L["Config - WaypointSystem - Pinpoint - Info - Extended - Description"] = "包含額外的訊息，例如名稱/描述。"
		L["Config - WaypointSystem - Navigator"] = "導航器"
		L["Config - WaypointSystem - Navigator - Enable"] = "顯示"
		L["Config - WaypointSystem - Navigator - Enable - Description"] = "當路徑點或標記點在螢幕外，導航器將指出方位。"

		L["Config - Appearance"] = "外觀"
		L["Config - Appearance - Title"] = "外觀"
		L["Config - Appearance - Title - Subtext"] = "自定義用戶界面的外觀。"
		L["Config - Appearance - Waypoint"] = "路徑點"
		L["Config - Appearance - Waypoint - Scale"] = "路徑點大小"
		L["Config - Appearance - Waypoint - Scale - Description"] = "路徑點大小根據距離變化，此選項設置了整體尺寸。"
		L["Config - Appearance - Waypoint - Scale - Min"] = "最小 %"
		L["Config - Appearance - Waypoint - Scale - Min - Description"] = "可以減小到的最小 % 尺寸。"
		L["Config - Appearance - Waypoint - Scale - Max"] = "最大 %"
		L["Config - Appearance - Waypoint - Scale - Max - Description"] = "可以放大到的最大 % 尺寸。"
		L["Config - Appearance - Waypoint - Beam"] = "顯示光束"
		L["Config - Appearance - Waypoint - Beam - Alpha"] = "透明度"
		L["Config - Appearance - Waypoint - Footer"] = "顯示訊息文字"
		L["Config - Appearance - Waypoint - Footer - Scale"] = "大小"
		L["Config - Appearance - Waypoint - Footer - Alpha"] = "訊息文字透明度"
		L["Config - Appearance - Pinpoint"] = "標記點"
		L["Config - Appearance - Pinpoint - Scale"] = "標記點大小"
		L["Config - Appearance - Navigator"] = "導航器"
		L["Config - Appearance - Navigator - Scale"] = "尺寸大小"
		L["Config - Appearance - Navigator - Alpha"] = "透明度"
		L['Config - Appearance - Navigator - Distance'] = "Distance"
		L["Config - Appearance - Visual"] = "視覺"
		L["Config - Appearance - Visual - UseCustomColor"] = "使用自訂顏色"
		L["Config - Appearance - Visual - UseCustomColor - Color"] = "顏色"
		L["Config - Appearance - Visual - UseCustomColor - TintIcon"] = "染色圖示"
		L["Config - Appearance - Visual - UseCustomColor - Reset"] = "重設"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Default"] = "普通任務"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Repeatable"] = "可重複任務"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Important"] = "重要任務"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Incomplete"] = "未完成任務"
		L["Config - Appearance - Visual - UseCustomColor - Neutral"] = "一般路徑點"

		L["Config - Audio"] = "音效"
		L["Config - Audio - Title"] = "音效"
		L["Config - Audio - Title - Subtext"] = "路徑點介面音效的設置。"
		L["Config - Audio - General"] = "一般"
		L["Config - Audio - General - EnableGlobalAudio"] = "啟用音效"
		L["Config - Audio - Customize"] = "自訂"
		L["Config - Audio - Customize - UseCustomAudio"] = "使用自訂音效"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID"] = "聲音ID"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID - Placeholder"] = "自訂ID"
		L["Config - Audio - Customize - UseCustomAudio - Preview"] = "預覽"
		L["Config - Audio - Customize - UseCustomAudio - Reset"] = "重設"
		L["Config - Audio - Customize - UseCustomAudio - WaypointShow"] = "顯示路徑點"
		L["Config - Audio - Customize - UseCustomAudio - PinpointShow"] = "顯示標記點"

		L["Config - About"] = "關於"
		L["Config - About - Contributors"] = "貢獻者"
		L["Config - About - Developer"] = "開發人員"
	end

	--------------------------------
	-- CONTRIBUTORS
	--------------------------------

	do
		L["Contributors - ZamestoTV"] = "ZamestoTV"
		L["Contributors - ZamestoTV - Description"] = "翻譯者 — 俄語"
		L["Contributors - huchang47"] = "huchang47"
		L["Contributors - huchang47 - Description"] = "翻譯者 — 簡体中文"
		L["Contributors - BlueNightSky"] = "BlueNightSky"
		L["Contributors - BlueNightSky - Description"] = "翻譯者 — 正體中文"
		L["Contributors - Crazyyoungs"] = "Crazyyoungs"
		L["Contributors - Crazyyoungs - Description"] = "翻譯者 — 韓語"
		L["Contributors - Klep"] = "Klep"
		L["Contributors - Klep - Description"] = "翻譯者 — 法語"
		L["Contributors - Kroffy"] = "Kroffy"
		L["Contributors - Kroffy - Description"] = "翻譯者 — 法語"
		L["Contributors - cathtail"] = "cathtail"
		L["Contributors - cathtail - Description"] = "翻譯者 — 巴西葡萄牙語"
		L["Contributors - Larsj02"] = "Larsj02"
		L["Contributors - Larsj02 - Description"] = "翻譯者 — 德語"
		L["Contributors - dabear78"] = "dabear78"
		L["Contributors - dabear78 - Description"] = "翻譯者 — 德語"
		L["Contributors - y45853160"] = "y45853160"
		L["Contributors - y45853160 - Description"] = "代碼 — 測試錯誤修復"
		L["Contributors - lemieszek"] = "lemieszek"
		L["Contributors - lemieszek - Description"] = "代碼 — 測試錯誤修復"
		L["Contributors - BadBoyBarny"] = "BadBoyBarny"
		L["Contributors - BadBoyBarny - Description"] = "代碼 — 錯誤修復"
		L["Contributors - SyverGiswold"] = "SyverGiswold"
		L["Contributors - SyverGiswold - Description"] = "代碼 — 功能"
	end
end

NS:Load()
