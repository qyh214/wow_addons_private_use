local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack
local CreateFrame = CreateFrame

local NUM_GUILDBANK_ICONS_PER_ROW = 10
local NUM_GUILDBANK_ICON_ROWS = 9
local NUM_GUILDBANK_ICONS_SHOWN = NUM_GUILDBANK_ICONS_PER_ROW * NUM_GUILDBANK_ICON_ROWS

function S:Blizzard_GuildBankUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gbank) then return end

	local GuildBankFrame = _G.GuildBankFrame
	GuildBankFrame:StripTextures()
	GuildBankFrame:CreateBackdrop('Transparent')
	GuildBankFrame.backdrop:Point('TOPLEFT', 8, -11)
	GuildBankFrame.backdrop:Point('BOTTOMRIGHT', 0, 6)
	GuildBankFrame:Width(770)
	GuildBankFrame:Height(450)
	GuildBankFrame.Emblem:Kill()

	for _, child in next, { GuildBankFrame:GetChildren() } do
		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			S:HandleCloseButton(child)
		end
	end

	for i = 1, _G.MAX_GUILDBANK_TABS do
		local tab = _G['GuildBankTab'..i]
		tab:StripTextures()

		local button = tab.Button
		local icon = button.IconTexture
		local texture = icon:GetTexture()
		button:StripTextures()
		button:StyleButton(true)
		button:SetTemplate(nil, true)
		icon:SetTexture(texture)
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	for i = 1, 7 do
		local column = _G.GuildBankFrame['Column'..i]
		column:StripTextures()

		for x = 1, 14 do
			local button = column['Button'..x]
			button:StripTextures()
			button:StyleButton()
			button:SetTemplate('Transparent')

			button.icon:SetInside()
			button.icon:SetTexCoord(unpack(E.TexCoords))
		end
	end

	S:HandleButton(GuildBankFrame.BuyInfo.PurchaseButton)
	S:HandleButton(GuildBankFrame.DepositButton)
	S:HandleButton(GuildBankFrame.WithdrawButton)
	GuildBankFrame.WithdrawButton:ClearAllPoints()
	GuildBankFrame.WithdrawButton:Point('LEFT', GuildBankFrame.DepositButton, 'LEFT', -102, 0)

	local GuildBankInfoSaveButton = _G.GuildBankInfoSaveButton
	S:HandleButton(GuildBankInfoSaveButton)

	local GuildBankInfoScrollFrame = _G.GuildBankInfoScrollFrame
	GuildBankInfoScrollFrame:StripTextures()
	GuildBankInfoScrollFrame:Width(685)

	S:HandleScrollBar(_G.GuildBankInfoScrollFrameScrollBar)
	_G.GuildBankInfoScrollFrameScrollBar:ClearAllPoints()
	_G.GuildBankInfoScrollFrameScrollBar:Point('TOPRIGHT', GuildBankInfoScrollFrame, 'TOPRIGHT', 29, -12)
	_G.GuildBankInfoScrollFrameScrollBar:Point('BOTTOMRIGHT', GuildBankInfoScrollFrame, 'BOTTOMRIGHT', 0, 17)

	local GuildBankTabInfoEditBox = _G.GuildBankTabInfoEditBox
	GuildBankTabInfoEditBox:Width(685)

	local GuildBankTransactionsScrollFrame = _G.GuildBankTransactionsScrollFrame
	GuildBankTransactionsScrollFrame:StripTextures()

	S:HandleScrollBar(_G.GuildBankTransactionsScrollFrameScrollBar)
	_G.GuildBankTransactionsScrollFrameScrollBar:ClearAllPoints()
	_G.GuildBankTransactionsScrollFrameScrollBar:Point('TOPRIGHT', GuildBankTransactionsScrollFrame, 'TOPRIGHT', 29, -8)
	_G.GuildBankTransactionsScrollFrameScrollBar:Point('BOTTOMRIGHT', GuildBankTransactionsScrollFrame, 'BOTTOMRIGHT', 0, 16)

	GuildBankFrame.bg = CreateFrame('Frame', nil, GuildBankFrame)
	GuildBankFrame.bg:SetTemplate()
	GuildBankFrame.bg:Point('TOPLEFT', 24, -64)
	GuildBankFrame.bg:Point('BOTTOMRIGHT', -18, 62)
	GuildBankFrame.bg:SetFrameLevel(GuildBankFrame:GetFrameLevel())

	_G.GuildBankLimitLabel:Point('CENTER', GuildBankFrame.TabLimitBG, 'CENTER', -40, -5)

	for i = 1, 4 do
		local tab = _G['GuildBankFrameTab'..i]

		S:HandleTab(tab)

		if i == 1 then
			tab:ClearAllPoints()
			tab:Point('BOTTOMLEFT', GuildBankFrame, 'BOTTOMLEFT', 0, -24)
		end
	end

	_G.GuildBankTab1:Point('TOPLEFT', GuildBankFrame, 'TOPRIGHT', E.PixelMode and -1 or 2, -36)
	_G.GuildBankTab2:Point('TOPLEFT', _G.GuildBankTab1, 'BOTTOMLEFT', 0, 7)
	_G.GuildBankTab3:Point('TOPLEFT', _G.GuildBankTab2, 'BOTTOMLEFT', 0, 7)
	_G.GuildBankTab4:Point('TOPLEFT', _G.GuildBankTab3, 'BOTTOMLEFT', 0, 7)
	_G.GuildBankTab5:Point('TOPLEFT', _G.GuildBankTab4, 'BOTTOMLEFT', 0, 7)
	_G.GuildBankTab6:Point('TOPLEFT', _G.GuildBankTab5, 'BOTTOMLEFT', 0, 7)

	if not E:IsAddOnEnabled('ArkInventory') then
		S:HandleIconSelectionFrame(_G.GuildBankPopupFrame, NUM_GUILDBANK_ICONS_SHOWN, 'GuildBankPopupButton', 'GuildBankPopup')
	end
end

S:AddCallbackForAddon('Blizzard_GuildBankUI')
