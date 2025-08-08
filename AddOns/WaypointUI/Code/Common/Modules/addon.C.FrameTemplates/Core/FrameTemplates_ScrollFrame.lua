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
	-- Creates scroll frame that supports horizontal or vertical scrolling.
	--
	-- Data Table:
	-- direction (string) -> "horizontal" or "vertical"
	-- stepSize (number)
	-- smoothScrollingRatio (number)
	---@param parent any
	---@param data table
	---@param name string
	---@param contentName string
	function NS:CreateScrollFrame(parent, data, name, contentName)
		local direction, stepSize, smoothScrollingRatio, customContent = data.direction, data.stepSize, data.smoothScrollingRatio, data.customContent

		--------------------------------

		local Frame = addon.C.FrameTemplates:CreateFrame("ScrollFrame", name, parent, "ScrollFrameTemplate")

		--------------------------------

		do -- ELEMENTS
			do -- CONTENT
				Frame.API_Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.API_Content", Frame)
				Frame.API_Content:SetAllPoints(Frame)
				Frame.API_Content:SetClipsChildren(true)
			end

			do -- SCROLL CHILD CONTENT
				if not customContent then
					Frame.API_Content.ScrollChildContentFrame = addon.C.FrameTemplates:CreateFrame("Frame", contentName .. "ContentFrame", Frame.API_Content)
					Frame.API_Content.ScrollChildContentFrame:SetPoint("TOP", Frame)

					--------------------------------

					if direction == "horizontal" then
						addon.C.API.FrameUtil:SetDynamicSize(Frame.API_Content.ScrollChildContentFrame, Frame, nil, 0, true)
					else
						addon.C.API.FrameUtil:SetDynamicSize(Frame.API_Content.ScrollChildContentFrame, Frame, 0, nil, true)
					end
				else
					Frame.API_Content.ScrollChildContentFrame = customContent
					Frame.API_Content.ScrollChildContentFrame:ClearAllPoints()
					Frame.API_Content.ScrollChildContentFrame:SetPoint("TOP", Frame)

					--------------------------------

					if direction == "horizontal" then
						addon.C.API.FrameUtil:SetDynamicSize(Frame.API_Content.ScrollChildContentFrame, Frame, nil, 0, true)
					else
						addon.C.API.FrameUtil:SetDynamicSize(Frame.API_Content.ScrollChildContentFrame, Frame, 0, nil, true)
					end
				end
			end

			do -- SCROLL CHILD
				Frame.API_Content.ScrollChildFrame = addon.C.FrameTemplates:CreateFrame("Frame", contentName, Frame.API_Content)
				Frame.API_Content.ScrollChildFrame:SetPoint("TOP", Frame)

				--------------------------------

				addon.C.API.FrameUtil:SetDynamicSize(Frame.API_Content.ScrollChildFrame, Frame.API_Content.ScrollChildContentFrame, 0, 0)

				--------------------------------

				if not customContent then
					Frame:SetScrollChild(Frame.API_Content.ScrollChildFrame)
				else
					Frame:SetScrollChild(Frame.API_Content.ScrollChildContentFrame)
				end
			end

			do -- SCROLL BAR
				if direction == "horizontal" then
					Frame.ScrollBar:Hide()
				end
			end
		end

		do -- LOGIC
			Frame.defaultScrollBar = Frame.ScrollBar
			Frame.stepSize = stepSize or 150

			Frame.onMouseWheelCallbacks = {}
			Frame.onSmoothScrollStartCallbacks = {}
			Frame.onSmoothScrollCallbacks = {}
			Frame.onSmoothScrollDestinationCallbacks = {}

			--------------------------------

			do -- FUNCTIONS
				do -- GET
					function Frame:GetContentWidth()
						return Frame.API_Content.ScrollChildFrame:GetWidth() - Frame:GetWidth()
					end

					function Frame:GetContentHeight()
						return Frame.API_Content.ScrollChildFrame:GetHeight() - Frame:GetHeight()
					end

					function Frame:GetVerticalScroll()
						local currentPoint, currentRelativeTo, currentRelativePoint, currentOffsetX, currentOffsetY = Frame.API_Content.ScrollChildContentFrame:GetPoint()

						--------------------------------

						return currentOffsetY
					end

					function Frame:GetHorizontalScroll()
						local currentPoint, currentRelativeTo, currentRelativePoint, currentOffsetX, currentOffsetY = Frame.API_Content.ScrollChildContentFrame:GetPoint()

						--------------------------------

						return currentOffsetX
					end

					function Frame:GetVerticalScrollPercentage()
						return Frame:GetVerticalScroll() / Frame:GetContentHeight()
					end

					function Frame:GetHorizontalScrollPercentage()
						return Frame:GetHorizontalScroll() / Frame:GetContentWidth()
					end
				end

				do -- SET
					function Frame:SetVerticalScroll(value, interpolate)
						local newScrollPosition = value
						newScrollPosition = math.min(newScrollPosition, Frame:GetVerticalScrollRange())
						newScrollPosition = math.max(newScrollPosition, 0)

						--------------------------------

						if interpolate then
							Frame.API_Content.ScrollChildFrame:ClearAllPoints()
							Frame.API_Content.ScrollChildFrame:SetPoint("TOP", Frame, 0, newScrollPosition)
						else
							Frame.API_Content.ScrollChildFrame:ClearAllPoints()
							Frame.API_Content.ScrollChildFrame:SetPoint("TOP", Frame, 0, newScrollPosition)
							Frame.API_Content.ScrollChildContentFrame:ClearAllPoints()
							Frame.API_Content.ScrollChildContentFrame:SetPoint("TOP", Frame, 0, newScrollPosition)
						end
					end

					function Frame:SetHorizontalScroll(value, interpolate)
						local newScrollPosition = value
						newScrollPosition = math.min(newScrollPosition, Frame:GetHorizontalScrollRange())
						newScrollPosition = math.max(newScrollPosition, 0)

						--------------------------------

						if interpolate then
							Frame.API_Content.ScrollChildFrame:ClearAllPoints()
							Frame.API_Content.ScrollChildFrame:SetPoint("LEFT", Frame, newScrollPosition, 0)
						else
							Frame.API_Content.ScrollChildFrame:ClearAllPoints()
							Frame.API_Content.ScrollChildFrame:SetPoint("LEFT", Frame, newScrollPosition, 0)
							Frame.API_Content.ScrollChildContentFrame:ClearAllPoints()
							Frame.API_Content.ScrollChildContentFrame:SetPoint("LEFT", Frame, newScrollPosition, 0)
						end
					end

					function Frame:ScrollToStart()
						Frame:SetVerticalScroll(0)
						Frame:SetHorizontalScroll(0)
					end

					function Frame:ScrollToEnd()
						local maxPosition = Frame:GetMaxVerticalScroll()
						Frame:SetVerticalScroll(maxPosition)

						local maxPosition = Frame:GetMaxHorizontalScroll()
						Frame:SetHorizontalScroll(maxPosition)
					end
				end
			end

			do -- SCROLLING
				Frame:SetScript("OnMouseWheel", function(self, delta)
					if direction == "vertical" then
						Frame:SetVerticalScroll(Frame:GetVerticalScroll() + (-Frame.stepSize * delta), true)

						--------------------------------

						if Frame.defaultScrollBar:IsShown() then
							Frame.defaultScrollBar.scrollPercentage = Frame:GetVerticalScrollPercentage()
						end
					elseif direction == "horizontal" then
						Frame:SetHorizontalScroll(Frame:GetHorizontalScroll() + (Frame.stepSize * delta))

						--------------------------------

						if Frame.defaultScrollBar:IsShown() then
							Frame.defaultScrollBar.scrollPercentage = Frame:GetHorizontalScrollPercentage()
						end
					end

					--------------------------------

					do -- ON SMOOTH SCROLL START
						if smoothScrollingRatio then
							C_Timer.After(.1, function()
								local onSmoothScrollStartCallbacks = Frame.onSmoothScrollStartCallbacks

								for callback = 1, #onSmoothScrollStartCallbacks do
									onSmoothScrollStartCallbacks[callback](self)
								end
							end, .1)
						end
					end

					do -- ON MOUSE WHEEL
						local onMouseWheelCallbacks = Frame.onMouseWheelCallbacks

						for callback = 1, #onMouseWheelCallbacks do
							onMouseWheelCallbacks[callback](self, delta)
						end
					end
				end)
			end

			do -- SMOOTH SCROLLING
				if smoothScrollingRatio then
					local isDestination = true

					Frame:SetScript("OnUpdate", function(self, elapsed)
						local targetPoint, targetRelativeTo, targetRelativePoint, targetOffsetX, targetOffsetY = Frame.API_Content.ScrollChildFrame:GetPoint()

						--------------------------------

						if direction == "vertical" then
							local currentPoint, currentRelativeTo, currentRelativePoint, currentOffsetX, currentOffsetY = Frame.API_Content.ScrollChildContentFrame:GetPoint()

							--------------------------------

							if (math.floor(currentOffsetY) == math.floor(targetOffsetY)) or (math.ceil(currentOffsetY) == math.ceil(targetOffsetY)) then
								if not isDestination then
									isDestination = true

									--------------------------------

									Frame.API_Content.ScrollChildContentFrame:SetPoint("TOP", Frame, 0, targetOffsetY)

									--------------------------------

									do -- ON SMOOTH SCROLL DESTINATION
										local onSmoothScrollDestinationCallbacks = Frame.onSmoothScrollDestinationCallbacks

										for callback = 1, #onSmoothScrollDestinationCallbacks do
											onSmoothScrollDestinationCallbacks[callback](self, targetOffsetY)
										end
									end
								end

								--------------------------------

								return
							end

							--------------------------------

							isDestination = false

							--------------------------------

							local delta = currentOffsetY - targetOffsetY
							local offset = delta > 0 and math.min(delta, delta * (1 / smoothScrollingRatio)) or math.max(delta, delta * (1 / smoothScrollingRatio))
							local newOffset = currentOffsetY - offset

							--------------------------------

							if delta < 0 then
								if newOffset >= targetOffsetY then
									newOffset = targetOffsetY
								end
							elseif delta > 0 then
								if newOffset <= targetOffsetY then
									newOffset = targetOffsetY
								end
							end

							--------------------------------

							Frame.API_Content.ScrollChildContentFrame:SetPoint("TOP", Frame, 0, newOffset)

							--------------------------------

							do -- ON SMOOTH SCROLL
								local onSmoothScrollCallbacks = Frame.onSmoothScrollCallbacks

								for callback = 1, #onSmoothScrollCallbacks do
									onSmoothScrollCallbacks[callback](self, newOffset)
								end
							end
						end

						if direction == "horizontal" then
							local currentPoint, currentRelativeTo, currentRelativePoint, currentOffsetX, currentOffsetY = Frame.API_Content.ScrollChildContentFrame:GetPoint()

							--------------------------------

							if (math.floor(currentOffsetX) == math.floor(targetOffsetX)) or (math.ceil(currentOffsetX) == math.ceil(targetOffsetX)) then
								if not isDestination then
									isDestination = true

									--------------------------------

									Frame.API_Content.ScrollChildContentFrame:SetPoint("LEFT", Frame, targetOffsetX, 0)

									--------------------------------

									do -- ON SMOOTH SCROLL DESTINATION
										local onSmoothScrollDestinationCallbacks = Frame.onSmoothScrollDestinationCallbacks

										for callback = 1, #onSmoothScrollDestinationCallbacks do
											onSmoothScrollDestinationCallbacks[callback](self, targetOffsetY)
										end
									end
								end

								--------------------------------

								return
							end

							--------------------------------

							isDestination = false

							--------------------------------

							local delta = currentOffsetX - targetOffsetX
							local offset = delta > 0 and math.min(delta, delta * (1 / smoothScrollingRatio)) or math.max(delta, delta * (1 / smoothScrollingRatio))
							local newOffset = currentOffsetX + offset

							--------------------------------

							if delta < 0 then
								if newOffset >= targetOffsetX then
									newOffset = targetOffsetX
								end
							elseif delta > 0 then
								if newOffset <= targetOffsetX then
									newOffset = targetOffsetX
								end
							end

							--------------------------------

							Frame.API_Content.ScrollChildContentFrame:SetPoint("LEFT", Frame, newOffset, 0)
						end
					end)
				else
					Frame.API_Content.ScrollChildContentFrame:ClearAllPoints()
					Frame.API_Content.ScrollChildContentFrame:SetPoint("TOP", Frame.API_Content.ScrollChildFrame, 0, 0)
				end
			end
		end

		--------------------------------

		return Frame, Frame.API_Content.ScrollChildContentFrame
	end

	-- Create a scroll box using WowScrollBoxList. Variables: ~.ScrollBar (EventFrame), ~.ScrollView (ScrollBoxListLinearView), ~.dataProvider (DataProvider), ~:SetData(data)
	--
	-- Data Table:
	-- prefabTemplate (string) -> Frame template XML
	-- elementCallback (function(frame, data))
	-- stepSize (number)
	-- smoothScrollingRatio (number)
	---@param parent any
	---@param data table
	---@param name string
	function NS:CreateScrollBox(parent, data, name)
		local prefabTemplate, elementCallback, stepSize, smoothScrollingRatio = data.prefabTemplate, data.elementCallback, data.stepSize, data.smoothScrollingRatio

		--------------------------------

		local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name, parent, "WowScrollBoxList")

		--------------------------------

		do -- ELEMENTS
			do -- SCROLL BAR
				Frame.ScrollBar = addon.C.FrameTemplates:CreateFrame("EventFrame", "ScrollBoxScrollBar", parent, "MinimalScrollBar")
				Frame.ScrollBar:SetPoint("TOPLEFT", Frame, "TOPRIGHT")
				Frame.ScrollBar:SetPoint("BOTTOMLEFT", Frame, "BOTTOMRIGHT")
			end

			do -- SCROLL VIEW
				Frame.ScrollView = CreateScrollBoxListLinearView()
			end
		end

		do -- LOGIC
			Frame.dataProvider = CreateDataProvider()
			Frame.ScrollView:SetDataProvider(Frame.dataProvider)

			ScrollUtil.InitScrollBoxListWithScrollBar(Frame, Frame.ScrollBar, Frame.ScrollView)

			Frame.ScrollView:SetElementInitializer(prefabTemplate, elementCallback)
		end

		do -- EVENTS
			Frame.targetScroll = 0
			Frame.stepSize = stepSize or 150

			Frame.onMouseWheelCallbacks = {}
			Frame.onSmoothScrollStartCallbacks = {}
			Frame.onSmoothScrollCallbacks = {}
			Frame.onSmoothScrollDestinationCallbacks = {}

			--------------------------------

			do -- FUNCTIONS
				function Frame:GetContentWidth()
					return Frame:GetWidth()
				end

				function Frame:GetContentHeight(factorVisibleExtent)
					return Frame:GetMaxVerticalScroll(factorVisibleExtent)
				end

				function Frame:SetData(data, resetPosition)
					Frame.dataProvider:Flush()
					Frame.dataProvider:InsertTable(data)

					--------------------------------

					if resetPosition then
						Frame:ScrollToStart()
					end
				end

				local function SetVerticalScroll_FirstElement(data)
					return data == Frame.dataProvider.collection[1]
				end

				function Frame:SetVerticalScroll(value, interpolate, isAnimation)
					if #Frame.dataProvider.collection >= 1 then
						if interpolate then
							Frame.targetScroll = value
						else
							if not isAnimation then
								Frame.targetScroll = value
							end

							Frame:ScrollToElementDataByPredicate(SetVerticalScroll_FirstElement, ScrollBoxConstants.AlignBegin, -value, true)
						end
					end
				end

				function Frame:GetVerticalScroll()
					if #Frame.dataProvider.collection >= 1 then
						return Frame:GetDerivedScrollOffset()
					else
						return 0
					end
				end

				function Frame:GetMaxVerticalScroll(factorVisibleExtent)
					if #Frame.dataProvider.collection >= 1 then
						return factorVisibleExtent and Frame.ScrollView:GetExtent() - Frame:GetVisibleExtent() or Frame.ScrollView:GetExtent()
					else
						return 0
					end
				end

				function Frame:ScrollToStart()
					Frame:SetVerticalScroll(0)
				end

				function Frame:ScrollToEnd()
					local maxPosition = Frame:GetMaxVerticalScroll()
					Frame:SetVerticalScroll(maxPosition)
				end

				function Frame:SetElementInfo(prefabTemplate, elementCallback)
					Frame.ScrollView:SetElementInitializer(prefabTemplate, elementCallback)
				end
			end

			do -- SCROLLING
				Frame:SetScript("OnMouseWheel", function(self, delta)
					local newScrollPosition = Frame.targetScroll + (-Frame.stepSize * delta)
					newScrollPosition = math.min(newScrollPosition, Frame:GetMaxVerticalScroll(true))
					newScrollPosition = math.max(newScrollPosition, 0)

					Frame:SetVerticalScroll(newScrollPosition, (smoothScrollingRatio ~= nil))

					--------------------------------

					do -- ON SMOOTH SCROLL START
						if smoothScrollingRatio then
							C_Timer.After(.1, function()
								local onSmoothScrollStartCallbacks = Frame.onSmoothScrollStartCallbacks

								for callback = 1, #onSmoothScrollStartCallbacks do
									onSmoothScrollStartCallbacks[callback](self)
								end
							end, .1)
						end
					end

					do -- ON MOUSE WHEEL
						local onMouseWheelCallbacks = Frame.onMouseWheelCallbacks

						for callback = 1, #onMouseWheelCallbacks do
							onMouseWheelCallbacks[callback](self, delta)
						end
					end
				end)
			end

			do -- SMOOTH SCROLLING
				if smoothScrollingRatio then
					local isDestination = true

					local _ = addon.C.FrameTemplates:CreateFrame("Frame", nil, Frame)
					_:SetScript("OnUpdate", function(self, elapsed)
						local targetOffsetY = Frame.targetScroll
						local currentOffsetY = Frame:GetVerticalScroll()

						--------------------------------

						if (math.floor(currentOffsetY) == math.floor(targetOffsetY)) or (math.ceil(currentOffsetY) == math.ceil(targetOffsetY)) then
							if not isDestination then
								isDestination = true

								--------------------------------

								do -- ON SMOOTH SCROLL DESTINATION
									local onSmoothScrollDestinationCallbacks = Frame.onSmoothScrollDestinationCallbacks

									for callback = 1, #onSmoothScrollDestinationCallbacks do
										onSmoothScrollDestinationCallbacks[callback](self, targetOffsetY)
									end
								end
							end

							--------------------------------

							return
						end

						--------------------------------

						isDestination = false

						--------------------------------

						local delta = currentOffsetY - targetOffsetY
						local offset = delta > 0 and math.min(delta, delta * (1 / smoothScrollingRatio)) or math.max(delta, delta * (1 / smoothScrollingRatio))
						local newOffset = currentOffsetY - offset

						--------------------------------

						if delta < 0 then
							if newOffset >= targetOffsetY then
								newOffset = targetOffsetY
							end
						elseif delta > 0 then
							if newOffset <= targetOffsetY then
								newOffset = targetOffsetY
							end
						end

						--------------------------------

						Frame:SetVerticalScroll(newOffset, false, true)

						--------------------------------

						do -- ON SMOOTH SCROLL
							local onSmoothScrollCallbacks = Frame.onSmoothScrollCallbacks

							for callback = 1, #onSmoothScrollCallbacks do
								onSmoothScrollCallbacks[callback](self, newOffset)
							end
						end
					end)
				end
			end
		end

		--------------------------------

		return Frame
	end
end
