---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.FrameTemplates; addon.C.FrameTemplates = NS

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do -- CONSTANTS

end

--------------------------------
-- TEMPLATES
--------------------------------

do
	-- Creates a horizontal progress bar.
	--
	-- Data Table:
	-- direction (string) -> "LEFT" or "RIGHT"
	function NS:CreateHorizontalProgressBar(parent, data, name)
		local direction = data.direction

		--------------------------------

		local ProgressBar = addon.C.FrameTemplates:CreateFrame("Frame", name, parent)

		--------------------------------

		do -- CONTENT
			ProgressBar.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", ProgressBar)
			ProgressBar.Content:SetAllPoints(ProgressBar)

			--------------------------------

			do -- PROGRESS BAR
				ProgressBar.Content.Bar = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Bar", ProgressBar.Content)
				addon.C.API.FrameUtil:SetDynamicSize(ProgressBar.Content.Bar, ProgressBar, false, 0, 0)

				if direction == "LEFT" then
					ProgressBar.Content.Bar:SetPoint("LEFT", ProgressBar.Content, 0, 0)
				else
					ProgressBar.Content.Bar:SetPoint("RIGHT", ProgressBar.Content, 0, 0)
				end
			end
		end

		do -- EVENTS
			ProgressBar.minValue = 0
			ProgressBar.maxValue = 1
			ProgressBar.value = .5

			ProgressBar.onMinMaxChangedCallback = {}
			ProgressBar.onValueChangedCallbacks = {}

			--------------------------------

			function ProgressBar:SetMinMaxValues(min, max)
				ProgressBar.minValue = min
				ProgressBar.maxValue = max

				--------------------------------

				do -- ON MIX MAX CHANGED
					local onMinMaxChangedCallback = ProgressBar.onMinMaxChangedCallback

					if #onMinMaxChangedCallback >= 1 then
						for i = 1, #onMinMaxChangedCallback do
							onMinMaxChangedCallback[i](ProgressBar, min, max)
						end
					end
				end
			end

			function ProgressBar:GetMinMaxValues()
				return ProgressBar.minValue, ProgressBar.maxValue
			end

			function ProgressBar:SetValue(value)
				ProgressBar.value = value
				ProgressBar:UpdateProgress()

				--------------------------------

				do -- ON VALUE CHANGED
					local onValueChangedCallbacks = ProgressBar.onValueChangedCallbacks

					if #onValueChangedCallbacks >= 1 then
						for i = 1, #onValueChangedCallbacks do
							onValueChangedCallbacks[i](ProgressBar, value)
						end
					end
				end
			end

			function ProgressBar:GetValue()
				return ProgressBar.value
			end

			function ProgressBar:UpdateProgress()
				local width = ProgressBar:GetWidth()
				local currentValue = ProgressBar.value
				local minValue = ProgressBar.minValue
				local maxValue = ProgressBar.maxValue

				local valueRange = maxValue - minValue
				local percentProgress = ((currentValue - minValue) / valueRange)
				local newWidth = width * percentProgress

				--------------------------------

				ProgressBar.Content.Bar:SetWidth(newWidth)
			end

			ProgressBar:HookScript("OnSizeChanged", ProgressBar.UpdateProgress)
		end

		--------------------------------

		return ProgressBar
	end
end
