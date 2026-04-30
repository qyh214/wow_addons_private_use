local AddonName, KeystoneLoot = ...;

local DB = KeystoneLoot.DB;
local Query = KeystoneLoot.Query;

local SLOTS = {
    INVTYPE_HEAD,
    INVTYPE_NECK,
    INVTYPE_SHOULDER,
    INVTYPE_CLOAK,
    INVTYPE_CHEST,
    INVTYPE_WRIST,
    INVTYPE_HAND,
    INVTYPE_WAIST,
    INVTYPE_LEGS,
    INVTYPE_FEET,
    INVTYPE_WEAPONMAINHAND,
    INVTYPE_WEAPONOFFHAND,
    INVTYPE_FINGER,
    INVTYPE_TRINKET,
    EJ_LOOT_SLOT_FILTER_OTHER
};

KeystoneLootSlotDropdownMixin = {};

function KeystoneLootSlotDropdownMixin:Init()
    self:SetSelectionText(function(selections)
        if (#selections == 0) then
            return FAVORITES;
        end

        local data = selections[1].data;
        if (not data) then
            return FAVORITES;
        end

        return data.name;
    end);

    self:SetupMenu(function(dropdown, rootDescription)
        rootDescription:SetTag("MENU_KEYSTONELOOT_SLOT_DROPDOWN");

        local function IsSelected(data)
            return DB:Get("filters.slotId") == data.slotId;
        end

        local function SetSelected(data)
            DB:Set("filters.slotId", data.slotId);
        end

        rootDescription:CreateRadio(FAVORITES, IsSelected, SetSelected, { slotId = -1 });
        rootDescription:CreateDivider();
        rootDescription:CreateRadio(ALL_INVENTORY_SLOTS, IsSelected, SetSelected, { slotId = -2 });

        for index, slotName in ipairs(SLOTS) do
            local slotId = index - 1; -- 0-based
            local radio = rootDescription:CreateRadio(slotName, IsSelected, SetSelected, { slotId = slotId });

            if (not self:SlotHasItems(slotId)) then
                radio:SetEnabled(false);

                radio:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddColoredLine(tooltip, BROWSE_NO_RESULTS, RED_FONT_COLOR);
                end);
            end
        end
    end);

    local function OnChanged()
        -- Check if current slot still has items
        local currentSlot = DB:Get("filters.slotId");

        -- Skip favorites slot
        if (currentSlot ~= -1 and currentSlot ~= -2) then
            local hasItems = self:SlotHasItems(currentSlot);

            -- If current slot is now empty, reset to Head
            if (not hasItems) then
                DB:Set("filters.slotId", -2);
            end
        end

        self:GenerateMenu();
    end

    DB:AddObserver("ui.selectedTab", OnChanged);
    DB:AddObserver("ui.selectedRaidTab", OnChanged);
    DB:AddObserver("filters.specId", OnChanged);
end

function KeystoneLootSlotDropdownMixin:SlotHasItems(slotId)
    local selectedTab = DB:Get("ui.selectedTab");

    if (selectedTab == "dungeons") then
        return Query:HasDungeonSlotItems(slotId);
    end

    return Query:HasRaidSlotItems(slotId);
end
