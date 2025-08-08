---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.FrameTemplates; addon.C.FrameTemplates = NS

--------------------------------

NS.Prefabs = {}

--------------------------------
-- PREFABS
--------------------------------

function NS.Prefabs:Load()
	do -- BLIZZARD
		local BASELINE = 100
		local function Ratio(level) return BASELINE / addon.C.Variables:RAW_RATIO(level) end
		local PADDING = Ratio(5)

		--------------------------------

		do -- BUTTON
			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Button.Template", function(parent, frameStrata, frameLevel, data, name)
				local PADDING_CONTENT = data.PADDING_CONTENT

				local DEFAULT_BACKGROUND_TEXTURE = data.DEFAULT_BACKGROUND_TEXTURE
				local HIGHLIGHTED_BACKGROUND_TEXTURE = data.HIGHLIGHTED_BACKGROUND_TEXTURE
				local CLICKED_BACKGROUND_TEXTURE = data.CLICKED_BACKGROUND_TEXTURE

				--------------------------------

				local Frame = addon.C.FrameTemplates:CreateButton(parent, name)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				--------------------------------

				do -- ELEMENTS
					do -- CONTENT
						local Content = Frame.Content

						--------------------------------

						do -- BACKGROUND
							Content.Background, Content.BackgroundTexture = addon.C.FrameTemplates:CreateNineSlice(Content, frameStrata, DEFAULT_BACKGROUND_TEXTURE, 75, .125, "$parent.Background", Enum.UITextureSliceMode.Stretched)
							Content.Background:SetPoint("CENTER", Content)
							Content.Background:SetFrameStrata(frameStrata)
							Content.Background:SetFrameLevel(frameLevel + 1)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Background, Content, -7.5, -7.5)
						end

						do -- MAIN
							Content.Main = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Main", Content)
							Content.Main:SetPoint("CENTER", Content)
							Content.Main:SetFrameStrata(frameStrata)
							Content.Main:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Main, Content, PADDING_CONTENT, PADDING_CONTENT)
						end
					end
				end

				do -- REFERENCES
					-- CORE
					Frame.REF_BACKGROUND = Frame.REF_CONTENT.Background
					Frame.REF_MAIN = Frame.REF_CONTENT.Main

					-- BACKGROUND
					Frame.REF_BACKGROUND_TEXTURE = Frame.REF_CONTENT.BackgroundTexture
				end

				do -- ANIMATIONS
					local function SetStyle(backgroundTexture, offsetX, offsetY)
						Frame.REF_BACKGROUND_TEXTURE:SetTexture(backgroundTexture)

						Frame.REF_MAIN:ClearAllPoints()
						Frame.REF_MAIN:SetPoint("CENTER", Frame.REF_CONTENT, offsetX, offsetY)
					end

					--------------------------------

					do -- ON ENTER
						function Frame:Animation_OnEnter_StopEvent()
							return not Frame.isMouseOver
						end

						function Frame:Animation_OnEnter(skipAnimation)
							SetStyle(HIGHLIGHTED_BACKGROUND_TEXTURE, 0, 0)
						end
					end

					do -- ON LEAVE
						function Frame:Animation_OnLeave_StopEvent()
							return Frame.isMouseOver
						end

						function Frame:Animation_OnLeave(skipAnimation)
							SetStyle(DEFAULT_BACKGROUND_TEXTURE, 0, 0)
						end
					end

					do -- ON MOUSE DOWN
						function Frame:Animation_OnMouseDown_StopEvent()
							return not Frame.isMouseDown
						end

						function Frame:Animation_OnMouseDown(skipAnimation)
							SetStyle(CLICKED_BACKGROUND_TEXTURE, 0, -1)
						end
					end

					do -- ON MOUSE UP
						function Frame:Animation_OnMouseUp_StopEvent()
							return Frame.isMouseDown
						end

						function Frame:Animation_OnMouseUp(skipAnimation)
							if Frame.isMouseOver then
								Frame:Animation_OnEnter(true)
							else
								Frame:Animation_OnLeave(true)
							end
						end
					end
				end

				do -- LOGIC
					do -- EVENTS
						local function Event_OnEnter(frame, skipAnimation)
							Frame:Animation_OnEnter(skipAnimation)
						end

						local function Event_OnLeave(frame, skipAnimation)
							Frame:Animation_OnLeave(skipAnimation)
						end

						local function Event_OnMouseDown(frame, skipAnimation)
							Frame:Animation_OnMouseDown(skipAnimation)

							--------------------------------

							PlaySound(856)
						end

						local function Event_OnMouseUp(frame, skipAnimation)
							Frame:Animation_OnMouseUp(skipAnimation)
						end

						table.insert(Frame.enterCallbacks, Event_OnEnter)
						table.insert(Frame.leaveCallbacks, Event_OnLeave)
						table.insert(Frame.mouseDownCallbacks, Event_OnMouseDown)
						table.insert(Frame.mouseUpCallbacks, Event_OnMouseUp)
					end
				end

				--------------------------------

				return Frame
			end)

			--------------------------------

			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Button.Text.Template", function(parent, frameStrata, frameLevel, data, name)
				local resize = data.resize

				local DEFAULT_CONTENT_COLOR = data.DEFAULT_CONTENT_COLOR
				local HIGHLIGHTED_CONTENT_COLOR = data.HIGHLIGHTED_CONTENT_COLOR
				local CLICKED_CONTENT_COLOR = data.CLICKED_CONTENT_COLOR

				--------------------------------

				local Frame = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Button.Template", parent, frameStrata, frameLevel, data, name)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				--------------------------------

				do -- ELEMENTS
					do -- MAIN
						local Main = Frame.REF_MAIN

						--------------------------------

						do -- TEXT
							Main.Text = addon.C.FrameTemplates:CreateText(Main, DEFAULT_CONTENT_COLOR, 12.5, "CENTER", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Text", "GameFontNormal")
							Main.Text:SetPoint("CENTER", Main)

							if resize then
								Main.Text:SetAutoFit(true)
								Main.Text:SetAutoFit_MaxWidth(10000)

								addon.C.API.FrameUtil:SetDynamicSize(Frame, Main.Text, -PADDING, -PADDING)
							else
								addon.C.API.FrameUtil:SetDynamicSize(Main.Text, Main, 0, 0)
							end
						end
					end
				end

				do -- REFERENCES
					-- MAIN
					Frame.REF_MAIN_TEXT = Frame.REF_MAIN.Text
				end

				do -- ANIMATIONS
					local function SetStyle(contentColor)
						Frame.REF_MAIN_TEXT:SetTextColor(contentColor.r, contentColor.g, contentColor.b, contentColor.a or 1)
					end

					--------------------------------

					do -- ON ENTER
						function Frame:Animation_Text_OnEnter_StopEvent()
							return not Frame.isMouseOver
						end

						function Frame:Animation_Text_OnEnter(skipAnimation)
							SetStyle(HIGHLIGHTED_CONTENT_COLOR)
						end
					end

					do -- ON LEAVE
						function Frame:Animation_Text_OnLeave_StopEvent()
							return Frame.isMouseOver
						end

						function Frame:Animation_Text_OnLeave(skipAnimation)
							SetStyle(DEFAULT_CONTENT_COLOR)
						end
					end

					do -- ON MOUSE DOWN
						function Frame:Animation_Text_OnMouseDown_StopEvent()
							return not Frame.isMouseDown
						end

						function Frame:Animation_Text_OnMouseDown(skipAnimation)
							SetStyle(CLICKED_CONTENT_COLOR)
						end
					end

					do -- ON MOUSE UP
						function Frame:Animation_Text_OnMouseUp_StopEvent()
							return Frame.isMouseDown
						end

						function Frame:Animation_Text_OnMouseUp(skipAnimation)
							if Frame.isMouseOver then
								Frame:Animation_Text_OnEnter(true)
							else
								Frame:Animation_Text_OnLeave(true)
							end
						end
					end
				end

				do -- LOGIC
					do -- FUNCTIONS
						do -- SET
							function Frame:SetText(text)
								Frame.REF_MAIN_TEXT:SetText(text)
							end
						end
					end

					do -- EVENTS
						local function Event_OnEnter(frame, skipAnimation)
							Frame:Animation_Text_OnEnter(skipAnimation)
						end

						local function Event_OnLeave(frame, skipAnimation)
							Frame:Animation_Text_OnLeave(skipAnimation)
						end

						local function Event_OnMouseDown(frame, skipAnimation)
							Frame:Animation_Text_OnMouseDown(skipAnimation)
						end

						local function Event_OnMouseUp(frame, skipAnimation)
							Frame:Animation_Text_OnMouseUp(skipAnimation)
						end

						table.insert(Frame.enterCallbacks, Event_OnEnter)
						table.insert(Frame.leaveCallbacks, Event_OnLeave)
						table.insert(Frame.mouseDownCallbacks, Event_OnMouseDown)
						table.insert(Frame.mouseUpCallbacks, Event_OnMouseUp)
					end
				end

				do -- SETUP
					Frame:OnLeave(true)
				end

				--------------------------------

				return Frame
			end)

			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Button.Text.Red", function(parent, frameStrata, frameLevel, data, name)
				local Frame = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Button.Text.Template", parent, frameStrata, frameLevel, {
					["resize"] = data.resize,
					["PADDING_CONTENT"] = PADDING,
					["DEFAULT_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-red.png",
					["DEFAULT_CONTENT_COLOR"] = addon.CS:GetSharedColor().RGB_YELLOW,
					["HIGHLIGHTED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-red-highlighted.png",
					["HIGHLIGHTED_CONTENT_COLOR"] = addon.CS:GetSharedColor().RGB_YELLOW,
					["CLICKED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-red-clicked.png",
					["CLICKED_CONTENT_COLOR"] = addon.CS:GetSharedColor().RGB_YELLOW,
				}, name)

				--------------------------------

				return Frame
			end)

			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Button.Text.Grey", function(parent, frameStrata, frameLevel, data, name)
				local Frame = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Button.Text.Template", parent, frameStrata, frameLevel, {
					["resize"] = data.resize,
					["PADDING_CONTENT"] = PADDING,
					["DEFAULT_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-grey.png",
					["DEFAULT_CONTENT_COLOR"] = addon.CS:GetSharedColor().RGB_WHITE,
					["HIGHLIGHTED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-grey-highlighted.png",
					["HIGHLIGHTED_CONTENT_COLOR"] = addon.CS:GetSharedColor().RGB_WHITE,
					["CLICKED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-grey-clicked.png",
					["CLICKED_CONTENT_COLOR"] = addon.CS:GetSharedColor().RGB_WHITE,
				}, name)

				--------------------------------

				return Frame
			end)

			--------------------------------

			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Button.Image.Template", function(parent, frameStrata, frameLevel, data, name)
				local DEFAULT_IMAGE_TEXTURE = data.DEFAULT_IMAGE_TEXTURE
				local HIGHLIGHTED_IMAGE_TEXTURE = data.HIGHLIGHTED_IMAGE_TEXTURE
				local CLICKED_IMAGE_TEXTURE = data.CLICKED_IMAGE_TEXTURE

				--------------------------------

				local Frame = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Button.Template", parent, frameStrata, frameLevel, data, name)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				--------------------------------

				do -- ELEMENTS
					do -- MAIN
						local Main = Frame.REF_MAIN

						--------------------------------

						do -- IMAGE
							Main.Image, Main.ImageTexture = addon.C.FrameTemplates:CreateTexture(Main, frameStrata, DEFAULT_IMAGE_TEXTURE, "$parent.Image")
							Main.Image:SetPoint("CENTER", Main)
							Main.Image:SetFrameStrata(frameStrata)
							Main.Image:SetFrameLevel(frameLevel + 3)
							addon.C.API.FrameUtil:SetDynamicSize(Main.Image, Main, 0, 0)
						end
					end
				end

				do -- REFERENCES
					-- MAIN
					Frame.REF_MAIN_IMAGE = Frame.REF_MAIN.Image
					Frame.REF_MAIN_IMAGE_TEXTURE = Frame.REF_MAIN.ImageTexture
				end

				do -- ANIMATIONS
					local function SetStyle(imageTexture)
						Frame.REF_MAIN_IMAGE_TEXTURE:SetTexture(imageTexture)
					end

					--------------------------------

					do -- ON ENTER
						function Frame:Animation_Image_OnEnter_StopEvent()
							return not Frame.isMouseOver
						end

						function Frame:Animation_Image_OnEnter(skipAnimation)
							SetStyle(HIGHLIGHTED_IMAGE_TEXTURE)
						end
					end

					do -- ON LEAVE
						function Frame:Animation_Image_OnLeave_StopEvent()
							return Frame.isMouseOver
						end

						function Frame:Animation_Image_OnLeave(skipAnimation)
							SetStyle(DEFAULT_IMAGE_TEXTURE)
						end
					end

					do -- ON MOUSE DOWN
						function Frame:Animation_Image_OnMouseDown_StopEvent()
							return not Frame.isMouseDown
						end

						function Frame:Animation_Image_OnMouseDown(skipAnimation)
							SetStyle(CLICKED_IMAGE_TEXTURE)
						end
					end

					do -- ON MOUSE UP
						function Frame:Animation_Image_OnMouseUp_StopEvent()
							return Frame.isMouseDown
						end

						function Frame:Animation_Image_OnMouseUp(skipAnimation)
							if Frame.isMouseOver then
								Frame:Animation_Image_OnEnter(true)
							else
								Frame:Animation_Image_OnLeave(true)
							end
						end
					end
				end

				do -- LOGIC
					do -- FUNCTIONS
						do -- SET
							function Frame:SetImage(texture)
								Frame.REF_MAIN_IMAGE_TEXTURE:SetTexture(texture)
							end
						end
					end

					do -- EVENTS
						local function Event_OnEnter(frame, skipAnimation)
							Frame:Animation_Image_OnEnter(skipAnimation)
						end

						local function Event_OnLeave(frame, skipAnimation)
							Frame:Animation_Image_OnLeave(skipAnimation)
						end

						local function Event_OnMouseDown(frame, skipAnimation)
							Frame:Animation_Image_OnMouseDown(skipAnimation)
						end

						local function Event_OnMouseUp(frame, skipAnimation)
							Frame:Animation_Image_OnMouseUp(skipAnimation)
						end

						table.insert(Frame.enterCallbacks, Event_OnEnter)
						table.insert(Frame.leaveCallbacks, Event_OnLeave)
						table.insert(Frame.mouseDownCallbacks, Event_OnMouseDown)
						table.insert(Frame.mouseUpCallbacks, Event_OnMouseUp)
					end
				end

				do -- SETUP
					Frame:OnLeave(true)
				end

				--------------------------------

				return Frame
			end)

			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Button.Image.Red", function(parent, frameStrata, frameLevel, data, name)
				local Frame = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Button.Image.Template", parent, frameStrata, frameLevel, {
					["PADDING_CONTENT"] = data.PADDING_CONTENT,
					["DEFAULT_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-red.png",
					["DEFAULT_IMAGE_TEXTURE"] = data.DEFAULT_IMAGE_TEXTURE,
					["HIGHLIGHTED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-red-highlighted.png",
					["HIGHLIGHTED_IMAGE_TEXTURE"] = data.HIGHLIGHTED_IMAGE_TEXTURE,
					["CLICKED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-red-clicked.png",
					["CLICKED_IMAGE_TEXTURE"] = data.CLICKED_IMAGE_TEXTURE,
				}, name)

				--------------------------------

				return Frame
			end)

			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Button.Image.Grey", function(parent, frameStrata, frameLevel, data, name)
				local Frame = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Button.Image.Template", parent, frameStrata, frameLevel, {
					["PADDING_CONTENT"] = data.PADDING_CONTENT,
					["DEFAULT_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-grey.png",
					["DEFAULT_IMAGE_TEXTURE"] = data.DEFAULT_IMAGE_TEXTURE,
					["HIGHLIGHTED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-grey-highlighted.png",
					["HIGHLIGHTED_IMAGE_TEXTURE"] = data.HIGHLIGHTED_IMAGE_TEXTURE,
					["CLICKED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-grey-clicked.png",
					["CLICKED_IMAGE_TEXTURE"] = data.CLICKED_IMAGE_TEXTURE,
				}, name)

				--------------------------------

				return Frame
			end)

			--------------------------------

			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Button.Dropdown.Template", function(parent, frameStrata, frameLevel, data, name)
				local resizeContextMenu = data.resizeContextMenu

				local DEFAULT_IMAGE_TEXTURE = data.DEFAULT_IMAGE_TEXTURE
				local DEFAULT_CONTENT_COLOR = data.DEFAULT_CONTENT_COLOR
				local HIGHLIGHTED_IMAGE_TEXTURE = data.HIGHLIGHTED_IMAGE_TEXTURE
				local HIGHLIGHTED_CONTENT_COLOR = data.HIGHLIGHTED_CONTENT_COLOR
				local CLICKED_IMAGE_TEXTURE = data.CLICKED_IMAGE_TEXTURE
				local CLICKED_CONTENT_COLOR = data.CLICKED_CONTENT_COLOR

				--------------------------------

				local Frame = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Button.Template", parent, frameStrata, frameLevel, data, name)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				--------------------------------

				do -- ELEMENTS
					do -- MAIN
						local Main = Frame.REF_MAIN

						--------------------------------

						do -- TEXT FRAME
							Main.TextFrame = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.TextFrame", Main)
							Main.TextFrame:SetPoint("LEFT", Main, PADDING, 0)
							Main.TextFrame:SetFrameStrata(frameStrata)
							Main.TextFrame:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Main.TextFrame, Main, function(relativeWidth, relativeHeight) return relativeWidth - relativeHeight - PADDING end, 0)

							local TextFrame = Main.TextFrame

							--------------------------------

							do -- TEXT
								TextFrame.Text = addon.C.FrameTemplates:CreateText(TextFrame, DEFAULT_CONTENT_COLOR, 12.5, "LEFT", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Text")
								TextFrame.Text:SetPoint("CENTER", TextFrame)
								TextFrame.Text:SetMaxLines(1)
								addon.C.API.FrameUtil:SetDynamicSize(TextFrame.Text, TextFrame, 0, 0)
							end
						end

						do -- IMAGE FRAME
							Main.ImageFrame = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.ImageFrame", Main)
							Main.ImageFrame:SetPoint("RIGHT", Main)
							Main.ImageFrame:SetFrameStrata(frameStrata)
							Main.ImageFrame:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Main.ImageFrame, Main, function(relativeWidth, relativeHeight) return relativeHeight end, function(relativeWidth, relativeHeight) return relativeHeight end)

							local ImageFrame = Main.ImageFrame

							--------------------------------

							do -- BACKGROUND
								ImageFrame.Background, ImageFrame.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(ImageFrame, frameStrata, DEFAULT_IMAGE_TEXTURE, "$parent.Background")
								ImageFrame.Background:SetSize(12.5, 12.5)
								ImageFrame.Background:SetPoint("CENTER", ImageFrame)
								ImageFrame.Background:SetFrameStrata(frameStrata)
								ImageFrame.Background:SetFrameLevel(frameLevel + 3)
							end
						end
					end
				end

				do -- REFERENCES
					-- MAIN
					Frame.REF_TEXT = Frame.REF_MAIN.TextFrame.Text
					Frame.REF_IMAGE = Frame.REF_MAIN.ImageFrame.BackgroundTexture
				end

				do -- ANIMATIONS
					local function SetStyle(imageTexture, contentColor)
						Frame.REF_IMAGE:SetTexture(imageTexture)
						Frame.REF_TEXT:SetTextColor(contentColor.r, contentColor.g, contentColor.b, contentColor.a or 1)
					end

					--------------------------------

					do -- ON ENTER
						function Frame:Animation_Dropdown_OnEnter_StopEvent()
							return not Frame.isMouseOver
						end

						function Frame:Animation_Dropdown_OnEnter(skipAnimation)
							SetStyle(HIGHLIGHTED_IMAGE_TEXTURE, HIGHLIGHTED_CONTENT_COLOR)
						end
					end

					do -- ON LEAVE
						function Frame:Animation_Dropdown_OnLeave_StopEvent()
							return Frame.isMouseOver
						end

						function Frame:Animation_Dropdown_OnLeave(skipAnimation)
							SetStyle(DEFAULT_IMAGE_TEXTURE, DEFAULT_CONTENT_COLOR)
						end
					end

					do -- ON MOUSE DOWN
						function Frame:Animation_Dropdown_OnMouseDown_StopEvent()
							return not Frame.isMouseDown
						end

						function Frame:Animation_Dropdown_OnMouseDown(skipAnimation)
							SetStyle(CLICKED_IMAGE_TEXTURE, CLICKED_CONTENT_COLOR)
						end
					end

					do -- ON MOUSE UP
						function Frame:Animation_Dropdown_OnMouseUp_StopEvent()
							return Frame.isMouseDown
						end

						function Frame:Animation_Dropdown_OnMouseUp(skipAnimation)
							if Frame.isMouseOver then
								Frame:Animation_Dropdown_OnEnter(true)
							else
								Frame:Animation_Dropdown_OnLeave(true)
							end
						end
					end
				end

				do -- LOGIC
					Frame.value = nil
					Frame.layoutInfo = {}

					Frame.onValueChangedCallbacks = {}

					--------------------------------

					do -- FUNCTIONS
						do -- SET
							function Frame:SetText(text)
								Frame.REF_TEXT:SetText(text)
							end

							function Frame:SetDropdownInfo(valueTable, startValue)
								local data = type(valueTable) == "function" and valueTable() or valueTable
								local layoutInfo = {}

								--------------------------------

								for i = 1, #data do
									local elementInfo = {
										["name"] = data[i],
										["type"] = "Button",
										["callback"] = function() Frame:ContextMenu_SetValue(i, true) end,
										["enabled"] = function() return Frame:ContextMenu_ActiveValueCheck(i) end,
									}

									table.insert(layoutInfo, elementInfo)
								end

								--------------------------------

								Frame.layoutInfo = layoutInfo
								Frame:ContextMenu_SetValue(startValue, false)
							end
						end

						do -- GET
							function Frame:GetValue()
								return Frame.value
							end
						end

						do -- LOGIC
							function Frame:ContextMenu_SetValue(index, userInput)
								Frame.value = index
								Frame:SetText(Frame.layoutInfo[index].name)

								--------------------------------

								if userInput then
									do -- ON VALUE CHANGED
										local onValueChangedCallbacks = Frame.onValueChangedCallbacks

										if #onValueChangedCallbacks >= 1 then
											for callback = 1, #onValueChangedCallbacks do
												onValueChangedCallbacks[callback](Frame, index, userInput)
											end
										end
									end
								end
							end

							function Frame:ContextMenu_ActiveValueCheck(index)
								return Frame.value == index
							end
						end
					end

					do -- EVENTS
						local function Logic_OnClick()
							if addon.C.Frame.ContextMenu.Script:Main_IsShown() then
								addon.C.Frame.ContextMenu.Script:Main_Hide()
							else
								addon.C.Frame.ContextMenu.Script:Main_Show({
									["parent"] = Frame,
									["buttonParent"] = Frame,
									["point"] = "TOP",
									["relativePoint"] = "BOTTOM",
									["offsetX"] = 0,
									["offsetY"] = -10,
									["width"] = resizeContextMenu and Frame:GetWidth() or 200,
									["layoutInfo"] = Frame.layoutInfo,
								})
							end
						end

						Frame:SetClick(Logic_OnClick)
					end
				end

				do -- SETUP
					Frame:OnLeave(true)
				end

				--------------------------------

				return Frame
			end)

			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Button.Dropdown", function(parent, frameStrata, frameLevel, data, name)
				local Frame = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Button.Dropdown.Template", parent, frameStrata, frameLevel, {
					["resizeContextMenu"] = data.resizeContextMenu,
					["PADDING_CONTENT"] = PADDING,
					["DEFAULT_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-grey.png",
					["DEFAULT_CONTENT_COLOR"] = addon.CS:GetSharedColor().RGB_WHITE,
					["DEFAULT_IMAGE_TEXTURE"] = addon.CS:NewIcon("arrow-up-down"),
					["HIGHLIGHTED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-grey-highlighted.png",
					["HIGHLIGHTED_CONTENT_COLOR"] = addon.CS:GetSharedColor().RGB_WHITE,
					["HIGHLIGHTED_IMAGE_TEXTURE"] = addon.CS:NewIcon("arrow-up-down"),
					["CLICKED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "button-background-grey-clicked.png",
					["CLICKED_CONTENT_COLOR"] = addon.CS:GetSharedColor().RGB_WHITE,
					["CLICKED_IMAGE_TEXTURE"] = addon.CS:NewIcon("arrow-up-down"),
				}, name)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				--------------------------------

				return Frame
			end)
		end

		do -- CHECKBOX
			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Checkbox.Template", function(parent, frameStrata, frameLevel, data, name)
				local DEFAULT_BACKGROUND_TEXTURE = data.DEFAULT_BACKGROUND_TEXTURE
				local DEFAULT_CHECK_TEXTURE = data.DEFAULT_CHECK_TEXTURE
				local DEFAULT_CHECK_COLOR = data.DEFAULT_CHECK_COLOR
				local HIGHLIGHTED_BACKGROUND_TEXTURE = data.HIGHLIGHTED_BACKGROUND_TEXTURE
				local HIGHLIGHTED_CHECK_TEXTURE = data.HIGHLIGHTED_CHECK_TEXTURE
				local HIGHLIGHTED_CHECK_COLOR = data.HIGHLIGHTED_CHECK_COLOR
				local CLICKED_BACKGROUND_TEXTURE = data.CLICKED_BACKGROUND_TEXTURE
				local CLICKED_CHECK_TEXTURE = data.CLICKED_CHECK_TEXTURE
				local CLICKED_CHECK_COLOR = data.CLICKED_CHECK_COLOR

				--------------------------------

				local Frame = addon.C.FrameTemplates:CreateCheckbox(parent, name)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				--------------------------------

				do -- ELEMENTS
					do -- CONTENT
						local Content = Frame.Content

						--------------------------------

						do -- BACKGROUND
							Content.Background, Content.BackgroundTexture = addon.C.FrameTemplates:CreateNineSlice(Content, frameStrata, DEFAULT_BACKGROUND_TEXTURE, 125, .0575, "$parent.Background", Enum.UITextureSliceMode.Stretched)
							Content.Background:SetPoint("CENTER", Content)
							Content.Background:SetFrameStrata(frameStrata)
							Content.Background:SetFrameLevel(frameLevel + 1)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Background, Content, -7.5, -7.5)
						end

						do -- CHECK
							Content.Check, Content.CheckTexture = addon.C.FrameTemplates:CreateTexture(Content, frameStrata, DEFAULT_CHECK_TEXTURE, "$parent.Check")
							Content.Check:SetPoint("CENTER", Content)
							Content.Check:SetFrameStrata(frameStrata)
							Content.Check:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Check, Content, 0, 0)
						end
					end
				end

				do -- REFERENCES
					-- CORE
					Frame.REF_BACKGROUND = Frame.REF_CONTENT.Background
					Frame.REF_CHECK = Frame.REF_CONTENT.Check

					-- BACKGROUND
					Frame.REF_BACKGROUND_TEXTURE = Frame.REF_CONTENT.BackgroundTexture

					-- CHECK
					Frame.REF_CHECK_TEXTURE = Frame.REF_CONTENT.CheckTexture
				end

				do -- ANIMATIONS
					local function SetStyle(backgroundTexture, checkTexture, checkColor)
						Frame.REF_BACKGROUND_TEXTURE:SetTexture(backgroundTexture)
						Frame.REF_CHECK_TEXTURE:SetTexture(checkTexture)
						Frame.REF_CHECK_TEXTURE:SetVertexColor(checkColor.r, checkColor.g, checkColor.b, checkColor.a)
					end

					--------------------------------

					do -- ON ENTER
						function Frame:Animation_OnEnter_StopEvent()
							return not Frame.isMouseOver
						end

						function Frame:Animation_OnEnter(skipAnimation)
							SetStyle(HIGHLIGHTED_BACKGROUND_TEXTURE, HIGHLIGHTED_CHECK_TEXTURE, HIGHLIGHTED_CHECK_COLOR)
						end
					end

					do -- ON LEAVE
						function Frame:Animation_OnLeave_StopEvent()
							return Frame.isMouseOver
						end

						function Frame:Animation_OnLeave(skipAnimation)
							SetStyle(DEFAULT_BACKGROUND_TEXTURE, DEFAULT_CHECK_TEXTURE, DEFAULT_CHECK_COLOR)
						end
					end

					do -- ON MOUSE DOWN
						function Frame:Animation_OnMouseDown_StopEvent()
							return not Frame.isMouseDown
						end

						function Frame:Animation_OnMouseDown(skipAnimation)
							SetStyle(CLICKED_BACKGROUND_TEXTURE, CLICKED_CHECK_TEXTURE, CLICKED_CHECK_COLOR)
						end
					end

					do -- ON MOUSE UP
						function Frame:Animation_OnMouseUp_StopEvent()
							return Frame.isMouseDown
						end

						function Frame:Animation_OnMouseUp(skipAnimation)
							if Frame.isMouseOver then
								SetStyle(HIGHLIGHTED_BACKGROUND_TEXTURE, HIGHLIGHTED_CHECK_TEXTURE, HIGHLIGHTED_CHECK_COLOR)
							else
								SetStyle(DEFAULT_BACKGROUND_TEXTURE, DEFAULT_CHECK_TEXTURE, DEFAULT_CHECK_COLOR)
							end
						end
					end
				end

				do -- LOGIC
					do -- FUNCTIONS

					end

					do -- EVENTS
						local function Event_OnEnter(frame, skipAnimation)
							Frame:Animation_OnEnter(skipAnimation)
						end

						local function Event_OnLeave(frame, skipAnimation)
							Frame:Animation_OnLeave(skipAnimation)
						end

						local function Event_OnMouseDown(frame, skipAnimation)
							Frame:Animation_OnMouseDown(skipAnimation)

							--------------------------------

							PlaySound(856)
						end

						local function Event_OnMouseUp(frame, skipAnimation)
							Frame:Animation_OnMouseUp(skipAnimation)
						end

						local function Event_OnValueChanged(frame, value, userInput)
							Frame.REF_CHECK:SetShown(value)
						end

						table.insert(Frame.enterCallbacks, Event_OnEnter)
						table.insert(Frame.leaveCallbacks, Event_OnLeave)
						table.insert(Frame.mouseDownCallbacks, Event_OnMouseDown)
						table.insert(Frame.mouseUpCallbacks, Event_OnMouseUp)
						table.insert(Frame.onValueChangedCallbacks, Event_OnValueChanged)
					end
				end

				do -- SETUP
					Frame:OnLeave(true)
					Frame:SetChecked(false, false)
				end

				--------------------------------

				return Frame
			end)

			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Checkbox", function(parent, frameStrata, frameLevel, data, name)
				local Frame = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Checkbox.Template", parent, frameStrata, frameLevel, {
					["DEFAULT_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "checkbox-background.png",
					["DEFAULT_CHECK_TEXTURE"] = addon.CS:GetCommonPathElement() .. "checkbox-tick.png",
					["DEFAULT_CHECK_COLOR"] = addon.CS:GetSharedColor().RGB_WHITE,
					["HIGHLIGHTED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "checkbox-background-highlighted.png",
					["HIGHLIGHTED_CHECK_TEXTURE"] = addon.CS:GetCommonPathElement() .. "checkbox-tick.png",
					["HIGHLIGHTED_CHECK_COLOR"] = addon.CS:GetSharedColor().RGB_WHITE,
					["CLICKED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "checkbox-background-highlighted.png",
					["CLICKED_CHECK_TEXTURE"] = addon.CS:GetCommonPathElement() .. "checkbox-tick.png",
					["CLICKED_CHECK_COLOR"] = addon.CS:GetSharedColor().RGB_WHITE,
				}, name)

				--------------------------------

				return Frame
			end)
		end

		do -- RANGE
			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Range.Template", function(parent, frameStrata, frameLevel, data, name)
				local DEFAULT_BACKGROUND_TEXTURE = data.DEFAULT_BACKGROUND_TEXTURE
				local DEFAULT_THUMB_TEXTURE = data.DEFAULT_THUMB_TEXTURE
				local HIGHLIGHTED_BACKGROUND_TEXTURE = data.HIGHLIGHTED_BACKGROUND_TEXTURE
				local HIGHLIGHTED_THUMB_TEXTURE = data.HIGHLIGHTED_THUMB_TEXTURE
				local CLICKED_BACKGROUND_TEXTURE = data.CLICKED_BACKGROUND_TEXTURE
				local CLICKED_THUMB_TEXTURE = data.CLICKED_THUMB_TEXTURE

				--------------------------------

				local Frame = addon.C.FrameTemplates:CreateRange(parent, { orientation = "HORIZONTAL", thumbSize = 17.5 }, name)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				--------------------------------

				do -- ELEMENTS
					do -- CONTENT
						local Content = Frame.Content

						--------------------------------

						do -- BACKGROUND
							Content.Background, Content.BackgroundTexture = addon.C.FrameTemplates:CreateNineSlice(Content, frameStrata, DEFAULT_BACKGROUND_TEXTURE, 125, .0375, "$parent.Background", Enum.UITextureSliceMode.Stretched)
							Content.Background:SetPoint("CENTER", Content)
							Content.Background:SetFrameStrata(frameStrata)
							Content.Background:SetFrameLevel(frameLevel + 1)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Background, Content, -2.5, -2.5)
						end

						do -- THUMB
							Content.Thumb = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Thumb", Content)
							Content.Thumb:SetSize(17.5, 17.5)
							Content.Thumb:SetPoint("CENTER", Frame.REF_THUMB_ANCHOR)
							Content.Thumb:SetFrameStrata(frameStrata)
							Content.Thumb:SetFrameLevel(frameLevel + 2)

							local Thumb = Content.Thumb

							--------------------------------

							do -- BACKGROUND
								Thumb.Background, Thumb.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(Thumb, frameStrata, DEFAULT_THUMB_TEXTURE, "$parent.Background")
								Thumb.Background:SetPoint("CENTER", Thumb)
								Thumb.Background:SetFrameStrata(frameStrata)
								Thumb.Background:SetFrameLevel(frameLevel + 3)
								addon.C.API.FrameUtil:SetDynamicSize(Thumb.Background, Thumb, 0, 0)
							end
						end
					end
				end

				do -- REFERENCES
					-- CORE
					Frame.REF_BACKGROUND = Frame.REF_CONTENT.Background
					Frame.REF_THUMB = Frame.REF_CONTENT.Thumb

					-- BACKGROUND
					Frame.REF_BACKGROUND_TEXTURE = Frame.REF_CONTENT.BackgroundTexture

					-- THUMB
					Frame.REF_THUMB_BACKGROUND = Frame.REF_THUMB.Background
					Frame.REF_THUMB_BACKGROUND_TEXTURE = Frame.REF_THUMB.BackgroundTexture
				end

				do -- ANIMATIONS
					local function SetStyle(backgroundTexture, thumbTexture)
						Frame.REF_BACKGROUND_TEXTURE:SetTexture(backgroundTexture)
						Frame.REF_THUMB_BACKGROUND_TEXTURE:SetTexture(thumbTexture)
					end

					--------------------------------

					do -- ON ENTER
						function Frame:Animation_OnEnter_StopEvent()
							return not Frame.isMouseOver
						end

						function Frame:Animation_OnEnter(skipAnimation)
							SetStyle(HIGHLIGHTED_BACKGROUND_TEXTURE, HIGHLIGHTED_THUMB_TEXTURE)
						end
					end

					do -- ON LEAVE
						function Frame:Animation_OnLeave_StopEvent()
							return Frame.isMouseOver
						end

						function Frame:Animation_OnLeave(skipAnimation)
							SetStyle(DEFAULT_BACKGROUND_TEXTURE, DEFAULT_THUMB_TEXTURE)
						end
					end

					do -- ON MOUSE DOWN
						function Frame:Animation_OnMouseDown_StopEvent()
							return not Frame.isMouseDown
						end

						function Frame:Animation_OnMouseDown(skipAnimation)
							SetStyle(CLICKED_BACKGROUND_TEXTURE, CLICKED_THUMB_TEXTURE)
						end
					end

					do -- ON MOUSE UP
						function Frame:Animation_OnMouseUp_StopEvent()
							return Frame.isMouseDown
						end

						function Frame:Animation_OnMouseUp(skipAnimation)
							if Frame.isMouseOver then
								SetStyle(HIGHLIGHTED_BACKGROUND_TEXTURE, HIGHLIGHTED_THUMB_TEXTURE)
							else
								SetStyle(DEFAULT_BACKGROUND_TEXTURE, DEFAULT_THUMB_TEXTURE)
							end
						end
					end
				end

				do -- LOGIC
					do -- FUNCTIONS
						do -- SET

						end

						do -- LOGIC

						end
					end

					do -- EVENTS
						local function Event_OnEnter(frame, skipAnimation)
							Frame:Animation_OnEnter(skipAnimation)
						end

						local function Event_OnLeave(frame, skipAnimation)
							Frame:Animation_OnLeave(skipAnimation)
						end

						local function Event_OnMouseDown(frame, skipAnimation)
							Frame:Animation_OnMouseDown(skipAnimation)

							--------------------------------

							PlaySound(856)
						end

						local function Event_OnMouseUp(frame, skipAnimation)
							Frame:Animation_OnMouseUp(skipAnimation)
						end

						local function Event_OnValueChanged(frame, value)

						end

						table.insert(Frame.enterCallbacks, Event_OnEnter)
						table.insert(Frame.leaveCallbacks, Event_OnLeave)
						table.insert(Frame.mouseDownCallbacks, Event_OnMouseDown)
						table.insert(Frame.mouseUpCallbacks, Event_OnMouseUp)
						table.insert(Frame.onValueChangedCallbacks, Event_OnValueChanged)
					end
				end

				do -- SETUP
					Frame:OnLeave(true)
				end

				--------------------------------

				return Frame
			end)

			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Range", function(parent, frameStrata, frameLevel, data, name)
				local Frame = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Range.Template", parent, frameStrata, frameLevel, {
					["DEFAULT_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "range-background.png",
					["DEFAULT_THUMB_TEXTURE"] = addon.CS:GetCommonPathElement() .. "range-thumb-flat.png",
					["HIGHLIGHTED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "range-background.png",
					["HIGHLIGHTED_THUMB_TEXTURE"] = addon.CS:GetCommonPathElement() .. "range-thumb-flat-highlighted.png",
					["CLICKED_BACKGROUND_TEXTURE"] = addon.CS:GetCommonPathElement() .. "range-background.png",
					["CLICKED_THUMB_TEXTURE"] = addon.CS:GetCommonPathElement() .. "range-thumb-flat-clicked.png",
				}, name)

				--------------------------------

				return Frame
			end)

			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Range.Text", function(parent, frameStrata, frameLevel, data, name)
				local rangeWidth, resize, direction = data.rangeWidth, data.resize, data.direction

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

						do -- LAYOUT GROUP
							Content.LayoutGroup, Content.LayoutGroup_Sort = addon.C.FrameTemplates:CreateLayoutGroup(Content, { point = "LEFT", direction = "horizontal", resize = false, padding = PADDING, distribute = false, distributeResizeElements = false, excludeHidden = true, autoSort = true, customOffset = nil, customLayoutSort = nil }, "$parent.LayoutGroup")
							Content.LayoutGroup:SetPoint("CENTER", Content)
							Content.LayoutGroup:SetFrameStrata(frameStrata)
							Content.LayoutGroup:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Content.LayoutGroup, Content, 0, 0)
							Frame.LGS_CONTENT = Content.LayoutGroup_Sort

							local LayoutGroup = Content.LayoutGroup

							--------------------------------

							do -- ELEMENTS
								do -- MAIN
									LayoutGroup.Main = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Main", LayoutGroup)
									LayoutGroup.Main:SetWidth(rangeWidth)
									LayoutGroup.Main:SetFrameStrata(frameStrata)
									LayoutGroup.Main:SetFrameLevel(frameLevel + 3)
									addon.C.API.FrameUtil:SetDynamicSize(LayoutGroup.Main, LayoutGroup, nil, 0)

									local Main = LayoutGroup.Main

									--------------------------------

									do -- CONTENT
										Main.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Main)
										Main.Content:SetPoint("CENTER", Main)
										Main.Content:SetFrameStrata(frameStrata)
										Main.Content:SetFrameLevel(frameLevel + 4)
										addon.C.API.FrameUtil:SetDynamicSize(Main.Content, Main, 0, 0)

										local Main_Content = Main.Content

										--------------------------------

										do -- RANGE
											Main_Content.Range = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Range", Main_Content, frameStrata, frameLevel + 5, nil, "$parent.Range")
											Main_Content.Range:SetPoint("CENTER", Main_Content)
											Main_Content.Range:SetFrameStrata(frameStrata)
											Main_Content.Range:SetFrameLevel(frameLevel + 6)
											addon.C.API.FrameUtil:SetDynamicSize(Main_Content.Range, Main_Content, 0, 0)
										end
									end
								end

								do -- INFO
									LayoutGroup.Info = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Info", LayoutGroup)
									LayoutGroup.Info:SetFrameStrata(frameStrata)
									LayoutGroup.Info:SetFrameLevel(frameLevel + 3)

									if resize then
										addon.C.API.FrameUtil:SetDynamicSize(LayoutGroup.Info, LayoutGroup, nil, 0)
										addon.C.API.FrameUtil:SetDynamicSize(Frame, LayoutGroup.Info, function(relativeWidth, relativeHeight) return relativeWidth + rangeWidth + PADDING end)
									else
										addon.C.API.FrameUtil:SetDynamicSize(LayoutGroup.Info, LayoutGroup, function(relativeWidth, relativeHeight) return relativeWidth - rangeWidth - PADDING end, 0)
									end

									local Info = LayoutGroup.Info

									--------------------------------

									do -- CONTENT
										Info.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Info)
										Info.Content:SetPoint("CENTER", Info)
										Info.Content:SetFrameStrata(frameStrata)
										Info.Content:SetFrameLevel(frameLevel + 4)
										addon.C.API.FrameUtil:SetDynamicSize(Info.Content, Info, 0, 0)

										local Info_Content = Info.Content

										--------------------------------

										do -- TEXT
											Info_Content.Text = addon.C.FrameTemplates:CreateText(Info_Content, addon.CS:GetSharedColor().RGB_YELLOW, 12.5, direction == "LEFT" and "RIGHT" or "LEFT", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Text", "GameFontNormal")
											Info_Content.Text:SetPoint("CENTER", Info_Content)

											if resize then
												Info_Content.Text:SetAutoFit(true)
												Info_Content.Text:SetAutoFit_MaxWidth(10000)
												addon.C.API.FrameUtil:SetDynamicSize(Info, Info_Content.Text, 0, nil)
											else
												addon.C.API.FrameUtil:SetDynamicSize(Info_Content.Text, Info_Content, 0, 0)
											end
										end
									end
								end

								do -- LAYOUT
									if direction == "LEFT" then
										LayoutGroup:AddElement(LayoutGroup.Info)
										LayoutGroup:AddElement(LayoutGroup.Main)
									else
										LayoutGroup:AddElement(LayoutGroup.Main)
										LayoutGroup:AddElement(LayoutGroup.Info)
									end
								end
							end
						end
					end
				end

				do -- REFERENCES
					-- CORE
					Frame.REF_CONTENT = Frame.Content
					Frame.REF_LAYOUT = Frame.REF_CONTENT.LayoutGroup
					Frame.REF_RANGE = Frame.REF_LAYOUT.Main.Content.Range
					Frame.REF_TEXT = Frame.REF_LAYOUT.Info.Content.Text
				end

				do -- LOGIC
					do -- FUNCTIONS
						do -- SET
							function Frame:SetText(text)
								Frame.REF_TEXT:SetText(text)

								--------------------------------

								Frame:UpdateLayout()
							end
						end

						do -- LOGIC
							function Frame:UpdateLayout()
								Frame.LGS_CONTENT()
							end
						end
					end

					do -- EVENTS

					end
				end

				do -- SETUP

				end

				--------------------------------

				return Frame
			end)
		end

		do -- SCROLL BAR
			PrefabRegistry:Add("C.FrameTemplates.Blizzard.ScrollBar", function(parent, frameStrata, frameLevel, data, name)
				local DEFAULT_THUMB_TEXTURE = addon.CS:GetCommonPathElement() .. "scrollbar-thumb.png"
				local HIGHLIGHTED_THUMB_TEXTURE = addon.CS:GetCommonPathElement() .. "scrollbar-thumb-highlighted.png"
				local CLICKED_THUMB_TEXTURE = addon.CS:GetCommonPathElement() .. "scrollbar-thumb-clicked.png"

				--------------------------------

				local Frame = addon.C.FrameTemplates:CreateScrollBar(parent, data, name)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				local Track = Frame.REF_TRACK
				local Thumb = Frame.REF_THUMB

				--------------------------------

				do -- ELEMENTS
					do -- TRACK
						do -- BACKGROUND
							Track.Background, Track.BackgroundTexture = addon.C.FrameTemplates:CreateNineSlice(Track, frameStrata, addon.CS:GetCommonPathElement() .. "frame.png", 125, .075, "$parent.Background", Enum.UITextureSliceMode.Stretched)
							Track.Background:SetPoint("CENTER", Track)
							Track.Background:SetFrameStrata(frameStrata)
							Track.Background:SetFrameLevel(frameLevel + 1)
							addon.C.API.FrameUtil:SetDynamicSize(Track.Background, Track, -2.5, -2.5)

							Track.BackgroundTexture:SetVertexColor(.575, .575, .575, 1)
						end
					end

					do -- THUMB
						do -- BACKGROUND
							Thumb.Background, Thumb.BackgroundTexture = addon.C.FrameTemplates:CreateNineSlice(Thumb, frameStrata, DEFAULT_THUMB_TEXTURE, 90, .125, "$parent.Background", Enum.UITextureSliceMode.Stretched)
							Thumb.Background:SetPoint("CENTER", Thumb)
							Thumb.Background:SetFrameStrata(frameStrata)
							Thumb.Background:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Thumb.Background, Thumb, -2.5, -2.5)
						end
					end
				end

				do -- REFERENCES
					-- TRACK
					Frame.REF_TRACK_BACKGROUND = Frame.REF_TRACK.Background
					Frame.REF_TRACK_BACKGROUND_TEXTURE = Frame.REF_TRACK.BackgroundTexture

					-- THUMB
					Frame.REF_THUMB_BACKGROUND = Frame.REF_THUMB.Background
					Frame.REF_THUMB_BACKGROUND_TEXTURE = Frame.REF_THUMB.BackgroundTexture
				end

				do -- ANIMATIONS
					local function SetStyle(thumbTexture)
						Frame.REF_THUMB_BACKGROUND_TEXTURE:SetTexture(thumbTexture)
					end

					--------------------------------

					do -- ON ENTER
						function Frame:Animation_OnEnter_StopEvent()
							return not Frame.isMouseOver
						end

						function Frame:Animation_OnEnter(skipAnimation)
							SetStyle(HIGHLIGHTED_THUMB_TEXTURE)
						end
					end

					do -- ON LEAVE
						function Frame:Animation_OnLeave_StopEvent()
							return not Frame.isMouseOver
						end

						function Frame:Animation_OnLeave(skipAnimation)
							SetStyle(DEFAULT_THUMB_TEXTURE)
						end
					end

					do -- ON MOUSE DOWN
						function Frame:Animation_OnMouseDown_StopEvent()
							return not Frame.isMouseDown
						end

						function Frame:Animation_OnMouseDown(skipAnimation)
							SetStyle(CLICKED_THUMB_TEXTURE)
						end
					end

					do -- ON MOUSE UP
						function Frame:Animation_OnMouseUp_StopEvent()
							return not Frame.isMouseDown
						end

						function Frame:Animation_OnMouseUp(skipAnimation)
							if Frame.isMouseOver then
								Frame:Animation_OnEnter(skipAnimation)
							else
								Frame:Animation_OnLeave(skipAnimation)
							end
						end
					end
				end

				do -- LOGIC
					Frame.isMouseOver = false
					Frame.isMouseDown = false

					--------------------------------

					do -- EVENTS
						function Thumb:OnEnter(skipAnimation)
							Frame.isMouseOver = true

							--------------------------------

							Frame:Animation_OnEnter(skipAnimation)
						end

						function Thumb:OnLeave(skipAnimation)
							Frame.isMouseOver = false

							--------------------------------

							Frame:Animation_OnLeave(skipAnimation)
						end

						function Thumb:OnMouseDown(skipAnimation)
							Frame.isMouseDown = true

							--------------------------------

							Frame:Animation_OnMouseDown(skipAnimation)

							--------------------------------

							PlaySound(856)
						end

						function Thumb:OnMouseUp(skipAnimation)
							Frame.isMouseDown = false

							--------------------------------

							Frame:Animation_OnMouseUp(skipAnimation)
						end

						Thumb:HookScript("OnEnter", Thumb.OnEnter)
						Thumb:HookScript("OnLeave", Thumb.OnLeave)
						Thumb:HookScript("OnMouseDown", Thumb.OnMouseDown)
						Thumb:HookScript("OnMouseUp", Thumb.OnMouseUp)
					end
				end

				do -- SETUP
					Thumb:OnLeave(true)
				end

				--------------------------------

				return Frame
			end)
		end

		do -- COLOR INPUT
			PrefabRegistry:Add("C.FrameTemplates.Blizzard.Color", function(parent, frameStrata, frameLevel, data, name)
				local DEFAULT_BACKGROUND_TEXTURE = data.DEFAULT_BACKGROUND_TEXTURE or addon.CS:GetCommonPathArt() .. "Elements/color-background.png"
				local DEFAULT_IMAGE_TEXTURE = data.DEFAULT_IMAGE_TEXTURE or addon.CS:GetCommonPathArt() .. "Elements/color-input-background.png"
				local HIGHLIGHTED_BACKGROUND_TEXTURE = data.HIGHLIGHTED_BACKGROUND_TEXTURE or addon.CS:GetCommonPathArt() .. "Elements/color-background-highlighted.png"
				local HIGHLIGHTED_IMAGE_TEXTURE = data.HIGHLIGHTED_IMAGE_TEXTURE or addon.CS:GetCommonPathArt() .. "Elements/color-input-background-highlighted.png"
				local CLICKED_BACKGROUND_TEXTURE = data.CLICKED_BACKGROUND_TEXTURE or addon.CS:GetCommonPathArt() .. "Elements/color-background-highlighted.png"
				local CLICKED_IMAGE_TEXTURE = data.CLICKED_IMAGE_TEXTURE or addon.CS:GetCommonPathArt() .. "Elements/color-input-background-clicked.png"

				--------------------------------

				local Frame = addon.C.FrameTemplates:CreateButton(parent, name)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				--------------------------------

				do -- ELEMENTS
					do -- CONTENT
						local Content = Frame.REF_CONTENT

						--------------------------------

						do -- BACKGROUND
							Content.Background, Content.BackgroundTexture = addon.C.FrameTemplates:CreateNineSlice(Content, frameStrata, DEFAULT_BACKGROUND_TEXTURE, 125, .075, "$parent.Background", Enum.UITextureSliceMode.Stretched)
							Content.Background:SetPoint("CENTER", Content)
							Content.Background:SetFrameStrata(frameStrata)
							Content.Background:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Background, Content, -7.5, -7.5)
						end

						do -- COLOR
							Content.Color = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Color", Content)
							Content.Color:SetPoint("CENTER", Content)
							Content.Color:SetFrameStrata(frameStrata)
							Content.Color:SetFrameLevel(frameLevel + 3)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Color, Content, 5, 5)

							local Color = Content.Color

							--------------------------------

							do -- BACKGROUND
								Color.Background, Color.BackgroundTexture = addon.C.FrameTemplates:CreateNineSlice(Color, frameStrata, DEFAULT_IMAGE_TEXTURE, 125, .0325, "$parent.Background")
								Color.Background:SetPoint("CENTER", Color)
								Color.Background:SetFrameStrata(frameStrata)
								Color.Background:SetFrameLevel(frameLevel + 4)
								addon.C.API.FrameUtil:SetDynamicSize(Color.Background, Color, 0, 0)
							end
						end
					end
				end

				do -- REFERENCES
					-- CORE
					Frame.REF_BACKGROUND = Frame.REF_CONTENT.Background
					Frame.REF_COLOR = Frame.REF_CONTENT.Color

					-- BACKGROUND
					Frame.REF_BACKGROUND_TEXTURE = Frame.REF_CONTENT.BackgroundTexture

					-- COLOR
					Frame.REF_COLOR_BACKGROUND = Frame.REF_COLOR.Background
					Frame.REF_COLOR_BACKGROUND_TEXTURE = Frame.REF_COLOR.BackgroundTexture
				end

				do -- ANIMATIONS
					local function SetStyle(backgroundTexture, colorTexture)
						Frame.REF_BACKGROUND_TEXTURE:SetTexture(backgroundTexture)
						Frame.REF_COLOR_BACKGROUND_TEXTURE:SetTexture(colorTexture)
					end

					--------------------------------

					do -- ON ENTER
						function Frame:Animation_OnEnter_StopEvent()
							return not Frame.isMouseOver
						end

						function Frame:Animation_OnEnter(skipAnimation)
							SetStyle(HIGHLIGHTED_BACKGROUND_TEXTURE, HIGHLIGHTED_IMAGE_TEXTURE)
						end
					end

					do -- ON LEAVE
						function Frame:Animation_OnLeave_StopEvent()
							return Frame.isMouseOver
						end

						function Frame:Animation_OnLeave(skipAnimation)
							SetStyle(DEFAULT_BACKGROUND_TEXTURE, DEFAULT_IMAGE_TEXTURE)
						end
					end

					do -- ON MOUSE DOWN
						function Frame:Animation_OnMouseDown_StopEvent()
							return not Frame.isMouseDown
						end

						function Frame:Animation_OnMouseDown(skipAnimation)
							SetStyle(CLICKED_BACKGROUND_TEXTURE, CLICKED_IMAGE_TEXTURE)
						end
					end

					do -- ON MOUSE UP
						function Frame:Animation_OnMouseUp_StopEvent()
							return Frame.isMouseDown
						end

						function Frame:Animation_OnMouseUp(skipAnimation)
							if Frame.isMouseOver then
								Frame:Animation_OnEnter()
							else
								Frame:Animation_Onleave()
							end
						end
					end
				end

				do -- LOGIC
					Frame.color = { r = nil, g = nil, b = nil, a = nil }

					Frame.onValueChangedCallbacks = {}
					Frame.onConfirmCallbacks = {}
					Frame.onCloseCallbacks = {}

					--------------------------------

					do -- FUNCTIONS
						do -- SET
							function Frame:SetColor(color)
								Frame.color.r = color.r
								Frame.color.g = color.g
								Frame.color.b = color.b
								Frame.color.a = color.a

								--------------------------------

								Frame.REF_COLOR_BACKGROUND_TEXTURE:SetVertexColor(color.r, color.g, color.b, color.a)
							end
						end

						do -- GET
							function Frame:GetColor()
								return Frame.color
							end
						end

						do -- LOGIC
							function Frame:UpdateColor(userInput)
								local r, g, b = ColorPickerFrame:GetColorRGB()
								local a = ColorPickerFrame:GetColorAlpha()
								local newColor = { r = r, g = g, b = b, a = a }

								Frame:SetColor(newColor)

								--------------------------------

								do -- ON VALUE CHANGED
									local onValueChangedCallbacks = Frame.onValueChangedCallbacks

									if #onValueChangedCallbacks >= 1 then
										for callback = 1, #onValueChangedCallbacks do
											onValueChangedCallbacks[callback](Frame, newColor, userInput)
										end
									end
								end
							end

							function Frame:ColorPicker_OnColorChanged()
								Frame:UpdateColor(true)
							end

							function Frame:ColorPicker_OnOpacityChanged()
								Frame:UpdateColor()
							end

							function Frame:ColorPicker_OnConfirm()
								Frame:UpdateColor(true)

								--------------------------------

								do -- ON CONFIRM
									local onConfirmCallbacks = Frame.onConfirmCallbacks

									if #onConfirmCallbacks >= 1 then
										for callback = 1, #onConfirmCallbacks do
											onConfirmCallbacks[callback](Frame)
										end
									end
								end
							end

							function Frame:ColorPicker_OnCancel(restore)
								if restore then
									Frame:SetColor(restore)
								end

								--------------------------------

								do -- ON CLOSE
									local onCloseCallbacks = Frame.onCloseCallbacks

									if #onCloseCallbacks >= 1 then
										for callback = 1, #onCloseCallbacks do
											onCloseCallbacks[callback](Frame)
										end
									end
								end
							end

							function Frame:OpenColorPicker()
								addon.C.API.Util:Blizzard_ShowColorPicker(Frame.color, Frame.ColorPicker_OnColorChanged, Frame.ColorPicker_OnOpacityChanged, Frame.ColorPicker_OnConfirm, Frame.ColorPicker_OnCancel)
							end

							function Frame:ToggleColorPicker()
								if ColorPickerFrame:IsShown() then
									addon.C.API.Util:Blizzard_HideColorPicker()
								else
									Frame:OpenColorPicker()
								end
							end
						end
					end

					do -- EVENTS
						local function Event_OnEnter(frame, skipAnimation)
							Frame:Animation_OnEnter(skipAnimation)
						end

						local function Event_OnLeave(frame, skipAnimation)
							Frame:Animation_OnLeave(skipAnimation)
						end

						local function Event_OnMouseDown(frame, skipAnimation)
							Frame:Animation_OnMouseDown(skipAnimation)

							--------------------------------

							PlaySound(856)
						end

						local function Event_OnMouseUp(frame, skipAnimation)
							Frame:Animation_OnMouseUp(skipAnimation)
						end

						table.insert(Frame.enterCallbacks, Event_OnEnter)
						table.insert(Frame.leaveCallbacks, Event_OnLeave)
						table.insert(Frame.mouseDownCallbacks, Event_OnMouseDown)
						table.insert(Frame.mouseUpCallbacks, Event_OnMouseUp)
						Frame:SetClick(Frame.ToggleColorPicker)
					end
				end

				do -- SETUP
					Frame:OnLeave(true)
				end

				--------------------------------

				return Frame
			end)
		end

		do -- TEXT BOX
			PrefabRegistry:Add("C.FrameTemplates.Blizzard.TextBox", function(parent, frameStrata, frameLevel, data, name)
				local DEFAULT_BACKGROUND_TEXTURE = data.DEFAULT_BACKGROUND_TEXTURE or addon.CS:GetCommonPathArt() .. "Elements/textbox-background.png"
				local DEFAULT_CONTENT_COLOR = data.DEFAULT_CONTENT_COLOR or { r = 1, g = 1, b = 1, a = .75 }
				local HIGHLIGHTED_BACKGROUND_TEXTURE = data.HIGHLIGHTED_BACKGROUND_TEXTURE or addon.CS:GetCommonPathArt() .. "Elements/textbox-background.png"
				local HIGHLIGHTED_CONTENT_COLOR = data.DEFAULT_CONTENT_COLOR or { r = 1, g = 1, b = 1, a = .75 }
				local CLICKED_BACKGROUND_TEXTURE = data.CLICKED_BACKGROUND_TEXTURE or addon.CS:GetCommonPathArt() .. "Elements/textbox-background.png"
				local CLICKED_CONTENT_COLOR = data.DEFAULT_CONTENT_COLOR or { r = 1, g = 1, b = 1, a = .75 }

				local ACTIVE_DEFAULT_BACKGROUND_TEXTURE = data.ACTIVE_DEFAULT_BACKGROUND_TEXTURE or addon.CS:GetCommonPathArt() .. "Elements/textbox-background-highlighted.png"
				local ACTIVE_DEFAULT_CONTENT_COLOR = data.ACTIVE_DEFAULT_CONTENT_COLOR or { r = 1, g = 1, b = 1, a = 1 }
				local ACTIVE_HIGHLIGHTED_BACKGROUND_TEXTURE = data.ACTIVE_HIGHLIGHTED_BACKGROUND_TEXTURE or addon.CS:GetCommonPathArt() .. "Elements/textbox-background-highlighted.png"
				local ACTIVE_HIGHLIGHTED_CONTENT_COLOR = data.ACTIVE_HIGHLIGHTED_CONTENT_COLOR or { r = 1, g = 1, b = 1, a = 1 }
				local ACTIVE_CLICKED_BACKGROUND_TEXTURE = data.ACTIVE_CLICKED_BACKGROUND_TEXTURE or addon.CS:GetCommonPathArt() .. "Elements/textbox-background-highlighted.png"
				local ACTIVE_CLICKED_CONTENT_COLOR = data.ACTIVE_CLICKED_CONTENT_COLOR or { r = 1, g = 1, b = 1, a = 1 }

				--------------------------------

				local Frame = addon.C.FrameTemplates:CreateTextBox(parent, frameStrata, frameLevel, data, name)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				--------------------------------

				do -- ELEMENTS
					do -- CONTENT
						local Content = Frame.REF_CONTENT

						--------------------------------

						do -- BACKGROUND
							Content.Background, Content.BackgroundTexture = addon.C.FrameTemplates:CreateNineSlice(Content, frameStrata, DEFAULT_BACKGROUND_TEXTURE, 125, .0575, "$parent.Background", Enum.UITextureSliceMode.Stretched)
							Content.Background:SetPoint("CENTER", Content)
							Content.Background:SetFrameStrata(frameStrata)
							Content.Background:SetFrameLevel(frameLevel + 1)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Background, Content, -7.5, -7.5)
						end
					end

					do -- INPUT
						local Input = Frame.REF_INPUT

						--------------------------------

						do -- TEXT
							local RawText = Frame.REF_INPUT_RAWTEXT
							RawText:SetFont(addon.C.Fonts.CONTENT_DEFAULT.path, 12.5, "")
							RawText:Hide()

							Input.Text = addon.C.FrameTemplates:CreateText(Input, addon.CS:GetSharedColor().RGB_WHITE, 12.5, "LEFT", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Text", "GameFontNormal")
							Input.Text:SetPoint("CENTER", Input)
							addon.C.API.FrameUtil:SetDynamicSize(Input.Text, Input, 0, 0)
						end
					end

					do -- PLACEHOLDER
						local Placeholder = Frame.REF_PLACEHOLDER
						Placeholder:SetAlpha(.75)

						--------------------------------

						do -- TEXT
							Placeholder.Text = addon.C.FrameTemplates:CreateText(Placeholder, addon.CS:GetSharedColor().RGB_WHITE, 12.5, "LEFT", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Placeholder", "GameFontNormal")
							Placeholder.Text:SetPoint("CENTER", Placeholder)
							addon.C.API.FrameUtil:SetDynamicSize(Placeholder.Text, Placeholder, 0, 0)
						end
					end
				end

				do -- REFERENCES
					-- CONTENT
					Frame.REF_CONTENT_BACKGROUND = Frame.REF_CONTENT.Background
					Frame.REF_CONTENT_BACKGROUND_TEXTURE = Frame.REF_CONTENT.BackgroundTexture

					-- INPUT
					Frame.REF_INPUT_TEXT = Frame.REF_INPUT.Text

					-- PLACEHOLDER
					Frame.REF_PLACEHOLDER_TEXT = Frame.REF_PLACEHOLDER.Text
				end

				do -- ANIMATIONS
					local function SetStyle(backgroundTexture, contentColor)
						Frame.REF_CONTENT_BACKGROUND_TEXTURE:SetTexture(backgroundTexture)
						Frame.REF_INPUT_TEXT:SetTextColor(contentColor.r, contentColor.g, contentColor.b, contentColor.a)
						Frame.REF_PLACEHOLDER_TEXT:SetTextColor(contentColor.r, contentColor.b, contentColor.g, contentColor.a)
					end

					function Frame:Animation_UpdateStyle()
						if Frame:HasFocus() then
							if Frame.isMouseDown then
								SetStyle(ACTIVE_CLICKED_BACKGROUND_TEXTURE, ACTIVE_CLICKED_CONTENT_COLOR)
							elseif Frame.isMouseOver then
								SetStyle(ACTIVE_HIGHLIGHTED_BACKGROUND_TEXTURE, ACTIVE_HIGHLIGHTED_CONTENT_COLOR)
							else
								SetStyle(ACTIVE_DEFAULT_BACKGROUND_TEXTURE, ACTIVE_DEFAULT_CONTENT_COLOR)
							end
						else
							if Frame.isMouseDown then
								SetStyle(CLICKED_BACKGROUND_TEXTURE, CLICKED_CONTENT_COLOR)
							elseif Frame.isMouseOver then
								SetStyle(HIGHLIGHTED_BACKGROUND_TEXTURE, HIGHLIGHTED_CONTENT_COLOR)
							else
								SetStyle(DEFAULT_BACKGROUND_TEXTURE, DEFAULT_CONTENT_COLOR)
							end
						end
					end

					--------------------------------

					do -- ON ENTER
						function Frame:Animation_OnEnter_StopEvent()
							return not Frame.isMouseOver
						end

						function Frame:Animation_OnEnter(skipAnimation)
							Frame:Animation_UpdateStyle()
						end
					end

					do -- ON LEAVE
						function Frame:Animation_OnLeave_StopEvent()
							return Frame.isMouseOver
						end

						function Frame:Animation_OnLeave(skipAnimation)
							Frame:Animation_UpdateStyle()
						end
					end

					do -- ON MOUSE DOWN
						function Frame:Animation_OnMouseDown_StopEvent()
							return not Frame.isMouseDown
						end

						function Frame:Animation_OnMouseDown(skipAnimation)
							Frame:Animation_UpdateStyle()
						end
					end

					do -- ON MOUSE UP
						function Frame:Animation_OnMouseUp_StopEvent()
							return Frame.isMouseDown
						end

						function Frame:Animation_OnMouseUp(skipAnimation)
							Frame:Animation_UpdateStyle()
						end
					end
				end

				do -- LOGIC
					do -- FUNCTIONS
						do -- SET
							function Frame:SetPlaceholder(text)
								Frame.REF_PLACEHOLDER_TEXT:SetText(text)
							end
						end
					end

					do -- EVENTS
						local function Event_OnEnter(frame, skipAnimation)
							Frame:Animation_OnEnter(skipAnimation)
						end

						local function Event_OnLeave(frame, skipAnimation)
							Frame:Animation_OnLeave(skipAnimation)
						end

						local function Event_OnMouseDown(frame, skipAnimation)
							Frame:Animation_OnMouseDown(skipAnimation)
						end

						local function Event_OnMouseUp(frame, skipAnimation)
							Frame:Animation_OnMouseUp(skipAnimation)
						end

						local function Event_OnEscapePressed()
							Frame:Animation_OnLeave(true)
						end

						local function Event_OnTextChanged(frame, userInput)
							local font, fontSize, fontFlags = Frame.REF_INPUT_TEXT:GetFont()
							Frame.REF_INPUT_RAWTEXT:SetFont(font, fontSize, fontFlags)
							Frame.REF_INPUT_TEXT:SetText(Frame.REF_INPUT_RAWTEXT:GetText())
						end

						local function Event_OnFocusChanged(frame, focus)
							Frame:Animation_UpdateStyle()
						end

						local function Event_GlobalMouseDown()
							if not Frame:IsMouseOver() then
								Frame:OnEscapePressed()
							end
						end

						table.insert(Frame.enterCallbacks, Event_OnEnter)
						table.insert(Frame.leaveCallbacks, Event_OnLeave)
						table.insert(Frame.mouseDownCallbacks, Event_OnMouseDown)
						table.insert(Frame.mouseUpCallbacks, Event_OnMouseUp)
						table.insert(Frame.escapePressedCallbacks, Event_OnEscapePressed)
						table.insert(Frame.textChangedCallbacks, Event_OnTextChanged)
						table.insert(Frame.focusChangedCallbacks, Event_OnFocusChanged)

						CallbackRegistry:Add("EVENT_MOUSE_DOWN", Event_GlobalMouseDown)
					end
				end

				do -- SETUP
					Frame:OnLeave(true)
				end

				--------------------------------

				return Frame
			end)
		end
	end
end
