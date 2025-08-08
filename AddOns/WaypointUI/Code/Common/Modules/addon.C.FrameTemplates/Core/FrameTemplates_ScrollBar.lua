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
	-- Creates a scrollbar.
	--
	-- Data Table:
	-- scrollFrame (frame)
	-- scrollFrameType (string) -> "scrollBoxList" or "scrollFrame"
	-- direction (string) -> "vertical" or "horizontal"
	function NS:CreateScrollBar(parent, data, name)
		local scrollFrame, scrollFrameType, direction = data.scrollFrame, data.scrollFrameType, data.direction

		--------------------------------

		local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name or "$parent.ScrollBar", parent)

		--------------------------------

		do -- ELEMENTS
			do -- CONTENT
				Frame.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Frame)
				Frame.Content:SetPoint("CENTER", Frame)
				addon.C.API.FrameUtil:SetDynamicSize(Frame.Content, Frame, 0, 0, true)

				--------------------------------

				do -- TRACK
					Frame.Content.Track = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Track", Frame.Content)
					Frame.Content.Track:SetPoint("CENTER", Frame.Content)
					addon.C.API.FrameUtil:SetDynamicSize(Frame.Content.Track, Frame.Content, 0, 0, true)
				end

				do -- THUMB
					Frame.Content.Thumb = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Thumb", Frame.Content)
					addon.C.API.FrameUtil:SetDynamicSize(Frame.Content.Thumb, Frame.Content, 0, nil, true)
				end
			end
		end

		do -- REFERENCES
			-- CORE
			Frame.REF_CONTENT = Frame.Content
			Frame.REF_TRACK = Frame.REF_CONTENT.Track
			Frame.REF_THUMB = Frame.REF_CONTENT.Thumb
		end

		do -- LOGIC
			Frame.isDragging = false
			Frame.value = nil

			local originX
			local originY
			local startX
			local startY

			--------------------------------

			local function Scrollbar_LimitThumbToFrame(thumb, boundaryFrame, restrictAxis)
				local point, relativeTo, relativePoint, offsetX, offsetY = thumb:GetPoint()
				local height = boundaryFrame:GetHeight()
				local width = boundaryFrame:GetWidth()

				local newX = offsetX
				local newY = offsetY

				--------------------------------

				if restrictAxis == "x" then
					if math.abs(offsetX) + thumb:GetWidth() > width then
						if offsetX < 0 then
							newX = -(width - thumb:GetWidth())
						else
							newX = width - thumb:GetWidth()
						end
					end

					if offsetX < 0 then
						newX = 0
					end

					--------------------------------

					thumb:ClearAllPoints()
					thumb:SetPoint("LEFT", boundaryFrame, newX, 0)

					--------------------------------

					local value = (newX) / (width - thumb:GetWidth())
					return value
				else
					if math.abs(offsetY) + thumb:GetHeight() > height then
						if offsetY < 0 then
							newY = -(height - thumb:GetHeight())
						else
							newY = height - thumb:GetHeight()
						end
					end

					if offsetY > 0 then
						newY = 0
					end

					--------------------------------

					thumb:ClearAllPoints()
					thumb:SetPoint("TOP", boundaryFrame, 0, newY)

					--------------------------------

					local value = (newY) / (height - thumb:GetHeight())
					return value
				end
			end

			local function GetMouseOffset(startX, startY)
				local offsetX, offsetY = addon.C.API.FrameUtil:GetMouseDelta(startX, startY)
				return offsetX, offsetY
			end

			local function Scrollbar_OnMouseDown()
				Frame.isDragging = true

				--------------------------------

				local point, relativeTo, relativePoint, offsetX, offsetY = Frame.Content.Thumb:GetPoint()
				originX = offsetX
				originY = offsetY

				--------------------------------

				startX, startY = GetCursorPosition()
			end

			local function Scrollbar_OnMouseUp()
				Frame.isDragging = false

				--------------------------------

				originX = nil
				originY = nil
				startX, startY = nil, nil
			end

			local function Scrollbar_OnUpdate()
				local verticalScrollRange = scrollFrame:GetContentHeight(true)
				local horizontalScrollRange = scrollFrame:GetContentWidth()

				local verticalScroll = scrollFrame.GetVerticalScroll and scrollFrame:GetVerticalScroll() or 0
				local horizontalScroll = scrollFrame.GetHorizontalScroll and scrollFrame:GetHorizontalScroll() or 0

				local contentHeight = scrollFrame:GetContentHeight()
				local contentWidth = scrollFrame:GetContentWidth()

				--------------------------------

				if (direction == "vertical" and verticalScrollRange > 0) or (direction == "horizontal" and horizontalScrollRange > 0) then
					if Frame.isDragging then
						local offsetX, offsetY = GetMouseOffset(startX, startY)

						--------------------------------

						Frame.Content.Thumb:ClearAllPoints()
						if direction == "horizontal" then
							Frame.Content.Thumb:SetPoint("LEFT", Frame, originX + (offsetX / Frame:GetEffectiveScale()), 0)
							Frame.value = Scrollbar_LimitThumbToFrame(Frame.Content.Thumb, Frame, "x")

							--------------------------------

							if scrollFrameType == "scrollBoxList" then
								scrollFrame:SetHorizontalScroll(math.abs((contentWidth - scrollFrame:GetWidth()) * Frame.value), true)
							else
								scrollFrame:SetHorizontalScroll((horizontalScrollRange) * Frame.value, true)
							end
						else
							Frame.Content.Thumb:SetPoint("TOP", Frame, 0, originY - (offsetY / Frame:GetEffectiveScale()))
							Frame.value = Scrollbar_LimitThumbToFrame(Frame.Content.Thumb, Frame, "y")

							--------------------------------

							if scrollFrameType == "scrollBoxList" then
								scrollFrame:SetVerticalScroll(math.abs((contentHeight - scrollFrame:GetHeight()) * Frame.value), true)
							else
								scrollFrame:SetVerticalScroll(math.abs((contentHeight) * Frame.value), true)
							end
						end
					else
						local frameHeight = Frame:GetHeight()
						local thumbHeight = Frame.Content.Thumb:GetHeight()
						local frameWidth = Frame:GetWidth()
						local thumbWidth = Frame.Content.Thumb:GetWidth()

						--------------------------------

						if scrollFrameType == "scrollBoxList" then
							if direction == "horizontal" then
								Frame.Content.Thumb:SetPoint("LEFT", Frame, (frameWidth - thumbWidth) * (horizontalScroll / horizontalScrollRange), 0)
							else
								Frame.Content.Thumb:SetPoint("TOP", Frame, 0, -(frameHeight - thumbHeight) * (verticalScroll / verticalScrollRange))
							end
						else
							if direction == "horizontal" then
								Frame.Content.Thumb:SetPoint("LEFT", Frame, (frameWidth - thumbWidth) * (horizontalScroll / horizontalScrollRange), 0)
							else
								Frame.Content.Thumb:SetPoint("TOP", Frame, 0, -(frameHeight - thumbHeight) * (verticalScroll / verticalScrollRange))
							end
						end
					end

					--------------------------------

					local newThumbSize = direction == "horizontal" and math.max(25, Frame:GetWidth() * (scrollFrame:GetWidth() / (scrollFrame:GetWidth() + contentWidth))) or math.max(25, Frame:GetHeight() * (scrollFrame:GetHeight() / (scrollFrame:GetHeight() + contentHeight)))

					if direction == "horizontal" then
						if newThumbSize < Frame:GetWidth() then
							Frame.Content.Thumb:Show()
							Frame.Content.Thumb:SetWidth(newThumbSize)
						else
							Frame.Content.Thumb:Hide()
						end
					else
						if newThumbSize < Frame:GetHeight() then
							Frame.Content.Thumb:Show()
							Frame.Content.Thumb:SetHeight(newThumbSize)
						else
							Frame.Content.Thumb:Hide()
						end
					end
				else
					Frame.Content.Thumb:Hide()
				end
			end

			--------------------------------

			Frame.Content.Thumb:HookScript("OnMouseDown", Scrollbar_OnMouseDown)
			Frame.Content.Thumb:HookScript("OnMouseUp", Scrollbar_OnMouseUp)
			Frame:SetScript("OnUpdate", Scrollbar_OnUpdate)
		end

		--------------------------------

		return Frame
	end
end
