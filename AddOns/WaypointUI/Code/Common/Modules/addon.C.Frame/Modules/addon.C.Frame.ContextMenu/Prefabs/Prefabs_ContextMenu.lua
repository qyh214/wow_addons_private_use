---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Frame.ContextMenu; addon.C.Frame.ContextMenu = NS

--------------------------------

NS.Prefabs = {}

--------------------------------
-- PREFABS
--------------------------------

function NS.Prefabs:Load()
	do -- CONTEXT MENU
		local BASELINE = 100
		local FRAME_DIVIDER_HEIGHT = 1

		local function Ratio(level) return BASELINE / addon.C.Variables:RAW_RATIO(level) end

		local PADDING = Ratio(5)

		--------------------------------

		do -- TEMPLATE
			PrefabRegistry:Add("C.Frame.ContextMenu", function(parent, frameStrata, frameLevel, name)
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

						do -- BACKGROUND
							Content.Background, Content.BackgroundTexture = addon.C.FrameTemplates:CreateNineSlice(Content, frameStrata, addon.CS:GetCommonPathElement() .. "context-background.png", { left = 75, top = 60, right = 75, bottom = 100 }, .375, "$parent.Background", Enum.UITextureSliceMode.Stretched)
							Content.Background:SetPoint("CENTER", Content, 0, -5)
							Content.Background:SetFrameStrata(frameStrata)
							Content.Background:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Background, Content, -42.5, -42.5)

							Content.BackgroundTexture:SetVertexColor(1, 1, 1, 1)
						end

						do -- MAIN
							Content.Main = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Main", Content)
							Content.Main:SetPoint("CENTER", Content)
							Content.Main:SetFrameStrata(frameStrata)
							Content.Main:SetFrameLevel(frameLevel + 3)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Main, Content, PADDING, PADDING)

							local Main = Content.Main

							--------------------------------

							do -- ELEMENTS
								local PADDING_ELEMENT = 2

								--------------------------------

								do -- LAYOUT GROUP
									Main.LayoutGroup, Main.LayoutGroup_Sort = addon.C.FrameTemplates:CreateLayoutGroup(Main, { point = "TOP", direction = "vertical", resize = true, padding = PADDING_ELEMENT, distribute = false, distributeResizeElements = false, excludeHidden = true, autoSort = true, customOffset = nil, customLayoutSort = nil }, "$parent.LayoutGroup")
									Main.LayoutGroup:SetPoint("CENTER", Main)
									Main.LayoutGroup:SetFrameStrata(frameStrata)
									Main.LayoutGroup:SetFrameLevel(frameLevel + 4)
									addon.C.API.FrameUtil:SetDynamicSize(Main.LayoutGroup, Main, 0, nil)
									addon.C.API.FrameUtil:SetDynamicSize(Frame, Main.LayoutGroup, nil, -PADDING)
									Frame.LGS_CONTENT = Main.LayoutGroup_Sort
								end
							end
						end
					end
				end

				do -- REFERENCES
					-- CORE
					Frame.REF_CONTENT = Frame.Content
					Frame.REF_BACKGROUND = Frame.REF_CONTENT.Background
					Frame.REF_MAIN = Frame.REF_CONTENT.Main

					-- BACKGROUND
					Frame.REF_BACKGROUND_TEXTURE = Frame.REF_CONTENT.BackgroundTexture

					-- MAIN
					Frame.REF_MAIN_LAYOUT = Frame.REF_MAIN.LayoutGroup
				end

				do -- ANIMATIONS
					do -- SHOW
						function Frame:ShowWithAnimation_StopEvent()
							return not Frame:IsVisible()
						end

						function Frame:ShowWithAnimation(skipAnimation)
							Frame:Show()

							--------------------------------

							addon.C.Animation:Alpha({ ["frame"] = Frame.REF_CONTENT, ["duration"] = .5, ["from"] = 0, ["to"] = 1, ["ease"] = "EaseExpo_Out", ["stopEvent"] = Frame.ShowWithAnimation_StopEvent })
							addon.C.Animation:Translate({ ["frame"] = Frame.REF_CONTENT, ["duration"] = .5, ["from"] = 7.5, ["to"] = 0, ["axis"] = "y", ["ease"] = "EaseExpo_Out", ["stopEvent"] = Frame.ShowWithAnimation_StopEvent })
						end
					end

					do -- HIDE
						function Frame:HideWithAnimation_StopEvent()
							return not Frame:IsVisible()
						end

						function Frame:HideWithAnimation()
							C_Timer.After(.125, function()
								Frame:Hide()
							end)

							--------------------------------

							addon.C.Animation:Alpha({ ["frame"] = Frame.REF_CONTENT, ["duration"] = .5, ["from"] = Frame.REF_CONTENT:GetAlpha(), ["to"] = 0, ["ease"] = "EaseExpo_Out", ["stopEvent"] = Frame.HideWithAnimation_StopEvent })
							addon.C.Animation:Translate({ ["frame"] = Frame.REF_CONTENT, ["duration"] = .5, ["from"] = select(5, Frame.REF_CONTENT:GetPoint()), ["to"] = 7.5, ["axis"] = "y", ["ease"] = "EaseExpo_Out", ["stopEvent"] = Frame.HideWithAnimation_StopEvent })
						end
					end
				end

				do -- LOGIC
					Frame.buttonParent = nil

					Frame.titlePool = {}
					Frame.buttonPool = {}

					--------------------------------

					do -- FUNCTIONS
						do -- SET
							function Frame:SetButtonParent(frame)
								Frame.buttonParent = frame
							end

							function Frame:SetLayout(layoutInfo)
								Frame.REF_MAIN_LAYOUT:ClearAllElements()

								for i = 1, #Frame.titlePool do
									Frame.titlePool[i]:Hide()
								end

								for i = 1, #Frame.buttonPool do
									Frame.buttonPool[i]:Hide()
								end

								--------------------------------

								local usedTitles = 0
								local usedButtons = 0

								for k, v in pairs(layoutInfo) do
									local var_name, var_type = v.name, v.type

									--------------------------------

									if var_type == "Title" then
										usedTitles = usedTitles + 1

										if #Frame.titlePool < usedTitles then
											Frame:Constructor_NewTitle()
										end

										--------------------------------

										Frame.titlePool[usedTitles]:Show()
										Frame.titlePool[usedTitles]:SetInfo(var_name, { r = addon.CS:GetSharedColor().RGB_WHITE.r, g = addon.CS:GetSharedColor().RGB_WHITE.g, b = addon.CS:GetSharedColor().RGB_WHITE.b, a = 1 })
										Frame.REF_MAIN_LAYOUT:AddElement(Frame.titlePool[usedTitles])
									end

									if var_type == "Button" then
										usedButtons = usedButtons + 1

										if #Frame.buttonPool < usedButtons then
											Frame:Constructor_NewButton()
										end

										--------------------------------

										local var_callback = v.callback
										local var_enabled = v.enabled

										Frame.buttonPool[usedButtons]:Show()
										Frame.buttonPool[usedButtons]:SetInfo(var_name, var_callback, var_enabled)
										Frame.REF_MAIN_LAYOUT:AddElement(Frame.buttonPool[usedButtons])
									end
								end

								--------------------------------

								Frame:UpdateLayout()
							end
						end

						do -- LOGIC
							function Frame:UpdateLayout()
								Frame.LGS_CONTENT()
							end

							function Frame:Constructor_NewTitle()
								local Title = PrefabRegistry:Create("C.Frame.ContextMenu.Element.Title", Frame.REF_MAIN_LAYOUT, frameStrata, frameLevel + 5, "$parent.Title")
								Title:SetFrameStrata(frameStrata)
								Title:SetFrameLevel(frameLevel + 5)
								addon.C.API.FrameUtil:SetDynamicSize(Title, Frame.REF_MAIN_LAYOUT, 0, nil)

								table.insert(Frame.titlePool, Title)

								--------------------------------

								return Title
							end

							function Frame:Constructor_NewButton()
								local Button = PrefabRegistry:Create("C.Frame.ContextMenu.Element.Button.Selection", Frame.REF_MAIN_LAYOUT, frameStrata, frameLevel + 5, {
									["DEFAULT_BACKGROUND_COLOR"] = { r = 1, g = 1, b = 1, a = 0 },
									["DEFAULT_CONTENT_COLOR"] = { r = 1, g = 1, b = 1, a = 1 },
									["HIGHLIGHTED_BACKGROUND_COLOR"] = { r = 1, g = 1, b = 1, a = .125 },
									["HIGHLIGHTED_CONTENT_COLOR"] = { r = 1, g = 1, b = 1, a = 1 },
									["CLICKED_BACKGROUND_COLOR"] = { r = 1, g = 1, b = 1, a = .175 },
									["CLICKED_CONTENT_COLOR"] = { r = 1, g = 1, b = 1, a = 1 },
									["ACTIVE_DEFAULT_BACKGROUND_COLOR"] = { r = 1, g = 1, b = 1, a = 0 },
									["ACTIVE_DEFAULT_CONTENT_COLOR"] = { r = addon.CS:GetSharedColor().RGB_YELLOW.r, g = addon.CS:GetSharedColor().RGB_YELLOW.g, b = addon.CS:GetSharedColor().RGB_YELLOW.b, a = 1 },
									["ACTIVE_HIGHLIGHTED_BACKGROUND_COLOR"] = { r = 1, g = 1, b = 1, a = .125 },
									["ACTIVE_HIGHLIGHTED_CONTENT_COLOR"] = { r = addon.CS:GetSharedColor().RGB_YELLOW.r, g = addon.CS:GetSharedColor().RGB_YELLOW.g, b = addon.CS:GetSharedColor().RGB_YELLOW.b, a = 1 },
									["ACTIVE_CLICKED_BACKGROUND_COLOR"] = { r = 1, g = 1, b = 1, a = .075 },
									["ACTIVE_CLICKED_CONTENT_COLOR"] = { r = addon.CS:GetSharedColor().RGB_YELLOW.r, g = addon.CS:GetSharedColor().RGB_YELLOW.g, b = addon.CS:GetSharedColor().RGB_YELLOW.b, a = 1 },
								}, "$parent.Button")
								Button:SetHeight(25)
								Button:SetFrameStrata(frameStrata)
								Button:SetFrameLevel(frameLevel + 5)
								addon.C.API.FrameUtil:SetDynamicSize(Button, Frame.REF_MAIN_LAYOUT, 0, nil)

								table.insert(Frame.buttonPool, Button)

								--------------------------------

								return Button
							end
						end
					end

					do -- EVENTS
						local function Event_FontOverrideReady()
							Frame:UpdateLayout()
						end

						local function Logic_GlobalClick(button)
							if Frame:IsVisible() then
								if (Frame.buttonParent and not Frame.buttonParent:IsMouseOver() and not Frame:IsMouseOver()) or (not Frame.buttonParent and not Frame:IsMouseOver()) then
									Frame:HideWithAnimation()
								end
							end
						end

						local function Logic_OnKeyDown(key)
							if Frame:IsVisible() then
								if key == "ESCAPE" then
									Frame:HideWithAnimation()

									--------------------------------

									CallbackRegistry:Trigger("EVENT_PREVENT_KEY")
								end
							end
						end

						CallbackRegistry:Add("C_FONT_OVERRIDE_READY", Event_FontOverrideReady)
						CallbackRegistry:Add("EVENT_MOUSE_DOWN", Logic_GlobalClick)
						CallbackRegistry:Add("EVENT_KEY_DOWN", Logic_OnKeyDown)
					end
				end

				do -- SETUP

				end

				--------------------------------

				return Frame
			end)

			PrefabRegistry:Add("C.Frame.ContextMenu.Element.Title", function(parent, frameStrata, frameLevel, name)
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

						do -- TEXT
							Content.Text = addon.C.FrameTemplates:CreateText(Content, addon.CS:GetSharedColor().RGB_WHITE, 12.5, "LEFT", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Text", "GameFontNormal")
							Content.Text:SetPoint("CENTER", Content)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Text, Content, 0, 0)
						end
					end
				end

				do -- REFERENCES
					-- CORE
					Frame.REF_CONTENT = Frame.Content

					-- CONTENT
					Frame.REF_TEXT = Frame.Content.Text
				end

				do -- LOGIC
					do -- FUNCTIONS
						do -- SET
							function Frame:SetInfo(text, textColor)
								Frame.REF_TEXT:SetText(text)
								Frame.REF_TEXT:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
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

			PrefabRegistry:Add("C.Frame.ContextMenu.Element.Button.Selection", function(parent, frameStrata, frameLevel, data, name)
				local DEFAULT_BACKGROUND_COLOR = data.DEFAULT_BACKGROUND_COLOR
				local DEFAULT_CONTENT_COLOR = data.DEFAULT_CONTENT_COLOR
				local HIGHLIGHTED_BACKGROUND_COLOR = data.HIGHLIGHTED_BACKGROUND_COLOR
				local HIGHLIGHTED_CONTENT_COLOR = data.HIGHLIGHTED_CONTENT_COLOR
				local CLICKED_BACKGROUND_COLOR = data.CLICKED_BACKGROUND_COLOR
				local CLICKED_CONTENT_COLOR = data.CLICKED_CONTENT_COLOR

				local ACTIVE_DEFAULT_BACKGROUND_COLOR = data.ACTIVE_DEFAULT_BACKGROUND_COLOR
				local ACTIVE_DEFAULT_CONTENT_COLOR = data.ACTIVE_DEFAULT_CONTENT_COLOR
				local ACTIVE_HIGHLIGHTED_BACKGROUND_COLOR = data.ACTIVE_HIGHLIGHTED_BACKGROUND_COLOR
				local ACTIVE_HIGHLIGHTED_CONTENT_COLOR = data.ACTIVE_HIGHLIGHTED_CONTENT_COLOR
				local ACTIVE_CLICKED_BACKGROUND_COLOR = data.ACTIVE_CLICKED_BACKGROUND_COLOR
				local ACTIVE_CLICKED_CONTENT_COLOR = data.ACTIVE_CLICKED_CONTENT_COLOR

				--------------------------------

				local Frame = addon.C.FrameTemplates:CreateButton(parent, name)
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

						do -- BACKGROUND
							Content.Background, Content.BackgroundTexture = addon.C.FrameTemplates:CreateNineSlice(Content, frameStrata, addon.CS:GetCommonPathArt() .. "Basic/square-bevel.png", 100, .0625, "$parent.Background", Enum.UITextureSliceMode.Stretched)
							Content.Background:SetPoint("CENTER", Content)
							Content.Background:SetFrameStrata(frameStrata)
							Content.Background:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Background, Content, 0, 0)
						end

						do -- CONTENT
							Content.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Content)
							Content.Content:SetPoint("CENTER", Content)
							Content.Content:SetFrameStrata(frameStrata)
							Content.Content:SetFrameLevel(frameLevel + 3)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Content, Content, PADDING, PADDING)

							local Subcontent = Content.Content

							--------------------------------

							do -- TEXT
								Subcontent.Text = addon.C.FrameTemplates:CreateText(Subcontent, addon.CS:GetSharedColor().RGB_WHITE, 12.5, "LEFT", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Text", "GameFontNormal")
								Subcontent.Text:SetPoint("LEFT", Subcontent)
								Subcontent.Text:SetAutoFit(true)
								Subcontent.Text:SetAutoFit_MaxWidth(INFO_TEXT_WIDTH_MAX)
								addon.C.API.FrameUtil:SetDynamicSize(Frame, Subcontent.Text, nil, -PADDING)
							end
						end
					end
				end

				do -- REFERENCES
					-- CORE
					Frame.REF_CONTENT = Frame.Content
					Frame.REF_BACKGROUND = Frame.REF_CONTENT.Background
					Frame.REF_MAIN = Frame.REF_CONTENT.Content

					-- BACKGROUND
					Frame.REF_BACKGROUND_TEXTURE = Frame.REF_CONTENT.BackgroundTexture

					-- CONTENT
					Frame.REF_TEXT = Frame.REF_MAIN.Text
				end

				do -- ANIMATIONS
					local function SetStyle(backgroundColor, textColor)
						Frame.REF_BACKGROUND_TEXTURE:SetVertexColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a)
						Frame.REF_TEXT:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
					end

					function Frame:Animation_UpdateStyle()
						if Frame.isMouseDown then
							if Frame.active then
								SetStyle(ACTIVE_CLICKED_BACKGROUND_COLOR, ACTIVE_CLICKED_CONTENT_COLOR)
							else
								SetStyle(CLICKED_BACKGROUND_COLOR, CLICKED_CONTENT_COLOR)
							end
						elseif Frame.isMouseOver then
							if Frame.active then
								SetStyle(ACTIVE_HIGHLIGHTED_BACKGROUND_COLOR, ACTIVE_HIGHLIGHTED_CONTENT_COLOR)
							else
								SetStyle(HIGHLIGHTED_BACKGROUND_COLOR, HIGHLIGHTED_CONTENT_COLOR)
							end
						else
							if Frame.active then
								SetStyle(ACTIVE_DEFAULT_BACKGROUND_COLOR, ACTIVE_DEFAULT_CONTENT_COLOR)
							else
								SetStyle(DEFAULT_BACKGROUND_COLOR, DEFAULT_CONTENT_COLOR)
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
					Frame.Check_Active = nil

					--------------------------------

					do -- FUNCTIONS
						do -- SET
							function Frame:SetInfo(text, click, active)
								Frame.Check_Active = active

								--------------------------------

								Frame.REF_TEXT:SetText(text)
								Frame:SetClick(click)

								--------------------------------

								Frame:UpdateActiveState()
							end

							function Frame:SetClick(callback)
								Frame.clickCallbacks = {}
								table.insert(Frame.clickCallbacks, function(...)
									callback(...)

									--------------------------------

									CallbackRegistry:Trigger("C.ContextMenu.RefreshButtonState")
								end)
							end
						end

						do -- LOGIC
							function Frame:UpdateActiveState()
								if Frame.Check_Active then
									Frame:SetActive(Frame.Check_Active())
								end

								--------------------------------

								Frame:Animation_UpdateStyle()
							end
						end
					end

					do -- EVENTS
						local function Logic_OnEnter(frame, skipAnimation)
							Frame:Animation_OnEnter(skipAnimation)
						end

						local function Logic_OnLeave(frame, skipAnimation)
							Frame:Animation_OnLeave(skipAnimation)
						end

						local function Logic_OnMouseDown(frame, skipAnimation)
							Frame:Animation_OnMouseDown(skipAnimation)

							--------------------------------

							PlaySound(856)
						end

						local function Logic_OnMouseUp(frame, skipAnimation)
							Frame:Animation_OnMouseUp(skipAnimation)
						end

						local function Logic_OnActiveChanged()
							if Frame:IsVisible() then
								Frame:UpdateActiveState()
							end
						end

						table.insert(Frame.enterCallbacks, Logic_OnEnter)
						table.insert(Frame.leaveCallbacks, Logic_OnLeave)
						table.insert(Frame.mouseDownCallbacks, Logic_OnMouseDown)
						table.insert(Frame.mouseUpCallbacks, Logic_OnMouseUp)
						CallbackRegistry:Add("C.ContextMenu.RefreshButtonState", Logic_OnActiveChanged)
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
