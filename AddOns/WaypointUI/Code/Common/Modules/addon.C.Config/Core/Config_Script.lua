---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Config; addon.C.Config = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Frame = NS.Variables.Frame
	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (FRAME)
	--------------------------------

	do
		function Frame:UpdateLayout()
			Frame.LGS_SIDEBAR()
			Frame.LGS_SIDEBAR_MAIN()
			Frame.LGS_SIDEBAR_FOOTER()
		end

		function Frame:SetAddonIcon()
			Frame.REF_SIDEBAR_HEADER_LOGO_BACKGROUND_TEXTURE:SetTexture(addon.C.AddonInfo.Variables.General.ADDON_ICON)
		end
	end

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do
		do -- CONSTRUCTOR
			Callback.Constructor = {}
			Callback.Constructor.FRAME_NAVIGATION = Frame.REF_SIDEBAR_MAIN_CONTENT
			Callback.Constructor.FRAME_NAVIGATION_FRAME_STRATA = Frame.REF_SIDEBAR_MAIN_CONTENT:GetFrameStrata()
			Callback.Constructor.FRAME_NAVIGATION_FRAME_LEVEL = Frame.REF_SIDEBAR_MAIN_CONTENT:GetFrameLevel()
			Callback.Constructor.FRAME_NAVIGATION_FOOTER = Frame.REF_SIDEBAR_FOOTER_CONTENT
			Callback.Constructor.FRAME_NAVIGATION_FOOTER_FRAME_STRATA = Frame.REF_SIDEBAR_FOOTER_CONTENT:GetFrameStrata()
			Callback.Constructor.FRAME_NAVIGATION_FOOTER_FRAME_LEVEL = Frame.REF_SIDEBAR_FOOTER_CONTENT:GetFrameLevel()
			Callback.Constructor.FRAME_CONTENT = Frame.REF_MAIN_CONTENT
			Callback.Constructor.FRAME_CONTENT_FRAME_STRATA = Frame.REF_MAIN_CONTENT:GetFrameStrata()
			Callback.Constructor.FRAME_CONTENT_FRAME_LEVEL = Frame.REF_MAIN_CONTENT:GetFrameLevel()

			--------------------------------

			do -- CREATE
				function Callback.Constructor:Create_Responder(parent)
					local Frame = addon.C.FrameTemplates:CreateFrame("Frame", nil, parent:GetParent())

					--------------------------------

					do -- LOGIC
						Frame.onConfigUpdateCallbacks = {}

						--------------------------------

						do -- EVENTS
							local function Event_ConfigUpdate()
								do -- ON CONFIG UPDATE
									local onConfigUpdateCallbacks = Frame.onConfigUpdateCallbacks

									if #onConfigUpdateCallbacks >= 1 then
										for callback = 1, #onConfigUpdateCallbacks do
											onConfigUpdateCallbacks[callback](Frame)
										end
									end
								end
							end

							CallbackRegistry:Add("C_CONFIG_UPDATE", Event_ConfigUpdate)
						end
					end

					--------------------------------

					return Frame
				end

				function Callback.Constructor:Create_Tab(name)
					local Frame = PrefabRegistry:Create("C.Config.Main.Tab", Callback.Constructor.FRAME_CONTENT, Callback.Constructor.FRAME_CONTENT_FRAME_STRATA, Callback.Constructor.FRAME_CONTENT_FRAME_LEVEL, name)
					Frame:SetPoint("CENTER", Callback.Constructor.FRAME_CONTENT)
					addon.C.API.FrameUtil:SetDynamicSize(Frame, Callback.Constructor.FRAME_CONTENT, 0, 0)

					--------------------------------

					table.insert(NS.Variables.Tabs, Frame)

					--------------------------------

					return Frame
				end

				function Callback.Constructor:Create_TabButton(footerTab, text, name)
					if footerTab then
						local Frame = PrefabRegistry:Create("C.Config.Sidebar.Navigation.Button", Callback.Constructor.FRAME_NAVIGATION_FOOTER, Callback.Constructor.FRAME_NAVIGATION_FOOTER_FRAME_STRATA, Callback.Constructor.FRAME_NAVIGATION_FOOTER_FRAME_LEVEL, name)
						Frame:SetHeight(NS.Variables.NAVIGATION_BUTTON_HEIGHT)
						addon.C.API.FrameUtil:SetDynamicSize(Frame, Callback.Constructor.FRAME_NAVIGATION_FOOTER, 0, nil)
						Frame:SetText(text)

						--------------------------------

						Callback.Constructor.FRAME_NAVIGATION_FOOTER:AddElement(Frame)
						table.insert(NS.Variables.TabButtons, Frame)

						--------------------------------

						return Frame
					else
						local Frame = PrefabRegistry:Create("C.Config.Sidebar.Navigation.Button", Callback.Constructor.FRAME_NAVIGATION, Callback.Constructor.FRAME_NAVIGATION_FRAME_STRATA, Callback.Constructor.FRAME_NAVIGATION_FRAME_LEVEL, name)
						Frame:SetHeight(NS.Variables.NAVIGATION_BUTTON_HEIGHT)
						addon.C.API.FrameUtil:SetDynamicSize(Frame, Callback.Constructor.FRAME_NAVIGATION, 0, nil)
						Frame:SetText(text)

						--------------------------------

						Callback.Constructor.FRAME_NAVIGATION:AddElement(Frame)
						table.insert(NS.Variables.TabButtons, Frame)

						--------------------------------

						return Frame
					end
				end

				function Callback.Constructor:Create_Setting_Title(parent, name)
					local FRAME_STRATA, FRAME_LEVEL = parent:GetFrameStrata(), parent:GetFrameLevel()

					--------------------------------

					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Title", parent, FRAME_STRATA, FRAME_LEVEL + 1, name)
					Frame:SetHeight(175)
					addon.C.API.FrameUtil:SetDynamicSize(Frame, parent, 0, nil)

					--------------------------------

					parent:AddElement(Frame)

					--------------------------------

					return Frame
				end

				function Callback.Constructor:Create_Setting_Container(parent, title, transparent, subcontainer, name)
					local FRAME_STRATA, FRAME_LEVEL = parent:GetFrameStrata(), parent:GetFrameLevel()

					--------------------------------

					local Frame = nil

					if title then
						Frame = PrefabRegistry:Create("C.Config.Main.Setting.Container.Title", parent, FRAME_STRATA, FRAME_LEVEL + 1, { transparent = transparent, subcontainer = subcontainer }, name)
						Frame:SetTitle(title)
					else
						Frame = PrefabRegistry:Create("C.Config.Main.Setting.Container", parent, FRAME_STRATA, FRAME_LEVEL + 1, { transparent = transparent, subcontainer = subcontainer }, name)
					end

					addon.C.API.FrameUtil:SetDynamicSize(Frame, parent, 0, nil)

					--------------------------------

					parent:AddElement(Frame)

					--------------------------------

					return Frame
				end

				function Callback.Constructor:Create_Setting_Element_Checkbox(parent, data, name)
					local FRAME_STRATA, FRAME_LEVEL = parent:GetFrameStrata(), parent:GetFrameLevel()

					--------------------------------

					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.Checkbox", parent, FRAME_STRATA, FRAME_LEVEL + 1, data, name)
					addon.C.API.FrameUtil:SetDynamicSize(Frame, parent, 0, nil)

					--------------------------------

					parent:AddElement(Frame)

					--------------------------------

					return Frame
				end

				function Callback.Constructor:Create_Setting_Element_Range(parent, data, name)
					local FRAME_STRATA, FRAME_LEVEL = parent:GetFrameStrata(), parent:GetFrameLevel()

					--------------------------------

					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.Range", parent, FRAME_STRATA, FRAME_LEVEL + 1, data, name)
					addon.C.API.FrameUtil:SetDynamicSize(Frame, parent, 0, nil)

					--------------------------------

					parent:AddElement(Frame)

					--------------------------------

					return Frame
				end

				function Callback.Constructor:Create_Setting_Element_Button(parent, data, name)
					local FRAME_STRATA, FRAME_LEVEL = parent:GetFrameStrata(), parent:GetFrameLevel()

					--------------------------------

					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.Button", parent, FRAME_STRATA, FRAME_LEVEL + 1, data, name)
					addon.C.API.FrameUtil:SetDynamicSize(Frame, parent, 0, nil)

					--------------------------------

					parent:AddElement(Frame)

					--------------------------------

					return Frame
				end

				function Callback.Constructor:Create_Setting_Element_Dropdown(parent, data, name)
					local FRAME_STRATA, FRAME_LEVEL = parent:GetFrameStrata(), parent:GetFrameLevel()

					--------------------------------

					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.Dropdown", parent, FRAME_STRATA, FRAME_LEVEL + 1, data, name)
					addon.C.API.FrameUtil:SetDynamicSize(Frame, parent, 0, nil)

					--------------------------------

					parent:AddElement(Frame)

					--------------------------------

					return Frame
				end

				function Callback.Constructor:Create_Setting_Element_Text(parent, data, name)
					local FRAME_STRATA, FRAME_LEVEL = parent:GetFrameStrata(), parent:GetFrameLevel()

					--------------------------------

					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.Text", parent, FRAME_STRATA, FRAME_LEVEL + 1, data, name)
					addon.C.API.FrameUtil:SetDynamicSize(Frame, parent, 0, nil)

					--------------------------------

					parent:AddElement(Frame)

					--------------------------------

					return Frame
				end

				function Callback.Constructor:Create_Setting_Element_Color(parent, data, name)
					local FRAME_STRATA, FRAME_LEVEL = parent:GetFrameStrata(), parent:GetFrameLevel()

					--------------------------------

					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.Color", parent, FRAME_STRATA, FRAME_LEVEL + 1, data, name)
					addon.C.API.FrameUtil:SetDynamicSize(Frame, parent, 0, nil)

					--------------------------------

					parent:AddElement(Frame)

					--------------------------------

					return Frame
				end

				function Callback.Constructor:Create_Setting_Element_TextBox(parent, data, name)
					local FRAME_STRATA, FRAME_LEVEL = parent:GetFrameStrata(), parent:GetFrameLevel()

					--------------------------------

					local Frame = PrefabRegistry:Create("C.Config.Main.Setting.Element.TextBox", parent, FRAME_STRATA, FRAME_LEVEL + 1, data, name)
					addon.C.API.FrameUtil:SetDynamicSize(Frame, parent, 0, nil)

					--------------------------------

					parent:AddElement(Frame)

					--------------------------------

					return Frame
				end
			end

			do -- FUNCTIONS (MAIN)
				function Callback.Constructor:StartConstruction(data)
					addon.C.AddonInfo.Variables.Config.PRELOAD()

					--------------------------------

					Callback.Constructor:ScanConstruct_Tabs(data)

					--------------------------------

					C_Timer.After(1, function()
						NS.Variables.ConfigReady = true

						--------------------------------

						CallbackRegistry:Trigger("C_CONFIG_UPDATE")
					end)
				end

				function Callback.Constructor:ScanConstruct_Tabs(data)
					for k, v in ipairs(data) do
						local name, type, elements = v.name, v.type, v.elements

						--------------------------------

						local newTab = nil
						local newTabButton = nil

						if type == addon.C.AddonInfo.Variables.Config.TYPE_TAB then
							local var_tab_footer = v.var_tab_footer

							--------------------------------

							newTab = Callback.Constructor:Create_Tab(name)
							newTabButton = Callback.Constructor:Create_TabButton(var_tab_footer, name, name)
							newTabButton:SetClick(function()
								Callback.Navigation:OpenTabByIndex(k)
							end)
						end

						--------------------------------

						if elements then
							Callback.Constructor:ScanConstruct_Elements(newTab.REF_CONTENT_SCROLL_CONTENT_LAYOUT, nil, elements)
						end
					end
				end

				function Callback.Constructor:ScanConstruct_Elements(parent, container, data)
					for k, v in ipairs(data) do
						local v_name, v_type, v_indent, v_descriptor, v_elements = v.name, v.type, v.indent, v.descriptor, v.elements
						local var_transparent, var_get, var_set, var_disabled, var_hidden = v.var_transparent, v.var_get, v.var_set, v.var_disabled, v.var_hidden
						if container and container.VAR_TRANSPARENT then var_transparent = true end

						local v_description = v_descriptor and v_descriptor.description or nil
						local v_imageInfo = v_descriptor and v_descriptor.imageType and { imageType = v_descriptor.imageType, imagePath = v_descriptor.imagePath } or nil

						--------------------------------

						local newFrame = nil

						local function Check_Disabled() return var_disabled() end
						local function Check_Hidden() return var_hidden() end
						local function Set(...) return var_set(...) end
						local function Get() return var_get() end

						if v_type == addon.C.AddonInfo.Variables.Config.TYPE_TITLE then
							local var_title_imageTexture, var_title_text, var_title_subtext = v.var_title_imageTexture, v.var_title_text, v.var_title_subtext

							--------------------------------

							newFrame = Callback.Constructor:Create_Setting_Title(parent, v_name)
							newFrame:SetInfo(var_title_imageTexture, var_title_text, var_title_subtext)
						end
						if v_type == addon.C.AddonInfo.Variables.Config.TYPE_CONTAINER then
							local var_subcontainer = v.var_subcontainer

							--------------------------------

							newFrame = Callback.Constructor:Create_Setting_Container(parent, v_name, var_transparent, var_subcontainer, v_name)

							local eventResponder = Callback.Constructor:Create_Responder(newFrame)

							table.insert(eventResponder.onConfigUpdateCallbacks, function()
								newFrame:SetShown(not Check_Hidden())
							end)
						end
						if v_type == addon.C.AddonInfo.Variables.Config.TYPE_RANGE then
							local var_range_min, var_range_max, var_range_step, var_range_text, var_range_set_lazy = v.var_range_min, v.var_range_max, v.var_range_step, v.var_range_text, v.var_range_set_lazy

							--------------------------------

							newFrame = Callback.Constructor:Create_Setting_Element_Range(parent, { indent = v_indent, transparent = var_transparent }, v_name)
							newFrame:SetTitle(v_name, v_imageInfo, v_description)

							local range = newFrame.REF_RANGE.REF_RANGE
							local eventResponder = Callback.Constructor:Create_Responder(newFrame)

							table.insert(eventResponder.onConfigUpdateCallbacks, function()
								range:SetEnabled(not Check_Disabled())
								newFrame:SetShown(not Check_Hidden())

								-- Value
								local min, max = type(var_range_min) == "function" and var_range_min() or var_range_min, type(var_range_max) == "function" and var_range_max() or var_range_max
								local step = type(var_range_step) == "function" and var_range_step() or var_range_step
								local new = Get(); new = math.max(new, min); new = math.min(new, max)

								range:SetMinMaxValues(min, max)
								range:SetValueStep(step)
								range:SetValue(new)

								-- Range text
								range:OnValueChanged(new, false)
							end)
							table.insert(range.onValueChangedCallbacks, function(_, value, userInput)
								if userInput then
									Set(value)
								end

								--------------------------------

								newFrame.REF_RANGE:SetText(var_range_text and var_range_text(value) or value)
							end)
							table.insert(range.mouseUpCallbacks, function()
								if NS.Variables.ConfigReady then
									if var_range_set_lazy then var_range_set_lazy(range:GetValue()) end

									--------------------------------

									CallbackRegistry:Trigger("C_CONFIG_UPDATE")
								end
							end)
						end
						if v_type == addon.C.AddonInfo.Variables.Config.TYPE_BUTTON then
							local var_button_text = v.var_button_text

							--------------------------------

							newFrame = Callback.Constructor:Create_Setting_Element_Button(parent, { indent = v_indent, transparent = var_transparent }, v_name)
							newFrame:SetTitle(v_name, v_imageInfo, v_description)

							local button = newFrame.REF_BUTTON
							button:SetText(var_button_text)
							button:SetClick(function()
								Set()

								--------------------------------

								if NS.Variables.ConfigReady then
									CallbackRegistry:Trigger("C_CONFIG_UPDATE")
								end
							end)

							local eventResponder = Callback.Constructor:Create_Responder(newFrame)

							table.insert(eventResponder.onConfigUpdateCallbacks, function()
								button:SetEnabled(not Check_Disabled())
								newFrame:SetShown(not Check_Hidden())
							end)
						end
						if v_type == addon.C.AddonInfo.Variables.Config.TYPE_CHECKBOX then
							newFrame = Callback.Constructor:Create_Setting_Element_Checkbox(parent, { indent = v_indent, transparent = var_transparent }, v_name)
							newFrame:SetTitle(v_name, v_imageInfo, v_description)

							local checkbox = newFrame.REF_CHECKBOX
							local eventResponder = Callback.Constructor:Create_Responder(newFrame)

							table.insert(eventResponder.onConfigUpdateCallbacks, function()
								checkbox:SetChecked(Get(), false)
								newFrame:SetShown(not Check_Hidden())
							end)
							table.insert(checkbox.onValueChangedCallbacks, function(_, value, userInput)
								if userInput then
									Set(value)

									--------------------------------

									if NS.Variables.ConfigReady then
										CallbackRegistry:Trigger("C_CONFIG_UPDATE")
									end
								end
							end)
						end
						if v_type == addon.C.AddonInfo.Variables.Config.TYPE_DROPDOWN then
							local var_dropdown_info = v.var_dropdown_info

							--------------------------------

							newFrame = Callback.Constructor:Create_Setting_Element_Dropdown(parent, { indent = v_indent, transparent = var_transparent }, v_name)
							newFrame:SetTitle(v_name, v_imageInfo, v_description)

							local dropdown = newFrame.REF_DROPDOWN
							dropdown:SetDropdownInfo(var_dropdown_info, Get())

							local eventResponder = Callback.Constructor:Create_Responder(newFrame)

							table.insert(eventResponder.onConfigUpdateCallbacks, function()
								dropdown:SetEnabled(not Check_Disabled())
								newFrame:SetShown(not Check_Hidden())
								dropdown:ContextMenu_SetValue(Get(), false)
							end)
							table.insert(dropdown.onValueChangedCallbacks, function(_, value, userInput)
								if userInput then
									if Set(value) then
										addon.C.Frame.ContextMenu.Script:Main_Hide()
									end

									--------------------------------

									if NS.Variables.ConfigReady then
										CallbackRegistry:Trigger("C_CONFIG_UPDATE")
									end
								end
							end)
						end
						if v_type == addon.C.AddonInfo.Variables.Config.TYPE_TEXT then
							newFrame = Callback.Constructor:Create_Setting_Element_Text(parent, { indent = v_indent, transparent = var_transparent }, v_name)
							newFrame:SetTitle(v_name, v_imageInfo, v_description)

							local eventResponder = Callback.Constructor:Create_Responder(newFrame)

							table.insert(eventResponder.onConfigUpdateCallbacks, function()
								newFrame:SetShown(not Check_Hidden())
							end)
						end
						if v_type == addon.C.AddonInfo.Variables.Config.TYPE_COLOR then
							newFrame = Callback.Constructor:Create_Setting_Element_Color(parent, { indent = v_indent, transparent = var_transparent }, v_name)
							newFrame:SetTitle(v_name, v_imageInfo, v_description)

							local color = newFrame.REF_COLOR
							color:SetColor(Get())

							local eventResponder = Callback.Constructor:Create_Responder(newFrame)

							table.insert(eventResponder.onConfigUpdateCallbacks, function()
								newFrame:SetShown(not Check_Hidden())
								color:SetColor(Get())
							end)
							table.insert(color.onValueChangedCallbacks, function(_, value, userInput)
								if userInput then
									Set(value)
								end
							end)
							table.insert(color.onCloseCallbacks, function()
								if NS.Variables.ConfigReady then
									CallbackRegistry:Trigger("C_CONFIG_UPDATE")
								end
							end)
						end
						if v_type == addon.C.AddonInfo.Variables.Config.TYPE_TEXTBOX then
							local var_textbox_placeholder = v.var_textbox_placeholder

							--------------------------------

							newFrame = Callback.Constructor:Create_Setting_Element_TextBox(parent, { indent = v_indent, transparent = var_transparent }, v_name)
							newFrame:SetTitle(v_name, v_imageInfo, v_description)

							local textBox = newFrame.REF_TEXTBOX
							textBox:SetPlaceholder(var_textbox_placeholder)
							textBox:SetText(Get())

							local eventResponder = Callback.Constructor:Create_Responder(newFrame)

							table.insert(eventResponder.onConfigUpdateCallbacks, function()
								newFrame:SetShown(not Check_Hidden())
								textBox:SetText(Get())
							end)
							table.insert(textBox.textChangedCallbacks, function(_, userInput)
								if userInput then
									Set(textBox:GetText())
								end
							end)
						end

						--------------------------------

						if v_type == addon.C.AddonInfo.Variables.Config.TYPE_CONTAINER then
							if v_elements then
								if newFrame.REF_CONTAINER then
									Callback.Constructor:ScanConstruct_Elements(newFrame.REF_CONTAINER.REF_MAIN_LAYOUT, newFrame.REF_CONTAINER, v_elements)
								else
									Callback.Constructor:ScanConstruct_Elements(newFrame.REF_MAIN_LAYOUT, newFrame, v_elements)
								end
							end
						end
					end
				end
			end
		end

		do -- NAVIGATION
			Callback.Navigation = {}

			--------------------------------

			do -- SIDEBAR
				function Callback.Navigation:UpdateSidebar()
					for i = 1, #NS.Variables.TabButtons do
						NS.Variables.TabButtons[i]:SetActive(false)
					end

					NS.Variables.TabButtons[NS.Variables.CurrentTab]:SetActive(true)
				end
			end

			do -- FUNCTIONS (MAIN)
				function Callback.Navigation:OpenTabByIndex(index, allowReload)
					if allowReload or NS.Variables.CurrentTab ~= index then
						for i = 1, #NS.Variables.Tabs do
							NS.Variables.Tabs[i]:Hide()
						end

						NS.Variables.Tabs[index]:ShowWithAnimation()

						--------------------------------

						NS.Variables.CurrentTab = index
						CallbackRegistry:Trigger("C_CONFIG_TAB_CHANGED")

						--------------------------------

						Callback.Navigation:UpdateSidebar()
					end
				end

				_G[addon.C.AddonInfo.Variables.General.IDENTIFIER .. "_OpenConfig"] = function()
					if addon.C.Variables.IS_WOW_VERSION_CLASSIC_ALL then
						InterfaceOptionsFrame_OpenToCategory(addon.C.AddonInfo.Variables.General.REGISTRY_NAME)
					else
						Settings.OpenToCategory(addon.C.AddonInfo.Variables.General.REGISTRY_NAME)
					end
				end
			end
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	do
		local loaded = false

		hooksecurefunc(Frame, "Show", function()
			local SettingsCanvas = SettingsPanel.Container.SettingsCanvas
			local Offset = addon.C.WoWClient.Script:IsAddOnLoaded("ElvUI") and 0 or 10

			--------------------------------

			Frame:ClearAllPoints()
			Frame:SetPoint("CENTER", SettingsCanvas, -Offset, 5)

			if not loaded then
				loaded = true

				--------------------------------

				Frame:SetSize(SettingsCanvas:GetWidth() + Offset, SettingsCanvas:GetHeight() + Offset / 2)

				--------------------------------

				Frame.REF_CONTENT:SetSize(Frame:GetSize())
				Frame:UpdateLayout()
				CallbackRegistry:Trigger("C_TEXT_AUTOFIT")
			end

			--------------------------------

			Callback.Navigation:OpenTabByIndex(1, true)
		end)

		CallbackRegistry:Add("C_CONFIG_UPDATE", function()
			Frame:UpdateLayout()
		end, 10)
	end

	--------------------------------
	-- SETUP
	--------------------------------

	do
		C_Timer.After(.1, function()
			Callback.Constructor:StartConstruction(addon.C.AddonInfo.Variables.Config.TABLE)
			Frame:SetAddonIcon()
			Frame:Hide()

			-- addon setting name cannot contain spaces or it can't be located by Settings.OpenToCategory
			-- so using REGISTRY_NAME instead of NAME
			local Category = Settings.RegisterCanvasLayoutCategory(Frame, addon.C.AddonInfo.Variables.General.REGISTRY_NAME)
			Category.ID = addon.C.AddonInfo.Variables.General.REGISTRY_NAME
			Settings.RegisterAddOnCategory(Category)
		end)
	end
end
