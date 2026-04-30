---@diagnostic disable: undefined-global

-- 本地化引擎挂在独立全局表 ExwindLocale 上
-- 不依赖 _G.ExwindTools（它在 ExwindTools.lua 里才会被 addonTable 覆盖）
-- ExwindTools.lua 启动后会执行: ExwindTools.L = ExwindLocale.GetProxy()

ExwindLocale = ExwindLocale or {}

local Locale = ExwindLocale

Locale._appName    = "ExwindTools"
Locale._defaultLocale = Locale._defaultLocale or "zhCN"
Locale._stores        = Locale._stores or {}

local function NormalizeLocaleTag(tag)
    local locale = tostring(tag or ""):gsub("%s+", "")
    if locale == "enGB" then return "enUS" end
    return locale ~= "" and locale or "zhCN"
end

local function NormalizeLocaleMode(mode)
    local value = tostring(mode or ""):gsub("%s+", "")
    if value == "zhCN" or value == "enUS" then
        return value
    end
    return "AUTO"
end

local function GetSavedLocaleMode()
    local db = rawget(_G, "ExwindToolsDB")
    if type(db) == "table" and type(db.Locale) == "table" then
        return NormalizeLocaleMode(db.Locale.mode)
    end
    return "AUTO"
end

function Locale.GetClientLocale()
    return NormalizeLocaleTag(GetLocale and GetLocale() or Locale._defaultLocale)
end

function Locale.ResolveLocale(mode)
    local localeMode = NormalizeLocaleMode(mode)
    if localeMode == "AUTO" then
        return Locale.GetClientLocale()
    end
    return NormalizeLocaleTag(localeMode)
end

Locale._mode = GetSavedLocaleMode()
Locale._currentLocale = Locale.ResolveLocale(Locale._mode)

local function EnsureStore(locale)
    locale = NormalizeLocaleTag(locale)
    if not Locale._stores[locale] then
        Locale._stores[locale] = {}
    end
    return Locale._stores[locale]
end

-- 创建某语言的写入代理，供 zhCN.lua / enUS.lua 使用
function Locale.NewLocale(locale, isDefault)
    locale = NormalizeLocaleTag(locale)
    local store = EnsureStore(locale)
    if isDefault == true then
        Locale._defaultLocale = locale
    end
    return setmetatable({}, {
        __newindex = function(_, key, value)
            if type(key) ~= "string" or key == "" then return end
            store[key] = (value == true or value == nil) and key or tostring(value)
        end,
        __index = function(_, key)
            return store[key]
        end,
    })
end

-- L[] 查询代理（始终读 Locale._stores，不依赖 ExwindTools）
Locale._proxy = Locale._proxy or setmetatable({}, {
    __index = function(_, key)
        if type(key) ~= "string" or key == "" then return key end
        local cur = Locale._stores[Locale._currentLocale]
        if type(cur) == "table" and cur[key] ~= nil then return cur[key] end
        local def = Locale._stores[Locale._defaultLocale]
        if type(def) == "table" and def[key] ~= nil then return def[key] end
        return key -- fallback: 直接返回 key 本身（通常就是中文原文）
    end,
})

-- 供 ExwindTools.lua 调用：把代理接入 addonTable
function Locale.GetProxy()
    return Locale._proxy
end

function Locale.GetCurrentLocale()
    return Locale._currentLocale
end

function Locale.GetLocaleMode()
    return Locale._mode or "AUTO"
end

function Locale.SetCurrentLocale(locale)
    Locale._currentLocale = NormalizeLocaleTag(locale)
    return Locale._currentLocale
end

function Locale.SetLocaleMode(mode)
    Locale._mode = NormalizeLocaleMode(mode)
    Locale._currentLocale = Locale.ResolveLocale(Locale._mode)
    return Locale._currentLocale
end
