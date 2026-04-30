local _, D4 = ...
local missingTranslationsEn = {}
local missingTranslations = {}
local missingLang = {}
local langs = {}
langs["enUS"] = true
langs["deDE"] = true
langs["esES"] = true
langs["esMX"] = true
langs["frFR"] = true
langs["itIT"] = true
langs["koKR"] = true
langs["ptBR"] = true
langs["ruRU"] = true
langs["zhCN"] = true
langs["zhTW"] = true
function D4:TryTrans(key, lang, ...)
    if key == nil then return "" end
    if key:find("LID_") then return D4:Trans(key, lang, ...) end

    return key
end

function D4:Trans(key, lang, ...)
    D4.trans = D4.trans or {}
    if lang == nil then
        lang = GetLocale()
    end

    if key and strfind(key, "LID_", 1, true) == nil then
        D4:INFO("[D4]", key)

        return key
    end

    if langs[lang] == nil then
        missingLang[lang] = true
        local ver = "MISSING"
        if D4.GetVersion then
            ver = D4:GetVersion()
        end

        D4:MSG("[GET] LANGUAGE IS MISSING [" .. lang .. "]", ver, "(", ..., ")")
    end

    D4.trans[lang] = D4.trans[lang] or {}
    if key and key ~= "" and key ~= "LID_" and D4.trans["enUS"] and D4.trans["enUS"][key] == nil and key and key ~= "" and missingTranslationsEn[key] == nil then
        missingTranslationsEn[key] = true
        local ver = "MISSING"
        if D4.GetVersion then
            ver = D4:GetVersion()
        end

        D4:MSG("TRANSLATION-KEY IS MISSING [" .. key .. "]", ver, "(", lang, ..., ")")
    end

    local result = nil
    if D4.trans[lang][key] ~= nil then
        result = D4.trans[lang][key]
    elseif D4.trans["enUS"] and D4.trans["enUS"][key] ~= nil then
        result = D4.trans["enUS"][key]
    else
        if key and key ~= "" and key ~= "LID_" and missingTranslations[key] == nil then
            missingTranslations[key] = true
            local ver = "MISSING"
            if D4.GetVersion then
                ver = D4:GetVersion()
            end

            D4:MSG("TRANSLATION MISSING [" .. key .. "]", ver, "(", lang, ..., ")")
        end

        return key
    end

    if select(1, ...) then
        result = string.format(result, ...)
    end

    return result or key
end

function D4:AddTrans(lang, key, value)
    D4.trans = D4.trans or {}
    if lang == nil then
        D4:MSG("[D4:AddTrans] lang is nil")

        return false
    end

    if key and strfind(key, "LID_", 1, true) == nil then
        D4:MSG("[D4:AddTrans] Missing LID_ for " .. key)

        return false
    end

    if langs[lang] == nil then
        missingLang[lang] = true
        local ver = "MISSING"
        if D4.GetVersion then
            ver = D4:GetVersion()
        end

        D4:MSG("[ADD] LANGUAGE IS MISSING [" .. lang .. "]", ver, "(", value, ")")
    end

    if key == nil then
        D4:MSG("[D4][AddTrans] key is nil")

        return false
    end

    if value == nil then
        D4:MSG("[D4][AddTrans] value is nil")

        return false
    end

    D4.trans[lang] = D4.trans[lang] or {}
    D4.trans[lang][key] = value
end

-- enUS
D4:AddTrans("enUS", "LID_LEFTCLICK", "Leftclick")
D4:AddTrans("enUS", "LID_RIGHTCLICK", "Rightclick")
D4:AddTrans("enUS", "LID_SHIFTLEFTCLICK", "Shift + Leftclick")
D4:AddTrans("enUS", "LID_SHIFTRIGHTCLICK", "Shift + Rightclick")
D4:AddTrans("enUS", "LID_CTRLLEFTCLICK", "Ctrl + Leftclick")
D4:AddTrans("enUS", "LID_CTRLRIGHTCLICK", "Ctrl + Rightclick")
D4:AddTrans("enUS", "LID_ALTLEFTCLICK", "Alt + Leftclick")
D4:AddTrans("enUS", "LID_ALTRIGHTCLICK", "Alt + Rightclick")
D4:AddTrans("enUS", "LID_OPENSETTINGS", "Open Settings")
D4:AddTrans("enUS", "LID_HIDEMINIMAPBUTTON", "Hide Minimap Button")
D4:AddTrans("enUS", "LID_DEFAULT", "Default")
-- deDE
D4:AddTrans("deDE", "LID_LEFTCLICK", "Linksklick")
D4:AddTrans("deDE", "LID_RIGHTCLICK", "Rechtsklick")
D4:AddTrans("deDE", "LID_SHIFTLEFTCLICK", "Shift + Linksklick")
D4:AddTrans("deDE", "LID_SHIFTRIGHTCLICK", "Shift + Rechtsklick")
D4:AddTrans("deDE", "LID_CTRLLEFTCLICK", "Strg + Linksklick")
D4:AddTrans("deDE", "LID_CTRLRIGHTCLICK", "Strg + Rechtsklick")
D4:AddTrans("deDE", "LID_ALTLEFTCLICK", "Alt + Linksklick")
D4:AddTrans("deDE", "LID_ALTRIGHTCLICK", "Alt + Rechtsklick")
D4:AddTrans("deDE", "LID_OPENSETTINGS", "Einstellungen öffnen")
D4:AddTrans("deDE", "LID_HIDEMINIMAPBUTTON", "Minimapknopf verstecken")
D4:AddTrans("deDE", "LID_DEFAULT", "Standard")
-- ruRU
D4:AddTrans("ruRU", "LID_LEFTCLICK", "ЛКМ")
D4:AddTrans("ruRU", "LID_RIGHTCLICK", "ПКМ")
D4:AddTrans("ruRU", "LID_SHIFTLEFTCLICK", "Shift + ЛКМ")
D4:AddTrans("ruRU", "LID_SHIFTRIGHTCLICK", "Shift + ПКМ")
D4:AddTrans("ruRU", "LID_CTRLLEFTCLICK", "Ctrl + ЛКМ")
D4:AddTrans("ruRU", "LID_CTRLRIGHTCLICK", "Ctrl + ПКМ")
D4:AddTrans("ruRU", "LID_ALTLEFTCLICK", "Alt + ЛКМ")
D4:AddTrans("ruRU", "LID_ALTRIGHTCLICK", "Alt + ПКМ")
D4:AddTrans("ruRU", "LID_OPENSETTINGS", "Открыть настройки")
D4:AddTrans("ruRU", "LID_HIDEMINIMAPBUTTON", "Скрыть иконку на миникарте")
D4:AddTrans("ruRU", "LID_DEFAULT", "По умолчанию")
