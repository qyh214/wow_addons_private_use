---@type string, Addon
local _, addon = ...

---@class Localization
local L = {}
addon.L = L

local locale = GetLocale()
local strings = {}

-- Default locale (English)
local defaultStrings = {}

-- Registry of all locale strings keyed by locale code
local registry = {}

local localeDisplayNames = {
	["enUS"] = "English",
	["enGB"] = "English",
	["deDE"] = "Deutsch",
	["esES"] = "Español",
	["esMX"] = "Español (México)",
	["frFR"] = "Français",
	["itIT"] = "Italiano",
	["ptBR"] = "Português",
	["koKR"] = "한국어",
	["ruRU"] = "Русский",
	["zhCN"] = "简体中文",
	["zhTW"] = "繁體中文",
}

-- Register a locale's strings for later activation
function L:RegisterLocale(localeKey, stringTable)
	registry[localeKey] = stringTable
end

-- Apply a registered locale as the active strings
function L:ApplyLocale(localeKey)
	wipe(strings)
	locale = localeKey

	local registered = registry[localeKey]
	if registered then
		for key, value in pairs(registered) do
			strings[key] = value
		end
	end
end

-- Return all registered locale codes with display names
function L:GetAvailableLocales()
	local result = {}
	for key in pairs(registry) do
		table.insert(result, { Key = key, Name = localeDisplayNames[key] or key })
	end
	table.sort(result, function(a, b)
		return a.Name < b.Name
	end)
	return result
end

-- Set a localized string
function L:SetString(key, value)
	strings[key] = value
end

-- Set multiple localized strings at once
function L:SetStrings(stringTable)
	for key, value in pairs(stringTable) do
		strings[key] = value
	end
end

-- Set default strings (English)
function L:SetDefaultStrings(stringTable)
	for key, value in pairs(stringTable) do
		defaultStrings[key] = value
	end
end

-- Get a localized string, falling back to English if not found
function L:Get(key)
	return strings[key] or defaultStrings[key] or key
end

-- Convenience metatable for easier access: L["key"] instead of L:Get("key")
setmetatable(L, {
	__index = function(t, key)
		if type(key) == "string" then
			return strings[key] or defaultStrings[key] or key
		end
		return rawget(t, key)
	end,
})

-- Return current locale
function L:GetLocale()
	return locale
end

function L:GetDisplayName(localeKey)
	return localeDisplayNames[localeKey] or localeKey
end
