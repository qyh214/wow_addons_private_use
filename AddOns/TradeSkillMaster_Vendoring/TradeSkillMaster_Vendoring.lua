-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Vendoring                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_vendoring           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TSM_Vendoring", "AceEvent-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Vendoring") -- loads the localization table

local private = {}

local settingsInfo = {
	version = 1,
	global = {
		displayMoneyCollected = { type = "boolean", default = false, lastModifiedVersion = 1 },
		defaultMerchantTab = { type = "boolean", default = false, lastModifiedVersion = 1 },
		autoSellTrash = { type = "boolean", default = false, lastModifiedVersion = 1 },
		qsHideGrouped = { type = "boolean", default = true, lastModifiedVersion = 1 },
		qsHideSoulbound = { type = "boolean", default = true, lastModifiedVersion = 1 },
		qsBatchSize = { type = "number", default = 12, lastModifiedVersion = 1 },
		defaultPage = { type = "number", default = 1, lastModifiedVersion = 1 },
		qsMarketValue = { type = "string", default = "dbmarket", lastModifiedVersion = 1 },
		qsMaxMarketValue = { type = "string", default = "100g", lastModifiedVersion = 1 },
		qsDestroyValue = { type = "string", default = "destroy", lastModifiedVersion = 1 },
		qsMaxDestroyValue = { type = "string", default = "100g", lastModifiedVersion = 1 },
		ignore = { type = "table", default = {}, lastModifiedVersion = 1 },
		helpPlatesShown = { type = "table", default = { buy = nil, buyback = nil, groups = nil, quickSell = nil }, lastModifiedVersion = 1 },
	},
}
local operationDefaults = {
	qsPreference = 1,
	sellAfterExpired = 20,
	sellSoulbound = false,
	keepQty = 0,
	restockQty = 0,
	restockSources = {},
	enableBuy = true,
	enableSell = true,
	vsMarketValue = "dbmarket",
	vsMaxMarketValue = "0c",
	vsDestroyValue = "Destroy",
	vsMaxDestroyValue = "0c",
}

function TSM:OnEnable()
	-- load settings
	TSM.db = TSMAPI.Settings:Init("TradeSkillMaster_VendoringDB", settingsInfo)

	for moduleName, module in pairs(TSM.modules) do
		TSM[moduleName] = module
	end

	-- register this module with TSM
	TSM:RegisterModule()
end

-- registers this module with TSM by first setting all fields and then calling TSMAPI:NewModule().
function TSM:RegisterModule()
	TSM.operations = {maxOperations=1, callbackOptions="Options:GetOperationOptionsInfo", callbackInfo="GetOperationInfo", defaults=operationDefaults}
	TSM.moduleOptions = {callback="Options:Load"}
	TSMAPI:NewModule(TSM)
end

function TSM:GetOperationInfo(operationName)
	local operation = TSM.operations[operationName]
	if not operation then return end
	if operation.target == "" then return end

	local parts = {}

	if operation.restockQty > 0 then
		tinsert(parts, format(L["Restocking to %d."],operation.restockQty))
	end

	if operation.keepQty > 0 then
		tinsert(parts,format(L["Keeping %d."],operation.keepQty))
	end

	local sellString = ""
	local sellSeparator = ""
	if operation.sellAfterExpired > 0 then
		sellString = format(L["Selling after %d expired auctions"],operation.sellAfterExpired)
		sellSeparator = L[" and "]
	else
		sellString = L["Selling if "]
		sellSeparator = ""
	end

	if operation.vsMaxMarketValue ~= '0c' and operation.vsMaxDestroyValue ~= '0c' then
		sellString = format(L["%s%smarket value is below %s and destroy value is below %s"],sellString,sellSeparator,operation.vsMaxMarketValue,operation.vsMaxDestroyValue)
	elseif operation.vsMaxMarketValue ~= '0c' and operation.vsMaxDestroyValue == '0c' then
		sellString = format(L["%s%smarket value is below %s"],sellString,sellSeparator,operation.vsMaxMarketValue)
	elseif operation.vsMaxMarketValue == '0c' and operation.vsMaxDestroyValue ~= '0c' then
		sellString = format(L["%s%sdestroy value is below %s"],sellString,sellSeparator,operation.vsMaxDestroyValue)
	elseif operation.sellAfterExpired == 0 then
		sellString = L["Selling always"]
	end

	tinsert(parts,format("%s.",sellString))

	if operation.sellSoulbound then
		tinsert(parts,L["Selling soulbound items."])
	end

	return table.concat(parts, " ")
end