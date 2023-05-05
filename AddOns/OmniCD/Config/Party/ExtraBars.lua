local E, L, C = select(2, ...):unpack()
local P = E.Party

local getColor = function(info)
	local ele, option, c = info[#info-1], info[#info]
	if ele == "bgColors" and option == "inactiveColor" then
		c = E.profile.Party[ info[2] ].extraBars[ info[4] ].barColors.inactiveColor
	else
		c = E.profile.Party[ info[2] ].extraBars[ info[4] ][ele][option]
	end
	return c.r, c.g, c.b, c.a
end

local setColor = function(info, r, g, b, a)
	local key, bar, ele, option = info[2], info[4], info[#info-1], info[#info]
	local c = E.profile.Party[key].extraBars[bar][ele][option]
	c.r = r
	c.g = g
	c.b = b
	c.a = a

	if P:IsCurrentZone(key) then
		P:ConfigExBar(bar, ele)
	end
end

local isRaidCDBar = function(info)
	return info[4] ~= "raidBar0"
end

local isDisabledProgressBarOrNameBar = function(info)
	local db = E.profile.Party[ info[2] ].extraBars[ info[4] ]
	return not db.enabled or not db.progressBar or db.layout == "horizontal" or db.nameBar
end

local isEnabledProgressBar = function(info)
	local db = E.profile.Party[ info[2] ].extraBars[ info[4] ]
	return not db.enabled or (db.layout == "vertical" and db.progressBar)
end

local sortByValues = {
	raidBar0 = {
		[1] = format("%s>%s", L["Cooldown"], CLASS),
		[2] = format("%s>%s>%s", L["Cooldown Remaining"], L["Cooldown"], CLASS),
		[5] = ROLE,
		[6] = CLASS,
		[7] = format("%s>%s", L["Cooldown Remaining"], ROLE),
		[8] = format("%s>%s", L["Cooldown Remaining"], CLASS),
	},
	raidBar1 = {
		[3] = format("%s>%s>%s", L["Priority"], CLASS, L["Spell ID"]),
		[4] = format("%s>%s>%s", CLASS, L["Priority"], L["Spell ID"]),
		[9] = format("%s>%s>%s>%s", L["Cooldown Remaining"], L["Priority"], CLASS, "ID"),
		[10] = format("%s>%s>%s>%s", L["Cooldown Remaining"], CLASS, L["Priority"], "ID"),
	},
}
local interruptBarSortByDesc = format("%s.\n%s.\n%s.\n%s.\n%s.\n%s.", sortByValues.raidBar0[1], sortByValues.raidBar0[2], sortByValues.raidBar0[5], sortByValues.raidBar0[6], sortByValues.raidBar0[7], sortByValues.raidBar0[8])
local raidBarSortByDesc = format("%s.\n%s.\n%s.\n%s.", sortByValues.raidBar1[3], sortByValues.raidBar1[4], sortByValues.raidBar1[9], sortByValues.raidBar1[10])

local notTextColor = function(info) return info[#info-1] ~= "textColors" end

local progressBarColorInfo = {
	lb1 = {
		name = function(info)
			local opt = info[#info-1]
			return opt == "textColors" and NAME
			or (opt == "barColors" and L["Bar"])
			or (opt == "bgColors" and L["BG"])
		end,
		order = 0,
		type = "description",
		width = 0.5
	},
	activeColor = {
		name = "",
		order = 1,
		type = "color",
		dialogControl = "ColorPicker-OmniCD",
		hasAlpha = notTextColor,
		width = 0.5,

	},
	rechargeColor = {
		name = "",
		order = 2,
		type = "color",
		dialogControl = "ColorPicker-OmniCD",
		hasAlpha = notTextColor,
		width = 0.5,
	},
	inactiveColor = {
		disabled = function(info)
			local db = E.profile.Party[ info[2] ].extraBars[ info[4] ]
			return not db.enabled
			or not db.progressBar
			or db.layout == "horizontal"
			or info[#info-1] == "bgColors"
			or (info[#info-1] == "barColors" and db.nameBar)
		end,
		name = "",
		order = 3,
		type = "color",
		dialogControl = "ColorPicker-OmniCD",
		hasAlpha = notTextColor,
		width = 0.5,
	},
	useClassColor = {
		name = "",
		order = 4,
		type = "multiselect",
		dialogControl = "Dropdown-OmniCD",
		values = {
			active = L["Active"],
			inactive = L["Inactive"],
			recharge = L["Recharge"],
		},
		get = function(info, k)
			return E.profile.Party[ info[2] ].extraBars[ info[4] ][ info[#info-1] ].useClassColor[k]
		end,
		set = function(info, k, value)
			local key, bar = info[2], info[4]
			E.profile.Party[key].extraBars[bar][ info[#info-1] ].useClassColor[k] = value

			if P:IsCurrentZone(key) then
				P:ConfigExBar(bar, "barColors")
			end
		end,
		disabledItem = function(info)
			return info[#info-1] == "bgColors" and "inactive"
		end,
	},
}

local extraBarsInfo = {
	disabled = function(info)
		return info[5] and not E.profile.Party[ info[2] ].extraBars[ info[4] ].enabled
	end,
	name = function(info)
		local bar = info[4]
		return E.profile.Party[ info[2] ].extraBars[bar].name or bar == "raidBar0" and L["Interrupt Bar"] or P.extraBars[bar].index
	end,
	order = function(info)
		return P.extraBars[ info[4] ].index
	end,
	type = "group",
	args = {
		enabled = {
			disabled = false,
			name = ENABLE,
			desc = function(info)
				return info[4] == "raidBar0" and format("%s\n\n|cffffd200%s", L["Move your group's Interrupt spells to the Interrupt Bar."], L["Interrupt spell types are automatically added to this bar."])
				or format("%s\n\n|cffffd200%s", L["Move your group's Raid Cooldowns to the Raid Bar."], L["Select the spells you want to move from the \'Raid CD\' tab. The spell must be enabled from the \'Spells\' tab first."])
			end,
			order = 1,
			type = "toggle",
		},
		locked = {
			name = LOCK_FRAME,
			desc = L["Lock frame position"],
			order = 2,
			type = "toggle",
		},
		layoutSettings = {
			name = L["Layout"],
			type = "group",
			inline = true,
			order = 10,
			args = {
				spellType = {
					disabled = function(info)
						return not E.profile.Party[ info[2] ].extraBars[ info[4] ].enabled or info[4] == "raidBar0"
					end,
					name = L["Spell Types"],
					desc = format("|cffff2020[%s]|r %s", L["Multiselect"], L["Select the spell types you want to display on this column."]),
					order = 1,
					type = "multiselect",
					dialogControl = "Dropdown-OmniCD",
					values = E.L_PRIORITY,
					get = function(info, k) return E.DB.profile.Party[ info[2] ].extraBars[ info[4] ].spellType[k] end,
					set = function(info, k, state)
						local key = info[2]
						for bar in pairs(P.extraBars) do
							E.DB.profile.Party[key].extraBars[bar].spellType[k] = state and bar == info[4]
						end
						if P:IsCurrentZone(key) then
							P:UpdateEnabledSpells()
							P:Refresh()
						end
					end,
					disabledItem = function() return "interrupt" end,
				},
				layout = {
					name = L["Layout"],
					desc = L["Select the icon layout"],
					order = 2,
					type = "select",
					values = {
						horizontal = L["Horizontal"],
						vertical = L["Vertical"],
					},
				},
				sortBy = {
					name = E.STR.WHATS_NEW_ESCSEQ .. COMPACT_UNIT_FRAME_PROFILE_SORTBY,
					desc = function(info)
						return info[4] == "raidBar0" and interruptBarSortByDesc or raidBarSortByDesc
					end,
					order = 3,
					type = "select",
					values = function(info)
						return sortByValues[ info[4] ] or sortByValues.raidBar1
					end,
				},
				sortDirection = {
					name = L["Sort Direction"],
					order = 4,
					type = "select",
					values = {
						asc = L["Ascending"],
						dsc = L["Descending"],
					}
				},
				lb1 = {
					name = "", order = 5, type = "description"
				},
				columns = {
					name = function(info)
						return E.profile.Party[ info[2] ].extraBars[ info[4] ].layout == "horizontal"
						and L["Column"] or L["Row"]
					end,
					desc = function(info)
						return E.profile.Party[ info[2] ].extraBars[ info[4] ].layout == "horizontal"
						and L["Set the number of icons per row"] or L["Set the number of icons per column"]
					end,
					order = 6,
					type = "range",
					min = 1, max = 100, softMax = 30, step = 1,
				},
				paddingX = {
					name = L["Padding X"],
					desc = L["Set the padding space between icon columns"],
					order = 7,
					type = "range",
					min = -5, max = 100, softMin = -1, softMax = 20, step = 1,
				},
				paddingY = {
					name = L["Padding Y"],
					desc = L["Set the padding space between icon rows"],
					order = 8,
					type = "range",
					min = -5, max = 100, softMin = -1, softMax = 20, step = 1,
				},
				lb2 = {
					name = "", order = 9, type = "description"
				},
				growUpward = {
					name = L["Grow Rows Upward"],
					desc = L["Toggle the grow direction of icon rows"],
					order = 10,
					type = "toggle",
				},
				growLeft = {
					name = L["Grow Columns Left"],
					desc = L["Toggle the grow direction of icon columns"],
					order = 11,
					type = "toggle",
				},
			}
		},
		iconSettings = {
			name = L["Icon"],
			type = "group",
			inline = true,
			order = 20,
			args = {
				scale = {
					name = L["Icon Size"],
					desc = L["Set the size of icons"],
					order = 1,
					type = "range",
					min = 0.2, max = 2.0, step = 0.01, isPercent = true,
				},
				showName = {
					disabled = isEnabledProgressBar,
					name = L["Show Name"],
					desc = L["Show name on icons"],
					order = 2,
					type = "toggle",
				},
				nameOfsY = {
					name = E.STR.WHATS_NEW_ESCSEQ .. L["Name Offset Y"],
					order = 3,
					type = "range",
					min = -20, max = 50, step = 1,
				},
				truncateIconName = {
					disabled = function(info) return not E.profile.Party[ info[2] ].extraBars[ info[4] ].showName or isEnabledProgressBar(info) end,
					name = L["Truncate Name"],
					desc = L["Adjust value until the truncate symbol [...] disappears.\n|cffff20200: Disable option"],
					order = 4,
					type = "range",
					min = 0, max = 20, step = 1,
				},
			}
		},
		progressBar = {
			disabled = function(info)
				local db = E.profile.Party[ info[2] ].extraBars[ info[4] ]
				return not db.enabled or not db.progressBar or db.layout == "horizontal"
			end,
			name = L["Status Bar Timer"],
			order = 30,
			type = "group",
			inline = true,
			args = {
				progressBar = {
					disabled = function(info)
						local db = E.profile.Party[ info[2] ].extraBars[ info[4] ]
						return not db.enabled or db.layout == "horizontal"
					end,
					name = ENABLE,
					desc = L["Replace default timers with a status bar timer."],
					order = 1,
					type = "toggle",
				},
				lb1 = {
					name = "", order = 2, type = "description"
				},
				colField = {
					name = "",
					order = 3,
					type = "group",
					inline = true,
					args = {
						lb0 = { name = "", order = 0, type = "description", width = 0.5 },
						lb1 = { name = L["Active"], order = 1, type = "description", width = 0.5 },
						lb2 = { name = L["Recharge"], order = 2, type = "description", width = 0.5 },
						lb3 = { name = L["Inactive"], order = 3, type = "description", width = 0.5 },
						lb4 = { name = format("%s (%s)", CLASS_COLORS, L["Multiselect"]),
							order = 4, type = "description", width = 1 },
					}
				},
				textColors = {
					name = "",
					order = 4,
					type = "group",
					inline = true,
					get = getColor,
					set = setColor,
					args = progressBarColorInfo,
				},
				barColors = {
					disabled = isDisabledProgressBarOrNameBar,
					name = "",
					order = 5,
					type = "group",
					inline = true,
					get = getColor,
					set = setColor,
					args = progressBarColorInfo,
				},
				bgColors = {
					disabled = isDisabledProgressBarOrNameBar,
					name = "",
					order = 6,
					type = "group",
					inline = true,
					get = getColor,
					set = setColor,
					args = progressBarColorInfo,
				},
				lb2 = {
					name = "\n\n", order = 7, type = "description"
				},
				nameBar = {
					name = L["Convert to Name Bar"],
					desc = L["Convert the status bar timer to a simple name display by disabling all timer functions. The \'Name\' color scheme will be retained."],
					order = 8,
					type = "toggle",
				},
				invertNameBar = {
					disabled = function(info)
						local db = E.profile.Party[ info[2] ].extraBars[ info[4] ]
						return not db.enabled or not db.progressBar or db.layout == "horizontal" or not db.nameBar
					end,
					name = L["Invert Name Bar"],
					desc = L["Attach Name Bar to the left of icon"],
					order = 9,
					type = "toggle",
				},
				useIconAlpha = {
					name = E.STR.WHATS_NEW_ESCSEQ .. L["Use Icon Alpha"],
					desc = L["Apply \'Icons\' alpha settings to the status bar"],
					order = 10,
					type = "toggle",
				},
				reverseFill = {
					disabled = isDisabledProgressBarOrNameBar,
					name = L["Reverse Fill"],
					desc = L["Timer will progress from right to left"],
					order = 11,
					type = "toggle",
				},
				hideSpark = {
					disabled = isDisabledProgressBarOrNameBar,
					name = L["Hide Spark"],
					desc = L["Hide the leading spark texture."],
					order = 12,
					type = "toggle",
				},
				hideBorder = {
					disabled = isDisabledProgressBarOrNameBar,
					name = L["Hide Border"],
					desc = L["Hide status bar border"],
					order = 13,
					type = "toggle",
				},
				showInterruptedSpell = {
					hidden = function(info)
						return E.preCata or isRaidCDBar(info)
					end,
					disabled = isDisabledProgressBarOrNameBar,
					name = L["Interrupted Spell Icon"],
					desc = format("%s\n\n|cffff2020%s",
					L["Show the interrupted spell icon."],
					L["Mouseovering the icon will show the interrupted spell information regardless of \'Show Tooltip\' option."]),
					order = 14,
					type = "toggle",
				},
				showRaidTargetMark = {
					hidden = function(info)
						return E.preCata or isRaidCDBar(info)
					end,
					disabled = isDisabledProgressBarOrNameBar,
					name = L["Interrupted Target Marker"] .. E.RAID_TARGET_MARKERS[1],
					desc = L["Show the interrupted unit's target marker if it exists."],
					order = 15,
					type = "toggle",
				},
				lb3 = {
					name = "\n", order = 16, type = "description"
				},
				statusBarWidth = {
					name = L["Bar width"],
					desc = format("%s\n\n%s", L["Set the status bar width. Adjust height with \'Icon Size\'."], E.STR.MAX_RANGE),
					order = 17,
					type = "range",
					min = 50, max = 999, softMax = 300, step = 1,
				},

				textOfsX = {
					name = L["Name Offset X"],
					order = 18,
					type = "range",
					min = 1, max = 30, step = 1,
				},
				textOfsY = {
					name = L["Name Offset Y"],
					order = 19,
					type = "range",
					min = -15, max = 15, step = 1,
				},
				truncateStatusBarName = {
					name = L["Truncate Name"],
					desc = L["Adjust value until the truncate symbol [...] disappears.\n|cffff20200: Disable option"],
					order = 20,
					type = "range",
					min = 0, max = 20, step = 1,
					get = function(info) return E.profile.Party[ info[2] ].extraBars[ info[4] ].truncateStatusBarName end,
					set = function(info, value)
						local key, bar = info[2], info[4]
						E.profile.Party[key].extraBars[bar].truncateStatusBarName = value
						if P:IsCurrentZone(key) then
							for _, icon in pairs(P.extraBars[bar].icons) do
								local name = P.groupInfo[icon.guid].name
								if value > 0 then
									name = string.utf8sub(name, 1, value)
								end
								local statusBar = icon.statusBar
								local castingBar = statusBar.CastingBar
								statusBar.name = name
								castingBar.name = name
								statusBar.Text:SetText(name)
								castingBar.Text:SetText(name)
							end
						end
					end,
				},
				textScale = {
					name = E.STR.WHATS_NEW_ESCSEQ .. L["Name Scale"],
					desc = format("%s\n\n%s", L["Set the Name Bar name scale"], L["The global font settings are in the General menu"]),
					order = 21,
					type = "range",
					min = 0.5, max = 1.0, step = 0.01, isPercent = true,
				},
			}
		},
		miscSettings = {
			name = MISCELLANEOUS,
			type = "group",
			inline = true,
			order = 40,
			args = {
				renameBar = {
					name = E.STR.WHATS_NEW_ESCSEQ .. L["Rename Bar"],
					order = 1,
					type = "input",
					get = function(info)
						local value = E.profile.Party[ info[2] ].extraBars[ info[4] ].name
						if not value then
							local index = strmatch(info[4], "%d$")
							value = index == "0" and L["Interrupts"] or index
						end
						return value
					end,
					set = function(info, value)
						local key, bar = info[2], info[4]
						if value == "" then
							local index = strmatch(bar, "%d$")
							value = index == "0" and L["Interrupts"] or index
						end
						E.profile.Party[key].extraBars[bar].name = value
						if P:IsCurrentZone(key) then
							local frame = P.extraBars[bar]
							local db = frame.db
							P:SetExAnchor(frame, db)
						end
					end,
				},
				reset = {
					name = RESET_POSITION,
					desc = L["Reset frame position"],
					order = 2,
					type = "execute",
					func = function(info)
						local key, bar = info[2], info[4]
						local frame = P.extraBars[bar]
						if frame then
							if E.profile.Party[key].extraBars[bar].manualPos[bar] then
								wipe(E.profile.Party[key].extraBars[bar].manualPos[bar])
							end
							if P:IsCurrentZone(key) then
								E.LoadPosition(frame)
							end
						end
					end,
					confirm = E.ConfirmAction,
				},
				resetBar = {
					name = RESET_TO_DEFAULT,
					desc = L["Reset current bar settings to default"],
					order = 3,
					type = "execute",
					func = function(info)
						local key, bar = info[2], info[4]
						E.profile.Party[key].extraBars[bar] = E:DeepCopy(C.Party[key].extraBars[bar])
						E:RefreshProfile()
					end,
					confirm = E.ConfirmAction,
				},
			}
		},
	}
}

local extraBars = {
	name = E.STR.WHATS_NEW_ESCSEQ .. L["Extra Bars"],
	type = "group",
	childGroups = "tab",
	order = 70,
	get = function(info) return E.profile.Party[ info[2] ].extraBars[ info[4] ][ info[#info] ] end,
	set = function(info, value)
		local key, bar, option = info[2], info[4], info[#info]
		E.profile.Party[key].extraBars[bar][option] = value

		if P:IsCurrentZone(key) then
			local frame = P.extraBars[bar]
			local db = frame.db
			if option == "locked" then
				P:SetExAnchor(frame, db)
			elseif option == "scale" then
				P:ConfigExSize(bar, true)
			elseif option == "enabled" then
				P:Refresh(true)
			else
				P:ConfigExBar(bar, option)
			end
		end
	end,
	args = {}
}

for i = 0, 8 do
	local bar = "raidBar" .. i
	extraBars.args[bar] = extraBarsInfo
end

function P:ConfigExBar(key, arg)
	local db_icon = E.db.icons
	local db = E.db.extraBars[key]
	local frame = self.extraBars[key]
	for i = 1, frame.numIcons do
		local icon = frame.icons[i]
		local statusBar = icon.statusBar
		if arg == "layout" or arg == "progressBar" then
			if db.layout == "vertical" and db.progressBar then
				statusBar = statusBar or self:GetStatusBar(icon, key)
				self:SetExBorder(icon, db)
				self:SetExStatusBarWidth(statusBar, db)
				self:SetExStatusBarColor(icon, key)
			elseif statusBar then
				self:RemoveStatusBar(statusBar)
				icon.statusBar = nil
			end
			self:SetExIconName(icon, db)
			self:SetOpacity(icon, db_icon, statusBar and not db.useIconAlpha)
		elseif arg == "useIconAlpha" then
			self:SetExStatusBarColor(icon, key)
			self:SetOpacity(icon, db_icon, statusBar and not db.useIconAlpha)
		elseif arg == "showName" or arg == "truncateIconName" or arg == "nameOfsY" then
			self:SetExIconName(icon, db)
		elseif arg == "barColors" or arg == "bgColors" or arg == "textColors" or arg == "reverseFill" or arg == "hideSpark" then
			self.CastingBarFrame_OnLoad(statusBar.CastingBar, db, icon)
			self:SetExStatusBarColor(icon, key)
		elseif arg == "statusBarWidth" or arg == "textOfsX" or arg == "textOfsY" or arg == "invertNameBar" or arg == "textScale" then
			self:SetExStatusBarWidth(statusBar, db)
		elseif arg == "hideBorder" then
			P:SetExBorder(icon, db)
		elseif arg == "nameBar" then
			self:SetExBorder(icon, db)
			self.CastingBarFrame_OnLoad(statusBar.CastingBar, db, icon)
			self:SetExStatusBarColor(icon, key)
			self:SetSwipeCounter(icon, db_icon)
			self:SetExStatusBarWidth(statusBar, db)
		end
	end

	local sortOrder = arg == "sortBy" or arg == "growUpward" or arg == "sortDirection" or arg == "layout" or arg == "growLeft"
	if sortOrder or arg == "progressBar" or arg == "columns" or arg == "paddingX" or arg == "paddingY"
		or arg == "statusBarWidth" or arg == "groupPadding" then
		self:UpdateExBarPositionValues()
		self:SetExIconLayout(key, sortOrder, true)
	end
end

local sliderTimer = {}

local updatePixelObj = function(key, frame, db, noDelay)
	P:UpdateExBarBackdrop(frame, db)
	P:UpdateExBarPositionValues()
	P:SetExIconLayout(key)
	P:SetExAnchor(frame, db)

	if not noDelay then
		sliderTimer[key] = nil
	end
end

function P:ConfigExSize(key, slider)
	local db = E.db.extraBars[key]
	local frame = self.extraBars[key]
	frame.container:SetScale(db.scale)

	if E.db.icons.displayBorder or (db.layout == "vertical" and db.progressBar) then
		if slider then
			if not sliderTimer[key] then
				sliderTimer[key] = E.TimerAfter(0.3, updatePixelObj, key, frame, db)
			end
		else
			updatePixelObj(key, frame, db, true)
		end
	end
end

P:RegisterSubcategory("extraBars", extraBars)
