---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Frame.ContextMenu; addon.C.Frame.ContextMenu = NS

--------------------------------

NS.Elements = {}

--------------------------------

function NS.Elements:Load()
	local Frame = addon.CS:GetCommonFrame()

	--------------------------------
	-- CREATE ELEMENTS
	--------------------------------

	do
		do -- ELEMENTS
			Frame.ContextMenu = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.ContextMenu", Frame)
			Frame.ContextMenu:SetPoint("CENTER", Frame)
			Frame.ContextMenu:SetFrameStrata(NS.Variables.FRAME_STRATA)
			Frame.ContextMenu:SetFrameLevel(NS.Variables.FRAME_LEVEL)
			addon.C.API.FrameUtil:SetDynamicSize(Frame.ContextMenu, Frame, 0, 0)

			local Frame_ContextMenu = Frame.ContextMenu

			--------------------------------

			do -- MAIN
				Frame_ContextMenu.Main = PrefabRegistry:Create("C.Frame.ContextMenu", Frame_ContextMenu, NS.Variables.FRAME_STRATA, NS.Variables.FRAME_LEVEL + 1, nil, "$parent.Main")
			end
		end

		do -- REFERENCES

		end
	end

	--------------------------------
	-- REFERENCES
	--------------------------------

	local Frame_ContextMenu = Frame.ContextMenu
	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- SETUP
	--------------------------------

	do
		Frame_ContextMenu.Main:Hide()
		Frame_ContextMenu.Main.hidden = true
	end
end
