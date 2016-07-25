-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Vendoring                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_vendoring           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Groups = TSM:NewModule("Groups", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Vendoring") -- loads the localization table

local private = { sellThreadId = nil, buyThreadId = nil, processing = false, frame = nil, sellProfit = 0}

function Groups:CreateTab()

	local BFC = TSMAPI.GUI:GetBuildFrameConstants()
	local frameInfo = {
		type = "Frame",
		key = "groupsTab",
		hidden = true,
		points = "ALL",
		scripts = {"OnShow"},
		children = {
			{
				type = "GroupTreeFrame",
				key = "groupTree",
				groupTreeInfo = {"Vendoring", "Vendoring_Vendor"},
				points = {{"TOPLEFT", 5, -5}, {"BOTTOMRIGHT", -5, 60}},
			},
			{
				type = "Button",
				key = "buyButton",
				text = L["Buy Selected Groups"],
				textHeight = 15,
				size = {180, 25},
				points = {{"BOTTOMLEFT", 5, 30}},
				scripts = {"OnClick"},
			},
			{
				type = "Button",
				key = "sellButton",
				text = L["Sell Selected Groups"],
				textHeight = 15,
				size = {180, 25},
				points = {{"BOTTOMLEFT", BFC.PREV, "BOTTOMRIGHT", 5,0}},
				scripts = {"OnClick"},
			}
		},
		handlers = {
			OnShow = function(self)
				private.frame = self

				if not self.helpBtn then
					local TOTAL_WIDTH = private.frame:GetParent():GetWidth()
					local helpPlateInfo = {
						FramePos = {x = 0, y = 70},
						FrameSize = {width = TOTAL_WIDTH, height = private.frame:GetHeight()},
						{
							ButtonPos = {x = 100, y = -20},
							HighLightBox = {x = 70, y = -35, width = TOTAL_WIDTH-70, height = 30},
							ToolTipDir = "DOWN",
							ToolTipText = L["These buttons change what is shown in the merchant frame. You can view what the merchant is selling, buyback any items you have sold, automatically buy and sell items in groups, and quickly sell items."],
						},
						{
							ButtonPos = {x = 200, y = -200},
							HighLightBox = {x = 0, y = -65, width = TOTAL_WIDTH, height = 325},
							ToolTipDir = "RIGHT",
							ToolTipText = L["Here you can select groups with TSM_Vendoring operations to be automatically bought or sold."],
						},
						{
							ButtonPos = {x = 60, y = -380},
							HighLightBox = {x = 0, y = -390, width = 185, height = 35},
							ToolTipDir = "RIGHT",
							ToolTipText = L["Click this button to automatically buy for groups which you have selected."],
						},
						{
							ButtonPos = {x = 270, y = -380},
							HighLightBox = {x = 190, y = -390, width = 185, height = 35},
							ToolTipDir = "RIGHT",
							ToolTipText = L["Click this button to automatically sell for groups which you have selected."],
						},
					}

					self.helpBtn = CreateFrame("Button", nil, private.frame, "MainHelpPlateButton")
					self.helpBtn:SetPoint("TOPLEFT", 50, 100)
					self.helpBtn:SetScript("OnClick", function() TSM.MerchantTab:ToggleHelpPlate(private.frame, helpPlateInfo, self.helpBtn, true) end)
					self.helpBtn:SetScript("OnHide", function() if HelpPlate_IsShowing(helpPlateInfo) then TSM.MerchantTab:ToggleHelpPlate(private.frame, helpPlateInfo, self.helpBtn, false) end end)
					if not TSM.db.global.helpPlatesShown.groups then
						TSM.db.global.helpPlatesShown.groups = true
						TSM.MerchantTab:ToggleHelpPlate(private.frame, helpPlateInfo, self.helpBtn, false)
					end
				end
			end,
			sellButton = {
				OnClick = function(self)
					private:DisableButtons()
					private.processing = true

					if private.sellThreadId == nil then
						private.sellThreadId = TSMAPI.Threading:Start(private.SellThread, 0.7, private.DoneSelling)
					end
				end
			},
			buyButton = {
				OnClick = function(self)
					private:DisableButtons()
					private.processing = true

					if private.buyThreadId == nil then
						private.buyThreadId = TSMAPI.Threading:Start(private.BuyThread, 0.7, private.DoneBuying)
					end
				end
			}

		}
	}

	return frameInfo
end

function private:EnableButtons()
	private.frame.sellButton:Enable()
	private.frame.buyButton:Enable()
end

function private:DisableButtons()
	private.frame.sellButton:Disable()
	private.frame.buyButton:Disable()
end

function private.SellThread(self)
	self:SetThreadName("VENDORING_GROUPS_SELL")
	local inventoryItems = {}
	local inventoryLocations = {}
	local printedBagsFullMsg

	private.sellProfit = 0

	-- Determine quantity of items in inventory.
	for bag, slot, itemString, quantity, locked in TSMAPI.Inventory:BagIterator(true,true) do
		inventoryItems[itemString] = (inventoryItems[itemString] or 0) + quantity

		if inventoryLocations[itemString] == nil then
			inventoryLocations[itemString] = {}
		end

		tinsert(inventoryLocations[itemString], { bag = bag, slot = slot, quantity = quantity })
	end

	for _, data in pairs(private.frame.groupTree:GetSelectedGroupInfo()) do
		for _, operationName in ipairs(data.operations) do
			local operation = TSM.operations[operationName]

			if operation.enableSell then
				for itemString in pairs(data.items) do
					local numToSell = (inventoryItems[itemString] or 0) - operation.keepQty
					if numToSell > 0 then

						local cancelledNum, expiredNum, totalFailed = TSMAPI:ModuleAPI("Accounting", "getAuctionStatsSinceLastSale", itemString)

						if not cancelledNum or not expiredNum then
							expiredNum = 0
						end

						local destroyValue = TSMAPI:GetCustomPriceValue(operation.vsDestroyValue,itemString) or 0
						local marketValue = TSMAPI:GetCustomPriceValue(operation.vsMarketValue,itemString) or 0

						local maxMarketValue = TSMAPI:GetCustomPriceValue(operation.vsMaxMarketValue,itemString) or 0
						local maxDestroyValue = TSMAPI:GetCustomPriceValue(operation.vsMaxDestroyValue,itemString) or 0

						local shouldSell = true

						if operation.sellAfterExpired > 0 and expiredNum < operation.sellAfterExpired then
							shouldSell = false
						end

						if maxDestroyValue > 0 and destroyValue >= maxDestroyValue then
							shouldSell = false
						end

						if maxMarketValue > 0 and marketValue >= maxMarketValue then
							shouldSell = false
						end

						if shouldSell then
							local family = GetItemFamily(TSMAPI.Item:ToItemID(itemString)) or 0
							-- get a list of empty slots which we can use to split items into
							local emptySlots = private:GetEmptyBagSlotsThread(self, family)

							sort(inventoryLocations[itemString], function(a, b) return a.quantity < b.quantity end)
							local quantity = numToSell

							local vendorValue = TSMAPI:GetItemValue(itemString,'VendorSell') or 0

							for _, location in ipairs(inventoryLocations[itemString]) do
								if quantity == 0 then break end
								if not TSMAPI.Item:IsSoulbound(location.bag, location.slot) or operation.sellSoulbound then
									if location.quantity <= quantity then
										quantity = quantity - location.quantity
										UseContainerItem(location.bag,location.slot)
										private.sellProfit = private.sellProfit + (vendorValue * location.quantity)
									else
										local splitTarget
										for i = 1, #emptySlots do
											if emptySlots[i].family == 0 or bit.band(family, emptySlots[i].family) > 0 then
												splitTarget = emptySlots[i]
												tremove(emptySlots, i)
												break
											end
										end
										if splitTarget then
											SplitContainerItem(location.bag, location.slot, quantity)
											PickupContainerItem(splitTarget.bag, splitTarget.slot)
											-- wait for the stack to be split
											while not GetContainerItemInfo(splitTarget.bag, splitTarget.slot) do self:Yield(true) end
											PickupContainerItem(splitTarget.bag, splitTarget.slot)
											UseContainerItem(splitTarget.bag, splitTarget.slot)
											private.sellProfit = private.sellProfit + (vendorValue * quantity)
										else
											-- the player's bags are full
											if not printedBagsFullMsg then
												TSM:Print(L["Could not vendor due to not having free bag space available to split a stack of items."])
												printedBagsFullMsg = true
											end
										end
										-- we're done
										quantity = 0
										break
									end
									self:Yield(true)
								end
							end
						end
					end
				end
			end
		end
	end
end

function private:DoneSelling()
	private.processing  = false
	private.sellThreadId = nil
	private:EnableButtons()

	if TSM.db.global.displayMoneyCollected then
		TSM:Printf(L["Collected: %s"],TSMAPI:MoneyToString(private.sellProfit, "OPT_TRIM"))
	end
end

function private.BuyThread(self)
	self:SetThreadName("VENDORING_GROUPS_BUY")

	-- Store and set the merchant filter to 'All'
	local currentMerchantFilter = GetMerchantFilter()
	SetMerchantFilter(1)

	local numMerchantItems = GetMerchantNumItems()

	local inventoryItems = {}

	-- Determine quantity of items in inventory.
	for bag, slot, itemString, quantity, locked in TSMAPI.Inventory:BagIterator() do
		inventoryItems[itemString] = (inventoryItems[itemString] or 0) + quantity
	end

	for index = 1, numMerchantItems do
		local name, texture, price, stackCount, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(index)
		local vendorItemLink = GetMerchantItemLink(index)
		local vendorItemString = TSMAPI.Item:ToItemString(vendorItemLink)

		for _, data in pairs(private.frame.groupTree:GetSelectedGroupInfo()) do
			for _, operationName in ipairs(data.operations) do
				local operation = TSM.operations[operationName]

				if operation.enableBuy then
					for itemString in pairs(data.items) do
						if vendorItemString == itemString then
							local numHave = inventoryItems[itemString] or 0

							if operation.restockSources.bank then
								numHave = numHave + TSMAPI.Inventory:GetBankQuantity(itemString) + TSMAPI.Inventory:GetReagentBankQuantity(itemString)
							end

							if operation.restockSources.guild then
								numHave = numHave + TSMAPI.Inventory:GetGuildQuantity(itemString)
							end

							if operation.restockSources.alts then
								numHave = numHave + select(2, TSMAPI.Inventory:GetPlayerTotals(itemString))
							end

							if operation.restockSources.ah then
								numHave = numHave + TSMAPI.Inventory:GetAuctionQuantity(itemString)
							end

							if operation.restockSources.mail then
								numHave = numHave + TSMAPI.Inventory:GetMailQuantity(itemString)
							end

							if operation.restockSources.alts_ah then
								numHave = numHave + select(4, TSMAPI.Inventory:GetPlayerTotals(itemString))
							end

							local restockAmount = operation.restockQty - numHave

							if restockAmount > 0 then
								-- Lower the restock amount to the number available
								if (numAvailable > -1) then
									restockAmount = math.min(restockAmount,numAvailable)
								end

								local maxStack = GetMerchantItemMaxStack(index)
								local maxAfford = TSM.Util:GetMaxAfford(index)
								
								restockAmount = math.min(restockAmount,maxAfford)								
								while restockAmount > 0 do
									BuyMerchantItem(index,math.min(restockAmount,maxStack))
									restockAmount = restockAmount - maxStack
									self:Yield()
								end

								self:Yield(true)
							end
						end
					end
				end
			end
		end
	end

	-- Restore the merchant filter
	SetMerchantFilter(currentMerchantFilter)
end


function private:DoneBuying()
	private.processing  = false
	private.buyThreadId = nil
	private:EnableButtons()
end

function private:GetEmptyBagSlotsThread(self, itemFamily)
	local specialBags = {}
	if itemFamily and itemFamily > 0 then
		for bag = 1, NUM_BAG_SLOTS do
			local bagFamily = GetItemFamily(GetInventoryItemLink("player", ContainerIDToInventoryID(bag)))
			if bagFamily and bagFamily > 0 and bit.band(itemFamily, bagFamily) > 0 then
				specialBags[bag] = true
			end
		end
	end

	-- get a list of empty slots which we can use to split items into
	local emptySlots = {}
	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			if not GetContainerItemInfo(bag, slot) then
				local family = (bag == 0) and 0 or GetItemFamily(GetInventoryItemLink("player", ContainerIDToInventoryID(bag)))
				tinsert(emptySlots, { bag = bag, slot = slot, family = family })
			end
		end
		self:Yield()
	end
	-- sort the empty slots such that we'll use special bags first if possible
	sort(emptySlots, function(a, b) return private:GetSlotSortValue(a.bag, a.slot, specialBags) < private:GetSlotSortValue(b.bag, b.slot, specialBags) end)
	return emptySlots
end

function private:GetSlotSortValue(bag, slot, specialBags)
	local val = 0
	if not specialBags[bag] then
		val = val + 100000
	end
	return val + bag * 1000 + slot
end


