---@type string
local AddonName = ...

---@class Private
local Private = select(2, ...)

function Private.Debug(data)
	if not Private.IsTestCharacter then
		return
	end

	if DevTool then
		DevTool:AddData(data)
	else
		print("DevTool not found or not loaded")
	end
end

---@key string
function Private.Print(key, ...)
	if Private.IsTestCharacter then
		if DevTool then
			DevTool:AddData(key, ...)
		else
			local colors = {
				["Provider"] = "FF525252",
				["Frame"] = "FFFF0000",
				["Tooltip"] = "FFFFD900",
				["Dropdown"] = "FF91FF00",
				["Init"] = "FF00FFC8",
			}

			print(Private.GetAddOnNameWithIcon(), (colors[key] and "[" .. WrapTextInColorCode(key, colors[key]) .. "]" or key), ...)
		end
	end
end

Private.Colors = {
	Artifact = "ffe5cc80",
	Astounding = "ffe268a8",
	Legendary = "ffff8000",
	Epic = "ffa335ee",
	Rare = "ff0070ff",
	Uncommon = "ff1eff00",
	Common = "FF9B9A9A",
	Archon = "00FF00DD",
	Brand = "FF2DA9C8",
	DeemphasizedText = "ff878787",
	White = "ffffffff",
}

---@param percentile number|nil
---@param content string|number|nil
function Private.EncodeWithPercentileColor(percentile, content)
	local color = Private.Colors.Common

	if percentile ~= nil then
		if percentile >= 100 then
			color = Private.Colors.Artifact
		elseif percentile >= 99 then
			color = Private.Colors.Astounding
		elseif percentile >= 95 then
			color = Private.Colors.Legendary
		elseif percentile >= 75 then
			color = Private.Colors.Epic
		elseif percentile >= 50 then
			color = Private.Colors.Rare
		elseif percentile >= 25 then
			color = Private.Colors.Uncommon
		end
	end

	return WrapTextInColorCode(content, color)
end

---@param texture string|number
---@return string
function Private.EncodeWithTexture(texture)
	if type(texture) == "number" then
		return string.format("|T%s:0|t", texture)
	end

	texture = string.lower(texture)
	texture = string.gsub(texture, ".blp", "")
	texture = string.gsub(texture, "/", "\\")
	texture = string.find(texture, "interface") == nil and string.format("interface\\icons\\%s", texture) or texture
	return string.format("|T%s:0|t", texture)
end

---@param addonName string
---@return string|nil
local function GetAddonIconTexture(addonName)
	local fn = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
	return fn(addonName, "IconTexture")
end

---@return string
function Private.GetAddOnNameWithIcon()
	local icon = GetAddonIconTexture(AddonName)
	return WrapTextInColorCode(icon and Private.EncodeWithTexture(icon) .. " " .. AddonName or AddonName, Private.Colors.Archon)
end

---@param percentile number
---@return string
function Private.FormatPercentile(percentile)
	return string.format("%.0f", percentile)
end

---@param percentile number
---@return string
function Private.FormatAveragePercentile(percentile)
	return string.format("%.1f", percentile)
end

