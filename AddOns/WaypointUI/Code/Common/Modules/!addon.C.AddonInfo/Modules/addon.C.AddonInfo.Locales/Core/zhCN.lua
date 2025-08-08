-- ♡ Translation // huchang47

---@class addon
local addon = select(2, ...)
local L = addon.C.AddonInfo.Locales

--------------------------------

L.zhCN = {}
local NS = L.zhCN; L.zhCN = NS

--------------------------------

function NS:Load()
	if GetLocale() ~= "zhCN" then
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
		L["WaypointSystem - Pinpoint - Quest - Complete"] = "可交任务"
	end

	--------------------------------
	-- SLASH COMMAND
	--------------------------------

	do
		L["SlashCommand - /way - Map ID - Prefix"] = "当前地图ID: "
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
		L["Config - General - Title - Subtext"] = "自定义全局设置。"
		L["Config - General - Preferences"] = "偏好设置"
		L["Config - General - Preferences - Meter"] = "单位使用米，而不是码"
		L["Config - General - Preferences - Meter - Description"] = "将度量单位更改为公制。"
		L["Config - General - Preferences - Font"] = "字体"
		L["Config - General - Preferences - Font - Description"] = "选择插件内使用的字体。"
		L["Config - General - Reset"] = "重置"
		L["Config - General - Reset - Button"] = "重置为默认设置"
		L["Config - General - Reset - Confirm"] = "你确定要重置所有设置吗？"
		L["Config - General - Reset - Confirm - Yes"] = "确定"
		L["Config - General - Reset - Confirm - No"] = "取消"

		L["Config - WaypointSystem"] = "路径点"
		L["Config - WaypointSystem - Title"] = "路径点"
		L["Config - WaypointSystem - Title - Subtext"] = "管理在世界状态时，任务目标点的行为。"
		L["Config - WaypointSystem - Type"] = "启用"
		L["Config - WaypointSystem - Type - Both"] = "所有"
		L["Config - WaypointSystem - Type - Waypoint"] = "路径点"
		L["Config - WaypointSystem - Type - Pinpoint"] = "标记点"
		L["Config - WaypointSystem - General"] = "通用"
		L["Config - WaypointSystem - General - RightClickToClear"] = "Right-Click To Clear"
		L["Config - WaypointSystem - General - RightClickToClear - Description"] = "Allows you to clear the Waypoint/Pinpoint/Navigator by right-clicking it."
		L["Config - WaypointSystem - General - Transition Distance"] = "标记点距离"
		L["Config - WaypointSystem - General - Transition Distance - Description"] = "标记点显示的最大距离。"
		L["Config - WaypointSystem - General - Hide Distance"] = "最小距离"
		L["Config - WaypointSystem - General - Hide Distance - Description"] = "超出距离后隐藏路径点和标记点。"
		L["Config - WaypointSystem - Waypoint"] = "路径点"
		L["Config - WaypointSystem - Waypoint - Footer - Type"] = "附加信息"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Both"] = "所有"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Distance"] = "距离"
		L["Config - WaypointSystem - Waypoint - Footer - Type - ETA"] = "到达时间"
		L["Config - WaypointSystem - Waypoint - Footer - Type - None"] = "无"
		L["Config - WaypointSystem - Pinpoint"] = "标记点"
		L["Config - WaypointSystem - Pinpoint - Info"] = "显示信息"
		L["Config - WaypointSystem - Pinpoint - Info - Extended"] = "显示扩展信息"
		L["Config - WaypointSystem - Pinpoint - Info - Extended - Description"] = "包含扩展的信息，例如名称和描述。"
		L["Config - WaypointSystem - Navigator"] = "导航"
		L["Config - WaypointSystem - Navigator - Enable"] = "显示"
		L["Config - WaypointSystem - Navigator - Enable - Description"] = "当路径点或标记点位于屏幕外，导航将会指示其方向。"

		L["Config - Appearance"] = "外观"
		L["Config - Appearance - Title"] = "外观"
		L["Config - Appearance - Title - Subtext"] = "自定义用户界面的外观。"
		L["Config - Appearance - Waypoint"] = "路径点"
		L["Config - Appearance - Waypoint - Scale"] = "路径点大小"
		L["Config - Appearance - Waypoint - Scale - Description"] = "路径点的大小会跟随距离变化。此选项用于调整整体大小。"
		L["Config - Appearance - Waypoint - Scale - Min"] = "最小百分比"
		L["Config - Appearance - Waypoint - Scale - Min - Description"] = "可缩小到的最小百分比。"
		L["Config - Appearance - Waypoint - Scale - Max"] = "最大百分比"
		L["Config - Appearance - Waypoint - Scale - Max - Description"] = "可放大到的最大百分比。"
		L["Config - Appearance - Waypoint - Beam"] = "显示光束"
		L["Config - Appearance - Waypoint - Beam - Alpha"] = "透明度"
		L["Config - Appearance - Waypoint - Footer"] = "显示信息文本"
		L["Config - Appearance - Waypoint - Footer - Scale"] = "大小"
		L["Config - Appearance - Waypoint - Footer - Alpha"] = "信息文本透明度"
		L["Config - Appearance - Pinpoint"] = "标记点"
		L["Config - Appearance - Pinpoint - Scale"] = "标记点大小"
		L["Config - Appearance - Navigator"] = "导航"
		L["Config - Appearance - Navigator - Scale"] = "大小"
		L["Config - Appearance - Navigator - Alpha"] = "透明度"
		L['Config - Appearance - Navigator - Distance'] = "Distance"
		L["Config - Appearance - Visual"] = "视觉"
		L["Config - Appearance - Visual - UseCustomColor"] = "使用自定义颜色"
		L["Config - Appearance - Visual - UseCustomColor - Color"] = "颜色"
		L["Config - Appearance - Visual - UseCustomColor - TintIcon"] = "图标染色"
		L["Config - Appearance - Visual - UseCustomColor - Reset"] = "重置"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Default"] = "普通任务"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Repeatable"] = "重复任务"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Important"] = "重要任务"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Incomplete"] = "未完成任务"
		L["Config - Appearance - Visual - UseCustomColor - Neutral"] = "通用路径点"

		L["Config - Audio"] = "音效"
		L["Config - Audio - Title"] = "音效"
		L["Config - Audio - Title - Subtext"] = "管理Waypoint UI的音效选项。"
		L["Config - Audio - General"] = "通用"
		L["Config - Audio - General - EnableGlobalAudio"] = "启用音效"
		L["Config - Audio - Customize"] = "自定义"
		L["Config - Audio - Customize - UseCustomAudio"] = "自定义音效"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID"] = "音效ID"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID - Placeholder"] = "自定义ID"
		L["Config - Audio - Customize - UseCustomAudio - Preview"] = "预览"
		L["Config - Audio - Customize - UseCustomAudio - Reset"] = "重置"
		L["Config - Audio - Customize - UseCustomAudio - WaypointShow"] = "显示路径点"
		L["Config - Audio - Customize - UseCustomAudio - PinpointShow"] = "显示标记点"

		L["Config - About"] = "关于"
		L["Config - About - Contributors"] = "贡献者"
		L["Config - About - Developer"] = "开发者"
		L["Config - About - Developer - AdaptiveX"] = "AdaptiveX"
	end

	--------------------------------
	-- CONTRIBUTORS
	--------------------------------

	do
		L["Contributors - ZamestoTV"] = "ZamestoTV"
		L["Contributors - ZamestoTV - Description"] = "翻译者 — 俄语"
		L["Contributors - huchang47"] = "huchang47"
		L["Contributors - huchang47 - Description"] = "翻译者 — 简体中文"
		L["Contributors - BlueNightSky"] = "BlueNightSky"
		L["Contributors - BlueNightSky - Description"] = "翻译者 — 繁体中文"
		L["Contributors - Crazyyoungs"] = "Crazyyoungs"
		L["Contributors - Crazyyoungs - Description"] = "翻译者 — 韩语"
		L["Contributors - Klep"] = "Klep"
		L["Contributors - Klep - Description"] = "翻译者 — 法语"
		L["Contributors - Kroffy"] = "Kroffy"
		L["Contributors - Kroffy - Description"] = "翻译者 — 法语"
		L["Contributors - cathtail"] = "cathtail"
		L["Contributors - cathtail - Description"] = "翻译者 - 巴西葡萄牙语"
		L["Contributors - Larsj02"] = "Larsj02"
		L["Contributors - Larsj02 - Description"] = "翻译者 — 德语"
		L["Contributors - dabear78"] = "dabear78"
		L["Contributors - dabear78 - Description"] = "翻译者 — 德语"
		L["Contributors - y45853160"] = "y45853160"
		L["Contributors - y45853160 - Description"] = "编码者 — 修复Bug"
		L["Contributors - lemieszek"] = "lemieszek"
		L["Contributors - lemieszek - Description"] = "编码者 — 修复Bug"
		L["Contributors - BadBoyBarny"] = "BadBoyBarny"
		L["Contributors - BadBoyBarny - Description"] = "编码者 — 修复Bug"
		L["Contributors - SyverGiswold"] = "SyverGiswold"
		L["Contributors - SyverGiswold - Description"] = "编码者 - 提交功能"
	end
end

NS:Load()
