---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Frame.ContextMenu; addon.C.Frame.ContextMenu = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	local Frame = addon.CS:GetCommonFrame()

	--------------------------------
	-- REFERENCES
	--------------------------------

	local Frame_ContextMenu = Frame.ContextMenu
	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do
		do -- MAIN
			function Callback:Main_Show(data)
				local parent, buttonParent, point, relativePoint, offsetX, offsetY, width, layoutInfo = data.parent, data.buttonParent, data.point, data.relativePoint, data.offsetX, data.offsetY, data.width, data.layoutInfo

				--------------------------------

				Frame_ContextMenu.Main:SetPoint(point, parent, relativePoint, offsetX, offsetY)
				Frame_ContextMenu.Main:SetWidth(width)
				Frame_ContextMenu.Main:SetLayout(layoutInfo)
				Frame_ContextMenu.Main:SetButtonParent(buttonParent)

				--------------------------------

				Frame_ContextMenu.Main:ShowWithAnimation()
			end

			function Callback:Main_Hide()
				Frame_ContextMenu.Main:HideWithAnimation()
			end

			function Callback:Main_IsShown()
				return Frame_ContextMenu.Main:IsShown()
			end
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	do

	end

	--------------------------------
	-- SETUP
	--------------------------------

	do

	end
end
