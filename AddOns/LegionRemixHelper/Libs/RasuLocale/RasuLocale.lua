---@class RasuLocale
local lib = LibStub:NewLibrary("RasuLocale", 1)
if not lib then return end

---@alias WOWLocale
---| "enUS" # English (US)
---| "koKR" # Korean
---| "frFR" # French
---| "deDE" # German
---| "zhCN" # Chinese (Simplified)
---| "esES" # Spanish (Spain)
---| "zhTW" # Chinese (Traditional)
---| "esMX" # Spanish (Mexico)
---| "ruRU" # Russian
---| "ptBR" # Portuguese (Brazil)
---| "itIT" # Italian

---@class RasuLocaleObject : RasuLocaleMixin

---@class RasuLocaleMixin
local localeMixin = {
    ---@type any
    identifier = nil,
    ---@type table<WOWLocale, table<any, string>>
    translations = {},
    ---@type WOWLocale
    selectedLocale = "enUS",
    ---@type WOWLocale
    fallbackLocale = "enUS",
}

---@param locale WOWLocale
function localeMixin:SetLocale(locale)
    self.selectedLocale = locale
end

---@return WOWLocale selectedLocale
function localeMixin:GetLocale()
    return self.selectedLocale
end

---@param locale WOWLocale
function localeMixin:SetFallbackLocale(locale)
    self.fallbackLocale = locale
end

---@return WOWLocale fallbackLocale
function localeMixin:GetFallbackLocale()
    return self.fallbackLocale
end

---@param locale WOWLocale
---@param key any
---@param value string
function localeMixin:AddTranslation(locale, key, value)
    if not self.translations[locale] then
        self.translations[locale] = {}
    end
    self.translations[locale][key] = value
end

---@param locale WOWLocale
---@param tbl table<any, string>
function localeMixin:AddTranslationTbl(locale, tbl)
    for key, value in pairs(tbl) do
        self:AddTranslation(locale, key, value)
    end
end

---@param tbl table<WOWLocale, table<any, string>>
function localeMixin:AddFullTranslationTbl(tbl)
    for locale, translations in pairs(tbl) do
        self:AddTranslationTbl(locale, translations)
    end
end

---@param key any
---@return string translation
function localeMixin:GetTranslation(key)
    local translations = self.translations[self:GetLocale()]
    if not translations then
        translations = self.translations[self:GetFallbackLocale()] or {}
    end
    return translations[key] or tostring(key)
end

---@return table<any, string> translationObj
function localeMixin:GetTranslationObj()
    return setmetatable({}, {
        __index = function(_, key)
            return self:GetTranslation(key)
        end
    })
end

lib.registeredLocales = lib.registeredLocales or {}

---@param identifier any
---@return RasuLocaleObject locale
function lib:CreateLocale(identifier)
    if self.registeredLocales[identifier] then
        return self.registeredLocales[identifier]
    end

    local locale = setmetatable({}, { __index = localeMixin })
    locale.identifier = identifier

    self.registeredLocales[identifier] = locale
    return locale
end

---@param identifier any
---@param createIfMissing boolean
---@return RasuLocaleObject|nil locale
function lib:GetLocale(identifier, createIfMissing)
    local locale = self.registeredLocales[identifier]
    if not locale and createIfMissing then
        locale = self:CreateLocale(identifier)
    end
    return locale
end