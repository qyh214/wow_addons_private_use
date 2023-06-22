local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next, unpack = next, unpack
local ipairs, pairs = ipairs, pairs

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local PlayerHasToy = PlayerHasToy
local hooksecurefunc = hooksecurefunc
local BAG_ITEM_QUALITY_COLORS = BAG_ITEM_QUALITY_COLORS
local GetItemQualityColor = GetItemQualityColor
local C_Heirloom_PlayerHasHeirloom = C_Heirloom.PlayerHasHeirloom
local C_TransmogCollection_GetSourceInfo = C_TransmogCollection.GetSourceInfo

local QUALITY_7_R, QUALITY_7_G, QUALITY_7_B = GetItemQualityColor(7)

local function clearBackdrop(backdrop)
	backdrop:SetBackdropColor(0, 0, 0, 0)
end

local function toyTextColor(text, r, g, b)
	if r == 0.33 and g == 0.27 and b == 0.2 then
		text:SetTextColor(0.4, 0.4, 0.4)
	elseif r == 1 and g == 0.82 and b == 0 then
		text:SetTextColor(0.9, 0.9, 0.9)
	end
end

local function petNameColor(iconBorder, r, g, b)
	local parent = iconBorder:GetParent()
	if not parent.name then return end

	if parent.isDead and parent.isDead:IsShown() then
		parent.name:SetTextColor(0.9, 0.3, 0.3)
	elseif r and parent.owned then
		parent.name:SetTextColor(r, g, b)
	else
		parent.name:SetTextColor(0.4, 0.4, 0.4)
	end
end

local function mountNameColor(object)
	local button = object:GetParent()
	local name = button.name

	if name:GetFontObject() == _G.GameFontDisable then
		name:SetTextColor(0.4, 0.4, 0.4)
	else
		if button.background then
			local _, g, b = button.background:GetVertexColor()
			if g == 0 and b == 0 then
				name:SetTextColor(0.9, 0.3, 0.3)
				return
			end
		end

		name:SetTextColor(0.9, 0.9, 0.9)
	end
end

local function selectedTextureSetShown(texture, shown) -- used sets list
	local parent = texture:GetParent()
	local icon = parent.icon or parent.Icon
	if shown then
		parent.backdrop:SetBackdropBorderColor(1, .8, .1)
		icon.backdrop:SetBackdropBorderColor(1, .8, .1)
	else
		local r, g, b = unpack(E.media.bordercolor)
		parent.backdrop:SetBackdropBorderColor(r, g, b)
		icon.backdrop:SetBackdropBorderColor(r, g, b)
	end
end

local function selectedTextureShow(texture) -- used for pets/mounts
	local parent = texture:GetParent()
	parent.backdrop:SetBackdropBorderColor(1, .8, .1)
	parent.icon.backdrop:SetBackdropBorderColor(1, .8, .1)
end

local function selectedTextureHide(texture) -- used for pets/mounts
	local parent = texture:GetParent()
	if not parent.hovered then
		local r, g, b = unpack(E.media.bordercolor)
		parent.backdrop:SetBackdropBorderColor(r, g, b)
		parent.icon.backdrop:SetBackdropBorderColor(r, g, b)
	end

	if parent.petList then
		petNameColor(parent.iconBorder, parent.iconBorder:GetVertexColor())
	end
end

local function buttonOnEnter(button)
	local r, g, b = unpack(E.media.rgbvaluecolor)
	local icon = button.icon or button.Icon
	button.backdrop:SetBackdropBorderColor(r, g, b)
	icon.backdrop:SetBackdropBorderColor(r, g, b)
	button.hovered = true
end

local function buttonOnLeave(button)
	local icon = button.icon or button.Icon
	if button.selected or (button.SelectedTexture and button.SelectedTexture:IsShown()) then
		button.backdrop:SetBackdropBorderColor(1, .8, .1)
		icon.backdrop:SetBackdropBorderColor(1, .8, .1)
	else
		local r, g, b = unpack(E.media.bordercolor)
		button.backdrop:SetBackdropBorderColor(r, g, b)
		icon.backdrop:SetBackdropBorderColor(r, g, b)
	end
	button.hovered = nil
