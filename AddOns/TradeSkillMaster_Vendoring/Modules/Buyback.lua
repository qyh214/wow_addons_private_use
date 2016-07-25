-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Vendoring                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_vendoring           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Buyback = TSM:NewModule("Buyback", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Vendoring") -- loads the localization table

local private = { frame = nil, inspecting = false, hovering = false }

function Buyback:CreateTab()
	local BFC = TSMAPI.GUI:GetBuildFrameConstants()

	local frameInfo = {
		type = "Frame",
		key = "buybackTab",
		hidden = true,
		points = "ALL",
		scripts = {"OnShow"},
		children = {
			{
				type = "ScrollingTableFrame",
				key = "buybackST",
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
				scripts = {"OnEnter", "OnLeave", "OnClick" },
				points = {{"TOPLEFT", 5, -5}, {"BOTTOMRIGHT", -5, 30}},
				sortInfo = {true},
				stDisableSelection = true
			}
		},
		handlers = {
			OnShow = function(self)
				private.frame = self
				private:UpdateBuybackST()

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
							ToolTipText = L["This is where you can buyback items from the merchant.  Right click on an item to buy it back."],
						},
					}

					self.helpBtn = CreateFrame("Button", nil, private.frame, "MainHelpPlateButton")
					self.helpBtn:SetPoint("TOPLEFT", 50, 100)
					self.helpBtn:SetScript("OnClick", function() TSM.MerchantTab:ToggleHelpPlate(private.frame, helpPlateInfo, self.helpBtn, true) end)
					self.helpBtn:SetScript("OnHide", function() if HelpPlate_IsShowing(helpPlateInfo) then TSM.MerchantTab:ToggleHelpPlate(private.frame, helpPlateInfo, self.helpBtn, false) end end)
					if not TSM.db.global.helpPlatesShown.buyback then
						TSM.db.global.helpPlatesShown.buyback = true
						TSM.MerchantTab:ToggleHelpPlate(private.frame, helpPlateInfo, self.helpBtn, false)
					end
				end
			end,
			buybackST = {
				OnClick = function(_, data, self, button)
					if not data then return end

					if IsModifiedClick("DRESSUP") then
						HandleModifiedItemClick(data.itemLink)
						return
					end

					if button == "RightButton" then
						BuybackItem(data.index)
					end
				end,
				OnEnter = function(_, data, self)
					if not data then return end

					if private.inspecting then
						ShowInspectCursor()
					else
						SetCursor("BUY_CURSOR")
					end

					private.hovering = true

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

function Buyback:OnMerchantShow()
	private:UpdateBuybackST()
end

function Buyback:OnMerchantUpdate()
	private:UpdateBuybackST()
end

function Buyback:OnBagUpdate()
	private:UpdateBuybackST()
end

function Buyback:BeginInspect()
	private.inspecting = true
	if private.hovering then
		ShowInspectCursor()
	end
end

function Buyback:EndInspect()
	private.inspecting = false

	if private.frame and private.frame:IsVisible() then
		if private.hovering then
			SetCursor("BUY_CURSOR")
		else
			ResetCursor()
		end
	end
end

function private:UpdateBuybackST()
	if not private.frame or not private.frame.buybackST then
		return
	end

	local numBuybackItems = GetNumBuybackItems()
	local stData = {}

	for index = 1, numBuybackItems do
		local buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable = GetBuybackItemInfo(index)
		local itemLink = GetBuybackItemLink(index)

		local displayCost = ""
		local displayText = ""
		local displayText = format("%d |T%s:0|t %s", buybackQuantity, buybackTexture, itemLink)

		if buybackPrice > 0 then
			displayCost = TSMAPI:MoneyToString(buybackPrice, "OPT_TRIM")
		end

		if buybackNumAvailable > 0 then
			displayText = format("%s (%d)",displayText,buybackNumAvailable)
		end

		if itemLink then
			tinsert(stData, {
							cols = {
								{ value = displayText, sortArg = buybackName },
								{ value = displayCost, sortArg = buybackPrice },
							},
							index = index,
							itemLink = itemLink,
						})
		end
	end

	private.frame.buybackST:SetData(stData)
end
