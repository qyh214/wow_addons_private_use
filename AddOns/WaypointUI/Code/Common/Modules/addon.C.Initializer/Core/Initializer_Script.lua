---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Initializer; addon.C.Initializer = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do
		function Callback:LoadCode()
			do -- PRIORITY
				if addon.C.AddonInfo.Variables.Initializer.LIST_PRIORITY then
					addon.C.AddonInfo.Variables.Initializer.LIST_PRIORITY()
				end

				--------------------------------

				CallbackRegistry:Trigger("ADDON_LOADED_PRIORITY")
			end

			do -- MAIN
				C_Timer.After(.1, function()
					if addon.Main then
						addon.Main:Load()
					else
						print("|cffFF0000" .. addon.C.AddonInfo.Variables.General.IDENTIFIER .. " - Missing reference to 'addon.Main'|r")
					end

					--------------------------------

					CallbackRegistry:Trigger("ADDON_LOADED_CODE")
				end)
			end

			--------------------------------

			C_Timer.After(2.5, function()
				NS.Variables.Ready = true
				CallbackRegistry:Trigger("ADDON_LOADED")
			end)
		end

		function Callback:Initalize()
			if InCombatLockdown() then
				NS.Variables.QueuedForInitalization = true
				return
			end
			NS.Variables.QueuedForInitalization = false

			--------------------------------

			if NS.Variables.Initalized then
				return
			end
			NS.Variables.Initalized = true

			--------------------------------

			Callback:LoadCode()
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	do
		local Events = addon.C.FrameTemplates:CreateFrame("Frame")
		Events:RegisterEvent("PLAYER_REGEN_ENABLED")
		Events:SetScript("OnEvent", function(_, event, ...)
			if NS.Variables.QueuedForInitalization then
				if event == "PLAYER_REGEN_ENABLED" then
					if not InCombatLockdown() then
						Callback:Initalize()

						Events:UnregisterEvent("PLAYER_REGEN_ENABLED")
					end
				end
			end
		end)
	end

	--------------------------------
	-- SETUP
	--------------------------------

	do
		Callback:Initalize()
	end
end