end

local function JournalScrollButtons(frame)
	if not frame then return end

	for _, bu in next, { frame.ScrollTarget:GetChildren() } do
		if not bu.IsSkinned then
			bu:StripTextures()
			bu:CreateBackdrop('Transparent', nil, nil, true)
			bu.backdrop:ClearAllPoints()
			bu.backdrop:Point('TOPLEFT', bu, 0, -2)
			bu.backdrop:Point('BOTTOMRIGHT', bu, 0, 2)

			local icon = bu.icon or bu.Icon
			icon:Size(40)
			icon:Point('LEFT', -43, 0)
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:CreateBackdrop('Transparent', nil, nil, true)

			bu:HookScript('OnEnter', buttonOnEnter)
			bu:HookScript('OnLeave', buttonOnLeave)

			if bu.ProgressBar then
				bu.ProgressBar:SetTexture(E.media.normTex)
				bu.ProgressBar:SetVertexColor(0.251, 0.753, 0.251, 1) -- 0.0118, 0.247, 0.00392
			end

			if frame:GetParent() == _G.WardrobeCollectionFrame.SetsCollectionFrame then
				bu.Favorite:SetAtlas('PetJournal-FavoritesIcon', true)
				bu.Favorite:Point('TOPLEFT', bu.Icon, 'TOPLEFT', -8, 8)

				hooksecurefunc(bu.SelectedTexture, 'SetShown', selectedTextureSetShown)
			else
				bu.selectedTexture:SetTexture()
				hooksecurefunc(bu.selectedTexture, 'Show', selectedTextureShow)
				hooksecurefunc(bu.selectedTexture, 'Hide', selectedTextureHide)

				if frame:GetParent() == _G.PetJournal then
					bu.petList = true
					bu.petTypeIcon:Point('TOPRIGHT', -1, -1)
					bu.petTypeIcon:Point('BOTTOMRIGHT', -1, 1)

					bu.dragButton.ActiveTexture:SetTexture(E.Media.Textures.White8x8)
					bu.dragButton.ActiveTexture:SetVertexColor(0.9, 0.8, 0.1, 0.3)
					bu.dragButton.levelBG:SetTexture()

					S:HandleIconBorder(bu.iconBorder, nil, petNameColor)
				elseif frame:GetParent() == _G.MountJournal then
					bu.mountList = true
					bu.factionIcon:SetDrawLayer('OVERLAY')
					bu.factionIcon:Point('TOPRIGHT', -1, -1)
					bu.factionIcon:Point('BOTTOMRIGHT', -1, 1)

					bu.DragButton.ActiveTexture:SetTexture(E.Media.Textures.White8x8)
					bu.DragButton.ActiveTexture:SetVertexColor(0.9, 0.8, 0.1, 0.3)

					bu.favorite:SetTexture([[Interface\COMMON\FavoritesIcon]])
					bu.favorite:Point('TOPLEFT', bu.DragButton, 'TOPLEFT' , -8, 8)
					bu.favorite:Size(32, 32)

					hooksecurefunc(bu.name, 'SetFontObject', mountNameColor)
					hooksecurefunc(bu.background, 'SetVertexColor', mountNameColor)
				end
			end

			bu.IsSkinned = true
		end
	end
end

