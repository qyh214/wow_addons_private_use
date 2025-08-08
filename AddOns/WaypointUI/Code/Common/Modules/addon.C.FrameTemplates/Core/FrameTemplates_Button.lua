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
	-- Creates a button.
	---@param parent any
	---@param name string
	function NS:CreateButton(parent, name)
		local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name, parent)

		--------------------------------

		do -- ELEMENTS
			do -- CONTENT
				Frame.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Frame)
				Frame.Content:SetPoint("CENTER", Frame)
				addon.C.API.FrameUtil:SetDynamicSize(Frame.Content, Frame, 0, 0)
			end
		end

		do -- REFERENCES
			local Frame = Frame

			--------------------------------

			-- CORE
			Frame.REF_CONTENT = Frame.Content
		end

		do -- LOGIC
			Frame.isMouseOver = false
			Frame.isMouseDown = false
			Frame.enabled = true
			Frame.active = false

			Frame.onEnableCallbacks = {}
			Frame.onActiveCallbacks = {}
			Frame.enterCallbacks = {}
			Frame.leaveCallbacks = {}
			Frame.mouseDownCallbacks = {}
			Frame.mouseUpCallbacks = {}
			Frame.clickCallbacks = {}

			--------------------------------

			do -- FUNCTIONS
				do -- SET
					function Frame:SetEnabled(value)
						Frame.enabled = value
						Frame:EnableMouse(value)

						--------------------------------

						do -- ON ENABLE
							local onEnableCallbacks = Frame.onEnableCallbacks

							if #onEnableCallbacks >= 1 then
								for callback = 1, #onEnableCallbacks do
									onEnableCallbacks[callback](Frame, value)
								end
							end
						end

						--------------------------------

						do -- APPEARANCE STATE
							if value == true then
								Frame.Content:SetAlpha(1)
							else
								Frame.Content:SetAlpha(.5)
							end
						end
					end

					function Frame:SetActive(value)
						Frame.active = value

						--------------------------------

						do -- ON ACTIVE
							local onActiveCallbacks = Frame.onActiveCallbacks

							if #onActiveCallbacks >= 1 then
								for callback = 1, #onActiveCallbacks do
									onActiveCallbacks[callback](Frame, value)
								end
							end
						end
					end

					function Frame:SetClick(callback)
						Frame.clickCallbacks = {}
						table.insert(Frame.clickCallbacks, callback)
					end
				end

				do -- LOGIC

				end
			end

			do -- EVENTS
				function Frame:OnEnter()
					if Frame.enabled then
						Frame.isMouseOver = true

						--------------------------------

						do -- MOUSE ENTER
							local enterCallbacks = Frame.enterCallbacks

							if #enterCallbacks >= 1 then
								for callback = 1, #enterCallbacks do
									enterCallbacks[callback](Frame)
								end
							end
						end
					end
				end

				function Frame:OnLeave(skipAnimation)
					if Frame.enabled then
						Frame.isMouseOver = false

						--------------------------------

						do -- MOUSE LEAVE
							local leaveCallbacks = Frame.leaveCallbacks

							if #leaveCallbacks >= 1 then
								for callback = 1, #leaveCallbacks do
									leaveCallbacks[callback](Frame, skipAnimation)
								end
							end
						end
					end
				end

				function Frame:OnMouseDown(skipAnimation)
					if Frame.enabled then
						Frame.isMouseDown = true

						--------------------------------

						do -- MOUSE DOWN
							local mouseDownCallbacks = Frame.mouseDownCallbacks

							if #mouseDownCallbacks >= 1 then
								for callback = 1, #mouseDownCallbacks do
									mouseDownCallbacks[callback](Frame, skipAnimation)
								end
							end
						end
					end
				end

				function Frame:OnMouseUp(skipAnimation)
					if Frame.enabled then
						Frame.isMouseDown = false

						--------------------------------

						do -- MOUSE UP
							local mouseUpCallbacks = Frame.mouseUpCallbacks

							if #mouseUpCallbacks >= 1 then
								for callback = 1, #mouseUpCallbacks do
									mouseUpCallbacks[callback](Frame, skipAnimation)
								end
							end
						end

						do -- CLICK
							local clickCallbacks = Frame.clickCallbacks

							if #clickCallbacks >= 1 then
								for callback = 1, #clickCallbacks do
									clickCallbacks[callback](Frame)
								end
							end
						end
					end
				end

				Frame:SetScript("OnEnter", function() Frame:OnEnter() end)
				Frame:SetScript("OnLeave", function() Frame:OnLeave() end)
				Frame:SetScript("OnMouseDown", function() Frame:OnMouseDown() end)
				Frame:SetScript("OnMouseUp", function() Frame:OnMouseUp() end)
			end
		end

		do -- SETUP

		end

		--------------------------------

		return Frame
	end
end
