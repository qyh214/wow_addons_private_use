-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Vendoring                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_vendoring           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local MerchantTab = TSM:NewModule("MerchantTab", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Vendoring") -- loads the localization table

local private = {frame=nil}

function MerchantTab:OnEnable()
	MerchantTab:RegisterEvent("MERCHANT_SHOW", function() TSMAPI.Delay:AfterTime(0, private.OnMerchantShow) end)
	MerchantTab:RegisterEvent("MERCHANT_UPDATE",private.OnMerchantUpdate)
	MerchantTab:RegisterEvent("PLAYER_MONEY", private.UpdateMoneyAndRepair)
	MerchantTab:RegisterEvent("GUILDBANK_UPDATE_MONEY", private.UpdateMoneyAndRepair)
	MerchantTab:RegisterEvent("GUILDBANK_UPDATE_WITHDRAWMONEY",private.UpdateMoneyAndRepair)
	MerchantTab:RegisterEvent("CURRENCY_DISPLAY_UPDATE", private.UpdateMoney)
	MerchantTab:RegisterEvent("UPDATE_INVENTORY_DURABILITY", private.UpdateRepair)
	MerchantTab:RegisterEvent("MODIFIER_STATE_CHANGED", private.ModifierChanged)

	TSMAPI.Inventory:RegisterCallback(private.OnBagUpdate)

	MerchantTab:RawHook("MerchantFrame_UpdateBuybackInfo", function(...) if MerchantFrame.selectedTab == 2 then return MerchantTab.hooks.MerchantFrame_UpdateBuybackInfo(...) end end, true)
	MerchantTab:RawHook("MerchantFrame_UpdateMerchantInfo", function(...) if MerchantFrame.selectedTab == 1 then return MerchantTab.hooks.MerchantFrame_UpdateMerchantInfo(...) end end, true)
	MerchantTab:RawHook("MerchantFrame_Update", function(...) if MerchantFrame.selectedTab == 1 or MerchantFrame.selectedTab == 2 then return MerchantTab.hooks.MerchantFrame_Update(...) else private:OnMerchantUpdate() end end,true)
end

function MerchantTab:ToggleHelpPlate(frame, info, btn, isUser)
	if not HelpPlate_IsShowing(info) then
		HelpPlate:SetParent(frame)
		HelpPlate:SetFrameStrata("DIALOG")
		HelpPlate_Show(info, frame, btn, isUser)
	else
		HelpPlate:SetParent(UIParent)
		HelpPlate:SetFrameStrata("DIALOG")
		HelpPlate_Hide(isUser)
	end
end

function private:ModifierChanged()
	if private.frame and private.frame:IsVisible() then
		if IsControlKeyDown() then
			TSM.QuickSell:BeginInspect()
			TSM.Buy:BeginInspect()
			TSM.Buyback:BeginInspect()
		else
			TSM.Buyback:EndInspect()
			TSM.QuickSell:EndInspect()
			TSM.Buy:EndInspect()
		end
	end
end

function private:OnBagUpdate()
	if private.frame and private.frame:IsVisible() then
		TSM.Buyback:OnBagUpdate()
		TSM.QuickSell:OnBagUpdate()
	end
end

function private:UpdateMoneyAndRepair()
	private:UpdateMoney()
	private:UpdateRepair()
end

function private:UpdateMoney()

	if not private.frame then
		return
	end

	if not private.frame:IsVisible() then
		return
	end

	private.frame.moneyText:SetText(TSMAPI:MoneyToString(GetMoney(), "OPT_ICON"))

	local currencies = { GetMerchantCurrencies() };

	local currencyText = ""

	if #currencies > 0 then
		for index = 1, #currencies do

			local name, count, icon = GetCurrencyInfo(currencies[index]);
			currencyText = format("%s %d |T%s:0|t",currencyText,count, icon)
		end
	end

	private.frame.currencyText:SetText(currencyText)

	-- Hide default UI
	if MerchantPageText then MerchantPageText:Hide() end
	if MerchantFrameLootFilter then MerchantFrameLootFilter:Hide() end
	if MerchantMoneyFrame then MerchantMoneyFrame:Hide() end
	if MerchantMoneyInset then MerchantMoneyInset:Hide() end
	if MerchantExtraCurrencyInset then MerchantExtraCurrencyInset:Hide() end
	if MerchantExtraCurrencyBg then MerchantExtraCurrencyBg:Hide() end
	if MerchantMoneyBg then MerchantMoneyBg:Hide() end

	for i = 1, 6 do
		local tokenButton = _G["MerchantToken"..i]
		if (tokenButton) then
			tokenButton:Hide()
		else
			break
		end
	end

end

function private:UpdateRepair()
	if not private.frame then
		return
	end

	if not private.frame:IsVisible() then
		return
	end

	-- Hide default UI
	if MerchantRepairItemButton then MerchantRepairItemButton:Hide() end
	if MerchantGuildBankRepairButton then MerchantGuildBankRepairButton:Hide() end
	if MerchantRepairAllButton then MerchantRepairAllButton:Hide() end

	if CanMerchantRepair() then
		private.frame.repairBtn:Show()
	else
		private.frame.repairBtn:Hide()
	end

	local repairAllCost, canRepair = GetRepairAllCost()

	if (canRepair and (repairAllCost > 0)) then
		private.frame.repairBtn:Enable()
	else
		private.frame.repairBtn:Disable()
	end
end

function private:OnMerchantShow()
	private.frame = private.frame or private:CreateMerchantTab()
	local currentTab = PanelTemplates_GetSelectedTab(MerchantFrame)

	TSM.QuickSell:SellTrash()

	if TSM.db.global.defaultMerchantTab then
		for i=1, MerchantFrame.numTabs do
			if _G["MerchantFrameTab"..i].isTSMTab then
				currentTab = i
				break
			end
		end

		TSM.Buy:OnMerchantShow()
		TSM.Buyback:OnMerchantShow()
		TSM.QuickSell:OnMerchantShow()
		private:UpdateMoneyAndRepair()
	end

	MerchantFrameTab2:Click()
	_G["MerchantFrameTab"..currentTab]:Click()
end

function private:OnMerchantUpdate()
	TSM.Buy:OnMerchantUpdate()
	TSM.Buyback:OnMerchantUpdate()
	TSM.QuickSell:OnMerchantUpdate()
end

function private:CreateMerchantTab()

	local BFC = TSMAPI.GUI:GetBuildFrameConstants()

	local frameInfo = {
		type = "Frame",
		parent = MerchantFrame,
		hidden = true,
		mouse = true,
		points = {{"TOPLEFT"}, {"BOTTOMRIGHT", 40, 0}},
		children = {
			{
				type = "TSMLogo",
				size = {80, 80},
				points = {{"CENTER", BFC.PARENT, "TOPLEFT", 25, -25}},
			},
			{
				type = "Text",
				text = "TSM_Vendoring - " .. TSM._version,
				textHeight = 18,
				justify = {"CENTER", "MIDDLE"},
				points = {{"TOPLEFT", 40, -5}, {"BOTTOMRIGHT", BFC.PARENT, "TOPRIGHT", -5, -25}},
			},
			{
				type = "Button",
				key = "closeBtn",
				text = "X",
				textHeight = 19,
				size = {20, 20},
				points = {{"TOPRIGHT", -5, -5}},
				scripts = {"OnClick"},
			},
			{
				type = "VLine",
				size = {2, 30},
				points = {{"TOPRIGHT", -30, -1}},
			},
			{
				type = "HLine",
				offset = -28,
			},
			{
				type = "Button",
				key = "buyBtn",
				text = L["Buy"],
				textHeight = 15,
				size = {55, 20},
				points = {{"TOPLEFT", 70, -40}},
				scripts = {"OnClick"},
			},
			{
				type = "Button",
				key = "buybackBtn",
				text = L["Buyback"],
				textHeight = 15,
				size = {65, 20},
				points = {{"TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0}},
				scripts = {"OnClick"},
			},
			{
				type = "Button",
				key = "groupsBtn",
				text = L["TSM Groups"],
				textHeight = 15,
				size = {90, 20},
				points = {{"TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0}},
				scripts = {"OnClick"},
			},
			{
				type = "Button",
				key = "quickSellBtn",
				text = L["Quick Sell"],
				textHeight = 15,
				size = {75, 20},
				points = {{"TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0}},
				scripts = {"OnClick"},
			},
			{
				type = "HLine",
				offset = -70,
			},
			{
				type = "Frame",
				key = "content",
				points = {{"TOPLEFT", 0, -70}, {"BOTTOMRIGHT"}},
				children = {
					TSM.Buy:CreateTab(),
					TSM.Buyback:CreateTab(),
					TSM.Groups:CreateTab(),
					TSM.QuickSell:CreateTab(),
				},
			},
			{
				type = "Text",
				key = "moneyText",
				points = {{"BOTTOMLEFT", BFC.PARENT, 5, 5 }}
			},
			{
				type = "Text",
				key = "currencyText",
				points = {{"TOPLEFT", BFC.PREV, "TOPRIGHT", 5,0 }}
			},
			{
				type = "Button",
				key = "repairBtn",
				text = L["Repair"],
				textHeight = 15,
				size = {50,20},
				points = {{"BOTTOMRIGHT", BFC.PARENT, -5, 5}},
				scripts = {"OnClick", "OnEnter", "OnLeave"}
			},
		},
		handlers = {
			closeBtn = {
				OnClick = CloseMerchant
			},
			buyBtn = {
				OnClick = private.OnTabButtonClick,
			},
			buybackBtn = {
				OnClick = private.OnTabButtonClick,
			},
			groupsBtn = {
				OnClick = private.OnTabButtonClick,
			},
			quickSellBtn = {
				OnClick = private.OnTabButtonClick,
			},
			repairBtn = {
				OnClick = function()
					if IsShiftKeyDown() then
						RepairAllItems(1)
					else
						RepairAllItems()
					end
				end,
				OnEnter = function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

					local repairAllCost, canRepair = GetRepairAllCost();
					if ( canRepair and (repairAllCost > 0) ) then
						GameTooltip:SetText(REPAIR_ALL_ITEMS);
						SetTooltipMoney(GameTooltip, repairAllCost);

						if CanGuildBankRepair() then
							local amount = GetGuildBankWithdrawMoney();
							local guildBankMoney = GetGuildBankMoney();
							if ( amount == -1 ) then
								-- Guild leader shows full guild bank amount
								amount = guildBankMoney;
							else
								amount = min(amount, guildBankMoney);
							end
							GameTooltip:AddLine(GUILDBANK_REPAIR, nil, nil, nil, 1)
							SetTooltipMoney(GameTooltip, amount, "GUILD_REPAIR");

							GameTooltip:AddLine(" ",nil,nil,nil,false)
							GameTooltip:AddLine(L["Hold shift to repair with guild bank"],1,1,1,1)
						end

						GameTooltip:Show()
					end
				end,
				OnLeave = function()
					GameTooltip:Hide()
				end
			}
		}
	}

	local frame = TSMAPI.GUI:BuildFrame(frameInfo)
	TSMAPI.Design:SetFrameBackdropColor(frame)

	for i=1, MerchantFrame.numTabs do
		if not _G["MerchantFrameTab"..i].isTSMTab then
			_G["MerchantFrameTab"..i]:HookScript("OnClick", private.OnOtherTabClick)
		end
	end

	local n = MerchantFrame.numTabs + 1
	local tab = CreateFrame("Button", "MerchantFrameTab"..n, MerchantFrame, "FriendsFrameTabTemplate")
	tab:Hide()
	tab:SetID(n)
	tab:SetText(TSMAPI.Design:GetInlineColor("link2").."TSM_Vendoring|r")
	tab:SetNormalFontObject(GameFontHighlightSmall)
	tab.isTSMTab = true
	tab:SetPoint("LEFT", _G["MerchantFrameTab"..n-1], "RIGHT", -16, 0)
	tab:Show()
	tab:SetScript("OnClick", private.OnTabClick)
	PanelTemplates_SetNumTabs(MerchantFrame, n)
	PanelTemplates_EnableTab(MerchantFrame, n)
	frame.tab = tab

	TSMAPI.Design:SetIconRegionColor(frame.moneyText)

	return frame
end

function private.OnTabClick(self)
	PanelTemplates_SetTab(MerchantFrame, self:GetID())

	MerchantFrameInset:Hide()
	MerchantFramePortraitFrame:Hide()
	MerchantFrameBg:Hide()
	if MerchantFrameText then MerchantFrameText:Hide() end
	MerchantFrameTitleBg:Hide()
	MerchantFrameTitleText:Hide()
	MerchantFrameCloseButton:Hide()

	for i = 1, 12 do
	   local merchantItem = _G["MerchantItem"..i]
	   if merchantItem then merchantItem:Hide() end
	end

	if MerchantBuyBackItem then MerchantBuyBackItem:Hide() end

	MerchantNameText:Hide()
	MerchantFrameLeftBorder:Hide()
	MerchantFrameTopBorder:Hide()
	MerchantFrameRightBorder:Hide()
	MerchantFrameBottomBorder:Hide()
	MerchantFrameTopTileStreaks:Hide()
	MerchantFrameTopRightCorner:Hide()
	MerchantFrameBotLeftCorner:Hide()
	MerchantFrameBotRightCorner:Hide()
	MerchantNextPageButton:Hide()
	MerchantPrevPageButton:Hide()
	MerchantRepairText:Hide()
	MerchantFrameBottomLeftBorder:Hide()
	MerchantFrameBottomRightBorder:Hide()
	MerchantFrameBotLeftCorner:Hide()
	MerchantFrameBotRightCorner:Hide()
	MerchantFrameBtnCornerLeft:Hide()
	MerchantFrameBtnCornerRight:Hide()
	MerchantFrameButtonBottomBorder:Hide()

	BuybackBG:Hide()

	private.frame:Show()

	if TSM.db.global.defaultPage == 1 then
		private.frame.buyBtn:Click()
	elseif TSM.db.global.defaultPage == 2 then
		private.frame.buybackBtn:Click()
	elseif TSM.db.global.defaultPage == 3 then
		private.frame.groupsBtn:Click()
	elseif TSM.db.global.defaultPage == 4 then
		private.frame.quickSellBtn:Click()
	end

	-- Detect SellJunk
	if IsAddOnLoaded("SellJunk") then LibStub("AceAddon-3.0"):GetAddon("SellJunk").sellButton:Hide() end

	-- Detect Scrap
	if ScrapVisualizer then
		ScrapVisualizer:Hide()
	end

	private:UpdateMoney()
	private:UpdateRepair()
end

function private.OnOtherTabClick(a,b,c)

	if not private.frame then return end
	private.frame:Hide()

	-- Let other addons fend for themselves.
	if MerchantFrame.selectedTab > 2 then
		return
	end

	MerchantNameText:Show()
	MerchantFrameLeftBorder:Show()
	MerchantFrameTopBorder:Show()
	MerchantFrameRightBorder:Show()
	MerchantFrameBottomBorder:Show()
	MerchantFrameTopTileStreaks:Show()
	MerchantFrameTopRightCorner:Show()
	MerchantFrameBotLeftCorner:Show()
	MerchantFrameBotRightCorner:Show()
	MerchantFrameBottomLeftBorder:Show()
	MerchantFrameBottomRightBorder:Show()

	MerchantFrameLootFilter:Show()
	MerchantMoneyFrame:Show()
	MerchantMoneyInset:Show()
	MerchantMoneyBg:Show()
	MerchantExtraCurrencyInset:Show()
	MerchantExtraCurrencyBg:Show()
	MerchantPageText:Show()

	MerchantFrameInset:Show()
	MerchantFramePortrait:Show()
	MerchantFramePortraitFrame:Show()
	MerchantFrameBg:Show()
	if MerchantFrameText then MerchantFrameText:Show() end
	MerchantFrameTitleBg:Show()
	MerchantFrameTitleText:Show()
	MerchantFrameCloseButton:Show()
	MerchantNextPageButton:Show()
	MerchantPrevPageButton:Show()
	MerchantRepairText:Show()
	BuybackBG:Show()

	if MerchantToken1 then MerchantToken1:Show() end

	for i = 1, 12 do
	   local merchantItem = _G["MerchantItem"..i]
	   if merchantItem then merchantItem:Show() end
	end

	if MerchantBuyBackItem then MerchantBuyBackItem:Show() end

	-- Detect SellJunk
	if IsAddOnLoaded("SellJunk") then LibStub("AceAddon-3.0"):GetAddon("SellJunk").sellButton:Show() end

	MerchantFrame_Update()
end

function private.OnTabButtonClick(self)
	private.frame.content.quickSellTab:Hide()
	private.frame.content.groupsTab:Hide()
	private.frame.content.buybackTab:Hide()
	private.frame.content.buyTab:Hide()

	private.frame.quickSellBtn:UnlockHighlight()
	private.frame.groupsBtn:UnlockHighlight()
	private.frame.buybackBtn:UnlockHighlight()
	private.frame.buyBtn:UnlockHighlight()
	self:LockHighlight()

	if self == private.frame.quickSellBtn then
		private.frame.content.quickSellTab:Show()
	elseif self == private.frame.groupsBtn then
		private.frame.content.groupsTab:Show()
	elseif self == private.frame.buyBtn then
		private.frame.content.buyTab:Show()
	elseif self == private.frame.buybackBtn then
		private.frame.content.buybackTab:Show()
	end
end