local function SkinMountFrame()
	S:HandleItemButton(_G.MountJournalSummonRandomFavoriteButton)
	S:HandleButton(_G.MountJournalFilterButton)

	_G.MountJournalFilterButton:ClearAllPoints()
	_G.MountJournalFilterButton:Point('LEFT', _G.MountJournalSearchBox, 'RIGHT', 5, 0)

	S:HandleCloseButton(_G.MountJournalFilterButton.ResetButton)
	_G.MountJournalFilterButton.ResetButton:ClearAllPoints()
	_G.MountJournalFilterButton.ResetButton:Point('CENTER', _G.MountJournalFilterButton, 'TOPRIGHT', 0, 0)

	local MountJournal = _G.MountJournal
	MountJournal:StripTextures()
	MountJournal.MountDisplay:StripTextures()
	MountJournal.MountDisplay.ShadowOverlay:StripTextures()
	MountJournal.MountCount:StripTextures()

	S:HandleIcon(MountJournal.MountDisplay.InfoButton.Icon, true)
	S:HandleCheckBox(MountJournal.MountDisplay.ModelScene.TogglePlayer)
	MountJournal.MountDisplay.ModelScene.TogglePlayer:Size(22)

	S:HandleButton(_G.MountJournalMountButton)
	S:HandleEditBox(_G.MountJournalSearchBox)
	S:HandleTrimScrollBar(_G.MountJournal.ScrollBar)
	S:HandleRotateButton(MountJournal.MountDisplay.ModelScene.RotateLeftButton)
	S:HandleRotateButton(MountJournal.MountDisplay.ModelScene.RotateRightButton)

	MountJournal.BottomLeftInset:StripTextures()
	MountJournal.BottomLeftInset:SetTemplate('Transparent')
	MountJournal.BottomLeftInset.SlotButton:StripTextures()
	S:HandleIcon(MountJournal.BottomLeftInset.SlotButton.ItemIcon)
	S:HandleButton(MountJournal.BottomLeftInset.SlotButton)
	hooksecurefunc(MountJournal.ScrollBox, 'Update', JournalScrollButtons)
end

