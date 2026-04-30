local AddonName, KeystoneLoot  = ...;

local DB                       = KeystoneLoot.DB;
local Query                    = KeystoneLoot.Query;

local ICON_SIZE                = 34;
local ICON_SPACING             = 8;
local ICON_TOP_OFFSET          = -90;
local FRAME_BASE_HEIGHT        = 104;

KeystoneLootCatalystFrameMixin = {};

function KeystoneLootCatalystFrameMixin:OnLoad()
    self.Border.Bg:SetTexture('Interface\\FrameGeneral\\UI-Background-Marble');
    self.iconPool = CreateFramePool("Button", self, "KeystoneLootLootIconButtonTemplate");
end

function KeystoneLootCatalystFrameMixin:Init()
    local function OnChanged()
        self:Refresh();
    end

    DB:AddObserver("filters.specId", OnChanged);
    DB:AddObserver("filters.slotId", OnChanged);
    DB:AddObserver("ui.selectedCharacterKey", OnChanged);

    self:Refresh();
end

function KeystoneLootCatalystFrameMixin:Refresh()
    self.iconPool:ReleaseAll();

    local items = Query:GetCatalystItems();
    local numItems = #items;
    local LastIcon = nil;

    for _, item in ipairs(items) do
        local Icon = self.iconPool:Acquire();
        Icon:ClearAllPoints();

        if (not LastIcon) then
            Icon:SetPoint("TOP", self, 0, ICON_TOP_OFFSET);
        else
            Icon:SetPoint("TOP", LastIcon, "BOTTOM", 0, -ICON_SPACING);
        end

        Icon:Init(item);
        Icon:Show();
        LastIcon = Icon;
    end

    self:SetHeight(FRAME_BASE_HEIGHT + numItems * (ICON_SIZE + ICON_SPACING));
    self:SetShown(numItems > 0);
end
