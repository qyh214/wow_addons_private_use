local AddonName, KeystoneLoot = ...;

KeystoneLoot.Keystone = {}

local Keystone = KeystoneLoot.Keystone;
local DB = KeystoneLoot.DB;
local Query = KeystoneLoot.Query;
local Character = KeystoneLoot.Character;

local function GetSpecPoolSize(lootTable, specId, classId)
    local count = 0;

    for _, itemId in ipairs(lootTable) do
        local item = Query:GetItemInfo(itemId);
        if (item and item.classes[classId]) then
            for _, s in ipairs(item.classes[classId]) do
                if (s == specId) then
                    count = count + 1;
                    break;
                end
            end
        end
    end

    return count;
end

local function GetBestSpecForItems(items, classId, lootTable, lootSpecId, favoSpecId)
    local eligibleSpecs = nil;

    for _, item in ipairs(items) do
        local itemInfo = Query:GetItemInfo(item.itemId);

        if (itemInfo and itemInfo.classes[classId]) then
            if (eligibleSpecs == nil) then
                eligibleSpecs = {};
                for _, specId in ipairs(itemInfo.classes[classId]) do
                    eligibleSpecs[specId] = true;
                end
            else
                local specSet = {};
                for _, specId in ipairs(itemInfo.classes[classId]) do
                    specSet[specId] = true;
                end

                for specId in pairs(eligibleSpecs) do
                    if (not specSet[specId]) then
                        eligibleSpecs[specId] = nil;
                    end
                end
            end
        end
    end

    if (not eligibleSpecs or not next(eligibleSpecs)) then
        return nil;
    end

    local lootSpecPoolSize = eligibleSpecs[lootSpecId] and GetSpecPoolSize(lootTable, lootSpecId, classId) or math.huge;
    local bestSpec = nil;
    local bestPoolSize = lootSpecPoolSize;

    for specId in pairs(eligibleSpecs) do
        if (specId ~= lootSpecId) then
            local poolSize = GetSpecPoolSize(lootTable, specId, classId);

            if (poolSize < bestPoolSize) then
                bestPoolSize = poolSize;
                bestSpec = specId;
            elseif (poolSize == bestPoolSize and bestSpec and specId == favoSpecId) then
                -- Prefer favoSpecId as tiebreaker so no arrow shows unnecessarily
                bestSpec = favoSpecId;
            end
        end
    end

    -- If best spec found equals the favoSpecId, no switch needed
    if (bestSpec == favoSpecId) then
        return nil;
    end

    return bestSpec;
end

