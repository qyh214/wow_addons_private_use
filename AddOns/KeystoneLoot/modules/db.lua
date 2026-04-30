local AddonName, KeystoneLoot = ...;

KeystoneLoot.DB = {};

local DB = KeystoneLoot.DB;

local CURRENT_SEASON = KeystoneLoot.Config.season;

local DB_VERSION = 4;
local CHAR_DB_VERSION = 1;

local observers = {};

function DB:Init()
    self:InitGlobalDB();
    self:InitCharDB();
end

function DB:InitGlobalDB()
    -- TODO: Will be removed in the next version
    if (KeystoneLootDB and KeystoneLootDB.minimapButtonEnabled ~= nil) then
        KeystoneLootDB = {};
    end

    if (not KeystoneLootDB or not KeystoneLootDB.version) then
        KeystoneLootDB = {
            version = 0,
            settings = {},
            favorites = {},
            currentSeason = 0
        };
    end

    while (KeystoneLootDB.version < DB_VERSION) do
        self:MigrateGlobalDB(KeystoneLootDB.version);
        KeystoneLootDB.version = KeystoneLootDB.version + 1;
    end

    self:CheckSeason();
end

function DB:InitCharDB()
    -- TODO: Will be removed in the next version
    if (KeystoneLootCharDB and KeystoneLootCharDB.favoriteLoot ~= nil) then
        KeystoneLootCharDB = {};
    end

    if (not KeystoneLootCharDB or not KeystoneLootCharDB.version) then
        KeystoneLootCharDB = {
            version = 0,
            filters = {},
            ui = {}
        };
    end

    while (KeystoneLootCharDB.version < CHAR_DB_VERSION) do
        self:MigrateCharDB(KeystoneLootCharDB.version);
        KeystoneLootCharDB.version = KeystoneLootCharDB.version + 1;
    end
end

function DB:MigrateGlobalDB(fromVersion)
    if (fromVersion == 0) then
        -- First install
        KeystoneLootDB.settings = {
            minimap = {
                enabled = true,
                degrees = 195
            },
            lootReminder = {
                dungeons = true
            },
            highlighting = {
                crit = true,
                haste = true,
                mastery = true,
                versatility = true,
                noStats = true
            },
            keystoneTooltip = true
        };

        KeystoneLootDB.favorites = {};
    end

    if (fromVersion == 1) then
        KeystoneLootDB.settings.favoriteTooltip = true;
    end

    if (fromVersion == 2) then
        KeystoneLootDB.settings.hiddenCharacters = {};
    end

    if (fromVersion == 3) then
        KeystoneLootDB.settings.wideMode = false;
    end
end

function DB:MigrateCharDB(fromVersion)
    if (fromVersion == 0) then
        -- First install
        local _, _, classId = UnitClass("player");
        local specId = GetSpecializationInfo(GetSpecialization() or 1);

        KeystoneLootCharDB.filters = {
            classId = classId,
            specId = specId or 0,
            slotId = 0,
            dungeon = {
                track = "champion",
                rank = 1
            },
            raid = {
                difficulty = "normal",
                rank = 1
            }
        };

        KeystoneLootCharDB.ui = {
            selectedTab = "dungeons",
            selectedRaidTab = KeystoneLoot.RaidDatabase[1].journalInstanceId
        }
    end
end

function DB:CheckSeason()
    local currentSeason = CURRENT_SEASON;

    if (not KeystoneLootDB.currentSeason) then
        KeystoneLootDB.currentSeason = currentSeason;
        return;
    end

    if (KeystoneLootDB.currentSeason ~= currentSeason) then
        -- New season - wipe all favorites
        wipe(KeystoneLootDB.favorites);
        KeystoneLootDB.currentSeason = currentSeason;
    end
end

function DB:Get(path)
    local keys = { strsplit(".", path) };
    local current = KeystoneLootCharDB;

    -- Try CharDB first
    for _, key in ipairs(keys) do
        if (current) then
            current = current[key];
        else
            break;
        end
    end

    -- Fallback to global DB
    if (current == nil) then
        current = KeystoneLootDB;

        for _, key in ipairs(keys) do
            if (current) then
                current = current[key];
            else
                break;
            end
        end
    end

    return current;
end

function DB:Set(path, value)
    local keys = { strsplit(".", path) };
    local lastKey = table.remove(keys);

    -- Determine which DB
    local db
    if (path:match("^settings") or path:match("^favorites")) then
        db = KeystoneLootDB;
    else
        db = KeystoneLootCharDB;
    end

    -- Navigate to parent
    local current = db;
    for _, key in ipairs(keys) do
        if (not current[key]) then
            current[key] = {};
        end

        current = current[key];
    end

    -- Set value
    current[lastKey] = value;

    -- Notify observers
    self:Notify(path, value);
end

function DB:AddObserver(key, callback)
    if (not observers[key]) then
        observers[key] = {};
    end

    table.insert(observers[key], callback);
end

function DB:Notify(path, value)
    -- Exact match
    if (observers[path]) then
        for _, callback in ipairs(observers[path]) do
            callback(value);
        end
    end

    -- Wildcard match (e.g., "filters.*")
    for pattern, callbacks in pairs(observers) do
        if (pattern:match("%*$")) then
            local prefix = pattern:gsub("%*$", "");
            if (path:match("^" .. prefix)) then
                for _, callback in ipairs(callbacks) do
                    callback(value);
                end
            end
        end
    end
end
