local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local pairs = pairs

function S:StyleTooltips()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip) then return end

	for _, tt in pairs({
		_G.ItemRefTooltip,
		_G.ItemRefShoppingTooltip1,
		_G.ItemRefShoppingTooltip2,
		_G.AutoCompleteBox,
		_G.FriendsTooltip,
		_G.EmbeddedItemTooltip,
		_G.ReputationParagonTooltip,
		_G.GameTooltip,
		_G.WorldMapTooltip,
		_G.ShoppingTooltip1,
		_G.ShoppingTooltip2,
		_G.QuickKeybindTooltip,
		-- ours
		_G.ElvUIConfigTooltip,
		_G.ElvUISpellBookTooltip
	}) do
		TT:SetStyle(tt)
	end
end

function S:TooltipFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip) then return end

	S:StyleTooltips()
	S:HandleCloseButton(_G.ItemRefCloseButton)

	-- EmbeddedItemTooltip (also Paragon Reputation)
	local EmbeddedTT = _G.EmbeddedItemTooltip.ItemTooltip
	S:HandleIcon(EmbeddedTT.Icon, true)
	S:HandleIconBorder(EmbeddedTT.IconBorder, EmbeddedTT.Icon.backdrop)

	-- Skin GameTooltip Status Bar
	_G.GameTooltipStatusBar:SetStatusBarTexture(E.media.normTex)
	_G.GameTooltipStatusBar:CreateBackdrop('Transparent')
	_G.GameTooltipStatusBar:ClearAllPoints()
	_G.GameTooltipStatusBar:Point('TOPLEFT', _G.GameTooltip, 'BOTTOMLEFT', E.Border, -(E.Spacing * 3))
	_G.GameTooltipStatusBar:Point('TOPRIGHT', _G.GameTooltip, 'BOTTOMRIGHT', -E.Border, -(E.Spacing * 3))
	E:RegisterStatusBar(_G.GameTooltipStatusBar)

	-- Tooltip Styling
	TT:SecureHook('GameTooltip_ShowStatusBar') -- Skin Status Bars
	TT:SecureHook('GameTooltip_ShowProgressBar') -- Skin Progress Bars
	TT:SecureHook('GameTooltip_ClearProgressBars')
	TT:SecureHook('GameTooltip_AddQuestRewardsToTooltip') -- Color Progress Bars
	TT:SecureHook('SharedTooltip_SetBackdropStyle', 'SetStyle') -- This also deals with other tooltip borders like AzeriteEssence Tooltip
end

S:AddCallback('TooltipFrames')