local function SkinPetFrame()
	_G.PetJournalSummonButton:StripTextures()
	_G.PetJournalFindBattle:StripTextures()
	S:HandleButton(_G.PetJournalSummonButton)
	S:HandleButton(_G.PetJournalFindBattle)
	_G.PetJournalRightInset:StripTextures()
	_G.PetJournalLeftInset:StripTextures()
	S:HandleItemButton(_G.PetJournalSummonRandomFavoritePetButton, true)
	E:RegisterCooldown(_G.PetJournalSummonRandomFavoritePetButtonCooldown)
	_G.PetJournalSummonRandomFavoritePetButtonCooldown:SetAllPoints(_G.PetJournalSummonRandomFavoritePetButtonIconTexture)

	for i = 1, 3 do
		local f = _G['PetJournalLoadoutPet'..i..'HelpFrame']
		f:StripTextures()
	end

	if E.global.general.disableTutorialButtons then
		_G.PetJournalTutorialButton:Kill()
	end

	local PetJournal = _G.PetJournal
	PetJournal.PetCount:StripTextures()
	S:HandleEditBox(_G.PetJournalSearchBox)
	_G.PetJournalSearchBox:ClearAllPoints()
	_G.PetJournalSearchBox:Point('TOPLEFT', _G.PetJournalLeftInset, 'TOPLEFT', (E.PixelMode and 13 or 10), -9)
	S:HandleButton(_G.PetJournalFilterButton)
	_G.PetJournalFilterButton:Height(E.PixelMode and 22 or 24)
	_G.PetJournalFilterButton:ClearAllPoints()
	_G.PetJournalFilterButton:Point('TOPRIGHT', _G.PetJournalLeftInset, 'TOPRIGHT', -5, -(E.PixelMode and 8 or 7))
	S:HandleCloseButton(_G.PetJournalFilterButton.ResetButton)
	_G.PetJournalFilterButton.ResetButton:ClearAllPoints()
	_G.PetJournalFilterButton.ResetButton:Point('CENTER', _G.PetJournalFilterButton, 'TOPRIGHT', 0, 0)
	S:HandleTrimScrollBar(_G.PetJournal.ScrollBar)
	hooksecurefunc(PetJournal.ScrollBox, 'Update', JournalScrollButtons)

	_G.PetJournalAchievementStatus:DisableDrawLayer('BACKGROUND')

	S:HandleItemButton(_G.PetJournalHealPetButton, true)
	E:RegisterCooldown(_G.PetJournalHealPetButtonCooldown)
	_G.PetJournalHealPetButtonCooldown:SetAllPoints(_G.PetJournalHealPetButtonIconTexture)
	_G.PetJournalHealPetButtonIconTexture:SetTexture([[Interface\Icons\spell_magic_polymorphrabbit]])
	_G.PetJournalLoadoutBorder:StripTextures()

	for i = 1, 3 do
		local petButton = _G['PetJournalLoadoutPet'..i]
		local petButtonHealthFrame = _G['PetJournalLoadoutPet'..i..'HealthFrame']
		local petButtonXPBar = _G['PetJournalLoadoutPet'..i..'XPBar']
		petButton:StripTextures()
		petButton:SetTemplate()
		petButton.petTypeIcon:Point('BOTTOMLEFT', 2, 2)

		petButton.dragButton:SetOutside(_G['PetJournalLoadoutPet'..i..'Icon'])
		petButton.dragButton:SetFrameLevel(_G['PetJournalLoadoutPet'..i].dragButton:GetFrameLevel() + 1)

		petButton.hover = true
		petButton.pushed = true
		petButton.checked = true
		S:HandleItemButton(petButton)
		petButton.levelBG:SetAtlas('PetJournal-LevelBubble', true)

		petButton.setButton:StripTextures()
		petButtonHealthFrame.healthBar:StripTextures()
		petButtonHealthFrame.healthBar:CreateBackdrop()
		petButtonHealthFrame.healthBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(petButtonHealthFrame.healthBar)
		petButtonXPBar:StripTextures()
		petButtonXPBar:CreateBackdrop()
		petButtonXPBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(petButtonXPBar)
		petButtonXPBar:SetFrameLevel(petButtonXPBar:GetFrameLevel() + 2)

		for index = 1, 3 do
			local f = _G['PetJournalLoadoutPet'..i..'Spell'..index]
			S:HandleItemButton(f)
			f.FlyoutArrow:SetTexture([[Interface\Buttons\ActionBarFlyoutButton]])
			_G['PetJournalLoadoutPet'..i..'Spell'..index..'Icon']:SetInside(f)
		end
	end

	_G.PetJournalSpellSelect:StripTextures()

	for i=1, 2 do
		local btn = _G['PetJournalSpellSelectSpell'..i]
		S:HandleItemButton(btn)

		_G['PetJournalSpellSelectSpell'..i..'Icon']:SetInside(btn)
		_G['PetJournalSpellSelectSpell'..i..'Icon']:SetDrawLayer('BORDER')
	end

	_G.PetJournalPetCard:StripTextures()
	_G.PetJournalPetCard:SetTemplate('Transparent')
	_G.PetJournalPetCardInset:StripTextures()
	_G.PetJournalPetCardPetInfoQualityBorder:SetAlpha(0)

	_G.PetJournalPetCardPetInfo:CreateBackdrop()
	_G.PetJournalPetCardPetInfo.favorite:SetParent(_G.PetJournalPetCardPetInfo.backdrop)
	_G.PetJournalPetCardPetInfo.backdrop:SetOutside(_G.PetJournalPetCardPetInfoIcon)
	_G.PetJournalPetCardPetInfoIcon:SetParent(_G.PetJournalPetCardPetInfo.backdrop)
	_G.PetJournalPetCardPetInfoIcon:SetTexCoord(unpack(E.TexCoords))

	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(_G.PetJournalPrimaryAbilityTooltip)
	end

	for i=1, 6 do
		local frame = _G['PetJournalPetCardSpell'..i]
		frame:SetFrameLevel(frame:GetFrameLevel() + 2)
		frame:DisableDrawLayer('BACKGROUND')
		frame:SetTemplate()
		frame.icon:SetTexCoord(unpack(E.TexCoords))
	end

	_G.PetJournalPetCardHealthFrame.healthBar:StripTextures()
	_G.PetJournalPetCardHealthFrame.healthBar:CreateBackdrop()
	_G.PetJournalPetCardHealthFrame.healthBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(_G.PetJournalPetCardHealthFrame.healthBar)

	_G.PetJournalPetCardXPBar:StripTextures()
	_G.PetJournalPetCardXPBar:CreateBackdrop()
	_G.PetJournalPetCardXPBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(_G.PetJournalPetCardXPBar)
end

