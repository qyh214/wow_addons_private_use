-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Options = TSM:NewModule("Options", "AceEvent-3.0", "AceHook-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Warehousing") -- loads the localization table
local private = {}



function Options:GetOperationOptionsInfo()
	local description = L["Warehousing operations contain settings for moving the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Warehousing operation."]
	local tabInfo = {
		{ text = L["General"], callback = private.DrawOperationGeneral},
	}
	local relationshipInfo = {
		{
			label = L["Move Quantity Settings"],
			{key="moveQtyEnabled", label=L["Set Move Quantity"]},
			{key="moveQuantity", label=L["Move Quantity"]},
			{key="stackSizeEnabled", label=L["Set Stack Size for bags"]},
			{key="stackSize", label=L["Stack Size Multiple"]},
			{key="keepBagQtyEnabled", label=L["Set Keep in Bags Quantity"]},
			{key="keepBagQuantity", label=L["Keep in Bags Quantity"]},
			{key="keepBankQtyEnabled", label=L["Set Keep in Bank Quantity"]},
			{key="keepBankQuantity", label=L["Keep in Bank/GuildBank Quantity"]},
		},
		{
			label = L["Restock Settings"],
			{key="restockQtyEnabled", label=L["Enable Restock"]},
			{key="restockQuantity", label=L["Restock Quantity"]},
			{key="restockStackSizeEnabled", label=L["Set Stack Size for bags"]},
			{key="restockStackSize", label=L["Stack Size Multiple"]},
			{key="restockKeepBankQtyEnabled", label=L["Set Keep in Bank Quantity"]},
			{key="restockKeepBankQuantity", label=L["Keep in Bank/GuildBank Quantity"]},
		},
	}
	return description, tabInfo, relationshipInfo
end

