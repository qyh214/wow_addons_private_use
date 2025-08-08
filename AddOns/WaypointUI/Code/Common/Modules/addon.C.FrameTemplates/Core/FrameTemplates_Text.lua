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
	-- Creates a text object with advanced functionality.
	---@param parent any
	---@param textColor table
	---@param textSize number
	---@param alignH string
	---@param alignV string
	---@param fontFile string
	---@param name? string
	function NS:CreateText(parent, textColor, textSize, alignH, alignV, fontFile, name, template)
		if type(fontFile) == "table" then
			textSize = addon.CS:NewFontSize(textSize, fontFile.sizeModifier)
			fontFile = fontFile.path
		end

		local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name, parent)

		--------------------------------

		do -- ELEMENTS
			do -- RENDERER
				Frame.Renderer = Frame:CreateFontString("$parent.Renderer", "OVERLAY", template or nil)
				Frame.Renderer:SetFont(fontFile, textSize or 11, "")
				Frame.Renderer:SetJustifyH(alignH or "CENTER")
				Frame.Renderer:SetJustifyV(alignV or "MIDDLE")
				Frame.Renderer:SetTextColor(textColor.r or 1, textColor.g or 1, textColor.b or 1)

				Frame.Renderer:SetPoint("TOPLEFT", Frame, 0, 0)
				Frame.Renderer:SetPoint("BOTTOMRIGHT", Frame, 0, 0)
			end
		end

		do -- LOGIC
			Frame.autoFit = false
			Frame.autoFit_maxWidth = nil
			Frame.autoFit_maxHeight = nil
			Frame.autoFit_preserveHeight = false
			Frame.autoFit_lastFitSession = nil

			--------------------------------

			do -- FUNCTIONS
				do -- SET
					function Frame:SetText(...)
						Frame.Renderer:SetText(...); if Frame.autoFit then Frame:SetToFit(Frame.autoFit_preserveHeight) end
					end

					function Frame:SetFormattedText(...)
						Frame.Renderer:SetFormattedText(...); if Frame.autoFit then Frame:SetToFit(Frame.autoFit_preserveHeight) end
					end

					function Frame:SetTextColor(...) Frame.Renderer:SetTextColor(...) end

					function Frame:SetFont(...) Frame.Renderer:SetFont(...) end

					function Frame:SetJustifyH(...) Frame.Renderer:SetJustifyH(...) end

					function Frame:SetJustifyV(...) Frame.Renderer:SetJustifyV(...) end

					function Frame:SetAlphaGradient(...) Frame.Renderer:SetAlphaGradient(...) end

					function Frame:SetMaxLines(...) Frame.Renderer:SetMaxLines(...) end

					--------------------------------

					local function AutoFit_CacheState()
						local parent = Frame:GetParent()
						local point, relativeTo, relativePoint, offsetX, offsetY = Frame:GetPoint()
						local scale = Frame:GetScale()
						local ignoreScale = Frame:IsIgnoringParentScale()

						return {
							parent = parent,
							point = point,
							relativeTo = relativeTo,
							relativePoint = relativePoint,
							offsetX = offsetX,
							offsetY = offsetY,
							scale = scale,
							ignoreScale = ignoreScale,
						}
					end

					-- Sets whether the text will automatically fit its content.
					---@param autoFit boolean
					---@param preserveHeight? boolean
					function Frame:SetAutoFit(autoFit, preserveHeight)
						Frame.autoFit = autoFit
						Frame.autoFit_preserveHeight = preserveHeight
						if Frame.autoFit then Frame:SetToFit(preserveHeight) end
					end

					-- Sets the max width allowed before wrapping to the next line.
					---@param width number
					function Frame:SetAutoFit_MaxWidth(width)
						Frame.autoFit_maxWidth = width
					end

					-- Sets the max height allowed. (Need further testing)
					---@param height number
					function Frame:SetAutoFit_MaxHeight(height)
						Frame.autoFit_maxHeight = height
					end

					-- Scales the text to fit its content.
					---@param preserveHeight? boolean
					function Frame:SetToFit(preserveHeight)
						local CacheState = AutoFit_CacheState()
						local IsNewSession; if Frame.autoFit_lastFitSession then IsNewSession = Frame.autoFit_lastFitSession.text ~= Frame:GetText() or Frame.autoFit_lastFitSession.fontSize ~= select(2, Frame.Renderer:GetFont()) else IsNewSession = true end

						--------------------------------

						-- Set position to UIParent
						-- This is required to get the correct width and height of the text, if the frame's point isn't set yet?
						local effectiveScale = Frame:GetEffectiveScale()
						Frame:SetParent(UIParent)
						Frame:ClearAllPoints()
						Frame:SetPoint("CENTER", UIParent)
						Frame:SetScale(effectiveScale)
						Frame:SetIgnoreParentScale(true)

						--------------------------------

						if Frame.autoFit_maxWidth then Frame:SetWidth(Frame.autoFit_maxWidth) else Frame:SetWidth(parent:GetWidth()) end
						if Frame.autoFit_maxHeight then Frame:SetHeight(Frame.autoFit_maxHeight) else Frame:SetHeight(10000) end

						local width, height = Frame.Renderer:GetWrappedWidth(), Frame.Renderer:GetStringHeight()
						Frame:SetWidth(width)
						Frame:SetHeight(height)

						-- If the current string height is less than the desired height (the height from the last session), then shrink the frame width until it wraps to the next line
						-- if preserveHeight then
						-- 	if not IsNewSession then
						-- 		while (Frame.Renderer:GetStringHeight() < Frame.autoFit_lastFitSession.stringHeight) do
						-- 			Frame:SetWidth(Frame:GetWidth() - 1)
						-- 		end
						-- 	end
						-- end

						--------------------------------

						-- Set position back to original
						Frame:SetParent(parent)
						Frame:SetScale(CacheState.scale)
						Frame:SetIgnoreParentScale(CacheState.ignoreScale)
						if CacheState.point then
							Frame:ClearAllPoints()
							Frame:SetPoint(CacheState.point, CacheState.relativeTo, CacheState.relativePoint, CacheState.offsetX, CacheState.offsetY)
						end

						--------------------------------

						-- Save state
						Frame.autoFit_lastFitSession = {
							["text"] = Frame:GetText(),
							["fontSize"] = select(2, Frame.Renderer:GetFont()),
							["stringHeight"] = height,
						}
					end
				end

				do -- GET
					function Frame:GetText() return Frame.Renderer:GetText() end

					function Frame:GetTextColor() return Frame.Renderer:GetTextColor() end

					function Frame:GetFont() return Frame.Renderer:GetFont() end

					function Frame:GetJustifyH() return Frame.Renderer:GetJustifyH() end

					function Frame:GetJustifyV() return Frame.Renderer:GetJustifyV() end

					function Frame:IsTruncated() return Frame.Renderer:IsTruncated() end

					function Frame:GetMaxLines() return Frame.Renderer:GetMaxLines() end

					function Frame:GetStringWidth() return Frame.Renderer:GetStringWidth() end

					function Frame:GetWrappedWidth() return Frame.Renderer:GetWrappedWidth() end

					function Frame:GetUnboundedStringWidth() return Frame.Renderer:GetUnboundedStringWidth() end

					function Frame:GetStringHeight() return Frame.Renderer:GetStringHeight() end

					--------------------------------

					function Frame:GetAutoFitMaxWidth()
						return Frame.autoFit_maxWidth
					end

					function Frame:GetAutoFitMaxHeight()
						return Frame.autoFit_maxHeight
					end

					function Frame:IsAutoFit()
						return Frame.autoFit
					end
				end

				do -- LOGIC
					function Frame:UpdateFont(newFont)
						local fontName, fontHeight, fontFlags = Frame.Renderer:GetFont()
						local newFontName, newFontPath, newFontSize

						if type(newFont) == "table" then
							newFontName = newFont.name
							newFontPath = newFont.path
							newFontSize = addon.CS:NewFontSize(textSize, newFont.sizeModifier)
						else
							newFontName = newFont
							newFontPath = newFont
							newFontSize = fontHeight
						end

						Frame:SetFont(newFontPath, newFontSize, fontFlags)

						--------------------------------

						if Frame:IsAutoFit() then
							Frame:SetToFit(Frame.autoFit_preserveHeight)
						end
					end
				end
			end

			do -- EVENTS
				local function AutoFit()
					if Frame:IsAutoFit() then
						Frame:SetToFit(Frame.autoFit_preserveHeight)
					end
				end

				Frame:RegisterEvent("UI_SCALE_CHANGED")
				Frame:SetScript("OnEvent", AutoFit)
				CallbackRegistry:Add("C_TEXT_AUTOFIT", AutoFit)
				CallbackRegistry:Add("C_FONT_OVERRIDE", function(newFontInfo) Frame:UpdateFont(newFontInfo) end)
			end
		end

		--------------------------------

		return Frame
	end
end
