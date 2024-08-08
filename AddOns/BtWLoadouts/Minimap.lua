local ADDON_NAME, Internal = ...
local L = Internal.L
local Settings = Internal.Settings

local GetCursorPosition = GetCursorPosition;
-- This is very important, the global functions gives different responses than the math functions
local cos, sin = math.cos, math.sin;
local min, max = math.min, math.max;
local deg, rad = math.deg, math.rad;
local sqrt = math.sqrt;
local atan2 = math.atan2;

local minimapShapes = {
    -- quadrant booleans (same order as SetTexCoord)
    -- {bottom-right, bottom-left, top-right, top-left}
    -- true = rounded, false = squared
    ["ROUND"] 			= {true,  true,  true,  true },
    ["SQUARE"] 			= {false, false, false, false},
    ["CORNER-TOPLEFT"] 		= {false, false, false, true },
    ["CORNER-TOPRIGHT"] 		= {false, false, true,  false},
    ["CORNER-BOTTOMLEFT"] 		= {false, true,  false, false},
    ["CORNER-BOTTOMRIGHT"]	 	= {true,  false, false, false},
    ["SIDE-LEFT"] 			= {false, true,  false, true },
    ["SIDE-RIGHT"] 			= {true,  false, true,  false},
    ["SIDE-TOP"] 			= {false, false, true,  true },
    ["SIDE-BOTTOM"] 		= {true,  true,  false, false},
    ["TRICORNER-TOPLEFT"] 		= {false, true,  true,  true },
    ["TRICORNER-TOPRIGHT"] 		= {true,  false, true,  true },
    ["TRICORNER-BOTTOMLEFT"] 	= {true,  true,  false, true },
    ["TRICORNER-BOTTOMRIGHT"] 	= {true,  true,  true,  false},
};

BtWLoadoutsMinimapMixin = {};
function BtWLoadoutsMinimapMixin:OnLoad()
    self:RegisterForClicks("anyUp");
    self:RegisterForDrag("LeftButton");
    self:RegisterEvent("PLAYER_LOGIN");
end
function BtWLoadoutsMinimapMixin:OnEvent(event, ...)
    self:SetShown(self:IsEnabled() and Settings.minimapShown);
    self:Reposition(Settings.minimapAngle or 195);

    local button = self;
    Minimap:HookScript("OnSizeChanged", function ()
        button:Reposition(Settings.minimapAngle or 195);
    end)
end
function BtWLoadoutsMinimapMixin:OnDragStart()
    self:LockHighlight();
    self:SetScript("OnUpdate", self.OnUpdate);
end
function BtWLoadoutsMinimapMixin:OnDragStop()
    self:UnlockHighlight();
    self:SetScript("OnUpdate", nil);
end
function BtWLoadoutsMinimapMixin:Reposition(degrees)
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

    self:SetPoint("CENTER", "$parent", "CENTER", x, y);
end
function BtWLoadoutsMinimapMixin:OnUpdate()
    local px,py = GetCursorPosition();
    local mx,my = Minimap:GetCenter();

    local scale = Minimap:GetEffectiveScale();
    px, py = px / scale, py / scale;

    local angle = deg(atan2(py - my, px - mx));

    Settings.minimapAngle = angle;

    self:Reposition(angle);
end
function BtWLoadoutsMinimapMixin:OnClick(button)
    if button == "LeftButton" then
        BtWLoadoutsFrame:SetShown(not BtWLoadoutsFrame:IsShown());
    elseif button == "RightButton" then
        if not self.Menu then
            self.Menu = CreateFrame("Frame", self:GetName().."Menu", self, "UIDropDownMenuTemplate");
            UIDropDownMenu_Initialize(self.Menu, BtWLoadoutsMinimapMenu_Init, "MENU");
        end

        ToggleDropDownMenu(1, nil, self.Menu, self, 0, 0);
    end
end
function BtWLoadoutsMinimapMixin:OnEnter()
    BtWLoadoutsHelpTipFlags["MINIMAP_ICON"] = true;
    self.FirstTimeAnim:Finish();

    GameTooltip:SetOwner(self, "ANCHOR_LEFT");
    GameTooltip:SetText(L["BtWLoadouts"], 1, 1, 1);
    GameTooltip:AddLine(L["Click to open BtWLoadouts.\nRight Click to enable and disable settings."], nil, nil, nil, true);
    if Internal.IsActivatingLoadout() then
        GameTooltip:AddLine(" ");
        GameTooltip:AddLine(L["Activating Loadout"], 1, 1, 1);
        GameTooltip:AddLine(Internal.GetWaitReason())
    end
    GameTooltip:Show();
end
function BtWLoadoutsMinimapMixin:OnLeave()
    GameTooltip:Hide();
end
local items = {}
function BtWLoadoutsMinimapMenu_Init(self, level, menuList)
    if level == 1 then
        wipe(items)
        for id, set in pairs(BtWLoadoutsSets.profiles) do
            if type(set) == "table" then
                if Internal.IsLoadoutEnabled(set) and Internal.IsLoadoutActivatable(set) then
                    items[#items+1] = set
                end
            end
        end
        table.sort(items, function (a, b)
            if a.specID ~= b.specID then
                return (a.specID or 1000) < (b.specID or 1000)
            end

            return a.name < b.name
        end)

        local info = UIDropDownMenu_CreateInfo();
        local specID

        if #items > 0 then
            local func = function (self, id)
                local set = BtWLoadoutsSets.profiles[id]
                if set then
                    Internal.ActivateProfile(set)
                end
            end

            for _,set in ipairs(items) do
                if set.specID ~= specID then
                    info.isTitle, info.disabled, info.notCheckable = true, true, true;
                    info.text = set.specID and (select(2, GetSpecializationInfoByID(set.specID))) or L["Other"];

                    UIDropDownMenu_AddButton(info, level);

                    specID = set.specID

                    info.isTitle, info.disabled, info.notCheckable = false, false, false;
                    info.func = func
                end

                info.text = set.name;
                info.arg1 = set.setID;
                info.checked = Internal.IsProfileActive(set)

                UIDropDownMenu_AddButton(info, level);
            end

            if Settings.showSettingsInMenu then
                info.isTitle, info.disabled, info.notCheckable = true, true, true;
                info.func, info.arg1 = nil, nil;
                info.text = L["Settings"];

                UIDropDownMenu_AddButton(info, level);
            end
        end

        if Settings.showSettingsInMenu then
            info.isTitle, info.disabled, info.notCheckable = false, false, false;
            info.func = function (self, key)
                Settings[key] = not Settings[key];
            end
            for i, entry in ipairs(Settings) do
                info.text = entry.name;
                info.arg1 = entry.key;
                info.checked = Settings[entry.key];

                UIDropDownMenu_AddButton(info, level);
            end
        end
    end
end

Internal.OnEvent("LoadoutActivateStart", function ()
    BtWLoadoutsMinimapButton.ProgressAnim:Play()
end)
Internal.OnEvent("LoadoutActivateEnd", function ()
    BtWLoadoutsMinimapButton.ProgressAnim:Stop()
end)

function Internal.ShowMinimap()
    BtWLoadoutsMinimapButton:Show()
end
function Internal.HideMinimap()
    BtWLoadoutsMinimapButton:Hide()
end