local AS, L, S, R = unpack(AddOnSkins)

local _G = _G
local gsub, ipairs = gsub, ipairs
local hooksecurefunc = hooksecurefunc

local function HandleIconString(self, text)
	if not text then text = self:GetText() end
	if not text or text == '' then return end

	local new, count = gsub(text, '|T([^:]-):[%d+:]+|t', '|T%1:14:14:0:0:64:64:5:59:5:59|t')
	if count > 0 then self:SetFormattedText('%s', new) end
end

local function ReskinTalents(self)
	for frame in self.talentPool:EnumerateActive() do
		if not frame.IsSkinned then
			frame.Border:SetAlpha(0)
			frame.IconBorder:SetAlpha(0)
			frame.TierBorder:SetAlpha(0)
			frame.Background:SetAlpha(0)

			S:SetTemplate(frame)
			frame:SetBackdropBorderColor(0, 1, 0)

			S:HandleIcon(frame.Icon, true)
			S:Point(frame.Icon, 'TOPLEFT', 7, -7)
			frame.Highlight:SetColorTexture(1, 1, 1, .25)

			HandleIconString(frame.InfoText)
			hooksecurefunc(frame.InfoText, 'SetText', HandleIconString)

			frame.IsSkinned = true
		end
	end
end

local function ReplaceCurrencies(displayGroup)
	for frame in displayGroup.currencyFramePool:EnumerateActive() do
		if not frame.IsSkinned then
			HandleIconString(frame.Text)
			hooksecurefunc(frame.Text, 'SetText', HandleIconString)

			frame.IsSkinned = true
		end
	end
end

function R:Blizzard_CovenantSanctum()
	if not AS:IsSkinEnabled('Blizzard_CovenantSanctum', 'covenantSanctum') then return end

	local frame = _G.CovenantSanctumFrame
	S:FontTemplate(frame.LevelFrame.Level)

	local UpgradesTab = frame.UpgradesTab
	S:CreateBackdrop(UpgradesTab.Background)
	S:HandleButton(UpgradesTab.DepositButton)
	UpgradesTab.DepositButton:SetFrameLevel(10)
	UpgradesTab.CurrencyBackground:SetAlpha(0)
	ReplaceCurrencies(UpgradesTab.CurrencyDisplayGroup)

	for _, upgrade in ipairs(UpgradesTab.Upgrades) do
		if upgrade.TierBorder then
			upgrade.TierBorder:SetAlpha(0)
		end
	end

	local TalentList = frame.UpgradesTab.TalentsList
	S:SetTemplate(TalentList)
	S:HandleButton(TalentList.UpgradeButton)
	TalentList.UpgradeButton:SetFrameLevel(10)
	TalentList.IntroBox.Background:Hide()
	hooksecurefunc(TalentList, 'Refresh', ReskinTalents)

	if not AS:CheckOption('Parchment') then
		frame.LevelFrame.Background:SetAlpha(0)
		UpgradesTab.Background:SetAlpha(0)
		TalentList.Divider:SetAlpha(0)
		TalentList.BackgroundTile:SetAlpha(0)
	end

	frame:HookScript('OnShow', function()
		if not frame.IsSkinned then
			S:SetTemplate(frame)
			frame.NineSlice:SetAlpha(0)

			frame.CloseButton.Border:SetAlpha(0)
			S:HandleCloseButton(frame.CloseButton)
			frame.CloseButton:ClearAllPoints()
			S:Point(frame.CloseButton, 'TOPRIGHT', frame, 'TOPRIGHT', 2, 2)

			frame.IsSkinned = true
		end
	end)
end

AS:RegisterSkin('Blizzard_CovenantSanctum', nil, 'ADDON_LOADED')
