local addonName, addon = ...
local AcamarAPI = addon:NewModule("AcamarAPI", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")
local private = {}
------------------------------------------------------------------------------

-- export API to other addons
_G["AcamarAPIHelper"] = AcamarAPI

-- calling IsBlock in message filter
-- return block, score: block (true/false), score(spam score, normally >=1 should treated as spammers or bots)
function AcamarAPI:IsBlock(guid)
	return addon.FilterProcessor:IsBlock(guid)
end

function AcamarAPI:SpamScore(guid)
	return addon.FilterProcessor:SpamScore(guid)
end