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
	-- Create a text box.
	---@param parent frame
	---@param frameStrata string
	---@param frameLevel number
	---@param data table
	---@param name string
	function NS:CreateTextBox(parent, frameStrata, frameLevel, data, name)
		local inset = data.inset or 5

		--------------------------------

		local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name, parent)
		Frame:SetFrameStrata(frameStrata)
		Frame:SetFrameLevel(frameLevel)

		--------------------------------

		do -- ELEMENTS
			do -- CONTENT
				Frame.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Frame)
				Frame.Content:SetPoint("CENTER", Frame)
				Frame.Content:SetFrameStrata(frameStrata)
				Frame.Content:SetFrameLevel(frameLevel + 1)
				addon.C.API.FrameUtil:SetDynamicSize(Frame.Content, Frame, 0, 0)

				local Content = Frame.Content

				--------------------------------

				do -- TEXT BOX
					Content.TextBox = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.TextBox", Content)
					Content.TextBox:SetPoint("CENTER", Content)
					Content.TextBox:SetFrameStrata(frameStrata)
					Content.TextBox:SetFrameLevel(frameLevel + 2)
					addon.C.API.FrameUtil:SetDynamicSize(Content.TextBox, Content, inset, inset)

					local TextBox = Content.TextBox

					--------------------------------

					do -- INPUT
						TextBox.Input = addon.C.FrameTemplates:CreateFrame("EditBox", "$parent.Input", TextBox)
						TextBox.Input:SetPoint("CENTER", TextBox)
						TextBox.Input:SetFrameStrata(frameStrata)
						TextBox.Input:SetFrameLevel(frameLevel + 3)
						addon.C.API.FrameUtil:SetDynamicSize(TextBox.Input, TextBox, 0, 0)

						TextBox.Input:SetMultiLine(false)
						TextBox.Input:SetAutoFocus(false)
					end

					do -- PLACEHOLDER
						TextBox.Placeholder = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Placeholder", TextBox)
						TextBox.Placeholder:SetPoint("CENTER", TextBox)
						TextBox.Placeholder:SetFrameStrata(frameStrata)
						TextBox.Placeholder:SetFrameLevel(frameLevel + 3)
						addon.C.API.FrameUtil:SetDynamicSize(TextBox.Placeholder, TextBox, 0, 0)
					end
				end
			end
		end

		do -- REFERENCES
			-- CORE
			Frame.REF_CONTENT = Frame.Content
			Frame.REF_INPUT = Frame.Content.TextBox.Input
			Frame.REF_PLACEHOLDER = Frame.Content.TextBox.Placeholder

			-- INPUT
			Frame.REF_INPUT_RAWTEXT = select(1, Frame.Content.TextBox.Input:GetRegions())
		end

		do -- LOGIC
			Frame.autoFocus = false
			Frame.isMouseOver = false
			Frame.isMouseDown = false

			Frame.enterCallbacks = {}
			Frame.leaveCallbacks = {}
			Frame.mouseDownCallbacks = {}
			Frame.mouseUpCallbacks = {}
			Frame.escapePressedCallbacks = {}
			Frame.textChangedCallbacks = {}
			Frame.focusChangedCallbacks = {}

			--------------------------------

			do -- FUNCTIONS
				do -- SET
					function Frame:SetText(text)
						Frame.REF_INPUT:SetText(text or "")
					end

					function Frame:SetAutoFocus(autoFocus)
						Frame.autoFocus = autoFocus
					end

					function Frame:SetFocus()
						Frame.REF_INPUT:SetFocus()
					end

					function Frame:ClearFocus()
						Frame.REF_INPUT:ClearFocus()
						Frame.REF_INPUT:ClearHighlightText()
					end
				end

				do -- GET
					function Frame:GetText()
						return Frame.REF_INPUT:GetText()
					end

					function Frame:GetAutoFocus()
						return Frame.autoFocus
					end

					function Frame:HasFocus()
						return Frame.REF_INPUT:HasFocus()
					end
				end

				do -- LOGIC
					function Frame:UpdatePlaceholder()
						if Frame.REF_INPUT:GetText() == "" then
							Frame.REF_PLACEHOLDER:Show()
						else
							Frame.REF_PLACEHOLDER:Hide()
						end
					end
				end
			end

			do -- EVENTS
				local function Event_OnShow()
					if Frame.autoFocus then
						Frame:SetFocus()
					end
				end

				function Frame:OnEnter(skipAnimation)
					Frame.isMouseOver = true

					--------------------------------

					do -- ON ENTER
						local enterCallbacks = Frame.enterCallbacks

						if #enterCallbacks >= 1 then
							for callback = 1, #enterCallbacks do
								enterCallbacks[callback](Frame, skipAnimation)
							end
						end
					end
				end

				function Frame:OnLeave(skipAnimation)
					Frame.isMouseOver = false

					--------------------------------

					do -- ON LEAVE
						local leaveCallbacks = Frame.leaveCallbacks

						if #leaveCallbacks >= 1 then
							for callback = 1, #leaveCallbacks do
								leaveCallbacks[callback](Frame, skipAnimation)
							end
						end
					end
				end

				function Frame:OnMouseDown(skipAnimation)
					Frame.isMouseDown = true

					--------------------------------

					Frame:SetFocus()

					--------------------------------

					do -- ON MOUSE DOWN
						local mouseDownCallbacks = Frame.mouseDownCallbacks

						if #mouseDownCallbacks >= 1 then
							for callback = 1, #mouseDownCallbacks do
								mouseDownCallbacks[callback](Frame, skipAnimation)
							end
						end
					end
				end

				function Frame:OnMouseUp(skipAnimation)
					Frame.isMouseDown = false

					--------------------------------

					do -- ON MOUSE UP
						local mouseUpCallbacks = Frame.mouseUpCallbacks

						if #mouseUpCallbacks >= 1 then
							for callback = 1, #mouseUpCallbacks do
								mouseUpCallbacks[callback](Frame, skipAnimation)
							end
						end
					end
				end

				function Frame:OnEscapePressed()
					Frame:ClearFocus()

					--------------------------------

					do -- ON ESCAPE PRESSED
						local escapePressedCallbacks = Frame.escapePressedCallbacks

						if #escapePressedCallbacks >= 1 then
							for callback = 1, #escapePressedCallbacks do
								escapePressedCallbacks[callback](Frame, Frame.REF_INPUT)
							end
						end
					end
				end

				function Frame:OnTextChanged(userInput)
					Frame:UpdatePlaceholder()

					--------------------------------

					do -- ON TEXT CHANGED
						local textChangedCallbacks = Frame.textChangedCallbacks

						if #textChangedCallbacks >= 1 then
							for callback = 1, #textChangedCallbacks do
								textChangedCallbacks[callback](Frame, userInput)
							end
						end
					end
				end

				function Frame:OnFocusChanged()
					do -- ON FOCUS CHANGED
						local focusChangedCallbacks = Frame.focusChangedCallbacks

						if #focusChangedCallbacks >= 1 then
							for callback = 1, #focusChangedCallbacks do
								focusChangedCallbacks[callback](Frame, Frame.REF_INPUT:HasFocus())
							end
						end
					end
				end

				addon.C.FrameTemplates:CreateMouseResponder(Frame, { enterCallback = Frame.OnEnter, leaveCallback = Frame.OnLeave, mouseDownCallback = Frame.OnMouseDown, mouseUpCallback = Frame.OnMouseUp })

				Frame.REF_INPUT:SetScript("OnEscapePressed", Frame.OnEscapePressed)
				Frame.REF_INPUT:HookScript("OnTextChanged", Frame.OnTextChanged)
				Frame.REF_INPUT:SetScript("OnEditFocusGained", Frame.OnFocusChanged)
				Frame.REF_INPUT:SetScript("OnEditFocusLost", Frame.OnFocusChanged)

				Frame:HookScript("OnShow", Event_OnShow)
			end
		end

		--------------------------------

		return Frame
	end

	-- Creates a text field.
	---@param parent any
	---@param data table
	---@param name string
	function NS:CreateTextBox_Legacy(parent, frameStrata, frameLevel, data, name)
		local inset = data.inset or 5

		--------------------------------

		local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name, parent)
		Frame:SetFrameStrata(frameStrata)
		Frame:SetFrameLevel(frameLevel)

		--------------------------------

		do -- ELEMENTS
			do -- SCROLL FRAME
				Frame.ScrollFrame, Frame.ScrollChildFrame = addon.C.FrameTemplates:CreateScrollFrame(parent, { direction = "vertical", smoothScrollingRatio = 5 }, "$parent.Name" .. "ScrollFrame", "$parent.Name" .. "ScrollChildFrame")
				Frame.ScrollFrame:SetPoint("CENTER", Frame)
				Frame.ScrollFrame:SetFrameStrata(frameStrata)
				Frame.ScrollFrame:SetFrameLevel(frameLevel + 1)
				addon.C.API.FrameUtil:SetDynamicSize(Frame.ScrollFrame, Frame, inset * 2, inset * 2)
				addon.C.API.FrameUtil:SetDynamicSize(Frame.ScrollChildFrame, Frame.ScrollFrame, 0, nil)

				local ScrollFrame = Frame.ScrollFrame
				local ScrollChildFrame = Frame.ScrollChildFrame

				----------------------------------

				do -- SCORLL BAR
					ScrollFrame.ScrollBar:Hide()
				end

				do -- CONTENT
					ScrollChildFrame.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", ScrollChildFrame)
					ScrollChildFrame.Content:SetPoint("TOP", ScrollChildFrame)
					ScrollChildFrame.Content:SetFrameStrata(frameStrata)
					ScrollChildFrame.Content:SetFrameLevel(frameLevel + 2)
					addon.C.API.FrameUtil:SetDynamicSize(ScrollChildFrame.Content, ScrollFrame, 0, 0)
					addon.C.API.FrameUtil:SetDynamicSize(ScrollChildFrame, ScrollChildFrame.Content, nil, 0)

					local Content = ScrollChildFrame.Content

					----------------------------------

					do -- CONTENT
						Content.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Content)
						Content.Content:SetPoint("CENTER", Content)
						Content.Content:SetFrameStrata(frameStrata)
						Content.Content:SetFrameLevel(frameLevel + 3)
						addon.C.API.FrameUtil:SetDynamicSize(Content.Content, Content, 0, 0)

						local Subcontent = Content.Content

						----------------------------------

						do -- LAYOUT GROUP
							Subcontent.LayoutGroup = addon.C.FrameTemplates:CreateLayoutGroup(Subcontent, { point = "LEFT", direction = "horizontal", resize = false, padding = 0, distribute = false, distributeResizeElements = false, excludeHidden = true, autoSort = true, customOffset = nil, customLayoutSort = nil }, "$parent.LayoutGroup")
							Subcontent.LayoutGroup:SetPoint("CENTER", Subcontent)
							addon.C.API.FrameUtil:SetDynamicSize(Subcontent.LayoutGroup, Subcontent, 0, 0)

							local LayoutGroup = Subcontent.LayoutGroup

							--------------------------------

							local IMAGE_FRAME_WIDTH = 20
							local IMAGE_FRAME_HEIGHT = 20

							do -- IMAGE FRAME
								LayoutGroup.ImageFrame = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.ImageFrame", LayoutGroup)
								LayoutGroup.ImageFrame:SetSize(IMAGE_FRAME_WIDTH, IMAGE_FRAME_HEIGHT)
								LayoutGroup:AddElement(LayoutGroup.ImageFrame)

								local ImageFrame = LayoutGroup.ImageFrame

								--------------------------------

								do -- BACKGROUND
									ImageFrame.Background, ImageFrame.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(ImageFrame, frameStrata, nil, "$parent.Background")
									ImageFrame.Background:SetPoint("CENTER", ImageFrame)
									addon.C.API.FrameUtil:SetDynamicSize(ImageFrame.Background, ImageFrame, 7.5, 7.5)
								end
							end

							do -- TEXT BOX
								LayoutGroup.TextBox = addon.C.FrameTemplates:CreateFrame("EditBox", name, LayoutGroup)
								LayoutGroup.TextBox:SetFrameStrata(frameStrata)
								LayoutGroup.TextBox:SetFrameLevel(frameLevel + 4)
								addon.C.API.FrameUtil:SetDynamicSize(ScrollChildFrame, LayoutGroup.TextBox, nil, 0)
								LayoutGroup:AddElement(LayoutGroup.TextBox)

								LayoutGroup.TextBox:SetMultiLine(false)
								LayoutGroup.TextBox:SetAutoFocus(false)

								local TextBox = LayoutGroup.TextBox

								--------------------------------

								do -- TEXT
									TextBox.Text = select(1, TextBox:GetRegions())
									TextBox.Text.justifyV = "TOP"
								end

								do -- PLACEHOLDER
									TextBox.Placeholder = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Placeholder", TextBox)
									TextBox.Placeholder:SetPoint("CENTER", TextBox)
									addon.C.API.FrameUtil:SetDynamicSize(TextBox.Placeholder, TextBox, 0, 0)
									TextBox.Placeholder:SetAlpha(1)

									local Placeholder = TextBox.Placeholder

									--------------------------------

									do -- TEXT
										Placeholder.Text = addon.C.FrameTemplates:CreateText(Placeholder, addon.CS:GetSharedColor().RGB_WHITE, 12.5, "LEFT", "TOP", addon.C.Fonts.CONTENT_MEDIUM, "$parent.Text")
										Placeholder.Text:SetPoint("CENTER", Placeholder)
										addon.C.API.FrameUtil:SetDynamicSize(Placeholder.Text, Placeholder, 0, 0)
										Placeholder.Text.justifyV = "TOP"
									end
								end
							end

							do -- EVENTS
								local function UpdateLayout()
									local indentWidth = LayoutGroup.ImageFrame:IsShown() and IMAGE_FRAME_WIDTH or 0
									LayoutGroup.TextBox:SetWidth(LayoutGroup:GetWidth() - indentWidth)
									Subcontent.LayoutGroup:Sort()
								end

								local function UpdateSize(self, userInput)
									if userInput then
										if LayoutGroup.TextBox:IsMultiLine() then
											local stringHeight = LayoutGroup.TextBox.Text:GetHeight()

											--------------------------------

											LayoutGroup.TextBox:SetHeight(stringHeight)
											LayoutGroup.TextBox.Text:SetJustifyV(LayoutGroup.TextBox.Text.justifyV)
											LayoutGroup.TextBox.Placeholder.Text:SetJustifyV(LayoutGroup.TextBox.Placeholder.Text.justifyV)
										else
											LayoutGroup.TextBox:SetHeight(Subcontent:GetHeight())
											LayoutGroup.TextBox.Text:SetJustifyV("MIDDLE")
											LayoutGroup.TextBox.Placeholder.Text:SetJustifyV("MIDDLE")
										end
									end
								end

								LayoutGroup.TextBox:SetScript("OnShow", UpdateLayout)
								LayoutGroup.TextBox:SetScript("OnUpdate", UpdateSize)
							end
						end
					end
				end
			end
		end

		do -- REFERENCES
			-- CORE
			Frame.REF_SCROLL = Frame.ScrollFrame
			Frame.REF_CONTENT = Frame.ScrollChildFrame.Content.Content

			-- SCROLL
			Frame.REF_SCROLL_CHILD = Frame.ScrollChildFrame

			-- CONTENT
			Frame.REF_CONTENT_LAYOUT = Frame.REF_CONTENT.LayoutGroup
			Frame.REF_CONTENT_LAYOUT_IMAGE = Frame.REF_CONTENT_LAYOUT.ImageFrame
			Frame.REF_CONTENT_LAYOUT_IMAGE_BACKGROUND = Frame.REF_CONTENT_LAYOUT_IMAGE.Background
			Frame.REF_CONTENT_LAYOUT_IMAGE_BACKGROUND_TEXTURE = Frame.REF_CONTENT_LAYOUT_IMAGE.BackgroundTexture
			Frame.REF_CONTENT_LAYOUT_TEXTBOX = Frame.REF_CONTENT_LAYOUT.TextBox
			Frame.REF_CONTENT_LAYOUT_TEXTBOX_TEXT = Frame.REF_CONTENT_LAYOUT_TEXTBOX.Text
			Frame.REF_CONTENT_LAYOUT_TEXTBOX_PLACEHOLDER = Frame.REF_CONTENT_LAYOUT_TEXTBOX.Placeholder
			Frame.REF_CONTENT_LAYOUT_TEXTBOX_PLACEHOLDER_TEXT = Frame.REF_CONTENT_LAYOUT_TEXTBOX_PLACEHOLDER.Text
		end

		do -- LOGIC
			Frame.isMouseOver = false
			Frame.isMouseDown = false
			Frame.autoSelect = false

			Frame.enterCallbacks = {}
			Frame.leaveCallbacks = {}
			Frame.mouseDownCallbacks = {}
			Frame.mouseUpCallbacks = {}
			Frame.escapePressedCallbacks = {}
			Frame.textChangedCallbacks = {}

			--------------------------------

			do -- FUNCTIONS
				do -- GET
					function Frame:GetImage()
						return Frame.REF_CONTENT_LAYOUT_IMAGE
					end

					function Frame:GetTextBox()
						return Frame.REF_CONTENT_LAYOUT_TEXTBOX
					end

					function Frame:GetTextBoxPlaceholder()
						return Frame.REF_CONTENT_LAYOUT_TEXTBOX_PLACEHOLDER
					end

					function Frame:GetTextBoxPlaceholderTextObject()
						return Frame.REF_CONTENT_LAYOUT_TEXTBOX_PLACEHOLDER_TEXT
					end

					function Frame:GetTextBoxTextObject()
						return Frame.REF_CONTENT_LAYOUT_TEXTBOX_TEXT
					end

					function Frame:IsFocused()
						return Frame:GetTextBox():HasFocus()
					end
				end

				do -- SET
					function Frame:SetImage(image)
						if image then
							Frame:GetImage():Show()
							Frame:GetImage().BackgroundTexture:SetTexture(image)
						else
							Frame:GetImage():Hide()
						end
					end

					function Frame:SetPlaceholder(text)
						Frame:GetTextBoxPlaceholderTextObject():SetText(text)

						----------------------------------

						Frame:UpdatePlaceholder()
					end
				end

				do -- LOGIC
					function Frame:UpdatePlaceholder()
						if Frame:GetTextBox():HasText() then
							Frame:GetTextBoxPlaceholder():Hide()
						else
							Frame:GetTextBoxPlaceholder():Show()
						end
					end
				end
			end

			do -- EVENTS
				function Frame:OnEnter(skipAnimation)
					Frame.isMouseOver = true

					--------------------------------

					do -- ON ENTER
						local enterCallbacks = Frame.enterCallbacks

						if #enterCallbacks >= 1 then
							for callback = 1, #enterCallbacks do
								enterCallbacks[callback](Frame, skipAnimation)
							end
						end
					end
				end

				function Frame:OnLeave(skipAnimation)
					if not Frame:GetTextBox():HasFocus() then
						Frame.isMouseOver = false

						--------------------------------

						do -- ON LEAVE
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
					Frame.isMouseDown = true

					--------------------------------

					do -- ON MOUSE DOWN
						local mouseDownCallbacks = Frame.mouseDownCallbacks

						if #mouseDownCallbacks >= 1 then
							for callback = 1, #mouseDownCallbacks do
								mouseDownCallbacks[callback](Frame, skipAnimation)
							end
						end
					end
				end

				function Frame:OnMouseUp(skipAnimation)
					Frame.isMouseDown = false

					--------------------------------

					do -- ON MOUSE UP
						local mouseUpCallbacks = Frame.mouseUpCallbacks

						if #mouseUpCallbacks >= 1 then
							for callback = 1, #mouseUpCallbacks do
								mouseUpCallbacks[callback](Frame, skipAnimation)
							end
						end
					end
				end

				function Frame:OnEscapePressed()
					Frame:GetTextBox():ClearFocus()

					--------------------------------

					do -- ON ESCAPE PRESSED
						local escapePressedCallbacks = Frame.escapePressedCallbacks

						if #escapePressedCallbacks >= 1 then
							for callback = 1, #escapePressedCallbacks do
								escapePressedCallbacks[callback](Frame, Frame:GetTextBox())
							end
						end
					end
				end

				function Frame:OnTextChanged()
					Frame:UpdatePlaceholder()

					--------------------------------

					do -- ON VALUE CHANGED
						local textChangedCallbacks = Frame.textChangedCallbacks

						if #textChangedCallbacks >= 1 then
							for callback = 1, #textChangedCallbacks do
								textChangedCallbacks[callback](Frame, Frame:GetTextBox(), Frame:GetTextBoxTextObject():GetText())
							end
						end
					end
				end

				addon.C.FrameTemplates:CreateMouseResponder(Frame, { enterCallback = Frame.OnEnter, leaveCallback = Frame.OnLeave, mouseDownCallback = Frame.OnMouseDown, mouseUpCallback = Frame.OnMouseUp })
				Frame:GetTextBox():SetScript("OnEditFocusGained", Frame.OnEnter)
				Frame:GetTextBox():SetScript("OnEditFocusLost", Frame.OnLeave)
				Frame:GetTextBox():SetScript("OnEscapePressed", Frame.OnEscapePressed)
				Frame:GetTextBox():HookScript("OnTextChanged", Frame.OnTextChanged)
				Frame:SetScript("OnShow", function()
					Frame:UpdatePlaceholder()

					--------------------------------

					C_Timer.After(.1, function()
						if Frame.autoSelect then
							Frame:GetTextBox():HighlightText(0, #Frame:GetTextBox():GetText())
							Frame:GetTextBox():SetFocus()
						else
							Frame:GetTextBox():ClearFocus()
						end
					end, 0)
				end)
			end
		end

		do -- SETUP
			Frame:SetImage(nil)
			Frame:UpdatePlaceholder()
		end

		--------------------------------

		return Frame
	end
end
