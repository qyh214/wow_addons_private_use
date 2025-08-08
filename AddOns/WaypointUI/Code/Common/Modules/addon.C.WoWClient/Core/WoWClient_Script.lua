---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.WoWClient; addon.C.WoWClient = NS

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
		do -- ADD-ONS
			function Callback:GetLoadedAddons()
				local numAddons = C_AddOns.GetNumAddOns()

				for i = 1, numAddons do
					local name, title, notes, loadable, reason, security, updateAvailable = C_AddOns.GetAddOnInfo(i)
					table.insert(NS.Variables.LOADED_ADDONS, name)
				end
			end

			function Callback:IsAddOnLoaded(name)
				return C_AddOns.IsAddOnLoaded(name)
			end
		end
	end

	--------------------------------
	-- SETUP
	--------------------------------

	do
		Callback:GetLoadedAddons()
	end
end
