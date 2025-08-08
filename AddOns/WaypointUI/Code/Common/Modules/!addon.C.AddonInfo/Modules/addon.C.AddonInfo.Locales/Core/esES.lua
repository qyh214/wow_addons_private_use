---@class addon
local addon = select(2, ...)
local L = addon.C.AddonInfo.Locales

--------------------------------

L.esES = {}
local NS = L.esES; L.esES = NS

--------------------------------

function NS:Load()
    if GetLocale() ~= "esES" then
        return
    end
end

NS:Load()
