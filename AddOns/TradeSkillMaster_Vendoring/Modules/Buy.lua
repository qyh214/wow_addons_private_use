-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Vendoring                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_vendoring           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Buy = TSM:NewModule("Buy", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Vendoring") -- loads the localization table

local private = { quantity = 1, frame = nil, tooltipFrame = nil, nameFilter = nil, vendorItems = {}, inspecting = false, hovering = false, splitIndex= nil }

function Buy:CreateTab(parent)

	local BFC = TSMAPI.GUI:GetBuildFrameConstants()
	local frameInfo = {
		type = "Frame",
		key = "buyTab",
		hidden = true,
		points = "ALL",
		scripts = {"OnShow"},
		children = {
			{
				type = "Frame",
				key = "confirmation",
				mouse = true,
				points = "ALL",
				strata = "DIALOG",
				children = {
						{
							type = "Frame",
							key = "splitFrame",
							size = {175, 115},
							points = {{"CENTER"}},
							scripts = {"OnShow"},
							children = {
											{
												type = "ItemLinkLabel",
												key = "item",
												textHeight = 16,
												points = {{"TOPLEFT", 5, -5}, {"TOPRIGHT", -5, -5}},
											},
											{
												type = "TextureButton",
												key = "lessBtn",
												normalTexture = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up",
												pushedTexture = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down",
												disabledTexture = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-DisabledTexture",
												highlightTexture = "Interface\\Buttons\\UI-Common-MouseHilight",
												size = { 28, 28 },
												points = { { "TOPLEFT", 15, -25 } },
												scripts = { "OnClick" },
											},
											{
												type = "InputBox",
												key = "quantityBox",
												numeric = true,
												size = {80,20},
												justify = {"RIGHT", "MIDDLE"},
												points = {{"TOPLEFT", BFC.PREV, "TOPRIGHT", 5, -5} },
												scripts = { "OnEditFocusGained", "OnEnterPressed" },
											},
											{
												type = "TextureButton",
												key = "moreBtn",
												normalTexture = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up",
												pushedTexture = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down",
												disabledTexture = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-DisabledTexture",
												highlightTexture = "Interface\\Buttons\\UI-Common-MouseHilight",
												size = { 28, 28 },
												points = { { "TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 5 } },
												scripts = { "OnClick" },
											},
											{
												type = "Button",
												key = "buyStackBtn",
												text = L["Stack"],
												textHeight = 12,
												size = {40, 20},
												points = {{"TOPLEFT", 45, -60 } },
												scripts = {"OnClick"},
											},
											{
												type = "Button",
												key = "buyMaxBtn",
												text = L["Max"],
												textHeight = 12,
												size = {40, 20},
												points = {{"TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0} },
												scripts = {"OnClick"},
											},
											{
												type = "Button",
												key = "okayBtn",
												text = L["Okay"],
												textHeight = 16,
												size = {80, 20},
												points = {{"TOPLEFT", 5, -90}},
												scripts = {"OnClick"},
											},
											{
												type = "Button",
												key = "closeBtn",
												text = L["Cancel"],
												textHeight = 16,
												size = {80, 20},
												points = {{"TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0} },
												scripts = {"OnClick"},
											},
										},
										handlers = {
											OnShow = function(self)
												if (private.splitIndex) then
													self.item:SetText(format("%s", GetMerchantItemLink(private.splitIndex)))
													self.quantityBox:SetNumber(1)
													self.quantityBox:SetFocus()
												end
											end,
											closeBtn = {
												OnClick = function()
													private.frame.confirmation:Hide()
												end
											},
											okayBtn = {
												OnClick = function(self)
													private:BuyItem(private.splitIndex,self:GetParent().quantityBox:GetNumber())
													private.frame.confirmation:Hide()
												end
											},
											buyMaxBtn = {
												OnClick = function(self)
													local maxAfford = TSM.Util:GetMaxAfford(private.splitIndex)
													local maxFit = TSM.Util:GetMaxFit(private.splitIndex)
													self:GetParent().quantityBox:SetNumber(min(maxFit,maxAfford))
												end
											},
											buyStackBtn = {
												OnClick = function(self)
													local maxStackSize = TSMAPI.Item:GetMaxStack(GetMerchantItemLink(private.splitIndex))
													self:GetParent().quantityBox:SetNumber(maxStackSize)
												end
											},
											lessBtn = {
												OnClick = function(self)
													local num = self:GetParent().quantityBox:GetNumber() - 1
													self:GetParent().quantityBox:SetNumber(max(num, 1))
												end,
											},
											moreBtn = {
												OnClick = function(self)
													local num = self:GetParent().quantityBox:GetNumber() + 1
													self:GetParent().quantityBox:SetNumber(max(num, 1))
												end,
											},
											quantityBox = {
												OnEditFocusGained = function(self)
													self:HighlightText()
												end,

												OnEnterPressed = function(self)
													private:BuyItem(private.splitIndex,self:GetNumber())
													private.frame.confirmation:Hide()
												end,
											},
										}
						},
					},
			},
			{
				type = "InputBox",
				key = "searchBar",
				name = "TSMVendoringSearchBar",
				text = SEARCH,
				textColor = { 1, 1, 1, 0.5 },
				size = { 210, 24 },
				points = { { "TOPLEFT", 5, -5 } },
				scripts = { "OnEditFocusGained", "OnEditFocusLost", "OnTextChanged", "OnEnterPressed" },
			},
			{
				type = "Button",
				key = "clearFilterBtn",
				name = "VendoringClearFilterBtn",
				text = L["Clear Filters"],
				textHeight = 14,
				size = { 80, 24 },
				points = { { "TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0} },
				scripts = { "OnClick" },
			},
			{
				type = "Button",
				key = "filterBtn",
				name = "TSMVendoringFilterButton",
				text = L["Filters >>"],
				textHeight = 14,
				size = { nil, 24 },
				points = { { "TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0 }, {"TOPRIGHT", -5, -5 }} ,
				scripts = { "OnClick" },
			},
			{
				type = "ScrollingTableFrame",
				key = "buyST",
				stCols = {
						{
							name = L["Item"],
							width = 0.7,
						},
						{
							name = L["Cost"],
							width = 0.3,
							align="RIGHT"
						},
					},
				scripts = {"OnEnter","OnClick","OnLeave" },
				points = { {"TOPLEFT", 5, -33 }, {"BOTTOMRIGHT", -5, 30}},
				stDisableSelection = true,
				sortInfo = {true, 1},
			},
		},
		handlers = {
			OnShow = function(self)
				private.frame = self
				private.frame.confirmation:Hide()
				TSMAPI.Design:SetFrameBackdropColor(private.frame.confirmation.splitFrame)
				private:UpdateBuyST(true)

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
							HighLightBox = {x = 0, y = -65, width = TOTAL_WIDTH, height = 350},
							ToolTipDir = "RIGHT",
							ToolTipText = L["This is where the items the merchant has for sale are listed.\n\nItems with a red number are things that you already know or cannot use.\n\nJust like the default UI, you may right click to buy a single item, or shift-left click to buy multiples."],
						},
					}

					self.helpBtn = CreateFrame("Button", nil, private.frame, "MainHelpPlateButton")
					self.helpBtn:SetPoint("TOPLEFT", 50, 100)
					self.helpBtn:SetScript("OnClick", function() TSM.MerchantTab:ToggleHelpPlate(private.frame, helpPlateInfo, self.helpBtn, true) end)
					self.helpBtn:SetScript("OnHide", function() if HelpPlate_IsShowing(helpPlateInfo) then TSM.MerchantTab:ToggleHelpPlate(private.frame, helpPlateInfo, self.helpBtn, false) end end)
					if not TSM.db.global.helpPlatesShown.buy then
						TSM.db.global.helpPlatesShown.buy = true
						TSM.MerchantTab:ToggleHelpPlate(private.frame, helpPlateInfo, self.helpBtn, false)
					end
				end

			end,
			searchBar = {
				OnEditFocusGained = function(self)
					self:SetTextColor(1, 1, 1, 1)
					if self:GetText() == SEARCH then
						self:SetText("")
					end
				end,
				OnEditFocusLost = function(self)
					if self:GetText() == "" or self:GetText() == SEARCH then
						self:SetTextColor(1, 1, 1, 0.5)
						self:SetText(SEARCH)
					end
				end,
				OnTextChanged = function(self)
					local text = self:GetText():trim()
					if text == SEARCH then
						text = ""
						private.nameFilter = nil
					else
						private.nameFilter = string.lower(text)
						private:UpdateBuyST(false)
					end
				end,
				OnEnterPressed = function(self)
					self:ClearFocus()
				end,
			},
			clearFilterBtn = {
				OnClick = function()
					SetMerchantFilter(1)
					private.frame.searchBar:SetText(SEARCH)
					private.nameFilter = nil
					private:UpdateBuyST(true)
				end
			},
			filterBtn = {
				OnClick = function(self)
					ToggleDropDownMenu(1, nil, MerchantFrame.lootFilter, "TSMVendoringFilterButton", self:GetWidth(), 0)
				end
			},
			buyST = {
				OnClick = function(_, data, self, button)
					if not data then return end

					if IsModifiedClick("DRESSUP") then
						HandleModifiedItemClick(GetMerchantItemLink(data.index))
						return
					end

					if IsShiftKeyDown() then
					   private.splitIndex = data.index
					   private.frame.confirmation:Show()

					   return
					end

					if button == "RightButton" then
						private:BuyItem(data.index,data.stackCount)
						return
					end
				end,
				OnEnter = function(_, data, self)
					if private.inspecting then
						ShowInspectCursor()
					else
						SetCursor("BUY_CURSOR")
					end

					private.hovering = true

					if not data or not data.itemLink then return end
					local color = TSMAPI.Design:GetInlineColor("link")
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					TSMAPI.Util:SafeTooltipLink(data.itemLink)
					GameTooltip:Show()
				end,
				OnLeave = function()
					ResetCursor()
					GameTooltip:ClearLines()
					GameTooltip:Hide()
					BattlePetTooltip:Hide()
					private.hovering = false
				end
			}
		}
	}

	return frameInfo
end

function Buy:OnMerchantShow()
	if not private.frame then
		return
	end

	private.frame.searchBar:SetTextColor(1, 1, 1, 0.5)
	private.frame.searchBar:SetText(SEARCH)
	private.nameFilter = nil

	private:UpdateBuyST(true)
end

function Buy:BeginInspect()
	private.inspecting = true
	ShowInspectCursor()
end

function Buy:EndInspect()
	private.inspecting = false

	if private.frame and private.frame:IsVisible() then
		if private.hovering then
			SetCursor("BUY_CURSOR")
		else
			ResetCursor()
		end
	end
end

function Buy:OnMerchantUpdate()
	private:UpdateBuyST(true)
end

function private:BuyItem(index,quantity)
	local maxStack = GetMerchantItemMaxStack(index)

	while quantity > 0 do
		BuyMerchantItem(index,math.min(quantity,maxStack))
		quantity = quantity - maxStack
	end
end


function private:IsKnown(itemLink)
	if not TSMVendoringScanTooltip then
		CreateFrame("GameTooltip", "TSMVendoringScanTooltip", UIParent, "GameTooltipTemplate")
	end
	TSMVendoringScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	TSMVendoringScanTooltip:ClearLines()
	TSMVendoringScanTooltip:SetHyperlink(itemLink)

	local result = nil
	for id = 1, TSMVendoringScanTooltip:NumLines() do
		local text = _G["TSMVendoringScanTooltipTextLeft" .. id]
		text = text and text:GetText()
		if text and (text == ITEM_SPELL_KNOWN) then
			result = true
			break
		end
	end
	TSMVendoringScanTooltip:Hide()
	return result
end

function private:UpdateBuyST(refresh)
	if not private.frame or not private.frame.buyST then
		return
	end

	if refresh then
		private.vendorItems = {}

		local numMerchantItems = GetMerchantNumItems();

		local name, texture, price, stackCount, numAvailable, isUsable, extendedCost
		local itemCostTexture, itemCostValue, itemCostLink

		for index = 1, numMerchantItems do
			local name, texture, price, stackCount, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(index)
			local itemLink = GetMerchantItemLink(index)

			if itemLink then
				local displayCost = ""
				local displayCostSeparator = ""
				local displayText = ""

				local sortPrice = price

				if not isUsable then
					displayText = "|cffff0000"
				elseif private:IsKnown(itemLink) then
					displayText = "|cffff0000"
				end

				displayText = format("%s%d |T%s:0|t %s", displayText,stackCount, texture,itemLink)

				if numAvailable > -1 then
					displayText = format("%s |cffff0000(%d)",displayText,numAvailable)
				end

				if extendedCost then
					local costCount = GetMerchantItemCostInfo(index)
					for i = 1,costCount do
						itemCostTexture, itemCostValue, itemCostLink = GetMerchantItemCostItem(index,i)

						sortPrice = sortPrice + itemCostValue / 100000

						if itemCostTexture and itemCostValue then
							displayCost = format("%s%s%d |T%s:0|t",displayCost,displayCostSeparator,itemCostValue,itemCostTexture)
						else
							displayCost = format("%s%s%d", displayCost,displayCostSeparator,itemCostValue)
						end

						displayCostSeparator = ", "
					end
				end

				if price > 0 then
					displayCost = format("%s%s%s",displayCost,displayCostSeparator,TSMAPI:MoneyToString(price, "OPT_TRIM"))
				end

				tinsert(private.vendorItems, {
								cols = {
									{ value = displayText, sortArg = name },
									{ value = displayCost, sortArg = sortPrice },
								},
								name = string.lower(name),
								index = index,
								itemLink = itemLink,
								stackCount = stackCount
							})
			end
		end
	end

	if private.nameFilter == nil or private.nameFilter == "" then
		private.frame.buyST:SetData(private.vendorItems)
	else

		local stData = {}

		for j,row in ipairs(private.vendorItems) do
			if string.find(row.name,private.nameFilter) then
				tinsert(stData,row)
			end
		end

		private.frame.buyST:SetData(stData)
	end
end
