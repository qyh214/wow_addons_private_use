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
-- FUNCTIONS
--------------------------------

do
	-- Default layout sort function.
	--
	-- Data Table
	-- point (string)
	-- direction (string) -> "vertical" or "horizontal"
	-- resize (boolean)
	-- padding (number)
	-- distribute (boolean)
	-- headerCallback (function(frame, element))
	-- footerCallback (function(frame, element))
	-- customOffset (function(frame, element, direction, currentOffset))
	---@param frame any
	---@param data table
	function NS:DefaultLayoutSort(frame, data)
		local point, direction, resize, padding, distribute, distributeResizeElements, excludeHidden, headerCallback, footerCallback, customOffset = data.point, data.direction, data.resize, data.padding, data.distribute, data.distributeResizeElements, data.excludeHidden, data.headerCallback, data.footerCallback, data.customOffset

		--------------------------------

		local FRAME_WIDTH = frame:GetWidth()
		local FRAME_HEIGHT = frame:GetHeight()

		local AllElements = frame.Sort_Elements
		local Elements = {}
		for i = 1, #AllElements do
			if AllElements[i]:IsShown() or not excludeHidden then
				table.insert(Elements, AllElements[i])
			end
		end

		--------------------------------

		if distribute then
			if distributeResizeElements then
				for i = 1, #Elements do
					if direction == "vertical" then
						Elements[i]:SetHeight((FRAME_HEIGHT / #Elements) - ((#Elements > 1) and padding / 2 or 0))
					else
						Elements[i]:SetWidth((FRAME_WIDTH / #Elements) - ((#Elements > 1) and padding / 2 or 0))
					end
				end
			end

			--------------------------------

			if direction == "vertical" then
				local numElements = 0
				local totalElementsHeight = 0

				for i = 1, #Elements do
					if Elements[i]:IsShown() or not excludeHidden then
						local element = Elements[i]

						--------------------------------

						if element.GetHeight then
							totalElementsHeight = totalElementsHeight + element:GetHeight()
						end

						--------------------------------

						numElements = numElements + 1
					end
				end

				--------------------------------

				local containerHeight = frame:GetHeight()
				local gap = (numElements > 1) and ((containerHeight - totalElementsHeight) / (numElements - 1)) or 0

				local offset = 0
				local elementIndex = 0

				for i = 1, #Elements do
					if Elements[i]:IsShown() or not excludeHidden then
						local element = Elements[i]
						elementIndex = elementIndex + 1

						--------------------------------

						element:ClearAllPoints()
						element:SetPoint(point, frame.Content, 0, -offset)

						--------------------------------

						if headerCallback and elementIndex == 1 then
							headerCallback(frame, element)
						end

						if footerCallback and elementIndex == numElements then
							footerCallback(frame, element)
						end

						--------------------------------

						if element.GetHeight then
							offset = offset + element:GetHeight()
						end

						if elementIndex < numElements then
							offset = offset + gap
						end
					end
				end
			elseif direction == "horizontal" then
				local numElements = #Elements
				local totalElementsWidth = 0

				for i = 1, #Elements do
					local element = Elements[i]

					--------------------------------

					if element.GetWidth then
						totalElementsWidth = totalElementsWidth + element:GetWidth()
					end
				end

				--------------------------------

				local containerWidth = frame:GetWidth()
				local gap = (numElements > 1) and ((containerWidth - totalElementsWidth) / (numElements - 1)) or 0

				local offset = 0

				for i = 1, #Elements do
					local element = Elements[i]

					--------------------------------

					element:ClearAllPoints()
					element:SetPoint(point, frame.Content, offset, 0)

					--------------------------------

					if headerCallback and i == 1 then
						headerCallback(frame, element)
					end

					if footerCallback and i == numElements then
						footerCallback(frame, element)
					end

					--------------------------------

					if element.GetWidth then
						offset = offset + element:GetWidth()
					end

					if i < numElements then
						offset = offset + gap
					end
				end
			end
		else
			local PADDING = padding
			local offset = 0

			--------------------------------

			for i = 1, #Elements do
				if Elements[i]:IsShown() or not excludeHidden then
					local element = Elements[i]

					--------------------------------

					if headerCallback and i == 1 then
						headerCallback(frame, element)
					end

					if footerCallback and i == #Elements then
						footerCallback(frame, element)
					end

					--------------------------------

					element:ClearAllPoints()

					if customOffset then
						local offsetX, offsetY = customOffset(frame, element, direction, -offset)

						--------------------------------

						element:SetPoint(point, frame.Content, offsetX, offsetY)
					else
						if direction == "vertical" then
							element:SetPoint(point, frame.Content, 0, -offset)
						else
							element:SetPoint(point, frame.Content, offset, 0)
						end
					end

					--------------------------------

					if direction == "vertical" and element.GetHeight then
						if i < #Elements then
							offset = offset + element:GetHeight() + PADDING
						else
							offset = offset + element:GetHeight()
						end
					elseif element.GetWidth then
						if i < #Elements then
							offset = offset + element:GetWidth() + PADDING
						else
							offset = offset + element:GetWidth()
						end
					end
				end
			end

			--------------------------------

			if resize then
				if direction == "vertical" then
					frame:SetHeight(offset)
				else
					frame:SetWidth(offset)
				end
			end
		end
	end

	-- Grid layout sort function.
	--
	-- Data Table:
	-- point (string)
	-- direction (string) -> "horizontal" (fill rows left-to-right) or "vertical" (fill columns top-to-bottom)
	-- resize (table) -> { maxWidth = (number | function), maxHeight = (number | function) }
	-- padding (number)
	-- distribute (boolean)
	-- headerCallback (function(frame, element))
	-- footerCallback (function(frame, element))
	-- customOffset (function(frame, element, direction, currentX, currentY))
	--
	-- Custom Data Table:
	-- columns (number)
	---@param frame any
	---@param data table
	---@param customData table
	function NS:GridLayoutSort(frame, data, customData)
		local point, direction, resize, padding, distribute, excludeHidden, headerCallback, footerCallback, customOffset = data.point, data.direction, data.resize, data.padding, data.distribute, data.excludeHidden, data.headerCallback, data.footerCallback, data.customOffset

		--------------------------------

		local Elements = frame.Sort_Elements

		--------------------------------

		if distribute then
			if direction == "horizontal" then
				local containerWidth = frame:GetWidth()
				local containerHeight = frame:GetHeight()

				--------------------------------

				local numElements = 0
				local rowInfo = {}

				--------------------------------

				do -- VISIBLE ELEMENTS
					for i = 1, #Elements do
						if Elements[i]:IsShown() or not excludeHidden then
							numElements = numElements + 1
						end
					end
				end

				do -- ROWS
					local rowElements = {}
					local rowOffsetX = 0
					local rowTotalElementWidth = 0

					for i = 1, numElements do
						local element = Elements[i]
						local nextElement = Elements[i + 1] or nil

						local nextElementWidth = (nextElement and nextElement:GetWidth()) or 0

						--------------------------------

						local newOffsetX = rowOffsetX + element:GetWidth()
						local isOverflow = ((newOffsetX + nextElementWidth) >= containerWidth)
						local isLastElementInList = (i == numElements)

						if isOverflow or isLastElementInList then
							table.insert(rowElements, element)
							rowOffsetX = rowOffsetX + element:GetWidth() + padding

							--------------------------------

							rowTotalElementWidth = rowOffsetX - padding

							--------------------------------

							local row = {
								["elements"] = rowElements,
								["offsetX"] = (containerWidth - rowTotalElementWidth) / 2,
								["totalElementWidth"] = rowTotalElementWidth,
							}

							table.insert(rowInfo, row)

							--------------------------------

							rowElements = {}
							rowOffsetX = 0
							rowTotalElementWidth = 0
						else
							table.insert(rowElements, element)

							--------------------------------

							rowOffsetX = rowOffsetX + element:GetWidth() + padding
						end
					end
				end

				do -- OFFSET Y
					local totalElementHeight = 0
					local offsetY = 0

					--------------------------------

					for i = 1, #rowInfo do
						if i == #rowInfo then
							totalElementHeight = totalElementHeight + rowInfo[i].elements[#rowInfo[i].elements]:GetHeight()
						else
							totalElementHeight = totalElementHeight + rowInfo[i].elements[1]:GetHeight() + padding
						end
					end

					offsetY = (containerHeight - totalElementHeight) / 2

					--------------------------------

					for i = 1, #rowInfo do
						rowInfo[i].offsetY = offsetY
					end
				end

				do -- ELEMENTS
					local offsetX = 0
					local offsetY = 0

					for i = 1, #rowInfo do
						offsetX = 0

						--------------------------------

						local row = rowInfo[i]
						local rowElements = row.elements
						local rowOffsetX = row.offsetX
						local rowOffsetY = row.offsetY

						------------------------------

						for x = 1, #rowElements do
							local element = rowElements[x]
							local nextElement = rowElements[x + 1] or nil

							local nextElementWidth = (nextElement and nextElement:GetWidth()) or 0

							--------------------------------

							if headerCallback and element == 1 then
								headerCallback(frame, element)
							end
							if footerCallback and element == #rowElements then
								footerCallback(frame, element)
							end

							--------------------------------

							element:ClearAllPoints()
							element:SetPoint(point, frame, (rowOffsetX + offsetX), -(rowOffsetY + offsetY))

							--------------------------------

							local newOffsetX = offsetX + element:GetWidth()
							local isOverflow = ((newOffsetX + nextElementWidth) >= containerWidth)
							local isLastElementInRow = (x == #rowElements)

							if isOverflow or isLastElementInRow then
								offsetX = 0
								offsetY = offsetY + element:GetHeight() + padding
							else
								offsetX = offsetX + element:GetWidth() + padding
							end
						end
					end
				end
			end
		else
			if direction == "horizontal" then
				if resize then
					if resize.maxWidth then
						if type(resize.maxWidth) == "function" then
							frame:SetWidth(resize.maxWidth())
						else
							frame:SetWidth(resize.maxWidth)
						end
					end

					if resize.maxHeight then
						if type(resize.maxHeight) == "function" then
							frame:SetHeight(resize.maxHeight())
						else
							frame:SetHeight(resize.maxHeight)
						end
					end
				end

				--------------------------------

				local containerWidth = frame:GetWidth()

				--------------------------------

				local numElements = 0
				local offsetX = 0
				local offsetY = 0

				local maxWidth = 0
				local maxHeight = 0

				--------------------------------

				do -- VISIBLE ELEMENTS
					for i = 1, #Elements do
						if Elements[i]:IsShown() or not excludeHidden then
							numElements = numElements + 1
						end
					end
				end

				do -- ELEMENTS
					for i = 1, numElements do
						if Elements[i]:IsShown() or not excludeHidden then
							local element = Elements[i]
							local nextElement = Elements[i + 1] or nil

							local nextElementWidth = (nextElement and nextElement:GetWidth()) or 0

							--------------------------------

							if headerCallback and i == 1 then
								headerCallback(frame, element)
							end
							if footerCallback and i == #Elements then
								footerCallback(frame, element)
							end

							--------------------------------

							element:ClearAllPoints()
							element:SetPoint(point, frame, offsetX, -offsetY)

							--------------------------------

							local newOffsetX = offsetX + element:GetWidth()
							local isOverflow = ((newOffsetX + nextElementWidth) >= containerWidth)
							local isLastElementInList = (i == numElements)

							if isOverflow then
								offsetX = 0
								offsetY = offsetY + element:GetHeight() + padding

								--------------------------------

								if offsetY > maxHeight then
									maxHeight = offsetY
								end
							else
								if isLastElementInList then
									offsetY = offsetY + element:GetHeight() + padding

									--------------------------------

									if offsetY > maxHeight then
										maxHeight = offsetY
									end
								end

								--------------------------------

								offsetX = offsetX + element:GetWidth() + padding

								--------------------------------

								if offsetX > maxWidth then
									maxWidth = offsetX
								end
							end
						end
					end

					--------------------------------

					if offsetY <= 0 then
						maxHeight = Elements[1]:GetHeight()
					else
						maxHeight = maxHeight - padding
					end
				end

				--------------------------------

				if resize then
					frame:SetWidth(maxWidth)
					frame:SetHeight(maxHeight)
				end
			end
		end
	end
end

--------------------------------
-- TEMPLATES
--------------------------------

do
	-- Creates a layout group. Variables: ~:Sort(), ~:AddElement(element), ~:RemoveElement(element)
	--
	-- Data Table
	-- point (string)
	-- direction (string) -> "vertical" or "horizontal"
	-- resize (boolean)
	-- resizeElements (boolean)
	-- padding (number)
	-- distribute (boolean)
	-- headerCallback (function(frame, element))
	-- footerCallback (function(frame, element))
	-- autoSort (boolean)
	-- customOffset (function(frame, element, direction, currentOffset))
	-- customLayoutSort (string) -> string to match the function name
	-- customLayoutSort_data (table)
	---@param parent any
	---@param data table
	---@param name string
	---@return any Frame
	---@return function Sort
	function NS:CreateLayoutGroup(parent, data, name)
		local point, direction, resize, padding, distribute, distributeResizeElements, excludeHidden, headerCallback, footerCallback, autoSort, customOffset, customLayoutSort, customLayoutSort_data = data.point, data.direction, data.resize, data.padding, data.distribute, data.distributeResizeElements, data.excludeHidden, data.headerCallback, data.footerCallback, data.autoSort, data.customOffset, data.customLayoutSort, data.customLayoutSort_data

		--------------------------------

		local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name, parent)

		--------------------------------

		do -- CONTENT
			Frame.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Frame)
			Frame.Content:SetAllPoints(Frame)
		end

		do -- LOGIC
			Frame.Sort_Elements = {}

			--------------------------------

			do -- FUNCTIONS
				do -- SET
					function Frame:Sort()
						if customLayoutSort then
							NS[customLayoutSort](self, Frame, data, customLayoutSort_data)
						else
							NS:DefaultLayoutSort(Frame, data)
						end
					end

					function Frame:AddElement(element)
						table.insert(Frame.Sort_Elements, element)

						--------------------------------

						if autoSort then
							Frame:Sort()
						end
					end

					function Frame:RemoveElement(element)
						addon.C.API.Util:FindValuePositionInTable(Frame.Sort_Elements, element)

						--------------------------------

						if autoSort then
							Frame:Sort()
						end
					end

					function Frame:ClearAllElements()
						Frame.Sort_Elements = {}
					end

					function Frame:GetElements()
						return Frame.Sort_Elements
					end
				end
			end

			do -- EVENTS

			end
		end

		--------------------------------

		return Frame, Frame.Sort
	end
end