function Keystone:GetLootReminderItemList(challengeModeId)
    local favorites = DB:Get("favorites");
    local characterKey = Character:GetKey();

    if (not favorites or not favorites[characterKey] or not favorites[characterKey][challengeModeId]) then
        return {}, {};
    end

    local sourceFavorites = favorites[characterKey][challengeModeId];
    local classId = Character:GetCurrentClassId();
    local numSpecs = GetNumSpecializations();

    -- Collect all specs that have at least one favorited item
    local specHasFavorite = {};
    for i = 1, numSpecs do
        local specId = GetSpecializationInfo(i);
        if (sourceFavorites[specId] and next(sourceFavorites[specId])) then
            specHasFavorite[specId] = true;
        end
    end

    -- Collect all favorited items across all specs (deduplicated)
    local favoriteItems = {};
    for specId in pairs(specHasFavorite) do
        for itemId, itemInfo in pairs(sourceFavorites[specId]) do
            if (not favoriteItems[itemId]) then
                favoriteItems[itemId] = itemInfo.icon;
            end
        end
    end

    -- Build item list per favo-spec based on drop specs
    local rawItemList = {};
    local allSpecItems = {};
    for itemId, icon in pairs(favoriteItems) do
        local item = Query:GetItemInfo(itemId);
        if (item) then
            local dropSpecs = item.classes[classId];
            if (not dropSpecs) then
                -- skip
            elseif (#dropSpecs == numSpecs) then
                allSpecItems[itemId] = { itemId = itemId, icon = icon };
            else
                for _, dropSpecId in ipairs(dropSpecs) do
                    if (specHasFavorite[dropSpecId]) then
                        rawItemList[dropSpecId] = rawItemList[dropSpecId] or {};
                        table.insert(rawItemList[dropSpecId], { itemId = itemId, icon = icon });
                    end
                end
            end
        end
    end

    -- Resolve current loot spec
    local lootSpecId = GetLootSpecialization();
    if (lootSpecId == 0) then
        lootSpecId = GetSpecializationInfo(GetSpecialization());
    end

    -- Subset check: remove specs whose item list is fully covered by another spec
    -- Never remove the loot spec, it is the baseline
    local toRemove = {};
    for specIdA, itemsA in pairs(rawItemList) do
        if (specIdA ~= lootSpecId) then
            for specIdB, itemsB in pairs(rawItemList) do
                if (specIdA ~= specIdB and not toRemove[specIdA]) then
                    local aIsSubsetOfB = true;
                    for _, itemA in ipairs(itemsA) do
                        local found = false;
                        for _, itemB in ipairs(itemsB) do
                            if (itemA.itemId == itemB.itemId) then
                                found = true;
                                break;
                            end
                        end
                        if (not found) then
                            aIsSubsetOfB = false;
                            break;
                        end
                    end
                    if (aIsSubsetOfB) then
                        local bIsSubsetOfA = true;
                        for _, itemB in ipairs(itemsB) do
                            local found = false;
                            for _, itemA in ipairs(itemsA) do
                                if (itemB.itemId == itemA.itemId) then
                                    found = true;
                                    break;
                                end
                            end
                            if (not found) then
                                bIsSubsetOfA = false;
                                break;
                            end
                        end

                        if (bIsSubsetOfA and specIdA > specIdB and specIdB ~= lootSpecId) then
                            -- Equal sets: keep the lower specId, unless specIdB is the loot spec
                        else
                            toRemove[specIdA] = true;
                        end
                    end
                end
            end
        end
    end

    for specId in pairs(toRemove) do
        rawItemList[specId] = nil;
    end

    -- Get dungeon loot table for pool size calculations
    local dungeonLootTable = nil;
    for _, dungeon in ipairs(Query:GetDungeons()) do
        if (dungeon.challengeModeId == challengeModeId) then
            dungeonLootTable = dungeon.lootTable;
            break;
        end
    end

    -- If all favorited items drop for every spec, find the spec with the smallest pool
    if (not next(rawItemList)) then
        if (not next(allSpecItems) or not dungeonLootTable) then
            return {}, allSpecItems;
        end

        local lootSpecPoolSize = GetSpecPoolSize(dungeonLootTable, lootSpecId, classId);
        local bestSpec = nil;
        local bestPoolSize = lootSpecPoolSize;

        for i = 1, numSpecs do
            local specId = GetSpecializationInfo(i);

            if (specId ~= lootSpecId) then
                local poolSize = GetSpecPoolSize(dungeonLootTable, specId, classId);
                if (poolSize < bestPoolSize) then
                    bestPoolSize = poolSize;
                    bestSpec = specId;
                end
            end
        end

        if (not bestSpec) then
            return {}, allSpecItems;
        end

        local items = {};
        for _, item in pairs(allSpecItems) do
            table.insert(items, item);
        end

        return {
            [lootSpecId] = {
                items         = items,
                displaySpecId = bestSpec,
                favoSpecId    = lootSpecId,
            },
        }, allSpecItems;
    end

    -- For each favo-spec group, find the spec with the smallest loot pool
    -- that can still drop all the favorited items
    local itemList = {};

    for favoSpecId, items in pairs(rawItemList) do
        local displaySpecId = favoSpecId;

        if (dungeonLootTable) then
            local bestSpec = GetBestSpecForItems(items, classId, dungeonLootTable, lootSpecId, favoSpecId);
            if (bestSpec) then
                displaySpecId = bestSpec;
            else
                displaySpecId = lootSpecId;
            end
        end

        itemList[favoSpecId] = {
            items         = items,
            displaySpecId = displaySpecId,
            favoSpecId    = favoSpecId,
        };
    end

    -- If all display specs already match the current loot spec, no reminder needed
    local needsReminder = false;

    for _, entry in pairs(itemList) do
        if (entry.displaySpecId ~= lootSpecId) then
            needsReminder = true;
            break;
        end
    end

    if (not needsReminder) then
        return {}, allSpecItems;
    end

    return itemList, allSpecItems;
end

function Keystone:GetRewards(keystoneLevel)
    if (not keystoneLevel or keystoneLevel < 2) then
        return;
    end

    if (keystoneLevel > 10) then
        keystoneLevel = 10;
    end

    local mapping = KeystoneLoot.KeystoneMapping
    if (not mapping or not mapping.rules) then
        return;
    end

    -- Find matching rule
    for _, rule in ipairs(mapping.rules) do
        for _, level in ipairs(rule.keystones) do
            if (level == keystoneLevel) then
                -- Get upgrade tracks
                local endTrack = KeystoneLoot.UpgradeTracks.dungeon[rule.endOfRun.track][rule.endOfRun.rank];
                local vaultTrack = KeystoneLoot.UpgradeTracks.dungeon[rule.greatVault.track][rule.greatVault.rank];

                return {
                    endOfRun = {
                        level = endTrack.ilvl,
                        text = endTrack.label,
                        rank = endTrack.rank
                    },
                    greatVault = {
                        level = vaultTrack.ilvl,
                        text = vaultTrack.label,
                        rank = vaultTrack.rank
                    }
                };
            end
        end
    end
end
