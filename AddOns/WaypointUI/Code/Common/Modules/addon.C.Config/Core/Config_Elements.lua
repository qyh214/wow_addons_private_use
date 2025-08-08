---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Config; addon.C.Config = NS

--------------------------------

NS.Elements = {}

--------------------------------

function NS.Elements:Load()
	--------------------------------
	-- CREATE ELEMENTS
	--------------------------------

	do
		do -- ELEMENTS
			local Frame = addon.C.FrameTemplates:CreateFrame("Frame")
			Frame:SetFrameStrata(NS.Variables.FRAME_STRATA)
			Frame:SetFrameLevel(NS.Variables.FRAME_LEVEL)

			NS.Variables.Frame = Frame

			--------------------------------

			do -- CONTENT
				Frame.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Frame)
				Frame.Content:SetPoint("CENTER", Frame)
				Frame.Content:SetFrameStrata(NS.Variables.FRAME_STRATA)
				Frame.Content:SetFrameLevel(NS.Variables.FRAME_LEVEL + 1)

				local Content = Frame.Content

				--------------------------------

				do -- ELEMENTS
					local PADDING = NS.Variables.PADDING
					local PADDING_CONTENT = NS.Variables:RATIO(8)
					local SIDEBAR_WIDTH = 200

					--------------------------------

					do -- SIDEBAR
						Content.Sidebar = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Sidebar", Content)
						Content.Sidebar:SetWidth(SIDEBAR_WIDTH)
						Content.Sidebar:SetPoint("LEFT", Content)
						Content.Sidebar:SetFrameStrata(NS.Variables.FRAME_STRATA)
						Content.Sidebar:SetFrameLevel(NS.Variables.FRAME_LEVEL + 2)
						addon.C.API.FrameUtil:SetDynamicSize(Content.Sidebar, Content, nil, 0, true)

						local Sidebar = Content.Sidebar

						--------------------------------

						do -- LAYOUT GROUP
							Sidebar.LayoutGroup, Sidebar.LayoutGroup_Sort = addon.C.FrameTemplates:CreateLayoutGroup(Sidebar, { point = "TOP", direction = "vertical", resize = false, padding = 0, distribute = false, distributeResizeElements = false, excludeHidden = true, autoSort = true, customOffset = nil, customLayoutSort = nil }, "LayoutGroup")
							Sidebar.LayoutGroup:SetPoint("CENTER", Sidebar)
							Sidebar.LayoutGroup:SetFrameStrata(NS.Variables.FRAME_STRATA)
							Sidebar.LayoutGroup:SetFrameLevel(NS.Variables.FRAME_LEVEL + 3)
							addon.C.API.FrameUtil:SetDynamicSize(Sidebar.LayoutGroup, Sidebar, PADDING_CONTENT, PADDING_CONTENT)
							Frame.LGS_SIDEBAR = Sidebar.LayoutGroup_Sort

							local Sidebar_LayoutGroup = Sidebar.LayoutGroup

							--------------------------------

							do -- ELEMENTS
								local HEADER_HEIGHT = 75
								local FOOTER_HEIGHT = 35

								--------------------------------

								do -- HEADER
									Sidebar_LayoutGroup.Header = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Header", Sidebar_LayoutGroup)
									Sidebar_LayoutGroup.Header:SetHeight(HEADER_HEIGHT)
									Sidebar_LayoutGroup.Header:SetFrameStrata(NS.Variables.FRAME_STRATA)
									Sidebar_LayoutGroup.Header:SetFrameLevel(NS.Variables.FRAME_LEVEL + 4)
									addon.C.API.FrameUtil:SetDynamicSize(Sidebar_LayoutGroup.Header, Sidebar_LayoutGroup, 0, nil)
									Sidebar_LayoutGroup:AddElement(Sidebar_LayoutGroup.Header)

									local Header = Sidebar_LayoutGroup.Header

									--------------------------------

									do -- LOGO
										Header.Logo = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Logo", Header)
										Header.Logo:SetPoint("CENTER", Header, 0, -25)
										Header.Logo:SetSize(112.5, 112.5)
										Header.Logo:SetFrameStrata(NS.Variables.FRAME_STRATA)
										Header.Logo:SetFrameLevel(NS.Variables.FRAME_LEVEL + 4)
										Header.Logo:SetAlpha(.25)

										local Logo = Header.Logo

										--------------------------------

										do -- BACKGROUND
											Logo.Background, Logo.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(Logo, NS.Variables.FRAME_STRATA, nil, "$parent.Background")
											Logo.Background:SetPoint("CENTER", Logo)
											Logo.Background:SetFrameStrata(NS.Variables.FRAME_STRATA)
											Logo.Background:SetFrameLevel(NS.Variables.FRAME_LEVEL + 5)
											addon.C.API.FrameUtil:SetDynamicSize(Logo.Background, Logo, 0, 0)

											Logo.BackgroundTexture:SetGradient("VERTICAL", { r = 1, g = 1, b = 1, a = 0 }, { r = 1, g = 1, b = 1, a = 1 })
										end
									end
								end

								do -- MAIN
									Sidebar_LayoutGroup.Main = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Main", Sidebar_LayoutGroup)
									Sidebar_LayoutGroup.Main:SetFrameStrata(NS.Variables.FRAME_STRATA)
									Sidebar_LayoutGroup.Main:SetFrameLevel(NS.Variables.FRAME_LEVEL + 4)
									addon.C.API.FrameUtil:SetDynamicSize(Sidebar_LayoutGroup.Main, Sidebar_LayoutGroup, 0, function(relativeWidth, relativeHeight) return relativeHeight - HEADER_HEIGHT - FOOTER_HEIGHT end)
									Sidebar_LayoutGroup:AddElement(Sidebar_LayoutGroup.Main)

									local Main = Sidebar_LayoutGroup.Main

									--------------------------------

									do -- ELEMENTS
										local PADDING_ELEMENT = NS.Variables:RATIO(10)

										--------------------------------

										do -- LAYOUT GROUP
											Main.LayoutGroup, Main.LayoutGroup_Sort = addon.C.FrameTemplates:CreateLayoutGroup(Main, { point = "TOP", direction = "vertical", resize = false, padding = PADDING_ELEMENT, distribute = false, distributeResizeElements = false, excludeHidden = true, autoSort = true, customOffset = nil, customLayoutSort = nil }, "$parent.LayoutGroup")
											Main.LayoutGroup:SetPoint("CENTER", Main)
											Main.LayoutGroup:SetFrameStrata(NS.Variables.FRAME_STRATA)
											Main.LayoutGroup:SetFrameLevel(NS.Variables.FRAME_LEVEL + 5)
											addon.C.API.FrameUtil:SetDynamicSize(Main.LayoutGroup, Main, 0, 0)
											Frame.LGS_SIDEBAR_MAIN = Main.LayoutGroup_Sort
										end
									end
								end

								do -- FOOTER
									Sidebar_LayoutGroup.Footer = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Footer", Sidebar_LayoutGroup)
									Sidebar_LayoutGroup.Footer:SetHeight(FOOTER_HEIGHT)
									Sidebar_LayoutGroup.Footer:SetFrameStrata(NS.Variables.FRAME_STRATA)
									Sidebar_LayoutGroup.Footer:SetFrameLevel(NS.Variables.FRAME_LEVEL + 4)
									addon.C.API.FrameUtil:SetDynamicSize(Sidebar_LayoutGroup.Footer, Sidebar_LayoutGroup, 0, nil)
									Sidebar_LayoutGroup:AddElement(Sidebar_LayoutGroup.Footer)

									local Footer = Sidebar_LayoutGroup.Footer

									--------------------------------

									do -- LAYOUT GROUP
										Footer.LayoutGroup, Footer.LayoutGroup_Sort = addon.C.FrameTemplates:CreateLayoutGroup(Footer, { point = "TOP", direction = "vertical", resize = false, padding = PADDING, distribute = false, distributeResizeElements = false, excludeHidden = true, autoSort = true, customOffset = nil, customLayoutSort = nil }, "$parent.LayoutGroup")
										Footer.LayoutGroup:SetPoint("CENTER", Footer)
										Footer.LayoutGroup:SetFrameStrata(NS.Variables.FRAME_STRATA)
										Footer.LayoutGroup:SetFrameLevel(NS.Variables.FRAME_LEVEL + 5)
										addon.C.API.FrameUtil:SetDynamicSize(Footer.LayoutGroup, Footer, 0, 0)
										Frame.LGS_SIDEBAR_FOOTER = Footer.LayoutGroup_Sort
									end
								end
							end

							do -- DIVIDER
								Sidebar.Divider = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Divider", Sidebar)
								Sidebar.Divider:SetWidth(2)
								Sidebar.Divider:SetPoint("CENTER", Sidebar, "RIGHT", 0, 0)
								Sidebar.Divider:SetFrameStrata(NS.Variables.FRAME_STRATA)
								Sidebar.Divider:SetFrameLevel(NS.Variables.FRAME_LEVEL + 3)
								addon.C.API.FrameUtil:SetDynamicSize(Sidebar.Divider, Sidebar, nil, 0)

								local Divider = Sidebar.Divider

								--------------------------------

								do -- BACKGROUND
									Divider.Background, Divider.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(Divider, NS.Variables.FRAME_STRATA, addon.CS:GetCommonPathArt() .. "Basic/square.png", "$parent.Background")
									Divider.Background:SetPoint("CENTER", Divider)
									Divider.Background:SetFrameStrata(NS.Variables.FRAME_STRATA)
									Divider.Background:SetFrameLevel(NS.Variables.FRAME_LEVEL + 4)
									addon.C.API.FrameUtil:SetDynamicSize(Divider.Background, Divider, 0, 0)

									Divider.BackgroundTexture:SetVertexColor(.5, .5, .5, .25)
								end
							end
						end

						do -- MAIN
							Content.Main = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Main", Content)
							Content.Main:SetPoint("RIGHT", Content)
							Content.Main:SetFrameStrata(NS.Variables.FRAME_STRATA)
							Content.Main:SetFrameLevel(NS.Variables.FRAME_LEVEL + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Main, Content, function(relativeWidth, relativeHeight) return relativeWidth - SIDEBAR_WIDTH end, 0)

							local Main = Content.Main

							--------------------------------

							do -- CONTENT
								Main.Content = addon.C.FrameTemplates:CreateFrame("Frame", "$parent.Content", Main)
								Main.Content:SetPoint("CENTER", Main)
								Main.Content:SetFrameStrata(NS.Variables.FRAME_STRATA)
								Main.Content:SetFrameLevel(NS.Variables.FRAME_LEVEL + 3)
								addon.C.API.FrameUtil:SetDynamicSize(Main.Content, Main, PADDING_CONTENT, PADDING_CONTENT)
							end
						end
					end
				end
			end
		end

		do -- REFERENCES
			local Frame = NS.Variables.Frame

			-- CORE
			Frame.REF_CONTENT = Frame.Content
			Frame.REF_SIDEBAR = Frame.Content.Sidebar
			Frame.REF_MAIN = Frame.Content.Main

			-- SIDEBAR
			Frame.REF_SIDEBAR_CONTENT = Frame.REF_SIDEBAR.LayoutGroup

			Frame.REF_SIDEBAR_HEADER = Frame.REF_SIDEBAR_CONTENT.Header
			Frame.REF_SIDEBAR_HEADER_LOGO = Frame.REF_SIDEBAR_HEADER.Logo
			Frame.REF_SIDEBAR_HEADER_LOGO_BACKGROUND = Frame.REF_SIDEBAR_HEADER_LOGO.Background
			Frame.REF_SIDEBAR_HEADER_LOGO_BACKGROUND_TEXTURE = Frame.REF_SIDEBAR_HEADER_LOGO.BackgroundTexture

			Frame.REF_SIDEBAR_MAIN = Frame.REF_SIDEBAR_CONTENT.Main
			Frame.REF_SIDEBAR_MAIN_CONTENT = Frame.REF_SIDEBAR_MAIN.LayoutGroup

			Frame.REF_SIDEBAR_FOOTER = Frame.REF_SIDEBAR_CONTENT.Footer
			Frame.REF_SIDEBAR_FOOTER_CONTENT = Frame.REF_SIDEBAR_FOOTER.LayoutGroup

			Frame.REF_SIDEBAR_DIVIDER = Frame.REF_SIDEBAR.Divider
			Frame.REF_SIDEBAR_DIVIDER_BACKGROUND = Frame.REF_SIDEBAR_DIVIDER.Background
			Frame.REF_SIDEBAR_DIVIDER_BACKGROUND_TEXTURE = Frame.REF_SIDEBAR_DIVIDER.BackgroundTexture

			-- MAIN
			Frame.REF_MAIN_CONTENT = Frame.REF_MAIN.Content
		end
	end

	--------------------------------
	-- REFERENCES
	--------------------------------

	local Frame = NS.Variables.Frame
	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- SETUP
	--------------------------------

	do

	end
end
