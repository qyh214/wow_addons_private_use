-- Base Localization
-- Languages with no translations will default to this:

---@class addon
local addon = select(2, ...)
local L = addon.C.AddonInfo.Locales

--------------------------------

L.enUS = {}
local NS = L.enUS; L.enUS = NS

--------------------------------

function NS:Load()
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
		L["WaypointSystem - Pinpoint - Quest - Complete"] = "Ready for Turn-in"
	end

	--------------------------------
	-- SLASH COMMAND
	--------------------------------

	do
		L["SlashCommand - /way - Map ID - Prefix"] = "Current Map ID: "
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
		L["Config - General"] = "General"
		L["Config - General - Title"] = "General"
		L["Config - General - Title - Subtext"] = "Customize overall settings."
		L["Config - General - Preferences"] = "Preferences"
		L["Config - General - Preferences - Meter"] = "Use Meters instead of Yards"
		L["Config - General - Preferences - Meter - Description"] = "Changes the unit of measurement to Metric."
		L["Config - General - Preferences - Font"] = "Font"
		L["Config - General - Preferences - Font - Description"] = "The font used throughout the add-on."
		L["Config - General - Reset"] = "Reset"
		L["Config - General - Reset - Button"] = "Reset to Default"
		L["Config - General - Reset - Confirm"] = "Are you sure you want to reset all settings?"
		L["Config - General - Reset - Confirm - Yes"] = "Confirm"
		L["Config - General - Reset - Confirm - No"] = "Cancel"

		L["Config - WaypointSystem"] = "Waypoint"
		L["Config - WaypointSystem - Title"] = "Waypoint"
		L["Config - WaypointSystem - Title - Subtext"] = "Manage behavior of in-world marker and in-world objective pin."
		L["Config - WaypointSystem - Type"] = "Enable"
		L["Config - WaypointSystem - Type - Both"] = "All"
		L["Config - WaypointSystem - Type - Waypoint"] = "Waypoint"
		L["Config - WaypointSystem - Type - Pinpoint"] = "Pinpoint"
		L["Config - WaypointSystem - General"] = "General"
		L["Config - WaypointSystem - General - RightClickToClear"] = "Right-Click To Clear"
		L["Config - WaypointSystem - General - RightClickToClear - Description"] = "Allows you to clear the Waypoint/Pinpoint/Navigator by right-clicking it."
		L["Config - WaypointSystem - General - Transition Distance"] = "Pinpoint Distance"
		L["Config - WaypointSystem - General - Transition Distance - Description"] = "Distance before Pinpoint is shown."
		L["Config - WaypointSystem - General - Hide Distance"] = "Minimum Distance"
		L["Config - WaypointSystem - General - Hide Distance - Description"] = "Distance before hidden."
		L["Config - WaypointSystem - Waypoint"] = "Waypoint"
		L["Config - WaypointSystem - Waypoint - Footer - Type"] = "Additional Info"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Both"] = "All"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Distance"] = "Distance"
		L["Config - WaypointSystem - Waypoint - Footer - Type - ETA"] = "Arrival Time"
		L["Config - WaypointSystem - Waypoint - Footer - Type - None"] = "None"
		L["Config - WaypointSystem - Pinpoint"] = "Pinpoint"
		L["Config - WaypointSystem - Pinpoint - Info"] = "Show Info"
		L["Config - WaypointSystem - Pinpoint - Info - Extended"] = "Use Extended Info"
		L["Config - WaypointSystem - Pinpoint - Info - Extended - Description"] = "Such as name and description."
		L["Config - WaypointSystem - Navigator"] = "Navigator"
		L["Config - WaypointSystem - Navigator - Enable"] = "Show"
		L["Config - WaypointSystem - Navigator - Enable - Description"] = "When the Waypoint or Pinpoint is off-screen, the navigator will point at the direction."

		L["Config - Appearance"] = "Appearance"
		L["Config - Appearance - Title"] = "Appearance"
		L["Config - Appearance - Title - Subtext"] = "Customize the appearance of the user interface."
		L["Config - Appearance - Waypoint"] = "Waypoint"
		L["Config - Appearance - Waypoint - Scale"] = "Size"
		L["Config - Appearance - Waypoint - Scale - Description"] = "Size changes based on distance. This option sets the overall size."
		L["Config - Appearance - Waypoint - Scale - Min"] = "Minimum %"
		L["Config - Appearance - Waypoint - Scale - Min - Description"] = "Size can reduce to."
		L["Config - Appearance - Waypoint - Scale - Max"] = "Maximum %"
		L["Config - Appearance - Waypoint - Scale - Max - Description"] = "Size can enlarge to."
		L["Config - Appearance - Waypoint - Beam"] = "Show Beam"
		L["Config - Appearance - Waypoint - Beam - Alpha"] = "Transparency"
		L["Config - Appearance - Waypoint - Footer"] = "Show Info Text"
		L["Config - Appearance - Waypoint - Footer - Scale"] = "Size"
		L["Config - Appearance - Waypoint - Footer - Alpha"] = "Transparency"
		L["Config - Appearance - Pinpoint"] = "Pinpoint"
		L["Config - Appearance - Pinpoint - Scale"] = "Size"
		L["Config - Appearance - Navigator"] = "Navigator"
		L["Config - Appearance - Navigator - Scale"] = "Size"
		L["Config - Appearance - Navigator - Alpha"] = "Transparency"
		L['Config - Appearance - Navigator - Distance'] = "Distance"
		L["Config - Appearance - Visual"] = "Visual"
		L["Config - Appearance - Visual - UseCustomColor"] = "Use Custom Color"
		L["Config - Appearance - Visual - UseCustomColor - Color"] = "Color"
		L["Config - Appearance - Visual - UseCustomColor - TintIcon"] = "Tint Icon"
		L["Config - Appearance - Visual - UseCustomColor - Reset"] = "Reset"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Default"] = "Normal Quest"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Repeatable"] = "Repeatable Quest"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Important"] = "Important Quest"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Incomplete"] = "Incomplete Quest"
		L["Config - Appearance - Visual - UseCustomColor - Neutral"] = "Generic Waypoint"

		L["Config - Audio"] = "Audio"
		L["Config - Audio - Title"] = "Audio"
		L["Config - Audio - Title - Subtext"] = "Configuration for Waypoint UI audio effects."
		L["Config - Audio - General"] = "General"
		L["Config - Audio - General - EnableGlobalAudio"] = "Enable Audio"
		L["Config - Audio - Customize"] = "Customize"
		L["Config - Audio - Customize - UseCustomAudio"] = "Use Custom Audio"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID"] = "Sound ID"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID - Placeholder"] = "Custom ID"
		L["Config - Audio - Customize - UseCustomAudio - Preview"] = "Preview"
		L["Config - Audio - Customize - UseCustomAudio - Reset"] = "Reset"
		L["Config - Audio - Customize - UseCustomAudio - WaypointShow"] = "Show Waypoint"
		L["Config - Audio - Customize - UseCustomAudio - PinpointShow"] = "Show Pinpoint"

		L["Config - About"] = "About"
		L["Config - About - Contributors"] = "Contributors"
		L["Config - About - Developer"] = "Developer"
		L["Config - About - Developer - AdaptiveX"] = "AdaptiveX"
	end

	--------------------------------
	-- CONTRIBUTORS
	--------------------------------

	do
		L["Contributors - ZamestoTV"] = "ZamestoTV"
		L["Contributors - ZamestoTV - Description"] = "Translator — Russian"
		L["Contributors - huchang47"] = "huchang47"
		L["Contributors - huchang47 - Description"] = "Translator — Chinese (Simplified)"
		L["Contributors - BlueNightSky"] = "BlueNightSky"
		L["Contributors - BlueNightSky - Description"] = "Translator — Chinese (Traditional)"
		L["Contributors - Crazyyoungs"] = "Crazyyoungs"
		L["Contributors - Crazyyoungs - Description"] = "Translator — Korean"
		L["Contributors - Klep"] = "Klep"
		L["Contributors - Klep - Description"] = "Translator — French"
		L["Contributors - Kroffy"] = "Kroffy"
		L["Contributors - Kroffy - Description"] = "Translator — French"
		L["Contributors - cathtail"] = "cathtail"
		L["Contributors - cathtail - Description"] = "Translator - Brazilian Portuguese"
		L["Contributors - Larsj02"] = "Larsj02"
		L["Contributors - Larsj02 - Description"] = "Translator — German"
		L["Contributors - dabear78"] = "dabear78"
		L["Contributors - dabear78 - Description"] = "Translator - German"
		L["Contributors - y45853160"] = "y45853160"
		L["Contributors - y45853160 - Description"] = "Code — Beta Bug Fix"
		L["Contributors - lemieszek"] = "lemieszek"
		L["Contributors - lemieszek - Description"] = "Code — Beta Bug Fix"
		L["Contributors - BadBoyBarny"] = "BadBoyBarny"
		L["Contributors - BadBoyBarny - Description"] = "Code — Bug Fix"
		L["Contributors - SyverGiswold"] = "SyverGiswold"
		L["Contributors - SyverGiswold - Description"] = "Code - Feature"
	end
end

NS:Load()
