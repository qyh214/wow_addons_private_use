-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TSM_Warehousing", "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Warehousing") -- loads the localization table
local private = { bank = nil }


local settingsInfo = {
	version = 1,
	global = {
		ShowLogData = { type = "boolean", default = false, lastModifiedVersion = 1 },
	},
	factionrealm = {
		BagState = { type = "table", default = {}, lastModifiedVersion = 1 },
	},
}
local operationDefaults = {
	moveQtyEnabled = nil,
	moveQuantity = 1, -- move 1
	keepBagQtyEnabled = nil,
	keepBagQuantity = 1, -- keep 1 in bags
	keepBankQtyEnabled = nil,
	keepBankQuantity = 1, --keep 1 in bank
	restockQtyEnabled = nil,
	restockQuantity = 1, --restock 1
	stackSize = 5,
	stackSizeEnabled = nil,
	restockKeepBankQtyEnabled = nil,
	restockKeepBankQuantity = 1,
	restockStackSizeEnabled = nil,
	restockStackSize = 5,
}

-- Called once the player has loaded into the game
-- Anything that needs to be done in order to initialize the addon should go here
function TSM:OnEnable()
	-- load settings
	TSM.db = TSMAPI.Settings:Init("TradeSkillMaster_WarehousingDB", settingsInfo)

	for name, module in pairs(TSM.modules) do
		TSM[name] = module
	end

	-- register the module with TSM
	TSM:RegisterModule()

	--add new fields to operation if they doesn't exist
	for name in pairs(TSM.operations) do
		TSMAPI.Operations:Update("Warehousing", name)
		local settings = TSM.operations[name]
		if not settings then return end
		if not settings.stackSize then
			settings.stackSize = 5
		end
		if not settings.restockKeepBankQuantity then
			settings.restockKeepBankQuantity = 1
		end
		if not settings.restockStackSize then
			settings.restockStackSize = 5
		end
	end

	TSM:RegisterEvent("GUILDBANKFRAME_OPENED", function(event)
		private.bank = "guildbank"
	end)

	TSM:RegisterEvent("BANKFRAME_OPENED", function(event)
		private.bank = "bank"
	end)

	TSM:RegisterEvent("GUILDBANKFRAME_CLOSED", function(event, addon)
		private.bank = nil
	end)

	TSM:RegisterEvent("BANKFRAME_CLOSED", function(event)
		private.bank = nil
	end)
end

function TSM:RegisterModule()
	TSM.slashCommands = {
		{ key = "movedata", label = L["Displays realtime move data."], callback = "SetLogFlag" },
		{ key = "get", label = L["Gets items from the bank or guild bank matching the itemstring, itemID or partial text entered."], callback = "GetItem" },
		{ key = "put", label = L["Puts items matching the itemstring, itemID or partial text entered into the bank or guild bank."], callback = "PutItem" },
	}
	TSM.operations = { maxOperations = 12, callbackOptions = "Options:GetOperationOptionsInfo", callbackInfo = "GetOperationInfo", defaults = operationDefaults }
	TSM.bankUiButton = { callback = "BankUI:createTab" }
	TSMAPI:NewModule(TSM)
end

function TSM:GetOperationInfo(name)
	TSMAPI.Operations:Update("Warehousing", name)
	local settings = TSM.operations[name]
	if not settings then return end
	if (settings.keepBagQtyEnabled or settings.keepBankQtyEnabled) and not settings.moveQtyEnabled then
		if settings.keepBagQtyEnabled then
			if settings.keepBankQtyEnabled then
				if settings.restockQtyEnabled then
					return format(L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."], settings.keepBagQuantity, settings.keepBankQuantity, settings.restockQuantity)
				else
					return format(L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."], settings.keepBagQuantity, settings.keepBankQuantity)
				end
			else
				if settings.restockQtyEnabled then
					return format(L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."], settings.keepBagQuantity, settings.restockQuantity)
				else
					return format(L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank."], settings.keepBagQuantity)
				end
			end
		else
			if settings.restockQtyEnabled then
				return format(L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."], settings.keepBankQuantity, settings.restockQuantity)
			else
				return format(L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags."], settings.keepBankQuantity)
			end
		end
	elseif (settings.keepBagQtyEnabled or settings.keepBankQtyEnabled) and settings.moveQtyEnabled then
		if settings.keepBagQtyEnabled then
			if settings.keepBankQtyEnabled then
				if settings.restockQtyEnabled then
					return format(L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."], settings.moveQuantity, settings.keepBagQuantity, settings.keepBankQuantity, settings.restockQuantity)
				else
					return format(L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."], settings.moveQuantity, settings.keepBagQuantity, settings.keepBankQuantity)
				end
			else
				if settings.restockQtyEnabled then
					return format(L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."], settings.keepBankQuantity, settings.restockQuantity)
				else
					return format(L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank."], settings.keepBankQuantity)
				end
			end
		else
			if settings.restockQtyEnabled then
				return format(L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."], settings.moveQuantity, settings.keepBankQuantity, settings.restockQuantity)
			else
				return format(L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags."], settings.moveQuantity, settings.keepBankQuantity)
			end
		end
	elseif settings.moveQtyEnabled then
		if settings.restockQtyEnabled then
			return format(L["Warehousing will move a max of %d of each item in this group. Restock will maintain %d items in your bags."], settings.moveQuantity, settings.restockQuantity)
		else
			return format(L["Warehousing will move a max of %d of each item in this group."], settings.moveQuantity)
		end
	else
		if settings.restockQtyEnabled then
			return format(L["Warehousing will move all of the items in this group. Restock will maintain %d items in your bags."], settings.restockQuantity)
		else
			return L["Warehousing will move all of the items in this group."]
		end
	end
end

function TSM:SetLogFlag()
	if TSM.db.global.ShowLogData then
		TSM.db.global.ShowLogData = false
		TSM:Print(L["Move Data has been turned off"])
	else
		TSM.db.global.ShowLogData = true
		TSM:Print(L["Move Data has been turned on"])
	end
end

function TSM:GetItem(args)
	if args then
		if TSM.move:areBanksVisible() then
			local quantity = tonumber(strmatch(args, " ([0-9]+)$"))
			local searchString = gsub(args, " ([0-9]+)$", "")
			if not searchString and TSMAPI.Item:GetTexture(quantity) then -- incase an itemID was entered but no qty then the strmatch would have incorrectly set as quantity
				searchString = quantity
				quantity = nil
			end
			TSM.move:manualMove(searchString, private.bank, quantity)
		else
			TSM:Print(L["There are no visible banks."])
		end
	else
		TSM:Print(L["Invalid criteria entered."])
	end
end

function TSM:PutItem(args)
	if args then
		if TSM.move:areBanksVisible() then
			local quantity = tonumber(strmatch(args, " ([0-9]+)$"))
			local searchString = gsub(args, " ([0-9]+)$", "")
			if not searchString and TSMAPI.Item:GetTexture(quantity) then -- incase an itemID was entered but no qty then the strmatch would have incorrectly set as quantity
				searchString = quantity
				quantity = nil
			end
			TSM.move:manualMove(searchString, "bags", quantity)
		else
			TSM:Print(L["There are no visible banks."])
		end
	else
		TSM:Print(L["Invalid criteria entered."])
	end
end
