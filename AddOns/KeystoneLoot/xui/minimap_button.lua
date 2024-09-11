local AddonName, KeystoneLoot = ...;

local Translate = KeystoneLoot.Translate;


-- https://wowwiki-archive.fandom.com/wiki/USERAPI_GetMinimapShape
local _minimapShapes = {
	['ROUND'] = { true, true, true, true },
	['SQUARE'] = { false, false, false, false },
	['CORNER-TOPLEFT'] = { false, false, false, true },
	['CORNER-TOPRIGHT'] = { false, false, true, false },
	['CORNER-BOTTOMLEFT'] = { false, true, false, false },
	['CORNER-BOTTOMRIGHT'] = { true, false, false, false },
	['SIDE-LEFT'] = { false, true, false, true },
	['SIDE-RIGHT'] = { true, false, true, false },
	['SIDE-TOP'] = { false, false, true, true },
	['SIDE-BOTTOM'] = { true, true, false, false },
	['TRICORNER-TOPLEFT'] = { false, true, true, true },
	['TRICORNER-TOPRIGHT'] = { true, false, true, true },
	['TRICORNER-BOTTOMLEFT'] = { true, true, false, true },
	['TRICORNER-BOTTOMRIGHT'] = { true, true, true, false }
}

local function GetPosition(position, radius)
	local angle = math.rad(position);
	local cos = math.cos(angle);
	local sin = math.sin(angle);
	local q = 1;
	local x = 0;
	local y = 0;

	if (cos < 0) then
		q = q + 1;
	end

	if (sin > 0) then
		q = q + 2;
	end

	local width = (Minimap:GetWidth() / 2) + radius;
	local height = (Minimap:GetHeight() / 2) + radius;

	local minimapShape = GetMinimapShape and GetMinimapShape() or 'ROUND';
	if (_minimapShapes[minimapShape][q]) then
		x = cos * width;
		y = sin * height;
	else
		x = math.max(-width, math.min(cos * (math.sqrt(2 * (width)^2) - 10), width));
		y = math.max(-height, math.min(sin * (math.sqrt(2 * (height)^2) - 10), height));
	end

	return 'CENTER', x, y;
end




local function OnUpdate(self, elapsed)
	local minimapScale = Minimap:GetEffectiveScale();
	local minimapX, minimapY = Minimap:GetCenter();

	local cursorX, cursorY = GetCursorPosition();
	cursorX = cursorX / minimapScale;
	cursorY = cursorY / minimapScale;

	local position = math.deg(math.atan2(cursorY - minimapY, cursorX - minimapX)) % 360;

	KeystoneLootDB.minimapButtonPosition = position;
	self:SetPoint(GetPosition(position, 5));
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_LEFT');
	GameTooltip:SetText('KeystoneLoot', 1, 1, 1);
	GameTooltip:AddLine(Translate['Left click: Open overview']);
	GameTooltip:AddLine(Translate['Right click: Open settings']);
	GameTooltip:Show();
end

local function OnLeave(self)
	GameTooltip:Hide();
end

local function OnMouseUp(self)
	self.Icon:SetPoint('CENTER', 0, 0);
end

local function OnMouseDown(self)
	self.Icon:SetPoint('CENTER', 1, -1);
end

local function OnDragStart(self)
	self:LockHighlight();
	self:SetScript('OnUpdate', OnUpdate);

	OnMouseUp(self);
	OnLeave(self);
end

local function OnDragStop(self)
	self:UnlockHighlight();
	self:SetScript('OnUpdate', nil);
end

local function OnClick(self, button)
	SlashCmdList.KEYSTONELOOT();

	local OverviewFrame = KeystoneLoot:GetOverview()
	if (button == 'RightButton' and OverviewFrame:IsShown()) then
		OverviewFrame.OptionsButton:Click();
	end
end

local Frame = CreateFrame('Button', 'KeystoneLootMinimapButton', Minimap);
Frame:SetSize(31, 31);
Frame:SetFrameStrata('MEDIUM');
Frame:SetFrameLevel(8);
Frame:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight');

Frame:RegisterForClicks('LeftButtonUp', 'RightButtonUp');
Frame:RegisterForDrag('LeftButton');
Frame:SetScript('OnEnter', OnEnter);
Frame:SetScript('OnLeave', OnLeave);
Frame:SetScript('OnMouseUp', OnMouseUp);
Frame:SetScript('OnMouseDown', OnMouseDown);
Frame:SetScript('OnDragStart', OnDragStart);
Frame:SetScript('OnDragStop', OnDragStop);
Frame:SetScript('OnClick', OnClick);

local Background = Frame:CreateTexture(nil, 'ARTWORK', nil, 1);
Background:SetSize(22, 22);
Background:SetPoint('TOPLEFT', 5, -5);
Background:SetTexture('Interface\\Minimap\\UI-Minimap-Background');

local Icon = Frame:CreateTexture(nil, 'ARTWORK', nil, 2);
Frame.Icon = Icon;
Icon:SetSize(17, 17);
Icon:SetPoint('CENTER');
Icon:SetTexture('Interface\\Icons\\INV_Relics_Hourglass_02');
Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);

local IconBorder = Frame:CreateTexture(nil, 'ARTWORK', nil, 3);
IconBorder:SetSize(50, 50);
IconBorder:SetPoint('TOPLEFT');
IconBorder:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder');


function KeystoneLoot:UpdateMinimapButton()
	Frame:SetShown(KeystoneLootDB.minimapButtonEnabled);
	Frame:SetPoint(GetPosition(KeystoneLootDB.minimapButtonPosition, 5));
end


AddonCompartmentFrame:RegisterAddon({
	text = 'KeystoneLoot',
	icon = 'Interface\\Icons\\INV_Relics_Hourglass_02',
	notCheckable = true,
	registerForAnyClick = true,
	func = function(_, _, _, _, mouseButton)
		OnClick(Frame, mouseButton);
	end,
	funcOnEnter = OnEnter,
	funcOnLeave = OnLeave
});