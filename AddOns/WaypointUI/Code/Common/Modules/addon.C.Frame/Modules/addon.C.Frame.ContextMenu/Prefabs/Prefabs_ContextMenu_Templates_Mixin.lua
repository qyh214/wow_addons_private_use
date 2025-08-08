---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales

--------------------------------
-- MIX-INS
--------------------------------

do  -- CONTEXT MENU
	do -- SELECTION
		do -- ELEMENT
			ContextMenu_Selection_Element = {}

			--------------------------------

			function ContextMenu_Selection_Element:OnLoad()
				self.ListElement = PrefabRegistry:Create("C.ContextMenu.Selection.Element", self, self:GetFrameStrata(), self:GetFrameLevel(), self:GetHeight() - 2.5, DeepInspectFrame.C.ContextMenu.Selection, "$parent.ListElement")
				self.ListElement:SetPoint("CENTER", self)
			end
		end
	end
end
