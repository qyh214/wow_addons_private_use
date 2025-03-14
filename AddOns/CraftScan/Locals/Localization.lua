local CraftScan = select(2, ...)

CraftScan.LOCAL = {}
CraftScan.LOCAL.LOCAL_CLIENT = {}
CraftScan.LOCAL.LOCAL_EN = {}

function CraftScan.LOCAL:Init()
    local currentLocale = GetLocale()
    CraftScan.LOCAL.LOCAL_EN = CraftScan.LOCAL_EN:GetData() -- always load english locals for fallback translations
    if currentLocale == CraftScan.CONST.LOCALES.EN then
        CraftScan.LOCAL.LOCAL_CLIENT = CraftScan.LOCAL.LOCAL_EN
    elseif currentLocale == CraftScan.CONST.LOCALES.DE then
        CraftScan.LOCAL.LOCAL_CLIENT = CraftScan.LOCAL_DE:GetData()
    elseif currentLocale == CraftScan.CONST.LOCALES.IT then
        CraftScan.LOCAL.LOCAL_CLIENT = CraftScan.LOCAL_IT:GetData()
    elseif currentLocale == CraftScan.CONST.LOCALES.RU then
        CraftScan.LOCAL.LOCAL_CLIENT = CraftScan.LOCAL_RU:GetData()
    elseif currentLocale == CraftScan.CONST.LOCALES.PT then
        CraftScan.LOCAL.LOCAL_CLIENT = CraftScan.LOCAL_PT:GetData()
    elseif currentLocale == CraftScan.CONST.LOCALES.ES then
        CraftScan.LOCAL.LOCAL_CLIENT = CraftScan.LOCAL_ES:GetData()
    elseif currentLocale == CraftScan.CONST.LOCALES.FR then
        CraftScan.LOCAL.LOCAL_CLIENT = CraftScan.LOCAL_FR:GetData()
    elseif currentLocale == CraftScan.CONST.LOCALES.MX then
        CraftScan.LOCAL.LOCAL_CLIENT = CraftScan.LOCAL_MX:GetData()
    elseif currentLocale == CraftScan.CONST.LOCALES.KO then
        CraftScan.LOCAL.LOCAL_CLIENT = CraftScan.LOCAL_KO:GetData()
    elseif currentLocale == CraftScan.CONST.LOCALES.TW then
        CraftScan.LOCAL.LOCAL_CLIENT = CraftScan.LOCAL_TW:GetData()
    elseif currentLocale == CraftScan.CONST.LOCALES.CN then
        CraftScan.LOCAL.LOCAL_CLIENT = CraftScan.LOCAL_CN:GetData()
    else
        error("CraftScan Error: Client not supported: " .. tostring(currentLocale))
    end
end

-- Swap this with the real implementation so anything not localized will stand
-- out as not ~'s.
--[[
---@param ID CraftScan.LOCALIZATION_IDS
function CraftScan.LOCAL:GetText(ID)
    local result = CraftScan.LOCAL.LOCAL_EN[ID]
    if result then
        return string.rep("~", #result)
    end
    return nil;
end
]]

function CraftScan.LOCAL:GetText(ID)
    local localizedText = CraftScan.LOCAL.LOCAL_CLIENT[ID]

    if not localizedText then
        local englishtext = CraftScan.LOCAL.LOCAL_EN[ID]
        return englishtext or ID; -- default to english
    else
        return localizedText
    end
end

CraftScan.LOCAL:Init();