local function SkinToyFrame()
	local ToyBox = _G.ToyBox
	S:HandleEditBox(ToyBox.searchBox)
	S:HandleButton(_G.ToyBoxFilterButton)
	_G.ToyBoxFilterButton:Point('LEFT', ToyBox.searchBox, 'RIGHT', 2, 0)
	S:HandleCloseButton(_G.ToyBoxFilterButton.ResetButton)
	_G.ToyBoxFilterButton.ResetButton:ClearAllPoints()
	_G.ToyBoxFilterButton.ResetButton:Point('CENTER', _G.ToyBoxFilterButton, 'TOPRIGHT', 0, 0)

	ToyBox.iconsFrame:StripTextures()
	S:HandleNextPrevButton(ToyBox.PagingFrame.NextPageButton, nil, nil, true)
	S:HandleNextPrevButton(ToyBox.PagingFrame.PrevPageButton, nil, nil, true)

	ToyBox.progressBar.border:Hide()
	ToyBox.progressBar:DisableDrawLayer('BACKGROUND')
	ToyBox.progressBar:SetStatusBarTexture(E.media.normTex)
	ToyBox.progressBar:CreateBackdrop()
	E:RegisterStatusBar(ToyBox.progressBar)

	for i = 1, 18 do
		local button = ToyBox.iconsFrame['spellButton'..i]
		S:HandleItemButton(button, true)

		button.iconTextureUncollected:SetTexCoord(unpack(E.TexCoords))
		button.iconTextureUncollected:SetInside(button)
		button.hover:SetAllPoints(button.iconTexture)
		button.checked:SetAllPoints(button.iconTexture)
		button.pushed:SetAllPoints(button.iconTexture)
		button.cooldown:SetAllPoints(button.iconTexture)

		hooksecurefunc(button.name, 'SetTextColor', toyTextColor)
		hooksecurefunc(button.new, 'SetTextColor', toyTextColor)
		E:RegisterCooldown(button.cooldown)
	end

	hooksecurefunc('ToySpellButton_UpdateButton', function(button)
		if button.itemID and PlayerHasToy(button.itemID) then
			local _, _, quality = GetItemInfo(button.itemID)
			if quality then
				local r, g, b = GetItemQualityColor(quality)
				button.backdrop:SetBackdropBorderColor(r, g, b)
			else
				button.backdrop:SetBackdropBorderColor(0.9, 0.9, 0.9)
			end
		else
			button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)
end

