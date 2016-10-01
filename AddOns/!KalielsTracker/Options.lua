--- Kaliel's Tracker
--- Copyright (c) 2012-2016, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, KT = ...

local ACD = LibStub("AceConfigDialog-3.0-KT")
local WidgetLists = AceGUIWidgetLSMlists
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local floor = math.floor
local fmod = math.fmod
local format = string.format
local ipairs = ipairs
local pairs = pairs
local strlen = string.len
local strsub = string.sub

local db
local mediaPath = "Interface\\AddOns\\"..addonName.."\\Media\\"
local anchors = { "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" }
local strata = { "LOW", "MEDIUM", "HIGH" }
local flags = { [""] = "None", ["OUTLINE"] = "Outline", ["OUTLINE, MONOCHROME"] = "Outline Monochrome" }
local textures = { "None", "Default (Blizzard)", "One line", "Two lines" }

local cNote = "|cff00ffe3"
local beta = "|cffff7fff[Beta]|r"
local warning = "|cffff7f00Warning:|r UI will be re-loaded!"

local KTF = KT.frame

local SetSharedColor, IsSpecialLocale, DecToHex, RgbToHex	-- functions

local defaults = {
	profile = {
		anchorPoint = "TOPRIGHT",
		xOffset = -85,
		yOffset = -200,
		maxHeight = 400,
		frameScrollbar = true,
		frameStrata = "LOW",
		
		bgr = "Solid",
		bgrColor = { r=0, g=0, b=0, a=0.7 },
		border = "None",
		borderColor = { r=1, g=0.82, b=0 },
		classBorder = false,
		borderAlpha = 1,
		borderThickness = 16,
		bgrInset = 4,
		
		font = "Friz Quadrata TT",
		fontSize = 12,
		fontFlag = "",
		fontShadow = 1,
		colorDifficulty = false,
		textWordWrap = false,
		objNumSwitch = false,

		hdrBgr = 2,
		hdrBgrColor = { r=1, g=0.82, b=0 },
		hdrBgrColorShare = false,
		hdrTxtColor = { r=1, g=0.82, b=0 },
		hdrTxtColorShare = false,
		hdrBtnColor = { r=1, g=0.82, b=0 },
		hdrBtnColorShare = false,
		hdrQuestsTitleAppend = true,
		hdrAchievsTitleAppend = true,
		hdrPetTrackerTitleAppend = true,
		hdrCollapsedTxt = 3,
		hdrOtherButtons = true,
		keyBindMinimize = "",
		
		qiBgrBorder = false,
		qiXOffset = -5,
		qiActiveButton = true,
		
		tooltipShow = true,
		tooltipShowID = true,
		hideEmptyTracker = false,
		collapseInInstance = false,
		
		sink20OutputSink = "UIErrorsFrame",
		sink20Sticky = false,

		specialLegionInvasion = true,

		addonMasque = false,
		addonPetTracker = false,
		addonTomTom = false,
		
		collapsed = false,
	}
}

