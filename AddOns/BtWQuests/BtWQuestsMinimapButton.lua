local GetCursorPosition = GetCursorPosition;
-- This is very important, the global functions gives different responses than the math functions
local cos, sin = math.cos, math.sin;
local min, max = math.min, math.max;
local deg, rad = math.deg, math.rad;
local sqrt = math.sqrt;
local atan2 = math.atan2;

local L = BtWQuests.L;

local minimapShapes = {
	-- quadrant booleans (same order as SetTexCoord)
	-- {bottom-right, bottom-left, top-right, top-left}
	-- true = rounded, false = squared
	["ROUND"] 					= { true,  true,  true,  true},
	["SQUARE"] 					= {false, false, false, false},
	["CORNER-TOPLEFT"] 			= {false, false, false,  true},
	["CORNER-TOPRIGHT"] 		= {false, false,  true, false},
	["CORNER-BOTTOMLEFT"] 		= {false,  true, false, false},
	["CORNER-BOTTOMRIGHT"]		= { true, false, false, false},
	["SIDE-LEFT"] 				= {false,  true, false,  true},
	["SIDE-RIGHT"] 				= { true, false,  true, false},
	["SIDE-TOP"] 				= {false, false,  true,  true},
	["SIDE-BOTTOM"] 			= { true,  true, false, false},
	["TRICORNER-TOPLEFT"] 		= {false,  true,  true,  true},
	["TRICORNER-TOPRIGHT"] 		= { true, false,  true,  true},
	["TRICORNER-BOTTOMLEFT"] 	= { true,  true, false,  true},
	["TRICORNER-BOTTOMRIGHT"] 	= { true,  true,  true, false},
}
function BtWQuestsMinimapButton_Toggle()
	BtWQuests.Settings.minimapShown = not BtWQuests.Settings.minimapShown

    BtWQuestsMinimapButton:SetShown(BtWQuests.Settings.minimapShown)
end
function BtWQuestsMinimapButton_Reposition(degrees)
	local rounding = 10;
	local angle = rad(degrees or 195);
	local x, y;
	local cos = cos(angle);
	local sin = sin(angle);
	local q = 1;
	if cos < 0 then
		q = q + 1;	-- lower
	end
	if sin > 0 then
		q = q + 2;	-- right
	end

	local hRadius = Minimap:GetWidth() / 2 + 5
	local vRadius = Minimap:GetHeight() / 2 + 5

	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND";
	local quadTable = minimapShapes[minimapShape];
	if quadTable[q] then
		x = cos * hRadius;
		y = sin * vRadius;
	else
		local hDiagRadius = sqrt(2*(hRadius)^2) - rounding
		local vDiagRadius = sqrt(2*(vRadius)^2) - rounding

		x = max(-hRadius, min(cos * hDiagRadius, hRadius));
		y = max(-vRadius, min(sin * vDiagRadius, vRadius));
	end

    BtWQuestsMinimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function BtWQuestsMinimapButtonDraggingFrame_OnUpdate()
	local px,py = GetCursorPosition()
    local mx,my = Minimap:GetCenter()

    local scale = Minimap:GetEffectiveScale()
    px, py = px / scale, py / scale

	local angle = deg(atan2(py - my, px - mx));
	BtWQuests_Settings.minimapAngle = angle;
	BtWQuestsMinimapButton_Reposition(angle);
end

function BtWQuestsMinimapButton_OnClick(self, button)
	if button == "RightButton" then
		BtWQuestsOptionsMenu:Toggle(self, 0, 0)
	else
		if BtWQuestsFrame:IsShown() then
			BtWQuestsFrame:Hide()
		else
			BtWQuestsFrame:Show()
		end
	end
end
function BtWQuestsMinimapButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 32);
    GameTooltip:SetText("BtWQuests", 1, 1, 1);
    GameTooltip:AddLine(L["MINIMAP_TOOLTIP_MESSAGE"], nil, nil, nil, true);
    GameTooltip:Show();
end
function BtWQuestsMinimapButton_OnLeave()
    GameTooltip:Hide();
end