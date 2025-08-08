---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Config; addon.C.Config = NS

--------------------------------

NS.Prefabs = {}

--------------------------------
-- PREFABS
--------------------------------

function NS.Prefabs:Load()
	local PADDING = NS.Variables.PADDING

	--------------------------------

	do -- SIDEBAR
		do -- NAVIGATION
			PrefabRegistry:Add("C.Config.Sidebar.Navigation.Button", function(parent, frameStrata, frameLevel, name)
				local DEFAULT_BACKGROUND_TEXTURE = addon.CS:GetCommonPathConfig() .. "navbutton-background.png"
				local DEFAULT_CONTENT_COLOR = addon.CS:GetSharedColor().RGB_WHITE
				local HIGHLIGHTED_BACKGROUND_TEXTURE = addon.CS:GetCommonPathConfig() .. "navbutton-background-highlighted.png"
				local HIGHLIGHTED_CONTENT_COLOR = addon.CS:GetSharedColor().RGB_WHITE
				local CLICKED_BACKGROUND_TEXTURE = addon.CS:GetCommonPathConfig() .. "navbutton-background-clicked.png"
				local CLICKED_CONTENT_COLOR = addon.CS:GetSharedColor().RGB_WHITE

				local ACTIVE_DEFAULT_BACKGROUND_TEXTURE = addon.CS:GetCommonPathConfig() .. "navbutton-background-active.png"
				local ACTIVE_DEFAULT_CONTENT_COLOR = addon.CS:GetSharedColor().RGB_WHITE
				local ACTIVE_HIGHLIGHTED_BACKGROUND_TEXTURE = addon.CS:GetCommonPathConfig() .. "navbutton-background-active-highlighted.png"
				local ACTIVE_HIGHLIGHTED_CONTENT_COLOR = addon.CS:GetSharedColor().RGB_WHITE
				local ACTIVE_CLICKED_BACKGROUND_TEXTURE = addon.CS:GetCommonPathConfig() .. "navbutton-background-active-clicked.png"
				local ACTIVE_CLICKED_CONTENT_COLOR = addon.CS:GetSharedColor().RGB_WHITE

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
							Content.Background, Content.BackgroundTexture = addon.C.FrameTemplates:CreateNineSlice(Content, frameStrata, DEFAULT_BACKGROUND_TEXTURE, 65, .5, "$parent.Background", Enum.UITextureSliceMode.Stretched)
							Content.Background:SetPoint("CENTER", Content)
							Content.Background:SetFrameStrata(frameStrata)
							Content.Background:SetFrameLevel(frameLevel + 1)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Background, Content, -7.5, -7.5)
						end

						do -- CONTENT
							Content.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Content)
							Content.Content:SetPoint("CENTER", Content)
							Content.Content:SetFrameStrata(frameStrata)
							Content.Content:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Content, Content, PADDING, PADDING)

							local Subcontent = Content.Content

							--------------------------------

							do -- TEXT
								Subcontent.Text = addon.C.FrameTemplates:CreateText(Subcontent, DEFAULT_CONTENT_COLOR, 12.5, "LEFT", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Text", "GameFontNormal")
								Subcontent.Text:SetPoint("CENTER", Subcontent)
								addon.C.API.FrameUtil:SetDynamicSize(Subcontent.Text, Subcontent, 0, 0)
							end
						end
					end
				end

				do -- REFERENCES
					-- CORE
					Frame.REF_BACKGROUND = Frame.Content.Background
					Frame.REF_CONTENT = Frame.Content.Content

					-- BACKGROUND
					Frame.REF_BACKGROUND_TEXTURE = Frame.Content.BackgroundTexture

					-- CONTENT
					Frame.REF_CONTENT_TEXT = Frame.REF_CONTENT.Text
				end

				do -- ANIMATIONS
					local function SetStyle(backgroundTexture, contentColor)
						Frame.REF_BACKGROUND_TEXTURE:SetTexture(backgroundTexture)
						Frame.REF_CONTENT_TEXT:SetTextColor(contentColor.r, contentColor.g, contentColor.b, contentColor.a or 1)
					end

					function Frame:Animation_UpdateStyle()
						if Frame.isMouseDown then
							if Frame.active then
								SetStyle(ACTIVE_CLICKED_BACKGROUND_TEXTURE, ACTIVE_CLICKED_CONTENT_COLOR)
							else
								SetStyle(CLICKED_BACKGROUND_TEXTURE, CLICKED_CONTENT_COLOR)
							end
						elseif Frame.isMouseOver then
							if Frame.active then
								SetStyle(ACTIVE_HIGHLIGHTED_BACKGROUND_TEXTURE, ACTIVE_HIGHLIGHTED_CONTENT_COLOR)
							else
								SetStyle(HIGHLIGHTED_BACKGROUND_TEXTURE, HIGHLIGHTED_CONTENT_COLOR)
							end
						else
							if Frame.active then
								SetStyle(ACTIVE_DEFAULT_BACKGROUND_TEXTURE, ACTIVE_DEFAULT_CONTENT_COLOR)
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
							return not Frame.isMouseOver
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
							function Frame:SetText(text)
								Frame.REF_CONTENT_TEXT:SetText(text)
							end

							function Frame:SetClick(callback)
								Frame.clickCallbacks = {}
								table.insert(Frame.clickCallbacks, callback)
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

						local function Event_OnActiveChanged(frame, value)
							Frame:Animation_UpdateStyle()
						end

						table.insert(Frame.enterCallbacks, Event_OnEnter)
						table.insert(Frame.leaveCallbacks, Event_OnLeave)
						table.insert(Frame.mouseDownCallbacks, Event_OnMouseDown)
						table.insert(Frame.mouseUpCallbacks, Event_OnMouseUp)
						table.insert(Frame.onActiveCallbacks, Event_OnActiveChanged)
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

	do -- MAIN
		do -- TAB
			PrefabRegistry:Add("C.Config.Main.Tab", function(parent, frameStrata, frameLevel, name)
				local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name, parent)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				--------------------------------

				do -- ELEMENTS
					local PADDING_ELEMENT = NS.Variables:RATIO(9)

					--------------------------------

					do -- CONTENT
						Frame.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Frame)
						Frame.Content:SetPoint("CENTER", Frame)
						Frame.Content:SetFrameStrata(frameStrata)
						Frame.Content:SetFrameLevel(frameLevel + 1)
						addon.C.API.FrameUtil:SetDynamicSize(Frame.Content, Frame, 0, 0)

						local Content = Frame.Content

						--------------------------------

						do -- SCROLL FRAME
							Content.ScrollFrame, Content.ScrollChildFrame = addon.C.FrameTemplates:CreateScrollFrame(Content, { direction = "vertical", smoothScrollingRatio = 5 }, "$parent.ScrollFrame", "$parent.ScrollChildFrame")
							Content.ScrollFrame:SetPoint("LEFT", Content)
							Content.ScrollFrame:SetFrameStrata(frameStrata)
							Content.ScrollFrame:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Content.ScrollFrame, Content, 5, 0)

							local ScrollFrame, ScrollChildFrame = Content.ScrollFrame, Content.ScrollChildFrame

							--------------------------------

							do -- SCROLL BAR
								ScrollFrame.ScrollBar:Hide()

								ScrollFrame.scrollBar = PrefabRegistry:Create("C.FrameTemplates.Blizzard.ScrollBar", ScrollFrame, frameStrata, frameLevel + 3, { scrollFrame = ScrollFrame, scrollFrameType = "scrollFrame", direction = "vertical" }, "$parent.ScrollBar")
								ScrollFrame.scrollBar:SetWidth(5)
								ScrollFrame.scrollBar:SetPoint("LEFT", ScrollFrame, "RIGHT", 0, 0)
								ScrollFrame.scrollBar:SetFrameStrata(frameStrata)
								ScrollFrame.scrollBar:SetFrameLevel(frameLevel + 3)
								addon.C.API.FrameUtil:SetDynamicSize(ScrollFrame.scrollBar, ScrollFrame, nil, 0)
							end

							do -- LAYOUT GROUP
								ScrollChildFrame.LayoutGroup, ScrollChildFrame.LayoutGroup_Sort = addon.C.FrameTemplates:CreateLayoutGroup(ScrollChildFrame, { point = "TOP", direction = "vertical", resize = true, padding = PADDING_ELEMENT, distribute = false, distributeResizeElements = false, excludeHidden = true, autoSort = true, customOffset = nil, customLayoutSort = nil }, "$parent.LayoutGroup")
								ScrollChildFrame.LayoutGroup:SetPoint("TOP", ScrollChildFrame)
								ScrollChildFrame.LayoutGroup:SetFrameStrata(frameStrata)
								ScrollChildFrame.LayoutGroup:SetFrameLevel(frameLevel + 3)
								addon.C.API.FrameUtil:SetDynamicSize(ScrollChildFrame.LayoutGroup, ScrollChildFrame, 0, nil)
								addon.C.API.FrameUtil:SetDynamicSize(ScrollChildFrame, ScrollChildFrame.LayoutGroup, nil, 0)
								Frame.LGS_CONTENT = ScrollChildFrame.LayoutGroup_Sort
							end
						end
					end
				end

				do -- REFERENCES
					-- CORE
					Frame.REF_CONTENT = Frame.Content

					-- CONTENT
					Frame.REF_CONTENT_SCROLL = Frame.REF_CONTENT.ScrollFrame
					Frame.REF_CONTENT_SCROLL_CONTENT = Frame.REF_CONTENT.ScrollChildFrame
					Frame.REF_CONTENT_SCROLL_CONTENT_LAYOUT = Frame.REF_CONTENT_SCROLL_CONTENT.LayoutGroup
				end

				do -- ANIMATIONS
					do -- PULSE
						function Frame:Animation_Pulse_StopEvent()
							return not Frame:IsVisible()
						end

						function Frame:Animation_Pulse(skipAnimation)
							local elements = Frame.REF_CONTENT_SCROLL_CONTENT_LAYOUT:GetElements()

							--------------------------------

							for i = 1, #elements do
								local element = elements[i]

								--------------------------------

								if element.ShowWithAnimation and element.ShowWithAnimation_Pre then
									if element.Animation_Pulse_Timer then element.Animation_Pulse_Timer:Cancel() end
									element:ShowWithAnimation_Pre()

									--------------------------------

									element.Animation_Pulse_Timer = C_Timer.NewTimer(.1 * i, function()
										if not Frame:Animation_Pulse_StopEvent() then
											element:ShowWithAnimation(skipAnimation)
										end
									end)
								end
							end
						end
					end

					do -- SHOW
						function Frame:ShowWithAnimation_StopEvent()
							return not Frame:IsVisible()
						end

						function Frame:ShowWithAnimation(skipAnimation)
							Frame:Show()

							--------------------------------

							if skipAnimation then
								Frame.REF_CONTENT:SetAlpha(1)
							else
								addon.C.Animation:Alpha({ ["frame"] = Frame.REF_CONTENT, ["duration"] = .5, ["from"] = 0, ["to"] = 1, ["ease"] = nil, ["stopEvent"] = Frame.ShowWithAnimation_StopEvent })

								--------------------------------

								Frame:Animation_Pulse(skipAnimation)
							end
						end
					end

					do -- HIDE
						function Frame:HideWithAnimation_StopEvent()
							return not Frame:IsVisible()
						end

						function Frame:HideWithAnimation(skipAnimation)
							C_Timer.After(.1, function()
								Frame:Hide()
							end)

							if skipAnimation then
								Frame.REF_CONTENT:SetAlpha(0)
							else
								addon.C.Animation:Alpha({ ["frame"] = Frame.REF_CONTENT, ["duration"] = .5, ["from"] = Frame.REF_CONTENT:GetAlpha(), ["to"] = 0, ["ease"] = nil, ["stopEvent"] = Frame.HideWithAnimation_StopEvent })
							end
						end
					end
				end

				do -- LOGIC
					do -- FUNCTIONS
						do -- LOGIC
							function Frame:Reset()
								Frame.REF_CONTENT_SCROLL:SetVerticalScroll(0)

								--------------------------------

								Frame:UpdateLayout()
							end

							function Frame:UpdateLayout()
								Frame.LGS_CONTENT()
							end
						end
					end

					do -- EVENTS
						local function Event_ConfigUpdate()
							Frame:UpdateLayout()
						end

						local function Event_FontOverrideReady()
							Frame:UpdateLayout()
						end

						local function Event_TabChanged()
							if Frame:IsVisible() then
								Frame:Reset()
							end
						end

						CallbackRegistry:Add("C_CONFIG_UPDATE", Event_ConfigUpdate, 11)
						CallbackRegistry:Add("C_CONFIG_TAB_CHANGED", Event_TabChanged, 11)
						CallbackRegistry:Add("C_FONT_OVERRIDE_READY", Event_FontOverrideReady, 11)
					end
				end

				--------------------------------

				return Frame
			end)
		end

		do -- SETTING
			do -- TITLE
				PrefabRegistry:Add("C.Config.Main.Setting.Title", function(parent, frameStrata, frameLevel, name)
					local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name, parent)
					Frame:SetFrameStrata(frameStrata)
					Frame:SetFrameLevel(frameLevel)

					--------------------------------

					do -- ELEMENTS
						do -- CONTENT
							Frame.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Frame)
							Frame.Content:SetPoint("CENTER", Frame, -12.5, -12.5)
							Frame.Content:SetFrameStrata(frameStrata)
							Frame.Content:SetFrameLevel(frameLevel + 1)

							local Content = Frame.Content

							--------------------------------

							do -- CONTAINER
								Content.Container = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Container", Content)
								Content.Container:SetPoint("CENTER", Content)
								Content.Container:SetFrameStrata(frameStrata)
								Content.Container:SetFrameLevel(frameLevel + 2)

								local Container = Content.Container

								--------------------------------

								do -- ELEMENTS
									local MAX_WIDTH = 275
									local IMAGE_SIZE = 35

									--------------------------------

									do -- IMAGE
										Container.Image = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Image", Container)
										Container.Image:SetSize(IMAGE_SIZE, IMAGE_SIZE)
										Container.Image:SetPoint("LEFT", Container)
										Container.Image:SetFrameStrata(frameStrata)
										Container.Image:SetFrameLevel(frameLevel + 3)

										local Image = Container.Image

										--------------------------------

										do -- BACKGROUND
											Image.Background, Image.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(Image, frameStrata, nil, "$parent.Background")
											Image.Background:SetPoint("CENTER", Image)
											Image.Background:SetFrameStrata(frameStrata)
											Image.Background:SetFrameLevel(frameLevel + 4)
											addon.C.API.FrameUtil:SetDynamicSize(Image.Background, Image, 0, 0)
										end
									end

									do -- INFO
										Container.Info = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Info", Container)
										Container.Info:SetPoint("TOPLEFT", Container.Image, "TOPRIGHT", 7.5, -2.5)
										Container.Info:SetFrameStrata(frameStrata)
										Container.Info:SetFrameLevel(frameLevel + 3)

										local Info = Container.Info

										--------------------------------

										do -- TITLE
											Info.Title = addon.C.FrameTemplates:CreateText(Info, addon.CS:GetSharedColor().RGB_WHITE, 14, "LEFT", "TOP", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Title")
											Info.Title:SetPoint("TOPLEFT", Info)
											Info.Title:SetAutoFit(true, true)
											Info.Title:SetAutoFit_MaxWidth(MAX_WIDTH - IMAGE_SIZE)
										end

										do -- SUBTITLE
											Info.Subtitle = addon.C.FrameTemplates:CreateText(Info, addon.CS:GetSharedColor().RGB_WHITE, 12, "LEFT", "TOP", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Subtitle")
											Info.Subtitle:SetPoint("TOPLEFT", Info.Title, "BOTTOMLEFT", 0, -5)
											Info.Subtitle:SetAutoFit(true, true)
											Info.Subtitle:SetAutoFit_MaxWidth(MAX_WIDTH - IMAGE_SIZE)
											Info.Subtitle:SetAlpha(.5)
										end
									end
								end
							end
						end
					end

					do -- REFERENCES
						-- CORE
						Frame.REF_CONTENT = Frame.Content
						Frame.REF_CONTAINER = Frame.Content.Container
						Frame.REF_IMAGE = Frame.Content.Container.Image
						Frame.REF_INFO = Frame.Content.Container.Info

						-- IMAGE
						Frame.REF_IMAGE_BACKGROUND = Frame.REF_IMAGE.Background
						Frame.REF_IMAGE_BACKGROUND_TEXTURE = Frame.REF_IMAGE.BackgroundTexture

						-- INFO
						Frame.REF_INFO_TITLE = Frame.REF_INFO.Title
						Frame.REF_INFO_SUBTITLE = Frame.REF_INFO.Subtitle
					end

					do -- LOGIC
						do -- FUNCTIONS
							do -- SET
								function Frame:SetInfo(imageTexture, title, subtitle)
									Frame.REF_IMAGE_BACKGROUND_TEXTURE:SetTexture(imageTexture)
									Frame.REF_INFO_TITLE:SetText(title)
									Frame.REF_INFO_SUBTITLE:SetText(subtitle)

									--------------------------------

									Frame:UpdateLayout()
								end
							end

							do -- LOGIC
								function Frame:UpdateLayout()
									Frame.REF_INFO:SetWidth(math.max(Frame.REF_INFO_TITLE:GetWidth(), Frame.REF_INFO_SUBTITLE:GetWidth()))
									Frame.REF_INFO:SetHeight(Frame.REF_INFO_TITLE:GetHeight() + 5 + Frame.REF_INFO_SUBTITLE:GetHeight())
									Frame.REF_CONTENT:SetWidth(Frame.REF_IMAGE:GetWidth() + 7.5 + Frame.REF_INFO:GetWidth())
									Frame.REF_CONTENT:SetHeight(Frame.REF_INFO:GetHeight())
									Frame.REF_CONTAINER:SetWidth(Frame.REF_CONTENT:GetWidth())
									Frame.REF_CONTAINER:SetHeight(Frame.REF_CONTENT:GetHeight())
								end
							end
						end
					end

					--------------------------------

					return Frame
				end)
			end

			do -- CONTAINER
				PrefabRegistry:Add("C.Config.Main.Setting.Container", function(parent, frameStrata, frameLevel, data, name)
					local transparent, subcontainer = data.transparent, data.subcontainer

					--------------------------------

					local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name, parent)
					Frame:SetFrameStrata(frameStrata)
					Frame:SetFrameLevel(frameLevel)

					--------------------------------

					do -- ELEMENTS
						local PADDING_CONTENT = NS.Variables:RATIO(8.25)

						--------------------------------

						do -- CONTENT
							Frame.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Frame)
							Frame.Content:SetPoint("CENTER", Frame)
							Frame.Content:SetFrameStrata(frameStrata)
							Frame.Content:SetFrameLevel(frameLevel + 1)
							addon.C.API.FrameUtil:SetDynamicSize(Frame.Content, Frame, 0, 0)

							local Content = Frame.Content

							--------------------------------

							do -- BACKGROUND
								Content.Background, Content.BackgroundTexture = addon.C.FrameTemplates:CreateNineSlice(Content, frameStrata, nil, 70, .25, "$parent.Background", Enum.UITextureSliceMode.Stretched)
								Content.Background:SetPoint("CENTER", Content)
								Content.Background:SetFrameStrata(frameStrata)
								Content.Background:SetFrameLevel(frameLevel + 1)
								addon.C.API.FrameUtil:SetDynamicSize(Content.Background, Content, -7.5, -7.5)
							end

							do -- CONTENT
								Content.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Content)
								Content.Content:SetPoint("CENTER", Content)
								Content.Content:SetFrameStrata(frameStrata)
								Content.Content:SetFrameLevel(frameLevel + 2)
								addon.C.API.FrameUtil:SetDynamicSize(Content.Content, Content, PADDING_CONTENT, PADDING_CONTENT)

								local Subcontent = Content.Content

								--------------------------------

								do -- LAYOUT GROUP
									Subcontent.LayoutGroup, Subcontent.LayoutGroup_Sort = addon.C.FrameTemplates:CreateLayoutGroup(Subcontent, { point = "TOP", direction = "vertical", resize = true, padding = 5, distribute = false, distributeResizeElements = false, excludeHidden = true, autoSort = true, customOffset = nil, customLayoutSort = nil }, "$parent.LayoutGroup")
									Subcontent.LayoutGroup:SetPoint("CENTER", Subcontent)
									Subcontent.LayoutGroup:SetFrameStrata(frameStrata)
									Subcontent.LayoutGroup:SetFrameLevel(frameLevel + 3)
									addon.C.API.FrameUtil:SetDynamicSize(Subcontent.LayoutGroup, Subcontent, 0, nil)
									addon.C.API.FrameUtil:SetDynamicSize(Frame, Subcontent.LayoutGroup, nil, -PADDING_CONTENT)
									Frame.LGS_CONTENT = Subcontent.LayoutGroup_Sort
								end
							end
						end
					end

					do -- REFERENCES
						-- CORE
						Frame.REF_CONTENT = Frame.Content
						Frame.REF_BACKGROUND = Frame.Content.Background
						Frame.REF_MAIN = Frame.Content.Content

						-- BACKGROUND
						Frame.REF_BACKGROUND_TEXTURE = Frame.Content.BackgroundTexture

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

								if skipAnimation then
									Frame.REF_CONTENT:SetAlpha(1)
									Frame.REF_CONTENT:SetPoint("CENTER", Frame.REF_CONTENT:GetParent(), 0, 0)
								else
									addon.C.Animation:Alpha({ ["frame"] = Frame.REF_CONTENT, ["duration"] = .25, ["from"] = 0, ["to"] = 1, ["ease"] = nil, ["stopEvent"] = Frame.ShowWithAnimation_StopEvent })
									addon.C.Animation:Translate({ ["frame"] = Frame.REF_CONTENT, ["duration"] = .5, ["from"] = -15, ["to"] = 0, ["axis"] = "y", ["ease"] = "EaseExpo_Out", ["stopEvent"] = Frame.ShowWithAnimation_StopEvent })
								end
							end

							function Frame:ShowWithAnimation_Pre()
								addon.C.Animation:CancelAll(Frame.REF_CONTENT)

								--------------------------------

								Frame.REF_CONTENT:SetAlpha(0)
							end
						end
					end

					do -- LOGIC
						Frame.VAR_PARENT = nil
						Frame.VAR_TRANSPARENT = transparent
						Frame.VAR_SUBCONTAINER = subcontainer

						--------------------------------

						do -- FUNCTIONS
							do -- LOGIC
								function Frame:UpdateLayout()
									Frame.LGS_CONTENT()

									--------------------------------

									if Frame.VAR_PARENT then
										Frame.VAR_PARENT.LGS_CONTENT()
									end
								end

								function Frame:UpdateTransparency()
									if Frame.VAR_TRANSPARENT then
										Frame.REF_BACKGROUND:SetAlpha(0)
									else
										Frame.REF_BACKGROUND:SetAlpha(1)
									end
								end

								function Frame:UpdateSubcontainer()
									if Frame.VAR_SUBCONTAINER then
										Frame.REF_BACKGROUND_TEXTURE:SetTexture(addon.CS:GetCommonPathConfig() .. "frame-light.png")
										if Frame.VAR_PARENT then addon.C.API.Util:SetFontSize(Frame.VAR_PARENT.REF_HEADER_TITLE_TEXT, 14) end
									else
										Frame.REF_BACKGROUND_TEXTURE:SetTexture(addon.CS:GetCommonPathConfig() .. "frame.png")
									end
								end
							end
						end

						do -- EVENTS
							local function Event_ConfigUpdate()
								Frame:UpdateLayout()
							end

							local function Event_FontOverrideReady()
								Frame:UpdateLayout()
							end

							if Frame.VAR_SUBCONTAINER then CallbackRegistry:Add("C_CONFIG_UPDATE", Event_ConfigUpdate, 9) else CallbackRegistry:Add("C_CONFIG_UPDATE", Event_ConfigUpdate, 10) end
							CallbackRegistry:Add("C_FONT_OVERRIDE_READY", Event_FontOverrideReady, 10)
						end
					end

					do -- SETUP
						C_Timer.After(0, function()
							Frame:UpdateTransparency()
							Frame:UpdateSubcontainer()
						end)
					end

					--------------------------------

					return Frame
				end)

				PrefabRegistry:Add("C.Config.Main.Setting.Container.Title", function(parent, frameStrata, frameLevel, data, name)
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
								Content.LayoutGroup, Content.LayoutGroup_Sort = addon.C.FrameTemplates:CreateLayoutGroup(Content, { point = "TOP", direction = "vertical", resize = true, padding = 0, distribute = false, distributeResizeElements = false, excludeHidden = true, autoSort = true, customOffset = nil, customLayoutSort = nil }, "$parent.LayoutGroup")
								Content.LayoutGroup:SetPoint("CENTER", Content)
								Content.LayoutGroup:SetFrameStrata(frameStrata)
								Content.LayoutGroup:SetFrameLevel(frameLevel + 2)
								addon.C.API.FrameUtil:SetDynamicSize(Content.LayoutGroup, Content, 0, nil)
								addon.C.API.FrameUtil:SetDynamicSize(Frame, Content.LayoutGroup, nil, 0)
								Frame.LGS_CONTENT = Content.LayoutGroup_Sort

								local Content_LayoutGroup = Content.LayoutGroup

								--------------------------------

								do -- ELEMENTS
									local HEADER_HEIGHT = 27.5

									--------------------------------

									do -- HEADER
										Content_LayoutGroup.Header = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Header", Content_LayoutGroup)
										Content_LayoutGroup.Header:SetHeight(HEADER_HEIGHT)
										Content_LayoutGroup.Header:SetFrameStrata(frameStrata)
										Content_LayoutGroup.Header:SetFrameLevel(frameLevel + 3)
										addon.C.API.FrameUtil:SetDynamicSize(Content_LayoutGroup.Header, Content_LayoutGroup, 0, nil)
										Content_LayoutGroup:AddElement(Content_LayoutGroup.Header)

										local Header = Content_LayoutGroup.Header

										--------------------------------

										do -- TITLE
											Header.Title = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Title", Header)
											Header.Title:SetPoint("CENTER", Header)
											Header.Title:SetFrameStrata(frameStrata)
											Header.Title:SetFrameLevel(frameLevel + 4)
											addon.C.API.FrameUtil:SetDynamicSize(Header.Title, Header, 35, 0)

											local Title = Header.Title

											--------------------------------

											do -- TEXT
												Title.Text = addon.C.FrameTemplates:CreateText(Header.Title, addon.CS:GetSharedColor().RGB_YELLOW, 15, "LEFT", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Text")
												Title.Text:SetPoint("CENTER", Title)
												addon.C.API.FrameUtil:SetDynamicSize(Title.Text, Title, 0, 0)
											end
										end
									end

									do -- CONTAINER
										Content_LayoutGroup.Container = PrefabRegistry:Create("C.Config.Main.Setting.Container", Content_LayoutGroup, frameStrata, frameLevel + 3, data, "$parent.Container")
										Content_LayoutGroup.Container:SetFrameStrata(frameStrata)
										Content_LayoutGroup.Container:SetFrameLevel(frameLevel + 3)
										addon.C.API.FrameUtil:SetDynamicSize(Content_LayoutGroup.Container, Content_LayoutGroup, 0, nil)
										Content_LayoutGroup:AddElement(Content_LayoutGroup.Container)

										--------------------------------

										Content_LayoutGroup.Container.VAR_PARENT = Frame
									end
								end
							end
						end
					end

					do -- REFERENCES
						-- CORE
						Frame.REF_CONTENT = Frame.Content
						Frame.REF_LAYOUT = Frame.REF_CONTENT.LayoutGroup
						Frame.REF_HEADER = Frame.REF_LAYOUT.Header
						Frame.REF_CONTAINER = Frame.REF_LAYOUT.Container

						-- HEADER
						Frame.REF_HEADER_TITLE = Frame.REF_HEADER.Title
						Frame.REF_HEADER_TITLE_TEXT = Frame.REF_HEADER_TITLE.Text
					end

					do -- ANIMATIONS
						do -- SHOW
							function Frame:ShowWithAnimation_StopEvent()
								return not Frame:IsVisible()
							end

							function Frame:ShowWithAnimation(skipAnimation)
								if skipAnimation then
									Frame.REF_HEADER_TITLE:SetAlpha(1)
								else
									addon.C.Animation:Alpha({ ["frame"] = Frame.REF_HEADER_TITLE, ["duration"] = .25, ["from"] = 0, ["to"] = 1, ["ease"] = nil, ["stopEvent"] = Frame.ShowWithAnimation_StopEvent })
								end

								--------------------------------

								Frame.REF_CONTAINER:ShowWithAnimation(skipAnimation)
							end

							function Frame:ShowWithAnimation_Pre()
								addon.C.Animation:CancelAll(Frame.REF_HEADER_TITLE)

								--------------------------------

								Frame.REF_HEADER_TITLE:SetAlpha(0)
								Frame.REF_CONTAINER:ShowWithAnimation_Pre()
							end
						end
					end

					do -- LOGIC
						do -- FUNCTIONS
							do -- SET
								function Frame:SetTitle(text)
									Frame.REF_HEADER_TITLE_TEXT:SetText(text)
								end
							end

							do -- LOGIC
								function Frame:UpdateLayout()
									Frame.REF_CONTAINER:UpdateLayout()
									Frame.LGS_CONTENT()
								end
							end
						end
					end

					--------------------------------

					return Frame
				end)
			end

			do -- ELEMENT
				PrefabRegistry:Add("C.Config.Main.Setting.Element.Template", function(parent, frameStrata, frameLevel, data, name)
					local indent, transparent = data.indent or 0, data.transparent

					--------------------------------

					local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name, parent)
					Frame:SetFrameStrata(frameStrata)
					Frame:SetFrameLevel(frameLevel)

					--------------------------------

					do -- ELEMENTS
						local MIN_HEIGHT = 17.5
						local INDENT_WIDTH = 15

						--------------------------------

						do -- CONTENT
							Frame.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Frame)
							Frame.Content:SetPoint("CENTER", Frame)
							Frame.Content:SetFrameStrata(frameStrata)
							Frame.Content:SetFrameLevel(frameLevel + 1)
							addon.C.API.FrameUtil:SetDynamicSize(Frame.Content, Frame, 0, 0)

							local Content = Frame.Content

							--------------------------------

							do -- ELEMENTS
								local PADDING_CONTENT = NS.Variables:RATIO(8)

								--------------------------------

								do -- BACKGROUND
									Content.Background, Content.BackgroundTexture = addon.C.FrameTemplates:CreateNineSlice(Content, frameStrata, addon.CS:GetCommonPathConfig() .. "button-background.png", 70, .125, "$parent.Background", Enum.UITextureSliceMode.Stretched)
									Content.Background:SetPoint("CENTER", Content)
									Content.Background:SetFrameStrata(frameStrata)
									Content.Background:SetFrameLevel(frameLevel + 1)
									addon.C.API.FrameUtil:SetDynamicSize(Content.Background, Content, -10, -10)
								end

								do -- DIVIDER
									Content.Divider = PrefabRegistry:Create("C.Config.Main.Setting.Element.Template.Divider", Content, frameStrata, frameLevel + 2, "$parent.Divider")
									Content.Divider:SetHeight(1)
									Content.Divider:SetPoint("TOP", Content, "BOTTOM", 0, -2.5)
									Content.Divider:SetFrameStrata(frameStrata)
									Content.Divider:SetFrameLevel(frameLevel + 2)
									addon.C.API.FrameUtil:SetDynamicSize(Content.Divider, Content, 0, nil)
								end

								do -- CONTENT
									Content.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Content)
									Content.Content:SetPoint("RIGHT", Content, -PADDING_CONTENT / 2, 0)
									Content.Content:SetFrameStrata(frameStrata)
									Content.Content:SetFrameLevel(frameLevel + 2)
									addon.C.API.FrameUtil:SetDynamicSize(Content.Content, Content, PADDING_CONTENT + (indent * INDENT_WIDTH), PADDING_CONTENT)

									local Subcontent = Content.Content

									--------------------------------

									do -- ELEMENTS
										local INFO_WIDTH_MODIFIER = .61
										local INFO_TEXT_WIDTH_MAX = 200
										local ACTION_WIDTH_MODIFIER = 1 - INFO_WIDTH_MODIFIER

										--------------------------------

										do -- INFO
											Subcontent.Info = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Info", Subcontent)
											Subcontent.Info:SetPoint("LEFT", Subcontent)
											Subcontent.Info:SetFrameStrata(frameStrata)
											Subcontent.Info:SetFrameLevel(frameLevel + 3)
											addon.C.API.FrameUtil:SetDynamicSize(Subcontent.Info, Subcontent, function(relativeWidth, relativeHeight) return relativeWidth * INFO_WIDTH_MODIFIER end, 0)

											local Info = Subcontent.Info

											--------------------------------

											do -- CONTENT
												Info.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Info)
												Info.Content:SetPoint("CENTER", Info)
												Info.Content:SetFrameStrata(frameStrata)
												Info.Content:SetFrameLevel(frameLevel + 4)
												addon.C.API.FrameUtil:SetDynamicSize(Info.Content, Info, 0, 0)

												local Info_Content = Info.Content

												--------------------------------

												do -- LAYOUT GROUP
													Info_Content.LayoutGroup, Info_Content.LayoutGroup_Sort = addon.C.FrameTemplates:CreateLayoutGroup(Info_Content, { point = "TOPLEFT", direction = "vertical", resize = true, padding = PADDING * .25, distribute = false, distributeResizeElements = false, excludeHidden = true, autoSort = true, customOffset = nil, customLayoutSort = nil }, "$parent.LayoutGroup")
													Info_Content.LayoutGroup:SetPoint("CENTER", Info_Content)
													Info_Content.LayoutGroup:SetFrameStrata(frameStrata)
													Info_Content.LayoutGroup:SetFrameLevel(frameLevel + 5)
													addon.C.API.FrameUtil:SetDynamicSize(Info_Content.LayoutGroup, Info_Content, 0, nil)
													addon.C.API.FrameUtil:SetDynamicSize(Frame, Info_Content.LayoutGroup, nil, function(relativeWidth, relativeHeight)
														local new = relativeHeight + PADDING_CONTENT + 5

														--------------------------------

														return math.max(new, MIN_HEIGHT)
													end)
													Frame.LGS_INFO = Info_Content.LayoutGroup_Sort

													local Info_LayoutGroup = Info_Content.LayoutGroup

													--------------------------------

													do -- ELEMENTS
														do -- TITLE
															Info_LayoutGroup.Title = addon.C.FrameTemplates:CreateText(Info_LayoutGroup, addon.CS:GetSharedColor().RGB_WHITE, 12, "LEFT", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Title", "GameFontNormal")
															Info_LayoutGroup.Title:SetAutoFit(true, true)
															Info_LayoutGroup.Title:SetAutoFit_MaxWidth(INFO_TEXT_WIDTH_MAX)
															Info_LayoutGroup:AddElement(Info_LayoutGroup.Title)
														end

														do -- IMAGE
															Info_LayoutGroup.Image = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Image", Info_LayoutGroup)
															Info_LayoutGroup.Image:SetFrameStrata(frameStrata)
															Info_LayoutGroup.Image:SetFrameLevel(frameLevel + 6)
															Info_LayoutGroup:AddElement(Info_LayoutGroup.Image)

															local Image = Info_LayoutGroup.Image

															--------------------------------

															do -- BACKGROUND
																Image.Background, Image.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(Image, frameStrata, nil, "$parent.Background")
																Image.Background:SetPoint("CENTER", Image)
																Image.Background:SetFrameStrata(frameStrata)
																Image.Background:SetFrameLevel(frameLevel + 6)
																addon.C.API.FrameUtil:SetDynamicSize(Image.Background, Image, 0, 0)
															end
														end

														do -- SUBTITLE
															Info_LayoutGroup.Subtitle = addon.C.FrameTemplates:CreateText(Info_LayoutGroup, addon.CS:GetSharedColor().RGB_WHITE, 11, "LEFT", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Subtitle", "GameFontNormal")
															Info_LayoutGroup.Subtitle:SetAutoFit(true, true)
															Info_LayoutGroup.Subtitle:SetAutoFit_MaxWidth(INFO_TEXT_WIDTH_MAX)
															Info_LayoutGroup.Subtitle:SetAlpha(.5)
															Info_LayoutGroup:AddElement(Info_LayoutGroup.Subtitle)
														end
													end
												end
											end
										end

										do -- ACTION
											Subcontent.Action = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Action", Subcontent)
											Subcontent.Action:SetHeight(MIN_HEIGHT)
											Subcontent.Action:SetPoint("RIGHT", Subcontent, 0, 0)
											Subcontent.Action:SetFrameStrata(frameStrata)
											Subcontent.Action:SetFrameLevel(frameLevel + 4)
											addon.C.API.FrameUtil:SetDynamicSize(Subcontent.Action, Subcontent, function(relativeWidth, relativeHeight) return relativeWidth * ACTION_WIDTH_MODIFIER end, nil)

											local Action = Subcontent.Action

											--------------------------------

											do -- CONTENT
												Action.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Action)
												Action.Content:SetPoint("CENTER", Action)
												Action.Content:SetFrameStrata(frameStrata)
												Action.Content:SetFrameLevel(frameLevel + 5)
												addon.C.API.FrameUtil:SetDynamicSize(Action.Content, Action, 0, 0)
											end
										end
									end
								end
							end
						end
					end

					do -- REFERENCES
						-- CORE
						Frame.REF_CONTENT = Frame.Content
						Frame.REF_BACKGROUND = Frame.Content.Background
						Frame.REF_DIVIDER = Frame.Content.Divider
						Frame.REF_MAIN = Frame.Content.Content

						-- BACKGROUND
						Frame.REF_BACKGROUND_TEXTURE = Frame.Content.BackgroundTexture

						-- MAIN
						Frame.REF_MAIN_INFO = Frame.REF_MAIN.Info
						Frame.REF_MAIN_INFO_LAYOUT = Frame.REF_MAIN_INFO.Content.LayoutGroup
						Frame.REF_MAIN_INFO_LAYOUT_TITLE = Frame.REF_MAIN_INFO_LAYOUT.Title
						Frame.REF_MAIN_INFO_LAYOUT_IMAGE = Frame.REF_MAIN_INFO_LAYOUT.Image
						Frame.REF_MAIN_INFO_LAYOUT_IMAGE_BACKGROUND = Frame.REF_MAIN_INFO_LAYOUT_IMAGE.Background
						Frame.REF_MAIN_INFO_LAYOUT_IMAGE_BACKGROUND_TEXTURE = Frame.REF_MAIN_INFO_LAYOUT_IMAGE.BackgroundTexture
						Frame.REF_MAIN_INFO_LAYOUT_SUBTITLE = Frame.REF_MAIN_INFO_LAYOUT.Subtitle
						Frame.REF_MAIN_ACTION = Frame.REF_MAIN.Action
						Frame.REF_MAIN_ACTION_CONTENT = Frame.REF_MAIN_ACTION.Content
					end

					do -- ANIMATIONS
						do -- ON ENTER
							function Frame:Animation_OnEnter_StopEvent()
								return not Frame.isMouseOver
							end

							function Frame:Animation_OnEnter(skipAnimation)
								if not transparent then
									Frame.REF_BACKGROUND:Show()
								end
							end
						end

						do -- ON LEAVE
							function Frame:Animation_OnLeave_StopEvent()
								return not Frame.isMouseOver
							end

							function Frame:Animation_OnLeave(skipAnimation)
								if not transparent then
									Frame.REF_BACKGROUND:Hide()
								end
							end
						end
					end

					do -- LOGIC
						Frame.isMouseOver = false
						Frame.isMouseDown = false

						Frame.enterCallbacks = {}
						Frame.leaveCallbacks = {}
						Frame.mouseDownCallbacks = {}
						Frame.mouseUpCallbacks = {}
						Frame.onConfigUpdateCallbacks = {}

						Frame.VAR_TRANSPARENT = transparent
						Frame.VAR_ELEMENT_HEIGHT = 15

						--------------------------------

						do -- FUNCTIONS
							do -- SET
								function Frame:SetTitle(title, imageInfo, subtitle)
									do -- TITLE
										Frame.REF_MAIN_INFO_LAYOUT_TITLE:SetShown(title)
										Frame.REF_MAIN_INFO_LAYOUT_TITLE:SetText(title)
									end

									do -- IMAGE
										Frame.REF_MAIN_INFO_LAYOUT_IMAGE:SetShown(imageInfo)

										if imageInfo then
											Frame.REF_MAIN_INFO_LAYOUT_IMAGE:SetSize(imageInfo.imageType == addon.C.AddonInfo.Variables.Config.IMAGE_TYPE_LARGE and 150 or 75, 75)
											Frame.REF_MAIN_INFO_LAYOUT_IMAGE_BACKGROUND_TEXTURE:SetTexture(imageInfo.imagePath)
										end
									end

									do -- SUBTITLE
										Frame.REF_MAIN_INFO_LAYOUT_SUBTITLE:SetShown(subtitle)
										Frame.REF_MAIN_INFO_LAYOUT_SUBTITLE:SetText(subtitle)
									end

									--------------------------------

									Frame:UpdateLayout()
								end
							end

							do -- LOGIC
								function Frame:UpdateLayout()
									Frame.LGS_INFO()
								end

								function Frame:UpdateTransparency()
									if Frame.VAR_TRANSPARENT then
										Frame.REF_DIVIDER:Hide()
										Frame.REF_BACKGROUND:Hide()
									else
										Frame.REF_DIVIDER:Show()
									end
								end
							end
						end

						do -- EVENTS
							local function Event_ConfigUpdate()
								if not Frame:IsVisible() then
									return
								end

								--------------------------------

								do -- ON CONFIG UPDATE
									local onConfigUpdateCallbacks = Frame.onConfigUpdateCallbacks

									if #onConfigUpdateCallbacks >= 1 then
										for callback = 1, #onConfigUpdateCallbacks do
											onConfigUpdateCallbacks[callback](Frame)
										end
									end
								end
							end

							local function Event_FontOverrideReady()
								Frame:UpdateLayout()
							end

							function Frame:OnEnter(skipAnimation)
								Frame.isMouseOver = true

								--------------------------------

								Frame:Animation_OnEnter(skipAnimation)

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

								Frame:Animation_OnLeave(skipAnimation)

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

							addon.C.FrameTemplates:CreateMouseResponder(Frame, { enterCallback = Frame.OnEnter, leaveCallback = Frame.OnLeave, mouseDownCallback = Frame.OnMouseDown, mouseUpCallback = Frame.OnMouseUp })
							CallbackRegistry:Add("C_CONFIG_UPDATE", Event_ConfigUpdate)
							CallbackRegistry:Add("C_FONT_OVERRIDE_READY", Event_FontOverrideReady)
						end
					end

					do -- SETUP
						Frame:UpdateTransparency()
					end

					--------------------------------

					return Frame
				end)

				PrefabRegistry:Add("C.Config.Main.Setting.Element.Template.Divider", function(parent, frameStrata, frameLevel, name)
					local Frame = addon.C.FrameTemplates:CreateFrame("Frame", name, parent)
					Frame:SetFrameStrata(frameStrata)
					Frame:SetFrameLevel(frameLevel)

					--------------------------------

					do -- ELEMENTS
						do -- BACKGROUND
							Frame.Background, Frame.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(Frame, frameStrata, addon.CS:GetCommonPathArt() .. "Basic/square.png", "$parent.Background")
							Frame.Background:SetPoint("CENTER", Frame)
							Frame.Background:SetFrameStrata(frameStrata)
							Frame.Background:SetFrameLevel(frameLevel + 1)
							addon.C.API.FrameUtil:SetDynamicSize(Frame.Background, Frame, 0, 0)
							Frame.BackgroundTexture:SetVertexColor(1, 1, 1, .075)
						end
					end

					do -- REFERENCES
						-- CORE
						Frame.REF_BACKGROUND = Frame.Background

						-- BACKGROUND
						Frame.REF_BACKGROUND_TEXTURE = Frame.BackgroundTexture
					end

					--------------------------------

					return Frame
				end)

				PrefabRegistry:Add("C.Config.Main.Setting.Element.Text", function(parent, frameStrata, frameLevel, data, name)
					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.Template", parent, frameStrata, frameLevel, data, name)
					Frame:SetFrameStrata(frameStrata)
					Frame:SetFrameLevel(frameLevel)

					--------------------------------

					do -- SETUP
						Frame:OnLeave(true)
					end

					--------------------------------

					return Frame
				end)

				PrefabRegistry:Add("C.Config.Main.Setting.Element.Checkbox", function(parent, frameStrata, frameLevel, data, name)
					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.Template", parent, frameStrata, frameLevel, data, name)
					Frame:SetFrameStrata(frameStrata)
					Frame:SetFrameLevel(frameLevel)

					--------------------------------

					do -- ELEMENTS
						do -- ACTION CONTENT
							local Action_Content = Frame.REF_MAIN_ACTION_CONTENT
							local Action_Content_FrameLevel = Action_Content:GetFrameLevel()

							--------------------------------

							do -- CHECKBOX
								Action_Content.Checkbox = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Checkbox", Action_Content, frameStrata, Action_Content_FrameLevel + 1, nil, "$parent.Checkbox")
								Action_Content.Checkbox:SetSize(Frame.VAR_ELEMENT_HEIGHT * 1.175, Frame.VAR_ELEMENT_HEIGHT * 1.175)
								Action_Content.Checkbox:SetPoint("RIGHT", Action_Content)
								Action_Content.Checkbox:SetFrameStrata(frameStrata)
								Action_Content.Checkbox:SetFrameLevel(Action_Content_FrameLevel + 1)
							end
						end
					end

					do -- REFERENCES
						Frame.REF_CHECKBOX = Frame.REF_MAIN_ACTION_CONTENT.Checkbox
					end

					do -- SETUP
						Frame:OnLeave(true)
					end

					--------------------------------

					return Frame
				end)

				PrefabRegistry:Add("C.Config.Main.Setting.Element.Range", function(parent, frameStrata, frameLevel, data, name)
					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.Template", parent, frameStrata, frameLevel, data, name)
					Frame:SetFrameStrata(frameStrata)
					Frame:SetFrameLevel(frameLevel)

					--------------------------------

					do -- ELEMENTS
						do -- ACTION CONTENT
							local Action_Content = Frame.REF_MAIN_ACTION_CONTENT
							local Action_Content_FrameLevel = Action_Content:GetFrameLevel()

							--------------------------------

							do -- RANGE
								Action_Content.Range = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Range.Text", Action_Content, frameStrata, Action_Content_FrameLevel + 1, { ["rangeWidth"] = 125, ["resize"] = false, ["direction"] = "LEFT" }, "$parent.Range")
								Action_Content.Range:SetSize(200, 10)
								Action_Content.Range:SetPoint("RIGHT", Action_Content)
								Action_Content.Range:SetFrameStrata(frameStrata)
								Action_Content.Range:SetFrameLevel(Action_Content_FrameLevel + 1)
							end
						end
					end

					do -- REFERENCES
						Frame.REF_RANGE = Frame.REF_MAIN_ACTION_CONTENT.Range
					end

					do -- SETUP
						Frame:OnLeave(true)
					end

					--------------------------------

					return Frame
				end)

				PrefabRegistry:Add("C.Config.Main.Setting.Element.Button", function(parent, frameStrata, frameLevel, data, name)
					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.Template", parent, frameStrata, frameLevel, data, name)
					Frame:SetFrameStrata(frameStrata)
					Frame:SetFrameLevel(frameLevel)

					--------------------------------

					do -- ELEMENTS
						do -- ACTION CONTENT
							local Action_Content = Frame.REF_MAIN_ACTION_CONTENT
							local Action_Content_FrameLevel = Action_Content:GetFrameLevel()

							--------------------------------

							do -- BUTTON
								Action_Content.Button = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Button.Text.Red", Action_Content, frameStrata, Action_Content_FrameLevel + 1, { ["resize"] = false }, "$parent.Button")
								Action_Content.Button:SetSize(125, Frame.VAR_ELEMENT_HEIGHT * 1.5)
								Action_Content.Button:SetPoint("RIGHT", Action_Content)
								Action_Content.Button:SetFrameStrata(frameStrata)
								Action_Content.Button:SetFrameLevel(Action_Content_FrameLevel + 1)
							end
						end
					end

					do -- REFERENCES
						Frame.REF_BUTTON = Frame.REF_MAIN_ACTION_CONTENT.Button
					end

					do -- SETUP
						Frame:OnLeave(true)
					end

					--------------------------------

					return Frame
				end)

				PrefabRegistry:Add("C.Config.Main.Setting.Element.Dropdown", function(parent, frameStrata, frameLevel, data, name)
					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.Template", parent, frameStrata, frameLevel, data, name)
					Frame:SetFrameStrata(frameStrata)
					Frame:SetFrameLevel(frameLevel)

					--------------------------------

					do -- ELEMENTS
						do -- ACTION CONTENT
							local Action_Content = Frame.REF_MAIN_ACTION_CONTENT
							local Action_Content_FrameLevel = Action_Content:GetFrameLevel()

							--------------------------------

							do -- DROPDOWN
								Action_Content.Dropdown = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Button.Dropdown", Action_Content, frameStrata, Action_Content_FrameLevel + 1, { ["resizeContextMenu"] = true }, "$parent.Dropdown")
								Action_Content.Dropdown:SetSize(125, Frame.VAR_ELEMENT_HEIGHT * 1.5)
								Action_Content.Dropdown:SetPoint("RIGHT", Action_Content)
								Action_Content.Dropdown:SetFrameStrata(frameStrata)
								Action_Content.Dropdown:SetFrameLevel(Action_Content_FrameLevel + 1)
							end
						end
					end

					do -- REFERENCES
						Frame.REF_DROPDOWN = Frame.REF_MAIN_ACTION_CONTENT.Dropdown
					end

					do -- SETUP
						Frame:OnLeave(true)
					end

					--------------------------------

					return Frame
				end)

				PrefabRegistry:Add("C.Config.Main.Setting.Element.Color", function(parent, frameStrata, frameLevel, data, name)
					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.Template", parent, frameStrata, frameLevel, data, name)
					Frame:SetFrameStrata(frameStrata)
					Frame:SetFrameLevel(frameLevel)

					--------------------------------

					do -- ELEMENTS
						do -- ACTION CONTENT
							local Action_Content = Frame.REF_MAIN_ACTION_CONTENT
							local Action_Content_FrameLevel = Action_Content:GetFrameLevel()

							--------------------------------

							do -- COLOR
								Action_Content.Color = PrefabRegistry:Create("C.FrameTemplates.Blizzard.Color", Action_Content, frameStrata, Action_Content_FrameLevel + 1, {}, "$parent.Color")
								Action_Content.Color:SetSize(125, Frame.VAR_ELEMENT_HEIGHT * 1.5)
								Action_Content.Color:SetPoint("RIGHT", Action_Content)
								Action_Content.Color:SetFrameStrata(frameStrata)
								Action_Content.Color:SetFrameLevel(Action_Content_FrameLevel + 1)
							end
						end
					end

					do -- REFERENCES
						Frame.REF_COLOR = Frame.REF_MAIN_ACTION_CONTENT.Color
					end

					do -- SETUP
						Frame:OnLeave(true)
					end

					--------------------------------

					return Frame
				end)

				PrefabRegistry:Add("C.Config.Main.Setting.Element.TextBox", function(parent, frameStrata, frameLevel, data, name)
					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.Template", parent, frameStrata, frameLevel, data, name)
					Frame:SetFrameStrata(frameStrata)
					Frame:SetFrameLevel(frameLevel)

					--------------------------------

					do -- ELEMENTS
						do -- ACTION CONTENT
							local Action_Content = Frame.REF_MAIN_ACTION_CONTENT
							local Action_Content_FrameLevel = Action_Content:GetFrameLevel()

							--------------------------------

							do -- TEXT BOX
								Action_Content.TextBox = PrefabRegistry:Create("C.FrameTemplates.Blizzard.TextBox", Action_Content, frameStrata, Action_Content_FrameLevel + 1, { inset = 10 }, "$parent.TextBox")
								Action_Content.TextBox:SetSize(125, Frame.VAR_ELEMENT_HEIGHT * 1.5)
								Action_Content.TextBox:SetPoint("RIGHT", Action_Content)
								Action_Content.TextBox:SetFrameStrata(frameStrata)
								Action_Content.TextBox:SetFrameLevel(Action_Content_FrameLevel + 1)
							end
						end
					end

					do -- REFERENCES
						Frame.REF_TEXTBOX = Frame.REF_MAIN_ACTION_CONTENT.TextBox
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
end
