local AddonName, KeystoneLoot = ...;

local DB = KeystoneLoot.DB;
local Query = KeystoneLoot.Query;

KeystoneLootRaidDropdownMixin = {};

function KeystoneLootRaidDropdownMixin:Init(raids)
    self.selectedIndex = 1;

    -- Set raid name
    local raid = raids[self.selectedIndex];
    local raidName = EJ_GetInstanceInfo(raid.journalInstanceId);
    self:SetText(raidName);

    -- Generate menu
    local function IsSelected(index)
        return self.selectedIndex == index;
    end

    local function SetSelected(index)
        self.selectedIndex = index;
        local raid = raids[index];
        local raidName = EJ_GetInstanceInfo(raid.journalInstanceId);

        self:GetParent():SetRaid(raid);
        self:SetText(raidName);

        DB:Set("ui.selectedRaidTab", raid.journalInstanceId);
    end

    self:SetupMenu(function(dropdown, rootDescription)
        rootDescription:SetTag("MENU_KEYSTONELOOT_RAID");

        for index, raid in ipairs(raids) do
            local raidName = EJ_GetInstanceInfo(raid.journalInstanceId);
            rootDescription:CreateRadio(raidName, IsSelected, SetSelected, index);
        end
    end);
end

function KeystoneLootRaidDropdownMixin:SetText(text)
    self.Text:SetText(text);

    local raidIcon = 20;
    local arrow = 18;
    self:SetWidth(raidIcon + self.Text:GetWidth() + arrow);
end

function KeystoneLootRaidDropdownMixin:OnMouseDown()
    if (not self:IsEnabled()) then
        return;
    end

    self.Text:AdjustPointsOffset(1, -1);
    self:GetNormalTexture():AdjustPointsOffset(1, -1);
    self:GetHighlightTexture():AdjustPointsOffset(1, -1);
end

function KeystoneLootRaidDropdownMixin:OnMouseUp()
    if (not self:IsEnabled()) then
        return;
    end

    self.Text:AdjustPointsOffset(-1, 1);
    self:GetNormalTexture():AdjustPointsOffset(-1, 1);
    self:GetHighlightTexture():AdjustPointsOffset(-1, 1);
end
