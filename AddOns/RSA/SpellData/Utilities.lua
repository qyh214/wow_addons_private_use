local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local L = LibStub('AceLocale-3.0'):GetLocale('RSA')

local defaults = {

}
local wrath = {

}

--[[if RSA.IsRetail() then
	RSA.monitorData.mage, RSA.configData.mage = RSA.PrepareDataTables(defaults)
elseif RSA.IsWrath() then
	RSA.monitorData.mage, RSA.configData.mage = RSA.PrepareDataTables(wrath)
end]]--