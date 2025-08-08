---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.API; addon.C.API = NS

--------------------------------
-- VARIABLES
--------------------------------

NS.FrameUtil = {}

do -- MAIN

end

do -- CONSTANTS

end

--------------------------------
-- FRAME
--------------------------------

do
	-- Anchors a frame to the center of its parent.
	---@param frame any
	---@param avoidButton? boolean: Whether to avoid anchoring to a button.
	function NS.FrameUtil:AnchorToCenter(frame, avoidButton)
		if not frame or not frame:GetParent() then
			return
		end

		--------------------------------

		local Parent = frame:GetParent()

		--------------------------------

		local function IsButton(_frame)
			if NS.Util:FindString(_frame:GetDebugName(), "Button") == true then
				IsButton(_frame:GetParent())
			else
				return _frame
			end
		end

		--------------------------------

		if avoidButton then
			Parent = IsButton(Parent)
		end

		local NewAnchor = CreateFrame("Frame", nil, Parent)
		NewAnchor:SetPoint(frame:GetPoint())
		NewAnchor:SetSize(frame:GetSize())

		--------------------------------

		frame:ClearAllPoints()
		frame:SetPoint("CENTER", NewAnchor, "CENTER")
	end

	-- Sets the visibility of a frame with a boolean value.
	---@param frame any
	---@param visibility boolean
	function NS.FrameUtil:SetVisibility(frame, visibility)
		if visibility then
			frame:Show()
		else
			frame:Hide()
		end
	end

	-- Returns the mouse delta from the origin point.
	---@param originX number
	---@param originY number
	---@return deltaX number
	---@return deltaY number
	function NS.FrameUtil:GetMouseDelta(originX, originY)
		if not originX or not originY then
			return nil, nil
		end

		--------------------------------

		local mouseX, mouseY = GetCursorPosition()
		local frameX = originX
		local frameY = originY

		--------------------------------

		local deltaX = (mouseX - frameX)
		local deltaY = (frameY - mouseY) -- Invert Y axis because WoW's coordinate system has Y increasing upwards.

		--------------------------------

		return deltaX, deltaY
	end

	-- Sets the value of a variable to all children of a frame.
	---@param frame any
	---@param variable string
	---@param value any
	function NS.FrameUtil:SetAllVariablesToChildren(frame, variable, value)
		for f1 = 1, frame:GetNumChildren() do
			local _frameIndex1 = select(f1, frame:GetChildren())

			--------------------------------

			if _frameIndex1.GetNumChildren and _frameIndex1:GetNumChildren() > 0 then
				NS.FrameUtil:SetAllVariablesToChildren(_frameIndex1, variable, value)
			end

			--------------------------------

			_frameIndex1[variable] = value
		end
	end

	-- Calls a function to all children of a frame.
	---@param frame any
	---@param func function
	function NS.FrameUtil:CallFunctionToAllChildren(frame, func)
		for f1 = 1, frame:GetNumChildren() do
			local _frameIndex1 = select(f1, frame:GetChildren())

			--------------------------------

			if _frameIndex1.GetNumChildren and _frameIndex1:GetNumChildren() > 0 then
				NS.FrameUtil:CallFunctionToAllChildren(_frameIndex1, func)
			end

			--------------------------------

			func(_frameIndex1)
		end
	end

	function NS.FrameUtil:IsFrameVisibleInScrollFrame(scrollFrame, element)
		local scrollFrameLeft = scrollFrame:GetLeft()
		local scrollFrameRight = scrollFrame:GetRight()
		local scrollFrameTop = scrollFrame:GetTop()
		local scrollFrameBottom = scrollFrame:GetBottom()

		local elementLeft = element:GetLeft()
		local elementRight = element:GetRight()
		local elementTop = element:GetTop()
		local elementBottom = element:GetBottom()

		return (
			elementLeft and elementRight and elementTop and elementBottom and

			elementRight > scrollFrameLeft - element:GetWidth() and
			elementLeft < scrollFrameRight + element:GetWidth() and
			elementBottom > scrollFrameBottom - element:GetHeight() and
			elementTop < scrollFrameTop + element:GetHeight()
		)
	end
end

--------------------------------
-- FRAME (DYNAMIC)
--------------------------------

do
	-- Sets the size of the specified frame to match the relative frame with padding. Set paddingX/paddingY to a function(relativeWidth, relativeHeight) to apply custom sizing calculations.
	---@param frame any
	---@param relativeTo any
	---@param paddingX? number|function
	---@param paddingY? number|function
	---@param updateAll? boolean
	function NS.FrameUtil:SetDynamicSize(frame, relativeTo, paddingX, paddingY, updateAll, updateFrame)
		local function UpdateSize()
			if paddingX then
				local newWidth = nil

				--------------------------------

				if type(paddingX) == "function" then
					newWidth = paddingX(relativeTo:GetWidth(), relativeTo:GetHeight())
				else
					newWidth = relativeTo:GetWidth() - paddingX
				end

				--------------------------------

				frame:SetWidth(newWidth)
			end

			if paddingY then
				local newHeight = nil

				--------------------------------

				if type(paddingY) == "function" then
					newHeight = paddingY(relativeTo:GetWidth(), relativeTo:GetHeight())
				else
					newHeight = relativeTo:GetHeight() - paddingY
				end

				--------------------------------

				frame:SetHeight(newHeight)
			end
		end

		--------------------------------

		UpdateSize()

		if updateAll then
			hooksecurefunc(updateFrame or relativeTo, "SetSize", UpdateSize)
			hooksecurefunc(updateFrame or relativeTo, "SetWidth", UpdateSize)
			hooksecurefunc(updateFrame or relativeTo, "SetHeight", UpdateSize)
		else
			if paddingX and paddingY then
				hooksecurefunc(updateFrame or relativeTo, "SetSize", UpdateSize)
			end

			if paddingX then
				hooksecurefunc(updateFrame or relativeTo, "SetWidth", UpdateSize)
			end

			if paddingY then
				hooksecurefunc(updateFrame or relativeTo, "SetHeight", UpdateSize)
			end
		end

		--------------------------------

		return UpdateSize
	end
end

--------------------------------
-- HOOKS
--------------------------------

do
	-- Sets the text color of a frame to white.
	---@param frame any
	function NS.FrameUtil:HookSetTextColor(frame)
		if not frame.HookedTextColor then
			frame.HookedTextColor = true

			--------------------------------

			hooksecurefunc(frame, "SetTextColor", function()
				frame:SetText("|cffFFFFFF" .. NS.Util:GetUnformattedText(frame:GetText()) .. "|r")
			end)

			hooksecurefunc(frame, "SetFormattedText", function()
				frame:SetText("|cffFFFFFF" .. NS.Util:GetUnformattedText(frame:GetText()) .. "|r")
			end)
		end

		--------------------------------

		frame:SetText("|cffFFFFFF" .. NS.Util:GetUnformattedText(frame:GetText()) .. "|r")
	end

	-- Hides an element when it is shown.
	---@param frame any
	function NS.FrameUtil:HookHideElement(frame)
		if not frame.HookedHideElement then
			frame.HookedHideElement = true

			--------------------------------

			frame:HookScript("OnShow", function()
				frame:Hide()
			end)

			--------------------------------

			frame:Hide()
		end
	end
end
