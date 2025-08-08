---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.Query; addon.Query = NS

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
		function Callback:GetSuperTrackedMapElement()
			for i = 1, WorldMapFrame.ScrollContainer.Child:GetNumChildren() do
				local element = select(i, WorldMapFrame.ScrollContainer.Child:GetChildren())

				--------------------------------

				if element.selected == true or element.superTracked == true or element.isSuperTracked == true then
					return element
				end
			end
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	--------------------------------
	-- SETUP
	--------------------------------
end