local function SkinHeirloomFrame()
	local HeirloomsJournal = _G.HeirloomsJournal
	S:HandleEditBox(HeirloomsJournal.SearchBox)
	HeirloomsJournal.iconsFrame:StripTextures()

	S:HandleNextPrevButton(HeirloomsJournal.PagingFrame.NextPageButton, nil, nil, true)
	S:HandleNextPrevButton(HeirloomsJournal.PagingFrame.PrevPageButton, nil, nil, true)
	S:HandleDropDownBox(_G.HeirloomsJournalClassDropDown)

	S:HandleButton(_G.HeirloomsJournal.FilterButton)
	S:HandleCloseButton(_G.HeirloomsJournal.FilterButton.ResetButton)
	_G.HeirloomsJournal.FilterButton.ResetButton:ClearAllPoints()
	_G.HeirloomsJournal.FilterButton.ResetButton:Point('CENTER', _G.HeirloomsJournal.FilterButton, 'TOPRIGHT', 0, 0)

	HeirloomsJournal.progressBar.border:Hide()
	HeirloomsJournal.progressBar:DisableDrawLayer('BACKGROUND')
	HeirloomsJournal.progressBar:SetStatusBarTexture(E.media.normTex)
	HeirloomsJournal.progressBar:CreateBackdrop()
	E:RegisterStatusBar(HeirloomsJournal.progressBar)

	hooksecurefunc(HeirloomsJournal, 'UpdateButton', function(_, button)
		if not button.IsSkinned then
			S:HandleItemButton(button, true)

			button.iconTextureUncollected:SetTexCoord(unpack(E.TexCoords))
			button.iconTextureUncollected:SetInside(button)
			button.iconTexture:SetDrawLayer('ARTWORK')
			button.hover:SetAllPoints(button.iconTexture)
			button.slotFrameCollected:SetAlpha(0)
			button.slotFrameUncollected:SetAlpha(0)
			button.special:SetJustifyH('RIGHT')
			button.special:ClearAllPoints()

			button.cooldown:SetAllPoints(button.iconTexture)
			E:RegisterCooldown(button.cooldown)

			button.IsSkinned = true
		end

		button.levelBackground:SetTexture()

		button.name:Point('LEFT', button, 'RIGHT', 4, 8)
		button.level:Point('TOPLEFT', button.levelBackground,'TOPLEFT', 25, 2)

		if C_Heirloom_PlayerHasHeirloom(button.itemID) then
			button.name:SetTextColor(0.9, 0.9, 0.9)
			button.level:SetTextColor(0.9, 0.9, 0.9)
			button.special:SetTextColor(1, .82, 0)
			button.backdrop:SetBackdropBorderColor(QUALITY_7_R, QUALITY_7_G, QUALITY_7_B)
		else
			button.name:SetTextColor(0.4, 0.4, 0.4)
			button.level:SetTextColor(0.4, 0.4, 0.4)
			button.special:SetTextColor(0.4, 0.4, 0.4)
			button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	hooksecurefunc(HeirloomsJournal, 'LayoutCurrentPage', function()
		for i=1, #HeirloomsJournal.heirloomHeaderFrames do
			local header = HeirloomsJournal.heirloomHeaderFrames[i]
			header:StripTextures()
			header.text:FontTemplate(nil, 15, '')
			header.text:SetTextColor(0.9, 0.9, 0.9)
		end
	end)
end

local function SkinTransmogFrames()
	local WardrobeCollectionFrame = _G.WardrobeCollectionFrame
	S:HandleTab(WardrobeCollectionFrame.ItemsTab)
	S:HandleTab(WardrobeCollectionFrame.SetsTab)

	WardrobeCollectionFrame.progressBar:StripTextures()
	WardrobeCollectionFrame.progressBar:CreateBackdrop()
	WardrobeCollectionFrame.progressBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(WardrobeCollectionFrame.progressBar)

	S:HandleEditBox(_G.WardrobeCollectionFrameSearchBox)
	_G.WardrobeCollectionFrameSearchBox:SetFrameLevel(5)

	S:HandleButton(WardrobeCollectionFrame.FilterButton)
	WardrobeCollectionFrame.FilterButton:Point('LEFT', WardrobeCollectionFrame.searchBox, 'RIGHT', 2, 0)
	S:HandleCloseButton(WardrobeCollectionFrame.FilterButton.ResetButton)
	WardrobeCollectionFrame.FilterButton.ResetButton:ClearAllPoints()
	WardrobeCollectionFrame.FilterButton.ResetButton:Point('CENTER', WardrobeCollectionFrame.FilterButton, 'TOPRIGHT', 0, 0)
	S:HandleDropDownBox(_G.WardrobeCollectionFrameWeaponDropDown)
	WardrobeCollectionFrame.ItemsCollectionFrame:StripTextures()

	for _, Frame in ipairs(WardrobeCollectionFrame.ContentFrames) do
		if Frame.Models then
			for _, Model in pairs(Frame.Models) do
				Model.Border:SetAlpha(0)
				Model.TransmogStateTexture:SetAlpha(0)

				local border = CreateFrame('Frame', nil, Model)
				border:SetTemplate()
				border:ClearAllPoints()
				border:Point('TOPLEFT', Model, 'TOPLEFT', 0, 1) -- dont use set inside, left side needs to be 0
				border:Point('BOTTOMRIGHT', Model, 'BOTTOMRIGHT', 1, -1)
				border:SetBackdropColor(0, 0, 0, 0)
				border.callbackBackdropColor = clearBackdrop

				if Model.NewGlow then Model.NewGlow:SetParent(border) end
				if Model.NewString then Model.NewString:SetParent(border) end

				for _, region in next, { Model:GetRegions() } do
					if region:IsObjectType('Texture') then -- check for hover glow
						local texture = region:GetTexture()
						if texture == 1116940 or texture == 1569530 then -- transmogrify.blp (items:1116940 or sets:1569530)
							region:SetColorTexture(1, 1, 1, 0.3)
							region:SetBlendMode('ADD')
							region:SetAllPoints(Model)
						end
					end
				end

				hooksecurefunc(Model.Border, 'SetAtlas', function(_, texture)
					if texture == 'transmog-wardrobe-border-uncollected' then
						border:SetBackdropBorderColor(0.9, 0.9, 0.3)
					elseif texture == 'transmog-wardrobe-border-unusable' then
						border:SetBackdropBorderColor(0.9, 0.3, 0.3)
					elseif Model.TransmogStateTexture:IsShown() then
						border:SetBackdropBorderColor(1, 0.7, 1)
					else
						border:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end
				end)
			end
		end

		local pending = Frame.PendingTransmogFrame
		if pending then
			local Glowframe = pending.Glowframe
			Glowframe:SetAtlas(nil)
			Glowframe:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, pending:GetFrameLevel())

			if Glowframe.backdrop then
				Glowframe.backdrop:Point('TOPLEFT', pending, 'TOPLEFT', 0, 1) -- dont use set inside, left side needs to be 0
				Glowframe.backdrop:Point('BOTTOMRIGHT', pending, 'BOTTOMRIGHT', 1, -1)
				Glowframe.backdrop:SetBackdropBorderColor(1, 0.7, 1)
				Glowframe.backdrop:SetBackdropColor(0, 0, 0, 0)
			end

			for i = 1, 12 do
				if i < 5 then
					Frame.PendingTransmogFrame['Smoke'..i]:Hide()
				end

				Frame.PendingTransmogFrame['Wisp'..i]:Hide()
			end
		end

		local paging = Frame.PagingFrame
		if paging then
			S:HandleNextPrevButton(paging.PrevPageButton, nil, nil, true)
			S:HandleNextPrevButton(paging.NextPageButton, nil, nil, true)
		end
	end

	local SetsCollectionFrame = WardrobeCollectionFrame.SetsCollectionFrame
	SetsCollectionFrame:SetTemplate('Transparent')
	SetsCollectionFrame.RightInset:StripTextures()
	SetsCollectionFrame.LeftInset:StripTextures()
	S:HandleTrimScrollBar(SetsCollectionFrame.ListContainer.ScrollBar)

	hooksecurefunc(SetsCollectionFrame.ListContainer.ScrollBox, 'Update', function(button)
		for _, child in next, { button.ScrollTarget:GetChildren() } do
			if not child.IsSkinned then
				child.Background:Hide()
				child.HighlightTexture:SetTexture('')
				child.Icon:SetSize(42, 42)
				S:HandleIcon(child.Icon)
				child.IconCover:SetOutside(child.Icon)

				child.SelectedTexture:SetDrawLayer('BACKGROUND')
				child.SelectedTexture:SetColorTexture(1, 1, 1, .25)
				child.SelectedTexture:ClearAllPoints()
				child.SelectedTexture:Point('TOPLEFT', 4, -2)
				child.SelectedTexture:Point('BOTTOMRIGHT', -1, 2)
				child.SelectedTexture:CreateBackdrop('Transparent')

				child.IsSkinned = true
			end
		end
	end)

	local DetailsFrame = SetsCollectionFrame.DetailsFrame
	DetailsFrame.ModelFadeTexture:Hide()
	DetailsFrame.IconRowBackground:Hide()
	DetailsFrame.Name:FontTemplate(nil, 16)
	DetailsFrame.LongName:FontTemplate(nil, 16)
	S:HandleButton(DetailsFrame.VariantSetsButton)

	hooksecurefunc(SetsCollectionFrame, 'SetItemFrameQuality', function(_, itemFrame)
		local icon = itemFrame.Icon
		if not icon.backdrop then
			icon:CreateBackdrop()
			icon:SetTexCoord(unpack(E.TexCoords))
			itemFrame.IconBorder:Hide()
		end

		if itemFrame.collected then
			local quality = C_TransmogCollection_GetSourceInfo(itemFrame.sourceID).quality
			local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
			icon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	_G.WardrobeSetsCollectionVariantSetsButton.Icon:SetTexture(E.Media.Textures.ArrowUp)
	_G.WardrobeSetsCollectionVariantSetsButton.Icon:SetRotation(S.ArrowRotation.down)

	local WardrobeFrame = _G.WardrobeFrame
	S:HandlePortraitFrame(WardrobeFrame)

	local WardrobeOutfitFrame = _G.WardrobeOutfitFrame
	WardrobeOutfitFrame:StripTextures()
	WardrobeOutfitFrame:SetTemplate('Transparent')
	S:HandleButton(_G.WardrobeOutfitDropDown.SaveButton)
	S:HandleDropDownBox(_G.WardrobeOutfitDropDown, 221)
	_G.WardrobeOutfitDropDown:Height(34)
	_G.WardrobeOutfitDropDown.SaveButton:ClearAllPoints()
	_G.WardrobeOutfitDropDown.SaveButton:Point('TOPLEFT', _G.WardrobeOutfitDropDown, 'TOPRIGHT', -2, -2)

	local WardrobeTransmogFrame = _G.WardrobeTransmogFrame
	WardrobeTransmogFrame:StripTextures()

	for i = 1, #WardrobeTransmogFrame.SlotButtons do
		local slotButton = WardrobeTransmogFrame.SlotButtons[i]
		slotButton:SetFrameLevel(slotButton:GetFrameLevel() + 2)
		slotButton:StripTextures()
		slotButton:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
		slotButton.Border:Kill()
		slotButton.Icon:SetTexCoord(unpack(E.TexCoords))
		slotButton.Icon:SetInside(slotButton.backdrop)

		local undo = slotButton.UndoButton
		if undo then undo:SetHighlightTexture(E.ClearTexture) end

		local pending = slotButton.PendingFrame
		if pending then
			if slotButton.transmogType == 1 then
				pending.Glow:Size(48)
				pending.Ants:Size(30)
			else
				pending.Glow:Size(74)
				pending.Ants:Size(48)
			end
		end
	end

	WardrobeTransmogFrame.SpecButton:ClearAllPoints()
	WardrobeTransmogFrame.SpecButton:Point('RIGHT', WardrobeTransmogFrame.ApplyButton, 'LEFT', -2, 0)
	S:HandleButton(WardrobeTransmogFrame.SpecButton)
	S:HandleButton(WardrobeTransmogFrame.ApplyButton)
	S:HandleButton(WardrobeTransmogFrame.ModelScene.ClearAllPendingButton)
	S:HandleCheckBox(WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox)

	WardrobeCollectionFrame.ItemsCollectionFrame:StripTextures()
	WardrobeCollectionFrame.ItemsCollectionFrame:SetTemplate('Transparent')

	WardrobeCollectionFrame.SetsTransmogFrame:StripTextures()
	WardrobeCollectionFrame.SetsTransmogFrame:SetTemplate('Transparent')
	S:HandleNextPrevButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.NextPageButton)
	S:HandleNextPrevButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.PrevPageButton)

	local WardrobeOutfitEditFrame = _G.WardrobeOutfitEditFrame
	WardrobeOutfitEditFrame:StripTextures()
	WardrobeOutfitEditFrame:SetTemplate('Transparent')
	WardrobeOutfitEditFrame.EditBox:StripTextures()
	S:HandleEditBox(WardrobeOutfitEditFrame.EditBox)
	S:HandleButton(WardrobeOutfitEditFrame.AcceptButton)
	S:HandleButton(WardrobeOutfitEditFrame.CancelButton)
	S:HandleButton(WardrobeOutfitEditFrame.DeleteButton)
end

local function HandleTabs()
	local tab = _G.CollectionsJournalTab1
	local index, lastTab = 1, tab
	while tab do
		S:HandleTab(tab)

		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('TOPLEFT', _G.CollectionsJournal, 'BOTTOMLEFT', -3, 0)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -5, 0)
			lastTab = tab
		end

		index = index + 1
		tab = _G['CollectionsJournalTab'..index]
	end
end

local function SkinCollectionsFrames()
	S:HandlePortraitFrame(_G.CollectionsJournal)

	HandleTabs()

	SkinMountFrame()
	SkinPetFrame()
	SkinToyFrame()
	SkinHeirloomFrame()
end

function S:Blizzard_Collections()
	if not E.private.skins.blizzard.enable then return end
	if E.private.skins.blizzard.collections then SkinCollectionsFrames() end
	if E.private.skins.blizzard.transmogrify then SkinTransmogFrames() end
end

S:AddCallbackForAddon('Blizzard_Collections')
