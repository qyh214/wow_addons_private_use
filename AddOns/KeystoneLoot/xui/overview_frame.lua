local AddonName, KeystoneLoot = ...;

local Translate = KeystoneLoot.Translate;


local function OnShow(self)
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);
end

local function OnHide(self)
	self.TooltipFrame:Hide();

	PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE);
end

local Frame = CreateFrame('Frame', AddonName..'Frame', UIParent, 'PortraitFrameTexturedBaseTemplate');
Frame:Hide();
Frame:SetSize(476, 230);
Frame:SetPoint('CENTER');

Frame:SetToplevel(true);
Frame:SetMovable(true);
Frame:SetUserPlaced(true);
Frame:SetClampedToScreen(true);

Frame:EnableMouse(true);
Frame:RegisterForDrag('LeftButton');

Frame:SetScript('OnDragStart', Frame.StartMoving);
Frame:SetScript('OnDragStop', Frame.StopMovingOrSizing);
Frame:SetScript('OnShow', OnShow);
Frame:SetScript('OnHide', OnHide);

Frame:SetPortraitToAsset('Interface\\Icons\\INV_Relics_Hourglass_02');
Frame:SetTitle((Translate['%s (%s Season %d)']):format('KeystoneLoot', EXPANSION_NAME10, 1));

table.insert(UISpecialFrames, Frame:GetName());


local function CloseButton_OnClick(self)
	self:GetParent():Hide();
end

local CloseButton = CreateFrame('Button', nil, Frame, 'UIPanelCloseButtonDefaultAnchors');
CloseButton:SetScript('OnClick', CloseButton_OnClick);


local AddonMarkerText = Frame:CreateFontString('ARTWORK', nil, 'GameFontDisableSmall');
AddonMarkerText:SetPoint('BOTTOM', 0, 6);
AddonMarkerText:SetShadowOffset(0, 0);
AddonMarkerText:SetText('Made with LOVE in Germany');


function KeystoneLoot:GetOverview()
    return Frame;
end