local options = {
	name = "|T"..mediaPath.."KT_logo:22:22:-1:7|t"..KT.title,
	type = "group",
	get = function(info) return db[info[#info]] end,
	args = {
		general = {
			name = "Options",
			type = "group",
			args = {
				sec0 = {
					name = "Info",
					type = "group",
					inline = true,
					order = 0,
					args = {
						info = {
							name = "  |cffffd100Version:|r  "..KT.version,
							type = "description",
							width = "normal",
							fontSize = "medium",
							order = 0.1,
						},
						slash = {
							name = cNote.." /kt|r ... Toggle (expand/collapse) the tracker\n"..
									cNote.." /kt config|r ... Show this config window",
							type = "description",
							width = "normal+half",
							order = 0.2
						},
						help = {
							name = "Help",
							type = "execute",
							width = "half",
							disabled = function()
								return not KT.Help:IsEnabled()
							end,
							func = function()
								KT.Help:ShowHelp()
							end,
							order = 0.3,
						},
					},
				},
				sec1 = {
					name = "Position / Size",
					type = "group",
					inline = true,
					order = 1,
					args = {
						anchorPoint = {
							name = "Anchor point",
							desc = "- Default: "..defaults.profile.anchorPoint,
							type = "select",
							values = anchors,
							get = function()
								for k, v in ipairs(anchors) do
									if db.anchorPoint == v then
										return k
									end
								end
							end,
							set = function(_, value)
								db.anchorPoint = anchors[value]
								db.xOffset = 0
								db.yOffset = 0
								KT:MoveTracker()
							end,
							order = 1.1,
						},
						xOffset = {
							name = "X offset",
							desc = "- Default: "..defaults.profile.xOffset.."\n- Step: 1",
							type = "range",
							min = 0,
							max = 0,
							step = 1,
							set = function(_, value)
								db.xOffset = value
								KT:MoveTracker()
							end,
							order = 1.2,
						},
						yOffset = {
							name = "Y offset",
							desc = "- Default: "..defaults.profile.yOffset.."\n- Step: 2",
							type = "range",
							min = 0,
							max = 0,
							step = 2,
							set = function(_, value)
								db.yOffset = value
								KT:MoveTracker()
								KT:SetSize()
							end,
							order = 1.3,
						},
						maxHeight = {
							name = "Max. height",
							desc = "- Default: "..defaults.profile.maxHeight.."\n- Step: 2",
							type = "range",
							min = 100,
							max = 100,
							step = 2,
							set = function(_, value)
								db.maxHeight = value
								KT:SetSize()
							end,
							order = 1.4,
						},
						maxHeightNote = {
							name = cNote.." Max. height is related with value Y offset.\n"..
								" Content is lesser ... tracker height is automatically increases.\n"..
								" Content is greater ... tracker enables scrolling.",
							type = "description",
							width = "double",
							order = 1.41,
						},
						frameScrollbar = {
							name = "Show scroll indicator",
							desc = "Show scroll indicator when srolling is enabled. Color is shared with border.",
							type = "toggle",
							set = function()
								db.frameScrollbar = not db.frameScrollbar
								KTF.Bar:SetShown(db.frameScrollbar)
								KT:SetSize()
							end,
							order = 1.5,
						},
						frameStrata = {
							name = "Strata",
							desc = "- Default: "..defaults.profile.frameStrata,
							type = "select",
							values = strata,
							get = function()
								for k, v in ipairs(strata) do
									if db.frameStrata == v then
										return k
									end
								end
							end,
							set = function(_, value)
								db.frameStrata = strata[value]
								KTF:SetFrameStrata(strata[value])
								KTF.Buttons:SetFrameStrata(strata[value])
							end,
							order = 1.6,
						},
					},
				},
				sec2 = {
					name = "Background / Border",
					type = "group",
					inline = true,
					order = 2,
					args = {
						bgr = {
							name = "Background texture",
							type = "select",
							dialogControl = "LSM30_Background",
							values = WidgetLists.background,
							set = function(_, value)
								db.bgr = value
								KT:SetBackground()
								KT:MoveButtons()
							end,
							order = 2.1,
						},
						bgrColor = {
							name = "Background color",
							type = "color",
							hasAlpha = true,
							get = function()
								return db.bgrColor.r, db.bgrColor.g, db.bgrColor.b, db.bgrColor.a
							end,
							set = function(_, r, g, b, a)
								db.bgrColor.r = r
								db.bgrColor.g = g
								db.bgrColor.b = b
								db.bgrColor.a = a
								KT:SetBackground()
							end,
							order = 2.2,
						},
						bgrNote = {
							name = cNote.." For a custom background\n texture set white color.",
							type = "description",
							width = "normal",
							order = 2.21,
						},
						border = {
							name = "Border texture",
							type = "select",
							dialogControl = "LSM30_Border",
							values = WidgetLists.border,
							set = function(_, value)
								db.border = value
								KT:SetBackground()
								KT:MoveButtons()
							end,
							order = 2.3,
						},
						borderColor = {
							name = "Border color",
							type = "color",
							disabled = function()
								return db.classBorder
							end,
							get = function()
								if not db.classBorder then
									SetSharedColor(db.borderColor)
								end
								return db.borderColor.r, db.borderColor.g, db.borderColor.b
							end,
							set = function(_, r, g, b)
								db.borderColor.r = r
								db.borderColor.g = g
								db.borderColor.b = b
								KT:SetBackground()
								KT:SetText()
								SetSharedColor(db.borderColor)
							end,
							order = 2.4,
						},
						classBorder = {
							name = "Border color by |cff%sClass|r",
							type = "toggle",
							get = function(info)
								if db[info[#info]] then
									SetSharedColor(KT.classColor)
								end
								return db[info[#info]]
							end,
							set = function()
								db.classBorder = not db.classBorder
								KT:SetBackground()
								KT:SetText()
							end,
							order = 2.5,
						},
						borderAlpha = {
							name = "Border transparency",
							desc = "- Default: "..defaults.profile.borderAlpha.."\n- Step: 0.05",
							type = "range",
							min = 0.1,
							max = 1,
							step = 0.05,
							set = function(_, value)
								db.borderAlpha = value
								KT:SetBackground()
							end,
							order = 2.6,
						},
						borderThickness = {
							name = "Border thickness",
							desc = "- Default: "..defaults.profile.borderThickness.."\n- Step: 0.5",
							type = "range",
							min = 1,
							max = 24,
							step = 0.5,
							set = function(_, value)
								db.borderThickness = value
								KT:SetBackground()
							end,
							order = 2.7,
						},
						bgrInset = {
							name = "Background inset",
							desc = "- Default: "..defaults.profile.bgrInset.."\n- Step: 0.5",
							type = "range",
							min = 0,
							max = 10,
							step = 0.5,
							set = function(_, value)
								db.bgrInset = value
								KT:SetBackground()
								KT:MoveButtons()
							end,
							order = 2.8,
						},
					},
				},
				sec3 = {
					name = "Texts",
					type = "group",
					inline = true,
					order = 3,
					args = {
						font = {
							name = "Font",
							type = "select",
							dialogControl = "LSM30_Font",
							values = WidgetLists.font,
							set = function(_, value)
								db.font = value
								KT:SetText()
								ObjectiveTracker_Update()
								if PetTracker then
									PetTracker.Objectives:TrackingChanged()
								end
							end,
							order = 3.1,
						},
						fontSize = {
							name = "Font size",
							type = "range",
							min = 8,
							max = 24,
							step = 1,
							set = function(_, value)
								db.fontSize = value
								KT:SetText()
								ObjectiveTracker_Update()
								if PetTracker then
									PetTracker.Objectives:TrackingChanged()
								end
							end,
							order = 3.2,
						},
						fontFlag = {
							name = "Font flag",
							type = "select",
							values = flags,
							get = function()
								for k, v in pairs(flags) do
									if db.fontFlag == k then
										return k
									end
								end
							end,
							set = function(_, value)
								db.fontFlag = value
								KT:SetText()
								ObjectiveTracker_Update()
								if PetTracker then
									PetTracker.Objectives:TrackingChanged()
								end
							end,
							order = 3.3,
						},
						fontShadow = {
							name = "Font shadow",
							type = "toggle",
							get = function()
								return (db.fontShadow == 1)
							end,
							set = function(_, value)
								db.fontShadow = value and 1 or 0
								KT:SetText()
								ObjectiveTracker_Update()
								if PetTracker then
									PetTracker.Objectives:TrackingChanged()
								end
							end,
							order = 3.4,
						},
						colorDifficulty = {
							name = "Color by difficulty",
							desc = "Quest titles color by difficulty.",
							type = "toggle",
							set = function()
								db.colorDifficulty = not db.colorDifficulty
								ObjectiveTracker_Update()
								QuestMapFrame_UpdateAll()
							end,
							order = 3.5,
						},
						textWordWrap = {
							name = "Wrap long texts",
							desc = "Long texts shows on two lines or on one line with ellipsis (...).",
							type = "toggle",
							set = function()
								db.textWordWrap = not db.textWordWrap
								KT:SetText()
								ObjectiveTracker_Update()
								if PetTracker then
									PetTracker.Objectives:TrackingChanged()
								end
							end,
							order = 3.6,
						},
						objNumSwitch = {
							name = "Objective numbers at the beginning "..beta,
							desc = "Changing the position of objective numbers at the beginning of the line. "..
								   cNote.."Only for deDE, esES, frFR, ruRU locale.",
							descStyle = "inline",
							type = "toggle",
							width = "double",
							disabled = function()
								return IsSpecialLocale()
							end,
							set = function()
								db.objNumSwitch = not db.objNumSwitch
								ObjectiveTracker_Update()
							end,
							order = 3.7,
						},
					},
				},
				sec4 = {
					name = "Headers",
					type = "group",
					inline = true,
					order = 4,
					args = {
						hdrBgrLabel = {
							name = " Texture",
							type = "description",
							width = "half",
							fontSize = "medium",
							order = 4.1,
						},
						hdrBgr = {
							name = "",
							type = "select",
							values = textures,
							get = function()
								for k, v in ipairs(textures) do
									if db.hdrBgr == k then
										return k
									end
								end
							end,
							set = function(_, value)
								db.hdrBgr = value
								KT:SetBackground()
							end,
							order = 4.11,
						},
						hdrBgrColor = {
							name = "Color",
							desc = "Sets the color to texture of the header.",
							type = "color",
							width = "half",
							disabled = function()
								return (db.hdrBgr < 3 or db.hdrBgrColorShare)
							end,
							get = function()
								return db.hdrBgrColor.r, db.hdrBgrColor.g, db.hdrBgrColor.b
							end,
							set = function(_, r, g, b)
								db.hdrBgrColor.r = r
								db.hdrBgrColor.g = g
								db.hdrBgrColor.b = b
								KT:SetBackground()
							end,
							order = 4.12,
						},
						hdrBgrColorShare = {
							name = "Use border color",
							desc = "The color of texture is shared with the border color.",
							type = "toggle",
							disabled = function()
								return (db.hdrBgr < 3)
							end,
							set = function()
								db.hdrBgrColorShare = not db.hdrBgrColorShare
								KT:SetBackground()
							end,
							order = 4.13,
						},
						hdrTxtLabel = {
							name = " Text",
							type = "description",
							width = "half",
							fontSize = "medium",
							order = 4.2,
						},
						hdrTxtColor = {
							name = "Color",
							desc = "Sets the color to header texts.",
							type = "color",
							width = "half",
							disabled = function()
								KT:SetText()
								return (db.hdrBgr == 2 or db.hdrTxtColorShare)
							end,
							get = function()
								return db.hdrTxtColor.r, db.hdrTxtColor.g, db.hdrTxtColor.b
							end,
							set = function(_, r, g, b)
								db.hdrTxtColor.r = r
								db.hdrTxtColor.g = g
								db.hdrTxtColor.b = b
								KT:SetText()
							end,
							order = 4.21,
						},
						hdrTxtColorShare = {
							name = "Use border color",
							desc = "The color of header texts is shared with the border color.",
							type = "toggle",
							disabled = function()
								return (db.hdrBgr == 2)
							end,
							set = function()
								db.hdrTxtColorShare = not db.hdrTxtColorShare
								KT:SetText()
							end,
							order = 4.22,
						},
						hdrTxtSpacer = {
							name = " ",
							type = "description",
							width = "normal",
							order = 4.23,
						},
						hdrBtnLabel = {
							name = " Buttons",
							type = "description",
							width = "half",
							fontSize = "medium",
							order = 4.3,
						},
						hdrBtnColor = {
							name = "Color",
							desc = "Sets the color to all header buttons.",
							type = "color",
							width = "half",
							disabled = function()
								return db.hdrBtnColorShare
							end,
							get = function()
								return db.hdrBtnColor.r, db.hdrBtnColor.g, db.hdrBtnColor.b
							end,
							set = function(_, r, g, b)
								db.hdrBtnColor.r = r
								db.hdrBtnColor.g = g
								db.hdrBtnColor.b = b
								KT:SetBackground()
							end,
							order = 4.32,
						},
						hdrBtnColorShare = {
							name = "Use border color",
							desc = "The color of all header buttons is shared with the border color.",
							type = "toggle",
							set = function()
								db.hdrBtnColorShare = not db.hdrBtnColorShare
								KT:SetBackground()
							end,
							order = 4.33,
						},
						hdrBtnSpacer = {
							name = " ",
							type = "description",
							width = "normal",
							order = 4.34,
						},
						sec4SpacerMid1 = {
							name = " ",
							type = "description",
							order = 4.35,
						},
						hdrQuestsTitleAppend = {
							name = "Show number of Quests",
							desc = "Show number of Quests inside the Quests header.",
							type = "toggle",
							width = "normal+half",
							set = function()
								db.hdrQuestsTitleAppend = not db.hdrQuestsTitleAppend
								KT:SetQuestsHeaderText(true)
							end,
							order = 4.4,
						},
						hdrAchievsTitleAppend = {
							name = "Show Achievement points",
							desc = "Show Achievement points inside the Achievements header.",
							type = "toggle",
							width = "normal+half",
							set = function()
								db.hdrAchievsTitleAppend = not db.hdrAchievsTitleAppend
								KT:SetAchievsHeaderText(true)
							end,
							order = 4.5,
						},
						hdrPetTrackerTitleAppend = {	-- Addon - PetTracker
							name = "Show number of owned Pets",
							desc = "Show number of owned Pets inside the PetTracker header.",
							type = "toggle",
							width = "normal+half",
							disabled = function()
								return not KT.AddonPetTracker.isLoaded
							end,
							set = function()
								db.hdrPetTrackerTitleAppend = not db.hdrPetTrackerTitleAppend
								KT.AddonPetTracker:SetPetsHeaderText(true)
							end,
							order = 4.6,
						},
						sec4SpacerMid2 = {
							name = " ",
							type = "description",
							order = 4.65,
						},
						hdrCollapsedTxtLabel = {
							name = " Collapsed\n text",
							type = "description",
							width = "half",
							fontSize = "medium",
							order = 4.7,
						},
						hdrCollapsedTxt1 = {
							name = "None",
							type = "toggle",
							width = "half",
							get = function()
								return (db.hdrCollapsedTxt == 1)
							end,
							set = function()
								db.hdrCollapsedTxt = 1
								ObjectiveTracker_Update()
							end,
							order = 4.71,
						},
						hdrCollapsedTxt2 = {
							name = ("0/%d (0)"):format(MAX_QUESTS),
							type = "toggle",
							width = "half",
							get = function()
								return (db.hdrCollapsedTxt == 2)
							end,
							set = function()
								db.hdrCollapsedTxt = 2
								ObjectiveTracker_Update()
							end,
							order = 4.72,
						},
						hdrCollapsedTxt3 = {
							name = ("0/%d Quests  -  0 Dailies"):format(MAX_QUESTS),
							type = "toggle",
							width = "normal+half",
							get = function()
								return (db.hdrCollapsedTxt == 3)
							end,
							set = function()
								db.hdrCollapsedTxt = 3
								ObjectiveTracker_Update()
							end,
							order = 4.73,
						},
						hdrOtherButtons = {
							name = "Show Quest Log and Achievements buttons",
							type = "toggle",
							width = "double",
							set = function()
								db.hdrOtherButtons = not db.hdrOtherButtons
								KT:ToggleOtherButtons()
								KT:SetBackground()
							end,
							order = 4.8,
						},
						keyBindMinimize = {
							name = "Key - Minimize button",
							type = "keybinding",
							set = function(_, value)
								SetOverrideBinding(KTF, false, db.keyBindMinimize, nil)
								if value ~= "" then
									local key = GetBindingKey("EXTRAACTIONBUTTON1")
									if key == value then
										SetBinding(key)
										SaveBindings(GetCurrentBindingSet())
									end
									SetOverrideBindingClick(KTF, false, value, KTF.MinimizeButton:GetName())
								end
								db.keyBindMinimize = value
							end,
							order = 4.9,
						},
					},
				},
				sec5 = {
					name = "Quest item buttons",
					type = "group",
					inline = true,
					order = 5,
					args = {
						qiBgrBorder = {
							name = "Show buttons block background and border",
							type = "toggle",
							width = "double",
							set = function()
								db.qiBgrBorder = not db.qiBgrBorder
								KT:SetBackground()
								KT:MoveButtons()
							end,
							order = 5.1,
						},
						qiXOffset = {
							name = "X offset",
							type = "range",
							min = -10,
							max = 10,
							step = 1,
							set = function(_, value)
								db.qiXOffset = value
								KT:MoveButtons()
							end,
							order = 5.2,
						},
						qiActiveButton = {
							name = "Enable Active button "..beta,
							desc = "Show Quest item button for CLOSEST quest as \"Extra Action Button\". "..
								   cNote.."Key bind is shared with EXTRAACTIONBUTTON1.",
							descStyle = "inline",
							width = "double",
							type = "toggle",
							set = function()
								db.qiActiveButton = not db.qiActiveButton
								if db.qiActiveButton then
									KT.ActiveButton:Enable()
								else
									KT.ActiveButton:Disable()
								end
							end,
							order = 5.3,
						},
						keyBindActiveButton = {
							name = "Key - Active button",
							type = "keybinding",
							disabled = function()
								return not db.qiActiveButton
							end,
							get = function()
								local key = GetBindingKey("EXTRAACTIONBUTTON1")
								return key
							end,
							set = function(_, value)
								local key = GetBindingKey("EXTRAACTIONBUTTON1")
								if key then
									SetBinding(key)
								end
								if value ~= "" then
									if db.keyBindMinimize == value then
										SetOverrideBinding(KTF, false, db.keyBindMinimize, nil)
										db.keyBindMinimize = ""
									end
									SetBinding(value, "EXTRAACTIONBUTTON1")
								end
								SaveBindings(GetCurrentBindingSet())
							end,
							order = 5.4,
						},
					},
				},
				sec6 = {
					name = "Other options",
					type = "group",
					inline = true,
					order = 6,
					args = {
						tooltipShow = {
							name = "Show tooltips",
							desc = "Show Quest or Achievement tooltips.",
							type = "toggle",
							set = function()
								db.tooltipShow = not db.tooltipShow
							end,
							order = 6.1,
						},
						tooltipShowID = {
							name = "Show ID in tooltips",
							desc = "Show Quest or Achievement ID in tooltips.",
							type = "toggle",
							disabled = function()
								return not db.tooltipShow
							end,
							set = function()
								db.tooltipShowID = not db.tooltipShowID
							end,
							order = 6.2,
						},
						hideEmptyTracker = {
							name = "Hide empty tracker",
							type = "toggle",
							set = function()
								db.hideEmptyTracker = not db.hideEmptyTracker
								KT:ToggleEmptyTracker()
							end,
							order = 6.3,
						},
						collapseInInstance = {
							name = "Collapse in instance",
							desc = "Collapses the tracker when entering an instance.",
							type = "toggle",
							set = function()
								db.collapseInInstance = not db.collapseInInstance
							end,
							order = 6.5,
						},
					},
				},
				sec7 = {
					-- LibSink
				},
				sec8 = {
					name = "Special",
					type = "group",
					inline = true,
					order = 0.5,
					args = {
						specialLegionInvasionImg = {
							name = "",
							type = "description",
							width = "half",
							image = "Interface\\Scenarios\\LegionInvasion",
							imageCoords = { 0.61328125, 0.728515625, 0.28125, 0.40234375 },
							imageWidth = 39,
							imageHeight = 42,
							order = 8.1,
						},
						specialLegionInvasion = {
							name = "Legion Invasion Monitor",
							desc = "Show zones under invasion inside the tracker.",
							descStyle = "inline",
							type = "toggle",
							width = "normal+half",
							confirm = true,
							confirmText = warning,
							set = function()
								db.specialLegionInvasion = not db.specialLegionInvasion
								if db.specialLegionInvasion then
									db.collapsed = false
								end
								ReloadUI()
							end,
							order = 8.2,
						},
					},
				},
			},
		},
		addons = {
			name = "Supported addons",
			type = "group",
			args = {
				desc = {
					name = "|cff00d200Green|r - compatible version - this version was tested and support is inserted.\n"..
							"|cffff0000Red|r - incompatible version - this version wasn't tested, maybe will need some code changes.\n"..
							"Please report all problems.",
					type = "description",
					order = 0,
				},
				sec1 = {
					name = "Addons",
					type = "group",
					inline = true,
					order = 1,
					args = {
						addonMasque = {
							name = "Masque",
							desc = "Version: %s\n\nSupport skinning for quest item buttons.",
							descStyle = "inline",
							type = "toggle",
							confirm = true,
							confirmText = warning,
							disabled = function()
								return (not IsAddOnLoaded("Masque") or not KT.AddonOthers:IsEnabled())
							end,
							set = function()
								db.addonMasque = not db.addonMasque
								ReloadUI()
							end,
							order = 1.2,
						},
						addonPetTracker = {
							name = "PetTracker",
							desc = "Version: %s\n\n"..beta.." Full support for zone pet tracking.",
							descStyle = "inline",
							type = "toggle",
							confirm = true,
							confirmText = warning,
							disabled = function()
								return not IsAddOnLoaded("PetTracker")
							end,
							set = function()
								db.addonPetTracker = not db.addonPetTracker
								PetTracker.Sets.HideTracker = not db.addonPetTracker
								ReloadUI()
							end,
							order = 1.3,
						},
						addonTomTom = {
							name = "TomTom",
							desc = "Version: %s\n\n"..beta.." Support for add/remove quest waypoints.",
							descStyle = "inline",
							type = "toggle",
							confirm = true,
							confirmText = warning,
							disabled = function()
								return not IsAddOnLoaded("TomTom")
							end,
							set = function()
								db.addonTomTom = not db.addonTomTom
								ReloadUI()
							end,
							order = 1.4,
						},
					},
				},
				sec2 = {
					name = "User Interfaces",
					type = "group",
					inline = true,
					order = 2,
					args = {
						elvui = {
							name = "ElvUI",
							type = "toggle",
							disabled = true,
							order = 2.1,
						},
						tukui = {
							name = "Tukui",
							type = "toggle",
							disabled = true,
							order = 2.2,
						},
						nibrealui = {
							name = "RealUI",
							type = "toggle",
							disabled = true,
							order = 2.3,
						},
						syncui = {
							name = "SyncUI",
							type = "toggle",
							disabled = true,
							order = 2.4,
						},
						spartanui = {
							name = "SpartanUI",
							type = "toggle",
							disabled = true,
							order = 2.5,
						},
						svui = {
							name = "SuperVillain UI",
							type = "toggle",
							disabled = true,
							order = 2.6,
						},
					},
				},
			},
		},
	},
}

local general = options.args.general.args
local addons = options.args.addons.args

function KT:CheckAddOn(addon, version, isUI)
	local name = strsplit("_", addon)
	local ver = isUI and "" or "---"
	local result = false
	local path
	if IsAddOnLoaded(addon) then
		local actualVersion = GetAddOnMetadata(addon, "Version")
		ver = isUI and "  -  " or ""
		ver = (ver.."|cff%s"..actualVersion.."|r"):format(actualVersion == version and "00d200" or "ff0000")
		result = true
	end
	if not isUI then
		path =  addons.sec1.args["addon"..name]
		path.desc = path.desc:format(ver)
	else
		local path =  addons.sec2.args[strlower(name)]
		path.name = path.name..ver
		path.disabled = not result
		path.get = function() return result end
	end
	return result
end

function KT:OpenOptions()
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame.profiles)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame.profiles)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame.general)
end

function KT:InitProfile(event, database, profile)
	ReloadUI()
end

function KT:SetupOptions()
	self.db = LibStub("AceDB-3.0"):New(strsub(addonName, 2).."DB", defaults, true)
	self.options = options
	db = self.db.profile

	general.sec2.args.classBorder.name = general.sec2.args.classBorder.name:format(RgbToHex(self.classColor))

	general.sec7 = self:GetSinkAce3OptionsDataTable()
	general.sec7.name = "Output for tracker messages"
	general.sec7.inline = true
	general.sec7.order = 7
	self:SetSinkStorage(db)
	
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	options.args.profiles.confirm = true
	options.args.profiles.args.reset.confirmText = warning
	options.args.profiles.args.new.confirmText = warning
	options.args.profiles.args.choose.confirmText = warning
	options.args.profiles.args.copyfrom.confirmText = warning
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, options, nil)
	
	self.optionsFrame = {}
	self.optionsFrame.general = ACD:AddToBlizOptions(addonName, self.title, nil, "general")
	self.optionsFrame.profiles = ACD:AddToBlizOptions(addonName, options.args.profiles.name, self.title, "profiles")
	self.optionsFrame.addons = ACD:AddToBlizOptions(addonName, options.args.addons.name, self.title, "addons")

	self.db.RegisterCallback(self, "OnProfileChanged", "InitProfile")
	self.db.RegisterCallback(self, "OnProfileCopied", "InitProfile")
	self.db.RegisterCallback(self, "OnProfileReset", "InitProfile")

	-- Disabled Options
	if IsSpecialLocale() then
		db.objNumSwitch = false
	end
end

function SetSharedColor(color)
	local name = "Use border |cff"..RgbToHex(color).."color|r"
	local sec4 = general.sec4.args
	sec4.hdrBgrColorShare.name = name
	sec4.hdrTxtColorShare.name = name
	sec4.hdrBtnColorShare.name = name
end

function IsSpecialLocale()
	return (KT.locale ~= "deDE" and
			KT.locale ~= "esES" and
			KT.locale ~= "frFR" and
			KT.locale ~= "ruRU")
end

function DecToHex(num)
	local b, k, hex, d = 16, "0123456789abcdef", "", 0
	while num > 0 do
		d = fmod(num, b) + 1
		hex = strsub(k, d, d)..hex
		num = floor(num/b)
	end
	hex = (hex == "") and "0" or hex
	return hex
end

function RgbToHex(color)
	local r, g, b = DecToHex(color.r*255), DecToHex(color.g*255), DecToHex(color.b*255)
	r = (strlen(r) < 2) and "0"..r or r
	g = (strlen(g) < 2) and "0"..g or g
	b = (strlen(b) < 2) and "0"..b or b
	return r..g..b
end