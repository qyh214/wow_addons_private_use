-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Vendoring                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_vendoring           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Options = TSM:NewModule("Options", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Vendoring") -- loads the localization table
local AceGUI = LibStub("AceGUI-3.0")
local private = {ignoreSTCreated=nil }



-- ============================================================================
-- Module Options
-- ============================================================================

function Options:Load(container)
	local tg = AceGUI:Create("TSMTabGroup")
	tg:SetLayout("Fill")
	tg:SetFullHeight(true)
	tg:SetFullWidth(true)
	tg:SetTabs({{value=1, text=L["General"]}, {value=2, text=L["Ignore List"]}})
    tg:SetCallback("OnGroupSelected", function(self, _, value)
		self:ReleaseChildren()
		if value == 1 then
			private:DrawGeneralSettings(self)
		elseif value == 2 then
			private:DrawIgnoreSettings(self)
		end
  end)
	container:AddChild(tg)
	tg:SelectTab(1)
end

function private:DrawGeneralSettings(container)
	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["General Settings"],
					relativeWidth = 1,
					children = {
						{
							type = "CheckBox",
							label = L["Make Vendoring Default Merchant Tab"],
							settingInfo = {TSM.db.global, "defaultMerchantTab"},
							tooltip = L["If checked, the Vendoring tab of merchant windows will be the default tab."],
						},
						{
							type = "Dropdown",
							label = L["Default Vendoring Page"],
							relativeWidth = 0.5,
							list = {L["Buy"], L["Buyback"], L["TSM Groups"], L["Quick Sell"]},
							settingInfo = {TSM.db.global, "defaultPage"},
							tooltip = L["Specifies the default page that will show when you select the TSM_Vendoring tab."],
						},
						{
							type = "CheckBox",
							label = L["Automatically Sell Vendor trash"],
							settingInfo = {TSM.db.global, "autoSellTrash"},
							tooltip = L["If checked, vendoring will automatically sell any grey items in your inventory when you visit a merchant."],
						},
					}
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Quick Sell Settings"],
					relativeWidth = 1,
					children = {
						{
							type = "Slider",
							label = L["Batch Size"],
							tooltip = L["Number of items to sell at a time when QuickSelling"],
							isPercent = false,
							min = 1,
							max = 100,
							step = 1,
							settingInfo = { TSM.db.global, "qsBatchSize" },
							relativeWidth = 0.5,
						},
						{
							type = "Spacer"
						},
						{
							type = "EditBox",
							label = L["Market Value"],
							settingInfo = { TSM.db.global, "qsMarketValue" },
							relativeWidth = 0.5,
							acceptCustom = true,
							tooltip = L["Formula for an item's market value"],
						},
						{
							type = "EditBox",
							label = L["Max Market Value"],
							settingInfo = { TSM.db.global, "qsMaxMarketValue" },
							relativeWidth = 0.5,
							acceptCustom = true,
							tooltip = L["Do not sell an item if its market value meets or exceeds this amount"],
						},
						{
							type = "EditBox",
							label = L["Destroy Value"],
							settingInfo = { TSM.db.global, "qsDestroyValue" },
							relativeWidth = 0.5,
							acceptCustom = true,
							tooltip = L["Formula for an item's destroy value"],
						},
						{
							type = "EditBox",
							label = L["Max Destroy Value"],
							settingInfo = { TSM.db.global, "qsMaxDestroyValue" },
							relativeWidth = 0.5,
							acceptCustom = true,
							tooltip = L["Do not sell an item if its destroy value meets or exceeds this amount"],
						}
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Chat Message Options"],
					relativeWidth = 1,
					children = {
						{
							type = "CheckBox",
							label = L["Display Total Money Received"],
							settingInfo = {TSM.db.global, "displayMoneyCollected"},
							tooltip = L["If checked, the total amount of gold received will be shown at the end of automatically selling."],
						},
					},
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end

function private:DrawIgnoreSettings(container)

	local stCols = {
		{
			name = L["Ignored Item"],
			width = 1,
		}
	}

	local stHandlers = {
		OnEnter = function(_, data, self)
			if not data.itemString then return end
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT")
			GameTooltip:AddLine(L["Click on this row to remove this item from the permanent ignore list."], 1, 1, 1, true)
			GameTooltip:Show()
		end,
		OnLeave = function()
			GameTooltip:ClearLines()
			GameTooltip:Hide()
		end,
		OnClick = function(_, data, _, button)
			if not data.itemString then return end
			TSM.db.global.ignore[data.itemString] = nil
			TSM:Printf(L["Removed %s from the permanent ignore list."], data.link)
			Options:UpdateIgnoreST()
		end
	}

	local page = {
		{
			type = "SimpleGroup",
			fullHeight = true,
			layout = "Fill",
			children = {
				{
					type = "ScrollingTable",
					tag = "TSM_VENDORING_IGNORE",
					colInfo = stCols,
					handlers = stHandlers,
					selectionDisabled = true,
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
	private.ignoreSTCreated = true
	Options:UpdateIgnoreST()
end

function Options:UpdateIgnoreST()
	if not private.ignoreSTCreated then return end
	local stData = {}
	for itemString in pairs(TSM.db.global.ignore) do
		local name = TSMAPI.Item:GetName(itemString) or itemString
		local link = TSMAPI.Item:GetLink(itemString) or itemString
		local row = {
			cols = {
				{
					value = link,
				},
			},
			name = name,
			link = link,
			itemString = itemString,
		}
		tinsert(stData, row)
	end
	sort(stData, function(a, b) return a.name < b.name end)
	TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_VENDORING_IGNORE", stData)
end

-- ============================================================================
-- Operation Options
-- ============================================================================

function Options:GetOperationOptionsInfo()
	local description = L["Vendoring operations contain settings for easy vendoring of items."]
	local tabInfo = {
		{text = L["General"], callback = private.DrawOperationGeneral},
	}
	local relationshipInfo = {
		{
			label = L["Vendoring Settings"],
			{key="sellAfterExpired", label=L["Sell after expired auctions"]},
			{key="enableBuy", label=L["Enable Buying"]},
			{key="enableSell", label=L["Enable Selling"]},
			{key="keepQty", label=L["Keep Quantity"]},
			{key="restockQty", label=L["Restock Quantity"]},
			{key="restockSources", label = L["Sources to Include in Restock"] },
			{key="vsMarketValue", label=L["Market Value"]},
			{key="vsMaxMarketValue", label=L["Max Market Value"]},
			{key="vsDestroyValue", label=L["Destroy Value"]},
			{key="vsMaxDestroyValue", label=L["Max Destroy Value"]},
			{key="sellSoulbound", label=L["Sell soulbound items"]},
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
					title = L["Buy Settings"],
					children = {
						{
							type = "CheckBox",
							label = L["Enable Buying"],
							settingInfo = {operationSettings, "enableBuy"},
							tooltip = L["If checked, this operation will be considered when clicking 'Buy Groups'"],
							disabled = operationSettings.relationships.enableBuy,
							callback = function() container:Reload() end,
						},
						{
							type = "Spacer"
						},
						{
							type = "Slider",
							settingInfo = {operationSettings, "restockQty"},
							label = L["Restock Quantity"],
							tooltip = L["When buying, restock to this amount"],
							isPercent = false,
							min = 0,
							max = 5000,
							step = 1,
							relativeWidth = 0.5,
							disabled = operationSettings.relationships.restockQty or not operationSettings.enableBuy
						},
						{
							type = "Dropdown",
							label = L["Sources to Include in Restock"],
							tooltip = L["Vendoring will take into account items from these sources when calculating how much to restock"],
							disabled = operationSettings.relationships.restockSources or not operationSettings.enableBuy,
							relativeWidth = 0.5,
							list = {bank=BANK, guild=GUILD, alts=L["Alts"], alts_ah=L["Alts AH"],  ah=L["AH"], mail=L["Mail"]},
							value = operationSettings.restockSources,
							multiselect = true,
							callback = function(_, _, key, value)
								if operationSettings.restockSources == nil then
									operationSettings.restockSources = {}
								end

								operationSettings.restockSources[key] = value
							end,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Sell Settings"],
					children = {
						{
							type = "CheckBox",
							label = L["Enable Selling"],
							settingInfo = {operationSettings, "enableSell"},
							tooltip = L["If checked, this operation will be considered when clicking 'Sell Groups'"],
							disabled = operationSettings.relationships.enableSell,
							callback = function() container:Reload() end,
						},
						{
							type = "Spacer"
						},
						{
							type = "Slider",
							settingInfo = {operationSettings, "keepQty"},
							label = L["Keep Quantity"],
							tooltip = L["Quantity to keep in your bags"],
							isPercent = false,
							min = 0,
							max = 5000,
							step = 1,
							relativeWidth = 0.5,
							disabled = operationSettings.relationships.keepQty or not operationSettings.enableSell
						},
						{
							type = "Slider",
							settingInfo = {operationSettings, "sellAfterExpired"},
							label = L["Min Expires"],
							tooltip = L["Only sell an item after it has expired this many times"],
							isPercent = false,
							min = 0,
							max = 5000,
							step = 1,
							relativeWidth = 0.5,
							disabled = operationSettings.relationships.sellAfterExpired or not operationSettings.enableSell
						},
						{
							type = "EditBox",
							label = L["Market Value"],
							settingInfo = { operationSettings, "vsMarketValue" },
							relativeWidth = 0.5,
							acceptCustom = true,
							tooltip = L["Formula for an item's market value"],
							disabled = operationSettings.relationships.vsMarketValue or not operationSettings.enableSell
						},
						{
							type = "EditBox",
							label = L["Max Market Value ('0c' to disable)"],
							settingInfo = { operationSettings, "vsMaxMarketValue" },
							relativeWidth = 0.5,
							acceptCustom = true,
							tooltip = L["Do not sell an item if its market value meets or exceeds this amount"],
							disabled = operationSettings.relationships.vsMaxMarketValue or not operationSettings.enableSell
						},
						{
							type = "EditBox",
							label = L["Destroy Value"],
							settingInfo = { operationSettings, "vsDestroyValue" },
							relativeWidth = 0.5,
							acceptCustom = true,
							tooltip = L["Formula for an item's destroy value"],
							disabled = operationSettings.relationships.vsDestroyValue or not operationSettings.enableSell
						},
						{
							type = "EditBox",
							label = L["Max Destroy Value ('0c' to disable)"],
							settingInfo = { operationSettings, "vsMaxDestroyValue" },
							relativeWidth = 0.5,
							acceptCustom = true,
							tooltip = L["Do not sell an item if its destroy value meets or exceeds this amount"],
							disabled = operationSettings.relationships.vsMaxDestroyValue or not operationSettings.enableSell
						},
						{
							type = "CheckBox",
							label = L["Sell soulbound items"],
							settingInfo = {operationSettings, "sellSoulbound"},
							tooltip = L["If checked, soulbound items will be sold"],
							disabled = operationSettings.relationships.sellSoulbound or not operationSettings.enableSell
						},
					},
				}
			},
		},
	}
	TSMAPI.GUI:BuildOptions(container, page)
end
