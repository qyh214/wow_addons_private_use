---@class addon
local addon = select(2, ...)
local L = addon.C.AddonInfo.Locales

--------------------------------

L.itIT = {}
local NS = L.itIT; L.itIT = NS

--------------------------------

function NS:Load()
	if GetLocale() ~= "itIT" then
		return
	end
end

NS:Load()
