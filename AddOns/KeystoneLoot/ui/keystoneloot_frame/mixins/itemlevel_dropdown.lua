local AddonName, KeystoneLoot = ...;

local DB = KeystoneLoot.DB;
local L = KeystoneLoot.L;

local TRACK_LABELS = {
    champion   = L["Champion"],
    hero       = L["Hero"],
    greatvault = L["Great Vault"],
    lfr        = L["Raid Finder"],
    normal     = L["Normal"],
    heroic     = L["Heroic"],
    mythic     = L["Mythic"],
};

KeystoneLootItemLevelDropdownMixin = {};

function KeystoneLootItemLevelDropdownMixin:Init()
    self:SetSelectionText(function(selections)
        if (#selections == 0) then
            return STAT_AVERAGE_ITEM_LEVEL;
        end

        local data = selections[1].data;
        if (not data or not data.label) then
            return STAT_AVERAGE_ITEM_LEVEL;
        end

        return data.label;
    end);

    self:SetupMenu(function(dropdown, rootDescription)
        rootDescription:SetTag("MENU_KEYSTONELOOT_ITEMLEVEL_DROPDOWN");

        local selectedTab = DB:Get("ui.selectedTab");
        if (selectedTab == "dungeons") then
            self:BuildDungeonMenu(rootDescription);
        else
            self:BuildRaidMenu(rootDescription);
        end
    end);

    DB:AddObserver("ui.selectedTab", function() self:GenerateMenu(); end);
end

function KeystoneLootItemLevelDropdownMixin:BuildDungeonMenu(rootDescription)
    local tracks = KeystoneLoot.UpgradeTracks.dungeon;
    local trackOrder = KeystoneLoot.UpgradeTrackOrder.dungeon;

    local function IsSelected(data)
        return DB:Get("filters.dungeon.track") == data.track and DB:Get("filters.dungeon.rank") == data.rank;
    end

    local function SetSelected(data)
        DB:Set("filters.dungeon.track", data.track);
        DB:Set("filters.dungeon.rank", data.rank);
    end

    for _, trackName in ipairs(trackOrder) do
        local trackData = tracks[trackName];
        local trackMenu = rootDescription:CreateButton(TRACK_LABELS[trackName] or trackName:upper());

        for rank, data in ipairs(trackData or {}) do
            trackMenu:CreateRadio(data.label, IsSelected, SetSelected, { track = trackName, rank = rank, label = data.label });
        end
    end
end

function KeystoneLootItemLevelDropdownMixin:BuildRaidMenu(rootDescription)
    local tracks = KeystoneLoot.UpgradeTracks.raid;
    local difficultyOrder = KeystoneLoot.UpgradeTrackOrder.raid;

    local function IsSelected(data)
        return DB:Get("filters.raid.difficulty") == data.difficulty and DB:Get("filters.raid.rank") == data.rank;
    end

    local function SetSelected(data)
        DB:Set("filters.raid.difficulty", data.difficulty);
        DB:Set("filters.raid.rank", data.rank);
    end

    for _, difficultyName in ipairs(difficultyOrder) do
        local difficultyData = tracks[difficultyName];
        local difficultyMenu = rootDescription:CreateButton(TRACK_LABELS[difficultyName] or difficultyName:upper());

        for rank, data in ipairs(difficultyData or {}) do
            difficultyMenu:CreateRadio(data.label, IsSelected, SetSelected, { difficulty = difficultyName, rank = rank, label = data.label });
        end
    end
end
