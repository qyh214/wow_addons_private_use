local AddonName, KeystoneLoot = ...;


function KeystoneLoot:CreateRaidFrame(parent)
	local Frame = CreateFrame('Frame', nil, parent);
	Frame:SetSize(250, 50);

	local BgTexture = Frame:CreateTexture(nil, 'ARTWORK');
	Frame.BgTexture = BgTexture;
	BgTexture:SetSize(311, 58);
	BgTexture:SetPoint('TOPLEFT', -4, 0);
	BgTexture:SetAtlas('UI-EJ-MemoryFrame');

	local BossIcon = Frame:CreateTexture(nil, 'BACKGROUND');
	Frame.BossIcon = BossIcon;
	BossIcon:SetSize(46, 46);
	BossIcon:SetPoint('TOPLEFT', 2, -6);

	local Title = Frame:CreateFontString('ARTWORK', nil, 'GameFontDisableLarge');
	Frame.Title = Title;
	Title:SetMaxLines(1);
	Title:SetWidth(230);
	Title:SetJustifyH('LEFT');
	Title:SetPoint('BOTTOMLEFT', Frame, 'TOPLEFT', 48, -2);
	Title = Mixin(Title, AutoScalingFontStringMixin);

	Frame.itemFrames = {};
	for index=1, 5 do
		local ItemButton = self:CreateItemButton(Frame);

		if (index == 1) then
			ItemButton:SetPoint('TOPLEFT', 60, -13);
		else
			ItemButton:SetPoint('LEFT', Frame.itemFrames[index - 1], 'RIGHT', 10, 0);
		end

		table.insert(Frame.itemFrames, ItemButton);
	end

	function Frame:SetDisabled(isDisabled)
		self.Title:SetTextColor((isDisabled and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR):GetRGB());
		self.BgTexture:SetDesaturated(isDisabled);
		self.BossIcon:SetDesaturated(isDisabled);
		self:SetAlpha(isDisabled and 0.8 or 1);
	end

	function Frame:SetItems(itemList)
		for index, ItemButton in next, self.itemFrames do
			local itemInfo = itemList[index];
			if (itemInfo) then
				ItemButton.itemId = itemInfo.itemId;
				ItemButton.specId = itemInfo.specId;

				ItemButton.Icon:SetTexture(itemInfo.icon);
				ItemButton:UpdateFavoriteStarIcon();
				ItemButton:UpdateOtherSpecIcon();
				ItemButton:UpdateStatVisibility();
				ItemButton:Show();
			else
				ItemButton:Hide();
			end
		end

		self:SetDisabled(#itemList == 0);
	end

	return Frame;
end