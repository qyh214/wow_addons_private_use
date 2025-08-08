---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.WaypointSystem; addon.WaypointSystem = NS

--------------------------------

NS.Elements = {}

--------------------------------

function NS.Elements:Load()
	--------------------------------
	-- CREATE ELEMENTS
	--------------------------------

	do
		do -- ELEMENTS
			WaypointFrame.Waypoint = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Waypoint", WaypointFrame)
			WaypointFrame.Waypoint:SetFrameStrata(NS.Variables.FRAME_STRATA)
			WaypointFrame.Waypoint:SetFrameLevel(NS.Variables.FRAME_LEVEL)

			local Frame = WaypointFrame.Waypoint
			local Frame_BlizzardWaypoint = SuperTrackedFrame

			--------------------------------

			do -- ELEMENTS
				local PADDING = NS.Variables.PADDING

				--------------------------------

				do -- WORLD
					Frame.World = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.World", Frame)
					Frame.World:SetAllPoints(Frame)

					local World = Frame.World

					--------------------------------

					do -- WAYPOINT
						World.Waypoint = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Waypoint", World)
						World.Waypoint:SetSize(37.5, 37.5)
						World.Waypoint:SetFrameStrata(NS.Variables.FRAME_STRATA)
						World.Waypoint:SetFrameLevel(NS.Variables.FRAME_LEVEL + 1)

						local Waypoint = World.Waypoint

						--------------------------------

						do -- CONTENT
							Waypoint.Alpha_MouseOver = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Alpha_MouseOver", Waypoint)
							Waypoint.Alpha_CharacterOverlap = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Alpha_CharacterOverlap", Waypoint.Alpha_MouseOver)
							Waypoint.Alpha_ScreenEdge = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Alpha_ScreenEdge", Waypoint.Alpha_CharacterOverlap)
							Waypoint.Alpha_MouseOver:SetPoint("CENTER", Waypoint)
							Waypoint.Alpha_CharacterOverlap:SetPoint("CENTER", Waypoint)
							Waypoint.Alpha_ScreenEdge:SetPoint("CENTER", Waypoint)
							addon.C.API.FrameUtil:SetDynamicSize(Waypoint.Alpha_MouseOver, Waypoint, 0, 0)
							addon.C.API.FrameUtil:SetDynamicSize(Waypoint.Alpha_CharacterOverlap, Waypoint, 0, 0)
							addon.C.API.FrameUtil:SetDynamicSize(Waypoint.Alpha_ScreenEdge, Waypoint, 0, 0)

							Waypoint.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Waypoint.Alpha_ScreenEdge)
							Waypoint.Content:SetPoint("CENTER", Waypoint)
							Waypoint.Content:SetFrameStrata(NS.Variables.FRAME_STRATA)
							Waypoint.Content:SetFrameLevel(NS.Variables.FRAME_LEVEL + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Waypoint.Content, Waypoint, 0, 0)

							local Content = Waypoint.Content

							--------------------------------

							do -- ELEMENTS
								local MARKER_HEIGHT = 1000

								--------------------------------

								do -- CONTEXT FRAME
									Content.ContextFrame = PrefabRegistry:Create("WaypointSystem.General.ContextFrame", Content, NS.Variables.FRAME_STRATA, NS.Variables.FRAME_LEVEL + 3, "$parent.ContextFrame")
									Content.ContextFrame:SetPoint("CENTER", Content)
									Content.ContextFrame:SetFrameStrata(NS.Variables.FRAME_STRATA)
									Content.ContextFrame:SetFrameLevel(NS.Variables.FRAME_LEVEL_MAX + 1)
									addon.C.API.FrameUtil:SetDynamicSize(Content.ContextFrame, Content, 0, 0)

									local ContextFrame = Content.ContextFrame

									--------------------------------

									do -- VFX
										ContextFrame.VFX = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.VFX", ContextFrame)
										ContextFrame.VFX:SetSize(125, 125)
										ContextFrame.VFX:SetPoint("CENTER", ContextFrame)
										ContextFrame.VFX:SetFrameStrata(NS.Variables.FRAME_STRATA)
										ContextFrame.VFX:SetFrameLevel(NS.Variables.FRAME_LEVEL_MAX)

										local VFX = ContextFrame.VFX

										--------------------------------

										do -- WAVE
											VFX.Wave = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Wave", VFX)
											VFX.Wave:SetSize(75, 75)
											VFX.Wave:SetPoint("CENTER", VFX)
											VFX.Wave:SetFrameStrata(NS.Variables.FRAME_STRATA)
											VFX.Wave:SetFrameLevel(NS.Variables.FRAME_LEVEL_MAX)

											local Wave = VFX.Wave

											--------------------------------

											do -- BACKGROUND
												Wave.Background, Wave.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(Wave, NS.Variables.FRAME_STRATA, NS.Variables.PATH .. "waypoint-wave.png", "$parent.Background")
												Wave.Background:SetPoint("CENTER", Wave)
												Wave.Background:SetFrameStrata(NS.Variables.FRAME_STRATA)
												Wave.Background:SetFrameLevel(NS.Variables.FRAME_LEVEL_MAX)
												addon.C.API.FrameUtil:SetDynamicSize(Wave.Background, Wave, 0, 0)
											end
										end
									end
								end

								do -- FOOTER
									Content.Footer = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Footer", Content)
									Content.Footer:SetSize(200, 37.5)
									Content.Footer:SetPoint("TOP", Content, "BOTTOM", 0, -7.5)
									Content.Footer:SetFrameStrata(NS.Variables.FRAME_STRATA)
									Content.Footer:SetFrameLevel(NS.Variables.FRAME_LEVEL + 3)
									Content.Footer:SetAlpha(.5)
									Content.Footer:SetIgnoreParentScale(true)

									local Footer = Content.Footer

									--------------------------------

									do -- LAYOUT GROUP
										Footer.LayoutGroup, Footer.LayoutGroup_Sort = addon.C.FrameTemplates:CreateLayoutGroup(Footer, { point = "TOP", direction = "vertical", resize = false, padding = 2.5, distribute = false, distributeResizeElements = false, excludeHidden = true, autoSort = true, customOffset = nil, customLayoutSort = nil }, "$parent.LayoutGroup")
										Footer.LayoutGroup:SetPoint("CENTER", Footer)
										Footer.LayoutGroup:SetFrameStrata(NS.Variables.FRAME_STRATA)
										Footer.LayoutGroup:SetFrameLevel(NS.Variables.FRAME_LEVEL + 4)
										addon.C.API.FrameUtil:SetDynamicSize(Footer.LayoutGroup, Footer, 0, 0)
										Frame.LGS_FOOTER = Footer.LayoutGroup_Sort

										local LayoutGroup = Footer.LayoutGroup

										--------------------------------

										do -- ELEMENTS
											do -- TEXT FRAME
												LayoutGroup.TextFrame = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.TextFrame", LayoutGroup)
												LayoutGroup.TextFrame:SetFrameStrata(NS.Variables.FRAME_STRATA)
												LayoutGroup.TextFrame:SetFrameLevel(NS.Variables.FRAME_LEVEL + 4)
												addon.C.API.FrameUtil:SetDynamicSize(LayoutGroup.TextFrame, LayoutGroup, 0, nil)
												LayoutGroup:AddElement(LayoutGroup.TextFrame)

												local TextFrame = LayoutGroup.TextFrame

												--------------------------------

												do -- TEXT
													TextFrame.Text = addon.C.FrameTemplates:CreateText(TextFrame, addon.CS:GetSharedColor().RGB_WHITE, 12.5, "CENTER", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Text", "GameFontNormal")
													TextFrame.Text:SetPoint("CENTER", TextFrame)
													TextFrame.Text:SetAutoFit(true)
													TextFrame.Text:SetAutoFit_MaxWidth(10000)
													addon.C.API.FrameUtil:SetDynamicSize(TextFrame, TextFrame.Text, nil, 0)
												end
											end

											do -- SUBTEXT FRAME
												LayoutGroup.SubtextFrame = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.SubtextFrame", LayoutGroup)
												LayoutGroup.SubtextFrame:SetFrameStrata(NS.Variables.FRAME_STRATA)
												LayoutGroup.SubtextFrame:SetFrameLevel(NS.Variables.FRAME_LEVEL + 4)
												addon.C.API.FrameUtil:SetDynamicSize(LayoutGroup.SubtextFrame, LayoutGroup.TextFrame, 0, nil)
												LayoutGroup:AddElement(LayoutGroup.SubtextFrame)

												local SubtextFrame = LayoutGroup.SubtextFrame

												--------------------------------

												do -- TEXT
													SubtextFrame.Text = addon.C.FrameTemplates:CreateText(SubtextFrame, addon.CS:GetSharedColor().RGB_WHITE, 12.5, "CENTER", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Text", "GameFontNormal")
													SubtextFrame.Text:SetPoint("CENTER", SubtextFrame)
													SubtextFrame.Text:SetAutoFit(true)
													SubtextFrame.Text:SetAutoFit_MaxWidth(10000)
													addon.C.API.FrameUtil:SetDynamicSize(SubtextFrame, SubtextFrame.Text, nil, 0)
												end
											end
										end
									end
								end

								do -- MARKER
									Content.Marker = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Marker", Content)
									Content.Marker:SetSize(35, MARKER_HEIGHT)
									Content.Marker:SetPoint("BOTTOM", Content, 0, 25)
									Content.Marker:SetFrameStrata(NS.Variables.FRAME_STRATA)
									Content.Marker:SetFrameLevel(NS.Variables.FRAME_LEVEL + 3)

									local Marker = Content.Marker

									--------------------------------

									do -- CONTENT
										Marker.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Marker)
										Marker.Content:SetPoint("CENTER", Marker)
										Marker.Content:SetFrameStrata(NS.Variables.FRAME_STRATA)
										Marker.Content:SetFrameLevel(NS.Variables.FRAME_LEVEL + 4)
										addon.C.API.FrameUtil:SetDynamicSize(Marker.Content, Marker, 0, 0)

										local Marker_Content = Marker.Content

										--------------------------------

										do -- BACKGROUND
											Marker_Content.Background, Marker_Content.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(Marker_Content, NS.Variables.FRAME_STRATA, NS.Variables.PATH .. "waypoint-line.png", "$parent.Background")
											Marker_Content.Background:SetWidth(125)
											Marker_Content.Background:SetPoint("CENTER", Marker_Content, 0, -MARKER_HEIGHT / 2)
											Marker_Content.Background:SetFrameStrata(NS.Variables.FRAME_STRATA)
											Marker_Content.Background:SetFrameLevel(NS.Variables.FRAME_LEVEL + 4)
											addon.C.API.FrameUtil:SetDynamicSize(Marker_Content.Background, Marker_Content, nil, 0)

											Marker_Content.Background:SetAlpha(.25)
										end

										do -- PULSE
											Marker_Content.Pulse = PrefabRegistry:Create("WaypointSystem.Waypoint.Marker.PulseFrame", Marker_Content, NS.Variables.FRAME_STRATA, NS.Variables.FRAME_LEVEL + 5, "$parent.Pulse")
											Marker_Content.Pulse:SetPoint("BOTTOM", Marker_Content)
											Marker_Content.Pulse:SetFrameStrata(NS.Variables.FRAME_STRATA)
											Marker_Content.Pulse:SetFrameLevel(NS.Variables.FRAME_LEVEL + 5)
											addon.C.API.FrameUtil:SetDynamicSize(Marker_Content.Pulse, Marker_Content, 0, function(relativeWidth, relativeHeight) return relativeHeight / 2 end)

											Marker_Content.Pulse:SetAlpha(.75)
										end
									end
								end
							end
						end
					end

					do -- PINPOINT
						World.Pinpoint = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Pinpoint", World)
						World.Pinpoint:SetFrameStrata(NS.Variables.FRAME_STRATA)
						World.Pinpoint:SetFrameLevel(NS.Variables.FRAME_LEVEL + 1)

						local Pinpoint = World.Pinpoint

						--------------------------------

						do -- CONTENT
							Pinpoint.Alpha_MouseOver = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Alpha_MouseOver", Pinpoint)
							Pinpoint.Alpha_CharacterOverlap = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Alpha_CharacterOverlap", Pinpoint.Alpha_MouseOver)
							Pinpoint.Alpha_ScreenEdge = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Alpha_ScreenEdge", Pinpoint.Alpha_CharacterOverlap)
							Pinpoint.Alpha_MouseOver:SetPoint("CENTER", Pinpoint)
							Pinpoint.Alpha_CharacterOverlap:SetPoint("CENTER", Pinpoint)
							Pinpoint.Alpha_ScreenEdge:SetPoint("CENTER", Pinpoint)
							addon.C.API.FrameUtil:SetDynamicSize(Pinpoint.Alpha_MouseOver, Pinpoint, 0, 0)
							addon.C.API.FrameUtil:SetDynamicSize(Pinpoint.Alpha_CharacterOverlap, Pinpoint, 0, 0)
							addon.C.API.FrameUtil:SetDynamicSize(Pinpoint.Alpha_ScreenEdge, Pinpoint, 0, 0)

							Pinpoint.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Pinpoint.Alpha_ScreenEdge)
							Pinpoint.Content:SetPoint("CENTER", Pinpoint)
							Pinpoint.Content:SetFrameStrata(NS.Variables.FRAME_STRATA)
							Pinpoint.Content:SetFrameLevel(NS.Variables.FRAME_LEVEL_MAX)
							addon.C.API.FrameUtil:SetDynamicSize(Pinpoint.Content, Pinpoint, 0, 0)
							Pinpoint.Content:SetScale(.75)

							local Content = Pinpoint.Content

							--------------------------------

							do -- ELEMENTS
								local PADDING_FRAME = NS.Variables:RATIO(2.5)
								local TEXT_WIDTH_MAX = 300

								--------------------------------

								do -- BACKGROUND
									Content.Background = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Background", Content)
									Content.Background:SetPoint("CENTER", Content)
									Content.Background:SetFrameStrata(NS.Variables.FRAME_STRATA)
									Content.Background:SetFrameLevel(NS.Variables.FRAME_LEVEL)
									addon.C.API.FrameUtil:SetDynamicSize(Content.Background, Content, 0, 0)

									local Background = Content.Background

									--------------------------------

									do -- CONTEXT FRAME
										Background.ContextFrame = PrefabRegistry:Create("WaypointSystem.General.ContextFrame", Background, NS.Variables.FRAME_STRATA, NS.Variables.FRAME_LEVEL, "$parent.ContextFrame")
										Background.ContextFrame:SetSize(75, 75)
										Background.ContextFrame:SetPoint("CENTER", Background)
										Background.ContextFrame:SetFrameStrata(NS.Variables.FRAME_STRATA)
										Background.ContextFrame:SetFrameLevel(NS.Variables.FRAME_LEVEL + 1)
										Background.ContextFrame:SetAlpha(.25)
									end

									do -- ARROW FRAME
										Background.ArrowFrame = PrefabRegistry:Create("WaypointSystem.Pinpoint.ArrowFrame", Background, NS.Variables.FRAME_STRATA, NS.Variables.FRAME_LEVEL + 1, {
											["size"] = 25,
											["offset"] = -7.5,
										}, "$parent.ArrowFrame")
										Background.ArrowFrame:SetSize(75, 75)
										Background.ArrowFrame:SetPoint("TOP", Background, "BOTTOM", 0, -12.5)
										Background.ArrowFrame:SetFrameStrata(NS.Variables.FRAME_STRATA)
										Background.ArrowFrame:SetFrameLevel(NS.Variables.FRAME_LEVEL + 1)
									end
								end

								do -- FOREGROUND
									Content.Foreground = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Foreground", Content)
									Content.Foreground:SetPoint("CENTER", Content)
									Content.Foreground:SetFrameStrata(NS.Variables.FRAME_STRATA)
									Content.Foreground:SetFrameLevel(NS.Variables.FRAME_LEVEL_MAX)
									addon.C.API.FrameUtil:SetDynamicSize(Content.Foreground, Content, 0, 0)

									local Foreground = Content.Foreground

									--------------------------------

									do -- BACKGROUND
										Foreground.Background = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Background", Foreground)
										Foreground.Background:SetPoint("CENTER", Foreground)
										Foreground.Background:SetFrameStrata(NS.Variables.FRAME_STRATA)
										Foreground.Background:SetFrameLevel(NS.Variables.FRAME_LEVEL_MAX + 1)
										addon.C.API.FrameUtil:SetDynamicSize(Foreground.Background, Foreground, -25, -25)

										local Background = Foreground.Background

										--------------------------------

										do -- CENTER
											Background.Center, Background.CenterTexture = addon.C.FrameTemplates:CreateNineSlice(Background, NS.Variables.FRAME_STRATA, NS.Variables.PATH .. "pinpoint-background-center.png", 37, .125, "$parent.Center", Enum.UITextureSliceMode.Stretched)
											Background.Center:SetPoint("CENTER", Background)
											Background.Center:SetFrameStrata(NS.Variables.FRAME_STRATA)
											Background.Center:SetFrameLevel(NS.Variables.FRAME_LEVEL_MAX + 2)
											addon.C.API.FrameUtil:SetDynamicSize(Background.Center, Background, 0, 0)

											Background.CenterTexture:SetVertexColor(0, 0, 0, .375)
										end

										do -- BORDER
											Background.Border, Background.BorderTexture = addon.C.FrameTemplates:CreateNineSlice(Background, NS.Variables.FRAME_STRATA, NS.Variables.PATH .. "pinpoint-background-border.png", 37, .125, "$parent.Border", Enum.UITextureSliceMode.Stretched)
											Background.Border:SetPoint("CENTER", Background)
											Background.Border:SetFrameStrata(NS.Variables.FRAME_STRATA)
											Background.Border:SetFrameLevel(NS.Variables.FRAME_LEVEL_MAX + 3)
											addon.C.API.FrameUtil:SetDynamicSize(Background.Border, Background, 0, 0)
										end
									end

									do -- CONTENT
										Foreground.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Foreground)
										Foreground.Content:SetPoint("CENTER", Foreground)
										Foreground.Content:SetFrameStrata(NS.Variables.FRAME_STRATA)
										Foreground.Content:SetFrameLevel(NS.Variables.FRAME_LEVEL_MAX + 5)
										addon.C.API.FrameUtil:SetDynamicSize(Foreground.Content, Foreground, 0, 0)

										local Content = Foreground.Content

										--------------------------------

										do -- TEXT FRAME
											Content.TextFrame = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.TextFrame", Content)
											Content.TextFrame:SetPoint("CENTER", Content)
											Content.TextFrame:SetFrameStrata(NS.Variables.FRAME_STRATA)
											Content.TextFrame:SetFrameLevel(NS.Variables.FRAME_LEVEL_MAX + 6)
											addon.C.API.FrameUtil:SetDynamicSize(Content.TextFrame, Content, 0, 0)

											local TextFrame = Content.TextFrame

											--------------------------------

											do -- TEXT
												TextFrame.Text = addon.C.FrameTemplates:CreateText(TextFrame, addon.CS:GetSharedColor().RGB_WHITE, 14, "CENTER", "MIDDLE", addon.C.Fonts.CONTENT_DEFAULT, "$parent.Text", "GameFontNormal")
												TextFrame.Text:SetPoint("CENTER", TextFrame)
												TextFrame.Text:SetAutoFit(true)
												TextFrame.Text:SetAutoFit_MaxWidth(TEXT_WIDTH_MAX)
												addon.C.API.FrameUtil:SetDynamicSize(Pinpoint, TextFrame.Text, 0, 0)
											end
										end
									end
								end
							end
						end
					end
				end

				do -- NAVIGATOR
					Frame.Navigator = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Navigator", Frame)
					Frame.Navigator:SetAllPoints(Frame)

					local Navigator = Frame.Navigator

					--------------------------------

					do -- ARROW
						Navigator.Arrow = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Arrow", Navigator)
						Navigator.Arrow:SetSize(37.5, 37.5)
						Navigator.Arrow:SetFrameStrata(NS.Variables.FRAME_STRATA)
						Navigator.Arrow:SetFrameLevel(NS.Variables.FRAME_LEVEL + 1)

						local Arrow = Navigator.Arrow

						--------------------------------

						do -- CONTENT
							Arrow.Alpha_MouseOver = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Alpha_MouseOver", Arrow)
							Arrow.Alpha_MouseOver:SetPoint("CENTER", Arrow)
							addon.C.API.FrameUtil:SetDynamicSize(Arrow.Alpha_MouseOver, Arrow, 0, 0)

							Arrow.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Arrow.Alpha_MouseOver)
							Arrow.Content:SetPoint("CENTER", Arrow)
							Arrow.Content:SetFrameStrata(NS.Variables.FRAME_STRATA)
							Arrow.Content:SetFrameLevel(NS.Variables.FRAME_LEVEL + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Arrow.Content, Arrow, 0, 0)

							local Content = Arrow.Content

							--------------------------------

							do -- CONTEXT FRAME
								Content.ContextFrame = PrefabRegistry:Create("WaypointSystem.General.ContextFrame", Content, NS.Variables.FRAME_STRATA, NS.Variables.FRAME_LEVEL + 3, "$parent.ContextFrame")
								Content.ContextFrame:SetPoint("CENTER", Content)
								Content.ContextFrame:SetFrameStrata(NS.Variables.FRAME_STRATA)
								Content.ContextFrame:SetFrameLevel(NS.Variables.FRAME_LEVEL + 3)
								addon.C.API.FrameUtil:SetDynamicSize(Content.ContextFrame, Content, 0, 0)
							end

							do -- INDICATOR
								Content.Indicator = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Indicator", Content)
								Content.Indicator:SetSize(75, 75)
								Content.Indicator:SetPoint("CENTER", Content)
								Content.Indicator:SetFrameStrata(NS.Variables.FRAME_STRATA)
								Content.Indicator:SetFrameLevel(NS.Variables.FRAME_LEVEL + 3)

								local Indicator = Content.Indicator

								--------------------------------

								do -- BACKGROUND
									Indicator.Background, Indicator.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(Indicator, NS.Variables.FRAME_STRATA, NS.Variables.PATH .. "navigator-indicator-background.png", "$parent.Background")
									Indicator.Background:SetPoint("CENTER", Indicator)
									Indicator.Background:SetFrameStrata(NS.Variables.FRAME_STRATA)
									Indicator.Background:SetFrameLevel(NS.Variables.FRAME_LEVEL + 3)
									addon.C.API.FrameUtil:SetDynamicSize(Indicator.Background, Indicator, 0, 0)

									Indicator.Background:SetAlpha(.5)
								end
							end
						end
					end
				end
			end
		end

		do -- REFERENCES
			local Frame = WaypointFrame.Waypoint

			--------------------------------

			-- CORE
			Frame.REF_WORLD = Frame.World
			Frame.REF_WORLD_WAYPOINT = Frame.REF_WORLD.Waypoint
			Frame.REF_WORLD_PINPOINT = Frame.REF_WORLD.Pinpoint

			Frame.REF_NAVIGATOR = Frame.Navigator
			Frame.REF_NAVIGATOR_ARROW = Frame.REF_NAVIGATOR.Arrow

			-- WAYPOINT
			Frame.REF_WORLD_WAYPOINT_ALPHA_MOUSE_OVER = Frame.REF_WORLD_WAYPOINT.Alpha_MouseOver
			Frame.REF_WORLD_WAYPOINT_ALPHA_CHARACTER_OVERLAP = Frame.REF_WORLD_WAYPOINT.Alpha_CharacterOverlap
			Frame.REF_WORLD_WAYPOINT_ALPHA_SCREEN_EDGE = Frame.REF_WORLD_WAYPOINT.Alpha_ScreenEdge

			Frame.REF_WORLD_WAYPOINT_CONTENT = Frame.REF_WORLD_WAYPOINT.Content
			Frame.REF_WORLD_WAYPOINT_CONTEXT = Frame.REF_WORLD_WAYPOINT_CONTENT.ContextFrame
			Frame.REF_WORLD_WAYPOINT_CONTEXT_VFX = Frame.REF_WORLD_WAYPOINT_CONTEXT.VFX
			Frame.REF_WORLD_WAYPOINT_CONTEXT_VFX_WAVE = Frame.REF_WORLD_WAYPOINT_CONTEXT_VFX.Wave
			Frame.REF_WORLD_WAYPOINT_CONTEXT_VFX_WAVE_BACKGROUND = Frame.REF_WORLD_WAYPOINT_CONTEXT_VFX_WAVE.Background
			Frame.REF_WORLD_WAYPOINT_CONTEXT_VFX_WAVE_BACKGROUND_TEXTURE = Frame.REF_WORLD_WAYPOINT_CONTEXT_VFX_WAVE.BackgroundTexture

			Frame.REF_WORLD_WAYPOINT_FOOTER = Frame.REF_WORLD_WAYPOINT_CONTENT.Footer
			Frame.REF_WORLD_WAYPOINT_FOOTER_LAYOUT = Frame.REF_WORLD_WAYPOINT_FOOTER.LayoutGroup
			Frame.REF_WORLD_WAYPOINT_FOOTER_LAYOUT_TEXT_FRAME = Frame.REF_WORLD_WAYPOINT_FOOTER_LAYOUT.TextFrame
			Frame.REF_WORLD_WAYPOINT_FOOTER_LAYOUT_TEXT = Frame.REF_WORLD_WAYPOINT_FOOTER_LAYOUT_TEXT_FRAME.Text
			Frame.REF_WORLD_WAYPOINT_FOOTER_LAYOUT_SUBTEXT_FRAME = Frame.REF_WORLD_WAYPOINT_FOOTER_LAYOUT.SubtextFrame
			Frame.REF_WORLD_WAYPOINT_FOOTER_LAYOUT_SUBTEXT = Frame.REF_WORLD_WAYPOINT_FOOTER_LAYOUT_SUBTEXT_FRAME.Text
			Frame.REF_WORLD_WAYPOINT_MARKER = Frame.REF_WORLD_WAYPOINT_CONTENT.Marker
			Frame.REF_WORLD_WAYPOINT_MARKER_CONTENT = Frame.REF_WORLD_WAYPOINT_MARKER.Content
			Frame.REF_WORLD_WAYPOINT_MARKER_BACKGROUND = Frame.REF_WORLD_WAYPOINT_MARKER_CONTENT.Background
			Frame.REF_WORLD_WAYPOINT_MARKER_BACKGROUND_TEXTURE = Frame.REF_WORLD_WAYPOINT_MARKER_CONTENT.BackgroundTexture
			Frame.REF_WORLD_WAYPOINT_MARKER_PULSE = Frame.REF_WORLD_WAYPOINT_MARKER_CONTENT.Pulse

			-- PINPOINT
			Frame.REF_WORLD_PINPOINT_ALPHA_MOUSE_OVER = Frame.REF_WORLD_PINPOINT.Alpha_MouseOver
			Frame.REF_WORLD_PINPOINT_ALPHA_CHARACTER_OVERLAP = Frame.REF_WORLD_PINPOINT.Alpha_CharacterOverlap
			Frame.REF_WORLD_PINPOINT_ALPHA_SCREEN_EDGE = Frame.REF_WORLD_PINPOINT.Alpha_ScreenEdge

			Frame.REF_WORLD_PINPOINT_CONTENT = Frame.REF_WORLD_PINPOINT.Content
			Frame.REF_WORLD_PINPOINT_BACKGROUND = Frame.REF_WORLD_PINPOINT_CONTENT.Background
			Frame.REF_WORLD_PINPOINT_BACKGROUND_CONTEXT = Frame.REF_WORLD_PINPOINT_BACKGROUND.ContextFrame
			Frame.REF_WORLD_PINPOINT_BACKGROUND_ARROW = Frame.REF_WORLD_PINPOINT_BACKGROUND.ArrowFrame
			Frame.REF_WORLD_PINPOINT_FOREGROUND = Frame.REF_WORLD_PINPOINT_CONTENT.Foreground
			Frame.REF_WORLD_PINPOINT_FOREGROUND_BACKGROUND = Frame.REF_WORLD_PINPOINT_FOREGROUND.Background
			Frame.REF_WORLD_PINPOINT_FOREGROUND_BACKGROUND_CENTER = Frame.REF_WORLD_PINPOINT_FOREGROUND_BACKGROUND.Center
			Frame.REF_WORLD_PINPOINT_FOREGROUND_BACKGROUND_CENTER_TEXTURE = Frame.REF_WORLD_PINPOINT_FOREGROUND_BACKGROUND.CenterTexture
			Frame.REF_WORLD_PINPOINT_FOREGROUND_BACKGROUND_BORDER = Frame.REF_WORLD_PINPOINT_FOREGROUND_BACKGROUND.Border
			Frame.REF_WORLD_PINPOINT_FOREGROUND_BACKGROUND_BORDER_TEXTURE = Frame.REF_WORLD_PINPOINT_FOREGROUND_BACKGROUND.BorderTexture
			Frame.REF_WORLD_PINPOINT_FOREGROUND_TEXT = Frame.REF_WORLD_PINPOINT_FOREGROUND.Content.TextFrame.Text

			-- NAVIGATOR
			Frame.REF_NAVIGATOR_ARROW_ALPHA_MOUSE_OVER = Frame.REF_NAVIGATOR_ARROW.Alpha_MouseOver

			Frame.REF_NAVIGATOR_ARROW_CONTENT = Frame.REF_NAVIGATOR_ARROW.Content
			Frame.REF_NAVIGATOR_ARROW_CONTEXT = Frame.REF_NAVIGATOR_ARROW_CONTENT.ContextFrame
			Frame.REF_NAVIGATOR_ARROW_INDICATOR = Frame.REF_NAVIGATOR_ARROW_CONTENT.Indicator
			Frame.REF_NAVIGATOR_ARROW_INDICATOR_BACKGROUND = Frame.REF_NAVIGATOR_ARROW_INDICATOR.Background
			Frame.REF_NAVIGATOR_ARROW_INDICATOR_BACKGROUND_TEXTURE = Frame.REF_NAVIGATOR_ARROW_INDICATOR.BackgroundTexture
		end
	end

	--------------------------------
	-- REFERENCES
	--------------------------------

	local Frame = WaypointFrame.Waypoint
	local Frame_World = Frame.REF_WORLD
	local Frame_World_Waypoint = Frame.REF_WORLD_WAYPOINT
	local Frame_World_Pinpoint = Frame.REF_WORLD_PINPOINT
	local Frame_Navigator = Frame.REF_NAVIGATOR
	local Frame_Navigator_Arrow = Frame.REF_NAVIGATOR_ARROW
	local Frame_BlizzardWaypoint = SuperTrackedFrame
	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- SETUP
	--------------------------------

	do
		Frame_World_Waypoint.hidden = true
		Frame_World_Waypoint:Hide()
		Frame.REF_WORLD_WAYPOINT_CONTEXT_VFX_WAVE:Hide()
		Frame.REF_WORLD_WAYPOINT_FOOTER_LAYOUT_SUBTEXT_FRAME.hidden = true
		Frame.REF_WORLD_WAYPOINT_FOOTER_LAYOUT_SUBTEXT_FRAME:Hide()

		Frame_World_Pinpoint.hidden = true
		Frame_World_Pinpoint:Hide()
		Frame.REF_WORLD_PINPOINT_FOREGROUND_TEXT:SetText("Placeholder") -- pre calculate sizing

		--------------------------------

		Frame_World.hidden = true
		Frame_World:Hide()

		Frame_Navigator.hidden = true
		Frame_Navigator:Hide()
	end
end
