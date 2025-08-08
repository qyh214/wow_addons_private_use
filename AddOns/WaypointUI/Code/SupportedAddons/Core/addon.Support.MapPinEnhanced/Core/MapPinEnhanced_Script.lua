---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.Support.MapPinEnhanced; addon.Support.MapPinEnhanced = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Frame = MapPinEnhancedSuperTrackedPin
	local Database = MapPinEnhancedDB
	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do
		do -- OVERRIDE
			function Callback:HideElements()
				if Frame then
					Frame:HookScript("OnShow", function()
						Frame:Hide()
					end)
				end
			end
		end

		do -- GET
			function Callback:GetSets()
				for set, setContent in pairs(Database.sets) do
					for pin, pinContent in pairs(setContent.pins) do
						-- Pin content
					end
				end
			end
		end

		do -- SET

		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	--------------------------------
	-- SETUP
	--------------------------------

	do
		Callback:HideElements()
	end
end
