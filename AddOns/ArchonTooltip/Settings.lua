---@type string, Private
local AddonName, Private = ...

table.insert(Private.LoginFnQueue, function()
	local settingsName = "Archon Tooltip"

	local function OpenSettings() end

	if Settings and Settings.RegisterAddOnCategory and Settings.RegisterVerticalLayoutCategory then
		local category = Settings.RegisterVerticalLayoutCategory(settingsName)

		do
			local function GetValue()
				return Private.db.Settings.ShowTooltipInCombat
			end

			local function SetValue(value)
				Private.db.Settings.ShowTooltipInCombat = value
				ArchonTooltipSaved.Settings.ShowTooltipInCombat = value

				if value == false and Private.db.Settings.AllowShiftExpansionInCombat then
					Private.db.Settings.AllowShiftExpansionInCombat = value
					ArchonTooltipSaved.Settings.AllowShiftExpansionInCombat = value
					Settings.SetValue("ALLOW_EXPAND_IN_COMBAT", value)
				end
			end

			local setting =
				Settings.RegisterProxySetting(category, "DISPLAY_TOOLTIP_IN_COMBAT", Settings.VarType.Boolean, Private.L.ShowTooltipInCombat, Settings.Default.False, GetValue, SetValue)

			Settings.CreateCheckbox(category, setting, Private.L.ShowTooltipInCombatDescription)
		end

		do
			local function GetValue()
				return Private.db.Settings.AllowShiftExpansionInCombat
			end

			local function SetValue(value)
				if value then
					Settings.SetValue("DISPLAY_TOOLTIP_IN_COMBAT", true)
				end
				Private.db.Settings.AllowShiftExpansionInCombat = value
				ArchonTooltipSaved.Settings.AllowShiftExpansionInCombat = value
			end

			local setting = Settings.RegisterProxySetting(
				category,
				"ALLOW_EXPAND_IN_COMBAT",
				Settings.VarType.Boolean,
				Private.L.AllowShiftExpansionInCombat,
				Settings.Default.False,
				GetValue,
				SetValue
			)

			Settings.CreateCheckbox(category, setting, Private.L.AllowShiftExpansionInCombatDescription)
		end

		do
			local function GetValue()
				return Private.db.Settings.ShowRank
			end

			local function SetValue(value)
				Private.db.Settings.ShowRank = value
				ArchonTooltipSaved.Settings.ShowRank = value
			end

			local setting = Settings.RegisterProxySetting(category, "RANK_VISIBILITY", Settings.VarType.Boolean, Private.L.ShowRank, Settings.Default.False, GetValue, SetValue)

			Settings.CreateCheckbox(category, setting, Private.L.ShowRankDescription)
		end

		do
			local function GetValue()
				return Private.db.Settings.ShowAsp
			end

			local function SetValue(value)
				Private.db.Settings.ShowAsp = value
				ArchonTooltipSaved.Settings.ShowAsp = value
			end

			local setting = Settings.RegisterProxySetting(category, "ASP_VISIBILITY", Settings.VarType.Boolean, Private.L.ShowAsp, Settings.Default.False, GetValue, SetValue)

			Settings.CreateCheckbox(category, setting, Private.L.ShowAspDescription)
		end

		do
			local function GetValue()
				return Private.db.Settings.ShowShiftHint
			end

			local function SetValue(value)
				Private.db.Settings.ShowShiftHint = value
				ArchonTooltipSaved.Settings.ShowShiftHint = value
			end

			local setting = Settings.RegisterProxySetting(category, "SHIFT_HINT_VISIBILITY", Settings.VarType.Boolean, Private.L.ShowShiftHint, Settings.Default.True, GetValue, SetValue)

			Settings.CreateCheckbox(category, setting, Private.L.ShowShiftHintDescription)
		end

		do
			local function GetValue()
				return Private.db.Settings.MenuDropdownIntegration
			end

			local function SetValue(value)
				Private.db.Settings.MenuDropdownIntegration = value
				ArchonTooltipSaved.Settings.MenuDropdownIntegration = value
			end

			local setting = Settings.RegisterProxySetting(category, "MENU_INTEGRATION", Settings.VarType.Boolean, Private.L.MenuIntegration, Settings.Default.True, GetValue, SetValue)

			Settings.CreateCheckbox(category, setting, Private.L.MenuIntegrationDescription)
		end

		Settings.RegisterAddOnCategory(category)

		OpenSettings = function()
			Settings.OpenToCategory(category.ID)
		end
	end

	if AddonCompartmentFrame then
		AddonCompartmentFrame:RegisterAddon({
			text = settingsName,
			icon = C_AddOns.GetAddOnMetadata(AddonName, "IconTexture"),
			registerForAnyClick = true,
			notCheckable = true,
			func = OpenSettings,
			funcOnEnter = function()
				if MenuUtil and MenuUtil.ShowTooltip then
					MenuUtil.ShowTooltip(AddonCompartmentFrame, function(tooltip)
						GameTooltip:SetText(settingsName, 1, 1, 1)
						GameTooltip:AddLine(Private.L.ClickToOpenSettings)
					end)
				else
					GameTooltip:SetOwner(AddonCompartmentFrame, "ANCHOR_LEFT")
					GameTooltip:SetText(AddonName, 1, 1, 1)
					GameTooltip:AddLine(Private.L.ClickToOpenSettings)
					GameTooltip:Show()
				end
			end,
			funcOnLeave = function()
				if MenuUtil.HideTooltip then
					MenuUtil.HideTooltip(AddonCompartmentFrame)
				else
					GameTooltip:Hide()
				end
			end,
		})
	end

	local uppercased = string.upper(AddonName)
	local lowercased = string.lower(AddonName)

	SlashCmdList[uppercased] = function(message)
		local command, rest = message:match("^(%S+)%s*(.*)$")

		if command == "options" or command == "settings" then
			OpenSettings()
		elseif command == "lookup" then
			local name, realmParts = rest:match("^(%S+)%s+(.*)$")

			if not name or not realmParts then
				local lines = {
					Private.GetAddOnNameWithIcon(),
					string.format(Private.L.SettingsLookupUsage, lowercased),
				}
				print(table.concat(lines, "\n"))

				return
			end

			---@param str string
			---@returns string
			local function Capitalize(str)
				return (str:gsub("(%a)([%w_']*)", function(first, remaining)
					return first:upper() .. remaining:lower()
				end))
			end

			name = Capitalize(name)
			local realm = Capitalize(realmParts)

			local profile = Private.GetProfile(name, realm)

			if profile == nil then
				local lines = {
					string.format(
						Private.L.SettingsLookupDataFor,
						Private.GetAddOnNameWithIcon(),
						Private.EncodeWithPercentileColor(100, name),
						Private.EncodeWithPercentileColor(100, realm)
					),
					Private.L.SettingsLookupNoData,
				}

				print(table.concat(lines, "\n"))
				return
			end

			local lines = {
				string.format(Private.L.SettingsLookupDataFor, Private.GetAddOnNameWithIcon(), Private.EncodeWithPercentileColor(100, name), Private.EncodeWithPercentileColor(100, realm)),
			}

			local profileLines = Private.GetProfileLines(profile)
			table.insert(lines, table.concat(profileLines, "\n"))

			print(table.concat(lines, "\n"))
		else
			local lines = {
				Private.GetAddOnNameWithIcon(),
				Private.L.SettingsAvailableCommands,
				string.format("/%s settings - %s", lowercased, Private.L.SettingsOpenSettingsLabel),
				string.format("/%s lookup <name> <realm> - %s", lowercased, Private.L.SettingsLookupLabel),
			}

			print(table.concat(lines, "\n"))
		end
	end

	_G[string.format("SLASH_%s1", uppercased)] = string.format("/%s", lowercased)
end)