function private.DrawOperationGeneral(container, operationName)
	local operationSettings = TSM.operations[operationName]

	local page = {
		{
			-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Move Quantity Settings"],
					children = {
						{
							type = "CheckBox",
							label = L["Set Move Quantity"],
							settingInfo = {operationSettings, "moveQtyEnabled"},
							disabled = operationSettings.relationships.moveQtyEnabled,
							callback = function() container:Reload() end,
							tooltip = L["Enable this to set the quantity to move, if disabled Warehousing will move all of the item"],
						},
						{
							-- slider to set the move quantity
							type = "Slider",
							label = L["Move Quantity"],
							settingInfo = {operationSettings, "moveQuantity"},
							disabled = operationSettings.relationships.moveQuantity or not operationSettings.moveQtyEnabled,
							isPercent = false,
							min = 1,
							max = 5000,
							step = 1,
							tooltip = L["Warehousing will move this number of each item"],
						},
						{
							type = "Spacer",
						},
						{
							type = "CheckBox",
							label = L["Set Stack Size for bags"],
							settingInfo = {operationSettings, "stackSizeEnabled"},
							disabled = operationSettings.relationships.stackSizeEnabled,
							callback = function() container:Reload() end,
							tooltip = L["Enable this to set the stack size multiple to be moved"],
						},
						{
							-- slider to set the move quantity
							type = "Slider",
							label = L["Stack Size Multiple"],
							settingInfo = {operationSettings, "stackSize"},
							disabled = operationSettings.relationships.stackSize or not operationSettings.stackSizeEnabled,
							isPercent = false,
							min = 1,
							max = 200,
							step = 1,
							tooltip = L["Warehousing will only move items in multiples of the stack size set when moving to your bags, this is useful for milling/prospecting etc to ensure you don't move items you can't process"],
						},
						{
							type = "Spacer",
						},
						{
							type = "CheckBox",
							label = L["Set Keep in Bags Quantity"],
							settingInfo = {operationSettings, "keepBagQtyEnabled"},
							disabled = operationSettings.relationships.keepBagQtyEnabled,
							callback = function() container:Reload() end,
							tooltip = L["Enable this to set the quantity to keep back in your bags"],
						},
						{
							-- slider to set the keep bags qty
							type = "Slider",
							label = L["Keep in Bags Quantity"],
							settingInfo = {operationSettings, "keepBagQuantity"},
							disabled = operationSettings.relationships.keepBagQuantity or not operationSettings.keepBagQtyEnabled,
							isPercent = false,
							min = 1,
							max = 5000,
							step = 1,
							tooltip = L["Warehousing will ensure this number remain in your bags when moving items to the bank / guildbank."],
						},
						{
							type = "Spacer",
						},
						{
							type = "CheckBox",
							label = L["Set Keep in Bank Quantity"],
							settingInfo = {operationSettings, "keepBankQtyEnabled"},
							disabled = operationSettings.relationships.keepBankQtyEnabled,
							callback = function() container:Reload() end,
							tooltip = L["Enable this to set the quantity to keep back in your bank / guildbank"],
						},
						{
							-- slider to set the keep bank qty
							type = "Slider",
							label = L["Keep in Bank/GuildBank Quantity"],
							settingInfo = {operationSettings, "keepBankQuantity"},
							disabled = operationSettings.relationships.keepBankQuantity or not operationSettings.keepBankQtyEnabled,
							isPercent = false,
							min = 1,
							max = 5000,
							step = 1,
							tooltip = L["Warehousing will ensure this number remain in your bank / guildbank when moving items to your bags."],
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Restock Settings"],
					children = {
						{
							type = "CheckBox",
							label = L["Enable Restock"],
							settingInfo = {operationSettings, "restockQtyEnabled"},
							disabled = operationSettings.relationships.restockQtyEnabled,
							callback = function() container:Reload() end,
							tooltip = L["Enable this to set the restock quantity"],
						},
						{
							-- slider to set the move quantity
							type = "Slider",
							label = L["Restock Quantity"],
							settingInfo = {operationSettings, "restockQuantity"},
							disabled = operationSettings.relationships.restockQuantity or not operationSettings.restockQtyEnabled,
							isPercent = false,
							min = 1,
							max = 5000,
							step = 1,
							tooltip = L["Warehousing will restock your bags up to this number of items"],
						},
						{
							type = "Spacer",
						},
						{
							type = "CheckBox",
							label = L["Set Stack Size for bags"],
							settingInfo = {operationSettings, "restockStackSizeEnabled"},
							disabled = operationSettings.relationships.restockStackSizeEnabled,
							callback = function() container:Reload() end,
							tooltip = L["Enable this to set the stack size multiple to be moved"],
						},
						{
							-- slider to set the move quantity
							type = "Slider",
							label = L["Stack Size Multiple"],
							settingInfo = {operationSettings, "restockStackSize"},
							disabled = operationSettings.relationships.restockStackSize or not operationSettings.restockStackSizeEnabled,
							isPercent = false,
							min = 1,
							max = 200,
							step = 1,
							tooltip = L["Warehousing will only move items in multiples of the stack size set when moving to your bags, this is useful for milling/prospecting etc to ensure you don't move items you can't process"],
						},
						{
							type = "Spacer",
						},
						{
							type = "CheckBox",
							settingInfo = {operationSettings, "restockKeepBankQtyEnabled"},
							label = L["Set Keep in Bank Quantity"],
							disabled = not operationSettings.restockQtyEnabled,
							callback = function() container:Reload() end,
							tooltip = L["Enable this to set the quantity to keep back in your bank / guildbank"],
						},
						{
							-- slider to set the keep bank qty
							type = "Slider",
							label = L["Keep in Bank/GuildBank Quantity"],
							settingInfo = {operationSettings, "restockKeepBankQuantity"},
							disabled = operationSettings.relationships.restockKeepBankQuantity or not operationSettings.restockQtyEnabled or not operationSettings.restockKeepBankQtyEnabled,
							isPercent = false,
							min = 1,
							max = 5000,
							tooltip = L["Warehousing will ensure this number remain in your bank / guildbank when restocking items to your bags."],
						},
					},
				},
			},
		},
	}
	TSMAPI.GUI:BuildOptions(container, page)
end