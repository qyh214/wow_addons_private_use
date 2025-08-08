---@class addon
local addon = select(2, ...)
local L = addon.C.AddonInfo.Locales

--------------------------------

L.esMX = {}
local NS = L.esMX; L.esMX = NS

--------------------------------

function NS:Load()
	if GetLocale() ~= "esMX" then
		return
	end
end

NS:Load()