---@param name string
---@param realmNameOrId string|number
---@param projectId number|nil
---@return string
function Private.GetProfileUrl(name, realmNameOrId, projectId)
	projectId = projectId or WOW_PROJECT_ID

	---@type string|nil
	local subdomain = nil
	if projectId == WOW_PROJECT_CLASSIC then
		subdomain = "sod"
	elseif projectId == WOW_PROJECT_WRATH_CLASSIC or projectId == WOW_PROJECT_CATACLYSM_CLASSIC then
		subdomain = "classic"
	end

	---@type table<number, string>
	local parts = {}

	local locale = GAME_LOCALE or GetLocale()

	if locale ~= "enUS" and Private.LocaleToSiteSubDomainMap[locale] ~= nil then
		parts[#parts + 1] = Private.LocaleToSiteSubDomainMap[locale]
		if subdomain then
			parts[#parts + 1] = subdomain
		end
	elseif subdomain ~= nil then
		parts[#parts + 1] = subdomain
	else
		parts[#parts + 1] = "www"
	end

	local subdomains = #parts == 1 and parts[1] or table.concat(parts, ".")
	local baseUrl = string.format("https://%s.warcraftlogs.com%s", subdomains, Private.CharacterBaseUrl)

	realmNameOrId = realmNameOrId or Private.CurrentRealm.name

	if type(realmNameOrId) == "string" then
		realmNameOrId = select(1, realmNameOrId:gsub("%s+", ""))

		for _, dataset in ipairs(Private.Realms) do
			if dataset.name == realmNameOrId then
				realmNameOrId = dataset.slug
				break
			end
		end
	else
		for id, dataset in ipairs(Private.Realms) do
			if id == realmNameOrId then
				realmNameOrId = dataset.slug
				break
			end
		end
	end

	return string.lower(string.format(baseUrl, Private.CurrentRealm.region, realmNameOrId, name))
end

---@param difficulty number
---@param size number
---@param zoneId number|nil
---@return string
function Private.GetDifficultyString(difficulty, size, zoneId)
	if Private.HasDifficulties == false then
		return ""
	end

	local translatedDifficulty = Private.L["Difficulty-" .. difficulty] or ""
	-- weekly data has no encounter ids and thus no zone id
	local zone = zoneId and Private.GetZoneById(zoneId) or nil
	local hasMultipleSizes = zone and zone.hasMultipleSizes or (Private.IsWrath or Private.IsCata)
	local difficultyIcon = zone and zone.difficultyIconMap and zone.difficultyIconMap[difficulty] or nil

	if difficultyIcon then
		translatedDifficulty = string.format("%s %s", Private.EncodeWithTexture(difficultyIcon), translatedDifficulty)
	end

	return hasMultipleSizes and string.format("%s%d", translatedDifficulty, size) or translatedDifficulty
end

---@param realm string|nil
---@return string|nil
function Private.GetRealmOrDefault(realm)
	-- in classic, party frames return an empty string as realm
	if (not realm or #realm == 0) and Private.CurrentRealm.name then
		return Private.CurrentRealm.name
	end

	return realm
end

local function ShowStaticPopupDialog(...)
	local id = "WARCRAFTLOGS_COPY_URL"

	if not StaticPopupDialogs[id] then
		StaticPopupDialogs[id] = {
			id = id,
			text = "%s",
			button2 = CLOSE,
			hasEditBox = true,
			hasWideEditBox = true,
			editBoxWidth = 350,
			preferredIndex = 3,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			OnShow = function(self)
				local editBox = _G[self:GetName() .. "WideEditBox"] or _G[self:GetName() .. "EditBox"]

				editBox:SetText(self.text.text_arg2)
				editBox:HighlightText()

				local ctrlDown = false

				editBox:SetScript("OnKeyDown", function(_, key)
					if key == "LCTRL" or key == "RCTRL" or key == "LMETA" or key == "RMETA" then
						ctrlDown = true
					end
				end)
				editBox:SetScript("OnKeyUp", function(_, key)
					C_Timer.After(0.2, function()
						ctrlDown = false
					end)

					if ctrlDown and (key == "C" or key == "X") then
						StaticPopup_Hide(id)
					end
				end)
			end,
			EditBoxOnEscapePressed = function(self)
				self:GetParent():Hide()
			end,
		}
	end

	return StaticPopup_Show(id, ...)
end

---@param info LeaderInfo
function Private.ShowCopyProfileUrlPopup(info)
	if info.name == nil then
		return
	end

	ShowStaticPopupDialog(info.name, Private.GetProfileUrl(info.name, info.realm, info.projectId))

	info.name = nil
	info.realm = nil
end

---@param realm string
---@returns boolean
function Private.SupportsLazyLoading(realm)
	return Private.IsClassicEra and Private.CurrentRealm ~= realm
end

---@type table<string, boolean>
local warnings = {}

---@param databaseKey string
---@param realmName string
---@returns boolean
function Private.LoadAddOn(databaseKey, realmName)
	local addonToLoad = string.format("%sDB_%s", AddonName, databaseKey)

	if (C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(addonToLoad)) or (IsAddOnLoaded and IsAddOnLoaded(addonToLoad)) then
		return true
	end

	if C_AddOns.DoesAddOnExist and not C_AddOns.DoesAddOnExist(addonToLoad) then
		local warning = string.format(Private.L.SubAddonMissing, Private.GetAddOnNameWithIcon(), databaseKey, realmName)

		if not warnings[warning] then
			warnings[warning] = true
			print(warning)
		end

		return false
	end

	local startTs = debugprofilestop()

	local fn = C_AddOns.LoadAddOn or LoadAddOn
	local loaded, reason = fn(addonToLoad, select(1, UnitName("player")))

	if not loaded then
		print(string.format(Private.L.DBLoadError, Private.GetAddOnNameWithIcon(), databaseKey, reason or Private.L.Unknown))
		return false
	end

	Private.Print(string.format("%s loaded %s in %s", "LoadAddOn", addonToLoad, string.format("%1.3f ms", debugprofilestop() - startTs)))

	return true
end

---@param realm string
---@returns string|nil
function Private.GetDatabaseKeyForRealm(realm)
	for _, realmInfo in pairs(Private.Realms) do
		if Private.CurrentRealm.region == realmInfo.region and realmInfo.name == realm then
			return realmInfo.database
		end
	end
end
