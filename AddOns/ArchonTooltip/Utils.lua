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
		if percentile >= 99.95 then
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
		local season = C_Seasons.GetActiveSeason()
		if season == Enum.SeasonID.SeasonOfDiscovery then
			subdomain = "sod"
		elseif season == Enum.SeasonID.Fresh then
			subdomain = "fresh"
		end
	elseif projectId == WOW_PROJECT_WRATH_CLASSIC or projectId == WOW_PROJECT_CATACLYSM_CLASSIC or projectId == WOW_PROJECT_MISTS_CLASSIC then
		subdomain = "classic"
	elseif projectId == WOW_PROJECT_BURNING_CRUSADE_CLASSIC and C_Seasons.GetActiveSeason() == 125 then
		subdomain = "fresh"
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

---@param zoneId number
---@param difficultyId number
---@param sizeId number
---@param progressKilled number
---@param progressPossible number
---@param isShort boolean
---@return string
function Private.GetProgressString(zoneId, difficultyId, sizeId, progressKilled, progressPossible, isShort)
	local progress = string.format("%d/%d", progressKilled, progressPossible)

	local zone = Private.GetZoneById(zoneId)
	local difficultyAndSize = ""

	if not isShort and zone and zone.difficultyIconMap ~= nil then
		local difficultyIcon = zone.difficultyIconMap[difficultyId]
		if difficultyIcon then
			difficultyAndSize = string.format("%s %s", difficultyAndSize, Private.EncodeWithTexture(difficultyIcon))
		end
	end

	if zone and zone.hasMultipleDifficulties then
		difficultyAndSize = string.format("%s%s", difficultyAndSize, Private.L["Difficulty-" .. difficultyId] or "")
	end

	if not isShort and zone and zone.hasMultipleSizes then
		difficultyAndSize = string.format(" %s%d", difficultyAndSize, sizeId)
	end

	return string.format("%s%s", progress, difficultyAndSize)
end

---@param realm string|nil
---@return string|nil
function Private.GetRealmOrDefault(realm)
	-- in classic, party frames return an empty string as realm
	if (not realm or #realm == 0) and Private.CurrentRealm.name then
		return Private.CurrentRealm.name
	end

	if realm then
		return select(1, string.gsub(realm, "%s+", ""))
	end

	return nil
end

local function ShowStaticPopupDialog(...)
	local id = "WARCRAFTLOGS_COPY_URL"

	if not StaticPopupDialogs[id] then
		local lastOnShowText = ""

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

				if editBox.GetOwningDialog then
					lastOnShowText = editBox:GetOwningDialog().Text.text_arg2
				else
					lastOnShowText = self.text.text_arg2
				end

				editBox:SetText(lastOnShowText)
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
			EditBoxOnTextChanged = function(self)
				-- ctrl + x sets the text to "" but this triggers hiding and shouldn't trigger resetting the text
				local currentText = self:GetText()

				if currentText == "" or currentText == lastOnShowText then
					return
				end

				self:SetText(lastOnShowText)
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

Private.AddOnUtils = {
	RaiderIoLoaded = false,
	---@param name string
	---@return boolean
	IsAddOnLoaded = function(name)
		if C_AddOns and C_AddOns.IsAddOnLoaded then
			return select(1, C_AddOns.IsAddOnLoaded(name))
		end

		return select(1, IsAddOnLoaded(name))
	end,
	---@param name string
	---@return boolean
	DoesAddOnExist = function(name)
		if C_AddOns and C_AddOns.DoesAddOnExist then
			return C_AddOns.DoesAddOnExist(name)
		end

		return true
	end,
	---@param name string
	---@return boolean?, string?
	LoadAddOn = function(name)
		if C_AddOns and C_AddOns.LoadAddOn then
			return C_AddOns.LoadAddOn(name)
		end

		return LoadAddOn(name)
	end,
}

---@type table<string, boolean>
local warnings = {}

---@param databaseKey string
---@param realmName string
---@returns boolean
function Private.LoadAddOn(databaseKey, realmName)
	local addonToLoad = string.format("%sDB_%s", AddonName, databaseKey)

	if Private.AddOnUtils.IsAddOnLoaded(addonToLoad) then
		return true
	end

	if not Private.AddOnUtils.DoesAddOnExist(addonToLoad) then
		local warning = string.format(Private.L.SubAddonMissing, Private.GetAddOnNameWithIcon(), databaseKey, realmName)

		if not warnings[warning] then
			warnings[warning] = true
			print(warning)
		end

		return false
	end

	local startTs = debugprofilestop()

	local loaded, reason = Private.AddOnUtils.LoadAddOn(addonToLoad, select(1, UnitName("player")))

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

--- the utf8 global is not available, so we polyfill utf8.offset so we can correctly find prefixes of utf8 strings
---@param str string
---@param index number
---@return number|nil
function Private.Utf8Offset(str, index)
	local len = #str

	if index <= 0 or index > len then
		return nil -- Out of bounds
	end

	-- Move forward to the nth character
	local count = 0
	for i = 1, len do
		local byte = string.byte(str, i)
		local isContinuationByte = byte >= 128 and byte < 192
		if not isContinuationByte then
			count = count + 1
			if count == index then
				return i
			end
		end
	end

	return nil -- If the nth character is not found
end
